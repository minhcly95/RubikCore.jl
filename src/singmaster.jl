const _SM_SOLVED = "UF UR UB UL DF DR DB DL FR FL BR BL UFR URB UBL ULF DRF DFL DLB DBR"

const _SM_EDGE_ORDER = Tuple(perm(ALL_EDGES[findfirst(==(str), _EDGE_STRS)]) for str in split(_SM_SOLVED)[1:12])
const _SM_EDGE_FLIPPED = Tuple(ori(ALL_EDGES[findfirst(==(str), _EDGE_STRS)]) for str in split(_SM_SOLVED)[1:12])
const _SM_CORNER_ORDER = Tuple(perm(ALL_CORNERS[findfirst(==(str), _CORNER_STRS)]) for str in split(_SM_SOLVED)[13:end])

function singmaster(c::Cube)
    d = inv(c)
    sstr = string(d.center)
    estr = [_EDGE_STRS[Int(ori_add(d.edges[_SM_EDGE_ORDER[i]], _SM_EDGE_FLIPPED[i]))] for i in 1:N_EDGES]
    if !is_mirrored(c)
        cstr = [_CORNER_STRS[Int(d.corners[_SM_CORNER_ORDER[i]])] for i in 1:N_CORNERS]
    else
        cstr = [_CORNER_STRS[Int(ori_neg(d.corners[_SM_CORNER_ORDER[i]])) + N_STATES] for i in 1:N_CORNERS]
    end
    return "[$sstr] " * join(vcat(estr, cstr), " ")
end

function parse_singmaster(str::AbstractString)
    cubies = split(str)

    # Center
    s = Symm()
    mirrored = false
    if first(cubies[1]) == '['
        s = Symm(popfirst!(cubies)[2:end-1])'
        mirrored = is_mirrored(s)
    end

    length(cubies) == 20 || error("Singmaster's notation must have exactly 20 cubies")

    # Edge
    e = MVector{N_EDGES, Edge}(undef)
    for i in 1:N_EDGES
        v = findfirst(==(cubies[i]), _EDGE_STRS)
        isnothing(v) && error("invalid string for Edge: $(cubies[i])")
        e[perm(ALL_EDGES[v])] = Edge(_SM_EDGE_ORDER[i], ori(ori_add(ALL_EDGES[v], _SM_EDGE_FLIPPED[i])))
    end

    # Corner
    c = MVector{N_CORNERS, Corner}(undef)
    for i in 1:N_CORNERS
        cstr = cubies[i+12]
        v = findfirst(==(cstr), _CORNER_STRS)
        isnothing(v) && error("invalid string for Corner: $cstr")
        if !mirrored
            (v <= N_STATES) || throw(ArgumentError("corner $cstr is inconsistent with center $(s')"))
            c[perm(ALL_CORNERS[v])] = Corner(_SM_CORNER_ORDER[i], neg_ori(ALL_CORNERS[v]))
        else
            v -= N_STATES
            (v >= 1) || throw(ArgumentError("corner $cstr is inconsistent with center $(s')"))
            c[perm(ALL_CORNERS[v])] = Corner(_SM_CORNER_ORDER[i], ori(ALL_CORNERS[v]))
        end
    end

    return Cube(s, Tuple(e), Tuple(c))
end
