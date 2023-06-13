`timescale 10ns/10ns

module tb_shuffle_arr();
    logic [7:0]   address;
    logic [7:0]   data;
    logic         wren;                   /*write enable*/
    logic [7:0]   q;                      /* output of memory; not used*/
    logic         clk;
    logic         rst;
    logic [23:0]  secret;
    logic         start;
    logic         finish;

    shuffle_arr DUT
    (
        .address(address),
        .data(data),
        .wren(wren),
        .q(q),
        .clk(clk),
        .rst(rst),
        .secret(secret),
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

    logic [7:0] memory [256];
    always_ff @(posedge clk) q <= memory[address];
    always_ff @(posedge clk) begin
	    if(rst) 
        begin
            for(int i = 0; i < 256; i = i + 1) 
            begin
                memory[i] <= i;
            end
		end
        else if(wren) memory[address] <= data;
    end

    initial begin
       

        rst = 1'b1;
        start = 1'b0;
        secret = 24'h000249;
        #2;
        rst = 1'b0;
        

        #2;
        start = 1'b1;

        wait(finish)

        for(int i = 0; i < 256; i = i + 1) begin
            $display("%0h", memory[i]);
        end

        $stop;
    end
endmodule
        
        
            