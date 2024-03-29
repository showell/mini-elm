module Example exposing (view)

import AstHelper
import Dict
import Elm.AST.Frontend as Frontend
import Elm.AST.Frontend.Unwrapped as FE
import Elm.Compiler
import Elm.Compiler.Error
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onInput)
import Html.Lazy
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
        FE.Let rec ->
            let
                bindings =
                    rec.bindings
                        |> List.map
                            (\r ->
                                ( r.name
                                , r.body |> meExpr
                                )
                            )
            in
            LetIn
                bindings
                (rec.body |> meExpr)

        FE.If rec ->
            IfElse
                (rec.test |> meExpr)
                (rec.then_ |> meExpr)
                (rec.else_ |> meExpr)

        FE.Var rec ->
            case getBuiltin rec of
                Just expr ->
                    expr

                _ ->
                    rec.name |> VarName

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

        FE.Bool n ->
            n
                |> VBool
                |> SimpleValue

        FE.Float n ->
            n
                |> VFloat
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


evalAstInJS ast =
    "REPLACE_CODE_HERE"


astToString : Result Elm.Compiler.Error.Error FE.Expr -> String
astToString astResult =
    case astResult of
        Ok ast ->
            ast
                |> AstHelper.toString

        _ ->
            "cannot compile"


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
            astResult
                |> astToString

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

        resultFromJs =
            astResult
                |> evalAstInJS
    in
    if resultFromJs == "REPLACE" ++ "_CODE_HERE" then
        """
        WARNING!!!!

        You should run postprocess.py to create
        index2.html, which does a JS eval of
        the AST
        """

    else
        let
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
                    |> MeRepr.fromExpr
                    |> String.replace "\n" ""
        in
        "USING meta-elm:\n"
            ++ computedExpr
            ++ "\n\nUSING eval.js:\n"
            ++ resultFromJs
            ++ "\n\n\n"
            ++ (astResult |> astToString)


divify : Html Msg -> Html Msg
divify html =
    html |> List.singleton |> div [ style "padding" "5px" ]


showResult : Html Msg -> Html Msg
showResult s =
    s
        |> List.singleton
        |> Html.pre []
        |> divify


evaluationResult : String -> Html Msg
evaluationResult code =
    -- this can be expensive, memoize it!
    Html.text (evaluate code) |> showResult


viewRepl : Model -> Html Msg
viewRepl model =
    let
        textAreaAttrs =
            [ style "width" "350px"
            , style "height" "280px"
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
            , Html.Lazy.lazy evaluationResult model.code
            ]
                |> div [ style "padding" "20px" ]
    in
    inputArea


bringInBuiltins =
    let
        sort =
            List.sort [ 1, 2, 3 ]
    in
    ()


view : Model -> List (Html Msg)
view model =
    let
        _ =
            bringInBuiltins
    in
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
    , "(\\x -> x + x + 3) 100"

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
