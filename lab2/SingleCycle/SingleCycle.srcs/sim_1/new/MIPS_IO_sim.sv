module MIPS_IO_sim();
    logic   CLK100MHZ, BTNC;
    logic   BTNL, BTNR;
    logic   [15:0] SW;
    logic   [6:0] A2G;
    logic   [7:0] AN;
    logic         DP;
    
    MIPS_Top top(.CLK100MHZ(CLK100MHZ),
                 .BTNC(BTNC),
                 .BTNL(BTNL),
                 .BTNR(BTNR),
                 .SW(SW),
                 .AN(AN),
                 .A2G(A2G),
                 .DP(DP));
    initial
    begin
        #0; BTNC <= 1;
        #2; BTNC <= 0;
        #2; BTNL <= 1; BTNR <= 1;
        #2; SW <= 16'b00000100_00001000;
    end
    
    always
    begin
        CLK100MHZ <= 1; # 5; CLK100MHZ <= 0; # 5;
    end
    
endmodule
