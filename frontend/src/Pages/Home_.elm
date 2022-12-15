module Pages.Home_ exposing (Model, Msg, changedSorting, page)

import Api.Data exposing (Data)
import Api.Log
import Api.NameList
import Api.User
import Bytes
import Components.Footer
import Dict
import Effect exposing (Effect)
import Element exposing (..)
import Element.Input as Input
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Gen.Params.Home_ exposing (Params)
import Html.Attributes as Attributes
import Http
import Material.Icons as Icons
import Material.Icons.Types exposing (Coloring(..))
import Page
import Ports exposing (refreshReceiver)
import Request
import Shared
import Task
import Utils.Date exposing (toYYYYMMDD)
import View exposing (View)
import Widget
import Widget.Icon as Icon
import Widget.Material as Material
import Widget.Material.Typography as Typography


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.protected.advanced
        (\user ->
            { init = init user shared
            , update = update user
            , view = view shared
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { logs : Data Api.Log.LogList
    , query : String
    , download_query : String
    , sort_by : String
    , asc : Bool
    , show_menu : Bool
    , name_dict : Data Api.NameList.NameDict
    , display_page : Int
    }


init : Api.User.User -> Shared.Model -> ( Model, Effect Msg )
init user shared =
    let
        name_dict =
            case shared.name_dict of
                Just dict ->
                    Api.Data.Success dict

                Nothing ->
                    Api.Data.Loading

        effect =
            case shared.name_dict of
                Just _ ->
                    Effect.fromCmd (fetchLogList user)

                Nothing ->
                    Effect.batch
                        [ Effect.fromCmd (fetchLogList user)
                        , Effect.fromCmd requestCSV
                        ]
    in
    ( { logs = Api.Data.Loading
      , query = ""
      , sort_by = "date"
      , download_query = ""
      , asc = False
      , show_menu = False
      , name_dict = name_dict
      , display_page = 0
      }
    , effect
    )



-- UPDATE


type Msg
    = ClickedSignOut
    | GotLogs (Data Api.Log.LogList)
    | Refresh
    | Updated Field String
    | ChangedSorting String
    | ToggledMenu
    | NameFileRequested File
    | CsvLoaded String
    | ClickedSelectButton
    | CsvDownload
    | GotCsv (Result Http.Error Bytes.Bytes)
    | ChangedSelected Int


type Field
    = Search
    | Download


update : Api.User.User -> Msg -> Model -> ( Model, Effect Msg )
update user msg model =
    case msg of
        ClickedSignOut ->
            ( model
            , Effect.fromShared
                Shared.ClickedSignOut
            )

        GotLogs logs ->
            ( { model | logs = logs }
            , Effect.none
            )

        Refresh ->
            case model.logs of
                Api.Data.Success value ->
                    ( { model | logs = Api.Data.Refresh value }
                    , Effect.fromCmd (fetchLogList user)
                    )

                _ ->
                    ( model, Effect.none )

        Updated Search query ->
            ( { model
                | query = query
                , display_page = 0
              }
            , Effect.none
            )

        Updated Download query ->
            ( { model | download_query = query }
            , Effect.none
            )

        ChangedSorting field ->
            if model.sort_by == field then
                ( { model
                    | sort_by = field
                    , asc = not model.asc
                  }
                , Effect.none
                )

            else
                ( { model
                    | sort_by = field
                  }
                , Effect.fromCmd (fetchLogList user)
                )

        ChangedSelected i ->
            ( { model
                | display_page = i
              }
            , Effect.none
            )

        ToggledMenu ->
            ( { model | show_menu = not model.show_menu }
            , Effect.none
            )

        NameFileRequested file ->
            ( model
            , Effect.fromCmd <| fetchNameDict file
            )

        CsvLoaded string ->
            let
                name_dict =
                    Api.Data.fromCsvResult <| Api.NameList.parseCsv string
            in
            ( { model
                | name_dict = name_dict
              }
            , case name_dict of
                Api.Data.Success dict ->
                    Effect.fromCmd <| Ports.saveNameList dict

                _ ->
                    Effect.none
            )

        ClickedSelectButton ->
            ( model
            , Effect.fromCmd requestCSV
            )

        CsvDownload ->
            ( model
            , Effect.fromCmd <| downloadCsv model user
            )

        GotCsv result ->
            case Api.Data.fromHttpResult result of
                Api.Data.Success content ->
                    ( model
                    , Effect.fromCmd <| saveFile content
                    )

                _ ->
                    ( model, Effect.none )


saveFile : Bytes.Bytes -> Cmd msg
saveFile content =
    Download.bytes "entrance_log.csv" "text/csv" content


changedSorting : String -> Msg
changedSorting field =
    ChangedSorting field



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    refreshReceiver Refresh


view : Shared.Model -> Model -> View Msg
view _ model =
    { title = "Homepage"
    , element =
        column
            [ width fill
            , height fill
            ]
            [ menuBar model
            , row
                [ width fill
                , height fill
                , paddingXY 5 5
                ]
                [ el
                    [ htmlAttribute
                        (Attributes.style "display" <|
                            if model.show_menu then
                                "block"

                            else
                                "none"
                        )
                    , width <|
                        px 300
                    , height fill
                    ]
                  <|
                    menuView model
                , column
                    [ width <| fillPortion 5
                    , alignTop
                    ]
                    [ case model.name_dict of
                        Api.Data.Success _ ->
                            case model.logs of
                                Api.Data.Success logs ->
                                    tableView model (logs |> filter model.query)

                                Api.Data.Refresh logs ->
                                    tableView model (logs |> filter model.query)

                                Api.Data.Failure error ->
                                    Element.text <| List.foldl (\c s -> c ++ " " ++ s) "" error

                                _ ->
                                    Nothing |> Widget.circularProgressIndicator (Material.progressIndicator Material.defaultPalette)

                        _ ->
                            column []
                                [ text "Name list CSV is not loaded"
                                , Widget.button (Material.containedButton Material.defaultPalette)
                                    { text = "Select CSV"
                                    , icon = Icons.upload_file |> Icon.elmMaterialIcons Color
                                    , onPress = Just ClickedSelectButton
                                    }
                                ]
                    ]
                ]
            , Components.Footer.view
            ]
    }


menuView : Model -> Element Msg
menuView model =
    column
        [ paddingXY 5 0
        ]
        [ el [ paddingXY 0 10 ] <| text "Menu"
        , column [ paddingXY 0 10 ]
            [ text "Reload name list CSV"
            , Widget.button (Material.containedButton Material.defaultPalette)
                { text = "Select CSV"
                , icon = Icons.upload_file |> Icon.elmMaterialIcons Color
                , onPress = Just ClickedSelectButton
                }
            ]
        , column [ paddingXY 0 10 ]
            [ text "Download a CSV file"
            , Widget.searchInput (Material.textInput Material.defaultPalette)
                { text = model.download_query
                , placeholder = Just (Input.placeholder [] (text "YYYYMM"))
                , label = ""
                , onChange = Updated Download
                , chips = []
                }
            , Widget.button (Material.containedButton Material.defaultPalette)
                { text = "Download"
                , icon = Icons.upload_file |> Icon.elmMaterialIcons Color
                , onPress = Just CsvDownload
                }
            ]
        ]


tableView : Model -> List Api.Log.Log -> Element Msg
tableView model logs =
    column [ width fill, height fill ]
        [ Widget.sortTable
            (Material.sortTable Material.defaultPalette)
            { content = List.reverse <| List.drop (100 * model.display_page) <| List.take (100 * (model.display_page + 1)) logs
            , columns =
                [ Widget.stringColumn
                    { title = "StudentID"
                    , value = .id
                    , toString = identity
                    , width = fill
                    }
                , Widget.stringColumn
                    { title = "Student Name"
                    , width = fill
                    , toString = \id -> getStudentName model id
                    , value = .id
                    }
                , Widget.intColumn
                    { title = "Date"
                    , width = fill
                    , value = .date
                    , toString = toYYYYMMDD
                    }
                , Widget.unsortableColumn
                    { title = "Entry Time"
                    , width = fill
                    , toString = .entry_time
                    }
                , Widget.unsortableColumn
                    { title = "Exit Time"
                    , width = fill
                    , toString = .exit_time
                    }
                , Widget.intColumn
                    { title = "purpose"
                    , width = fill
                    , value = .purpose
                    , toString = purposeToString
                    }
                ]
            , asc = model.asc
            , sortBy = model.sort_by
            , onChange = ChangedSorting
            }
        , el [ centerX ]
            ({ selected = Just model.display_page
             , options =
                List.range 1 (logs |> List.length |> (\i -> i // 100))
                    |> List.map
                        (\i ->
                            { text = String.fromInt i
                            , icon = always Element.none
                            }
                        )
             , onSelect = \i -> Just <| ChangedSelected i
             }
                |> Widget.select
                |> Widget.buttonRow
                    { elementRow = Material.buttonRow
                    , content = Material.outlinedButton Material.defaultPalette
                    }
            )
        ]



-- MENU BAR


menuBar : Model -> Element Msg
menuBar model =
    Widget.menuBar
        (Material.menuBar
            Material.defaultPalette
        )
        { title =
            "OFLS - Entrance Log Manager"
                |> Element.text
                |> Element.el Typography.h6
        , deviceClass = Desktop
        , openRightSheet = Nothing
        , openLeftSheet = Just ToggledMenu
        , openTopSheet = Nothing
        , primaryActions =
            [ { icon =
                    Icons.logout
                        |> Icon.elmMaterialIcons Color
              , text = "Logout"
              , onPress = Just ClickedSignOut
              }
            ]
        , search =
            Just
                { text = model.query
                , chips = []
                , placeholder = Just (Input.placeholder [] (text "Student ID"))
                , onChange = Updated Search
                , label = "Search"
                }
        }



-- internal
-- Request CSV


requestCSV : Cmd Msg
requestCSV =
    Select.file [ "text/csv" ] NameFileRequested


getStudentName : Model -> String -> String
getStudentName model id =
    case model.name_dict of
        Api.Data.Success dict ->
            case Dict.get id dict of
                Just name ->
                    name

                Nothing ->
                    "Unknown"

        _ ->
            "Unknown"


filter : String -> List Api.Log.Log -> List Api.Log.Log
filter query logs =
    if String.isEmpty query then
        logs

    else if String.startsWith "s" query then
        logs
            |> List.filter (\log -> String.startsWith query log.id)

    else if String.all (\c -> Char.isDigit c || c == '/') query then
        logs
            |> List.filter (\log -> String.startsWith query (toYYYYMMDD log.date))

    else
        logs


fetchLogList :
    Api.User.User
    -> Cmd Msg
fetchLogList user =
    Api.Log.list
        { token = Just user.token
        , onResponse = GotLogs
        }


downloadCsv : Model -> Api.User.User -> Cmd Msg
downloadCsv model user =
    Api.Log.csvDownload model.download_query
        { token = Just user.token
        , onResponse = GotCsv
        }


fetchNameDict : File -> Cmd Msg
fetchNameDict file =
    Task.perform CsvLoaded (File.toString file)


satisfactionToString : Int -> String
satisfactionToString satisfication =
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
            "質問"

        1 ->
            "自習"

        2 ->
            "WS"

        3 ->
            "休憩"

        4 ->
            "図書閲覧"

        5 ->
            "その他"

        _ ->
            ""
