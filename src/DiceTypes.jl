export SymbolDice, CustomDice, StandardDice

abstract type Dice end
"Numeric dice have results that are numbers to be added up"
abstract type NumericDice <:Dice end

"A numeric dice with any combination of numbers "
struct CustomDice <:NumericDice
    name::String
    sides::Int #e.g. 3
    results::Vector{Int} #e.g. [-1,0,1]

    CustomDice(n,s,r) = s != length(r) ? error("number of sides do not match number of results") : new(n,s,sort(r))
end

"StandardDice have values ranging from 1 to number of sides. E.g. 1:20"
struct StandardDice <:NumericDice
    name::String
    sides::Int #e.g. 8
    results::UnitRange{Int} #e.g. 1:8
end

"Outer constructors for NumericDice"
CustomDice(r::Vector{Int}) = CustomDice("Dice",length(r),r)
CustomDice(r::Vector{Int},name::String) = CustomDice(name,length(r),r)
StandardDice(s::Int) = StandardDice(string("d",s),s,1:s)

"Symbol dice produce descriptive results that are combined"
struct SymbolDice <: Dice 
    name::String
    sides::Int #e.g. 12
    sidesfreq::Vector{Int} #[1,2,2,1,3,2,1] # How many times a specific side is repeated in the die. The order must match "symbolsinside"
    symbols::Vector{Symbol} #[:blank, :success, :advantage, :triumph]
    symbolsinside::Vector{Vector{Int}} #[[1,0,0,0], [0,1,0,0],[0,2,0,0],[0,0,1,0],[0,1,1,0],[0,0,2,0],[0,0,0,1]]
end

"User friendly Constructor for Symbol dice"
function SymbolDice(sides::Array,freq::Array=[],name::String="Dice")

    (freq==[]) && (freq = ones(length(sides))) #If f is empty then each results happens once in the die
    (sum(freq) < length(sides)) && error("More results than sides in the die") #El vector rep contiene cuantas veces se repita cada resultado y debe ser igual a las caras
    
    # Unify repeated sides
    ur = unique(sides)
    p = [sum([(c == x)*f for (c,f) in zip(sides,freq)]) for x in ur]
    
    # Store unique symbols in die
    s = [] 
    for sᵢ in ur # Extracts the symbols in die
        for j in sᵢ
            push!(s,j)
        end
    end
    unique!(s) # Unique die symbols
    
    # Count the results of each side
    m = [] 
    for sᵢ in ur # Counts the results present in each side as 1 and 0
        temp = fill(0,length(s))
            for j in sᵢ
                temp += (j .== s) 
            end
        push!(m,temp)
    end

    s = Symbol.(s)
    SymbolDice(name,sum(p),p,s,m) 
end


"TODO hybrid dice"
struct HybridDice <:Dice
    name::String
    sides::Int #e.g. 12
    results::Vector{Int} #e.g. [1:10]
    symbolsidefreq::Vector{Int} #[1,1]
    symbols::Vector{Symbol} #[:sauroneye, :hope]
    symbolsinside::Vector{Vector{Int}} #[[1,0], [0,1]]
end


"Tables.jl compliant Struct for storing dice probabilities results"
struct DiceProbabilities <: Tables.AbstractColumns
    headers::Vector{Symbol}
    dicenamecols::Int
    data::Array{Real}
    lookup::Dict{Symbol, Int}
end