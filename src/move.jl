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
Base.:(==)(a::Move, b::Cube) = Cube(a) == b
Base.:(==)(a::Cube, b::Move) = a == Cube(b)

# Operations
Base.:*(a::Cube, b::Move) = a * Cube(b)
Base.:*(a::Move, b::Cube) = Cube(a) * b
Base.:*(a::Move, b::Move) = Move(Cube(a) * Cube(b))
Base.inv(m::Move) = Move(inv(Cube(m)))
Base.adjoint(m::Move) = inv(m)
Base.literal_pow(::typeof(^), m::Move, p::Val) = Move(Base.literal_pow(^, Cube(m), p))

# Sequence of moves
Move(ms::AbstractVector{Move}) = prod(ms)
Cube(ms::AbstractVector{Move}) = Cube(prod(ms))
Base.:*(c::Cube, ms::AbstractVector{Move}) = prod(ms, init=c)
Base.:*(ms::AbstractVector{Move}, c::Cube) = prod(ms) * c
Base.inv(ms::AbstractVector{Move}) = reverse!(inv.(ms))
Base.adjoint(ms::AbstractVector{Move}) = inv(ms)
Base.:^(ms::AbstractVector{Move}, p::Integer) = repeat(ms, outer=p)

# Parse (implemented in literal-moves.jl)
Move(str::AbstractString) = parse(Move, str)

Base.parse(::Type{Vector{Move}}, str::AbstractString) = parse.(Move, split(str))

macro seq_str(str)
    return :(parse(Vector{Move}, $(esc(str))))
end
