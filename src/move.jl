abstract type AbstractMove end

struct Move <: AbstractMove
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

# Operations (abstract form)
Cube(m::AbstractMove) = Cube(Move(m))

Base.:(==)(a::Cube, b::AbstractMove) = a == Cube(b)
Base.:(==)(a::AbstractMove, b::Cube) = Cube(a) == b
Base.:(==)(a::AbstractMove, b::AbstractMove) = Cube(a) == Cube(b)

Base.:*(a::Cube, b::AbstractMove) = a * Cube(b)
Base.:*(a::AbstractMove, b::Cube) = Cube(a) * b
Base.:*(a::AbstractMove, b::AbstractMove) = Move(Cube(a) * Cube(b))

Base.inv(m::AbstractMove) = Move(inv(Cube(m)))
Base.adjoint(m::AbstractMove) = inv(m)

Base.:^(m::AbstractMove, p::Integer) = Move(Cube(m)^p)

# Sequence of moves
Move(ms::AbstractVector{<:AbstractMove}) = prod(ms)
Cube(ms::AbstractVector{<:AbstractMove}) = Cube(prod(ms))

Base.:*(c::Cube, ms::AbstractVector{<:AbstractMove}) = prod(ms, init=c)
Base.:*(ms::AbstractVector{<:AbstractMove}, c::Cube) = prod(ms) * c
Base.:*(a::AbstractVector{<:AbstractMove}, b::AbstractVector{<:AbstractMove}) = vcat(a, b)
Base.:*(a::AbstractMove, b::AbstractVector{<:AbstractMove}) = vcat(a, b)
Base.:*(a::AbstractVector{<:AbstractMove}, b::AbstractMove) = vcat(a, b)

Base.inv(ms::AbstractVector{<:AbstractMove}) = reverse!(inv.(ms))
Base.adjoint(ms::AbstractVector{<:AbstractMove}) = inv(ms)

Base.:^(ms::AbstractVector{<:AbstractMove}, p::Integer) = repeat(ms, outer=p)

# Parse (implemented in literal-moves.jl)
Move(str::AbstractString) = parse(Move, str)

Base.parse(::Type{Vector{Move}}, str::AbstractString) = parse.(Move, split(str))

macro seq_str(str)
    return :(parse(Vector{Move}, $(esc(str))))
end
