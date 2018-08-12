module Arbiter(
    input clk,
    input rst,
    // handshake signals from AXI bus
    input [31:0] rdata,
    input rlast,
    input rvalid,
    input wlast,
    input wready,
    // RAM ports
    input ram_en,
    input [3:0] ram_write_en,
    input [31:0] ram_write_data,
    input [31:0] ram_addr,
    // ROM ports
    input rom_en,
    input [3:0] rom_write_en,
    input [31:0] rom_write_data,
    input [31:0] rom_addr,
    // output of AXI & CPU signals
    output wready_out,
    output stall_all,
    // output of RAM & ROM data
    output [31:0] ram_read_data,
    output [31:0] rom_read_data,
    // output of AXI control signals
    output [3:0] awid_o,
    output [31:0] awaddr_o,
    output [3:0] awlen_o,
    output [2:0] awsize_o,
    output [1:0] awburst_o,
    output [31:0] wdata_o,
    output [3:0] wstrb_o,
    output [3:0] arid_o,
    output [31:0] araddr_o,
    output [3:0] arlen_o,
    output [2:0] arsize_o,
    output [1:0] arburst_o,
    // burst cache IO
    input [31:0] cache_data,
    output [9:0] cache_addr
);

    parameter kBurstCacheSize = 16;

    wire ram_write_flag = ram_en && ram_write_en;
    wire ram_read_flag = ram_en && !ram_write_en;

    assign awid_o = 4'b0000;
    assign awaddr_o = ram_write_flag ? ram_addr : 32'h0;
    assign awlen_o = 4'b0000;
    assign awsize_o = 3'b010;
    assign awburst_o = 2'b00;

    assign wdata_o = ram_write_flag ? ram_write_data : 32'h0;
    assign wstrb_o = ram_en ? ram_write_en : 4'b0000;

    assign arid_o = 4'b0000;
    assign araddr_o = ram_read_flag ? ram_addr : rom_addr;
    assign arlen_o = ram_read_flag ? 4'b0000 : 4'b1111;
    assign arsize_o = 3'b010;
    assign arburst_o = 2'b00;

    assign ram_read_data = ram_read_flag ? rdata : 0;
    assign rom_read_data = !ram_read_flag && rom_en ? rdata : 0;

    reg data_valid;
    reg rom_data_valid, ram_data_read_valid, ram_data_write_valid;
    reg[31:0] rom_burst_start_addr;

    always @(*) begin
        if (!rst) begin
            data_valid <= 0;
        end
        else if (ram_read_flag) begin
            data_valid <= ram_data_read_valid;
        end
        else if (ram_write_flag) begin
            data_valid <= ram_data_write_valid;
        end
        else begin
            data_valid <= rom_data_valid;
        end
    end

    // generate ROM data (read)
    always @(posedge clk) begin
        if (!rst) begin
            rom_data_valid <= 0;
        end
        else begin
            //
        end
    end

    // generate RAM data (read)
    always @(posedge clk) begin
        if (!rst) begin
            ram_data_read_valid <= 0;
        end
        else begin
            //
        end
    end

    // generate RAM data (write)
    always @(posedge clk) begin
        if (!rst) begin
            ram_data_write_valid <= 0;
        end
        else begin
            //
        end
    end

    assign stall_all = ~data_valid;

endmodule
