`timescale 1ns/1ps

module axis_sync_fifo_if_wrap #(
    parameter int DATA_W = 32,
    parameter int DEPTH  = 8
) (
    input logic aclk,
    input logic aresetn,

    axis_stream_if.slave  s_axis,
    axis_stream_if.master m_axis,

    output logic full,
    output logic empty,
    output logic [$clog2(DEPTH+1)-1:0] count
);

    axis_sync_fifo_core #(
        .DATA_W(DATA_W),
        .DEPTH (DEPTH)
    ) u_fifo_core (
        .clk      (aclk),
        .rst_n    (aresetn),

        .s_tdata  (s_axis.tdata),
        .s_tvalid (s_axis.tvalid),
        .s_tready (s_axis.tready),

        .m_tdata  (m_axis.tdata),
        .m_tvalid (m_axis.tvalid),
        .m_tready (m_axis.tready),

        .full     (full),
        .empty    (empty),
        .count    (count)
    );

endmodule
