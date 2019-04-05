module Data.PriceRule exposing (PriceRule, decodePriceRuleText, priceRuleDecoder)

import Data.PriceCondition as PriceCondition exposing (..)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias PriceRule =
    { id : Int
    , productVersionId : Int
    , priceConditions : List PriceCondition
    }


priceRuleDecoder : Decode.Decoder (List PriceRule)
priceRuleDecoder =
    Decode.list decodePriceRuleText


decodePriceRuleText : Decode.Decoder PriceRule
decodePriceRuleText =
    Decode.map3 PriceRule
        (field "id" Decode.int)
        (field "productVersionId" Decode.int)
        (field "priceConditions" priceConditionDecoder)
