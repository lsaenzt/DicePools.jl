export headers, data, lookup, dicenamecols # ¿debería exportarse esto?

# Implementing DicePool as Tables interface compliant for direct reading to DataFrames, CSV...

# declare that DicePool is a table
Tables.istable(::Type{<:DicePool}) = true

# getter methods to avoid getproperty clash
headers(dp::DicePool) = getfield(dp, :headers)
data(dp::DicePool) = getfield(dp, :data)
lookup(dp::DicePool) = getfield(dp, :lookup)
dicenamecols(dp::DicePool) = getfield(dp, :dicenamecols)

# column interface
Tables.columnaccess(::Type{<:DicePool}) = true
Tables.columns(dp::DicePool) = dp

# required Tables.AbstractColumns object methods
Tables.getcolumn(dp::DicePool, nm::Symbol) = data(dp)[:, lookup(dp)[nm]]
Tables.getcolumn(dp::DicePool, i::Int) = data(dp)[:, i]
Tables.columnnames(dp::DicePool) = headers(dp)
