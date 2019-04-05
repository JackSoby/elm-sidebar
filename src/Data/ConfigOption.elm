module Data.ConfigOption exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias ConfigOption =
    { id : Int
    , name : String
    , code : String
    , default : String
    , partNumber : Maybe String
    }


decodeConfigOptionText : Decode.Decoder ConfigOption
decodeConfigOptionText =
    Decode.map5 ConfigOption
        (field "id" Decode.int)
        (field "name" Decode.string)
        (field "code" Decode.string)
        (field "default" Decode.string)
        (field "partNumber" (nullable Decode.string))


configOptionDecoder : Decode.Decoder (List ConfigOption)
configOptionDecoder =
    Decode.list decodeConfigOptionText
