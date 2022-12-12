module Api.Data exposing (..)

import Http
import Json.Decode as Decode


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


expectJson : (Data value -> msg) -> Decode.Decoder value -> Http.Expect msg
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

                Http.BadStatus_ _ body ->
                    case Decode.decodeString errorDecoder body of
                        Ok errors ->
                            Err errors

                        Err _ ->
                            Err [ "Bad status code" ]

                Http.GoodStatus_ _ body ->
                    case Decode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err error ->
                            Err [ Decode.errorToString error ]


errorDecoder : Decode.Decoder (List String)
errorDecoder =
    Decode.keyValuePairs (Decode.list Decode.string)
        |> Decode.field "errors"
        |> Decode.map
            (List.concatMap
                (\( key, values ) ->
                    values
                        |> List.map (\value -> key ++ ": " ++ value)
                )
            )


fromResult : Result (List String) value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err errors ->
            Failure errors
