# DicePools

## Summary

DicePools generates Tables.jl compliant output with the results of rolling dice under various rules. Dice can be both numeric or with symbols and combining both is also possible.

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

### Note
This package is being developed for Julia learning and practicing. Pending tasks:
    - explode dice
    - reroll numeric dice

## Index

```@index
```
