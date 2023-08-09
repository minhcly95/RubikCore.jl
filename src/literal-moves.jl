# Utility macro
macro _define_move_powers(range, moves...)
    expr = Expr(:block)
    for move in moves
        emove = esc(move)
        for i in eval(range)
            name = esc(Symbol("$move$i"))
            push!(expr.args, :(const $name = $emove ^ $i))
        end
    end
    return expr
end

macro _group_move_powers(group_name, range, moves...)
    group_name = esc(group_name)
    tuple = Expr(:tuple)
    for move in moves
        for i in eval(range)
            name = esc(Symbol("$move$i"))
            push!(tuple.args, name)
        end
    end
    return :(const $group_name = $tuple)
end

macro _export_move_powers(range, moves...)
    expr = Expr(:export)
    for move in moves
        push!(expr.args, esc(move))
        for i in eval(range)
            name = esc(Symbol("$move$i"))
            push!(expr.args, name)
        end
    end
    return expr
end

macro _define_literal_dict(moves...)
    function make_entry(move, var_suffix, str_suffix)
        key = esc(Symbol("$move$var_suffix"))
        val = "$move$str_suffix"
        return :($key => $val)
    end

    literals = Expr[]
    for move in moves
        push!(literals, make_entry(move, "1", ""))
        push!(literals, make_entry(move, "2", "2"))
        push!(literals, make_entry(move, "3", "'"))
    end
    return Expr(:call, :Dict, literals...)
end

macro _define_literal_revdict(moves...)
    function make_entries(move, var_suffix, str_suffices...)
        entries = Expr[]
        for str_suffix in str_suffices
            key = "$move$str_suffix"
            val = esc(Symbol("$move$var_suffix"))
            push!(entries, :($key => $val))
        end
        return entries
    end

    literals = Expr[]
    for move in moves
        append!(literals, make_entries(move, "1", "", "1", "+"))
        append!(literals, make_entries(move, "2", "2", move))
        append!(literals, make_entries(move, "3", "'", "3", "-"))
    end
    return Expr(:call, :Dict, literals...)
end

# Face turns
function _make_basic_face_turns()
    EDGE_TWIST_PERM = ((1, 3, 4, 2), (4, 8, 12, 7), (3, 6, 11, 8), (10, 12, 11, 9), (1, 5, 9, 6), (2, 7, 10, 5))
    CORNER_TWIST_PERM = ((1, 2, 4, 3), (3, 4, 8, 7), (4, 2, 6, 8), (5, 7, 8, 6), (2, 1, 5, 6), (1, 3, 7, 5))
    EDGE_CHANGE = (0, 0, 1, 0, 0, 1)
    CORNER_CHANGE = ((0, 0, 0, 0), (1, 2, 1, 2), (1, 2, 1, 2), (0, 0, 0, 0), (1, 2, 1, 2), (1, 2, 1, 2))

    edge_trans = [e for _ in ALL_FACES, e in ALL_EDGES]
    corner_trans = [c for _ in ALL_FACES, c in ALL_CORNERS]

    for f in 1:NFACES
        for i in 1:4
            ii = mod1(i + 1, 4)
            for o in 1:2
                oo = mod1(o + EDGE_CHANGE[f], 2)
                edge_trans[f, Int(Edge(EDGE_TWIST_PERM[f][i], o))] = Edge(EDGE_TWIST_PERM[f][ii], oo)
            end
            for o in 1:3
                oo = mod1(o + CORNER_CHANGE[f][i], 3)
                corner_trans[f, Int(Corner(CORNER_TWIST_PERM[f][i], o))] = Corner(CORNER_TWIST_PERM[f][ii], oo)
            end
        end
    end

    return Tuple(
        Move(Cube(Symm(),
            Tuple(edge_trans[f, Int(Edge(i, 1))] for i in 1:NEDGES),
            Tuple(corner_trans[f, Int(Corner(i, 1))] for i in 1:NCORNERS)))
        for f in 1:NFACES)
end

const U, F, R, D, B, L = _make_basic_face_turns()
@_define_move_powers(1:3, U, F, R, D, B, L)
@_group_move_powers(FACE_TURNS, 1:3, U, F, R, D, B, L)

# Face to move
function Move(f::Face, t::Integer = 1)
    t = mod(t, 4)
    return t == 0 ? I : FACE_TURNS[(Int(f)-1) * 3 + t]
end

# Whole cube rotations
const x, y, z = Move(rotate(Cube(), symm"BUR")), Move(rotate(Cube(), symm"ULF")), Move(rotate(Cube(), symm"RFD"))
@_define_move_powers(1:3, x, y, z)
@_group_move_powers(CUBE_ROTATIONS, 1:3, x, y, z)

# Slice turn
const M, E, S = R * L' * x', U * D' * y', F' * B * z
@_define_move_powers(1:3, M, E, S)
@_group_move_powers(SLICE_TURNS, 1:3, M, E, S)

# Wide turns
const u, f, r, d, b, l = D * y, B * z, L * x, U * y', F * z', R * x'
@_define_move_powers(1:3, u, f, r, d, b, l)
@_group_move_powers(WIDE_TURNS, 1:3, u, f, r, d, b, l)

# Print
const _LITERAL_MOVE_TO_STR = @_define_literal_dict(U, F, R, D, B, L, u, f, r, d, b, l, x, y, z, M, E, S)
const _LITERAL_MOVE_FROM_STR = @_define_literal_revdict(U, F, R, D, B, L, u, f, r, d, b, l, x, y, z, M, E, S)

function Base.show(io::IO, m::Move)
    if m == I
        print(io, "I")
    elseif haskey(_LITERAL_MOVE_TO_STR, m)
        print(io, _LITERAL_MOVE_TO_STR[m])
    else
        print(io, "Move(")
        show(io, m.cube)
        print(io, ")")
    end
end

# Parse
function Base.parse(::Type{Move}, str::AbstractString)
    if str == "I"
        return I
    elseif haskey(_LITERAL_MOVE_FROM_STR, str)
        return _LITERAL_MOVE_FROM_STR[str]
    else
        throw(ArgumentError("unknown move: $str"))
    end
end

Move(str::AbstractString) = parse(Move, str)

# Parse sequence
Base.parse(::Type{Vector{Move}}, str::AbstractString) = parse.(Move, split(str))

macro seq_str(str)
    return :(parse(Vector{Move}, $(esc(str))))
end
