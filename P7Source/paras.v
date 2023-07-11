`define     YES             1'b1
`define     NO              1'b0

`define     ALUDEFAULT      5'd31
`define     ALUOR           5'd0
`define     ALUAND          5'd1
`define     ALUADD          5'd2
`define     ALUSUB          5'd3
`define     ALULUI          5'd4
`define     ALUSLT          5'd5
`define     ALUSLTU         5'd6
`define     ALUNOR          5'd7 
`define     ALUXOR          5'd8 
`define     ALUSLL          5'd9 
`define     ALUSLLV         5'd10 
`define     ALUSRL          5'd11 
`define     ALUSRLV         5'd12 
`define     ALUSRA          5'd13 
`define     ALUSRAV         5'd14
`define     ALULOADADD      5'd15
`define     ALUSAVEADD      5'd16

`define     ALUFROMGPR      2'd0
`define     ALUFROMIMM      2'd1
// `define     ALUFROMSMT      2'd2

`define     MNDTYPEDEFAULT      4'd15
`define     MNDMULT         4'd0
`define     MNDMULTU        4'd1
`define     MNDDIV          4'd2
`define     MNDDIVU         4'd3

`define     MNDUSEDEFAULT   3'd0
`define     MNDUSEHI        3'd1
`define     MNDUSELO        3'd2

`define     MNDNOWRITE      2'd0
`define     MNDWRITEHI      2'd1
`define     MNDWRITELO      2'd2

`define     CMPDEFAULT      4'd15
`define     CMPEQUAL        4'd0
`define     CMPNOTEQUAL     4'd1
`define     CMPGTZ          4'd2 
`define     CMPGEZ          4'd3 
`define     CMPLTZ          4'd4 
`define     CMPLEZ          4'd5 

`define     EXTDEFAULT      4'd15
`define     EXTZERO         4'd0
`define     EXTSIGN         4'd1

`define     EXCDEFAULT      5'd0
`define     EXCAdEL         5'd4
`define     EXCAdES         5'd5
`define     EXCSYSCALL      5'd8
`define     EXCRI           5'd10
`define     EXCOV           5'd12

`define     REGDATAFROMALU  3'd0
`define     REGDATAFROMDM   3'd1
`define     REGDATAFROMPCN  3'd2
`define     REGDATAFROMCP0  3'd3
`define     REGDATANOWRITE  3'd7

`define     MEMDEFAULT      4'd15
`define     MEMWORD         4'd0
`define     MEMHALFWORD     4'd1
`define     MEMBYTE         4'd2
`define     MEMHALFWORDU    4'd3 // only for load
`define     MEMBYTEU        4'd4 // only for load

`define     PCNORMAL        3'd0
`define     PCBRANCH        3'd1
`define     PCJUMP          3'd2
`define     PCJREG          3'd3
`define     PCERET          3'd4

`define     REGA3FROMRT     3'd0
`define     REGA3FROMRD     3'd1
`define     REGA3FROMRA     3'd2
`define     REGA3FORMFC0    3'd3
`define     REGA3FORMTC0    3'd4
`define     REGA3DEFAULT    3'd7

`define     OPCODE_RTYPE    6'b00_0000
`define     OPCODE_LUI      6'b00_1111
`define     OPCODE_ADDI     6'b00_1000
`define     OPCODE_ADDIU    6'b00_1001
`define     OPCODE_ANDI     6'b00_1100
`define     OPCODE_ORI      6'b00_1101
`define     OPCODE_SLTI     6'b00_1010
`define     OPCODE_SLTIU    6'b00_1011
`define     OPCODE_XORI     6'b00_1110
`define     OPCODE_LB       6'b10_0000
`define     OPCODE_LBU      6'b10_0100
`define     OPCODE_LH       6'b10_0001
`define     OPCODE_LHU      6'b10_0101
`define     OPCODE_LW       6'b10_0011
`define     OPCODE_SB       6'b10_1000
`define     OPCODE_SH       6'b10_1001
`define     OPCODE_SW       6'b10_1011
`define     OPCODE_BEQ      6'b00_0100
`define     OPCODE_BNE      6'b00_0101
`define     OPCODE_BGELTZ   6'b00_0001
`define     OPCODE_BGTZ     6'b00_0111
`define     OPCODE_BLEZ     6'b00_0110
`define     OPCODE_J        6'b00_0010
`define     OPCODE_JAL      6'b00_0011

`define     OPCODE_COP0     6'b01_0000
`define     RS_MFC0         5'b0_0000
`define     RS_MTC0         5'b0_0100
`define     FUNCT_ERET      6'b01_1000
`define     FUNCT_SYSCALL   6'b00_1100

`define     FUNCT_ADD       6'b10_0000
`define	    FUNCT_ADDU      6'b10_0001
`define     FUNCT_SUB       6'b10_0010
`define     FUNCT_SUBU      6'b10_0011
`define     FUNCT_AND       6'b10_0100
`define     FUNCT_OR        6'b10_0101
`define     FUNCT_NOR       6'b10_0111 
`define     FUNCT_XOR       6'b10_0110 
`define     FUNCT_SLT       6'b10_1010
`define     FUNCT_SLTU      6'b10_1011
`define     FUNCT_SLL       6'b00_0000 
`define     FUNCT_SLLV      6'b00_0100 
`define     FUNCT_SRA       6'b00_0011 
`define     FUNCT_SRAV      6'b00_0111 
`define     FUNCT_SRL       6'b00_0010 
`define     FUNCT_SRLV      6'b00_0110 
`define     FUNCT_NOP       6'b00_0000

`define     FUNCT_MULT      6'b01_1000
`define     FUNCT_MULTU     6'b01_1001
`define     FUNCT_DIV       6'b01_1010
`define     FUNCT_DIVU      6'b01_1011
`define     FUNCT_MFHI      6'b01_0000
`define     FUNCT_MFLO      6'b01_0010
`define     FUNCT_MTHI      6'b01_0001
`define     FUNCT_MTLO      6'b01_0011

`define     FUNCT_JR        6'b00_1000
`define     FUNCT_JALR      6'b00_1001

`define     RT_bltz         5'b00000
`define     RT_bgez         5'b00001


`define     TNEWDEFAULT     4'd0
`define     TUSEDEFAULT     4'd15
`define     REGADDRDEFAULT  5'd0