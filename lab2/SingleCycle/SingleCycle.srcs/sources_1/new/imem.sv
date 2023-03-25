module imem(
    input   logic [4:0] A,
    output  logic [31:0] RD);
    
    logic [31:0] RAM[63:0];
    
    initial
        begin 
            $readmemh("memfile.dat", RAM);
        end
        
        assign rd = RAM[A];
endmodule
