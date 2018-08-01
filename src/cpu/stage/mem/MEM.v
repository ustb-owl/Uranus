`timescale 1ns / 1ps

`include "../../define/bus.v"

module MEM(
    input rst,
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    input hilo_write_en_in,
    input [`DATA_BUS] hi_in,
    input [`DATA_BUS] lo_in,
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    output hilo_write_en_out,
    output [`DATA_BUS] hi_out,
    output [`DATA_BUS] lo_out
);

    assign result_out = rst ? result_in : 0;
    assign write_reg_en_out = rst ? write_reg_en_in : 0;
    assign write_reg_addr_out = rst ? write_reg_addr_in : 0;
    assign hilo_write_en_out = rst ? hilo_write_en_in : 0;
    assign hi_out = rst ? hi_in : 0;
    assign lo_out = rst ? lo_in : 0;

endmodule // MEM
