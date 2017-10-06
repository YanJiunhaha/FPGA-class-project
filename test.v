module test (
	input clk,
	input clr,
	input [7:4]i,
	output reg [5:0]Ring_Counter
	output [11:0]Out;
);
	reg [3:0]decoder;
	always@(i)begin
		case(i)
			4'b0000:decoder<=4'b1000;
			4'b0001:decoder<=4'b0100;
			4'b0010:decoder<=4'b0010;
			4'b1110:decoder<=4'b1001;
			default:decoder<=4'b0000;
		endcase
	end
	always@(negedge clk)begin
		if(!clr) Ring_Counter<=6'b000000;
		else if(Ring_Counter==0)Ring_Counter<=6'b000001;
		else Ring_Counter={Ring_Counter[4:0],Ring_Counter[5]};
	end
	assign Out[11]=Ring_Counter[1];
	
endmodule 
