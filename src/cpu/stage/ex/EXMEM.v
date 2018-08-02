`timescale 1ns / 1ps

`include "../../define/bus.v"

module EXMEM(
    input clk,
    input rst,
    // input from EX stage
    input mem_read_flag_in,
    input mem_write_flag_in,
    input mem_sign_ext_flag_in,
    input [3:0] mem_sel_in,
    input [`DATA_BUS] mem_write_data_in,
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    input hilo_write_en_in,
    input [`DATA_BUS] hi_in,
    input [`DATA_BUS] lo_in,
    // output to MEM stage
    output mem_read_flag_out,
    output mem_write_flag_out,
    output mem_sign_ext_flag_out,
    output [3:0] mem_sel_out,
    output [`DATA_BUS] mem_write_data_out,
    // output to WB stage
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    // HI & LO control
    output hilo_write_en_out,
    output [`DATA_BUS] hi_out,
    output [`DATA_BUS] lo_out
);

    PipelineDeliver #(1) ff_mem_read_flag(
        clk, rst,
        mem_read_flag_in, mem_read_flag_out
    );

    PipelineDeliver #(1) ff_mem_write_flag(
        clk, rst,
        mem_write_flag_in, mem_write_flag_out
    );

    PipelineDeliver #(1) ff_mem_sign_ext_flag(
        clk, rst,
        mem_sign_ext_flag_in, mem_sign_ext_flag_out
    );

    PipelineDeliver #(4) ff_mem_sel(
        clk, rst,
        mem_sel_in, mem_sel_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_mem_write_data(
        clk, rst,
        mem_write_data_in, mem_write_data_out
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
