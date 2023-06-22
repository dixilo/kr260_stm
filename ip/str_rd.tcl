# FFT quad
set ip_name "str_rd"
create_project $ip_name "." -force
source ./util.tcl

# file
set proj_fileset [get_filesets sources_1]
add_files -norecurse -scan_for_includes -fileset $proj_fileset [list \
"str_rd.v" \
"str_rd_core.v" \
]

set_property "top" "str_rd" $proj_fileset

ipx::package_project -root_dir "." -vendor kuhep -library user -taxonomy /kuhep
set_property name $ip_name [ipx::current_core]
set_property vendor_display_name {kuhep} [ipx::current_core]

# Interface
ipx::infer_bus_interface s_axi_aclk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::save_core [ipx::current_core]

ipx::associate_bus_interfaces -busif s_axis -clock s_axi_aclk [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axi -clock s_axi_aclk [ipx::current_core]

ipx::save_core [ipx::current_core]
