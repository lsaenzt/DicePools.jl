#------------------------------------------------------------------------------------------------------
# Game mechanics with numeric dice
#------------------------------------------------------------------------------------------------------

"""
    drop(n,dice,mod;[droplowest=0],[drophighest=0],[name])

Drop lowest or highest results

# Arguments
 - droplowest::Int' and/or 'drophighest::Int': number of dice to be dropped

# Example
    drop(5,d8; droplowest=2)
"""
function drop(n::Union{Int,OrdinalRange}, dice::NumericDice, mod::Int=0; droplowest=0,
              drophighest=0, name="Dice")
    (droplowest + drophighest) > n &&
        return error("More dice dropped than the number of dice rolled")

    customroll(n, dice, name) do r
        return sum(r[(begin + droplowest):(end - drophighest)]) + mod
    end
end

"""
    takemid(n,dice,[mod=0];[mid=1],[name])

Sum mid dice results. The number of mid dice to sum is set by the 'mid::Int' keyword
"""
function takemid(n::Union{Int,OrdinalRange}, dice::NumericDice, mod::Int=0; mid=1,
                 name="Dice")
    mid > n && return error("Mid cannot be higher than the number of dice")

    l = n - mid
    drop = div(l, 2)

    customroll(n, dice, name) do r
        return sum(r[(begin + drop):(end - drop - isodd(l))]) + mod
    end
end

"""
    beattarget(n,dice;target=maximum(dice.results),equal=true, [name])

Beating a target number with n dice. If equal is set to true, matching the target counts as success
"""
function beattarget(n, dice::NumericDice; target::Int=maximum(dice.results), name=dice.name,
                    equal=true)
    equal ? (f = ≥) : (f = >) # if equal is true use equal or greater, else use greater
    dice = CustomDice([f(i, target) ? 1 : 0 for i in dice.results], name) # Sides that count as 1 success
    return roll(n, dice)
end

"""
    rollunder(n,dice;target=maximum(dice.results),equal=true, [name])

Roll below a target number with n dice. If equal is set to true, matching the target counts as success
"""
function rollunder(n, dice::NumericDice; target::Int=maximum(dice.results), name=dice.name,
                   equal=true)
    equal ? (f = ≤) : (f = <) # if equal is true use equal or less, else use less
    dice = CustomDice([f(i, target) ? 1 : 0 for i in dice.results], name) # Sides that count as 1 success
    return roll(n, dice)
end

function reroll(n::Union{Int,UnitRange{Int}}, dice::CustomDice, mod::Int=0; reroll::Int,
                name::String=dice.name) end

function explode() end

"""
Single random result of die roll
"""
function singleroll(n::Int, d::NumericDice, mod::Int=0)
    s = 0
    for i in 1:n
        s = s + rand(d.results)
    end
    return s + mod
end

"""
Sample of 'rep' rolls of an 'n' dice of type 'd' applying 'f' to each result
"""
function sampleroll(f::Function, n::Int, d::NumericDice, rep::Int)
    res = Vector{Int}(undef, rep)
    for i in 1:rep
        r = Vector{Int}(undef, d.sides)
        for j in 1:n
            r[j] = rand(d.results)
        end
        res[i] = f(r)
    end
    ur = sort(unique(res))
    freq = [sum([c == x for c in res]) for x in ur]
    freq = freq ./ length(res) .* 100

    return [ur freq]
end
