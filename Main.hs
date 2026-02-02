{-# LANGUAGE BangPatterns #-}

module Main where

import System.Environment (getArgs, getProgName)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Text.Read (readMaybe)
import Data.Set (Set)
import qualified Data.Set as Set
import Control.Parallel.Strategies
import Text.Printf (printf)

-- | Calculate the sum of squares of digits
sumOfSquares :: Int -> Int
sumOfSquares = go 0
  where
    go !acc 0 = acc
    go !acc n = 
      let digit = n `mod` 10
      in go (acc + digit * digit) (n `div` 10)

-- | Check if a number is happy using tail recursion with accumulator
isHappy :: Int -> Bool
isHappy = go Set.empty
  where
    go :: Set Int -> Int -> Bool
    go _ 1 = True
    go seen n
      | Set.member n seen = False
      | otherwise = go (Set.insert n seen) (sumOfSquares n)

-- | Count happy numbers from 1 to bound using parallel strategies
countHappyNumbers :: Int -> Int
countHappyNumbers bound =
  let results = map isHappy [1..bound] `using` parListChunk chunkSize rseq
      chunkSize = max 1 (bound `div` 100)
  in length $ filter id results

-- | Parse command line argument
parseBound :: String -> Either String Int
parseBound arg = case readMaybe arg of
  Nothing -> Left "Error: BOUND must be a valid integer"
  Just n 
    | n < 1 -> Left "Error: BOUND must be a positive integer (greater than 0)"
    | otherwise -> Right n

-- | Main program
main :: IO ()
main = do
  args <- getArgs
  progName <- getProgName
  
  case args of
    [arg] -> do
      case parseBound arg of
        Left err -> do
          hPutStrLn stderr err
          exitFailure
        Right bound -> do
          let happyCount = countHappyNumbers bound
              percentage = (fromIntegral happyCount / fromIntegral bound) * 100 :: Double
          printf "Happy numbers from 1 to %d: %d (%.2f%%)\n" bound happyCount percentage
    _ -> do
      hPutStrLn stderr $ "Usage: " ++ progName ++ " BOUND"
      hPutStrLn stderr "  BOUND: positive integer to check happy numbers from 1 to BOUND"
      exitFailure
