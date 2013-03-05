{-# LANGUAGE OverloadedStrings #-}
import Data.Char (isSpace)
import GHC.Exts (IsString, fromString)

import Data.List (intercalate)
import Data.Maybe (listToMaybe, fromJust)
import Control.Arrow ((>>>), arr)
import Control.Monad (forM_)
import Data.Char (toLower)
import Data.Functor ((<$>))
import Data.Maybe (fromMaybe)
import Data.Monoid (mempty, mconcat, mappend)
import Data.Ord (comparing)
import Data.List (sortBy, isSuffixOf)
import System.FilePath
import Data.Time.Format (parseTime, formatTime)
import Data.Time.Clock (UTCTime)
import System.Locale (TimeLocale, defaultTimeLocale)

import Text.Regex.PCRE ((=~~), (=~))

import Hakyll

main :: IO ()
-- main = hakyllWith config $ do
main = hakyll $ do
  match "css/*" $ do
    route $ setExtension "css"
    compile compressCssCompiler

  match ("imgs/*" .||. "stuff/*" .||. "imgs/icons/*") $ do
    route idRoute
    compile copyFileCompiler

  match ("projects.md" .||. "about.md") $ do
    compile $ pandocCompiler

  match ("drafts/*.md" .||. "notes/*.md") $ do
    route $ cleanDate `composeRoutes` cleanURL
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/note.html" noteContext
      >>= loadAndApplyTemplate "templates/base.html" noteContext

  match "templates/*" $ compile templateCompiler

  create ["index.html"] $ do
    route idRoute
    compile $ do
      let indexContext =
            listField "notes" "notes/*.md" "templates/note-link.html" `mappend`
            fileField "projects" "projects.md" `mappend`
            fileField "about" "about.md" `mappend`
            defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/index.html" indexContext
        >>= loadAndApplyTemplate "templates/base.html" defaultContext
        >>= cleanIndexUrls


--   match "feed/index.html" $ route idRoute
--   create "feed/index.html" $ requireAll_ "_posts/*.md"
--     >>= arr (map $ copyField "content" "description")
--     >>= renderRss feedConfiguration

-- feedConfiguration :: FeedConfiguration
-- feedConfiguration = FeedConfiguration
--     { feedTitle       = "milkbox.net"
--     , feedDescription = "pointless yammering"
--     , feedAuthorName  = "milkypostman"
--     , feedAuthorEmail = "contact@milkbox.net"
--     , feedRoot        = "http://milkbox.net"
--     }

listField :: String -> Pattern -> Identifier -> Context a
listField name pattern template = field name $ \_ -> do
  collection <- recentFirst <$> loadAll pattern
  itemTpl <- loadBody template
  list <- applyTemplateList itemTpl defaultContext collection
  return list


fileField :: String -> Identifier -> Context String
fileField name file = field name $ \_ -> loadBody file

cleanIndexUrls :: Item String -> Compiler (Item String)
cleanIndexUrls = return . fmap (withUrls clean)
  where
    idx = "index.html"
    clean url
      | idx `isSuffixOf` url = take (length url - length idx) url
      | otherwise = url


noteContext :: Context String
noteContext = dateField "date" "%Y-%m-%d" `mappend`
              defaultContext

setRoot :: Routes
setRoot = customRoute stripTopDir

stripTopDir :: Identifier -> FilePath
stripTopDir = joinPath . tail . splitPath . toFilePath

cleanURL :: Routes
cleanURL = customRoute fileToDirectory

fileToDirectory :: Identifier -> FilePath
fileToDirectory = (flip combine) "index.html" . dropExtension . toFilePath

cleanDate :: Routes
cleanDate = customRoute removeDatePrefix

removeDatePrefix :: Identifier -> FilePath
removeDatePrefix ident = replaceFileName file (drop 11 $ takeFileName file)
  where file = toFilePath ident


-- config :: HakyllConfiguration
-- config = defaultHakyllConfiguration
--     { deployCommand = "find _site/ -type d -exec chmod go+x {} \\;; chmod -R go+r _site; rsync -avz --delete _site/* milkbox.net:milkbox"
--     }
