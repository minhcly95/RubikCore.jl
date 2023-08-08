using Rubik
using Test

@testset "Rubik.jl" begin
    include("const.jl")
    include("ops.jl")
    include("symm.jl")
    include("print.jl")
    include("display.jl")
end
