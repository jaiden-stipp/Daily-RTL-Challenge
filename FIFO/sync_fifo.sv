module sync_fifo #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 8
) (
    input  logic clk,
    input  logic rst_n,

    input  logic wr_en,
    input  logic [WIDTH-1:0] wr_data,
    output logic full,

    input  logic rd_en,
    output logic [WIDTH-1:0] rd_data,
    output logic empty,

    output logic [$clog2(DEPTH+1)-1:0] count
);
    logic [WIDTH-1:0] data [DEPTH-1:0];
    logic [$clog2(DEPTH+1)-1:0] read_pointer;
    logic [$clog2(DEPTH+1)-1:0] write_pointer;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++) begin
                data[i] <= '0;
            end
            rd_data <= '0;
            count <= '0;
            write_pointer <= '0;
            read_pointer <= '0;
        end else begin
            
            
            case ({wr_en && !full, rd_en && !empty}) 
                2'b10: begin // Write Only
                    data[write_pointer] <= wr_data;
                    write_pointer <= (write_pointer == DEPTH-1) ? '0 : write_pointer + 1;
                    count <= count + 1;
                end 
                2'b01: begin // Read Only
                    rd_data <= data[read_pointer];
                    read_pointer <= (read_pointer == DEPTH-1) ? '0 : read_pointer + 1;
                    count <= count - 1;
                end
                2'b11: begin // Both Read and Write
                    data[write_pointer] <= wr_data;
                    rd_data <= data[read_pointer];
                    write_pointer <= (write_pointer == DEPTH-1) ? '0 : write_pointer + 1;
                    read_pointer <= (read_pointer == DEPTH-1) ? '0 : read_pointer + 1;
                end
                2'b00: ; // None
                default: ;
            endcase
                
                
            
        end
    end
    
    always_comb begin
        empty = (count == 0);
        full = (count == DEPTH);
    end
endmodule