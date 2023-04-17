module dMemoryDecoder(
    input   logic clk, reset,
    input   logic btnl, btnr,
    input   logic [15:0] sw,
    output  logic [7:0]  an,
    output  logic [6:0]  a2g,
    output  logic        dp,
    input   logic [7:0] addr,
    input   logic writeEN,
    input   logic [31:0] writedata,
    output  logic [31:0] readdata);
    
    logic pRead, pWrite, WE;
    logic [31:0] readdata1, readdata2;
    logic [11:0] led;
    
    assign pRead = addr[7];
    assign pWrite = addr[7] & writeEN;
    assign WE = writeEN & (addr[7] == 0);
    
    mipsmem dmem(.clk(clk),                  
                 .A(addr),
                 .WE(WE),
                 .RD(readdata1),
                 .WD(writedata)); 

    IO io(.clk(clk),
          .reset(reset),
          .pRead(pRead),
          .pWrite(pWrite),
          .addr(addr[3:2]),
          .pWriteData(writedata),
          .sw(sw),
          .btnl(btnl),
          .btnr(btnr),
          .led(led),
          .pReadData(readdata2));
    
    mux2 #(32) rdmux(.select(addr[7]), .t(readdata2), .f(readdata1), .y(readdata));
       
    x7Seg x7(.clk(clk),
             .reset(reset),
             .digit({sw, 4'b0000, led}),
             .a2g(a2g),
             .an(an),
             .dp(dp));          
                          
endmodule
