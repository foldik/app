module Page.Course exposing (Model, Msg, init, update, view, subscriptions)

import Browser.Navigation as Nav

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http
import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import User
import Session

-- MODEL

type alias Model =
    { session : Session.Session
    , id : Int
    }

init : Session.Session -> Int -> (Model, Cmd Msg)
init session id = 
    (Model session id, Cmd.none)

-- UPDATE

type Msg
    = Msg Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Msg id ->
            ( { model | id = id }, Cmd.none )

-- VIEW

view : Model -> Html Msg
view model =
    div [ class "columns" ]
        [ text (String.fromInt model.id) ]


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


