module alu(
    input   logic [31:0] srca, srcb,
    input   logic [2:0] ctr,
    output  logic [31:0] out,
    output  logic zf, cf, nf, of);
    
    logic [32:0] temp;           // reg [4:0] temp;
    
    always_comb
    begin
        cf = 0;
        of = 0;
        temp = 33'b0;
        case(ctr)
            3'b000: out = srca & srcb; // AND
            3'b001: out = srca | srcb; // OR
            3'b010:         // ADD
                begin
                    temp = {1'b0, srca} + {1'b0, srcb};
                    out = temp[31:0];
                    cf = temp[32];  
                    of = out[31] ^ srca[31] ^ srcb[31] ^ cf;
                end
                    
            3'b101:         // SUB
                begin
                    temp = {1'b0, srca} - {1'b0, srcb};
                    out = temp[31:0];
                    cf = temp[32];
                    of = out[31] ^ srca[31] ^ srcb[31] ^ cf;
                end
            3'b111:         // SLT
                begin
                    out = srca < srcb ? 1 : 0;
                end
        endcase
        nf = out[31];
        if(out == 32'b0) zf = 1;
        else             zf = 0;
    end
    
endmodule
