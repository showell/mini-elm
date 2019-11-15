module Type exposing (Model, Msg(..))


type alias Model =
    { title : String
    , code : String
    , inputCode : String
    }


type Msg
    = Compile
    | UpdateInputCode String
