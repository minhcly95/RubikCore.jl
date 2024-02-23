function Base.show(io::IO, ::MIME"text/plain", c::Cube)
    println(io, "3x3x3 Cube:")
    print_net(io, c)
end

function print_net(io::IO, c::Cube)
    FACE_CRAYONS = Dict(
        Up => crayon"fg:black bg:white",
        Front => crayon"fg:white bg:green",
        Right => crayon"fg:white bg:red",
        Down => crayon"fg:black bg:yellow",
        Back => crayon"fg:white bg:blue",
        Left => crayon"fg:white bg:magenta",    # Orange is replaced by magenta
        )
    DEF_CRAYON = crayon"reset"
    NBSP = Char(160)                            # Non-breaking space

    print_square(f) = print(io, FACE_CRAYONS[f], "$NBSP$(Char(f))$NBSP")
    function print_row(net_face, row)
        for i in 1:3
            print_square(net_face[(row-1)*3 + i])
        end
    end
    print_emptyrow() = print(io, DEF_CRAYON, NBSP^9)
    print_newline() = println(io, DEF_CRAYON, NBSP)

    cnet = net(c)

    for i in 1:3
        print_emptyrow(); print_row(cnet[1], i); print_emptyrow(); print_emptyrow(); print_newline()
    end
    for i in 1:3
        print_row(cnet[6], i); print_row(cnet[2], i); print_row(cnet[3], i); print_row(cnet[5], i); print_newline()
    end
    for i in 1:3
        print_emptyrow(); print_row(cnet[4], i); print_emptyrow(); print_emptyrow();
        (i < 3) ? print_newline() : print(io, DEF_CRAYON, NBSP)
    end
end

macro _net_face_from_sm(sm, i1, i2, i3, i4, f, i5, i6, i7, i8)
    sm = esc(sm)
    f = esc(f)
    return :((
        Face($sm[$i1]), Face($sm[$i2]), Face($sm[$i3]),
        Face($sm[$i4]), $f, Face($sm[$i5]),
        Face($sm[$i6]), Face($sm[$i7]), Face($sm[$i8])
    ))
end

function net(c::Cube)
    sm = singmaster(c)
    centers = [(c.center')(f) for f in ALL_FACES]
    sm = sm[7:end]
    return (
        @_net_face_from_sm(sm, 45, 7, 41, 10, centers[1], 4, 49, 1, 37),
        @_net_face_from_sm(sm, 51, 2, 38, 28, centers[2], 25, 58, 14, 55),
        @_net_face_from_sm(sm, 39, 5, 42, 26, centers[3], 32, 54, 17, 67),
        @_net_face_from_sm(sm, 57, 13, 53, 22, centers[4], 16, 61, 19, 65),
        @_net_face_from_sm(sm, 43, 8, 46, 31, centers[5], 34, 66, 20, 63),
        @_net_face_from_sm(sm, 47, 11, 50, 35, centers[6], 29, 62, 23, 59),
    )
end
