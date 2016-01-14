
module UiFi.Markup.Node.Build where

import           Data.Nullable    (Nullable (), toNullable)
import           DOM.HTML.Types
import           Prelude
import           UiFi.Markup.Node
import           UiFi.Markup.ElConfig
import           UiFi.Markup.Attr
import           UiFi.Markup.Listener

-- | Use a `Node` as a blueprint to construct a live `HTMLElement`.
build :: Node -> HTMLElement
build n = 
  case n of
    Text t -> buildText t
    Element spec -> 
      case spec.config of
        ElConfig config ->
          buildElement { ns: toNullable spec.ns
                       , tag: spec.tag
                       , key: toNullable config.key
                       , attrs: config.attrs
                       , styles: config.styles
                       , listeners: config.listeners
                       , children: map build spec.children
                       }

foreign import buildText
  :: String -> HTMLElement

foreign import buildElement
  :: { ns        :: Nullable String
     , tag       :: String
     , key       :: Nullable String
     , attrs     :: Array Attr
     , styles    :: Array Attr
     , listeners :: Array Listener
     , children  :: Array HTMLElement
     } -> HTMLElement

