struct Cube
    center::Symm
    edges::NTuple{NEDGES, Edge}
    corners::NTuple{NCORNERS, Corner}

    Base.@propagate_inbounds function Cube(center, edges, corners)
        @boundscheck begin
            eperm = Int.(perm.(edges))
            (sort!(collect(eperm)) == 1:NEDGES) || throw(ArgumentError("invalid edge permutation: $eperm"))
            cperm = Int.(perm.(corners))
            (sort!(collect(cperm)) == 1:NCORNERS) || throw(ArgumentError("invalid corner permutation: $cperm"))
        end
        new(center, edges, corners)
    end
end

Cube(c::Cube) = c
Base.copy(c::Cube) = c

# Identity cube
const _IDENTITY_CUBE = Cube(Symm(), Tuple(Edge(i, 1) for i in 1:NEDGES), Tuple(Corner(i, 1) for i in 1:NCORNERS))
Cube() = _IDENTITY_CUBE

Base.one(::Cube) = Cube()
Base.one(::Type{Cube}) = Cube()

# Mirrored
is_mirrored(c::Cube) = is_mirrored(c.center)

# Multiplication
function Base.:*(a::Cube, b::Cube)
    ds = a.center * b.center
    de = MVector{NEDGES, Edge}(undef)
    dc = MVector{NCORNERS, Corner}(undef)
    for i = 1:NEDGES
        ae = a.edges[i]
        @inbounds de[i] = ori_add(b.edges[perm(ae)], ori(ae))
    end
    for i = 1:NCORNERS
        ac = a.corners[i]
        @inbounds dc[i] = ori_add(b.corners[perm(ac)], ori(ac))
    end
    return @inbounds Cube(ds, Tuple(de), Tuple(dc))
end

# Inverse
function Base.inv(c::Cube)
    ds = c.center'
    de = MVector{NEDGES, Edge}(undef)
    dc = MVector{NCORNERS, Corner}(undef)
    for i = 1:NEDGES
        ce = c.edges[i]
        @inbounds de[perm(ce)] = _unsafe_edge(i, ori(ce))
    end
    for i = 1:NCORNERS
        cc = c.corners[i]
        @inbounds dc[perm(cc)] = ori_sub(_unsafe_corner(i, 1), ori(cc))
    end
    return @inbounds Cube(ds, Tuple(de), Tuple(dc))
end
Base.adjoint(c::Cube) = inv(c)

# Power
Base.:^(c::Cube, p::Integer) = p >= 0 ? Base.power_by_squaring(c, p) : Base.power_by_squaring(c', -p)

Base.literal_pow(::typeof(^), c::Cube, ::Val{-3}) = inv(c*c*c)
Base.literal_pow(::typeof(^), c::Cube, ::Val{-2}) = inv(c*c)
Base.literal_pow(::typeof(^), c::Cube, ::Val{-1}) = inv(c)
Base.literal_pow(::typeof(^), c::Cube, ::Val{0}) = Cube()
Base.literal_pow(::typeof(^), c::Cube, ::Val{1}) = c
Base.literal_pow(::typeof(^), c::Cube, ::Val{2}) = c*c
Base.literal_pow(::typeof(^), c::Cube, ::Val{3}) = c*c*c

# Print
Base.print(io::IO, c::Cube) = print(io, singmaster(c))
Base.show(io::IO, c::Cube) = print(io, "Cube(\"$c\")")

# Parse
Base.parse(::Type{Cube}, str::AbstractString) = parse_singmaster(str)
Cube(str::AbstractString) = parse(Cube, str)
