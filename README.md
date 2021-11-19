![Test Status](https://github.com/lsaenzt/DicePools.jl/workflows/Tests/badge.svg)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lsaenzt.github.io/DicePools.jl/dev/)

# DicePools

DicePools calculates each possible result of a dice pool and their probability of ocurrence. Dice can be both numeric or with symbols and combining both is also possible.

Results is Tables.jl compliant and can be easily converted to DataFrames, CSV, PrettyTables, etc.

### Example 
```julia
    eigths = roll(1:3,d8)
    symbols = SymbolDice([["Success"],["Blank"]],[2,4],"Symbol") # 2 success and 4 blanks
    special = roll(1:4,symbols)
    results = pool(eigths,special)

    using PrettyTables, DataFrames, CSV
    pretty_table(eigths)
    DataFrame(symbols)
    CSV.write(results)
```

### Note

DicePools has been (obviously) developed with learning purposes in mind. And for fun... It uses type hierarchies, type constructors (inner and outter), multiple dispath, do-block functions, overloading of Julia Base, BigInts, tables.jl interface implementation, recursive functions, documenter and testing suite.
