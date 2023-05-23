# jtag
JTAG - is an industry standard for verifying designs and testing printed circuit boards after manufacture.

![TAP State Machine](https://github.com/mrscaletto/jtag/blob/main/jtag-part-ii-the-test-access-port-state-machine-.png)

Main blocks: jtagtap.sv and ram_module

Module jtag 

Inputs: input TCK, input TDI, input TMS, input HREADY, input HRESP, input [31:0] HRDATA;              
Outputs: output reg HWRITE, output reg [1:0] HTRANS, output reg [31:0] HWDATA, output reg [31:0] HADDR, output reg TDO;
  	
  	
