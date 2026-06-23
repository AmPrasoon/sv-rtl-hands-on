`timescale 1ns/1ps

module tb_axis_sync_fifo;

    localparam int DATA_W = 32;
    localparam int DEPTH  = 8;

    logic clk;
    logic rst_n;

    logic [DATA_W-1:0] s_tdata;
    logic              s_tvalid;
    logic              s_tready;

    logic [DATA_W-1:0] m_tdata;
    logic              m_tvalid;
    logic              m_tready;

    logic              full;
    logic              empty;
    logic [$clog2(DEPTH+1)-1:0] count;

    axis_sync_fifo_core #(
        .DATA_W(DATA_W),
        .DEPTH (DEPTH)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),

        .s_tdata  (s_tdata),
        .s_tvalid (s_tvalid),
        .s_tready (s_tready),

        .m_tdata  (m_tdata),
        .m_tvalid (m_tvalid),
        .m_tready (m_tready),

        .full     (full),
        .empty    (empty),
        .count    (count)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic reset_dut();
        begin
            rst_n    = 1'b0;
            s_tdata  = '0;
            s_tvalid = 1'b0;
            m_tready = 1'b0;

            repeat (5) @(posedge clk);

            @(negedge clk);
            rst_n = 1'b1;

            repeat (2) @(posedge clk);
        end
    endtask

    task automatic axis_write(input logic [DATA_W-1:0] data);
        begin
            @(negedge clk);
            s_tdata  = data;
            s_tvalid = 1'b1;

            while (!s_tready) begin
                @(posedge clk);
            end

            @(negedge clk);
            s_tvalid = 1'b0;
            s_tdata  = '0;
        end
    endtask

    task automatic axis_read(output logic [DATA_W-1:0] data);
        begin
            @(negedge clk);
            m_tready = 1'b1;

            while (!m_tvalid) begin
                @(posedge clk);
            end

            data = m_tdata;

            @(negedge clk);
            m_tready = 1'b0;
        end
    endtask

    initial begin
        logic [DATA_W-1:0] rdata;

        $display("Starting SystemVerilog FIFO test...");

        reset_dut();

        if (empty !== 1'b1) begin
            $fatal(1, "FIFO should be empty after reset");
        end

        if (full !== 1'b0) begin
            $fatal(1, "FIFO should not be full after reset");
        end

        axis_write(32'h0000_0011);
        axis_write(32'h0000_0022);
        axis_write(32'h0000_0033);

        if (count !== 3) begin
            $fatal(1, "Expected count=3, got %0d", count);
        end

        axis_read(rdata);
        if (rdata !== 32'h0000_0011) begin
            $fatal(1, "Expected 0x11, got %h", rdata);
        end

        axis_read(rdata);
        if (rdata !== 32'h0000_0022) begin
            $fatal(1, "Expected 0x22, got %h", rdata);
        end

        axis_read(rdata);
        if (rdata !== 32'h0000_0033) begin
            $fatal(1, "Expected 0x33, got %h", rdata);
        end

        repeat (2) @(posedge clk);

        if (empty !== 1'b1) begin
            $fatal(1, "FIFO should be empty after all reads");
        end

        if (count !== 0) begin
            $fatal(1, "Expected count=0, got %0d", count);
        end

        $display("SystemVerilog FIFO test PASSED.");
        $finish;
    end

endmodule
