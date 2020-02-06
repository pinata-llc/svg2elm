port module Ports exposing (compiled)

import Json.Encode exposing (Value)


port compiled : Value -> Cmd msg
