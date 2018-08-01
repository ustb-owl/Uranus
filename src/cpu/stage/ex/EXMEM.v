`timescale 1ns / 1ps

`include "../../define/bus.v"

module EXMEM(
    input clk,
    input rst,
    // input from EX stage
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    input hilo_write_en_in,
    input [`DATA_BUS] hi_in,
    input [`DATA_BUS] lo_in,
    // output to MEM (and WB) stage
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    // HI & LO control
    output hilo_write_en_out,
    output [`DATA_BUS] hi_out,
    output [`DATA_BUS] lo_out
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

    PipelineDeliver #(1) ff_hilo_write_en(
        clk, rst,
        hilo_write_en_in, hilo_write_en_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_hi(
        clk, rst, hi_in, hi_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_lo(
        clk, rst, lo_in, lo_out
    );

endmodule // EXMEM
