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

  match "_layouts/*" $ compile templateCompiler

  match "_posts/recipes/*.md" $ do
    route $ setRoot `composeRoutes` cleanDate `composeRoutes` cleanURL
    compile $ pageCompiler
      >>> arr (copyBodyToField "content")
      >>> arr (renderDateField "date" "%Y-%m-%d" "Date unknown")
      >>> arr (changeField "url" $ dropFileName)
      >>> arr (changeField "title" $ map toLower)
      >>> applyTemplateCompiler "_layouts/base.html"
      >>> relativizeUrlsCompiler

  match "_posts/unix/*.md" $ do
    route $ setRoot `composeRoutes` cleanDate `composeRoutes` cleanURL
    compile $ pageCompiler
      >>> arr (copyBodyToField "content")
      >>> arr (renderDateField "date" "%Y-%m-%d" "Date unknown")
      >>> arr (changeField "url" $ dropFileName)
      >>> arr (changeField "title" $ map toLower)
      >>> applyTemplateCompiler "_layouts/base.html"
      >>> relativizeUrlsCompiler

  match "index.html" $ route idRoute
  create "index.html" $ constA mempty
    >>> arr (setField "title" "net")
    >>> setFieldPageList (take 1 . recentFirst) "_layouts/item.html" "postfirst" "_posts/*.md"
    >>> setFieldPageList (tail . recentFirst) "_layouts/itemlink.html" "recipes" "_posts/recipes/*.md"
    >>> setFieldPageList (tail . recentFirst) "_layouts/itemlink.html" "unix" "_posts/unix/*.md"
    >>> applyTemplateCompiler "_layouts/front.html"
    >>> applyTemplateCompiler "_layouts/base.html"
    >>> relativizeUrlsCompiler

  match "feed/index.html" $ route idRoute
  create "feed/index.html" $ requireAll_ "_posts/*/*.md"
    >>> arr (map $ copyField "content" "description")
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

cleanDate :: Routes
cleanDate = customRoute removeDatePrefix

removeDatePrefix :: Identifier () -> FilePath
removeDatePrefix ident = replaceFileName file (drop 11 $ takeFileName file)
  where file = toFilePath ident
                               
