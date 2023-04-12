module dMemoryDecoder(
    input   logic clk, reset,
    // --IO--
    input   logic btnl, btnr,
    input   logic [15:0] sw,
    output  logic [7:0]  an,
    output  logic [6:0]  a2g,
    output  logic        dp,
    input   logic [7:0] addr,
    // --IO--
    input   logic writeEN,
//    input   logic [31:0] addr,
    input   logic [31:0] writedata,
    output  logic [31:0] readdata);
    
    // --IO
    logic pRead, pWrite, WE;
    logic [31:0] readdata1, readdata2;
    logic [11:0] led;
    
    always_comb
    begin
        if (addr[7])
        begin
            pWrite <= writeEN;
            WE     <= 1'b0;
        end
        else
        begin
            pWrite <= 1'b0;
            WE     <= writeEN;
        end
    end
    // --IO--
    
    mipsmem dmem(.clk(clk),                  
                 .A(addr),
                 // --IO--
                 .WE(WE),
                 // --IO--
//                 .WE(writeEN),
                 .WD(writedata), 
                 .RD(readdata)); 

//--IO--    
    IO io(.clk(clk),
          .reset(reset),
          .pRead(addr[7]),
          .pWrite(pWrite),
          .addr(addr[3:2]),
          .pWriteData(writedata[11:0]),
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
// --IO--                           
endmodule
