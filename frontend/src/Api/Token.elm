module Api.Token exposing
    ( Token
    , decoder
    , delete
    , encode
    , get
    , post
    , put
    , toString
    )

import Http
import Json.Decode as Decode
import Json.Encode as Encode


type Token
    = Token String


decoder : Decode.Decoder Token
decoder =
    Decode.map Token Decode.string


encode : Token -> Encode.Value
encode (Token token) =
    Encode.string token



-- HTTP Helpers


get :
    Maybe Token
    ->
        { url : String
        , expect : Http.Expect msg
        }
    -> Cmd msg
get =
    request "GET" Http.emptyBody


delete :
    Maybe Token
    ->
        { url : String
        , expect : Http.Expect msg
        }
    -> Cmd msg
delete =
    request "DELETE" Http.emptyBody


post :
    Maybe Token
    ->
        { url : String
        , body : Http.Body
        , expect : Http.Expect msg
        }
    -> Cmd msg
post token options =
    request "POST" options.body token options


put :
    Maybe Token
    ->
        { url : String
        , body : Http.Body
        , expect : Http.Expect msg
        }
    -> Cmd msg
put token options =
    request "PUT" options.body token options


request :
    String
    -> Http.Body
    -> Maybe Token
    ->
        { options
            | url : String
            , expect : Http.Expect msg
        }
    -> Cmd msg
request method body maybeToken options =
    Http.request
        { method = method
        , headers =
            case maybeToken of
                Just (Token token) ->
                    [ Http.header "Authorization" ("Bearer " ++ token) ]

                Nothing ->
                    []
        , body = body
        , url = options.url
        , expect = options.expect
        , timeout = Just (1000 * 60)
        , tracker = Nothing
        }


toString : Token -> String
toString (Token token) =
    token
