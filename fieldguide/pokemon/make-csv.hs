module Main (main) where

import Data.List (sort, zipWith4)
import Data.Fixed (Deci)
import Data.Char (toLower, isAlpha, isSpace)
import Data.Maybe (fromJust, mapMaybe)
import Control.Monad (forM, guard)

import Data.Csv hiding (lookup)
import qualified Data.ByteString.Char8 as B8
import qualified Data.ByteString.Lazy as BL
import qualified Data.Vector as V

main :: IO ()
main = do
  recs <- fmap toRows readPokémon
  let csv = encodeByName header recs
      header = V.fromList $ map B8.pack
        ["name", "display_name", "description", "height", "color"]
  BL.writeFile "species.csv" csv

data Pokémon = Pokémon
  { name        :: String
  , description :: String
  , height      :: Deci
  , color       :: Color
  } deriving (Eq, Ord, Show, Read)

data Color
  = Black | Blue | Brown | Gray | Green | Pink | Purple | Red | White | Yellow
  deriving (Eq, Ord, Show, Read, Enum, Bounded)

readPokémon :: IO [Pokémon]
readPokémon = do
  names   <- fmap lines              $ readFile "names.txt"
  descs   <- fmap lines              $ readFile "descriptions.txt"
  heights <- fmap (map read . lines) $ readFile "heights.txt"
  let allColors = [minBound .. maxBound] :: [Color]
  colorToPokes <- forM allColors $ \col -> do
    pokes <- fmap lines $ readFile $ "colors/" ++ map toLower (show col) ++ ".txt"
    return (col, pokes)
  let pokesOfColor c = fromJust $ lookup c colorToPokes
      pokeToColor p = head $ filter (elem p . pokesOfColor) allColors
      colors = map pokeToColor names
  return $ zipWith4 Pokémon names descs heights colors

toRows :: [Pokémon] -> [NamedRecord]
toRows pokes = let
  heightGroups = splitInto 6 $ map height pokes
  hasHeight h (minh, maxh) = minh <= h && h <= maxh
  heightToStr h = case filter (hasHeight h) heightGroups of
    (minh, maxh) : _ -> show minh ++ " to " ++ show maxh
    [] -> error "toRows: no group contains height!"
  fileName = mapMaybe $ \c -> case c of
    '♀' -> Just 'F'
    '♂' -> Just 'M'
    _   -> guard (isAlpha c || isSpace c) >> Just c
  in do
    p <- pokes
    return $ namedRecord
      [ B8.pack "name"         .= fileName (name p)
      , B8.pack "display_name" .= name p
      , B8.pack "description"  .= description p
      , B8.pack "height"       .= heightToStr (height p)
      , B8.pack "color"        .= show (color p)
      ]

-- | Splits a list into a given number of ranges such that when you categorize
-- the list with those ranges, each group has roughly the same size.
splitInto :: (Ord a) => Int -> [a] -> [(a, a)]
splitInto n xs = let
  xs' = sort xs
  possible = combinations n $ splitPoints xs'
  splits = map (\ns -> splitAtAll ns xs') possible
  scores = map (variance . map (fromIntegral . length)) splits
  best = head $ sort $ zip scores splits
  ranges = map (\chunk -> (head chunk, last chunk)) $ snd best
  in ranges

variance :: [Double] -> Double
variance ns = let
  len = fromIntegral $ length ns :: Double
  mean = sum ns / len
  sqDifs = map (\n -> (n - mean) ** 2) ns
  in sum sqDifs / len

-- | Given a sorted list, returns the indexes of elements which are different
-- from their immediate predecessors.
splitPoints :: (Eq a) => [a] -> [Int]
splitPoints xs = map fst $ filter snd $ zip [1..] $ zipWith (/=) xs (tail xs)

-- | Computes all the subsequences of the list of the given size.
combinations :: Int -> [a] -> [[a]]
combinations 0 _  = [[]]
combinations _ [] = []
combinations n (x : xs) = let
  with = map (x :) $ combinations (n - 1) xs
  without = combinations n xs
  in with ++ without

splitAtAll :: [Int] -> [a] -> [[a]]
splitAtAll []       xs = [xs]
splitAtAll (n : ns) xs = case splitAt n xs of
  (a, b) -> a : splitAtAll (map (subtract n) ns) b
