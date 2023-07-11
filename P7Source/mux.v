`timescale 1ns / 1ps

module mux5D1S(
	input [0:0] select,
	input [4:0] in0,
	input [4:0] in1,

	output [4:0] out
);
	assign out = 
		select == 1'd0 ? in0 :
		in1;
endmodule

module mux5D2S(
	input [1:0] select,
	input [4:0] in0,
	input [4:0] in1,
	input [4:0] in2,
	input [4:0] in3,

	output [4:0] out
);
	assign out = 
		select == 2'd0 ? in0 :
		select == 2'd1 ? in1 :
		select == 2'd2 ? in2 :
		in3;
endmodule

module mux32D2S(
	input [1:0] select,
	input [31:0] in0,
	input [31:0] in1,
	input [31:0] in2,
	input [31:0] in3,

	output [31:0] out
);
	assign out = 
		select == 2'd0 ? in0 :
		select == 2'd1 ? in1 :
		select == 2'd2 ? in2 :
		in3;
endmodule

module mux32D3S(
	input [2:0] select,
	input [31:0] in0,
	input [31:0] in1,
	input [31:0] in2,
	input [31:0] in3,
	input [31:0] in4,
	input [31:0] in5,
	input [31:0] in6,
	input [31:0] in7,

	output [31:0] out
);
	assign out = 
		select == 3'd0 ? in0 :
		select == 3'd1 ? in1 :
		select == 3'd2 ? in2 :
		select == 3'd3 ? in3 :
		select == 3'd4 ? in4 :
		select == 3'd5 ? in5 :
		select == 3'd6 ? in6 :
		in7;
endmodule

