`timescale 1ns / 1ps

module PiplineDeliver #(parameter width = 1) (
    input clk,
    input rst,
    input stall_current,
    input stall_next,
    input [width - 1:0] in,
    output reg[width - 1:0] out
);

    always@(posedge clk) begin
        if (!rst) begin
            out <= 0;
        end
        else if (stall_current && !stall_next) begin
            out <= 0;
        end
        else if (!stall_current) begin
            out <= in;
        end
    end

endmodule // PiplineDeliver
