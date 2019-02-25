import Api
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, map2, map4, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode
import Url

import Route
import Page.Login as LoginPage
import Page.Logout as LogoutPage
import Page.Register as RegisterPage
import Page.VerifyRegistration as VerifyRegistrationPage
import Page.ForgotPassword as ForgotPasswordPage
import Page.Home as HomePage
import Page.Courses as CoursesPage
import Page.Mentors as MentorsPage
import Page.Students as StudentsPage
import Page.Course as CoursePage
--GEN_PAGE_IMPORT

import Session
import User
import Role
import Task
import Time

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


-- MODEL

type alias Model =
    { session : Session.Session
    , isMenuOpen : Bool
    , page : Page
    }

type Page 
    = Loading
    | NotFound
    | Logout LogoutPage.Model
    | Login LoginPage.Model
    | Home HomePage.Model
    | Register RegisterPage.Model
    | VerifyRegistration VerifyRegistrationPage.Model
    | ForgotPassword ForgotPasswordPage.Model
    | Courses CoursesPage.Model
    | Mentors MentorsPage.Model
    | Students StudentsPage.Model
    | Course CoursePage.Model
--GEN_PAGE_TYPE


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        session = Session.guest key url
    in
    ( Model session False Loading
    , Task.perform SetTimeZone Time.here
    --, Api.loadSession GotSession
    )

-- VIEW

view : Model -> Browser.Document Msg
view model =
    { title = "App"
    , body =
        [ headerView model.isMenuOpen model.session
        , viewPage model
        ]
    }

headerView : Bool -> Session.Session -> Html Msg
headerView isMenuOpen session =
    let
        menuView =
            case session of
                Session.NotSignedIn _ _ _ ->
                    [ div [ class "navbar-start" ]
                        [ a [ class "navbar-item", href "/login"] [ text "Login" ]
                        ]
                    ]

                Session.SignedIn _ _ _ user ->
                    [ div [ class "navbar-start" ] (roleBasedHeaderView user)
                    , div [ class "navbar-end"] 
                        [ div [ class "navbar-item" ] 
                            [ div [ class "buttons" ] 
                                [ a [ class "button is-light",  href "/logout" ] 
                                    [ text "Logout" ] 
                                ]
                            ]
                        ]
                    ]
    in
    nav [ class "navbar is-link", attribute "role" "navigation", attribute "aria-label" "main navigation" ] 
        [ div [ class "navbar-brand" ] 
            [ a [ class "navbar-item", href "/" ] [ strong [] [ text "╦╣" ] ]
            , span [ onClick ToggleMenu
                    , class "navbar-burger burger"
                    , attribute "role" "button"
                    , attribute "aria-label" "menu"
                    , attribute "aria-expanded" (boolToString isMenuOpen)
                    , attribute "data-target" "navItems"
                    ] 
                [ span [ attribute "aria-hidden" "true" ] []
                , span [ attribute "aria-hidden" "true" ] []
                , span [ attribute "aria-hidden" "true" ] []
                ]
            ]
        , div [ id "navItems", classList [("navbar-menu", True), ("is-active", isMenuOpen)] ]
            menuView
        ] 
    

roleBasedHeaderView : User.User -> List (Html Msg)
roleBasedHeaderView user =
    case user.role of
        Role.Admin ->
            [ a [ class "navbar-item", href "/courses" ] [ strong [] [ text "Courses" ] ]
            , a [ class "navbar-item", href "/mentors" ] [ strong [] [ text "Mentors" ] ]
            , a [ class "navbar-item", href "/students" ] [ strong [] [ text "Students" ] ]

            ]
    
        Role.Mentor ->
            [ a [ class "navbar-item", href "/courses" ] [ text "Courses" ]
            , a [ class "navbar-item", href "/students" ] [ text "Students" ]
            ]

        Role.Student ->
            [ a [ class "navbar-item", href "/courses" ] [ text "Courses" ]
            ]
    


viewPage : Model -> Html Msg
viewPage model =
    let
        pageContent =
            case model.page of
                Loading ->
                    div [] [ text "Loading" ]

                NotFound ->
                    div [] [ text "Not found :(" ]

                Login pageModel ->
                    LoginPage.view pageModel
                        |> Html.map LoginMsg

                Logout pageModel ->
                    LogoutPage.view pageModel
                        |> Html.map LogoutMsg
            
                Home pageModel ->
                    HomePage.view pageModel
                        |> Html.map HomeMsg

                Register pageModel ->
                    RegisterPage.view pageModel
                        |> Html.map RegisterMsg 

                VerifyRegistration pageModel ->
                    VerifyRegistrationPage.view pageModel
                        |> Html.map VerifyRegistrationMsg 

                ForgotPassword pageModel ->
                    ForgotPasswordPage.view pageModel
                        |> Html.map ForgotPasswordMsg

                Courses pageModel ->
                    CoursesPage.view pageModel
                        |> Html.map CoursesMsg

                Mentors pageModel ->
                    MentorsPage.view pageModel
                        |> Html.map MentorsMsg

                Students pageModel ->
                    StudentsPage.view pageModel
                        |> Html.map StudentsMsg

                Course pageModel ->
                    CoursePage.view pageModel
                        |> Html.map CourseMsg

--GEN_VIEW_PAGE

    in
    div [ onClick CollapseMenu, class "section" ] 
        [ div [ class "container" ] 
            [ pageContent ] 
        ]
    
            

-- UPDATE

type Msg
    = SetTimeZone Time.Zone
    | ToggleMenu
    | CollapseMenu
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotSession (Result Http.Error User.User)
    | LoginMsg LoginPage.Msg
    | LogoutMsg LogoutPage.Msg
    | HomeMsg HomePage.Msg
    | RegisterMsg RegisterPage.Msg
    | VerifyRegistrationMsg VerifyRegistrationPage.Msg
    | ForgotPasswordMsg ForgotPasswordPage.Msg
    | CoursesMsg CoursesPage.Msg
    | MentorsMsg MentorsPage.Msg
    | StudentsMsg StudentsPage.Msg
    | CourseMsg CoursePage.Msg
--GEN_PAGE_MESSAGE


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case (msg, model.page) of
        (SetTimeZone zone, _) ->
            ( { model | session = (Session.setZone model.session zone) }
            , Api.loadSession GotSession
            )

        (LinkClicked urlRequest, _) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.getNavKey model.session) (Url.toString url) 
                    )
            
                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        (UrlChanged url, _) ->
            let
                session = Session.setUrl model.session url
            in
            changeToRoute session model.page

        (GotSession result, _) ->
            case result of
                Ok user ->
                    let
                        session = Session.toSignedIn model.session user
                    in
                    case Route.router (Session.getUrl session) of
                        Route.ReloadSession ->
                            ( { model | session = session }, Nav.pushUrl (Session.getNavKey session) "/" )
                    
                        _ ->
                            changeToRoute session model.page
            
                Err _ ->
                    let
                        session = Session.toNotSignedIn model.session
                    in
                    case Route.router (Session.getUrl session) of
                        Route.Login ->
                            changeToRoute session model.page
                    
                        Route.Register ->
                            changeToRoute session model.page

                        Route.ForgotPassword ->
                            changeToRoute session model.page

                        Route.VerifyRegistration _ ->
                            changeToRoute session model.page

                        _ ->
                            ( Model session False Loading, Nav.pushUrl (Session.getNavKey session) "/login" )

        (LoginMsg pageMsg, Login pageModel) ->
            let
                (newPageModel, command) = (LoginPage.update pageMsg pageModel)
            in
            ( { model | page = (Login newPageModel) }
            , Cmd.map LoginMsg command
            )

        (LogoutMsg pageMsg, Logout pageModel) ->
            let
                (newPageModel, command) = (LogoutPage.update pageMsg pageModel)
            in
            ( { model | page = (Logout newPageModel) }
            , Cmd.map LogoutMsg command
            )

        (RegisterMsg pageMsg, Register pageModel) ->
            let
                (newPageModel, command) = (RegisterPage.update pageMsg pageModel)
            in
            ( { model | page = (Register newPageModel) }
            , Cmd.map RegisterMsg command
            )

        (VerifyRegistrationMsg pageMsg, VerifyRegistration pageModel) ->
            let
                (newPageModel, command) = (VerifyRegistrationPage.update pageMsg pageModel)
            in
            ( { model | page = (VerifyRegistration newPageModel) }
            , Cmd.map VerifyRegistrationMsg command
            )

        (ForgotPasswordMsg pageMsg, ForgotPassword pageModel) ->
            let
                (newPageModel, command) = (ForgotPasswordPage.update pageMsg pageModel)
            in
            ( { model | page = (ForgotPassword newPageModel) }
            , Cmd.map ForgotPasswordMsg command
            )

        (HomeMsg pageMsg, Home pageModel) ->
            let
                (newPageModel, command) = (HomePage.update pageMsg pageModel)
            in
            ( { model | page = (Home newPageModel) }
            , Cmd.map HomeMsg command
            )

        (CoursesMsg pageMsg, Courses pageModel) ->
            let
                (newPageModel, command) = (CoursesPage.update pageMsg pageModel)
            in
            ( { model | page = (Courses newPageModel) }
            , Cmd.map CoursesMsg command
            )

        (MentorsMsg pageMsg, Mentors pageModel) ->
            let
                (newPageModel, command) = (MentorsPage.update pageMsg pageModel)
            in
            ( { model | page = (Mentors newPageModel) }
            , Cmd.map MentorsMsg command
            )

        (StudentsMsg pageMsg, Students pageModel) ->
            let
                (newPageModel, command) = (StudentsPage.update pageMsg pageModel)
            in
            ( { model | page = (Students newPageModel) }
            , Cmd.map StudentsMsg command
            )

        (CourseMsg pageMsg, Course pageModel) ->
            let
                (newPageModel, command) = (CoursePage.update pageMsg pageModel)
            in
            ( { model | page = (Course newPageModel) }
            , Cmd.map CourseMsg command
            )

--GEN_UPDATE_PAGE

        (ToggleMenu, _) ->
            ( { model | isMenuOpen = (not model.isMenuOpen) }, Cmd.none)

        (CollapseMenu, _) ->
            ( { model | isMenuOpen = False }, Cmd.none)

        (_, _) ->
            ( model
            , Cmd.none
            )

-- ROUTER

changeToRoute : Session.Session -> Page -> (Model, Cmd Msg)
changeToRoute session oldPage =
    case ((Session.isSignedIn session), (Route.router (Session.getUrl session)), oldPage) of
        (False, Route.Login, _) ->
            let
                (initModel, command) = LoginPage.init session
            in
            (Model session False (Login initModel), Cmd.map LoginMsg command) 

        (True, Route.Logout, _) ->
            let
                (initModel, command) = LogoutPage.init session
            in
            (Model session False (Logout initModel), Cmd.map LogoutMsg command) 
    
        (False, Route.Register, _) ->
            let
                (initModel, command) = RegisterPage.init
            in
            (Model session False (Register initModel), Cmd.map RegisterMsg command)

        (False, Route.VerifyRegistration token, _) ->
            let
                (initModel, command) = VerifyRegistrationPage.init session token
            in
            (Model session False (VerifyRegistration initModel), Cmd.map VerifyRegistrationMsg command)


        (False, Route.ForgotPassword, _) ->
            let
                (initModel, command) = ForgotPasswordPage.init
            in
            (Model session False (ForgotPassword initModel), Cmd.map ForgotPasswordMsg command)

        (True, Route.Home, _) ->
            let
                (initModel, command) = HomePage.init session
            in
            (Model session False (Home initModel), Cmd.map HomeMsg command)

        (True, Route.Courses maybePage maybeLimit maybeTitle, previousPage) ->
            let
                config = CoursesPage.toConfig maybePage maybeLimit maybeTitle
            in
            case previousPage of
                Courses pageModel ->
                    let
                        (newPageModel, command) = CoursesPage.update (CoursesPage.PageChanged config.page config.limit) pageModel
                    in
                    (Model session False (Courses newPageModel), Cmd.map CoursesMsg command)
                _ ->
                    let
                        (initModel, command) = CoursesPage.init config session          
                    in
                    (Model session False (Courses initModel), Cmd.map CoursesMsg command)
                    
        (True, Route.Mentors, _) ->
            let
                (initModel, command) = MentorsPage.init session
            in
            (Model session False (Mentors initModel), Cmd.map MentorsMsg command)

        (True, Route.Students, _) ->
            let
                (initModel, command) = StudentsPage.init session
            in
            (Model session False (Students initModel), Cmd.map StudentsMsg command)

        (True, Route.Course id, _) ->
            let
                (initModel, command) = CoursePage.init session id
            in
            (Model session False (Course initModel), Cmd.map CourseMsg command)

--GEN_ROUTER

        (_, Route.NotFound, _) ->
            (Model session False NotFound, Cmd.none)

        (_, Route.ReloadSession, _) ->
            (Model session False Loading, Api.loadSession GotSession)

        (True, _, _) ->
            ( Model session False Loading, Nav.pushUrl (Session.getNavKey session) "/" )

        (False, _, _) ->
            ( Model session False Loading, Nav.pushUrl (Session.getNavKey session) "/login" )


boolToString : Bool -> String
boolToString value =
    case value of
        True ->
            "true"
    
        False ->
            "false"


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Loading ->
            Sub.none

        NotFound ->
            Sub.none

        Login pageModel ->
            LoginPage.subscriptions pageModel
                |> Sub.map LoginMsg

        Logout pageModel ->
            LogoutPage.subscriptions pageModel
                |> Sub.map LogoutMsg
    
        Home pageModel ->
            HomePage.subscriptions pageModel
                |> Sub.map HomeMsg

        Register pageModel ->
            RegisterPage.subscriptions pageModel
                |> Sub.map RegisterMsg 

        VerifyRegistration pageModel ->
            VerifyRegistrationPage.subscriptions pageModel
                |> Sub.map VerifyRegistrationMsg 

        ForgotPassword pageModel ->
            ForgotPasswordPage.subscriptions pageModel
                |> Sub.map ForgotPasswordMsg     

        Courses pageModel ->
            CoursesPage.subscriptions pageModel
                |> Sub.map CoursesMsg     

        Mentors pageModel ->
            MentorsPage.subscriptions pageModel
                |> Sub.map MentorsMsg     

        Students pageModel ->
            StudentsPage.subscriptions pageModel
                |> Sub.map StudentsMsg     

        Course pageModel ->
            CoursePage.subscriptions pageModel
                |> Sub.map CourseMsg     

--GEN_SUBSCRIPTION
            