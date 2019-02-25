module Forms exposing (Value(..), valid, invalid, emptyString, getStringValue, validateNotEmptyString)

type Value a
    = FormValue a
    | InvalidFormValue String a

valid : Value a -> Bool
valid formValue =
    case formValue of
        FormValue value ->
            True
    
        InvalidFormValue _ value ->
            False 

invalid : Value a -> Bool
invalid formValue =
    case formValue of
        FormValue value ->
            False
    
        InvalidFormValue _ value ->
            True 


emptyString : Value String
emptyString =
    FormValue ""


getStringValue : Value String -> String
getStringValue formValue =
    case formValue of
        FormValue value ->
            value
    
        InvalidFormValue _ value ->
            value

validateNotEmptyString : String -> Value String -> Value String
validateNotEmptyString message formValue =
    case formValue of
        FormValue value ->
            notEmptyString message value
    
        InvalidFormValue _ value ->
            notEmptyString message value

notEmptyString : String -> String -> Value String
notEmptyString message value =
    case (String.trim value) of
        "" ->
            InvalidFormValue message value

        _ ->
            FormValue value 
    