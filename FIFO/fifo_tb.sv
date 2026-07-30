module fifo_tb;
    localparam int width = 32;
    localparam int depth = 8;

    logic clk, rst_n, wr_en, full, rd_en, empty;
    
    logic [width-1:0] wr_data;
    logic [width-1:0] rd_data;

    logic [$clog2(depth+1)-1:0] count;

    sync_fifo  #(
        .WIDTH(width),
        .DEPTH(depth)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .count(count)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    int pass, fail;
    int data_check[depth];
    int fill_check[depth];
    initial begin
        $display("Seed = %0d", $get_initial_random_seed());
        pass = 0;
        fail = 0;
        rst_n = 1'b0; wr_data = '0; wr_en = '0; rd_en = '0;
        @(posedge clk); #1;
        rst_n = 1'b1;
        // Write Read Check
        for (int i = 0; i < 1000; i++) begin
            wr_en = 1;
            rd_en = 0;
            wr_data = $urandom;
            @(posedge clk); #1;

            wr_en = 0;
            rd_en = 1;
            @(posedge clk); #1;
            
            if (rd_data != wr_data) begin
                $error("FAIL WR/RD [%0d]: wr_data = %0d, rd_data = %0d", i, wr_data, rd_data);
                fail = fail + 1;
            end else begin
                pass = pass + 1;
            end
            rd_en = 0;
        end
        rd_en = 1'b0;
        @(posedge clk); #1;
        if (!empty) begin
            $error("Failed to empty FIFO");
            fail = fail + 1;
        end
        
        // Fill and read all 
        wr_en = 1'b1;
        for (int j = 0; j < depth; j++) begin
            wr_data = $urandom;
            
            data_check[j] = wr_data;
            @(posedge clk); #1;
        end
        #1;
        if (!full) begin
            $error("Failed to fill FIFO");
            fail = fail + 1;
        end
        wr_en = 1'b0;
        for (int k = 0; k < depth; k++) begin
            rd_en = 1'b1;
            @(posedge clk); #1;
            if (rd_data != data_check[k]) begin
                $error("FAIL Read from full at Test #%0d: wr_data = %0d, rd_data = %0d", k, data_check[k], rd_data);
                fail = fail + 1;
            end else begin
                pass = pass + 1;
            end
        end
        $display("All Tests Concluded. Pass: %0d, Fail: %0d", pass, fail);
        $stop;


    end
endmodule