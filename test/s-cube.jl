@testset "SCube" begin
    @testset "Identity" begin
        for sc in rand(SCube, 100)
            @test sc * SCube() == sc
            @test SCube() * sc == sc
        end
    end

    @testset "Inverse" begin
        for sc in rand(SCube, 100)
            @test inv(sc) == sc'
            @test sc' * sc == SCube()
            @test sc * sc' == SCube()
        end
    end

    @testset "Normalization" begin
        @test normalize(Cube, SCube(symm"RFD", U)) == Cube(R)
        @test normalize(Cube, SCube(symm"LDF", B)) == Cube(U)
        @test normalize(Cube, SCube(symm"RDB", D)) == Cube(L)

        for c in rand(Cube, 100)
            sc = c * SCube(rand(Symm))
            normed = normalize(sc)
            @test normed.symm == Symm()
            @test normed.cube == c
        end
    end

    @testset "Congruence" begin
        @test is_congruent(SCube(symm"RFD", U), SCube(symm"BDL", L))
        @test is_congruent(SCube(symm"RFD", U), SCube(symm"BLU", B))
        @test !is_congruent(SCube(symm"BDL", L), SCube(symm"BLU", B'))

        for sc in rand(SCube, 100)
            sd = sc * SCube(rand(Symm))
            @test is_congruent(sc, sd)
        end
    end
    
    @testset "Sequence multiplication" begin
        for _ in 1:100
            seq1 = rand(SCube, 50)
            seq2 = rand(SCube, 50)
            seq3 = vcat(seq1, seq2)
            a = prod(seq1)
            b = prod(seq2)
            c = prod(seq3)
            @test a * b == c
        end
    end

    @testset "Sequence inverse" begin
        for _ in 1:100
            seq = rand(SCube, 50)
            inv_seq = reverse!(inv.(seq))
            a = prod(seq)
            b = prod(inv_seq)
            @test a == b'
        end
    end
end
