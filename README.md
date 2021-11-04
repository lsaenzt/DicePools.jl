# DicePools

DicePools generates a Table.jl compliant output with the results of rolling dice. Dice can be both numeric or with symbols and combining both is also possible.

A little example 
```
    eights = roll(1:3,d8)
    special = roll(1:4,symboldice)
    results = pool(eigth,special)
    DataFrame(results)
    CSV.write(results)
```
