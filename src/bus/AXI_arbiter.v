module arbiter(
    input           clk,
    input           rst,

    input   [31:0]  rdata,
    input           rvalid,

    input           ram_en,
    input   [3:0]   ram_write_en,
    input   [31:0]  ram_write_data,
    input   [31:0]  ram_addr,

    input           rom_en,
    input   [3:0]   rom_write_en,
    input   [31:0]  rom_write_data,
    input   [31:0]  rom_addr,

    output          stall_all,

    output  [31:0]  ram_read_data,
    output  [31:0]  rom_read_data,

    output  [3:0]   awid_o,
    output  [31:0]  awaddr_o,
    output  [3:0]   awlen_o,
    output  [2:0]   awsize_o,
    output  [1:0]   awburst_o,
    output  [31:0]  wdata_o,
    output  [3:0]   wstrb_o,
    output  [3:0]   arid_o,
    output  [31:0]  araddr_o,
    output  [3:0]   arlen_o,
    output  [2:0]   arsize_o,
    output  [1:0]   arburst_o
);

    wire ram_write_flag = ram_en && ram_write_en;
    wire ram_read_flag = ram_en && !ram_write_en;

    assign  ram_read_data = ram_read_flag ? rdata : 0;
    assign  rom_read_data = !ram_read_flag && rom_en ? rdata : 0;

    assign  awid_o = 4'b000;
    assign  awaddr_o = ram_write_flag ? ram_addr : 32'h0;
    assign  awlen_o = 4'b0000;
    assign  awsize_o = 3'b010;
    assign  awburst_o = 2'b00;

    assign  wdata_o = ram_write_flag ? ram_write_data : 32'h0;
    assign  wstrb_o = ram_en ? ram_write_en : 4'b0000;

    assign  arid_o = 4'b0000;
    assign  araddr_o = ram_read_flag ? ram_addr : rom_en ? rom_addr : 32'h0;
    assign  arlen_o = 4'b0000;
    assign  arsize_o = 3'b010;
    assign  arburst_o = 2'b00;

    // TODO: replace these MAGIC codes
    reg rvalid_delay;
    reg[13:0] delay_cycle;
    wire stall_signal = ~(rvalid & rvalid_delay);

    always @(posedge clk) begin
        if (!rst) begin
            rvalid_delay <= 0;
            // delay_cycle <= 0;
        end
        else begin
            rvalid_delay <= rvalid;
            // if (!stall_signal && ram_read_flag) begin
            //     delay_cycle <= 1 << 13;
            // end
            // if (delay_cycle) begin
            //     delay_cycle <= delay_cycle >> 1;
            // end
        end
    end

    // assign stall_all = (delay_cycle ? ~delay_cycle[0] : 1'b0) | stall_signal;
    assign stall_all = stall_signal;

endmodule
