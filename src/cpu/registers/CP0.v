`timescale 1ns / 1ps

`include "../define/bus.v"
`include "../define/cp0.v"

module CP0(
    input clk,
    input rst,
    input [`CP0_ADDR_BUS] read_addr,
    // 6 external interrupt inputs
    input [5:0] interrupt,
    input write_en,
    input [`CP0_ADDR_BUS] write_addr,
    input [`DATA_BUS] write_data,
    // data output
    output reg[`DATA_BUS] data_out
);

    // Coprocessor 0 registers
    reg[`DATA_BUS] reg_count;
    reg[`DATA_BUS] reg_compare;
    reg[`DATA_BUS] reg_status;
    reg[`DATA_BUS] reg_cause;
    reg[`DATA_BUS] reg_epc;
    reg[`DATA_BUS] reg_config;
    reg[`DATA_BUS] reg_prid;
    reg reg_timer_int;

    // write data into registers
    always @(posedge clk) begin
        if (!rst) begin
            reg_count <= 0;
            reg_compare <= 0;
            reg_status <= 0;
            reg_cause <= 0;
            reg_epc <= 0;
            reg_config <= 0;
            reg_prid <= 0;
            reg_timer_int <= 0;
        end
        else begin
            reg_count <= reg_count + 1;
            reg_cause[15:10] <= interrupt;
            if (reg_compare && reg_count == reg_compare) begin
                reg_timer_int <= 1;
            end
            if (write_en) begin
                case (write_addr)
                    `CP0_REG_COUNT: begin
                        reg_count <= write_data;
                    end
                    `CP0_REG_COMPARE: begin
                        reg_compare <= write_data;
                        reg_timer_int <= 0;
                    end
                    `CP0_REG_STATUS: begin
                        reg_status <= write_data;
                    end
                    `CP0_REG_EPC: begin
                        reg_epc <= write_data;
                    end
                    `CP0_REG_CAUSE: begin
                        reg_cause[9:8] <= write_data[9:8];
                        reg_cause[23] <= write_data[23];
                        reg_cause[22] <= write_data[22];
                    end
                endcase
            end
        end
    end

    // generate data output
    always@(*) begin
        if (!rst) begin
            data_out <= 0;
        end
        else begin
            case (read_addr)
                `CP0_REG_COUNT: data_out <= reg_count;
                `CP0_REG_COMPARE: data_out <= reg_compare;
                `CP0_REG_STATUS: data_out <= reg_status;
                `CP0_REG_CAUSE: data_out <= reg_cause;
                `CP0_REG_EPC: data_out <= reg_epc;
                `CP0_REG_PRID: data_out <= reg_prid;
                `CP0_REG_CONFIG: data_out <= reg_config;
                default: data_out <= 0;
            endcase
        end
    end

endmodule // CP0
