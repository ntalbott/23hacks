import Data.List
import System.IO

permutations :: [a] -> [[a]]
permutations [] = [[]]
permutations (x:xs) = [zs| ys <- permutations xs, zs <- everywhere x ys]

everywhere :: a -> [a] -> [[a]]
everywhere x [] = [[x]]
everywhere x (y:ys) = (x:y:ys) : [y:zs| zs <- everywhere x ys]

permute :: Int -> [[Int]]
permute n = permutations [1..n]

fac :: Int -> Int
fac 0 = 1
fac n = n * fac (n-1)

avg :: [Float] -> Float 
avg xs = (sum xs) / (fromInteger (toInteger (length xs)))

type IndividualGame = [Int]
type Game = (IndividualGame, IndividualGame, IndividualGame)
type Round = (Int, Int, Int)
type RoundOutcome = (Int, Int, Int)
type Outcome = (Int, Int)

emptyGame = ([], [], [])

main :: IO ()
main = do
        hSetBuffering stdout NoBuffering
        playGame

playGame :: IO ()
playGame = do
        putStrLn "NEW GAME"
        game <- playRounds emptyGame
        putStrLn "Game:"
        putStrLn (show (gameOutcome game))
        putStrLn "--------"
        playGame

playRounds :: Game -> IO Game
playRounds game@(rs, xs, ys)
  | 6 == (length rs) =  do return game
  | otherwise = do
        r <- collectMove "What did the computer play?" (rpossibilities rs)
        suggest r game (rpossibilities xs)
        x <- collectMove "What did you play?" (rpossibilities xs)
        y <- collectMove "What did your opponent play?" (rpossibilities ys)
        playRounds (addRound game (r, x, y))
                
addRound :: Game -> Round -> Game
addRound (rs, xs, ys) (r, x, y) = unzip3 ((zip3 rs xs ys) ++ [(r, x, y)])

suggest :: Int -> Game -> [Int] -> IO ()
suggest r game p =  putStrLn (show (sortBy (\(_, x) (_, y) -> compare y x) ([(x, rprob r x game) | x <- p])))
        
collectMove :: String -> [Int] -> IO Int
collectMove prompt p = do
        putStr (prompt ++ " " ++ (show p) ++ " ")
        m <- getNum
        if m `elem` p then return m else do
                n <- collectMove prompt p
                return n
        
getNum :: IO Int
getNum = do
        l <- getLine
        return (read l)
        
prob :: Int -> Int -> Int -> Game -> Float
{-prob 6 1 x ([], [], []) = [0.62054473,0.5757739,0.5211931,0.4753256,0.42217633,0.38498604] !! (x-1)
prob 6 2 x ([], [], []) = [0.58095896,0.5486517,0.51325125,0.48321134,0.44926855,0.42465824] !! (x-1)
prob 6 3 x ([], [], []) = [0.55645114,0.53395337,0.5089479,0.48732883,0.46394825,0.44937035] !! (x-1)
prob 6 4 x ([], [], []) = [0.52342975,0.5102351,0.5029013,0.49289516,0.48781174,0.48272726] !! (x-1)
prob 6 5 x ([], [], []) = [0.49831015,0.49524307,0.49817595,0.49705642,0.5030073,0.5082072] !! (x-1)
prob 6 6 x ([], [], []) = [0.45825192,0.46781716,0.48997536,0.5049774,0.5304179,0.5485607] !! (x-1)-}
prob n r x (rs, xs, ys) = avg [avg [avg [play (r', x', y') | y' <- possibleGames n ys] | x' <- possibleGames n (xs ++ [x])] | r' <- possibleGames n (rs ++ [r])]
    
rprob = prob 6

possibleGames :: Int -> IndividualGame -> [IndividualGame]
possibleGames n xs
  | length xs == n =  [xs]
  | otherwise      =  [xs ++ p | p <- permutations (possibilities n xs)]
  
possibilities :: Int -> [Int] -> [Int]
possibilities n xs = [x| x <- [1..n], notElem x xs]

rpossibilities = possibilities 6

rgames :: [Game]
rgames = games 6

sgames :: [Game]
sgames = games 3

games :: Int -> [Game]
games n = [(r, x, y)| r <- individualGames n, x <- individualGames n, y <- individualGames n]

individualGames :: Int -> [IndividualGame]
individualGames n = permute n

tie = 0.5

gameAsRounds :: Game -> [Round]
gameAsRounds (r, x, y) = zip3 r x y

outcomeAsProb :: RoundOutcome -> Float
outcomeAsProb (_, x, y) = if x == y then tie else if x > y then 1.0 else 0.0

play :: Game -> Float
play ([], [], []) = 0.0
play game = outcomeAsProb (gameOutcome game)

gameOutcome game = foldl' totalRounds (0, 0, 0) (gameAsRounds game)

totalRounds :: RoundOutcome -> Round -> RoundOutcome
totalRounds (r', x', y') (r, x, y)
  | x == y    =  (r'+r+x+y, x', y')
  | x > y     =  (0, r'+x'+r+x+y, y')
  | otherwise =  (0, x', r'+y'+r+x+y)

