# STEP#0: project configuration.
set PROJECT_NAME    "zybo_demo"
set PROJECT_TOP     "zybo_top"
set RTL_DIR         "../../vhdl"
set BOARD_DIR       "./src"
set OBJ_CODE_DIR    "../../test/dhrystone"
set VHDL_FILES [list \
    "$RTL_DIR/light52_pkg.vhdl" \
    "$RTL_DIR/light52_ucode_pkg.vhdl" \
    "$OBJ_CODE_DIR/obj_code_pkg.vhdl" \
    "$RTL_DIR/light52_muldiv.vhdl" \
    "$RTL_DIR/light52_alu.vhdl" \
    "$RTL_DIR/light52_cpu.vhdl" \
    "$RTL_DIR/light52_timer.vhdl" \
    "$RTL_DIR/light52_uart.vhdl" \
    "$RTL_DIR/light52_mcu.vhdl" \
    "$BOARD_DIR/zybo_top.vhdl" \
]
set XDC_FILES [list \
    "$BOARD_DIR/constraints/vivado-zybo.xdc" \
]
# From this point onwards the script is mostly generic.

# STEP#1: define the output directory area.
#
set outputDir ./$PROJECT_NAME
file mkdir $outputDir
#
# STEP#2: setup design sources and constraints
#
read_vhdl   $VHDL_FILES
read_xdc    $XDC_FILES
#
# STEP#3: run synthesis, write design checkpoint, report timing,
# and utilization estimates
#
synth_design -top $PROJECT_TOP -part "xc7z010clg400-1"
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -hierarchical -file $outputDir/post_synth_util.rpt
#
# Run custom script to report critical timing paths
# FIXME TBD
#reportCriticalPaths $outputDir/post_synth_critpath_report.csv
#
# STEP#4: run logic optimization, placement and physical logic optimization,
# write design checkpoint, report utilization and timing estimates
#
opt_design
#FIXME TBD
#reportCriticalPaths $outputDir/post_opt_critpath_report.csv
place_design
report_clock_utilization -file $outputDir/clock_util.rpt
#
# Optionally run optimization if there are timing violations after placement
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
puts "Found setup timing violations => running physical optimization"
phys_opt_design
}
write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_utilization -file $outputDir/post_place_util.hier.rpt -hierarchical
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
#
# STEP#5: run the router, write the post-route design checkpoint, report the routing
# status, report timing, power, and DRC, and finally save the Verilog netlist.
#
route_design
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
# TODO WE don't need the Verilog netlist, make this optional.
#write_verilog -force $outputDir/cpu_impl_netlist.v -mode timesim -sdf_anno true
#
# STEP#6: generate a bitstream
#
write_bitstream -force $outputDir/$PROJECT_NAME.bit
