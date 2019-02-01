`timescale 1ns / 1ps

// direct mapped cache line

module CacheLine #(parameter
    ADDR_WIDTH = 32,
    LINE_WIDTH = 6,         // 2^6 = 64 bytes/line
    CACHE_WIDTH = 6         // 2^6 = 64 lines
    `define INDEX_WIDTH     ((LINE_WIDTH) - 2)
    `define TAG_WIDTH       ((ADDR_WIDTH) - (LINE_WIDTH) - (CACHE_WIDTH))
) (
    input clk,
    input rst,
    input write_en,
    // input signals
    input valid_in,
    input tag_in,
    input dirty_in,
    input [`INDEX_WIDTH - 1:0] index_in,
    input [31:0] data_in,
    // output signals
    output valid_out,
    output tag_out,
    output dirty_out,
    output [31:0] data_out,
);

    reg valid, dirty;
    reg[`TAG_WIDTH - 1:0] tag;
    reg[31:0] data[2 ** `INDEX_WIDTH - 1:0];

    assign valid_out = valid;
    assign tag_out = tag;
    assign dirty_out = valid ? dirty : 0;
    assign data_out = valid ? data[index_in] : 0;

    always @(posedge clk) begin
        if (!rst) begin
            valid <= 0;
            tag <= 0;
            dirty <= 0;
        end
        else if (write_en) begin
            valid <= valid_in;
            tag <= tag_in;
            dirty <= dirty_in;
        end
    end

    always @(posedge clk) begin
        if (write_en) begin
            data[index_in] <= data_in;
        end
    end

endmodule // CacheLine
