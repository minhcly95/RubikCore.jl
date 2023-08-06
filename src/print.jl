# Show cube
Base.show(io::IO, c::Cube) = print(io, "Cube($(singmaster(c)))")

Base.parse(::Type{Cube}, str::AbstractString) = parse_singmaster(str)

# Show move
Base.show(io::IO, m::Move) = _show_move(io, Val(m))

_show_move(io::IO, ::Val{I}) = print(io, "I")

_show_move(io::IO, ::Val{U}) = print(io, "U")
_show_move(io::IO, ::Val{F}) = print(io, "F")
_show_move(io::IO, ::Val{R}) = print(io, "R")
_show_move(io::IO, ::Val{D}) = print(io, "D")
_show_move(io::IO, ::Val{B}) = print(io, "B")
_show_move(io::IO, ::Val{L}) = print(io, "L")

_show_move(io::IO, ::Val{U2}) = print(io, "U2")
_show_move(io::IO, ::Val{F2}) = print(io, "F2")
_show_move(io::IO, ::Val{R2}) = print(io, "R2")
_show_move(io::IO, ::Val{D2}) = print(io, "D2")
_show_move(io::IO, ::Val{B2}) = print(io, "B2")
_show_move(io::IO, ::Val{L2}) = print(io, "L2")

_show_move(io::IO, ::Val{U3}) = print(io, "U'")
_show_move(io::IO, ::Val{F3}) = print(io, "F'")
_show_move(io::IO, ::Val{R3}) = print(io, "R'")
_show_move(io::IO, ::Val{D3}) = print(io, "D'")
_show_move(io::IO, ::Val{B3}) = print(io, "B'")
_show_move(io::IO, ::Val{L3}) = print(io, "L'")

_show_move(io::IO, ::Val{m}) where {m} = print(io, "Move($(singmaster(Cube(m))))")

Base.parse(::Type{Move}, str::AbstractString) = parse_move(str)
Base.parse(::Type{Vector{Move}}, str::AbstractString) = parse_sequence(str)

macro seq_str(str)
    return :(parse_sequence($(esc(str))))
end

# Singmaster's notation
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

singmaster(m::Move) = singmaster(Cube(m))

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
    return Cube(Tuple(c), Tuple(e))
end

const _WORD_DICT = Dict(
    "U" => U, "U1" => U, "U+" => U, "U2" => U2, "UU" => U2, "U'" => U3, "U3" => U3, "U-" => U3,
    "F" => F, "F1" => F, "F+" => F, "F2" => F2, "FF" => F2, "F'" => F3, "F3" => F3, "F-" => F3,
    "R" => R, "R1" => R, "R+" => R, "R2" => R2, "RR" => R2, "R'" => R3, "R3" => R3, "R-" => R3,
    "D" => D, "D1" => D, "D+" => D, "D2" => D2, "DD" => D2, "D'" => D3, "D3" => D3, "D-" => D3,
    "B" => B, "B1" => B, "B+" => B, "B2" => B2, "BB" => B2, "B'" => B3, "B3" => B3, "B-" => B3,
    "L" => L, "L1" => L, "L+" => L, "L2" => L2, "LL" => L2, "L'" => L3, "L3" => L3, "L-" => L3,
)

parse_move(str::AbstractString) = haskey(_WORD_DICT, str) ? _WORD_DICT[str] : error("No such move ($str)")

parse_sequence(str::AbstractString) = [parse_move(s) for s in split(str)]
