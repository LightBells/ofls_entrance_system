module Api.Log exposing
    ( Log
    , LogList
    , csvDownload
    , list
    )

import Api.Data exposing (Data, resolve)
import Api.Endpoint exposing (downloadCSV, listLog)
import Api.Token exposing (Token)
import Bytes
import Http
import Json.Decode as Decode
import Maybe
import Utils.Date exposing (parseYYYYMMDD)
import Utils.Json exposing (withField)


type alias RawLog =
    { id : String
    , date : String
    , entry_time : String
    , exit_time : String
    , purpose : Int
    , satisfaction : Int
    }


type alias Log =
    { id : String
    , date : Int
    , entry_time : String
    , exit_time : String
    , purpose : Int
    , satisfaction : Int
    }


type alias LogList =
    List Log


rawLogToLog : RawLog -> Log
rawLogToLog rawLog =
    { id = rawLog.id
    , date = rawLog.date |> parseYYYYMMDD |> Maybe.withDefault 0
    , entry_time = rawLog.entry_time
    , exit_time = rawLog.exit_time
    , purpose = rawLog.purpose
    , satisfaction = rawLog.satisfaction
    }


logDecoder : Decode.Decoder RawLog
logDecoder =
    Utils.Json.record RawLog
        |> withField "id" Decode.string
        |> withField "date" Decode.string
        |> withField "entry_time" Decode.string
        |> withField "exit_time" Decode.string
        |> withField "purpose" Decode.int
        |> withField "satisfication" Decode.int


logsFieldDecoder : Decode.Decoder (List Log)
logsFieldDecoder =
    Decode.map (List.map rawLogToLog)
        (Decode.list logDecoder)


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


csvDownload :
    String
    ->
        { token : Maybe Token
        , onResponse : Result Http.Error Bytes.Bytes -> msg
        }
    -> Cmd msg
csvDownload query options =
    Api.Token.get options.token
        { url = downloadCSV ++ query
        , expect = Http.expectBytesResponse options.onResponse (resolve Ok)
        }
