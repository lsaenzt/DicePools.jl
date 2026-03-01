using Pkg;
Pkg.activate(@__DIR__);
Pkg.add("BenchmarkTools");
using DicePools;
using BenchmarkTools;

println("Benchmarking DicePools operations")

println("--- benchmark roll(10, d6)")
@btime roll(10, d6)

println("--- benchmark roll(1:10, d6)")
@btime roll(1:10, d6)

println("--- benchmark customroll(10, d6, x->sum(x))")
@btime customroll(x -> sum(x), 10, d6)

println("--- benchmark pool of dice")
@btime pool(roll(3, d6), roll(2, d8))

println("--- benchmark roll(10, MY0_Skill)")
@btime roll(10, MY0_Skill)

println("--- benchmark reroll(MY0_Skill)")
@btime reroll(5, MY0_Skill, :Blank)
