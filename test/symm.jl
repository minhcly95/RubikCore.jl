@testset "Symmetry" begin
    @testset "Identity" begin
        for s in ALL_SYMMS
            @test s * Symm() == s
            @test Symm() * s == s
        end
    end

    @testset "Mirrored" begin
        @test !any(is_mirrored.(UNMIRRORED_SYMMS))
        @test all(is_mirrored.(MIRRORED_SYMMS))
        for _ in 1:100
            a, b = rand(ALL_SYMMS, 2)
            @test is_mirrored(a * b) == is_mirrored(a) ⊻ is_mirrored(b)
        end
    end

    @testset "Multiplication" begin
        as = ["BRU", "DBR", "BRD", "UFL", "LDB", "LDF", "FRD", "DRB", "FRU", "BRD"]
        bs = ["FUR", "UFL", "ULB", "FRD", "DFL", "RBU", "LDF", "FRD", "FRU", "UFR"]
        cs = ["DRF", "DBL", "RBD", "FRU", "RUB", "DLB", "DFR", "BDL", "RUF", "BRD"]
        for (a, b, c) in zip(as, bs, cs)
            @test Symm(a) * Symm(b) == Symm(c)
        end
    end

    @testset "Inverse" begin
        for s in ALL_SYMMS
            @test s' * s == Symm()
            @test s * s' == Symm()
        end
    end

    @testset "Sequence multiplication" begin
        for _ in 1:100
            seq1 = rand(ALL_SYMMS, 10)
            seq2 = rand(ALL_SYMMS, 10)
            seq3 = vcat(seq1, seq2)
            a, b, c = prod.((seq1, seq2, seq3))
            @test a * b == c
        end
    end

    @testset "Sequence inverse" begin
        for _ in 1:100
            seq = rand(ALL_SYMMS, 10)
            inv_seq = reverse!(inv.(seq))
            a, b = prod.((seq, inv_seq))
            @test a == b'
        end
    end
end
