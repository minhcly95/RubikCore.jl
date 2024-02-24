module RubikCore

using FastPerms
using Random
using Crayons

include("int_struct.jl")
include("make_tuple.jl")

include("face.jl")
include("symm.jl")
include("edge_state.jl")
include("corner_state.jl")
include("cube.jl")
include("singmaster.jl")
include("move.jl")
include("rotate.jl")
include("literal-moves.jl")
include("faceturn.jl")
include("random.jl")
include("canon.jl")
include("display.jl")

export AbstractMove
export Face, Up, Front, Right, Down, Back, Left, opposite
export Symm, @symm_str
export Cube
export Move, @seq_str
export normalize, is_congruent
export FaceTurn, twist
export canonicalize

# Literals submodule
module Literals
using ..RubikCore
import ..RubikCore: @_reexport_move_powers

import ..RubikCore: FACE_TURNS, CUBE_ROTATIONS, SLICE_TURNS, WIDE_TURNS
export FACE_TURNS, CUBE_ROTATIONS, SLICE_TURNS, WIDE_TURNS

@_reexport_move_powers(1:3, U, F, R, D, B, L)
@_reexport_move_powers(1:3, x, y, z)
@_reexport_move_powers(1:3, M, E, S)
@_reexport_move_powers(1:3, u, f, r, d, b, l)
end

end
