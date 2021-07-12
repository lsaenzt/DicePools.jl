# NumericDice
d4 = StandardDice(4)
d6 = StandardDice(6)
d8 = StandardDice(8)
d10 = StandardDice(10)
d12 = StandardDice(12)
d20 = StandardDice(20)
d100 = StandardDice(100)
fudge = StandardDice(3,-1:1,"fudge")

# Year-Zero Engine Dice
MY0_Skill = SymbolDice([["Success"],["Blank"]],[1,5],"MY0_Skill")
MY0_Attr = SymbolDice([["Success"],["Blank"],["Harm"]],[1,4,1],"MY0_Attr")
MY0_Eq = SymbolDice([["Success"],["Blank"],["Break"]],[1,4,1],"MY0_Eq")

# Conan 2D20 Dice
Conan_Dmg = SymbolDice([["Hit"],["Hit","Hit"],["Blank"],["Hit","Effect"]],[1,1,2,2],"Conan_Dmg")

# Genesys
Boost = SymbolDice([["Blank"],["Success"],["Success","Advantage"],["Advantage","Advantage"],["Advantage"]],[2,1,1,1,1],"Boost") 
Setback = SymbolDice([["Blank"],["Failure"],["Threat"]],[2,2,2],"Setback") #[1,1,1] works the same                                                   
Ability = SymbolDice([["Blank"],["Success"],["Success","Success"],["Advantage"],["Success","Advantage"],["Advantage","Advantage"]],[1,2,1,2,1,1],"Ability")