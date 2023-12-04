Split ← (¬-˜⊢×·+`»⊸>)∘≠⊔⊢
scratchies ← ((•ParseFloat¨ ' '⊸Split)¨ '|'⊸Split)¨ 10⊸↓¨ •FLines "input"
wins ← (+´∊´)¨ scratchies
part1 ← +´{⌊2⋆𝕩-1}¨ wins
part2 ← (+´1¨{i‿w𝕊𝕩: is←w↑(i+1)↓↕≠𝕩 ⋄ (i⊑𝕩)⊸+⌾(is⊸⊏)𝕩}´⌽∘(↕∘≠⋈¨⊢)) wins
•Out •Fmt part1‿part2
