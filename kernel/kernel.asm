
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	22813103          	ld	sp,552(sp) # 8000a228 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdae5f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	246020ef          	jal	80002358 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00012517          	auipc	a0,0x12
    80000190:	0f450513          	addi	a0,a0,244 # 80012280 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	0e848493          	addi	s1,s1,232 # 80012280 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	17890913          	addi	s2,s2,376 # 80012318 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	72a010ef          	jal	800018e2 <myproc>
    800001bc:	02e020ef          	jal	800021ea <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	5ed010ef          	jal	80001fb2 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00012717          	auipc	a4,0x12
    800001dc:	0a870713          	addi	a4,a4,168 # 80012280 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	104020ef          	jal	8000230e <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00012517          	auipc	a0,0x12
    80000226:	05e50513          	addi	a0,a0,94 # 80012280 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00012717          	auipc	a4,0x12
    80000250:	0cf72623          	sw	a5,204(a4) # 80012318 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00012517          	auipc	a0,0x12
    80000266:	01e50513          	addi	a0,a0,30 # 80012280 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00012517          	auipc	a0,0x12
    800002ba:	fca50513          	addi	a0,a0,-54 # 80012280 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	0ca020ef          	jal	800023a2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00012517          	auipc	a0,0x12
    800002e0:	fa450513          	addi	a0,a0,-92 # 80012280 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00012717          	auipc	a4,0x12
    800002fe:	f8670713          	addi	a4,a4,-122 # 80012280 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00012797          	auipc	a5,0x12
    80000324:	f6078793          	addi	a5,a5,-160 # 80012280 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00012797          	auipc	a5,0x12
    80000352:	fca7a783          	lw	a5,-54(a5) # 80012318 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00012717          	auipc	a4,0x12
    80000368:	f1c70713          	addi	a4,a4,-228 # 80012280 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00012497          	auipc	s1,0x12
    80000378:	f0c48493          	addi	s1,s1,-244 # 80012280 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	eca70713          	addi	a4,a4,-310 # 80012280 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	f4f72a23          	sw	a5,-172(a4) # 80012320 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00012797          	auipc	a5,0x12
    800003ee:	e9678793          	addi	a5,a5,-362 # 80012280 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00012797          	auipc	a5,0x12
    80000412:	f0c7a723          	sw	a2,-242(a5) # 8001231c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00012517          	auipc	a0,0x12
    8000041a:	f0250513          	addi	a0,a0,-254 # 80012318 <cons+0x98>
    8000041e:	3e1010ef          	jal	80001ffe <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	00012517          	auipc	a0,0x12
    80000438:	e4c50513          	addi	a0,a0,-436 # 80012280 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00022797          	auipc	a5,0x22
    80000448:	3c478793          	addi	a5,a5,964 # 80022808 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	29a60613          	addi	a2,a2,666 # 80007718 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	d2c7a783          	lw	a5,-724(a5) # 8000a244 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00012517          	auipc	a0,0x12
    80000564:	dc850513          	addi	a0,a0,-568 # 80012328 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	ff0b8b93          	addi	s7,s7,-16 # 80007718 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	0000a797          	auipc	a5,0xa
    800007c0:	a887a783          	lw	a5,-1400(a5) # 8000a244 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00012517          	auipc	a0,0x12
    800007d6:	b5650513          	addi	a0,a0,-1194 # 80012328 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	0000a797          	auipc	a5,0xa
    800007f4:	a527aa23          	sw	s2,-1452(a5) # 8000a244 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	0000a797          	auipc	a5,0xa
    80000816:	a327a723          	sw	s2,-1490(a5) # 8000a240 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	00012517          	auipc	a0,0x12
    80000830:	afc50513          	addi	a0,a0,-1284 # 80012328 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	00012517          	auipc	a0,0x12
    80000888:	abc50513          	addi	a0,a0,-1348 # 80012340 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00012517          	auipc	a0,0x12
    800008ac:	a9850513          	addi	a0,a0,-1384 # 80012340 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	0000a497          	auipc	s1,0xa
    800008ca:	98648493          	addi	s1,s1,-1658 # 8000a24c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00012997          	auipc	s3,0x12
    800008d2:	a7298993          	addi	s3,s3,-1422 # 80012340 <tx_lock>
    800008d6:	0000a917          	auipc	s2,0xa
    800008da:	97290913          	addi	s2,s2,-1678 # 8000a248 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	6c8010ef          	jal	80001fb2 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00012517          	auipc	a0,0x12
    80000918:	a2c50513          	addi	a0,a0,-1492 # 80012340 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	0000a797          	auipc	a5,0xa
    8000093c:	90c7a783          	lw	a5,-1780(a5) # 8000a244 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000a797          	auipc	a5,0xa
    80000946:	8fe7a783          	lw	a5,-1794(a5) # 8000a240 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	0000a797          	auipc	a5,0xa
    8000096c:	8dc7a783          	lw	a5,-1828(a5) # 8000a244 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00012517          	auipc	a0,0x12
    800009c8:	97c50513          	addi	a0,a0,-1668 # 80012340 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00012517          	auipc	a0,0x12
    800009e4:	96050513          	addi	a0,a0,-1696 # 80012340 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	0000a797          	auipc	a5,0xa
    800009f4:	8407ae23          	sw	zero,-1956(a5) # 8000a24c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	0000a517          	auipc	a0,0xa
    800009fc:	85050513          	addi	a0,a0,-1968 # 8000a248 <tx_chan>
    80000a00:	5fe010ef          	jal	80001ffe <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00023797          	auipc	a5,0x23
    80000a34:	f7078793          	addi	a5,a5,-144 # 800239a0 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	00012917          	auipc	s2,0x12
    80000a50:	90c90913          	addi	s2,s2,-1780 # 80012358 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	00012517          	auipc	a0,0x12
    80000ade:	87e50513          	addi	a0,a0,-1922 # 80012358 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00023517          	auipc	a0,0x23
    80000aee:	eb650513          	addi	a0,a0,-330 # 800239a0 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	00012497          	auipc	s1,0x12
    80000b0c:	85048493          	addi	s1,s1,-1968 # 80012358 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00012517          	auipc	a0,0x12
    80000b20:	83c50513          	addi	a0,a0,-1988 # 80012358 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00012517          	auipc	a0,0x12
    80000b44:	81850513          	addi	a0,a0,-2024 # 80012358 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	54f000ef          	jal	800018c6 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	521000ef          	jal	800018c6 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	519000ef          	jal	800018c6 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	505000ef          	jal	800018c6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf6:	4d1000ef          	jal	800018c6 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	4ad000ef          	jal	800018c6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c80:	0310000f          	fence	rw,w
    80000c84:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb661>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	273000ef          	jal	800018b6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00009717          	auipc	a4,0x9
    80000e4c:	40870713          	addi	a4,a4,1032 # 8000a250 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e5c:	25b000ef          	jal	800018b6 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	662010ef          	jal	800024d4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	6d2040ef          	jal	80005548 <plicinithart>
  }

  scheduler();        
    80000e7a:	73d000ef          	jal	80001db6 <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	1da50513          	addi	a0,a0,474 # 80007078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	137000ef          	jal	800017ec <procinit>
    trapinit();      // trap vectors
    80000eba:	5f6010ef          	jal	800024b0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	616010ef          	jal	800024d4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	66c040ef          	jal	8000552e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	682040ef          	jal	80005548 <plicinithart>
    binit();         // buffer cache
    80000eca:	53f010ef          	jal	80002c08 <binit>
    iinit();         // inode table
    80000ece:	2c4020ef          	jal	80003192 <iinit>
    fileinit();      // file table
    80000ed2:	1b6030ef          	jal	80004088 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	762040ef          	jal	80005638 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4db000ef          	jal	80001bb4 <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00009717          	auipc	a4,0x9
    80000ee8:	36f72623          	sw	a5,876(a4) # 8000a250 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	00009797          	auipc	a5,0x9
    80000efc:	3607b783          	ld	a5,864(a5) # 8000a258 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17450513          	addi	a0,a0,372 # 800070b0 <etext+0xb0>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb657>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00006517          	auipc	a0,0x6
    80001056:	06650513          	addi	a0,a0,102 # 800070b8 <etext+0xb8>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	07a50513          	addi	a0,a0,122 # 800070d8 <etext+0xd8>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00006517          	auipc	a0,0x6
    8000106e:	08e50513          	addi	a0,a0,142 # 800070f8 <etext+0xf8>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	09250513          	addi	a0,a0,146 # 80007108 <etext+0x108>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	05e50513          	addi	a0,a0,94 # 80007118 <etext+0x118>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00006917          	auipc	s2,0x6
    8000111c:	ee890913          	addi	s2,s2,-280 # 80007000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80006697          	auipc	a3,0x80006
    80001126:	ede68693          	addi	a3,a3,-290 # 7000 <_entry-0x7fff9000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00005617          	auipc	a2,0x5
    80001152:	eb260613          	addi	a2,a2,-334 # 80006000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	5ee000ef          	jal	80001754 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	00009797          	auipc	a5,0x9
    80001188:	0ca7ba23          	sd	a0,212(a5) # 8000a258 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00006517          	auipc	a0,0x6
    800011f8:	f2c50513          	addi	a0,a0,-212 # 80007120 <etext+0x120>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00006517          	auipc	a0,0x6
    80001370:	dcc50513          	addi	a0,a0,-564 # 80007138 <etext+0x138>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00006517          	auipc	a0,0x6
    80001480:	ccc50513          	addi	a0,a0,-820 # 80007148 <etext+0x148>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	372000ef          	jal	800018e2 <myproc>
  if (va >= p->sz)
    80001574:	653c                	ld	a5,72(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05093503          	ld	a0,80(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001754:	7139                	addi	sp,sp,-64
    80001756:	fc06                	sd	ra,56(sp)
    80001758:	f822                	sd	s0,48(sp)
    8000175a:	f426                	sd	s1,40(sp)
    8000175c:	f04a                	sd	s2,32(sp)
    8000175e:	ec4e                	sd	s3,24(sp)
    80001760:	e852                	sd	s4,16(sp)
    80001762:	e456                	sd	s5,8(sp)
    80001764:	e05a                	sd	s6,0(sp)
    80001766:	0080                	addi	s0,sp,64
    80001768:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	00011497          	auipc	s1,0x11
    8000176e:	05648493          	addi	s1,s1,86 # 800127c0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	00a36937          	lui	s2,0xa36
    80001778:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    8000177c:	0932                	slli	s2,s2,0xc
    8000177e:	46d90913          	addi	s2,s2,1133
    80001782:	0936                	slli	s2,s2,0xd
    80001784:	df590913          	addi	s2,s2,-523
    80001788:	093a                	slli	s2,s2,0xe
    8000178a:	6cf90913          	addi	s2,s2,1743
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00017a97          	auipc	s5,0x17
    8000179a:	e2aa8a93          	addi	s5,s5,-470 # 800185c0 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	858d                	srai	a1,a1,0x3
    800017ac:	032585b3          	mul	a1,a1,s2
    800017b0:	2585                	addiw	a1,a1,1
    800017b2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017b6:	4719                	li	a4,6
    800017b8:	6685                	lui	a3,0x1
    800017ba:	40b985b3          	sub	a1,s3,a1
    800017be:	8552                	mv	a0,s4
    800017c0:	8dfff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	17848493          	addi	s1,s1,376
    800017c8:	fd549be3          	bne	s1,s5,8000179e <proc_mapstacks+0x4a>
  }
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6b02                	ld	s6,0(sp)
    800017dc:	6121                	addi	sp,sp,64
    800017de:	8082                	ret
      panic("kalloc");
    800017e0:	00006517          	auipc	a0,0x6
    800017e4:	97850513          	addi	a0,a0,-1672 # 80007158 <etext+0x158>
    800017e8:	ff9fe0ef          	jal	800007e0 <panic>

00000000800017ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017ec:	7139                	addi	sp,sp,-64
    800017ee:	fc06                	sd	ra,56(sp)
    800017f0:	f822                	sd	s0,48(sp)
    800017f2:	f426                	sd	s1,40(sp)
    800017f4:	f04a                	sd	s2,32(sp)
    800017f6:	ec4e                	sd	s3,24(sp)
    800017f8:	e852                	sd	s4,16(sp)
    800017fa:	e456                	sd	s5,8(sp)
    800017fc:	e05a                	sd	s6,0(sp)
    800017fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001800:	00006597          	auipc	a1,0x6
    80001804:	96058593          	addi	a1,a1,-1696 # 80007160 <etext+0x160>
    80001808:	00011517          	auipc	a0,0x11
    8000180c:	b7050513          	addi	a0,a0,-1168 # 80012378 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	00011517          	auipc	a0,0x11
    80001820:	b7450513          	addi	a0,a0,-1164 # 80012390 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  initlock(&mlfq_lock, "mlfq");
    80001828:	00006597          	auipc	a1,0x6
    8000182c:	95058593          	addi	a1,a1,-1712 # 80007178 <etext+0x178>
    80001830:	00011517          	auipc	a0,0x11
    80001834:	b7850513          	addi	a0,a0,-1160 # 800123a8 <mlfq_lock>
    80001838:	b16ff0ef          	jal	80000b4e <initlock>
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	00011497          	auipc	s1,0x11
    80001840:	f8448493          	addi	s1,s1,-124 # 800127c0 <proc>
      initlock(&p->lock, "proc");
    80001844:	00006b17          	auipc	s6,0x6
    80001848:	93cb0b13          	addi	s6,s6,-1732 # 80007180 <etext+0x180>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184c:	8aa6                	mv	s5,s1
    8000184e:	00a36937          	lui	s2,0xa36
    80001852:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    80001856:	0932                	slli	s2,s2,0xc
    80001858:	46d90913          	addi	s2,s2,1133
    8000185c:	0936                	slli	s2,s2,0xd
    8000185e:	df590913          	addi	s2,s2,-523
    80001862:	093a                	slli	s2,s2,0xe
    80001864:	6cf90913          	addi	s2,s2,1743
    80001868:	040009b7          	lui	s3,0x4000
    8000186c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001870:	00017a17          	auipc	s4,0x17
    80001874:	d50a0a13          	addi	s4,s4,-688 # 800185c0 <tickslock>
      initlock(&p->lock, "proc");
    80001878:	85da                	mv	a1,s6
    8000187a:	8526                	mv	a0,s1
    8000187c:	ad2ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    80001880:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001884:	415487b3          	sub	a5,s1,s5
    80001888:	878d                	srai	a5,a5,0x3
    8000188a:	032787b3          	mul	a5,a5,s2
    8000188e:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdb661>
    80001890:	00d7979b          	slliw	a5,a5,0xd
    80001894:	40f987b3          	sub	a5,s3,a5
    80001898:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	17848493          	addi	s1,s1,376
    8000189e:	fd449de3          	bne	s1,s4,80001878 <procinit+0x8c>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	addi	sp,sp,64
    800018b4:	8082                	ret

00000000800018b6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b6:	1141                	addi	sp,sp,-16
    800018b8:	e422                	sd	s0,8(sp)
    800018ba:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018bc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018be:	2501                	sext.w	a0,a0
    800018c0:	6422                	ld	s0,8(sp)
    800018c2:	0141                	addi	sp,sp,16
    800018c4:	8082                	ret

00000000800018c6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c6:	1141                	addi	sp,sp,-16
    800018c8:	e422                	sd	s0,8(sp)
    800018ca:	0800                	addi	s0,sp,16
    800018cc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ce:	2781                	sext.w	a5,a5
    800018d0:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d2:	00011517          	auipc	a0,0x11
    800018d6:	aee50513          	addi	a0,a0,-1298 # 800123c0 <cpus>
    800018da:	953e                	add	a0,a0,a5
    800018dc:	6422                	ld	s0,8(sp)
    800018de:	0141                	addi	sp,sp,16
    800018e0:	8082                	ret

00000000800018e2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e2:	1101                	addi	sp,sp,-32
    800018e4:	ec06                	sd	ra,24(sp)
    800018e6:	e822                	sd	s0,16(sp)
    800018e8:	e426                	sd	s1,8(sp)
    800018ea:	1000                	addi	s0,sp,32
  push_off();
    800018ec:	aa2ff0ef          	jal	80000b8e <push_off>
    800018f0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f2:	2781                	sext.w	a5,a5
    800018f4:	079e                	slli	a5,a5,0x7
    800018f6:	00011717          	auipc	a4,0x11
    800018fa:	a8270713          	addi	a4,a4,-1406 # 80012378 <pid_lock>
    800018fe:	97ba                	add	a5,a5,a4
    80001900:	67a4                	ld	s1,72(a5)
  pop_off();
    80001902:	b10ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    80001906:	8526                	mv	a0,s1
    80001908:	60e2                	ld	ra,24(sp)
    8000190a:	6442                	ld	s0,16(sp)
    8000190c:	64a2                	ld	s1,8(sp)
    8000190e:	6105                	addi	sp,sp,32
    80001910:	8082                	ret

0000000080001912 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001912:	7179                	addi	sp,sp,-48
    80001914:	f406                	sd	ra,40(sp)
    80001916:	f022                	sd	s0,32(sp)
    80001918:	ec26                	sd	s1,24(sp)
    8000191a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000191c:	fc7ff0ef          	jal	800018e2 <myproc>
    80001920:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001922:	b44ff0ef          	jal	80000c66 <release>

  if (first) {
    80001926:	00009797          	auipc	a5,0x9
    8000192a:	8da7a783          	lw	a5,-1830(a5) # 8000a200 <first.1>
    8000192e:	cf8d                	beqz	a5,80001968 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001930:	4505                	li	a0,1
    80001932:	51d010ef          	jal	8000364e <fsinit>

    first = 0;
    80001936:	00009797          	auipc	a5,0x9
    8000193a:	8c07a523          	sw	zero,-1846(a5) # 8000a200 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000193e:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001942:	00006517          	auipc	a0,0x6
    80001946:	84650513          	addi	a0,a0,-1978 # 80007188 <etext+0x188>
    8000194a:	fca43823          	sd	a0,-48(s0)
    8000194e:	fc043c23          	sd	zero,-40(s0)
    80001952:	fd040593          	addi	a1,s0,-48
    80001956:	603020ef          	jal	80004758 <kexec>
    8000195a:	6cbc                	ld	a5,88(s1)
    8000195c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000195e:	6cbc                	ld	a5,88(s1)
    80001960:	7bb8                	ld	a4,112(a5)
    80001962:	57fd                	li	a5,-1
    80001964:	02f70d63          	beq	a4,a5,8000199e <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001968:	385000ef          	jal	800024ec <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000196c:	68a8                	ld	a0,80(s1)
    8000196e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001970:	04000737          	lui	a4,0x4000
    80001974:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001976:	0732                	slli	a4,a4,0xc
    80001978:	00004797          	auipc	a5,0x4
    8000197c:	72478793          	addi	a5,a5,1828 # 8000609c <userret>
    80001980:	00004697          	auipc	a3,0x4
    80001984:	68068693          	addi	a3,a3,1664 # 80006000 <_trampoline>
    80001988:	8f95                	sub	a5,a5,a3
    8000198a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000198c:	577d                	li	a4,-1
    8000198e:	177e                	slli	a4,a4,0x3f
    80001990:	8d59                	or	a0,a0,a4
    80001992:	9782                	jalr	a5
}
    80001994:	70a2                	ld	ra,40(sp)
    80001996:	7402                	ld	s0,32(sp)
    80001998:	64e2                	ld	s1,24(sp)
    8000199a:	6145                	addi	sp,sp,48
    8000199c:	8082                	ret
      panic("exec");
    8000199e:	00005517          	auipc	a0,0x5
    800019a2:	7f250513          	addi	a0,a0,2034 # 80007190 <etext+0x190>
    800019a6:	e3bfe0ef          	jal	800007e0 <panic>

00000000800019aa <allocpid>:
{
    800019aa:	1101                	addi	sp,sp,-32
    800019ac:	ec06                	sd	ra,24(sp)
    800019ae:	e822                	sd	s0,16(sp)
    800019b0:	e426                	sd	s1,8(sp)
    800019b2:	e04a                	sd	s2,0(sp)
    800019b4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019b6:	00011917          	auipc	s2,0x11
    800019ba:	9c290913          	addi	s2,s2,-1598 # 80012378 <pid_lock>
    800019be:	854a                	mv	a0,s2
    800019c0:	a0eff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019c4:	00009797          	auipc	a5,0x9
    800019c8:	84078793          	addi	a5,a5,-1984 # 8000a204 <nextpid>
    800019cc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ce:	0014871b          	addiw	a4,s1,1
    800019d2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019d4:	854a                	mv	a0,s2
    800019d6:	a90ff0ef          	jal	80000c66 <release>
}
    800019da:	8526                	mv	a0,s1
    800019dc:	60e2                	ld	ra,24(sp)
    800019de:	6442                	ld	s0,16(sp)
    800019e0:	64a2                	ld	s1,8(sp)
    800019e2:	6902                	ld	s2,0(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret

00000000800019e8 <proc_pagetable>:
{
    800019e8:	1101                	addi	sp,sp,-32
    800019ea:	ec06                	sd	ra,24(sp)
    800019ec:	e822                	sd	s0,16(sp)
    800019ee:	e426                	sd	s1,8(sp)
    800019f0:	e04a                	sd	s2,0(sp)
    800019f2:	1000                	addi	s0,sp,32
    800019f4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019f6:	f9eff0ef          	jal	80001194 <uvmcreate>
    800019fa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019fc:	cd05                	beqz	a0,80001a34 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019fe:	4729                	li	a4,10
    80001a00:	00004697          	auipc	a3,0x4
    80001a04:	60068693          	addi	a3,a3,1536 # 80006000 <_trampoline>
    80001a08:	6605                	lui	a2,0x1
    80001a0a:	040005b7          	lui	a1,0x4000
    80001a0e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a10:	05b2                	slli	a1,a1,0xc
    80001a12:	ddcff0ef          	jal	80000fee <mappages>
    80001a16:	02054663          	bltz	a0,80001a42 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a1a:	4719                	li	a4,6
    80001a1c:	05893683          	ld	a3,88(s2)
    80001a20:	6605                	lui	a2,0x1
    80001a22:	020005b7          	lui	a1,0x2000
    80001a26:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a28:	05b6                	slli	a1,a1,0xd
    80001a2a:	8526                	mv	a0,s1
    80001a2c:	dc2ff0ef          	jal	80000fee <mappages>
    80001a30:	00054f63          	bltz	a0,80001a4e <proc_pagetable+0x66>
}
    80001a34:	8526                	mv	a0,s1
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6902                	ld	s2,0(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret
    uvmfree(pagetable, 0);
    80001a42:	4581                	li	a1,0
    80001a44:	8526                	mv	a0,s1
    80001a46:	949ff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a4a:	4481                	li	s1,0
    80001a4c:	b7e5                	j	80001a34 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a4e:	4681                	li	a3,0
    80001a50:	4605                	li	a2,1
    80001a52:	040005b7          	lui	a1,0x4000
    80001a56:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a58:	05b2                	slli	a1,a1,0xc
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	f5eff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a60:	4581                	li	a1,0
    80001a62:	8526                	mv	a0,s1
    80001a64:	92bff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a68:	4481                	li	s1,0
    80001a6a:	b7e9                	j	80001a34 <proc_pagetable+0x4c>

0000000080001a6c <proc_freepagetable>:
{
    80001a6c:	1101                	addi	sp,sp,-32
    80001a6e:	ec06                	sd	ra,24(sp)
    80001a70:	e822                	sd	s0,16(sp)
    80001a72:	e426                	sd	s1,8(sp)
    80001a74:	e04a                	sd	s2,0(sp)
    80001a76:	1000                	addi	s0,sp,32
    80001a78:	84aa                	mv	s1,a0
    80001a7a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a7c:	4681                	li	a3,0
    80001a7e:	4605                	li	a2,1
    80001a80:	040005b7          	lui	a1,0x4000
    80001a84:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a86:	05b2                	slli	a1,a1,0xc
    80001a88:	f32ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a8c:	4681                	li	a3,0
    80001a8e:	4605                	li	a2,1
    80001a90:	020005b7          	lui	a1,0x2000
    80001a94:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a96:	05b6                	slli	a1,a1,0xd
    80001a98:	8526                	mv	a0,s1
    80001a9a:	f20ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a9e:	85ca                	mv	a1,s2
    80001aa0:	8526                	mv	a0,s1
    80001aa2:	8edff0ef          	jal	8000138e <uvmfree>
}
    80001aa6:	60e2                	ld	ra,24(sp)
    80001aa8:	6442                	ld	s0,16(sp)
    80001aaa:	64a2                	ld	s1,8(sp)
    80001aac:	6902                	ld	s2,0(sp)
    80001aae:	6105                	addi	sp,sp,32
    80001ab0:	8082                	ret

0000000080001ab2 <freeproc>:
{
    80001ab2:	1101                	addi	sp,sp,-32
    80001ab4:	ec06                	sd	ra,24(sp)
    80001ab6:	e822                	sd	s0,16(sp)
    80001ab8:	e426                	sd	s1,8(sp)
    80001aba:	1000                	addi	s0,sp,32
    80001abc:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001abe:	6d28                	ld	a0,88(a0)
    80001ac0:	c119                	beqz	a0,80001ac6 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001ac2:	f5bfe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ac6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001aca:	68a8                	ld	a0,80(s1)
    80001acc:	c501                	beqz	a0,80001ad4 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ace:	64ac                	ld	a1,72(s1)
    80001ad0:	f9dff0ef          	jal	80001a6c <proc_freepagetable>
  p->pagetable = 0;
    80001ad4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ad8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001adc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ae0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ae4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ae8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001aec:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001af0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001af4:	0004ac23          	sw	zero,24(s1)
}
    80001af8:	60e2                	ld	ra,24(sp)
    80001afa:	6442                	ld	s0,16(sp)
    80001afc:	64a2                	ld	s1,8(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret

0000000080001b02 <allocproc>:
{
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	e04a                	sd	s2,0(sp)
    80001b0c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b0e:	00011497          	auipc	s1,0x11
    80001b12:	cb248493          	addi	s1,s1,-846 # 800127c0 <proc>
    80001b16:	00017917          	auipc	s2,0x17
    80001b1a:	aaa90913          	addi	s2,s2,-1366 # 800185c0 <tickslock>
    acquire(&p->lock);
    80001b1e:	8526                	mv	a0,s1
    80001b20:	8aeff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b24:	4c9c                	lw	a5,24(s1)
    80001b26:	cb91                	beqz	a5,80001b3a <allocproc+0x38>
      release(&p->lock);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	93cff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b2e:	17848493          	addi	s1,s1,376
    80001b32:	ff2496e3          	bne	s1,s2,80001b1e <allocproc+0x1c>
  return 0;
    80001b36:	4481                	li	s1,0
    80001b38:	a0b9                	j	80001b86 <allocproc+0x84>
  p->pid = allocpid();
    80001b3a:	e71ff0ef          	jal	800019aa <allocpid>
    80001b3e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b40:	4785                	li	a5,1
    80001b42:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b44:	fbbfe0ef          	jal	80000afe <kalloc>
    80001b48:	892a                	mv	s2,a0
    80001b4a:	eca8                	sd	a0,88(s1)
    80001b4c:	c521                	beqz	a0,80001b94 <allocproc+0x92>
  p->pagetable = proc_pagetable(p);
    80001b4e:	8526                	mv	a0,s1
    80001b50:	e99ff0ef          	jal	800019e8 <proc_pagetable>
    80001b54:	892a                	mv	s2,a0
    80001b56:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b58:	c531                	beqz	a0,80001ba4 <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80001b5a:	07000613          	li	a2,112
    80001b5e:	4581                	li	a1,0
    80001b60:	06048513          	addi	a0,s1,96
    80001b64:	93eff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b68:	00000797          	auipc	a5,0x0
    80001b6c:	daa78793          	addi	a5,a5,-598 # 80001912 <forkret>
    80001b70:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b72:	60bc                	ld	a5,64(s1)
    80001b74:	6705                	lui	a4,0x1
    80001b76:	97ba                	add	a5,a5,a4
    80001b78:	f4bc                	sd	a5,104(s1)
  p->priority = 0;
    80001b7a:	1604a423          	sw	zero,360(s1)
  p->time_slices = 0;
    80001b7e:	1604a623          	sw	zero,364(s1)
  p->arrival_time = 0;
    80001b82:	1604b823          	sd	zero,368(s1)
}
    80001b86:	8526                	mv	a0,s1
    80001b88:	60e2                	ld	ra,24(sp)
    80001b8a:	6442                	ld	s0,16(sp)
    80001b8c:	64a2                	ld	s1,8(sp)
    80001b8e:	6902                	ld	s2,0(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret
    freeproc(p);
    80001b94:	8526                	mv	a0,s1
    80001b96:	f1dff0ef          	jal	80001ab2 <freeproc>
    release(&p->lock);
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	8caff0ef          	jal	80000c66 <release>
    return 0;
    80001ba0:	84ca                	mv	s1,s2
    80001ba2:	b7d5                	j	80001b86 <allocproc+0x84>
    freeproc(p);
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	f0dff0ef          	jal	80001ab2 <freeproc>
    release(&p->lock);
    80001baa:	8526                	mv	a0,s1
    80001bac:	8baff0ef          	jal	80000c66 <release>
    return 0;
    80001bb0:	84ca                	mv	s1,s2
    80001bb2:	bfd1                	j	80001b86 <allocproc+0x84>

0000000080001bb4 <userinit>:
{
    80001bb4:	1101                	addi	sp,sp,-32
    80001bb6:	ec06                	sd	ra,24(sp)
    80001bb8:	e822                	sd	s0,16(sp)
    80001bba:	e426                	sd	s1,8(sp)
    80001bbc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bbe:	f45ff0ef          	jal	80001b02 <allocproc>
    80001bc2:	84aa                	mv	s1,a0
  initproc = p;
    80001bc4:	00008797          	auipc	a5,0x8
    80001bc8:	6aa7b223          	sd	a0,1700(a5) # 8000a268 <initproc>
  p->cwd = namei("/");
    80001bcc:	00005517          	auipc	a0,0x5
    80001bd0:	5cc50513          	addi	a0,a0,1484 # 80007198 <etext+0x198>
    80001bd4:	79d010ef          	jal	80003b70 <namei>
    80001bd8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bdc:	478d                	li	a5,3
    80001bde:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	884ff0ef          	jal	80000c66 <release>
}
    80001be6:	60e2                	ld	ra,24(sp)
    80001be8:	6442                	ld	s0,16(sp)
    80001bea:	64a2                	ld	s1,8(sp)
    80001bec:	6105                	addi	sp,sp,32
    80001bee:	8082                	ret

0000000080001bf0 <growproc>:
{
    80001bf0:	1101                	addi	sp,sp,-32
    80001bf2:	ec06                	sd	ra,24(sp)
    80001bf4:	e822                	sd	s0,16(sp)
    80001bf6:	e426                	sd	s1,8(sp)
    80001bf8:	e04a                	sd	s2,0(sp)
    80001bfa:	1000                	addi	s0,sp,32
    80001bfc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bfe:	ce5ff0ef          	jal	800018e2 <myproc>
    80001c02:	892a                	mv	s2,a0
  sz = p->sz;
    80001c04:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c06:	02905963          	blez	s1,80001c38 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c0a:	00b48633          	add	a2,s1,a1
    80001c0e:	020007b7          	lui	a5,0x2000
    80001c12:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c14:	07b6                	slli	a5,a5,0xd
    80001c16:	02c7ea63          	bltu	a5,a2,80001c4a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c1a:	4691                	li	a3,4
    80001c1c:	6928                	ld	a0,80(a0)
    80001c1e:	e6aff0ef          	jal	80001288 <uvmalloc>
    80001c22:	85aa                	mv	a1,a0
    80001c24:	c50d                	beqz	a0,80001c4e <growproc+0x5e>
  p->sz = sz;
    80001c26:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c2a:	4501                	li	a0,0
}
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6902                	ld	s2,0(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret
  } else if(n < 0){
    80001c38:	fe04d7e3          	bgez	s1,80001c26 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c3c:	00b48633          	add	a2,s1,a1
    80001c40:	6928                	ld	a0,80(a0)
    80001c42:	e02ff0ef          	jal	80001244 <uvmdealloc>
    80001c46:	85aa                	mv	a1,a0
    80001c48:	bff9                	j	80001c26 <growproc+0x36>
      return -1;
    80001c4a:	557d                	li	a0,-1
    80001c4c:	b7c5                	j	80001c2c <growproc+0x3c>
      return -1;
    80001c4e:	557d                	li	a0,-1
    80001c50:	bff1                	j	80001c2c <growproc+0x3c>

0000000080001c52 <kfork>:
{
    80001c52:	7139                	addi	sp,sp,-64
    80001c54:	fc06                	sd	ra,56(sp)
    80001c56:	f822                	sd	s0,48(sp)
    80001c58:	f04a                	sd	s2,32(sp)
    80001c5a:	e456                	sd	s5,8(sp)
    80001c5c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c5e:	c85ff0ef          	jal	800018e2 <myproc>
    80001c62:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c64:	e9fff0ef          	jal	80001b02 <allocproc>
    80001c68:	0e050a63          	beqz	a0,80001d5c <kfork+0x10a>
    80001c6c:	e852                	sd	s4,16(sp)
    80001c6e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c70:	048ab603          	ld	a2,72(s5)
    80001c74:	692c                	ld	a1,80(a0)
    80001c76:	050ab503          	ld	a0,80(s5)
    80001c7a:	f46ff0ef          	jal	800013c0 <uvmcopy>
    80001c7e:	04054a63          	bltz	a0,80001cd2 <kfork+0x80>
    80001c82:	f426                	sd	s1,40(sp)
    80001c84:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c86:	048ab783          	ld	a5,72(s5)
    80001c8a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c8e:	058ab683          	ld	a3,88(s5)
    80001c92:	87b6                	mv	a5,a3
    80001c94:	058a3703          	ld	a4,88(s4)
    80001c98:	12068693          	addi	a3,a3,288
    80001c9c:	0007b803          	ld	a6,0(a5)
    80001ca0:	6788                	ld	a0,8(a5)
    80001ca2:	6b8c                	ld	a1,16(a5)
    80001ca4:	6f90                	ld	a2,24(a5)
    80001ca6:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001caa:	e708                	sd	a0,8(a4)
    80001cac:	eb0c                	sd	a1,16(a4)
    80001cae:	ef10                	sd	a2,24(a4)
    80001cb0:	02078793          	addi	a5,a5,32
    80001cb4:	02070713          	addi	a4,a4,32
    80001cb8:	fed792e3          	bne	a5,a3,80001c9c <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001cbc:	058a3783          	ld	a5,88(s4)
    80001cc0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cc4:	0d0a8493          	addi	s1,s5,208
    80001cc8:	0d0a0913          	addi	s2,s4,208
    80001ccc:	150a8993          	addi	s3,s5,336
    80001cd0:	a831                	j	80001cec <kfork+0x9a>
    freeproc(np);
    80001cd2:	8552                	mv	a0,s4
    80001cd4:	ddfff0ef          	jal	80001ab2 <freeproc>
    release(&np->lock);
    80001cd8:	8552                	mv	a0,s4
    80001cda:	f8dfe0ef          	jal	80000c66 <release>
    return -1;
    80001cde:	597d                	li	s2,-1
    80001ce0:	6a42                	ld	s4,16(sp)
    80001ce2:	a0b5                	j	80001d4e <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ce4:	04a1                	addi	s1,s1,8
    80001ce6:	0921                	addi	s2,s2,8
    80001ce8:	01348963          	beq	s1,s3,80001cfa <kfork+0xa8>
    if(p->ofile[i])
    80001cec:	6088                	ld	a0,0(s1)
    80001cee:	d97d                	beqz	a0,80001ce4 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cf0:	41a020ef          	jal	8000410a <filedup>
    80001cf4:	00a93023          	sd	a0,0(s2)
    80001cf8:	b7f5                	j	80001ce4 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cfa:	150ab503          	ld	a0,336(s5)
    80001cfe:	626010ef          	jal	80003324 <idup>
    80001d02:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d06:	4641                	li	a2,16
    80001d08:	158a8593          	addi	a1,s5,344
    80001d0c:	158a0513          	addi	a0,s4,344
    80001d10:	8d0ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001d14:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001d18:	8552                	mv	a0,s4
    80001d1a:	f4dfe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001d1e:	00010497          	auipc	s1,0x10
    80001d22:	67248493          	addi	s1,s1,1650 # 80012390 <wait_lock>
    80001d26:	8526                	mv	a0,s1
    80001d28:	ea7fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d2c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d30:	8526                	mv	a0,s1
    80001d32:	f35fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d36:	8552                	mv	a0,s4
    80001d38:	e97fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d3c:	478d                	li	a5,3
    80001d3e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d42:	8552                	mv	a0,s4
    80001d44:	f23fe0ef          	jal	80000c66 <release>
  return pid;
    80001d48:	74a2                	ld	s1,40(sp)
    80001d4a:	69e2                	ld	s3,24(sp)
    80001d4c:	6a42                	ld	s4,16(sp)
}
    80001d4e:	854a                	mv	a0,s2
    80001d50:	70e2                	ld	ra,56(sp)
    80001d52:	7442                	ld	s0,48(sp)
    80001d54:	7902                	ld	s2,32(sp)
    80001d56:	6aa2                	ld	s5,8(sp)
    80001d58:	6121                	addi	sp,sp,64
    80001d5a:	8082                	ret
    return -1;
    80001d5c:	597d                	li	s2,-1
    80001d5e:	bfc5                	j	80001d4e <kfork+0xfc>

0000000080001d60 <boost_all_priorities>:
{
    80001d60:	7179                	addi	sp,sp,-48
    80001d62:	f406                	sd	ra,40(sp)
    80001d64:	f022                	sd	s0,32(sp)
    80001d66:	ec26                	sd	s1,24(sp)
    80001d68:	e84a                	sd	s2,16(sp)
    80001d6a:	e44e                	sd	s3,8(sp)
    80001d6c:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d6e:	00011497          	auipc	s1,0x11
    80001d72:	a5248493          	addi	s1,s1,-1454 # 800127c0 <proc>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001d76:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d78:	00017917          	auipc	s2,0x17
    80001d7c:	84890913          	addi	s2,s2,-1976 # 800185c0 <tickslock>
    80001d80:	a801                	j	80001d90 <boost_all_priorities+0x30>
    release(&p->lock);
    80001d82:	8526                	mv	a0,s1
    80001d84:	ee3fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d88:	17848493          	addi	s1,s1,376
    80001d8c:	01248e63          	beq	s1,s2,80001da8 <boost_all_priorities+0x48>
    acquire(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	e3dfe0ef          	jal	80000bce <acquire>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001d96:	4c9c                	lw	a5,24(s1)
    80001d98:	37f9                	addiw	a5,a5,-2
    80001d9a:	fef9e4e3          	bltu	s3,a5,80001d82 <boost_all_priorities+0x22>
      p->priority = 0;
    80001d9e:	1604a423          	sw	zero,360(s1)
      p->time_slices = 0;
    80001da2:	1604a623          	sw	zero,364(s1)
    80001da6:	bff1                	j	80001d82 <boost_all_priorities+0x22>
}
    80001da8:	70a2                	ld	ra,40(sp)
    80001daa:	7402                	ld	s0,32(sp)
    80001dac:	64e2                	ld	s1,24(sp)
    80001dae:	6942                	ld	s2,16(sp)
    80001db0:	69a2                	ld	s3,8(sp)
    80001db2:	6145                	addi	sp,sp,48
    80001db4:	8082                	ret

0000000080001db6 <scheduler>:
{
    80001db6:	711d                	addi	sp,sp,-96
    80001db8:	ec86                	sd	ra,88(sp)
    80001dba:	e8a2                	sd	s0,80(sp)
    80001dbc:	e4a6                	sd	s1,72(sp)
    80001dbe:	e0ca                	sd	s2,64(sp)
    80001dc0:	fc4e                	sd	s3,56(sp)
    80001dc2:	f852                	sd	s4,48(sp)
    80001dc4:	f456                	sd	s5,40(sp)
    80001dc6:	f05a                	sd	s6,32(sp)
    80001dc8:	ec5e                	sd	s7,24(sp)
    80001dca:	e862                	sd	s8,16(sp)
    80001dcc:	e466                	sd	s9,8(sp)
    80001dce:	e06a                	sd	s10,0(sp)
    80001dd0:	1080                	addi	s0,sp,96
    80001dd2:	8792                	mv	a5,tp
  int id = r_tp();
    80001dd4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dd6:	00779b93          	slli	s7,a5,0x7
    80001dda:	00010717          	auipc	a4,0x10
    80001dde:	59e70713          	addi	a4,a4,1438 # 80012378 <pid_lock>
    80001de2:	975e                	add	a4,a4,s7
    80001de4:	04073423          	sd	zero,72(a4)
          swtch(&c->context, &p->context);
    80001de8:	00010717          	auipc	a4,0x10
    80001dec:	5e070713          	addi	a4,a4,1504 # 800123c8 <cpus+0x8>
    80001df0:	9bba                	add	s7,s7,a4
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001df2:	00008c97          	auipc	s9,0x8
    80001df6:	46ec8c93          	addi	s9,s9,1134 # 8000a260 <last_boost_time>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001dfa:	00016997          	auipc	s3,0x16
    80001dfe:	7c698993          	addi	s3,s3,1990 # 800185c0 <tickslock>
          c->proc = p;
    80001e02:	079e                	slli	a5,a5,0x7
    80001e04:	00010a97          	auipc	s5,0x10
    80001e08:	574a8a93          	addi	s5,s5,1396 # 80012378 <pid_lock>
    80001e0c:	9abe                	add	s5,s5,a5
    80001e0e:	a809                	j	80001e20 <scheduler+0x6a>
      release(&tickslock);
    80001e10:	855a                	mv	a0,s6
    80001e12:	e55fe0ef          	jal	80000c66 <release>
    80001e16:	a871                	j	80001eb2 <scheduler+0xfc>
    80001e18:	4785                	li	a5,1
    if(found == 0) {
    80001e1a:	efb1                	bnez	a5,80001e76 <scheduler+0xc0>
      asm volatile("wfi");
    80001e1c:	10500073          	wfi
    acquire(&tickslock);
    80001e20:	00016b17          	auipc	s6,0x16
    80001e24:	7a0b0b13          	addi	s6,s6,1952 # 800185c0 <tickslock>
    uint64 current_ticks = ticks;
    80001e28:	00008d17          	auipc	s10,0x8
    80001e2c:	448d0d13          	addi	s10,s10,1096 # 8000a270 <ticks>
    80001e30:	a099                	j	80001e76 <scheduler+0xc0>
        release(&p->lock);
    80001e32:	8526                	mv	a0,s1
    80001e34:	e33fe0ef          	jal	80000c66 <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e38:	17848493          	addi	s1,s1,376
    80001e3c:	09348363          	beq	s1,s3,80001ec2 <scheduler+0x10c>
        acquire(&p->lock);
    80001e40:	8526                	mv	a0,s1
    80001e42:	d8dfe0ef          	jal	80000bce <acquire>
        if(p->state == RUNNABLE && p->priority == priority) {
    80001e46:	4c9c                	lw	a5,24(s1)
    80001e48:	ff2795e3          	bne	a5,s2,80001e32 <scheduler+0x7c>
    80001e4c:	1684a783          	lw	a5,360(s1)
    80001e50:	ff4791e3          	bne	a5,s4,80001e32 <scheduler+0x7c>
          p->state = RUNNING;
    80001e54:	4791                	li	a5,4
    80001e56:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    80001e58:	049ab423          	sd	s1,72(s5)
          swtch(&c->context, &p->context);
    80001e5c:	06048593          	addi	a1,s1,96
    80001e60:	855e                	mv	a0,s7
    80001e62:	5e4000ef          	jal	80002446 <swtch>
          c->proc = 0;
    80001e66:	040ab423          	sd	zero,72(s5)
          release(&p->lock);
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	dfbfe0ef          	jal	80000c66 <release>
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001e70:	478d                	li	a5,3
    80001e72:	fafa03e3          	beq	s4,a5,80001e18 <scheduler+0x62>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e7a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e7e:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e82:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e86:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e88:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80001e8c:	855a                	mv	a0,s6
    80001e8e:	d41fe0ef          	jal	80000bce <acquire>
    uint64 current_ticks = ticks;
    80001e92:	000d6703          	lwu	a4,0(s10)
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001e96:	000cb783          	ld	a5,0(s9)
    80001e9a:	40f707b3          	sub	a5,a4,a5
    80001e9e:	46f5                	li	a3,29
    80001ea0:	f6f6f8e3          	bgeu	a3,a5,80001e10 <scheduler+0x5a>
      last_boost_time = current_ticks;
    80001ea4:	00ecb023          	sd	a4,0(s9)
      release(&tickslock);
    80001ea8:	855a                	mv	a0,s6
    80001eaa:	dbdfe0ef          	jal	80000c66 <release>
      boost_all_priorities();
    80001eae:	eb3ff0ef          	jal	80001d60 <boost_all_priorities>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001eb2:	4a01                	li	s4,0
        if(p->state == RUNNABLE && p->priority == priority) {
    80001eb4:	490d                	li	s2,3
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001eb6:	4c11                	li	s8,4
      for(p = proc; p < &proc[NPROC]; p++) {
    80001eb8:	00011497          	auipc	s1,0x11
    80001ebc:	90848493          	addi	s1,s1,-1784 # 800127c0 <proc>
    80001ec0:	b741                	j	80001e40 <scheduler+0x8a>
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001ec2:	2a05                	addiw	s4,s4,1
    80001ec4:	ff8a1ae3          	bne	s4,s8,80001eb8 <scheduler+0x102>
    80001ec8:	4781                	li	a5,0
    80001eca:	bf81                	j	80001e1a <scheduler+0x64>

0000000080001ecc <sched>:
{
    80001ecc:	7179                	addi	sp,sp,-48
    80001ece:	f406                	sd	ra,40(sp)
    80001ed0:	f022                	sd	s0,32(sp)
    80001ed2:	ec26                	sd	s1,24(sp)
    80001ed4:	e84a                	sd	s2,16(sp)
    80001ed6:	e44e                	sd	s3,8(sp)
    80001ed8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001eda:	a09ff0ef          	jal	800018e2 <myproc>
    80001ede:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ee0:	c85fe0ef          	jal	80000b64 <holding>
    80001ee4:	c92d                	beqz	a0,80001f56 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ee6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ee8:	2781                	sext.w	a5,a5
    80001eea:	079e                	slli	a5,a5,0x7
    80001eec:	00010717          	auipc	a4,0x10
    80001ef0:	48c70713          	addi	a4,a4,1164 # 80012378 <pid_lock>
    80001ef4:	97ba                	add	a5,a5,a4
    80001ef6:	0c07a703          	lw	a4,192(a5)
    80001efa:	4785                	li	a5,1
    80001efc:	06f71363          	bne	a4,a5,80001f62 <sched+0x96>
  if(p->state == RUNNING)
    80001f00:	4c98                	lw	a4,24(s1)
    80001f02:	4791                	li	a5,4
    80001f04:	06f70563          	beq	a4,a5,80001f6e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f08:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f0c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f0e:	e7b5                	bnez	a5,80001f7a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f10:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f12:	00010917          	auipc	s2,0x10
    80001f16:	46690913          	addi	s2,s2,1126 # 80012378 <pid_lock>
    80001f1a:	2781                	sext.w	a5,a5
    80001f1c:	079e                	slli	a5,a5,0x7
    80001f1e:	97ca                	add	a5,a5,s2
    80001f20:	0c47a983          	lw	s3,196(a5)
    80001f24:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f26:	2781                	sext.w	a5,a5
    80001f28:	079e                	slli	a5,a5,0x7
    80001f2a:	00010597          	auipc	a1,0x10
    80001f2e:	49e58593          	addi	a1,a1,1182 # 800123c8 <cpus+0x8>
    80001f32:	95be                	add	a1,a1,a5
    80001f34:	06048513          	addi	a0,s1,96
    80001f38:	50e000ef          	jal	80002446 <swtch>
    80001f3c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f3e:	2781                	sext.w	a5,a5
    80001f40:	079e                	slli	a5,a5,0x7
    80001f42:	993e                	add	s2,s2,a5
    80001f44:	0d392223          	sw	s3,196(s2)
}
    80001f48:	70a2                	ld	ra,40(sp)
    80001f4a:	7402                	ld	s0,32(sp)
    80001f4c:	64e2                	ld	s1,24(sp)
    80001f4e:	6942                	ld	s2,16(sp)
    80001f50:	69a2                	ld	s3,8(sp)
    80001f52:	6145                	addi	sp,sp,48
    80001f54:	8082                	ret
    panic("sched p->lock");
    80001f56:	00005517          	auipc	a0,0x5
    80001f5a:	24a50513          	addi	a0,a0,586 # 800071a0 <etext+0x1a0>
    80001f5e:	883fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001f62:	00005517          	auipc	a0,0x5
    80001f66:	24e50513          	addi	a0,a0,590 # 800071b0 <etext+0x1b0>
    80001f6a:	877fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001f6e:	00005517          	auipc	a0,0x5
    80001f72:	25250513          	addi	a0,a0,594 # 800071c0 <etext+0x1c0>
    80001f76:	86bfe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001f7a:	00005517          	auipc	a0,0x5
    80001f7e:	25650513          	addi	a0,a0,598 # 800071d0 <etext+0x1d0>
    80001f82:	85ffe0ef          	jal	800007e0 <panic>

0000000080001f86 <yield>:
{
    80001f86:	1101                	addi	sp,sp,-32
    80001f88:	ec06                	sd	ra,24(sp)
    80001f8a:	e822                	sd	s0,16(sp)
    80001f8c:	e426                	sd	s1,8(sp)
    80001f8e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f90:	953ff0ef          	jal	800018e2 <myproc>
    80001f94:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f96:	c39fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001f9a:	478d                	li	a5,3
    80001f9c:	cc9c                	sw	a5,24(s1)
  sched();
    80001f9e:	f2fff0ef          	jal	80001ecc <sched>
  release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	cc3fe0ef          	jal	80000c66 <release>
}
    80001fa8:	60e2                	ld	ra,24(sp)
    80001faa:	6442                	ld	s0,16(sp)
    80001fac:	64a2                	ld	s1,8(sp)
    80001fae:	6105                	addi	sp,sp,32
    80001fb0:	8082                	ret

0000000080001fb2 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001fb2:	7179                	addi	sp,sp,-48
    80001fb4:	f406                	sd	ra,40(sp)
    80001fb6:	f022                	sd	s0,32(sp)
    80001fb8:	ec26                	sd	s1,24(sp)
    80001fba:	e84a                	sd	s2,16(sp)
    80001fbc:	e44e                	sd	s3,8(sp)
    80001fbe:	1800                	addi	s0,sp,48
    80001fc0:	89aa                	mv	s3,a0
    80001fc2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fc4:	91fff0ef          	jal	800018e2 <myproc>
    80001fc8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001fca:	c05fe0ef          	jal	80000bce <acquire>
  release(lk);
    80001fce:	854a                	mv	a0,s2
    80001fd0:	c97fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001fd4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001fd8:	4789                	li	a5,2
    80001fda:	cc9c                	sw	a5,24(s1)

  sched();
    80001fdc:	ef1ff0ef          	jal	80001ecc <sched>

  // Tidy up.
  p->chan = 0;
    80001fe0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001fe4:	8526                	mv	a0,s1
    80001fe6:	c81fe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001fea:	854a                	mv	a0,s2
    80001fec:	be3fe0ef          	jal	80000bce <acquire>
}
    80001ff0:	70a2                	ld	ra,40(sp)
    80001ff2:	7402                	ld	s0,32(sp)
    80001ff4:	64e2                	ld	s1,24(sp)
    80001ff6:	6942                	ld	s2,16(sp)
    80001ff8:	69a2                	ld	s3,8(sp)
    80001ffa:	6145                	addi	sp,sp,48
    80001ffc:	8082                	ret

0000000080001ffe <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001ffe:	7139                	addi	sp,sp,-64
    80002000:	fc06                	sd	ra,56(sp)
    80002002:	f822                	sd	s0,48(sp)
    80002004:	f426                	sd	s1,40(sp)
    80002006:	f04a                	sd	s2,32(sp)
    80002008:	ec4e                	sd	s3,24(sp)
    8000200a:	e852                	sd	s4,16(sp)
    8000200c:	e456                	sd	s5,8(sp)
    8000200e:	0080                	addi	s0,sp,64
    80002010:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002012:	00010497          	auipc	s1,0x10
    80002016:	7ae48493          	addi	s1,s1,1966 # 800127c0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000201a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000201c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000201e:	00016917          	auipc	s2,0x16
    80002022:	5a290913          	addi	s2,s2,1442 # 800185c0 <tickslock>
    80002026:	a801                	j	80002036 <wakeup+0x38>
      }
      release(&p->lock);
    80002028:	8526                	mv	a0,s1
    8000202a:	c3dfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000202e:	17848493          	addi	s1,s1,376
    80002032:	03248263          	beq	s1,s2,80002056 <wakeup+0x58>
    if(p != myproc()){
    80002036:	8adff0ef          	jal	800018e2 <myproc>
    8000203a:	fea48ae3          	beq	s1,a0,8000202e <wakeup+0x30>
      acquire(&p->lock);
    8000203e:	8526                	mv	a0,s1
    80002040:	b8ffe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002044:	4c9c                	lw	a5,24(s1)
    80002046:	ff3791e3          	bne	a5,s3,80002028 <wakeup+0x2a>
    8000204a:	709c                	ld	a5,32(s1)
    8000204c:	fd479ee3          	bne	a5,s4,80002028 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002050:	0154ac23          	sw	s5,24(s1)
    80002054:	bfd1                	j	80002028 <wakeup+0x2a>
    }
  }
}
    80002056:	70e2                	ld	ra,56(sp)
    80002058:	7442                	ld	s0,48(sp)
    8000205a:	74a2                	ld	s1,40(sp)
    8000205c:	7902                	ld	s2,32(sp)
    8000205e:	69e2                	ld	s3,24(sp)
    80002060:	6a42                	ld	s4,16(sp)
    80002062:	6aa2                	ld	s5,8(sp)
    80002064:	6121                	addi	sp,sp,64
    80002066:	8082                	ret

0000000080002068 <reparent>:
{
    80002068:	7179                	addi	sp,sp,-48
    8000206a:	f406                	sd	ra,40(sp)
    8000206c:	f022                	sd	s0,32(sp)
    8000206e:	ec26                	sd	s1,24(sp)
    80002070:	e84a                	sd	s2,16(sp)
    80002072:	e44e                	sd	s3,8(sp)
    80002074:	e052                	sd	s4,0(sp)
    80002076:	1800                	addi	s0,sp,48
    80002078:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000207a:	00010497          	auipc	s1,0x10
    8000207e:	74648493          	addi	s1,s1,1862 # 800127c0 <proc>
      pp->parent = initproc;
    80002082:	00008a17          	auipc	s4,0x8
    80002086:	1e6a0a13          	addi	s4,s4,486 # 8000a268 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000208a:	00016997          	auipc	s3,0x16
    8000208e:	53698993          	addi	s3,s3,1334 # 800185c0 <tickslock>
    80002092:	a029                	j	8000209c <reparent+0x34>
    80002094:	17848493          	addi	s1,s1,376
    80002098:	01348b63          	beq	s1,s3,800020ae <reparent+0x46>
    if(pp->parent == p){
    8000209c:	7c9c                	ld	a5,56(s1)
    8000209e:	ff279be3          	bne	a5,s2,80002094 <reparent+0x2c>
      pp->parent = initproc;
    800020a2:	000a3503          	ld	a0,0(s4)
    800020a6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020a8:	f57ff0ef          	jal	80001ffe <wakeup>
    800020ac:	b7e5                	j	80002094 <reparent+0x2c>
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6a02                	ld	s4,0(sp)
    800020ba:	6145                	addi	sp,sp,48
    800020bc:	8082                	ret

00000000800020be <kexit>:
{
    800020be:	7179                	addi	sp,sp,-48
    800020c0:	f406                	sd	ra,40(sp)
    800020c2:	f022                	sd	s0,32(sp)
    800020c4:	ec26                	sd	s1,24(sp)
    800020c6:	e84a                	sd	s2,16(sp)
    800020c8:	e44e                	sd	s3,8(sp)
    800020ca:	e052                	sd	s4,0(sp)
    800020cc:	1800                	addi	s0,sp,48
    800020ce:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020d0:	813ff0ef          	jal	800018e2 <myproc>
    800020d4:	89aa                	mv	s3,a0
  if(p == initproc)
    800020d6:	00008797          	auipc	a5,0x8
    800020da:	1927b783          	ld	a5,402(a5) # 8000a268 <initproc>
    800020de:	0d050493          	addi	s1,a0,208
    800020e2:	15050913          	addi	s2,a0,336
    800020e6:	00a79f63          	bne	a5,a0,80002104 <kexit+0x46>
    panic("init exiting");
    800020ea:	00005517          	auipc	a0,0x5
    800020ee:	0fe50513          	addi	a0,a0,254 # 800071e8 <etext+0x1e8>
    800020f2:	eeefe0ef          	jal	800007e0 <panic>
      fileclose(f);
    800020f6:	05a020ef          	jal	80004150 <fileclose>
      p->ofile[fd] = 0;
    800020fa:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800020fe:	04a1                	addi	s1,s1,8
    80002100:	01248563          	beq	s1,s2,8000210a <kexit+0x4c>
    if(p->ofile[fd]){
    80002104:	6088                	ld	a0,0(s1)
    80002106:	f965                	bnez	a0,800020f6 <kexit+0x38>
    80002108:	bfdd                	j	800020fe <kexit+0x40>
  begin_op();
    8000210a:	43b010ef          	jal	80003d44 <begin_op>
  iput(p->cwd);
    8000210e:	1509b503          	ld	a0,336(s3)
    80002112:	3ca010ef          	jal	800034dc <iput>
  end_op();
    80002116:	499010ef          	jal	80003dae <end_op>
  p->cwd = 0;
    8000211a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000211e:	00010497          	auipc	s1,0x10
    80002122:	27248493          	addi	s1,s1,626 # 80012390 <wait_lock>
    80002126:	8526                	mv	a0,s1
    80002128:	aa7fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000212c:	854e                	mv	a0,s3
    8000212e:	f3bff0ef          	jal	80002068 <reparent>
  wakeup(p->parent);
    80002132:	0389b503          	ld	a0,56(s3)
    80002136:	ec9ff0ef          	jal	80001ffe <wakeup>
  acquire(&p->lock);
    8000213a:	854e                	mv	a0,s3
    8000213c:	a93fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002140:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002144:	4795                	li	a5,5
    80002146:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000214a:	8526                	mv	a0,s1
    8000214c:	b1bfe0ef          	jal	80000c66 <release>
  sched();
    80002150:	d7dff0ef          	jal	80001ecc <sched>
  panic("zombie exit");
    80002154:	00005517          	auipc	a0,0x5
    80002158:	0a450513          	addi	a0,a0,164 # 800071f8 <etext+0x1f8>
    8000215c:	e84fe0ef          	jal	800007e0 <panic>

0000000080002160 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002160:	7179                	addi	sp,sp,-48
    80002162:	f406                	sd	ra,40(sp)
    80002164:	f022                	sd	s0,32(sp)
    80002166:	ec26                	sd	s1,24(sp)
    80002168:	e84a                	sd	s2,16(sp)
    8000216a:	e44e                	sd	s3,8(sp)
    8000216c:	1800                	addi	s0,sp,48
    8000216e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002170:	00010497          	auipc	s1,0x10
    80002174:	65048493          	addi	s1,s1,1616 # 800127c0 <proc>
    80002178:	00016997          	auipc	s3,0x16
    8000217c:	44898993          	addi	s3,s3,1096 # 800185c0 <tickslock>
    acquire(&p->lock);
    80002180:	8526                	mv	a0,s1
    80002182:	a4dfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    80002186:	589c                	lw	a5,48(s1)
    80002188:	01278b63          	beq	a5,s2,8000219e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	ad9fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002192:	17848493          	addi	s1,s1,376
    80002196:	ff3495e3          	bne	s1,s3,80002180 <kkill+0x20>
  }
  return -1;
    8000219a:	557d                	li	a0,-1
    8000219c:	a819                	j	800021b2 <kkill+0x52>
      p->killed = 1;
    8000219e:	4785                	li	a5,1
    800021a0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800021a2:	4c98                	lw	a4,24(s1)
    800021a4:	4789                	li	a5,2
    800021a6:	00f70d63          	beq	a4,a5,800021c0 <kkill+0x60>
      release(&p->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	abbfe0ef          	jal	80000c66 <release>
      return 0;
    800021b0:	4501                	li	a0,0
}
    800021b2:	70a2                	ld	ra,40(sp)
    800021b4:	7402                	ld	s0,32(sp)
    800021b6:	64e2                	ld	s1,24(sp)
    800021b8:	6942                	ld	s2,16(sp)
    800021ba:	69a2                	ld	s3,8(sp)
    800021bc:	6145                	addi	sp,sp,48
    800021be:	8082                	ret
        p->state = RUNNABLE;
    800021c0:	478d                	li	a5,3
    800021c2:	cc9c                	sw	a5,24(s1)
    800021c4:	b7dd                	j	800021aa <kkill+0x4a>

00000000800021c6 <setkilled>:

void
setkilled(struct proc *p)
{
    800021c6:	1101                	addi	sp,sp,-32
    800021c8:	ec06                	sd	ra,24(sp)
    800021ca:	e822                	sd	s0,16(sp)
    800021cc:	e426                	sd	s1,8(sp)
    800021ce:	1000                	addi	s0,sp,32
    800021d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021d2:	9fdfe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800021d6:	4785                	li	a5,1
    800021d8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021da:	8526                	mv	a0,s1
    800021dc:	a8bfe0ef          	jal	80000c66 <release>
}
    800021e0:	60e2                	ld	ra,24(sp)
    800021e2:	6442                	ld	s0,16(sp)
    800021e4:	64a2                	ld	s1,8(sp)
    800021e6:	6105                	addi	sp,sp,32
    800021e8:	8082                	ret

00000000800021ea <killed>:

int
killed(struct proc *p)
{
    800021ea:	1101                	addi	sp,sp,-32
    800021ec:	ec06                	sd	ra,24(sp)
    800021ee:	e822                	sd	s0,16(sp)
    800021f0:	e426                	sd	s1,8(sp)
    800021f2:	e04a                	sd	s2,0(sp)
    800021f4:	1000                	addi	s0,sp,32
    800021f6:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800021f8:	9d7fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    800021fc:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	a65fe0ef          	jal	80000c66 <release>
  return k;
}
    80002206:	854a                	mv	a0,s2
    80002208:	60e2                	ld	ra,24(sp)
    8000220a:	6442                	ld	s0,16(sp)
    8000220c:	64a2                	ld	s1,8(sp)
    8000220e:	6902                	ld	s2,0(sp)
    80002210:	6105                	addi	sp,sp,32
    80002212:	8082                	ret

0000000080002214 <kwait>:
{
    80002214:	715d                	addi	sp,sp,-80
    80002216:	e486                	sd	ra,72(sp)
    80002218:	e0a2                	sd	s0,64(sp)
    8000221a:	fc26                	sd	s1,56(sp)
    8000221c:	f84a                	sd	s2,48(sp)
    8000221e:	f44e                	sd	s3,40(sp)
    80002220:	f052                	sd	s4,32(sp)
    80002222:	ec56                	sd	s5,24(sp)
    80002224:	e85a                	sd	s6,16(sp)
    80002226:	e45e                	sd	s7,8(sp)
    80002228:	e062                	sd	s8,0(sp)
    8000222a:	0880                	addi	s0,sp,80
    8000222c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000222e:	eb4ff0ef          	jal	800018e2 <myproc>
    80002232:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002234:	00010517          	auipc	a0,0x10
    80002238:	15c50513          	addi	a0,a0,348 # 80012390 <wait_lock>
    8000223c:	993fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002240:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002242:	4a15                	li	s4,5
        havekids = 1;
    80002244:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002246:	00016997          	auipc	s3,0x16
    8000224a:	37a98993          	addi	s3,s3,890 # 800185c0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000224e:	00010c17          	auipc	s8,0x10
    80002252:	142c0c13          	addi	s8,s8,322 # 80012390 <wait_lock>
    80002256:	a871                	j	800022f2 <kwait+0xde>
          pid = pp->pid;
    80002258:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000225c:	000b0c63          	beqz	s6,80002274 <kwait+0x60>
    80002260:	4691                	li	a3,4
    80002262:	02c48613          	addi	a2,s1,44
    80002266:	85da                	mv	a1,s6
    80002268:	05093503          	ld	a0,80(s2)
    8000226c:	b76ff0ef          	jal	800015e2 <copyout>
    80002270:	02054b63          	bltz	a0,800022a6 <kwait+0x92>
          freeproc(pp);
    80002274:	8526                	mv	a0,s1
    80002276:	83dff0ef          	jal	80001ab2 <freeproc>
          release(&pp->lock);
    8000227a:	8526                	mv	a0,s1
    8000227c:	9ebfe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002280:	00010517          	auipc	a0,0x10
    80002284:	11050513          	addi	a0,a0,272 # 80012390 <wait_lock>
    80002288:	9dffe0ef          	jal	80000c66 <release>
}
    8000228c:	854e                	mv	a0,s3
    8000228e:	60a6                	ld	ra,72(sp)
    80002290:	6406                	ld	s0,64(sp)
    80002292:	74e2                	ld	s1,56(sp)
    80002294:	7942                	ld	s2,48(sp)
    80002296:	79a2                	ld	s3,40(sp)
    80002298:	7a02                	ld	s4,32(sp)
    8000229a:	6ae2                	ld	s5,24(sp)
    8000229c:	6b42                	ld	s6,16(sp)
    8000229e:	6ba2                	ld	s7,8(sp)
    800022a0:	6c02                	ld	s8,0(sp)
    800022a2:	6161                	addi	sp,sp,80
    800022a4:	8082                	ret
            release(&pp->lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	9bffe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800022ac:	00010517          	auipc	a0,0x10
    800022b0:	0e450513          	addi	a0,a0,228 # 80012390 <wait_lock>
    800022b4:	9b3fe0ef          	jal	80000c66 <release>
            return -1;
    800022b8:	59fd                	li	s3,-1
    800022ba:	bfc9                	j	8000228c <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022bc:	17848493          	addi	s1,s1,376
    800022c0:	03348063          	beq	s1,s3,800022e0 <kwait+0xcc>
      if(pp->parent == p){
    800022c4:	7c9c                	ld	a5,56(s1)
    800022c6:	ff279be3          	bne	a5,s2,800022bc <kwait+0xa8>
        acquire(&pp->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	903fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800022d0:	4c9c                	lw	a5,24(s1)
    800022d2:	f94783e3          	beq	a5,s4,80002258 <kwait+0x44>
        release(&pp->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	98ffe0ef          	jal	80000c66 <release>
        havekids = 1;
    800022dc:	8756                	mv	a4,s5
    800022de:	bff9                	j	800022bc <kwait+0xa8>
    if(!havekids || killed(p)){
    800022e0:	cf19                	beqz	a4,800022fe <kwait+0xea>
    800022e2:	854a                	mv	a0,s2
    800022e4:	f07ff0ef          	jal	800021ea <killed>
    800022e8:	e919                	bnez	a0,800022fe <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022ea:	85e2                	mv	a1,s8
    800022ec:	854a                	mv	a0,s2
    800022ee:	cc5ff0ef          	jal	80001fb2 <sleep>
    havekids = 0;
    800022f2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022f4:	00010497          	auipc	s1,0x10
    800022f8:	4cc48493          	addi	s1,s1,1228 # 800127c0 <proc>
    800022fc:	b7e1                	j	800022c4 <kwait+0xb0>
      release(&wait_lock);
    800022fe:	00010517          	auipc	a0,0x10
    80002302:	09250513          	addi	a0,a0,146 # 80012390 <wait_lock>
    80002306:	961fe0ef          	jal	80000c66 <release>
      return -1;
    8000230a:	59fd                	li	s3,-1
    8000230c:	b741                	j	8000228c <kwait+0x78>

000000008000230e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000230e:	7179                	addi	sp,sp,-48
    80002310:	f406                	sd	ra,40(sp)
    80002312:	f022                	sd	s0,32(sp)
    80002314:	ec26                	sd	s1,24(sp)
    80002316:	e84a                	sd	s2,16(sp)
    80002318:	e44e                	sd	s3,8(sp)
    8000231a:	e052                	sd	s4,0(sp)
    8000231c:	1800                	addi	s0,sp,48
    8000231e:	84aa                	mv	s1,a0
    80002320:	892e                	mv	s2,a1
    80002322:	89b2                	mv	s3,a2
    80002324:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002326:	dbcff0ef          	jal	800018e2 <myproc>
  if(user_dst){
    8000232a:	cc99                	beqz	s1,80002348 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000232c:	86d2                	mv	a3,s4
    8000232e:	864e                	mv	a2,s3
    80002330:	85ca                	mv	a1,s2
    80002332:	6928                	ld	a0,80(a0)
    80002334:	aaeff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002338:	70a2                	ld	ra,40(sp)
    8000233a:	7402                	ld	s0,32(sp)
    8000233c:	64e2                	ld	s1,24(sp)
    8000233e:	6942                	ld	s2,16(sp)
    80002340:	69a2                	ld	s3,8(sp)
    80002342:	6a02                	ld	s4,0(sp)
    80002344:	6145                	addi	sp,sp,48
    80002346:	8082                	ret
    memmove((char *)dst, src, len);
    80002348:	000a061b          	sext.w	a2,s4
    8000234c:	85ce                	mv	a1,s3
    8000234e:	854a                	mv	a0,s2
    80002350:	9affe0ef          	jal	80000cfe <memmove>
    return 0;
    80002354:	8526                	mv	a0,s1
    80002356:	b7cd                	j	80002338 <either_copyout+0x2a>

0000000080002358 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002358:	7179                	addi	sp,sp,-48
    8000235a:	f406                	sd	ra,40(sp)
    8000235c:	f022                	sd	s0,32(sp)
    8000235e:	ec26                	sd	s1,24(sp)
    80002360:	e84a                	sd	s2,16(sp)
    80002362:	e44e                	sd	s3,8(sp)
    80002364:	e052                	sd	s4,0(sp)
    80002366:	1800                	addi	s0,sp,48
    80002368:	892a                	mv	s2,a0
    8000236a:	84ae                	mv	s1,a1
    8000236c:	89b2                	mv	s3,a2
    8000236e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002370:	d72ff0ef          	jal	800018e2 <myproc>
  if(user_src){
    80002374:	cc99                	beqz	s1,80002392 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002376:	86d2                	mv	a3,s4
    80002378:	864e                	mv	a2,s3
    8000237a:	85ca                	mv	a1,s2
    8000237c:	6928                	ld	a0,80(a0)
    8000237e:	b48ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002382:	70a2                	ld	ra,40(sp)
    80002384:	7402                	ld	s0,32(sp)
    80002386:	64e2                	ld	s1,24(sp)
    80002388:	6942                	ld	s2,16(sp)
    8000238a:	69a2                	ld	s3,8(sp)
    8000238c:	6a02                	ld	s4,0(sp)
    8000238e:	6145                	addi	sp,sp,48
    80002390:	8082                	ret
    memmove(dst, (char*)src, len);
    80002392:	000a061b          	sext.w	a2,s4
    80002396:	85ce                	mv	a1,s3
    80002398:	854a                	mv	a0,s2
    8000239a:	965fe0ef          	jal	80000cfe <memmove>
    return 0;
    8000239e:	8526                	mv	a0,s1
    800023a0:	b7cd                	j	80002382 <either_copyin+0x2a>

00000000800023a2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023a2:	715d                	addi	sp,sp,-80
    800023a4:	e486                	sd	ra,72(sp)
    800023a6:	e0a2                	sd	s0,64(sp)
    800023a8:	fc26                	sd	s1,56(sp)
    800023aa:	f84a                	sd	s2,48(sp)
    800023ac:	f44e                	sd	s3,40(sp)
    800023ae:	f052                	sd	s4,32(sp)
    800023b0:	ec56                	sd	s5,24(sp)
    800023b2:	e85a                	sd	s6,16(sp)
    800023b4:	e45e                	sd	s7,8(sp)
    800023b6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800023b8:	00005517          	auipc	a0,0x5
    800023bc:	cc050513          	addi	a0,a0,-832 # 80007078 <etext+0x78>
    800023c0:	93afe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023c4:	00010497          	auipc	s1,0x10
    800023c8:	55448493          	addi	s1,s1,1364 # 80012918 <proc+0x158>
    800023cc:	00016917          	auipc	s2,0x16
    800023d0:	34c90913          	addi	s2,s2,844 # 80018718 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023d4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023d6:	00005997          	auipc	s3,0x5
    800023da:	e3298993          	addi	s3,s3,-462 # 80007208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    800023de:	00005a97          	auipc	s5,0x5
    800023e2:	e32a8a93          	addi	s5,s5,-462 # 80007210 <etext+0x210>
    printf("\n");
    800023e6:	00005a17          	auipc	s4,0x5
    800023ea:	c92a0a13          	addi	s4,s4,-878 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023ee:	00005b97          	auipc	s7,0x5
    800023f2:	342b8b93          	addi	s7,s7,834 # 80007730 <states.0>
    800023f6:	a829                	j	80002410 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800023f8:	ed86a583          	lw	a1,-296(a3)
    800023fc:	8556                	mv	a0,s5
    800023fe:	8fcfe0ef          	jal	800004fa <printf>
    printf("\n");
    80002402:	8552                	mv	a0,s4
    80002404:	8f6fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002408:	17848493          	addi	s1,s1,376
    8000240c:	03248263          	beq	s1,s2,80002430 <procdump+0x8e>
    if(p->state == UNUSED)
    80002410:	86a6                	mv	a3,s1
    80002412:	ec04a783          	lw	a5,-320(s1)
    80002416:	dbed                	beqz	a5,80002408 <procdump+0x66>
      state = "???";
    80002418:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000241a:	fcfb6fe3          	bltu	s6,a5,800023f8 <procdump+0x56>
    8000241e:	02079713          	slli	a4,a5,0x20
    80002422:	01d75793          	srli	a5,a4,0x1d
    80002426:	97de                	add	a5,a5,s7
    80002428:	6390                	ld	a2,0(a5)
    8000242a:	f679                	bnez	a2,800023f8 <procdump+0x56>
      state = "???";
    8000242c:	864e                	mv	a2,s3
    8000242e:	b7e9                	j	800023f8 <procdump+0x56>
  }
}
    80002430:	60a6                	ld	ra,72(sp)
    80002432:	6406                	ld	s0,64(sp)
    80002434:	74e2                	ld	s1,56(sp)
    80002436:	7942                	ld	s2,48(sp)
    80002438:	79a2                	ld	s3,40(sp)
    8000243a:	7a02                	ld	s4,32(sp)
    8000243c:	6ae2                	ld	s5,24(sp)
    8000243e:	6b42                	ld	s6,16(sp)
    80002440:	6ba2                	ld	s7,8(sp)
    80002442:	6161                	addi	sp,sp,80
    80002444:	8082                	ret

0000000080002446 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002446:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000244a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000244e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002450:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002452:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002456:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000245a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000245e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002462:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002466:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000246a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000246e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002472:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002476:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000247a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000247e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002482:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002484:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002486:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000248a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000248e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002492:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002496:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000249a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000249e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024a2:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024a6:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024aa:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024ae:	8082                	ret

00000000800024b0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024b0:	1141                	addi	sp,sp,-16
    800024b2:	e406                	sd	ra,8(sp)
    800024b4:	e022                	sd	s0,0(sp)
    800024b6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024b8:	00005597          	auipc	a1,0x5
    800024bc:	d9858593          	addi	a1,a1,-616 # 80007250 <etext+0x250>
    800024c0:	00016517          	auipc	a0,0x16
    800024c4:	10050513          	addi	a0,a0,256 # 800185c0 <tickslock>
    800024c8:	e86fe0ef          	jal	80000b4e <initlock>
}
    800024cc:	60a2                	ld	ra,8(sp)
    800024ce:	6402                	ld	s0,0(sp)
    800024d0:	0141                	addi	sp,sp,16
    800024d2:	8082                	ret

00000000800024d4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024d4:	1141                	addi	sp,sp,-16
    800024d6:	e422                	sd	s0,8(sp)
    800024d8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024da:	00003797          	auipc	a5,0x3
    800024de:	ff678793          	addi	a5,a5,-10 # 800054d0 <kernelvec>
    800024e2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024e6:	6422                	ld	s0,8(sp)
    800024e8:	0141                	addi	sp,sp,16
    800024ea:	8082                	ret

00000000800024ec <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024ec:	1141                	addi	sp,sp,-16
    800024ee:	e406                	sd	ra,8(sp)
    800024f0:	e022                	sd	s0,0(sp)
    800024f2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024f4:	beeff0ef          	jal	800018e2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024f8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024fc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024fe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002502:	04000737          	lui	a4,0x4000
    80002506:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002508:	0732                	slli	a4,a4,0xc
    8000250a:	00004797          	auipc	a5,0x4
    8000250e:	af678793          	addi	a5,a5,-1290 # 80006000 <_trampoline>
    80002512:	00004697          	auipc	a3,0x4
    80002516:	aee68693          	addi	a3,a3,-1298 # 80006000 <_trampoline>
    8000251a:	8f95                	sub	a5,a5,a3
    8000251c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000251e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002522:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002524:	18002773          	csrr	a4,satp
    80002528:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000252a:	6d38                	ld	a4,88(a0)
    8000252c:	613c                	ld	a5,64(a0)
    8000252e:	6685                	lui	a3,0x1
    80002530:	97b6                	add	a5,a5,a3
    80002532:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002534:	6d3c                	ld	a5,88(a0)
    80002536:	00000717          	auipc	a4,0x0
    8000253a:	0f870713          	addi	a4,a4,248 # 8000262e <usertrap>
    8000253e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002540:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002542:	8712                	mv	a4,tp
    80002544:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002546:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000254a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000254e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002552:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002556:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002558:	6f9c                	ld	a5,24(a5)
    8000255a:	14179073          	csrw	sepc,a5
}
    8000255e:	60a2                	ld	ra,8(sp)
    80002560:	6402                	ld	s0,0(sp)
    80002562:	0141                	addi	sp,sp,16
    80002564:	8082                	ret

0000000080002566 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002566:	1101                	addi	sp,sp,-32
    80002568:	ec06                	sd	ra,24(sp)
    8000256a:	e822                	sd	s0,16(sp)
    8000256c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000256e:	b48ff0ef          	jal	800018b6 <cpuid>
    80002572:	cd11                	beqz	a0,8000258e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002574:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002578:	000f4737          	lui	a4,0xf4
    8000257c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002580:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002582:	14d79073          	csrw	stimecmp,a5
}
    80002586:	60e2                	ld	ra,24(sp)
    80002588:	6442                	ld	s0,16(sp)
    8000258a:	6105                	addi	sp,sp,32
    8000258c:	8082                	ret
    8000258e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002590:	00016497          	auipc	s1,0x16
    80002594:	03048493          	addi	s1,s1,48 # 800185c0 <tickslock>
    80002598:	8526                	mv	a0,s1
    8000259a:	e34fe0ef          	jal	80000bce <acquire>
    ticks++;
    8000259e:	00008517          	auipc	a0,0x8
    800025a2:	cd250513          	addi	a0,a0,-814 # 8000a270 <ticks>
    800025a6:	411c                	lw	a5,0(a0)
    800025a8:	2785                	addiw	a5,a5,1
    800025aa:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800025ac:	a53ff0ef          	jal	80001ffe <wakeup>
    release(&tickslock);
    800025b0:	8526                	mv	a0,s1
    800025b2:	eb4fe0ef          	jal	80000c66 <release>
    800025b6:	64a2                	ld	s1,8(sp)
    800025b8:	bf75                	j	80002574 <clockintr+0xe>

00000000800025ba <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025ba:	1101                	addi	sp,sp,-32
    800025bc:	ec06                	sd	ra,24(sp)
    800025be:	e822                	sd	s0,16(sp)
    800025c0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025c2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800025c6:	57fd                	li	a5,-1
    800025c8:	17fe                	slli	a5,a5,0x3f
    800025ca:	07a5                	addi	a5,a5,9
    800025cc:	00f70c63          	beq	a4,a5,800025e4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025d0:	57fd                	li	a5,-1
    800025d2:	17fe                	slli	a5,a5,0x3f
    800025d4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025d6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025d8:	04f70763          	beq	a4,a5,80002626 <devintr+0x6c>
  }
}
    800025dc:	60e2                	ld	ra,24(sp)
    800025de:	6442                	ld	s0,16(sp)
    800025e0:	6105                	addi	sp,sp,32
    800025e2:	8082                	ret
    800025e4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025e6:	797020ef          	jal	8000557c <plic_claim>
    800025ea:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025ec:	47a9                	li	a5,10
    800025ee:	00f50963          	beq	a0,a5,80002600 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800025f2:	4785                	li	a5,1
    800025f4:	00f50963          	beq	a0,a5,80002606 <devintr+0x4c>
    return 1;
    800025f8:	4505                	li	a0,1
    } else if(irq){
    800025fa:	e889                	bnez	s1,8000260c <devintr+0x52>
    800025fc:	64a2                	ld	s1,8(sp)
    800025fe:	bff9                	j	800025dc <devintr+0x22>
      uartintr();
    80002600:	bb0fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002604:	a819                	j	8000261a <devintr+0x60>
      virtio_disk_intr();
    80002606:	43c030ef          	jal	80005a42 <virtio_disk_intr>
    if(irq)
    8000260a:	a801                	j	8000261a <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000260c:	85a6                	mv	a1,s1
    8000260e:	00005517          	auipc	a0,0x5
    80002612:	c4a50513          	addi	a0,a0,-950 # 80007258 <etext+0x258>
    80002616:	ee5fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000261a:	8526                	mv	a0,s1
    8000261c:	781020ef          	jal	8000559c <plic_complete>
    return 1;
    80002620:	4505                	li	a0,1
    80002622:	64a2                	ld	s1,8(sp)
    80002624:	bf65                	j	800025dc <devintr+0x22>
    clockintr();
    80002626:	f41ff0ef          	jal	80002566 <clockintr>
    return 2;
    8000262a:	4509                	li	a0,2
    8000262c:	bf45                	j	800025dc <devintr+0x22>

000000008000262e <usertrap>:
{
    8000262e:	1101                	addi	sp,sp,-32
    80002630:	ec06                	sd	ra,24(sp)
    80002632:	e822                	sd	s0,16(sp)
    80002634:	e426                	sd	s1,8(sp)
    80002636:	e04a                	sd	s2,0(sp)
    80002638:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000263a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000263e:	1007f793          	andi	a5,a5,256
    80002642:	eba5                	bnez	a5,800026b2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002644:	00003797          	auipc	a5,0x3
    80002648:	e8c78793          	addi	a5,a5,-372 # 800054d0 <kernelvec>
    8000264c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002650:	a92ff0ef          	jal	800018e2 <myproc>
    80002654:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002656:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002658:	14102773          	csrr	a4,sepc
    8000265c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000265e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002662:	47a1                	li	a5,8
    80002664:	04f70d63          	beq	a4,a5,800026be <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002668:	f53ff0ef          	jal	800025ba <devintr>
    8000266c:	892a                	mv	s2,a0
    8000266e:	e945                	bnez	a0,8000271e <usertrap+0xf0>
    80002670:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002674:	47bd                	li	a5,15
    80002676:	08f70863          	beq	a4,a5,80002706 <usertrap+0xd8>
    8000267a:	14202773          	csrr	a4,scause
    8000267e:	47b5                	li	a5,13
    80002680:	08f70363          	beq	a4,a5,80002706 <usertrap+0xd8>
    80002684:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002688:	5890                	lw	a2,48(s1)
    8000268a:	00005517          	auipc	a0,0x5
    8000268e:	c0e50513          	addi	a0,a0,-1010 # 80007298 <etext+0x298>
    80002692:	e69fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002696:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000269a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000269e:	00005517          	auipc	a0,0x5
    800026a2:	c2a50513          	addi	a0,a0,-982 # 800072c8 <etext+0x2c8>
    800026a6:	e55fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800026aa:	8526                	mv	a0,s1
    800026ac:	b1bff0ef          	jal	800021c6 <setkilled>
    800026b0:	a035                	j	800026dc <usertrap+0xae>
    panic("usertrap: not from user mode");
    800026b2:	00005517          	auipc	a0,0x5
    800026b6:	bc650513          	addi	a0,a0,-1082 # 80007278 <etext+0x278>
    800026ba:	926fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    800026be:	b2dff0ef          	jal	800021ea <killed>
    800026c2:	ed15                	bnez	a0,800026fe <usertrap+0xd0>
    p->trapframe->epc += 4;
    800026c4:	6cb8                	ld	a4,88(s1)
    800026c6:	6f1c                	ld	a5,24(a4)
    800026c8:	0791                	addi	a5,a5,4
    800026ca:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026cc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026d0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d4:	10079073          	csrw	sstatus,a5
    syscall();
    800026d8:	27c000ef          	jal	80002954 <syscall>
  if(killed(p))
    800026dc:	8526                	mv	a0,s1
    800026de:	b0dff0ef          	jal	800021ea <killed>
    800026e2:	e139                	bnez	a0,80002728 <usertrap+0xfa>
  prepare_return();
    800026e4:	e09ff0ef          	jal	800024ec <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e8:	68a8                	ld	a0,80(s1)
    800026ea:	8131                	srli	a0,a0,0xc
    800026ec:	57fd                	li	a5,-1
    800026ee:	17fe                	slli	a5,a5,0x3f
    800026f0:	8d5d                	or	a0,a0,a5
}
    800026f2:	60e2                	ld	ra,24(sp)
    800026f4:	6442                	ld	s0,16(sp)
    800026f6:	64a2                	ld	s1,8(sp)
    800026f8:	6902                	ld	s2,0(sp)
    800026fa:	6105                	addi	sp,sp,32
    800026fc:	8082                	ret
      kexit(-1);
    800026fe:	557d                	li	a0,-1
    80002700:	9bfff0ef          	jal	800020be <kexit>
    80002704:	b7c1                	j	800026c4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002706:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000270a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000270e:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002710:	00163613          	seqz	a2,a2
    80002714:	68a8                	ld	a0,80(s1)
    80002716:	e4bfe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000271a:	f169                	bnez	a0,800026dc <usertrap+0xae>
    8000271c:	b7a5                	j	80002684 <usertrap+0x56>
  if(killed(p))
    8000271e:	8526                	mv	a0,s1
    80002720:	acbff0ef          	jal	800021ea <killed>
    80002724:	c511                	beqz	a0,80002730 <usertrap+0x102>
    80002726:	a011                	j	8000272a <usertrap+0xfc>
    80002728:	4901                	li	s2,0
    kexit(-1);
    8000272a:	557d                	li	a0,-1
    8000272c:	993ff0ef          	jal	800020be <kexit>
  if(which_dev == 2) {
    80002730:	4789                	li	a5,2
    80002732:	faf919e3          	bne	s2,a5,800026e4 <usertrap+0xb6>
    p->time_slices++;
    80002736:	16c4a783          	lw	a5,364(s1)
    8000273a:	2785                	addiw	a5,a5,1
    8000273c:	0007869b          	sext.w	a3,a5
    80002740:	16f4a623          	sw	a5,364(s1)
    if(p->time_slices >= mlfq_time_quanta[p->priority]) {
    80002744:	1684a703          	lw	a4,360(s1)
    80002748:	00271613          	slli	a2,a4,0x2
    8000274c:	00008797          	auipc	a5,0x8
    80002750:	ac478793          	addi	a5,a5,-1340 # 8000a210 <mlfq_time_quanta>
    80002754:	97b2                	add	a5,a5,a2
    80002756:	439c                	lw	a5,0(a5)
    80002758:	00f6ca63          	blt	a3,a5,8000276c <usertrap+0x13e>
      if(p->priority < NMLFQ - 1) {
    8000275c:	4789                	li	a5,2
    8000275e:	00e7c563          	blt	a5,a4,80002768 <usertrap+0x13a>
        p->priority++;  // Move to lower priority queue
    80002762:	2705                	addiw	a4,a4,1
    80002764:	16e4a423          	sw	a4,360(s1)
      p->time_slices = 0;  // Reset time slice counter for new queue
    80002768:	1604a623          	sw	zero,364(s1)
    yield();
    8000276c:	81bff0ef          	jal	80001f86 <yield>
    80002770:	bf95                	j	800026e4 <usertrap+0xb6>

0000000080002772 <kerneltrap>:
{
    80002772:	7179                	addi	sp,sp,-48
    80002774:	f406                	sd	ra,40(sp)
    80002776:	f022                	sd	s0,32(sp)
    80002778:	ec26                	sd	s1,24(sp)
    8000277a:	e84a                	sd	s2,16(sp)
    8000277c:	e44e                	sd	s3,8(sp)
    8000277e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002780:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002784:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002788:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000278c:	1004f793          	andi	a5,s1,256
    80002790:	c795                	beqz	a5,800027bc <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002792:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002796:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002798:	eb85                	bnez	a5,800027c8 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000279a:	e21ff0ef          	jal	800025ba <devintr>
    8000279e:	c91d                	beqz	a0,800027d4 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800027a0:	4789                	li	a5,2
    800027a2:	04f50a63          	beq	a0,a5,800027f6 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027a6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027aa:	10049073          	csrw	sstatus,s1
}
    800027ae:	70a2                	ld	ra,40(sp)
    800027b0:	7402                	ld	s0,32(sp)
    800027b2:	64e2                	ld	s1,24(sp)
    800027b4:	6942                	ld	s2,16(sp)
    800027b6:	69a2                	ld	s3,8(sp)
    800027b8:	6145                	addi	sp,sp,48
    800027ba:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027bc:	00005517          	auipc	a0,0x5
    800027c0:	b3450513          	addi	a0,a0,-1228 # 800072f0 <etext+0x2f0>
    800027c4:	81cfe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800027c8:	00005517          	auipc	a0,0x5
    800027cc:	b5050513          	addi	a0,a0,-1200 # 80007318 <etext+0x318>
    800027d0:	810fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027d4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027d8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800027dc:	85ce                	mv	a1,s3
    800027de:	00005517          	auipc	a0,0x5
    800027e2:	b5a50513          	addi	a0,a0,-1190 # 80007338 <etext+0x338>
    800027e6:	d15fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800027ea:	00005517          	auipc	a0,0x5
    800027ee:	b7650513          	addi	a0,a0,-1162 # 80007360 <etext+0x360>
    800027f2:	feffd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    800027f6:	8ecff0ef          	jal	800018e2 <myproc>
    800027fa:	d555                	beqz	a0,800027a6 <kerneltrap+0x34>
    yield();
    800027fc:	f8aff0ef          	jal	80001f86 <yield>
    80002800:	b75d                	j	800027a6 <kerneltrap+0x34>

0000000080002802 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002802:	1101                	addi	sp,sp,-32
    80002804:	ec06                	sd	ra,24(sp)
    80002806:	e822                	sd	s0,16(sp)
    80002808:	e426                	sd	s1,8(sp)
    8000280a:	1000                	addi	s0,sp,32
    8000280c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000280e:	8d4ff0ef          	jal	800018e2 <myproc>
  switch (n) {
    80002812:	4795                	li	a5,5
    80002814:	0497e163          	bltu	a5,s1,80002856 <argraw+0x54>
    80002818:	048a                	slli	s1,s1,0x2
    8000281a:	00005717          	auipc	a4,0x5
    8000281e:	f4670713          	addi	a4,a4,-186 # 80007760 <states.0+0x30>
    80002822:	94ba                	add	s1,s1,a4
    80002824:	409c                	lw	a5,0(s1)
    80002826:	97ba                	add	a5,a5,a4
    80002828:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000282a:	6d3c                	ld	a5,88(a0)
    8000282c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6105                	addi	sp,sp,32
    80002836:	8082                	ret
    return p->trapframe->a1;
    80002838:	6d3c                	ld	a5,88(a0)
    8000283a:	7fa8                	ld	a0,120(a5)
    8000283c:	bfcd                	j	8000282e <argraw+0x2c>
    return p->trapframe->a2;
    8000283e:	6d3c                	ld	a5,88(a0)
    80002840:	63c8                	ld	a0,128(a5)
    80002842:	b7f5                	j	8000282e <argraw+0x2c>
    return p->trapframe->a3;
    80002844:	6d3c                	ld	a5,88(a0)
    80002846:	67c8                	ld	a0,136(a5)
    80002848:	b7dd                	j	8000282e <argraw+0x2c>
    return p->trapframe->a4;
    8000284a:	6d3c                	ld	a5,88(a0)
    8000284c:	6bc8                	ld	a0,144(a5)
    8000284e:	b7c5                	j	8000282e <argraw+0x2c>
    return p->trapframe->a5;
    80002850:	6d3c                	ld	a5,88(a0)
    80002852:	6fc8                	ld	a0,152(a5)
    80002854:	bfe9                	j	8000282e <argraw+0x2c>
  panic("argraw");
    80002856:	00005517          	auipc	a0,0x5
    8000285a:	b1a50513          	addi	a0,a0,-1254 # 80007370 <etext+0x370>
    8000285e:	f83fd0ef          	jal	800007e0 <panic>

0000000080002862 <fetchaddr>:
{
    80002862:	1101                	addi	sp,sp,-32
    80002864:	ec06                	sd	ra,24(sp)
    80002866:	e822                	sd	s0,16(sp)
    80002868:	e426                	sd	s1,8(sp)
    8000286a:	e04a                	sd	s2,0(sp)
    8000286c:	1000                	addi	s0,sp,32
    8000286e:	84aa                	mv	s1,a0
    80002870:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002872:	870ff0ef          	jal	800018e2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002876:	653c                	ld	a5,72(a0)
    80002878:	02f4f663          	bgeu	s1,a5,800028a4 <fetchaddr+0x42>
    8000287c:	00848713          	addi	a4,s1,8
    80002880:	02e7e463          	bltu	a5,a4,800028a8 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002884:	46a1                	li	a3,8
    80002886:	8626                	mv	a2,s1
    80002888:	85ca                	mv	a1,s2
    8000288a:	6928                	ld	a0,80(a0)
    8000288c:	e3bfe0ef          	jal	800016c6 <copyin>
    80002890:	00a03533          	snez	a0,a0
    80002894:	40a00533          	neg	a0,a0
}
    80002898:	60e2                	ld	ra,24(sp)
    8000289a:	6442                	ld	s0,16(sp)
    8000289c:	64a2                	ld	s1,8(sp)
    8000289e:	6902                	ld	s2,0(sp)
    800028a0:	6105                	addi	sp,sp,32
    800028a2:	8082                	ret
    return -1;
    800028a4:	557d                	li	a0,-1
    800028a6:	bfcd                	j	80002898 <fetchaddr+0x36>
    800028a8:	557d                	li	a0,-1
    800028aa:	b7fd                	j	80002898 <fetchaddr+0x36>

00000000800028ac <fetchstr>:
{
    800028ac:	7179                	addi	sp,sp,-48
    800028ae:	f406                	sd	ra,40(sp)
    800028b0:	f022                	sd	s0,32(sp)
    800028b2:	ec26                	sd	s1,24(sp)
    800028b4:	e84a                	sd	s2,16(sp)
    800028b6:	e44e                	sd	s3,8(sp)
    800028b8:	1800                	addi	s0,sp,48
    800028ba:	892a                	mv	s2,a0
    800028bc:	84ae                	mv	s1,a1
    800028be:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800028c0:	822ff0ef          	jal	800018e2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800028c4:	86ce                	mv	a3,s3
    800028c6:	864a                	mv	a2,s2
    800028c8:	85a6                	mv	a1,s1
    800028ca:	6928                	ld	a0,80(a0)
    800028cc:	bbdfe0ef          	jal	80001488 <copyinstr>
    800028d0:	00054c63          	bltz	a0,800028e8 <fetchstr+0x3c>
  return strlen(buf);
    800028d4:	8526                	mv	a0,s1
    800028d6:	d3cfe0ef          	jal	80000e12 <strlen>
}
    800028da:	70a2                	ld	ra,40(sp)
    800028dc:	7402                	ld	s0,32(sp)
    800028de:	64e2                	ld	s1,24(sp)
    800028e0:	6942                	ld	s2,16(sp)
    800028e2:	69a2                	ld	s3,8(sp)
    800028e4:	6145                	addi	sp,sp,48
    800028e6:	8082                	ret
    return -1;
    800028e8:	557d                	li	a0,-1
    800028ea:	bfc5                	j	800028da <fetchstr+0x2e>

00000000800028ec <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028ec:	1101                	addi	sp,sp,-32
    800028ee:	ec06                	sd	ra,24(sp)
    800028f0:	e822                	sd	s0,16(sp)
    800028f2:	e426                	sd	s1,8(sp)
    800028f4:	1000                	addi	s0,sp,32
    800028f6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028f8:	f0bff0ef          	jal	80002802 <argraw>
    800028fc:	c088                	sw	a0,0(s1)
}
    800028fe:	60e2                	ld	ra,24(sp)
    80002900:	6442                	ld	s0,16(sp)
    80002902:	64a2                	ld	s1,8(sp)
    80002904:	6105                	addi	sp,sp,32
    80002906:	8082                	ret

0000000080002908 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002908:	1101                	addi	sp,sp,-32
    8000290a:	ec06                	sd	ra,24(sp)
    8000290c:	e822                	sd	s0,16(sp)
    8000290e:	e426                	sd	s1,8(sp)
    80002910:	1000                	addi	s0,sp,32
    80002912:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002914:	eefff0ef          	jal	80002802 <argraw>
    80002918:	e088                	sd	a0,0(s1)
}
    8000291a:	60e2                	ld	ra,24(sp)
    8000291c:	6442                	ld	s0,16(sp)
    8000291e:	64a2                	ld	s1,8(sp)
    80002920:	6105                	addi	sp,sp,32
    80002922:	8082                	ret

0000000080002924 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002924:	7179                	addi	sp,sp,-48
    80002926:	f406                	sd	ra,40(sp)
    80002928:	f022                	sd	s0,32(sp)
    8000292a:	ec26                	sd	s1,24(sp)
    8000292c:	e84a                	sd	s2,16(sp)
    8000292e:	1800                	addi	s0,sp,48
    80002930:	84ae                	mv	s1,a1
    80002932:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002934:	fd840593          	addi	a1,s0,-40
    80002938:	fd1ff0ef          	jal	80002908 <argaddr>
  return fetchstr(addr, buf, max);
    8000293c:	864a                	mv	a2,s2
    8000293e:	85a6                	mv	a1,s1
    80002940:	fd843503          	ld	a0,-40(s0)
    80002944:	f69ff0ef          	jal	800028ac <fetchstr>
}
    80002948:	70a2                	ld	ra,40(sp)
    8000294a:	7402                	ld	s0,32(sp)
    8000294c:	64e2                	ld	s1,24(sp)
    8000294e:	6942                	ld	s2,16(sp)
    80002950:	6145                	addi	sp,sp,48
    80002952:	8082                	ret

0000000080002954 <syscall>:
[SYS_boostproc] sys_boostproc,
};

void
syscall(void)
{
    80002954:	1101                	addi	sp,sp,-32
    80002956:	ec06                	sd	ra,24(sp)
    80002958:	e822                	sd	s0,16(sp)
    8000295a:	e426                	sd	s1,8(sp)
    8000295c:	e04a                	sd	s2,0(sp)
    8000295e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002960:	f83fe0ef          	jal	800018e2 <myproc>
    80002964:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002966:	05853903          	ld	s2,88(a0)
    8000296a:	0a893783          	ld	a5,168(s2)
    8000296e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002972:	37fd                	addiw	a5,a5,-1
    80002974:	4759                	li	a4,22
    80002976:	00f76f63          	bltu	a4,a5,80002994 <syscall+0x40>
    8000297a:	00369713          	slli	a4,a3,0x3
    8000297e:	00005797          	auipc	a5,0x5
    80002982:	dfa78793          	addi	a5,a5,-518 # 80007778 <syscalls>
    80002986:	97ba                	add	a5,a5,a4
    80002988:	639c                	ld	a5,0(a5)
    8000298a:	c789                	beqz	a5,80002994 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000298c:	9782                	jalr	a5
    8000298e:	06a93823          	sd	a0,112(s2)
    80002992:	a829                	j	800029ac <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002994:	15848613          	addi	a2,s1,344
    80002998:	588c                	lw	a1,48(s1)
    8000299a:	00005517          	auipc	a0,0x5
    8000299e:	9de50513          	addi	a0,a0,-1570 # 80007378 <etext+0x378>
    800029a2:	b59fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800029a6:	6cbc                	ld	a5,88(s1)
    800029a8:	577d                	li	a4,-1
    800029aa:	fbb8                	sd	a4,112(a5)
  }
}
    800029ac:	60e2                	ld	ra,24(sp)
    800029ae:	6442                	ld	s0,16(sp)
    800029b0:	64a2                	ld	s1,8(sp)
    800029b2:	6902                	ld	s2,0(sp)
    800029b4:	6105                	addi	sp,sp,32
    800029b6:	8082                	ret

00000000800029b8 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800029b8:	1101                	addi	sp,sp,-32
    800029ba:	ec06                	sd	ra,24(sp)
    800029bc:	e822                	sd	s0,16(sp)
    800029be:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800029c0:	fec40593          	addi	a1,s0,-20
    800029c4:	4501                	li	a0,0
    800029c6:	f27ff0ef          	jal	800028ec <argint>
  kexit(n);
    800029ca:	fec42503          	lw	a0,-20(s0)
    800029ce:	ef0ff0ef          	jal	800020be <kexit>
  return 0;  // not reached
}
    800029d2:	4501                	li	a0,0
    800029d4:	60e2                	ld	ra,24(sp)
    800029d6:	6442                	ld	s0,16(sp)
    800029d8:	6105                	addi	sp,sp,32
    800029da:	8082                	ret

00000000800029dc <sys_getpid>:

uint64
sys_getpid(void)
{
    800029dc:	1141                	addi	sp,sp,-16
    800029de:	e406                	sd	ra,8(sp)
    800029e0:	e022                	sd	s0,0(sp)
    800029e2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029e4:	efffe0ef          	jal	800018e2 <myproc>
}
    800029e8:	5908                	lw	a0,48(a0)
    800029ea:	60a2                	ld	ra,8(sp)
    800029ec:	6402                	ld	s0,0(sp)
    800029ee:	0141                	addi	sp,sp,16
    800029f0:	8082                	ret

00000000800029f2 <sys_fork>:

uint64
sys_fork(void)
{
    800029f2:	1141                	addi	sp,sp,-16
    800029f4:	e406                	sd	ra,8(sp)
    800029f6:	e022                	sd	s0,0(sp)
    800029f8:	0800                	addi	s0,sp,16
  return kfork();
    800029fa:	a58ff0ef          	jal	80001c52 <kfork>
}
    800029fe:	60a2                	ld	ra,8(sp)
    80002a00:	6402                	ld	s0,0(sp)
    80002a02:	0141                	addi	sp,sp,16
    80002a04:	8082                	ret

0000000080002a06 <sys_wait>:

uint64
sys_wait(void)
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a0e:	fe840593          	addi	a1,s0,-24
    80002a12:	4501                	li	a0,0
    80002a14:	ef5ff0ef          	jal	80002908 <argaddr>
  return kwait(p);
    80002a18:	fe843503          	ld	a0,-24(s0)
    80002a1c:	ff8ff0ef          	jal	80002214 <kwait>
}
    80002a20:	60e2                	ld	ra,24(sp)
    80002a22:	6442                	ld	s0,16(sp)
    80002a24:	6105                	addi	sp,sp,32
    80002a26:	8082                	ret

0000000080002a28 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a28:	7179                	addi	sp,sp,-48
    80002a2a:	f406                	sd	ra,40(sp)
    80002a2c:	f022                	sd	s0,32(sp)
    80002a2e:	ec26                	sd	s1,24(sp)
    80002a30:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a32:	fd840593          	addi	a1,s0,-40
    80002a36:	4501                	li	a0,0
    80002a38:	eb5ff0ef          	jal	800028ec <argint>
  argint(1, &t);
    80002a3c:	fdc40593          	addi	a1,s0,-36
    80002a40:	4505                	li	a0,1
    80002a42:	eabff0ef          	jal	800028ec <argint>
  addr = myproc()->sz;
    80002a46:	e9dfe0ef          	jal	800018e2 <myproc>
    80002a4a:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002a4c:	fdc42703          	lw	a4,-36(s0)
    80002a50:	4785                	li	a5,1
    80002a52:	02f70763          	beq	a4,a5,80002a80 <sys_sbrk+0x58>
    80002a56:	fd842783          	lw	a5,-40(s0)
    80002a5a:	0207c363          	bltz	a5,80002a80 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002a5e:	97a6                	add	a5,a5,s1
    80002a60:	0297ee63          	bltu	a5,s1,80002a9c <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002a64:	02000737          	lui	a4,0x2000
    80002a68:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a6a:	0736                	slli	a4,a4,0xd
    80002a6c:	02f76a63          	bltu	a4,a5,80002aa0 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002a70:	e73fe0ef          	jal	800018e2 <myproc>
    80002a74:	fd842703          	lw	a4,-40(s0)
    80002a78:	653c                	ld	a5,72(a0)
    80002a7a:	97ba                	add	a5,a5,a4
    80002a7c:	e53c                	sd	a5,72(a0)
    80002a7e:	a039                	j	80002a8c <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a80:	fd842503          	lw	a0,-40(s0)
    80002a84:	96cff0ef          	jal	80001bf0 <growproc>
    80002a88:	00054863          	bltz	a0,80002a98 <sys_sbrk+0x70>
  }
  return addr;
}
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	70a2                	ld	ra,40(sp)
    80002a90:	7402                	ld	s0,32(sp)
    80002a92:	64e2                	ld	s1,24(sp)
    80002a94:	6145                	addi	sp,sp,48
    80002a96:	8082                	ret
      return -1;
    80002a98:	54fd                	li	s1,-1
    80002a9a:	bfcd                	j	80002a8c <sys_sbrk+0x64>
      return -1;
    80002a9c:	54fd                	li	s1,-1
    80002a9e:	b7fd                	j	80002a8c <sys_sbrk+0x64>
      return -1;
    80002aa0:	54fd                	li	s1,-1
    80002aa2:	b7ed                	j	80002a8c <sys_sbrk+0x64>

0000000080002aa4 <sys_pause>:

uint64
sys_pause(void)
{
    80002aa4:	7139                	addi	sp,sp,-64
    80002aa6:	fc06                	sd	ra,56(sp)
    80002aa8:	f822                	sd	s0,48(sp)
    80002aaa:	f04a                	sd	s2,32(sp)
    80002aac:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002aae:	fcc40593          	addi	a1,s0,-52
    80002ab2:	4501                	li	a0,0
    80002ab4:	e39ff0ef          	jal	800028ec <argint>
  if(n < 0)
    80002ab8:	fcc42783          	lw	a5,-52(s0)
    80002abc:	0607c763          	bltz	a5,80002b2a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002ac0:	00016517          	auipc	a0,0x16
    80002ac4:	b0050513          	addi	a0,a0,-1280 # 800185c0 <tickslock>
    80002ac8:	906fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002acc:	00007917          	auipc	s2,0x7
    80002ad0:	7a492903          	lw	s2,1956(s2) # 8000a270 <ticks>
  while(ticks - ticks0 < n){
    80002ad4:	fcc42783          	lw	a5,-52(s0)
    80002ad8:	cf8d                	beqz	a5,80002b12 <sys_pause+0x6e>
    80002ada:	f426                	sd	s1,40(sp)
    80002adc:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ade:	00016997          	auipc	s3,0x16
    80002ae2:	ae298993          	addi	s3,s3,-1310 # 800185c0 <tickslock>
    80002ae6:	00007497          	auipc	s1,0x7
    80002aea:	78a48493          	addi	s1,s1,1930 # 8000a270 <ticks>
    if(killed(myproc())){
    80002aee:	df5fe0ef          	jal	800018e2 <myproc>
    80002af2:	ef8ff0ef          	jal	800021ea <killed>
    80002af6:	ed0d                	bnez	a0,80002b30 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002af8:	85ce                	mv	a1,s3
    80002afa:	8526                	mv	a0,s1
    80002afc:	cb6ff0ef          	jal	80001fb2 <sleep>
  while(ticks - ticks0 < n){
    80002b00:	409c                	lw	a5,0(s1)
    80002b02:	412787bb          	subw	a5,a5,s2
    80002b06:	fcc42703          	lw	a4,-52(s0)
    80002b0a:	fee7e2e3          	bltu	a5,a4,80002aee <sys_pause+0x4a>
    80002b0e:	74a2                	ld	s1,40(sp)
    80002b10:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b12:	00016517          	auipc	a0,0x16
    80002b16:	aae50513          	addi	a0,a0,-1362 # 800185c0 <tickslock>
    80002b1a:	94cfe0ef          	jal	80000c66 <release>
  return 0;
    80002b1e:	4501                	li	a0,0
}
    80002b20:	70e2                	ld	ra,56(sp)
    80002b22:	7442                	ld	s0,48(sp)
    80002b24:	7902                	ld	s2,32(sp)
    80002b26:	6121                	addi	sp,sp,64
    80002b28:	8082                	ret
    n = 0;
    80002b2a:	fc042623          	sw	zero,-52(s0)
    80002b2e:	bf49                	j	80002ac0 <sys_pause+0x1c>
      release(&tickslock);
    80002b30:	00016517          	auipc	a0,0x16
    80002b34:	a9050513          	addi	a0,a0,-1392 # 800185c0 <tickslock>
    80002b38:	92efe0ef          	jal	80000c66 <release>
      return -1;
    80002b3c:	557d                	li	a0,-1
    80002b3e:	74a2                	ld	s1,40(sp)
    80002b40:	69e2                	ld	s3,24(sp)
    80002b42:	bff9                	j	80002b20 <sys_pause+0x7c>

0000000080002b44 <sys_kill>:

uint64
sys_kill(void)
{
    80002b44:	1101                	addi	sp,sp,-32
    80002b46:	ec06                	sd	ra,24(sp)
    80002b48:	e822                	sd	s0,16(sp)
    80002b4a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b4c:	fec40593          	addi	a1,s0,-20
    80002b50:	4501                	li	a0,0
    80002b52:	d9bff0ef          	jal	800028ec <argint>
  return kkill(pid);
    80002b56:	fec42503          	lw	a0,-20(s0)
    80002b5a:	e06ff0ef          	jal	80002160 <kkill>
}
    80002b5e:	60e2                	ld	ra,24(sp)
    80002b60:	6442                	ld	s0,16(sp)
    80002b62:	6105                	addi	sp,sp,32
    80002b64:	8082                	ret

0000000080002b66 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b66:	1101                	addi	sp,sp,-32
    80002b68:	ec06                	sd	ra,24(sp)
    80002b6a:	e822                	sd	s0,16(sp)
    80002b6c:	e426                	sd	s1,8(sp)
    80002b6e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b70:	00016517          	auipc	a0,0x16
    80002b74:	a5050513          	addi	a0,a0,-1456 # 800185c0 <tickslock>
    80002b78:	856fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002b7c:	00007497          	auipc	s1,0x7
    80002b80:	6f44a483          	lw	s1,1780(s1) # 8000a270 <ticks>
  release(&tickslock);
    80002b84:	00016517          	auipc	a0,0x16
    80002b88:	a3c50513          	addi	a0,a0,-1476 # 800185c0 <tickslock>
    80002b8c:	8dafe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002b90:	02049513          	slli	a0,s1,0x20
    80002b94:	9101                	srli	a0,a0,0x20
    80002b96:	60e2                	ld	ra,24(sp)
    80002b98:	6442                	ld	s0,16(sp)
    80002b9a:	64a2                	ld	s1,8(sp)
    80002b9c:	6105                	addi	sp,sp,32
    80002b9e:	8082                	ret

0000000080002ba0 <sys_getprocinfo>:

// Get process information for MLFQ debugging
uint64
sys_getprocinfo(void)
{
    80002ba0:	7139                	addi	sp,sp,-64
    80002ba2:	fc06                	sd	ra,56(sp)
    80002ba4:	f822                	sd	s0,48(sp)
    80002ba6:	f426                	sd	s1,40(sp)
    80002ba8:	0080                	addi	s0,sp,64
  uint64 addr;
  struct proc *p = myproc();
    80002baa:	d39fe0ef          	jal	800018e2 <myproc>
    80002bae:	84aa                	mv	s1,a0
  
  argaddr(0, &addr);
    80002bb0:	fd840593          	addi	a1,s0,-40
    80002bb4:	4501                	li	a0,0
    80002bb6:	d53ff0ef          	jal	80002908 <argaddr>
    int state;
    int priority;
    int time_slices;
  } info;
  
  info.pid = p->pid;
    80002bba:	589c                	lw	a5,48(s1)
    80002bbc:	fcf42423          	sw	a5,-56(s0)
  info.state = p->state;
    80002bc0:	4c9c                	lw	a5,24(s1)
    80002bc2:	fcf42623          	sw	a5,-52(s0)
  info.priority = p->priority;
    80002bc6:	1684a783          	lw	a5,360(s1)
    80002bca:	fcf42823          	sw	a5,-48(s0)
  info.time_slices = p->time_slices;
    80002bce:	16c4a783          	lw	a5,364(s1)
    80002bd2:	fcf42a23          	sw	a5,-44(s0)
  
  if(copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    80002bd6:	46c1                	li	a3,16
    80002bd8:	fc840613          	addi	a2,s0,-56
    80002bdc:	fd843583          	ld	a1,-40(s0)
    80002be0:	68a8                	ld	a0,80(s1)
    80002be2:	a01fe0ef          	jal	800015e2 <copyout>
    return -1;
  
  return 0;
}
    80002be6:	957d                	srai	a0,a0,0x3f
    80002be8:	70e2                	ld	ra,56(sp)
    80002bea:	7442                	ld	s0,48(sp)
    80002bec:	74a2                	ld	s1,40(sp)
    80002bee:	6121                	addi	sp,sp,64
    80002bf0:	8082                	ret

0000000080002bf2 <sys_boostproc>:

uint64
sys_boostproc(void)
{
    80002bf2:	1141                	addi	sp,sp,-16
    80002bf4:	e406                	sd	ra,8(sp)
    80002bf6:	e022                	sd	s0,0(sp)
    80002bf8:	0800                	addi	s0,sp,16
  extern void boost_all_priorities(void);
  
  boost_all_priorities();
    80002bfa:	966ff0ef          	jal	80001d60 <boost_all_priorities>
  
  return 0;
    80002bfe:	4501                	li	a0,0
    80002c00:	60a2                	ld	ra,8(sp)
    80002c02:	6402                	ld	s0,0(sp)
    80002c04:	0141                	addi	sp,sp,16
    80002c06:	8082                	ret

0000000080002c08 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c08:	7179                	addi	sp,sp,-48
    80002c0a:	f406                	sd	ra,40(sp)
    80002c0c:	f022                	sd	s0,32(sp)
    80002c0e:	ec26                	sd	s1,24(sp)
    80002c10:	e84a                	sd	s2,16(sp)
    80002c12:	e44e                	sd	s3,8(sp)
    80002c14:	e052                	sd	s4,0(sp)
    80002c16:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c18:	00004597          	auipc	a1,0x4
    80002c1c:	78058593          	addi	a1,a1,1920 # 80007398 <etext+0x398>
    80002c20:	00016517          	auipc	a0,0x16
    80002c24:	9b850513          	addi	a0,a0,-1608 # 800185d8 <bcache>
    80002c28:	f27fd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c2c:	0001e797          	auipc	a5,0x1e
    80002c30:	9ac78793          	addi	a5,a5,-1620 # 800205d8 <bcache+0x8000>
    80002c34:	0001e717          	auipc	a4,0x1e
    80002c38:	c0c70713          	addi	a4,a4,-1012 # 80020840 <bcache+0x8268>
    80002c3c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c40:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c44:	00016497          	auipc	s1,0x16
    80002c48:	9ac48493          	addi	s1,s1,-1620 # 800185f0 <bcache+0x18>
    b->next = bcache.head.next;
    80002c4c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c4e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c50:	00004a17          	auipc	s4,0x4
    80002c54:	750a0a13          	addi	s4,s4,1872 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002c58:	2b893783          	ld	a5,696(s2)
    80002c5c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c5e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c62:	85d2                	mv	a1,s4
    80002c64:	01048513          	addi	a0,s1,16
    80002c68:	322010ef          	jal	80003f8a <initsleeplock>
    bcache.head.next->prev = b;
    80002c6c:	2b893783          	ld	a5,696(s2)
    80002c70:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c72:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c76:	45848493          	addi	s1,s1,1112
    80002c7a:	fd349fe3          	bne	s1,s3,80002c58 <binit+0x50>
  }
}
    80002c7e:	70a2                	ld	ra,40(sp)
    80002c80:	7402                	ld	s0,32(sp)
    80002c82:	64e2                	ld	s1,24(sp)
    80002c84:	6942                	ld	s2,16(sp)
    80002c86:	69a2                	ld	s3,8(sp)
    80002c88:	6a02                	ld	s4,0(sp)
    80002c8a:	6145                	addi	sp,sp,48
    80002c8c:	8082                	ret

0000000080002c8e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c8e:	7179                	addi	sp,sp,-48
    80002c90:	f406                	sd	ra,40(sp)
    80002c92:	f022                	sd	s0,32(sp)
    80002c94:	ec26                	sd	s1,24(sp)
    80002c96:	e84a                	sd	s2,16(sp)
    80002c98:	e44e                	sd	s3,8(sp)
    80002c9a:	1800                	addi	s0,sp,48
    80002c9c:	892a                	mv	s2,a0
    80002c9e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ca0:	00016517          	auipc	a0,0x16
    80002ca4:	93850513          	addi	a0,a0,-1736 # 800185d8 <bcache>
    80002ca8:	f27fd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002cac:	0001e497          	auipc	s1,0x1e
    80002cb0:	be44b483          	ld	s1,-1052(s1) # 80020890 <bcache+0x82b8>
    80002cb4:	0001e797          	auipc	a5,0x1e
    80002cb8:	b8c78793          	addi	a5,a5,-1140 # 80020840 <bcache+0x8268>
    80002cbc:	02f48b63          	beq	s1,a5,80002cf2 <bread+0x64>
    80002cc0:	873e                	mv	a4,a5
    80002cc2:	a021                	j	80002cca <bread+0x3c>
    80002cc4:	68a4                	ld	s1,80(s1)
    80002cc6:	02e48663          	beq	s1,a4,80002cf2 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002cca:	449c                	lw	a5,8(s1)
    80002ccc:	ff279ce3          	bne	a5,s2,80002cc4 <bread+0x36>
    80002cd0:	44dc                	lw	a5,12(s1)
    80002cd2:	ff3799e3          	bne	a5,s3,80002cc4 <bread+0x36>
      b->refcnt++;
    80002cd6:	40bc                	lw	a5,64(s1)
    80002cd8:	2785                	addiw	a5,a5,1
    80002cda:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cdc:	00016517          	auipc	a0,0x16
    80002ce0:	8fc50513          	addi	a0,a0,-1796 # 800185d8 <bcache>
    80002ce4:	f83fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002ce8:	01048513          	addi	a0,s1,16
    80002cec:	2d4010ef          	jal	80003fc0 <acquiresleep>
      return b;
    80002cf0:	a889                	j	80002d42 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cf2:	0001e497          	auipc	s1,0x1e
    80002cf6:	b964b483          	ld	s1,-1130(s1) # 80020888 <bcache+0x82b0>
    80002cfa:	0001e797          	auipc	a5,0x1e
    80002cfe:	b4678793          	addi	a5,a5,-1210 # 80020840 <bcache+0x8268>
    80002d02:	00f48863          	beq	s1,a5,80002d12 <bread+0x84>
    80002d06:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d08:	40bc                	lw	a5,64(s1)
    80002d0a:	cb91                	beqz	a5,80002d1e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d0c:	64a4                	ld	s1,72(s1)
    80002d0e:	fee49de3          	bne	s1,a4,80002d08 <bread+0x7a>
  panic("bget: no buffers");
    80002d12:	00004517          	auipc	a0,0x4
    80002d16:	69650513          	addi	a0,a0,1686 # 800073a8 <etext+0x3a8>
    80002d1a:	ac7fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002d1e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d22:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d26:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d2a:	4785                	li	a5,1
    80002d2c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d2e:	00016517          	auipc	a0,0x16
    80002d32:	8aa50513          	addi	a0,a0,-1878 # 800185d8 <bcache>
    80002d36:	f31fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002d3a:	01048513          	addi	a0,s1,16
    80002d3e:	282010ef          	jal	80003fc0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d42:	409c                	lw	a5,0(s1)
    80002d44:	cb89                	beqz	a5,80002d56 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d46:	8526                	mv	a0,s1
    80002d48:	70a2                	ld	ra,40(sp)
    80002d4a:	7402                	ld	s0,32(sp)
    80002d4c:	64e2                	ld	s1,24(sp)
    80002d4e:	6942                	ld	s2,16(sp)
    80002d50:	69a2                	ld	s3,8(sp)
    80002d52:	6145                	addi	sp,sp,48
    80002d54:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d56:	4581                	li	a1,0
    80002d58:	8526                	mv	a0,s1
    80002d5a:	2d7020ef          	jal	80005830 <virtio_disk_rw>
    b->valid = 1;
    80002d5e:	4785                	li	a5,1
    80002d60:	c09c                	sw	a5,0(s1)
  return b;
    80002d62:	b7d5                	j	80002d46 <bread+0xb8>

0000000080002d64 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d64:	1101                	addi	sp,sp,-32
    80002d66:	ec06                	sd	ra,24(sp)
    80002d68:	e822                	sd	s0,16(sp)
    80002d6a:	e426                	sd	s1,8(sp)
    80002d6c:	1000                	addi	s0,sp,32
    80002d6e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d70:	0541                	addi	a0,a0,16
    80002d72:	2cc010ef          	jal	8000403e <holdingsleep>
    80002d76:	c911                	beqz	a0,80002d8a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d78:	4585                	li	a1,1
    80002d7a:	8526                	mv	a0,s1
    80002d7c:	2b5020ef          	jal	80005830 <virtio_disk_rw>
}
    80002d80:	60e2                	ld	ra,24(sp)
    80002d82:	6442                	ld	s0,16(sp)
    80002d84:	64a2                	ld	s1,8(sp)
    80002d86:	6105                	addi	sp,sp,32
    80002d88:	8082                	ret
    panic("bwrite");
    80002d8a:	00004517          	auipc	a0,0x4
    80002d8e:	63650513          	addi	a0,a0,1590 # 800073c0 <etext+0x3c0>
    80002d92:	a4ffd0ef          	jal	800007e0 <panic>

0000000080002d96 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d96:	1101                	addi	sp,sp,-32
    80002d98:	ec06                	sd	ra,24(sp)
    80002d9a:	e822                	sd	s0,16(sp)
    80002d9c:	e426                	sd	s1,8(sp)
    80002d9e:	e04a                	sd	s2,0(sp)
    80002da0:	1000                	addi	s0,sp,32
    80002da2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002da4:	01050913          	addi	s2,a0,16
    80002da8:	854a                	mv	a0,s2
    80002daa:	294010ef          	jal	8000403e <holdingsleep>
    80002dae:	c135                	beqz	a0,80002e12 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002db0:	854a                	mv	a0,s2
    80002db2:	254010ef          	jal	80004006 <releasesleep>

  acquire(&bcache.lock);
    80002db6:	00016517          	auipc	a0,0x16
    80002dba:	82250513          	addi	a0,a0,-2014 # 800185d8 <bcache>
    80002dbe:	e11fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002dc2:	40bc                	lw	a5,64(s1)
    80002dc4:	37fd                	addiw	a5,a5,-1
    80002dc6:	0007871b          	sext.w	a4,a5
    80002dca:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002dcc:	e71d                	bnez	a4,80002dfa <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002dce:	68b8                	ld	a4,80(s1)
    80002dd0:	64bc                	ld	a5,72(s1)
    80002dd2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002dd4:	68b8                	ld	a4,80(s1)
    80002dd6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002dd8:	0001e797          	auipc	a5,0x1e
    80002ddc:	80078793          	addi	a5,a5,-2048 # 800205d8 <bcache+0x8000>
    80002de0:	2b87b703          	ld	a4,696(a5)
    80002de4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002de6:	0001e717          	auipc	a4,0x1e
    80002dea:	a5a70713          	addi	a4,a4,-1446 # 80020840 <bcache+0x8268>
    80002dee:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002df0:	2b87b703          	ld	a4,696(a5)
    80002df4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002df6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002dfa:	00015517          	auipc	a0,0x15
    80002dfe:	7de50513          	addi	a0,a0,2014 # 800185d8 <bcache>
    80002e02:	e65fd0ef          	jal	80000c66 <release>
}
    80002e06:	60e2                	ld	ra,24(sp)
    80002e08:	6442                	ld	s0,16(sp)
    80002e0a:	64a2                	ld	s1,8(sp)
    80002e0c:	6902                	ld	s2,0(sp)
    80002e0e:	6105                	addi	sp,sp,32
    80002e10:	8082                	ret
    panic("brelse");
    80002e12:	00004517          	auipc	a0,0x4
    80002e16:	5b650513          	addi	a0,a0,1462 # 800073c8 <etext+0x3c8>
    80002e1a:	9c7fd0ef          	jal	800007e0 <panic>

0000000080002e1e <bpin>:

void
bpin(struct buf *b) {
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	e426                	sd	s1,8(sp)
    80002e26:	1000                	addi	s0,sp,32
    80002e28:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e2a:	00015517          	auipc	a0,0x15
    80002e2e:	7ae50513          	addi	a0,a0,1966 # 800185d8 <bcache>
    80002e32:	d9dfd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002e36:	40bc                	lw	a5,64(s1)
    80002e38:	2785                	addiw	a5,a5,1
    80002e3a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e3c:	00015517          	auipc	a0,0x15
    80002e40:	79c50513          	addi	a0,a0,1948 # 800185d8 <bcache>
    80002e44:	e23fd0ef          	jal	80000c66 <release>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6105                	addi	sp,sp,32
    80002e50:	8082                	ret

0000000080002e52 <bunpin>:

void
bunpin(struct buf *b) {
    80002e52:	1101                	addi	sp,sp,-32
    80002e54:	ec06                	sd	ra,24(sp)
    80002e56:	e822                	sd	s0,16(sp)
    80002e58:	e426                	sd	s1,8(sp)
    80002e5a:	1000                	addi	s0,sp,32
    80002e5c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e5e:	00015517          	auipc	a0,0x15
    80002e62:	77a50513          	addi	a0,a0,1914 # 800185d8 <bcache>
    80002e66:	d69fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002e6a:	40bc                	lw	a5,64(s1)
    80002e6c:	37fd                	addiw	a5,a5,-1
    80002e6e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e70:	00015517          	auipc	a0,0x15
    80002e74:	76850513          	addi	a0,a0,1896 # 800185d8 <bcache>
    80002e78:	deffd0ef          	jal	80000c66 <release>
}
    80002e7c:	60e2                	ld	ra,24(sp)
    80002e7e:	6442                	ld	s0,16(sp)
    80002e80:	64a2                	ld	s1,8(sp)
    80002e82:	6105                	addi	sp,sp,32
    80002e84:	8082                	ret

0000000080002e86 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e86:	1101                	addi	sp,sp,-32
    80002e88:	ec06                	sd	ra,24(sp)
    80002e8a:	e822                	sd	s0,16(sp)
    80002e8c:	e426                	sd	s1,8(sp)
    80002e8e:	e04a                	sd	s2,0(sp)
    80002e90:	1000                	addi	s0,sp,32
    80002e92:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e94:	00d5d59b          	srliw	a1,a1,0xd
    80002e98:	0001e797          	auipc	a5,0x1e
    80002e9c:	e1c7a783          	lw	a5,-484(a5) # 80020cb4 <sb+0x1c>
    80002ea0:	9dbd                	addw	a1,a1,a5
    80002ea2:	dedff0ef          	jal	80002c8e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ea6:	0074f713          	andi	a4,s1,7
    80002eaa:	4785                	li	a5,1
    80002eac:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002eb0:	14ce                	slli	s1,s1,0x33
    80002eb2:	90d9                	srli	s1,s1,0x36
    80002eb4:	00950733          	add	a4,a0,s1
    80002eb8:	05874703          	lbu	a4,88(a4)
    80002ebc:	00e7f6b3          	and	a3,a5,a4
    80002ec0:	c29d                	beqz	a3,80002ee6 <bfree+0x60>
    80002ec2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002ec4:	94aa                	add	s1,s1,a0
    80002ec6:	fff7c793          	not	a5,a5
    80002eca:	8f7d                	and	a4,a4,a5
    80002ecc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002ed0:	7f9000ef          	jal	80003ec8 <log_write>
  brelse(bp);
    80002ed4:	854a                	mv	a0,s2
    80002ed6:	ec1ff0ef          	jal	80002d96 <brelse>
}
    80002eda:	60e2                	ld	ra,24(sp)
    80002edc:	6442                	ld	s0,16(sp)
    80002ede:	64a2                	ld	s1,8(sp)
    80002ee0:	6902                	ld	s2,0(sp)
    80002ee2:	6105                	addi	sp,sp,32
    80002ee4:	8082                	ret
    panic("freeing free block");
    80002ee6:	00004517          	auipc	a0,0x4
    80002eea:	4ea50513          	addi	a0,a0,1258 # 800073d0 <etext+0x3d0>
    80002eee:	8f3fd0ef          	jal	800007e0 <panic>

0000000080002ef2 <balloc>:
{
    80002ef2:	711d                	addi	sp,sp,-96
    80002ef4:	ec86                	sd	ra,88(sp)
    80002ef6:	e8a2                	sd	s0,80(sp)
    80002ef8:	e4a6                	sd	s1,72(sp)
    80002efa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002efc:	0001e797          	auipc	a5,0x1e
    80002f00:	da07a783          	lw	a5,-608(a5) # 80020c9c <sb+0x4>
    80002f04:	0e078f63          	beqz	a5,80003002 <balloc+0x110>
    80002f08:	e0ca                	sd	s2,64(sp)
    80002f0a:	fc4e                	sd	s3,56(sp)
    80002f0c:	f852                	sd	s4,48(sp)
    80002f0e:	f456                	sd	s5,40(sp)
    80002f10:	f05a                	sd	s6,32(sp)
    80002f12:	ec5e                	sd	s7,24(sp)
    80002f14:	e862                	sd	s8,16(sp)
    80002f16:	e466                	sd	s9,8(sp)
    80002f18:	8baa                	mv	s7,a0
    80002f1a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f1c:	0001eb17          	auipc	s6,0x1e
    80002f20:	d7cb0b13          	addi	s6,s6,-644 # 80020c98 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f24:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f26:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f28:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f2a:	6c89                	lui	s9,0x2
    80002f2c:	a0b5                	j	80002f98 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f2e:	97ca                	add	a5,a5,s2
    80002f30:	8e55                	or	a2,a2,a3
    80002f32:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f36:	854a                	mv	a0,s2
    80002f38:	791000ef          	jal	80003ec8 <log_write>
        brelse(bp);
    80002f3c:	854a                	mv	a0,s2
    80002f3e:	e59ff0ef          	jal	80002d96 <brelse>
  bp = bread(dev, bno);
    80002f42:	85a6                	mv	a1,s1
    80002f44:	855e                	mv	a0,s7
    80002f46:	d49ff0ef          	jal	80002c8e <bread>
    80002f4a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f4c:	40000613          	li	a2,1024
    80002f50:	4581                	li	a1,0
    80002f52:	05850513          	addi	a0,a0,88
    80002f56:	d4dfd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002f5a:	854a                	mv	a0,s2
    80002f5c:	76d000ef          	jal	80003ec8 <log_write>
  brelse(bp);
    80002f60:	854a                	mv	a0,s2
    80002f62:	e35ff0ef          	jal	80002d96 <brelse>
}
    80002f66:	6906                	ld	s2,64(sp)
    80002f68:	79e2                	ld	s3,56(sp)
    80002f6a:	7a42                	ld	s4,48(sp)
    80002f6c:	7aa2                	ld	s5,40(sp)
    80002f6e:	7b02                	ld	s6,32(sp)
    80002f70:	6be2                	ld	s7,24(sp)
    80002f72:	6c42                	ld	s8,16(sp)
    80002f74:	6ca2                	ld	s9,8(sp)
}
    80002f76:	8526                	mv	a0,s1
    80002f78:	60e6                	ld	ra,88(sp)
    80002f7a:	6446                	ld	s0,80(sp)
    80002f7c:	64a6                	ld	s1,72(sp)
    80002f7e:	6125                	addi	sp,sp,96
    80002f80:	8082                	ret
    brelse(bp);
    80002f82:	854a                	mv	a0,s2
    80002f84:	e13ff0ef          	jal	80002d96 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f88:	015c87bb          	addw	a5,s9,s5
    80002f8c:	00078a9b          	sext.w	s5,a5
    80002f90:	004b2703          	lw	a4,4(s6)
    80002f94:	04eaff63          	bgeu	s5,a4,80002ff2 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002f98:	41fad79b          	sraiw	a5,s5,0x1f
    80002f9c:	0137d79b          	srliw	a5,a5,0x13
    80002fa0:	015787bb          	addw	a5,a5,s5
    80002fa4:	40d7d79b          	sraiw	a5,a5,0xd
    80002fa8:	01cb2583          	lw	a1,28(s6)
    80002fac:	9dbd                	addw	a1,a1,a5
    80002fae:	855e                	mv	a0,s7
    80002fb0:	cdfff0ef          	jal	80002c8e <bread>
    80002fb4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fb6:	004b2503          	lw	a0,4(s6)
    80002fba:	000a849b          	sext.w	s1,s5
    80002fbe:	8762                	mv	a4,s8
    80002fc0:	fca4f1e3          	bgeu	s1,a0,80002f82 <balloc+0x90>
      m = 1 << (bi % 8);
    80002fc4:	00777693          	andi	a3,a4,7
    80002fc8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002fcc:	41f7579b          	sraiw	a5,a4,0x1f
    80002fd0:	01d7d79b          	srliw	a5,a5,0x1d
    80002fd4:	9fb9                	addw	a5,a5,a4
    80002fd6:	4037d79b          	sraiw	a5,a5,0x3
    80002fda:	00f90633          	add	a2,s2,a5
    80002fde:	05864603          	lbu	a2,88(a2)
    80002fe2:	00c6f5b3          	and	a1,a3,a2
    80002fe6:	d5a1                	beqz	a1,80002f2e <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fe8:	2705                	addiw	a4,a4,1
    80002fea:	2485                	addiw	s1,s1,1
    80002fec:	fd471ae3          	bne	a4,s4,80002fc0 <balloc+0xce>
    80002ff0:	bf49                	j	80002f82 <balloc+0x90>
    80002ff2:	6906                	ld	s2,64(sp)
    80002ff4:	79e2                	ld	s3,56(sp)
    80002ff6:	7a42                	ld	s4,48(sp)
    80002ff8:	7aa2                	ld	s5,40(sp)
    80002ffa:	7b02                	ld	s6,32(sp)
    80002ffc:	6be2                	ld	s7,24(sp)
    80002ffe:	6c42                	ld	s8,16(sp)
    80003000:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003002:	00004517          	auipc	a0,0x4
    80003006:	3e650513          	addi	a0,a0,998 # 800073e8 <etext+0x3e8>
    8000300a:	cf0fd0ef          	jal	800004fa <printf>
  return 0;
    8000300e:	4481                	li	s1,0
    80003010:	b79d                	j	80002f76 <balloc+0x84>

0000000080003012 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003012:	7179                	addi	sp,sp,-48
    80003014:	f406                	sd	ra,40(sp)
    80003016:	f022                	sd	s0,32(sp)
    80003018:	ec26                	sd	s1,24(sp)
    8000301a:	e84a                	sd	s2,16(sp)
    8000301c:	e44e                	sd	s3,8(sp)
    8000301e:	1800                	addi	s0,sp,48
    80003020:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003022:	47ad                	li	a5,11
    80003024:	02b7e663          	bltu	a5,a1,80003050 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003028:	02059793          	slli	a5,a1,0x20
    8000302c:	01e7d593          	srli	a1,a5,0x1e
    80003030:	00b504b3          	add	s1,a0,a1
    80003034:	0504a903          	lw	s2,80(s1)
    80003038:	06091a63          	bnez	s2,800030ac <bmap+0x9a>
      addr = balloc(ip->dev);
    8000303c:	4108                	lw	a0,0(a0)
    8000303e:	eb5ff0ef          	jal	80002ef2 <balloc>
    80003042:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003046:	06090363          	beqz	s2,800030ac <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000304a:	0524a823          	sw	s2,80(s1)
    8000304e:	a8b9                	j	800030ac <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003050:	ff45849b          	addiw	s1,a1,-12
    80003054:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003058:	0ff00793          	li	a5,255
    8000305c:	06e7ee63          	bltu	a5,a4,800030d8 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003060:	08052903          	lw	s2,128(a0)
    80003064:	00091d63          	bnez	s2,8000307e <bmap+0x6c>
      addr = balloc(ip->dev);
    80003068:	4108                	lw	a0,0(a0)
    8000306a:	e89ff0ef          	jal	80002ef2 <balloc>
    8000306e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003072:	02090d63          	beqz	s2,800030ac <bmap+0x9a>
    80003076:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003078:	0929a023          	sw	s2,128(s3)
    8000307c:	a011                	j	80003080 <bmap+0x6e>
    8000307e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003080:	85ca                	mv	a1,s2
    80003082:	0009a503          	lw	a0,0(s3)
    80003086:	c09ff0ef          	jal	80002c8e <bread>
    8000308a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000308c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003090:	02049713          	slli	a4,s1,0x20
    80003094:	01e75593          	srli	a1,a4,0x1e
    80003098:	00b784b3          	add	s1,a5,a1
    8000309c:	0004a903          	lw	s2,0(s1)
    800030a0:	00090e63          	beqz	s2,800030bc <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030a4:	8552                	mv	a0,s4
    800030a6:	cf1ff0ef          	jal	80002d96 <brelse>
    return addr;
    800030aa:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030ac:	854a                	mv	a0,s2
    800030ae:	70a2                	ld	ra,40(sp)
    800030b0:	7402                	ld	s0,32(sp)
    800030b2:	64e2                	ld	s1,24(sp)
    800030b4:	6942                	ld	s2,16(sp)
    800030b6:	69a2                	ld	s3,8(sp)
    800030b8:	6145                	addi	sp,sp,48
    800030ba:	8082                	ret
      addr = balloc(ip->dev);
    800030bc:	0009a503          	lw	a0,0(s3)
    800030c0:	e33ff0ef          	jal	80002ef2 <balloc>
    800030c4:	0005091b          	sext.w	s2,a0
      if(addr){
    800030c8:	fc090ee3          	beqz	s2,800030a4 <bmap+0x92>
        a[bn] = addr;
    800030cc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800030d0:	8552                	mv	a0,s4
    800030d2:	5f7000ef          	jal	80003ec8 <log_write>
    800030d6:	b7f9                	j	800030a4 <bmap+0x92>
    800030d8:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800030da:	00004517          	auipc	a0,0x4
    800030de:	32650513          	addi	a0,a0,806 # 80007400 <etext+0x400>
    800030e2:	efefd0ef          	jal	800007e0 <panic>

00000000800030e6 <iget>:
{
    800030e6:	7179                	addi	sp,sp,-48
    800030e8:	f406                	sd	ra,40(sp)
    800030ea:	f022                	sd	s0,32(sp)
    800030ec:	ec26                	sd	s1,24(sp)
    800030ee:	e84a                	sd	s2,16(sp)
    800030f0:	e44e                	sd	s3,8(sp)
    800030f2:	e052                	sd	s4,0(sp)
    800030f4:	1800                	addi	s0,sp,48
    800030f6:	89aa                	mv	s3,a0
    800030f8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800030fa:	0001e517          	auipc	a0,0x1e
    800030fe:	bbe50513          	addi	a0,a0,-1090 # 80020cb8 <itable>
    80003102:	acdfd0ef          	jal	80000bce <acquire>
  empty = 0;
    80003106:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003108:	0001e497          	auipc	s1,0x1e
    8000310c:	bc848493          	addi	s1,s1,-1080 # 80020cd0 <itable+0x18>
    80003110:	0001f697          	auipc	a3,0x1f
    80003114:	65068693          	addi	a3,a3,1616 # 80022760 <log>
    80003118:	a039                	j	80003126 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000311a:	02090963          	beqz	s2,8000314c <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000311e:	08848493          	addi	s1,s1,136
    80003122:	02d48863          	beq	s1,a3,80003152 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003126:	449c                	lw	a5,8(s1)
    80003128:	fef059e3          	blez	a5,8000311a <iget+0x34>
    8000312c:	4098                	lw	a4,0(s1)
    8000312e:	ff3716e3          	bne	a4,s3,8000311a <iget+0x34>
    80003132:	40d8                	lw	a4,4(s1)
    80003134:	ff4713e3          	bne	a4,s4,8000311a <iget+0x34>
      ip->ref++;
    80003138:	2785                	addiw	a5,a5,1
    8000313a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000313c:	0001e517          	auipc	a0,0x1e
    80003140:	b7c50513          	addi	a0,a0,-1156 # 80020cb8 <itable>
    80003144:	b23fd0ef          	jal	80000c66 <release>
      return ip;
    80003148:	8926                	mv	s2,s1
    8000314a:	a02d                	j	80003174 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000314c:	fbe9                	bnez	a5,8000311e <iget+0x38>
      empty = ip;
    8000314e:	8926                	mv	s2,s1
    80003150:	b7f9                	j	8000311e <iget+0x38>
  if(empty == 0)
    80003152:	02090a63          	beqz	s2,80003186 <iget+0xa0>
  ip->dev = dev;
    80003156:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000315a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000315e:	4785                	li	a5,1
    80003160:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003164:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003168:	0001e517          	auipc	a0,0x1e
    8000316c:	b5050513          	addi	a0,a0,-1200 # 80020cb8 <itable>
    80003170:	af7fd0ef          	jal	80000c66 <release>
}
    80003174:	854a                	mv	a0,s2
    80003176:	70a2                	ld	ra,40(sp)
    80003178:	7402                	ld	s0,32(sp)
    8000317a:	64e2                	ld	s1,24(sp)
    8000317c:	6942                	ld	s2,16(sp)
    8000317e:	69a2                	ld	s3,8(sp)
    80003180:	6a02                	ld	s4,0(sp)
    80003182:	6145                	addi	sp,sp,48
    80003184:	8082                	ret
    panic("iget: no inodes");
    80003186:	00004517          	auipc	a0,0x4
    8000318a:	29250513          	addi	a0,a0,658 # 80007418 <etext+0x418>
    8000318e:	e52fd0ef          	jal	800007e0 <panic>

0000000080003192 <iinit>:
{
    80003192:	7179                	addi	sp,sp,-48
    80003194:	f406                	sd	ra,40(sp)
    80003196:	f022                	sd	s0,32(sp)
    80003198:	ec26                	sd	s1,24(sp)
    8000319a:	e84a                	sd	s2,16(sp)
    8000319c:	e44e                	sd	s3,8(sp)
    8000319e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031a0:	00004597          	auipc	a1,0x4
    800031a4:	28858593          	addi	a1,a1,648 # 80007428 <etext+0x428>
    800031a8:	0001e517          	auipc	a0,0x1e
    800031ac:	b1050513          	addi	a0,a0,-1264 # 80020cb8 <itable>
    800031b0:	99ffd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    800031b4:	0001e497          	auipc	s1,0x1e
    800031b8:	b2c48493          	addi	s1,s1,-1236 # 80020ce0 <itable+0x28>
    800031bc:	0001f997          	auipc	s3,0x1f
    800031c0:	5b498993          	addi	s3,s3,1460 # 80022770 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031c4:	00004917          	auipc	s2,0x4
    800031c8:	26c90913          	addi	s2,s2,620 # 80007430 <etext+0x430>
    800031cc:	85ca                	mv	a1,s2
    800031ce:	8526                	mv	a0,s1
    800031d0:	5bb000ef          	jal	80003f8a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800031d4:	08848493          	addi	s1,s1,136
    800031d8:	ff349ae3          	bne	s1,s3,800031cc <iinit+0x3a>
}
    800031dc:	70a2                	ld	ra,40(sp)
    800031de:	7402                	ld	s0,32(sp)
    800031e0:	64e2                	ld	s1,24(sp)
    800031e2:	6942                	ld	s2,16(sp)
    800031e4:	69a2                	ld	s3,8(sp)
    800031e6:	6145                	addi	sp,sp,48
    800031e8:	8082                	ret

00000000800031ea <ialloc>:
{
    800031ea:	7139                	addi	sp,sp,-64
    800031ec:	fc06                	sd	ra,56(sp)
    800031ee:	f822                	sd	s0,48(sp)
    800031f0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800031f2:	0001e717          	auipc	a4,0x1e
    800031f6:	ab272703          	lw	a4,-1358(a4) # 80020ca4 <sb+0xc>
    800031fa:	4785                	li	a5,1
    800031fc:	06e7f063          	bgeu	a5,a4,8000325c <ialloc+0x72>
    80003200:	f426                	sd	s1,40(sp)
    80003202:	f04a                	sd	s2,32(sp)
    80003204:	ec4e                	sd	s3,24(sp)
    80003206:	e852                	sd	s4,16(sp)
    80003208:	e456                	sd	s5,8(sp)
    8000320a:	e05a                	sd	s6,0(sp)
    8000320c:	8aaa                	mv	s5,a0
    8000320e:	8b2e                	mv	s6,a1
    80003210:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003212:	0001ea17          	auipc	s4,0x1e
    80003216:	a86a0a13          	addi	s4,s4,-1402 # 80020c98 <sb>
    8000321a:	00495593          	srli	a1,s2,0x4
    8000321e:	018a2783          	lw	a5,24(s4)
    80003222:	9dbd                	addw	a1,a1,a5
    80003224:	8556                	mv	a0,s5
    80003226:	a69ff0ef          	jal	80002c8e <bread>
    8000322a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000322c:	05850993          	addi	s3,a0,88
    80003230:	00f97793          	andi	a5,s2,15
    80003234:	079a                	slli	a5,a5,0x6
    80003236:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003238:	00099783          	lh	a5,0(s3)
    8000323c:	cb9d                	beqz	a5,80003272 <ialloc+0x88>
    brelse(bp);
    8000323e:	b59ff0ef          	jal	80002d96 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003242:	0905                	addi	s2,s2,1
    80003244:	00ca2703          	lw	a4,12(s4)
    80003248:	0009079b          	sext.w	a5,s2
    8000324c:	fce7e7e3          	bltu	a5,a4,8000321a <ialloc+0x30>
    80003250:	74a2                	ld	s1,40(sp)
    80003252:	7902                	ld	s2,32(sp)
    80003254:	69e2                	ld	s3,24(sp)
    80003256:	6a42                	ld	s4,16(sp)
    80003258:	6aa2                	ld	s5,8(sp)
    8000325a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000325c:	00004517          	auipc	a0,0x4
    80003260:	1dc50513          	addi	a0,a0,476 # 80007438 <etext+0x438>
    80003264:	a96fd0ef          	jal	800004fa <printf>
  return 0;
    80003268:	4501                	li	a0,0
}
    8000326a:	70e2                	ld	ra,56(sp)
    8000326c:	7442                	ld	s0,48(sp)
    8000326e:	6121                	addi	sp,sp,64
    80003270:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003272:	04000613          	li	a2,64
    80003276:	4581                	li	a1,0
    80003278:	854e                	mv	a0,s3
    8000327a:	a29fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    8000327e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003282:	8526                	mv	a0,s1
    80003284:	445000ef          	jal	80003ec8 <log_write>
      brelse(bp);
    80003288:	8526                	mv	a0,s1
    8000328a:	b0dff0ef          	jal	80002d96 <brelse>
      return iget(dev, inum);
    8000328e:	0009059b          	sext.w	a1,s2
    80003292:	8556                	mv	a0,s5
    80003294:	e53ff0ef          	jal	800030e6 <iget>
    80003298:	74a2                	ld	s1,40(sp)
    8000329a:	7902                	ld	s2,32(sp)
    8000329c:	69e2                	ld	s3,24(sp)
    8000329e:	6a42                	ld	s4,16(sp)
    800032a0:	6aa2                	ld	s5,8(sp)
    800032a2:	6b02                	ld	s6,0(sp)
    800032a4:	b7d9                	j	8000326a <ialloc+0x80>

00000000800032a6 <iupdate>:
{
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	e426                	sd	s1,8(sp)
    800032ae:	e04a                	sd	s2,0(sp)
    800032b0:	1000                	addi	s0,sp,32
    800032b2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032b4:	415c                	lw	a5,4(a0)
    800032b6:	0047d79b          	srliw	a5,a5,0x4
    800032ba:	0001e597          	auipc	a1,0x1e
    800032be:	9f65a583          	lw	a1,-1546(a1) # 80020cb0 <sb+0x18>
    800032c2:	9dbd                	addw	a1,a1,a5
    800032c4:	4108                	lw	a0,0(a0)
    800032c6:	9c9ff0ef          	jal	80002c8e <bread>
    800032ca:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032cc:	05850793          	addi	a5,a0,88
    800032d0:	40d8                	lw	a4,4(s1)
    800032d2:	8b3d                	andi	a4,a4,15
    800032d4:	071a                	slli	a4,a4,0x6
    800032d6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800032d8:	04449703          	lh	a4,68(s1)
    800032dc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800032e0:	04649703          	lh	a4,70(s1)
    800032e4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800032e8:	04849703          	lh	a4,72(s1)
    800032ec:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800032f0:	04a49703          	lh	a4,74(s1)
    800032f4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800032f8:	44f8                	lw	a4,76(s1)
    800032fa:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032fc:	03400613          	li	a2,52
    80003300:	05048593          	addi	a1,s1,80
    80003304:	00c78513          	addi	a0,a5,12
    80003308:	9f7fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    8000330c:	854a                	mv	a0,s2
    8000330e:	3bb000ef          	jal	80003ec8 <log_write>
  brelse(bp);
    80003312:	854a                	mv	a0,s2
    80003314:	a83ff0ef          	jal	80002d96 <brelse>
}
    80003318:	60e2                	ld	ra,24(sp)
    8000331a:	6442                	ld	s0,16(sp)
    8000331c:	64a2                	ld	s1,8(sp)
    8000331e:	6902                	ld	s2,0(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret

0000000080003324 <idup>:
{
    80003324:	1101                	addi	sp,sp,-32
    80003326:	ec06                	sd	ra,24(sp)
    80003328:	e822                	sd	s0,16(sp)
    8000332a:	e426                	sd	s1,8(sp)
    8000332c:	1000                	addi	s0,sp,32
    8000332e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003330:	0001e517          	auipc	a0,0x1e
    80003334:	98850513          	addi	a0,a0,-1656 # 80020cb8 <itable>
    80003338:	897fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    8000333c:	449c                	lw	a5,8(s1)
    8000333e:	2785                	addiw	a5,a5,1
    80003340:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003342:	0001e517          	auipc	a0,0x1e
    80003346:	97650513          	addi	a0,a0,-1674 # 80020cb8 <itable>
    8000334a:	91dfd0ef          	jal	80000c66 <release>
}
    8000334e:	8526                	mv	a0,s1
    80003350:	60e2                	ld	ra,24(sp)
    80003352:	6442                	ld	s0,16(sp)
    80003354:	64a2                	ld	s1,8(sp)
    80003356:	6105                	addi	sp,sp,32
    80003358:	8082                	ret

000000008000335a <ilock>:
{
    8000335a:	1101                	addi	sp,sp,-32
    8000335c:	ec06                	sd	ra,24(sp)
    8000335e:	e822                	sd	s0,16(sp)
    80003360:	e426                	sd	s1,8(sp)
    80003362:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003364:	cd19                	beqz	a0,80003382 <ilock+0x28>
    80003366:	84aa                	mv	s1,a0
    80003368:	451c                	lw	a5,8(a0)
    8000336a:	00f05c63          	blez	a5,80003382 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000336e:	0541                	addi	a0,a0,16
    80003370:	451000ef          	jal	80003fc0 <acquiresleep>
  if(ip->valid == 0){
    80003374:	40bc                	lw	a5,64(s1)
    80003376:	cf89                	beqz	a5,80003390 <ilock+0x36>
}
    80003378:	60e2                	ld	ra,24(sp)
    8000337a:	6442                	ld	s0,16(sp)
    8000337c:	64a2                	ld	s1,8(sp)
    8000337e:	6105                	addi	sp,sp,32
    80003380:	8082                	ret
    80003382:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003384:	00004517          	auipc	a0,0x4
    80003388:	0cc50513          	addi	a0,a0,204 # 80007450 <etext+0x450>
    8000338c:	c54fd0ef          	jal	800007e0 <panic>
    80003390:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003392:	40dc                	lw	a5,4(s1)
    80003394:	0047d79b          	srliw	a5,a5,0x4
    80003398:	0001e597          	auipc	a1,0x1e
    8000339c:	9185a583          	lw	a1,-1768(a1) # 80020cb0 <sb+0x18>
    800033a0:	9dbd                	addw	a1,a1,a5
    800033a2:	4088                	lw	a0,0(s1)
    800033a4:	8ebff0ef          	jal	80002c8e <bread>
    800033a8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033aa:	05850593          	addi	a1,a0,88
    800033ae:	40dc                	lw	a5,4(s1)
    800033b0:	8bbd                	andi	a5,a5,15
    800033b2:	079a                	slli	a5,a5,0x6
    800033b4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033b6:	00059783          	lh	a5,0(a1)
    800033ba:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033be:	00259783          	lh	a5,2(a1)
    800033c2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033c6:	00459783          	lh	a5,4(a1)
    800033ca:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033ce:	00659783          	lh	a5,6(a1)
    800033d2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033d6:	459c                	lw	a5,8(a1)
    800033d8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033da:	03400613          	li	a2,52
    800033de:	05b1                	addi	a1,a1,12
    800033e0:	05048513          	addi	a0,s1,80
    800033e4:	91bfd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    800033e8:	854a                	mv	a0,s2
    800033ea:	9adff0ef          	jal	80002d96 <brelse>
    ip->valid = 1;
    800033ee:	4785                	li	a5,1
    800033f0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800033f2:	04449783          	lh	a5,68(s1)
    800033f6:	c399                	beqz	a5,800033fc <ilock+0xa2>
    800033f8:	6902                	ld	s2,0(sp)
    800033fa:	bfbd                	j	80003378 <ilock+0x1e>
      panic("ilock: no type");
    800033fc:	00004517          	auipc	a0,0x4
    80003400:	05c50513          	addi	a0,a0,92 # 80007458 <etext+0x458>
    80003404:	bdcfd0ef          	jal	800007e0 <panic>

0000000080003408 <iunlock>:
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	e426                	sd	s1,8(sp)
    80003410:	e04a                	sd	s2,0(sp)
    80003412:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003414:	c505                	beqz	a0,8000343c <iunlock+0x34>
    80003416:	84aa                	mv	s1,a0
    80003418:	01050913          	addi	s2,a0,16
    8000341c:	854a                	mv	a0,s2
    8000341e:	421000ef          	jal	8000403e <holdingsleep>
    80003422:	cd09                	beqz	a0,8000343c <iunlock+0x34>
    80003424:	449c                	lw	a5,8(s1)
    80003426:	00f05b63          	blez	a5,8000343c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000342a:	854a                	mv	a0,s2
    8000342c:	3db000ef          	jal	80004006 <releasesleep>
}
    80003430:	60e2                	ld	ra,24(sp)
    80003432:	6442                	ld	s0,16(sp)
    80003434:	64a2                	ld	s1,8(sp)
    80003436:	6902                	ld	s2,0(sp)
    80003438:	6105                	addi	sp,sp,32
    8000343a:	8082                	ret
    panic("iunlock");
    8000343c:	00004517          	auipc	a0,0x4
    80003440:	02c50513          	addi	a0,a0,44 # 80007468 <etext+0x468>
    80003444:	b9cfd0ef          	jal	800007e0 <panic>

0000000080003448 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003448:	7179                	addi	sp,sp,-48
    8000344a:	f406                	sd	ra,40(sp)
    8000344c:	f022                	sd	s0,32(sp)
    8000344e:	ec26                	sd	s1,24(sp)
    80003450:	e84a                	sd	s2,16(sp)
    80003452:	e44e                	sd	s3,8(sp)
    80003454:	1800                	addi	s0,sp,48
    80003456:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003458:	05050493          	addi	s1,a0,80
    8000345c:	08050913          	addi	s2,a0,128
    80003460:	a021                	j	80003468 <itrunc+0x20>
    80003462:	0491                	addi	s1,s1,4
    80003464:	01248b63          	beq	s1,s2,8000347a <itrunc+0x32>
    if(ip->addrs[i]){
    80003468:	408c                	lw	a1,0(s1)
    8000346a:	dde5                	beqz	a1,80003462 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000346c:	0009a503          	lw	a0,0(s3)
    80003470:	a17ff0ef          	jal	80002e86 <bfree>
      ip->addrs[i] = 0;
    80003474:	0004a023          	sw	zero,0(s1)
    80003478:	b7ed                	j	80003462 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000347a:	0809a583          	lw	a1,128(s3)
    8000347e:	ed89                	bnez	a1,80003498 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003480:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003484:	854e                	mv	a0,s3
    80003486:	e21ff0ef          	jal	800032a6 <iupdate>
}
    8000348a:	70a2                	ld	ra,40(sp)
    8000348c:	7402                	ld	s0,32(sp)
    8000348e:	64e2                	ld	s1,24(sp)
    80003490:	6942                	ld	s2,16(sp)
    80003492:	69a2                	ld	s3,8(sp)
    80003494:	6145                	addi	sp,sp,48
    80003496:	8082                	ret
    80003498:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000349a:	0009a503          	lw	a0,0(s3)
    8000349e:	ff0ff0ef          	jal	80002c8e <bread>
    800034a2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800034a4:	05850493          	addi	s1,a0,88
    800034a8:	45850913          	addi	s2,a0,1112
    800034ac:	a021                	j	800034b4 <itrunc+0x6c>
    800034ae:	0491                	addi	s1,s1,4
    800034b0:	01248963          	beq	s1,s2,800034c2 <itrunc+0x7a>
      if(a[j])
    800034b4:	408c                	lw	a1,0(s1)
    800034b6:	dde5                	beqz	a1,800034ae <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034b8:	0009a503          	lw	a0,0(s3)
    800034bc:	9cbff0ef          	jal	80002e86 <bfree>
    800034c0:	b7fd                	j	800034ae <itrunc+0x66>
    brelse(bp);
    800034c2:	8552                	mv	a0,s4
    800034c4:	8d3ff0ef          	jal	80002d96 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034c8:	0809a583          	lw	a1,128(s3)
    800034cc:	0009a503          	lw	a0,0(s3)
    800034d0:	9b7ff0ef          	jal	80002e86 <bfree>
    ip->addrs[NDIRECT] = 0;
    800034d4:	0809a023          	sw	zero,128(s3)
    800034d8:	6a02                	ld	s4,0(sp)
    800034da:	b75d                	j	80003480 <itrunc+0x38>

00000000800034dc <iput>:
{
    800034dc:	1101                	addi	sp,sp,-32
    800034de:	ec06                	sd	ra,24(sp)
    800034e0:	e822                	sd	s0,16(sp)
    800034e2:	e426                	sd	s1,8(sp)
    800034e4:	1000                	addi	s0,sp,32
    800034e6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034e8:	0001d517          	auipc	a0,0x1d
    800034ec:	7d050513          	addi	a0,a0,2000 # 80020cb8 <itable>
    800034f0:	edefd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034f4:	4498                	lw	a4,8(s1)
    800034f6:	4785                	li	a5,1
    800034f8:	02f70063          	beq	a4,a5,80003518 <iput+0x3c>
  ip->ref--;
    800034fc:	449c                	lw	a5,8(s1)
    800034fe:	37fd                	addiw	a5,a5,-1
    80003500:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003502:	0001d517          	auipc	a0,0x1d
    80003506:	7b650513          	addi	a0,a0,1974 # 80020cb8 <itable>
    8000350a:	f5cfd0ef          	jal	80000c66 <release>
}
    8000350e:	60e2                	ld	ra,24(sp)
    80003510:	6442                	ld	s0,16(sp)
    80003512:	64a2                	ld	s1,8(sp)
    80003514:	6105                	addi	sp,sp,32
    80003516:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003518:	40bc                	lw	a5,64(s1)
    8000351a:	d3ed                	beqz	a5,800034fc <iput+0x20>
    8000351c:	04a49783          	lh	a5,74(s1)
    80003520:	fff1                	bnez	a5,800034fc <iput+0x20>
    80003522:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003524:	01048913          	addi	s2,s1,16
    80003528:	854a                	mv	a0,s2
    8000352a:	297000ef          	jal	80003fc0 <acquiresleep>
    release(&itable.lock);
    8000352e:	0001d517          	auipc	a0,0x1d
    80003532:	78a50513          	addi	a0,a0,1930 # 80020cb8 <itable>
    80003536:	f30fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    8000353a:	8526                	mv	a0,s1
    8000353c:	f0dff0ef          	jal	80003448 <itrunc>
    ip->type = 0;
    80003540:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003544:	8526                	mv	a0,s1
    80003546:	d61ff0ef          	jal	800032a6 <iupdate>
    ip->valid = 0;
    8000354a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000354e:	854a                	mv	a0,s2
    80003550:	2b7000ef          	jal	80004006 <releasesleep>
    acquire(&itable.lock);
    80003554:	0001d517          	auipc	a0,0x1d
    80003558:	76450513          	addi	a0,a0,1892 # 80020cb8 <itable>
    8000355c:	e72fd0ef          	jal	80000bce <acquire>
    80003560:	6902                	ld	s2,0(sp)
    80003562:	bf69                	j	800034fc <iput+0x20>

0000000080003564 <iunlockput>:
{
    80003564:	1101                	addi	sp,sp,-32
    80003566:	ec06                	sd	ra,24(sp)
    80003568:	e822                	sd	s0,16(sp)
    8000356a:	e426                	sd	s1,8(sp)
    8000356c:	1000                	addi	s0,sp,32
    8000356e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003570:	e99ff0ef          	jal	80003408 <iunlock>
  iput(ip);
    80003574:	8526                	mv	a0,s1
    80003576:	f67ff0ef          	jal	800034dc <iput>
}
    8000357a:	60e2                	ld	ra,24(sp)
    8000357c:	6442                	ld	s0,16(sp)
    8000357e:	64a2                	ld	s1,8(sp)
    80003580:	6105                	addi	sp,sp,32
    80003582:	8082                	ret

0000000080003584 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003584:	0001d717          	auipc	a4,0x1d
    80003588:	72072703          	lw	a4,1824(a4) # 80020ca4 <sb+0xc>
    8000358c:	4785                	li	a5,1
    8000358e:	0ae7ff63          	bgeu	a5,a4,8000364c <ireclaim+0xc8>
{
    80003592:	7139                	addi	sp,sp,-64
    80003594:	fc06                	sd	ra,56(sp)
    80003596:	f822                	sd	s0,48(sp)
    80003598:	f426                	sd	s1,40(sp)
    8000359a:	f04a                	sd	s2,32(sp)
    8000359c:	ec4e                	sd	s3,24(sp)
    8000359e:	e852                	sd	s4,16(sp)
    800035a0:	e456                	sd	s5,8(sp)
    800035a2:	e05a                	sd	s6,0(sp)
    800035a4:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035a6:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035a8:	00050a1b          	sext.w	s4,a0
    800035ac:	0001da97          	auipc	s5,0x1d
    800035b0:	6eca8a93          	addi	s5,s5,1772 # 80020c98 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800035b4:	00004b17          	auipc	s6,0x4
    800035b8:	ebcb0b13          	addi	s6,s6,-324 # 80007470 <etext+0x470>
    800035bc:	a099                	j	80003602 <ireclaim+0x7e>
    800035be:	85ce                	mv	a1,s3
    800035c0:	855a                	mv	a0,s6
    800035c2:	f39fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800035c6:	85ce                	mv	a1,s3
    800035c8:	8552                	mv	a0,s4
    800035ca:	b1dff0ef          	jal	800030e6 <iget>
    800035ce:	89aa                	mv	s3,a0
    brelse(bp);
    800035d0:	854a                	mv	a0,s2
    800035d2:	fc4ff0ef          	jal	80002d96 <brelse>
    if (ip) {
    800035d6:	00098f63          	beqz	s3,800035f4 <ireclaim+0x70>
      begin_op();
    800035da:	76a000ef          	jal	80003d44 <begin_op>
      ilock(ip);
    800035de:	854e                	mv	a0,s3
    800035e0:	d7bff0ef          	jal	8000335a <ilock>
      iunlock(ip);
    800035e4:	854e                	mv	a0,s3
    800035e6:	e23ff0ef          	jal	80003408 <iunlock>
      iput(ip);
    800035ea:	854e                	mv	a0,s3
    800035ec:	ef1ff0ef          	jal	800034dc <iput>
      end_op();
    800035f0:	7be000ef          	jal	80003dae <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035f4:	0485                	addi	s1,s1,1
    800035f6:	00caa703          	lw	a4,12(s5)
    800035fa:	0004879b          	sext.w	a5,s1
    800035fe:	02e7fd63          	bgeu	a5,a4,80003638 <ireclaim+0xb4>
    80003602:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003606:	0044d593          	srli	a1,s1,0x4
    8000360a:	018aa783          	lw	a5,24(s5)
    8000360e:	9dbd                	addw	a1,a1,a5
    80003610:	8552                	mv	a0,s4
    80003612:	e7cff0ef          	jal	80002c8e <bread>
    80003616:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003618:	05850793          	addi	a5,a0,88
    8000361c:	00f9f713          	andi	a4,s3,15
    80003620:	071a                	slli	a4,a4,0x6
    80003622:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003624:	00079703          	lh	a4,0(a5)
    80003628:	c701                	beqz	a4,80003630 <ireclaim+0xac>
    8000362a:	00679783          	lh	a5,6(a5)
    8000362e:	dbc1                	beqz	a5,800035be <ireclaim+0x3a>
    brelse(bp);
    80003630:	854a                	mv	a0,s2
    80003632:	f64ff0ef          	jal	80002d96 <brelse>
    if (ip) {
    80003636:	bf7d                	j	800035f4 <ireclaim+0x70>
}
    80003638:	70e2                	ld	ra,56(sp)
    8000363a:	7442                	ld	s0,48(sp)
    8000363c:	74a2                	ld	s1,40(sp)
    8000363e:	7902                	ld	s2,32(sp)
    80003640:	69e2                	ld	s3,24(sp)
    80003642:	6a42                	ld	s4,16(sp)
    80003644:	6aa2                	ld	s5,8(sp)
    80003646:	6b02                	ld	s6,0(sp)
    80003648:	6121                	addi	sp,sp,64
    8000364a:	8082                	ret
    8000364c:	8082                	ret

000000008000364e <fsinit>:
fsinit(int dev) {
    8000364e:	7179                	addi	sp,sp,-48
    80003650:	f406                	sd	ra,40(sp)
    80003652:	f022                	sd	s0,32(sp)
    80003654:	ec26                	sd	s1,24(sp)
    80003656:	e84a                	sd	s2,16(sp)
    80003658:	e44e                	sd	s3,8(sp)
    8000365a:	1800                	addi	s0,sp,48
    8000365c:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    8000365e:	4585                	li	a1,1
    80003660:	e2eff0ef          	jal	80002c8e <bread>
    80003664:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003666:	0001d997          	auipc	s3,0x1d
    8000366a:	63298993          	addi	s3,s3,1586 # 80020c98 <sb>
    8000366e:	02000613          	li	a2,32
    80003672:	05850593          	addi	a1,a0,88
    80003676:	854e                	mv	a0,s3
    80003678:	e86fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    8000367c:	854a                	mv	a0,s2
    8000367e:	f18ff0ef          	jal	80002d96 <brelse>
  if(sb.magic != FSMAGIC)
    80003682:	0009a703          	lw	a4,0(s3)
    80003686:	102037b7          	lui	a5,0x10203
    8000368a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000368e:	02f71363          	bne	a4,a5,800036b4 <fsinit+0x66>
  initlog(dev, &sb);
    80003692:	0001d597          	auipc	a1,0x1d
    80003696:	60658593          	addi	a1,a1,1542 # 80020c98 <sb>
    8000369a:	8526                	mv	a0,s1
    8000369c:	62a000ef          	jal	80003cc6 <initlog>
  ireclaim(dev);
    800036a0:	8526                	mv	a0,s1
    800036a2:	ee3ff0ef          	jal	80003584 <ireclaim>
}
    800036a6:	70a2                	ld	ra,40(sp)
    800036a8:	7402                	ld	s0,32(sp)
    800036aa:	64e2                	ld	s1,24(sp)
    800036ac:	6942                	ld	s2,16(sp)
    800036ae:	69a2                	ld	s3,8(sp)
    800036b0:	6145                	addi	sp,sp,48
    800036b2:	8082                	ret
    panic("invalid file system");
    800036b4:	00004517          	auipc	a0,0x4
    800036b8:	ddc50513          	addi	a0,a0,-548 # 80007490 <etext+0x490>
    800036bc:	924fd0ef          	jal	800007e0 <panic>

00000000800036c0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036c0:	1141                	addi	sp,sp,-16
    800036c2:	e422                	sd	s0,8(sp)
    800036c4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036c6:	411c                	lw	a5,0(a0)
    800036c8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036ca:	415c                	lw	a5,4(a0)
    800036cc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036ce:	04451783          	lh	a5,68(a0)
    800036d2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036d6:	04a51783          	lh	a5,74(a0)
    800036da:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036de:	04c56783          	lwu	a5,76(a0)
    800036e2:	e99c                	sd	a5,16(a1)
}
    800036e4:	6422                	ld	s0,8(sp)
    800036e6:	0141                	addi	sp,sp,16
    800036e8:	8082                	ret

00000000800036ea <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036ea:	457c                	lw	a5,76(a0)
    800036ec:	0ed7eb63          	bltu	a5,a3,800037e2 <readi+0xf8>
{
    800036f0:	7159                	addi	sp,sp,-112
    800036f2:	f486                	sd	ra,104(sp)
    800036f4:	f0a2                	sd	s0,96(sp)
    800036f6:	eca6                	sd	s1,88(sp)
    800036f8:	e0d2                	sd	s4,64(sp)
    800036fa:	fc56                	sd	s5,56(sp)
    800036fc:	f85a                	sd	s6,48(sp)
    800036fe:	f45e                	sd	s7,40(sp)
    80003700:	1880                	addi	s0,sp,112
    80003702:	8b2a                	mv	s6,a0
    80003704:	8bae                	mv	s7,a1
    80003706:	8a32                	mv	s4,a2
    80003708:	84b6                	mv	s1,a3
    8000370a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000370c:	9f35                	addw	a4,a4,a3
    return 0;
    8000370e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003710:	0cd76063          	bltu	a4,a3,800037d0 <readi+0xe6>
    80003714:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003716:	00e7f463          	bgeu	a5,a4,8000371e <readi+0x34>
    n = ip->size - off;
    8000371a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000371e:	080a8f63          	beqz	s5,800037bc <readi+0xd2>
    80003722:	e8ca                	sd	s2,80(sp)
    80003724:	f062                	sd	s8,32(sp)
    80003726:	ec66                	sd	s9,24(sp)
    80003728:	e86a                	sd	s10,16(sp)
    8000372a:	e46e                	sd	s11,8(sp)
    8000372c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000372e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003732:	5c7d                	li	s8,-1
    80003734:	a80d                	j	80003766 <readi+0x7c>
    80003736:	020d1d93          	slli	s11,s10,0x20
    8000373a:	020ddd93          	srli	s11,s11,0x20
    8000373e:	05890613          	addi	a2,s2,88
    80003742:	86ee                	mv	a3,s11
    80003744:	963a                	add	a2,a2,a4
    80003746:	85d2                	mv	a1,s4
    80003748:	855e                	mv	a0,s7
    8000374a:	bc5fe0ef          	jal	8000230e <either_copyout>
    8000374e:	05850763          	beq	a0,s8,8000379c <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003752:	854a                	mv	a0,s2
    80003754:	e42ff0ef          	jal	80002d96 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003758:	013d09bb          	addw	s3,s10,s3
    8000375c:	009d04bb          	addw	s1,s10,s1
    80003760:	9a6e                	add	s4,s4,s11
    80003762:	0559f763          	bgeu	s3,s5,800037b0 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003766:	00a4d59b          	srliw	a1,s1,0xa
    8000376a:	855a                	mv	a0,s6
    8000376c:	8a7ff0ef          	jal	80003012 <bmap>
    80003770:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003774:	c5b1                	beqz	a1,800037c0 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003776:	000b2503          	lw	a0,0(s6)
    8000377a:	d14ff0ef          	jal	80002c8e <bread>
    8000377e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003780:	3ff4f713          	andi	a4,s1,1023
    80003784:	40ec87bb          	subw	a5,s9,a4
    80003788:	413a86bb          	subw	a3,s5,s3
    8000378c:	8d3e                	mv	s10,a5
    8000378e:	2781                	sext.w	a5,a5
    80003790:	0006861b          	sext.w	a2,a3
    80003794:	faf671e3          	bgeu	a2,a5,80003736 <readi+0x4c>
    80003798:	8d36                	mv	s10,a3
    8000379a:	bf71                	j	80003736 <readi+0x4c>
      brelse(bp);
    8000379c:	854a                	mv	a0,s2
    8000379e:	df8ff0ef          	jal	80002d96 <brelse>
      tot = -1;
    800037a2:	59fd                	li	s3,-1
      break;
    800037a4:	6946                	ld	s2,80(sp)
    800037a6:	7c02                	ld	s8,32(sp)
    800037a8:	6ce2                	ld	s9,24(sp)
    800037aa:	6d42                	ld	s10,16(sp)
    800037ac:	6da2                	ld	s11,8(sp)
    800037ae:	a831                	j	800037ca <readi+0xe0>
    800037b0:	6946                	ld	s2,80(sp)
    800037b2:	7c02                	ld	s8,32(sp)
    800037b4:	6ce2                	ld	s9,24(sp)
    800037b6:	6d42                	ld	s10,16(sp)
    800037b8:	6da2                	ld	s11,8(sp)
    800037ba:	a801                	j	800037ca <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037bc:	89d6                	mv	s3,s5
    800037be:	a031                	j	800037ca <readi+0xe0>
    800037c0:	6946                	ld	s2,80(sp)
    800037c2:	7c02                	ld	s8,32(sp)
    800037c4:	6ce2                	ld	s9,24(sp)
    800037c6:	6d42                	ld	s10,16(sp)
    800037c8:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800037ca:	0009851b          	sext.w	a0,s3
    800037ce:	69a6                	ld	s3,72(sp)
}
    800037d0:	70a6                	ld	ra,104(sp)
    800037d2:	7406                	ld	s0,96(sp)
    800037d4:	64e6                	ld	s1,88(sp)
    800037d6:	6a06                	ld	s4,64(sp)
    800037d8:	7ae2                	ld	s5,56(sp)
    800037da:	7b42                	ld	s6,48(sp)
    800037dc:	7ba2                	ld	s7,40(sp)
    800037de:	6165                	addi	sp,sp,112
    800037e0:	8082                	ret
    return 0;
    800037e2:	4501                	li	a0,0
}
    800037e4:	8082                	ret

00000000800037e6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037e6:	457c                	lw	a5,76(a0)
    800037e8:	10d7e063          	bltu	a5,a3,800038e8 <writei+0x102>
{
    800037ec:	7159                	addi	sp,sp,-112
    800037ee:	f486                	sd	ra,104(sp)
    800037f0:	f0a2                	sd	s0,96(sp)
    800037f2:	e8ca                	sd	s2,80(sp)
    800037f4:	e0d2                	sd	s4,64(sp)
    800037f6:	fc56                	sd	s5,56(sp)
    800037f8:	f85a                	sd	s6,48(sp)
    800037fa:	f45e                	sd	s7,40(sp)
    800037fc:	1880                	addi	s0,sp,112
    800037fe:	8aaa                	mv	s5,a0
    80003800:	8bae                	mv	s7,a1
    80003802:	8a32                	mv	s4,a2
    80003804:	8936                	mv	s2,a3
    80003806:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003808:	00e687bb          	addw	a5,a3,a4
    8000380c:	0ed7e063          	bltu	a5,a3,800038ec <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003810:	00043737          	lui	a4,0x43
    80003814:	0cf76e63          	bltu	a4,a5,800038f0 <writei+0x10a>
    80003818:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000381a:	0a0b0f63          	beqz	s6,800038d8 <writei+0xf2>
    8000381e:	eca6                	sd	s1,88(sp)
    80003820:	f062                	sd	s8,32(sp)
    80003822:	ec66                	sd	s9,24(sp)
    80003824:	e86a                	sd	s10,16(sp)
    80003826:	e46e                	sd	s11,8(sp)
    80003828:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000382a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000382e:	5c7d                	li	s8,-1
    80003830:	a825                	j	80003868 <writei+0x82>
    80003832:	020d1d93          	slli	s11,s10,0x20
    80003836:	020ddd93          	srli	s11,s11,0x20
    8000383a:	05848513          	addi	a0,s1,88
    8000383e:	86ee                	mv	a3,s11
    80003840:	8652                	mv	a2,s4
    80003842:	85de                	mv	a1,s7
    80003844:	953a                	add	a0,a0,a4
    80003846:	b13fe0ef          	jal	80002358 <either_copyin>
    8000384a:	05850a63          	beq	a0,s8,8000389e <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000384e:	8526                	mv	a0,s1
    80003850:	678000ef          	jal	80003ec8 <log_write>
    brelse(bp);
    80003854:	8526                	mv	a0,s1
    80003856:	d40ff0ef          	jal	80002d96 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000385a:	013d09bb          	addw	s3,s10,s3
    8000385e:	012d093b          	addw	s2,s10,s2
    80003862:	9a6e                	add	s4,s4,s11
    80003864:	0569f063          	bgeu	s3,s6,800038a4 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003868:	00a9559b          	srliw	a1,s2,0xa
    8000386c:	8556                	mv	a0,s5
    8000386e:	fa4ff0ef          	jal	80003012 <bmap>
    80003872:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003876:	c59d                	beqz	a1,800038a4 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003878:	000aa503          	lw	a0,0(s5)
    8000387c:	c12ff0ef          	jal	80002c8e <bread>
    80003880:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003882:	3ff97713          	andi	a4,s2,1023
    80003886:	40ec87bb          	subw	a5,s9,a4
    8000388a:	413b06bb          	subw	a3,s6,s3
    8000388e:	8d3e                	mv	s10,a5
    80003890:	2781                	sext.w	a5,a5
    80003892:	0006861b          	sext.w	a2,a3
    80003896:	f8f67ee3          	bgeu	a2,a5,80003832 <writei+0x4c>
    8000389a:	8d36                	mv	s10,a3
    8000389c:	bf59                	j	80003832 <writei+0x4c>
      brelse(bp);
    8000389e:	8526                	mv	a0,s1
    800038a0:	cf6ff0ef          	jal	80002d96 <brelse>
  }

  if(off > ip->size)
    800038a4:	04caa783          	lw	a5,76(s5)
    800038a8:	0327fa63          	bgeu	a5,s2,800038dc <writei+0xf6>
    ip->size = off;
    800038ac:	052aa623          	sw	s2,76(s5)
    800038b0:	64e6                	ld	s1,88(sp)
    800038b2:	7c02                	ld	s8,32(sp)
    800038b4:	6ce2                	ld	s9,24(sp)
    800038b6:	6d42                	ld	s10,16(sp)
    800038b8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038ba:	8556                	mv	a0,s5
    800038bc:	9ebff0ef          	jal	800032a6 <iupdate>

  return tot;
    800038c0:	0009851b          	sext.w	a0,s3
    800038c4:	69a6                	ld	s3,72(sp)
}
    800038c6:	70a6                	ld	ra,104(sp)
    800038c8:	7406                	ld	s0,96(sp)
    800038ca:	6946                	ld	s2,80(sp)
    800038cc:	6a06                	ld	s4,64(sp)
    800038ce:	7ae2                	ld	s5,56(sp)
    800038d0:	7b42                	ld	s6,48(sp)
    800038d2:	7ba2                	ld	s7,40(sp)
    800038d4:	6165                	addi	sp,sp,112
    800038d6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038d8:	89da                	mv	s3,s6
    800038da:	b7c5                	j	800038ba <writei+0xd4>
    800038dc:	64e6                	ld	s1,88(sp)
    800038de:	7c02                	ld	s8,32(sp)
    800038e0:	6ce2                	ld	s9,24(sp)
    800038e2:	6d42                	ld	s10,16(sp)
    800038e4:	6da2                	ld	s11,8(sp)
    800038e6:	bfd1                	j	800038ba <writei+0xd4>
    return -1;
    800038e8:	557d                	li	a0,-1
}
    800038ea:	8082                	ret
    return -1;
    800038ec:	557d                	li	a0,-1
    800038ee:	bfe1                	j	800038c6 <writei+0xe0>
    return -1;
    800038f0:	557d                	li	a0,-1
    800038f2:	bfd1                	j	800038c6 <writei+0xe0>

00000000800038f4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038f4:	1141                	addi	sp,sp,-16
    800038f6:	e406                	sd	ra,8(sp)
    800038f8:	e022                	sd	s0,0(sp)
    800038fa:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038fc:	4639                	li	a2,14
    800038fe:	c70fd0ef          	jal	80000d6e <strncmp>
}
    80003902:	60a2                	ld	ra,8(sp)
    80003904:	6402                	ld	s0,0(sp)
    80003906:	0141                	addi	sp,sp,16
    80003908:	8082                	ret

000000008000390a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000390a:	7139                	addi	sp,sp,-64
    8000390c:	fc06                	sd	ra,56(sp)
    8000390e:	f822                	sd	s0,48(sp)
    80003910:	f426                	sd	s1,40(sp)
    80003912:	f04a                	sd	s2,32(sp)
    80003914:	ec4e                	sd	s3,24(sp)
    80003916:	e852                	sd	s4,16(sp)
    80003918:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000391a:	04451703          	lh	a4,68(a0)
    8000391e:	4785                	li	a5,1
    80003920:	00f71a63          	bne	a4,a5,80003934 <dirlookup+0x2a>
    80003924:	892a                	mv	s2,a0
    80003926:	89ae                	mv	s3,a1
    80003928:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000392a:	457c                	lw	a5,76(a0)
    8000392c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000392e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003930:	e39d                	bnez	a5,80003956 <dirlookup+0x4c>
    80003932:	a095                	j	80003996 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003934:	00004517          	auipc	a0,0x4
    80003938:	b7450513          	addi	a0,a0,-1164 # 800074a8 <etext+0x4a8>
    8000393c:	ea5fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003940:	00004517          	auipc	a0,0x4
    80003944:	b8050513          	addi	a0,a0,-1152 # 800074c0 <etext+0x4c0>
    80003948:	e99fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000394c:	24c1                	addiw	s1,s1,16
    8000394e:	04c92783          	lw	a5,76(s2)
    80003952:	04f4f163          	bgeu	s1,a5,80003994 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003956:	4741                	li	a4,16
    80003958:	86a6                	mv	a3,s1
    8000395a:	fc040613          	addi	a2,s0,-64
    8000395e:	4581                	li	a1,0
    80003960:	854a                	mv	a0,s2
    80003962:	d89ff0ef          	jal	800036ea <readi>
    80003966:	47c1                	li	a5,16
    80003968:	fcf51ce3          	bne	a0,a5,80003940 <dirlookup+0x36>
    if(de.inum == 0)
    8000396c:	fc045783          	lhu	a5,-64(s0)
    80003970:	dff1                	beqz	a5,8000394c <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003972:	fc240593          	addi	a1,s0,-62
    80003976:	854e                	mv	a0,s3
    80003978:	f7dff0ef          	jal	800038f4 <namecmp>
    8000397c:	f961                	bnez	a0,8000394c <dirlookup+0x42>
      if(poff)
    8000397e:	000a0463          	beqz	s4,80003986 <dirlookup+0x7c>
        *poff = off;
    80003982:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003986:	fc045583          	lhu	a1,-64(s0)
    8000398a:	00092503          	lw	a0,0(s2)
    8000398e:	f58ff0ef          	jal	800030e6 <iget>
    80003992:	a011                	j	80003996 <dirlookup+0x8c>
  return 0;
    80003994:	4501                	li	a0,0
}
    80003996:	70e2                	ld	ra,56(sp)
    80003998:	7442                	ld	s0,48(sp)
    8000399a:	74a2                	ld	s1,40(sp)
    8000399c:	7902                	ld	s2,32(sp)
    8000399e:	69e2                	ld	s3,24(sp)
    800039a0:	6a42                	ld	s4,16(sp)
    800039a2:	6121                	addi	sp,sp,64
    800039a4:	8082                	ret

00000000800039a6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800039a6:	711d                	addi	sp,sp,-96
    800039a8:	ec86                	sd	ra,88(sp)
    800039aa:	e8a2                	sd	s0,80(sp)
    800039ac:	e4a6                	sd	s1,72(sp)
    800039ae:	e0ca                	sd	s2,64(sp)
    800039b0:	fc4e                	sd	s3,56(sp)
    800039b2:	f852                	sd	s4,48(sp)
    800039b4:	f456                	sd	s5,40(sp)
    800039b6:	f05a                	sd	s6,32(sp)
    800039b8:	ec5e                	sd	s7,24(sp)
    800039ba:	e862                	sd	s8,16(sp)
    800039bc:	e466                	sd	s9,8(sp)
    800039be:	1080                	addi	s0,sp,96
    800039c0:	84aa                	mv	s1,a0
    800039c2:	8b2e                	mv	s6,a1
    800039c4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800039c6:	00054703          	lbu	a4,0(a0)
    800039ca:	02f00793          	li	a5,47
    800039ce:	00f70e63          	beq	a4,a5,800039ea <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039d2:	f11fd0ef          	jal	800018e2 <myproc>
    800039d6:	15053503          	ld	a0,336(a0)
    800039da:	94bff0ef          	jal	80003324 <idup>
    800039de:	8a2a                	mv	s4,a0
  while(*path == '/')
    800039e0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800039e4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800039e6:	4b85                	li	s7,1
    800039e8:	a871                	j	80003a84 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800039ea:	4585                	li	a1,1
    800039ec:	4505                	li	a0,1
    800039ee:	ef8ff0ef          	jal	800030e6 <iget>
    800039f2:	8a2a                	mv	s4,a0
    800039f4:	b7f5                	j	800039e0 <namex+0x3a>
      iunlockput(ip);
    800039f6:	8552                	mv	a0,s4
    800039f8:	b6dff0ef          	jal	80003564 <iunlockput>
      return 0;
    800039fc:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800039fe:	8552                	mv	a0,s4
    80003a00:	60e6                	ld	ra,88(sp)
    80003a02:	6446                	ld	s0,80(sp)
    80003a04:	64a6                	ld	s1,72(sp)
    80003a06:	6906                	ld	s2,64(sp)
    80003a08:	79e2                	ld	s3,56(sp)
    80003a0a:	7a42                	ld	s4,48(sp)
    80003a0c:	7aa2                	ld	s5,40(sp)
    80003a0e:	7b02                	ld	s6,32(sp)
    80003a10:	6be2                	ld	s7,24(sp)
    80003a12:	6c42                	ld	s8,16(sp)
    80003a14:	6ca2                	ld	s9,8(sp)
    80003a16:	6125                	addi	sp,sp,96
    80003a18:	8082                	ret
      iunlock(ip);
    80003a1a:	8552                	mv	a0,s4
    80003a1c:	9edff0ef          	jal	80003408 <iunlock>
      return ip;
    80003a20:	bff9                	j	800039fe <namex+0x58>
      iunlockput(ip);
    80003a22:	8552                	mv	a0,s4
    80003a24:	b41ff0ef          	jal	80003564 <iunlockput>
      return 0;
    80003a28:	8a4e                	mv	s4,s3
    80003a2a:	bfd1                	j	800039fe <namex+0x58>
  len = path - s;
    80003a2c:	40998633          	sub	a2,s3,s1
    80003a30:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003a34:	099c5063          	bge	s8,s9,80003ab4 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003a38:	4639                	li	a2,14
    80003a3a:	85a6                	mv	a1,s1
    80003a3c:	8556                	mv	a0,s5
    80003a3e:	ac0fd0ef          	jal	80000cfe <memmove>
    80003a42:	84ce                	mv	s1,s3
  while(*path == '/')
    80003a44:	0004c783          	lbu	a5,0(s1)
    80003a48:	01279763          	bne	a5,s2,80003a56 <namex+0xb0>
    path++;
    80003a4c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a4e:	0004c783          	lbu	a5,0(s1)
    80003a52:	ff278de3          	beq	a5,s2,80003a4c <namex+0xa6>
    ilock(ip);
    80003a56:	8552                	mv	a0,s4
    80003a58:	903ff0ef          	jal	8000335a <ilock>
    if(ip->type != T_DIR){
    80003a5c:	044a1783          	lh	a5,68(s4)
    80003a60:	f9779be3          	bne	a5,s7,800039f6 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003a64:	000b0563          	beqz	s6,80003a6e <namex+0xc8>
    80003a68:	0004c783          	lbu	a5,0(s1)
    80003a6c:	d7dd                	beqz	a5,80003a1a <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a6e:	4601                	li	a2,0
    80003a70:	85d6                	mv	a1,s5
    80003a72:	8552                	mv	a0,s4
    80003a74:	e97ff0ef          	jal	8000390a <dirlookup>
    80003a78:	89aa                	mv	s3,a0
    80003a7a:	d545                	beqz	a0,80003a22 <namex+0x7c>
    iunlockput(ip);
    80003a7c:	8552                	mv	a0,s4
    80003a7e:	ae7ff0ef          	jal	80003564 <iunlockput>
    ip = next;
    80003a82:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003a84:	0004c783          	lbu	a5,0(s1)
    80003a88:	01279763          	bne	a5,s2,80003a96 <namex+0xf0>
    path++;
    80003a8c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a8e:	0004c783          	lbu	a5,0(s1)
    80003a92:	ff278de3          	beq	a5,s2,80003a8c <namex+0xe6>
  if(*path == 0)
    80003a96:	cb8d                	beqz	a5,80003ac8 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003a98:	0004c783          	lbu	a5,0(s1)
    80003a9c:	89a6                	mv	s3,s1
  len = path - s;
    80003a9e:	4c81                	li	s9,0
    80003aa0:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003aa2:	01278963          	beq	a5,s2,80003ab4 <namex+0x10e>
    80003aa6:	d3d9                	beqz	a5,80003a2c <namex+0x86>
    path++;
    80003aa8:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003aaa:	0009c783          	lbu	a5,0(s3)
    80003aae:	ff279ce3          	bne	a5,s2,80003aa6 <namex+0x100>
    80003ab2:	bfad                	j	80003a2c <namex+0x86>
    memmove(name, s, len);
    80003ab4:	2601                	sext.w	a2,a2
    80003ab6:	85a6                	mv	a1,s1
    80003ab8:	8556                	mv	a0,s5
    80003aba:	a44fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003abe:	9cd6                	add	s9,s9,s5
    80003ac0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ac4:	84ce                	mv	s1,s3
    80003ac6:	bfbd                	j	80003a44 <namex+0x9e>
  if(nameiparent){
    80003ac8:	f20b0be3          	beqz	s6,800039fe <namex+0x58>
    iput(ip);
    80003acc:	8552                	mv	a0,s4
    80003ace:	a0fff0ef          	jal	800034dc <iput>
    return 0;
    80003ad2:	4a01                	li	s4,0
    80003ad4:	b72d                	j	800039fe <namex+0x58>

0000000080003ad6 <dirlink>:
{
    80003ad6:	7139                	addi	sp,sp,-64
    80003ad8:	fc06                	sd	ra,56(sp)
    80003ada:	f822                	sd	s0,48(sp)
    80003adc:	f04a                	sd	s2,32(sp)
    80003ade:	ec4e                	sd	s3,24(sp)
    80003ae0:	e852                	sd	s4,16(sp)
    80003ae2:	0080                	addi	s0,sp,64
    80003ae4:	892a                	mv	s2,a0
    80003ae6:	8a2e                	mv	s4,a1
    80003ae8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003aea:	4601                	li	a2,0
    80003aec:	e1fff0ef          	jal	8000390a <dirlookup>
    80003af0:	e535                	bnez	a0,80003b5c <dirlink+0x86>
    80003af2:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003af4:	04c92483          	lw	s1,76(s2)
    80003af8:	c48d                	beqz	s1,80003b22 <dirlink+0x4c>
    80003afa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003afc:	4741                	li	a4,16
    80003afe:	86a6                	mv	a3,s1
    80003b00:	fc040613          	addi	a2,s0,-64
    80003b04:	4581                	li	a1,0
    80003b06:	854a                	mv	a0,s2
    80003b08:	be3ff0ef          	jal	800036ea <readi>
    80003b0c:	47c1                	li	a5,16
    80003b0e:	04f51b63          	bne	a0,a5,80003b64 <dirlink+0x8e>
    if(de.inum == 0)
    80003b12:	fc045783          	lhu	a5,-64(s0)
    80003b16:	c791                	beqz	a5,80003b22 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b18:	24c1                	addiw	s1,s1,16
    80003b1a:	04c92783          	lw	a5,76(s2)
    80003b1e:	fcf4efe3          	bltu	s1,a5,80003afc <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b22:	4639                	li	a2,14
    80003b24:	85d2                	mv	a1,s4
    80003b26:	fc240513          	addi	a0,s0,-62
    80003b2a:	a7afd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003b2e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b32:	4741                	li	a4,16
    80003b34:	86a6                	mv	a3,s1
    80003b36:	fc040613          	addi	a2,s0,-64
    80003b3a:	4581                	li	a1,0
    80003b3c:	854a                	mv	a0,s2
    80003b3e:	ca9ff0ef          	jal	800037e6 <writei>
    80003b42:	1541                	addi	a0,a0,-16
    80003b44:	00a03533          	snez	a0,a0
    80003b48:	40a00533          	neg	a0,a0
    80003b4c:	74a2                	ld	s1,40(sp)
}
    80003b4e:	70e2                	ld	ra,56(sp)
    80003b50:	7442                	ld	s0,48(sp)
    80003b52:	7902                	ld	s2,32(sp)
    80003b54:	69e2                	ld	s3,24(sp)
    80003b56:	6a42                	ld	s4,16(sp)
    80003b58:	6121                	addi	sp,sp,64
    80003b5a:	8082                	ret
    iput(ip);
    80003b5c:	981ff0ef          	jal	800034dc <iput>
    return -1;
    80003b60:	557d                	li	a0,-1
    80003b62:	b7f5                	j	80003b4e <dirlink+0x78>
      panic("dirlink read");
    80003b64:	00004517          	auipc	a0,0x4
    80003b68:	96c50513          	addi	a0,a0,-1684 # 800074d0 <etext+0x4d0>
    80003b6c:	c75fc0ef          	jal	800007e0 <panic>

0000000080003b70 <namei>:

struct inode*
namei(char *path)
{
    80003b70:	1101                	addi	sp,sp,-32
    80003b72:	ec06                	sd	ra,24(sp)
    80003b74:	e822                	sd	s0,16(sp)
    80003b76:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b78:	fe040613          	addi	a2,s0,-32
    80003b7c:	4581                	li	a1,0
    80003b7e:	e29ff0ef          	jal	800039a6 <namex>
}
    80003b82:	60e2                	ld	ra,24(sp)
    80003b84:	6442                	ld	s0,16(sp)
    80003b86:	6105                	addi	sp,sp,32
    80003b88:	8082                	ret

0000000080003b8a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b8a:	1141                	addi	sp,sp,-16
    80003b8c:	e406                	sd	ra,8(sp)
    80003b8e:	e022                	sd	s0,0(sp)
    80003b90:	0800                	addi	s0,sp,16
    80003b92:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b94:	4585                	li	a1,1
    80003b96:	e11ff0ef          	jal	800039a6 <namex>
}
    80003b9a:	60a2                	ld	ra,8(sp)
    80003b9c:	6402                	ld	s0,0(sp)
    80003b9e:	0141                	addi	sp,sp,16
    80003ba0:	8082                	ret

0000000080003ba2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ba2:	1101                	addi	sp,sp,-32
    80003ba4:	ec06                	sd	ra,24(sp)
    80003ba6:	e822                	sd	s0,16(sp)
    80003ba8:	e426                	sd	s1,8(sp)
    80003baa:	e04a                	sd	s2,0(sp)
    80003bac:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003bae:	0001f917          	auipc	s2,0x1f
    80003bb2:	bb290913          	addi	s2,s2,-1102 # 80022760 <log>
    80003bb6:	01892583          	lw	a1,24(s2)
    80003bba:	02492503          	lw	a0,36(s2)
    80003bbe:	8d0ff0ef          	jal	80002c8e <bread>
    80003bc2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003bc4:	02892603          	lw	a2,40(s2)
    80003bc8:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003bca:	00c05f63          	blez	a2,80003be8 <write_head+0x46>
    80003bce:	0001f717          	auipc	a4,0x1f
    80003bd2:	bbe70713          	addi	a4,a4,-1090 # 8002278c <log+0x2c>
    80003bd6:	87aa                	mv	a5,a0
    80003bd8:	060a                	slli	a2,a2,0x2
    80003bda:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003bdc:	4314                	lw	a3,0(a4)
    80003bde:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003be0:	0711                	addi	a4,a4,4
    80003be2:	0791                	addi	a5,a5,4
    80003be4:	fec79ce3          	bne	a5,a2,80003bdc <write_head+0x3a>
  }
  bwrite(buf);
    80003be8:	8526                	mv	a0,s1
    80003bea:	97aff0ef          	jal	80002d64 <bwrite>
  brelse(buf);
    80003bee:	8526                	mv	a0,s1
    80003bf0:	9a6ff0ef          	jal	80002d96 <brelse>
}
    80003bf4:	60e2                	ld	ra,24(sp)
    80003bf6:	6442                	ld	s0,16(sp)
    80003bf8:	64a2                	ld	s1,8(sp)
    80003bfa:	6902                	ld	s2,0(sp)
    80003bfc:	6105                	addi	sp,sp,32
    80003bfe:	8082                	ret

0000000080003c00 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c00:	0001f797          	auipc	a5,0x1f
    80003c04:	b887a783          	lw	a5,-1144(a5) # 80022788 <log+0x28>
    80003c08:	0af05e63          	blez	a5,80003cc4 <install_trans+0xc4>
{
    80003c0c:	715d                	addi	sp,sp,-80
    80003c0e:	e486                	sd	ra,72(sp)
    80003c10:	e0a2                	sd	s0,64(sp)
    80003c12:	fc26                	sd	s1,56(sp)
    80003c14:	f84a                	sd	s2,48(sp)
    80003c16:	f44e                	sd	s3,40(sp)
    80003c18:	f052                	sd	s4,32(sp)
    80003c1a:	ec56                	sd	s5,24(sp)
    80003c1c:	e85a                	sd	s6,16(sp)
    80003c1e:	e45e                	sd	s7,8(sp)
    80003c20:	0880                	addi	s0,sp,80
    80003c22:	8b2a                	mv	s6,a0
    80003c24:	0001fa97          	auipc	s5,0x1f
    80003c28:	b68a8a93          	addi	s5,s5,-1176 # 8002278c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c2c:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c2e:	00004b97          	auipc	s7,0x4
    80003c32:	8b2b8b93          	addi	s7,s7,-1870 # 800074e0 <etext+0x4e0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c36:	0001fa17          	auipc	s4,0x1f
    80003c3a:	b2aa0a13          	addi	s4,s4,-1238 # 80022760 <log>
    80003c3e:	a025                	j	80003c66 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c40:	000aa603          	lw	a2,0(s5)
    80003c44:	85ce                	mv	a1,s3
    80003c46:	855e                	mv	a0,s7
    80003c48:	8b3fc0ef          	jal	800004fa <printf>
    80003c4c:	a839                	j	80003c6a <install_trans+0x6a>
    brelse(lbuf);
    80003c4e:	854a                	mv	a0,s2
    80003c50:	946ff0ef          	jal	80002d96 <brelse>
    brelse(dbuf);
    80003c54:	8526                	mv	a0,s1
    80003c56:	940ff0ef          	jal	80002d96 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c5a:	2985                	addiw	s3,s3,1
    80003c5c:	0a91                	addi	s5,s5,4
    80003c5e:	028a2783          	lw	a5,40(s4)
    80003c62:	04f9d663          	bge	s3,a5,80003cae <install_trans+0xae>
    if(recovering) {
    80003c66:	fc0b1de3          	bnez	s6,80003c40 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c6a:	018a2583          	lw	a1,24(s4)
    80003c6e:	013585bb          	addw	a1,a1,s3
    80003c72:	2585                	addiw	a1,a1,1
    80003c74:	024a2503          	lw	a0,36(s4)
    80003c78:	816ff0ef          	jal	80002c8e <bread>
    80003c7c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c7e:	000aa583          	lw	a1,0(s5)
    80003c82:	024a2503          	lw	a0,36(s4)
    80003c86:	808ff0ef          	jal	80002c8e <bread>
    80003c8a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c8c:	40000613          	li	a2,1024
    80003c90:	05890593          	addi	a1,s2,88
    80003c94:	05850513          	addi	a0,a0,88
    80003c98:	866fd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c9c:	8526                	mv	a0,s1
    80003c9e:	8c6ff0ef          	jal	80002d64 <bwrite>
    if(recovering == 0)
    80003ca2:	fa0b16e3          	bnez	s6,80003c4e <install_trans+0x4e>
      bunpin(dbuf);
    80003ca6:	8526                	mv	a0,s1
    80003ca8:	9aaff0ef          	jal	80002e52 <bunpin>
    80003cac:	b74d                	j	80003c4e <install_trans+0x4e>
}
    80003cae:	60a6                	ld	ra,72(sp)
    80003cb0:	6406                	ld	s0,64(sp)
    80003cb2:	74e2                	ld	s1,56(sp)
    80003cb4:	7942                	ld	s2,48(sp)
    80003cb6:	79a2                	ld	s3,40(sp)
    80003cb8:	7a02                	ld	s4,32(sp)
    80003cba:	6ae2                	ld	s5,24(sp)
    80003cbc:	6b42                	ld	s6,16(sp)
    80003cbe:	6ba2                	ld	s7,8(sp)
    80003cc0:	6161                	addi	sp,sp,80
    80003cc2:	8082                	ret
    80003cc4:	8082                	ret

0000000080003cc6 <initlog>:
{
    80003cc6:	7179                	addi	sp,sp,-48
    80003cc8:	f406                	sd	ra,40(sp)
    80003cca:	f022                	sd	s0,32(sp)
    80003ccc:	ec26                	sd	s1,24(sp)
    80003cce:	e84a                	sd	s2,16(sp)
    80003cd0:	e44e                	sd	s3,8(sp)
    80003cd2:	1800                	addi	s0,sp,48
    80003cd4:	892a                	mv	s2,a0
    80003cd6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003cd8:	0001f497          	auipc	s1,0x1f
    80003cdc:	a8848493          	addi	s1,s1,-1400 # 80022760 <log>
    80003ce0:	00004597          	auipc	a1,0x4
    80003ce4:	82058593          	addi	a1,a1,-2016 # 80007500 <etext+0x500>
    80003ce8:	8526                	mv	a0,s1
    80003cea:	e65fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003cee:	0149a583          	lw	a1,20(s3)
    80003cf2:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003cf4:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003cf8:	854a                	mv	a0,s2
    80003cfa:	f95fe0ef          	jal	80002c8e <bread>
  log.lh.n = lh->n;
    80003cfe:	4d30                	lw	a2,88(a0)
    80003d00:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d02:	00c05f63          	blez	a2,80003d20 <initlog+0x5a>
    80003d06:	87aa                	mv	a5,a0
    80003d08:	0001f717          	auipc	a4,0x1f
    80003d0c:	a8470713          	addi	a4,a4,-1404 # 8002278c <log+0x2c>
    80003d10:	060a                	slli	a2,a2,0x2
    80003d12:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d14:	4ff4                	lw	a3,92(a5)
    80003d16:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d18:	0791                	addi	a5,a5,4
    80003d1a:	0711                	addi	a4,a4,4
    80003d1c:	fec79ce3          	bne	a5,a2,80003d14 <initlog+0x4e>
  brelse(buf);
    80003d20:	876ff0ef          	jal	80002d96 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d24:	4505                	li	a0,1
    80003d26:	edbff0ef          	jal	80003c00 <install_trans>
  log.lh.n = 0;
    80003d2a:	0001f797          	auipc	a5,0x1f
    80003d2e:	a407af23          	sw	zero,-1442(a5) # 80022788 <log+0x28>
  write_head(); // clear the log
    80003d32:	e71ff0ef          	jal	80003ba2 <write_head>
}
    80003d36:	70a2                	ld	ra,40(sp)
    80003d38:	7402                	ld	s0,32(sp)
    80003d3a:	64e2                	ld	s1,24(sp)
    80003d3c:	6942                	ld	s2,16(sp)
    80003d3e:	69a2                	ld	s3,8(sp)
    80003d40:	6145                	addi	sp,sp,48
    80003d42:	8082                	ret

0000000080003d44 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d44:	1101                	addi	sp,sp,-32
    80003d46:	ec06                	sd	ra,24(sp)
    80003d48:	e822                	sd	s0,16(sp)
    80003d4a:	e426                	sd	s1,8(sp)
    80003d4c:	e04a                	sd	s2,0(sp)
    80003d4e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d50:	0001f517          	auipc	a0,0x1f
    80003d54:	a1050513          	addi	a0,a0,-1520 # 80022760 <log>
    80003d58:	e77fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003d5c:	0001f497          	auipc	s1,0x1f
    80003d60:	a0448493          	addi	s1,s1,-1532 # 80022760 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d64:	4979                	li	s2,30
    80003d66:	a029                	j	80003d70 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d68:	85a6                	mv	a1,s1
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	a46fe0ef          	jal	80001fb2 <sleep>
    if(log.committing){
    80003d70:	509c                	lw	a5,32(s1)
    80003d72:	fbfd                	bnez	a5,80003d68 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d74:	4cd8                	lw	a4,28(s1)
    80003d76:	2705                	addiw	a4,a4,1
    80003d78:	0027179b          	slliw	a5,a4,0x2
    80003d7c:	9fb9                	addw	a5,a5,a4
    80003d7e:	0017979b          	slliw	a5,a5,0x1
    80003d82:	5494                	lw	a3,40(s1)
    80003d84:	9fb5                	addw	a5,a5,a3
    80003d86:	00f95763          	bge	s2,a5,80003d94 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d8a:	85a6                	mv	a1,s1
    80003d8c:	8526                	mv	a0,s1
    80003d8e:	a24fe0ef          	jal	80001fb2 <sleep>
    80003d92:	bff9                	j	80003d70 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d94:	0001f517          	auipc	a0,0x1f
    80003d98:	9cc50513          	addi	a0,a0,-1588 # 80022760 <log>
    80003d9c:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003d9e:	ec9fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003da2:	60e2                	ld	ra,24(sp)
    80003da4:	6442                	ld	s0,16(sp)
    80003da6:	64a2                	ld	s1,8(sp)
    80003da8:	6902                	ld	s2,0(sp)
    80003daa:	6105                	addi	sp,sp,32
    80003dac:	8082                	ret

0000000080003dae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003dae:	7139                	addi	sp,sp,-64
    80003db0:	fc06                	sd	ra,56(sp)
    80003db2:	f822                	sd	s0,48(sp)
    80003db4:	f426                	sd	s1,40(sp)
    80003db6:	f04a                	sd	s2,32(sp)
    80003db8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003dba:	0001f497          	auipc	s1,0x1f
    80003dbe:	9a648493          	addi	s1,s1,-1626 # 80022760 <log>
    80003dc2:	8526                	mv	a0,s1
    80003dc4:	e0bfc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003dc8:	4cdc                	lw	a5,28(s1)
    80003dca:	37fd                	addiw	a5,a5,-1
    80003dcc:	0007891b          	sext.w	s2,a5
    80003dd0:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003dd2:	509c                	lw	a5,32(s1)
    80003dd4:	ef9d                	bnez	a5,80003e12 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003dd6:	04091763          	bnez	s2,80003e24 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003dda:	0001f497          	auipc	s1,0x1f
    80003dde:	98648493          	addi	s1,s1,-1658 # 80022760 <log>
    80003de2:	4785                	li	a5,1
    80003de4:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003de6:	8526                	mv	a0,s1
    80003de8:	e7ffc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003dec:	549c                	lw	a5,40(s1)
    80003dee:	04f04b63          	bgtz	a5,80003e44 <end_op+0x96>
    acquire(&log.lock);
    80003df2:	0001f497          	auipc	s1,0x1f
    80003df6:	96e48493          	addi	s1,s1,-1682 # 80022760 <log>
    80003dfa:	8526                	mv	a0,s1
    80003dfc:	dd3fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003e00:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e04:	8526                	mv	a0,s1
    80003e06:	9f8fe0ef          	jal	80001ffe <wakeup>
    release(&log.lock);
    80003e0a:	8526                	mv	a0,s1
    80003e0c:	e5bfc0ef          	jal	80000c66 <release>
}
    80003e10:	a025                	j	80003e38 <end_op+0x8a>
    80003e12:	ec4e                	sd	s3,24(sp)
    80003e14:	e852                	sd	s4,16(sp)
    80003e16:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e18:	00003517          	auipc	a0,0x3
    80003e1c:	6f050513          	addi	a0,a0,1776 # 80007508 <etext+0x508>
    80003e20:	9c1fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003e24:	0001f497          	auipc	s1,0x1f
    80003e28:	93c48493          	addi	s1,s1,-1732 # 80022760 <log>
    80003e2c:	8526                	mv	a0,s1
    80003e2e:	9d0fe0ef          	jal	80001ffe <wakeup>
  release(&log.lock);
    80003e32:	8526                	mv	a0,s1
    80003e34:	e33fc0ef          	jal	80000c66 <release>
}
    80003e38:	70e2                	ld	ra,56(sp)
    80003e3a:	7442                	ld	s0,48(sp)
    80003e3c:	74a2                	ld	s1,40(sp)
    80003e3e:	7902                	ld	s2,32(sp)
    80003e40:	6121                	addi	sp,sp,64
    80003e42:	8082                	ret
    80003e44:	ec4e                	sd	s3,24(sp)
    80003e46:	e852                	sd	s4,16(sp)
    80003e48:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e4a:	0001fa97          	auipc	s5,0x1f
    80003e4e:	942a8a93          	addi	s5,s5,-1726 # 8002278c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e52:	0001fa17          	auipc	s4,0x1f
    80003e56:	90ea0a13          	addi	s4,s4,-1778 # 80022760 <log>
    80003e5a:	018a2583          	lw	a1,24(s4)
    80003e5e:	012585bb          	addw	a1,a1,s2
    80003e62:	2585                	addiw	a1,a1,1
    80003e64:	024a2503          	lw	a0,36(s4)
    80003e68:	e27fe0ef          	jal	80002c8e <bread>
    80003e6c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e6e:	000aa583          	lw	a1,0(s5)
    80003e72:	024a2503          	lw	a0,36(s4)
    80003e76:	e19fe0ef          	jal	80002c8e <bread>
    80003e7a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e7c:	40000613          	li	a2,1024
    80003e80:	05850593          	addi	a1,a0,88
    80003e84:	05848513          	addi	a0,s1,88
    80003e88:	e77fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003e8c:	8526                	mv	a0,s1
    80003e8e:	ed7fe0ef          	jal	80002d64 <bwrite>
    brelse(from);
    80003e92:	854e                	mv	a0,s3
    80003e94:	f03fe0ef          	jal	80002d96 <brelse>
    brelse(to);
    80003e98:	8526                	mv	a0,s1
    80003e9a:	efdfe0ef          	jal	80002d96 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e9e:	2905                	addiw	s2,s2,1
    80003ea0:	0a91                	addi	s5,s5,4
    80003ea2:	028a2783          	lw	a5,40(s4)
    80003ea6:	faf94ae3          	blt	s2,a5,80003e5a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003eaa:	cf9ff0ef          	jal	80003ba2 <write_head>
    install_trans(0); // Now install writes to home locations
    80003eae:	4501                	li	a0,0
    80003eb0:	d51ff0ef          	jal	80003c00 <install_trans>
    log.lh.n = 0;
    80003eb4:	0001f797          	auipc	a5,0x1f
    80003eb8:	8c07aa23          	sw	zero,-1836(a5) # 80022788 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003ebc:	ce7ff0ef          	jal	80003ba2 <write_head>
    80003ec0:	69e2                	ld	s3,24(sp)
    80003ec2:	6a42                	ld	s4,16(sp)
    80003ec4:	6aa2                	ld	s5,8(sp)
    80003ec6:	b735                	j	80003df2 <end_op+0x44>

0000000080003ec8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003ec8:	1101                	addi	sp,sp,-32
    80003eca:	ec06                	sd	ra,24(sp)
    80003ecc:	e822                	sd	s0,16(sp)
    80003ece:	e426                	sd	s1,8(sp)
    80003ed0:	e04a                	sd	s2,0(sp)
    80003ed2:	1000                	addi	s0,sp,32
    80003ed4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003ed6:	0001f917          	auipc	s2,0x1f
    80003eda:	88a90913          	addi	s2,s2,-1910 # 80022760 <log>
    80003ede:	854a                	mv	a0,s2
    80003ee0:	ceffc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003ee4:	02892603          	lw	a2,40(s2)
    80003ee8:	47f5                	li	a5,29
    80003eea:	04c7cc63          	blt	a5,a2,80003f42 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003eee:	0001f797          	auipc	a5,0x1f
    80003ef2:	88e7a783          	lw	a5,-1906(a5) # 8002277c <log+0x1c>
    80003ef6:	04f05c63          	blez	a5,80003f4e <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003efa:	4781                	li	a5,0
    80003efc:	04c05f63          	blez	a2,80003f5a <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f00:	44cc                	lw	a1,12(s1)
    80003f02:	0001f717          	auipc	a4,0x1f
    80003f06:	88a70713          	addi	a4,a4,-1910 # 8002278c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f0a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f0c:	4314                	lw	a3,0(a4)
    80003f0e:	04b68663          	beq	a3,a1,80003f5a <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f12:	2785                	addiw	a5,a5,1
    80003f14:	0711                	addi	a4,a4,4
    80003f16:	fef61be3          	bne	a2,a5,80003f0c <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f1a:	0621                	addi	a2,a2,8
    80003f1c:	060a                	slli	a2,a2,0x2
    80003f1e:	0001f797          	auipc	a5,0x1f
    80003f22:	84278793          	addi	a5,a5,-1982 # 80022760 <log>
    80003f26:	97b2                	add	a5,a5,a2
    80003f28:	44d8                	lw	a4,12(s1)
    80003f2a:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	ef1fe0ef          	jal	80002e1e <bpin>
    log.lh.n++;
    80003f32:	0001f717          	auipc	a4,0x1f
    80003f36:	82e70713          	addi	a4,a4,-2002 # 80022760 <log>
    80003f3a:	571c                	lw	a5,40(a4)
    80003f3c:	2785                	addiw	a5,a5,1
    80003f3e:	d71c                	sw	a5,40(a4)
    80003f40:	a80d                	j	80003f72 <log_write+0xaa>
    panic("too big a transaction");
    80003f42:	00003517          	auipc	a0,0x3
    80003f46:	5d650513          	addi	a0,a0,1494 # 80007518 <etext+0x518>
    80003f4a:	897fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003f4e:	00003517          	auipc	a0,0x3
    80003f52:	5e250513          	addi	a0,a0,1506 # 80007530 <etext+0x530>
    80003f56:	88bfc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003f5a:	00878693          	addi	a3,a5,8
    80003f5e:	068a                	slli	a3,a3,0x2
    80003f60:	0001f717          	auipc	a4,0x1f
    80003f64:	80070713          	addi	a4,a4,-2048 # 80022760 <log>
    80003f68:	9736                	add	a4,a4,a3
    80003f6a:	44d4                	lw	a3,12(s1)
    80003f6c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f6e:	faf60fe3          	beq	a2,a5,80003f2c <log_write+0x64>
  }
  release(&log.lock);
    80003f72:	0001e517          	auipc	a0,0x1e
    80003f76:	7ee50513          	addi	a0,a0,2030 # 80022760 <log>
    80003f7a:	cedfc0ef          	jal	80000c66 <release>
}
    80003f7e:	60e2                	ld	ra,24(sp)
    80003f80:	6442                	ld	s0,16(sp)
    80003f82:	64a2                	ld	s1,8(sp)
    80003f84:	6902                	ld	s2,0(sp)
    80003f86:	6105                	addi	sp,sp,32
    80003f88:	8082                	ret

0000000080003f8a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f8a:	1101                	addi	sp,sp,-32
    80003f8c:	ec06                	sd	ra,24(sp)
    80003f8e:	e822                	sd	s0,16(sp)
    80003f90:	e426                	sd	s1,8(sp)
    80003f92:	e04a                	sd	s2,0(sp)
    80003f94:	1000                	addi	s0,sp,32
    80003f96:	84aa                	mv	s1,a0
    80003f98:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f9a:	00003597          	auipc	a1,0x3
    80003f9e:	5b658593          	addi	a1,a1,1462 # 80007550 <etext+0x550>
    80003fa2:	0521                	addi	a0,a0,8
    80003fa4:	babfc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003fa8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003fac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fb0:	0204a423          	sw	zero,40(s1)
}
    80003fb4:	60e2                	ld	ra,24(sp)
    80003fb6:	6442                	ld	s0,16(sp)
    80003fb8:	64a2                	ld	s1,8(sp)
    80003fba:	6902                	ld	s2,0(sp)
    80003fbc:	6105                	addi	sp,sp,32
    80003fbe:	8082                	ret

0000000080003fc0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003fc0:	1101                	addi	sp,sp,-32
    80003fc2:	ec06                	sd	ra,24(sp)
    80003fc4:	e822                	sd	s0,16(sp)
    80003fc6:	e426                	sd	s1,8(sp)
    80003fc8:	e04a                	sd	s2,0(sp)
    80003fca:	1000                	addi	s0,sp,32
    80003fcc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fce:	00850913          	addi	s2,a0,8
    80003fd2:	854a                	mv	a0,s2
    80003fd4:	bfbfc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003fd8:	409c                	lw	a5,0(s1)
    80003fda:	c799                	beqz	a5,80003fe8 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003fdc:	85ca                	mv	a1,s2
    80003fde:	8526                	mv	a0,s1
    80003fe0:	fd3fd0ef          	jal	80001fb2 <sleep>
  while (lk->locked) {
    80003fe4:	409c                	lw	a5,0(s1)
    80003fe6:	fbfd                	bnez	a5,80003fdc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003fe8:	4785                	li	a5,1
    80003fea:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003fec:	8f7fd0ef          	jal	800018e2 <myproc>
    80003ff0:	591c                	lw	a5,48(a0)
    80003ff2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	c71fc0ef          	jal	80000c66 <release>
}
    80003ffa:	60e2                	ld	ra,24(sp)
    80003ffc:	6442                	ld	s0,16(sp)
    80003ffe:	64a2                	ld	s1,8(sp)
    80004000:	6902                	ld	s2,0(sp)
    80004002:	6105                	addi	sp,sp,32
    80004004:	8082                	ret

0000000080004006 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004006:	1101                	addi	sp,sp,-32
    80004008:	ec06                	sd	ra,24(sp)
    8000400a:	e822                	sd	s0,16(sp)
    8000400c:	e426                	sd	s1,8(sp)
    8000400e:	e04a                	sd	s2,0(sp)
    80004010:	1000                	addi	s0,sp,32
    80004012:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004014:	00850913          	addi	s2,a0,8
    80004018:	854a                	mv	a0,s2
    8000401a:	bb5fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    8000401e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004022:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004026:	8526                	mv	a0,s1
    80004028:	fd7fd0ef          	jal	80001ffe <wakeup>
  release(&lk->lk);
    8000402c:	854a                	mv	a0,s2
    8000402e:	c39fc0ef          	jal	80000c66 <release>
}
    80004032:	60e2                	ld	ra,24(sp)
    80004034:	6442                	ld	s0,16(sp)
    80004036:	64a2                	ld	s1,8(sp)
    80004038:	6902                	ld	s2,0(sp)
    8000403a:	6105                	addi	sp,sp,32
    8000403c:	8082                	ret

000000008000403e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000403e:	7179                	addi	sp,sp,-48
    80004040:	f406                	sd	ra,40(sp)
    80004042:	f022                	sd	s0,32(sp)
    80004044:	ec26                	sd	s1,24(sp)
    80004046:	e84a                	sd	s2,16(sp)
    80004048:	1800                	addi	s0,sp,48
    8000404a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000404c:	00850913          	addi	s2,a0,8
    80004050:	854a                	mv	a0,s2
    80004052:	b7dfc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004056:	409c                	lw	a5,0(s1)
    80004058:	ef81                	bnez	a5,80004070 <holdingsleep+0x32>
    8000405a:	4481                	li	s1,0
  release(&lk->lk);
    8000405c:	854a                	mv	a0,s2
    8000405e:	c09fc0ef          	jal	80000c66 <release>
  return r;
}
    80004062:	8526                	mv	a0,s1
    80004064:	70a2                	ld	ra,40(sp)
    80004066:	7402                	ld	s0,32(sp)
    80004068:	64e2                	ld	s1,24(sp)
    8000406a:	6942                	ld	s2,16(sp)
    8000406c:	6145                	addi	sp,sp,48
    8000406e:	8082                	ret
    80004070:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004072:	0284a983          	lw	s3,40(s1)
    80004076:	86dfd0ef          	jal	800018e2 <myproc>
    8000407a:	5904                	lw	s1,48(a0)
    8000407c:	413484b3          	sub	s1,s1,s3
    80004080:	0014b493          	seqz	s1,s1
    80004084:	69a2                	ld	s3,8(sp)
    80004086:	bfd9                	j	8000405c <holdingsleep+0x1e>

0000000080004088 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004088:	1141                	addi	sp,sp,-16
    8000408a:	e406                	sd	ra,8(sp)
    8000408c:	e022                	sd	s0,0(sp)
    8000408e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004090:	00003597          	auipc	a1,0x3
    80004094:	4d058593          	addi	a1,a1,1232 # 80007560 <etext+0x560>
    80004098:	0001f517          	auipc	a0,0x1f
    8000409c:	81050513          	addi	a0,a0,-2032 # 800228a8 <ftable>
    800040a0:	aaffc0ef          	jal	80000b4e <initlock>
}
    800040a4:	60a2                	ld	ra,8(sp)
    800040a6:	6402                	ld	s0,0(sp)
    800040a8:	0141                	addi	sp,sp,16
    800040aa:	8082                	ret

00000000800040ac <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800040ac:	1101                	addi	sp,sp,-32
    800040ae:	ec06                	sd	ra,24(sp)
    800040b0:	e822                	sd	s0,16(sp)
    800040b2:	e426                	sd	s1,8(sp)
    800040b4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040b6:	0001e517          	auipc	a0,0x1e
    800040ba:	7f250513          	addi	a0,a0,2034 # 800228a8 <ftable>
    800040be:	b11fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040c2:	0001e497          	auipc	s1,0x1e
    800040c6:	7fe48493          	addi	s1,s1,2046 # 800228c0 <ftable+0x18>
    800040ca:	0001f717          	auipc	a4,0x1f
    800040ce:	79670713          	addi	a4,a4,1942 # 80023860 <disk>
    if(f->ref == 0){
    800040d2:	40dc                	lw	a5,4(s1)
    800040d4:	cf89                	beqz	a5,800040ee <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040d6:	02848493          	addi	s1,s1,40
    800040da:	fee49ce3          	bne	s1,a4,800040d2 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040de:	0001e517          	auipc	a0,0x1e
    800040e2:	7ca50513          	addi	a0,a0,1994 # 800228a8 <ftable>
    800040e6:	b81fc0ef          	jal	80000c66 <release>
  return 0;
    800040ea:	4481                	li	s1,0
    800040ec:	a809                	j	800040fe <filealloc+0x52>
      f->ref = 1;
    800040ee:	4785                	li	a5,1
    800040f0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040f2:	0001e517          	auipc	a0,0x1e
    800040f6:	7b650513          	addi	a0,a0,1974 # 800228a8 <ftable>
    800040fa:	b6dfc0ef          	jal	80000c66 <release>
}
    800040fe:	8526                	mv	a0,s1
    80004100:	60e2                	ld	ra,24(sp)
    80004102:	6442                	ld	s0,16(sp)
    80004104:	64a2                	ld	s1,8(sp)
    80004106:	6105                	addi	sp,sp,32
    80004108:	8082                	ret

000000008000410a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000410a:	1101                	addi	sp,sp,-32
    8000410c:	ec06                	sd	ra,24(sp)
    8000410e:	e822                	sd	s0,16(sp)
    80004110:	e426                	sd	s1,8(sp)
    80004112:	1000                	addi	s0,sp,32
    80004114:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004116:	0001e517          	auipc	a0,0x1e
    8000411a:	79250513          	addi	a0,a0,1938 # 800228a8 <ftable>
    8000411e:	ab1fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004122:	40dc                	lw	a5,4(s1)
    80004124:	02f05063          	blez	a5,80004144 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004128:	2785                	addiw	a5,a5,1
    8000412a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000412c:	0001e517          	auipc	a0,0x1e
    80004130:	77c50513          	addi	a0,a0,1916 # 800228a8 <ftable>
    80004134:	b33fc0ef          	jal	80000c66 <release>
  return f;
}
    80004138:	8526                	mv	a0,s1
    8000413a:	60e2                	ld	ra,24(sp)
    8000413c:	6442                	ld	s0,16(sp)
    8000413e:	64a2                	ld	s1,8(sp)
    80004140:	6105                	addi	sp,sp,32
    80004142:	8082                	ret
    panic("filedup");
    80004144:	00003517          	auipc	a0,0x3
    80004148:	42450513          	addi	a0,a0,1060 # 80007568 <etext+0x568>
    8000414c:	e94fc0ef          	jal	800007e0 <panic>

0000000080004150 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004150:	7139                	addi	sp,sp,-64
    80004152:	fc06                	sd	ra,56(sp)
    80004154:	f822                	sd	s0,48(sp)
    80004156:	f426                	sd	s1,40(sp)
    80004158:	0080                	addi	s0,sp,64
    8000415a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000415c:	0001e517          	auipc	a0,0x1e
    80004160:	74c50513          	addi	a0,a0,1868 # 800228a8 <ftable>
    80004164:	a6bfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004168:	40dc                	lw	a5,4(s1)
    8000416a:	04f05a63          	blez	a5,800041be <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000416e:	37fd                	addiw	a5,a5,-1
    80004170:	0007871b          	sext.w	a4,a5
    80004174:	c0dc                	sw	a5,4(s1)
    80004176:	04e04e63          	bgtz	a4,800041d2 <fileclose+0x82>
    8000417a:	f04a                	sd	s2,32(sp)
    8000417c:	ec4e                	sd	s3,24(sp)
    8000417e:	e852                	sd	s4,16(sp)
    80004180:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004182:	0004a903          	lw	s2,0(s1)
    80004186:	0094ca83          	lbu	s5,9(s1)
    8000418a:	0104ba03          	ld	s4,16(s1)
    8000418e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004192:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004196:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000419a:	0001e517          	auipc	a0,0x1e
    8000419e:	70e50513          	addi	a0,a0,1806 # 800228a8 <ftable>
    800041a2:	ac5fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    800041a6:	4785                	li	a5,1
    800041a8:	04f90063          	beq	s2,a5,800041e8 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800041ac:	3979                	addiw	s2,s2,-2
    800041ae:	4785                	li	a5,1
    800041b0:	0527f563          	bgeu	a5,s2,800041fa <fileclose+0xaa>
    800041b4:	7902                	ld	s2,32(sp)
    800041b6:	69e2                	ld	s3,24(sp)
    800041b8:	6a42                	ld	s4,16(sp)
    800041ba:	6aa2                	ld	s5,8(sp)
    800041bc:	a00d                	j	800041de <fileclose+0x8e>
    800041be:	f04a                	sd	s2,32(sp)
    800041c0:	ec4e                	sd	s3,24(sp)
    800041c2:	e852                	sd	s4,16(sp)
    800041c4:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800041c6:	00003517          	auipc	a0,0x3
    800041ca:	3aa50513          	addi	a0,a0,938 # 80007570 <etext+0x570>
    800041ce:	e12fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    800041d2:	0001e517          	auipc	a0,0x1e
    800041d6:	6d650513          	addi	a0,a0,1750 # 800228a8 <ftable>
    800041da:	a8dfc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800041de:	70e2                	ld	ra,56(sp)
    800041e0:	7442                	ld	s0,48(sp)
    800041e2:	74a2                	ld	s1,40(sp)
    800041e4:	6121                	addi	sp,sp,64
    800041e6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800041e8:	85d6                	mv	a1,s5
    800041ea:	8552                	mv	a0,s4
    800041ec:	336000ef          	jal	80004522 <pipeclose>
    800041f0:	7902                	ld	s2,32(sp)
    800041f2:	69e2                	ld	s3,24(sp)
    800041f4:	6a42                	ld	s4,16(sp)
    800041f6:	6aa2                	ld	s5,8(sp)
    800041f8:	b7dd                	j	800041de <fileclose+0x8e>
    begin_op();
    800041fa:	b4bff0ef          	jal	80003d44 <begin_op>
    iput(ff.ip);
    800041fe:	854e                	mv	a0,s3
    80004200:	adcff0ef          	jal	800034dc <iput>
    end_op();
    80004204:	babff0ef          	jal	80003dae <end_op>
    80004208:	7902                	ld	s2,32(sp)
    8000420a:	69e2                	ld	s3,24(sp)
    8000420c:	6a42                	ld	s4,16(sp)
    8000420e:	6aa2                	ld	s5,8(sp)
    80004210:	b7f9                	j	800041de <fileclose+0x8e>

0000000080004212 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004212:	715d                	addi	sp,sp,-80
    80004214:	e486                	sd	ra,72(sp)
    80004216:	e0a2                	sd	s0,64(sp)
    80004218:	fc26                	sd	s1,56(sp)
    8000421a:	f44e                	sd	s3,40(sp)
    8000421c:	0880                	addi	s0,sp,80
    8000421e:	84aa                	mv	s1,a0
    80004220:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004222:	ec0fd0ef          	jal	800018e2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004226:	409c                	lw	a5,0(s1)
    80004228:	37f9                	addiw	a5,a5,-2
    8000422a:	4705                	li	a4,1
    8000422c:	04f76063          	bltu	a4,a5,8000426c <filestat+0x5a>
    80004230:	f84a                	sd	s2,48(sp)
    80004232:	892a                	mv	s2,a0
    ilock(f->ip);
    80004234:	6c88                	ld	a0,24(s1)
    80004236:	924ff0ef          	jal	8000335a <ilock>
    stati(f->ip, &st);
    8000423a:	fb840593          	addi	a1,s0,-72
    8000423e:	6c88                	ld	a0,24(s1)
    80004240:	c80ff0ef          	jal	800036c0 <stati>
    iunlock(f->ip);
    80004244:	6c88                	ld	a0,24(s1)
    80004246:	9c2ff0ef          	jal	80003408 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000424a:	46e1                	li	a3,24
    8000424c:	fb840613          	addi	a2,s0,-72
    80004250:	85ce                	mv	a1,s3
    80004252:	05093503          	ld	a0,80(s2)
    80004256:	b8cfd0ef          	jal	800015e2 <copyout>
    8000425a:	41f5551b          	sraiw	a0,a0,0x1f
    8000425e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004260:	60a6                	ld	ra,72(sp)
    80004262:	6406                	ld	s0,64(sp)
    80004264:	74e2                	ld	s1,56(sp)
    80004266:	79a2                	ld	s3,40(sp)
    80004268:	6161                	addi	sp,sp,80
    8000426a:	8082                	ret
  return -1;
    8000426c:	557d                	li	a0,-1
    8000426e:	bfcd                	j	80004260 <filestat+0x4e>

0000000080004270 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004270:	7179                	addi	sp,sp,-48
    80004272:	f406                	sd	ra,40(sp)
    80004274:	f022                	sd	s0,32(sp)
    80004276:	e84a                	sd	s2,16(sp)
    80004278:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000427a:	00854783          	lbu	a5,8(a0)
    8000427e:	cfd1                	beqz	a5,8000431a <fileread+0xaa>
    80004280:	ec26                	sd	s1,24(sp)
    80004282:	e44e                	sd	s3,8(sp)
    80004284:	84aa                	mv	s1,a0
    80004286:	89ae                	mv	s3,a1
    80004288:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000428a:	411c                	lw	a5,0(a0)
    8000428c:	4705                	li	a4,1
    8000428e:	04e78363          	beq	a5,a4,800042d4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004292:	470d                	li	a4,3
    80004294:	04e78763          	beq	a5,a4,800042e2 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004298:	4709                	li	a4,2
    8000429a:	06e79a63          	bne	a5,a4,8000430e <fileread+0x9e>
    ilock(f->ip);
    8000429e:	6d08                	ld	a0,24(a0)
    800042a0:	8baff0ef          	jal	8000335a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042a4:	874a                	mv	a4,s2
    800042a6:	5094                	lw	a3,32(s1)
    800042a8:	864e                	mv	a2,s3
    800042aa:	4585                	li	a1,1
    800042ac:	6c88                	ld	a0,24(s1)
    800042ae:	c3cff0ef          	jal	800036ea <readi>
    800042b2:	892a                	mv	s2,a0
    800042b4:	00a05563          	blez	a0,800042be <fileread+0x4e>
      f->off += r;
    800042b8:	509c                	lw	a5,32(s1)
    800042ba:	9fa9                	addw	a5,a5,a0
    800042bc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800042be:	6c88                	ld	a0,24(s1)
    800042c0:	948ff0ef          	jal	80003408 <iunlock>
    800042c4:	64e2                	ld	s1,24(sp)
    800042c6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800042c8:	854a                	mv	a0,s2
    800042ca:	70a2                	ld	ra,40(sp)
    800042cc:	7402                	ld	s0,32(sp)
    800042ce:	6942                	ld	s2,16(sp)
    800042d0:	6145                	addi	sp,sp,48
    800042d2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800042d4:	6908                	ld	a0,16(a0)
    800042d6:	388000ef          	jal	8000465e <piperead>
    800042da:	892a                	mv	s2,a0
    800042dc:	64e2                	ld	s1,24(sp)
    800042de:	69a2                	ld	s3,8(sp)
    800042e0:	b7e5                	j	800042c8 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042e2:	02451783          	lh	a5,36(a0)
    800042e6:	03079693          	slli	a3,a5,0x30
    800042ea:	92c1                	srli	a3,a3,0x30
    800042ec:	4725                	li	a4,9
    800042ee:	02d76863          	bltu	a4,a3,8000431e <fileread+0xae>
    800042f2:	0792                	slli	a5,a5,0x4
    800042f4:	0001e717          	auipc	a4,0x1e
    800042f8:	51470713          	addi	a4,a4,1300 # 80022808 <devsw>
    800042fc:	97ba                	add	a5,a5,a4
    800042fe:	639c                	ld	a5,0(a5)
    80004300:	c39d                	beqz	a5,80004326 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004302:	4505                	li	a0,1
    80004304:	9782                	jalr	a5
    80004306:	892a                	mv	s2,a0
    80004308:	64e2                	ld	s1,24(sp)
    8000430a:	69a2                	ld	s3,8(sp)
    8000430c:	bf75                	j	800042c8 <fileread+0x58>
    panic("fileread");
    8000430e:	00003517          	auipc	a0,0x3
    80004312:	27250513          	addi	a0,a0,626 # 80007580 <etext+0x580>
    80004316:	ccafc0ef          	jal	800007e0 <panic>
    return -1;
    8000431a:	597d                	li	s2,-1
    8000431c:	b775                	j	800042c8 <fileread+0x58>
      return -1;
    8000431e:	597d                	li	s2,-1
    80004320:	64e2                	ld	s1,24(sp)
    80004322:	69a2                	ld	s3,8(sp)
    80004324:	b755                	j	800042c8 <fileread+0x58>
    80004326:	597d                	li	s2,-1
    80004328:	64e2                	ld	s1,24(sp)
    8000432a:	69a2                	ld	s3,8(sp)
    8000432c:	bf71                	j	800042c8 <fileread+0x58>

000000008000432e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000432e:	00954783          	lbu	a5,9(a0)
    80004332:	10078b63          	beqz	a5,80004448 <filewrite+0x11a>
{
    80004336:	715d                	addi	sp,sp,-80
    80004338:	e486                	sd	ra,72(sp)
    8000433a:	e0a2                	sd	s0,64(sp)
    8000433c:	f84a                	sd	s2,48(sp)
    8000433e:	f052                	sd	s4,32(sp)
    80004340:	e85a                	sd	s6,16(sp)
    80004342:	0880                	addi	s0,sp,80
    80004344:	892a                	mv	s2,a0
    80004346:	8b2e                	mv	s6,a1
    80004348:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000434a:	411c                	lw	a5,0(a0)
    8000434c:	4705                	li	a4,1
    8000434e:	02e78763          	beq	a5,a4,8000437c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004352:	470d                	li	a4,3
    80004354:	02e78863          	beq	a5,a4,80004384 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004358:	4709                	li	a4,2
    8000435a:	0ce79c63          	bne	a5,a4,80004432 <filewrite+0x104>
    8000435e:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004360:	0ac05863          	blez	a2,80004410 <filewrite+0xe2>
    80004364:	fc26                	sd	s1,56(sp)
    80004366:	ec56                	sd	s5,24(sp)
    80004368:	e45e                	sd	s7,8(sp)
    8000436a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000436c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000436e:	6b85                	lui	s7,0x1
    80004370:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004374:	6c05                	lui	s8,0x1
    80004376:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000437a:	a8b5                	j	800043f6 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000437c:	6908                	ld	a0,16(a0)
    8000437e:	1fc000ef          	jal	8000457a <pipewrite>
    80004382:	a04d                	j	80004424 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004384:	02451783          	lh	a5,36(a0)
    80004388:	03079693          	slli	a3,a5,0x30
    8000438c:	92c1                	srli	a3,a3,0x30
    8000438e:	4725                	li	a4,9
    80004390:	0ad76e63          	bltu	a4,a3,8000444c <filewrite+0x11e>
    80004394:	0792                	slli	a5,a5,0x4
    80004396:	0001e717          	auipc	a4,0x1e
    8000439a:	47270713          	addi	a4,a4,1138 # 80022808 <devsw>
    8000439e:	97ba                	add	a5,a5,a4
    800043a0:	679c                	ld	a5,8(a5)
    800043a2:	c7dd                	beqz	a5,80004450 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800043a4:	4505                	li	a0,1
    800043a6:	9782                	jalr	a5
    800043a8:	a8b5                	j	80004424 <filewrite+0xf6>
      if(n1 > max)
    800043aa:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800043ae:	997ff0ef          	jal	80003d44 <begin_op>
      ilock(f->ip);
    800043b2:	01893503          	ld	a0,24(s2)
    800043b6:	fa5fe0ef          	jal	8000335a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043ba:	8756                	mv	a4,s5
    800043bc:	02092683          	lw	a3,32(s2)
    800043c0:	01698633          	add	a2,s3,s6
    800043c4:	4585                	li	a1,1
    800043c6:	01893503          	ld	a0,24(s2)
    800043ca:	c1cff0ef          	jal	800037e6 <writei>
    800043ce:	84aa                	mv	s1,a0
    800043d0:	00a05763          	blez	a0,800043de <filewrite+0xb0>
        f->off += r;
    800043d4:	02092783          	lw	a5,32(s2)
    800043d8:	9fa9                	addw	a5,a5,a0
    800043da:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800043de:	01893503          	ld	a0,24(s2)
    800043e2:	826ff0ef          	jal	80003408 <iunlock>
      end_op();
    800043e6:	9c9ff0ef          	jal	80003dae <end_op>

      if(r != n1){
    800043ea:	029a9563          	bne	s5,s1,80004414 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800043ee:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800043f2:	0149da63          	bge	s3,s4,80004406 <filewrite+0xd8>
      int n1 = n - i;
    800043f6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800043fa:	0004879b          	sext.w	a5,s1
    800043fe:	fafbd6e3          	bge	s7,a5,800043aa <filewrite+0x7c>
    80004402:	84e2                	mv	s1,s8
    80004404:	b75d                	j	800043aa <filewrite+0x7c>
    80004406:	74e2                	ld	s1,56(sp)
    80004408:	6ae2                	ld	s5,24(sp)
    8000440a:	6ba2                	ld	s7,8(sp)
    8000440c:	6c02                	ld	s8,0(sp)
    8000440e:	a039                	j	8000441c <filewrite+0xee>
    int i = 0;
    80004410:	4981                	li	s3,0
    80004412:	a029                	j	8000441c <filewrite+0xee>
    80004414:	74e2                	ld	s1,56(sp)
    80004416:	6ae2                	ld	s5,24(sp)
    80004418:	6ba2                	ld	s7,8(sp)
    8000441a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000441c:	033a1c63          	bne	s4,s3,80004454 <filewrite+0x126>
    80004420:	8552                	mv	a0,s4
    80004422:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004424:	60a6                	ld	ra,72(sp)
    80004426:	6406                	ld	s0,64(sp)
    80004428:	7942                	ld	s2,48(sp)
    8000442a:	7a02                	ld	s4,32(sp)
    8000442c:	6b42                	ld	s6,16(sp)
    8000442e:	6161                	addi	sp,sp,80
    80004430:	8082                	ret
    80004432:	fc26                	sd	s1,56(sp)
    80004434:	f44e                	sd	s3,40(sp)
    80004436:	ec56                	sd	s5,24(sp)
    80004438:	e45e                	sd	s7,8(sp)
    8000443a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000443c:	00003517          	auipc	a0,0x3
    80004440:	15450513          	addi	a0,a0,340 # 80007590 <etext+0x590>
    80004444:	b9cfc0ef          	jal	800007e0 <panic>
    return -1;
    80004448:	557d                	li	a0,-1
}
    8000444a:	8082                	ret
      return -1;
    8000444c:	557d                	li	a0,-1
    8000444e:	bfd9                	j	80004424 <filewrite+0xf6>
    80004450:	557d                	li	a0,-1
    80004452:	bfc9                	j	80004424 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004454:	557d                	li	a0,-1
    80004456:	79a2                	ld	s3,40(sp)
    80004458:	b7f1                	j	80004424 <filewrite+0xf6>

000000008000445a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000445a:	7179                	addi	sp,sp,-48
    8000445c:	f406                	sd	ra,40(sp)
    8000445e:	f022                	sd	s0,32(sp)
    80004460:	ec26                	sd	s1,24(sp)
    80004462:	e052                	sd	s4,0(sp)
    80004464:	1800                	addi	s0,sp,48
    80004466:	84aa                	mv	s1,a0
    80004468:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000446a:	0005b023          	sd	zero,0(a1)
    8000446e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004472:	c3bff0ef          	jal	800040ac <filealloc>
    80004476:	e088                	sd	a0,0(s1)
    80004478:	c549                	beqz	a0,80004502 <pipealloc+0xa8>
    8000447a:	c33ff0ef          	jal	800040ac <filealloc>
    8000447e:	00aa3023          	sd	a0,0(s4)
    80004482:	cd25                	beqz	a0,800044fa <pipealloc+0xa0>
    80004484:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004486:	e78fc0ef          	jal	80000afe <kalloc>
    8000448a:	892a                	mv	s2,a0
    8000448c:	c12d                	beqz	a0,800044ee <pipealloc+0x94>
    8000448e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004490:	4985                	li	s3,1
    80004492:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004496:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000449a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000449e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044a2:	00003597          	auipc	a1,0x3
    800044a6:	0fe58593          	addi	a1,a1,254 # 800075a0 <etext+0x5a0>
    800044aa:	ea4fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    800044ae:	609c                	ld	a5,0(s1)
    800044b0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800044b4:	609c                	ld	a5,0(s1)
    800044b6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800044ba:	609c                	ld	a5,0(s1)
    800044bc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800044c0:	609c                	ld	a5,0(s1)
    800044c2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800044c6:	000a3783          	ld	a5,0(s4)
    800044ca:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800044ce:	000a3783          	ld	a5,0(s4)
    800044d2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800044d6:	000a3783          	ld	a5,0(s4)
    800044da:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800044de:	000a3783          	ld	a5,0(s4)
    800044e2:	0127b823          	sd	s2,16(a5)
  return 0;
    800044e6:	4501                	li	a0,0
    800044e8:	6942                	ld	s2,16(sp)
    800044ea:	69a2                	ld	s3,8(sp)
    800044ec:	a01d                	j	80004512 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800044ee:	6088                	ld	a0,0(s1)
    800044f0:	c119                	beqz	a0,800044f6 <pipealloc+0x9c>
    800044f2:	6942                	ld	s2,16(sp)
    800044f4:	a029                	j	800044fe <pipealloc+0xa4>
    800044f6:	6942                	ld	s2,16(sp)
    800044f8:	a029                	j	80004502 <pipealloc+0xa8>
    800044fa:	6088                	ld	a0,0(s1)
    800044fc:	c10d                	beqz	a0,8000451e <pipealloc+0xc4>
    fileclose(*f0);
    800044fe:	c53ff0ef          	jal	80004150 <fileclose>
  if(*f1)
    80004502:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004506:	557d                	li	a0,-1
  if(*f1)
    80004508:	c789                	beqz	a5,80004512 <pipealloc+0xb8>
    fileclose(*f1);
    8000450a:	853e                	mv	a0,a5
    8000450c:	c45ff0ef          	jal	80004150 <fileclose>
  return -1;
    80004510:	557d                	li	a0,-1
}
    80004512:	70a2                	ld	ra,40(sp)
    80004514:	7402                	ld	s0,32(sp)
    80004516:	64e2                	ld	s1,24(sp)
    80004518:	6a02                	ld	s4,0(sp)
    8000451a:	6145                	addi	sp,sp,48
    8000451c:	8082                	ret
  return -1;
    8000451e:	557d                	li	a0,-1
    80004520:	bfcd                	j	80004512 <pipealloc+0xb8>

0000000080004522 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004522:	1101                	addi	sp,sp,-32
    80004524:	ec06                	sd	ra,24(sp)
    80004526:	e822                	sd	s0,16(sp)
    80004528:	e426                	sd	s1,8(sp)
    8000452a:	e04a                	sd	s2,0(sp)
    8000452c:	1000                	addi	s0,sp,32
    8000452e:	84aa                	mv	s1,a0
    80004530:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004532:	e9cfc0ef          	jal	80000bce <acquire>
  if(writable){
    80004536:	02090763          	beqz	s2,80004564 <pipeclose+0x42>
    pi->writeopen = 0;
    8000453a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000453e:	21848513          	addi	a0,s1,536
    80004542:	abdfd0ef          	jal	80001ffe <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004546:	2204b783          	ld	a5,544(s1)
    8000454a:	e785                	bnez	a5,80004572 <pipeclose+0x50>
    release(&pi->lock);
    8000454c:	8526                	mv	a0,s1
    8000454e:	f18fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    80004552:	8526                	mv	a0,s1
    80004554:	cc8fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    80004558:	60e2                	ld	ra,24(sp)
    8000455a:	6442                	ld	s0,16(sp)
    8000455c:	64a2                	ld	s1,8(sp)
    8000455e:	6902                	ld	s2,0(sp)
    80004560:	6105                	addi	sp,sp,32
    80004562:	8082                	ret
    pi->readopen = 0;
    80004564:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004568:	21c48513          	addi	a0,s1,540
    8000456c:	a93fd0ef          	jal	80001ffe <wakeup>
    80004570:	bfd9                	j	80004546 <pipeclose+0x24>
    release(&pi->lock);
    80004572:	8526                	mv	a0,s1
    80004574:	ef2fc0ef          	jal	80000c66 <release>
}
    80004578:	b7c5                	j	80004558 <pipeclose+0x36>

000000008000457a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000457a:	711d                	addi	sp,sp,-96
    8000457c:	ec86                	sd	ra,88(sp)
    8000457e:	e8a2                	sd	s0,80(sp)
    80004580:	e4a6                	sd	s1,72(sp)
    80004582:	e0ca                	sd	s2,64(sp)
    80004584:	fc4e                	sd	s3,56(sp)
    80004586:	f852                	sd	s4,48(sp)
    80004588:	f456                	sd	s5,40(sp)
    8000458a:	1080                	addi	s0,sp,96
    8000458c:	84aa                	mv	s1,a0
    8000458e:	8aae                	mv	s5,a1
    80004590:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004592:	b50fd0ef          	jal	800018e2 <myproc>
    80004596:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004598:	8526                	mv	a0,s1
    8000459a:	e34fc0ef          	jal	80000bce <acquire>
  while(i < n){
    8000459e:	0b405a63          	blez	s4,80004652 <pipewrite+0xd8>
    800045a2:	f05a                	sd	s6,32(sp)
    800045a4:	ec5e                	sd	s7,24(sp)
    800045a6:	e862                	sd	s8,16(sp)
  int i = 0;
    800045a8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045aa:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800045ac:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800045b0:	21c48b93          	addi	s7,s1,540
    800045b4:	a81d                	j	800045ea <pipewrite+0x70>
      release(&pi->lock);
    800045b6:	8526                	mv	a0,s1
    800045b8:	eaefc0ef          	jal	80000c66 <release>
      return -1;
    800045bc:	597d                	li	s2,-1
    800045be:	7b02                	ld	s6,32(sp)
    800045c0:	6be2                	ld	s7,24(sp)
    800045c2:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800045c4:	854a                	mv	a0,s2
    800045c6:	60e6                	ld	ra,88(sp)
    800045c8:	6446                	ld	s0,80(sp)
    800045ca:	64a6                	ld	s1,72(sp)
    800045cc:	6906                	ld	s2,64(sp)
    800045ce:	79e2                	ld	s3,56(sp)
    800045d0:	7a42                	ld	s4,48(sp)
    800045d2:	7aa2                	ld	s5,40(sp)
    800045d4:	6125                	addi	sp,sp,96
    800045d6:	8082                	ret
      wakeup(&pi->nread);
    800045d8:	8562                	mv	a0,s8
    800045da:	a25fd0ef          	jal	80001ffe <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800045de:	85a6                	mv	a1,s1
    800045e0:	855e                	mv	a0,s7
    800045e2:	9d1fd0ef          	jal	80001fb2 <sleep>
  while(i < n){
    800045e6:	05495b63          	bge	s2,s4,8000463c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800045ea:	2204a783          	lw	a5,544(s1)
    800045ee:	d7e1                	beqz	a5,800045b6 <pipewrite+0x3c>
    800045f0:	854e                	mv	a0,s3
    800045f2:	bf9fd0ef          	jal	800021ea <killed>
    800045f6:	f161                	bnez	a0,800045b6 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800045f8:	2184a783          	lw	a5,536(s1)
    800045fc:	21c4a703          	lw	a4,540(s1)
    80004600:	2007879b          	addiw	a5,a5,512
    80004604:	fcf70ae3          	beq	a4,a5,800045d8 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004608:	4685                	li	a3,1
    8000460a:	01590633          	add	a2,s2,s5
    8000460e:	faf40593          	addi	a1,s0,-81
    80004612:	0509b503          	ld	a0,80(s3)
    80004616:	8b0fd0ef          	jal	800016c6 <copyin>
    8000461a:	03650e63          	beq	a0,s6,80004656 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000461e:	21c4a783          	lw	a5,540(s1)
    80004622:	0017871b          	addiw	a4,a5,1
    80004626:	20e4ae23          	sw	a4,540(s1)
    8000462a:	1ff7f793          	andi	a5,a5,511
    8000462e:	97a6                	add	a5,a5,s1
    80004630:	faf44703          	lbu	a4,-81(s0)
    80004634:	00e78c23          	sb	a4,24(a5)
      i++;
    80004638:	2905                	addiw	s2,s2,1
    8000463a:	b775                	j	800045e6 <pipewrite+0x6c>
    8000463c:	7b02                	ld	s6,32(sp)
    8000463e:	6be2                	ld	s7,24(sp)
    80004640:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004642:	21848513          	addi	a0,s1,536
    80004646:	9b9fd0ef          	jal	80001ffe <wakeup>
  release(&pi->lock);
    8000464a:	8526                	mv	a0,s1
    8000464c:	e1afc0ef          	jal	80000c66 <release>
  return i;
    80004650:	bf95                	j	800045c4 <pipewrite+0x4a>
  int i = 0;
    80004652:	4901                	li	s2,0
    80004654:	b7fd                	j	80004642 <pipewrite+0xc8>
    80004656:	7b02                	ld	s6,32(sp)
    80004658:	6be2                	ld	s7,24(sp)
    8000465a:	6c42                	ld	s8,16(sp)
    8000465c:	b7dd                	j	80004642 <pipewrite+0xc8>

000000008000465e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000465e:	715d                	addi	sp,sp,-80
    80004660:	e486                	sd	ra,72(sp)
    80004662:	e0a2                	sd	s0,64(sp)
    80004664:	fc26                	sd	s1,56(sp)
    80004666:	f84a                	sd	s2,48(sp)
    80004668:	f44e                	sd	s3,40(sp)
    8000466a:	f052                	sd	s4,32(sp)
    8000466c:	ec56                	sd	s5,24(sp)
    8000466e:	0880                	addi	s0,sp,80
    80004670:	84aa                	mv	s1,a0
    80004672:	892e                	mv	s2,a1
    80004674:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004676:	a6cfd0ef          	jal	800018e2 <myproc>
    8000467a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000467c:	8526                	mv	a0,s1
    8000467e:	d50fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004682:	2184a703          	lw	a4,536(s1)
    80004686:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000468a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000468e:	02f71563          	bne	a4,a5,800046b8 <piperead+0x5a>
    80004692:	2244a783          	lw	a5,548(s1)
    80004696:	cb85                	beqz	a5,800046c6 <piperead+0x68>
    if(killed(pr)){
    80004698:	8552                	mv	a0,s4
    8000469a:	b51fd0ef          	jal	800021ea <killed>
    8000469e:	ed19                	bnez	a0,800046bc <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046a0:	85a6                	mv	a1,s1
    800046a2:	854e                	mv	a0,s3
    800046a4:	90ffd0ef          	jal	80001fb2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046a8:	2184a703          	lw	a4,536(s1)
    800046ac:	21c4a783          	lw	a5,540(s1)
    800046b0:	fef701e3          	beq	a4,a5,80004692 <piperead+0x34>
    800046b4:	e85a                	sd	s6,16(sp)
    800046b6:	a809                	j	800046c8 <piperead+0x6a>
    800046b8:	e85a                	sd	s6,16(sp)
    800046ba:	a039                	j	800046c8 <piperead+0x6a>
      release(&pi->lock);
    800046bc:	8526                	mv	a0,s1
    800046be:	da8fc0ef          	jal	80000c66 <release>
      return -1;
    800046c2:	59fd                	li	s3,-1
    800046c4:	a8b9                	j	80004722 <piperead+0xc4>
    800046c6:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046c8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800046ca:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046cc:	05505363          	blez	s5,80004712 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800046d0:	2184a783          	lw	a5,536(s1)
    800046d4:	21c4a703          	lw	a4,540(s1)
    800046d8:	02f70d63          	beq	a4,a5,80004712 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800046dc:	1ff7f793          	andi	a5,a5,511
    800046e0:	97a6                	add	a5,a5,s1
    800046e2:	0187c783          	lbu	a5,24(a5)
    800046e6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800046ea:	4685                	li	a3,1
    800046ec:	fbf40613          	addi	a2,s0,-65
    800046f0:	85ca                	mv	a1,s2
    800046f2:	050a3503          	ld	a0,80(s4)
    800046f6:	eedfc0ef          	jal	800015e2 <copyout>
    800046fa:	03650e63          	beq	a0,s6,80004736 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800046fe:	2184a783          	lw	a5,536(s1)
    80004702:	2785                	addiw	a5,a5,1
    80004704:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004708:	2985                	addiw	s3,s3,1
    8000470a:	0905                	addi	s2,s2,1
    8000470c:	fd3a92e3          	bne	s5,s3,800046d0 <piperead+0x72>
    80004710:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004712:	21c48513          	addi	a0,s1,540
    80004716:	8e9fd0ef          	jal	80001ffe <wakeup>
  release(&pi->lock);
    8000471a:	8526                	mv	a0,s1
    8000471c:	d4afc0ef          	jal	80000c66 <release>
    80004720:	6b42                	ld	s6,16(sp)
  return i;
}
    80004722:	854e                	mv	a0,s3
    80004724:	60a6                	ld	ra,72(sp)
    80004726:	6406                	ld	s0,64(sp)
    80004728:	74e2                	ld	s1,56(sp)
    8000472a:	7942                	ld	s2,48(sp)
    8000472c:	79a2                	ld	s3,40(sp)
    8000472e:	7a02                	ld	s4,32(sp)
    80004730:	6ae2                	ld	s5,24(sp)
    80004732:	6161                	addi	sp,sp,80
    80004734:	8082                	ret
      if(i == 0)
    80004736:	fc099ee3          	bnez	s3,80004712 <piperead+0xb4>
        i = -1;
    8000473a:	89aa                	mv	s3,a0
    8000473c:	bfd9                	j	80004712 <piperead+0xb4>

000000008000473e <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000473e:	1141                	addi	sp,sp,-16
    80004740:	e422                	sd	s0,8(sp)
    80004742:	0800                	addi	s0,sp,16
    80004744:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004746:	8905                	andi	a0,a0,1
    80004748:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000474a:	8b89                	andi	a5,a5,2
    8000474c:	c399                	beqz	a5,80004752 <flags2perm+0x14>
      perm |= PTE_W;
    8000474e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004752:	6422                	ld	s0,8(sp)
    80004754:	0141                	addi	sp,sp,16
    80004756:	8082                	ret

0000000080004758 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004758:	df010113          	addi	sp,sp,-528
    8000475c:	20113423          	sd	ra,520(sp)
    80004760:	20813023          	sd	s0,512(sp)
    80004764:	ffa6                	sd	s1,504(sp)
    80004766:	fbca                	sd	s2,496(sp)
    80004768:	0c00                	addi	s0,sp,528
    8000476a:	892a                	mv	s2,a0
    8000476c:	dea43c23          	sd	a0,-520(s0)
    80004770:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004774:	96efd0ef          	jal	800018e2 <myproc>
    80004778:	84aa                	mv	s1,a0

  begin_op();
    8000477a:	dcaff0ef          	jal	80003d44 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000477e:	854a                	mv	a0,s2
    80004780:	bf0ff0ef          	jal	80003b70 <namei>
    80004784:	c931                	beqz	a0,800047d8 <kexec+0x80>
    80004786:	f3d2                	sd	s4,480(sp)
    80004788:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000478a:	bd1fe0ef          	jal	8000335a <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000478e:	04000713          	li	a4,64
    80004792:	4681                	li	a3,0
    80004794:	e5040613          	addi	a2,s0,-432
    80004798:	4581                	li	a1,0
    8000479a:	8552                	mv	a0,s4
    8000479c:	f4ffe0ef          	jal	800036ea <readi>
    800047a0:	04000793          	li	a5,64
    800047a4:	00f51a63          	bne	a0,a5,800047b8 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800047a8:	e5042703          	lw	a4,-432(s0)
    800047ac:	464c47b7          	lui	a5,0x464c4
    800047b0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800047b4:	02f70663          	beq	a4,a5,800047e0 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800047b8:	8552                	mv	a0,s4
    800047ba:	dabfe0ef          	jal	80003564 <iunlockput>
    end_op();
    800047be:	df0ff0ef          	jal	80003dae <end_op>
  }
  return -1;
    800047c2:	557d                	li	a0,-1
    800047c4:	7a1e                	ld	s4,480(sp)
}
    800047c6:	20813083          	ld	ra,520(sp)
    800047ca:	20013403          	ld	s0,512(sp)
    800047ce:	74fe                	ld	s1,504(sp)
    800047d0:	795e                	ld	s2,496(sp)
    800047d2:	21010113          	addi	sp,sp,528
    800047d6:	8082                	ret
    end_op();
    800047d8:	dd6ff0ef          	jal	80003dae <end_op>
    return -1;
    800047dc:	557d                	li	a0,-1
    800047de:	b7e5                	j	800047c6 <kexec+0x6e>
    800047e0:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800047e2:	8526                	mv	a0,s1
    800047e4:	a04fd0ef          	jal	800019e8 <proc_pagetable>
    800047e8:	8b2a                	mv	s6,a0
    800047ea:	2c050b63          	beqz	a0,80004ac0 <kexec+0x368>
    800047ee:	f7ce                	sd	s3,488(sp)
    800047f0:	efd6                	sd	s5,472(sp)
    800047f2:	e7de                	sd	s7,456(sp)
    800047f4:	e3e2                	sd	s8,448(sp)
    800047f6:	ff66                	sd	s9,440(sp)
    800047f8:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047fa:	e7042d03          	lw	s10,-400(s0)
    800047fe:	e8845783          	lhu	a5,-376(s0)
    80004802:	12078963          	beqz	a5,80004934 <kexec+0x1dc>
    80004806:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004808:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000480a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000480c:	6c85                	lui	s9,0x1
    8000480e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004812:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004816:	6a85                	lui	s5,0x1
    80004818:	a085                	j	80004878 <kexec+0x120>
      panic("loadseg: address should exist");
    8000481a:	00003517          	auipc	a0,0x3
    8000481e:	d8e50513          	addi	a0,a0,-626 # 800075a8 <etext+0x5a8>
    80004822:	fbffb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80004826:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004828:	8726                	mv	a4,s1
    8000482a:	012c06bb          	addw	a3,s8,s2
    8000482e:	4581                	li	a1,0
    80004830:	8552                	mv	a0,s4
    80004832:	eb9fe0ef          	jal	800036ea <readi>
    80004836:	2501                	sext.w	a0,a0
    80004838:	24a49a63          	bne	s1,a0,80004a8c <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000483c:	012a893b          	addw	s2,s5,s2
    80004840:	03397363          	bgeu	s2,s3,80004866 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004844:	02091593          	slli	a1,s2,0x20
    80004848:	9181                	srli	a1,a1,0x20
    8000484a:	95de                	add	a1,a1,s7
    8000484c:	855a                	mv	a0,s6
    8000484e:	f62fc0ef          	jal	80000fb0 <walkaddr>
    80004852:	862a                	mv	a2,a0
    if(pa == 0)
    80004854:	d179                	beqz	a0,8000481a <kexec+0xc2>
    if(sz - i < PGSIZE)
    80004856:	412984bb          	subw	s1,s3,s2
    8000485a:	0004879b          	sext.w	a5,s1
    8000485e:	fcfcf4e3          	bgeu	s9,a5,80004826 <kexec+0xce>
    80004862:	84d6                	mv	s1,s5
    80004864:	b7c9                	j	80004826 <kexec+0xce>
    sz = sz1;
    80004866:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000486a:	2d85                	addiw	s11,s11,1
    8000486c:	038d0d1b          	addiw	s10,s10,56
    80004870:	e8845783          	lhu	a5,-376(s0)
    80004874:	08fdd063          	bge	s11,a5,800048f4 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004878:	2d01                	sext.w	s10,s10
    8000487a:	03800713          	li	a4,56
    8000487e:	86ea                	mv	a3,s10
    80004880:	e1840613          	addi	a2,s0,-488
    80004884:	4581                	li	a1,0
    80004886:	8552                	mv	a0,s4
    80004888:	e63fe0ef          	jal	800036ea <readi>
    8000488c:	03800793          	li	a5,56
    80004890:	1cf51663          	bne	a0,a5,80004a5c <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004894:	e1842783          	lw	a5,-488(s0)
    80004898:	4705                	li	a4,1
    8000489a:	fce798e3          	bne	a5,a4,8000486a <kexec+0x112>
    if(ph.memsz < ph.filesz)
    8000489e:	e4043483          	ld	s1,-448(s0)
    800048a2:	e3843783          	ld	a5,-456(s0)
    800048a6:	1af4ef63          	bltu	s1,a5,80004a64 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800048aa:	e2843783          	ld	a5,-472(s0)
    800048ae:	94be                	add	s1,s1,a5
    800048b0:	1af4ee63          	bltu	s1,a5,80004a6c <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800048b4:	df043703          	ld	a4,-528(s0)
    800048b8:	8ff9                	and	a5,a5,a4
    800048ba:	1a079d63          	bnez	a5,80004a74 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800048be:	e1c42503          	lw	a0,-484(s0)
    800048c2:	e7dff0ef          	jal	8000473e <flags2perm>
    800048c6:	86aa                	mv	a3,a0
    800048c8:	8626                	mv	a2,s1
    800048ca:	85ca                	mv	a1,s2
    800048cc:	855a                	mv	a0,s6
    800048ce:	9bbfc0ef          	jal	80001288 <uvmalloc>
    800048d2:	e0a43423          	sd	a0,-504(s0)
    800048d6:	1a050363          	beqz	a0,80004a7c <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800048da:	e2843b83          	ld	s7,-472(s0)
    800048de:	e2042c03          	lw	s8,-480(s0)
    800048e2:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800048e6:	00098463          	beqz	s3,800048ee <kexec+0x196>
    800048ea:	4901                	li	s2,0
    800048ec:	bfa1                	j	80004844 <kexec+0xec>
    sz = sz1;
    800048ee:	e0843903          	ld	s2,-504(s0)
    800048f2:	bfa5                	j	8000486a <kexec+0x112>
    800048f4:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800048f6:	8552                	mv	a0,s4
    800048f8:	c6dfe0ef          	jal	80003564 <iunlockput>
  end_op();
    800048fc:	cb2ff0ef          	jal	80003dae <end_op>
  p = myproc();
    80004900:	fe3fc0ef          	jal	800018e2 <myproc>
    80004904:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004906:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000490a:	6985                	lui	s3,0x1
    8000490c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000490e:	99ca                	add	s3,s3,s2
    80004910:	77fd                	lui	a5,0xfffff
    80004912:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004916:	4691                	li	a3,4
    80004918:	6609                	lui	a2,0x2
    8000491a:	964e                	add	a2,a2,s3
    8000491c:	85ce                	mv	a1,s3
    8000491e:	855a                	mv	a0,s6
    80004920:	969fc0ef          	jal	80001288 <uvmalloc>
    80004924:	892a                	mv	s2,a0
    80004926:	e0a43423          	sd	a0,-504(s0)
    8000492a:	e519                	bnez	a0,80004938 <kexec+0x1e0>
  if(pagetable)
    8000492c:	e1343423          	sd	s3,-504(s0)
    80004930:	4a01                	li	s4,0
    80004932:	aab1                	j	80004a8e <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004934:	4901                	li	s2,0
    80004936:	b7c1                	j	800048f6 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004938:	75f9                	lui	a1,0xffffe
    8000493a:	95aa                	add	a1,a1,a0
    8000493c:	855a                	mv	a0,s6
    8000493e:	b21fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004942:	7bfd                	lui	s7,0xfffff
    80004944:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004946:	e0043783          	ld	a5,-512(s0)
    8000494a:	6388                	ld	a0,0(a5)
    8000494c:	cd39                	beqz	a0,800049aa <kexec+0x252>
    8000494e:	e9040993          	addi	s3,s0,-368
    80004952:	f9040c13          	addi	s8,s0,-112
    80004956:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004958:	cbafc0ef          	jal	80000e12 <strlen>
    8000495c:	0015079b          	addiw	a5,a0,1
    80004960:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004964:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004968:	11796e63          	bltu	s2,s7,80004a84 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000496c:	e0043d03          	ld	s10,-512(s0)
    80004970:	000d3a03          	ld	s4,0(s10)
    80004974:	8552                	mv	a0,s4
    80004976:	c9cfc0ef          	jal	80000e12 <strlen>
    8000497a:	0015069b          	addiw	a3,a0,1
    8000497e:	8652                	mv	a2,s4
    80004980:	85ca                	mv	a1,s2
    80004982:	855a                	mv	a0,s6
    80004984:	c5ffc0ef          	jal	800015e2 <copyout>
    80004988:	10054063          	bltz	a0,80004a88 <kexec+0x330>
    ustack[argc] = sp;
    8000498c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004990:	0485                	addi	s1,s1,1
    80004992:	008d0793          	addi	a5,s10,8
    80004996:	e0f43023          	sd	a5,-512(s0)
    8000499a:	008d3503          	ld	a0,8(s10)
    8000499e:	c909                	beqz	a0,800049b0 <kexec+0x258>
    if(argc >= MAXARG)
    800049a0:	09a1                	addi	s3,s3,8
    800049a2:	fb899be3          	bne	s3,s8,80004958 <kexec+0x200>
  ip = 0;
    800049a6:	4a01                	li	s4,0
    800049a8:	a0dd                	j	80004a8e <kexec+0x336>
  sp = sz;
    800049aa:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800049ae:	4481                	li	s1,0
  ustack[argc] = 0;
    800049b0:	00349793          	slli	a5,s1,0x3
    800049b4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb5f0>
    800049b8:	97a2                	add	a5,a5,s0
    800049ba:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800049be:	00148693          	addi	a3,s1,1
    800049c2:	068e                	slli	a3,a3,0x3
    800049c4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800049c8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800049cc:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800049d0:	f5796ee3          	bltu	s2,s7,8000492c <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800049d4:	e9040613          	addi	a2,s0,-368
    800049d8:	85ca                	mv	a1,s2
    800049da:	855a                	mv	a0,s6
    800049dc:	c07fc0ef          	jal	800015e2 <copyout>
    800049e0:	0e054263          	bltz	a0,80004ac4 <kexec+0x36c>
  p->trapframe->a1 = sp;
    800049e4:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800049e8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800049ec:	df843783          	ld	a5,-520(s0)
    800049f0:	0007c703          	lbu	a4,0(a5)
    800049f4:	cf11                	beqz	a4,80004a10 <kexec+0x2b8>
    800049f6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049f8:	02f00693          	li	a3,47
    800049fc:	a039                	j	80004a0a <kexec+0x2b2>
      last = s+1;
    800049fe:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004a02:	0785                	addi	a5,a5,1
    80004a04:	fff7c703          	lbu	a4,-1(a5)
    80004a08:	c701                	beqz	a4,80004a10 <kexec+0x2b8>
    if(*s == '/')
    80004a0a:	fed71ce3          	bne	a4,a3,80004a02 <kexec+0x2aa>
    80004a0e:	bfc5                	j	800049fe <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004a10:	4641                	li	a2,16
    80004a12:	df843583          	ld	a1,-520(s0)
    80004a16:	158a8513          	addi	a0,s5,344
    80004a1a:	bc6fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a1e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004a22:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004a26:	e0843783          	ld	a5,-504(s0)
    80004a2a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004a2e:	058ab783          	ld	a5,88(s5)
    80004a32:	e6843703          	ld	a4,-408(s0)
    80004a36:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a38:	058ab783          	ld	a5,88(s5)
    80004a3c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a40:	85e6                	mv	a1,s9
    80004a42:	82afd0ef          	jal	80001a6c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a46:	0004851b          	sext.w	a0,s1
    80004a4a:	79be                	ld	s3,488(sp)
    80004a4c:	7a1e                	ld	s4,480(sp)
    80004a4e:	6afe                	ld	s5,472(sp)
    80004a50:	6b5e                	ld	s6,464(sp)
    80004a52:	6bbe                	ld	s7,456(sp)
    80004a54:	6c1e                	ld	s8,448(sp)
    80004a56:	7cfa                	ld	s9,440(sp)
    80004a58:	7d5a                	ld	s10,432(sp)
    80004a5a:	b3b5                	j	800047c6 <kexec+0x6e>
    80004a5c:	e1243423          	sd	s2,-504(s0)
    80004a60:	7dba                	ld	s11,424(sp)
    80004a62:	a035                	j	80004a8e <kexec+0x336>
    80004a64:	e1243423          	sd	s2,-504(s0)
    80004a68:	7dba                	ld	s11,424(sp)
    80004a6a:	a015                	j	80004a8e <kexec+0x336>
    80004a6c:	e1243423          	sd	s2,-504(s0)
    80004a70:	7dba                	ld	s11,424(sp)
    80004a72:	a831                	j	80004a8e <kexec+0x336>
    80004a74:	e1243423          	sd	s2,-504(s0)
    80004a78:	7dba                	ld	s11,424(sp)
    80004a7a:	a811                	j	80004a8e <kexec+0x336>
    80004a7c:	e1243423          	sd	s2,-504(s0)
    80004a80:	7dba                	ld	s11,424(sp)
    80004a82:	a031                	j	80004a8e <kexec+0x336>
  ip = 0;
    80004a84:	4a01                	li	s4,0
    80004a86:	a021                	j	80004a8e <kexec+0x336>
    80004a88:	4a01                	li	s4,0
  if(pagetable)
    80004a8a:	a011                	j	80004a8e <kexec+0x336>
    80004a8c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004a8e:	e0843583          	ld	a1,-504(s0)
    80004a92:	855a                	mv	a0,s6
    80004a94:	fd9fc0ef          	jal	80001a6c <proc_freepagetable>
  return -1;
    80004a98:	557d                	li	a0,-1
  if(ip){
    80004a9a:	000a1b63          	bnez	s4,80004ab0 <kexec+0x358>
    80004a9e:	79be                	ld	s3,488(sp)
    80004aa0:	7a1e                	ld	s4,480(sp)
    80004aa2:	6afe                	ld	s5,472(sp)
    80004aa4:	6b5e                	ld	s6,464(sp)
    80004aa6:	6bbe                	ld	s7,456(sp)
    80004aa8:	6c1e                	ld	s8,448(sp)
    80004aaa:	7cfa                	ld	s9,440(sp)
    80004aac:	7d5a                	ld	s10,432(sp)
    80004aae:	bb21                	j	800047c6 <kexec+0x6e>
    80004ab0:	79be                	ld	s3,488(sp)
    80004ab2:	6afe                	ld	s5,472(sp)
    80004ab4:	6b5e                	ld	s6,464(sp)
    80004ab6:	6bbe                	ld	s7,456(sp)
    80004ab8:	6c1e                	ld	s8,448(sp)
    80004aba:	7cfa                	ld	s9,440(sp)
    80004abc:	7d5a                	ld	s10,432(sp)
    80004abe:	b9ed                	j	800047b8 <kexec+0x60>
    80004ac0:	6b5e                	ld	s6,464(sp)
    80004ac2:	b9dd                	j	800047b8 <kexec+0x60>
  sz = sz1;
    80004ac4:	e0843983          	ld	s3,-504(s0)
    80004ac8:	b595                	j	8000492c <kexec+0x1d4>

0000000080004aca <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004aca:	7179                	addi	sp,sp,-48
    80004acc:	f406                	sd	ra,40(sp)
    80004ace:	f022                	sd	s0,32(sp)
    80004ad0:	ec26                	sd	s1,24(sp)
    80004ad2:	e84a                	sd	s2,16(sp)
    80004ad4:	1800                	addi	s0,sp,48
    80004ad6:	892e                	mv	s2,a1
    80004ad8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ada:	fdc40593          	addi	a1,s0,-36
    80004ade:	e0ffd0ef          	jal	800028ec <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ae2:	fdc42703          	lw	a4,-36(s0)
    80004ae6:	47bd                	li	a5,15
    80004ae8:	02e7e963          	bltu	a5,a4,80004b1a <argfd+0x50>
    80004aec:	df7fc0ef          	jal	800018e2 <myproc>
    80004af0:	fdc42703          	lw	a4,-36(s0)
    80004af4:	01a70793          	addi	a5,a4,26
    80004af8:	078e                	slli	a5,a5,0x3
    80004afa:	953e                	add	a0,a0,a5
    80004afc:	611c                	ld	a5,0(a0)
    80004afe:	c385                	beqz	a5,80004b1e <argfd+0x54>
    return -1;
  if(pfd)
    80004b00:	00090463          	beqz	s2,80004b08 <argfd+0x3e>
    *pfd = fd;
    80004b04:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004b08:	4501                	li	a0,0
  if(pf)
    80004b0a:	c091                	beqz	s1,80004b0e <argfd+0x44>
    *pf = f;
    80004b0c:	e09c                	sd	a5,0(s1)
}
    80004b0e:	70a2                	ld	ra,40(sp)
    80004b10:	7402                	ld	s0,32(sp)
    80004b12:	64e2                	ld	s1,24(sp)
    80004b14:	6942                	ld	s2,16(sp)
    80004b16:	6145                	addi	sp,sp,48
    80004b18:	8082                	ret
    return -1;
    80004b1a:	557d                	li	a0,-1
    80004b1c:	bfcd                	j	80004b0e <argfd+0x44>
    80004b1e:	557d                	li	a0,-1
    80004b20:	b7fd                	j	80004b0e <argfd+0x44>

0000000080004b22 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b22:	1101                	addi	sp,sp,-32
    80004b24:	ec06                	sd	ra,24(sp)
    80004b26:	e822                	sd	s0,16(sp)
    80004b28:	e426                	sd	s1,8(sp)
    80004b2a:	1000                	addi	s0,sp,32
    80004b2c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b2e:	db5fc0ef          	jal	800018e2 <myproc>
    80004b32:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b34:	0d050793          	addi	a5,a0,208
    80004b38:	4501                	li	a0,0
    80004b3a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b3c:	6398                	ld	a4,0(a5)
    80004b3e:	cb19                	beqz	a4,80004b54 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b40:	2505                	addiw	a0,a0,1
    80004b42:	07a1                	addi	a5,a5,8
    80004b44:	fed51ce3          	bne	a0,a3,80004b3c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b48:	557d                	li	a0,-1
}
    80004b4a:	60e2                	ld	ra,24(sp)
    80004b4c:	6442                	ld	s0,16(sp)
    80004b4e:	64a2                	ld	s1,8(sp)
    80004b50:	6105                	addi	sp,sp,32
    80004b52:	8082                	ret
      p->ofile[fd] = f;
    80004b54:	01a50793          	addi	a5,a0,26
    80004b58:	078e                	slli	a5,a5,0x3
    80004b5a:	963e                	add	a2,a2,a5
    80004b5c:	e204                	sd	s1,0(a2)
      return fd;
    80004b5e:	b7f5                	j	80004b4a <fdalloc+0x28>

0000000080004b60 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b60:	715d                	addi	sp,sp,-80
    80004b62:	e486                	sd	ra,72(sp)
    80004b64:	e0a2                	sd	s0,64(sp)
    80004b66:	fc26                	sd	s1,56(sp)
    80004b68:	f84a                	sd	s2,48(sp)
    80004b6a:	f44e                	sd	s3,40(sp)
    80004b6c:	ec56                	sd	s5,24(sp)
    80004b6e:	e85a                	sd	s6,16(sp)
    80004b70:	0880                	addi	s0,sp,80
    80004b72:	8b2e                	mv	s6,a1
    80004b74:	89b2                	mv	s3,a2
    80004b76:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b78:	fb040593          	addi	a1,s0,-80
    80004b7c:	80eff0ef          	jal	80003b8a <nameiparent>
    80004b80:	84aa                	mv	s1,a0
    80004b82:	10050a63          	beqz	a0,80004c96 <create+0x136>
    return 0;

  ilock(dp);
    80004b86:	fd4fe0ef          	jal	8000335a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b8a:	4601                	li	a2,0
    80004b8c:	fb040593          	addi	a1,s0,-80
    80004b90:	8526                	mv	a0,s1
    80004b92:	d79fe0ef          	jal	8000390a <dirlookup>
    80004b96:	8aaa                	mv	s5,a0
    80004b98:	c129                	beqz	a0,80004bda <create+0x7a>
    iunlockput(dp);
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	9c9fe0ef          	jal	80003564 <iunlockput>
    ilock(ip);
    80004ba0:	8556                	mv	a0,s5
    80004ba2:	fb8fe0ef          	jal	8000335a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ba6:	4789                	li	a5,2
    80004ba8:	02fb1463          	bne	s6,a5,80004bd0 <create+0x70>
    80004bac:	044ad783          	lhu	a5,68(s5)
    80004bb0:	37f9                	addiw	a5,a5,-2
    80004bb2:	17c2                	slli	a5,a5,0x30
    80004bb4:	93c1                	srli	a5,a5,0x30
    80004bb6:	4705                	li	a4,1
    80004bb8:	00f76c63          	bltu	a4,a5,80004bd0 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004bbc:	8556                	mv	a0,s5
    80004bbe:	60a6                	ld	ra,72(sp)
    80004bc0:	6406                	ld	s0,64(sp)
    80004bc2:	74e2                	ld	s1,56(sp)
    80004bc4:	7942                	ld	s2,48(sp)
    80004bc6:	79a2                	ld	s3,40(sp)
    80004bc8:	6ae2                	ld	s5,24(sp)
    80004bca:	6b42                	ld	s6,16(sp)
    80004bcc:	6161                	addi	sp,sp,80
    80004bce:	8082                	ret
    iunlockput(ip);
    80004bd0:	8556                	mv	a0,s5
    80004bd2:	993fe0ef          	jal	80003564 <iunlockput>
    return 0;
    80004bd6:	4a81                	li	s5,0
    80004bd8:	b7d5                	j	80004bbc <create+0x5c>
    80004bda:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004bdc:	85da                	mv	a1,s6
    80004bde:	4088                	lw	a0,0(s1)
    80004be0:	e0afe0ef          	jal	800031ea <ialloc>
    80004be4:	8a2a                	mv	s4,a0
    80004be6:	cd15                	beqz	a0,80004c22 <create+0xc2>
  ilock(ip);
    80004be8:	f72fe0ef          	jal	8000335a <ilock>
  ip->major = major;
    80004bec:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004bf0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004bf4:	4905                	li	s2,1
    80004bf6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004bfa:	8552                	mv	a0,s4
    80004bfc:	eaafe0ef          	jal	800032a6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004c00:	032b0763          	beq	s6,s2,80004c2e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c04:	004a2603          	lw	a2,4(s4)
    80004c08:	fb040593          	addi	a1,s0,-80
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	ec9fe0ef          	jal	80003ad6 <dirlink>
    80004c12:	06054563          	bltz	a0,80004c7c <create+0x11c>
  iunlockput(dp);
    80004c16:	8526                	mv	a0,s1
    80004c18:	94dfe0ef          	jal	80003564 <iunlockput>
  return ip;
    80004c1c:	8ad2                	mv	s5,s4
    80004c1e:	7a02                	ld	s4,32(sp)
    80004c20:	bf71                	j	80004bbc <create+0x5c>
    iunlockput(dp);
    80004c22:	8526                	mv	a0,s1
    80004c24:	941fe0ef          	jal	80003564 <iunlockput>
    return 0;
    80004c28:	8ad2                	mv	s5,s4
    80004c2a:	7a02                	ld	s4,32(sp)
    80004c2c:	bf41                	j	80004bbc <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c2e:	004a2603          	lw	a2,4(s4)
    80004c32:	00003597          	auipc	a1,0x3
    80004c36:	99658593          	addi	a1,a1,-1642 # 800075c8 <etext+0x5c8>
    80004c3a:	8552                	mv	a0,s4
    80004c3c:	e9bfe0ef          	jal	80003ad6 <dirlink>
    80004c40:	02054e63          	bltz	a0,80004c7c <create+0x11c>
    80004c44:	40d0                	lw	a2,4(s1)
    80004c46:	00003597          	auipc	a1,0x3
    80004c4a:	98a58593          	addi	a1,a1,-1654 # 800075d0 <etext+0x5d0>
    80004c4e:	8552                	mv	a0,s4
    80004c50:	e87fe0ef          	jal	80003ad6 <dirlink>
    80004c54:	02054463          	bltz	a0,80004c7c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c58:	004a2603          	lw	a2,4(s4)
    80004c5c:	fb040593          	addi	a1,s0,-80
    80004c60:	8526                	mv	a0,s1
    80004c62:	e75fe0ef          	jal	80003ad6 <dirlink>
    80004c66:	00054b63          	bltz	a0,80004c7c <create+0x11c>
    dp->nlink++;  // for ".."
    80004c6a:	04a4d783          	lhu	a5,74(s1)
    80004c6e:	2785                	addiw	a5,a5,1
    80004c70:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c74:	8526                	mv	a0,s1
    80004c76:	e30fe0ef          	jal	800032a6 <iupdate>
    80004c7a:	bf71                	j	80004c16 <create+0xb6>
  ip->nlink = 0;
    80004c7c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c80:	8552                	mv	a0,s4
    80004c82:	e24fe0ef          	jal	800032a6 <iupdate>
  iunlockput(ip);
    80004c86:	8552                	mv	a0,s4
    80004c88:	8ddfe0ef          	jal	80003564 <iunlockput>
  iunlockput(dp);
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	8d7fe0ef          	jal	80003564 <iunlockput>
  return 0;
    80004c92:	7a02                	ld	s4,32(sp)
    80004c94:	b725                	j	80004bbc <create+0x5c>
    return 0;
    80004c96:	8aaa                	mv	s5,a0
    80004c98:	b715                	j	80004bbc <create+0x5c>

0000000080004c9a <sys_dup>:
{
    80004c9a:	7179                	addi	sp,sp,-48
    80004c9c:	f406                	sd	ra,40(sp)
    80004c9e:	f022                	sd	s0,32(sp)
    80004ca0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004ca2:	fd840613          	addi	a2,s0,-40
    80004ca6:	4581                	li	a1,0
    80004ca8:	4501                	li	a0,0
    80004caa:	e21ff0ef          	jal	80004aca <argfd>
    return -1;
    80004cae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004cb0:	02054363          	bltz	a0,80004cd6 <sys_dup+0x3c>
    80004cb4:	ec26                	sd	s1,24(sp)
    80004cb6:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004cb8:	fd843903          	ld	s2,-40(s0)
    80004cbc:	854a                	mv	a0,s2
    80004cbe:	e65ff0ef          	jal	80004b22 <fdalloc>
    80004cc2:	84aa                	mv	s1,a0
    return -1;
    80004cc4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004cc6:	00054d63          	bltz	a0,80004ce0 <sys_dup+0x46>
  filedup(f);
    80004cca:	854a                	mv	a0,s2
    80004ccc:	c3eff0ef          	jal	8000410a <filedup>
  return fd;
    80004cd0:	87a6                	mv	a5,s1
    80004cd2:	64e2                	ld	s1,24(sp)
    80004cd4:	6942                	ld	s2,16(sp)
}
    80004cd6:	853e                	mv	a0,a5
    80004cd8:	70a2                	ld	ra,40(sp)
    80004cda:	7402                	ld	s0,32(sp)
    80004cdc:	6145                	addi	sp,sp,48
    80004cde:	8082                	ret
    80004ce0:	64e2                	ld	s1,24(sp)
    80004ce2:	6942                	ld	s2,16(sp)
    80004ce4:	bfcd                	j	80004cd6 <sys_dup+0x3c>

0000000080004ce6 <sys_read>:
{
    80004ce6:	7179                	addi	sp,sp,-48
    80004ce8:	f406                	sd	ra,40(sp)
    80004cea:	f022                	sd	s0,32(sp)
    80004cec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cee:	fd840593          	addi	a1,s0,-40
    80004cf2:	4505                	li	a0,1
    80004cf4:	c15fd0ef          	jal	80002908 <argaddr>
  argint(2, &n);
    80004cf8:	fe440593          	addi	a1,s0,-28
    80004cfc:	4509                	li	a0,2
    80004cfe:	beffd0ef          	jal	800028ec <argint>
  if(argfd(0, 0, &f) < 0)
    80004d02:	fe840613          	addi	a2,s0,-24
    80004d06:	4581                	li	a1,0
    80004d08:	4501                	li	a0,0
    80004d0a:	dc1ff0ef          	jal	80004aca <argfd>
    80004d0e:	87aa                	mv	a5,a0
    return -1;
    80004d10:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d12:	0007ca63          	bltz	a5,80004d26 <sys_read+0x40>
  return fileread(f, p, n);
    80004d16:	fe442603          	lw	a2,-28(s0)
    80004d1a:	fd843583          	ld	a1,-40(s0)
    80004d1e:	fe843503          	ld	a0,-24(s0)
    80004d22:	d4eff0ef          	jal	80004270 <fileread>
}
    80004d26:	70a2                	ld	ra,40(sp)
    80004d28:	7402                	ld	s0,32(sp)
    80004d2a:	6145                	addi	sp,sp,48
    80004d2c:	8082                	ret

0000000080004d2e <sys_write>:
{
    80004d2e:	7179                	addi	sp,sp,-48
    80004d30:	f406                	sd	ra,40(sp)
    80004d32:	f022                	sd	s0,32(sp)
    80004d34:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d36:	fd840593          	addi	a1,s0,-40
    80004d3a:	4505                	li	a0,1
    80004d3c:	bcdfd0ef          	jal	80002908 <argaddr>
  argint(2, &n);
    80004d40:	fe440593          	addi	a1,s0,-28
    80004d44:	4509                	li	a0,2
    80004d46:	ba7fd0ef          	jal	800028ec <argint>
  if(argfd(0, 0, &f) < 0)
    80004d4a:	fe840613          	addi	a2,s0,-24
    80004d4e:	4581                	li	a1,0
    80004d50:	4501                	li	a0,0
    80004d52:	d79ff0ef          	jal	80004aca <argfd>
    80004d56:	87aa                	mv	a5,a0
    return -1;
    80004d58:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d5a:	0007ca63          	bltz	a5,80004d6e <sys_write+0x40>
  return filewrite(f, p, n);
    80004d5e:	fe442603          	lw	a2,-28(s0)
    80004d62:	fd843583          	ld	a1,-40(s0)
    80004d66:	fe843503          	ld	a0,-24(s0)
    80004d6a:	dc4ff0ef          	jal	8000432e <filewrite>
}
    80004d6e:	70a2                	ld	ra,40(sp)
    80004d70:	7402                	ld	s0,32(sp)
    80004d72:	6145                	addi	sp,sp,48
    80004d74:	8082                	ret

0000000080004d76 <sys_close>:
{
    80004d76:	1101                	addi	sp,sp,-32
    80004d78:	ec06                	sd	ra,24(sp)
    80004d7a:	e822                	sd	s0,16(sp)
    80004d7c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d7e:	fe040613          	addi	a2,s0,-32
    80004d82:	fec40593          	addi	a1,s0,-20
    80004d86:	4501                	li	a0,0
    80004d88:	d43ff0ef          	jal	80004aca <argfd>
    return -1;
    80004d8c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d8e:	02054063          	bltz	a0,80004dae <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d92:	b51fc0ef          	jal	800018e2 <myproc>
    80004d96:	fec42783          	lw	a5,-20(s0)
    80004d9a:	07e9                	addi	a5,a5,26
    80004d9c:	078e                	slli	a5,a5,0x3
    80004d9e:	953e                	add	a0,a0,a5
    80004da0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004da4:	fe043503          	ld	a0,-32(s0)
    80004da8:	ba8ff0ef          	jal	80004150 <fileclose>
  return 0;
    80004dac:	4781                	li	a5,0
}
    80004dae:	853e                	mv	a0,a5
    80004db0:	60e2                	ld	ra,24(sp)
    80004db2:	6442                	ld	s0,16(sp)
    80004db4:	6105                	addi	sp,sp,32
    80004db6:	8082                	ret

0000000080004db8 <sys_fstat>:
{
    80004db8:	1101                	addi	sp,sp,-32
    80004dba:	ec06                	sd	ra,24(sp)
    80004dbc:	e822                	sd	s0,16(sp)
    80004dbe:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004dc0:	fe040593          	addi	a1,s0,-32
    80004dc4:	4505                	li	a0,1
    80004dc6:	b43fd0ef          	jal	80002908 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004dca:	fe840613          	addi	a2,s0,-24
    80004dce:	4581                	li	a1,0
    80004dd0:	4501                	li	a0,0
    80004dd2:	cf9ff0ef          	jal	80004aca <argfd>
    80004dd6:	87aa                	mv	a5,a0
    return -1;
    80004dd8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dda:	0007c863          	bltz	a5,80004dea <sys_fstat+0x32>
  return filestat(f, st);
    80004dde:	fe043583          	ld	a1,-32(s0)
    80004de2:	fe843503          	ld	a0,-24(s0)
    80004de6:	c2cff0ef          	jal	80004212 <filestat>
}
    80004dea:	60e2                	ld	ra,24(sp)
    80004dec:	6442                	ld	s0,16(sp)
    80004dee:	6105                	addi	sp,sp,32
    80004df0:	8082                	ret

0000000080004df2 <sys_link>:
{
    80004df2:	7169                	addi	sp,sp,-304
    80004df4:	f606                	sd	ra,296(sp)
    80004df6:	f222                	sd	s0,288(sp)
    80004df8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dfa:	08000613          	li	a2,128
    80004dfe:	ed040593          	addi	a1,s0,-304
    80004e02:	4501                	li	a0,0
    80004e04:	b21fd0ef          	jal	80002924 <argstr>
    return -1;
    80004e08:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e0a:	0c054e63          	bltz	a0,80004ee6 <sys_link+0xf4>
    80004e0e:	08000613          	li	a2,128
    80004e12:	f5040593          	addi	a1,s0,-176
    80004e16:	4505                	li	a0,1
    80004e18:	b0dfd0ef          	jal	80002924 <argstr>
    return -1;
    80004e1c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e1e:	0c054463          	bltz	a0,80004ee6 <sys_link+0xf4>
    80004e22:	ee26                	sd	s1,280(sp)
  begin_op();
    80004e24:	f21fe0ef          	jal	80003d44 <begin_op>
  if((ip = namei(old)) == 0){
    80004e28:	ed040513          	addi	a0,s0,-304
    80004e2c:	d45fe0ef          	jal	80003b70 <namei>
    80004e30:	84aa                	mv	s1,a0
    80004e32:	c53d                	beqz	a0,80004ea0 <sys_link+0xae>
  ilock(ip);
    80004e34:	d26fe0ef          	jal	8000335a <ilock>
  if(ip->type == T_DIR){
    80004e38:	04449703          	lh	a4,68(s1)
    80004e3c:	4785                	li	a5,1
    80004e3e:	06f70663          	beq	a4,a5,80004eaa <sys_link+0xb8>
    80004e42:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004e44:	04a4d783          	lhu	a5,74(s1)
    80004e48:	2785                	addiw	a5,a5,1
    80004e4a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	c56fe0ef          	jal	800032a6 <iupdate>
  iunlock(ip);
    80004e54:	8526                	mv	a0,s1
    80004e56:	db2fe0ef          	jal	80003408 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004e5a:	fd040593          	addi	a1,s0,-48
    80004e5e:	f5040513          	addi	a0,s0,-176
    80004e62:	d29fe0ef          	jal	80003b8a <nameiparent>
    80004e66:	892a                	mv	s2,a0
    80004e68:	cd21                	beqz	a0,80004ec0 <sys_link+0xce>
  ilock(dp);
    80004e6a:	cf0fe0ef          	jal	8000335a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e6e:	00092703          	lw	a4,0(s2)
    80004e72:	409c                	lw	a5,0(s1)
    80004e74:	04f71363          	bne	a4,a5,80004eba <sys_link+0xc8>
    80004e78:	40d0                	lw	a2,4(s1)
    80004e7a:	fd040593          	addi	a1,s0,-48
    80004e7e:	854a                	mv	a0,s2
    80004e80:	c57fe0ef          	jal	80003ad6 <dirlink>
    80004e84:	02054b63          	bltz	a0,80004eba <sys_link+0xc8>
  iunlockput(dp);
    80004e88:	854a                	mv	a0,s2
    80004e8a:	edafe0ef          	jal	80003564 <iunlockput>
  iput(ip);
    80004e8e:	8526                	mv	a0,s1
    80004e90:	e4cfe0ef          	jal	800034dc <iput>
  end_op();
    80004e94:	f1bfe0ef          	jal	80003dae <end_op>
  return 0;
    80004e98:	4781                	li	a5,0
    80004e9a:	64f2                	ld	s1,280(sp)
    80004e9c:	6952                	ld	s2,272(sp)
    80004e9e:	a0a1                	j	80004ee6 <sys_link+0xf4>
    end_op();
    80004ea0:	f0ffe0ef          	jal	80003dae <end_op>
    return -1;
    80004ea4:	57fd                	li	a5,-1
    80004ea6:	64f2                	ld	s1,280(sp)
    80004ea8:	a83d                	j	80004ee6 <sys_link+0xf4>
    iunlockput(ip);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	eb8fe0ef          	jal	80003564 <iunlockput>
    end_op();
    80004eb0:	efffe0ef          	jal	80003dae <end_op>
    return -1;
    80004eb4:	57fd                	li	a5,-1
    80004eb6:	64f2                	ld	s1,280(sp)
    80004eb8:	a03d                	j	80004ee6 <sys_link+0xf4>
    iunlockput(dp);
    80004eba:	854a                	mv	a0,s2
    80004ebc:	ea8fe0ef          	jal	80003564 <iunlockput>
  ilock(ip);
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	c98fe0ef          	jal	8000335a <ilock>
  ip->nlink--;
    80004ec6:	04a4d783          	lhu	a5,74(s1)
    80004eca:	37fd                	addiw	a5,a5,-1
    80004ecc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	bd4fe0ef          	jal	800032a6 <iupdate>
  iunlockput(ip);
    80004ed6:	8526                	mv	a0,s1
    80004ed8:	e8cfe0ef          	jal	80003564 <iunlockput>
  end_op();
    80004edc:	ed3fe0ef          	jal	80003dae <end_op>
  return -1;
    80004ee0:	57fd                	li	a5,-1
    80004ee2:	64f2                	ld	s1,280(sp)
    80004ee4:	6952                	ld	s2,272(sp)
}
    80004ee6:	853e                	mv	a0,a5
    80004ee8:	70b2                	ld	ra,296(sp)
    80004eea:	7412                	ld	s0,288(sp)
    80004eec:	6155                	addi	sp,sp,304
    80004eee:	8082                	ret

0000000080004ef0 <sys_unlink>:
{
    80004ef0:	7151                	addi	sp,sp,-240
    80004ef2:	f586                	sd	ra,232(sp)
    80004ef4:	f1a2                	sd	s0,224(sp)
    80004ef6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004ef8:	08000613          	li	a2,128
    80004efc:	f3040593          	addi	a1,s0,-208
    80004f00:	4501                	li	a0,0
    80004f02:	a23fd0ef          	jal	80002924 <argstr>
    80004f06:	16054063          	bltz	a0,80005066 <sys_unlink+0x176>
    80004f0a:	eda6                	sd	s1,216(sp)
  begin_op();
    80004f0c:	e39fe0ef          	jal	80003d44 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004f10:	fb040593          	addi	a1,s0,-80
    80004f14:	f3040513          	addi	a0,s0,-208
    80004f18:	c73fe0ef          	jal	80003b8a <nameiparent>
    80004f1c:	84aa                	mv	s1,a0
    80004f1e:	c945                	beqz	a0,80004fce <sys_unlink+0xde>
  ilock(dp);
    80004f20:	c3afe0ef          	jal	8000335a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f24:	00002597          	auipc	a1,0x2
    80004f28:	6a458593          	addi	a1,a1,1700 # 800075c8 <etext+0x5c8>
    80004f2c:	fb040513          	addi	a0,s0,-80
    80004f30:	9c5fe0ef          	jal	800038f4 <namecmp>
    80004f34:	10050e63          	beqz	a0,80005050 <sys_unlink+0x160>
    80004f38:	00002597          	auipc	a1,0x2
    80004f3c:	69858593          	addi	a1,a1,1688 # 800075d0 <etext+0x5d0>
    80004f40:	fb040513          	addi	a0,s0,-80
    80004f44:	9b1fe0ef          	jal	800038f4 <namecmp>
    80004f48:	10050463          	beqz	a0,80005050 <sys_unlink+0x160>
    80004f4c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004f4e:	f2c40613          	addi	a2,s0,-212
    80004f52:	fb040593          	addi	a1,s0,-80
    80004f56:	8526                	mv	a0,s1
    80004f58:	9b3fe0ef          	jal	8000390a <dirlookup>
    80004f5c:	892a                	mv	s2,a0
    80004f5e:	0e050863          	beqz	a0,8000504e <sys_unlink+0x15e>
  ilock(ip);
    80004f62:	bf8fe0ef          	jal	8000335a <ilock>
  if(ip->nlink < 1)
    80004f66:	04a91783          	lh	a5,74(s2)
    80004f6a:	06f05763          	blez	a5,80004fd8 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f6e:	04491703          	lh	a4,68(s2)
    80004f72:	4785                	li	a5,1
    80004f74:	06f70963          	beq	a4,a5,80004fe6 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004f78:	4641                	li	a2,16
    80004f7a:	4581                	li	a1,0
    80004f7c:	fc040513          	addi	a0,s0,-64
    80004f80:	d23fb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f84:	4741                	li	a4,16
    80004f86:	f2c42683          	lw	a3,-212(s0)
    80004f8a:	fc040613          	addi	a2,s0,-64
    80004f8e:	4581                	li	a1,0
    80004f90:	8526                	mv	a0,s1
    80004f92:	855fe0ef          	jal	800037e6 <writei>
    80004f96:	47c1                	li	a5,16
    80004f98:	08f51b63          	bne	a0,a5,8000502e <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004f9c:	04491703          	lh	a4,68(s2)
    80004fa0:	4785                	li	a5,1
    80004fa2:	08f70d63          	beq	a4,a5,8000503c <sys_unlink+0x14c>
  iunlockput(dp);
    80004fa6:	8526                	mv	a0,s1
    80004fa8:	dbcfe0ef          	jal	80003564 <iunlockput>
  ip->nlink--;
    80004fac:	04a95783          	lhu	a5,74(s2)
    80004fb0:	37fd                	addiw	a5,a5,-1
    80004fb2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004fb6:	854a                	mv	a0,s2
    80004fb8:	aeefe0ef          	jal	800032a6 <iupdate>
  iunlockput(ip);
    80004fbc:	854a                	mv	a0,s2
    80004fbe:	da6fe0ef          	jal	80003564 <iunlockput>
  end_op();
    80004fc2:	dedfe0ef          	jal	80003dae <end_op>
  return 0;
    80004fc6:	4501                	li	a0,0
    80004fc8:	64ee                	ld	s1,216(sp)
    80004fca:	694e                	ld	s2,208(sp)
    80004fcc:	a849                	j	8000505e <sys_unlink+0x16e>
    end_op();
    80004fce:	de1fe0ef          	jal	80003dae <end_op>
    return -1;
    80004fd2:	557d                	li	a0,-1
    80004fd4:	64ee                	ld	s1,216(sp)
    80004fd6:	a061                	j	8000505e <sys_unlink+0x16e>
    80004fd8:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004fda:	00002517          	auipc	a0,0x2
    80004fde:	5fe50513          	addi	a0,a0,1534 # 800075d8 <etext+0x5d8>
    80004fe2:	ffefb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fe6:	04c92703          	lw	a4,76(s2)
    80004fea:	02000793          	li	a5,32
    80004fee:	f8e7f5e3          	bgeu	a5,a4,80004f78 <sys_unlink+0x88>
    80004ff2:	e5ce                	sd	s3,200(sp)
    80004ff4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ff8:	4741                	li	a4,16
    80004ffa:	86ce                	mv	a3,s3
    80004ffc:	f1840613          	addi	a2,s0,-232
    80005000:	4581                	li	a1,0
    80005002:	854a                	mv	a0,s2
    80005004:	ee6fe0ef          	jal	800036ea <readi>
    80005008:	47c1                	li	a5,16
    8000500a:	00f51c63          	bne	a0,a5,80005022 <sys_unlink+0x132>
    if(de.inum != 0)
    8000500e:	f1845783          	lhu	a5,-232(s0)
    80005012:	efa1                	bnez	a5,8000506a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005014:	29c1                	addiw	s3,s3,16
    80005016:	04c92783          	lw	a5,76(s2)
    8000501a:	fcf9efe3          	bltu	s3,a5,80004ff8 <sys_unlink+0x108>
    8000501e:	69ae                	ld	s3,200(sp)
    80005020:	bfa1                	j	80004f78 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005022:	00002517          	auipc	a0,0x2
    80005026:	5ce50513          	addi	a0,a0,1486 # 800075f0 <etext+0x5f0>
    8000502a:	fb6fb0ef          	jal	800007e0 <panic>
    8000502e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005030:	00002517          	auipc	a0,0x2
    80005034:	5d850513          	addi	a0,a0,1496 # 80007608 <etext+0x608>
    80005038:	fa8fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    8000503c:	04a4d783          	lhu	a5,74(s1)
    80005040:	37fd                	addiw	a5,a5,-1
    80005042:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005046:	8526                	mv	a0,s1
    80005048:	a5efe0ef          	jal	800032a6 <iupdate>
    8000504c:	bfa9                	j	80004fa6 <sys_unlink+0xb6>
    8000504e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005050:	8526                	mv	a0,s1
    80005052:	d12fe0ef          	jal	80003564 <iunlockput>
  end_op();
    80005056:	d59fe0ef          	jal	80003dae <end_op>
  return -1;
    8000505a:	557d                	li	a0,-1
    8000505c:	64ee                	ld	s1,216(sp)
}
    8000505e:	70ae                	ld	ra,232(sp)
    80005060:	740e                	ld	s0,224(sp)
    80005062:	616d                	addi	sp,sp,240
    80005064:	8082                	ret
    return -1;
    80005066:	557d                	li	a0,-1
    80005068:	bfdd                	j	8000505e <sys_unlink+0x16e>
    iunlockput(ip);
    8000506a:	854a                	mv	a0,s2
    8000506c:	cf8fe0ef          	jal	80003564 <iunlockput>
    goto bad;
    80005070:	694e                	ld	s2,208(sp)
    80005072:	69ae                	ld	s3,200(sp)
    80005074:	bff1                	j	80005050 <sys_unlink+0x160>

0000000080005076 <sys_open>:

uint64
sys_open(void)
{
    80005076:	7131                	addi	sp,sp,-192
    80005078:	fd06                	sd	ra,184(sp)
    8000507a:	f922                	sd	s0,176(sp)
    8000507c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000507e:	f4c40593          	addi	a1,s0,-180
    80005082:	4505                	li	a0,1
    80005084:	869fd0ef          	jal	800028ec <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005088:	08000613          	li	a2,128
    8000508c:	f5040593          	addi	a1,s0,-176
    80005090:	4501                	li	a0,0
    80005092:	893fd0ef          	jal	80002924 <argstr>
    80005096:	87aa                	mv	a5,a0
    return -1;
    80005098:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000509a:	0a07c263          	bltz	a5,8000513e <sys_open+0xc8>
    8000509e:	f526                	sd	s1,168(sp)

  begin_op();
    800050a0:	ca5fe0ef          	jal	80003d44 <begin_op>

  if(omode & O_CREATE){
    800050a4:	f4c42783          	lw	a5,-180(s0)
    800050a8:	2007f793          	andi	a5,a5,512
    800050ac:	c3d5                	beqz	a5,80005150 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800050ae:	4681                	li	a3,0
    800050b0:	4601                	li	a2,0
    800050b2:	4589                	li	a1,2
    800050b4:	f5040513          	addi	a0,s0,-176
    800050b8:	aa9ff0ef          	jal	80004b60 <create>
    800050bc:	84aa                	mv	s1,a0
    if(ip == 0){
    800050be:	c541                	beqz	a0,80005146 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800050c0:	04449703          	lh	a4,68(s1)
    800050c4:	478d                	li	a5,3
    800050c6:	00f71763          	bne	a4,a5,800050d4 <sys_open+0x5e>
    800050ca:	0464d703          	lhu	a4,70(s1)
    800050ce:	47a5                	li	a5,9
    800050d0:	0ae7ed63          	bltu	a5,a4,8000518a <sys_open+0x114>
    800050d4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800050d6:	fd7fe0ef          	jal	800040ac <filealloc>
    800050da:	892a                	mv	s2,a0
    800050dc:	c179                	beqz	a0,800051a2 <sys_open+0x12c>
    800050de:	ed4e                	sd	s3,152(sp)
    800050e0:	a43ff0ef          	jal	80004b22 <fdalloc>
    800050e4:	89aa                	mv	s3,a0
    800050e6:	0a054a63          	bltz	a0,8000519a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800050ea:	04449703          	lh	a4,68(s1)
    800050ee:	478d                	li	a5,3
    800050f0:	0cf70263          	beq	a4,a5,800051b4 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800050f4:	4789                	li	a5,2
    800050f6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800050fa:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800050fe:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005102:	f4c42783          	lw	a5,-180(s0)
    80005106:	0017c713          	xori	a4,a5,1
    8000510a:	8b05                	andi	a4,a4,1
    8000510c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005110:	0037f713          	andi	a4,a5,3
    80005114:	00e03733          	snez	a4,a4
    80005118:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000511c:	4007f793          	andi	a5,a5,1024
    80005120:	c791                	beqz	a5,8000512c <sys_open+0xb6>
    80005122:	04449703          	lh	a4,68(s1)
    80005126:	4789                	li	a5,2
    80005128:	08f70d63          	beq	a4,a5,800051c2 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000512c:	8526                	mv	a0,s1
    8000512e:	adafe0ef          	jal	80003408 <iunlock>
  end_op();
    80005132:	c7dfe0ef          	jal	80003dae <end_op>

  return fd;
    80005136:	854e                	mv	a0,s3
    80005138:	74aa                	ld	s1,168(sp)
    8000513a:	790a                	ld	s2,160(sp)
    8000513c:	69ea                	ld	s3,152(sp)
}
    8000513e:	70ea                	ld	ra,184(sp)
    80005140:	744a                	ld	s0,176(sp)
    80005142:	6129                	addi	sp,sp,192
    80005144:	8082                	ret
      end_op();
    80005146:	c69fe0ef          	jal	80003dae <end_op>
      return -1;
    8000514a:	557d                	li	a0,-1
    8000514c:	74aa                	ld	s1,168(sp)
    8000514e:	bfc5                	j	8000513e <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005150:	f5040513          	addi	a0,s0,-176
    80005154:	a1dfe0ef          	jal	80003b70 <namei>
    80005158:	84aa                	mv	s1,a0
    8000515a:	c11d                	beqz	a0,80005180 <sys_open+0x10a>
    ilock(ip);
    8000515c:	9fefe0ef          	jal	8000335a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005160:	04449703          	lh	a4,68(s1)
    80005164:	4785                	li	a5,1
    80005166:	f4f71de3          	bne	a4,a5,800050c0 <sys_open+0x4a>
    8000516a:	f4c42783          	lw	a5,-180(s0)
    8000516e:	d3bd                	beqz	a5,800050d4 <sys_open+0x5e>
      iunlockput(ip);
    80005170:	8526                	mv	a0,s1
    80005172:	bf2fe0ef          	jal	80003564 <iunlockput>
      end_op();
    80005176:	c39fe0ef          	jal	80003dae <end_op>
      return -1;
    8000517a:	557d                	li	a0,-1
    8000517c:	74aa                	ld	s1,168(sp)
    8000517e:	b7c1                	j	8000513e <sys_open+0xc8>
      end_op();
    80005180:	c2ffe0ef          	jal	80003dae <end_op>
      return -1;
    80005184:	557d                	li	a0,-1
    80005186:	74aa                	ld	s1,168(sp)
    80005188:	bf5d                	j	8000513e <sys_open+0xc8>
    iunlockput(ip);
    8000518a:	8526                	mv	a0,s1
    8000518c:	bd8fe0ef          	jal	80003564 <iunlockput>
    end_op();
    80005190:	c1ffe0ef          	jal	80003dae <end_op>
    return -1;
    80005194:	557d                	li	a0,-1
    80005196:	74aa                	ld	s1,168(sp)
    80005198:	b75d                	j	8000513e <sys_open+0xc8>
      fileclose(f);
    8000519a:	854a                	mv	a0,s2
    8000519c:	fb5fe0ef          	jal	80004150 <fileclose>
    800051a0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800051a2:	8526                	mv	a0,s1
    800051a4:	bc0fe0ef          	jal	80003564 <iunlockput>
    end_op();
    800051a8:	c07fe0ef          	jal	80003dae <end_op>
    return -1;
    800051ac:	557d                	li	a0,-1
    800051ae:	74aa                	ld	s1,168(sp)
    800051b0:	790a                	ld	s2,160(sp)
    800051b2:	b771                	j	8000513e <sys_open+0xc8>
    f->type = FD_DEVICE;
    800051b4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800051b8:	04649783          	lh	a5,70(s1)
    800051bc:	02f91223          	sh	a5,36(s2)
    800051c0:	bf3d                	j	800050fe <sys_open+0x88>
    itrunc(ip);
    800051c2:	8526                	mv	a0,s1
    800051c4:	a84fe0ef          	jal	80003448 <itrunc>
    800051c8:	b795                	j	8000512c <sys_open+0xb6>

00000000800051ca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800051ca:	7175                	addi	sp,sp,-144
    800051cc:	e506                	sd	ra,136(sp)
    800051ce:	e122                	sd	s0,128(sp)
    800051d0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800051d2:	b73fe0ef          	jal	80003d44 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800051d6:	08000613          	li	a2,128
    800051da:	f7040593          	addi	a1,s0,-144
    800051de:	4501                	li	a0,0
    800051e0:	f44fd0ef          	jal	80002924 <argstr>
    800051e4:	02054363          	bltz	a0,8000520a <sys_mkdir+0x40>
    800051e8:	4681                	li	a3,0
    800051ea:	4601                	li	a2,0
    800051ec:	4585                	li	a1,1
    800051ee:	f7040513          	addi	a0,s0,-144
    800051f2:	96fff0ef          	jal	80004b60 <create>
    800051f6:	c911                	beqz	a0,8000520a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051f8:	b6cfe0ef          	jal	80003564 <iunlockput>
  end_op();
    800051fc:	bb3fe0ef          	jal	80003dae <end_op>
  return 0;
    80005200:	4501                	li	a0,0
}
    80005202:	60aa                	ld	ra,136(sp)
    80005204:	640a                	ld	s0,128(sp)
    80005206:	6149                	addi	sp,sp,144
    80005208:	8082                	ret
    end_op();
    8000520a:	ba5fe0ef          	jal	80003dae <end_op>
    return -1;
    8000520e:	557d                	li	a0,-1
    80005210:	bfcd                	j	80005202 <sys_mkdir+0x38>

0000000080005212 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005212:	7135                	addi	sp,sp,-160
    80005214:	ed06                	sd	ra,152(sp)
    80005216:	e922                	sd	s0,144(sp)
    80005218:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000521a:	b2bfe0ef          	jal	80003d44 <begin_op>
  argint(1, &major);
    8000521e:	f6c40593          	addi	a1,s0,-148
    80005222:	4505                	li	a0,1
    80005224:	ec8fd0ef          	jal	800028ec <argint>
  argint(2, &minor);
    80005228:	f6840593          	addi	a1,s0,-152
    8000522c:	4509                	li	a0,2
    8000522e:	ebefd0ef          	jal	800028ec <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005232:	08000613          	li	a2,128
    80005236:	f7040593          	addi	a1,s0,-144
    8000523a:	4501                	li	a0,0
    8000523c:	ee8fd0ef          	jal	80002924 <argstr>
    80005240:	02054563          	bltz	a0,8000526a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005244:	f6841683          	lh	a3,-152(s0)
    80005248:	f6c41603          	lh	a2,-148(s0)
    8000524c:	458d                	li	a1,3
    8000524e:	f7040513          	addi	a0,s0,-144
    80005252:	90fff0ef          	jal	80004b60 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005256:	c911                	beqz	a0,8000526a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005258:	b0cfe0ef          	jal	80003564 <iunlockput>
  end_op();
    8000525c:	b53fe0ef          	jal	80003dae <end_op>
  return 0;
    80005260:	4501                	li	a0,0
}
    80005262:	60ea                	ld	ra,152(sp)
    80005264:	644a                	ld	s0,144(sp)
    80005266:	610d                	addi	sp,sp,160
    80005268:	8082                	ret
    end_op();
    8000526a:	b45fe0ef          	jal	80003dae <end_op>
    return -1;
    8000526e:	557d                	li	a0,-1
    80005270:	bfcd                	j	80005262 <sys_mknod+0x50>

0000000080005272 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005272:	7135                	addi	sp,sp,-160
    80005274:	ed06                	sd	ra,152(sp)
    80005276:	e922                	sd	s0,144(sp)
    80005278:	e14a                	sd	s2,128(sp)
    8000527a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000527c:	e66fc0ef          	jal	800018e2 <myproc>
    80005280:	892a                	mv	s2,a0
  
  begin_op();
    80005282:	ac3fe0ef          	jal	80003d44 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005286:	08000613          	li	a2,128
    8000528a:	f6040593          	addi	a1,s0,-160
    8000528e:	4501                	li	a0,0
    80005290:	e94fd0ef          	jal	80002924 <argstr>
    80005294:	04054363          	bltz	a0,800052da <sys_chdir+0x68>
    80005298:	e526                	sd	s1,136(sp)
    8000529a:	f6040513          	addi	a0,s0,-160
    8000529e:	8d3fe0ef          	jal	80003b70 <namei>
    800052a2:	84aa                	mv	s1,a0
    800052a4:	c915                	beqz	a0,800052d8 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800052a6:	8b4fe0ef          	jal	8000335a <ilock>
  if(ip->type != T_DIR){
    800052aa:	04449703          	lh	a4,68(s1)
    800052ae:	4785                	li	a5,1
    800052b0:	02f71963          	bne	a4,a5,800052e2 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800052b4:	8526                	mv	a0,s1
    800052b6:	952fe0ef          	jal	80003408 <iunlock>
  iput(p->cwd);
    800052ba:	15093503          	ld	a0,336(s2)
    800052be:	a1efe0ef          	jal	800034dc <iput>
  end_op();
    800052c2:	aedfe0ef          	jal	80003dae <end_op>
  p->cwd = ip;
    800052c6:	14993823          	sd	s1,336(s2)
  return 0;
    800052ca:	4501                	li	a0,0
    800052cc:	64aa                	ld	s1,136(sp)
}
    800052ce:	60ea                	ld	ra,152(sp)
    800052d0:	644a                	ld	s0,144(sp)
    800052d2:	690a                	ld	s2,128(sp)
    800052d4:	610d                	addi	sp,sp,160
    800052d6:	8082                	ret
    800052d8:	64aa                	ld	s1,136(sp)
    end_op();
    800052da:	ad5fe0ef          	jal	80003dae <end_op>
    return -1;
    800052de:	557d                	li	a0,-1
    800052e0:	b7fd                	j	800052ce <sys_chdir+0x5c>
    iunlockput(ip);
    800052e2:	8526                	mv	a0,s1
    800052e4:	a80fe0ef          	jal	80003564 <iunlockput>
    end_op();
    800052e8:	ac7fe0ef          	jal	80003dae <end_op>
    return -1;
    800052ec:	557d                	li	a0,-1
    800052ee:	64aa                	ld	s1,136(sp)
    800052f0:	bff9                	j	800052ce <sys_chdir+0x5c>

00000000800052f2 <sys_exec>:

uint64
sys_exec(void)
{
    800052f2:	7121                	addi	sp,sp,-448
    800052f4:	ff06                	sd	ra,440(sp)
    800052f6:	fb22                	sd	s0,432(sp)
    800052f8:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800052fa:	e4840593          	addi	a1,s0,-440
    800052fe:	4505                	li	a0,1
    80005300:	e08fd0ef          	jal	80002908 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005304:	08000613          	li	a2,128
    80005308:	f5040593          	addi	a1,s0,-176
    8000530c:	4501                	li	a0,0
    8000530e:	e16fd0ef          	jal	80002924 <argstr>
    80005312:	87aa                	mv	a5,a0
    return -1;
    80005314:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005316:	0c07c463          	bltz	a5,800053de <sys_exec+0xec>
    8000531a:	f726                	sd	s1,424(sp)
    8000531c:	f34a                	sd	s2,416(sp)
    8000531e:	ef4e                	sd	s3,408(sp)
    80005320:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005322:	10000613          	li	a2,256
    80005326:	4581                	li	a1,0
    80005328:	e5040513          	addi	a0,s0,-432
    8000532c:	977fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005330:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005334:	89a6                	mv	s3,s1
    80005336:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005338:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000533c:	00391513          	slli	a0,s2,0x3
    80005340:	e4040593          	addi	a1,s0,-448
    80005344:	e4843783          	ld	a5,-440(s0)
    80005348:	953e                	add	a0,a0,a5
    8000534a:	d18fd0ef          	jal	80002862 <fetchaddr>
    8000534e:	02054663          	bltz	a0,8000537a <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005352:	e4043783          	ld	a5,-448(s0)
    80005356:	c3a9                	beqz	a5,80005398 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005358:	fa6fb0ef          	jal	80000afe <kalloc>
    8000535c:	85aa                	mv	a1,a0
    8000535e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005362:	cd01                	beqz	a0,8000537a <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005364:	6605                	lui	a2,0x1
    80005366:	e4043503          	ld	a0,-448(s0)
    8000536a:	d42fd0ef          	jal	800028ac <fetchstr>
    8000536e:	00054663          	bltz	a0,8000537a <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005372:	0905                	addi	s2,s2,1
    80005374:	09a1                	addi	s3,s3,8
    80005376:	fd4913e3          	bne	s2,s4,8000533c <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000537a:	f5040913          	addi	s2,s0,-176
    8000537e:	6088                	ld	a0,0(s1)
    80005380:	c931                	beqz	a0,800053d4 <sys_exec+0xe2>
    kfree(argv[i]);
    80005382:	e9afb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005386:	04a1                	addi	s1,s1,8
    80005388:	ff249be3          	bne	s1,s2,8000537e <sys_exec+0x8c>
  return -1;
    8000538c:	557d                	li	a0,-1
    8000538e:	74ba                	ld	s1,424(sp)
    80005390:	791a                	ld	s2,416(sp)
    80005392:	69fa                	ld	s3,408(sp)
    80005394:	6a5a                	ld	s4,400(sp)
    80005396:	a0a1                	j	800053de <sys_exec+0xec>
      argv[i] = 0;
    80005398:	0009079b          	sext.w	a5,s2
    8000539c:	078e                	slli	a5,a5,0x3
    8000539e:	fd078793          	addi	a5,a5,-48
    800053a2:	97a2                	add	a5,a5,s0
    800053a4:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800053a8:	e5040593          	addi	a1,s0,-432
    800053ac:	f5040513          	addi	a0,s0,-176
    800053b0:	ba8ff0ef          	jal	80004758 <kexec>
    800053b4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053b6:	f5040993          	addi	s3,s0,-176
    800053ba:	6088                	ld	a0,0(s1)
    800053bc:	c511                	beqz	a0,800053c8 <sys_exec+0xd6>
    kfree(argv[i]);
    800053be:	e5efb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053c2:	04a1                	addi	s1,s1,8
    800053c4:	ff349be3          	bne	s1,s3,800053ba <sys_exec+0xc8>
  return ret;
    800053c8:	854a                	mv	a0,s2
    800053ca:	74ba                	ld	s1,424(sp)
    800053cc:	791a                	ld	s2,416(sp)
    800053ce:	69fa                	ld	s3,408(sp)
    800053d0:	6a5a                	ld	s4,400(sp)
    800053d2:	a031                	j	800053de <sys_exec+0xec>
  return -1;
    800053d4:	557d                	li	a0,-1
    800053d6:	74ba                	ld	s1,424(sp)
    800053d8:	791a                	ld	s2,416(sp)
    800053da:	69fa                	ld	s3,408(sp)
    800053dc:	6a5a                	ld	s4,400(sp)
}
    800053de:	70fa                	ld	ra,440(sp)
    800053e0:	745a                	ld	s0,432(sp)
    800053e2:	6139                	addi	sp,sp,448
    800053e4:	8082                	ret

00000000800053e6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800053e6:	7139                	addi	sp,sp,-64
    800053e8:	fc06                	sd	ra,56(sp)
    800053ea:	f822                	sd	s0,48(sp)
    800053ec:	f426                	sd	s1,40(sp)
    800053ee:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800053f0:	cf2fc0ef          	jal	800018e2 <myproc>
    800053f4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053f6:	fd840593          	addi	a1,s0,-40
    800053fa:	4501                	li	a0,0
    800053fc:	d0cfd0ef          	jal	80002908 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005400:	fc840593          	addi	a1,s0,-56
    80005404:	fd040513          	addi	a0,s0,-48
    80005408:	852ff0ef          	jal	8000445a <pipealloc>
    return -1;
    8000540c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000540e:	0a054463          	bltz	a0,800054b6 <sys_pipe+0xd0>
  fd0 = -1;
    80005412:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005416:	fd043503          	ld	a0,-48(s0)
    8000541a:	f08ff0ef          	jal	80004b22 <fdalloc>
    8000541e:	fca42223          	sw	a0,-60(s0)
    80005422:	08054163          	bltz	a0,800054a4 <sys_pipe+0xbe>
    80005426:	fc843503          	ld	a0,-56(s0)
    8000542a:	ef8ff0ef          	jal	80004b22 <fdalloc>
    8000542e:	fca42023          	sw	a0,-64(s0)
    80005432:	06054063          	bltz	a0,80005492 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005436:	4691                	li	a3,4
    80005438:	fc440613          	addi	a2,s0,-60
    8000543c:	fd843583          	ld	a1,-40(s0)
    80005440:	68a8                	ld	a0,80(s1)
    80005442:	9a0fc0ef          	jal	800015e2 <copyout>
    80005446:	00054e63          	bltz	a0,80005462 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000544a:	4691                	li	a3,4
    8000544c:	fc040613          	addi	a2,s0,-64
    80005450:	fd843583          	ld	a1,-40(s0)
    80005454:	0591                	addi	a1,a1,4
    80005456:	68a8                	ld	a0,80(s1)
    80005458:	98afc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000545c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000545e:	04055c63          	bgez	a0,800054b6 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005462:	fc442783          	lw	a5,-60(s0)
    80005466:	07e9                	addi	a5,a5,26
    80005468:	078e                	slli	a5,a5,0x3
    8000546a:	97a6                	add	a5,a5,s1
    8000546c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005470:	fc042783          	lw	a5,-64(s0)
    80005474:	07e9                	addi	a5,a5,26
    80005476:	078e                	slli	a5,a5,0x3
    80005478:	94be                	add	s1,s1,a5
    8000547a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000547e:	fd043503          	ld	a0,-48(s0)
    80005482:	ccffe0ef          	jal	80004150 <fileclose>
    fileclose(wf);
    80005486:	fc843503          	ld	a0,-56(s0)
    8000548a:	cc7fe0ef          	jal	80004150 <fileclose>
    return -1;
    8000548e:	57fd                	li	a5,-1
    80005490:	a01d                	j	800054b6 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005492:	fc442783          	lw	a5,-60(s0)
    80005496:	0007c763          	bltz	a5,800054a4 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000549a:	07e9                	addi	a5,a5,26
    8000549c:	078e                	slli	a5,a5,0x3
    8000549e:	97a6                	add	a5,a5,s1
    800054a0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800054a4:	fd043503          	ld	a0,-48(s0)
    800054a8:	ca9fe0ef          	jal	80004150 <fileclose>
    fileclose(wf);
    800054ac:	fc843503          	ld	a0,-56(s0)
    800054b0:	ca1fe0ef          	jal	80004150 <fileclose>
    return -1;
    800054b4:	57fd                	li	a5,-1
}
    800054b6:	853e                	mv	a0,a5
    800054b8:	70e2                	ld	ra,56(sp)
    800054ba:	7442                	ld	s0,48(sp)
    800054bc:	74a2                	ld	s1,40(sp)
    800054be:	6121                	addi	sp,sp,64
    800054c0:	8082                	ret
	...

00000000800054d0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800054d0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800054d2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800054d4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800054d6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800054d8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800054da:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800054dc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800054de:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800054e0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800054e2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800054e4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800054e6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800054e8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800054ea:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800054ec:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800054ee:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800054f0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800054f2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800054f4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800054f6:	a7cfd0ef          	jal	80002772 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800054fa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800054fc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800054fe:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005500:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005502:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005504:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005506:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005508:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000550a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000550c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000550e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005510:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005512:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005514:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005516:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005518:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000551a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000551c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000551e:	10200073          	sret
	...

000000008000552e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000552e:	1141                	addi	sp,sp,-16
    80005530:	e422                	sd	s0,8(sp)
    80005532:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005534:	0c0007b7          	lui	a5,0xc000
    80005538:	4705                	li	a4,1
    8000553a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000553c:	0c0007b7          	lui	a5,0xc000
    80005540:	c3d8                	sw	a4,4(a5)
}
    80005542:	6422                	ld	s0,8(sp)
    80005544:	0141                	addi	sp,sp,16
    80005546:	8082                	ret

0000000080005548 <plicinithart>:

void
plicinithart(void)
{
    80005548:	1141                	addi	sp,sp,-16
    8000554a:	e406                	sd	ra,8(sp)
    8000554c:	e022                	sd	s0,0(sp)
    8000554e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005550:	b66fc0ef          	jal	800018b6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005554:	0085171b          	slliw	a4,a0,0x8
    80005558:	0c0027b7          	lui	a5,0xc002
    8000555c:	97ba                	add	a5,a5,a4
    8000555e:	40200713          	li	a4,1026
    80005562:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005566:	00d5151b          	slliw	a0,a0,0xd
    8000556a:	0c2017b7          	lui	a5,0xc201
    8000556e:	97aa                	add	a5,a5,a0
    80005570:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005574:	60a2                	ld	ra,8(sp)
    80005576:	6402                	ld	s0,0(sp)
    80005578:	0141                	addi	sp,sp,16
    8000557a:	8082                	ret

000000008000557c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000557c:	1141                	addi	sp,sp,-16
    8000557e:	e406                	sd	ra,8(sp)
    80005580:	e022                	sd	s0,0(sp)
    80005582:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005584:	b32fc0ef          	jal	800018b6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005588:	00d5151b          	slliw	a0,a0,0xd
    8000558c:	0c2017b7          	lui	a5,0xc201
    80005590:	97aa                	add	a5,a5,a0
  return irq;
}
    80005592:	43c8                	lw	a0,4(a5)
    80005594:	60a2                	ld	ra,8(sp)
    80005596:	6402                	ld	s0,0(sp)
    80005598:	0141                	addi	sp,sp,16
    8000559a:	8082                	ret

000000008000559c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000559c:	1101                	addi	sp,sp,-32
    8000559e:	ec06                	sd	ra,24(sp)
    800055a0:	e822                	sd	s0,16(sp)
    800055a2:	e426                	sd	s1,8(sp)
    800055a4:	1000                	addi	s0,sp,32
    800055a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800055a8:	b0efc0ef          	jal	800018b6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800055ac:	00d5151b          	slliw	a0,a0,0xd
    800055b0:	0c2017b7          	lui	a5,0xc201
    800055b4:	97aa                	add	a5,a5,a0
    800055b6:	c3c4                	sw	s1,4(a5)
}
    800055b8:	60e2                	ld	ra,24(sp)
    800055ba:	6442                	ld	s0,16(sp)
    800055bc:	64a2                	ld	s1,8(sp)
    800055be:	6105                	addi	sp,sp,32
    800055c0:	8082                	ret

00000000800055c2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800055c2:	1141                	addi	sp,sp,-16
    800055c4:	e406                	sd	ra,8(sp)
    800055c6:	e022                	sd	s0,0(sp)
    800055c8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800055ca:	479d                	li	a5,7
    800055cc:	04a7ca63          	blt	a5,a0,80005620 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800055d0:	0001e797          	auipc	a5,0x1e
    800055d4:	29078793          	addi	a5,a5,656 # 80023860 <disk>
    800055d8:	97aa                	add	a5,a5,a0
    800055da:	0187c783          	lbu	a5,24(a5)
    800055de:	e7b9                	bnez	a5,8000562c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800055e0:	00451693          	slli	a3,a0,0x4
    800055e4:	0001e797          	auipc	a5,0x1e
    800055e8:	27c78793          	addi	a5,a5,636 # 80023860 <disk>
    800055ec:	6398                	ld	a4,0(a5)
    800055ee:	9736                	add	a4,a4,a3
    800055f0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800055f4:	6398                	ld	a4,0(a5)
    800055f6:	9736                	add	a4,a4,a3
    800055f8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800055fc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005600:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005604:	97aa                	add	a5,a5,a0
    80005606:	4705                	li	a4,1
    80005608:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000560c:	0001e517          	auipc	a0,0x1e
    80005610:	26c50513          	addi	a0,a0,620 # 80023878 <disk+0x18>
    80005614:	9ebfc0ef          	jal	80001ffe <wakeup>
}
    80005618:	60a2                	ld	ra,8(sp)
    8000561a:	6402                	ld	s0,0(sp)
    8000561c:	0141                	addi	sp,sp,16
    8000561e:	8082                	ret
    panic("free_desc 1");
    80005620:	00002517          	auipc	a0,0x2
    80005624:	ff850513          	addi	a0,a0,-8 # 80007618 <etext+0x618>
    80005628:	9b8fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000562c:	00002517          	auipc	a0,0x2
    80005630:	ffc50513          	addi	a0,a0,-4 # 80007628 <etext+0x628>
    80005634:	9acfb0ef          	jal	800007e0 <panic>

0000000080005638 <virtio_disk_init>:
{
    80005638:	1101                	addi	sp,sp,-32
    8000563a:	ec06                	sd	ra,24(sp)
    8000563c:	e822                	sd	s0,16(sp)
    8000563e:	e426                	sd	s1,8(sp)
    80005640:	e04a                	sd	s2,0(sp)
    80005642:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005644:	00002597          	auipc	a1,0x2
    80005648:	ff458593          	addi	a1,a1,-12 # 80007638 <etext+0x638>
    8000564c:	0001e517          	auipc	a0,0x1e
    80005650:	33c50513          	addi	a0,a0,828 # 80023988 <disk+0x128>
    80005654:	cfafb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005658:	100017b7          	lui	a5,0x10001
    8000565c:	4398                	lw	a4,0(a5)
    8000565e:	2701                	sext.w	a4,a4
    80005660:	747277b7          	lui	a5,0x74727
    80005664:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005668:	18f71063          	bne	a4,a5,800057e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000566c:	100017b7          	lui	a5,0x10001
    80005670:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005672:	439c                	lw	a5,0(a5)
    80005674:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005676:	4709                	li	a4,2
    80005678:	16e79863          	bne	a5,a4,800057e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000567c:	100017b7          	lui	a5,0x10001
    80005680:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005682:	439c                	lw	a5,0(a5)
    80005684:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005686:	16e79163          	bne	a5,a4,800057e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000568a:	100017b7          	lui	a5,0x10001
    8000568e:	47d8                	lw	a4,12(a5)
    80005690:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005692:	554d47b7          	lui	a5,0x554d4
    80005696:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000569a:	14f71763          	bne	a4,a5,800057e8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000569e:	100017b7          	lui	a5,0x10001
    800056a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a6:	4705                	li	a4,1
    800056a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056aa:	470d                	li	a4,3
    800056ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800056ae:	10001737          	lui	a4,0x10001
    800056b2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800056b4:	c7ffe737          	lui	a4,0xc7ffe
    800056b8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdadbf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800056bc:	8ef9                	and	a3,a3,a4
    800056be:	10001737          	lui	a4,0x10001
    800056c2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056c4:	472d                	li	a4,11
    800056c6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056c8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800056cc:	439c                	lw	a5,0(a5)
    800056ce:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800056d2:	8ba1                	andi	a5,a5,8
    800056d4:	12078063          	beqz	a5,800057f4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800056d8:	100017b7          	lui	a5,0x10001
    800056dc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800056e0:	100017b7          	lui	a5,0x10001
    800056e4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800056e8:	439c                	lw	a5,0(a5)
    800056ea:	2781                	sext.w	a5,a5
    800056ec:	10079a63          	bnez	a5,80005800 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800056f0:	100017b7          	lui	a5,0x10001
    800056f4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800056f8:	439c                	lw	a5,0(a5)
    800056fa:	2781                	sext.w	a5,a5
  if(max == 0)
    800056fc:	10078863          	beqz	a5,8000580c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005700:	471d                	li	a4,7
    80005702:	10f77b63          	bgeu	a4,a5,80005818 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005706:	bf8fb0ef          	jal	80000afe <kalloc>
    8000570a:	0001e497          	auipc	s1,0x1e
    8000570e:	15648493          	addi	s1,s1,342 # 80023860 <disk>
    80005712:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005714:	beafb0ef          	jal	80000afe <kalloc>
    80005718:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000571a:	be4fb0ef          	jal	80000afe <kalloc>
    8000571e:	87aa                	mv	a5,a0
    80005720:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005722:	6088                	ld	a0,0(s1)
    80005724:	10050063          	beqz	a0,80005824 <virtio_disk_init+0x1ec>
    80005728:	0001e717          	auipc	a4,0x1e
    8000572c:	14073703          	ld	a4,320(a4) # 80023868 <disk+0x8>
    80005730:	0e070a63          	beqz	a4,80005824 <virtio_disk_init+0x1ec>
    80005734:	0e078863          	beqz	a5,80005824 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005738:	6605                	lui	a2,0x1
    8000573a:	4581                	li	a1,0
    8000573c:	d66fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005740:	0001e497          	auipc	s1,0x1e
    80005744:	12048493          	addi	s1,s1,288 # 80023860 <disk>
    80005748:	6605                	lui	a2,0x1
    8000574a:	4581                	li	a1,0
    8000574c:	6488                	ld	a0,8(s1)
    8000574e:	d54fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005752:	6605                	lui	a2,0x1
    80005754:	4581                	li	a1,0
    80005756:	6888                	ld	a0,16(s1)
    80005758:	d4afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000575c:	100017b7          	lui	a5,0x10001
    80005760:	4721                	li	a4,8
    80005762:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005764:	4098                	lw	a4,0(s1)
    80005766:	100017b7          	lui	a5,0x10001
    8000576a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000576e:	40d8                	lw	a4,4(s1)
    80005770:	100017b7          	lui	a5,0x10001
    80005774:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005778:	649c                	ld	a5,8(s1)
    8000577a:	0007869b          	sext.w	a3,a5
    8000577e:	10001737          	lui	a4,0x10001
    80005782:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005786:	9781                	srai	a5,a5,0x20
    80005788:	10001737          	lui	a4,0x10001
    8000578c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005790:	689c                	ld	a5,16(s1)
    80005792:	0007869b          	sext.w	a3,a5
    80005796:	10001737          	lui	a4,0x10001
    8000579a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000579e:	9781                	srai	a5,a5,0x20
    800057a0:	10001737          	lui	a4,0x10001
    800057a4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800057a8:	10001737          	lui	a4,0x10001
    800057ac:	4785                	li	a5,1
    800057ae:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800057b0:	00f48c23          	sb	a5,24(s1)
    800057b4:	00f48ca3          	sb	a5,25(s1)
    800057b8:	00f48d23          	sb	a5,26(s1)
    800057bc:	00f48da3          	sb	a5,27(s1)
    800057c0:	00f48e23          	sb	a5,28(s1)
    800057c4:	00f48ea3          	sb	a5,29(s1)
    800057c8:	00f48f23          	sb	a5,30(s1)
    800057cc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800057d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800057d4:	100017b7          	lui	a5,0x10001
    800057d8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800057dc:	60e2                	ld	ra,24(sp)
    800057de:	6442                	ld	s0,16(sp)
    800057e0:	64a2                	ld	s1,8(sp)
    800057e2:	6902                	ld	s2,0(sp)
    800057e4:	6105                	addi	sp,sp,32
    800057e6:	8082                	ret
    panic("could not find virtio disk");
    800057e8:	00002517          	auipc	a0,0x2
    800057ec:	e6050513          	addi	a0,a0,-416 # 80007648 <etext+0x648>
    800057f0:	ff1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800057f4:	00002517          	auipc	a0,0x2
    800057f8:	e7450513          	addi	a0,a0,-396 # 80007668 <etext+0x668>
    800057fc:	fe5fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005800:	00002517          	auipc	a0,0x2
    80005804:	e8850513          	addi	a0,a0,-376 # 80007688 <etext+0x688>
    80005808:	fd9fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000580c:	00002517          	auipc	a0,0x2
    80005810:	e9c50513          	addi	a0,a0,-356 # 800076a8 <etext+0x6a8>
    80005814:	fcdfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005818:	00002517          	auipc	a0,0x2
    8000581c:	eb050513          	addi	a0,a0,-336 # 800076c8 <etext+0x6c8>
    80005820:	fc1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005824:	00002517          	auipc	a0,0x2
    80005828:	ec450513          	addi	a0,a0,-316 # 800076e8 <etext+0x6e8>
    8000582c:	fb5fa0ef          	jal	800007e0 <panic>

0000000080005830 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005830:	7159                	addi	sp,sp,-112
    80005832:	f486                	sd	ra,104(sp)
    80005834:	f0a2                	sd	s0,96(sp)
    80005836:	eca6                	sd	s1,88(sp)
    80005838:	e8ca                	sd	s2,80(sp)
    8000583a:	e4ce                	sd	s3,72(sp)
    8000583c:	e0d2                	sd	s4,64(sp)
    8000583e:	fc56                	sd	s5,56(sp)
    80005840:	f85a                	sd	s6,48(sp)
    80005842:	f45e                	sd	s7,40(sp)
    80005844:	f062                	sd	s8,32(sp)
    80005846:	ec66                	sd	s9,24(sp)
    80005848:	1880                	addi	s0,sp,112
    8000584a:	8a2a                	mv	s4,a0
    8000584c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000584e:	00c52c83          	lw	s9,12(a0)
    80005852:	001c9c9b          	slliw	s9,s9,0x1
    80005856:	1c82                	slli	s9,s9,0x20
    80005858:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000585c:	0001e517          	auipc	a0,0x1e
    80005860:	12c50513          	addi	a0,a0,300 # 80023988 <disk+0x128>
    80005864:	b6afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005868:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000586a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000586c:	0001eb17          	auipc	s6,0x1e
    80005870:	ff4b0b13          	addi	s6,s6,-12 # 80023860 <disk>
  for(int i = 0; i < 3; i++){
    80005874:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005876:	0001ec17          	auipc	s8,0x1e
    8000587a:	112c0c13          	addi	s8,s8,274 # 80023988 <disk+0x128>
    8000587e:	a8b9                	j	800058dc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005880:	00fb0733          	add	a4,s6,a5
    80005884:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005888:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000588a:	0207c563          	bltz	a5,800058b4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000588e:	2905                	addiw	s2,s2,1
    80005890:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005892:	05590963          	beq	s2,s5,800058e4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005896:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005898:	0001e717          	auipc	a4,0x1e
    8000589c:	fc870713          	addi	a4,a4,-56 # 80023860 <disk>
    800058a0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800058a2:	01874683          	lbu	a3,24(a4)
    800058a6:	fee9                	bnez	a3,80005880 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800058a8:	2785                	addiw	a5,a5,1
    800058aa:	0705                	addi	a4,a4,1
    800058ac:	fe979be3          	bne	a5,s1,800058a2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800058b0:	57fd                	li	a5,-1
    800058b2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800058b4:	01205d63          	blez	s2,800058ce <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800058b8:	f9042503          	lw	a0,-112(s0)
    800058bc:	d07ff0ef          	jal	800055c2 <free_desc>
      for(int j = 0; j < i; j++)
    800058c0:	4785                	li	a5,1
    800058c2:	0127d663          	bge	a5,s2,800058ce <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800058c6:	f9442503          	lw	a0,-108(s0)
    800058ca:	cf9ff0ef          	jal	800055c2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800058ce:	85e2                	mv	a1,s8
    800058d0:	0001e517          	auipc	a0,0x1e
    800058d4:	fa850513          	addi	a0,a0,-88 # 80023878 <disk+0x18>
    800058d8:	edafc0ef          	jal	80001fb2 <sleep>
  for(int i = 0; i < 3; i++){
    800058dc:	f9040613          	addi	a2,s0,-112
    800058e0:	894e                	mv	s2,s3
    800058e2:	bf55                	j	80005896 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058e4:	f9042503          	lw	a0,-112(s0)
    800058e8:	00451693          	slli	a3,a0,0x4

  if(write)
    800058ec:	0001e797          	auipc	a5,0x1e
    800058f0:	f7478793          	addi	a5,a5,-140 # 80023860 <disk>
    800058f4:	00a50713          	addi	a4,a0,10
    800058f8:	0712                	slli	a4,a4,0x4
    800058fa:	973e                	add	a4,a4,a5
    800058fc:	01703633          	snez	a2,s7
    80005900:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005902:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005906:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000590a:	6398                	ld	a4,0(a5)
    8000590c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000590e:	0a868613          	addi	a2,a3,168
    80005912:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005914:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005916:	6390                	ld	a2,0(a5)
    80005918:	00d605b3          	add	a1,a2,a3
    8000591c:	4741                	li	a4,16
    8000591e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005920:	4805                	li	a6,1
    80005922:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005926:	f9442703          	lw	a4,-108(s0)
    8000592a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000592e:	0712                	slli	a4,a4,0x4
    80005930:	963a                	add	a2,a2,a4
    80005932:	058a0593          	addi	a1,s4,88
    80005936:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005938:	0007b883          	ld	a7,0(a5)
    8000593c:	9746                	add	a4,a4,a7
    8000593e:	40000613          	li	a2,1024
    80005942:	c710                	sw	a2,8(a4)
  if(write)
    80005944:	001bb613          	seqz	a2,s7
    80005948:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000594c:	00166613          	ori	a2,a2,1
    80005950:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005954:	f9842583          	lw	a1,-104(s0)
    80005958:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000595c:	00250613          	addi	a2,a0,2
    80005960:	0612                	slli	a2,a2,0x4
    80005962:	963e                	add	a2,a2,a5
    80005964:	577d                	li	a4,-1
    80005966:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000596a:	0592                	slli	a1,a1,0x4
    8000596c:	98ae                	add	a7,a7,a1
    8000596e:	03068713          	addi	a4,a3,48
    80005972:	973e                	add	a4,a4,a5
    80005974:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005978:	6398                	ld	a4,0(a5)
    8000597a:	972e                	add	a4,a4,a1
    8000597c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005980:	4689                	li	a3,2
    80005982:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005986:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000598a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000598e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005992:	6794                	ld	a3,8(a5)
    80005994:	0026d703          	lhu	a4,2(a3)
    80005998:	8b1d                	andi	a4,a4,7
    8000599a:	0706                	slli	a4,a4,0x1
    8000599c:	96ba                	add	a3,a3,a4
    8000599e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800059a2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800059a6:	6798                	ld	a4,8(a5)
    800059a8:	00275783          	lhu	a5,2(a4)
    800059ac:	2785                	addiw	a5,a5,1
    800059ae:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800059b2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800059b6:	100017b7          	lui	a5,0x10001
    800059ba:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800059be:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800059c2:	0001e917          	auipc	s2,0x1e
    800059c6:	fc690913          	addi	s2,s2,-58 # 80023988 <disk+0x128>
  while(b->disk == 1) {
    800059ca:	4485                	li	s1,1
    800059cc:	01079a63          	bne	a5,a6,800059e0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800059d0:	85ca                	mv	a1,s2
    800059d2:	8552                	mv	a0,s4
    800059d4:	ddefc0ef          	jal	80001fb2 <sleep>
  while(b->disk == 1) {
    800059d8:	004a2783          	lw	a5,4(s4)
    800059dc:	fe978ae3          	beq	a5,s1,800059d0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800059e0:	f9042903          	lw	s2,-112(s0)
    800059e4:	00290713          	addi	a4,s2,2
    800059e8:	0712                	slli	a4,a4,0x4
    800059ea:	0001e797          	auipc	a5,0x1e
    800059ee:	e7678793          	addi	a5,a5,-394 # 80023860 <disk>
    800059f2:	97ba                	add	a5,a5,a4
    800059f4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800059f8:	0001e997          	auipc	s3,0x1e
    800059fc:	e6898993          	addi	s3,s3,-408 # 80023860 <disk>
    80005a00:	00491713          	slli	a4,s2,0x4
    80005a04:	0009b783          	ld	a5,0(s3)
    80005a08:	97ba                	add	a5,a5,a4
    80005a0a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005a0e:	854a                	mv	a0,s2
    80005a10:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005a14:	bafff0ef          	jal	800055c2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005a18:	8885                	andi	s1,s1,1
    80005a1a:	f0fd                	bnez	s1,80005a00 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005a1c:	0001e517          	auipc	a0,0x1e
    80005a20:	f6c50513          	addi	a0,a0,-148 # 80023988 <disk+0x128>
    80005a24:	a42fb0ef          	jal	80000c66 <release>
}
    80005a28:	70a6                	ld	ra,104(sp)
    80005a2a:	7406                	ld	s0,96(sp)
    80005a2c:	64e6                	ld	s1,88(sp)
    80005a2e:	6946                	ld	s2,80(sp)
    80005a30:	69a6                	ld	s3,72(sp)
    80005a32:	6a06                	ld	s4,64(sp)
    80005a34:	7ae2                	ld	s5,56(sp)
    80005a36:	7b42                	ld	s6,48(sp)
    80005a38:	7ba2                	ld	s7,40(sp)
    80005a3a:	7c02                	ld	s8,32(sp)
    80005a3c:	6ce2                	ld	s9,24(sp)
    80005a3e:	6165                	addi	sp,sp,112
    80005a40:	8082                	ret

0000000080005a42 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a42:	1101                	addi	sp,sp,-32
    80005a44:	ec06                	sd	ra,24(sp)
    80005a46:	e822                	sd	s0,16(sp)
    80005a48:	e426                	sd	s1,8(sp)
    80005a4a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005a4c:	0001e497          	auipc	s1,0x1e
    80005a50:	e1448493          	addi	s1,s1,-492 # 80023860 <disk>
    80005a54:	0001e517          	auipc	a0,0x1e
    80005a58:	f3450513          	addi	a0,a0,-204 # 80023988 <disk+0x128>
    80005a5c:	972fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005a60:	100017b7          	lui	a5,0x10001
    80005a64:	53b8                	lw	a4,96(a5)
    80005a66:	8b0d                	andi	a4,a4,3
    80005a68:	100017b7          	lui	a5,0x10001
    80005a6c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005a6e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005a72:	689c                	ld	a5,16(s1)
    80005a74:	0204d703          	lhu	a4,32(s1)
    80005a78:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005a7c:	04f70663          	beq	a4,a5,80005ac8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005a80:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a84:	6898                	ld	a4,16(s1)
    80005a86:	0204d783          	lhu	a5,32(s1)
    80005a8a:	8b9d                	andi	a5,a5,7
    80005a8c:	078e                	slli	a5,a5,0x3
    80005a8e:	97ba                	add	a5,a5,a4
    80005a90:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a92:	00278713          	addi	a4,a5,2
    80005a96:	0712                	slli	a4,a4,0x4
    80005a98:	9726                	add	a4,a4,s1
    80005a9a:	01074703          	lbu	a4,16(a4)
    80005a9e:	e321                	bnez	a4,80005ade <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005aa0:	0789                	addi	a5,a5,2
    80005aa2:	0792                	slli	a5,a5,0x4
    80005aa4:	97a6                	add	a5,a5,s1
    80005aa6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005aa8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005aac:	d52fc0ef          	jal	80001ffe <wakeup>

    disk.used_idx += 1;
    80005ab0:	0204d783          	lhu	a5,32(s1)
    80005ab4:	2785                	addiw	a5,a5,1
    80005ab6:	17c2                	slli	a5,a5,0x30
    80005ab8:	93c1                	srli	a5,a5,0x30
    80005aba:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005abe:	6898                	ld	a4,16(s1)
    80005ac0:	00275703          	lhu	a4,2(a4)
    80005ac4:	faf71ee3          	bne	a4,a5,80005a80 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005ac8:	0001e517          	auipc	a0,0x1e
    80005acc:	ec050513          	addi	a0,a0,-320 # 80023988 <disk+0x128>
    80005ad0:	996fb0ef          	jal	80000c66 <release>
}
    80005ad4:	60e2                	ld	ra,24(sp)
    80005ad6:	6442                	ld	s0,16(sp)
    80005ad8:	64a2                	ld	s1,8(sp)
    80005ada:	6105                	addi	sp,sp,32
    80005adc:	8082                	ret
      panic("virtio_disk_intr status");
    80005ade:	00002517          	auipc	a0,0x2
    80005ae2:	c2250513          	addi	a0,a0,-990 # 80007700 <etext+0x700>
    80005ae6:	cfbfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
