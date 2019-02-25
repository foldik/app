module PaginatedList exposing (PaginatedList, Msg(..), view, update, decoder)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)

-- MODEL

type alias PaginatedList a =
    { page : Int
    , limit : Int
    , max : Int
    , data : List a 
    }


-- DECODER

decoder : Decoder a -> Decoder (PaginatedList a)
decoder listDecoder =
    map4 PaginatedList
        (field "page" int)
        (field "limit" int)
        (field "max" int)
        (field "data" (list listDecoder))

-- UPDATE

type Msg
    = NoOP

update : Int -> PaginatedList a -> PaginatedList a
update nextPage paginatedList =
    if nextPage < 1 then
        paginatedList
    else if nextPage > paginatedList.max then
        paginatedList
    else
        { paginatedList | page = nextPage } 

toPageUrl : String -> String -> String -> String -> String
toPageUrl baseUrl remainingPart page limit =
    "/" ++ baseUrl ++ "?page=" ++ page ++ "&limit=" ++ limit ++ remainingPart

-- VIEW

view : String -> String -> PaginatedList a -> Html Msg
view baseUrl remainingPart paginatedList =
    if paginatedList.max < 2 then
        span [] []
    else 
        let
            previousButton = 
                if [paginatedList.page == 1, paginatedList.max == 0] |> List.any (\n -> n == True) then
                    button [ class "pagination-previous button", disabled True ] 
                        [ text "Previous"]
                else 
                    a [ href ( toPageUrl baseUrl remainingPart (String.fromInt (paginatedList.page - 1)) (String.fromInt paginatedList.limit) ), class "pagination-previous button"] 
                        [ text "Previous"]

            nextButton = 
                if paginatedList.page == paginatedList.max then
                    button [ class "pagination-next button", disabled True ]
                        [ text "Next page" ]
                else 
                    a [ href ( toPageUrl baseUrl remainingPart (String.fromInt (paginatedList.page + 1)) (String.fromInt paginatedList.limit) ), class "pagination-next button" ]
                        [ text "Next page" ]

            pageButtons = pageButtonsView baseUrl remainingPart paginatedList

        in
        nav [ class "pagination is-centered has-padding-bottom-20 has-padding-top-20"
            , attribute "role" "navigation"
            , attribute "aria-label" "pagination" 
            ] 
            [ previousButton
            , nextButton
            , pageButtons
            ]

pageButtonsView : String -> String -> PaginatedList a -> Html Msg
pageButtonsView baseUrl remainingPart paginatedList =
    ul [ class "pagination-list" ]
        (
            pageButtonsList paginatedList
            |> List.map (\n -> pageButtonView baseUrl remainingPart n paginatedList)
        )

pageButtonsList : PaginatedList a -> List String
pageButtonsList paginatedList =
    if paginatedList.max < 1  then
        []
    else if paginatedList.max <= 5 then
        List.range 1 paginatedList.max
        |> List.map (\n -> String.fromInt n)
    else if paginatedList.page < 4 then
        ["1", "2", "3", "4", "DOTS", String.fromInt paginatedList.max]
    else if paginatedList.page > (paginatedList.max - 3) then
        ["1", "DOTS", String.fromInt (paginatedList.max - 3), String.fromInt (paginatedList.max - 2), String.fromInt (paginatedList.max - 1), String.fromInt paginatedList.max]
    else 
        ["1", "DOTS", String.fromInt (paginatedList.page - 1), String.fromInt paginatedList.page, String.fromInt (paginatedList.page + 1), "DOTS", String.fromInt paginatedList.max]


pageButtonView : String -> String -> String -> PaginatedList a -> Html Msg
pageButtonView baseUrl remainingPart pageString paginatedList =
    case pageString of
        "DOTS" ->
            li [] 
                [ span [ class "pagination-ellipsis"] 
                    [ text "..." ]
                ]
    
        _ ->
            li [] 
                [ a [ href ( toPageUrl baseUrl remainingPart pageString (String.fromInt paginatedList.limit) )
                        , classList [("pagination-link button", True), ("is-current", (pageString == (String.fromInt paginatedList.page) ))]
                        , attribute "aria-label" ("Goto page " ++ pageString)
                        ] 
                    [ text pageString ]
                ]
