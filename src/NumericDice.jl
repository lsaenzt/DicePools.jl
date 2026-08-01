#------------------------------------------------------------------------------------------------------
# Basic add roll functions
#------------------------------------------------------------------------------------------------------
"""
    roll(n,dice,mod;[name=dice.name])

mod::Int is a modifier to apply to each result

# Example
```julia  
    roll(3,d6,+2)
    roll(3,custom,"fudge")
```
"""
function roll(n::Union{Int,UnitRange{Int}}, dice::StandardDice, mod::Int=0;
    name::String=dice.name)
    s = dice.sides

    _n_iter = collect(n)
    total_rows = sum(nᵢ == 0 ? 0 : nᵢ > 0 ? nᵢ * s - nᵢ + 1 : abs(nᵢ) * s - abs(nᵢ) + 1 for nᵢ in _n_iter)

    A = Matrix{Float64}(undef, total_rows, 3)
    curr_row = 1

    for nᵢ in n
        if nᵢ == 0
            continue
        elseif nᵢ < 0 # Negative dice
            neg = true
            nᵢ = abs(nᵢ)
        else
            neg = false
        end

        dist = Float64[1.0]
        prob_step = 1.0 / s
        for _ in 1:nᵢ
            next_dist = zeros(Float64, length(dist) + s - 1)
            for j in eachindex(dist)
                for k in 1:s
                    next_dist[j+k-1] += dist[j] * prob_step
                end
            end
            dist = next_dist
        end

        for (idx, prob) in enumerate(dist)
            res_val = nᵢ + idx - 1
            A[curr_row, 1] = neg ? -nᵢ : nᵢ
            A[curr_row, 2] = neg ? (res_val + mod) - (s * nᵢ + nᵢ) : res_val + mod
            A[curr_row, 3] = prob * 100.0
            curr_row += 1
        end
    end

    # Creates a DicePool struct that is Tables.jl compliant
    name = (mod == 0) ? name : string(n, dice.name, "+", mod)
    cols = Symbol[Symbol(name), :Result, :Probability]
    return DicePools.DicePool(cols, 1, A,
        Dict([j => i for (i, j) in enumerate(cols)])) # Struct Tables.jl compliant
end

function roll(n::Union{Int,UnitRange{Int}}, dice::CustomDice, mod::Int=0;
    name::String=dice.name)
    A_parts = Matrix{Float64}[]

    for nᵢ in n
        if nᵢ == 0
            continue
        elseif nᵢ < 0 # Negative dice
            neg = true
            nᵢ = abs(nᵢ)
        else
            neg = false
        end

        r, p = recursiveroll_sum(nᵢ, dice)
        (mod != 0) && (r = r .+ mod)

        mat = Matrix{Float64}(undef, length(r), 3)
        mat[:, 1] .= neg ? -nᵢ : nᵢ
        mat[:, 2] .= r
        mat[:, 3] .= p

        if neg
            mat = sortslices(mat; dims=1, by=x -> x[end-1])
        end
        push!(A_parts, mat)
    end

    A = isempty(A_parts) ? Matrix{Float64}(undef, 0, 3) : reduce(vcat, A_parts)

    name = (mod == 0) ? name : string(n, name, "+", mod)
    cols = Symbol[Symbol(name), :Result, :Probability]
    return DicePools.DicePool(cols, 1, A,
        Dict([j => i for (i, j) in enumerate(cols)]))
end

function recursiveroll_sum(n, dice::NumericDice)
    dr = dice.results
    dp = fill(100 / dice.sides, dice.sides)

    if n == 1
        ur = unique(dr)
        p = [sum([(c == x) * f for (c, f) in zip(dr, dp)]) for x in ur]

    else
        dr₋₁, dp₋₁ = recursiveroll_sum(n - 1, dice)

        results = [i + j for i in dr₋₁, j in dr]
        freq = [i * j / 100 for i in dp₋₁, j in dp]

        ur = unique(results)
        p = [sum([(c == x) * f for (c, f) in zip(results, freq)]) for x in ur]
    end
    return ur, p
end

"""
    customroll(n,dice,[name=dice.name]) do r
        f(r)
    end

Applies a function to each possible result. 
Calculates every single combination of results. It can take time if the number of possibilities is high.

# Example. Drop lowest
```julia  
    customroll(3,d6) do r
        sum(r[2:end])
    end
```
"""
function customroll(f::Function, n::Union{Int,UnitRange{Int}}, dice::NumericDice;
    name::String="Dice")
    minimum(n) <= 0 && return error("Must roll a positive number of dice")

    idx = 1:(dice.sides) # Combinations on idx deals with repeated values in a Customdice
    A_parts = Matrix{Float64}[]

    for nᵢ in n
        # 1. Calculate the probability each combination of sides. First taking into account combinations of results and secondly considering repeated sides on a die
        allcomb = dice.sides^nᵢ # All possible combinations for the given number of sides and dice
        c = with_replacement_combinations(idx, nᵢ)
        r = OrderedDict{Int,Float64}()

        for cᵢ in c
            rep = count_repeated(cᵢ)    # This allows faster splat in the next line       
            reord = multinomial(rep...) # All possible dice combinatios that lead to the same result. E.g. 20 ways of getting 3 dice with one result and 3 dice with other
            prob = reord / allcomb * 100
            @inbounds s = f(@view dice.results[cᵢ]) # Function applied to the individual results
            r[s] = get(r, s, 0.0) + prob
        end

        sort!(r)

        mat = Matrix{Float64}(undef, length(r), 3)
        mat[:, 1] .= nᵢ
        mat[:, 2] .= collect(keys(r))
        mat[:, 3] .= collect(values(r))
        push!(A_parts, mat)
    end

    A = isempty(A_parts) ? Matrix{Float64}(undef, 0, 3) : reduce(vcat, A_parts)

    # 3. Creates a DiceProbabilties Struct
    cols = Symbol[Symbol(name), :Result, :Probability]
    return DicePools.DicePool(cols, 1, A,
        Dict([j => i for (i, j) in enumerate(cols)])) # Struct Table.jl compliant
end

"Count repeated values in an ordered array"
function count_repeated(a::AbstractVector)
    counts = Int[]
    isempty(a) && return counts
    c = 1
    @inbounds for j in eachindex(a)
        j == 1 && continue
        if a[j] == a[j-1]
            c += 1
        else
            push!(counts, c)
            c = 1
        end
    end
    push!(counts, c)
    return counts
end

#---------------------------------------------------------------------------------------------------
# Roll highest function
#---------------------------------------------------------------------------------------------------

"""
highest(n,dice;[name=dice.name])

# Example
```julia  
    highest(3,d8)
```
"""
function highest(n::Union{Int,UnitRange{Int}}, dice::StandardDice, mod::Int=0;
    name::String=dice.name)

    # reference: https://rpg.stackexchange.com/questions/107775/2-dice-pools-roll-matching-highest
    A_parts = Matrix{Float64}[]

    for nᵢ in n
        if nᵢ == 0
            continue
        elseif nᵢ < 0 # Negative dice
            neg = true
            nᵢ = abs(nᵢ)
        else
            neg = false
        end

        mat = Matrix{Float64}(undef, length(dice.results), 3)
        idx = 1
        for rᵢ in dice.results
            p = ((rᵢ / dice.sides)^nᵢ - ((rᵢ - 1) / dice.sides)^nᵢ) * 100 # Probabilidad de resultado más alto rᵢ con nᵢ dados
            mat[idx, 1] = neg ? -nᵢ : nᵢ
            mat[idx, 2] = neg ? -rᵢ : rᵢ
            mat[idx, 3] = p
            idx += 1
        end

        if neg
            mat = sortslices(mat; dims=1, by=x -> x[end-1])
        end
        push!(A_parts, mat)
    end

    A = isempty(A_parts) ? Matrix{Float64}(undef, 0, 3) : reduce(vcat, A_parts)

    # 3. Creates a DiceProbabilties Struct
    cols = Symbol[Symbol(name), :Result, :Probability]
    return DicePools.DicePool(cols, 1, A,
        Dict([j => i for (i, j) in enumerate(cols)])) # Struct Table.jl compliant

end


#---------------------------------------------------------------------------------------------------
# Roll lowest function
#---------------------------------------------------------------------------------------------------

"""
lowest(n,dice;[name=dice.name])

# Example
```julia  
    lowest(3,d8)
```
"""
function lowest(n::Union{Int,UnitRange{Int}}, dice::StandardDice, mod::Int=0;
    name::String=dice.name)

    # reference: https://rpg.stackexchange.com/questions/107775/2-dice-pools-roll-matching-highest
    A_parts = Matrix{Float64}[]

    for nᵢ in n
        if nᵢ == 0
            continue
        elseif nᵢ < 0 # Negative dice
            neg = true
            nᵢ = abs(nᵢ)
        else
            neg = false
        end

        mat = Matrix{Float64}(undef, length(dice.results), 3)
        idx = 1
        for rᵢ in dice.results
            p = (((dice.sides - rᵢ + 1) / dice.sides)^nᵢ - ((dice.sides - rᵢ) / dice.sides)^nᵢ) * 100 # Probabilidad de resultado más bajo rᵢ con nᵢ dados
            mat[idx, 1] = neg ? -nᵢ : nᵢ
            mat[idx, 2] = neg ? -rᵢ : rᵢ
            mat[idx, 3] = p
            idx += 1
        end

        if neg
            mat = sortslices(mat; dims=1, by=x -> x[end-1])
        end
        push!(A_parts, mat)
    end

    A = isempty(A_parts) ? Matrix{Float64}(undef, 0, 3) : reduce(vcat, A_parts)

    # 3. Creates a DiceProbabilties Struct
    cols = Symbol[Symbol(name), :Result, :Probability]
    return DicePools.DicePool(cols, 1, A,
        Dict([j => i for (i, j) in enumerate(cols)])) # Struct Table.jl compliant

end


#---------------------------------------------------------------------------------------------------
# Overloading of Julia.Base arithmetic functions
#---------------------------------------------------------------------------------------------------
import Base.*, Base.+, Base.-

*(n::Union{Int,UnitRange{Int}}, d::Dice) = roll(n, d)

+(a::DicePool, b::DicePool, c::DicePool...) = pool(a, b, c...)

function +(a::DicePool, b::Int)
    (length(headers(a)) - dicenamecols(a)) > 2 &&
        return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier
    data(a)[:, end-1] = data(a)[:, end-1] .+ b
    return a
end

function -(a::DicePool, b::Int)
    (length(headers(a)) - dicenamecols(a)) > 2 &&
        return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier
    data(a)[:, end-1] = data(a)[:, end-1] .- b
    return a
end

function -(a::DicePool, b::DicePool)
    (length(headers(a)) - dicenamecols(a)) > 2 &&
        return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier
    (length(headers(b)) - dicenamecols(b)) > 2 &&
        return error("Non-numeric die with more than 1 results column") # If more than one column with results it is not possible to apply a modifier

    # Modifications for the 'negative' die
    headers(b)[1] = Symbol("-", headers(b)[1]) # Die name with a minus
    data(b)[:, end-1] = data(b)[:, end-1] .* -1 # Results negative for substracting
    # Sorting probabilities to get the results also sorted when 'pooled'
    sorted_b = DicePool(headers(b), dicenamecols(b),
        sortslices(data(b); dims=1, by=x -> x[end-1]),
        Dict([j => i for (i, j) in enumerate(headers(b))]))

    return pool(a, sorted_b)
end
