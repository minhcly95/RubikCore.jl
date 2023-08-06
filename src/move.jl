@enum Face Up=1 Front Right Down Back Left

@enum Move I U1 U2 U3 F1 F2 F3 R1 R2 R3 D1 D2 D3 B1 B2 B3 L1 L2 L3

const NFACES = 6
const NTWISTS = 3
const NMOVES = NFACES * NTWISTS

const ALL_FACES = (Up, Front, Right, Down, Back, Left)
const ALL_MOVES = (U1, U2, U3, F1, F2, F3, R1, R2, R3, D1, D2, D3, B1, B2, B3, L1, L2, L3)

# Accessors
function face(m::Move)
    return m == I ? Up : Face(fld1(Int(m), NTWISTS))
end

function twist(m::Move)
    return m == I ? 0 : mod1(Int(m), NTWISTS)
end

# Operations
function Move(f::Face, t::Int)
    t = mod(t, 4)
    return t == 0 ? I : Move((Int(f) - 1) * NTWISTS + t)
end

Move(f::Face) = Move(f, 1)

Base.:^(f::Face, t::Int) = Move(f, t)
Base.:^(m::Move, t::Int) = Move(face(m), twist(m) * t)

Base.inv(f::Face) = Move(f, 3)
Base.inv(m::Move) = Move(face(m), -twist(m))
