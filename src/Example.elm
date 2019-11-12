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


meExpr ast =
    case ast of
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
                |> MeRunTime.getFinalValue
                |> ComputedValue
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
    [ "(100 + 60 + 2) :: [5, 7+2]"
    ]
        |> List.map runExample
        |> List.concat
        |> Html.div []
