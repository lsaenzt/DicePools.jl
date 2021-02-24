# TODO: Crear macro para @roll 3d6 
# Iterator.product es una alternativa para crear todas las combinaciones
# CHECK for drop lowest-highest:https://stackoverflow.com/questions/50690348/calculate-probability-of-a-fair-dice-roll-in-non-exponential-time

"Fast method for standard numeric rolls. E.g. 3d6" #TODO: add modifier to name -> d6+1
function roll(N::Union{Int,OrdinalRange},dice::StandardDice,mod::Int=0,name::String=string("d",dice.sides))

    A = Array{Int64,2}(undef,0,3) 
    s = dice.sides

    for n in N # n number of dice to roll

     # Based on https://mathworld.wolfram.com/Dice.html. Superfast
     allcomb = s^n # Todas las posibles combinaciones de caras que pueden salir
 
     # Initializes array for storing results
     r = zeros(n*s-n+1,2) # Array length is max result minus min result

        for p in n:s*n # Computes 'c' as described in https://mathworld.wolfram.com/Dice.html
            c=0
            for k in 0:floor(Int,(p-n)/s)
            c = c + (-1)^k*binomial(n,k)*binomial(p-s*k-1,n-1)
            end
            r[p-n+1,1] = p + mod
            r[p-n+1,2] = c/allcomb*100
        end
      
    # Concatenate results for each n
    A = vcat(A,hcat(fill(n,n*s-n+1),r))

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
 
function roll(N::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0,name::String="Dice")
    
    A = Array{Int64,2}(undef,0,3)
 
    for n in N
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
 
      # Todas las combinaciones de resultado. Ej: 1) 6 ochos 2) 3 seises, 2 unos y 1 tres...
     c = multiexponents(dice.sides,n)

     allcomb = dice.sides^n # Todas las posibles combinaciones de caras que pueden salir
 
     r = Dict{Int, Number}()
 
        for cᵢ in c

            reord = multinomial(cᵢ...) # Variaciones: todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados on 4 y 3 dados 2 
            prob = reord/allcomb*100            
            s = sum(cᵢ.*dice.results) + mod
            r[s] = get(r,s,0) + prob
            
        end

        
     
 # 2. Concatenates results

    A = vcat(A,hcat(fill(n,length(r)),collect(keys(rₛ)),collect(values(rₛ))))

    end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame
 
     n = [Symbol(name),:Result,:Probability]   
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant
 end

"""
This method allows to apply a function to each result

e.g. drop lowet
 roll(3,d6) do r
    sum(r[2:end])
 end

NOT TESTED. DOES NOT WORK WITH STANDARDICE!!!

"""

function roll(f::Function,N::Union{Int,OrdinalRange},dice::NumericDice,mod::Int=0,name::String="Dice")
    A = Array{Int64,2}(undef,0,3) 
 
    for n in N
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
 
      # Todas las combinaciones de resultado. Ej: 1) 6 ochos 2) 3 seises, 2 unos y 1 tres...
     c = with_replacement_combinations(dice.results,n)
     allcomb = dice.sides^n # Todas las posibles combinaciones de caras que pueden salir
 
     r = Dict{Int, Number}()
 
        for (j,numbercombs) in enumerate(c)
            l=1
            for k in 2:n
                (numbercombs[k] != numbercombs[k-1]) && (l=l+1)
            end
            # Revisar esta línea. Tarda mucho
            reord = factorial(n,n-l+1) # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados on 4 y 3 dados 2 
            prob = reord/allcomb*100
            
            s= f(numbercombs) + mod

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