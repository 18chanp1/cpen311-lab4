onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mem_init/clk
add wave -noupdate -radix hexadecimal /tb_mem_init/address
add wave -noupdate -radix hexadecimal /tb_mem_init/data
add wave -noupdate /tb_mem_init/wren
add wave -noupdate /tb_mem_init/rst
add wave -noupdate /tb_mem_init/start
add wave -noupdate /tb_mem_init/finish
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5250 ns} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {4280 ns} {5280 ns}
