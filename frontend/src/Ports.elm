port module Ports exposing (clearUser, refreshReceiver, saveNameList, saveUser)

import Api.NameList exposing (NameDict)
import Api.User exposing (User)
import Json.Decode as Decode
import Json.Encode as Encode


port outgoing :
    { tag : String
    , data : Decode.Value
    }
    -> Cmd msg


port incoming :
    ({ tag : String
     , data : Encode.Value
     }
     -> msg
    )
    -> Sub msg


saveUser : User -> Cmd msg
saveUser user =
    outgoing
        { tag = "saveUser"
        , data = Api.User.encode user
        }


clearUser : Cmd msg
clearUser =
    outgoing
        { tag = "clearUser"
        , data = Encode.null
        }


refreshReceiver : msg -> Sub msg
refreshReceiver msg =
    incoming
        (\_ ->
            msg
        )


saveNameList : NameDict -> Cmd msg
saveNameList nameList =
    outgoing
        { tag = "saveNameList"
        , data = Api.NameList.encodeJson nameList
        }
