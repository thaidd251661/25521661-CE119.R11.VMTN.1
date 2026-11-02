.data
    S:          .word 7, 4, 9, 10, 3, 6, 8, 3, 7, 10, 5, 4  # Mảng 12 phần tử
    S_len:      .word 12                                   # n = 12
    grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3      # Bảng tra nhóm điểm 0-10
    hist:       .word 0, 0, 0, 0                           # Mảng đếm 4 nhóm

    str_min:    .asciiz "min="
    str_max:    .asciiz " max="
    str_g0:     .asciiz "g0="
    str_g1:     .asciiz " g1="
    str_g2:     .asciiz " g2="
    str_g3:     .asciiz " g3="
    str_newline:.asciiz "\n"

    str_test1:  .asciiz "(a+b)*[c-{d/e}]"
    str_test2:  .asciiz "f(x[i]{j}})"
    str_test3:  .asciiz "{[(]}"
    str_test4:  .asciiz "((a)"

    str_tn2_lbl:.asciiz "TN2:\n"
    str_tn3_lbl:.asciiz "\nTN3:\n"
    str_comma:  .asciiz ", "
    str_close:  .asciiz ")\n"

.text
.globl main

main:
    # TN2: Thống kê và đếm nhóm điểm
    la   $a0, str_tn2_lbl
    li   $v0, 4
    syscall

    la   $a0, S
    lw   $a1, S_len
    jal  stats
    
    move $s0, $v0
    move $s1, $v1

    la   $a0, str_min
    li   $v0, 4
    syscall
    move $a0, $s0
    li   $v0, 1
    syscall
    la   $a0, str_max
    li   $v0, 4
    syscall
    move $a0, $s1
    li   $v0, 1
    syscall
    la   $a0, str_newline
    li   $v0, 4
    syscall

    la   $a0, S
    lw   $a1, S_len
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    la   $t0, hist
    la   $a0, str_g0
    li   $v0, 4
    syscall
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    la   $a0, str_g1
    li   $v0, 4
    syscall
    lw   $a0, 4($t0)
    li   $v0, 1
    syscall

    la   $a0, str_g2
    li   $v0, 4
    syscall
    lw   $a0, 8($t0)
    li   $v0, 1
    syscall

    la   $a0, str_g3
    li   $v0, 4
    syscall
    lw   $a0, 12($t0)
    li   $v0, 1
    syscall
    la   $a0, str_newline
    li   $v0, 4
    syscall

    # Vẽ biểu đồ
    la   $a0, hist
    li   $a1, 4
    jal  draw_hist

    # TN3: Kiểm tra ngoặc
    la   $a0, str_tn3_lbl
    li   $v0, 4
    syscall

    la   $a0, str_test1
    jal  check_brackets
    jal  print_tn3_res

    la   $a0, str_test2
    jal  check_brackets
    jal  print_tn3_res

    la   $a0, str_test3
    jal  check_brackets
    jal  print_tn3_res

    la   $a0, str_test4
    jal  check_brackets
    jal  print_tn3_res

    li   $v0, 10
    syscall

# In kết quả (v0, v1)
print_tn3_res:
    move $t7, $v0
    move $t8, $v1

    li   $a0, '('
    li   $v0, 11
    syscall

    move $a0, $t7
    li   $v0, 1
    syscall

    la   $a0, str_comma
    li   $v0, 4
    syscall

    move $a0, $t8
    li   $v0, 1
    syscall

    la   $a0, str_close
    li   $v0, 4
    syscall
    jr   $ra

# Thủ tục stats: $a0 = mảng, $a1 = n -> $v0 = min, $v1 = max
stats:
    lw   $v0, 0($a0)        # min = S[0]
    lw   $v1, 0($a0)        # max = S[0]
    li   $t0, 1             # i = 1

stats_loop:
    beq  $t0, $a1, stats_done
    sll  $t1, $t0, 2        # offset = i * 4
    add  $t1, $a0, $t1
    lw   $t2, 0($t1)
    bge  $t2, $v0, check_max
    move $v0, $t2           # cập nhật min
check_max:
    ble  $t2, $v1, stats_next
    move $v1, $t2           # cập nhật max
stats_next:
    addi $t0, $t0, 1
    j    stats_loop
stats_done:
    jr   $ra

# Thủ tục histogram: $a0 = S, $a1 = n, $a2 = grade_tab, $a3 = hist
histogram:
    li   $t0, 0             # i = 0

hist_loop:
    beq  $t0, $a1, hist_done
    sll  $t1, $t0, 2        # offset = i * 4
    add  $t1, $a0, $t1
    lw   $t2, 0($t1)        # điểm s = S[i]
    add  $t3, $a2, $t2      # địa chỉ grade_tab[s]
    lbu  $t4, 0($t3)        # nhóm g = grade_tab[s]
    sll  $t4, $t4, 2        # offset = g * 4
    add  $t5, $a3, $t4
    lw   $t6, 0($t5)
    addi $t6, $t6, 1        # hist[g]++
    sw   $t6, 0($t5)
    addi $t0, $t0, 1
    j    hist_loop
hist_done:
    jr   $ra

# Thủ tục draw_hist: $a0 = hist, $a1 = số nhóm
draw_hist:
    move $t0, $a0
    move $t1, $a1
    li   $t2, 0             # i = 0

draw_outer:
    beq  $t2, $t1, draw_done

    li   $a0, 'g'
    li   $v0, 11
    syscall
    move $a0, $t2
    li   $v0, 1
    syscall
    li   $a0, ':'
    li   $v0, 11
    syscall
    li   $a0, ' '
    li   $v0, 11
    syscall

    sll  $t3, $t2, 2
    add  $t3, $t0, $t3
    lw   $t4, 0($t3)        # số sinh viên nhóm i

    li   $t5, 0
draw_inner:
    beq  $t5, $t4, draw_next
    li   $a0, '|'
    li   $v0, 11
    syscall
    addi $t5, $t5, 1
    j    draw_inner

draw_next:
    li   $a0, '\n'
    li   $v0, 11
    syscall
    addi $t2, $t2, 1
    j    draw_outer
draw_done:
    jr   $ra

# Thủ tục check_brackets: $a0 = chuỗi -> $v0 = pos, $v1 = mã lỗi (0..3)
check_brackets:
    move $t9, $sp           # lưu $sp ban đầu để khôi phục O(1)
    move $t0, $a0
    li   $t1, 0             # pos = 0

cb_loop:
    lbu  $t2, 0($t0)
    beqz $t2, cb_end_string  # hết chuỗi ('\0')

    addi $t1, $t1, 1        # pos++
    addi $t0, $t0, 1

    # Ngoặc mở -> Push vào stack
    li   $t3, '('
    beq  $t2, $t3, cb_push
    li   $t3, '['
    beq  $t2, $t3, cb_push
    li   $t3, '{'
    beq  $t2, $t3, cb_push

    # Ngoặc đóng -> Pop và đối chiếu
    li   $t3, ')'
    beq  $t2, $t3, cb_check_close
    li   $t3, ']'
    beq  $t2, $t3, cb_check_close
    li   $t3, '}'
    beq  $t2, $t3, cb_check_close

    j    cb_loop

cb_push:
    addi $sp, $sp, -4
    sw   $t2, 0($sp)
    j    cb_loop

cb_check_close:
    beq  $sp, $t9, cb_err_empty # stack rỗng mà gặp ngoặc đóng -> lỗi 2

    lw   $t4, 0($sp)
    addi $sp, $sp, 4

    li   $t3, ')'
    beq  $t2, $t3, cb_check_paren
    li   $t3, ']'
    beq  $t2, $t3, cb_check_bracket
    li   $t3, '}'
    beq  $t2, $t3, cb_check_brace
    j    cb_loop

cb_check_paren:
    li   $t5, '('
    bne  $t4, $t5, cb_err_mismatch # lệch cặp () -> lỗi 1
    j    cb_loop

cb_check_bracket:
    li   $t5, '['
    bne  $t4, $t5, cb_err_mismatch # lệch cặp [] -> lỗi 1
    j    cb_loop

cb_check_brace:
    li   $t5, '{'
    bne  $t4, $t5, cb_err_mismatch # lệch cặp {} -> lỗi 1
    j    cb_loop

cb_end_string:
    bne  $sp, $t9, cb_err_dangling # hết chuỗi nhưng còn ngoặc mở -> lỗi 3

    # Hợp lệ (0, 0)
    move $sp, $t9
    li   $v0, 0
    li   $v1, 0
    jr   $ra

cb_err_mismatch:            # Lỗi 1: Ngoặc đóng không khớp ngoặc mở
    move $sp, $t9
    move $v0, $t1
    li   $v1, 1
    jr   $ra

cb_err_empty:               # Lỗi 2: Thừa ngoặc đóng
    move $sp, $t9
    move $v0, $t1
    li   $v1, 2
    jr   $ra

cb_err_dangling:            # Lỗi 3: Thừa ngoặc mở
    move $sp, $t9
    move $v0, $t1
    li   $v1, 3
    jr   $ra