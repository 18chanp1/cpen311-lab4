`timescale 10ns/10ns

module tb_mem_init();

    logic [7:0]  address;
    logic [7:0]  data;
    logic        wren;                   /*write enable*/
    logic         q;                      /* output of memory; not used*/
    logic         clk;
    logic         rst;
    logic         start;
    logic        finish;

    mem_init DUT 
    (
        .address(address),
        .data(data),
        .wren(wren),
        .q(q),
        .clk(clk),
        .rst(rst),
        .start(start),
        .finish(finish)
    );

    initial begin
        forever begin
            clk = 1'b0;
            #1;
            clk = 1'b1;
            #1;
        end
    end

    initial begin 
        rst = 1'b1;
        start = 1'b0;
        #2;
        rst = 1'b0;
        #2;
        #2;
        start = 1'b1;

        wait(finish);
        #2;
        #2;
        
        $stop;
    end

endmodule
