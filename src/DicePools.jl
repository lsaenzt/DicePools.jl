module DicePools

using Combinatorics
using OrderedCollections
using Tables

export roll, combineresults, reroll

include("DiceTypes.jl")
include("TablesInterface.jl")
include("SymbolDice.jl")
include("NumericDice.jl")
include("DiceExamples.jl")

end # module

using .DicePools