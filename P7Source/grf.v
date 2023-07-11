`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/10/28
Time: 8:09
*/

module grf(
    input clk,
    input reset,
    input WE,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    output [31:0] RD1,
    output [31:0] RD2
);
    reg [31:0] grf_reg [0:31];
    assign RD1 = A1 == 5'b0 ? 32'b0 :
                 A1 == A3   ? WD    :
                 grf_reg[A1];
    assign RD2 = A2 == 5'b0 ? 32'b0 :
                 A2 == A3   ? WD    :
                 grf_reg[A2];

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                grf_reg[i] <= 32'b0;
            end
        end
        else if (WE) begin
            if (A3 == 5'b0) begin
                grf_reg[0] <= 32'b0;
            end
            else begin
                grf_reg[A3] <= WD;
            end
        end
    end

endmodule
