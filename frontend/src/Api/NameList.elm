module Api.NameList exposing
    ( NameDict
    , decodeJson
    , encodeJson
    , parseCsv
    )

import Csv.Decode as Decode
import Dict exposing (Dict)
import File exposing (File(..))
import Json.Decode as JsonDecode
import Json.Encode as Encode


type alias NameDict =
    Dict String String


type alias Field =
    { id : String
    , name : String
    }


fromList : List Field -> NameDict
fromList =
    List.foldl (\field -> Dict.insert field.id field.name) Dict.empty


decoder : Decode.Decoder Field
decoder =
    Decode.map2 Field
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)


parseCsv : String -> Result Decode.Error NameDict
parseCsv csv =
    convertToDict <|
        Decode.decodeCustom { fieldSeparator = ':' } (Decode.CustomFieldNames [ "id", "name" ]) decoder csv


convertToDict : Result Decode.Error (List Field) -> Result Decode.Error NameDict
convertToDict =
    Result.map fromList


encodeJson : NameDict -> Encode.Value
encodeJson dict =
    Encode.dict identity Encode.string dict


decodeJson : JsonDecode.Decoder NameDict
decodeJson =
    JsonDecode.dict JsonDecode.string
