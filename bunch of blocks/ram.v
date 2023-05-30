`timescale 1ns / 1ps


module single_port_ram(ram_address,HWRITE,clk,data_out);

    input clk;
    input [31:0] ram_address;
    input  HWRITE; //write_enable
    input  [31:0] HWDATA,
    //input data_in;
    input HREADY;
    input  [31:0] HRDATA,
  	input  [31:0] HADDR
    
    //output [31:0]data_out;

reg [7:0] ram_memory[31:0]; // a 32 byte ( 32*8 bit)  RAM  
reg [5:0] address_register;


always@(posedge clk)
    begin
        if (HWRITE)
        ram_memory[ram_address] <= HWDATA
    else
   HADDR <= ram_address;
        
        
always @(posedge clk)
    begin
        if (write_enable)  // write operation
        ram_memory[ram_address] <= data_in;
    else 
  address_register <= ram_address;
    end

assign data_out = ram_memory[address_register];

endmodule

