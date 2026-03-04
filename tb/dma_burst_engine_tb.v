`timescale 1ns/1ps

module tb_dma_burst_engine;

reg clk;
reg rst;
reg start;
reg [31:0] data_in;

reg AWREADY;
reg WREADY;
reg BVALID;

wire AWVALID;
wire WVALID;
wire BREADY;
wire [31:0] AWADDR;
wire [31:0] WDATA;
wire done;

dma_burst_engine dut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .AWREADY(AWREADY),
    .WREADY(WREADY),
    .BVALID(BVALID),
    .AWVALID(AWVALID),
    .WVALID(WVALID),
    .BREADY(BREADY),
    .AWADDR(AWADDR),
    .WDATA(WDATA),
    .done(done)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    start = 0;
    data_in = 32'hDEADBEEF;
    AWREADY = 0;
    WREADY = 0;
    BVALID = 0;

    #20 rst = 0;

    #10 start = 1;
    #10 start = 0;

    repeat(8) begin
        #20 AWREADY = 1;
        #10 AWREADY = 0;

        #20 WREADY = 1;
        #10 WREADY = 0;

        #20 BVALID = 1;
        #10 BVALID = 0;
    end

    #50 $finish;
end

initial begin
    $dumpfile("burst.vcd");
    $dumpvars(0, tb_dma_burst_engine);
end

endmodule
