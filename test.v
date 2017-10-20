module test (
	input clk,
	input clr,
	//input [7:0]Data,
	output reg [5:0]Ring_Counter,
	output [11:0]Control,
	output reg[7:0]Data_Output
);
	reg [3:0]decoder;
	reg [3:0]PC_counter;
	reg [7:0]bus;
	reg [3:0]MAR;
	reg [7:4]i;
	reg [3:0]i2;
	reg [7:0]ACC;
	reg [7:0]ADD;
	reg [7:0]temp;
//---------------------control------------------------------
	always@(i)begin
		case(i)
			4'b0000:decoder<=4'b1000;
			4'b0001:decoder<=4'b0100;
			4'b0010:decoder<=4'b0010;
			4'b1110:decoder<=4'b0001;
			default:decoder<=4'b0000;
		endcase
	end
	always@(posedge clk,negedge clr)begin
		if(!clr) Ring_Counter<=6'b000000;
		else if(Ring_Counter==0)Ring_Counter<=6'b000001;
		else Ring_Counter<={Ring_Counter[4:0],Ring_Counter[5]};
	end
	assign Control[11]=Ring_Counter[1];
	assign Control[10]=Ring_Counter[0];
	assign Control[9]=!(Ring_Counter[0]||Ring_Counter[3]&&(decoder[3]||decoder[2]||decoder[1]||decoder[0]));
	assign Control[8]=!(Ring_Counter[2]||Ring_Counter[4]&&(decoder[3]||decoder[2]||decoder[1]||decoder[0]));
	assign Control[7]=!Ring_Counter[2];
	assign Control[6]=!(Ring_Counter[3]&&(decoder[3]||decoder[2]||decoder[1]||decoder[0]));
	assign Control[5]=!(Ring_Counter[4]&&decoder[3]);
	assign Control[4]=Ring_Counter[3]&&decoder[0];
	assign Control[3]=Ring_Counter[5]&&decoder[1];
	assign Control[2]=Ring_Counter[5]&&(decoder[2]||decoder[1]);
	assign Control[1]=!(Ring_Counter[4]&&(decoder[2]||decoder[1]));
	assign Control[0]=!(Ring_Counter[3]&&decoder[0]);
//---------------------Program Counter-------------------
	always@(negedge clk,negedge clr)begin
		if(!clr) PC_counter<=0;
		else begin
			if(Control[11])begin
				PC_counter<=PC_counter+1;
			end 
		end
	end
//----------------------ROM----------------------------
	function [7:0]Instruction_decoder;
		input [3:0]sel;
		case(sel)
			4'd0 : Instruction_decoder = 8'h09 ;
			4'd1 : Instruction_decoder = 8'h1a ;
			4'd2 : Instruction_decoder = 8'h2b ;
			4'd3 : Instruction_decoder = 8'hec ;
			4'd4 : Instruction_decoder = 8'he0 ;
			4'd5 : Instruction_decoder = 8'hf0 ;
			4'd6 : Instruction_decoder = 8'hf0 ;
			4'd7 : Instruction_decoder = 8'h00 ;
			4'd8 : Instruction_decoder = 8'h00 ;
			4'd9 : Instruction_decoder = 8'h10 ;
			4'd10 : Instruction_decoder = 8'h14 ;
			4'd11 : Instruction_decoder = 8'h18 ;
			4'd12 : Instruction_decoder = 8'h20 ;
			4'd13 : Instruction_decoder = 8'h00 ;
			4'd14 : Instruction_decoder = 8'h00 ;
			4'd15 : Instruction_decoder = 8'h00 ;
			default : Instruction_decoder = 8'h00 ;
		endcase
	endfunction
//----------------------multiple------------------------
	always@(Control)begin
		casex(Control)
			12'bx0xxxxxxxxxx:bus[3:0]<=PC_counter;
			12'bxx0xxxxxxxxx:bus<=Instruction_decoder(MAR);
			12'bxxxxx0xxxxxx:bus[3:0]<=i2;
			12'bxxxxxxx0xxxx:bus<=ACC;
			12'bxxxxxxxxx0xx:bus<=ADD;
		endcase
	end
//----------------------Memory Address Register--------
	always@(posedge clk)begin
		if(!Control[9])begin
			MAR<=bus[3:0];
		end
	end
//----------------------Instruction Register-----------
	always@(posedge clk,negedge clr)begin
		if(!clr)i<=0;
		else begin
			if(!Control[7])begin 
				i<=bus[7:4];
				i2<=bus[3:0];
			end
		end
	end
//----------------------Accumulator-----------------------
	always@(posedge clk)begin
		if(!Control[5])begin
			ACC<=bus;
		end
	end
//----------------------Adder--------------------
	always@(posedge clk)begin
	
		if(Control[3])begin
			ADD<=ACC-temp;
		end else begin
			ADD<=ACC+temp;
		end
		if(!Control[1])begin
			temp<=bus;
		end
	end
//---------------------Output---------------------
	always@(posedge clk,negedge clr)begin
		if(!clr)Data_Output<=0;
		else if(!Control[0])begin
			Data_Output<=bus;
		end
	end
endmodule 