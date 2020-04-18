onerror {resume}
quietly set dataset_list [list sim]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/uart_8n1_clock_gen_tb/subject/clk_src
add wave -noupdate sim:/uart_8n1_clock_gen_tb/subject/baud_rate
add wave -noupdate sim:/uart_8n1_clock_gen_tb/subject/clk_baud_16x
add wave -noupdate -divider boom
add wave -noupdate sim:/uart_8n1_clock_gen_tb/subject/reset
add wave -noupdate sim:/uart_8n1_clock_gen_tb/subject/next_threshold
add wave -noupdate sim:/uart_8n1_clock_gen_tb/subject/counter
add wave -noupdate sim:/uart_8n1_clock_gen_tb/subject/threshold
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {214000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 324
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
