## Description

This section describes the general structure of the code and main design choices.

## Overview

DicePools is organized in the following files:

- DiceTypes.jl: includes types for dice and their hierarchy 
- NumericDice.jl: several fucntions for calculating results on rolls with numeric dice (add, roll under, beat target...)
- SymbolDice.jl: results and probabilites for Symbol dice
- DiceExamples.jl: definitions of common (and not-so common) types of dice
- Pool.jl: methods for pooling dice together. Numeric, Symbol or both
- TablesInterface.jl: define methods to make the probability results Tables.jl compliant
- Utils.jl: helper methods for specific games

## Numeric dice

Numericdice.jl  defines a function roll with two methods for calculating the propability of a result in the following cases
1.  Sum of results of standard dice using combinatorics
2.  Sum of results of custom numeric dice

There is algo a customroll method for applying a function to the results of a numeric dice. This method is used in functions that implement specific mechanics such as 'roll under', 'take mid', 'beat target', 'drop lowest'...

## Symbol dice