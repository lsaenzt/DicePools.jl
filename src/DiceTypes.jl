export CategoricalDice, CustomDice, StandardDice #HybridDice

abstract type Dice end
"Numeric dice have results that are numbers to be summed"
abstract type NumericDice <: Dice end

"A numeric dice with numbers "
struct CustomDice <: NumericDice
    sides::Int #e.g. 3
    results::Vector{Int} #e.g. [-1,0,1]

    CustomDice(s,r) = s != length(r) ? error("number of sides do not match number of results") : new(s,sort(r))
end

"StandardDice have values ranging from 1 to number of sides. E.g. 1:20"
struct StandardDice <: NumericDice
    sides::Int #e.g. 8
    results::UnitRange{Int} #e.g. 1:8
end

"Outer constructors for NumericDice"
CustomDice(r::Vector{Int}) = CustomDice(length(r),r)
StandardDice(s::Int) = StandardDice(s,1:s)

"Categorical dice produce descriptive results that are combined"
struct SymbolDice <: Dice 
    sides::Int #e.g. 12
    sidesfreq::Vector{Int} #[1,2,2,1,3,2,1]
    resulttypes::Vector{Symbol} #[:blank, :success, :advantage, :triumph]
    resultsinside::Vector{Vector{Int}} #[[1,0,0,0], [0,1,0,0],[0,2,0,0],[0,0,1,0],[0,1,1,0],[0,0,2,0],[0,0,0,1]]
end

function SymbolDice(sides::Array,freq::Array=[]) #User friendly Constructor for categorial dice
    
    #TODO: identificar caras repetidas y unirlas
    (freq==[]) && (freq = ones(length(r))) #If f is empty then each results happens once in the dice
    (sum(freq) < length(sides)) && error("Más resultados en el dado que caras") #El vector rep contiene cuantas veces se repita cada resultado y debe ser igual a las caras
     
    r = [] # Unique results categories

    for sᵢ in sides # Extracts the results categories
        for j in sᵢ
            push!(r,j)
        end
    end
    unique!(r) # Unique category of results as Symbol
    
    m = [] # count the results of each side

    for sᵢ in sides # Counts the results present in each side as 1 and 0
        temp = fill(0,length(r))
            for j in sᵢ
                temp += (j .== r) 
            end
        push!(m,temp)
    end

    r = Symbol.(r)
    SymbolDice(sum(freq),freq,r,m) 
end


"TODO hybrid dice"
struct HybridDice end


"Tables.jl compliant Struct for storing dice probabilities results"
struct DiceProbabilities <: Tables.AbstractColumns
    headers::Vector{Symbol}
    dicenamecols::Int
    data::Array{Real}
    lookup::Dict{Symbol, Int}
end
