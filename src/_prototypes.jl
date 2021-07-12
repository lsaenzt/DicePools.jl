#-----------------------------------------------------------------------------------------------------------------------------
# DICE RESULTS
#-----------------------------------------------------------------------------------------------------------------------------

# IDEA 1: not working because each result of multiexponent is different and therefore the arguments of multinomialₘₑₘ

using Memoize
@memoize multinomialₘₑₘ(k::Vector{Int}) =  multinomial(k...) # No funciona porque cada resultado de multiexponent es diferente...

# IDEA 2: repetir todas las combinaciones de resultados. Sencillo pero acaba siendo lento, con 5d100 se queda sin memoria y no tengo resultados individuales...
function roll(n,s)

    l = length(s)
    results = repeat(s,inner=l).+ repeat(s,outer=l)
        for i in 3:n
            results = repeat(results,inner=l).+ repeat(s,outer=length(results))
        end

    ur = unique(results)
    freq = Int[sum([c == x for c in results]) for x in ur]

    return zip(ur,freq./(l^n)*100)
    
end

# IDEA 3: Este bucle obtiene las combinaciones con repeticion correctamente para 3d6. No sé cómo hacer anidados de profundidad = nº de dados
count=1
for i in 1:6, j in i:6, k in j:6
     println(i,j,k," ",count)
     count +=1  
end

# IDEA 4: recursive "loop" para resolver el problema de Idea 3. Complejo y no sé si más rápido.
d=Dict{Int,Int}()
a=zeros(Int,12)

function recursivedie(n,s,k=1)
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

# IDEA 5: El producto de todas las combinaciones. Simple pero muy lento.

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

 # IDEA 6: Idea 2 pero con una función llamada recursivamente. El mejor con diferencia

function recursivedistribution(n,s)

    dice = [1:s fill(1/s,s)]

    if n==1
        r = dice # Cambiar 1:s por Dice.results y fill(1/Dice.sides,Dice.sides) por
    else
        d₋₁ = recursivedistribution(n-1,s)

        dˢ = repeat(d₋₁,inner = (s,1))
        sᵈ = repeat(dice,outer = (size(d₋₁,1),1))

        results = dˢ[:,1].+sᵈ[:,1]
        freq = dˢ[:,2].* sᵈ[:,2]

        ur = unique(results)
        p = [sum([(c == x)*f for (c,f) in zip(results,freq)]) for x in ur] 
        
        r = [ur p] # TODO: sumar modificador a ur
    end
    return r
end

# Solution shown in https://stackoverflow.com/questions/50690348/calculate-probability-of-a-fair-dice-roll-in-non-exponential-time
# Complex and slow. See attached csmax.xlsx for simulation of what the function is doing

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
            (d1 !== nothing) && for (key, value) in d1
                d[sum_maxdice+key] = get(d,sum_maxdice+key,0) + mult*value
            end
        end
    end
    return d
end

    
# Test dispatch

dummy(n::Int, a::Int, mod::Int=0)=n*a+mod

dummy(n::Int, a::Real;s=1)=n*a^s


#-----------------------------------------------------------------------------------------------------------------------------
# DEPRECATED roll+function method. Does not work with repeated values
#-----------------------------------------------------------------------------------------------------------------------------

function roll(f::Function,n::Union{Int,OrdinalRange},dice::NumericDice;name::String="Dice") 

    A = Array{Real,2}(undef,0,3)  

    for nᵢ in n
    # 1. Calculate the probability each combination o sides. First taking into account ordenations of sides and secondly considering repeated sides on a die
    c = with_replacement_combinations(dice.results,nᵢ)
    allcomb = dice.sides^nᵢ # Todas las posibles combinaciones de caras que pueden salir

    r = OrderedDict{Int, Real}() 
        for cᵢ in c
            rep = count_repeated(cᵢ)          
            reord = multinomial(rep...) # Todas las ordenaciones de dados que pueden dar esa combinación de resultados Ej. 3 dados con 4 y 3 dados con 2 
            prob = reord/allcomb*100
            s = f(cᵢ)
            r[s] = get(r,s,0) + prob
        end
    sort!(r)
    # 2. Concatenate results
    A = vcat(A,hcat(fill(nᵢ,length(r)),collect(keys(r)),collect(values(r))))
    end

    # 3. Creates a DiceProbabilties Struc
    cols = [Symbol(name),:Result,:Probability]
    DicePools.DiceProbabilities(cols,1,A,Dict([j => i for (i,j) in enumerate(cols)])) # Struct Table.jl compliant
end


#-----------------------------------------------------------------------------------------------------------------------------
# COUNT DUPLICATES
#-----------------------------------------------------------------------------------------------------------------------------

# This one works but doing many, many allocations
function count_duplicates(a::Array,r=[])
    i = 1
    while i<length(a) && (a[i] == a[i+1])
        i += 1
    end
    i < length(a) && count_duplicates(a[i+1:end],r)
    push!(r,i)
end

# This one works much faster
function count_duplicates(a::Array)
    i = 1
    d = 1
    for j in 2:length(a)
       if a[j]==a[j-1] 
         i+=d
       else
         d *= 10
         i += d
        end
    end
    digits(i)
end
