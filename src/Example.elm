module Example exposing (view)

import Dict
import Elm.AST.Frontend as Frontend
import Elm.AST.Frontend.Unwrapped as FE
import Elm.Compiler
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onInput)
import MeList
import MeNumber
import MeRepr
import MeRunTime
import MeType
    exposing
        ( Expr(..)
        , V(..)
        )
import MeWrapper
import Type exposing (Model, Msg(..))


type alias VarInfo =
    { module_ : Maybe String
    , name : String
    }


getBuiltin : VarInfo -> Maybe Expr
getBuiltin var =
    let
        module_ =
            var.module_
                |> Maybe.withDefault "<unknown>"
    in
    Dict.get (module_ ++ "." ++ var.name) MeWrapper.allWrappers


meExpr : FE.Expr -> MeType.Expr
meExpr ast =
    case ast of
        FE.Var rec ->
            case getBuiltin rec of
                Just expr ->
                    expr

                _ ->
                    exprError ast

        FE.Call rec ->
            A1
                (meExpr rec.fn)
                (meExpr rec.argument)

        FE.Argument name ->
            VarName name

        FE.Lambda rec ->
            case rec.arguments of
                [] ->
                    exprError ast

                [ e1 ] ->
                    F1 e1 (meExpr rec.body)

                [ e1, e2 ] ->
                    F2 e1 e2 (meExpr rec.body)

                [ e1, e2, e3 ] ->
                    F3 e1 e2 e3 (meExpr rec.body)

                _ ->
                    exprError ast

        FE.List items ->
            items
                |> List.map meExpr
                |> VList
                |> SimpleValue

        FE.Cons a b ->
            Infix (meExpr a) MeList.cons (meExpr b)

        FE.Plus a b ->
            Infix (meExpr a) MeNumber.plus (meExpr b)

        FE.Int n ->
            n
                |> VInt
                |> SimpleValue

        _ ->
            exprError ast


exprError : FE.Expr -> MeType.Expr
exprError ast =
    let
        _ =
            Debug.log "unsupported ast" ast
    in
    "cannot interpret"
        |> VError
        |> SimpleValue


runExample : String -> List (Html msg)
runExample code =
    let
        astResult =
            code
                |> Elm.Compiler.parseExpr
                |> Result.map Frontend.unwrap

        expr =
            case astResult of
                Ok ast ->
                    ast
                        |> meExpr

                Err _ ->
                    "cannot compile"
                        |> VError
                        |> ComputedValue

        computedExpr =
            expr
                |> MeRunTime.computeExpr

        result =
            computedExpr
                |> MeRepr.fromExpr

        elmInElmSide =
            Debug.toString astResult

        metaElmSide =
            Debug.toString expr

        demoText =
            code ++ "\n = \n\n" ++ result
    in
    [ text demoText
    , text elmInElmSide
    , text metaElmSide
    , text (Debug.toString computedExpr)
    , Html.hr [] []
    ]



{--
toCall : String -> String
toCall s =
    let
        apply f v =
            "(" ++ f ++ ")(\n" ++ v ++ ")"

        makeCalls lst =
            case lst of
                [] ->
                    "empty pipe expression"

                h :: rest ->
                    List.foldl apply h rest
    in
    s
        |> String.split "|>"
        |> List.map String.trim
        |> makeCalls
--}


text : String -> Html msg
text s =
    Html.div [ style "padding" "5px" ] [ Html.pre [] [ Html.text s ] ]


evaluate : String -> String
evaluate code =
    let
        astResult =
            code
                |> Elm.Compiler.parseExpr
                |> Result.map Frontend.unwrap

        expr =
            case astResult of
                Ok ast ->
                    ast
                        |> meExpr

                Err _ ->
                    "cannot compile"
                        |> VError
                        |> ComputedValue

        computedExpr =
            expr
                |> MeRunTime.computeExpr
    in
    computedExpr
        |> MeRepr.fromExpr


divify : Html Msg -> Html Msg
divify html =
    html |> List.singleton |> div [ style "padding" "5px" ]


viewRepl : Model -> Html Msg
viewRepl model =
    let
        textAreaAttrs =
            [ style "width" "350px"
            , style "height" "150px"
            , onInput UpdateInputCode
            ]

        introText =
            """
            This is powered by elm-in-elm (parsing) and meta-elm (evaluation).
            The supported operators are "+" and "::" for now.  The supported data
            types are lists and integers.  You must use normal
            calling syntax (e.g. no "|>" or similar things).
            """
                |> Html.text
                |> List.singleton
                |> Html.p [ style "width" "350px" ]

        inputArea =
            [ introText
            , Html.textarea textAreaAttrs [ Html.text model.inputCode ]
            , Html.button [ onClick Compile ] [ Html.text "compile" ] |> divify
            , Html.text (evaluate model.code) |> divify
            ]
                |> div [ style "padding" "50px" ]
    in
    inputArea


view : Model -> List (Html Msg)
view model =
    [ viewRepl model
    , Html.hr [] []
    , Html.h3 [] [ Html.text "supported methods" ]
    , MeWrapper.viewWrappers |> div []
    , Html.hr [] []
    , Html.text "ignore everything below:"
    , viewExample
    ]


viewExample : Html Msg
viewExample =
    [ "17 :: (List.map (\\x -> x + 2) [ 10, 20, 30 ])"
    , "(100 + 60 + 2) :: [5, 7+2]"
    , "(\\x -> x + 1)(7)"
    , "(\\z -> 2 + z)(40)"

    {--
    , toCall """
            [ 41, 17, 22, 35, 500 + 7 ]
                |> List.indexedMap Tuple.pair
                |> List.sortBy Tuple.second
                |> List.map Tuple.first
                |> List.indexedMap Tuple.pair
                |> List.sortBy Tuple.second
                |> List.map Tuple.first
                |> List.map (\\n -> n + 1)
                """
    --}
    ]
        |> List.map runExample
        |> List.concat
        |> Html.div []
