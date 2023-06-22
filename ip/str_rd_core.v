
`timescale 1 ns / 1 ps

module str_rd_core #
(
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    parameter integer C_S_AXI_ADDR_WIDTH	= 8,
    parameter integer N_PKT = 3
)
(
    input wire                              S_AXI_ACLK,
    input wire                              S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   S_AXI_AWADDR,
    input wire [2 : 0]                      S_AXI_AWPROT,
    input wire                              S_AXI_AWVALID,
    output wire                             S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0]   S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input wire                              S_AXI_WVALID,
    output wire                             S_AXI_WREADY,

    output wire [1 : 0]                     S_AXI_BRESP,
    output wire                             S_AXI_BVALID,
    input wire                              S_AXI_BREADY,
    
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   S_AXI_ARADDR,
    input wire [2 : 0]                      S_AXI_ARPROT,
    input wire                              S_AXI_ARVALID,
    output wire                             S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]  S_AXI_RDATA,
    output wire [1 : 0]                     S_AXI_RRESP,
    output wire                             S_AXI_RVALID,
    input wire                              S_AXI_RREADY,

    // user info
    input wire [32*N_PKT - 1:0] tdata,
    input wire                  tvalid,
    output wire                 busy,

    input wire [31:0] write_data_count,
    input wire [31:0] read_data_count
);

    
    //------------------------Address Info-------------------
    // 0x00 : write_data_count : bit [31:0]      - write_data_count[31: 0]
    // 0x04 : read_data_count  : bit [31:0]      - read_data_count[31: 0]
    // 0x08 : word_read        : bit [N_PKT-1:0] - word_read[N_PKT-1:0]
    // 0x0c : reserved
    // 0x08 - : data

    //////////////////////////////////////////////// Signal definitions
    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
    reg                             axi_awready;
    reg                             axi_wready;
    reg [1 : 0]                     axi_bresp;
    reg                             axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
    reg                             axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
    reg [1 : 0]                     axi_rresp;
    reg                             axi_rvalid;

    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 5;

    wire                            slv_reg_rden;
    wire                            slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]    reg_data_out;
    
    reg                             aw_en;
    reg [N_PKT-1:0]                 word_read;

    //////////////////////////////////////////////// AXI logics
    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY     = axi_wready;
    assign S_AXI_BRESP      = axi_bresp;
    assign S_AXI_BVALID     = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA      = axi_rdata;
    assign S_AXI_RRESP      = axi_rresp;
    assign S_AXI_RVALID     = axi_rvalid;

    ////////////////////// WRITE
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_awready <= 1'b0;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
                axi_awready <= 1'b1;
            else if (S_AXI_BREADY && axi_bvalid)
               axi_awready <= 1'b0;
            else
               axi_awready <= 1'b0;
        end
    end

    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            aw_en <= 1'b1;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
                aw_en <= 1'b0;
            else if (S_AXI_BREADY && axi_bvalid)
                aw_en <= 1'b1;
        end
    end

    // axi_awaddr latching
    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 )
            axi_awaddr <= 0;
        else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) 
                axi_awaddr <= S_AXI_AWADDR;
        end
    end

    // axi_wready generation
    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 )
            axi_wready <= 1'b0;
        else begin
            if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
                axi_wready <= 1'b1;
            else
                axi_wready <= 1'b0;
        end 
    end

    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            ;
        end else begin
            if (slv_reg_wren) begin
                ;
            end else begin
                ;
            end
        end
    end

    // write response logic generation
    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_bvalid  <= 0;
            axi_bresp   <= 2'b0;
        end else begin
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
                // indicates a valid write response is available
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0; // 'OKAY' response 
            end else begin
                if (S_AXI_BREADY && axi_bvalid) 
                    axi_bvalid <= 1'b0; 
            end
        end
    end   

    ////////////////////// READ
    // axi_arready generation
    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end else begin    
            if (~axi_arready && S_AXI_ARVALID) begin
                axi_arready <= 1'b1;
                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

    // axi_arvalid generation
    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end else begin    
            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;
            end else if (axi_rvalid && S_AXI_RREADY)
                axi_rvalid <= 1'b0;
        end
    end

    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    
    wire [OPT_MEM_ADDR_BITS:0] addr4 = axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
    always @(*) begin
        if (addr4 == 6'h0)
            reg_data_out <= write_data_count;
        else if (addr4 == 6'h1)
            reg_data_out <= read_data_count;
        else if (addr4 == 6'h2)
            reg_data_out <= word_read;
        else if (addr4 == 6'h3)
            reg_data_out <= 32'h0;
        else if ((6'h4 <= addr4) && (addr4 < N_PKT + 4))
            reg_data_out <= tdata[32*(addr4 - 6'h4)+:32];
        else
            reg_data_out <= 32'h0;
    end

    // Output register or memory read data
    always @( posedge S_AXI_ACLK ) begin
        if ( S_AXI_ARESETN == 1'b0 )
            axi_rdata  <= 0;
        else begin if (slv_reg_rden)
            axi_rdata <= reg_data_out;
        end
    end

    /* User logic */
    assign busy = (word_read != {(N_PKT){1'b0}});

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            word_read <= {(N_PKT){1'b0}};
        end else begin
            if (~busy && tvalid) begin
                word_read <= {(N_PKT){1'b1}};
            end else begin
                if (slv_reg_rden) begin
                    if ((6'h4 <= addr4) && (addr4 < N_PKT + 4))
                        word_read[addr4 - 6'h4] <= 0;
                end
            end
        end
    end

endmodule
