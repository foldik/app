module Page.Register exposing (Model, Msg, init, update, view, subscriptions)

import Api
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http
import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import Forms

import Registration

-- MODEL

type alias Model =
    { registration : Registration.Registration
    , registrationResult : Maybe RegistrationResult
    }

type RegistrationResult
    = Success
    | Failed String

init : (Model, Cmd Msg)
init = 
    (Model Registration.empty Nothing, Cmd.none)

-- UPDATE

type Msg
    = SetUserName String
    | SetEmail String
    | SetFirstName String
    | SetLastName String
    | SubmitRegistration
    | ClearResult
    | GotRegistrationResult (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetUserName userName ->
            ( { model | registration = Registration.setUserName userName model.registration }, Cmd.none )

        SetEmail email ->
            ( { model | registration = Registration.setEmail email model.registration }, Cmd.none )

        SetFirstName firstName ->
            ( { model | registration = Registration.setFirstName firstName model.registration }, Cmd.none )

        SetLastName lastName ->
            ( { model | registration = Registration.setLastName lastName model.registration }, Cmd.none )

        SubmitRegistration ->
            let
                (validatedRegistration, isValid) = Registration.validate model.registration
            in
            if isValid then
                ( { model | registration = validatedRegistration }, Api.register GotRegistrationResult validatedRegistration )
            else
                ( { model | registration = validatedRegistration }, Cmd.none )

        ClearResult -> 
            ( { model | registrationResult = Nothing }, Cmd.none)

        GotRegistrationResult result ->
            case result of
                Ok _ ->
                    ( { model | registrationResult = Just Success }, Cmd.none )
            
                Err _ ->
                    ( { model | registrationResult = Just (Failed "Registration failed.") }, Cmd.none )
            

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
                        [ input [ class "input", type_ "text", value (Forms.getStringValue model.registration.userName), onInput SetUserName, onClick ClearResult, placeholder "Username" ] [] ]
                    , validationMessage model.registration.userName
                    ]
                , div [ class "field" ] 
                    [ legend [ class "label" ] [ text "Email" ] 
                    , div [ class "control" ] 
                        [ input [ class "input", type_ "email", value (Forms.getStringValue model.registration.email), onInput SetEmail, onClick ClearResult, placeholder "Email" ] [] ]
                    , validationMessage model.registration.email
                    ]
                , div [ class "field" ] 
                    [ legend [ class "label" ] [ text "First Name" ] 
                    , div [ class "control" ] 
                        [ input [ class "input", type_ "text", value (Forms.getStringValue model.registration.firstName), onInput SetFirstName, onClick ClearResult, placeholder "First Name" ] [] ]
                    , validationMessage model.registration.firstName
                    ]
                , div [ class "field" ] 
                    [ legend [ class "label" ] [ text "Last Name" ] 
                    , div [ class "control" ] 
                        [ input [ class "input", type_ "text", value (Forms.getStringValue model.registration.lastName), onInput SetLastName, onClick ClearResult, placeholder "Last Name" ] [] ]
                    , validationMessage model.registration.lastName
                    ]
                , div [ class "field" ] 
                    [ div [ class "control" ] 
                        [ button [ class "button is-link", type_ "button", onClick SubmitRegistration ] [ text "Register" ] ]
                    ]
                ]
            , registrationResultView model.registrationResult
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
    

registrationResultView : Maybe RegistrationResult -> Html Msg
registrationResultView maybeRegistrationResult =
    case maybeRegistrationResult of
        Nothing ->
            div [] []
    
        Just result ->
            case result of
                Success ->
                    article [ class "message is-success" ] 
                        [ div [ class "message-body" ] 
                            [ text "Succesfully registered! We've sent an email. You can continue with the registration through the link in that." ]
                        ]
            
                Failed message ->
                    article [ class "message is-danger" ] 
                        [ div [ class "message-body" ] 
                            [ text message ]
                        ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none