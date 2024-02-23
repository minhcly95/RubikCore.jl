const N_TWISTS = 3          # 3 turns for each face
const N_FACETURNS = N_TWISTS * N_FACES

# Simpler representation of face turns
@int_struct struct FaceTurn <: AbstractMove
    N_FACETURNS::UInt8
end

# Get all instances of FaceTurn
Base.instances(::Type{FaceTurn}) = @inbounds FaceTurn.(1:N_FACETURNS)
const ALL_FACETURNS = Tuple(instances(FaceTurn))

# Get index shorthand
Base.@propagate_inbounds Base.getindex(a::Tuple, ft::FaceTurn) = getindex(a, convert(Int, ft))

# Convert from and to Face
Face(ft::FaceTurn) = @inbounds Face(fld1(Int(ft), N_TWISTS))
twist(ft::FaceTurn) = mod1(Int(ft), N_TWISTS)

Base.@propagate_inbounds function FaceTurn(face::Face, twist::Integer=1)
    @boundscheck (1 <= twist <= 3) || throw(ArgumentError("invalid value for twist: $twist. Must be within 1:3."))
    return @inbounds FaceTurn((Int(face) - 1) * N_TWISTS + twist)
end

# Convert from and to Move
Move(ft::FaceTurn) = @inbounds FACE_TURNS[ft]

function FaceTurn(m::Move)
    i = findfirst(==(m), FACE_TURNS)
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
const SYMM_FACETURN = Tuple(Tuple(FaceTurn(symm(Move(ft))) for ft in ALL_FACETURNS) for symm in ALL_SYMMS)
(symm::Symm)(ft::FaceTurn) = @inbounds SYMM_FACETURN[symm][ft]

# Print
Base.print(io::IO, ft::FaceTurn) = print(io, Move(ft))
Base.show(io::IO, ft::FaceTurn) = print(io, "FaceTurn($(Move(ft)))")

