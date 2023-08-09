@testset "Move" begin
    @testset "Identity" begin
        for m in Move.(rand(Cube, 10))
            @test m * I == m
            @test I * m == m
        end
    end
    
    @testset "Trigger inverse" begin
        for (seq1, seq2) in [(SEXY_MOVE, REVERSED_SEXY), (MIRRORED_SEXY, REVERSED_MIRRORED_SEXY), (SLEDGEHAMMER, HEDGEHAMMER)]
            m1, m2 = Move.((seq1, seq2))
            @test m1' == m2
            @test m1 * m2 == I
        end
    end

    @testset "Trigger power order" begin
        for seq in [SEXY_MOVE, REVERSED_SEXY, MIRRORED_SEXY, REVERSED_MIRRORED_SEXY, SLEDGEHAMMER, HEDGEHAMMER]
            @test Move(seq)^6 == I
        end
        @test Move(CIRCLE)^5 == I
        @test Move(ANTI_CIRCLE)^5 == I
        @test (R * U')^63 == I
        @test (R2 * U2)^6 == I
    end

    @testset "PLL sequences" begin
        @test Move(PLL_H)^2 == I
        @test (Move(PLL_Z) * U')^2 == I
        @test Move(PLL_Ua) * Move(PLL_Ub) == I
        @test Move(PLL_Ua)^3 == I
        @test Move(PLL_Ub)^3 == I

        @test Move(PLL_T)^2 == I
        @test Move(PLL_F)^2 == I
        @test Move(PLL_Ja)^2 == I
        @test Move(PLL_Jb)^3 == I
        @test (Move(PLL_Jb) * U')^2 == I
        @test Move(PLL_Ra)^3 == I
        @test (Move(PLL_Ra) * U')^2 == I
        @test Move(PLL_Rb)^3 == I
        @test (Move(PLL_Rb) * U)^2 == I

        @test Move(PLL_Ga) * Move(PLL_Gb) == I
        @test Move(PLL_Gc) * Move(PLL_Gd) == I
        @test Move(PLL_Ga)^4 == I
        @test Move(PLL_Gb)^4 == I
        @test Move(PLL_Gc)^4 == I
        @test Move(PLL_Gd)^4 == I

        @test Move(PLL_Aa) * U' * Move(PLL_Ab) * U == I

        @test Move(PLL_E)^2 == I
        @test Move(PLL_Na)^2 == I
        @test Move(PLL_Nb)^2 == I
        @test Move(PLL_V)^2 == I
        @test Move(PLL_Y)^2 == I
    end
end
