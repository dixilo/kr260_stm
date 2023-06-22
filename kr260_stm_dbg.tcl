# KR260 stimulator firmware

## Utility
source ./util.tcl

## Device setting (RFSoC 2x2)
set p_device "xck26-sfvc784-2LV-c"
set p_board "xilinx.com:kr260_som:part0:1.0"

set project_name "kr260_stm_dbg"

create_project -force $project_name ./${project_name} -part $p_device
set_property board_part $p_board [current_project]
set_property platform.extensible true [current_project]

add_files -norecurse -fileset sources_1 {\
    "./hdl/pps_timer.v" \
    "./hdl/enc_timer.v" \
}

add_files -fileset constrs_1 -norecurse {\
    "./constraints/kr260_stm_dbg.xdc" \
}

## IP repository
set_property  ip_repo_paths  {\
    ./hls \
    ./ip \
} [current_project]

#set_property ip_repo_paths $lib_dirs [current_fileset]
update_ip_catalog

## create board design
create_bd_design "system"


## port definitions
### pps single ended
create_bd_port -dir I pps

### enc_0 diff
create_bd_port -dir I enc_0_p
create_bd_port -dir I enc_0_n
create_bd_cell -type ip -vlnv [latest_ip util_ds_buf] util_ds_buf_0
connect_bd_net [get_bd_ports enc_0_p] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
connect_bd_net [get_bd_ports enc_0_n] [get_bd_pins util_ds_buf_0/IBUF_DS_N]

## dummy
set xlconstant_enc1 [create_bd_cell -type ip -vlnv [latest_ip xlconstant] xlconstant_enc1]
set_property -dict [list CONFIG.CONST_WIDTH {1} CONFIG.CONST_VAL {0}] $xlconstant_enc1

### concat
create_bd_cell -type ip -vlnv [latest_ip xlconcat] xlconcat_enc
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins xlconcat_enc/In0]
connect_bd_net [get_bd_pins xlconstant_enc1/dout]   [get_bd_pins xlconcat_enc/In1]

### SPI
create_bd_port -dir O spi_mosi
create_bd_port -dir I spi_miso
create_bd_port -dir O spi_sck
create_bd_port -dir O -from 9 -to 0 spi_cs



## Zynq
source ./zynq_inst.tcl


## PPS tester
create_bd_cell -type module -reference pps_timer pps_timer
create_bd_cell -type module -reference enc_timer enc_timer

## FIFO
create_bd_cell -type ip -vlnv [latest_ip axis_data_fifo] axis_data_fifo
set_property CONFIG.TDATA_NUM_BYTES {12} [get_bd_cells axis_data_fifo]
set_property CONFIG.HAS_RD_DATA_COUNT {1} [get_bd_cells axis_data_fifo]
set_property CONFIG.HAS_WR_DATA_COUNT {1} [get_bd_cells axis_data_fifo]

## Simple reader for PPS
create_bd_cell -type ip -vlnv [latest_ip axi_reader] axi_reader

## Stream reader for Encoder
create_bd_cell -type ip -vlnv [latest_ip str_rd] str_rd

## AXI QUAD SPI
create_bd_cell -type ip -vlnv [latest_ip axi_quad_spi] axi_quad_spi
set_property CONFIG.C_NUM_SS_BITS {10} [get_bd_cells axi_quad_spi]
set_property CONFIG.Multiples16 {8} [get_bd_cells axi_quad_spi]

## Connection
### Encoder
connect_bd_net [get_bd_pins xlconcat_enc/dout] [get_bd_pins enc_timer/enc_in]
connect_bd_net [get_bd_pins enc_timer/clk] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins enc_timer/rstn] [get_bd_pins psr_200/peripheral_aresetn]
connect_bd_net [get_bd_pins enc_timer/timer_cnt_in] [get_bd_pins zynq_ultra_ps_e_0/emio_enet0_enet_tsu_timer_cnt]

connect_bd_intf_net [get_bd_intf_pins enc_timer/m_axis] [get_bd_intf_pins axis_data_fifo/S_AXIS]
connect_bd_net [get_bd_pins axis_data_fifo/s_axis_aclk] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axis_data_fifo/s_axis_aresetn] [get_bd_pins psr_200/peripheral_aresetn]

connect_bd_intf_net [get_bd_intf_pins axis_data_fifo/M_AXIS] [get_bd_intf_pins str_rd/s_axis]
connect_bd_net [get_bd_pins axis_data_fifo/axis_wr_data_count] [get_bd_pins str_rd/write_data_count]
connect_bd_net [get_bd_pins axis_data_fifo/axis_rd_data_count] [get_bd_pins str_rd/read_data_count]
connect_bd_net [get_bd_pins str_rd/s_axi_aclk] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins str_rd/s_axi_aresetn] [get_bd_pins psr_200/peripheral_aresetn]

connect_bd_net [get_bd_ports pps] [get_bd_pins pps_timer/pps]
connect_bd_net [get_bd_pins pps_timer/clk] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins pps_timer/rstn] [get_bd_pins psr_200/peripheral_aresetn]
connect_bd_net [get_bd_pins pps_timer/timer_cnt_in] [get_bd_pins zynq_ultra_ps_e_0/emio_enet0_enet_tsu_timer_cnt]


connect_bd_net [get_bd_pins pps_timer/timer_cnt_out] [get_bd_pins axi_reader/cnt_in]
connect_bd_net [get_bd_pins axi_reader/ap_clk] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axi_reader/s_axi_aclk] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axi_reader/ap_rst_n] [get_bd_pins psr_200/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_reader/ap_rst_n_s_axi_aclk] [get_bd_pins psr_200/peripheral_aresetn]

connect_bd_net [get_bd_ports spi_mosi] [get_bd_pins axi_quad_spi/io0_o]
connect_bd_net [get_bd_ports spi_miso] [get_bd_pins axi_quad_spi/io1_i]
connect_bd_net [get_bd_ports spi_sck] [get_bd_pins axi_quad_spi/sck_o]
connect_bd_net [get_bd_ports spi_cs] [get_bd_pins axi_quad_spi/ss_o]
connect_bd_net [get_bd_pins axi_quad_spi/s_axi_aclk] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axi_quad_spi/s_axi_aresetn] [get_bd_pins psr_200/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_quad_spi/ext_spi_clk] [get_bd_pins clk_wiz_cpu/clk_out1]
connect_bd_net [get_bd_pins axi_quad_spi/ip2intc_irpt] [get_bd_pins xlconcat_intc/In0]


set_property -dict [list CONFIG.NUM_MI {3}] [get_bd_cells axi_ic_cpu]

connect_bd_intf_net [get_bd_intf_pins axi_reader/s_axi_control] -boundary_type upper [get_bd_intf_pins axi_ic_cpu/M01_AXI]
connect_bd_intf_net [get_bd_intf_pins str_rd/s_axi] -boundary_type upper [get_bd_intf_pins axi_ic_cpu/M02_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_quad_spi/AXI_LITE] -boundary_type upper [get_bd_intf_pins axi_ic_cpu/M00_AXI]
connect_bd_net [get_bd_pins axi_ic_cpu/M01_ACLK] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axi_ic_cpu/M01_ARESETN] [get_bd_pins psr_200/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_ic_cpu/M02_ACLK] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axi_ic_cpu/M02_ARESETN] [get_bd_pins psr_200/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_ic_cpu/M00_ACLK] [get_bd_pins clk_wiz_cpu/clk_out2]
connect_bd_net [get_bd_pins axi_ic_cpu/M00_ARESETN] [get_bd_pins psr_200/interconnect_aresetn]


assign_bd_address -offset 0x00_8001_0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_reader/s_axi_control/Reg] -force
assign_bd_address -offset 0x00_8002_0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs str_rd/s_axi/reg0] -force
assign_bd_address -offset 0x00_8003_0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_quad_spi/AXI_LITE/Reg] -force

### Project
save_bd_design
validate_bd_design

set project_system_dir "./${project_name}/${project_name}.srcs/sources_1/bd/system"

set_property synth_checkpoint_mode None [get_files  $project_system_dir/system.bd]
generate_target {synthesis implementation} [get_files  $project_system_dir/system.bd]
make_wrapper -files [get_files $project_system_dir/system.bd] -top

import_files -force -norecurse -fileset sources_1 $project_system_dir/hdl/system_wrapper.v
set_property top system_wrapper [current_fileset]
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]
