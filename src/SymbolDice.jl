"""
    roll(n,dice;name=dice.name)

Roll n symbol dice and add the results. Returns a Tables.jl compliant struct

# Arguments
    - n::Union{Int,OrdinalRange} -> number of dice o a range of values (E.g. 1:10)
    - dice::SymbolDice -> an already defined die 

# Example 
```julia  
    roll(1:5, dicewithsymbols) 
```
"""
function roll(n::Union{Int,UnitRange{Int}}, dice::SymbolDice; name::String=dice.name)

    minimum(n) <= 0 && return error("Must roll a positive number of dice")

    A_parts = Matrix{Float64}[] # Array to store the results of each roll

    for nᵢ in n
        # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die

        c = multiexponents(length(dice.sidesfreq), nᵢ)  # multiexponents return an iterable

        allcomb = dice.sides^nᵢ # All possible combinations for the given number of sides and dice
        r = Array{Any}(undef, length(c), 2)

        for (j, sidecombs) in enumerate(c)
            s = sidecombs[sidecombs.>0] # Eliminate zeros to speed up splat operator in next line
            reord = multinomial(s...)   # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados blancos y 3 dados éxitos 
            events = reord * (.*(dice.sidesfreq .^ sidecombs...)) # Todas las posibilidades teniendo en cuenta cuando hay caras iguales. Ej: hay 4 caras con resultados blanco en cada dado
            prob = events / allcomb * 100

            r[j, 1] = sidecombs
            r[j, 2] = Float64(prob)
            # r is a matrix with each of the possible combination of dice sides and its probability
        end

        # 2. Transforms dice sides into categorical results. E.g.: 1 side type 1 means 1 success and 1 advantage

        a = zeros(Int, size(r, 1), length(dice.symbols))

        for k in 1:size(a, 1)
            a[k, :] = sum(r[k, 1] .* dice.symbolsinside)
        end

        mat = Matrix{Float64}(undef, size(a, 1), length(dice.symbols) + 2)
        mat[:, 1] .= nᵢ
        mat[:, 2:end-1] .= a
        mat[:, end] .= r[:, 2]
        push!(A_parts, mat)
    end #for

    A = isempty(A_parts) ? Matrix{Float64}(undef, 0, length(dice.symbols) + 2) : reduce(vcat, A_parts)

    # 3. Creates a DicePool struct that is Tables.jl compliant
    cols = Symbol[Symbol(name), dice.symbols..., :Probability]
    return DicePools.DicePool(cols, 1, A,
        Dict([j => i for (i, j) in enumerate(cols)]))
end
"""
    reroll(iter, dice::categorical,reroll::Symbol, name::String="Dice")

reroll the dice with specific results

    reroll(1:3, MY0_Skill, :Blank,"Push_Skill")
"""
#TODO More complex rules for rerolling
function reroll(iter::Union{Int,UnitRange{Int}}, dice::SymbolDice,
    reroll::Union{Symbol,Array{Symbol}}, name::String="Dice")
    (typeof(reroll) == Symbol) && (reroll = Symbol[reroll])

    roll1 = roll(iter, dice, name=name) #First roll
    roll2 = roll(range(0; stop=maximum(iter)), dice, name="Reroll") # Base for 2nd roll

    l₁ = size(data(roll1), 1) # Length of each Table
    l₂ = size(data(roll2), 1)
    L = l₁ * l₂ # Total length of output

    w = size(data(roll1), 2) # Width for both roll and reroll

    tempr = Array{Real}(undef, L, 2w) # Num of data columns is the total

    # Main table with the results of the roll1 combined with itself
    tempr[:, 1:w] = repeat(data(roll1); outer=(l₂, 1), inner=(1, 1))
    tempr[:, (w+1):end] = repeat(data(roll2); outer=(1, 1), inner=(l₁, 1))
    allnames = [headers(roll1)..., headers(roll2)...] # Colnames

    # Eliminate rows where dice of the second roll are not equal to the rerolled dice
    cols = (|).([i .== headers(roll1) for i in reroll]...) # For selecting columns of results to be rerolled. "(|)." means "or" 
    rerolled = vec(sum(data(roll1)[:, cols]; dims=2)) # Number of dice to be rerolled for each row. Note: "Vec" is used because rerolled is a matrix
    tempr = tempr[tempr[:, w+1].==repeat(rerolled, l₂), :] # Keeps rows where dice equals rerolled. 

    # Column Consolidation
    colnames = Symbol[headers(roll1)[1], :Reroll, headers(roll1)[2:(end-1)]...] # Reordered Colnames
    r = Array{Real}(undef, size(tempr, 1), length(colnames) + 1) # One more columns for :Probability

    for (i, j) in enumerate(colnames)
        r[:, i] = sum(tempr[:, j.==allnames]; dims=2) #Sums columns with the same name as j
    end

    # Probability calculation
    r[:, end] = prod(tempr[:, :Probability.==allnames]; dims=2) ./ 100 #Sums columns with the same name as j

    c = Symbol[colnames..., :Probability] # Adds :Probability to column names

    return DicePools.DicePool(c, 2, Matrix{Float64}(r),
        Dict([j => i for (i, j) in enumerate(c)]))
end
