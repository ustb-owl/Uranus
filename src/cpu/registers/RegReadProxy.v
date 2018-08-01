`timescale 1ns / 1ps

`include "../define/bus.v"

module RegReadProxy(
    // input from ID stage
    input read_en_1,
    input read_en_2,
    input [`REG_ADDR_BUS] read_addr_1,
    input [`REG_ADDR_BUS] read_addr_2,
    // data from regfile
    input [`DATA_BUS] data_1_from_reg,
    input [`DATA_BUS] data_2_from_reg,
    // data from EX stage
    input reg_write_en_from_ex,
    input [`REG_ADDR_BUS] reg_write_addr_from_ex,
    input [`DATA_BUS] data_from_ex,
    // data from MEM stage
    input reg_write_en_from_mem,
    input [`REG_ADDR_BUS] reg_write_addr_from_mem,
    input [`DATA_BUS] data_from_mem,
    // reg data output
    output reg[`DATA_BUS] read_data_1,
    output reg[`DATA_BUS] read_data_2
);

    // generate output read_data_1
    always @(*) begin
        if (read_en_1) begin
            if (reg_write_en_from_ex
                    && read_addr_1 == reg_write_addr_from_ex) begin
                read_data_1 <= data_from_ex;
            end
            else if (reg_write_en_from_mem
                    && read_addr_1 == reg_write_addr_from_mem) begin
                read_data_1 <= data_from_mem;
            end
            else begin
                read_data_1 <= data_1_from_reg;
            end
        end
        else begin
            read_data_1 <= 0;
        end
    end

    // generate output read_data_2
    always @(*) begin
        if (read_en_2) begin
            if (reg_write_en_from_ex
                    && read_addr_2 == reg_write_addr_from_ex) begin
                read_data_2 <= data_from_ex;
            end
            else if (reg_write_en_from_mem
                    && read_addr_2 == reg_write_addr_from_mem) begin
                read_data_2 <= data_from_mem;
            end
            else begin
                read_data_2 <= data_2_from_reg;
            end
        end
        else begin
            read_data_2 <= 0;
        end
    end

endmodule // RegReadProxy
