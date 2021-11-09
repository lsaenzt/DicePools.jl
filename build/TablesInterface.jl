export headers,data,lookup,dicenamecols # ¿debería exportarse esto?

# Implementing diceprobabilities as Tables interface compliant for direct reading to DataFrames, CSV...

# declare that DiceProbabilities is a table
Tables.istable(::Type{<:DiceProbabilities}) = true

# getter methods to avoid getproperty clash
headers(dp::DiceProbabilities) = getfield(dp, :headers)
data(dp::DiceProbabilities) = getfield(dp, :data)
lookup(dp::DiceProbabilities) = getfield(dp, :lookup)
dicenamecols(dp::DiceProbabilities) = getfield(dp, :dicenamecols)

# column interface
Tables.columnaccess(::Type{<:DiceProbabilities}) = true
Tables.columns(dp::DiceProbabilities) = dp

# required Tables.AbstractColumns object methods
Tables.getcolumn(dp::DiceProbabilities, nm::Symbol) = data(dp)[:,lookup(dp)[nm]]
Tables.getcolumn(dp::DiceProbabilities, i::Int) = data(dp)[:,i]
Tables.columnnames(dp::DiceProbabilities) = headers(dp)