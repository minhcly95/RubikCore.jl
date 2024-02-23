# EdgeState and CornerState rotation
function _make_symm_states()
    # Each Symm permutes EdgeState and CornerState in a certain way.
    # We reuse Singmaster print and parse to build these lists of permutations.
    symm_edgestate = []
    symm_cornerstate = []

    for symm in ALL_SYMMS
        face_map = [Char(symm(f)) => Char(f) for f in ALL_FACES]
        cstr = replace(SM_SOLVED, face_map...)
        c = parse(Cube, cstr)
        push!(symm_edgestate, c.edges)
        push!(symm_cornerstate, c.corners)
    end

    return symm_edgestate, symm_cornerstate
end
const SYMM_EDGESTATE, SYMM_CORNERSTATE = Tuple.(_make_symm_states())

Base.:*(e::EdgeState, symm::Symm) = @inbounds e * SYMM_EDGESTATE[symm]
Base.:*(symm::Symm, e::EdgeState) = @inbounds SYMM_EDGESTATE[symm] * e
(symm::Symm)(e::EdgeState) = e * symm

Base.:*(c::CornerState, symm::Symm) = @inbounds c * SYMM_CORNERSTATE[symm]
Base.:*(symm::Symm, c::CornerState) = @inbounds SYMM_CORNERSTATE[symm] * c
(symm::Symm)(c::CornerState) = c * symm

# Cube rotation
Base.:*(c::Cube, symm::Symm) = Cube(c.center * symm, c.edges * symm, c.corners * symm)
Base.:*(symm::Symm, c::Cube) = Cube(symm * c.center, symm * c.edges, symm * c.corners)
(symm::Symm)(c::Cube) = c * symm

# Move rotation
(symm::Symm)(m::Move) = Move(symm' * Cube(m) * symm)

# Normalization: turn the cube back to [UFR]
normalize(c::Cube) = c * c.center'

# Congruence (same cube up to symmetry)
is_congruent(a::Cube, b::Cube) = a == b * (b.center' * a.center)

