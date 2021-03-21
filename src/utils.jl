"""
 Single Random result of die roll
"""
function roll(d::NumericDice)
    rand(d.results)
end

"""
 Sample of 'rep' rolls of an 'n' dice of type 'd'
"""
# ESTO ES MUY TONTO: Hay que hacer una simulación de r lanzamientos de n dados de tipo x
function sampleroll(n::Int,d::NumericDice, rep::Int)
    results = Vector{Int}(undef,rep)
    for i in 1:rep
        s = 0
        for i in 1:n
            s = s+ rand(d.results)
        end
        results[i] = s
    end
    ur = sort(unique(results))
    freq = [sum([c == x for c in results]) for x in ur] 
    freq = freq./length(results).*100

    return [ur freq]
end

"""
 A single set of DnD abilities
"""

function dndabilities()
    a = Vector{Int}(undef,6)
    for i in 1:6
     a[i] = (collect(rand(1:6) for i in 1:4) |> sort!)[2:4] |>sum
    end
    return sort(a,rev = true)
end

