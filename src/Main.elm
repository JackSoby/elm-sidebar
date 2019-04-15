port module Main exposing (Model, Msg(..), getCategory, init, main, update, view)

import Browser
import Data.Category as Category exposing (..)
import Data.Configuration as Configuration exposing (..)
import Data.ParentCategory as ParentCategory exposing (..)
import Data.PriceCondition as PriceCondition exposing (..)
import Data.PriceRule as PriceRule exposing (..)
import Data.ProductSummary as ProductSummary exposing (..)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html5.DragDrop as DragDrop
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import List.Extra as ListExtra
import Set
import String.Extra as StringExtra


type DropTarget
    = OnCategory ParentCategory
    | BelowCategories



---- MODEL ----


type alias Model =
    { categories : List ParentCategory
    , selectedCategoryId : Maybe Int
    , subCategories : List Category
    , selectedSubCategoryId : Maybe Int
    , priceRules : List PriceRule
    , configurations : List Configuration
    , selectedProductId : Maybe Int
    , dragDrop : DragDrop.Model ParentCategory DropTarget
    , mappedConfigurations : Dict.Dict String String
    }


type alias ConfigurationPrice =
    { priceRules : List PriceRule
    , configurations : List Configuration
    }


init : ( Model, Cmd Msg )
init =
    ( { categories = []
      , subCategories = []
      , selectedCategoryId = Nothing
      , configurations = []
      , priceRules = []
      , selectedProductId = Nothing
      , selectedSubCategoryId = Nothing
      , dragDrop = DragDrop.init
      , mappedConfigurations = Dict.empty
      }
    , getCategory
    )


getCategory : Cmd Msg
getCategory =
    Http.get
        { url = "https://beswick-product-manager-dev.bowst.com/api/categories"
        , expect = Http.expectJson GetCategories parentJsonDecoder
        }


getSubCategories : String -> Cmd Msg
getSubCategories name =
    Http.get
        { url = "https://beswick-product-manager-dev.bowst.com/api/categories/by-category-code?code=" ++ slugifyName name
        , expect = Http.expectJson GetSubCategories jsonDecoder
        }


getProductConfigurationsAndPriceRules : Int -> Cmd Msg
getProductConfigurationsAndPriceRules id =
    Http.get
        { url = "https://beswick-product-manager-dev.bowst.com/api/configurations/by-product-id?id=" ++ String.fromInt id
        , expect = Http.expectJson GetConfigurationsAndPriceRules decodeProductConfigurationValues
        }


decodeProductConfigurationValues : Decode.Decoder ConfigurationPrice
decodeProductConfigurationValues =
    Decode.map2 ConfigurationPrice
        (field "priceRules" (Decode.list decodePriceRuleText))
        (field "configurations" (Decode.list decodeConfigruationText))


slugifyName : String -> String
slugifyName name =
    String.replace " " "-" (String.replace "," "" name)
        |> String.toLower


reorderCategories : ParentCategory -> DropTarget -> List ParentCategory -> List ParentCategory
reorderCategories activeProject dropTarget projects =
    let
        baseList =
            projects
                |> List.filter ((/=) activeProject)

        result =
            case dropTarget of
                OnCategory targetProject ->
                    baseList
                        |> ListExtra.splitWhen ((==) targetProject)

                BelowCategories ->
                    Just ( baseList, [] )
    in
    case result of
        Just ( start, end ) ->
            start ++ [ activeProject ] ++ end

        Nothing ->
            projects



---- UPDATE ----


type Msg
    = GetCategories (Result Http.Error (List ParentCategory))
    | UpdateCategoryId ParentCategory
    | UpdateSubCategoryId Int
    | GetSubCategories (Result Http.Error (List Category))
    | GetConfigurationsAndPriceRules (Result Http.Error ConfigurationPrice)
    | FetchConfigurations Int
    | DragDropMsg (DragDrop.Msg ParentCategory DropTarget)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DragDropMsg reorderMsg ->
            let
                ( nextDragDropModel, result ) =
                    DragDrop.update reorderMsg model.dragDrop

                nextModel =
                    { model
                        | dragDrop = nextDragDropModel
                        , categories =
                            case result of
                                Nothing ->
                                    model.categories

                                Just ( draggedCategory, targetCategory, position ) ->
                                    reorderCategories draggedCategory targetCategory model.categories
                    }
            in
            ( nextModel, Cmd.none )

        GetCategories result ->
            case result of
                Ok cats ->
                    ( { model | categories = cats }, Cmd.none )

                Err err ->
                    let
                        log =
                            Debug.log "err" err
                    in
                    ( model, Cmd.none )

        UpdateCategoryId cat ->
            ( { model | selectedCategoryId = Just cat.id, subCategories = [] }, getSubCategories cat.name )

        GetSubCategories result ->
            case result of
                Ok cats ->
                    ( { model | subCategories = cats }, Cmd.none )

                Err err ->
                    let
                        log =
                            Debug.log "err" err
                    in
                    ( model, Cmd.none )

        UpdateSubCategoryId id ->
            ( { model | selectedSubCategoryId = Just id }, Cmd.none )

        FetchConfigurations id ->
            ( { model | selectedProductId = Just id, configurations = [] }, getProductConfigurationsAndPriceRules id )

        GetConfigurationsAndPriceRules result ->
            case result of
                Ok val ->
                    let
                        mappedConfigs =
                            val.configurations
                                |> List.foldr (\config acc -> Dict.union acc (Dict.singleton config.key config.name)) Dict.empty
                    in
                    ( { model | priceRules = val.priceRules, mappedConfigurations = mappedConfigs, configurations = val.configurations }, Cmd.none )

                _ ->
                    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        dragCategory =
            DragDrop.getDragId model.dragDrop

        dropTarget =
            DragDrop.getDropId model.dragDrop
    in
    div []
        [ div
            [ class "panel has-background-white reorderable"
            , classList [ ( "is-reordering", dragCategory /= Nothing ) ]
            ]
            (List.map (categoryView model dragCategory dropTarget) model.categories
                ++ [ belowProject dropTarget ]
            )
        ]


belowProject : Maybe DropTarget -> Html Msg
belowProject dropTarget =
    let
        attrs =
            [ class "reorderable--item has-background-light"
            , classList [ ( "targeted", dropTarget == Just BelowCategories ) ]
            , style "height" "84px"
            ]
                ++ DragDrop.droppable DragDropMsg BelowCategories
    in
    div attrs [ div [ class "drop-target has-background-light" ] [] ]


categoryView : Model -> Maybe ParentCategory -> Maybe DropTarget -> ParentCategory -> Html Msg
categoryView model dragCategory dropTarget category =
    let
        attrs =
            [ class "reorderable--item"
            , classList
                [ ( "targeted", dropTarget == Just (OnCategory category) )
                , ( "is-active", dragCategory == Just category )
                ]
            ]
                ++ DragDrop.draggable DragDropMsg category
                ++ DragDrop.droppable DragDropMsg (OnCategory category)
    in
    div attrs
        [ div [ class "drop-target has-background-light" ] []
        , div [ class "panel-block" ]
            [ span [ class "panel-icon" ]
                [ i [ attribute "aria-hidden" "true", class "fas fa-bars" ]
                    []
                ]
            , span []
                [ displayParentCategory model category
                ]
            ]
        ]


displayParentCategory : Model -> ParentCategory -> Html Msg
displayParentCategory model category =
    case category.id == (model.selectedCategoryId |> Maybe.withDefault 0) of
        True ->
            let
                subCategories =
                    model.subCategories
                        |> List.map
                            (\subCat ->
                                displaySubCategory model subCat
                            )
            in
            div [ class "alert alert-info" ]
                [ text category.name
                , div
                    [ class "alert alert-dark" ]
                    subCategories
                ]

        False ->
            div [ class "alert alert-info", onClick (UpdateCategoryId category) ] [ text category.name ]


displaySubCategory : Model -> Category -> Html Msg
displaySubCategory model category =
    case (model.selectedSubCategoryId |> Maybe.withDefault 0) == category.id of
        True ->
            let
                products =
                    category.products
                        |> List.map
                            (\prod ->
                                displayProductInfo model prod
                            )
            in
            div []
                [ text category.name
                , div [ class "alert alert-light" ] products
                ]

        False ->
            div [ onClick (UpdateSubCategoryId category.id) ] [ text category.name ]


displayProductInfo : Model -> ProductSummary -> Html Msg
displayProductInfo model product =
    case (model.selectedProductId |> Maybe.withDefault 0) == product.id of
        True ->
            let
                configs =
                    model.configurations
                        |> List.map
                            (\config ->
                                div [] [ text config.name ]
                            )

                rules =
                    model.priceRules
                        |> List.map
                            (\rule ->
                                let
                                    conditions =
                                        rule.priceConditions
                                            |> List.foldr
                                                (\con acc ->
                                                    case Dict.get con.key model.mappedConfigurations of
                                                        Just val ->
                                                            case acc == "" of
                                                                True ->
                                                                    acc ++ val

                                                                _ ->
                                                                    acc ++ ", " ++ val

                                                        Nothing ->
                                                            acc
                                                )
                                                ""
                                in
                                div [] [ text conditions ]
                            )
            in
            div [ onClick (FetchConfigurations product.id) ]
                [ text (product.name |> Maybe.withDefault "")
                , div [ class "alert alert-primary" ] ([ h3 [] [ text "Configurations" ] ] ++ configs)
                , div [ class "alert alert-secondary" ] ([ h3 [] [ text "Price Rules" ] ] ++ rules)
                ]

        False ->
            div [ onClick (FetchConfigurations product.id) ] [ text (product.name |> Maybe.withDefault "") ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
