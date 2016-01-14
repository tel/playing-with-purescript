
module UiFi.Markup.Event where

import Control.Monad.Eff
import Prelude
import DOM.HTML.Types

foreign import data HANDLER :: !

foreign import stopPropagation 
  :: forall r eff . Event r -> Eff (handler :: HANDLER | eff) Unit

foreign import preventDefault
  :: forall r eff . Event r -> Eff (handler :: HANDLER | eff) Unit

type Event r =
  { bubbles :: Boolean
  , cancelable :: Boolean
  , currentTarget :: HTMLElement
  , defaultPrevented :: Boolean
  , target :: HTMLElement
  , timeStamp :: Number
  , "type" :: String
  | r
  }

type KeyboardEvent r = Event ( keyCode :: Int | r )

type WheelDetail = 
  ( deltaX :: Number
  , deltaY :: Number
  , deltaZ :: Number
  , deltaMode :: Int
  )

type MouseDetail =
  ( button :: Number
  , detail :: Number
  , relatedTarget :: HTMLElement
  , clientX :: Number
  , clientY :: Number
  , screenX :: Number
  , screenY :: Number
  , pageX :: Number
  , pageY :: Number
  , ctrlKey :: Boolean
  , shiftKey :: Boolean
  , altKey :: Boolean
  , metaKey :: Boolean
  , which :: Number
  )

type DragDetail = 
  ( dataTransfer :: DataTransfer 
  | MouseDetail
  )

foreign import data DataTransfer :: *
