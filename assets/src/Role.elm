module Role exposing (Role(..), decoder)

import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)

type Role
  = Admin
  | Mentor
  | Student

decoder : Decoder Role
decoder =
  let
    convert : String -> Decoder Role
    convert raw =
      if raw == "admin" then
        succeed Admin
      else if raw == "mentor" then
        succeed Mentor
      else if raw == "student" then
        succeed Student
      else
        fail "Unknown role"       
  in
    string |> andThen convert