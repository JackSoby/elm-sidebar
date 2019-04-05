module Data.Configuration exposing (Configuration, configurationDecoder, decodeConfigruationText)

import Data.ConfigOption as ConfigOption exposing (..)
import Json.Decode as Decode exposing (Decoder, field, int, maybe, nullable, string)


type alias Configuration =
    { id : Int
    , name : String
    , key : String

    -- , configOptions : List ConfigOption
    }


configurationDecoder : Decode.Decoder (List Configuration)
configurationDecoder =
    Decode.list decodeConfigruationText


decodeConfigruationText : Decode.Decoder Configuration
decodeConfigruationText =
    Decode.map3 Configuration
        (field "id" Decode.int)
        (field "name" Decode.string)
        (field "key" Decode.string)



-- (field "configOptions" configOptionDecoder)
