module mipsmem(
    input   logic clk,
    input   logic [31:0] A, WD,
    input   logic WE,
    output  logic [31:0] RD);
    
    logic [31:0] RAM[63:0];
    
    assign RD = RAM[A[31:2]];
    
    always_ff @(posedge clk)
        if (WE)
            RAM[A[31:2]] <= WD;
            
endmodule
