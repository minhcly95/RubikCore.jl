@testset "Canonicalization" begin
    @testset "Canonical cube without inverse" begin
        for cube in rand(Cube, 100)
            ncube = normalize(cube)
            canon = minimum(Cube(rotate(Move(ncube), symm)) for symm in ALL_SYMMS)
            @test canonicalize(cube) == canon
            @test canonicalize(rotate(cube, rand(ALL_SYMMS))) == canon
            @test canonicalize(canon) == canon
        end
    end
    
    @testset "Canonical cube with inverse" begin
        for cube in rand(Cube, 100)
            ncube = normalize(cube)
            canon = minimum(Cube(rotate(Move(ncube), symm)) for symm in ALL_SYMMS)
            inv_canon = minimum(Cube(rotate(Move(ncube'), symm)) for symm in ALL_SYMMS)
            all_canon = min(canon, inv_canon)
            @test canonicalize(cube, true) == all_canon
            @test canonicalize(rotate(cube, rand(ALL_SYMMS)), true) == all_canon
            @test canonicalize(cube', true) == all_canon
            @test canonicalize(canon, true) == all_canon
            @test canonicalize(inv_canon, true) == all_canon
        end
    end
end
