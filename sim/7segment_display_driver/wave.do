onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider IN
add wave -noupdate /tb/subject/data
add wave -noupdate /tb/subject/digit_enable_mask
add wave -noupdate /tb/subject/decimal_point_enable_mask
add wave -noupdate /tb/subject/reset
add wave -noupdate /tb/subject/clk
add wave -noupdate -divider OUT
add wave -noupdate /tb/subject/display_led_segments
add wave -noupdate /tb/subject/display_led_enable_mask
add wave -noupdate -divider INTERNAL
add wave -noupdate /tb/subject/div_stages
add wave -noupdate /tb/subject/block_clk
add wave -noupdate /tb/subject/data_latch
add wave -noupdate /tb/subject/cur_active_mask
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4999400 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 421
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
WaveRestoreZoom {0 ps} {5250 ns}
