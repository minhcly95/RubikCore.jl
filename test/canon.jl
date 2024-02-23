@testset "Canonicalization" begin
    @testset "Canonical cube without inverse" begin
        for cube in rand(Cube, 100)
            ncube = normalize(cube)
            canon = minimum(symm' * ncube * symm for symm in ALL_SYMMS)
            @test canonicalize(cube) == canon
            @test canonicalize(cube * rand(ALL_SYMMS)) == canon
            @test canonicalize(canon) == canon
        end
    end
    
    @testset "Canonical cube with inverse" begin
        for cube in rand(Cube, 100)
            ncube = normalize(cube)
            canon = minimum(symm' * ncube * symm for symm in ALL_SYMMS)
            inv_canon = minimum(symm' * ncube' * symm for symm in ALL_SYMMS)
            all_canon = min(canon, inv_canon)
            @test canonicalize(cube, include_inv=true) == all_canon
            @test canonicalize(cube * rand(ALL_SYMMS), include_inv=true) == all_canon
            @test canonicalize(cube', include_inv=true) == all_canon
            @test canonicalize(canon, include_inv=true) == all_canon
            @test canonicalize(inv_canon, include_inv=true) == all_canon
        end
    end
end
