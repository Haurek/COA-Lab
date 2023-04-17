module imem(
    input   logic [5:0] A,
    output  logic [31:0] RD);
    
    logic [31:0] RAM[63:0];
    
    initial
//        $readmemh("memfile2.dat", RAM);
        $readmemh("memfile_io.dat", RAM);
//        $readmemh("memfile.dat", RAM);
    assign RD = RAM[A];
endmodule
