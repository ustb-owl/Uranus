`timescale 1ns / 1ps

module SegDisplay(
    input clk,
    input rst,
    input [31:0] buffer,
    output reg[7:0] seg_sel,
    output reg[7:0] seg_bit
);

    reg[15:0] counter;
    reg[3:0] cur_num;

    always @(posedge clk) begin
        if (!rst) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end

    always @(posedge clk) begin
        if (!rst) begin
            seg_sel <= 8'hf;
        end
        else begin
            case (counter[15:13])
                3'd0: seg_sel <= 8'b01111111;
                3'd1: seg_sel <= 8'b10111111;
                3'd2: seg_sel <= 8'b11011111;
                3'd3: seg_sel <= 8'b11101111;
                3'd4: seg_sel <= 8'b11110111;
                3'd5: seg_sel <= 8'b11111011;
                3'd6: seg_sel <= 8'b11111101;
                3'd7: seg_sel <= 8'b11111110;
                default:;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rst) begin
            cur_num <= 0;
        end
        else begin
            case (counter[15:13])
                3'd0: cur_num <= buffer[31:28];
                3'd1: cur_num <= buffer[27:24];
                3'd2: cur_num <= buffer[23:20];
                3'd3: cur_num <= buffer[19:16];
                3'd4: cur_num <= buffer[15:12];
                3'd5: cur_num <= buffer[11:8];
                3'd6: cur_num <= buffer[7:4];
                3'd7: cur_num <= buffer[3:0];
                default:;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rst) begin
            seg_bit <= 0;
        end
        else begin
            case (cur_num)
                4'h0: seg_bit <= 7'b1111110;
                4'h1: seg_bit <= 7'b0110000;
                4'h2: seg_bit <= 7'b1101101;
                4'h3: seg_bit <= 7'b1111001;
                4'h4: seg_bit <= 7'b0110011;
                4'h5: seg_bit <= 7'b1011011;
                4'h6: seg_bit <= 7'b1011111;
                4'h7: seg_bit <= 7'b1110000;
                4'h8: seg_bit <= 7'b1111111;
                4'h9: seg_bit <= 7'b1111011;
                4'ha: seg_bit <= 7'b1110111;
                4'hb: seg_bit <= 7'b0011111;
                4'hc: seg_bit <= 7'b1001110;
                4'hd: seg_bit <= 7'b0111101;
                4'he: seg_bit <= 7'b1001111;
                4'hf: seg_bit <= 7'b1000111;
            endcase
        end
    end

endmodule // SegDisplay
