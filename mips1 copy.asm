.text
ori $0, $0, 0x7312
ori $1, $0, 0x3555
ori $2, $0, 0x5123
ori $3, $0, 0x1234
ori $4, $0, 0x5678
ori $5, $0, 0x9abc
ori $6, $0, 0xdef0
sw $1, 0x7f00($0)
sb $1, 0x7f00($0)
sh $1, 0x7f00($0)
sw $1, 0x7f01($0)
sb $1, 0x7f01($0)
sh $1, 0x7f01($0)
sw $1, 0x7f02($0)
sb $1, 0x7f02($0)
sh $1, 0x7f02($0)
sw $1, 0x7f08($0)
sb $1, 0x7f08($0)
sh $1, 0x7f08($0)
sw $1, 0x7f0b($0)
sb $1, 0x7f0b($0)
sh $1, 0x7f0b($0)
sw $1, 0x7f0c($0)
sb $1, 0x7f0c($0)
sh $1, 0x7f0c($0)
sw $1, 0x7f0f($0)
sb $1, 0x7f0f($0)
sh $1, 0x7f0f($0)
sw $1, 0x7fff($0)
sb $1, 0x7fff($0)
sh $1, 0x7fff($0)
sw $1, 0x7f1b($0)
sb $1, 0x7f1b($0)
sh $1, 0x7f1b($0)
sw $1, 0x7f1c($0)
sb $1, 0x7f1c($0)
sh $1, 0x7f1c($0)
sw $1, 0x7f10($0)
sb $1, 0x7f10($0)
sh $1, 0x7f10($0)
sw $1, 0x7f11($0)
sb $1, 0x7f11($0)
sh $1, 0x7f11($0)
sw $1, 0x7f20($0)
j EndOfAll			# 000030b0
nop

.ktext 0x4180
start:
mfc0 $t0, $14			# 000030b4
addi $t0, $t0, 4			# 000030b8
mtc0 $t0, $14			# 000030bc
eret			# 000030c0
jal start			# 000030c4
ori $1, $1, 1
EndOfAll:
ori $4, $0, 3
ori $3, $0, 5
nop
nop
nop
nop
nop

