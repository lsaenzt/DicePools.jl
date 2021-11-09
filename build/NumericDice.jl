#------------------------------------------------------------------------------------------------------
# Basic roll functions
#------------------------------------------------------------------------------------------------------
"""
    roll(n,dice,mod;[name=dice.name])

mod::Int is a modifier to apply to each result

# Example    
    roll(3,d6,+2)
    roll(3,custom,"fudge")
""" 
function roll(n::Union{Int,UnitRange{Int}},dice::StandardDice,mod::Int=0;name::String=dice.name) # Fast method for StandardDice

    A = Array{Union{Int, Float64},2}(undef,0,3) 
    s = dice.sides
   
    for nᵢ in n  # n number of dice to roll
        
        if nᵢ == 0
            continue
        elseif nᵢ < 0 # Negative dice
            neg = true
            nᵢ = abs(nᵢ)
        else 
            neg = false
        end

     # Based on https://mathworld.wolfram.com/Dice.html.
     allcomb = BigInt(s)^nᵢ # Todas las posibles combinaciones de caras que pueden salir 

     r = zeros(Int,nᵢ*s-nᵢ+1) # Array length is max result minus min result
     f = zeros(Float64,nᵢ*s-nᵢ+1)
     
        for p in nᵢ:s*nᵢ # Computes 'c' as described in https://mathworld.wolfram.com/Dice.html
            c=0
            for k in 0:floor(Int,(p-nᵢ)/s)
            c = c + (-1)^k*binomial(BigInt(nᵢ),k)*binomial(BigInt(p-s*k-1),nᵢ-1)
            end
            r[p-nᵢ+1] = p + mod
            f[p-nᵢ+1] = c/allcomb*100
        end 
    # Concatenate results for each n
        if neg 
        A = vcat(A,hcat(fill(-nᵢ,nᵢ*s-nᵢ+1),r.-(s*nᵢ+nᵢ),f)) #Results in Standard Dice are 'symmetric'
        else
        A = vcat(A,hcat(fill(nᵢ,nᵢ*s-nᵢ+1),r,f))
        end
    end

    A[:,1:end-1]=Int.(A[:,1:end-1]) # Just for aesthetics. Number of dice and results as Int

    # Creates a DiceProbabilities struct that is Tables.jl compliant
    name = (mod==0) ? name : string(n,dice.name,"+",mod)
    cols = [Symbol(name),:Result,:Probability]   
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Tables.jl compliant
end

function roll(n::Union{Int,UnitRange{Int}},dice::CustomDice,mod::Int=0;name::String=dice.name) # Method for non-standard numeric dice. Calculation is done recursively

    A = Array{Union{Int, Float64},2}(undef,0,3) 

    for nᵢ in n

        if nᵢ == 0
            continue
        elseif nᵢ < 0 # Negative dice
            neg = true
            nᵢ = abs(nᵢ)
        else 
            neg = false
        end

    r,p = recursiveroll_sum(nᵢ,dice)
    (mod != 0) && (r = r.+mod)

        if neg
        A = vcat(A,hcat(fill(-nᵢ,length(r)),sortslices([-r p],dims=1,by= x-> x[end-1])))
        else
        A = vcat(A,hcat(fill(nᵢ,length(r)),r,p))
        end
    end
    A[:,1:end-1]=Int.(A[:,1:end-1]) # Just for aesthetics. Number of dice and results as Int

    name = (mod==0) ? name : string(n,name,"+",mod)
    cols = [Symbol(name),:Result,:Probability]   
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)]))
end

function recursiveroll_sum(n,dice::NumericDice)

    dr = dice.results 
    dp = fill(100/dice.sides,dice.sides)
    
    if n==1
        ur = unique(dr)
        p = [sum([(c == x)*f for (c,f) in zip(dr,dp)]) for x in ur]

    else
        dr₋₁,dp₋₁ = recursiveroll_sum(n-1,dice)

        results = [i+j for i in dr₋₁, j in dr]
        freq = [i*j/100 for i in dp₋₁, j in dp]

        ur = unique(results)
        p = [sum([(c == x)*f for (c,f) in zip(results,freq)]) for x in ur]
        
    end
    return ur,p
end

"""
    customroll(n,dice,[name=dice.name]) do r
        f(r)
    end

Applies a function to each individual result. 
Calculates every single possible result. It takes time if the number of possibilities is high.

# Example. Drop lowest
    customroll(3,d6) do r
        sum(r[2:end])
    end
"""
function customroll(f::Function,n::Union{Int,UnitRange{Int}},dice::NumericDice;name::String="Dice") 

    minimum(n)<=0 && return error("Must roll a positive number of dice")

    A = Array{Union{Int, Float64},2}(undef,0,3)
    idx = 1:dice.sides # Combinations on idx deals with repeated values in a Customdice

    for nᵢ in n
    # 1. Calculate the probability each combination of sides. First taking into account combinations of results and secondly considering repeated sides on a die
    allcomb = dice.sides^nᵢ # All possible combinations for the given number of sides and dice
    c = with_replacement_combinations(idx,nᵢ)
    r = OrderedDict{Int, Float64}()

        for cᵢ in c
            rep = count_repeated(cᵢ)    # This allows faster splat in the next line       
            reord = multinomial(rep...) # All possible dice combinatios that lead to the same result. E.g. 20 ways of getting 3 dice with one result and 3 dice with other
            prob = reord/allcomb*100
            @inbounds s = f(@view dice.results[cᵢ]) # Function applied to the individual results
            r[s] = get(r,s,0) + prob
        end

    sort!(r)

    # 2. Concatenate results
    A = vcat(A,hcat(fill(nᵢ,length(r)),collect(keys(r)),collect(values(r))))
    end

    A[:,1:end-1]=Int.(A[:,1:end-1]) # Just for aesthetics. Number of dice and results as Int

    # 3. Creates a DiceProbabilties Struct
    cols = [Symbol(name),:Result,:Probability]
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Table.jl compliant
end

"Count repeated values in an ordered array" # Avoids using multiexponents(cᵢ...) in roll(f,n,dice) which is slower
function count_repeated(a::Array)
    i = 1
    d = 1
    for j in 2:length(a) # El primer bloque de repetidos en unidades, el segundo en decenas, el tercero en centenas...
       if a[j]==a[j-1] 
         i += d
       else
         d *= 10
         i += d
        end
    end
    digits(i) # Descomposición de número
end

#---------------------------------------------------------------------------------------------------
# Overloading of Julia.Base arithmetic functions
#---------------------------------------------------------------------------------------------------
import Base.*, Base.+, Base.-

*(n::Union{Int,UnitRange{Int}}, d::Dice) = roll(n,d)

+(a::DiceProbabilities,b::DiceProbabilities,c::DiceProbabilities...) = pool(a,b,c...)

function +(a::DiceProbabilities,b::Int)
    (length(headers(a)) - dicenamecols(a)) > 2 && return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier
    data(a)[:,end-1] = data(a)[:,end-1] .+ b
    a
end

function -(a::DiceProbabilities,b::Int)
    (length(headers(a)) - dicenamecols(a)) > 2 && return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier
    data(a)[:,end-1] = data(a)[:,end-1] .- b
    a
end

function -(a::DiceProbabilities,b::DiceProbabilities)
    (length(headers(a)) - dicenamecols(a)) > 2 && return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier
    (length(headers(b)) - dicenamecols(b)) > 2 && return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier
    
    # Modifications for the 'negative' die
    headers(b)[1] = Symbol("-",headers(b)[1]) # Die name with a minus
    data(b)[:,end-1] = data(b)[:,end-1] .* -1 # Results negative for substracting
    # Sorting probabilities to get the results also sorted when 'pooled'
    sorted_b = DiceProbabilities(headers(b), dicenamecols(b), sortslices(data(b),dims=1,by= x -> x[end-1]), Dict([j => i for (i,j) in enumerate(headers(b))]))
   
    pool(a,sorted_b)
end