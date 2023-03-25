module mux2#(parameter N = 32)(
    input   logic select,
    input   logic [N - 1:0] t, f,
    output  logic [N - 1:0] y);
    
    assign y = select ? t : f;
endmodule
