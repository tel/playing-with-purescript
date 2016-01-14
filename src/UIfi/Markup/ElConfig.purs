
module UiFi.Markup.ElConfig where

import           Data.Maybe
import           Data.Monoid
import           Prelude
import           UiFi.Markup.Attr
import           UiFi.Markup.Listener

newtype ElConfig 
  = ElConfig
    { key :: Maybe String
    , attrs :: Array Attr
    , styles :: Array Attr
    , listeners :: Array Listener
    }

key :: String -> ElConfig
key str = ElConfig { key: Just str, styles: [], attrs: [], listeners: [] }

attr :: Attr -> ElConfig
attr at = ElConfig { key: Nothing, styles: [], attrs: [ at ], listeners: [] }

listener :: forall eff r . ListenerOf eff r -> ElConfig
listener l = ElConfig { key: Nothing, styles: [], attrs: [], listeners: [ mkListener l ] }

instance elConfigSemigroup :: Semigroup ElConfig where
  append (ElConfig xs) (ElConfig ys) = 
    ElConfig { key: append xs.key ys.key
             , attrs: append xs.attrs ys.attrs
             , styles: append xs.styles ys.styles
             , listeners: append xs.listeners ys.listeners
             }

instance elConfigMonoid :: Monoid ElConfig where
  mempty = ElConfig { key: Nothing, styles: [], attrs: [], listeners: [] }
