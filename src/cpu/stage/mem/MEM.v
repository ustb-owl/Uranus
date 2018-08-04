`timescale 1ns / 1ps

`include "../../define/bus.v"

module MEM(
    input rst,
    // memory accessing signals
    input mem_read_flag,
    input mem_write_flag,
    input mem_sign_ext_flag,
    input [3:0] mem_sel,
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
    input [`DATA_BUS] ram_read_data,
    output reg ram_en,
    output reg[3:0] ram_write_en,
    output reg[`ADDR_BUS] ram_addr,
    output reg[`DATA_BUS] ram_write_data,
    // to WB stage
    output reg[`DATA_BUS] result_out,
    output  write_reg_en_out,
    output [`REG_ADDR_BUS] write_reg_addr_out,
    output hilo_write_en_out,
    output [`DATA_BUS] hi_out,
    output [`DATA_BUS] lo_out,
    output [`ADDR_BUS] debug_pc_addr_out
);

    // internal ram_write_sel control signal
    reg[3:0] ram_write_sel;

    assign write_reg_en_out = rst ? write_reg_en_in : 0;
    assign write_reg_addr_out = rst ? write_reg_addr_in : 0;
    assign hilo_write_en_out = rst ? hilo_write_en_in : 0;
    assign hi_out = rst ? hi_in : 0;
    assign lo_out = rst ? lo_in : 0;
    assign debug_pc_addr_out = debug_pc_addr_out;

    wire[`ADDR_BUS] address = result_in;

    // generate result_out signal
    // because load instructions will use this signal
    always @(*) begin
        if (!rst) begin
            result_out <= 0;
        end
        else begin
            if (mem_read_flag) begin
                if (mem_sel == 4'b0001) begin
                    case(address[1:0])
                        2'b00: result_out <= mem_sign_ext_flag ? {{24{ram_read_data[7]}}, ram_read_data[7:0]} : {24'b0, ram_read_data[7:0]};
                        2'b01: result_out <= mem_sign_ext_flag ? {{24{ram_read_data[15]}}, ram_read_data[15:8]} : {24'b0, ram_read_data[15:8]};
                        2'b10: result_out <= mem_sign_ext_flag ? {{24{ram_read_data[23]}}, ram_read_data[23:16]} : {24'b0, ram_read_data[23:16]};
                        2'b11: result_out <= mem_sign_ext_flag ? {{24{ram_read_data[31]}}, ram_read_data[31:24]} : {24'b0, ram_read_data[31:24]};
                    endcase
                end
                else if (mem_sel == 4'b0011) begin
                    case (address[1:0])
                        2'b00: result_out <= mem_sign_ext_flag ? {{16{ram_read_data[15]}}, ram_read_data[15:0]} : {16'b0, ram_read_data[15:0]};
                        2'b10: result_out <= mem_sign_ext_flag ? {{16{ram_read_data[31]}}, ram_read_data[31:16]} : {16'b0, ram_read_data[31:16]};
                        default: result_out <= 0;
                    endcase
                end
                else if (mem_sel == 4'b1111) begin
                    case (address[1:0])
                        2'b00: result_out <= ram_read_data;
                        default: result_out <= 0;
                    endcase
                end
                else begin
                    result_out <= 0;
                end
            end
            else if (mem_write_flag) begin
                result_out <= 0;
            end
            else begin
                result_out <= result_in;
            end
        end
    end

    // generate ram_en signal
    always @(*) begin
        if (!rst) begin
            ram_en <= 0;
        end
        else if (mem_write_flag || mem_read_flag) begin
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
        else if (mem_write_flag) begin
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
        else if (mem_write_flag || mem_read_flag) begin
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
        else if (mem_write_flag) begin
            if (mem_sel == 4'b0001) begin   // byte
                case (address[1:0])
                    2'b00: ram_write_sel <= 4'b0001;
                    2'b01: ram_write_sel <= 4'b0010;
                    2'b10: ram_write_sel <= 4'b0100;
                    2'b11: ram_write_sel <= 4'b1000;
                    default: ram_write_sel <= 4'b0000;
                endcase
            end
            else if (mem_sel == 4'b0011) begin   // half word
                case (address[1:0])
                    2'b00: ram_write_sel <= 4'b0011;
                    2'b10: ram_write_sel <= 4'b1100;
                    default: ram_write_sel <= 4'b0000;
                endcase
            end
            else if (mem_sel == 4'b1111) begin   // word
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
        else if (mem_write_flag) begin
            if (mem_sel == 4'b0001) begin
                case (address[1:0])
                    2'b00: ram_write_data <= mem_write_data;
                    2'b01: ram_write_data <= mem_write_data << 8;
                    2'b10: ram_write_data <= mem_write_data << 16;
                    2'b11: ram_write_data <= mem_write_data << 24;
                endcase
            end
            else if (mem_sel == 4'b0011) begin
                case (address[1:0])
                    2'b00: ram_write_data <= mem_write_data;
                    2'b10: ram_write_data <= mem_write_data << 16;
                    default: ram_write_data <= 0;
                endcase
            end
            else if (mem_sel == 4'b1111) begin
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
