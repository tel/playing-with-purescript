
module Test.Data.IntMap where

import           Data.IntMap
import           Data.Maybe
import           Prelude
import qualified Test.Data.IntMap.Internal as Internal
import           Test.Unit                 (Test (), test)
import           Test.Unit.Assert          as Assert

(>|) :: forall a b . a -> (a -> b) -> b
(>|) a f = f a

tests :: Test ()
tests = do
  test "Data.IntMap" do 
    Assert.equal Nothing (lookup 0 (empty :: IntMap Int))
    Assert.equal (Just 1234) (lookup 0 (insert 0 1234 empty))
    Assert.equal 
      (Just 1234) 
      (lookup 0 (   empty
                 >| insert 10 4321
                 >| insert 20 4321
                 >| insert 30 4321
                 >| insert 0 1234))
    Internal.tests
