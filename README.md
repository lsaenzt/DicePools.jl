# DicePools

## Summary

DicePools calculates the probability of results of rolling a number of dice. Dice can be both numeric or with symbols and combining both is also possible.

Results is Tables.jl compliant and can be easily converted to DataFrames, CSV, PrettyTables...

### Example 
```
    eigths = roll(1:3,d8)
    symbols = SymbolDice([["Success"],["Blank"]],[1,5],"Symbol") # 1 success and 5 blanks
    special = roll(1:4,symbols)
    results = pool(eigths,special)

    using PrettyTables, DataFrames, CSV
    pretty_table(results)
    DataFrame(results)
    CSV.write(results)
```
