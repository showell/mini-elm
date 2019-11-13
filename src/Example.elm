module Example exposing (view)

import Dict
import Elm.AST.Frontend as Frontend
import Elm.AST.Frontend.Unwrapped as FE
import Elm.Compiler
import Html
import Html.Attributes exposing (style)
import MeList
import MeNumber
import MeRepr
import MeRunTime
import MeTuple
import MeType
    exposing
        ( Expr(..)
        , V(..)
        )


builtins =
    [ ( "List.map", MeList.map )
    , ( "List.sortBy", MeList.sortByInt ) -- cheating a bit!!!
    , ( "Tuple.first", MeTuple.first )
    , ( "Tuple.pair", MeTuple.pair )
    , ( "Tuple.second", MeTuple.second )
    , ( "List.indexedMap", MeList.indexedMap )
    ]
        |> Dict.fromList


getBuiltin var =
    let
        module_ =
            var.module_
                |> Maybe.withDefault "<unknown>"
    in
    Dict.get (module_ ++ "." ++ var.name) builtins


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
            meExpr rec.body

        FE.List items ->
            -- note there's a bug in meta-elm where I don't
            -- compute lists aggressively enough, so we do
            -- computeExpr below
            items
                |> List.map meExpr
                |> List.map MeRunTime.computeExpr
                |> VList
                |> SimpleValue

        FE.Cons a b ->
            Infix (meExpr a) MeList.cons (meExpr b)

        FE.Plus a b ->
            case ( a, b ) of
                ( FE.Argument name, _ ) ->
                    LambdaLeft name MeNumber.plus (meExpr b)

                ( _, FE.Argument name ) ->
                    LambdaRight (meExpr a) MeNumber.plus name

                _ ->
                    Infix (meExpr a) MeNumber.plus (meExpr b)

        FE.Int n ->
            n
                |> VInt
                |> SimpleValue

        _ ->
            exprError ast


exprError ast =
    let
        _ =
            Debug.log "unsupported ast" ast
    in
    "cannot interpret"
        |> VError
        |> SimpleValue


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


text s =
    Html.div [ style "padding" "5px" ] [ Html.pre [] [ Html.text s ] ]


view =
    [ "17 :: (List.map (\\x -> x + 2) [ 10, 20, 30 ])"
    , "(100 + 60 + 2) :: [5, 7+2]"
    , "(\\x -> x + 1)(7)"
    , "(\\z -> 2 + z)(40)"
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
    ]
        |> List.map runExample
        |> List.concat
        |> Html.div []
