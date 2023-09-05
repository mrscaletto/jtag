module RegisterFile ( 
                     input clk, srst, reg_write,
                     input [7:0] w_data,
                     input [2:0] r_addr1, w_addr,
                     //input [2:0] r_addr1, r_addr2, w_addr,
                     
                     output [7:0] r_data1 );
                     //output [7:0] r_data1, r_data2
                     
  
  reg [7:0] register [0:31];
  
  integer i;
  integer j;  

  always @ (posedge clk) begin
    if (srst) begin

      
      for(i = 0; i < 31; i=i+1) begin
        register[i] <= 'h0;
      end
    end
    
    else if (reg_write)
      register[w_addr] <= w_data;
  end
  

  assign r_data1 = register[r_addr1];
  
  //assign r_data2 = register[r_addr2];
    
endmodule
