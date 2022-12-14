module Components.Footer exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


black : Color
black =
    rgb255 0 0 0


white : Color
white =
    rgb255 255 255 255


view : Element msg
view =
    row
        [ centerX
        , width fill
        , height (px 50)
        , Background.color black
        ]
        [ el
            [ Font.color white
            , Font.size 4
            , Font.center
            ]
          <|
            text
                "© 2022 Hikaru Takahashi"
        ]
