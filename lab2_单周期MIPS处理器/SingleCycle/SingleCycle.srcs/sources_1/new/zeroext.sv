module zeroext(
    input   logic [15:0] in,
    output  logic [31:0] out);
    
    assign out = {{16{1'b0}}, in};
    
endmodule
