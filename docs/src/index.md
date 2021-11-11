# DicePools

## Summary

DicePools calculates the probability of each possible result when rolling a number of dice. Dice can be both numeric or with symbols and combining both is also possible.

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

### Output 

DicePools generates a table with one row for each possible result and the following dimensions:

- Dice: a column with the numbers of dice in the pool. A pool of 2D6 will have a "2" in this column. If rolling several pools (e.g. 1:3) the output shows numbers 1,2,3. To see the results of one the pools (e.g. 3d6), you should filter this column by "3·

- Symbols: if a symbol die is rolled, the output includes one column per symbol. The values of the column are the symbols rolled. 

- Results: if a numeric dice are rolled, this column shows the result of the roll.

- Probability: the probability of geeting the symbols and/or results for a dice pool.


### Note
Pending tasks:
    - explode dice
    - reroll numeric dice

## Index

```@index
```