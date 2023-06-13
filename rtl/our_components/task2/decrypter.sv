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

    


