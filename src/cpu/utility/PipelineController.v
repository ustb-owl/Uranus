`timescale 1ns / 1ps

module PipelineController(
    input rst,
    input request_from_id,
    input request_from_ex,
    output stall_pc,
    output stall_if,
    output stall_id,
    output stall_ex,
    output stall_mem,
    output stall_wb
);

    // the stall signal of PC, IF, ID, EX, MEM, WB
    reg[5:0] stall;

    // assign the output of the stall signal
    assign {stall_wb, stall_mem, stall_ex,
            stall_id, stall_if, stall_pc} = stall;

    // generate the stall signal
    always @(*) begin
        if (!rst) begin
            stall <= 6'b000000;
        end
        else if (request_from_id) begin
            stall <= 6'b000111;
        end
        else if (request_from_ex) begin
            stall <= 6'b001111;
        end
        else begin
            stall <= 6'b000000;
        end
    end

endmodule // PipelineController
