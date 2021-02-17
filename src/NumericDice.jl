# Crear macro para @roll 3d6 
export NumericDice, roll, combineresults, reroll


struct NumericDice
    sides::Int #e.g. 8
    sidesvalues::Vector{Int} #[1,2,3,4,5,6,7,8]
end

# Function to define 'normal' dice
function numericdice(sides::Int)
    NumericDice(sides,1:sides)
end

#=

TODO: PENSAR SI SE PUEDE PRODUCTO VECTORIAL DE LAS COMBINACIONES Y LOS "sidesvalues" PARA LA SUMA DEL RESULTADO

function roll(iter::Union{Int,OrdinalRange},dice::NumericalDice,name::String="Dice")

    A = Array{Int64,2}(undef,0,numericdice.sides+2) 
 
    for i in iter
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
 
     c = collect(multiexponents(dice.sides),i)) # Todas las combinaciones de resultado. Ej: 1) 6 ochos 2) 3 seises, 2 unos y 1 tres...
 
     allcomb = dice.sides^i # Todas las posibles combinaciones de caras que pueden salir
 
     r= Array{Any}(undef,length(c), 2)
 
     for (j,sidecombs) in enumerate(c)
 
         reord = multinomial(sidecombs...) # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados blancos y 3 dados éxitos 
         events = reord*(.*(dice.sidesfreq.^sidecombs...)) # Todas las posibilidades teniendo en cuenta cuando hay caras iguales. Ej: hay 4 caras con resultados blanco en cada dado
         prob = events/allcomb*100
       
         r[j,1] = sidecombs
         r[j,2] = prob
         # r is a matrix with each of the possible combination of dice sides and its probability
     end
 
 # 2. Transforms dice sides into categorical results. E.g.: 1 side type 1 means 1 success and 1 advantage
 
     a = zeros(Int, size(r,1),length(dice.resulttypes))
 
     #n = Array{String}(undef,lengthdice.resulttypes)+1) # Nombres de cada columna de la matriz resultante. Tiene que ser un vector de columnas para DataFrames
 
     for k in 1:size(a,1)
             a[k,:]=sum(r[k].*dice.resultsinside)
     end
 
     A = vcat(A,hcat(fill(i,size(a,1)),a,r[:,2])) #Accumulates all results into one matrix. Number od dice, results and probability
 
     end
 # 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame
 
     n = [Symbol(name), dice.resulttypes...,:Probability]
 
     #TODO:Read name directly from CategoricalDice input. Impossible?
     
     DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant
 
 end

 =#