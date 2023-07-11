`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/12/14
Time: 12:14
*/

module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);

    wire [5:0] HWInt;
    wire requestInt;
    wire [31:0] CPUAddr, CPUDataIn, CPUWriteData;
    wire [3:0] CPUByteEn;

    assign m_data_wdata = CPUWriteData;

    cpu cpu_inst(
        .clk(clk),
        .reset(reset),
        .Inst(i_inst_rdata),
        .CPUDataIn(CPUDataIn),
        .HWInt(HWInt),
        .InstAddr(i_inst_addr),
        .CPUDataAddr(CPUAddr),
        .CPUWriteData(CPUWriteData),
        .CPUDataByteEn(CPUByteEn),
        .requestInt(requestInt),
        .PCM(m_inst_addr),
        .RegWrite(w_grf_we),
        .RegAddr(w_grf_addr),
        .RegData(w_grf_wdata),
        .PCW(w_inst_addr),
        .MacroPC(macroscopic_pc)
    );

    wire [31:0] TC0Data, TC1Data;
    wire [31:2] TC0Addr, TC1Addr;
    wire TC0WE, TC1WE, TC0IRQ, TC1IRQ;

    assign HWInt[5:3] = 3'b0;
    assign HWInt[2] = interrupt;
    assign HWInt[1] = TC1IRQ;
    assign HWInt[0] = TC0IRQ;

    bridge bridge_inst(
        .CPUAddr(CPUAddr),
        .CPUByteEn(CPUByteEn),
        .DMData(m_data_rdata),
        .TC0Data(TC0Data),
        .TC1Data(TC1Data),
        .DMAddr(m_data_addr),
        .DMByteEn(m_data_byteen),
        .TC0Addr(TC0Addr),
        .TC0WE(TC0WE),
        .TC1Addr(TC1Addr),
        .TC1WE(TC1WE),
        .INTAddr(m_int_addr),
        .INTByteEn(m_int_byteen),
        .CPUData(CPUDataIn)
    );

    timer TC0(
        .clk(clk),
        .reset(reset),
        .Addr(TC0Addr),
        .WE(TC0WE),
        .Din(CPUWriteData),
        .Dout(TC0Data),
        .IRQ(TC0IRQ)
    );

    timer TC1(
        .clk(clk),
        .reset(reset),
        .Addr(TC1Addr),
        .WE(TC1WE),
        .Din(CPUWriteData),
        .Dout(TC1Data),
        .IRQ(TC1IRQ)
    );

endmodule