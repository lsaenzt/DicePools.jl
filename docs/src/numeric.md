# Numeric Dice

## Functions

```@docs
roll(n::Union{Int,OrdinalRange},dice::StandardDice,mod::Int=0;name::String=dice.name)
roll(n::Union{Int,OrdinalRange},dice::CustomDice,mod::Int=0;name::String=dice.name)
roll(f::Function,n::Union{Int,OrdinalRange},dice::NumericDice;name::String="Dice")
drop(n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0;droplowest=0,drophighest=0,name="Dice")
```
