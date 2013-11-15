module BackEnd.FileUtil where
import System.Directory
import System.IO
import System.IO.Error hiding (catch)
import Control.Exception
#if __GLASGOW_HASKELL__ <= 704
import Prelude hiding (catch)
#else
import Prelude
#endif

removeIfExists :: FilePath -> IO ()
removeIfExists fileName = removeFile fileName `catch` handleExists
  where handleExists e
          | isDoesNotExistError e = return ()
          | otherwise = throwIO e
