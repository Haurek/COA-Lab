module x7Seg(
    input   logic clk, reset,
    input   logic [31:0] digit,
    output  logic [6:0] a2g,
    output  logic [7:0] an,
    output  logic       dp);
    
    logic [2:0] s;
    logic [19:0] clkdiv;
    logic [4:0] data;
    
    assign dp = 1;
    assign s = clkdiv[19:17];
    always_comb
        case(s)
            0:  
            begin
                an   = 8'b11111110;
                data = {1'b0, digit[3:0]};
            end 
            1:
            begin
                an   = 8'b11111101;
                data = {1'b0, digit[7:4]};
            end   
            2:
            begin
                an   = 8'b11111011;
                data = {1'b0, digit[11:8]};
            end 
            3: // = 
            begin
                an   = 8'b11110111;
                data = {1'b1, digit[15:12]};// =
            end 
            4: 
            begin
                an   = 8'b11101111;
                data = {1'b0, digit[19:16]};
            end 
            5: 
            begin
                an   = 8'b11011111;
                data = {1'b0, digit[23:20]};
            end  
            6:  
            begin
                an   = 8'b10111111;
                data = {1'b0, digit[27:24]};
            end 
            7: 
            begin
                an   = 8'b01111111;
                data = {1'b0, digit[31:28]};
            end 
            default: an = 8'b11111111;
        endcase
        
    always @(posedge clk, posedge reset)
        if (reset == 1) clkdiv <= 0;
        else clkdiv <= clkdiv + 1;
        
    Hex7Seg s7(.data(digit), .a2g(a2g));         
endmodule
