//-------------------------------------------------------------------------
// Copyright (c) 1997-2009 Cadence Design Systems, Inc.  All rights reserved.
// This work may not be copied, modified, re-published, uploaded, executed,
// or distributed in any way, in any medium, whether in whole or in part,
// without prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------

//------------------------------------------------------------------------
//  Abstract   : Simulation Architecture for CW_tap_uc
//  RC Release : 20.10-p001_1
//------------------------------------------------------------------------

//-----------------------------------------------------------------------
//  Module         : CW_tap_uc
//  Abstract       : TAP Controller with Usercode support 
//
//  Pin Name        Width    	   Direction  Function
//----------------------------------------------------------------------
//  tck             1 bit    	   Input      Test clock
//  trst_n          1 bit    	   Input      Test reset, active low
//  tms             1 bit    	   Input      Test mode select
//  tdi             1 bit    	   Input      Test data in
//  so              1 bit    	   Input      Serial data from boundary scan
//                           	              registers and data registers
//  bypass_sel      1 bit    	   Input      Selects bypass register,active
//                                            high
//  sentinel_val    width bit-1(s) Input      User defined status bits
//  device_id_sel   1 bit          Input      Selects the device identification 
//                                            register, active high
//  user_code_sel   1 bit          Input      Selects the user_code_val bus for
//                                            input in to the device identification
//                                            register, active high
//  user_code_val   32 bits        Input      32-bit user defined code.
//  ver             4 bits         Input      4 bit version number
//  ver_sel         1 bit          Input      Selects version from the parameter
//                                            or the ver input port 
//                                            0 = version (parameter) 
//                                            1 = ver (input port)
//  part_num        16 bits        Input      16 bit part number
//  part_num_sel    1 bit          Input      Selects part from the parameter
//                                            or the part_num from the input port 
//                                            0 = part (parameter) 
//                                            1 = part_num (input port)
//  mnfr_id         11 bits        Input      11 bit JEDEC manufacturer's 
//                                            identity code (mnfr_id != 127)
//  mnfr_id_sel     1 bit          Input      Selects man_num from the parameter 
//                                            or mnfr_id from the input port 
//                                            0 = man_num (parameter) 
//                                            1 = mnfr_id (input port)
//  clock_dr        1 bit          Output     Clock's in data in asynchronous
//                                            mode
//  shift_dr        1 bit          Output     Enables shifting of data in both
//                                            synchronous and asynchronous mode
//  update_dr       1 bit          Output     Enables updating data in asynchronous mode
//  tdo             1 bit          Output     Test data out
//  tdo_en          1 bit          Output     Enables for tdo output buffer
//  tap_state       16 bits        Output     Current state of the TAP finite
//                                            state machine
//  instructions    width bit(s)   Output     Instruction register output
//  sync_capture_en 1 bit          Output     Enable for synchronous capture    
//  sync_update_dr  1 bit          Output     Enable updating new data in
//                                            synchronous mode 
//-----------------------------------------------------------------------
//
//  Parameter       Values             Description
//-----------------------------------------------------------------------
//  width           2 to 32            Width of instruction register
//                  Default: 2
//  id              0 or 1             Determines whether the device 
//                  Default: 0         identification register is present 
//                                     0 = not present,
//                                     1 = present
//  idcode_opcode   1 to 2^(width-1)   Opcode for IDCODE.
//                  Default: 1
//  version         0 to 15            4-bit version number
//                  Default: 0
//  part            0 to 65535         16-bit part number
//                  Default: 0
//  man_num         0 to 2047          11-bit JEDEC manufacturer identity code
//                  man_num !=127 
//                  Default: 0 
//  sync_mode       0 or 1             Determines whether the bypass, device 
//                  Default: 0         identification, and instruction registers 
//                                     are synchronous with respect to tck 
//                                     0 = asynchronous, 
//                                     1 = synchronous
//----------------------------------------------------------------------- 

module CW_tap_uc ( 
		tck, 
		trst_n, 
		tms, 
		tdi, 
		so, 
		bypass_sel, 
		sentinel_val,
		device_id_sel,
		user_code_sel,
		user_code_val,
		ver,
		ver_sel,
		part_num,
		part_num_sel,
		mnfr_id,
		mnfr_id_sel,
		clock_dr, 
		shift_dr,
		update_dr,
		tdo,
		tdo_en,
		tap_state,
		instructions, 
		sync_capture_en, 
		sync_update_dr           );
   
//----------------------------------------------------------------------
// parameters declaration
//----------------------------------------------------------------------
   parameter width = 2;
   parameter id = 0;
   parameter idcode_opcode =1;
   parameter version = 0;
   parameter part = 0;
   parameter man_num = 0;
   parameter sync_mode = 0;

   parameter RESET      = 0;
   parameter IDLE       = 1;
   parameter SEL_DR_SC  = 2;
   parameter CAPTURE_DR = 3;
   parameter SHIFT_DR   = 4;
   parameter EXIT1_DR   = 5;
   parameter PAUSE_DR   = 6;
   parameter EXIT2_DR   = 7;
   parameter UPDATE_DR  = 8;
   parameter SEL_IR_SC  = 9;
   parameter CAPTURE_IR = 10;
   parameter SHIFT_IR   = 11;
   parameter EXIT1_IR   = 12;
   parameter PAUSE_IR   = 13;
   parameter EXIT2_IR   = 14;
   parameter UPDATE_IR  = 15;

   parameter RESET_STATE      = 16'b0000000000000001;
   parameter IDLE_STATE       = 16'b0000000000000010;
   parameter SEL_DR_SC_STATE  = 16'b0000000000000100;
   parameter CAPTURE_DR_STATE = 16'b0000000000001000;
   parameter SHIFT_DR_STATE   = 16'b0000000000010000;
   parameter EXIT1_DR_STATE   = 16'b0000000000100000;
   parameter PAUSE_DR_STATE   = 16'b0000000001000000;
   parameter EXIT2_DR_STATE   = 16'b0000000010000000;
   parameter UPDATE_DR_STATE  = 16'b0000000100000000;
   parameter SEL_IR_SC_STATE  = 16'b0000001000000000;
   parameter CAPTURE_IR_STATE = 16'b0000010000000000;
   parameter SHIFT_IR_STATE   = 16'b0000100000000000;
   parameter EXIT1_IR_STATE   = 16'b0001000000000000;
   parameter PAUSE_IR_STATE   = 16'b0010000000000000;
   parameter EXIT2_IR_STATE   = 16'b0100000000000000;
   parameter UPDATE_IR_STATE  = 16'b1000000000000000; 

//----------------------------------------------------------------------
// input declaration
//----------------------------------------------------------------------
   input 		 tck;
   input 		 trst_n;
   input 		 tms;
   input 		 tdi;
   input 		 so;
   input 		 bypass_sel;
   input [(width - 2):0] sentinel_val;
   input 		  ver_sel;
   input 		  device_id_sel;
   input 		  user_code_sel;
   input [31:0] 	  user_code_val;
   input [3:0] 		  ver;
   input [15:0] 	  part_num;
   input 		  part_num_sel;
   input [10:0] 	  mnfr_id;
   input 		  mnfr_id_sel;
   
//----------------------------------------------------------------------
// output declaration
//----------------------------------------------------------------------
   output 		  clock_dr;
   output 		  shift_dr;
   output 		  update_dr;
   output 		  tdo;
   output 		  tdo_en;
   output [15:0] 	  tap_state;
   output [(width - 1):0] instructions;
   output 		  sync_capture_en;
   output 		  sync_update_dr;
 
//----------------------------------------------------------------------
// wire declaration
//----------------------------------------------------------------------
   wire [15:0] 		  tap_state;      
   wire 		  tck_n;
   wire 		  update_dr;
   wire 		  update_ir;
   wire 		  sync_capture_en;
   wire 		  sync_capture_ir;
   wire 		  sync_update_dr;
   wire 		  tdo_en;
   wire 		  capture_dr_clk;
   wire 		  capture_dr_en;
   wire 		  capture_ir_clk;   
   wire 		  capture_ir_en;
   wire 		  update_ir_clk;
   wire 		  update_ir_en;
   wire 		  clock_dr;   
   wire 		  clock_ir;
   wire 		  instr_rst;   
   wire 		  capture_dr;
   wire 		  data_in;
   wire [31:0] 		  id_code;
   wire 		  id_select;
   wire 		  bypass_int;
   wire [10:0] 		  temp_man_num_val;
   wire [15:0] 		  temp_part_val;
   wire [3:0] 		  temp_version_val;
   
//----------------------------------------------------------------------
// reg declaration
//----------------------------------------------------------------------
   reg [15:0] 		  curr_state;
   reg [15:0] 		  next_state;
   reg 			  shift_dr;
   reg 			  shift_ir;
   reg 			  reset;
   reg [31:0] 		  capture_dr_reg;
   reg [(width-1):0] 	  capture_ir_reg;
   reg [(width-1):0] 	  update_ir_reg;
   reg [(width-1):0] 	  data_in_ir;
   reg 			  bypass_so;
   reg 			  update_ir_reg_tmp_n;
   reg 			  update_ir_reg_tmp;
   reg 			  update_ir_reg_tmp_by;
   reg 			  tdo;
   reg 			  tdo_temp;
   
   assign 		  tck_n = ~tck; 
   
//--------------------------------------------------------------------
// Sequential part of the State Machine
//--------------------------------------------------------------------
   always @ (posedge tck or negedge trst_n)
     begin
	if(~trst_n)
	  curr_state <= RESET_STATE;
	else
	  curr_state <= next_state;
     end

//--------------------------------------------------------------------
// Combinatorial part of the State Machine
//--------------------------------------------------------------------
   always @ (curr_state or tms)
     begin

	case (curr_state)

	  RESET_STATE: // 0
	    begin
	       if(tms)
		 next_state = RESET_STATE; // 0
	       else 
		 next_state = IDLE_STATE; // 1
	    end
	  
	  IDLE_STATE: // 1
	    begin
	       if(tms)
		 next_state = SEL_DR_SC_STATE; // 2
	       else
		 next_state = IDLE_STATE; // 1
	    end
	  
	  SEL_DR_SC_STATE: // 2
	    begin
	       if(tms)
		 next_state = SEL_IR_SC_STATE; // 9
	       else
		 next_state = CAPTURE_DR_STATE; // 3
	    end
	  
	  CAPTURE_DR_STATE: // 3
	    begin
	       if(tms)
		 next_state = EXIT1_DR_STATE; // 5
	       else
		 next_state = SHIFT_DR_STATE; // 4
	    end

	  SHIFT_DR_STATE: // 4
	    begin
	       if(tms)
		 next_state = EXIT1_DR_STATE; // 5
	       else
		 next_state = SHIFT_DR_STATE; // 4
	    end

	  EXIT1_DR_STATE: // 5
	    begin
	       if(tms)
		 next_state = UPDATE_DR_STATE; // 8
	       else
		 next_state = PAUSE_DR_STATE; // 6
	    end
	  
	  PAUSE_DR_STATE: // 6
	    begin
	       if(tms)
		 next_state = EXIT2_DR_STATE; // 7
	       else
		 next_state = PAUSE_DR_STATE; // 6
	    end
	  
	  EXIT2_DR_STATE: // 7
	    begin
	       if(tms)
		 next_state = UPDATE_DR_STATE; // 8
	       else
		 next_state = SHIFT_DR_STATE; // 4
	    end
	  
	  UPDATE_DR_STATE: // 8
	    begin
	       if(tms)
		 next_state = SEL_DR_SC_STATE; // 2
	       else
		 next_state = IDLE_STATE; // 1
	    end
	  
	  SEL_IR_SC_STATE: // 9
	    begin
	       if(tms)
		 next_state = RESET_STATE; // 0
	       else
		 next_state = CAPTURE_IR_STATE; // 10
	    end
	  
	  CAPTURE_IR_STATE: // 10
	    begin
	       if(tms)
		 next_state = EXIT1_IR_STATE; // 12
	       else
		 next_state = SHIFT_IR_STATE; // 11
	    end

	  SHIFT_IR_STATE: // 11
	    begin
	       if(tms)
		 next_state = EXIT1_IR_STATE; // 12
	       else
		 next_state = SHIFT_IR_STATE; // 11
	    end

	  EXIT1_IR_STATE: // 12
	    begin
	       if(tms)
		 next_state = UPDATE_IR_STATE; // 15
	       else
		 next_state = PAUSE_IR_STATE; // 13
	    end
	  
	  PAUSE_IR_STATE: // 13
	    begin
	       if(tms)
		 next_state = EXIT2_IR_STATE; // 14
	       else
		 next_state = PAUSE_IR_STATE; // 13
	    end
	  
	  EXIT2_IR_STATE: // 14
	    begin
	       if(tms)
		 next_state = UPDATE_IR_STATE; // 15
	       else
		 next_state = SHIFT_IR_STATE; // 11
	    end
	  
	  UPDATE_IR_STATE: // 15
	    begin
	       if(tms)
		 next_state = SEL_DR_SC_STATE; // 2
	       else
		 next_state = IDLE_STATE; // 1
	    end

	  default:next_state = 16'd0;
	  
	  
	endcase // case1'b1
	
     end // always @ (curr_state or tms)
//--------------------------------------------------------------------
   
   always @ (posedge tck_n or negedge trst_n)
     begin
	if(~trst_n)
	  begin
	     shift_dr <= 1'b0;
	     shift_ir <= 1'b0;
	  end
	else
	  begin
	     shift_dr <= curr_state[SHIFT_DR];
	     shift_ir <= curr_state[SHIFT_IR];
	  end
     end // always @ (posedge tck_n or negedge trst_n)

   always @ (posedge tck_n)
     begin
	reset    <= curr_state[RESET];
     end
   
   
   assign tap_state       = curr_state;
   assign tdo_en          = shift_dr | shift_ir;
   assign clock_dr = tck | ~(tck | curr_state[CAPTURE_DR] | curr_state[SHIFT_DR]) |
			      ~(curr_state[CAPTURE_DR] | curr_state[SHIFT_DR]);
   assign clock_ir = tck | ~(tck | curr_state[CAPTURE_IR] | curr_state[SHIFT_IR]) |
			      ~(curr_state[CAPTURE_IR] | curr_state[SHIFT_IR]);
   assign instr_rst       = ~(reset | ~trst_n);
   assign update_dr       = tck_n & curr_state[UPDATE_DR];
   assign update_ir       = tck_n & curr_state[UPDATE_IR];
   assign sync_capture_en = ~(shift_dr | curr_state[CAPTURE_DR] | curr_state[SHIFT_DR]);
   assign sync_capture_ir = ~(shift_ir | curr_state[CAPTURE_IR] | curr_state[SHIFT_IR]);
   assign sync_update_dr  = curr_state[UPDATE_DR];
   assign capture_dr      = curr_state[CAPTURE_DR];
     
//--------------------------------------------------------------------
// capture_dr_reg generation
//--------------------------------------------------------------------
   assign capture_dr_clk = sync_mode ? tck        : clock_dr;
   assign capture_dr_en  = sync_mode ? ( curr_state[CAPTURE_DR] | 
					 curr_state[SHIFT_DR])   : 1'b1;

   assign temp_version_val = ver_sel == 1'b0 ? version[3:0] : ver;
   assign temp_part_val    = part_num_sel == 1'b0 ? part[15:0] : part_num;
   assign temp_man_num_val = mnfr_id_sel == 1'b0 ? man_num[10:0] : mnfr_id;

   assign id_code[0]       = user_code_sel == 1'b0 ? 1'b1 : user_code_val[0];
   assign id_code[11:1]    = user_code_sel == 1'b0 ? temp_man_num_val :
                             user_code_val[11:1];
   assign id_code[27:12]   = user_code_sel == 1'b0 ? temp_part_val : user_code_val[27:12];
   assign id_code[31:28]   = user_code_sel == 1'b0 ? temp_version_val : user_code_val[31:28];
   
   always @ (posedge capture_dr_clk)
     begin
	if(capture_dr_en)
	  begin
	     if(~shift_dr)
	       capture_dr_reg <= id_code;
	     else
	       capture_dr_reg <= {tdi,capture_dr_reg[31:1]};
	  end
     end

//--------------------------------------------------------------------
// capture_ir_reg generation
//--------------------------------------------------------------------
   assign capture_ir_clk = sync_mode ? tck             : clock_ir;   
   assign capture_ir_en  = sync_mode ? sync_capture_ir : 1'b0 ;
   
   always @ (sentinel_val)
     begin
	if(width > 2)
	  begin
	     data_in_ir = {(sentinel_val << 1),1'b1};
	  end
	data_in_ir[1:0] = 2'b01;
     end
         
   always @ (posedge capture_ir_clk)
     begin
	if(~capture_ir_en)
	  begin
	     if(~shift_ir)
	       begin
		  capture_ir_reg <= data_in_ir;
	       end
	     else
	       begin
		  capture_ir_reg <= {tdi,capture_ir_reg[(width-1):1]};
	       end
	  end
     end
   
//--------------------------------------------------------------------
// update_ir_reg generation
//--------------------------------------------------------------------
   assign update_ir_clk  = sync_mode ?  tck_n             : update_ir;
   assign update_ir_en   = sync_mode ? (curr_state[UPDATE_IR]) : 1'b1;

   always @ (posedge update_ir_clk or negedge instr_rst)
     begin
	if(~instr_rst)
	  begin
	     if(id == 1'b1)
	       update_ir_reg <= idcode_opcode;
	     else
	       update_ir_reg <= {width{1'b1}}; 
	  end
	else
	  begin
	     if(update_ir_en)
	       begin
		  update_ir_reg <= capture_ir_reg;
	       end
	  end
     end

//--------------------------------------------------------------------
// tdo generation
//--------------------------------------------------------------------   
   assign data_in = tdi & shift_dr;
      
   always @ (posedge capture_dr_clk)
     begin
	if(~capture_dr)
	  begin
	     if(capture_dr_en)
	       bypass_so <= data_in;
	  end
	else
	  bypass_so <= 1'b0;
     end

   always @ (bypass_sel or bypass_int or capture_dr_reg or id_select or so or bypass_so or device_id_sel)
     begin
	if(bypass_sel | bypass_int)
	  tdo_temp = bypass_so;
	else if(id & ( device_id_sel==1'b1 || id_select))
	  tdo_temp = capture_dr_reg[0];
	else
	  tdo_temp = so;
     end

   always @ (posedge tck_n)
     begin
	if(curr_state[SHIFT_IR])
	  tdo <= capture_ir_reg[0];
	else
	  tdo <= tdo_temp;
     end
   
//--------------------------------------------------------------------
// othere update_ir_reg dependent signals/outputs
//--------------------------------------------------------------------   
   integer i;   
   always @ (update_ir_reg)
     begin
	update_ir_reg_tmp_n  =  update_ir_reg[(width-1)]; 
	update_ir_reg_tmp    =  update_ir_reg[(width-1)]; 
	update_ir_reg_tmp_by =  update_ir_reg[(width-1)]; 
	if(width > 2)
	  begin
	     for (i = (width-1); i >= 2; i = i-1)
	       begin
		  update_ir_reg_tmp_n  = update_ir_reg_tmp_n  | update_ir_reg[i];
		  update_ir_reg_tmp    = update_ir_reg_tmp    | update_ir_reg[i];
		  update_ir_reg_tmp_by = update_ir_reg_tmp_by & update_ir_reg[i];
	       end
	  end
	else
	  begin
	     update_ir_reg_tmp_n  =  update_ir_reg[1]; 
	     update_ir_reg_tmp    = ~update_ir_reg[1]; 
	     update_ir_reg_tmp_by =  update_ir_reg[1]; 
	  end
     end
   
   assign instructions = update_ir_reg;
   assign id_select    =  update_ir_reg[0] & ~update_ir_reg[1] & ~update_ir_reg_tmp_n;
   assign bypass_int   =  update_ir_reg[0] &  update_ir_reg[1] &  update_ir_reg_tmp_by;

//----------------------------------------------------------------------
// cadence translate_off
// synopsys translate_off
//----------------------------------------------------------------------
   initial
     begin : parameter_check
       integer err_flag;
	
	reg [width:0] upper_limit;
        upper_limit = 0;
	
	upper_limit[width]=1;
	upper_limit=upper_limit-1;
	
	
        err_flag = 0 ;

	
       if ((width < 2) ||(width > 32))
         begin
           $display("%m ERROR - Incorrect Parameter, width = %0d (Valid range : 2 to 32)", width);
           err_flag = 1;
         end
        
       if ((id != 1) && (id != 0))
         begin
           $display("%m ERROR - Incorrect Parameter, id = %0d (Valid range : 1 or 0)", id);
           err_flag = 1;
         end

       if ((version < 0 ) || (version > 15))
         begin
           $display("%m ERROR - Incorrect Parameter, version = %0d (Valid range : 0 to 15)", version);
           err_flag = 1;
         end

       if ((part < 0 ) || (part > 65535))
         begin
           $display("%m ERROR - Incorrect Parameter, part = %0d (Valid range : 0 to 65535)", part);
           err_flag = 1;
         end

       if ((man_num < 0 ) ||  (man_num > 2047) || (man_num == 127))
         begin
           $display("%m ERROR - Incorrect Parameter, man_num = %0d (Valid range : 0 to 2047, man_num != 127)", man_num);
           err_flag = 1;
         end

       if ((sync_mode != 1) && (sync_mode != 0))
         begin
           $display("%m ERROR - Incorrect Parameter, sync_mode = %0d (Valid range : 1 or 0)", sync_mode);
           err_flag = 1;
         end

       if ((idcode_opcode < 1) || (idcode_opcode > upper_limit))
         begin
           $display("%m ERROR - Incorrect Parameter, idcode_opcode = %0d (Valid range : 1 to 2^(width-1))",idcode_opcode );
           err_flag = 1;
         end
	
       if (err_flag)
         begin
           $display("%m ERROR - Simulation stopped due to incorrect parameter values");
           #1 $finish;
         end
    end // block: Parameter_Check
//----------------------------------------------------------------------
// cadence translate_on
// synopsys translate_on
//----------------------------------------------------------------------   
endmodule // CW_tap_uc
//------------------------------End of file-----------------------------
