r1 = resultsprobabilities(2:6,MY0_Attr,"Attr");
r2 = resultsprobabilities(0:5,MY0_Skill,"Skill");
r3 = resultsprobabilities(0:2,MY0_Eq,"Equip");

function test(r1,r2,r3)
   
    rs = (r1,r2,r3)
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
