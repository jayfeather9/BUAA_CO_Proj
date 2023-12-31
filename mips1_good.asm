andi $sp,$sp,0			# 00003000
ori $sp,$sp,0x10			# 00003004
jal test_AdES			# 00003008
nop			# 0000300c
jal test_AdEL			# 00003010
nop			# 00003014
jal test_Syscall			# 00003018
nop			# 0000301c
jal test_RI			# 00003020
nop			# 00003024
jal test_Ov			# 00003028
nop			# 0000302c
jal test_specials			# 00003030
nop			# 00003034
jal End			# 00003038
nop			# 0000303c
test_AdES:
lui $1, 0x7fff			# 00003040
sw $2, 0x7fff($1)			# 00003044
sh $2, 0x7fff($1)			# 00003048
sb $2, 0x7fff($1)			# 0000304c
sw $2, 0x7fff($0)			# 00003050
sw $2, 0x3004($0)			# 00003054
sw $2, 0x7f24($0)			# 00003058
sw $2, 0x7f98($0)			# 0000305c
sw $2, 0x4184($0)			# 00003060
sh $2, 0x7fff($0)			# 00003064
sh $2, 0x3004($0)			# 00003068
sh $2, 0x7f24($0)			# 0000306c
sh $2, 0x7f98($0)			# 00003070
sh $2, 0x4184($0)			# 00003074
sb $2, 0x7fff($0)			# 00003078
sb $2, 0x3004($0)			# 0000307c
sb $2, 0x7f24($0)			# 00003080
sb $2, 0x7f98($0)			# 00003084
sb $2, 0x4184($0)			# 00003088
sw $2, 0x7f08($0)			# 0000308c
sw $2, 0x7f18($0)			# 00003090
sh $2, 0x7f08($0)			# 00003094
sh $2, 0x7f18($0)			# 00003098
sb $2, 0x7f08($0)			# 0000309c
sb $2, 0x7f18($0)			# 000030a0
sh $2, 0x7f00($0)			# 000030a4
sh $2, 0x7f02($0)			# 000030a8
sh $2, 0x7f10($0)			# 000030ac
sh $2, 0x7f12($0)			# 000030b0
sb $2, 0x7f00($0)			# 000030b4
sb $2, 0x7f02($0)			# 000030b8
sb $2, 0x7f10($0)			# 000030bc
sb $2, 0x7f12($0)			# 000030c0
sw $2, 0x1($0)			# 000030c4
sw $2, 0x2($0)			# 000030c8
sw $2, 0x3($0)			# 000030cc
sh $2, 0x1($0)			# 000030d0
sh $2, 0x3($0)			# 000030d4
jr $ra			# 000030d8
nop			# 000030dc
test_AdEL:
lui $1, 0x7fff			# 000030e0
lw $2, 0x7fff($1)			# 000030e4
lh $2, 0x7fff($1)			# 000030e8
lb $2, 0x7fff($1)			# 000030ec
lw $2, 0x7fff($0)			# 000030f0
lw $2, 0x3004($0)			# 000030f4
lw $2, 0x7f24($0)			# 000030f8
lw $2, 0x7f98($0)			# 000030fc
lw $2, 0x4184($0)			# 00003100
lh $2, 0x7fff($0)			# 00003104
lh $2, 0x3004($0)			# 00003108
lh $2, 0x7f24($0)			# 0000310c
lh $2, 0x7f98($0)			# 00003110
lh $2, 0x4184($0)			# 00003114
lb $2, 0x7fff($0)			# 00003118
lb $2, 0x3004($0)			# 0000311c
lb $2, 0x7f24($0)			# 00003120
lb $2, 0x7f98($0)			# 00003124
lb $2, 0x4184($0)			# 00003128
lh $2, 0x7f00($0)			# 0000312c
lh $2, 0x7f02($0)			# 00003130
lh $2, 0x7f10($0)			# 00003134
lh $2, 0x7f12($0)			# 00003138
lb $2, 0x7f00($0)			# 0000313c
lb $2, 0x7f02($0)			# 00003140
lb $2, 0x7f10($0)			# 00003144
lb $2, 0x7f12($0)			# 00003148
lw $2, 0x1($0)			# 0000314c
lw $2, 0x2($0)			# 00003150
lw $2, 0x3($0)			# 00003154
lh $2, 0x1($0)			# 00003158
lh $2, 0x3($0)			# 0000315c
wPC1:
andi $1, $1, 0x0			# 00003160
ori $1, $1, 0x8fff			# 00003164
jr $1			# 00003168
nop			# 0000316c
wPC2:
andi $1, $1, 0x0			# 00003170
ori $1, $1, 0x3002			# 00003174
jr $1			# 00003178
nop			# 0000317c
wPC3:
andi $1, $1, 0x0			# 00003180
ori $1, $1, 0x2ff8			# 00003184
jr $1			# 00003188
nop			# 0000318c
wPC4:
andi $1, $1, 0x0			# 00003190
ori $1, $1, 0x77f8			# 00003194
jr $1			# 00003198
nop			# 0000319c
test_wPC_end:
jr $ra			# 000031a0
nop			# 000031a4
test_Syscall:
syscall			# 000031a8
jr $ra			# 000031ac
nop			# 000031b0
test_RI:
lhu $0,($0)			# 000031b4
beq $0,$0,RI1			# 000031b8
nop			# 000031bc
test_RI_1:
lhu $0($0)			# 000031c0
beq $0,$0,RI2			# 000031c4
nop			# 000031c8
test_RI_End:
jr $ra			# 000031cc
nop			# 000031d0
test_Ov:
andi $1, $1, 0x0			# 000031d4
lui $1, 0x7fff			# 000031d8
add $1, $1, $1			# 000031dc
addi $1, $1, 0x7fff			# 000031e0
lui $1, 0x7fff			# 000031e4
lui $2, 0x8001			# 000031e8
sub $1, $1, $1			# 000031ec
jr $ra			# 000031f0
nop			# 000031f4
test_specials:
mult $1, $1			# 000031f8
nop			# 000031fc
multu $1, $1			# 00003200
nop			# 00003204
div $1, $1			# 00003208
nop			# 0000320c
divu $1, $1			# 00003210
nop			# 00003214
mfhi $1			# 00003218
nop			# 0000321c
mflo $1			# 00003220
nop			# 00003224
mthi $1			# 00003228
nop			# 0000322c
mtlo $1			# 00003230
nop			# 00003234
beq $0, $0, epc1			# 00003238
lw $2, 0x3($0)			# 0000323c
epc1:
beq $0, $0, epc2			# 00003240
lw $2, 0x3($0)			# 00003244
epc2:
beq $0, $0, epc3			# 00003248
lw $2, 0x3($0)			# 0000324c
epc3:
lw $1, 0x4($0)			# 00003250
sw $1, 0x4($0)			# 00003254
lw $1, 0x4($0)			# 00003258
addi $1, $1, 0x1			# 0000325c
jr $ra			# 00003260
nop			# 00003264
End:
beq $0, $0,EndOfAll			# 00003268
nop			# 0000326c


RI1:
andi $k0,$k0,0			# 00003270
andi $k1,$k1,0			# 00003274
andi $s4,$s4,0			# 00003278
la $k0,test_RI			# 0000327c
ori $k1,$k1,0x28			# 00003280
ori $s4,$s4,0x2			# 00003284
sw $s4,($sp)			# 00003288
addi $sp,$sp,4			# 0000328c
sw $k0,($sp)			# 00003290
addi $sp,$sp,4			# 00003294
sw $k1,($sp)			# 00003298
addi $sp,$sp,4			# 0000329c
j test_RI_1			# 000032a0
nop			# 000032a4
RI2:
andi $k0,$k0,0			# 000032a8
andi $k1,$k1,0			# 000032ac
andi $s4,$s4,0			# 000032b0
la $k0,test_RI_1			# 000032b4
ori $k1,$k1,0x28			# 000032b8
ori $s4,$s4,0x2			# 000032bc
sw $s4,($sp)			# 000032c0
addi $sp,$sp,4			# 000032c4
sw $k0,($sp)			# 000032c8
addi $sp,$sp,4			# 000032cc
sw $k1,($sp)			# 000032d0
addi $sp,$sp,4			# 000032d4
j test_RI_End			# 000032d8
nop			# 000032dc

.ktext 0x4180
ori $s0,$s0,0x8fff			# 000032e0
ori $s1,$s1,0x3002			# 000032e4
ori $s2,$s2,0x2ff8			# 000032e8
ori $s3,$s3,0x77f8			# 000032ec
la $s6,test_RI			# 000032f0
la $s7,test_RI_1			# 000032f4
mfc0 $k0,$14			# 000032f8
mfc0 $k1,$13			# 000032fc
mfc0 $s4,$12			# 00003300
sw $s4,($sp)			# 00003304
addi $sp,$sp,4			# 00003308
sw $k0,($sp)			# 0000330c
addi $sp,$sp,4			# 00003310
sw $k1,($sp)			# 00003314
addi $sp,$sp,4			# 00003318
beq $k0,$s0,return0			# 0000331c
nop			# 00003320
beq $k0,$s1,return1			# 00003324
nop			# 00003328
beq $k0,$s2,return2			# 0000332c
nop			# 00003330
beq $k0,$s3,return3			# 00003334
nop			# 00003338
beq $k0,$s6,return4			# 0000333c
nop			# 00003340
beq $k0,$s7,return5			# 00003344
add $k0,$k0,4			# 00003348
mtc0 $k0,$14			# 0000334c
eret			# 00003350
ori $10,$10,5			# 00003354
return0:
la $s5,wPC2			# 00003358
mtc0 $s5,$14			# 0000335c
eret			# 00003360
return1:
la $s5,wPC3			# 00003364
mtc0 $s5,$14			# 00003368
eret			# 0000336c
return2:
la $s5,wPC4			# 00003370
mtc0 $s5,$14			# 00003374
eret			# 00003378
return3:
la $s5,test_wPC_end			# 0000337c
mtc0 $s5,$14			# 00003380
eret			# 00003384
return4:
la $s5,test_RI_1			# 00003388
mtc0 $s5,$14			# 0000338c
eret			# 00003390
return5:
la $s5,test_RI_End			# 00003394
mtc0 $s5,$14			# 00003398
eret			# 0000339c
EndOfAll:
