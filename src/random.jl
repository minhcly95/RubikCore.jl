Base.rand(rng::AbstractRNG, ::Random.SamplerType{Face}) = rand(rng, ALL_FACES)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Move}) = rand(rng, BASIC_MOVES)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Cube}) = Cube(rand(rng, BASIC_MOVES, 30))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Symm}) = rand(rng, UNMIRRORED_SYMMS)
