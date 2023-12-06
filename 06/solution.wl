input := Drop[StringSplit[#], 1] & /@ StringSplit[$ScriptInputString, "\n"]
games := Transpose[FromDigits /@ input]
discrim[lim_, record_] := Sqrt[Discriminant[x^2 - lim x + record, x]]
range[lim_, record_] := 
 Floor[(lim + discrim[lim, record])/2] - 
 Ceiling[(lim - discrim[lim, record])/2] + 1
part1 := Times @@ range @@@ games
game := FromDigits /@ StringJoin @@@ input
part2 := range @@ game
Print[part1]
Print[part2]
