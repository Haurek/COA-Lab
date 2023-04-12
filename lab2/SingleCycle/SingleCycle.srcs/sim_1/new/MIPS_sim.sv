module MIPS_sim();
    logic   CLK100MHZ, BTNC;
    logic [31:0] DataAdr, WriteData;
    logic MemWrite;
//    logic   BTNL, BTNR;
//    logic   [15:0] SW;
//    logic   [6:0] A2G;
//    logic   [7:0] AN;
//    logic         DP;
    MIPS_Top top(.CLK100MHZ(CLK100MHZ),
                 .BTNC(BTNC),
                 .DataAdr(DataAdr),
                 .WriteData(WriteData),
                 .MemWrite(MemWrite));
//                 .BTNL(BTNL),
//                 .BTNR(BTNR),
//                 .SW(SW),
//                 .AN(AN),
//                 .A2G(A2G),
//                 .DP(DP));
    initial
    begin
        BTNC <= 1; # 22; BTNC <= 0;
//        #0; BTNC <= 1;
//        #2; BTNC <= 0;
//        #2; BTNL <= 1; BTNR <= 1;
//        #2; SW <= 16'b00000100_00001000;
    end
    
    always
    begin
        CLK100MHZ <= 1; # 5; CLK100MHZ <= 0; # 5;
    end
    
//    always @(negedge CLK100MHZ)
//    begin
//        if (MemWrite)
//        begin
//            if (DataAdr === 84 & WriteData === 7)
//            begin
//                $display("Simlation succeeded");
//                $stop;
//            end
//            else if (DataAdr !== 80)
//            begin
//                $display("Simlation failed");
//                $stop;
//            end
//        end
//    end
//    logic clk;
//    logic reset;
//    logic [31:0] writedata, dataadr;
//    logic        memwrite;
//    MIPS_Top top(.CLK100MHZ(clk),
//                 .BTNC(reset),
//                 .SW(SW),
//                 .AN(AN),
//                 .A2G(A2G),
//                 .DP(DP));
endmodule
