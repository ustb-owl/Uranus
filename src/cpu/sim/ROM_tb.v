`timescale 1ns / 1ps

`include "../define/bus.v"

module ROM_tb(
    input en,
    input [`ADDR_BUS] addr,
    output [`INST_BUS] inst
);

    reg[7:0] rom[0:511];

    initial begin
        $readmemh("rom/inst.bin", rom);
    end

    // big endian storage
    assign inst[7:0] = en ? rom[(addr + 3) & 32'h000fffff] : 8'b0;
    assign inst[15:8] = en ? rom[(addr + 2) & 32'h000fffff] : 8'b0;
    assign inst[23:16] = en ? rom[(addr + 1) & 32'h000fffff] : 8'b0;
    assign inst[31:24] = en ? rom[(addr + 0) & 32'h000fffff] : 8'b0;

endmodule // ROM_tb
