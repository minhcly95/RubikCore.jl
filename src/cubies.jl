const NSTATES = 24
const NEDGES = 12
const NCORNERS = 8

# Edge
struct Edge
    v::UInt8
    function Edge(v::Integer)
        (1 <= v <= NSTATES) || throw(ArgumentError("invalid value for Edge: $v"))
        return new(v)
    end
end

Base.Int(e::Edge) = Int(e.v)

const ALL_EDGES = Tuple(Edge(i) for i in 1:NSTATES)

# Permutation (1-12) and orientation (1-2)
Edge(perm::Integer, ori::Integer) = Edge((perm - 1) << 1 + ori)

const _EDGES = Tuple(Tuple(Edge(perm, ori) for ori in 1:2) for perm in 1:NEDGES)
const _EDGE_PERM = Tuple(fld1(UInt8(v), 0x2) for v in 1:NSTATES)
const _EDGE_ORI = Tuple(mod1(UInt8(v), 0x2) for v in 1:NSTATES)

perm(e::Edge) = @inbounds _EDGE_PERM[Int(e)]
ori(e::Edge) = @inbounds _EDGE_ORI[Int(e)] 

_unsafe_edge(perm::Integer, ori::Integer) = @inbounds _EDGES[perm][ori]

# Ori manipulation
const _EDGE_ORI_ADD = Tuple(Tuple(Edge(perm(e), mod1(ori(e) + (o - 1), 2)) for o in 1:2) for e in ALL_EDGES)

flip(e::Edge) = @inbounds _EDGE_ORI_ADD[Int(e)][2]
ori_add(e1::Edge, ori::Integer) = @inbounds _EDGE_ORI_ADD[Int(e1)][ori]

# Corner
struct Corner
    v::UInt8
    function Corner(v::Integer)
        (1 <= v <= NSTATES) || throw(ArgumentError("invalid value for Corner: $v"))
        return new(v)
    end
end

Base.Int(c::Corner) = Int(c.v)

const ALL_CORNERS = Tuple(Corner(i) for i in 1:NSTATES)

# Permutation (1-8) and orientation (1-3)
Corner(perm::Integer, ori::Integer) = Corner((ori - 1) << 3 + perm)

const _CORNERS = Tuple(Tuple(Corner(perm, ori) for ori in 1:3) for perm in 1:NCORNERS)
const _CORNER_PERM = Tuple(mod1(UInt8(v), 0x8) for v in 1:NSTATES)
const _CORNER_ORI = Tuple(fld1(UInt8(v), 0x8) for v in 1:NSTATES)
const _CORNER_NEG_ORI = Tuple(mod1(0x5 - o, 0x3) for o in _CORNER_ORI)

perm(c::Corner) = @inbounds _CORNER_PERM[Int(c)]
ori(c::Corner) = @inbounds _CORNER_ORI[Int(c)]
neg_ori(c::Corner) = @inbounds _CORNER_NEG_ORI[Int(c)]

_unsafe_corner(perm::Integer, ori::Integer) = @inbounds _CORNERS[perm][ori]

# Ori manipulation
const _CORNER_ORI_NEG = Tuple(Corner(perm(c), mod1(5 - ori(c), 3)) for c in ALL_CORNERS)
const _CORNER_ORI_ADD = Tuple(Tuple(Corner(perm(c), mod1(ori(c) + (o - 1), 3)) for o in 1:3) for c in ALL_CORNERS)
const _CORNER_ORI_SUB = Tuple(Tuple(Corner(perm(c), mod1(ori(c) - (o - 1), 3)) for o in 1:3) for c in ALL_CORNERS)

ori_neg(c::Corner) = @inbounds _CORNER_ORI_NEG[Int(c)]
ori_add(c::Corner, ori::Integer) = @inbounds _CORNER_ORI_ADD[Int(c)][ori]
ori_sub(c::Corner, ori::Integer) = @inbounds _CORNER_ORI_SUB[Int(c)][ori]
ori_inc(c::Corner) = ori_add(c, 2)
ori_dec(c::Corner) = ori_add(c, 3)

# Print
Base.print(io::IO, e::Edge) = print(io, "$(perm(e))$((' ', '~')[ori(e)])")
Base.show(io::IO, e::Edge) = print(io, "Edge($e)")

Base.print(io::IO, c::Corner) = print(io, "$(perm(c))$((' ', '+', '-')[ori(c)])")
Base.show(io::IO, c::Corner) = print(io, "Corner($c)")

# String representation
const _EDGE_STRS = (
    "UB", "BU", "UL", "LU", "UR", "RU", "UF", "FU",
    "LB", "BL", "RB", "BR", "LF", "FL", "RF", "FR",
    "DB", "BD", "DL", "LD", "DR", "RD", "DF", "FD")

const _CORNER_STRS = (
    "UBL", "URB", "ULF", "UFR", "DLB", "DBR", "DFL", "DRF",
    "LUB", "BUR", "FUL", "RUF", "BDL", "RDB", "LDF", "FDR",
    "BLU", "RBU", "LFU", "FRU", "LBD", "BRD", "FLD", "RFD",
    "ULB", "UBR", "UFL", "URF", "DBL", "DRB", "DLF", "DFR",
    "LBU", "BRU", "FLU", "RFU", "BLD", "RBD", "LFD", "FRD",
    "BUL", "RUB", "LUF", "FUR", "LDB", "BDR", "FDL", "RDF")
