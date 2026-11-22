.data
n_val:  .word 20                
msg1:   .asciiz "F("
msg2:   .asciiz ") = "

.text
.globl main
main:
        lw    $s0, n_val        # doc n tu bo nho
        move  $a0, $s0
        jal   fib_opt           # goi thu tuc toi uu truong hop co so
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

# fib_opt: tinh F(n) de quy co toi uu truong hop co so truoc khi cap khung
# Tham so  : $a0 = n (n >= 0)
# Tra ve   : $v0 = F(n)
# Thanh ghi: $s0, $s1, $ra (chi cat vao khung ngan xep 12 byte khi n >= 2)
fib_opt:
        slti  $t0, $a0, 2       # kiem tra n < 2 truoc khi cap khung
        beq   $t0, $zero, fo_rec
        move  $v0, $a0          # truong hop co so: tra ve ngay, khong dung stack
        jr    $ra

fo_rec:
        addi  $sp, $sp, -12     # mo dau: chi cap khung cho nhanh de quy (n >= 2)
        sw    $ra, 8($sp)       # cat dia chi tro ve
        sw    $s0, 4($sp)       # cat $s0 (dung luu n)
        sw    $s1, 0($sp)       # cat $s1 (dung luu F(n-1))

        move  $s0, $a0          # giu n qua loi goi de quy
        addi  $a0, $s0, -1      # tham so n - 1
        jal   fib_opt           # $v0 = F(n - 1)
        move  $s1, $v0          # giu F(n - 1) qua loi goi thu hai

        addi  $a0, $s0, -2      # tham so n - 2
        jal   fib_opt           # $v0 = F(n - 2)
        add   $v0, $s1, $v0     # $v0 = F(n - 1) + F(n - 2)

        lw    $s1, 0($sp)       # ket thuc: khoi phuc thanh ghi
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12      # thu hoi khung 12 byte
        jr    $ra
