# Note: Usage of Real for getting Int for the number of dice and results and float for probabilities
#------------------------------------------------------------------------------------------------------
# roll functions
#------------------------------------------------------------------------------------------------------
"""
    roll(n,dice,mod;[name=dice.name])

mod::Int is a modifier to apply to each result

# Example    
    roll(3,d6,+2)
    roll(4, custom;name="foo")
""" 
function roll(n::Union{Int,OrdinalRange},dice::StandardDice,mod::Int=0;name::String=dice.name) # Fast method for StandardDice

    A = Array{Real,2}(undef,0,3) 
    s = dice.sides

    for nᵢ in n  # n number of dice to roll
     # Based on https://mathworld.wolfram.com/Dice.html.
     allcomb = BigInt(s)^nᵢ # Todas las posibles combinaciones de caras que pueden salir 

     r = zeros(Int,nᵢ*s-nᵢ+1) # Array length is max result minus min result
     f = zeros(Real,nᵢ*s-nᵢ+1)
     
        for p in nᵢ:s*nᵢ # Computes 'c' as described in https://mathworld.wolfram.com/Dice.html
            c=0
            for k in 0:floor(Int,(p-nᵢ)/s)
            c = c + (-1)^k*binomial(BigInt(nᵢ),k)*binomial(BigInt(p-s*k-1),nᵢ-1)
            end
            r[p-nᵢ+1] = p + mod
            f[p-nᵢ+1] = c/allcomb*100
        end 
    # Concatenate results for each n
    A = vcat(A,hcat(fill(nᵢ,nᵢ*s-nᵢ+1),r,f))
    end
    
    # Creates a DiceProbabilities struct that is Tables.jl compliant
    name = (mod==0) ? name : string(n,dice.name,"+",mod)
    cols = [Symbol(name),:Result,:Probability]   
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Tables.jl compliant
end

function roll(n::Union{Int,OrdinalRange},dice::CustomDice,mod::Int=0;name::String=dice.name) # Method for non-standard numeric dice. Calculation is done recursively
    
    A = Array{Real,2}(undef,0,3) 

    for nᵢ in n
        r,p = recursiveroll_sum(nᵢ,dice)
        (mod != 0) && (r = r.+mod)

    A = vcat(A,hcat(fill(nᵢ,length(r)),r,p))
    end

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
Calculate every single possible result. It takes time if the number of possibilities is high.

# Example. Drop lowest
    customroll(3,d6) do r
        sum(r[2:end])
    end
"""
function customroll(f::Function,n::Union{Int,OrdinalRange},dice::NumericDice;name::String="Dice") 

    A = Array{Real,2}(undef,0,3)
    idx = 1:dice.sides # Combinations on idx deals with repeated values in a Customdice

    for nᵢ in n
    # 1. Calculate the probability each combination of sides. First taking into account combinations of results and secondly considering repeated sides on a die
    allcomb = dice.sides^nᵢ # All possible combinations for the given number of sides and dice
    c = with_replacement_combinations(idx,nᵢ)
    r = OrderedDict{Int, Real}()

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

#------------------------------------------------------------------------------------------------------
# roll functions
#------------------------------------------------------------------------------------------------------
# Nota: Las funciones siguientes no se pueden llamar "roll". El multiple dispatch toma sólo argumentos posicionales y se confunde entre estas dos y la de antes
"""
    drop(n,dice,mod;[droplowest=0],[drophighest=0],[name])

Drop lowest or highest results

# Arguments
 - droplowest::Int' and/or 'drophighest::Int': number of dice to be dropped

# Example
    drop(5,d8; droplowest=2)
""" 
function drop(n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0;droplowest=0,drophighest=0,name="Dice") 

    (droplowest+drophighest)>n && return error("More dice dropped than the number of dice rolled")

    customroll(n,dice,name) do r
        sum(r[begin+droplowest:end-drophighest]) + mod
    end
end

"""
    takemid(n,dice,[mod=0];[mid=1],[name])

Sum mid dice results. The number of mid dice to sum is set by the 'mid::Int' keyword
""" 
function takemid(n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0;mid=1,name="Dice")
    
    mid>n && return error("Mid cannot be higher than the number of dice")

    l = n - mid
    drop = div(l,2)
    
    customroll(n,dice,name) do r
        sum(r[begin+drop:end-drop-isodd(l)]) + mod
    end
end

"""
    beattarget(n,dice;target=maximum(dice.results),equal=true, [name])

Beating a target number with n dice. If equal is set to true, matching the target counts as success
""" 
function beattarget(n,dice::NumericDice;target::Int=maximum(dice.results),name=dice.name, equal=true) 
    equal ? (f = ≥) : (f = >) # if equal is true use equal or greater, else use greater
    dice = CustomDice([f(i,target) ? 1 : 0 for i in dice.results],name) # Sides that count as 1 success
    roll(n,dice)
end

"""
    rollunder(n,dice;target=maximum(dice.results),equal=true, [name])

Roll below a target number with n dice. If equal is set to true, matching the target counts as success
""" 
function rollunder(n,dice::NumericDice;target::Int=maximum(dice.results),name=dice.name, equal=true) 
    equal ? (f = ≤) : (f = <) # if equal is true use equal or less, else use less
    dice = CustomDice([f(i,target) ? 1 : 0 for i in dice.results],name) # Sides that count as 1 success
    roll(n,dice)
end


function explode() end

"""
Single random result of die roll
"""
function singleroll(n::Int,d::NumericDice,mod::Int=0)
    s=0
    for i in 1:n
        s = s + rand(d.results)
    end
    return s+mod
end

"""
Sample of 'rep' rolls of an 'n' dice of type 'd' applying 'f' to each result
"""
function sampleroll(f::Function, n::Int, d::NumericDice, rep::Int)
    res = Vector{Int}(undef,rep)
    for i in 1:rep
        r = Vector{Int}(undef,d.sides)
        for j in 1:n
            r[j] = rand(d.results)
        end
        res[i] = f(r)
    end
    ur = sort(unique(res))
    freq = [sum([c == x for c in res]) for x in ur] 
    freq = freq./length(res).*100

    return [ur freq]
end

#---------------------------------------------------------------------------------------------------
# Methods for Julia.Base arithmetic functions with Dice
#---------------------------------------------------------------------------------------------------
import Base.*, Base.+, Base.-

*(n::Int, d::Dice) = roll(n,d)

+(a::DiceProbabilities,b::DiceProbabilities,c::DiceProbabilities...) = pool(a,b,c...)

function +(a::DiceProbabilities,b::Int)
    (length(headers(a)) - dicenamecols(a)) > 2 && return error("Non-numeric die with more than 1 results column") # If more thna one column with results it is not possible to apply a modifier
    data(a)[:,end-1] = data(a)[:,end-1] .+ b
    a
end

function -(a::DiceProbabilities,b::Int)
    (length(headers(a)) - dicenamecols(a)) > 2 && return error("Non-numeric die with more than 1 results column") # If more thna one column with results it is not possible to apply a modifier
    data(a)[:,end-1] = data(a)[:,end-1] .- b
    a
end

function -(a::DiceProbabilities,b::DiceProbabilities)
    (length(headers(a)) - dicenamecols(a)) > 2 && return error("Non-numeric die with more than 1 results column") # If more thna one column with results it is not possible to apply a modifier
    (length(headers(b)) - dicenamecols(b)) > 2 && return error("Non-numeric die with more than 1 results column") # If more thna one column with results it is not possible to apply a modifier
    
    headers(b)[1] = Symbol("-",headers(b)[1])
    data(b)[:,end-1] = data(b)[:,end-1] .* -1
    pool(a,b)
end