onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/subject/clk
add wave -noupdate /tb/subject/reset_n
add wave -noupdate -radix decimal -radixshowbase 0 /tb/subject/in
add wave -noupdate /tb/subject/out
add wave -noupdate /tb/subject/state
add wave -noupdate /tb/subject/ready
add wave -noupdate /tb/subject/restart
add wave -noupdate /tb/subject/src_reg
add wave -noupdate /tb/subject/dst_reg
add wave -noupdate /tb/subject/next_dst_reg
add wave -noupdate /tb/subject/out_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 279
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
WaveRestoreZoom {0 ns} {238 ns}
