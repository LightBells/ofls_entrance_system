module Utils.Json exposing
    ( maybe
    , record
    , withDefault
    , withField
    )

import Json.Decode as Decode
import Json.Encode as Encode



-- DECODING RECORDS


record : fn -> Decode.Decoder fn
record =
    Decode.succeed


withField :
    String
    -> Decode.Decoder field
    -> Decode.Decoder (field -> value)
    -> Decode.Decoder value
withField str decoder =
    apply (Decode.field str decoder)


withDefault : value -> Decode.Decoder value -> Decode.Decoder value
withDefault fallback decoder =
    Decode.maybe decoder |> Decode.map (Maybe.withDefault fallback)



-- ENCODING


maybe : (value -> Decode.Value) -> Maybe value -> Decode.Value
maybe encode value =
    value |> Maybe.map encode |> Maybe.withDefault Encode.null



-- INTERNALS


apply : Decode.Decoder field -> Decode.Decoder (field -> value) -> Decode.Decoder value
apply =
    Decode.map2 (|>)
