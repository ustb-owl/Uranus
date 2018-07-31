`timescale 1ns / 1ps

`include "bus.v"

module MEM(
    input rst,
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out
);

    assign result_out = rst ? result_in : 0;
    assign write_reg_en_out = rst ? write_reg_en_in : 0;
    assign write_reg_addr_out = rst ? write_reg_addr_in : 0;

endmodule // MEM
