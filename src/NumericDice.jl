# TODO: Crear macro para @roll 3d6 

# A partir de cierto número hacer overflow ¿BigInt?
"Fast method for standard numeric rolls. E.g. 3d6" #TODO: add modifier to name -> d6+1
function roll(n::Union{Int,OrdinalRange},dice::StandardDice,mod::Int=0,name::String=string("d",dice.sides))

    A = Array{Int64,2}(undef,0,3) 
    s = dice.sides

    for nᵢ in n  # n number of dice to roll
     # Based on https://mathworld.wolfram.com/Dice.html. Superfast
     allcomb = s^nᵢ # Todas las posibles combinaciones de caras que pueden salir 
     # Initializes array for storing results
     r = zeros(nᵢ*s-nᵢ+1,2) # Array length is max result minus min result

        for p in nᵢ:s*nᵢ # Computes 'c' as described in https://mathworld.wolfram.com/Dice.html
            c=0
            for k in 0:floor(Int,(p-nᵢ)/s)
            c = c + (-1)^k*binomial(nᵢ,k)*binomial(p-s*k-1,nᵢ-1)
            end
            r[p-nᵢ+1,1] = p + mod
            r[p-nᵢ+1,2] = c/allcomb*100
        end
      
    # Concatenate results for each n
    A = vcat(A,hcat(fill(nᵢ,nᵢ*s-nᵢ+1),r))

    end
    # Creates a DiceProbabilities struct that is Tables.jl compliant 
     n = [Symbol(name),:Result,:Probability]   
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Tables.jl compliant
end

"""
This method is for non-standard numeric dice. E.g: Fugde dice
Calculation is done iterating over the possible results
"""
# TODO: Read name directly from CategoricalDice input. Impossible?
 
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

"""
This method allows to apply a function to each result before summing the results

e.g. drop lowest
 roll(3,d6) do r
    r[2:end]
 end
"""
# On par with AnyDice but more flexible
function roll(f::Function,n::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0,name::String="Dice")
   
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
            s= sum(f(cᵢ)) + mod
            r[s] = get(r,s,0) + prob            
        end

     rₛ = sort(r)
 # 2. Concatenate results
    A = vcat(A,hcat(fill(n,length(r)),collect(keys(rₛ)),collect(values(rₛ))))
    end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame 
     n = [Symbol(name),:Result,:Probability] 
     #TODO:Read name directly from CategoricalDice input. Impossible?     
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant
 end