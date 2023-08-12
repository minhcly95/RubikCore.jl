module RubikCore

using StaticArrays
using Random
using Crayons

include("macros.jl")
include("face.jl")
include("symm.jl")
include("cubies.jl")
include("cube.jl")
include("move.jl")
include("rotate.jl")
include("canon.jl")
include("singmaster.jl")
include("display.jl")
include("utils.jl")

export Face, Up, Front, Right, Down, Back, Left, opposite, ALL_FACES
export Symm, is_mirrored, @symm_str, ALL_SYMMS, UNMIRRORED_SYMMS, MIRRORED_SYMMS
export Edge, Corner, perm, ori, slot_string
export Cube, singmaster, parse_singmaster
export Move, @seq_str
export rotate, normalize, is_congruent
export canonicalize
export net

module Literals
using ..RubikCore
import ..RubikCore: Move, Face, ALL_EDGES, ALL_CORNERS, N_FACES, N_EDGES, N_CORNERS, I

include("literal-moves.jl")

export FACE_TURNS, CUBE_ROTATIONS, SLICE_TURNS, WIDE_TURNS
@_export_move_powers(1:3, U, F, R, D, B, L)
@_export_move_powers(1:3, x, y, z)
@_export_move_powers(1:3, M, E, S)
@_export_move_powers(1:3, u, f, r, d, b, l)

end

using .Literals: FACE_TURNS

include("random.jl")

end
