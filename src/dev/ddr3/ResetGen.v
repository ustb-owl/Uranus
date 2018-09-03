`timescale 1ns / 1ps

module ResetGenerator(
    input ddr_ui_clk,
    input ddr_ui_clk_rst,
    input ddr_calib_done,
    output reg ddr_interconn_rst
);

    always @(posedge ddr_ui_clk) begin
        ddr_interconn_rst <= ~ddr_ui_clk_rst && ddr_calib_done;
    end

endmodule // ResetGenerator
