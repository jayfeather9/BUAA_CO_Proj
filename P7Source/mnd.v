`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/14
Time: 14:23
*/

`include "paras.v"

module mnd(
    input clk,
    input reset,
    input start,
    input requestInt,
    input [1:0] MNDWE,
    input [3:0] MNDType,
    input [31:0] RD1,
    input [31:0] RD2,
    output busy,
    output [31:0] HI,
    output [31:0] LO
);
    reg [1:0] curType;
    reg [3:0] cnt;
    reg [63:0] prod;

    always @(posedge clk) begin
        if (!reset && !requestInt && MNDWE == `MNDWRITEHI) begin
            prod[63:32] <= RD1;
        end
        else if (!reset && !requestInt && MNDWE == `MNDWRITELO) begin
            prod[31:0] <= RD1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            cnt <= 4'b0;
            prod <= 64'b0;
            curType <= `MNDTYPEDEFAULT;
        end
        else if (requestInt)begin
            cnt <= cnt;
            prod <= prod;
            curType <= curType;
        end
        else if (start) begin
            cnt <= 4'b1;
            curType <= MNDType;
            case (MNDType)
                `MNDMULT: begin
                    //prod <= {{16{RD1[31]}}, RD1} * {{16{RD2[31]}}, RD2};
                    prod <= $signed(RD1) * $signed(RD2);
                end
                `MNDMULTU: begin
                    //prod <= {{16{1'b0}}, RD1} * {{16{1'b0}}, RD2};
                    prod <= RD1 * RD2;
                end
                `MNDDIV: begin
                    prod <= {$signed(RD1) % $signed(RD2), $signed(RD1) / $signed(RD2)};
                end
                `MNDDIVU: begin
                    prod <= {RD1 % RD2, RD1 / RD2};
                end
                default: begin
                    prod <= 64'b0;
                end
            endcase
        end
        else if ((cnt > 5 && (curType == `MNDMULT || curType == `MNDMULTU)) ||
                 (cnt > 10 && (curType == `MNDDIV || curType == `MNDDIVU))) begin
            cnt <= 4'b0;
            curType <= `MNDTYPEDEFAULT;
        end
        else if (cnt > 0) begin
            cnt <= cnt + 1;
        end
    end

    assign busy = (cnt >= 1);
    assign HI = (cnt > 0) ? 32'd0 : prod[63:32];
    assign LO = (cnt > 0) ? 32'd0 : prod[31:0];

endmodule
