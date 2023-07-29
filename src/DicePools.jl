module DicePools

using Combinatorics
using OrderedCollections
using Tables
using PrecompileTools

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

@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    @compile_workload begin
        roll(1,d4)
        highest(1,d4)
        drop(1,d4)
        takemid(1,d6)
    end
end

end # module
