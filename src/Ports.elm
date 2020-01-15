port module Ports exposing (..)


port readFiles : List String -> Cmd msg


port filesRead : (List ( String, String ) -> msg) -> Sub msg


port print : String -> Cmd msg


port printAndExitFailure : String -> Cmd msg


port printAndExitSuccess : String -> Cmd msg
