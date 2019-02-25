module NewCourse exposing (NewCourse, empty, validate, encode, setTitle, setShortDescription)

import Json.Decode exposing (Decoder, field, map5, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import Forms


-- MODEL

type alias NewCourse =
    { title : Forms.Value String
    , shortDescription : Forms.Value String
    }

empty : NewCourse
empty =
    NewCourse Forms.emptyString Forms.emptyString


setTitle : String -> NewCourse -> NewCourse
setTitle title newCourse =
  { newCourse | title = Forms.FormValue title }


setShortDescription : String -> NewCourse -> NewCourse
setShortDescription shortDescription newCourse =
  { newCourse | shortDescription = Forms.FormValue shortDescription }


-- VALIDATE

validate : NewCourse -> (NewCourse, Bool)
validate newCourse =
    let
        title = Forms.validateNotEmptyString "Please give me a title." newCourse.title
        validatednewCourse = { newCourse | title = title }
    in
    if Forms.invalid validatednewCourse.title then
        (validatednewCourse, False)
    else
        (validatednewCourse, True)


-- ENCODER

encode : NewCourse -> Encode.Value
encode newCourse =
  Encode.object
    [ ("title", Encode.string (Forms.getStringValue newCourse.title))
    , ("short_description", Encode.string (Forms.getStringValue newCourse.shortDescription))
    ]