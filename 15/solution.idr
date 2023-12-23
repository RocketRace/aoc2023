import Data.List1
import Data.List
import Data.String
import Data.Vect
import Data.Fin
import Data.Zippable
import Data.Stream
import Control.Monad.State

hash : String -> Nat
hash = hash' 0 where
    hash' : Nat -> String -> Nat
    hash' acc str with (asList str)
        hash' acc "" | [] = acc 
        hash' acc _ | c :: rest = ((hash' acc _ | rest) + cast (ord c)) * 17  `mod` 256

part1 : String -> Nat
part1 line = sum [hash (reverse segment) | segment <- split (==',') line]

hashKey : String -> Fin 256
hashKey str = fromMaybe 0 $ natToFin (hash str) 256 -- ugly, couldn't get a proof to work

data Op = Remove | Focus Nat

parseOp : String -> Maybe Op
parseOp s with (strUncons s)
    _ | Just (c, rest) with (c)
        _ | '-' = Just Remove
        _ | '=' with (parsePositive {a=Nat} rest)
            _ | Just int = Just (Focus int)
            _ | _ = Nothing
        _ | _ = Nothing
    _ | _ = Nothing

Boxes = Vect 256 (List (String, Nat))

perform : String -> State Boxes ()
perform step = 
    let (label, rest) = span (\c => c /= '-' && c /= '=') step
        op = parseOp rest
        key = hashKey (reverse label)
        labelIs : String -> (String, a) -> Bool
        labelIs label = \(x, _) => x == label
    in modify (
        case op of
            Just Remove => updateAt key (deleteBy labelIs label)
            Just (Focus value) => updateAt key 
                (\list => case findIndex (labelIs label) list of
                            Nothing => list ++ [(label, value)]
                            Just _ => replaceWhen (labelIs label) (label, value) list)
            Nothing => id
    )

indexed : List a -> List (Nat, a)
indexed xs = indexed' 0 xs where
    indexed' : Nat -> List a -> List (Nat, a)
    indexed' _ [] = []
    indexed' i (x :: xs) = (i, x) :: indexed' (S i) xs

focusingPower : Boxes -> Nat
focusingPower boxes =
    let nested = indexed . toList $ indexed `map` boxes
        flattened = concat $ (\(i, box) => (i,) `map` box) `map` nested
        produced = (\(boxI, (lensI, (label, focal))) => (S boxI) * (S lensI) * focal) `map` flattened
    in sum produced

part2 : String -> Nat
part2 line = 
    let segments = split (==',') line
        init = Vect.replicate 256 []
        actions = perform `map` segments
        (final, ()) = runState init $ sequence_ actions
    in focusingPower final

main : IO () 
main = part2 <$> getLine >>= printLn
   {-- part2 --}
