set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

#Fan Speed Enable
set_property PACKAGE_PIN A12 [get_ports {fan_en_b}]
set_property IOSTANDARD LVCMOS33 [get_ports {fan_en_b}]
set_property SLEW SLOW [get_ports {fan_en_b}]
set_property DRIVE 4 [get_ports {fan_en_b}]

# Encoder input
set_property PACKAGE_PIN E10 [get_ports {enc_0_p}]
set_property IOSTANDARD LVDS_25 [get_ports {enc_0_p}]
set_property PACKAGE_PIN D10 [get_ports {enc_0_n}]
set_property IOSTANDARD LVDS_25 [get_ports {enc_0_n}]
set_property PACKAGE_PIN E12 [get_ports {enc_1_p}]
set_property IOSTANDARD LVDS_25 [get_ports {enc_1_p}]
set_property PACKAGE_PIN D11 [get_ports {enc_1_n}]
set_property IOSTANDARD LVDS_25 [get_ports {enc_1_n}]


# PPS input
set_property PACKAGE_PIN B10 [get_ports {pps}]
set_property IOSTANDARD LVCMOS33 [get_ports {pps}]

# SPI / RPi GPIO
set_property PACKAGE_PIN AE13 [get_ports {spi_mosi}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_mosi}]
set_property PACKAGE_PIN AC13 [get_ports {spi_miso}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_miso}]
set_property PACKAGE_PIN AF13 [get_ports {spi_sck}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_sck}]


set_property PACKAGE_PIN AA12 [get_ports {spi_cs[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[0]}]
set_property PACKAGE_PIN Y9 [get_ports {spi_cs[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[1]}]
set_property PACKAGE_PIN AA8 [get_ports {spi_cs[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[2]}]
set_property PACKAGE_PIN AC14 [get_ports {spi_cs[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[3]}]
set_property PACKAGE_PIN AH13 [get_ports {spi_cs[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[4]}]
set_property PACKAGE_PIN AD14 [get_ports {spi_cs[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[5]}]
set_property PACKAGE_PIN AA13 [get_ports {spi_cs[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[6]}]
set_property PACKAGE_PIN AB15 [get_ports {spi_cs[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[7]}]
set_property PACKAGE_PIN W12 [get_ports {spi_cs[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[8]}]
set_property PACKAGE_PIN W11 [get_ports {spi_cs[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs[9]}]
