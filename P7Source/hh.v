`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/7
Time: 10:00
*/

`include "paras.v"

module hh(
    input clk,
    input reset,

    input [3:0] FD_TuseE,
    input [3:0] FD_TuseM,
    input [4:0] FD_A1,
    input [4:0] FD_A2,
    input [4:0] FD_A3,
    input [31:0] FD_RD1,
    input [31:0] FD_RD2,
    input [3:0] FD_Tnew,
    input FD_RegWrite,
    input [2:0] FD_MNDUsage,
    input [1:0] FD_MNDWE,
    input FD_ERET,

    input [3:0] DE_TuseE,
    input [3:0] DE_TuseM,
    input [4:0] DE_A1,
    input [4:0] DE_A2,
    input [4:0] DE_A3,
    input [31:0] DE_RD1,
    input [31:0] DE_RD2,
    input [3:0] DE_Tnew,
    input DE_RegWrite,
    input [3:0] DE_MemType,

    input MND_Busy,
    
    input [3:0] EM_TuseM,
    input [4:0] EM_A2,
    input [4:0] EM_A3,
    input [31:0] EM_RD2,
    input [3:0] EM_Tnew,
    input EM_RegWrite,
    input [31:0] EM_RegData,
    input [3:0] EM_MemType,
    
    input [3:0] MW_Tnew,
    input MW_RegWrite,
    input [4:0] MW_A3,
    input [31:0] MW_RegData,

    output Froze,
    output [31:0] RD1ForwardD,
    output [31:0] RD2ForwardD,
    output [31:0] RD1ForwardE,
    output [31:0] RD2ForwardE,
    output [31:0] WDForward
);
    reg [3:0] eretStallCnt;
    
    always @(posedge clk) begin
        if (reset) begin
            eretStallCnt <= 0;
        end 
        else if (FD_ERET && eretStallCnt == 0) begin
            eretStallCnt <= 3;
        end
        else begin
            eretStallCnt <= eretStallCnt == 0 ? 0 : eretStallCnt - 1;
        end
    end

    assign Froze =      (FD_ERET && eretStallCnt != 1) ||
                        ((FD_MNDUsage == `MNDUSEHI || FD_MNDUsage == `MNDUSELO 
                          || FD_MNDWE == `MNDWRITEHI || FD_MNDWE == `MNDWRITELO) && MND_Busy) ||
                        (DE_Tnew > FD_TuseE && DE_A3 == FD_A1 && DE_RegWrite) ||
                        (DE_Tnew > FD_TuseM && DE_A3 == FD_A2 && DE_RegWrite) ||
                        (EM_Tnew > FD_TuseE && EM_A3 == FD_A1 && EM_RegWrite) ||
                        (EM_Tnew > FD_TuseM && EM_A3 == FD_A2 && EM_RegWrite);

    assign RD1ForwardD =    (FD_A1 == 0) ? 0 :
                            (EM_Tnew <= FD_TuseE && EM_A3 == FD_A1 && EM_RegWrite) ? EM_RegData :
                            (MW_Tnew <= FD_TuseE && MW_A3 == FD_A1 && MW_RegWrite) ? MW_RegData : FD_RD1;

    assign RD2ForwardD =    (FD_A2 == 0) ? 0 :
                            (EM_Tnew <= FD_TuseM && EM_A3 == FD_A2 && EM_RegWrite) ? EM_RegData :
                            (MW_Tnew <= FD_TuseM && MW_A3 == FD_A2 && MW_RegWrite) ? MW_RegData : FD_RD2;

    assign RD1ForwardE =    (DE_A1 == 0) ? 0 :
                            (EM_Tnew <= DE_TuseE && EM_A3 == DE_A1 && EM_RegWrite) ? EM_RegData :
                            (MW_Tnew <= DE_TuseE && MW_A3 == DE_A1 && MW_RegWrite) ? MW_RegData : DE_RD1;

    assign RD2ForwardE =    (DE_A2 == 0) ? 0 :
                            (EM_Tnew <= DE_TuseM && EM_A3 == DE_A2 && EM_RegWrite) ? EM_RegData :
                            (MW_Tnew <= DE_TuseM && MW_A3 == DE_A2 && MW_RegWrite) ? MW_RegData : DE_RD2;

    assign WDForward   =    (EM_A2 == 0) ? 0 :
                            (MW_Tnew <= EM_TuseM && MW_A3 == EM_A2 && MW_RegWrite) ? MW_RegData : EM_RD2;


    

endmodule
