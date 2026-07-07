`timescale 1ns/1ps

module tb_axis_sync_fifo_if_wrap;

    localparam int DATA_W = 32;
    localparam int DEPTH  = 8;

    logic aclk;
    logic aresetn;

    logic full;
    logic empty;
    logic [$clog2(DEPTH+1)-1:0] count;

    axis_stream_if #(
        .DATA_W(DATA_W)
    ) s_axis (
        .aclk    (aclk),
        .aresetn (aresetn)
    );

    axis_stream_if #(
        .DATA_W(DATA_W)
    ) m_axis (
        .aclk    (aclk),
        .aresetn (aresetn)
    );

    axis_sync_fifo_if_wrap #(
        .DATA_W(DATA_W),
        .DEPTH (DEPTH)
    ) dut (
        .aclk    (aclk),
        .aresetn (aresetn),
        .s_axis  (s_axis),
        .m_axis  (m_axis),
        .full    (full),
        .empty   (empty),
        .count   (count)
    );

    initial aclk = 1'b0;
    always #5 aclk = ~aclk;

    task automatic reset_dut();
        begin
            aresetn = 1'b0;

            s_axis.tdata  = '0;
            s_axis.tvalid = 1'b0;
            m_axis.tready = 1'b0;

            repeat (5) @(posedge aclk);

            @(negedge aclk);
            aresetn = 1'b1;

            repeat (2) @(posedge aclk);
        end
    endtask

    task automatic axis_write(input logic [DATA_W-1:0] data);
        begin
            @(negedge aclk);
            s_axis.tdata  = data;
            s_axis.tvalid = 1'b1;

            while (!s_axis.tready) begin
                @(posedge aclk);
            end

            @(negedge aclk);
            s_axis.tvalid = 1'b0;
            s_axis.tdata  = '0;
        end
    endtask

    task automatic axis_read(output logic [DATA_W-1:0] data);
        begin
            @(negedge aclk);
            m_axis.tready = 1'b1;

            while (!m_axis.tvalid) begin
                @(posedge aclk);
            end

            data = m_axis.tdata;

            @(negedge aclk);
            m_axis.tready = 1'b0;
        end
    endtask

    initial begin
        logic [DATA_W-1:0] rdata;

        $display("Starting interface-wrapper FIFO test...");

        reset_dut();

        if (empty !== 1'b1) begin
            $fatal(1, "FIFO should be empty after reset");
        end

        axis_write(32'h0000_00AA);
        axis_write(32'h0000_00BB);

        if (count !== 2) begin
            $fatal(1, "Expected count=2, got %0d", count);
        end

        axis_read(rdata);
        if (rdata !== 32'h0000_00AA) begin
            $fatal(1, "Expected 0xAA, got %h", rdata);
        end

        axis_read(rdata);
        if (rdata !== 32'h0000_00BB) begin
            $fatal(1, "Expected 0xBB, got %h", rdata);
        end

        repeat (2) @(posedge aclk);

        if (empty !== 1'b1) begin
            $fatal(1, "FIFO should be empty after reads");
        end

        $display("Interface-wrapper FIFO test PASSED.");
        $finish;
    end

endmodule
