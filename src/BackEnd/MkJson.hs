module BackEnd.MkJson
  ( assetList
  , value
  , showValue ) where
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as LC (unpack)
import qualified Data.Text as T
import BackEnd.CalcSHA

assetList :: FilePath -> Value
assetList path = do
  object [ T.pack path .= (unsafeShowSHA path) ]

value :: [FilePath] -> Value
value path = do
  object [ "files" .= (map assetList path) ]

showValue :: [FilePath] -> String
showValue = LC.unpack . encode . value
