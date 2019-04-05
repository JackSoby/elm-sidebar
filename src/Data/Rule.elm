module Data.Rule exposing (..)

import Data.Condition as Condition exposing (..)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias Rule =
    { errorType : String
    , message : Maybe String
    , id : Int
    , conditions : List Condition
    }


ruleDecoder : Decode.Decoder (List Rule)
ruleDecoder =
    Decode.list decodeRuleText


decodeRuleText : Decode.Decoder Rule
decodeRuleText =
    Decode.map4 Rule
        (field "errorType" Decode.string)
        (field "message" (nullable Decode.string))
        (field "id" Decode.int)
        (field "conditions" conditionDecoder)
