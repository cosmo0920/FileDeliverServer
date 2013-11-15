import System.Directory
import System.IO
import qualified Filesystem.Path.CurrentOS as FP
import System.FilePath.Posix
import System.FSNotify
import System.Exit
import Control.Monad
import Control.Monad.IO.Class
import Control.Concurrent
import Web.Scotty
import Network.Wai.Middleware.Static
import Network.Wai.Middleware.RequestLogger
import Prelude hiding (catch)
import Data.IORef
import Data.Aeson (Value)
import BackEnd.RecursiveDir
import BackEnd.MkJson
import BackEnd.Settings
import BackEnd.FileUtil

main :: IO ()
main = do
  jsonfile <- jsonpath
  base <- basepath
  monitor <- monitorpath
  serverPort <- port
  putStrLn $ "[base path] " ++ base
  setCurrentDirectory monitor

  iref <- newIORef (""::Value)
  _ <- forkIO $ do
     removeIfExists jsonfile
     setCurrentDirectory monitor
     relative <- liftIO $ getFileWithRelativePath monitor
     writeFile jsonfile $ showValue relative
     writeIORef iref $ value relative
     putStrLn $ "[genarate] " ++ jsonfile

  putStrLn $ "[watch] " ++ monitor
  man <- startManager
  forever $ do
    _ <- forkIO $ do
      let relativeDir workdir = makeRelative monitor (FP.encodeString workdir)
      watchTree man (FP.decodeString monitor) (const True) $ \event ->
        case event of
          Modified  dir' _ -> do
            let added = relativeDir dir'
            putStr $ unlines [ "Modified: "  ++ show added
                               , "[notice] needs server reboot!!" ]
          Added     dir' _ -> do
            let modified = relativeDir dir'
            putStr $ unlines [ "Added: " ++ show modified
                               , "[notice] needs server reboot!!" ]
          Removed   dir' _ -> do
            let removed = relativeDir dir'
            putStr $ unlines [ "Removed: " ++ show removed
                               , "[notice] needs server reboot!!" ]

    _ <- forkIO $ scotty serverPort $ do
      middleware logStdoutDev
      middleware $ staticPolicy $ noDots >-> addBase monitor
      get "/filelist.json" $ do
        fileValue <- liftIO $ readIORef iref
        json (fileValue)

    putStrLn "input 'quit' to quit"
    line <- getLine
    when (line == "quit") $ do
      putStrLn "watching stopped"
      stopManager man
      putStrLn "quit"
      exitSuccess
