using RubikCore, RubikCore.Literals
using RubikCore:
    I, ALL_FACES, ALL_SYMMS, EVEN_SYMMS, ODD_SYMMS, N_EDGES, N_CORNERS, ALL_FACETURNS, singmaster,
    EdgeState, CornerState, flip_edge, swap_edges, twist_corner, swap_corners,
    edge_ori, corner_ori, edge_perm, corner_perm, parity
using Test

@testset "RubikCore.jl" begin
    include("const.jl")
    include("face.jl")
    include("symm.jl")
    include("cube.jl")
    include("lowlevel.jl")
    include("move.jl")
    include("faceturn.jl")
    include("rotate.jl")
    include("canon.jl")
    include("print.jl")
    include("display.jl")
    include("search.jl")
end
