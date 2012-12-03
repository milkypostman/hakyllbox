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
main = hakyllWith config $ do
  match "css/*" $ do
    route $ setExtension "css"
    compile compressCssCompiler

  match "imgs/*" $ do
    route idRoute
    compile copyFileCompiler

  match "stuff/*" $ do
    route idRoute
    compile copyFileCompiler

  match "imgs/icons/*" $ do
    route idRoute
    compile copyFileCompiler

  match "_layouts/*" $ compile templateCompiler

  match "projects.md" $ do
    compile $ pageCompiler

  match "_drafts/*.md" $ do
    route $ cleanDate `composeRoutes` cleanURL
    compile $ pageCompiler
      >>> arr (copyBodyToField "content")
      >>> arr (renderDateField "date" "%Y-%m-%d" "Date unknown")
      >>> arr (changeField "url" $ dropFileName)
      >>> applyTemplateCompiler "_layouts/post.html"
      >>> applyTemplateCompiler "_layouts/base.html"
      >>> relativizeUrlsCompiler

  match "_posts/*.md" $ do
    route $ setRoot `composeRoutes` cleanDate `composeRoutes` cleanURL
    compile $ pageCompiler
      >>> arr (copyBodyToField "content")
      >>> arr (renderDateField "date" "%Y-%m-%d" "Date unknown")
      >>> arr (changeField "url" $ dropFileName)
      >>> applyTemplateCompiler "_layouts/post.html"
      >>> applyTemplateCompiler "_layouts/base.html"
      >>> relativizeUrlsCompiler

  match "index.html" $ route idRoute
  create "index.html" $ constA mempty
    >>> arr (setField "title" "net")
    >>> setFieldPageList recentFirst "_layouts/postlink.html" "posts" "_posts/*.md"
    >>> setFieldPage "projects" "projects.md"
    >>> applyTemplateCompiler "_layouts/index.html"
    >>> applyTemplateCompiler "_layouts/base.html"
    >>> relativizeUrlsCompiler

  match "feed/index.html" $ route idRoute
  create "feed/index.html" $ requireAll_ "_posts/*.md"
    >>> arr (map $ copyField "content" "description")
    >>> renderRss feedConfiguration

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "milkbox.net"
    , feedDescription = "pointless yammering"
    , feedAuthorName  = "milkypostman"
    , feedAuthorEmail = "contact@milkbox.net"
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


config :: HakyllConfiguration
config = defaultHakyllConfiguration
    { deployCommand = "find _site/ -type d -exec chmod go+x {} \\;; chmod -R go+r _site; rsync -avz --delete _site/* milkbox.net:milkbox"
    }
