`timescale 1ns / 1ps

`include "bus.v"
`include "segpos.v"
`include "opcode.v"
`include "regimm.v"
`include "funct.v"

// NOTE: just a preliminary version
module ID(
    input rst,
    input [`ADDR_BUS] addr,
    input [`INST_BUS] inst,
    input [`DATA_BUS] reg_data_1,
    input [`DATA_BUS] reg_data_2,
    output reg reg_read_en_1,
    output reg reg_read_en_2,
    output reg[`REG_ADDR_BUS] reg_addr_1,
    output reg[`REG_ADDR_BUS] reg_addr_2,
    output reg write_reg_en,
    output reg[`REG_ADDR_BUS] write_reg_addr,
    output [`FUNCT_BUS] funct,
    output [`SHAMT_BUS] shamt,
    output reg[`DATA_BUS] operand_1,
    output reg[`DATA_BUS] operand_2
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

    // generate address of registers to be read
    always @(*) begin
        if (!rst) begin
            reg_read_en_1 <= 0;
            reg_read_en_2 <= 0;
            reg_addr_1 <= 0;
            reg_addr_2 <= 0;
        end
        else begin
            case (inst_op)
                // arithmetic & logic (immediate)
                `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
                `OP_ANDI, `OP_ORI, `OP_XORI,
                // memory accessing
                `OP_LB, `OP_LH, `OP_LW, `OP_LBU, `OP_LHU: begin
                    reg_read_en_1 <= 1;
                    reg_read_en_2 <= 0;
                    reg_addr_1 <= inst_rs;
                    reg_addr_2 <= 0;
                end
                // branch
                `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ,
                // memory accessing
                `OP_SB, `OP_SH, `OP_SW,
                // r-type
                `OP_SPECIAL: begin
                    reg_read_en_1 <= 1;
                    reg_read_en_2 <= 1;
                    reg_addr_1 <= inst_rs;
                    reg_addr_2 <= inst_rt;
                end
                // reg-imm
                `OP_REGIMM: begin
                    case (inst_rt)
                        `REGIMM_BLTZ, `REGIMM_BLTZAL,
                        `REGIMM_BGEZ, `REGIMM_BGEZAL: begin
                            reg_read_en_1 <= 1;
                            reg_read_en_2 <= 0;
                            reg_addr_1 <= inst_rs;
                            reg_addr_2 <= 0;
                        end
                        default: begin
                            reg_read_en_1 <= 0;
                            reg_read_en_2 <= 0;
                            reg_addr_1 <= 0;
                            reg_addr_2 <= 0;
                        end
                    endcase
                end
                // coprocessor
                `OP_CP0: begin
                    reg_read_en_1 <= 1;
                    reg_read_en_2 <= 1;
                    reg_addr_1 <= inst_rt;
                    reg_addr_2 <= 0;
                end
                default: begin   // OP_J, OP_JAL, OP_LUI
                    reg_read_en_1 <= 0;
                    reg_read_en_2 <= 0;
                    reg_addr_1 <= 0;
                    reg_addr_2 <= 0;
                end
            endcase
        end
    end

    // generate FUNCT signal
    FunctGen funct_gen(inst_op, inst_funct, inst_rt, funct);

    // calculate link address
    wire[`ADDR_BUS] link_addr = addr + 8;

    // generate operand_1
    always @(*) begin
        if (!rst) begin
            operand_1 <= 0;
        end
        else begin
            case (inst_op)
                // immediate
                `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
                `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI,
                // memory accessing
                `OP_LB, `OP_LH, `OP_LW, `OP_LBU,
                `OP_LHU, `OP_SB, `OP_SH, `OP_SW: begin
                    operand_1 <= reg_data_1;
                end
                `OP_SPECIAL: begin
                    operand_1 <= funct == `FUNCT_JALR ? link_addr : reg_data_1;
                end
                `OP_REGIMM: begin
                    operand_1 <= inst_rt == `REGIMM_BLTZAL
                        || inst_rt == `REGIMM_BGEZAL ? link_addr : 0;
                end
                `OP_JAL: begin
                    operand_1 <= link_addr;
                end
                `OP_LB, `OP_LH, `OP_LW, `OP_LBU,
                `OP_LHU, `OP_SB, `OP_SH, `OP_SW: begin
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
                `OP_ORI, `OP_ANDI, `OP_XORI: begin
                    operand_2 <= zero_extended_imm;
                end 
                `OP_LUI: begin
                    operand_2 <= zero_extended_imm_hi;
                end
                // arithmetic & logic (immediate)
                `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
                `OP_LB, `OP_LH, `OP_LW, `OP_LBU,
                // memory accessing
                `OP_LHU, `OP_SB, `OP_SH, `OP_SW: begin
                    operand_2 <= sign_extended_imm;
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

endmodule // ID
