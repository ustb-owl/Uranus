`timescale 1ns / 1ps

`include "bus.v"

module PC(
    input clk,
    input rst,
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
        else begin
            addr <= addr + 4;
        end
    end

endmodule // PC
