`timescale 1ns / 1ps

`include "debug.v"

module Top(
    input clk,
    input rst,
    // GPIO
    input [7:0] switch,
    input [3:0] keypad_row,
    output [3:0] keypad_col,
    output [1:0] bicolor_led_0,
    output [1:0] bicolor_led_1,
    output [15:0] led,
    output [7:0] seg_sel,
    output [7:0] seg_bit,
    // SPI
    inout spi_mosi,
    inout spi_miso,
    inout spi_io2,   // quad mode
    inout spi_io3,   // quad mode
    inout spi_sck,
    inout spi_ss,
    // UART
    input uart_rxd,
    output uart_txd,
    // DDR3
    inout [15:0] ddr3_dq,
    inout [1:0] ddr3_dqs_p,
    inout [1:0] ddr3_dqs_n,
    output [12:0] ddr3_addr,
    output [2:0] ddr3_ba,
    output ddr3_ras_n,
    output ddr3_cas_n,
    output ddr3_we_n,
    output ddr3_reset_n,
    output ddr3_ck_p,
    output ddr3_ck_n,
    output ddr3_cke,
    output [1:0] ddr3_dm,
    output ddr3_odt,
    // VGA
    inout [3:0] vga_r,
    inout [3:0] vga_g,
    inout [3:0] vga_b,
    output vga_hsync,
    output vga_vsync
);

    // SPI
    wire spi_io0_i, spi_io0_o, spi_io0_t, spi_io1_i, spi_io1_o, spi_io1_t;
    // wire spi_io2_i, spi_io2_o, spi_io2_t, spi_io3_i, spi_io3_o, spi_io3_t;
    wire spi_sck_i, spi_sck_o, spi_sck_t, spi_ss_i, spi_ss_o, spi_ss_t;

    assign spi_io2 = 1'bz; assign spi_io3 = 1'bz;

    IOBUF spi_mosi_iob(.IO(spi_mosi), .I(spi_io0_o), .O(spi_io0_i), .T(spi_io0_t));
    IOBUF spi_miso_iob(.IO(spi_miso), .I(spi_io1_o), .O(spi_io1_i), .T(spi_io1_t));
    // IOBUF spi_io2_iob(.IO(spi_io2), .I(spi_io2_o), .O(spi_io2_i), .T(spi_io2_t));
    // IOBUF spi_io3_iob(.IO(spi_io3), .I(spi_io3_o), .O(spi_io3_i), .T(spi_io3_t));
    IOBUF spi_sck_iob(.IO(spi_sck), .I(spi_sck_o), .O(spi_sck_i), .T(spi_sck_t));
    IOBUF spi_ss_iob(.IO(spi_ss), .I(spi_ss_o), .O(spi_ss_i), .T(spi_ss_t));

    // VGA
    wire[5:0] vga_red, vga_green, vga_blue;

    assign vga_r[0] = vga_red[2] ? 1'b1 : 1'bz; assign vga_r[1] = vga_red[3] ? 1'b1 : 1'bz;
    assign vga_r[2] = vga_red[4] ? 1'b1 : 1'bz; assign vga_r[3] = vga_red[5] ? 1'b1 : 1'bz;
    assign vga_g[0] = vga_green[2] ? 1'b1 : 1'bz; assign vga_g[1] = vga_green[3] ? 1'b1 : 1'bz;
    assign vga_g[2] = vga_green[4] ? 1'b1 : 1'bz; assign vga_g[3] = vga_green[5] ? 1'b1 : 1'bz;
    assign vga_b[0] = vga_blue[2] ? 1'b1 : 1'bz; assign vga_b[1] = vga_blue[3] ? 1'b1 : 1'bz;
    assign vga_b[2] = vga_blue[4] ? 1'b1 : 1'bz; assign vga_b[3] = vga_blue[5] ? 1'b1 : 1'bz;

    // SoC
    SoC soc(
        // clock & reset
        .clk(clk),
        .rstn(rst),
        // GPIO
        .gpio_switch(switch),
        .gpio_keypad_row(keypad_row),
        .gpio_keypad_col(keypad_col),
        .gpio_bicolor_led_0(bicolor_led_0),
        .gpio_bicolor_led_1(bicolor_led_1),
        .gpio_led(led),
        .gpio_seg_sel(seg_sel),
        .gpio_seg_bit(seg_bit),
        // SPI
        .spi_io0_i(spi_io0_i),
        .spi_io0_o(spi_io0_o),
        .spi_io0_t(spi_io0_t),
        .spi_io1_i(spi_io1_i),
        .spi_io1_o(spi_io1_o),
        .spi_io1_t(spi_io1_t),
        // .spi_io2_i(spi_io2_i),
        // .spi_io2_o(spi_io2_o),
        // .spi_io2_t(spi_io2_t),
        // .spi_io3_i(spi_io3_i),
        // .spi_io3_o(spi_io3_o),
        // .spi_io3_t(spi_io3_t),
        .spi_sck_i(spi_sck_i),
        .spi_sck_o(spi_sck_o),
        .spi_sck_t(spi_sck_t),
        .spi_ss_i(spi_ss_i),
        .spi_ss_o(spi_ss_o),
        .spi_ss_t(spi_ss_t),
        // UART
        .uart_ctsn(1'b0),
        .uart_dcdn(1'b0),
        .uart_dsrn(1'b0),
        .uart_ri(1'b1),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd),
        // DDR3
        .ddr3_dq(ddr3_dq),
        .ddr3_dqs_p(ddr3_dqs_p),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_addr(ddr3_addr),
        .ddr3_ba(ddr3_ba),
        .ddr3_ras_n(ddr3_ras_n),
        .ddr3_cas_n(ddr3_cas_n),
        .ddr3_we_n(ddr3_we_n),
        .ddr3_reset_n(ddr3_reset_n),
        .ddr3_ck_p(ddr3_ck_p),
        .ddr3_ck_n(ddr3_ck_n),
        .ddr3_cke(ddr3_cke),
        .ddr3_dm(ddr3_dm),
        .ddr3_odt(ddr3_odt),
        // VGA
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync)
    );

endmodule // Top
