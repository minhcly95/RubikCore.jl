abstract type IntStruct end

# Construct an enum-like struct that only accepts values in a certain range
macro int_struct(struct_blk)
    (struct_blk.head == :struct) || throw(ArgumentError("not a struct block"))

    # Extract the name and the parent type
    local struct_str, struct_name
    parent_type = IntStruct

    name_arg = struct_blk.args[2]
    if name_arg isa Symbol
        struct_str = string(name_arg)
        struct_name = esc(name_arg)
    elseif name_arg isa Expr && name_arg.head == :(<:)
        struct_str = string(name_arg.args[1])
        struct_name = esc(name_arg.args[1])
        parent_type = esc(name_arg.args[2])
    end

    # Extract the maximum value of the enum
    content = filter(e -> e isa Symbol || (e isa Expr && e.head == :(::)), struct_blk.args[3].args)
    max_val_expr = only(content)

    local max_val
    int_type = Int

    if max_val_expr isa Symbol
        max_val = esc(max_val_expr)
    else
        max_val = esc(max_val_expr.args[1])
        int_type = getfield(Core, max_val_expr.args[2])
    end

    # Truncate the value to skip boundchecking
    trunc_val = typemax(int_type)

    return quote
        # Definition
        struct $struct_name <: $parent_type
            val::$int_type
            @inline function $struct_name(val::Integer)
                @boundscheck (1 <= val <= $max_val) || throw(ArgumentError("invalid value for $($struct_str): $val. Must be within 1:$($max_val)."))
                return new(val & $trunc_val)
            end
        end

        # Conversion
        Base.Int(s::$struct_name) = Int(s.val)
        Base.convert(I::Type{<:Integer}, s::$struct_name) = convert(I, s.val)

        # Static information
        Base.copy(s::$struct_name) = s
        Base.typemin(::Type{$struct_name}) = convert($int_type, 1)
        Base.typemax(::Type{$struct_name}) = convert($int_type, $max_val)

        # Comparison
        Base.isless(a::$struct_name, b::$struct_name) = a.val < b.val
    end
end

# Return all instances of an int struct
Base.instances(S::Type{<:IntStruct}) = S.(typemin(S):typemax(S))

# Get index shorthand
Base.@propagate_inbounds Base.getindex(a::AbstractArray, s::IntStruct) = getindex(a, convert(Int, s))
Base.@propagate_inbounds Base.getindex(a::Tuple, s::IntStruct) = getindex(a, convert(Int, s))

