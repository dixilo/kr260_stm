`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
import axi_vip_pkg::*;
import system_axi_vip_0_pkg::*;

module sim_full(

    );

    localparam STEP_SYS = 50;

    // input

    logic s_axi_aclk;
    logic s_axi_aresetn;
    logic [95:0] s_axis_tdata;
    logic s_axis_tready;
    logic s_axis_tvalid;

    system_wrapper dut(.*);

    system_axi_vip_0_mst_t  agent;

    task clk_gen();
        s_axi_aclk = 0;
        forever #(STEP_SYS/2) s_axi_aclk = ~s_axi_aclk;
    endtask

    task rst_gen();
        s_axi_aresetn = 0;
        s_axis_tdata = 96'b0;
        s_axis_tvalid = 0;

        #(STEP_SYS*50);
        s_axi_aresetn = 1;
    endtask

    task rd_tran();
        axi_transaction  rd_transaction;
        rd_transaction   = agent.rd_driver.create_transaction("read transaction with randomization");
        RD_TRANSACTION_FAIL_1a:assert(rd_transaction.randomize());

        rd_transaction.set_read_cmd(32'h00, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
        rd_transaction.set_read_cmd(32'h04, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
        rd_transaction.set_read_cmd(32'h08, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
        rd_transaction.set_read_cmd(32'h0c, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
        
        rd_transaction.set_read_cmd(32'h10, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
        rd_transaction.set_read_cmd(32'h14, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);

        rd_transaction.set_read_cmd(32'h1c, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
        rd_transaction.set_read_cmd(32'h18, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
    endtask
    
    task axis_tran(logic [95:0] data);
        @(posedge s_axi_aclk);
        s_axis_tdata <= data;
        s_axis_tvalid <= 1'b1;
        @(posedge s_axi_aclk);
        s_axis_tvalid <= 1'b0;
    endtask

    initial begin : START_system_axi_vip_0_0_MASTER
        fork
            clk_gen();
            rst_gen();
        join_none
        
        #(STEP_SYS*10);
    
        agent = new("my VIP master", sim_full.dut.system_i.axi_vip.inst.IF);
        agent.start_master();
        #(STEP_SYS*100);

        rd_tran();
        #(STEP_SYS*1000);
        axis_tran(96'h00000003_00000002_00000001);
        axis_tran(96'h00000006_00000005_00000004);
        axis_tran(96'h00000009_00000008_00000007);
        axis_tran(96'h0000000c_0000000b_0000000a);
        #(STEP_SYS*10);
        
        rd_tran();
        rd_tran();
        rd_tran();
        rd_tran();
        rd_tran();

        // Channel
        #(STEP_SYS*1000);
        $finish;
    end
endmodule
