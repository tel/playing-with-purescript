
module UiFi.Markup.Patch where

import           Control.Monad          (unless)
import           Control.Monad.Eff
import           Data.IntMap            (IntMap ())
import qualified Data.IntMap            as IntMap
import           Data.Maybe
import           Data.Maybe.Unsafe      (fromJust)
import           Data.StrMap            (StrMap ())
import qualified Data.StrMap            as StrMap
import           Data.Traversable       (for)
import           DOM                    (DOM ())
import           DOM.HTML.Types         (HTMLElement ())
import           Prelude
import           UiFi.Markup.DomIndex   (domIndex)
import           UiFi.Markup.Listener
import           UiFi.Markup.Node
import           UiFi.Markup.Node.Build (build)

type MoveSet =
  { removes :: Array { from :: Int, key :: Maybe String }
  , inserts :: Array { to :: Int, key :: String }
  }

data Patch
  = PatchRemove
  | PatchInsert Node
  | PatchText String
  | PatchNode Node
  | PatchOrder MoveSet
  | PatchAttrs (StrMap (Maybe String))
  | PatchStyles (StrMap (Maybe String))
  | PatchListeners (StrMap (Maybe Listener))

newtype PatchSet = PatchSet { current :: Node, patches :: IntMap (Array Patch) }

----------------------------------------------------------------------------

-- | Apply a `PatchSet` to an `HTMLElement`.
patch :: forall eff . HTMLElement -> PatchSet -> Eff (dom :: DOM | eff) Unit
patch el (PatchSet ps) = do
  unless (IntMap.null ps.patches) do 
    for indices applyPatches 
    return unit
  where
    indices = IntMap.indices ps.patches
    index = domIndex indices el ps.current
    applyPatches ix = do
      let patchList = fromJust (IntMap.lookup ix ps.patches)
          domNode = fromJust (IntMap.lookup ix index)
      for patchList (patch1 domNode)
      return unit

----------------------------------------------------------------------------

foreign import patchRemove :: forall eff . HTMLElement -> Eff (dom :: DOM | eff) Unit
foreign import patchInsert :: forall eff . HTMLElement -> HTMLElement -> Eff (dom :: DOM | eff) Unit
foreign import patchText :: forall eff . HTMLElement -> String -> Eff (dom :: DOM | eff) Unit
foreign import patchNode :: forall eff . HTMLElement -> HTMLElement -> Eff (dom :: DOM | eff) Unit

patch1 :: forall eff . HTMLElement -> Patch -> Eff (dom :: DOM | eff) Unit
patch1 el p = 
  case p of
    PatchRemove -> 
      patchRemove el
    PatchInsert vnode -> 
      patchInsert el (build vnode)
    PatchText string -> 
      patchText el string
    PatchNode vnode -> 
      patchNode el (build vnode)
    PatchOrder moves -> do
      -- (1) For each action in "removes"
      --     (1) take the remove.from-th child
      --     (2) cache it against its key if the key exists
      --     (3) remove it from `el`
      -- (2) For each action in "inserts"
      --     (1) grab the node, foundNode, from the cache by key
      --     (2) if insert.to is larger than the list of children
      --         - then el.insertBefore(foundNode, null)
      --         - else el.insertBefore(foundNode, insert.to-th child node)
      return unit
      
    PatchAttrs attrs -> do
      -- for each name in attrs (should include all previous ones!)
      -- - if new value is Remove
      --   - then: update attr to "" (or null, but we assume all strings?)
      --   - else: update attr to new value
      return unit

    PatchStyles styles -> do
      -- for each name in styles (should include all previous ones!)
      -- - if new value is Remove
      --   - then: update style to ""
      --   - else: update style to new value
      return unit

    PatchListeners listeners -> do
      -- for each name in listeners (should include all previous ones!)
      -- - if new value is Remove
      --   - then: update listener to undefined
      --   - else: update listener to new value
      return unit
