using Rubik
using Test

@testset "Rubik.jl" begin
    include("const.jl")
    include("face.jl")
    include("symm.jl")
    include("cube.jl")
    include("move.jl")
    include("rotate.jl")
    include("canon.jl")
    include("print.jl")
    include("display.jl")
    include("search.jl")
end
