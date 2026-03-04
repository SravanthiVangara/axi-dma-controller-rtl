module apb_dma_config (
    input  wire        pclk,
    input  wire        presetn,

    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [7:0]  paddr,
    input  wire [31:0] pwdata,
    output reg  [31:0] prdata,

    output reg         dma_start,
    output reg [31:0]  dst_addr,
    output reg [15:0]  transfer_size,
    input  wire        dma_done
);

    reg [31:0] CTRL;
    reg [31:0] SIZE;
    reg [31:0] STATUS;

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            CTRL <= 0;
            dst_addr <= 0;
            SIZE <= 0;
            STATUS <= 0;
            dma_start <= 0;
        end
        else begin
            dma_start <= 0;

            if (psel && penable && pwrite) begin
                case (paddr)
                    8'h00: begin
                        CTRL <= pwdata;
                        dma_start <= pwdata[0];
                        STATUS <= 0;
                    end
                    8'h04: dst_addr <= pwdata;
                    8'h08: begin
                        SIZE <= pwdata;
                        transfer_size <= pwdata[15:0];
                    end
                endcase
            end

            if (dma_done)
                STATUS <= 32'h1;
        end
    end

    always @(*) begin
        case (paddr)
            8'h00: prdata = CTRL;
            8'h04: prdata = dst_addr;
            8'h08: prdata = SIZE;
            8'h0C: prdata = STATUS;
            default: prdata = 32'h0;
        endcase
    end

endmodule
