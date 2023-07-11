ori $s0,$s0,0x8fff
ori $s1,$s1,0x3002
ori $s2,$s2,0x2ff8
ori $s3,$s3,0x77f8
la $s6,test_RI
la $s7,test_RI_1
mfc0 $k0,$14
mfc0 $k1,$13
mfc0 $s4,$12
sw $s4,($sp)
addi $sp,$sp,4
sw $k0,($sp)
addi $sp,$sp,4
sw $k1,($sp)
addi $sp,$sp,4
test_RI:
test_RI_1: