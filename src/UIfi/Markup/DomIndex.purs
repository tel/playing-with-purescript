
module UiFi.Markup.DomIndex where

import           Control.Apply     ((*>))
import           Control.Monad     (when)
import           Control.Monad.Eff
import           Control.Monad.ST
import qualified Data.Array        as A
import           Data.Array.Unsafe (unsafeIndex)
import           Data.IntMap       (IntMap ())
import qualified Data.IntMap       as IntMap
import           Data.Monoid
import           Data.Tuple        (Tuple (Tuple))
import           DOM.HTML.Types    (HTMLElement ())
import           Prelude
import           UiFi.Markup.Node

domIndex :: Array Int -> HTMLElement -> Node -> IntMap HTMLElement
domIndex indices real0 virt0 = pureST do
  let targets = A.sort indices
  ix <- newSTRef 0
  nodeMap <- newSTRef IntMap.empty
  let go real virt = do
        ixHere <- readSTRef ix
        when (find ixHere targets) do
          modifySTRef nodeMap (IntMap.insert ixHere real)
          pure unit
        modifySTRef ix (+1)
        case virt of
          Text _ -> do 
            pure unit
          Element s -> do
            nTimes (A.length s.children) $ \n -> do
              let vchild = unsafeIndex s.children n
                  rchild = childAt n real
              if containsInRange (ixHere + 1) (ixHere + size vchild) targets
                 then do
                   go rchild vchild 
                 else do 
                   modifySTRef ix (\a -> a + size vchild) 
                   pure unit
        pure unit
  go real0 virt0
  readSTRef nodeMap


nTimes :: forall f a . (Applicative f) => Int -> (Int -> f a) -> f Unit
nTimes max act = go 0 where
  go n | n < max = act n *> go (n+1)
       | otherwise = pure unit

--
-- domIndex :: Array Int -> HTMLElement -> Node -> IntMap HTMLElement
-- domIndex indices realTree virtualTree = 
--   case go realTree virtualTree (Tuple 0 IntMap.empty) of
--     Tuple _ix elmap -> elmap
--   where
--     -- step the index forward one and maybe add the current node
--     localStep :: HTMLElement -> Arr
--     localStep real (Tuple ix nodes) = 
--       Tuple (ix + 1) $ if find ix indices 
--                           then IntMap.insert ix real nodes
--                           else nodes
--
--     -- for each child, if any, step through the whole subtree
--     childSteps :: HTMLElement -> Node -> Arr
--     childSteps real virt (Tuple ix nodes) = 
--       case virt of
--         Text _ -> Tuple (ix + size virt) nodes
--         Element s -> 
--           let nChildren = A.length (s.children)
--            in forN nChildren (Tuple ix nodes) \n ->
--                 go (childAt n real) (unsafeIndex s.children n)
--
--     go :: HTMLElement -> Node -> Arr
--     go real virt (Tuple ix nodes) = 
--       -- if we already know there aren't any targets down here, let's skip the
--       -- whole thing
--       if containsInRange ix (ix + size virt - 1) indices
--          then childSteps real virt <<< localStep real $ Tuple ix nodes
--          else Tuple (ix + size virt) nodes

foreign import childAt :: Int -> HTMLElement -> HTMLElement

-- | Determine if an element is in a sorted array via binary search.
find :: forall a . (Ord a) => a -> Array a -> Boolean
find val = containsInRange val val

-- | Do any values in the (sorted!) array lie between these two low and high marks?
containsInRange :: forall a . (Ord a) => a -> a -> Array a -> Boolean
containsInRange low hi a = go 0 (A.length a - 1) where
  -- go explores the array via progressively shrinking index slices. Each time
  -- we pick a value in the middle of the endpoints of the slice and then either
  -- return or refine the slice by halfing it. Runtime is thus log2(n).
  go min max =
    case max - min of
      0 -> let val = unsafeIndex a min
            in val >= low && val <= hi
      1 -> let v1 = unsafeIndex a min
               v2 = unsafeIndex a max
            in (v1 >= low && v1 <= hi) || (v2 >= low && v2 <= hi)
      diff 
        | diff < 0 -> false
        | otherwise -> 
            let ix = (min + max) `div` 2
                val = unsafeIndex a ix
             in if val < low
                   then go ix max
                   else if val > hi
                           then go min ix
                           else true
