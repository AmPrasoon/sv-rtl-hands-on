`timescale 1ns/1ps
module axis_sync_fifo_core #(
    parameter int DATA_W = 32,
    parameter int DEPTH  = 8
) (
    input  logic clk,
    input  logic rst_n,

    // Input stream
    input  logic [DATA_W-1:0] s_tdata,
    input  logic              s_tvalid,
    output logic              s_tready,

    // Output stream
    output logic [DATA_W-1:0] m_tdata,
    output logic              m_tvalid,
    input  logic              m_tready,

    // Status
    output logic              full,
    output logic              empty,
    output logic [$clog2(DEPTH+1)-1:0] count
);

    localparam int ADDR_W  = $clog2(DEPTH);
    localparam int COUNT_W = $clog2(DEPTH+1);

    localparam logic [COUNT_W-1:0] DEPTH_COUNT = COUNT_W'(DEPTH);
    localparam logic [ADDR_W-1:0]  PTR_LAST    = ADDR_W'(DEPTH-1);

    logic [DATA_W-1:0] mem [0:DEPTH-1];

    logic [ADDR_W-1:0] wr_ptr;
    logic [ADDR_W-1:0] rd_ptr;

    logic wr_en;
    logic rd_en;

    assign empty = (count == '0);
    assign full  = (count == DEPTH_COUNT);

    assign s_tready = !full;
    assign m_tvalid = !empty;
    assign m_tdata  = mem[rd_ptr];

    assign wr_en = s_tvalid && s_tready;
    assign rd_en = m_tvalid && m_tready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end else begin
            if (wr_en) begin
                mem[wr_ptr] <= s_tdata;

                if (wr_ptr == PTR_LAST)
                    wr_ptr <= '0;
                else
                    wr_ptr <= wr_ptr + 1'b1;
            end

            if (rd_en) begin
                if (rd_ptr == PTR_LAST)
                    rd_ptr <= '0;
                else
                    rd_ptr <= rd_ptr + 1'b1;
            end

            unique case ({wr_en, rd_en})
                2'b10: count <= count + 1'b1; // write only
                2'b01: count <= count - 1'b1; // read only
                default: count <= count;      // idle or simultaneous read/write
            endcase
        end
    end

endmodule
