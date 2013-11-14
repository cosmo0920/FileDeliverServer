import System.Directory
import System.IO
import Filesystem hiding (readFile, removeFile)
import qualified Filesystem.Path.Rules as FR
import qualified Filesystem.Path.CurrentOS as FP
import System.FSNotify
import Control.Monad
import Control.Monad.IO.Class
import Control.Concurrent
import Control.Exception
import System.Exit
import Web.Scotty
import Network.Wai.Middleware.Static
import Prelude hiding (catch)
import System.IO.Error hiding (catch)
import RecursiveDir
import MkJson

main :: IO ()
main = do
  let jsonfile = "filelist.json"
  removeIfExists jsonfile
  dir <- getCurrentDirectory
  let path = FP.decodeString dir
  putStrLn $ "[path] " ++ FP.encodeString path
  setCurrentDirectory $ FP.encodeString path
  mv <- newEmptyMVar
  wd <- getWorkingDirectory
  _ <- forkIO $ do
     threadDelay 3000
     relative <- liftIO $ getFileWithRelativePath dir
     removeIfExists jsonfile
     System.IO.writeFile jsonfile $ showValue relative
     putMVar mv $ value relative
     putStrLn $ "[genarate] " ++ jsonfile

  putStrLn $ "[watch] " ++ show wd
  man <- startManager
  forever $ do
    _ <- forkIO $ do
      let relativeDir workdir = makeRelative dir (FP.encodeString workdir)
      watchTree man wd (const True) $ \event ->
        case event of
          Modified  dir' _ -> do
            let added = relativeDir dir'
            putStrLn $ "Modified: "  ++ show added
          Added     dir' _ -> do
            let modified = relativeDir dir'
            putStrLn $ "Added: " ++ show modified
          Removed   dir' _ -> do
            let removed = relativeDir dir'
            putStrLn $ "Removed: " ++ show removed

    _ <- forkIO $ scotty 3001 $ do
      currentDir <- liftIO $ getCurrentDirectory
      middleware $ staticPolicy $ addBase currentDir
      get "/filelist.json" $ do
        fileValue <- liftIO $ takeMVar mv
        json (fileValue)

    putStrLn "input 'quit' to quit"
    line <- getLine
    when (line == "quit") $ do
      putStrLn "watching stopped"
      stopManager man
      putStrLn "quit"
      exitSuccess

removeIfExists :: FilePath -> IO ()
removeIfExists fileName = removeFile fileName `catch` handleExists
  where handleExists e
          | isDoesNotExistError e = return ()
          | otherwise = throwIO e
