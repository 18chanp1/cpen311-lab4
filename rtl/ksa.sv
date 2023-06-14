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

    /* Instantiate on chip memory*/

    logic [7:0] s_arr_addr, s_arr_data, s_arr_q;
    logic s_arr_wren;
    s_memory s_arr
    (
        .address(s_arr_addr),
        .clock(clk),
        .data(s_arr_data),
        .wren(s_arr_wren),
        .q(s_arr_q)
    );

    /*Instantiate ROM*/
    logic [7:0] rom_addr, rom_q;
    msg rom
    (
        .clock(clk),
        .address(rom_addr),
        .q(rom_q)
    );

    /*Instantiate output RAM*/
    logic [7:0] result_addr, result_data, result_q;
    logic result_wren;
    decrypted result
    (
        .address(result_addr),
        .clock(clk),
        .data(result_data),
        .wren(result_wren),
        .q(result_q)
    );

    /*Initial test of mem_init module*/
    logic [7:0] init_addr, init_data;
    logic init_wren, init_start, init_finish;
    mem_init ksa_mem_init 
    (
        .address(init_addr),
        .data(init_data),
        .wren(init_wren),
        .q(s_arr_q),
        .clk(clk),
        .rst(reset_n),
        .start(init_start),
        .finish(init_finish)
    );



    /* Test of the shuffle_arr module */
    logic [7:0] shuffle_addr, shuffle_data;
    logic [23:0] shuffle_secret;
    logic shuffle_wren, shuffle_start, shuffle_finish;

    shuffle_arr ksa_shuffle
    (
        .address(shuffle_addr),
        .data(shuffle_data),
        .q(s_arr_q),
        .wren(shuffle_wren),
        .clk(clk),
        .rst(reset_n),
        .start(shuffle_start),
        .secret(24'h0003FF),
        .finish(shuffle_finish)
    );

    logic [7:0] decrypter_s_addr, decrypter_s_data, 
    decrypter_s_q;
    logic decrypter_start, decrypter_finish, decrypter_s_wren;

    decrypter ksa_decrypter
    (
        .msg_q(rom_q),
        .msg_addr(rom_addr),
        .result_addr(result_addr),
        .result_data(result_data),
        .result_wren(result_wren),
        .s_addr(decrypter_s_addr),
        .s_data(decrypter_s_data),
        .s_q(s_arr_q),
        .s_wren(decrypter_s_wren),
        .clk(clk),
        .rst(reset_n),
        .start(decrypter_start),
        .finish(decrypter_finish)
    );

	parameter READY = 6'b000_000;
    parameter FSM1 = 6'b000_001;
    parameter BREAK = 6'b001_000;
    parameter FSM2 = 6'b001_010;
    parameter BREAK2 = 6'b011_000;
    parameter FSM3 = 6'b011_100;
    parameter DONE = 6'b111_000;
    logic select;
	 
    logic [5:0] state;
    assign init_start = state[0];
    assign shuffle_start = state[1];
    assign decrypter_start = state[2];
	assign LEDR[3] = state[3];
    assign LEDR[4] = state[4];
    assign LEDR[5] = state[5];
	
	 
    always_ff @(posedge clk) begin
        if(reset_n) state <= READY;
        else begin
            case(state)
                READY: state <= ~KEY[0] ? FSM1 : READY;
                FSM1: state <= init_finish? BREAK : FSM1;
                BREAK: state <= ~KEY[1] ? FSM2 : BREAK;
                FSM2: state <= shuffle_finish ? BREAK2 : FSM2;
                BREAK2: state <= ~KEY[1] ? FSM3 : BREAK2;
                FSM3: state <= decrypter_finish ? DONE : FSM3;
                DONE: state <= DONE;
            endcase
        end
    end

    always_comb begin
        case (state)
            FSM1:
            begin
                s_arr_addr = init_addr;
                s_arr_data = init_data;
                s_arr_wren = init_wren;
            end
            FSM2:
            begin
                s_arr_addr = shuffle_addr;
                s_arr_data = shuffle_data;
                s_arr_wren = shuffle_wren;
            end
            FSM3:
            begin
                s_arr_addr = decrypter_s_addr;
                s_arr_data = decrypter_s_data;
                s_arr_wren = decrypter_s_wren;
            end
            default: 
            begin
                s_arr_addr = 8'b0;
                s_arr_data = 8'b0;
                s_arr_wren = 1'b0;
            end
        endcase
    end
endmodule

`default_nettype wire