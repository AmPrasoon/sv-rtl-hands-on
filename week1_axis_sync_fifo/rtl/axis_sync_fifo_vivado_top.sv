`timescale 1ns/1ps

module axis_sync_fifo_vivado_top #(
    parameter int C_AXIS_TDATA_WIDTH = 32,
    parameter int FIFO_DEPTH         = 8
) (
    input  logic aclk,
    input  logic aresetn,

    // AXI4-Stream slave/input side
    input  logic [C_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
    input  logic                          s_axis_tvalid,
    output logic                          s_axis_tready,

    // AXI4-Stream master/output side
    output logic [C_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
    output logic                          m_axis_tvalid,
    input  logic                          m_axis_tready,

    // Optional debug/status outputs
    output logic                          fifo_full,
    output logic                          fifo_empty
);

    logic [$clog2(FIFO_DEPTH+1)-1:0] fifo_count;

    axis_sync_fifo_core #(
        .DATA_W(C_AXIS_TDATA_WIDTH),
        .DEPTH (FIFO_DEPTH)
    ) u_fifo_core (
        .clk      (aclk),
        .rst_n    (aresetn),

        .s_tdata  (s_axis_tdata),
        .s_tvalid (s_axis_tvalid),
        .s_tready (s_axis_tready),

        .m_tdata  (m_axis_tdata),
        .m_tvalid (m_axis_tvalid),
        .m_tready (m_axis_tready),

        .full     (fifo_full),
        .empty    (fifo_empty),
        .count    (fifo_count)
    );

endmodule
