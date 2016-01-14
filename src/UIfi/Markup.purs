
module UiFi.Markup where

import           Control.Monad.Eff (Eff ())
import           Data.Maybe        (Maybe (Just, Nothing))
import           Data.Monoid       (Monoid)
import           DOM.HTML.Types    (HTMLElement ())
import           Prelude
import           Unsafe.Coerce     (unsafeCoerce)

data Initializer
data Finalizer

mkInitializer :: forall eff. (HTMLElement -> Eff eff Unit) -> Initializer
mkInitializer = unsafeCoerce

runInitializer :: forall r. ((forall eff. HTMLElement -> Eff eff Unit) -> r) -> Initializer -> r
runInitializer f init = f (unsafeCoerce init)

-- initializer :: forall eff . String -> (HTMLElement -> Eff eff Unit) -> Prop
-- initializer s f = InitializerP s (mkInitializer f)

mkFinalizer   :: forall eff. (HTMLElement -> Eff eff Unit) -> Finalizer
mkFinalizer   = unsafeCoerce

runFinalizer :: forall r. ((forall eff. HTMLElement -> Eff eff Unit) -> r) -> Finalizer -> r
runFinalizer f i = f (unsafeCoerce i)

-- finalizer :: forall eff. String -> (HTMLElement -> Eff eff Unit) -> Prop
-- finalizer s f = FinalizerP s (mkFinalizer f)
