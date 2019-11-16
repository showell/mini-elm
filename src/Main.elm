module Main exposing (main)

import Browser
import Example
import Type
    exposing
        ( Model
        , Msg(..)
        )



-- MODEL / INIT


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        code =
            """
let
    y = 7
in
List.tail
    [ 5
    , y
    , False
    , List.map
        (\\x -> x + 3.1)
        (5 :: [(\\x -> x + 1)(8)])
    , 30 + 20 + 10
    , if True then 7 else 13
    ]""" |> String.trim

        model =
            { title = "simple demo"
            , code = code
            , inputCode = code
            }
    in
    ( model, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Compile ->
            ( { model | code = model.inputCode }, Cmd.none )

        UpdateInputCode inputCode ->
            ( { model | inputCode = inputCode }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = model.title
    , body = Example.view model
    }
