module Core where

import           Control.Monad.Aff
import           Control.Monad.Eff
import           Control.Monad.Eff.Console (print, CONSOLE ())
import           Control.Monad.Eff.Class
import           Data.Maybe
import qualified Data.Nullable                 as Nullable
import qualified DOM                           as Dom
import qualified DOM.HTML                      as Dom
import qualified DOM.HTML.Types                as Dom
import qualified DOM.HTML.Window               as Dom
import qualified DOM.Node.Node                 as Dom
import qualified DOM.Node.NonElementParentNode as Dom
import qualified DOM.Node.Types                as Dom
import qualified Internal.VirtualDOM           as Vd
import           Prelude

tree0 :: Vd.VTree
tree0 = Vd.vtext "Hello"

tree1 :: Vd.VTree
tree1 = Vd.vtext "Goodbye"

getElementById' :: forall eff . String -> Eff (dom :: Dom.DOM | eff) (Maybe Dom.Element)
getElementById' id = do
  wind <- Dom.window
  doc <- Dom.document wind
  let docNepn = Dom.documentToNonElementParentNode (Dom.htmlDocumentToDocument doc)
  elOrNot <- Dom.getElementById (Dom.ElementId id) docNepn
  return (Nullable.toMaybe elOrNot)

initVTree :: forall eff . Vd.VTree -> Dom.Node -> Eff (dom :: Dom.DOM | eff) Dom.HTMLElement
initVTree vt parent = do
  let el = Vd.createElement vt
  Dom.appendChild (Dom.htmlElementToNode el) parent
  return el

app :: forall eff . Aff (dom :: Dom.DOM | eff) Unit
app = do
  mayContainer <- liftEff $ getElementById' "container"
  case mayContainer of
    Nothing -> return unit
    Just container -> do
      el <- liftEff $ initVTree tree0 (Dom.elementToNode container)
      let delta = Vd.diff tree0 tree1
      liftEff $ Vd.patch delta el
      return unit

main :: Eff (dom :: Dom.DOM, console :: CONSOLE) Unit
main = runAff onError onResult app where
  onError err = print err
  onResult _ = return unit
