module Data.Condition exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias Condition =
    { key : String
    , value : String
    , operator : String
    , id : Int
    }


conditionDecoder : Decode.Decoder (List Condition)
conditionDecoder =
    Decode.list decodeConditionText


decodeConditionText : Decode.Decoder Condition
decodeConditionText =
    Decode.map4 Condition
        (field "key" Decode.string)
        (field "value" Decode.string)
        (field "operator" Decode.string)
        (field "id" Decode.int)
