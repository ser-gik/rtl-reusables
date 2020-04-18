vsim work.uart_8n1_transmitter_tb work.uart_8n1_receiver_tb
add wave -position insertpoint sim:/uart_8n1_transmitter_tb/subject/*
add wave -position insertpoint sim:/uart_8n1_receiver_tb/subject/*
run