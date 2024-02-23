make_tuple(a::AbstractMatrix) = Tuple(Tuple.(eachrow(a)))

