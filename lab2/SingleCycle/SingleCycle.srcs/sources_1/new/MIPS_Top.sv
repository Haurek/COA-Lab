module MIPS_Top(
    input   logic        CLK100MHZ,
    input   logic        BTNC,
    // --IO--
    input   logic        BTNL,
    input   logic        BTNR,
    input   logic [15:0] SW,
    output  logic [7:0]  AN,
    output  logic [6:0]  A2G,
    output  logic        DP);
    // --IO--
//    output  logic [31:0] WriteData, DataAdr,
//    output  logic        MemWrite);
    
    logic [31:0] PC, Instr;
//    logic [31:0] ReadData;
    // --IO--
    logic [31:0] ReadData, WriteData, DataAdr;
    logic Write;
    // --IO--
    
    MIPS mips(.clk(CLK100MHZ),
              .reset(BTNC),
              .pc(PC),
              .instr(Instr), 
//              .memwrite(MemWrite),
                // --IO--
              .memwrite(Write), 
                // --IO--
              .aluout(DataAdr),
              .writedata(WriteData), 
              .readdata(ReadData));
              
    imem imem(.A(PC[7:2]), 
              .RD(Instr));
    
    dMemoryDecoder dmd(.clk(CLK100MHZ),
                       .reset(BTNC),
                       // --IO--
                       .btnl(BTNL),
                       .btnr(BTNR),
                       .sw(SW),
                       .an(AN),
                       .a2g(A2G),
                       .dp(DP),
                       .addr(DataAdr[7:0]),                      
                       .writeEN(Write),
                        // --IO--
//                       .addr(DataAdr),
//                       .writeEN(MemWrite),
                       .writedata(WriteData),
                       .readdata(ReadData));
endmodule
