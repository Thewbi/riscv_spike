# riscv_spike
Instructions and Samples for using the Spike RISCV simulator

# Working

Download the original precompiled toolchain in 64 bit version (without Vector extension! But I think it actually supports the vector extension)
Download it from here: https://github.com/riscv-collab/riscv-gnu-toolchain/releases
Install it to /opt/riscv

Build your own spike and pk both for 64 bit.

This works: (use the spike (without any paths) command which is the correct executable after sudo make install is executed!).

```
spike pk ./a.out
```

```
spike --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs pk main
```




# Install VirtualBox and install the latest Ubuntu into virtual box.

You need to install without unattended installation because with unattended installation, the terminal will not open.

You should create a harddrive with 40 GB of memory. 25 GB is not enough to build the riscv toolchain.
Do not check "Pre-allocate Full Size" when creating the hard drive.

You should assign 2 CPUs otherwise the OS is really laggy.

Activate Clipboard Sharing (only Ubuntu Desktop, not Ubuntu Server)

https://superuser.com/questions/1318231/why-doesnt-clipboard-sharing-work-with-ubuntu-18-04-lts-inside-virtualbox-5-1-2

```
sudo apt-get update
sudo apt-get install virtualbox-guest-x11
```

Now everytime you reboot the virtualbox and want to use the bidirectional clipboard, execute

```
sudo VBoxClient --clipboard
```

Goto Devices > "Insert Guest Additions CD Image..."
Goto Devices > Shared Clipboard > Bidirectional


# Share a folder

1. Devices > Shared Folders > Shared Folder Settings.
2. Add a shared folder with automount and the /mnt as mountpoint
3. FolderPath: C:\Users\lapto\Downloads
4. FolderName: Downloads

Template for a mount command (replace <FolderName> by the FolderName
that you used when creating the shared folder record.
```
sudo mount -t vboxsf <FolderName> /mnt
```

example:
```
sudo mount -t vboxsf Downloads /mnt
```

No files copied into /mnt on the guest are available in the Downloads
folder of the host and vice-versa.


# Protip

There is no need to compile the RISCV GNU Toolchain yourself.
The page https://github.com/riscv-collab/riscv-gnu-toolchain/releases contains precompiled releases.

This page: https://github.com/haipnh/riscv-gnu-toolchain_gcv/releases
seems to have prebuild toolchains with the vector extension enabled.

Download riscv32-elf-ubuntu-24.04-gcc-nightly-2025.08.06-nightly.tar.xz

```
sudo apt install xz-utils

sudo rm -r /opt/riscv

cd ~/Downloads
sudo tar -xf riscv32-elf-ubuntu-24.04-gcc-nightly-2025.08.06-nightly.tar.xz -C /opt
```

You can extract and copy the toolchain to /opt/riscv.
Then during configure of other software, the /opt/riscv folder can be used as prefix:

e.g.:

```
RISCV=/opt/riscv
PATH=$RISCV/bin:$PATH

echo $PATH

riscv32-unknown-elf-as

./configure --prefix=$RISCV --with-arch=rv32gvc --with-abi=ilp32d
```








# Install RISC-V toolchain on Ubuntu

https://github.com/riscv-collab/riscv-gnu-toolchain

```
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev

cd ~/dev/riscv
git clone https://github.com/riscv/riscv-gnu-toolchain -b rvv-next

cd /opt
sudo mkdir riscv
cd riscv
sudo mkdir bin

PATH=/opt/riscv/bin:$PATH

cd ~/dev/riscv/riscv-gnu-toolchain

./configure --prefix=/opt/riscv
./configure --prefix=/opt/riscv --with-arch=rv32gvc --with-abi=ilp32d

sudo make
```




# Building a vector application:

https://stackoverflow.com/questions/69375945/risc-v-toolchain-with-vector-support

Objdump won't recognize instructions but you can see it if you emit assembler code with -S key

https://github.com/brucehoult/rvv_example

```
cd ~/dev
git clone https://github.com/brucehoult/rvv_example
cd rvv_example
make
```

```
riscv64-unknown-elf-gcc -O main.c vec.S -o main -march=rv32gcv_zba -lm
riscv64-unknown-elf-objdump -d main > main.lst
```


```
# void vec_len_rvv(float *r, struct pt *pts, int n)

    #define r a0
    #define pts a1
    #define n a2
    #define vl a3
    #define Xs v0
    #define Ys v1
    #define Zs v2
    #define lens v3
    
    .globl vec_len_rvv
vec_len_rvv:
    # 32 bit elements, don't care (Agnostic) how tail and mask are handled
    vsetvli vl, n, e32, ta,ma
    vlseg3e32.v Xs, (pts) # loads interleaved Xs, Ys, Zs into 3 registers
    vfmul.vv lens, Xs, Xs
    vfmacc.vv lens, Ys, Ys
    vfmacc.vv lens, Zs, Zs
    vfsqrt.v lens, lens
    vse32.v lens, (r)
    sub n, n, vl
    sh2add r, vl, r # bump r ptr 4 bytes per float
    sh1add vl, vl, vl # multiply vl by 3 floats per point
    sh2add pts, vl, pts # bump v ptr 4 bytes per float (12 per pt)
    bnez n, vec_len_rvv
    ret
```





# Install Spike

https://riscv.epcc.ed.ac.uk/documentation/how-to/install-spike/

```
sudo apt-get update
sudo apt-get install device-tree-compiler  
sudo apt-get install libboost-all-dev
sudo apt-get install build-essential
sudo apt install git make
```


```
RISCV=/opt/riscv
PATH=$RISCV/bin:$PATH

# mkdir ~/dev
# cd ~/dev
# mkdir riscv
# cd ~/dev/riscv

cd ~/Downloads
git clone https://github.com/riscv-software-src/riscv-isa-sim.git  
cd ~/dev/riscv/riscv-isa-sim
mkdir build   
cd ~/dev/riscv/riscv-isa-sim/build

mkdir /home/vbox/spike
SPIKE_INSTALL_DIR=/home/vbox/spike

Either build 32 or 64 bit
../configure --prefix=$SPIKE_INSTALL_DIR --host=riscv64-unknown-elf --with-isa=rv32gcv --with-varch=vlen:128,elen:32
../configure --prefix=$RISCV --host=riscv64-unknown-elf --with-target=riscv64-unknown-elf --with-boost-libdir=/usr/lib/x86_64-linux-gnu/ --with-varch=vlen:128,elen:32 --with-isa=rv64gcv  <---------------- Use this
../configure --prefix=$RISCV --host=riscv64-unknown-elf --with-target=riscv64-unknown-elf --with-boost-libdir=/usr/lib/x86_64-linux-gnu/ --varch=vlen:128,elen:64,slen:128 --with-isa=rv64gcv

sudo ../configure --prefix=$RISCV --host=riscv64-unknown-elf --with-boost-libdir=/usr/lib/x86_64-linux-gnu/
sudo ../configure --prefix=$RISCV --host=riscv32-unknown-elf --with-boost-libdir=/usr/lib/x86_64-linux-gnu/ --with-varch=vlen:128,elen:32 --with-isa=rv32gcv --with-target=riscv32-unknown-elf
sudo ../configure --prefix=$SPIKE_INSTALL_DIR --host=riscv32-unknown-elf --with-boost-libdir=/usr/lib/x86_64-linux-gnu/ --with-target=riscv32-unknown-elf

make -j$(nproc)
sudo make install  
```







# Install PK (Proxy Kernel for applications that use POSIX functionality)

```
cd ~/dev
mkdir riscv
cd ~/dev/riscv
git clone https://github.com/riscv/riscv-pk.git  

cd riscv-pk
mkdir build
cd build



../configure --prefix=$RISCV --host=riscv64-unknown-elf
../configure --prefix=$RISCV --host=riscv32-unknown-elf
../configure --prefix=$HOME/dev/riscv-isa-sim/build --host=riscv32-unknown-elf

../configure --prefix=$SPIKE_INSTALL_DIR --host=riscv32-unknown-elf
../configure --prefix=$SPIKE_INSTALL_DIR --host=riscv64-unknown-elf   <---------------------- Works
../configure --prefix=$SPIKE_INSTALL_DIR --host=riscv64-unknown-elf --with-isa=rv32gcv

make -j$(nproc)
sudo make install
```



ERROR: gcc error unrecognized argument in option -m mcmodel=medany
Solution:
https://github.com/riscv-software-src/riscv-pk/issues/204
This means you’re using a host compiler rather than a RISC-V compiler. 
Make sure that riscv64-unknown-elf-gcc is in your PATH when you execute configure
If this error occurs:
```
RISCV=/opt/riscv
PATH=$RISCV/bin:$PATH
make clean
../configure --prefix=$SPIKE_INSTALL_DIR --host=riscv64-unknown-elf
make -j2
sudo make install
```




# Cleaning the Build

https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1196

For a clean full build I normally do the following which seems to work (installed-tools is the directory specified at configuration time via --prefix)


```
PATH=/opt/riscv/bin:$PATH
cd ~/dev/riscv/riscv-gnu-toolchain
rm -rf installed-tools
make distclean
```




# Building an executable

## Example 1

```
#include <stdio.h>

int main() {
    printf("Hallo Welt!\n");
    return 0;
}
```

Building

```
RISCV=/opt/riscv
PATH=$RISCV/bin:$PATH

riscv32-unknown-elf-gcc -march=rv32id -mabi=ilp32d main.c -lm
riscv32-unknown-elf-gcc -mabi=ilp32d main.c
riscv32-unknown-elf-objdump -d a.out > main.lst
```

Running with Spike

```
SPIKE=$HOME/spike
$SPIKE/bin/spike -d --isa=RV32IMdc pk ./a.out
```

This works: (use the spike command which is the correct executable after sudo make install is executed!).

```
spike pk ./a.out
```


## Example 2

```
int mult() {
        int a=1000,b=3;
        return a*b;
}

int main() {
        mult();
}
```



# Using spike

RISCV=$HOME/dev/riscv
spike --isa=RV64IMACV $RISCV/riscv-pk/build/pk ./main

```
~/dev/riscv/riscv-isa-sim/build/spike --isa=RV32IMACV --varch=vlen:128,elen:32 --isa=rv32gcv pk ./a.out
~/dev/riscv/riscv-isa-sim/build/spike --isa=RV32IMACV --varch=vlen:128,elen:32 --isa=rv32gcv pk ./main
```

## Single step debugging:

```
~/dev/riscv/riscv-isa-sim/build/spike -d --isa=rv32gcv pk ./a.out


```

Hit enter to execute a single instruction at a time


https://riscv.epcc.ed.ac.uk/documentation/how-to/first_vector_prog/



# Berkeley Host-Target Interface (HTIF)

https://github.com/riscv-software-src/riscv-isa-sim/issues/195
https://github.com/ucb-bar/libgloss-htif
https://github.com/riscv-boom/riscv-coremark/blob/master/riscv64-baremetal/syscalls.c




# Spike without PK

The Proxy Kernel is a layer of operating system which provides system calls.

It is possible to use Spike with baremetal assembler code without PK.
Here is a repository with example code: https://github.com/ilya-sotnikov/riscv-asm-spike

You need to update the makefile and provide the prefix to your toolchain installation:

```
TOOLCHAIN_PREFIX := /opt/riscv/bin/riscv64-unknown-elf
```

Also change the RV_ARCH argument: 

```
RV_ARCH := rv64gcv_zba
```

Then build the sample

```
make
```

The binary is placed into the target folder.

Run Spike on the sample without the pk parameter.

```
spike --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main 
```


```
spike -d --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main 
```






# Spike 

https://github.com/riscv-software-src/riscv-isa-sim/issues/145

All processors start execution at DEFAULT_RSTVEC. This is hardcoded to 0x1000 in encoding.h

Spike places a boot_rom device at the reset location. This boot_rom contains the reset vector code, followed by the binary device tree data.

The reset vector is a small sequence of code, only 8 instructions, that does the following:

- Load a0 with the value of the processor's mhartid CSR
- Load a1 with the address of the binary device tree data
- Load t0 with the value of start_pc, then unconditionally jump to that location

While the user cannot (currently) alter this boot code sequence, they do have control over the value of start_pc. If the user provides an alternate entry point on the command line, then this will be used. Otherwise, start_pc is initialized with the value of the _entry symbol found in the ELF file.



# RISC-V Vector Extension Tutorial

Disclaimer: the code for the tutorials is based on https://github.com/ilya-sotnikov/riscv-asm-spike

This section will enable you to use RISC-V vector instructions with the Spike Simulator on an Ubuntu Linux system.
The earlier parts contained instructions on how to install the Spike simulator.
This section will provide assembly code that makes use of the Vector Extension.

## Displaying Vector Extension Registers

The vector extension adds 32 vector registers.
The spike simulator can print out the registers.
To print the register contents, either start the spike simulator in debug mode
for single stepping with the enter key using the -d option:

```
spike -d --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main
```

Or pause a running spike simulation using Ctrl + c

Spike will now diplsay a prompt and await user input.

```
(spike)
```

To display the vector registers, use the *vreg* command.

```
vreg <hartid> <vector_register>
```

The hartid should be set to 0 so that the first hart is targeted since the examples only execute on hart 0.
A hart is RISC-V lingo for a hardware threat inside the RISC-V cpu. A RISC-V cpu can have several harts.

The vector_register is the id of the vector register to print (Not it's ABI name! using v0, v1, v2, ... yields
incorrect output without any warning or error!).

A correct usage example is:

```
vreg 0 0
vreg 0 1
vreg 0 2
```

These commands will print the vector register v0, v1 and v2 of the first hart.

## 01 - Loading data into the Vector Extension Registers

The vlevXY.v command is used to load data from memory into the registers

```
vle32.v v0, (a1)
```

A very important aspect is that of alignment. The RISC-V Vector Extension specification 
https://github.com/riscvarchive/riscv-v-spec/releases/tag/v1.0 states that a Vector
Load/Store Register instruction (such as vleXY.v) is allowed to throw an exception if
the data's address is not aligned correctly.

```
Implementations are allowed to raise a misaligned address exception on whole register loads and stores if the base address
is not naturally aligned to the larger of the size of the encoded EEW in bytes (EEW/8) or the implementation’s smallest
supported SEW size in bytes (SEWMIN/8).
```

I do not fully understand every last cornercase of this sentence but to prevent 
traps and exceptions it is necessary to define test data at aligned addresses:

```
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
    .quad 0x30ac75dc32808aa4
    .quad 0x8344c0aa5b761295
```

Here is how to load data into a vector register:

```
.section .text

    .globl main
main:
    addi sp, sp, -8
    sd ra, 0(sp)
	
	# Vector-Extension (RVV, V) must be enabled first as otherwise
    # an exception is thrown when a V instruction is used for the 
    # first time
    csrr    t0, mstatus
    li      t1, 0x600       # bits 9 and 10 to 1 which is a bitmask of 0x600
    or      t1, t1, t0
    csrw    mstatus, t1

    # Zero all vector registers
	vsetvli a3, a2, e8, m1, ta, ma
    vmv.v.i v0, 0x0
	
	# load the address of the testdata into register a1
	la a1, testdata + 0
	
	vsetvli t0, x0, e32, m1, ta, ma   	# use max length, fill the entire vector register
	
	# load testdata into the vector register
	vle32.v v0, (a1)                	# Get first vector
	
	ld      ra, 0(sp)
    addi    sp, sp, 8

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
	.quad 0x30ac75dc32808aa4
	.quad 0x8344c0aa5b761295
```

This application is then built into an .elf file called main.
main is the executed within spike.

```
spike -d --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main
```

Here is the single-step output of spike:

```
core   0: 0x0000000080002150 (0xf5468693) addi    a3, a3, -172
(spike) 
core   0: >>>>  vvaddint32
core   0: 0x0000000080002154 (0x0d0072d7) vsetvli t0, zero, e32, m1, ta, ma
(spike) 
core   0: 0x0000000080002158 (0x0205e007) vle32.v v0, (a1)
(spike) vreg 0 0
VLEN=128 bits; ELEN=64 bits
v0  : [1]: 0x8344c0aa5b761295  [0]: 0x30ac75dc32808aa4  
```

After executing *vle32.v v0, (a1)* and printing it *vreg 0 0*, 
the content of the v0 register matches the test data exactly.

The spike simulator is terminated using the *quit* command.

```
(spike) quit
```

## 02 - Adding two Vectors

The vadd.vv instruction is used to add vectors together.

Do not confuse the *vadd.vv* instruction with the *vaadd.vv* instruction!
*vaadd.vv* is an instruction that performs averaging while adding.
I do not know what that even means but the takeaway is to not accidently
execute vaadd.vv when you want to really execute vadd.vv.

First, load two registers with test data to add.

```
.section .text

    .globl main
main:
    addi sp, sp, -8
    sd ra, 0(sp)




    # Vector-Extension (RVV, V) must be enabled first
    csrr    t0, mstatus
    li      t1, 0x600       # bits 9 and 10 to 1 which is a bitmask of 0x600
    or      t1, t1, t0
    csrw    mstatus, t1




    # load the address of the testdata into register a1, a2 and a3
    la a1, testdata + 0
    la a2, testdata + 16

    la a3, resultdata + 0




    # use max length, fill the entire vector register
    vsetvli t0, x0, e32, m1, ta, ma         

    # Encoded Element Width (EEW) = 32 because of the mnemonic vle32.v
    # Implementation’s smallest supported SEW size in bytes (SEW_MIN/8).

    vle32.v v0, (a1)                # Get first vector
    vle32.v v1, (a2)                # Get second vector

    vadd.vv v2, v0, v1              # Sum vectors
    
    vse32.v v2, (a3)                # Store result





    .align 5
resultdata:
    .zero 1024

    .align 5
testdata:
    .quad 0x0807060504030201
    .quad 0x11100E0D0C0B0A09

    .quad 0x0807060504030201
    .quad 0x11100E0D0C0B0A09
```

Running Spike on the elf file 

```
spike -d --isa=rv64imafcv_Zba_Zbb_Zbc_Zbs target/main
```

yields the following output

```
core   0: >>>>  vvaddint32
core   0: 0x0000000080002154 (0x0d0072d7) vsetvli t0, zero, e32, m1, ta, ma
(spike) 
core   0: 0x0000000080002158 (0x0205e007) vle32.v v0, (a1)
(spike) 
core   0: 0x000000008000215c (0x02066087) vle32.v v1, (a2)
(spike) 
core   0: 0x0000000080002160 (0x02008157) vadd.vv v2, v0, v1
(spike) 
core   0: 0x0000000080002164 (0x0206e127) vse32.v v2, (a3)
(spike) 
core   0: 0x0000000080002168 (0x00006082) c.ldsp  ra, 0(sp)
(spike) vreg 0 0
VLEN=128 bits; ELEN=64 bits
v0  : [1]: 0x11100e0d0c0b0a09  [0]: 0x0807060504030201  
(spike) vreg 0 1
VLEN=128 bits; ELEN=64 bits
v1  : [1]: 0x11100e0d0c0b0a09  [0]: 0x0807060504030201  
(spike) vreg 0 2
VLEN=128 bits; ELEN=64 bits
v2  : [1]: 0x22201c1a18161412  [0]: 0x100e0c0a08060402  
(spike) 
```

As we can see from the output, the source registers v0 and v1 have both been loaded
with the numbers 0x01, 0x02, ..., 0x11.

The add operation is performed and the result is placed into the target reguster v2.

The register v2 is output. The resulting value is:

```
v2  : [1]: 0x22201c1a18161412  [0]: 0x100e0c0a08060402
```

This means that the individual elements have been added by the vectored vadd.vv instruction.

The spike simulator is stopped using quit.

```
(spike) quit
```

## 03 - Strip Mining

Strip Mining is iterating over large vectors that are too large to fit into the vector registers of the vector extension. In each interation, a fraction of the large vector is placed into the vector extension registers and the requested operation (add, sub, ...) is performed on the subset, until the large vectors are processed overall.

An important question is how to deal with the situation in which the large vector is not a full multiple of the vector register size. Meaning in the last iteration, only a small amount of elements need to processed. In order to take care of this case, in strip mining the vsetvli instruction is called in each iteration and not only once at the beginning.

The idea of calling vsetvli each iteration is that in each iteration the user specifies the amount of elements that are left for processing via the second parameter to vsetvli and the vector engine returns the amount of elements it will process this iteration via the first parameter of vsetvli.

Let's run the example in Spike.

Single step until the following instruction is executed:

```
la a1, testdata + 0
```

First, once single stepping has reached the load of vector 0's address into a0 display the address that is now stored in register a1.

```
(spike) reg 0 a1
0x00000000800034a0
```

You need very sharp eyes to read this address! You need to be able to tell zeroes apart from eights. The address above is: 0x800034a0. The easisest way is to just copy the entire address so you do not make any mistakes typeing in the address later.

Now let's check what data is stored at that address:

```
(spike) mem 0 0x800034a0
0x0807060504030201
```

These are the first 64 bits of testdata as expected.

We can use what we just learn about memory after the strip mining is done in order to check that strip mining has computed correct results.

Because the pointer to the result data is stored in a3 and a3 is moved as strip mining progresses, it is important to read the address of a3 before strip mining begins so we can learn about the address where the result data is stored before the pointer to the result data is moved around.

Retrieve the address of the result symbol where the result will be stored.
The address is stored in register a3.

```
(spike) reg 0 a3
0x00000000800030a0
```

Single step until the entire strip mining of all 12 values has been performed.

Now check the data at the address

```
(spike) mem 0 0x800030a0
0x100e0c0a08060402
(spike) mem 0 0x800030a8
0x22201c1a18161412
(spike) mem 0 0x800030b0
0x32302e2c2a282624
(spike) mem 0 0x800030b8
0x42403e3c3a383634
(spike) mem 0 0x800030c0
0x52504e4c4a484644
(spike) mem 0 0x800030c8 
0x62605e5c5a585654
(spike) mem 0 0x800030d0
0x0000000000000000
```

This shows that strip mining has succesfully added all data of the large vectors using the vector registers of the vector extension.
