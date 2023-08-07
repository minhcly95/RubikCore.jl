module Rubik

using StaticArrays
using Random
using Crayons

include("utils.jl")
include("cube.jl")
include("ops.jl")
include("move.jl")
include("print.jl")
include("display.jl")
include("random.jl")

export Cube
export Face, Up, Front, Right, Down, Back, Left
export Move, I, U, F, R, D, B, L
export U1, U2, U3, F1, F2, F3, R1, R2, R3, D1, D2, D3, B1, B2, B3, L1, L2, L3
export ALL_FACES, BASIC_MOVES

export singmaster, @seq_str

end
