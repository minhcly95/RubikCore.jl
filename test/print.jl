@testset "Printing and parsing" begin
    @testset "Symm parse" begin
        for s in ALL_SYMMS
            str = string(s)
            @test Symm(str) == s
        end
    end

    @testset "Trigger parse" begin
        for (c, s) in [
            (Cube(I), "[UFR] UF UR UB UL DF DR DB DL FR FL BR BL UFR URB UBL ULF DRF DFL DLB DBR"),
            (Cube(U), "[UFR] UR UB UL UF DF DR DB DL FR FL BR BL URB UBL ULF UFR DRF DFL DLB DBR"),
            (Cube(F), "[UFR] LF UR UB UL RF DR DB DL FU FD BR BL LFU URB UBL LDF RUF RFD DLB DBR"),
            (Cube(R), "[UFR] UF FR UB UL DF BR DB DL DR FL UR BL FDR FRU UBL ULF BRD DFL DLB BUR"),
            (Cube(D), "[UFR] UF UR UB UL DL DF DR DB FR FL BR BL UFR URB UBL ULF DFL DLB DBR DRF"),
            (Cube(B), "[UFR] UF UR RB UL DF DR LB DL FR FL BD BU UFR RDB RBU ULF DRF DFL LUB LBD"),
            (Cube(L), "[UFR] UF UR UB BL DF DR DB FL FR UL BR DL UFR URB BDL BLU DRF FUL FLD DBR"),
            (Cube(SEXY_MOVE), "[UFR] UF FR UR UL DF DR DB DL UB FL BR BL FDR LUB URB ULF RUF DFL DLB DBR"),
            (Cube(REVERSED_SEXY), "[UFR] UF UB FR UL DF DR DB DL UR FL BR BL RFD UBL RBU ULF FRU DFL DLB DBR"),
            (Cube(MIRRORED_SEXY), "[UFR] UF UR UL FL DF DR DB DL FR UB BR BL UFR UBL RBU FLD DRF LFU DLB DBR"),
            (Cube(REVERSED_MIRRORED_SEXY), "[UFR] UF UR FL UB DF DR DB DL FR UL BR BL UFR LUB URB LDF DRF FUL DLB DBR"),
            (Cube(SLEDGEHAMMER), "[UFR] RF FU UB UL DF DR DB DL UR FL BR BL RFD FUL UBL BUR FRU DFL DLB DBR"),
            (Cube(HEDGEHAMMER), "[UFR] RU FR UB UL DF DR DB DL FU FL BR BL FDR LFU UBL RBU RUF DFL DLB DBR"),
        ]
            @test singmaster(c) == s
            @test Cube(s) == c
        end
    end

    @testset "Cube parse" begin
        for cube in rand(Cube, 100)
            str = singmaster(cube)
            @test Cube(str) == cube
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
end
