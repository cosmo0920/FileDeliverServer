import System.Directory
import System.IO
import System.FSNotify
import System.Exit
import Control.Monad
import Control.Concurrent
import Prelude hiding (catch)
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
  putStrLn $ "[base path] " ++ base
  setCurrentDirectory monitor

  iref <- newIORef (""::Value)
  _ <- forkIO $ generateJson setting iref

  putStrLn $ "[watch] " ++ monitor
  man <- startManager
  forever $ do
    _ <- forkIO $ monitorRecursive setting man iref

    _ <- forkIO $ scottyServer setting iref

    putStrLn "input 'quit' to quit"
    line <- getLine
    when (line == "quit") $ do
      putStrLn "watching stopped"
      stopManager man
      putStrLn "quit"
      exitSuccess
