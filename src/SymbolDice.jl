
macro dice(d) #TODO: investigar macros para utilizar en argumento de "resultsprobabilities" sin tener que escribir variable y su nombre
    quote
        $(esc(d)), $(string(d))
    end
end
 
"""
    roll(iter,dice)

#Arguments
    - iter::Union{Int,OrdinalRange} -> number of dice o a range of values (E.g. 1:10)
    - dice::CategoricalDice -> an already defined dice 
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

function roll(N::Union{Int,OrdinalRange},dice::SymbolDice,name::String="Dice")

   A = Array{Int64,2}(undef,0,length(dice.resulttypes)+2) 

   for n in N
   # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die

    c = multiexponents(length(dice.sidesfreq),n)  # multiexponents return an iterable
    
    allcomb = dice.sides^n # Todas las posibles combinaciones de caras que pueden salir

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

    A = vcat(A,hcat(fill(n,size(a,1)),a,r[:,2])) #Accumulates all results into one matrix. Number od dice, results and probability

    end
# 3. Creates a Namedtuple with the results. Can be directly usesd with |> DataFrame

    n = [Symbol(name), dice.resulttypes...,:Probability]

    #TODO:Read name directly from CategoricalDice input. Impossible?
    
    DicePools.DiceProbabilities(n,1,A,Dict([j => i for (i,j) in enumerate(n)])) # Struct Table.jl compliant

end
 
"""
    combineresults(r1,r2,rs...)

Combines the results into one table 

    combineresults(r,t,s)
"""
function combineresults(r1::DiceProbabilities,r2::DiceProbabilities,ri::DiceProbabilities...)
    
    rs = (r1,r2,ri...)
    l = size.(data.(rs),1) # Length of each Table
    L = prod(l) # Total length of output

    tempr = Array{Real}(undef,L,sum(length.(rs))) #Num of data columns is the total
    
    # Main table with individual results tables replicated for generating all combinations
    tempnames = []
    pos = 1
    for (i,rᵢ) in enumerate(rs)
        rcol = headers(rᵢ)
        ncol = length(rcol)
        push!(tempnames, rcol...)
        tempr[:,pos:pos+ncol-1] = repeat(data(rᵢ),outer=(div(L,prod(l[i:end])),1),inner=(div(L,prod(l[1:i])),1))
        pos+=ncol
    end
  
    # Headers for output table 
    colname = []
    for rᵢ in rs # Dice names first
        push!(colname, headers(rᵢ)[1:dicenamecols(rᵢ)]...) #Dice name columns
    end
    
    n = length(colname) #number of dice names columns

    for rᵢ in rs # Results later
        push!(colname, headers(rᵢ)[dicenamecols(rᵢ)+1:end-1]...) # Rest of columns except Probability
    end
    colname = union(colname)

    # Column Consolidation
    r = Array{Real}(undef,L,length(colname)+1) # One more columns for :Probability

    for (i,j) in enumerate(colname)

        r[:,i] = sum(tempr[:,j.==tempnames],dims=2) #Sums columns with the same name as j

    end    
    # Probability calculation
        r[:,end] = prod(tempr[:,:Probability.==tempnames],dims=2)./10000 #Sums columns with the same name as j
 
    c = [colname...,:Probability]
    
    DicePools.DiceProbabilities(c,n,r,Dict([j => i for (i,j) in enumerate(c)]))

end

"""
    reroll(iter, dice::categorical,reroll::Symbol, name::String="Dice")

reroll the dice with specific results

    reroll(1:3, MY0_Skill, :Blank,"Push_Skill")
"""
#TODO Complejo: incluir una regla para reroll e.j. :Blank if :Harm == 0 ¬:Bread ==0
function reroll(iter::Union{Int,OrdinalRange},dice::SymbolDice,reroll::Union{Symbol,Array{Symbol}}, name::String="Dice")

    (typeof(reroll) == Symbol) && (reroll = [reroll])

    roll = resultsprobabilities(iter,dice,name) #First roll
    roll2 = resultsprobabilities(range(0,stop= maximum(iter)),dice,"Reroll") # Base for 2nd roll
    
    l₁ = size(data(roll),1) # Length of each Table
    l₂ = size(data(roll2),1)
    L = l₁*l₂ # Total length of output

    w = size(data(roll),2) # Width for both roll and reroll

    tempr = Array{Real}(undef,L,2w) #Num of data columns is the total
        
    # Main table with the results of the roll combined with itself
    tempr[:,1:w] = repeat(data(roll),outer=(l₂,1),inner=(1,1))
    tempr[:,w+1:end] = repeat(data(roll2),outer=(1,1),inner=(l₁,1))
    allnames=[headers(roll)...,headers(roll2)...] # Colnames

    # Eliminate rows where dice of the second roll are not equal to the rerolled dice
    cols = (|).([i.==headers(roll) for i in reroll]...) # For selecting columns of results to be rerolled. "(|)." means "or" 
    rerolled = sum(data(roll)[:,cols],dims=2) |> vec # Number of dice to be rerolled for each row. Note: "Vec" is used because rerolled is a matrix
    tempr = tempr[tempr[:,w+1].==repeat(rerolled,l₂),:] # Keeps rows where dice equals rerolled. 

    # Column Consolidation
    colnames=[headers(roll)[1],:Reroll,headers(roll)[2:end-1]...] # Reordered Colnames
    r = Array{Real}(undef,size(tempr,1),length(colnames)+1) # One more columns for :Probability

    for (i,j) in enumerate(colnames) 
        r[:,i] = sum(tempr[:,j.==allnames],dims=2) #Sums columns with the same name as j
    end  

    # Probability calculation
        r[:,end] = prod(tempr[:,:Probability.==allnames],dims=2)./100 #Sums columns with the same name as j
 
    c = [colnames...,:Probability] # Adds :Probability to column names
    
    DicePools.DiceProbabilities(c,2,r,Dict([j => i for (i,j) in enumerate(c)]))
end