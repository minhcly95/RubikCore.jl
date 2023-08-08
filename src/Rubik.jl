module Rubik

using StaticArrays
using Random
using Crayons

include("utils.jl")
include("cube.jl")
include("ops.jl")
include("face.jl")
include("move.jl")
include("singmaster.jl")
include("symm.jl")
include("s-cube.jl")
include("display.jl")
include("random.jl")

export Cube
export Face, Up, Front, Right, Down, Back, Left, opposite
export Move, I, U, F, R, D, B, L
export U1, U2, U3, F1, F2, F3, R1, R2, R3, D1, D2, D3, B1, B2, B3, L1, L2, L3
export Symm, is_mirrored, remap
export SCube, normalize, is_congruent

export ALL_FACES, BASIC_MOVES, ALL_SYMMS, UNMIRRORED_SYMMS, MIRRORED_SYMMS
export singmaster, @seq_str, @symm_str

end
