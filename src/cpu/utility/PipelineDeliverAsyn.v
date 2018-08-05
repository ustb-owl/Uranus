`timescale 1ns / 1ps

module PipelineDeliverAsyn #(parameter width = 1) (
    input clk,
    input rst,
    input stall_current_stage_in,
    input stall_next_stage_in,
    input [width - 1:0] in,
    output reg[width - 1:0] out
);

    reg stall_current, stall_next;
    wire stall_current_stage, stall_next_stage;

    // NOTE: glitch?
    assign stall_current_stage = stall_current_stage_in | stall_current;
    assign stall_next_stage = stall_next_stage_in | stall_next;

    // delay one more tick for stall signals
    always @(posedge clk) begin
        stall_current <= stall_current_stage_in;
        stall_next <= stall_next_stage_in;
    end

    always @(*) begin
        if (!rst) begin
            out <= 0;
        end
        else if (stall_current_stage && !stall_next_stage) begin
            out <= 0;
        end
        else if (!stall_current_stage) begin
            out <= in;
        end
    end

endmodule // PipelineDeliverAsyn
