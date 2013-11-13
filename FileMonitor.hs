import System.Directory
import System.IO
import Filesystem hiding (readFile)
import qualified Filesystem.Path.Rules as FR
import qualified Filesystem.Path.CurrentOS as FP
import System.FSNotify
import Control.Monad
import Control.Monad.IO.Class
import Control.Concurrent
import System.Exit
import Web.Scotty
import Network.Wai.Middleware.Static
import RecursiveDir
import MkJson
import CalcSHA

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
                   contentsSHA1 <- showSHA1 $ FP.encodeString dir'
                   putStrLn $ "Modified: "  ++ show contentsSHA1
        Added     dir' _ -> do
                   contentsSHA1 <- showSHA1 $ FP.encodeString dir'
                   putStrLn $ "Added: " ++ show contentsSHA1
        Removed   dir' _ -> do
                   putStrLn $ "Removed: " ++ show dir'
    _ <- forkIO $ scotty 3001 $ do
      currentDir <- liftIO $ getCurrentDirectory
      middleware $ staticPolicy $ addBase currentDir
      get "/assetlist.json" $ do
        directory <- liftIO $ getCurrentDirectory
        filesRelative <- liftIO $ getFileWithRelativePath directory
        json (showValue filesRelative)
    -- _ <- forkIO $ do
    --   directory <- getCurrentDirectory
    --   filesRelative <- getFileWithRelativePath directory
    --   putStrLn $ show $ calcSHA filesRelative

    putStrLn "input 'quit' to quit"
    line <- getLine
    when (line == "quit") $ do
      putStrLn "watching stopped"
      stopManager man
      putStrLn "quit"
      exitSuccess
