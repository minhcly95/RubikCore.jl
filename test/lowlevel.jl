@testset "Low-level manipulation" begin
    @testset "Flip edge" begin
        for e in rand(EdgeState, 100)
            i = rand(1:N_EDGES)
            ee = flip_edge(e, i)
            # Base.rand always generates a 0-parity EdgeState
            # So flipping 1 edge makes it 1-parity
            @test parity(ee) == 1
            @test edge_ori(ee, i) == !edge_ori(e, i)
        end
    end

    @testset "Twist corner" begin
        for c in rand(CornerState, 100)
            i = rand(1:N_CORNERS)
            c1 = twist_corner(c, i, 1)
            c2 = twist_corner(c, i, 2)
            # Base.rand always generates a 0-parity CornerState
            @test parity(c1) == 1
            @test parity(c2) == 2
            @test corner_ori(c1, i) == mod(corner_ori(c, i) + 1, 3)
            @test corner_ori(c2, i) == mod(corner_ori(c, i) + 2, 3)

            @test twist_corner(c, i, 3) == c
            @test twist_corner(c, i, 4) == c1
            @test twist_corner(c, i, 5) == c2
            @test twist_corner(c, i, -1) == c2
            @test twist_corner(c, i, -2) == c1
        end
    end

    @testset "Swap edges" begin
        for e in rand(EdgeState, 100)
            i, j = rand(1:N_EDGES, 2)
            ee = swap_edges(e, i, j)
            @test i == j ? iseven(edge_perm(e * ee)) : isodd(edge_perm(e * ee))
        end
    end

    @testset "Swap corners" begin
        for c in rand(CornerState, 100)
            i, j = rand(1:N_CORNERS, 2)
            cc = swap_corners(c, i, j)
            @test i == j ? iseven(corner_perm(c * cc)) : isodd(corner_perm(c * cc))
        end
    end
end
