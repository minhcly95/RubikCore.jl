@testset "Cube" begin
    @testset "Identity" begin
        for c in rand(Cube, 10)
            @test c * Cube() == c
            @test Cube() * c == c
        end
    end

    @testset "Multiplication" begin
        for (a, b, c, d) in zip(AS, BS, CS, DS)
            @test a * b == c
            @test b * a == d
        end
    end

    @testset "Inverse" begin
        for (a, i) in zip(AS, IS)
            @test a' == i
            @test a == i'
            @test a * i == Cube()
            @test i * a == Cube()
        end
    end

    @testset "Power" begin
        for (a, a2, a3, a11) in zip(AS, A2S, A3S, A11S)
            @test a^0 == Cube()
            @test a^1 == a
            @test a^-1 == a'
            @test a^2 == a2
            @test a^3 == a3
            @test a^11 == a11
        end
    end

    @testset "Random inverse" begin
        for c in rand(Cube, 100)
            @test c' * c == I
            @test c * c' == I
        end
    end

    @testset "Random power" begin
        for c in rand(Cube, 100)
            p, q = rand(-20:20, 2)
            @test c^p * c^q == c^(p+q)
        end
    end

    @testset "Sequence multiplication" begin
        for _ in 1:100
            seq1 = rand(Move, 50)
            seq2 = rand(Move, 50)
            seq3 = seq1 * seq2
            a, b, c = prod.((seq1, seq2, seq3))
            @test a * b == c
        end
    end

    @testset "Sequence inverse" begin
        for _ in 1:100
            seq = rand(Move, 50)
            a, b = prod.((seq, seq'))
            @test a == b'
        end
    end

    @testset "Sequence power" begin
        for _ in 1:100
            seq = rand(Move, 50)
            c, c2, c3, c5, c8 = prod.((seq, seq^2, seq^3, seq^5, seq^8))
            @test c^0 == I
            @test c^1 == c
            @test c^-1 == c'
            @test c^2 == c2
            @test c^3 == c3
            @test c^5 == c5
            @test c^8 == c8
        end
    end
end