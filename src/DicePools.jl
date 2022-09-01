module DicePools

using Combinatorics
using OrderedCollections
using Tables

export roll, customroll, reroll, sampleroll, highest, drop, takemid, beattarget, rollunder, pool
export d4, d6, d8, d10, d12, d20, d100, fudge, MY0_Skill, MY0_Eq, MY0_Attr, Conan_Dmg,
       Boost, Setback, Ability

setprecision(32)

include("DiceTypes.jl")
include("TablesInterface.jl")
include("Pool.jl")
include("SymbolDice.jl")
include("NumericDice.jl")
include("Mechanics.jl")
include("DiceExamples.jl")
include("Utils.jl")

let 
    roll(1,d4)
    highest(1,d4)
    drop(1,d4)
end

end # module
