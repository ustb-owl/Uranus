`timescale 1ns / 1ps

`include "../../define/bus.v"

module IFID(
    input clk,
    input rst,
    input [`ADDR_BUS] addr_in,
    input [`INST_BUS] inst_in,
    output [`ADDR_BUS] addr_out,
    output [`INST_BUS] inst_out
);

    PipelineDeliver #(`ADDR_BUS_WIDTH) ff_addr(
        clk, rst,
        addr_in, addr_out
    );

    PipelineDeliver #(`INST_BUS_WIDTH) ff_inst(
        clk, rst,
        inst_in, inst_out
    );

endmodule // IFID
