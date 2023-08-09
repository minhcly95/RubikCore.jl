# Define an order
Base.isless(a::Symm, b::Symm) = Int(a) < Int(b)
Base.isless(a::Edge, b::Edge) = Int(a) < Int(b)
Base.isless(a::Corner, b::Corner) = Int(a) < Int(b)

Base.isless(a::Cube, b::Cube) =
    a.center < b.center || a.center == b.center &&
    (a.edges < b.edges || a.edges == b.edges && a.corners < b.corners)

# Find the minimum cube across all symmetries (and inverse with all of its symmetries)
function canonicalize(cube::Cube, include_inv::Bool=false)
    cube = normalize(cube)
    if !include_inv
        return _canonicalize(cube, cube)
    else
        inv_cube = inv(cube)
        return _canonicalize(inv_cube, _canonicalize(cube, min(cube, inv_cube)))
    end
end

# Implementation
@inline function _canonicalize(cube::Cube, init::Cube)
    de = MVector{NEDGES, Edge}(init.edges)
    dc = MVector{NCORNERS, Corner}(init.corners)
    # Rotate and multiply from scratch to prune as early as possible
    # No need to rotate the center because it's unchanged
    for symm in ALL_SYMMS[2:end]
        inv_symm = symm'
        less, greater = false, false

        for i in 1:NEDGES
            e1 = rotate(_unsafe_edge(i, 1), inv_symm)
            e2 = ori_add(cube.edges[perm(e1)], ori(e1))
            e = rotate(e2, symm)
            if less || e < de[i]
                de[i] = e
                less = true
            elseif e > de[i]
                greater = true
                break
            end
        end
        greater && continue

        for i in 1:NCORNERS
            c1 = rotate(_unsafe_corner(i, 1), inv_symm)
            c2 = ori_add(cube.corners[perm(c1)], ori(c1))
            c = rotate(c2, symm)
            if less || c < dc[i]
                dc[i] = c
                less = true
            elseif c > dc[i]
                break
            end
        end
    end
    return @inbounds Cube(init.center, Tuple(de), Tuple(dc))
end
