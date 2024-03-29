@testset "Rotation" begin
    SS = [Symm("RBD"), Symm("FDR"), Symm("RDF"), Symm("BRU"), Symm("ULF")]

    @testset "Face rotation" begin
        rotated = [(Right, Back, Down), (Front, Down, Right), (Right, Down, Front), (Back, Right, Up), (Up, Left, Front)]
        for (s, f) in zip(SS, rotated)
            @test s(Up) == f[1]
            @test s(Front) == f[2]
            @test s(Right) == f[3]
        end
    end

    @testset "Cube rotation" begin
        for (s, c, r) in zip(SS, AS, RS)
            @test s(c) == r
        end
    end

    @testset "PLL rotation" begin
        rotated = [
            [D', R', D, R, D, B', D2, R, D, R, D', R', D, B],
            [x, R2, D, R, D', R, F2, r', F, r, F2, x'],
            [F, R', F', R, F, D, R, D', F', R', F, D', F, D, F', R, F'],
            [y, D, B', D', F, D, B, D', F', D, B, D', F, D, B', D', F', y'],
            [F, U, F', U', D, F2, U', F, U', F', U, F', U, F2, D'],
        ]
        for (s, seq, rot) in zip(SS, [PLL_T, PLL_Ja, PLL_Nb, PLL_E, PLL_Gd], rotated)
            @test s.(seq) == rot
        end
    end

    @testset "Sequence rotation" begin
        for _ in 1:100
            symm = rand(ALL_SYMMS)
            seq = rand([FACE_TURNS..., CUBE_ROTATIONS..., SLICE_TURNS..., WIDE_TURNS...], 50)
            rotated_seq = [symm(m) for m in seq]
            cube = symm' * Cube(prod(seq)) * symm
            @test Cube(rotated_seq) == cube
        end
    end

    @testset "Normalization" begin
        for c in rand(Cube, 100)
            d = rand(ALL_SYMMS)(c)
            @test normalize(c).center == Symm(1)
            @test normalize(c) == normalize(d)
        end
    end

    @testset "Congruence" begin
        for c in rand(Cube, 100)
            d = rand(ALL_SYMMS)(c)
            @test is_congruent(c, d)
        end
    end
end
