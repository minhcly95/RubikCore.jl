@testset "Display" begin
    function test_net(cube, ref)
        io = IOBuffer()
        show(io, MIME"text/plain"(), cube)
        str = String(take!(io))
        # Strip all escape sequences and non-breaking spaces
        str = replace(str, r"\e\[.+?m" => "")
        str = replace(str, Char(160) => " ")
        tokens = split(str)[3:end]
        ref_tokens = split(ref)
        @test tokens == ref_tokens
    end

    @testset "Text display" begin
        test_net(Cube(), """
                     U  U  U
                     U  U  U
                     U  U  U
            L  L  L  F  F  F  R  R  R  B  B  B
            L  L  L  F  F  F  R  R  R  B  B  B
            L  L  L  F  F  F  R  R  R  B  B  B
                     D  D  D
                     D  D  D
                     D  D  D
            """)
        test_net(AS[1], """
                     B  D  D                    
                     B  L  F                    
                     R  L  L                    
            R  L  F  D  D  B  D  R  B  R  B  U  
            L  U  L  U  B  D  F  D  B  U  F  F  
            L  R  L  U  U  F  D  B  R  F  D  U  
                     F  F  L                    
                     U  R  R                    
                     B  R  U                
            """)
        test_net(AS[2], """
                     R  R  B                    
                     D  L  B                    
                     L  F  F                    
            F  F  B  D  L  L  D  R  U  R  F  U  
            D  F  U  R  U  D  B  B  B  U  D  L  
            R  R  L  B  F  R  D  B  F  L  L  D  
                     U  U  F                    
                     D  R  L                    
                     B  U  U                                
            """)
        test_net(AS[3], """
                     F  L  B                    
                     B  L  R                    
                     U  U  U                    
            L  D  R  B  L  F  R  U  L  U  D  U  
            F  B  F  D  D  L  B  F  U  F  U  L  
            F  R  D  L  R  D  R  B  B  L  U  D  
                     F  D  B                    
                     F  R  R                    
                     R  B  D                              
            """)
        test_net(AS[4], """
                     L  D  B                    
                     D  D  D                    
                     F  U  U                    
            D  R  U  L  R  R  B  L  R  D  F  B  
            L  F  F  L  L  L  U  B  U  B  R  B  
            R  F  D  L  R  F  R  D  L  B  R  U  
                     F  B  D                    
                     U  U  B                    
                     F  F  U                               
            """)
        test_net(AS[5], """
                     F  U  L                    
                     R  U  L                    
                     R  D  F                    
            U  F  F  D  R  L  D  B  U  B  F  R  
            L  L  L  D  F  U  B  R  U  R  B  F  
            D  D  U  F  D  U  B  R  B  L  U  B  
                     L  F  R                    
                     B  D  B                    
                     R  L  D                       
            """)
    end
end
