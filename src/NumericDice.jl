# Note: Use Real for getting Int for the number of dice and results and float for probabilities
"""
    roll(n,dice,mod,[name])
Fast method for standard numeric rolls. E.g. 3d6+2
""" 
function roll(n::Union{Int,OrdinalRange},dice::StandardDice,mod::Int=0;name::String=dice.name)

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

"""
     roll(n,dice,mod,[name])

This method is for non-standard numeric dice. E.g: Fugde dice. Calculation is done recursively
mod::Int is a modifier to apply to each result
"""
function roll(n::Union{Int,OrdinalRange},dice::CustomDice,mod::Int=0;name::String=dice.name)
    #TODO: for i in n para varias tiradas.
    A = Array{Real,2}(undef,0,3) 

    for nᵢ in n
        r = recursiveroll_sum(nᵢ,dice)
        (mod != 0) && (r[:,1] = r[:,1].+mod)

    A = vcat(A,hcat(fill(nᵢ,size(r,1)),r))
    end

    name = (mod==0) ? name : string(n,name,"+",mod)
    cols = [Symbol(name),:Result,:Probability]   
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)]))
end

function recursiveroll_sum(n,dice::NumericDice)

    basedie = Real[dice.results fill(100/dice.sides,dice.sides)]
    if n==1
        r = basedie
    else
        d₋₁ = recursiveroll_sum(n-1,dice)

        dˢ = repeat(d₋₁,inner = (dice.sides,1))
        sᵈ = repeat(basedie,outer = (size(d₋₁,1),1))

        results = dˢ[:,1].+sᵈ[:,1]
        freq = dˢ[:,2].*sᵈ[:,2]/100

        ur = unique(results)
        p = [sum([(c == x)*f for (c,f) in zip(results,freq)]) for x in ur]
        
        r = Real[ur p]
    end
    return r
end

"""
    roll(n,dice,[name]) do r
        f(r)
    end

Applies a function to each result. Slow when the number of possible results is high.

# Example. Drop lowest
    roll(3,d6) do r
        sum(r[2:end])
    end
"""

function roll(f::Function,n::Union{Int,OrdinalRange},dice::NumericDice;name::String="Dice")   

    A = Array{Real,2}(undef,0,3)  

    for nᵢ in n
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
    c = with_replacement_combinations(dice.results,nᵢ)
    allcomb = dice.sides^nᵢ # Todas las posibles combinaciones de caras que pueden salir 
    r = OrderedDict{Int, Real}() 
        for cᵢ in c
            rep = count_repeated(cᵢ)          
            reord = multinomial(rep...) # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados con 4 y 3 dados con 2 
            prob = reord/allcomb*100
            s = f(cᵢ)
            r[s] = get(r,s,0) + prob
        end
    sort!(r)
    # 2. Concatenate results
    A = vcat(A,hcat(fill(nᵢ,length(r)),collect(keys(r)),collect(values(r))))
    end

    # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame
    cols = [Symbol(name),:Result,:Probability]
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Table.jl compliant
end

"Count repeated values in an ordered array" # Sustituye el uso de multiexponents(dice.sides,nᵢ) que es más lento.
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


# Nota: Las funciones siguientes no se pueden llamar "roll". El multiple dispatch toma sólo argumentos posiciones y se confunde entre estas dos y la de antes
"""
    rollanddrop(n,dice,mod;[droplowest=0],[drophighest=0],[name])

Method for dropping lowest or highest results with kwarg 'droplowest::Int' and/or 'drophighest::Int'
""" 
function rollanddrop(n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0;droplowest=0,drophighest=0,name="Dice") 

    (droplowest+drophighest)>n && return error("More dice dropped than the number of dice rolled")

    roll(n,dice) do r
        sum(r[begin+droplowest:end-drophighest]) + mod
    end
end

"""
    takemid(n,dice,[mod=0];[mid=1],[name])

Methods for hoose mid results with kwarg 'mid::Int'
""" 
function takemid(n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0;mid=1,name="Dice")
    
    mid>n && return error("Mid cannot be higher than the number of dice")

    l = n - mid
    drop = div(l,2)
    
    roll(n,dice) do r
        sum(r[begin+drop:end-drop-isodd(l)]) + mod
    end
end

function explode() end

function rolltobeat() end

function recursiveroll_beat(n,dice::NumericDice;target::Int) end # ¿Versión por encima de y por debajo de?

"""
Single random result of die roll
"""
function singleroll(n::Int,d::NumericDice,mod::Int=0)
    s=0
    for i in 1:n
        s = s+ rand(d.results)
    end
    return s+mod
end

"""
Sample of 'rep' rolls of an 'n' dice of type 'd' applying 'f' to each result
"""
function sampleroll(f::Function, n::Int,d::NumericDice, rep::Int)
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


#---------------------------------------------------------------------------------------------------------------------------------------------

#= OLD VERSION

function roll(n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0,name::String="Dice")
    
    A = Array{Int64,2}(undef,0,3)
 
    for nᵢ in n
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
    # Todas las combinaciones de resultado. Ej: 1) 6 ochos 2) 3 seises, 2 unos y 1 tres...
    c = multiexponents(dice.sides,nᵢ)
    allcomb = dice.sides^nᵢ # Todas las posibles combinaciones de caras que pueden salir 
    r = OrderedDict{Int, Number}()
 
        for cᵢ in c
            reord = multinomial(cᵢ...) # Variaciones: todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados on 4 y 3 dados 2 
            prob = reord/allcomb*100            
            s = sum(cᵢ.*dice.results) + mod
            r[s] = get(r,s,0) + prob         
        end

     rₛ = sort(r)
     
 # 2. Concatenates results
    A = vcat(A,hcat(fill(n,length(r)),collect(keys(rₛ)),collect(values(rₛ))))

    end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame
 
     n = [Symbol(name),:Result,:Probability]   
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant
 end
=#