module BackEnd.FileUtil where
import System.Directory
import System.IO
import Control.Exception
#if __GLASGOW_HASKELL__ <= 704
import Prelude hiding (catch)
import System.IO.Error hiding (catch)
#else
import Prelude
import System.IO.Error
#endif

removeIfExists :: FilePath -> IO ()
removeIfExists fileName = removeFile fileName `catch` handleExists
  where handleExists e
          | isDoesNotExistError e = return ()
          | otherwise = throwIO e
