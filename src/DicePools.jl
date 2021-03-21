module DicePools

using Combinatorics
using OrderedCollections
using Tables

export roll, combineresults, reroll, sampleroll

include("DiceTypes.jl")
include("TablesInterface.jl")
include("SymbolDice.jl")
include("NumericDice.jl")
include("DiceExamples.jl")
include("Utils.jl")

end # module

using .DicePools