#!/usr/bin/env runhaskell
module Main where

import Data.Char (isSpace)

indent :: String -> Int
indent s = case span isSpace s of
  (_ , "") -> maxBound
  (sp, _ ) -> length sp

main :: IO ()
main = interact $ unlines . go [] . lines where

  go, go' :: [Int] -> [String] -> [String]

  -- First check if we have to add a "return" line
  go _           []          = []
  go ns@(n : nt) ls@(l : lt) = if indent l <= n
    then (replicate (n + 2) ' ' ++ "return") : go nt ls
    else go' ns ls
  go [] ls = go' [] ls

  -- Then check if this line starts an action
  go' ns ls@(l : lt) = if drop (length l - 3) l `elem` ["->>", "=>>"]
    then init l : go (indent l : ns) lt
    else l : go ns lt
