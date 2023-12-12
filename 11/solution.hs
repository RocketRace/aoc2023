import Data.List

type Grid = [String]

rows :: Grid -> [Int]
rows grid = 
    let ind = zip [0..] grid
        filtered = filter (all (== '.') . snd) ind
    in
        fst <$> filtered

cols :: Grid -> [Int]
cols = rows . transpose

applyGaps :: Int -> [Int] -> [Int] -> [Int]
applyGaps gapSize gaps ns = applyGaps' gapSize gaps 0 ns

applyGaps' :: Int -> [Int] -> Int -> [Int] -> [Int]
applyGaps' gapSize remainingGaps accum [] = []
applyGaps' gapSize [] accum ns = (accum +) <$> ns
applyGaps' gapSize (nextGap:rest) accum (n:ns)
    | nextGap > n = accum + n : applyGaps' gapSize (nextGap:rest) accum ns
    | nextGap < n = applyGaps' gapSize rest (accum + gapSize) (n:ns)
    | otherwise = undefined -- hohoho

applyGaps'' :: Int -> [Int] -> Int -> [Int] -> [Int]
applyGaps'' gapSize remainingGaps accum [] = []

galaxies :: Grid -> [(Int, Int)]
galaxies grid =
    let indexed = zip [0..] $ zip [0..] <$> grid
        coordinated = [((x, y), c) | (y, row) <- indexed, (x, c) <- row]
    in
        fst <$> filter ((== '#') . snd) coordinated

explode :: Grid -> Int -> ([Int], [Int])
explode grid gap =
    let (xs, ys) = unzip $ galaxies grid
        xs' = applyGaps gap (cols grid) (sort xs)
        ys' = applyGaps gap (rows grid) (sort ys)
    in 
        (xs', ys')

webSum :: [Int] -> Int
webSum ns =
    let radius = length ns - 1
        coefficients = [-radius, -radius + 2 .. radius]
    in
        sum $ zipWith (*) ns coefficients

explosionSum :: Grid -> Int -> Int
explosionSum grid explosion =
    let (xs, ys) = explode grid explosion
    in 
        webSum xs + webSum ys

main :: IO ()
main = do
    input <- readFile "input"
    let grid = lines input
    putStrLn $ show $ explosionSum grid 1
    putStrLn $ show $ explosionSum grid 999999
