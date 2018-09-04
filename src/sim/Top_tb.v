`timescale 1ns / 1ps

module Top_tb();

    reg clk, rst;

    wire  [3 :0] axi_arid;
    wire  [31:0] axi_araddr;
    wire  [7 :0] axi_arlen;
    wire  [2 :0] axi_arsize;
    wire  [1 :0] axi_arburst;
    wire  [1 :0] axi_arlock;
    wire  [3 :0] axi_arcache;
    wire  [2 :0] axi_arprot;
    wire         axi_arvalid;
    wire         axi_arready;
    wire  [3 :0] axi_rid;
    wire  [31:0] axi_rdata;
    wire  [1 :0] axi_rresp;
    wire         axi_rlast;
    wire         axi_rvalid;
    wire         axi_rready;
    wire  [3 :0] axi_awid;
    wire  [31:0] axi_awaddr;
    wire  [7 :0] axi_awlen;
    wire  [2 :0] axi_awsize;
    wire  [1 :0] axi_awburst;
    wire  [1 :0] axi_awlock;
    wire  [3 :0] axi_awcache;
    wire  [2 :0] axi_awprot;
    wire         axi_awvalid;
    wire         axi_awready;
    wire  [3 :0] axi_wid;
    wire  [31:0] axi_wdata;
    wire  [3 :0] axi_wstrb;
    wire         axi_wlast;
    wire         axi_wvalid;
    wire         axi_wready;
    wire  [3 :0] axi_bid;
    wire  [1 :0] axi_bresp;
    wire         axi_bvalid;
    wire         axi_bready;

    wire[7:0] switch;
    wire[15:0] keypad;
    wire[1:0] bicolor_led_0;
    wire[1:0] bicolor_led_1;
    wire[15:0] led;
    wire[31:0] num;

    wire[31:0] debug_pc_addr;
    wire[3:0] debug_reg_write_en;
    wire[4:0] debug_reg_write_addr;
    wire[31:0] debug_reg_write_data;

    assign switch = 0;
    assign keypad = 0;

    SoC_tb soc(
        .clk(clk),
        .rst(rst),

        .m0_axi_arid(axi_arid),
        .m0_axi_araddr(axi_araddr),
        .m0_axi_arlen(axi_arlen),
        .m0_axi_arsize(axi_arsize),
        .m0_axi_arburst(axi_arburst),
        .m0_axi_arlock(axi_arlock),
        .m0_axi_arcache(axi_arcache),
        .m0_axi_arprot(axi_arprot),
        .m0_axi_arvalid(axi_arvalid),
        .m0_axi_arready(axi_arready),
        .m0_axi_rid(axi_rid),
        .m0_axi_rdata(axi_rdata),
        .m0_axi_rresp(axi_rresp),
        .m0_axi_rlast(axi_rlast),
        .m0_axi_rvalid(axi_rvalid),
        .m0_axi_rready(axi_rready),
        .m0_axi_awid(axi_awid),
        .m0_axi_awaddr(axi_awaddr),
        .m0_axi_awlen(axi_awlen),
        .m0_axi_awsize(axi_awsize),
        .m0_axi_awburst(axi_awburst),
        .m0_axi_awlock(axi_awlock),
        .m0_axi_awcache(axi_awcache),
        .m0_axi_awprot(axi_awprot),
        .m0_axi_awvalid(axi_awvalid),
        .m0_axi_awready(axi_awready),
        .m0_axi_wid(axi_wid),
        .m0_axi_wdata(axi_wdata),
        .m0_axi_wstrb(axi_wstrb),
        .m0_axi_wlast(axi_wlast),
        .m0_axi_wvalid(axi_wvalid),
        .m0_axi_wready(axi_wready),
        .m0_axi_bid(axi_bid),
        .m0_axi_bresp(axi_bresp),
        .m0_axi_bvalid(axi_bvalid),
        .m0_axi_bready(axi_bready),

        .switch(switch),
        .keypad(keypad),
        .bicolor_led_0(bicolor_led_0),
        .bicolor_led_1(bicolor_led_1),
        .led(led),
        .num(num),

        .debug_pc_addr(debug_pc_addr),
        .debug_reg_write_en(debug_reg_write_en),
        .debug_reg_write_addr(debug_reg_write_addr),
        .debug_reg_write_data(debug_reg_write_data)
    );

    SimMem mem(
        .s_aclk(clk),
        .s_aresetn(rst),
        .s_axi_arid(axi_arid),
        .s_axi_araddr(axi_araddr),
        .s_axi_arlen(axi_arlen),
        .s_axi_arsize(axi_arsize),
        .s_axi_arburst(axi_arburst),
        .s_axi_arlock(axi_arlock),
        .s_axi_arcache(axi_arcache),
        .s_axi_arprot(axi_arprot),
        .s_axi_arvalid(axi_arvalid),
        .s_axi_arready(axi_arready),
        .s_axi_rid(axi_rid),
        .s_axi_rdata(axi_rdata),
        .s_axi_rresp(axi_rresp),
        .s_axi_rlast(axi_rlast),
        .s_axi_rvalid(axi_rvalid),
        .s_axi_rready(axi_rready),
        .s_axi_awid(axi_awid),
        .s_axi_awaddr(axi_awaddr),
        .s_axi_awlen(axi_awlen),
        .s_axi_awsize(axi_awsize),
        .s_axi_awburst(axi_awburst),
        .s_axi_awlock(axi_awlock),
        .s_axi_awcache(axi_awcache),
        .s_axi_awprot(axi_awprot),
        .s_axi_awvalid(axi_awvalid),
        .s_axi_awready(axi_awready),
        .s_axi_wid(axi_wid),
        .s_axi_wdata(axi_wdata),
        .s_axi_wstrb(axi_wstrb),
        .s_axi_wlast(axi_wlast),
        .s_axi_wvalid(axi_wvalid),
        .s_axi_wready(axi_wready),
        .s_axi_bid(axi_bid),
        .s_axi_bresp(axi_bresp),
        .s_axi_bvalid(axi_bvalid),
        .s_axi_bready(axi_bready)
    );

    initial begin
        clk = 0;
        rst = 0;
        #7 rst = 1;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule // Top_tb
