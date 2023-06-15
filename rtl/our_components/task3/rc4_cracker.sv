/* Task 3 FSM */

module rc4_cracker
#
(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 8,
	parameter ADDR_MAX = 255,   /*Highest possible address of the pseudorandom sequence.*/
	parameter SECRET_LEN = 24  /*Must be multiple of 8, i.e. byte-sized. Length of secret*/
	parameter MESSAGE_LEN = 32 /* in bytes*/
)
(
	clk, 
	reset, 
	start, 
	finish, 
	s_arr_q, 
	encrypted_message
);

	/* State Encodings */
	parameter IDLE = 0;// add proper encoding
	parameter GENERATE_KEY;
	parameter SHUFFLE_ARR;
	parameter DECRYPTER;
	parameter FAILURE;
	
	parameter MAX_KEY = {2'b00, 22{1'b1}}; // we know the 2 most significant bits will be 00
	
	/* Local Variables */
	logic [23:0] current_key = 0; // 24-bit KEY
	logic state; // add width
	
	logic try_next_key;
	
	/* TASK 2: Shuffle array based on secret key: shuffle_arr module in shuffle_arr.sv */
	logic [7:0] shuffle_addr, shuffle_data;
	logic [23:0] shuffle_secret;
	logic shuffle_wren, shuffle_start, shuffle_finish;

	shuffle_arr ksa_shuffle (.address(shuffle_addr),
								    .data(shuffle_data),
								    .q(s_arr_q),
								    .wren(shuffle_wren),
								    .clk(clk),
								    .rst(reset),
								    .start(shuffle_start),
								    .secret(current_key),
								    .finish(shuffle_finish));
	
	
	always_ff @(posedge clk) 
	begin
		if (reset) begin
			state <= IDLE;
		end else begin
			case(state)
				IDLE: begin // don't think idle is necessary -> remove later
					if (try_next_key) state <= GENERATE_KEY;
					else state <= IDLE; // stay in idle
				end
				
				// GENERATE_KEY State
				GENERATE_KEY: begin
					if (current_key == MAX_KEY) begin
						current_key = 0; // implement some failure method here
						state <= FAILURE;
					else begin
						current_key = current_key + 1;
						state <= SHUFFLE_ARR;
					end
				end
				
				// SHUFFLE_ARR State
				SHUFFLE_ARR: begin
					// Set signals for Shuffle
				end
				
				// DECRYPTER State
				DECRYPTER: begin
					// Set signals for Decrypter
				end
			endcase
		end
	
	end



endmodule
