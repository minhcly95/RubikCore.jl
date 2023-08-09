Base.rand(rng::AbstractRNG, ::Random.SamplerType{Face}) = rand(rng, ALL_FACES)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Symm}) = rand(rng, UNMIRRORED_SYMMS)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Cube}) = rotate(Cube(rand(rng, Move, 30)), rand(rng, Symm))

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Move}) = rand(rng, FACE_TURNS)
