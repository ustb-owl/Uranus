`timescale 1ns / 1ps

`include "../../define/bus.v"
`include "../../define/segpos.v"
`include "../../define/opcode.v"
`include "../../define/regimm.v"
`include "../../define/funct.v"

module ID(
    input rst,
    // from IF stage (PC)
    input [`ADDR_BUS] addr,
    input [`INST_BUS] inst,
    // from/to regfile
    input [`DATA_BUS] reg_data_1,
    input [`DATA_BUS] reg_data_2,
    output reg reg_read_en_1,
    output reg reg_read_en_2,
    output reg[`REG_ADDR_BUS] reg_addr_1,
    output reg[`REG_ADDR_BUS] reg_addr_2,
    // to EX stage
    output reg[`FUNCT_BUS] funct,
    output [`SHAMT_BUS] shamt,
    output reg[`DATA_BUS] operand_1,
    output reg[`DATA_BUS] operand_2,
    // to WB stage (write back to regfile)
    output reg write_reg_en,
    output reg[`REG_ADDR_BUS] write_reg_addr
);

    // extract information from instruction
    wire[`INST_OP_BUS] inst_op = inst[`SEG_OPCODE];
    wire[`REG_ADDR_BUS] inst_rs = inst[`SEG_RS];
    wire[`REG_ADDR_BUS] inst_rt = inst[`SEG_RT];
    wire[`REG_ADDR_BUS] inst_rd = inst[`SEG_RD];
    wire[`SHAMT_BUS] inst_shamt = inst[`SEG_SHAMT];
    wire[`FUNCT_BUS] inst_funct = inst[`SEG_FUNCT];

    assign shamt = inst_shamt;

    // extract immediate from instruction
    wire[`HALF_DATA_BUS] inst_imm = inst[`SEG_IMM];
    wire[`DATA_BUS] zero_extended_imm = {16'b0, inst_imm};
    wire[`DATA_BUS] zero_extended_imm_hi = {inst_imm, 16'b0};
    wire[`DATA_BUS] sign_extended_imm = {{16{inst_imm[15]}}, inst_imm};

    // generate read address of registers
    always @(*) begin
        if (!rst) begin
            reg_read_en_1 <= 0;
            reg_read_en_2 <= 0;
            reg_addr_1 <= 0;
            reg_addr_2 <= 0;
        end
        else begin
            case (inst_op)
                `OP_ORI: begin
                    reg_read_en_1 <= 1;
                    reg_read_en_2 <= 0;
                    reg_addr_1 <= inst_rs;
                    reg_addr_2 <= 0;
                end
                `OP_SPECIAL: begin
                    reg_read_en_1 <= 1;
                    reg_read_en_2 <= 1;
                    reg_addr_1 <= inst_rs;
                    reg_addr_2 <= inst_rt;
                end
                default: begin
                    reg_read_en_1 <= 0;
                    reg_read_en_2 <= 0;
                    reg_addr_1 <= 0;
                    reg_addr_2 <= 0;
                end
            endcase
        end
    end

    // generate funct signal
    always @(*) begin
        case (inst_op)
            `OP_SPECIAL: begin
                funct <= inst_funct;
            end
            `OP_ORI: begin
                funct <= `FUNCT_OR;
            end
            default: begin
                funct <= `FUNCT_NOP;
            end
        endcase
    end

    // generate operand_1
    always @(*) begin
        if (!rst) begin
            operand_1 <= 0;
        end
        else begin
            case (inst_op)
                `OP_ORI: begin
                    operand_1 <= reg_data_1;
                end
                `OP_SPECIAL: begin
                    operand_1 <= reg_data_1;
                end
                default: begin
                    operand_1 <= 0;
                end
            endcase
        end
    end

    // generate operand_2
    always @(*) begin
        if (!rst) begin
            operand_2 <= 0;
        end
        else begin
            case (inst_op)
                `OP_ORI: begin
                    operand_2 <= zero_extended_imm;
                end
                `OP_SPECIAL: begin
                    operand_2 <= reg_data_2;
                end
                default: begin
                    operand_2 <= 0;
                end
            endcase
        end
    end

    // generate write address of registers
    always @(*) begin
        if (!rst) begin
            write_reg_en <= 0;
            write_reg_addr <= 0;
        end
        else begin
            case (inst_op)
                `OP_ORI: begin
                    write_reg_en <= 1;
                    write_reg_addr <= inst_rt;
                end
                `OP_SPECIAL: begin
                    write_reg_en <= 1;
                    write_reg_addr <= inst_rd;
                end
                default: begin
                    write_reg_en <= 0;
                    write_reg_addr <= 0;
                end
            endcase
        end
    end

endmodule // ID
