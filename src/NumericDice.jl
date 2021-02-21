
# TODO: Crear macro para @roll 3d6 
# Iterator.product es una alternativa para crear todas las combinaciones
# TODO: evaluar alternativa con https://mathworld.wolfram.com/Dice.html y multinomials

# Todavía no funciona:
function testroll(n::Int, s::Int)
    for p in n:s*n
        c=0
        for k in 0:floor(Int,(p-n)/s)
           c = c + (-1)^k*binomial(n,k)*binomial(p-s*k-1,n-1)
        end
        println(p," ",c/(s^n)*100)
    end   
end
#  also https://stackoverflow.com/questions/50690348/calculate-probability-of-a-fair-dice-roll-in-non-exponential-time


"This method is for standard numeric rolls. E.g. 3d6"
function roll(iter::Union{Int,OrdinalRange},dice::StandardDice,name::String="Dice")

    A = Array{Int64,2}(undef,0,3) 
    s = dice.sides

    for n in iter
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
 
     # Basado en https://mathworld.wolfram.com/Dice.html. Es súperrápido

     allcomb = s^n # Todas las posibles combinaciones de caras que pueden salir
 
     # Inicializo un array para almacenar los resultados con el rango de valores posibles
     r = zeros(n*s-n+1,2) #n*s es el máximo resultado y n el mínimo para un dado standard

     for p in n:s*n
        c=0
        for k in 0:floor(Int,(p-n)/s)
           c = c + (-1)^k*binomial(n,k)*binomial(p-s*k-1,n-1)
        end
        r[p-n+1,1] = p + dice.modifier
        r[p-n+1,2] = c/allcomb*100
    end
      
 # 2. Concatenate results

    A = vcat(A,hcat(fill(n,n*s-n+1),r))

    end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame
 
     n = [Symbol(name),:Result,:Probability]
 
     #TODO:Read name directly from CategoricalDice input. Impossible?
     
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant
 
 end

 """
This method allows to apply a function to each result
"""

function roll(iter::Union{Int,OrdinalRange},dice::NumericDice,name::String="Dice")
    A = Array{Int64,2}(undef,0,3) 
 
    for i in iter
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
 
      # Todas las combinaciones de resultado. Ej: 1) 6 ochos 2) 3 seises, 2 unos y 1 tres...
     c = with_replacement_combinations(dice.results,i)
     allcomb = dice.sides^i # Todas las posibles combinaciones de caras que pueden salir
 
     r = Dict{Int, Number}()
 
        for (j,numbercombs) in enumerate(c)
            l=1
            for k in 2:i
                (numbercombs[k] != numbercombs[k-1]) && (l=l+1)
            end
            # Revisar esta línea. Tarda mucho
            reord = factorial(i,i-l+1) # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados on 4 y 3 dados 2 
            prob = reord/allcomb*100
            
            s= sum(numbercombs) + dice.modifier

            r[s] = get(r,s,0) + prob
            
        end

     rₛ = sort(r)
 # 2. Concatenate results

    A = vcat(A,hcat(fill(i,length(r)),collect(keys(rₛ)),collect(values(rₛ))))

    end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame
 
     n = [Symbol(name),:Result,:Probability]
 
     #TODO:Read name directly from CategoricalDice input. Impossible?
     
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant
 end

"""
This method allows to apply a function to each result

e.g. drop lowet
 roll(3,d6) do r
    sum(r[2:end])
 end

NOT TESTED

"""

function roll(f::Function,iter::Union{Int,OrdinalRange},dice::NumericDice,name::String="Dice")
    A = Array{Int64,2}(undef,0,3) 
 
    for i in iter
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
 
      # Todas las combinaciones de resultado. Ej: 1) 6 ochos 2) 3 seises, 2 unos y 1 tres...
     c = with_replacement_combinations(dice.results,i)
     allcomb = dice.sides^i # Todas las posibles combinaciones de caras que pueden salir
 
     r = Dict{Int, Number}()
 
        for (j,numbercombs) in enumerate(c)
            l=1
            for k in 2:i
                (numbercombs[k] != numbercombs[k-1]) && (l=l+1)
            end
            # Revisar esta línea. Tarda mucho
            reord = factorial(i,i-l+1) # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados on 4 y 3 dados 2 
            prob = reord/allcomb*100
            
            s= f(numbercombs) + dice.modifier

            r[s] = get(r,s,0) + prob
            
        end

     rₛ = sort(r)
 # 2. Concatenate results

    A = vcat(A,hcat(fill(i,length(r)),collect(keys(rₛ)),collect(values(rₛ))))

    end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame
 
     n = [Symbol(name),:Result,:Probability]
 
     #TODO:Read name directly from CategoricalDice input. Impossible?
     
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant
 end