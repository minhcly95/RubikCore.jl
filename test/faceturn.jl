@testset "FaceTurn" begin
    @testset "Conversion" begin
        for ft in ALL_FACETURNS
            @test Move(ft) == ft
            @test FaceTurn(Move(ft)) === ft
        end
    end

    @testset "Inverse" begin
        for ft in ALL_FACETURNS
            @test ft' == Move(ft)'
        end
    end

    @testset "Power" begin
        for ft in ALL_FACETURNS, p in -7:7
            @test ft^p == Move(ft)^p
        end
    end

    @testset "Rotation" begin
        for ft in ALL_FACETURNS, symm in ALL_SYMMS
            @test symm(ft) == symm(Move(ft))
        end
    end
end
