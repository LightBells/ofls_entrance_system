module Api.User exposing
    ( User
    , authentication
    , decoder
    , encode
    )

import Api.Data exposing (Data)
import Api.Endpoint
import Api.Token exposing (Token)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias User =
    { token : Token
    , refreshToken : Token
    }


decoder : Decode.Decoder User
decoder =
    Decode.map2 User
        (Decode.field "token" Api.Token.decoder)
        (Decode.field "refresh_token" Api.Token.decoder)


encode : User -> Encode.Value
encode user =
    Encode.object
        [ ( "token", Api.Token.encode user.token )
        , ( "refresh_token", Api.Token.encode user.refreshToken )
        ]


authentication :
    { user : { user | id : String, password : String }
    , onResponse : Data User -> msg
    }
    -> Cmd msg
authentication { user, onResponse } =
    let
        body : Decode.Value
        body =
            Encode.object
                [ ( "user"
                  , Encode.object
                        [ ( "id", Encode.string user.id )
                        , ( "password", Encode.string user.password )
                        ]
                  )
                ]
    in
    Http.post
        { url = Api.Endpoint.login
        , body = Http.jsonBody body
        , expect = Api.Data.expectJson onResponse decoder
        }
