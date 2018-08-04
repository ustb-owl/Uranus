`timescale 1ns / 1ps

module CPU_tb();

    reg clk, rst;

    wire ram_en;
    wire[3:0] ram_write_en;
    wire[31:0] ram_addr;
    wire[31:0] ram_write_data;
    wire[31:0] ram_read_data;

    wire rom_en;
    // wire[3:0] rom_write_en;
    wire[31:0] rom_addr;
    // wire[31:0] rom_write_data;
    wire[31:0] rom_read_data;

    wire[31:0] debug_pc_addr;
    wire[3:0] debug_reg_write_en;
    wire[4:0] debug_reg_write_addr;
    wire[31:0] debug_reg_write_data;

    Uranus cpu(
        .clk(clk),
        .rst(rst),
        .ram_en(ram_en),
        .ram_write_en(ram_write_en),
        .ram_addr(ram_addr),
        .ram_write_data(ram_write_data),
        .ram_read_data(ram_read_data),
        .rom_en(rom_en),
        // .rom_write_en(rom_write_en),
        .rom_addr(rom_addr),
        // .rom_write_data(rom_write_data),
        .rom_read_data(rom_read_data),
        .debug_pc_addr(debug_pc_addr),
        .debug_reg_write_en(debug_reg_write_en),
        .debug_reg_write_addr(debug_reg_write_addr),
        .debug_reg_write_data(debug_reg_write_data)
    );

    RAM_tb ram(
        clk, rst, ram_en, ram_write_en,
        ram_addr, ram_write_data, ram_read_data
    );

    ROM_tb rom(
        rom_en, rom_addr, rom_read_data
    );

    initial begin
        clk = 0;
        rst = 0;
        #7 rst = 1;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule // CPU_tb
