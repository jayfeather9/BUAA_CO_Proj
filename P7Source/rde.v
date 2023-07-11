`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/8
Time: 13:43
*/

`include "paras.v"

module rde(
    input [4:0] ALUCtrl,
    input [1:0] ALUSrc,
    input [3:0] MNDType,
    input [2:0] MNDUsage,
    input [1:0] MNDWE,
    input MNDStart,
    input MemWrite,
    input [3:0] MemType,
    input [2:0] RegDataSrc,

    input RegWrite,
    input [3:0] Tnew,
    input [3:0] TuseE,
    input [3:0] TuseM,
    
    input [4:0] A3,
    input [4:0] A2,
    input [4:0] A1,

    input [31:0] Imm,
    input [4:0] shamt,
    input [31:0] PCNxt,

    input [4:0] excCode,
    input EXLClr,
    input CP0WE,
    input ignoreOv,
    input isIDS,
    input requestInt,

    input [31:0] RD1,
    input [31:0] RD2,
    
    input reset,
    input clk,
    input Froze,

    output reg [4:0] ALUCtrlOut,
    output reg [1:0] ALUSrcOut,
    output reg [3:0] MNDTypeOut,
    output reg [2:0] MNDUsageOut,
    output reg [1:0] MNDWEOut,
    output reg MNDStartOut,
    output reg MemWriteOut,
    output reg [3:0] MemTypeOut,
    output reg [2:0] RegDataSrcOut,

    output reg RegWriteOut,
    output reg [3:0] TnewOut,
    output reg [3:0] TuseEOut,
    output reg [3:0] TuseMOut,
    
    output reg [4:0] A3Out,
    output reg [4:0] A2Out,
    output reg [4:0] A1Out,
    
    output reg [31:0] ImmOut,
    output reg [4:0] shamtOut,
    output reg [31:0] PCNxtOut,

    output reg [31:0] RD1Out,
    output reg [31:0] RD2Out,

    output reg [4:0] excCodeOut,
    output reg EXLClrOut,
    output reg CP0WEOut,
    output reg ignoreOvOut,
    output reg isIDSOut
);
    
    always @(posedge clk) begin
        if (reset || requestInt) begin
    		ALUCtrlOut <= `ALUDEFAULT;
    		ALUSrcOut <= `ALUFROMGPR;
            MNDTypeOut <= `MNDTYPEDEFAULT;
            MNDUsageOut <= `MNDUSEDEFAULT;
            MNDWEOut <= `MNDNOWRITE;
            MNDStartOut <= `NO;
    		MemWriteOut <= `NO;
            MemTypeOut <= `MEMDEFAULT;
    		RegDataSrcOut <= `REGDATANOWRITE;
    		RegWriteOut <= `NO;
    		TnewOut <= `TNEWDEFAULT;
    		TuseEOut <= `TUSEDEFAULT;
    		TuseMOut <= `TUSEDEFAULT;
    
    		A3Out <= `REGADDRDEFAULT;
    		A2Out <= `REGADDRDEFAULT;
    		A1Out <= `REGADDRDEFAULT;
    
    		ImmOut <= 16'b0;
    		shamtOut <= 5'b0;
    		PCNxtOut <= 32'b0;

            RD1Out <= 32'b0;
            RD2Out <= 32'b0;

            excCodeOut <= `EXCDEFAULT;
            EXLClrOut <= `NO;
            CP0WEOut <= `NO;
            ignoreOvOut <= `NO;
            isIDSOut <= `NO;
        end
        else if (Froze) begin
            ALUCtrlOut <= `ALUDEFAULT;
    		ALUSrcOut <= `ALUFROMGPR;
            MNDTypeOut <= `MNDTYPEDEFAULT;
            MNDUsageOut <= `MNDUSEDEFAULT;
            MNDWEOut <= `MNDNOWRITE;
            MNDStartOut <= `NO;
    		MemWriteOut <= `NO;
            MemTypeOut <= `MEMDEFAULT;
    		RegDataSrcOut <= `REGDATANOWRITE;
    		RegWriteOut <= `NO;
    		TnewOut <= `TNEWDEFAULT;
    		TuseEOut <= `TUSEDEFAULT;
    		TuseMOut <= `TUSEDEFAULT;
    
    		A3Out <= `REGADDRDEFAULT;
    		A2Out <= `REGADDRDEFAULT;
    		A1Out <= `REGADDRDEFAULT;
    
    		ImmOut <= 16'b0;
    		shamtOut <= 5'b0;
    		PCNxtOut <= PCNxt;

            RD1Out <= 32'b0;
            RD2Out <= 32'b0;

            excCodeOut <= `EXCDEFAULT;
            EXLClrOut <= `NO;
            CP0WEOut <= `NO;
            ignoreOvOut <= `NO;
            isIDSOut <= isIDS;
        end
        else begin
    		ALUCtrlOut <= ALUCtrl;
    		ALUSrcOut <= ALUSrc;
            MNDTypeOut <= MNDType;
            MNDUsageOut <= MNDUsage;
            MNDWEOut <= MNDWE;
            MNDStartOut <= MNDStart;
    		MemWriteOut <= MemWrite;
            MemTypeOut <= MemType;
    		RegDataSrcOut <= RegDataSrc;

    		RegWriteOut <= RegWrite;
    		TnewOut <= $signed(Tnew - 1) > 0 ? Tnew - 1 : 0;
    		TuseEOut <= TuseE;
    		TuseMOut <= TuseM;
    
    		A3Out <= A3;
    		A2Out <= A2;
    		A1Out <= A1;
    
    		ImmOut <= Imm;
    		shamtOut <= shamt;
    		PCNxtOut <= PCNxt;

            RD1Out <= RD1;
            RD2Out <= RD2;

            excCodeOut <= excCode;
            EXLClrOut <= EXLClr;
            CP0WEOut <= CP0WE;
            ignoreOvOut <= ignoreOv;
            isIDSOut <= isIDS;
        end
    end
    

endmodule
