const NFACES = 6

@enum Face Up=1 Front Right Down Back Left
const ALL_FACES = instances(Face)

opposite(f::Face) = Face(mod1(Int(f) + 3, 6))

# Face from char
const _CHAR_TO_FACE = Dict('U' => Up, 'F' => Front, 'R' => Right, 'D' => Down, 'B' => Back, 'L' => Left)
const _FACE_TO_CHAR = Dict(reverse.(collect(_CHAR_TO_FACE)))

Face(c::Char) = haskey(_CHAR_TO_FACE, c) ? _CHAR_TO_FACE[c] : error("Invalid face ($c)")

Face(s::String) = length(s) == 1 ? Face(s[1]) : error("Invalid face ($s)")

# Face to char
Base.Char(f::Face) = _FACE_TO_CHAR[f]
