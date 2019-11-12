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
import MeType
    exposing
        ( Expr(..)
        , V(..)
        )


getBuiltin var =
    let
        module_ =
            var.module_
                |> Maybe.withDefault "<unknown>"

        builtins =
            [ ( "List.map", MeList.map )
            ]
                |> Dict.fromList
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
            F1
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


text s =
    Html.div [ style "padding" "20px" ] [ Html.text s ]


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
            code ++ " gets intrepreted as " ++ result
    in
    [ text demoText
    , text elmInElmSide
    , text metaElmSide
    , text (Debug.toString computedExpr)
    , Html.hr [] []
    ]


view =
    [ "17 :: (List.map (\\x -> x + 2) [ 10, 20, 30 ])"
    , "(100 + 60 + 2) :: [5, 7+2]"
    , "(\\x -> x + 1)(7)"
    , "(\\z -> 2 + z)(40)"
    ]
        |> List.map runExample
        |> List.concat
        |> Html.div []
