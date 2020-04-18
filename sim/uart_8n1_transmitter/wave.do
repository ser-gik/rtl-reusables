onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider IN
add wave -noupdate /tb/subject/trans_data
add wave -noupdate /tb/subject/trans_write
add wave -noupdate /tb/subject/clk_baud_16x
add wave -noupdate /tb/subject/reset
add wave -noupdate -divider OUT
add wave -noupdate /tb/subject/trans_busy
add wave -noupdate /tb/subject/tx
add wave -noupdate -divider INTERNAL
add wave -noupdate /tb/subject/frame
add wave -noupdate /tb/subject/state
add wave -noupdate /tb/subject/should_start
add wave -noupdate /tb/subject/should_send_next_bit
add wave -noupdate /tb/subject/should_stop
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 388
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
WaveRestoreZoom {0 ps} {8414700 ps}
