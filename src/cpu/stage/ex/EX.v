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
    input mem_read_flag_in,
    input mem_write_flag_in,
    input mem_sign_ext_flag_in,
    input [3:0] mem_sel_in,
    input [`DATA_BUS] mem_write_data_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    input [`ADDR_BUS] debug_pc_addr_in,
    // HI & LO data
    input [`DATA_BUS] hi_in,
    input [`DATA_BUS] lo_in,
    // to MEM stage
    output mem_read_flag_out,
    output mem_write_flag_out,
    output mem_sign_ext_flag_out,
    output [3:0] mem_sel_out,
    output [`DATA_BUS] mem_write_data_out,
    // to WB stage
    output [`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    // HI & LO control
    output reg hilo_write_en,
    output reg[`DATA_BUS] hi_out,
    output reg[`DATA_BUS] lo_out,
    // debug signal
    output [`ADDR_BUS] debug_pc_addr_out
);

    // store the result of ALU
    reg[`DATA_BUS] result;

    assign result_out = rst ? result : 0;
    assign write_reg_addr_out = rst ? write_reg_addr_in : 0;
    assign mem_read_flag_out = rst ? mem_read_flag_in : 0;
    assign mem_write_flag_out = rst ? mem_write_flag_in : 0;
    assign mem_sign_ext_flag_out = rst ? mem_sign_ext_flag_in : 0;
    assign mem_sel_out = rst ? mem_sel_in : 0;
    assign mem_write_data_out = rst ? mem_write_data_in : 0;
    assign debug_pc_addr_out = debug_pc_addr_in;

    // store HI & LO
    wire[`DATA_BUS] hi = hi_in;
    wire[`DATA_BUS] lo = lo_in;

    // calculate the complement of operand_2
    wire[`DATA_BUS] operand_2_mux = (funct == `FUNCT_SUB ||
            funct == `FUNCT_SUBU || funct == `FUNCT_SLT) ?
            (~operand_2) + 1 : operand_2;

    // sum of operand_1 & operand_2
    wire[`DATA_BUS] result_sum = operand_1 + operand_2_mux;

    // overflow flag
    wire overflow_sum = ((!operand_1[31] && !operand_2_mux[31]) && result_sum[31])
            || ((operand_1[31] && operand_2_mux[31]) && (!result_sum[31]));

    // flag of operand_1 < operand_2    
    wire operand_1_lt_operand_2 = funct == `FUNCT_SLT ?
            // op1 is negative & op2 is positive
            ((operand_1[31] && !operand_2[31]) ||
                // op1 & op2 is positive, op1 - op2 is negative
                (!operand_1[31] && !operand_2[31] && result_sum[31]) ||
                // op1 & op2 is negative, op1 - op2 is negative
                (operand_1[31] && operand_2[31] && result_sum[31]))
            : (operand_1 < operand_2);

    // calculate result
    always @(*) begin
        case (funct)
            // jump with link & logic
            `FUNCT_JALR, `FUNCT_OR: result <= operand_1 | operand_2;
            `FUNCT_AND: result <= operand_1 & operand_2;
            `FUNCT_XOR: result <= operand_1 ^ operand_2;
            `FUNCT_NOR: result <=  ~(operand_1 | operand_2);
            // comparison
            `FUNCT_SLT, `FUNCT_SLTU: result <= operand_1_lt_operand_2;
            // arithmetic
            `FUNCT_ADD, `FUNCT_ADDU,
            `FUNCT_SUB, `FUNCT_SUBU: result <= result_sum;
            // HI & LO
            `FUNCT_MFHI: result <= hi;
            `FUNCT_MFLO: result <= lo;
            // shift
            `FUNCT_SLL: result <= operand_2 << shamt;
            `FUNCT_SRL: result <= operand_2 >> shamt;
            `FUNCT_SRA: result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, shamt})) | operand_2 >> shamt;
            `FUNCT_SLLV: result <= operand_2 << operand_1[4:0];
            `FUNCT_SRLV: result <= operand_2 >> operand_1[4:0];
            `FUNCT_SRAV: result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, operand_1[4:0]})) | operand_2 >> operand_1[4:0];
            // MULT, MULTU, DIV, DIVU
            default: result <= 0;
        endcase
    end

    reg write_reg_en;
    assign write_reg_en_out = rst ? write_reg_en && !mem_write_flag_in : 0;

    // control register write
    always @(*) begin
        case (funct)
            // TODO: raise exception when overflow
            `FUNCT_ADD, `FUNCT_SUB: write_reg_en <= !overflow_sum;
            // instructions that not to write register
            `FUNCT_MULT, `FUNCT_MULTU, `FUNCT_DIV,
            `FUNCT_DIVU, `FUNCT_JR: write_reg_en <= 0;
            default: write_reg_en <= write_reg_en_in;
        endcase
    end

    // write HI & LO 
    always @(*) begin
        case (funct)
            // HILO move instructions
            `FUNCT_MTHI: begin
                hilo_write_en <= 1;
                hi_out <= operand_1;
                lo_out <= lo;
            end
            `FUNCT_MTLO: begin
                hilo_write_en <= 1;
                hi_out <= hi;
                lo_out <= operand_1;
            end
            // multiplication & division
            // `FUNCT_MULT, `FUNCT_MULTU: begin
            //     hilo_write_en <= 1;
            //     hi_out <= mul_result_final[63:32];
            //     lo_out <= mul_result_final[31:0];
            // end
            // `FUNCT_DIV, `FUNCT_DIVU: begin
            //     hilo_write_en <= 1;
            //     hi_out <= div_result[63:32];
            //     lo_out <= div_result[31:0];
            // end
            default: begin
                hilo_write_en <= 0;
                hi_out <= hi;
                lo_out <= lo;
            end
        endcase
    end

endmodule // EX
