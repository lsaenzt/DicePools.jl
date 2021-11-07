module DicePools

using Combinatorics
using OrderedCollections
using Tables
using PrettyTables

export roll, customroll, reroll, sampleroll, drop, takemid, beattarget, rollunder, pool
export d4,d6,d8,d10,d12,d20,d100,fudge,MY0_Skill,MY0_Eq,MY0_Attr,Conan_Dmg,Boost,Setback,Ability

setprecision(32)

include("DiceTypes.jl")
include("TablesInterface.jl")
include("pool.jl")
include("SymbolDice.jl")
include("NumericDice.jl")
include("Mechanics.jl")
include("DiceExamples.jl")
include("Utils.jl")

end # module

#= ToDO List
    1.- [DONE]Subsract dice -> add method -(DiceProbabilities), -(DiceProbabilities,DiceProbabilities), 
    2.- [DONE] Also, +(DiceProbabilities,DiceProbabilities...), +(StandardDice, Int), *(Int,Dice)
    3.- [DONE] macro @roll 3d6+1 -> Not useful if 1 & 2 work
    4.- [DONE] Solve sorting results when substracting dice
    5.- [DONE] Solve minus dice (-3d6)
    6.- reroll numeric
    7.- exploding dice (~ reroll 'x' times)
    8.- hybrid dice (e.g. The one ring: d10 plus symbols)
    9.- double target (e.g. Conand20: 1 success or 2 successes)
    10.- [DONE] Groupby combined dice
    11.- [WIP] docs
=#