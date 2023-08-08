@testset "Symmetry" begin
    @testset "Identity" begin
        for s in ALL_SYMMS
            @test s * Symm() == s
            @test Symm() * s == s
        end
    end

    @testset "Inverse" begin
        for s in ALL_SYMMS
            @test inv(s) == s'
            @test s' * s == Symm()
            @test s * s' == Symm()
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
    
    @testset "Random symmetry" begin
        for _ in 1:50
            @test !is_mirrored(rand(Symm))
        end
    end
    
    @testset "Move remap" begin
        @test remap(symm"UFR", U) == U
        @test remap(symm"UFR", F) == F
        @test remap(symm"UFR", R) == R

        @test remap(symm"UFL", U) == U'
        @test remap(symm"UFL", F) == F'
        @test remap(symm"UFL", R) == L'
        
        @test remap(symm"RFD", U) == R
        @test remap(symm"RFD", F) == F
        @test remap(symm"RFD", R) == D

        @test remap(symm"FLU", U) == F'
        @test remap(symm"FLU", F) == L'
        @test remap(symm"FLU", R) == U'
    end

    @testset "Sequence multiplication" begin
        for _ in 1:100
            seq1 = rand(ALL_SYMMS, 10)
            seq2 = rand(ALL_SYMMS, 10)
            seq3 = vcat(seq1, seq2)
            a = prod(seq1)
            b = prod(seq2)
            c = prod(seq3)
            @test a * b == c
        end
    end

    @testset "Sequence inverse" begin
        for _ in 1:100
            seq = rand(ALL_SYMMS, 10)
            inv_seq = reverse!(inv.(seq))
            a = prod(seq)
            b = prod(inv_seq)
            @test a == b'
        end
    end

    @testset "Sequence remap" begin
        for _ in 1:100
            symm = rand(ALL_SYMMS)
            seq = rand(Move, 50)
            remapped_seq = [remap(symm, m) for m in seq]
            cube = Cube(seq)
            remapped_cube = remap(symm, cube)
            @test Cube(remapped_seq) == remapped_cube
        end
    end
end
