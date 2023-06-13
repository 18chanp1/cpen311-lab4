/* 
A module to generate a pseudo-random sequence as defined in the 
lab manual using a secret key for the RC4 algorithm. 
*/
module shuffle_arr
#
(
    /*Due to optimizations with mod256, DATA_WIDTH is not changeable*/
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter ADDR_MAX = 255,   /*Highest possible address of the pseudorandom sequence.*/
    parameter SECRET_LEN = 24  /*Must be multiple of 8, i.e. byte-sized. Length of secret*/
)
(
    output logic [ADDR_WIDTH - 1:0] address,        /*Memory control signals*/
    output logic [DATA_WIDTH - 1:0] data,
    input logic [DATA_WIDTH - 1:0]  q,         
    output logic                    wren,            
    input logic                     clk,
    input logic                     rst,
    input logic [SECRET_LEN - 1:0]  secret,        /*Secret key input*/
    input logic                     start,
    output logic                    finish
    /*Signals should by synchronous*/
);

    logic [DATA_TOP:0] state;
	logic [ADDR_WIDTH - 1:0] i, j;
    logic [DATA_WIDTH - 1:0] si;

    localparam ADDR_TOP = ADDR_WIDTH + 5 - 1;
    localparam DATA_TOP = ADDR_TOP + DATA_WIDTH;
    localparam SECRET_BYTE_LEN = SECRET_LEN >> 3;

    assign finish =     state[0];
    assign wren =       state[1];
    /*state ID =        state[4:2]*/
    assign address =    state[ADDR_TOP:5];
    assign data =       state[DATA_TOP:ADDR_TOP + 1];

    parameter READY =           5'b000_00;
    parameter GET_SI =          5'b001_00;
    parameter COMPUTE_J =       5'b010_00;
    parameter GET_SJ =          5'b110_00;
    parameter WRITE_SI_TO_SJ =  5'b101_10;
    parameter WRITE_SJ_TO_SI =  5'b011_10;
    parameter DONE =            5'b100_01;

    always_ff @(posedge clk) begin
        if(rst) begin
            state   <= 'b0;
            i       <= 'b0;
            j       <= 'b0;
            si      <= 'b0;
        end 
        else begin
            case(state[4:0])
                READY:              state <= start ? {{(DATA_WIDTH){1'bx}}, i, GET_SI} : state;
                GET_SI:             state <= {{(DATA_WIDTH + ADDR_WIDTH){1'bx}}, COMPUTE_J}; //q=xx;
                COMPUTE_J: 
                begin //q==si
                    si <= q;
                    j <= j + q + secret[(((SECRET_BYTE_LEN - 1) -  (i % 3)) * 8) +: 8];
                    state[DATA_TOP: ADDR_TOP + 1] <= 'bx;
                    state[ADDR_TOP:5] <= j + q + secret[(((SECRET_BYTE_LEN - 1) -  (i % 3)) * 8) +: 8];
                    state[4:0] <= GET_SJ;
                end
                GET_SJ:             state <= {si, j, WRITE_SI_TO_SJ}; // q = xx
                WRITE_SI_TO_SJ:     state <= {q, i, WRITE_SJ_TO_SI}; //q=sj
                WRITE_SJ_TO_SI: begin
                    if (i >= ADDR_MAX) 
                    begin
                        state <= {{(DATA_WIDTH){1'bx}}, i, DONE};
                    end
                    else 
                    begin //q==xx
                        i                               <= i+1;
                        state[DATA_TOP:ADDR_TOP + 1]    <= {(DATA_WIDTH){1'bx}};
                        state[ADDR_TOP:5]               <= i+1;
                        state[4:0]                      <= GET_SI;
                    end
                end
                DONE:               state <= state;
            endcase
        end
    end
endmodule


