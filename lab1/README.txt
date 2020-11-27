######################################### README ########################################################

For both main folder (iir,iir_LA):
	-Testing: C code used to implement the filter structure.
	-src: the VHDL file.
	-tb: the VHDL file used to test the device.
	-sim: the folder where modelsim is executed and contains the results of the filter and scripts.
	-saif/vcd: scripts used to perform the backward annotation.
	-netlist: files used for place and route.
	-syn: the files obtained by sinopsys and scripts.
	-report_clock_*: report_area, report_timing, report_power of the structure taking in account.
	-PowerReport: in this folder there are the power report obtained by innovous.
	
The tree folder organization is the following:
.
├── iir
│   ├── innovus
|   | 	├── PowerReport
│   │   ├── netlist
│   │   ├── saif
│   │   ├── sim
│   │   ├── src
│   │   ├── syn
│   │   │   └── report_clock_14.52
│   │   ├── tb
│   │   └── vcd
│   ├── netlist
│   ├── saif
│   ├── sim
│   ├── src
│   ├── syn
│   │   └── report_clock_14_52
│   ├── tb
│   ├── Testing
│   └── vcd
└── iir_LA
    ├── innovus
    | 	├── PowerReport
    │   ├── netlist
    │   ├── saif
    │   ├── sim
    │   ├── src
    │   ├── syn
    │   │   └── report_clock_9_3
    │   ├── tb
    │   └── vcd
    ├── netlist
    ├── saif
    ├── sim
    ├── src
    ├── syn
    │   ├── report_clock_2_28
    │   └── report_clock_9_2
    ├── tb
    ├── Testing
    └── vcd
