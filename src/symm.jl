const NSYMMS = 48

struct Symm
    m::Int
    Base.@propagate_inbounds function Symm(m)
        @boundscheck (1 <= m <= NSYMMS) || error("Invalid Symm value ($m)")
        new(m)
    end
end
Symm() = Symm(1)

Cube(s::Symm) = s
Base.copy(s::Symm) = s

const ALL_SYMMS = Tuple(Symm(i) for i in 1:NSYMMS)

is_mirrored(s::Symm) = iseven(mod1(s.m, 8)) ⊻ iseven(fld1(s.m, 8))
const UNMIRRORED_SYMMS = Tuple(filter(!is_mirrored, ALL_SYMMS))
const MIRRORED_SYMMS = Tuple(filter(is_mirrored, ALL_SYMMS))

# Lookup tables
const _SYMM_PERMUTE_MAP = ("UFR", "URF", "FRU", "FUR", "RUF", "RFU")
const _SYMM_NEGATE_MAP = ("UFR", "UFL", "UBL", "UBR", "DBR", "DBL", "DFL", "DFR")

_symm_face_from_str(s::String) = tuple(Face.(collect(s))..., opposite.(Face.(collect(s)))...)
_symm_face_mul(a, b) = Tuple(b[Int(a[i])] for i in 1:6)

function _make_symm_face()
    symm_face = Vector(undef, NSYMMS)
    for i in 1:6
        symm_face[8*(i-1) + 1] = _symm_face_from_str(_SYMM_PERMUTE_MAP[i])
    end
    for i in 1:8
        symm_face[i] = _symm_face_from_str(_SYMM_NEGATE_MAP[i])
    end
    for i in 2:6, j in 2:8
        symm_face[8*(i-1) + j] = _symm_face_mul(symm_face[8*(i-1) + 1], symm_face[j])
    end
    return Tuple(symm_face)
end
const _SYMM_FACE = _make_symm_face()
const _SYMM_STR = Tuple(join(Char.(symm_face[1:3])) for symm_face in _SYMM_FACE)

function _make_symm_mul()
    symm_map = Dict(reverse.(enumerate(_SYMM_FACE)))
    symm_mul = [symm_map[_symm_face_mul(m, n)] for m in _SYMM_FACE, n in _SYMM_FACE]
    return Tuple(Tuple.(eachrow(symm_mul)))
end

const _SYMM_MUL = _make_symm_mul()
const _SYMM_INV = Tuple(findfirst(==(1), mul_i) for mul_i in _SYMM_MUL)

# Operations
remap(s::Symm, f::Face) = @inbounds _SYMM_FACE[s.m][Int(f)]

Base.:*(a::Symm, b::Symm) = @inbounds Symm(_SYMM_MUL[a.m][b.m])
Base.inv(s::Symm) = @inbounds Symm(_SYMM_INV[s.m])
Base.adjoint(s::Symm) = inv(s)
Base.:^(s::Symm, p::Integer) = Base.power_by_squaring(s, p)

# Whole cube rotation
function _make_symm_rot()
    edge_dict = Dict(reverse.(enumerate(_SM_EDGES)))
    corner_dict = Dict(reverse.(enumerate(_SM_CORNERS)))
    edge_rot = zeros(Int, NSYMMS, NSTATES)
    corner_rot = zeros(Int, NSYMMS, NSTATES)
    for m in 1:NSYMMS
        s = Symm(m)
        for v in ALL_STATES
            # Edge
            faces = remap.((s,), Face.(collect(_SM_EDGES[v+1])))
            edge_rot[m, v+1] = edge_dict[join(Char.(faces))]-1

            # Corner
            faces = remap.((s,), Face.(collect(_SM_CORNERS[v+1])))
            corner_rot[m, v+1] = _MOD24[corner_dict[join(Char.(faces))]]
        end
    end
    return Tuple(Tuple.(eachrow(edge_rot))), Tuple(Tuple.(eachrow(corner_rot)))
end
const _SYMM_EDGE_ROT, _SYMM_CORNER_ROT = _make_symm_rot()

function remap(s::Symm, c::Cube)
    m, n = s.m, inv(s).m
    me, mc, ne, nc = _SYMM_EDGE_ROT[m], _SYMM_CORNER_ROT[m], _SYMM_EDGE_ROT[n], _SYMM_CORNER_ROT[n]
    dc = MVector{8, Int}(undef)
    de = MVector{12, Int}(undef)
    @_for(i = 1:8, @inbounds dc[i] = mc[_corner_ori_add(c.c[_corner_perm(nc[i]) + 1], nc[i]) + 1])
    @_for(i = 1:12, @inbounds de[i] = me[_edge_ori_add(c.e[_edge_perm(ne[i*2-1]) + 1], ne[i*2-1]) + 1])
    return @inbounds Cube(Tuple(dc), Tuple(de))
end

remap(s::Symm, m::Move) = Move(remap(s, Cube(m)))

# Print
Base.show(io::IO, s::Symm) = print(io, "Symm($(_SYMM_STR[s.m]))")

# Parse
function Symm(str::AbstractString)
    m = findfirst(==(str), _SYMM_STR)
    isnothing(m) && error("Invalid Symm string ($str)")
    return Symm(m)
end

Base.parse(::Type{Symm}, str::AbstractString) = Symm(str)

macro symm_str(str)
    return :(Symm($(esc(str))))
end
