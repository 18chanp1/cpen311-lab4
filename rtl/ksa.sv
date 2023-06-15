/*
Rewritten version of KSA module in System Verilog instead of VHDL
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
    
	 /* Instantiate Seven Segment Display Decoders for 6 digits*/
	 
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
	 
	 
	 /* TASK 1: Instantiate on-chip memory: s_memory module */
	 logic [7:0] s_arr_addr, s_arr_data, s_arr_q;
    logic s_arr_wren;
    
	 s_memory s_arr(.address(s_arr_addr),
						 .clock(clk),
						 .data(s_arr_data),
						 .wren(s_arr_wren),
						 .q(s_arr_q));
						 
	
	 /* TASK 1: Instantiate ROM: rom module */
    logic [7:0] rom_addr, rom_q;
	 
    msg rom(.clock(clk),
			   .address(rom_addr),
			   .q(rom_q));
						
						
	 /* TASK 1: Instantiate output RAM: decrypted module */
	 logic [7:0] result_addr, result_data, result_q;
    logic result_wren;
    decrypted result (.address(result_addr),
							 .clock(clk),
							 .data(result_data),
							 .wren(result_wren),
							 .q(result_q));
	 
	 
	 /* TASK 1: Initialize Memory: Instantiate mem_init module in mem_init.sv */
	 logic [7:0] init_addr, init_data;
    logic init_wren, init_start, init_finish;
	 mem_init ksa_mem_init (.address(init_addr),
									.data(init_data),
									.wren(init_wren),
									.q(s_arr_q),
									.clk(clk),
									.rst(reset_n),
									.start(init_start),
									.finish(init_finish));
	 
	 
	 /* TASK 2: Shuffle array based on secret key: shuffle_arr module in shuffle_arr.sv */
	 logic [7:0] shuffle_addr, shuffle_data;
    logic [23:0] shuffle_secret;
    logic shuffle_wren, shuffle_start, shuffle_finish;
	 
	 shuffle_arr ksa_shuffle (.address(shuffle_addr),
									  .data(shuffle_data),
									  .q(s_arr_q),
									  .wren(shuffle_wren),
									  .clk(clk),
									  .rst(reset_n),
									  .start(shuffle_start),
									  .secret(24'h0003FF), // Hardcoded secret key for now. --> replace with actual key input
									  .finish(shuffle_finish));
									  
									  
	 /* TASK 2: Compute one byte per character in the encrypted message: decrypter module in decrypter.sv */
	 logic [7:0] decrypter_s_addr, decrypter_s_data, decrypter_s_q;
    logic decrypter_start, decrypter_finish, decrypter_s_wren;
	 
	 decrypter ksa_decrypter (.msg_q(rom_q),
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
									  .finish(decrypter_finish));
	 
endmodule

`default_nettype wire