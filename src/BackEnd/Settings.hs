-- | Server setting
module BackEnd.Settings
  ( basepath
  , port
  , monitorpath
  , jsonpath ) where
import Prelude
import BackEnd.Util

basepath :: IO String
basepath = readSetting "basepath"
port :: IO Int
port     = readSettingInt "port"
monitorpath :: IO String
monitorpath = readSetting "monitorpath"
jsonpath :: IO String
jsonpath = do
  base <- readSetting "basepath"
  jsonfile <- readSetting "jsonpath"
  return $ base ++ "/" ++ jsonfile