
module UiFi.Markup.Attr where

-- | Nothing complex here, but usually this is to be used opaquely.
newtype Attr 
  = Attr 
  { name :: String
  , value :: String 
  }
