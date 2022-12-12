module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Api.User exposing (User)
import Element exposing (..)
import Json.Decode as Json
import Ports
import Request exposing (Request)
import View exposing (View)


type alias Flags =
    Json.Value


type alias Model =
    { user : Maybe User }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ flags =
    let
        user =
            flags
                |> Json.decodeValue (Json.field "user" Api.User.decoder)
                |> Result.toMaybe
    in
    ( Model user
    , Cmd.none
    )


type Msg
    = ClickedSignOut
    | SignedInUser User


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        SignedInUser user ->
            ( { model | user = Just user }
            , Ports.saveUser user
            )

        ClickedSignOut ->
            ( { model | user = Nothing }
            , Ports.clearUser
            )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


view :
    Request
    ->
        { page : View msg
        , toMsg : Msg -> msg
        }
    -> Model
    -> View msg
view req { page, toMsg } model =
    { title =
        if String.isEmpty page.title then
            "Log Manager for the Office for learning Support"

        else
            page.title ++ " | OFLS Log Manager"
    , element =
        row
            []
            [ column
                [ width fill ]
                [ page.element ]
            ]
    }
