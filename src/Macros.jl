macro dicename(d) #TODO: investigar macros para utilizar en argumento de "resultsprobabilities" sin tener que escribir variable y su nombre
    quote
        $(string(d))
    end
end

macro roll(d)
    quote
        $(esc(d)), $(string(d))
    end
end
 