`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/8
Time: 9:29
*/

`include "paras.v"

module rfd(
    input [3:0] CmpType,
    input [3:0] ExtType,
    input [2:0] PCSrc,
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

    input [15:0] Imm,
    input [25:0] InstrIndex,
    input [4:0] shamt,
    input [31:0] PCNxt,

    input [4:0] excCode,
    input EXLClr,
    input CP0WE,
    input eretClear,
    input ignoreOv,
    
    input reset,
    input clk,
    input Froze,
    input eretClearSignal,
    input requestInt,

    // output [3:0] HHTuseE,
    // output [3:0] HHTuseM,
    // output [4:0] HHA1,
    // output [4:0] HHA2,

    output reg [3:0] CmpTypeOut,
    output reg [3:0] ExtTypeOut,
    output reg [2:0] PCSrcOut,
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
    
    output reg [15:0] ImmOut,
    output reg [25:0] InstrIndexOut,
    output reg [4:0] shamtOut,
    output reg [31:0] PCNxtOut,

    output reg [4:0] excCodeOut,
    output reg EXLClrOut,
    output reg CP0WEOut,
    output reg eretClearOut,
    output reg ignoreOvOut,
    output reg isIDSOut
);

    // assign HHTuseE = TuseE;
    // assign HHTuseM = TuseM;
    // assign HHA1 = A1;
    // assign HHA2 = A2;
    reg nxtIsIDS;

    always @(posedge clk) begin
        if (reset || (eretClearSignal && !Froze) || requestInt) begin
            isIDSOut <= `NO;
            nxtIsIDS <= `NO;
        end
        else if (Froze) begin
            isIDSOut <= isIDSOut;
            nxtIsIDS <= nxtIsIDS;
        end
        else if (nxtIsIDS) begin
            isIDSOut <= `YES;
            nxtIsIDS <= `NO;
        end
        else if (PCSrc != `PCNORMAL && PCSrc != `PCERET) begin
            isIDSOut <= `NO;
            nxtIsIDS <= `YES;
        end
        else begin
            isIDSOut <= `NO;
            nxtIsIDS <= `NO;
        end
    end
    
    always @(posedge clk) begin
        if (reset || (eretClearSignal && !Froze) || requestInt) begin
    		CmpTypeOut <= `CMPDEFAULT;
    		ExtTypeOut <= `EXTDEFAULT;
    		PCSrcOut <= `PCNORMAL;
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
    		InstrIndexOut <= 26'b0;
    		shamtOut <= 5'b0;
    		PCNxtOut <= 32'b0;

            excCodeOut <= `EXCDEFAULT;
            EXLClrOut <= `NO;
            CP0WEOut <= `NO;
            eretClearOut <= `NO;
            ignoreOvOut <= `NO;
        end
        else if (Froze) begin
            CmpTypeOut <= CmpTypeOut;
    		ExtTypeOut <= ExtTypeOut;
    		PCSrcOut <= PCSrcOut;
    		ALUCtrlOut <= ALUCtrlOut;
    		ALUSrcOut <= ALUSrcOut;
            MNDTypeOut <= MNDTypeOut;
            MNDUsageOut <= MNDUsageOut;
            MNDWEOut <= MNDWEOut;
            MNDStartOut <= MNDStartOut;
    		MemWriteOut <= MemWriteOut;
            MemTypeOut <= MemTypeOut;
    		RegDataSrcOut <= RegDataSrcOut;
    		RegWriteOut <= RegWriteOut;
    		TnewOut <= TnewOut;
    		TuseEOut <= TuseEOut;
    		TuseMOut <= TuseMOut;
    
    		A3Out <= A3Out;
    		A2Out <= A2Out;
    		A1Out <= A1Out;
    
    		ImmOut <= ImmOut;
    		InstrIndexOut <= InstrIndexOut;
    		shamtOut <= shamtOut;
    		PCNxtOut <= PCNxtOut;

            excCodeOut <= excCodeOut;
            EXLClrOut <= EXLClrOut;
            CP0WEOut <= CP0WEOut;
            eretClearOut <= eretClearOut;
            ignoreOvOut <= ignoreOvOut;
        end
        else begin
    		CmpTypeOut <= CmpType;
    		ExtTypeOut <= ExtType;
    		PCSrcOut <= PCSrc;
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
    		InstrIndexOut <= InstrIndex;
    		shamtOut <= shamt;
    		PCNxtOut <= PCNxt;

            excCodeOut <= excCode;
            EXLClrOut <= EXLClr;
            CP0WEOut <= CP0WE;
            eretClearOut <= eretClear;
            ignoreOvOut <= ignoreOv;
        end
    end
    

endmodule
