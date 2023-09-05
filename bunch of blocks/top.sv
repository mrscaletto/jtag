`timescale 1ns / 1ps

module top(
    
	
	// JTAG-related IO
	logic TCK, // Test Clock Input 
	logic TDI, // Test Data Input 
	logic  TDO, // Test Data Output 
	logic TMS, // Test Mode Select 
  	
  	// AHB-related IO
  	logic HREADY,
  	
logic [31:0] HRDATA,
  	logic  HWRITE,
  	logic  [31:0] HWDATA,
  	logic  [31:0] HADDR    
    );
    
jtag d0(
.TCK(CLK),
.TDI(TDI),
.TDO(TDO),
.TMS(TMS),
.HREADY(HREADY),
.HRDATA(HRDATA),
.HWRITE(HWRITE),
.HWDATA(HWDATA),
.HADDR(HADDR)
);    

single_port_ram d1(
.HREADY(HREADY),
.HRDATA(HRDATA),
.HWRITE(HWRITE),
.HWDATA(HWDATA),
.HADDR(HADDR)  
 );   
    
    
    
    
    
endmodule