`define DELAY_31 #31

`define DELAY_32 #32

`define BYPASS 4'b0000
`define IDCODE 4'b1000
`define ADDR   4'b0100
`define WDATA  4'b1100
`define RDATA  4'b0010

// testbench for JTAG
module jtag_test ();
  localparam REGISTER_SIZE = 4;
  localparam MUX_SIZE = 3;
  localparam  STATE_SIZE = 4;

  reg tck;
  reg tdi;
  wire tdo;
  reg tms;
  reg hresp;
  wire hwrite;
  wire [1:0] htrans;
  wire [31:0] hwdata;
  wire [31:0] haddr;

  // invert clock every 1 cycle
  always #1 tck <= ~tck;
  
  task test_logic_reset;
    begin
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1;
    end
   endtask
  
  task read_data_register;
    begin
      //run test idle
      tms = 1'b0; #1 #1
      //select DR scan
      tms = 1'b1; #1 #1
      //capture DR
      tms = 1'b0; #1 #1
      //shift DR
      tms = 1'b0; #1 #1
      //shift 31 remaining bits
      tms = 1'b0; `DELAY_31 `DELAY_31
      //go into exit1 DR
      tms = 1'b1; #1 #1
      //update DR
      tms = 1'b1; #1 #1
      //run test idle
      tms = 1'b0; #1 #1
      tms = 1'b0;
    end
  endtask
  
  task write_data_register;
    input [31:0] data;
    begin
       //run test idle
      tms = 1'b0; #1 #1
      //select DR scan
      tms = 1'b1; #1 #1
      //capture DR
      tms = 1'b0; #1 #1
      //shift DR
      //tdi = data[0];
      tms = 1'b0; 
      //shift 31 remaining bits
      for(integer count = 0; count<31; count++) begin
         tdi = data[count];
      		#1 #1
        tms = 1'b0;
      end
      tdi = data[31]; //TODO: Why is there off by one?
      //go into exit1 DR - still in shift DR
      tms = 1'b1; #1 #1
      //update DR
      tms = 1'b1; #1 #1
      //run test idle
      tms = 1'b0; #1 #1
      tms = 1'b0;
    end
  endtask
  
  task write_instruction_register;
  input [3:0] instruction;
  reg end_reg; // dummy register
  begin
    // Have to start from either test_logic_reset or run_test_idle
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = instruction[0]; #1 #1
    tdi = instruction[1]; #1 #1
    tdi = instruction[2]; #1 #1
    tdi = instruction[3];
    // move into latch IR
    tms = 1'b1; #1 #1
    // move into run_test_idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    // Fix Verilog delay bug
    end_reg = 1'b0;
  end
  endtask
  
  jtag
  #(.REGISTER_SIZE(32),
    .IR_SIZE(4),
    .STATE_SIZE(4)
   ) jtag_inst
  	(
      .TCK(tck),
      .TDI(tdi),
      .TDO(tdo),
      .TMS(tms),
      .HREADY(1'b1), //permanently ready to write
      .HRDATA(32'hF00F), //data to read from AHB-Lite bus
      .HWRITE(hwrite),
      .HRESP(hresp),
      .HTRANS(htrans),
      .HWDATA(hwdata),
      .HADDR(haddr)
    );

  initial begin
    // init vars
    tck = 1'b0; // clock
    tdi = 1'b0; // input
    tms = 1'b1; // TAP state machine control
    #1

    $display("Starting testbench");
	

    test_logic_reset();
   
//<-Test of IDCODE register->
    /*
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0;
    tms = 1'b0; #1 #1
    tdi = 1'b0;
    tms = 1'b0; #1 #1
    tdi = 1'b0;
    tms = 1'b0; #1 #1
    tdi = 1'b1;
    // move into latch IR
    tms = 1'b1; #1 #1
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1

*/

//<-Test of AHBL ADDRESS instruction->
    /*
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0; #1 #1
    tdi = 1'b0; #1 #1
    tdi = 1'b1; #1 #1
    tdi = 1'b0;
    // move into latch IR
    tms = 1'b1; #1 #1
    */
 /*   
    write_instruction_register(`ADDR);
    
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
*/
    write_instruction_register(`IDCODE);
    write_data_register(32'h89abcdef);
    read_data_register();
//<-Test of AHBL WRITE instruction->
    /*
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0; #1 #1
    tdi = 1'b0; #1 #1
    tdi = 1'b1; #1 #1
    tdi = 1'b1;
    // move into latch IR
    tms = 1'b1; #1 #1
    */
   /* 
    write_instruction_register(`WDATA);
    
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
*/

/*
//<-Test of AHB READ instruction->
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0; #1 #1
    tdi = 1'b1; #1 #1
    tdi = 1'b0; #1 #1
    tdi = 1'b0;
    // move into latch IR
    tms = 1'b1; #1 #1
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1; #1 #1
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1


    //<-Change IR and set val to read->
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move into shift DR
    tms = 1'b0; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
