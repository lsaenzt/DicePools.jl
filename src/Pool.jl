"""
    pool(r1,r2,rs...)

Combines the results of several dice rolls into one table

    pool(r,t,s)
"""
function pool(r1::DiceProbabilities,r2::DiceProbabilities,ri::DiceProbabilities...)
    
    rs = (r1,r2,ri...)
    l = size.(data.(rs),1)      # Length of each Table
    L = prod(l)                 # Total length of outputrs

    tempr = Array{Real}(undef,L,sum(length.(rs))) # Num of data columns is the total
    
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
    for rᵢ in rs    # Dice names first
        push!(colname, headers(rᵢ)[1:dicenamecols(rᵢ)]...)  # Dice name columns
    end
    
    n = length(colname) # Number of dice names columns

    for rᵢ in rs # Results later
        push!(colname, headers(rᵢ)[dicenamecols(rᵢ)+1:end-1]...) # Rest of columns except Probability
    end
    colname = union(colname) # Unque name columns

    # Column Consolidation
    r = Array{Real}(undef,L,length(colname)+1) # One more columns for :Probability

    for (i,j) in enumerate(colname)
        r[:,i] = sum(tempr[:,j.==tempnames],dims=2) # Sums columns with the same name as j
    end
    # Probability calculation
        r[:,end] = prod(tempr[:,:Probability.==tempnames],dims=2)./(100^(length(rs)-1)) # Multiplies probabilities
 
    cols = [colname...,:Probability]
 
    DicePools.DiceProbabilities(cols, n, collapse(r), Dict([j => i for (i,j) in enumerate(cols)]))
end

"Consolidates repeated results when pooling"
function collapse(d::Array{Real})
    
        s = Set()
        output =Array{Real}(d[1:0, :])       # Empty matrix with no rows and same columns as dp. Trick from Timeseries.jl
        groups = Array{Int}(d[:,1:end-1])    # Matrix with columns to group
        prob = Vector{Float64}(d[:,end])     # Probabilities
        temp = Vector{Real}(undef,size(d,2)) # Vector of type Real to store Int for results and Float for Probabilities

        for i in eachrow(groups)
            in(i,s) && continue     # If the row has been already computed skip to next iteration
                      
            p = sum([(k==i) for k in eachrow(groups)].* prob)
            temp[1:end-1] = i # temp filled in two steps to avoid promotion to Float
            temp[end] = p      # idem.
            output = [output; temp |> permutedims]
            push!(s,i)       # Save row as computed
        end

    return output
end