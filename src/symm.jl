const N_SYMMS = 48

# Struct
@int_struct struct Symm
    N_SYMMS::UInt8
end

Symm() = @inbounds Symm(1)
Base.one(::Type{Symm}) = Symm()
Base.one(::Symm) = Symm()

const ALL_SYMMS = Tuple(instances(Symm))

# Parity
Base.isodd(s::Symm) = iseven(mod1(Int(s), 8)) ⊻ iseven(fld1(Int(s), 8))
Base.iseven(s::Symm) = !isodd(s)

const EVEN_SYMMS = Tuple(filter(iseven, ALL_SYMMS))
const ODD_SYMMS = Tuple(filter(isodd, ALL_SYMMS))

# Represent Symm as permutation of faces
const SYMM_PERMUTE_GEN = (
    SPerm(1, 2, 3, 4, 5, 6),     # UFR
    SPerm(1, 3, 2, 4, 6, 5),     # URF
    SPerm(2, 3, 1, 5, 6, 4),     # FRU
    SPerm(2, 1, 3, 5, 4, 6),     # FUR
    SPerm(3, 1, 2, 6, 4, 5),     # RUF
    SPerm(3, 2, 1, 6, 5, 4),     # RFU
)
const SYMM_NEGATE_GEN = (
    SPerm(1, 2, 3, 4, 5, 6),     # UFR
    SPerm(1, 2, 6, 4, 5, 3),     # UFL
    SPerm(1, 5, 6, 4, 2, 3),     # UBL
    SPerm(1, 5, 3, 4, 2, 6),     # UBR
    SPerm(4, 5, 3, 1, 2, 6),     # DBR
    SPerm(4, 5, 6, 1, 2, 3),     # DBL
    SPerm(4, 2, 6, 1, 5, 3),     # DFL
    SPerm(4, 2, 3, 1, 5, 6),     # DFR
)

const SYMM_PERM = Tuple(a * b for b in SYMM_NEGATE_GEN, a in SYMM_PERMUTE_GEN)

FastPerms.SPerm(s::Symm) = @inbounds SYMM_PERM[s]
Symm(a::SPerm) = Symm(findfirst(==(a), SYMM_PERM))

# Get the image of the given face
const SYMM_FACE = Tuple(Tuple(Face.(a)) for a in SYMM_PERM)

(s::Symm)(f::Face) = @inbounds SYMM_FACE[s][f]

# Multiplication and inversion
const SYMM_MUL = make_tuple([Symm(a * b) for a in SYMM_PERM, b in SYMM_PERM])
const SYMM_INV = Tuple(Symm(findfirst(==(Symm()), mul_i)) for mul_i in SYMM_MUL)

Base.:*(a::Symm, b::Symm) = @inbounds SYMM_MUL[a][b]
Base.inv(s::Symm) = @inbounds SYMM_INV[s]
Base.adjoint(s::Symm) = inv(s)
Base.:^(s::Symm, p::Integer) = Base.power_by_squaring(s, p)

# Print and parse
const SYMM_STR = Tuple(join(Char.(symm_face[1:3])) for symm_face in SYMM_FACE)

Base.print(io::IO, s::Symm) = print(io, @inbounds SYMM_STR[s])
Base.show(io::IO, s::Symm) = print(io, "Symm(\"$s\")")

function Symm(str::AbstractString)
    s = findfirst(==(str), SYMM_STR)
    isnothing(s) && error("invalid string for Symm: $str")
    return Symm(s)
end

Base.parse(::Type{Symm}, str::AbstractString) = Symm(str)

macro symm_str(str)
    return :(Symm($str))
end
