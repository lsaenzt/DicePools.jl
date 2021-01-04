using Test, .DicePools

using DataFrames, Statistics

# Conan Damage Dice

    Conan_Dmg = DicePools.CategoricalDice([["Hit"],["Hit","Hit"],["Blank"],["Hit","Effect"]],[1,1,2,2]);

    tdf = DicePools.resultsprobabilities(3:10,Conan_Dmg,name="Conan")|> DataFrame;

    psum = combine(groupby(tdf,:Conan),:Probability => sum);

@test unique(round.(psum[:,2], digits=2)) == [100.0] #Test all probabilities add up 100%

    chance = sort!(combine(groupby(tdf,[:Conan,:Hit]),:Probability => sum => :Probability),[:Conan,:Hit]); # Probabities for each number of dice and number of Hits

@test maximum(chance.Probability)<=100

    cumchance = transform(groupby(chance,[:Conan]),[:Hit,:Probability] => ((s,p) -> sum(p.*[s.<=i for i in s])) => :MoreThan);

@test maximum(round.(cumchance.MoreThan,digits=2))<=100

# MYZ Attribute Dice

    MY0_Attr = DicePools.CategoricalDice([["Success"],["Blank"],["Harm"]],[1,4,1])

    tdf = DicePools.resultsprobabilities(1:15,MY0_Attr,name="MY0")|> DataFrame

    psum = combine(groupby(tdf,:MY0),:Probability => sum) 

@test unique(round.(psum[:,2], digits=2)) == [100.0]

    chance = sort!(combine(groupby(tdf,[:MY0,:Success]),:Probability => sum => :Probability),[:MY0,:Success]) # Probabities for each number of dice and number of Hits

@test maximum(chance.Probability)<=100

    cumchance = transform(groupby(chance,[:MY0]),[:Success,:Probability] => ((s,p) -> sum(p.*[s.<=i for i in s])) => :MoreThan) 

@test maximum(round.(cumchance.MoreThan,digits=2))<=100


#= Nota explicativa de ((s,p) -> sum(p.*[s.<=i for i in s]))

1.- Pasamos el vector S "success" y el p "probability" 
2.- Generamos un matriz que tiene para cada fila un vector que indica si S es mayor que el valor individual de fila i
3.- Multiplicamos cada elemento de P por cada Array anterior 
4.- Sumamos el vector resultanto de lo anterior
=#