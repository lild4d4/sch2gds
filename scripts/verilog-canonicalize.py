import sys
# name = sys.argv[1]

verilog_file = open(sys.argv[1], "r")
verilog_file_output = open(sys.argv[2], "w")
power_pin = sys.argv[3]
ground_pin = sys.argv[4]


for line in verilog_file:
    if line.find(power_pin) != -1:
    	continue
    elif line.find(ground_pin) != -1:
    	continue
    else:
        verilog_file_output.write(line)
