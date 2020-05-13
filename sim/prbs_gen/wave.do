onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/subject/seed
add wave -noupdate /tb/subject/out
add wave -noupdate /tb/subject/clk
add wave -noupdate /tb/subject/reset_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 195
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
WaveRestoreZoom {8596 ns} {10548 ns}
