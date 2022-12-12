module Api.Endpoint exposing
    ( Endpoint
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
