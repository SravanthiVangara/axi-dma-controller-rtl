`timescale 1ns/1ps

module dma_burst_engine #(
    parameter BASE_ADDR = 32'h1000,
    parameter BURST_LEN = 8
)(
    input clk,
    input rst,

    input start,
    input [31:0] data_in,

    input AWREADY,
    input WREADY,
    input BVALID,

    output reg AWVALID,
    output reg WVALID,
    output reg BREADY,
    output reg [31:0] AWADDR,
    output reg [31:0] WDATA,
    output reg done
);

reg [2:0] state;
reg [3:0] burst_count;
reg [31:0] addr_reg;

localparam IDLE      = 0;
localparam SEND_ADDR = 1;
localparam SEND_DATA = 2;
localparam WAIT_RESP = 3;
localparam FINISH    = 4;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        AWVALID <= 0;
        WVALID <= 0;
        BREADY <= 0;
        done <= 0;
        addr_reg <= BASE_ADDR;
        burst_count <= 0;
    end
    else begin
        case(state)

        IDLE: begin
            done <= 0;
            if (start) begin
                AWADDR <= addr_reg;
                state <= SEND_ADDR;
            end
        end

        SEND_ADDR: begin
            AWVALID <= 1;
            if (AWREADY) begin
                AWVALID <= 0;
                state <= SEND_DATA;
            end
        end

        SEND_DATA: begin
            WDATA <= data_in;
            WVALID <= 1;
            if (WREADY) begin
                WVALID <= 0;
                burst_count <= burst_count + 1;
                addr_reg <= addr_reg + 4;
                state <= WAIT_RESP;
            end
        end

        WAIT_RESP: begin
            BREADY <= 1;
            if (BVALID) begin
                BREADY <= 0;
                if (burst_count == BURST_LEN-1)
                    state <= FINISH;
                else
                    state <= SEND_ADDR;
            end
        end

        FINISH: begin
            done <= 1;
            burst_count <= 0;
            state <= IDLE;
        end

        endcase
    end
end

endmodule