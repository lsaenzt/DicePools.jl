using DataFrames

# Conan

tdf = DicePools.roll(3:10,Conan_Dmg)|> DataFrame;

psum = combine(groupby(tdf,:Conan_Dmg),:Probability => sum);

@test unique(round.(psum[:,2], digits=2)) == [100.0]

chance = sort!(combine(groupby(tdf,[:Conan_Dmg,:Hit]),:Probability => sum => :Probability),[:Conan_Dmg,:Hit]); # Probabities for each number of dice and number of Hits

@test maximum(chance.Probability)<=100

# MY0

tdf = DicePools.roll(1:15,MY0_Attr)|> DataFrame

psum = combine(groupby(tdf,:MY0_Attr),:Probability => sum)

@test unique(round.(psum[:,2], digits=2)) == [100.0]

chance = sort!(combine(groupby(tdf,[:MY0_Attr,:Success]),:Probability => sum => :Probability),[:MY0_Attr,:Success]) # Probabities for each number of dice and number of Hits

@test maximum(chance.Probability)<=100

cumchance = transform(groupby(chance,[:MY0_Attr]),[:Success,:Probability] => ((s,p) -> sum(p.*[s.<=i for i in s])) => :MoreThan)

@test maximum(round.(cumchance.MoreThan,digits=2)) <= 100

#= Explanatory note of ((s,p) -> sum(p.*[s.<=i for i in s]))
    1.- Pasamos el vector S "success" y el p "probability" 
    2.- Generamos un matriz que tiene para cada fila un vector que indica si S es mayor que el valor individual de fila i
    3.- Multiplicamos cada elemento de P por cada Array anterior 
    4.- Sumamos el vector resultante de lo anterior
=#