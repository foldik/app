module Page.Login exposing (Model, Msg(..), init, update, view, subscriptions)

import Api
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
    , userName : String
    , password : String
    , hasFailedLogin : Bool
    }

init : Session.Session -> (Model, Cmd Msg)
init session = 
    (Model session "" "" False, Cmd.none)

-- UPDATE

type Msg
    = SetUserName String
    | SetPassword String
    | SubmitLogin
    | ClearResult
    | GotSession (Result Http.Error User.User)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetUserName userName ->
            ( { model | userName = userName }, Cmd.none)

        SetPassword password ->
            ( { model | password = password }, Cmd.none)

        SubmitLogin ->
            ( { model | userName = "", password = "" }, Api.login GotSession model.userName model.password)

        ClearResult ->
            ( { model | hasFailedLogin = False }, Cmd.none)

        GotSession result ->
            case result of
                Ok _ ->
                   ( model, Nav.pushUrl (Session.getNavKey model.session) "reload-session" ) 
            
                Err _ ->
                    ( { model | hasFailedLogin = True }, Cmd.none )
                    

-- VIEW

view : Model -> Html Msg
view model =
    div [ class "columns is-desktop" ]
        [ div [ class "column" ] []
        , div [ class "column" ] 
            [ Html.form [ class "has-padding-bottom-20" ]
                [ div [ class "field" ] 
                    [ legend [ class "label" ] [ text "Username" ]
                    , div [ class "control" ] 
                        [ input [ class "input", type_ "text", value model.userName, onInput SetUserName, onClick ClearResult, placeholder "Username" ] [] ]
                    ]
                , div [ class "field" ] 
                    [ legend [ class "label" ] [ text "Password" ] 
                    , div [ class "control" ] 
                        [ input [ class "input", type_ "password", value model.password, onInput SetPassword, onClick ClearResult, placeholder "Password" ] [] ]
                    ]
                , div [ class "field" ]
                    [ label [ class "label" ] 
                        [ a [ class "has-text-right has-padding-right-30", href "/register" ] [ text "Sign Up" ]
                        , a [ href "/forgot-password" ] [ text "Forgot password" ] 
                        ]
                    ] 
                , div [ class "field" ] 
                    [ div [ class "control" ] 
                        [ button [ class "button is-link", type_ "button", onClick SubmitLogin ] [ text "Login" ] ]
                    ]
                ]
            , failedLoginMessage model.hasFailedLogin
            ]
        , div [ class "column" ] []
        ]
    

failedLoginMessage : Bool -> Html Msg
failedLoginMessage hasFailedLogin =
    case hasFailedLogin of
        True ->
            article [ class "message is-danger" ] 
                [ div [ class "message-body" ]
                    [ text "Bad username or password." ]
                ]
    
        False ->
            div [] []

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none