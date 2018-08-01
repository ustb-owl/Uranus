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
    output reg[`ADDR_BUS] addr
);

    always @(posedge clk) begin
        rom_en <= rst;
    end

    always @(posedge clk) begin
        if (!rom_en) begin
            addr <= 0;
        end
        else if (branch_flag) begin
            addr <= branch_addr;
        end
        else begin
            addr <= addr + 4;
        end
    end

endmodule // PC
