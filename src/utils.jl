# Extract info from the iterator
function _extract_itr(itr)
    if itr.head != :(=) 
        error("Invalid iterator ($itr). Use the format \"i = 1:10\".")
    end
    var_sym = itr.args[1]
    range = eval(itr.args[2])
    return var_sym, range
end

# Recursive function to replace var with val
function _replace_var!(expr::Expr, var, val)
    for i in eachindex(expr.args)
        if expr.args[i] == var
            expr.args[i] = val
        elseif expr.args[i] isa Expr
            _replace_var!(expr.args[i], var, val)
        end
    end
end

# Repeat a statement while iterating of a variable
macro _for(itr, expr)
    var_sym, range = _extract_itr(itr)
    block = Expr(:block)
    for i in range
        i_expr = copy(expr)
        _replace_var!(i_expr, var_sym, i)
        push!(block.args, esc(i_expr))
    end

    return block
end

# Make a tuple from iteration of a variable
# Example: @_tuple_for(i = 1:12, a[i + 1])
macro _tuple_for(itr, expr)
    var_sym, range = _extract_itr(itr)
    t_expr = Expr(:tuple)
    for i in range
        i_expr = copy(expr)
        _replace_var!(i_expr, var_sym, i)
        push!(t_expr.args, esc(i_expr))
    end

    return t_expr
end
