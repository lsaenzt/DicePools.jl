## Description

This section describes the general structure of the code and main design choices.

## Overview

DicePools is organized in the following files:

- DiceTypes.jl: includes types for dice and their hierarchy 
- NumericDice.jl: several fucntions for calculating results on rolls with numeric dice (add, roll under, beat target...)
- SymbolDice.jl: results and probabilites for Symbol dice
- DiceExamples.jl: definitions of common types of dice
- Pool.jl: methods for pooling dice together. Either Numeric or Symbol
- TablesInterface.jl: define methods to make the probability results Tables.jl compliant
- Macros.jl: WIP
- Utils.jl: helper methods for specific games

## Numeric dice

## Symbol dice