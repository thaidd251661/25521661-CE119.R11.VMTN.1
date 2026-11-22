.data
s1:     .asciiz "kien truc may tinh"
s2:     .asciiz "mips"
s3:     .asciiz ""
s4:     .asciiz "a bc def"
sd:     .asciiz "moi thu tuc co mot khung ngan xep"
bar:    .asciiz "|"
nl:     .asciiz "\n"

.text
.globl main
main:
        # Test 1: "kien truc may tinh"
        la    $a0, s1
        jal   test_case

        # Test 2: "mips"
        la    $a0, s2
        jal   test_case

        # Test 3: "" 
        la    $a0, s3
        jal   test_case

        # Test 4: "a bc def"
        la    $a0, s4
        jal   test_case

        # Test 5: S(1)
        la    $a0, sd
        jal   test_case

        li    $v0, 10
        syscall

# test_case: goi reverse_words va in chuoi giua hai dau |
# Tham so  : $a0 = dia chi chuoi
# Tra ve   : khong
# Thanh ghi: $s0, $ra
test_case:
        addi  $sp, $sp, -8
        sw    $ra, 4($sp)
        sw    $s0, 0($sp)

        move  $s0, $a0          # luu dia chi chuoi
        jal   reverse_words     # dao thu tu tu tai cho

        li    $v0, 4
        la    $a0, bar
        syscall

        move  $a0, $s0
        syscall

        la    $a0, bar
        syscall

        la    $a0, nl
        syscall

        lw    $s0, 0($sp)
        lw    $ra, 4($sp)
        addi  $sp, $sp, 8
        jr    $ra

# strlen: tinh do dai chuoi .asciiz (thu tuc la)
# Tham so  : $a0 = dia chi chuoi
# Tra ve   : $v0 = so ky tu truoc byte 0
# Thanh ghi: $t0, $t1
strlen:
        move  $t0, $a0          # con tro duyet
sl_loop:
        lbu   $t1, 0($t0)
        beq   $t1, $zero, sl_done
        addiu $t0, $t0, 1
        j     sl_loop
sl_done:
        subu  $v0, $t0, $a0     # do dai = end - start
        jr    $ra

# rev_range: dao tai cho doan [$a0, $a1] (thu tuc la)
# Tham so  : $a0 = dia chi ky tu dau, $a1 = dia chi ky tu cuoi
# Tra ve   : khong
# Thanh ghi: $t0, $t1
rev_range:
rr_loop:
        bgeu  $a0, $a1, rr_done # dung khi $a0 >= $a1 (so sanh khong dau)
        lbu   $t0, 0($a0)
        lbu   $t1, 0($a1)
        sb    $t1, 0($a0)
        sb    $t0, 0($a1)
        addiu $a0, $a0, 1
        addiu $a1, $a1, -1
        j     rr_loop
rr_done:
        jr    $ra

# reverse_words: dao thu tu cac tu tai cho (thu tuc khong la)
# Tham so  : $a0 = dia chi chuoi
# Tra ve   : khong
# Thanh ghi: $s0-$s2, $ra (cat vao khung 16 byte), $t0, $t1
reverse_words:
        addi  $sp, $sp, -16     # mo dau: cap khung 16 byte
        sw    $ra, 12($sp)
        sw    $s0, 8($sp)
        sw    $s1, 4($sp)
        sw    $s2, 0($sp)

        move  $s0, $a0          # $s0 = dia chi dau chuoi
        jal   strlen            # $v0 = len
        beq   $v0, $zero, rw_done

        addu  $s1, $s0, $v0     # $s1 = dia chi byte 0 cuoi chuoi

        # Buoc 1: dao toan bo chuoi [$s0, $s1 - 1]
        move  $a0, $s0
        addiu $a1, $s1, -1
        jal   rev_range

        # Buoc 2: duyet va dao lai tung tu
        move  $s2, $s0          # $s2 = curr = dau chuoi ($s0 la word_start)
rw_loop:
        bgeu  $s2, $s1, rw_last # cham cuoi chuoi -> dao tu cuoi cung
        lbu   $t0, 0($s2)
        li    $t1, 32           # ma ASCII cua dau cach ' '
        bne   $t0, $t1, rw_next

        move  $a0, $s0          # word_start
        addiu $a1, $s2, -1      # curr - 1
        jal   rev_range
        addiu $s0, $s2, 1       # word_start = curr + 1

rw_next:
        addiu $s2, $s2, 1
        j     rw_loop

rw_last:
        move  $a0, $s0          # tu cuoi cung: [word_start, $s1 - 1]
        addiu $a1, $s1, -1
        jal   rev_range

rw_done:
        lw    $s2, 0($sp)       # ket thuc: khoi phuc thanh ghi
        lw    $s1, 4($sp)
        lw    $s0, 8($sp)
        lw    $ra, 12($sp)
        addi  $sp, $sp, 16      # thu hoi khung 16 byte
        jr    $ra
