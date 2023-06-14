onerror {resume}
radix define  {
    -default default
}
radix define states {
    "5'b00000" "READY",
    "5'b00100" "GETSI" -color "yellow",
    "5'b01000" "COMPJ" -color "cyan",
    "5'b11000" "GETSJ" -color "yellow",
    "5'b10110" "S[J]=S[I]" -color "orange",
    "5'b01110" "S[I]=S[J]" -color "orange",
    "5'b10001" "DONE" -color "green",
    -default default
}
radix define 
    -default default
 {
    -default default
}
quietly virtual function -install /tb_shuffle_arr/DUT -env /tb_shuffle_arr/#INITIAL#49 { &{/tb_shuffle_arr/DUT/state[4], /tb_shuffle_arr/DUT/state[3], /tb_shuffle_arr/DUT/state[2], /tb_shuffle_arr/DUT/state[1], /tb_shuffle_arr/DUT/state[0] }} State
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_shuffle_arr/clk
add wave -noupdate /tb_shuffle_arr/rst
add wave -noupdate /tb_shuffle_arr/start
add wave -noupdate /tb_shuffle_arr/finish
add wave -noupdate -radix unsigned /tb_shuffle_arr/address
add wave -noupdate -radix hexadecimal -radixshowbase 1 /tb_shuffle_arr/data
add wave -noupdate /tb_shuffle_arr/wren
add wave -noupdate -radix hexadecimal -radixshowbase 1 /tb_shuffle_arr/q
add wave -noupdate -radix hexadecimal -radixshowbase 1 /tb_shuffle_arr/secret
add wave -noupdate -radix unsigned /tb_shuffle_arr/DUT/i
add wave -noupdate -radix unsigned /tb_shuffle_arr/DUT/j
add wave -noupdate -radix hexadecimal -radixshowbase 1 /tb_shuffle_arr/DUT/si
add wave -noupdate -radix states /tb_shuffle_arr/DUT/State
add wave -noupdate -radix hexadecimal /tb_shuffle_arr/memory
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25560 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 179
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
WaveRestoreZoom {25330 ns} {25690 ns}
