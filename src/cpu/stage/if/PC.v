`timescale 1ns / 1ps

`include "../../define/bus.v"

module PC(
    input clk,
    input rst,
    // branch control
    input branch_flag,
    input [`ADDR_BUS] branch_addr,
    // output to ROM
    output reg rom_en,
    output [3:0] rom_write_en,
    output reg[`ADDR_BUS] rom_addr,
    output [`DATA_BUS] rom_write_data
);

    assign rom_wen = 0;
    assign rom_write_data = 0;

    always @(posedge clk) begin
        rom_en <= rst;
    end

    always @(posedge clk) begin
        if (!rom_en) begin
            rom_addr <= `ADDR_BUS_WIDTH'hbfc00000;
        end
        else if (branch_flag) begin
            rom_addr <= branch_addr;
        end
        else begin
            rom_addr <= rom_addr + 4;
        end
    end

endmodule // PC
