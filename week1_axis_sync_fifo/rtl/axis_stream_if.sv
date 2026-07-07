`timescale 1ns/1ps

interface axis_stream_if #(
    parameter int DATA_W = 32
) (
    input logic aclk,
    input logic aresetn
);

    logic [DATA_W-1:0] tdata;
    logic              tvalid;
    logic              tready;

    // Source/master side:
    // drives tdata and tvalid, receives tready.
    modport master (
        input  aclk,
        input  aresetn,
        output tdata,
        output tvalid,
        input  tready
    );

    // Destination/slave side:
    // receives tdata and tvalid, drives tready.
    modport slave (
        input  aclk,
        input  aresetn,
        input  tdata,
        input  tvalid,
        output tready
    );

    // Passive monitor:
    // observes the stream without driving it.
    modport monitor (
        input aclk,
        input aresetn,
        input tdata,
        input tvalid,
        input tready
    );

endinterface
