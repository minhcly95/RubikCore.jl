# Lookup tables
const _EDGE_TWIST_PERM = ((0, 2, 3, 1), (3, 7, 11, 6), (2, 5, 10, 7), (9, 11, 10, 8), (0, 4, 8, 5), (1, 6, 9, 4))
const _CORNER_TWIST_PERM = ((0, 1, 3, 2), (2, 3, 7, 6), (3, 1, 5, 7), (4, 6, 7, 5), (1, 0, 4, 5), (0, 2, 6, 4))
const _EDGE_CHANGE = (0, 0, 1, 0, 0, 1)
const _CORNER_CHANGE = ((0, 0, 0, 0), (1, 2, 1, 2), (1, 2, 1, 2), (0, 0, 0, 0), (1, 2, 1, 2), (1, 2, 1, 2))

function _make_transition_lookup()
    edge_trans = [v for _ in 1:NMOVES, v in 0:(NSTATES-1)]
    corner_trans = [v for _ in 1:NMOVES, v in 0:(NSTATES-1)]

    for face in ALL_FACES, t in 1:NTWISTS
        f = Int(face)
        m = Move(face, t)
        isquarter = t != 2
        for i in 1:4
            ii = mod1(i + t, 4)
            for o in 0:1
                oo = isquarter ? o : o ⊻ _EDGE_CHANGE[f]
                edge_trans[Int(m), edge_val(_EDGE_TWIST_PERM[f][i], o) + 1] = edge_val(_EDGE_TWIST_PERM[f][ii], oo)
            end
            for o in 0:2
                oo = isquarter ? o : (o + _CORNER_CHANGE[f][i]) % 3
                corner_trans[Int(m), corner_val(_CORNER_TWIST_PERM[f][i], o) + 1] = corner_val(_CORNER_TWIST_PERM[f][ii], oo)
            end
        end
    end

    return Tuple(Tuple.(eachrow(edge_trans))), Tuple(Tuple.(eachrow(corner_trans)))
end
const _EDGE_TRANS, _CORNER_TRANS = _make_transition_lookup()

macro _getfield_boundscheck(A, i)
    return Expr(:call, :getfield, esc(A), esc(i), Expr(:boundscheck))
end

# Move function
function move_cubies(c::Cube, m::Move)
    if m == I
        return c
    else
        corner_trans_m = _CORNER_TRANS[Int(m)]
        edge_trans_m = _EDGE_TRANS[Int(m)]
        return Cube((
            @_getfield_boundscheck(corner_trans_m, c.c[1]+1),
            @_getfield_boundscheck(corner_trans_m, c.c[2]+1),
            @_getfield_boundscheck(corner_trans_m, c.c[3]+1),
            @_getfield_boundscheck(corner_trans_m, c.c[4]+1),
            @_getfield_boundscheck(corner_trans_m, c.c[5]+1),
            @_getfield_boundscheck(corner_trans_m, c.c[6]+1),
            @_getfield_boundscheck(corner_trans_m, c.c[7]+1),
            @_getfield_boundscheck(corner_trans_m, c.c[8]+1),
            ), (
            @_getfield_boundscheck(edge_trans_m, c.e[1]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[2]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[3]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[4]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[5]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[6]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[7]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[8]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[9]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[10]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[11]+1),
            @_getfield_boundscheck(edge_trans_m, c.e[12]+1),
            ))
    end
end

Base.@propagate_inbounds Base.:*(c::Cube, m::Move) = move_cubies(c, m)
