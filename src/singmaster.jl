const SM_SOLVED = "UF UR UB UL DF DR DB DL FR FL BR BL UFR URB UBL ULF DRF DFL DLB DBR"

# SM string position → slot mapping
const SM_EDGE_SLOTS = SPerm{EDGE_DEGREE,UInt8}(1, 2, 3, 4, 5, 6, 7, 8, 17, 18, 19, 20, 21, 22, 23, 24, 9, 10, 16, 15, 12, 11, 13, 14)
const SM_CORNER_SLOTS = SPerm{CORNER_DEGREE,UInt8}(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 22, 23, 24, 19, 20, 21, 16, 17, 18)

# Token → side mapping
function _make_singmaster_token_dicts()
    edges = []
    for i in 1:N_EDGES
        j, k = 2i - 1, 2i
        fj, fk = Char(EDGE_FACE[j]), Char(EDGE_FACE[k])
        push!(edges, join((fj, fk)) => (j, k))
        push!(edges, join((fk, fj)) => (k, j))
    end

    corners = []
    for i in 1:N_CORNERS
        j, k, l = 3i - 2, 3i - 1, 3i
        fj, fk, fl = Char(CORNER_FACE[j]), Char(CORNER_FACE[k]), Char(CORNER_FACE[l])
        push!(corners, join((fj, fk, fl)) => (j, k, l))
        push!(corners, join((fj, fl, fk)) => (j, l, k))
        push!(corners, join((fk, fl, fj)) => (k, l, j))
        push!(corners, join((fk, fj, fl)) => (k, j, l))
        push!(corners, join((fl, fj, fk)) => (l, j, k))
        push!(corners, join((fl, fk, fj)) => (l, k, j))
    end

    return Dict(edges), Dict(corners)
end
const SM_TOKEN_TO_EDGE, SM_TOKEN_TO_CORNER = _make_singmaster_token_dicts()

# Singmaster string
function singmaster(c::Cube)
    # By convention, the input c is in the side → slot format
    # For printing, we use the slot → side format
    d = inv(c)

    sstr = string(d.center)

    # SM position → slot → side
    echars = Char.(EDGE_FACE[SM_EDGE_SLOTS*d.edges.perm])
    cchars = Char.(CORNER_FACE[SM_CORNER_SLOTS*d.corners.perm])

    etokens = join.(Iterators.partition(echars, 2))
    ctokens = join.(Iterators.partition(cchars, 3))

    return "[$sstr] " * join(vcat(etokens, ctokens), " ")
end

# Parse Singmaster string
function parse_singmaster(str::AbstractString)
    cubies = split(str)

    # Center
    s = Symm()
    if first(cubies[1]) == '['
        s = Symm(popfirst!(cubies)[2:end-1])'
    end

    length(cubies) == N_EDGES + N_CORNERS || error("Singmaster's notation must have exactly 20 tokens")

    # SM position → side
    edge_sides = SPerm(Tuple(Iterators.flatten(SM_TOKEN_TO_EDGE[token] for token in cubies[1:N_EDGES])))
    corner_sides = SPerm(Tuple(Iterators.flatten(SM_TOKEN_TO_CORNER[token] for token in cubies[N_EDGES+1:N_EDGES+N_CORNERS])))

    # Side → SM position → slot
    estate = EdgeState(inv(edge_sides) * SM_EDGE_SLOTS)
    cstate = CornerState(inv(corner_sides) * SM_CORNER_SLOTS)

    return Cube(s, estate, cstate)
end
