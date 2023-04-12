module MIPS(
    input   logic clk, reset,
    input   logic [31:0] instr,
    input   logic [31:0] readdata,
    output  logic [31:0] pc,
    output  logic [31:0] aluout, writedata,
    output  logic        memwrite );
    
    logic MemtoReg, Branch, PCSrc, Jump,
          ALUSrc, RegDest, RegWrite, ImmExt;
    logic ZF;    
    logic [2:0] ALUControl;
    
    controller c(.opcode(instr[31:26]),
                 .funct(instr[5:0]),
                 .zf(ZF), 
                 .memtoreg(MemtoReg),
                 .alusrc(ALUSrc),
                 .regdest(RegDest),
                 .regwrite(RegWrite),
                 .memwrite(memwrite),
                 .pcsrc(PCSrc),
                 .immext(ImmExt),
                 .jump(Jump),
                 .alucontrol(ALUControl));
                 
    datapath dp(.clk(clk),
                .reset(reset),
                .regwrite(RegWrite),
                .regdest(RegDest),
                .alusrc(ALUSrc),
                .memtoreg(MemtoReg),
                .pcsrc(PCSrc),
                .immext(ImmExt),
                .jump(Jump),
                .alucontrol(ALUControl),
                .readdata(readdata),               
                .instr(instr),
                .aluout(aluout),
                .zf(ZF),
                .pc(pc),
                .writedata(writedata));                
endmodule
