import sys
# name = sys.argv[1]

f = open(sys.argv[1], "r")
fmod = open(sys.argv[2], "w")

for line in f:
    if line.find("VCC") != -1:
        print("found")
    elif line.find("VSS") != -1:
        print("found")
    elif line[:7] == "sg13g2_":
        fmod.write(line[7:])
    else:
        fmod.write(line)
