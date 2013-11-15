module BackEnd.RecursiveDir
  ( getRecursiveContents
  , getFileWithRelativePath ) where

import Control.Applicative ((<$>),(<*>))
import Control.Monad (forM)
import System.Directory (getDirectoryContents, doesDirectoryExist, getPermissions, Permissions(..))
import System.FilePath.Posix

infixr 5 $.
($.) :: (a -> b) -> a -> b
($.) = ($)

getValidContents :: FilePath -> IO [String]
getValidContents path =
    filter (`notElem` [".", "..", ".git", ".svn"]) <$> getDirectoryContents path

isSearchableDir :: FilePath -> IO Bool
isSearchableDir dir =
    (&&) <$> doesDirectoryExist dir
         <*> (searchable <$> getPermissions dir)

getRecursiveContents :: FilePath -> IO [FilePath]
getRecursiveContents dir = do
  cnts <- map (dir </>) <$> getValidContents dir
  concat <$> forM cnts $. \path -> do
    isDirectory <- isSearchableDir path
    if isDirectory
      then getRecursiveContents path
      else return [path]

getFileWithRelativePath :: FilePath -> IO [FilePath]
getFileWithRelativePath path = do
  contents <- getRecursiveContents path
  return $ map (makeRelative path) contents
