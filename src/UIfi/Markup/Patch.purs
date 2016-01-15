
module UiFi.Markup.Patch where

import           Control.Monad.Eff
import           Data.IntMap          (IntMap ())
import qualified Data.IntMap          as IntMap
import           Data.Map             (Map ())
import qualified Data.Map             as Map
import           Data.Maybe
import           Data.Monoid
import           Data.StrMap          (StrMap ())
import qualified Data.StrMap          as StrMap
import           Data.Tuple           (Tuple (Tuple))
import           DOM                  (DOM ())
import           DOM.HTML.Types       (HTMLElement ())
import           Prelude
import           UiFi.Markup.Listener
import           UiFi.Markup.Node

type MoveSet =
  { removes :: Array { from :: Int, key :: Maybe String }
  , inserts :: Array { to :: Int, key :: String }
  }

data Patch
  = PatchNoOp
  | PatchRemove Node
  | PatchInsert Node
  | PatchText String
  | PatchNode Node
  | PatchOrder MoveSet
  | PatchAttrs (StrMap (Maybe String))
  | PatchStyles (StrMap (Maybe String))
  | PatchListeners (StrMap (Maybe Listener))

data PatchKey = A | I Int

instance patchKeyEq :: Eq PatchKey where
  eq A A = true
  eq (I i1) (I i2) = i1 == i2
  eq _ _ = false

instance patchKeyOrd :: Ord PatchKey where
  compare A A = EQ
  compare A _ = LT
  compare (I _) A = GT
  compare (I i1) (I i2) = compare i1 i2

newtype PatchSet = PatchSet { current :: Node, patches :: IntMap (Array Patch) }


----------------------------------------------------------------------------

patch :: forall eff . HTMLElement -> PatchSet -> Eff (dom :: DOM | eff) HTMLElement
patch el ps = do
  -- if no patches have numeric indices, return immediately: we're a no-op
  return el

----------------------------------------------------------------------------

patch1 :: forall eff . HTMLElement -> Patch -> Eff (dom :: DOM | eff) HTMLElement
patch1 el p = 
  case p of
    PatchNoOp -> return el

    PatchRemove vnode -> do
      -- (1) get parent of el
      -- (2) delete el from parent
      -- (3) use vnode to try to destroy widgets if needed
      return el

    PatchInsert vnode -> do
      -- (1) render vnode into an HTMLElement
      -- (2) append the result on to `el`
      return el

    PatchText string -> do
      -- (1) If `el` is a text node, replace its text
      -- (2) Else build a new text node and use `el.replaceNode` to swap it in
      return el

    -- PatchWidget 

    PatchNode vnode -> do
      -- (1) build a new node
      -- (2) el.replaceNode to swap it in
      return el

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
      return el
      
    PatchAttrs attrs -> do
      -- for each name in attrs (should include all previous ones!)
      -- - if new value is Remove
      --   - then: update attr to "" (or null, but we assume all strings?)
      --   - else: update attr to new value
      return el

    PatchStyles styles -> do
      -- for each name in styles (should include all previous ones!)
      -- - if new value is Remove
      --   - then: update style to ""
      --   - else: update style to new value
      return el

    PatchListeners listeners -> do
      -- for each name in listeners (should include all previous ones!)
      -- - if new value is Remove
      --   - then: update listener to undefined
      --   - else: update listener to new value
      return el
