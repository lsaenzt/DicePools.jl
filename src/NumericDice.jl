# TODO: Crear macro para @roll 3d6 

# A partir de cierto número hacer overflow ¿BigInt? ¿Cambiar a roll(n,s::NumericDice)?
"Fast method for standard numeric rolls. E.g. 3d6" # TODO: add modifier to name -> d6+1
function roll(n::Union{Int,OrdinalRange},dice::StandardDice,mod::Int=0,name::String=string("d",dice.sides))

    A = Array{Int64,2}(undef,0,3) 
    s = dice.sides

    for nᵢ in n  # n number of dice to roll
     # Based on https://mathworld.wolfram.com/Dice.html. Superfast
     allcomb = BigInt(s)^nᵢ # Todas las posibles combinaciones de caras que pueden salir 

     r = zeros(nᵢ*s-nᵢ+1,2) # Array length is max result minus min result

        for p in nᵢ:s*nᵢ # Computes 'c' as described in https://mathworld.wolfram.com/Dice.html
            c=0
            for k in 0:floor(Int,(p-nᵢ)/s)
            c = c + (-1)^k*binomial(BigInt(nᵢ),k)*binomial(BigInt(p-s*k-1),nᵢ-1)
            end
            r[p-nᵢ+1,1] = p + mod
            r[p-nᵢ+1,2] = c/allcomb*100
        end 
    # Concatenate results for each n
    A = vcat(A,hcat(fill(nᵢ,nᵢ*s-nᵢ+1),r))
    end
    
    # Creates a DiceProbabilities struct that is Tables.jl compliant 
     cols = [Symbol(name),:Result,:Probability]   
     DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Tables.jl compliant
end

"""
This method is for non-standard numeric dice. E.g: Fugde dice
Calculation is done recursively
"""
function roll(n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0,name::String="Dice")
    
    r = recursiveroll(n,dice)
    (mod != 0) && (r[:,1] = r[:,1].+mod)

    cols = [Symbol(name),:Result,:Probability]   
    DicePools.DiceProbabilities(cols,1,hcat(fill(n,size(r,1)),r),Dict([j => i for (i,j) in enumerate(cols)]))
end

function recursiveroll(n,dice::NumericDice)

    basedie = [dice.results fill(1/dice.sides,dice.sides)]
    if n==1
        r = basedie
    else
        d₋₁ = recursiveroll(n-1,dice)

        dˢ = repeat(d₋₁,inner = (dice.sides,1))
        sᵈ = repeat(basedie,outer = (size(d₋₁,1),1))

        results = dˢ[:,1].+sᵈ[:,1]
        freq = dˢ[:,2].*sᵈ[:,2]

        ur = unique(results)
        p = [sum([(c == x)*f for (c,f) in zip(results,freq)]) for x in ur]
        
        r = [ur p] # TODO: sumar modificador a ur
    end
    return r
end


"""
Apples a function to each result. Slow when the number of possible results is high.

e.g. drop lowest
 roll(3,d6) do r
    sum(r[2:end])
 end
"""
# On par with AnyDice but more flexible
function roll(f::Function,n::Union{Int,OrdinalRange},dice::NumericDice,name::String="Dice")
   
    A = Array{Int64,2}(undef,0,3) 
 
    for nᵢ in n
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
    c = with_replacement_combinations(dice.results,nᵢ)
    m = multiexponents(dice.sides,nᵢ)
    allcomb = dice.sides^nᵢ # Todas las posibles combinaciones de caras que pueden salir 
    r = OrderedDict{Int, Number}()
 
        for (cᵢ,mᵢ) in zip(c,m)          
            reord = multinomial(mᵢ...) # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados on 4 y 3 dados 2 
            prob = reord/allcomb*100
            s = f(cᵢ)
            r[s] = get(r,s,0) + prob            
        end

    rₛ = sort(r)
 # 2. Concatenate results
    A = vcat(A,hcat(fill(n,length(r)),collect(keys(rₛ)),collect(values(rₛ))))
    end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame 
    cols = [Symbol(name),:Result,:Probability] 
    #TODO:Read name directly from CategoricalDice input. Impossible?     
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Table.jl compliant
end

"""
Drop lowest or highest results
"""
function roll(n::Union{Int,OrdinalRange},dice::NumericDice,name::String="Dice";droplowest::Int=0,drophighest::Int=0)
    
    (droplowest+drophighest)>n && return error("More dice dropped than the number of dice rolled")

    roll(n,dice) do r
        sum(r[begin+droplowest:end-drophighest])
    end
end

"""
Take mid results
"""
function roll(n::Union{Int,OrdinalRange},dice::NumericDice,name::String="Dice";mid::Int=1)
    
    mid>n && return error("Mid cannot be higher than the number of dice")

    l = n - mid
    drop = div(l,2)
    
    roll(n,dice) do r
        sum(r[begin+drop:end-drop-isodd(l)])
    end
end

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
Sample of 'rep' rolls of an 'n' dice of type 'd'
"""
# TODO: Hay que hacer una simulación para operaciones extrañas de resultados 
function sampleroll(n::Int,d::NumericDice, rep::Int)
    results = Vector{Int}(undef,rep)
    for i in 1:rep
        s = 0
        for i in 1:n
            s = s+ rand(d.results)
        end
        results[i] = s
    end
    ur = sort(unique(results))
    freq = [sum([c == x for c in results]) for x in ur] 
    freq = freq./length(results).*100

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