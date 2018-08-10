`timescale 1ns / 1ps

module Top(
    input         clk,
    input         resetn,

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

    output [3:0]  debug_wb_pc,
    output [31:0] debug_wb_rf_wen,
    output [4:0]  debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

    wire[3:0]  awid_i;
    wire[31:0] awaddr_i;
    wire[3:0]  awlen_i;
    wire[2:0]  awsize_i;
    wire[1:0]  awburst_i;
    wire[31:0] wdata_i;
    wire[3:0]  wstrb_i;
    wire[3:0]  arid_i;
    wire[31:0] araddr_i;
    wire[3:0]  arlen_i;
    wire[2:0]  arsize_i;
    wire[1:0]  arburst_i;

    assign arlock = 0;
    assign arcache = 0;
    assign arprot = 0;
    assign awlock = 0;
    assign awcache = 0;
    assign awprot = 0;

    assign awid_i = 4'b1010;
    assign awlen_i = 4'b0000;
    assign awsize_i = 3'b010;
    assign awburst_i = 2'b00;

    assign arid_i = 4'b0101;
    // TODO: !
    assign araddr_i = ? /* MUX(rom_addr, ram_addr) */;
    assign arlen_i = 4'b0000;
    assign arsize_i = 3'b010;
    assign arburst_i = 2'b00;

    AXI_master axi_master(
        .clk(clk),
        .rst_n(resetn),

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

        .awid_i(awid_i),
        .awaddr_i(awaddr_i),
        .awlen_i(awlen_i),
        .awsize_i(awsize_i),
        .awburst_i(awburst_i),
        .wdata_i(wdata_i),
        .wstrb_i(wstrb_i),
        .arid_i(arid_i),
        .araddr_i(araddr_i),
        .arlen_i(arlen_i),
        .arsize_i(arsize_i),
        .arburst_i(arburst_i),
    );

    Uranus cpu(
        .clk(clk),
        .rst(resetn),

        .stall_all(rvalid),
        .interrupt(int[4:0]),

        .ram_en( ),                     // TODO: !
        .ram_write_en(wstrb_i),
        .ram_addr(awaddr_i),
        .ram_write_data(wdata_i),
        .ram_read_data( ),              // TODO: !

        .rom_en( ),                     // TODO: !
        // .rom_write_en( ),
        .rom_addr( ),                   // TODO: !
        // .rom_write_data( ),
        .rom_read_data( ),              // TODO: !

        .debug_pc_addr(debug_wb_pc),
        .debug_reg_write_en(debug_wb_rf_wen),
        .debug_reg_write_addr(debug_wb_rf_wnum),
        .debug_reg_write_data(debug_wb_rf_wdata)
    );

endmodule // Top
