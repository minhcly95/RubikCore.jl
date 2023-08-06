Base.rand(rng::AbstractRNG, ::Random.SamplerType{Move}) = rand(rng, ALL_MOVES)
