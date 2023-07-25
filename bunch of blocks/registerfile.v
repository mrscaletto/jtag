module RegisterFile(ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, Clk, ReadData1, ReadData2);

	input [4:0] ReadRegister1,ReadRegister2,WriteRegister;
    /*
      ReadRegister1: 5-битный адрес для выбора регистра для чтения через 32-битный
      ReadRegister2: 5-битный адрес для выбора регистра для чтения через 32-битный
      WriteRegister: 5-битный адрес для выбора регистра для записи через 32-битный
    */
	input [31:0] WriteData;//32-битный входной порт для записи
	input RegWrite,Clk;
	
	output reg [31:0] ReadData1,ReadData2;
	
	
	//reg [63:0] Registers = new reg[32];
	reg [63:0] Registers [0:31];
	
	initial begin
		Registers[0] <= 32'h00000000;
    Registers[1] <= 32'h00000000;
		Registers[2] <= 32'h00000000;
		Registers[3] <= 32'h00000000;
		Registers[4] <= 32'h00000000;
		Registers[5] <= 32'h00000000;
		Registers[6] <= 32'h00000000;
		Registers[7] <= 32'h00000000;
		Registers[8] <= 32'h00000000;
		Registers[9] <= 32'h00000000;
		Registers[10] <= 32'h00000000;
		Registers[11] <= 32'h00000000;
		Registers[12] <= 32'h00000000;
		Registers[13] <= 32'h00000000;
		Registers[14] <= 32'h00000000;
		Registers[15] <= 32'h00000000;
		Registers[16] <= 32'h00000000;
		Registers[17] <= 32'h00000000;
		Registers[18] <= 32'h00000000;
		Registers[19] <= 32'h00000000;
		Registers[20] <= 32'h00000000;
		Registers[21] <= 32'h00000000;
		Registers[22] <= 32'h00000000;
		Registers[23] <= 32'h00000000;
		Registers[24] <= 32'h00000000;
		Registers[25] <= 32'h00000000;
    Registers[26] <= 32'h00000000;
		Registers[27] <= 32'h00000000;
		Registers[28] <= 32'h00000000;
		Registers[29] <= 32'h00000000;
		Registers[30] <= 32'h00000000;
		Registers[31] <= 32'h00000000;
		Registers[32] <= 32'h00000000;
		Registers[33] <= 32'h00000000;
		Registers[34] <= 32'h00000000;
		Registers[35] <= 32'h00000000;
		Registers[36] <= 32'h00000000;
		Registers[37] <= 32'h00000000;
		Registers[38] <= 32'h00000000;
		Registers[39] <= 32'h00000000;
		Registers[40] <= 32'h00000000;
		Registers[41] <= 32'h00000000;
		Registers[42] <= 32'h00000000;
		Registers[43] <= 32'h00000000;
		Registers[44] <= 32'h00000000;
    Registers[45] <= 32'h00000000;
		Registers[46] <= 32'h00000000;
		Registers[47] <= 32'h00000000;
		Registers[48] <= 32'h00000000;
		Registers[49] <= 32'h00000000;
		Registers[50] <= 32'h00000000;
		Registers[51] <= 32'h00000000;
		Registers[52] <= 32'h00000000;
    Registers[53] <= 32'h00000000;
		Registers[54] <= 32'h00000000;
		Registers[55] <= 32'h00000000;
		Registers[56] <= 32'h00000000;
		Registers[57] <= 32'h00000000;
		Registers[58] <= 32'h00000000;
		Registers[59] <= 32'h00000000;
		Registers[60] <= 32'h00000000;
    Registers[61] <= 32'h00000000;
		Registers[62] <= 32'h00000000;
		Registers[63] <= 32'b0;
	end
	
	
	always @(posedge Clk)
	begin
		
		if (RegWrite == 1) 
		begin
			Registers[WriteRegister] <= WriteData;
		end
	end
	
	always @(negedge Clk)
	begin
		ReadData1 <= Registers[ReadRegister1];
		ReadData2 <= Registers[ReadRegister2];
	end
	
	

endmodule
