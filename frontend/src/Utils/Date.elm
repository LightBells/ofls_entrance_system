module Utils.Date exposing (..)

import Date exposing (Date, format, fromCalendarDate, fromRataDie, numberToMonth, toRataDie)


parseYYYYMMDD : String -> Maybe Int
parseYYYYMMDD str =
    let
        parts =
            String.split "/" str
    in
    case parts of
        [ year, month, day ] ->
            let
                monthInt =
                    String.toInt month

                dayInt =
                    String.toInt day

                yearInt =
                    String.toInt year
            in
            case ( monthInt, dayInt, yearInt ) of
                ( Just m, Just d, Just y ) ->
                    Just <| toRataDie (fromCalendarDate y (numberToMonth m) d)

                _ ->
                    Nothing

        _ ->
            Nothing


toYYYYMMDD : Int -> String
toYYYYMMDD dateInt =
    let
        date =
            fromRataDie dateInt
    in
    format "y/M/d(E)" date


convert : String -> String
convert date =
    parseYYYYMMDD date
        |> Maybe.map toYYYYMMDD
        |> Maybe.withDefault ""
