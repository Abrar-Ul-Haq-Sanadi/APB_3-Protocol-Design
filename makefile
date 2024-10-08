clean:
	rmdir /s /q design
	rmdir /s /q testbench

compile:
	vlog -work design -vopt -sv  -stats=none apb_master.sv
	vlog -work design -vopt -sv  -stats=none CSR.sv
	vlog -work design -vopt -sv  -stats=none apb_wrapper.sv
	vlog -work testbench -vopt -sv  +cover=sbceft1 -stats=none tb_apb_wrapper.sv

simulate:
	vsim -c -do run.do -logfile run.log 

waveform:
	gtkwave wave.vcd

all:
	make clean
	make compile
	make simulate
	make waveform

 
