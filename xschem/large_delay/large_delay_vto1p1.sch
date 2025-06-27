v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -140 -10 -80 -10 {
lab=VIN,n2,n3,n4,n5}
N 0 -10 100 -10 {
lab=n2,n3,n4,n5,VOUT}
C {devices/lab_pin.sym} -140 -10 0 0 {name=p6 sig_type=std_logic lab=VIN,n2,n3,n4,n5}
C {devices/lab_pin.sym} 100 -10 0 1 {name=p7 sig_type=std_logic lab=n2,n3,n4,n5,VOUT}
C {devices/iopin.sym} 0 -150 2 0 {name=p4 lab=VIN}
C {devices/iopin.sym} 0 -110 2 0 {name=p5 lab=VOUT}
C {devices/iopin.sym} -130 -160 2 0 {name=p1 lab=VCC}
C {devices/iopin.sym} -130 -120 2 0 {name=p2 lab=VSS}
C {sg13g2_stdcells/sg13g2_dlygate4sd3_1.sym} -40 -10 0 0 {name=x1[0:4] VDD=VCC VSS=VSS prefix=sg13g2_ }
