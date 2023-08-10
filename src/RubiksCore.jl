module RubiksCore

using StaticArrays
using Random
using Crayons

include("face.jl")
include("symm.jl")
include("cubies.jl")
include("cube.jl")
include("move.jl")
include("rotate.jl")
include("canon.jl")
include("literal-moves.jl")
include("singmaster.jl")
include("display.jl")
include("random.jl")
include("utils.jl")

export Face, Up, Front, Right, Down, Back, Left, opposite, ALL_FACES
export Symm, is_mirrored, @symm_str, ALL_SYMMS, UNMIRRORED_SYMMS, MIRRORED_SYMMS
export Edge, Corner, perm, ori
export Cube, singmaster, parse_singmaster
export Move, I, @seq_str
export rotate, normalize, is_congruent
export canonicalize

export FACE_TURNS, CUBE_ROTATIONS, SLICE_TURNS, WIDE_TURNS
@_export_move_powers(1:3, U, F, R, D, B, L)
@_export_move_powers(1:3, x, y, z)
@_export_move_powers(1:3, M, E, S)
@_export_move_powers(1:3, u, f, r, d, b, l)

end
