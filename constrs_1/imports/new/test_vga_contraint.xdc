## This file is a general .xdc for the ARTY Z7-10 Rev.B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal

set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=SYSCLK

##Buttons

#set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports { red_i }]; #IO_L4P_T0_35 Sch=BTN0
#set_property -dict { PACKAGE_PIN D20    IOSTANDARD LVCMOS33 } [get_ports { grn_i }]; #IO_L4N_T0_35 Sch=BTN1
set_property -dict { PACKAGE_PIN L20    IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L9N_T1_DQS_AD3N_35 Sch=BTN2

set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { rgb[0] }]; #IO_L17P_T2_34 Sch=JA1_P
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { rgb[1] }]; #IO_L17N_T2_34 Sch=JA1_N
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { rgb[2] }]; #IO_L7P_T1_34 Sch=JA2_P
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { rgb[0] }]; #IO_L7N_T1_34 Sch=JA2_N

##Pmod Header JB

#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { jb_n[1] }]; #IO_L8N_T1_34 Sch=JB1_N
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { jb_p[1] }]; #IO_L8P_T1_34 Sch=JB1_P
#set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { jb_n[2] }]; #IO_L1N_T0_34 Sch=JB2_N
#set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { jb_p[2] }]; #IO_L1P_T0_34 Sch=JB2_P
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { vsync }]; #IO_L18N_T2_34 Sch=JB3_N
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { hsync }]; #IO_L18P_T2_34 Sch=JB3_P