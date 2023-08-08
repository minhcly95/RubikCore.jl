@testset "Operations" begin
    @testset "Face to move" begin
        for (f, m) in zip((Up, Front, Right, Down, Back, Left), (U, F, R, D, B, L))
            @test f^0 == I
            @test f^1 == m
            @test f^-2 == m^2
            @test f' == m^3
        end
    end
    
    @testset "Cube identity" begin
        for _ in 1:100
            c = rand(Cube)
            @test c * Cube() == c
            @test Cube() * c == c
        end
    end

    @testset "Move identity" begin
        @test I * I == I
        for m in BASIC_MOVES
            @test m * I == m
            @test I * m == m
        end
    end

    @testset "Move inverse" begin
        for m in BASIC_MOVES
            @test inv(m) == m'
            @test m' * m == I
            @test m * m' == I
        end
    end

    @testset "Move power" begin
        for m in BASIC_MOVES
            @test m^0 == m^4 == m^-4 == I
            @test m^1 == m^5 == m^-3 == m
            @test m^2 == m^-2 == m'^2
            @test m^3 == m^-1 == m'
        end
    end

    @testset "Trigger inverse" begin
        for (S, T) in [(SEXY_MOVE, REVERSED_SEXY), (MIRRORED_SEXY, REVERSED_MIRRORED_SEXY), (SLEDGEHAMMER, HEDGEHAMMER)]
            @test S' == T
            @test T' == S
            @test S * T == I
            @test S' * T' == I
        end
    end

    @testset "Trigger power" begin
        for T in [SEXY_MOVE, REVERSED_SEXY, MIRRORED_SEXY, REVERSED_MIRRORED_SEXY, SLEDGEHAMMER, HEDGEHAMMER]
            @test T^6 == I
        end
        @test CIRCLE^5 == I
        @test ANTI_CIRCLE^5 == I
        @test (R * U')^63 == I
        @test (R2 * U2)^6 == I
    end

    @testset "Sequence multiplication" begin
        for _ in 1:100
            seq1 = rand(Move, 50)
            seq2 = rand(Move, 50)
            seq3 = vcat(seq1, seq2)
            a = prod(seq1)
            b = prod(seq2)
            c = prod(seq3)
            @test a * b == c
        end
    end

    @testset "Sequence inverse" begin
        for _ in 1:100
            seq = rand(Move, 50)
            inv_seq = reverse!(inv.(seq))
            a = prod(seq)
            b = prod(inv_seq)
            @test a == inv(b)
            @test a * b == I
            @test inv(inv(a)) == a
        end
    end

    @testset "Sequence power" begin
        for _ in 1:100
            seq = rand(Move, 50)
            seq2 = vcat(seq, seq)
            seq3 = vcat(seq, seq2)
            seq5 = vcat(seq2, seq3)
            seq8 = vcat(seq3, seq5)
            c, c2, c3, c5, c8 = prod.((seq, seq2, seq3, seq5, seq8))
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