struct Cube
    c::NTuple{8, Int}
    e::NTuple{12, Int}
end

const NSTATES = 24
const ALL_STATES = 0:(NSTATES-1)

# State accessors
edge_perm(v::Int) = v >> 1
edge_ori(v::Int) = v & 1
corner_perm(v::Int) = v & 7
corner_ori(v::Int) = v >> 3

# State constructors
edge_val(perm::Int, ori::Int) = perm << 1 + ori
corner_val(perm::Int, ori::Int) = ori << 3 + perm

# Edge operators
edge_flip(v::Int) = v ⊻ 1
edge_ori_add(v1::Int, v2::Int) = v1 ⊻ edge_ori(v2)

# Corner operators (cached)
const _MOD24 = Tuple(Int[i % NSTATES for i in 0:(2*NSTATES - 1)])
const _CORNER_ORI_INC = Tuple([corner_val(corner_perm(i), (corner_ori(i) + 1) % 3) for i in 0:(NSTATES - 1)])
const _CORNER_ORI_DEC = Tuple([corner_val(corner_perm(i), (corner_ori(i) + 2) % 3) for i in 0:(NSTATES - 1)])
const _CORNER_ORI_NEG_STRIP = Tuple([corner_val(0, (3 - corner_ori(i)) % 3) for i in 0:(NSTATES - 1)])

corner_ori_inc(v::Int) = _CORNER_ORI_INC[v + 1]
corner_ori_dec(v::Int) = _CORNER_ORI_DEC[v + 1]
corner_ori_add(v1::Int, v2::Int) = _MOD24[v1 + v2 & 0b11000 + 1]
corner_ori_sub(v1::Int, v2::Int) = v1 + _CORNER_ORI_NEG_STRIP[v2 + 1]

# Identity cube (cached)
const _IDENTITY_CUBE = Cube(Tuple(corner_val(i, 0) for i in 0:7), Tuple(edge_val(i, 0) for i in 0:11))
Cube() = _IDENTITY_CUBE
