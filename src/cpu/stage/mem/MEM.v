`timescale 1ns / 1ps

`include "../../define/bus.v"

module MEM(
    input rst,
    // memory accessing signals
    input mem_read_flag_in,
    input mem_write_flag_in,
    input mem_sign_ext_flag_in,
    input [3:0] mem_sel_in,
    input [`DATA_BUS] mem_write_data,
    // from EX stage
    input [`DATA_BUS] result_in,
    input  write_reg_en_in,
    input [`REG_ADDR_BUS] write_reg_addr_in,
    input hilo_write_en_in,
    input [`DATA_BUS] hi_in,
    input [`DATA_BUS] lo_in,
    input [`ADDR_BUS] debug_pc_addr_in,
    // RAM control signals
    output reg ram_en,
    output reg[3:0] ram_write_en,
    output reg[`ADDR_BUS] ram_addr,
    output reg[`DATA_BUS] ram_write_data,
    // to ID stage
    output mem_load_flag,
    // to WB stage
    output mem_read_flag_out,
    output mem_write_flag_out,
    output mem_sign_ext_flag_out,
    output [3:0] mem_sel_out,
    output [`DATA_BUS] result_out,
    output write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    output hilo_write_en_out,
    output [`DATA_BUS] hi_out,
    output [`DATA_BUS] lo_out,
    output [`ADDR_BUS] debug_pc_addr_out
);

    // internal ram_write_sel control signal
    reg[3:0] ram_write_sel;

    // to ID stage
    assign mem_load_flag = rst ? mem_read_flag_in : 0;
    // to WB stage
    assign mem_read_flag_out = rst ? mem_read_flag_in : 0;
    assign mem_write_flag_out = rst ? mem_write_flag_in : 0;
    assign mem_sign_ext_flag_out = rst ? mem_sign_ext_flag_in : 0;
    assign mem_sel_out = rst ? mem_sel_in : 0;
    assign result_out = rst ? result_in : 0;
    assign write_reg_en_out = rst ? write_reg_en_in : 0;
    assign write_reg_addr_out = rst ? write_reg_addr_in : 0;
    assign hilo_write_en_out = rst ? hilo_write_en_in : 0;
    assign hi_out = rst ? hi_in : 0;
    assign lo_out = rst ? lo_in : 0;
    // debug signal
    assign debug_pc_addr_out = debug_pc_addr_in;

    wire[`ADDR_BUS] address = result_in;

    // generate ram_en signal
    always @(*) begin
        if (!rst) begin
            ram_en <= 0;
        end
        else if (mem_write_flag_in || mem_read_flag_in) begin
            ram_en <= 1;
        end
        else begin
            ram_en <= 0;
        end
    end
    
    // generate ram_write_en signal
    always @(*) begin
        if (!rst) begin
            ram_write_en <= 4'b0000;
        end
        else if (mem_write_flag_in) begin
            ram_write_en <= ram_write_sel;
        end
        else begin
            ram_write_en <= 4'b0000;
        end
    end

    // generate ram_write_addr signal
    always @(*) begin
        if (!rst) begin
            ram_addr <= 0;
        end
        else if (mem_write_flag_in || mem_read_flag_in) begin
            ram_addr <= {address[31:2], 2'b00};
        end
        else begin
            ram_addr <= 0;
        end
    end

    // generate ram_write_sel signal
    always @(*) begin
        if (!rst) begin
            ram_write_sel <= 4'b0000;
        end
        else if (mem_write_flag_in) begin
            if (mem_sel_in == 4'b0001) begin   // byte
                case (address[1:0])
                    2'b00: ram_write_sel <= 4'b0001;
                    2'b01: ram_write_sel <= 4'b0010;
                    2'b10: ram_write_sel <= 4'b0100;
                    2'b11: ram_write_sel <= 4'b1000;
                    default: ram_write_sel <= 4'b0000;
                endcase
            end
            else if (mem_sel_in == 4'b0011) begin   // half word
                case (address[1:0])
                    2'b00: ram_write_sel <= 4'b0011;
                    2'b10: ram_write_sel <= 4'b1100;
                    default: ram_write_sel <= 4'b0000;
                endcase
            end
            else if (mem_sel_in == 4'b1111) begin   // word
                case (address[1:0])
                    2'b00: ram_write_sel <= 4'b1111;
                    default: ram_write_sel <= 4'b0000;
                endcase
            end
            else begin
                ram_write_sel <= 4'b0000;
            end
        end
        else begin
            ram_write_sel <= 4'b0000;
        end
    end

    // generate ram_write_data signal
    always @(*) begin
        if (!rst) begin
            ram_write_data <= 0;
        end
        else if (mem_write_flag_in) begin
            if (mem_sel_in == 4'b0001) begin
                case (address[1:0])
                    2'b00: ram_write_data <= mem_write_data;
                    2'b01: ram_write_data <= mem_write_data << 8;
                    2'b10: ram_write_data <= mem_write_data << 16;
                    2'b11: ram_write_data <= mem_write_data << 24;
                endcase
            end
            else if (mem_sel_in == 4'b0011) begin
                case (address[1:0])
                    2'b00: ram_write_data <= mem_write_data;
                    2'b10: ram_write_data <= mem_write_data << 16;
                    default: ram_write_data <= 0;
                endcase
            end
            else if (mem_sel_in == 4'b1111) begin
                case (address[1:0])
                    2'b00: ram_write_data <= mem_write_data;
                    default: ram_write_data <= 0;
                endcase
            end
            else begin
                ram_write_data <= 0;
            end
        end
        else begin
            ram_write_data <= 0;
        end
    end

endmodule // MEM
