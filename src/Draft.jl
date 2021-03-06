# IDEA 1: repetir todas las combinaciones de resultados. Sencillo pero acaba siendo lento, con 5d100 se queda sin memoria y no tengo resultados individuales...
function roll(n,s)

    l = length(s)
    results = repeat(s,inner=l).+ repeat(s,outer=l)

        for i in 3:n
            results = repeat(results,inner=l).+ repeat(s,outer=length(results))
        end
    # Usar Dict mejor?
    ur = unique(results)
    freq = Int[sum([c == x for c in results]) for x in ur]

    return zip(ur,freq./(l^n)*100)
    
end

# IDEA 2: Este bucle obtiene las combinaciones con repeticion correctamente para 3d6. No sé cómo hacer anidados de profundidad = nº de dados
count=1
for i in 1:6, j in i:6, k in j:6
     println(i,j,k," ",count)
     count +=1  
end

# IDEA 3: recursive "loop" para resolver el problema de Idea 2. Complejo y no sé si más rápido.
d=Dict{Int,Int}()
a=zeros(Int,12)

function recursivedie(n,s,k=1) #Esta lo hace
    for i in k:s
        a[n] = i
        (n>1) && recursivedie(n-1,s,i)
        if n==1
            # Println(a)
            # Multinomial???
            r = sum(a)
            d[r] = get(d,r,0) + 1
        end
    end
end

function lanza(n,s)
    global d=Dict{Int,Int}()
    global a=zeros(Int,s)
    recursivedie(n,s)
end

# IDEA 4: el producto de todas las combinaciones. Simple pero muy lento.

function roll(n,s)

    c= Iterators.product(repeat([1:s], outer=(1,n))...)
    allcomb = s^n
    r = Dict{Int, Number}()

    for cᵢ in c
        x = sum(cᵢ)
        r[x] = get(r,x,0) + 1/allcomb
    end
    r
 end

# CHECK for drop lowest-highest:https://stackoverflow.com/questions/50690348/calculate-probability-of-a-fair-dice-roll-in-non-exponential-time
# Complejísimo y muy lento...

function outcomes(n, sides,drophighest=0, droplowest=0)
    d=Dict()
    if n==0
        d[0]=1        
    elseif sides==0
        nothing
    else
        for dicewithmax in 0:n  # Resuelve cada caso en el que existen "dicewithmax" dados con el máximo resultado. El máximo es sides y se reduce en cada llamada a "outcomes"
                                # El caso 0 significa que ningún dado ha obtenido el máximo resultado "sides" y se resuelve la siguiente iteración con "sides-1"
            d1 = outcomes(n-dicewithmax,sides-1,max(drophighest-dicewithmax,0),droplowest) # Siguiente iteración quitando los dados que tienen máximo "sides" y repitiendo con "sides-1"

            maxdicenotdropped = max(min(dicewithmax-drophighest,n-drophighest-droplowest),0) # Se elimina un resultado máximo en caso de drophighest!=0

            sum_maxdice = maxdicenotdropped*sides
            mult = binomial(n,dicewithmax) # Combinaciones de obtener x dados con resultado máximo en n
            (d1 != nothing) && for (key, value) in d1
                d[sum_maxdice+key] = get(d,sum_maxdice+key,0) + mult*value
            end
        end
    end
    return d
end

    
    