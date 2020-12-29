using Tables

export names,data,lookup

# Implementing diceprobabilities as Tables interface compliant for direct reading to DataFrames, CSV...

struct DiceProbabilities <: Tables.AbstractColumns
    names::Tuple
    data::Array
    lookup::Dict{Symbol, Int}
    #TODO:Implementar nº de columnas nombre+getter para poder usar combineresults de combineresults...
end

# declare that DiceProbabilities is a table
Tables.istable(::Type{<:DiceProbabilities}) = true

# getter methods to avoid getproperty clash
names(dp::DiceProbabilities) = getfield(dp, :names)
data(dp::DiceProbabilities) = getfield(dp, :data)
lookup(dp::DiceProbabilities) = getfield(dp, :lookup)

# column interface
Tables.columnaccess(::Type{<:DiceProbabilities}) = true
Tables.columns(dp::DiceProbabilities) = dp

# required Tables.AbstractColumns object methods
Tables.getcolumn(dp::DiceProbabilities, nm::Symbol) = data(dp)[:,lookup(dp)[nm]]
Tables.getcolumn(dp::DiceProbabilities, i::Int) = data(dp)[:,i]
Tables.columnnames(dp::DiceProbabilities) = names(dp)