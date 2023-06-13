module shuffle_arr
#
(
    /*Due to optimizations with mod256, this is not changeable*/
    parameter DATA_WIDTH = 8
)
(
    output logic [DATA_WIDTH - 1:0]  address,
    output logic [DATA_WIDTH - 1:0]  data,
    input logic [DATA_WIDTH - 1:0]   q,         
    output logic        wren,                   /*write enable*/
    input logic         clk,
    input logic         rst,
    input logic         start,
    input logic [23:0]  secret,
    output logic        finish
    /*Signals should by synchronous*/
);

    logic [44:0] state;
	logic [7:0] i, j, si;
    assign finish =     state[0];
    assign wren =       state[1];
    /*state ID =        state[4:2]*/
    assign address =    state[12:5];
    assign data =       state[20:13];
    assign i =          state[28:21];
    assign j =          state[36:29];
    assign si =         state[44:37];

    parameter READY = 5'b000_00;
    parameter GET_SI = 5'b001_00;
    parameter COMPUTE_J = 5'b010_00;
    parameter GET_SJ = 5'b110_00;
    parameter WRITE_SI_TO_SJ = 5'b101_10;
    parameter WRITE_SJ_TO_SI = 5'b011_10;
    parameter DONE = 5'b100_01;

    always_ff @(posedge clk) begin
        if(rst) begin
            state <= {29'b0};
        end 
        else begin
            case(state[4:0])
                READY:      state <= start ? {si, j, i, 8'b0, i, GET_SI} : state;
                GET_SI:     state <= {si, j, i, 8'b0, 8'b0, COMPUTE_J}; //q=xx;
                COMPUTE_J: begin
                            //q==si
                            state[44:37]    <= q;
                            state[36:29]    <= j + q + secret[((2 -  (i % 3)) * 8) +: 8];
                            state[28:21]    <= i;
                            state[20:13]    <= 8'b0;
                            state[12:5]     <= j + q + secret[((2 -  (i % 3)) * 8) +: 8];
                            state[4:0]      <= GET_SJ;
                        end
                GET_SJ: state <= {si, j, i, si, j, WRITE_SI_TO_SJ}; // q = xx
                WRITE_SI_TO_SJ:   state <= {si, j, i, q, i, WRITE_SJ_TO_SI}; //q=sj
                WRITE_SJ_TO_SI: begin
                    if (i >= 255) begin
                        state[44:37]    <= si;
                        state[36:29]    <= j;
                        state[28:21]    <=  i;
                        state[20:13]    <= 8'b0;
                        state[12:5]     <= i;
                        state[4:0]      <= DONE;
                    end
                    else begin
                        //q==xx
                        state[44:37]    <= si;
                        state[36:29]    <= j;
                        state[28:21]    <= i+1;
                        state[20:13]    <= 8'b0;
                        state[12:5]     <= i+1;
                        state[4:0]      <= GET_SI;
                    end
                end
                DONE:       state <= state;
            endcase
        end
    end
endmodule


