module rc4_cracker_tb;

	/* Inputs */
	logic clk, reset, rc4_start;
	
	/* Outputs */
	logic rc4_finish, rc4_failure, rc4_ready;
	logic [23:0] current_key;

	/* Instantiate Module */
	
	rc4_cracker DUT
	(
		.clk(clk), 
		.reset(reset), 
		.rc4_start(rc4_start), 
		.rc4_finish(rc4_finish), 
		.rc4_failure(rc4_failure),
		.current_key(current_key),
		.rc4_ready(rc4_ready)
	);
	
	
	/* Initial Block for clk */
	
	initial forever begin
		clk = 1'b0;
		#5;
		clk = 1'b1;
		#5;
	end
	
	
	initial begin
		reset = 1'b1;
		#20;
		reset = 1'b0;
		// Observe rc4_ready output in waveform
		#10;
		rc4_start = 1'b1;
		#10;
		rc4_start = 1'b0;
		#200;
	
	
		$stop;
	end

endmodule
