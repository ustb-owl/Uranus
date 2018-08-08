`timescale 1ns / 1ps

`include "../define/bus.v"

`define RAM_RANGE(l, u) ram_addr_in >= (l) && ram_addr_in <= (u)

module MMU(
    input rst,
    input [`ADDR_BUS] ram_addr_in,
    output reg[`ADDR_BUS] ram_addr_out
);

    always @(*) begin
        if (!rst) begin
            ram_addr_out <= 0;
        end
        else begin
            if (`RAM_RANGE(0, 32'h7fff_ffff)) begin
                ram_addr_out <= ram_addr_in;
            end
            else if (`RAM_RANGE(32'h8000_0000, 32'h9fff_ffff)) begin
                ram_addr_out <= ram_addr_in - 32'h8000_0000;
            end
            else if (`RAM_RANGE(32'ha000_0000, 32'hbfff_ffff)) begin
                ram_addr_out <= ram_addr_in - 32'ha000_0000;
            end
            else if (`RAM_RANGE(32'hc000_0000, 32'hdfff_ffff)) begin
                ram_addr_out <= ram_addr_in;
            end
            else begin   // 32'he000_0000, 32'hffff_ffff
                ram_addr_out <= ram_addr_in;
            end
        end
    end

endmodule // MMU
