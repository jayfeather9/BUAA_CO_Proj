`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/12/14
Time: 8:47
*/

module bridge(
    // CPU inputs
    input [31:0] CPUAddr,
    input [3:0] CPUByteEn,
    // DM input
    input [31:0] DMData,
    // TC inputs
    input [31:0] TC0Data,
    input [31:0] TC1Data,
    // DM outputs
    output [31:0] DMAddr,
    output [3:0] DMByteEn,
    // TC outputs
    output [31:2] TC0Addr,
    output TC0WE,
    output [31:2] TC1Addr,
    output TC1WE,
    // INT outputs
    output [31:0] INTAddr,
    output [3:0] INTByteEn,
    // CPU outputs
    output [31:0] CPUData
);
    assign DMAddr = CPUAddr;
    assign TC0Addr = CPUAddr[31:2];
    assign TC1Addr = CPUAddr[31:2];
    assign INTAddr = CPUAddr;

    assign DMByteEn = (CPUAddr <= 32'h2fff) ? CPUByteEn : 4'b0;
    assign TC0WE = (CPUAddr >= 32'h7f00 && CPUAddr <= 32'h7f0b) ? |CPUByteEn : 1'b0;
    assign TC1WE = (CPUAddr >= 32'h7f10 && CPUAddr <= 32'h7f1b) ? |CPUByteEn : 1'b0;
    assign INTByteEn = (CPUAddr == 32'h7f20) ? CPUByteEn : 4'b0;

    assign CPUData = (CPUAddr <= 32'h2fff) ? DMData : 
                    (CPUAddr >= 32'h7f00 && CPUAddr <= 32'h7f0b) ? TC0Data : 
                    (CPUAddr >= 32'h7f10 && CPUAddr <= 32'h7f1b) ? TC1Data : 
                    32'h0;

endmodule