Base.rand(rng::AbstractRNG, ::Random.SamplerType{Face}) = rand(rng, ALL_FACES)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Symm}) = rand(rng, EVEN_SYMMS)

function Base.rand(rng::AbstractRNG, ::Random.SamplerType{EdgeState})
    # Shuffle the edges
    edge_perm = rand(rng, SPerm{N_EDGES})

    # Map the sides to the correct position
    perm = collect(Iterators.flatten((2j - 1, 2j) for j in images(edge_perm)))

    # Flipping helper
    function flip(i)
        j, k = 2i - 1, 2i
        perm[j], perm[k] = perm[k], perm[j]
    end

    # Randomly flip the edges
    flipped = rand(rng, Bool, N_EDGES - 1)
    for i in 1:N_EDGES-1
        flipped[i] && flip(i)
    end

    # Flip the last edge to preserve parity
    last_flipped = xor(flipped...)
    last_flipped && flip(N_EDGES)

    return EdgeState(SPerm(perm))
end

function Base.rand(rng::AbstractRNG, ::Random.SamplerType{CornerState})
    # Shuffle the corners
    corner_perm = rand(rng, SPerm{N_CORNERS})

    # Map the sides to the correct position
    perm = collect(Iterators.flatten((3j - 2, 3j - 1, 3j) for j in images(corner_perm)))

    # Twisting helper
    function twist(i, t)
        j, k, l = 3i - 2, 3i - 1, 3i
        if t == 0
            return
        elseif t == 1
            perm[j], perm[k], perm[l] = perm[k], perm[l], perm[j]
        elseif t == 2
            perm[j], perm[k], perm[l] = perm[l], perm[j], perm[k]
        end
    end

    # Randomly twist the corners
    twisted = rand(rng, 0:2, N_CORNERS - 1)
    twist.(1:N_CORNERS-1, twisted)

    # Twist the last corner to preserve parity
    last_twisted = mod(-sum(twisted), 3)
    twist(N_CORNERS, last_twisted)

    return CornerState(SPerm(perm))
end

function Base.rand(rng::AbstractRNG, ::Random.SamplerType{Cube})
    center = rand(rng, Symm)
    edges = rand(rng, EdgeState)
    corners = rand(rng, CornerState)

    # Match the parity of edge_perm and corner_perm
    parity = isodd(edge_perm(edges)) ⊻ isodd(corner_perm(corners))
    if parity
        # Swap 2 edges {1,2} ↔ {3,4} if parity is odd
        edges = EdgeState(edges.perm * SPerm(3, 4, 1, 2))
    end

    return Cube(center, edges, corners)
end

Base.rand(rng::AbstractRNG, ::Random.SamplerType{Move}) = rand(rng, FACE_TURNS)

Base.rand(rng::AbstractRNG, ::Random.SamplerType{FaceTurn}) = rand(rng, ALL_FACETURNS)

