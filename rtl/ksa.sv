/*
Rewritten version of KSA module in systemverilog instead of VHDL
*/

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

    /*Initial test of mem_init module*/
    logic [7:0] init_addr, init_data, init_q;
    logic init_wren, init_start, init_finish;
    mem_init ksa_mem_init 
    (
        .address(init_addr),
        .data(init_data),
        .wren(init_wren),
        .q(init_q),
        .clk(clk),
        .rst(reset_n),
        .start(init_start),
        .finish(init_finish)
    );



    /* Test of the shuffle_arr module */
    logic [7:0] shuffle_addr, shuffle_data, shuffle_q;
    logic [23:0] shuffle_secret;
    logic shuffle_wren, shuffle_start, shuffle_finish;

    shuffle_arr ksa_shuffle
    (
        .address(shuffle_addr),
        .data(shuffle_data),
        .q(shuffle_q),
        .wren(shuffle_wren),
        .clk(clk),
        .rst(reset_n),
        .start(shuffle_start),
        .secret(24'h000249),
        .finish(shuffle_finish)
    );

	 parameter READY = 4'b0000;
	 parameter FSM1 = 4'b0010;
	 parameter BREAK = 4'B0100;
	 parameter FSM2 = 4'b0001;
	 parameter DONE = 4'b1000;
	 logic select;
	 
	 logic [3:0] state;
    assign select = state[0];
	 assign LEDR[2] = state[2];
    assign LEDR[3] = state[3];
	 assign shuffle_start = state[0];
     assign init_start = state[1];
	 
    always_ff @(posedge clk) begin
        if(reset_n) state <= READY;
        else begin
            case(state)
                READY: state <= ~KEY[0] ? FSM1 : READY;
                FSM1: state <= init_finish? BREAK : FSM1;
					 BREAK: state <= ~KEY[1] ? FSM2 : BREAK;
                FSM2: state <= shuffle_finish ? DONE : FSM2;
            endcase
        end
    end

    always_comb begin
        if(select) begin
            s_arr_addr = shuffle_addr;
            s_arr_data = shuffle_data;
            s_arr_wren = shuffle_wren;
            shuffle_q = s_arr_q;
				init_q = 8'b0;
        end
        else begin
            s_arr_addr = init_addr;
            s_arr_data = init_data;
            s_arr_wren = init_wren;
            init_q = s_arr_q;
				shuffle_q = 8'b0;
        end
    end
endmodule

    