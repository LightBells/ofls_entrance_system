module Api.Data exposing (..)

import Bytes
import Csv.Decode as CsvDecode
import Http
import Json.Decode as JsonDecode


type Data value
    = NotAsked
    | Loading
    | Failure (List String)
    | Success value
    | Refresh value


map : (a -> b) -> Data a -> Data b
map fn data =
    case data of
        Success value ->
            Success (fn value)

        Refresh value ->
            Refresh (fn value)

        Failure errors ->
            Failure errors

        Loading ->
            Loading

        NotAsked ->
            NotAsked


toMaybe : Data value -> Maybe value
toMaybe data =
    case data of
        Success value ->
            Just value

        _ ->
            Nothing


resolve : (body -> Result String a) -> Http.Response body -> Result Http.Error a
resolve toResult response =
    case response of
        Http.BadUrl_ url_ ->
            Err (Http.BadUrl url_)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ metadata _ ->
            Err (Http.BadStatus metadata.statusCode)

        Http.GoodStatus_ _ body ->
            Result.mapError Http.BadBody (toResult body)


expectJson : (Data value -> msg) -> JsonDecode.Decoder value -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse (fromResult >> toMsg) <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err [ "Bad URL: " ++ url ]

                Http.Timeout_ ->
                    Err [ "Timeout" ]

                Http.NetworkError_ ->
                    Err [ "Network error" ]

                Http.BadStatus_ meta body ->
                    case JsonDecode.decodeString errorJsonDecoder body of
                        Ok errors ->
                            Err errors

                        Err _ ->
                            Err [ "Bad status code: " ++ meta.statusText ]

                Http.GoodStatus_ _ body ->
                    case JsonDecode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err error ->
                            Err [ JsonDecode.errorToString error ]


errorJsonDecoder : JsonDecode.Decoder (List String)
errorJsonDecoder =
    JsonDecode.keyValuePairs (JsonDecode.list JsonDecode.string)
        |> JsonDecode.field "errors"
        |> JsonDecode.map
            (List.concatMap
                (\( key, values ) ->
                    values
                        |> List.map (\value -> key ++ ": " ++ value)
                )
            )


errorCsvDecoder : CsvDecode.Error -> String
errorCsvDecoder error =
    CsvDecode.errorToString error


fromHttpResult : Result Http.Error Bytes.Bytes -> Data Bytes.Bytes
fromHttpResult result =
    case result of
        Ok value ->
            Success value

        Err error ->
            Failure [ decodeHttpError error ]


decodeHttpError : Http.Error -> String
decodeHttpError error =
    case error of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus statusCode ->
            "Bad status code: " ++ String.fromInt statusCode

        Http.BadBody body ->
            "Bad body: " ++ body


fromCsvResult : Result CsvDecode.Error value -> Data value
fromCsvResult result =
    case result of
        Ok value ->
            Success value

        Err error ->
            Failure [ errorCsvDecoder error ]


fromResult : Result (List String) value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err errors ->
            Failure errors
