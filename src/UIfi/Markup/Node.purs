
module UiFi.Markup.Node where

import           Data.Foldable        (fold, foldl)
import           Data.Maybe
import           Prelude
import           UiFi.Markup.ElConfig

type NS = String
type TagName = String

data Node
  = Text String

  | Element 
    { ns :: Maybe String
    , tag :: String
    , config :: ElConfig
    , children :: Array Node
    , size :: Int
    }

  -- | Wrapped nodes are subject to initialization and finalization upon
  -- creation and destruction.
  -- | Wrapped 
  --   { initizalize :: Initializer
  --   , finalize :: Finalizer
  --   , node :: Node
  --   }

el_ :: Maybe NS -> TagName -> Array ElConfig -> Array Node -> Node
el_ ns tag configs children = 
  Element { ns: ns
          , tag: tag
          , config: fold configs
          , children: children 
          , size: 1 + foldl (\total child -> total + size child) 0 children
          }

size :: Node -> Int
size (Text _) = 1
size (Element s) = s.size

elNS :: NS -> TagName -> Array ElConfig -> Array Node -> Node
elNS ns = el_ (Just ns)

el :: TagName -> Array ElConfig -> Array Node -> Node
el = el_ Nothing

text :: String -> Node
text = Text
