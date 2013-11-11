import System.Directory
import System.IO
import Filesystem hiding (readFile)
import qualified Filesystem.Path.Rules as FR
import qualified Filesystem.Path.CurrentOS as FP
import System.FSNotify
import Data.Digest.Pure.SHA
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text                  as T
import Data.Text.Encoding
import Control.Monad
import Control.Concurrent
import System.Exit
import Web.Scotty
import Encode
import RecursiveDir

main :: IO ()
main = do
  hSetBuffering stdin NoBuffering
  hFlush stdout
  dir <- getCurrentDirectory
  let path = FP.decodeString dir
  putStrLn $ "[path] " ++ FP.encodeString path
  setCurrentDirectory $ FP.encodeString path
  wd <- getWorkingDirectory
  putStrLn $ "[watch] " ++ show wd
  man <- startManager
  forever $ do
    _ <- forkIO $ watchTree man wd (const True) $ \event ->
      case event of
        Modified  dir' _ -> do
                   contentsSHA1 <- showSHA1 dir'
                   putStrLn $ "Modified: " ++ show contentsSHA1
        Added     dir' _ -> do
                   contentsSHA1 <- showSHA1 dir'
                   putStrLn $ "Added: " ++ show contentsSHA1
        Removed   dir' _ -> do
                   putStrLn $ "Removed: " ++ show dir'
    _ <- forkIO $ scotty 3001 $ do
      get "/assetlist.json" $ do
        json ("Scotty, up!" :: String)
    _ <- forkIO $ do
      directory <- getCurrentDirectory
      filesRelative <- getFileWithRelativePath directory
      putStrLn $ show filesRelative

    putStrLn "input 'quit' to quit"
    line <- getLine
    when (line == "quit") $ do
      putStrLn "watching stopped"
      stopManager man
      putStrLn "quit"
      exitSuccess

sha1Digest :: String -> String
sha1Digest = showDigest . sha1 . fromStrict' . encodeUtf8 . T.pack

showSHA1 :: FP.FilePath -> IO String
showSHA1 dir = do
  content <- readFile $ FP.encodeString dir
  let digest = sha1Digest content
  return digest
