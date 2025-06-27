v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
C {devices/code_shown.sym} -360 40 0 0 {name=CODE only_toplevel=false value="
.control
save all
tran 50p 380n
plot V(VFE) V(VRE)+2 V(VIN)+4
.endc

.measure tran tdelayfe
+ TRIG tran1.V(VFE) TD=0u VAL=0.6 RISE=1
+ TARG tran1.V(VFE) TD=0u VAL=0.6 FALL=1

.measure tran tdelayfe
+ TRIG tran1.V(VRE) TD=0u VAL=0.6 RISE=1
+ TARG tran1.V(VRE) TD=0u VAL=0.6 FALL=1
"}
C {devices/vsource.sym} -160 -110 0 0 {name=VCC value=1.2}
C {devices/vsource.sym} -240 -110 0 0 {name=VSS value=0}
C {devices/gnd.sym} -240 -80 0 0 {name=l1 lab=GND}
C {devices/gnd.sym} -160 -80 0 0 {name=l2 lab=GND}
C {devices/lab_pin.sym} -240 -240 0 0 {name=p1 sig_type=std_logic lab=VIN}
C {devices/lab_pin.sym} -240 -180 0 0 {name=p2 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -240 -140 0 0 {name=p3 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 60 -80 0 0 {name=p4 sig_type=std_logic lab=VIN}
C {devices/lab_pin.sym} 180 -20 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} -160 -140 0 0 {name=p6 sig_type=std_logic lab=VCC}
C {devices/lab_pin.sym} 180 -140 0 0 {name=p7 sig_type=std_logic lab=VCC}
C {devices/lab_pin.sym} 300 -100 2 0 {name=p8 sig_type=std_logic lab=VFE}
C {devices/lab_pin.sym} 300 -60 2 0 {name=p9 sig_type=std_logic lab=VRE}
C {SPG_vto1p1.sym} 180 -80 0 0 {name=x1}
C {devices/code_shown.sym} 80 40 0 0 {name=MODEL1 only_toplevel=true
format="tcleval( @value )"
value="

.param corner=0

.if (corner==0)
.lib $::SG13G2_MODELS/cornerMOSlv.lib mos_tt
.lib $::SG13G2_MODELS/cornerMOShv.lib mos_tt
.lib $::SG13G2_MODELS/cornerRES.lib res_typ
.lib $::SG13G2_MODELS/cornerCAP.lib cap_typ
.endif

.include /opt/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice
"}
C {devices/vsource.sym} -240 -210 0 0 {name=VIN1 value="PULSE(0 1.2 0n 1n 1n 100n 200n)"}
