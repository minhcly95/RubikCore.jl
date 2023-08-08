# Multiplication
function Base.:*(a::Cube, b::Cube)
    dc = MVector{8, Int}(undef)
    de = MVector{12, Int}(undef)
    @_for(i = 1:8, @inbounds dc[i] = _corner_ori_add(b.c[_corner_perm(a.c[i]) + 1], a.c[i]))
    @_for(i = 1:12, @inbounds de[i] = _edge_ori_add(b.e[_edge_perm(a.e[i]) + 1], a.e[i]))
    return @inbounds Cube(Tuple(dc), Tuple(de))
end

# Inverse
function Base.inv(c::Cube)
    dc = MVector{8, Int}(undef)
    de = MVector{12, Int}(undef)
    @_for(i = 1:8, @inbounds dc[_corner_perm(c.c[i]) + 1] = _corner_ori_sub(i-1, c.c[i]))
    @_for(i = 1:12, @inbounds de[_edge_perm(c.e[i]) + 1] = _edge_val(i-1, _edge_ori(c.e[i])))
    return @inbounds Cube(Tuple(dc), Tuple(de))
end

@inline Base.adjoint(c::Cube) = inv(c)

# Power
@inline Base.:^(c::Cube, p::Integer) = Base.power_by_squaring(c, p)
@_insert_literal_pow(Cube)
