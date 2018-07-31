`timescale 1ns / 1ps

module CPU_tb();

    reg clk, rst;

    Uranus cpu(clk, rst);

    initial begin
        clk = 0;
        rst = 0;
        #7 rst = 1;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule // CPU_tb
