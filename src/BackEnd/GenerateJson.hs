module BackEnd.GenerateJson
  ( generateJson
  , generateJsonWithLock ) where
import System.Directory
import System.IO
import Control.Monad.IO.Class
#if __GLASGOW_HASKELL__ <= 704
import Prelude hiding (catch)
#else
import Prelude
#endif
import Data.IORef
import Data.Aeson (Value)
import BackEnd.Type
import BackEnd.FileUtil
import BackEnd.MkJson
import BackEnd.RecursiveDir
import BackEnd.Barrier

generateJson :: ServerSetting -> (IORef Value) -> IO ()
generateJson ServerSetting{..} iref = do
  removeIfExists jsonPath
  setCurrentDirectory monitorPath
  relative <- liftIO $ getFileWithRelativePath monitorPath
  writeFile jsonPath $ showValue relative
  writeIORef iref $ value relative
  putStrLn $ "[genarate] " ++ jsonPath

generateJsonWithLock :: ServerSetting -> (IORef Value) -> IO ()
generateJsonWithLock ServerSetting{..} iref = do
  removeIfExists jsonPath
  setCurrentDirectory monitorPath
  relative <- liftIO $ getFileWithRelativePath monitorPath
  writeIORef iref $ value relative
  bar <- newBarrier
  val <- writeFile jsonPath $ showValue relative
  signalBarrier bar val
  waitBarrier bar
  putStrLn $ "[genarate] " ++ jsonPath
