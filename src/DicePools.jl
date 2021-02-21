module DicePools

using Combinatorics, OrderedCollections

export roll, combineresults, reroll

include("TablesInterface.jl")
include("DiceTypes.jl")
include("CategoricalDice.jl")
include("NumericDice.jl")
include("DiceExamples.jl")

end # module

using .DicePools