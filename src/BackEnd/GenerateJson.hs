module BackEnd.GenerateJson where
import System.Directory
import System.IO
import Control.Monad.IO.Class
import Prelude hiding (catch)
import Data.IORef
import Data.Aeson (Value)
import BackEnd.Type
import BackEnd.FileUtil
import BackEnd.MkJson
import BackEnd.RecursiveDir

generateJson :: ServerSetting -> (IORef Value) -> IO ()
generateJson ServerSetting{..} iref = do
  removeIfExists jsonPath
  setCurrentDirectory monitorPath
  relative <- liftIO $ getFileWithRelativePath monitorPath
  writeFile jsonPath $ showValue relative
  writeIORef iref $ value relative
  putStrLn $ "[genarate] " ++ jsonPath
