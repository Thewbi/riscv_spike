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



# RISC-V Vector Extension Tutorial

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

## Loading data into the Vector Extension Registers

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