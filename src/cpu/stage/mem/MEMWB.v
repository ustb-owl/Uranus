`timescale 1ns / 1ps

`include "../../define/bus.v"

module MEMWB(
    input clk,
    input rst,
    input stall_current_stage,
    input stall_next_stage,
    // RAM control signals
    input [`DATA_BUS] ram_read_data_in,
    // input from MEM stage
    input mem_read_flag_in,
    input mem_write_flag_in,
    input mem_sign_ext_flag_in,
    input [3:0] mem_sel_in,
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    input [`ADDR_BUS] debug_pc_addr_in,
    input hilo_write_en_in,
    input [`DATA_BUS] hi_in,
    input [`DATA_BUS] lo_in,
    input cp0_write_en_in,
    input [`CP0_ADDR_BUS] cp0_addr_in,
    input [`DATA_BUS] cp0_write_data_in,
    // RAM data
    output [`DATA_BUS] ram_read_data_out,
    // memory accessing signals
    output mem_read_flag_out,
    output mem_write_flag_out,
    output mem_sign_ext_flag_out,
    output [3:0] mem_sel_out,
    // regfile
    output [`DATA_BUS] result_out,
    output write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    // HI & LO
    output hilo_write_en_out,
    output [`DATA_BUS] hi_out,
    output [`DATA_BUS] lo_out,
    // coprocessor 0 control
    output cp0_write_en_out,
    output [`CP0_ADDR_BUS] cp0_addr_out,
    output [`DATA_BUS] cp0_write_data_out,
    // debug signals
    output [`ADDR_BUS] debug_pc_addr_out
);

    PipelineDeliverAsyn #(`DATA_BUS_WIDTH) ff_ram_read_data(
        clk, rst,
        stall_current_stage, stall_next_stage,
        ram_read_data_in, ram_read_data_out
    );

    PipelineDeliver #(1) ff_mem_read_flag(
        clk, rst,
        stall_current_stage, stall_next_stage,
        mem_read_flag_in, mem_read_flag_out
    );

    PipelineDeliver #(1) ff_mem_write_flag(
        clk, rst,
        stall_current_stage, stall_next_stage,
        mem_write_flag_in, mem_write_flag_out
    );

    PipelineDeliver #(1) ff_mem_sign_ext_flag(
        clk, rst,
        stall_current_stage, stall_next_stage,
        mem_sign_ext_flag_in, mem_sign_ext_flag_out
    );

    PipelineDeliver #(4) ff_mem_sel(
        clk, rst,
        stall_current_stage, stall_next_stage,
        mem_sel_in, mem_sel_out
    );

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

    PipelineDeliver #(1) ff_cp0_write_en(
        clk, rst,
        stall_current_stage, stall_next_stage,
        cp0_write_en_in, cp0_write_en_out
    );

    PipelineDeliver #(`CP0_ADDR_BUS_WIDTH) ff_cp0_addr(
        clk, rst,
        stall_current_stage, stall_next_stage,
        cp0_addr_in, cp0_addr_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_cp0_write_data(
        clk, rst,
        stall_current_stage, stall_next_stage,
        cp0_write_data_in, cp0_write_data_out
    );

    PipelineDeliver #(`ADDR_BUS_WIDTH) ff_debug_pc_addr(
        clk, rst,
        0, 0,
        debug_pc_addr_in, debug_pc_addr_out
    );

endmodule // MEMWB
