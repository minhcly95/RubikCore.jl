const NSTATES = 24
const ALL_STATES = 0:(NSTATES-1)

struct Cube
    c::NTuple{8, Int}
    e::NTuple{12, Int}
    
    Base.@propagate_inbounds function Cube(c, e)
        @boundscheck all(in(ALL_STATES), c) && all(in(ALL_STATES), e) || error("Invalid cubies state")
        new(c, e)
    end
end

# State accessors
@inline _edge_perm(v::Int) = v >> 1
@inline _edge_ori(v::Int) = v & 1
@inline _corner_perm(v::Int) = v & 0b111
@inline _corner_ori(v::Int) = v >> 3

# State constructors
@inline _edge_val(perm::Int, ori::Int) = perm << 1 + ori
@inline _corner_val(perm::Int, ori::Int) = ori << 3 + perm

# Edge operators
@inline _edge_flip(v::Int) = v ⊻ 1
@inline _edge_ori_add(v1::Int, v2::Int) = v1 ⊻ _edge_ori(v2)

# Corner operators (cached)
const _MOD24 = Tuple(Int[i % NSTATES for i in 0:(2*NSTATES - 1)])
const _CORNER_ORI_INC = Tuple([_corner_val(_corner_perm(i), (_corner_ori(i) + 1) % 3) for i in 0:(NSTATES - 1)])
const _CORNER_ORI_DEC = Tuple([_corner_val(_corner_perm(i), (_corner_ori(i) + 2) % 3) for i in 0:(NSTATES - 1)])
const _CORNER_ORI_NEG_STRIP = Tuple([_corner_val(0, (3 - _corner_ori(i)) % 3) for i in 0:(NSTATES - 1)])

@inline _corner_ori_inc(v::Int) = @inbounds _CORNER_ORI_INC[v + 1]
@inline _corner_ori_dec(v::Int) = @inbounds _CORNER_ORI_DEC[v + 1]
@inline _corner_ori_add(v1::Int, v2::Int) = @inbounds _MOD24[v1 + v2 & 0b11000 + 1]
@inline _corner_ori_sub(v1::Int, v2::Int) = @inbounds v1 + _CORNER_ORI_NEG_STRIP[v2 + 1]

# Identity cube
const _IDENTITY_CUBE = Cube(Tuple(_corner_val(i, 0) for i in 0:7), Tuple(_edge_val(i, 0) for i in 0:11))
@inline Cube() = _IDENTITY_CUBE
Base.one(::Type{Cube}) = Cube()
