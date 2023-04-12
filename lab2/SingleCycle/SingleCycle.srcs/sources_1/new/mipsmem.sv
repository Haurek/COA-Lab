module mipsmem(
    input   logic clk,
    input   logic [31:0] WD,
//    input   logic [31:0] A,
    //--IO--
    input   logic [7:0] A,
    //--IO--
    input   logic WE,
    output  logic [31:0] RD);
    
//    logic [31:0] RAM[63:0];
//    assign RD = RAM[A[31:2]];
//    always_ff @(posedge clk)
//        if (WE)
//            RAM[A[31:2]] <= WD;

//--IO--
    logic [31:0] RAM[255:0];
    
    assign RD = RAM[A];
    
    always_ff @(posedge clk)
        if (WE)
            RAM[A] <= WD;
//--IO--            
endmodule
