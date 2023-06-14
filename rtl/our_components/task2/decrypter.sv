/* 
A module to decrypt the RC4 scheme, using a pseudorandom scratchpad
as prepared by shuffle_arr, using the lab manual's algorithm. 
*/
module decrypter
#
(
    /*Due to optimizations with mod256, DATA_WIDTH is not changeable*/
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter MESSAGE_LEN = 32 /* in bytes*/
)
(
    input logic [DATA_WIDTH - 1:0]  msg_q,          /*ROM encrypted message control signal*/
    output logic [ADDR_WIDTH - 1:0] msg_addr,
    output logic [ADDR_WIDTH - 1:0] result_addr,    /*RAM decrypted message control*/
    output logic [DATA_WIDTH - 1:0] result_data,
    output logic                    result_wren,
    output logic [ADDR_WIDTH - 1:0] s_addr,         /*scratch control signals*/
    output logic [DATA_WIDTH - 1:0] s_data,
    input logic [DATA_WIDTH - 1:0]  s_q,         
    output logic                    s_wren,    
    input logic                     clk,            /*FSM Control signals*/
    input logic                     rst,
    input logic                     start,
    output logic                    finish
    /* Signals synchronous*/
);

    localparam MSG_ADDR_T =     ADDR_WIDTH + 7 - 1;         //default 14
    localparam RESULT_ADDR_T =  MSG_ADDR_T + ADDR_WIDTH;    //default 22
    localparam RESULT_DATA_T =  RESULT_ADDR_T + DATA_WIDTH; //default 30
    localparam S_ADDR_T =       RESULT_DATA_T + ADDR_WIDTH  //default 38
    localparam S_DATA_T =       S_ADDR_T + DATA_WIDTH       //default 46

    logic [S_DATA_T:0] state;
    
    assign finish =         state[0];
    /* RAM write enables */
    assign result_wren =    state[1];
    assign s_wren =         state[2];
    /*assign state_ID =     state[6:3];*/
    /* variable length params*/
    /* Encrypted message ROM control*/
    assign msg_addr =       state[MSG_ADDR_T:7];
    /* Decrypted message RAM control*/
    assign result_addr =    state[RESULT_ADDR_T:MSG_ADDR_T + 1];
    assign result_data =    state[RESULT_DATA_T:RESULT_ADDR_T + 1];
    /* Scratchpad RAM controls*/
    assign s_addr =         state[S_ADDR_T:RESULT_DATA_T + 1];
    assign s_data =         state[S_DATA_T:S_ADDR_T + 1];

    /*registers to store variables*/
    logic[ADDR_WIDTH - 1:0] i, j;
    logic[DATA_WIDTH - 1:0] si, sj;
    logic [$clog2(MESSAGE_LEN) - 1 : 0] k;

    /* State encodings*/
    parameter READY =           7'b0000_000;
    parameter LOAD_SI =         7'b0001_000;
    parameter COMPUTE_J =       7'b0010_000; /* Wait for S[i] to be retrieved*/
    parameter LOAD_SJ =         7'b0011_000;
    parameter WRITE_SI_TO_SJ =  7'b0100_100;
    parameter WRITE_SJ_TO_SI =  7'b0101_100;
    parameter GET_F_ENCR =      7'b0110_000;
    parameter COMPUTE_DECRYPT = 7'b0111_000;/*Wait for S[s[i]+s[j]] to be retrieved*/
    parameter WRITEOUT =        7'b1000_010;
    parameter DONE =            7'b1001_001;

    always_ff @(posedge clk) begin
        if(rst)
        begin
            state <=    'b0;
            i <=        'b0;
            j <=        'b0;
            si <=       'b0;
            sj <=       'b0;
            k <=        'b0;
        end
        else
        begin
            case (state[6:0])
                READY: //s_q = xx
                begin
                    if(start) 
                    begin
                        i                                   <= i + 1;
                        state[S_ADDR_T:RESULT_DATA_T + 1]   <= i + 1;   //s_addr
                        state[6:0]                          <= LOAD_SI;
                    end
                    else state                              <= state;
                end
                LOAD_SI: //s_q=xx
                begin
                    state[6:0]                              <= COMPUTE_J;
                end
                COMPUTE_J: //s_q = s[i]
                begin
                    j                                       <= j + s_q;
                    si                                      <= s_q;
                    state[S_ADDR_T:RESULT_DATA_T + 1]       <= j + s_q; //s_addr = new j
                    state[6:0]                              <= LOAD_SJ;
                end
                LOAD_SJ: //s_q = xx
                begin
                    state[S_DATA_T:S_ADDR_T + 1]            <= si;      //s_data = s[i]
                    state[S_ADDR_T:RESULT_DATA_T + 1]       <= j;       //s_addr = j
                    state[6:0]                              <= WRITE_SI_TO_SJ;
                end
                WRITE_SI_TO_SJ: //s_q = s[j];
                begin
                    sj                                      <= s_q;
                    state[S_DATA_T:S_ADDR_T + 1]            <= s_q;    //s_data = s[j]
                    state[S_ADDR_T:RESULT_DATA_T + 1]       <= i;      //s_addr = i
                    state[6:0]                              <= WRITE_SJ_TO_SI;
                end
                WRITE_SJ_TO_SI: //s_q = xx;
                begin
                    state[S_ADDR_T:RESULT_DATA_T + 1]       <= si + sj; //s_addr = si + sj;
                    state[MSG_ADDR_T:7]                     <= k;       //msg_addr = k;
                    state[6:0]                              <= GET_F_ENCR;
                end
                GET_F_ENCR: //s_q = xx;
                begin
                    state[6:0]                              <= COMPUTE_DECRYPT;
                end
                COMPUTE_DECRYPT: //s_q = s[s[i] + s[j]], msg_q = msg[k]
                begin
                    state[RESULT_DATA_T:RESULT_ADDR_T + 1]  <= s_q ^ msg_q; //result_data
                    state[RESULT_ADDR_T:MSG_ADDR_T + 1]     <= k;           //result_addr
                    state[6:0]                              <= WRITEOUT;
				end
                WRITEOUT: 
                begin
                    if(k < (MESSAGE_LEN - 1))
						begin
                            i                                   <= i + 1;
                            k                                   <= k + 1;
                            state[S_ADDR_T:RESULT_DATA_T + 1]   <= i + 1;  //s_addr
                            state[6:0]                          <= LOAD_SI;
						end
                    else state[6:0]                             <= DONE;
                end
            endcase
        end
    end
endmodule