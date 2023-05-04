module ControlUnit(
    input   logic clk, reset,
    input   logic [5:0] funct, opcode,
    input   logic zf, 
    output  logic [2:0] alucontrol,
    output  logic [1:0] alusrcb, pcsrc,
    output  logic alusrca, irwrite, memtoreg,
                  pcen, regdst, regwrite, iord,
    output  logic memwrite);
    
    logic branch, branchbne;
    logic pcwrite;
    logic [2:0] aluop;
    
    maindec md(.clk(clk),
               .reset(reset),
               .op(opcode),
               .memwrite(memwrite),
               .regwrite(regwrite),
               .regdst(regdst),
               .memtoreg(memtoreg),
               .branch(branch),
               .branchbne(branchbne),
               .alusrca(alusrca),
               .alusrcb(alusrcb),
               .pcsrc(pcsrc),
               .aluop(aluop),
               .pcwrite(pcwrite),
               .irwrite(irwrite),
               .iord(iord));
               
    aludec ad(.aluop(aluop),
              .f(funct),
              .aluctrl(alucontrol));       
    
    assign pcen = ((branch & zf) | (branchbne & (~zf))) | pcwrite; 
endmodule
