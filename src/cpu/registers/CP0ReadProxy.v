`timescale 1ns / 1ps

`include "../define/bus.v"

module CP0ReadProxy(
    input [`CP0_ADDR_BUS] cp0_read_addr,
    // from coprocessor 0
    input [`DATA_BUS] cp0_read_data_in,
    // from MEM stage
    input mem_cp0_write_flag,
    input [`CP0_ADDR_BUS] mem_cp0_write_addr,
    input [`DATA_BUS] mem_cp0_data_in,
    // from WB stage
    input wb_cp0_write_flag,
    input [`CP0_ADDR_BUS] wb_cp0_write_addr,
    input [`DATA_BUS] wb_cp0_data_in,
    // coprocessor 0 register data output
    output reg[`DATA_BUS] cp0_read_data_out
);

    // generate output
    always @(*) begin
        if (mem_cp0_write_flag && mem_cp0_write_addr == cp0_read_addr) begin
            cp0_read_data_out <= mem_cp0_data_in;
        end
        else if (wb_cp0_write_flag && wb_cp0_write_addr == cp0_read_addr) begin
            cp0_read_data_out <= wb_cp0_data_in;
        end
        else begin
            cp0_read_data_out <= cp0_read_data_in;
        end
    end

endmodule // CP0ReadProxy
