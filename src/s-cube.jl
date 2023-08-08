# Cube with symmetry
struct SCube
    symm::Symm
    cube::Cube
end
SCube(symm::Symm) = SCube(symm, Cube())
SCube(cube::Cube) = SCube(Symm(), cube)
SCube() = SCube(Symm(), Cube())

SCube(symm::Symm, m::Move) = SCube(symm, Cube(m))
SCube(m::Move) = SCube(Symm(), m)

@inline SCube(sc::SCube) = sc
@inline Base.copy(sc::SCube) = sc

# Operations
Base.:*(a::SCube, b::SCube) = SCube(b.symm * a.symm, remap(b.symm', a.cube) * b.cube)
Base.:*(a::SCube, b::Cube) = SCube(a.symm, a.cube * b)
Base.:*(a::Cube, b::SCube) = SCube(b.symm, remap(b.symm', a) * b.cube)
Base.:*(a::SCube, b::Move) = a * Cube(b)
Base.:*(a::Move, b::SCube) = Cube(a) * b

Base.inv(sc::SCube) = SCube(sc.symm', remap(sc.symm, sc.cube'))
Base.adjoint(sc::SCube) = inv(sc)

Base.:^(sc::SCube, p::Integer) = Base.power_by_squaring(sc, p)
@_insert_literal_pow(SCube)

# Normalization
normalize(sc::SCube) = SCube(Symm(), normalize(Cube, sc))
normalize(::Type{Cube}, sc::SCube) = remap(sc.symm, sc.cube)

# Congruent (same cube up to symmetry)
is_congruent(a::SCube, b::SCube) = remap(a.symm * b.symm', a.cube) == b.cube
is_congruent(a::SCube, b::Cube) = normalize(Cube, a) == b.cube
is_congruent(a::Cube, b::SCube) = a == normalize(Cube, b)

# Print
Base.show(io::IO, sc::SCube) = print(io, "SCube($(singmaster(sc)))")

_make_symm_char_map(s::Symm) = Dict(' ' => ' ', (Char(f) => Char(_SYMM_FACE[s.m][Int(f)]) for f in ALL_FACES)...)

function singmaster(sc::SCube)
    symm_str = _SYMM_STR[sc.symm.m]
    char_map = _make_symm_char_map(sc.symm)
    cube_str = join([char_map[c] for c in singmaster(sc.cube)])
    return "[$symm_str] $cube_str"
end

# Parse
function Base.parse(::Type{SCube}, str::AbstractString)
    symm = Symm(str[2:4])
    char_map = _make_symm_char_map(symm')
    cube_str = join([char_map[c] for c in str[6:end]])
    cube = parse_singmaster(cube_str)
    return SCube(symm, cube)
end
