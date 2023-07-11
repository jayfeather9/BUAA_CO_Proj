`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/12/14
Time: 9:11
*/

module cp0(
    input clk,
    input reset,
    input WE,
    input [4:0] cp0Addr,
    input [31:0] cp0WriteData,
    input [31:0] VPC,
    input isInDelayedSlot,
    input [4:0] exceptionCode,
    input [5:0] HWInt,
    input EXLClr,
    output [31:0] cp0ReadData,
    output [31:0] EPCData,
    output requestInt
);
    reg [31:0] SR, Cause, EPC;
    assign EPCData = EPC;
    assign cp0ReadData = (cp0Addr == 5'd12) ? SR : 
                         (cp0Addr == 5'd13) ? Cause : 
                         (cp0Addr == 5'd14) ? EPC : 
                         32'h0;

    always @(posedge clk) begin
        Cause[15:10] <= HWInt;
    end

    assign requestInt = reset ? 1'b0 :
        (((|(HWInt & SR[15:10])) == 1'b1) && (SR[0] == 1'b1) && (SR[1] == 1'b0)) ? 1'b1 :
        ((exceptionCode != 5'd0) && (SR[1] == 1'b0)) ? 1'b1 :
        1'b0;
    
    // always @(posedge clk) begin
    //     $display("PCM=%h", VPC);
    // end

    always @(posedge clk) begin
        if (reset) begin
            SR <= 0;
            Cause <= 0;
            EPC <= 0;
        end
        else if (((|(HWInt & SR[15:10])) == 1'b1) && (SR[0] == 1'b1) && (SR[1] == 1'b0)) begin
            $display("Interrupt Cause = %h SR = %h VPC = %h EPC = %h", Cause, SR, VPC, isInDelayedSlot ? VPC - 4 : VPC);
            SR[1] <= 1;
            Cause[31] <= isInDelayedSlot;
            Cause[6:2] <= 0;
            EPC <= isInDelayedSlot ? VPC - 4 : VPC;
        end
        else if ((exceptionCode != 5'd0) && (SR[1] == 1'b0))begin
            SR[1] <= 1;
            Cause[31] <= isInDelayedSlot;
            Cause[6:2] <= exceptionCode;
            EPC <= isInDelayedSlot ? VPC - 4 : VPC;
            $display("Interrupt ExcCode = %d SR = %h VPC = %h EPC = %h", exceptionCode, SR, VPC, isInDelayedSlot ? VPC - 4 : VPC);
        end
        else if (EXLClr) begin
            SR[1] <= 0;
        end
        else if (WE) begin
            if (cp0Addr == 5'd12) begin
                SR <= cp0WriteData;
            end 
            else if (cp0Addr == 5'd13) begin
                Cause <= cp0WriteData;
            end 
            else if (cp0Addr == 5'd14) begin
                EPC <= cp0WriteData;
            end
        end
    end

endmodule