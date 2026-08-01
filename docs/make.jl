using Documenter, DicePools

makedocs(; modules=[DicePools], sitename="DicePools.jl", format=Documenter.HTML(),
         pages=["Introduction" => "index.md",
                "Rolling" => ["numeric.md", "symbol.md", "pool.md"],
                "Dice" => "dicetypes.md", "Internals" => "codedescription.md"],checkdocs=:exports)

deploydocs(; repo="github.com/lsaenzt/DicePools.jl.git", devbranch="master")

# Common issues: functions are not exported, docstrings without """