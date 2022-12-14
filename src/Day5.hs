module Day5
  ( part1,
    part2,
  )
where

import Data.List (transpose)
import Data.List.Split (splitWhen)

-- https://stackoverflow.com/questions/2026912/how-to-get-every-nth-element-of-an-infinite-list-in-haskell
every n xs = case drop (n -1) xs of
  y : ys -> y : every n ys
  [] -> []

splitInitialStateFromInstructions :: [String] -> ([String], [String])
splitInitialStateFromInstructions input = (initialState, instructions)
  where
    lists = splitWhen (== "") input
    initialState = init (head lists)
    instructions = last lists

parseInitialStateRow :: String -> String
parseInitialStateRow row = every 4 ("  " ++ row)

rotateInitialStateRows :: [String] -> [String]
rotateInitialStateRows rows = do
  let lists = map (const []) rows
  []

parseInstruction :: String -> (Int, Int, Int)
parseInstruction instruction = (head values, values !! 1 - 1, last values - 1)
  where
    words = splitWhen (== ' ') instruction
    filteredWords = filter (\x -> (x /= "move") && (x /= "from") && (x /= "to")) words
    values = map read filteredWords

updateColumnWithReverse :: Int -> Int -> String -> (Int, String) -> String
updateColumnWithReverse source destination items (index, column)
  | source == destination = column
  | index == source = drop (length items) column
  | index == destination = reverse items ++ column
  | otherwise = column

runInstructionWithReverse :: [String] -> (Int, Int, Int) -> [String]
runInstructionWithReverse columns (quantity, source, destination) = do
  let items = take quantity (columns !! source)
  zipWith (curry (updateColumnWithReverse source destination items)) [0 ..] columns

updateColumn :: Int -> Int -> String -> (Int, String) -> String
updateColumn source destination items (index, column)
  | source == destination = column
  | index == source = drop (length items) column
  | index == destination = items ++ column
  | otherwise = column

runInstruction :: [String] -> (Int, Int, Int) -> [String]
runInstruction columns (quantity, source, destination) = do
  let items = take quantity (columns !! source)
  zipWith (curry (updateColumn source destination items)) [0 ..] columns

parseInput :: [String] -> ([(Int, Int, Int)], [String])
parseInput lines = do
  let (initialStateInput, instructionsInput) = splitInitialStateFromInstructions lines
  let initialState = map (filter (/= ' ')) (transpose (map parseInitialStateRow initialStateInput))
  let instructions = map parseInstruction instructionsInput
  (instructions, initialState)

part1 :: IO String -> IO ()
part1 input = do
  inputLines <- lines <$> input
  let (instructions, initialState) = parseInput inputLines
  let finalState = foldl runInstructionWithReverse initialState instructions
  print (map head finalState)

part2 :: IO String -> IO ()
part2 input = do
  inputLines <- lines <$> input
  let (instructions, initialState) = parseInput inputLines
  let finalState = foldl runInstruction initialState instructions
  print (map head finalState)
