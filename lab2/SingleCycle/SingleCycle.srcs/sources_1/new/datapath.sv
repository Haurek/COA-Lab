module datapath(
    input   logic clk, reset,
    input   logic regwrite, regdest, jump, immext,
                  alusrc, memtoreg, pcsrc,
    input   logic [2:0] alucontrol,
    input   logic [31:0] readdata,
    input   logic [31:0] instr,
    output  logic zf, of, nf, cf,
    output  logic [31:0] pc, writedata, aluout);
    
    logic [4:0] WriteReg;
    logic [31:0] PCnext, PCnextBr, PCplus4, PCBranch;
    logic [31:0] SignImm, SignImmSh, ZeroImm, Imm;
    logic [31:0] SrcA, SrcB;
    logic [31:0] Result;
    
    // next PC logic
    flopr #(32) pcreg(.clk(clk), .reset(reset), .out(pc), .in(PCnext));                                         
    adder       pcadder1(.a(32'b100), .b(pc), .y(PCplus4));
    sl2         immsh(.in(SignImm), .out(SignImmSh));
    adder       pcadder2(.a(PCplus4), .b(SignImmSh), .y(PCBranch));                                     
    mux2 #(32)  pcbrmux(.select(pcsrc), .t(PCBranch), .f(PCplus4), .y(PCnextBr));
    mux2 #(32)  pcmux(.select(jump), .t({PCplus4[31:28], instr[25:0], 2'b00}), .f(PCnextBr), .y(PCnext)); 
    
    //register file logic
    regfile     rf(.clk(clk),
                   .E3(regwrite), 
                   .A1(instr[25:21]), 
                   .A2(instr[20:16]),
                   .A3(WriteReg),
                   .WD3(Result),
                   .RD1(SrcA),
                   .RD2(writedata));
    mux2 #(5)   wrmux(.select(regdest), .t(instr[15:11]), .f(instr[20:16]), .y(WriteReg)); 
    mux2 #(32)  resmux(.select(memtoreg), .t(readdata), .f(aluout), .y(Result));
    signext     se(.in(instr[15:0]), .out(SignImm));
    zeroext     ze(.in(instr[15:0]), .out(ZeroImm));
    mux2 #(32)  extmux(.select(immext), .t(ZeroImm), .f(SignImm), .y(Imm));
    
    // ALU logic
    mux2 #(32)  srcbmux(.select(alusrc), .t(Imm), .f(writedata), .y(SrcB));
    alu         alu(.srca(SrcA), 
                    .srcb(SrcB), 
                    .ctr(alucontrol), 
                    .out(aluout), 
                    .zf(zf),
                    .of(of),
                    .cf(cf),
                    .nf(nf));               
                                                            
endmodule
