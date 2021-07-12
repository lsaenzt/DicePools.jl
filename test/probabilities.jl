using Test, .DicePools

# Standard die
    
    std = roll(10,d100);
@test abs(sum(std.Probability)-100) <= 0.001

# Custom die
    
    custom = roll(10,CustomDice([-5,-4,-3,-2,-1,0,0,0,1,2,3,4,5]));
@test abs(sum(custom.Probability)-100) <= 0.001

# Custom operation
    
    customf = roll(5,CustomDice([-5,-4,-3,-2,-1,0,0,0,1,2,3,4,5])) do r
                sum(abs.(r))+2
            end
@test abs(sum(customf.Probability)-100) <= 0.001

# Non-standard numeric roll

    beat = beattarget(5,d12; target = 10);
@test sum(beat.Probability)-100 <= 0.001

    below = belowtarget(5,d12; target = 10);
@test sum(below.Probability)-100 <= 0.001

# Symbol Dice

    symd = DicePools.roll(3:6,Conan_Dmg)

    @test sum(data(symd)[data(symd)[:,1].==3,5])-100 <= 0.001
    @test sum(data(symd)[data(symd)[:,1].==4,5])-100 <= 0.001
    @test sum(data(symd)[data(symd)[:,1].==5,5])-100 <= 0.001
    @test sum(data(symd)[data(symd)[:,1].==6,5])-100 <= 0.001

@test unique(round.(psum[:,2], digits=2)) == [100.0] #Test all probabilities add up 100%

    chance = sort!(combine(groupby(tdf,[:Conan,:Hit]),:Probability => sum => :Probability),[:Conan,:Hit]); # Probabities for each number of dice and number of Hits

@test maximum(chance.Probability)<=100

    cumchance = transform(groupby(chance,[:Conan]),[:Hit,:Probability] => ((s,p) -> sum(p.*[s.<=i for i in s])) => :MoreThan);

@test maximum(round.(cumchance.MoreThan,digits=2)) <= 100

# Pooling

pl = pool(beat,below,custom);
@test abs(sum(pl.Probability)-100) <= 0.001 

pl2 = pool(customf,symd);
@test abs(sum(pl2.Probability)-4*100) <= 0.001 #There a 4 dice groups in symd (3,4,5,6)