@testset "Move operations" begin
    @testset "Face and twist" begin
        for m in Rubik.ALL_MOVES
            f, t = face(m), twist(m)
            @test m == Move(f, t)
        end
    end

    @testset "Face power" begin
        for f in Rubik.ALL_FACES
            @test f^0 == I
            @test f^1 == Move(f, 1)
            @test f^2 == Move(f, 2)
            @test f^-1 == Move(f, 3)
        end
    end
    
    @testset "Move power" begin
        for m in Rubik.ALL_MOVES
            f, t = face(m), twist(m)

            @test m^0 == m^4 == m^-4 == I
            @test m^1 == m^5 == m^-3 == m
            @test m^2 == m^-2
            @test m^3 == m^-1 == Move(f, 4 - t)

            @test m^2 == I || m^2 == Move(f, 2)
        end
    end
end