`timescale 1ns / 1ps


module single_port_ram(

    input clk,
    input [31:0] HADDR,
    input  HWRITE, //write_enable
    input  [31:0] HWDATA,
    //input data_in;
    input  [31:0] HRDATA,
  	
  	output reg HREADY = 1
    //reg
    //output [31:0]data_out
    );

reg [31:0] ram_memory[31:0]; // a 32 byte ( 32*8 bit)  RAM  



always@(posedge clk)
    
    begin
        if (HWRITE)
        ram_memory[HADDR] <= HWDATA;
    end 
        
        

assign data_out = ram_memory[HADDR];



endmodule


