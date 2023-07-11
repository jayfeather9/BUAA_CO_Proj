`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/10/26
Time: 20:43
*/

`include "paras.v"

module dmio(
    input [3:0] MemType,
    input [31:0] Addr,
    input [31:0] WD,
    input WE,
    input requestInt,
    // === below is DM i/o ===
    input [31:0] dataIn,
    output [31:0] CPUDataAddr,
    output [31:0] CPUWriteData,
    output [3:0] CPUDataByteEn,
    // === above is DM i/o ===
    output [31:0] RD,
    output isChangingA3,
    output [4:0] changedA3,
    output [4:0] excCode
);
    reg [31:0] DM_data_reg [0:4095];
    wire [15:0] halfword_dataIn;
    wire [7:0] byte_dataIn;
    assign halfword_dataIn = dataIn[Addr[1]*16 +: 16];
    assign byte_dataIn = dataIn[Addr[1:0]*8 +: 8];
    assign RD = (MemType == `MEMWORD) ? dataIn :
                (MemType == `MEMHALFWORD) ? {{16{halfword_dataIn[15]}}, halfword_dataIn} :
                (MemType == `MEMHALFWORDU) ? {{16{1'b0}}, halfword_dataIn} :
                (MemType == `MEMBYTE) ? {{24{byte_dataIn[7]}}, byte_dataIn} :
                (MemType == `MEMBYTEU) ? {{24{1'b0}}, byte_dataIn} :
                32'b0;

    assign isChangingA3 = 1'b0;
    assign changedA3 = 5'b0;

    assign excCode = 
        // misaligned fault
        (MemType == `MEMWORD && Addr[1:0] != 2'b0 && WE == 1'b0) ? `EXCAdEL :
        (MemType == `MEMWORD && Addr[1:0] != 2'b0 && WE == 1'b1) ? `EXCAdES :
        ((MemType == `MEMHALFWORD || MemType == `MEMHALFWORDU) && Addr[0] != 1'b0 && WE == 1'b0) ? `EXCAdEL :
        (MemType == `MEMHALFWORD && Addr[0] != 1'b0 && WE == 1'b1) ? `EXCAdES :
        // access fault
        (MemType == `MEMWORD && (
            (Addr > 32'h2fff && Addr < 32'h7f00) || (Addr > 32'h7f23) || (Addr == 32'h7f0c) || (Addr == 32'h7f1c)
            ) && WE == 1'b0) ? `EXCAdEL :
        (MemType == `MEMWORD && (
            (Addr > 32'h2fff && Addr < 32'h7f00) || (Addr > 32'h7f23) || (Addr == 32'h7f0c) || (Addr == 32'h7f1c) || (Addr == 32'h7f08) || (Addr == 32'h7f18)
            ) && WE == 1'b1) ? `EXCAdES :
        ((MemType == `MEMHALFWORD || MemType == `MEMHALFWORDU || MemType == `MEMBYTE || MemType == `MEMBYTEU) 
            && ((Addr > 32'h2fff && Addr < 32'h7f20) || (Addr > 32'h7f23)) && WE == 1'b0) ? `EXCAdEL :
        ((MemType == `MEMHALFWORD || MemType == `MEMHALFWORDU || MemType == `MEMBYTE || MemType == `MEMBYTEU) 
            && ((Addr > 32'h2fff && Addr < 32'h7f20) || (Addr > 32'h7f23)) && WE == 1'b1) ? `EXCAdES :
        `EXCDEFAULT;
    
    assign CPUDataAddr = Addr;
    assign CPUDataByteEn =    (WE == 1'b0 || requestInt == 1'b1) ? 4'b0000 :
                            (MemType == `MEMWORD) ? 4'b1111 :
                            (MemType == `MEMHALFWORD && Addr[1] == 1'b1) ? 4'b1100 :
                            (MemType == `MEMHALFWORD && Addr[1] == 1'b0) ? 4'b0011 :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b11) ? 4'b1000 :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b10) ? 4'b0100 :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b01) ? 4'b0010 :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b00) ? 4'b0001 :
                            4'b0000;
    assign CPUWriteData =   (WE == 1'b0) ? 32'b0 :
                            (MemType == `MEMWORD) ? WD :
                            (MemType == `MEMHALFWORD && Addr[1] == 1'b1) ? {WD[15:0], 16'b0} :
                            (MemType == `MEMHALFWORD && Addr[1] == 1'b0) ? {16'b0, WD[15:0]} :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b11) ? {WD[7:0], 24'b0} :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b10) ? {8'b0, WD[7:0], 16'b0} :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b01) ? {16'b0, WD[7:0], 8'b0} :
                            (MemType == `MEMBYTE && Addr[1:0] == 2'b00) ? {24'b0, WD[7:0]} :
                            32'b0;

endmodule
