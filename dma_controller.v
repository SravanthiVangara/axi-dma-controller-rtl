module dma_controller (
    input  wire clk,
    input  wire rst,

    input  wire dma_start,
    input  wire fifo_full,
    input  wire fifo_empty,
    input  wire axi_ready,

    output reg  wr_en,
    output reg  rd_en,
    output reg  dma_busy,
    output reg  dma_done,
    output reg  dma_interrupt
);

    // -----------------------------
    // State Encoding
    // -----------------------------
    localparam IDLE  = 2'b00;
    localparam WRITE = 2'b01;
    localparam SEND  = 2'b10;
    localparam DONE  = 2'b11;

    reg [1:0] state, next_state;

    // -----------------------------
    // Sequential Block
    // -----------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // -----------------------------
    // Combinational Block
    // -----------------------------
    always @(*) begin

        // Default values (VERY IMPORTANT)
        wr_en = 0;
        rd_en = 0;
        dma_busy = 0;
        dma_done = 0;
        dma_interrupt = 0;
        next_state = state;

        case (state)

        IDLE: begin
            if (dma_start)
                next_state = WRITE;
        end

        WRITE: begin
            dma_busy = 1;

            if (!fifo_full)
                wr_en = 1;
            else
                next_state = SEND;
        end

        SEND: begin
            dma_busy = 1;

            if (!fifo_empty && axi_ready)
                rd_en = 1;
            else if (fifo_empty)
                next_state = DONE;
        end

        DONE: begin
            dma_done = 1;
            dma_interrupt = 1;
            next_state = IDLE;
        end

        endcase
    end

endmodule