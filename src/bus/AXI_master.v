module AXI_master
#(
    parameter   DOWN_ADDR = 12'h000,
    parameter   UP_ADDR   = 12'hfff
)
(   
    //GLOBAL SIGNALS (2)
    input           clk,
    input           rst_n,

    //WRITE ADDRESS CHANNEL SIGNALS (7)
    output  reg [3:0]   AWID,
    output  reg [31:0]  AWADDR,
    output  reg [3:0]   AWLEN,
    output  reg [2:0]   AWSIZE,
    output  reg [1:0]   AWBURST,
//  output  reg [1:0]   AWLOCK,
//  output  reg [3:0]   AWCACHE,
//  output  reg [2:0]   AWPROT,
    output  reg         AWVALID,
    input               AWREADY,
    
    //WRITE DATA CHANNEL SIGNALS (6)
    output  reg [3:0]   WID,
    output  reg [31:0]  WDATA,
    output  reg [3:0]   WSTRB,
    output  reg         WLAST,
    output  reg         WVALID,
    input               WREADY, 
    
    //WRITE RESPONSE CHANNEL SIGNALS (4)
    input   [3:0]       BID,
    input   [1:0]       BRESP,
    input               BVALID,
    output  reg         BREADY,

    //READ ADDRESS CHANNEL SIGNALS (7)
    output  reg [3:0]   ARID,
    output  reg [31:0]  ARADDR,
    output  reg [3:0]   ARLEN,
    output  reg [2:0]   ARSIZE,
    output  reg [1:0]   ARBURST,
//  output  reg [1:0]   ARLOCK,
//  output  reg [3:0]   ARCACHE,
//  output  reg [2:0]   ARPORT,
    output  reg         ARVALID,
    input               ARREADY,  

    //READ DATA CHANNEL SIGNALS (6)
    input       [3:0]   RID,
    input       [31:0]  RDATA,
    input       [1:0]   RRESP,
    input               RLAST,
    input               RVALID,
    output  reg         RREADY,

    //USER'S INPUTS SIGNALS (12)
    //Sending inputs to master which will be transfered through AXI protocol.
    input   [3:0]   awid_i,
    input   [31:0]  awaddr_i,
    input   [3:0]   awlen_i,
    input   [2:0]   awsize_i,
    input   [1:0]   awburst_i,

    input   [31:0]  wdata_i,
    input   [3:0]   wstrb_i,

    input   [3:0]   arid_i,
    input   [31:0]  araddr_i,
    input   [3:0]   arlen_i,
    input   [2:0]   arsize_i,
    input   [1:0]   arburst_i
);

    //Bursts must not cross 4KB boundaries to prevent them from crossing boundaries 
    //between slaves and to limit the size of the address incrementer required within slaves.

    //creating the master's local ram of 4096 Bytes(4 KB).
    reg         [7:0]  master_mem   [4095:0];

    //VARIABLES FOR WRITE ADDRESS CHANNEL MASTER
    parameter   [1:0]   AW_IDLE_M  = 2'b00;
    parameter   [1:0]   AW_START_M = 2'b01;
    parameter   [1:0]   AW_WAIT_M  = 2'b10;
    parameter   [1:0]   AW_VALID_M = 2'b11;

    reg         [1:0]   AWState_M;
    reg         [1:0]   AWNext_State_M;

    //VARIABLES FOR WRITE DATA CHANNEL MASTER
    reg         [3:0]   count;
    reg         [3:0]   count_next;

    parameter   [2:0]   W_INIT_M = 3'b000;
    parameter   [2:0]   W_TRANSFER_M = 3'b001;
    parameter   [2:0]   W_READY_M = 3'b010;
    parameter   [2:0]   W_VALID_M = 3'b011;
    parameter   [2:0]   W_ERROR_M = 3'b100;

    reg         [2:0]   WState_M;
    reg         [2:0]   WNext_State_M;

    //VARIABLES FOR WRITE RESPONSE CHANNEL MASTER
    parameter   [1:0]   B_IDLE_M  = 2'b00;
    parameter   [1:0]   B_START_M = 2'b01;
    parameter   [1:0]   B_READY_M = 2'b10;

    reg         [1:0]   BState_M;
    reg         [1:0]   BNext_State_M;

    //VARIABLES FOR READ ADDRESS CHANNEL MASTER
    parameter   [2:0]   AR_IDLE_M  = 3'b000;
    parameter   [2:0]   AR_START_M = 3'b001;
    parameter   [2:0]   AR_WAIT_M  = 3'b010;
    parameter   [2:0]   AR_VALID_M = 3'b011;
    parameter   [2:0]   AR_EXTRA_M = 3'b100;

    reg         [2:0]   ARState_M;
    reg         [2:0]   ARNext_State_M;

    //VARIABLES FOR READ DATA CHANNEL MASTER
    reg         [31:0]  address_slave;
    reg         [31:0]  address_slave_reg;
    reg         [31:0]  address_slave_temp;
    reg         [31:0]  ARADDR_reg;

    parameter   [1:0]   R_CLEAR_M = 2'b00;
    parameter   [1:0]   R_START_M = 2'b01;
    parameter   [1:0]   R_READ_M  = 2'b10;
    parameter   [1:0]   R_VALID_M = 2'b11;

    reg         [1:0]   RState_M;
    reg         [1:0]   RNext_State_M;

    integer             wrap_boundary;
    integer             first_time;
    integer             first_time_next;

    //FSM FOR WRITE ADDRESS CHANNEL MASTER
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            AWState_M <= AW_IDLE_M;
        end
        else    begin
            AWState_M <= AWNext_State_M;
        end
    end

    always @ (*)    begin
        case(AWState_M)
            AW_IDLE_M:  begin
                AWID    = 0;
                AWADDR  = 0;
                AWLEN   = 0;
                AWSIZE  = 0;
                AWBURST = 0;
                AWVALID = 0;
                AWNext_State_M = AW_START_M;
            end

            AW_START_M: begin
                if(awaddr_i >= 32'h0)  begin
                    AWID    = awid_i;
                    AWADDR  = awaddr_i;
                    AWLEN   = awlen_i;
                    AWSIZE  = awsize_i;
                    AWBURST = awburst_i;
                    AWVALID = 1'b1;
                    AWNext_State_M = AW_WAIT_M;
                end
                else    begin
                    AWNext_State_M = AW_IDLE_M;
                end
            end

            AW_WAIT_M:  begin
                if(AWREADY == 1'b1) begin
                    AWNext_State_M = AW_VALID_M;
                end
                else    begin
                    AWNext_State_M = AW_WAIT_M;
                end
            end

            AW_VALID_M: begin
                AWVALID = 1'b0;
                if(BREADY == 1'b1)  begin
                    AWNext_State_M = AW_IDLE_M;
                end
                else    begin
                    AWNext_State_M = AW_VALID_M;
                end
            end
        
        endcase
    end

    //FSM FOR WRITE DATA CHANNEL MASTER
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            WState_M <= W_INIT_M;
            count <= 4'b0;
        end
        else    begin
            WState_M <= WNext_State_M;
            count <= count_next;
        end
    end

    always @ (*)    begin
        case(WState_M)
            W_INIT_M:   begin
                WID    = 0;
                WDATA  = 0;
                WSTRB  = 0;
                WLAST  = 0;
                WVALID = 0;
                count_next = 0;

                if(AWREADY == 1)    begin
                    WNext_State_M = W_TRANSFER_M;
                end
                else    begin
                    WNext_State_M = W_INIT_M;
                end
            end

            W_TRANSFER_M:   begin
                if(awaddr_i[11:0] >= DOWN_ADDR && awaddr_i[11:0] <= UP_ADDR && awsize_i <= 3'b010) begin
                    WID    = AWID;
                    WVALID = 1;
                    WSTRB  = wstrb_i;
                    WDATA  = wdata_i;
                    count_next    = count + 4'b1;
                    WNext_State_M = W_READY_M;
                end
                else    begin
                    count_next    = count + 4'b1;
                    WNext_State_M = W_ERROR_M;
                end
            end

            W_READY_M:  begin
                if(WREADY == 1'b1)  begin
                    if(count_next == (awlen_i + 1))   begin
                        WLAST = 1'b1;
                    end
                    else    begin
                        WLAST = 1'b0;
                    end

                    WNext_State_M = W_VALID_M;
                end
                else    begin
                    WNext_State_M = W_READY_M;
                end
            end

            W_VALID_M:  begin
                WVALID = 0;

                if(count_next == (awlen_i + 1))   begin
                    WNext_State_M = W_INIT_M;
                    WLAST = 0;
                end
                else    begin
                    WNext_State_M = W_TRANSFER_M;
                end
            end

            W_ERROR_M:  begin
                if(count_next == (awlen_i + 1))   begin
                    WLAST = 1'b1;
                    WNext_State_M = W_VALID_M;
                end
                else    begin
                    WLAST = 1'b0;
                    WNext_State_M = W_TRANSFER_M;
                end
            end
        endcase
    end

    //FSM FOR WRITE RESPONSE CHANNEL MASTER
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            BState_M <= B_IDLE_M;
        end
        else    begin
            BState_M <= BNext_State_M;
        end
    end

    always @ (*)    begin
        case(BState_M)
            B_IDLE_M:   begin
                BREADY = 0;
                BNext_State_M = B_START_M;
            end

            B_START_M:  begin
                if(BVALID == 1'b1)  begin
                    BNext_State_M = B_READY_M;
                end
            end

            B_READY_M:  begin
                BREADY = 1'b1;
                BNext_State_M = B_IDLE_M;
            end
        endcase
    end

    //FSM FOR READ ADDRESS CHANNEL MASTER
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            ARState_M <= AR_IDLE_M;
        end
        else    begin
            ARState_M <= ARNext_State_M;
        end
    end

    always @ (*)    begin
        case(ARState_M)
            AR_IDLE_M:  begin
                ARID    = 0;
                ARADDR  = 0;
                ARLEN   = 0;
                ARSIZE  = 0;
                ARBURST = 0;
                ARVALID = 0;
                ARNext_State_M = AR_START_M;
            end

            AR_START_M: begin
                if(araddr_i >= 32'h0)  begin
                    ARID    = arid_i;
                    ARADDR  = araddr_i;
                    ARLEN   = arlen_i;
                    ARSIZE  = arsize_i;
                    ARBURST = arburst_i;
                    ARVALID = 1'b1;
                    ARNext_State_M = AR_WAIT_M;
                end
                else    begin
                    ARNext_State_M = AR_IDLE_M;
                end
            end

            AR_WAIT_M:  begin
                if(ARREADY == 1'b1) begin
                    ARNext_State_M = AR_VALID_M;
                end
                else    begin
                    ARNext_State_M = AR_WAIT_M;
                end
            end

            AR_VALID_M: begin
                ARVALID = 1'b0;
                if(RLAST == 1'b1)   begin
                    ARNext_State_M = AR_EXTRA_M;
                end
                else    begin
                    ARNext_State_M = AR_VALID_M;
                end
            end

            AR_EXTRA_M: begin
                ARNext_State_M = AR_IDLE_M;
            end

        endcase;
    end

    //FSM FOR READ DATA CHANNEL MASTER
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)  begin
            RState_M   <= R_CLEAR_M;
        end
        else    begin
            RState_M   <= RNext_State_M;
            first_time <= first_time_next;
        end
    end

    always @ (*)    begin
        if(ARREADY == 1'b1) begin
            ARADDR_reg = araddr_i;
        end

        case(RState_M)
            R_CLEAR_M:  begin
                RNext_State_M     = R_START_M;
                RREADY            = 0;
                first_time_next   = 0;
                address_slave     = 0;
                address_slave_reg = 0;
            end

            R_START_M:  begin
                if(RVALID == 1'b1)  begin
                    RNext_State_M = R_READ_M;
                    address_slave = address_slave_reg;
                end
                else    begin
                    RNext_State_M = R_START_M;
                end
            end

            R_READ_M:   begin
                RNext_State_M = R_VALID_M;
                RREADY = 1;

                case(arburst_i)
                    2'b00:  begin
                        address_slave = ARADDR_reg;

                        case(arsize_i)
                            3'b000: begin
                                master_mem[address_slave[11:0]]     = RDATA[7:0];
                            end

                            3'b001: begin
                                master_mem[address_slave[11:0]]     = RDATA[7:0];
                                master_mem[address_slave[11:0] + 1] = RDATA[15:8];
                            end

                            3'b010: begin
                                master_mem[address_slave[11:0]]     = RDATA[7:0];
                                master_mem[address_slave[11:0] + 1] = RDATA[15:8];
                                master_mem[address_slave[11:0] + 2] = RDATA[23:16];
                                master_mem[address_slave[11:0] + 3] = RDATA[31:24];
                            end
                        endcase
                    end

                    2'b01:  begin
                        if(first_time == 1'b0) begin
                            address_slave = ARADDR_reg;
                            first_time_next = 1'b1;
                        end
                        else    begin
                            first_time_next = first_time;
                        end

                        if(RLAST == 1'b1)   begin
                            first_time_next = 1'b0;
                        end
                        else    begin
                            first_time_next = first_time;
                        end

                        case(arsize_i)
                            3'b000: begin
                                master_mem[address_slave[11:0]]     = RDATA[7:0];
                            end

                            3'b001: begin
                                master_mem[address_slave[11:0]]     = RDATA[7:0];
                                master_mem[address_slave[11:0] + 1] = RDATA[15:8];
                                address_slave_reg = address_slave + 2;
                            end

                            3'b010: begin
                                master_mem[address_slave[11:0]]     = RDATA[7:0];
                                master_mem[address_slave[11:0] + 1] = RDATA[15:8];
                                master_mem[address_slave[11:0] + 2] = RDATA[23:16];
                                master_mem[address_slave[11:0] + 3] = RDATA[31:24];
                                address_slave_reg = address_slave + 4;
                            end
                        endcase
                    end

                    2'b10:  begin
                        if(first_time == 1'b0)  begin
                            address_slave   = ARADDR_reg;
                            first_time_next = 1'b1;
                        end
                        else    begin
                            first_time_next = first_time;
                        end

                        if(RLAST == 1'b1)   begin
                            first_time_next = 1'b0;
                        end
                        else    begin
                            first_time_next = first_time;
                        end

                        case(arlen_i)
                            4'b0001:    begin
                                case(arsize_i)
                                    3'b000: begin
                                        wrap_boundary = 2 * 1;
                                    end
                                    3'b001: begin
                                        wrap_boundary = 2 * 2;
                                    end
                                    3'b010: begin
                                        wrap_boundary = 2 * 4;
                                    end
                                endcase
                            end

                            4'b0011:    begin
                                case(arsize_i)
                                    3'b000: begin
                                        wrap_boundary = 4 * 1;
                                    end
                                    3'b001: begin
                                        wrap_boundary = 4 * 2;
                                    end
                                    3'b010: begin
                                        wrap_boundary = 4 * 4;
                                    end
                                endcase
                            end

                            4'b0111:    begin
                                case(arsize_i)
                                    3'b000: begin
                                        wrap_boundary = 8 * 1;
                                    end
                                    3'b001: begin
                                        wrap_boundary = 8 * 2;
                                    end
                                    3'b010: begin
                                        wrap_boundary = 8 * 4;
                                    end
                                endcase
                            end

                            4'b1111:    begin
                                case(arsize_i)
                                    3'b000: begin
                                        wrap_boundary = 16 * 1;
                                    end
                                    3'b001: begin
                                        wrap_boundary = 16 * 2;
                                    end
                                    3'b010: begin
                                        wrap_boundary = 16 * 4;
                                    end
                                endcase
                            end
                        endcase

                        case(arsize_i)
                            3'b000: begin
                                master_mem[address_slave[11:0]] = RDATA[7:0];
                                address_slave_temp = address_slave + 1;

                                if(address_slave_temp % wrap_boundary == 0) begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end
                                else    begin
                                    address_slave_reg = address_slave_temp;
                                end
                            end

                            3'b001: begin
                                master_mem[address_slave[11:0]] = RDATA[7:0];
                                address_slave_temp = address_slave + 1;

                                if(address_slave_temp % wrap_boundary == 0) begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end
                                else    begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end

                                master_mem[address_slave[11:0]] = RDATA[15:8];
                                address_slave_temp = address_slave_reg + 1;

                                if(address_slave_temp % wrap_boundary == 0) begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end
                                else begin
                                    address_slave_reg = address_slave_temp;
                                end
                            end

                            3'b010: begin
                                master_mem[address_slave[11:0]] = RDATA[7:0];
                                address_slave_temp = address_slave + 1;

                                if(address_slave_temp % wrap_boundary == 0) begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end
                                else    begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end

                                master_mem[address_slave[11:0]] = RDATA[15:8];
                                address_slave_temp = address_slave_reg + 1;

                                if(address_slave_temp % wrap_boundary == 0) begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end
                                else begin
                                    address_slave_reg = address_slave_temp;
                                end

                                master_mem[address_slave[11:0]] = RDATA[23:16];
                                address_slave_temp = address_slave + 1;

                                if(address_slave_temp % wrap_boundary == 0) begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end
                                else    begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end

                                master_mem[address_slave[11:0]] = RDATA[31:24];
                                address_slave_temp = address_slave_reg + 1;

                                if(address_slave_temp % wrap_boundary == 0) begin
                                    address_slave_reg = address_slave_temp - wrap_boundary;
                                end
                                else begin
                                    address_slave_reg = address_slave_temp;
                                end
                            end
                        endcase
                    end
                endcase
            end

            R_VALID_M:  begin
                RREADY = 1'b0;

                if(RLAST == 1'b1)   begin
                    RNext_State_M = R_CLEAR_M;
                end
                else    begin
                    RNext_State_M = R_START_M;
                end
            end
        endcase
    end

endmodule