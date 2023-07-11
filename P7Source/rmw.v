`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/8
Time: 13:51
*/

`include "paras.v"

module rmw(
    input [2:0] RegDataSrc,
    input RegWrite,

    input [3:0] Tnew,
    
    input [4:0] A3,

    input [31:0] ExeResult,
    input [31:0] PCNxt,
    input [31:0] DMData,
    input [31:0] CP0ReadData,

    input reset,
    input clk,
    input requestInt,

    output reg [2:0] RegDataSrcOut,
    output reg RegWriteOut,

    output reg [3:0] TnewOut,
    
    output reg [4:0] A3Out,

    output reg [31:0] ExeResultOut,
    output reg [31:0] PCNxtOut,
    output reg [31:0] DMDataOut,
    output reg [31:0] CP0ReadDataOut
);
    
    always @(posedge clk) begin
        if (reset || requestInt) begin
    		RegDataSrcOut <= `REGDATANOWRITE;
    		RegWriteOut <= `NO;

    		TnewOut <= `TNEWDEFAULT;

    		A3Out <= `REGADDRDEFAULT;

            ExeResultOut <= 32'b0;
            PCNxtOut <= 32'b0;
            DMDataOut <= 32'b0;
            CP0ReadDataOut <= 32'b0;
        end
        else begin
            RegDataSrcOut <= RegDataSrc;
            RegWriteOut <= RegWrite;

            TnewOut <= $signed(Tnew - 1) > 0 ? Tnew - 1 : 0;

            A3Out <= A3;

            ExeResultOut <= ExeResult;
            PCNxtOut <= PCNxt;
            DMDataOut <= DMData;
            CP0ReadDataOut <= CP0ReadData;
        end
    end
    

endmodule
