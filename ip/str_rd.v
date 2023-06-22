`timescale 1 ns / 1 ps

module str_rd #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 8,
    parameter integer N_PKT = 3
)
(    
    // AXIS data, synchronous to axi clk
    input wire [32*N_PKT-1:0] s_axis_tdata,
    output wire               s_axis_tready,
    input wire                s_axis_tvalid,

    // FIFO info
    input wire [31:0] write_data_count,
    input wire [31:0] read_data_count,


    // Ports of Axi Slave Bus Interface S_AXI
    input wire                                s_axi_aclk,
    input wire                                s_axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]     s_axi_awaddr,
    input wire [2 : 0]                        s_axi_awprot,
    input wire                                s_axi_awvalid,
    output wire                               s_axi_awready,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0]     s_axi_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
    input wire                                s_axi_wvalid,
    output wire                               s_axi_wready,
    output wire [1 : 0]                       s_axi_bresp,
    output wire                               s_axi_bvalid,
    input wire                                s_axi_bready,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]     s_axi_araddr,
    input wire [2 : 0]                        s_axi_arprot,
    input wire                                s_axi_arvalid,
    output wire                               s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]    s_axi_rdata,
    output wire [1 : 0]                       s_axi_rresp,
    output wire                               s_axi_rvalid,
    input wire                                s_axi_rready
);

    wire [N_PKT*32-1:0] tdata;
    wire                tvalid;

    // AXI core part
    str_rd_core # ( 
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) str_rd_core_inst (
        .S_AXI_ACLK(s_axi_aclk),
        .S_AXI_ARESETN(s_axi_aresetn),
        .S_AXI_AWADDR(s_axi_awaddr),
        .S_AXI_AWPROT(s_axi_awprot),
        .S_AXI_AWVALID(s_axi_awvalid),
        .S_AXI_AWREADY(s_axi_awready),
        .S_AXI_WDATA(s_axi_wdata),
        .S_AXI_WSTRB(s_axi_wstrb),
        .S_AXI_WVALID(s_axi_wvalid),
        .S_AXI_WREADY(s_axi_wready),
        .S_AXI_BRESP(s_axi_bresp),
        .S_AXI_BVALID(s_axi_bvalid),
        .S_AXI_BREADY(s_axi_bready),
        .S_AXI_ARADDR(s_axi_araddr),
        .S_AXI_ARPROT(s_axi_arprot),
        .S_AXI_ARVALID(s_axi_arvalid),
        .S_AXI_ARREADY(s_axi_arready),
        .S_AXI_RDATA(s_axi_rdata),
        .S_AXI_RRESP(s_axi_rresp),
        .S_AXI_RVALID(s_axi_rvalid),
        .S_AXI_RREADY(s_axi_rready),

        .tdata(tdata),
        .tvalid(tvalid),
        .busy(busy),

        .write_data_count(write_data_count),
        .read_data_count(read_data_count)
    );
 

    reg [32*N_PKT-1:0] tdata_buf;
    reg                tvalid_buf;
    reg                tready_mask;

    // tdata latching
    always @(posedge s_axi_aclk) begin
        if (~s_axi_aresetn)
            tdata_buf <= {(32*N_PKT){1'b0}};
        else if (trans) begin
            tdata_buf <= s_axis_tdata;
        end
    end

    // tvalid buffering
    always @(posedge s_axi_aclk) begin
        tvalid_buf <= s_axis_tvalid;
    end

    assign tdata = tdata_buf;
    assign tvalid = tvalid_buf;

    // tready masking
    // Mask 1 clock after the transaction happens.
    wire trans = s_axis_tvalid & s_axis_tready;
    reg trans_buf;

    always @(posedge s_axi_aclk) begin
        trans_buf <= trans;
    end

    assign s_axis_tready = ~busy & ~trans_buf;

endmodule
