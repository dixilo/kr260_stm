set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv [latest_ip zynq_ultra_ps_e] zynq_ultra_ps_e_0 ]
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0] $zynq_ultra_ps_e_0

# https://www.hackster.io/whitney-knitter/getting-started-with-the-kria-kr260-in-vivado-2022-1-33746d#toc-export-platform-for-sw-development-8
# refclk for psu__dp (line 14) is modified from the instruction to fix error.
set_property -dict [list \
    CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__ENET0__PERIPHERAL__IO {GT Lane0} \
    CONFIG.PSU__ENET1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__ENET1__GRP_MDIO__ENABLE {1} \
    CONFIG.PSU__ENET1__GRP_MDIO__IO {MIO 50 .. 51} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 24 .. 25} \
    CONFIG.PSU__DP__REF_CLK_SEL {Ref Clk0} \
    CONFIG.PSU__DP__LANE_SEL {Single Lower} \
    CONFIG.PSU__TTC0__WAVEOUT__ENABLE {1} \
    CONFIG.PSU__TTC0__WAVEOUT__IO {EMIO} \
    CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 36 .. 37} \
    CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB0__RESET__ENABLE {1} \
    CONFIG.PSU__USB0__RESET__IO {MIO 76} \
    CONFIG.PSU__USB__RESET__MODE {Separate MIO Pin} \
    CONFIG.PSU__USB1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB1__RESET__ENABLE {1} \
    CONFIG.PSU__USB1__RESET__IO {MIO 77} \
    CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
    CONFIG.PSU__USB3_1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USE__M_AXI_GP0 {0} \
    CONFIG.PSU__USE__M_AXI_GP1 {0} \
    CONFIG.PSU__USE__M_AXI_GP2 {1} \
    CONFIG.PSU__NUM_FABRIC_RESETS {4}] $zynq_ultra_ps_e_0

# Fan controller
set xlslice_cpu [create_bd_cell -type ip -vlnv [latest_ip xlslice] xlslice_cpu]
set_property -dict [list CONFIG.DIN_TO {2} CONFIG.DIN_FROM {2} CONFIG.DIN_WIDTH {3} CONFIG.DOUT_WIDTH {1}] $xlslice_cpu
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/emio_ttc0_wave_o] [get_bd_pins xlslice_cpu/Din]
create_bd_port -dir O fan_en_b
connect_bd_net [get_bd_ports fan_en_b] [get_bd_pins xlslice_cpu/Dout]

# clocking wizard
set clk_wiz_cpu [create_bd_cell -type ip -vlnv [latest_ip clk_wiz] clk_wiz_cpu]
set_property -dict [list CONFIG.CLKOUT2_USED {true} \
                         CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {49.9995} \
                         CONFIG.RESET_TYPE {ACTIVE_LOW}] $clk_wiz_cpu

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins clk_wiz_cpu/clk_in1]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins clk_wiz_cpu/resetn]

# System resets
set psr_100 [create_bd_cell -type ip -vlnv [latest_ip proc_sys_reset] psr_100]
set psr_200 [create_bd_cell -type ip -vlnv [latest_ip proc_sys_reset] psr_200]
connect_bd_net [get_bd_pins clk_wiz_cpu/clk_out1] [get_bd_pins psr_100/slowest_sync_clk]
connect_bd_net [get_bd_pins clk_wiz_cpu/clk_out2] [get_bd_pins psr_200/slowest_sync_clk]
connect_bd_net [get_bd_pins psr_100/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]
connect_bd_net [get_bd_pins psr_200/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

# AXI clock
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk] [get_bd_pins clk_wiz_cpu/clk_out2]

# Interrupt
set xlconcat_intc [create_bd_cell -type ip -vlnv [latest_ip xlconcat] xlconcat_intc]
set_property CONFIG.NUM_PORTS {1} $xlconcat_intc
connect_bd_net [get_bd_pins xlconcat_intc/dout] [get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]

# Interconnect
set axi_ic_cpu [create_bd_cell -type ip -vlnv [latest_ip axi_interconnect] axi_ic_cpu]
set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells axi_ic_cpu]

connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_LPD] -boundary_type upper [get_bd_intf_pins axi_ic_cpu/S00_AXI]
connect_bd_net [get_bd_pins axi_ic_cpu/ACLK] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axi_ic_cpu/S00_ACLK] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins psr_200/interconnect_aresetn] [get_bd_pins axi_ic_cpu/ARESETN]
connect_bd_net [get_bd_pins psr_200/interconnect_aresetn] [get_bd_pins axi_ic_cpu/S00_ARESETN]

# TSU
set_property -dict [list CONFIG.PSU__ENET0__TSU__ENABLE {1}] $zynq_ultra_ps_e_0
set xlconstant_tsu [create_bd_cell -type ip -vlnv [latest_ip xlconstant] xlconstant_tsu]
set_property -dict [list CONFIG.CONST_WIDTH {2} CONFIG.CONST_VAL {3}] $xlconstant_tsu
connect_bd_net [get_bd_pins xlconstant_tsu/dout] [get_bd_pins zynq_ultra_ps_e_0/emio_enet0_tsu_inc_ctrl]
