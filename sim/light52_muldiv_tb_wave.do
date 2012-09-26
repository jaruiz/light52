onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /light52_muldiv_tb/clk
add wave -noupdate -format Logic /light52_muldiv_tb/reset
add wave -noupdate -divider Inputs
add wave -noupdate -color Khaki -format Literal -radix hexadecimal /light52_muldiv_tb/data_a
add wave -noupdate -color Tan -format Literal -radix hexadecimal /light52_muldiv_tb/data_b
add wave -noupdate -divider Control
add wave -noupdate -format Logic /light52_muldiv_tb/load_a
add wave -noupdate -format Logic /light52_muldiv_tb/load_b
add wave -noupdate -color Firebrick -format Logic /light52_muldiv_tb/div_ready
add wave -noupdate -color {Dark Green} -format Logic /light52_muldiv_tb/mul_ready
add wave -noupdate -color Pink -format Literal /light52_muldiv_tb/uut/bit_ctr
add wave -noupdate -divider Results
add wave -noupdate -color {Dark Green} -format Literal -radix hexadecimal /light52_muldiv_tb/product
add wave -noupdate -color Firebrick -format Literal -radix hexadecimal /light52_muldiv_tb/quotient
add wave -noupdate -color Orange -format Literal -radix hexadecimal /light52_muldiv_tb/remainder
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {110201 ps}
