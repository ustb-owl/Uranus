`timescale 1ns / 1ps

// cache: write back

module CacheL1Inst(
    input clk,
    input rst,
    // cache control
    input cache_write_en,            // burst
    input [31:0] cache_write_addr,
    input [31:0] cache_write_data,
    input cache_read_en,
    input [31:0] cache_read_addr,
    output [31:0] cache_read_data,
);

    reg[4095:0] cache_mem;

    always @(posedge clk) begin
        if (!rst) begin
            //
        end
        else begin
            //
        end
    end

endmodule // CacheL1
