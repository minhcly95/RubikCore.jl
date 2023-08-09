const NSYMMS = 48

# Struct
struct Symm
    s::UInt8
    function Symm(s::Integer)
        (1 <= s <= NSYMMS) || throw(ArgumentError("invalid value for Symm: $s"))
        return new(s)
    end
end

const ALL_SYMMS = Tuple(Symm(i) for i in 1:NSYMMS)

Symm() = @inbounds ALL_SYMMS[1]
Base.copy(s::Symm) = s

Base.Int(s::Symm) = Int(s.s)

# Mirrored
is_mirrored(s::Symm) = iseven(mod1(s.s, 8)) ⊻ iseven(fld1(s.s, 8))
const UNMIRRORED_SYMMS = Tuple(filter(!is_mirrored, ALL_SYMMS))
const MIRRORED_SYMMS = Tuple(filter(is_mirrored, ALL_SYMMS))

# Face mapping
const _SYMM_PERMUTE_MAP = ("UFR", "URF", "FRU", "FUR", "RUF", "RFU")
const _SYMM_NEGATE_MAP = ("UFR", "UFL", "UBL", "UBR", "DBR", "DBL", "DFL", "DFR")

_symm_face_from_str(str::String) = tuple(Face.(collect(str))..., opposite.(Face.(collect(str)))...)
_symm_face_mul(a, b) = Tuple(b[Int(a[i])] for i in 1:NFACES)

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

# Operations
function _make_symm_mul()
    symm_map = Dict(reverse.(enumerate(_SYMM_FACE)))
    symm_mul = [Symm(symm_map[_symm_face_mul(s, n)]) for s in _SYMM_FACE, n in _SYMM_FACE]
    return Tuple(Tuple.(eachrow(symm_mul)))
end
const _SYMM_MUL = _make_symm_mul()
const _SYMM_INV = Tuple(Symm(findfirst(==(Symm()), mul_i)) for mul_i in _SYMM_MUL)

Base.:*(a::Symm, b::Symm) = @inbounds _SYMM_MUL[Int(a)][Int(b)]
Base.inv(s::Symm) = @inbounds _SYMM_INV[Int(s)]
Base.adjoint(s::Symm) = inv(s)
Base.:^(s::Symm, p::Integer) = Base.power_by_squaring(s, p)

# Print and parse
Base.print(io::IO, s::Symm) = print(io, @inbounds _SYMM_STR[Int(s)])

Base.show(io::IO, s::Symm) = print(io, "Symm(\"$s\")")

function Symm(str::AbstractString)
    s = findfirst(==(str), _SYMM_STR)
    isnothing(s) && error("invalid string for Symm: $str")
    return Symm(s)
end

Base.parse(::Type{Symm}, str::AbstractString) = Symm(str)

macro symm_str(str)
    return :(Symm($(esc(str))))
end
