using Documenter, .DicePools

makedocs(
    modules = [DicePools],
    sitename = "DicePools.jl",
    format = Documenter.HTML(),
    pages = ["Introduction" => "index.md",
            "Rolling" => ["numeric.md", "symbol.md", "pool.md"]]
)