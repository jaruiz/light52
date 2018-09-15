# Run this script with quartus_sh -t

#####################################################################################
# Project configuration.
#####################################################################################

set PROJECT_NAME    "de1_demo"
set PROJECT_TOP     "de1_top"
set RTL_DIR         "../../vhdl"
set BOARD_DIR       "./src"
set OBJ_CODE_DIR    "../../test/dhrystone"

#####################################################################################
# Create project, then add source files and pin assignments.
#####################################################################################

# Load whatever Altera packages are needed by the flow commands below.
load_package flow 

# Create the project.
project_new $PROJECT_NAME -overwrite

# Add all the source files. Order counts.
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_pkg.vhdl
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_ucode_pkg.vhdl
set_global_assignment -name VHDL_FILE $OBJ_CODE_DIR/obj_code_pkg.vhdl
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_muldiv.vhdl
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_alu.vhdl
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_cpu.vhdl
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_timer.vhdl
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_uart.vhdl
set_global_assignment -name VHDL_FILE $RTL_DIR/light52_mcu.vhdl
set_global_assignment -name VHDL_FILE $BOARD_DIR/de1_top.vhdl


# Prepare project to target Terasic's DE1 board.
set_global_assignment -name FAMILY "Cyclone II"
set_global_assignment -name DEVICE EP2C20F484C7
set_global_assignment -name TOP_LEVEL_ENTITY $PROJECT_TOP
# We're gonna use one of these pins as regular I/O so let the synth tool know.
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "USE AS REGULAR IO"

#------------------------------------------------------------------------------------
# Pin assignments: placement & I/O standard.
#------------------------------------------------------------------------------------

set_location_assignment PIN_T21 -to buttons[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to buttons[3]
set_location_assignment PIN_T22 -to buttons[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to buttons[2]
set_location_assignment PIN_R21 -to buttons[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to buttons[1]
set_location_assignment PIN_R22 -to buttons[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to buttons[0]
set_location_assignment PIN_R13 -to flash_addr[21]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[21]
set_location_assignment PIN_U13 -to flash_addr[20]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[20]
set_location_assignment PIN_V14 -to flash_addr[19]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[19]
set_location_assignment PIN_U14 -to flash_addr[18]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[18]
set_location_assignment PIN_AA20 -to flash_addr[17]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[17]
set_location_assignment PIN_AB12 -to flash_addr[16]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[16]
set_location_assignment PIN_AA12 -to flash_addr[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[15]
set_location_assignment PIN_AB13 -to flash_addr[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[14]
set_location_assignment PIN_AA13 -to flash_addr[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[13]
set_location_assignment PIN_AB14 -to flash_addr[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[12]
set_location_assignment PIN_T12 -to flash_addr[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[11]
set_location_assignment PIN_R12 -to flash_addr[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[10]
set_location_assignment PIN_Y13 -to flash_addr[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[9]
set_location_assignment PIN_R14 -to flash_addr[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[8]
set_location_assignment PIN_W15 -to flash_addr[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[7]
set_location_assignment PIN_V15 -to flash_addr[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[6]
set_location_assignment PIN_U15 -to flash_addr[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[5]
set_location_assignment PIN_T15 -to flash_addr[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[4]
set_location_assignment PIN_R15 -to flash_addr[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[3]
set_location_assignment PIN_Y16 -to flash_addr[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[2]
set_location_assignment PIN_AA14 -to flash_addr[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[1]
set_location_assignment PIN_AB20 -to flash_addr[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_addr[0]
set_location_assignment PIN_AA19 -to flash_data[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[7]
set_location_assignment PIN_AB19 -to flash_data[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[6]
set_location_assignment PIN_AA18 -to flash_data[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[5]
set_location_assignment PIN_AB18 -to flash_data[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[4]
set_location_assignment PIN_AA17 -to flash_data[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[3]
set_location_assignment PIN_AB17 -to flash_data[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[2]
set_location_assignment PIN_AA16 -to flash_data[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[1]
set_location_assignment PIN_AB16 -to flash_data[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_data[0]
set_location_assignment PIN_AA15 -to flash_oe_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_oe_n
set_location_assignment PIN_W14 -to flash_reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_reset_n
set_location_assignment PIN_Y14 -to flash_we_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to flash_we_n
set_location_assignment PIN_Y21 -to green_leds[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[7]
set_location_assignment PIN_Y22 -to green_leds[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[6]
set_location_assignment PIN_W21 -to green_leds[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[5]
set_location_assignment PIN_W22 -to green_leds[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[4]
set_location_assignment PIN_V21 -to green_leds[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[3]
set_location_assignment PIN_V22 -to green_leds[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[2]
set_location_assignment PIN_U21 -to green_leds[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[1]
set_location_assignment PIN_U22 -to green_leds[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green_leds[0]
set_location_assignment PIN_J2 -to hex0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex0[0]
set_location_assignment PIN_J1 -to hex0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex0[1]
set_location_assignment PIN_H2 -to hex0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex0[2]
set_location_assignment PIN_H1 -to hex0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex0[3]
set_location_assignment PIN_F2 -to hex0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex0[4]
set_location_assignment PIN_F1 -to hex0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex0[5]
set_location_assignment PIN_E2 -to hex0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex0[6]
set_location_assignment PIN_E1 -to hex1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex1[0]
set_location_assignment PIN_H6 -to hex1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex1[1]
set_location_assignment PIN_H5 -to hex1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex1[2]
set_location_assignment PIN_H4 -to hex1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex1[3]
set_location_assignment PIN_G3 -to hex1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex1[4]
set_location_assignment PIN_D2 -to hex1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex1[5]
set_location_assignment PIN_D1 -to hex1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex1[6]
set_location_assignment PIN_G5 -to hex2[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex2[0]
set_location_assignment PIN_G6 -to hex2[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex2[1]
set_location_assignment PIN_C2 -to hex2[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex2[2]
set_location_assignment PIN_C1 -to hex2[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex2[3]
set_location_assignment PIN_E3 -to hex2[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex2[4]
set_location_assignment PIN_E4 -to hex2[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex2[5]
set_location_assignment PIN_D3 -to hex2[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex2[6]
set_location_assignment PIN_F4 -to hex3[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex3[0]
set_location_assignment PIN_D5 -to hex3[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex3[1]
set_location_assignment PIN_D6 -to hex3[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex3[2]
set_location_assignment PIN_J4 -to hex3[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex3[3]
set_location_assignment PIN_L8 -to hex3[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex3[4]
set_location_assignment PIN_F3 -to hex3[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex3[5]
set_location_assignment PIN_D4 -to hex3[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hex3[6]
set_location_assignment PIN_R17 -to red_leds[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[9]
set_location_assignment PIN_R18 -to red_leds[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[8]
set_location_assignment PIN_U18 -to red_leds[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[7]
set_location_assignment PIN_Y18 -to red_leds[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[6]
set_location_assignment PIN_V19 -to red_leds[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[5]
set_location_assignment PIN_T18 -to red_leds[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[4]
set_location_assignment PIN_Y19 -to red_leds[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[3]
set_location_assignment PIN_U19 -to red_leds[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[2]
set_location_assignment PIN_R19 -to red_leds[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[1]
set_location_assignment PIN_R20 -to red_leds[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red_leds[0]
set_location_assignment PIN_F14 -to rxd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rxd
set_location_assignment PIN_V20 -to sd_clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sd_clk
set_location_assignment PIN_Y20 -to sd_cmd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sd_cmd
set_location_assignment PIN_U20 -to sd_cs
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sd_cs
set_location_assignment PIN_W20 -to sd_data
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sd_data
set_location_assignment PIN_Y5 -to sram_addr[17]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[17]
set_location_assignment PIN_Y6 -to sram_addr[16]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[16]
set_location_assignment PIN_T7 -to sram_addr[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[15]
set_location_assignment PIN_R10 -to sram_addr[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[14]
set_location_assignment PIN_U10 -to sram_addr[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[13]
set_location_assignment PIN_Y10 -to sram_addr[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[12]
set_location_assignment PIN_T11 -to sram_addr[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[11]
set_location_assignment PIN_R11 -to sram_addr[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[10]
set_location_assignment PIN_W11 -to sram_addr[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[9]
set_location_assignment PIN_V11 -to sram_addr[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[8]
set_location_assignment PIN_AB11 -to sram_addr[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[7]
set_location_assignment PIN_AA11 -to sram_addr[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[6]
set_location_assignment PIN_AB10 -to sram_addr[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[5]
set_location_assignment PIN_AA5 -to sram_addr[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[4]
set_location_assignment PIN_AB4 -to sram_addr[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[3]
set_location_assignment PIN_AA4 -to sram_addr[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[2]
set_location_assignment PIN_AB3 -to sram_addr[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[1]
set_location_assignment PIN_AA3 -to sram_addr[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_addr[0]
set_location_assignment PIN_AB5 -to sram_ce_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_ce_n
set_location_assignment PIN_U8 -to sram_data[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[15]
set_location_assignment PIN_V8 -to sram_data[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[14]
set_location_assignment PIN_W8 -to sram_data[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[13]
set_location_assignment PIN_R9 -to sram_data[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[12]
set_location_assignment PIN_U9 -to sram_data[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[11]
set_location_assignment PIN_V9 -to sram_data[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[10]
set_location_assignment PIN_W9 -to sram_data[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[9]
set_location_assignment PIN_Y9 -to sram_data[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[8]
set_location_assignment PIN_AB9 -to sram_data[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[7]
set_location_assignment PIN_AA9 -to sram_data[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[6]
set_location_assignment PIN_AB8 -to sram_data[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[5]
set_location_assignment PIN_AA8 -to sram_data[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[4]
set_location_assignment PIN_AB7 -to sram_data[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[3]
set_location_assignment PIN_AA7 -to sram_data[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[2]
set_location_assignment PIN_AB6 -to sram_data[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[1]
set_location_assignment PIN_AA6 -to sram_data[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_data[0]
set_location_assignment PIN_Y7 -to sram_lb_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_lb_n
set_location_assignment PIN_T8 -to sram_oe_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_oe_n
set_location_assignment PIN_W7 -to sram_ub_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_ub_n
set_location_assignment PIN_AA10 -to sram_we_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sram_we_n
set_location_assignment PIN_L2 -to switches[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[9]
set_location_assignment PIN_M1 -to switches[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[8]
set_location_assignment PIN_M2 -to switches[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[7]
set_location_assignment PIN_U11 -to switches[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[6]
set_location_assignment PIN_U12 -to switches[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[5]
set_location_assignment PIN_W12 -to switches[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[4]
set_location_assignment PIN_V12 -to switches[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[3]
set_location_assignment PIN_M22 -to switches[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[2]
set_location_assignment PIN_L21 -to switches[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[1]
set_location_assignment PIN_L22 -to switches[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to switches[0]
set_location_assignment PIN_G12 -to txd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to txd
set_location_assignment PIN_L1 -to clk_50MHz
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk_50MHz


#####################################################################################
# Run the flow.
#####################################################################################

# Synthesize, fit, assemble a programming file, and run timing analysis. 
puts "#### Analysis & Synthesis ######################################################"
execute_module -tool map
puts "#### Fitter ####################################################################"
execute_module -tool fit
puts "#### Assembler #################################################################"
execute_module -tool asm
puts "#### Timing Analyzer ###########################################################"
execute_module -tool sta -args --sdc=constraints.sdc

# Close the project
project_close
