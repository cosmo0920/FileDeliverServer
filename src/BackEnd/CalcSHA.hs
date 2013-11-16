module BackEnd.CalcSHA where
import Data.Digest.Pure.SHA
import System.IO.Unsafe
import qualified Data.ByteString.Lazy.Char8 as BL

shaDigest :: BL.ByteString -> String
shaDigest = showDigest . sha256

showSHA :: FilePath -> IO String
showSHA dir = do
  content <- BL.readFile dir
  let digest = shaDigest content
  return digest

unsafeShowSHA :: FilePath -> String
unsafeShowSHA dir = unsafePerformIO $ do
  content <- BL.readFile dir
  let digest = shaDigest content
  return digest
