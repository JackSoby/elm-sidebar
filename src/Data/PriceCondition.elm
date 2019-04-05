module Data.PriceCondition exposing (PriceCondition, decodePriceConditionText, priceConditionDecoder)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias PriceCondition =
    { key : String
    , value : String
    , priceRuleId : Int
    , id : Int
    }


priceConditionDecoder : Decode.Decoder (List PriceCondition)
priceConditionDecoder =
    Decode.list decodePriceConditionText


decodePriceConditionText : Decode.Decoder PriceCondition
decodePriceConditionText =
    Decode.map4 PriceCondition
        (field "key" Decode.string)
        (field "value" Decode.string)
        (field "priceRuleId" Decode.int)
        (field "id" Decode.int)
