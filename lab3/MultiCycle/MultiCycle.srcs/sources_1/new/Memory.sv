module Memory(
    input   logic      clk,
    input   logic       WE,
    input   logic [31:0] A,
    input   logic [31:0] WD,
    output  logic [31:0] RD);
    
    logic [31:0] RAM[1023:0];
    
    initial
        $readmemh("memfile.dat", RAM);
    
    assign RD = RAM[A[31:2]];
    always_ff @(posedge clk)
        if (WE) RAM[A[31:2]] <= WD;
        
endmodule
