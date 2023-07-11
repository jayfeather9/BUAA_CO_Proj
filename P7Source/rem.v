`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/8
Time: 13:46
*/

`include "paras.v"

module rem(
    input MemWrite,
    input [3:0] MemType,
    input [2:0] RegDataSrc,

    input RegWrite,

    input [3:0] Tnew,
    input [3:0] TuseM,
    
    input [4:0] A3,
    input [4:0] A2,
    input [4:0] A1,

    input [31:0] RD2,

    input [31:0] ExeResult,
    input [31:0] PCNxt,

    input [4:0] excCode,
    input EXLClr,
    input CP0WE,
    input ignoreOv,
    input isIDS,
    
    input reset,
    input clk,
    input requestInt,

    output reg MemWriteOut,
    output reg [3:0] MemTypeOut,
    output reg [2:0] RegDataSrcOut,

    output reg RegWriteOut,

    output reg [3:0] TnewOut,
    output reg [3:0] TuseMOut,
    
    output reg [4:0] A3Out,
    output reg [4:0] A2Out,
    output reg [4:0] A1Out,

    output reg [31:0] RD2Out,

    output reg [31:0] ExeResultOut,
    output reg [31:0] PCNxtOut,

    output reg [4:0] excCodeOut,
    output reg EXLClrOut,
    output reg CP0WEOut,
    output reg isIDSOut
);
    
    always @(posedge clk) begin
        if (reset || requestInt) begin
    		MemWriteOut <= `NO;
            MemTypeOut <= `MEMDEFAULT;
    		RegDataSrcOut <= `REGDATANOWRITE;
    		RegWriteOut <= `NO;

    		TnewOut <= `TNEWDEFAULT;
    		TuseMOut <= `TUSEDEFAULT;
    
    		A3Out <= `REGADDRDEFAULT;
    		A2Out <= `REGADDRDEFAULT;
            A1Out <= `REGADDRDEFAULT;

            RD2Out <= 32'b0;

            ExeResultOut <= 32'b0;
            PCNxtOut <= 32'b0;

            excCodeOut <= `EXCDEFAULT;
            EXLClrOut <= `NO;
            CP0WEOut <= `NO;
            isIDSOut <= `NO;
        end
        else begin
    		MemWriteOut <= MemWrite;
            MemTypeOut <= MemType;
    		RegDataSrcOut <= RegDataSrc;

    		RegWriteOut <= RegWrite;

    		TnewOut <= $signed(Tnew - 1) > 0 ? Tnew - 1 : 0;
    		TuseMOut <= TuseM;
    
    		A3Out <= A3;
    		A2Out <= A2;
            A1Out <= A1;

            RD2Out <= RD2;

            ExeResultOut <= ExeResult;
            PCNxtOut <= PCNxt;

            excCodeOut <= excCode;
            EXLClrOut <= EXLClr;
            CP0WEOut <= CP0WE;
            isIDSOut <= isIDS;
        end
    end
    

endmodule
