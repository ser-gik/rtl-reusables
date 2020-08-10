onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider INPUTS
add wave -noupdate /tb/clk
add wave -noupdate /tb/reset_n
add wave -noupdate -divider OUTPUTS
add wave -noupdate /tb/hsync
add wave -noupdate /tb/vsync
add wave -noupdate /tb/pixel_visible
add wave -noupdate -expand /tb/pixel_x
add wave -noupdate -expand /tb/pixel_y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
configure wave -timelineunits ns
update
WaveRestoreZoom {9848100 ps} {11161300 ps}
