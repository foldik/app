module Registration exposing (Registration, empty, setUserName, setEmail, setFirstName, setLastName, encode, validate)

import Forms

import Json.Encode as Encode


-- MODEL

type alias Registration =
    { userName : Forms.Value String
    , email : Forms.Value String
    , firstName : Forms.Value String
    , lastName : Forms.Value String
    }

empty : Registration
empty =
    Registration Forms.emptyString Forms.emptyString Forms.emptyString Forms.emptyString


setUserName : String -> Registration -> Registration
setUserName userName registration =
    { registration | userName = Forms.FormValue userName }


setEmail : String -> Registration -> Registration
setEmail email registration =
    { registration | email = Forms.FormValue email }


setFirstName : String -> Registration -> Registration
setFirstName firstName registration =
    { registration | firstName = Forms.FormValue firstName }


setLastName : String -> Registration -> Registration
setLastName lastName registration =
    { registration | lastName = Forms.FormValue lastName }


-- VALIDATE

validate : Registration -> (Registration, Bool)
validate registration =
    let
        userName = Forms.validateNotEmptyString "Please give me your user name." registration.userName
        email = Forms.validateNotEmptyString "Please give me your email." registration.email
        firstName = Forms.validateNotEmptyString "Please give me your first name." registration.firstName
        lastName = Forms.validateNotEmptyString "Please give me your last name." registration.lastName
        validatedRegistration = { registration | userName = userName, email = email, firstName = firstName, lastName = lastName }
    in
    if Forms.invalid validatedRegistration.userName then
        ( validatedRegistration, False )
    else if Forms.invalid validatedRegistration.email then
        ( validatedRegistration, False )
    else if Forms.invalid validatedRegistration.firstName then
        ( validatedRegistration, False )
    else if Forms.invalid validatedRegistration.lastName then
        ( validatedRegistration, False )
    else
        (validatedRegistration, True) 


-- ENCODER

encode : Registration -> Encode.Value
encode registration =
  Encode.object
    [ ("username", Encode.string (Forms.getStringValue registration.userName))
    , ("email", Encode.string (Forms.getStringValue registration.email))
    , ("first_name", Encode.string (Forms.getStringValue registration.firstName))
    , ("last_name", Encode.string (Forms.getStringValue registration.lastName))
    ]