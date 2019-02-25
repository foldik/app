module User exposing (User, decoder)

import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)
import Role

type alias User = 
  { userName : String
  , firstName : String
  , lastName : String
  , role : Role.Role
  }

decoder : Decoder User
decoder =
  map4 User
    (field "username" string)
    (field "first_name" string)
    (field "last_name" string)
    (field "role" Role.decoder)
