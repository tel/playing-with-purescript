
-- <https://developer.mozilla.org/en-US/docs/Web/Events>
-- <https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener>
module UiFi.Markup.Listener where

import           Control.Monad.Eff
import           Prelude
import           UiFi.Markup.Event
import Unsafe.Coerce   (unsafeCoerce)


data Listener

mkListener :: forall eff r . ListenerOf eff r -> Listener
mkListener = unsafeCoerce

runListener :: forall r . (forall eff e . (e -> Eff eff Unit) -> r) -> Listener -> r
runListener run l = 
  let it = unsafeCoerce l
  in run it.handle

type ListenerOf eff r = 
  { on :: String
  , handle :: Event r -> Eff eff Unit
  }
