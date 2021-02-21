export d4,d6,d8,d12,d20,d100,fudge,MY0_Skill,MY0_Eq,MY0_Attr,Conan_Dmg,□,■,♢

# NumericDice
 d4 = NumericDice(4)
 d6 = NumericDice(6)
 d8 = NumericDice(8)
 d10 = NumericDice(10)
 d12 = NumericDice(12)
 d20 = NumericDice(20)
 d100 = NumericDice(100)
 fudge = NumericDice([-1,0,1])

# Year-Zero Engine Dice

MY0_Skill = CategoricalDice([["Success"],["Blank"]],[1,5])
MY0_Attr = CategoricalDice([["Success"],["Blank"],["Harm"]],[1,4,1])
MY0_Eq = CategoricalDice([["Success"],["Blank"],["Break"]],[1,4,1])

# Conan 2D20 Dice

Conan_Dmg = CategoricalDice([["Hit"],["Hit","Hit"],["Blank"],["Hit","Effect"]],[1,1,2,2])

# Genesys

□ = CategoricalDice([["Blank"],["Success"],["Success","Advantage"],["Advantage","Advantage"],["Advantage"]],[2,1,1,1,1]) #Boost
■ = CategoricalDice([["Blank"],["Failure"],["Threat"]],[2,2,2])                                                          #Setback
♢ = CategoricalDice([["Blank"],["Success"],["Success","Success"],["Advantage"],["Success","Advantage"],["Advantage","Advantage"]],[1,2,1,2,1,1]) # Ability
#=
◈ = 
⬠ = 
⬟ = 
=#