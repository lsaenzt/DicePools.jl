module DicePools

using Combinatorics
using OrderedCollections
using Tables

export roll, combine, reroll, sampleroll

include("DiceTypes.jl")
include("TablesInterface.jl")
include("Macros.jl")
include("SymbolDice.jl")
include("NumericDice.jl")
include("DiceExamples.jl")
include("Utils.jl")

end # module

using .DicePools

#= ToDo List 
    macro @roll 3d6+1
    combine numeric d5+d20
    reroll numeric 
    exploding dice
    docs
=#

