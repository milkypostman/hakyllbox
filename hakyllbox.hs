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

  match "imgs/icons/*" $ do
    route idRoute
    compile copyFileCompiler

  match "_layouts/*" $ compile templateCompiler

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
    >>> setFieldPageList (filter $ hasTag "linux") "_layouts/postlink.html" "linux" "_posts/*.md"
    >>> setFieldPageList recentFirst "_layouts/postlink.html" "posts" "_posts/*.md"
    >>> applyTemplateCompiler "_layouts/index.html"
    >>> applyTemplateCompiler "_layouts/base.html"
    >>> relativizeUrlsCompiler

  match "feed/index.html" $ route idRoute
  create "feed/index.html" $ requireAll_ "_posts/*.md"
    >>> arr (map $ copyField "content" "description")
    >>> renderRss feedConfiguration

  -- Tags
  create "tags" $
    requireAll "_posts/*.md" (\_ ps -> readTags ps :: Tags String)

  match "tags/*" $ route $ setExtension ".html"
  metaCompile $ require_ "tags"
    >>> arr tagsMap
    >>> arr (map (\(t, p) -> (tagIdentifier t, makeTagList t p)))

getTags :: Page a -> [String]
getTags = map trim . splitAll "," . getField "tags"

hasTag :: String -> Page a -> Bool
hasTag s p = elem s $ getTags p

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "milkbox.net"
    , feedDescription = "pointless yammering"
    , feedAuthorName  = "milkypostman"
    , feedRoot        = "http://milkbox.net"
    }

makeTagList :: String
            -> [Page String]
            -> Compiler () (Page String)
makeTagList tag posts =
    constA posts
        >>> pageListCompiler recentFirst "_layouts/postlink.html"
        >>> arr (copyBodyToField "posts" . fromBody)
        >>> arr (setField "title" ("posts tagged " ++ tag))
        >>> applyTemplateCompiler "_layouts/tag.html"
        >>> applyTemplateCompiler "_layouts/base.html"


renderTagList' :: Compiler (Tags String) String
renderTagList' = renderTagList tagIdentifier

tagIdentifier :: String -> Identifier (Page String)
tagIdentifier "linux" =  fromCapture "tags/*" "linux"
tagIdentifier _ =  fromCapture "tags/*" ""

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

