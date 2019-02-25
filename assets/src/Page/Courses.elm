module Page.Courses exposing (Model, Msg(..), Config, init, update, view, subscriptions, toConfig)

import Api
import Browser.Navigation as Nav

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http
import Json.Decode exposing (Decoder, field, map5, list, string, int, andThen, succeed, fail)
import Json.Encode as Encode

import CoursePreview
import NewCourse
import User
import Session
import Role
import DateTime

import List.Split as Split
import Array

import PaginatedList

import Forms

-- MODEL

type alias Model =
    { session : Session.Session
    , searchText : String
    , newCourse : NewCourse.NewCourse
    , isNewCourseVisible : Bool
    , courses : PaginatedList.PaginatedList CoursePreview.CoursePreview
    }


type alias Config =
    { page : Int
    , limit : Int
    , title : String
    }

toConfig : Maybe Int -> Maybe Int -> Maybe String -> Config
toConfig maybePage maybeLimit maybeTitle =
    let
        page =
            case maybePage of
                Just value ->
                    value
            
                Nothing ->
                    1
        limit =
            case maybeLimit of
                Just value ->
                    value
            
                Nothing ->
                    20
        title =
            case maybeTitle of
                Just value ->
                    value
            
                Nothing ->
                    ""
    in
    Config page limit title


init : Config -> Session.Session -> (Model, Cmd Msg)
init config session = 
    let
        courses = PaginatedList.PaginatedList config.page config.limit 1 []
    in
    (Model session config.title NewCourse.empty False courses, toPage session courses.page courses.limit config.title)

toPage : Session.Session -> Int -> Int -> String -> Cmd Msg
toPage session page limit title =
    Nav.pushUrl (Session.getNavKey session) ("/courses?page=" ++ (String.fromInt page) ++ "&limit=" ++ (String.fromInt limit) ++ (titleQueryPart title))


titleQueryPart : String -> String
titleQueryPart title =
    case String.trim title of
        "" ->
            ""
            
        trimmed_title ->
            "&title=" ++ trimmed_title

-- UPDATE

type Msg
    = NoOp PaginatedList.Msg
    | PageChanged Int Int
    | SetSearchText String
    | GotCoursesPage (Result Http.Error (PaginatedList.PaginatedList CoursePreview.CoursePreview))
    -- New course form
    | ShowNewCourseModal
    | HideNewCourseModal
    | SetNewCourseTitle String
    | SetNewCourseShortDescription String
    | SubmitNewCourse


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp _ ->
            ( model, Cmd.none )

        PageChanged page limit ->
            ( model, Api.getCourses GotCoursesPage model.session model.searchText page limit )
        
        SetSearchText value ->
            ( { model | searchText = value }, Cmd.none)

        GotCoursesPage result ->
            case result of
                Ok courses ->
                    ( { model | courses = courses }, Cmd.none)
            
                Err _ ->
                    ( model, Cmd.none )

        ShowNewCourseModal ->
            ( { model | newCourse = NewCourse.empty, isNewCourseVisible = True }, Cmd.none)

        HideNewCourseModal ->
            ( { model | newCourse = NewCourse.empty, isNewCourseVisible = False }, Cmd.none)

        SetNewCourseTitle value ->
            ( { model | newCourse = (NewCourse.setTitle value model.newCourse) }, Cmd.none )

        SetNewCourseShortDescription value ->
            ( { model | newCourse = (NewCourse.setShortDescription value model.newCourse) }, Cmd.none )

        SubmitNewCourse ->
            let
                (validatedNewCourse, isValid) = NewCourse.validate model.newCourse
            in
            if (Forms.valid validatedNewCourse.title) then
                ( { model | newCourse = validatedNewCourse }, submitNewCourse validatedNewCourse )
            else
                ( { model | newCourse = validatedNewCourse }, Cmd.none )


submitNewCourse : NewCourse.NewCourse -> Cmd Msg
submitNewCourse newCourse =
    Cmd.none
    

-- VIEW

view : Model -> Html Msg
view model =
    let
        pagination = 
            PaginatedList.view "courses" (titleQueryPart model.searchText) model.courses
            |> Html.map NoOp
    in
    div [] 
        [ h1 [ class "title" ] 
            [ text "Courses" ]
        , div [ class "columns" ] 
            [ div [ class "column" ]
                [ div [ class "field" ] 
                    [ div [ class "control" ] 
                        [ input [ class "input", type_ "text", onInput SetSearchText, placeholder "Search criteria" ] 
                            []
                        ]
                    ]
                , button [ class "button is-link" ] 
                    [ text "Search" ]
                ] 
            ]
        , div [ class "columns" ] 
            [ div [ class "column" ] 
                [ button [ onClick ShowNewCourseModal, class "button is-link is-pulled-right" ] 
                    [ text "New" ]
                ]
            ]
        , newCourseView model.isNewCourseVisible model.newCourse
        , pagination
        , courseListView model.session model.courses
        , pagination
        ]

newCourseView : Bool -> NewCourse.NewCourse -> Html Msg
newCourseView isVisible formData =
    div [ classList [("modal", True), ("is-active", isVisible)] ] 
        [ div [ class "modal-background" ] 
            []
        , div [ class "modal-card" ] 
            [ header [ class "modal-card-head" ] 
                [ p [ class "modal-card-title" ] 
                    [ text "New course" ]
                , button [ onClick HideNewCourseModal, class "delete", attribute "aria-label" "close" ]
                    []
                ]
            , section [ class "modal-card-body"]
                [ div [ class "field" ] 
                    [ legend [ class "label" ] [ text "Title" ]
                    , div [ class "control" ] 
                        [ input [ class "input", type_ "text", onInput SetNewCourseTitle, value (Forms.getStringValue formData.title), placeholder "Title" ] [] ]
                    , validationMessage formData.title
                    ]
                , div [ class "field" ] 
                    [ legend [ class "label" ] [ text "Short description" ] 
                    , div [ class "control" ] 
                        [ textarea [ class "textarea", onInput SetNewCourseShortDescription, value (Forms.getStringValue formData.shortDescription), placeholder "Short description" ] [] ]
                    ]
                ]
            , footer [ class "modal-card-foot" ]
                [ button [ onClick SubmitNewCourse, class "button is-success" ] 
                    [ text "Create" ]
                , button [ onClick HideNewCourseModal, class "button" ]
                    [ text "Cancel" ]
                ]
            ]
        ]

validationMessage : Forms.Value String -> Html Msg
validationMessage formValue =
    case formValue of
        Forms.FormValue _ ->
            span [] []
    
        Forms.InvalidFormValue message _ ->
            p [ class "help is-danger" ] [ text message ]


courseListView : Session.Session -> PaginatedList.PaginatedList CoursePreview.CoursePreview -> Html Msg
courseListView session courses =
    let
        courseColumns = Split.chunksOfLeft 3 courses.data
    in
    div [] (List.map (\column -> div [ class "columns" ] (courseListRowView session column) ) courseColumns)
            

courseListRowView : Session.Session -> List CoursePreview.CoursePreview -> List (Html Msg)
courseListRowView session column =
    let
        rowItems = Array.fromList column
        card = (\i row -> 
            case (Array.get i row) of
                Just course ->
                    div [ class "column" ] [ courseCardView session course ]

                Nothing ->
                    div [ class "column" ] []
            ) 
    in
    [card 0 rowItems
    , card 1 rowItems
    , card 2 rowItems]


courseCardView : Session.Session -> CoursePreview.CoursePreview -> Html Msg
courseCardView session course =
    a [ href ("/courses/" ++ (String.fromInt course.id)) ] 
        [ div [ class "card" ]
            [ div [ class "card-content" ]
                [ div [ class "content" ] 
                    [ h1 [ class "title" ] 
                        [ text course.title ]
                    , p [ class "subtitle is-6" ] 
                        [  span [ class "has-padding-right-10" ] 
                            [ text ("Last updated: " ++ (DateTime.toyyyyMMddhhmm course.lastUpdate (Session.getZone session))) ]
                        , courseStatusTag course.status
                        ]
                    , p [] 
                        [ text course.shortDescription ]
                    ]
                ]
            ]
        ]


courseStatusTag : CoursePreview.CourseStatus -> Html Msg
courseStatusTag status =
    case status of
        CoursePreview.Draft ->
            strong [ class "tag is-info", title "Students and the public can't see it." ] [ text "Draft" ]
    
        CoursePreview.Published ->
            strong [ class "tag is-primary", title "Students can see it but the public can't." ] [ text "Published" ]

        CoursePreview.Public ->
            strong [ class "tag is-success", title "Both students and the public can see it." ] [ text "Public" ]
            

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

    