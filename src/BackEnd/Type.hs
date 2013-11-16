module BackEnd.Type where
import Prelude
import BackEnd.Settings

data ServerSetting = ServerSetting {
                       basePath    :: String
                     , serverPort  :: Int
                     , monitorPath :: String
                     , jsonPath    :: String
                     } deriving (Show)

serverSetting :: IO ServerSetting
serverSetting = do
  base       <- basepath
  serverport <- port
  monitor    <- monitorpath
  json       <- jsonpath
  return ServerSetting {
           basePath    = base
         , serverPort  = serverport
         , monitorPath = monitor
         , jsonPath    = json
         }