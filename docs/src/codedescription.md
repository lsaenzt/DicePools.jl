## Overview

DicePools is organized in the following files:

- DiceTypes.jl: includes types for dice and their hierarchy 
- NumericDice.jl: basic functions for adding results on rolls with numeric dice. Also includes overloading of Base arithmetic functions.
- Mechanics.jl: Add other mechanics with numeric dice: roll under, beat target...
- SymbolDice.jl: results and probabilites for Symbol dice
- DiceExamples.jl: definitions of common (and not-so common) types of dice
- Pool.jl: methods for pooling dice together. Numeric, Symbol or both
- TablesInterface.jl: define methods to make the probability results Tables.jl compliant
- Utils.jl: helper methods for specific games

## Numeric dice and mechanics

Numericdice.jl defines a function roll with two methods for calculating the probability of a result in the following cases
1.  Sum of results of standard dice using combinatorics
2.  Sum of results of custom numeric dice based on a recursive cross-product function

There is algo a customroll method for applying a function to the results of a numeric dice. This method is used in functions that implement specific mechanics such as 'roll under', 'take mid', 'beat target', 'drop lowest'...

## Symbol dice

SymbolDice.jl calculates the probability for dice with symbols instead of numbers on their sides. 
Each combination of symbols is given a probability.

## Pool

Pool.jl includes a function for combining the results of previous rolls. Either numberic, symbol dice or both