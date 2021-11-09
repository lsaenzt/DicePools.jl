# Macro for standard dice roll e.g. 3d10+3. -> Overloading Base arithmetic operators is much simper
macro roll(w)
    # split("3d4+2d6-1",r"[+-]")
    quote 
        dd = $(string(w))

        n = dd[begin:findfirst("d",dd)[1]-1]

        if occursin(r"[+-]",dd)
            d = dd[findfirst("d",dd)[1]+1:findfirst(r"[+-]",dd)[1]-1]
            mod = dd[findfirst(r"[+-]",dd)[1]:end]
        else
            d = dd[findfirst("d",dd)[1]+1:end]
            mod = "0"
        end

        roll(parse(Int,n),StandardDice(parse(Int,d)),parse(Int,mod))
    end
end

macro dicename(d) #TODO: investigar macros para utilizar en argumento de "resultsprobabilities" sin tener que escribir variable y su nombre
    quote
        $(string(d))
    end
end