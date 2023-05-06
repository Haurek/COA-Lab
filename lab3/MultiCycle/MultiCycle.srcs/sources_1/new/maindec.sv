module maindec(
    input   logic clk, reset,
    input   logic [5:0] op,
    output  logic pcwrite, memwrite, irwrite, regwrite, branchbne,
                  alusrca, branch, iord, memtoreg, regdst,
    output  logic [1:0] alusrcb, pcsrc,
    output  logic [2:0] aluop);
    
    localparam FETCH   = 5'b00000;
    localparam DECODE  = 5'b00001;
    localparam MEMADR  = 5'b00010;
    localparam MEMRD   = 5'b00011;
    localparam MEMWB   = 5'b00100;
    localparam MEMWR   = 5'b00101;
    localparam RTYPEEX = 5'b00110;
    localparam RTYPEWB = 5'b00111;
    localparam BEQEX   = 5'b01000;
    localparam ADDIEX  = 5'b01001;
    localparam ADDIWB  = 5'b01010;
    localparam JEX     = 5'b01011;
    localparam ANDIEX  = 5'b01100;
    localparam ANDIWB  = 5'b01101;
    localparam ORIEX   = 5'b01110;
    localparam ORIWB   = 5'b01111;
    localparam BNEEX   = 5'b10000;
    localparam SLTIEX  = 5'b10001;
    localparam SLTIWB  = 5'b10010;
    
    localparam LW      = 6'b100011;
    localparam SW      = 6'b101011;
    localparam RTYPE   = 6'b000000;
    localparam BEQ     = 6'b000100;
    localparam BNE     = 6'b000101;
    localparam ADDI    = 6'b001000;
    localparam ANDI    = 6'b001100;
    localparam ORI     = 6'b001101;
    localparam SLTI    = 6'b001010;
    localparam J       = 6'b000010;
    
    logic [4:0]  state, nextstate;
    logic [16:0] controls;
    
    always_ff @(posedge clk or posedge reset)
        if (reset) state <= FETCH;
        else       state <= nextstate;
        
    always_comb
        case(state)
            FETCH:   nextstate = DECODE;
            DECODE: 
            case(op)
                LW:      nextstate = MEMADR;
                SW:      nextstate = MEMADR;
                RTYPE:   nextstate = RTYPEEX;
                BEQ:     nextstate = BEQEX;
                BNE:     nextstate = BNEEX;
                ANDI:    nextstate = ANDIEX;
                ORI:     nextstate = ORIEX;
                ADDI:    nextstate = ADDIEX;
                SLTI:    nextstate = SLTIEX;
                J:       nextstate = JEX;
                default: nextstate = 5'bx;
            endcase
            MEMADR:
            case(op)
                LW:      nextstate = MEMRD;
                SW:      nextstate = MEMWR;
                default: nextstate = 5'bx;
            endcase
            MEMRD:   nextstate = MEMWB;
            MEMWB:   nextstate = FETCH;
            MEMWR:   nextstate = FETCH;
            RTYPEEX: nextstate = RTYPEWB;
            RTYPEWB: nextstate = FETCH;
            BEQEX:   nextstate = FETCH;
            BNEEX:   nextstate = FETCH;
            ANDIEX:  nextstate = ANDIWB;
            ANDIWB:  nextstate = FETCH;
            ORIEX:  nextstate  = ORIWB;
            ORIWB:  nextstate  = FETCH;
            ADDIEX:  nextstate = ADDIWB;
            ADDIWB:  nextstate = FETCH;
            SLTIEX:  nextstate = SLTIWB;
            SLTIWB:  nextstate = FETCH;
            JEX:     nextstate = FETCH;
            default: nextstate = 5'bx;
        endcase
        
        assign {pcwrite, memwrite, irwrite, regwrite, 
                alusrca, branch, iord, memtoreg, regdst,
                alusrcb, pcsrc, aluop, branchbne} = controls;
        
        always_comb
            case(state)
                FETCH:    controls = 17'b10100000001000000;
                DECODE:   controls = 17'b00000000011000000;
                MEMADR:   controls = 17'b00001000010000000;
                MEMRD:    controls = 17'b00000010000000000;
                MEMWB:    controls = 17'b00010001000000000;
                MEMWR:    controls = 17'b01000010000000000;
                RTYPEEX:  controls = 17'b00001000000000100;
                RTYPEWB:  controls = 17'b00010000110000000;
                BEQEX:    controls = 17'b00001100000010010;
                BNEEX:    controls = 17'b00001100000010011;
                ADDIEX:   controls = 17'b00001000010000000;
                ADDIWB:   controls = 17'b00010000000000000;
                ANDIEX:   controls = 17'b00001000010001000;
                ANDIWB:   controls = 17'b00010000000000000;
                ORIEX:    controls = 17'b00001000010000110;
                ORIWB:    controls = 17'b00010000000000000;
                SLTIEX:   controls = 17'b00001000010001110;
                SLTIWB:   controls = 17'b00010000000000000;
                JEX:      controls = 17'b10000000000100000;
                default:  controls = 17'bx;
            endcase     
                            
endmodule