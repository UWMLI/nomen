#!/usr/bin/env runhaskell
module Main where

import Data.Char (isSpace)

indent :: String -> Int
indent (' '  : s) = 1 + indent s
indent ('\t' : s) = 2 + indent s
indent s          = if all isSpace s then maxBound else 0

dropLast :: [a] -> [a]
dropLast (x : xs@(_ : _)) = x : dropLast xs
dropLast _                = []

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
    then dropLast l : go (indent l : ns) lt
    else l : go ns lt
