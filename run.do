##To compile file
vsim -voptargs=+acc -L design testbench.tb_apb_wrapper -logfile run.log


##run the file till 10ms
run        10000 ns

##coverage report file generation 
##coverage report -html -htmldir covhtmlreport -source -details -assert -directive -cvg -code bcefst -threshL 50 -threshH 90

##exit(stop) the simulation
exit
