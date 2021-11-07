using Documenter, .DicePools

# Press Alt+Enter on VSCode
makedocs(
    modules = [DicePools],
    sitename = "DicePools.jl",
    format = Documenter.HTML(),
    pages = ["Introduction" => "index.md",
            "Rolling" => ["numeric.md", "symbol.md", "pool.md"],
            "Dice" => "dicetypes.md", "Description" => "codedescription.md"]
)

#= ToDO 
deploydocs(
    repo = "github.com/lsaenzt/DicePools.jl.git",
    devbranch = "main"
)
=#