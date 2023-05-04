module MIPS_Top(
    input   logic   CLK100MHZ,
    input   logic   BTNC);
    
    logic [31:0] ReadData, WriteData, Adr;
    logic Write;
    
    MIPS mips(.clk(CLK100MHZ),
              .reset(BTNC),
              .memwrite(Write), 
              .adr(Adr),
              .writedata(WriteData), 
              .readdata(ReadData));
    
    Memory IDMemory(.clk(CLK100MHZ),
                    .A(Adr),                      
                    .WE(Write),
                    .WD(WriteData),
                    .RD(ReadData));
endmodule
