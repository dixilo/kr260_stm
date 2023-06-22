## Utility
source ../util.tcl

## Device setting (KCU105)
set p_device "xcku040-ffva1156-2-e"
set p_board "xilinx.com:kcu105:part0:1.7"

set project_name "axi_bench"

create_project -force $project_name ./${project_name} -part $p_device
set_property board_part $p_board [current_project]

set_property  ip_repo_paths  "." [current_project]

## create board design
create_bd_design "system"

### DDC_DAQ2
create_bd_cell -type ip -vlnv [latest_ip str_rd] str_rd

### AXI VIP
create_bd_cell -type ip -vlnv [latest_ip axi_vip] axi_vip
set_property CONFIG.INTERFACE_MODE {MASTER} [get_bd_cells axi_vip]

### Interconnect
create_bd_cell -type ip -vlnv [latest_ip axi_interconnect] axi_interconnect
set_property CONFIG.NUM_MI {1} [get_bd_cells axi_interconnect]


### FIFO
create_bd_cell -type ip -vlnv [latest_ip axis_data_fifo] axis_data_fifo
set_property CONFIG.HAS_RD_DATA_COUNT {1} [get_bd_cells axis_data_fifo]
set_property CONFIG.HAS_WR_DATA_COUNT {1} [get_bd_cells axis_data_fifo]
set_property CONFIG.TDATA_NUM_BYTES.VALUE_SRC {USER} [get_bd_cells axis_data_fifo]
set_property CONFIG.TDATA_NUM_BYTES {12} [get_bd_cells axis_data_fifo]

## Connection
### Port definition
#### Clock and reset
create_bd_port -dir I -type clk s_axi_aclk
set_property CONFIG.FREQ_HZ 200000000 [get_bd_ports s_axi_aclk]

create_bd_port -dir I -type rst s_axi_aresetn

#### Data
# Input
create_bd_port -dir I -from 95 -to 0 -type data s_axis_tdata
create_bd_port -dir O -type data s_axis_tready
create_bd_port -dir I -type data s_axis_tvalid


### AXI intf
connect_bd_intf_net [get_bd_intf_pins axi_vip/M_AXI] -boundary_type upper [get_bd_intf_pins axi_interconnect/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect/M00_AXI] -boundary_type upper [get_bd_intf_pins str_rd/s_axi]

### AXIS intf
connect_bd_intf_net [get_bd_intf_pins axis_data_fifo/M_AXIS] -boundary_type upper [get_bd_intf_pins str_rd/s_axis]

### AXI Clock
connect_bd_net [get_bd_ports s_axi_aclk] [get_bd_pins axi_vip/aclk]
connect_bd_net [get_bd_ports s_axi_aclk] [get_bd_pins axi_interconnect/ACLK]
connect_bd_net [get_bd_ports s_axi_aclk] [get_bd_pins axi_interconnect/S00_ACLK]
connect_bd_net [get_bd_ports s_axi_aclk] [get_bd_pins axi_interconnect/M00_ACLK]
connect_bd_net [get_bd_ports s_axi_aclk] [get_bd_pins str_rd/s_axi_aclk]
connect_bd_net [get_bd_ports s_axi_aclk] [get_bd_pins axis_data_fifo/s_axis_aclk]

### AXI aresetn
connect_bd_net [get_bd_ports s_axi_aresetn] [get_bd_pins axi_vip/aresetn]
connect_bd_net [get_bd_ports s_axi_aresetn] [get_bd_pins axi_interconnect/ARESETN]
connect_bd_net [get_bd_ports s_axi_aresetn] [get_bd_pins axi_interconnect/M00_ARESETN]
connect_bd_net [get_bd_ports s_axi_aresetn] [get_bd_pins axi_interconnect/S00_ARESETN]
connect_bd_net [get_bd_ports s_axi_aresetn] [get_bd_pins str_rd/s_axi_aresetn]
connect_bd_net [get_bd_ports s_axi_aresetn] [get_bd_pins axis_data_fifo/s_axis_aresetn]

### Data
connect_bd_net [get_bd_ports s_axis_tdata]  [get_bd_pins axis_data_fifo/s_axis_tdata]
connect_bd_net [get_bd_ports s_axis_tready] [get_bd_pins axis_data_fifo/s_axis_tready]
connect_bd_net [get_bd_ports s_axis_tvalid] [get_bd_pins axis_data_fifo/s_axis_tvalid]

### misc
connect_bd_net [get_bd_pins axis_data_fifo/axis_wr_data_count] [get_bd_pins str_rd/write_data_count]
connect_bd_net [get_bd_pins axis_data_fifo/axis_rd_data_count] [get_bd_pins str_rd/read_data_count]

## Project
save_bd_design
validate_bd_design

set project_system_dir "./${project_name}/${project_name}.srcs/sources_1/bd/system"

set_property synth_checkpoint_mode None [get_files  $project_system_dir/system.bd]
generate_target {synthesis implementation} [get_files  $project_system_dir/system.bd]
make_wrapper -files [get_files $project_system_dir/system.bd] -top

import_files -force -norecurse -fileset sources_1 $project_system_dir/hdl/system_wrapper.v
#add_files -norecurse -fileset sources_1 [glob ./src/*]
set_property top system_wrapper [current_fileset]

### Simulation
add_files -fileset sim_1 -norecurse ./sim_full.sv
set_property top sim_full [get_filesets sim_1]


# Run
## Synthesis
#launch_runs synth_1
#wait_on_run synth_1
#open_run synth_1
#report_utilization -file "./utilization.txt" -name utilization_1

## Implementation
#set_property strategy Performance_Retiming [get_runs impl_1]
#launch_runs impl_1 -to_step write_bitstream
#wait_on_run impl_1
#open_run impl_1
#report_timing_summary -file timing_impl.log
