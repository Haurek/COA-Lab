module latch #(parameter N = 8)(
    input   logic clk, reset,
    input   logic en,
    input   logic [N-1:0] in,
    output  logic [N-1:0] out);
    
    always_ff @(posedge clk, posedge reset)
        if (reset)   out <= 'b0;
        else if (en) out <= in;
endmodule
