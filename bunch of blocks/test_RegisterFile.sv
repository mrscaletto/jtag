module test_RegisterFile();
    
  reg CLK, RST;
  always #1 CLK = ~CLK;
  
  reg W_EN;
  reg [0:63] W_DATA;
  reg [0:4] W_ADDR, R_ADDR1, R_ADDR2;
  reg [0:63] R_DATA1, R_DATA2;
  reg [0:7] W_MASK;
  
  integer i, j;
    
  RegisterFile  REG1 (.clk(CLK),
                        .srst(RST),
                        .reg_write(W_EN),
                        .w_addr(W_ADDR),
                        .w_data(W_DATA),
                        .r_addr1(R_ADDR1),
                        //.r_addr2(R_ADDR2),
                        .r_data1(R_DATA1),
                        //.r_data2(R_DATA2));
    
  initial begin
    check_REGISTER;
  end
  
  /*
    initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  */


  	task check_REGISTER(); begin
        RST = 1'b1;
        CLK = 1'b0;
        W_EN = 1'b0;
        W_ADDR = 5'b0;
        R_ADDR1 = 5'bxxxxx;
        //R_ADDR2 = 5'bxxxxx;
        W_DATA = 64'h0;
      	W_MASK = 8'hFF;
        

        #32


        #4 RST = 1'b0;
        
        #2 W_EN = 1'b1; W_ADDR = 5'h0; W_DATA = 8'hFF;
      for (i = 1; i < 8; i=i+1) begin
            #2 W_ADDR = i; W_DATA = i+15;
        end
        
        #2 W_EN = 1'b0; W_ADDR = 0; W_DATA = 0;
        
        #2
        
        #32


      j=8;
      for (i = 0; i < 8; i=i+1) begin
        j=j-1;
        #2 R_ADDR1 = i; R_ADDR2 = j;
        end        
        #2 W_EN = 1'b1; W_ADDR = 5; W_DATA = 25; R_ADDR1 = 5; R_ADDR2 = 5;        
        #2 W_EN = 1'b0; W_ADDR = 0; W_DATA = 0; R_ADDR1 = 4; R_ADDR2 = 4;        
        #2 R_ADDR1 = 5; R_ADDR2 = 5;      
        #20 $stop;
        end
    endtask
  
endmodule