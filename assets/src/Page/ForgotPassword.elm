module Page.ForgotPassword exposing (Model, Msg, init, update, view, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http
import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import Forms

-- MODEL

type alias Model =
    { userName : Forms.Value String
    , result : Maybe SubmitResult
    }

type SubmitResult
    = Success
    | Failed String

init : (Model, Cmd Msg)
init = 
    (Model Forms.emptyString Nothing, Cmd.none)


-- UPDATE

type Msg
    = SetUserName String
    | SubmitForm
    | GotResponse (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetUserName userName ->
            ( { model | userName = Forms.FormValue userName }, Cmd.none )

        SubmitForm ->
            let
                validatedUserName = Forms.validateNotEmptyString "Please give me your user name." model.userName
            in
            if Forms.valid validatedUserName then
                ( model, submitForgotPassword model )
            else
                ( { model | userName = validatedUserName }, Cmd.none)

        GotResponse result ->
            case result of
                Ok _ ->
                    ( { model | userName = Forms.emptyString, result = Just Success }, Cmd.none )
            
                Err _ ->
                     ( { model | userName = Forms.emptyString, result = Just (Failed ("Doesn't exist user with '" ++ (Forms.getStringValue model.userName) ++ "' user name.")) }, Cmd.none )


-- API

submitForgotPassword : Model -> Cmd Msg
submitForgotPassword model =
    Http.post
        { url = "/api/forgotpassword"
        , body = Http.jsonBody (userNameEncoder model)
        , expect = Http.expectString GotResponse
        }

userNameEncoder : Model -> Encode.Value
userNameEncoder model =
    Encode.object
        [ ("username", Encode.string (Forms.getStringValue model.userName))
        ]

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
                        [ input [ class "input", type_ "text", value (Forms.getStringValue model.userName), onInput SetUserName, placeholder "Username" ] [] ]
                    , validationMessage model.userName
                    ]
                , div [ class "field" ] 
                    [ div [ class "control" ] 
                        [ button [ class "button is-link", type_ "button", onClick SubmitForm ] [ text "Send mail" ] ]
                    ]
                ]
            , formSubmitResultView model
            ]
        , div [ class "column" ] []
        ]

validationMessage : Forms.Value String -> Html Msg
validationMessage formValue =
    case formValue of
        Forms.FormValue _ ->
            span [] []
    
        Forms.InvalidFormValue message _ ->
            p [ class "help is-danger" ] [ text message ]
    
formSubmitResultView : Model -> Html Msg
formSubmitResultView model =
    case model.result of
        Nothing ->
            span [] []
    
        Just Success ->
            article [ class "message is-success" ] 
                [ div [ class "message-body" ] 
                    [ text "We sent a mail to you. You can set your new password through the link in that." ]
                ]

        Just (Failed message) ->
            article [ class "message is-danger" ] 
                [ div [ class "message-body" ] 
                    [ text message ]
                ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none