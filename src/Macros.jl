macro dicename(d) #TODO: investigar macros para utilizar en argumento de "resultsprobabilities" sin tener que escribir variable y su nombre
    quote
        $(string(d))
    end
end

#TODO macro for parsing 3d10+3, for example.
macro roll(d)
    quote
        $(esc(d)), $(string(d))
    end
end
 