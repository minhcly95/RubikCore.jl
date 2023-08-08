@testset "Display" begin
    @testset "Identity text display" begin
        io = IOBuffer()
        show(io, MIME"text/plain"(), Cube())
        displayed = String(take!(io))

        # Strip all escape sequences and non-breaking spaces
        displayed = replace(displayed, r"\e\[.+?m" => "")
        displayed = replace(displayed, Char(160) => " ")
        # Remove all trailing whitespaces for each line
        displayed = replace(displayed, r" *$"m => "")

        # DO NOT add or remove any space lest ruining the test
        reference = """
        3x3x3 Cube:
                  U  U  U
                  U  U  U
                  U  U  U
         L  L  L  F  F  F  R  R  R  B  B  B
         L  L  L  F  F  F  R  R  R  B  B  B
         L  L  L  F  F  F  R  R  R  B  B  B
                  D  D  D
                  D  D  D
                  D  D  D"""

        @test displayed == reference
    end
end
