import System.Directory
import System.IO
import System.FSNotify
import System.Exit
import Control.Monad
import Control.Concurrent
#if __GLASGOW_HASKELL__ <= 704
import Prelude hiding (catch)
#else
import Prelude
#endif
import Data.IORef
import Data.Aeson (Value)
import BackEnd.Settings
import BackEnd.Type
import BackEnd.Server
import BackEnd.Monitor
import BackEnd.GenerateJson

main :: IO ()
main = do
  base <- basepath
  monitor <- monitorpath
  setting <- serverSetting
  usage
  putStrLn $ "[base path] " ++ base
  setCurrentDirectory monitor

  iref <- newIORef (""::Value)
  _ <- forkIO $ generateJson setting iref

  putStrLn $ "[watch] " ++ monitor
  man <- startManager
  forever $ do
    _monitorThread <- forkIO $ monitorRecursive setting man iref

    _serverThread <- forkIO $ scottyServer setting iref

    line <- getLine
#if !defined(mingw32_HOST_OS) && !defined(_WIN32)
    mapM_ killThread [_monitorThread, _serverThread]
#endif
    when (line == "quit" || line == "q") $ do
      putStrLn "watching stopped"
      stopManager man
      putStrLn "quit"
      exitSuccess
    when (line == "json" || line == "j") $ do
      _ <- forkIO $ generateJson setting iref
      putStrLn "[notice] regenerate JSON"

usage :: IO ()
usage = do
  putStr $ unlines [ "[usage] input 'quit' or 'q' to quit"
                   , "[usage] input 'json' or 'j' to regenerate JSON and IORef value" ]