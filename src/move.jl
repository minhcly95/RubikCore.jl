struct Move
    cube::Cube
end

Base.copy(m::Move) = m
Move(m::Move) = m
Cube(m::Move) = m.cube

# Identity move
Move() = Move(Cube())
const I = Move()

Base.one(::Move) = I
Base.one(::Type{Move}) = I

# Comparison with Cube
@inline Base.:(==)(a::Move, b::Cube) = Cube(a) == b
@inline Base.:(==)(a::Cube, b::Move) = a == Cube(b)

# Operations
@inline Base.:*(a::Cube, b::Move) = a * Cube(b)
@inline Base.:*(a::Move, b::Move) = Move(Cube(a) * Cube(b))
@inline Base.inv(m::Move) = Move(inv(Cube(m)))
@inline Base.adjoint(m::Move) = inv(m)
@inline Base.literal_pow(::typeof(^), m::Move, p::Val) = Move(Base.literal_pow(^, Cube(m), p))

# Sequence of moves
Move(ms::AbstractVector{Move}) = prod(ms)
Cube(ms::AbstractVector{Move}) = Cube(prod(ms))
Base.:*(c::Cube, ms::AbstractVector{Move}) = prod(ms, init=c)
