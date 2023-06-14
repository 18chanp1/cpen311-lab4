`timescale 10ns/10ns

module tb_decrypter();

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 8;
    parameter MESSAGE_LEN = 32;
    
    logic [DATA_WIDTH - 1:0]  msg_q;          /*ROM encrypted message control signal*/
    logic [ADDR_WIDTH - 1:0] msg_addr;
    logic [ADDR_WIDTH - 1:0] result_addr;    /*RAM decrypted message control*/
    logic [DATA_WIDTH - 1:0] result_data;
    logic                    result_wren;
    logic [ADDR_WIDTH - 1:0] s_addr;         /*scratch control signals*/
    logic [DATA_WIDTH - 1:0] s_data;
    logic [DATA_WIDTH - 1:0]  s_q;         
    logic                    s_wren;    
    logic                     clk;            /*FSM Control signals*/
    logic                     rst;
    logic                     start;
    logic                    finish; 

    decrypter DUT
    (
        .msg_q(msg_q),
        .msg_addr(msg_addr),
        .result_addr(result_addr),
        .result_data(result_data),
        .result_wren(result_wren),
        .s_addr(s_addr),
        .s_data(s_data),
        .s_q(s_q),
        .s_wren(s_wren),
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

    logic [7:0] e_msg [32];

    always_ff @(posedge clk) begin
        msg_q <= e_msg[msg_addr];
    end

    logic [7:0] enc_out [32];
    always_ff @(posedge clk) 
    begin
        if (result_wren) 
        begin
            enc_out[result_addr] <= result_data;
        end
    end

    logic [7:0] scratch [256];
    always_ff @(posedge clk)
    begin
        if (s_wren) 
        begin
            s_q <= s_data;
            scratch[s_addr] <= s_data;
        end
        else s_q <= scratch[s_addr];
    end


    initial begin 
        $readmemh("encrypted_msg.mem", e_msg);
        $readmemh("swapped.mem", scratch);
        rst = 1'b1;
        start = 1'b0;

        #2;

        rst = 1'b0;
        start = 1'b1;

        wait(finish);
        #12;


        $display("%p", enc_out);

        for (int i = 0; i < 32; i = i + 1) begin
            $write("%c", enc_out[i]);
        end
        $display("");

        $stop;
    end

endmodule

            




    

    

        

        