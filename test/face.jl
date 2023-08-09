@testset "Face" begin
    @testset "Opposite" begin
        for f1 in ALL_FACES, f2 in ALL_FACES
            @test (f1 == opposite(f2)) ⊻ (abs(Int(f1) - Int(f2)) != 3)
        end
    end

    @testset "Print and parse" begin
        for f in ALL_FACES
            @test Face(Char(f)) == f
        end
    end
end
