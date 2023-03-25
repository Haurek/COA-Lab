module MIPS_Top(
    input   logic        CLK100MHZ,
    input   logic        BUTTON_C,
    output  logic [31:0] WriteData, ALUOut,
    output  logic        MemWrite);
    
    logic [31:0] PC, Instr, ReadData;
    
    MIPS mips(.clk(CLK100MHZ),
              .reset(BUTTON_C),
              .pc(PC),
              .instr(Instr), 
              .memwrite(MemWrite), 
              .aluout(ALUOut), 
              .writedata(WriteData), 
              .readdata(ReadData));
              
    imem imem(.A(PC[7:2]), 
              .RD(instr));
              
    mipsmem dmem(.clk(CLK100MHZ),                  
                 .A(ALUOut),
                 .WD(writedata), 
                 .RD(ReadData)); 
endmodule
