create_clock -period 8 [get_ports clk_125MHz_i]

set_property PACKAGE_PIN T16 [get_ports {switches_i[3]}]
set_property PACKAGE_PIN W13 [get_ports {switches_i[2]}]
set_property PACKAGE_PIN P15 [get_ports {switches_i[1]}]
set_property PACKAGE_PIN G15 [get_ports {switches_i[0]}]

set_property PACKAGE_PIN Y16 [get_ports {buttons_i[3]}]
set_property PACKAGE_PIN V16 [get_ports {buttons_i[2]}]
set_property PACKAGE_PIN P16 [get_ports {buttons_i[1]}]
set_property PACKAGE_PIN R18 [get_ports {buttons_i[0]}]

set_property PACKAGE_PIN D18 [get_ports {leds_o[3]}]
set_property PACKAGE_PIN G14 [get_ports {leds_o[2]}]
set_property PACKAGE_PIN M15 [get_ports {leds_o[1]}]
set_property PACKAGE_PIN M14 [get_ports {leds_o[0]}]

set_property PACKAGE_PIN L16 [get_ports clk_125MHz_i]

set_property PACKAGE_PIN W16 [get_ports pmod_e_2_txd_o]
set_property PACKAGE_PIN J15 [get_ports pmod_e_3_rxd_i]

# IO standard set by default. 
# Set individually other pins that need a different standard. 
set_property IOSTANDARD LVCMOS33 [get_ports *]


