Base.rand(rng::AbstractRNG, ::Random.SamplerType{Face}) = rand(rng, ALL_FACES)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Symm}) = rand(rng, UNMIRRORED_SYMMS)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Move}) = rand(rng, FACE_TURNS)

function Base.rand(rng::AbstractRNG, ::Random.SamplerType{Cube})
    e = MVector{NEDGES, Edge}(Cube().edges)
    c = MVector{NCORNERS, Corner}(Cube().corners)

    # Shuffle to randomize permutation
    parity = 0
    for i in 1:NEDGES
        j = rand(rng, i:NEDGES)
        if i != j
            e[i], e[j] = e[j], e[i]
            parity += 1
        end
    end
    for i in 1:NCORNERS
        j = rand(rng, i:NCORNERS)
        if i != j
            c[i], c[j] = c[j], c[i]
            parity += 1
        end
    end
    if isodd(parity)
        c[1], c[2] = c[2], c[1]
    end

    # Assign random orientation
    last_ori = 1
    for i in 1:(NEDGES-1)
        o = rand(rng, 1:2)
        e[i] = ori_add(e[i], o)
        last_ori += o - 1
    end
    e[end] = ori_add(e[end], mod1(last_ori, 2))

    last_ori = 1
    for i in 1:(NCORNERS-1)
        o = rand(rng, 1:3)
        c[i] = ori_add(c[i], o)
        last_ori -= o - 1
    end
    c[end] = ori_add(c[end], mod1(last_ori, 3))

    return Cube(rand(rng, Symm), Tuple(e), Tuple(c))
end
