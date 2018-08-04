`timescale 1ns / 1ps

`include "../../define/bus.v"

module MEMWB(
    input clk,
    input rst,
    input stall_current_stage,
    input stall_next_stage,
    // input from MEM stage
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    input [`ADDR_BUS] debug_pc_addr_in,
    input hilo_write_en_in,
    input [`DATA_BUS] hi_in,
    input [`DATA_BUS] lo_in,
    // regfile
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    // HI & LO
    output hilo_write_en_out,
    output [`DATA_BUS] hi_out,
    output [`DATA_BUS] lo_out,
    // debug signals
    output [`ADDR_BUS] debug_pc_addr_out,
    output [3:0] debug_reg_write_en
);

    assign debug_reg_write_en = {4{write_reg_en_out}};

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_result(
        clk, rst,
        stall_current_stage, stall_next_stage,
        result_in, result_out
    );

    PipelineDeliver #(1) ff_write_reg_en(
        clk, rst,
        stall_current_stage, stall_next_stage,
        write_reg_en_in, write_reg_en_out
    );

    PipelineDeliver #(`REG_ADDR_BUS_WIDTH) ff_write_reg_addr(
        clk, rst,
        stall_current_stage, stall_next_stage,
        write_reg_addr_in, write_reg_addr_out
    );

    PipelineDeliver #(1) ff_hilo_write_en(
        clk, rst,
        stall_current_stage, stall_next_stage,
        hilo_write_en_in, hilo_write_en_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_hi(
        clk, rst,
        stall_current_stage, stall_next_stage,
        hi_in, hi_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_lo(
        clk, rst,
        stall_current_stage, stall_next_stage,
        lo_in, lo_out
    );

    PipelineDeliver #(`ADDR_BUS_WIDTH) ff_debug_pc_addr(
        clk, rst,
        stall_current_stage, stall_next_stage,
        debug_pc_addr_in, debug_pc_addr_out
    );

endmodule // MEMWB
