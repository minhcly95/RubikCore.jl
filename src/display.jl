function Base.show(io::IO, ::MIME"text/plain", c::Cube)
    println(io, "3x3x3 Cube:")
    print_net(io, c)
end

function Base.show(io::IO, ::MIME"text/plain", sc::SCube)
    println(io, "3x3x3 SCube:")
    print_net(io, sc)
end

print_net(io::IO, c::Cube) = print_net(io, SCube(c))

function print_net(io::IO, sc::SCube)
    FACE_CRAYONS = Dict(
        'U' => crayon"fg:black bg:white",
        'F' => crayon"fg:white bg:green",
        'R' => crayon"fg:white bg:red",
        'D' => crayon"fg:black bg:yellow",
        'B' => crayon"fg:white bg:blue",
        'L' => crayon"fg:white bg:magenta",     # Orange is replaced by magenta
        )
    DEF_CRAYON = crayon"reset"
    NBSP = Char(160)                            # Non-breaking space

    print_square(f) = print(io, FACE_CRAYONS[f], "$NBSP$f$NBSP")
    function print_row(net_face, row)
        @_for(i = 1:3, print_square(net_face[(row-1)*3 + i]))
    end
    print_emptyrow() = print(io, DEF_CRAYON, NBSP^9)
    print_newline() = println(io, DEF_CRAYON, NBSP)

    net = _get_net(sc)

    for i in 1:3
        print_emptyrow(); print_row(net[1], i); print_emptyrow(); print_emptyrow(); print_newline()
    end
    for i in 1:3
        print_row(net[6], i); print_row(net[2], i); print_row(net[3], i); print_row(net[5], i); print_newline()
    end
    for i in 1:3
        print_emptyrow(); print_row(net[4], i); print_emptyrow(); print_emptyrow();
        (i < 3) ? print_newline() : print(io, DEF_CRAYON, NBSP)
    end
end

macro _net_face_from_sm(sm, i1, i2, i3, i4, f, i5, i6, i7, i8)
    sm = esc(sm)
    f = esc(f)
    return :(($sm[$i1+6], $sm[$i2+6], $sm[$i3+6], $sm[$i4+6], $f, $sm[$i5+6], $sm[$i6+6], $sm[$i7+6], $sm[$i8+6]))
end

function _get_net(sc::SCube)
    sm = singmaster(sc)
    centers = Char.(remap(sc.symm, f) for f in ALL_FACES)
    return (
        @_net_face_from_sm(sm, 45, 7, 41, 10, centers[1], 4, 49, 1, 37),
        @_net_face_from_sm(sm, 51, 2, 38, 28, centers[2], 25, 58, 14, 55),
        @_net_face_from_sm(sm, 39, 5, 42, 26, centers[3], 32, 54, 17, 67),
        @_net_face_from_sm(sm, 57, 13, 53, 22, centers[4], 16, 61, 19, 65),
        @_net_face_from_sm(sm, 43, 8, 46, 31, centers[5], 34, 66, 20, 63),
        @_net_face_from_sm(sm, 47, 11, 50, 35, centers[6], 29, 62, 23, 59),
    )
end
