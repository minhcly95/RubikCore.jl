macro define_int_struct(struct_name, int_type, max_val, inherit=nothing)
    trunc_val = typemax(getfield(Core, int_type))
    int_type = esc(int_type)
    max_val = esc(max_val)
    struct_str = "$struct_name"
    esc_struct = esc(struct_name)

    expr = quote
        struct $struct_name
            val::$int_type
            Base.@propagate_inbounds function $struct_name(val::Integer)
                @boundscheck (1 <= val <= $max_val) || throw(ArgumentError("invalid value for $($struct_str): $val. Must be within 1:$($max_val)."))
                return new(val & $trunc_val)
            end
        end

        Base.Int(s::$esc_struct) = Int(s.val)
        Base.copy(s::$esc_struct) = s
    end

    if !isnothing(inherit)
        struct_expr = expr.args[findfirst(arg -> arg isa Expr && arg.head == :struct, expr.args)]
        struct_expr.args[2] = :($struct_name <: $(esc(inherit)))
    end
    return expr
end
