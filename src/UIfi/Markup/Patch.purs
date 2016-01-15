
module UiFi.Markup.Patch where

import           Control.Monad          (unless)
import           Control.Monad.Eff
import           Control.Monad.ST
import qualified Data.Array             as A
import           Data.Array.Unsafe      (unsafeIndex)
import           Data.Function
import           Data.IntMap            (IntMap ())
import qualified Data.IntMap            as IntMap
import           Data.Maybe
import           Data.Maybe.Unsafe      (fromJust)
import           Data.Nullable          (Nullable (), toNullable)
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

foreign import patchRemove 
  :: forall eff . Fn1 HTMLElement (Eff (dom :: DOM | eff) Unit)
foreign import patchInsert 
  :: forall eff . Fn2 HTMLElement HTMLElement (Eff (dom :: DOM | eff) Unit)
foreign import patchText 
  :: forall eff . Fn2 HTMLElement String (Eff (dom :: DOM | eff) Unit)
foreign import patchNode 
  :: forall eff . Fn2 HTMLElement HTMLElement (Eff (dom :: DOM | eff) Unit)
foreign import childNodes 
  :: forall eff . Fn1 HTMLElement (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import removeFrom 
  :: forall eff . Fn2 HTMLElement HTMLElement (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import insertBefore 
  :: forall eff . Fn3 HTMLElement (Nullable HTMLElement) HTMLElement (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import clearAttr 
  :: forall eff . Fn2 HTMLElement String (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import setAttr 
  :: forall eff . Fn3 HTMLElement String String (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import clearStyle 
  :: forall eff . Fn2 HTMLElement String (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import setStyle 
  :: forall eff . Fn3 HTMLElement String String (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import clearListener 
  :: forall eff . Fn2 HTMLElement String (Eff (dom :: DOM | eff) (Array HTMLElement))
foreign import setListener 
  :: forall eff . Fn3 HTMLElement String Listener (Eff (dom :: DOM | eff) (Array HTMLElement))

-- TODO: SORT OF! Listeners have to be something more sophisticate than that...

patch1 :: forall eff . HTMLElement -> Patch -> Eff (dom :: DOM | eff) Unit
patch1 el p = 
  case p of
    PatchRemove -> 
      runFn1 patchRemove el
    PatchInsert vnode -> 
      runFn2 patchInsert el (build vnode)
    PatchText string -> 
      runFn2 patchText el string
    PatchNode vnode -> 
      runFn2 patchNode el (build vnode)
    PatchOrder moves -> runST do
      cacheRef <- newSTRef StrMap.empty
      children <- runFn1 childNodes el
      for moves.removes \remove -> do
        let child = unsafeIndex children remove.from
        runFn2 removeFrom el child
        case remove.key of
          Nothing -> return unit
          Just k -> do 
            modifySTRef cacheRef (StrMap.insert k child)
            return unit

      cache <- readSTRef cacheRef
      for moves.inserts \insert -> do
        let child = fromJust (StrMap.lookup insert.key cache)
        case A.index children insert.to of
          Nothing -> 
            runFn3 insertBefore el (toNullable Nothing) child
          Just nextChild -> 
            runFn3 insertBefore el (toNullable (Just nextChild)) child
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
