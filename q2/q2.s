.global main
.section .data
intstr:   .string "%d"
sepstr:   .string " "
newline:  .string "\n"

.section .text
main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    sd s4, 0(sp)

    li a0, 4000
    call malloc                         # s1 = malloc(4000)
    mv s1, a0

    li a0, 4000
    call malloc                         # s2 = malloc(4000)
    mv s2, a0

    li a0, 4000
    call malloc                         # s3 = malloc(4000)
    mv s3, a0

    li s0, 0                            # n = 0
    li s4, -1                           # sp_top = -1

input:
    addi sp, sp, -16
    mv a1, sp
    la a0, intstr
    call scanf                          # scanf("%d", &tmp)
    li t0, 1
    bne a0, t0, input_complete
    lw t1, 0(sp)
    addi sp, sp, 16
    slli t2, s0, 2
    add t2, s1, t2
    sw t1, 0(t2)                        # arr[n] = tmp
    addi s0, s0, 1                      # n++
    j input

input_complete:
    addi sp, sp, 16
    li s5, 0

initialisation:
    bge s5, s0, init_done
    slli t0, s5, 2
    add t0, s2, t0
    li t1, -1
    sw t1, 0(t0)                        # result[i] = -1
    addi s5, s5, 1
    j initialisation
init_done:

    addi s5, s0, -1                     # i = n-1
nge:
    bltz s5, nge_done

pop:
    bltz s4, push
    slli t0, s5, 2
    add t0, s1, t0
    lw t1, 0(t0)                        # t1 = arr[i]
    slli t2, s4, 2
    add t2, s3, t2
    lw t3, 0(t2)                        # t3 = stack[sp_top]
    slli t3, t3, 2
    add t3, s1, t3
    lw t3, 0(t3)                        # t3 = arr[stack[sp_top]]
    bgt t3, t1, push
    addi s4, s4, -1                     # sp_top--
    j pop

push:
    bltz s4, do_push
    slli t0, s4, 2
    add t0, s3, t0
    lw t1, 0(t0)                        # t1 = stack[sp_top]
    slli t2, s5, 2
    add t2, s2, t2
    sw t1, 0(t2)                        # result[i] = stack[sp_top]

do_push:
    addi s4, s4, 1                      # sp_top++
    slli t0, s4, 2
    add t0, s3, t0
    sw s5, 0(t0)                        # stack[sp_top] = i
    addi s5, s5, -1                     # i--
    j nge

nge_done:
    li s5, 0

print_loop:
    bge  s5, s0, print_done
    slli t0, s5, 2
    add  t0, s2, t0
    lw   a1, 0(t0)                      # a1 = result[i]
    la   a0, intstr
    call printf                         # printf("%d", result[i])
    addi s5, s5, 1
    bge  s5, s0, print_done             # skip space if last element
    la   a0, sepstr
    call printf                         # printf(" ")
    j    print_loop

print_done:
    la a0, newline
    call printf                         # printf("\n")

    li a0, 0
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    ld s4, 0(sp)
    addi sp, sp, 48
    ret