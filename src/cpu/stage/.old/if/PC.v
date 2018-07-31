`timescale 1ns / 1ps

`include "bus.v"

module PC(
    input clk,
    input rst,
    // pipeline stall signal
    input stall_pc,
    // branch signal
    input branch_en,
    input [`ADDR_BUS] branch_addr,
    // ROM control signal
    output reg rom_en,
    output reg[`ADDR_BUS] addr
);

    always @(posedge clk) begin
        rom_en <= rst;
    end

    always @(posedge clk) begin
        if (!rom_en) begin
            addr <= `ADDR_BUS_WIDTH'b0;
        end
        else if (!stall_pc) begin
            if (branch_en) begin
                addr <= branch_addr;
            end
            else begin
                addr <= addr + 4;
            end
        end
    end

endmodule // PC