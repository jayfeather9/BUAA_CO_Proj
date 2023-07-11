`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/10/28
Time: 8:39
*/

`include "paras.v"

module ifu(
    input clk,
    input reset,
    input Froze,
    input [2:0] PCSrc,
    input ALUZero,
    input requestInt,
    input [15:0] PCImm,
    input [25:0] PCInstrIndex,
    input [31:0] PCJumpReg,
    input [31:0] EPC,
    output [31:0] InstAddr,
    output [31:0] PCNxt
);
    reg [31:0] PC;

    assign PCNxt = PC + 8; // delay slot
    assign InstAddr = PC;
    
    always @(posedge clk) begin
        if (reset) begin
            PC <= 32'h3000;
        end
        else if (requestInt) begin
            $display("Interrupt Happened");
            PC <= 32'h4180;
        end
        else if (Froze) begin
            $display("Frozed");
            PC <= PC;
        end
        else if (PCSrc == `PCNORMAL || (PCSrc == `PCBRANCH && ALUZero == 0)) begin // No b/j code or branch code do not valid
            if (PCSrc == 2'b01)begin
                $display("Branch Failed");
            end
            PC <= PC + 4;
        end
        else if (PCSrc == `PCBRANCH && ALUZero == 1) begin // branch code takes effect
            $display("Branch Succeded new PC = %h", PC + {{14{PCImm[15]}}, PCImm, {2{1'b0}}});
            PC <= PC + {{14{PCImm[15]}}, PCImm, {2{1'b0}}};
        end
        else if (PCSrc == `PCJUMP) begin // jal code
            $display("Jal Done new PC = %h", {PC[31:28], PCInstrIndex, {2{1'b0}}});
            PC <= {PC[31:28], PCInstrIndex, {2{1'b0}}};
        end
        else if (PCSrc == `PCJREG) begin // jr code
            $display("Jr Done PCSrc = %d ALUZero = %d new PC = %h", PCSrc, ALUZero, PCJumpReg);
            PC <= PCJumpReg;
        end
        else if (PCSrc == `PCERET) begin
            $display("Eret Done target = %h", EPC);
            PC <= EPC;
        end
        else begin
            $display("PCSRC BAD");
            PC <= PC + 4;
        end
    end

endmodule
