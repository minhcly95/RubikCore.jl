struct Cube
    center::Symm
    edges::EdgeState
    corners::CornerState
end

Base.copy(c::Cube) = c

# Identity cube
const IDENTITY_CUBE = Cube(Symm(), EdgeState(), CornerState())
Cube() = IDENTITY_CUBE
Base.one(::Cube) = Cube()
Base.one(::Type{Cube}) = Cube()

# Evenness of a Cube is evenness of its center
Base.iseven(c::Cube) = iseven(c.center)

# Information of each edge and corner
edge_perm(c::Cube) = edge_perm(c.edges)
edge_ori(c::Cube) = edge_ori(c.edges)
corner_perm(c::Cube) = corner_perm(c.corners)
corner_ori(c::Cube) = corner_ori(c.corners)

# Multiplication and inversion
Base.:*(a::Cube, b::Cube) = Cube(a.center * b.center, a.edges * b.edges, a.corners * b.corners)
Base.inv(c::Cube) = Cube(inv(c.center), inv(c.edges), inv(c.corners))
Base.adjoint(c::Cube) = inv(c)

# A valid cube consists of an even center, a valid edge state, a valid corner state,
# and matching permutation parity of edges and corners.
Base.isvalid(c::Cube) =
    iseven(c.center) && isvalid(c.edges) && isvalid(c.corners) &&
    !(isodd(edge_perm(c.edges)) ⊻ isodd(corner_perm(c.corners)))

# Power
Base.:^(c::Cube, p::Integer) = p >= 0 ? Base.power_by_squaring(c, p) : Base.power_by_squaring(c', -p)

Base.literal_pow(::typeof(^), c::Cube, ::Val{-3}) = inv(c * c * c)
Base.literal_pow(::typeof(^), c::Cube, ::Val{-2}) = inv(c * c)
Base.literal_pow(::typeof(^), c::Cube, ::Val{-1}) = inv(c)
Base.literal_pow(::typeof(^), c::Cube, ::Val{0}) = Cube()
Base.literal_pow(::typeof(^), c::Cube, ::Val{1}) = c
Base.literal_pow(::typeof(^), c::Cube, ::Val{2}) = c * c
Base.literal_pow(::typeof(^), c::Cube, ::Val{3}) = c * c * c

# Print
Base.print(io::IO, c::Cube) = print(io, singmaster(c))
Base.show(io::IO, c::Cube) = print(io, "Cube(\"$c\")")

# Parse
Base.parse(::Type{Cube}, str::AbstractString) = parse_singmaster(str)
Cube(str::AbstractString) = parse(Cube, str)

