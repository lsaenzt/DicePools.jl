macro dice(d) #TODO: investigar macros para utilizar en argumento de "resultsprobabilities" sin tener que escribir variable y su nombre
    quote
        $(esc(d)), $(string(d))
    end
end
 