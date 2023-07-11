`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/6
Time: 16:13
*/

`include "paras.v"

module ext(
    input [15:0] Imm,
    input [3:0] ExtType,
    output [31:0] ExtOut
);
    assign ExtOut = ExtType == `EXTZERO ? {{16{1'b0}}, Imm} :
                    ExtType == `EXTSIGN ? {{16{Imm[15]}}, Imm} :
                    {{16{1'b0}}, Imm};
endmodule
