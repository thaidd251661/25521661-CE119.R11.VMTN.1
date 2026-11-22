.data
n_val:  .word 12
msg1:   .asciiz "F("
msg2:   .asciiz ") = "

.text
.globl main
main:
        lw    $s0, n_val        # doc n tu bo nho
        move  $a0, $s0
        jal   fib_rec          # doi thanh "jal fib_iter" khi do fib_iter
        move  $s1, $v0          # luu ket qua F(n)

        # In "F(n) = <ket qua>"
        li    $v0, 4
        la    $a0, msg1
        syscall

        li    $v0, 1
        move  $a0, $s0
        syscall

        li    $v0, 4
        la    $a0, msg2
        syscall

        li    $v0, 1
        move  $a0, $s1
        syscall

        li    $v0, 10
        syscall

# fib_rec: tinh so Fibonacci thu n bang de quy
# Tham so  : $a0 = n (n >= 0)
# Tra ve   : $v0 = F(n)
# Thanh ghi: $s0, $s1, $ra (cat vao khung ngan xep 12 byte)
fib_rec:
        addi  $sp, $sp, -12     # mo dau: cap khung 3 word
        sw    $ra, 8($sp)       # cat dia chi tro ve
        sw    $s0, 4($sp)       # cat $s0 (dung luu n)
        sw    $s1, 0($sp)       # cat $s1 (dung luu F(n-1))

        slti  $t0, $a0, 2       # kiem tra n < 2
        bne   $t0, $zero, fr_base

        move  $s0, $a0          # giu n qua loi goi de quy
        addi  $a0, $s0, -1      # tham so n - 1
        jal   fib_rec           # $v0 = F(n - 1)
        move  $s1, $v0          # giu F(n - 1) qua loi goi thu hai

        addi  $a0, $s0, -2      # tham so n - 2
        jal   fib_rec           # $v0 = F(n - 2)
        add   $v0, $s1, $v0     # $v0 = F(n - 1) + F(n - 2)
        j     fr_done

fr_base:
        move  $v0, $a0          # truong hop co so: F(0) = 0, F(1) = 1

fr_done:
        lw    $s1, 0($sp)       # ket thuc: khoi phuc thanh ghi
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12      # thu hoi khung 12 byte
        jr    $ra

# fib_iter: tinh F(n) bang vong lap (de so sanh)
# Tham so  : $a0 = n    Tra ve : $v0 = F(n)
# Thanh ghi: $t0-$t3 (thu tuc la)
fib_iter:
        move  $v0, $zero        # a = F(0)
        li    $t0, 1            # b = F(1)
        move  $t1, $zero        # i = 0
fi_loop:
        slt   $t2, $t1, $a0
        beq   $t2, $zero, fi_done
        addu  $t3, $v0, $t0     # a + b
        move  $v0, $t0
        move  $t0, $t3
        addiu $t1, $t1, 1
        j     fi_loop
fi_done:
        jr    $ra
