`timescale 1ns / 1ps

`include "../define/bus.v"

module ROM(
    input en,
    input [`ADDR_BUS] addr,
    output [`INST_BUS] inst
);

    reg[7:0] rom[0:511];

    initial begin
        $readmemh("rom/inst.bin", rom);
    end

    // big endian storage
    assign inst[7:0] = (en ? rom[addr + 3] : 8'b0);
    assign inst[15:8] = (en ? rom[addr + 2] : 8'b0);
    assign inst[23:16] = (en ? rom[addr + 1] : 8'b0);
    assign inst[31:24] = (en ? rom[addr + 0] : 8'b0);

endmodule // ROM
