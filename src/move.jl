const NFACES = 6
const NTWISTS = 3
const NMOVES = NFACES * NTWISTS

# Identity cube
const I = Cube(Tuple(_corner_val(i, 0) for i in 0:7), Tuple(_edge_val(i, 0) for i in 0:11))

# Fundamental moves
@enum Face Up=1 Front Right Down Back Left
const ALL_FACES = instances(Face)

function _make_fundamental_moves()
    EDGE_TWIST_PERM = ((0, 2, 3, 1), (3, 7, 11, 6), (2, 5, 10, 7), (9, 11, 10, 8), (0, 4, 8, 5), (1, 6, 9, 4))
    CORNER_TWIST_PERM = ((0, 1, 3, 2), (2, 3, 7, 6), (3, 1, 5, 7), (4, 6, 7, 5), (1, 0, 4, 5), (0, 2, 6, 4))
    EDGE_CHANGE = (0, 0, 1, 0, 0, 1)
    CORNER_CHANGE = ((0, 0, 0, 0), (1, 2, 1, 2), (1, 2, 1, 2), (0, 0, 0, 0), (1, 2, 1, 2), (1, 2, 1, 2))

    edge_trans = [v for _ in ALL_FACES, v in 0:(NSTATES-1)]
    corner_trans = [v for _ in ALL_FACES, v in 0:(NSTATES-1)]

    for face in ALL_FACES
        f = Int(face)
        for i in 1:4
            ii = mod1(i + 1, 4)
            for o in 0:1
                oo = o ⊻ EDGE_CHANGE[f]
                edge_trans[f, _edge_val(EDGE_TWIST_PERM[f][i], o) + 1] = _edge_val(EDGE_TWIST_PERM[f][ii], oo)
            end
            for o in 0:2
                oo = (o + CORNER_CHANGE[f][i]) % 3
                corner_trans[f, _corner_val(CORNER_TWIST_PERM[f][i], o) + 1] = _corner_val(CORNER_TWIST_PERM[f][ii], oo)
            end
        end
    end

    return Tuple(
        Cube(
            Tuple(corner_trans[f, _corner_val(i, 0) + 1] for i in 0:7),
            Tuple(edge_trans[f, _edge_val(i, 0) + 1] for i in 0:11))
        for f in 1:NFACES)
end

const U, F, R, D, B, L = _make_fundamental_moves()

# Literal moves
const U1, F1, R1, D1, B1, L1 = U, F, R, D, B, L
const U2, F2, R2, D2, B2, L2 = U*U, F*F, R*R, D*D, B*B, L*L
const U3, F3, R3, D3, B3, L3 = U', F', R', D', B', L'

const ALL_MOVES = (U1, U2, U3, F1, F2, F3, R1, R2, R3, D1, D2, D3, B1, B2, B3, L1, L2, L3)

# Face to move
Cube(f::Face) = Cube(Val(f))
Cube(::Val{Up}) = U
Cube(::Val{Front}) = F
Cube(::Val{Right}) = R
Cube(::Val{Down}) = D
Cube(::Val{Back}) = B
Cube(::Val{Left}) = L

@inline Base.inv(f::Face) = inv(Cube(f))
@inline Base.adjoint(f::Face) = inv(Cube(f))
@inline Base.literal_pow(::typeof(^), f::Face, p::Val) = Base.literal_pow(^, Cube(f), p)
