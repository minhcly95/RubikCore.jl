const N_FACES = 6

# Struct
@int_struct struct Face
    N_FACES::UInt8
end

# Literal faces
const Up = Face(1)
const Front = Face(2)
const Right = Face(3)
const Down = Face(4)
const Back = Face(5)
const Left = Face(6)

const ALL_FACES = Tuple(instances(Face))

# Opposite face
const _OPPOSITE_FACE = (Down, Back, Left, Up, Front, Right)
opposite(f::Face) = @inbounds _OPPOSITE_FACE[f]

# Print and parse
const _FACE_CHARS = ('U', 'F', 'R', 'D', 'B', 'L')
const _FACE_STRS = ("Up", "Front", "Right", "Down", "Back", "Left")

Base.Char(f::Face) = @inbounds _FACE_CHARS[f]
Base.show(io::IO, f::Face) = print(io, @inbounds _FACE_STRS[f])

function Face(c::Char)
    f = findfirst(==(c), _FACE_CHARS)
    isnothing(f) && throw(ArgumentError("invalid character for Face: $c"))
    return Face(f)
end
