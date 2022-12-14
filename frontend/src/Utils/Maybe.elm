module Utils.Maybe exposing (..)


withDefault : Maybe a -> a -> a
withDefault maybe value =
    case maybe of
        Just x ->
            x

        Nothing ->
            value
