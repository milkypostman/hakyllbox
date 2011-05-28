{-# LANGUAGE OverloadedStrings #-}
import Data.Char (isSpace)
import GHC.Exts (IsString, fromString)
import Data.Maybe (listToMaybe)
import Control.Arrow ((>>>), arr)
import Control.Monad (forM_)
import Data.Monoid (mempty, mconcat)
import Data.Ord (comparing)
import Data.List (sortBy)
import System.FilePath

import Text.Regex.PCRE ((=~~), (=~))

import Hakyll

main :: IO ()
main = hakyll $ do
  match "css/*" $ do
    route $ setExtension "css"
    compile compressCssCompiler

  match "imgs/*" $ do
    route idRoute
    compile copyFileCompiler

  match "templates/*" $ compile templateCompiler

  -- match "index.md" $ do
  --   route $ setExtension "html"
  --   compile $ pageCompiler
  --     >>> applyTemplateCompiler "templates/base.html"
  --     >>> relativizeUrlsCompiler

  match "brain/*.md" $ do
    route $ composeRoutes cleanDate cleanURL
    compile $ pageCompiler
      >>> applyTemplateCompiler "templates/base.html"
      >>> relativizeUrlsCompiler

  -- group "raw" $ do
  --   match "brain/*.md" $ do
  --     route idRoute
  --     compile $ readPageCompiler

  match "index.html" $ route idRoute
  create "index.html" $ constA mempty
    >>> arr (setField "title" "brains")
    >>> requireAllA "brain/*.md" postList
    >>> applyTemplateCompiler "templates/thoughts.html"
    >>> applyTemplateCompiler "templates/base.html"
    >>> relativizeUrlsCompiler

cleanURL :: Routes
cleanURL = customRoute fileToDirectory

fileToDirectory :: Identifier -> FilePath
fileToDirectory = (flip combine) "index.html" . dropExtension . toFilePath

cleanDate :: Routes
cleanDate = customRoute removeDatePrefix

removeDatePrefix :: Identifier -> FilePath
removeDatePrefix = concatHeadTail . flip (=~) ("\\d{12}-" :: String) . toFilePath
-- removeDatePrefix = concatHeadTail . flip (=~) ("\\d{4}-\\d{2}-\\d{2}_\\d{2}:\\d{2}-" :: String) . toFilePath

concatHeadTail :: (String,String,String) -> String
concatHeadTail (a,_,c) = combine a c

stripIndexLink :: Page a -> Page a
stripIndexLink = changeField "url" dropFileName

postList :: Compiler (Page String, [Page String]) (Page String)
postList = buildList "thoughts" "templates/thought.html"

sortByCreatedField :: [Page a] -> [Page a]
sortByCreatedField = sortBy $ comparing $ getField "created"

buildList :: String -> Identifier -> Compiler (Page String, [Page String]) (Page String)
buildList field template = setFieldA field $
    arr (reverse . sortByBaseName)
    >>> arr (map stripIndexLink)
    >>> require template (\p t -> map (applyTemplate t) p)
    >>> arr mconcat
    >>> arr pageBody