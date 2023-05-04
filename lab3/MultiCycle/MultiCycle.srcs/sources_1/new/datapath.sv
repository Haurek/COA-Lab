module datapath(
    input   logic clk, reset,
    input   logic [2:0] alucontrol,
    input   logic [1:0] alusrcb, pcsrc,
    input   logic alusrca, irwrite, memtoreg,
                  pcen, regdst, regwrite, iord,
    input   logic [31:0] readdata,
    output  logic [31:0] adr,
    output  logic [5:0] funct, op,
    output  logic [31:0] writedata,
    output  logic zero);
    
    logic [31:0] PC, PCNext;
    
    logic [31:0] Instr, Data;
    
    logic [4:0]  WriteReg;
    logic [31:0] SignImm, SignImmSh;
    logic [31:0] RD1, RD2, A, B;
    
    logic [31:0] SrcA, SrcB;
    logic [31:0] ALUResult, ALUOut;
    
    // PC logic
    mux3 #(32)  pcmux(.select(pcsrc), .d0(ALUResult), .d1(ALUOut), .d2({PCNext[31:28], Instr[25:0], 2'b00}), .y(PCNext));
    latch #(32) pcreg(.clk(clk),
                      .reset(reset), 
                      .en(pcen), 
                      .in(PCNext),
                      .out(PC));
    mux2 #(32)  idmux(.select(iord), .t(ALUOut), .f(PC), .y(adr));
    
    // Memory logic
    latch #(32) instrreg (.clk(clk),
                          .reset(reset),
                          .en(irwrite),
                          .in(readdata),
                          .out(Instr));
    flopr #(32) datareg(.clk(clk),
                        .reset(reset),
                        .in(readdata),
                        .out(Data));
    
    // Register file logic 
    regfile     rf(.clk(clk),
                   .WE3(regwrite), 
                   .A1(Instr[25:21]), 
                   .A2(Instr[20:16]),
                   .A3(WriteReg),
                   .WD3(ALUOut),
                   .RD1(RD1),
                   .RD2(RD2));
    mux2 #(5)   wrmux(.select(regdst), .t(Instr[15:11]), .f(Instr[20:16]), .y(WriteReg));
    mux2 #(32)  resmux(.select(memtoreg), .t(Data), .f(ALUOut), .y(Result));
    signext     se(.in(Instr[15:0]), .out(SignImm));
    sl2         immsh(.in(SignImm), .out(SignImmSh));
    flopr #(32) rd1reg(.clk(clk), .reset(reset), .in(RD1), .out(A));
    flopr #(32) rd2reg(.clk(clk), .reset(reset), .in(RD2), .out(B));
    
    // ALU logic 
    mux2 #(32) srcamux(.select(alusrca), .t(A), .f(PC), .y(SrcA));
    mux4 #(32) srcbmux(.select(alusrcb), .d0(B), .d1(4), .d2(SignImm), .d3(SignImmSh), .y(SrcB));
    alu        alu(.srca(SrcA), 
                   .srcb(SrcB), 
                   .ctr(alucontrol), 
                   .out(ALUResult), 
                   .zf(zero));   
    flopr #(32) outreg(.clk(clk), .reset(reset), .in(ALUResult), .out(ALUOut));
                                        
endmodule
