using RubikCore, RubikCore.Literals
using RubikCore: I
using Test

@testset "RubikCore.jl" begin
    include("const.jl")
    include("face.jl")
    include("symm.jl")
    include("cube.jl")
    include("move.jl")
    include("faceturn.jl")
    include("rotate.jl")
    include("canon.jl")
    include("print.jl")
    include("display.jl")
    include("search.jl")
end
