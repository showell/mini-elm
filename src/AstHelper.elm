module AstHelper exposing (toString)

import Elm.AST.Frontend.Unwrapped as FE


indent : List String -> String
indent lst =
    lst
        |> String.join "\n"
        |> String.split "\n"
        |> List.map (\s -> "    " ++ s)
        |> String.join "\n"


toString : FE.Expr -> String
toString ast =
    case ast of
        FE.If rec ->
            "If\n"
                ++ ([ rec.test |> toString
                    , rec.test |> toString
                    , rec.else_ |> toString
                    ]
                        |> indent
                   )

        FE.Var var ->
            case var.module_ of
                Just mname ->
                    "Var: " ++ mname ++ "." ++ var.name

                Nothing ->
                    "Var: " ++ var.name

        FE.Call rec ->
            "Call\n"
                ++ ([ rec.fn |> toString
                    , rec.argument |> toString
                    ]
                        |> indent
                   )

        FE.Argument name ->
            "Argument: " ++ name

        FE.Lambda rec ->
            "Lambda "
                ++ (rec.arguments |> String.join " ")
                ++ "\n"
                ++ ([ rec.body |> toString
                    ]
                        |> indent
                   )

        FE.List items ->
            "List\n"
                ++ (items
                        |> List.map toString
                        |> indent
                   )

        FE.Cons a b ->
            "Cons\n"
                ++ ([ a |> toString
                    , b |> toString
                    ]
                        |> indent
                   )

        FE.Plus a b ->
            "Plus\n"
                ++ ([ a |> toString
                    , b |> toString
                    ]
                        |> indent
                   )

        FE.Int n ->
            "Int: " ++ (n |> String.fromInt)

        FE.Float n ->
            "Float: " ++ (n |> String.fromFloat)

        FE.Bool b ->
            "Float: "
                ++ (if b then
                        "True"

                    else
                        "False"
                   )

        _ ->
            "???"
