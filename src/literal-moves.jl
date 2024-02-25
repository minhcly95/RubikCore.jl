# Utility macro
macro _define_move_powers(range, moves...)
    expr = Expr(:block)
    for move in moves
        emove = esc(move)
        for i in eval(range)
            name = esc(Symbol("$move$i"))
            push!(expr.args, :(const $name = $emove^$i))
        end
    end
    return expr
end

macro _tuple_move_powers(range, moves...)
    tuple = Expr(:tuple)
    for move in moves
        for i in eval(range)
            name = esc(Symbol("$move$i"))
            push!(tuple.args, name)
        end
    end
    return tuple
end

macro _reexport_move_powers(range, moves...)
    symbols = []
    for move in moves
        push!(symbols, move)
        for i in eval(range)
            name = Symbol("$move$i")
            push!(symbols, name)
        end
    end

    import_expr = Expr(:import, Expr(:(:), Expr(:., :., :., :RubikCore), [Expr(:., s) for s in symbols]...))
    export_expr = Expr(:export, symbols...)
    return :($import_expr; $export_expr)
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
    EDGE_TURN_PERM = (
        perm"(1 7 5 3)(2 8 6 4)",
        perm"(1 10 17 16)(2 9 18 15)",
        perm"(3 11 19 9)(4 12 20 10)",
        perm"(17 19 21 23)(18 20 22 24)",
        perm"(5 14 21 12)(6 13 22 11)",
        perm"(7 15 23 13)(8 16 24 14)",
    )
    CORNER_TURN_PERM = (
        perm"(1 10 7 4)(2 11 8 5)(3 12 9 6)",
        perm"(1 14 22 11)(2 15 23 12)(3 13 24 10)",
        perm"(1 6 16 15)(2 4 17 13)(3 5 18 14)",
        perm"(13 16 19 22)(14 17 20 23)(15 18 21 24)",
        perm"(4 9 19 18)(5 7 20 16)(6 8 21 17)",
        perm"(7 12 22 21)(8 10 23 19)(9 11 24 20)",
    )

    return Tuple(
        Move(Cube(Symm(), EdgeState(EDGE_TURN_PERM[f]), CornerState(CORNER_TURN_PERM[f])))
        for f in ALL_FACES)
end

const U, F, R, D, B, L = _make_basic_face_turns()
@_define_move_powers(1:3, U, F, R, D, B, L)
const FACE_TURNS = @_tuple_move_powers(1:3, U, F, R, D, B, L)

# Whole cube rotations
const x, y, z = Move(Cube() * symm"BUR"), Move(Cube() * symm"ULF"), Move(Cube() * symm"RFD")
@_define_move_powers(1:3, x, y, z)
const CUBE_ROTATIONS = @_tuple_move_powers(1:3, x, y, z)

# Slice turn
const M, E, S = R * L' * x', U * D' * y', F' * B * z
@_define_move_powers(1:3, M, E, S)
const SLICE_TURNS = @_tuple_move_powers(1:3, M, E, S)

# Wide turns
const u, f, r, d, b, l = D * y, B * z, L * x, U * y', F * z', R * x'
@_define_move_powers(1:3, u, f, r, d, b, l)
const WIDE_TURNS = @_tuple_move_powers(1:3, u, f, r, d, b, l)

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
