.data
msg:    .asciiz "Ket qua: "

.text
.globl main
main:
        li    $a0, 5            # x = 5
        jal   outer             # v0 = outer(5)
        move  $s0, $v0

        li    $v0, 4
        la    $a0, msg
        syscall

        move  $a0, $s0
        li    $v0, 1
        syscall

        li    $v0, 10
        syscall

# outer: tinh inner(x) + 1 (thu tuc khong la)
# Tham so  : $a0 = x
# Tra ve   : $v0 = 2x + 1
# Thanh ghi: $ra (cat vao khung ngan xep 4 byte)
outer:
        addi  $sp, $sp, -4      # mo dau: cap khung 1 word
        sw    $ra, 0($sp)       # cat dia chi tro ve main

        jal   inner             # $v0 = 2 * x
        addi  $v0, $v0, 1       # $v0 = 2 * x + 1

        lw    $ra, 0($sp)       # ket thuc: khoi phuc $ra
        addi  $sp, $sp, 4       # thu hoi khung ngan xep
        jr    $ra               # tro ve main

# inner: tinh 2 * x (thu tuc la)
# Tham so  : $a0 = x
# Tra ve   : $v0 = 2x
# Thanh ghi: khong dung thanh ghi can bao toan
inner:
        add   $v0, $a0, $a0
        jr    $ra