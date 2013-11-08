import System.Directory
import System.IO
import Filesystem hiding (readFile)
import qualified Filesystem.Path.CurrentOS as FP
import System.FSNotify
import Data.Digest.Pure.SHA
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text                  as T
import Data.Text.Encoding
import Encode

main :: IO ()
main = do
  dir <- getCurrentDirectory
  setCurrentDirectory dir
  wd <- getWorkingDirectory
  print wd
  man <- startManager
  watchTree man wd (const True) $ \event ->
    case event of
      Modified  dir' _ -> do
                 contentsSHA1 <- showSHA1 dir'
                 putStrLn $ "Modified: " ++ show contentsSHA1
      Added     dir' _ -> do
                 contentsSHA1 <- showSHA1 dir'
                 putStrLn $ "Added: " ++ show contentsSHA1
      Removed   dir' _ -> do
                 putStrLn $ "Removed: " ++ show dir'

  print "press retrun to stop"
  getLine
  print "watching stopped, press retrun to exit"
  stopManager man
  getLine
  return ()

sha1Digest :: String -> String
sha1Digest = showDigest . sha1 . fromStrict' . encodeUtf8 . T.pack

showSHA1 :: FP.FilePath -> IO String
showSHA1 dir = do
  content <- readFile $ FP.encodeString dir
  let digest = sha1Digest content
  return digest