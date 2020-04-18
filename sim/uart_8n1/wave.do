onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider IN
add wave -noupdate /tb/subject/rx
add wave -noupdate /tb/subject/tx_data
add wave -noupdate /tb/subject/tx_write
add wave -noupdate /tb/subject/rx_read
add wave -noupdate /tb/subject/baud_rate
add wave -noupdate /tb/subject/clk
add wave -noupdate /tb/subject/reset
add wave -noupdate -divider OUT
add wave -noupdate /tb/subject/tx
add wave -noupdate /tb/subject/tx_full
add wave -noupdate /tb/subject/tx_empty
add wave -noupdate /tb/subject/rx_data
add wave -noupdate /tb/subject/rx_full
add wave -noupdate /tb/subject/rx_empty
add wave -noupdate /tb/subject/rx_error
add wave -noupdate -divider INTERNAL
add wave -noupdate /tb/subject/clk_baud_16x
add wave -noupdate /tb/subject/reset_sticky
add wave -noupdate /tb/subject/prev_clk_baud_16x
add wave -noupdate /tb/subject/transmitter_busy
add wave -noupdate /tb/subject/prev_transmitter_busy
add wave -noupdate /tb/subject/has_outgoing
add wave -noupdate /tb/subject/outgoing
add wave -noupdate /tb/subject/receiver_busy
add wave -noupdate /tb/subject/prev_receiver_busy
add wave -noupdate /tb/subject/has_incoming
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 270
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
WaveRestoreZoom {0 ps} {900 ps}
