module Api.Log exposing
    ( Log
    , LogList
    , list
    )

import Api.Data exposing (Data)
import Api.Endpoint exposing (listLog)
import Api.Token exposing (Token)
import Json.Decode as Decode
import Utils.Json exposing (withField)


type alias Log =
    { id : String
    , date : String
    , entry_time : String
    , exit_time : String
    , purpose : Int
    , satisfaction : Int
    }


type alias LogList =
    List Log


logDecoder : Decode.Decoder Log
logDecoder =
    Utils.Json.record Log
        |> withField "id" Decode.string
        |> withField "date" Decode.string
        |> withField "entry_time" Decode.string
        |> withField "exit_time" Decode.string
        |> withField "purpose" Decode.int
        |> withField "satisfication" Decode.int


logsFieldDecoder : Decode.Decoder (List Log)
logsFieldDecoder =
    Decode.list logDecoder


decoder : Decode.Decoder LogList
decoder =
    Decode.field "logs" logsFieldDecoder


list :
    { token : Maybe Token
    , onResponse : Data LogList -> msg
    }
    -> Cmd msg
list options =
    Api.Token.get options.token
        { url = listLog
        , expect = Api.Data.expectJson options.onResponse decoder
        }
