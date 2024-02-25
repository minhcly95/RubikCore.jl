const N_CORNERS = 8
const SIDES_PER_CORNER = 3
const CORNER_DEGREE = N_CORNERS * SIDES_PER_CORNER

# We represent the state of the corners as a permutation
# of 24 sides (8 edges * 3 sides per edge).
# The sides are numbered as follows:
#
#   Top Layer        Bottom Layer
#       B                 B
#     8   6             21 17
#    ┌─────┐           ┌─────┐
#   9│7   4│5        20│19 16│18
# L  │  U  │  R     L  │  D  │  R 
#  11│10  1│3        24│22 13│14
#    └─────┘           └─────┘
#     12  2             23 15
#       F                 F      
#
# Note that every corner is represented by a consecutive triplet {3i-2,3i-1,3i}.
# The sides in each corner are always numbered in the counter-clockwise direction.
# As a convention, the permutation represents the mapping
# from the original slot to the current slot.

struct CornerState
    perm::SPerm{CORNER_DEGREE,UInt8}

    # A valid permutation is one that maps a corner to an corner.
    # In other words, it maps every triplet {3i-2,3i-1,3i} to a consecutive triplet.
    # We do not check parity here (which is done by Base.isvalid instead).
    @inline function CornerState(perm::AbstractPerm{CORNER_DEGREE})
        @boundscheck begin
            for i in 1:N_CORNERS
                j, k, l = 3i - 2, 3i - 1, 3i
                pj, pk, pl = @inbounds perm[j], perm[k], perm[l]
                m, n = min(pj, pk, pl), max(pj, pk, pl)
                (n - m == 2) || throw(ArgumentError("invalid permutation for CornerState: {$j,$k,$l} → {$pj,$pk,$pl}"))
            end
        end
        new(perm)
    end
end
Base.@propagate_inbounds CornerState(perm::AbstractPerm) = CornerState(convert(SPerm{CORNER_DEGREE,UInt8}, perm))

# Identity
@inline CornerState() = @inbounds CornerState(SPerm{CORNER_DEGREE,UInt8}())
Base.one(::Type{CornerState}) = CornerState()
Base.one(::CornerState) = CornerState()

# Wrapper of permutation
Base.@propagate_inbounds Base.getindex(c::CornerState, i::Integer) = c.perm[i]
Base.:*(c::CornerState, d::CornerState) = @inbounds CornerState(c.perm * d.perm)
Base.inv(c::CornerState) = @inbounds CornerState(inv(c.perm))

# Information for each corner: perm, ori, and mirrored
# Get the permutation of the corner pieces (not the sides)
Base.@propagate_inbounds corner_perm(c::CornerState, i::Integer) = fld1(c[3i], 3)

# If 3i → 3j, then the orientation is 0 (not twisted).
# If 3i → 3j-1, then it is 2 ≡ -1 (twisted CW).
# If 3i → 3j-2, then it parity is 1 ≡ -2 (twisted CCW).
Base.@propagate_inbounds corner_ori(c::CornerState, i::Integer) = c[3i] % 3

# Each corner can be mirrored (1,3,2) or unmirrored (1,2,3)
Base.@propagate_inbounds function is_corner_unmirrored(c::CornerState, i::Integer)
    j, k, l = 3i - 2, 3i - 1, 3i
    pj, pk, pl = c[j], c[k], c[l]
    # Test the evenness of the triplet
    return (pk - pj) * (pl - pj) * (pl - pk) > 0
end
Base.@propagate_inbounds is_corner_mirrored(c::CornerState, i::Integer) = !is_corner_unmirrored(c, i)

# Aggregated functions
corner_perm(c::CornerState) = @inbounds SPerm{N_CORNERS,UInt8}((corner_perm(c, i) for i in 1:N_CORNERS)...)
corner_ori(c::CornerState) = @inbounds tuple((corner_ori(c, i) for i in 1:N_CORNERS)...)
is_corner_unmirrored(c::CornerState) = @inbounds tuple((is_corner_unmirrored(c, i) for i in 1:N_CORNERS)...)
is_corner_mirrored(c::CornerState) = @inbounds tuple((is_corner_mirrored(c, i) for i in 1:N_CORNERS)...)

# The parity of the state is the sum of the orientation of all corners.
# A reachable state must have 0 parity since every turn is parity neutral.
function parity(c::CornerState)
    parity = @inbounds sum(c[3i] for i in 1:N_CORNERS)
    return parity % 3
end

# Valid state = unmirrored corners and 0-parity
Base.isvalid(c::CornerState) = @inbounds (parity(c) == 0) && all(is_corner_unmirrored(c, i) for i in 1:N_CORNERS)

# The face of each side
const CORNER_FACE = (
    Up, Front, Right,
    Up, Right, Back,
    Up, Back, Left,
    Up, Left, Front,
    Down, Right, Front,
    Down, Back, Right,
    Down, Left, Back,
    Down, Front, Left,
)

# Low-level manipulation
@inline function twist_corner(c::CornerState, i::Integer, twist::Integer)
    @boundscheck 1 <= i <= N_CORNERS || throw(ArgumentError("index out-of-range (must be in 1:$N_CORNERS)"))

    twist = mod(twist, 3)
    (twist == 0) && return c

    ref = Ref(c)
    ptr = Base.unsafe_convert(Ptr{UInt8}, pointer_from_objref(ref))
    GC.@preserve ref begin
        j = unsafe_load(ptr, 3i - 2)
        k = unsafe_load(ptr, 3i - 1)
        l = unsafe_load(ptr, 3i)
        if twist == 1
            unsafe_store!(ptr, k, 3i - 2)
            unsafe_store!(ptr, l, 3i - 1)
            unsafe_store!(ptr, j, 3i)
        else
            unsafe_store!(ptr, l, 3i - 2)
            unsafe_store!(ptr, j, 3i - 1)
            unsafe_store!(ptr, k, 3i)
        end
    end
    return ref[]
end

@inline function swap_corners(c::CornerState, i::Integer, j::Integer)
    @boundscheck (1 <= i <= N_CORNERS && 1 <= j <= N_CORNERS) || throw(ArgumentError("index out-of-range (must be in 1:$N_CORNERS)"))
    ref = Ref(c)
    ptr = Base.unsafe_convert(Ptr{UInt8}, pointer_from_objref(ref))
    GC.@preserve ref begin
        m = unsafe_load(ptr, 3i - 2)
        n = unsafe_load(ptr, 3i - 1)
        o = unsafe_load(ptr, 3i)
        p = unsafe_load(ptr, 3j - 2)
        q = unsafe_load(ptr, 3j - 1)
        r = unsafe_load(ptr, 3j)
        unsafe_store!(ptr, p, 3i - 2)
        unsafe_store!(ptr, q, 3i - 1)
        unsafe_store!(ptr, r, 3i)
        unsafe_store!(ptr, m, 3j - 2)
        unsafe_store!(ptr, n, 3j - 1)
        unsafe_store!(ptr, o, 3j)
    end
    return ref[]
end

