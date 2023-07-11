`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/10/27
Time: 10:44
*/

`include "paras.v"

module alu(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [4:0] ALUCtrl,
    input [4:0] shamt,
    input ignoreOv,
    output [31:0] ALUResult,
    output [4:0] excCode
);

    assign ALUResult = 
        ALUCtrl == `ALUOR ? SrcA | SrcB :         // or
        ALUCtrl == `ALUAND ? SrcA & SrcB :         // and
        (ALUCtrl == `ALUADD || ALUCtrl == `ALULOADADD || ALUCtrl == `ALUSAVEADD) ? SrcA + SrcB : // add
        ALUCtrl == `ALUSUB ? SrcA - SrcB :         // sub
        ALUCtrl == `ALULUI ? {SrcB[15:0], {16{1'b0}}} :       // lui
        ALUCtrl == `ALUSLT ? ($signed(SrcA) < $signed(SrcB) ? 32'b1 : 32'b0) :         // slt
        ALUCtrl == `ALUSLTU ? (SrcA < SrcB ? 32'b1 : 32'b0) :        // sltu
        ALUCtrl == `ALUNOR ? ~(SrcA | SrcB) :      // nor
        ALUCtrl == `ALUXOR ? SrcA ^ SrcB :         // xor
        ALUCtrl == `ALUSLL ? SrcB << shamt :       // sll
        ALUCtrl == `ALUSLLV ? SrcB << SrcA[4:0] :      // sllv
        ALUCtrl == `ALUSRL ? SrcB >> shamt :       // srl
        ALUCtrl == `ALUSRLV ? SrcB >> SrcA[4:0] :      // srlv
        ALUCtrl == `ALUSRA ? $signed($signed(SrcB) >>> shamt) :       // sra
        ALUCtrl == `ALUSRAV ? $signed($signed(SrcB) >>> SrcA[4:0]) :      // srav
        32'b0;

    wire [32:0] AddResult, SubResult;
    wire AddOverflow, SubOverflow;
    assign AddResult = {SrcA[31], SrcA} + {SrcB[31], SrcB};
    assign SubResult = {SrcA[31], SrcA} - {SrcB[31], SrcB};
    assign AddOverflow = (AddResult[32] != AddResult[31]) ? 1'b1 : 1'b0;
    assign SubOverflow = (SubResult[32] != SubResult[31]) ? 1'b1 : 1'b0;
    
    assign excCode = ((ignoreOv == 1'b0) && (
                        (ALUCtrl == `ALUADD && AddOverflow) ||
                        (ALUCtrl == `ALUSUB && SubOverflow))
                        ) ? `EXCOV : 
                    ((ignoreOv == 1'b0) && 
                        (ALUCtrl == `ALULOADADD && AddOverflow)
                        ) ? `EXCAdEL : 
                    ((ignoreOv == 1'b0) &&
                        (ALUCtrl == `ALUSAVEADD && AddOverflow)
                        ) ? `EXCAdES : 
                    `EXCDEFAULT;

endmodule
