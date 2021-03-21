export d4,d6,d8,d10,d12,d20,d100,fudge,MY0_Skill,MY0_Eq,MY0_Attr,Conan_Dmg,Boost, Setback, Ability

# NumericDice
d4 = StandardDice(4)
d6 = StandardDice(6)
d8 = StandardDice(8)
d10 = StandardDice(10)
d12 = StandardDice(12)
d20 = StandardDice(20)
d100 = StandardDice(100)
fudge = CustomDice([-1,0,1])

# Year-Zero Engine Dice
MY0_Skill = SymbolDice([["Success"],["Blank"]],[1,5])
MY0_Attr = SymbolDice([["Success"],["Blank"],["Harm"]],[1,4,1])
MY0_Eq = SymbolDice([["Success"],["Blank"],["Break"]],[1,4,1])

# Conan 2D20 Dice
Conan_Dmg = SymbolDice([["Hit"],["Hit","Hit"],["Blank"],["Hit","Effect"]],[1,1,2,2])

# Genesys
Boost = SymbolDice([["Blank"],["Success"],["Success","Advantage"],["Advantage","Advantage"],["Advantage"]],[2,1,1,1,1]) 
Setback = SymbolDice([["Blank"],["Failure"],["Threat"]],[2,2,2])                                                          
Ability = SymbolDice([["Blank"],["Success"],["Success","Success"],["Advantage"],["Success","Advantage"],["Advantage","Advantage"]],[1,2,1,2,1,1]) 
