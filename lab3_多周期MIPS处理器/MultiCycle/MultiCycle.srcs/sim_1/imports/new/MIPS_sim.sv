module MIPS_sim();
    logic CLK100MHZ, BTNC;
    MIPS_Top top(.CLK100MHZ(CLK100MHZ),
                 .BTNC(BTNC));

    initial
    begin
        BTNC <= 1; # 22; BTNC <= 0;
    end
    
    always
    begin
        CLK100MHZ <= 1; # 5; CLK100MHZ <= 0; # 5;
    end
    
endmodule
