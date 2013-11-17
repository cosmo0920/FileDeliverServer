module BackEnd.Type
  ( ServerSetting(..)
  , serverSetting ) where
import Prelude
import BackEnd.Settings

data ServerSetting = ServerSetting {
                       basePath    :: String
                     , serverPort  :: Int
                     , monitorPath :: String
                     , jsonPath    :: String
                     , monitorOnly :: Bool
                     } deriving (Show)

serverSetting :: IO ServerSetting
serverSetting = do
  base            <- basepath
  serverport      <- port
  monitor         <- monitorpath
  json            <- jsonpath
  eventMonitor    <- monitoronly
  return ServerSetting {
           basePath    = base
         , serverPort  = serverport
         , monitorPath = monitor
         , jsonPath    = json
         , monitorOnly = eventMonitor
         }