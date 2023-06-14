`timescale 10ns/10ns

module tb_decrypter();

    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter MESSAGE_LEN = 32
    
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

    $readmemh("encrypted_msg.mem", e_msg);

    logic [7:0] rom_reg;
    always_ff @(posedge clk) begin
        msg_q <= rom_reg;
        rom_reg <= e_msg[msg_addr];
    end

    logic [7:0] enc_out [256];
    always_ff @(posedge clk) 
    begin
        if(rst) begin
            for (int i = 0; i < 256; i = i + 1)
            begin
                enc_out <= 'b0;
            end
            result_q <= 'b0;
        end
        else if (result_wren) 
        begin
            enc_out[address] <= result_data;
            result_q <= result_data;
        end
        else result_q <= enc_out[address];
    end

    logic [7:0] scratch [256];
    $readmemh("swapped.mem", swapped);
    always_ff @(posedge clk)
    begin
        if(rst) begin
            for (int i = 0; i < 256; i = i + 1)
            begin
                scratch[i] <= swapped[i];
            end
            s_q <= swapped[s_addr];
        end
        else if (s_wren) 
        begin
            s_q <= s_data;
            scratch[i] <= s_data;
        end
        else s_q <= scratch[i];
    end


    initial begin 
        rst = 1'b1;
        start = 1'b0;

        #2;

        start = 1'b1;

        wait(finish);

        $display("%s", enc_out);
    end

endmodule

            




    

    

        

        