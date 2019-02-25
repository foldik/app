module Api exposing (loadSession, login, logout, register, getCourses)

import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import Http
import Session
import User
import Role
import Registration
import CoursePreview
import PaginatedList
import NewCourse


-- SESSION

loadSession : (Result Http.Error User.User -> msg) -> Cmd msg
loadSession msg =
  Http.get
    { url = "/api/me"
    , expect = Http.expectJson msg userDecoder
    }

userDecoder : Decoder User.User
userDecoder =
  field "data" User.decoder


-- LOGIN

login : (Result Http.Error User.User -> msg) -> String -> String -> Cmd msg
login msg userName password =
  Http.post
    { url = "/api/login"
    , body = Http.jsonBody (loginEncoder userName password)
    , expect = Http.expectJson msg userDecoder
    }

loginEncoder : String -> String -> Encode.Value
loginEncoder userName password =
  Encode.object
    [ ("username", Encode.string userName)
    , ("password", Encode.string password)
    ]


-- LOGOUT

logout : (Result Http.Error String -> msg) -> Cmd msg
logout msg =
  Http.post
    { url = "/api/logout"
    , body = Http.emptyBody
    , expect = Http.expectString msg
    }


-- REGISTRATION

register : (Result Http.Error String -> msg) -> Registration.Registration -> Cmd msg
register msg registration =
  Http.post
    { url = "/api/registration"
    , body = Http.jsonBody (Registration.encode registration)
    , expect = Http.expectString msg
    }


-- COURSE PREVIEW

getCourses : (Result Http.Error (PaginatedList.PaginatedList CoursePreview.CoursePreview) -> msg) -> Session.Session -> String -> Int -> Int -> Cmd msg 
getCourses msg session title page limit =
    case session of
        Session.SignedIn _ _ _ user ->
            case user.role of
                Role.Admin ->
                    getCoursesPage msg title page limit "admin" 
            
                Role.Mentor ->
                    getCoursesPage msg title page limit "mentor"

                Role.Student ->
                    Cmd.none
    
        _ ->
            Cmd.none   

getCoursesPage : (Result Http.Error (PaginatedList.PaginatedList CoursePreview.CoursePreview) -> msg) -> String -> Int -> Int -> String -> Cmd msg
getCoursesPage msg title page limit apiPrefix =
    let
        url =
            case String.trim title of
                "" ->
                    ("/api/" ++ apiPrefix ++ "/courses?page=" ++ (String.fromInt page) ++ "&limit=" ++ (String.fromInt limit))
            
                title_param ->
                    ("/api/" ++ apiPrefix ++ "/courses?page=" ++ (String.fromInt page) ++ "&limit=" ++ (String.fromInt limit) ++ "&title=" ++ title_param)
    in
    Http.get
        { url = url
        , expect = Http.expectJson msg (PaginatedList.decoder CoursePreview.decode)
        }