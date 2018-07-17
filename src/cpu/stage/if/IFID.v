`timescale 1ns / 1ps

`include "bus.v"

module IFID(
    input clk,
    input rst,
    input stall_current,
    input stall_next,
    input [`ADDR_BUS] addr_in,
    input [`INST_BUS] inst_in,
    output [`ADDR_BUS] addr_out,
    output [`INST_BUS] inst_out
);

    PiplineDeliver #(`ADDR_BUS_WIDTH) ff_addr(
        clk, rst,
        stall_current, stall_next,
        addr_in, addr_out
    );

    PiplineDeliver #(`INST_BUS_WIDTH) ff_inst(
        clk, rst,
        stall_current, stall_next,
        inst_in, inst_out
    );

endmodule // IFID
