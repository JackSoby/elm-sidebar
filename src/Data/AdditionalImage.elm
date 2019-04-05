module Data.AdditionalImage exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias AdditionalImage =
    { 
     thumbnail : String
    , fullImage : String
    }


decodeImageText : Decode.Decoder AdditionalImage
decodeImageText =
    Decode.map2 AdditionalImage
        (field "thumbnail" Decode.string)
        (field "full_image" Decode.string)


imageDecoder : Decode.Decoder (List AdditionalImage)
imageDecoder =
    Decode.list decodeImageText
