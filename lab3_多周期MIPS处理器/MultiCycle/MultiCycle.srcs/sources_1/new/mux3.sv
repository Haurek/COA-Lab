module mux3 #(parameter N = 32)(
    input   logic [1:0] select,
    input   logic [N - 1:0] d0, d1, d2, 
    output  logic [N - 1:0] y);

    assign y = select[1] ? d2 : (select[0] ? d1 : d0);
        
endmodule
