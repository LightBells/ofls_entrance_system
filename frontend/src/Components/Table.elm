module Components.Table exposing (view)

import Api.Log exposing (LogList)
import Element exposing (..)


view : LogList -> Element msg
view logs =
    Element.table [] <|
        { data = logs
        , columns =
            [ { header = text "StudentID"
              , width = fill
              , view = \log -> text log.id
              }
            , { header = text "Student Name"
              , width = fill
              , view = \log -> text "Hogehoge"
              }
            , { header = text "Date"
              , width = fill
              , view = \log -> text log.date
              }
            , { header = text "Entry Time"
              , width = fill
              , view = \log -> text log.entry_time
              }
            , { header = text "Exit Time"
              , width = fill
              , view = \log -> text log.exit_time
              }
            , { header = text "purpose"
              , width = fill
              , view = \log -> text <| purposeToString log.purpose
              }
            , { header = text "satisfication"
              , width = fill
              , view = \log -> text <| satisficationToString log.satisfaction
              }
            ]
        }


satisficationToString : Int -> String
satisficationToString satisfication =
    case satisfication of
        0 ->
            "Very Satisfied"

        1 ->
            "Satisfied"

        2 ->
            "Neutral"

        3 ->
            "Dissatisfied"

        4 ->
            "Very Dissatisfied"

        _ ->
            ""


purposeToString : Int -> String
purposeToString purpose =
    case purpose of
        0 ->
            "Gahaha"

        1 ->
            "Study"

        2 ->
            "Work"

        3 ->
            "Socialize"

        4 ->
            "Hobbies"

        _ ->
            ""
