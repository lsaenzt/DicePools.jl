r1 = resultsprobabilities(2:6,MY0_Attr,name="Attr");
r2 = resultsprobabilities(0:5,MY0_Skill,name="Skill");
r3 = resultsprobabilities(0:2,MY0_Eq,name="Equip");

function test(r1,r2,r3)
   
    rs = (r1,r2,r3)
    l = size.(DicePools.data.(rs),1) # Length of each Table
    L = prod(l) # Total length of output

    resultname = []
    r = Array{Int}(undef,L,sum(length.(rs))-length(rs)*2) #Num of data columns is the total minus name column and probability column

    pos = 1
    for (i,j) in enumerate(rs)
        rcol = DicePools.names(j)[2:end-1]
        ncol = length(rcol)
        push!(resultname, rcol)
        r[:,pos:pos+ncol-1]= repeat(DicePools.data(j)[:,2:end-1],outer=(div(L,prod(l[i:end])),1),inner=(div(L,prod(l[1:i])),1))
        pos+=ncol
    end

    resultname,r
    
end
