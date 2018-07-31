`timescale 1ns / 1ps

`include "bus.v"

module MEMWB(
    input clk,
    input rst,
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out
);

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_result(
        clk, rst,
        result_in, result_out
    );

    PipelineDeliver #(1) ff_write_reg_en(
        clk, rst,
        write_reg_en_in, write_reg_en_out
    );

    PipelineDeliver #(`REG_ADDR_BUS_WIDTH) ff_write_reg_addr(
        clk, rst,
        write_reg_addr_in, write_reg_addr_out
    );

endmodule // MEMWB
