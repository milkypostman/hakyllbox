{-# LANGUAGE OverloadedStrings #-}
import Control.Arrow ((>>>), arr)
import Control.Monad (forM_)
import Data.Monoid (mempty, mconcat)
import System.FilePath

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

  match "index.md" $ do
    route $ setExtension "html"
    compile $ pageCompiler
      >>> applyTemplateCompiler "templates/base.html"
      >>> relativizeUrlsCompiler

  match "brain/*.md" $ do
    route $ cleanURL
    compile $ pageCompiler
      >>> applyTemplateCompiler "templates/base.html"

  match "brain/index.html" $ route idRoute
  create "brain/index.html" $ constA mempty
    >>> arr (setField "title" "brains")
    >>> requireAllA "brain/***.md" postList
    >>> applyTemplateCompiler "templates/thoughts.html"
    >>> applyTemplateCompiler "templates/base.html"



cleanURL :: Routes
cleanURL = customRoute fileToDirectory

fileToDirectory :: Identifier -> FilePath
fileToDirectory = (flip combine) "index.html" . dropExtension . toFilePath

stripIndexLink :: Page a -> Page a
stripIndexLink = changeField "url" dropFileName

postList :: Compiler (Page String, [Page String]) (Page String)
postList = buildList "thoughts" "templates/thought.html"

buildList :: String -> Identifier -> Compiler (Page String, [Page String]) (Page String)
buildList field template = setFieldA field $
    arr (reverse . sortByBaseName)
        >>> require template (\p t -> map (applyTemplate t) p)
        >>> arr mconcat
        >>> arr pageBody