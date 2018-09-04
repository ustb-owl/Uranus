`timescale 1ns / 1ps

module Keypad(
    input clk,
    input rst,
    // keypad control
    input [3:0] keypad_row,
    output [3:0] keypad_col,
    // data output
    output [15:0] keypad
);

    assign keypad_col = 0;
    assign keypad = 0;

endmodule // Keypad
