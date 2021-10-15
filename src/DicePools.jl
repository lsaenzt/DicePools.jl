module DicePools

using Combinatorics
using OrderedCollections
using Tables

export roll, reroll, sampleroll, drop, takemid, beattarget, rollunder, pool
export d4,d6,d8,d10,d12,d20,d100,fudge,MY0_Skill,MY0_Eq,MY0_Attr,Conan_Dmg,Boost,Setback,Ability

setprecision(32)

include("DiceTypes.jl")
include("TablesInterface.jl")
include("pool.jl")
include("Macros.jl")
include("SymbolDice.jl")
include("NumericDice.jl")
include("DiceExamples.jl")
include("Utils.jl")

end # module

using .DicePools

#= ToDO List
    1.- [DONE]Subsract dice -> add method -(DiceProbabilities), -(DiceProbabilities,DiceProbabilities), 
    2.- [DONE]Also, +(DiceProbabilities,DiceProbabilities...), +(StandardDice, Int), *(Int,Dice)
    3.- [DONE] macro @roll 3d6+1 -> Not useful if 1 & 2 work
    4.- Solve sorting results when substracting dice
    4.- reroll numeric
    5.- exploding dice (~ reroll 'x' times)
    6.- hybrid dice (e.g. The one ring: d10 plus symbols)
    7.- double target (e.g. Conand20: 1 success or 2 successes)
    8.- change symboldice from array of arrays to array...(splat)
    9.- [DONE] Groupby combined dice
    10.- [WIP] docs
=#

#= Note

Roll function replica la filosofía del excel DicePools.xlsx

    1.- Listado de las posibles combinaciones de resultados según dados. Ej: 3 resultos de 1 éxito, 1 de dos éxitos y otro blanco con 5 dados
    2.- Calcular cuantas ordenaciones existen que den esos resultados. Ej: Primera: dado 1º,2º y 3º, 1 éxito, el 4º dos éxitos y el 5º blanco, 
                                                                       Segunda: el 1º,2º y 4º, 1 éxito, el 3º dos éxitos y el 5º blanco, etc, etc.
    3.- Calcular para una de esas ordenaciones cuantos casos existen teniendo en cuenta que hay resultados que aparecen varias veces (p.ej. si el blanco sale en 3 caras)
    4.- El total de casos posibles son los casos para cada combinación de resultados * las posibles ordenaciones según dados
    5.- La probabilidad es la cifra anterior entre el total de combinaciones de n dados de s caras (s^n)
=#