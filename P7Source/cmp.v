`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/7
Time: 9:00
*/

`include "paras.v"

module cmp(
    input [31:0] RD1,
    input [31:0] RD2,
    input [3:0] CmpType,
    output CmpOut
);
    assign CmpOut = (CmpType == `CMPEQUAL) ? (RD1 == RD2 ? 1'b1 : 1'b0) :
                    (CmpType == `CMPNOTEQUAL) ? (RD1 != RD2 ? 1'b1 : 1'b0) :
                    (CmpType == `CMPGTZ) ? ($signed($signed(RD1) > $signed(0)) ? 1'b1 : 1'b0) :
                    (CmpType == `CMPLTZ) ? ($signed($signed(RD1) < $signed(0)) ? 1'b1 : 1'b0) :
                    (CmpType == `CMPGEZ) ? ($signed($signed(RD1) >= $signed(0)) ? 1'b1 : 1'b0) :
                    (CmpType == `CMPLEZ) ? ($signed($signed(RD1) <= $signed(0)) ? 1'b1 : 1'b0) :
                    1'b0;

endmodule
