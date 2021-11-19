# DicePools

DicePools calculates the probability of each possible result when rolling a number of dice. Dice can be both numeric or with symbols and combining both is also possible.

Results is Tables.jl compliant and can be easily converted to DataFrames, CSV, PrettyTables...

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

### Output 

DicePools generates a DicePool object storing a table with one row for each possible result and the following column dimensions:

- Dice: numbers of dice in the pool. A pool of 2D6 will have a "2" in this column. If rolling several pools (e.g. 1:3) the output shows numbers 1,2,3. To see the results of one the pools, you should filter this column by the desired number of dice (e.g. 3 for getting the results of a 3d6 roll)

- Symbols: if a symbol die is rolled, the output includes one column per symbol. The values of the column are the symbols rolled. 

- Results: if a numeric dice are rolled, this column shows the result of the roll. It depends on the mechanich applied. In a standard roll (e.g. 3d6) the column shows the sum of the dice. In other mechanics it can represent other type of results (e.g. number of successes in a beat targe roll)

- Probability: the probability of getting the symbols and/or results in each row.

## Index

```@index
```

### Note

DicePools has been (obviously) developed with learning purposes in mind. And for fun... It uses type hierarchies, type constructors (inner and outter), multiple dispath, do-block functions, overloading of Julia Base, BigInts, tables.jl interface implementation, recursive functions, documenter and testing suite.

### Todos
Pending tasks:
    - explode dice
    - reroll numeric dice
    - Hybril dice (combining both numbers and symbols)
