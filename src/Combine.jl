"""
    combineresults(r1,r2,rs...)

Combines the results of several dice rolls into one table 

TODO: Group results

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
 
    cols = [colname...,:Probability]
    
    DicePools.DiceProbabilities(cols,n,r,Dict([j => i for (i,j) in enumerate(cols)]))
end

"consolidates repeated results in a combination"

function consolidate(dp::DiceProbabilities)

    unique(data(dp)[:,1:end-1];dims=1) # Resultados únicos

end