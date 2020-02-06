module Main exposing (main)

import Json.Encode as E
import Platform exposing (Program, worker)
import Ports
import Svg2Elm.Generator exposing (compileFunction)


type alias File =
    { name : String
    , code : String
    }


compileAndEncode : File -> E.Value
compileAndEncode { name, code } =
    case compileFunction name code of
        Ok elm ->
            E.object
                [ ( "type", E.string "Ok" )
                , ( "elm", E.string elm )
                ]

        Err err ->
            E.object
                [ ( "type", E.string "Err" )
                , ( "error", E.string err )
                ]


main : Program File () Never
main =
    worker
        { init = \file -> ( (), Ports.compiled <| compileAndEncode file )
        , subscriptions = \_ -> Sub.none
        , update = \_ _ -> ( (), Cmd.none )
        }
