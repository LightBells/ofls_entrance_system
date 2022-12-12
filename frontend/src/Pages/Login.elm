module Pages.Login exposing (Model, Msg, page)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.Events as Events
import Components.Footer
import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Login exposing (Params)
import Gen.Route as Route
import Page
import Request
import Shared
import Utils.Route
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared
        , update = update req
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { user : Data User
    , id : String
    , password : String
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( Model
        (case shared.user of
            Just user ->
                Api.Data.Success user

            Nothing ->
                Api.Data.NotAsked
        )
        ""
        ""
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | AttemptedSignIn
    | GotUser (Data User)


type Field
    = ID
    | Password


update : Request.With Params -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        Updated ID id ->
            ( { model | id = id }, Effect.none )

        Updated Password password ->
            ( { model | password = password }, Effect.none )

        AttemptedSignIn ->
            ( model
            , Effect.fromCmd <|
                Api.User.authentication
                    { user =
                        { id = model.id
                        , password = model.password
                        }
                    , onResponse = GotUser
                    }
            )

        GotUser user ->
            case Api.Data.toMaybe user of
                Just user_ ->
                    ( { model | user = user }
                    , Effect.batch
                        [ Effect.fromCmd (Utils.Route.navigate req.key Route.Home_)
                        , Effect.fromShared (Shared.SignedInUser user_)
                        ]
                    )

                Nothing ->
                    ( { model | user = user }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Login"
    , element =
        el
            [ centerX
            , centerY
            ]
        <|
            column []
                [ column
                    [ height fill
                    ]
                    [ column
                        [ Font.color (Element.rgb255 0 0 0)
                        , Font.size 40
                        , Font.center
                        , width fill
                        ]
                        [ el [ centerX ] <| text "OFLS"
                        , el [ centerX ] <| text "Entry Management System"
                        , el [ centerX ] <| text "Login"
                        ]
                    , Input.username
                        [ Events.onEnter AttemptedSignIn
                        ]
                        { text = model.id
                        , onChange = Updated ID
                        , placeholder = Just (Input.placeholder [] (text "ID"))
                        , label = Input.labelHidden "ID"
                        }
                    , Input.currentPassword
                        [ Events.onEnter AttemptedSignIn ]
                        { text = model.password
                        , onChange = Updated Password
                        , placeholder = Just (Input.placeholder [] (text "Password"))
                        , label = Input.labelHidden "Password"
                        , show = False
                        }
                    , loginButton
                    , case model.user of
                        Api.Data.Failure error ->
                            el [ centerX ] <|
                                column []
                                    (List.map (\message -> text message) error)

                        _ ->
                            text ""
                    ]
                , Components.Footer.view
                ]
    }


blue : Color
blue =
    Element.rgb255 100 100 238


white : Color
white =
    Element.rgb255 255 255 255


loginButton : Element Msg
loginButton =
    Input.button
        [ Background.color blue
        , Font.color white
        , Element.focused
            [ Background.color blue ]
        , width fill
        , padding 10
        , Font.center
        ]
        { onPress = Just AttemptedSignIn
        , label = text "Sign In"
        }
