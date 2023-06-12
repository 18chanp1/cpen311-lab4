module mem_init
#(
    parameter DATA_WIDTH = 8 /* width of data, must be same as address width*/
)
(
    output logic [DATA_WIDTH - 1:0]  address,
    output logic [DATA_WIDTH - 1:0]  data,
    output logic        wren,
    input logic         q,
    input logic         clk,
    input logic         rst,
    input logic         start,
    output logic        finish
);

    localparam STATE_TOP = DATA_WIDTH + 2 - 1;

    logic [STATE_TOP:0] state;
    assign address =    state[STATE_TOP:2];
    assign data =       state[STATE_TOP:2];
    assign wren =       state[1];
    assign finish =     state[0];

    parameter READY = 2'b00;
    parameter WRITE = 2'b10;
    parameter DONE = 2'b01;

    always_ff @(posedge clk) begin
        if(rst) state <= {(DATA_WIDTH + 2){1'b0}};
        else begin 
            case(state[1:0])
                READY: state <= start ? {state[STATE_TOP:2], WRITE} : state;
                WRITE: state <= state[STATE_TOP:2] >= 255 ? {state[STATE_TOP:2], DONE} : {(state[STATE_TOP:2] + 1), WRITE};
                DONE: state <= state;
            endcase
        end
    end
endmodule