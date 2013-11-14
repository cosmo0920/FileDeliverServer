module MkJson where
import Control.Applicative (Applicative,pure,(<$>),(<*>))
import Control.Monad (mzero,(=<<),(<=<),(>=>))
import Data.Aeson
import Data.Aeson.Types
import Data.Either.Utils (forceEither)
import Data.Maybe (catMaybes)
import Data.Text (Text)
import qualified Data.Attoparsec as AP (Result(..),parseOnly)
import qualified Data.Attoparsec.Number as N (Number(I,D))
import qualified Data.ByteString.Lazy.Char8 as LC (unpack)
import qualified Data.HashMap.Strict as HM
import qualified Data.Text as T
import qualified Filesystem.Path.CurrentOS as FP
import CalcSHA

s :: String -> String
s = id

assetList :: FilePath -> Value
assetList path = do
  object [ T.pack path .= (unsafeShowSHA path) ]

value :: [FilePath] -> Value
value path = do
  let sha1 = calcSHA path
  object [ "files" .= map s (zipWith (++) path (calcSHA path))]

showValue :: [FilePath] -> String
showValue = LC.unpack . encode . value

remove :: Text -> Value -> Parser Value
remove key val = Object . HM.delete key <$> parseJSON val

-- modify :: a ->  v -> HM.HashMap a v -> HM.HashMap a v
modify key val =  HM.adjust key <$> parseJSON val

add key val = HM.insert key <$> parseJSON val

forceResult :: Result t -> t
forceResult (Success v) = v

dropValue :: FP.FilePath -> Value -> Value
dropValue dir fileValue = do
  forceResult $ parse (remove (T.pack $ FP.encodeString dir)) fileValue

-- modifyValue :: FP.FilePath -> Value -> Value
-- modifyValue dir fileValue = do
--   forceResult $ parse (modify (T.pack $ FP.encodeString dir)) fileValue
