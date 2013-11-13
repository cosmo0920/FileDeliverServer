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
import qualified Data.Map as M (lookup,delete)
import CalcSHA

s :: String -> String
s = id

value :: [FilePath] -> Value
value path = do
  let sha1 = calcSHA path
  object [ "files" .= map s (zipWith (++) path (calcSHA path))]

showValue :: [FilePath] -> String
showValue = LC.unpack . encode . value
