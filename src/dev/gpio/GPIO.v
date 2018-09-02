`timescale 1ns / 1ps

module GPIO(
    input clk,
    input clk_timer,   // 100MHz
    input rst,
    // bus IO
    input en,
    input write_en,
    input addr,
    input [31:0] data_in,
    output reg[31:0] data_out,
    // GPIO control
    input [7:0] switch,
    input [15:0] keypad,
    output reg[1:0] bicolor_led_0,
    output reg[1:0] bicolor_led_1,
    output reg[15:0] led,
    output reg[31:0] num
);

    // address definition
    wire[11:0] address = addr[11:0];
    parameter kSwitchAddr = 12'h000, kKeypadAddr = 12'h004,
            kBicolor0Addr = 12'h008, kBicolor1Addr = 12'h00c,
            kLEDAddr = 12'h010, kNumAddr = 12'h014,
            kTimerAddr = 12'h018;

    // flags
    wire read_flag = en && !write_en;
    wire write_flag = en && write_en;

    // timer
    reg[31:0] timer, timer_write_flag;
    wire[31:0] next_timer = timer + 1;
    always @(posedge clk_timer) begin
        if (!rst) begin
            timer <= 0;
            timer_write_flag <= 0;
        end
        else if (!timer_write_flag) begin
            if (write_flag && address == kTimerAddr) begin
                timer <= data_in;
                timer_write_flag <= 1;
            end
            else begin
                timer <= next_timer;
            end
        end
        else if (!write_flag) begin
            timer <= next_timer;
            timer_write_flag <= 0;
        end
        else begin
            timer <= next_timer;
        end
    end

    // read
    always @(posedge clk) begin
        if (!rst) begin
            data_out <= 0;
        end
        else if (read_flag) begin
            case (address)
                kSwitchAddr: data_out <= {24'h0, switch};
                kKeypadAddr: data_out <= {16'h0, keypad};
                kBicolor0Addr: data_out <= {30'h0, bicolor_led_0};
                kBicolor1Addr: data_out <= {30'h0, bicolor_led_1};
                kLEDAddr: data_out <= {16'h0, led};
                kNumAddr: data_out <= num;
                kTimerAddr: data_out <= timer;
            endcase
        end
    end

    // write
    always @(posedge clk) begin
        if (!rst) begin
            bicolor_led_0 <= 2'h0;
            bicolor_led_1 <= 2'h0;
            led <= 16'hffff;
            num <= 32'h0;
        end
        else if (write_flag) begin
            case (address)
                kBicolor0Addr: bicolor_led_0 <= data_in[1:0];
                kBicolor1Addr: bicolor_led_1 <= data_in[1:0];
                kLEDAddr: led <= data_in[15:0];
                kNumAddr: num <= data_in;
                default:;
            endcase
        end
    end

endmodule // GPIO
