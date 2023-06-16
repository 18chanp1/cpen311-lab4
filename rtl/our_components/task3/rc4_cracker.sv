/* Task 3 FSM */

module rc4_cracker
#
(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 8,
	parameter ADDR_MAX = 255,   /*Highest possible address of the pseudorandom sequence.*/
	parameter SECRET_LEN = 24,  /*Must be multiple of 8, i.e. byte-sized. Length of secret*/
	parameter MESSAGE_LEN = 32 /* in bytes*/
)
(
	input logic clk, 
	input logic reset, 
	input logic rc4_start, 
	output logic rc4_finish, 
	output logic rc4_failure,
	input logic s_arr_q, 
	output logic [23:0] current_key,
	output logic [31:0] encrypted_message,
	output logic [7:0] s_arr_addr,
	output logic [7:0] s_arr_data,
	output logic s_arr_wren,
	output logic rc4_ready
);

	/* State Encodings */
	parameter IDLE 						= 000_100000;// add proper encoding
	parameter GENERATE_KEY 				= 001_000000;
	parameter INIT_ARRAY 				= 010_000001;
	parameter SHUFFLE_ARR 				= 011_000010;
	parameter DECRYPTER 					= 100_000100;
	parameter FAILURE 					= 101_001000;
	parameter FINISHED_CURRENT_KEY 	= 110_000000;
	parameter CRACKED						= 111_010000;
	
	parameter MAX_KEY = {2'b00, {22{1'b1}}}; // we know the 2 most significant bits will be 00
	
	/* Local Variables */
	logic [8:0] state; // add width
		
		
	assign rc4_failure = state[3]; // Glitch Free --> Driven by State Bit
	assign rc4_finish = state[4];  // Glitch Free --> Driven by State Bit
	assign rc4_ready = state[5];   // Glitch Free --> Driven by State Bit
	
	/* TASK 1: Initialize Memory: Instantiate mem_init module in mem_init.sv */
	logic [7:0] init_addr, init_data;
	logic init_wren, init_start, init_finish;
	
	assign init_start = state[0]; // Glitch Free --> Driven by State Bit
	
	
	
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
	
	assign shuffle_start = state[1]; // Glitch Free --> Driven by State Bit

	shuffle_arr ksa_shuffle (.address(shuffle_addr),
								    .data(shuffle_data),
								    .q(s_arr_q),
								    .wren(shuffle_wren),
								    .clk(clk),
								    .rst(reset),
								    .start(shuffle_start),
								    .secret(current_key),
								    .finish(shuffle_finish));
	
	
	/* TASK 2: Compute one byte per character in the encrypted message: decrypter module in decrypter.sv */
	 logic [7:0] decrypter_s_addr, decrypter_s_data, decrypter_s_q;
    logic decrypter_start, decrypter_finish, decrypter_s_wren;
	 
	 assign decrypter_start = state[2];
	 
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
	
	
	always_ff @(posedge clk) 
	begin
		if (reset) begin
			state <= IDLE;
		end else begin
			case(state)
				IDLE: begin // don't think idle is necessary -> remove later
					current_key <= 0;
					if (rc4_start) state <= GENERATE_KEY;
					else state <= IDLE; // Wait in idle until start button is pressed initially
				end
				
				// GENERATE_KEY State
				GENERATE_KEY: begin
					if (current_key == MAX_KEY) begin
						current_key = 0; // implement some failure method here
						state <= FAILURE;
					end else begin
						current_key = current_key + 1;
						state <= SHUFFLE_ARR;
					end
				end
				
				// INIT_ARRAY State
				INIT_ARRAY: begin
					if (init_finish) state <= SHUFFLE_ARR;
					else state <= INIT_ARRAY; // Wait for init_finish from init FSM
				end
				
				// SHUFFLE_ARR State
				SHUFFLE_ARR: begin
					if (shuffle_finish) state <= DECRYPTER;
					else state <= SHUFFLE_ARR; // Wait for shuffle_finish from shuffle FSM
				end
				
				// DECRYPTER State
				DECRYPTER: begin
					if (decrypter_finish) state <= FINISHED_CURRENT_KEY;
					else state <= DECRYPTER; // Wait for decrypter_finish from decrypter FSM
				end
				
				// FINISHED_CURRENT_KEY State
				FINISHED_CURRENT_KEY: begin
					// First check if we cracked it (ask Paco how), otherwise go back to GENERATE_KEY to try another key
					state <= GENERATE_KEY;
				end
				
				// CRACKED State
				CRACKED: begin
					state <= CRACKED;
				end
				
				//DEFAULT 
				default: state <= IDLE;
			endcase
		end
	
	end
	
	/* Assign signals for s_memory */
	always_comb begin
		case (state)
			// INIT_ARRAY State Case
			INIT_ARRAY: begin
				 s_arr_addr = init_addr;
				 s_arr_data = init_data;
				 s_arr_wren = init_wren;
			end
			
			// SHUFFLE_ARR State Case
			SHUFFLE_ARR: begin
				 s_arr_addr = shuffle_addr;
				 s_arr_data = shuffle_data;
				 s_arr_wren = shuffle_wren;
			end
			
			// DECRYPTER State Case
			DECRYPTER: begin
				 s_arr_addr = decrypter_s_addr;
				 s_arr_data = decrypter_s_data;
				 s_arr_wren = decrypter_s_wren;
			end
			
			// All Other States Case
			default: begin
				 s_arr_addr = 8'b0;
				 s_arr_data = 8'b0;
				 s_arr_wren = 1'b0;
			end
		endcase
	 end

endmodule
