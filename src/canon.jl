# Define an order
function Base.isless(a::EdgeState, b::EdgeState)
    aa, bb = Ref(a), Ref(b)
    GC.@preserve aa bb return Base.memcmp(pointer_from_objref(aa), pointer_from_objref(bb), sizeof(EdgeState)) < 0
end

function Base.isless(a::CornerState, b::CornerState)
    aa, bb = Ref(a), Ref(b)
    GC.@preserve aa bb return Base.memcmp(pointer_from_objref(aa), pointer_from_objref(bb), sizeof(CornerState)) < 0
end

function Base.isless(a::Cube, b::Cube)
    aa, bb = Ref(a), Ref(b)
    GC.@preserve aa bb return Base.memcmp(pointer_from_objref(aa), pointer_from_objref(bb), sizeof(Cube)) < 0
end

# Find the minimum cube across all conjugates s' * c * s for s in ALL_SYMMS
# (and inverse with all of its conjugates)
function canonicalize(cube::Cube; include_inv::Bool=false)
    cube = normalize(cube)
    if !include_inv
        return _canonicalize(cube, cube)
    else
        inv_cube = inv(cube)
        return _canonicalize(inv_cube, _canonicalize(cube, min(cube, inv_cube)))
    end
end

# Implementation
function _canonicalize(cube::Cube, init::Cube)
    edges = init.edges
    corners = init.corners

    # No need to rotate the center because it's unchanged
    for symm in ALL_SYMMS[2:end]
        sedges = symm' * cube.edges * symm
        if sedges < edges
            edges = sedges
            corners = symm' * cube.corners * symm
        elseif sedges == edges
            scorners = symm' * cube.corners * symm
            if scorners < corners
                corners = scorners
            end
        end
    end

    return Cube(init.center, edges, corners)
end
