`timescale 1ns / 1ps

`include "../define/bus.v"

module RAM(
    input clk,
    input rst,
    input en,
    input write_en,
    input write_sel,
    input [`ADDR_BUS] addr,
    input [`DATA_BUS] data_in,
    output reg[`DATA_BUS] data_out
);

    parameter kSubRamSize = 128;

    reg[7:0] ram0[0:kSubRamSize - 1];
    reg[7:0] ram1[0:kSubRamSize - 1];
    reg[7:0] ram2[0:kSubRamSize - 1];
    reg[7:0] ram3[0:kSubRamSize - 1];

    wire out_en = rst && en && !write_en;
    always @(*) begin
        data_out[7:0] = out_en && !addr[31:9] && !addr[1:0] ?
                ram3[addr[31:2]] : 8'b0;
        data_out[15: 8] = out_en && !addr[31:9] && !addr[1:0] ?
                ram2[addr[31:2]] : 8'b0;
        data_out[23:16] = out_en && !addr[31:9] && !addr[1:0] ?
                ram1[addr[31:2]] : 8'b0;
        data_out[31:24] = out_en && !addr[31:9] && !addr[1:0] ?
                ram0[addr[31:2]] : 8'b0;
    end

    reg inner_en;
    always @(posedge clk) begin
        inner_en <= write_en && en && rst;
    end

    always @(posedge inner_en) begin
        if (inner_en && !addr[31:9] && !addr[1:0]) begin
            if (write_sel[0]) ram3[addr[31:2]] <= data_in[7:0];
            if (write_sel[1]) ram2[addr[31:2]] <= data_in[15:8];
            if (write_sel[2]) ram1[addr[31:2]] <= data_in[23:16];
            if (write_sel[3]) ram0[addr[31:2]] <= data_in[31:24];
        end
    end

endmodule // RAM
