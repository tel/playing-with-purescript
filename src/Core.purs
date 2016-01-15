module Core where

import           DOM.HTML.Types         (HTMLElement ())
import           UiFi.Markup.DomIndex
import           UiFi.Markup.Node
import           UiFi.Markup.Node.Build
import qualified Data.IntMap       as IntMap

-- vNode :: Node
-- vNode = el "div" []
--   [ el "div" []
--     [ text "1" ]
--   , el "div" [] 
--     [ text "2" ]
--   , el "div" []
--     [ text "3" ]
--   ]
--
-- realNode = build vNode
--
-- nodes = domIndex [0, 1, 2, 3, 4, 5, 6] realNode vNode
