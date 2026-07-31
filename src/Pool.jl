"""
    pool(r1,r2,rs...)

Combines by adding the results of several dice rolls into one table. 
Arguments are two or more DicePool structs.
"""
function pool(r1::DicePool, r2::DicePool, ri::DicePool...)
    rs = (r1, r2, ri...)
    l = size.(data.(rs), 1)      # Length of each Table
    L = prod(l)                 # Total length of outputs

    tempr = Matrix{Float64}(undef, L, sum(length.(rs))) # Num of data columns is the total

    # Main table with individual results tables replicated for generating all combinations
    tempnames = Symbol[]
    pos = 1
    for (i, rᵢ) in enumerate(rs)
        rcol = headers(rᵢ)
        ncol = length(rcol)
        push!(tempnames, rcol...)
        tempr[:, pos:(pos+ncol-1)] = repeat(data(rᵢ); outer=(div(L, prod(l[i:end])), 1),
            inner=(div(L, prod(l[1:i])), 1))
        pos += ncol
    end

    # Headers for output table 
    colname = Symbol[]
    for rᵢ in rs    # Dice names first
        push!(colname, headers(rᵢ)[1:dicenamecols(rᵢ)]...)  # Dice name columns
    end

    n = length(colname) # Number of dice names columns

    for rᵢ in rs # Results later
        push!(colname, headers(rᵢ)[(dicenamecols(rᵢ)+1):(end-1)]...) # Rest of columns except Probability
    end
    colname = union(colname) # Unique name columns

    # Column Consolidation
    r = Matrix{Float64}(undef, L, length(colname) + 1) # One more column for :Probability

    for (i, j) in enumerate(colname)
        r[:, i] = sum(tempr[:, j.==tempnames]; dims=2) # Sums columns with the same name as j
    end
    # Probability calculation
    r[:, end] = prod(tempr[:, :Probability.==tempnames]; dims=2) ./ (100^(length(rs) - 1)) # Multiplies probabilities

    cols = [colname..., :Probability]

    return DicePools.DicePool(cols, n, collapse(r),
        Dict([j => i for (i, j) in enumerate(cols)]))
end

"Consolidates repeated results when pooling"
function collapse(d::Matrix{Float64})
    # Since groups are practically integer vectors representing combinations of sums, collect unique ones.
    groups = d[:, 1:(end-1)]
    prob = d[:, end]

    unique_idxs = unique(i -> groups[i, :], 1:stack)

    output = Matrix{Float64}(undef, length(unique_idxs), size(d, 2))

    # We can optimize it by using a Dict mapping the row vector to the accumulated probability.
    acc = Dict{Vector{Float64},Float64}()
    for i in 1:size(d, 1)
        row_vec = @views groups[i, :]
        acc[row_vec] = get(acc, row_vec, 0.0) + prob[i]
    end

    i = 1
    for (idx, row_idx) in enumerate(unique_idxs)
        row_vec = @views groups[row_idx, :]
        output[i, 1:end-1] = row_vec
        output[i, end] = acc[row_vec]
        i += 1
    end

    return output
end

"""
    compare(f,r1,r2)

Compares the results of two dicepools 
# Example
```julia  
    compare(>,highest(4d6),highest(3d6))
```
"""
function compare(f::Function, r1::DicePool, r2::DicePool) #TODO

end
