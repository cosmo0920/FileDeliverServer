module BackEnd.Server
  ( scottyServer ) where
import Web.Scotty
import Network.Wai.Middleware.Static
import Network.Wai.Middleware.RequestLogger
import Data.IORef
import Data.Aeson (ToJSON)
import Control.Monad.IO.Class
import BackEnd.Type

scottyServer :: ToJSON a => ServerSetting -> IORef a -> IO ()
scottyServer ServerSetting{..} iref = do
  scotty serverPort $ do
    middleware logStdoutDev
    middleware $ staticPolicy $ noDots >-> addBase monitorPath
    get "/filelist.json" $ do
      fileValue <- liftIO $ readIORef iref
      json (fileValue)