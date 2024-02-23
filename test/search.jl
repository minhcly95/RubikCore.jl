# Next face in a canonical sequence
const CANONSEQ_NEXT = (
    (Front, Right, Down, Back, Left),
    (Up, Right, Down, Back, Left),
    (Up, Front, Down, Back, Left),
    (Front, Right, Back, Left),
    (Up, Right, Down, Left),
    (Up, Front, Down, Back),
)

function search_recur(cube, d, all_pos, last_face)
    push!(all_pos, cube)
    (d == 0) && return
    faces = isnothing(last_face) ? ALL_FACES : @inbounds CANONSEQ_NEXT[last_face]
    for f in faces, t in 1:3
        ft = FaceTurn(f, t)
        search_recur(cube * ft, d - 1, all_pos, f)
    end
end

@testset "Search" begin
    MAX_ELEMENTS = 1000000
    ALL_POS = (1, 18, 243, 3240, 43239, 574908, 7618438, 100803036, 1332343288)
    CANON_POS = (1, 2, 9, 75, 934, 12077, 159131, 2101575, 27762103, 366611212)
    CANONINV_POS = (1, 2, 8, 48, 509, 6198, 80178, 1053077, 13890036, 183339529)

    @testset "Breadth-first all pos" begin
        depth = Dict{Cube,Int}(Cube() => 0)
        all_pos = [Cube()]
        current = 1
        prev_d = -1
        
        println("Breadth-first all pos begins")
        time = @elapsed begin
            while current <= length(all_pos)
                cube = all_pos[current]
                d = depth[cube]

                if d != prev_d
                    num_pos = length(all_pos) - current + 1
                    println("    At level $d: size $num_pos")
                    @test ALL_POS[d+1] == num_pos
                    (length(all_pos) > MAX_ELEMENTS) && break
                    prev_d = d
                end

                for move in FACE_TURNS
                    next_cube = cube * move
                    if !haskey(depth, next_cube)
                        depth[next_cube] = d + 1
                        push!(all_pos, next_cube)
                    end
                end

                current += 1
            end
        end
        println("Breadth-first all pos ended, took $time seconds\n")
    end

    @testset "Breadth-first canon pos" begin
        depth = Dict{Cube,Int}(Cube() => 0)
        all_pos = [Cube()]
        current = 1
        prev_d = -1
        
        println("Breadth-first canon pos begins")
        time = @elapsed begin
            while current <= length(all_pos)
                cube = all_pos[current]
                d = depth[cube]

                if d != prev_d
                    num_pos = length(all_pos) - current + 1
                    println("    At level $d: size $num_pos")
                    @test CANON_POS[d+1] == num_pos
                    (length(all_pos) > MAX_ELEMENTS) && break
                    prev_d = d
                end

                for move in FACE_TURNS
                    next_cube = canonicalize(cube * move)
                    if !haskey(depth, next_cube)
                        depth[next_cube] = d + 1
                        push!(all_pos, next_cube)
                    end
                end

                current += 1
            end
        end
        println("Breadth-first canon pos ended, took $time seconds\n")
    end

    @testset "Breadth-first canon with inv pos" begin
        depth = Dict{Cube,Int}(Cube() => 0)
        all_pos = [Cube()]
        current = 1
        prev_d = -1
        
        println("Breadth-first canon with inv pos begins")
        time = @elapsed begin
            while current <= length(all_pos)
                cube = all_pos[current]
                d = depth[cube]

                if d != prev_d
                    num_pos = length(all_pos) - current + 1
                    println("    At level $d: size $num_pos")
                    @test CANONINV_POS[d+1] == num_pos
                    (length(all_pos) > MAX_ELEMENTS) && break
                    prev_d = d
                end

                for move in FACE_TURNS
                    next_cube = canonicalize(cube * move, include_inv=true)
                    if !haskey(depth, next_cube)
                        depth[next_cube] = d + 1
                        push!(all_pos, next_cube)
                    end
                    next_cube = canonicalize(cube' * move, include_inv=true)
                    if !haskey(depth, next_cube)
                        depth[next_cube] = d + 1
                        push!(all_pos, next_cube)
                    end
                end

                current += 1
            end
        end
        println("Breadth-first canon with inv pos ended, took $time seconds\n")
    end

    @testset "Depth-first search" begin
        prev_count = 0
        for d in 0:8
            all_pos = Cube[]
            println("Depth-first search at level $d begins")

            search_time = @elapsed search_recur(Cube(), d, all_pos, nothing)
            println("   Search took $search_time seconds")

            sort_time = @elapsed sort!(all_pos)
            println("   Sort took $sort_time seconds")

            unique_time = @elapsed unique!(all_pos)
            println("   Unique took $unique_time seconds")
            
            num_pos = length(all_pos)
            println("Depth-first search at level $d ended: pos $(num_pos), size $(num_pos - prev_count)\n")
            @test ALL_POS[d+1] == num_pos - prev_count
            prev_count = num_pos

            (num_pos > MAX_ELEMENTS) && break
        end
    end
end
