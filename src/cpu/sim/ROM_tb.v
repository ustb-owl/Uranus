`timescale 1ns / 1ps

`include "../define/bus.v"

module ROM_tb(
    // synchronous ROM
    input clk,
    input rst,
    input en,
    input [`ADDR_BUS] addr,
    output reg[`INST_BUS] inst
);

    reg[7:0] rom[0:511];

    initial begin
        $readmemh("rom/inst.bin", rom);
    end

    always @(posedge clk) begin
        if (!rst || !en) begin
            inst <= 0;
        end
        else begin
            // big endian storage
            inst[7:0] <= rom[(addr + 3) & 32'h000fffff];
            inst[15:8] <= rom[(addr + 2) & 32'h000fffff];
            inst[23:16] <= rom[(addr + 1) & 32'h000fffff];
            inst[31:24] <= rom[(addr + 0) & 32'h000fffff];
        end
    end


endmodule // ROM_tb
