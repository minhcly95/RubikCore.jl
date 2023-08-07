Base.rand(rng::AbstractRNG, ::Random.SamplerType{Move}) = rand(rng, BASIC_MOVES)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Cube}) = Cube(rand(rng, BASIC_MOVES, 30))
