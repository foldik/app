module Page.VerifyRegistration exposing (Model, Msg(..), init, update, view, subscriptions)

import Browser.Navigation as Nav

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http
import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import User
import Session

import Forms

-- MODEL

type alias Model =
    { session : Session.Session
    , token : Token
    , name : String
    , password : Forms.Value String
    , passwordAgain : Forms.Value String
    , maybeBerificationResult : Maybe VerificationResult
    }

type Token
    = Valid String
    | Invalid String
    | Loading String

type VerificationResult 
    = Success
    | Failed String


toValid : Token -> Token
toValid token = 
    case token of
        Valid value ->
            token
    
        Invalid value ->
            Valid value

        Loading value ->
            Valid value

toInvalid : Token -> Token
toInvalid token = 
    case token of
        Valid value ->
            Invalid value
    
        Invalid value ->
            token

        Loading value ->
            Invalid value

getTokenValue : Token -> String
getTokenValue token =
    case token of
        Valid value ->
            value
    
        Invalid value ->
            value

        Loading value ->
            value


init : Session.Session -> String -> (Model, Cmd Msg)
init session token = 
    (Model session (Loading token) "" Forms.emptyString Forms.emptyString Nothing, validateToken (Loading token))

-- UPDATE

type Msg
    = SetName String
    | SetPassword String
    | SetPasswordAgain String
    | SubmitVerification
    | GotTokenValidationResult (Result Http.Error String)
    | GotVerificationResult (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetName name ->
            ( { model | name = name }, Cmd.none)

        SetPassword password ->
            ( { model | password = Forms.FormValue password }, Cmd.none)

        SetPasswordAgain passwordAgain ->
            ( { model | passwordAgain = Forms.FormValue passwordAgain }, Cmd.none)

        SubmitVerification ->
            if (Forms.getStringValue model.password) == (Forms.getStringValue model.passwordAgain) then
                let
                    validatedPassword = Forms.validateNotEmptyString "Please give me your passsword." model.password
                    validatedPasswordAgain = Forms.validateNotEmptyString "Please give me your passsword again." model.passwordAgain
                in
                if Forms.invalid validatedPassword then
                    ({ model | password = validatedPassword, passwordAgain = validatedPasswordAgain }, Cmd.none)
                else
                    ( model, submitPassword model )
            else
                ( { model | maybeBerificationResult = Just (Failed "Passwords must be the same!") }, Cmd.none )

        GotTokenValidationResult result ->
            case result of
                Ok userName ->
                   ( { model | token = (toValid model.token), name = userName }, Cmd.none ) 
            
                Err _ ->
                    ( { model | token = (toInvalid model.token) }, Cmd.none )

        GotVerificationResult result ->
            case result of
                Ok _ ->
                   ( { model | maybeBerificationResult = (Just Success) }, Nav.pushUrl (Session.getNavKey model.session) "/login" ) 
            
                Err _ ->
                    ( { model | maybeBerificationResult = (Just (Failed "Error happened on the server")) }, Cmd.none )


-- API

validateToken : Token -> Cmd Msg
validateToken token =
    Http.get
        { url = "/api/registration/" ++ (getTokenValue token)
        , expect = Http.expectJson GotTokenValidationResult tokenValidationDecoder
        }


tokenValidationDecoder : Decoder String
tokenValidationDecoder =
    field "data" (field "username" string)


submitPassword : Model -> Cmd Msg
submitPassword model =
    Http.post
        { url = "/api/registration/" ++ (getTokenValue model.token)
        , body = Http.jsonBody (passwordEncoder model)
        , expect = Http.expectString GotVerificationResult
        }

passwordEncoder : Model -> Encode.Value
passwordEncoder model =
    Encode.object
        [ ("password", Encode.string (Forms.getStringValue model.password))
        , ("password_again", Encode.string (Forms.getStringValue model.passwordAgain))
        ]

-- VIEW

view : Model -> Html Msg
view model =
    case model.token of
        Loading _ ->
            div [] [ text "Loading token." ]
    
        Invalid _ ->
            div [] [ text "Sorry but the given token is not valid." ]

        Valid token ->
            div [ class "columns is-desktop" ]
                [ div [ class "column" ] []
                , div [ class "column" ] 
                    [ h1 [ class "title is-size-4" ] [ text ("Hello " ++ model.name ++ "! Please set your password.") ]
                    , Html.form [ class "has-padding-bottom-20" ]
                        [ div [ class "field" ] 
                            [ legend [ class "label" ] [ text "Password" ]
                            , div [ class "control" ] 
                                [ input [ class "input", type_ "password", value (Forms.getStringValue model.password), onInput SetPassword, placeholder "Password" ] [] ]
                            , validationMessage model.password
                            ]
                        , div [ class "field" ] 
                            [ legend [ class "label" ] [ text "Password again" ] 
                            , div [ class "control" ] 
                                [ input [ class "input", type_ "password", value (Forms.getStringValue model.passwordAgain), onInput SetPasswordAgain, placeholder "Password again" ] [] ]
                            , validationMessage model.passwordAgain
                            ]
                        , div [ class "field" ] 
                            [ div [ class "control" ] 
                                [ button [ class "button is-link", type_ "button", onClick SubmitVerification ] [ text "Save" ] ]
                            ]
                        ]
                    , registrationResultView model.maybeBerificationResult
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
    

registrationResultView : Maybe VerificationResult -> Html Msg
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