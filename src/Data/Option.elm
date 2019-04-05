module Data.Option exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias Option =
    { id : Int
    , name : String
    , code : String
    }


decodeOptionText : Decode.Decoder Option
decodeOptionText =
    Decode.map3 Option
        (field "id" Decode.int)
        (field "name" Decode.string)
        (field "code" Decode.string)


optionDecoder : Decode.Decoder (List Option)
optionDecoder =
    Decode.list decodeOptionText
