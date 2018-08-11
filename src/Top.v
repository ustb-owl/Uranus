`timescale 1ns / 1ps

module Top(
    input         aclk,
    input         aresetn,

    input  [5:0]  int,

    output [3:0]  arid,
    output [31:0] araddr,
    output [3:0]  arlen,
    output [2:0]  arsize,
    output [1:0]  arburst,
    output [1:0]  arlock,
    output [3:0]  arcache,
    output [2:0]  arprot,
    output        arvalid,
    input         arready,

    input  [3:0]  rid,
    input  [31:0] rdata,
    input  [1:0]  rresp,
    input         rlast,
    input         rvalid,
    output        rready,

    output [3:0]  awid,
    output [31:0] awaddr,
    output [3:0]  awlen,
    output [2:0]  awsize,
    output [1:0]  awburst,
    output [1:0]  awlock,
    output [3:0]  awcache,
    output [2:0]  awprot,
    output        awvalid,
    input         awready,

    output [3:0]  wid,
    output [31:0] wdata,
    output [3:0]  wstrb,
    output        wlast,
    output        wvalid,
    input         wready,

    input  [3:0]  bid,
    input  [1:0]  bresp,
    input         bvalid,
    output        bready,

    output [31:0]  debug_wb_pc,
    output [3:0] debug_wb_rf_wen,
    output [4:0]  debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

    wire       ram_en_conn;
    wire[3:0]  ram_write_en_conn;
    wire[31:0] ram_write_data_conn;
    wire[31:0] ram_addr_conn;
    wire       rom_en_conn;
    wire[3:0]  rom_write_en_conn;
    wire[31:0] rom_write_data_conn;
    wire[31:0] rom_addr_conn;

    wire[3:0]  awid_conn;
    wire[31:0] awaddr_conn;
    wire[3:0]  awlen_conn;
    wire[2:0]  awsize_conn;
    wire[1:0]  awburst_conn;
    wire[31:0] wdata_conn;
    wire[3:0]  wstrb_conn;
    wire[3:0]  arid_conn;
    wire[31:0] araddr_conn;
    wire[3:0]  arlen_conn;
    wire[2:0]  arsize_conn;
    wire[1:0]  arburst_conn;

    assign arlock = 0;
    assign arcache = 0;
    assign arprot = 0;
    assign awlock = 0;
    assign awcache = 0;
    assign awprot = 0;

    AXI_master axi_master(
        .clk(aclk),
        .rst_n(aresetn),

        .AWID(awid),
        .AWADDR(awaddr),
        .AWLEN(awlen),
        .AWSIZE(awsize),
        .AWBURST(awburst),
        .AWVALID(awvalid),
        .AWREADY(awready),

        .WID(wid),
        .WDATA(wdata),
        .WSTRB(wstrb),
        .WLAST(wlast),
        .WVALID(wvalid),
        .WREADY(wready),

        .BID(bid),
        .BRESP(bresp),
        .BVALID(bvalid),
        .BREADY(bready),

        .ARID(arid),
        .ARADDR(araddr),
        .ARLEN(arlen),
        .ARSIZE(arsize),
        .ARBURST(arburst),
        .ARVALID(arvalid),
        .ARREADY(arready),

        .RID(rid),
        .RDATA(rdata),
        .RRESP(rresp),
        .RLAST(rlast),
        .RVALID(rvalid),
        .RREADY(rready),

        .awid_i(awid_conn),
        .awaddr_i(awaddr_conn),
        .awlen_i(awlen_conn),
        .awsize_i(awsize_conn),
        .awburst_i(awburst_conn),
        .wdata_i(wdata_conn),
        .wstrb_i(wstrb_conn),
        .arid_i(arid_conn),
        .araddr_i(araddr_conn),
        .arlen_i(arlen_conn),
        .arsize_i(arsize_conn),
        .arburst_i(arburst_conn)
    );

    arbiter arbiter_0(
        .ram_en(ram_en_conn),
        .ram_write_en(ram_write_en_conn),
        .ram_write_data(ram_write_data_conn),
        .ram_addr(ram_addr_conn),

        .rom_en(rom_en_conn),
        .rom_write_en(rom_write_en_conn),
        .rom_write_data(rom_write_data_conn),
        .rom_addr(rom_addr_conn),

        .awid_o(awid_conn),
        .awaddr_o(awaddr_conn),
        .awlen_o(awlen_conn),
        .awsize_o(awsize_conn),
        .awburst_o(awburst_conn),
        .wdata_o(wdata_conn),
        .wstrb_o(wstrb_conn),
        .arid_o(arid_conn),
        .araddr_o(araddr_conn),
        .arlen_o(arlen_conn),
        .arsize_o(arsize_conn),
        .arburst_o(arburst_conn)
    );

    Uranus cpu(
        .clk(aclk),
        .rst(aresetn),

        .stall_all(~rvalid),
        .interrupt(int[4:0]),

        .ram_en(ram_en_conn),
        .ram_write_en(ram_write_en_conn),
        .ram_addr(ram_addr_conn),
        .ram_write_data(ram_write_data_conn),
        .ram_read_data(rdata),

        .rom_en(rom_en_conn),
        .rom_write_en(rom_write_en_conn),
        .rom_addr(rom_addr_conn),
        .rom_write_data(rom_write_data_conn),
        .rom_read_data(rdata),

        .debug_pc_addr(debug_wb_pc),
        .debug_reg_write_en(debug_wb_rf_wen),
        .debug_reg_write_addr(debug_wb_rf_wnum),
        .debug_reg_write_data(debug_wb_rf_wdata)
    );

endmodule // Top
