`timescale 1ns / 1ps

`include "bus.v"

module IDEX(
    input clk,
    input rst,
    // input from ID stage
    input [`FUNCT_BUS] funct_in,
    input [`SHAMT_BUS] shamt_in,
    input [`DATA_BUS] operand_1_in,
    input [`DATA_BUS] operand_2_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    // output to EX (and WB) stage
    output [`FUNCT_BUS] funct_out,
    output [`SHAMT_BUS] shamt_out,
    output [`DATA_BUS] operand_1_out,
    output [`DATA_BUS] operand_2_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out
);

    PipelineDeliver #(`FUNCT_BUS_WIDTH) ff_funct(
        clk, rst,
        funct_in, funct_out
    );

    PipelineDeliver #(`SHAMT_BUS_WIDTH) ff_shamt(
        clk, rst,
        shamt_in, shamt_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_operand_1(
        clk, rst,
        operand_1_in, operand_1_out
    );

    PipelineDeliver #(`DATA_BUS_WIDTH) ff_operand_2(
        clk, rst,
        operand_2_in, operand_2_out
    );

    PipelineDeliver #(1) ff_write_reg_en(
        clk, rst,
        write_reg_en_in, write_reg_en_out
    );

    PipelineDeliver #(`REG_ADDR_BUS_WIDTH) ff_write_reg_addr(
        clk, rst,
        write_reg_addr_in, write_reg_addr_out
    );

endmodule // IDEX
