module Page.Logout exposing (Model, Msg(..), init, update, view, subscriptions)

import Api
import Browser.Navigation as Nav

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http

import Session

-- MODEL

type alias Model =
    { session : Session.Session
    , message : String
    }

init : Session.Session -> (Model, Cmd Msg)
init session =
    (Model session "", Api.logout LoggedOut)

-- UPDATE

type Msg
    = LoggedOut (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LoggedOut result ->
            case result of
                Ok _ ->
                   ( model, Nav.pushUrl (Session.getNavKey model.session) "reload-session" ) 
            
                Err _ ->
                    ( { model | message = "Couldn't log out."}, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div [] [ text model.message ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none