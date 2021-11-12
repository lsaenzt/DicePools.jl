"""
 A single set of DnD abilities
"""
function dndabilities()
    a = Vector{Int}(undef, 6)
    for i in 1:6
        a[i] = sum((sort!(collect(rand(1:6) for i in 1:4)))[2:4])
    end
    return sort(a; rev=true)
end
