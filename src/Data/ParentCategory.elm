module Data.ParentCategory exposing (..)

import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias ParentCategory =
    { id : Int
    , name : String
    , imageUrl : String
    }


parentJsonDecoder : Decode.Decoder (List ParentCategory)
parentJsonDecoder =
    Decode.field "data" decodeParentCategoryList


decodeParentCategoryList : Decode.Decoder (List ParentCategory)
decodeParentCategoryList =
    Decode.list decodeParentCategoryText


decodeParentCategoryText : Decode.Decoder ParentCategory
decodeParentCategoryText =
    Decode.map3 ParentCategory
        (field "id" Decode.int)
        (field "name" Decode.string)
        (field "imageUrl" Decode.string)
