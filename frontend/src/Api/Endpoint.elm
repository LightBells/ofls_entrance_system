module Api.Endpoint exposing
    ( Endpoint
    , downloadCSV
    , listLog
    , login
    )


type alias Endpoint =
    String


baseUrl : String
baseUrl =
    "http://localhost:8080/v1/"


login : Endpoint
login =
    baseUrl ++ "login"


listLog : Endpoint
listLog =
    baseUrl ++ "logs/"


downloadCSV : Endpoint
downloadCSV =
    baseUrl ++ "logs/monthly/csv/"
