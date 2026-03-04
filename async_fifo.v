module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire wr_clk,
    input  wire wr_rst,
    input  wire wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire full,

    input  wire rd_clk,
    input  wire rd_rst,
    input  wire rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire empty
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Binary pointers
    reg [ADDR_WIDTH:0] wr_ptr_bin;
    reg [ADDR_WIDTH:0] rd_ptr_bin;

    // Gray pointers
    reg [ADDR_WIDTH:0] wr_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_gray;

    // Synced pointers
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

    // Write pointer logic
    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wr_ptr_bin <= 0;
            wr_ptr_gray <= 0;
        end
        else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin <= wr_ptr_bin + 1;
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
        end
    end

    // Read pointer logic
    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rd_ptr_bin <= 0;
            rd_ptr_gray <= 0;
            rd_data <= 0;
        end
        else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin <= rd_ptr_bin + 1;
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);
        end
    end

    // Synchronize read pointer into write clock domain
    always @(posedge wr_clk) begin
        rd_ptr_gray_sync1 <= rd_ptr_gray;
        rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end

    // Synchronize write pointer into read clock domain
    always @(posedge rd_clk) begin
        wr_ptr_gray_sync1 <= wr_ptr_gray;
        wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end

    // Full detection
    assign full =
        (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
                         rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

    // Empty detection
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

endmodule