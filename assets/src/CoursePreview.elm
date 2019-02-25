module CoursePreview exposing (CoursePreview, CourseStatus(..), decode)

import Json.Decode exposing (Decoder, field, map5, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import Forms

--MODEL

type alias CoursePreview =
    { id : Int
    , title : String
    , shortDescription : String
    , lastUpdate : Int
    , status : CourseStatus
    }


type CourseStatus
    = Draft
    | Published
    | Public

-- DECODER

decode : Decoder CoursePreview
decode =
    map5 CoursePreview
        (field "id" int)
        (field "title" string)
        (field "short_description" string)
        (field "last_update" int)
        (field "status" courseStatusDecoder)


courseStatusDecoder : Decoder CourseStatus
courseStatusDecoder = 
  let
    convert : String -> Decoder CourseStatus
    convert raw =
      if raw == "draft" then
        succeed Draft
      else if raw == "published" then
        succeed Published
      else if raw == "public" then
        succeed Public
      else
        fail "Unknown role"       
  in
    string |> andThen convert