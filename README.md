# jtag
JTAG - is an industry standard for verifying designs and testing printed circuit boards after manufacture.

![TAP State Machine](https://github.com/mrscaletto/jtag/blob/main/jtag-part-ii-the-test-access-port-state-machine-.png)

Main blocks: jtagtap.sv and ram_module

Module jtag 
Inputs:                 Outputs:
  input TCK,              output reg HWRITE,
	input TDI,              output reg [1:0] HTRANS,
	input TMS,              output reg [31:0] HWDATA,
	input HREADY,           output reg [31:0] HADDR
  input HRESP,            output reg TDO
  input [31:0] HRDATA,   
  	
  	
  	
