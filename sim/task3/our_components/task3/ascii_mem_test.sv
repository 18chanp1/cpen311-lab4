module ascii_mem_test
#
(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 8,
	parameter ADDR_MAX = 32,   /*Highest possible address of the pseudorandom sequence.*/
	parameter SECRET_LEN = 24,  /*Must be multiple of 8, i.e. byte-sized. Length of secret*/
	parameter MESSAGE_LEN = 32 /* in bytes*/
)
(
	input logic clk,
	input logic reset,
	input logic start,
	output logic finish,
	output logic failure,
	input logic [7:0] q,
	output logic [7:0] address
);

	/* State Encodings */
	parameter IDLE			= 5'b000_00;
	parameter PREP_READ 	= 5'b001_00;
	parameter READ			= 5'b010_00;
	parameter FINISHED 	= 5'b011_01;
	parameter FAILURE		= 5'b100_11;
	
	localparam STATE_TOP = DATA_WIDTH + 2 - 1;
	
	/* Local Variables */
	logic [4:0] state;
	
	assign finish = state[0];
	assign failure = state[1];

	always_ff @(posedge clk, posedge reset)
	begin
		if (reset) begin
			state <= IDLE;
			address <= 0;
		end else begin
			case (state)
			
				// IDLE State
				IDLE: begin
					address <= 0;
					if (start) state <= READ;
					else state <= IDLE;
				end
				
				// PREP_READ State
				PREP_READ: begin
					state <= READ;
				end
				
				// READ State
				READ: begin
					if ((((q <= 122) & (q >= 97)) | (q == 32)) & (address < 32)) begin
						address <= address + 1;
						state <= PREP_READ; // check next byte
					end else if (address == 32) begin // all bytes checked are VALID
						state <= FINISHED;
					end else begin
						state <= FAILURE;
					end
				end
				
				// FINISHED State
				FINISHED: begin
					state <= FINISHED;
				end
				
				// FAILURE State
				FAILURE: begin
					state <= FAILURE;
				end
				
				default: state <= IDLE;
			endcase
		end
			
	
	end



endmodule
