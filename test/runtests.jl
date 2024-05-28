using StipplePlotly
using Test
using DataFrames

files = filter(endswith(".jl"), readdir(@__DIR__))

for file in files
    file == "runtests.jl" && continue

    title = file[1:end-3]
    @testset verbose = true "$title" begin
        include(file)
    end
end
