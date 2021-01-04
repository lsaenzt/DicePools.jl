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

function reroll(iter::Union{Int,OrdinalRange},dice::CategoricalDice,reroll::Array{Symbol}, name::String="Dice")

    roll = resultsprobabilities(iter,dice,name)
    roll2 = resultsprobabilities(range(0,stop= maximum(iter)),dice,"Reroll")
    
    l₁ = size(data(roll),1) # Length of each Table
    l₂ = size(data(roll2),1)
    L = l₁*l₂ # Total length of output
    w = size(data(roll),2) # Width for both roll and reroll

    tempr = Array{Real}(undef,L,2w) #Num of data columns is the total
        
    # Main table with the results of the roll combined with itself
    tempr[:,1:w] = repeat(data(roll),outer=(l₂,1),inner=(1,1))
    tempr[:,w+1:end] = repeat(data(roll2),outer=(1,1),inner=(l₁,1))
    allnames=[headers(roll)...,headers(roll2)...] # Colnames

    # Eliminates rows where dice of the second roll are not equal to the rerolled dice
    cols = (|).([i.==headers(roll) for i in reroll]...) # For selecting columns of results to be rerolled. "(|)." means "or" 
    rerolled = sum(data(roll)[:,cols],dims=2) # Number of dice to be rerolled for each row
    tempr = tempr[tempr[:,w+1].==repeat(vec(rerolled),l₂),:] # Keeps rows where dice equals rerolled. Note: "Vec" is used because rerolled is a matrix

    # Column Consolidation
    colnames=[headers(roll)[1],:Reroll,headers(roll)[2:end-1]...] # Reordered Colnames
    r = Array{Real}(undef,size(tempr,1),length(colnames)+1) # One more columns for :Probability

    for (i,j) in enumerate(colnames) 
        r[:,i] = sum(tempr[:,j.==allnames],dims=2) #Sums columns with the same name as j
    end  

    # Probability calculation
        r[:,end] = prod(tempr[:,:Probability.==allnames],dims=2)./100 #Sums columns with the same name as j
 
    c = [colnames...,:Probability]
    
    DicePools.DiceProbabilities(c,2,r,Dict([j => i for (i,j) in enumerate(c)]))
end