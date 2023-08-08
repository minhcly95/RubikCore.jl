const _SM_EDGES = (
    "UB", "BU", "UL", "LU", "UR", "RU", "UF", "FU",
    "LB", "BL", "RB", "BR", "LF", "FL", "RF", "FR",
    "DB", "BD", "DL", "LD", "DR", "RD", "DF", "FD")
const _SM_CORNERS = (
    "UBL", "URB", "ULF", "UFR", "DLB", "DBR", "DFL", "DRF",
    "LUB", "BUR", "FUL", "RUF", "BDL", "RDB", "LDF", "FDR",
    "BLU", "RBU", "LFU", "FRU", "LBD", "BRD", "FLD", "RFD",
    "ULB", "UBR", "UFL", "URF", "DBL", "DRB", "DLF", "DFR",
    "LBU", "BRU", "FLU", "RFU", "BLD", "RBD", "LFD", "FRD",
    "BUL", "RUB", "LUF", "FUR", "LDB", "BDR", "FDL", "RDF")

const _SM_SOLVED = "UF UR UB UL DF DR DB DL FR FL BR BL UFR URB UBL ULF DRF DFL DLB DBR"

const _SM_EDGE_ORDER = Tuple(_edge_perm(findfirst(==(str), _SM_EDGES) - 1) for str in split(_SM_SOLVED)[1:12])
const _SM_EDGE_FLIPPED = Tuple(_edge_ori(findfirst(==(str), _SM_EDGES) - 1) for str in split(_SM_SOLVED)[1:12])
const _SM_CORNER_ORDER = Tuple(_corner_perm(findfirst(==(str), _SM_CORNERS) - 1) for str in split(_SM_SOLVED)[13:end])

function singmaster(c::Cube)
    d = inv(c)
    estr = [_SM_EDGES[d.e[_SM_EDGE_ORDER[i] + 1] ⊻ _SM_EDGE_FLIPPED[i] + 1] for i in 1:12]
    cstr = [_SM_CORNERS[d.c[_SM_CORNER_ORDER[i] + 1] + 1] for i in 1:8]
    return join(vcat(estr, cstr), " ")
end

function parse_singmaster(str::AbstractString)
    cubies = split(str)
    length(cubies) == 20 || error("Singmaster's notation must have exactly 20 cubies")
    c = MVector{8, Int}(undef)
    e = MVector{12, Int}(undef)
    for i in 1:12
        v = findfirst(==(cubies[i]), _SM_EDGES)
        isnothing(v) && error("No such edge ($(cubies[i]))")
        e[_edge_perm(v - 1) + 1] = _edge_val(_SM_EDGE_ORDER[i], _edge_ori(v - 1) ⊻ _SM_EDGE_FLIPPED[i])
    end
    for i in 1:8
        v = findfirst(==(cubies[i+12]), _SM_CORNERS)
        isnothing(v) && error("No such corner ($(cubies[i+12]))")
        c[_corner_perm(v - 1) + 1] = _corner_ori_sub(_SM_CORNER_ORDER[i], v - 1)
    end
    # Verify the given cube is valid
    return Cube(Tuple(c), Tuple(e))
end
