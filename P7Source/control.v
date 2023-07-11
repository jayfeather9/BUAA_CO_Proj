`timescale 1ns / 1ps

/*
Author: Wu Feiyang
Date: 2022/11/10
Time: 17:09
*/

`include "paras.v"

module control(
    input [5:0] OPCode,
    input [5:0] func,
    input [4:0] rs,
    input [4:0] rt,
    
    output reg [3:0] CmpType,
    output reg [3:0] ExtType,
    output reg [2:0] PCSrc,
    
    output reg [4:0] ALUCtrl,
    output reg [1:0] ALUSrc,
    output reg [3:0] MNDType,
    output reg [2:0] MNDUsage,
    output reg [1:0] MNDWE,
    output reg MNDStart,
    
    output reg MemWrite,
    output reg [3:0] MemType,
    
    output reg [2:0] RegDataSrc,
    output reg [2:0] RegDest,
    output reg RegWrite,
    
    output reg [3:0] Tnew,
    output reg [3:0] TuseE,
    output reg [3:0] TuseM,

    output reg [4:0] excCode,
    output reg EXLClr,
    output reg CP0WE,
    output reg eretClear,
    output reg ignoreOv
);

    always @(*) begin
        case (OPCode)
            `OPCODE_RTYPE : begin
                // R type

                CmpType 	<=	    `CMPDEFAULT;
                ExtType 	<=	    `EXTDEFAULT;
                MemWrite    <=      `NO;
                MemType     <=      `MEMDEFAULT;

                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;

                case(func)
                    `FUNCT_JR,
                    `FUNCT_JALR: begin
                        // jr jalr
                        PCSrc       <=      `PCJREG;

                        ALUCtrl     <=      `ALUDEFAULT;
                        ALUSrc      <=      `ALUFROMGPR;
                        MNDType     <=      `MNDTYPEDEFAULT;
                        MNDUsage    <=      `MNDUSEDEFAULT;
                        MNDWE       <=      `MNDNOWRITE;
                        MNDStart    <=      `NO;
                        
                        TuseE       <=      4'd0;
                        TuseM       <=      `TUSEDEFAULT;

                        excCode     <=      `EXCDEFAULT;
                        ignoreOv    <=      `NO;

                        case(func)
                            `FUNCT_JR: begin
                                RegDataSrc  <=      `REGDATANOWRITE;
                                RegDest     <=      `REGA3DEFAULT;
                                RegWrite    <=      `NO;

                                Tnew        <=      `TNEWDEFAULT;
                            end
                            `FUNCT_JALR: begin
                                RegDataSrc 	<=      `REGDATAFROMPCN;
                                RegDest 	<=      `REGA3FROMRD;
                                RegWrite    <=      `YES;
                                
                                Tnew 		<=      4'd3;
                            end
                        endcase
                    end
                    `FUNCT_ADD,
					`FUNCT_ADDU,
                    `FUNCT_SUB,
					`FUNCT_SUBU,
                    `FUNCT_AND,
                    `FUNCT_OR,
                    `FUNCT_NOR,
                    `FUNCT_XOR,
                    `FUNCT_SLT,
                    `FUNCT_SLTU,
                    `FUNCT_SLL,
                    `FUNCT_SLLV,
                    `FUNCT_SRL,
                    `FUNCT_SRLV,
                    `FUNCT_SRA,
                    `FUNCT_SRAV: begin
                        // R Type Calc
                        PCSrc       <=      `PCNORMAL;

                        ALUSrc      <=      `ALUFROMGPR;
                        MNDType     <=      `MNDTYPEDEFAULT;
                        MNDUsage    <=      `MNDUSEDEFAULT;
                        MNDWE       <=      `MNDNOWRITE;
                        MNDStart    <=      `NO;
                        
                        RegDataSrc  <=      `REGDATAFROMALU;
                        RegDest     <=      `REGA3FROMRD;
                        RegWrite    <=      `YES;

                        Tnew        <=      4'd3;
                        TuseE       <=      4'd1;
                        TuseM       <=      4'd1;

                        excCode     <=      `EXCDEFAULT;

                        case(func)
                            `FUNCT_ADDU, `FUNCT_SUBU: ignoreOv    <=      `YES;
                            default: ignoreOv    <=      `NO;
                        endcase
                        
                        case(func)
                            `FUNCT_ADD, `FUNCT_ADDU: ALUCtrl     <=      `ALUADD;
                            `FUNCT_SUB, `FUNCT_SUBU: ALUCtrl     <=      `ALUSUB;
                            `FUNCT_AND: ALUCtrl     <=      `ALUAND;
                            `FUNCT_OR: ALUCtrl     <=      `ALUOR;
                            `FUNCT_NOR: ALUCtrl     <=      `ALUNOR;
                            `FUNCT_XOR: ALUCtrl     <=      `ALUXOR;
                            `FUNCT_SLT: ALUCtrl     <=      `ALUSLT;
                            `FUNCT_SLTU: ALUCtrl     <=      `ALUSLTU;
                            `FUNCT_SLL: ALUCtrl     <=      `ALUSLL;
                            `FUNCT_SLLV: ALUCtrl     <=      `ALUSLLV;
                            `FUNCT_SRL: ALUCtrl     <=      `ALUSRL;
                            `FUNCT_SRLV: ALUCtrl     <=      `ALUSRLV;
                            `FUNCT_SRA: ALUCtrl     <=      `ALUSRA;
                            `FUNCT_SRAV: ALUCtrl     <=      `ALUSRAV;
                            default: ALUCtrl     <=      `ALUDEFAULT;
                        endcase
                    end
                    `FUNCT_MULT,
                    `FUNCT_MULTU,
                    `FUNCT_DIV,
                    `FUNCT_DIVU,
                    `FUNCT_MFHI,
                    `FUNCT_MFLO,
                    `FUNCT_MTHI,
                    `FUNCT_MTLO: begin
                        // R type mult / div
                        PCSrc 		<=      `PCNORMAL;
                        
                        ALUCtrl 	<=      `ALUDEFAULT;
                        ALUSrc 		<=      `ALUFROMGPR;

                        excCode     <=      `EXCDEFAULT;
                        ignoreOv    <=      `NO;
                        
                        case(func)
                            `FUNCT_MULT,
                            `FUNCT_MULTU,
                            `FUNCT_DIV,
                            `FUNCT_DIVU: begin // mult
                                MNDUsage    <=      `MNDUSEDEFAULT;
                                MNDWE       <=      `MNDNOWRITE;
                                MNDStart    <=      `YES;

                                RegDataSrc 	<=      `REGDATANOWRITE;
                                RegDest 	<=      `REGA3DEFAULT;
                                RegWrite    <=      `NO;

                                Tnew 		<=      `TNEWDEFAULT;
                                TuseE 		<=      4'd1;
                                TuseM 		<=      4'd1;
                                case(func)
                                    `FUNCT_MULT: MNDType     <=      `MNDMULT;
                                    `FUNCT_MULTU: MNDType     <=      `MNDMULTU;
                                    `FUNCT_DIV: MNDType     <=      `MNDDIV;
                                    `FUNCT_DIVU: MNDType     <=      `MNDDIVU;
                                    default: MNDType     <=      `MNDTYPEDEFAULT;
                                endcase 
                            end
                            `FUNCT_MFHI,
                            `FUNCT_MFLO: begin // mnd fetch
                                case (func)
                                    `FUNCT_MFHI: MNDUsage    <=      `MNDUSEHI;
                                    `FUNCT_MFLO: MNDUsage    <=      `MNDUSELO;
                                    default: MNDUsage    <=      `MNDUSEDEFAULT;
                                endcase
                                MNDType     <=      `MNDTYPEDEFAULT;
                                MNDWE       <=      `MNDNOWRITE;
                                MNDStart    <=      `NO;

                                RegDataSrc 	<=      `REGDATAFROMALU;
                                RegDest 	<=      `REGA3FROMRD;
                                RegWrite    <=      `YES;

                                Tnew 		<=      4'd3;
                                TuseE 		<=      `TUSEDEFAULT;
                                TuseM 		<=      `TUSEDEFAULT;
                            end
                            `FUNCT_MTHI,
                            `FUNCT_MTLO: begin // mnd write
                                case (func)
                                    `FUNCT_MTHI: MNDWE       <=      `MNDWRITEHI;
                                    `FUNCT_MTLO: MNDWE       <=      `MNDWRITELO;
                                    default: MNDWE       <=      `MNDNOWRITE;
                                endcase
                                MNDType     <=      `MNDTYPEDEFAULT;
                                MNDUsage    <=      `MNDUSEDEFAULT;
                                MNDStart    <=      `NO;

                                RegDataSrc 	<=      `REGDATANOWRITE;
                                RegDest 	<=      `REGA3DEFAULT;
                                RegWrite    <=      `NO;

                                Tnew 		<=      `TNEWDEFAULT;
                                TuseE 		<=      4'd1;
                                TuseM 		<=      `TUSEDEFAULT;
                            end
                            default: begin
                                MNDUsage    <=      `MNDTYPEDEFAULT;
                                MNDWE       <=      `MNDNOWRITE;
                                MNDStart    <=      `NO;
                                
                                RegDataSrc 	<=      `REGDATANOWRITE;
                                RegDest 	<=      `REGA3DEFAULT;
                                RegWrite    <=      `NO;

                                Tnew 		<=      `TNEWDEFAULT;
                                TuseE 		<=      `TUSEDEFAULT;
                                TuseM 		<=      `TUSEDEFAULT;
                                RegWrite    <=      `NO;
                            end
                        endcase
                    end
                    `FUNCT_SYSCALL: begin
                        PCSrc 		<=      `PCNORMAL;
                        
                        ALUCtrl 	<=      `ALUDEFAULT;
                        ALUSrc 		<=      `ALUFROMGPR;
                        MNDType     <=      `MNDTYPEDEFAULT;
                        MNDUsage    <=      `MNDUSEDEFAULT;
                        MNDWE       <=      `MNDNOWRITE;
                        MNDStart    <=      `NO;
                        
                        RegDataSrc 	<=      `REGDATANOWRITE;
                        RegDest 	<=      `REGA3DEFAULT;
                        RegWrite    <=      `NO;
                        
                        Tnew 		<=      `TNEWDEFAULT;
                        TuseE 		<=      `TUSEDEFAULT;
                        TuseM 		<=      `TUSEDEFAULT;

                        excCode     <=      `EXCSYSCALL;
                        ignoreOv    <=      `NO;
                    end
                    `FUNCT_NOP: begin
                        PCSrc 		<=      `PCNORMAL;
                        
                        ALUCtrl 	<=      `ALUDEFAULT;
                        ALUSrc 		<=      `ALUFROMGPR;
                        MNDType     <=      `MNDTYPEDEFAULT;
                        MNDUsage    <=      `MNDUSEDEFAULT;
                        MNDWE       <=      `MNDNOWRITE;
                        MNDStart    <=      `NO;
                        
                        RegDataSrc 	<=      `REGDATANOWRITE;
                        RegDest 	<=      `REGA3DEFAULT;
                        RegWrite    <=      `NO;
                        
                        Tnew 		<=      `TNEWDEFAULT;
                        TuseE 		<=      `TUSEDEFAULT;
                        TuseM 		<=      `TUSEDEFAULT;

                        excCode     <=      `EXCDEFAULT;
                        ignoreOv    <=      `NO;
                    end
                    default: begin
                        PCSrc 		<=      `PCNORMAL;
                        
                        ALUCtrl 	<=      `ALUDEFAULT;
                        ALUSrc 		<=      `ALUFROMGPR;
                        MNDType     <=      `MNDTYPEDEFAULT;
                        MNDUsage    <=      `MNDUSEDEFAULT;
                        MNDWE       <=      `MNDNOWRITE;
                        MNDStart    <=      `NO;
                        
                        RegDataSrc 	<=      `REGDATANOWRITE;
                        RegDest 	<=      `REGA3DEFAULT;
                        RegWrite    <=      `NO;
                        
                        Tnew 		<=      `TNEWDEFAULT;
                        TuseE 		<=      `TUSEDEFAULT;
                        TuseM 		<=      `TUSEDEFAULT;

                        excCode     <=      `EXCRI;
                        ignoreOv    <=      `NO;
                    end
                endcase
            end
            `OPCODE_COP0: begin
                CmpType 	<=      `CMPDEFAULT;
                ExtType 	<=      `EXTDEFAULT;
                
                ALUCtrl 	<=      `ALUDEFAULT;
                ALUSrc 		<=      `ALUFROMGPR;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=      `NO;
                MemType     <=      `MEMDEFAULT;

                ignoreOv    <=      `NO;

                case(func)
                    `FUNCT_NOP: begin
                        EXLClr      <=      `NO;
                        eretClear   <=      `NO;
                        PCSrc 		<=      `PCNORMAL;
                        case(rs)
                            `RS_MFC0: begin
                                RegDataSrc 	<=      `REGDATAFROMCP0;
                                RegDest 	<=      `REGA3FORMFC0;
                                RegWrite    <=      `YES;
                                excCode     <=      `EXCDEFAULT;
                                CP0WE       <=      `NO;

                                Tnew 		<=      4'd4;
                                TuseE 		<=      `TUSEDEFAULT;
                                TuseM 		<=      `TUSEDEFAULT;
                            end
                            `RS_MTC0: begin
                                RegDataSrc 	<=      `REGDATANOWRITE;
                                RegDest 	<=      `REGA3FORMTC0;
                                RegWrite    <=      `NO;
                                excCode     <=      `EXCDEFAULT;
                                CP0WE       <=      `YES;

                                Tnew 		<=      `TNEWDEFAULT;
                                TuseE 		<=      `TUSEDEFAULT;
                                TuseM 		<=      4'd2;
                            end
                            default: begin
                                RegDataSrc 	<=      `REGDATANOWRITE;
                                RegDest 	<=      `REGA3DEFAULT;
                                RegWrite    <=      `NO;
                                excCode     <=      `EXCRI;
                                CP0WE       <=      `NO;

                                Tnew 		<=      `TNEWDEFAULT;
                                TuseE 		<=      `TUSEDEFAULT;
                                TuseM 		<=      `TUSEDEFAULT;
                            end
                        endcase
                    end
                    `FUNCT_ERET: begin
                        PCSrc 		<=      `PCERET;
                        RegDataSrc 	<=      `REGDATANOWRITE;
                        RegDest 	<=      `REGA3DEFAULT;
                        RegWrite    <=      `NO;
                        excCode     <=      `EXCDEFAULT;
                        EXLClr      <=      `YES;
                        CP0WE       <=      `NO;
                        eretClear   <=      `YES;

                        Tnew 		<=      `TNEWDEFAULT;
                        TuseE 		<=      `TUSEDEFAULT;
                        TuseM 		<=      `TUSEDEFAULT;
                    end
                    default: begin
                        PCSrc 		<=      `PCNORMAL;
                        RegDataSrc 	<=      `REGDATANOWRITE;
                        RegDest 	<=      `REGA3DEFAULT;
                        RegWrite    <=      `NO;
                        excCode     <=      `EXCRI;
                        EXLClr      <=      `NO;
                        CP0WE       <=      `NO;
                        eretClear   <=      `NO;

                        Tnew 		<=      `TNEWDEFAULT;
                        TuseE 		<=      `TUSEDEFAULT;
                        TuseM 		<=      `TUSEDEFAULT;
                    end
                endcase
            end
            `OPCODE_LUI: begin
                CmpType 	<=	    `CMPDEFAULT;
                ExtType     <=      `EXTZERO;
                PCSrc 		<=	    `PCNORMAL;
                
                ALUCtrl 	<=	    `ALULUI;
                ALUSrc 		<=	    `ALUFROMIMM;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=	    `NO;
                MemType     <=      `MEMDEFAULT;

                RegDataSrc 	<=	    `REGDATAFROMALU;
                RegDest 	<=	    `REGA3FROMRT;
                RegWrite    <=      `YES;
                
                Tnew 		<=	    4'd3;
                TuseE 		<=	    `TUSEDEFAULT;
                TuseM 		<=	    `TUSEDEFAULT;

                excCode     <=      `EXCDEFAULT;
                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;
                ignoreOv    <=      `NO;
            end
            `OPCODE_ORI,
            `OPCODE_ANDI,
            `OPCODE_ADDI,
            `OPCODE_ADDIU,
            `OPCODE_SLTI,
            `OPCODE_SLTIU,
            `OPCODE_XORI: begin
                // imm calc
                CmpType 	<=	    `CMPDEFAULT;
                PCSrc 		<=	    `PCNORMAL;
                
                ALUSrc 		<=	    `ALUFROMIMM;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=	    `NO;
                MemType     <=      `MEMDEFAULT;

                RegDataSrc 	<=	    `REGDATAFROMALU;
                RegDest 	<=	    `REGA3FROMRT;
                RegWrite    <=      `YES;
                
                Tnew 		<=	    4'd3;
                TuseE 		<=	    4'd1;
                TuseM 		<=	    `TUSEDEFAULT;

                excCode     <=      `EXCDEFAULT;
                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;

                case(OPCode)
                    `OPCODE_ORI: begin // ori
                        ALUCtrl     <=      `ALUOR;
                        ExtType     <=	    `EXTZERO;
                        ignoreOv    <=      `NO;
                    end
                    `OPCODE_ADDI: begin // addi
                        ALUCtrl     <=      `ALUADD;
                        ExtType     <=      `EXTSIGN;
                        ignoreOv    <=      `NO;
                    end
                    `OPCODE_ADDIU: begin // addiu
                        ALUCtrl     <=      `ALUADD;
                        ExtType     <=      `EXTSIGN;
                        ignoreOv    <=      `YES;
                    end
                    `OPCODE_ANDI: begin // andi
                        ALUCtrl     <=      `ALUAND;
                        ExtType     <=      `EXTZERO;
                        ignoreOv    <=      `NO;
                    end
                    `OPCODE_SLTI: begin // slti
                        ALUCtrl     <=      `ALUSLT;
                        ExtType     <=      `EXTSIGN;
                        ignoreOv    <=      `NO;
                    end
                    `OPCODE_SLTIU: begin // sltiu
                        ALUCtrl     <=      `ALUSLTU;
                        ExtType     <=      `EXTSIGN;
                        ignoreOv    <=      `NO;
                    end
                    `OPCODE_XORI: begin // xori
                        ALUCtrl     <=      `ALUXOR;
                        ExtType     <=      `EXTZERO;
                        ignoreOv    <=      `NO;
                    end
                    default: begin
                        ALUCtrl     <=      `ALUDEFAULT;
                        ExtType     <=      `EXTDEFAULT;
                        ignoreOv    <=      `NO;
                    end 
                endcase
            end 
            `OPCODE_LB,
            `OPCODE_LBU,
            `OPCODE_LH,
            `OPCODE_LHU,
            `OPCODE_LW: begin
                // load memory
                CmpType 	<=	    `CMPDEFAULT;
                ExtType 	<=	    `EXTSIGN;
                PCSrc 		<=	    `PCNORMAL;

                ALUCtrl 	<=	    `ALULOADADD; // add
                ALUSrc 		<=	    `ALUFROMIMM;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=	    `NO;
                
                RegDataSrc 	<=	    `REGDATAFROMDM;
                RegDest 	<=	    `REGA3FROMRT;
                RegWrite    <=      `YES;
                
                Tnew 		<=	    4'd4;
                TuseE 		<=	    4'd1;
                TuseM 		<=	    `TUSEDEFAULT;

                excCode     <=      `EXCDEFAULT;
                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;
                ignoreOv    <=      `NO;

                case (OPCode)
                    `OPCODE_LW: MemType <=      `MEMWORD;
                    `OPCODE_LH: MemType <=      `MEMHALFWORD;
                    `OPCODE_LHU: MemType <=     `MEMHALFWORDU;
                    `OPCODE_LB: MemType <=      `MEMBYTE;
                    `OPCODE_LBU: MemType <=     `MEMBYTEU;
                default: MemType <=      `MEMDEFAULT;
                endcase
            end
            `OPCODE_SB,
            `OPCODE_SH,
            `OPCODE_SW: begin
                // save memory
                CmpType 	<=	    `CMPDEFAULT;
                ExtType 	<=	    `EXTSIGN;
                PCSrc 		<=	    `PCNORMAL;
                
                ALUCtrl 	<=	    `ALUSAVEADD; // add
                ALUSrc 		<=	    `ALUFROMIMM;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=	    `YES;
                
                RegDataSrc 	<=	    `REGDATANOWRITE;
                RegDest 	<=	    `REGA3DEFAULT;
                RegWrite    <=      `NO;
                
                Tnew 		<=	    `TNEWDEFAULT;
                TuseE 		<=	    4'd1;
                TuseM 		<=	    4'd2;

                excCode     <=      `EXCDEFAULT;
                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;
                ignoreOv    <=      `NO;

                case (OPCode)
                    `OPCODE_SW: MemType <=      `MEMWORD;
                    `OPCODE_SH: MemType <=      `MEMHALFWORD;
                    `OPCODE_SB: MemType <=      `MEMBYTE;
                    default: MemType <=      `MEMDEFAULT;
                endcase
            end
            `OPCODE_BEQ,
            `OPCODE_BNE,
            `OPCODE_BGELTZ,
            `OPCODE_BGTZ,
            `OPCODE_BLEZ: begin
                // branch (beq)
                ExtType 	<=      `EXTSIGN;
                PCSrc 		<=      `PCBRANCH;

                ALUCtrl 	<=      `ALUDEFAULT; // sub
                ALUSrc 		<=      `ALUFROMGPR;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=      `NO;
                MemType     <=      `MEMDEFAULT;; 
                
                RegDataSrc 	<=      `REGDATANOWRITE;
                RegDest 	<=      `REGA3DEFAULT;
                RegWrite    <=      `NO;
                
                Tnew 		<=      `TNEWDEFAULT;
                TuseE 		<=      4'd0;
                TuseM 		<=      4'd0;

                excCode     <=      `EXCDEFAULT;
                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;
                ignoreOv    <=      `NO;

                case (OPCode)
                    `OPCODE_BEQ: CmpType    <=      `CMPEQUAL;
                    `OPCODE_BNE: CmpType    <=      `CMPNOTEQUAL;
                    `OPCODE_BGTZ: CmpType   <=    `CMPGTZ;
                    `OPCODE_BLEZ: CmpType   <=    `CMPLEZ;
                    `OPCODE_BGELTZ: CmpType <=    (rt == 5'b0) ? `CMPLTZ : 
                                                  (rt == 5'b1) ? `CMPGEZ : `CMPDEFAULT;
                    default: CmpType        <=      `CMPDEFAULT;
                endcase
            end
            `OPCODE_JAL,
            `OPCODE_J: begin
                // jump (jal, j)
                CmpType 	<=      `CMPDEFAULT;
                ExtType 	<=      `EXTZERO;
                PCSrc 		<=      `PCJUMP;
                
                ALUCtrl 	<=      `ALUDEFAULT;
                ALUSrc 		<=      `ALUFROMGPR;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=      `NO;
                MemType     <=      `MEMDEFAULT;
                
                TuseE 		<=      `TUSEDEFAULT;
                TuseM 		<=      `TUSEDEFAULT;

                excCode     <=      `EXCDEFAULT;
                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;
                ignoreOv    <=      `NO;

                case(OPCode)
                    `OPCODE_JAL: begin
                        RegDataSrc 	<=      `REGDATAFROMPCN;
                        RegDest 	<=      `REGA3FROMRA;
                        RegWrite    <=      `YES;
                        Tnew 		<=      4'd3;
                    end
                    `OPCODE_J: begin
                        RegDataSrc 	<=      `REGDATANOWRITE;
                        RegDest 	<=      `REGA3DEFAULT;
                        RegWrite    <=      `NO;
                        Tnew 		<=      `TNEWDEFAULT;
                    end
                endcase
            end
            default: begin
                // others
                CmpType 	<=      `CMPDEFAULT;
                ExtType 	<=      `EXTDEFAULT;
                PCSrc 		<=      `PCNORMAL;
                
                ALUCtrl 	<=      `ALUDEFAULT;
                ALUSrc 		<=      `ALUFROMGPR;
                MNDType     <=      `MNDTYPEDEFAULT;
                MNDUsage    <=      `MNDUSEDEFAULT;
                MNDWE       <=      `MNDNOWRITE;
                MNDStart    <=      `NO;
                
                MemWrite 	<=      `NO;
                MemType     <=      `MEMDEFAULT;
                
                RegDataSrc 	<=      `REGDATANOWRITE;
                RegDest 	<=      `REGA3DEFAULT;
                RegWrite    <=      `NO;
                
                Tnew 		<=      `TNEWDEFAULT;
                TuseE 		<=      `TUSEDEFAULT;
                TuseM 		<=      `TUSEDEFAULT;

                excCode     <=      `EXCRI;
                EXLClr      <=      `NO;
                CP0WE       <=      `NO;
                eretClear   <=      `NO;
                ignoreOv    <=      `NO;
            end
        endcase
    end
endmodule
