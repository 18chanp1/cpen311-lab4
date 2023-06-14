/*
Rewritten version of KSA module in systemverilog instead of VHDL
*/
`default_nettype none

module ksa 
(
    input logic         CLOCK_50,
    input logic [3:0]   KEY,
    input logic [9:0]   SW,
    output logic [9:0]  LEDR,
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5
); 
    logic hex0in, hex1in, hex2in, hex3in, hex4in, hex5in;
    
    SevenSegmentDisplayDecoder ksa_sseg_decoder0
    (
        .ssOut(HEX0),
        .nIn(hex0in)
    );

    SevenSegmentDisplayDecoder ksa_sseg_decoder1
    (
        .ssOut(HEX1),
        .nIn(hex1in)
    );

    SevenSegmentDisplayDecoder ksa_sseg_decoder2
    (
        .ssOut(HEX2),
        .nIn(hex2in)
    );

    SevenSegmentDisplayDecoder ksa_sseg_decoder3
    (
        .ssOut(HEX3),
        .nIn(hex3in)
    );

    SevenSegmentDisplayDecoder ksa_sseg_decoder4
    (
        .ssOut(HEX4),
        .nIn(hex4in)
    );

    SevenSegmentDisplayDecoder ksa_sseg_decoder5
    (
        .ssOut(HEX5),
        .nIn(hex5in)
    );

    logic clk, reset_n;

    assign clk = CLOCK_50;
    assign reset_n = ~KEY[3];
endmodule

`default_nettype wire