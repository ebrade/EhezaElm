module Main exposing (main)

import Browser
import Html exposing (Html, button, div, li, text, ul)
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


fetchTopStoryIDs : Task Http.Error (List Int)
fetchTopStoryIDs =
    HttpBuilder.get "https://hacker-news.firebaseio.com/v0/topstories.json"
        |> HttpBuilder.withExpectJson (Json.Decode.list Json.Decode.int)
        |> HttpBuilder.toTask


fetchCurrentStory : Int -> Task Http.Error Story
fetchCurrentStory int =
    HttpBuilder.get ("https://hacker-news.firebaseio.com/v0/item/" ++ String.fromInt(int) ++ ".json")
        |> HttpBuilder.withExpectJson decodeStory
        |> HttpBuilder.toTask


fetchstories : Cmd Msg
fetchstories =
    fetchTopStoryIDs
        |> Task.andThen
            (\topStoryIDs ->
                topStoryIDs
                    |> List.map fetchCurrentStory
                    |> Task.sequence
            )
        |> RemoteData.asCmd
        |> Cmd.map StoriesFetched


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchClick ->
            ( { model | stories = Loading }
            , fetchstories
            )

        StoriesFetched stories ->
            ( { model | stories = stories }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ case model.stories of
            NotAsked ->
                button [ onClick FetchClick ] [ text "Fetch stories" ]

            Loading ->
                text "Loading..."

            Success stories ->
                ul [] <|
                    List.map
                        (\story ->
                            li [] [ text story.title ]
                        )
                        stories

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
    , descendants : Int
    , id : Int
    , score : Int
    , time : Int
    , title : String
    , url : String
    }


decodeStory : Json.Decode.Decoder Story
decodeStory =
    Json.Decode.succeed Story
        |> Json.Decode.Pipeline.required "by" Json.Decode.string
        |> Json.Decode.Pipeline.required "descendants" Json.Decode.int
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "score" Json.Decode.int
        |> Json.Decode.Pipeline.required "time" Json.Decode.int
        |> Json.Decode.Pipeline.required "title" Json.Decode.string
        |> Json.Decode.Pipeline.required "url" Json.Decode.string


