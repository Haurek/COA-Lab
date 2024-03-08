module controller(
    input   logic [5:0] funct, opcode,
    input   logic       zf,
    output  logic [2:0] alucontrol,
    output  logic       memwrite, regwrite, 
                        regdest, alusrc, immext,
                        memtoreg, pcsrc, jump                                    
    );
    
    logic branch, branchbne;
    logic [2:0] ALUOp;

    maindec md(.op(opcode),
               .memwrite(memwrite),
               .regwrite(regwrite),
               .regdest(regdest),
               .memtoreg(memtoreg),
               .branch(branch),
               .branchbne(branchbne),
               .immext(immext),
               .jump(jump),
               .alusrc(alusrc),
               .aluop(ALUOp));
    
    aludec ad(.aluop(ALUOp),
              .f(funct),
              .aluctrl(alucontrol));       
    
    assign pcsrc = (branch & zf) | (branchbne & (~zf));                 
        
endmodule
