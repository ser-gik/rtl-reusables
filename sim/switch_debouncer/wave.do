onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/subject/clk
add wave -noupdate /tb/subject/reset_n
add wave -noupdate -expand /tb/subject/in
add wave -noupdate /tb/subject/sample_clk
add wave -noupdate {/tb/subject/debounce_bit[0]/sync_reg}
add wave -noupdate {/tb/subject/debounce_bit[0]/samples}
add wave -noupdate {/tb/subject/debounce_bit[0]/stable_samples}
add wave -noupdate {/tb/subject/debounce_bit[0]/out_reg}
add wave -noupdate {/tb/subject/debounce_bit[1]/sync_reg}
add wave -noupdate {/tb/subject/debounce_bit[1]/samples}
add wave -noupdate {/tb/subject/debounce_bit[1]/stable_samples}
add wave -noupdate {/tb/subject/debounce_bit[1]/out_reg}
add wave -noupdate {/tb/subject/debounce_bit[2]/sync_reg}
add wave -noupdate {/tb/subject/debounce_bit[2]/samples}
add wave -noupdate {/tb/subject/debounce_bit[2]/stable_samples}
add wave -noupdate {/tb/subject/debounce_bit[2]/out_reg}
add wave -noupdate -expand /tb/subject/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 258
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
WaveRestoreZoom {0 ns} {102 ns}
