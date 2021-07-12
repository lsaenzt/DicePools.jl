"""
    roll(n,dice;name=dice.name)

Roll n symbol dice and add the results. Returns a Tables.jl compliant struct

# Arguments
    - n::Union{Int,OrdinalRange} -> number of dice o a range of values (E.g. 1:10)
    - dice::SymbolDice -> an already defined die 

# Example 
    roll(1:5, dicewithsymbols) 
"""
function roll(n::Union{Int,OrdinalRange},dice::SymbolDice;name::String=dice.name) 

   A = Array{Int64,2}(undef,0,length(dice.symbols)+2)

   for nᵢ in n
   # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die

    c = multiexponents(length(dice.sidesfreq),nᵢ)  # multiexponents return an iterable
    
    allcomb = dice.sides^nᵢ # All possible combinations for the given number of sides and dice

    r= Array{Any}(undef,length(c), 2)

        for (j,sidecombs) in enumerate(c)

            s = sidecombs[sidecombs.>0] # Eliminate zeros to speed up splat operator in next line
            reord = multinomial(s...)   # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados blancos y 3 dados éxitos 
            events = reord*(.*(dice.sidesfreq.^sidecombs...)) # Todas las posibilidades teniendo en cuenta cuando hay caras iguales. Ej: hay 4 caras con resultados blanco en cada dado
            prob = events/allcomb*100
        
            r[j,1] = sidecombs
            r[j,2] = prob
            # r is a matrix with each of the possible combination of dice sides and its probability
        end

# 2. Transforms dice sides into categorical results. E.g.: 1 side type 1 means 1 success and 1 advantage

    a = zeros(Int, size(r,1),length(dice.symbols))

    #n = Array{String}(undef,lengthdice.symbols)+1) # Nombres de cada columna de la matriz resultante. Tiene que ser un vector de columnas para DataFrames

        for k in 1:size(a,1)
                a[k,:]=sum(r[k].*dice.symbolsinside)
        end

    A = vcat(A,hcat(fill(nᵢ,size(a,1)),a,r[:,2])) #Accumulates all results into one matrix. Number od dice, results and probability
    
    end #for

# 3. Creates a DiceProbabilities struct that is Tables.jl compliant
    cols = [Symbol(name), dice.symbols...,:Probability]
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Table.jl compliant

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
 
    cols = [colnames...,:Probability] # Adds :Probability to column names
    
    DicePools.DiceProbabilities(c,2,r,Dict([j => i for (i,j) in enumerate(cols)]))
end