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
    logic [3:0] hex0in, hex1in, hex2in, hex3in, hex4in, hex5in;
    
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
									  
									  
	 logic [23:0] current_key;
	 logic rc4_start, rc4_finish, rc4_failure, rc4_ready, rc4_stop;
	 
	 assign rc4_start = ~KEY[0]; // KEY 0 button press is "start" of decryption
	 
	 logic pause = 1'b0;
     
     always_ff @(posedge ~KEY[1]) begin
        pause <= ~pause;
     end

    /* For bonus task */
    logic core_1_finish, core_2_finish, core_3_finish, core_4_finish;
    logic core_1_failure, core_2_failure, core_3_failure, core_4_failure;
    logic core_1_ready, core_2_ready, core_3_ready, core_4_ready;
    logic [23:0] core_1_current_key, core_2_current_key, core_3_current_key, core_4_current_key;

	 
	/* Core 1 */
    rc4_cracker #(.KEY_START(0), .MAX_KEY(1048575)) core_1 // up to 0FFFF
					  (.clk(clk),
					   .reset(reset_n),
						.pause(pause),
						.rc4_stop(rc4_stop),
						.rc4_start(rc4_start),
						.rc4_finish(core_1_finish), 
						.rc4_failure(core_1_failure),
						.current_key(core_1_current_key),
						.rc4_ready(core_1_ready));

 /* Core 2 */
    rc4_cracker #(.KEY_START(1048576), .MAX_KEY(2097151)) core_2  // up to 1FFFF
                 (.clk(clk),
						.reset(reset_n),
						.pause(pause),
						.rc4_stop(rc4_stop),
						.rc4_start(rc4_start),
						.rc4_finish(core_2_finish), 
						.rc4_failure(core_2_failure),
						.current_key(core_2_current_key),
						.rc4_ready(core_2_ready));

    /* Core 3 */
    rc4_cracker #(.KEY_START(2097152), .MAX_KEY(3145727)) core_3  // up to 2FFFF
					  (.clk(clk),
						.reset(reset_n),
						.pause(pause),
						.rc4_stop(rc4_stop),
						.rc4_start(rc4_start),
						.rc4_finish(core_3_finish), 
						.rc4_failure(core_3_failure),
						.current_key(core_3_current_key),
						.rc4_ready(core_3_ready));

    /* Core 4 */
    rc4_cracker #(.KEY_START(3145728), .MAX_KEY(4194303)) core_4  // up to 3FFFF
					  (.clk(clk),
						.reset(reset_n),
						.pause(pause),
						.rc4_stop(rc4_stop),
						.rc4_start(rc4_start),
						.rc4_finish(core_4_finish), 
						.rc4_failure(core_4_failure),
						.current_key(core_4_current_key),
						.rc4_ready(core_4_ready));
     
     
     /* TASK 3: Cracking RC-4 Brute Force Checker - Instantiate rc4_cracker module */
	//  rc4_cracker ksa_cracker (.clk(clk),
    //                         .reset(reset_n),
    //                         .pause(pause),
    //                         .rc4_start(rc4_start),
    //                         .rc4_finish(rc4_finish), 
    //                         .rc4_failure(rc4_failure),
    //                         .current_key(current_key),
    //                         .rc4_ready(rc4_ready));
		
		/* Display current key considered in HEX display */
	assign {hex5in, hex4in, hex3in, hex2in, hex1in, hex0in} = current_key; // Total 24 bits
	
	
	
	/* Assign LEDR depending on status */
	// assign LEDR[9] = rc4_ready;
	// assign LEDR[0] = rc4_finish;
	// assign LEDR[1] = rc4_failure;
    
    /* For Bonus */
    assign rc4_finish = core_1_finish | core_2_finish | core_3_finish | core_4_finish;
    assign rc4_failure = core_1_failure & core_2_failure & core_3_failure & core_4_failure;
    assign rc4_ready = core_1_ready & core_2_ready & core_3_ready & core_4_ready;
    assign rc4_stop = rc4_finish;

    assign LEDR[9] = core_1_ready & core_2_ready & core_3_ready & core_4_ready;
    assign LEDR[0] = rc4_finish;
    assign LEDR[1] = rc4_failure;

    assign LEDR[2] = pause ? 1'b1 : 1'b0; // Only turn on if paused

    /* Assign hex display key to the key found by whichever core */
    always_comb begin
        if (core_1_finish) current_key = core_1_current_key;
        else if (core_2_finish) current_key = core_2_current_key;
        else if (core_3_finish) current_key = core_3_current_key;
        else if (core_4_finish) current_key = core_4_current_key;
        else current_key = core_1_current_key;
    end

    // For bonus: Use LEDR[7:4] to indicate which core found the solution
    assign LEDR[7:4] = {core_1_finish, core_2_finish, core_3_finish, core_4_finish};
		
	 
endmodule

`default_nettype wire