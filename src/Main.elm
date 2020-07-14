module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Browser
import Debug exposing (toString)
import Html exposing (Html, button, div, input, li, text, ul)
import Html.Attributes exposing (align, class, placeholder)
import Html.Events exposing (onClick)
import Http
import HttpBuilder
import Json.Decode
import Json.Decode.Pipeline
import RemoteData exposing (RemoteData(..), WebData)
import Task exposing (Task)


type alias Model =
    { stories : WebData (List Story) }


init : () -> ( Model, Cmd Msg )
init flags =
    ( { stories = NotAsked }, Cmd.none )


type Msg
    = FetchClick
    | StoriesFetched (WebData (List Story))


--- Getting All Top Stories IDs From Hacker News Top Story API ---
fetchTopStoryIDs : Task Http.Error (List Int)
fetchTopStoryIDs =
    HttpBuilder.get "https://hacker-news.firebaseio.com/v0/topstories.json"
        |> HttpBuilder.withExpectJson (Json.Decode.list Json.Decode.int)
        |> HttpBuilder.toTask

--- Getting A Story Content Using Hacker News Story API---
fetchCurrentStory : Int -> Task Http.Error Story
fetchCurrentStory int =
    HttpBuilder.get ("https://hacker-news.firebaseio.com/v0/item/" ++ String.fromInt(int) ++ ".json")
        |> HttpBuilder.withExpectJson decodeStory
        |> HttpBuilder.toTask


--- Fetching All Stories As A list of the Story Type ---
fetchStories : Cmd Msg
fetchStories =
    fetchTopStoryIDs
        |> Task.andThen
            (\topStoryIDs ->
                topStoryIDs
                    |> List.map fetchCurrentStory
                    |> Task.sequence
            )
        |> RemoteData.asCmd
        |> Cmd.map StoriesFetched


--- Update ---
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchClick ->
            ( { model | stories = Loading }
            , fetchStories
            )

        StoriesFetched stories ->
            ( { model | stories = stories }
            , Cmd.none
            )


--- Model ---
view : Model -> Html Msg
view model =
    div []
        [ case model.stories of
            NotAsked ->

                Card.config []
                    |> Card.block []
                        [ Block.titleH4 [] [ text "E-Heza Elm Challenge" ]
                        , Block.text [] [ text "Welcome! Click Button Bellow to Get top Stories From Hacker News." ]
                        , Block.custom
                        <| Button.button [ Button.onClick FetchClick, Button.success ]
                            [ text "Fetch Hacker New Top stories" ]

                        ]
                    |> Card.view

            Loading ->
                text "Loading Stories From the HackerNews APi..."

            Success stories ->
                div[][text ("All Top Stories From Hacker News")
                ,div[class "row d-flex justify-content-center"][
                    ul [class "list-group col-md-8"] <|
                        List.map
                            (\story ->
                                li [class "list-group-item border-dark"]
                                    [ li[class "list-group-item"][text ("Posted By: " ++  story.by)]
                                    , li [class "list-group-item"][text ("Story Title: " ++ story.title )]
                                    , li [class "list-group-item"][input [class "col-md-6",placeholder "Enter Your notes"][] ]
                                     ]

                            )
                            stories
                ]]

            Failure err ->
                text <| Debug.toString err

        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


type alias Story =
    { by : String
    , title : String
    }


decodeStory : Json.Decode.Decoder Story
decodeStory =
    Json.Decode.succeed Story
        |> Json.Decode.Pipeline.required "by" Json.Decode.string
        |> Json.Decode.Pipeline.required "title" Json.Decode.string



