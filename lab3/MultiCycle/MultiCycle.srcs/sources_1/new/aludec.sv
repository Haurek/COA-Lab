module aludec(
    input   logic [2:0] aluop,
    input   logic [5:0] f,
    output  logic [2:0] aluctrl);
    
    always_comb
    case(aluop)
        3'b000: aluctrl <= 3'b010; // ADD
        3'b001: aluctrl <= 3'b110; // SUB
        3'b010: case(f)
            6'b000000: aluctrl <= 3'b010; // nop
            6'b100000: aluctrl <= 3'b010; // add
            6'b100010: aluctrl <= 3'b110; // sub
            6'b100100: aluctrl <= 3'b000; // and
            6'b100101: aluctrl <= 3'b001; // or
            6'b101010: aluctrl <= 3'b111; // slt
            default:   aluctrl <= 3'bxxx; // ???
            endcase
        3'b100:  aluctrl <= 3'b000; // andi
        3'b011:  aluctrl <= 3'b001; // ori
        3'b111:  aluctrl <= 3'b111; // slt
        default: aluctrl <= 3'bxxx; // ??? 
    endcase            
            
endmodule
