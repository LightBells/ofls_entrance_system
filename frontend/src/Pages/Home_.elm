module Pages.Home_ exposing (Model, Msg, page)

import Api.Data exposing (Data)
import Api.Log
import Api.User
import Components.Footer
import Components.Table
import Effect exposing (Effect)
import Element exposing (..)
import Element.Border
import Element.Font
import Element.Input as Input
import Gen.Params.Home_ exposing (Params)
import Page
import Ports exposing (refreshReceiver)
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared _ =
    Page.protected.advanced
        (\user ->
            { init = init user
            , update = update user
            , view = view shared
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { logs : Data Api.Log.LogList
    , id : String
    , date : String
    }


init : Api.User.User -> ( Model, Effect Msg )
init user =
    ( { logs = Api.Data.Loading
      , id = ""
      , date = ""
      }
    , Effect.fromCmd (fetchLogList user)
    )


fetchLogList :
    Api.User.User
    -> Cmd Msg
fetchLogList user =
    Api.Log.list
        { token = Just user.token
        , onResponse = GotLogs
        }



-- UPDATE


type Msg
    = ClickedSignOut
    | GotLogs (Data Api.Log.LogList)
    | Refresh
    | Updated Field String


type Field
    = IdSearch
    | DateSearch


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

        Updated IdSearch id ->
            ( { model | id = id }
            , Effect.none
            )

        Updated DateSearch date ->
            ( { model | date = date }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    refreshReceiver Refresh



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Homepage"
    , element =
        column
            [ width fill
            , height fill
            ]
            [ row [ width fill ]
                [ row
                    [ width fill
                    , paddingEach
                        { top = 10
                        , right = 300
                        , bottom = 20
                        , left = 5
                        }
                    ]
                    [ text "OFLS - Entrance Management System" ]
                , Input.search [ width <| px 200 ]
                    { onChange = Updated IdSearch
                    , text = model.id
                    , placeholder = Just (Input.placeholder [] (text "Student ID"))
                    , label = Input.labelHidden "Student ID"
                    }
                , Input.search [ width <| px 200 ]
                    { onChange = Updated DateSearch
                    , text = model.date
                    , placeholder = Just (Input.placeholder [] (text "Date"))
                    , label = Input.labelHidden "Date"
                    }
                , case shared.user of
                    Just _ ->
                        logoutButton

                    Nothing ->
                        Element.none
                ]
            , row
                [ width fill
                , height fill
                , paddingXY 5 5
                ]
                [ column
                    [ width <| fillPortion 5
                    , alignTop
                    ]
                    [ case model.logs of
                        Api.Data.Success logs ->
                            Components.Table.view (logs |> filterWithId model.id |> filterWithDate model.date)

                        Api.Data.Refresh logs ->
                            Components.Table.view (logs |> filterWithId model.id |> filterWithDate model.date)

                        _ ->
                            Element.text "Loading..."
                    ]
                ]
            , Components.Footer.view
            ]
    }



-- internal


filterWithId : String -> Api.Log.LogList -> Api.Log.LogList
filterWithId id =
    let
        helper : Api.Log.Log -> Bool
        helper log =
            if id == "" then
                True

            else
                String.startsWith id log.id
    in
    List.filter helper


filterWithDate : String -> Api.Log.LogList -> Api.Log.LogList
filterWithDate date =
    let
        helper : Api.Log.Log -> Bool
        helper log =
            if date == "" then
                True

            else
                String.endsWith date log.date
    in
    List.filter helper


logoutButton : Element Msg
logoutButton =
    Input.button
        [ Element.Border.rounded 5
        , Element.Border.solid
        , Element.Border.width 2
        , Element.Border.color (Element.rgb255 150 150 150)
        , Element.Font.color (Element.rgb255 150 150 150)
        , Element.Font.size 20
        , Element.Font.center
        , Element.width <| Element.px 250
        , Element.height fill
        ]
        { onPress = Just ClickedSignOut
        , label = text "Sign out"
        }
