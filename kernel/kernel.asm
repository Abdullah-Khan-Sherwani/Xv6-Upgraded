
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
    80000004:	25813103          	ld	sp,600(sp) # 8000a258 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdadef>
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
    80000112:	3b2020ef          	jal	800024c4 <either_copyin>
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
    80000190:	12450513          	addi	a0,a0,292 # 800122b0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	11848493          	addi	s1,s1,280 # 800122b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	1a890913          	addi	s2,s2,424 # 80012348 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	798010ef          	jal	80001950 <myproc>
    800001bc:	19a020ef          	jal	80002356 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	721010ef          	jal	800020e6 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00012717          	auipc	a4,0x12
    800001dc:	0d870713          	addi	a4,a4,216 # 800122b0 <cons>
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
    8000020a:	270020ef          	jal	8000247a <either_copyout>
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
    80000226:	08e50513          	addi	a0,a0,142 # 800122b0 <cons>
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
    80000250:	0ef72e23          	sw	a5,252(a4) # 80012348 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00012517          	auipc	a0,0x12
    80000266:	04e50513          	addi	a0,a0,78 # 800122b0 <cons>
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
    800002ba:	ffa50513          	addi	a0,a0,-6 # 800122b0 <cons>
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
    800002d8:	236020ef          	jal	8000250e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00012517          	auipc	a0,0x12
    800002e0:	fd450513          	addi	a0,a0,-44 # 800122b0 <cons>
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
    800002fe:	fb670713          	addi	a4,a4,-74 # 800122b0 <cons>
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
    80000324:	f9078793          	addi	a5,a5,-112 # 800122b0 <cons>
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
    80000352:	ffa7a783          	lw	a5,-6(a5) # 80012348 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00012717          	auipc	a4,0x12
    80000368:	f4c70713          	addi	a4,a4,-180 # 800122b0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00012497          	auipc	s1,0x12
    80000378:	f3c48493          	addi	s1,s1,-196 # 800122b0 <cons>
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
    800003ba:	efa70713          	addi	a4,a4,-262 # 800122b0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	f8f72223          	sw	a5,-124(a4) # 80012350 <cons+0xa0>
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
    800003ee:	ec678793          	addi	a5,a5,-314 # 800122b0 <cons>
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
    80000412:	f2c7af23          	sw	a2,-194(a5) # 8001234c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00012517          	auipc	a0,0x12
    8000041a:	f3250513          	addi	a0,a0,-206 # 80012348 <cons+0x98>
    8000041e:	515010ef          	jal	80002132 <wakeup>
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
    80000438:	e7c50513          	addi	a0,a0,-388 # 800122b0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00022797          	auipc	a5,0x22
    80000448:	43478793          	addi	a5,a5,1076 # 80022878 <devsw>
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
    8000051c:	d5c7a783          	lw	a5,-676(a5) # 8000a274 <panicking>
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
    80000564:	df850513          	addi	a0,a0,-520 # 80012358 <pr>
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
    800007c0:	ab87a783          	lw	a5,-1352(a5) # 8000a274 <panicking>
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
    800007d6:	b8650513          	addi	a0,a0,-1146 # 80012358 <pr>
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
    800007f4:	a927a223          	sw	s2,-1404(a5) # 8000a274 <panicking>
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
    80000816:	a527af23          	sw	s2,-1442(a5) # 8000a270 <panicked>
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
    80000830:	b2c50513          	addi	a0,a0,-1236 # 80012358 <pr>
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
    80000888:	aec50513          	addi	a0,a0,-1300 # 80012370 <tx_lock>
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
    800008ac:	ac850513          	addi	a0,a0,-1336 # 80012370 <tx_lock>
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
    800008ca:	9b648493          	addi	s1,s1,-1610 # 8000a27c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00012997          	auipc	s3,0x12
    800008d2:	aa298993          	addi	s3,s3,-1374 # 80012370 <tx_lock>
    800008d6:	0000a917          	auipc	s2,0xa
    800008da:	9a290913          	addi	s2,s2,-1630 # 8000a278 <tx_chan>
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
    800008ea:	7fc010ef          	jal	800020e6 <sleep>
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
    80000918:	a5c50513          	addi	a0,a0,-1444 # 80012370 <tx_lock>
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
    8000093c:	93c7a783          	lw	a5,-1732(a5) # 8000a274 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000a797          	auipc	a5,0xa
    80000946:	92e7a783          	lw	a5,-1746(a5) # 8000a270 <panicked>
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
    8000096c:	90c7a783          	lw	a5,-1780(a5) # 8000a274 <panicking>
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
    800009c8:	9ac50513          	addi	a0,a0,-1620 # 80012370 <tx_lock>
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
    800009e4:	99050513          	addi	a0,a0,-1648 # 80012370 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	0000a797          	auipc	a5,0xa
    800009f4:	8807a623          	sw	zero,-1908(a5) # 8000a27c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	0000a517          	auipc	a0,0xa
    800009fc:	88050513          	addi	a0,a0,-1920 # 8000a278 <tx_chan>
    80000a00:	732010ef          	jal	80002132 <wakeup>
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
    80000a34:	fe078793          	addi	a5,a5,-32 # 80023a10 <end>
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
    80000a50:	93c90913          	addi	s2,s2,-1732 # 80012388 <kmem>
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
    80000ade:	8ae50513          	addi	a0,a0,-1874 # 80012388 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00023517          	auipc	a0,0x23
    80000aee:	f2650513          	addi	a0,a0,-218 # 80023a10 <end>
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
    80000b0c:	88048493          	addi	s1,s1,-1920 # 80012388 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00012517          	auipc	a0,0x12
    80000b20:	86c50513          	addi	a0,a0,-1940 # 80012388 <kmem>
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
    80000b44:	84850513          	addi	a0,a0,-1976 # 80012388 <kmem>
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
    80000b78:	5bd000ef          	jal	80001934 <mycpu>
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
    80000ba6:	58f000ef          	jal	80001934 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	587000ef          	jal	80001934 <mycpu>
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
    80000bc2:	573000ef          	jal	80001934 <mycpu>
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
    80000bf6:	53f000ef          	jal	80001934 <mycpu>
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
    80000c1a:	51b000ef          	jal	80001934 <mycpu>
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
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb5f1>
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
    80000e44:	2e1000ef          	jal	80001924 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00009717          	auipc	a4,0x9
    80000e4c:	43870713          	addi	a4,a4,1080 # 8000a280 <started>
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
    80000e5c:	2c9000ef          	jal	80001924 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	7ce010ef          	jal	80002640 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	043040ef          	jal	800056b8 <plicinithart>
  }

  scheduler();        
    80000e7a:	038010ef          	jal	80001eb2 <scheduler>
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
    80000eb6:	17d000ef          	jal	80001832 <procinit>
    trapinit();      // trap vectors
    80000eba:	762010ef          	jal	8000261c <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	782010ef          	jal	80002640 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	7dc040ef          	jal	8000569e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	7f2040ef          	jal	800056b8 <plicinithart>
    binit();         // buffer cache
    80000eca:	6b7010ef          	jal	80002d80 <binit>
    iinit();         // inode table
    80000ece:	43c020ef          	jal	8000330a <iinit>
    fileinit();      // file table
    80000ed2:	32e030ef          	jal	80004200 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	0d3040ef          	jal	800057a8 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	549000ef          	jal	80001c22 <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00009717          	auipc	a4,0x9
    80000ee8:	38f72e23          	sw	a5,924(a4) # 8000a280 <started>
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
    80000efc:	3907b783          	ld	a5,912(a5) # 8000a288 <kernel_pagetable>
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
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb5e7>
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
    80001166:	634000ef          	jal	8000179a <proc_mapstacks>
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
    80001188:	10a7b223          	sd	a0,260(a5) # 8000a288 <kernel_pagetable>
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
    80001570:	3e0000ef          	jal	80001950 <myproc>
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

0000000080001754 <mlfq_enqueue>:
struct spinlock mlfq_lock;

// Enqueue a process to its priority queue (must hold mlfq_lock)
static void
mlfq_enqueue(struct proc *p)
{
    80001754:	1141                	addi	sp,sp,-16
    80001756:	e422                	sd	s0,8(sp)
    80001758:	0800                	addi	s0,sp,16
  int pri = p->priority;
    8000175a:	16852783          	lw	a5,360(a0)
  p->queue_next = 0;
    8000175e:	16053823          	sd	zero,368(a0)
  
  if(mlfq_tails[pri] == 0) {
    80001762:	00379693          	slli	a3,a5,0x3
    80001766:	00011717          	auipc	a4,0x11
    8000176a:	c4270713          	addi	a4,a4,-958 # 800123a8 <mlfq_tails>
    8000176e:	9736                	add	a4,a4,a3
    80001770:	6318                	ld	a4,0(a4)
    80001772:	cf09                	beqz	a4,8000178c <mlfq_enqueue+0x38>
    // Queue is empty
    mlfq_heads[pri] = p;
    mlfq_tails[pri] = p;
  } else {
    // Add to tail
    mlfq_tails[pri]->queue_next = p;
    80001774:	16a73823          	sd	a0,368(a4)
    mlfq_tails[pri] = p;
    80001778:	078e                	slli	a5,a5,0x3
    8000177a:	00011717          	auipc	a4,0x11
    8000177e:	c2e70713          	addi	a4,a4,-978 # 800123a8 <mlfq_tails>
    80001782:	97ba                	add	a5,a5,a4
    80001784:	e388                	sd	a0,0(a5)
    mlfq_tails[pri] = p;
  }
}
    80001786:	6422                	ld	s0,8(sp)
    80001788:	0141                	addi	sp,sp,16
    8000178a:	8082                	ret
    mlfq_heads[pri] = p;
    8000178c:	00011717          	auipc	a4,0x11
    80001790:	c1c70713          	addi	a4,a4,-996 # 800123a8 <mlfq_tails>
    80001794:	9736                	add	a4,a4,a3
    80001796:	f308                	sd	a0,32(a4)
    mlfq_tails[pri] = p;
    80001798:	b7c5                	j	80001778 <mlfq_enqueue+0x24>

000000008000179a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000179a:	7139                	addi	sp,sp,-64
    8000179c:	fc06                	sd	ra,56(sp)
    8000179e:	f822                	sd	s0,48(sp)
    800017a0:	f426                	sd	s1,40(sp)
    800017a2:	f04a                	sd	s2,32(sp)
    800017a4:	ec4e                	sd	s3,24(sp)
    800017a6:	e852                	sd	s4,16(sp)
    800017a8:	e456                	sd	s5,8(sp)
    800017aa:	e05a                	sd	s6,0(sp)
    800017ac:	0080                	addi	s0,sp,64
    800017ae:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017b0:	00011497          	auipc	s1,0x11
    800017b4:	08048493          	addi	s1,s1,128 # 80012830 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	8b26                	mv	s6,s1
    800017ba:	00a36937          	lui	s2,0xa36
    800017be:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    800017c2:	0932                	slli	s2,s2,0xc
    800017c4:	46d90913          	addi	s2,s2,1133
    800017c8:	0936                	slli	s2,s2,0xd
    800017ca:	df590913          	addi	s2,s2,-523
    800017ce:	093a                	slli	s2,s2,0xe
    800017d0:	6cf90913          	addi	s2,s2,1743
    800017d4:	040009b7          	lui	s3,0x4000
    800017d8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017da:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017dc:	00017a97          	auipc	s5,0x17
    800017e0:	e54a8a93          	addi	s5,s5,-428 # 80018630 <tickslock>
    char *pa = kalloc();
    800017e4:	b1aff0ef          	jal	80000afe <kalloc>
    800017e8:	862a                	mv	a2,a0
    if(pa == 0)
    800017ea:	cd15                	beqz	a0,80001826 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017ec:	416485b3          	sub	a1,s1,s6
    800017f0:	858d                	srai	a1,a1,0x3
    800017f2:	032585b3          	mul	a1,a1,s2
    800017f6:	2585                	addiw	a1,a1,1
    800017f8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017fc:	4719                	li	a4,6
    800017fe:	6685                	lui	a3,0x1
    80001800:	40b985b3          	sub	a1,s3,a1
    80001804:	8552                	mv	a0,s4
    80001806:	899ff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000180a:	17848493          	addi	s1,s1,376
    8000180e:	fd549be3          	bne	s1,s5,800017e4 <proc_mapstacks+0x4a>
  }
}
    80001812:	70e2                	ld	ra,56(sp)
    80001814:	7442                	ld	s0,48(sp)
    80001816:	74a2                	ld	s1,40(sp)
    80001818:	7902                	ld	s2,32(sp)
    8000181a:	69e2                	ld	s3,24(sp)
    8000181c:	6a42                	ld	s4,16(sp)
    8000181e:	6aa2                	ld	s5,8(sp)
    80001820:	6b02                	ld	s6,0(sp)
    80001822:	6121                	addi	sp,sp,64
    80001824:	8082                	ret
      panic("kalloc");
    80001826:	00006517          	auipc	a0,0x6
    8000182a:	93250513          	addi	a0,a0,-1742 # 80007158 <etext+0x158>
    8000182e:	fb3fe0ef          	jal	800007e0 <panic>

0000000080001832 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001832:	7139                	addi	sp,sp,-64
    80001834:	fc06                	sd	ra,56(sp)
    80001836:	f822                	sd	s0,48(sp)
    80001838:	f426                	sd	s1,40(sp)
    8000183a:	f04a                	sd	s2,32(sp)
    8000183c:	ec4e                	sd	s3,24(sp)
    8000183e:	e852                	sd	s4,16(sp)
    80001840:	e456                	sd	s5,8(sp)
    80001842:	e05a                	sd	s6,0(sp)
    80001844:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001846:	00011497          	auipc	s1,0x11
    8000184a:	b6248493          	addi	s1,s1,-1182 # 800123a8 <mlfq_tails>
    8000184e:	00006597          	auipc	a1,0x6
    80001852:	91258593          	addi	a1,a1,-1774 # 80007160 <etext+0x160>
    80001856:	00011517          	auipc	a0,0x11
    8000185a:	b9250513          	addi	a0,a0,-1134 # 800123e8 <pid_lock>
    8000185e:	af0ff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001862:	00006597          	auipc	a1,0x6
    80001866:	90658593          	addi	a1,a1,-1786 # 80007168 <etext+0x168>
    8000186a:	00011517          	auipc	a0,0x11
    8000186e:	b9650513          	addi	a0,a0,-1130 # 80012400 <wait_lock>
    80001872:	adcff0ef          	jal	80000b4e <initlock>
  initlock(&mlfq_lock, "mlfq");
    80001876:	00006597          	auipc	a1,0x6
    8000187a:	90258593          	addi	a1,a1,-1790 # 80007178 <etext+0x178>
    8000187e:	00011517          	auipc	a0,0x11
    80001882:	b9a50513          	addi	a0,a0,-1126 # 80012418 <mlfq_lock>
    80001886:	ac8ff0ef          	jal	80000b4e <initlock>
  
  // Initialize MLFQ queues
  for(int i = 0; i < NMLFQ; i++) {
    mlfq_heads[i] = 0;
    8000188a:	0204b023          	sd	zero,32(s1)
    mlfq_tails[i] = 0;
    8000188e:	0004b023          	sd	zero,0(s1)
    mlfq_heads[i] = 0;
    80001892:	0204b423          	sd	zero,40(s1)
    mlfq_tails[i] = 0;
    80001896:	0004b423          	sd	zero,8(s1)
    mlfq_heads[i] = 0;
    8000189a:	0204b823          	sd	zero,48(s1)
    mlfq_tails[i] = 0;
    8000189e:	0004b823          	sd	zero,16(s1)
    mlfq_heads[i] = 0;
    800018a2:	0204bc23          	sd	zero,56(s1)
    mlfq_tails[i] = 0;
    800018a6:	0004bc23          	sd	zero,24(s1)
  }
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018aa:	00011497          	auipc	s1,0x11
    800018ae:	f8648493          	addi	s1,s1,-122 # 80012830 <proc>
      initlock(&p->lock, "proc");
    800018b2:	00006b17          	auipc	s6,0x6
    800018b6:	8ceb0b13          	addi	s6,s6,-1842 # 80007180 <etext+0x180>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800018ba:	8aa6                	mv	s5,s1
    800018bc:	00a36937          	lui	s2,0xa36
    800018c0:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    800018c4:	0932                	slli	s2,s2,0xc
    800018c6:	46d90913          	addi	s2,s2,1133
    800018ca:	0936                	slli	s2,s2,0xd
    800018cc:	df590913          	addi	s2,s2,-523
    800018d0:	093a                	slli	s2,s2,0xe
    800018d2:	6cf90913          	addi	s2,s2,1743
    800018d6:	040009b7          	lui	s3,0x4000
    800018da:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018dc:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018de:	00017a17          	auipc	s4,0x17
    800018e2:	d52a0a13          	addi	s4,s4,-686 # 80018630 <tickslock>
      initlock(&p->lock, "proc");
    800018e6:	85da                	mv	a1,s6
    800018e8:	8526                	mv	a0,s1
    800018ea:	a64ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    800018ee:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018f2:	415487b3          	sub	a5,s1,s5
    800018f6:	878d                	srai	a5,a5,0x3
    800018f8:	032787b3          	mul	a5,a5,s2
    800018fc:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdb5f1>
    800018fe:	00d7979b          	slliw	a5,a5,0xd
    80001902:	40f987b3          	sub	a5,s3,a5
    80001906:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001908:	17848493          	addi	s1,s1,376
    8000190c:	fd449de3          	bne	s1,s4,800018e6 <procinit+0xb4>
  }
}
    80001910:	70e2                	ld	ra,56(sp)
    80001912:	7442                	ld	s0,48(sp)
    80001914:	74a2                	ld	s1,40(sp)
    80001916:	7902                	ld	s2,32(sp)
    80001918:	69e2                	ld	s3,24(sp)
    8000191a:	6a42                	ld	s4,16(sp)
    8000191c:	6aa2                	ld	s5,8(sp)
    8000191e:	6b02                	ld	s6,0(sp)
    80001920:	6121                	addi	sp,sp,64
    80001922:	8082                	ret

0000000080001924 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001924:	1141                	addi	sp,sp,-16
    80001926:	e422                	sd	s0,8(sp)
    80001928:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000192a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000192c:	2501                	sext.w	a0,a0
    8000192e:	6422                	ld	s0,8(sp)
    80001930:	0141                	addi	sp,sp,16
    80001932:	8082                	ret

0000000080001934 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001934:	1141                	addi	sp,sp,-16
    80001936:	e422                	sd	s0,8(sp)
    80001938:	0800                	addi	s0,sp,16
    8000193a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000193c:	2781                	sext.w	a5,a5
    8000193e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001940:	00011517          	auipc	a0,0x11
    80001944:	af050513          	addi	a0,a0,-1296 # 80012430 <cpus>
    80001948:	953e                	add	a0,a0,a5
    8000194a:	6422                	ld	s0,8(sp)
    8000194c:	0141                	addi	sp,sp,16
    8000194e:	8082                	ret

0000000080001950 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001950:	1101                	addi	sp,sp,-32
    80001952:	ec06                	sd	ra,24(sp)
    80001954:	e822                	sd	s0,16(sp)
    80001956:	e426                	sd	s1,8(sp)
    80001958:	1000                	addi	s0,sp,32
  push_off();
    8000195a:	a34ff0ef          	jal	80000b8e <push_off>
    8000195e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001960:	2781                	sext.w	a5,a5
    80001962:	079e                	slli	a5,a5,0x7
    80001964:	00011717          	auipc	a4,0x11
    80001968:	a4470713          	addi	a4,a4,-1468 # 800123a8 <mlfq_tails>
    8000196c:	97ba                	add	a5,a5,a4
    8000196e:	67c4                	ld	s1,136(a5)
  pop_off();
    80001970:	aa2ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    80001974:	8526                	mv	a0,s1
    80001976:	60e2                	ld	ra,24(sp)
    80001978:	6442                	ld	s0,16(sp)
    8000197a:	64a2                	ld	s1,8(sp)
    8000197c:	6105                	addi	sp,sp,32
    8000197e:	8082                	ret

0000000080001980 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001980:	7179                	addi	sp,sp,-48
    80001982:	f406                	sd	ra,40(sp)
    80001984:	f022                	sd	s0,32(sp)
    80001986:	ec26                	sd	s1,24(sp)
    80001988:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000198a:	fc7ff0ef          	jal	80001950 <myproc>
    8000198e:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001990:	ad6ff0ef          	jal	80000c66 <release>

  if (first) {
    80001994:	00009797          	auipc	a5,0x9
    80001998:	89c7a783          	lw	a5,-1892(a5) # 8000a230 <first.1>
    8000199c:	cf8d                	beqz	a5,800019d6 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000199e:	4505                	li	a0,1
    800019a0:	627010ef          	jal	800037c6 <fsinit>

    first = 0;
    800019a4:	00009797          	auipc	a5,0x9
    800019a8:	8807a623          	sw	zero,-1908(a5) # 8000a230 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    800019ac:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    800019b0:	00005517          	auipc	a0,0x5
    800019b4:	7d850513          	addi	a0,a0,2008 # 80007188 <etext+0x188>
    800019b8:	fca43823          	sd	a0,-48(s0)
    800019bc:	fc043c23          	sd	zero,-40(s0)
    800019c0:	fd040593          	addi	a1,s0,-48
    800019c4:	70d020ef          	jal	800048d0 <kexec>
    800019c8:	6cbc                	ld	a5,88(s1)
    800019ca:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019cc:	6cbc                	ld	a5,88(s1)
    800019ce:	7bb8                	ld	a4,112(a5)
    800019d0:	57fd                	li	a5,-1
    800019d2:	02f70d63          	beq	a4,a5,80001a0c <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019d6:	483000ef          	jal	80002658 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019da:	68a8                	ld	a0,80(s1)
    800019dc:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019de:	04000737          	lui	a4,0x4000
    800019e2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019e4:	0732                	slli	a4,a4,0xc
    800019e6:	00004797          	auipc	a5,0x4
    800019ea:	6b678793          	addi	a5,a5,1718 # 8000609c <userret>
    800019ee:	00004697          	auipc	a3,0x4
    800019f2:	61268693          	addi	a3,a3,1554 # 80006000 <_trampoline>
    800019f6:	8f95                	sub	a5,a5,a3
    800019f8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019fa:	577d                	li	a4,-1
    800019fc:	177e                	slli	a4,a4,0x3f
    800019fe:	8d59                	or	a0,a0,a4
    80001a00:	9782                	jalr	a5
}
    80001a02:	70a2                	ld	ra,40(sp)
    80001a04:	7402                	ld	s0,32(sp)
    80001a06:	64e2                	ld	s1,24(sp)
    80001a08:	6145                	addi	sp,sp,48
    80001a0a:	8082                	ret
      panic("exec");
    80001a0c:	00005517          	auipc	a0,0x5
    80001a10:	78450513          	addi	a0,a0,1924 # 80007190 <etext+0x190>
    80001a14:	dcdfe0ef          	jal	800007e0 <panic>

0000000080001a18 <allocpid>:
{
    80001a18:	1101                	addi	sp,sp,-32
    80001a1a:	ec06                	sd	ra,24(sp)
    80001a1c:	e822                	sd	s0,16(sp)
    80001a1e:	e426                	sd	s1,8(sp)
    80001a20:	e04a                	sd	s2,0(sp)
    80001a22:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a24:	00011917          	auipc	s2,0x11
    80001a28:	9c490913          	addi	s2,s2,-1596 # 800123e8 <pid_lock>
    80001a2c:	854a                	mv	a0,s2
    80001a2e:	9a0ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    80001a32:	00009797          	auipc	a5,0x9
    80001a36:	80278793          	addi	a5,a5,-2046 # 8000a234 <nextpid>
    80001a3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3c:	0014871b          	addiw	a4,s1,1
    80001a40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a42:	854a                	mv	a0,s2
    80001a44:	a22ff0ef          	jal	80000c66 <release>
}
    80001a48:	8526                	mv	a0,s1
    80001a4a:	60e2                	ld	ra,24(sp)
    80001a4c:	6442                	ld	s0,16(sp)
    80001a4e:	64a2                	ld	s1,8(sp)
    80001a50:	6902                	ld	s2,0(sp)
    80001a52:	6105                	addi	sp,sp,32
    80001a54:	8082                	ret

0000000080001a56 <proc_pagetable>:
{
    80001a56:	1101                	addi	sp,sp,-32
    80001a58:	ec06                	sd	ra,24(sp)
    80001a5a:	e822                	sd	s0,16(sp)
    80001a5c:	e426                	sd	s1,8(sp)
    80001a5e:	e04a                	sd	s2,0(sp)
    80001a60:	1000                	addi	s0,sp,32
    80001a62:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a64:	f30ff0ef          	jal	80001194 <uvmcreate>
    80001a68:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a6a:	cd05                	beqz	a0,80001aa2 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a6c:	4729                	li	a4,10
    80001a6e:	00004697          	auipc	a3,0x4
    80001a72:	59268693          	addi	a3,a3,1426 # 80006000 <_trampoline>
    80001a76:	6605                	lui	a2,0x1
    80001a78:	040005b7          	lui	a1,0x4000
    80001a7c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a7e:	05b2                	slli	a1,a1,0xc
    80001a80:	d6eff0ef          	jal	80000fee <mappages>
    80001a84:	02054663          	bltz	a0,80001ab0 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a88:	4719                	li	a4,6
    80001a8a:	05893683          	ld	a3,88(s2)
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	020005b7          	lui	a1,0x2000
    80001a94:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a96:	05b6                	slli	a1,a1,0xd
    80001a98:	8526                	mv	a0,s1
    80001a9a:	d54ff0ef          	jal	80000fee <mappages>
    80001a9e:	00054f63          	bltz	a0,80001abc <proc_pagetable+0x66>
}
    80001aa2:	8526                	mv	a0,s1
    80001aa4:	60e2                	ld	ra,24(sp)
    80001aa6:	6442                	ld	s0,16(sp)
    80001aa8:	64a2                	ld	s1,8(sp)
    80001aaa:	6902                	ld	s2,0(sp)
    80001aac:	6105                	addi	sp,sp,32
    80001aae:	8082                	ret
    uvmfree(pagetable, 0);
    80001ab0:	4581                	li	a1,0
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	8dbff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001ab8:	4481                	li	s1,0
    80001aba:	b7e5                	j	80001aa2 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001abc:	4681                	li	a3,0
    80001abe:	4605                	li	a2,1
    80001ac0:	040005b7          	lui	a1,0x4000
    80001ac4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ac6:	05b2                	slli	a1,a1,0xc
    80001ac8:	8526                	mv	a0,s1
    80001aca:	ef0ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001ace:	4581                	li	a1,0
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	8bdff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	b7e9                	j	80001aa2 <proc_pagetable+0x4c>

0000000080001ada <proc_freepagetable>:
{
    80001ada:	1101                	addi	sp,sp,-32
    80001adc:	ec06                	sd	ra,24(sp)
    80001ade:	e822                	sd	s0,16(sp)
    80001ae0:	e426                	sd	s1,8(sp)
    80001ae2:	e04a                	sd	s2,0(sp)
    80001ae4:	1000                	addi	s0,sp,32
    80001ae6:	84aa                	mv	s1,a0
    80001ae8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aea:	4681                	li	a3,0
    80001aec:	4605                	li	a2,1
    80001aee:	040005b7          	lui	a1,0x4000
    80001af2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af4:	05b2                	slli	a1,a1,0xc
    80001af6:	ec4ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001afa:	4681                	li	a3,0
    80001afc:	4605                	li	a2,1
    80001afe:	020005b7          	lui	a1,0x2000
    80001b02:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b04:	05b6                	slli	a1,a1,0xd
    80001b06:	8526                	mv	a0,s1
    80001b08:	eb2ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001b0c:	85ca                	mv	a1,s2
    80001b0e:	8526                	mv	a0,s1
    80001b10:	87fff0ef          	jal	8000138e <uvmfree>
}
    80001b14:	60e2                	ld	ra,24(sp)
    80001b16:	6442                	ld	s0,16(sp)
    80001b18:	64a2                	ld	s1,8(sp)
    80001b1a:	6902                	ld	s2,0(sp)
    80001b1c:	6105                	addi	sp,sp,32
    80001b1e:	8082                	ret

0000000080001b20 <freeproc>:
{
    80001b20:	1101                	addi	sp,sp,-32
    80001b22:	ec06                	sd	ra,24(sp)
    80001b24:	e822                	sd	s0,16(sp)
    80001b26:	e426                	sd	s1,8(sp)
    80001b28:	1000                	addi	s0,sp,32
    80001b2a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b2c:	6d28                	ld	a0,88(a0)
    80001b2e:	c119                	beqz	a0,80001b34 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b30:	eedfe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001b34:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b38:	68a8                	ld	a0,80(s1)
    80001b3a:	c501                	beqz	a0,80001b42 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b3c:	64ac                	ld	a1,72(s1)
    80001b3e:	f9dff0ef          	jal	80001ada <proc_freepagetable>
  p->pagetable = 0;
    80001b42:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b46:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b4a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b4e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b52:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b56:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b5a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b5e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b62:	0004ac23          	sw	zero,24(s1)
}
    80001b66:	60e2                	ld	ra,24(sp)
    80001b68:	6442                	ld	s0,16(sp)
    80001b6a:	64a2                	ld	s1,8(sp)
    80001b6c:	6105                	addi	sp,sp,32
    80001b6e:	8082                	ret

0000000080001b70 <allocproc>:
{
    80001b70:	1101                	addi	sp,sp,-32
    80001b72:	ec06                	sd	ra,24(sp)
    80001b74:	e822                	sd	s0,16(sp)
    80001b76:	e426                	sd	s1,8(sp)
    80001b78:	e04a                	sd	s2,0(sp)
    80001b7a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b7c:	00011497          	auipc	s1,0x11
    80001b80:	cb448493          	addi	s1,s1,-844 # 80012830 <proc>
    80001b84:	00017917          	auipc	s2,0x17
    80001b88:	aac90913          	addi	s2,s2,-1364 # 80018630 <tickslock>
    acquire(&p->lock);
    80001b8c:	8526                	mv	a0,s1
    80001b8e:	840ff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b92:	4c9c                	lw	a5,24(s1)
    80001b94:	cb91                	beqz	a5,80001ba8 <allocproc+0x38>
      release(&p->lock);
    80001b96:	8526                	mv	a0,s1
    80001b98:	8ceff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b9c:	17848493          	addi	s1,s1,376
    80001ba0:	ff2496e3          	bne	s1,s2,80001b8c <allocproc+0x1c>
  return 0;
    80001ba4:	4481                	li	s1,0
    80001ba6:	a0b9                	j	80001bf4 <allocproc+0x84>
  p->pid = allocpid();
    80001ba8:	e71ff0ef          	jal	80001a18 <allocpid>
    80001bac:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bae:	4785                	li	a5,1
    80001bb0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bb2:	f4dfe0ef          	jal	80000afe <kalloc>
    80001bb6:	892a                	mv	s2,a0
    80001bb8:	eca8                	sd	a0,88(s1)
    80001bba:	c521                	beqz	a0,80001c02 <allocproc+0x92>
  p->pagetable = proc_pagetable(p);
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	e99ff0ef          	jal	80001a56 <proc_pagetable>
    80001bc2:	892a                	mv	s2,a0
    80001bc4:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001bc6:	c531                	beqz	a0,80001c12 <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80001bc8:	07000613          	li	a2,112
    80001bcc:	4581                	li	a1,0
    80001bce:	06048513          	addi	a0,s1,96
    80001bd2:	8d0ff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001bd6:	00000797          	auipc	a5,0x0
    80001bda:	daa78793          	addi	a5,a5,-598 # 80001980 <forkret>
    80001bde:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001be0:	60bc                	ld	a5,64(s1)
    80001be2:	6705                	lui	a4,0x1
    80001be4:	97ba                	add	a5,a5,a4
    80001be6:	f4bc                	sd	a5,104(s1)
  p->priority = 0;
    80001be8:	1604a423          	sw	zero,360(s1)
  p->time_slices = 0;
    80001bec:	1604a623          	sw	zero,364(s1)
  p->queue_next = 0;
    80001bf0:	1604b823          	sd	zero,368(s1)
}
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	60e2                	ld	ra,24(sp)
    80001bf8:	6442                	ld	s0,16(sp)
    80001bfa:	64a2                	ld	s1,8(sp)
    80001bfc:	6902                	ld	s2,0(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret
    freeproc(p);
    80001c02:	8526                	mv	a0,s1
    80001c04:	f1dff0ef          	jal	80001b20 <freeproc>
    release(&p->lock);
    80001c08:	8526                	mv	a0,s1
    80001c0a:	85cff0ef          	jal	80000c66 <release>
    return 0;
    80001c0e:	84ca                	mv	s1,s2
    80001c10:	b7d5                	j	80001bf4 <allocproc+0x84>
    freeproc(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	f0dff0ef          	jal	80001b20 <freeproc>
    release(&p->lock);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	84cff0ef          	jal	80000c66 <release>
    return 0;
    80001c1e:	84ca                	mv	s1,s2
    80001c20:	bfd1                	j	80001bf4 <allocproc+0x84>

0000000080001c22 <userinit>:
{
    80001c22:	1101                	addi	sp,sp,-32
    80001c24:	ec06                	sd	ra,24(sp)
    80001c26:	e822                	sd	s0,16(sp)
    80001c28:	e426                	sd	s1,8(sp)
    80001c2a:	e04a                	sd	s2,0(sp)
    80001c2c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c2e:	f43ff0ef          	jal	80001b70 <allocproc>
    80001c32:	84aa                	mv	s1,a0
  initproc = p;
    80001c34:	00008797          	auipc	a5,0x8
    80001c38:	66a7b223          	sd	a0,1636(a5) # 8000a298 <initproc>
  p->cwd = namei("/");
    80001c3c:	00005517          	auipc	a0,0x5
    80001c40:	55c50513          	addi	a0,a0,1372 # 80007198 <etext+0x198>
    80001c44:	0a4020ef          	jal	80003ce8 <namei>
    80001c48:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c4c:	478d                	li	a5,3
    80001c4e:	cc9c                	sw	a5,24(s1)
  acquire(&mlfq_lock);
    80001c50:	00010917          	auipc	s2,0x10
    80001c54:	7c890913          	addi	s2,s2,1992 # 80012418 <mlfq_lock>
    80001c58:	854a                	mv	a0,s2
    80001c5a:	f75fe0ef          	jal	80000bce <acquire>
  mlfq_enqueue(p);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	af5ff0ef          	jal	80001754 <mlfq_enqueue>
  release(&mlfq_lock);
    80001c64:	854a                	mv	a0,s2
    80001c66:	800ff0ef          	jal	80000c66 <release>
  release(&p->lock);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	ffbfe0ef          	jal	80000c66 <release>
}
    80001c70:	60e2                	ld	ra,24(sp)
    80001c72:	6442                	ld	s0,16(sp)
    80001c74:	64a2                	ld	s1,8(sp)
    80001c76:	6902                	ld	s2,0(sp)
    80001c78:	6105                	addi	sp,sp,32
    80001c7a:	8082                	ret

0000000080001c7c <growproc>:
{
    80001c7c:	1101                	addi	sp,sp,-32
    80001c7e:	ec06                	sd	ra,24(sp)
    80001c80:	e822                	sd	s0,16(sp)
    80001c82:	e426                	sd	s1,8(sp)
    80001c84:	e04a                	sd	s2,0(sp)
    80001c86:	1000                	addi	s0,sp,32
    80001c88:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c8a:	cc7ff0ef          	jal	80001950 <myproc>
    80001c8e:	892a                	mv	s2,a0
  sz = p->sz;
    80001c90:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c92:	02905963          	blez	s1,80001cc4 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c96:	00b48633          	add	a2,s1,a1
    80001c9a:	020007b7          	lui	a5,0x2000
    80001c9e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001ca0:	07b6                	slli	a5,a5,0xd
    80001ca2:	02c7ea63          	bltu	a5,a2,80001cd6 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ca6:	4691                	li	a3,4
    80001ca8:	6928                	ld	a0,80(a0)
    80001caa:	ddeff0ef          	jal	80001288 <uvmalloc>
    80001cae:	85aa                	mv	a1,a0
    80001cb0:	c50d                	beqz	a0,80001cda <growproc+0x5e>
  p->sz = sz;
    80001cb2:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cb6:	4501                	li	a0,0
}
    80001cb8:	60e2                	ld	ra,24(sp)
    80001cba:	6442                	ld	s0,16(sp)
    80001cbc:	64a2                	ld	s1,8(sp)
    80001cbe:	6902                	ld	s2,0(sp)
    80001cc0:	6105                	addi	sp,sp,32
    80001cc2:	8082                	ret
  } else if(n < 0){
    80001cc4:	fe04d7e3          	bgez	s1,80001cb2 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cc8:	00b48633          	add	a2,s1,a1
    80001ccc:	6928                	ld	a0,80(a0)
    80001cce:	d76ff0ef          	jal	80001244 <uvmdealloc>
    80001cd2:	85aa                	mv	a1,a0
    80001cd4:	bff9                	j	80001cb2 <growproc+0x36>
      return -1;
    80001cd6:	557d                	li	a0,-1
    80001cd8:	b7c5                	j	80001cb8 <growproc+0x3c>
      return -1;
    80001cda:	557d                	li	a0,-1
    80001cdc:	bff1                	j	80001cb8 <growproc+0x3c>

0000000080001cde <kfork>:
{
    80001cde:	7139                	addi	sp,sp,-64
    80001ce0:	fc06                	sd	ra,56(sp)
    80001ce2:	f822                	sd	s0,48(sp)
    80001ce4:	f04a                	sd	s2,32(sp)
    80001ce6:	e456                	sd	s5,8(sp)
    80001ce8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cea:	c67ff0ef          	jal	80001950 <myproc>
    80001cee:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001cf0:	e81ff0ef          	jal	80001b70 <allocproc>
    80001cf4:	10050763          	beqz	a0,80001e02 <kfork+0x124>
    80001cf8:	ec4e                	sd	s3,24(sp)
    80001cfa:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001cfc:	048ab603          	ld	a2,72(s5)
    80001d00:	692c                	ld	a1,80(a0)
    80001d02:	050ab503          	ld	a0,80(s5)
    80001d06:	ebaff0ef          	jal	800013c0 <uvmcopy>
    80001d0a:	04054a63          	bltz	a0,80001d5e <kfork+0x80>
    80001d0e:	f426                	sd	s1,40(sp)
    80001d10:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001d12:	048ab783          	ld	a5,72(s5)
    80001d16:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001d1a:	058ab683          	ld	a3,88(s5)
    80001d1e:	87b6                	mv	a5,a3
    80001d20:	0589b703          	ld	a4,88(s3)
    80001d24:	12068693          	addi	a3,a3,288
    80001d28:	0007b803          	ld	a6,0(a5)
    80001d2c:	6788                	ld	a0,8(a5)
    80001d2e:	6b8c                	ld	a1,16(a5)
    80001d30:	6f90                	ld	a2,24(a5)
    80001d32:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001d36:	e708                	sd	a0,8(a4)
    80001d38:	eb0c                	sd	a1,16(a4)
    80001d3a:	ef10                	sd	a2,24(a4)
    80001d3c:	02078793          	addi	a5,a5,32
    80001d40:	02070713          	addi	a4,a4,32
    80001d44:	fed792e3          	bne	a5,a3,80001d28 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d48:	0589b783          	ld	a5,88(s3)
    80001d4c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d50:	0d0a8493          	addi	s1,s5,208
    80001d54:	0d098913          	addi	s2,s3,208
    80001d58:	150a8a13          	addi	s4,s5,336
    80001d5c:	a831                	j	80001d78 <kfork+0x9a>
    freeproc(np);
    80001d5e:	854e                	mv	a0,s3
    80001d60:	dc1ff0ef          	jal	80001b20 <freeproc>
    release(&np->lock);
    80001d64:	854e                	mv	a0,s3
    80001d66:	f01fe0ef          	jal	80000c66 <release>
    return -1;
    80001d6a:	597d                	li	s2,-1
    80001d6c:	69e2                	ld	s3,24(sp)
    80001d6e:	a059                	j	80001df4 <kfork+0x116>
  for(i = 0; i < NOFILE; i++)
    80001d70:	04a1                	addi	s1,s1,8
    80001d72:	0921                	addi	s2,s2,8
    80001d74:	01448963          	beq	s1,s4,80001d86 <kfork+0xa8>
    if(p->ofile[i])
    80001d78:	6088                	ld	a0,0(s1)
    80001d7a:	d97d                	beqz	a0,80001d70 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d7c:	506020ef          	jal	80004282 <filedup>
    80001d80:	00a93023          	sd	a0,0(s2)
    80001d84:	b7f5                	j	80001d70 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d86:	150ab503          	ld	a0,336(s5)
    80001d8a:	712010ef          	jal	8000349c <idup>
    80001d8e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d92:	4641                	li	a2,16
    80001d94:	158a8593          	addi	a1,s5,344
    80001d98:	15898513          	addi	a0,s3,344
    80001d9c:	844ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001da0:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001da4:	854e                	mv	a0,s3
    80001da6:	ec1fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001daa:	00010497          	auipc	s1,0x10
    80001dae:	65648493          	addi	s1,s1,1622 # 80012400 <wait_lock>
    80001db2:	8526                	mv	a0,s1
    80001db4:	e1bfe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001db8:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	ea9fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001dc2:	854e                	mv	a0,s3
    80001dc4:	e0bfe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001dc8:	478d                	li	a5,3
    80001dca:	00f9ac23          	sw	a5,24(s3)
  acquire(&mlfq_lock);
    80001dce:	00010497          	auipc	s1,0x10
    80001dd2:	64a48493          	addi	s1,s1,1610 # 80012418 <mlfq_lock>
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	df7fe0ef          	jal	80000bce <acquire>
  mlfq_enqueue(np);
    80001ddc:	854e                	mv	a0,s3
    80001dde:	977ff0ef          	jal	80001754 <mlfq_enqueue>
  release(&mlfq_lock);
    80001de2:	8526                	mv	a0,s1
    80001de4:	e83fe0ef          	jal	80000c66 <release>
  release(&np->lock);
    80001de8:	854e                	mv	a0,s3
    80001dea:	e7dfe0ef          	jal	80000c66 <release>
  return pid;
    80001dee:	74a2                	ld	s1,40(sp)
    80001df0:	69e2                	ld	s3,24(sp)
    80001df2:	6a42                	ld	s4,16(sp)
}
    80001df4:	854a                	mv	a0,s2
    80001df6:	70e2                	ld	ra,56(sp)
    80001df8:	7442                	ld	s0,48(sp)
    80001dfa:	7902                	ld	s2,32(sp)
    80001dfc:	6aa2                	ld	s5,8(sp)
    80001dfe:	6121                	addi	sp,sp,64
    80001e00:	8082                	ret
    return -1;
    80001e02:	597d                	li	s2,-1
    80001e04:	bfc5                	j	80001df4 <kfork+0x116>

0000000080001e06 <boost_all_priorities>:
{
    80001e06:	7179                	addi	sp,sp,-48
    80001e08:	f406                	sd	ra,40(sp)
    80001e0a:	f022                	sd	s0,32(sp)
    80001e0c:	ec26                	sd	s1,24(sp)
    80001e0e:	e84a                	sd	s2,16(sp)
    80001e10:	e44e                	sd	s3,8(sp)
    80001e12:	e052                	sd	s4,0(sp)
    80001e14:	1800                	addi	s0,sp,48
  acquire(&mlfq_lock);
    80001e16:	00010497          	auipc	s1,0x10
    80001e1a:	59248493          	addi	s1,s1,1426 # 800123a8 <mlfq_tails>
    80001e1e:	00010517          	auipc	a0,0x10
    80001e22:	5fa50513          	addi	a0,a0,1530 # 80012418 <mlfq_lock>
    80001e26:	da9fe0ef          	jal	80000bce <acquire>
    mlfq_heads[i] = 0;
    80001e2a:	0204b023          	sd	zero,32(s1)
    mlfq_tails[i] = 0;
    80001e2e:	0004b023          	sd	zero,0(s1)
    mlfq_heads[i] = 0;
    80001e32:	0204b423          	sd	zero,40(s1)
    mlfq_tails[i] = 0;
    80001e36:	0004b423          	sd	zero,8(s1)
    mlfq_heads[i] = 0;
    80001e3a:	0204b823          	sd	zero,48(s1)
    mlfq_tails[i] = 0;
    80001e3e:	0004b823          	sd	zero,16(s1)
    mlfq_heads[i] = 0;
    80001e42:	0204bc23          	sd	zero,56(s1)
    mlfq_tails[i] = 0;
    80001e46:	0004bc23          	sd	zero,24(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e4a:	00011497          	auipc	s1,0x11
    80001e4e:	9e648493          	addi	s1,s1,-1562 # 80012830 <proc>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001e52:	4989                	li	s3,2
      if(p->state == RUNNABLE) {
    80001e54:	4a0d                	li	s4,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e56:	00016917          	auipc	s2,0x16
    80001e5a:	7da90913          	addi	s2,s2,2010 # 80018630 <tickslock>
    80001e5e:	a801                	j	80001e6e <boost_all_priorities+0x68>
    release(&p->lock);
    80001e60:	8526                	mv	a0,s1
    80001e62:	e05fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e66:	17848493          	addi	s1,s1,376
    80001e6a:	03248663          	beq	s1,s2,80001e96 <boost_all_priorities+0x90>
    acquire(&p->lock);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	d5ffe0ef          	jal	80000bce <acquire>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001e74:	4c9c                	lw	a5,24(s1)
    80001e76:	ffe7871b          	addiw	a4,a5,-2
    80001e7a:	fee9e3e3          	bltu	s3,a4,80001e60 <boost_all_priorities+0x5a>
      p->priority = 0;
    80001e7e:	1604a423          	sw	zero,360(s1)
      p->time_slices = 0;
    80001e82:	1604a623          	sw	zero,364(s1)
      p->queue_next = 0;
    80001e86:	1604b823          	sd	zero,368(s1)
      if(p->state == RUNNABLE) {
    80001e8a:	fd479be3          	bne	a5,s4,80001e60 <boost_all_priorities+0x5a>
        mlfq_enqueue(p);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	8c5ff0ef          	jal	80001754 <mlfq_enqueue>
    80001e94:	b7f1                	j	80001e60 <boost_all_priorities+0x5a>
  release(&mlfq_lock);
    80001e96:	00010517          	auipc	a0,0x10
    80001e9a:	58250513          	addi	a0,a0,1410 # 80012418 <mlfq_lock>
    80001e9e:	dc9fe0ef          	jal	80000c66 <release>
}
    80001ea2:	70a2                	ld	ra,40(sp)
    80001ea4:	7402                	ld	s0,32(sp)
    80001ea6:	64e2                	ld	s1,24(sp)
    80001ea8:	6942                	ld	s2,16(sp)
    80001eaa:	69a2                	ld	s3,8(sp)
    80001eac:	6a02                	ld	s4,0(sp)
    80001eae:	6145                	addi	sp,sp,48
    80001eb0:	8082                	ret

0000000080001eb2 <scheduler>:
{
    80001eb2:	7159                	addi	sp,sp,-112
    80001eb4:	f486                	sd	ra,104(sp)
    80001eb6:	f0a2                	sd	s0,96(sp)
    80001eb8:	eca6                	sd	s1,88(sp)
    80001eba:	e8ca                	sd	s2,80(sp)
    80001ebc:	e4ce                	sd	s3,72(sp)
    80001ebe:	e0d2                	sd	s4,64(sp)
    80001ec0:	fc56                	sd	s5,56(sp)
    80001ec2:	f85a                	sd	s6,48(sp)
    80001ec4:	f45e                	sd	s7,40(sp)
    80001ec6:	f062                	sd	s8,32(sp)
    80001ec8:	ec66                	sd	s9,24(sp)
    80001eca:	e86a                	sd	s10,16(sp)
    80001ecc:	e46e                	sd	s11,8(sp)
    80001ece:	1880                	addi	s0,sp,112
    80001ed0:	8c92                	mv	s9,tp
  int id = r_tp();
    80001ed2:	2c81                	sext.w	s9,s9
  c->proc = 0;
    80001ed4:	007c9713          	slli	a4,s9,0x7
    80001ed8:	00010797          	auipc	a5,0x10
    80001edc:	4d078793          	addi	a5,a5,1232 # 800123a8 <mlfq_tails>
    80001ee0:	97ba                	add	a5,a5,a4
    80001ee2:	0807b423          	sd	zero,136(a5)
    acquire(&tickslock);
    80001ee6:	00016a97          	auipc	s5,0x16
    80001eea:	74aa8a93          	addi	s5,s5,1866 # 80018630 <tickslock>
    acquire(&mlfq_lock);
    80001eee:	00010917          	auipc	s2,0x10
    80001ef2:	52a90913          	addi	s2,s2,1322 # 80012418 <mlfq_lock>
  mlfq_heads[priority] = p->queue_next;
    80001ef6:	00010a17          	auipc	s4,0x10
    80001efa:	4b2a0a13          	addi	s4,s4,1202 # 800123a8 <mlfq_tails>
          c->proc = p;
    80001efe:	8d3e                	mv	s10,a5
          swtch(&c->context, &p->context);
    80001f00:	00010797          	auipc	a5,0x10
    80001f04:	53878793          	addi	a5,a5,1336 # 80012438 <cpus+0x8>
    80001f08:	00f70cb3          	add	s9,a4,a5
    80001f0c:	a815                	j	80001f40 <scheduler+0x8e>
      release(&tickslock);
    80001f0e:	8556                	mv	a0,s5
    80001f10:	d57fe0ef          	jal	80000c66 <release>
    80001f14:	a875                	j	80001fd0 <scheduler+0x11e>
    mlfq_tails[priority] = 0;
    80001f16:	00073023          	sd	zero,0(a4)
    80001f1a:	a8a1                	j	80001f72 <scheduler+0xc0>
          p->state = RUNNING;
    80001f1c:	4791                	li	a5,4
    80001f1e:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    80001f20:	089d3423          	sd	s1,136(s10) # 1088 <_entry-0x7fffef78>
          swtch(&c->context, &p->context);
    80001f24:	06048593          	addi	a1,s1,96
    80001f28:	8566                	mv	a0,s9
    80001f2a:	688000ef          	jal	800025b2 <swtch>
          c->proc = 0;
    80001f2e:	080d3423          	sd	zero,136(s10)
          found = 1;
    80001f32:	4d85                	li	s11,1
    80001f34:	a8a1                	j	80001f8c <scheduler+0xda>
      release(&mlfq_lock);
    80001f36:	854a                	mv	a0,s2
    80001f38:	d2ffe0ef          	jal	80000c66 <release>
      asm volatile("wfi");
    80001f3c:	10500073          	wfi
    uint64 current_ticks = ticks;
    80001f40:	00008c17          	auipc	s8,0x8
    80001f44:	360c0c13          	addi	s8,s8,864 # 8000a2a0 <ticks>
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001f48:	00008b17          	auipc	s6,0x8
    80001f4c:	348b0b13          	addi	s6,s6,840 # 8000a290 <last_boost_time>
    80001f50:	03100b93          	li	s7,49
    for(int priority = 0; priority < NMLFQ; priority++) {
    80001f54:	4991                	li	s3,4
    80001f56:	a081                	j	80001f96 <scheduler+0xe4>
    80001f58:	2785                	addiw	a5,a5,1
    80001f5a:	0721                	addi	a4,a4,8
    80001f5c:	fd378de3          	beq	a5,s3,80001f36 <scheduler+0x84>
  struct proc *p = mlfq_heads[priority];
    80001f60:	6304                	ld	s1,0(a4)
  if(p == 0)
    80001f62:	d8fd                	beqz	s1,80001f58 <scheduler+0xa6>
  mlfq_heads[priority] = p->queue_next;
    80001f64:	1704b683          	ld	a3,368(s1)
    80001f68:	00379713          	slli	a4,a5,0x3
    80001f6c:	9752                	add	a4,a4,s4
    80001f6e:	f314                	sd	a3,32(a4)
  if(mlfq_heads[priority] == 0) {
    80001f70:	d2dd                	beqz	a3,80001f16 <scheduler+0x64>
  p->queue_next = 0;
    80001f72:	1604b823          	sd	zero,368(s1)
        release(&mlfq_lock);
    80001f76:	854a                	mv	a0,s2
    80001f78:	ceffe0ef          	jal	80000c66 <release>
        acquire(&p->lock);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	c51fe0ef          	jal	80000bce <acquire>
        if(p->state == RUNNABLE) {
    80001f82:	4c98                	lw	a4,24(s1)
    80001f84:	478d                	li	a5,3
    int found = 0;
    80001f86:	4d81                	li	s11,0
        if(p->state == RUNNABLE) {
    80001f88:	f8f70ae3          	beq	a4,a5,80001f1c <scheduler+0x6a>
        release(&p->lock);
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	cd9fe0ef          	jal	80000c66 <release>
    if(!found) {
    80001f92:	fa0d82e3          	beqz	s11,80001f36 <scheduler+0x84>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f9a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f9e:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001fa6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fa8:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80001fac:	8556                	mv	a0,s5
    80001fae:	c21fe0ef          	jal	80000bce <acquire>
    uint64 current_ticks = ticks;
    80001fb2:	000c6703          	lwu	a4,0(s8)
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001fb6:	000b3783          	ld	a5,0(s6)
    80001fba:	40f707b3          	sub	a5,a4,a5
    80001fbe:	f4fbf8e3          	bgeu	s7,a5,80001f0e <scheduler+0x5c>
      last_boost_time = current_ticks;
    80001fc2:	00eb3023          	sd	a4,0(s6)
      release(&tickslock);
    80001fc6:	8556                	mv	a0,s5
    80001fc8:	c9ffe0ef          	jal	80000c66 <release>
      boost_all_priorities();
    80001fcc:	e3bff0ef          	jal	80001e06 <boost_all_priorities>
    acquire(&mlfq_lock);
    80001fd0:	854a                	mv	a0,s2
    80001fd2:	bfdfe0ef          	jal	80000bce <acquire>
    for(int priority = 0; priority < NMLFQ; priority++) {
    80001fd6:	00010717          	auipc	a4,0x10
    80001fda:	3f270713          	addi	a4,a4,1010 # 800123c8 <mlfq_heads>
    80001fde:	4781                	li	a5,0
    80001fe0:	b741                	j	80001f60 <scheduler+0xae>

0000000080001fe2 <sched>:
{
    80001fe2:	7179                	addi	sp,sp,-48
    80001fe4:	f406                	sd	ra,40(sp)
    80001fe6:	f022                	sd	s0,32(sp)
    80001fe8:	ec26                	sd	s1,24(sp)
    80001fea:	e84a                	sd	s2,16(sp)
    80001fec:	e44e                	sd	s3,8(sp)
    80001fee:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ff0:	961ff0ef          	jal	80001950 <myproc>
    80001ff4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ff6:	b6ffe0ef          	jal	80000b64 <holding>
    80001ffa:	c92d                	beqz	a0,8000206c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ffc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ffe:	2781                	sext.w	a5,a5
    80002000:	079e                	slli	a5,a5,0x7
    80002002:	00010717          	auipc	a4,0x10
    80002006:	3a670713          	addi	a4,a4,934 # 800123a8 <mlfq_tails>
    8000200a:	97ba                	add	a5,a5,a4
    8000200c:	1007a703          	lw	a4,256(a5)
    80002010:	4785                	li	a5,1
    80002012:	06f71363          	bne	a4,a5,80002078 <sched+0x96>
  if(p->state == RUNNING)
    80002016:	4c98                	lw	a4,24(s1)
    80002018:	4791                	li	a5,4
    8000201a:	06f70563          	beq	a4,a5,80002084 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000201e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002022:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002024:	e7b5                	bnez	a5,80002090 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002026:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002028:	00010917          	auipc	s2,0x10
    8000202c:	38090913          	addi	s2,s2,896 # 800123a8 <mlfq_tails>
    80002030:	2781                	sext.w	a5,a5
    80002032:	079e                	slli	a5,a5,0x7
    80002034:	97ca                	add	a5,a5,s2
    80002036:	1047a983          	lw	s3,260(a5)
    8000203a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000203c:	2781                	sext.w	a5,a5
    8000203e:	079e                	slli	a5,a5,0x7
    80002040:	00010597          	auipc	a1,0x10
    80002044:	3f858593          	addi	a1,a1,1016 # 80012438 <cpus+0x8>
    80002048:	95be                	add	a1,a1,a5
    8000204a:	06048513          	addi	a0,s1,96
    8000204e:	564000ef          	jal	800025b2 <swtch>
    80002052:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002054:	2781                	sext.w	a5,a5
    80002056:	079e                	slli	a5,a5,0x7
    80002058:	993e                	add	s2,s2,a5
    8000205a:	11392223          	sw	s3,260(s2)
}
    8000205e:	70a2                	ld	ra,40(sp)
    80002060:	7402                	ld	s0,32(sp)
    80002062:	64e2                	ld	s1,24(sp)
    80002064:	6942                	ld	s2,16(sp)
    80002066:	69a2                	ld	s3,8(sp)
    80002068:	6145                	addi	sp,sp,48
    8000206a:	8082                	ret
    panic("sched p->lock");
    8000206c:	00005517          	auipc	a0,0x5
    80002070:	13450513          	addi	a0,a0,308 # 800071a0 <etext+0x1a0>
    80002074:	f6cfe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80002078:	00005517          	auipc	a0,0x5
    8000207c:	13850513          	addi	a0,a0,312 # 800071b0 <etext+0x1b0>
    80002080:	f60fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80002084:	00005517          	auipc	a0,0x5
    80002088:	13c50513          	addi	a0,a0,316 # 800071c0 <etext+0x1c0>
    8000208c:	f54fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80002090:	00005517          	auipc	a0,0x5
    80002094:	14050513          	addi	a0,a0,320 # 800071d0 <etext+0x1d0>
    80002098:	f48fe0ef          	jal	800007e0 <panic>

000000008000209c <yield>:
{
    8000209c:	1101                	addi	sp,sp,-32
    8000209e:	ec06                	sd	ra,24(sp)
    800020a0:	e822                	sd	s0,16(sp)
    800020a2:	e426                	sd	s1,8(sp)
    800020a4:	e04a                	sd	s2,0(sp)
    800020a6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020a8:	8a9ff0ef          	jal	80001950 <myproc>
    800020ac:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ae:	b21fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    800020b2:	478d                	li	a5,3
    800020b4:	cc9c                	sw	a5,24(s1)
  acquire(&mlfq_lock);
    800020b6:	00010917          	auipc	s2,0x10
    800020ba:	36290913          	addi	s2,s2,866 # 80012418 <mlfq_lock>
    800020be:	854a                	mv	a0,s2
    800020c0:	b0ffe0ef          	jal	80000bce <acquire>
  mlfq_enqueue(p);
    800020c4:	8526                	mv	a0,s1
    800020c6:	e8eff0ef          	jal	80001754 <mlfq_enqueue>
  release(&mlfq_lock);
    800020ca:	854a                	mv	a0,s2
    800020cc:	b9bfe0ef          	jal	80000c66 <release>
  sched();
    800020d0:	f13ff0ef          	jal	80001fe2 <sched>
  release(&p->lock);
    800020d4:	8526                	mv	a0,s1
    800020d6:	b91fe0ef          	jal	80000c66 <release>
}
    800020da:	60e2                	ld	ra,24(sp)
    800020dc:	6442                	ld	s0,16(sp)
    800020de:	64a2                	ld	s1,8(sp)
    800020e0:	6902                	ld	s2,0(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020e6:	7179                	addi	sp,sp,-48
    800020e8:	f406                	sd	ra,40(sp)
    800020ea:	f022                	sd	s0,32(sp)
    800020ec:	ec26                	sd	s1,24(sp)
    800020ee:	e84a                	sd	s2,16(sp)
    800020f0:	e44e                	sd	s3,8(sp)
    800020f2:	1800                	addi	s0,sp,48
    800020f4:	89aa                	mv	s3,a0
    800020f6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020f8:	859ff0ef          	jal	80001950 <myproc>
    800020fc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020fe:	ad1fe0ef          	jal	80000bce <acquire>
  release(lk);
    80002102:	854a                	mv	a0,s2
    80002104:	b63fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80002108:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000210c:	4789                	li	a5,2
    8000210e:	cc9c                	sw	a5,24(s1)

  sched();
    80002110:	ed3ff0ef          	jal	80001fe2 <sched>

  // Tidy up.
  p->chan = 0;
    80002114:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002118:	8526                	mv	a0,s1
    8000211a:	b4dfe0ef          	jal	80000c66 <release>
  acquire(lk);
    8000211e:	854a                	mv	a0,s2
    80002120:	aaffe0ef          	jal	80000bce <acquire>
}
    80002124:	70a2                	ld	ra,40(sp)
    80002126:	7402                	ld	s0,32(sp)
    80002128:	64e2                	ld	s1,24(sp)
    8000212a:	6942                	ld	s2,16(sp)
    8000212c:	69a2                	ld	s3,8(sp)
    8000212e:	6145                	addi	sp,sp,48
    80002130:	8082                	ret

0000000080002132 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002132:	7139                	addi	sp,sp,-64
    80002134:	fc06                	sd	ra,56(sp)
    80002136:	f822                	sd	s0,48(sp)
    80002138:	f426                	sd	s1,40(sp)
    8000213a:	f04a                	sd	s2,32(sp)
    8000213c:	ec4e                	sd	s3,24(sp)
    8000213e:	e852                	sd	s4,16(sp)
    80002140:	e456                	sd	s5,8(sp)
    80002142:	e05a                	sd	s6,0(sp)
    80002144:	0080                	addi	s0,sp,64
    80002146:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002148:	00010497          	auipc	s1,0x10
    8000214c:	6e848493          	addi	s1,s1,1768 # 80012830 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002150:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002152:	4b0d                	li	s6,3
        
        // Enqueue to MLFQ
        acquire(&mlfq_lock);
    80002154:	00010a97          	auipc	s5,0x10
    80002158:	2c4a8a93          	addi	s5,s5,708 # 80012418 <mlfq_lock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000215c:	00016917          	auipc	s2,0x16
    80002160:	4d490913          	addi	s2,s2,1236 # 80018630 <tickslock>
    80002164:	a801                	j	80002174 <wakeup+0x42>
        mlfq_enqueue(p);
        release(&mlfq_lock);
      }
      release(&p->lock);
    80002166:	8526                	mv	a0,s1
    80002168:	afffe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000216c:	17848493          	addi	s1,s1,376
    80002170:	03248b63          	beq	s1,s2,800021a6 <wakeup+0x74>
    if(p != myproc()){
    80002174:	fdcff0ef          	jal	80001950 <myproc>
    80002178:	fea48ae3          	beq	s1,a0,8000216c <wakeup+0x3a>
      acquire(&p->lock);
    8000217c:	8526                	mv	a0,s1
    8000217e:	a51fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002182:	4c9c                	lw	a5,24(s1)
    80002184:	ff3791e3          	bne	a5,s3,80002166 <wakeup+0x34>
    80002188:	709c                	ld	a5,32(s1)
    8000218a:	fd479ee3          	bne	a5,s4,80002166 <wakeup+0x34>
        p->state = RUNNABLE;
    8000218e:	0164ac23          	sw	s6,24(s1)
        acquire(&mlfq_lock);
    80002192:	8556                	mv	a0,s5
    80002194:	a3bfe0ef          	jal	80000bce <acquire>
        mlfq_enqueue(p);
    80002198:	8526                	mv	a0,s1
    8000219a:	dbaff0ef          	jal	80001754 <mlfq_enqueue>
        release(&mlfq_lock);
    8000219e:	8556                	mv	a0,s5
    800021a0:	ac7fe0ef          	jal	80000c66 <release>
    800021a4:	b7c9                	j	80002166 <wakeup+0x34>
    }
  }
}
    800021a6:	70e2                	ld	ra,56(sp)
    800021a8:	7442                	ld	s0,48(sp)
    800021aa:	74a2                	ld	s1,40(sp)
    800021ac:	7902                	ld	s2,32(sp)
    800021ae:	69e2                	ld	s3,24(sp)
    800021b0:	6a42                	ld	s4,16(sp)
    800021b2:	6aa2                	ld	s5,8(sp)
    800021b4:	6b02                	ld	s6,0(sp)
    800021b6:	6121                	addi	sp,sp,64
    800021b8:	8082                	ret

00000000800021ba <reparent>:
{
    800021ba:	7179                	addi	sp,sp,-48
    800021bc:	f406                	sd	ra,40(sp)
    800021be:	f022                	sd	s0,32(sp)
    800021c0:	ec26                	sd	s1,24(sp)
    800021c2:	e84a                	sd	s2,16(sp)
    800021c4:	e44e                	sd	s3,8(sp)
    800021c6:	e052                	sd	s4,0(sp)
    800021c8:	1800                	addi	s0,sp,48
    800021ca:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021cc:	00010497          	auipc	s1,0x10
    800021d0:	66448493          	addi	s1,s1,1636 # 80012830 <proc>
      pp->parent = initproc;
    800021d4:	00008a17          	auipc	s4,0x8
    800021d8:	0c4a0a13          	addi	s4,s4,196 # 8000a298 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021dc:	00016997          	auipc	s3,0x16
    800021e0:	45498993          	addi	s3,s3,1108 # 80018630 <tickslock>
    800021e4:	a029                	j	800021ee <reparent+0x34>
    800021e6:	17848493          	addi	s1,s1,376
    800021ea:	01348b63          	beq	s1,s3,80002200 <reparent+0x46>
    if(pp->parent == p){
    800021ee:	7c9c                	ld	a5,56(s1)
    800021f0:	ff279be3          	bne	a5,s2,800021e6 <reparent+0x2c>
      pp->parent = initproc;
    800021f4:	000a3503          	ld	a0,0(s4)
    800021f8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021fa:	f39ff0ef          	jal	80002132 <wakeup>
    800021fe:	b7e5                	j	800021e6 <reparent+0x2c>
}
    80002200:	70a2                	ld	ra,40(sp)
    80002202:	7402                	ld	s0,32(sp)
    80002204:	64e2                	ld	s1,24(sp)
    80002206:	6942                	ld	s2,16(sp)
    80002208:	69a2                	ld	s3,8(sp)
    8000220a:	6a02                	ld	s4,0(sp)
    8000220c:	6145                	addi	sp,sp,48
    8000220e:	8082                	ret

0000000080002210 <kexit>:
{
    80002210:	7179                	addi	sp,sp,-48
    80002212:	f406                	sd	ra,40(sp)
    80002214:	f022                	sd	s0,32(sp)
    80002216:	ec26                	sd	s1,24(sp)
    80002218:	e84a                	sd	s2,16(sp)
    8000221a:	e44e                	sd	s3,8(sp)
    8000221c:	e052                	sd	s4,0(sp)
    8000221e:	1800                	addi	s0,sp,48
    80002220:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002222:	f2eff0ef          	jal	80001950 <myproc>
    80002226:	89aa                	mv	s3,a0
  if(p == initproc)
    80002228:	00008797          	auipc	a5,0x8
    8000222c:	0707b783          	ld	a5,112(a5) # 8000a298 <initproc>
    80002230:	0d050493          	addi	s1,a0,208
    80002234:	15050913          	addi	s2,a0,336
    80002238:	00a79f63          	bne	a5,a0,80002256 <kexit+0x46>
    panic("init exiting");
    8000223c:	00005517          	auipc	a0,0x5
    80002240:	fac50513          	addi	a0,a0,-84 # 800071e8 <etext+0x1e8>
    80002244:	d9cfe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002248:	080020ef          	jal	800042c8 <fileclose>
      p->ofile[fd] = 0;
    8000224c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002250:	04a1                	addi	s1,s1,8
    80002252:	01248563          	beq	s1,s2,8000225c <kexit+0x4c>
    if(p->ofile[fd]){
    80002256:	6088                	ld	a0,0(s1)
    80002258:	f965                	bnez	a0,80002248 <kexit+0x38>
    8000225a:	bfdd                	j	80002250 <kexit+0x40>
  begin_op();
    8000225c:	461010ef          	jal	80003ebc <begin_op>
  iput(p->cwd);
    80002260:	1509b503          	ld	a0,336(s3)
    80002264:	3f0010ef          	jal	80003654 <iput>
  end_op();
    80002268:	4bf010ef          	jal	80003f26 <end_op>
  p->cwd = 0;
    8000226c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002270:	00010497          	auipc	s1,0x10
    80002274:	19048493          	addi	s1,s1,400 # 80012400 <wait_lock>
    80002278:	8526                	mv	a0,s1
    8000227a:	955fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000227e:	854e                	mv	a0,s3
    80002280:	f3bff0ef          	jal	800021ba <reparent>
  wakeup(p->parent);
    80002284:	0389b503          	ld	a0,56(s3)
    80002288:	eabff0ef          	jal	80002132 <wakeup>
  acquire(&p->lock);
    8000228c:	854e                	mv	a0,s3
    8000228e:	941fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002292:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002296:	4795                	li	a5,5
    80002298:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000229c:	8526                	mv	a0,s1
    8000229e:	9c9fe0ef          	jal	80000c66 <release>
  sched();
    800022a2:	d41ff0ef          	jal	80001fe2 <sched>
  panic("zombie exit");
    800022a6:	00005517          	auipc	a0,0x5
    800022aa:	f5250513          	addi	a0,a0,-174 # 800071f8 <etext+0x1f8>
    800022ae:	d32fe0ef          	jal	800007e0 <panic>

00000000800022b2 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800022b2:	7179                	addi	sp,sp,-48
    800022b4:	f406                	sd	ra,40(sp)
    800022b6:	f022                	sd	s0,32(sp)
    800022b8:	ec26                	sd	s1,24(sp)
    800022ba:	e84a                	sd	s2,16(sp)
    800022bc:	e44e                	sd	s3,8(sp)
    800022be:	1800                	addi	s0,sp,48
    800022c0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022c2:	00010497          	auipc	s1,0x10
    800022c6:	56e48493          	addi	s1,s1,1390 # 80012830 <proc>
    800022ca:	00016997          	auipc	s3,0x16
    800022ce:	36698993          	addi	s3,s3,870 # 80018630 <tickslock>
    acquire(&p->lock);
    800022d2:	8526                	mv	a0,s1
    800022d4:	8fbfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800022d8:	589c                	lw	a5,48(s1)
    800022da:	01278b63          	beq	a5,s2,800022f0 <kkill+0x3e>
        release(&mlfq_lock);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022de:	8526                	mv	a0,s1
    800022e0:	987fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022e4:	17848493          	addi	s1,s1,376
    800022e8:	ff3495e3          	bne	s1,s3,800022d2 <kkill+0x20>
  }
  return -1;
    800022ec:	557d                	li	a0,-1
    800022ee:	a819                	j	80002304 <kkill+0x52>
      p->killed = 1;
    800022f0:	4785                	li	a5,1
    800022f2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022f4:	4c98                	lw	a4,24(s1)
    800022f6:	4789                	li	a5,2
    800022f8:	00f70d63          	beq	a4,a5,80002312 <kkill+0x60>
      release(&p->lock);
    800022fc:	8526                	mv	a0,s1
    800022fe:	969fe0ef          	jal	80000c66 <release>
      return 0;
    80002302:	4501                	li	a0,0
}
    80002304:	70a2                	ld	ra,40(sp)
    80002306:	7402                	ld	s0,32(sp)
    80002308:	64e2                	ld	s1,24(sp)
    8000230a:	6942                	ld	s2,16(sp)
    8000230c:	69a2                	ld	s3,8(sp)
    8000230e:	6145                	addi	sp,sp,48
    80002310:	8082                	ret
        p->state = RUNNABLE;
    80002312:	478d                	li	a5,3
    80002314:	cc9c                	sw	a5,24(s1)
        acquire(&mlfq_lock);
    80002316:	00010917          	auipc	s2,0x10
    8000231a:	10290913          	addi	s2,s2,258 # 80012418 <mlfq_lock>
    8000231e:	854a                	mv	a0,s2
    80002320:	8affe0ef          	jal	80000bce <acquire>
        mlfq_enqueue(p);
    80002324:	8526                	mv	a0,s1
    80002326:	c2eff0ef          	jal	80001754 <mlfq_enqueue>
        release(&mlfq_lock);
    8000232a:	854a                	mv	a0,s2
    8000232c:	93bfe0ef          	jal	80000c66 <release>
    80002330:	b7f1                	j	800022fc <kkill+0x4a>

0000000080002332 <setkilled>:

void
setkilled(struct proc *p)
{
    80002332:	1101                	addi	sp,sp,-32
    80002334:	ec06                	sd	ra,24(sp)
    80002336:	e822                	sd	s0,16(sp)
    80002338:	e426                	sd	s1,8(sp)
    8000233a:	1000                	addi	s0,sp,32
    8000233c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000233e:	891fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    80002342:	4785                	li	a5,1
    80002344:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002346:	8526                	mv	a0,s1
    80002348:	91ffe0ef          	jal	80000c66 <release>
}
    8000234c:	60e2                	ld	ra,24(sp)
    8000234e:	6442                	ld	s0,16(sp)
    80002350:	64a2                	ld	s1,8(sp)
    80002352:	6105                	addi	sp,sp,32
    80002354:	8082                	ret

0000000080002356 <killed>:

int
killed(struct proc *p)
{
    80002356:	1101                	addi	sp,sp,-32
    80002358:	ec06                	sd	ra,24(sp)
    8000235a:	e822                	sd	s0,16(sp)
    8000235c:	e426                	sd	s1,8(sp)
    8000235e:	e04a                	sd	s2,0(sp)
    80002360:	1000                	addi	s0,sp,32
    80002362:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002364:	86bfe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002368:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000236c:	8526                	mv	a0,s1
    8000236e:	8f9fe0ef          	jal	80000c66 <release>
  return k;
}
    80002372:	854a                	mv	a0,s2
    80002374:	60e2                	ld	ra,24(sp)
    80002376:	6442                	ld	s0,16(sp)
    80002378:	64a2                	ld	s1,8(sp)
    8000237a:	6902                	ld	s2,0(sp)
    8000237c:	6105                	addi	sp,sp,32
    8000237e:	8082                	ret

0000000080002380 <kwait>:
{
    80002380:	715d                	addi	sp,sp,-80
    80002382:	e486                	sd	ra,72(sp)
    80002384:	e0a2                	sd	s0,64(sp)
    80002386:	fc26                	sd	s1,56(sp)
    80002388:	f84a                	sd	s2,48(sp)
    8000238a:	f44e                	sd	s3,40(sp)
    8000238c:	f052                	sd	s4,32(sp)
    8000238e:	ec56                	sd	s5,24(sp)
    80002390:	e85a                	sd	s6,16(sp)
    80002392:	e45e                	sd	s7,8(sp)
    80002394:	e062                	sd	s8,0(sp)
    80002396:	0880                	addi	s0,sp,80
    80002398:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000239a:	db6ff0ef          	jal	80001950 <myproc>
    8000239e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023a0:	00010517          	auipc	a0,0x10
    800023a4:	06050513          	addi	a0,a0,96 # 80012400 <wait_lock>
    800023a8:	827fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    800023ac:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023ae:	4a15                	li	s4,5
        havekids = 1;
    800023b0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023b2:	00016997          	auipc	s3,0x16
    800023b6:	27e98993          	addi	s3,s3,638 # 80018630 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023ba:	00010c17          	auipc	s8,0x10
    800023be:	046c0c13          	addi	s8,s8,70 # 80012400 <wait_lock>
    800023c2:	a871                	j	8000245e <kwait+0xde>
          pid = pp->pid;
    800023c4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023c8:	000b0c63          	beqz	s6,800023e0 <kwait+0x60>
    800023cc:	4691                	li	a3,4
    800023ce:	02c48613          	addi	a2,s1,44
    800023d2:	85da                	mv	a1,s6
    800023d4:	05093503          	ld	a0,80(s2)
    800023d8:	a0aff0ef          	jal	800015e2 <copyout>
    800023dc:	02054b63          	bltz	a0,80002412 <kwait+0x92>
          freeproc(pp);
    800023e0:	8526                	mv	a0,s1
    800023e2:	f3eff0ef          	jal	80001b20 <freeproc>
          release(&pp->lock);
    800023e6:	8526                	mv	a0,s1
    800023e8:	87ffe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800023ec:	00010517          	auipc	a0,0x10
    800023f0:	01450513          	addi	a0,a0,20 # 80012400 <wait_lock>
    800023f4:	873fe0ef          	jal	80000c66 <release>
}
    800023f8:	854e                	mv	a0,s3
    800023fa:	60a6                	ld	ra,72(sp)
    800023fc:	6406                	ld	s0,64(sp)
    800023fe:	74e2                	ld	s1,56(sp)
    80002400:	7942                	ld	s2,48(sp)
    80002402:	79a2                	ld	s3,40(sp)
    80002404:	7a02                	ld	s4,32(sp)
    80002406:	6ae2                	ld	s5,24(sp)
    80002408:	6b42                	ld	s6,16(sp)
    8000240a:	6ba2                	ld	s7,8(sp)
    8000240c:	6c02                	ld	s8,0(sp)
    8000240e:	6161                	addi	sp,sp,80
    80002410:	8082                	ret
            release(&pp->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	853fe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    80002418:	00010517          	auipc	a0,0x10
    8000241c:	fe850513          	addi	a0,a0,-24 # 80012400 <wait_lock>
    80002420:	847fe0ef          	jal	80000c66 <release>
            return -1;
    80002424:	59fd                	li	s3,-1
    80002426:	bfc9                	j	800023f8 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002428:	17848493          	addi	s1,s1,376
    8000242c:	03348063          	beq	s1,s3,8000244c <kwait+0xcc>
      if(pp->parent == p){
    80002430:	7c9c                	ld	a5,56(s1)
    80002432:	ff279be3          	bne	a5,s2,80002428 <kwait+0xa8>
        acquire(&pp->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	f96fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    8000243c:	4c9c                	lw	a5,24(s1)
    8000243e:	f94783e3          	beq	a5,s4,800023c4 <kwait+0x44>
        release(&pp->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	823fe0ef          	jal	80000c66 <release>
        havekids = 1;
    80002448:	8756                	mv	a4,s5
    8000244a:	bff9                	j	80002428 <kwait+0xa8>
    if(!havekids || killed(p)){
    8000244c:	cf19                	beqz	a4,8000246a <kwait+0xea>
    8000244e:	854a                	mv	a0,s2
    80002450:	f07ff0ef          	jal	80002356 <killed>
    80002454:	e919                	bnez	a0,8000246a <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002456:	85e2                	mv	a1,s8
    80002458:	854a                	mv	a0,s2
    8000245a:	c8dff0ef          	jal	800020e6 <sleep>
    havekids = 0;
    8000245e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002460:	00010497          	auipc	s1,0x10
    80002464:	3d048493          	addi	s1,s1,976 # 80012830 <proc>
    80002468:	b7e1                	j	80002430 <kwait+0xb0>
      release(&wait_lock);
    8000246a:	00010517          	auipc	a0,0x10
    8000246e:	f9650513          	addi	a0,a0,-106 # 80012400 <wait_lock>
    80002472:	ff4fe0ef          	jal	80000c66 <release>
      return -1;
    80002476:	59fd                	li	s3,-1
    80002478:	b741                	j	800023f8 <kwait+0x78>

000000008000247a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000247a:	7179                	addi	sp,sp,-48
    8000247c:	f406                	sd	ra,40(sp)
    8000247e:	f022                	sd	s0,32(sp)
    80002480:	ec26                	sd	s1,24(sp)
    80002482:	e84a                	sd	s2,16(sp)
    80002484:	e44e                	sd	s3,8(sp)
    80002486:	e052                	sd	s4,0(sp)
    80002488:	1800                	addi	s0,sp,48
    8000248a:	84aa                	mv	s1,a0
    8000248c:	892e                	mv	s2,a1
    8000248e:	89b2                	mv	s3,a2
    80002490:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002492:	cbeff0ef          	jal	80001950 <myproc>
  if(user_dst){
    80002496:	cc99                	beqz	s1,800024b4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002498:	86d2                	mv	a3,s4
    8000249a:	864e                	mv	a2,s3
    8000249c:	85ca                	mv	a1,s2
    8000249e:	6928                	ld	a0,80(a0)
    800024a0:	942ff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024a4:	70a2                	ld	ra,40(sp)
    800024a6:	7402                	ld	s0,32(sp)
    800024a8:	64e2                	ld	s1,24(sp)
    800024aa:	6942                	ld	s2,16(sp)
    800024ac:	69a2                	ld	s3,8(sp)
    800024ae:	6a02                	ld	s4,0(sp)
    800024b0:	6145                	addi	sp,sp,48
    800024b2:	8082                	ret
    memmove((char *)dst, src, len);
    800024b4:	000a061b          	sext.w	a2,s4
    800024b8:	85ce                	mv	a1,s3
    800024ba:	854a                	mv	a0,s2
    800024bc:	843fe0ef          	jal	80000cfe <memmove>
    return 0;
    800024c0:	8526                	mv	a0,s1
    800024c2:	b7cd                	j	800024a4 <either_copyout+0x2a>

00000000800024c4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024c4:	7179                	addi	sp,sp,-48
    800024c6:	f406                	sd	ra,40(sp)
    800024c8:	f022                	sd	s0,32(sp)
    800024ca:	ec26                	sd	s1,24(sp)
    800024cc:	e84a                	sd	s2,16(sp)
    800024ce:	e44e                	sd	s3,8(sp)
    800024d0:	e052                	sd	s4,0(sp)
    800024d2:	1800                	addi	s0,sp,48
    800024d4:	892a                	mv	s2,a0
    800024d6:	84ae                	mv	s1,a1
    800024d8:	89b2                	mv	s3,a2
    800024da:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024dc:	c74ff0ef          	jal	80001950 <myproc>
  if(user_src){
    800024e0:	cc99                	beqz	s1,800024fe <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800024e2:	86d2                	mv	a3,s4
    800024e4:	864e                	mv	a2,s3
    800024e6:	85ca                	mv	a1,s2
    800024e8:	6928                	ld	a0,80(a0)
    800024ea:	9dcff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ee:	70a2                	ld	ra,40(sp)
    800024f0:	7402                	ld	s0,32(sp)
    800024f2:	64e2                	ld	s1,24(sp)
    800024f4:	6942                	ld	s2,16(sp)
    800024f6:	69a2                	ld	s3,8(sp)
    800024f8:	6a02                	ld	s4,0(sp)
    800024fa:	6145                	addi	sp,sp,48
    800024fc:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fe:	000a061b          	sext.w	a2,s4
    80002502:	85ce                	mv	a1,s3
    80002504:	854a                	mv	a0,s2
    80002506:	ff8fe0ef          	jal	80000cfe <memmove>
    return 0;
    8000250a:	8526                	mv	a0,s1
    8000250c:	b7cd                	j	800024ee <either_copyin+0x2a>

000000008000250e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000250e:	715d                	addi	sp,sp,-80
    80002510:	e486                	sd	ra,72(sp)
    80002512:	e0a2                	sd	s0,64(sp)
    80002514:	fc26                	sd	s1,56(sp)
    80002516:	f84a                	sd	s2,48(sp)
    80002518:	f44e                	sd	s3,40(sp)
    8000251a:	f052                	sd	s4,32(sp)
    8000251c:	ec56                	sd	s5,24(sp)
    8000251e:	e85a                	sd	s6,16(sp)
    80002520:	e45e                	sd	s7,8(sp)
    80002522:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002524:	00005517          	auipc	a0,0x5
    80002528:	b5450513          	addi	a0,a0,-1196 # 80007078 <etext+0x78>
    8000252c:	fcffd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002530:	00010497          	auipc	s1,0x10
    80002534:	45848493          	addi	s1,s1,1112 # 80012988 <proc+0x158>
    80002538:	00016917          	auipc	s2,0x16
    8000253c:	25090913          	addi	s2,s2,592 # 80018788 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002540:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002542:	00005997          	auipc	s3,0x5
    80002546:	cc698993          	addi	s3,s3,-826 # 80007208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    8000254a:	00005a97          	auipc	s5,0x5
    8000254e:	cc6a8a93          	addi	s5,s5,-826 # 80007210 <etext+0x210>
    printf("\n");
    80002552:	00005a17          	auipc	s4,0x5
    80002556:	b26a0a13          	addi	s4,s4,-1242 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255a:	00005b97          	auipc	s7,0x5
    8000255e:	1d6b8b93          	addi	s7,s7,470 # 80007730 <states.0>
    80002562:	a829                	j	8000257c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002564:	ed86a583          	lw	a1,-296(a3)
    80002568:	8556                	mv	a0,s5
    8000256a:	f91fd0ef          	jal	800004fa <printf>
    printf("\n");
    8000256e:	8552                	mv	a0,s4
    80002570:	f8bfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002574:	17848493          	addi	s1,s1,376
    80002578:	03248263          	beq	s1,s2,8000259c <procdump+0x8e>
    if(p->state == UNUSED)
    8000257c:	86a6                	mv	a3,s1
    8000257e:	ec04a783          	lw	a5,-320(s1)
    80002582:	dbed                	beqz	a5,80002574 <procdump+0x66>
      state = "???";
    80002584:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002586:	fcfb6fe3          	bltu	s6,a5,80002564 <procdump+0x56>
    8000258a:	02079713          	slli	a4,a5,0x20
    8000258e:	01d75793          	srli	a5,a4,0x1d
    80002592:	97de                	add	a5,a5,s7
    80002594:	6390                	ld	a2,0(a5)
    80002596:	f679                	bnez	a2,80002564 <procdump+0x56>
      state = "???";
    80002598:	864e                	mv	a2,s3
    8000259a:	b7e9                	j	80002564 <procdump+0x56>
  }
}
    8000259c:	60a6                	ld	ra,72(sp)
    8000259e:	6406                	ld	s0,64(sp)
    800025a0:	74e2                	ld	s1,56(sp)
    800025a2:	7942                	ld	s2,48(sp)
    800025a4:	79a2                	ld	s3,40(sp)
    800025a6:	7a02                	ld	s4,32(sp)
    800025a8:	6ae2                	ld	s5,24(sp)
    800025aa:	6b42                	ld	s6,16(sp)
    800025ac:	6ba2                	ld	s7,8(sp)
    800025ae:	6161                	addi	sp,sp,80
    800025b0:	8082                	ret

00000000800025b2 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025b2:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025b6:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025ba:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025bc:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025be:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025c2:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025c6:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025ca:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025ce:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025d2:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025d6:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025da:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025de:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025e2:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025e6:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025ea:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025ee:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025f0:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025f2:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025f6:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025fa:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025fe:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002602:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002606:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000260a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000260e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002612:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002616:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000261a:	8082                	ret

000000008000261c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000261c:	1141                	addi	sp,sp,-16
    8000261e:	e406                	sd	ra,8(sp)
    80002620:	e022                	sd	s0,0(sp)
    80002622:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002624:	00005597          	auipc	a1,0x5
    80002628:	c2c58593          	addi	a1,a1,-980 # 80007250 <etext+0x250>
    8000262c:	00016517          	auipc	a0,0x16
    80002630:	00450513          	addi	a0,a0,4 # 80018630 <tickslock>
    80002634:	d1afe0ef          	jal	80000b4e <initlock>
}
    80002638:	60a2                	ld	ra,8(sp)
    8000263a:	6402                	ld	s0,0(sp)
    8000263c:	0141                	addi	sp,sp,16
    8000263e:	8082                	ret

0000000080002640 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002640:	1141                	addi	sp,sp,-16
    80002642:	e422                	sd	s0,8(sp)
    80002644:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002646:	00003797          	auipc	a5,0x3
    8000264a:	ffa78793          	addi	a5,a5,-6 # 80005640 <kernelvec>
    8000264e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002652:	6422                	ld	s0,8(sp)
    80002654:	0141                	addi	sp,sp,16
    80002656:	8082                	ret

0000000080002658 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002658:	1141                	addi	sp,sp,-16
    8000265a:	e406                	sd	ra,8(sp)
    8000265c:	e022                	sd	s0,0(sp)
    8000265e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002660:	af0ff0ef          	jal	80001950 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002664:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002668:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000266a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000266e:	04000737          	lui	a4,0x4000
    80002672:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002674:	0732                	slli	a4,a4,0xc
    80002676:	00004797          	auipc	a5,0x4
    8000267a:	98a78793          	addi	a5,a5,-1654 # 80006000 <_trampoline>
    8000267e:	00004697          	auipc	a3,0x4
    80002682:	98268693          	addi	a3,a3,-1662 # 80006000 <_trampoline>
    80002686:	8f95                	sub	a5,a5,a3
    80002688:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000268a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000268e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002690:	18002773          	csrr	a4,satp
    80002694:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002696:	6d38                	ld	a4,88(a0)
    80002698:	613c                	ld	a5,64(a0)
    8000269a:	6685                	lui	a3,0x1
    8000269c:	97b6                	add	a5,a5,a3
    8000269e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026a0:	6d3c                	ld	a5,88(a0)
    800026a2:	00000717          	auipc	a4,0x0
    800026a6:	0f870713          	addi	a4,a4,248 # 8000279a <usertrap>
    800026aa:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026ac:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026ae:	8712                	mv	a4,tp
    800026b0:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b2:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026b6:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ba:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026be:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026c2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026c4:	6f9c                	ld	a5,24(a5)
    800026c6:	14179073          	csrw	sepc,a5
}
    800026ca:	60a2                	ld	ra,8(sp)
    800026cc:	6402                	ld	s0,0(sp)
    800026ce:	0141                	addi	sp,sp,16
    800026d0:	8082                	ret

00000000800026d2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026d2:	1101                	addi	sp,sp,-32
    800026d4:	ec06                	sd	ra,24(sp)
    800026d6:	e822                	sd	s0,16(sp)
    800026d8:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800026da:	a4aff0ef          	jal	80001924 <cpuid>
    800026de:	cd11                	beqz	a0,800026fa <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800026e0:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026e4:	000f4737          	lui	a4,0xf4
    800026e8:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026ec:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026ee:	14d79073          	csrw	stimecmp,a5
}
    800026f2:	60e2                	ld	ra,24(sp)
    800026f4:	6442                	ld	s0,16(sp)
    800026f6:	6105                	addi	sp,sp,32
    800026f8:	8082                	ret
    800026fa:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800026fc:	00016497          	auipc	s1,0x16
    80002700:	f3448493          	addi	s1,s1,-204 # 80018630 <tickslock>
    80002704:	8526                	mv	a0,s1
    80002706:	cc8fe0ef          	jal	80000bce <acquire>
    ticks++;
    8000270a:	00008517          	auipc	a0,0x8
    8000270e:	b9650513          	addi	a0,a0,-1130 # 8000a2a0 <ticks>
    80002712:	411c                	lw	a5,0(a0)
    80002714:	2785                	addiw	a5,a5,1
    80002716:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002718:	a1bff0ef          	jal	80002132 <wakeup>
    release(&tickslock);
    8000271c:	8526                	mv	a0,s1
    8000271e:	d48fe0ef          	jal	80000c66 <release>
    80002722:	64a2                	ld	s1,8(sp)
    80002724:	bf75                	j	800026e0 <clockintr+0xe>

0000000080002726 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002726:	1101                	addi	sp,sp,-32
    80002728:	ec06                	sd	ra,24(sp)
    8000272a:	e822                	sd	s0,16(sp)
    8000272c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000272e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002732:	57fd                	li	a5,-1
    80002734:	17fe                	slli	a5,a5,0x3f
    80002736:	07a5                	addi	a5,a5,9
    80002738:	00f70c63          	beq	a4,a5,80002750 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000273c:	57fd                	li	a5,-1
    8000273e:	17fe                	slli	a5,a5,0x3f
    80002740:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002742:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002744:	04f70763          	beq	a4,a5,80002792 <devintr+0x6c>
  }
}
    80002748:	60e2                	ld	ra,24(sp)
    8000274a:	6442                	ld	s0,16(sp)
    8000274c:	6105                	addi	sp,sp,32
    8000274e:	8082                	ret
    80002750:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002752:	79b020ef          	jal	800056ec <plic_claim>
    80002756:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002758:	47a9                	li	a5,10
    8000275a:	00f50963          	beq	a0,a5,8000276c <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000275e:	4785                	li	a5,1
    80002760:	00f50963          	beq	a0,a5,80002772 <devintr+0x4c>
    return 1;
    80002764:	4505                	li	a0,1
    } else if(irq){
    80002766:	e889                	bnez	s1,80002778 <devintr+0x52>
    80002768:	64a2                	ld	s1,8(sp)
    8000276a:	bff9                	j	80002748 <devintr+0x22>
      uartintr();
    8000276c:	a44fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002770:	a819                	j	80002786 <devintr+0x60>
      virtio_disk_intr();
    80002772:	440030ef          	jal	80005bb2 <virtio_disk_intr>
    if(irq)
    80002776:	a801                	j	80002786 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002778:	85a6                	mv	a1,s1
    8000277a:	00005517          	auipc	a0,0x5
    8000277e:	ade50513          	addi	a0,a0,-1314 # 80007258 <etext+0x258>
    80002782:	d79fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002786:	8526                	mv	a0,s1
    80002788:	785020ef          	jal	8000570c <plic_complete>
    return 1;
    8000278c:	4505                	li	a0,1
    8000278e:	64a2                	ld	s1,8(sp)
    80002790:	bf65                	j	80002748 <devintr+0x22>
    clockintr();
    80002792:	f41ff0ef          	jal	800026d2 <clockintr>
    return 2;
    80002796:	4509                	li	a0,2
    80002798:	bf45                	j	80002748 <devintr+0x22>

000000008000279a <usertrap>:
{
    8000279a:	1101                	addi	sp,sp,-32
    8000279c:	ec06                	sd	ra,24(sp)
    8000279e:	e822                	sd	s0,16(sp)
    800027a0:	e426                	sd	s1,8(sp)
    800027a2:	e04a                	sd	s2,0(sp)
    800027a4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027a6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027aa:	1007f793          	andi	a5,a5,256
    800027ae:	eba5                	bnez	a5,8000281e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027b0:	00003797          	auipc	a5,0x3
    800027b4:	e9078793          	addi	a5,a5,-368 # 80005640 <kernelvec>
    800027b8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027bc:	994ff0ef          	jal	80001950 <myproc>
    800027c0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027c2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027c4:	14102773          	csrr	a4,sepc
    800027c8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027ca:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027ce:	47a1                	li	a5,8
    800027d0:	04f70d63          	beq	a4,a5,8000282a <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800027d4:	f53ff0ef          	jal	80002726 <devintr>
    800027d8:	892a                	mv	s2,a0
    800027da:	e945                	bnez	a0,8000288a <usertrap+0xf0>
    800027dc:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800027e0:	47bd                	li	a5,15
    800027e2:	08f70863          	beq	a4,a5,80002872 <usertrap+0xd8>
    800027e6:	14202773          	csrr	a4,scause
    800027ea:	47b5                	li	a5,13
    800027ec:	08f70363          	beq	a4,a5,80002872 <usertrap+0xd8>
    800027f0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027f4:	5890                	lw	a2,48(s1)
    800027f6:	00005517          	auipc	a0,0x5
    800027fa:	aa250513          	addi	a0,a0,-1374 # 80007298 <etext+0x298>
    800027fe:	cfdfd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002802:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002806:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000280a:	00005517          	auipc	a0,0x5
    8000280e:	abe50513          	addi	a0,a0,-1346 # 800072c8 <etext+0x2c8>
    80002812:	ce9fd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002816:	8526                	mv	a0,s1
    80002818:	b1bff0ef          	jal	80002332 <setkilled>
    8000281c:	a035                	j	80002848 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000281e:	00005517          	auipc	a0,0x5
    80002822:	a5a50513          	addi	a0,a0,-1446 # 80007278 <etext+0x278>
    80002826:	fbbfd0ef          	jal	800007e0 <panic>
    if(killed(p))
    8000282a:	b2dff0ef          	jal	80002356 <killed>
    8000282e:	ed15                	bnez	a0,8000286a <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002830:	6cb8                	ld	a4,88(s1)
    80002832:	6f1c                	ld	a5,24(a4)
    80002834:	0791                	addi	a5,a5,4
    80002836:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002838:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000283c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002840:	10079073          	csrw	sstatus,a5
    syscall();
    80002844:	27c000ef          	jal	80002ac0 <syscall>
  if(killed(p))
    80002848:	8526                	mv	a0,s1
    8000284a:	b0dff0ef          	jal	80002356 <killed>
    8000284e:	e139                	bnez	a0,80002894 <usertrap+0xfa>
  prepare_return();
    80002850:	e09ff0ef          	jal	80002658 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002854:	68a8                	ld	a0,80(s1)
    80002856:	8131                	srli	a0,a0,0xc
    80002858:	57fd                	li	a5,-1
    8000285a:	17fe                	slli	a5,a5,0x3f
    8000285c:	8d5d                	or	a0,a0,a5
}
    8000285e:	60e2                	ld	ra,24(sp)
    80002860:	6442                	ld	s0,16(sp)
    80002862:	64a2                	ld	s1,8(sp)
    80002864:	6902                	ld	s2,0(sp)
    80002866:	6105                	addi	sp,sp,32
    80002868:	8082                	ret
      kexit(-1);
    8000286a:	557d                	li	a0,-1
    8000286c:	9a5ff0ef          	jal	80002210 <kexit>
    80002870:	b7c1                	j	80002830 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002872:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002876:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000287a:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000287c:	00163613          	seqz	a2,a2
    80002880:	68a8                	ld	a0,80(s1)
    80002882:	cdffe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002886:	f169                	bnez	a0,80002848 <usertrap+0xae>
    80002888:	b7a5                	j	800027f0 <usertrap+0x56>
  if(killed(p))
    8000288a:	8526                	mv	a0,s1
    8000288c:	acbff0ef          	jal	80002356 <killed>
    80002890:	c511                	beqz	a0,8000289c <usertrap+0x102>
    80002892:	a011                	j	80002896 <usertrap+0xfc>
    80002894:	4901                	li	s2,0
    kexit(-1);
    80002896:	557d                	li	a0,-1
    80002898:	979ff0ef          	jal	80002210 <kexit>
  if(which_dev == 2) {
    8000289c:	4789                	li	a5,2
    8000289e:	faf919e3          	bne	s2,a5,80002850 <usertrap+0xb6>
    p->time_slices++;
    800028a2:	16c4a783          	lw	a5,364(s1)
    800028a6:	2785                	addiw	a5,a5,1
    800028a8:	0007869b          	sext.w	a3,a5
    800028ac:	16f4a623          	sw	a5,364(s1)
    if(p->time_slices >= mlfq_time_quanta[p->priority]) {
    800028b0:	1684a703          	lw	a4,360(s1)
    800028b4:	00271613          	slli	a2,a4,0x2
    800028b8:	00008797          	auipc	a5,0x8
    800028bc:	98878793          	addi	a5,a5,-1656 # 8000a240 <mlfq_time_quanta>
    800028c0:	97b2                	add	a5,a5,a2
    800028c2:	439c                	lw	a5,0(a5)
    800028c4:	00f6ca63          	blt	a3,a5,800028d8 <usertrap+0x13e>
      if(p->priority < NMLFQ - 1) {
    800028c8:	4789                	li	a5,2
    800028ca:	00e7c563          	blt	a5,a4,800028d4 <usertrap+0x13a>
        p->priority++;  // Move to lower priority queue
    800028ce:	2705                	addiw	a4,a4,1
    800028d0:	16e4a423          	sw	a4,360(s1)
      p->time_slices = 0;  // Reset time slice counter for new queue
    800028d4:	1604a623          	sw	zero,364(s1)
    yield();
    800028d8:	fc4ff0ef          	jal	8000209c <yield>
    800028dc:	bf95                	j	80002850 <usertrap+0xb6>

00000000800028de <kerneltrap>:
{
    800028de:	7179                	addi	sp,sp,-48
    800028e0:	f406                	sd	ra,40(sp)
    800028e2:	f022                	sd	s0,32(sp)
    800028e4:	ec26                	sd	s1,24(sp)
    800028e6:	e84a                	sd	s2,16(sp)
    800028e8:	e44e                	sd	s3,8(sp)
    800028ea:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ec:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028f8:	1004f793          	andi	a5,s1,256
    800028fc:	c795                	beqz	a5,80002928 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002902:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002904:	eb85                	bnez	a5,80002934 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002906:	e21ff0ef          	jal	80002726 <devintr>
    8000290a:	c91d                	beqz	a0,80002940 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000290c:	4789                	li	a5,2
    8000290e:	04f50a63          	beq	a0,a5,80002962 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002912:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002916:	10049073          	csrw	sstatus,s1
}
    8000291a:	70a2                	ld	ra,40(sp)
    8000291c:	7402                	ld	s0,32(sp)
    8000291e:	64e2                	ld	s1,24(sp)
    80002920:	6942                	ld	s2,16(sp)
    80002922:	69a2                	ld	s3,8(sp)
    80002924:	6145                	addi	sp,sp,48
    80002926:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002928:	00005517          	auipc	a0,0x5
    8000292c:	9c850513          	addi	a0,a0,-1592 # 800072f0 <etext+0x2f0>
    80002930:	eb1fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002934:	00005517          	auipc	a0,0x5
    80002938:	9e450513          	addi	a0,a0,-1564 # 80007318 <etext+0x318>
    8000293c:	ea5fd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002940:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002944:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002948:	85ce                	mv	a1,s3
    8000294a:	00005517          	auipc	a0,0x5
    8000294e:	9ee50513          	addi	a0,a0,-1554 # 80007338 <etext+0x338>
    80002952:	ba9fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002956:	00005517          	auipc	a0,0x5
    8000295a:	a0a50513          	addi	a0,a0,-1526 # 80007360 <etext+0x360>
    8000295e:	e83fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002962:	feffe0ef          	jal	80001950 <myproc>
    80002966:	d555                	beqz	a0,80002912 <kerneltrap+0x34>
    yield();
    80002968:	f34ff0ef          	jal	8000209c <yield>
    8000296c:	b75d                	j	80002912 <kerneltrap+0x34>

000000008000296e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000296e:	1101                	addi	sp,sp,-32
    80002970:	ec06                	sd	ra,24(sp)
    80002972:	e822                	sd	s0,16(sp)
    80002974:	e426                	sd	s1,8(sp)
    80002976:	1000                	addi	s0,sp,32
    80002978:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000297a:	fd7fe0ef          	jal	80001950 <myproc>
  switch (n) {
    8000297e:	4795                	li	a5,5
    80002980:	0497e163          	bltu	a5,s1,800029c2 <argraw+0x54>
    80002984:	048a                	slli	s1,s1,0x2
    80002986:	00005717          	auipc	a4,0x5
    8000298a:	dda70713          	addi	a4,a4,-550 # 80007760 <states.0+0x30>
    8000298e:	94ba                	add	s1,s1,a4
    80002990:	409c                	lw	a5,0(s1)
    80002992:	97ba                	add	a5,a5,a4
    80002994:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002996:	6d3c                	ld	a5,88(a0)
    80002998:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000299a:	60e2                	ld	ra,24(sp)
    8000299c:	6442                	ld	s0,16(sp)
    8000299e:	64a2                	ld	s1,8(sp)
    800029a0:	6105                	addi	sp,sp,32
    800029a2:	8082                	ret
    return p->trapframe->a1;
    800029a4:	6d3c                	ld	a5,88(a0)
    800029a6:	7fa8                	ld	a0,120(a5)
    800029a8:	bfcd                	j	8000299a <argraw+0x2c>
    return p->trapframe->a2;
    800029aa:	6d3c                	ld	a5,88(a0)
    800029ac:	63c8                	ld	a0,128(a5)
    800029ae:	b7f5                	j	8000299a <argraw+0x2c>
    return p->trapframe->a3;
    800029b0:	6d3c                	ld	a5,88(a0)
    800029b2:	67c8                	ld	a0,136(a5)
    800029b4:	b7dd                	j	8000299a <argraw+0x2c>
    return p->trapframe->a4;
    800029b6:	6d3c                	ld	a5,88(a0)
    800029b8:	6bc8                	ld	a0,144(a5)
    800029ba:	b7c5                	j	8000299a <argraw+0x2c>
    return p->trapframe->a5;
    800029bc:	6d3c                	ld	a5,88(a0)
    800029be:	6fc8                	ld	a0,152(a5)
    800029c0:	bfe9                	j	8000299a <argraw+0x2c>
  panic("argraw");
    800029c2:	00005517          	auipc	a0,0x5
    800029c6:	9ae50513          	addi	a0,a0,-1618 # 80007370 <etext+0x370>
    800029ca:	e17fd0ef          	jal	800007e0 <panic>

00000000800029ce <fetchaddr>:
{
    800029ce:	1101                	addi	sp,sp,-32
    800029d0:	ec06                	sd	ra,24(sp)
    800029d2:	e822                	sd	s0,16(sp)
    800029d4:	e426                	sd	s1,8(sp)
    800029d6:	e04a                	sd	s2,0(sp)
    800029d8:	1000                	addi	s0,sp,32
    800029da:	84aa                	mv	s1,a0
    800029dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029de:	f73fe0ef          	jal	80001950 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029e2:	653c                	ld	a5,72(a0)
    800029e4:	02f4f663          	bgeu	s1,a5,80002a10 <fetchaddr+0x42>
    800029e8:	00848713          	addi	a4,s1,8
    800029ec:	02e7e463          	bltu	a5,a4,80002a14 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029f0:	46a1                	li	a3,8
    800029f2:	8626                	mv	a2,s1
    800029f4:	85ca                	mv	a1,s2
    800029f6:	6928                	ld	a0,80(a0)
    800029f8:	ccffe0ef          	jal	800016c6 <copyin>
    800029fc:	00a03533          	snez	a0,a0
    80002a00:	40a00533          	neg	a0,a0
}
    80002a04:	60e2                	ld	ra,24(sp)
    80002a06:	6442                	ld	s0,16(sp)
    80002a08:	64a2                	ld	s1,8(sp)
    80002a0a:	6902                	ld	s2,0(sp)
    80002a0c:	6105                	addi	sp,sp,32
    80002a0e:	8082                	ret
    return -1;
    80002a10:	557d                	li	a0,-1
    80002a12:	bfcd                	j	80002a04 <fetchaddr+0x36>
    80002a14:	557d                	li	a0,-1
    80002a16:	b7fd                	j	80002a04 <fetchaddr+0x36>

0000000080002a18 <fetchstr>:
{
    80002a18:	7179                	addi	sp,sp,-48
    80002a1a:	f406                	sd	ra,40(sp)
    80002a1c:	f022                	sd	s0,32(sp)
    80002a1e:	ec26                	sd	s1,24(sp)
    80002a20:	e84a                	sd	s2,16(sp)
    80002a22:	e44e                	sd	s3,8(sp)
    80002a24:	1800                	addi	s0,sp,48
    80002a26:	892a                	mv	s2,a0
    80002a28:	84ae                	mv	s1,a1
    80002a2a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a2c:	f25fe0ef          	jal	80001950 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a30:	86ce                	mv	a3,s3
    80002a32:	864a                	mv	a2,s2
    80002a34:	85a6                	mv	a1,s1
    80002a36:	6928                	ld	a0,80(a0)
    80002a38:	a51fe0ef          	jal	80001488 <copyinstr>
    80002a3c:	00054c63          	bltz	a0,80002a54 <fetchstr+0x3c>
  return strlen(buf);
    80002a40:	8526                	mv	a0,s1
    80002a42:	bd0fe0ef          	jal	80000e12 <strlen>
}
    80002a46:	70a2                	ld	ra,40(sp)
    80002a48:	7402                	ld	s0,32(sp)
    80002a4a:	64e2                	ld	s1,24(sp)
    80002a4c:	6942                	ld	s2,16(sp)
    80002a4e:	69a2                	ld	s3,8(sp)
    80002a50:	6145                	addi	sp,sp,48
    80002a52:	8082                	ret
    return -1;
    80002a54:	557d                	li	a0,-1
    80002a56:	bfc5                	j	80002a46 <fetchstr+0x2e>

0000000080002a58 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a58:	1101                	addi	sp,sp,-32
    80002a5a:	ec06                	sd	ra,24(sp)
    80002a5c:	e822                	sd	s0,16(sp)
    80002a5e:	e426                	sd	s1,8(sp)
    80002a60:	1000                	addi	s0,sp,32
    80002a62:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a64:	f0bff0ef          	jal	8000296e <argraw>
    80002a68:	c088                	sw	a0,0(s1)
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6105                	addi	sp,sp,32
    80002a72:	8082                	ret

0000000080002a74 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a74:	1101                	addi	sp,sp,-32
    80002a76:	ec06                	sd	ra,24(sp)
    80002a78:	e822                	sd	s0,16(sp)
    80002a7a:	e426                	sd	s1,8(sp)
    80002a7c:	1000                	addi	s0,sp,32
    80002a7e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a80:	eefff0ef          	jal	8000296e <argraw>
    80002a84:	e088                	sd	a0,0(s1)
}
    80002a86:	60e2                	ld	ra,24(sp)
    80002a88:	6442                	ld	s0,16(sp)
    80002a8a:	64a2                	ld	s1,8(sp)
    80002a8c:	6105                	addi	sp,sp,32
    80002a8e:	8082                	ret

0000000080002a90 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a90:	7179                	addi	sp,sp,-48
    80002a92:	f406                	sd	ra,40(sp)
    80002a94:	f022                	sd	s0,32(sp)
    80002a96:	ec26                	sd	s1,24(sp)
    80002a98:	e84a                	sd	s2,16(sp)
    80002a9a:	1800                	addi	s0,sp,48
    80002a9c:	84ae                	mv	s1,a1
    80002a9e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002aa0:	fd840593          	addi	a1,s0,-40
    80002aa4:	fd1ff0ef          	jal	80002a74 <argaddr>
  return fetchstr(addr, buf, max);
    80002aa8:	864a                	mv	a2,s2
    80002aaa:	85a6                	mv	a1,s1
    80002aac:	fd843503          	ld	a0,-40(s0)
    80002ab0:	f69ff0ef          	jal	80002a18 <fetchstr>
}
    80002ab4:	70a2                	ld	ra,40(sp)
    80002ab6:	7402                	ld	s0,32(sp)
    80002ab8:	64e2                	ld	s1,24(sp)
    80002aba:	6942                	ld	s2,16(sp)
    80002abc:	6145                	addi	sp,sp,48
    80002abe:	8082                	ret

0000000080002ac0 <syscall>:
[SYS_boostproc] sys_boostproc,
};

void
syscall(void)
{
    80002ac0:	1101                	addi	sp,sp,-32
    80002ac2:	ec06                	sd	ra,24(sp)
    80002ac4:	e822                	sd	s0,16(sp)
    80002ac6:	e426                	sd	s1,8(sp)
    80002ac8:	e04a                	sd	s2,0(sp)
    80002aca:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002acc:	e85fe0ef          	jal	80001950 <myproc>
    80002ad0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ad2:	05853903          	ld	s2,88(a0)
    80002ad6:	0a893783          	ld	a5,168(s2)
    80002ada:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ade:	37fd                	addiw	a5,a5,-1
    80002ae0:	4759                	li	a4,22
    80002ae2:	00f76f63          	bltu	a4,a5,80002b00 <syscall+0x40>
    80002ae6:	00369713          	slli	a4,a3,0x3
    80002aea:	00005797          	auipc	a5,0x5
    80002aee:	c8e78793          	addi	a5,a5,-882 # 80007778 <syscalls>
    80002af2:	97ba                	add	a5,a5,a4
    80002af4:	639c                	ld	a5,0(a5)
    80002af6:	c789                	beqz	a5,80002b00 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002af8:	9782                	jalr	a5
    80002afa:	06a93823          	sd	a0,112(s2)
    80002afe:	a829                	j	80002b18 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b00:	15848613          	addi	a2,s1,344
    80002b04:	588c                	lw	a1,48(s1)
    80002b06:	00005517          	auipc	a0,0x5
    80002b0a:	87250513          	addi	a0,a0,-1934 # 80007378 <etext+0x378>
    80002b0e:	9edfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b12:	6cbc                	ld	a5,88(s1)
    80002b14:	577d                	li	a4,-1
    80002b16:	fbb8                	sd	a4,112(a5)
  }
}
    80002b18:	60e2                	ld	ra,24(sp)
    80002b1a:	6442                	ld	s0,16(sp)
    80002b1c:	64a2                	ld	s1,8(sp)
    80002b1e:	6902                	ld	s2,0(sp)
    80002b20:	6105                	addi	sp,sp,32
    80002b22:	8082                	ret

0000000080002b24 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b24:	1101                	addi	sp,sp,-32
    80002b26:	ec06                	sd	ra,24(sp)
    80002b28:	e822                	sd	s0,16(sp)
    80002b2a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b2c:	fec40593          	addi	a1,s0,-20
    80002b30:	4501                	li	a0,0
    80002b32:	f27ff0ef          	jal	80002a58 <argint>
  kexit(n);
    80002b36:	fec42503          	lw	a0,-20(s0)
    80002b3a:	ed6ff0ef          	jal	80002210 <kexit>
  return 0;  // not reached
}
    80002b3e:	4501                	li	a0,0
    80002b40:	60e2                	ld	ra,24(sp)
    80002b42:	6442                	ld	s0,16(sp)
    80002b44:	6105                	addi	sp,sp,32
    80002b46:	8082                	ret

0000000080002b48 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b48:	1141                	addi	sp,sp,-16
    80002b4a:	e406                	sd	ra,8(sp)
    80002b4c:	e022                	sd	s0,0(sp)
    80002b4e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b50:	e01fe0ef          	jal	80001950 <myproc>
}
    80002b54:	5908                	lw	a0,48(a0)
    80002b56:	60a2                	ld	ra,8(sp)
    80002b58:	6402                	ld	s0,0(sp)
    80002b5a:	0141                	addi	sp,sp,16
    80002b5c:	8082                	ret

0000000080002b5e <sys_fork>:

uint64
sys_fork(void)
{
    80002b5e:	1141                	addi	sp,sp,-16
    80002b60:	e406                	sd	ra,8(sp)
    80002b62:	e022                	sd	s0,0(sp)
    80002b64:	0800                	addi	s0,sp,16
  return kfork();
    80002b66:	978ff0ef          	jal	80001cde <kfork>
}
    80002b6a:	60a2                	ld	ra,8(sp)
    80002b6c:	6402                	ld	s0,0(sp)
    80002b6e:	0141                	addi	sp,sp,16
    80002b70:	8082                	ret

0000000080002b72 <sys_wait>:

uint64
sys_wait(void)
{
    80002b72:	1101                	addi	sp,sp,-32
    80002b74:	ec06                	sd	ra,24(sp)
    80002b76:	e822                	sd	s0,16(sp)
    80002b78:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b7a:	fe840593          	addi	a1,s0,-24
    80002b7e:	4501                	li	a0,0
    80002b80:	ef5ff0ef          	jal	80002a74 <argaddr>
  return kwait(p);
    80002b84:	fe843503          	ld	a0,-24(s0)
    80002b88:	ff8ff0ef          	jal	80002380 <kwait>
}
    80002b8c:	60e2                	ld	ra,24(sp)
    80002b8e:	6442                	ld	s0,16(sp)
    80002b90:	6105                	addi	sp,sp,32
    80002b92:	8082                	ret

0000000080002b94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b94:	7179                	addi	sp,sp,-48
    80002b96:	f406                	sd	ra,40(sp)
    80002b98:	f022                	sd	s0,32(sp)
    80002b9a:	ec26                	sd	s1,24(sp)
    80002b9c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b9e:	fd840593          	addi	a1,s0,-40
    80002ba2:	4501                	li	a0,0
    80002ba4:	eb5ff0ef          	jal	80002a58 <argint>
  argint(1, &t);
    80002ba8:	fdc40593          	addi	a1,s0,-36
    80002bac:	4505                	li	a0,1
    80002bae:	eabff0ef          	jal	80002a58 <argint>
  addr = myproc()->sz;
    80002bb2:	d9ffe0ef          	jal	80001950 <myproc>
    80002bb6:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002bb8:	fdc42703          	lw	a4,-36(s0)
    80002bbc:	4785                	li	a5,1
    80002bbe:	02f70763          	beq	a4,a5,80002bec <sys_sbrk+0x58>
    80002bc2:	fd842783          	lw	a5,-40(s0)
    80002bc6:	0207c363          	bltz	a5,80002bec <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bca:	97a6                	add	a5,a5,s1
    80002bcc:	0297ee63          	bltu	a5,s1,80002c08 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002bd0:	02000737          	lui	a4,0x2000
    80002bd4:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bd6:	0736                	slli	a4,a4,0xd
    80002bd8:	02f76a63          	bltu	a4,a5,80002c0c <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002bdc:	d75fe0ef          	jal	80001950 <myproc>
    80002be0:	fd842703          	lw	a4,-40(s0)
    80002be4:	653c                	ld	a5,72(a0)
    80002be6:	97ba                	add	a5,a5,a4
    80002be8:	e53c                	sd	a5,72(a0)
    80002bea:	a039                	j	80002bf8 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002bec:	fd842503          	lw	a0,-40(s0)
    80002bf0:	88cff0ef          	jal	80001c7c <growproc>
    80002bf4:	00054863          	bltz	a0,80002c04 <sys_sbrk+0x70>
  }
  return addr;
}
    80002bf8:	8526                	mv	a0,s1
    80002bfa:	70a2                	ld	ra,40(sp)
    80002bfc:	7402                	ld	s0,32(sp)
    80002bfe:	64e2                	ld	s1,24(sp)
    80002c00:	6145                	addi	sp,sp,48
    80002c02:	8082                	ret
      return -1;
    80002c04:	54fd                	li	s1,-1
    80002c06:	bfcd                	j	80002bf8 <sys_sbrk+0x64>
      return -1;
    80002c08:	54fd                	li	s1,-1
    80002c0a:	b7fd                	j	80002bf8 <sys_sbrk+0x64>
      return -1;
    80002c0c:	54fd                	li	s1,-1
    80002c0e:	b7ed                	j	80002bf8 <sys_sbrk+0x64>

0000000080002c10 <sys_pause>:

uint64
sys_pause(void)
{
    80002c10:	7139                	addi	sp,sp,-64
    80002c12:	fc06                	sd	ra,56(sp)
    80002c14:	f822                	sd	s0,48(sp)
    80002c16:	f04a                	sd	s2,32(sp)
    80002c18:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c1a:	fcc40593          	addi	a1,s0,-52
    80002c1e:	4501                	li	a0,0
    80002c20:	e39ff0ef          	jal	80002a58 <argint>
  if(n < 0)
    80002c24:	fcc42783          	lw	a5,-52(s0)
    80002c28:	0607c763          	bltz	a5,80002c96 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c2c:	00016517          	auipc	a0,0x16
    80002c30:	a0450513          	addi	a0,a0,-1532 # 80018630 <tickslock>
    80002c34:	f9bfd0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002c38:	00007917          	auipc	s2,0x7
    80002c3c:	66892903          	lw	s2,1640(s2) # 8000a2a0 <ticks>
  while(ticks - ticks0 < n){
    80002c40:	fcc42783          	lw	a5,-52(s0)
    80002c44:	cf8d                	beqz	a5,80002c7e <sys_pause+0x6e>
    80002c46:	f426                	sd	s1,40(sp)
    80002c48:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c4a:	00016997          	auipc	s3,0x16
    80002c4e:	9e698993          	addi	s3,s3,-1562 # 80018630 <tickslock>
    80002c52:	00007497          	auipc	s1,0x7
    80002c56:	64e48493          	addi	s1,s1,1614 # 8000a2a0 <ticks>
    if(killed(myproc())){
    80002c5a:	cf7fe0ef          	jal	80001950 <myproc>
    80002c5e:	ef8ff0ef          	jal	80002356 <killed>
    80002c62:	ed0d                	bnez	a0,80002c9c <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c64:	85ce                	mv	a1,s3
    80002c66:	8526                	mv	a0,s1
    80002c68:	c7eff0ef          	jal	800020e6 <sleep>
  while(ticks - ticks0 < n){
    80002c6c:	409c                	lw	a5,0(s1)
    80002c6e:	412787bb          	subw	a5,a5,s2
    80002c72:	fcc42703          	lw	a4,-52(s0)
    80002c76:	fee7e2e3          	bltu	a5,a4,80002c5a <sys_pause+0x4a>
    80002c7a:	74a2                	ld	s1,40(sp)
    80002c7c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c7e:	00016517          	auipc	a0,0x16
    80002c82:	9b250513          	addi	a0,a0,-1614 # 80018630 <tickslock>
    80002c86:	fe1fd0ef          	jal	80000c66 <release>
  return 0;
    80002c8a:	4501                	li	a0,0
}
    80002c8c:	70e2                	ld	ra,56(sp)
    80002c8e:	7442                	ld	s0,48(sp)
    80002c90:	7902                	ld	s2,32(sp)
    80002c92:	6121                	addi	sp,sp,64
    80002c94:	8082                	ret
    n = 0;
    80002c96:	fc042623          	sw	zero,-52(s0)
    80002c9a:	bf49                	j	80002c2c <sys_pause+0x1c>
      release(&tickslock);
    80002c9c:	00016517          	auipc	a0,0x16
    80002ca0:	99450513          	addi	a0,a0,-1644 # 80018630 <tickslock>
    80002ca4:	fc3fd0ef          	jal	80000c66 <release>
      return -1;
    80002ca8:	557d                	li	a0,-1
    80002caa:	74a2                	ld	s1,40(sp)
    80002cac:	69e2                	ld	s3,24(sp)
    80002cae:	bff9                	j	80002c8c <sys_pause+0x7c>

0000000080002cb0 <sys_kill>:

uint64
sys_kill(void)
{
    80002cb0:	1101                	addi	sp,sp,-32
    80002cb2:	ec06                	sd	ra,24(sp)
    80002cb4:	e822                	sd	s0,16(sp)
    80002cb6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002cb8:	fec40593          	addi	a1,s0,-20
    80002cbc:	4501                	li	a0,0
    80002cbe:	d9bff0ef          	jal	80002a58 <argint>
  return kkill(pid);
    80002cc2:	fec42503          	lw	a0,-20(s0)
    80002cc6:	decff0ef          	jal	800022b2 <kkill>
}
    80002cca:	60e2                	ld	ra,24(sp)
    80002ccc:	6442                	ld	s0,16(sp)
    80002cce:	6105                	addi	sp,sp,32
    80002cd0:	8082                	ret

0000000080002cd2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cd2:	1101                	addi	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	e426                	sd	s1,8(sp)
    80002cda:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cdc:	00016517          	auipc	a0,0x16
    80002ce0:	95450513          	addi	a0,a0,-1708 # 80018630 <tickslock>
    80002ce4:	eebfd0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002ce8:	00007497          	auipc	s1,0x7
    80002cec:	5b84a483          	lw	s1,1464(s1) # 8000a2a0 <ticks>
  release(&tickslock);
    80002cf0:	00016517          	auipc	a0,0x16
    80002cf4:	94050513          	addi	a0,a0,-1728 # 80018630 <tickslock>
    80002cf8:	f6ffd0ef          	jal	80000c66 <release>
  return xticks;
}
    80002cfc:	02049513          	slli	a0,s1,0x20
    80002d00:	9101                	srli	a0,a0,0x20
    80002d02:	60e2                	ld	ra,24(sp)
    80002d04:	6442                	ld	s0,16(sp)
    80002d06:	64a2                	ld	s1,8(sp)
    80002d08:	6105                	addi	sp,sp,32
    80002d0a:	8082                	ret

0000000080002d0c <sys_getprocinfo>:

// Get process information for MLFQ debugging
uint64
sys_getprocinfo(void)
{
    80002d0c:	7139                	addi	sp,sp,-64
    80002d0e:	fc06                	sd	ra,56(sp)
    80002d10:	f822                	sd	s0,48(sp)
    80002d12:	f426                	sd	s1,40(sp)
    80002d14:	0080                	addi	s0,sp,64
  uint64 addr;
  struct proc *p = myproc();
    80002d16:	c3bfe0ef          	jal	80001950 <myproc>
    80002d1a:	84aa                	mv	s1,a0
  
  argaddr(0, &addr);
    80002d1c:	fd840593          	addi	a1,s0,-40
    80002d20:	4501                	li	a0,0
    80002d22:	d53ff0ef          	jal	80002a74 <argaddr>
    int state;
    int priority;
    int time_slices;
  } info;
  
  acquire(&p->lock);
    80002d26:	8526                	mv	a0,s1
    80002d28:	ea7fd0ef          	jal	80000bce <acquire>
  info.pid = p->pid;
    80002d2c:	589c                	lw	a5,48(s1)
    80002d2e:	fcf42423          	sw	a5,-56(s0)
  info.state = p->state;
    80002d32:	4c9c                	lw	a5,24(s1)
    80002d34:	fcf42623          	sw	a5,-52(s0)
  info.priority = p->priority;
    80002d38:	1684a783          	lw	a5,360(s1)
    80002d3c:	fcf42823          	sw	a5,-48(s0)
  info.time_slices = p->time_slices;
    80002d40:	16c4a783          	lw	a5,364(s1)
    80002d44:	fcf42a23          	sw	a5,-44(s0)
  release(&p->lock);
    80002d48:	8526                	mv	a0,s1
    80002d4a:	f1dfd0ef          	jal	80000c66 <release>
  
  if(copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    80002d4e:	46c1                	li	a3,16
    80002d50:	fc840613          	addi	a2,s0,-56
    80002d54:	fd843583          	ld	a1,-40(s0)
    80002d58:	68a8                	ld	a0,80(s1)
    80002d5a:	889fe0ef          	jal	800015e2 <copyout>
    return -1;
  
  return 0;
}
    80002d5e:	957d                	srai	a0,a0,0x3f
    80002d60:	70e2                	ld	ra,56(sp)
    80002d62:	7442                	ld	s0,48(sp)
    80002d64:	74a2                	ld	s1,40(sp)
    80002d66:	6121                	addi	sp,sp,64
    80002d68:	8082                	ret

0000000080002d6a <sys_boostproc>:

uint64
sys_boostproc(void)
{
    80002d6a:	1141                	addi	sp,sp,-16
    80002d6c:	e406                	sd	ra,8(sp)
    80002d6e:	e022                	sd	s0,0(sp)
    80002d70:	0800                	addi	s0,sp,16
  extern void boost_all_priorities(void);
  
  boost_all_priorities();
    80002d72:	894ff0ef          	jal	80001e06 <boost_all_priorities>
  
  return 0;
    80002d76:	4501                	li	a0,0
    80002d78:	60a2                	ld	ra,8(sp)
    80002d7a:	6402                	ld	s0,0(sp)
    80002d7c:	0141                	addi	sp,sp,16
    80002d7e:	8082                	ret

0000000080002d80 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d80:	7179                	addi	sp,sp,-48
    80002d82:	f406                	sd	ra,40(sp)
    80002d84:	f022                	sd	s0,32(sp)
    80002d86:	ec26                	sd	s1,24(sp)
    80002d88:	e84a                	sd	s2,16(sp)
    80002d8a:	e44e                	sd	s3,8(sp)
    80002d8c:	e052                	sd	s4,0(sp)
    80002d8e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d90:	00004597          	auipc	a1,0x4
    80002d94:	60858593          	addi	a1,a1,1544 # 80007398 <etext+0x398>
    80002d98:	00016517          	auipc	a0,0x16
    80002d9c:	8b050513          	addi	a0,a0,-1872 # 80018648 <bcache>
    80002da0:	daffd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002da4:	0001e797          	auipc	a5,0x1e
    80002da8:	8a478793          	addi	a5,a5,-1884 # 80020648 <bcache+0x8000>
    80002dac:	0001e717          	auipc	a4,0x1e
    80002db0:	b0470713          	addi	a4,a4,-1276 # 800208b0 <bcache+0x8268>
    80002db4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002db8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dbc:	00016497          	auipc	s1,0x16
    80002dc0:	8a448493          	addi	s1,s1,-1884 # 80018660 <bcache+0x18>
    b->next = bcache.head.next;
    80002dc4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dc6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dc8:	00004a17          	auipc	s4,0x4
    80002dcc:	5d8a0a13          	addi	s4,s4,1496 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002dd0:	2b893783          	ld	a5,696(s2)
    80002dd4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dd6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dda:	85d2                	mv	a1,s4
    80002ddc:	01048513          	addi	a0,s1,16
    80002de0:	322010ef          	jal	80004102 <initsleeplock>
    bcache.head.next->prev = b;
    80002de4:	2b893783          	ld	a5,696(s2)
    80002de8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002dea:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dee:	45848493          	addi	s1,s1,1112
    80002df2:	fd349fe3          	bne	s1,s3,80002dd0 <binit+0x50>
  }
}
    80002df6:	70a2                	ld	ra,40(sp)
    80002df8:	7402                	ld	s0,32(sp)
    80002dfa:	64e2                	ld	s1,24(sp)
    80002dfc:	6942                	ld	s2,16(sp)
    80002dfe:	69a2                	ld	s3,8(sp)
    80002e00:	6a02                	ld	s4,0(sp)
    80002e02:	6145                	addi	sp,sp,48
    80002e04:	8082                	ret

0000000080002e06 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e06:	7179                	addi	sp,sp,-48
    80002e08:	f406                	sd	ra,40(sp)
    80002e0a:	f022                	sd	s0,32(sp)
    80002e0c:	ec26                	sd	s1,24(sp)
    80002e0e:	e84a                	sd	s2,16(sp)
    80002e10:	e44e                	sd	s3,8(sp)
    80002e12:	1800                	addi	s0,sp,48
    80002e14:	892a                	mv	s2,a0
    80002e16:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e18:	00016517          	auipc	a0,0x16
    80002e1c:	83050513          	addi	a0,a0,-2000 # 80018648 <bcache>
    80002e20:	daffd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e24:	0001e497          	auipc	s1,0x1e
    80002e28:	adc4b483          	ld	s1,-1316(s1) # 80020900 <bcache+0x82b8>
    80002e2c:	0001e797          	auipc	a5,0x1e
    80002e30:	a8478793          	addi	a5,a5,-1404 # 800208b0 <bcache+0x8268>
    80002e34:	02f48b63          	beq	s1,a5,80002e6a <bread+0x64>
    80002e38:	873e                	mv	a4,a5
    80002e3a:	a021                	j	80002e42 <bread+0x3c>
    80002e3c:	68a4                	ld	s1,80(s1)
    80002e3e:	02e48663          	beq	s1,a4,80002e6a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002e42:	449c                	lw	a5,8(s1)
    80002e44:	ff279ce3          	bne	a5,s2,80002e3c <bread+0x36>
    80002e48:	44dc                	lw	a5,12(s1)
    80002e4a:	ff3799e3          	bne	a5,s3,80002e3c <bread+0x36>
      b->refcnt++;
    80002e4e:	40bc                	lw	a5,64(s1)
    80002e50:	2785                	addiw	a5,a5,1
    80002e52:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e54:	00015517          	auipc	a0,0x15
    80002e58:	7f450513          	addi	a0,a0,2036 # 80018648 <bcache>
    80002e5c:	e0bfd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002e60:	01048513          	addi	a0,s1,16
    80002e64:	2d4010ef          	jal	80004138 <acquiresleep>
      return b;
    80002e68:	a889                	j	80002eba <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e6a:	0001e497          	auipc	s1,0x1e
    80002e6e:	a8e4b483          	ld	s1,-1394(s1) # 800208f8 <bcache+0x82b0>
    80002e72:	0001e797          	auipc	a5,0x1e
    80002e76:	a3e78793          	addi	a5,a5,-1474 # 800208b0 <bcache+0x8268>
    80002e7a:	00f48863          	beq	s1,a5,80002e8a <bread+0x84>
    80002e7e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e80:	40bc                	lw	a5,64(s1)
    80002e82:	cb91                	beqz	a5,80002e96 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e84:	64a4                	ld	s1,72(s1)
    80002e86:	fee49de3          	bne	s1,a4,80002e80 <bread+0x7a>
  panic("bget: no buffers");
    80002e8a:	00004517          	auipc	a0,0x4
    80002e8e:	51e50513          	addi	a0,a0,1310 # 800073a8 <etext+0x3a8>
    80002e92:	94ffd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002e96:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e9a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e9e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ea2:	4785                	li	a5,1
    80002ea4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ea6:	00015517          	auipc	a0,0x15
    80002eaa:	7a250513          	addi	a0,a0,1954 # 80018648 <bcache>
    80002eae:	db9fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002eb2:	01048513          	addi	a0,s1,16
    80002eb6:	282010ef          	jal	80004138 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002eba:	409c                	lw	a5,0(s1)
    80002ebc:	cb89                	beqz	a5,80002ece <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ebe:	8526                	mv	a0,s1
    80002ec0:	70a2                	ld	ra,40(sp)
    80002ec2:	7402                	ld	s0,32(sp)
    80002ec4:	64e2                	ld	s1,24(sp)
    80002ec6:	6942                	ld	s2,16(sp)
    80002ec8:	69a2                	ld	s3,8(sp)
    80002eca:	6145                	addi	sp,sp,48
    80002ecc:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ece:	4581                	li	a1,0
    80002ed0:	8526                	mv	a0,s1
    80002ed2:	2cf020ef          	jal	800059a0 <virtio_disk_rw>
    b->valid = 1;
    80002ed6:	4785                	li	a5,1
    80002ed8:	c09c                	sw	a5,0(s1)
  return b;
    80002eda:	b7d5                	j	80002ebe <bread+0xb8>

0000000080002edc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002edc:	1101                	addi	sp,sp,-32
    80002ede:	ec06                	sd	ra,24(sp)
    80002ee0:	e822                	sd	s0,16(sp)
    80002ee2:	e426                	sd	s1,8(sp)
    80002ee4:	1000                	addi	s0,sp,32
    80002ee6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ee8:	0541                	addi	a0,a0,16
    80002eea:	2cc010ef          	jal	800041b6 <holdingsleep>
    80002eee:	c911                	beqz	a0,80002f02 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ef0:	4585                	li	a1,1
    80002ef2:	8526                	mv	a0,s1
    80002ef4:	2ad020ef          	jal	800059a0 <virtio_disk_rw>
}
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	64a2                	ld	s1,8(sp)
    80002efe:	6105                	addi	sp,sp,32
    80002f00:	8082                	ret
    panic("bwrite");
    80002f02:	00004517          	auipc	a0,0x4
    80002f06:	4be50513          	addi	a0,a0,1214 # 800073c0 <etext+0x3c0>
    80002f0a:	8d7fd0ef          	jal	800007e0 <panic>

0000000080002f0e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f0e:	1101                	addi	sp,sp,-32
    80002f10:	ec06                	sd	ra,24(sp)
    80002f12:	e822                	sd	s0,16(sp)
    80002f14:	e426                	sd	s1,8(sp)
    80002f16:	e04a                	sd	s2,0(sp)
    80002f18:	1000                	addi	s0,sp,32
    80002f1a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f1c:	01050913          	addi	s2,a0,16
    80002f20:	854a                	mv	a0,s2
    80002f22:	294010ef          	jal	800041b6 <holdingsleep>
    80002f26:	c135                	beqz	a0,80002f8a <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	254010ef          	jal	8000417e <releasesleep>

  acquire(&bcache.lock);
    80002f2e:	00015517          	auipc	a0,0x15
    80002f32:	71a50513          	addi	a0,a0,1818 # 80018648 <bcache>
    80002f36:	c99fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002f3a:	40bc                	lw	a5,64(s1)
    80002f3c:	37fd                	addiw	a5,a5,-1
    80002f3e:	0007871b          	sext.w	a4,a5
    80002f42:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f44:	e71d                	bnez	a4,80002f72 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f46:	68b8                	ld	a4,80(s1)
    80002f48:	64bc                	ld	a5,72(s1)
    80002f4a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f4c:	68b8                	ld	a4,80(s1)
    80002f4e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f50:	0001d797          	auipc	a5,0x1d
    80002f54:	6f878793          	addi	a5,a5,1784 # 80020648 <bcache+0x8000>
    80002f58:	2b87b703          	ld	a4,696(a5)
    80002f5c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f5e:	0001e717          	auipc	a4,0x1e
    80002f62:	95270713          	addi	a4,a4,-1710 # 800208b0 <bcache+0x8268>
    80002f66:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f68:	2b87b703          	ld	a4,696(a5)
    80002f6c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f6e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f72:	00015517          	auipc	a0,0x15
    80002f76:	6d650513          	addi	a0,a0,1750 # 80018648 <bcache>
    80002f7a:	cedfd0ef          	jal	80000c66 <release>
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	64a2                	ld	s1,8(sp)
    80002f84:	6902                	ld	s2,0(sp)
    80002f86:	6105                	addi	sp,sp,32
    80002f88:	8082                	ret
    panic("brelse");
    80002f8a:	00004517          	auipc	a0,0x4
    80002f8e:	43e50513          	addi	a0,a0,1086 # 800073c8 <etext+0x3c8>
    80002f92:	84ffd0ef          	jal	800007e0 <panic>

0000000080002f96 <bpin>:

void
bpin(struct buf *b) {
    80002f96:	1101                	addi	sp,sp,-32
    80002f98:	ec06                	sd	ra,24(sp)
    80002f9a:	e822                	sd	s0,16(sp)
    80002f9c:	e426                	sd	s1,8(sp)
    80002f9e:	1000                	addi	s0,sp,32
    80002fa0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fa2:	00015517          	auipc	a0,0x15
    80002fa6:	6a650513          	addi	a0,a0,1702 # 80018648 <bcache>
    80002faa:	c25fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002fae:	40bc                	lw	a5,64(s1)
    80002fb0:	2785                	addiw	a5,a5,1
    80002fb2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fb4:	00015517          	auipc	a0,0x15
    80002fb8:	69450513          	addi	a0,a0,1684 # 80018648 <bcache>
    80002fbc:	cabfd0ef          	jal	80000c66 <release>
}
    80002fc0:	60e2                	ld	ra,24(sp)
    80002fc2:	6442                	ld	s0,16(sp)
    80002fc4:	64a2                	ld	s1,8(sp)
    80002fc6:	6105                	addi	sp,sp,32
    80002fc8:	8082                	ret

0000000080002fca <bunpin>:

void
bunpin(struct buf *b) {
    80002fca:	1101                	addi	sp,sp,-32
    80002fcc:	ec06                	sd	ra,24(sp)
    80002fce:	e822                	sd	s0,16(sp)
    80002fd0:	e426                	sd	s1,8(sp)
    80002fd2:	1000                	addi	s0,sp,32
    80002fd4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fd6:	00015517          	auipc	a0,0x15
    80002fda:	67250513          	addi	a0,a0,1650 # 80018648 <bcache>
    80002fde:	bf1fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002fe2:	40bc                	lw	a5,64(s1)
    80002fe4:	37fd                	addiw	a5,a5,-1
    80002fe6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fe8:	00015517          	auipc	a0,0x15
    80002fec:	66050513          	addi	a0,a0,1632 # 80018648 <bcache>
    80002ff0:	c77fd0ef          	jal	80000c66 <release>
}
    80002ff4:	60e2                	ld	ra,24(sp)
    80002ff6:	6442                	ld	s0,16(sp)
    80002ff8:	64a2                	ld	s1,8(sp)
    80002ffa:	6105                	addi	sp,sp,32
    80002ffc:	8082                	ret

0000000080002ffe <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ffe:	1101                	addi	sp,sp,-32
    80003000:	ec06                	sd	ra,24(sp)
    80003002:	e822                	sd	s0,16(sp)
    80003004:	e426                	sd	s1,8(sp)
    80003006:	e04a                	sd	s2,0(sp)
    80003008:	1000                	addi	s0,sp,32
    8000300a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000300c:	00d5d59b          	srliw	a1,a1,0xd
    80003010:	0001e797          	auipc	a5,0x1e
    80003014:	d147a783          	lw	a5,-748(a5) # 80020d24 <sb+0x1c>
    80003018:	9dbd                	addw	a1,a1,a5
    8000301a:	dedff0ef          	jal	80002e06 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000301e:	0074f713          	andi	a4,s1,7
    80003022:	4785                	li	a5,1
    80003024:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003028:	14ce                	slli	s1,s1,0x33
    8000302a:	90d9                	srli	s1,s1,0x36
    8000302c:	00950733          	add	a4,a0,s1
    80003030:	05874703          	lbu	a4,88(a4)
    80003034:	00e7f6b3          	and	a3,a5,a4
    80003038:	c29d                	beqz	a3,8000305e <bfree+0x60>
    8000303a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000303c:	94aa                	add	s1,s1,a0
    8000303e:	fff7c793          	not	a5,a5
    80003042:	8f7d                	and	a4,a4,a5
    80003044:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003048:	7f9000ef          	jal	80004040 <log_write>
  brelse(bp);
    8000304c:	854a                	mv	a0,s2
    8000304e:	ec1ff0ef          	jal	80002f0e <brelse>
}
    80003052:	60e2                	ld	ra,24(sp)
    80003054:	6442                	ld	s0,16(sp)
    80003056:	64a2                	ld	s1,8(sp)
    80003058:	6902                	ld	s2,0(sp)
    8000305a:	6105                	addi	sp,sp,32
    8000305c:	8082                	ret
    panic("freeing free block");
    8000305e:	00004517          	auipc	a0,0x4
    80003062:	37250513          	addi	a0,a0,882 # 800073d0 <etext+0x3d0>
    80003066:	f7afd0ef          	jal	800007e0 <panic>

000000008000306a <balloc>:
{
    8000306a:	711d                	addi	sp,sp,-96
    8000306c:	ec86                	sd	ra,88(sp)
    8000306e:	e8a2                	sd	s0,80(sp)
    80003070:	e4a6                	sd	s1,72(sp)
    80003072:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003074:	0001e797          	auipc	a5,0x1e
    80003078:	c987a783          	lw	a5,-872(a5) # 80020d0c <sb+0x4>
    8000307c:	0e078f63          	beqz	a5,8000317a <balloc+0x110>
    80003080:	e0ca                	sd	s2,64(sp)
    80003082:	fc4e                	sd	s3,56(sp)
    80003084:	f852                	sd	s4,48(sp)
    80003086:	f456                	sd	s5,40(sp)
    80003088:	f05a                	sd	s6,32(sp)
    8000308a:	ec5e                	sd	s7,24(sp)
    8000308c:	e862                	sd	s8,16(sp)
    8000308e:	e466                	sd	s9,8(sp)
    80003090:	8baa                	mv	s7,a0
    80003092:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003094:	0001eb17          	auipc	s6,0x1e
    80003098:	c74b0b13          	addi	s6,s6,-908 # 80020d08 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000309c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000309e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030a0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030a2:	6c89                	lui	s9,0x2
    800030a4:	a0b5                	j	80003110 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800030a6:	97ca                	add	a5,a5,s2
    800030a8:	8e55                	or	a2,a2,a3
    800030aa:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800030ae:	854a                	mv	a0,s2
    800030b0:	791000ef          	jal	80004040 <log_write>
        brelse(bp);
    800030b4:	854a                	mv	a0,s2
    800030b6:	e59ff0ef          	jal	80002f0e <brelse>
  bp = bread(dev, bno);
    800030ba:	85a6                	mv	a1,s1
    800030bc:	855e                	mv	a0,s7
    800030be:	d49ff0ef          	jal	80002e06 <bread>
    800030c2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800030c4:	40000613          	li	a2,1024
    800030c8:	4581                	li	a1,0
    800030ca:	05850513          	addi	a0,a0,88
    800030ce:	bd5fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    800030d2:	854a                	mv	a0,s2
    800030d4:	76d000ef          	jal	80004040 <log_write>
  brelse(bp);
    800030d8:	854a                	mv	a0,s2
    800030da:	e35ff0ef          	jal	80002f0e <brelse>
}
    800030de:	6906                	ld	s2,64(sp)
    800030e0:	79e2                	ld	s3,56(sp)
    800030e2:	7a42                	ld	s4,48(sp)
    800030e4:	7aa2                	ld	s5,40(sp)
    800030e6:	7b02                	ld	s6,32(sp)
    800030e8:	6be2                	ld	s7,24(sp)
    800030ea:	6c42                	ld	s8,16(sp)
    800030ec:	6ca2                	ld	s9,8(sp)
}
    800030ee:	8526                	mv	a0,s1
    800030f0:	60e6                	ld	ra,88(sp)
    800030f2:	6446                	ld	s0,80(sp)
    800030f4:	64a6                	ld	s1,72(sp)
    800030f6:	6125                	addi	sp,sp,96
    800030f8:	8082                	ret
    brelse(bp);
    800030fa:	854a                	mv	a0,s2
    800030fc:	e13ff0ef          	jal	80002f0e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003100:	015c87bb          	addw	a5,s9,s5
    80003104:	00078a9b          	sext.w	s5,a5
    80003108:	004b2703          	lw	a4,4(s6)
    8000310c:	04eaff63          	bgeu	s5,a4,8000316a <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003110:	41fad79b          	sraiw	a5,s5,0x1f
    80003114:	0137d79b          	srliw	a5,a5,0x13
    80003118:	015787bb          	addw	a5,a5,s5
    8000311c:	40d7d79b          	sraiw	a5,a5,0xd
    80003120:	01cb2583          	lw	a1,28(s6)
    80003124:	9dbd                	addw	a1,a1,a5
    80003126:	855e                	mv	a0,s7
    80003128:	cdfff0ef          	jal	80002e06 <bread>
    8000312c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000312e:	004b2503          	lw	a0,4(s6)
    80003132:	000a849b          	sext.w	s1,s5
    80003136:	8762                	mv	a4,s8
    80003138:	fca4f1e3          	bgeu	s1,a0,800030fa <balloc+0x90>
      m = 1 << (bi % 8);
    8000313c:	00777693          	andi	a3,a4,7
    80003140:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003144:	41f7579b          	sraiw	a5,a4,0x1f
    80003148:	01d7d79b          	srliw	a5,a5,0x1d
    8000314c:	9fb9                	addw	a5,a5,a4
    8000314e:	4037d79b          	sraiw	a5,a5,0x3
    80003152:	00f90633          	add	a2,s2,a5
    80003156:	05864603          	lbu	a2,88(a2)
    8000315a:	00c6f5b3          	and	a1,a3,a2
    8000315e:	d5a1                	beqz	a1,800030a6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003160:	2705                	addiw	a4,a4,1
    80003162:	2485                	addiw	s1,s1,1
    80003164:	fd471ae3          	bne	a4,s4,80003138 <balloc+0xce>
    80003168:	bf49                	j	800030fa <balloc+0x90>
    8000316a:	6906                	ld	s2,64(sp)
    8000316c:	79e2                	ld	s3,56(sp)
    8000316e:	7a42                	ld	s4,48(sp)
    80003170:	7aa2                	ld	s5,40(sp)
    80003172:	7b02                	ld	s6,32(sp)
    80003174:	6be2                	ld	s7,24(sp)
    80003176:	6c42                	ld	s8,16(sp)
    80003178:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000317a:	00004517          	auipc	a0,0x4
    8000317e:	26e50513          	addi	a0,a0,622 # 800073e8 <etext+0x3e8>
    80003182:	b78fd0ef          	jal	800004fa <printf>
  return 0;
    80003186:	4481                	li	s1,0
    80003188:	b79d                	j	800030ee <balloc+0x84>

000000008000318a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000318a:	7179                	addi	sp,sp,-48
    8000318c:	f406                	sd	ra,40(sp)
    8000318e:	f022                	sd	s0,32(sp)
    80003190:	ec26                	sd	s1,24(sp)
    80003192:	e84a                	sd	s2,16(sp)
    80003194:	e44e                	sd	s3,8(sp)
    80003196:	1800                	addi	s0,sp,48
    80003198:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000319a:	47ad                	li	a5,11
    8000319c:	02b7e663          	bltu	a5,a1,800031c8 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800031a0:	02059793          	slli	a5,a1,0x20
    800031a4:	01e7d593          	srli	a1,a5,0x1e
    800031a8:	00b504b3          	add	s1,a0,a1
    800031ac:	0504a903          	lw	s2,80(s1)
    800031b0:	06091a63          	bnez	s2,80003224 <bmap+0x9a>
      addr = balloc(ip->dev);
    800031b4:	4108                	lw	a0,0(a0)
    800031b6:	eb5ff0ef          	jal	8000306a <balloc>
    800031ba:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800031be:	06090363          	beqz	s2,80003224 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800031c2:	0524a823          	sw	s2,80(s1)
    800031c6:	a8b9                	j	80003224 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800031c8:	ff45849b          	addiw	s1,a1,-12
    800031cc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800031d0:	0ff00793          	li	a5,255
    800031d4:	06e7ee63          	bltu	a5,a4,80003250 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800031d8:	08052903          	lw	s2,128(a0)
    800031dc:	00091d63          	bnez	s2,800031f6 <bmap+0x6c>
      addr = balloc(ip->dev);
    800031e0:	4108                	lw	a0,0(a0)
    800031e2:	e89ff0ef          	jal	8000306a <balloc>
    800031e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800031ea:	02090d63          	beqz	s2,80003224 <bmap+0x9a>
    800031ee:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800031f0:	0929a023          	sw	s2,128(s3)
    800031f4:	a011                	j	800031f8 <bmap+0x6e>
    800031f6:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800031f8:	85ca                	mv	a1,s2
    800031fa:	0009a503          	lw	a0,0(s3)
    800031fe:	c09ff0ef          	jal	80002e06 <bread>
    80003202:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003204:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003208:	02049713          	slli	a4,s1,0x20
    8000320c:	01e75593          	srli	a1,a4,0x1e
    80003210:	00b784b3          	add	s1,a5,a1
    80003214:	0004a903          	lw	s2,0(s1)
    80003218:	00090e63          	beqz	s2,80003234 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000321c:	8552                	mv	a0,s4
    8000321e:	cf1ff0ef          	jal	80002f0e <brelse>
    return addr;
    80003222:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003224:	854a                	mv	a0,s2
    80003226:	70a2                	ld	ra,40(sp)
    80003228:	7402                	ld	s0,32(sp)
    8000322a:	64e2                	ld	s1,24(sp)
    8000322c:	6942                	ld	s2,16(sp)
    8000322e:	69a2                	ld	s3,8(sp)
    80003230:	6145                	addi	sp,sp,48
    80003232:	8082                	ret
      addr = balloc(ip->dev);
    80003234:	0009a503          	lw	a0,0(s3)
    80003238:	e33ff0ef          	jal	8000306a <balloc>
    8000323c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003240:	fc090ee3          	beqz	s2,8000321c <bmap+0x92>
        a[bn] = addr;
    80003244:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003248:	8552                	mv	a0,s4
    8000324a:	5f7000ef          	jal	80004040 <log_write>
    8000324e:	b7f9                	j	8000321c <bmap+0x92>
    80003250:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003252:	00004517          	auipc	a0,0x4
    80003256:	1ae50513          	addi	a0,a0,430 # 80007400 <etext+0x400>
    8000325a:	d86fd0ef          	jal	800007e0 <panic>

000000008000325e <iget>:
{
    8000325e:	7179                	addi	sp,sp,-48
    80003260:	f406                	sd	ra,40(sp)
    80003262:	f022                	sd	s0,32(sp)
    80003264:	ec26                	sd	s1,24(sp)
    80003266:	e84a                	sd	s2,16(sp)
    80003268:	e44e                	sd	s3,8(sp)
    8000326a:	e052                	sd	s4,0(sp)
    8000326c:	1800                	addi	s0,sp,48
    8000326e:	89aa                	mv	s3,a0
    80003270:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003272:	0001e517          	auipc	a0,0x1e
    80003276:	ab650513          	addi	a0,a0,-1354 # 80020d28 <itable>
    8000327a:	955fd0ef          	jal	80000bce <acquire>
  empty = 0;
    8000327e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003280:	0001e497          	auipc	s1,0x1e
    80003284:	ac048493          	addi	s1,s1,-1344 # 80020d40 <itable+0x18>
    80003288:	0001f697          	auipc	a3,0x1f
    8000328c:	54868693          	addi	a3,a3,1352 # 800227d0 <log>
    80003290:	a039                	j	8000329e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003292:	02090963          	beqz	s2,800032c4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003296:	08848493          	addi	s1,s1,136
    8000329a:	02d48863          	beq	s1,a3,800032ca <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000329e:	449c                	lw	a5,8(s1)
    800032a0:	fef059e3          	blez	a5,80003292 <iget+0x34>
    800032a4:	4098                	lw	a4,0(s1)
    800032a6:	ff3716e3          	bne	a4,s3,80003292 <iget+0x34>
    800032aa:	40d8                	lw	a4,4(s1)
    800032ac:	ff4713e3          	bne	a4,s4,80003292 <iget+0x34>
      ip->ref++;
    800032b0:	2785                	addiw	a5,a5,1
    800032b2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800032b4:	0001e517          	auipc	a0,0x1e
    800032b8:	a7450513          	addi	a0,a0,-1420 # 80020d28 <itable>
    800032bc:	9abfd0ef          	jal	80000c66 <release>
      return ip;
    800032c0:	8926                	mv	s2,s1
    800032c2:	a02d                	j	800032ec <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032c4:	fbe9                	bnez	a5,80003296 <iget+0x38>
      empty = ip;
    800032c6:	8926                	mv	s2,s1
    800032c8:	b7f9                	j	80003296 <iget+0x38>
  if(empty == 0)
    800032ca:	02090a63          	beqz	s2,800032fe <iget+0xa0>
  ip->dev = dev;
    800032ce:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800032d2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800032d6:	4785                	li	a5,1
    800032d8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800032dc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800032e0:	0001e517          	auipc	a0,0x1e
    800032e4:	a4850513          	addi	a0,a0,-1464 # 80020d28 <itable>
    800032e8:	97ffd0ef          	jal	80000c66 <release>
}
    800032ec:	854a                	mv	a0,s2
    800032ee:	70a2                	ld	ra,40(sp)
    800032f0:	7402                	ld	s0,32(sp)
    800032f2:	64e2                	ld	s1,24(sp)
    800032f4:	6942                	ld	s2,16(sp)
    800032f6:	69a2                	ld	s3,8(sp)
    800032f8:	6a02                	ld	s4,0(sp)
    800032fa:	6145                	addi	sp,sp,48
    800032fc:	8082                	ret
    panic("iget: no inodes");
    800032fe:	00004517          	auipc	a0,0x4
    80003302:	11a50513          	addi	a0,a0,282 # 80007418 <etext+0x418>
    80003306:	cdafd0ef          	jal	800007e0 <panic>

000000008000330a <iinit>:
{
    8000330a:	7179                	addi	sp,sp,-48
    8000330c:	f406                	sd	ra,40(sp)
    8000330e:	f022                	sd	s0,32(sp)
    80003310:	ec26                	sd	s1,24(sp)
    80003312:	e84a                	sd	s2,16(sp)
    80003314:	e44e                	sd	s3,8(sp)
    80003316:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003318:	00004597          	auipc	a1,0x4
    8000331c:	11058593          	addi	a1,a1,272 # 80007428 <etext+0x428>
    80003320:	0001e517          	auipc	a0,0x1e
    80003324:	a0850513          	addi	a0,a0,-1528 # 80020d28 <itable>
    80003328:	827fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000332c:	0001e497          	auipc	s1,0x1e
    80003330:	a2448493          	addi	s1,s1,-1500 # 80020d50 <itable+0x28>
    80003334:	0001f997          	auipc	s3,0x1f
    80003338:	4ac98993          	addi	s3,s3,1196 # 800227e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000333c:	00004917          	auipc	s2,0x4
    80003340:	0f490913          	addi	s2,s2,244 # 80007430 <etext+0x430>
    80003344:	85ca                	mv	a1,s2
    80003346:	8526                	mv	a0,s1
    80003348:	5bb000ef          	jal	80004102 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000334c:	08848493          	addi	s1,s1,136
    80003350:	ff349ae3          	bne	s1,s3,80003344 <iinit+0x3a>
}
    80003354:	70a2                	ld	ra,40(sp)
    80003356:	7402                	ld	s0,32(sp)
    80003358:	64e2                	ld	s1,24(sp)
    8000335a:	6942                	ld	s2,16(sp)
    8000335c:	69a2                	ld	s3,8(sp)
    8000335e:	6145                	addi	sp,sp,48
    80003360:	8082                	ret

0000000080003362 <ialloc>:
{
    80003362:	7139                	addi	sp,sp,-64
    80003364:	fc06                	sd	ra,56(sp)
    80003366:	f822                	sd	s0,48(sp)
    80003368:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000336a:	0001e717          	auipc	a4,0x1e
    8000336e:	9aa72703          	lw	a4,-1622(a4) # 80020d14 <sb+0xc>
    80003372:	4785                	li	a5,1
    80003374:	06e7f063          	bgeu	a5,a4,800033d4 <ialloc+0x72>
    80003378:	f426                	sd	s1,40(sp)
    8000337a:	f04a                	sd	s2,32(sp)
    8000337c:	ec4e                	sd	s3,24(sp)
    8000337e:	e852                	sd	s4,16(sp)
    80003380:	e456                	sd	s5,8(sp)
    80003382:	e05a                	sd	s6,0(sp)
    80003384:	8aaa                	mv	s5,a0
    80003386:	8b2e                	mv	s6,a1
    80003388:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000338a:	0001ea17          	auipc	s4,0x1e
    8000338e:	97ea0a13          	addi	s4,s4,-1666 # 80020d08 <sb>
    80003392:	00495593          	srli	a1,s2,0x4
    80003396:	018a2783          	lw	a5,24(s4)
    8000339a:	9dbd                	addw	a1,a1,a5
    8000339c:	8556                	mv	a0,s5
    8000339e:	a69ff0ef          	jal	80002e06 <bread>
    800033a2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800033a4:	05850993          	addi	s3,a0,88
    800033a8:	00f97793          	andi	a5,s2,15
    800033ac:	079a                	slli	a5,a5,0x6
    800033ae:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800033b0:	00099783          	lh	a5,0(s3)
    800033b4:	cb9d                	beqz	a5,800033ea <ialloc+0x88>
    brelse(bp);
    800033b6:	b59ff0ef          	jal	80002f0e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800033ba:	0905                	addi	s2,s2,1
    800033bc:	00ca2703          	lw	a4,12(s4)
    800033c0:	0009079b          	sext.w	a5,s2
    800033c4:	fce7e7e3          	bltu	a5,a4,80003392 <ialloc+0x30>
    800033c8:	74a2                	ld	s1,40(sp)
    800033ca:	7902                	ld	s2,32(sp)
    800033cc:	69e2                	ld	s3,24(sp)
    800033ce:	6a42                	ld	s4,16(sp)
    800033d0:	6aa2                	ld	s5,8(sp)
    800033d2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800033d4:	00004517          	auipc	a0,0x4
    800033d8:	06450513          	addi	a0,a0,100 # 80007438 <etext+0x438>
    800033dc:	91efd0ef          	jal	800004fa <printf>
  return 0;
    800033e0:	4501                	li	a0,0
}
    800033e2:	70e2                	ld	ra,56(sp)
    800033e4:	7442                	ld	s0,48(sp)
    800033e6:	6121                	addi	sp,sp,64
    800033e8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033ea:	04000613          	li	a2,64
    800033ee:	4581                	li	a1,0
    800033f0:	854e                	mv	a0,s3
    800033f2:	8b1fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    800033f6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800033fa:	8526                	mv	a0,s1
    800033fc:	445000ef          	jal	80004040 <log_write>
      brelse(bp);
    80003400:	8526                	mv	a0,s1
    80003402:	b0dff0ef          	jal	80002f0e <brelse>
      return iget(dev, inum);
    80003406:	0009059b          	sext.w	a1,s2
    8000340a:	8556                	mv	a0,s5
    8000340c:	e53ff0ef          	jal	8000325e <iget>
    80003410:	74a2                	ld	s1,40(sp)
    80003412:	7902                	ld	s2,32(sp)
    80003414:	69e2                	ld	s3,24(sp)
    80003416:	6a42                	ld	s4,16(sp)
    80003418:	6aa2                	ld	s5,8(sp)
    8000341a:	6b02                	ld	s6,0(sp)
    8000341c:	b7d9                	j	800033e2 <ialloc+0x80>

000000008000341e <iupdate>:
{
    8000341e:	1101                	addi	sp,sp,-32
    80003420:	ec06                	sd	ra,24(sp)
    80003422:	e822                	sd	s0,16(sp)
    80003424:	e426                	sd	s1,8(sp)
    80003426:	e04a                	sd	s2,0(sp)
    80003428:	1000                	addi	s0,sp,32
    8000342a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000342c:	415c                	lw	a5,4(a0)
    8000342e:	0047d79b          	srliw	a5,a5,0x4
    80003432:	0001e597          	auipc	a1,0x1e
    80003436:	8ee5a583          	lw	a1,-1810(a1) # 80020d20 <sb+0x18>
    8000343a:	9dbd                	addw	a1,a1,a5
    8000343c:	4108                	lw	a0,0(a0)
    8000343e:	9c9ff0ef          	jal	80002e06 <bread>
    80003442:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003444:	05850793          	addi	a5,a0,88
    80003448:	40d8                	lw	a4,4(s1)
    8000344a:	8b3d                	andi	a4,a4,15
    8000344c:	071a                	slli	a4,a4,0x6
    8000344e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003450:	04449703          	lh	a4,68(s1)
    80003454:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003458:	04649703          	lh	a4,70(s1)
    8000345c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003460:	04849703          	lh	a4,72(s1)
    80003464:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003468:	04a49703          	lh	a4,74(s1)
    8000346c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003470:	44f8                	lw	a4,76(s1)
    80003472:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003474:	03400613          	li	a2,52
    80003478:	05048593          	addi	a1,s1,80
    8000347c:	00c78513          	addi	a0,a5,12
    80003480:	87ffd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    80003484:	854a                	mv	a0,s2
    80003486:	3bb000ef          	jal	80004040 <log_write>
  brelse(bp);
    8000348a:	854a                	mv	a0,s2
    8000348c:	a83ff0ef          	jal	80002f0e <brelse>
}
    80003490:	60e2                	ld	ra,24(sp)
    80003492:	6442                	ld	s0,16(sp)
    80003494:	64a2                	ld	s1,8(sp)
    80003496:	6902                	ld	s2,0(sp)
    80003498:	6105                	addi	sp,sp,32
    8000349a:	8082                	ret

000000008000349c <idup>:
{
    8000349c:	1101                	addi	sp,sp,-32
    8000349e:	ec06                	sd	ra,24(sp)
    800034a0:	e822                	sd	s0,16(sp)
    800034a2:	e426                	sd	s1,8(sp)
    800034a4:	1000                	addi	s0,sp,32
    800034a6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034a8:	0001e517          	auipc	a0,0x1e
    800034ac:	88050513          	addi	a0,a0,-1920 # 80020d28 <itable>
    800034b0:	f1efd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800034b4:	449c                	lw	a5,8(s1)
    800034b6:	2785                	addiw	a5,a5,1
    800034b8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034ba:	0001e517          	auipc	a0,0x1e
    800034be:	86e50513          	addi	a0,a0,-1938 # 80020d28 <itable>
    800034c2:	fa4fd0ef          	jal	80000c66 <release>
}
    800034c6:	8526                	mv	a0,s1
    800034c8:	60e2                	ld	ra,24(sp)
    800034ca:	6442                	ld	s0,16(sp)
    800034cc:	64a2                	ld	s1,8(sp)
    800034ce:	6105                	addi	sp,sp,32
    800034d0:	8082                	ret

00000000800034d2 <ilock>:
{
    800034d2:	1101                	addi	sp,sp,-32
    800034d4:	ec06                	sd	ra,24(sp)
    800034d6:	e822                	sd	s0,16(sp)
    800034d8:	e426                	sd	s1,8(sp)
    800034da:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800034dc:	cd19                	beqz	a0,800034fa <ilock+0x28>
    800034de:	84aa                	mv	s1,a0
    800034e0:	451c                	lw	a5,8(a0)
    800034e2:	00f05c63          	blez	a5,800034fa <ilock+0x28>
  acquiresleep(&ip->lock);
    800034e6:	0541                	addi	a0,a0,16
    800034e8:	451000ef          	jal	80004138 <acquiresleep>
  if(ip->valid == 0){
    800034ec:	40bc                	lw	a5,64(s1)
    800034ee:	cf89                	beqz	a5,80003508 <ilock+0x36>
}
    800034f0:	60e2                	ld	ra,24(sp)
    800034f2:	6442                	ld	s0,16(sp)
    800034f4:	64a2                	ld	s1,8(sp)
    800034f6:	6105                	addi	sp,sp,32
    800034f8:	8082                	ret
    800034fa:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800034fc:	00004517          	auipc	a0,0x4
    80003500:	f5450513          	addi	a0,a0,-172 # 80007450 <etext+0x450>
    80003504:	adcfd0ef          	jal	800007e0 <panic>
    80003508:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000350a:	40dc                	lw	a5,4(s1)
    8000350c:	0047d79b          	srliw	a5,a5,0x4
    80003510:	0001e597          	auipc	a1,0x1e
    80003514:	8105a583          	lw	a1,-2032(a1) # 80020d20 <sb+0x18>
    80003518:	9dbd                	addw	a1,a1,a5
    8000351a:	4088                	lw	a0,0(s1)
    8000351c:	8ebff0ef          	jal	80002e06 <bread>
    80003520:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003522:	05850593          	addi	a1,a0,88
    80003526:	40dc                	lw	a5,4(s1)
    80003528:	8bbd                	andi	a5,a5,15
    8000352a:	079a                	slli	a5,a5,0x6
    8000352c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000352e:	00059783          	lh	a5,0(a1)
    80003532:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003536:	00259783          	lh	a5,2(a1)
    8000353a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000353e:	00459783          	lh	a5,4(a1)
    80003542:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003546:	00659783          	lh	a5,6(a1)
    8000354a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000354e:	459c                	lw	a5,8(a1)
    80003550:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003552:	03400613          	li	a2,52
    80003556:	05b1                	addi	a1,a1,12
    80003558:	05048513          	addi	a0,s1,80
    8000355c:	fa2fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003560:	854a                	mv	a0,s2
    80003562:	9adff0ef          	jal	80002f0e <brelse>
    ip->valid = 1;
    80003566:	4785                	li	a5,1
    80003568:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000356a:	04449783          	lh	a5,68(s1)
    8000356e:	c399                	beqz	a5,80003574 <ilock+0xa2>
    80003570:	6902                	ld	s2,0(sp)
    80003572:	bfbd                	j	800034f0 <ilock+0x1e>
      panic("ilock: no type");
    80003574:	00004517          	auipc	a0,0x4
    80003578:	ee450513          	addi	a0,a0,-284 # 80007458 <etext+0x458>
    8000357c:	a64fd0ef          	jal	800007e0 <panic>

0000000080003580 <iunlock>:
{
    80003580:	1101                	addi	sp,sp,-32
    80003582:	ec06                	sd	ra,24(sp)
    80003584:	e822                	sd	s0,16(sp)
    80003586:	e426                	sd	s1,8(sp)
    80003588:	e04a                	sd	s2,0(sp)
    8000358a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000358c:	c505                	beqz	a0,800035b4 <iunlock+0x34>
    8000358e:	84aa                	mv	s1,a0
    80003590:	01050913          	addi	s2,a0,16
    80003594:	854a                	mv	a0,s2
    80003596:	421000ef          	jal	800041b6 <holdingsleep>
    8000359a:	cd09                	beqz	a0,800035b4 <iunlock+0x34>
    8000359c:	449c                	lw	a5,8(s1)
    8000359e:	00f05b63          	blez	a5,800035b4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800035a2:	854a                	mv	a0,s2
    800035a4:	3db000ef          	jal	8000417e <releasesleep>
}
    800035a8:	60e2                	ld	ra,24(sp)
    800035aa:	6442                	ld	s0,16(sp)
    800035ac:	64a2                	ld	s1,8(sp)
    800035ae:	6902                	ld	s2,0(sp)
    800035b0:	6105                	addi	sp,sp,32
    800035b2:	8082                	ret
    panic("iunlock");
    800035b4:	00004517          	auipc	a0,0x4
    800035b8:	eb450513          	addi	a0,a0,-332 # 80007468 <etext+0x468>
    800035bc:	a24fd0ef          	jal	800007e0 <panic>

00000000800035c0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035c0:	7179                	addi	sp,sp,-48
    800035c2:	f406                	sd	ra,40(sp)
    800035c4:	f022                	sd	s0,32(sp)
    800035c6:	ec26                	sd	s1,24(sp)
    800035c8:	e84a                	sd	s2,16(sp)
    800035ca:	e44e                	sd	s3,8(sp)
    800035cc:	1800                	addi	s0,sp,48
    800035ce:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800035d0:	05050493          	addi	s1,a0,80
    800035d4:	08050913          	addi	s2,a0,128
    800035d8:	a021                	j	800035e0 <itrunc+0x20>
    800035da:	0491                	addi	s1,s1,4
    800035dc:	01248b63          	beq	s1,s2,800035f2 <itrunc+0x32>
    if(ip->addrs[i]){
    800035e0:	408c                	lw	a1,0(s1)
    800035e2:	dde5                	beqz	a1,800035da <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800035e4:	0009a503          	lw	a0,0(s3)
    800035e8:	a17ff0ef          	jal	80002ffe <bfree>
      ip->addrs[i] = 0;
    800035ec:	0004a023          	sw	zero,0(s1)
    800035f0:	b7ed                	j	800035da <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800035f2:	0809a583          	lw	a1,128(s3)
    800035f6:	ed89                	bnez	a1,80003610 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800035f8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800035fc:	854e                	mv	a0,s3
    800035fe:	e21ff0ef          	jal	8000341e <iupdate>
}
    80003602:	70a2                	ld	ra,40(sp)
    80003604:	7402                	ld	s0,32(sp)
    80003606:	64e2                	ld	s1,24(sp)
    80003608:	6942                	ld	s2,16(sp)
    8000360a:	69a2                	ld	s3,8(sp)
    8000360c:	6145                	addi	sp,sp,48
    8000360e:	8082                	ret
    80003610:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003612:	0009a503          	lw	a0,0(s3)
    80003616:	ff0ff0ef          	jal	80002e06 <bread>
    8000361a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000361c:	05850493          	addi	s1,a0,88
    80003620:	45850913          	addi	s2,a0,1112
    80003624:	a021                	j	8000362c <itrunc+0x6c>
    80003626:	0491                	addi	s1,s1,4
    80003628:	01248963          	beq	s1,s2,8000363a <itrunc+0x7a>
      if(a[j])
    8000362c:	408c                	lw	a1,0(s1)
    8000362e:	dde5                	beqz	a1,80003626 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003630:	0009a503          	lw	a0,0(s3)
    80003634:	9cbff0ef          	jal	80002ffe <bfree>
    80003638:	b7fd                	j	80003626 <itrunc+0x66>
    brelse(bp);
    8000363a:	8552                	mv	a0,s4
    8000363c:	8d3ff0ef          	jal	80002f0e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003640:	0809a583          	lw	a1,128(s3)
    80003644:	0009a503          	lw	a0,0(s3)
    80003648:	9b7ff0ef          	jal	80002ffe <bfree>
    ip->addrs[NDIRECT] = 0;
    8000364c:	0809a023          	sw	zero,128(s3)
    80003650:	6a02                	ld	s4,0(sp)
    80003652:	b75d                	j	800035f8 <itrunc+0x38>

0000000080003654 <iput>:
{
    80003654:	1101                	addi	sp,sp,-32
    80003656:	ec06                	sd	ra,24(sp)
    80003658:	e822                	sd	s0,16(sp)
    8000365a:	e426                	sd	s1,8(sp)
    8000365c:	1000                	addi	s0,sp,32
    8000365e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003660:	0001d517          	auipc	a0,0x1d
    80003664:	6c850513          	addi	a0,a0,1736 # 80020d28 <itable>
    80003668:	d66fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000366c:	4498                	lw	a4,8(s1)
    8000366e:	4785                	li	a5,1
    80003670:	02f70063          	beq	a4,a5,80003690 <iput+0x3c>
  ip->ref--;
    80003674:	449c                	lw	a5,8(s1)
    80003676:	37fd                	addiw	a5,a5,-1
    80003678:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000367a:	0001d517          	auipc	a0,0x1d
    8000367e:	6ae50513          	addi	a0,a0,1710 # 80020d28 <itable>
    80003682:	de4fd0ef          	jal	80000c66 <release>
}
    80003686:	60e2                	ld	ra,24(sp)
    80003688:	6442                	ld	s0,16(sp)
    8000368a:	64a2                	ld	s1,8(sp)
    8000368c:	6105                	addi	sp,sp,32
    8000368e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003690:	40bc                	lw	a5,64(s1)
    80003692:	d3ed                	beqz	a5,80003674 <iput+0x20>
    80003694:	04a49783          	lh	a5,74(s1)
    80003698:	fff1                	bnez	a5,80003674 <iput+0x20>
    8000369a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000369c:	01048913          	addi	s2,s1,16
    800036a0:	854a                	mv	a0,s2
    800036a2:	297000ef          	jal	80004138 <acquiresleep>
    release(&itable.lock);
    800036a6:	0001d517          	auipc	a0,0x1d
    800036aa:	68250513          	addi	a0,a0,1666 # 80020d28 <itable>
    800036ae:	db8fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800036b2:	8526                	mv	a0,s1
    800036b4:	f0dff0ef          	jal	800035c0 <itrunc>
    ip->type = 0;
    800036b8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800036bc:	8526                	mv	a0,s1
    800036be:	d61ff0ef          	jal	8000341e <iupdate>
    ip->valid = 0;
    800036c2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036c6:	854a                	mv	a0,s2
    800036c8:	2b7000ef          	jal	8000417e <releasesleep>
    acquire(&itable.lock);
    800036cc:	0001d517          	auipc	a0,0x1d
    800036d0:	65c50513          	addi	a0,a0,1628 # 80020d28 <itable>
    800036d4:	cfafd0ef          	jal	80000bce <acquire>
    800036d8:	6902                	ld	s2,0(sp)
    800036da:	bf69                	j	80003674 <iput+0x20>

00000000800036dc <iunlockput>:
{
    800036dc:	1101                	addi	sp,sp,-32
    800036de:	ec06                	sd	ra,24(sp)
    800036e0:	e822                	sd	s0,16(sp)
    800036e2:	e426                	sd	s1,8(sp)
    800036e4:	1000                	addi	s0,sp,32
    800036e6:	84aa                	mv	s1,a0
  iunlock(ip);
    800036e8:	e99ff0ef          	jal	80003580 <iunlock>
  iput(ip);
    800036ec:	8526                	mv	a0,s1
    800036ee:	f67ff0ef          	jal	80003654 <iput>
}
    800036f2:	60e2                	ld	ra,24(sp)
    800036f4:	6442                	ld	s0,16(sp)
    800036f6:	64a2                	ld	s1,8(sp)
    800036f8:	6105                	addi	sp,sp,32
    800036fa:	8082                	ret

00000000800036fc <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036fc:	0001d717          	auipc	a4,0x1d
    80003700:	61872703          	lw	a4,1560(a4) # 80020d14 <sb+0xc>
    80003704:	4785                	li	a5,1
    80003706:	0ae7ff63          	bgeu	a5,a4,800037c4 <ireclaim+0xc8>
{
    8000370a:	7139                	addi	sp,sp,-64
    8000370c:	fc06                	sd	ra,56(sp)
    8000370e:	f822                	sd	s0,48(sp)
    80003710:	f426                	sd	s1,40(sp)
    80003712:	f04a                	sd	s2,32(sp)
    80003714:	ec4e                	sd	s3,24(sp)
    80003716:	e852                	sd	s4,16(sp)
    80003718:	e456                	sd	s5,8(sp)
    8000371a:	e05a                	sd	s6,0(sp)
    8000371c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000371e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003720:	00050a1b          	sext.w	s4,a0
    80003724:	0001da97          	auipc	s5,0x1d
    80003728:	5e4a8a93          	addi	s5,s5,1508 # 80020d08 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000372c:	00004b17          	auipc	s6,0x4
    80003730:	d44b0b13          	addi	s6,s6,-700 # 80007470 <etext+0x470>
    80003734:	a099                	j	8000377a <ireclaim+0x7e>
    80003736:	85ce                	mv	a1,s3
    80003738:	855a                	mv	a0,s6
    8000373a:	dc1fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    8000373e:	85ce                	mv	a1,s3
    80003740:	8552                	mv	a0,s4
    80003742:	b1dff0ef          	jal	8000325e <iget>
    80003746:	89aa                	mv	s3,a0
    brelse(bp);
    80003748:	854a                	mv	a0,s2
    8000374a:	fc4ff0ef          	jal	80002f0e <brelse>
    if (ip) {
    8000374e:	00098f63          	beqz	s3,8000376c <ireclaim+0x70>
      begin_op();
    80003752:	76a000ef          	jal	80003ebc <begin_op>
      ilock(ip);
    80003756:	854e                	mv	a0,s3
    80003758:	d7bff0ef          	jal	800034d2 <ilock>
      iunlock(ip);
    8000375c:	854e                	mv	a0,s3
    8000375e:	e23ff0ef          	jal	80003580 <iunlock>
      iput(ip);
    80003762:	854e                	mv	a0,s3
    80003764:	ef1ff0ef          	jal	80003654 <iput>
      end_op();
    80003768:	7be000ef          	jal	80003f26 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000376c:	0485                	addi	s1,s1,1
    8000376e:	00caa703          	lw	a4,12(s5)
    80003772:	0004879b          	sext.w	a5,s1
    80003776:	02e7fd63          	bgeu	a5,a4,800037b0 <ireclaim+0xb4>
    8000377a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000377e:	0044d593          	srli	a1,s1,0x4
    80003782:	018aa783          	lw	a5,24(s5)
    80003786:	9dbd                	addw	a1,a1,a5
    80003788:	8552                	mv	a0,s4
    8000378a:	e7cff0ef          	jal	80002e06 <bread>
    8000378e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003790:	05850793          	addi	a5,a0,88
    80003794:	00f9f713          	andi	a4,s3,15
    80003798:	071a                	slli	a4,a4,0x6
    8000379a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000379c:	00079703          	lh	a4,0(a5)
    800037a0:	c701                	beqz	a4,800037a8 <ireclaim+0xac>
    800037a2:	00679783          	lh	a5,6(a5)
    800037a6:	dbc1                	beqz	a5,80003736 <ireclaim+0x3a>
    brelse(bp);
    800037a8:	854a                	mv	a0,s2
    800037aa:	f64ff0ef          	jal	80002f0e <brelse>
    if (ip) {
    800037ae:	bf7d                	j	8000376c <ireclaim+0x70>
}
    800037b0:	70e2                	ld	ra,56(sp)
    800037b2:	7442                	ld	s0,48(sp)
    800037b4:	74a2                	ld	s1,40(sp)
    800037b6:	7902                	ld	s2,32(sp)
    800037b8:	69e2                	ld	s3,24(sp)
    800037ba:	6a42                	ld	s4,16(sp)
    800037bc:	6aa2                	ld	s5,8(sp)
    800037be:	6b02                	ld	s6,0(sp)
    800037c0:	6121                	addi	sp,sp,64
    800037c2:	8082                	ret
    800037c4:	8082                	ret

00000000800037c6 <fsinit>:
fsinit(int dev) {
    800037c6:	7179                	addi	sp,sp,-48
    800037c8:	f406                	sd	ra,40(sp)
    800037ca:	f022                	sd	s0,32(sp)
    800037cc:	ec26                	sd	s1,24(sp)
    800037ce:	e84a                	sd	s2,16(sp)
    800037d0:	e44e                	sd	s3,8(sp)
    800037d2:	1800                	addi	s0,sp,48
    800037d4:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800037d6:	4585                	li	a1,1
    800037d8:	e2eff0ef          	jal	80002e06 <bread>
    800037dc:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037de:	0001d997          	auipc	s3,0x1d
    800037e2:	52a98993          	addi	s3,s3,1322 # 80020d08 <sb>
    800037e6:	02000613          	li	a2,32
    800037ea:	05850593          	addi	a1,a0,88
    800037ee:	854e                	mv	a0,s3
    800037f0:	d0efd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    800037f4:	854a                	mv	a0,s2
    800037f6:	f18ff0ef          	jal	80002f0e <brelse>
  if(sb.magic != FSMAGIC)
    800037fa:	0009a703          	lw	a4,0(s3)
    800037fe:	102037b7          	lui	a5,0x10203
    80003802:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003806:	02f71363          	bne	a4,a5,8000382c <fsinit+0x66>
  initlog(dev, &sb);
    8000380a:	0001d597          	auipc	a1,0x1d
    8000380e:	4fe58593          	addi	a1,a1,1278 # 80020d08 <sb>
    80003812:	8526                	mv	a0,s1
    80003814:	62a000ef          	jal	80003e3e <initlog>
  ireclaim(dev);
    80003818:	8526                	mv	a0,s1
    8000381a:	ee3ff0ef          	jal	800036fc <ireclaim>
}
    8000381e:	70a2                	ld	ra,40(sp)
    80003820:	7402                	ld	s0,32(sp)
    80003822:	64e2                	ld	s1,24(sp)
    80003824:	6942                	ld	s2,16(sp)
    80003826:	69a2                	ld	s3,8(sp)
    80003828:	6145                	addi	sp,sp,48
    8000382a:	8082                	ret
    panic("invalid file system");
    8000382c:	00004517          	auipc	a0,0x4
    80003830:	c6450513          	addi	a0,a0,-924 # 80007490 <etext+0x490>
    80003834:	fadfc0ef          	jal	800007e0 <panic>

0000000080003838 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003838:	1141                	addi	sp,sp,-16
    8000383a:	e422                	sd	s0,8(sp)
    8000383c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000383e:	411c                	lw	a5,0(a0)
    80003840:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003842:	415c                	lw	a5,4(a0)
    80003844:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003846:	04451783          	lh	a5,68(a0)
    8000384a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000384e:	04a51783          	lh	a5,74(a0)
    80003852:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003856:	04c56783          	lwu	a5,76(a0)
    8000385a:	e99c                	sd	a5,16(a1)
}
    8000385c:	6422                	ld	s0,8(sp)
    8000385e:	0141                	addi	sp,sp,16
    80003860:	8082                	ret

0000000080003862 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003862:	457c                	lw	a5,76(a0)
    80003864:	0ed7eb63          	bltu	a5,a3,8000395a <readi+0xf8>
{
    80003868:	7159                	addi	sp,sp,-112
    8000386a:	f486                	sd	ra,104(sp)
    8000386c:	f0a2                	sd	s0,96(sp)
    8000386e:	eca6                	sd	s1,88(sp)
    80003870:	e0d2                	sd	s4,64(sp)
    80003872:	fc56                	sd	s5,56(sp)
    80003874:	f85a                	sd	s6,48(sp)
    80003876:	f45e                	sd	s7,40(sp)
    80003878:	1880                	addi	s0,sp,112
    8000387a:	8b2a                	mv	s6,a0
    8000387c:	8bae                	mv	s7,a1
    8000387e:	8a32                	mv	s4,a2
    80003880:	84b6                	mv	s1,a3
    80003882:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003884:	9f35                	addw	a4,a4,a3
    return 0;
    80003886:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003888:	0cd76063          	bltu	a4,a3,80003948 <readi+0xe6>
    8000388c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000388e:	00e7f463          	bgeu	a5,a4,80003896 <readi+0x34>
    n = ip->size - off;
    80003892:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003896:	080a8f63          	beqz	s5,80003934 <readi+0xd2>
    8000389a:	e8ca                	sd	s2,80(sp)
    8000389c:	f062                	sd	s8,32(sp)
    8000389e:	ec66                	sd	s9,24(sp)
    800038a0:	e86a                	sd	s10,16(sp)
    800038a2:	e46e                	sd	s11,8(sp)
    800038a4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038a6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038aa:	5c7d                	li	s8,-1
    800038ac:	a80d                	j	800038de <readi+0x7c>
    800038ae:	020d1d93          	slli	s11,s10,0x20
    800038b2:	020ddd93          	srli	s11,s11,0x20
    800038b6:	05890613          	addi	a2,s2,88
    800038ba:	86ee                	mv	a3,s11
    800038bc:	963a                	add	a2,a2,a4
    800038be:	85d2                	mv	a1,s4
    800038c0:	855e                	mv	a0,s7
    800038c2:	bb9fe0ef          	jal	8000247a <either_copyout>
    800038c6:	05850763          	beq	a0,s8,80003914 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038ca:	854a                	mv	a0,s2
    800038cc:	e42ff0ef          	jal	80002f0e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038d0:	013d09bb          	addw	s3,s10,s3
    800038d4:	009d04bb          	addw	s1,s10,s1
    800038d8:	9a6e                	add	s4,s4,s11
    800038da:	0559f763          	bgeu	s3,s5,80003928 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800038de:	00a4d59b          	srliw	a1,s1,0xa
    800038e2:	855a                	mv	a0,s6
    800038e4:	8a7ff0ef          	jal	8000318a <bmap>
    800038e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038ec:	c5b1                	beqz	a1,80003938 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800038ee:	000b2503          	lw	a0,0(s6)
    800038f2:	d14ff0ef          	jal	80002e06 <bread>
    800038f6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038f8:	3ff4f713          	andi	a4,s1,1023
    800038fc:	40ec87bb          	subw	a5,s9,a4
    80003900:	413a86bb          	subw	a3,s5,s3
    80003904:	8d3e                	mv	s10,a5
    80003906:	2781                	sext.w	a5,a5
    80003908:	0006861b          	sext.w	a2,a3
    8000390c:	faf671e3          	bgeu	a2,a5,800038ae <readi+0x4c>
    80003910:	8d36                	mv	s10,a3
    80003912:	bf71                	j	800038ae <readi+0x4c>
      brelse(bp);
    80003914:	854a                	mv	a0,s2
    80003916:	df8ff0ef          	jal	80002f0e <brelse>
      tot = -1;
    8000391a:	59fd                	li	s3,-1
      break;
    8000391c:	6946                	ld	s2,80(sp)
    8000391e:	7c02                	ld	s8,32(sp)
    80003920:	6ce2                	ld	s9,24(sp)
    80003922:	6d42                	ld	s10,16(sp)
    80003924:	6da2                	ld	s11,8(sp)
    80003926:	a831                	j	80003942 <readi+0xe0>
    80003928:	6946                	ld	s2,80(sp)
    8000392a:	7c02                	ld	s8,32(sp)
    8000392c:	6ce2                	ld	s9,24(sp)
    8000392e:	6d42                	ld	s10,16(sp)
    80003930:	6da2                	ld	s11,8(sp)
    80003932:	a801                	j	80003942 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003934:	89d6                	mv	s3,s5
    80003936:	a031                	j	80003942 <readi+0xe0>
    80003938:	6946                	ld	s2,80(sp)
    8000393a:	7c02                	ld	s8,32(sp)
    8000393c:	6ce2                	ld	s9,24(sp)
    8000393e:	6d42                	ld	s10,16(sp)
    80003940:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003942:	0009851b          	sext.w	a0,s3
    80003946:	69a6                	ld	s3,72(sp)
}
    80003948:	70a6                	ld	ra,104(sp)
    8000394a:	7406                	ld	s0,96(sp)
    8000394c:	64e6                	ld	s1,88(sp)
    8000394e:	6a06                	ld	s4,64(sp)
    80003950:	7ae2                	ld	s5,56(sp)
    80003952:	7b42                	ld	s6,48(sp)
    80003954:	7ba2                	ld	s7,40(sp)
    80003956:	6165                	addi	sp,sp,112
    80003958:	8082                	ret
    return 0;
    8000395a:	4501                	li	a0,0
}
    8000395c:	8082                	ret

000000008000395e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000395e:	457c                	lw	a5,76(a0)
    80003960:	10d7e063          	bltu	a5,a3,80003a60 <writei+0x102>
{
    80003964:	7159                	addi	sp,sp,-112
    80003966:	f486                	sd	ra,104(sp)
    80003968:	f0a2                	sd	s0,96(sp)
    8000396a:	e8ca                	sd	s2,80(sp)
    8000396c:	e0d2                	sd	s4,64(sp)
    8000396e:	fc56                	sd	s5,56(sp)
    80003970:	f85a                	sd	s6,48(sp)
    80003972:	f45e                	sd	s7,40(sp)
    80003974:	1880                	addi	s0,sp,112
    80003976:	8aaa                	mv	s5,a0
    80003978:	8bae                	mv	s7,a1
    8000397a:	8a32                	mv	s4,a2
    8000397c:	8936                	mv	s2,a3
    8000397e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003980:	00e687bb          	addw	a5,a3,a4
    80003984:	0ed7e063          	bltu	a5,a3,80003a64 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003988:	00043737          	lui	a4,0x43
    8000398c:	0cf76e63          	bltu	a4,a5,80003a68 <writei+0x10a>
    80003990:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003992:	0a0b0f63          	beqz	s6,80003a50 <writei+0xf2>
    80003996:	eca6                	sd	s1,88(sp)
    80003998:	f062                	sd	s8,32(sp)
    8000399a:	ec66                	sd	s9,24(sp)
    8000399c:	e86a                	sd	s10,16(sp)
    8000399e:	e46e                	sd	s11,8(sp)
    800039a0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039a2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039a6:	5c7d                	li	s8,-1
    800039a8:	a825                	j	800039e0 <writei+0x82>
    800039aa:	020d1d93          	slli	s11,s10,0x20
    800039ae:	020ddd93          	srli	s11,s11,0x20
    800039b2:	05848513          	addi	a0,s1,88
    800039b6:	86ee                	mv	a3,s11
    800039b8:	8652                	mv	a2,s4
    800039ba:	85de                	mv	a1,s7
    800039bc:	953a                	add	a0,a0,a4
    800039be:	b07fe0ef          	jal	800024c4 <either_copyin>
    800039c2:	05850a63          	beq	a0,s8,80003a16 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039c6:	8526                	mv	a0,s1
    800039c8:	678000ef          	jal	80004040 <log_write>
    brelse(bp);
    800039cc:	8526                	mv	a0,s1
    800039ce:	d40ff0ef          	jal	80002f0e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039d2:	013d09bb          	addw	s3,s10,s3
    800039d6:	012d093b          	addw	s2,s10,s2
    800039da:	9a6e                	add	s4,s4,s11
    800039dc:	0569f063          	bgeu	s3,s6,80003a1c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800039e0:	00a9559b          	srliw	a1,s2,0xa
    800039e4:	8556                	mv	a0,s5
    800039e6:	fa4ff0ef          	jal	8000318a <bmap>
    800039ea:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039ee:	c59d                	beqz	a1,80003a1c <writei+0xbe>
    bp = bread(ip->dev, addr);
    800039f0:	000aa503          	lw	a0,0(s5)
    800039f4:	c12ff0ef          	jal	80002e06 <bread>
    800039f8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039fa:	3ff97713          	andi	a4,s2,1023
    800039fe:	40ec87bb          	subw	a5,s9,a4
    80003a02:	413b06bb          	subw	a3,s6,s3
    80003a06:	8d3e                	mv	s10,a5
    80003a08:	2781                	sext.w	a5,a5
    80003a0a:	0006861b          	sext.w	a2,a3
    80003a0e:	f8f67ee3          	bgeu	a2,a5,800039aa <writei+0x4c>
    80003a12:	8d36                	mv	s10,a3
    80003a14:	bf59                	j	800039aa <writei+0x4c>
      brelse(bp);
    80003a16:	8526                	mv	a0,s1
    80003a18:	cf6ff0ef          	jal	80002f0e <brelse>
  }

  if(off > ip->size)
    80003a1c:	04caa783          	lw	a5,76(s5)
    80003a20:	0327fa63          	bgeu	a5,s2,80003a54 <writei+0xf6>
    ip->size = off;
    80003a24:	052aa623          	sw	s2,76(s5)
    80003a28:	64e6                	ld	s1,88(sp)
    80003a2a:	7c02                	ld	s8,32(sp)
    80003a2c:	6ce2                	ld	s9,24(sp)
    80003a2e:	6d42                	ld	s10,16(sp)
    80003a30:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a32:	8556                	mv	a0,s5
    80003a34:	9ebff0ef          	jal	8000341e <iupdate>

  return tot;
    80003a38:	0009851b          	sext.w	a0,s3
    80003a3c:	69a6                	ld	s3,72(sp)
}
    80003a3e:	70a6                	ld	ra,104(sp)
    80003a40:	7406                	ld	s0,96(sp)
    80003a42:	6946                	ld	s2,80(sp)
    80003a44:	6a06                	ld	s4,64(sp)
    80003a46:	7ae2                	ld	s5,56(sp)
    80003a48:	7b42                	ld	s6,48(sp)
    80003a4a:	7ba2                	ld	s7,40(sp)
    80003a4c:	6165                	addi	sp,sp,112
    80003a4e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a50:	89da                	mv	s3,s6
    80003a52:	b7c5                	j	80003a32 <writei+0xd4>
    80003a54:	64e6                	ld	s1,88(sp)
    80003a56:	7c02                	ld	s8,32(sp)
    80003a58:	6ce2                	ld	s9,24(sp)
    80003a5a:	6d42                	ld	s10,16(sp)
    80003a5c:	6da2                	ld	s11,8(sp)
    80003a5e:	bfd1                	j	80003a32 <writei+0xd4>
    return -1;
    80003a60:	557d                	li	a0,-1
}
    80003a62:	8082                	ret
    return -1;
    80003a64:	557d                	li	a0,-1
    80003a66:	bfe1                	j	80003a3e <writei+0xe0>
    return -1;
    80003a68:	557d                	li	a0,-1
    80003a6a:	bfd1                	j	80003a3e <writei+0xe0>

0000000080003a6c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a6c:	1141                	addi	sp,sp,-16
    80003a6e:	e406                	sd	ra,8(sp)
    80003a70:	e022                	sd	s0,0(sp)
    80003a72:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a74:	4639                	li	a2,14
    80003a76:	af8fd0ef          	jal	80000d6e <strncmp>
}
    80003a7a:	60a2                	ld	ra,8(sp)
    80003a7c:	6402                	ld	s0,0(sp)
    80003a7e:	0141                	addi	sp,sp,16
    80003a80:	8082                	ret

0000000080003a82 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a82:	7139                	addi	sp,sp,-64
    80003a84:	fc06                	sd	ra,56(sp)
    80003a86:	f822                	sd	s0,48(sp)
    80003a88:	f426                	sd	s1,40(sp)
    80003a8a:	f04a                	sd	s2,32(sp)
    80003a8c:	ec4e                	sd	s3,24(sp)
    80003a8e:	e852                	sd	s4,16(sp)
    80003a90:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a92:	04451703          	lh	a4,68(a0)
    80003a96:	4785                	li	a5,1
    80003a98:	00f71a63          	bne	a4,a5,80003aac <dirlookup+0x2a>
    80003a9c:	892a                	mv	s2,a0
    80003a9e:	89ae                	mv	s3,a1
    80003aa0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aa2:	457c                	lw	a5,76(a0)
    80003aa4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003aa6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aa8:	e39d                	bnez	a5,80003ace <dirlookup+0x4c>
    80003aaa:	a095                	j	80003b0e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003aac:	00004517          	auipc	a0,0x4
    80003ab0:	9fc50513          	addi	a0,a0,-1540 # 800074a8 <etext+0x4a8>
    80003ab4:	d2dfc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003ab8:	00004517          	auipc	a0,0x4
    80003abc:	a0850513          	addi	a0,a0,-1528 # 800074c0 <etext+0x4c0>
    80003ac0:	d21fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ac4:	24c1                	addiw	s1,s1,16
    80003ac6:	04c92783          	lw	a5,76(s2)
    80003aca:	04f4f163          	bgeu	s1,a5,80003b0c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ace:	4741                	li	a4,16
    80003ad0:	86a6                	mv	a3,s1
    80003ad2:	fc040613          	addi	a2,s0,-64
    80003ad6:	4581                	li	a1,0
    80003ad8:	854a                	mv	a0,s2
    80003ada:	d89ff0ef          	jal	80003862 <readi>
    80003ade:	47c1                	li	a5,16
    80003ae0:	fcf51ce3          	bne	a0,a5,80003ab8 <dirlookup+0x36>
    if(de.inum == 0)
    80003ae4:	fc045783          	lhu	a5,-64(s0)
    80003ae8:	dff1                	beqz	a5,80003ac4 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003aea:	fc240593          	addi	a1,s0,-62
    80003aee:	854e                	mv	a0,s3
    80003af0:	f7dff0ef          	jal	80003a6c <namecmp>
    80003af4:	f961                	bnez	a0,80003ac4 <dirlookup+0x42>
      if(poff)
    80003af6:	000a0463          	beqz	s4,80003afe <dirlookup+0x7c>
        *poff = off;
    80003afa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003afe:	fc045583          	lhu	a1,-64(s0)
    80003b02:	00092503          	lw	a0,0(s2)
    80003b06:	f58ff0ef          	jal	8000325e <iget>
    80003b0a:	a011                	j	80003b0e <dirlookup+0x8c>
  return 0;
    80003b0c:	4501                	li	a0,0
}
    80003b0e:	70e2                	ld	ra,56(sp)
    80003b10:	7442                	ld	s0,48(sp)
    80003b12:	74a2                	ld	s1,40(sp)
    80003b14:	7902                	ld	s2,32(sp)
    80003b16:	69e2                	ld	s3,24(sp)
    80003b18:	6a42                	ld	s4,16(sp)
    80003b1a:	6121                	addi	sp,sp,64
    80003b1c:	8082                	ret

0000000080003b1e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b1e:	711d                	addi	sp,sp,-96
    80003b20:	ec86                	sd	ra,88(sp)
    80003b22:	e8a2                	sd	s0,80(sp)
    80003b24:	e4a6                	sd	s1,72(sp)
    80003b26:	e0ca                	sd	s2,64(sp)
    80003b28:	fc4e                	sd	s3,56(sp)
    80003b2a:	f852                	sd	s4,48(sp)
    80003b2c:	f456                	sd	s5,40(sp)
    80003b2e:	f05a                	sd	s6,32(sp)
    80003b30:	ec5e                	sd	s7,24(sp)
    80003b32:	e862                	sd	s8,16(sp)
    80003b34:	e466                	sd	s9,8(sp)
    80003b36:	1080                	addi	s0,sp,96
    80003b38:	84aa                	mv	s1,a0
    80003b3a:	8b2e                	mv	s6,a1
    80003b3c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b3e:	00054703          	lbu	a4,0(a0)
    80003b42:	02f00793          	li	a5,47
    80003b46:	00f70e63          	beq	a4,a5,80003b62 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b4a:	e07fd0ef          	jal	80001950 <myproc>
    80003b4e:	15053503          	ld	a0,336(a0)
    80003b52:	94bff0ef          	jal	8000349c <idup>
    80003b56:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b58:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003b5c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b5e:	4b85                	li	s7,1
    80003b60:	a871                	j	80003bfc <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003b62:	4585                	li	a1,1
    80003b64:	4505                	li	a0,1
    80003b66:	ef8ff0ef          	jal	8000325e <iget>
    80003b6a:	8a2a                	mv	s4,a0
    80003b6c:	b7f5                	j	80003b58 <namex+0x3a>
      iunlockput(ip);
    80003b6e:	8552                	mv	a0,s4
    80003b70:	b6dff0ef          	jal	800036dc <iunlockput>
      return 0;
    80003b74:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b76:	8552                	mv	a0,s4
    80003b78:	60e6                	ld	ra,88(sp)
    80003b7a:	6446                	ld	s0,80(sp)
    80003b7c:	64a6                	ld	s1,72(sp)
    80003b7e:	6906                	ld	s2,64(sp)
    80003b80:	79e2                	ld	s3,56(sp)
    80003b82:	7a42                	ld	s4,48(sp)
    80003b84:	7aa2                	ld	s5,40(sp)
    80003b86:	7b02                	ld	s6,32(sp)
    80003b88:	6be2                	ld	s7,24(sp)
    80003b8a:	6c42                	ld	s8,16(sp)
    80003b8c:	6ca2                	ld	s9,8(sp)
    80003b8e:	6125                	addi	sp,sp,96
    80003b90:	8082                	ret
      iunlock(ip);
    80003b92:	8552                	mv	a0,s4
    80003b94:	9edff0ef          	jal	80003580 <iunlock>
      return ip;
    80003b98:	bff9                	j	80003b76 <namex+0x58>
      iunlockput(ip);
    80003b9a:	8552                	mv	a0,s4
    80003b9c:	b41ff0ef          	jal	800036dc <iunlockput>
      return 0;
    80003ba0:	8a4e                	mv	s4,s3
    80003ba2:	bfd1                	j	80003b76 <namex+0x58>
  len = path - s;
    80003ba4:	40998633          	sub	a2,s3,s1
    80003ba8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003bac:	099c5063          	bge	s8,s9,80003c2c <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003bb0:	4639                	li	a2,14
    80003bb2:	85a6                	mv	a1,s1
    80003bb4:	8556                	mv	a0,s5
    80003bb6:	948fd0ef          	jal	80000cfe <memmove>
    80003bba:	84ce                	mv	s1,s3
  while(*path == '/')
    80003bbc:	0004c783          	lbu	a5,0(s1)
    80003bc0:	01279763          	bne	a5,s2,80003bce <namex+0xb0>
    path++;
    80003bc4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bc6:	0004c783          	lbu	a5,0(s1)
    80003bca:	ff278de3          	beq	a5,s2,80003bc4 <namex+0xa6>
    ilock(ip);
    80003bce:	8552                	mv	a0,s4
    80003bd0:	903ff0ef          	jal	800034d2 <ilock>
    if(ip->type != T_DIR){
    80003bd4:	044a1783          	lh	a5,68(s4)
    80003bd8:	f9779be3          	bne	a5,s7,80003b6e <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003bdc:	000b0563          	beqz	s6,80003be6 <namex+0xc8>
    80003be0:	0004c783          	lbu	a5,0(s1)
    80003be4:	d7dd                	beqz	a5,80003b92 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003be6:	4601                	li	a2,0
    80003be8:	85d6                	mv	a1,s5
    80003bea:	8552                	mv	a0,s4
    80003bec:	e97ff0ef          	jal	80003a82 <dirlookup>
    80003bf0:	89aa                	mv	s3,a0
    80003bf2:	d545                	beqz	a0,80003b9a <namex+0x7c>
    iunlockput(ip);
    80003bf4:	8552                	mv	a0,s4
    80003bf6:	ae7ff0ef          	jal	800036dc <iunlockput>
    ip = next;
    80003bfa:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003bfc:	0004c783          	lbu	a5,0(s1)
    80003c00:	01279763          	bne	a5,s2,80003c0e <namex+0xf0>
    path++;
    80003c04:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c06:	0004c783          	lbu	a5,0(s1)
    80003c0a:	ff278de3          	beq	a5,s2,80003c04 <namex+0xe6>
  if(*path == 0)
    80003c0e:	cb8d                	beqz	a5,80003c40 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003c10:	0004c783          	lbu	a5,0(s1)
    80003c14:	89a6                	mv	s3,s1
  len = path - s;
    80003c16:	4c81                	li	s9,0
    80003c18:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003c1a:	01278963          	beq	a5,s2,80003c2c <namex+0x10e>
    80003c1e:	d3d9                	beqz	a5,80003ba4 <namex+0x86>
    path++;
    80003c20:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003c22:	0009c783          	lbu	a5,0(s3)
    80003c26:	ff279ce3          	bne	a5,s2,80003c1e <namex+0x100>
    80003c2a:	bfad                	j	80003ba4 <namex+0x86>
    memmove(name, s, len);
    80003c2c:	2601                	sext.w	a2,a2
    80003c2e:	85a6                	mv	a1,s1
    80003c30:	8556                	mv	a0,s5
    80003c32:	8ccfd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003c36:	9cd6                	add	s9,s9,s5
    80003c38:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003c3c:	84ce                	mv	s1,s3
    80003c3e:	bfbd                	j	80003bbc <namex+0x9e>
  if(nameiparent){
    80003c40:	f20b0be3          	beqz	s6,80003b76 <namex+0x58>
    iput(ip);
    80003c44:	8552                	mv	a0,s4
    80003c46:	a0fff0ef          	jal	80003654 <iput>
    return 0;
    80003c4a:	4a01                	li	s4,0
    80003c4c:	b72d                	j	80003b76 <namex+0x58>

0000000080003c4e <dirlink>:
{
    80003c4e:	7139                	addi	sp,sp,-64
    80003c50:	fc06                	sd	ra,56(sp)
    80003c52:	f822                	sd	s0,48(sp)
    80003c54:	f04a                	sd	s2,32(sp)
    80003c56:	ec4e                	sd	s3,24(sp)
    80003c58:	e852                	sd	s4,16(sp)
    80003c5a:	0080                	addi	s0,sp,64
    80003c5c:	892a                	mv	s2,a0
    80003c5e:	8a2e                	mv	s4,a1
    80003c60:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c62:	4601                	li	a2,0
    80003c64:	e1fff0ef          	jal	80003a82 <dirlookup>
    80003c68:	e535                	bnez	a0,80003cd4 <dirlink+0x86>
    80003c6a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c6c:	04c92483          	lw	s1,76(s2)
    80003c70:	c48d                	beqz	s1,80003c9a <dirlink+0x4c>
    80003c72:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c74:	4741                	li	a4,16
    80003c76:	86a6                	mv	a3,s1
    80003c78:	fc040613          	addi	a2,s0,-64
    80003c7c:	4581                	li	a1,0
    80003c7e:	854a                	mv	a0,s2
    80003c80:	be3ff0ef          	jal	80003862 <readi>
    80003c84:	47c1                	li	a5,16
    80003c86:	04f51b63          	bne	a0,a5,80003cdc <dirlink+0x8e>
    if(de.inum == 0)
    80003c8a:	fc045783          	lhu	a5,-64(s0)
    80003c8e:	c791                	beqz	a5,80003c9a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c90:	24c1                	addiw	s1,s1,16
    80003c92:	04c92783          	lw	a5,76(s2)
    80003c96:	fcf4efe3          	bltu	s1,a5,80003c74 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003c9a:	4639                	li	a2,14
    80003c9c:	85d2                	mv	a1,s4
    80003c9e:	fc240513          	addi	a0,s0,-62
    80003ca2:	902fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003ca6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003caa:	4741                	li	a4,16
    80003cac:	86a6                	mv	a3,s1
    80003cae:	fc040613          	addi	a2,s0,-64
    80003cb2:	4581                	li	a1,0
    80003cb4:	854a                	mv	a0,s2
    80003cb6:	ca9ff0ef          	jal	8000395e <writei>
    80003cba:	1541                	addi	a0,a0,-16
    80003cbc:	00a03533          	snez	a0,a0
    80003cc0:	40a00533          	neg	a0,a0
    80003cc4:	74a2                	ld	s1,40(sp)
}
    80003cc6:	70e2                	ld	ra,56(sp)
    80003cc8:	7442                	ld	s0,48(sp)
    80003cca:	7902                	ld	s2,32(sp)
    80003ccc:	69e2                	ld	s3,24(sp)
    80003cce:	6a42                	ld	s4,16(sp)
    80003cd0:	6121                	addi	sp,sp,64
    80003cd2:	8082                	ret
    iput(ip);
    80003cd4:	981ff0ef          	jal	80003654 <iput>
    return -1;
    80003cd8:	557d                	li	a0,-1
    80003cda:	b7f5                	j	80003cc6 <dirlink+0x78>
      panic("dirlink read");
    80003cdc:	00003517          	auipc	a0,0x3
    80003ce0:	7f450513          	addi	a0,a0,2036 # 800074d0 <etext+0x4d0>
    80003ce4:	afdfc0ef          	jal	800007e0 <panic>

0000000080003ce8 <namei>:

struct inode*
namei(char *path)
{
    80003ce8:	1101                	addi	sp,sp,-32
    80003cea:	ec06                	sd	ra,24(sp)
    80003cec:	e822                	sd	s0,16(sp)
    80003cee:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cf0:	fe040613          	addi	a2,s0,-32
    80003cf4:	4581                	li	a1,0
    80003cf6:	e29ff0ef          	jal	80003b1e <namex>
}
    80003cfa:	60e2                	ld	ra,24(sp)
    80003cfc:	6442                	ld	s0,16(sp)
    80003cfe:	6105                	addi	sp,sp,32
    80003d00:	8082                	ret

0000000080003d02 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d02:	1141                	addi	sp,sp,-16
    80003d04:	e406                	sd	ra,8(sp)
    80003d06:	e022                	sd	s0,0(sp)
    80003d08:	0800                	addi	s0,sp,16
    80003d0a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d0c:	4585                	li	a1,1
    80003d0e:	e11ff0ef          	jal	80003b1e <namex>
}
    80003d12:	60a2                	ld	ra,8(sp)
    80003d14:	6402                	ld	s0,0(sp)
    80003d16:	0141                	addi	sp,sp,16
    80003d18:	8082                	ret

0000000080003d1a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d1a:	1101                	addi	sp,sp,-32
    80003d1c:	ec06                	sd	ra,24(sp)
    80003d1e:	e822                	sd	s0,16(sp)
    80003d20:	e426                	sd	s1,8(sp)
    80003d22:	e04a                	sd	s2,0(sp)
    80003d24:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d26:	0001f917          	auipc	s2,0x1f
    80003d2a:	aaa90913          	addi	s2,s2,-1366 # 800227d0 <log>
    80003d2e:	01892583          	lw	a1,24(s2)
    80003d32:	02492503          	lw	a0,36(s2)
    80003d36:	8d0ff0ef          	jal	80002e06 <bread>
    80003d3a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003d3c:	02892603          	lw	a2,40(s2)
    80003d40:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d42:	00c05f63          	blez	a2,80003d60 <write_head+0x46>
    80003d46:	0001f717          	auipc	a4,0x1f
    80003d4a:	ab670713          	addi	a4,a4,-1354 # 800227fc <log+0x2c>
    80003d4e:	87aa                	mv	a5,a0
    80003d50:	060a                	slli	a2,a2,0x2
    80003d52:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d54:	4314                	lw	a3,0(a4)
    80003d56:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d58:	0711                	addi	a4,a4,4
    80003d5a:	0791                	addi	a5,a5,4
    80003d5c:	fec79ce3          	bne	a5,a2,80003d54 <write_head+0x3a>
  }
  bwrite(buf);
    80003d60:	8526                	mv	a0,s1
    80003d62:	97aff0ef          	jal	80002edc <bwrite>
  brelse(buf);
    80003d66:	8526                	mv	a0,s1
    80003d68:	9a6ff0ef          	jal	80002f0e <brelse>
}
    80003d6c:	60e2                	ld	ra,24(sp)
    80003d6e:	6442                	ld	s0,16(sp)
    80003d70:	64a2                	ld	s1,8(sp)
    80003d72:	6902                	ld	s2,0(sp)
    80003d74:	6105                	addi	sp,sp,32
    80003d76:	8082                	ret

0000000080003d78 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d78:	0001f797          	auipc	a5,0x1f
    80003d7c:	a807a783          	lw	a5,-1408(a5) # 800227f8 <log+0x28>
    80003d80:	0af05e63          	blez	a5,80003e3c <install_trans+0xc4>
{
    80003d84:	715d                	addi	sp,sp,-80
    80003d86:	e486                	sd	ra,72(sp)
    80003d88:	e0a2                	sd	s0,64(sp)
    80003d8a:	fc26                	sd	s1,56(sp)
    80003d8c:	f84a                	sd	s2,48(sp)
    80003d8e:	f44e                	sd	s3,40(sp)
    80003d90:	f052                	sd	s4,32(sp)
    80003d92:	ec56                	sd	s5,24(sp)
    80003d94:	e85a                	sd	s6,16(sp)
    80003d96:	e45e                	sd	s7,8(sp)
    80003d98:	0880                	addi	s0,sp,80
    80003d9a:	8b2a                	mv	s6,a0
    80003d9c:	0001fa97          	auipc	s5,0x1f
    80003da0:	a60a8a93          	addi	s5,s5,-1440 # 800227fc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003da4:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003da6:	00003b97          	auipc	s7,0x3
    80003daa:	73ab8b93          	addi	s7,s7,1850 # 800074e0 <etext+0x4e0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003dae:	0001fa17          	auipc	s4,0x1f
    80003db2:	a22a0a13          	addi	s4,s4,-1502 # 800227d0 <log>
    80003db6:	a025                	j	80003dde <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003db8:	000aa603          	lw	a2,0(s5)
    80003dbc:	85ce                	mv	a1,s3
    80003dbe:	855e                	mv	a0,s7
    80003dc0:	f3afc0ef          	jal	800004fa <printf>
    80003dc4:	a839                	j	80003de2 <install_trans+0x6a>
    brelse(lbuf);
    80003dc6:	854a                	mv	a0,s2
    80003dc8:	946ff0ef          	jal	80002f0e <brelse>
    brelse(dbuf);
    80003dcc:	8526                	mv	a0,s1
    80003dce:	940ff0ef          	jal	80002f0e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dd2:	2985                	addiw	s3,s3,1
    80003dd4:	0a91                	addi	s5,s5,4
    80003dd6:	028a2783          	lw	a5,40(s4)
    80003dda:	04f9d663          	bge	s3,a5,80003e26 <install_trans+0xae>
    if(recovering) {
    80003dde:	fc0b1de3          	bnez	s6,80003db8 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003de2:	018a2583          	lw	a1,24(s4)
    80003de6:	013585bb          	addw	a1,a1,s3
    80003dea:	2585                	addiw	a1,a1,1
    80003dec:	024a2503          	lw	a0,36(s4)
    80003df0:	816ff0ef          	jal	80002e06 <bread>
    80003df4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003df6:	000aa583          	lw	a1,0(s5)
    80003dfa:	024a2503          	lw	a0,36(s4)
    80003dfe:	808ff0ef          	jal	80002e06 <bread>
    80003e02:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e04:	40000613          	li	a2,1024
    80003e08:	05890593          	addi	a1,s2,88
    80003e0c:	05850513          	addi	a0,a0,88
    80003e10:	eeffc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e14:	8526                	mv	a0,s1
    80003e16:	8c6ff0ef          	jal	80002edc <bwrite>
    if(recovering == 0)
    80003e1a:	fa0b16e3          	bnez	s6,80003dc6 <install_trans+0x4e>
      bunpin(dbuf);
    80003e1e:	8526                	mv	a0,s1
    80003e20:	9aaff0ef          	jal	80002fca <bunpin>
    80003e24:	b74d                	j	80003dc6 <install_trans+0x4e>
}
    80003e26:	60a6                	ld	ra,72(sp)
    80003e28:	6406                	ld	s0,64(sp)
    80003e2a:	74e2                	ld	s1,56(sp)
    80003e2c:	7942                	ld	s2,48(sp)
    80003e2e:	79a2                	ld	s3,40(sp)
    80003e30:	7a02                	ld	s4,32(sp)
    80003e32:	6ae2                	ld	s5,24(sp)
    80003e34:	6b42                	ld	s6,16(sp)
    80003e36:	6ba2                	ld	s7,8(sp)
    80003e38:	6161                	addi	sp,sp,80
    80003e3a:	8082                	ret
    80003e3c:	8082                	ret

0000000080003e3e <initlog>:
{
    80003e3e:	7179                	addi	sp,sp,-48
    80003e40:	f406                	sd	ra,40(sp)
    80003e42:	f022                	sd	s0,32(sp)
    80003e44:	ec26                	sd	s1,24(sp)
    80003e46:	e84a                	sd	s2,16(sp)
    80003e48:	e44e                	sd	s3,8(sp)
    80003e4a:	1800                	addi	s0,sp,48
    80003e4c:	892a                	mv	s2,a0
    80003e4e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e50:	0001f497          	auipc	s1,0x1f
    80003e54:	98048493          	addi	s1,s1,-1664 # 800227d0 <log>
    80003e58:	00003597          	auipc	a1,0x3
    80003e5c:	6a858593          	addi	a1,a1,1704 # 80007500 <etext+0x500>
    80003e60:	8526                	mv	a0,s1
    80003e62:	cedfc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003e66:	0149a583          	lw	a1,20(s3)
    80003e6a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003e6c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e70:	854a                	mv	a0,s2
    80003e72:	f95fe0ef          	jal	80002e06 <bread>
  log.lh.n = lh->n;
    80003e76:	4d30                	lw	a2,88(a0)
    80003e78:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e7a:	00c05f63          	blez	a2,80003e98 <initlog+0x5a>
    80003e7e:	87aa                	mv	a5,a0
    80003e80:	0001f717          	auipc	a4,0x1f
    80003e84:	97c70713          	addi	a4,a4,-1668 # 800227fc <log+0x2c>
    80003e88:	060a                	slli	a2,a2,0x2
    80003e8a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e8c:	4ff4                	lw	a3,92(a5)
    80003e8e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e90:	0791                	addi	a5,a5,4
    80003e92:	0711                	addi	a4,a4,4
    80003e94:	fec79ce3          	bne	a5,a2,80003e8c <initlog+0x4e>
  brelse(buf);
    80003e98:	876ff0ef          	jal	80002f0e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e9c:	4505                	li	a0,1
    80003e9e:	edbff0ef          	jal	80003d78 <install_trans>
  log.lh.n = 0;
    80003ea2:	0001f797          	auipc	a5,0x1f
    80003ea6:	9407ab23          	sw	zero,-1706(a5) # 800227f8 <log+0x28>
  write_head(); // clear the log
    80003eaa:	e71ff0ef          	jal	80003d1a <write_head>
}
    80003eae:	70a2                	ld	ra,40(sp)
    80003eb0:	7402                	ld	s0,32(sp)
    80003eb2:	64e2                	ld	s1,24(sp)
    80003eb4:	6942                	ld	s2,16(sp)
    80003eb6:	69a2                	ld	s3,8(sp)
    80003eb8:	6145                	addi	sp,sp,48
    80003eba:	8082                	ret

0000000080003ebc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ebc:	1101                	addi	sp,sp,-32
    80003ebe:	ec06                	sd	ra,24(sp)
    80003ec0:	e822                	sd	s0,16(sp)
    80003ec2:	e426                	sd	s1,8(sp)
    80003ec4:	e04a                	sd	s2,0(sp)
    80003ec6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ec8:	0001f517          	auipc	a0,0x1f
    80003ecc:	90850513          	addi	a0,a0,-1784 # 800227d0 <log>
    80003ed0:	cfffc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003ed4:	0001f497          	auipc	s1,0x1f
    80003ed8:	8fc48493          	addi	s1,s1,-1796 # 800227d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003edc:	4979                	li	s2,30
    80003ede:	a029                	j	80003ee8 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ee0:	85a6                	mv	a1,s1
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	a02fe0ef          	jal	800020e6 <sleep>
    if(log.committing){
    80003ee8:	509c                	lw	a5,32(s1)
    80003eea:	fbfd                	bnez	a5,80003ee0 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003eec:	4cd8                	lw	a4,28(s1)
    80003eee:	2705                	addiw	a4,a4,1
    80003ef0:	0027179b          	slliw	a5,a4,0x2
    80003ef4:	9fb9                	addw	a5,a5,a4
    80003ef6:	0017979b          	slliw	a5,a5,0x1
    80003efa:	5494                	lw	a3,40(s1)
    80003efc:	9fb5                	addw	a5,a5,a3
    80003efe:	00f95763          	bge	s2,a5,80003f0c <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f02:	85a6                	mv	a1,s1
    80003f04:	8526                	mv	a0,s1
    80003f06:	9e0fe0ef          	jal	800020e6 <sleep>
    80003f0a:	bff9                	j	80003ee8 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003f0c:	0001f517          	auipc	a0,0x1f
    80003f10:	8c450513          	addi	a0,a0,-1852 # 800227d0 <log>
    80003f14:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003f16:	d51fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003f1a:	60e2                	ld	ra,24(sp)
    80003f1c:	6442                	ld	s0,16(sp)
    80003f1e:	64a2                	ld	s1,8(sp)
    80003f20:	6902                	ld	s2,0(sp)
    80003f22:	6105                	addi	sp,sp,32
    80003f24:	8082                	ret

0000000080003f26 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f26:	7139                	addi	sp,sp,-64
    80003f28:	fc06                	sd	ra,56(sp)
    80003f2a:	f822                	sd	s0,48(sp)
    80003f2c:	f426                	sd	s1,40(sp)
    80003f2e:	f04a                	sd	s2,32(sp)
    80003f30:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f32:	0001f497          	auipc	s1,0x1f
    80003f36:	89e48493          	addi	s1,s1,-1890 # 800227d0 <log>
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	c93fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003f40:	4cdc                	lw	a5,28(s1)
    80003f42:	37fd                	addiw	a5,a5,-1
    80003f44:	0007891b          	sext.w	s2,a5
    80003f48:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003f4a:	509c                	lw	a5,32(s1)
    80003f4c:	ef9d                	bnez	a5,80003f8a <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f4e:	04091763          	bnez	s2,80003f9c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003f52:	0001f497          	auipc	s1,0x1f
    80003f56:	87e48493          	addi	s1,s1,-1922 # 800227d0 <log>
    80003f5a:	4785                	li	a5,1
    80003f5c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f5e:	8526                	mv	a0,s1
    80003f60:	d07fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f64:	549c                	lw	a5,40(s1)
    80003f66:	04f04b63          	bgtz	a5,80003fbc <end_op+0x96>
    acquire(&log.lock);
    80003f6a:	0001f497          	auipc	s1,0x1f
    80003f6e:	86648493          	addi	s1,s1,-1946 # 800227d0 <log>
    80003f72:	8526                	mv	a0,s1
    80003f74:	c5bfc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003f78:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	9b4fe0ef          	jal	80002132 <wakeup>
    release(&log.lock);
    80003f82:	8526                	mv	a0,s1
    80003f84:	ce3fc0ef          	jal	80000c66 <release>
}
    80003f88:	a025                	j	80003fb0 <end_op+0x8a>
    80003f8a:	ec4e                	sd	s3,24(sp)
    80003f8c:	e852                	sd	s4,16(sp)
    80003f8e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f90:	00003517          	auipc	a0,0x3
    80003f94:	57850513          	addi	a0,a0,1400 # 80007508 <etext+0x508>
    80003f98:	849fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003f9c:	0001f497          	auipc	s1,0x1f
    80003fa0:	83448493          	addi	s1,s1,-1996 # 800227d0 <log>
    80003fa4:	8526                	mv	a0,s1
    80003fa6:	98cfe0ef          	jal	80002132 <wakeup>
  release(&log.lock);
    80003faa:	8526                	mv	a0,s1
    80003fac:	cbbfc0ef          	jal	80000c66 <release>
}
    80003fb0:	70e2                	ld	ra,56(sp)
    80003fb2:	7442                	ld	s0,48(sp)
    80003fb4:	74a2                	ld	s1,40(sp)
    80003fb6:	7902                	ld	s2,32(sp)
    80003fb8:	6121                	addi	sp,sp,64
    80003fba:	8082                	ret
    80003fbc:	ec4e                	sd	s3,24(sp)
    80003fbe:	e852                	sd	s4,16(sp)
    80003fc0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fc2:	0001fa97          	auipc	s5,0x1f
    80003fc6:	83aa8a93          	addi	s5,s5,-1990 # 800227fc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003fca:	0001fa17          	auipc	s4,0x1f
    80003fce:	806a0a13          	addi	s4,s4,-2042 # 800227d0 <log>
    80003fd2:	018a2583          	lw	a1,24(s4)
    80003fd6:	012585bb          	addw	a1,a1,s2
    80003fda:	2585                	addiw	a1,a1,1
    80003fdc:	024a2503          	lw	a0,36(s4)
    80003fe0:	e27fe0ef          	jal	80002e06 <bread>
    80003fe4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fe6:	000aa583          	lw	a1,0(s5)
    80003fea:	024a2503          	lw	a0,36(s4)
    80003fee:	e19fe0ef          	jal	80002e06 <bread>
    80003ff2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ff4:	40000613          	li	a2,1024
    80003ff8:	05850593          	addi	a1,a0,88
    80003ffc:	05848513          	addi	a0,s1,88
    80004000:	cfffc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80004004:	8526                	mv	a0,s1
    80004006:	ed7fe0ef          	jal	80002edc <bwrite>
    brelse(from);
    8000400a:	854e                	mv	a0,s3
    8000400c:	f03fe0ef          	jal	80002f0e <brelse>
    brelse(to);
    80004010:	8526                	mv	a0,s1
    80004012:	efdfe0ef          	jal	80002f0e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004016:	2905                	addiw	s2,s2,1
    80004018:	0a91                	addi	s5,s5,4
    8000401a:	028a2783          	lw	a5,40(s4)
    8000401e:	faf94ae3          	blt	s2,a5,80003fd2 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004022:	cf9ff0ef          	jal	80003d1a <write_head>
    install_trans(0); // Now install writes to home locations
    80004026:	4501                	li	a0,0
    80004028:	d51ff0ef          	jal	80003d78 <install_trans>
    log.lh.n = 0;
    8000402c:	0001e797          	auipc	a5,0x1e
    80004030:	7c07a623          	sw	zero,1996(a5) # 800227f8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004034:	ce7ff0ef          	jal	80003d1a <write_head>
    80004038:	69e2                	ld	s3,24(sp)
    8000403a:	6a42                	ld	s4,16(sp)
    8000403c:	6aa2                	ld	s5,8(sp)
    8000403e:	b735                	j	80003f6a <end_op+0x44>

0000000080004040 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004040:	1101                	addi	sp,sp,-32
    80004042:	ec06                	sd	ra,24(sp)
    80004044:	e822                	sd	s0,16(sp)
    80004046:	e426                	sd	s1,8(sp)
    80004048:	e04a                	sd	s2,0(sp)
    8000404a:	1000                	addi	s0,sp,32
    8000404c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000404e:	0001e917          	auipc	s2,0x1e
    80004052:	78290913          	addi	s2,s2,1922 # 800227d0 <log>
    80004056:	854a                	mv	a0,s2
    80004058:	b77fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000405c:	02892603          	lw	a2,40(s2)
    80004060:	47f5                	li	a5,29
    80004062:	04c7cc63          	blt	a5,a2,800040ba <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004066:	0001e797          	auipc	a5,0x1e
    8000406a:	7867a783          	lw	a5,1926(a5) # 800227ec <log+0x1c>
    8000406e:	04f05c63          	blez	a5,800040c6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004072:	4781                	li	a5,0
    80004074:	04c05f63          	blez	a2,800040d2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004078:	44cc                	lw	a1,12(s1)
    8000407a:	0001e717          	auipc	a4,0x1e
    8000407e:	78270713          	addi	a4,a4,1922 # 800227fc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004082:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004084:	4314                	lw	a3,0(a4)
    80004086:	04b68663          	beq	a3,a1,800040d2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000408a:	2785                	addiw	a5,a5,1
    8000408c:	0711                	addi	a4,a4,4
    8000408e:	fef61be3          	bne	a2,a5,80004084 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004092:	0621                	addi	a2,a2,8
    80004094:	060a                	slli	a2,a2,0x2
    80004096:	0001e797          	auipc	a5,0x1e
    8000409a:	73a78793          	addi	a5,a5,1850 # 800227d0 <log>
    8000409e:	97b2                	add	a5,a5,a2
    800040a0:	44d8                	lw	a4,12(s1)
    800040a2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800040a4:	8526                	mv	a0,s1
    800040a6:	ef1fe0ef          	jal	80002f96 <bpin>
    log.lh.n++;
    800040aa:	0001e717          	auipc	a4,0x1e
    800040ae:	72670713          	addi	a4,a4,1830 # 800227d0 <log>
    800040b2:	571c                	lw	a5,40(a4)
    800040b4:	2785                	addiw	a5,a5,1
    800040b6:	d71c                	sw	a5,40(a4)
    800040b8:	a80d                	j	800040ea <log_write+0xaa>
    panic("too big a transaction");
    800040ba:	00003517          	auipc	a0,0x3
    800040be:	45e50513          	addi	a0,a0,1118 # 80007518 <etext+0x518>
    800040c2:	f1efc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    800040c6:	00003517          	auipc	a0,0x3
    800040ca:	46a50513          	addi	a0,a0,1130 # 80007530 <etext+0x530>
    800040ce:	f12fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    800040d2:	00878693          	addi	a3,a5,8
    800040d6:	068a                	slli	a3,a3,0x2
    800040d8:	0001e717          	auipc	a4,0x1e
    800040dc:	6f870713          	addi	a4,a4,1784 # 800227d0 <log>
    800040e0:	9736                	add	a4,a4,a3
    800040e2:	44d4                	lw	a3,12(s1)
    800040e4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800040e6:	faf60fe3          	beq	a2,a5,800040a4 <log_write+0x64>
  }
  release(&log.lock);
    800040ea:	0001e517          	auipc	a0,0x1e
    800040ee:	6e650513          	addi	a0,a0,1766 # 800227d0 <log>
    800040f2:	b75fc0ef          	jal	80000c66 <release>
}
    800040f6:	60e2                	ld	ra,24(sp)
    800040f8:	6442                	ld	s0,16(sp)
    800040fa:	64a2                	ld	s1,8(sp)
    800040fc:	6902                	ld	s2,0(sp)
    800040fe:	6105                	addi	sp,sp,32
    80004100:	8082                	ret

0000000080004102 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004102:	1101                	addi	sp,sp,-32
    80004104:	ec06                	sd	ra,24(sp)
    80004106:	e822                	sd	s0,16(sp)
    80004108:	e426                	sd	s1,8(sp)
    8000410a:	e04a                	sd	s2,0(sp)
    8000410c:	1000                	addi	s0,sp,32
    8000410e:	84aa                	mv	s1,a0
    80004110:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004112:	00003597          	auipc	a1,0x3
    80004116:	43e58593          	addi	a1,a1,1086 # 80007550 <etext+0x550>
    8000411a:	0521                	addi	a0,a0,8
    8000411c:	a33fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004120:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004124:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004128:	0204a423          	sw	zero,40(s1)
}
    8000412c:	60e2                	ld	ra,24(sp)
    8000412e:	6442                	ld	s0,16(sp)
    80004130:	64a2                	ld	s1,8(sp)
    80004132:	6902                	ld	s2,0(sp)
    80004134:	6105                	addi	sp,sp,32
    80004136:	8082                	ret

0000000080004138 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004138:	1101                	addi	sp,sp,-32
    8000413a:	ec06                	sd	ra,24(sp)
    8000413c:	e822                	sd	s0,16(sp)
    8000413e:	e426                	sd	s1,8(sp)
    80004140:	e04a                	sd	s2,0(sp)
    80004142:	1000                	addi	s0,sp,32
    80004144:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004146:	00850913          	addi	s2,a0,8
    8000414a:	854a                	mv	a0,s2
    8000414c:	a83fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80004150:	409c                	lw	a5,0(s1)
    80004152:	c799                	beqz	a5,80004160 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004154:	85ca                	mv	a1,s2
    80004156:	8526                	mv	a0,s1
    80004158:	f8ffd0ef          	jal	800020e6 <sleep>
  while (lk->locked) {
    8000415c:	409c                	lw	a5,0(s1)
    8000415e:	fbfd                	bnez	a5,80004154 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004160:	4785                	li	a5,1
    80004162:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004164:	fecfd0ef          	jal	80001950 <myproc>
    80004168:	591c                	lw	a5,48(a0)
    8000416a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000416c:	854a                	mv	a0,s2
    8000416e:	af9fc0ef          	jal	80000c66 <release>
}
    80004172:	60e2                	ld	ra,24(sp)
    80004174:	6442                	ld	s0,16(sp)
    80004176:	64a2                	ld	s1,8(sp)
    80004178:	6902                	ld	s2,0(sp)
    8000417a:	6105                	addi	sp,sp,32
    8000417c:	8082                	ret

000000008000417e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000417e:	1101                	addi	sp,sp,-32
    80004180:	ec06                	sd	ra,24(sp)
    80004182:	e822                	sd	s0,16(sp)
    80004184:	e426                	sd	s1,8(sp)
    80004186:	e04a                	sd	s2,0(sp)
    80004188:	1000                	addi	s0,sp,32
    8000418a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000418c:	00850913          	addi	s2,a0,8
    80004190:	854a                	mv	a0,s2
    80004192:	a3dfc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80004196:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000419a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000419e:	8526                	mv	a0,s1
    800041a0:	f93fd0ef          	jal	80002132 <wakeup>
  release(&lk->lk);
    800041a4:	854a                	mv	a0,s2
    800041a6:	ac1fc0ef          	jal	80000c66 <release>
}
    800041aa:	60e2                	ld	ra,24(sp)
    800041ac:	6442                	ld	s0,16(sp)
    800041ae:	64a2                	ld	s1,8(sp)
    800041b0:	6902                	ld	s2,0(sp)
    800041b2:	6105                	addi	sp,sp,32
    800041b4:	8082                	ret

00000000800041b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800041b6:	7179                	addi	sp,sp,-48
    800041b8:	f406                	sd	ra,40(sp)
    800041ba:	f022                	sd	s0,32(sp)
    800041bc:	ec26                	sd	s1,24(sp)
    800041be:	e84a                	sd	s2,16(sp)
    800041c0:	1800                	addi	s0,sp,48
    800041c2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800041c4:	00850913          	addi	s2,a0,8
    800041c8:	854a                	mv	a0,s2
    800041ca:	a05fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041ce:	409c                	lw	a5,0(s1)
    800041d0:	ef81                	bnez	a5,800041e8 <holdingsleep+0x32>
    800041d2:	4481                	li	s1,0
  release(&lk->lk);
    800041d4:	854a                	mv	a0,s2
    800041d6:	a91fc0ef          	jal	80000c66 <release>
  return r;
}
    800041da:	8526                	mv	a0,s1
    800041dc:	70a2                	ld	ra,40(sp)
    800041de:	7402                	ld	s0,32(sp)
    800041e0:	64e2                	ld	s1,24(sp)
    800041e2:	6942                	ld	s2,16(sp)
    800041e4:	6145                	addi	sp,sp,48
    800041e6:	8082                	ret
    800041e8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041ea:	0284a983          	lw	s3,40(s1)
    800041ee:	f62fd0ef          	jal	80001950 <myproc>
    800041f2:	5904                	lw	s1,48(a0)
    800041f4:	413484b3          	sub	s1,s1,s3
    800041f8:	0014b493          	seqz	s1,s1
    800041fc:	69a2                	ld	s3,8(sp)
    800041fe:	bfd9                	j	800041d4 <holdingsleep+0x1e>

0000000080004200 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004200:	1141                	addi	sp,sp,-16
    80004202:	e406                	sd	ra,8(sp)
    80004204:	e022                	sd	s0,0(sp)
    80004206:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004208:	00003597          	auipc	a1,0x3
    8000420c:	35858593          	addi	a1,a1,856 # 80007560 <etext+0x560>
    80004210:	0001e517          	auipc	a0,0x1e
    80004214:	70850513          	addi	a0,a0,1800 # 80022918 <ftable>
    80004218:	937fc0ef          	jal	80000b4e <initlock>
}
    8000421c:	60a2                	ld	ra,8(sp)
    8000421e:	6402                	ld	s0,0(sp)
    80004220:	0141                	addi	sp,sp,16
    80004222:	8082                	ret

0000000080004224 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004224:	1101                	addi	sp,sp,-32
    80004226:	ec06                	sd	ra,24(sp)
    80004228:	e822                	sd	s0,16(sp)
    8000422a:	e426                	sd	s1,8(sp)
    8000422c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000422e:	0001e517          	auipc	a0,0x1e
    80004232:	6ea50513          	addi	a0,a0,1770 # 80022918 <ftable>
    80004236:	999fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000423a:	0001e497          	auipc	s1,0x1e
    8000423e:	6f648493          	addi	s1,s1,1782 # 80022930 <ftable+0x18>
    80004242:	0001f717          	auipc	a4,0x1f
    80004246:	68e70713          	addi	a4,a4,1678 # 800238d0 <disk>
    if(f->ref == 0){
    8000424a:	40dc                	lw	a5,4(s1)
    8000424c:	cf89                	beqz	a5,80004266 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000424e:	02848493          	addi	s1,s1,40
    80004252:	fee49ce3          	bne	s1,a4,8000424a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004256:	0001e517          	auipc	a0,0x1e
    8000425a:	6c250513          	addi	a0,a0,1730 # 80022918 <ftable>
    8000425e:	a09fc0ef          	jal	80000c66 <release>
  return 0;
    80004262:	4481                	li	s1,0
    80004264:	a809                	j	80004276 <filealloc+0x52>
      f->ref = 1;
    80004266:	4785                	li	a5,1
    80004268:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000426a:	0001e517          	auipc	a0,0x1e
    8000426e:	6ae50513          	addi	a0,a0,1710 # 80022918 <ftable>
    80004272:	9f5fc0ef          	jal	80000c66 <release>
}
    80004276:	8526                	mv	a0,s1
    80004278:	60e2                	ld	ra,24(sp)
    8000427a:	6442                	ld	s0,16(sp)
    8000427c:	64a2                	ld	s1,8(sp)
    8000427e:	6105                	addi	sp,sp,32
    80004280:	8082                	ret

0000000080004282 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004282:	1101                	addi	sp,sp,-32
    80004284:	ec06                	sd	ra,24(sp)
    80004286:	e822                	sd	s0,16(sp)
    80004288:	e426                	sd	s1,8(sp)
    8000428a:	1000                	addi	s0,sp,32
    8000428c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000428e:	0001e517          	auipc	a0,0x1e
    80004292:	68a50513          	addi	a0,a0,1674 # 80022918 <ftable>
    80004296:	939fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    8000429a:	40dc                	lw	a5,4(s1)
    8000429c:	02f05063          	blez	a5,800042bc <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800042a0:	2785                	addiw	a5,a5,1
    800042a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800042a4:	0001e517          	auipc	a0,0x1e
    800042a8:	67450513          	addi	a0,a0,1652 # 80022918 <ftable>
    800042ac:	9bbfc0ef          	jal	80000c66 <release>
  return f;
}
    800042b0:	8526                	mv	a0,s1
    800042b2:	60e2                	ld	ra,24(sp)
    800042b4:	6442                	ld	s0,16(sp)
    800042b6:	64a2                	ld	s1,8(sp)
    800042b8:	6105                	addi	sp,sp,32
    800042ba:	8082                	ret
    panic("filedup");
    800042bc:	00003517          	auipc	a0,0x3
    800042c0:	2ac50513          	addi	a0,a0,684 # 80007568 <etext+0x568>
    800042c4:	d1cfc0ef          	jal	800007e0 <panic>

00000000800042c8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042c8:	7139                	addi	sp,sp,-64
    800042ca:	fc06                	sd	ra,56(sp)
    800042cc:	f822                	sd	s0,48(sp)
    800042ce:	f426                	sd	s1,40(sp)
    800042d0:	0080                	addi	s0,sp,64
    800042d2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042d4:	0001e517          	auipc	a0,0x1e
    800042d8:	64450513          	addi	a0,a0,1604 # 80022918 <ftable>
    800042dc:	8f3fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800042e0:	40dc                	lw	a5,4(s1)
    800042e2:	04f05a63          	blez	a5,80004336 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800042e6:	37fd                	addiw	a5,a5,-1
    800042e8:	0007871b          	sext.w	a4,a5
    800042ec:	c0dc                	sw	a5,4(s1)
    800042ee:	04e04e63          	bgtz	a4,8000434a <fileclose+0x82>
    800042f2:	f04a                	sd	s2,32(sp)
    800042f4:	ec4e                	sd	s3,24(sp)
    800042f6:	e852                	sd	s4,16(sp)
    800042f8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042fa:	0004a903          	lw	s2,0(s1)
    800042fe:	0094ca83          	lbu	s5,9(s1)
    80004302:	0104ba03          	ld	s4,16(s1)
    80004306:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000430a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000430e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004312:	0001e517          	auipc	a0,0x1e
    80004316:	60650513          	addi	a0,a0,1542 # 80022918 <ftable>
    8000431a:	94dfc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000431e:	4785                	li	a5,1
    80004320:	04f90063          	beq	s2,a5,80004360 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004324:	3979                	addiw	s2,s2,-2
    80004326:	4785                	li	a5,1
    80004328:	0527f563          	bgeu	a5,s2,80004372 <fileclose+0xaa>
    8000432c:	7902                	ld	s2,32(sp)
    8000432e:	69e2                	ld	s3,24(sp)
    80004330:	6a42                	ld	s4,16(sp)
    80004332:	6aa2                	ld	s5,8(sp)
    80004334:	a00d                	j	80004356 <fileclose+0x8e>
    80004336:	f04a                	sd	s2,32(sp)
    80004338:	ec4e                	sd	s3,24(sp)
    8000433a:	e852                	sd	s4,16(sp)
    8000433c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000433e:	00003517          	auipc	a0,0x3
    80004342:	23250513          	addi	a0,a0,562 # 80007570 <etext+0x570>
    80004346:	c9afc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    8000434a:	0001e517          	auipc	a0,0x1e
    8000434e:	5ce50513          	addi	a0,a0,1486 # 80022918 <ftable>
    80004352:	915fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004356:	70e2                	ld	ra,56(sp)
    80004358:	7442                	ld	s0,48(sp)
    8000435a:	74a2                	ld	s1,40(sp)
    8000435c:	6121                	addi	sp,sp,64
    8000435e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004360:	85d6                	mv	a1,s5
    80004362:	8552                	mv	a0,s4
    80004364:	336000ef          	jal	8000469a <pipeclose>
    80004368:	7902                	ld	s2,32(sp)
    8000436a:	69e2                	ld	s3,24(sp)
    8000436c:	6a42                	ld	s4,16(sp)
    8000436e:	6aa2                	ld	s5,8(sp)
    80004370:	b7dd                	j	80004356 <fileclose+0x8e>
    begin_op();
    80004372:	b4bff0ef          	jal	80003ebc <begin_op>
    iput(ff.ip);
    80004376:	854e                	mv	a0,s3
    80004378:	adcff0ef          	jal	80003654 <iput>
    end_op();
    8000437c:	babff0ef          	jal	80003f26 <end_op>
    80004380:	7902                	ld	s2,32(sp)
    80004382:	69e2                	ld	s3,24(sp)
    80004384:	6a42                	ld	s4,16(sp)
    80004386:	6aa2                	ld	s5,8(sp)
    80004388:	b7f9                	j	80004356 <fileclose+0x8e>

000000008000438a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000438a:	715d                	addi	sp,sp,-80
    8000438c:	e486                	sd	ra,72(sp)
    8000438e:	e0a2                	sd	s0,64(sp)
    80004390:	fc26                	sd	s1,56(sp)
    80004392:	f44e                	sd	s3,40(sp)
    80004394:	0880                	addi	s0,sp,80
    80004396:	84aa                	mv	s1,a0
    80004398:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000439a:	db6fd0ef          	jal	80001950 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000439e:	409c                	lw	a5,0(s1)
    800043a0:	37f9                	addiw	a5,a5,-2
    800043a2:	4705                	li	a4,1
    800043a4:	04f76063          	bltu	a4,a5,800043e4 <filestat+0x5a>
    800043a8:	f84a                	sd	s2,48(sp)
    800043aa:	892a                	mv	s2,a0
    ilock(f->ip);
    800043ac:	6c88                	ld	a0,24(s1)
    800043ae:	924ff0ef          	jal	800034d2 <ilock>
    stati(f->ip, &st);
    800043b2:	fb840593          	addi	a1,s0,-72
    800043b6:	6c88                	ld	a0,24(s1)
    800043b8:	c80ff0ef          	jal	80003838 <stati>
    iunlock(f->ip);
    800043bc:	6c88                	ld	a0,24(s1)
    800043be:	9c2ff0ef          	jal	80003580 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800043c2:	46e1                	li	a3,24
    800043c4:	fb840613          	addi	a2,s0,-72
    800043c8:	85ce                	mv	a1,s3
    800043ca:	05093503          	ld	a0,80(s2)
    800043ce:	a14fd0ef          	jal	800015e2 <copyout>
    800043d2:	41f5551b          	sraiw	a0,a0,0x1f
    800043d6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043d8:	60a6                	ld	ra,72(sp)
    800043da:	6406                	ld	s0,64(sp)
    800043dc:	74e2                	ld	s1,56(sp)
    800043de:	79a2                	ld	s3,40(sp)
    800043e0:	6161                	addi	sp,sp,80
    800043e2:	8082                	ret
  return -1;
    800043e4:	557d                	li	a0,-1
    800043e6:	bfcd                	j	800043d8 <filestat+0x4e>

00000000800043e8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043e8:	7179                	addi	sp,sp,-48
    800043ea:	f406                	sd	ra,40(sp)
    800043ec:	f022                	sd	s0,32(sp)
    800043ee:	e84a                	sd	s2,16(sp)
    800043f0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800043f2:	00854783          	lbu	a5,8(a0)
    800043f6:	cfd1                	beqz	a5,80004492 <fileread+0xaa>
    800043f8:	ec26                	sd	s1,24(sp)
    800043fa:	e44e                	sd	s3,8(sp)
    800043fc:	84aa                	mv	s1,a0
    800043fe:	89ae                	mv	s3,a1
    80004400:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004402:	411c                	lw	a5,0(a0)
    80004404:	4705                	li	a4,1
    80004406:	04e78363          	beq	a5,a4,8000444c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000440a:	470d                	li	a4,3
    8000440c:	04e78763          	beq	a5,a4,8000445a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004410:	4709                	li	a4,2
    80004412:	06e79a63          	bne	a5,a4,80004486 <fileread+0x9e>
    ilock(f->ip);
    80004416:	6d08                	ld	a0,24(a0)
    80004418:	8baff0ef          	jal	800034d2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000441c:	874a                	mv	a4,s2
    8000441e:	5094                	lw	a3,32(s1)
    80004420:	864e                	mv	a2,s3
    80004422:	4585                	li	a1,1
    80004424:	6c88                	ld	a0,24(s1)
    80004426:	c3cff0ef          	jal	80003862 <readi>
    8000442a:	892a                	mv	s2,a0
    8000442c:	00a05563          	blez	a0,80004436 <fileread+0x4e>
      f->off += r;
    80004430:	509c                	lw	a5,32(s1)
    80004432:	9fa9                	addw	a5,a5,a0
    80004434:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004436:	6c88                	ld	a0,24(s1)
    80004438:	948ff0ef          	jal	80003580 <iunlock>
    8000443c:	64e2                	ld	s1,24(sp)
    8000443e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004440:	854a                	mv	a0,s2
    80004442:	70a2                	ld	ra,40(sp)
    80004444:	7402                	ld	s0,32(sp)
    80004446:	6942                	ld	s2,16(sp)
    80004448:	6145                	addi	sp,sp,48
    8000444a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000444c:	6908                	ld	a0,16(a0)
    8000444e:	388000ef          	jal	800047d6 <piperead>
    80004452:	892a                	mv	s2,a0
    80004454:	64e2                	ld	s1,24(sp)
    80004456:	69a2                	ld	s3,8(sp)
    80004458:	b7e5                	j	80004440 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000445a:	02451783          	lh	a5,36(a0)
    8000445e:	03079693          	slli	a3,a5,0x30
    80004462:	92c1                	srli	a3,a3,0x30
    80004464:	4725                	li	a4,9
    80004466:	02d76863          	bltu	a4,a3,80004496 <fileread+0xae>
    8000446a:	0792                	slli	a5,a5,0x4
    8000446c:	0001e717          	auipc	a4,0x1e
    80004470:	40c70713          	addi	a4,a4,1036 # 80022878 <devsw>
    80004474:	97ba                	add	a5,a5,a4
    80004476:	639c                	ld	a5,0(a5)
    80004478:	c39d                	beqz	a5,8000449e <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000447a:	4505                	li	a0,1
    8000447c:	9782                	jalr	a5
    8000447e:	892a                	mv	s2,a0
    80004480:	64e2                	ld	s1,24(sp)
    80004482:	69a2                	ld	s3,8(sp)
    80004484:	bf75                	j	80004440 <fileread+0x58>
    panic("fileread");
    80004486:	00003517          	auipc	a0,0x3
    8000448a:	0fa50513          	addi	a0,a0,250 # 80007580 <etext+0x580>
    8000448e:	b52fc0ef          	jal	800007e0 <panic>
    return -1;
    80004492:	597d                	li	s2,-1
    80004494:	b775                	j	80004440 <fileread+0x58>
      return -1;
    80004496:	597d                	li	s2,-1
    80004498:	64e2                	ld	s1,24(sp)
    8000449a:	69a2                	ld	s3,8(sp)
    8000449c:	b755                	j	80004440 <fileread+0x58>
    8000449e:	597d                	li	s2,-1
    800044a0:	64e2                	ld	s1,24(sp)
    800044a2:	69a2                	ld	s3,8(sp)
    800044a4:	bf71                	j	80004440 <fileread+0x58>

00000000800044a6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800044a6:	00954783          	lbu	a5,9(a0)
    800044aa:	10078b63          	beqz	a5,800045c0 <filewrite+0x11a>
{
    800044ae:	715d                	addi	sp,sp,-80
    800044b0:	e486                	sd	ra,72(sp)
    800044b2:	e0a2                	sd	s0,64(sp)
    800044b4:	f84a                	sd	s2,48(sp)
    800044b6:	f052                	sd	s4,32(sp)
    800044b8:	e85a                	sd	s6,16(sp)
    800044ba:	0880                	addi	s0,sp,80
    800044bc:	892a                	mv	s2,a0
    800044be:	8b2e                	mv	s6,a1
    800044c0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800044c2:	411c                	lw	a5,0(a0)
    800044c4:	4705                	li	a4,1
    800044c6:	02e78763          	beq	a5,a4,800044f4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044ca:	470d                	li	a4,3
    800044cc:	02e78863          	beq	a5,a4,800044fc <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800044d0:	4709                	li	a4,2
    800044d2:	0ce79c63          	bne	a5,a4,800045aa <filewrite+0x104>
    800044d6:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800044d8:	0ac05863          	blez	a2,80004588 <filewrite+0xe2>
    800044dc:	fc26                	sd	s1,56(sp)
    800044de:	ec56                	sd	s5,24(sp)
    800044e0:	e45e                	sd	s7,8(sp)
    800044e2:	e062                	sd	s8,0(sp)
    int i = 0;
    800044e4:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800044e6:	6b85                	lui	s7,0x1
    800044e8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044ec:	6c05                	lui	s8,0x1
    800044ee:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800044f2:	a8b5                	j	8000456e <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800044f4:	6908                	ld	a0,16(a0)
    800044f6:	1fc000ef          	jal	800046f2 <pipewrite>
    800044fa:	a04d                	j	8000459c <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044fc:	02451783          	lh	a5,36(a0)
    80004500:	03079693          	slli	a3,a5,0x30
    80004504:	92c1                	srli	a3,a3,0x30
    80004506:	4725                	li	a4,9
    80004508:	0ad76e63          	bltu	a4,a3,800045c4 <filewrite+0x11e>
    8000450c:	0792                	slli	a5,a5,0x4
    8000450e:	0001e717          	auipc	a4,0x1e
    80004512:	36a70713          	addi	a4,a4,874 # 80022878 <devsw>
    80004516:	97ba                	add	a5,a5,a4
    80004518:	679c                	ld	a5,8(a5)
    8000451a:	c7dd                	beqz	a5,800045c8 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000451c:	4505                	li	a0,1
    8000451e:	9782                	jalr	a5
    80004520:	a8b5                	j	8000459c <filewrite+0xf6>
      if(n1 > max)
    80004522:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004526:	997ff0ef          	jal	80003ebc <begin_op>
      ilock(f->ip);
    8000452a:	01893503          	ld	a0,24(s2)
    8000452e:	fa5fe0ef          	jal	800034d2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004532:	8756                	mv	a4,s5
    80004534:	02092683          	lw	a3,32(s2)
    80004538:	01698633          	add	a2,s3,s6
    8000453c:	4585                	li	a1,1
    8000453e:	01893503          	ld	a0,24(s2)
    80004542:	c1cff0ef          	jal	8000395e <writei>
    80004546:	84aa                	mv	s1,a0
    80004548:	00a05763          	blez	a0,80004556 <filewrite+0xb0>
        f->off += r;
    8000454c:	02092783          	lw	a5,32(s2)
    80004550:	9fa9                	addw	a5,a5,a0
    80004552:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004556:	01893503          	ld	a0,24(s2)
    8000455a:	826ff0ef          	jal	80003580 <iunlock>
      end_op();
    8000455e:	9c9ff0ef          	jal	80003f26 <end_op>

      if(r != n1){
    80004562:	029a9563          	bne	s5,s1,8000458c <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004566:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000456a:	0149da63          	bge	s3,s4,8000457e <filewrite+0xd8>
      int n1 = n - i;
    8000456e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004572:	0004879b          	sext.w	a5,s1
    80004576:	fafbd6e3          	bge	s7,a5,80004522 <filewrite+0x7c>
    8000457a:	84e2                	mv	s1,s8
    8000457c:	b75d                	j	80004522 <filewrite+0x7c>
    8000457e:	74e2                	ld	s1,56(sp)
    80004580:	6ae2                	ld	s5,24(sp)
    80004582:	6ba2                	ld	s7,8(sp)
    80004584:	6c02                	ld	s8,0(sp)
    80004586:	a039                	j	80004594 <filewrite+0xee>
    int i = 0;
    80004588:	4981                	li	s3,0
    8000458a:	a029                	j	80004594 <filewrite+0xee>
    8000458c:	74e2                	ld	s1,56(sp)
    8000458e:	6ae2                	ld	s5,24(sp)
    80004590:	6ba2                	ld	s7,8(sp)
    80004592:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004594:	033a1c63          	bne	s4,s3,800045cc <filewrite+0x126>
    80004598:	8552                	mv	a0,s4
    8000459a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000459c:	60a6                	ld	ra,72(sp)
    8000459e:	6406                	ld	s0,64(sp)
    800045a0:	7942                	ld	s2,48(sp)
    800045a2:	7a02                	ld	s4,32(sp)
    800045a4:	6b42                	ld	s6,16(sp)
    800045a6:	6161                	addi	sp,sp,80
    800045a8:	8082                	ret
    800045aa:	fc26                	sd	s1,56(sp)
    800045ac:	f44e                	sd	s3,40(sp)
    800045ae:	ec56                	sd	s5,24(sp)
    800045b0:	e45e                	sd	s7,8(sp)
    800045b2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800045b4:	00003517          	auipc	a0,0x3
    800045b8:	fdc50513          	addi	a0,a0,-36 # 80007590 <etext+0x590>
    800045bc:	a24fc0ef          	jal	800007e0 <panic>
    return -1;
    800045c0:	557d                	li	a0,-1
}
    800045c2:	8082                	ret
      return -1;
    800045c4:	557d                	li	a0,-1
    800045c6:	bfd9                	j	8000459c <filewrite+0xf6>
    800045c8:	557d                	li	a0,-1
    800045ca:	bfc9                	j	8000459c <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800045cc:	557d                	li	a0,-1
    800045ce:	79a2                	ld	s3,40(sp)
    800045d0:	b7f1                	j	8000459c <filewrite+0xf6>

00000000800045d2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045d2:	7179                	addi	sp,sp,-48
    800045d4:	f406                	sd	ra,40(sp)
    800045d6:	f022                	sd	s0,32(sp)
    800045d8:	ec26                	sd	s1,24(sp)
    800045da:	e052                	sd	s4,0(sp)
    800045dc:	1800                	addi	s0,sp,48
    800045de:	84aa                	mv	s1,a0
    800045e0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045e2:	0005b023          	sd	zero,0(a1)
    800045e6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045ea:	c3bff0ef          	jal	80004224 <filealloc>
    800045ee:	e088                	sd	a0,0(s1)
    800045f0:	c549                	beqz	a0,8000467a <pipealloc+0xa8>
    800045f2:	c33ff0ef          	jal	80004224 <filealloc>
    800045f6:	00aa3023          	sd	a0,0(s4)
    800045fa:	cd25                	beqz	a0,80004672 <pipealloc+0xa0>
    800045fc:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800045fe:	d00fc0ef          	jal	80000afe <kalloc>
    80004602:	892a                	mv	s2,a0
    80004604:	c12d                	beqz	a0,80004666 <pipealloc+0x94>
    80004606:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004608:	4985                	li	s3,1
    8000460a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000460e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004612:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004616:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000461a:	00003597          	auipc	a1,0x3
    8000461e:	f8658593          	addi	a1,a1,-122 # 800075a0 <etext+0x5a0>
    80004622:	d2cfc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004626:	609c                	ld	a5,0(s1)
    80004628:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000462c:	609c                	ld	a5,0(s1)
    8000462e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004632:	609c                	ld	a5,0(s1)
    80004634:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004638:	609c                	ld	a5,0(s1)
    8000463a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000463e:	000a3783          	ld	a5,0(s4)
    80004642:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004646:	000a3783          	ld	a5,0(s4)
    8000464a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000464e:	000a3783          	ld	a5,0(s4)
    80004652:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004656:	000a3783          	ld	a5,0(s4)
    8000465a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000465e:	4501                	li	a0,0
    80004660:	6942                	ld	s2,16(sp)
    80004662:	69a2                	ld	s3,8(sp)
    80004664:	a01d                	j	8000468a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004666:	6088                	ld	a0,0(s1)
    80004668:	c119                	beqz	a0,8000466e <pipealloc+0x9c>
    8000466a:	6942                	ld	s2,16(sp)
    8000466c:	a029                	j	80004676 <pipealloc+0xa4>
    8000466e:	6942                	ld	s2,16(sp)
    80004670:	a029                	j	8000467a <pipealloc+0xa8>
    80004672:	6088                	ld	a0,0(s1)
    80004674:	c10d                	beqz	a0,80004696 <pipealloc+0xc4>
    fileclose(*f0);
    80004676:	c53ff0ef          	jal	800042c8 <fileclose>
  if(*f1)
    8000467a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000467e:	557d                	li	a0,-1
  if(*f1)
    80004680:	c789                	beqz	a5,8000468a <pipealloc+0xb8>
    fileclose(*f1);
    80004682:	853e                	mv	a0,a5
    80004684:	c45ff0ef          	jal	800042c8 <fileclose>
  return -1;
    80004688:	557d                	li	a0,-1
}
    8000468a:	70a2                	ld	ra,40(sp)
    8000468c:	7402                	ld	s0,32(sp)
    8000468e:	64e2                	ld	s1,24(sp)
    80004690:	6a02                	ld	s4,0(sp)
    80004692:	6145                	addi	sp,sp,48
    80004694:	8082                	ret
  return -1;
    80004696:	557d                	li	a0,-1
    80004698:	bfcd                	j	8000468a <pipealloc+0xb8>

000000008000469a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000469a:	1101                	addi	sp,sp,-32
    8000469c:	ec06                	sd	ra,24(sp)
    8000469e:	e822                	sd	s0,16(sp)
    800046a0:	e426                	sd	s1,8(sp)
    800046a2:	e04a                	sd	s2,0(sp)
    800046a4:	1000                	addi	s0,sp,32
    800046a6:	84aa                	mv	s1,a0
    800046a8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800046aa:	d24fc0ef          	jal	80000bce <acquire>
  if(writable){
    800046ae:	02090763          	beqz	s2,800046dc <pipeclose+0x42>
    pi->writeopen = 0;
    800046b2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046b6:	21848513          	addi	a0,s1,536
    800046ba:	a79fd0ef          	jal	80002132 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800046be:	2204b783          	ld	a5,544(s1)
    800046c2:	e785                	bnez	a5,800046ea <pipeclose+0x50>
    release(&pi->lock);
    800046c4:	8526                	mv	a0,s1
    800046c6:	da0fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800046ca:	8526                	mv	a0,s1
    800046cc:	b50fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800046d0:	60e2                	ld	ra,24(sp)
    800046d2:	6442                	ld	s0,16(sp)
    800046d4:	64a2                	ld	s1,8(sp)
    800046d6:	6902                	ld	s2,0(sp)
    800046d8:	6105                	addi	sp,sp,32
    800046da:	8082                	ret
    pi->readopen = 0;
    800046dc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046e0:	21c48513          	addi	a0,s1,540
    800046e4:	a4ffd0ef          	jal	80002132 <wakeup>
    800046e8:	bfd9                	j	800046be <pipeclose+0x24>
    release(&pi->lock);
    800046ea:	8526                	mv	a0,s1
    800046ec:	d7afc0ef          	jal	80000c66 <release>
}
    800046f0:	b7c5                	j	800046d0 <pipeclose+0x36>

00000000800046f2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046f2:	711d                	addi	sp,sp,-96
    800046f4:	ec86                	sd	ra,88(sp)
    800046f6:	e8a2                	sd	s0,80(sp)
    800046f8:	e4a6                	sd	s1,72(sp)
    800046fa:	e0ca                	sd	s2,64(sp)
    800046fc:	fc4e                	sd	s3,56(sp)
    800046fe:	f852                	sd	s4,48(sp)
    80004700:	f456                	sd	s5,40(sp)
    80004702:	1080                	addi	s0,sp,96
    80004704:	84aa                	mv	s1,a0
    80004706:	8aae                	mv	s5,a1
    80004708:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000470a:	a46fd0ef          	jal	80001950 <myproc>
    8000470e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004710:	8526                	mv	a0,s1
    80004712:	cbcfc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004716:	0b405a63          	blez	s4,800047ca <pipewrite+0xd8>
    8000471a:	f05a                	sd	s6,32(sp)
    8000471c:	ec5e                	sd	s7,24(sp)
    8000471e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004720:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004722:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004724:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004728:	21c48b93          	addi	s7,s1,540
    8000472c:	a81d                	j	80004762 <pipewrite+0x70>
      release(&pi->lock);
    8000472e:	8526                	mv	a0,s1
    80004730:	d36fc0ef          	jal	80000c66 <release>
      return -1;
    80004734:	597d                	li	s2,-1
    80004736:	7b02                	ld	s6,32(sp)
    80004738:	6be2                	ld	s7,24(sp)
    8000473a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000473c:	854a                	mv	a0,s2
    8000473e:	60e6                	ld	ra,88(sp)
    80004740:	6446                	ld	s0,80(sp)
    80004742:	64a6                	ld	s1,72(sp)
    80004744:	6906                	ld	s2,64(sp)
    80004746:	79e2                	ld	s3,56(sp)
    80004748:	7a42                	ld	s4,48(sp)
    8000474a:	7aa2                	ld	s5,40(sp)
    8000474c:	6125                	addi	sp,sp,96
    8000474e:	8082                	ret
      wakeup(&pi->nread);
    80004750:	8562                	mv	a0,s8
    80004752:	9e1fd0ef          	jal	80002132 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004756:	85a6                	mv	a1,s1
    80004758:	855e                	mv	a0,s7
    8000475a:	98dfd0ef          	jal	800020e6 <sleep>
  while(i < n){
    8000475e:	05495b63          	bge	s2,s4,800047b4 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004762:	2204a783          	lw	a5,544(s1)
    80004766:	d7e1                	beqz	a5,8000472e <pipewrite+0x3c>
    80004768:	854e                	mv	a0,s3
    8000476a:	bedfd0ef          	jal	80002356 <killed>
    8000476e:	f161                	bnez	a0,8000472e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004770:	2184a783          	lw	a5,536(s1)
    80004774:	21c4a703          	lw	a4,540(s1)
    80004778:	2007879b          	addiw	a5,a5,512
    8000477c:	fcf70ae3          	beq	a4,a5,80004750 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004780:	4685                	li	a3,1
    80004782:	01590633          	add	a2,s2,s5
    80004786:	faf40593          	addi	a1,s0,-81
    8000478a:	0509b503          	ld	a0,80(s3)
    8000478e:	f39fc0ef          	jal	800016c6 <copyin>
    80004792:	03650e63          	beq	a0,s6,800047ce <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004796:	21c4a783          	lw	a5,540(s1)
    8000479a:	0017871b          	addiw	a4,a5,1
    8000479e:	20e4ae23          	sw	a4,540(s1)
    800047a2:	1ff7f793          	andi	a5,a5,511
    800047a6:	97a6                	add	a5,a5,s1
    800047a8:	faf44703          	lbu	a4,-81(s0)
    800047ac:	00e78c23          	sb	a4,24(a5)
      i++;
    800047b0:	2905                	addiw	s2,s2,1
    800047b2:	b775                	j	8000475e <pipewrite+0x6c>
    800047b4:	7b02                	ld	s6,32(sp)
    800047b6:	6be2                	ld	s7,24(sp)
    800047b8:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800047ba:	21848513          	addi	a0,s1,536
    800047be:	975fd0ef          	jal	80002132 <wakeup>
  release(&pi->lock);
    800047c2:	8526                	mv	a0,s1
    800047c4:	ca2fc0ef          	jal	80000c66 <release>
  return i;
    800047c8:	bf95                	j	8000473c <pipewrite+0x4a>
  int i = 0;
    800047ca:	4901                	li	s2,0
    800047cc:	b7fd                	j	800047ba <pipewrite+0xc8>
    800047ce:	7b02                	ld	s6,32(sp)
    800047d0:	6be2                	ld	s7,24(sp)
    800047d2:	6c42                	ld	s8,16(sp)
    800047d4:	b7dd                	j	800047ba <pipewrite+0xc8>

00000000800047d6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047d6:	715d                	addi	sp,sp,-80
    800047d8:	e486                	sd	ra,72(sp)
    800047da:	e0a2                	sd	s0,64(sp)
    800047dc:	fc26                	sd	s1,56(sp)
    800047de:	f84a                	sd	s2,48(sp)
    800047e0:	f44e                	sd	s3,40(sp)
    800047e2:	f052                	sd	s4,32(sp)
    800047e4:	ec56                	sd	s5,24(sp)
    800047e6:	0880                	addi	s0,sp,80
    800047e8:	84aa                	mv	s1,a0
    800047ea:	892e                	mv	s2,a1
    800047ec:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047ee:	962fd0ef          	jal	80001950 <myproc>
    800047f2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800047f4:	8526                	mv	a0,s1
    800047f6:	bd8fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047fa:	2184a703          	lw	a4,536(s1)
    800047fe:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004802:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004806:	02f71563          	bne	a4,a5,80004830 <piperead+0x5a>
    8000480a:	2244a783          	lw	a5,548(s1)
    8000480e:	cb85                	beqz	a5,8000483e <piperead+0x68>
    if(killed(pr)){
    80004810:	8552                	mv	a0,s4
    80004812:	b45fd0ef          	jal	80002356 <killed>
    80004816:	ed19                	bnez	a0,80004834 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004818:	85a6                	mv	a1,s1
    8000481a:	854e                	mv	a0,s3
    8000481c:	8cbfd0ef          	jal	800020e6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004820:	2184a703          	lw	a4,536(s1)
    80004824:	21c4a783          	lw	a5,540(s1)
    80004828:	fef701e3          	beq	a4,a5,8000480a <piperead+0x34>
    8000482c:	e85a                	sd	s6,16(sp)
    8000482e:	a809                	j	80004840 <piperead+0x6a>
    80004830:	e85a                	sd	s6,16(sp)
    80004832:	a039                	j	80004840 <piperead+0x6a>
      release(&pi->lock);
    80004834:	8526                	mv	a0,s1
    80004836:	c30fc0ef          	jal	80000c66 <release>
      return -1;
    8000483a:	59fd                	li	s3,-1
    8000483c:	a8b9                	j	8000489a <piperead+0xc4>
    8000483e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004840:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004842:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004844:	05505363          	blez	s5,8000488a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004848:	2184a783          	lw	a5,536(s1)
    8000484c:	21c4a703          	lw	a4,540(s1)
    80004850:	02f70d63          	beq	a4,a5,8000488a <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004854:	1ff7f793          	andi	a5,a5,511
    80004858:	97a6                	add	a5,a5,s1
    8000485a:	0187c783          	lbu	a5,24(a5)
    8000485e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004862:	4685                	li	a3,1
    80004864:	fbf40613          	addi	a2,s0,-65
    80004868:	85ca                	mv	a1,s2
    8000486a:	050a3503          	ld	a0,80(s4)
    8000486e:	d75fc0ef          	jal	800015e2 <copyout>
    80004872:	03650e63          	beq	a0,s6,800048ae <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004876:	2184a783          	lw	a5,536(s1)
    8000487a:	2785                	addiw	a5,a5,1
    8000487c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004880:	2985                	addiw	s3,s3,1
    80004882:	0905                	addi	s2,s2,1
    80004884:	fd3a92e3          	bne	s5,s3,80004848 <piperead+0x72>
    80004888:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000488a:	21c48513          	addi	a0,s1,540
    8000488e:	8a5fd0ef          	jal	80002132 <wakeup>
  release(&pi->lock);
    80004892:	8526                	mv	a0,s1
    80004894:	bd2fc0ef          	jal	80000c66 <release>
    80004898:	6b42                	ld	s6,16(sp)
  return i;
}
    8000489a:	854e                	mv	a0,s3
    8000489c:	60a6                	ld	ra,72(sp)
    8000489e:	6406                	ld	s0,64(sp)
    800048a0:	74e2                	ld	s1,56(sp)
    800048a2:	7942                	ld	s2,48(sp)
    800048a4:	79a2                	ld	s3,40(sp)
    800048a6:	7a02                	ld	s4,32(sp)
    800048a8:	6ae2                	ld	s5,24(sp)
    800048aa:	6161                	addi	sp,sp,80
    800048ac:	8082                	ret
      if(i == 0)
    800048ae:	fc099ee3          	bnez	s3,8000488a <piperead+0xb4>
        i = -1;
    800048b2:	89aa                	mv	s3,a0
    800048b4:	bfd9                	j	8000488a <piperead+0xb4>

00000000800048b6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800048b6:	1141                	addi	sp,sp,-16
    800048b8:	e422                	sd	s0,8(sp)
    800048ba:	0800                	addi	s0,sp,16
    800048bc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800048be:	8905                	andi	a0,a0,1
    800048c0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800048c2:	8b89                	andi	a5,a5,2
    800048c4:	c399                	beqz	a5,800048ca <flags2perm+0x14>
      perm |= PTE_W;
    800048c6:	00456513          	ori	a0,a0,4
    return perm;
}
    800048ca:	6422                	ld	s0,8(sp)
    800048cc:	0141                	addi	sp,sp,16
    800048ce:	8082                	ret

00000000800048d0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048d0:	df010113          	addi	sp,sp,-528
    800048d4:	20113423          	sd	ra,520(sp)
    800048d8:	20813023          	sd	s0,512(sp)
    800048dc:	ffa6                	sd	s1,504(sp)
    800048de:	fbca                	sd	s2,496(sp)
    800048e0:	0c00                	addi	s0,sp,528
    800048e2:	892a                	mv	s2,a0
    800048e4:	dea43c23          	sd	a0,-520(s0)
    800048e8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048ec:	864fd0ef          	jal	80001950 <myproc>
    800048f0:	84aa                	mv	s1,a0

  begin_op();
    800048f2:	dcaff0ef          	jal	80003ebc <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800048f6:	854a                	mv	a0,s2
    800048f8:	bf0ff0ef          	jal	80003ce8 <namei>
    800048fc:	c931                	beqz	a0,80004950 <kexec+0x80>
    800048fe:	f3d2                	sd	s4,480(sp)
    80004900:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004902:	bd1fe0ef          	jal	800034d2 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004906:	04000713          	li	a4,64
    8000490a:	4681                	li	a3,0
    8000490c:	e5040613          	addi	a2,s0,-432
    80004910:	4581                	li	a1,0
    80004912:	8552                	mv	a0,s4
    80004914:	f4ffe0ef          	jal	80003862 <readi>
    80004918:	04000793          	li	a5,64
    8000491c:	00f51a63          	bne	a0,a5,80004930 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004920:	e5042703          	lw	a4,-432(s0)
    80004924:	464c47b7          	lui	a5,0x464c4
    80004928:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000492c:	02f70663          	beq	a4,a5,80004958 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004930:	8552                	mv	a0,s4
    80004932:	dabfe0ef          	jal	800036dc <iunlockput>
    end_op();
    80004936:	df0ff0ef          	jal	80003f26 <end_op>
  }
  return -1;
    8000493a:	557d                	li	a0,-1
    8000493c:	7a1e                	ld	s4,480(sp)
}
    8000493e:	20813083          	ld	ra,520(sp)
    80004942:	20013403          	ld	s0,512(sp)
    80004946:	74fe                	ld	s1,504(sp)
    80004948:	795e                	ld	s2,496(sp)
    8000494a:	21010113          	addi	sp,sp,528
    8000494e:	8082                	ret
    end_op();
    80004950:	dd6ff0ef          	jal	80003f26 <end_op>
    return -1;
    80004954:	557d                	li	a0,-1
    80004956:	b7e5                	j	8000493e <kexec+0x6e>
    80004958:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000495a:	8526                	mv	a0,s1
    8000495c:	8fafd0ef          	jal	80001a56 <proc_pagetable>
    80004960:	8b2a                	mv	s6,a0
    80004962:	2c050b63          	beqz	a0,80004c38 <kexec+0x368>
    80004966:	f7ce                	sd	s3,488(sp)
    80004968:	efd6                	sd	s5,472(sp)
    8000496a:	e7de                	sd	s7,456(sp)
    8000496c:	e3e2                	sd	s8,448(sp)
    8000496e:	ff66                	sd	s9,440(sp)
    80004970:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004972:	e7042d03          	lw	s10,-400(s0)
    80004976:	e8845783          	lhu	a5,-376(s0)
    8000497a:	12078963          	beqz	a5,80004aac <kexec+0x1dc>
    8000497e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004980:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004982:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004984:	6c85                	lui	s9,0x1
    80004986:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000498a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000498e:	6a85                	lui	s5,0x1
    80004990:	a085                	j	800049f0 <kexec+0x120>
      panic("loadseg: address should exist");
    80004992:	00003517          	auipc	a0,0x3
    80004996:	c1650513          	addi	a0,a0,-1002 # 800075a8 <etext+0x5a8>
    8000499a:	e47fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    8000499e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800049a0:	8726                	mv	a4,s1
    800049a2:	012c06bb          	addw	a3,s8,s2
    800049a6:	4581                	li	a1,0
    800049a8:	8552                	mv	a0,s4
    800049aa:	eb9fe0ef          	jal	80003862 <readi>
    800049ae:	2501                	sext.w	a0,a0
    800049b0:	24a49a63          	bne	s1,a0,80004c04 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800049b4:	012a893b          	addw	s2,s5,s2
    800049b8:	03397363          	bgeu	s2,s3,800049de <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800049bc:	02091593          	slli	a1,s2,0x20
    800049c0:	9181                	srli	a1,a1,0x20
    800049c2:	95de                	add	a1,a1,s7
    800049c4:	855a                	mv	a0,s6
    800049c6:	deafc0ef          	jal	80000fb0 <walkaddr>
    800049ca:	862a                	mv	a2,a0
    if(pa == 0)
    800049cc:	d179                	beqz	a0,80004992 <kexec+0xc2>
    if(sz - i < PGSIZE)
    800049ce:	412984bb          	subw	s1,s3,s2
    800049d2:	0004879b          	sext.w	a5,s1
    800049d6:	fcfcf4e3          	bgeu	s9,a5,8000499e <kexec+0xce>
    800049da:	84d6                	mv	s1,s5
    800049dc:	b7c9                	j	8000499e <kexec+0xce>
    sz = sz1;
    800049de:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049e2:	2d85                	addiw	s11,s11,1
    800049e4:	038d0d1b          	addiw	s10,s10,56
    800049e8:	e8845783          	lhu	a5,-376(s0)
    800049ec:	08fdd063          	bge	s11,a5,80004a6c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049f0:	2d01                	sext.w	s10,s10
    800049f2:	03800713          	li	a4,56
    800049f6:	86ea                	mv	a3,s10
    800049f8:	e1840613          	addi	a2,s0,-488
    800049fc:	4581                	li	a1,0
    800049fe:	8552                	mv	a0,s4
    80004a00:	e63fe0ef          	jal	80003862 <readi>
    80004a04:	03800793          	li	a5,56
    80004a08:	1cf51663          	bne	a0,a5,80004bd4 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004a0c:	e1842783          	lw	a5,-488(s0)
    80004a10:	4705                	li	a4,1
    80004a12:	fce798e3          	bne	a5,a4,800049e2 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004a16:	e4043483          	ld	s1,-448(s0)
    80004a1a:	e3843783          	ld	a5,-456(s0)
    80004a1e:	1af4ef63          	bltu	s1,a5,80004bdc <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a22:	e2843783          	ld	a5,-472(s0)
    80004a26:	94be                	add	s1,s1,a5
    80004a28:	1af4ee63          	bltu	s1,a5,80004be4 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004a2c:	df043703          	ld	a4,-528(s0)
    80004a30:	8ff9                	and	a5,a5,a4
    80004a32:	1a079d63          	bnez	a5,80004bec <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a36:	e1c42503          	lw	a0,-484(s0)
    80004a3a:	e7dff0ef          	jal	800048b6 <flags2perm>
    80004a3e:	86aa                	mv	a3,a0
    80004a40:	8626                	mv	a2,s1
    80004a42:	85ca                	mv	a1,s2
    80004a44:	855a                	mv	a0,s6
    80004a46:	843fc0ef          	jal	80001288 <uvmalloc>
    80004a4a:	e0a43423          	sd	a0,-504(s0)
    80004a4e:	1a050363          	beqz	a0,80004bf4 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a52:	e2843b83          	ld	s7,-472(s0)
    80004a56:	e2042c03          	lw	s8,-480(s0)
    80004a5a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a5e:	00098463          	beqz	s3,80004a66 <kexec+0x196>
    80004a62:	4901                	li	s2,0
    80004a64:	bfa1                	j	800049bc <kexec+0xec>
    sz = sz1;
    80004a66:	e0843903          	ld	s2,-504(s0)
    80004a6a:	bfa5                	j	800049e2 <kexec+0x112>
    80004a6c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004a6e:	8552                	mv	a0,s4
    80004a70:	c6dfe0ef          	jal	800036dc <iunlockput>
  end_op();
    80004a74:	cb2ff0ef          	jal	80003f26 <end_op>
  p = myproc();
    80004a78:	ed9fc0ef          	jal	80001950 <myproc>
    80004a7c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a7e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004a82:	6985                	lui	s3,0x1
    80004a84:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a86:	99ca                	add	s3,s3,s2
    80004a88:	77fd                	lui	a5,0xfffff
    80004a8a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a8e:	4691                	li	a3,4
    80004a90:	6609                	lui	a2,0x2
    80004a92:	964e                	add	a2,a2,s3
    80004a94:	85ce                	mv	a1,s3
    80004a96:	855a                	mv	a0,s6
    80004a98:	ff0fc0ef          	jal	80001288 <uvmalloc>
    80004a9c:	892a                	mv	s2,a0
    80004a9e:	e0a43423          	sd	a0,-504(s0)
    80004aa2:	e519                	bnez	a0,80004ab0 <kexec+0x1e0>
  if(pagetable)
    80004aa4:	e1343423          	sd	s3,-504(s0)
    80004aa8:	4a01                	li	s4,0
    80004aaa:	aab1                	j	80004c06 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004aac:	4901                	li	s2,0
    80004aae:	b7c1                	j	80004a6e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004ab0:	75f9                	lui	a1,0xffffe
    80004ab2:	95aa                	add	a1,a1,a0
    80004ab4:	855a                	mv	a0,s6
    80004ab6:	9a9fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004aba:	7bfd                	lui	s7,0xfffff
    80004abc:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004abe:	e0043783          	ld	a5,-512(s0)
    80004ac2:	6388                	ld	a0,0(a5)
    80004ac4:	cd39                	beqz	a0,80004b22 <kexec+0x252>
    80004ac6:	e9040993          	addi	s3,s0,-368
    80004aca:	f9040c13          	addi	s8,s0,-112
    80004ace:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ad0:	b42fc0ef          	jal	80000e12 <strlen>
    80004ad4:	0015079b          	addiw	a5,a0,1
    80004ad8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004adc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ae0:	11796e63          	bltu	s2,s7,80004bfc <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ae4:	e0043d03          	ld	s10,-512(s0)
    80004ae8:	000d3a03          	ld	s4,0(s10)
    80004aec:	8552                	mv	a0,s4
    80004aee:	b24fc0ef          	jal	80000e12 <strlen>
    80004af2:	0015069b          	addiw	a3,a0,1
    80004af6:	8652                	mv	a2,s4
    80004af8:	85ca                	mv	a1,s2
    80004afa:	855a                	mv	a0,s6
    80004afc:	ae7fc0ef          	jal	800015e2 <copyout>
    80004b00:	10054063          	bltz	a0,80004c00 <kexec+0x330>
    ustack[argc] = sp;
    80004b04:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004b08:	0485                	addi	s1,s1,1
    80004b0a:	008d0793          	addi	a5,s10,8
    80004b0e:	e0f43023          	sd	a5,-512(s0)
    80004b12:	008d3503          	ld	a0,8(s10)
    80004b16:	c909                	beqz	a0,80004b28 <kexec+0x258>
    if(argc >= MAXARG)
    80004b18:	09a1                	addi	s3,s3,8
    80004b1a:	fb899be3          	bne	s3,s8,80004ad0 <kexec+0x200>
  ip = 0;
    80004b1e:	4a01                	li	s4,0
    80004b20:	a0dd                	j	80004c06 <kexec+0x336>
  sp = sz;
    80004b22:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004b26:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b28:	00349793          	slli	a5,s1,0x3
    80004b2c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb580>
    80004b30:	97a2                	add	a5,a5,s0
    80004b32:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b36:	00148693          	addi	a3,s1,1
    80004b3a:	068e                	slli	a3,a3,0x3
    80004b3c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b40:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b44:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004b48:	f5796ee3          	bltu	s2,s7,80004aa4 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b4c:	e9040613          	addi	a2,s0,-368
    80004b50:	85ca                	mv	a1,s2
    80004b52:	855a                	mv	a0,s6
    80004b54:	a8ffc0ef          	jal	800015e2 <copyout>
    80004b58:	0e054263          	bltz	a0,80004c3c <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004b5c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b60:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b64:	df843783          	ld	a5,-520(s0)
    80004b68:	0007c703          	lbu	a4,0(a5)
    80004b6c:	cf11                	beqz	a4,80004b88 <kexec+0x2b8>
    80004b6e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b70:	02f00693          	li	a3,47
    80004b74:	a039                	j	80004b82 <kexec+0x2b2>
      last = s+1;
    80004b76:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004b7a:	0785                	addi	a5,a5,1
    80004b7c:	fff7c703          	lbu	a4,-1(a5)
    80004b80:	c701                	beqz	a4,80004b88 <kexec+0x2b8>
    if(*s == '/')
    80004b82:	fed71ce3          	bne	a4,a3,80004b7a <kexec+0x2aa>
    80004b86:	bfc5                	j	80004b76 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b88:	4641                	li	a2,16
    80004b8a:	df843583          	ld	a1,-520(s0)
    80004b8e:	158a8513          	addi	a0,s5,344
    80004b92:	a4efc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b96:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b9a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b9e:	e0843783          	ld	a5,-504(s0)
    80004ba2:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004ba6:	058ab783          	ld	a5,88(s5)
    80004baa:	e6843703          	ld	a4,-408(s0)
    80004bae:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004bb0:	058ab783          	ld	a5,88(s5)
    80004bb4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004bb8:	85e6                	mv	a1,s9
    80004bba:	f21fc0ef          	jal	80001ada <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004bbe:	0004851b          	sext.w	a0,s1
    80004bc2:	79be                	ld	s3,488(sp)
    80004bc4:	7a1e                	ld	s4,480(sp)
    80004bc6:	6afe                	ld	s5,472(sp)
    80004bc8:	6b5e                	ld	s6,464(sp)
    80004bca:	6bbe                	ld	s7,456(sp)
    80004bcc:	6c1e                	ld	s8,448(sp)
    80004bce:	7cfa                	ld	s9,440(sp)
    80004bd0:	7d5a                	ld	s10,432(sp)
    80004bd2:	b3b5                	j	8000493e <kexec+0x6e>
    80004bd4:	e1243423          	sd	s2,-504(s0)
    80004bd8:	7dba                	ld	s11,424(sp)
    80004bda:	a035                	j	80004c06 <kexec+0x336>
    80004bdc:	e1243423          	sd	s2,-504(s0)
    80004be0:	7dba                	ld	s11,424(sp)
    80004be2:	a015                	j	80004c06 <kexec+0x336>
    80004be4:	e1243423          	sd	s2,-504(s0)
    80004be8:	7dba                	ld	s11,424(sp)
    80004bea:	a831                	j	80004c06 <kexec+0x336>
    80004bec:	e1243423          	sd	s2,-504(s0)
    80004bf0:	7dba                	ld	s11,424(sp)
    80004bf2:	a811                	j	80004c06 <kexec+0x336>
    80004bf4:	e1243423          	sd	s2,-504(s0)
    80004bf8:	7dba                	ld	s11,424(sp)
    80004bfa:	a031                	j	80004c06 <kexec+0x336>
  ip = 0;
    80004bfc:	4a01                	li	s4,0
    80004bfe:	a021                	j	80004c06 <kexec+0x336>
    80004c00:	4a01                	li	s4,0
  if(pagetable)
    80004c02:	a011                	j	80004c06 <kexec+0x336>
    80004c04:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004c06:	e0843583          	ld	a1,-504(s0)
    80004c0a:	855a                	mv	a0,s6
    80004c0c:	ecffc0ef          	jal	80001ada <proc_freepagetable>
  return -1;
    80004c10:	557d                	li	a0,-1
  if(ip){
    80004c12:	000a1b63          	bnez	s4,80004c28 <kexec+0x358>
    80004c16:	79be                	ld	s3,488(sp)
    80004c18:	7a1e                	ld	s4,480(sp)
    80004c1a:	6afe                	ld	s5,472(sp)
    80004c1c:	6b5e                	ld	s6,464(sp)
    80004c1e:	6bbe                	ld	s7,456(sp)
    80004c20:	6c1e                	ld	s8,448(sp)
    80004c22:	7cfa                	ld	s9,440(sp)
    80004c24:	7d5a                	ld	s10,432(sp)
    80004c26:	bb21                	j	8000493e <kexec+0x6e>
    80004c28:	79be                	ld	s3,488(sp)
    80004c2a:	6afe                	ld	s5,472(sp)
    80004c2c:	6b5e                	ld	s6,464(sp)
    80004c2e:	6bbe                	ld	s7,456(sp)
    80004c30:	6c1e                	ld	s8,448(sp)
    80004c32:	7cfa                	ld	s9,440(sp)
    80004c34:	7d5a                	ld	s10,432(sp)
    80004c36:	b9ed                	j	80004930 <kexec+0x60>
    80004c38:	6b5e                	ld	s6,464(sp)
    80004c3a:	b9dd                	j	80004930 <kexec+0x60>
  sz = sz1;
    80004c3c:	e0843983          	ld	s3,-504(s0)
    80004c40:	b595                	j	80004aa4 <kexec+0x1d4>

0000000080004c42 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c42:	7179                	addi	sp,sp,-48
    80004c44:	f406                	sd	ra,40(sp)
    80004c46:	f022                	sd	s0,32(sp)
    80004c48:	ec26                	sd	s1,24(sp)
    80004c4a:	e84a                	sd	s2,16(sp)
    80004c4c:	1800                	addi	s0,sp,48
    80004c4e:	892e                	mv	s2,a1
    80004c50:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c52:	fdc40593          	addi	a1,s0,-36
    80004c56:	e03fd0ef          	jal	80002a58 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004c5a:	fdc42703          	lw	a4,-36(s0)
    80004c5e:	47bd                	li	a5,15
    80004c60:	02e7e963          	bltu	a5,a4,80004c92 <argfd+0x50>
    80004c64:	cedfc0ef          	jal	80001950 <myproc>
    80004c68:	fdc42703          	lw	a4,-36(s0)
    80004c6c:	01a70793          	addi	a5,a4,26
    80004c70:	078e                	slli	a5,a5,0x3
    80004c72:	953e                	add	a0,a0,a5
    80004c74:	611c                	ld	a5,0(a0)
    80004c76:	c385                	beqz	a5,80004c96 <argfd+0x54>
    return -1;
  if(pfd)
    80004c78:	00090463          	beqz	s2,80004c80 <argfd+0x3e>
    *pfd = fd;
    80004c7c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c80:	4501                	li	a0,0
  if(pf)
    80004c82:	c091                	beqz	s1,80004c86 <argfd+0x44>
    *pf = f;
    80004c84:	e09c                	sd	a5,0(s1)
}
    80004c86:	70a2                	ld	ra,40(sp)
    80004c88:	7402                	ld	s0,32(sp)
    80004c8a:	64e2                	ld	s1,24(sp)
    80004c8c:	6942                	ld	s2,16(sp)
    80004c8e:	6145                	addi	sp,sp,48
    80004c90:	8082                	ret
    return -1;
    80004c92:	557d                	li	a0,-1
    80004c94:	bfcd                	j	80004c86 <argfd+0x44>
    80004c96:	557d                	li	a0,-1
    80004c98:	b7fd                	j	80004c86 <argfd+0x44>

0000000080004c9a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c9a:	1101                	addi	sp,sp,-32
    80004c9c:	ec06                	sd	ra,24(sp)
    80004c9e:	e822                	sd	s0,16(sp)
    80004ca0:	e426                	sd	s1,8(sp)
    80004ca2:	1000                	addi	s0,sp,32
    80004ca4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ca6:	cabfc0ef          	jal	80001950 <myproc>
    80004caa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004cac:	0d050793          	addi	a5,a0,208
    80004cb0:	4501                	li	a0,0
    80004cb2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004cb4:	6398                	ld	a4,0(a5)
    80004cb6:	cb19                	beqz	a4,80004ccc <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004cb8:	2505                	addiw	a0,a0,1
    80004cba:	07a1                	addi	a5,a5,8
    80004cbc:	fed51ce3          	bne	a0,a3,80004cb4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004cc0:	557d                	li	a0,-1
}
    80004cc2:	60e2                	ld	ra,24(sp)
    80004cc4:	6442                	ld	s0,16(sp)
    80004cc6:	64a2                	ld	s1,8(sp)
    80004cc8:	6105                	addi	sp,sp,32
    80004cca:	8082                	ret
      p->ofile[fd] = f;
    80004ccc:	01a50793          	addi	a5,a0,26
    80004cd0:	078e                	slli	a5,a5,0x3
    80004cd2:	963e                	add	a2,a2,a5
    80004cd4:	e204                	sd	s1,0(a2)
      return fd;
    80004cd6:	b7f5                	j	80004cc2 <fdalloc+0x28>

0000000080004cd8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004cd8:	715d                	addi	sp,sp,-80
    80004cda:	e486                	sd	ra,72(sp)
    80004cdc:	e0a2                	sd	s0,64(sp)
    80004cde:	fc26                	sd	s1,56(sp)
    80004ce0:	f84a                	sd	s2,48(sp)
    80004ce2:	f44e                	sd	s3,40(sp)
    80004ce4:	ec56                	sd	s5,24(sp)
    80004ce6:	e85a                	sd	s6,16(sp)
    80004ce8:	0880                	addi	s0,sp,80
    80004cea:	8b2e                	mv	s6,a1
    80004cec:	89b2                	mv	s3,a2
    80004cee:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004cf0:	fb040593          	addi	a1,s0,-80
    80004cf4:	80eff0ef          	jal	80003d02 <nameiparent>
    80004cf8:	84aa                	mv	s1,a0
    80004cfa:	10050a63          	beqz	a0,80004e0e <create+0x136>
    return 0;

  ilock(dp);
    80004cfe:	fd4fe0ef          	jal	800034d2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d02:	4601                	li	a2,0
    80004d04:	fb040593          	addi	a1,s0,-80
    80004d08:	8526                	mv	a0,s1
    80004d0a:	d79fe0ef          	jal	80003a82 <dirlookup>
    80004d0e:	8aaa                	mv	s5,a0
    80004d10:	c129                	beqz	a0,80004d52 <create+0x7a>
    iunlockput(dp);
    80004d12:	8526                	mv	a0,s1
    80004d14:	9c9fe0ef          	jal	800036dc <iunlockput>
    ilock(ip);
    80004d18:	8556                	mv	a0,s5
    80004d1a:	fb8fe0ef          	jal	800034d2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d1e:	4789                	li	a5,2
    80004d20:	02fb1463          	bne	s6,a5,80004d48 <create+0x70>
    80004d24:	044ad783          	lhu	a5,68(s5)
    80004d28:	37f9                	addiw	a5,a5,-2
    80004d2a:	17c2                	slli	a5,a5,0x30
    80004d2c:	93c1                	srli	a5,a5,0x30
    80004d2e:	4705                	li	a4,1
    80004d30:	00f76c63          	bltu	a4,a5,80004d48 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d34:	8556                	mv	a0,s5
    80004d36:	60a6                	ld	ra,72(sp)
    80004d38:	6406                	ld	s0,64(sp)
    80004d3a:	74e2                	ld	s1,56(sp)
    80004d3c:	7942                	ld	s2,48(sp)
    80004d3e:	79a2                	ld	s3,40(sp)
    80004d40:	6ae2                	ld	s5,24(sp)
    80004d42:	6b42                	ld	s6,16(sp)
    80004d44:	6161                	addi	sp,sp,80
    80004d46:	8082                	ret
    iunlockput(ip);
    80004d48:	8556                	mv	a0,s5
    80004d4a:	993fe0ef          	jal	800036dc <iunlockput>
    return 0;
    80004d4e:	4a81                	li	s5,0
    80004d50:	b7d5                	j	80004d34 <create+0x5c>
    80004d52:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004d54:	85da                	mv	a1,s6
    80004d56:	4088                	lw	a0,0(s1)
    80004d58:	e0afe0ef          	jal	80003362 <ialloc>
    80004d5c:	8a2a                	mv	s4,a0
    80004d5e:	cd15                	beqz	a0,80004d9a <create+0xc2>
  ilock(ip);
    80004d60:	f72fe0ef          	jal	800034d2 <ilock>
  ip->major = major;
    80004d64:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004d68:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004d6c:	4905                	li	s2,1
    80004d6e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004d72:	8552                	mv	a0,s4
    80004d74:	eaafe0ef          	jal	8000341e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d78:	032b0763          	beq	s6,s2,80004da6 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d7c:	004a2603          	lw	a2,4(s4)
    80004d80:	fb040593          	addi	a1,s0,-80
    80004d84:	8526                	mv	a0,s1
    80004d86:	ec9fe0ef          	jal	80003c4e <dirlink>
    80004d8a:	06054563          	bltz	a0,80004df4 <create+0x11c>
  iunlockput(dp);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	94dfe0ef          	jal	800036dc <iunlockput>
  return ip;
    80004d94:	8ad2                	mv	s5,s4
    80004d96:	7a02                	ld	s4,32(sp)
    80004d98:	bf71                	j	80004d34 <create+0x5c>
    iunlockput(dp);
    80004d9a:	8526                	mv	a0,s1
    80004d9c:	941fe0ef          	jal	800036dc <iunlockput>
    return 0;
    80004da0:	8ad2                	mv	s5,s4
    80004da2:	7a02                	ld	s4,32(sp)
    80004da4:	bf41                	j	80004d34 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004da6:	004a2603          	lw	a2,4(s4)
    80004daa:	00003597          	auipc	a1,0x3
    80004dae:	81e58593          	addi	a1,a1,-2018 # 800075c8 <etext+0x5c8>
    80004db2:	8552                	mv	a0,s4
    80004db4:	e9bfe0ef          	jal	80003c4e <dirlink>
    80004db8:	02054e63          	bltz	a0,80004df4 <create+0x11c>
    80004dbc:	40d0                	lw	a2,4(s1)
    80004dbe:	00003597          	auipc	a1,0x3
    80004dc2:	81258593          	addi	a1,a1,-2030 # 800075d0 <etext+0x5d0>
    80004dc6:	8552                	mv	a0,s4
    80004dc8:	e87fe0ef          	jal	80003c4e <dirlink>
    80004dcc:	02054463          	bltz	a0,80004df4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004dd0:	004a2603          	lw	a2,4(s4)
    80004dd4:	fb040593          	addi	a1,s0,-80
    80004dd8:	8526                	mv	a0,s1
    80004dda:	e75fe0ef          	jal	80003c4e <dirlink>
    80004dde:	00054b63          	bltz	a0,80004df4 <create+0x11c>
    dp->nlink++;  // for ".."
    80004de2:	04a4d783          	lhu	a5,74(s1)
    80004de6:	2785                	addiw	a5,a5,1
    80004de8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004dec:	8526                	mv	a0,s1
    80004dee:	e30fe0ef          	jal	8000341e <iupdate>
    80004df2:	bf71                	j	80004d8e <create+0xb6>
  ip->nlink = 0;
    80004df4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004df8:	8552                	mv	a0,s4
    80004dfa:	e24fe0ef          	jal	8000341e <iupdate>
  iunlockput(ip);
    80004dfe:	8552                	mv	a0,s4
    80004e00:	8ddfe0ef          	jal	800036dc <iunlockput>
  iunlockput(dp);
    80004e04:	8526                	mv	a0,s1
    80004e06:	8d7fe0ef          	jal	800036dc <iunlockput>
  return 0;
    80004e0a:	7a02                	ld	s4,32(sp)
    80004e0c:	b725                	j	80004d34 <create+0x5c>
    return 0;
    80004e0e:	8aaa                	mv	s5,a0
    80004e10:	b715                	j	80004d34 <create+0x5c>

0000000080004e12 <sys_dup>:
{
    80004e12:	7179                	addi	sp,sp,-48
    80004e14:	f406                	sd	ra,40(sp)
    80004e16:	f022                	sd	s0,32(sp)
    80004e18:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e1a:	fd840613          	addi	a2,s0,-40
    80004e1e:	4581                	li	a1,0
    80004e20:	4501                	li	a0,0
    80004e22:	e21ff0ef          	jal	80004c42 <argfd>
    return -1;
    80004e26:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e28:	02054363          	bltz	a0,80004e4e <sys_dup+0x3c>
    80004e2c:	ec26                	sd	s1,24(sp)
    80004e2e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e30:	fd843903          	ld	s2,-40(s0)
    80004e34:	854a                	mv	a0,s2
    80004e36:	e65ff0ef          	jal	80004c9a <fdalloc>
    80004e3a:	84aa                	mv	s1,a0
    return -1;
    80004e3c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e3e:	00054d63          	bltz	a0,80004e58 <sys_dup+0x46>
  filedup(f);
    80004e42:	854a                	mv	a0,s2
    80004e44:	c3eff0ef          	jal	80004282 <filedup>
  return fd;
    80004e48:	87a6                	mv	a5,s1
    80004e4a:	64e2                	ld	s1,24(sp)
    80004e4c:	6942                	ld	s2,16(sp)
}
    80004e4e:	853e                	mv	a0,a5
    80004e50:	70a2                	ld	ra,40(sp)
    80004e52:	7402                	ld	s0,32(sp)
    80004e54:	6145                	addi	sp,sp,48
    80004e56:	8082                	ret
    80004e58:	64e2                	ld	s1,24(sp)
    80004e5a:	6942                	ld	s2,16(sp)
    80004e5c:	bfcd                	j	80004e4e <sys_dup+0x3c>

0000000080004e5e <sys_read>:
{
    80004e5e:	7179                	addi	sp,sp,-48
    80004e60:	f406                	sd	ra,40(sp)
    80004e62:	f022                	sd	s0,32(sp)
    80004e64:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e66:	fd840593          	addi	a1,s0,-40
    80004e6a:	4505                	li	a0,1
    80004e6c:	c09fd0ef          	jal	80002a74 <argaddr>
  argint(2, &n);
    80004e70:	fe440593          	addi	a1,s0,-28
    80004e74:	4509                	li	a0,2
    80004e76:	be3fd0ef          	jal	80002a58 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e7a:	fe840613          	addi	a2,s0,-24
    80004e7e:	4581                	li	a1,0
    80004e80:	4501                	li	a0,0
    80004e82:	dc1ff0ef          	jal	80004c42 <argfd>
    80004e86:	87aa                	mv	a5,a0
    return -1;
    80004e88:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e8a:	0007ca63          	bltz	a5,80004e9e <sys_read+0x40>
  return fileread(f, p, n);
    80004e8e:	fe442603          	lw	a2,-28(s0)
    80004e92:	fd843583          	ld	a1,-40(s0)
    80004e96:	fe843503          	ld	a0,-24(s0)
    80004e9a:	d4eff0ef          	jal	800043e8 <fileread>
}
    80004e9e:	70a2                	ld	ra,40(sp)
    80004ea0:	7402                	ld	s0,32(sp)
    80004ea2:	6145                	addi	sp,sp,48
    80004ea4:	8082                	ret

0000000080004ea6 <sys_write>:
{
    80004ea6:	7179                	addi	sp,sp,-48
    80004ea8:	f406                	sd	ra,40(sp)
    80004eaa:	f022                	sd	s0,32(sp)
    80004eac:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004eae:	fd840593          	addi	a1,s0,-40
    80004eb2:	4505                	li	a0,1
    80004eb4:	bc1fd0ef          	jal	80002a74 <argaddr>
  argint(2, &n);
    80004eb8:	fe440593          	addi	a1,s0,-28
    80004ebc:	4509                	li	a0,2
    80004ebe:	b9bfd0ef          	jal	80002a58 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ec2:	fe840613          	addi	a2,s0,-24
    80004ec6:	4581                	li	a1,0
    80004ec8:	4501                	li	a0,0
    80004eca:	d79ff0ef          	jal	80004c42 <argfd>
    80004ece:	87aa                	mv	a5,a0
    return -1;
    80004ed0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ed2:	0007ca63          	bltz	a5,80004ee6 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ed6:	fe442603          	lw	a2,-28(s0)
    80004eda:	fd843583          	ld	a1,-40(s0)
    80004ede:	fe843503          	ld	a0,-24(s0)
    80004ee2:	dc4ff0ef          	jal	800044a6 <filewrite>
}
    80004ee6:	70a2                	ld	ra,40(sp)
    80004ee8:	7402                	ld	s0,32(sp)
    80004eea:	6145                	addi	sp,sp,48
    80004eec:	8082                	ret

0000000080004eee <sys_close>:
{
    80004eee:	1101                	addi	sp,sp,-32
    80004ef0:	ec06                	sd	ra,24(sp)
    80004ef2:	e822                	sd	s0,16(sp)
    80004ef4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ef6:	fe040613          	addi	a2,s0,-32
    80004efa:	fec40593          	addi	a1,s0,-20
    80004efe:	4501                	li	a0,0
    80004f00:	d43ff0ef          	jal	80004c42 <argfd>
    return -1;
    80004f04:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f06:	02054063          	bltz	a0,80004f26 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004f0a:	a47fc0ef          	jal	80001950 <myproc>
    80004f0e:	fec42783          	lw	a5,-20(s0)
    80004f12:	07e9                	addi	a5,a5,26
    80004f14:	078e                	slli	a5,a5,0x3
    80004f16:	953e                	add	a0,a0,a5
    80004f18:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f1c:	fe043503          	ld	a0,-32(s0)
    80004f20:	ba8ff0ef          	jal	800042c8 <fileclose>
  return 0;
    80004f24:	4781                	li	a5,0
}
    80004f26:	853e                	mv	a0,a5
    80004f28:	60e2                	ld	ra,24(sp)
    80004f2a:	6442                	ld	s0,16(sp)
    80004f2c:	6105                	addi	sp,sp,32
    80004f2e:	8082                	ret

0000000080004f30 <sys_fstat>:
{
    80004f30:	1101                	addi	sp,sp,-32
    80004f32:	ec06                	sd	ra,24(sp)
    80004f34:	e822                	sd	s0,16(sp)
    80004f36:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f38:	fe040593          	addi	a1,s0,-32
    80004f3c:	4505                	li	a0,1
    80004f3e:	b37fd0ef          	jal	80002a74 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f42:	fe840613          	addi	a2,s0,-24
    80004f46:	4581                	li	a1,0
    80004f48:	4501                	li	a0,0
    80004f4a:	cf9ff0ef          	jal	80004c42 <argfd>
    80004f4e:	87aa                	mv	a5,a0
    return -1;
    80004f50:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f52:	0007c863          	bltz	a5,80004f62 <sys_fstat+0x32>
  return filestat(f, st);
    80004f56:	fe043583          	ld	a1,-32(s0)
    80004f5a:	fe843503          	ld	a0,-24(s0)
    80004f5e:	c2cff0ef          	jal	8000438a <filestat>
}
    80004f62:	60e2                	ld	ra,24(sp)
    80004f64:	6442                	ld	s0,16(sp)
    80004f66:	6105                	addi	sp,sp,32
    80004f68:	8082                	ret

0000000080004f6a <sys_link>:
{
    80004f6a:	7169                	addi	sp,sp,-304
    80004f6c:	f606                	sd	ra,296(sp)
    80004f6e:	f222                	sd	s0,288(sp)
    80004f70:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f72:	08000613          	li	a2,128
    80004f76:	ed040593          	addi	a1,s0,-304
    80004f7a:	4501                	li	a0,0
    80004f7c:	b15fd0ef          	jal	80002a90 <argstr>
    return -1;
    80004f80:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f82:	0c054e63          	bltz	a0,8000505e <sys_link+0xf4>
    80004f86:	08000613          	li	a2,128
    80004f8a:	f5040593          	addi	a1,s0,-176
    80004f8e:	4505                	li	a0,1
    80004f90:	b01fd0ef          	jal	80002a90 <argstr>
    return -1;
    80004f94:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f96:	0c054463          	bltz	a0,8000505e <sys_link+0xf4>
    80004f9a:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f9c:	f21fe0ef          	jal	80003ebc <begin_op>
  if((ip = namei(old)) == 0){
    80004fa0:	ed040513          	addi	a0,s0,-304
    80004fa4:	d45fe0ef          	jal	80003ce8 <namei>
    80004fa8:	84aa                	mv	s1,a0
    80004faa:	c53d                	beqz	a0,80005018 <sys_link+0xae>
  ilock(ip);
    80004fac:	d26fe0ef          	jal	800034d2 <ilock>
  if(ip->type == T_DIR){
    80004fb0:	04449703          	lh	a4,68(s1)
    80004fb4:	4785                	li	a5,1
    80004fb6:	06f70663          	beq	a4,a5,80005022 <sys_link+0xb8>
    80004fba:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004fbc:	04a4d783          	lhu	a5,74(s1)
    80004fc0:	2785                	addiw	a5,a5,1
    80004fc2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fc6:	8526                	mv	a0,s1
    80004fc8:	c56fe0ef          	jal	8000341e <iupdate>
  iunlock(ip);
    80004fcc:	8526                	mv	a0,s1
    80004fce:	db2fe0ef          	jal	80003580 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004fd2:	fd040593          	addi	a1,s0,-48
    80004fd6:	f5040513          	addi	a0,s0,-176
    80004fda:	d29fe0ef          	jal	80003d02 <nameiparent>
    80004fde:	892a                	mv	s2,a0
    80004fe0:	cd21                	beqz	a0,80005038 <sys_link+0xce>
  ilock(dp);
    80004fe2:	cf0fe0ef          	jal	800034d2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004fe6:	00092703          	lw	a4,0(s2)
    80004fea:	409c                	lw	a5,0(s1)
    80004fec:	04f71363          	bne	a4,a5,80005032 <sys_link+0xc8>
    80004ff0:	40d0                	lw	a2,4(s1)
    80004ff2:	fd040593          	addi	a1,s0,-48
    80004ff6:	854a                	mv	a0,s2
    80004ff8:	c57fe0ef          	jal	80003c4e <dirlink>
    80004ffc:	02054b63          	bltz	a0,80005032 <sys_link+0xc8>
  iunlockput(dp);
    80005000:	854a                	mv	a0,s2
    80005002:	edafe0ef          	jal	800036dc <iunlockput>
  iput(ip);
    80005006:	8526                	mv	a0,s1
    80005008:	e4cfe0ef          	jal	80003654 <iput>
  end_op();
    8000500c:	f1bfe0ef          	jal	80003f26 <end_op>
  return 0;
    80005010:	4781                	li	a5,0
    80005012:	64f2                	ld	s1,280(sp)
    80005014:	6952                	ld	s2,272(sp)
    80005016:	a0a1                	j	8000505e <sys_link+0xf4>
    end_op();
    80005018:	f0ffe0ef          	jal	80003f26 <end_op>
    return -1;
    8000501c:	57fd                	li	a5,-1
    8000501e:	64f2                	ld	s1,280(sp)
    80005020:	a83d                	j	8000505e <sys_link+0xf4>
    iunlockput(ip);
    80005022:	8526                	mv	a0,s1
    80005024:	eb8fe0ef          	jal	800036dc <iunlockput>
    end_op();
    80005028:	efffe0ef          	jal	80003f26 <end_op>
    return -1;
    8000502c:	57fd                	li	a5,-1
    8000502e:	64f2                	ld	s1,280(sp)
    80005030:	a03d                	j	8000505e <sys_link+0xf4>
    iunlockput(dp);
    80005032:	854a                	mv	a0,s2
    80005034:	ea8fe0ef          	jal	800036dc <iunlockput>
  ilock(ip);
    80005038:	8526                	mv	a0,s1
    8000503a:	c98fe0ef          	jal	800034d2 <ilock>
  ip->nlink--;
    8000503e:	04a4d783          	lhu	a5,74(s1)
    80005042:	37fd                	addiw	a5,a5,-1
    80005044:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005048:	8526                	mv	a0,s1
    8000504a:	bd4fe0ef          	jal	8000341e <iupdate>
  iunlockput(ip);
    8000504e:	8526                	mv	a0,s1
    80005050:	e8cfe0ef          	jal	800036dc <iunlockput>
  end_op();
    80005054:	ed3fe0ef          	jal	80003f26 <end_op>
  return -1;
    80005058:	57fd                	li	a5,-1
    8000505a:	64f2                	ld	s1,280(sp)
    8000505c:	6952                	ld	s2,272(sp)
}
    8000505e:	853e                	mv	a0,a5
    80005060:	70b2                	ld	ra,296(sp)
    80005062:	7412                	ld	s0,288(sp)
    80005064:	6155                	addi	sp,sp,304
    80005066:	8082                	ret

0000000080005068 <sys_unlink>:
{
    80005068:	7151                	addi	sp,sp,-240
    8000506a:	f586                	sd	ra,232(sp)
    8000506c:	f1a2                	sd	s0,224(sp)
    8000506e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005070:	08000613          	li	a2,128
    80005074:	f3040593          	addi	a1,s0,-208
    80005078:	4501                	li	a0,0
    8000507a:	a17fd0ef          	jal	80002a90 <argstr>
    8000507e:	16054063          	bltz	a0,800051de <sys_unlink+0x176>
    80005082:	eda6                	sd	s1,216(sp)
  begin_op();
    80005084:	e39fe0ef          	jal	80003ebc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005088:	fb040593          	addi	a1,s0,-80
    8000508c:	f3040513          	addi	a0,s0,-208
    80005090:	c73fe0ef          	jal	80003d02 <nameiparent>
    80005094:	84aa                	mv	s1,a0
    80005096:	c945                	beqz	a0,80005146 <sys_unlink+0xde>
  ilock(dp);
    80005098:	c3afe0ef          	jal	800034d2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000509c:	00002597          	auipc	a1,0x2
    800050a0:	52c58593          	addi	a1,a1,1324 # 800075c8 <etext+0x5c8>
    800050a4:	fb040513          	addi	a0,s0,-80
    800050a8:	9c5fe0ef          	jal	80003a6c <namecmp>
    800050ac:	10050e63          	beqz	a0,800051c8 <sys_unlink+0x160>
    800050b0:	00002597          	auipc	a1,0x2
    800050b4:	52058593          	addi	a1,a1,1312 # 800075d0 <etext+0x5d0>
    800050b8:	fb040513          	addi	a0,s0,-80
    800050bc:	9b1fe0ef          	jal	80003a6c <namecmp>
    800050c0:	10050463          	beqz	a0,800051c8 <sys_unlink+0x160>
    800050c4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800050c6:	f2c40613          	addi	a2,s0,-212
    800050ca:	fb040593          	addi	a1,s0,-80
    800050ce:	8526                	mv	a0,s1
    800050d0:	9b3fe0ef          	jal	80003a82 <dirlookup>
    800050d4:	892a                	mv	s2,a0
    800050d6:	0e050863          	beqz	a0,800051c6 <sys_unlink+0x15e>
  ilock(ip);
    800050da:	bf8fe0ef          	jal	800034d2 <ilock>
  if(ip->nlink < 1)
    800050de:	04a91783          	lh	a5,74(s2)
    800050e2:	06f05763          	blez	a5,80005150 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800050e6:	04491703          	lh	a4,68(s2)
    800050ea:	4785                	li	a5,1
    800050ec:	06f70963          	beq	a4,a5,8000515e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800050f0:	4641                	li	a2,16
    800050f2:	4581                	li	a1,0
    800050f4:	fc040513          	addi	a0,s0,-64
    800050f8:	babfb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050fc:	4741                	li	a4,16
    800050fe:	f2c42683          	lw	a3,-212(s0)
    80005102:	fc040613          	addi	a2,s0,-64
    80005106:	4581                	li	a1,0
    80005108:	8526                	mv	a0,s1
    8000510a:	855fe0ef          	jal	8000395e <writei>
    8000510e:	47c1                	li	a5,16
    80005110:	08f51b63          	bne	a0,a5,800051a6 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005114:	04491703          	lh	a4,68(s2)
    80005118:	4785                	li	a5,1
    8000511a:	08f70d63          	beq	a4,a5,800051b4 <sys_unlink+0x14c>
  iunlockput(dp);
    8000511e:	8526                	mv	a0,s1
    80005120:	dbcfe0ef          	jal	800036dc <iunlockput>
  ip->nlink--;
    80005124:	04a95783          	lhu	a5,74(s2)
    80005128:	37fd                	addiw	a5,a5,-1
    8000512a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000512e:	854a                	mv	a0,s2
    80005130:	aeefe0ef          	jal	8000341e <iupdate>
  iunlockput(ip);
    80005134:	854a                	mv	a0,s2
    80005136:	da6fe0ef          	jal	800036dc <iunlockput>
  end_op();
    8000513a:	dedfe0ef          	jal	80003f26 <end_op>
  return 0;
    8000513e:	4501                	li	a0,0
    80005140:	64ee                	ld	s1,216(sp)
    80005142:	694e                	ld	s2,208(sp)
    80005144:	a849                	j	800051d6 <sys_unlink+0x16e>
    end_op();
    80005146:	de1fe0ef          	jal	80003f26 <end_op>
    return -1;
    8000514a:	557d                	li	a0,-1
    8000514c:	64ee                	ld	s1,216(sp)
    8000514e:	a061                	j	800051d6 <sys_unlink+0x16e>
    80005150:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005152:	00002517          	auipc	a0,0x2
    80005156:	48650513          	addi	a0,a0,1158 # 800075d8 <etext+0x5d8>
    8000515a:	e86fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000515e:	04c92703          	lw	a4,76(s2)
    80005162:	02000793          	li	a5,32
    80005166:	f8e7f5e3          	bgeu	a5,a4,800050f0 <sys_unlink+0x88>
    8000516a:	e5ce                	sd	s3,200(sp)
    8000516c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005170:	4741                	li	a4,16
    80005172:	86ce                	mv	a3,s3
    80005174:	f1840613          	addi	a2,s0,-232
    80005178:	4581                	li	a1,0
    8000517a:	854a                	mv	a0,s2
    8000517c:	ee6fe0ef          	jal	80003862 <readi>
    80005180:	47c1                	li	a5,16
    80005182:	00f51c63          	bne	a0,a5,8000519a <sys_unlink+0x132>
    if(de.inum != 0)
    80005186:	f1845783          	lhu	a5,-232(s0)
    8000518a:	efa1                	bnez	a5,800051e2 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000518c:	29c1                	addiw	s3,s3,16
    8000518e:	04c92783          	lw	a5,76(s2)
    80005192:	fcf9efe3          	bltu	s3,a5,80005170 <sys_unlink+0x108>
    80005196:	69ae                	ld	s3,200(sp)
    80005198:	bfa1                	j	800050f0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000519a:	00002517          	auipc	a0,0x2
    8000519e:	45650513          	addi	a0,a0,1110 # 800075f0 <etext+0x5f0>
    800051a2:	e3efb0ef          	jal	800007e0 <panic>
    800051a6:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800051a8:	00002517          	auipc	a0,0x2
    800051ac:	46050513          	addi	a0,a0,1120 # 80007608 <etext+0x608>
    800051b0:	e30fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    800051b4:	04a4d783          	lhu	a5,74(s1)
    800051b8:	37fd                	addiw	a5,a5,-1
    800051ba:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051be:	8526                	mv	a0,s1
    800051c0:	a5efe0ef          	jal	8000341e <iupdate>
    800051c4:	bfa9                	j	8000511e <sys_unlink+0xb6>
    800051c6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800051c8:	8526                	mv	a0,s1
    800051ca:	d12fe0ef          	jal	800036dc <iunlockput>
  end_op();
    800051ce:	d59fe0ef          	jal	80003f26 <end_op>
  return -1;
    800051d2:	557d                	li	a0,-1
    800051d4:	64ee                	ld	s1,216(sp)
}
    800051d6:	70ae                	ld	ra,232(sp)
    800051d8:	740e                	ld	s0,224(sp)
    800051da:	616d                	addi	sp,sp,240
    800051dc:	8082                	ret
    return -1;
    800051de:	557d                	li	a0,-1
    800051e0:	bfdd                	j	800051d6 <sys_unlink+0x16e>
    iunlockput(ip);
    800051e2:	854a                	mv	a0,s2
    800051e4:	cf8fe0ef          	jal	800036dc <iunlockput>
    goto bad;
    800051e8:	694e                	ld	s2,208(sp)
    800051ea:	69ae                	ld	s3,200(sp)
    800051ec:	bff1                	j	800051c8 <sys_unlink+0x160>

00000000800051ee <sys_open>:

uint64
sys_open(void)
{
    800051ee:	7131                	addi	sp,sp,-192
    800051f0:	fd06                	sd	ra,184(sp)
    800051f2:	f922                	sd	s0,176(sp)
    800051f4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051f6:	f4c40593          	addi	a1,s0,-180
    800051fa:	4505                	li	a0,1
    800051fc:	85dfd0ef          	jal	80002a58 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005200:	08000613          	li	a2,128
    80005204:	f5040593          	addi	a1,s0,-176
    80005208:	4501                	li	a0,0
    8000520a:	887fd0ef          	jal	80002a90 <argstr>
    8000520e:	87aa                	mv	a5,a0
    return -1;
    80005210:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005212:	0a07c263          	bltz	a5,800052b6 <sys_open+0xc8>
    80005216:	f526                	sd	s1,168(sp)

  begin_op();
    80005218:	ca5fe0ef          	jal	80003ebc <begin_op>

  if(omode & O_CREATE){
    8000521c:	f4c42783          	lw	a5,-180(s0)
    80005220:	2007f793          	andi	a5,a5,512
    80005224:	c3d5                	beqz	a5,800052c8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005226:	4681                	li	a3,0
    80005228:	4601                	li	a2,0
    8000522a:	4589                	li	a1,2
    8000522c:	f5040513          	addi	a0,s0,-176
    80005230:	aa9ff0ef          	jal	80004cd8 <create>
    80005234:	84aa                	mv	s1,a0
    if(ip == 0){
    80005236:	c541                	beqz	a0,800052be <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005238:	04449703          	lh	a4,68(s1)
    8000523c:	478d                	li	a5,3
    8000523e:	00f71763          	bne	a4,a5,8000524c <sys_open+0x5e>
    80005242:	0464d703          	lhu	a4,70(s1)
    80005246:	47a5                	li	a5,9
    80005248:	0ae7ed63          	bltu	a5,a4,80005302 <sys_open+0x114>
    8000524c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000524e:	fd7fe0ef          	jal	80004224 <filealloc>
    80005252:	892a                	mv	s2,a0
    80005254:	c179                	beqz	a0,8000531a <sys_open+0x12c>
    80005256:	ed4e                	sd	s3,152(sp)
    80005258:	a43ff0ef          	jal	80004c9a <fdalloc>
    8000525c:	89aa                	mv	s3,a0
    8000525e:	0a054a63          	bltz	a0,80005312 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005262:	04449703          	lh	a4,68(s1)
    80005266:	478d                	li	a5,3
    80005268:	0cf70263          	beq	a4,a5,8000532c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000526c:	4789                	li	a5,2
    8000526e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005272:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005276:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000527a:	f4c42783          	lw	a5,-180(s0)
    8000527e:	0017c713          	xori	a4,a5,1
    80005282:	8b05                	andi	a4,a4,1
    80005284:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005288:	0037f713          	andi	a4,a5,3
    8000528c:	00e03733          	snez	a4,a4
    80005290:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005294:	4007f793          	andi	a5,a5,1024
    80005298:	c791                	beqz	a5,800052a4 <sys_open+0xb6>
    8000529a:	04449703          	lh	a4,68(s1)
    8000529e:	4789                	li	a5,2
    800052a0:	08f70d63          	beq	a4,a5,8000533a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800052a4:	8526                	mv	a0,s1
    800052a6:	adafe0ef          	jal	80003580 <iunlock>
  end_op();
    800052aa:	c7dfe0ef          	jal	80003f26 <end_op>

  return fd;
    800052ae:	854e                	mv	a0,s3
    800052b0:	74aa                	ld	s1,168(sp)
    800052b2:	790a                	ld	s2,160(sp)
    800052b4:	69ea                	ld	s3,152(sp)
}
    800052b6:	70ea                	ld	ra,184(sp)
    800052b8:	744a                	ld	s0,176(sp)
    800052ba:	6129                	addi	sp,sp,192
    800052bc:	8082                	ret
      end_op();
    800052be:	c69fe0ef          	jal	80003f26 <end_op>
      return -1;
    800052c2:	557d                	li	a0,-1
    800052c4:	74aa                	ld	s1,168(sp)
    800052c6:	bfc5                	j	800052b6 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800052c8:	f5040513          	addi	a0,s0,-176
    800052cc:	a1dfe0ef          	jal	80003ce8 <namei>
    800052d0:	84aa                	mv	s1,a0
    800052d2:	c11d                	beqz	a0,800052f8 <sys_open+0x10a>
    ilock(ip);
    800052d4:	9fefe0ef          	jal	800034d2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800052d8:	04449703          	lh	a4,68(s1)
    800052dc:	4785                	li	a5,1
    800052de:	f4f71de3          	bne	a4,a5,80005238 <sys_open+0x4a>
    800052e2:	f4c42783          	lw	a5,-180(s0)
    800052e6:	d3bd                	beqz	a5,8000524c <sys_open+0x5e>
      iunlockput(ip);
    800052e8:	8526                	mv	a0,s1
    800052ea:	bf2fe0ef          	jal	800036dc <iunlockput>
      end_op();
    800052ee:	c39fe0ef          	jal	80003f26 <end_op>
      return -1;
    800052f2:	557d                	li	a0,-1
    800052f4:	74aa                	ld	s1,168(sp)
    800052f6:	b7c1                	j	800052b6 <sys_open+0xc8>
      end_op();
    800052f8:	c2ffe0ef          	jal	80003f26 <end_op>
      return -1;
    800052fc:	557d                	li	a0,-1
    800052fe:	74aa                	ld	s1,168(sp)
    80005300:	bf5d                	j	800052b6 <sys_open+0xc8>
    iunlockput(ip);
    80005302:	8526                	mv	a0,s1
    80005304:	bd8fe0ef          	jal	800036dc <iunlockput>
    end_op();
    80005308:	c1ffe0ef          	jal	80003f26 <end_op>
    return -1;
    8000530c:	557d                	li	a0,-1
    8000530e:	74aa                	ld	s1,168(sp)
    80005310:	b75d                	j	800052b6 <sys_open+0xc8>
      fileclose(f);
    80005312:	854a                	mv	a0,s2
    80005314:	fb5fe0ef          	jal	800042c8 <fileclose>
    80005318:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000531a:	8526                	mv	a0,s1
    8000531c:	bc0fe0ef          	jal	800036dc <iunlockput>
    end_op();
    80005320:	c07fe0ef          	jal	80003f26 <end_op>
    return -1;
    80005324:	557d                	li	a0,-1
    80005326:	74aa                	ld	s1,168(sp)
    80005328:	790a                	ld	s2,160(sp)
    8000532a:	b771                	j	800052b6 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000532c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005330:	04649783          	lh	a5,70(s1)
    80005334:	02f91223          	sh	a5,36(s2)
    80005338:	bf3d                	j	80005276 <sys_open+0x88>
    itrunc(ip);
    8000533a:	8526                	mv	a0,s1
    8000533c:	a84fe0ef          	jal	800035c0 <itrunc>
    80005340:	b795                	j	800052a4 <sys_open+0xb6>

0000000080005342 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005342:	7175                	addi	sp,sp,-144
    80005344:	e506                	sd	ra,136(sp)
    80005346:	e122                	sd	s0,128(sp)
    80005348:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000534a:	b73fe0ef          	jal	80003ebc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000534e:	08000613          	li	a2,128
    80005352:	f7040593          	addi	a1,s0,-144
    80005356:	4501                	li	a0,0
    80005358:	f38fd0ef          	jal	80002a90 <argstr>
    8000535c:	02054363          	bltz	a0,80005382 <sys_mkdir+0x40>
    80005360:	4681                	li	a3,0
    80005362:	4601                	li	a2,0
    80005364:	4585                	li	a1,1
    80005366:	f7040513          	addi	a0,s0,-144
    8000536a:	96fff0ef          	jal	80004cd8 <create>
    8000536e:	c911                	beqz	a0,80005382 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005370:	b6cfe0ef          	jal	800036dc <iunlockput>
  end_op();
    80005374:	bb3fe0ef          	jal	80003f26 <end_op>
  return 0;
    80005378:	4501                	li	a0,0
}
    8000537a:	60aa                	ld	ra,136(sp)
    8000537c:	640a                	ld	s0,128(sp)
    8000537e:	6149                	addi	sp,sp,144
    80005380:	8082                	ret
    end_op();
    80005382:	ba5fe0ef          	jal	80003f26 <end_op>
    return -1;
    80005386:	557d                	li	a0,-1
    80005388:	bfcd                	j	8000537a <sys_mkdir+0x38>

000000008000538a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000538a:	7135                	addi	sp,sp,-160
    8000538c:	ed06                	sd	ra,152(sp)
    8000538e:	e922                	sd	s0,144(sp)
    80005390:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005392:	b2bfe0ef          	jal	80003ebc <begin_op>
  argint(1, &major);
    80005396:	f6c40593          	addi	a1,s0,-148
    8000539a:	4505                	li	a0,1
    8000539c:	ebcfd0ef          	jal	80002a58 <argint>
  argint(2, &minor);
    800053a0:	f6840593          	addi	a1,s0,-152
    800053a4:	4509                	li	a0,2
    800053a6:	eb2fd0ef          	jal	80002a58 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053aa:	08000613          	li	a2,128
    800053ae:	f7040593          	addi	a1,s0,-144
    800053b2:	4501                	li	a0,0
    800053b4:	edcfd0ef          	jal	80002a90 <argstr>
    800053b8:	02054563          	bltz	a0,800053e2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800053bc:	f6841683          	lh	a3,-152(s0)
    800053c0:	f6c41603          	lh	a2,-148(s0)
    800053c4:	458d                	li	a1,3
    800053c6:	f7040513          	addi	a0,s0,-144
    800053ca:	90fff0ef          	jal	80004cd8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053ce:	c911                	beqz	a0,800053e2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053d0:	b0cfe0ef          	jal	800036dc <iunlockput>
  end_op();
    800053d4:	b53fe0ef          	jal	80003f26 <end_op>
  return 0;
    800053d8:	4501                	li	a0,0
}
    800053da:	60ea                	ld	ra,152(sp)
    800053dc:	644a                	ld	s0,144(sp)
    800053de:	610d                	addi	sp,sp,160
    800053e0:	8082                	ret
    end_op();
    800053e2:	b45fe0ef          	jal	80003f26 <end_op>
    return -1;
    800053e6:	557d                	li	a0,-1
    800053e8:	bfcd                	j	800053da <sys_mknod+0x50>

00000000800053ea <sys_chdir>:

uint64
sys_chdir(void)
{
    800053ea:	7135                	addi	sp,sp,-160
    800053ec:	ed06                	sd	ra,152(sp)
    800053ee:	e922                	sd	s0,144(sp)
    800053f0:	e14a                	sd	s2,128(sp)
    800053f2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053f4:	d5cfc0ef          	jal	80001950 <myproc>
    800053f8:	892a                	mv	s2,a0
  
  begin_op();
    800053fa:	ac3fe0ef          	jal	80003ebc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800053fe:	08000613          	li	a2,128
    80005402:	f6040593          	addi	a1,s0,-160
    80005406:	4501                	li	a0,0
    80005408:	e88fd0ef          	jal	80002a90 <argstr>
    8000540c:	04054363          	bltz	a0,80005452 <sys_chdir+0x68>
    80005410:	e526                	sd	s1,136(sp)
    80005412:	f6040513          	addi	a0,s0,-160
    80005416:	8d3fe0ef          	jal	80003ce8 <namei>
    8000541a:	84aa                	mv	s1,a0
    8000541c:	c915                	beqz	a0,80005450 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000541e:	8b4fe0ef          	jal	800034d2 <ilock>
  if(ip->type != T_DIR){
    80005422:	04449703          	lh	a4,68(s1)
    80005426:	4785                	li	a5,1
    80005428:	02f71963          	bne	a4,a5,8000545a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000542c:	8526                	mv	a0,s1
    8000542e:	952fe0ef          	jal	80003580 <iunlock>
  iput(p->cwd);
    80005432:	15093503          	ld	a0,336(s2)
    80005436:	a1efe0ef          	jal	80003654 <iput>
  end_op();
    8000543a:	aedfe0ef          	jal	80003f26 <end_op>
  p->cwd = ip;
    8000543e:	14993823          	sd	s1,336(s2)
  return 0;
    80005442:	4501                	li	a0,0
    80005444:	64aa                	ld	s1,136(sp)
}
    80005446:	60ea                	ld	ra,152(sp)
    80005448:	644a                	ld	s0,144(sp)
    8000544a:	690a                	ld	s2,128(sp)
    8000544c:	610d                	addi	sp,sp,160
    8000544e:	8082                	ret
    80005450:	64aa                	ld	s1,136(sp)
    end_op();
    80005452:	ad5fe0ef          	jal	80003f26 <end_op>
    return -1;
    80005456:	557d                	li	a0,-1
    80005458:	b7fd                	j	80005446 <sys_chdir+0x5c>
    iunlockput(ip);
    8000545a:	8526                	mv	a0,s1
    8000545c:	a80fe0ef          	jal	800036dc <iunlockput>
    end_op();
    80005460:	ac7fe0ef          	jal	80003f26 <end_op>
    return -1;
    80005464:	557d                	li	a0,-1
    80005466:	64aa                	ld	s1,136(sp)
    80005468:	bff9                	j	80005446 <sys_chdir+0x5c>

000000008000546a <sys_exec>:

uint64
sys_exec(void)
{
    8000546a:	7121                	addi	sp,sp,-448
    8000546c:	ff06                	sd	ra,440(sp)
    8000546e:	fb22                	sd	s0,432(sp)
    80005470:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005472:	e4840593          	addi	a1,s0,-440
    80005476:	4505                	li	a0,1
    80005478:	dfcfd0ef          	jal	80002a74 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000547c:	08000613          	li	a2,128
    80005480:	f5040593          	addi	a1,s0,-176
    80005484:	4501                	li	a0,0
    80005486:	e0afd0ef          	jal	80002a90 <argstr>
    8000548a:	87aa                	mv	a5,a0
    return -1;
    8000548c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000548e:	0c07c463          	bltz	a5,80005556 <sys_exec+0xec>
    80005492:	f726                	sd	s1,424(sp)
    80005494:	f34a                	sd	s2,416(sp)
    80005496:	ef4e                	sd	s3,408(sp)
    80005498:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000549a:	10000613          	li	a2,256
    8000549e:	4581                	li	a1,0
    800054a0:	e5040513          	addi	a0,s0,-432
    800054a4:	ffefb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800054a8:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800054ac:	89a6                	mv	s3,s1
    800054ae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800054b0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800054b4:	00391513          	slli	a0,s2,0x3
    800054b8:	e4040593          	addi	a1,s0,-448
    800054bc:	e4843783          	ld	a5,-440(s0)
    800054c0:	953e                	add	a0,a0,a5
    800054c2:	d0cfd0ef          	jal	800029ce <fetchaddr>
    800054c6:	02054663          	bltz	a0,800054f2 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800054ca:	e4043783          	ld	a5,-448(s0)
    800054ce:	c3a9                	beqz	a5,80005510 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800054d0:	e2efb0ef          	jal	80000afe <kalloc>
    800054d4:	85aa                	mv	a1,a0
    800054d6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800054da:	cd01                	beqz	a0,800054f2 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054dc:	6605                	lui	a2,0x1
    800054de:	e4043503          	ld	a0,-448(s0)
    800054e2:	d36fd0ef          	jal	80002a18 <fetchstr>
    800054e6:	00054663          	bltz	a0,800054f2 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800054ea:	0905                	addi	s2,s2,1
    800054ec:	09a1                	addi	s3,s3,8
    800054ee:	fd4913e3          	bne	s2,s4,800054b4 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054f2:	f5040913          	addi	s2,s0,-176
    800054f6:	6088                	ld	a0,0(s1)
    800054f8:	c931                	beqz	a0,8000554c <sys_exec+0xe2>
    kfree(argv[i]);
    800054fa:	d22fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054fe:	04a1                	addi	s1,s1,8
    80005500:	ff249be3          	bne	s1,s2,800054f6 <sys_exec+0x8c>
  return -1;
    80005504:	557d                	li	a0,-1
    80005506:	74ba                	ld	s1,424(sp)
    80005508:	791a                	ld	s2,416(sp)
    8000550a:	69fa                	ld	s3,408(sp)
    8000550c:	6a5a                	ld	s4,400(sp)
    8000550e:	a0a1                	j	80005556 <sys_exec+0xec>
      argv[i] = 0;
    80005510:	0009079b          	sext.w	a5,s2
    80005514:	078e                	slli	a5,a5,0x3
    80005516:	fd078793          	addi	a5,a5,-48
    8000551a:	97a2                	add	a5,a5,s0
    8000551c:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005520:	e5040593          	addi	a1,s0,-432
    80005524:	f5040513          	addi	a0,s0,-176
    80005528:	ba8ff0ef          	jal	800048d0 <kexec>
    8000552c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000552e:	f5040993          	addi	s3,s0,-176
    80005532:	6088                	ld	a0,0(s1)
    80005534:	c511                	beqz	a0,80005540 <sys_exec+0xd6>
    kfree(argv[i]);
    80005536:	ce6fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000553a:	04a1                	addi	s1,s1,8
    8000553c:	ff349be3          	bne	s1,s3,80005532 <sys_exec+0xc8>
  return ret;
    80005540:	854a                	mv	a0,s2
    80005542:	74ba                	ld	s1,424(sp)
    80005544:	791a                	ld	s2,416(sp)
    80005546:	69fa                	ld	s3,408(sp)
    80005548:	6a5a                	ld	s4,400(sp)
    8000554a:	a031                	j	80005556 <sys_exec+0xec>
  return -1;
    8000554c:	557d                	li	a0,-1
    8000554e:	74ba                	ld	s1,424(sp)
    80005550:	791a                	ld	s2,416(sp)
    80005552:	69fa                	ld	s3,408(sp)
    80005554:	6a5a                	ld	s4,400(sp)
}
    80005556:	70fa                	ld	ra,440(sp)
    80005558:	745a                	ld	s0,432(sp)
    8000555a:	6139                	addi	sp,sp,448
    8000555c:	8082                	ret

000000008000555e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000555e:	7139                	addi	sp,sp,-64
    80005560:	fc06                	sd	ra,56(sp)
    80005562:	f822                	sd	s0,48(sp)
    80005564:	f426                	sd	s1,40(sp)
    80005566:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005568:	be8fc0ef          	jal	80001950 <myproc>
    8000556c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000556e:	fd840593          	addi	a1,s0,-40
    80005572:	4501                	li	a0,0
    80005574:	d00fd0ef          	jal	80002a74 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005578:	fc840593          	addi	a1,s0,-56
    8000557c:	fd040513          	addi	a0,s0,-48
    80005580:	852ff0ef          	jal	800045d2 <pipealloc>
    return -1;
    80005584:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005586:	0a054463          	bltz	a0,8000562e <sys_pipe+0xd0>
  fd0 = -1;
    8000558a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000558e:	fd043503          	ld	a0,-48(s0)
    80005592:	f08ff0ef          	jal	80004c9a <fdalloc>
    80005596:	fca42223          	sw	a0,-60(s0)
    8000559a:	08054163          	bltz	a0,8000561c <sys_pipe+0xbe>
    8000559e:	fc843503          	ld	a0,-56(s0)
    800055a2:	ef8ff0ef          	jal	80004c9a <fdalloc>
    800055a6:	fca42023          	sw	a0,-64(s0)
    800055aa:	06054063          	bltz	a0,8000560a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800055ae:	4691                	li	a3,4
    800055b0:	fc440613          	addi	a2,s0,-60
    800055b4:	fd843583          	ld	a1,-40(s0)
    800055b8:	68a8                	ld	a0,80(s1)
    800055ba:	828fc0ef          	jal	800015e2 <copyout>
    800055be:	00054e63          	bltz	a0,800055da <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800055c2:	4691                	li	a3,4
    800055c4:	fc040613          	addi	a2,s0,-64
    800055c8:	fd843583          	ld	a1,-40(s0)
    800055cc:	0591                	addi	a1,a1,4
    800055ce:	68a8                	ld	a0,80(s1)
    800055d0:	812fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055d4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800055d6:	04055c63          	bgez	a0,8000562e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800055da:	fc442783          	lw	a5,-60(s0)
    800055de:	07e9                	addi	a5,a5,26
    800055e0:	078e                	slli	a5,a5,0x3
    800055e2:	97a6                	add	a5,a5,s1
    800055e4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055e8:	fc042783          	lw	a5,-64(s0)
    800055ec:	07e9                	addi	a5,a5,26
    800055ee:	078e                	slli	a5,a5,0x3
    800055f0:	94be                	add	s1,s1,a5
    800055f2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800055f6:	fd043503          	ld	a0,-48(s0)
    800055fa:	ccffe0ef          	jal	800042c8 <fileclose>
    fileclose(wf);
    800055fe:	fc843503          	ld	a0,-56(s0)
    80005602:	cc7fe0ef          	jal	800042c8 <fileclose>
    return -1;
    80005606:	57fd                	li	a5,-1
    80005608:	a01d                	j	8000562e <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000560a:	fc442783          	lw	a5,-60(s0)
    8000560e:	0007c763          	bltz	a5,8000561c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005612:	07e9                	addi	a5,a5,26
    80005614:	078e                	slli	a5,a5,0x3
    80005616:	97a6                	add	a5,a5,s1
    80005618:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000561c:	fd043503          	ld	a0,-48(s0)
    80005620:	ca9fe0ef          	jal	800042c8 <fileclose>
    fileclose(wf);
    80005624:	fc843503          	ld	a0,-56(s0)
    80005628:	ca1fe0ef          	jal	800042c8 <fileclose>
    return -1;
    8000562c:	57fd                	li	a5,-1
}
    8000562e:	853e                	mv	a0,a5
    80005630:	70e2                	ld	ra,56(sp)
    80005632:	7442                	ld	s0,48(sp)
    80005634:	74a2                	ld	s1,40(sp)
    80005636:	6121                	addi	sp,sp,64
    80005638:	8082                	ret
    8000563a:	0000                	unimp
    8000563c:	0000                	unimp
	...

0000000080005640 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005640:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005642:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005644:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005646:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005648:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000564a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000564c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000564e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005650:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005652:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005654:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005656:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005658:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000565a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000565c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000565e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005660:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005662:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005664:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005666:	a78fd0ef          	jal	800028de <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000566a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000566c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000566e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005670:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005672:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005674:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005676:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005678:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000567a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000567c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000567e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005680:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005682:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005684:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005686:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005688:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000568a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000568c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000568e:	10200073          	sret
	...

000000008000569e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000569e:	1141                	addi	sp,sp,-16
    800056a0:	e422                	sd	s0,8(sp)
    800056a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800056a4:	0c0007b7          	lui	a5,0xc000
    800056a8:	4705                	li	a4,1
    800056aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800056ac:	0c0007b7          	lui	a5,0xc000
    800056b0:	c3d8                	sw	a4,4(a5)
}
    800056b2:	6422                	ld	s0,8(sp)
    800056b4:	0141                	addi	sp,sp,16
    800056b6:	8082                	ret

00000000800056b8 <plicinithart>:

void
plicinithart(void)
{
    800056b8:	1141                	addi	sp,sp,-16
    800056ba:	e406                	sd	ra,8(sp)
    800056bc:	e022                	sd	s0,0(sp)
    800056be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056c0:	a64fc0ef          	jal	80001924 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800056c4:	0085171b          	slliw	a4,a0,0x8
    800056c8:	0c0027b7          	lui	a5,0xc002
    800056cc:	97ba                	add	a5,a5,a4
    800056ce:	40200713          	li	a4,1026
    800056d2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800056d6:	00d5151b          	slliw	a0,a0,0xd
    800056da:	0c2017b7          	lui	a5,0xc201
    800056de:	97aa                	add	a5,a5,a0
    800056e0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800056e4:	60a2                	ld	ra,8(sp)
    800056e6:	6402                	ld	s0,0(sp)
    800056e8:	0141                	addi	sp,sp,16
    800056ea:	8082                	ret

00000000800056ec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056ec:	1141                	addi	sp,sp,-16
    800056ee:	e406                	sd	ra,8(sp)
    800056f0:	e022                	sd	s0,0(sp)
    800056f2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056f4:	a30fc0ef          	jal	80001924 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800056f8:	00d5151b          	slliw	a0,a0,0xd
    800056fc:	0c2017b7          	lui	a5,0xc201
    80005700:	97aa                	add	a5,a5,a0
  return irq;
}
    80005702:	43c8                	lw	a0,4(a5)
    80005704:	60a2                	ld	ra,8(sp)
    80005706:	6402                	ld	s0,0(sp)
    80005708:	0141                	addi	sp,sp,16
    8000570a:	8082                	ret

000000008000570c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000570c:	1101                	addi	sp,sp,-32
    8000570e:	ec06                	sd	ra,24(sp)
    80005710:	e822                	sd	s0,16(sp)
    80005712:	e426                	sd	s1,8(sp)
    80005714:	1000                	addi	s0,sp,32
    80005716:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005718:	a0cfc0ef          	jal	80001924 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000571c:	00d5151b          	slliw	a0,a0,0xd
    80005720:	0c2017b7          	lui	a5,0xc201
    80005724:	97aa                	add	a5,a5,a0
    80005726:	c3c4                	sw	s1,4(a5)
}
    80005728:	60e2                	ld	ra,24(sp)
    8000572a:	6442                	ld	s0,16(sp)
    8000572c:	64a2                	ld	s1,8(sp)
    8000572e:	6105                	addi	sp,sp,32
    80005730:	8082                	ret

0000000080005732 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005732:	1141                	addi	sp,sp,-16
    80005734:	e406                	sd	ra,8(sp)
    80005736:	e022                	sd	s0,0(sp)
    80005738:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000573a:	479d                	li	a5,7
    8000573c:	04a7ca63          	blt	a5,a0,80005790 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005740:	0001e797          	auipc	a5,0x1e
    80005744:	19078793          	addi	a5,a5,400 # 800238d0 <disk>
    80005748:	97aa                	add	a5,a5,a0
    8000574a:	0187c783          	lbu	a5,24(a5)
    8000574e:	e7b9                	bnez	a5,8000579c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005750:	00451693          	slli	a3,a0,0x4
    80005754:	0001e797          	auipc	a5,0x1e
    80005758:	17c78793          	addi	a5,a5,380 # 800238d0 <disk>
    8000575c:	6398                	ld	a4,0(a5)
    8000575e:	9736                	add	a4,a4,a3
    80005760:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005764:	6398                	ld	a4,0(a5)
    80005766:	9736                	add	a4,a4,a3
    80005768:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000576c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005770:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005774:	97aa                	add	a5,a5,a0
    80005776:	4705                	li	a4,1
    80005778:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000577c:	0001e517          	auipc	a0,0x1e
    80005780:	16c50513          	addi	a0,a0,364 # 800238e8 <disk+0x18>
    80005784:	9affc0ef          	jal	80002132 <wakeup>
}
    80005788:	60a2                	ld	ra,8(sp)
    8000578a:	6402                	ld	s0,0(sp)
    8000578c:	0141                	addi	sp,sp,16
    8000578e:	8082                	ret
    panic("free_desc 1");
    80005790:	00002517          	auipc	a0,0x2
    80005794:	e8850513          	addi	a0,a0,-376 # 80007618 <etext+0x618>
    80005798:	848fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000579c:	00002517          	auipc	a0,0x2
    800057a0:	e8c50513          	addi	a0,a0,-372 # 80007628 <etext+0x628>
    800057a4:	83cfb0ef          	jal	800007e0 <panic>

00000000800057a8 <virtio_disk_init>:
{
    800057a8:	1101                	addi	sp,sp,-32
    800057aa:	ec06                	sd	ra,24(sp)
    800057ac:	e822                	sd	s0,16(sp)
    800057ae:	e426                	sd	s1,8(sp)
    800057b0:	e04a                	sd	s2,0(sp)
    800057b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800057b4:	00002597          	auipc	a1,0x2
    800057b8:	e8458593          	addi	a1,a1,-380 # 80007638 <etext+0x638>
    800057bc:	0001e517          	auipc	a0,0x1e
    800057c0:	23c50513          	addi	a0,a0,572 # 800239f8 <disk+0x128>
    800057c4:	b8afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057c8:	100017b7          	lui	a5,0x10001
    800057cc:	4398                	lw	a4,0(a5)
    800057ce:	2701                	sext.w	a4,a4
    800057d0:	747277b7          	lui	a5,0x74727
    800057d4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800057d8:	18f71063          	bne	a4,a5,80005958 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057dc:	100017b7          	lui	a5,0x10001
    800057e0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800057e2:	439c                	lw	a5,0(a5)
    800057e4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057e6:	4709                	li	a4,2
    800057e8:	16e79863          	bne	a5,a4,80005958 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057ec:	100017b7          	lui	a5,0x10001
    800057f0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800057f2:	439c                	lw	a5,0(a5)
    800057f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057f6:	16e79163          	bne	a5,a4,80005958 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800057fa:	100017b7          	lui	a5,0x10001
    800057fe:	47d8                	lw	a4,12(a5)
    80005800:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005802:	554d47b7          	lui	a5,0x554d4
    80005806:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000580a:	14f71763          	bne	a4,a5,80005958 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000580e:	100017b7          	lui	a5,0x10001
    80005812:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005816:	4705                	li	a4,1
    80005818:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000581a:	470d                	li	a4,3
    8000581c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000581e:	10001737          	lui	a4,0x10001
    80005822:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005824:	c7ffe737          	lui	a4,0xc7ffe
    80005828:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad4f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000582c:	8ef9                	and	a3,a3,a4
    8000582e:	10001737          	lui	a4,0x10001
    80005832:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005834:	472d                	li	a4,11
    80005836:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005838:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000583c:	439c                	lw	a5,0(a5)
    8000583e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005842:	8ba1                	andi	a5,a5,8
    80005844:	12078063          	beqz	a5,80005964 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005848:	100017b7          	lui	a5,0x10001
    8000584c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005850:	100017b7          	lui	a5,0x10001
    80005854:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005858:	439c                	lw	a5,0(a5)
    8000585a:	2781                	sext.w	a5,a5
    8000585c:	10079a63          	bnez	a5,80005970 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005860:	100017b7          	lui	a5,0x10001
    80005864:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005868:	439c                	lw	a5,0(a5)
    8000586a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000586c:	10078863          	beqz	a5,8000597c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005870:	471d                	li	a4,7
    80005872:	10f77b63          	bgeu	a4,a5,80005988 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005876:	a88fb0ef          	jal	80000afe <kalloc>
    8000587a:	0001e497          	auipc	s1,0x1e
    8000587e:	05648493          	addi	s1,s1,86 # 800238d0 <disk>
    80005882:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005884:	a7afb0ef          	jal	80000afe <kalloc>
    80005888:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000588a:	a74fb0ef          	jal	80000afe <kalloc>
    8000588e:	87aa                	mv	a5,a0
    80005890:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005892:	6088                	ld	a0,0(s1)
    80005894:	10050063          	beqz	a0,80005994 <virtio_disk_init+0x1ec>
    80005898:	0001e717          	auipc	a4,0x1e
    8000589c:	04073703          	ld	a4,64(a4) # 800238d8 <disk+0x8>
    800058a0:	0e070a63          	beqz	a4,80005994 <virtio_disk_init+0x1ec>
    800058a4:	0e078863          	beqz	a5,80005994 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800058a8:	6605                	lui	a2,0x1
    800058aa:	4581                	li	a1,0
    800058ac:	bf6fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800058b0:	0001e497          	auipc	s1,0x1e
    800058b4:	02048493          	addi	s1,s1,32 # 800238d0 <disk>
    800058b8:	6605                	lui	a2,0x1
    800058ba:	4581                	li	a1,0
    800058bc:	6488                	ld	a0,8(s1)
    800058be:	be4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800058c2:	6605                	lui	a2,0x1
    800058c4:	4581                	li	a1,0
    800058c6:	6888                	ld	a0,16(s1)
    800058c8:	bdafb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800058cc:	100017b7          	lui	a5,0x10001
    800058d0:	4721                	li	a4,8
    800058d2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800058d4:	4098                	lw	a4,0(s1)
    800058d6:	100017b7          	lui	a5,0x10001
    800058da:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800058de:	40d8                	lw	a4,4(s1)
    800058e0:	100017b7          	lui	a5,0x10001
    800058e4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800058e8:	649c                	ld	a5,8(s1)
    800058ea:	0007869b          	sext.w	a3,a5
    800058ee:	10001737          	lui	a4,0x10001
    800058f2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058f6:	9781                	srai	a5,a5,0x20
    800058f8:	10001737          	lui	a4,0x10001
    800058fc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005900:	689c                	ld	a5,16(s1)
    80005902:	0007869b          	sext.w	a3,a5
    80005906:	10001737          	lui	a4,0x10001
    8000590a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000590e:	9781                	srai	a5,a5,0x20
    80005910:	10001737          	lui	a4,0x10001
    80005914:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005918:	10001737          	lui	a4,0x10001
    8000591c:	4785                	li	a5,1
    8000591e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005920:	00f48c23          	sb	a5,24(s1)
    80005924:	00f48ca3          	sb	a5,25(s1)
    80005928:	00f48d23          	sb	a5,26(s1)
    8000592c:	00f48da3          	sb	a5,27(s1)
    80005930:	00f48e23          	sb	a5,28(s1)
    80005934:	00f48ea3          	sb	a5,29(s1)
    80005938:	00f48f23          	sb	a5,30(s1)
    8000593c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005940:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005944:	100017b7          	lui	a5,0x10001
    80005948:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000594c:	60e2                	ld	ra,24(sp)
    8000594e:	6442                	ld	s0,16(sp)
    80005950:	64a2                	ld	s1,8(sp)
    80005952:	6902                	ld	s2,0(sp)
    80005954:	6105                	addi	sp,sp,32
    80005956:	8082                	ret
    panic("could not find virtio disk");
    80005958:	00002517          	auipc	a0,0x2
    8000595c:	cf050513          	addi	a0,a0,-784 # 80007648 <etext+0x648>
    80005960:	e81fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005964:	00002517          	auipc	a0,0x2
    80005968:	d0450513          	addi	a0,a0,-764 # 80007668 <etext+0x668>
    8000596c:	e75fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005970:	00002517          	auipc	a0,0x2
    80005974:	d1850513          	addi	a0,a0,-744 # 80007688 <etext+0x688>
    80005978:	e69fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000597c:	00002517          	auipc	a0,0x2
    80005980:	d2c50513          	addi	a0,a0,-724 # 800076a8 <etext+0x6a8>
    80005984:	e5dfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005988:	00002517          	auipc	a0,0x2
    8000598c:	d4050513          	addi	a0,a0,-704 # 800076c8 <etext+0x6c8>
    80005990:	e51fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005994:	00002517          	auipc	a0,0x2
    80005998:	d5450513          	addi	a0,a0,-684 # 800076e8 <etext+0x6e8>
    8000599c:	e45fa0ef          	jal	800007e0 <panic>

00000000800059a0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800059a0:	7159                	addi	sp,sp,-112
    800059a2:	f486                	sd	ra,104(sp)
    800059a4:	f0a2                	sd	s0,96(sp)
    800059a6:	eca6                	sd	s1,88(sp)
    800059a8:	e8ca                	sd	s2,80(sp)
    800059aa:	e4ce                	sd	s3,72(sp)
    800059ac:	e0d2                	sd	s4,64(sp)
    800059ae:	fc56                	sd	s5,56(sp)
    800059b0:	f85a                	sd	s6,48(sp)
    800059b2:	f45e                	sd	s7,40(sp)
    800059b4:	f062                	sd	s8,32(sp)
    800059b6:	ec66                	sd	s9,24(sp)
    800059b8:	1880                	addi	s0,sp,112
    800059ba:	8a2a                	mv	s4,a0
    800059bc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800059be:	00c52c83          	lw	s9,12(a0)
    800059c2:	001c9c9b          	slliw	s9,s9,0x1
    800059c6:	1c82                	slli	s9,s9,0x20
    800059c8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800059cc:	0001e517          	auipc	a0,0x1e
    800059d0:	02c50513          	addi	a0,a0,44 # 800239f8 <disk+0x128>
    800059d4:	9fafb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800059d8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800059da:	44a1                	li	s1,8
      disk.free[i] = 0;
    800059dc:	0001eb17          	auipc	s6,0x1e
    800059e0:	ef4b0b13          	addi	s6,s6,-268 # 800238d0 <disk>
  for(int i = 0; i < 3; i++){
    800059e4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059e6:	0001ec17          	auipc	s8,0x1e
    800059ea:	012c0c13          	addi	s8,s8,18 # 800239f8 <disk+0x128>
    800059ee:	a8b9                	j	80005a4c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800059f0:	00fb0733          	add	a4,s6,a5
    800059f4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800059f8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800059fa:	0207c563          	bltz	a5,80005a24 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800059fe:	2905                	addiw	s2,s2,1
    80005a00:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a02:	05590963          	beq	s2,s5,80005a54 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005a06:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005a08:	0001e717          	auipc	a4,0x1e
    80005a0c:	ec870713          	addi	a4,a4,-312 # 800238d0 <disk>
    80005a10:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005a12:	01874683          	lbu	a3,24(a4)
    80005a16:	fee9                	bnez	a3,800059f0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005a18:	2785                	addiw	a5,a5,1
    80005a1a:	0705                	addi	a4,a4,1
    80005a1c:	fe979be3          	bne	a5,s1,80005a12 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005a20:	57fd                	li	a5,-1
    80005a22:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005a24:	01205d63          	blez	s2,80005a3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a28:	f9042503          	lw	a0,-112(s0)
    80005a2c:	d07ff0ef          	jal	80005732 <free_desc>
      for(int j = 0; j < i; j++)
    80005a30:	4785                	li	a5,1
    80005a32:	0127d663          	bge	a5,s2,80005a3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a36:	f9442503          	lw	a0,-108(s0)
    80005a3a:	cf9ff0ef          	jal	80005732 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a3e:	85e2                	mv	a1,s8
    80005a40:	0001e517          	auipc	a0,0x1e
    80005a44:	ea850513          	addi	a0,a0,-344 # 800238e8 <disk+0x18>
    80005a48:	e9efc0ef          	jal	800020e6 <sleep>
  for(int i = 0; i < 3; i++){
    80005a4c:	f9040613          	addi	a2,s0,-112
    80005a50:	894e                	mv	s2,s3
    80005a52:	bf55                	j	80005a06 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a54:	f9042503          	lw	a0,-112(s0)
    80005a58:	00451693          	slli	a3,a0,0x4

  if(write)
    80005a5c:	0001e797          	auipc	a5,0x1e
    80005a60:	e7478793          	addi	a5,a5,-396 # 800238d0 <disk>
    80005a64:	00a50713          	addi	a4,a0,10
    80005a68:	0712                	slli	a4,a4,0x4
    80005a6a:	973e                	add	a4,a4,a5
    80005a6c:	01703633          	snez	a2,s7
    80005a70:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a72:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a76:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a7a:	6398                	ld	a4,0(a5)
    80005a7c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a7e:	0a868613          	addi	a2,a3,168
    80005a82:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a84:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a86:	6390                	ld	a2,0(a5)
    80005a88:	00d605b3          	add	a1,a2,a3
    80005a8c:	4741                	li	a4,16
    80005a8e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a90:	4805                	li	a6,1
    80005a92:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a96:	f9442703          	lw	a4,-108(s0)
    80005a9a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a9e:	0712                	slli	a4,a4,0x4
    80005aa0:	963a                	add	a2,a2,a4
    80005aa2:	058a0593          	addi	a1,s4,88
    80005aa6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005aa8:	0007b883          	ld	a7,0(a5)
    80005aac:	9746                	add	a4,a4,a7
    80005aae:	40000613          	li	a2,1024
    80005ab2:	c710                	sw	a2,8(a4)
  if(write)
    80005ab4:	001bb613          	seqz	a2,s7
    80005ab8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005abc:	00166613          	ori	a2,a2,1
    80005ac0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005ac4:	f9842583          	lw	a1,-104(s0)
    80005ac8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005acc:	00250613          	addi	a2,a0,2
    80005ad0:	0612                	slli	a2,a2,0x4
    80005ad2:	963e                	add	a2,a2,a5
    80005ad4:	577d                	li	a4,-1
    80005ad6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005ada:	0592                	slli	a1,a1,0x4
    80005adc:	98ae                	add	a7,a7,a1
    80005ade:	03068713          	addi	a4,a3,48
    80005ae2:	973e                	add	a4,a4,a5
    80005ae4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005ae8:	6398                	ld	a4,0(a5)
    80005aea:	972e                	add	a4,a4,a1
    80005aec:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005af0:	4689                	li	a3,2
    80005af2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005af6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005afa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005afe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b02:	6794                	ld	a3,8(a5)
    80005b04:	0026d703          	lhu	a4,2(a3)
    80005b08:	8b1d                	andi	a4,a4,7
    80005b0a:	0706                	slli	a4,a4,0x1
    80005b0c:	96ba                	add	a3,a3,a4
    80005b0e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005b12:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b16:	6798                	ld	a4,8(a5)
    80005b18:	00275783          	lhu	a5,2(a4)
    80005b1c:	2785                	addiw	a5,a5,1
    80005b1e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005b22:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b26:	100017b7          	lui	a5,0x10001
    80005b2a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005b2e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005b32:	0001e917          	auipc	s2,0x1e
    80005b36:	ec690913          	addi	s2,s2,-314 # 800239f8 <disk+0x128>
  while(b->disk == 1) {
    80005b3a:	4485                	li	s1,1
    80005b3c:	01079a63          	bne	a5,a6,80005b50 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005b40:	85ca                	mv	a1,s2
    80005b42:	8552                	mv	a0,s4
    80005b44:	da2fc0ef          	jal	800020e6 <sleep>
  while(b->disk == 1) {
    80005b48:	004a2783          	lw	a5,4(s4)
    80005b4c:	fe978ae3          	beq	a5,s1,80005b40 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005b50:	f9042903          	lw	s2,-112(s0)
    80005b54:	00290713          	addi	a4,s2,2
    80005b58:	0712                	slli	a4,a4,0x4
    80005b5a:	0001e797          	auipc	a5,0x1e
    80005b5e:	d7678793          	addi	a5,a5,-650 # 800238d0 <disk>
    80005b62:	97ba                	add	a5,a5,a4
    80005b64:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b68:	0001e997          	auipc	s3,0x1e
    80005b6c:	d6898993          	addi	s3,s3,-664 # 800238d0 <disk>
    80005b70:	00491713          	slli	a4,s2,0x4
    80005b74:	0009b783          	ld	a5,0(s3)
    80005b78:	97ba                	add	a5,a5,a4
    80005b7a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b7e:	854a                	mv	a0,s2
    80005b80:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b84:	bafff0ef          	jal	80005732 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005b88:	8885                	andi	s1,s1,1
    80005b8a:	f0fd                	bnez	s1,80005b70 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b8c:	0001e517          	auipc	a0,0x1e
    80005b90:	e6c50513          	addi	a0,a0,-404 # 800239f8 <disk+0x128>
    80005b94:	8d2fb0ef          	jal	80000c66 <release>
}
    80005b98:	70a6                	ld	ra,104(sp)
    80005b9a:	7406                	ld	s0,96(sp)
    80005b9c:	64e6                	ld	s1,88(sp)
    80005b9e:	6946                	ld	s2,80(sp)
    80005ba0:	69a6                	ld	s3,72(sp)
    80005ba2:	6a06                	ld	s4,64(sp)
    80005ba4:	7ae2                	ld	s5,56(sp)
    80005ba6:	7b42                	ld	s6,48(sp)
    80005ba8:	7ba2                	ld	s7,40(sp)
    80005baa:	7c02                	ld	s8,32(sp)
    80005bac:	6ce2                	ld	s9,24(sp)
    80005bae:	6165                	addi	sp,sp,112
    80005bb0:	8082                	ret

0000000080005bb2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005bb2:	1101                	addi	sp,sp,-32
    80005bb4:	ec06                	sd	ra,24(sp)
    80005bb6:	e822                	sd	s0,16(sp)
    80005bb8:	e426                	sd	s1,8(sp)
    80005bba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005bbc:	0001e497          	auipc	s1,0x1e
    80005bc0:	d1448493          	addi	s1,s1,-748 # 800238d0 <disk>
    80005bc4:	0001e517          	auipc	a0,0x1e
    80005bc8:	e3450513          	addi	a0,a0,-460 # 800239f8 <disk+0x128>
    80005bcc:	802fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005bd0:	100017b7          	lui	a5,0x10001
    80005bd4:	53b8                	lw	a4,96(a5)
    80005bd6:	8b0d                	andi	a4,a4,3
    80005bd8:	100017b7          	lui	a5,0x10001
    80005bdc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005bde:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005be2:	689c                	ld	a5,16(s1)
    80005be4:	0204d703          	lhu	a4,32(s1)
    80005be8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005bec:	04f70663          	beq	a4,a5,80005c38 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005bf0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005bf4:	6898                	ld	a4,16(s1)
    80005bf6:	0204d783          	lhu	a5,32(s1)
    80005bfa:	8b9d                	andi	a5,a5,7
    80005bfc:	078e                	slli	a5,a5,0x3
    80005bfe:	97ba                	add	a5,a5,a4
    80005c00:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005c02:	00278713          	addi	a4,a5,2
    80005c06:	0712                	slli	a4,a4,0x4
    80005c08:	9726                	add	a4,a4,s1
    80005c0a:	01074703          	lbu	a4,16(a4)
    80005c0e:	e321                	bnez	a4,80005c4e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c10:	0789                	addi	a5,a5,2
    80005c12:	0792                	slli	a5,a5,0x4
    80005c14:	97a6                	add	a5,a5,s1
    80005c16:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005c18:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c1c:	d16fc0ef          	jal	80002132 <wakeup>

    disk.used_idx += 1;
    80005c20:	0204d783          	lhu	a5,32(s1)
    80005c24:	2785                	addiw	a5,a5,1
    80005c26:	17c2                	slli	a5,a5,0x30
    80005c28:	93c1                	srli	a5,a5,0x30
    80005c2a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005c2e:	6898                	ld	a4,16(s1)
    80005c30:	00275703          	lhu	a4,2(a4)
    80005c34:	faf71ee3          	bne	a4,a5,80005bf0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c38:	0001e517          	auipc	a0,0x1e
    80005c3c:	dc050513          	addi	a0,a0,-576 # 800239f8 <disk+0x128>
    80005c40:	826fb0ef          	jal	80000c66 <release>
}
    80005c44:	60e2                	ld	ra,24(sp)
    80005c46:	6442                	ld	s0,16(sp)
    80005c48:	64a2                	ld	s1,8(sp)
    80005c4a:	6105                	addi	sp,sp,32
    80005c4c:	8082                	ret
      panic("virtio_disk_intr status");
    80005c4e:	00002517          	auipc	a0,0x2
    80005c52:	ab250513          	addi	a0,a0,-1358 # 80007700 <etext+0x700>
    80005c56:	b8bfa0ef          	jal	800007e0 <panic>
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
