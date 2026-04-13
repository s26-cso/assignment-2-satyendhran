.data
.text
.global make_node
.global insert
.global get
.global getAtMost

make_node:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)

    li a0, 12
    call malloc

    lw t0, 8(sp)
    sw t0, 0(a0)                                # node->val = val
    sw zero, 4(a0)                              # node->left = NULL
    sw zero, 8(a0)                              # node->right = NULL

    lw ra, 12(sp)
    addi sp, sp, 16
    ret

insert:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)                                
    sw a1, 4(sp)                                

    beq a0, zero, insert_create                 # if (root == NULL) goto create

    lw t0, 0(a0)                                # t0 = root->val
    blt a1, t0, insert_left                     # if (val < root->val) left
    bgt a1, t0, insert_right                    # if (val > root->val) right
    lw ra, 12(sp)
    addi sp, sp, 16
    ret                              

insert_left:
    lw a0, 4(a0)                                # a0 = root->left
    lw a1, 4(sp)
    call insert                                 # insert(root->left, val)
    lw t2, 8(sp)
    sw a0, 4(t2)                                # root->left = returned node
    mv a0, t2                                   # return root
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

insert_right:
    lw a0, 8(a0)                                # a0 = root->right
    lw a1, 4(sp)
    call insert                                 # insert(root->right, val)
    lw t2, 8(sp)
    sw a0, 8(t2)                                # root->right = returned node
    mv a0, t2                                   # return root
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

insert_create:
    lw a0, 4(sp)                                # a0 = val
    call make_node                              # make_node(val) → new Node
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

get:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)                                
    sw a1, 4(sp)                                

    beq a0, zero, get_null                      # if (root == NULL) return NULL

    lw t0, 0(a0)                                # t0 = root->val
    beq t0, a1, get_done                        # if (root->val == val) found
    blt a1, t0, get_left                        # if (val < root->val) goto left
                                                # else: val > root->val → go right
    lw a0, 8(a0)                                # a0 = root->right
    lw a1, 4(sp)
    call get                                    # get(root->right, val)
    j get_done

get_left:
    lw a0, 4(a0)                                # a0 = root->left
    lw a1, 4(sp)
    call get                                    # get(root->left, val)
    j get_done

get_null:
    li a0, 0                                    # return NULL

get_done:
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

getAtMost:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw a0, 12(sp)                                
    sw a1, 8(sp)                                

    beq a1, zero, gam_minus1                    # if (root == NULL) return -1

    lw t0, 0(a1)                                # t0 = root->val
    beq t0, a0, gam_exact                       # if (root->val == val) exact match
    blt a0, t0, gam_left                        # if (val < root->val) goto left
                                                # else: root->val < val → root->val is candidate

    sw t0, 0(sp)                                # spill candidate root->val onto stack

    lw a1, 8(a1)                                # a1 = root->right
    call getAtMost                              # getAtMost(val, root->right)

    li t2, -1
    bne a0, t2, gam_done                        # if (result != -1) return right subtree result

    lw a0, 0(sp)                                # else return saved root->val as best candidate
    j gam_done

gam_left:
    lw a1, 4(a1)                                # a1 = root->left
    call getAtMost                              # getAtMost(val, root->left)
    j gam_done

gam_exact:
    mv a0, t0                                   # return exact match value
    j gam_done

gam_minus1:
    li a0, -1                                   # return -1

gam_done:
    lw ra, 16(sp)
    addi sp, sp, 20
    ret