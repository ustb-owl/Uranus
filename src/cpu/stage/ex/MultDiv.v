`timescale 1ns / 1ps

`include "../../define/bus.v"
`include "../../define/funct.v"

module MultDiv(
    input clk,
    input rst,
    input flush,
    input [`FUNCT_BUS] funct,
    input [`DATA_BUS] operand_1,
    input [`DATA_BUS] operand_2,
    output done,
    output reg[`DOUBLE_DATA_BUS] result
);

    parameter kDivCycle = 32, kMultCycle = 1;

    reg[kDivCycle - 1:0] cycle_counter;
    reg[`DOUBLE_DATA_BUS] mult_result;

    wire signed_flag, mult_neg_flag;
    wire[`DATA_BUS] op_1, op_2;

    assign done = cycle_counter[0];
    assign signed_flag = funct == `FUNCT_MULT || funct == `FUNCT_DIV;
    assign mult_neg_flag = signed_flag && (operand_1[31] ^ operand_2[31]);
    assign op_1 = (signed_flag && operand_1[31]) ? -operand_1 : operand_1;
    assign op_2 = (signed_flag && operand_2[31]) ? -operand_2 : operand_2;

    always @(posedge clk) begin
        mult_result <= op_1 * op_2;
    end

    always @(*) begin
        case (funct)
            `FUNCT_MULT, `FUNCT_MULTU: begin
                result <= mult_neg_flag ? -mult_result : mult_result;
            end
            // `FUNCT_DIV, `FUNCT_DIVU: result <= 
            default: result <= 0;
        endcase
    end

    always @(posedge clk) begin
        if (!rst || flush) begin
            cycle_counter <= 0;
        end
        else if (cycle_counter) begin
            cycle_counter <= cycle_counter >> 1;
        end
        else begin
            case (funct)
                `FUNCT_MULT, `FUNCT_MULTU: begin
                    cycle_counter <= 1'b1 << (kMultCycle - 1);
                end
                `FUNCT_DIV, `FUNCT_DIVU: begin
                    cycle_counter <= 1'b1 << (kDivCycle - 1);
                end
                default: begin
                    cycle_counter <= 0;
                end
            endcase
        end
    end

endmodule // MultDiv
