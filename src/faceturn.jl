const N_TWISTS = 3          # 3 turns for each face
const N_FACETURNS = N_TWISTS * N_FACES     

# Simpler representation of face turns
@define_int_struct(FaceTurn, UInt8, N_FACETURNS, AbstractMove)

const ALL_FACETURNS = Tuple(@inbounds FaceTurn(i) for i in 1:N_FACETURNS)

# Convert from and to Face
Face(ft::FaceTurn) = @inbounds Face(fld1(Int(ft), N_TWISTS))
twist(ft::FaceTurn) = mod1(Int(ft), N_TWISTS)

Base.@propagate_inbounds function FaceTurn(face::Face, twist::Integer = 1)
    @boundscheck (1 <= twist <= 3) || throw(ArgumentError("invalid value for twist: $twist. Must be within 1:3."))
    return @inbounds FaceTurn((Int(face) - 1) * N_TWISTS + twist)
end

# Convert from and to Move
const _FACETURN_MOVE = (
    Literals.U1, Literals.U2, Literals.U3,
    Literals.F1, Literals.F2, Literals.F3,
    Literals.R1, Literals.R2, Literals.R3,
    Literals.D1, Literals.D2, Literals.D3,
    Literals.B1, Literals.B2, Literals.B3,
    Literals.L1, Literals.L2, Literals.L3
)
Move(ft::FaceTurn) = @inbounds _FACETURN_MOVE[Int(ft)]

function FaceTurn(m::Move)
    i = findfirst(==(m), _FACETURN_MOVE)
    isnothing(i) && throw(ArgumentError("given Move cannot be converted to FaceTurn: $m"))
    return FaceTurn(i)
end

# Specialized operations
Base.inv(ft::FaceTurn) = @inbounds FaceTurn(Face(ft), N_TWISTS + 1 - twist(ft))

function Base.:^(ft::FaceTurn, p::Integer)
    t = mod(twist(ft) * p, 4)
    return t == 0 ? I : @inbounds FaceTurn(Face(ft), t)
end

# Cache FaceTurn rotation
const _FACETURN_ROTATE = Tuple(Tuple(FaceTurn(rotate(Move(ft), symm)) for ft in ALL_FACETURNS) for symm in ALL_SYMMS)
rotate(ft::FaceTurn, symm::Symm) = @inbounds _FACETURN_ROTATE[Int(symm)][Int(ft)]

# Print
Base.print(io::IO, ft::FaceTurn) = print(io, Move(ft))
Base.show(io::IO, ft::FaceTurn) = print(io, "FaceTurn($(Move(ft)))")
