module DicePools

using Combinatorics
using OrderedCollections
using Tables

export roll, combine, reroll, sampleroll, rollanddrop, takemid, beattarget, belowtarget
export d4,d6,d8,d10,d12,d20,d100,fudge,MY0_Skill,MY0_Eq,MY0_Attr,Conan_Dmg,Boost,Setback,Ability

setprecision(32)

include("DiceTypes.jl")
include("TablesInterface.jl")
include("Macros.jl")
include("SymbolDice.jl")
include("NumericDice.jl")
include("DiceExamples.jl")
include("Utils.jl")

end # module

using .DicePools

#= ToDO List
    macro @roll 3d6+1
    reroll numeric
    exploding dice (~ reroll 'x' times)
    simplify docstrings for roll
    hybrid dice (e.g. The one ring: d10 plus symbols)
    double target (e.g. Conand20: 1 success or 2 successes)
    change symboldice from array of arrays to array...(splat)
    Groupby symbol dice
    docs
=#