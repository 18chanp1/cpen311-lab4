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
    parameter MESSAGE_LEN = 32; /* in bytes*/
)
(
    input logic [DATA_WIDTH - 1:0] msg_q,           /*ROM message control signal*/
    output logic [ADDR_WIDTH - 1:0] msg_addr,
    output logic [ADDR_WIDTH - 1:0] result_addr,    /*RAM decrypted message control*/
    output logic [DATA_WIDTH - 1:0] result_data,
    output logic                    result_wren,
    output logic [ADDR_WIDTH - 1:0] s_addr,        /*scratch control signals*/
    output logic [DATA_WIDTH - 1:0] s_data,
    input logic [DATA_WIDTH - 1:0]  s_q,         
    output logic                    s_wren,    
    input logic                     clk,
    output logic                    start,
    output logic                    finish
    /* Signals synchronous*/
);

    logic [46:0] state;

    assign finish = state[0];
    assign result_wren = state[1];
    assign s_wren = state[2];
    assign state_ID = state[6:3];
    /* variable by param*/
    assign msg_addr = state[14:7];
    assign result_addr = state[22:15];
    assign result_data = state[30:23];
    assign s_addr = state[38:31];
    assign s_data = state[46:39];

    logic[7:0] i, j, si, sj, k;  //k can be smaller.

    parameter READY =   7'b0000_000;
    parameter LOAD_SI = 7'b001_000;
    parameter COMPUTE_J = 7'b0010_000;
    parameter LOAD_SJ = 7'b0011_000;
    parameter WRITE_SI_TO_SJ = 7'b0100_100;
    parameter WRITE_SJ_TO_SI = 7'b0101_100;
    parameter GET_F_ENCR = 7'b0110_000;
    parameter COMPUTE_DECRYPT = 7'b0111_000;
    parameter WRITEOUT = 7'b1000_010;
    parameter DONE = 7'b1001_001;

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
                READY: 
                begin
                    if(start) 
                    begin
                        i <= i + 1;
                        state[38:31] <= i + 1; //s_addr
                        state[6:0] <= LOAD_SI;
                    end
                    else state <= state;
                end
                LOAD_SI: //s_q=xx
                begin
                    state[6:0] <= COMPUTE_J;
                end
                COMPUTE_J: //s_q=s[i]
                begin
                    j <= j + s_q;
                    si <= s_q;
                    state[38:31] <= j + s_q; //s_addr = new j
                    state[6:0] <= LOAD_SJ;
                end
                LOAD_SJ: //s_q = xx
                begin
                    state[46:39] <= si;        //s_data = s[i]
                    state[38:31] <= j;         //s_addr = j
                    state[6:0] <= WRITE_SI_TO_SJ;
                end
                WRITE_SI_TO_SJ: //s_q = s[j];
                begin
                    sj <= s_q;
                    state[46:39] <= s_q;    //s_data = s[j]
                    state[38:31] <= i;      //s_addr = i
                    state[6:0] <= WRITE_SJ_TO_SI;
                end
                WRITE_SJ_TO_SI: //s_q = xx;
                begin
                    state[38:31] <= si + sj; //s_addr = si + sj;
                    state[14:7] <= k;        //msg_addr = k;
                    state[6:0] <= GET_F_ENCR;
                end
                GET_F_ENCR: //s_q = xx;
                begin
                    state[6:0] <= COMPUTE_DECRYPT;
                end
                COMPUTE_DECRYPT: //s_q = s[s[i] + s[j]]
                begin
                    state[30:23] <= s_q ^ msg_q //result_data
                    state[22:15] <= k //result_addr
                    state[6:0] <= WRITEOUT
                WRITEOUT: 
                begin
                    if(k < (MESSAGE_LEN - 1))
                        i <= i + 1;
                        k <= k + 1;
                        state[38:31] <= i + 1; //s_addr
                        state[6:0] <= LOAD_SI
                    else state[6:0] <= DONE;
                end
            endcase
        end
    end
endmodule

                    


                

    


