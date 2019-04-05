module Data.ProductFilter exposing (..)

import Data.Option as Option exposing (..)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias ProductFilter =
    { id : Int
    , name : Maybe String
    , key : String
    , options : List Option
    }


productFilterDecoder : Decode.Decoder (List ProductFilter)
productFilterDecoder =
    Decode.list decodeProductFilterText


decodeProductFilterText : Decode.Decoder ProductFilter
decodeProductFilterText =
    Decode.map4 ProductFilter
        (field "id" Decode.int)
        (field "name" (nullable Decode.string))
        (field "key" Decode.string)
        (field "options" optionDecoder)
