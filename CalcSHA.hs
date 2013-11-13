module CalcSHA where
import Data.Digest.Pure.SHA
import System.IO.Unsafe
import qualified Data.ByteString.Lazy.Char8 as BL

sha1Digest :: BL.ByteString -> String
sha1Digest = showDigest . sha1

showSHA1 :: FilePath -> IO String
showSHA1 dir = do
  content <- BL.readFile dir
  let digest = sha1Digest content
  return digest

showSHA1WithSep' :: FilePath -> String
showSHA1WithSep' dir = unsafePerformIO $ do
  content <- BL.readFile dir
  let digest = sha1Digest content
  return $ "," ++ digest

calcSHA :: [FilePath] -> [String]
calcSHA dir = do
  map showSHA1WithSep' dir
