# Next face in a canonical sequence
const _CANONSEQ_NEXT = (
    (Front, Right, Down, Back, Left),
    (Up, Right, Down, Back, Left),
    (Up, Front, Down, Back, Left),
    (Front, Right, Back, Left),
    (Up, Right, Down, Left),
    (Up, Front, Down, Back),
)

canonseq_next_faces(f::Face) = @inbounds _CANONSEQ_NEXT[Int(f)]
