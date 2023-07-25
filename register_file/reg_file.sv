module RegisterFile ( 
                     input clk, srst, reg_write,
                     input [7:0] w_data,
                     input [2:0] r_addr1, r_addr2, w_addr,
                     output [7:0] r_data1, r_data2);
    
  
  reg [7:0] register [0:7];
  
  integer i;
    
  always @ (posedge clk) begin
    if (srst) begin
      // Initialize all registers to value 0
      for(i = 0; i < 8; i=i+1) begin
        register[i] <= 'h0;
      end
    end
    // Write to registers only on condition reg_write
    // On reg_write, write the data to the register address provided on w_addr
    else if (reg_write)
      register[w_addr] <= w_data;
  end
  
  // Read data available on 2 read ports based on 2 seperate read addresses
  assign r_data1 = register[r_addr1];
  assign r_data2 = register[r_addr2];
    
endmodule
