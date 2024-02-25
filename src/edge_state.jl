const N_EDGES = 12
const SIDES_PER_EDGE = 2
const EDGE_DEGREE = N_EDGES * SIDES_PER_EDGE

# We represent the state of the edges as a permutation
# of 24 sides (12 edges * 2 sides per edge).
# The sides are numbered as follows:
#
#   Top Layer       Middle Layer       Bottom Layer
#       B                 B                 B
#       6              13   11              22
#    ┌─────┐         14┌─────┐12         ┌─────┐
#    │  5  │           │     │           │  21 │
# L 8│7 U 3│4 R     L  │     │  R    L 24│23 19│20 R
#    │  1  │           │     │           │  17 │
#    └─────┘         16└─────┘10         └─────┘
#       2              15    9              18
#       F                 F                 F      
#
# Note that every edge is represented by a consecutive pair {2i-1,2i}.
# As a convention, the permutation represents the mapping
# from the original slot to the current slot.

struct EdgeState
    perm::SPerm{EDGE_DEGREE,UInt8}

    # A valid permutation is one that maps an edge to an edge.
    # In other words, it maps every pair {2i-1,2i} to a consecutive pair.
    # We do not check parity here (which is done by Base.isvalid instead).
    @inline function EdgeState(perm::AbstractPerm{EDGE_DEGREE})
        @boundscheck begin
            for i in 1:N_EDGES
                j, k = 2i - 1, 2i
                pj, pk = @inbounds perm[j], perm[k]
                (abs(pj - pk) == 1) || throw(ArgumentError("invalid permutation for EdgeState: {$j,$k} → {$pj,$pk}"))
            end
        end
        new(perm)
    end
end
Base.@propagate_inbounds EdgeState(perm::AbstractPerm) = EdgeState(convert(SPerm{EDGE_DEGREE,UInt8}, perm))

# Identity
@inline EdgeState() = @inbounds EdgeState(SPerm{EDGE_DEGREE,UInt8}())
Base.one(::Type{EdgeState}) = EdgeState()
Base.one(::EdgeState) = EdgeState()

# Wrapper of permutation
Base.@propagate_inbounds Base.getindex(e::EdgeState, i::Integer) = e.perm[i]
Base.:*(e::EdgeState, f::EdgeState) = @inbounds EdgeState(e.perm * f.perm)
Base.inv(e::EdgeState) = @inbounds EdgeState(inv(e.perm))

# Information for each edge: perm, ori
# Get the permutation of the edge pieces (not the sides)
Base.@propagate_inbounds edge_perm(e::EdgeState, i::Integer) = fld1(e[2i], 2)

# If 2i → 2j, then the edge is even (not flipped).
# If 2i → 2j-1, then it's odd (flipped).
Base.@propagate_inbounds edge_ori(e::EdgeState, i::Integer) = Bool(e[2i] & 1)

# Aggregated functions
edge_perm(e::EdgeState) = @inbounds SPerm{N_EDGES,UInt8}((edge_perm(e, i) for i in 1:N_EDGES)...)
edge_ori(e::EdgeState) = @inbounds tuple((edge_ori(e, i) for i in 1:N_EDGES)...)

# The parity is the sum of the evenness of all edges.
# A reachable state must have 0 parity (even) since every turn is parity neutral.
function parity(e::EdgeState)
    # An even edge maps even to even (2i → 2j)
    parity = @inbounds sum(e[2i] for i in 1:N_EDGES)
    return parity % 2
end

Base.iseven(e::EdgeState) = parity(e) == 0
Base.isodd(e::EdgeState) = parity(e) == 1
Base.isvalid(e::EdgeState) = iseven(e)

# The face of each side
const EDGE_FACE = (
    Up, Front, Up, Right, Up, Back, Up, Left,
    Front, Right, Back, Right, Back, Left, Front, Left,
    Down, Front, Down, Right, Down, Back, Down, Left
)

