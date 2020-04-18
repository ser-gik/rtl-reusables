onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider IN
add wave -noupdate /tb/subject/clk_src
add wave -noupdate /tb/subject/baud_rate
add wave -noupdate /tb/subject/reset
add wave -noupdate -divider OUT
add wave -noupdate /tb/subject/clk_baud_16x
add wave -noupdate -divider INTERNAL
add wave -noupdate /tb/subject/next_threshold
add wave -noupdate /tb/subject/counter
add wave -noupdate /tb/subject/threshold
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1205300 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 406
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1266300 ps}
