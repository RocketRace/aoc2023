# Comment/uncomment these lines for part 1/2 respectively
# Pat ← +@0⇡10
Pat ← ⊂+@0⇡10{"zero" "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}

&fras "input"
⬚@ ⊜∘≠@\n. # split lines
⊠⊐⌕Pat
≡(□⊚)⍉
[≡(⊡1⊡0⊔):≡(⊡1⊡0⇌⊔).]
⍉
◿10
≡/(+×10)
/+
