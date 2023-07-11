`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 10/30
Time: 11:55
*/

`include "paras.v"

module cpu(
    input clk,
    input reset,
    input [31:0] Inst,
    input [31:0] CPUDataIn,
    input [5:0] HWInt,
    output [31:0] InstAddr,
    output [31:0] CPUDataAddr,
    output [31:0] CPUWriteData,
    output [3:0] CPUDataByteEn,
    output requestInt,
    output [31:0] PCM,
    output RegWrite,
    output [4:0] RegAddr,
    output [31:0] RegData,
    output [31:0] PCW,
    output [31:0] MacroPC
);
    // no use position reg
    reg [31:0] BLANK32;
    reg [4:0] BLANK5;

    assign MacroPC = PCM;

// ==============
// Fetch(F) Layer
// ==============

    // Control signal & Inst
    wire [5:0] OPCode, func;
    wire [4:0] rs, rt, rd, shamtF;
    wire [15:0] ImmF;
    wire [25:0] InstrIndexF;
    assign OPCode = Inst[31:26];
    assign rs = Inst[25:21];
    assign rt = Inst[20:16];
    assign rd = Inst[15:11];
    assign shamtF = Inst[10:6];
    assign func = Inst[5:0];
    assign ImmF = Inst[15:0];
    assign InstrIndexF = Inst[25:0];

    // input signals
    wire [4:0] A1F, A2F, A3F;

    // IFU signals
    wire CmpOut;
    wire [31:0] PCNxtF;

    // Controller outputs
    wire MemWriteF, RegWriteF, MNDStartF;
    wire [1:0] ALUSrcF, MNDWEF;
    wire [2:0] PCSrcF, MNDUsageF, RegDestF, RegDataSrcF;
    wire [3:0] ExtTypeF, CmpTypeF, TnewF, TuseEF, TuseMF, MemTypeF, MNDTypeF;
    wire [4:0] ALUCtrlF, excCodeF;
    wire EXLClrF, CP0WEF, eretClearF, ignoreOvF; 

    // HH signals
    wire Froze;
    // wire [3:0] HHFD_TuseE, HHFD_TuseM;
    // wire [4:0] HHFD_A1, HHFD_A2;
    wire [31:0] RD1ForwardD, RD2ForwardD, RD1ForwardE, RD2ForwardE, RegDataM, WDForward;

    assign A3F =    (RegDestF == `REGA3FROMRT) ? rt :
                    (RegDestF == `REGA3DEFAULT) ? 5'd0 :
                    (RegDestF == `REGA3FROMRD) ? rd :
                    (RegDestF == `REGA3FROMRA) ? 5'd31 :
                    (RegDestF == `REGA3FORMFC0) ? rt :
                    (RegDestF == `REGA3FORMTC0) ? 5'd0 :
                    5'd0;

    assign A2F =    (RegDestF == `REGA3FROMRT) ? 5'd0 :
                    (RegDestF == `REGA3DEFAULT) ? rt :
                    (RegDestF == `REGA3FROMRD) ? rt :
                    (RegDestF == `REGA3FROMRA) ? 5'd0 :
                    (RegDestF == `REGA3FORMFC0) ? 5'd0 :
                    (RegDestF == `REGA3FORMTC0) ? rt :
                    5'd0;

    assign A1F =    (RegDestF == `REGA3FORMFC0) ? rd :
                    (RegDestF == `REGA3FORMTC0) ? rd :
                    rs;
    
    // advance definition for ifu
    wire [2:0] PCSrcD;
    wire [15:0] ImmD;
    wire [25:0] InstrIndexD;

    wire [31:0] EPCData;

    ifu InstructionFetchUnit(
        .clk(clk),
        .reset(reset),
        .Froze(Froze),
        .PCSrc(PCSrcD),
        .ALUZero(CmpOut),
        .requestInt(requestInt),
        .PCImm(ImmD),
        .PCInstrIndex(InstrIndexD),
        .PCJumpReg(RD1ForwardD),
        .EPC(EPCData),
        .InstAddr(InstAddr),
        .PCNxt(PCNxtF)
    );

    wire [4:0] IFUExcCode;
    assign IFUExcCode = ((InstAddr[1:0] != 2'b0) || (InstAddr < 32'h3000) || (InstAddr > 32'h6ffc)) ? `EXCAdEL : `EXCDEFAULT;
    wire [5:0] NewOPCode, NewFunc;
    assign NewOPCode = (IFUExcCode == `EXCAdEL) ? `OPCODE_RTYPE : OPCode;
    assign NewFunc = (IFUExcCode == `EXCAdEL) ? `FUNCT_NOP : func;

    wire [4:0] excCodeFOut;
    assign excCodeFOut = IFUExcCode | excCodeF;

    control Controller(
        .OPCode(NewOPCode),
        .func(NewFunc),
        .rs(rs),
        .rt(rt),

    	.CmpType(CmpTypeF),
    	.ExtType(ExtTypeF),
    	.PCSrc(PCSrcF),
    
    	.ALUCtrl(ALUCtrlF),
    	.ALUSrc(ALUSrcF),
        .MNDType(MNDTypeF),
        .MNDUsage(MNDUsageF),
        .MNDWE(MNDWEF),
        .MNDStart(MNDStartF),
    
    	.MemWrite(MemWriteF),
        .MemType(MemTypeF),
    
    	.RegDataSrc(RegDataSrcF),
    	.RegDest(RegDestF),
    	.RegWrite(RegWriteF),
    
    	.Tnew(TnewF),
    	.TuseE(TuseEF),
    	.TuseM(TuseMF),

        .excCode(excCodeF),
        .EXLClr(EXLClrF),
        .CP0WE(CP0WEF),
        .eretClear(eretClearF),
        .ignoreOv(ignoreOvF)
    );

// ===============
// Decode(D) Layer
// ===============

    // Control signals
    wire MemWriteD, RegWriteD, MNDStartD;
    wire [1:0] ALUSrcD, MNDWED; // PCSrcD advanced
    wire [2:0] MNDUsageD, RegDataSrcD;
    wire [3:0] ExtTypeD, CmpTypeD, TnewD, TuseED, TuseMD, MemTypeD, MNDTypeD;
    wire [4:0] ALUCtrlD, excCodeD;
    wire EXLClrD, CP0WED, eretClearD, ignoreOvD, isIDSD; 
   
    // Inst signals
    wire [4:0] A1D, A2D, A3D, shamtD; // ImmD InstrIndexD advanced
    wire [31:0] PCNxtD, ImmExt;
    
    // Data signals
    wire [31:0] RD1D, RD2D;

    // GRF in & out signals
    // these are back from W layer!!!
    // defined in module outputs
    // wire RegWrite; 
    // wire [4:0] RegAddr;
    // wire [31:0] RegData; 

    // pipeline reg FD
    rfd RegisterFetch2Decode(    
    	.CmpType(CmpTypeF),
    	.ExtType(ExtTypeF),
    	.PCSrc(PCSrcF),
    	.ALUCtrl(ALUCtrlF),
    	.ALUSrc(ALUSrcF),
        .MNDType(MNDTypeF),
        .MNDUsage(MNDUsageF),
        .MNDWE(MNDWEF),
        .MNDStart(MNDStartF),
    	.MemWrite(MemWriteF),
        .MemType(MemTypeF),
    	.RegDataSrc(RegDataSrcF),
    	.RegWrite(RegWriteF),
    	.Tnew(TnewF),
    	.TuseE(TuseEF),
    	.TuseM(TuseMF),
    
    	.A3(A3F),
    	.A2(A2F),
    	.A1(A1F),

    	.Imm(ImmF),
    	.InstrIndex(InstrIndexF),
    	.shamt(shamtF),
    	.PCNxt(PCNxtF),

        .excCode(excCodeFOut),
        .EXLClr(EXLClrF),
        .CP0WE(CP0WEF),
        .eretClear(eretClearF),
        .ignoreOv(ignoreOvF),

        .reset(reset),
        .clk(clk),
        .Froze(Froze),
        .eretClearSignal(eretClearD),
        .requestInt(requestInt),
        
    	.CmpTypeOut(CmpTypeD),
    	.ExtTypeOut(ExtTypeD),
    	.PCSrcOut(PCSrcD),
    	.ALUCtrlOut(ALUCtrlD),
    	.ALUSrcOut(ALUSrcD),
        .MNDTypeOut(MNDTypeD),
        .MNDUsageOut(MNDUsageD),
        .MNDWEOut(MNDWED),
        .MNDStartOut(MNDStartD),
    	.MemWriteOut(MemWriteD),
        .MemTypeOut(MemTypeD),
    	.RegDataSrcOut(RegDataSrcD),
    	.RegWriteOut(RegWriteD),
    	.TnewOut(TnewD),
    	.TuseEOut(TuseED),
    	.TuseMOut(TuseMD),
    
    	.A3Out(A3D),
    	.A2Out(A2D),
    	.A1Out(A1D),
    
    	.ImmOut(ImmD),
    	.InstrIndexOut(InstrIndexD),
    	.shamtOut(shamtD),
    	.PCNxtOut(PCNxtD),

        .excCodeOut(excCodeD),
        .EXLClrOut(EXLClrD),
        .CP0WEOut(CP0WED),
        .eretClearOut(eretClearD),
        .ignoreOvOut(ignoreOvD),
        .isIDSOut(isIDSD)
    );
    
    grf GeneralRegisterFile(
        .clk(clk),
        .reset(reset),
        .WE(RegWrite),
        .A1(A1D),
        .A2(A2D),
        .A3(RegAddr),
        .WD(RegData),
        .RD1(RD1D),
        .RD2(RD2D)
    );

    cmp CompareUnit(
        .RD1(RD1ForwardD),
        .RD2(RD2ForwardD),
        .CmpType(CmpTypeD),
        .CmpOut(CmpOut)
    );

    ext ExtendUnit(
        .Imm(ImmD),
        .ExtType(ExtTypeD),
        .ExtOut(ImmExt)
    );

// ================
// Execute(E) Layer
// ================

    // Control signals  
    wire MemWriteE, RegWriteE, MNDStartE;
    wire [1:0] ALUSrcE, MNDWEE;
    wire [2:0] MNDUsageE, RegDataSrcE;
    wire [3:0] TnewE, TuseEE, TuseME, MemTypeE, MNDTypeE;
    wire [4:0] ALUCtrlE, excCodeE;
    wire EXLClrE, CP0WEE, ignoreOvE, isIDSF;

    // Inst signals
    wire [4:0] A1E, A2E, A3E, shamtE; 

    // Data signals
    wire [31:0] RD1E, RD2E, PCNxtE, ImmE;

    // ALU signals
    wire [31:0] ALUCalcSrcB, ALUResultE;

    // MND signals
    wire MNDBusyE;
    wire [31:0] MNDLOE, MNDHIE;

    // PipeReg signals
    wire [31:0] ExeResultE;

    rde RegisterDecode2Execute(
    	.ALUCtrl(ALUCtrlD),
    	.ALUSrc(ALUSrcD),
        .MNDType(MNDTypeD),
        .MNDUsage(MNDUsageD),
        .MNDWE(MNDWED),
        .MNDStart(MNDStartD),
    	.MemWrite(MemWriteD),
    	.MemType(MemTypeD),
    	.RegDataSrc(RegDataSrcD),

    	.RegWrite(RegWriteD),
    	.Tnew(TnewD),
    	.TuseE(TuseED),
    	.TuseM(TuseMD),
    
    	.A3(A3D),
    	.A2(A2D),
    	.A1(A1D),

    	.Imm(ImmExt), // not ImmD!
    	.shamt(shamtD),
    	.PCNxt(PCNxtD),

        .excCode(excCodeD),
        .EXLClr(EXLClrD),
        .CP0WE(CP0WED),
        .ignoreOv(ignoreOvD),
        .isIDS(isIDSD),
        .requestInt(requestInt),

    	.RD1(RD1ForwardD),
    	.RD2(RD2ForwardD),
       
        .reset(reset),
        .clk(clk),
        .Froze(Froze),

    	.ALUCtrlOut(ALUCtrlE),
    	.ALUSrcOut(ALUSrcE),
        .MNDTypeOut(MNDTypeE),
        .MNDUsageOut(MNDUsageE),
        .MNDWEOut(MNDWEE),
        .MNDStartOut(MNDStartE),
    	.MemWriteOut(MemWriteE),
    	.MemTypeOut(MemTypeE),
    	.RegDataSrcOut(RegDataSrcE),

    	.RegWriteOut(RegWriteE),
    	.TnewOut(TnewE),
    	.TuseEOut(TuseEE),
    	.TuseMOut(TuseME),
    
    	.A3Out(A3E),
    	.A2Out(A2E),
    	.A1Out(A1E),
    
    	.ImmOut(ImmE),
    	.shamtOut(shamtE),
    	.PCNxtOut(PCNxtE),

    	.RD1Out(RD1E),
    	.RD2Out(RD2E),
            
        .excCodeOut(excCodeE),
        .EXLClrOut(EXLClrE),
        .CP0WEOut(CP0WEE),
        .ignoreOvOut(ignoreOvE),
        .isIDSOut(isIDSF)
    );

    // `define     ALUFROMGPR      2'd0
    // `define     ALUFROMIMM      2'd1
    // `define     ALUFROMSMT      2'd2

    // ALUCalcSrcB
    mux32D2S ALUSrcALUSrcBMUXE(
        .select(ALUSrcE),
        .in0(RD2ForwardE),
        .in1(ImmE),
        .in2(BLANK32),
        .in3(BLANK32),
        .out(ALUCalcSrcB)
    );

    // `define     MNDUSEDEFAULT   3'd0
    // `define     MNDUSEHI        3'd1
    // `define     MNDUSELO        3'd2
    mux32D3S MNDUsageExeResultEMUXE(
        .select(MNDUsageE),
        .in0(ALUResultE),
        .in1(MNDHIE),
        .in2(MNDLOE),
        .out(ExeResultE)
    );

    wire ALUOverflowSignal;
    wire [4:0] excCodeEOut, ALUExcCode;

    alu ArthmeticLogicUnit(
        .SrcA(RD1ForwardE),
        .SrcB(ALUCalcSrcB),
        .shamt(shamtE),
        .ALUCtrl(ALUCtrlE),
        .ignoreOv(ignoreOvE),
        .ALUResult(ALUResultE),
        .excCode(ALUExcCode)
    );

    mnd MultiplyAndDiviseUnit(
        .clk(clk),
        .reset(reset),
        .start(MNDStartE),
        .requestInt(requestInt),
        .MNDWE(MNDWEE),
        .MNDType(MNDTypeE),
        .RD1(RD1ForwardE),
        .RD2(RD2ForwardE),
        .busy(MNDBusyE),
        .HI(MNDHIE),
        .LO(MNDLOE)
    );

    assign excCodeEOut = ALUExcCode | excCodeE;

// ================
// Memory(M) Layer
// ================

    // Control signals  
    wire MemWriteM, RegWriteM;
    wire [2:0] RegDataSrcM;
    wire [3:0] TnewM, TuseMM, MemTypeM;
    wire [4:0] excCodeM;
    wire EXLClrM, CP0WEM, isIDSM;

    // Inst signals
    wire [4:0] A1M, A2M, A3M; 

    // Data signals
    wire [31:0] ExeResultM, RD2M, PCNxtM, DMDataM;

    rem RegisterExecute2Memory(
    	.MemWrite(MemWriteE),
    	.MemType(MemTypeE),
    	.RegDataSrc(RegDataSrcE),

    	.RegWrite(RegWriteE),

    	.Tnew(TnewE),
    	.TuseM(TuseME),
    
    	.A3(A3E),
    	.A2(A2E),
        .A1(A1E),

    	.RD2(RD2ForwardE),

    	.ExeResult(ExeResultE),
    	.PCNxt(PCNxtE),

        .excCode(excCodeEOut),
        .EXLClr(EXLClrE),
        .CP0WE(CP0WEE),
        .isIDS(isIDSF),
    
        .reset(reset),
        .clk(clk),
        .requestInt(requestInt),

    	.MemWriteOut(MemWriteM),
    	.MemTypeOut(MemTypeM),
    	.RegDataSrcOut(RegDataSrcM),

    	.RegWriteOut(RegWriteM),

    	.TnewOut(TnewM),
    	.TuseMOut(TuseMM),
    
    	.A3Out(A3M),
    	.A2Out(A2M),
        .A1Out(A1M),

    	.RD2Out(RD2M),

    	.ExeResultOut(ExeResultM),
    	.PCNxtOut(PCNxtM),

        .excCodeOut(excCodeM),
        .EXLClrOut(EXLClrM),
        .CP0WEOut(CP0WEM),
        .isIDSOut(isIDSM)
    );

    wire isChangingA3;
    wire [4:0] changedA3, A3M_new;

    wire [4:0] excCodeMOut, DMExcCode;
    assign excCodeMOut = excCodeM | DMExcCode;

    dmio DataMemoryInputOutput(
        .MemType(MemTypeM),
        .Addr(ExeResultM),
        .WD(WDForward),
        .WE(MemWriteM),
        .requestInt(requestInt),
        .dataIn(CPUDataIn),
        .CPUDataAddr(CPUDataAddr),
        .CPUWriteData(CPUWriteData),
        .CPUDataByteEn(CPUDataByteEn),
        .RD(DMDataM),
        .isChangingA3(isChangingA3),
        .changedA3(changedA3),
        .excCode(DMExcCode)
    );

    assign A3M_new = (isChangingA3 == 1'b1) ? changedA3 : A3M;
    
    assign PCM = PCNxtM - 8;

    wire [31:0] CP0ReadDataM;

    cp0 CoProcessor0(
        .clk(clk),
        .reset(reset),
        .WE(CP0WEM),
        .cp0Addr(A1M),
        .cp0WriteData(WDForward),
        .VPC(PCM),
        .isInDelayedSlot(isIDSM),
        .exceptionCode(excCodeMOut),
        .HWInt(HWInt),
        .EXLClr(EXLClrM),
        .cp0ReadData(CP0ReadDataM),
        .EPCData(EPCData),
        .requestInt(requestInt)
    );

//==================
// Writeback(W) Layer
//==================

    // Control signals  
    wire RegWriteW;
    wire [2:0] RegDataSrcW;
    wire [3:0] TnewW;

    // Inst signals
    wire [4:0] A3W; 

    // Data signals
    wire [31:0] ExeResultW, PCNxtW, DMDataW, CP0ReadDataW;
    
    rmw RegisterMemory2Writeback(
    	.RegDataSrc(RegDataSrcM),
    	.RegWrite(RegWriteM),

    	.Tnew(TnewM),
    
    	.A3(A3M_new),

    	.ExeResult(ExeResultM),
    	.PCNxt(PCNxtM),
    	.DMData(DMDataM),
        .CP0ReadData(CP0ReadDataM),

        .reset(reset),
        .clk(clk),
        .requestInt(requestInt),

    	.RegDataSrcOut(RegDataSrcW),
    	.RegWriteOut(RegWriteW),

    	.TnewOut(TnewW),
    
    	.A3Out(A3W),

    	.ExeResultOut(ExeResultW),
    	.PCNxtOut(PCNxtW),
    	.DMDataOut(DMDataW),
        .CP0ReadDataOut(CP0ReadDataW)
    );

    assign RegWrite = RegWriteW;
    assign RegAddr = A3W; 
    // assign w_grf_we = RegWrite;
    // assign w_grf_addr = RegAddr;
    // assign w_grf_wdata = RegData;
    assign PCW = PCNxtW - 8;

    // `define     REGDATAFROMALU  3'd0
    // `define     REGDATAFROMDM   3'd1
    // `define     REGDATAFROMPCN  3'd2
    // `define     REGDATAFROMCP0  3'd3
    // `define     REGDATANOWRITE  3'd7

    // RegData
    mux32D3S RegDataSrcRegDataMUXW(
        .select(RegDataSrcW),
        .in0(ExeResultW),
        .in1(DMDataW),
        .in2(PCNxtW),
        .in3(CP0ReadDataW),
        .out(RegData)
    );

//================
// Hazard Handling
//================

    // RegDataM
    mux32D3S RegDataSrcMRegDataMMUXW(
        .select(RegDataSrcM),
        .in0(ExeResultM),
        .in2(PCNxtM),
        .out(RegDataM)
    );

    wire MNDRealBusy;
    assign MNDRealBusy = MNDBusyE | MNDStartE;

    hh HazardHandlingModule(
        .clk(clk),
        .reset(reset),
        
        .FD_TuseE(TuseED),
    	.FD_TuseM(TuseMD),
    	.FD_A1(A1D),
    	.FD_A2(A2D),
    	.FD_A3(A3D),
    	.FD_RD1(RD1D),
    	.FD_RD2(RD2D),
    	.FD_Tnew(TnewD),
    	.FD_RegWrite(RegWriteD),
        .FD_MNDUsage(MNDUsageD),
        .FD_MNDWE(MNDWED),
        .FD_ERET(eretClearD),

    	.DE_TuseE(TuseEE),
    	.DE_TuseM(TuseME),
    	.DE_A1(A1E),
    	.DE_A2(A2E),
    	.DE_A3(A3E),
    	.DE_RD1(RD1E),
    	.DE_RD2(RD2E),
    	.DE_Tnew(TnewE),
    	.DE_RegWrite(RegWriteE),
        .DE_MemType(MemTypeE),

        .MND_Busy(MNDRealBusy),
    
    	.EM_TuseM(TuseMM),
    	.EM_A2(A2M),
    	.EM_A3(A3M),
    	.EM_RD2(RD2M),
    	.EM_Tnew(TnewM),
    	.EM_RegWrite(RegWriteM),
    	.EM_RegData(RegDataM),
        .EM_MemType(MemTypeM),
    
    	.MW_Tnew(TnewW),
    	.MW_RegWrite(RegWriteW),
    	.MW_A3(A3W),
    	.MW_RegData(RegData),

    	.Froze(Froze),
    	.RD1ForwardD(RD1ForwardD),
    	.RD2ForwardD(RD2ForwardD),
    	.RD1ForwardE(RD1ForwardE),
    	.RD2ForwardE(RD2ForwardE),
    	.WDForward(WDForward)
    );

    always @(posedge clk) begin
        if (!reset)begin
            // $display("A1F %d A2F %d A3F %d", A1F, A2F, A3F);
            // $display("HHFD_A1 %d HHFD_A2 %d", HHFD_A1, HHFD_A2);
            // $display("A1D %d A2D %d A3D %d", A1D, A2D, A3D);
            // $display("RD1D %h RD2D %h RD1FwdD %h RD2FwdD %h", RD1D, RD2D, RD1ForwardD, RD2ForwardD);
            // $display("PCSrcF %d PCSrcD %d", PCSrcF, PCSrcD);
            // $display("PCF %h PCD %h PCE %h\nPCM %h PCW %h",
            // PCNxtF-8, PCNxtD-8, PCNxtE-8, PCNxtM-8, PCNxtW-8);
            // $display("A1E %d A2E %d A3E %d",A1E,A2E,A3E);
            // $display("RD1E %h RD2E %h RD1FwdE %h RD2FwdE %h", RD1E, RD2E, RD1ForwardE, RD2ForwardE);
            
            // $display("A2M %d A3M %d MemWriteM %d RegWriteM %d RegDataM %h", 
            // A2M, A3M, MemWriteM, RegWriteM, RegDataM);

            // $display("A3W %d RegWriteW %d RegData %h", A3W, RegWriteW, RegData);
            // $display("TuseED %d TuseMD %d TnewE %d TnewM %d", TuseED, TuseMD, TnewE, TnewM);

            // $display("TuseEE %d TuseME %d TnewE %d TnewM %d", TuseEE, TuseME, TnewE, TnewM);
            // if (PCSrcD != 2'b00) begin
            //     $display("%h=>Jump or Branch", PCNxtD-8);
            // end
            // if (CmpTypeD != 4'd15)begin
            //     $display("A1D %d A2D %d", A1D, A2D);
            //     $display("RD1FwdD %h RD2FwdD %h CmpType %d CmpOut %d", RD1ForwardD, RD2ForwardD, CmpTypeD, CmpOut);
            // end
            // $display("%h========================================",PCNxtW-8);
            // if (RegWrite && !reset) begin
            //     $display("%d@%h: $%d <= %h", $time, PCNxtW-8, RegAddr, RegData);
            // end
            // if (MemWriteM && !reset) begin
            //     $display("%d@%h: *%h <= %h", $time, PCNxtM-8, ExeResultM, WDForward);
            // end
            // $display("========================================");
            // $display("excCodeMOut = %h", excCodeMOut);
        end
    end

endmodule
