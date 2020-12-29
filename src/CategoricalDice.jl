export categoricaldice, resultsprobabilities

struct categoricaldice
    sides::Int #e.g. 12
    sidesfreq::Vector #[1,2,2,1,3,2,1]
    resulttypes::Vector #[:blank, :success, :advantage, :triumph]
    resultsinside::Vector #[[1,0,0,0], [0,1,0,0],[0,2,0,0],[0,0,1,0],[0,1,1,0],[0,0,2,0],[0,0,0,1]]
end

function categoricaldice(sides::Array,freq::Array=[]) #User friendly Constructor for categorial dice
    
    #TODO: identificar caras repetidas y unirlas
    (freq==[]) && (freq = ones(length(r))) #If f is empty then each results happens once in the dice
    (sum(freq) < length(sides)) && error("Más resultados en el dado que caras") #El vector rep contiene cuantas veces se repita cada resultado y debe ser igual a las caras
     
    r = [] # Unique results categories

    for i in sides # Extracts the results categories
        for j in i
            push!(r,j)
        end
    end
    unique!(r) # Unique category of results as Symbol
    
    m = [] # count the results of each side

    for i in sides # Counts the results present in each side as 1 and 0
        temp = fill(0,length(r))
            for j in i
                temp += (j .== r) 
            end
        push!(m,temp)
    end

    r = Symbol.(r)
    categoricaldice(sum(freq),freq,r,m) 
end

macro dice(d) #TODO: investigar macros para utilizar en argumento de "resultsprobabilities" sin tener que escribir variable y su nombre
    quote
        $(esc(d)), $(string(d))
    end
end
 

"""
    resultsprobabilities(iter,dice)

#Arguments
    - iter::Union{Int,OrdinalRange} -> number of dice o a range of values (E.g. 1:10)
    - dice::categoricaldice -> an already defined dice 
    - name::String="Dice" -> name of the dice to be used as output 

# Returns a Namedtuple with column names and values: 
    1.- Name of the die => number of dice
    2.- One column for each types of results => total number of results
    3.- Probability => probability of the combination of results

La función replica la filosofía del excel DicePools.xlsx

    1.- Listado de las posibles combinaciones de resultados según dados. Ej: 3 resultos de 1 éxito, 1 de dos éxitos y otro blanco con 5 dados
    2.- Calcular cuantas ordenaciones existen que den esos resultados. Ej: Primera: dado 1º,2º y 3º, 1 éxito, el 4º dos éxitos y el 5º blanco, 
                                                                       Segunda: el 1º,2º y 4º, 1 éxito, el 3º dos éxitos y el 5º blanco, etc, etc.
    3.- Calcular para una de esas ordenaciones cuantos casos existen teniendo en cuenta que hay resultados que aparecen varias veces (p.ej. si el blanco sale en 3 caras)
    4.- El total de casos posibles son los casos para cada combinación de resultados * las posibles ordenaciones según dados
    5.- La probabilidad es la cifra anterior entre el total de combinaciones de n dados de s caras (s^n)
"""

function resultsprobabilities(iter::Union{Int,OrdinalRange},dice::categoricaldice;name::String="Dice")

   A = Array{Int64,2}(undef,0,length(dice.resulttypes)+2) 

   for i in iter
   # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die

    c = collect(multiexponents(length(dice.sidesfreq),i)) # Todas las combinaciones de resultado. Ej: los n dados éxito, n-2 éxito, otro blanco y otro fatiga...

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

    n = (Symbol(name), dice.resulttypes...,:Probability) # Tuple for direct DataFrame creation

    #TODO:Read name directly from categoricaldice input. Impossible?
    
    DiceProbabilities(n,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant

end
 
"""
    combineresults(r1,r2,rs...)

Combines the results of a tuple of results of dice 

    combineresults(r,t,s)

"""
function combineresults(r1::DiceProbabilities,r2::DiceProbabilities,r3::DiceProbabilities) #TODO: Generalizar a "n" tablas de probabilidades
 
    rs = (r1,r2,r3)
    l = size.(data.(rs),1) # Length of each Table
    L = prod(l) # Total length of output

    # Combinations based on DataFrames implementation -> https://github.com/JuliaData/DataFrames.jl/blob/a6910c5212d504d15c23ba13145d3f9ad3995afd/src/abstractdataframe/join.jl#L1232-L1287

    # 1.- Dice
    
    diename = []
    n = Array{Int}(undef,L,length(rs))

    for (i,j) in enumerate(rs)
        push!(diename, names(j)[1])
        num[:,i]= repeat(j[1],outer=div(L,prod(l[i:end])),inner=div(L,prod(l[1:i])))
    end

    # 2.- Results and consolidation

    resultname = []
    r = Array{Int}(undef,L,sum(length.(rs))-length(rs)*2) #Num of data columns is the total minus name column and probability column

    pos = 1
    for (i,j) in enumerate(rs) #combinations of results data. Ignoring dice names columns and probability column
        rcol = DicePools.names(j)[2:end-1]
        ncol = length(rcol)
        push!(resultname, rcol)
        r[:,pos:pos+ncol-1]= repeat(DicePools.data(j)[:,2:end-1],outer=(div(L,prod(l[i:end])),1),inner=(div(L,prod(l[1:i])),1))
        pos+=ncol
    end

    # Vas por aquí: sumar columnas de resultados con mismo nombre...
    commonresults = intersect(names(r1)[2:end-1],names(r1)[2:end-1]) # Common result types (ignoring dice name). Using Tables.jl accessors

    # 3.- Probabilities

    p=nothing
    
    n = (;)  #Column names

    DiceProbabilities(n, hcat(n,r,p),Dict([j => i for (i,j) in enumerate(n)])) 
    #= OJO: Un objeto DiceProbabilities permite Tables.jl pero no es correcto porque no funcionaría combineresults por los nombres
       Solución: incorporar a DiceProbabilities struct un campo con el nº de columnas de nombre que hay
    =#
    
end

"""
    rerollprobabilities(iter, dice::categorical,reroll::Symbol, name::String="Dice")

reroll the dice with specific results

    rerollprobabilities(1:3, MY0, :Blank; name="MY0")

"""
function rerollprobabilities(iter::Union{Int,OrdinalRange},dice::categoricaldice,reroll::Symbol; name::String="Dice")


end