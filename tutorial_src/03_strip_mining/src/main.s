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
    # spike -d --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main
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

    li a0, 12                   # 12 elements in the large vector

    la a1, testdata + 0         # first test data set starts at the testdata symbol
    la a2, testdata + (12 * 4)  # second test data set starts 12 elements later

    la a3, resultdata + 0




# vector-vector add routine of 32-bit integers
#
# void vvaddint32(size_t n, const int*x, const int*y, int*z)
# { 
#	for (size_t i=0; i<n; i++) 
#   { 
#      z[i] = x[i] + y[i]; 
#   }
# }
#
# Mapping parameters to argument register (a0 .. a7)
# a0 = n, a1 = x, a2 = y, a3 = z
#
# Non-vector instructions are indented
vvaddint32:
	vsetvli t0, a0, e32, ta, ma 	# Set vector length based on 32-bit vectors. t0 contains the amount of elements that will be processed
	
	vle32.v v0, (a1) 				# Get first vector
	
		# can I move these two instructions up over vle32.v ???
		sub a0, a0, t0 				# Decrement number of elements that still need processing. 
									# t0 is the result of vsetvli. It is the amount of elements processed this iteration
		slli t0, t0, 2 				# Multiply number done by 4 bytes (= 32 bit integer) because of SEW=e32		

		add a1, a1, t0 				# Bump pointer for first vector
		
	vle32.v v1, (a2) 				# Get second vector
		add a2, a2, t0 				# Bump pointer for second vector
		
	vadd.vv v2, v0, v1 			    # Sum vectors
	
	vse32.v v2, (a3) 				# Store result
		add a3, a3, t0 				# Bump pointer
		
		bnez a0, vvaddint32 		# Loop back
		ret 						# Finished






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
    .quad 0x1918171615141312
    .quad 0x21201F1E1D1C1B1A
    .quad 0x2928272625242322
    .quad 0x31302F2E2D2C2B2A

    .quad 0x0807060504030201
    .quad 0x11100E0D0C0B0A09
    .quad 0x1918171615141312
    .quad 0x21201F1E1D1C1B1A
    .quad 0x2928272625242322
    .quad 0x31302F2E2D2C2B2A
