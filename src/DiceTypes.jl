export CategoricalDice, NumericDice #HybridDice


"Numeric dice have results that are numbers to be summed"
struct NumericDice
    sides::Int #e.g. 8
    results::Vector{Int} #e.g. [-1,0,1]
    modifier::Int # -1
end

"Outer constructors"
NumericDice(s::Int) = NumericDice(s,1:s,0)
NumericDice(s::Int,m::Int) = NumericDice(s,1:s,m)
NumericDice(r::Vector{Int}) = NumericDice(length(r),r,0)
NumericDice(r::Vector{Int},m::Int) = NumericDice(length(r),r,m)

"Categorical dice have descriptive results than are combined"
struct CategoricalDice
    sides::Int #e.g. 12
    sidesfreq::Vector{Int} #[1,2,2,1,3,2,1]
    resulttypes::Vector{Symbol} #[:blank, :success, :advantage, :triumph]
    resultsinside::Vector{Vector{Int}} #[[1,0,0,0], [0,1,0,0],[0,2,0,0],[0,0,1,0],[0,1,1,0],[0,0,2,0],[0,0,0,1]]
end

function CategoricalDice(sides::Array,freq::Array=[]) #User friendly Constructor for categorial dice
    
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
    CategoricalDice(sum(freq),freq,r,m) 
end


"TODO hybrid dice"
struct HybridDice end



