{-# LANGUAGE OverloadedStrings #-}
import Data.Char (isSpace)
import GHC.Exts (IsString, fromString)

import Data.List (intercalate)
import Data.Maybe (listToMaybe, fromJust)
import Control.Arrow ((>>>), arr)
import Control.Monad (forM_)
import Data.Char (toLower)
import Data.Maybe (fromMaybe)
import Data.Monoid (mempty, mconcat)
import Data.Ord (comparing)
import Data.List (sortBy)
import System.FilePath
import Data.Time.Format (parseTime, formatTime)
import Data.Time.Clock (UTCTime)
import System.Locale (TimeLocale, defaultTimeLocale)

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

  match "projects/*/*.md" $ do
    route $ setRoot `composeRoutes` cleanURL
    compile $ pageCompiler
      >>> arr addPosted
      >>> arr (changeField "url" $ dropFileName)
      >>> arr (changeField "title" $ map toLower)
      >>> applyTemplateCompiler "templates/base.html"
      >>> relativizeUrlsCompiler

  match "index.html" $ route idRoute
  create "index.html" $ constA mempty
    >>> arr (setField "title" "brains")
    >>> requireAllA "projects/nix/*.md" (buildList "nix")
    >>> requireAllA "projects/cooking/*.md" (buildList "cooking")
    >>> applyTemplateCompiler "templates/front.html"
    >>> applyTemplateCompiler "templates/base.html"
    >>> relativizeUrlsCompiler

  match "rss/index.html" $ route idRoute
  create "rss/index.html" $ requireAll_ "brain/*.md"
    >>> renderRss feedConfiguration


feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "milkbox.net"
    , feedDescription = "pointless yammering"
    , feedAuthorName  = "milkypostman"
    , feedRoot        = "http://milkbox.net"
    }

setRoot :: Routes
setRoot = customRoute stripTopDir

stripTopDir :: Identifier () -> FilePath
stripTopDir = joinPath . tail . splitPath . toFilePath

cleanURL :: Routes
cleanURL = customRoute fileToDirectory

fileToDirectory :: Identifier () -> FilePath
fileToDirectory = (flip combine) "index.html" . dropExtension . toFilePath

addPosted :: Page a -> Page a
addPosted p = flip (setField "posted") p .
              reformatTime "%Y-%m-%d-%H%M" "%Y.%m.%d;%H:%M" $
              intercalate "-" $ take 4 $ splitAll "-" $ takeFileName $ getField "path" p

reformatTime :: String -> String -> String -> String
reformatTime old new value = case parsed of
  Just parsed -> formatTime defaultTimeLocale new parsed
  Nothing     -> value
  where
    parsed = parseTime defaultTimeLocale old value :: Maybe UTCTime


buildList :: String -> Compiler (Page String, [Page String]) (Page String)
buildList field = setFieldA field $
    arr (reverse . chronological)
    >>> require "templates/itemlink.html" (\p t -> map (applyTemplate t) p)
    >>> arr mconcat
    >>> arr pageBody
