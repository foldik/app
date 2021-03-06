module Page.Mentors exposing (Model, Msg, init, update, view, subscriptions)

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
    , value : String
    }

init : Session.Session -> (Model, Cmd Msg)
init session = 
    (Model session "Hello Mentors!", Cmd.none)

-- UPDATE

type Msg
    = Msg String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Msg value ->
            ( { model | value = value }, Cmd.none )

-- VIEW

view : Model -> Html Msg
view model =
    div [ class "columns" ]
        [ text model.value ]


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


