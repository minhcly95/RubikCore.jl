const N_STATES = 24
const N_EDGES = 12
const N_CORNERS = 8

# Edge
@define_int_struct(Edge, UInt8, N_STATES)

const ALL_EDGES = Tuple(Edge(i) for i in 1:N_STATES)

# Permutation (1-12) and orientation (1-2)
Base.@propagate_inbounds function Edge(perm::Integer, ori::Integer)
    @boundscheck begin
        (1 <= perm <= N_EDGES) || throw(ArgumentError("invalid value for perm: $perm. Must be within 1:$N_EDGES."))
        (1 <= ori <= 2) || throw(ArgumentError("invalid value for ori: $ori. Must be within 1:2."))
    end
    return @inbounds Edge((perm - 1) << 1 + ori)
end

const _EDGES = Tuple(Tuple(Edge(perm, ori) for ori in 1:2) for perm in 1:N_EDGES)
const _EDGE_PERM = Tuple(fld1(UInt8(v), 0x2) for v in 1:N_STATES)
const _EDGE_ORI = Tuple(mod1(UInt8(v), 0x2) for v in 1:N_STATES)

perm(e::Edge) = @inbounds _EDGE_PERM[Int(e)]
ori(e::Edge) = @inbounds _EDGE_ORI[Int(e)]

# Ori manipulation
const _EDGE_ORI_ADD = Tuple(Tuple(Edge(perm(e), mod1(ori(e) + (o - 1), 2)) for o in 1:2) for e in ALL_EDGES)

flip(e::Edge) = @inbounds _EDGE_ORI_ADD[Int(e)][2]
ori_add(e1::Edge, ori::Integer) = @inbounds _EDGE_ORI_ADD[Int(e1)][ori]

# Corner
@define_int_struct(Corner, UInt8, N_STATES)

const ALL_CORNERS = Tuple(Corner(i) for i in 1:N_STATES)

# Permutation (1-8) and orientation (1-3)
Base.@propagate_inbounds function Corner(perm::Integer, ori::Integer)
    @boundscheck begin
        (1 <= perm <= N_CORNERS) || throw(ArgumentError("invalid value for perm: $perm. Must be within 1:$N_CORNERS."))
        (1 <= ori <= 3) || throw(ArgumentError("invalid value for ori: $ori. Must be within 1:3."))
    end
    return @inbounds Corner((ori - 1) << 3 + perm)
end

const _CORNERS = Tuple(Tuple(Corner(perm, ori) for ori in 1:3) for perm in 1:N_CORNERS)
const _CORNER_PERM = Tuple(mod1(UInt8(v), 0x8) for v in 1:N_STATES)
const _CORNER_ORI = Tuple(fld1(UInt8(v), 0x8) for v in 1:N_STATES)
const _CORNER_NEG_ORI = Tuple(mod1(0x5 - o, 0x3) for o in _CORNER_ORI)

perm(c::Corner) = @inbounds _CORNER_PERM[Int(c)]
ori(c::Corner) = @inbounds _CORNER_ORI[Int(c)]
neg_ori(c::Corner) = @inbounds _CORNER_NEG_ORI[Int(c)]

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

slot_string(e::Edge) = _EDGE_STRS[Int(e)]
slot_string(c::Corner, mirrored=false) = _CORNER_STRS[Int(c) + (mirrored ? 24 : 0)]
