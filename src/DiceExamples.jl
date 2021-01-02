export MY0_Skill,MY0_Eq,MY0_Attr,Conan_Dmg,□,■,♢

# Year-Zero Engine Dice

MY0_Skill = categoricaldice([["Success"],["Blank"]],[1,5])
MY0_Attr = categoricaldice([["Success"],["Blank"],["Harm"]],[1,4,1])
MY0_Eq = categoricaldice([["Success"],["Blank"],["Break"]],[1,4,1])

# Conan 2D20 Dice

Conan_Dmg = categoricaldice([["Hit"],["Hit","Hit"],["Blank"],["Hit","Effect"]],[1,1,2,2])

# Genesys

□ = categoricaldice([["Blank"],["Success"],["Success","Advantage"],["Advantage","Advantage"],["Advantage"]],[2,1,1,1,1]) #Boost
■ = categoricaldice([["Blank"],["Failure"],["Threat"]],[2,2,2])                                                          #Setback
♢ = categoricaldice([["Blank"],["Success"],["Success","Success"],["Advantage"],["Success","Advantage"],["Advantage","Advantage"]],[1,2,1,2,1,1]) # Ability
#=
◈ = 
⬠ = 
⬟ = 
=#