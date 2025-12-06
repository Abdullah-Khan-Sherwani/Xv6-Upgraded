
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
    80000112:	3da020ef          	jal	800024ec <either_copyin>
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
    800001bc:	1c2020ef          	jal	8000237e <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	749010ef          	jal	8000210e <sleep>
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
    8000020a:	298020ef          	jal	800024a2 <either_copyout>
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
    800002d8:	25e020ef          	jal	80002536 <procdump>
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
    8000041e:	53d010ef          	jal	8000215a <wakeup>
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
    800008ea:	025010ef          	jal	8000210e <sleep>
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
    80000a00:	75a010ef          	jal	8000215a <wakeup>
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
    80000e72:	7f6010ef          	jal	80002668 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	073040ef          	jal	800056e8 <plicinithart>
  }

  scheduler();        
    80000e7a:	060010ef          	jal	80001eda <scheduler>
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
    80000eba:	78a010ef          	jal	80002644 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	7aa010ef          	jal	80002668 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	00d040ef          	jal	800056ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	023040ef          	jal	800056e8 <plicinithart>
    binit();         // buffer cache
    80000eca:	6df010ef          	jal	80002da8 <binit>
    iinit();         // inode table
    80000ece:	464020ef          	jal	80003332 <iinit>
    fileinit();      // file table
    80000ed2:	356030ef          	jal	80004228 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	103040ef          	jal	800057d8 <virtio_disk_init>
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
    800019a0:	64f010ef          	jal	800037ee <fsinit>

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
    800019c4:	735020ef          	jal	800048f8 <kexec>
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
    800019d6:	4ab000ef          	jal	80002680 <prepare_return>
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
    80001c44:	0cc020ef          	jal	80003d10 <namei>
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
    80001d7c:	52e020ef          	jal	800042aa <filedup>
    80001d80:	00a93023          	sd	a0,0(s2)
    80001d84:	b7f5                	j	80001d70 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001d86:	150ab503          	ld	a0,336(s5)
    80001d8a:	73a010ef          	jal	800034c4 <idup>
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
    80001e12:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e14:	00011497          	auipc	s1,0x11
    80001e18:	a1c48493          	addi	s1,s1,-1508 # 80012830 <proc>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001e1c:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e1e:	00017917          	auipc	s2,0x17
    80001e22:	81290913          	addi	s2,s2,-2030 # 80018630 <tickslock>
    80001e26:	a801                	j	80001e36 <boost_all_priorities+0x30>
    release(&p->lock);
    80001e28:	8526                	mv	a0,s1
    80001e2a:	e3dfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e2e:	17848493          	addi	s1,s1,376
    80001e32:	03248063          	beq	s1,s2,80001e52 <boost_all_priorities+0x4c>
    acquire(&p->lock);
    80001e36:	8526                	mv	a0,s1
    80001e38:	d97fe0ef          	jal	80000bce <acquire>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001e3c:	4c9c                	lw	a5,24(s1)
    80001e3e:	37f9                	addiw	a5,a5,-2
    80001e40:	fef9e4e3          	bltu	s3,a5,80001e28 <boost_all_priorities+0x22>
      p->priority = 0;
    80001e44:	1604a423          	sw	zero,360(s1)
      p->time_slices = 0;
    80001e48:	1604a623          	sw	zero,364(s1)
      p->queue_next = 0;
    80001e4c:	1604b823          	sd	zero,368(s1)
    80001e50:	bfe1                	j	80001e28 <boost_all_priorities+0x22>
  acquire(&mlfq_lock);
    80001e52:	00010497          	auipc	s1,0x10
    80001e56:	55648493          	addi	s1,s1,1366 # 800123a8 <mlfq_tails>
    80001e5a:	00010517          	auipc	a0,0x10
    80001e5e:	5be50513          	addi	a0,a0,1470 # 80012418 <mlfq_lock>
    80001e62:	d6dfe0ef          	jal	80000bce <acquire>
    mlfq_heads[i] = 0;
    80001e66:	0204b023          	sd	zero,32(s1)
    mlfq_tails[i] = 0;
    80001e6a:	0004b023          	sd	zero,0(s1)
    mlfq_heads[i] = 0;
    80001e6e:	0204b423          	sd	zero,40(s1)
    mlfq_tails[i] = 0;
    80001e72:	0004b423          	sd	zero,8(s1)
    mlfq_heads[i] = 0;
    80001e76:	0204b823          	sd	zero,48(s1)
    mlfq_tails[i] = 0;
    80001e7a:	0004b823          	sd	zero,16(s1)
    mlfq_heads[i] = 0;
    80001e7e:	0204bc23          	sd	zero,56(s1)
    mlfq_tails[i] = 0;
    80001e82:	0004bc23          	sd	zero,24(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e86:	00011497          	auipc	s1,0x11
    80001e8a:	9aa48493          	addi	s1,s1,-1622 # 80012830 <proc>
    if(p->state == RUNNABLE) {
    80001e8e:	498d                	li	s3,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e90:	00016917          	auipc	s2,0x16
    80001e94:	7a090913          	addi	s2,s2,1952 # 80018630 <tickslock>
    80001e98:	a801                	j	80001ea8 <boost_all_priorities+0xa2>
    release(&p->lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	dcbfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ea0:	17848493          	addi	s1,s1,376
    80001ea4:	01248e63          	beq	s1,s2,80001ec0 <boost_all_priorities+0xba>
    acquire(&p->lock);
    80001ea8:	8526                	mv	a0,s1
    80001eaa:	d25fe0ef          	jal	80000bce <acquire>
    if(p->state == RUNNABLE) {
    80001eae:	4c9c                	lw	a5,24(s1)
    80001eb0:	ff3795e3          	bne	a5,s3,80001e9a <boost_all_priorities+0x94>
      p->queue_next = 0;
    80001eb4:	1604b823          	sd	zero,368(s1)
      mlfq_enqueue(p);
    80001eb8:	8526                	mv	a0,s1
    80001eba:	89bff0ef          	jal	80001754 <mlfq_enqueue>
    80001ebe:	bff1                	j	80001e9a <boost_all_priorities+0x94>
  release(&mlfq_lock);
    80001ec0:	00010517          	auipc	a0,0x10
    80001ec4:	55850513          	addi	a0,a0,1368 # 80012418 <mlfq_lock>
    80001ec8:	d9ffe0ef          	jal	80000c66 <release>
}
    80001ecc:	70a2                	ld	ra,40(sp)
    80001ece:	7402                	ld	s0,32(sp)
    80001ed0:	64e2                	ld	s1,24(sp)
    80001ed2:	6942                	ld	s2,16(sp)
    80001ed4:	69a2                	ld	s3,8(sp)
    80001ed6:	6145                	addi	sp,sp,48
    80001ed8:	8082                	ret

0000000080001eda <scheduler>:
{
    80001eda:	7159                	addi	sp,sp,-112
    80001edc:	f486                	sd	ra,104(sp)
    80001ede:	f0a2                	sd	s0,96(sp)
    80001ee0:	eca6                	sd	s1,88(sp)
    80001ee2:	e8ca                	sd	s2,80(sp)
    80001ee4:	e4ce                	sd	s3,72(sp)
    80001ee6:	e0d2                	sd	s4,64(sp)
    80001ee8:	fc56                	sd	s5,56(sp)
    80001eea:	f85a                	sd	s6,48(sp)
    80001eec:	f45e                	sd	s7,40(sp)
    80001eee:	f062                	sd	s8,32(sp)
    80001ef0:	ec66                	sd	s9,24(sp)
    80001ef2:	e86a                	sd	s10,16(sp)
    80001ef4:	e46e                	sd	s11,8(sp)
    80001ef6:	1880                	addi	s0,sp,112
    80001ef8:	8c92                	mv	s9,tp
  int id = r_tp();
    80001efa:	2c81                	sext.w	s9,s9
  c->proc = 0;
    80001efc:	007c9713          	slli	a4,s9,0x7
    80001f00:	00010797          	auipc	a5,0x10
    80001f04:	4a878793          	addi	a5,a5,1192 # 800123a8 <mlfq_tails>
    80001f08:	97ba                	add	a5,a5,a4
    80001f0a:	0807b423          	sd	zero,136(a5)
    acquire(&tickslock);
    80001f0e:	00016a97          	auipc	s5,0x16
    80001f12:	722a8a93          	addi	s5,s5,1826 # 80018630 <tickslock>
    acquire(&mlfq_lock);
    80001f16:	00010917          	auipc	s2,0x10
    80001f1a:	50290913          	addi	s2,s2,1282 # 80012418 <mlfq_lock>
  mlfq_heads[priority] = p->queue_next;
    80001f1e:	00010a17          	auipc	s4,0x10
    80001f22:	48aa0a13          	addi	s4,s4,1162 # 800123a8 <mlfq_tails>
          c->proc = p;
    80001f26:	8d3e                	mv	s10,a5
          swtch(&c->context, &p->context);
    80001f28:	00010797          	auipc	a5,0x10
    80001f2c:	51078793          	addi	a5,a5,1296 # 80012438 <cpus+0x8>
    80001f30:	00f70cb3          	add	s9,a4,a5
    80001f34:	a815                	j	80001f68 <scheduler+0x8e>
      release(&tickslock);
    80001f36:	8556                	mv	a0,s5
    80001f38:	d2ffe0ef          	jal	80000c66 <release>
    80001f3c:	a875                	j	80001ff8 <scheduler+0x11e>
    mlfq_tails[priority] = 0;
    80001f3e:	00073023          	sd	zero,0(a4)
    80001f42:	a8a1                	j	80001f9a <scheduler+0xc0>
          p->state = RUNNING;
    80001f44:	4791                	li	a5,4
    80001f46:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    80001f48:	089d3423          	sd	s1,136(s10) # 1088 <_entry-0x7fffef78>
          swtch(&c->context, &p->context);
    80001f4c:	06048593          	addi	a1,s1,96
    80001f50:	8566                	mv	a0,s9
    80001f52:	688000ef          	jal	800025da <swtch>
          c->proc = 0;
    80001f56:	080d3423          	sd	zero,136(s10)
          found = 1;
    80001f5a:	4d85                	li	s11,1
    80001f5c:	a8a1                	j	80001fb4 <scheduler+0xda>
      release(&mlfq_lock);
    80001f5e:	854a                	mv	a0,s2
    80001f60:	d07fe0ef          	jal	80000c66 <release>
      asm volatile("wfi");
    80001f64:	10500073          	wfi
    uint64 current_ticks = ticks;
    80001f68:	00008c17          	auipc	s8,0x8
    80001f6c:	338c0c13          	addi	s8,s8,824 # 8000a2a0 <ticks>
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001f70:	00008b17          	auipc	s6,0x8
    80001f74:	320b0b13          	addi	s6,s6,800 # 8000a290 <last_boost_time>
    80001f78:	03100b93          	li	s7,49
    for(int priority = 0; priority < NMLFQ; priority++) {
    80001f7c:	4991                	li	s3,4
    80001f7e:	a081                	j	80001fbe <scheduler+0xe4>
    80001f80:	2785                	addiw	a5,a5,1
    80001f82:	0721                	addi	a4,a4,8
    80001f84:	fd378de3          	beq	a5,s3,80001f5e <scheduler+0x84>
  struct proc *p = mlfq_heads[priority];
    80001f88:	6304                	ld	s1,0(a4)
  if(p == 0)
    80001f8a:	d8fd                	beqz	s1,80001f80 <scheduler+0xa6>
  mlfq_heads[priority] = p->queue_next;
    80001f8c:	1704b683          	ld	a3,368(s1)
    80001f90:	00379713          	slli	a4,a5,0x3
    80001f94:	9752                	add	a4,a4,s4
    80001f96:	f314                	sd	a3,32(a4)
  if(mlfq_heads[priority] == 0) {
    80001f98:	d2dd                	beqz	a3,80001f3e <scheduler+0x64>
  p->queue_next = 0;
    80001f9a:	1604b823          	sd	zero,368(s1)
        release(&mlfq_lock);
    80001f9e:	854a                	mv	a0,s2
    80001fa0:	cc7fe0ef          	jal	80000c66 <release>
        acquire(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	c29fe0ef          	jal	80000bce <acquire>
        if(p->state == RUNNABLE) {
    80001faa:	4c98                	lw	a4,24(s1)
    80001fac:	478d                	li	a5,3
    int found = 0;
    80001fae:	4d81                	li	s11,0
        if(p->state == RUNNABLE) {
    80001fb0:	f8f70ae3          	beq	a4,a5,80001f44 <scheduler+0x6a>
        release(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	cb1fe0ef          	jal	80000c66 <release>
    if(!found) {
    80001fba:	fa0d82e3          	beqz	s11,80001f5e <scheduler+0x84>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fc2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fc6:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001fce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fd0:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80001fd4:	8556                	mv	a0,s5
    80001fd6:	bf9fe0ef          	jal	80000bce <acquire>
    uint64 current_ticks = ticks;
    80001fda:	000c6703          	lwu	a4,0(s8)
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001fde:	000b3783          	ld	a5,0(s6)
    80001fe2:	40f707b3          	sub	a5,a4,a5
    80001fe6:	f4fbf8e3          	bgeu	s7,a5,80001f36 <scheduler+0x5c>
      last_boost_time = current_ticks;
    80001fea:	00eb3023          	sd	a4,0(s6)
      release(&tickslock);
    80001fee:	8556                	mv	a0,s5
    80001ff0:	c77fe0ef          	jal	80000c66 <release>
      boost_all_priorities();
    80001ff4:	e13ff0ef          	jal	80001e06 <boost_all_priorities>
    acquire(&mlfq_lock);
    80001ff8:	854a                	mv	a0,s2
    80001ffa:	bd5fe0ef          	jal	80000bce <acquire>
    for(int priority = 0; priority < NMLFQ; priority++) {
    80001ffe:	00010717          	auipc	a4,0x10
    80002002:	3ca70713          	addi	a4,a4,970 # 800123c8 <mlfq_heads>
    80002006:	4781                	li	a5,0
    80002008:	b741                	j	80001f88 <scheduler+0xae>

000000008000200a <sched>:
{
    8000200a:	7179                	addi	sp,sp,-48
    8000200c:	f406                	sd	ra,40(sp)
    8000200e:	f022                	sd	s0,32(sp)
    80002010:	ec26                	sd	s1,24(sp)
    80002012:	e84a                	sd	s2,16(sp)
    80002014:	e44e                	sd	s3,8(sp)
    80002016:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002018:	939ff0ef          	jal	80001950 <myproc>
    8000201c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000201e:	b47fe0ef          	jal	80000b64 <holding>
    80002022:	c92d                	beqz	a0,80002094 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002024:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002026:	2781                	sext.w	a5,a5
    80002028:	079e                	slli	a5,a5,0x7
    8000202a:	00010717          	auipc	a4,0x10
    8000202e:	37e70713          	addi	a4,a4,894 # 800123a8 <mlfq_tails>
    80002032:	97ba                	add	a5,a5,a4
    80002034:	1007a703          	lw	a4,256(a5)
    80002038:	4785                	li	a5,1
    8000203a:	06f71363          	bne	a4,a5,800020a0 <sched+0x96>
  if(p->state == RUNNING)
    8000203e:	4c98                	lw	a4,24(s1)
    80002040:	4791                	li	a5,4
    80002042:	06f70563          	beq	a4,a5,800020ac <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002046:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000204a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000204c:	e7b5                	bnez	a5,800020b8 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000204e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002050:	00010917          	auipc	s2,0x10
    80002054:	35890913          	addi	s2,s2,856 # 800123a8 <mlfq_tails>
    80002058:	2781                	sext.w	a5,a5
    8000205a:	079e                	slli	a5,a5,0x7
    8000205c:	97ca                	add	a5,a5,s2
    8000205e:	1047a983          	lw	s3,260(a5)
    80002062:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002064:	2781                	sext.w	a5,a5
    80002066:	079e                	slli	a5,a5,0x7
    80002068:	00010597          	auipc	a1,0x10
    8000206c:	3d058593          	addi	a1,a1,976 # 80012438 <cpus+0x8>
    80002070:	95be                	add	a1,a1,a5
    80002072:	06048513          	addi	a0,s1,96
    80002076:	564000ef          	jal	800025da <swtch>
    8000207a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000207c:	2781                	sext.w	a5,a5
    8000207e:	079e                	slli	a5,a5,0x7
    80002080:	993e                	add	s2,s2,a5
    80002082:	11392223          	sw	s3,260(s2)
}
    80002086:	70a2                	ld	ra,40(sp)
    80002088:	7402                	ld	s0,32(sp)
    8000208a:	64e2                	ld	s1,24(sp)
    8000208c:	6942                	ld	s2,16(sp)
    8000208e:	69a2                	ld	s3,8(sp)
    80002090:	6145                	addi	sp,sp,48
    80002092:	8082                	ret
    panic("sched p->lock");
    80002094:	00005517          	auipc	a0,0x5
    80002098:	10c50513          	addi	a0,a0,268 # 800071a0 <etext+0x1a0>
    8000209c:	f44fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    800020a0:	00005517          	auipc	a0,0x5
    800020a4:	11050513          	addi	a0,a0,272 # 800071b0 <etext+0x1b0>
    800020a8:	f38fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    800020ac:	00005517          	auipc	a0,0x5
    800020b0:	11450513          	addi	a0,a0,276 # 800071c0 <etext+0x1c0>
    800020b4:	f2cfe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    800020b8:	00005517          	auipc	a0,0x5
    800020bc:	11850513          	addi	a0,a0,280 # 800071d0 <etext+0x1d0>
    800020c0:	f20fe0ef          	jal	800007e0 <panic>

00000000800020c4 <yield>:
{
    800020c4:	1101                	addi	sp,sp,-32
    800020c6:	ec06                	sd	ra,24(sp)
    800020c8:	e822                	sd	s0,16(sp)
    800020ca:	e426                	sd	s1,8(sp)
    800020cc:	e04a                	sd	s2,0(sp)
    800020ce:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020d0:	881ff0ef          	jal	80001950 <myproc>
    800020d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d6:	af9fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    800020da:	478d                	li	a5,3
    800020dc:	cc9c                	sw	a5,24(s1)
  acquire(&mlfq_lock);
    800020de:	00010917          	auipc	s2,0x10
    800020e2:	33a90913          	addi	s2,s2,826 # 80012418 <mlfq_lock>
    800020e6:	854a                	mv	a0,s2
    800020e8:	ae7fe0ef          	jal	80000bce <acquire>
  mlfq_enqueue(p);
    800020ec:	8526                	mv	a0,s1
    800020ee:	e66ff0ef          	jal	80001754 <mlfq_enqueue>
  release(&mlfq_lock);
    800020f2:	854a                	mv	a0,s2
    800020f4:	b73fe0ef          	jal	80000c66 <release>
  sched();
    800020f8:	f13ff0ef          	jal	8000200a <sched>
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b69fe0ef          	jal	80000c66 <release>
}
    80002102:	60e2                	ld	ra,24(sp)
    80002104:	6442                	ld	s0,16(sp)
    80002106:	64a2                	ld	s1,8(sp)
    80002108:	6902                	ld	s2,0(sp)
    8000210a:	6105                	addi	sp,sp,32
    8000210c:	8082                	ret

000000008000210e <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	1800                	addi	s0,sp,48
    8000211c:	89aa                	mv	s3,a0
    8000211e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002120:	831ff0ef          	jal	80001950 <myproc>
    80002124:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002126:	aa9fe0ef          	jal	80000bce <acquire>
  release(lk);
    8000212a:	854a                	mv	a0,s2
    8000212c:	b3bfe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80002130:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002134:	4789                	li	a5,2
    80002136:	cc9c                	sw	a5,24(s1)

  sched();
    80002138:	ed3ff0ef          	jal	8000200a <sched>

  // Tidy up.
  p->chan = 0;
    8000213c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	b25fe0ef          	jal	80000c66 <release>
  acquire(lk);
    80002146:	854a                	mv	a0,s2
    80002148:	a87fe0ef          	jal	80000bce <acquire>
}
    8000214c:	70a2                	ld	ra,40(sp)
    8000214e:	7402                	ld	s0,32(sp)
    80002150:	64e2                	ld	s1,24(sp)
    80002152:	6942                	ld	s2,16(sp)
    80002154:	69a2                	ld	s3,8(sp)
    80002156:	6145                	addi	sp,sp,48
    80002158:	8082                	ret

000000008000215a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000215a:	7139                	addi	sp,sp,-64
    8000215c:	fc06                	sd	ra,56(sp)
    8000215e:	f822                	sd	s0,48(sp)
    80002160:	f426                	sd	s1,40(sp)
    80002162:	f04a                	sd	s2,32(sp)
    80002164:	ec4e                	sd	s3,24(sp)
    80002166:	e852                	sd	s4,16(sp)
    80002168:	e456                	sd	s5,8(sp)
    8000216a:	e05a                	sd	s6,0(sp)
    8000216c:	0080                	addi	s0,sp,64
    8000216e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002170:	00010497          	auipc	s1,0x10
    80002174:	6c048493          	addi	s1,s1,1728 # 80012830 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002178:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000217a:	4b0d                	li	s6,3
        
        // Enqueue to MLFQ
        acquire(&mlfq_lock);
    8000217c:	00010a97          	auipc	s5,0x10
    80002180:	29ca8a93          	addi	s5,s5,668 # 80012418 <mlfq_lock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002184:	00016917          	auipc	s2,0x16
    80002188:	4ac90913          	addi	s2,s2,1196 # 80018630 <tickslock>
    8000218c:	a801                	j	8000219c <wakeup+0x42>
        mlfq_enqueue(p);
        release(&mlfq_lock);
      }
      release(&p->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	ad7fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002194:	17848493          	addi	s1,s1,376
    80002198:	03248b63          	beq	s1,s2,800021ce <wakeup+0x74>
    if(p != myproc()){
    8000219c:	fb4ff0ef          	jal	80001950 <myproc>
    800021a0:	fea48ae3          	beq	s1,a0,80002194 <wakeup+0x3a>
      acquire(&p->lock);
    800021a4:	8526                	mv	a0,s1
    800021a6:	a29fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021aa:	4c9c                	lw	a5,24(s1)
    800021ac:	ff3791e3          	bne	a5,s3,8000218e <wakeup+0x34>
    800021b0:	709c                	ld	a5,32(s1)
    800021b2:	fd479ee3          	bne	a5,s4,8000218e <wakeup+0x34>
        p->state = RUNNABLE;
    800021b6:	0164ac23          	sw	s6,24(s1)
        acquire(&mlfq_lock);
    800021ba:	8556                	mv	a0,s5
    800021bc:	a13fe0ef          	jal	80000bce <acquire>
        mlfq_enqueue(p);
    800021c0:	8526                	mv	a0,s1
    800021c2:	d92ff0ef          	jal	80001754 <mlfq_enqueue>
        release(&mlfq_lock);
    800021c6:	8556                	mv	a0,s5
    800021c8:	a9ffe0ef          	jal	80000c66 <release>
    800021cc:	b7c9                	j	8000218e <wakeup+0x34>
    }
  }
}
    800021ce:	70e2                	ld	ra,56(sp)
    800021d0:	7442                	ld	s0,48(sp)
    800021d2:	74a2                	ld	s1,40(sp)
    800021d4:	7902                	ld	s2,32(sp)
    800021d6:	69e2                	ld	s3,24(sp)
    800021d8:	6a42                	ld	s4,16(sp)
    800021da:	6aa2                	ld	s5,8(sp)
    800021dc:	6b02                	ld	s6,0(sp)
    800021de:	6121                	addi	sp,sp,64
    800021e0:	8082                	ret

00000000800021e2 <reparent>:
{
    800021e2:	7179                	addi	sp,sp,-48
    800021e4:	f406                	sd	ra,40(sp)
    800021e6:	f022                	sd	s0,32(sp)
    800021e8:	ec26                	sd	s1,24(sp)
    800021ea:	e84a                	sd	s2,16(sp)
    800021ec:	e44e                	sd	s3,8(sp)
    800021ee:	e052                	sd	s4,0(sp)
    800021f0:	1800                	addi	s0,sp,48
    800021f2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f4:	00010497          	auipc	s1,0x10
    800021f8:	63c48493          	addi	s1,s1,1596 # 80012830 <proc>
      pp->parent = initproc;
    800021fc:	00008a17          	auipc	s4,0x8
    80002200:	09ca0a13          	addi	s4,s4,156 # 8000a298 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002204:	00016997          	auipc	s3,0x16
    80002208:	42c98993          	addi	s3,s3,1068 # 80018630 <tickslock>
    8000220c:	a029                	j	80002216 <reparent+0x34>
    8000220e:	17848493          	addi	s1,s1,376
    80002212:	01348b63          	beq	s1,s3,80002228 <reparent+0x46>
    if(pp->parent == p){
    80002216:	7c9c                	ld	a5,56(s1)
    80002218:	ff279be3          	bne	a5,s2,8000220e <reparent+0x2c>
      pp->parent = initproc;
    8000221c:	000a3503          	ld	a0,0(s4)
    80002220:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002222:	f39ff0ef          	jal	8000215a <wakeup>
    80002226:	b7e5                	j	8000220e <reparent+0x2c>
}
    80002228:	70a2                	ld	ra,40(sp)
    8000222a:	7402                	ld	s0,32(sp)
    8000222c:	64e2                	ld	s1,24(sp)
    8000222e:	6942                	ld	s2,16(sp)
    80002230:	69a2                	ld	s3,8(sp)
    80002232:	6a02                	ld	s4,0(sp)
    80002234:	6145                	addi	sp,sp,48
    80002236:	8082                	ret

0000000080002238 <kexit>:
{
    80002238:	7179                	addi	sp,sp,-48
    8000223a:	f406                	sd	ra,40(sp)
    8000223c:	f022                	sd	s0,32(sp)
    8000223e:	ec26                	sd	s1,24(sp)
    80002240:	e84a                	sd	s2,16(sp)
    80002242:	e44e                	sd	s3,8(sp)
    80002244:	e052                	sd	s4,0(sp)
    80002246:	1800                	addi	s0,sp,48
    80002248:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000224a:	f06ff0ef          	jal	80001950 <myproc>
    8000224e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002250:	00008797          	auipc	a5,0x8
    80002254:	0487b783          	ld	a5,72(a5) # 8000a298 <initproc>
    80002258:	0d050493          	addi	s1,a0,208
    8000225c:	15050913          	addi	s2,a0,336
    80002260:	00a79f63          	bne	a5,a0,8000227e <kexit+0x46>
    panic("init exiting");
    80002264:	00005517          	auipc	a0,0x5
    80002268:	f8450513          	addi	a0,a0,-124 # 800071e8 <etext+0x1e8>
    8000226c:	d74fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002270:	080020ef          	jal	800042f0 <fileclose>
      p->ofile[fd] = 0;
    80002274:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002278:	04a1                	addi	s1,s1,8
    8000227a:	01248563          	beq	s1,s2,80002284 <kexit+0x4c>
    if(p->ofile[fd]){
    8000227e:	6088                	ld	a0,0(s1)
    80002280:	f965                	bnez	a0,80002270 <kexit+0x38>
    80002282:	bfdd                	j	80002278 <kexit+0x40>
  begin_op();
    80002284:	461010ef          	jal	80003ee4 <begin_op>
  iput(p->cwd);
    80002288:	1509b503          	ld	a0,336(s3)
    8000228c:	3f0010ef          	jal	8000367c <iput>
  end_op();
    80002290:	4bf010ef          	jal	80003f4e <end_op>
  p->cwd = 0;
    80002294:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002298:	00010497          	auipc	s1,0x10
    8000229c:	16848493          	addi	s1,s1,360 # 80012400 <wait_lock>
    800022a0:	8526                	mv	a0,s1
    800022a2:	92dfe0ef          	jal	80000bce <acquire>
  reparent(p);
    800022a6:	854e                	mv	a0,s3
    800022a8:	f3bff0ef          	jal	800021e2 <reparent>
  wakeup(p->parent);
    800022ac:	0389b503          	ld	a0,56(s3)
    800022b0:	eabff0ef          	jal	8000215a <wakeup>
  acquire(&p->lock);
    800022b4:	854e                	mv	a0,s3
    800022b6:	919fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    800022ba:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022be:	4795                	li	a5,5
    800022c0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	9a1fe0ef          	jal	80000c66 <release>
  sched();
    800022ca:	d41ff0ef          	jal	8000200a <sched>
  panic("zombie exit");
    800022ce:	00005517          	auipc	a0,0x5
    800022d2:	f2a50513          	addi	a0,a0,-214 # 800071f8 <etext+0x1f8>
    800022d6:	d0afe0ef          	jal	800007e0 <panic>

00000000800022da <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800022da:	7179                	addi	sp,sp,-48
    800022dc:	f406                	sd	ra,40(sp)
    800022de:	f022                	sd	s0,32(sp)
    800022e0:	ec26                	sd	s1,24(sp)
    800022e2:	e84a                	sd	s2,16(sp)
    800022e4:	e44e                	sd	s3,8(sp)
    800022e6:	1800                	addi	s0,sp,48
    800022e8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022ea:	00010497          	auipc	s1,0x10
    800022ee:	54648493          	addi	s1,s1,1350 # 80012830 <proc>
    800022f2:	00016997          	auipc	s3,0x16
    800022f6:	33e98993          	addi	s3,s3,830 # 80018630 <tickslock>
    acquire(&p->lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	8d3fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    80002300:	589c                	lw	a5,48(s1)
    80002302:	01278b63          	beq	a5,s2,80002318 <kkill+0x3e>
        release(&mlfq_lock);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002306:	8526                	mv	a0,s1
    80002308:	95ffe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000230c:	17848493          	addi	s1,s1,376
    80002310:	ff3495e3          	bne	s1,s3,800022fa <kkill+0x20>
  }
  return -1;
    80002314:	557d                	li	a0,-1
    80002316:	a819                	j	8000232c <kkill+0x52>
      p->killed = 1;
    80002318:	4785                	li	a5,1
    8000231a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000231c:	4c98                	lw	a4,24(s1)
    8000231e:	4789                	li	a5,2
    80002320:	00f70d63          	beq	a4,a5,8000233a <kkill+0x60>
      release(&p->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	941fe0ef          	jal	80000c66 <release>
      return 0;
    8000232a:	4501                	li	a0,0
}
    8000232c:	70a2                	ld	ra,40(sp)
    8000232e:	7402                	ld	s0,32(sp)
    80002330:	64e2                	ld	s1,24(sp)
    80002332:	6942                	ld	s2,16(sp)
    80002334:	69a2                	ld	s3,8(sp)
    80002336:	6145                	addi	sp,sp,48
    80002338:	8082                	ret
        p->state = RUNNABLE;
    8000233a:	478d                	li	a5,3
    8000233c:	cc9c                	sw	a5,24(s1)
        acquire(&mlfq_lock);
    8000233e:	00010917          	auipc	s2,0x10
    80002342:	0da90913          	addi	s2,s2,218 # 80012418 <mlfq_lock>
    80002346:	854a                	mv	a0,s2
    80002348:	887fe0ef          	jal	80000bce <acquire>
        mlfq_enqueue(p);
    8000234c:	8526                	mv	a0,s1
    8000234e:	c06ff0ef          	jal	80001754 <mlfq_enqueue>
        release(&mlfq_lock);
    80002352:	854a                	mv	a0,s2
    80002354:	913fe0ef          	jal	80000c66 <release>
    80002358:	b7f1                	j	80002324 <kkill+0x4a>

000000008000235a <setkilled>:

void
setkilled(struct proc *p)
{
    8000235a:	1101                	addi	sp,sp,-32
    8000235c:	ec06                	sd	ra,24(sp)
    8000235e:	e822                	sd	s0,16(sp)
    80002360:	e426                	sd	s1,8(sp)
    80002362:	1000                	addi	s0,sp,32
    80002364:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002366:	869fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    8000236a:	4785                	li	a5,1
    8000236c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	8f7fe0ef          	jal	80000c66 <release>
}
    80002374:	60e2                	ld	ra,24(sp)
    80002376:	6442                	ld	s0,16(sp)
    80002378:	64a2                	ld	s1,8(sp)
    8000237a:	6105                	addi	sp,sp,32
    8000237c:	8082                	ret

000000008000237e <killed>:

int
killed(struct proc *p)
{
    8000237e:	1101                	addi	sp,sp,-32
    80002380:	ec06                	sd	ra,24(sp)
    80002382:	e822                	sd	s0,16(sp)
    80002384:	e426                	sd	s1,8(sp)
    80002386:	e04a                	sd	s2,0(sp)
    80002388:	1000                	addi	s0,sp,32
    8000238a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000238c:	843fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002390:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002394:	8526                	mv	a0,s1
    80002396:	8d1fe0ef          	jal	80000c66 <release>
  return k;
}
    8000239a:	854a                	mv	a0,s2
    8000239c:	60e2                	ld	ra,24(sp)
    8000239e:	6442                	ld	s0,16(sp)
    800023a0:	64a2                	ld	s1,8(sp)
    800023a2:	6902                	ld	s2,0(sp)
    800023a4:	6105                	addi	sp,sp,32
    800023a6:	8082                	ret

00000000800023a8 <kwait>:
{
    800023a8:	715d                	addi	sp,sp,-80
    800023aa:	e486                	sd	ra,72(sp)
    800023ac:	e0a2                	sd	s0,64(sp)
    800023ae:	fc26                	sd	s1,56(sp)
    800023b0:	f84a                	sd	s2,48(sp)
    800023b2:	f44e                	sd	s3,40(sp)
    800023b4:	f052                	sd	s4,32(sp)
    800023b6:	ec56                	sd	s5,24(sp)
    800023b8:	e85a                	sd	s6,16(sp)
    800023ba:	e45e                	sd	s7,8(sp)
    800023bc:	e062                	sd	s8,0(sp)
    800023be:	0880                	addi	s0,sp,80
    800023c0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023c2:	d8eff0ef          	jal	80001950 <myproc>
    800023c6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023c8:	00010517          	auipc	a0,0x10
    800023cc:	03850513          	addi	a0,a0,56 # 80012400 <wait_lock>
    800023d0:	ffefe0ef          	jal	80000bce <acquire>
    havekids = 0;
    800023d4:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023d6:	4a15                	li	s4,5
        havekids = 1;
    800023d8:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023da:	00016997          	auipc	s3,0x16
    800023de:	25698993          	addi	s3,s3,598 # 80018630 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023e2:	00010c17          	auipc	s8,0x10
    800023e6:	01ec0c13          	addi	s8,s8,30 # 80012400 <wait_lock>
    800023ea:	a871                	j	80002486 <kwait+0xde>
          pid = pp->pid;
    800023ec:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023f0:	000b0c63          	beqz	s6,80002408 <kwait+0x60>
    800023f4:	4691                	li	a3,4
    800023f6:	02c48613          	addi	a2,s1,44
    800023fa:	85da                	mv	a1,s6
    800023fc:	05093503          	ld	a0,80(s2)
    80002400:	9e2ff0ef          	jal	800015e2 <copyout>
    80002404:	02054b63          	bltz	a0,8000243a <kwait+0x92>
          freeproc(pp);
    80002408:	8526                	mv	a0,s1
    8000240a:	f16ff0ef          	jal	80001b20 <freeproc>
          release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	857fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002414:	00010517          	auipc	a0,0x10
    80002418:	fec50513          	addi	a0,a0,-20 # 80012400 <wait_lock>
    8000241c:	84bfe0ef          	jal	80000c66 <release>
}
    80002420:	854e                	mv	a0,s3
    80002422:	60a6                	ld	ra,72(sp)
    80002424:	6406                	ld	s0,64(sp)
    80002426:	74e2                	ld	s1,56(sp)
    80002428:	7942                	ld	s2,48(sp)
    8000242a:	79a2                	ld	s3,40(sp)
    8000242c:	7a02                	ld	s4,32(sp)
    8000242e:	6ae2                	ld	s5,24(sp)
    80002430:	6b42                	ld	s6,16(sp)
    80002432:	6ba2                	ld	s7,8(sp)
    80002434:	6c02                	ld	s8,0(sp)
    80002436:	6161                	addi	sp,sp,80
    80002438:	8082                	ret
            release(&pp->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	82bfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    80002440:	00010517          	auipc	a0,0x10
    80002444:	fc050513          	addi	a0,a0,-64 # 80012400 <wait_lock>
    80002448:	81ffe0ef          	jal	80000c66 <release>
            return -1;
    8000244c:	59fd                	li	s3,-1
    8000244e:	bfc9                	j	80002420 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002450:	17848493          	addi	s1,s1,376
    80002454:	03348063          	beq	s1,s3,80002474 <kwait+0xcc>
      if(pp->parent == p){
    80002458:	7c9c                	ld	a5,56(s1)
    8000245a:	ff279be3          	bne	a5,s2,80002450 <kwait+0xa8>
        acquire(&pp->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	f6efe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    80002464:	4c9c                	lw	a5,24(s1)
    80002466:	f94783e3          	beq	a5,s4,800023ec <kwait+0x44>
        release(&pp->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	ffafe0ef          	jal	80000c66 <release>
        havekids = 1;
    80002470:	8756                	mv	a4,s5
    80002472:	bff9                	j	80002450 <kwait+0xa8>
    if(!havekids || killed(p)){
    80002474:	cf19                	beqz	a4,80002492 <kwait+0xea>
    80002476:	854a                	mv	a0,s2
    80002478:	f07ff0ef          	jal	8000237e <killed>
    8000247c:	e919                	bnez	a0,80002492 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000247e:	85e2                	mv	a1,s8
    80002480:	854a                	mv	a0,s2
    80002482:	c8dff0ef          	jal	8000210e <sleep>
    havekids = 0;
    80002486:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002488:	00010497          	auipc	s1,0x10
    8000248c:	3a848493          	addi	s1,s1,936 # 80012830 <proc>
    80002490:	b7e1                	j	80002458 <kwait+0xb0>
      release(&wait_lock);
    80002492:	00010517          	auipc	a0,0x10
    80002496:	f6e50513          	addi	a0,a0,-146 # 80012400 <wait_lock>
    8000249a:	fccfe0ef          	jal	80000c66 <release>
      return -1;
    8000249e:	59fd                	li	s3,-1
    800024a0:	b741                	j	80002420 <kwait+0x78>

00000000800024a2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024a2:	7179                	addi	sp,sp,-48
    800024a4:	f406                	sd	ra,40(sp)
    800024a6:	f022                	sd	s0,32(sp)
    800024a8:	ec26                	sd	s1,24(sp)
    800024aa:	e84a                	sd	s2,16(sp)
    800024ac:	e44e                	sd	s3,8(sp)
    800024ae:	e052                	sd	s4,0(sp)
    800024b0:	1800                	addi	s0,sp,48
    800024b2:	84aa                	mv	s1,a0
    800024b4:	892e                	mv	s2,a1
    800024b6:	89b2                	mv	s3,a2
    800024b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ba:	c96ff0ef          	jal	80001950 <myproc>
  if(user_dst){
    800024be:	cc99                	beqz	s1,800024dc <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800024c0:	86d2                	mv	a3,s4
    800024c2:	864e                	mv	a2,s3
    800024c4:	85ca                	mv	a1,s2
    800024c6:	6928                	ld	a0,80(a0)
    800024c8:	91aff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024cc:	70a2                	ld	ra,40(sp)
    800024ce:	7402                	ld	s0,32(sp)
    800024d0:	64e2                	ld	s1,24(sp)
    800024d2:	6942                	ld	s2,16(sp)
    800024d4:	69a2                	ld	s3,8(sp)
    800024d6:	6a02                	ld	s4,0(sp)
    800024d8:	6145                	addi	sp,sp,48
    800024da:	8082                	ret
    memmove((char *)dst, src, len);
    800024dc:	000a061b          	sext.w	a2,s4
    800024e0:	85ce                	mv	a1,s3
    800024e2:	854a                	mv	a0,s2
    800024e4:	81bfe0ef          	jal	80000cfe <memmove>
    return 0;
    800024e8:	8526                	mv	a0,s1
    800024ea:	b7cd                	j	800024cc <either_copyout+0x2a>

00000000800024ec <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024ec:	7179                	addi	sp,sp,-48
    800024ee:	f406                	sd	ra,40(sp)
    800024f0:	f022                	sd	s0,32(sp)
    800024f2:	ec26                	sd	s1,24(sp)
    800024f4:	e84a                	sd	s2,16(sp)
    800024f6:	e44e                	sd	s3,8(sp)
    800024f8:	e052                	sd	s4,0(sp)
    800024fa:	1800                	addi	s0,sp,48
    800024fc:	892a                	mv	s2,a0
    800024fe:	84ae                	mv	s1,a1
    80002500:	89b2                	mv	s3,a2
    80002502:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002504:	c4cff0ef          	jal	80001950 <myproc>
  if(user_src){
    80002508:	cc99                	beqz	s1,80002526 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000250a:	86d2                	mv	a3,s4
    8000250c:	864e                	mv	a2,s3
    8000250e:	85ca                	mv	a1,s2
    80002510:	6928                	ld	a0,80(a0)
    80002512:	9b4ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002516:	70a2                	ld	ra,40(sp)
    80002518:	7402                	ld	s0,32(sp)
    8000251a:	64e2                	ld	s1,24(sp)
    8000251c:	6942                	ld	s2,16(sp)
    8000251e:	69a2                	ld	s3,8(sp)
    80002520:	6a02                	ld	s4,0(sp)
    80002522:	6145                	addi	sp,sp,48
    80002524:	8082                	ret
    memmove(dst, (char*)src, len);
    80002526:	000a061b          	sext.w	a2,s4
    8000252a:	85ce                	mv	a1,s3
    8000252c:	854a                	mv	a0,s2
    8000252e:	fd0fe0ef          	jal	80000cfe <memmove>
    return 0;
    80002532:	8526                	mv	a0,s1
    80002534:	b7cd                	j	80002516 <either_copyin+0x2a>

0000000080002536 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002536:	715d                	addi	sp,sp,-80
    80002538:	e486                	sd	ra,72(sp)
    8000253a:	e0a2                	sd	s0,64(sp)
    8000253c:	fc26                	sd	s1,56(sp)
    8000253e:	f84a                	sd	s2,48(sp)
    80002540:	f44e                	sd	s3,40(sp)
    80002542:	f052                	sd	s4,32(sp)
    80002544:	ec56                	sd	s5,24(sp)
    80002546:	e85a                	sd	s6,16(sp)
    80002548:	e45e                	sd	s7,8(sp)
    8000254a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000254c:	00005517          	auipc	a0,0x5
    80002550:	b2c50513          	addi	a0,a0,-1236 # 80007078 <etext+0x78>
    80002554:	fa7fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002558:	00010497          	auipc	s1,0x10
    8000255c:	43048493          	addi	s1,s1,1072 # 80012988 <proc+0x158>
    80002560:	00016917          	auipc	s2,0x16
    80002564:	22890913          	addi	s2,s2,552 # 80018788 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002568:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000256a:	00005997          	auipc	s3,0x5
    8000256e:	c9e98993          	addi	s3,s3,-866 # 80007208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    80002572:	00005a97          	auipc	s5,0x5
    80002576:	c9ea8a93          	addi	s5,s5,-866 # 80007210 <etext+0x210>
    printf("\n");
    8000257a:	00005a17          	auipc	s4,0x5
    8000257e:	afea0a13          	addi	s4,s4,-1282 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002582:	00005b97          	auipc	s7,0x5
    80002586:	1aeb8b93          	addi	s7,s7,430 # 80007730 <states.0>
    8000258a:	a829                	j	800025a4 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000258c:	ed86a583          	lw	a1,-296(a3)
    80002590:	8556                	mv	a0,s5
    80002592:	f69fd0ef          	jal	800004fa <printf>
    printf("\n");
    80002596:	8552                	mv	a0,s4
    80002598:	f63fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000259c:	17848493          	addi	s1,s1,376
    800025a0:	03248263          	beq	s1,s2,800025c4 <procdump+0x8e>
    if(p->state == UNUSED)
    800025a4:	86a6                	mv	a3,s1
    800025a6:	ec04a783          	lw	a5,-320(s1)
    800025aa:	dbed                	beqz	a5,8000259c <procdump+0x66>
      state = "???";
    800025ac:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ae:	fcfb6fe3          	bltu	s6,a5,8000258c <procdump+0x56>
    800025b2:	02079713          	slli	a4,a5,0x20
    800025b6:	01d75793          	srli	a5,a4,0x1d
    800025ba:	97de                	add	a5,a5,s7
    800025bc:	6390                	ld	a2,0(a5)
    800025be:	f679                	bnez	a2,8000258c <procdump+0x56>
      state = "???";
    800025c0:	864e                	mv	a2,s3
    800025c2:	b7e9                	j	8000258c <procdump+0x56>
  }
}
    800025c4:	60a6                	ld	ra,72(sp)
    800025c6:	6406                	ld	s0,64(sp)
    800025c8:	74e2                	ld	s1,56(sp)
    800025ca:	7942                	ld	s2,48(sp)
    800025cc:	79a2                	ld	s3,40(sp)
    800025ce:	7a02                	ld	s4,32(sp)
    800025d0:	6ae2                	ld	s5,24(sp)
    800025d2:	6b42                	ld	s6,16(sp)
    800025d4:	6ba2                	ld	s7,8(sp)
    800025d6:	6161                	addi	sp,sp,80
    800025d8:	8082                	ret

00000000800025da <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025da:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025de:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025e2:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025e4:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025e6:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025ea:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025ee:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025f2:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025f6:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025fa:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025fe:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002602:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002606:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000260a:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000260e:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002612:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002616:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002618:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000261a:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000261e:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002622:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002626:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000262a:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000262e:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002632:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002636:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000263a:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000263e:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002642:	8082                	ret

0000000080002644 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002644:	1141                	addi	sp,sp,-16
    80002646:	e406                	sd	ra,8(sp)
    80002648:	e022                	sd	s0,0(sp)
    8000264a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000264c:	00005597          	auipc	a1,0x5
    80002650:	c0458593          	addi	a1,a1,-1020 # 80007250 <etext+0x250>
    80002654:	00016517          	auipc	a0,0x16
    80002658:	fdc50513          	addi	a0,a0,-36 # 80018630 <tickslock>
    8000265c:	cf2fe0ef          	jal	80000b4e <initlock>
}
    80002660:	60a2                	ld	ra,8(sp)
    80002662:	6402                	ld	s0,0(sp)
    80002664:	0141                	addi	sp,sp,16
    80002666:	8082                	ret

0000000080002668 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002668:	1141                	addi	sp,sp,-16
    8000266a:	e422                	sd	s0,8(sp)
    8000266c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000266e:	00003797          	auipc	a5,0x3
    80002672:	00278793          	addi	a5,a5,2 # 80005670 <kernelvec>
    80002676:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000267a:	6422                	ld	s0,8(sp)
    8000267c:	0141                	addi	sp,sp,16
    8000267e:	8082                	ret

0000000080002680 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002680:	1141                	addi	sp,sp,-16
    80002682:	e406                	sd	ra,8(sp)
    80002684:	e022                	sd	s0,0(sp)
    80002686:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002688:	ac8ff0ef          	jal	80001950 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000268c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002690:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002692:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002696:	04000737          	lui	a4,0x4000
    8000269a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000269c:	0732                	slli	a4,a4,0xc
    8000269e:	00004797          	auipc	a5,0x4
    800026a2:	96278793          	addi	a5,a5,-1694 # 80006000 <_trampoline>
    800026a6:	00004697          	auipc	a3,0x4
    800026aa:	95a68693          	addi	a3,a3,-1702 # 80006000 <_trampoline>
    800026ae:	8f95                	sub	a5,a5,a3
    800026b0:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b2:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026b6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026b8:	18002773          	csrr	a4,satp
    800026bc:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026be:	6d38                	ld	a4,88(a0)
    800026c0:	613c                	ld	a5,64(a0)
    800026c2:	6685                	lui	a3,0x1
    800026c4:	97b6                	add	a5,a5,a3
    800026c6:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026c8:	6d3c                	ld	a5,88(a0)
    800026ca:	00000717          	auipc	a4,0x0
    800026ce:	0f870713          	addi	a4,a4,248 # 800027c2 <usertrap>
    800026d2:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026d4:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026d6:	8712                	mv	a4,tp
    800026d8:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026da:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026de:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026e2:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e6:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026ea:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026ec:	6f9c                	ld	a5,24(a5)
    800026ee:	14179073          	csrw	sepc,a5
}
    800026f2:	60a2                	ld	ra,8(sp)
    800026f4:	6402                	ld	s0,0(sp)
    800026f6:	0141                	addi	sp,sp,16
    800026f8:	8082                	ret

00000000800026fa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026fa:	1101                	addi	sp,sp,-32
    800026fc:	ec06                	sd	ra,24(sp)
    800026fe:	e822                	sd	s0,16(sp)
    80002700:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002702:	a22ff0ef          	jal	80001924 <cpuid>
    80002706:	cd11                	beqz	a0,80002722 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002708:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000270c:	000f4737          	lui	a4,0xf4
    80002710:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002714:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002716:	14d79073          	csrw	stimecmp,a5
}
    8000271a:	60e2                	ld	ra,24(sp)
    8000271c:	6442                	ld	s0,16(sp)
    8000271e:	6105                	addi	sp,sp,32
    80002720:	8082                	ret
    80002722:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002724:	00016497          	auipc	s1,0x16
    80002728:	f0c48493          	addi	s1,s1,-244 # 80018630 <tickslock>
    8000272c:	8526                	mv	a0,s1
    8000272e:	ca0fe0ef          	jal	80000bce <acquire>
    ticks++;
    80002732:	00008517          	auipc	a0,0x8
    80002736:	b6e50513          	addi	a0,a0,-1170 # 8000a2a0 <ticks>
    8000273a:	411c                	lw	a5,0(a0)
    8000273c:	2785                	addiw	a5,a5,1
    8000273e:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002740:	a1bff0ef          	jal	8000215a <wakeup>
    release(&tickslock);
    80002744:	8526                	mv	a0,s1
    80002746:	d20fe0ef          	jal	80000c66 <release>
    8000274a:	64a2                	ld	s1,8(sp)
    8000274c:	bf75                	j	80002708 <clockintr+0xe>

000000008000274e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000274e:	1101                	addi	sp,sp,-32
    80002750:	ec06                	sd	ra,24(sp)
    80002752:	e822                	sd	s0,16(sp)
    80002754:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002756:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000275a:	57fd                	li	a5,-1
    8000275c:	17fe                	slli	a5,a5,0x3f
    8000275e:	07a5                	addi	a5,a5,9
    80002760:	00f70c63          	beq	a4,a5,80002778 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002764:	57fd                	li	a5,-1
    80002766:	17fe                	slli	a5,a5,0x3f
    80002768:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000276a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000276c:	04f70763          	beq	a4,a5,800027ba <devintr+0x6c>
  }
}
    80002770:	60e2                	ld	ra,24(sp)
    80002772:	6442                	ld	s0,16(sp)
    80002774:	6105                	addi	sp,sp,32
    80002776:	8082                	ret
    80002778:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000277a:	7a3020ef          	jal	8000571c <plic_claim>
    8000277e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002780:	47a9                	li	a5,10
    80002782:	00f50963          	beq	a0,a5,80002794 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002786:	4785                	li	a5,1
    80002788:	00f50963          	beq	a0,a5,8000279a <devintr+0x4c>
    return 1;
    8000278c:	4505                	li	a0,1
    } else if(irq){
    8000278e:	e889                	bnez	s1,800027a0 <devintr+0x52>
    80002790:	64a2                	ld	s1,8(sp)
    80002792:	bff9                	j	80002770 <devintr+0x22>
      uartintr();
    80002794:	a1cfe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002798:	a819                	j	800027ae <devintr+0x60>
      virtio_disk_intr();
    8000279a:	448030ef          	jal	80005be2 <virtio_disk_intr>
    if(irq)
    8000279e:	a801                	j	800027ae <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800027a0:	85a6                	mv	a1,s1
    800027a2:	00005517          	auipc	a0,0x5
    800027a6:	ab650513          	addi	a0,a0,-1354 # 80007258 <etext+0x258>
    800027aa:	d51fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800027ae:	8526                	mv	a0,s1
    800027b0:	78d020ef          	jal	8000573c <plic_complete>
    return 1;
    800027b4:	4505                	li	a0,1
    800027b6:	64a2                	ld	s1,8(sp)
    800027b8:	bf65                	j	80002770 <devintr+0x22>
    clockintr();
    800027ba:	f41ff0ef          	jal	800026fa <clockintr>
    return 2;
    800027be:	4509                	li	a0,2
    800027c0:	bf45                	j	80002770 <devintr+0x22>

00000000800027c2 <usertrap>:
{
    800027c2:	1101                	addi	sp,sp,-32
    800027c4:	ec06                	sd	ra,24(sp)
    800027c6:	e822                	sd	s0,16(sp)
    800027c8:	e426                	sd	s1,8(sp)
    800027ca:	e04a                	sd	s2,0(sp)
    800027cc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ce:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027d2:	1007f793          	andi	a5,a5,256
    800027d6:	eba5                	bnez	a5,80002846 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027d8:	00003797          	auipc	a5,0x3
    800027dc:	e9878793          	addi	a5,a5,-360 # 80005670 <kernelvec>
    800027e0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027e4:	96cff0ef          	jal	80001950 <myproc>
    800027e8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027ea:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ec:	14102773          	csrr	a4,sepc
    800027f0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027f2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027f6:	47a1                	li	a5,8
    800027f8:	04f70d63          	beq	a4,a5,80002852 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800027fc:	f53ff0ef          	jal	8000274e <devintr>
    80002800:	892a                	mv	s2,a0
    80002802:	e945                	bnez	a0,800028b2 <usertrap+0xf0>
    80002804:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002808:	47bd                	li	a5,15
    8000280a:	08f70863          	beq	a4,a5,8000289a <usertrap+0xd8>
    8000280e:	14202773          	csrr	a4,scause
    80002812:	47b5                	li	a5,13
    80002814:	08f70363          	beq	a4,a5,8000289a <usertrap+0xd8>
    80002818:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000281c:	5890                	lw	a2,48(s1)
    8000281e:	00005517          	auipc	a0,0x5
    80002822:	a7a50513          	addi	a0,a0,-1414 # 80007298 <etext+0x298>
    80002826:	cd5fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000282a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000282e:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002832:	00005517          	auipc	a0,0x5
    80002836:	a9650513          	addi	a0,a0,-1386 # 800072c8 <etext+0x2c8>
    8000283a:	cc1fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000283e:	8526                	mv	a0,s1
    80002840:	b1bff0ef          	jal	8000235a <setkilled>
    80002844:	a035                	j	80002870 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002846:	00005517          	auipc	a0,0x5
    8000284a:	a3250513          	addi	a0,a0,-1486 # 80007278 <etext+0x278>
    8000284e:	f93fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002852:	b2dff0ef          	jal	8000237e <killed>
    80002856:	ed15                	bnez	a0,80002892 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002858:	6cb8                	ld	a4,88(s1)
    8000285a:	6f1c                	ld	a5,24(a4)
    8000285c:	0791                	addi	a5,a5,4
    8000285e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002860:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002864:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002868:	10079073          	csrw	sstatus,a5
    syscall();
    8000286c:	27c000ef          	jal	80002ae8 <syscall>
  if(killed(p))
    80002870:	8526                	mv	a0,s1
    80002872:	b0dff0ef          	jal	8000237e <killed>
    80002876:	e139                	bnez	a0,800028bc <usertrap+0xfa>
  prepare_return();
    80002878:	e09ff0ef          	jal	80002680 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000287c:	68a8                	ld	a0,80(s1)
    8000287e:	8131                	srli	a0,a0,0xc
    80002880:	57fd                	li	a5,-1
    80002882:	17fe                	slli	a5,a5,0x3f
    80002884:	8d5d                	or	a0,a0,a5
}
    80002886:	60e2                	ld	ra,24(sp)
    80002888:	6442                	ld	s0,16(sp)
    8000288a:	64a2                	ld	s1,8(sp)
    8000288c:	6902                	ld	s2,0(sp)
    8000288e:	6105                	addi	sp,sp,32
    80002890:	8082                	ret
      kexit(-1);
    80002892:	557d                	li	a0,-1
    80002894:	9a5ff0ef          	jal	80002238 <kexit>
    80002898:	b7c1                	j	80002858 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000289a:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000289e:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800028a2:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800028a4:	00163613          	seqz	a2,a2
    800028a8:	68a8                	ld	a0,80(s1)
    800028aa:	cb7fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800028ae:	f169                	bnez	a0,80002870 <usertrap+0xae>
    800028b0:	b7a5                	j	80002818 <usertrap+0x56>
  if(killed(p))
    800028b2:	8526                	mv	a0,s1
    800028b4:	acbff0ef          	jal	8000237e <killed>
    800028b8:	c511                	beqz	a0,800028c4 <usertrap+0x102>
    800028ba:	a011                	j	800028be <usertrap+0xfc>
    800028bc:	4901                	li	s2,0
    kexit(-1);
    800028be:	557d                	li	a0,-1
    800028c0:	979ff0ef          	jal	80002238 <kexit>
  if(which_dev == 2) {
    800028c4:	4789                	li	a5,2
    800028c6:	faf919e3          	bne	s2,a5,80002878 <usertrap+0xb6>
    p->time_slices++;
    800028ca:	16c4a783          	lw	a5,364(s1)
    800028ce:	2785                	addiw	a5,a5,1
    800028d0:	0007869b          	sext.w	a3,a5
    800028d4:	16f4a623          	sw	a5,364(s1)
    if(p->time_slices >= mlfq_time_quanta[p->priority]) {
    800028d8:	1684a703          	lw	a4,360(s1)
    800028dc:	00271613          	slli	a2,a4,0x2
    800028e0:	00008797          	auipc	a5,0x8
    800028e4:	96078793          	addi	a5,a5,-1696 # 8000a240 <mlfq_time_quanta>
    800028e8:	97b2                	add	a5,a5,a2
    800028ea:	439c                	lw	a5,0(a5)
    800028ec:	00f6ca63          	blt	a3,a5,80002900 <usertrap+0x13e>
      if(p->priority < NMLFQ - 1) {
    800028f0:	4789                	li	a5,2
    800028f2:	00e7c563          	blt	a5,a4,800028fc <usertrap+0x13a>
        p->priority++;  // Move to lower priority queue
    800028f6:	2705                	addiw	a4,a4,1
    800028f8:	16e4a423          	sw	a4,360(s1)
      p->time_slices = 0;  // Reset time slice counter for new queue
    800028fc:	1604a623          	sw	zero,364(s1)
    yield();
    80002900:	fc4ff0ef          	jal	800020c4 <yield>
    80002904:	bf95                	j	80002878 <usertrap+0xb6>

0000000080002906 <kerneltrap>:
{
    80002906:	7179                	addi	sp,sp,-48
    80002908:	f406                	sd	ra,40(sp)
    8000290a:	f022                	sd	s0,32(sp)
    8000290c:	ec26                	sd	s1,24(sp)
    8000290e:	e84a                	sd	s2,16(sp)
    80002910:	e44e                	sd	s3,8(sp)
    80002912:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002914:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002918:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002920:	1004f793          	andi	a5,s1,256
    80002924:	c795                	beqz	a5,80002950 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002926:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000292a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000292c:	eb85                	bnez	a5,8000295c <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000292e:	e21ff0ef          	jal	8000274e <devintr>
    80002932:	c91d                	beqz	a0,80002968 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002934:	4789                	li	a5,2
    80002936:	04f50a63          	beq	a0,a5,8000298a <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000293a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000293e:	10049073          	csrw	sstatus,s1
}
    80002942:	70a2                	ld	ra,40(sp)
    80002944:	7402                	ld	s0,32(sp)
    80002946:	64e2                	ld	s1,24(sp)
    80002948:	6942                	ld	s2,16(sp)
    8000294a:	69a2                	ld	s3,8(sp)
    8000294c:	6145                	addi	sp,sp,48
    8000294e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002950:	00005517          	auipc	a0,0x5
    80002954:	9a050513          	addi	a0,a0,-1632 # 800072f0 <etext+0x2f0>
    80002958:	e89fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000295c:	00005517          	auipc	a0,0x5
    80002960:	9bc50513          	addi	a0,a0,-1604 # 80007318 <etext+0x318>
    80002964:	e7dfd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002968:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000296c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002970:	85ce                	mv	a1,s3
    80002972:	00005517          	auipc	a0,0x5
    80002976:	9c650513          	addi	a0,a0,-1594 # 80007338 <etext+0x338>
    8000297a:	b81fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000297e:	00005517          	auipc	a0,0x5
    80002982:	9e250513          	addi	a0,a0,-1566 # 80007360 <etext+0x360>
    80002986:	e5bfd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000298a:	fc7fe0ef          	jal	80001950 <myproc>
    8000298e:	d555                	beqz	a0,8000293a <kerneltrap+0x34>
    yield();
    80002990:	f34ff0ef          	jal	800020c4 <yield>
    80002994:	b75d                	j	8000293a <kerneltrap+0x34>

0000000080002996 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002996:	1101                	addi	sp,sp,-32
    80002998:	ec06                	sd	ra,24(sp)
    8000299a:	e822                	sd	s0,16(sp)
    8000299c:	e426                	sd	s1,8(sp)
    8000299e:	1000                	addi	s0,sp,32
    800029a0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029a2:	faffe0ef          	jal	80001950 <myproc>
  switch (n) {
    800029a6:	4795                	li	a5,5
    800029a8:	0497e163          	bltu	a5,s1,800029ea <argraw+0x54>
    800029ac:	048a                	slli	s1,s1,0x2
    800029ae:	00005717          	auipc	a4,0x5
    800029b2:	db270713          	addi	a4,a4,-590 # 80007760 <states.0+0x30>
    800029b6:	94ba                	add	s1,s1,a4
    800029b8:	409c                	lw	a5,0(s1)
    800029ba:	97ba                	add	a5,a5,a4
    800029bc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029be:	6d3c                	ld	a5,88(a0)
    800029c0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029c2:	60e2                	ld	ra,24(sp)
    800029c4:	6442                	ld	s0,16(sp)
    800029c6:	64a2                	ld	s1,8(sp)
    800029c8:	6105                	addi	sp,sp,32
    800029ca:	8082                	ret
    return p->trapframe->a1;
    800029cc:	6d3c                	ld	a5,88(a0)
    800029ce:	7fa8                	ld	a0,120(a5)
    800029d0:	bfcd                	j	800029c2 <argraw+0x2c>
    return p->trapframe->a2;
    800029d2:	6d3c                	ld	a5,88(a0)
    800029d4:	63c8                	ld	a0,128(a5)
    800029d6:	b7f5                	j	800029c2 <argraw+0x2c>
    return p->trapframe->a3;
    800029d8:	6d3c                	ld	a5,88(a0)
    800029da:	67c8                	ld	a0,136(a5)
    800029dc:	b7dd                	j	800029c2 <argraw+0x2c>
    return p->trapframe->a4;
    800029de:	6d3c                	ld	a5,88(a0)
    800029e0:	6bc8                	ld	a0,144(a5)
    800029e2:	b7c5                	j	800029c2 <argraw+0x2c>
    return p->trapframe->a5;
    800029e4:	6d3c                	ld	a5,88(a0)
    800029e6:	6fc8                	ld	a0,152(a5)
    800029e8:	bfe9                	j	800029c2 <argraw+0x2c>
  panic("argraw");
    800029ea:	00005517          	auipc	a0,0x5
    800029ee:	98650513          	addi	a0,a0,-1658 # 80007370 <etext+0x370>
    800029f2:	deffd0ef          	jal	800007e0 <panic>

00000000800029f6 <fetchaddr>:
{
    800029f6:	1101                	addi	sp,sp,-32
    800029f8:	ec06                	sd	ra,24(sp)
    800029fa:	e822                	sd	s0,16(sp)
    800029fc:	e426                	sd	s1,8(sp)
    800029fe:	e04a                	sd	s2,0(sp)
    80002a00:	1000                	addi	s0,sp,32
    80002a02:	84aa                	mv	s1,a0
    80002a04:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a06:	f4bfe0ef          	jal	80001950 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a0a:	653c                	ld	a5,72(a0)
    80002a0c:	02f4f663          	bgeu	s1,a5,80002a38 <fetchaddr+0x42>
    80002a10:	00848713          	addi	a4,s1,8
    80002a14:	02e7e463          	bltu	a5,a4,80002a3c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a18:	46a1                	li	a3,8
    80002a1a:	8626                	mv	a2,s1
    80002a1c:	85ca                	mv	a1,s2
    80002a1e:	6928                	ld	a0,80(a0)
    80002a20:	ca7fe0ef          	jal	800016c6 <copyin>
    80002a24:	00a03533          	snez	a0,a0
    80002a28:	40a00533          	neg	a0,a0
}
    80002a2c:	60e2                	ld	ra,24(sp)
    80002a2e:	6442                	ld	s0,16(sp)
    80002a30:	64a2                	ld	s1,8(sp)
    80002a32:	6902                	ld	s2,0(sp)
    80002a34:	6105                	addi	sp,sp,32
    80002a36:	8082                	ret
    return -1;
    80002a38:	557d                	li	a0,-1
    80002a3a:	bfcd                	j	80002a2c <fetchaddr+0x36>
    80002a3c:	557d                	li	a0,-1
    80002a3e:	b7fd                	j	80002a2c <fetchaddr+0x36>

0000000080002a40 <fetchstr>:
{
    80002a40:	7179                	addi	sp,sp,-48
    80002a42:	f406                	sd	ra,40(sp)
    80002a44:	f022                	sd	s0,32(sp)
    80002a46:	ec26                	sd	s1,24(sp)
    80002a48:	e84a                	sd	s2,16(sp)
    80002a4a:	e44e                	sd	s3,8(sp)
    80002a4c:	1800                	addi	s0,sp,48
    80002a4e:	892a                	mv	s2,a0
    80002a50:	84ae                	mv	s1,a1
    80002a52:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a54:	efdfe0ef          	jal	80001950 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a58:	86ce                	mv	a3,s3
    80002a5a:	864a                	mv	a2,s2
    80002a5c:	85a6                	mv	a1,s1
    80002a5e:	6928                	ld	a0,80(a0)
    80002a60:	a29fe0ef          	jal	80001488 <copyinstr>
    80002a64:	00054c63          	bltz	a0,80002a7c <fetchstr+0x3c>
  return strlen(buf);
    80002a68:	8526                	mv	a0,s1
    80002a6a:	ba8fe0ef          	jal	80000e12 <strlen>
}
    80002a6e:	70a2                	ld	ra,40(sp)
    80002a70:	7402                	ld	s0,32(sp)
    80002a72:	64e2                	ld	s1,24(sp)
    80002a74:	6942                	ld	s2,16(sp)
    80002a76:	69a2                	ld	s3,8(sp)
    80002a78:	6145                	addi	sp,sp,48
    80002a7a:	8082                	ret
    return -1;
    80002a7c:	557d                	li	a0,-1
    80002a7e:	bfc5                	j	80002a6e <fetchstr+0x2e>

0000000080002a80 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a80:	1101                	addi	sp,sp,-32
    80002a82:	ec06                	sd	ra,24(sp)
    80002a84:	e822                	sd	s0,16(sp)
    80002a86:	e426                	sd	s1,8(sp)
    80002a88:	1000                	addi	s0,sp,32
    80002a8a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a8c:	f0bff0ef          	jal	80002996 <argraw>
    80002a90:	c088                	sw	a0,0(s1)
}
    80002a92:	60e2                	ld	ra,24(sp)
    80002a94:	6442                	ld	s0,16(sp)
    80002a96:	64a2                	ld	s1,8(sp)
    80002a98:	6105                	addi	sp,sp,32
    80002a9a:	8082                	ret

0000000080002a9c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a9c:	1101                	addi	sp,sp,-32
    80002a9e:	ec06                	sd	ra,24(sp)
    80002aa0:	e822                	sd	s0,16(sp)
    80002aa2:	e426                	sd	s1,8(sp)
    80002aa4:	1000                	addi	s0,sp,32
    80002aa6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002aa8:	eefff0ef          	jal	80002996 <argraw>
    80002aac:	e088                	sd	a0,0(s1)
}
    80002aae:	60e2                	ld	ra,24(sp)
    80002ab0:	6442                	ld	s0,16(sp)
    80002ab2:	64a2                	ld	s1,8(sp)
    80002ab4:	6105                	addi	sp,sp,32
    80002ab6:	8082                	ret

0000000080002ab8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ab8:	7179                	addi	sp,sp,-48
    80002aba:	f406                	sd	ra,40(sp)
    80002abc:	f022                	sd	s0,32(sp)
    80002abe:	ec26                	sd	s1,24(sp)
    80002ac0:	e84a                	sd	s2,16(sp)
    80002ac2:	1800                	addi	s0,sp,48
    80002ac4:	84ae                	mv	s1,a1
    80002ac6:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ac8:	fd840593          	addi	a1,s0,-40
    80002acc:	fd1ff0ef          	jal	80002a9c <argaddr>
  return fetchstr(addr, buf, max);
    80002ad0:	864a                	mv	a2,s2
    80002ad2:	85a6                	mv	a1,s1
    80002ad4:	fd843503          	ld	a0,-40(s0)
    80002ad8:	f69ff0ef          	jal	80002a40 <fetchstr>
}
    80002adc:	70a2                	ld	ra,40(sp)
    80002ade:	7402                	ld	s0,32(sp)
    80002ae0:	64e2                	ld	s1,24(sp)
    80002ae2:	6942                	ld	s2,16(sp)
    80002ae4:	6145                	addi	sp,sp,48
    80002ae6:	8082                	ret

0000000080002ae8 <syscall>:
[SYS_boostproc] sys_boostproc,
};

void
syscall(void)
{
    80002ae8:	1101                	addi	sp,sp,-32
    80002aea:	ec06                	sd	ra,24(sp)
    80002aec:	e822                	sd	s0,16(sp)
    80002aee:	e426                	sd	s1,8(sp)
    80002af0:	e04a                	sd	s2,0(sp)
    80002af2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002af4:	e5dfe0ef          	jal	80001950 <myproc>
    80002af8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002afa:	05853903          	ld	s2,88(a0)
    80002afe:	0a893783          	ld	a5,168(s2)
    80002b02:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b06:	37fd                	addiw	a5,a5,-1
    80002b08:	4759                	li	a4,22
    80002b0a:	00f76f63          	bltu	a4,a5,80002b28 <syscall+0x40>
    80002b0e:	00369713          	slli	a4,a3,0x3
    80002b12:	00005797          	auipc	a5,0x5
    80002b16:	c6678793          	addi	a5,a5,-922 # 80007778 <syscalls>
    80002b1a:	97ba                	add	a5,a5,a4
    80002b1c:	639c                	ld	a5,0(a5)
    80002b1e:	c789                	beqz	a5,80002b28 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b20:	9782                	jalr	a5
    80002b22:	06a93823          	sd	a0,112(s2)
    80002b26:	a829                	j	80002b40 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b28:	15848613          	addi	a2,s1,344
    80002b2c:	588c                	lw	a1,48(s1)
    80002b2e:	00005517          	auipc	a0,0x5
    80002b32:	84a50513          	addi	a0,a0,-1974 # 80007378 <etext+0x378>
    80002b36:	9c5fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b3a:	6cbc                	ld	a5,88(s1)
    80002b3c:	577d                	li	a4,-1
    80002b3e:	fbb8                	sd	a4,112(a5)
  }
}
    80002b40:	60e2                	ld	ra,24(sp)
    80002b42:	6442                	ld	s0,16(sp)
    80002b44:	64a2                	ld	s1,8(sp)
    80002b46:	6902                	ld	s2,0(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret

0000000080002b4c <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b4c:	1101                	addi	sp,sp,-32
    80002b4e:	ec06                	sd	ra,24(sp)
    80002b50:	e822                	sd	s0,16(sp)
    80002b52:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b54:	fec40593          	addi	a1,s0,-20
    80002b58:	4501                	li	a0,0
    80002b5a:	f27ff0ef          	jal	80002a80 <argint>
  kexit(n);
    80002b5e:	fec42503          	lw	a0,-20(s0)
    80002b62:	ed6ff0ef          	jal	80002238 <kexit>
  return 0;  // not reached
}
    80002b66:	4501                	li	a0,0
    80002b68:	60e2                	ld	ra,24(sp)
    80002b6a:	6442                	ld	s0,16(sp)
    80002b6c:	6105                	addi	sp,sp,32
    80002b6e:	8082                	ret

0000000080002b70 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b70:	1141                	addi	sp,sp,-16
    80002b72:	e406                	sd	ra,8(sp)
    80002b74:	e022                	sd	s0,0(sp)
    80002b76:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b78:	dd9fe0ef          	jal	80001950 <myproc>
}
    80002b7c:	5908                	lw	a0,48(a0)
    80002b7e:	60a2                	ld	ra,8(sp)
    80002b80:	6402                	ld	s0,0(sp)
    80002b82:	0141                	addi	sp,sp,16
    80002b84:	8082                	ret

0000000080002b86 <sys_fork>:

uint64
sys_fork(void)
{
    80002b86:	1141                	addi	sp,sp,-16
    80002b88:	e406                	sd	ra,8(sp)
    80002b8a:	e022                	sd	s0,0(sp)
    80002b8c:	0800                	addi	s0,sp,16
  return kfork();
    80002b8e:	950ff0ef          	jal	80001cde <kfork>
}
    80002b92:	60a2                	ld	ra,8(sp)
    80002b94:	6402                	ld	s0,0(sp)
    80002b96:	0141                	addi	sp,sp,16
    80002b98:	8082                	ret

0000000080002b9a <sys_wait>:

uint64
sys_wait(void)
{
    80002b9a:	1101                	addi	sp,sp,-32
    80002b9c:	ec06                	sd	ra,24(sp)
    80002b9e:	e822                	sd	s0,16(sp)
    80002ba0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ba2:	fe840593          	addi	a1,s0,-24
    80002ba6:	4501                	li	a0,0
    80002ba8:	ef5ff0ef          	jal	80002a9c <argaddr>
  return kwait(p);
    80002bac:	fe843503          	ld	a0,-24(s0)
    80002bb0:	ff8ff0ef          	jal	800023a8 <kwait>
}
    80002bb4:	60e2                	ld	ra,24(sp)
    80002bb6:	6442                	ld	s0,16(sp)
    80002bb8:	6105                	addi	sp,sp,32
    80002bba:	8082                	ret

0000000080002bbc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002bbc:	7179                	addi	sp,sp,-48
    80002bbe:	f406                	sd	ra,40(sp)
    80002bc0:	f022                	sd	s0,32(sp)
    80002bc2:	ec26                	sd	s1,24(sp)
    80002bc4:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002bc6:	fd840593          	addi	a1,s0,-40
    80002bca:	4501                	li	a0,0
    80002bcc:	eb5ff0ef          	jal	80002a80 <argint>
  argint(1, &t);
    80002bd0:	fdc40593          	addi	a1,s0,-36
    80002bd4:	4505                	li	a0,1
    80002bd6:	eabff0ef          	jal	80002a80 <argint>
  addr = myproc()->sz;
    80002bda:	d77fe0ef          	jal	80001950 <myproc>
    80002bde:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002be0:	fdc42703          	lw	a4,-36(s0)
    80002be4:	4785                	li	a5,1
    80002be6:	02f70763          	beq	a4,a5,80002c14 <sys_sbrk+0x58>
    80002bea:	fd842783          	lw	a5,-40(s0)
    80002bee:	0207c363          	bltz	a5,80002c14 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bf2:	97a6                	add	a5,a5,s1
    80002bf4:	0297ee63          	bltu	a5,s1,80002c30 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002bf8:	02000737          	lui	a4,0x2000
    80002bfc:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bfe:	0736                	slli	a4,a4,0xd
    80002c00:	02f76a63          	bltu	a4,a5,80002c34 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002c04:	d4dfe0ef          	jal	80001950 <myproc>
    80002c08:	fd842703          	lw	a4,-40(s0)
    80002c0c:	653c                	ld	a5,72(a0)
    80002c0e:	97ba                	add	a5,a5,a4
    80002c10:	e53c                	sd	a5,72(a0)
    80002c12:	a039                	j	80002c20 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002c14:	fd842503          	lw	a0,-40(s0)
    80002c18:	864ff0ef          	jal	80001c7c <growproc>
    80002c1c:	00054863          	bltz	a0,80002c2c <sys_sbrk+0x70>
  }
  return addr;
}
    80002c20:	8526                	mv	a0,s1
    80002c22:	70a2                	ld	ra,40(sp)
    80002c24:	7402                	ld	s0,32(sp)
    80002c26:	64e2                	ld	s1,24(sp)
    80002c28:	6145                	addi	sp,sp,48
    80002c2a:	8082                	ret
      return -1;
    80002c2c:	54fd                	li	s1,-1
    80002c2e:	bfcd                	j	80002c20 <sys_sbrk+0x64>
      return -1;
    80002c30:	54fd                	li	s1,-1
    80002c32:	b7fd                	j	80002c20 <sys_sbrk+0x64>
      return -1;
    80002c34:	54fd                	li	s1,-1
    80002c36:	b7ed                	j	80002c20 <sys_sbrk+0x64>

0000000080002c38 <sys_pause>:

uint64
sys_pause(void)
{
    80002c38:	7139                	addi	sp,sp,-64
    80002c3a:	fc06                	sd	ra,56(sp)
    80002c3c:	f822                	sd	s0,48(sp)
    80002c3e:	f04a                	sd	s2,32(sp)
    80002c40:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c42:	fcc40593          	addi	a1,s0,-52
    80002c46:	4501                	li	a0,0
    80002c48:	e39ff0ef          	jal	80002a80 <argint>
  if(n < 0)
    80002c4c:	fcc42783          	lw	a5,-52(s0)
    80002c50:	0607c763          	bltz	a5,80002cbe <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c54:	00016517          	auipc	a0,0x16
    80002c58:	9dc50513          	addi	a0,a0,-1572 # 80018630 <tickslock>
    80002c5c:	f73fd0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002c60:	00007917          	auipc	s2,0x7
    80002c64:	64092903          	lw	s2,1600(s2) # 8000a2a0 <ticks>
  while(ticks - ticks0 < n){
    80002c68:	fcc42783          	lw	a5,-52(s0)
    80002c6c:	cf8d                	beqz	a5,80002ca6 <sys_pause+0x6e>
    80002c6e:	f426                	sd	s1,40(sp)
    80002c70:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c72:	00016997          	auipc	s3,0x16
    80002c76:	9be98993          	addi	s3,s3,-1602 # 80018630 <tickslock>
    80002c7a:	00007497          	auipc	s1,0x7
    80002c7e:	62648493          	addi	s1,s1,1574 # 8000a2a0 <ticks>
    if(killed(myproc())){
    80002c82:	ccffe0ef          	jal	80001950 <myproc>
    80002c86:	ef8ff0ef          	jal	8000237e <killed>
    80002c8a:	ed0d                	bnez	a0,80002cc4 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c8c:	85ce                	mv	a1,s3
    80002c8e:	8526                	mv	a0,s1
    80002c90:	c7eff0ef          	jal	8000210e <sleep>
  while(ticks - ticks0 < n){
    80002c94:	409c                	lw	a5,0(s1)
    80002c96:	412787bb          	subw	a5,a5,s2
    80002c9a:	fcc42703          	lw	a4,-52(s0)
    80002c9e:	fee7e2e3          	bltu	a5,a4,80002c82 <sys_pause+0x4a>
    80002ca2:	74a2                	ld	s1,40(sp)
    80002ca4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002ca6:	00016517          	auipc	a0,0x16
    80002caa:	98a50513          	addi	a0,a0,-1654 # 80018630 <tickslock>
    80002cae:	fb9fd0ef          	jal	80000c66 <release>
  return 0;
    80002cb2:	4501                	li	a0,0
}
    80002cb4:	70e2                	ld	ra,56(sp)
    80002cb6:	7442                	ld	s0,48(sp)
    80002cb8:	7902                	ld	s2,32(sp)
    80002cba:	6121                	addi	sp,sp,64
    80002cbc:	8082                	ret
    n = 0;
    80002cbe:	fc042623          	sw	zero,-52(s0)
    80002cc2:	bf49                	j	80002c54 <sys_pause+0x1c>
      release(&tickslock);
    80002cc4:	00016517          	auipc	a0,0x16
    80002cc8:	96c50513          	addi	a0,a0,-1684 # 80018630 <tickslock>
    80002ccc:	f9bfd0ef          	jal	80000c66 <release>
      return -1;
    80002cd0:	557d                	li	a0,-1
    80002cd2:	74a2                	ld	s1,40(sp)
    80002cd4:	69e2                	ld	s3,24(sp)
    80002cd6:	bff9                	j	80002cb4 <sys_pause+0x7c>

0000000080002cd8 <sys_kill>:

uint64
sys_kill(void)
{
    80002cd8:	1101                	addi	sp,sp,-32
    80002cda:	ec06                	sd	ra,24(sp)
    80002cdc:	e822                	sd	s0,16(sp)
    80002cde:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ce0:	fec40593          	addi	a1,s0,-20
    80002ce4:	4501                	li	a0,0
    80002ce6:	d9bff0ef          	jal	80002a80 <argint>
  return kkill(pid);
    80002cea:	fec42503          	lw	a0,-20(s0)
    80002cee:	decff0ef          	jal	800022da <kkill>
}
    80002cf2:	60e2                	ld	ra,24(sp)
    80002cf4:	6442                	ld	s0,16(sp)
    80002cf6:	6105                	addi	sp,sp,32
    80002cf8:	8082                	ret

0000000080002cfa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cfa:	1101                	addi	sp,sp,-32
    80002cfc:	ec06                	sd	ra,24(sp)
    80002cfe:	e822                	sd	s0,16(sp)
    80002d00:	e426                	sd	s1,8(sp)
    80002d02:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d04:	00016517          	auipc	a0,0x16
    80002d08:	92c50513          	addi	a0,a0,-1748 # 80018630 <tickslock>
    80002d0c:	ec3fd0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002d10:	00007497          	auipc	s1,0x7
    80002d14:	5904a483          	lw	s1,1424(s1) # 8000a2a0 <ticks>
  release(&tickslock);
    80002d18:	00016517          	auipc	a0,0x16
    80002d1c:	91850513          	addi	a0,a0,-1768 # 80018630 <tickslock>
    80002d20:	f47fd0ef          	jal	80000c66 <release>
  return xticks;
}
    80002d24:	02049513          	slli	a0,s1,0x20
    80002d28:	9101                	srli	a0,a0,0x20
    80002d2a:	60e2                	ld	ra,24(sp)
    80002d2c:	6442                	ld	s0,16(sp)
    80002d2e:	64a2                	ld	s1,8(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret

0000000080002d34 <sys_getprocinfo>:

// Get process information for MLFQ debugging
uint64
sys_getprocinfo(void)
{
    80002d34:	7139                	addi	sp,sp,-64
    80002d36:	fc06                	sd	ra,56(sp)
    80002d38:	f822                	sd	s0,48(sp)
    80002d3a:	f426                	sd	s1,40(sp)
    80002d3c:	0080                	addi	s0,sp,64
  uint64 addr;
  struct proc *p = myproc();
    80002d3e:	c13fe0ef          	jal	80001950 <myproc>
    80002d42:	84aa                	mv	s1,a0
  
  argaddr(0, &addr);
    80002d44:	fd840593          	addi	a1,s0,-40
    80002d48:	4501                	li	a0,0
    80002d4a:	d53ff0ef          	jal	80002a9c <argaddr>
    int state;
    int priority;
    int time_slices;
  } info;
  
  acquire(&p->lock);
    80002d4e:	8526                	mv	a0,s1
    80002d50:	e7ffd0ef          	jal	80000bce <acquire>
  info.pid = p->pid;
    80002d54:	589c                	lw	a5,48(s1)
    80002d56:	fcf42423          	sw	a5,-56(s0)
  info.state = p->state;
    80002d5a:	4c9c                	lw	a5,24(s1)
    80002d5c:	fcf42623          	sw	a5,-52(s0)
  info.priority = p->priority;
    80002d60:	1684a783          	lw	a5,360(s1)
    80002d64:	fcf42823          	sw	a5,-48(s0)
  info.time_slices = p->time_slices;
    80002d68:	16c4a783          	lw	a5,364(s1)
    80002d6c:	fcf42a23          	sw	a5,-44(s0)
  release(&p->lock);
    80002d70:	8526                	mv	a0,s1
    80002d72:	ef5fd0ef          	jal	80000c66 <release>
  
  if(copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    80002d76:	46c1                	li	a3,16
    80002d78:	fc840613          	addi	a2,s0,-56
    80002d7c:	fd843583          	ld	a1,-40(s0)
    80002d80:	68a8                	ld	a0,80(s1)
    80002d82:	861fe0ef          	jal	800015e2 <copyout>
    return -1;
  
  return 0;
}
    80002d86:	957d                	srai	a0,a0,0x3f
    80002d88:	70e2                	ld	ra,56(sp)
    80002d8a:	7442                	ld	s0,48(sp)
    80002d8c:	74a2                	ld	s1,40(sp)
    80002d8e:	6121                	addi	sp,sp,64
    80002d90:	8082                	ret

0000000080002d92 <sys_boostproc>:

uint64
sys_boostproc(void)
{
    80002d92:	1141                	addi	sp,sp,-16
    80002d94:	e406                	sd	ra,8(sp)
    80002d96:	e022                	sd	s0,0(sp)
    80002d98:	0800                	addi	s0,sp,16
  extern void boost_all_priorities(void);
  
  boost_all_priorities();
    80002d9a:	86cff0ef          	jal	80001e06 <boost_all_priorities>
  
  return 0;
    80002d9e:	4501                	li	a0,0
    80002da0:	60a2                	ld	ra,8(sp)
    80002da2:	6402                	ld	s0,0(sp)
    80002da4:	0141                	addi	sp,sp,16
    80002da6:	8082                	ret

0000000080002da8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002da8:	7179                	addi	sp,sp,-48
    80002daa:	f406                	sd	ra,40(sp)
    80002dac:	f022                	sd	s0,32(sp)
    80002dae:	ec26                	sd	s1,24(sp)
    80002db0:	e84a                	sd	s2,16(sp)
    80002db2:	e44e                	sd	s3,8(sp)
    80002db4:	e052                	sd	s4,0(sp)
    80002db6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002db8:	00004597          	auipc	a1,0x4
    80002dbc:	5e058593          	addi	a1,a1,1504 # 80007398 <etext+0x398>
    80002dc0:	00016517          	auipc	a0,0x16
    80002dc4:	88850513          	addi	a0,a0,-1912 # 80018648 <bcache>
    80002dc8:	d87fd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dcc:	0001e797          	auipc	a5,0x1e
    80002dd0:	87c78793          	addi	a5,a5,-1924 # 80020648 <bcache+0x8000>
    80002dd4:	0001e717          	auipc	a4,0x1e
    80002dd8:	adc70713          	addi	a4,a4,-1316 # 800208b0 <bcache+0x8268>
    80002ddc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002de0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002de4:	00016497          	auipc	s1,0x16
    80002de8:	87c48493          	addi	s1,s1,-1924 # 80018660 <bcache+0x18>
    b->next = bcache.head.next;
    80002dec:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dee:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002df0:	00004a17          	auipc	s4,0x4
    80002df4:	5b0a0a13          	addi	s4,s4,1456 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002df8:	2b893783          	ld	a5,696(s2)
    80002dfc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dfe:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e02:	85d2                	mv	a1,s4
    80002e04:	01048513          	addi	a0,s1,16
    80002e08:	322010ef          	jal	8000412a <initsleeplock>
    bcache.head.next->prev = b;
    80002e0c:	2b893783          	ld	a5,696(s2)
    80002e10:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e12:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e16:	45848493          	addi	s1,s1,1112
    80002e1a:	fd349fe3          	bne	s1,s3,80002df8 <binit+0x50>
  }
}
    80002e1e:	70a2                	ld	ra,40(sp)
    80002e20:	7402                	ld	s0,32(sp)
    80002e22:	64e2                	ld	s1,24(sp)
    80002e24:	6942                	ld	s2,16(sp)
    80002e26:	69a2                	ld	s3,8(sp)
    80002e28:	6a02                	ld	s4,0(sp)
    80002e2a:	6145                	addi	sp,sp,48
    80002e2c:	8082                	ret

0000000080002e2e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e2e:	7179                	addi	sp,sp,-48
    80002e30:	f406                	sd	ra,40(sp)
    80002e32:	f022                	sd	s0,32(sp)
    80002e34:	ec26                	sd	s1,24(sp)
    80002e36:	e84a                	sd	s2,16(sp)
    80002e38:	e44e                	sd	s3,8(sp)
    80002e3a:	1800                	addi	s0,sp,48
    80002e3c:	892a                	mv	s2,a0
    80002e3e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e40:	00016517          	auipc	a0,0x16
    80002e44:	80850513          	addi	a0,a0,-2040 # 80018648 <bcache>
    80002e48:	d87fd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e4c:	0001e497          	auipc	s1,0x1e
    80002e50:	ab44b483          	ld	s1,-1356(s1) # 80020900 <bcache+0x82b8>
    80002e54:	0001e797          	auipc	a5,0x1e
    80002e58:	a5c78793          	addi	a5,a5,-1444 # 800208b0 <bcache+0x8268>
    80002e5c:	02f48b63          	beq	s1,a5,80002e92 <bread+0x64>
    80002e60:	873e                	mv	a4,a5
    80002e62:	a021                	j	80002e6a <bread+0x3c>
    80002e64:	68a4                	ld	s1,80(s1)
    80002e66:	02e48663          	beq	s1,a4,80002e92 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002e6a:	449c                	lw	a5,8(s1)
    80002e6c:	ff279ce3          	bne	a5,s2,80002e64 <bread+0x36>
    80002e70:	44dc                	lw	a5,12(s1)
    80002e72:	ff3799e3          	bne	a5,s3,80002e64 <bread+0x36>
      b->refcnt++;
    80002e76:	40bc                	lw	a5,64(s1)
    80002e78:	2785                	addiw	a5,a5,1
    80002e7a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e7c:	00015517          	auipc	a0,0x15
    80002e80:	7cc50513          	addi	a0,a0,1996 # 80018648 <bcache>
    80002e84:	de3fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002e88:	01048513          	addi	a0,s1,16
    80002e8c:	2d4010ef          	jal	80004160 <acquiresleep>
      return b;
    80002e90:	a889                	j	80002ee2 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e92:	0001e497          	auipc	s1,0x1e
    80002e96:	a664b483          	ld	s1,-1434(s1) # 800208f8 <bcache+0x82b0>
    80002e9a:	0001e797          	auipc	a5,0x1e
    80002e9e:	a1678793          	addi	a5,a5,-1514 # 800208b0 <bcache+0x8268>
    80002ea2:	00f48863          	beq	s1,a5,80002eb2 <bread+0x84>
    80002ea6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ea8:	40bc                	lw	a5,64(s1)
    80002eaa:	cb91                	beqz	a5,80002ebe <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002eac:	64a4                	ld	s1,72(s1)
    80002eae:	fee49de3          	bne	s1,a4,80002ea8 <bread+0x7a>
  panic("bget: no buffers");
    80002eb2:	00004517          	auipc	a0,0x4
    80002eb6:	4f650513          	addi	a0,a0,1270 # 800073a8 <etext+0x3a8>
    80002eba:	927fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002ebe:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ec2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ec6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002eca:	4785                	li	a5,1
    80002ecc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ece:	00015517          	auipc	a0,0x15
    80002ed2:	77a50513          	addi	a0,a0,1914 # 80018648 <bcache>
    80002ed6:	d91fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002eda:	01048513          	addi	a0,s1,16
    80002ede:	282010ef          	jal	80004160 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ee2:	409c                	lw	a5,0(s1)
    80002ee4:	cb89                	beqz	a5,80002ef6 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ee6:	8526                	mv	a0,s1
    80002ee8:	70a2                	ld	ra,40(sp)
    80002eea:	7402                	ld	s0,32(sp)
    80002eec:	64e2                	ld	s1,24(sp)
    80002eee:	6942                	ld	s2,16(sp)
    80002ef0:	69a2                	ld	s3,8(sp)
    80002ef2:	6145                	addi	sp,sp,48
    80002ef4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ef6:	4581                	li	a1,0
    80002ef8:	8526                	mv	a0,s1
    80002efa:	2d7020ef          	jal	800059d0 <virtio_disk_rw>
    b->valid = 1;
    80002efe:	4785                	li	a5,1
    80002f00:	c09c                	sw	a5,0(s1)
  return b;
    80002f02:	b7d5                	j	80002ee6 <bread+0xb8>

0000000080002f04 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f04:	1101                	addi	sp,sp,-32
    80002f06:	ec06                	sd	ra,24(sp)
    80002f08:	e822                	sd	s0,16(sp)
    80002f0a:	e426                	sd	s1,8(sp)
    80002f0c:	1000                	addi	s0,sp,32
    80002f0e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f10:	0541                	addi	a0,a0,16
    80002f12:	2cc010ef          	jal	800041de <holdingsleep>
    80002f16:	c911                	beqz	a0,80002f2a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f18:	4585                	li	a1,1
    80002f1a:	8526                	mv	a0,s1
    80002f1c:	2b5020ef          	jal	800059d0 <virtio_disk_rw>
}
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	64a2                	ld	s1,8(sp)
    80002f26:	6105                	addi	sp,sp,32
    80002f28:	8082                	ret
    panic("bwrite");
    80002f2a:	00004517          	auipc	a0,0x4
    80002f2e:	49650513          	addi	a0,a0,1174 # 800073c0 <etext+0x3c0>
    80002f32:	8affd0ef          	jal	800007e0 <panic>

0000000080002f36 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f36:	1101                	addi	sp,sp,-32
    80002f38:	ec06                	sd	ra,24(sp)
    80002f3a:	e822                	sd	s0,16(sp)
    80002f3c:	e426                	sd	s1,8(sp)
    80002f3e:	e04a                	sd	s2,0(sp)
    80002f40:	1000                	addi	s0,sp,32
    80002f42:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f44:	01050913          	addi	s2,a0,16
    80002f48:	854a                	mv	a0,s2
    80002f4a:	294010ef          	jal	800041de <holdingsleep>
    80002f4e:	c135                	beqz	a0,80002fb2 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f50:	854a                	mv	a0,s2
    80002f52:	254010ef          	jal	800041a6 <releasesleep>

  acquire(&bcache.lock);
    80002f56:	00015517          	auipc	a0,0x15
    80002f5a:	6f250513          	addi	a0,a0,1778 # 80018648 <bcache>
    80002f5e:	c71fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002f62:	40bc                	lw	a5,64(s1)
    80002f64:	37fd                	addiw	a5,a5,-1
    80002f66:	0007871b          	sext.w	a4,a5
    80002f6a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f6c:	e71d                	bnez	a4,80002f9a <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f6e:	68b8                	ld	a4,80(s1)
    80002f70:	64bc                	ld	a5,72(s1)
    80002f72:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f74:	68b8                	ld	a4,80(s1)
    80002f76:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f78:	0001d797          	auipc	a5,0x1d
    80002f7c:	6d078793          	addi	a5,a5,1744 # 80020648 <bcache+0x8000>
    80002f80:	2b87b703          	ld	a4,696(a5)
    80002f84:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f86:	0001e717          	auipc	a4,0x1e
    80002f8a:	92a70713          	addi	a4,a4,-1750 # 800208b0 <bcache+0x8268>
    80002f8e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f90:	2b87b703          	ld	a4,696(a5)
    80002f94:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f96:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f9a:	00015517          	auipc	a0,0x15
    80002f9e:	6ae50513          	addi	a0,a0,1710 # 80018648 <bcache>
    80002fa2:	cc5fd0ef          	jal	80000c66 <release>
}
    80002fa6:	60e2                	ld	ra,24(sp)
    80002fa8:	6442                	ld	s0,16(sp)
    80002faa:	64a2                	ld	s1,8(sp)
    80002fac:	6902                	ld	s2,0(sp)
    80002fae:	6105                	addi	sp,sp,32
    80002fb0:	8082                	ret
    panic("brelse");
    80002fb2:	00004517          	auipc	a0,0x4
    80002fb6:	41650513          	addi	a0,a0,1046 # 800073c8 <etext+0x3c8>
    80002fba:	827fd0ef          	jal	800007e0 <panic>

0000000080002fbe <bpin>:

void
bpin(struct buf *b) {
    80002fbe:	1101                	addi	sp,sp,-32
    80002fc0:	ec06                	sd	ra,24(sp)
    80002fc2:	e822                	sd	s0,16(sp)
    80002fc4:	e426                	sd	s1,8(sp)
    80002fc6:	1000                	addi	s0,sp,32
    80002fc8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fca:	00015517          	auipc	a0,0x15
    80002fce:	67e50513          	addi	a0,a0,1662 # 80018648 <bcache>
    80002fd2:	bfdfd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002fd6:	40bc                	lw	a5,64(s1)
    80002fd8:	2785                	addiw	a5,a5,1
    80002fda:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fdc:	00015517          	auipc	a0,0x15
    80002fe0:	66c50513          	addi	a0,a0,1644 # 80018648 <bcache>
    80002fe4:	c83fd0ef          	jal	80000c66 <release>
}
    80002fe8:	60e2                	ld	ra,24(sp)
    80002fea:	6442                	ld	s0,16(sp)
    80002fec:	64a2                	ld	s1,8(sp)
    80002fee:	6105                	addi	sp,sp,32
    80002ff0:	8082                	ret

0000000080002ff2 <bunpin>:

void
bunpin(struct buf *b) {
    80002ff2:	1101                	addi	sp,sp,-32
    80002ff4:	ec06                	sd	ra,24(sp)
    80002ff6:	e822                	sd	s0,16(sp)
    80002ff8:	e426                	sd	s1,8(sp)
    80002ffa:	1000                	addi	s0,sp,32
    80002ffc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ffe:	00015517          	auipc	a0,0x15
    80003002:	64a50513          	addi	a0,a0,1610 # 80018648 <bcache>
    80003006:	bc9fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    8000300a:	40bc                	lw	a5,64(s1)
    8000300c:	37fd                	addiw	a5,a5,-1
    8000300e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003010:	00015517          	auipc	a0,0x15
    80003014:	63850513          	addi	a0,a0,1592 # 80018648 <bcache>
    80003018:	c4ffd0ef          	jal	80000c66 <release>
}
    8000301c:	60e2                	ld	ra,24(sp)
    8000301e:	6442                	ld	s0,16(sp)
    80003020:	64a2                	ld	s1,8(sp)
    80003022:	6105                	addi	sp,sp,32
    80003024:	8082                	ret

0000000080003026 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003026:	1101                	addi	sp,sp,-32
    80003028:	ec06                	sd	ra,24(sp)
    8000302a:	e822                	sd	s0,16(sp)
    8000302c:	e426                	sd	s1,8(sp)
    8000302e:	e04a                	sd	s2,0(sp)
    80003030:	1000                	addi	s0,sp,32
    80003032:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003034:	00d5d59b          	srliw	a1,a1,0xd
    80003038:	0001e797          	auipc	a5,0x1e
    8000303c:	cec7a783          	lw	a5,-788(a5) # 80020d24 <sb+0x1c>
    80003040:	9dbd                	addw	a1,a1,a5
    80003042:	dedff0ef          	jal	80002e2e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003046:	0074f713          	andi	a4,s1,7
    8000304a:	4785                	li	a5,1
    8000304c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003050:	14ce                	slli	s1,s1,0x33
    80003052:	90d9                	srli	s1,s1,0x36
    80003054:	00950733          	add	a4,a0,s1
    80003058:	05874703          	lbu	a4,88(a4)
    8000305c:	00e7f6b3          	and	a3,a5,a4
    80003060:	c29d                	beqz	a3,80003086 <bfree+0x60>
    80003062:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003064:	94aa                	add	s1,s1,a0
    80003066:	fff7c793          	not	a5,a5
    8000306a:	8f7d                	and	a4,a4,a5
    8000306c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003070:	7f9000ef          	jal	80004068 <log_write>
  brelse(bp);
    80003074:	854a                	mv	a0,s2
    80003076:	ec1ff0ef          	jal	80002f36 <brelse>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	64a2                	ld	s1,8(sp)
    80003080:	6902                	ld	s2,0(sp)
    80003082:	6105                	addi	sp,sp,32
    80003084:	8082                	ret
    panic("freeing free block");
    80003086:	00004517          	auipc	a0,0x4
    8000308a:	34a50513          	addi	a0,a0,842 # 800073d0 <etext+0x3d0>
    8000308e:	f52fd0ef          	jal	800007e0 <panic>

0000000080003092 <balloc>:
{
    80003092:	711d                	addi	sp,sp,-96
    80003094:	ec86                	sd	ra,88(sp)
    80003096:	e8a2                	sd	s0,80(sp)
    80003098:	e4a6                	sd	s1,72(sp)
    8000309a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000309c:	0001e797          	auipc	a5,0x1e
    800030a0:	c707a783          	lw	a5,-912(a5) # 80020d0c <sb+0x4>
    800030a4:	0e078f63          	beqz	a5,800031a2 <balloc+0x110>
    800030a8:	e0ca                	sd	s2,64(sp)
    800030aa:	fc4e                	sd	s3,56(sp)
    800030ac:	f852                	sd	s4,48(sp)
    800030ae:	f456                	sd	s5,40(sp)
    800030b0:	f05a                	sd	s6,32(sp)
    800030b2:	ec5e                	sd	s7,24(sp)
    800030b4:	e862                	sd	s8,16(sp)
    800030b6:	e466                	sd	s9,8(sp)
    800030b8:	8baa                	mv	s7,a0
    800030ba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030bc:	0001eb17          	auipc	s6,0x1e
    800030c0:	c4cb0b13          	addi	s6,s6,-948 # 80020d08 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030c4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800030c6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030c8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030ca:	6c89                	lui	s9,0x2
    800030cc:	a0b5                	j	80003138 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800030ce:	97ca                	add	a5,a5,s2
    800030d0:	8e55                	or	a2,a2,a3
    800030d2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800030d6:	854a                	mv	a0,s2
    800030d8:	791000ef          	jal	80004068 <log_write>
        brelse(bp);
    800030dc:	854a                	mv	a0,s2
    800030de:	e59ff0ef          	jal	80002f36 <brelse>
  bp = bread(dev, bno);
    800030e2:	85a6                	mv	a1,s1
    800030e4:	855e                	mv	a0,s7
    800030e6:	d49ff0ef          	jal	80002e2e <bread>
    800030ea:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800030ec:	40000613          	li	a2,1024
    800030f0:	4581                	li	a1,0
    800030f2:	05850513          	addi	a0,a0,88
    800030f6:	badfd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    800030fa:	854a                	mv	a0,s2
    800030fc:	76d000ef          	jal	80004068 <log_write>
  brelse(bp);
    80003100:	854a                	mv	a0,s2
    80003102:	e35ff0ef          	jal	80002f36 <brelse>
}
    80003106:	6906                	ld	s2,64(sp)
    80003108:	79e2                	ld	s3,56(sp)
    8000310a:	7a42                	ld	s4,48(sp)
    8000310c:	7aa2                	ld	s5,40(sp)
    8000310e:	7b02                	ld	s6,32(sp)
    80003110:	6be2                	ld	s7,24(sp)
    80003112:	6c42                	ld	s8,16(sp)
    80003114:	6ca2                	ld	s9,8(sp)
}
    80003116:	8526                	mv	a0,s1
    80003118:	60e6                	ld	ra,88(sp)
    8000311a:	6446                	ld	s0,80(sp)
    8000311c:	64a6                	ld	s1,72(sp)
    8000311e:	6125                	addi	sp,sp,96
    80003120:	8082                	ret
    brelse(bp);
    80003122:	854a                	mv	a0,s2
    80003124:	e13ff0ef          	jal	80002f36 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003128:	015c87bb          	addw	a5,s9,s5
    8000312c:	00078a9b          	sext.w	s5,a5
    80003130:	004b2703          	lw	a4,4(s6)
    80003134:	04eaff63          	bgeu	s5,a4,80003192 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003138:	41fad79b          	sraiw	a5,s5,0x1f
    8000313c:	0137d79b          	srliw	a5,a5,0x13
    80003140:	015787bb          	addw	a5,a5,s5
    80003144:	40d7d79b          	sraiw	a5,a5,0xd
    80003148:	01cb2583          	lw	a1,28(s6)
    8000314c:	9dbd                	addw	a1,a1,a5
    8000314e:	855e                	mv	a0,s7
    80003150:	cdfff0ef          	jal	80002e2e <bread>
    80003154:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003156:	004b2503          	lw	a0,4(s6)
    8000315a:	000a849b          	sext.w	s1,s5
    8000315e:	8762                	mv	a4,s8
    80003160:	fca4f1e3          	bgeu	s1,a0,80003122 <balloc+0x90>
      m = 1 << (bi % 8);
    80003164:	00777693          	andi	a3,a4,7
    80003168:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000316c:	41f7579b          	sraiw	a5,a4,0x1f
    80003170:	01d7d79b          	srliw	a5,a5,0x1d
    80003174:	9fb9                	addw	a5,a5,a4
    80003176:	4037d79b          	sraiw	a5,a5,0x3
    8000317a:	00f90633          	add	a2,s2,a5
    8000317e:	05864603          	lbu	a2,88(a2)
    80003182:	00c6f5b3          	and	a1,a3,a2
    80003186:	d5a1                	beqz	a1,800030ce <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003188:	2705                	addiw	a4,a4,1
    8000318a:	2485                	addiw	s1,s1,1
    8000318c:	fd471ae3          	bne	a4,s4,80003160 <balloc+0xce>
    80003190:	bf49                	j	80003122 <balloc+0x90>
    80003192:	6906                	ld	s2,64(sp)
    80003194:	79e2                	ld	s3,56(sp)
    80003196:	7a42                	ld	s4,48(sp)
    80003198:	7aa2                	ld	s5,40(sp)
    8000319a:	7b02                	ld	s6,32(sp)
    8000319c:	6be2                	ld	s7,24(sp)
    8000319e:	6c42                	ld	s8,16(sp)
    800031a0:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800031a2:	00004517          	auipc	a0,0x4
    800031a6:	24650513          	addi	a0,a0,582 # 800073e8 <etext+0x3e8>
    800031aa:	b50fd0ef          	jal	800004fa <printf>
  return 0;
    800031ae:	4481                	li	s1,0
    800031b0:	b79d                	j	80003116 <balloc+0x84>

00000000800031b2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800031b2:	7179                	addi	sp,sp,-48
    800031b4:	f406                	sd	ra,40(sp)
    800031b6:	f022                	sd	s0,32(sp)
    800031b8:	ec26                	sd	s1,24(sp)
    800031ba:	e84a                	sd	s2,16(sp)
    800031bc:	e44e                	sd	s3,8(sp)
    800031be:	1800                	addi	s0,sp,48
    800031c0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800031c2:	47ad                	li	a5,11
    800031c4:	02b7e663          	bltu	a5,a1,800031f0 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800031c8:	02059793          	slli	a5,a1,0x20
    800031cc:	01e7d593          	srli	a1,a5,0x1e
    800031d0:	00b504b3          	add	s1,a0,a1
    800031d4:	0504a903          	lw	s2,80(s1)
    800031d8:	06091a63          	bnez	s2,8000324c <bmap+0x9a>
      addr = balloc(ip->dev);
    800031dc:	4108                	lw	a0,0(a0)
    800031de:	eb5ff0ef          	jal	80003092 <balloc>
    800031e2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800031e6:	06090363          	beqz	s2,8000324c <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800031ea:	0524a823          	sw	s2,80(s1)
    800031ee:	a8b9                	j	8000324c <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800031f0:	ff45849b          	addiw	s1,a1,-12
    800031f4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800031f8:	0ff00793          	li	a5,255
    800031fc:	06e7ee63          	bltu	a5,a4,80003278 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003200:	08052903          	lw	s2,128(a0)
    80003204:	00091d63          	bnez	s2,8000321e <bmap+0x6c>
      addr = balloc(ip->dev);
    80003208:	4108                	lw	a0,0(a0)
    8000320a:	e89ff0ef          	jal	80003092 <balloc>
    8000320e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003212:	02090d63          	beqz	s2,8000324c <bmap+0x9a>
    80003216:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003218:	0929a023          	sw	s2,128(s3)
    8000321c:	a011                	j	80003220 <bmap+0x6e>
    8000321e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003220:	85ca                	mv	a1,s2
    80003222:	0009a503          	lw	a0,0(s3)
    80003226:	c09ff0ef          	jal	80002e2e <bread>
    8000322a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000322c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003230:	02049713          	slli	a4,s1,0x20
    80003234:	01e75593          	srli	a1,a4,0x1e
    80003238:	00b784b3          	add	s1,a5,a1
    8000323c:	0004a903          	lw	s2,0(s1)
    80003240:	00090e63          	beqz	s2,8000325c <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003244:	8552                	mv	a0,s4
    80003246:	cf1ff0ef          	jal	80002f36 <brelse>
    return addr;
    8000324a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000324c:	854a                	mv	a0,s2
    8000324e:	70a2                	ld	ra,40(sp)
    80003250:	7402                	ld	s0,32(sp)
    80003252:	64e2                	ld	s1,24(sp)
    80003254:	6942                	ld	s2,16(sp)
    80003256:	69a2                	ld	s3,8(sp)
    80003258:	6145                	addi	sp,sp,48
    8000325a:	8082                	ret
      addr = balloc(ip->dev);
    8000325c:	0009a503          	lw	a0,0(s3)
    80003260:	e33ff0ef          	jal	80003092 <balloc>
    80003264:	0005091b          	sext.w	s2,a0
      if(addr){
    80003268:	fc090ee3          	beqz	s2,80003244 <bmap+0x92>
        a[bn] = addr;
    8000326c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003270:	8552                	mv	a0,s4
    80003272:	5f7000ef          	jal	80004068 <log_write>
    80003276:	b7f9                	j	80003244 <bmap+0x92>
    80003278:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000327a:	00004517          	auipc	a0,0x4
    8000327e:	18650513          	addi	a0,a0,390 # 80007400 <etext+0x400>
    80003282:	d5efd0ef          	jal	800007e0 <panic>

0000000080003286 <iget>:
{
    80003286:	7179                	addi	sp,sp,-48
    80003288:	f406                	sd	ra,40(sp)
    8000328a:	f022                	sd	s0,32(sp)
    8000328c:	ec26                	sd	s1,24(sp)
    8000328e:	e84a                	sd	s2,16(sp)
    80003290:	e44e                	sd	s3,8(sp)
    80003292:	e052                	sd	s4,0(sp)
    80003294:	1800                	addi	s0,sp,48
    80003296:	89aa                	mv	s3,a0
    80003298:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000329a:	0001e517          	auipc	a0,0x1e
    8000329e:	a8e50513          	addi	a0,a0,-1394 # 80020d28 <itable>
    800032a2:	92dfd0ef          	jal	80000bce <acquire>
  empty = 0;
    800032a6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032a8:	0001e497          	auipc	s1,0x1e
    800032ac:	a9848493          	addi	s1,s1,-1384 # 80020d40 <itable+0x18>
    800032b0:	0001f697          	auipc	a3,0x1f
    800032b4:	52068693          	addi	a3,a3,1312 # 800227d0 <log>
    800032b8:	a039                	j	800032c6 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032ba:	02090963          	beqz	s2,800032ec <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032be:	08848493          	addi	s1,s1,136
    800032c2:	02d48863          	beq	s1,a3,800032f2 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800032c6:	449c                	lw	a5,8(s1)
    800032c8:	fef059e3          	blez	a5,800032ba <iget+0x34>
    800032cc:	4098                	lw	a4,0(s1)
    800032ce:	ff3716e3          	bne	a4,s3,800032ba <iget+0x34>
    800032d2:	40d8                	lw	a4,4(s1)
    800032d4:	ff4713e3          	bne	a4,s4,800032ba <iget+0x34>
      ip->ref++;
    800032d8:	2785                	addiw	a5,a5,1
    800032da:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800032dc:	0001e517          	auipc	a0,0x1e
    800032e0:	a4c50513          	addi	a0,a0,-1460 # 80020d28 <itable>
    800032e4:	983fd0ef          	jal	80000c66 <release>
      return ip;
    800032e8:	8926                	mv	s2,s1
    800032ea:	a02d                	j	80003314 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032ec:	fbe9                	bnez	a5,800032be <iget+0x38>
      empty = ip;
    800032ee:	8926                	mv	s2,s1
    800032f0:	b7f9                	j	800032be <iget+0x38>
  if(empty == 0)
    800032f2:	02090a63          	beqz	s2,80003326 <iget+0xa0>
  ip->dev = dev;
    800032f6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800032fa:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800032fe:	4785                	li	a5,1
    80003300:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003304:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003308:	0001e517          	auipc	a0,0x1e
    8000330c:	a2050513          	addi	a0,a0,-1504 # 80020d28 <itable>
    80003310:	957fd0ef          	jal	80000c66 <release>
}
    80003314:	854a                	mv	a0,s2
    80003316:	70a2                	ld	ra,40(sp)
    80003318:	7402                	ld	s0,32(sp)
    8000331a:	64e2                	ld	s1,24(sp)
    8000331c:	6942                	ld	s2,16(sp)
    8000331e:	69a2                	ld	s3,8(sp)
    80003320:	6a02                	ld	s4,0(sp)
    80003322:	6145                	addi	sp,sp,48
    80003324:	8082                	ret
    panic("iget: no inodes");
    80003326:	00004517          	auipc	a0,0x4
    8000332a:	0f250513          	addi	a0,a0,242 # 80007418 <etext+0x418>
    8000332e:	cb2fd0ef          	jal	800007e0 <panic>

0000000080003332 <iinit>:
{
    80003332:	7179                	addi	sp,sp,-48
    80003334:	f406                	sd	ra,40(sp)
    80003336:	f022                	sd	s0,32(sp)
    80003338:	ec26                	sd	s1,24(sp)
    8000333a:	e84a                	sd	s2,16(sp)
    8000333c:	e44e                	sd	s3,8(sp)
    8000333e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003340:	00004597          	auipc	a1,0x4
    80003344:	0e858593          	addi	a1,a1,232 # 80007428 <etext+0x428>
    80003348:	0001e517          	auipc	a0,0x1e
    8000334c:	9e050513          	addi	a0,a0,-1568 # 80020d28 <itable>
    80003350:	ffefd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003354:	0001e497          	auipc	s1,0x1e
    80003358:	9fc48493          	addi	s1,s1,-1540 # 80020d50 <itable+0x28>
    8000335c:	0001f997          	auipc	s3,0x1f
    80003360:	48498993          	addi	s3,s3,1156 # 800227e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003364:	00004917          	auipc	s2,0x4
    80003368:	0cc90913          	addi	s2,s2,204 # 80007430 <etext+0x430>
    8000336c:	85ca                	mv	a1,s2
    8000336e:	8526                	mv	a0,s1
    80003370:	5bb000ef          	jal	8000412a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003374:	08848493          	addi	s1,s1,136
    80003378:	ff349ae3          	bne	s1,s3,8000336c <iinit+0x3a>
}
    8000337c:	70a2                	ld	ra,40(sp)
    8000337e:	7402                	ld	s0,32(sp)
    80003380:	64e2                	ld	s1,24(sp)
    80003382:	6942                	ld	s2,16(sp)
    80003384:	69a2                	ld	s3,8(sp)
    80003386:	6145                	addi	sp,sp,48
    80003388:	8082                	ret

000000008000338a <ialloc>:
{
    8000338a:	7139                	addi	sp,sp,-64
    8000338c:	fc06                	sd	ra,56(sp)
    8000338e:	f822                	sd	s0,48(sp)
    80003390:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003392:	0001e717          	auipc	a4,0x1e
    80003396:	98272703          	lw	a4,-1662(a4) # 80020d14 <sb+0xc>
    8000339a:	4785                	li	a5,1
    8000339c:	06e7f063          	bgeu	a5,a4,800033fc <ialloc+0x72>
    800033a0:	f426                	sd	s1,40(sp)
    800033a2:	f04a                	sd	s2,32(sp)
    800033a4:	ec4e                	sd	s3,24(sp)
    800033a6:	e852                	sd	s4,16(sp)
    800033a8:	e456                	sd	s5,8(sp)
    800033aa:	e05a                	sd	s6,0(sp)
    800033ac:	8aaa                	mv	s5,a0
    800033ae:	8b2e                	mv	s6,a1
    800033b0:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800033b2:	0001ea17          	auipc	s4,0x1e
    800033b6:	956a0a13          	addi	s4,s4,-1706 # 80020d08 <sb>
    800033ba:	00495593          	srli	a1,s2,0x4
    800033be:	018a2783          	lw	a5,24(s4)
    800033c2:	9dbd                	addw	a1,a1,a5
    800033c4:	8556                	mv	a0,s5
    800033c6:	a69ff0ef          	jal	80002e2e <bread>
    800033ca:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800033cc:	05850993          	addi	s3,a0,88
    800033d0:	00f97793          	andi	a5,s2,15
    800033d4:	079a                	slli	a5,a5,0x6
    800033d6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800033d8:	00099783          	lh	a5,0(s3)
    800033dc:	cb9d                	beqz	a5,80003412 <ialloc+0x88>
    brelse(bp);
    800033de:	b59ff0ef          	jal	80002f36 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800033e2:	0905                	addi	s2,s2,1
    800033e4:	00ca2703          	lw	a4,12(s4)
    800033e8:	0009079b          	sext.w	a5,s2
    800033ec:	fce7e7e3          	bltu	a5,a4,800033ba <ialloc+0x30>
    800033f0:	74a2                	ld	s1,40(sp)
    800033f2:	7902                	ld	s2,32(sp)
    800033f4:	69e2                	ld	s3,24(sp)
    800033f6:	6a42                	ld	s4,16(sp)
    800033f8:	6aa2                	ld	s5,8(sp)
    800033fa:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800033fc:	00004517          	auipc	a0,0x4
    80003400:	03c50513          	addi	a0,a0,60 # 80007438 <etext+0x438>
    80003404:	8f6fd0ef          	jal	800004fa <printf>
  return 0;
    80003408:	4501                	li	a0,0
}
    8000340a:	70e2                	ld	ra,56(sp)
    8000340c:	7442                	ld	s0,48(sp)
    8000340e:	6121                	addi	sp,sp,64
    80003410:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003412:	04000613          	li	a2,64
    80003416:	4581                	li	a1,0
    80003418:	854e                	mv	a0,s3
    8000341a:	889fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    8000341e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003422:	8526                	mv	a0,s1
    80003424:	445000ef          	jal	80004068 <log_write>
      brelse(bp);
    80003428:	8526                	mv	a0,s1
    8000342a:	b0dff0ef          	jal	80002f36 <brelse>
      return iget(dev, inum);
    8000342e:	0009059b          	sext.w	a1,s2
    80003432:	8556                	mv	a0,s5
    80003434:	e53ff0ef          	jal	80003286 <iget>
    80003438:	74a2                	ld	s1,40(sp)
    8000343a:	7902                	ld	s2,32(sp)
    8000343c:	69e2                	ld	s3,24(sp)
    8000343e:	6a42                	ld	s4,16(sp)
    80003440:	6aa2                	ld	s5,8(sp)
    80003442:	6b02                	ld	s6,0(sp)
    80003444:	b7d9                	j	8000340a <ialloc+0x80>

0000000080003446 <iupdate>:
{
    80003446:	1101                	addi	sp,sp,-32
    80003448:	ec06                	sd	ra,24(sp)
    8000344a:	e822                	sd	s0,16(sp)
    8000344c:	e426                	sd	s1,8(sp)
    8000344e:	e04a                	sd	s2,0(sp)
    80003450:	1000                	addi	s0,sp,32
    80003452:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003454:	415c                	lw	a5,4(a0)
    80003456:	0047d79b          	srliw	a5,a5,0x4
    8000345a:	0001e597          	auipc	a1,0x1e
    8000345e:	8c65a583          	lw	a1,-1850(a1) # 80020d20 <sb+0x18>
    80003462:	9dbd                	addw	a1,a1,a5
    80003464:	4108                	lw	a0,0(a0)
    80003466:	9c9ff0ef          	jal	80002e2e <bread>
    8000346a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000346c:	05850793          	addi	a5,a0,88
    80003470:	40d8                	lw	a4,4(s1)
    80003472:	8b3d                	andi	a4,a4,15
    80003474:	071a                	slli	a4,a4,0x6
    80003476:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003478:	04449703          	lh	a4,68(s1)
    8000347c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003480:	04649703          	lh	a4,70(s1)
    80003484:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003488:	04849703          	lh	a4,72(s1)
    8000348c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003490:	04a49703          	lh	a4,74(s1)
    80003494:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003498:	44f8                	lw	a4,76(s1)
    8000349a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000349c:	03400613          	li	a2,52
    800034a0:	05048593          	addi	a1,s1,80
    800034a4:	00c78513          	addi	a0,a5,12
    800034a8:	857fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	3bb000ef          	jal	80004068 <log_write>
  brelse(bp);
    800034b2:	854a                	mv	a0,s2
    800034b4:	a83ff0ef          	jal	80002f36 <brelse>
}
    800034b8:	60e2                	ld	ra,24(sp)
    800034ba:	6442                	ld	s0,16(sp)
    800034bc:	64a2                	ld	s1,8(sp)
    800034be:	6902                	ld	s2,0(sp)
    800034c0:	6105                	addi	sp,sp,32
    800034c2:	8082                	ret

00000000800034c4 <idup>:
{
    800034c4:	1101                	addi	sp,sp,-32
    800034c6:	ec06                	sd	ra,24(sp)
    800034c8:	e822                	sd	s0,16(sp)
    800034ca:	e426                	sd	s1,8(sp)
    800034cc:	1000                	addi	s0,sp,32
    800034ce:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034d0:	0001e517          	auipc	a0,0x1e
    800034d4:	85850513          	addi	a0,a0,-1960 # 80020d28 <itable>
    800034d8:	ef6fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800034dc:	449c                	lw	a5,8(s1)
    800034de:	2785                	addiw	a5,a5,1
    800034e0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034e2:	0001e517          	auipc	a0,0x1e
    800034e6:	84650513          	addi	a0,a0,-1978 # 80020d28 <itable>
    800034ea:	f7cfd0ef          	jal	80000c66 <release>
}
    800034ee:	8526                	mv	a0,s1
    800034f0:	60e2                	ld	ra,24(sp)
    800034f2:	6442                	ld	s0,16(sp)
    800034f4:	64a2                	ld	s1,8(sp)
    800034f6:	6105                	addi	sp,sp,32
    800034f8:	8082                	ret

00000000800034fa <ilock>:
{
    800034fa:	1101                	addi	sp,sp,-32
    800034fc:	ec06                	sd	ra,24(sp)
    800034fe:	e822                	sd	s0,16(sp)
    80003500:	e426                	sd	s1,8(sp)
    80003502:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003504:	cd19                	beqz	a0,80003522 <ilock+0x28>
    80003506:	84aa                	mv	s1,a0
    80003508:	451c                	lw	a5,8(a0)
    8000350a:	00f05c63          	blez	a5,80003522 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000350e:	0541                	addi	a0,a0,16
    80003510:	451000ef          	jal	80004160 <acquiresleep>
  if(ip->valid == 0){
    80003514:	40bc                	lw	a5,64(s1)
    80003516:	cf89                	beqz	a5,80003530 <ilock+0x36>
}
    80003518:	60e2                	ld	ra,24(sp)
    8000351a:	6442                	ld	s0,16(sp)
    8000351c:	64a2                	ld	s1,8(sp)
    8000351e:	6105                	addi	sp,sp,32
    80003520:	8082                	ret
    80003522:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003524:	00004517          	auipc	a0,0x4
    80003528:	f2c50513          	addi	a0,a0,-212 # 80007450 <etext+0x450>
    8000352c:	ab4fd0ef          	jal	800007e0 <panic>
    80003530:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003532:	40dc                	lw	a5,4(s1)
    80003534:	0047d79b          	srliw	a5,a5,0x4
    80003538:	0001d597          	auipc	a1,0x1d
    8000353c:	7e85a583          	lw	a1,2024(a1) # 80020d20 <sb+0x18>
    80003540:	9dbd                	addw	a1,a1,a5
    80003542:	4088                	lw	a0,0(s1)
    80003544:	8ebff0ef          	jal	80002e2e <bread>
    80003548:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000354a:	05850593          	addi	a1,a0,88
    8000354e:	40dc                	lw	a5,4(s1)
    80003550:	8bbd                	andi	a5,a5,15
    80003552:	079a                	slli	a5,a5,0x6
    80003554:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003556:	00059783          	lh	a5,0(a1)
    8000355a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000355e:	00259783          	lh	a5,2(a1)
    80003562:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003566:	00459783          	lh	a5,4(a1)
    8000356a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000356e:	00659783          	lh	a5,6(a1)
    80003572:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003576:	459c                	lw	a5,8(a1)
    80003578:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000357a:	03400613          	li	a2,52
    8000357e:	05b1                	addi	a1,a1,12
    80003580:	05048513          	addi	a0,s1,80
    80003584:	f7afd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003588:	854a                	mv	a0,s2
    8000358a:	9adff0ef          	jal	80002f36 <brelse>
    ip->valid = 1;
    8000358e:	4785                	li	a5,1
    80003590:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003592:	04449783          	lh	a5,68(s1)
    80003596:	c399                	beqz	a5,8000359c <ilock+0xa2>
    80003598:	6902                	ld	s2,0(sp)
    8000359a:	bfbd                	j	80003518 <ilock+0x1e>
      panic("ilock: no type");
    8000359c:	00004517          	auipc	a0,0x4
    800035a0:	ebc50513          	addi	a0,a0,-324 # 80007458 <etext+0x458>
    800035a4:	a3cfd0ef          	jal	800007e0 <panic>

00000000800035a8 <iunlock>:
{
    800035a8:	1101                	addi	sp,sp,-32
    800035aa:	ec06                	sd	ra,24(sp)
    800035ac:	e822                	sd	s0,16(sp)
    800035ae:	e426                	sd	s1,8(sp)
    800035b0:	e04a                	sd	s2,0(sp)
    800035b2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800035b4:	c505                	beqz	a0,800035dc <iunlock+0x34>
    800035b6:	84aa                	mv	s1,a0
    800035b8:	01050913          	addi	s2,a0,16
    800035bc:	854a                	mv	a0,s2
    800035be:	421000ef          	jal	800041de <holdingsleep>
    800035c2:	cd09                	beqz	a0,800035dc <iunlock+0x34>
    800035c4:	449c                	lw	a5,8(s1)
    800035c6:	00f05b63          	blez	a5,800035dc <iunlock+0x34>
  releasesleep(&ip->lock);
    800035ca:	854a                	mv	a0,s2
    800035cc:	3db000ef          	jal	800041a6 <releasesleep>
}
    800035d0:	60e2                	ld	ra,24(sp)
    800035d2:	6442                	ld	s0,16(sp)
    800035d4:	64a2                	ld	s1,8(sp)
    800035d6:	6902                	ld	s2,0(sp)
    800035d8:	6105                	addi	sp,sp,32
    800035da:	8082                	ret
    panic("iunlock");
    800035dc:	00004517          	auipc	a0,0x4
    800035e0:	e8c50513          	addi	a0,a0,-372 # 80007468 <etext+0x468>
    800035e4:	9fcfd0ef          	jal	800007e0 <panic>

00000000800035e8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035e8:	7179                	addi	sp,sp,-48
    800035ea:	f406                	sd	ra,40(sp)
    800035ec:	f022                	sd	s0,32(sp)
    800035ee:	ec26                	sd	s1,24(sp)
    800035f0:	e84a                	sd	s2,16(sp)
    800035f2:	e44e                	sd	s3,8(sp)
    800035f4:	1800                	addi	s0,sp,48
    800035f6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800035f8:	05050493          	addi	s1,a0,80
    800035fc:	08050913          	addi	s2,a0,128
    80003600:	a021                	j	80003608 <itrunc+0x20>
    80003602:	0491                	addi	s1,s1,4
    80003604:	01248b63          	beq	s1,s2,8000361a <itrunc+0x32>
    if(ip->addrs[i]){
    80003608:	408c                	lw	a1,0(s1)
    8000360a:	dde5                	beqz	a1,80003602 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000360c:	0009a503          	lw	a0,0(s3)
    80003610:	a17ff0ef          	jal	80003026 <bfree>
      ip->addrs[i] = 0;
    80003614:	0004a023          	sw	zero,0(s1)
    80003618:	b7ed                	j	80003602 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000361a:	0809a583          	lw	a1,128(s3)
    8000361e:	ed89                	bnez	a1,80003638 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003620:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003624:	854e                	mv	a0,s3
    80003626:	e21ff0ef          	jal	80003446 <iupdate>
}
    8000362a:	70a2                	ld	ra,40(sp)
    8000362c:	7402                	ld	s0,32(sp)
    8000362e:	64e2                	ld	s1,24(sp)
    80003630:	6942                	ld	s2,16(sp)
    80003632:	69a2                	ld	s3,8(sp)
    80003634:	6145                	addi	sp,sp,48
    80003636:	8082                	ret
    80003638:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000363a:	0009a503          	lw	a0,0(s3)
    8000363e:	ff0ff0ef          	jal	80002e2e <bread>
    80003642:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003644:	05850493          	addi	s1,a0,88
    80003648:	45850913          	addi	s2,a0,1112
    8000364c:	a021                	j	80003654 <itrunc+0x6c>
    8000364e:	0491                	addi	s1,s1,4
    80003650:	01248963          	beq	s1,s2,80003662 <itrunc+0x7a>
      if(a[j])
    80003654:	408c                	lw	a1,0(s1)
    80003656:	dde5                	beqz	a1,8000364e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003658:	0009a503          	lw	a0,0(s3)
    8000365c:	9cbff0ef          	jal	80003026 <bfree>
    80003660:	b7fd                	j	8000364e <itrunc+0x66>
    brelse(bp);
    80003662:	8552                	mv	a0,s4
    80003664:	8d3ff0ef          	jal	80002f36 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003668:	0809a583          	lw	a1,128(s3)
    8000366c:	0009a503          	lw	a0,0(s3)
    80003670:	9b7ff0ef          	jal	80003026 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003674:	0809a023          	sw	zero,128(s3)
    80003678:	6a02                	ld	s4,0(sp)
    8000367a:	b75d                	j	80003620 <itrunc+0x38>

000000008000367c <iput>:
{
    8000367c:	1101                	addi	sp,sp,-32
    8000367e:	ec06                	sd	ra,24(sp)
    80003680:	e822                	sd	s0,16(sp)
    80003682:	e426                	sd	s1,8(sp)
    80003684:	1000                	addi	s0,sp,32
    80003686:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003688:	0001d517          	auipc	a0,0x1d
    8000368c:	6a050513          	addi	a0,a0,1696 # 80020d28 <itable>
    80003690:	d3efd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003694:	4498                	lw	a4,8(s1)
    80003696:	4785                	li	a5,1
    80003698:	02f70063          	beq	a4,a5,800036b8 <iput+0x3c>
  ip->ref--;
    8000369c:	449c                	lw	a5,8(s1)
    8000369e:	37fd                	addiw	a5,a5,-1
    800036a0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036a2:	0001d517          	auipc	a0,0x1d
    800036a6:	68650513          	addi	a0,a0,1670 # 80020d28 <itable>
    800036aa:	dbcfd0ef          	jal	80000c66 <release>
}
    800036ae:	60e2                	ld	ra,24(sp)
    800036b0:	6442                	ld	s0,16(sp)
    800036b2:	64a2                	ld	s1,8(sp)
    800036b4:	6105                	addi	sp,sp,32
    800036b6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800036b8:	40bc                	lw	a5,64(s1)
    800036ba:	d3ed                	beqz	a5,8000369c <iput+0x20>
    800036bc:	04a49783          	lh	a5,74(s1)
    800036c0:	fff1                	bnez	a5,8000369c <iput+0x20>
    800036c2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800036c4:	01048913          	addi	s2,s1,16
    800036c8:	854a                	mv	a0,s2
    800036ca:	297000ef          	jal	80004160 <acquiresleep>
    release(&itable.lock);
    800036ce:	0001d517          	auipc	a0,0x1d
    800036d2:	65a50513          	addi	a0,a0,1626 # 80020d28 <itable>
    800036d6:	d90fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800036da:	8526                	mv	a0,s1
    800036dc:	f0dff0ef          	jal	800035e8 <itrunc>
    ip->type = 0;
    800036e0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800036e4:	8526                	mv	a0,s1
    800036e6:	d61ff0ef          	jal	80003446 <iupdate>
    ip->valid = 0;
    800036ea:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036ee:	854a                	mv	a0,s2
    800036f0:	2b7000ef          	jal	800041a6 <releasesleep>
    acquire(&itable.lock);
    800036f4:	0001d517          	auipc	a0,0x1d
    800036f8:	63450513          	addi	a0,a0,1588 # 80020d28 <itable>
    800036fc:	cd2fd0ef          	jal	80000bce <acquire>
    80003700:	6902                	ld	s2,0(sp)
    80003702:	bf69                	j	8000369c <iput+0x20>

0000000080003704 <iunlockput>:
{
    80003704:	1101                	addi	sp,sp,-32
    80003706:	ec06                	sd	ra,24(sp)
    80003708:	e822                	sd	s0,16(sp)
    8000370a:	e426                	sd	s1,8(sp)
    8000370c:	1000                	addi	s0,sp,32
    8000370e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003710:	e99ff0ef          	jal	800035a8 <iunlock>
  iput(ip);
    80003714:	8526                	mv	a0,s1
    80003716:	f67ff0ef          	jal	8000367c <iput>
}
    8000371a:	60e2                	ld	ra,24(sp)
    8000371c:	6442                	ld	s0,16(sp)
    8000371e:	64a2                	ld	s1,8(sp)
    80003720:	6105                	addi	sp,sp,32
    80003722:	8082                	ret

0000000080003724 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003724:	0001d717          	auipc	a4,0x1d
    80003728:	5f072703          	lw	a4,1520(a4) # 80020d14 <sb+0xc>
    8000372c:	4785                	li	a5,1
    8000372e:	0ae7ff63          	bgeu	a5,a4,800037ec <ireclaim+0xc8>
{
    80003732:	7139                	addi	sp,sp,-64
    80003734:	fc06                	sd	ra,56(sp)
    80003736:	f822                	sd	s0,48(sp)
    80003738:	f426                	sd	s1,40(sp)
    8000373a:	f04a                	sd	s2,32(sp)
    8000373c:	ec4e                	sd	s3,24(sp)
    8000373e:	e852                	sd	s4,16(sp)
    80003740:	e456                	sd	s5,8(sp)
    80003742:	e05a                	sd	s6,0(sp)
    80003744:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003746:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003748:	00050a1b          	sext.w	s4,a0
    8000374c:	0001da97          	auipc	s5,0x1d
    80003750:	5bca8a93          	addi	s5,s5,1468 # 80020d08 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003754:	00004b17          	auipc	s6,0x4
    80003758:	d1cb0b13          	addi	s6,s6,-740 # 80007470 <etext+0x470>
    8000375c:	a099                	j	800037a2 <ireclaim+0x7e>
    8000375e:	85ce                	mv	a1,s3
    80003760:	855a                	mv	a0,s6
    80003762:	d99fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003766:	85ce                	mv	a1,s3
    80003768:	8552                	mv	a0,s4
    8000376a:	b1dff0ef          	jal	80003286 <iget>
    8000376e:	89aa                	mv	s3,a0
    brelse(bp);
    80003770:	854a                	mv	a0,s2
    80003772:	fc4ff0ef          	jal	80002f36 <brelse>
    if (ip) {
    80003776:	00098f63          	beqz	s3,80003794 <ireclaim+0x70>
      begin_op();
    8000377a:	76a000ef          	jal	80003ee4 <begin_op>
      ilock(ip);
    8000377e:	854e                	mv	a0,s3
    80003780:	d7bff0ef          	jal	800034fa <ilock>
      iunlock(ip);
    80003784:	854e                	mv	a0,s3
    80003786:	e23ff0ef          	jal	800035a8 <iunlock>
      iput(ip);
    8000378a:	854e                	mv	a0,s3
    8000378c:	ef1ff0ef          	jal	8000367c <iput>
      end_op();
    80003790:	7be000ef          	jal	80003f4e <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003794:	0485                	addi	s1,s1,1
    80003796:	00caa703          	lw	a4,12(s5)
    8000379a:	0004879b          	sext.w	a5,s1
    8000379e:	02e7fd63          	bgeu	a5,a4,800037d8 <ireclaim+0xb4>
    800037a2:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800037a6:	0044d593          	srli	a1,s1,0x4
    800037aa:	018aa783          	lw	a5,24(s5)
    800037ae:	9dbd                	addw	a1,a1,a5
    800037b0:	8552                	mv	a0,s4
    800037b2:	e7cff0ef          	jal	80002e2e <bread>
    800037b6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037b8:	05850793          	addi	a5,a0,88
    800037bc:	00f9f713          	andi	a4,s3,15
    800037c0:	071a                	slli	a4,a4,0x6
    800037c2:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800037c4:	00079703          	lh	a4,0(a5)
    800037c8:	c701                	beqz	a4,800037d0 <ireclaim+0xac>
    800037ca:	00679783          	lh	a5,6(a5)
    800037ce:	dbc1                	beqz	a5,8000375e <ireclaim+0x3a>
    brelse(bp);
    800037d0:	854a                	mv	a0,s2
    800037d2:	f64ff0ef          	jal	80002f36 <brelse>
    if (ip) {
    800037d6:	bf7d                	j	80003794 <ireclaim+0x70>
}
    800037d8:	70e2                	ld	ra,56(sp)
    800037da:	7442                	ld	s0,48(sp)
    800037dc:	74a2                	ld	s1,40(sp)
    800037de:	7902                	ld	s2,32(sp)
    800037e0:	69e2                	ld	s3,24(sp)
    800037e2:	6a42                	ld	s4,16(sp)
    800037e4:	6aa2                	ld	s5,8(sp)
    800037e6:	6b02                	ld	s6,0(sp)
    800037e8:	6121                	addi	sp,sp,64
    800037ea:	8082                	ret
    800037ec:	8082                	ret

00000000800037ee <fsinit>:
fsinit(int dev) {
    800037ee:	7179                	addi	sp,sp,-48
    800037f0:	f406                	sd	ra,40(sp)
    800037f2:	f022                	sd	s0,32(sp)
    800037f4:	ec26                	sd	s1,24(sp)
    800037f6:	e84a                	sd	s2,16(sp)
    800037f8:	e44e                	sd	s3,8(sp)
    800037fa:	1800                	addi	s0,sp,48
    800037fc:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800037fe:	4585                	li	a1,1
    80003800:	e2eff0ef          	jal	80002e2e <bread>
    80003804:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003806:	0001d997          	auipc	s3,0x1d
    8000380a:	50298993          	addi	s3,s3,1282 # 80020d08 <sb>
    8000380e:	02000613          	li	a2,32
    80003812:	05850593          	addi	a1,a0,88
    80003816:	854e                	mv	a0,s3
    80003818:	ce6fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    8000381c:	854a                	mv	a0,s2
    8000381e:	f18ff0ef          	jal	80002f36 <brelse>
  if(sb.magic != FSMAGIC)
    80003822:	0009a703          	lw	a4,0(s3)
    80003826:	102037b7          	lui	a5,0x10203
    8000382a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000382e:	02f71363          	bne	a4,a5,80003854 <fsinit+0x66>
  initlog(dev, &sb);
    80003832:	0001d597          	auipc	a1,0x1d
    80003836:	4d658593          	addi	a1,a1,1238 # 80020d08 <sb>
    8000383a:	8526                	mv	a0,s1
    8000383c:	62a000ef          	jal	80003e66 <initlog>
  ireclaim(dev);
    80003840:	8526                	mv	a0,s1
    80003842:	ee3ff0ef          	jal	80003724 <ireclaim>
}
    80003846:	70a2                	ld	ra,40(sp)
    80003848:	7402                	ld	s0,32(sp)
    8000384a:	64e2                	ld	s1,24(sp)
    8000384c:	6942                	ld	s2,16(sp)
    8000384e:	69a2                	ld	s3,8(sp)
    80003850:	6145                	addi	sp,sp,48
    80003852:	8082                	ret
    panic("invalid file system");
    80003854:	00004517          	auipc	a0,0x4
    80003858:	c3c50513          	addi	a0,a0,-964 # 80007490 <etext+0x490>
    8000385c:	f85fc0ef          	jal	800007e0 <panic>

0000000080003860 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003860:	1141                	addi	sp,sp,-16
    80003862:	e422                	sd	s0,8(sp)
    80003864:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003866:	411c                	lw	a5,0(a0)
    80003868:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000386a:	415c                	lw	a5,4(a0)
    8000386c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000386e:	04451783          	lh	a5,68(a0)
    80003872:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003876:	04a51783          	lh	a5,74(a0)
    8000387a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000387e:	04c56783          	lwu	a5,76(a0)
    80003882:	e99c                	sd	a5,16(a1)
}
    80003884:	6422                	ld	s0,8(sp)
    80003886:	0141                	addi	sp,sp,16
    80003888:	8082                	ret

000000008000388a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000388a:	457c                	lw	a5,76(a0)
    8000388c:	0ed7eb63          	bltu	a5,a3,80003982 <readi+0xf8>
{
    80003890:	7159                	addi	sp,sp,-112
    80003892:	f486                	sd	ra,104(sp)
    80003894:	f0a2                	sd	s0,96(sp)
    80003896:	eca6                	sd	s1,88(sp)
    80003898:	e0d2                	sd	s4,64(sp)
    8000389a:	fc56                	sd	s5,56(sp)
    8000389c:	f85a                	sd	s6,48(sp)
    8000389e:	f45e                	sd	s7,40(sp)
    800038a0:	1880                	addi	s0,sp,112
    800038a2:	8b2a                	mv	s6,a0
    800038a4:	8bae                	mv	s7,a1
    800038a6:	8a32                	mv	s4,a2
    800038a8:	84b6                	mv	s1,a3
    800038aa:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800038ac:	9f35                	addw	a4,a4,a3
    return 0;
    800038ae:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800038b0:	0cd76063          	bltu	a4,a3,80003970 <readi+0xe6>
    800038b4:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800038b6:	00e7f463          	bgeu	a5,a4,800038be <readi+0x34>
    n = ip->size - off;
    800038ba:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038be:	080a8f63          	beqz	s5,8000395c <readi+0xd2>
    800038c2:	e8ca                	sd	s2,80(sp)
    800038c4:	f062                	sd	s8,32(sp)
    800038c6:	ec66                	sd	s9,24(sp)
    800038c8:	e86a                	sd	s10,16(sp)
    800038ca:	e46e                	sd	s11,8(sp)
    800038cc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038ce:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038d2:	5c7d                	li	s8,-1
    800038d4:	a80d                	j	80003906 <readi+0x7c>
    800038d6:	020d1d93          	slli	s11,s10,0x20
    800038da:	020ddd93          	srli	s11,s11,0x20
    800038de:	05890613          	addi	a2,s2,88
    800038e2:	86ee                	mv	a3,s11
    800038e4:	963a                	add	a2,a2,a4
    800038e6:	85d2                	mv	a1,s4
    800038e8:	855e                	mv	a0,s7
    800038ea:	bb9fe0ef          	jal	800024a2 <either_copyout>
    800038ee:	05850763          	beq	a0,s8,8000393c <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038f2:	854a                	mv	a0,s2
    800038f4:	e42ff0ef          	jal	80002f36 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038f8:	013d09bb          	addw	s3,s10,s3
    800038fc:	009d04bb          	addw	s1,s10,s1
    80003900:	9a6e                	add	s4,s4,s11
    80003902:	0559f763          	bgeu	s3,s5,80003950 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003906:	00a4d59b          	srliw	a1,s1,0xa
    8000390a:	855a                	mv	a0,s6
    8000390c:	8a7ff0ef          	jal	800031b2 <bmap>
    80003910:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003914:	c5b1                	beqz	a1,80003960 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003916:	000b2503          	lw	a0,0(s6)
    8000391a:	d14ff0ef          	jal	80002e2e <bread>
    8000391e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003920:	3ff4f713          	andi	a4,s1,1023
    80003924:	40ec87bb          	subw	a5,s9,a4
    80003928:	413a86bb          	subw	a3,s5,s3
    8000392c:	8d3e                	mv	s10,a5
    8000392e:	2781                	sext.w	a5,a5
    80003930:	0006861b          	sext.w	a2,a3
    80003934:	faf671e3          	bgeu	a2,a5,800038d6 <readi+0x4c>
    80003938:	8d36                	mv	s10,a3
    8000393a:	bf71                	j	800038d6 <readi+0x4c>
      brelse(bp);
    8000393c:	854a                	mv	a0,s2
    8000393e:	df8ff0ef          	jal	80002f36 <brelse>
      tot = -1;
    80003942:	59fd                	li	s3,-1
      break;
    80003944:	6946                	ld	s2,80(sp)
    80003946:	7c02                	ld	s8,32(sp)
    80003948:	6ce2                	ld	s9,24(sp)
    8000394a:	6d42                	ld	s10,16(sp)
    8000394c:	6da2                	ld	s11,8(sp)
    8000394e:	a831                	j	8000396a <readi+0xe0>
    80003950:	6946                	ld	s2,80(sp)
    80003952:	7c02                	ld	s8,32(sp)
    80003954:	6ce2                	ld	s9,24(sp)
    80003956:	6d42                	ld	s10,16(sp)
    80003958:	6da2                	ld	s11,8(sp)
    8000395a:	a801                	j	8000396a <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000395c:	89d6                	mv	s3,s5
    8000395e:	a031                	j	8000396a <readi+0xe0>
    80003960:	6946                	ld	s2,80(sp)
    80003962:	7c02                	ld	s8,32(sp)
    80003964:	6ce2                	ld	s9,24(sp)
    80003966:	6d42                	ld	s10,16(sp)
    80003968:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000396a:	0009851b          	sext.w	a0,s3
    8000396e:	69a6                	ld	s3,72(sp)
}
    80003970:	70a6                	ld	ra,104(sp)
    80003972:	7406                	ld	s0,96(sp)
    80003974:	64e6                	ld	s1,88(sp)
    80003976:	6a06                	ld	s4,64(sp)
    80003978:	7ae2                	ld	s5,56(sp)
    8000397a:	7b42                	ld	s6,48(sp)
    8000397c:	7ba2                	ld	s7,40(sp)
    8000397e:	6165                	addi	sp,sp,112
    80003980:	8082                	ret
    return 0;
    80003982:	4501                	li	a0,0
}
    80003984:	8082                	ret

0000000080003986 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003986:	457c                	lw	a5,76(a0)
    80003988:	10d7e063          	bltu	a5,a3,80003a88 <writei+0x102>
{
    8000398c:	7159                	addi	sp,sp,-112
    8000398e:	f486                	sd	ra,104(sp)
    80003990:	f0a2                	sd	s0,96(sp)
    80003992:	e8ca                	sd	s2,80(sp)
    80003994:	e0d2                	sd	s4,64(sp)
    80003996:	fc56                	sd	s5,56(sp)
    80003998:	f85a                	sd	s6,48(sp)
    8000399a:	f45e                	sd	s7,40(sp)
    8000399c:	1880                	addi	s0,sp,112
    8000399e:	8aaa                	mv	s5,a0
    800039a0:	8bae                	mv	s7,a1
    800039a2:	8a32                	mv	s4,a2
    800039a4:	8936                	mv	s2,a3
    800039a6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039a8:	00e687bb          	addw	a5,a3,a4
    800039ac:	0ed7e063          	bltu	a5,a3,80003a8c <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039b0:	00043737          	lui	a4,0x43
    800039b4:	0cf76e63          	bltu	a4,a5,80003a90 <writei+0x10a>
    800039b8:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039ba:	0a0b0f63          	beqz	s6,80003a78 <writei+0xf2>
    800039be:	eca6                	sd	s1,88(sp)
    800039c0:	f062                	sd	s8,32(sp)
    800039c2:	ec66                	sd	s9,24(sp)
    800039c4:	e86a                	sd	s10,16(sp)
    800039c6:	e46e                	sd	s11,8(sp)
    800039c8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ca:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039ce:	5c7d                	li	s8,-1
    800039d0:	a825                	j	80003a08 <writei+0x82>
    800039d2:	020d1d93          	slli	s11,s10,0x20
    800039d6:	020ddd93          	srli	s11,s11,0x20
    800039da:	05848513          	addi	a0,s1,88
    800039de:	86ee                	mv	a3,s11
    800039e0:	8652                	mv	a2,s4
    800039e2:	85de                	mv	a1,s7
    800039e4:	953a                	add	a0,a0,a4
    800039e6:	b07fe0ef          	jal	800024ec <either_copyin>
    800039ea:	05850a63          	beq	a0,s8,80003a3e <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039ee:	8526                	mv	a0,s1
    800039f0:	678000ef          	jal	80004068 <log_write>
    brelse(bp);
    800039f4:	8526                	mv	a0,s1
    800039f6:	d40ff0ef          	jal	80002f36 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039fa:	013d09bb          	addw	s3,s10,s3
    800039fe:	012d093b          	addw	s2,s10,s2
    80003a02:	9a6e                	add	s4,s4,s11
    80003a04:	0569f063          	bgeu	s3,s6,80003a44 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003a08:	00a9559b          	srliw	a1,s2,0xa
    80003a0c:	8556                	mv	a0,s5
    80003a0e:	fa4ff0ef          	jal	800031b2 <bmap>
    80003a12:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a16:	c59d                	beqz	a1,80003a44 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003a18:	000aa503          	lw	a0,0(s5)
    80003a1c:	c12ff0ef          	jal	80002e2e <bread>
    80003a20:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a22:	3ff97713          	andi	a4,s2,1023
    80003a26:	40ec87bb          	subw	a5,s9,a4
    80003a2a:	413b06bb          	subw	a3,s6,s3
    80003a2e:	8d3e                	mv	s10,a5
    80003a30:	2781                	sext.w	a5,a5
    80003a32:	0006861b          	sext.w	a2,a3
    80003a36:	f8f67ee3          	bgeu	a2,a5,800039d2 <writei+0x4c>
    80003a3a:	8d36                	mv	s10,a3
    80003a3c:	bf59                	j	800039d2 <writei+0x4c>
      brelse(bp);
    80003a3e:	8526                	mv	a0,s1
    80003a40:	cf6ff0ef          	jal	80002f36 <brelse>
  }

  if(off > ip->size)
    80003a44:	04caa783          	lw	a5,76(s5)
    80003a48:	0327fa63          	bgeu	a5,s2,80003a7c <writei+0xf6>
    ip->size = off;
    80003a4c:	052aa623          	sw	s2,76(s5)
    80003a50:	64e6                	ld	s1,88(sp)
    80003a52:	7c02                	ld	s8,32(sp)
    80003a54:	6ce2                	ld	s9,24(sp)
    80003a56:	6d42                	ld	s10,16(sp)
    80003a58:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a5a:	8556                	mv	a0,s5
    80003a5c:	9ebff0ef          	jal	80003446 <iupdate>

  return tot;
    80003a60:	0009851b          	sext.w	a0,s3
    80003a64:	69a6                	ld	s3,72(sp)
}
    80003a66:	70a6                	ld	ra,104(sp)
    80003a68:	7406                	ld	s0,96(sp)
    80003a6a:	6946                	ld	s2,80(sp)
    80003a6c:	6a06                	ld	s4,64(sp)
    80003a6e:	7ae2                	ld	s5,56(sp)
    80003a70:	7b42                	ld	s6,48(sp)
    80003a72:	7ba2                	ld	s7,40(sp)
    80003a74:	6165                	addi	sp,sp,112
    80003a76:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a78:	89da                	mv	s3,s6
    80003a7a:	b7c5                	j	80003a5a <writei+0xd4>
    80003a7c:	64e6                	ld	s1,88(sp)
    80003a7e:	7c02                	ld	s8,32(sp)
    80003a80:	6ce2                	ld	s9,24(sp)
    80003a82:	6d42                	ld	s10,16(sp)
    80003a84:	6da2                	ld	s11,8(sp)
    80003a86:	bfd1                	j	80003a5a <writei+0xd4>
    return -1;
    80003a88:	557d                	li	a0,-1
}
    80003a8a:	8082                	ret
    return -1;
    80003a8c:	557d                	li	a0,-1
    80003a8e:	bfe1                	j	80003a66 <writei+0xe0>
    return -1;
    80003a90:	557d                	li	a0,-1
    80003a92:	bfd1                	j	80003a66 <writei+0xe0>

0000000080003a94 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a94:	1141                	addi	sp,sp,-16
    80003a96:	e406                	sd	ra,8(sp)
    80003a98:	e022                	sd	s0,0(sp)
    80003a9a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a9c:	4639                	li	a2,14
    80003a9e:	ad0fd0ef          	jal	80000d6e <strncmp>
}
    80003aa2:	60a2                	ld	ra,8(sp)
    80003aa4:	6402                	ld	s0,0(sp)
    80003aa6:	0141                	addi	sp,sp,16
    80003aa8:	8082                	ret

0000000080003aaa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003aaa:	7139                	addi	sp,sp,-64
    80003aac:	fc06                	sd	ra,56(sp)
    80003aae:	f822                	sd	s0,48(sp)
    80003ab0:	f426                	sd	s1,40(sp)
    80003ab2:	f04a                	sd	s2,32(sp)
    80003ab4:	ec4e                	sd	s3,24(sp)
    80003ab6:	e852                	sd	s4,16(sp)
    80003ab8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003aba:	04451703          	lh	a4,68(a0)
    80003abe:	4785                	li	a5,1
    80003ac0:	00f71a63          	bne	a4,a5,80003ad4 <dirlookup+0x2a>
    80003ac4:	892a                	mv	s2,a0
    80003ac6:	89ae                	mv	s3,a1
    80003ac8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aca:	457c                	lw	a5,76(a0)
    80003acc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ace:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ad0:	e39d                	bnez	a5,80003af6 <dirlookup+0x4c>
    80003ad2:	a095                	j	80003b36 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003ad4:	00004517          	auipc	a0,0x4
    80003ad8:	9d450513          	addi	a0,a0,-1580 # 800074a8 <etext+0x4a8>
    80003adc:	d05fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003ae0:	00004517          	auipc	a0,0x4
    80003ae4:	9e050513          	addi	a0,a0,-1568 # 800074c0 <etext+0x4c0>
    80003ae8:	cf9fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aec:	24c1                	addiw	s1,s1,16
    80003aee:	04c92783          	lw	a5,76(s2)
    80003af2:	04f4f163          	bgeu	s1,a5,80003b34 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003af6:	4741                	li	a4,16
    80003af8:	86a6                	mv	a3,s1
    80003afa:	fc040613          	addi	a2,s0,-64
    80003afe:	4581                	li	a1,0
    80003b00:	854a                	mv	a0,s2
    80003b02:	d89ff0ef          	jal	8000388a <readi>
    80003b06:	47c1                	li	a5,16
    80003b08:	fcf51ce3          	bne	a0,a5,80003ae0 <dirlookup+0x36>
    if(de.inum == 0)
    80003b0c:	fc045783          	lhu	a5,-64(s0)
    80003b10:	dff1                	beqz	a5,80003aec <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003b12:	fc240593          	addi	a1,s0,-62
    80003b16:	854e                	mv	a0,s3
    80003b18:	f7dff0ef          	jal	80003a94 <namecmp>
    80003b1c:	f961                	bnez	a0,80003aec <dirlookup+0x42>
      if(poff)
    80003b1e:	000a0463          	beqz	s4,80003b26 <dirlookup+0x7c>
        *poff = off;
    80003b22:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b26:	fc045583          	lhu	a1,-64(s0)
    80003b2a:	00092503          	lw	a0,0(s2)
    80003b2e:	f58ff0ef          	jal	80003286 <iget>
    80003b32:	a011                	j	80003b36 <dirlookup+0x8c>
  return 0;
    80003b34:	4501                	li	a0,0
}
    80003b36:	70e2                	ld	ra,56(sp)
    80003b38:	7442                	ld	s0,48(sp)
    80003b3a:	74a2                	ld	s1,40(sp)
    80003b3c:	7902                	ld	s2,32(sp)
    80003b3e:	69e2                	ld	s3,24(sp)
    80003b40:	6a42                	ld	s4,16(sp)
    80003b42:	6121                	addi	sp,sp,64
    80003b44:	8082                	ret

0000000080003b46 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b46:	711d                	addi	sp,sp,-96
    80003b48:	ec86                	sd	ra,88(sp)
    80003b4a:	e8a2                	sd	s0,80(sp)
    80003b4c:	e4a6                	sd	s1,72(sp)
    80003b4e:	e0ca                	sd	s2,64(sp)
    80003b50:	fc4e                	sd	s3,56(sp)
    80003b52:	f852                	sd	s4,48(sp)
    80003b54:	f456                	sd	s5,40(sp)
    80003b56:	f05a                	sd	s6,32(sp)
    80003b58:	ec5e                	sd	s7,24(sp)
    80003b5a:	e862                	sd	s8,16(sp)
    80003b5c:	e466                	sd	s9,8(sp)
    80003b5e:	1080                	addi	s0,sp,96
    80003b60:	84aa                	mv	s1,a0
    80003b62:	8b2e                	mv	s6,a1
    80003b64:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b66:	00054703          	lbu	a4,0(a0)
    80003b6a:	02f00793          	li	a5,47
    80003b6e:	00f70e63          	beq	a4,a5,80003b8a <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b72:	ddffd0ef          	jal	80001950 <myproc>
    80003b76:	15053503          	ld	a0,336(a0)
    80003b7a:	94bff0ef          	jal	800034c4 <idup>
    80003b7e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b80:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003b84:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b86:	4b85                	li	s7,1
    80003b88:	a871                	j	80003c24 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003b8a:	4585                	li	a1,1
    80003b8c:	4505                	li	a0,1
    80003b8e:	ef8ff0ef          	jal	80003286 <iget>
    80003b92:	8a2a                	mv	s4,a0
    80003b94:	b7f5                	j	80003b80 <namex+0x3a>
      iunlockput(ip);
    80003b96:	8552                	mv	a0,s4
    80003b98:	b6dff0ef          	jal	80003704 <iunlockput>
      return 0;
    80003b9c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b9e:	8552                	mv	a0,s4
    80003ba0:	60e6                	ld	ra,88(sp)
    80003ba2:	6446                	ld	s0,80(sp)
    80003ba4:	64a6                	ld	s1,72(sp)
    80003ba6:	6906                	ld	s2,64(sp)
    80003ba8:	79e2                	ld	s3,56(sp)
    80003baa:	7a42                	ld	s4,48(sp)
    80003bac:	7aa2                	ld	s5,40(sp)
    80003bae:	7b02                	ld	s6,32(sp)
    80003bb0:	6be2                	ld	s7,24(sp)
    80003bb2:	6c42                	ld	s8,16(sp)
    80003bb4:	6ca2                	ld	s9,8(sp)
    80003bb6:	6125                	addi	sp,sp,96
    80003bb8:	8082                	ret
      iunlock(ip);
    80003bba:	8552                	mv	a0,s4
    80003bbc:	9edff0ef          	jal	800035a8 <iunlock>
      return ip;
    80003bc0:	bff9                	j	80003b9e <namex+0x58>
      iunlockput(ip);
    80003bc2:	8552                	mv	a0,s4
    80003bc4:	b41ff0ef          	jal	80003704 <iunlockput>
      return 0;
    80003bc8:	8a4e                	mv	s4,s3
    80003bca:	bfd1                	j	80003b9e <namex+0x58>
  len = path - s;
    80003bcc:	40998633          	sub	a2,s3,s1
    80003bd0:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003bd4:	099c5063          	bge	s8,s9,80003c54 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003bd8:	4639                	li	a2,14
    80003bda:	85a6                	mv	a1,s1
    80003bdc:	8556                	mv	a0,s5
    80003bde:	920fd0ef          	jal	80000cfe <memmove>
    80003be2:	84ce                	mv	s1,s3
  while(*path == '/')
    80003be4:	0004c783          	lbu	a5,0(s1)
    80003be8:	01279763          	bne	a5,s2,80003bf6 <namex+0xb0>
    path++;
    80003bec:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bee:	0004c783          	lbu	a5,0(s1)
    80003bf2:	ff278de3          	beq	a5,s2,80003bec <namex+0xa6>
    ilock(ip);
    80003bf6:	8552                	mv	a0,s4
    80003bf8:	903ff0ef          	jal	800034fa <ilock>
    if(ip->type != T_DIR){
    80003bfc:	044a1783          	lh	a5,68(s4)
    80003c00:	f9779be3          	bne	a5,s7,80003b96 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003c04:	000b0563          	beqz	s6,80003c0e <namex+0xc8>
    80003c08:	0004c783          	lbu	a5,0(s1)
    80003c0c:	d7dd                	beqz	a5,80003bba <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c0e:	4601                	li	a2,0
    80003c10:	85d6                	mv	a1,s5
    80003c12:	8552                	mv	a0,s4
    80003c14:	e97ff0ef          	jal	80003aaa <dirlookup>
    80003c18:	89aa                	mv	s3,a0
    80003c1a:	d545                	beqz	a0,80003bc2 <namex+0x7c>
    iunlockput(ip);
    80003c1c:	8552                	mv	a0,s4
    80003c1e:	ae7ff0ef          	jal	80003704 <iunlockput>
    ip = next;
    80003c22:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003c24:	0004c783          	lbu	a5,0(s1)
    80003c28:	01279763          	bne	a5,s2,80003c36 <namex+0xf0>
    path++;
    80003c2c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c2e:	0004c783          	lbu	a5,0(s1)
    80003c32:	ff278de3          	beq	a5,s2,80003c2c <namex+0xe6>
  if(*path == 0)
    80003c36:	cb8d                	beqz	a5,80003c68 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003c38:	0004c783          	lbu	a5,0(s1)
    80003c3c:	89a6                	mv	s3,s1
  len = path - s;
    80003c3e:	4c81                	li	s9,0
    80003c40:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003c42:	01278963          	beq	a5,s2,80003c54 <namex+0x10e>
    80003c46:	d3d9                	beqz	a5,80003bcc <namex+0x86>
    path++;
    80003c48:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003c4a:	0009c783          	lbu	a5,0(s3)
    80003c4e:	ff279ce3          	bne	a5,s2,80003c46 <namex+0x100>
    80003c52:	bfad                	j	80003bcc <namex+0x86>
    memmove(name, s, len);
    80003c54:	2601                	sext.w	a2,a2
    80003c56:	85a6                	mv	a1,s1
    80003c58:	8556                	mv	a0,s5
    80003c5a:	8a4fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003c5e:	9cd6                	add	s9,s9,s5
    80003c60:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003c64:	84ce                	mv	s1,s3
    80003c66:	bfbd                	j	80003be4 <namex+0x9e>
  if(nameiparent){
    80003c68:	f20b0be3          	beqz	s6,80003b9e <namex+0x58>
    iput(ip);
    80003c6c:	8552                	mv	a0,s4
    80003c6e:	a0fff0ef          	jal	8000367c <iput>
    return 0;
    80003c72:	4a01                	li	s4,0
    80003c74:	b72d                	j	80003b9e <namex+0x58>

0000000080003c76 <dirlink>:
{
    80003c76:	7139                	addi	sp,sp,-64
    80003c78:	fc06                	sd	ra,56(sp)
    80003c7a:	f822                	sd	s0,48(sp)
    80003c7c:	f04a                	sd	s2,32(sp)
    80003c7e:	ec4e                	sd	s3,24(sp)
    80003c80:	e852                	sd	s4,16(sp)
    80003c82:	0080                	addi	s0,sp,64
    80003c84:	892a                	mv	s2,a0
    80003c86:	8a2e                	mv	s4,a1
    80003c88:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c8a:	4601                	li	a2,0
    80003c8c:	e1fff0ef          	jal	80003aaa <dirlookup>
    80003c90:	e535                	bnez	a0,80003cfc <dirlink+0x86>
    80003c92:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c94:	04c92483          	lw	s1,76(s2)
    80003c98:	c48d                	beqz	s1,80003cc2 <dirlink+0x4c>
    80003c9a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c9c:	4741                	li	a4,16
    80003c9e:	86a6                	mv	a3,s1
    80003ca0:	fc040613          	addi	a2,s0,-64
    80003ca4:	4581                	li	a1,0
    80003ca6:	854a                	mv	a0,s2
    80003ca8:	be3ff0ef          	jal	8000388a <readi>
    80003cac:	47c1                	li	a5,16
    80003cae:	04f51b63          	bne	a0,a5,80003d04 <dirlink+0x8e>
    if(de.inum == 0)
    80003cb2:	fc045783          	lhu	a5,-64(s0)
    80003cb6:	c791                	beqz	a5,80003cc2 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cb8:	24c1                	addiw	s1,s1,16
    80003cba:	04c92783          	lw	a5,76(s2)
    80003cbe:	fcf4efe3          	bltu	s1,a5,80003c9c <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003cc2:	4639                	li	a2,14
    80003cc4:	85d2                	mv	a1,s4
    80003cc6:	fc240513          	addi	a0,s0,-62
    80003cca:	8dafd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003cce:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cd2:	4741                	li	a4,16
    80003cd4:	86a6                	mv	a3,s1
    80003cd6:	fc040613          	addi	a2,s0,-64
    80003cda:	4581                	li	a1,0
    80003cdc:	854a                	mv	a0,s2
    80003cde:	ca9ff0ef          	jal	80003986 <writei>
    80003ce2:	1541                	addi	a0,a0,-16
    80003ce4:	00a03533          	snez	a0,a0
    80003ce8:	40a00533          	neg	a0,a0
    80003cec:	74a2                	ld	s1,40(sp)
}
    80003cee:	70e2                	ld	ra,56(sp)
    80003cf0:	7442                	ld	s0,48(sp)
    80003cf2:	7902                	ld	s2,32(sp)
    80003cf4:	69e2                	ld	s3,24(sp)
    80003cf6:	6a42                	ld	s4,16(sp)
    80003cf8:	6121                	addi	sp,sp,64
    80003cfa:	8082                	ret
    iput(ip);
    80003cfc:	981ff0ef          	jal	8000367c <iput>
    return -1;
    80003d00:	557d                	li	a0,-1
    80003d02:	b7f5                	j	80003cee <dirlink+0x78>
      panic("dirlink read");
    80003d04:	00003517          	auipc	a0,0x3
    80003d08:	7cc50513          	addi	a0,a0,1996 # 800074d0 <etext+0x4d0>
    80003d0c:	ad5fc0ef          	jal	800007e0 <panic>

0000000080003d10 <namei>:

struct inode*
namei(char *path)
{
    80003d10:	1101                	addi	sp,sp,-32
    80003d12:	ec06                	sd	ra,24(sp)
    80003d14:	e822                	sd	s0,16(sp)
    80003d16:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d18:	fe040613          	addi	a2,s0,-32
    80003d1c:	4581                	li	a1,0
    80003d1e:	e29ff0ef          	jal	80003b46 <namex>
}
    80003d22:	60e2                	ld	ra,24(sp)
    80003d24:	6442                	ld	s0,16(sp)
    80003d26:	6105                	addi	sp,sp,32
    80003d28:	8082                	ret

0000000080003d2a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d2a:	1141                	addi	sp,sp,-16
    80003d2c:	e406                	sd	ra,8(sp)
    80003d2e:	e022                	sd	s0,0(sp)
    80003d30:	0800                	addi	s0,sp,16
    80003d32:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d34:	4585                	li	a1,1
    80003d36:	e11ff0ef          	jal	80003b46 <namex>
}
    80003d3a:	60a2                	ld	ra,8(sp)
    80003d3c:	6402                	ld	s0,0(sp)
    80003d3e:	0141                	addi	sp,sp,16
    80003d40:	8082                	ret

0000000080003d42 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d42:	1101                	addi	sp,sp,-32
    80003d44:	ec06                	sd	ra,24(sp)
    80003d46:	e822                	sd	s0,16(sp)
    80003d48:	e426                	sd	s1,8(sp)
    80003d4a:	e04a                	sd	s2,0(sp)
    80003d4c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d4e:	0001f917          	auipc	s2,0x1f
    80003d52:	a8290913          	addi	s2,s2,-1406 # 800227d0 <log>
    80003d56:	01892583          	lw	a1,24(s2)
    80003d5a:	02492503          	lw	a0,36(s2)
    80003d5e:	8d0ff0ef          	jal	80002e2e <bread>
    80003d62:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003d64:	02892603          	lw	a2,40(s2)
    80003d68:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d6a:	00c05f63          	blez	a2,80003d88 <write_head+0x46>
    80003d6e:	0001f717          	auipc	a4,0x1f
    80003d72:	a8e70713          	addi	a4,a4,-1394 # 800227fc <log+0x2c>
    80003d76:	87aa                	mv	a5,a0
    80003d78:	060a                	slli	a2,a2,0x2
    80003d7a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d7c:	4314                	lw	a3,0(a4)
    80003d7e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d80:	0711                	addi	a4,a4,4
    80003d82:	0791                	addi	a5,a5,4
    80003d84:	fec79ce3          	bne	a5,a2,80003d7c <write_head+0x3a>
  }
  bwrite(buf);
    80003d88:	8526                	mv	a0,s1
    80003d8a:	97aff0ef          	jal	80002f04 <bwrite>
  brelse(buf);
    80003d8e:	8526                	mv	a0,s1
    80003d90:	9a6ff0ef          	jal	80002f36 <brelse>
}
    80003d94:	60e2                	ld	ra,24(sp)
    80003d96:	6442                	ld	s0,16(sp)
    80003d98:	64a2                	ld	s1,8(sp)
    80003d9a:	6902                	ld	s2,0(sp)
    80003d9c:	6105                	addi	sp,sp,32
    80003d9e:	8082                	ret

0000000080003da0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003da0:	0001f797          	auipc	a5,0x1f
    80003da4:	a587a783          	lw	a5,-1448(a5) # 800227f8 <log+0x28>
    80003da8:	0af05e63          	blez	a5,80003e64 <install_trans+0xc4>
{
    80003dac:	715d                	addi	sp,sp,-80
    80003dae:	e486                	sd	ra,72(sp)
    80003db0:	e0a2                	sd	s0,64(sp)
    80003db2:	fc26                	sd	s1,56(sp)
    80003db4:	f84a                	sd	s2,48(sp)
    80003db6:	f44e                	sd	s3,40(sp)
    80003db8:	f052                	sd	s4,32(sp)
    80003dba:	ec56                	sd	s5,24(sp)
    80003dbc:	e85a                	sd	s6,16(sp)
    80003dbe:	e45e                	sd	s7,8(sp)
    80003dc0:	0880                	addi	s0,sp,80
    80003dc2:	8b2a                	mv	s6,a0
    80003dc4:	0001fa97          	auipc	s5,0x1f
    80003dc8:	a38a8a93          	addi	s5,s5,-1480 # 800227fc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dcc:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003dce:	00003b97          	auipc	s7,0x3
    80003dd2:	712b8b93          	addi	s7,s7,1810 # 800074e0 <etext+0x4e0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003dd6:	0001fa17          	auipc	s4,0x1f
    80003dda:	9faa0a13          	addi	s4,s4,-1542 # 800227d0 <log>
    80003dde:	a025                	j	80003e06 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003de0:	000aa603          	lw	a2,0(s5)
    80003de4:	85ce                	mv	a1,s3
    80003de6:	855e                	mv	a0,s7
    80003de8:	f12fc0ef          	jal	800004fa <printf>
    80003dec:	a839                	j	80003e0a <install_trans+0x6a>
    brelse(lbuf);
    80003dee:	854a                	mv	a0,s2
    80003df0:	946ff0ef          	jal	80002f36 <brelse>
    brelse(dbuf);
    80003df4:	8526                	mv	a0,s1
    80003df6:	940ff0ef          	jal	80002f36 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dfa:	2985                	addiw	s3,s3,1
    80003dfc:	0a91                	addi	s5,s5,4
    80003dfe:	028a2783          	lw	a5,40(s4)
    80003e02:	04f9d663          	bge	s3,a5,80003e4e <install_trans+0xae>
    if(recovering) {
    80003e06:	fc0b1de3          	bnez	s6,80003de0 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e0a:	018a2583          	lw	a1,24(s4)
    80003e0e:	013585bb          	addw	a1,a1,s3
    80003e12:	2585                	addiw	a1,a1,1
    80003e14:	024a2503          	lw	a0,36(s4)
    80003e18:	816ff0ef          	jal	80002e2e <bread>
    80003e1c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003e1e:	000aa583          	lw	a1,0(s5)
    80003e22:	024a2503          	lw	a0,36(s4)
    80003e26:	808ff0ef          	jal	80002e2e <bread>
    80003e2a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e2c:	40000613          	li	a2,1024
    80003e30:	05890593          	addi	a1,s2,88
    80003e34:	05850513          	addi	a0,a0,88
    80003e38:	ec7fc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	8c6ff0ef          	jal	80002f04 <bwrite>
    if(recovering == 0)
    80003e42:	fa0b16e3          	bnez	s6,80003dee <install_trans+0x4e>
      bunpin(dbuf);
    80003e46:	8526                	mv	a0,s1
    80003e48:	9aaff0ef          	jal	80002ff2 <bunpin>
    80003e4c:	b74d                	j	80003dee <install_trans+0x4e>
}
    80003e4e:	60a6                	ld	ra,72(sp)
    80003e50:	6406                	ld	s0,64(sp)
    80003e52:	74e2                	ld	s1,56(sp)
    80003e54:	7942                	ld	s2,48(sp)
    80003e56:	79a2                	ld	s3,40(sp)
    80003e58:	7a02                	ld	s4,32(sp)
    80003e5a:	6ae2                	ld	s5,24(sp)
    80003e5c:	6b42                	ld	s6,16(sp)
    80003e5e:	6ba2                	ld	s7,8(sp)
    80003e60:	6161                	addi	sp,sp,80
    80003e62:	8082                	ret
    80003e64:	8082                	ret

0000000080003e66 <initlog>:
{
    80003e66:	7179                	addi	sp,sp,-48
    80003e68:	f406                	sd	ra,40(sp)
    80003e6a:	f022                	sd	s0,32(sp)
    80003e6c:	ec26                	sd	s1,24(sp)
    80003e6e:	e84a                	sd	s2,16(sp)
    80003e70:	e44e                	sd	s3,8(sp)
    80003e72:	1800                	addi	s0,sp,48
    80003e74:	892a                	mv	s2,a0
    80003e76:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e78:	0001f497          	auipc	s1,0x1f
    80003e7c:	95848493          	addi	s1,s1,-1704 # 800227d0 <log>
    80003e80:	00003597          	auipc	a1,0x3
    80003e84:	68058593          	addi	a1,a1,1664 # 80007500 <etext+0x500>
    80003e88:	8526                	mv	a0,s1
    80003e8a:	cc5fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003e8e:	0149a583          	lw	a1,20(s3)
    80003e92:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003e94:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e98:	854a                	mv	a0,s2
    80003e9a:	f95fe0ef          	jal	80002e2e <bread>
  log.lh.n = lh->n;
    80003e9e:	4d30                	lw	a2,88(a0)
    80003ea0:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003ea2:	00c05f63          	blez	a2,80003ec0 <initlog+0x5a>
    80003ea6:	87aa                	mv	a5,a0
    80003ea8:	0001f717          	auipc	a4,0x1f
    80003eac:	95470713          	addi	a4,a4,-1708 # 800227fc <log+0x2c>
    80003eb0:	060a                	slli	a2,a2,0x2
    80003eb2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003eb4:	4ff4                	lw	a3,92(a5)
    80003eb6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003eb8:	0791                	addi	a5,a5,4
    80003eba:	0711                	addi	a4,a4,4
    80003ebc:	fec79ce3          	bne	a5,a2,80003eb4 <initlog+0x4e>
  brelse(buf);
    80003ec0:	876ff0ef          	jal	80002f36 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ec4:	4505                	li	a0,1
    80003ec6:	edbff0ef          	jal	80003da0 <install_trans>
  log.lh.n = 0;
    80003eca:	0001f797          	auipc	a5,0x1f
    80003ece:	9207a723          	sw	zero,-1746(a5) # 800227f8 <log+0x28>
  write_head(); // clear the log
    80003ed2:	e71ff0ef          	jal	80003d42 <write_head>
}
    80003ed6:	70a2                	ld	ra,40(sp)
    80003ed8:	7402                	ld	s0,32(sp)
    80003eda:	64e2                	ld	s1,24(sp)
    80003edc:	6942                	ld	s2,16(sp)
    80003ede:	69a2                	ld	s3,8(sp)
    80003ee0:	6145                	addi	sp,sp,48
    80003ee2:	8082                	ret

0000000080003ee4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ee4:	1101                	addi	sp,sp,-32
    80003ee6:	ec06                	sd	ra,24(sp)
    80003ee8:	e822                	sd	s0,16(sp)
    80003eea:	e426                	sd	s1,8(sp)
    80003eec:	e04a                	sd	s2,0(sp)
    80003eee:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ef0:	0001f517          	auipc	a0,0x1f
    80003ef4:	8e050513          	addi	a0,a0,-1824 # 800227d0 <log>
    80003ef8:	cd7fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003efc:	0001f497          	auipc	s1,0x1f
    80003f00:	8d448493          	addi	s1,s1,-1836 # 800227d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003f04:	4979                	li	s2,30
    80003f06:	a029                	j	80003f10 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003f08:	85a6                	mv	a1,s1
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	a02fe0ef          	jal	8000210e <sleep>
    if(log.committing){
    80003f10:	509c                	lw	a5,32(s1)
    80003f12:	fbfd                	bnez	a5,80003f08 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003f14:	4cd8                	lw	a4,28(s1)
    80003f16:	2705                	addiw	a4,a4,1
    80003f18:	0027179b          	slliw	a5,a4,0x2
    80003f1c:	9fb9                	addw	a5,a5,a4
    80003f1e:	0017979b          	slliw	a5,a5,0x1
    80003f22:	5494                	lw	a3,40(s1)
    80003f24:	9fb5                	addw	a5,a5,a3
    80003f26:	00f95763          	bge	s2,a5,80003f34 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f2a:	85a6                	mv	a1,s1
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	9e0fe0ef          	jal	8000210e <sleep>
    80003f32:	bff9                	j	80003f10 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003f34:	0001f517          	auipc	a0,0x1f
    80003f38:	89c50513          	addi	a0,a0,-1892 # 800227d0 <log>
    80003f3c:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003f3e:	d29fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003f42:	60e2                	ld	ra,24(sp)
    80003f44:	6442                	ld	s0,16(sp)
    80003f46:	64a2                	ld	s1,8(sp)
    80003f48:	6902                	ld	s2,0(sp)
    80003f4a:	6105                	addi	sp,sp,32
    80003f4c:	8082                	ret

0000000080003f4e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f4e:	7139                	addi	sp,sp,-64
    80003f50:	fc06                	sd	ra,56(sp)
    80003f52:	f822                	sd	s0,48(sp)
    80003f54:	f426                	sd	s1,40(sp)
    80003f56:	f04a                	sd	s2,32(sp)
    80003f58:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f5a:	0001f497          	auipc	s1,0x1f
    80003f5e:	87648493          	addi	s1,s1,-1930 # 800227d0 <log>
    80003f62:	8526                	mv	a0,s1
    80003f64:	c6bfc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003f68:	4cdc                	lw	a5,28(s1)
    80003f6a:	37fd                	addiw	a5,a5,-1
    80003f6c:	0007891b          	sext.w	s2,a5
    80003f70:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003f72:	509c                	lw	a5,32(s1)
    80003f74:	ef9d                	bnez	a5,80003fb2 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f76:	04091763          	bnez	s2,80003fc4 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003f7a:	0001f497          	auipc	s1,0x1f
    80003f7e:	85648493          	addi	s1,s1,-1962 # 800227d0 <log>
    80003f82:	4785                	li	a5,1
    80003f84:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f86:	8526                	mv	a0,s1
    80003f88:	cdffc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f8c:	549c                	lw	a5,40(s1)
    80003f8e:	04f04b63          	bgtz	a5,80003fe4 <end_op+0x96>
    acquire(&log.lock);
    80003f92:	0001f497          	auipc	s1,0x1f
    80003f96:	83e48493          	addi	s1,s1,-1986 # 800227d0 <log>
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	c33fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003fa0:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003fa4:	8526                	mv	a0,s1
    80003fa6:	9b4fe0ef          	jal	8000215a <wakeup>
    release(&log.lock);
    80003faa:	8526                	mv	a0,s1
    80003fac:	cbbfc0ef          	jal	80000c66 <release>
}
    80003fb0:	a025                	j	80003fd8 <end_op+0x8a>
    80003fb2:	ec4e                	sd	s3,24(sp)
    80003fb4:	e852                	sd	s4,16(sp)
    80003fb6:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003fb8:	00003517          	auipc	a0,0x3
    80003fbc:	55050513          	addi	a0,a0,1360 # 80007508 <etext+0x508>
    80003fc0:	821fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003fc4:	0001f497          	auipc	s1,0x1f
    80003fc8:	80c48493          	addi	s1,s1,-2036 # 800227d0 <log>
    80003fcc:	8526                	mv	a0,s1
    80003fce:	98cfe0ef          	jal	8000215a <wakeup>
  release(&log.lock);
    80003fd2:	8526                	mv	a0,s1
    80003fd4:	c93fc0ef          	jal	80000c66 <release>
}
    80003fd8:	70e2                	ld	ra,56(sp)
    80003fda:	7442                	ld	s0,48(sp)
    80003fdc:	74a2                	ld	s1,40(sp)
    80003fde:	7902                	ld	s2,32(sp)
    80003fe0:	6121                	addi	sp,sp,64
    80003fe2:	8082                	ret
    80003fe4:	ec4e                	sd	s3,24(sp)
    80003fe6:	e852                	sd	s4,16(sp)
    80003fe8:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fea:	0001fa97          	auipc	s5,0x1f
    80003fee:	812a8a93          	addi	s5,s5,-2030 # 800227fc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003ff2:	0001ea17          	auipc	s4,0x1e
    80003ff6:	7dea0a13          	addi	s4,s4,2014 # 800227d0 <log>
    80003ffa:	018a2583          	lw	a1,24(s4)
    80003ffe:	012585bb          	addw	a1,a1,s2
    80004002:	2585                	addiw	a1,a1,1
    80004004:	024a2503          	lw	a0,36(s4)
    80004008:	e27fe0ef          	jal	80002e2e <bread>
    8000400c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000400e:	000aa583          	lw	a1,0(s5)
    80004012:	024a2503          	lw	a0,36(s4)
    80004016:	e19fe0ef          	jal	80002e2e <bread>
    8000401a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000401c:	40000613          	li	a2,1024
    80004020:	05850593          	addi	a1,a0,88
    80004024:	05848513          	addi	a0,s1,88
    80004028:	cd7fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    8000402c:	8526                	mv	a0,s1
    8000402e:	ed7fe0ef          	jal	80002f04 <bwrite>
    brelse(from);
    80004032:	854e                	mv	a0,s3
    80004034:	f03fe0ef          	jal	80002f36 <brelse>
    brelse(to);
    80004038:	8526                	mv	a0,s1
    8000403a:	efdfe0ef          	jal	80002f36 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000403e:	2905                	addiw	s2,s2,1
    80004040:	0a91                	addi	s5,s5,4
    80004042:	028a2783          	lw	a5,40(s4)
    80004046:	faf94ae3          	blt	s2,a5,80003ffa <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000404a:	cf9ff0ef          	jal	80003d42 <write_head>
    install_trans(0); // Now install writes to home locations
    8000404e:	4501                	li	a0,0
    80004050:	d51ff0ef          	jal	80003da0 <install_trans>
    log.lh.n = 0;
    80004054:	0001e797          	auipc	a5,0x1e
    80004058:	7a07a223          	sw	zero,1956(a5) # 800227f8 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000405c:	ce7ff0ef          	jal	80003d42 <write_head>
    80004060:	69e2                	ld	s3,24(sp)
    80004062:	6a42                	ld	s4,16(sp)
    80004064:	6aa2                	ld	s5,8(sp)
    80004066:	b735                	j	80003f92 <end_op+0x44>

0000000080004068 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004068:	1101                	addi	sp,sp,-32
    8000406a:	ec06                	sd	ra,24(sp)
    8000406c:	e822                	sd	s0,16(sp)
    8000406e:	e426                	sd	s1,8(sp)
    80004070:	e04a                	sd	s2,0(sp)
    80004072:	1000                	addi	s0,sp,32
    80004074:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004076:	0001e917          	auipc	s2,0x1e
    8000407a:	75a90913          	addi	s2,s2,1882 # 800227d0 <log>
    8000407e:	854a                	mv	a0,s2
    80004080:	b4ffc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004084:	02892603          	lw	a2,40(s2)
    80004088:	47f5                	li	a5,29
    8000408a:	04c7cc63          	blt	a5,a2,800040e2 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000408e:	0001e797          	auipc	a5,0x1e
    80004092:	75e7a783          	lw	a5,1886(a5) # 800227ec <log+0x1c>
    80004096:	04f05c63          	blez	a5,800040ee <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000409a:	4781                	li	a5,0
    8000409c:	04c05f63          	blez	a2,800040fa <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040a0:	44cc                	lw	a1,12(s1)
    800040a2:	0001e717          	auipc	a4,0x1e
    800040a6:	75a70713          	addi	a4,a4,1882 # 800227fc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800040aa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040ac:	4314                	lw	a3,0(a4)
    800040ae:	04b68663          	beq	a3,a1,800040fa <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800040b2:	2785                	addiw	a5,a5,1
    800040b4:	0711                	addi	a4,a4,4
    800040b6:	fef61be3          	bne	a2,a5,800040ac <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800040ba:	0621                	addi	a2,a2,8
    800040bc:	060a                	slli	a2,a2,0x2
    800040be:	0001e797          	auipc	a5,0x1e
    800040c2:	71278793          	addi	a5,a5,1810 # 800227d0 <log>
    800040c6:	97b2                	add	a5,a5,a2
    800040c8:	44d8                	lw	a4,12(s1)
    800040ca:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800040cc:	8526                	mv	a0,s1
    800040ce:	ef1fe0ef          	jal	80002fbe <bpin>
    log.lh.n++;
    800040d2:	0001e717          	auipc	a4,0x1e
    800040d6:	6fe70713          	addi	a4,a4,1790 # 800227d0 <log>
    800040da:	571c                	lw	a5,40(a4)
    800040dc:	2785                	addiw	a5,a5,1
    800040de:	d71c                	sw	a5,40(a4)
    800040e0:	a80d                	j	80004112 <log_write+0xaa>
    panic("too big a transaction");
    800040e2:	00003517          	auipc	a0,0x3
    800040e6:	43650513          	addi	a0,a0,1078 # 80007518 <etext+0x518>
    800040ea:	ef6fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    800040ee:	00003517          	auipc	a0,0x3
    800040f2:	44250513          	addi	a0,a0,1090 # 80007530 <etext+0x530>
    800040f6:	eeafc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    800040fa:	00878693          	addi	a3,a5,8
    800040fe:	068a                	slli	a3,a3,0x2
    80004100:	0001e717          	auipc	a4,0x1e
    80004104:	6d070713          	addi	a4,a4,1744 # 800227d0 <log>
    80004108:	9736                	add	a4,a4,a3
    8000410a:	44d4                	lw	a3,12(s1)
    8000410c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000410e:	faf60fe3          	beq	a2,a5,800040cc <log_write+0x64>
  }
  release(&log.lock);
    80004112:	0001e517          	auipc	a0,0x1e
    80004116:	6be50513          	addi	a0,a0,1726 # 800227d0 <log>
    8000411a:	b4dfc0ef          	jal	80000c66 <release>
}
    8000411e:	60e2                	ld	ra,24(sp)
    80004120:	6442                	ld	s0,16(sp)
    80004122:	64a2                	ld	s1,8(sp)
    80004124:	6902                	ld	s2,0(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000412a:	1101                	addi	sp,sp,-32
    8000412c:	ec06                	sd	ra,24(sp)
    8000412e:	e822                	sd	s0,16(sp)
    80004130:	e426                	sd	s1,8(sp)
    80004132:	e04a                	sd	s2,0(sp)
    80004134:	1000                	addi	s0,sp,32
    80004136:	84aa                	mv	s1,a0
    80004138:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000413a:	00003597          	auipc	a1,0x3
    8000413e:	41658593          	addi	a1,a1,1046 # 80007550 <etext+0x550>
    80004142:	0521                	addi	a0,a0,8
    80004144:	a0bfc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004148:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000414c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004150:	0204a423          	sw	zero,40(s1)
}
    80004154:	60e2                	ld	ra,24(sp)
    80004156:	6442                	ld	s0,16(sp)
    80004158:	64a2                	ld	s1,8(sp)
    8000415a:	6902                	ld	s2,0(sp)
    8000415c:	6105                	addi	sp,sp,32
    8000415e:	8082                	ret

0000000080004160 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004160:	1101                	addi	sp,sp,-32
    80004162:	ec06                	sd	ra,24(sp)
    80004164:	e822                	sd	s0,16(sp)
    80004166:	e426                	sd	s1,8(sp)
    80004168:	e04a                	sd	s2,0(sp)
    8000416a:	1000                	addi	s0,sp,32
    8000416c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000416e:	00850913          	addi	s2,a0,8
    80004172:	854a                	mv	a0,s2
    80004174:	a5bfc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80004178:	409c                	lw	a5,0(s1)
    8000417a:	c799                	beqz	a5,80004188 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000417c:	85ca                	mv	a1,s2
    8000417e:	8526                	mv	a0,s1
    80004180:	f8ffd0ef          	jal	8000210e <sleep>
  while (lk->locked) {
    80004184:	409c                	lw	a5,0(s1)
    80004186:	fbfd                	bnez	a5,8000417c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004188:	4785                	li	a5,1
    8000418a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000418c:	fc4fd0ef          	jal	80001950 <myproc>
    80004190:	591c                	lw	a5,48(a0)
    80004192:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004194:	854a                	mv	a0,s2
    80004196:	ad1fc0ef          	jal	80000c66 <release>
}
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	64a2                	ld	s1,8(sp)
    800041a0:	6902                	ld	s2,0(sp)
    800041a2:	6105                	addi	sp,sp,32
    800041a4:	8082                	ret

00000000800041a6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041a6:	1101                	addi	sp,sp,-32
    800041a8:	ec06                	sd	ra,24(sp)
    800041aa:	e822                	sd	s0,16(sp)
    800041ac:	e426                	sd	s1,8(sp)
    800041ae:	e04a                	sd	s2,0(sp)
    800041b0:	1000                	addi	s0,sp,32
    800041b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041b4:	00850913          	addi	s2,a0,8
    800041b8:	854a                	mv	a0,s2
    800041ba:	a15fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    800041be:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041c2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800041c6:	8526                	mv	a0,s1
    800041c8:	f93fd0ef          	jal	8000215a <wakeup>
  release(&lk->lk);
    800041cc:	854a                	mv	a0,s2
    800041ce:	a99fc0ef          	jal	80000c66 <release>
}
    800041d2:	60e2                	ld	ra,24(sp)
    800041d4:	6442                	ld	s0,16(sp)
    800041d6:	64a2                	ld	s1,8(sp)
    800041d8:	6902                	ld	s2,0(sp)
    800041da:	6105                	addi	sp,sp,32
    800041dc:	8082                	ret

00000000800041de <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800041de:	7179                	addi	sp,sp,-48
    800041e0:	f406                	sd	ra,40(sp)
    800041e2:	f022                	sd	s0,32(sp)
    800041e4:	ec26                	sd	s1,24(sp)
    800041e6:	e84a                	sd	s2,16(sp)
    800041e8:	1800                	addi	s0,sp,48
    800041ea:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800041ec:	00850913          	addi	s2,a0,8
    800041f0:	854a                	mv	a0,s2
    800041f2:	9ddfc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041f6:	409c                	lw	a5,0(s1)
    800041f8:	ef81                	bnez	a5,80004210 <holdingsleep+0x32>
    800041fa:	4481                	li	s1,0
  release(&lk->lk);
    800041fc:	854a                	mv	a0,s2
    800041fe:	a69fc0ef          	jal	80000c66 <release>
  return r;
}
    80004202:	8526                	mv	a0,s1
    80004204:	70a2                	ld	ra,40(sp)
    80004206:	7402                	ld	s0,32(sp)
    80004208:	64e2                	ld	s1,24(sp)
    8000420a:	6942                	ld	s2,16(sp)
    8000420c:	6145                	addi	sp,sp,48
    8000420e:	8082                	ret
    80004210:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004212:	0284a983          	lw	s3,40(s1)
    80004216:	f3afd0ef          	jal	80001950 <myproc>
    8000421a:	5904                	lw	s1,48(a0)
    8000421c:	413484b3          	sub	s1,s1,s3
    80004220:	0014b493          	seqz	s1,s1
    80004224:	69a2                	ld	s3,8(sp)
    80004226:	bfd9                	j	800041fc <holdingsleep+0x1e>

0000000080004228 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004228:	1141                	addi	sp,sp,-16
    8000422a:	e406                	sd	ra,8(sp)
    8000422c:	e022                	sd	s0,0(sp)
    8000422e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004230:	00003597          	auipc	a1,0x3
    80004234:	33058593          	addi	a1,a1,816 # 80007560 <etext+0x560>
    80004238:	0001e517          	auipc	a0,0x1e
    8000423c:	6e050513          	addi	a0,a0,1760 # 80022918 <ftable>
    80004240:	90ffc0ef          	jal	80000b4e <initlock>
}
    80004244:	60a2                	ld	ra,8(sp)
    80004246:	6402                	ld	s0,0(sp)
    80004248:	0141                	addi	sp,sp,16
    8000424a:	8082                	ret

000000008000424c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000424c:	1101                	addi	sp,sp,-32
    8000424e:	ec06                	sd	ra,24(sp)
    80004250:	e822                	sd	s0,16(sp)
    80004252:	e426                	sd	s1,8(sp)
    80004254:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004256:	0001e517          	auipc	a0,0x1e
    8000425a:	6c250513          	addi	a0,a0,1730 # 80022918 <ftable>
    8000425e:	971fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004262:	0001e497          	auipc	s1,0x1e
    80004266:	6ce48493          	addi	s1,s1,1742 # 80022930 <ftable+0x18>
    8000426a:	0001f717          	auipc	a4,0x1f
    8000426e:	66670713          	addi	a4,a4,1638 # 800238d0 <disk>
    if(f->ref == 0){
    80004272:	40dc                	lw	a5,4(s1)
    80004274:	cf89                	beqz	a5,8000428e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004276:	02848493          	addi	s1,s1,40
    8000427a:	fee49ce3          	bne	s1,a4,80004272 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000427e:	0001e517          	auipc	a0,0x1e
    80004282:	69a50513          	addi	a0,a0,1690 # 80022918 <ftable>
    80004286:	9e1fc0ef          	jal	80000c66 <release>
  return 0;
    8000428a:	4481                	li	s1,0
    8000428c:	a809                	j	8000429e <filealloc+0x52>
      f->ref = 1;
    8000428e:	4785                	li	a5,1
    80004290:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004292:	0001e517          	auipc	a0,0x1e
    80004296:	68650513          	addi	a0,a0,1670 # 80022918 <ftable>
    8000429a:	9cdfc0ef          	jal	80000c66 <release>
}
    8000429e:	8526                	mv	a0,s1
    800042a0:	60e2                	ld	ra,24(sp)
    800042a2:	6442                	ld	s0,16(sp)
    800042a4:	64a2                	ld	s1,8(sp)
    800042a6:	6105                	addi	sp,sp,32
    800042a8:	8082                	ret

00000000800042aa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800042aa:	1101                	addi	sp,sp,-32
    800042ac:	ec06                	sd	ra,24(sp)
    800042ae:	e822                	sd	s0,16(sp)
    800042b0:	e426                	sd	s1,8(sp)
    800042b2:	1000                	addi	s0,sp,32
    800042b4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042b6:	0001e517          	auipc	a0,0x1e
    800042ba:	66250513          	addi	a0,a0,1634 # 80022918 <ftable>
    800042be:	911fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800042c2:	40dc                	lw	a5,4(s1)
    800042c4:	02f05063          	blez	a5,800042e4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800042c8:	2785                	addiw	a5,a5,1
    800042ca:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800042cc:	0001e517          	auipc	a0,0x1e
    800042d0:	64c50513          	addi	a0,a0,1612 # 80022918 <ftable>
    800042d4:	993fc0ef          	jal	80000c66 <release>
  return f;
}
    800042d8:	8526                	mv	a0,s1
    800042da:	60e2                	ld	ra,24(sp)
    800042dc:	6442                	ld	s0,16(sp)
    800042de:	64a2                	ld	s1,8(sp)
    800042e0:	6105                	addi	sp,sp,32
    800042e2:	8082                	ret
    panic("filedup");
    800042e4:	00003517          	auipc	a0,0x3
    800042e8:	28450513          	addi	a0,a0,644 # 80007568 <etext+0x568>
    800042ec:	cf4fc0ef          	jal	800007e0 <panic>

00000000800042f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042f0:	7139                	addi	sp,sp,-64
    800042f2:	fc06                	sd	ra,56(sp)
    800042f4:	f822                	sd	s0,48(sp)
    800042f6:	f426                	sd	s1,40(sp)
    800042f8:	0080                	addi	s0,sp,64
    800042fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042fc:	0001e517          	auipc	a0,0x1e
    80004300:	61c50513          	addi	a0,a0,1564 # 80022918 <ftable>
    80004304:	8cbfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004308:	40dc                	lw	a5,4(s1)
    8000430a:	04f05a63          	blez	a5,8000435e <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000430e:	37fd                	addiw	a5,a5,-1
    80004310:	0007871b          	sext.w	a4,a5
    80004314:	c0dc                	sw	a5,4(s1)
    80004316:	04e04e63          	bgtz	a4,80004372 <fileclose+0x82>
    8000431a:	f04a                	sd	s2,32(sp)
    8000431c:	ec4e                	sd	s3,24(sp)
    8000431e:	e852                	sd	s4,16(sp)
    80004320:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004322:	0004a903          	lw	s2,0(s1)
    80004326:	0094ca83          	lbu	s5,9(s1)
    8000432a:	0104ba03          	ld	s4,16(s1)
    8000432e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004332:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004336:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000433a:	0001e517          	auipc	a0,0x1e
    8000433e:	5de50513          	addi	a0,a0,1502 # 80022918 <ftable>
    80004342:	925fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    80004346:	4785                	li	a5,1
    80004348:	04f90063          	beq	s2,a5,80004388 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000434c:	3979                	addiw	s2,s2,-2
    8000434e:	4785                	li	a5,1
    80004350:	0527f563          	bgeu	a5,s2,8000439a <fileclose+0xaa>
    80004354:	7902                	ld	s2,32(sp)
    80004356:	69e2                	ld	s3,24(sp)
    80004358:	6a42                	ld	s4,16(sp)
    8000435a:	6aa2                	ld	s5,8(sp)
    8000435c:	a00d                	j	8000437e <fileclose+0x8e>
    8000435e:	f04a                	sd	s2,32(sp)
    80004360:	ec4e                	sd	s3,24(sp)
    80004362:	e852                	sd	s4,16(sp)
    80004364:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004366:	00003517          	auipc	a0,0x3
    8000436a:	20a50513          	addi	a0,a0,522 # 80007570 <etext+0x570>
    8000436e:	c72fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004372:	0001e517          	auipc	a0,0x1e
    80004376:	5a650513          	addi	a0,a0,1446 # 80022918 <ftable>
    8000437a:	8edfc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000437e:	70e2                	ld	ra,56(sp)
    80004380:	7442                	ld	s0,48(sp)
    80004382:	74a2                	ld	s1,40(sp)
    80004384:	6121                	addi	sp,sp,64
    80004386:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004388:	85d6                	mv	a1,s5
    8000438a:	8552                	mv	a0,s4
    8000438c:	336000ef          	jal	800046c2 <pipeclose>
    80004390:	7902                	ld	s2,32(sp)
    80004392:	69e2                	ld	s3,24(sp)
    80004394:	6a42                	ld	s4,16(sp)
    80004396:	6aa2                	ld	s5,8(sp)
    80004398:	b7dd                	j	8000437e <fileclose+0x8e>
    begin_op();
    8000439a:	b4bff0ef          	jal	80003ee4 <begin_op>
    iput(ff.ip);
    8000439e:	854e                	mv	a0,s3
    800043a0:	adcff0ef          	jal	8000367c <iput>
    end_op();
    800043a4:	babff0ef          	jal	80003f4e <end_op>
    800043a8:	7902                	ld	s2,32(sp)
    800043aa:	69e2                	ld	s3,24(sp)
    800043ac:	6a42                	ld	s4,16(sp)
    800043ae:	6aa2                	ld	s5,8(sp)
    800043b0:	b7f9                	j	8000437e <fileclose+0x8e>

00000000800043b2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043b2:	715d                	addi	sp,sp,-80
    800043b4:	e486                	sd	ra,72(sp)
    800043b6:	e0a2                	sd	s0,64(sp)
    800043b8:	fc26                	sd	s1,56(sp)
    800043ba:	f44e                	sd	s3,40(sp)
    800043bc:	0880                	addi	s0,sp,80
    800043be:	84aa                	mv	s1,a0
    800043c0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800043c2:	d8efd0ef          	jal	80001950 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800043c6:	409c                	lw	a5,0(s1)
    800043c8:	37f9                	addiw	a5,a5,-2
    800043ca:	4705                	li	a4,1
    800043cc:	04f76063          	bltu	a4,a5,8000440c <filestat+0x5a>
    800043d0:	f84a                	sd	s2,48(sp)
    800043d2:	892a                	mv	s2,a0
    ilock(f->ip);
    800043d4:	6c88                	ld	a0,24(s1)
    800043d6:	924ff0ef          	jal	800034fa <ilock>
    stati(f->ip, &st);
    800043da:	fb840593          	addi	a1,s0,-72
    800043de:	6c88                	ld	a0,24(s1)
    800043e0:	c80ff0ef          	jal	80003860 <stati>
    iunlock(f->ip);
    800043e4:	6c88                	ld	a0,24(s1)
    800043e6:	9c2ff0ef          	jal	800035a8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800043ea:	46e1                	li	a3,24
    800043ec:	fb840613          	addi	a2,s0,-72
    800043f0:	85ce                	mv	a1,s3
    800043f2:	05093503          	ld	a0,80(s2)
    800043f6:	9ecfd0ef          	jal	800015e2 <copyout>
    800043fa:	41f5551b          	sraiw	a0,a0,0x1f
    800043fe:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004400:	60a6                	ld	ra,72(sp)
    80004402:	6406                	ld	s0,64(sp)
    80004404:	74e2                	ld	s1,56(sp)
    80004406:	79a2                	ld	s3,40(sp)
    80004408:	6161                	addi	sp,sp,80
    8000440a:	8082                	ret
  return -1;
    8000440c:	557d                	li	a0,-1
    8000440e:	bfcd                	j	80004400 <filestat+0x4e>

0000000080004410 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004410:	7179                	addi	sp,sp,-48
    80004412:	f406                	sd	ra,40(sp)
    80004414:	f022                	sd	s0,32(sp)
    80004416:	e84a                	sd	s2,16(sp)
    80004418:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000441a:	00854783          	lbu	a5,8(a0)
    8000441e:	cfd1                	beqz	a5,800044ba <fileread+0xaa>
    80004420:	ec26                	sd	s1,24(sp)
    80004422:	e44e                	sd	s3,8(sp)
    80004424:	84aa                	mv	s1,a0
    80004426:	89ae                	mv	s3,a1
    80004428:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000442a:	411c                	lw	a5,0(a0)
    8000442c:	4705                	li	a4,1
    8000442e:	04e78363          	beq	a5,a4,80004474 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004432:	470d                	li	a4,3
    80004434:	04e78763          	beq	a5,a4,80004482 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004438:	4709                	li	a4,2
    8000443a:	06e79a63          	bne	a5,a4,800044ae <fileread+0x9e>
    ilock(f->ip);
    8000443e:	6d08                	ld	a0,24(a0)
    80004440:	8baff0ef          	jal	800034fa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004444:	874a                	mv	a4,s2
    80004446:	5094                	lw	a3,32(s1)
    80004448:	864e                	mv	a2,s3
    8000444a:	4585                	li	a1,1
    8000444c:	6c88                	ld	a0,24(s1)
    8000444e:	c3cff0ef          	jal	8000388a <readi>
    80004452:	892a                	mv	s2,a0
    80004454:	00a05563          	blez	a0,8000445e <fileread+0x4e>
      f->off += r;
    80004458:	509c                	lw	a5,32(s1)
    8000445a:	9fa9                	addw	a5,a5,a0
    8000445c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000445e:	6c88                	ld	a0,24(s1)
    80004460:	948ff0ef          	jal	800035a8 <iunlock>
    80004464:	64e2                	ld	s1,24(sp)
    80004466:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004468:	854a                	mv	a0,s2
    8000446a:	70a2                	ld	ra,40(sp)
    8000446c:	7402                	ld	s0,32(sp)
    8000446e:	6942                	ld	s2,16(sp)
    80004470:	6145                	addi	sp,sp,48
    80004472:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004474:	6908                	ld	a0,16(a0)
    80004476:	388000ef          	jal	800047fe <piperead>
    8000447a:	892a                	mv	s2,a0
    8000447c:	64e2                	ld	s1,24(sp)
    8000447e:	69a2                	ld	s3,8(sp)
    80004480:	b7e5                	j	80004468 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004482:	02451783          	lh	a5,36(a0)
    80004486:	03079693          	slli	a3,a5,0x30
    8000448a:	92c1                	srli	a3,a3,0x30
    8000448c:	4725                	li	a4,9
    8000448e:	02d76863          	bltu	a4,a3,800044be <fileread+0xae>
    80004492:	0792                	slli	a5,a5,0x4
    80004494:	0001e717          	auipc	a4,0x1e
    80004498:	3e470713          	addi	a4,a4,996 # 80022878 <devsw>
    8000449c:	97ba                	add	a5,a5,a4
    8000449e:	639c                	ld	a5,0(a5)
    800044a0:	c39d                	beqz	a5,800044c6 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800044a2:	4505                	li	a0,1
    800044a4:	9782                	jalr	a5
    800044a6:	892a                	mv	s2,a0
    800044a8:	64e2                	ld	s1,24(sp)
    800044aa:	69a2                	ld	s3,8(sp)
    800044ac:	bf75                	j	80004468 <fileread+0x58>
    panic("fileread");
    800044ae:	00003517          	auipc	a0,0x3
    800044b2:	0d250513          	addi	a0,a0,210 # 80007580 <etext+0x580>
    800044b6:	b2afc0ef          	jal	800007e0 <panic>
    return -1;
    800044ba:	597d                	li	s2,-1
    800044bc:	b775                	j	80004468 <fileread+0x58>
      return -1;
    800044be:	597d                	li	s2,-1
    800044c0:	64e2                	ld	s1,24(sp)
    800044c2:	69a2                	ld	s3,8(sp)
    800044c4:	b755                	j	80004468 <fileread+0x58>
    800044c6:	597d                	li	s2,-1
    800044c8:	64e2                	ld	s1,24(sp)
    800044ca:	69a2                	ld	s3,8(sp)
    800044cc:	bf71                	j	80004468 <fileread+0x58>

00000000800044ce <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800044ce:	00954783          	lbu	a5,9(a0)
    800044d2:	10078b63          	beqz	a5,800045e8 <filewrite+0x11a>
{
    800044d6:	715d                	addi	sp,sp,-80
    800044d8:	e486                	sd	ra,72(sp)
    800044da:	e0a2                	sd	s0,64(sp)
    800044dc:	f84a                	sd	s2,48(sp)
    800044de:	f052                	sd	s4,32(sp)
    800044e0:	e85a                	sd	s6,16(sp)
    800044e2:	0880                	addi	s0,sp,80
    800044e4:	892a                	mv	s2,a0
    800044e6:	8b2e                	mv	s6,a1
    800044e8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800044ea:	411c                	lw	a5,0(a0)
    800044ec:	4705                	li	a4,1
    800044ee:	02e78763          	beq	a5,a4,8000451c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044f2:	470d                	li	a4,3
    800044f4:	02e78863          	beq	a5,a4,80004524 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800044f8:	4709                	li	a4,2
    800044fa:	0ce79c63          	bne	a5,a4,800045d2 <filewrite+0x104>
    800044fe:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004500:	0ac05863          	blez	a2,800045b0 <filewrite+0xe2>
    80004504:	fc26                	sd	s1,56(sp)
    80004506:	ec56                	sd	s5,24(sp)
    80004508:	e45e                	sd	s7,8(sp)
    8000450a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000450c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000450e:	6b85                	lui	s7,0x1
    80004510:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004514:	6c05                	lui	s8,0x1
    80004516:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000451a:	a8b5                	j	80004596 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000451c:	6908                	ld	a0,16(a0)
    8000451e:	1fc000ef          	jal	8000471a <pipewrite>
    80004522:	a04d                	j	800045c4 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004524:	02451783          	lh	a5,36(a0)
    80004528:	03079693          	slli	a3,a5,0x30
    8000452c:	92c1                	srli	a3,a3,0x30
    8000452e:	4725                	li	a4,9
    80004530:	0ad76e63          	bltu	a4,a3,800045ec <filewrite+0x11e>
    80004534:	0792                	slli	a5,a5,0x4
    80004536:	0001e717          	auipc	a4,0x1e
    8000453a:	34270713          	addi	a4,a4,834 # 80022878 <devsw>
    8000453e:	97ba                	add	a5,a5,a4
    80004540:	679c                	ld	a5,8(a5)
    80004542:	c7dd                	beqz	a5,800045f0 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004544:	4505                	li	a0,1
    80004546:	9782                	jalr	a5
    80004548:	a8b5                	j	800045c4 <filewrite+0xf6>
      if(n1 > max)
    8000454a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000454e:	997ff0ef          	jal	80003ee4 <begin_op>
      ilock(f->ip);
    80004552:	01893503          	ld	a0,24(s2)
    80004556:	fa5fe0ef          	jal	800034fa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000455a:	8756                	mv	a4,s5
    8000455c:	02092683          	lw	a3,32(s2)
    80004560:	01698633          	add	a2,s3,s6
    80004564:	4585                	li	a1,1
    80004566:	01893503          	ld	a0,24(s2)
    8000456a:	c1cff0ef          	jal	80003986 <writei>
    8000456e:	84aa                	mv	s1,a0
    80004570:	00a05763          	blez	a0,8000457e <filewrite+0xb0>
        f->off += r;
    80004574:	02092783          	lw	a5,32(s2)
    80004578:	9fa9                	addw	a5,a5,a0
    8000457a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000457e:	01893503          	ld	a0,24(s2)
    80004582:	826ff0ef          	jal	800035a8 <iunlock>
      end_op();
    80004586:	9c9ff0ef          	jal	80003f4e <end_op>

      if(r != n1){
    8000458a:	029a9563          	bne	s5,s1,800045b4 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000458e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004592:	0149da63          	bge	s3,s4,800045a6 <filewrite+0xd8>
      int n1 = n - i;
    80004596:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000459a:	0004879b          	sext.w	a5,s1
    8000459e:	fafbd6e3          	bge	s7,a5,8000454a <filewrite+0x7c>
    800045a2:	84e2                	mv	s1,s8
    800045a4:	b75d                	j	8000454a <filewrite+0x7c>
    800045a6:	74e2                	ld	s1,56(sp)
    800045a8:	6ae2                	ld	s5,24(sp)
    800045aa:	6ba2                	ld	s7,8(sp)
    800045ac:	6c02                	ld	s8,0(sp)
    800045ae:	a039                	j	800045bc <filewrite+0xee>
    int i = 0;
    800045b0:	4981                	li	s3,0
    800045b2:	a029                	j	800045bc <filewrite+0xee>
    800045b4:	74e2                	ld	s1,56(sp)
    800045b6:	6ae2                	ld	s5,24(sp)
    800045b8:	6ba2                	ld	s7,8(sp)
    800045ba:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800045bc:	033a1c63          	bne	s4,s3,800045f4 <filewrite+0x126>
    800045c0:	8552                	mv	a0,s4
    800045c2:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800045c4:	60a6                	ld	ra,72(sp)
    800045c6:	6406                	ld	s0,64(sp)
    800045c8:	7942                	ld	s2,48(sp)
    800045ca:	7a02                	ld	s4,32(sp)
    800045cc:	6b42                	ld	s6,16(sp)
    800045ce:	6161                	addi	sp,sp,80
    800045d0:	8082                	ret
    800045d2:	fc26                	sd	s1,56(sp)
    800045d4:	f44e                	sd	s3,40(sp)
    800045d6:	ec56                	sd	s5,24(sp)
    800045d8:	e45e                	sd	s7,8(sp)
    800045da:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800045dc:	00003517          	auipc	a0,0x3
    800045e0:	fb450513          	addi	a0,a0,-76 # 80007590 <etext+0x590>
    800045e4:	9fcfc0ef          	jal	800007e0 <panic>
    return -1;
    800045e8:	557d                	li	a0,-1
}
    800045ea:	8082                	ret
      return -1;
    800045ec:	557d                	li	a0,-1
    800045ee:	bfd9                	j	800045c4 <filewrite+0xf6>
    800045f0:	557d                	li	a0,-1
    800045f2:	bfc9                	j	800045c4 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800045f4:	557d                	li	a0,-1
    800045f6:	79a2                	ld	s3,40(sp)
    800045f8:	b7f1                	j	800045c4 <filewrite+0xf6>

00000000800045fa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045fa:	7179                	addi	sp,sp,-48
    800045fc:	f406                	sd	ra,40(sp)
    800045fe:	f022                	sd	s0,32(sp)
    80004600:	ec26                	sd	s1,24(sp)
    80004602:	e052                	sd	s4,0(sp)
    80004604:	1800                	addi	s0,sp,48
    80004606:	84aa                	mv	s1,a0
    80004608:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000460a:	0005b023          	sd	zero,0(a1)
    8000460e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004612:	c3bff0ef          	jal	8000424c <filealloc>
    80004616:	e088                	sd	a0,0(s1)
    80004618:	c549                	beqz	a0,800046a2 <pipealloc+0xa8>
    8000461a:	c33ff0ef          	jal	8000424c <filealloc>
    8000461e:	00aa3023          	sd	a0,0(s4)
    80004622:	cd25                	beqz	a0,8000469a <pipealloc+0xa0>
    80004624:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004626:	cd8fc0ef          	jal	80000afe <kalloc>
    8000462a:	892a                	mv	s2,a0
    8000462c:	c12d                	beqz	a0,8000468e <pipealloc+0x94>
    8000462e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004630:	4985                	li	s3,1
    80004632:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004636:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000463a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000463e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004642:	00003597          	auipc	a1,0x3
    80004646:	f5e58593          	addi	a1,a1,-162 # 800075a0 <etext+0x5a0>
    8000464a:	d04fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    8000464e:	609c                	ld	a5,0(s1)
    80004650:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004654:	609c                	ld	a5,0(s1)
    80004656:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000465a:	609c                	ld	a5,0(s1)
    8000465c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004660:	609c                	ld	a5,0(s1)
    80004662:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004666:	000a3783          	ld	a5,0(s4)
    8000466a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000466e:	000a3783          	ld	a5,0(s4)
    80004672:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004676:	000a3783          	ld	a5,0(s4)
    8000467a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000467e:	000a3783          	ld	a5,0(s4)
    80004682:	0127b823          	sd	s2,16(a5)
  return 0;
    80004686:	4501                	li	a0,0
    80004688:	6942                	ld	s2,16(sp)
    8000468a:	69a2                	ld	s3,8(sp)
    8000468c:	a01d                	j	800046b2 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000468e:	6088                	ld	a0,0(s1)
    80004690:	c119                	beqz	a0,80004696 <pipealloc+0x9c>
    80004692:	6942                	ld	s2,16(sp)
    80004694:	a029                	j	8000469e <pipealloc+0xa4>
    80004696:	6942                	ld	s2,16(sp)
    80004698:	a029                	j	800046a2 <pipealloc+0xa8>
    8000469a:	6088                	ld	a0,0(s1)
    8000469c:	c10d                	beqz	a0,800046be <pipealloc+0xc4>
    fileclose(*f0);
    8000469e:	c53ff0ef          	jal	800042f0 <fileclose>
  if(*f1)
    800046a2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046a6:	557d                	li	a0,-1
  if(*f1)
    800046a8:	c789                	beqz	a5,800046b2 <pipealloc+0xb8>
    fileclose(*f1);
    800046aa:	853e                	mv	a0,a5
    800046ac:	c45ff0ef          	jal	800042f0 <fileclose>
  return -1;
    800046b0:	557d                	li	a0,-1
}
    800046b2:	70a2                	ld	ra,40(sp)
    800046b4:	7402                	ld	s0,32(sp)
    800046b6:	64e2                	ld	s1,24(sp)
    800046b8:	6a02                	ld	s4,0(sp)
    800046ba:	6145                	addi	sp,sp,48
    800046bc:	8082                	ret
  return -1;
    800046be:	557d                	li	a0,-1
    800046c0:	bfcd                	j	800046b2 <pipealloc+0xb8>

00000000800046c2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046c2:	1101                	addi	sp,sp,-32
    800046c4:	ec06                	sd	ra,24(sp)
    800046c6:	e822                	sd	s0,16(sp)
    800046c8:	e426                	sd	s1,8(sp)
    800046ca:	e04a                	sd	s2,0(sp)
    800046cc:	1000                	addi	s0,sp,32
    800046ce:	84aa                	mv	s1,a0
    800046d0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800046d2:	cfcfc0ef          	jal	80000bce <acquire>
  if(writable){
    800046d6:	02090763          	beqz	s2,80004704 <pipeclose+0x42>
    pi->writeopen = 0;
    800046da:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046de:	21848513          	addi	a0,s1,536
    800046e2:	a79fd0ef          	jal	8000215a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800046e6:	2204b783          	ld	a5,544(s1)
    800046ea:	e785                	bnez	a5,80004712 <pipeclose+0x50>
    release(&pi->lock);
    800046ec:	8526                	mv	a0,s1
    800046ee:	d78fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800046f2:	8526                	mv	a0,s1
    800046f4:	b28fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800046f8:	60e2                	ld	ra,24(sp)
    800046fa:	6442                	ld	s0,16(sp)
    800046fc:	64a2                	ld	s1,8(sp)
    800046fe:	6902                	ld	s2,0(sp)
    80004700:	6105                	addi	sp,sp,32
    80004702:	8082                	ret
    pi->readopen = 0;
    80004704:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004708:	21c48513          	addi	a0,s1,540
    8000470c:	a4ffd0ef          	jal	8000215a <wakeup>
    80004710:	bfd9                	j	800046e6 <pipeclose+0x24>
    release(&pi->lock);
    80004712:	8526                	mv	a0,s1
    80004714:	d52fc0ef          	jal	80000c66 <release>
}
    80004718:	b7c5                	j	800046f8 <pipeclose+0x36>

000000008000471a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000471a:	711d                	addi	sp,sp,-96
    8000471c:	ec86                	sd	ra,88(sp)
    8000471e:	e8a2                	sd	s0,80(sp)
    80004720:	e4a6                	sd	s1,72(sp)
    80004722:	e0ca                	sd	s2,64(sp)
    80004724:	fc4e                	sd	s3,56(sp)
    80004726:	f852                	sd	s4,48(sp)
    80004728:	f456                	sd	s5,40(sp)
    8000472a:	1080                	addi	s0,sp,96
    8000472c:	84aa                	mv	s1,a0
    8000472e:	8aae                	mv	s5,a1
    80004730:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004732:	a1efd0ef          	jal	80001950 <myproc>
    80004736:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004738:	8526                	mv	a0,s1
    8000473a:	c94fc0ef          	jal	80000bce <acquire>
  while(i < n){
    8000473e:	0b405a63          	blez	s4,800047f2 <pipewrite+0xd8>
    80004742:	f05a                	sd	s6,32(sp)
    80004744:	ec5e                	sd	s7,24(sp)
    80004746:	e862                	sd	s8,16(sp)
  int i = 0;
    80004748:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000474a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000474c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004750:	21c48b93          	addi	s7,s1,540
    80004754:	a81d                	j	8000478a <pipewrite+0x70>
      release(&pi->lock);
    80004756:	8526                	mv	a0,s1
    80004758:	d0efc0ef          	jal	80000c66 <release>
      return -1;
    8000475c:	597d                	li	s2,-1
    8000475e:	7b02                	ld	s6,32(sp)
    80004760:	6be2                	ld	s7,24(sp)
    80004762:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004764:	854a                	mv	a0,s2
    80004766:	60e6                	ld	ra,88(sp)
    80004768:	6446                	ld	s0,80(sp)
    8000476a:	64a6                	ld	s1,72(sp)
    8000476c:	6906                	ld	s2,64(sp)
    8000476e:	79e2                	ld	s3,56(sp)
    80004770:	7a42                	ld	s4,48(sp)
    80004772:	7aa2                	ld	s5,40(sp)
    80004774:	6125                	addi	sp,sp,96
    80004776:	8082                	ret
      wakeup(&pi->nread);
    80004778:	8562                	mv	a0,s8
    8000477a:	9e1fd0ef          	jal	8000215a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000477e:	85a6                	mv	a1,s1
    80004780:	855e                	mv	a0,s7
    80004782:	98dfd0ef          	jal	8000210e <sleep>
  while(i < n){
    80004786:	05495b63          	bge	s2,s4,800047dc <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000478a:	2204a783          	lw	a5,544(s1)
    8000478e:	d7e1                	beqz	a5,80004756 <pipewrite+0x3c>
    80004790:	854e                	mv	a0,s3
    80004792:	bedfd0ef          	jal	8000237e <killed>
    80004796:	f161                	bnez	a0,80004756 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004798:	2184a783          	lw	a5,536(s1)
    8000479c:	21c4a703          	lw	a4,540(s1)
    800047a0:	2007879b          	addiw	a5,a5,512
    800047a4:	fcf70ae3          	beq	a4,a5,80004778 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047a8:	4685                	li	a3,1
    800047aa:	01590633          	add	a2,s2,s5
    800047ae:	faf40593          	addi	a1,s0,-81
    800047b2:	0509b503          	ld	a0,80(s3)
    800047b6:	f11fc0ef          	jal	800016c6 <copyin>
    800047ba:	03650e63          	beq	a0,s6,800047f6 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800047be:	21c4a783          	lw	a5,540(s1)
    800047c2:	0017871b          	addiw	a4,a5,1
    800047c6:	20e4ae23          	sw	a4,540(s1)
    800047ca:	1ff7f793          	andi	a5,a5,511
    800047ce:	97a6                	add	a5,a5,s1
    800047d0:	faf44703          	lbu	a4,-81(s0)
    800047d4:	00e78c23          	sb	a4,24(a5)
      i++;
    800047d8:	2905                	addiw	s2,s2,1
    800047da:	b775                	j	80004786 <pipewrite+0x6c>
    800047dc:	7b02                	ld	s6,32(sp)
    800047de:	6be2                	ld	s7,24(sp)
    800047e0:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800047e2:	21848513          	addi	a0,s1,536
    800047e6:	975fd0ef          	jal	8000215a <wakeup>
  release(&pi->lock);
    800047ea:	8526                	mv	a0,s1
    800047ec:	c7afc0ef          	jal	80000c66 <release>
  return i;
    800047f0:	bf95                	j	80004764 <pipewrite+0x4a>
  int i = 0;
    800047f2:	4901                	li	s2,0
    800047f4:	b7fd                	j	800047e2 <pipewrite+0xc8>
    800047f6:	7b02                	ld	s6,32(sp)
    800047f8:	6be2                	ld	s7,24(sp)
    800047fa:	6c42                	ld	s8,16(sp)
    800047fc:	b7dd                	j	800047e2 <pipewrite+0xc8>

00000000800047fe <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047fe:	715d                	addi	sp,sp,-80
    80004800:	e486                	sd	ra,72(sp)
    80004802:	e0a2                	sd	s0,64(sp)
    80004804:	fc26                	sd	s1,56(sp)
    80004806:	f84a                	sd	s2,48(sp)
    80004808:	f44e                	sd	s3,40(sp)
    8000480a:	f052                	sd	s4,32(sp)
    8000480c:	ec56                	sd	s5,24(sp)
    8000480e:	0880                	addi	s0,sp,80
    80004810:	84aa                	mv	s1,a0
    80004812:	892e                	mv	s2,a1
    80004814:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004816:	93afd0ef          	jal	80001950 <myproc>
    8000481a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000481c:	8526                	mv	a0,s1
    8000481e:	bb0fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004822:	2184a703          	lw	a4,536(s1)
    80004826:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000482a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000482e:	02f71563          	bne	a4,a5,80004858 <piperead+0x5a>
    80004832:	2244a783          	lw	a5,548(s1)
    80004836:	cb85                	beqz	a5,80004866 <piperead+0x68>
    if(killed(pr)){
    80004838:	8552                	mv	a0,s4
    8000483a:	b45fd0ef          	jal	8000237e <killed>
    8000483e:	ed19                	bnez	a0,8000485c <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004840:	85a6                	mv	a1,s1
    80004842:	854e                	mv	a0,s3
    80004844:	8cbfd0ef          	jal	8000210e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004848:	2184a703          	lw	a4,536(s1)
    8000484c:	21c4a783          	lw	a5,540(s1)
    80004850:	fef701e3          	beq	a4,a5,80004832 <piperead+0x34>
    80004854:	e85a                	sd	s6,16(sp)
    80004856:	a809                	j	80004868 <piperead+0x6a>
    80004858:	e85a                	sd	s6,16(sp)
    8000485a:	a039                	j	80004868 <piperead+0x6a>
      release(&pi->lock);
    8000485c:	8526                	mv	a0,s1
    8000485e:	c08fc0ef          	jal	80000c66 <release>
      return -1;
    80004862:	59fd                	li	s3,-1
    80004864:	a8b9                	j	800048c2 <piperead+0xc4>
    80004866:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004868:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000486a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000486c:	05505363          	blez	s5,800048b2 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004870:	2184a783          	lw	a5,536(s1)
    80004874:	21c4a703          	lw	a4,540(s1)
    80004878:	02f70d63          	beq	a4,a5,800048b2 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    8000487c:	1ff7f793          	andi	a5,a5,511
    80004880:	97a6                	add	a5,a5,s1
    80004882:	0187c783          	lbu	a5,24(a5)
    80004886:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000488a:	4685                	li	a3,1
    8000488c:	fbf40613          	addi	a2,s0,-65
    80004890:	85ca                	mv	a1,s2
    80004892:	050a3503          	ld	a0,80(s4)
    80004896:	d4dfc0ef          	jal	800015e2 <copyout>
    8000489a:	03650e63          	beq	a0,s6,800048d6 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000489e:	2184a783          	lw	a5,536(s1)
    800048a2:	2785                	addiw	a5,a5,1
    800048a4:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048a8:	2985                	addiw	s3,s3,1
    800048aa:	0905                	addi	s2,s2,1
    800048ac:	fd3a92e3          	bne	s5,s3,80004870 <piperead+0x72>
    800048b0:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800048b2:	21c48513          	addi	a0,s1,540
    800048b6:	8a5fd0ef          	jal	8000215a <wakeup>
  release(&pi->lock);
    800048ba:	8526                	mv	a0,s1
    800048bc:	baafc0ef          	jal	80000c66 <release>
    800048c0:	6b42                	ld	s6,16(sp)
  return i;
}
    800048c2:	854e                	mv	a0,s3
    800048c4:	60a6                	ld	ra,72(sp)
    800048c6:	6406                	ld	s0,64(sp)
    800048c8:	74e2                	ld	s1,56(sp)
    800048ca:	7942                	ld	s2,48(sp)
    800048cc:	79a2                	ld	s3,40(sp)
    800048ce:	7a02                	ld	s4,32(sp)
    800048d0:	6ae2                	ld	s5,24(sp)
    800048d2:	6161                	addi	sp,sp,80
    800048d4:	8082                	ret
      if(i == 0)
    800048d6:	fc099ee3          	bnez	s3,800048b2 <piperead+0xb4>
        i = -1;
    800048da:	89aa                	mv	s3,a0
    800048dc:	bfd9                	j	800048b2 <piperead+0xb4>

00000000800048de <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800048de:	1141                	addi	sp,sp,-16
    800048e0:	e422                	sd	s0,8(sp)
    800048e2:	0800                	addi	s0,sp,16
    800048e4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800048e6:	8905                	andi	a0,a0,1
    800048e8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800048ea:	8b89                	andi	a5,a5,2
    800048ec:	c399                	beqz	a5,800048f2 <flags2perm+0x14>
      perm |= PTE_W;
    800048ee:	00456513          	ori	a0,a0,4
    return perm;
}
    800048f2:	6422                	ld	s0,8(sp)
    800048f4:	0141                	addi	sp,sp,16
    800048f6:	8082                	ret

00000000800048f8 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048f8:	df010113          	addi	sp,sp,-528
    800048fc:	20113423          	sd	ra,520(sp)
    80004900:	20813023          	sd	s0,512(sp)
    80004904:	ffa6                	sd	s1,504(sp)
    80004906:	fbca                	sd	s2,496(sp)
    80004908:	0c00                	addi	s0,sp,528
    8000490a:	892a                	mv	s2,a0
    8000490c:	dea43c23          	sd	a0,-520(s0)
    80004910:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004914:	83cfd0ef          	jal	80001950 <myproc>
    80004918:	84aa                	mv	s1,a0

  begin_op();
    8000491a:	dcaff0ef          	jal	80003ee4 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000491e:	854a                	mv	a0,s2
    80004920:	bf0ff0ef          	jal	80003d10 <namei>
    80004924:	c931                	beqz	a0,80004978 <kexec+0x80>
    80004926:	f3d2                	sd	s4,480(sp)
    80004928:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000492a:	bd1fe0ef          	jal	800034fa <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000492e:	04000713          	li	a4,64
    80004932:	4681                	li	a3,0
    80004934:	e5040613          	addi	a2,s0,-432
    80004938:	4581                	li	a1,0
    8000493a:	8552                	mv	a0,s4
    8000493c:	f4ffe0ef          	jal	8000388a <readi>
    80004940:	04000793          	li	a5,64
    80004944:	00f51a63          	bne	a0,a5,80004958 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004948:	e5042703          	lw	a4,-432(s0)
    8000494c:	464c47b7          	lui	a5,0x464c4
    80004950:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004954:	02f70663          	beq	a4,a5,80004980 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004958:	8552                	mv	a0,s4
    8000495a:	dabfe0ef          	jal	80003704 <iunlockput>
    end_op();
    8000495e:	df0ff0ef          	jal	80003f4e <end_op>
  }
  return -1;
    80004962:	557d                	li	a0,-1
    80004964:	7a1e                	ld	s4,480(sp)
}
    80004966:	20813083          	ld	ra,520(sp)
    8000496a:	20013403          	ld	s0,512(sp)
    8000496e:	74fe                	ld	s1,504(sp)
    80004970:	795e                	ld	s2,496(sp)
    80004972:	21010113          	addi	sp,sp,528
    80004976:	8082                	ret
    end_op();
    80004978:	dd6ff0ef          	jal	80003f4e <end_op>
    return -1;
    8000497c:	557d                	li	a0,-1
    8000497e:	b7e5                	j	80004966 <kexec+0x6e>
    80004980:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004982:	8526                	mv	a0,s1
    80004984:	8d2fd0ef          	jal	80001a56 <proc_pagetable>
    80004988:	8b2a                	mv	s6,a0
    8000498a:	2c050b63          	beqz	a0,80004c60 <kexec+0x368>
    8000498e:	f7ce                	sd	s3,488(sp)
    80004990:	efd6                	sd	s5,472(sp)
    80004992:	e7de                	sd	s7,456(sp)
    80004994:	e3e2                	sd	s8,448(sp)
    80004996:	ff66                	sd	s9,440(sp)
    80004998:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000499a:	e7042d03          	lw	s10,-400(s0)
    8000499e:	e8845783          	lhu	a5,-376(s0)
    800049a2:	12078963          	beqz	a5,80004ad4 <kexec+0x1dc>
    800049a6:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049a8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049aa:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800049ac:	6c85                	lui	s9,0x1
    800049ae:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049b2:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800049b6:	6a85                	lui	s5,0x1
    800049b8:	a085                	j	80004a18 <kexec+0x120>
      panic("loadseg: address should exist");
    800049ba:	00003517          	auipc	a0,0x3
    800049be:	bee50513          	addi	a0,a0,-1042 # 800075a8 <etext+0x5a8>
    800049c2:	e1ffb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    800049c6:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800049c8:	8726                	mv	a4,s1
    800049ca:	012c06bb          	addw	a3,s8,s2
    800049ce:	4581                	li	a1,0
    800049d0:	8552                	mv	a0,s4
    800049d2:	eb9fe0ef          	jal	8000388a <readi>
    800049d6:	2501                	sext.w	a0,a0
    800049d8:	24a49a63          	bne	s1,a0,80004c2c <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800049dc:	012a893b          	addw	s2,s5,s2
    800049e0:	03397363          	bgeu	s2,s3,80004a06 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800049e4:	02091593          	slli	a1,s2,0x20
    800049e8:	9181                	srli	a1,a1,0x20
    800049ea:	95de                	add	a1,a1,s7
    800049ec:	855a                	mv	a0,s6
    800049ee:	dc2fc0ef          	jal	80000fb0 <walkaddr>
    800049f2:	862a                	mv	a2,a0
    if(pa == 0)
    800049f4:	d179                	beqz	a0,800049ba <kexec+0xc2>
    if(sz - i < PGSIZE)
    800049f6:	412984bb          	subw	s1,s3,s2
    800049fa:	0004879b          	sext.w	a5,s1
    800049fe:	fcfcf4e3          	bgeu	s9,a5,800049c6 <kexec+0xce>
    80004a02:	84d6                	mv	s1,s5
    80004a04:	b7c9                	j	800049c6 <kexec+0xce>
    sz = sz1;
    80004a06:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a0a:	2d85                	addiw	s11,s11,1
    80004a0c:	038d0d1b          	addiw	s10,s10,56
    80004a10:	e8845783          	lhu	a5,-376(s0)
    80004a14:	08fdd063          	bge	s11,a5,80004a94 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a18:	2d01                	sext.w	s10,s10
    80004a1a:	03800713          	li	a4,56
    80004a1e:	86ea                	mv	a3,s10
    80004a20:	e1840613          	addi	a2,s0,-488
    80004a24:	4581                	li	a1,0
    80004a26:	8552                	mv	a0,s4
    80004a28:	e63fe0ef          	jal	8000388a <readi>
    80004a2c:	03800793          	li	a5,56
    80004a30:	1cf51663          	bne	a0,a5,80004bfc <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004a34:	e1842783          	lw	a5,-488(s0)
    80004a38:	4705                	li	a4,1
    80004a3a:	fce798e3          	bne	a5,a4,80004a0a <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004a3e:	e4043483          	ld	s1,-448(s0)
    80004a42:	e3843783          	ld	a5,-456(s0)
    80004a46:	1af4ef63          	bltu	s1,a5,80004c04 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a4a:	e2843783          	ld	a5,-472(s0)
    80004a4e:	94be                	add	s1,s1,a5
    80004a50:	1af4ee63          	bltu	s1,a5,80004c0c <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004a54:	df043703          	ld	a4,-528(s0)
    80004a58:	8ff9                	and	a5,a5,a4
    80004a5a:	1a079d63          	bnez	a5,80004c14 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a5e:	e1c42503          	lw	a0,-484(s0)
    80004a62:	e7dff0ef          	jal	800048de <flags2perm>
    80004a66:	86aa                	mv	a3,a0
    80004a68:	8626                	mv	a2,s1
    80004a6a:	85ca                	mv	a1,s2
    80004a6c:	855a                	mv	a0,s6
    80004a6e:	81bfc0ef          	jal	80001288 <uvmalloc>
    80004a72:	e0a43423          	sd	a0,-504(s0)
    80004a76:	1a050363          	beqz	a0,80004c1c <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a7a:	e2843b83          	ld	s7,-472(s0)
    80004a7e:	e2042c03          	lw	s8,-480(s0)
    80004a82:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a86:	00098463          	beqz	s3,80004a8e <kexec+0x196>
    80004a8a:	4901                	li	s2,0
    80004a8c:	bfa1                	j	800049e4 <kexec+0xec>
    sz = sz1;
    80004a8e:	e0843903          	ld	s2,-504(s0)
    80004a92:	bfa5                	j	80004a0a <kexec+0x112>
    80004a94:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004a96:	8552                	mv	a0,s4
    80004a98:	c6dfe0ef          	jal	80003704 <iunlockput>
  end_op();
    80004a9c:	cb2ff0ef          	jal	80003f4e <end_op>
  p = myproc();
    80004aa0:	eb1fc0ef          	jal	80001950 <myproc>
    80004aa4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004aa6:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004aaa:	6985                	lui	s3,0x1
    80004aac:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004aae:	99ca                	add	s3,s3,s2
    80004ab0:	77fd                	lui	a5,0xfffff
    80004ab2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004ab6:	4691                	li	a3,4
    80004ab8:	6609                	lui	a2,0x2
    80004aba:	964e                	add	a2,a2,s3
    80004abc:	85ce                	mv	a1,s3
    80004abe:	855a                	mv	a0,s6
    80004ac0:	fc8fc0ef          	jal	80001288 <uvmalloc>
    80004ac4:	892a                	mv	s2,a0
    80004ac6:	e0a43423          	sd	a0,-504(s0)
    80004aca:	e519                	bnez	a0,80004ad8 <kexec+0x1e0>
  if(pagetable)
    80004acc:	e1343423          	sd	s3,-504(s0)
    80004ad0:	4a01                	li	s4,0
    80004ad2:	aab1                	j	80004c2e <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ad4:	4901                	li	s2,0
    80004ad6:	b7c1                	j	80004a96 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004ad8:	75f9                	lui	a1,0xffffe
    80004ada:	95aa                	add	a1,a1,a0
    80004adc:	855a                	mv	a0,s6
    80004ade:	981fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004ae2:	7bfd                	lui	s7,0xfffff
    80004ae4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004ae6:	e0043783          	ld	a5,-512(s0)
    80004aea:	6388                	ld	a0,0(a5)
    80004aec:	cd39                	beqz	a0,80004b4a <kexec+0x252>
    80004aee:	e9040993          	addi	s3,s0,-368
    80004af2:	f9040c13          	addi	s8,s0,-112
    80004af6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004af8:	b1afc0ef          	jal	80000e12 <strlen>
    80004afc:	0015079b          	addiw	a5,a0,1
    80004b00:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b04:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b08:	11796e63          	bltu	s2,s7,80004c24 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b0c:	e0043d03          	ld	s10,-512(s0)
    80004b10:	000d3a03          	ld	s4,0(s10)
    80004b14:	8552                	mv	a0,s4
    80004b16:	afcfc0ef          	jal	80000e12 <strlen>
    80004b1a:	0015069b          	addiw	a3,a0,1
    80004b1e:	8652                	mv	a2,s4
    80004b20:	85ca                	mv	a1,s2
    80004b22:	855a                	mv	a0,s6
    80004b24:	abffc0ef          	jal	800015e2 <copyout>
    80004b28:	10054063          	bltz	a0,80004c28 <kexec+0x330>
    ustack[argc] = sp;
    80004b2c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004b30:	0485                	addi	s1,s1,1
    80004b32:	008d0793          	addi	a5,s10,8
    80004b36:	e0f43023          	sd	a5,-512(s0)
    80004b3a:	008d3503          	ld	a0,8(s10)
    80004b3e:	c909                	beqz	a0,80004b50 <kexec+0x258>
    if(argc >= MAXARG)
    80004b40:	09a1                	addi	s3,s3,8
    80004b42:	fb899be3          	bne	s3,s8,80004af8 <kexec+0x200>
  ip = 0;
    80004b46:	4a01                	li	s4,0
    80004b48:	a0dd                	j	80004c2e <kexec+0x336>
  sp = sz;
    80004b4a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004b4e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b50:	00349793          	slli	a5,s1,0x3
    80004b54:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb580>
    80004b58:	97a2                	add	a5,a5,s0
    80004b5a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b5e:	00148693          	addi	a3,s1,1
    80004b62:	068e                	slli	a3,a3,0x3
    80004b64:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b68:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b6c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004b70:	f5796ee3          	bltu	s2,s7,80004acc <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b74:	e9040613          	addi	a2,s0,-368
    80004b78:	85ca                	mv	a1,s2
    80004b7a:	855a                	mv	a0,s6
    80004b7c:	a67fc0ef          	jal	800015e2 <copyout>
    80004b80:	0e054263          	bltz	a0,80004c64 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004b84:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b88:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b8c:	df843783          	ld	a5,-520(s0)
    80004b90:	0007c703          	lbu	a4,0(a5)
    80004b94:	cf11                	beqz	a4,80004bb0 <kexec+0x2b8>
    80004b96:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b98:	02f00693          	li	a3,47
    80004b9c:	a039                	j	80004baa <kexec+0x2b2>
      last = s+1;
    80004b9e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004ba2:	0785                	addi	a5,a5,1
    80004ba4:	fff7c703          	lbu	a4,-1(a5)
    80004ba8:	c701                	beqz	a4,80004bb0 <kexec+0x2b8>
    if(*s == '/')
    80004baa:	fed71ce3          	bne	a4,a3,80004ba2 <kexec+0x2aa>
    80004bae:	bfc5                	j	80004b9e <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004bb0:	4641                	li	a2,16
    80004bb2:	df843583          	ld	a1,-520(s0)
    80004bb6:	158a8513          	addi	a0,s5,344
    80004bba:	a26fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004bbe:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004bc2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004bc6:	e0843783          	ld	a5,-504(s0)
    80004bca:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004bce:	058ab783          	ld	a5,88(s5)
    80004bd2:	e6843703          	ld	a4,-408(s0)
    80004bd6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004bd8:	058ab783          	ld	a5,88(s5)
    80004bdc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004be0:	85e6                	mv	a1,s9
    80004be2:	ef9fc0ef          	jal	80001ada <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004be6:	0004851b          	sext.w	a0,s1
    80004bea:	79be                	ld	s3,488(sp)
    80004bec:	7a1e                	ld	s4,480(sp)
    80004bee:	6afe                	ld	s5,472(sp)
    80004bf0:	6b5e                	ld	s6,464(sp)
    80004bf2:	6bbe                	ld	s7,456(sp)
    80004bf4:	6c1e                	ld	s8,448(sp)
    80004bf6:	7cfa                	ld	s9,440(sp)
    80004bf8:	7d5a                	ld	s10,432(sp)
    80004bfa:	b3b5                	j	80004966 <kexec+0x6e>
    80004bfc:	e1243423          	sd	s2,-504(s0)
    80004c00:	7dba                	ld	s11,424(sp)
    80004c02:	a035                	j	80004c2e <kexec+0x336>
    80004c04:	e1243423          	sd	s2,-504(s0)
    80004c08:	7dba                	ld	s11,424(sp)
    80004c0a:	a015                	j	80004c2e <kexec+0x336>
    80004c0c:	e1243423          	sd	s2,-504(s0)
    80004c10:	7dba                	ld	s11,424(sp)
    80004c12:	a831                	j	80004c2e <kexec+0x336>
    80004c14:	e1243423          	sd	s2,-504(s0)
    80004c18:	7dba                	ld	s11,424(sp)
    80004c1a:	a811                	j	80004c2e <kexec+0x336>
    80004c1c:	e1243423          	sd	s2,-504(s0)
    80004c20:	7dba                	ld	s11,424(sp)
    80004c22:	a031                	j	80004c2e <kexec+0x336>
  ip = 0;
    80004c24:	4a01                	li	s4,0
    80004c26:	a021                	j	80004c2e <kexec+0x336>
    80004c28:	4a01                	li	s4,0
  if(pagetable)
    80004c2a:	a011                	j	80004c2e <kexec+0x336>
    80004c2c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004c2e:	e0843583          	ld	a1,-504(s0)
    80004c32:	855a                	mv	a0,s6
    80004c34:	ea7fc0ef          	jal	80001ada <proc_freepagetable>
  return -1;
    80004c38:	557d                	li	a0,-1
  if(ip){
    80004c3a:	000a1b63          	bnez	s4,80004c50 <kexec+0x358>
    80004c3e:	79be                	ld	s3,488(sp)
    80004c40:	7a1e                	ld	s4,480(sp)
    80004c42:	6afe                	ld	s5,472(sp)
    80004c44:	6b5e                	ld	s6,464(sp)
    80004c46:	6bbe                	ld	s7,456(sp)
    80004c48:	6c1e                	ld	s8,448(sp)
    80004c4a:	7cfa                	ld	s9,440(sp)
    80004c4c:	7d5a                	ld	s10,432(sp)
    80004c4e:	bb21                	j	80004966 <kexec+0x6e>
    80004c50:	79be                	ld	s3,488(sp)
    80004c52:	6afe                	ld	s5,472(sp)
    80004c54:	6b5e                	ld	s6,464(sp)
    80004c56:	6bbe                	ld	s7,456(sp)
    80004c58:	6c1e                	ld	s8,448(sp)
    80004c5a:	7cfa                	ld	s9,440(sp)
    80004c5c:	7d5a                	ld	s10,432(sp)
    80004c5e:	b9ed                	j	80004958 <kexec+0x60>
    80004c60:	6b5e                	ld	s6,464(sp)
    80004c62:	b9dd                	j	80004958 <kexec+0x60>
  sz = sz1;
    80004c64:	e0843983          	ld	s3,-504(s0)
    80004c68:	b595                	j	80004acc <kexec+0x1d4>

0000000080004c6a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c6a:	7179                	addi	sp,sp,-48
    80004c6c:	f406                	sd	ra,40(sp)
    80004c6e:	f022                	sd	s0,32(sp)
    80004c70:	ec26                	sd	s1,24(sp)
    80004c72:	e84a                	sd	s2,16(sp)
    80004c74:	1800                	addi	s0,sp,48
    80004c76:	892e                	mv	s2,a1
    80004c78:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c7a:	fdc40593          	addi	a1,s0,-36
    80004c7e:	e03fd0ef          	jal	80002a80 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004c82:	fdc42703          	lw	a4,-36(s0)
    80004c86:	47bd                	li	a5,15
    80004c88:	02e7e963          	bltu	a5,a4,80004cba <argfd+0x50>
    80004c8c:	cc5fc0ef          	jal	80001950 <myproc>
    80004c90:	fdc42703          	lw	a4,-36(s0)
    80004c94:	01a70793          	addi	a5,a4,26
    80004c98:	078e                	slli	a5,a5,0x3
    80004c9a:	953e                	add	a0,a0,a5
    80004c9c:	611c                	ld	a5,0(a0)
    80004c9e:	c385                	beqz	a5,80004cbe <argfd+0x54>
    return -1;
  if(pfd)
    80004ca0:	00090463          	beqz	s2,80004ca8 <argfd+0x3e>
    *pfd = fd;
    80004ca4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ca8:	4501                	li	a0,0
  if(pf)
    80004caa:	c091                	beqz	s1,80004cae <argfd+0x44>
    *pf = f;
    80004cac:	e09c                	sd	a5,0(s1)
}
    80004cae:	70a2                	ld	ra,40(sp)
    80004cb0:	7402                	ld	s0,32(sp)
    80004cb2:	64e2                	ld	s1,24(sp)
    80004cb4:	6942                	ld	s2,16(sp)
    80004cb6:	6145                	addi	sp,sp,48
    80004cb8:	8082                	ret
    return -1;
    80004cba:	557d                	li	a0,-1
    80004cbc:	bfcd                	j	80004cae <argfd+0x44>
    80004cbe:	557d                	li	a0,-1
    80004cc0:	b7fd                	j	80004cae <argfd+0x44>

0000000080004cc2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004cc2:	1101                	addi	sp,sp,-32
    80004cc4:	ec06                	sd	ra,24(sp)
    80004cc6:	e822                	sd	s0,16(sp)
    80004cc8:	e426                	sd	s1,8(sp)
    80004cca:	1000                	addi	s0,sp,32
    80004ccc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004cce:	c83fc0ef          	jal	80001950 <myproc>
    80004cd2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004cd4:	0d050793          	addi	a5,a0,208
    80004cd8:	4501                	li	a0,0
    80004cda:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004cdc:	6398                	ld	a4,0(a5)
    80004cde:	cb19                	beqz	a4,80004cf4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ce0:	2505                	addiw	a0,a0,1
    80004ce2:	07a1                	addi	a5,a5,8
    80004ce4:	fed51ce3          	bne	a0,a3,80004cdc <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ce8:	557d                	li	a0,-1
}
    80004cea:	60e2                	ld	ra,24(sp)
    80004cec:	6442                	ld	s0,16(sp)
    80004cee:	64a2                	ld	s1,8(sp)
    80004cf0:	6105                	addi	sp,sp,32
    80004cf2:	8082                	ret
      p->ofile[fd] = f;
    80004cf4:	01a50793          	addi	a5,a0,26
    80004cf8:	078e                	slli	a5,a5,0x3
    80004cfa:	963e                	add	a2,a2,a5
    80004cfc:	e204                	sd	s1,0(a2)
      return fd;
    80004cfe:	b7f5                	j	80004cea <fdalloc+0x28>

0000000080004d00 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d00:	715d                	addi	sp,sp,-80
    80004d02:	e486                	sd	ra,72(sp)
    80004d04:	e0a2                	sd	s0,64(sp)
    80004d06:	fc26                	sd	s1,56(sp)
    80004d08:	f84a                	sd	s2,48(sp)
    80004d0a:	f44e                	sd	s3,40(sp)
    80004d0c:	ec56                	sd	s5,24(sp)
    80004d0e:	e85a                	sd	s6,16(sp)
    80004d10:	0880                	addi	s0,sp,80
    80004d12:	8b2e                	mv	s6,a1
    80004d14:	89b2                	mv	s3,a2
    80004d16:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004d18:	fb040593          	addi	a1,s0,-80
    80004d1c:	80eff0ef          	jal	80003d2a <nameiparent>
    80004d20:	84aa                	mv	s1,a0
    80004d22:	10050a63          	beqz	a0,80004e36 <create+0x136>
    return 0;

  ilock(dp);
    80004d26:	fd4fe0ef          	jal	800034fa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d2a:	4601                	li	a2,0
    80004d2c:	fb040593          	addi	a1,s0,-80
    80004d30:	8526                	mv	a0,s1
    80004d32:	d79fe0ef          	jal	80003aaa <dirlookup>
    80004d36:	8aaa                	mv	s5,a0
    80004d38:	c129                	beqz	a0,80004d7a <create+0x7a>
    iunlockput(dp);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	9c9fe0ef          	jal	80003704 <iunlockput>
    ilock(ip);
    80004d40:	8556                	mv	a0,s5
    80004d42:	fb8fe0ef          	jal	800034fa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d46:	4789                	li	a5,2
    80004d48:	02fb1463          	bne	s6,a5,80004d70 <create+0x70>
    80004d4c:	044ad783          	lhu	a5,68(s5)
    80004d50:	37f9                	addiw	a5,a5,-2
    80004d52:	17c2                	slli	a5,a5,0x30
    80004d54:	93c1                	srli	a5,a5,0x30
    80004d56:	4705                	li	a4,1
    80004d58:	00f76c63          	bltu	a4,a5,80004d70 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d5c:	8556                	mv	a0,s5
    80004d5e:	60a6                	ld	ra,72(sp)
    80004d60:	6406                	ld	s0,64(sp)
    80004d62:	74e2                	ld	s1,56(sp)
    80004d64:	7942                	ld	s2,48(sp)
    80004d66:	79a2                	ld	s3,40(sp)
    80004d68:	6ae2                	ld	s5,24(sp)
    80004d6a:	6b42                	ld	s6,16(sp)
    80004d6c:	6161                	addi	sp,sp,80
    80004d6e:	8082                	ret
    iunlockput(ip);
    80004d70:	8556                	mv	a0,s5
    80004d72:	993fe0ef          	jal	80003704 <iunlockput>
    return 0;
    80004d76:	4a81                	li	s5,0
    80004d78:	b7d5                	j	80004d5c <create+0x5c>
    80004d7a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004d7c:	85da                	mv	a1,s6
    80004d7e:	4088                	lw	a0,0(s1)
    80004d80:	e0afe0ef          	jal	8000338a <ialloc>
    80004d84:	8a2a                	mv	s4,a0
    80004d86:	cd15                	beqz	a0,80004dc2 <create+0xc2>
  ilock(ip);
    80004d88:	f72fe0ef          	jal	800034fa <ilock>
  ip->major = major;
    80004d8c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004d90:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004d94:	4905                	li	s2,1
    80004d96:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004d9a:	8552                	mv	a0,s4
    80004d9c:	eaafe0ef          	jal	80003446 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004da0:	032b0763          	beq	s6,s2,80004dce <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004da4:	004a2603          	lw	a2,4(s4)
    80004da8:	fb040593          	addi	a1,s0,-80
    80004dac:	8526                	mv	a0,s1
    80004dae:	ec9fe0ef          	jal	80003c76 <dirlink>
    80004db2:	06054563          	bltz	a0,80004e1c <create+0x11c>
  iunlockput(dp);
    80004db6:	8526                	mv	a0,s1
    80004db8:	94dfe0ef          	jal	80003704 <iunlockput>
  return ip;
    80004dbc:	8ad2                	mv	s5,s4
    80004dbe:	7a02                	ld	s4,32(sp)
    80004dc0:	bf71                	j	80004d5c <create+0x5c>
    iunlockput(dp);
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	941fe0ef          	jal	80003704 <iunlockput>
    return 0;
    80004dc8:	8ad2                	mv	s5,s4
    80004dca:	7a02                	ld	s4,32(sp)
    80004dcc:	bf41                	j	80004d5c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004dce:	004a2603          	lw	a2,4(s4)
    80004dd2:	00002597          	auipc	a1,0x2
    80004dd6:	7f658593          	addi	a1,a1,2038 # 800075c8 <etext+0x5c8>
    80004dda:	8552                	mv	a0,s4
    80004ddc:	e9bfe0ef          	jal	80003c76 <dirlink>
    80004de0:	02054e63          	bltz	a0,80004e1c <create+0x11c>
    80004de4:	40d0                	lw	a2,4(s1)
    80004de6:	00002597          	auipc	a1,0x2
    80004dea:	7ea58593          	addi	a1,a1,2026 # 800075d0 <etext+0x5d0>
    80004dee:	8552                	mv	a0,s4
    80004df0:	e87fe0ef          	jal	80003c76 <dirlink>
    80004df4:	02054463          	bltz	a0,80004e1c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004df8:	004a2603          	lw	a2,4(s4)
    80004dfc:	fb040593          	addi	a1,s0,-80
    80004e00:	8526                	mv	a0,s1
    80004e02:	e75fe0ef          	jal	80003c76 <dirlink>
    80004e06:	00054b63          	bltz	a0,80004e1c <create+0x11c>
    dp->nlink++;  // for ".."
    80004e0a:	04a4d783          	lhu	a5,74(s1)
    80004e0e:	2785                	addiw	a5,a5,1
    80004e10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e14:	8526                	mv	a0,s1
    80004e16:	e30fe0ef          	jal	80003446 <iupdate>
    80004e1a:	bf71                	j	80004db6 <create+0xb6>
  ip->nlink = 0;
    80004e1c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004e20:	8552                	mv	a0,s4
    80004e22:	e24fe0ef          	jal	80003446 <iupdate>
  iunlockput(ip);
    80004e26:	8552                	mv	a0,s4
    80004e28:	8ddfe0ef          	jal	80003704 <iunlockput>
  iunlockput(dp);
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	8d7fe0ef          	jal	80003704 <iunlockput>
  return 0;
    80004e32:	7a02                	ld	s4,32(sp)
    80004e34:	b725                	j	80004d5c <create+0x5c>
    return 0;
    80004e36:	8aaa                	mv	s5,a0
    80004e38:	b715                	j	80004d5c <create+0x5c>

0000000080004e3a <sys_dup>:
{
    80004e3a:	7179                	addi	sp,sp,-48
    80004e3c:	f406                	sd	ra,40(sp)
    80004e3e:	f022                	sd	s0,32(sp)
    80004e40:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e42:	fd840613          	addi	a2,s0,-40
    80004e46:	4581                	li	a1,0
    80004e48:	4501                	li	a0,0
    80004e4a:	e21ff0ef          	jal	80004c6a <argfd>
    return -1;
    80004e4e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e50:	02054363          	bltz	a0,80004e76 <sys_dup+0x3c>
    80004e54:	ec26                	sd	s1,24(sp)
    80004e56:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e58:	fd843903          	ld	s2,-40(s0)
    80004e5c:	854a                	mv	a0,s2
    80004e5e:	e65ff0ef          	jal	80004cc2 <fdalloc>
    80004e62:	84aa                	mv	s1,a0
    return -1;
    80004e64:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e66:	00054d63          	bltz	a0,80004e80 <sys_dup+0x46>
  filedup(f);
    80004e6a:	854a                	mv	a0,s2
    80004e6c:	c3eff0ef          	jal	800042aa <filedup>
  return fd;
    80004e70:	87a6                	mv	a5,s1
    80004e72:	64e2                	ld	s1,24(sp)
    80004e74:	6942                	ld	s2,16(sp)
}
    80004e76:	853e                	mv	a0,a5
    80004e78:	70a2                	ld	ra,40(sp)
    80004e7a:	7402                	ld	s0,32(sp)
    80004e7c:	6145                	addi	sp,sp,48
    80004e7e:	8082                	ret
    80004e80:	64e2                	ld	s1,24(sp)
    80004e82:	6942                	ld	s2,16(sp)
    80004e84:	bfcd                	j	80004e76 <sys_dup+0x3c>

0000000080004e86 <sys_read>:
{
    80004e86:	7179                	addi	sp,sp,-48
    80004e88:	f406                	sd	ra,40(sp)
    80004e8a:	f022                	sd	s0,32(sp)
    80004e8c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e8e:	fd840593          	addi	a1,s0,-40
    80004e92:	4505                	li	a0,1
    80004e94:	c09fd0ef          	jal	80002a9c <argaddr>
  argint(2, &n);
    80004e98:	fe440593          	addi	a1,s0,-28
    80004e9c:	4509                	li	a0,2
    80004e9e:	be3fd0ef          	jal	80002a80 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ea2:	fe840613          	addi	a2,s0,-24
    80004ea6:	4581                	li	a1,0
    80004ea8:	4501                	li	a0,0
    80004eaa:	dc1ff0ef          	jal	80004c6a <argfd>
    80004eae:	87aa                	mv	a5,a0
    return -1;
    80004eb0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004eb2:	0007ca63          	bltz	a5,80004ec6 <sys_read+0x40>
  return fileread(f, p, n);
    80004eb6:	fe442603          	lw	a2,-28(s0)
    80004eba:	fd843583          	ld	a1,-40(s0)
    80004ebe:	fe843503          	ld	a0,-24(s0)
    80004ec2:	d4eff0ef          	jal	80004410 <fileread>
}
    80004ec6:	70a2                	ld	ra,40(sp)
    80004ec8:	7402                	ld	s0,32(sp)
    80004eca:	6145                	addi	sp,sp,48
    80004ecc:	8082                	ret

0000000080004ece <sys_write>:
{
    80004ece:	7179                	addi	sp,sp,-48
    80004ed0:	f406                	sd	ra,40(sp)
    80004ed2:	f022                	sd	s0,32(sp)
    80004ed4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ed6:	fd840593          	addi	a1,s0,-40
    80004eda:	4505                	li	a0,1
    80004edc:	bc1fd0ef          	jal	80002a9c <argaddr>
  argint(2, &n);
    80004ee0:	fe440593          	addi	a1,s0,-28
    80004ee4:	4509                	li	a0,2
    80004ee6:	b9bfd0ef          	jal	80002a80 <argint>
  if(argfd(0, 0, &f) < 0)
    80004eea:	fe840613          	addi	a2,s0,-24
    80004eee:	4581                	li	a1,0
    80004ef0:	4501                	li	a0,0
    80004ef2:	d79ff0ef          	jal	80004c6a <argfd>
    80004ef6:	87aa                	mv	a5,a0
    return -1;
    80004ef8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004efa:	0007ca63          	bltz	a5,80004f0e <sys_write+0x40>
  return filewrite(f, p, n);
    80004efe:	fe442603          	lw	a2,-28(s0)
    80004f02:	fd843583          	ld	a1,-40(s0)
    80004f06:	fe843503          	ld	a0,-24(s0)
    80004f0a:	dc4ff0ef          	jal	800044ce <filewrite>
}
    80004f0e:	70a2                	ld	ra,40(sp)
    80004f10:	7402                	ld	s0,32(sp)
    80004f12:	6145                	addi	sp,sp,48
    80004f14:	8082                	ret

0000000080004f16 <sys_close>:
{
    80004f16:	1101                	addi	sp,sp,-32
    80004f18:	ec06                	sd	ra,24(sp)
    80004f1a:	e822                	sd	s0,16(sp)
    80004f1c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004f1e:	fe040613          	addi	a2,s0,-32
    80004f22:	fec40593          	addi	a1,s0,-20
    80004f26:	4501                	li	a0,0
    80004f28:	d43ff0ef          	jal	80004c6a <argfd>
    return -1;
    80004f2c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f2e:	02054063          	bltz	a0,80004f4e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004f32:	a1ffc0ef          	jal	80001950 <myproc>
    80004f36:	fec42783          	lw	a5,-20(s0)
    80004f3a:	07e9                	addi	a5,a5,26
    80004f3c:	078e                	slli	a5,a5,0x3
    80004f3e:	953e                	add	a0,a0,a5
    80004f40:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f44:	fe043503          	ld	a0,-32(s0)
    80004f48:	ba8ff0ef          	jal	800042f0 <fileclose>
  return 0;
    80004f4c:	4781                	li	a5,0
}
    80004f4e:	853e                	mv	a0,a5
    80004f50:	60e2                	ld	ra,24(sp)
    80004f52:	6442                	ld	s0,16(sp)
    80004f54:	6105                	addi	sp,sp,32
    80004f56:	8082                	ret

0000000080004f58 <sys_fstat>:
{
    80004f58:	1101                	addi	sp,sp,-32
    80004f5a:	ec06                	sd	ra,24(sp)
    80004f5c:	e822                	sd	s0,16(sp)
    80004f5e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f60:	fe040593          	addi	a1,s0,-32
    80004f64:	4505                	li	a0,1
    80004f66:	b37fd0ef          	jal	80002a9c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f6a:	fe840613          	addi	a2,s0,-24
    80004f6e:	4581                	li	a1,0
    80004f70:	4501                	li	a0,0
    80004f72:	cf9ff0ef          	jal	80004c6a <argfd>
    80004f76:	87aa                	mv	a5,a0
    return -1;
    80004f78:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f7a:	0007c863          	bltz	a5,80004f8a <sys_fstat+0x32>
  return filestat(f, st);
    80004f7e:	fe043583          	ld	a1,-32(s0)
    80004f82:	fe843503          	ld	a0,-24(s0)
    80004f86:	c2cff0ef          	jal	800043b2 <filestat>
}
    80004f8a:	60e2                	ld	ra,24(sp)
    80004f8c:	6442                	ld	s0,16(sp)
    80004f8e:	6105                	addi	sp,sp,32
    80004f90:	8082                	ret

0000000080004f92 <sys_link>:
{
    80004f92:	7169                	addi	sp,sp,-304
    80004f94:	f606                	sd	ra,296(sp)
    80004f96:	f222                	sd	s0,288(sp)
    80004f98:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f9a:	08000613          	li	a2,128
    80004f9e:	ed040593          	addi	a1,s0,-304
    80004fa2:	4501                	li	a0,0
    80004fa4:	b15fd0ef          	jal	80002ab8 <argstr>
    return -1;
    80004fa8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004faa:	0c054e63          	bltz	a0,80005086 <sys_link+0xf4>
    80004fae:	08000613          	li	a2,128
    80004fb2:	f5040593          	addi	a1,s0,-176
    80004fb6:	4505                	li	a0,1
    80004fb8:	b01fd0ef          	jal	80002ab8 <argstr>
    return -1;
    80004fbc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fbe:	0c054463          	bltz	a0,80005086 <sys_link+0xf4>
    80004fc2:	ee26                	sd	s1,280(sp)
  begin_op();
    80004fc4:	f21fe0ef          	jal	80003ee4 <begin_op>
  if((ip = namei(old)) == 0){
    80004fc8:	ed040513          	addi	a0,s0,-304
    80004fcc:	d45fe0ef          	jal	80003d10 <namei>
    80004fd0:	84aa                	mv	s1,a0
    80004fd2:	c53d                	beqz	a0,80005040 <sys_link+0xae>
  ilock(ip);
    80004fd4:	d26fe0ef          	jal	800034fa <ilock>
  if(ip->type == T_DIR){
    80004fd8:	04449703          	lh	a4,68(s1)
    80004fdc:	4785                	li	a5,1
    80004fde:	06f70663          	beq	a4,a5,8000504a <sys_link+0xb8>
    80004fe2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004fe4:	04a4d783          	lhu	a5,74(s1)
    80004fe8:	2785                	addiw	a5,a5,1
    80004fea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fee:	8526                	mv	a0,s1
    80004ff0:	c56fe0ef          	jal	80003446 <iupdate>
  iunlock(ip);
    80004ff4:	8526                	mv	a0,s1
    80004ff6:	db2fe0ef          	jal	800035a8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ffa:	fd040593          	addi	a1,s0,-48
    80004ffe:	f5040513          	addi	a0,s0,-176
    80005002:	d29fe0ef          	jal	80003d2a <nameiparent>
    80005006:	892a                	mv	s2,a0
    80005008:	cd21                	beqz	a0,80005060 <sys_link+0xce>
  ilock(dp);
    8000500a:	cf0fe0ef          	jal	800034fa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000500e:	00092703          	lw	a4,0(s2)
    80005012:	409c                	lw	a5,0(s1)
    80005014:	04f71363          	bne	a4,a5,8000505a <sys_link+0xc8>
    80005018:	40d0                	lw	a2,4(s1)
    8000501a:	fd040593          	addi	a1,s0,-48
    8000501e:	854a                	mv	a0,s2
    80005020:	c57fe0ef          	jal	80003c76 <dirlink>
    80005024:	02054b63          	bltz	a0,8000505a <sys_link+0xc8>
  iunlockput(dp);
    80005028:	854a                	mv	a0,s2
    8000502a:	edafe0ef          	jal	80003704 <iunlockput>
  iput(ip);
    8000502e:	8526                	mv	a0,s1
    80005030:	e4cfe0ef          	jal	8000367c <iput>
  end_op();
    80005034:	f1bfe0ef          	jal	80003f4e <end_op>
  return 0;
    80005038:	4781                	li	a5,0
    8000503a:	64f2                	ld	s1,280(sp)
    8000503c:	6952                	ld	s2,272(sp)
    8000503e:	a0a1                	j	80005086 <sys_link+0xf4>
    end_op();
    80005040:	f0ffe0ef          	jal	80003f4e <end_op>
    return -1;
    80005044:	57fd                	li	a5,-1
    80005046:	64f2                	ld	s1,280(sp)
    80005048:	a83d                	j	80005086 <sys_link+0xf4>
    iunlockput(ip);
    8000504a:	8526                	mv	a0,s1
    8000504c:	eb8fe0ef          	jal	80003704 <iunlockput>
    end_op();
    80005050:	efffe0ef          	jal	80003f4e <end_op>
    return -1;
    80005054:	57fd                	li	a5,-1
    80005056:	64f2                	ld	s1,280(sp)
    80005058:	a03d                	j	80005086 <sys_link+0xf4>
    iunlockput(dp);
    8000505a:	854a                	mv	a0,s2
    8000505c:	ea8fe0ef          	jal	80003704 <iunlockput>
  ilock(ip);
    80005060:	8526                	mv	a0,s1
    80005062:	c98fe0ef          	jal	800034fa <ilock>
  ip->nlink--;
    80005066:	04a4d783          	lhu	a5,74(s1)
    8000506a:	37fd                	addiw	a5,a5,-1
    8000506c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005070:	8526                	mv	a0,s1
    80005072:	bd4fe0ef          	jal	80003446 <iupdate>
  iunlockput(ip);
    80005076:	8526                	mv	a0,s1
    80005078:	e8cfe0ef          	jal	80003704 <iunlockput>
  end_op();
    8000507c:	ed3fe0ef          	jal	80003f4e <end_op>
  return -1;
    80005080:	57fd                	li	a5,-1
    80005082:	64f2                	ld	s1,280(sp)
    80005084:	6952                	ld	s2,272(sp)
}
    80005086:	853e                	mv	a0,a5
    80005088:	70b2                	ld	ra,296(sp)
    8000508a:	7412                	ld	s0,288(sp)
    8000508c:	6155                	addi	sp,sp,304
    8000508e:	8082                	ret

0000000080005090 <sys_unlink>:
{
    80005090:	7151                	addi	sp,sp,-240
    80005092:	f586                	sd	ra,232(sp)
    80005094:	f1a2                	sd	s0,224(sp)
    80005096:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005098:	08000613          	li	a2,128
    8000509c:	f3040593          	addi	a1,s0,-208
    800050a0:	4501                	li	a0,0
    800050a2:	a17fd0ef          	jal	80002ab8 <argstr>
    800050a6:	16054063          	bltz	a0,80005206 <sys_unlink+0x176>
    800050aa:	eda6                	sd	s1,216(sp)
  begin_op();
    800050ac:	e39fe0ef          	jal	80003ee4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800050b0:	fb040593          	addi	a1,s0,-80
    800050b4:	f3040513          	addi	a0,s0,-208
    800050b8:	c73fe0ef          	jal	80003d2a <nameiparent>
    800050bc:	84aa                	mv	s1,a0
    800050be:	c945                	beqz	a0,8000516e <sys_unlink+0xde>
  ilock(dp);
    800050c0:	c3afe0ef          	jal	800034fa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800050c4:	00002597          	auipc	a1,0x2
    800050c8:	50458593          	addi	a1,a1,1284 # 800075c8 <etext+0x5c8>
    800050cc:	fb040513          	addi	a0,s0,-80
    800050d0:	9c5fe0ef          	jal	80003a94 <namecmp>
    800050d4:	10050e63          	beqz	a0,800051f0 <sys_unlink+0x160>
    800050d8:	00002597          	auipc	a1,0x2
    800050dc:	4f858593          	addi	a1,a1,1272 # 800075d0 <etext+0x5d0>
    800050e0:	fb040513          	addi	a0,s0,-80
    800050e4:	9b1fe0ef          	jal	80003a94 <namecmp>
    800050e8:	10050463          	beqz	a0,800051f0 <sys_unlink+0x160>
    800050ec:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800050ee:	f2c40613          	addi	a2,s0,-212
    800050f2:	fb040593          	addi	a1,s0,-80
    800050f6:	8526                	mv	a0,s1
    800050f8:	9b3fe0ef          	jal	80003aaa <dirlookup>
    800050fc:	892a                	mv	s2,a0
    800050fe:	0e050863          	beqz	a0,800051ee <sys_unlink+0x15e>
  ilock(ip);
    80005102:	bf8fe0ef          	jal	800034fa <ilock>
  if(ip->nlink < 1)
    80005106:	04a91783          	lh	a5,74(s2)
    8000510a:	06f05763          	blez	a5,80005178 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000510e:	04491703          	lh	a4,68(s2)
    80005112:	4785                	li	a5,1
    80005114:	06f70963          	beq	a4,a5,80005186 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005118:	4641                	li	a2,16
    8000511a:	4581                	li	a1,0
    8000511c:	fc040513          	addi	a0,s0,-64
    80005120:	b83fb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005124:	4741                	li	a4,16
    80005126:	f2c42683          	lw	a3,-212(s0)
    8000512a:	fc040613          	addi	a2,s0,-64
    8000512e:	4581                	li	a1,0
    80005130:	8526                	mv	a0,s1
    80005132:	855fe0ef          	jal	80003986 <writei>
    80005136:	47c1                	li	a5,16
    80005138:	08f51b63          	bne	a0,a5,800051ce <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000513c:	04491703          	lh	a4,68(s2)
    80005140:	4785                	li	a5,1
    80005142:	08f70d63          	beq	a4,a5,800051dc <sys_unlink+0x14c>
  iunlockput(dp);
    80005146:	8526                	mv	a0,s1
    80005148:	dbcfe0ef          	jal	80003704 <iunlockput>
  ip->nlink--;
    8000514c:	04a95783          	lhu	a5,74(s2)
    80005150:	37fd                	addiw	a5,a5,-1
    80005152:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005156:	854a                	mv	a0,s2
    80005158:	aeefe0ef          	jal	80003446 <iupdate>
  iunlockput(ip);
    8000515c:	854a                	mv	a0,s2
    8000515e:	da6fe0ef          	jal	80003704 <iunlockput>
  end_op();
    80005162:	dedfe0ef          	jal	80003f4e <end_op>
  return 0;
    80005166:	4501                	li	a0,0
    80005168:	64ee                	ld	s1,216(sp)
    8000516a:	694e                	ld	s2,208(sp)
    8000516c:	a849                	j	800051fe <sys_unlink+0x16e>
    end_op();
    8000516e:	de1fe0ef          	jal	80003f4e <end_op>
    return -1;
    80005172:	557d                	li	a0,-1
    80005174:	64ee                	ld	s1,216(sp)
    80005176:	a061                	j	800051fe <sys_unlink+0x16e>
    80005178:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000517a:	00002517          	auipc	a0,0x2
    8000517e:	45e50513          	addi	a0,a0,1118 # 800075d8 <etext+0x5d8>
    80005182:	e5efb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005186:	04c92703          	lw	a4,76(s2)
    8000518a:	02000793          	li	a5,32
    8000518e:	f8e7f5e3          	bgeu	a5,a4,80005118 <sys_unlink+0x88>
    80005192:	e5ce                	sd	s3,200(sp)
    80005194:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005198:	4741                	li	a4,16
    8000519a:	86ce                	mv	a3,s3
    8000519c:	f1840613          	addi	a2,s0,-232
    800051a0:	4581                	li	a1,0
    800051a2:	854a                	mv	a0,s2
    800051a4:	ee6fe0ef          	jal	8000388a <readi>
    800051a8:	47c1                	li	a5,16
    800051aa:	00f51c63          	bne	a0,a5,800051c2 <sys_unlink+0x132>
    if(de.inum != 0)
    800051ae:	f1845783          	lhu	a5,-232(s0)
    800051b2:	efa1                	bnez	a5,8000520a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051b4:	29c1                	addiw	s3,s3,16
    800051b6:	04c92783          	lw	a5,76(s2)
    800051ba:	fcf9efe3          	bltu	s3,a5,80005198 <sys_unlink+0x108>
    800051be:	69ae                	ld	s3,200(sp)
    800051c0:	bfa1                	j	80005118 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800051c2:	00002517          	auipc	a0,0x2
    800051c6:	42e50513          	addi	a0,a0,1070 # 800075f0 <etext+0x5f0>
    800051ca:	e16fb0ef          	jal	800007e0 <panic>
    800051ce:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800051d0:	00002517          	auipc	a0,0x2
    800051d4:	43850513          	addi	a0,a0,1080 # 80007608 <etext+0x608>
    800051d8:	e08fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    800051dc:	04a4d783          	lhu	a5,74(s1)
    800051e0:	37fd                	addiw	a5,a5,-1
    800051e2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051e6:	8526                	mv	a0,s1
    800051e8:	a5efe0ef          	jal	80003446 <iupdate>
    800051ec:	bfa9                	j	80005146 <sys_unlink+0xb6>
    800051ee:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800051f0:	8526                	mv	a0,s1
    800051f2:	d12fe0ef          	jal	80003704 <iunlockput>
  end_op();
    800051f6:	d59fe0ef          	jal	80003f4e <end_op>
  return -1;
    800051fa:	557d                	li	a0,-1
    800051fc:	64ee                	ld	s1,216(sp)
}
    800051fe:	70ae                	ld	ra,232(sp)
    80005200:	740e                	ld	s0,224(sp)
    80005202:	616d                	addi	sp,sp,240
    80005204:	8082                	ret
    return -1;
    80005206:	557d                	li	a0,-1
    80005208:	bfdd                	j	800051fe <sys_unlink+0x16e>
    iunlockput(ip);
    8000520a:	854a                	mv	a0,s2
    8000520c:	cf8fe0ef          	jal	80003704 <iunlockput>
    goto bad;
    80005210:	694e                	ld	s2,208(sp)
    80005212:	69ae                	ld	s3,200(sp)
    80005214:	bff1                	j	800051f0 <sys_unlink+0x160>

0000000080005216 <sys_open>:

uint64
sys_open(void)
{
    80005216:	7131                	addi	sp,sp,-192
    80005218:	fd06                	sd	ra,184(sp)
    8000521a:	f922                	sd	s0,176(sp)
    8000521c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000521e:	f4c40593          	addi	a1,s0,-180
    80005222:	4505                	li	a0,1
    80005224:	85dfd0ef          	jal	80002a80 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005228:	08000613          	li	a2,128
    8000522c:	f5040593          	addi	a1,s0,-176
    80005230:	4501                	li	a0,0
    80005232:	887fd0ef          	jal	80002ab8 <argstr>
    80005236:	87aa                	mv	a5,a0
    return -1;
    80005238:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000523a:	0a07c263          	bltz	a5,800052de <sys_open+0xc8>
    8000523e:	f526                	sd	s1,168(sp)

  begin_op();
    80005240:	ca5fe0ef          	jal	80003ee4 <begin_op>

  if(omode & O_CREATE){
    80005244:	f4c42783          	lw	a5,-180(s0)
    80005248:	2007f793          	andi	a5,a5,512
    8000524c:	c3d5                	beqz	a5,800052f0 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000524e:	4681                	li	a3,0
    80005250:	4601                	li	a2,0
    80005252:	4589                	li	a1,2
    80005254:	f5040513          	addi	a0,s0,-176
    80005258:	aa9ff0ef          	jal	80004d00 <create>
    8000525c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000525e:	c541                	beqz	a0,800052e6 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005260:	04449703          	lh	a4,68(s1)
    80005264:	478d                	li	a5,3
    80005266:	00f71763          	bne	a4,a5,80005274 <sys_open+0x5e>
    8000526a:	0464d703          	lhu	a4,70(s1)
    8000526e:	47a5                	li	a5,9
    80005270:	0ae7ed63          	bltu	a5,a4,8000532a <sys_open+0x114>
    80005274:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005276:	fd7fe0ef          	jal	8000424c <filealloc>
    8000527a:	892a                	mv	s2,a0
    8000527c:	c179                	beqz	a0,80005342 <sys_open+0x12c>
    8000527e:	ed4e                	sd	s3,152(sp)
    80005280:	a43ff0ef          	jal	80004cc2 <fdalloc>
    80005284:	89aa                	mv	s3,a0
    80005286:	0a054a63          	bltz	a0,8000533a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000528a:	04449703          	lh	a4,68(s1)
    8000528e:	478d                	li	a5,3
    80005290:	0cf70263          	beq	a4,a5,80005354 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005294:	4789                	li	a5,2
    80005296:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000529a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000529e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052a2:	f4c42783          	lw	a5,-180(s0)
    800052a6:	0017c713          	xori	a4,a5,1
    800052aa:	8b05                	andi	a4,a4,1
    800052ac:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800052b0:	0037f713          	andi	a4,a5,3
    800052b4:	00e03733          	snez	a4,a4
    800052b8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800052bc:	4007f793          	andi	a5,a5,1024
    800052c0:	c791                	beqz	a5,800052cc <sys_open+0xb6>
    800052c2:	04449703          	lh	a4,68(s1)
    800052c6:	4789                	li	a5,2
    800052c8:	08f70d63          	beq	a4,a5,80005362 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800052cc:	8526                	mv	a0,s1
    800052ce:	adafe0ef          	jal	800035a8 <iunlock>
  end_op();
    800052d2:	c7dfe0ef          	jal	80003f4e <end_op>

  return fd;
    800052d6:	854e                	mv	a0,s3
    800052d8:	74aa                	ld	s1,168(sp)
    800052da:	790a                	ld	s2,160(sp)
    800052dc:	69ea                	ld	s3,152(sp)
}
    800052de:	70ea                	ld	ra,184(sp)
    800052e0:	744a                	ld	s0,176(sp)
    800052e2:	6129                	addi	sp,sp,192
    800052e4:	8082                	ret
      end_op();
    800052e6:	c69fe0ef          	jal	80003f4e <end_op>
      return -1;
    800052ea:	557d                	li	a0,-1
    800052ec:	74aa                	ld	s1,168(sp)
    800052ee:	bfc5                	j	800052de <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800052f0:	f5040513          	addi	a0,s0,-176
    800052f4:	a1dfe0ef          	jal	80003d10 <namei>
    800052f8:	84aa                	mv	s1,a0
    800052fa:	c11d                	beqz	a0,80005320 <sys_open+0x10a>
    ilock(ip);
    800052fc:	9fefe0ef          	jal	800034fa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005300:	04449703          	lh	a4,68(s1)
    80005304:	4785                	li	a5,1
    80005306:	f4f71de3          	bne	a4,a5,80005260 <sys_open+0x4a>
    8000530a:	f4c42783          	lw	a5,-180(s0)
    8000530e:	d3bd                	beqz	a5,80005274 <sys_open+0x5e>
      iunlockput(ip);
    80005310:	8526                	mv	a0,s1
    80005312:	bf2fe0ef          	jal	80003704 <iunlockput>
      end_op();
    80005316:	c39fe0ef          	jal	80003f4e <end_op>
      return -1;
    8000531a:	557d                	li	a0,-1
    8000531c:	74aa                	ld	s1,168(sp)
    8000531e:	b7c1                	j	800052de <sys_open+0xc8>
      end_op();
    80005320:	c2ffe0ef          	jal	80003f4e <end_op>
      return -1;
    80005324:	557d                	li	a0,-1
    80005326:	74aa                	ld	s1,168(sp)
    80005328:	bf5d                	j	800052de <sys_open+0xc8>
    iunlockput(ip);
    8000532a:	8526                	mv	a0,s1
    8000532c:	bd8fe0ef          	jal	80003704 <iunlockput>
    end_op();
    80005330:	c1ffe0ef          	jal	80003f4e <end_op>
    return -1;
    80005334:	557d                	li	a0,-1
    80005336:	74aa                	ld	s1,168(sp)
    80005338:	b75d                	j	800052de <sys_open+0xc8>
      fileclose(f);
    8000533a:	854a                	mv	a0,s2
    8000533c:	fb5fe0ef          	jal	800042f0 <fileclose>
    80005340:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005342:	8526                	mv	a0,s1
    80005344:	bc0fe0ef          	jal	80003704 <iunlockput>
    end_op();
    80005348:	c07fe0ef          	jal	80003f4e <end_op>
    return -1;
    8000534c:	557d                	li	a0,-1
    8000534e:	74aa                	ld	s1,168(sp)
    80005350:	790a                	ld	s2,160(sp)
    80005352:	b771                	j	800052de <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005354:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005358:	04649783          	lh	a5,70(s1)
    8000535c:	02f91223          	sh	a5,36(s2)
    80005360:	bf3d                	j	8000529e <sys_open+0x88>
    itrunc(ip);
    80005362:	8526                	mv	a0,s1
    80005364:	a84fe0ef          	jal	800035e8 <itrunc>
    80005368:	b795                	j	800052cc <sys_open+0xb6>

000000008000536a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000536a:	7175                	addi	sp,sp,-144
    8000536c:	e506                	sd	ra,136(sp)
    8000536e:	e122                	sd	s0,128(sp)
    80005370:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005372:	b73fe0ef          	jal	80003ee4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005376:	08000613          	li	a2,128
    8000537a:	f7040593          	addi	a1,s0,-144
    8000537e:	4501                	li	a0,0
    80005380:	f38fd0ef          	jal	80002ab8 <argstr>
    80005384:	02054363          	bltz	a0,800053aa <sys_mkdir+0x40>
    80005388:	4681                	li	a3,0
    8000538a:	4601                	li	a2,0
    8000538c:	4585                	li	a1,1
    8000538e:	f7040513          	addi	a0,s0,-144
    80005392:	96fff0ef          	jal	80004d00 <create>
    80005396:	c911                	beqz	a0,800053aa <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005398:	b6cfe0ef          	jal	80003704 <iunlockput>
  end_op();
    8000539c:	bb3fe0ef          	jal	80003f4e <end_op>
  return 0;
    800053a0:	4501                	li	a0,0
}
    800053a2:	60aa                	ld	ra,136(sp)
    800053a4:	640a                	ld	s0,128(sp)
    800053a6:	6149                	addi	sp,sp,144
    800053a8:	8082                	ret
    end_op();
    800053aa:	ba5fe0ef          	jal	80003f4e <end_op>
    return -1;
    800053ae:	557d                	li	a0,-1
    800053b0:	bfcd                	j	800053a2 <sys_mkdir+0x38>

00000000800053b2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800053b2:	7135                	addi	sp,sp,-160
    800053b4:	ed06                	sd	ra,152(sp)
    800053b6:	e922                	sd	s0,144(sp)
    800053b8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800053ba:	b2bfe0ef          	jal	80003ee4 <begin_op>
  argint(1, &major);
    800053be:	f6c40593          	addi	a1,s0,-148
    800053c2:	4505                	li	a0,1
    800053c4:	ebcfd0ef          	jal	80002a80 <argint>
  argint(2, &minor);
    800053c8:	f6840593          	addi	a1,s0,-152
    800053cc:	4509                	li	a0,2
    800053ce:	eb2fd0ef          	jal	80002a80 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053d2:	08000613          	li	a2,128
    800053d6:	f7040593          	addi	a1,s0,-144
    800053da:	4501                	li	a0,0
    800053dc:	edcfd0ef          	jal	80002ab8 <argstr>
    800053e0:	02054563          	bltz	a0,8000540a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800053e4:	f6841683          	lh	a3,-152(s0)
    800053e8:	f6c41603          	lh	a2,-148(s0)
    800053ec:	458d                	li	a1,3
    800053ee:	f7040513          	addi	a0,s0,-144
    800053f2:	90fff0ef          	jal	80004d00 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053f6:	c911                	beqz	a0,8000540a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053f8:	b0cfe0ef          	jal	80003704 <iunlockput>
  end_op();
    800053fc:	b53fe0ef          	jal	80003f4e <end_op>
  return 0;
    80005400:	4501                	li	a0,0
}
    80005402:	60ea                	ld	ra,152(sp)
    80005404:	644a                	ld	s0,144(sp)
    80005406:	610d                	addi	sp,sp,160
    80005408:	8082                	ret
    end_op();
    8000540a:	b45fe0ef          	jal	80003f4e <end_op>
    return -1;
    8000540e:	557d                	li	a0,-1
    80005410:	bfcd                	j	80005402 <sys_mknod+0x50>

0000000080005412 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005412:	7135                	addi	sp,sp,-160
    80005414:	ed06                	sd	ra,152(sp)
    80005416:	e922                	sd	s0,144(sp)
    80005418:	e14a                	sd	s2,128(sp)
    8000541a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000541c:	d34fc0ef          	jal	80001950 <myproc>
    80005420:	892a                	mv	s2,a0
  
  begin_op();
    80005422:	ac3fe0ef          	jal	80003ee4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005426:	08000613          	li	a2,128
    8000542a:	f6040593          	addi	a1,s0,-160
    8000542e:	4501                	li	a0,0
    80005430:	e88fd0ef          	jal	80002ab8 <argstr>
    80005434:	04054363          	bltz	a0,8000547a <sys_chdir+0x68>
    80005438:	e526                	sd	s1,136(sp)
    8000543a:	f6040513          	addi	a0,s0,-160
    8000543e:	8d3fe0ef          	jal	80003d10 <namei>
    80005442:	84aa                	mv	s1,a0
    80005444:	c915                	beqz	a0,80005478 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005446:	8b4fe0ef          	jal	800034fa <ilock>
  if(ip->type != T_DIR){
    8000544a:	04449703          	lh	a4,68(s1)
    8000544e:	4785                	li	a5,1
    80005450:	02f71963          	bne	a4,a5,80005482 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005454:	8526                	mv	a0,s1
    80005456:	952fe0ef          	jal	800035a8 <iunlock>
  iput(p->cwd);
    8000545a:	15093503          	ld	a0,336(s2)
    8000545e:	a1efe0ef          	jal	8000367c <iput>
  end_op();
    80005462:	aedfe0ef          	jal	80003f4e <end_op>
  p->cwd = ip;
    80005466:	14993823          	sd	s1,336(s2)
  return 0;
    8000546a:	4501                	li	a0,0
    8000546c:	64aa                	ld	s1,136(sp)
}
    8000546e:	60ea                	ld	ra,152(sp)
    80005470:	644a                	ld	s0,144(sp)
    80005472:	690a                	ld	s2,128(sp)
    80005474:	610d                	addi	sp,sp,160
    80005476:	8082                	ret
    80005478:	64aa                	ld	s1,136(sp)
    end_op();
    8000547a:	ad5fe0ef          	jal	80003f4e <end_op>
    return -1;
    8000547e:	557d                	li	a0,-1
    80005480:	b7fd                	j	8000546e <sys_chdir+0x5c>
    iunlockput(ip);
    80005482:	8526                	mv	a0,s1
    80005484:	a80fe0ef          	jal	80003704 <iunlockput>
    end_op();
    80005488:	ac7fe0ef          	jal	80003f4e <end_op>
    return -1;
    8000548c:	557d                	li	a0,-1
    8000548e:	64aa                	ld	s1,136(sp)
    80005490:	bff9                	j	8000546e <sys_chdir+0x5c>

0000000080005492 <sys_exec>:

uint64
sys_exec(void)
{
    80005492:	7121                	addi	sp,sp,-448
    80005494:	ff06                	sd	ra,440(sp)
    80005496:	fb22                	sd	s0,432(sp)
    80005498:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000549a:	e4840593          	addi	a1,s0,-440
    8000549e:	4505                	li	a0,1
    800054a0:	dfcfd0ef          	jal	80002a9c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800054a4:	08000613          	li	a2,128
    800054a8:	f5040593          	addi	a1,s0,-176
    800054ac:	4501                	li	a0,0
    800054ae:	e0afd0ef          	jal	80002ab8 <argstr>
    800054b2:	87aa                	mv	a5,a0
    return -1;
    800054b4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800054b6:	0c07c463          	bltz	a5,8000557e <sys_exec+0xec>
    800054ba:	f726                	sd	s1,424(sp)
    800054bc:	f34a                	sd	s2,416(sp)
    800054be:	ef4e                	sd	s3,408(sp)
    800054c0:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800054c2:	10000613          	li	a2,256
    800054c6:	4581                	li	a1,0
    800054c8:	e5040513          	addi	a0,s0,-432
    800054cc:	fd6fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800054d0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800054d4:	89a6                	mv	s3,s1
    800054d6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800054d8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800054dc:	00391513          	slli	a0,s2,0x3
    800054e0:	e4040593          	addi	a1,s0,-448
    800054e4:	e4843783          	ld	a5,-440(s0)
    800054e8:	953e                	add	a0,a0,a5
    800054ea:	d0cfd0ef          	jal	800029f6 <fetchaddr>
    800054ee:	02054663          	bltz	a0,8000551a <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800054f2:	e4043783          	ld	a5,-448(s0)
    800054f6:	c3a9                	beqz	a5,80005538 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800054f8:	e06fb0ef          	jal	80000afe <kalloc>
    800054fc:	85aa                	mv	a1,a0
    800054fe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005502:	cd01                	beqz	a0,8000551a <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005504:	6605                	lui	a2,0x1
    80005506:	e4043503          	ld	a0,-448(s0)
    8000550a:	d36fd0ef          	jal	80002a40 <fetchstr>
    8000550e:	00054663          	bltz	a0,8000551a <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005512:	0905                	addi	s2,s2,1
    80005514:	09a1                	addi	s3,s3,8
    80005516:	fd4913e3          	bne	s2,s4,800054dc <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000551a:	f5040913          	addi	s2,s0,-176
    8000551e:	6088                	ld	a0,0(s1)
    80005520:	c931                	beqz	a0,80005574 <sys_exec+0xe2>
    kfree(argv[i]);
    80005522:	cfafb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005526:	04a1                	addi	s1,s1,8
    80005528:	ff249be3          	bne	s1,s2,8000551e <sys_exec+0x8c>
  return -1;
    8000552c:	557d                	li	a0,-1
    8000552e:	74ba                	ld	s1,424(sp)
    80005530:	791a                	ld	s2,416(sp)
    80005532:	69fa                	ld	s3,408(sp)
    80005534:	6a5a                	ld	s4,400(sp)
    80005536:	a0a1                	j	8000557e <sys_exec+0xec>
      argv[i] = 0;
    80005538:	0009079b          	sext.w	a5,s2
    8000553c:	078e                	slli	a5,a5,0x3
    8000553e:	fd078793          	addi	a5,a5,-48
    80005542:	97a2                	add	a5,a5,s0
    80005544:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005548:	e5040593          	addi	a1,s0,-432
    8000554c:	f5040513          	addi	a0,s0,-176
    80005550:	ba8ff0ef          	jal	800048f8 <kexec>
    80005554:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005556:	f5040993          	addi	s3,s0,-176
    8000555a:	6088                	ld	a0,0(s1)
    8000555c:	c511                	beqz	a0,80005568 <sys_exec+0xd6>
    kfree(argv[i]);
    8000555e:	cbefb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005562:	04a1                	addi	s1,s1,8
    80005564:	ff349be3          	bne	s1,s3,8000555a <sys_exec+0xc8>
  return ret;
    80005568:	854a                	mv	a0,s2
    8000556a:	74ba                	ld	s1,424(sp)
    8000556c:	791a                	ld	s2,416(sp)
    8000556e:	69fa                	ld	s3,408(sp)
    80005570:	6a5a                	ld	s4,400(sp)
    80005572:	a031                	j	8000557e <sys_exec+0xec>
  return -1;
    80005574:	557d                	li	a0,-1
    80005576:	74ba                	ld	s1,424(sp)
    80005578:	791a                	ld	s2,416(sp)
    8000557a:	69fa                	ld	s3,408(sp)
    8000557c:	6a5a                	ld	s4,400(sp)
}
    8000557e:	70fa                	ld	ra,440(sp)
    80005580:	745a                	ld	s0,432(sp)
    80005582:	6139                	addi	sp,sp,448
    80005584:	8082                	ret

0000000080005586 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005586:	7139                	addi	sp,sp,-64
    80005588:	fc06                	sd	ra,56(sp)
    8000558a:	f822                	sd	s0,48(sp)
    8000558c:	f426                	sd	s1,40(sp)
    8000558e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005590:	bc0fc0ef          	jal	80001950 <myproc>
    80005594:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005596:	fd840593          	addi	a1,s0,-40
    8000559a:	4501                	li	a0,0
    8000559c:	d00fd0ef          	jal	80002a9c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800055a0:	fc840593          	addi	a1,s0,-56
    800055a4:	fd040513          	addi	a0,s0,-48
    800055a8:	852ff0ef          	jal	800045fa <pipealloc>
    return -1;
    800055ac:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800055ae:	0a054463          	bltz	a0,80005656 <sys_pipe+0xd0>
  fd0 = -1;
    800055b2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800055b6:	fd043503          	ld	a0,-48(s0)
    800055ba:	f08ff0ef          	jal	80004cc2 <fdalloc>
    800055be:	fca42223          	sw	a0,-60(s0)
    800055c2:	08054163          	bltz	a0,80005644 <sys_pipe+0xbe>
    800055c6:	fc843503          	ld	a0,-56(s0)
    800055ca:	ef8ff0ef          	jal	80004cc2 <fdalloc>
    800055ce:	fca42023          	sw	a0,-64(s0)
    800055d2:	06054063          	bltz	a0,80005632 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800055d6:	4691                	li	a3,4
    800055d8:	fc440613          	addi	a2,s0,-60
    800055dc:	fd843583          	ld	a1,-40(s0)
    800055e0:	68a8                	ld	a0,80(s1)
    800055e2:	800fc0ef          	jal	800015e2 <copyout>
    800055e6:	00054e63          	bltz	a0,80005602 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800055ea:	4691                	li	a3,4
    800055ec:	fc040613          	addi	a2,s0,-64
    800055f0:	fd843583          	ld	a1,-40(s0)
    800055f4:	0591                	addi	a1,a1,4
    800055f6:	68a8                	ld	a0,80(s1)
    800055f8:	febfb0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055fc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800055fe:	04055c63          	bgez	a0,80005656 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005602:	fc442783          	lw	a5,-60(s0)
    80005606:	07e9                	addi	a5,a5,26
    80005608:	078e                	slli	a5,a5,0x3
    8000560a:	97a6                	add	a5,a5,s1
    8000560c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005610:	fc042783          	lw	a5,-64(s0)
    80005614:	07e9                	addi	a5,a5,26
    80005616:	078e                	slli	a5,a5,0x3
    80005618:	94be                	add	s1,s1,a5
    8000561a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000561e:	fd043503          	ld	a0,-48(s0)
    80005622:	ccffe0ef          	jal	800042f0 <fileclose>
    fileclose(wf);
    80005626:	fc843503          	ld	a0,-56(s0)
    8000562a:	cc7fe0ef          	jal	800042f0 <fileclose>
    return -1;
    8000562e:	57fd                	li	a5,-1
    80005630:	a01d                	j	80005656 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005632:	fc442783          	lw	a5,-60(s0)
    80005636:	0007c763          	bltz	a5,80005644 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000563a:	07e9                	addi	a5,a5,26
    8000563c:	078e                	slli	a5,a5,0x3
    8000563e:	97a6                	add	a5,a5,s1
    80005640:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005644:	fd043503          	ld	a0,-48(s0)
    80005648:	ca9fe0ef          	jal	800042f0 <fileclose>
    fileclose(wf);
    8000564c:	fc843503          	ld	a0,-56(s0)
    80005650:	ca1fe0ef          	jal	800042f0 <fileclose>
    return -1;
    80005654:	57fd                	li	a5,-1
}
    80005656:	853e                	mv	a0,a5
    80005658:	70e2                	ld	ra,56(sp)
    8000565a:	7442                	ld	s0,48(sp)
    8000565c:	74a2                	ld	s1,40(sp)
    8000565e:	6121                	addi	sp,sp,64
    80005660:	8082                	ret
	...

0000000080005670 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005670:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005672:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005674:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005676:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005678:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000567a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000567c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000567e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005680:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005682:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005684:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005686:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005688:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000568a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000568c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000568e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005690:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005692:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005694:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005696:	a70fd0ef          	jal	80002906 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000569a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000569c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000569e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800056a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800056a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800056a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800056a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800056a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800056aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800056ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800056ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800056b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800056b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800056b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800056b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800056b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800056ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800056bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800056be:	10200073          	sret
	...

00000000800056ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800056ce:	1141                	addi	sp,sp,-16
    800056d0:	e422                	sd	s0,8(sp)
    800056d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800056d4:	0c0007b7          	lui	a5,0xc000
    800056d8:	4705                	li	a4,1
    800056da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800056dc:	0c0007b7          	lui	a5,0xc000
    800056e0:	c3d8                	sw	a4,4(a5)
}
    800056e2:	6422                	ld	s0,8(sp)
    800056e4:	0141                	addi	sp,sp,16
    800056e6:	8082                	ret

00000000800056e8 <plicinithart>:

void
plicinithart(void)
{
    800056e8:	1141                	addi	sp,sp,-16
    800056ea:	e406                	sd	ra,8(sp)
    800056ec:	e022                	sd	s0,0(sp)
    800056ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056f0:	a34fc0ef          	jal	80001924 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800056f4:	0085171b          	slliw	a4,a0,0x8
    800056f8:	0c0027b7          	lui	a5,0xc002
    800056fc:	97ba                	add	a5,a5,a4
    800056fe:	40200713          	li	a4,1026
    80005702:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005706:	00d5151b          	slliw	a0,a0,0xd
    8000570a:	0c2017b7          	lui	a5,0xc201
    8000570e:	97aa                	add	a5,a5,a0
    80005710:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005714:	60a2                	ld	ra,8(sp)
    80005716:	6402                	ld	s0,0(sp)
    80005718:	0141                	addi	sp,sp,16
    8000571a:	8082                	ret

000000008000571c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000571c:	1141                	addi	sp,sp,-16
    8000571e:	e406                	sd	ra,8(sp)
    80005720:	e022                	sd	s0,0(sp)
    80005722:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005724:	a00fc0ef          	jal	80001924 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005728:	00d5151b          	slliw	a0,a0,0xd
    8000572c:	0c2017b7          	lui	a5,0xc201
    80005730:	97aa                	add	a5,a5,a0
  return irq;
}
    80005732:	43c8                	lw	a0,4(a5)
    80005734:	60a2                	ld	ra,8(sp)
    80005736:	6402                	ld	s0,0(sp)
    80005738:	0141                	addi	sp,sp,16
    8000573a:	8082                	ret

000000008000573c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000573c:	1101                	addi	sp,sp,-32
    8000573e:	ec06                	sd	ra,24(sp)
    80005740:	e822                	sd	s0,16(sp)
    80005742:	e426                	sd	s1,8(sp)
    80005744:	1000                	addi	s0,sp,32
    80005746:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005748:	9dcfc0ef          	jal	80001924 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000574c:	00d5151b          	slliw	a0,a0,0xd
    80005750:	0c2017b7          	lui	a5,0xc201
    80005754:	97aa                	add	a5,a5,a0
    80005756:	c3c4                	sw	s1,4(a5)
}
    80005758:	60e2                	ld	ra,24(sp)
    8000575a:	6442                	ld	s0,16(sp)
    8000575c:	64a2                	ld	s1,8(sp)
    8000575e:	6105                	addi	sp,sp,32
    80005760:	8082                	ret

0000000080005762 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005762:	1141                	addi	sp,sp,-16
    80005764:	e406                	sd	ra,8(sp)
    80005766:	e022                	sd	s0,0(sp)
    80005768:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000576a:	479d                	li	a5,7
    8000576c:	04a7ca63          	blt	a5,a0,800057c0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005770:	0001e797          	auipc	a5,0x1e
    80005774:	16078793          	addi	a5,a5,352 # 800238d0 <disk>
    80005778:	97aa                	add	a5,a5,a0
    8000577a:	0187c783          	lbu	a5,24(a5)
    8000577e:	e7b9                	bnez	a5,800057cc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005780:	00451693          	slli	a3,a0,0x4
    80005784:	0001e797          	auipc	a5,0x1e
    80005788:	14c78793          	addi	a5,a5,332 # 800238d0 <disk>
    8000578c:	6398                	ld	a4,0(a5)
    8000578e:	9736                	add	a4,a4,a3
    80005790:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005794:	6398                	ld	a4,0(a5)
    80005796:	9736                	add	a4,a4,a3
    80005798:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000579c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057a0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057a4:	97aa                	add	a5,a5,a0
    800057a6:	4705                	li	a4,1
    800057a8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057ac:	0001e517          	auipc	a0,0x1e
    800057b0:	13c50513          	addi	a0,a0,316 # 800238e8 <disk+0x18>
    800057b4:	9a7fc0ef          	jal	8000215a <wakeup>
}
    800057b8:	60a2                	ld	ra,8(sp)
    800057ba:	6402                	ld	s0,0(sp)
    800057bc:	0141                	addi	sp,sp,16
    800057be:	8082                	ret
    panic("free_desc 1");
    800057c0:	00002517          	auipc	a0,0x2
    800057c4:	e5850513          	addi	a0,a0,-424 # 80007618 <etext+0x618>
    800057c8:	818fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    800057cc:	00002517          	auipc	a0,0x2
    800057d0:	e5c50513          	addi	a0,a0,-420 # 80007628 <etext+0x628>
    800057d4:	80cfb0ef          	jal	800007e0 <panic>

00000000800057d8 <virtio_disk_init>:
{
    800057d8:	1101                	addi	sp,sp,-32
    800057da:	ec06                	sd	ra,24(sp)
    800057dc:	e822                	sd	s0,16(sp)
    800057de:	e426                	sd	s1,8(sp)
    800057e0:	e04a                	sd	s2,0(sp)
    800057e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800057e4:	00002597          	auipc	a1,0x2
    800057e8:	e5458593          	addi	a1,a1,-428 # 80007638 <etext+0x638>
    800057ec:	0001e517          	auipc	a0,0x1e
    800057f0:	20c50513          	addi	a0,a0,524 # 800239f8 <disk+0x128>
    800057f4:	b5afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057f8:	100017b7          	lui	a5,0x10001
    800057fc:	4398                	lw	a4,0(a5)
    800057fe:	2701                	sext.w	a4,a4
    80005800:	747277b7          	lui	a5,0x74727
    80005804:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005808:	18f71063          	bne	a4,a5,80005988 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000580c:	100017b7          	lui	a5,0x10001
    80005810:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005812:	439c                	lw	a5,0(a5)
    80005814:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005816:	4709                	li	a4,2
    80005818:	16e79863          	bne	a5,a4,80005988 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000581c:	100017b7          	lui	a5,0x10001
    80005820:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005822:	439c                	lw	a5,0(a5)
    80005824:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005826:	16e79163          	bne	a5,a4,80005988 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000582a:	100017b7          	lui	a5,0x10001
    8000582e:	47d8                	lw	a4,12(a5)
    80005830:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005832:	554d47b7          	lui	a5,0x554d4
    80005836:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000583a:	14f71763          	bne	a4,a5,80005988 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000583e:	100017b7          	lui	a5,0x10001
    80005842:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005846:	4705                	li	a4,1
    80005848:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000584a:	470d                	li	a4,3
    8000584c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000584e:	10001737          	lui	a4,0x10001
    80005852:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005854:	c7ffe737          	lui	a4,0xc7ffe
    80005858:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad4f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000585c:	8ef9                	and	a3,a3,a4
    8000585e:	10001737          	lui	a4,0x10001
    80005862:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005864:	472d                	li	a4,11
    80005866:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005868:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000586c:	439c                	lw	a5,0(a5)
    8000586e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005872:	8ba1                	andi	a5,a5,8
    80005874:	12078063          	beqz	a5,80005994 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005878:	100017b7          	lui	a5,0x10001
    8000587c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005880:	100017b7          	lui	a5,0x10001
    80005884:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005888:	439c                	lw	a5,0(a5)
    8000588a:	2781                	sext.w	a5,a5
    8000588c:	10079a63          	bnez	a5,800059a0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005890:	100017b7          	lui	a5,0x10001
    80005894:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005898:	439c                	lw	a5,0(a5)
    8000589a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000589c:	10078863          	beqz	a5,800059ac <virtio_disk_init+0x1d4>
  if(max < NUM)
    800058a0:	471d                	li	a4,7
    800058a2:	10f77b63          	bgeu	a4,a5,800059b8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800058a6:	a58fb0ef          	jal	80000afe <kalloc>
    800058aa:	0001e497          	auipc	s1,0x1e
    800058ae:	02648493          	addi	s1,s1,38 # 800238d0 <disk>
    800058b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800058b4:	a4afb0ef          	jal	80000afe <kalloc>
    800058b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800058ba:	a44fb0ef          	jal	80000afe <kalloc>
    800058be:	87aa                	mv	a5,a0
    800058c0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800058c2:	6088                	ld	a0,0(s1)
    800058c4:	10050063          	beqz	a0,800059c4 <virtio_disk_init+0x1ec>
    800058c8:	0001e717          	auipc	a4,0x1e
    800058cc:	01073703          	ld	a4,16(a4) # 800238d8 <disk+0x8>
    800058d0:	0e070a63          	beqz	a4,800059c4 <virtio_disk_init+0x1ec>
    800058d4:	0e078863          	beqz	a5,800059c4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800058d8:	6605                	lui	a2,0x1
    800058da:	4581                	li	a1,0
    800058dc:	bc6fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800058e0:	0001e497          	auipc	s1,0x1e
    800058e4:	ff048493          	addi	s1,s1,-16 # 800238d0 <disk>
    800058e8:	6605                	lui	a2,0x1
    800058ea:	4581                	li	a1,0
    800058ec:	6488                	ld	a0,8(s1)
    800058ee:	bb4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800058f2:	6605                	lui	a2,0x1
    800058f4:	4581                	li	a1,0
    800058f6:	6888                	ld	a0,16(s1)
    800058f8:	baafb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800058fc:	100017b7          	lui	a5,0x10001
    80005900:	4721                	li	a4,8
    80005902:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005904:	4098                	lw	a4,0(s1)
    80005906:	100017b7          	lui	a5,0x10001
    8000590a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000590e:	40d8                	lw	a4,4(s1)
    80005910:	100017b7          	lui	a5,0x10001
    80005914:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005918:	649c                	ld	a5,8(s1)
    8000591a:	0007869b          	sext.w	a3,a5
    8000591e:	10001737          	lui	a4,0x10001
    80005922:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005926:	9781                	srai	a5,a5,0x20
    80005928:	10001737          	lui	a4,0x10001
    8000592c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005930:	689c                	ld	a5,16(s1)
    80005932:	0007869b          	sext.w	a3,a5
    80005936:	10001737          	lui	a4,0x10001
    8000593a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000593e:	9781                	srai	a5,a5,0x20
    80005940:	10001737          	lui	a4,0x10001
    80005944:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005948:	10001737          	lui	a4,0x10001
    8000594c:	4785                	li	a5,1
    8000594e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005950:	00f48c23          	sb	a5,24(s1)
    80005954:	00f48ca3          	sb	a5,25(s1)
    80005958:	00f48d23          	sb	a5,26(s1)
    8000595c:	00f48da3          	sb	a5,27(s1)
    80005960:	00f48e23          	sb	a5,28(s1)
    80005964:	00f48ea3          	sb	a5,29(s1)
    80005968:	00f48f23          	sb	a5,30(s1)
    8000596c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005970:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005974:	100017b7          	lui	a5,0x10001
    80005978:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000597c:	60e2                	ld	ra,24(sp)
    8000597e:	6442                	ld	s0,16(sp)
    80005980:	64a2                	ld	s1,8(sp)
    80005982:	6902                	ld	s2,0(sp)
    80005984:	6105                	addi	sp,sp,32
    80005986:	8082                	ret
    panic("could not find virtio disk");
    80005988:	00002517          	auipc	a0,0x2
    8000598c:	cc050513          	addi	a0,a0,-832 # 80007648 <etext+0x648>
    80005990:	e51fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005994:	00002517          	auipc	a0,0x2
    80005998:	cd450513          	addi	a0,a0,-812 # 80007668 <etext+0x668>
    8000599c:	e45fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    800059a0:	00002517          	auipc	a0,0x2
    800059a4:	ce850513          	addi	a0,a0,-792 # 80007688 <etext+0x688>
    800059a8:	e39fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    800059ac:	00002517          	auipc	a0,0x2
    800059b0:	cfc50513          	addi	a0,a0,-772 # 800076a8 <etext+0x6a8>
    800059b4:	e2dfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800059b8:	00002517          	auipc	a0,0x2
    800059bc:	d1050513          	addi	a0,a0,-752 # 800076c8 <etext+0x6c8>
    800059c0:	e21fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800059c4:	00002517          	auipc	a0,0x2
    800059c8:	d2450513          	addi	a0,a0,-732 # 800076e8 <etext+0x6e8>
    800059cc:	e15fa0ef          	jal	800007e0 <panic>

00000000800059d0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800059d0:	7159                	addi	sp,sp,-112
    800059d2:	f486                	sd	ra,104(sp)
    800059d4:	f0a2                	sd	s0,96(sp)
    800059d6:	eca6                	sd	s1,88(sp)
    800059d8:	e8ca                	sd	s2,80(sp)
    800059da:	e4ce                	sd	s3,72(sp)
    800059dc:	e0d2                	sd	s4,64(sp)
    800059de:	fc56                	sd	s5,56(sp)
    800059e0:	f85a                	sd	s6,48(sp)
    800059e2:	f45e                	sd	s7,40(sp)
    800059e4:	f062                	sd	s8,32(sp)
    800059e6:	ec66                	sd	s9,24(sp)
    800059e8:	1880                	addi	s0,sp,112
    800059ea:	8a2a                	mv	s4,a0
    800059ec:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800059ee:	00c52c83          	lw	s9,12(a0)
    800059f2:	001c9c9b          	slliw	s9,s9,0x1
    800059f6:	1c82                	slli	s9,s9,0x20
    800059f8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800059fc:	0001e517          	auipc	a0,0x1e
    80005a00:	ffc50513          	addi	a0,a0,-4 # 800239f8 <disk+0x128>
    80005a04:	9cafb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005a08:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005a0a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a0c:	0001eb17          	auipc	s6,0x1e
    80005a10:	ec4b0b13          	addi	s6,s6,-316 # 800238d0 <disk>
  for(int i = 0; i < 3; i++){
    80005a14:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a16:	0001ec17          	auipc	s8,0x1e
    80005a1a:	fe2c0c13          	addi	s8,s8,-30 # 800239f8 <disk+0x128>
    80005a1e:	a8b9                	j	80005a7c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005a20:	00fb0733          	add	a4,s6,a5
    80005a24:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005a28:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a2a:	0207c563          	bltz	a5,80005a54 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005a2e:	2905                	addiw	s2,s2,1
    80005a30:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a32:	05590963          	beq	s2,s5,80005a84 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005a36:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005a38:	0001e717          	auipc	a4,0x1e
    80005a3c:	e9870713          	addi	a4,a4,-360 # 800238d0 <disk>
    80005a40:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005a42:	01874683          	lbu	a3,24(a4)
    80005a46:	fee9                	bnez	a3,80005a20 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005a48:	2785                	addiw	a5,a5,1
    80005a4a:	0705                	addi	a4,a4,1
    80005a4c:	fe979be3          	bne	a5,s1,80005a42 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005a50:	57fd                	li	a5,-1
    80005a52:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005a54:	01205d63          	blez	s2,80005a6e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a58:	f9042503          	lw	a0,-112(s0)
    80005a5c:	d07ff0ef          	jal	80005762 <free_desc>
      for(int j = 0; j < i; j++)
    80005a60:	4785                	li	a5,1
    80005a62:	0127d663          	bge	a5,s2,80005a6e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a66:	f9442503          	lw	a0,-108(s0)
    80005a6a:	cf9ff0ef          	jal	80005762 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a6e:	85e2                	mv	a1,s8
    80005a70:	0001e517          	auipc	a0,0x1e
    80005a74:	e7850513          	addi	a0,a0,-392 # 800238e8 <disk+0x18>
    80005a78:	e96fc0ef          	jal	8000210e <sleep>
  for(int i = 0; i < 3; i++){
    80005a7c:	f9040613          	addi	a2,s0,-112
    80005a80:	894e                	mv	s2,s3
    80005a82:	bf55                	j	80005a36 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a84:	f9042503          	lw	a0,-112(s0)
    80005a88:	00451693          	slli	a3,a0,0x4

  if(write)
    80005a8c:	0001e797          	auipc	a5,0x1e
    80005a90:	e4478793          	addi	a5,a5,-444 # 800238d0 <disk>
    80005a94:	00a50713          	addi	a4,a0,10
    80005a98:	0712                	slli	a4,a4,0x4
    80005a9a:	973e                	add	a4,a4,a5
    80005a9c:	01703633          	snez	a2,s7
    80005aa0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005aa2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005aa6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005aaa:	6398                	ld	a4,0(a5)
    80005aac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005aae:	0a868613          	addi	a2,a3,168
    80005ab2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ab4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ab6:	6390                	ld	a2,0(a5)
    80005ab8:	00d605b3          	add	a1,a2,a3
    80005abc:	4741                	li	a4,16
    80005abe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ac0:	4805                	li	a6,1
    80005ac2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005ac6:	f9442703          	lw	a4,-108(s0)
    80005aca:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005ace:	0712                	slli	a4,a4,0x4
    80005ad0:	963a                	add	a2,a2,a4
    80005ad2:	058a0593          	addi	a1,s4,88
    80005ad6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005ad8:	0007b883          	ld	a7,0(a5)
    80005adc:	9746                	add	a4,a4,a7
    80005ade:	40000613          	li	a2,1024
    80005ae2:	c710                	sw	a2,8(a4)
  if(write)
    80005ae4:	001bb613          	seqz	a2,s7
    80005ae8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005aec:	00166613          	ori	a2,a2,1
    80005af0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005af4:	f9842583          	lw	a1,-104(s0)
    80005af8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005afc:	00250613          	addi	a2,a0,2
    80005b00:	0612                	slli	a2,a2,0x4
    80005b02:	963e                	add	a2,a2,a5
    80005b04:	577d                	li	a4,-1
    80005b06:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b0a:	0592                	slli	a1,a1,0x4
    80005b0c:	98ae                	add	a7,a7,a1
    80005b0e:	03068713          	addi	a4,a3,48
    80005b12:	973e                	add	a4,a4,a5
    80005b14:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b18:	6398                	ld	a4,0(a5)
    80005b1a:	972e                	add	a4,a4,a1
    80005b1c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b20:	4689                	li	a3,2
    80005b22:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b26:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b2a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005b2e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b32:	6794                	ld	a3,8(a5)
    80005b34:	0026d703          	lhu	a4,2(a3)
    80005b38:	8b1d                	andi	a4,a4,7
    80005b3a:	0706                	slli	a4,a4,0x1
    80005b3c:	96ba                	add	a3,a3,a4
    80005b3e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005b42:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b46:	6798                	ld	a4,8(a5)
    80005b48:	00275783          	lhu	a5,2(a4)
    80005b4c:	2785                	addiw	a5,a5,1
    80005b4e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005b52:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b56:	100017b7          	lui	a5,0x10001
    80005b5a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005b5e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005b62:	0001e917          	auipc	s2,0x1e
    80005b66:	e9690913          	addi	s2,s2,-362 # 800239f8 <disk+0x128>
  while(b->disk == 1) {
    80005b6a:	4485                	li	s1,1
    80005b6c:	01079a63          	bne	a5,a6,80005b80 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005b70:	85ca                	mv	a1,s2
    80005b72:	8552                	mv	a0,s4
    80005b74:	d9afc0ef          	jal	8000210e <sleep>
  while(b->disk == 1) {
    80005b78:	004a2783          	lw	a5,4(s4)
    80005b7c:	fe978ae3          	beq	a5,s1,80005b70 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005b80:	f9042903          	lw	s2,-112(s0)
    80005b84:	00290713          	addi	a4,s2,2
    80005b88:	0712                	slli	a4,a4,0x4
    80005b8a:	0001e797          	auipc	a5,0x1e
    80005b8e:	d4678793          	addi	a5,a5,-698 # 800238d0 <disk>
    80005b92:	97ba                	add	a5,a5,a4
    80005b94:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b98:	0001e997          	auipc	s3,0x1e
    80005b9c:	d3898993          	addi	s3,s3,-712 # 800238d0 <disk>
    80005ba0:	00491713          	slli	a4,s2,0x4
    80005ba4:	0009b783          	ld	a5,0(s3)
    80005ba8:	97ba                	add	a5,a5,a4
    80005baa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005bae:	854a                	mv	a0,s2
    80005bb0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005bb4:	bafff0ef          	jal	80005762 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005bb8:	8885                	andi	s1,s1,1
    80005bba:	f0fd                	bnez	s1,80005ba0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005bbc:	0001e517          	auipc	a0,0x1e
    80005bc0:	e3c50513          	addi	a0,a0,-452 # 800239f8 <disk+0x128>
    80005bc4:	8a2fb0ef          	jal	80000c66 <release>
}
    80005bc8:	70a6                	ld	ra,104(sp)
    80005bca:	7406                	ld	s0,96(sp)
    80005bcc:	64e6                	ld	s1,88(sp)
    80005bce:	6946                	ld	s2,80(sp)
    80005bd0:	69a6                	ld	s3,72(sp)
    80005bd2:	6a06                	ld	s4,64(sp)
    80005bd4:	7ae2                	ld	s5,56(sp)
    80005bd6:	7b42                	ld	s6,48(sp)
    80005bd8:	7ba2                	ld	s7,40(sp)
    80005bda:	7c02                	ld	s8,32(sp)
    80005bdc:	6ce2                	ld	s9,24(sp)
    80005bde:	6165                	addi	sp,sp,112
    80005be0:	8082                	ret

0000000080005be2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005be2:	1101                	addi	sp,sp,-32
    80005be4:	ec06                	sd	ra,24(sp)
    80005be6:	e822                	sd	s0,16(sp)
    80005be8:	e426                	sd	s1,8(sp)
    80005bea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005bec:	0001e497          	auipc	s1,0x1e
    80005bf0:	ce448493          	addi	s1,s1,-796 # 800238d0 <disk>
    80005bf4:	0001e517          	auipc	a0,0x1e
    80005bf8:	e0450513          	addi	a0,a0,-508 # 800239f8 <disk+0x128>
    80005bfc:	fd3fa0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c00:	100017b7          	lui	a5,0x10001
    80005c04:	53b8                	lw	a4,96(a5)
    80005c06:	8b0d                	andi	a4,a4,3
    80005c08:	100017b7          	lui	a5,0x10001
    80005c0c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005c0e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c12:	689c                	ld	a5,16(s1)
    80005c14:	0204d703          	lhu	a4,32(s1)
    80005c18:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c1c:	04f70663          	beq	a4,a5,80005c68 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005c20:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c24:	6898                	ld	a4,16(s1)
    80005c26:	0204d783          	lhu	a5,32(s1)
    80005c2a:	8b9d                	andi	a5,a5,7
    80005c2c:	078e                	slli	a5,a5,0x3
    80005c2e:	97ba                	add	a5,a5,a4
    80005c30:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005c32:	00278713          	addi	a4,a5,2
    80005c36:	0712                	slli	a4,a4,0x4
    80005c38:	9726                	add	a4,a4,s1
    80005c3a:	01074703          	lbu	a4,16(a4)
    80005c3e:	e321                	bnez	a4,80005c7e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c40:	0789                	addi	a5,a5,2
    80005c42:	0792                	slli	a5,a5,0x4
    80005c44:	97a6                	add	a5,a5,s1
    80005c46:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005c48:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c4c:	d0efc0ef          	jal	8000215a <wakeup>

    disk.used_idx += 1;
    80005c50:	0204d783          	lhu	a5,32(s1)
    80005c54:	2785                	addiw	a5,a5,1
    80005c56:	17c2                	slli	a5,a5,0x30
    80005c58:	93c1                	srli	a5,a5,0x30
    80005c5a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005c5e:	6898                	ld	a4,16(s1)
    80005c60:	00275703          	lhu	a4,2(a4)
    80005c64:	faf71ee3          	bne	a4,a5,80005c20 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c68:	0001e517          	auipc	a0,0x1e
    80005c6c:	d9050513          	addi	a0,a0,-624 # 800239f8 <disk+0x128>
    80005c70:	ff7fa0ef          	jal	80000c66 <release>
}
    80005c74:	60e2                	ld	ra,24(sp)
    80005c76:	6442                	ld	s0,16(sp)
    80005c78:	64a2                	ld	s1,8(sp)
    80005c7a:	6105                	addi	sp,sp,32
    80005c7c:	8082                	ret
      panic("virtio_disk_intr status");
    80005c7e:	00002517          	auipc	a0,0x2
    80005c82:	a8250513          	addi	a0,a0,-1406 # 80007700 <etext+0x700>
    80005c86:	b5bfa0ef          	jal	800007e0 <panic>
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
