using Documenter, DicePools

const REPO = Documenter.Remotes.GitHub("lsaenzt", "DicePools.jl")

makedocs(; modules=[DicePools], sitename="DicePools.jl", authors="lsaenzt",
         # Pin the remote instead of relying on git auto-detection. This covers the whole
         # repo root, so it fixes both the navbar / "Edit on GitHub" link and the
         # "source" links of docstrings coming from src/.
         repo=REPO,
         format=Documenter.HTML(; canonical="https://lsaenzt.github.io/DicePools.jl",
                                edit_link="master"),
         pages=["Introduction" => "index.md",
                "Rolling" => ["numeric.md", "symbol.md", "pool.md"],
                "Dice" => "dicetypes.md", "Internals" => "codedescription.md"],
                checkdocs=:exports)

deploydocs(; repo="github.com/lsaenzt/DicePools.jl.git", devbranch="master")

# Common issues: functions are not exported, docstrings without """, exported and included in .md files must be the same
# Source-url errors: the docs environment must `dev` the package (see docs/Project.toml
# `[sources]`), never `add` it by URL -- an added package lives in ~/.julia/packages
# without a .git dir, so Documenter cannot resolve a remote for it.
