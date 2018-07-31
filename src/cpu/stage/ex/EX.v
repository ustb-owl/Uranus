`timescale 1ns / 1ps

`include "../../define/bus.v"
`include "../../define/funct.v"

module EX(
    input rst,
    // from ID stage
    input [`FUNCT_BUS] funct,
    input [`SHAMT_BUS] shamt,
    input [`DATA_BUS] operand_1,
    input [`DATA_BUS] operand_2,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    // to WB stage
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out
);

    reg[`DATA_BUS] result;

    assign result_out = rst ? result : 0;
    assign write_reg_en_out = rst ? write_reg_en_in : 0;
    assign write_reg_addr_out = rst ? write_reg_addr_in : 0;

    // calculate result
    always @(*) begin
        case (funct)
            `FUNCT_OR: begin
                result <= (operand_1 | operand_2);
            end
            default: begin
                result <= 0;
            end
        endcase
    end

endmodule // EX
