# DicePools

## Summary

DicePools generates Table.jl compliant output with the results of rolling dice under various rules. Dice can be both numeric or with symbols and combining both is also possible.

A little example 
```
    eights = roll(1:3,d8)
    special = roll(1:4,symboldice)
    results = pool(eigth,special)
    DataFrame(results)
    CSV.write(results)
```

### Note
This package is being developed as part of learning process and practice with Julia. Pending tasks:
    - explode dice
    - reroll numeric dice
    - macros for easier syntax (e.g. @roll 3d12+2)


## Index

```@index
```
