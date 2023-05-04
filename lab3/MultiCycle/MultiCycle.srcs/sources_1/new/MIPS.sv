module MIPS(
    input   logic   clk, reset,
    input   logic [31:0] readdata,
    output  logic   memwrite,
    output  logic [31:0] adr,
    output  logic [31:0] writedata);
    
    logic [5:0] Funct, Op;
    logic Zero;
    
    logic [2:0] ALUControl;
    logic [1:0] ALUSrcB, PCSrc;
    logic ALUSrcA, IorD, IRWrite, MemtoReg,
          PCEN, RegDst, RegWrite;
          
    ControlUnit c(.clk(clk),
                  .funct(Funct),
                  .opcode(Op),
                  .reset(reset),
                  .zf(Zero),
                  .alucontrol(ALUControl),
                  .alusrcb(ALUSrcB),
                  .pcsrc(PCSrc),
                  .alusrca(ALUSrcA),
                  .iord(IorD),
                  .irwrite(IRWrite),
                  .memtoreg(MemtoReg),
                  .pcen(PCEN),
                  .regdst(RegDst),
                  .regwrite(RegWrite),
                  .memwrite(memwrite));
                
    datapath dp(.clk(clk),
                .reset(reset),
                .alucontrol(ALUControl),
                .alusrca(ALUSrcA),
                .alusrcb(ALUSrcB),
                .iord(IorD),
                .irwrite(IRWrite),
                .memtoreg(MemtoReg),  
                .pcen(PCEN),        
                .pcsrc(PCSrc),
                .readdata(readdata),
                .regdst(RegDst),
                .regwrite(RegWrite),
                .adr(adr),
                .funct(Funct),
                .op(Op),
                .writedata(writedata),
                .zero(Zero));
                
endmodule
