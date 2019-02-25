module Route exposing (Route(..), router)

import Url
import Url.Parser exposing (Parser, (</>), (<?>), int, map, oneOf, s, string, top, parse)
import Url.Parser.Query as Query

type Route
    = Home
    | Login
    | Logout
    | Register
    | VerifyRegistration String 
    | ForgotPassword
    | ReloadSession
    | NotFound
    | Courses (Maybe Int) (Maybe Int) (Maybe String)
    | Course Int
    | Mentors
    | Students
--GEN_ROUTE_TYPE


router : Url.Url -> Route
router url =
  Maybe.withDefault NotFound (parse routeParser url)

routeParser : Parser (Route -> a) a
routeParser = 
  oneOf
    [ map Home top
    , map Login (s "login")
    , map Logout (s "logout")
    , map Register (s "register")
    , map VerifyRegistration (s "register" </> string)
    , map ForgotPassword (s "forgot-password")
    , map Courses (s "courses" <?> Query.int "page" <?> Query.int "limit" <?> Query.string "title")
    , map Course (s "courses" </> int )
    , map Mentors (s "mentors")
    , map Students (s "students")
--GEN_ROUTER_PARSER
    , map ReloadSession (s "reload-session")
    ]
