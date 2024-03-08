module maindec(
    input   logic [5:0] op,
    output  logic memwrite, regwrite, regdest, immext,
                  alusrc, memtoreg, branch, branchbne, jump,
    output  logic [2:0] aluop);
    
    logic [11:0] controls;
    
    assign {regwrite, regdest, alusrc, branch, 
            memwrite, memtoreg, jump, aluop, 
            immext, branchbne} = controls;
    
    always_comb            
    case(op)
        // aluop:
        // 010 -> R 000 -> ADD 001 -> SUB 
        // 001 -> addi 100 -> andi 011 -> ori 111 -> slti
        6'b000000: controls <= 12'b110000001000;  // R
        6'b001000: controls <= 12'b101000000000;  // addi
        6'b001100: controls <= 12'b101000010010;  // andi
        6'b001101: controls <= 12'b101000001110;  // ori
        6'b001010: controls <= 12'b101000011100;  // slti
        6'b100011: controls <= 12'b101001000000;  // lw
        6'b101011: controls <= 12'b0x101x000000;  // sw
        6'b000100: controls <= 12'b0x010x000100;  // beq
        6'b000101: controls <= 12'b000000000101;  // bne
        6'b000010: controls <= 12'b0xxx0x1xxx00;  // j
        default:   controls <= 12'bxxxxxxxxxxxx;  // ???
    endcase     
       
endmodule
