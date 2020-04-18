onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider IN
add wave -noupdate /tb/subject/recv_read
add wave -noupdate /tb/subject/rx
add wave -noupdate /tb/subject/clk_baud_16x
add wave -noupdate /tb/subject/reset
add wave -noupdate -divider OUT
add wave -noupdate /tb/subject/recv_data
add wave -noupdate /tb/subject/recv_busy
add wave -noupdate /tb/subject/recv_error
add wave -noupdate -divider INTERNAL
add wave -noupdate /tb/subject/rx_sync
add wave -noupdate /tb/subject/state
add wave -noupdate /tb/subject/is_start_bit
add wave -noupdate /tb/subject/is_stop_bit
add wave -noupdate /tb/subject/is_data_bit
add wave -noupdate /tb/subject/sample
add wave -noupdate /tb/subject/sampling_error
add wave -noupdate /tb/subject/is_sampled
add wave -noupdate /tb/subject/framing_error
add wave -noupdate /tb/subject/error
add wave -noupdate /tb/subject/cycle_finish
add wave -noupdate /tb/subject/accumulator
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3597300 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 298
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
WaveRestoreZoom {0 ps} {3777900 ps}
