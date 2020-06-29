onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/r_reg_inst/clk
add wave -noupdate /tb/r_reg_inst/reset
add wave -noupdate /tb/r_reg_inst/d
add wave -noupdate /tb/r_reg_inst/q
add wave -noupdate /tb/r_reg_inst/ff
add wave -noupdate /tb/r_reg_inst/clk_rising
add wave -noupdate /tb/r_reg_inst/reset_high
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 220
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {126 ns}
