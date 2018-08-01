`timescale 1ns / 1ps

`include "../define/bus.v"

module CP0(
    input clk,
    input rst,
    input [`CP0_ADDR_BUS] read_addr,
    input [5:0] interrupt,
    input write_en,
    input [`CP0_ADDR_BUS] write_addr,
    input [`DATA_BUS] write_data,
    output reg[`DATA_BUS] data_out
);

    always @(posedge clk) begin
        if (!rst) begin
            //
        end
        else begin
            //
        end
    end

endmodule // CP0
