.data
fname:    .string "input.txt"
mode_r:   .string "r"
yes_str:  .string "Yes\n"
no_str:   .string "No\n"

.text
.globl main

main:
    addi sp, sp, -48                 
    sd   ra, 40(sp)       
    sd   s0, 32(sp)  
    sd   s1, 24(sp)   
    sd   s2, 16(sp)                    
    sd   s3, 8(sp)                      
    sd   s4, 0(sp)                      

    # fd1 = fopen("input.txt", "r")
    la   a0, fname                      
    la   a1, mode_r                     
    call fopen                          # a0 = fd1
    mv   s2, a0                         # s2 = fd1

    # fd2 = fopen("input.txt", "r")
    la   a0, fname                      
    la   a1, mode_r                     
    call fopen                          # a0 = fd2
    mv   s3, a0                         # s3 = fd2

    # fseek(fd1, 0, SEEK_END)
    mv   a0, s2                         # a0 = fd1
    li   a1, 0                          # offset = 0
    li   a2, 2                          # SEEK_END = 2
    call fseek                          # fseek(fd1, 0, SEEK_END)

    # s4 = ftell(fd1) = raw file size
    mv   a0, s2                         # a0 = fd1
    call ftell                          # a0 = file size
    mv   s4, a0                         # s4 = file size

    li   s0, 0                          # s0 = left = 0
    addi s1, s4, -1                     # s1 = right = file_size - 1

    mv   a0, s2                         # a0 = fd1
    mv   a1, s1                         # a1 = right
    li   a2, 0                          # SEEK_SET = 0
    call fseek                          # fseek(fd1, right, SEEK_SET)
    mv   a0, s2                         # a0 = fd1
    call fgetc                          # a0 = byte at right
    li   t0, 10                         # t0 = '\n' ASCII 10
    bne  a0, t0, check_loop             # if byte != '\n' -> skip trim
    addi s1, s1, -1                     # right-- (skip trailing \n)

check_loop:
    bge  s0, s1, is_palindrome          # if left >= right -> palindrome

    # seek fd1 to left, read left_char into s5
    mv   a0, s2                         # a0 = fd1
    mv   a1, s0                         # a1 = left
    li   a2, 0                          # SEEK_SET = 0
    call fseek                          # fseek(fd1, left, SEEK_SET)
    mv   a0, s2                         # a0 = fd1
    call fgetc                          # a0 = left_char
    mv   t0, a0                         # t0 = left_char

    # seek fd2 to right, read right_char
    mv   a0, s3                         # a0 = fd2
    mv   a1, s1                         # a1 = right
    li   a2, 0                          # SEEK_SET = 0
    call fseek                          # fseek(fd2, right, SEEK_SET)
    mv   a0, s3                         # a0 = fd2
    call fgetc                          # a0 = right_char

    bne  t0, a0, not_palindrome         # if left_char != right_char -> not palindrome

    addi s0, s0, 1                      # left++
    addi s1, s1, -1                     # right--
    j    check_loop                     # loop

is_palindrome:
    la   a0, yes_str                    # a0 = &yes_str
    call printf                         # printf("Yes\n")
    j    cleanup

not_palindrome:
    la   a0, no_str                     # a0 = &no_str
    call printf                         # printf("No\n")

cleanup:
    mv   a0, s2                         # a0 = fd1
    call fclose                         # fclose(fd1)
    mv   a0, s3                         # a0 = fd2
    call fclose                         # fclose(fd2)

    li   a0, 0                          # return 0
    ld   ra, 40(sp)                     # restore return address
    ld   s0, 32(sp)                     # restore s0
    ld   s1, 24(sp)                     # restore s1
    ld   s2, 16(sp)                     # restore s2
    ld   s3, 8(sp)                      # restore s3
    ld   s4, 0(sp)                      # restore s4
    addi sp, sp, 48                     # epilogue: deallocate stack frame
    ret