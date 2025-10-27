    .section .text

    .globl main
main:
    addi sp, sp, -8
    sd ra, 0(sp)

    # # print separator
    # la a0, msg_sep
    # jal print_str_ln

    #csrw mtvec, t0;
    
    #csrrs x0, mstatus, t1
    #xori t1, t1, 0x600
    #csrrw t1, mstatus, x0

    #
    # Working:
    # spike --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main
    #
    # Spike has been built/configured with the option:
    # --with-varch=vlen:128,elen:32
    # So I assume vlen=128, elen=32
    #
    # Not working:
    # spike --varch=vlen:128,elen:64 --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main 
    # spike --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs --varch=vlen:128,elen:64 target/main 
    # spike --isa=rv64gcv 
    #

    #
    # Commands for the spike simulator
    #
    # until pc 0 2020
    #
    # reg <hartid> <reg>
    # reg 0 a0
    #
    # freg 0 fa0
    # fregd 0 fa0
    # fregs
    #
    # Printing vector registers:
    # vreg <hartid> <vector_register>
    # The <vector_register> is not specified with the ABI name but only
    # the index of the register. e.g. v0 = 0, v1 = 1, v2 = 2, ....
    # vreg 0 0
    # vreg 0 1
    # vreg 0 2
    #

    # csrr t0,mstatus \n"  \ "li  t1,0x600 \n"     \ "or t1,t1,t0 \n"      \ "csrw mstatus,t1

    # Vector-Extension (RVV, V) must be enabled first as otherwise
    # an exception is thrown when a V instruction is used for the 
    # first time
    csrr    t0, mstatus
    li      t1, 0x600       # bits 9 and 10 to 1 which is a bitmask of 0x600
    or      t1, t1, t0
    csrw    mstatus, t1

    # vsetvli a3, a2, e32, m1, ta, ma
    vsetvli a3, a2, e8, m1, ta, ma

    # Zero all vector registers
    #vsetvli t0, x0, e8,m8,tu,mu
    vmv.v.i v0, 0x0
    vmv.v.i v8, 0x0
    vmv.v.i v16, 0x0
    vmv.v.i v24, 0x0

    # # print separator
    # la a0, msg_sep_end
    # jal print_str_ln

    li a0, 2

    la a1, testdata + 0
    la a2, testdata + 16

    la a3, resultdata + 0

vvaddint32:
    # vsetvli t0, a0, e32, m1, ta, ma     # Set vector length based on 32-bit vectors
    
    vsetvli t0, x0, e32, m1, ta, ma         # use max length, fill the entire vector register

    # Encoded Element Width (EEW) = 32 because of the mnemonic vle32.v
    # Implementation’s smallest supported SEW size in bytes (SEW_MIN/8).

    vle32.v v0, (a1)                # Get first vector
    # sub a0, a0, t0                  # Decrement number done
    # slli t0, t0, 2                  # Multiply number done by 4 bytes
    # add a1, a1, t0                  # Bump pointer
    vle32.v v1, (a2)                # Get second vector
    # add a2, a2, t0                  # Bump pointer
    vadd.vv v2, v0, v1              # Sum vectors
    vse32.v v2, (a3)                # Store result
    # add a3, a3, t0                  # Bump pointer
    # bnez a0, vvaddint32             # Loop back
    # ret                             # Finished

    # la a0, msg_mtime
    # jal print_str_ln
    # jal mtime_get
    # jal print_unsigned_ln

    # # print separator
    # la a0, msg_sep
    # jal print_str_ln

    # la a0, msg_c_fn
    # jal print_str_ln
    # jal c_function

    # # print separator
    # la a0, msg_sep
    # jal print_str_ln

    # la a0, msg_mtime
    # jal print_str_ln
    # jal mtime_get
    # jal print_unsigned_ln

    # # print separator
    # la a0, msg_sep
    # jal print_str_ln

    # la a0, msg_exc
    # jal print_str_ln

    #unimp

    #la a0, msg_wfi
    #jal print_str_ln

    ld      ra, 0(sp)
    addi    sp, sp, 8

    #addi sp, sp, 8
    #ld ra, 0(sp)

#1:
#        wfi
#        j 1b

    ret

  .section .data

msg_mtime:    .asciz "mtime:"
msg_c_fn:     .asciz "calling a C function from asm:"
msg_wfi:      .asciz "waiting for interrupts..."
msg_exc:      .asciz "manually invoking an exception..."

    .globl msg_sep
msg_sep:      .asciz "-------------------------"
msg_sep_end:  .asciz "--------- END -----------"

    .align 5
resultdata:
    .zero 1024

# .align 5 is executed by the assembler as an alginment of the
# following data to 2^5 = 32 byte aligned addresses. Meaning
# addresses are used that when divided by 32 have a remainder of 0
#
# This is required for the vector test data since otherwise an
# instruction with an encoded element width such as vle32...
# causes an exception because it can only read data from aligned
# addresses
#
# See Vector Extension Spec, 7.9. Vector Load/Store Whole Register Instructions
    .align 5
testdata:
    .quad 0x0807060504030201
    .quad 0x11100E0D0C0B0A09

    .quad 0x0807060504030201
    .quad 0x11100E0D0C0B0A09
