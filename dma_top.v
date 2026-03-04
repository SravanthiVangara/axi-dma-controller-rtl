

module dma_top (
    input clk,
    input rst,
    input dma_start,

    input AWREADY,
    input WREADY,
    input BVALID,

    input [31:0] adc_data,

    output dma_interrupt
);

wire fifo_full;
wire fifo_empty;
wire wr_en;
wire rd_en;
wire [31:0] fifo_out;

async_fifo fifo (
    .wr_clk(clk),
    .wr_rst(rst),
    .wr_en(wr_en),
    .wr_data(adc_data),
    .full(fifo_full),

    .rd_clk(clk),
    .rd_rst(rst),
    .rd_en(rd_en),
    .rd_data(fifo_out),
    .empty(fifo_empty)
);

dma_controller ctrl (
    .clk(clk),
    .rst(rst),
    .dma_start(dma_start),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .axi_ready(WREADY),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .dma_busy(),
    .dma_done(),
    .dma_interrupt(dma_interrupt)
);

dma_burst_engine axi (
    .clk(clk),
    .rst(rst),
    .start(rd_en),
    .data_in(fifo_out),
    .AWREADY(AWREADY),
    .WREADY(WREADY),
    .BVALID(BVALID),
    .AWVALID(),
    .WVALID(),
    .BREADY(),
    .AWADDR(),
    .WDATA(),
    .done()
);

endmodule