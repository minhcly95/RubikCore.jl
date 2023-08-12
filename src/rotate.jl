# Face rotation
rotate(f::Face, symm::Symm) = @inbounds _SYMM_FACE[Int(symm)][Int(f)]

# Symm rotation
rotate(s::Symm, symm::Symm) = s * symm

# Cubies rotation
function _make_rotate_tables()
    edge_dict = Dict(str => ALL_EDGES[i] for (i, str) in enumerate(_EDGE_STRS))
    corner_dict = Dict(str => ALL_CORNERS[mod1(i, N_STATES)] for (i, str) in enumerate(_CORNER_STRS))
    rotate_edge = Matrix{Edge}(undef, N_SYMMS, N_STATES)
    rotate_corner = Matrix{Corner}(undef, N_SYMMS, N_STATES)
    for s in ALL_SYMMS
        for v in 1:N_STATES
            # Edge
            faces = rotate.(Face.(collect(_EDGE_STRS[v])), (s,))
            rotate_edge[Int(s), v] = edge_dict[join(Char.(faces))]
            # Corner
            faces = rotate.(Face.(collect(_CORNER_STRS[v])), (s,))
            rotate_corner[Int(s), v] = corner_dict[join(Char.(faces))]
        end
    end
    return Tuple(Tuple.(eachrow(rotate_edge))), Tuple(Tuple.(eachrow(rotate_corner)))
end
const _ROTATE_EDGE, _ROTATE_CORNER = _make_rotate_tables()

rotate(e::Edge, symm::Symm) = @inbounds _ROTATE_EDGE[Int(symm)][Int(e)]
rotate(c::Corner, symm::Symm) = @inbounds _ROTATE_CORNER[Int(symm)][Int(c)]

# Cube rotation
function rotate(c::Cube, symm::Symm)
    ds = rotate(c.center, symm)
    de = rotate.(c.edges, (symm,))
    dc = rotate.(c.corners, (symm,))
    return @inbounds Cube(ds, de, dc)
end

# Move rotation
rotate(m::Move, symm::Symm) = Move(rotate(rotate(Cube(), symm') * m, symm))

# Normalization: turn the cube back to [UFR]
normalize(c::Cube) = rotate(c, c.center')

# Congruence (same cube up to symmetry)
is_congruent(a::Cube, b::Cube) = a == rotate(b, b.center' * a.center)
