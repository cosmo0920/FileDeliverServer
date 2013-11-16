module BackEnd.Monitor where
import qualified Filesystem.Path.CurrentOS as FP
import System.FilePath
import System.FSNotify
import Prelude hiding (catch)
import BackEnd.Type

monitorRecursive :: ServerSetting -> WatchManager -> IO ()
monitorRecursive ServerSetting{..} man = do
  let relativeDir workdir = makeRelative monitorPath (FP.encodeString workdir)
  watchTree man (FP.decodeString monitorPath) (const True) $ \event ->
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
