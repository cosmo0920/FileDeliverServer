module BackEnd.Monitor where
import qualified Filesystem.Path.CurrentOS as FP
import System.FilePath
import System.FSNotify
import Data.IORef
import Data.Aeson (Value)
import Prelude hiding (catch)
import BackEnd.Type
import BackEnd.GenerateJson

-- | TODO: avoid all JSON value update
monitorRecursive :: ServerSetting -> WatchManager -> IORef Value -> IO ()
monitorRecursive ServerSetting{..} man iref = do
  let relativeDir workdir = makeRelative monitorPath (FP.encodeString workdir)
  watchTree man (FP.decodeString monitorPath) (const True) $ \event ->
    case event of
      Modified  dir' _ -> do
        let added = relativeDir dir'
        monitorResult ServerSetting{..} "Modified: " added iref
      Added     dir' _ -> do
        let modified = relativeDir dir'
        monitorResult ServerSetting{..} "Added: " modified iref
      Removed   dir' _ -> do
        let removed = relativeDir dir'
        monitorResult ServerSetting{..} "Removed: " removed iref

monitorResult :: ServerSetting -> String -> String -> IORef Value -> IO ()
monitorResult ServerSetting{..} outStr file iref = do
  if monitorOnly then
    putStr $ unlines [ outStr ++ file
                     , "[notice] file(s) changed. it needs server reboot!!" ]
  else do
    putStrLn $ outStr ++ file
    generateJson ServerSetting{..} iref
