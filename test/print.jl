@testset "Printing and parsing" begin
    @testset "Singmaster's notation" begin
        for (m, s) in [
            (I, "UF UR UB UL DF DR DB DL FR FL BR BL UFR URB UBL ULF DRF DFL DLB DBR"),
            (U, "UR UB UL UF DF DR DB DL FR FL BR BL URB UBL ULF UFR DRF DFL DLB DBR"),
            (F, "LF UR UB UL RF DR DB DL FU FD BR BL LFU URB UBL LDF RUF RFD DLB DBR"),
            (R, "UF FR UB UL DF BR DB DL DR FL UR BL FDR FRU UBL ULF BRD DFL DLB BUR"),
            (D, "UF UR UB UL DL DF DR DB FR FL BR BL UFR URB UBL ULF DFL DLB DBR DRF"),
            (B, "UF UR RB UL DF DR LB DL FR FL BD BU UFR RDB RBU ULF DRF DFL LUB LBD"),
            (L, "UF UR UB BL DF DR DB FL FR UL BR DL UFR URB BDL BLU DRF FUL FLD DBR"),
            (SEXY_MOVE, "UF FR UR UL DF DR DB DL UB FL BR BL FDR LUB URB ULF RUF DFL DLB DBR"),
            (REVERSED_SEXY, "UF UB FR UL DF DR DB DL UR FL BR BL RFD UBL RBU ULF FRU DFL DLB DBR"),
            (MIRRORED_SEXY, "UF UR UL FL DF DR DB DL FR UB BR BL UFR UBL RBU FLD DRF LFU DLB DBR"),
            (REVERSED_MIRRORED_SEXY, "UF UR FL UB DF DR DB DL FR UL BR BL UFR LUB URB LDF DRF FUL DLB DBR"),
            (SLEDGEHAMMER, "RF FU UB UL DF DR DB DL UR FL BR BL RFD FUL UBL BUR FRU DFL DLB DBR"),
            (HEDGEHAMMER, "RU FR UB UL DF DR DB DL FU FL BR BL FDR LFU UBL RBU RUF DFL DLB DBR"),
        ]
            @test singmaster(m) == s
            @test parse(Cube, s) == Cube(m)
        end
    end

    @testset "Cube parse" begin
        for _ in 1:100
            seq = rand(Move, 50)
            cube = Cube(prod(seq))
            str = singmaster(cube)
            @test parse(Cube, str) == cube
        end
    end

    @testset "Move parse" begin
        for (s, m) in [
            ("U", U), ("U1", U), ("U+", U), ("U2", U2), ("UU", U2), ("U'", U3), ("U3", U3), ("U-", U3),
            ("F", F), ("F1", F), ("F+", F), ("F2", F2), ("FF", F2), ("F'", F3), ("F3", F3), ("F-", F3),
            ("R", R), ("R1", R), ("R+", R), ("R2", R2), ("RR", R2), ("R'", R3), ("R3", R3), ("R-", R3),
            ("D", D), ("D1", D), ("D+", D), ("D2", D2), ("DD", D2), ("D'", D3), ("D3", D3), ("D-", D3),
            ("B", B), ("B1", B), ("B+", B), ("B2", B2), ("BB", B2), ("B'", B3), ("B3", B3), ("B-", B3),
            ("L", L), ("L1", L), ("L+", L), ("L2", L2), ("LL", L2), ("L'", L3), ("L3", L3), ("L-", L3),
        ]
            @test parse(Move, s) == m
        end
    end

    @testset "Trigger parse" begin
        for (s, m) in [
            (seq"", I),
            (seq"R U R' U'", SEXY_MOVE),
            (seq"U+ R+ U- R-", REVERSED_SEXY),
            (seq"L- U- L+ U+", MIRRORED_SEXY),
            (seq"U3 L3 U1 L1", REVERSED_MIRRORED_SEXY),
            (seq"R' F R F'", SLEDGEHAMMER),
            (seq"F1 R3 F3 R1", HEDGEHAMMER),
        ]
            @test prod(s) == m
        end
    end

    @testset "Sequence parse" begin
        for _ in 1:100
            seq = rand(Move, 50)
            seq_str = join(string.(seq), " ")
            seq_parse = parse(Vector{Move}, seq_str)
            @test seq == seq_parse
        end
    end

    @testset "Symm parse" begin
        for _ in 1:100
            s = rand(ALL_SYMMS)
            str = string(s)[6:8]
            @test string(s) == "Symm($str)"
            @test Symm(str) == s
        end
    end
end
