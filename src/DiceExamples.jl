export MY0_Skill,MY0_Eq,MY0_Attr,Conan_Dmg,□,■,♢

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