module Data.ProductSummary exposing (ProductSummary, decodeProductList, decodeProductSummaryText, jsonProductsDecoder)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias ProductSummary =
    { id : Int
    , name : Maybe String
    , code : String
    , productFilterValues : Dict String (List String)
    }


jsonProductsDecoder : Decode.Decoder (List ProductSummary)
jsonProductsDecoder =
    Decode.field "data" decodeProductList


decodeProductList : Decode.Decoder (List ProductSummary)
decodeProductList =
    Decode.list decodeProductSummaryText


decodeProductSummaryText : Decode.Decoder ProductSummary
decodeProductSummaryText =
    Decode.map4 ProductSummary
        (field "id" Decode.int)
        (field "name" (nullable Decode.string))
        (field "code" Decode.string)
        (field "productFilterValues" (Decode.dict (Decode.list Decode.string)))
