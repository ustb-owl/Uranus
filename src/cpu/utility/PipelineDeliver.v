`timescale 1ns / 1ps

module PipelineDeliver #(parameter width = 1) (
    input clk,
    input rst,
    input [width - 1:0] in,
    output reg[width - 1:0] out
);

    always@(posedge clk) begin
        if (!rst) begin
            out <= 0;
        end
        else begin
            out <= in;
        end
    end

endmodule // PiplineDeliver
