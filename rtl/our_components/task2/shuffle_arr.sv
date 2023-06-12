module shuffle_arr
#
(
    /*Due to optimizations with mod256, this is not changeable*/
    localparam DATA_WIDTH = 8;
)
(
    output logic [DATA_WIDTH - 1:0]  address,
    output logic [DATA_WIDTH - 1:0]  data,
    output logic        wren,                   /*write enable*/
    input logic         q,                      /* output of memory, not used*/
    input logic         clk,
    input logic         rst,
    input logic         start,
    input logic [23:0]  secret,
    output logic        finish
    /*Signals should by synchronous*/
);

    logic [44:0] state;
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
    parameter READ_SJ = 5'b010_00;
    parameter WRITE_SI = 5'b101_10;
    parameter WRITE_SJ = 5'b011_10;
    parameter DONE = 5'b100_01;

    always_ff @(posedge clk) begin
        if(rst) begin
            state <= {29'b0};
        end 
        else begin
            case(state[4:0]) begin
                READY:      state <= start ? {si, j, i, 8'b0, i, GET_SI} : state;
                GET_SI:     state <= {si, j, i, 8'b0, j, READ_SJ}; //q=xx;
                READ_SJ:    state <= {q, (j + q + secret[((i % 3) * 8) +: 8]), i, 8'b0, (j + q + secret[((i % 3) * 8) +: 8]), WRITE_SJ}; //q=si
                WRITE_SI:   state <= {si, j, i, q, i, WRITE_SI}; //q=sj
                WRITE_SJ:   state <= (i >= 255) ? {si, j, i, 8'b0, i, DONE}, {si, j, i+1, 8'b0, i + 1, GET_SI}; //q=xx
                DONE:       state <= state;
            endcase
        end
    end
endmodule


