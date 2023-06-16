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
    assign reset_n = ~KEY[3]; // Active Low Reset Button on FPGA
	 
	 
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
									  
									  
	 logic [23:0] current_key;
	 logic [31:0] encrypted_message;
	 logic rc4_start, rc4_finish, rc4_failure, rc4_ready;
	 
	 assign rc4_start = ~KEY[0]; // KEY 0 button press is "start" of decryption
	 
	 /* TASK 3: Cracking RC-4 Brute Force Checker - Instantiate rc4_cracker module */
	 rc4_cracker ksa_cracker (.clk(clk),
									  .reset(reset_n),
									  .rc4_start(rc4_start),
									  .rc4_finish(rc4_finish), 
									  .rc4_failure(rc4_failure),
									  .s_arr_q(s_arr_q),
									  .current_key(current_key),
									  .encrypted_message(encrypted_message),
									  .s_arr_addr(s_arr_addr),
									  .s_arr_data(s_arr_data),
									  .s_arr_wren(s_arr_wren),
									  .rc4_ready(rc4_ready));
		
		/* Display current key considered in HEX display */
	assign {hex5in, hex4in, hex3in, hex2in, hex1in, hex0in} = current_key; // Total 24 bits
	
	
	
	/* Assign LEDR depending on status */
	assign LEDR[9] = rc4_ready;
	assign LEDR[0] = rc4_finish;
	assign LEDR[1] = rc4_failure;
	
	 
endmodule

`default_nettype wire