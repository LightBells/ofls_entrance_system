module Api.Endpoint exposing
    ( Endpoint
    , downloadCSV
    , listLog
    , login
    )


type alias Endpoint =
    String


login : Endpoint
login =
    "http://localhost:8080/v1/login"


listLog : Endpoint
listLog =
    "http://localhost:8080/v1/logs/"


downloadCSV : Endpoint
downloadCSV =
    "http://localhost:8080/v1/logs/monthly/csv/"
