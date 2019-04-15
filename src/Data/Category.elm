module Data.Category exposing (Category, decodeCategoryList, decodeCategoryText, jsonDecoder)

import Data.Product as Product exposing (..)
import Data.ProductFilter as ProductFilter exposing (..)
import Data.ProductSummary as ProductSummary exposing (..)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias Category =
    { id : Int
    , name : String
    , imageUrl : String
    , parentId : Maybe Int
    , productFilters : List ProductFilter
    , products : List ProductSummary
    }


jsonDecoder : Decode.Decoder (List Category)
jsonDecoder =
    Decode.field "data" decodeCategoryList


decodeCategoryList : Decode.Decoder (List Category)
decodeCategoryList =
    Decode.list decodeCategoryText


decodeCategoryText : Decode.Decoder Category
decodeCategoryText =
    Decode.map6 Category
        (field "id" Decode.int)
        (field "name" Decode.string)
        (field "imageUrl" Decode.string)
        (field "parentId" (nullable Decode.int))
        (field "productFilters" productFilterDecoder)
        (field "products" decodeProductList)
