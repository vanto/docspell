module Page.ItemDetail.Update exposing (update)

import Api
import Browser.Navigation as Nav
import Comp.ItemDetail
import Comp.ItemDetail.Update
import Data.Flags exposing (Flags)
import Data.UiSettings exposing (UiSettings)
import Page.ItemDetail.Data exposing (Model, Msg(..))
import Scroll
import Task


update : Nav.Key -> Flags -> Maybe String -> UiSettings -> Msg -> Model -> ( Model, Cmd Msg, Sub Msg )
update key flags next settings msg model =
    case msg of
        Init id ->
            let
                ( lm, lc, ls ) =
                    Comp.ItemDetail.update key
                        flags
                        next
                        settings
                        Comp.ItemDetail.Update.Init
                        model.detail

                task =
                    Scroll.scroll "main-content" 0 0 0 0
            in
            ( { model | detail = lm }
            , Cmd.batch
                [ Api.itemDetail flags id ItemResp
                , Cmd.map ItemDetailMsg lc
                , Task.attempt ScrollResult task
                ]
            , Sub.map ItemDetailMsg ls
            )

        ItemDetailMsg lmsg ->
            let
                ( lm, lc, ls ) =
                    Comp.ItemDetail.update key flags next settings lmsg model.detail
            in
            ( { model | detail = lm }
            , Cmd.map ItemDetailMsg lc
            , Sub.map ItemDetailMsg ls
            )

        ItemResp (Ok item) ->
            let
                lmsg =
                    Comp.ItemDetail.Update.SetItem item
            in
            update key flags next settings (ItemDetailMsg lmsg) model

        ItemResp (Err _) ->
            ( model, Cmd.none, Sub.none )

        ScrollResult _ ->
            ( model, Cmd.none, Sub.none )
