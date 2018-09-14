`timescale 1ns / 1ps

`include "../../define/bus.v"
`include "../../define/funct.v"

module  Multiplier(
    input   wire                    rst,

    // from ID stage
    input   wire[`FUNCT_BUS]        funct,
    input   wire[`DATA_BUS]         operand_1,
    input   wire[`DATA_BUS]         operand_2,

    // from HILOReadProxy
    input   wire[`DATA_BUS]         hi,
    input   wire[`DATA_BUS]         lo,

    // data output
    output  reg [`DOUBLE_DATA_BUS]  result_mult
);

    wire[`DATA_BUS] multiplicand    = (((funct == `FUNCT2_MUL)  ||
                                        (funct == `FUNCT2_MADD) || (funct == `FUNCT2_MSUB)) && operand_1[31]) ? (~operand_1 + 1) : operand_1;
    wire[`DATA_BUS] multiplicator   = (((funct == `FUNCT2_MUL)  ||
                                        (funct == `FUNCT2_MADD) || (funct == `FUNCT2_MSUB)) && operand_2[31]) ? (~operand_2 + 1) : operand_2;

    wire[`DOUBLE_DATA_BUS]  result_mult_temp = multiplicand * multiplicator;

    always @ (*)    begin
        if (!rst) begin
            result_mult         <= 64'h0;
        end else    begin
            case (funct)

                `FUNCT2_MUL:    begin
                    if (operand_1[31] ^ operand_2[31])
                            result_mult <= ~result_mult_temp + 1;
                    else    result_mult <= result_mult_temp;
                end

                `FUNCT2_MADD: begin
                    if (operand_1[31] ^ operand_2[31])
                            result_mult <= ~result_mult_temp + 1 + {hi, lo};
                    else    result_mult <= result_mult_temp + {hi, lo};
                end

                `FUNCT2_MADDU:  begin
                    result_mult         <= result_mult_temp + {hi, lo};
                end

                `FUNCT2_MSUB:    begin
                    if (operand_1[31] ^ operand_2[31])
                            result_mult <= result_mult_temp + {hi, lo};
                    else    result_mult <= ~result_mult_temp + 1 + {hi, lo};
                end

                `FUNCT2_MSUBU:  begin
                    result_mult         <= ~result_mult_temp + 1 + {hi, lo};
                end

                default:    begin   // `FUNCT_MULTU
                    result_mult         <= result_mult_temp;
                end
            
            endcase
        end
    end

endmodule