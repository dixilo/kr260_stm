open_project -reset proj_reader

# Add design files
add_files reader.cpp

# Set the top-level function
set_top axi_reader

# ########################################################
# Create a solution
open_solution -reset solution1 -flow_target vivado

# Define technology and clock rate
set_part {xck26-sfvc784-2LV-c}
create_clock -period 2
set_clock_uncertainty 0.2
config_rtl -reset all

csynth_design
export_design -format ip_catalog

exit
