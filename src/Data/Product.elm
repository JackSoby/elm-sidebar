module Data.Product exposing (..)

import Data.AdditionalImage as AdditionalImage exposing (..)
import Data.Configuration as Configuration exposing (..)
import Data.Rule as Rule exposing (..)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)


type alias Product =
    { id : Int
    , name : Maybe String
    , code : String
    , imageUrl : String
    , productFilterValues : Dict String (List String)
    , rules : List Rule
    , additionalImages : List AdditionalImage
    , partNumberTemplate : String
    , configurations : List Configuration
    , description : String
    , seals : List String
    , materials : List String
    }


jsonProductDecoder : Decode.Decoder Product
jsonProductDecoder =
    Decode.field "data" decodeProductText


decodeProductText : Decode.Decoder Product
decodeProductText =
    decode Product
        |> Json.Decode.Pipeline.required "id" Decode.int
        |> Json.Decode.Pipeline.required "name" (nullable Decode.string)
        |> Json.Decode.Pipeline.required "code" Decode.string
        |> Json.Decode.Pipeline.required "imageUrl" Decode.string
        |> Json.Decode.Pipeline.required "productFilterValues" (Decode.dict (Decode.list Decode.string))
        |> Json.Decode.Pipeline.required "rules" ruleDecoder
        |> Json.Decode.Pipeline.required "additionalImages" imageDecoder
        |> Json.Decode.Pipeline.required "partNumberTemplate" Decode.string
        |> Json.Decode.Pipeline.required "configurations" configurationDecoder
        |> Json.Decode.Pipeline.required "description" Decode.string
        |> Json.Decode.Pipeline.required "seals" (Decode.list Decode.string)
        |> Json.Decode.Pipeline.required "materials" (Decode.list Decode.string)
