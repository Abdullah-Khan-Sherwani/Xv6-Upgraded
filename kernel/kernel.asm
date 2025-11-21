
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	98010113          	addi	sp,sp,-1664 # 80007980 <stack0>
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
    80000016:	04a000ef          	jal	ra,80000060 <start>

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
    80000056:	14d79073          	csrw	0x14d,a5
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd75f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d6278793          	addi	a5,a5,-670 # 80000de2 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
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
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
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
    800000d0:	7159                	addi	sp,sp,-112
    800000d2:	f486                	sd	ra,104(sp)
    800000d4:	f0a2                	sd	s0,96(sp)
    800000d6:	eca6                	sd	s1,88(sp)
    800000d8:	e8ca                	sd	s2,80(sp)
    800000da:	e4ce                	sd	s3,72(sp)
    800000dc:	e0d2                	sd	s4,64(sp)
    800000de:	fc56                	sd	s5,56(sp)
    800000e0:	f85a                	sd	s6,48(sp)
    800000e2:	f45e                	sd	s7,40(sp)
    800000e4:	f062                	sd	s8,32(sp)
    800000e6:	1880                	addi	s0,sp,112
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000e8:	04c05463          	blez	a2,80000130 <consolewrite+0x60>
    800000ec:	8a2a                	mv	s4,a0
    800000ee:	8aae                	mv	s5,a1
    800000f0:	89b2                	mv	s3,a2
  int i = 0;
    800000f2:	4901                	li	s2,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f4:	4bfd                	li	s7,31
    int nn = sizeof(buf);
    800000f6:	02000c13          	li	s8,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fa:	5b7d                	li	s6,-1
    800000fc:	a025                	j	80000124 <consolewrite+0x54>
    800000fe:	86a6                	mv	a3,s1
    80000100:	01590633          	add	a2,s2,s5
    80000104:	85d2                	mv	a1,s4
    80000106:	f9040513          	addi	a0,s0,-112
    8000010a:	1cc020ef          	jal	ra,800022d6 <either_copyin>
    8000010e:	03650263          	beq	a0,s6,80000132 <consolewrite+0x62>
      break;
    uartwrite(buf, nn);
    80000112:	85a6                	mv	a1,s1
    80000114:	f9040513          	addi	a0,s0,-112
    80000118:	71e000ef          	jal	ra,80000836 <uartwrite>
    i += nn;
    8000011c:	0124893b          	addw	s2,s1,s2
  while(i < n){
    80000120:	01395963          	bge	s2,s3,80000132 <consolewrite+0x62>
    if(nn > n - i)
    80000124:	412984bb          	subw	s1,s3,s2
    80000128:	fc9bdbe3          	bge	s7,s1,800000fe <consolewrite+0x2e>
    int nn = sizeof(buf);
    8000012c:	84e2                	mv	s1,s8
    8000012e:	bfc1                	j	800000fe <consolewrite+0x2e>
  int i = 0;
    80000130:	4901                	li	s2,0
  }

  return i;
}
    80000132:	854a                	mv	a0,s2
    80000134:	70a6                	ld	ra,104(sp)
    80000136:	7406                	ld	s0,96(sp)
    80000138:	64e6                	ld	s1,88(sp)
    8000013a:	6946                	ld	s2,80(sp)
    8000013c:	69a6                	ld	s3,72(sp)
    8000013e:	6a06                	ld	s4,64(sp)
    80000140:	7ae2                	ld	s5,56(sp)
    80000142:	7b42                	ld	s6,48(sp)
    80000144:	7ba2                	ld	s7,40(sp)
    80000146:	7c02                	ld	s8,32(sp)
    80000148:	6165                	addi	sp,sp,112
    8000014a:	8082                	ret

000000008000014c <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014c:	7159                	addi	sp,sp,-112
    8000014e:	f486                	sd	ra,104(sp)
    80000150:	f0a2                	sd	s0,96(sp)
    80000152:	eca6                	sd	s1,88(sp)
    80000154:	e8ca                	sd	s2,80(sp)
    80000156:	e4ce                	sd	s3,72(sp)
    80000158:	e0d2                	sd	s4,64(sp)
    8000015a:	fc56                	sd	s5,56(sp)
    8000015c:	f85a                	sd	s6,48(sp)
    8000015e:	f45e                	sd	s7,40(sp)
    80000160:	f062                	sd	s8,32(sp)
    80000162:	ec66                	sd	s9,24(sp)
    80000164:	e86a                	sd	s10,16(sp)
    80000166:	1880                	addi	s0,sp,112
    80000168:	8aaa                	mv	s5,a0
    8000016a:	8a2e                	mv	s4,a1
    8000016c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000016e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000172:	00010517          	auipc	a0,0x10
    80000176:	80e50513          	addi	a0,a0,-2034 # 8000f980 <cons>
    8000017a:	1f3000ef          	jal	ra,80000b6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000017e:	00010497          	auipc	s1,0x10
    80000182:	80248493          	addi	s1,s1,-2046 # 8000f980 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000186:	00010917          	auipc	s2,0x10
    8000018a:	89290913          	addi	s2,s2,-1902 # 8000fa18 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000018e:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000190:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000192:	4ca9                	li	s9,10
  while(n > 0){
    80000194:	07305363          	blez	s3,800001fa <consoleread+0xae>
    while(cons.r == cons.w){
    80000198:	0984a783          	lw	a5,152(s1)
    8000019c:	09c4a703          	lw	a4,156(s1)
    800001a0:	02f71163          	bne	a4,a5,800001c2 <consoleread+0x76>
      if(killed(myproc())){
    800001a4:	674010ef          	jal	ra,80001818 <myproc>
    800001a8:	7c1010ef          	jal	ra,80002168 <killed>
    800001ac:	e125                	bnez	a0,8000020c <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    800001ae:	85a6                	mv	a1,s1
    800001b0:	854a                	mv	a0,s2
    800001b2:	57f010ef          	jal	ra,80001f30 <sleep>
    while(cons.r == cons.w){
    800001b6:	0984a783          	lw	a5,152(s1)
    800001ba:	09c4a703          	lw	a4,156(s1)
    800001be:	fef703e3          	beq	a4,a5,800001a4 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001c2:	0017871b          	addiw	a4,a5,1
    800001c6:	08e4ac23          	sw	a4,152(s1)
    800001ca:	07f7f713          	andi	a4,a5,127
    800001ce:	9726                	add	a4,a4,s1
    800001d0:	01874703          	lbu	a4,24(a4)
    800001d4:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001d8:	057d0f63          	beq	s10,s7,80000236 <consoleread+0xea>
    cbuf = c;
    800001dc:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001e0:	4685                	li	a3,1
    800001e2:	f9f40613          	addi	a2,s0,-97
    800001e6:	85d2                	mv	a1,s4
    800001e8:	8556                	mv	a0,s5
    800001ea:	0a2020ef          	jal	ra,8000228c <either_copyout>
    800001ee:	01850663          	beq	a0,s8,800001fa <consoleread+0xae>
    dst++;
    800001f2:	0a05                	addi	s4,s4,1
    --n;
    800001f4:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001f6:	f99d1fe3          	bne	s10,s9,80000194 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001fa:	0000f517          	auipc	a0,0xf
    800001fe:	78650513          	addi	a0,a0,1926 # 8000f980 <cons>
    80000202:	203000ef          	jal	ra,80000c04 <release>

  return target - n;
    80000206:	413b053b          	subw	a0,s6,s3
    8000020a:	a801                	j	8000021a <consoleread+0xce>
        release(&cons.lock);
    8000020c:	0000f517          	auipc	a0,0xf
    80000210:	77450513          	addi	a0,a0,1908 # 8000f980 <cons>
    80000214:	1f1000ef          	jal	ra,80000c04 <release>
        return -1;
    80000218:	557d                	li	a0,-1
}
    8000021a:	70a6                	ld	ra,104(sp)
    8000021c:	7406                	ld	s0,96(sp)
    8000021e:	64e6                	ld	s1,88(sp)
    80000220:	6946                	ld	s2,80(sp)
    80000222:	69a6                	ld	s3,72(sp)
    80000224:	6a06                	ld	s4,64(sp)
    80000226:	7ae2                	ld	s5,56(sp)
    80000228:	7b42                	ld	s6,48(sp)
    8000022a:	7ba2                	ld	s7,40(sp)
    8000022c:	7c02                	ld	s8,32(sp)
    8000022e:	6ce2                	ld	s9,24(sp)
    80000230:	6d42                	ld	s10,16(sp)
    80000232:	6165                	addi	sp,sp,112
    80000234:	8082                	ret
      if(n < target){
    80000236:	0009871b          	sext.w	a4,s3
    8000023a:	fd6770e3          	bgeu	a4,s6,800001fa <consoleread+0xae>
        cons.r--;
    8000023e:	0000f717          	auipc	a4,0xf
    80000242:	7cf72d23          	sw	a5,2010(a4) # 8000fa18 <cons+0x98>
    80000246:	bf55                	j	800001fa <consoleread+0xae>

0000000080000248 <consputc>:
{
    80000248:	1141                	addi	sp,sp,-16
    8000024a:	e406                	sd	ra,8(sp)
    8000024c:	e022                	sd	s0,0(sp)
    8000024e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000250:	10000793          	li	a5,256
    80000254:	00f50863          	beq	a0,a5,80000264 <consputc+0x1c>
    uartputc_sync(c);
    80000258:	67c000ef          	jal	ra,800008d4 <uartputc_sync>
}
    8000025c:	60a2                	ld	ra,8(sp)
    8000025e:	6402                	ld	s0,0(sp)
    80000260:	0141                	addi	sp,sp,16
    80000262:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000264:	4521                	li	a0,8
    80000266:	66e000ef          	jal	ra,800008d4 <uartputc_sync>
    8000026a:	02000513          	li	a0,32
    8000026e:	666000ef          	jal	ra,800008d4 <uartputc_sync>
    80000272:	4521                	li	a0,8
    80000274:	660000ef          	jal	ra,800008d4 <uartputc_sync>
    80000278:	b7d5                	j	8000025c <consputc+0x14>

000000008000027a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000027a:	1101                	addi	sp,sp,-32
    8000027c:	ec06                	sd	ra,24(sp)
    8000027e:	e822                	sd	s0,16(sp)
    80000280:	e426                	sd	s1,8(sp)
    80000282:	e04a                	sd	s2,0(sp)
    80000284:	1000                	addi	s0,sp,32
    80000286:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80000288:	0000f517          	auipc	a0,0xf
    8000028c:	6f850513          	addi	a0,a0,1784 # 8000f980 <cons>
    80000290:	0dd000ef          	jal	ra,80000b6c <acquire>

  switch(c){
    80000294:	47d5                	li	a5,21
    80000296:	0af48063          	beq	s1,a5,80000336 <consoleintr+0xbc>
    8000029a:	0297c663          	blt	a5,s1,800002c6 <consoleintr+0x4c>
    8000029e:	47a1                	li	a5,8
    800002a0:	0cf48f63          	beq	s1,a5,8000037e <consoleintr+0x104>
    800002a4:	47c1                	li	a5,16
    800002a6:	10f49063          	bne	s1,a5,800003a6 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800002aa:	076020ef          	jal	ra,80002320 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ae:	0000f517          	auipc	a0,0xf
    800002b2:	6d250513          	addi	a0,a0,1746 # 8000f980 <cons>
    800002b6:	14f000ef          	jal	ra,80000c04 <release>
}
    800002ba:	60e2                	ld	ra,24(sp)
    800002bc:	6442                	ld	s0,16(sp)
    800002be:	64a2                	ld	s1,8(sp)
    800002c0:	6902                	ld	s2,0(sp)
    800002c2:	6105                	addi	sp,sp,32
    800002c4:	8082                	ret
  switch(c){
    800002c6:	07f00793          	li	a5,127
    800002ca:	0af48a63          	beq	s1,a5,8000037e <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002ce:	0000f717          	auipc	a4,0xf
    800002d2:	6b270713          	addi	a4,a4,1714 # 8000f980 <cons>
    800002d6:	0a072783          	lw	a5,160(a4)
    800002da:	09872703          	lw	a4,152(a4)
    800002de:	9f99                	subw	a5,a5,a4
    800002e0:	07f00713          	li	a4,127
    800002e4:	fcf765e3          	bltu	a4,a5,800002ae <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002e8:	47b5                	li	a5,13
    800002ea:	0cf48163          	beq	s1,a5,800003ac <consoleintr+0x132>
      consputc(c);
    800002ee:	8526                	mv	a0,s1
    800002f0:	f59ff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f4:	0000f797          	auipc	a5,0xf
    800002f8:	68c78793          	addi	a5,a5,1676 # 8000f980 <cons>
    800002fc:	0a07a683          	lw	a3,160(a5)
    80000300:	0016871b          	addiw	a4,a3,1
    80000304:	0007061b          	sext.w	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0af48f63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    8000031c:	4791                	li	a5,4
    8000031e:	0af48c63          	beq	s1,a5,800003d6 <consoleintr+0x15c>
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	6f67a783          	lw	a5,1782(a5) # 8000fa18 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f6f71fe3          	bne	a4,a5,800002ae <consoleintr+0x34>
    80000334:	a04d                	j	800003d6 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000336:	0000f717          	auipc	a4,0xf
    8000033a:	64a70713          	addi	a4,a4,1610 # 8000f980 <cons>
    8000033e:	0a072783          	lw	a5,160(a4)
    80000342:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000346:	0000f497          	auipc	s1,0xf
    8000034a:	63a48493          	addi	s1,s1,1594 # 8000f980 <cons>
    while(cons.e != cons.w &&
    8000034e:	4929                	li	s2,10
    80000350:	f4f70fe3          	beq	a4,a5,800002ae <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000354:	37fd                	addiw	a5,a5,-1
    80000356:	07f7f713          	andi	a4,a5,127
    8000035a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000035c:	01874703          	lbu	a4,24(a4)
    80000360:	f52707e3          	beq	a4,s2,800002ae <consoleintr+0x34>
      cons.e--;
    80000364:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000368:	10000513          	li	a0,256
    8000036c:	eddff0ef          	jal	ra,80000248 <consputc>
    while(cons.e != cons.w &&
    80000370:	0a04a783          	lw	a5,160(s1)
    80000374:	09c4a703          	lw	a4,156(s1)
    80000378:	fcf71ee3          	bne	a4,a5,80000354 <consoleintr+0xda>
    8000037c:	bf0d                	j	800002ae <consoleintr+0x34>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	60270713          	addi	a4,a4,1538 # 8000f980 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f2f700e3          	beq	a4,a5,800002ae <consoleintr+0x34>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	68f72623          	sw	a5,1676(a4) # 8000fa20 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea9ff0ef          	jal	ra,80000248 <consputc>
    800003a4:	b729                	j	800002ae <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	f00484e3          	beqz	s1,800002ae <consoleintr+0x34>
    800003aa:	b715                	j	800002ce <consoleintr+0x54>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e9bff0ef          	jal	ra,80000248 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	5ce78793          	addi	a5,a5,1486 # 8000f980 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	64c7a323          	sw	a2,1606(a5) # 8000fa1c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	63a50513          	addi	a0,a0,1594 # 8000fa18 <cons+0x98>
    800003e6:	397010ef          	jal	ra,80001f7c <wakeup>
    800003ea:	b5d1                	j	800002ae <consoleintr+0x34>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c1c58593          	addi	a1,a1,-996 # 80007010 <etext+0x10>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	58450513          	addi	a0,a0,1412 # 8000f980 <cons>
    80000404:	6e8000ef          	jal	ra,80000aec <initlock>

  uartinit();
    80000408:	3e2000ef          	jal	ra,800007ea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	afc78793          	addi	a5,a5,-1284 # 8001ff08 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d3870713          	addi	a4,a4,-712 # 8000014c <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7139                	addi	sp,sp,-64
    80000432:	fc06                	sd	ra,56(sp)
    80000434:	f822                	sd	s0,48(sp)
    80000436:	f426                	sd	s1,40(sp)
    80000438:	f04a                	sd	s2,32(sp)
    8000043a:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000043c:	c219                	beqz	a2,80000442 <printint+0x12>
    8000043e:	06054f63          	bltz	a0,800004bc <printint+0x8c>
    x = -xx;
  else
    x = xx;
    80000442:	4881                	li	a7,0
    80000444:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000448:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000044a:	00007617          	auipc	a2,0x7
    8000044e:	bee60613          	addi	a2,a2,-1042 # 80007038 <digits>
    80000452:	883e                	mv	a6,a5
    80000454:	2785                	addiw	a5,a5,1
    80000456:	02b57733          	remu	a4,a0,a1
    8000045a:	9732                	add	a4,a4,a2
    8000045c:	00074703          	lbu	a4,0(a4)
    80000460:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000464:	872a                	mv	a4,a0
    80000466:	02b55533          	divu	a0,a0,a1
    8000046a:	0685                	addi	a3,a3,1
    8000046c:	feb773e3          	bgeu	a4,a1,80000452 <printint+0x22>

  if(sign)
    80000470:	00088b63          	beqz	a7,80000486 <printint+0x56>
    buf[i++] = '-';
    80000474:	fe040713          	addi	a4,s0,-32
    80000478:	97ba                	add	a5,a5,a4
    8000047a:	02d00713          	li	a4,45
    8000047e:	fee78423          	sb	a4,-24(a5)
    80000482:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000486:	02f05563          	blez	a5,800004b0 <printint+0x80>
    8000048a:	fc840713          	addi	a4,s0,-56
    8000048e:	00f704b3          	add	s1,a4,a5
    80000492:	fff70913          	addi	s2,a4,-1
    80000496:	993e                	add	s2,s2,a5
    80000498:	37fd                	addiw	a5,a5,-1
    8000049a:	1782                	slli	a5,a5,0x20
    8000049c:	9381                	srli	a5,a5,0x20
    8000049e:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a2:	fff4c503          	lbu	a0,-1(s1)
    800004a6:	da3ff0ef          	jal	ra,80000248 <consputc>
  while(--i >= 0)
    800004aa:	14fd                	addi	s1,s1,-1
    800004ac:	ff249be3          	bne	s1,s2,800004a2 <printint+0x72>
}
    800004b0:	70e2                	ld	ra,56(sp)
    800004b2:	7442                	ld	s0,48(sp)
    800004b4:	74a2                	ld	s1,40(sp)
    800004b6:	7902                	ld	s2,32(sp)
    800004b8:	6121                	addi	sp,sp,64
    800004ba:	8082                	ret
    x = -xx;
    800004bc:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004c0:	4885                	li	a7,1
    x = -xx;
    800004c2:	b749                	j	80000444 <printint+0x14>

00000000800004c4 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c4:	7131                	addi	sp,sp,-192
    800004c6:	fc86                	sd	ra,120(sp)
    800004c8:	f8a2                	sd	s0,112(sp)
    800004ca:	f4a6                	sd	s1,104(sp)
    800004cc:	f0ca                	sd	s2,96(sp)
    800004ce:	ecce                	sd	s3,88(sp)
    800004d0:	e8d2                	sd	s4,80(sp)
    800004d2:	e4d6                	sd	s5,72(sp)
    800004d4:	e0da                	sd	s6,64(sp)
    800004d6:	fc5e                	sd	s7,56(sp)
    800004d8:	f862                	sd	s8,48(sp)
    800004da:	f466                	sd	s9,40(sp)
    800004dc:	f06a                	sd	s10,32(sp)
    800004de:	ec6e                	sd	s11,24(sp)
    800004e0:	0100                	addi	s0,sp,128
    800004e2:	8a2a                	mv	s4,a0
    800004e4:	e40c                	sd	a1,8(s0)
    800004e6:	e810                	sd	a2,16(s0)
    800004e8:	ec14                	sd	a3,24(s0)
    800004ea:	f018                	sd	a4,32(s0)
    800004ec:	f41c                	sd	a5,40(s0)
    800004ee:	03043823          	sd	a6,48(s0)
    800004f2:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800004f6:	00007797          	auipc	a5,0x7
    800004fa:	44e7a783          	lw	a5,1102(a5) # 80007944 <panicking>
    800004fe:	cb9d                	beqz	a5,80000534 <printf+0x70>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000500:	00840793          	addi	a5,s0,8
    80000504:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000508:	000a4503          	lbu	a0,0(s4)
    8000050c:	24050363          	beqz	a0,80000752 <printf+0x28e>
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000052a:	00007b97          	auipc	s7,0x7
    8000052e:	b0eb8b93          	addi	s7,s7,-1266 # 80007038 <digits>
    80000532:	a01d                	j	80000558 <printf+0x94>
    acquire(&pr.lock);
    80000534:	0000f517          	auipc	a0,0xf
    80000538:	4f450513          	addi	a0,a0,1268 # 8000fa28 <pr>
    8000053c:	630000ef          	jal	ra,80000b6c <acquire>
    80000540:	b7c1                	j	80000500 <printf+0x3c>
      consputc(cx);
    80000542:	d07ff0ef          	jal	ra,80000248 <consputc>
      continue;
    80000546:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000548:	0014899b          	addiw	s3,s1,1
    8000054c:	013a07b3          	add	a5,s4,s3
    80000550:	0007c503          	lbu	a0,0(a5)
    80000554:	1e050f63          	beqz	a0,80000752 <printf+0x28e>
    if(cx != '%'){
    80000558:	ff5515e3          	bne	a0,s5,80000542 <printf+0x7e>
    i++;
    8000055c:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000560:	009a07b3          	add	a5,s4,s1
    80000564:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000568:	1e090563          	beqz	s2,80000752 <printf+0x28e>
    8000056c:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000570:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000572:	c789                	beqz	a5,8000057c <printf+0xb8>
    80000574:	009a0733          	add	a4,s4,s1
    80000578:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000057c:	03690863          	beq	s2,s6,800005ac <printf+0xe8>
    } else if(c0 == 'l' && c1 == 'd'){
    80000580:	05890263          	beq	s2,s8,800005c4 <printf+0x100>
    } else if(c0 == 'u'){
    80000584:	0d990163          	beq	s2,s9,80000646 <printf+0x182>
    } else if(c0 == 'x'){
    80000588:	11a90863          	beq	s2,s10,80000698 <printf+0x1d4>
    } else if(c0 == 'p'){
    8000058c:	15b90163          	beq	s2,s11,800006ce <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    80000590:	06300793          	li	a5,99
    80000594:	16f90963          	beq	s2,a5,80000706 <printf+0x242>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80000598:	07300793          	li	a5,115
    8000059c:	16f90f63          	beq	s2,a5,8000071a <printf+0x256>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a0:	03591c63          	bne	s2,s5,800005d8 <printf+0x114>
      consputc('%');
    800005a4:	8556                	mv	a0,s5
    800005a6:	ca3ff0ef          	jal	ra,80000248 <consputc>
    800005aa:	bf79                	j	80000548 <printf+0x84>
      printint(va_arg(ap, int), 10, 1);
    800005ac:	f8843783          	ld	a5,-120(s0)
    800005b0:	00878713          	addi	a4,a5,8
    800005b4:	f8e43423          	sd	a4,-120(s0)
    800005b8:	4605                	li	a2,1
    800005ba:	45a9                	li	a1,10
    800005bc:	4388                	lw	a0,0(a5)
    800005be:	e73ff0ef          	jal	ra,80000430 <printint>
    800005c2:	b759                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c4:	03678163          	beq	a5,s6,800005e6 <printf+0x122>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005c8:	03878d63          	beq	a5,s8,80000602 <printf+0x13e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005cc:	09978a63          	beq	a5,s9,80000660 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005d0:	03878b63          	beq	a5,s8,80000606 <printf+0x142>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	0da78f63          	beq	a5,s10,800006b2 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005d8:	8556                	mv	a0,s5
    800005da:	c6fff0ef          	jal	ra,80000248 <consputc>
      consputc(c0);
    800005de:	854a                	mv	a0,s2
    800005e0:	c69ff0ef          	jal	ra,80000248 <consputc>
    800005e4:	b795                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    800005e6:	f8843783          	ld	a5,-120(s0)
    800005ea:	00878713          	addi	a4,a5,8
    800005ee:	f8e43423          	sd	a4,-120(s0)
    800005f2:	4605                	li	a2,1
    800005f4:	45a9                	li	a1,10
    800005f6:	6388                	ld	a0,0(a5)
    800005f8:	e39ff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800005fc:	0029849b          	addiw	s1,s3,2
    80000600:	b7a1                	j	80000548 <printf+0x84>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000602:	03668463          	beq	a3,s6,8000062a <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000606:	07968b63          	beq	a3,s9,8000067c <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000060a:	fda697e3          	bne	a3,s10,800005d8 <printf+0x114>
      printint(va_arg(ap, uint64), 16, 0);
    8000060e:	f8843783          	ld	a5,-120(s0)
    80000612:	00878713          	addi	a4,a5,8
    80000616:	f8e43423          	sd	a4,-120(s0)
    8000061a:	4601                	li	a2,0
    8000061c:	45c1                	li	a1,16
    8000061e:	6388                	ld	a0,0(a5)
    80000620:	e11ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000624:	0039849b          	addiw	s1,s3,3
    80000628:	b705                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 1);
    8000062a:	f8843783          	ld	a5,-120(s0)
    8000062e:	00878713          	addi	a4,a5,8
    80000632:	f8e43423          	sd	a4,-120(s0)
    80000636:	4605                	li	a2,1
    80000638:	45a9                	li	a1,10
    8000063a:	6388                	ld	a0,0(a5)
    8000063c:	df5ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000640:	0039849b          	addiw	s1,s3,3
    80000644:	b711                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 10, 0);
    80000646:	f8843783          	ld	a5,-120(s0)
    8000064a:	00878713          	addi	a4,a5,8
    8000064e:	f8e43423          	sd	a4,-120(s0)
    80000652:	4601                	li	a2,0
    80000654:	45a9                	li	a1,10
    80000656:	0007e503          	lwu	a0,0(a5)
    8000065a:	dd7ff0ef          	jal	ra,80000430 <printint>
    8000065e:	b5ed                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	dbfff0ef          	jal	ra,80000430 <printint>
      i += 1;
    80000676:	0029849b          	addiw	s1,s3,2
    8000067a:	b5f9                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	6388                	ld	a0,0(a5)
    8000068e:	da3ff0ef          	jal	ra,80000430 <printint>
      i += 2;
    80000692:	0039849b          	addiw	s1,s3,3
    80000696:	bd4d                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint32), 16, 0);
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	4601                	li	a2,0
    800006a6:	45c1                	li	a1,16
    800006a8:	0007e503          	lwu	a0,0(a5)
    800006ac:	d85ff0ef          	jal	ra,80000430 <printint>
    800006b0:	bd61                	j	80000548 <printf+0x84>
      printint(va_arg(ap, uint64), 16, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45c1                	li	a1,16
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	d6dff0ef          	jal	ra,80000430 <printint>
      i += 1;
    800006c8:	0029849b          	addiw	s1,s3,2
    800006cc:	bdb5                	j	80000548 <printf+0x84>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	b67ff0ef          	jal	ra,80000248 <consputc>
  consputc('x');
    800006e6:	856a                	mv	a0,s10
    800006e8:	b61ff0ef          	jal	ra,80000248 <consputc>
    800006ec:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ee:	03c9d793          	srli	a5,s3,0x3c
    800006f2:	97de                	add	a5,a5,s7
    800006f4:	0007c503          	lbu	a0,0(a5)
    800006f8:	b51ff0ef          	jal	ra,80000248 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006fc:	0992                	slli	s3,s3,0x4
    800006fe:	397d                	addiw	s2,s2,-1
    80000700:	fe0917e3          	bnez	s2,800006ee <printf+0x22a>
    80000704:	b591                	j	80000548 <printf+0x84>
      consputc(va_arg(ap, uint));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	4388                	lw	a0,0(a5)
    80000714:	b35ff0ef          	jal	ra,80000248 <consputc>
    80000718:	bd05                	j	80000548 <printf+0x84>
      if((s = va_arg(ap, char*)) == 0)
    8000071a:	f8843783          	ld	a5,-120(s0)
    8000071e:	00878713          	addi	a4,a5,8
    80000722:	f8e43423          	sd	a4,-120(s0)
    80000726:	0007b903          	ld	s2,0(a5)
    8000072a:	00090d63          	beqz	s2,80000744 <printf+0x280>
      for(; *s; s++)
    8000072e:	00094503          	lbu	a0,0(s2)
    80000732:	e0050be3          	beqz	a0,80000548 <printf+0x84>
        consputc(*s);
    80000736:	b13ff0ef          	jal	ra,80000248 <consputc>
      for(; *s; s++)
    8000073a:	0905                	addi	s2,s2,1
    8000073c:	00094503          	lbu	a0,0(s2)
    80000740:	f97d                	bnez	a0,80000736 <printf+0x272>
    80000742:	b519                	j	80000548 <printf+0x84>
        s = "(null)";
    80000744:	00007917          	auipc	s2,0x7
    80000748:	8d490913          	addi	s2,s2,-1836 # 80007018 <etext+0x18>
      for(; *s; s++)
    8000074c:	02800513          	li	a0,40
    80000750:	b7dd                	j	80000736 <printf+0x272>
    }

  }
  va_end(ap);

  if(panicking == 0)
    80000752:	00007797          	auipc	a5,0x7
    80000756:	1f27a783          	lw	a5,498(a5) # 80007944 <panicking>
    8000075a:	c38d                	beqz	a5,8000077c <printf+0x2b8>
    release(&pr.lock);

  return 0;
}
    8000075c:	4501                	li	a0,0
    8000075e:	70e6                	ld	ra,120(sp)
    80000760:	7446                	ld	s0,112(sp)
    80000762:	74a6                	ld	s1,104(sp)
    80000764:	7906                	ld	s2,96(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6a46                	ld	s4,80(sp)
    8000076a:	6aa6                	ld	s5,72(sp)
    8000076c:	6b06                	ld	s6,64(sp)
    8000076e:	7be2                	ld	s7,56(sp)
    80000770:	7c42                	ld	s8,48(sp)
    80000772:	7ca2                	ld	s9,40(sp)
    80000774:	7d02                	ld	s10,32(sp)
    80000776:	6de2                	ld	s11,24(sp)
    80000778:	6129                	addi	sp,sp,192
    8000077a:	8082                	ret
    release(&pr.lock);
    8000077c:	0000f517          	auipc	a0,0xf
    80000780:	2ac50513          	addi	a0,a0,684 # 8000fa28 <pr>
    80000784:	480000ef          	jal	ra,80000c04 <release>
  return 0;
    80000788:	bfd1                	j	8000075c <printf+0x298>

000000008000078a <panic>:

void
panic(char *s)
{
    8000078a:	1101                	addi	sp,sp,-32
    8000078c:	ec06                	sd	ra,24(sp)
    8000078e:	e822                	sd	s0,16(sp)
    80000790:	e426                	sd	s1,8(sp)
    80000792:	e04a                	sd	s2,0(sp)
    80000794:	1000                	addi	s0,sp,32
    80000796:	84aa                	mv	s1,a0
  panicking = 1;
    80000798:	4905                	li	s2,1
    8000079a:	00007797          	auipc	a5,0x7
    8000079e:	1b27a523          	sw	s2,426(a5) # 80007944 <panicking>
  printf("panic: ");
    800007a2:	00007517          	auipc	a0,0x7
    800007a6:	87e50513          	addi	a0,a0,-1922 # 80007020 <etext+0x20>
    800007aa:	d1bff0ef          	jal	ra,800004c4 <printf>
  printf("%s\n", s);
    800007ae:	85a6                	mv	a1,s1
    800007b0:	00007517          	auipc	a0,0x7
    800007b4:	87850513          	addi	a0,a0,-1928 # 80007028 <etext+0x28>
    800007b8:	d0dff0ef          	jal	ra,800004c4 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	1927a223          	sw	s2,388(a5) # 80007940 <panicked>
  for(;;)
    800007c4:	a001                	j	800007c4 <panic+0x3a>

00000000800007c6 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007c6:	1141                	addi	sp,sp,-16
    800007c8:	e406                	sd	ra,8(sp)
    800007ca:	e022                	sd	s0,0(sp)
    800007cc:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007ce:	00007597          	auipc	a1,0x7
    800007d2:	86258593          	addi	a1,a1,-1950 # 80007030 <etext+0x30>
    800007d6:	0000f517          	auipc	a0,0xf
    800007da:	25250513          	addi	a0,a0,594 # 8000fa28 <pr>
    800007de:	30e000ef          	jal	ra,80000aec <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800007ea:	1141                	addi	sp,sp,-16
    800007ec:	e406                	sd	ra,8(sp)
    800007ee:	e022                	sd	s0,0(sp)
    800007f0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007f2:	100007b7          	lui	a5,0x10000
    800007f6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007fa:	f8000713          	li	a4,-128
    800007fe:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000802:	470d                	li	a4,3
    80000804:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000808:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000810:	469d                	li	a3,7
    80000812:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000816:	00e780a3          	sb	a4,1(a5)

  initlock(&tx_lock, "uart");
    8000081a:	00007597          	auipc	a1,0x7
    8000081e:	83658593          	addi	a1,a1,-1994 # 80007050 <digits+0x18>
    80000822:	0000f517          	auipc	a0,0xf
    80000826:	21e50513          	addi	a0,a0,542 # 8000fa40 <tx_lock>
    8000082a:	2c2000ef          	jal	ra,80000aec <initlock>
}
    8000082e:	60a2                	ld	ra,8(sp)
    80000830:	6402                	ld	s0,0(sp)
    80000832:	0141                	addi	sp,sp,16
    80000834:	8082                	ret

0000000080000836 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000836:	715d                	addi	sp,sp,-80
    80000838:	e486                	sd	ra,72(sp)
    8000083a:	e0a2                	sd	s0,64(sp)
    8000083c:	fc26                	sd	s1,56(sp)
    8000083e:	f84a                	sd	s2,48(sp)
    80000840:	f44e                	sd	s3,40(sp)
    80000842:	f052                	sd	s4,32(sp)
    80000844:	ec56                	sd	s5,24(sp)
    80000846:	e85a                	sd	s6,16(sp)
    80000848:	e45e                	sd	s7,8(sp)
    8000084a:	0880                	addi	s0,sp,80
    8000084c:	84aa                	mv	s1,a0
    8000084e:	8aae                	mv	s5,a1
  acquire(&tx_lock);
    80000850:	0000f517          	auipc	a0,0xf
    80000854:	1f050513          	addi	a0,a0,496 # 8000fa40 <tx_lock>
    80000858:	314000ef          	jal	ra,80000b6c <acquire>

  int i = 0;
  while(i < n){ 
    8000085c:	05505b63          	blez	s5,800008b2 <uartwrite+0x7c>
    80000860:	8a26                	mv	s4,s1
    80000862:	0485                	addi	s1,s1,1
    80000864:	3afd                	addiw	s5,s5,-1
    80000866:	1a82                	slli	s5,s5,0x20
    80000868:	020ada93          	srli	s5,s5,0x20
    8000086c:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    8000086e:	00007497          	auipc	s1,0x7
    80000872:	0de48493          	addi	s1,s1,222 # 8000794c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000876:	0000f997          	auipc	s3,0xf
    8000087a:	1ca98993          	addi	s3,s3,458 # 8000fa40 <tx_lock>
    8000087e:	00007917          	auipc	s2,0x7
    80000882:	0ca90913          	addi	s2,s2,202 # 80007948 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000886:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    8000088a:	4b05                	li	s6,1
    8000088c:	a005                	j	800008ac <uartwrite+0x76>
      sleep(&tx_chan, &tx_lock);
    8000088e:	85ce                	mv	a1,s3
    80000890:	854a                	mv	a0,s2
    80000892:	69e010ef          	jal	ra,80001f30 <sleep>
    while(tx_busy != 0){
    80000896:	409c                	lw	a5,0(s1)
    80000898:	fbfd                	bnez	a5,8000088e <uartwrite+0x58>
    WriteReg(THR, buf[i]);
    8000089a:	000a4783          	lbu	a5,0(s4)
    8000089e:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008a2:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008a6:	0a05                	addi	s4,s4,1
    800008a8:	015a0563          	beq	s4,s5,800008b2 <uartwrite+0x7c>
    while(tx_busy != 0){
    800008ac:	409c                	lw	a5,0(s1)
    800008ae:	f3e5                	bnez	a5,8000088e <uartwrite+0x58>
    800008b0:	b7ed                	j	8000089a <uartwrite+0x64>
  }

  release(&tx_lock);
    800008b2:	0000f517          	auipc	a0,0xf
    800008b6:	18e50513          	addi	a0,a0,398 # 8000fa40 <tx_lock>
    800008ba:	34a000ef          	jal	ra,80000c04 <release>
}
    800008be:	60a6                	ld	ra,72(sp)
    800008c0:	6406                	ld	s0,64(sp)
    800008c2:	74e2                	ld	s1,56(sp)
    800008c4:	7942                	ld	s2,48(sp)
    800008c6:	79a2                	ld	s3,40(sp)
    800008c8:	7a02                	ld	s4,32(sp)
    800008ca:	6ae2                	ld	s5,24(sp)
    800008cc:	6b42                	ld	s6,16(sp)
    800008ce:	6ba2                	ld	s7,8(sp)
    800008d0:	6161                	addi	sp,sp,80
    800008d2:	8082                	ret

00000000800008d4 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800008d4:	1101                	addi	sp,sp,-32
    800008d6:	ec06                	sd	ra,24(sp)
    800008d8:	e822                	sd	s0,16(sp)
    800008da:	e426                	sd	s1,8(sp)
    800008dc:	1000                	addi	s0,sp,32
    800008de:	84aa                	mv	s1,a0
  if(panicking == 0)
    800008e0:	00007797          	auipc	a5,0x7
    800008e4:	0647a783          	lw	a5,100(a5) # 80007944 <panicking>
    800008e8:	cb89                	beqz	a5,800008fa <uartputc_sync+0x26>
    push_off();

  if(panicked){
    800008ea:	00007797          	auipc	a5,0x7
    800008ee:	0567a783          	lw	a5,86(a5) # 80007940 <panicked>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800008f6:	c789                	beqz	a5,80000900 <uartputc_sync+0x2c>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc_sync+0x24>
    push_off();
    800008fa:	232000ef          	jal	ra,80000b2c <push_off>
    800008fe:	b7f5                	j	800008ea <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000900:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000904:	0207f793          	andi	a5,a5,32
    80000908:	dfe5                	beqz	a5,80000900 <uartputc_sync+0x2c>
    ;
  WriteReg(THR, c);
    8000090a:	0ff4f513          	andi	a0,s1,255
    8000090e:	100007b7          	lui	a5,0x10000
    80000912:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000916:	00007797          	auipc	a5,0x7
    8000091a:	02e7a783          	lw	a5,46(a5) # 80007944 <panicking>
    8000091e:	c791                	beqz	a5,8000092a <uartputc_sync+0x56>
    pop_off();
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    pop_off();
    8000092a:	286000ef          	jal	ra,80000bb0 <pop_off>
}
    8000092e:	bfcd                	j	80000920 <uartputc_sync+0x4c>

0000000080000930 <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000930:	1141                	addi	sp,sp,-16
    80000932:	e422                	sd	s0,8(sp)
    80000934:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000936:	100007b7          	lui	a5,0x10000
    8000093a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000093e:	8b85                	andi	a5,a5,1
    80000940:	cb91                	beqz	a5,80000954 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000942:	100007b7          	lui	a5,0x10000
    80000946:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000094a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000094e:	6422                	ld	s0,8(sp)
    80000950:	0141                	addi	sp,sp,16
    80000952:	8082                	ret
    return -1;
    80000954:	557d                	li	a0,-1
    80000956:	bfe5                	j	8000094e <uartgetc+0x1e>

0000000080000958 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000958:	1101                	addi	sp,sp,-32
    8000095a:	ec06                	sd	ra,24(sp)
    8000095c:	e822                	sd	s0,16(sp)
    8000095e:	e426                	sd	s1,8(sp)
    80000960:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000962:	100004b7          	lui	s1,0x10000
    80000966:	0024c783          	lbu	a5,2(s1) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    8000096a:	0000f517          	auipc	a0,0xf
    8000096e:	0d650513          	addi	a0,a0,214 # 8000fa40 <tx_lock>
    80000972:	1fa000ef          	jal	ra,80000b6c <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000976:	0054c783          	lbu	a5,5(s1)
    8000097a:	0207f793          	andi	a5,a5,32
    8000097e:	eb89                	bnez	a5,80000990 <uartintr+0x38>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000980:	0000f517          	auipc	a0,0xf
    80000984:	0c050513          	addi	a0,a0,192 # 8000fa40 <tx_lock>
    80000988:	27c000ef          	jal	ra,80000c04 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000098c:	54fd                	li	s1,-1
    8000098e:	a831                	j	800009aa <uartintr+0x52>
    tx_busy = 0;
    80000990:	00007797          	auipc	a5,0x7
    80000994:	fa07ae23          	sw	zero,-68(a5) # 8000794c <tx_busy>
    wakeup(&tx_chan);
    80000998:	00007517          	auipc	a0,0x7
    8000099c:	fb050513          	addi	a0,a0,-80 # 80007948 <tx_chan>
    800009a0:	5dc010ef          	jal	ra,80001f7c <wakeup>
    800009a4:	bff1                	j	80000980 <uartintr+0x28>
      break;
    consoleintr(c);
    800009a6:	8d5ff0ef          	jal	ra,8000027a <consoleintr>
    int c = uartgetc();
    800009aa:	f87ff0ef          	jal	ra,80000930 <uartgetc>
    if(c == -1)
    800009ae:	fe951ce3          	bne	a0,s1,800009a6 <uartintr+0x4e>
  }
}
    800009b2:	60e2                	ld	ra,24(sp)
    800009b4:	6442                	ld	s0,16(sp)
    800009b6:	64a2                	ld	s1,8(sp)
    800009b8:	6105                	addi	sp,sp,32
    800009ba:	8082                	ret

00000000800009bc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009bc:	1101                	addi	sp,sp,-32
    800009be:	ec06                	sd	ra,24(sp)
    800009c0:	e822                	sd	s0,16(sp)
    800009c2:	e426                	sd	s1,8(sp)
    800009c4:	e04a                	sd	s2,0(sp)
    800009c6:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009c8:	03451793          	slli	a5,a0,0x34
    800009cc:	e7a9                	bnez	a5,80000a16 <kfree+0x5a>
    800009ce:	84aa                	mv	s1,a0
    800009d0:	00020797          	auipc	a5,0x20
    800009d4:	6d078793          	addi	a5,a5,1744 # 800210a0 <end>
    800009d8:	02f56f63          	bltu	a0,a5,80000a16 <kfree+0x5a>
    800009dc:	47c5                	li	a5,17
    800009de:	07ee                	slli	a5,a5,0x1b
    800009e0:	02f57b63          	bgeu	a0,a5,80000a16 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009e4:	6605                	lui	a2,0x1
    800009e6:	4585                	li	a1,1
    800009e8:	258000ef          	jal	ra,80000c40 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800009ec:	0000f917          	auipc	s2,0xf
    800009f0:	06c90913          	addi	s2,s2,108 # 8000fa58 <kmem>
    800009f4:	854a                	mv	a0,s2
    800009f6:	176000ef          	jal	ra,80000b6c <acquire>
  r->next = kmem.freelist;
    800009fa:	01893783          	ld	a5,24(s2)
    800009fe:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a00:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a04:	854a                	mv	a0,s2
    80000a06:	1fe000ef          	jal	ra,80000c04 <release>
}
    80000a0a:	60e2                	ld	ra,24(sp)
    80000a0c:	6442                	ld	s0,16(sp)
    80000a0e:	64a2                	ld	s1,8(sp)
    80000a10:	6902                	ld	s2,0(sp)
    80000a12:	6105                	addi	sp,sp,32
    80000a14:	8082                	ret
    panic("kfree");
    80000a16:	00006517          	auipc	a0,0x6
    80000a1a:	64250513          	addi	a0,a0,1602 # 80007058 <digits+0x20>
    80000a1e:	d6dff0ef          	jal	ra,8000078a <panic>

0000000080000a22 <freerange>:
{
    80000a22:	7179                	addi	sp,sp,-48
    80000a24:	f406                	sd	ra,40(sp)
    80000a26:	f022                	sd	s0,32(sp)
    80000a28:	ec26                	sd	s1,24(sp)
    80000a2a:	e84a                	sd	s2,16(sp)
    80000a2c:	e44e                	sd	s3,8(sp)
    80000a2e:	e052                	sd	s4,0(sp)
    80000a30:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a32:	6785                	lui	a5,0x1
    80000a34:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a38:	94aa                	add	s1,s1,a0
    80000a3a:	757d                	lui	a0,0xfffff
    80000a3c:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a3e:	94be                	add	s1,s1,a5
    80000a40:	0095ec63          	bltu	a1,s1,80000a58 <freerange+0x36>
    80000a44:	892e                	mv	s2,a1
    kfree(p);
    80000a46:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a48:	6985                	lui	s3,0x1
    kfree(p);
    80000a4a:	01448533          	add	a0,s1,s4
    80000a4e:	f6fff0ef          	jal	ra,800009bc <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a52:	94ce                	add	s1,s1,s3
    80000a54:	fe997be3          	bgeu	s2,s1,80000a4a <freerange+0x28>
}
    80000a58:	70a2                	ld	ra,40(sp)
    80000a5a:	7402                	ld	s0,32(sp)
    80000a5c:	64e2                	ld	s1,24(sp)
    80000a5e:	6942                	ld	s2,16(sp)
    80000a60:	69a2                	ld	s3,8(sp)
    80000a62:	6a02                	ld	s4,0(sp)
    80000a64:	6145                	addi	sp,sp,48
    80000a66:	8082                	ret

0000000080000a68 <kinit>:
{
    80000a68:	1141                	addi	sp,sp,-16
    80000a6a:	e406                	sd	ra,8(sp)
    80000a6c:	e022                	sd	s0,0(sp)
    80000a6e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a70:	00006597          	auipc	a1,0x6
    80000a74:	5f058593          	addi	a1,a1,1520 # 80007060 <digits+0x28>
    80000a78:	0000f517          	auipc	a0,0xf
    80000a7c:	fe050513          	addi	a0,a0,-32 # 8000fa58 <kmem>
    80000a80:	06c000ef          	jal	ra,80000aec <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a84:	45c5                	li	a1,17
    80000a86:	05ee                	slli	a1,a1,0x1b
    80000a88:	00020517          	auipc	a0,0x20
    80000a8c:	61850513          	addi	a0,a0,1560 # 800210a0 <end>
    80000a90:	f93ff0ef          	jal	ra,80000a22 <freerange>
}
    80000a94:	60a2                	ld	ra,8(sp)
    80000a96:	6402                	ld	s0,0(sp)
    80000a98:	0141                	addi	sp,sp,16
    80000a9a:	8082                	ret

0000000080000a9c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a9c:	1101                	addi	sp,sp,-32
    80000a9e:	ec06                	sd	ra,24(sp)
    80000aa0:	e822                	sd	s0,16(sp)
    80000aa2:	e426                	sd	s1,8(sp)
    80000aa4:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aa6:	0000f497          	auipc	s1,0xf
    80000aaa:	fb248493          	addi	s1,s1,-78 # 8000fa58 <kmem>
    80000aae:	8526                	mv	a0,s1
    80000ab0:	0bc000ef          	jal	ra,80000b6c <acquire>
  r = kmem.freelist;
    80000ab4:	6c84                	ld	s1,24(s1)
  if(r)
    80000ab6:	c485                	beqz	s1,80000ade <kalloc+0x42>
    kmem.freelist = r->next;
    80000ab8:	609c                	ld	a5,0(s1)
    80000aba:	0000f517          	auipc	a0,0xf
    80000abe:	f9e50513          	addi	a0,a0,-98 # 8000fa58 <kmem>
    80000ac2:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000ac4:	140000ef          	jal	ra,80000c04 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ac8:	6605                	lui	a2,0x1
    80000aca:	4595                	li	a1,5
    80000acc:	8526                	mv	a0,s1
    80000ace:	172000ef          	jal	ra,80000c40 <memset>
  return (void*)r;
}
    80000ad2:	8526                	mv	a0,s1
    80000ad4:	60e2                	ld	ra,24(sp)
    80000ad6:	6442                	ld	s0,16(sp)
    80000ad8:	64a2                	ld	s1,8(sp)
    80000ada:	6105                	addi	sp,sp,32
    80000adc:	8082                	ret
  release(&kmem.lock);
    80000ade:	0000f517          	auipc	a0,0xf
    80000ae2:	f7a50513          	addi	a0,a0,-134 # 8000fa58 <kmem>
    80000ae6:	11e000ef          	jal	ra,80000c04 <release>
  if(r)
    80000aea:	b7e5                	j	80000ad2 <kalloc+0x36>

0000000080000aec <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000aec:	1141                	addi	sp,sp,-16
    80000aee:	e422                	sd	s0,8(sp)
    80000af0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000af2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000af4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000af8:	00053823          	sd	zero,16(a0)
}
    80000afc:	6422                	ld	s0,8(sp)
    80000afe:	0141                	addi	sp,sp,16
    80000b00:	8082                	ret

0000000080000b02 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b02:	411c                	lw	a5,0(a0)
    80000b04:	e399                	bnez	a5,80000b0a <holding+0x8>
    80000b06:	4501                	li	a0,0
  return r;
}
    80000b08:	8082                	ret
{
    80000b0a:	1101                	addi	sp,sp,-32
    80000b0c:	ec06                	sd	ra,24(sp)
    80000b0e:	e822                	sd	s0,16(sp)
    80000b10:	e426                	sd	s1,8(sp)
    80000b12:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b14:	6904                	ld	s1,16(a0)
    80000b16:	4e7000ef          	jal	ra,800017fc <mycpu>
    80000b1a:	40a48533          	sub	a0,s1,a0
    80000b1e:	00153513          	seqz	a0,a0
}
    80000b22:	60e2                	ld	ra,24(sp)
    80000b24:	6442                	ld	s0,16(sp)
    80000b26:	64a2                	ld	s1,8(sp)
    80000b28:	6105                	addi	sp,sp,32
    80000b2a:	8082                	ret

0000000080000b2c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b2c:	1101                	addi	sp,sp,-32
    80000b2e:	ec06                	sd	ra,24(sp)
    80000b30:	e822                	sd	s0,16(sp)
    80000b32:	e426                	sd	s1,8(sp)
    80000b34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b36:	100024f3          	csrr	s1,sstatus
    80000b3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b3e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b40:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000b44:	4b9000ef          	jal	ra,800017fc <mycpu>
    80000b48:	5d3c                	lw	a5,120(a0)
    80000b4a:	cb99                	beqz	a5,80000b60 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b4c:	4b1000ef          	jal	ra,800017fc <mycpu>
    80000b50:	5d3c                	lw	a5,120(a0)
    80000b52:	2785                	addiw	a5,a5,1
    80000b54:	dd3c                	sw	a5,120(a0)
}
    80000b56:	60e2                	ld	ra,24(sp)
    80000b58:	6442                	ld	s0,16(sp)
    80000b5a:	64a2                	ld	s1,8(sp)
    80000b5c:	6105                	addi	sp,sp,32
    80000b5e:	8082                	ret
    mycpu()->intena = old;
    80000b60:	49d000ef          	jal	ra,800017fc <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b64:	8085                	srli	s1,s1,0x1
    80000b66:	8885                	andi	s1,s1,1
    80000b68:	dd64                	sw	s1,124(a0)
    80000b6a:	b7cd                	j	80000b4c <push_off+0x20>

0000000080000b6c <acquire>:
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
    80000b76:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b78:	fb5ff0ef          	jal	ra,80000b2c <push_off>
  if(holding(lk))
    80000b7c:	8526                	mv	a0,s1
    80000b7e:	f85ff0ef          	jal	ra,80000b02 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b82:	4705                	li	a4,1
  if(holding(lk))
    80000b84:	e105                	bnez	a0,80000ba4 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000b86:	87ba                	mv	a5,a4
    80000b88:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b8c:	2781                	sext.w	a5,a5
    80000b8e:	ffe5                	bnez	a5,80000b86 <acquire+0x1a>
  __sync_synchronize();
    80000b90:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b94:	469000ef          	jal	ra,800017fc <mycpu>
    80000b98:	e888                	sd	a0,16(s1)
}
    80000b9a:	60e2                	ld	ra,24(sp)
    80000b9c:	6442                	ld	s0,16(sp)
    80000b9e:	64a2                	ld	s1,8(sp)
    80000ba0:	6105                	addi	sp,sp,32
    80000ba2:	8082                	ret
    panic("acquire");
    80000ba4:	00006517          	auipc	a0,0x6
    80000ba8:	4c450513          	addi	a0,a0,1220 # 80007068 <digits+0x30>
    80000bac:	bdfff0ef          	jal	ra,8000078a <panic>

0000000080000bb0 <pop_off>:

void
pop_off(void)
{
    80000bb0:	1141                	addi	sp,sp,-16
    80000bb2:	e406                	sd	ra,8(sp)
    80000bb4:	e022                	sd	s0,0(sp)
    80000bb6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bb8:	445000ef          	jal	ra,800017fc <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bc0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bc2:	e78d                	bnez	a5,80000bec <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	02f05963          	blez	a5,80000bf8 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bca:	37fd                	addiw	a5,a5,-1
    80000bcc:	0007871b          	sext.w	a4,a5
    80000bd0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000bd2:	eb09                	bnez	a4,80000be4 <pop_off+0x34>
    80000bd4:	5d7c                	lw	a5,124(a0)
    80000bd6:	c799                	beqz	a5,80000be4 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000bdc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000be0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000be4:	60a2                	ld	ra,8(sp)
    80000be6:	6402                	ld	s0,0(sp)
    80000be8:	0141                	addi	sp,sp,16
    80000bea:	8082                	ret
    panic("pop_off - interruptible");
    80000bec:	00006517          	auipc	a0,0x6
    80000bf0:	48450513          	addi	a0,a0,1156 # 80007070 <digits+0x38>
    80000bf4:	b97ff0ef          	jal	ra,8000078a <panic>
    panic("pop_off");
    80000bf8:	00006517          	auipc	a0,0x6
    80000bfc:	49050513          	addi	a0,a0,1168 # 80007088 <digits+0x50>
    80000c00:	b8bff0ef          	jal	ra,8000078a <panic>

0000000080000c04 <release>:
{
    80000c04:	1101                	addi	sp,sp,-32
    80000c06:	ec06                	sd	ra,24(sp)
    80000c08:	e822                	sd	s0,16(sp)
    80000c0a:	e426                	sd	s1,8(sp)
    80000c0c:	1000                	addi	s0,sp,32
    80000c0e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c10:	ef3ff0ef          	jal	ra,80000b02 <holding>
    80000c14:	c105                	beqz	a0,80000c34 <release+0x30>
  lk->cpu = 0;
    80000c16:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c1a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c1e:	0f50000f          	fence	iorw,ow
    80000c22:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c26:	f8bff0ef          	jal	ra,80000bb0 <pop_off>
}
    80000c2a:	60e2                	ld	ra,24(sp)
    80000c2c:	6442                	ld	s0,16(sp)
    80000c2e:	64a2                	ld	s1,8(sp)
    80000c30:	6105                	addi	sp,sp,32
    80000c32:	8082                	ret
    panic("release");
    80000c34:	00006517          	auipc	a0,0x6
    80000c38:	45c50513          	addi	a0,a0,1116 # 80007090 <digits+0x58>
    80000c3c:	b4fff0ef          	jal	ra,8000078a <panic>

0000000080000c40 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c40:	1141                	addi	sp,sp,-16
    80000c42:	e422                	sd	s0,8(sp)
    80000c44:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c46:	ca19                	beqz	a2,80000c5c <memset+0x1c>
    80000c48:	87aa                	mv	a5,a0
    80000c4a:	1602                	slli	a2,a2,0x20
    80000c4c:	9201                	srli	a2,a2,0x20
    80000c4e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c52:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c56:	0785                	addi	a5,a5,1
    80000c58:	fee79de3          	bne	a5,a4,80000c52 <memset+0x12>
  }
  return dst;
}
    80000c5c:	6422                	ld	s0,8(sp)
    80000c5e:	0141                	addi	sp,sp,16
    80000c60:	8082                	ret

0000000080000c62 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c62:	1141                	addi	sp,sp,-16
    80000c64:	e422                	sd	s0,8(sp)
    80000c66:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c68:	ca05                	beqz	a2,80000c98 <memcmp+0x36>
    80000c6a:	fff6069b          	addiw	a3,a2,-1
    80000c6e:	1682                	slli	a3,a3,0x20
    80000c70:	9281                	srli	a3,a3,0x20
    80000c72:	0685                	addi	a3,a3,1
    80000c74:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c76:	00054783          	lbu	a5,0(a0)
    80000c7a:	0005c703          	lbu	a4,0(a1)
    80000c7e:	00e79863          	bne	a5,a4,80000c8e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c82:	0505                	addi	a0,a0,1
    80000c84:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000c86:	fed518e3          	bne	a0,a3,80000c76 <memcmp+0x14>
  }

  return 0;
    80000c8a:	4501                	li	a0,0
    80000c8c:	a019                	j	80000c92 <memcmp+0x30>
      return *s1 - *s2;
    80000c8e:	40e7853b          	subw	a0,a5,a4
}
    80000c92:	6422                	ld	s0,8(sp)
    80000c94:	0141                	addi	sp,sp,16
    80000c96:	8082                	ret
  return 0;
    80000c98:	4501                	li	a0,0
    80000c9a:	bfe5                	j	80000c92 <memcmp+0x30>

0000000080000c9c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000c9c:	1141                	addi	sp,sp,-16
    80000c9e:	e422                	sd	s0,8(sp)
    80000ca0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ca2:	c205                	beqz	a2,80000cc2 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ca4:	02a5e263          	bltu	a1,a0,80000cc8 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ca8:	1602                	slli	a2,a2,0x20
    80000caa:	9201                	srli	a2,a2,0x20
    80000cac:	00c587b3          	add	a5,a1,a2
{
    80000cb0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cb2:	0585                	addi	a1,a1,1
    80000cb4:	0705                	addi	a4,a4,1
    80000cb6:	fff5c683          	lbu	a3,-1(a1)
    80000cba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000cbe:	fef59ae3          	bne	a1,a5,80000cb2 <memmove+0x16>

  return dst;
}
    80000cc2:	6422                	ld	s0,8(sp)
    80000cc4:	0141                	addi	sp,sp,16
    80000cc6:	8082                	ret
  if(s < d && s + n > d){
    80000cc8:	02061693          	slli	a3,a2,0x20
    80000ccc:	9281                	srli	a3,a3,0x20
    80000cce:	00d58733          	add	a4,a1,a3
    80000cd2:	fce57be3          	bgeu	a0,a4,80000ca8 <memmove+0xc>
    d += n;
    80000cd6:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000cd8:	fff6079b          	addiw	a5,a2,-1
    80000cdc:	1782                	slli	a5,a5,0x20
    80000cde:	9381                	srli	a5,a5,0x20
    80000ce0:	fff7c793          	not	a5,a5
    80000ce4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ce6:	177d                	addi	a4,a4,-1
    80000ce8:	16fd                	addi	a3,a3,-1
    80000cea:	00074603          	lbu	a2,0(a4)
    80000cee:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000cf2:	fee79ae3          	bne	a5,a4,80000ce6 <memmove+0x4a>
    80000cf6:	b7f1                	j	80000cc2 <memmove+0x26>

0000000080000cf8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d00:	f9dff0ef          	jal	ra,80000c9c <memmove>
}
    80000d04:	60a2                	ld	ra,8(sp)
    80000d06:	6402                	ld	s0,0(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d12:	ce11                	beqz	a2,80000d2e <strncmp+0x22>
    80000d14:	00054783          	lbu	a5,0(a0)
    80000d18:	cf89                	beqz	a5,80000d32 <strncmp+0x26>
    80000d1a:	0005c703          	lbu	a4,0(a1)
    80000d1e:	00f71a63          	bne	a4,a5,80000d32 <strncmp+0x26>
    n--, p++, q++;
    80000d22:	367d                	addiw	a2,a2,-1
    80000d24:	0505                	addi	a0,a0,1
    80000d26:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d28:	f675                	bnez	a2,80000d14 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	a809                	j	80000d3e <strncmp+0x32>
    80000d2e:	4501                	li	a0,0
    80000d30:	a039                	j	80000d3e <strncmp+0x32>
  if(n == 0)
    80000d32:	ca09                	beqz	a2,80000d44 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d34:	00054503          	lbu	a0,0(a0)
    80000d38:	0005c783          	lbu	a5,0(a1)
    80000d3c:	9d1d                	subw	a0,a0,a5
}
    80000d3e:	6422                	ld	s0,8(sp)
    80000d40:	0141                	addi	sp,sp,16
    80000d42:	8082                	ret
    return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	bfe5                	j	80000d3e <strncmp+0x32>

0000000080000d48 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d48:	1141                	addi	sp,sp,-16
    80000d4a:	e422                	sd	s0,8(sp)
    80000d4c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d4e:	872a                	mv	a4,a0
    80000d50:	8832                	mv	a6,a2
    80000d52:	367d                	addiw	a2,a2,-1
    80000d54:	01005963          	blez	a6,80000d66 <strncpy+0x1e>
    80000d58:	0705                	addi	a4,a4,1
    80000d5a:	0005c783          	lbu	a5,0(a1)
    80000d5e:	fef70fa3          	sb	a5,-1(a4)
    80000d62:	0585                	addi	a1,a1,1
    80000d64:	f7f5                	bnez	a5,80000d50 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d66:	86ba                	mv	a3,a4
    80000d68:	00c05c63          	blez	a2,80000d80 <strncpy+0x38>
    *s++ = 0;
    80000d6c:	0685                	addi	a3,a3,1
    80000d6e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d72:	fff6c793          	not	a5,a3
    80000d76:	9fb9                	addw	a5,a5,a4
    80000d78:	010787bb          	addw	a5,a5,a6
    80000d7c:	fef048e3          	bgtz	a5,80000d6c <strncpy+0x24>
  return os;
}
    80000d80:	6422                	ld	s0,8(sp)
    80000d82:	0141                	addi	sp,sp,16
    80000d84:	8082                	ret

0000000080000d86 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e422                	sd	s0,8(sp)
    80000d8a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000d8c:	02c05363          	blez	a2,80000db2 <safestrcpy+0x2c>
    80000d90:	fff6069b          	addiw	a3,a2,-1
    80000d94:	1682                	slli	a3,a3,0x20
    80000d96:	9281                	srli	a3,a3,0x20
    80000d98:	96ae                	add	a3,a3,a1
    80000d9a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000d9c:	00d58963          	beq	a1,a3,80000dae <safestrcpy+0x28>
    80000da0:	0585                	addi	a1,a1,1
    80000da2:	0785                	addi	a5,a5,1
    80000da4:	fff5c703          	lbu	a4,-1(a1)
    80000da8:	fee78fa3          	sb	a4,-1(a5)
    80000dac:	fb65                	bnez	a4,80000d9c <safestrcpy+0x16>
    ;
  *s = 0;
    80000dae:	00078023          	sb	zero,0(a5)
  return os;
}
    80000db2:	6422                	ld	s0,8(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strlen>:

int
strlen(const char *s)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dbe:	00054783          	lbu	a5,0(a0)
    80000dc2:	cf91                	beqz	a5,80000dde <strlen+0x26>
    80000dc4:	0505                	addi	a0,a0,1
    80000dc6:	87aa                	mv	a5,a0
    80000dc8:	4685                	li	a3,1
    80000dca:	9e89                	subw	a3,a3,a0
    80000dcc:	00f6853b          	addw	a0,a3,a5
    80000dd0:	0785                	addi	a5,a5,1
    80000dd2:	fff7c703          	lbu	a4,-1(a5)
    80000dd6:	fb7d                	bnez	a4,80000dcc <strlen+0x14>
    ;
  return n;
}
    80000dd8:	6422                	ld	s0,8(sp)
    80000dda:	0141                	addi	sp,sp,16
    80000ddc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000dde:	4501                	li	a0,0
    80000de0:	bfe5                	j	80000dd8 <strlen+0x20>

0000000080000de2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000de2:	1141                	addi	sp,sp,-16
    80000de4:	e406                	sd	ra,8(sp)
    80000de6:	e022                	sd	s0,0(sp)
    80000de8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000dea:	203000ef          	jal	ra,800017ec <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000dee:	00007717          	auipc	a4,0x7
    80000df2:	b6270713          	addi	a4,a4,-1182 # 80007950 <started>
  if(cpuid() == 0){
    80000df6:	c51d                	beqz	a0,80000e24 <main+0x42>
    while(started == 0)
    80000df8:	431c                	lw	a5,0(a4)
    80000dfa:	2781                	sext.w	a5,a5
    80000dfc:	dff5                	beqz	a5,80000df8 <main+0x16>
      ;
    __sync_synchronize();
    80000dfe:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e02:	1eb000ef          	jal	ra,800017ec <cpuid>
    80000e06:	85aa                	mv	a1,a0
    80000e08:	00006517          	auipc	a0,0x6
    80000e0c:	2a850513          	addi	a0,a0,680 # 800070b0 <digits+0x78>
    80000e10:	eb4ff0ef          	jal	ra,800004c4 <printf>
    kvminithart();    // turn on paging
    80000e14:	080000ef          	jal	ra,80000e94 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e18:	638010ef          	jal	ra,80002450 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e1c:	5e8040ef          	jal	ra,80005404 <plicinithart>
  }

  scheduler();        
    80000e20:	713000ef          	jal	ra,80001d32 <scheduler>
    consoleinit();
    80000e24:	dc8ff0ef          	jal	ra,800003ec <consoleinit>
    printfinit();
    80000e28:	99fff0ef          	jal	ra,800007c6 <printfinit>
    printf("\n");
    80000e2c:	00006517          	auipc	a0,0x6
    80000e30:	29450513          	addi	a0,a0,660 # 800070c0 <digits+0x88>
    80000e34:	e90ff0ef          	jal	ra,800004c4 <printf>
    printf("xv6 kernel is booting\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	26050513          	addi	a0,a0,608 # 80007098 <digits+0x60>
    80000e40:	e84ff0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	27c50513          	addi	a0,a0,636 # 800070c0 <digits+0x88>
    80000e4c:	e78ff0ef          	jal	ra,800004c4 <printf>
    kinit();         // physical page allocator
    80000e50:	c19ff0ef          	jal	ra,80000a68 <kinit>
    kvminit();       // create kernel page table
    80000e54:	2ca000ef          	jal	ra,8000111e <kvminit>
    kvminithart();   // turn on paging
    80000e58:	03c000ef          	jal	ra,80000e94 <kvminithart>
    procinit();      // process table
    80000e5c:	0d5000ef          	jal	ra,80001730 <procinit>
    trapinit();      // trap vectors
    80000e60:	5cc010ef          	jal	ra,8000242c <trapinit>
    trapinithart();  // install kernel trap vector
    80000e64:	5ec010ef          	jal	ra,80002450 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e68:	586040ef          	jal	ra,800053ee <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e6c:	598040ef          	jal	ra,80005404 <plicinithart>
    binit();         // buffer cache
    80000e70:	53d010ef          	jal	ra,80002bac <binit>
    iinit();         // inode table
    80000e74:	2b0020ef          	jal	ra,80003124 <iinit>
    fileinit();      // file table
    80000e78:	190030ef          	jal	ra,80004008 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e7c:	678040ef          	jal	ra,800054f4 <virtio_disk_init>
    userinit();      // first user process
    80000e80:	46b000ef          	jal	ra,80001aea <userinit>
    __sync_synchronize();
    80000e84:	0ff0000f          	fence
    started = 1;
    80000e88:	4785                	li	a5,1
    80000e8a:	00007717          	auipc	a4,0x7
    80000e8e:	acf72323          	sw	a5,-1338(a4) # 80007950 <started>
    80000e92:	b779                	j	80000e20 <main+0x3e>

0000000080000e94 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e422                	sd	s0,8(sp)
    80000e98:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000e9a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000e9e:	00007797          	auipc	a5,0x7
    80000ea2:	aba7b783          	ld	a5,-1350(a5) # 80007958 <kernel_pagetable>
    80000ea6:	83b1                	srli	a5,a5,0xc
    80000ea8:	577d                	li	a4,-1
    80000eaa:	177e                	slli	a4,a4,0x3f
    80000eac:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000eae:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000eb2:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000eb6:	6422                	ld	s0,8(sp)
    80000eb8:	0141                	addi	sp,sp,16
    80000eba:	8082                	ret

0000000080000ebc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ebc:	7139                	addi	sp,sp,-64
    80000ebe:	fc06                	sd	ra,56(sp)
    80000ec0:	f822                	sd	s0,48(sp)
    80000ec2:	f426                	sd	s1,40(sp)
    80000ec4:	f04a                	sd	s2,32(sp)
    80000ec6:	ec4e                	sd	s3,24(sp)
    80000ec8:	e852                	sd	s4,16(sp)
    80000eca:	e456                	sd	s5,8(sp)
    80000ecc:	e05a                	sd	s6,0(sp)
    80000ece:	0080                	addi	s0,sp,64
    80000ed0:	84aa                	mv	s1,a0
    80000ed2:	89ae                	mv	s3,a1
    80000ed4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ed6:	57fd                	li	a5,-1
    80000ed8:	83e9                	srli	a5,a5,0x1a
    80000eda:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000edc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ede:	02b7fc63          	bgeu	a5,a1,80000f16 <walk+0x5a>
    panic("walk");
    80000ee2:	00006517          	auipc	a0,0x6
    80000ee6:	1e650513          	addi	a0,a0,486 # 800070c8 <digits+0x90>
    80000eea:	8a1ff0ef          	jal	ra,8000078a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000eee:	060a8263          	beqz	s5,80000f52 <walk+0x96>
    80000ef2:	babff0ef          	jal	ra,80000a9c <kalloc>
    80000ef6:	84aa                	mv	s1,a0
    80000ef8:	c139                	beqz	a0,80000f3e <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000efa:	6605                	lui	a2,0x1
    80000efc:	4581                	li	a1,0
    80000efe:	d43ff0ef          	jal	ra,80000c40 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f02:	00c4d793          	srli	a5,s1,0xc
    80000f06:	07aa                	slli	a5,a5,0xa
    80000f08:	0017e793          	ori	a5,a5,1
    80000f0c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f10:	3a5d                	addiw	s4,s4,-9
    80000f12:	036a0063          	beq	s4,s6,80000f32 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f16:	0149d933          	srl	s2,s3,s4
    80000f1a:	1ff97913          	andi	s2,s2,511
    80000f1e:	090e                	slli	s2,s2,0x3
    80000f20:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f22:	00093483          	ld	s1,0(s2)
    80000f26:	0014f793          	andi	a5,s1,1
    80000f2a:	d3f1                	beqz	a5,80000eee <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f2c:	80a9                	srli	s1,s1,0xa
    80000f2e:	04b2                	slli	s1,s1,0xc
    80000f30:	b7c5                	j	80000f10 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f32:	00c9d513          	srli	a0,s3,0xc
    80000f36:	1ff57513          	andi	a0,a0,511
    80000f3a:	050e                	slli	a0,a0,0x3
    80000f3c:	9526                	add	a0,a0,s1
}
    80000f3e:	70e2                	ld	ra,56(sp)
    80000f40:	7442                	ld	s0,48(sp)
    80000f42:	74a2                	ld	s1,40(sp)
    80000f44:	7902                	ld	s2,32(sp)
    80000f46:	69e2                	ld	s3,24(sp)
    80000f48:	6a42                	ld	s4,16(sp)
    80000f4a:	6aa2                	ld	s5,8(sp)
    80000f4c:	6b02                	ld	s6,0(sp)
    80000f4e:	6121                	addi	sp,sp,64
    80000f50:	8082                	ret
        return 0;
    80000f52:	4501                	li	a0,0
    80000f54:	b7ed                	j	80000f3e <walk+0x82>

0000000080000f56 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	00b7f463          	bgeu	a5,a1,80000f62 <walkaddr+0xc>
    return 0;
    80000f5e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f60:	8082                	ret
{
    80000f62:	1141                	addi	sp,sp,-16
    80000f64:	e406                	sd	ra,8(sp)
    80000f66:	e022                	sd	s0,0(sp)
    80000f68:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f6a:	4601                	li	a2,0
    80000f6c:	f51ff0ef          	jal	ra,80000ebc <walk>
  if(pte == 0)
    80000f70:	c105                	beqz	a0,80000f90 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000f72:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f74:	0117f693          	andi	a3,a5,17
    80000f78:	4745                	li	a4,17
    return 0;
    80000f7a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000f7c:	00e68663          	beq	a3,a4,80000f88 <walkaddr+0x32>
}
    80000f80:	60a2                	ld	ra,8(sp)
    80000f82:	6402                	ld	s0,0(sp)
    80000f84:	0141                	addi	sp,sp,16
    80000f86:	8082                	ret
  pa = PTE2PA(*pte);
    80000f88:	00a7d513          	srli	a0,a5,0xa
    80000f8c:	0532                	slli	a0,a0,0xc
  return pa;
    80000f8e:	bfcd                	j	80000f80 <walkaddr+0x2a>
    return 0;
    80000f90:	4501                	li	a0,0
    80000f92:	b7fd                	j	80000f80 <walkaddr+0x2a>

0000000080000f94 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000f94:	715d                	addi	sp,sp,-80
    80000f96:	e486                	sd	ra,72(sp)
    80000f98:	e0a2                	sd	s0,64(sp)
    80000f9a:	fc26                	sd	s1,56(sp)
    80000f9c:	f84a                	sd	s2,48(sp)
    80000f9e:	f44e                	sd	s3,40(sp)
    80000fa0:	f052                	sd	s4,32(sp)
    80000fa2:	ec56                	sd	s5,24(sp)
    80000fa4:	e85a                	sd	s6,16(sp)
    80000fa6:	e45e                	sd	s7,8(sp)
    80000fa8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000faa:	03459793          	slli	a5,a1,0x34
    80000fae:	e7a9                	bnez	a5,80000ff8 <mappages+0x64>
    80000fb0:	8aaa                	mv	s5,a0
    80000fb2:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fb4:	03461793          	slli	a5,a2,0x34
    80000fb8:	e7b1                	bnez	a5,80001004 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fba:	ca39                	beqz	a2,80001010 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fbc:	79fd                	lui	s3,0xfffff
    80000fbe:	964e                	add	a2,a2,s3
    80000fc0:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fc4:	892e                	mv	s2,a1
    80000fc6:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000fca:	6b85                	lui	s7,0x1
    80000fcc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000fd0:	4605                	li	a2,1
    80000fd2:	85ca                	mv	a1,s2
    80000fd4:	8556                	mv	a0,s5
    80000fd6:	ee7ff0ef          	jal	ra,80000ebc <walk>
    80000fda:	c539                	beqz	a0,80001028 <mappages+0x94>
    if(*pte & PTE_V)
    80000fdc:	611c                	ld	a5,0(a0)
    80000fde:	8b85                	andi	a5,a5,1
    80000fe0:	ef95                	bnez	a5,8000101c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000fe2:	80b1                	srli	s1,s1,0xc
    80000fe4:	04aa                	slli	s1,s1,0xa
    80000fe6:	0164e4b3          	or	s1,s1,s6
    80000fea:	0014e493          	ori	s1,s1,1
    80000fee:	e104                	sd	s1,0(a0)
    if(a == last)
    80000ff0:	05390863          	beq	s2,s3,80001040 <mappages+0xac>
    a += PGSIZE;
    80000ff4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000ff6:	bfd9                	j	80000fcc <mappages+0x38>
    panic("mappages: va not aligned");
    80000ff8:	00006517          	auipc	a0,0x6
    80000ffc:	0d850513          	addi	a0,a0,216 # 800070d0 <digits+0x98>
    80001000:	f8aff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size not aligned");
    80001004:	00006517          	auipc	a0,0x6
    80001008:	0ec50513          	addi	a0,a0,236 # 800070f0 <digits+0xb8>
    8000100c:	f7eff0ef          	jal	ra,8000078a <panic>
    panic("mappages: size");
    80001010:	00006517          	auipc	a0,0x6
    80001014:	10050513          	addi	a0,a0,256 # 80007110 <digits+0xd8>
    80001018:	f72ff0ef          	jal	ra,8000078a <panic>
      panic("mappages: remap");
    8000101c:	00006517          	auipc	a0,0x6
    80001020:	10450513          	addi	a0,a0,260 # 80007120 <digits+0xe8>
    80001024:	f66ff0ef          	jal	ra,8000078a <panic>
      return -1;
    80001028:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000102a:	60a6                	ld	ra,72(sp)
    8000102c:	6406                	ld	s0,64(sp)
    8000102e:	74e2                	ld	s1,56(sp)
    80001030:	7942                	ld	s2,48(sp)
    80001032:	79a2                	ld	s3,40(sp)
    80001034:	7a02                	ld	s4,32(sp)
    80001036:	6ae2                	ld	s5,24(sp)
    80001038:	6b42                	ld	s6,16(sp)
    8000103a:	6ba2                	ld	s7,8(sp)
    8000103c:	6161                	addi	sp,sp,80
    8000103e:	8082                	ret
  return 0;
    80001040:	4501                	li	a0,0
    80001042:	b7e5                	j	8000102a <mappages+0x96>

0000000080001044 <kvmmap>:
{
    80001044:	1141                	addi	sp,sp,-16
    80001046:	e406                	sd	ra,8(sp)
    80001048:	e022                	sd	s0,0(sp)
    8000104a:	0800                	addi	s0,sp,16
    8000104c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000104e:	86b2                	mv	a3,a2
    80001050:	863e                	mv	a2,a5
    80001052:	f43ff0ef          	jal	ra,80000f94 <mappages>
    80001056:	e509                	bnez	a0,80001060 <kvmmap+0x1c>
}
    80001058:	60a2                	ld	ra,8(sp)
    8000105a:	6402                	ld	s0,0(sp)
    8000105c:	0141                	addi	sp,sp,16
    8000105e:	8082                	ret
    panic("kvmmap");
    80001060:	00006517          	auipc	a0,0x6
    80001064:	0d050513          	addi	a0,a0,208 # 80007130 <digits+0xf8>
    80001068:	f22ff0ef          	jal	ra,8000078a <panic>

000000008000106c <kvmmake>:
{
    8000106c:	1101                	addi	sp,sp,-32
    8000106e:	ec06                	sd	ra,24(sp)
    80001070:	e822                	sd	s0,16(sp)
    80001072:	e426                	sd	s1,8(sp)
    80001074:	e04a                	sd	s2,0(sp)
    80001076:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001078:	a25ff0ef          	jal	ra,80000a9c <kalloc>
    8000107c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000107e:	6605                	lui	a2,0x1
    80001080:	4581                	li	a1,0
    80001082:	bbfff0ef          	jal	ra,80000c40 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001086:	4719                	li	a4,6
    80001088:	6685                	lui	a3,0x1
    8000108a:	10000637          	lui	a2,0x10000
    8000108e:	100005b7          	lui	a1,0x10000
    80001092:	8526                	mv	a0,s1
    80001094:	fb1ff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001098:	4719                	li	a4,6
    8000109a:	6685                	lui	a3,0x1
    8000109c:	10001637          	lui	a2,0x10001
    800010a0:	100015b7          	lui	a1,0x10001
    800010a4:	8526                	mv	a0,s1
    800010a6:	f9fff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010aa:	4719                	li	a4,6
    800010ac:	040006b7          	lui	a3,0x4000
    800010b0:	0c000637          	lui	a2,0xc000
    800010b4:	0c0005b7          	lui	a1,0xc000
    800010b8:	8526                	mv	a0,s1
    800010ba:	f8bff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010be:	00006917          	auipc	s2,0x6
    800010c2:	f4290913          	addi	s2,s2,-190 # 80007000 <etext>
    800010c6:	4729                	li	a4,10
    800010c8:	80006697          	auipc	a3,0x80006
    800010cc:	f3868693          	addi	a3,a3,-200 # 7000 <_entry-0x7fff9000>
    800010d0:	4605                	li	a2,1
    800010d2:	067e                	slli	a2,a2,0x1f
    800010d4:	85b2                	mv	a1,a2
    800010d6:	8526                	mv	a0,s1
    800010d8:	f6dff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800010dc:	4719                	li	a4,6
    800010de:	46c5                	li	a3,17
    800010e0:	06ee                	slli	a3,a3,0x1b
    800010e2:	412686b3          	sub	a3,a3,s2
    800010e6:	864a                	mv	a2,s2
    800010e8:	85ca                	mv	a1,s2
    800010ea:	8526                	mv	a0,s1
    800010ec:	f59ff0ef          	jal	ra,80001044 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800010f0:	4729                	li	a4,10
    800010f2:	6685                	lui	a3,0x1
    800010f4:	00005617          	auipc	a2,0x5
    800010f8:	f0c60613          	addi	a2,a2,-244 # 80006000 <_trampoline>
    800010fc:	040005b7          	lui	a1,0x4000
    80001100:	15fd                	addi	a1,a1,-1
    80001102:	05b2                	slli	a1,a1,0xc
    80001104:	8526                	mv	a0,s1
    80001106:	f3fff0ef          	jal	ra,80001044 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000110a:	8526                	mv	a0,s1
    8000110c:	59a000ef          	jal	ra,800016a6 <proc_mapstacks>
}
    80001110:	8526                	mv	a0,s1
    80001112:	60e2                	ld	ra,24(sp)
    80001114:	6442                	ld	s0,16(sp)
    80001116:	64a2                	ld	s1,8(sp)
    80001118:	6902                	ld	s2,0(sp)
    8000111a:	6105                	addi	sp,sp,32
    8000111c:	8082                	ret

000000008000111e <kvminit>:
{
    8000111e:	1141                	addi	sp,sp,-16
    80001120:	e406                	sd	ra,8(sp)
    80001122:	e022                	sd	s0,0(sp)
    80001124:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001126:	f47ff0ef          	jal	ra,8000106c <kvmmake>
    8000112a:	00007797          	auipc	a5,0x7
    8000112e:	82a7b723          	sd	a0,-2002(a5) # 80007958 <kernel_pagetable>
}
    80001132:	60a2                	ld	ra,8(sp)
    80001134:	6402                	ld	s0,0(sp)
    80001136:	0141                	addi	sp,sp,16
    80001138:	8082                	ret

000000008000113a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000113a:	1101                	addi	sp,sp,-32
    8000113c:	ec06                	sd	ra,24(sp)
    8000113e:	e822                	sd	s0,16(sp)
    80001140:	e426                	sd	s1,8(sp)
    80001142:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001144:	959ff0ef          	jal	ra,80000a9c <kalloc>
    80001148:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000114a:	c509                	beqz	a0,80001154 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000114c:	6605                	lui	a2,0x1
    8000114e:	4581                	li	a1,0
    80001150:	af1ff0ef          	jal	ra,80000c40 <memset>
  return pagetable;
}
    80001154:	8526                	mv	a0,s1
    80001156:	60e2                	ld	ra,24(sp)
    80001158:	6442                	ld	s0,16(sp)
    8000115a:	64a2                	ld	s1,8(sp)
    8000115c:	6105                	addi	sp,sp,32
    8000115e:	8082                	ret

0000000080001160 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001160:	7139                	addi	sp,sp,-64
    80001162:	fc06                	sd	ra,56(sp)
    80001164:	f822                	sd	s0,48(sp)
    80001166:	f426                	sd	s1,40(sp)
    80001168:	f04a                	sd	s2,32(sp)
    8000116a:	ec4e                	sd	s3,24(sp)
    8000116c:	e852                	sd	s4,16(sp)
    8000116e:	e456                	sd	s5,8(sp)
    80001170:	e05a                	sd	s6,0(sp)
    80001172:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001174:	03459793          	slli	a5,a1,0x34
    80001178:	e785                	bnez	a5,800011a0 <uvmunmap+0x40>
    8000117a:	8a2a                	mv	s4,a0
    8000117c:	892e                	mv	s2,a1
    8000117e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001180:	0632                	slli	a2,a2,0xc
    80001182:	00b609b3          	add	s3,a2,a1
    80001186:	6b05                	lui	s6,0x1
    80001188:	0335e763          	bltu	a1,s3,800011b6 <uvmunmap+0x56>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000118c:	70e2                	ld	ra,56(sp)
    8000118e:	7442                	ld	s0,48(sp)
    80001190:	74a2                	ld	s1,40(sp)
    80001192:	7902                	ld	s2,32(sp)
    80001194:	69e2                	ld	s3,24(sp)
    80001196:	6a42                	ld	s4,16(sp)
    80001198:	6aa2                	ld	s5,8(sp)
    8000119a:	6b02                	ld	s6,0(sp)
    8000119c:	6121                	addi	sp,sp,64
    8000119e:	8082                	ret
    panic("uvmunmap: not aligned");
    800011a0:	00006517          	auipc	a0,0x6
    800011a4:	f9850513          	addi	a0,a0,-104 # 80007138 <digits+0x100>
    800011a8:	de2ff0ef          	jal	ra,8000078a <panic>
    *pte = 0;
    800011ac:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011b0:	995a                	add	s2,s2,s6
    800011b2:	fd397de3          	bgeu	s2,s3,8000118c <uvmunmap+0x2c>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011b6:	4601                	li	a2,0
    800011b8:	85ca                	mv	a1,s2
    800011ba:	8552                	mv	a0,s4
    800011bc:	d01ff0ef          	jal	ra,80000ebc <walk>
    800011c0:	84aa                	mv	s1,a0
    800011c2:	d57d                	beqz	a0,800011b0 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800011c4:	611c                	ld	a5,0(a0)
    800011c6:	0017f713          	andi	a4,a5,1
    800011ca:	d37d                	beqz	a4,800011b0 <uvmunmap+0x50>
    if(do_free){
    800011cc:	fe0a80e3          	beqz	s5,800011ac <uvmunmap+0x4c>
      uint64 pa = PTE2PA(*pte);
    800011d0:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800011d2:	00c79513          	slli	a0,a5,0xc
    800011d6:	fe6ff0ef          	jal	ra,800009bc <kfree>
    800011da:	bfc9                	j	800011ac <uvmunmap+0x4c>

00000000800011dc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011dc:	1101                	addi	sp,sp,-32
    800011de:	ec06                	sd	ra,24(sp)
    800011e0:	e822                	sd	s0,16(sp)
    800011e2:	e426                	sd	s1,8(sp)
    800011e4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800011e6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800011e8:	00b67d63          	bgeu	a2,a1,80001202 <uvmdealloc+0x26>
    800011ec:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800011ee:	6785                	lui	a5,0x1
    800011f0:	17fd                	addi	a5,a5,-1
    800011f2:	00f60733          	add	a4,a2,a5
    800011f6:	767d                	lui	a2,0xfffff
    800011f8:	8f71                	and	a4,a4,a2
    800011fa:	97ae                	add	a5,a5,a1
    800011fc:	8ff1                	and	a5,a5,a2
    800011fe:	00f76863          	bltu	a4,a5,8000120e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001202:	8526                	mv	a0,s1
    80001204:	60e2                	ld	ra,24(sp)
    80001206:	6442                	ld	s0,16(sp)
    80001208:	64a2                	ld	s1,8(sp)
    8000120a:	6105                	addi	sp,sp,32
    8000120c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000120e:	8f99                	sub	a5,a5,a4
    80001210:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001212:	4685                	li	a3,1
    80001214:	0007861b          	sext.w	a2,a5
    80001218:	85ba                	mv	a1,a4
    8000121a:	f47ff0ef          	jal	ra,80001160 <uvmunmap>
    8000121e:	b7d5                	j	80001202 <uvmdealloc+0x26>

0000000080001220 <uvmalloc>:
  if(newsz < oldsz)
    80001220:	08b66963          	bltu	a2,a1,800012b2 <uvmalloc+0x92>
{
    80001224:	7139                	addi	sp,sp,-64
    80001226:	fc06                	sd	ra,56(sp)
    80001228:	f822                	sd	s0,48(sp)
    8000122a:	f426                	sd	s1,40(sp)
    8000122c:	f04a                	sd	s2,32(sp)
    8000122e:	ec4e                	sd	s3,24(sp)
    80001230:	e852                	sd	s4,16(sp)
    80001232:	e456                	sd	s5,8(sp)
    80001234:	e05a                	sd	s6,0(sp)
    80001236:	0080                	addi	s0,sp,64
    80001238:	8aaa                	mv	s5,a0
    8000123a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000123c:	6985                	lui	s3,0x1
    8000123e:	19fd                	addi	s3,s3,-1
    80001240:	95ce                	add	a1,a1,s3
    80001242:	79fd                	lui	s3,0xfffff
    80001244:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001248:	06c9f763          	bgeu	s3,a2,800012b6 <uvmalloc+0x96>
    8000124c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000124e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001252:	84bff0ef          	jal	ra,80000a9c <kalloc>
    80001256:	84aa                	mv	s1,a0
    if(mem == 0){
    80001258:	c11d                	beqz	a0,8000127e <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    8000125a:	6605                	lui	a2,0x1
    8000125c:	4581                	li	a1,0
    8000125e:	9e3ff0ef          	jal	ra,80000c40 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001262:	875a                	mv	a4,s6
    80001264:	86a6                	mv	a3,s1
    80001266:	6605                	lui	a2,0x1
    80001268:	85ca                	mv	a1,s2
    8000126a:	8556                	mv	a0,s5
    8000126c:	d29ff0ef          	jal	ra,80000f94 <mappages>
    80001270:	e51d                	bnez	a0,8000129e <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001272:	6785                	lui	a5,0x1
    80001274:	993e                	add	s2,s2,a5
    80001276:	fd496ee3          	bltu	s2,s4,80001252 <uvmalloc+0x32>
  return newsz;
    8000127a:	8552                	mv	a0,s4
    8000127c:	a039                	j	8000128a <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    8000127e:	864e                	mv	a2,s3
    80001280:	85ca                	mv	a1,s2
    80001282:	8556                	mv	a0,s5
    80001284:	f59ff0ef          	jal	ra,800011dc <uvmdealloc>
      return 0;
    80001288:	4501                	li	a0,0
}
    8000128a:	70e2                	ld	ra,56(sp)
    8000128c:	7442                	ld	s0,48(sp)
    8000128e:	74a2                	ld	s1,40(sp)
    80001290:	7902                	ld	s2,32(sp)
    80001292:	69e2                	ld	s3,24(sp)
    80001294:	6a42                	ld	s4,16(sp)
    80001296:	6aa2                	ld	s5,8(sp)
    80001298:	6b02                	ld	s6,0(sp)
    8000129a:	6121                	addi	sp,sp,64
    8000129c:	8082                	ret
      kfree(mem);
    8000129e:	8526                	mv	a0,s1
    800012a0:	f1cff0ef          	jal	ra,800009bc <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012a4:	864e                	mv	a2,s3
    800012a6:	85ca                	mv	a1,s2
    800012a8:	8556                	mv	a0,s5
    800012aa:	f33ff0ef          	jal	ra,800011dc <uvmdealloc>
      return 0;
    800012ae:	4501                	li	a0,0
    800012b0:	bfe9                	j	8000128a <uvmalloc+0x6a>
    return oldsz;
    800012b2:	852e                	mv	a0,a1
}
    800012b4:	8082                	ret
  return newsz;
    800012b6:	8532                	mv	a0,a2
    800012b8:	bfc9                	j	8000128a <uvmalloc+0x6a>

00000000800012ba <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012ba:	7179                	addi	sp,sp,-48
    800012bc:	f406                	sd	ra,40(sp)
    800012be:	f022                	sd	s0,32(sp)
    800012c0:	ec26                	sd	s1,24(sp)
    800012c2:	e84a                	sd	s2,16(sp)
    800012c4:	e44e                	sd	s3,8(sp)
    800012c6:	e052                	sd	s4,0(sp)
    800012c8:	1800                	addi	s0,sp,48
    800012ca:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012cc:	84aa                	mv	s1,a0
    800012ce:	6905                	lui	s2,0x1
    800012d0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012d2:	4985                	li	s3,1
    800012d4:	a811                	j	800012e8 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012d6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800012d8:	0532                	slli	a0,a0,0xc
    800012da:	fe1ff0ef          	jal	ra,800012ba <freewalk>
      pagetable[i] = 0;
    800012de:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800012e2:	04a1                	addi	s1,s1,8
    800012e4:	01248f63          	beq	s1,s2,80001302 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800012e8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012ea:	00f57793          	andi	a5,a0,15
    800012ee:	ff3784e3          	beq	a5,s3,800012d6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800012f2:	8905                	andi	a0,a0,1
    800012f4:	d57d                	beqz	a0,800012e2 <freewalk+0x28>
      panic("freewalk: leaf");
    800012f6:	00006517          	auipc	a0,0x6
    800012fa:	e5a50513          	addi	a0,a0,-422 # 80007150 <digits+0x118>
    800012fe:	c8cff0ef          	jal	ra,8000078a <panic>
    }
  }
  kfree((void*)pagetable);
    80001302:	8552                	mv	a0,s4
    80001304:	eb8ff0ef          	jal	ra,800009bc <kfree>
}
    80001308:	70a2                	ld	ra,40(sp)
    8000130a:	7402                	ld	s0,32(sp)
    8000130c:	64e2                	ld	s1,24(sp)
    8000130e:	6942                	ld	s2,16(sp)
    80001310:	69a2                	ld	s3,8(sp)
    80001312:	6a02                	ld	s4,0(sp)
    80001314:	6145                	addi	sp,sp,48
    80001316:	8082                	ret

0000000080001318 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001318:	1101                	addi	sp,sp,-32
    8000131a:	ec06                	sd	ra,24(sp)
    8000131c:	e822                	sd	s0,16(sp)
    8000131e:	e426                	sd	s1,8(sp)
    80001320:	1000                	addi	s0,sp,32
    80001322:	84aa                	mv	s1,a0
  if(sz > 0)
    80001324:	e989                	bnez	a1,80001336 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001326:	8526                	mv	a0,s1
    80001328:	f93ff0ef          	jal	ra,800012ba <freewalk>
}
    8000132c:	60e2                	ld	ra,24(sp)
    8000132e:	6442                	ld	s0,16(sp)
    80001330:	64a2                	ld	s1,8(sp)
    80001332:	6105                	addi	sp,sp,32
    80001334:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001336:	6605                	lui	a2,0x1
    80001338:	167d                	addi	a2,a2,-1
    8000133a:	962e                	add	a2,a2,a1
    8000133c:	4685                	li	a3,1
    8000133e:	8231                	srli	a2,a2,0xc
    80001340:	4581                	li	a1,0
    80001342:	e1fff0ef          	jal	ra,80001160 <uvmunmap>
    80001346:	b7c5                	j	80001326 <uvmfree+0xe>

0000000080001348 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001348:	ce49                	beqz	a2,800013e2 <uvmcopy+0x9a>
{
    8000134a:	715d                	addi	sp,sp,-80
    8000134c:	e486                	sd	ra,72(sp)
    8000134e:	e0a2                	sd	s0,64(sp)
    80001350:	fc26                	sd	s1,56(sp)
    80001352:	f84a                	sd	s2,48(sp)
    80001354:	f44e                	sd	s3,40(sp)
    80001356:	f052                	sd	s4,32(sp)
    80001358:	ec56                	sd	s5,24(sp)
    8000135a:	e85a                	sd	s6,16(sp)
    8000135c:	e45e                	sd	s7,8(sp)
    8000135e:	0880                	addi	s0,sp,80
    80001360:	8aaa                	mv	s5,a0
    80001362:	8b2e                	mv	s6,a1
    80001364:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001366:	4481                	li	s1,0
    80001368:	a029                	j	80001372 <uvmcopy+0x2a>
    8000136a:	6785                	lui	a5,0x1
    8000136c:	94be                	add	s1,s1,a5
    8000136e:	0544fe63          	bgeu	s1,s4,800013ca <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001372:	4601                	li	a2,0
    80001374:	85a6                	mv	a1,s1
    80001376:	8556                	mv	a0,s5
    80001378:	b45ff0ef          	jal	ra,80000ebc <walk>
    8000137c:	d57d                	beqz	a0,8000136a <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    8000137e:	6118                	ld	a4,0(a0)
    80001380:	00177793          	andi	a5,a4,1
    80001384:	d3fd                	beqz	a5,8000136a <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001386:	00a75593          	srli	a1,a4,0xa
    8000138a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000138e:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001392:	f0aff0ef          	jal	ra,80000a9c <kalloc>
    80001396:	89aa                	mv	s3,a0
    80001398:	c105                	beqz	a0,800013b8 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000139a:	6605                	lui	a2,0x1
    8000139c:	85de                	mv	a1,s7
    8000139e:	8ffff0ef          	jal	ra,80000c9c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800013a2:	874a                	mv	a4,s2
    800013a4:	86ce                	mv	a3,s3
    800013a6:	6605                	lui	a2,0x1
    800013a8:	85a6                	mv	a1,s1
    800013aa:	855a                	mv	a0,s6
    800013ac:	be9ff0ef          	jal	ra,80000f94 <mappages>
    800013b0:	dd4d                	beqz	a0,8000136a <uvmcopy+0x22>
      kfree(mem);
    800013b2:	854e                	mv	a0,s3
    800013b4:	e08ff0ef          	jal	ra,800009bc <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013b8:	4685                	li	a3,1
    800013ba:	00c4d613          	srli	a2,s1,0xc
    800013be:	4581                	li	a1,0
    800013c0:	855a                	mv	a0,s6
    800013c2:	d9fff0ef          	jal	ra,80001160 <uvmunmap>
  return -1;
    800013c6:	557d                	li	a0,-1
    800013c8:	a011                	j	800013cc <uvmcopy+0x84>
  return 0;
    800013ca:	4501                	li	a0,0
}
    800013cc:	60a6                	ld	ra,72(sp)
    800013ce:	6406                	ld	s0,64(sp)
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	7942                	ld	s2,48(sp)
    800013d4:	79a2                	ld	s3,40(sp)
    800013d6:	7a02                	ld	s4,32(sp)
    800013d8:	6ae2                	ld	s5,24(sp)
    800013da:	6b42                	ld	s6,16(sp)
    800013dc:	6ba2                	ld	s7,8(sp)
    800013de:	6161                	addi	sp,sp,80
    800013e0:	8082                	ret
  return 0;
    800013e2:	4501                	li	a0,0
}
    800013e4:	8082                	ret

00000000800013e6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800013e6:	1141                	addi	sp,sp,-16
    800013e8:	e406                	sd	ra,8(sp)
    800013ea:	e022                	sd	s0,0(sp)
    800013ec:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800013ee:	4601                	li	a2,0
    800013f0:	acdff0ef          	jal	ra,80000ebc <walk>
  if(pte == 0)
    800013f4:	c901                	beqz	a0,80001404 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800013f6:	611c                	ld	a5,0(a0)
    800013f8:	9bbd                	andi	a5,a5,-17
    800013fa:	e11c                	sd	a5,0(a0)
}
    800013fc:	60a2                	ld	ra,8(sp)
    800013fe:	6402                	ld	s0,0(sp)
    80001400:	0141                	addi	sp,sp,16
    80001402:	8082                	ret
    panic("uvmclear");
    80001404:	00006517          	auipc	a0,0x6
    80001408:	d5c50513          	addi	a0,a0,-676 # 80007160 <digits+0x128>
    8000140c:	b7eff0ef          	jal	ra,8000078a <panic>

0000000080001410 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001410:	c2d5                	beqz	a3,800014b4 <copyinstr+0xa4>
{
    80001412:	715d                	addi	sp,sp,-80
    80001414:	e486                	sd	ra,72(sp)
    80001416:	e0a2                	sd	s0,64(sp)
    80001418:	fc26                	sd	s1,56(sp)
    8000141a:	f84a                	sd	s2,48(sp)
    8000141c:	f44e                	sd	s3,40(sp)
    8000141e:	f052                	sd	s4,32(sp)
    80001420:	ec56                	sd	s5,24(sp)
    80001422:	e85a                	sd	s6,16(sp)
    80001424:	e45e                	sd	s7,8(sp)
    80001426:	0880                	addi	s0,sp,80
    80001428:	8a2a                	mv	s4,a0
    8000142a:	8b2e                	mv	s6,a1
    8000142c:	8bb2                	mv	s7,a2
    8000142e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001430:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001432:	6985                	lui	s3,0x1
    80001434:	a035                	j	80001460 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001436:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000143a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000143c:	0017b793          	seqz	a5,a5
    80001440:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
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
    srcva = va0 + PGSIZE;
    8000145a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000145e:	c4b9                	beqz	s1,800014ac <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001460:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001464:	85ca                	mv	a1,s2
    80001466:	8552                	mv	a0,s4
    80001468:	aefff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0)
    8000146c:	c131                	beqz	a0,800014b0 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    8000146e:	41790833          	sub	a6,s2,s7
    80001472:	984e                	add	a6,a6,s3
    if(n > max)
    80001474:	0104f363          	bgeu	s1,a6,8000147a <copyinstr+0x6a>
    80001478:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000147a:	955e                	add	a0,a0,s7
    8000147c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001480:	fc080de3          	beqz	a6,8000145a <copyinstr+0x4a>
    80001484:	985a                	add	a6,a6,s6
    80001486:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001488:	41650633          	sub	a2,a0,s6
    8000148c:	14fd                	addi	s1,s1,-1
    8000148e:	9b26                	add	s6,s6,s1
    80001490:	00f60733          	add	a4,a2,a5
    80001494:	00074703          	lbu	a4,0(a4)
    80001498:	df59                	beqz	a4,80001436 <copyinstr+0x26>
        *dst = *p;
    8000149a:	00e78023          	sb	a4,0(a5)
      --max;
    8000149e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800014a2:	0785                	addi	a5,a5,1
    while(n > 0){
    800014a4:	ff0796e3          	bne	a5,a6,80001490 <copyinstr+0x80>
      dst++;
    800014a8:	8b42                	mv	s6,a6
    800014aa:	bf45                	j	8000145a <copyinstr+0x4a>
    800014ac:	4781                	li	a5,0
    800014ae:	b779                	j	8000143c <copyinstr+0x2c>
      return -1;
    800014b0:	557d                	li	a0,-1
    800014b2:	bf49                	j	80001444 <copyinstr+0x34>
  int got_null = 0;
    800014b4:	4781                	li	a5,0
  if(got_null){
    800014b6:	0017b793          	seqz	a5,a5
    800014ba:	40f00533          	neg	a0,a5
}
    800014be:	8082                	ret

00000000800014c0 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014c0:	1141                	addi	sp,sp,-16
    800014c2:	e406                	sd	ra,8(sp)
    800014c4:	e022                	sd	s0,0(sp)
    800014c6:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014c8:	4601                	li	a2,0
    800014ca:	9f3ff0ef          	jal	ra,80000ebc <walk>
  if (pte == 0) {
    800014ce:	c519                	beqz	a0,800014dc <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800014d0:	6108                	ld	a0,0(a0)
    return 0;
    800014d2:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014d4:	60a2                	ld	ra,8(sp)
    800014d6:	6402                	ld	s0,0(sp)
    800014d8:	0141                	addi	sp,sp,16
    800014da:	8082                	ret
    return 0;
    800014dc:	4501                	li	a0,0
    800014de:	bfdd                	j	800014d4 <ismapped+0x14>

00000000800014e0 <vmfault>:
{
    800014e0:	7179                	addi	sp,sp,-48
    800014e2:	f406                	sd	ra,40(sp)
    800014e4:	f022                	sd	s0,32(sp)
    800014e6:	ec26                	sd	s1,24(sp)
    800014e8:	e84a                	sd	s2,16(sp)
    800014ea:	e44e                	sd	s3,8(sp)
    800014ec:	e052                	sd	s4,0(sp)
    800014ee:	1800                	addi	s0,sp,48
    800014f0:	89aa                	mv	s3,a0
    800014f2:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800014f4:	324000ef          	jal	ra,80001818 <myproc>
  if (va >= p->sz)
    800014f8:	653c                	ld	a5,72(a0)
    800014fa:	00f4ec63          	bltu	s1,a5,80001512 <vmfault+0x32>
    return 0;
    800014fe:	4981                	li	s3,0
}
    80001500:	854e                	mv	a0,s3
    80001502:	70a2                	ld	ra,40(sp)
    80001504:	7402                	ld	s0,32(sp)
    80001506:	64e2                	ld	s1,24(sp)
    80001508:	6942                	ld	s2,16(sp)
    8000150a:	69a2                	ld	s3,8(sp)
    8000150c:	6a02                	ld	s4,0(sp)
    8000150e:	6145                	addi	sp,sp,48
    80001510:	8082                	ret
    80001512:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001514:	75fd                	lui	a1,0xfffff
    80001516:	8ced                	and	s1,s1,a1
  if(ismapped(pagetable, va)) {
    80001518:	85a6                	mv	a1,s1
    8000151a:	854e                	mv	a0,s3
    8000151c:	fa5ff0ef          	jal	ra,800014c0 <ismapped>
    return 0;
    80001520:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001522:	fd79                	bnez	a0,80001500 <vmfault+0x20>
  mem = (uint64) kalloc();
    80001524:	d78ff0ef          	jal	ra,80000a9c <kalloc>
    80001528:	8a2a                	mv	s4,a0
  if(mem == 0)
    8000152a:	d979                	beqz	a0,80001500 <vmfault+0x20>
  mem = (uint64) kalloc();
    8000152c:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000152e:	6605                	lui	a2,0x1
    80001530:	4581                	li	a1,0
    80001532:	f0eff0ef          	jal	ra,80000c40 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001536:	4759                	li	a4,22
    80001538:	86d2                	mv	a3,s4
    8000153a:	6605                	lui	a2,0x1
    8000153c:	85a6                	mv	a1,s1
    8000153e:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    80001542:	a53ff0ef          	jal	ra,80000f94 <mappages>
    80001546:	dd4d                	beqz	a0,80001500 <vmfault+0x20>
    kfree((void *)mem);
    80001548:	8552                	mv	a0,s4
    8000154a:	c72ff0ef          	jal	ra,800009bc <kfree>
    return 0;
    8000154e:	4981                	li	s3,0
    80001550:	bf45                	j	80001500 <vmfault+0x20>

0000000080001552 <copyout>:
  while(len > 0){
    80001552:	cec1                	beqz	a3,800015ea <copyout+0x98>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	e0ca                	sd	s2,64(sp)
    8000155e:	fc4e                	sd	s3,56(sp)
    80001560:	f852                	sd	s4,48(sp)
    80001562:	f456                	sd	s5,40(sp)
    80001564:	f05a                	sd	s6,32(sp)
    80001566:	ec5e                	sd	s7,24(sp)
    80001568:	e862                	sd	s8,16(sp)
    8000156a:	e466                	sd	s9,8(sp)
    8000156c:	e06a                	sd	s10,0(sp)
    8000156e:	1080                	addi	s0,sp,96
    80001570:	8c2a                	mv	s8,a0
    80001572:	8b2e                	mv	s6,a1
    80001574:	8bb2                	mv	s7,a2
    80001576:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001578:	74fd                	lui	s1,0xfffff
    8000157a:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000157c:	57fd                	li	a5,-1
    8000157e:	83e9                	srli	a5,a5,0x1a
    80001580:	0697e763          	bltu	a5,s1,800015ee <copyout+0x9c>
    80001584:	6d05                	lui	s10,0x1
    80001586:	8cbe                	mv	s9,a5
    80001588:	a015                	j	800015ac <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000158a:	409b0533          	sub	a0,s6,s1
    8000158e:	0009861b          	sext.w	a2,s3
    80001592:	85de                	mv	a1,s7
    80001594:	954a                	add	a0,a0,s2
    80001596:	f06ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000159a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000159e:	9bce                	add	s7,s7,s3
  while(len > 0){
    800015a0:	040a0363          	beqz	s4,800015e6 <copyout+0x94>
    if(va0 >= MAXVA)
    800015a4:	055ce763          	bltu	s9,s5,800015f2 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800015a8:	84d6                	mv	s1,s5
    dstva = va0 + PGSIZE;
    800015aa:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    800015ac:	85a6                	mv	a1,s1
    800015ae:	8562                	mv	a0,s8
    800015b0:	9a7ff0ef          	jal	ra,80000f56 <walkaddr>
    800015b4:	892a                	mv	s2,a0
    if(pa0 == 0) {
    800015b6:	e901                	bnez	a0,800015c6 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800015b8:	4601                	li	a2,0
    800015ba:	85a6                	mv	a1,s1
    800015bc:	8562                	mv	a0,s8
    800015be:	f23ff0ef          	jal	ra,800014e0 <vmfault>
    800015c2:	892a                	mv	s2,a0
    800015c4:	c90d                	beqz	a0,800015f6 <copyout+0xa4>
    pte = walk(pagetable, va0, 0);
    800015c6:	4601                	li	a2,0
    800015c8:	85a6                	mv	a1,s1
    800015ca:	8562                	mv	a0,s8
    800015cc:	8f1ff0ef          	jal	ra,80000ebc <walk>
    if((*pte & PTE_W) == 0)
    800015d0:	611c                	ld	a5,0(a0)
    800015d2:	8b91                	andi	a5,a5,4
    800015d4:	c39d                	beqz	a5,800015fa <copyout+0xa8>
    n = PGSIZE - (dstva - va0);
    800015d6:	01a48ab3          	add	s5,s1,s10
    800015da:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    800015de:	fb3a76e3          	bgeu	s4,s3,8000158a <copyout+0x38>
    800015e2:	89d2                	mv	s3,s4
    800015e4:	b75d                	j	8000158a <copyout+0x38>
  return 0;
    800015e6:	4501                	li	a0,0
    800015e8:	a811                	j	800015fc <copyout+0xaa>
    800015ea:	4501                	li	a0,0
}
    800015ec:	8082                	ret
      return -1;
    800015ee:	557d                	li	a0,-1
    800015f0:	a031                	j	800015fc <copyout+0xaa>
    800015f2:	557d                	li	a0,-1
    800015f4:	a021                	j	800015fc <copyout+0xaa>
        return -1;
    800015f6:	557d                	li	a0,-1
    800015f8:	a011                	j	800015fc <copyout+0xaa>
      return -1;
    800015fa:	557d                	li	a0,-1
}
    800015fc:	60e6                	ld	ra,88(sp)
    800015fe:	6446                	ld	s0,80(sp)
    80001600:	64a6                	ld	s1,72(sp)
    80001602:	6906                	ld	s2,64(sp)
    80001604:	79e2                	ld	s3,56(sp)
    80001606:	7a42                	ld	s4,48(sp)
    80001608:	7aa2                	ld	s5,40(sp)
    8000160a:	7b02                	ld	s6,32(sp)
    8000160c:	6be2                	ld	s7,24(sp)
    8000160e:	6c42                	ld	s8,16(sp)
    80001610:	6ca2                	ld	s9,8(sp)
    80001612:	6d02                	ld	s10,0(sp)
    80001614:	6125                	addi	sp,sp,96
    80001616:	8082                	ret

0000000080001618 <copyin>:
  while(len > 0){
    80001618:	c6c9                	beqz	a3,800016a2 <copyin+0x8a>
{
    8000161a:	715d                	addi	sp,sp,-80
    8000161c:	e486                	sd	ra,72(sp)
    8000161e:	e0a2                	sd	s0,64(sp)
    80001620:	fc26                	sd	s1,56(sp)
    80001622:	f84a                	sd	s2,48(sp)
    80001624:	f44e                	sd	s3,40(sp)
    80001626:	f052                	sd	s4,32(sp)
    80001628:	ec56                	sd	s5,24(sp)
    8000162a:	e85a                	sd	s6,16(sp)
    8000162c:	e45e                	sd	s7,8(sp)
    8000162e:	e062                	sd	s8,0(sp)
    80001630:	0880                	addi	s0,sp,80
    80001632:	8baa                	mv	s7,a0
    80001634:	8aae                	mv	s5,a1
    80001636:	8932                	mv	s2,a2
    80001638:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000163a:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000163c:	6b05                	lui	s6,0x1
    8000163e:	a035                	j	8000166a <copyin+0x52>
    80001640:	412984b3          	sub	s1,s3,s2
    80001644:	94da                	add	s1,s1,s6
    if(n > len)
    80001646:	009a7363          	bgeu	s4,s1,8000164c <copyin+0x34>
    8000164a:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000164c:	413905b3          	sub	a1,s2,s3
    80001650:	0004861b          	sext.w	a2,s1
    80001654:	95aa                	add	a1,a1,a0
    80001656:	8556                	mv	a0,s5
    80001658:	e44ff0ef          	jal	ra,80000c9c <memmove>
    len -= n;
    8000165c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001660:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001662:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001666:	020a0163          	beqz	s4,80001688 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000166a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000166e:	85ce                	mv	a1,s3
    80001670:	855e                	mv	a0,s7
    80001672:	8e5ff0ef          	jal	ra,80000f56 <walkaddr>
    if(pa0 == 0) {
    80001676:	f569                	bnez	a0,80001640 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001678:	4601                	li	a2,0
    8000167a:	85ce                	mv	a1,s3
    8000167c:	855e                	mv	a0,s7
    8000167e:	e63ff0ef          	jal	ra,800014e0 <vmfault>
    80001682:	fd5d                	bnez	a0,80001640 <copyin+0x28>
        return -1;
    80001684:	557d                	li	a0,-1
    80001686:	a011                	j	8000168a <copyin+0x72>
  return 0;
    80001688:	4501                	li	a0,0
}
    8000168a:	60a6                	ld	ra,72(sp)
    8000168c:	6406                	ld	s0,64(sp)
    8000168e:	74e2                	ld	s1,56(sp)
    80001690:	7942                	ld	s2,48(sp)
    80001692:	79a2                	ld	s3,40(sp)
    80001694:	7a02                	ld	s4,32(sp)
    80001696:	6ae2                	ld	s5,24(sp)
    80001698:	6b42                	ld	s6,16(sp)
    8000169a:	6ba2                	ld	s7,8(sp)
    8000169c:	6c02                	ld	s8,0(sp)
    8000169e:	6161                	addi	sp,sp,80
    800016a0:	8082                	ret
  return 0;
    800016a2:	4501                	li	a0,0
}
    800016a4:	8082                	ret

00000000800016a6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016a6:	7139                	addi	sp,sp,-64
    800016a8:	fc06                	sd	ra,56(sp)
    800016aa:	f822                	sd	s0,48(sp)
    800016ac:	f426                	sd	s1,40(sp)
    800016ae:	f04a                	sd	s2,32(sp)
    800016b0:	ec4e                	sd	s3,24(sp)
    800016b2:	e852                	sd	s4,16(sp)
    800016b4:	e456                	sd	s5,8(sp)
    800016b6:	e05a                	sd	s6,0(sp)
    800016b8:	0080                	addi	s0,sp,64
    800016ba:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016bc:	0000f497          	auipc	s1,0xf
    800016c0:	80448493          	addi	s1,s1,-2044 # 8000fec0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016c4:	8b26                	mv	s6,s1
    800016c6:	00006a97          	auipc	s5,0x6
    800016ca:	93aa8a93          	addi	s5,s5,-1734 # 80007000 <etext>
    800016ce:	04000937          	lui	s2,0x4000
    800016d2:	197d                	addi	s2,s2,-1
    800016d4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016d6:	00014a17          	auipc	s4,0x14
    800016da:	5eaa0a13          	addi	s4,s4,1514 # 80015cc0 <tickslock>
    char *pa = kalloc();
    800016de:	bbeff0ef          	jal	ra,80000a9c <kalloc>
    800016e2:	862a                	mv	a2,a0
    if(pa == 0)
    800016e4:	c121                	beqz	a0,80001724 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800016e6:	416485b3          	sub	a1,s1,s6
    800016ea:	858d                	srai	a1,a1,0x3
    800016ec:	000ab783          	ld	a5,0(s5)
    800016f0:	02f585b3          	mul	a1,a1,a5
    800016f4:	2585                	addiw	a1,a1,1
    800016f6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800016fa:	4719                	li	a4,6
    800016fc:	6685                	lui	a3,0x1
    800016fe:	40b905b3          	sub	a1,s2,a1
    80001702:	854e                	mv	a0,s3
    80001704:	941ff0ef          	jal	ra,80001044 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001708:	17848493          	addi	s1,s1,376
    8000170c:	fd4499e3          	bne	s1,s4,800016de <proc_mapstacks+0x38>
  }
}
    80001710:	70e2                	ld	ra,56(sp)
    80001712:	7442                	ld	s0,48(sp)
    80001714:	74a2                	ld	s1,40(sp)
    80001716:	7902                	ld	s2,32(sp)
    80001718:	69e2                	ld	s3,24(sp)
    8000171a:	6a42                	ld	s4,16(sp)
    8000171c:	6aa2                	ld	s5,8(sp)
    8000171e:	6b02                	ld	s6,0(sp)
    80001720:	6121                	addi	sp,sp,64
    80001722:	8082                	ret
      panic("kalloc");
    80001724:	00006517          	auipc	a0,0x6
    80001728:	a4c50513          	addi	a0,a0,-1460 # 80007170 <digits+0x138>
    8000172c:	85eff0ef          	jal	ra,8000078a <panic>

0000000080001730 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001730:	7139                	addi	sp,sp,-64
    80001732:	fc06                	sd	ra,56(sp)
    80001734:	f822                	sd	s0,48(sp)
    80001736:	f426                	sd	s1,40(sp)
    80001738:	f04a                	sd	s2,32(sp)
    8000173a:	ec4e                	sd	s3,24(sp)
    8000173c:	e852                	sd	s4,16(sp)
    8000173e:	e456                	sd	s5,8(sp)
    80001740:	e05a                	sd	s6,0(sp)
    80001742:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001744:	00006597          	auipc	a1,0x6
    80001748:	a3458593          	addi	a1,a1,-1484 # 80007178 <digits+0x140>
    8000174c:	0000e517          	auipc	a0,0xe
    80001750:	32c50513          	addi	a0,a0,812 # 8000fa78 <pid_lock>
    80001754:	b98ff0ef          	jal	ra,80000aec <initlock>
  initlock(&wait_lock, "wait_lock");
    80001758:	00006597          	auipc	a1,0x6
    8000175c:	a2858593          	addi	a1,a1,-1496 # 80007180 <digits+0x148>
    80001760:	0000e517          	auipc	a0,0xe
    80001764:	33050513          	addi	a0,a0,816 # 8000fa90 <wait_lock>
    80001768:	b84ff0ef          	jal	ra,80000aec <initlock>
  initlock(&mlfq_lock, "mlfq");
    8000176c:	00006597          	auipc	a1,0x6
    80001770:	a2458593          	addi	a1,a1,-1500 # 80007190 <digits+0x158>
    80001774:	0000e517          	auipc	a0,0xe
    80001778:	33450513          	addi	a0,a0,820 # 8000faa8 <mlfq_lock>
    8000177c:	b70ff0ef          	jal	ra,80000aec <initlock>
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001780:	0000e497          	auipc	s1,0xe
    80001784:	74048493          	addi	s1,s1,1856 # 8000fec0 <proc>
      initlock(&p->lock, "proc");
    80001788:	00006b17          	auipc	s6,0x6
    8000178c:	a10b0b13          	addi	s6,s6,-1520 # 80007198 <digits+0x160>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001790:	8aa6                	mv	s5,s1
    80001792:	00006a17          	auipc	s4,0x6
    80001796:	86ea0a13          	addi	s4,s4,-1938 # 80007000 <etext>
    8000179a:	04000937          	lui	s2,0x4000
    8000179e:	197d                	addi	s2,s2,-1
    800017a0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a2:	00014997          	auipc	s3,0x14
    800017a6:	51e98993          	addi	s3,s3,1310 # 80015cc0 <tickslock>
      initlock(&p->lock, "proc");
    800017aa:	85da                	mv	a1,s6
    800017ac:	8526                	mv	a0,s1
    800017ae:	b3eff0ef          	jal	ra,80000aec <initlock>
      p->state = UNUSED;
    800017b2:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017b6:	415487b3          	sub	a5,s1,s5
    800017ba:	878d                	srai	a5,a5,0x3
    800017bc:	000a3703          	ld	a4,0(s4)
    800017c0:	02e787b3          	mul	a5,a5,a4
    800017c4:	2785                	addiw	a5,a5,1
    800017c6:	00d7979b          	slliw	a5,a5,0xd
    800017ca:	40f907b3          	sub	a5,s2,a5
    800017ce:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d0:	17848493          	addi	s1,s1,376
    800017d4:	fd349be3          	bne	s1,s3,800017aa <procinit+0x7a>
  }
}
    800017d8:	70e2                	ld	ra,56(sp)
    800017da:	7442                	ld	s0,48(sp)
    800017dc:	74a2                	ld	s1,40(sp)
    800017de:	7902                	ld	s2,32(sp)
    800017e0:	69e2                	ld	s3,24(sp)
    800017e2:	6a42                	ld	s4,16(sp)
    800017e4:	6aa2                	ld	s5,8(sp)
    800017e6:	6b02                	ld	s6,0(sp)
    800017e8:	6121                	addi	sp,sp,64
    800017ea:	8082                	ret

00000000800017ec <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017ec:	1141                	addi	sp,sp,-16
    800017ee:	e422                	sd	s0,8(sp)
    800017f0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017f2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800017f4:	2501                	sext.w	a0,a0
    800017f6:	6422                	ld	s0,8(sp)
    800017f8:	0141                	addi	sp,sp,16
    800017fa:	8082                	ret

00000000800017fc <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800017fc:	1141                	addi	sp,sp,-16
    800017fe:	e422                	sd	s0,8(sp)
    80001800:	0800                	addi	s0,sp,16
    80001802:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001804:	2781                	sext.w	a5,a5
    80001806:	079e                	slli	a5,a5,0x7
  return c;
}
    80001808:	0000e517          	auipc	a0,0xe
    8000180c:	2b850513          	addi	a0,a0,696 # 8000fac0 <cpus>
    80001810:	953e                	add	a0,a0,a5
    80001812:	6422                	ld	s0,8(sp)
    80001814:	0141                	addi	sp,sp,16
    80001816:	8082                	ret

0000000080001818 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001818:	1101                	addi	sp,sp,-32
    8000181a:	ec06                	sd	ra,24(sp)
    8000181c:	e822                	sd	s0,16(sp)
    8000181e:	e426                	sd	s1,8(sp)
    80001820:	1000                	addi	s0,sp,32
  push_off();
    80001822:	b0aff0ef          	jal	ra,80000b2c <push_off>
    80001826:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001828:	2781                	sext.w	a5,a5
    8000182a:	079e                	slli	a5,a5,0x7
    8000182c:	0000e717          	auipc	a4,0xe
    80001830:	24c70713          	addi	a4,a4,588 # 8000fa78 <pid_lock>
    80001834:	97ba                	add	a5,a5,a4
    80001836:	67a4                	ld	s1,72(a5)
  pop_off();
    80001838:	b78ff0ef          	jal	ra,80000bb0 <pop_off>
  return p;
}
    8000183c:	8526                	mv	a0,s1
    8000183e:	60e2                	ld	ra,24(sp)
    80001840:	6442                	ld	s0,16(sp)
    80001842:	64a2                	ld	s1,8(sp)
    80001844:	6105                	addi	sp,sp,32
    80001846:	8082                	ret

0000000080001848 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001848:	7179                	addi	sp,sp,-48
    8000184a:	f406                	sd	ra,40(sp)
    8000184c:	f022                	sd	s0,32(sp)
    8000184e:	ec26                	sd	s1,24(sp)
    80001850:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001852:	fc7ff0ef          	jal	ra,80001818 <myproc>
    80001856:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001858:	bacff0ef          	jal	ra,80000c04 <release>

  if (first) {
    8000185c:	00006797          	auipc	a5,0x6
    80001860:	0c47a783          	lw	a5,196(a5) # 80007920 <first.1>
    80001864:	cf8d                	beqz	a5,8000189e <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001866:	4505                	li	a0,1
    80001868:	56d010ef          	jal	ra,800035d4 <fsinit>

    first = 0;
    8000186c:	00006797          	auipc	a5,0x6
    80001870:	0a07aa23          	sw	zero,180(a5) # 80007920 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001874:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001878:	00006517          	auipc	a0,0x6
    8000187c:	92850513          	addi	a0,a0,-1752 # 800071a0 <digits+0x168>
    80001880:	fca43823          	sd	a0,-48(s0)
    80001884:	fc043c23          	sd	zero,-40(s0)
    80001888:	fd040593          	addi	a1,s0,-48
    8000188c:	5f1020ef          	jal	ra,8000467c <kexec>
    80001890:	6cbc                	ld	a5,88(s1)
    80001892:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001894:	6cbc                	ld	a5,88(s1)
    80001896:	7bb8                	ld	a4,112(a5)
    80001898:	57fd                	li	a5,-1
    8000189a:	02f70d63          	beq	a4,a5,800018d4 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000189e:	3cb000ef          	jal	ra,80002468 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800018a2:	68a8                	ld	a0,80(s1)
    800018a4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800018a6:	04000737          	lui	a4,0x4000
    800018aa:	00004797          	auipc	a5,0x4
    800018ae:	7f278793          	addi	a5,a5,2034 # 8000609c <userret>
    800018b2:	00004697          	auipc	a3,0x4
    800018b6:	74e68693          	addi	a3,a3,1870 # 80006000 <_trampoline>
    800018ba:	8f95                	sub	a5,a5,a3
    800018bc:	177d                	addi	a4,a4,-1
    800018be:	0732                	slli	a4,a4,0xc
    800018c0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018c2:	577d                	li	a4,-1
    800018c4:	177e                	slli	a4,a4,0x3f
    800018c6:	8d59                	or	a0,a0,a4
    800018c8:	9782                	jalr	a5
}
    800018ca:	70a2                	ld	ra,40(sp)
    800018cc:	7402                	ld	s0,32(sp)
    800018ce:	64e2                	ld	s1,24(sp)
    800018d0:	6145                	addi	sp,sp,48
    800018d2:	8082                	ret
      panic("exec");
    800018d4:	00006517          	auipc	a0,0x6
    800018d8:	8d450513          	addi	a0,a0,-1836 # 800071a8 <digits+0x170>
    800018dc:	eaffe0ef          	jal	ra,8000078a <panic>

00000000800018e0 <allocpid>:
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	e04a                	sd	s2,0(sp)
    800018ea:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018ec:	0000e917          	auipc	s2,0xe
    800018f0:	18c90913          	addi	s2,s2,396 # 8000fa78 <pid_lock>
    800018f4:	854a                	mv	a0,s2
    800018f6:	a76ff0ef          	jal	ra,80000b6c <acquire>
  pid = nextpid;
    800018fa:	00006797          	auipc	a5,0x6
    800018fe:	02a78793          	addi	a5,a5,42 # 80007924 <nextpid>
    80001902:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001904:	0014871b          	addiw	a4,s1,1
    80001908:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    8000190a:	854a                	mv	a0,s2
    8000190c:	af8ff0ef          	jal	ra,80000c04 <release>
}
    80001910:	8526                	mv	a0,s1
    80001912:	60e2                	ld	ra,24(sp)
    80001914:	6442                	ld	s0,16(sp)
    80001916:	64a2                	ld	s1,8(sp)
    80001918:	6902                	ld	s2,0(sp)
    8000191a:	6105                	addi	sp,sp,32
    8000191c:	8082                	ret

000000008000191e <proc_pagetable>:
{
    8000191e:	1101                	addi	sp,sp,-32
    80001920:	ec06                	sd	ra,24(sp)
    80001922:	e822                	sd	s0,16(sp)
    80001924:	e426                	sd	s1,8(sp)
    80001926:	e04a                	sd	s2,0(sp)
    80001928:	1000                	addi	s0,sp,32
    8000192a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000192c:	80fff0ef          	jal	ra,8000113a <uvmcreate>
    80001930:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001932:	cd05                	beqz	a0,8000196a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001934:	4729                	li	a4,10
    80001936:	00004697          	auipc	a3,0x4
    8000193a:	6ca68693          	addi	a3,a3,1738 # 80006000 <_trampoline>
    8000193e:	6605                	lui	a2,0x1
    80001940:	040005b7          	lui	a1,0x4000
    80001944:	15fd                	addi	a1,a1,-1
    80001946:	05b2                	slli	a1,a1,0xc
    80001948:	e4cff0ef          	jal	ra,80000f94 <mappages>
    8000194c:	02054663          	bltz	a0,80001978 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001950:	4719                	li	a4,6
    80001952:	05893683          	ld	a3,88(s2)
    80001956:	6605                	lui	a2,0x1
    80001958:	020005b7          	lui	a1,0x2000
    8000195c:	15fd                	addi	a1,a1,-1
    8000195e:	05b6                	slli	a1,a1,0xd
    80001960:	8526                	mv	a0,s1
    80001962:	e32ff0ef          	jal	ra,80000f94 <mappages>
    80001966:	00054f63          	bltz	a0,80001984 <proc_pagetable+0x66>
}
    8000196a:	8526                	mv	a0,s1
    8000196c:	60e2                	ld	ra,24(sp)
    8000196e:	6442                	ld	s0,16(sp)
    80001970:	64a2                	ld	s1,8(sp)
    80001972:	6902                	ld	s2,0(sp)
    80001974:	6105                	addi	sp,sp,32
    80001976:	8082                	ret
    uvmfree(pagetable, 0);
    80001978:	4581                	li	a1,0
    8000197a:	8526                	mv	a0,s1
    8000197c:	99dff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    80001980:	4481                	li	s1,0
    80001982:	b7e5                	j	8000196a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001984:	4681                	li	a3,0
    80001986:	4605                	li	a2,1
    80001988:	040005b7          	lui	a1,0x4000
    8000198c:	15fd                	addi	a1,a1,-1
    8000198e:	05b2                	slli	a1,a1,0xc
    80001990:	8526                	mv	a0,s1
    80001992:	fceff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80001996:	4581                	li	a1,0
    80001998:	8526                	mv	a0,s1
    8000199a:	97fff0ef          	jal	ra,80001318 <uvmfree>
    return 0;
    8000199e:	4481                	li	s1,0
    800019a0:	b7e9                	j	8000196a <proc_pagetable+0x4c>

00000000800019a2 <proc_freepagetable>:
{
    800019a2:	1101                	addi	sp,sp,-32
    800019a4:	ec06                	sd	ra,24(sp)
    800019a6:	e822                	sd	s0,16(sp)
    800019a8:	e426                	sd	s1,8(sp)
    800019aa:	e04a                	sd	s2,0(sp)
    800019ac:	1000                	addi	s0,sp,32
    800019ae:	84aa                	mv	s1,a0
    800019b0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019b2:	4681                	li	a3,0
    800019b4:	4605                	li	a2,1
    800019b6:	040005b7          	lui	a1,0x4000
    800019ba:	15fd                	addi	a1,a1,-1
    800019bc:	05b2                	slli	a1,a1,0xc
    800019be:	fa2ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800019c2:	4681                	li	a3,0
    800019c4:	4605                	li	a2,1
    800019c6:	020005b7          	lui	a1,0x2000
    800019ca:	15fd                	addi	a1,a1,-1
    800019cc:	05b6                	slli	a1,a1,0xd
    800019ce:	8526                	mv	a0,s1
    800019d0:	f90ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    800019d4:	85ca                	mv	a1,s2
    800019d6:	8526                	mv	a0,s1
    800019d8:	941ff0ef          	jal	ra,80001318 <uvmfree>
}
    800019dc:	60e2                	ld	ra,24(sp)
    800019de:	6442                	ld	s0,16(sp)
    800019e0:	64a2                	ld	s1,8(sp)
    800019e2:	6902                	ld	s2,0(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret

00000000800019e8 <freeproc>:
{
    800019e8:	1101                	addi	sp,sp,-32
    800019ea:	ec06                	sd	ra,24(sp)
    800019ec:	e822                	sd	s0,16(sp)
    800019ee:	e426                	sd	s1,8(sp)
    800019f0:	1000                	addi	s0,sp,32
    800019f2:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019f4:	6d28                	ld	a0,88(a0)
    800019f6:	c119                	beqz	a0,800019fc <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019f8:	fc5fe0ef          	jal	ra,800009bc <kfree>
  p->trapframe = 0;
    800019fc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a00:	68a8                	ld	a0,80(s1)
    80001a02:	c501                	beqz	a0,80001a0a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a04:	64ac                	ld	a1,72(s1)
    80001a06:	f9dff0ef          	jal	ra,800019a2 <proc_freepagetable>
  p->pagetable = 0;
    80001a0a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a0e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a12:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a16:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a1a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a1e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a22:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a26:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a2a:	0004ac23          	sw	zero,24(s1)
}
    80001a2e:	60e2                	ld	ra,24(sp)
    80001a30:	6442                	ld	s0,16(sp)
    80001a32:	64a2                	ld	s1,8(sp)
    80001a34:	6105                	addi	sp,sp,32
    80001a36:	8082                	ret

0000000080001a38 <allocproc>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a44:	0000e497          	auipc	s1,0xe
    80001a48:	47c48493          	addi	s1,s1,1148 # 8000fec0 <proc>
    80001a4c:	00014917          	auipc	s2,0x14
    80001a50:	27490913          	addi	s2,s2,628 # 80015cc0 <tickslock>
    acquire(&p->lock);
    80001a54:	8526                	mv	a0,s1
    80001a56:	916ff0ef          	jal	ra,80000b6c <acquire>
    if(p->state == UNUSED) {
    80001a5a:	4c9c                	lw	a5,24(s1)
    80001a5c:	cb91                	beqz	a5,80001a70 <allocproc+0x38>
      release(&p->lock);
    80001a5e:	8526                	mv	a0,s1
    80001a60:	9a4ff0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a64:	17848493          	addi	s1,s1,376
    80001a68:	ff2496e3          	bne	s1,s2,80001a54 <allocproc+0x1c>
  return 0;
    80001a6c:	4481                	li	s1,0
    80001a6e:	a0b9                	j	80001abc <allocproc+0x84>
  p->pid = allocpid();
    80001a70:	e71ff0ef          	jal	ra,800018e0 <allocpid>
    80001a74:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a76:	4785                	li	a5,1
    80001a78:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a7a:	822ff0ef          	jal	ra,80000a9c <kalloc>
    80001a7e:	892a                	mv	s2,a0
    80001a80:	eca8                	sd	a0,88(s1)
    80001a82:	c521                	beqz	a0,80001aca <allocproc+0x92>
  p->pagetable = proc_pagetable(p);
    80001a84:	8526                	mv	a0,s1
    80001a86:	e99ff0ef          	jal	ra,8000191e <proc_pagetable>
    80001a8a:	892a                	mv	s2,a0
    80001a8c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a8e:	c531                	beqz	a0,80001ada <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80001a90:	07000613          	li	a2,112
    80001a94:	4581                	li	a1,0
    80001a96:	06048513          	addi	a0,s1,96
    80001a9a:	9a6ff0ef          	jal	ra,80000c40 <memset>
  p->context.ra = (uint64)forkret;
    80001a9e:	00000797          	auipc	a5,0x0
    80001aa2:	daa78793          	addi	a5,a5,-598 # 80001848 <forkret>
    80001aa6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001aa8:	60bc                	ld	a5,64(s1)
    80001aaa:	6705                	lui	a4,0x1
    80001aac:	97ba                	add	a5,a5,a4
    80001aae:	f4bc                	sd	a5,104(s1)
  p->priority = 0;
    80001ab0:	1604a423          	sw	zero,360(s1)
  p->time_slices = 0;
    80001ab4:	1604a623          	sw	zero,364(s1)
  p->arrival_time = 0;
    80001ab8:	1604b823          	sd	zero,368(s1)
}
    80001abc:	8526                	mv	a0,s1
    80001abe:	60e2                	ld	ra,24(sp)
    80001ac0:	6442                	ld	s0,16(sp)
    80001ac2:	64a2                	ld	s1,8(sp)
    80001ac4:	6902                	ld	s2,0(sp)
    80001ac6:	6105                	addi	sp,sp,32
    80001ac8:	8082                	ret
    freeproc(p);
    80001aca:	8526                	mv	a0,s1
    80001acc:	f1dff0ef          	jal	ra,800019e8 <freeproc>
    release(&p->lock);
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	932ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001ad6:	84ca                	mv	s1,s2
    80001ad8:	b7d5                	j	80001abc <allocproc+0x84>
    freeproc(p);
    80001ada:	8526                	mv	a0,s1
    80001adc:	f0dff0ef          	jal	ra,800019e8 <freeproc>
    release(&p->lock);
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	922ff0ef          	jal	ra,80000c04 <release>
    return 0;
    80001ae6:	84ca                	mv	s1,s2
    80001ae8:	bfd1                	j	80001abc <allocproc+0x84>

0000000080001aea <userinit>:
{
    80001aea:	1101                	addi	sp,sp,-32
    80001aec:	ec06                	sd	ra,24(sp)
    80001aee:	e822                	sd	s0,16(sp)
    80001af0:	e426                	sd	s1,8(sp)
    80001af2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001af4:	f45ff0ef          	jal	ra,80001a38 <allocproc>
    80001af8:	84aa                	mv	s1,a0
  initproc = p;
    80001afa:	00006797          	auipc	a5,0x6
    80001afe:	e6a7b723          	sd	a0,-402(a5) # 80007968 <initproc>
  p->cwd = namei("/");
    80001b02:	00005517          	auipc	a0,0x5
    80001b06:	6ae50513          	addi	a0,a0,1710 # 800071b0 <digits+0x178>
    80001b0a:	7c9010ef          	jal	ra,80003ad2 <namei>
    80001b0e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b12:	478d                	li	a5,3
    80001b14:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b16:	8526                	mv	a0,s1
    80001b18:	8ecff0ef          	jal	ra,80000c04 <release>
}
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <growproc>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b34:	ce5ff0ef          	jal	ra,80001818 <myproc>
    80001b38:	892a                	mv	s2,a0
  sz = p->sz;
    80001b3a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b3c:	02905963          	blez	s1,80001b6e <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001b40:	00b48633          	add	a2,s1,a1
    80001b44:	020007b7          	lui	a5,0x2000
    80001b48:	17fd                	addi	a5,a5,-1
    80001b4a:	07b6                	slli	a5,a5,0xd
    80001b4c:	02c7ea63          	bltu	a5,a2,80001b80 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b50:	4691                	li	a3,4
    80001b52:	6928                	ld	a0,80(a0)
    80001b54:	eccff0ef          	jal	ra,80001220 <uvmalloc>
    80001b58:	85aa                	mv	a1,a0
    80001b5a:	c50d                	beqz	a0,80001b84 <growproc+0x5e>
  p->sz = sz;
    80001b5c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001b60:	4501                	li	a0,0
}
    80001b62:	60e2                	ld	ra,24(sp)
    80001b64:	6442                	ld	s0,16(sp)
    80001b66:	64a2                	ld	s1,8(sp)
    80001b68:	6902                	ld	s2,0(sp)
    80001b6a:	6105                	addi	sp,sp,32
    80001b6c:	8082                	ret
  } else if(n < 0){
    80001b6e:	fe04d7e3          	bgez	s1,80001b5c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b72:	00b48633          	add	a2,s1,a1
    80001b76:	6928                	ld	a0,80(a0)
    80001b78:	e64ff0ef          	jal	ra,800011dc <uvmdealloc>
    80001b7c:	85aa                	mv	a1,a0
    80001b7e:	bff9                	j	80001b5c <growproc+0x36>
      return -1;
    80001b80:	557d                	li	a0,-1
    80001b82:	b7c5                	j	80001b62 <growproc+0x3c>
      return -1;
    80001b84:	557d                	li	a0,-1
    80001b86:	bff1                	j	80001b62 <growproc+0x3c>

0000000080001b88 <kfork>:
{
    80001b88:	7139                	addi	sp,sp,-64
    80001b8a:	fc06                	sd	ra,56(sp)
    80001b8c:	f822                	sd	s0,48(sp)
    80001b8e:	f426                	sd	s1,40(sp)
    80001b90:	f04a                	sd	s2,32(sp)
    80001b92:	ec4e                	sd	s3,24(sp)
    80001b94:	e852                	sd	s4,16(sp)
    80001b96:	e456                	sd	s5,8(sp)
    80001b98:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b9a:	c7fff0ef          	jal	ra,80001818 <myproc>
    80001b9e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ba0:	e99ff0ef          	jal	ra,80001a38 <allocproc>
    80001ba4:	0e050663          	beqz	a0,80001c90 <kfork+0x108>
    80001ba8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001baa:	048ab603          	ld	a2,72(s5)
    80001bae:	692c                	ld	a1,80(a0)
    80001bb0:	050ab503          	ld	a0,80(s5)
    80001bb4:	f94ff0ef          	jal	ra,80001348 <uvmcopy>
    80001bb8:	04054863          	bltz	a0,80001c08 <kfork+0x80>
  np->sz = p->sz;
    80001bbc:	048ab783          	ld	a5,72(s5)
    80001bc0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001bc4:	058ab683          	ld	a3,88(s5)
    80001bc8:	87b6                	mv	a5,a3
    80001bca:	058a3703          	ld	a4,88(s4)
    80001bce:	12068693          	addi	a3,a3,288
    80001bd2:	0007b803          	ld	a6,0(a5) # 2000000 <_entry-0x7e000000>
    80001bd6:	6788                	ld	a0,8(a5)
    80001bd8:	6b8c                	ld	a1,16(a5)
    80001bda:	6f90                	ld	a2,24(a5)
    80001bdc:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001be0:	e708                	sd	a0,8(a4)
    80001be2:	eb0c                	sd	a1,16(a4)
    80001be4:	ef10                	sd	a2,24(a4)
    80001be6:	02078793          	addi	a5,a5,32
    80001bea:	02070713          	addi	a4,a4,32
    80001bee:	fed792e3          	bne	a5,a3,80001bd2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001bf2:	058a3783          	ld	a5,88(s4)
    80001bf6:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001bfa:	0d0a8493          	addi	s1,s5,208
    80001bfe:	0d0a0913          	addi	s2,s4,208
    80001c02:	150a8993          	addi	s3,s5,336
    80001c06:	a829                	j	80001c20 <kfork+0x98>
    freeproc(np);
    80001c08:	8552                	mv	a0,s4
    80001c0a:	ddfff0ef          	jal	ra,800019e8 <freeproc>
    release(&np->lock);
    80001c0e:	8552                	mv	a0,s4
    80001c10:	ff5fe0ef          	jal	ra,80000c04 <release>
    return -1;
    80001c14:	597d                	li	s2,-1
    80001c16:	a09d                	j	80001c7c <kfork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001c18:	04a1                	addi	s1,s1,8
    80001c1a:	0921                	addi	s2,s2,8
    80001c1c:	01348963          	beq	s1,s3,80001c2e <kfork+0xa6>
    if(p->ofile[i])
    80001c20:	6088                	ld	a0,0(s1)
    80001c22:	d97d                	beqz	a0,80001c18 <kfork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c24:	466020ef          	jal	ra,8000408a <filedup>
    80001c28:	00a93023          	sd	a0,0(s2)
    80001c2c:	b7f5                	j	80001c18 <kfork+0x90>
  np->cwd = idup(p->cwd);
    80001c2e:	150ab503          	ld	a0,336(s5)
    80001c32:	67c010ef          	jal	ra,800032ae <idup>
    80001c36:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c3a:	4641                	li	a2,16
    80001c3c:	158a8593          	addi	a1,s5,344
    80001c40:	158a0513          	addi	a0,s4,344
    80001c44:	942ff0ef          	jal	ra,80000d86 <safestrcpy>
  pid = np->pid;
    80001c48:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001c4c:	8552                	mv	a0,s4
    80001c4e:	fb7fe0ef          	jal	ra,80000c04 <release>
  acquire(&wait_lock);
    80001c52:	0000e497          	auipc	s1,0xe
    80001c56:	e3e48493          	addi	s1,s1,-450 # 8000fa90 <wait_lock>
    80001c5a:	8526                	mv	a0,s1
    80001c5c:	f11fe0ef          	jal	ra,80000b6c <acquire>
  np->parent = p;
    80001c60:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	f9ffe0ef          	jal	ra,80000c04 <release>
  acquire(&np->lock);
    80001c6a:	8552                	mv	a0,s4
    80001c6c:	f01fe0ef          	jal	ra,80000b6c <acquire>
  np->state = RUNNABLE;
    80001c70:	478d                	li	a5,3
    80001c72:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c76:	8552                	mv	a0,s4
    80001c78:	f8dfe0ef          	jal	ra,80000c04 <release>
}
    80001c7c:	854a                	mv	a0,s2
    80001c7e:	70e2                	ld	ra,56(sp)
    80001c80:	7442                	ld	s0,48(sp)
    80001c82:	74a2                	ld	s1,40(sp)
    80001c84:	7902                	ld	s2,32(sp)
    80001c86:	69e2                	ld	s3,24(sp)
    80001c88:	6a42                	ld	s4,16(sp)
    80001c8a:	6aa2                	ld	s5,8(sp)
    80001c8c:	6121                	addi	sp,sp,64
    80001c8e:	8082                	ret
    return -1;
    80001c90:	597d                	li	s2,-1
    80001c92:	b7ed                	j	80001c7c <kfork+0xf4>

0000000080001c94 <boost_all_priorities>:
{
    80001c94:	7139                	addi	sp,sp,-64
    80001c96:	fc06                	sd	ra,56(sp)
    80001c98:	f822                	sd	s0,48(sp)
    80001c9a:	f426                	sd	s1,40(sp)
    80001c9c:	f04a                	sd	s2,32(sp)
    80001c9e:	ec4e                	sd	s3,24(sp)
    80001ca0:	e852                	sd	s4,16(sp)
    80001ca2:	e456                	sd	s5,8(sp)
    80001ca4:	0080                	addi	s0,sp,64
  printf("[MLFQ BOOST] Boosting all processes to Q0 at tick %d\n", ticks);
    80001ca6:	00006597          	auipc	a1,0x6
    80001caa:	cca5a583          	lw	a1,-822(a1) # 80007970 <ticks>
    80001cae:	00005517          	auipc	a0,0x5
    80001cb2:	50a50513          	addi	a0,a0,1290 # 800071b8 <digits+0x180>
    80001cb6:	80ffe0ef          	jal	ra,800004c4 <printf>
  int boosted_count = 0;
    80001cba:	4a01                	li	s4,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cbc:	0000e497          	auipc	s1,0xe
    80001cc0:	20448493          	addi	s1,s1,516 # 8000fec0 <proc>
    if(p->state == RUNNABLE || p->state == RUNNING) {
    80001cc4:	4985                	li	s3,1
        printf("[MLFQ BOOST] PID %d: Q%d -> Q0 (slices=%d)\n", 
    80001cc6:	00005a97          	auipc	s5,0x5
    80001cca:	52aa8a93          	addi	s5,s5,1322 # 800071f0 <digits+0x1b8>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cce:	00014917          	auipc	s2,0x14
    80001cd2:	ff290913          	addi	s2,s2,-14 # 80015cc0 <tickslock>
    80001cd6:	a821                	j	80001cee <boost_all_priorities+0x5a>
      p->priority = 0;
    80001cd8:	1604a423          	sw	zero,360(s1)
      p->time_slices = 0;
    80001cdc:	1604a623          	sw	zero,364(s1)
    release(&p->lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	f23fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ce6:	17848493          	addi	s1,s1,376
    80001cea:	03248463          	beq	s1,s2,80001d12 <boost_all_priorities+0x7e>
    acquire(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	e7dfe0ef          	jal	ra,80000b6c <acquire>
    if(p->state == RUNNABLE || p->state == RUNNING) {
    80001cf4:	4c9c                	lw	a5,24(s1)
    80001cf6:	37f5                	addiw	a5,a5,-3
    80001cf8:	fef9e4e3          	bltu	s3,a5,80001ce0 <boost_all_priorities+0x4c>
      if(p->priority != 0) {
    80001cfc:	1684a603          	lw	a2,360(s1)
    80001d00:	de61                	beqz	a2,80001cd8 <boost_all_priorities+0x44>
        printf("[MLFQ BOOST] PID %d: Q%d -> Q0 (slices=%d)\n", 
    80001d02:	16c4a683          	lw	a3,364(s1)
    80001d06:	588c                	lw	a1,48(s1)
    80001d08:	8556                	mv	a0,s5
    80001d0a:	fbafe0ef          	jal	ra,800004c4 <printf>
        boosted_count++;
    80001d0e:	2a05                	addiw	s4,s4,1
    80001d10:	b7e1                	j	80001cd8 <boost_all_priorities+0x44>
  printf("[MLFQ BOOST] Boosted %d processes\n", boosted_count);
    80001d12:	85d2                	mv	a1,s4
    80001d14:	00005517          	auipc	a0,0x5
    80001d18:	50c50513          	addi	a0,a0,1292 # 80007220 <digits+0x1e8>
    80001d1c:	fa8fe0ef          	jal	ra,800004c4 <printf>
}
    80001d20:	70e2                	ld	ra,56(sp)
    80001d22:	7442                	ld	s0,48(sp)
    80001d24:	74a2                	ld	s1,40(sp)
    80001d26:	7902                	ld	s2,32(sp)
    80001d28:	69e2                	ld	s3,24(sp)
    80001d2a:	6a42                	ld	s4,16(sp)
    80001d2c:	6aa2                	ld	s5,8(sp)
    80001d2e:	6121                	addi	sp,sp,64
    80001d30:	8082                	ret

0000000080001d32 <scheduler>:
{
    80001d32:	711d                	addi	sp,sp,-96
    80001d34:	ec86                	sd	ra,88(sp)
    80001d36:	e8a2                	sd	s0,80(sp)
    80001d38:	e4a6                	sd	s1,72(sp)
    80001d3a:	e0ca                	sd	s2,64(sp)
    80001d3c:	fc4e                	sd	s3,56(sp)
    80001d3e:	f852                	sd	s4,48(sp)
    80001d40:	f456                	sd	s5,40(sp)
    80001d42:	f05a                	sd	s6,32(sp)
    80001d44:	ec5e                	sd	s7,24(sp)
    80001d46:	e862                	sd	s8,16(sp)
    80001d48:	e466                	sd	s9,8(sp)
    80001d4a:	e06a                	sd	s10,0(sp)
    80001d4c:	1080                	addi	s0,sp,96
    80001d4e:	8792                	mv	a5,tp
  int id = r_tp();
    80001d50:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d52:	00779b93          	slli	s7,a5,0x7
    80001d56:	0000e717          	auipc	a4,0xe
    80001d5a:	d2270713          	addi	a4,a4,-734 # 8000fa78 <pid_lock>
    80001d5e:	975e                	add	a4,a4,s7
    80001d60:	04073423          	sd	zero,72(a4)
          swtch(&c->context, &p->context);
    80001d64:	0000e717          	auipc	a4,0xe
    80001d68:	d6470713          	addi	a4,a4,-668 # 8000fac8 <cpus+0x8>
    80001d6c:	9bba                	add	s7,s7,a4
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001d6e:	00006c97          	auipc	s9,0x6
    80001d72:	bf2c8c93          	addi	s9,s9,-1038 # 80007960 <last_boost_time>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001d76:	00014997          	auipc	s3,0x14
    80001d7a:	f4a98993          	addi	s3,s3,-182 # 80015cc0 <tickslock>
          c->proc = p;
    80001d7e:	079e                	slli	a5,a5,0x7
    80001d80:	0000ea97          	auipc	s5,0xe
    80001d84:	cf8a8a93          	addi	s5,s5,-776 # 8000fa78 <pid_lock>
    80001d88:	9abe                	add	s5,s5,a5
    80001d8a:	a899                	j	80001de0 <scheduler+0xae>
      release(&tickslock);
    80001d8c:	855a                	mv	a0,s6
    80001d8e:	e77fe0ef          	jal	ra,80000c04 <release>
    80001d92:	a871                	j	80001e2e <scheduler+0xfc>
        release(&p->lock);
    80001d94:	8526                	mv	a0,s1
    80001d96:	e6ffe0ef          	jal	ra,80000c04 <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001d9a:	17848493          	addi	s1,s1,376
    80001d9e:	09348c63          	beq	s1,s3,80001e36 <scheduler+0x104>
        acquire(&p->lock);
    80001da2:	8526                	mv	a0,s1
    80001da4:	dc9fe0ef          	jal	ra,80000b6c <acquire>
        if(p->state == RUNNABLE && p->priority == priority) {
    80001da8:	4c9c                	lw	a5,24(s1)
    80001daa:	ff2795e3          	bne	a5,s2,80001d94 <scheduler+0x62>
    80001dae:	1684a783          	lw	a5,360(s1)
    80001db2:	ff4791e3          	bne	a5,s4,80001d94 <scheduler+0x62>
          p->state = RUNNING;
    80001db6:	4791                	li	a5,4
    80001db8:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    80001dba:	049ab423          	sd	s1,72(s5)
          swtch(&c->context, &p->context);
    80001dbe:	06048593          	addi	a1,s1,96
    80001dc2:	855e                	mv	a0,s7
    80001dc4:	5fe000ef          	jal	ra,800023c2 <swtch>
          c->proc = 0;
    80001dc8:	040ab423          	sd	zero,72(s5)
          release(&p->lock);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	e37fe0ef          	jal	ra,80000c04 <release>
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001dd2:	478d                	li	a5,3
    80001dd4:	00fa1e63          	bne	s4,a5,80001df0 <scheduler+0xbe>
          found = 1;
    80001dd8:	4785                	li	a5,1
    if(found == 0) {
    80001dda:	eb99                	bnez	a5,80001df0 <scheduler+0xbe>
      asm volatile("wfi");
    80001ddc:	10500073          	wfi
    acquire(&tickslock);
    80001de0:	00014b17          	auipc	s6,0x14
    80001de4:	ee0b0b13          	addi	s6,s6,-288 # 80015cc0 <tickslock>
    uint64 current_ticks = ticks;
    80001de8:	00006d17          	auipc	s10,0x6
    80001dec:	b88d0d13          	addi	s10,s10,-1144 # 80007970 <ticks>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001df0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001df4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001df8:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dfc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e00:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e02:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80001e06:	855a                	mv	a0,s6
    80001e08:	d65fe0ef          	jal	ra,80000b6c <acquire>
    uint64 current_ticks = ticks;
    80001e0c:	000d6703          	lwu	a4,0(s10)
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001e10:	000cb783          	ld	a5,0(s9)
    80001e14:	40f707b3          	sub	a5,a4,a5
    80001e18:	06300693          	li	a3,99
    80001e1c:	f6f6f8e3          	bgeu	a3,a5,80001d8c <scheduler+0x5a>
      last_boost_time = current_ticks;
    80001e20:	00ecb023          	sd	a4,0(s9)
      release(&tickslock);
    80001e24:	855a                	mv	a0,s6
    80001e26:	ddffe0ef          	jal	ra,80000c04 <release>
      boost_all_priorities();
    80001e2a:	e6bff0ef          	jal	ra,80001c94 <boost_all_priorities>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e2e:	4a01                	li	s4,0
        if(p->state == RUNNABLE && p->priority == priority) {
    80001e30:	490d                	li	s2,3
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001e32:	4c11                	li	s8,4
    80001e34:	a021                	j	80001e3c <scheduler+0x10a>
    80001e36:	2a05                	addiw	s4,s4,1
    80001e38:	018a0763          	beq	s4,s8,80001e46 <scheduler+0x114>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e3c:	0000e497          	auipc	s1,0xe
    80001e40:	08448493          	addi	s1,s1,132 # 8000fec0 <proc>
    80001e44:	bfb9                	j	80001da2 <scheduler+0x70>
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001e46:	4781                	li	a5,0
    80001e48:	bf49                	j	80001dda <scheduler+0xa8>

0000000080001e4a <sched>:
{
    80001e4a:	7179                	addi	sp,sp,-48
    80001e4c:	f406                	sd	ra,40(sp)
    80001e4e:	f022                	sd	s0,32(sp)
    80001e50:	ec26                	sd	s1,24(sp)
    80001e52:	e84a                	sd	s2,16(sp)
    80001e54:	e44e                	sd	s3,8(sp)
    80001e56:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e58:	9c1ff0ef          	jal	ra,80001818 <myproc>
    80001e5c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e5e:	ca5fe0ef          	jal	ra,80000b02 <holding>
    80001e62:	c92d                	beqz	a0,80001ed4 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e64:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e66:	2781                	sext.w	a5,a5
    80001e68:	079e                	slli	a5,a5,0x7
    80001e6a:	0000e717          	auipc	a4,0xe
    80001e6e:	c0e70713          	addi	a4,a4,-1010 # 8000fa78 <pid_lock>
    80001e72:	97ba                	add	a5,a5,a4
    80001e74:	0c07a703          	lw	a4,192(a5)
    80001e78:	4785                	li	a5,1
    80001e7a:	06f71363          	bne	a4,a5,80001ee0 <sched+0x96>
  if(p->state == RUNNING)
    80001e7e:	4c98                	lw	a4,24(s1)
    80001e80:	4791                	li	a5,4
    80001e82:	06f70563          	beq	a4,a5,80001eec <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e8a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e8c:	e7b5                	bnez	a5,80001ef8 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e8e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e90:	0000e917          	auipc	s2,0xe
    80001e94:	be890913          	addi	s2,s2,-1048 # 8000fa78 <pid_lock>
    80001e98:	2781                	sext.w	a5,a5
    80001e9a:	079e                	slli	a5,a5,0x7
    80001e9c:	97ca                	add	a5,a5,s2
    80001e9e:	0c47a983          	lw	s3,196(a5)
    80001ea2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ea4:	2781                	sext.w	a5,a5
    80001ea6:	079e                	slli	a5,a5,0x7
    80001ea8:	0000e597          	auipc	a1,0xe
    80001eac:	c2058593          	addi	a1,a1,-992 # 8000fac8 <cpus+0x8>
    80001eb0:	95be                	add	a1,a1,a5
    80001eb2:	06048513          	addi	a0,s1,96
    80001eb6:	50c000ef          	jal	ra,800023c2 <swtch>
    80001eba:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ebc:	2781                	sext.w	a5,a5
    80001ebe:	079e                	slli	a5,a5,0x7
    80001ec0:	97ca                	add	a5,a5,s2
    80001ec2:	0d37a223          	sw	s3,196(a5)
}
    80001ec6:	70a2                	ld	ra,40(sp)
    80001ec8:	7402                	ld	s0,32(sp)
    80001eca:	64e2                	ld	s1,24(sp)
    80001ecc:	6942                	ld	s2,16(sp)
    80001ece:	69a2                	ld	s3,8(sp)
    80001ed0:	6145                	addi	sp,sp,48
    80001ed2:	8082                	ret
    panic("sched p->lock");
    80001ed4:	00005517          	auipc	a0,0x5
    80001ed8:	37450513          	addi	a0,a0,884 # 80007248 <digits+0x210>
    80001edc:	8affe0ef          	jal	ra,8000078a <panic>
    panic("sched locks");
    80001ee0:	00005517          	auipc	a0,0x5
    80001ee4:	37850513          	addi	a0,a0,888 # 80007258 <digits+0x220>
    80001ee8:	8a3fe0ef          	jal	ra,8000078a <panic>
    panic("sched RUNNING");
    80001eec:	00005517          	auipc	a0,0x5
    80001ef0:	37c50513          	addi	a0,a0,892 # 80007268 <digits+0x230>
    80001ef4:	897fe0ef          	jal	ra,8000078a <panic>
    panic("sched interruptible");
    80001ef8:	00005517          	auipc	a0,0x5
    80001efc:	38050513          	addi	a0,a0,896 # 80007278 <digits+0x240>
    80001f00:	88bfe0ef          	jal	ra,8000078a <panic>

0000000080001f04 <yield>:
{
    80001f04:	1101                	addi	sp,sp,-32
    80001f06:	ec06                	sd	ra,24(sp)
    80001f08:	e822                	sd	s0,16(sp)
    80001f0a:	e426                	sd	s1,8(sp)
    80001f0c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f0e:	90bff0ef          	jal	ra,80001818 <myproc>
    80001f12:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f14:	c59fe0ef          	jal	ra,80000b6c <acquire>
  p->state = RUNNABLE;
    80001f18:	478d                	li	a5,3
    80001f1a:	cc9c                	sw	a5,24(s1)
  sched();
    80001f1c:	f2fff0ef          	jal	ra,80001e4a <sched>
  release(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	ce3fe0ef          	jal	ra,80000c04 <release>
}
    80001f26:	60e2                	ld	ra,24(sp)
    80001f28:	6442                	ld	s0,16(sp)
    80001f2a:	64a2                	ld	s1,8(sp)
    80001f2c:	6105                	addi	sp,sp,32
    80001f2e:	8082                	ret

0000000080001f30 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f30:	7179                	addi	sp,sp,-48
    80001f32:	f406                	sd	ra,40(sp)
    80001f34:	f022                	sd	s0,32(sp)
    80001f36:	ec26                	sd	s1,24(sp)
    80001f38:	e84a                	sd	s2,16(sp)
    80001f3a:	e44e                	sd	s3,8(sp)
    80001f3c:	1800                	addi	s0,sp,48
    80001f3e:	89aa                	mv	s3,a0
    80001f40:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f42:	8d7ff0ef          	jal	ra,80001818 <myproc>
    80001f46:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f48:	c25fe0ef          	jal	ra,80000b6c <acquire>
  release(lk);
    80001f4c:	854a                	mv	a0,s2
    80001f4e:	cb7fe0ef          	jal	ra,80000c04 <release>

  // Go to sleep.
  p->chan = chan;
    80001f52:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f56:	4789                	li	a5,2
    80001f58:	cc9c                	sw	a5,24(s1)

  sched();
    80001f5a:	ef1ff0ef          	jal	ra,80001e4a <sched>

  // Tidy up.
  p->chan = 0;
    80001f5e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	ca1fe0ef          	jal	ra,80000c04 <release>
  acquire(lk);
    80001f68:	854a                	mv	a0,s2
    80001f6a:	c03fe0ef          	jal	ra,80000b6c <acquire>
}
    80001f6e:	70a2                	ld	ra,40(sp)
    80001f70:	7402                	ld	s0,32(sp)
    80001f72:	64e2                	ld	s1,24(sp)
    80001f74:	6942                	ld	s2,16(sp)
    80001f76:	69a2                	ld	s3,8(sp)
    80001f78:	6145                	addi	sp,sp,48
    80001f7a:	8082                	ret

0000000080001f7c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f7c:	7139                	addi	sp,sp,-64
    80001f7e:	fc06                	sd	ra,56(sp)
    80001f80:	f822                	sd	s0,48(sp)
    80001f82:	f426                	sd	s1,40(sp)
    80001f84:	f04a                	sd	s2,32(sp)
    80001f86:	ec4e                	sd	s3,24(sp)
    80001f88:	e852                	sd	s4,16(sp)
    80001f8a:	e456                	sd	s5,8(sp)
    80001f8c:	0080                	addi	s0,sp,64
    80001f8e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f90:	0000e497          	auipc	s1,0xe
    80001f94:	f3048493          	addi	s1,s1,-208 # 8000fec0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f98:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f9a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f9c:	00014917          	auipc	s2,0x14
    80001fa0:	d2490913          	addi	s2,s2,-732 # 80015cc0 <tickslock>
    80001fa4:	a801                	j	80001fb4 <wakeup+0x38>
      }
      release(&p->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	c5dfe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fac:	17848493          	addi	s1,s1,376
    80001fb0:	03248263          	beq	s1,s2,80001fd4 <wakeup+0x58>
    if(p != myproc()){
    80001fb4:	865ff0ef          	jal	ra,80001818 <myproc>
    80001fb8:	fea48ae3          	beq	s1,a0,80001fac <wakeup+0x30>
      acquire(&p->lock);
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	baffe0ef          	jal	ra,80000b6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fc2:	4c9c                	lw	a5,24(s1)
    80001fc4:	ff3791e3          	bne	a5,s3,80001fa6 <wakeup+0x2a>
    80001fc8:	709c                	ld	a5,32(s1)
    80001fca:	fd479ee3          	bne	a5,s4,80001fa6 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fce:	0154ac23          	sw	s5,24(s1)
    80001fd2:	bfd1                	j	80001fa6 <wakeup+0x2a>
    }
  }
}
    80001fd4:	70e2                	ld	ra,56(sp)
    80001fd6:	7442                	ld	s0,48(sp)
    80001fd8:	74a2                	ld	s1,40(sp)
    80001fda:	7902                	ld	s2,32(sp)
    80001fdc:	69e2                	ld	s3,24(sp)
    80001fde:	6a42                	ld	s4,16(sp)
    80001fe0:	6aa2                	ld	s5,8(sp)
    80001fe2:	6121                	addi	sp,sp,64
    80001fe4:	8082                	ret

0000000080001fe6 <reparent>:
{
    80001fe6:	7179                	addi	sp,sp,-48
    80001fe8:	f406                	sd	ra,40(sp)
    80001fea:	f022                	sd	s0,32(sp)
    80001fec:	ec26                	sd	s1,24(sp)
    80001fee:	e84a                	sd	s2,16(sp)
    80001ff0:	e44e                	sd	s3,8(sp)
    80001ff2:	e052                	sd	s4,0(sp)
    80001ff4:	1800                	addi	s0,sp,48
    80001ff6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ff8:	0000e497          	auipc	s1,0xe
    80001ffc:	ec848493          	addi	s1,s1,-312 # 8000fec0 <proc>
      pp->parent = initproc;
    80002000:	00006a17          	auipc	s4,0x6
    80002004:	968a0a13          	addi	s4,s4,-1688 # 80007968 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002008:	00014997          	auipc	s3,0x14
    8000200c:	cb898993          	addi	s3,s3,-840 # 80015cc0 <tickslock>
    80002010:	a029                	j	8000201a <reparent+0x34>
    80002012:	17848493          	addi	s1,s1,376
    80002016:	01348b63          	beq	s1,s3,8000202c <reparent+0x46>
    if(pp->parent == p){
    8000201a:	7c9c                	ld	a5,56(s1)
    8000201c:	ff279be3          	bne	a5,s2,80002012 <reparent+0x2c>
      pp->parent = initproc;
    80002020:	000a3503          	ld	a0,0(s4)
    80002024:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002026:	f57ff0ef          	jal	ra,80001f7c <wakeup>
    8000202a:	b7e5                	j	80002012 <reparent+0x2c>
}
    8000202c:	70a2                	ld	ra,40(sp)
    8000202e:	7402                	ld	s0,32(sp)
    80002030:	64e2                	ld	s1,24(sp)
    80002032:	6942                	ld	s2,16(sp)
    80002034:	69a2                	ld	s3,8(sp)
    80002036:	6a02                	ld	s4,0(sp)
    80002038:	6145                	addi	sp,sp,48
    8000203a:	8082                	ret

000000008000203c <kexit>:
{
    8000203c:	7179                	addi	sp,sp,-48
    8000203e:	f406                	sd	ra,40(sp)
    80002040:	f022                	sd	s0,32(sp)
    80002042:	ec26                	sd	s1,24(sp)
    80002044:	e84a                	sd	s2,16(sp)
    80002046:	e44e                	sd	s3,8(sp)
    80002048:	e052                	sd	s4,0(sp)
    8000204a:	1800                	addi	s0,sp,48
    8000204c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000204e:	fcaff0ef          	jal	ra,80001818 <myproc>
    80002052:	89aa                	mv	s3,a0
  if(p == initproc)
    80002054:	00006797          	auipc	a5,0x6
    80002058:	9147b783          	ld	a5,-1772(a5) # 80007968 <initproc>
    8000205c:	0d050493          	addi	s1,a0,208
    80002060:	15050913          	addi	s2,a0,336
    80002064:	00a79f63          	bne	a5,a0,80002082 <kexit+0x46>
    panic("init exiting");
    80002068:	00005517          	auipc	a0,0x5
    8000206c:	22850513          	addi	a0,a0,552 # 80007290 <digits+0x258>
    80002070:	f1afe0ef          	jal	ra,8000078a <panic>
      fileclose(f);
    80002074:	05c020ef          	jal	ra,800040d0 <fileclose>
      p->ofile[fd] = 0;
    80002078:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000207c:	04a1                	addi	s1,s1,8
    8000207e:	01248563          	beq	s1,s2,80002088 <kexit+0x4c>
    if(p->ofile[fd]){
    80002082:	6088                	ld	a0,0(s1)
    80002084:	f965                	bnez	a0,80002074 <kexit+0x38>
    80002086:	bfdd                	j	8000207c <kexit+0x40>
  begin_op();
    80002088:	43b010ef          	jal	ra,80003cc2 <begin_op>
  iput(p->cwd);
    8000208c:	1509b503          	ld	a0,336(s3)
    80002090:	3d2010ef          	jal	ra,80003462 <iput>
  end_op();
    80002094:	49f010ef          	jal	ra,80003d32 <end_op>
  p->cwd = 0;
    80002098:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000209c:	0000e497          	auipc	s1,0xe
    800020a0:	9f448493          	addi	s1,s1,-1548 # 8000fa90 <wait_lock>
    800020a4:	8526                	mv	a0,s1
    800020a6:	ac7fe0ef          	jal	ra,80000b6c <acquire>
  reparent(p);
    800020aa:	854e                	mv	a0,s3
    800020ac:	f3bff0ef          	jal	ra,80001fe6 <reparent>
  wakeup(p->parent);
    800020b0:	0389b503          	ld	a0,56(s3)
    800020b4:	ec9ff0ef          	jal	ra,80001f7c <wakeup>
  acquire(&p->lock);
    800020b8:	854e                	mv	a0,s3
    800020ba:	ab3fe0ef          	jal	ra,80000b6c <acquire>
  p->xstate = status;
    800020be:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020c2:	4795                	li	a5,5
    800020c4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020c8:	8526                	mv	a0,s1
    800020ca:	b3bfe0ef          	jal	ra,80000c04 <release>
  sched();
    800020ce:	d7dff0ef          	jal	ra,80001e4a <sched>
  panic("zombie exit");
    800020d2:	00005517          	auipc	a0,0x5
    800020d6:	1ce50513          	addi	a0,a0,462 # 800072a0 <digits+0x268>
    800020da:	eb0fe0ef          	jal	ra,8000078a <panic>

00000000800020de <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020de:	7179                	addi	sp,sp,-48
    800020e0:	f406                	sd	ra,40(sp)
    800020e2:	f022                	sd	s0,32(sp)
    800020e4:	ec26                	sd	s1,24(sp)
    800020e6:	e84a                	sd	s2,16(sp)
    800020e8:	e44e                	sd	s3,8(sp)
    800020ea:	1800                	addi	s0,sp,48
    800020ec:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020ee:	0000e497          	auipc	s1,0xe
    800020f2:	dd248493          	addi	s1,s1,-558 # 8000fec0 <proc>
    800020f6:	00014997          	auipc	s3,0x14
    800020fa:	bca98993          	addi	s3,s3,-1078 # 80015cc0 <tickslock>
    acquire(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	a6dfe0ef          	jal	ra,80000b6c <acquire>
    if(p->pid == pid){
    80002104:	589c                	lw	a5,48(s1)
    80002106:	01278b63          	beq	a5,s2,8000211c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000210a:	8526                	mv	a0,s1
    8000210c:	af9fe0ef          	jal	ra,80000c04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002110:	17848493          	addi	s1,s1,376
    80002114:	ff3495e3          	bne	s1,s3,800020fe <kkill+0x20>
  }
  return -1;
    80002118:	557d                	li	a0,-1
    8000211a:	a819                	j	80002130 <kkill+0x52>
      p->killed = 1;
    8000211c:	4785                	li	a5,1
    8000211e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002120:	4c98                	lw	a4,24(s1)
    80002122:	4789                	li	a5,2
    80002124:	00f70d63          	beq	a4,a5,8000213e <kkill+0x60>
      release(&p->lock);
    80002128:	8526                	mv	a0,s1
    8000212a:	adbfe0ef          	jal	ra,80000c04 <release>
      return 0;
    8000212e:	4501                	li	a0,0
}
    80002130:	70a2                	ld	ra,40(sp)
    80002132:	7402                	ld	s0,32(sp)
    80002134:	64e2                	ld	s1,24(sp)
    80002136:	6942                	ld	s2,16(sp)
    80002138:	69a2                	ld	s3,8(sp)
    8000213a:	6145                	addi	sp,sp,48
    8000213c:	8082                	ret
        p->state = RUNNABLE;
    8000213e:	478d                	li	a5,3
    80002140:	cc9c                	sw	a5,24(s1)
    80002142:	b7dd                	j	80002128 <kkill+0x4a>

0000000080002144 <setkilled>:

void
setkilled(struct proc *p)
{
    80002144:	1101                	addi	sp,sp,-32
    80002146:	ec06                	sd	ra,24(sp)
    80002148:	e822                	sd	s0,16(sp)
    8000214a:	e426                	sd	s1,8(sp)
    8000214c:	1000                	addi	s0,sp,32
    8000214e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002150:	a1dfe0ef          	jal	ra,80000b6c <acquire>
  p->killed = 1;
    80002154:	4785                	li	a5,1
    80002156:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002158:	8526                	mv	a0,s1
    8000215a:	aabfe0ef          	jal	ra,80000c04 <release>
}
    8000215e:	60e2                	ld	ra,24(sp)
    80002160:	6442                	ld	s0,16(sp)
    80002162:	64a2                	ld	s1,8(sp)
    80002164:	6105                	addi	sp,sp,32
    80002166:	8082                	ret

0000000080002168 <killed>:

int
killed(struct proc *p)
{
    80002168:	1101                	addi	sp,sp,-32
    8000216a:	ec06                	sd	ra,24(sp)
    8000216c:	e822                	sd	s0,16(sp)
    8000216e:	e426                	sd	s1,8(sp)
    80002170:	e04a                	sd	s2,0(sp)
    80002172:	1000                	addi	s0,sp,32
    80002174:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002176:	9f7fe0ef          	jal	ra,80000b6c <acquire>
  k = p->killed;
    8000217a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	a85fe0ef          	jal	ra,80000c04 <release>
  return k;
}
    80002184:	854a                	mv	a0,s2
    80002186:	60e2                	ld	ra,24(sp)
    80002188:	6442                	ld	s0,16(sp)
    8000218a:	64a2                	ld	s1,8(sp)
    8000218c:	6902                	ld	s2,0(sp)
    8000218e:	6105                	addi	sp,sp,32
    80002190:	8082                	ret

0000000080002192 <kwait>:
{
    80002192:	715d                	addi	sp,sp,-80
    80002194:	e486                	sd	ra,72(sp)
    80002196:	e0a2                	sd	s0,64(sp)
    80002198:	fc26                	sd	s1,56(sp)
    8000219a:	f84a                	sd	s2,48(sp)
    8000219c:	f44e                	sd	s3,40(sp)
    8000219e:	f052                	sd	s4,32(sp)
    800021a0:	ec56                	sd	s5,24(sp)
    800021a2:	e85a                	sd	s6,16(sp)
    800021a4:	e45e                	sd	s7,8(sp)
    800021a6:	e062                	sd	s8,0(sp)
    800021a8:	0880                	addi	s0,sp,80
    800021aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021ac:	e6cff0ef          	jal	ra,80001818 <myproc>
    800021b0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021b2:	0000e517          	auipc	a0,0xe
    800021b6:	8de50513          	addi	a0,a0,-1826 # 8000fa90 <wait_lock>
    800021ba:	9b3fe0ef          	jal	ra,80000b6c <acquire>
    havekids = 0;
    800021be:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800021c0:	4a15                	li	s4,5
        havekids = 1;
    800021c2:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021c4:	00014997          	auipc	s3,0x14
    800021c8:	afc98993          	addi	s3,s3,-1284 # 80015cc0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021cc:	0000ec17          	auipc	s8,0xe
    800021d0:	8c4c0c13          	addi	s8,s8,-1852 # 8000fa90 <wait_lock>
    havekids = 0;
    800021d4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d6:	0000e497          	auipc	s1,0xe
    800021da:	cea48493          	addi	s1,s1,-790 # 8000fec0 <proc>
    800021de:	a899                	j	80002234 <kwait+0xa2>
          pid = pp->pid;
    800021e0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021e4:	000b0c63          	beqz	s6,800021fc <kwait+0x6a>
    800021e8:	4691                	li	a3,4
    800021ea:	02c48613          	addi	a2,s1,44
    800021ee:	85da                	mv	a1,s6
    800021f0:	05093503          	ld	a0,80(s2)
    800021f4:	b5eff0ef          	jal	ra,80001552 <copyout>
    800021f8:	00054f63          	bltz	a0,80002216 <kwait+0x84>
          freeproc(pp);
    800021fc:	8526                	mv	a0,s1
    800021fe:	feaff0ef          	jal	ra,800019e8 <freeproc>
          release(&pp->lock);
    80002202:	8526                	mv	a0,s1
    80002204:	a01fe0ef          	jal	ra,80000c04 <release>
          release(&wait_lock);
    80002208:	0000e517          	auipc	a0,0xe
    8000220c:	88850513          	addi	a0,a0,-1912 # 8000fa90 <wait_lock>
    80002210:	9f5fe0ef          	jal	ra,80000c04 <release>
          return pid;
    80002214:	a891                	j	80002268 <kwait+0xd6>
            release(&pp->lock);
    80002216:	8526                	mv	a0,s1
    80002218:	9edfe0ef          	jal	ra,80000c04 <release>
            release(&wait_lock);
    8000221c:	0000e517          	auipc	a0,0xe
    80002220:	87450513          	addi	a0,a0,-1932 # 8000fa90 <wait_lock>
    80002224:	9e1fe0ef          	jal	ra,80000c04 <release>
            return -1;
    80002228:	59fd                	li	s3,-1
    8000222a:	a83d                	j	80002268 <kwait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000222c:	17848493          	addi	s1,s1,376
    80002230:	03348063          	beq	s1,s3,80002250 <kwait+0xbe>
      if(pp->parent == p){
    80002234:	7c9c                	ld	a5,56(s1)
    80002236:	ff279be3          	bne	a5,s2,8000222c <kwait+0x9a>
        acquire(&pp->lock);
    8000223a:	8526                	mv	a0,s1
    8000223c:	931fe0ef          	jal	ra,80000b6c <acquire>
        if(pp->state == ZOMBIE){
    80002240:	4c9c                	lw	a5,24(s1)
    80002242:	f9478fe3          	beq	a5,s4,800021e0 <kwait+0x4e>
        release(&pp->lock);
    80002246:	8526                	mv	a0,s1
    80002248:	9bdfe0ef          	jal	ra,80000c04 <release>
        havekids = 1;
    8000224c:	8756                	mv	a4,s5
    8000224e:	bff9                	j	8000222c <kwait+0x9a>
    if(!havekids || killed(p)){
    80002250:	c709                	beqz	a4,8000225a <kwait+0xc8>
    80002252:	854a                	mv	a0,s2
    80002254:	f15ff0ef          	jal	ra,80002168 <killed>
    80002258:	c50d                	beqz	a0,80002282 <kwait+0xf0>
      release(&wait_lock);
    8000225a:	0000e517          	auipc	a0,0xe
    8000225e:	83650513          	addi	a0,a0,-1994 # 8000fa90 <wait_lock>
    80002262:	9a3fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002266:	59fd                	li	s3,-1
}
    80002268:	854e                	mv	a0,s3
    8000226a:	60a6                	ld	ra,72(sp)
    8000226c:	6406                	ld	s0,64(sp)
    8000226e:	74e2                	ld	s1,56(sp)
    80002270:	7942                	ld	s2,48(sp)
    80002272:	79a2                	ld	s3,40(sp)
    80002274:	7a02                	ld	s4,32(sp)
    80002276:	6ae2                	ld	s5,24(sp)
    80002278:	6b42                	ld	s6,16(sp)
    8000227a:	6ba2                	ld	s7,8(sp)
    8000227c:	6c02                	ld	s8,0(sp)
    8000227e:	6161                	addi	sp,sp,80
    80002280:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002282:	85e2                	mv	a1,s8
    80002284:	854a                	mv	a0,s2
    80002286:	cabff0ef          	jal	ra,80001f30 <sleep>
    havekids = 0;
    8000228a:	b7a9                	j	800021d4 <kwait+0x42>

000000008000228c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000228c:	7179                	addi	sp,sp,-48
    8000228e:	f406                	sd	ra,40(sp)
    80002290:	f022                	sd	s0,32(sp)
    80002292:	ec26                	sd	s1,24(sp)
    80002294:	e84a                	sd	s2,16(sp)
    80002296:	e44e                	sd	s3,8(sp)
    80002298:	e052                	sd	s4,0(sp)
    8000229a:	1800                	addi	s0,sp,48
    8000229c:	84aa                	mv	s1,a0
    8000229e:	892e                	mv	s2,a1
    800022a0:	89b2                	mv	s3,a2
    800022a2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a4:	d74ff0ef          	jal	ra,80001818 <myproc>
  if(user_dst){
    800022a8:	cc99                	beqz	s1,800022c6 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022aa:	86d2                	mv	a3,s4
    800022ac:	864e                	mv	a2,s3
    800022ae:	85ca                	mv	a1,s2
    800022b0:	6928                	ld	a0,80(a0)
    800022b2:	aa0ff0ef          	jal	ra,80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022b6:	70a2                	ld	ra,40(sp)
    800022b8:	7402                	ld	s0,32(sp)
    800022ba:	64e2                	ld	s1,24(sp)
    800022bc:	6942                	ld	s2,16(sp)
    800022be:	69a2                	ld	s3,8(sp)
    800022c0:	6a02                	ld	s4,0(sp)
    800022c2:	6145                	addi	sp,sp,48
    800022c4:	8082                	ret
    memmove((char *)dst, src, len);
    800022c6:	000a061b          	sext.w	a2,s4
    800022ca:	85ce                	mv	a1,s3
    800022cc:	854a                	mv	a0,s2
    800022ce:	9cffe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    800022d2:	8526                	mv	a0,s1
    800022d4:	b7cd                	j	800022b6 <either_copyout+0x2a>

00000000800022d6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022d6:	7179                	addi	sp,sp,-48
    800022d8:	f406                	sd	ra,40(sp)
    800022da:	f022                	sd	s0,32(sp)
    800022dc:	ec26                	sd	s1,24(sp)
    800022de:	e84a                	sd	s2,16(sp)
    800022e0:	e44e                	sd	s3,8(sp)
    800022e2:	e052                	sd	s4,0(sp)
    800022e4:	1800                	addi	s0,sp,48
    800022e6:	892a                	mv	s2,a0
    800022e8:	84ae                	mv	s1,a1
    800022ea:	89b2                	mv	s3,a2
    800022ec:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ee:	d2aff0ef          	jal	ra,80001818 <myproc>
  if(user_src){
    800022f2:	cc99                	beqz	s1,80002310 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022f4:	86d2                	mv	a3,s4
    800022f6:	864e                	mv	a2,s3
    800022f8:	85ca                	mv	a1,s2
    800022fa:	6928                	ld	a0,80(a0)
    800022fc:	b1cff0ef          	jal	ra,80001618 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002300:	70a2                	ld	ra,40(sp)
    80002302:	7402                	ld	s0,32(sp)
    80002304:	64e2                	ld	s1,24(sp)
    80002306:	6942                	ld	s2,16(sp)
    80002308:	69a2                	ld	s3,8(sp)
    8000230a:	6a02                	ld	s4,0(sp)
    8000230c:	6145                	addi	sp,sp,48
    8000230e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002310:	000a061b          	sext.w	a2,s4
    80002314:	85ce                	mv	a1,s3
    80002316:	854a                	mv	a0,s2
    80002318:	985fe0ef          	jal	ra,80000c9c <memmove>
    return 0;
    8000231c:	8526                	mv	a0,s1
    8000231e:	b7cd                	j	80002300 <either_copyin+0x2a>

0000000080002320 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002320:	715d                	addi	sp,sp,-80
    80002322:	e486                	sd	ra,72(sp)
    80002324:	e0a2                	sd	s0,64(sp)
    80002326:	fc26                	sd	s1,56(sp)
    80002328:	f84a                	sd	s2,48(sp)
    8000232a:	f44e                	sd	s3,40(sp)
    8000232c:	f052                	sd	s4,32(sp)
    8000232e:	ec56                	sd	s5,24(sp)
    80002330:	e85a                	sd	s6,16(sp)
    80002332:	e45e                	sd	s7,8(sp)
    80002334:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002336:	00005517          	auipc	a0,0x5
    8000233a:	d8a50513          	addi	a0,a0,-630 # 800070c0 <digits+0x88>
    8000233e:	986fe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002342:	0000e497          	auipc	s1,0xe
    80002346:	cd648493          	addi	s1,s1,-810 # 80010018 <proc+0x158>
    8000234a:	00014917          	auipc	s2,0x14
    8000234e:	ace90913          	addi	s2,s2,-1330 # 80015e18 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002352:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002354:	00005997          	auipc	s3,0x5
    80002358:	f5c98993          	addi	s3,s3,-164 # 800072b0 <digits+0x278>
    printf("%d %s %s", p->pid, state, p->name);
    8000235c:	00005a97          	auipc	s5,0x5
    80002360:	f5ca8a93          	addi	s5,s5,-164 # 800072b8 <digits+0x280>
    printf("\n");
    80002364:	00005a17          	auipc	s4,0x5
    80002368:	d5ca0a13          	addi	s4,s4,-676 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000236c:	00005b97          	auipc	s7,0x5
    80002370:	f8cb8b93          	addi	s7,s7,-116 # 800072f8 <states.0>
    80002374:	a829                	j	8000238e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002376:	ed86a583          	lw	a1,-296(a3)
    8000237a:	8556                	mv	a0,s5
    8000237c:	948fe0ef          	jal	ra,800004c4 <printf>
    printf("\n");
    80002380:	8552                	mv	a0,s4
    80002382:	942fe0ef          	jal	ra,800004c4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002386:	17848493          	addi	s1,s1,376
    8000238a:	03248163          	beq	s1,s2,800023ac <procdump+0x8c>
    if(p->state == UNUSED)
    8000238e:	86a6                	mv	a3,s1
    80002390:	ec04a783          	lw	a5,-320(s1)
    80002394:	dbed                	beqz	a5,80002386 <procdump+0x66>
      state = "???";
    80002396:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002398:	fcfb6fe3          	bltu	s6,a5,80002376 <procdump+0x56>
    8000239c:	1782                	slli	a5,a5,0x20
    8000239e:	9381                	srli	a5,a5,0x20
    800023a0:	078e                	slli	a5,a5,0x3
    800023a2:	97de                	add	a5,a5,s7
    800023a4:	6390                	ld	a2,0(a5)
    800023a6:	fa61                	bnez	a2,80002376 <procdump+0x56>
      state = "???";
    800023a8:	864e                	mv	a2,s3
    800023aa:	b7f1                	j	80002376 <procdump+0x56>
  }
}
    800023ac:	60a6                	ld	ra,72(sp)
    800023ae:	6406                	ld	s0,64(sp)
    800023b0:	74e2                	ld	s1,56(sp)
    800023b2:	7942                	ld	s2,48(sp)
    800023b4:	79a2                	ld	s3,40(sp)
    800023b6:	7a02                	ld	s4,32(sp)
    800023b8:	6ae2                	ld	s5,24(sp)
    800023ba:	6b42                	ld	s6,16(sp)
    800023bc:	6ba2                	ld	s7,8(sp)
    800023be:	6161                	addi	sp,sp,80
    800023c0:	8082                	ret

00000000800023c2 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800023c2:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800023c6:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800023ca:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800023cc:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800023ce:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800023d2:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800023d6:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023da:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023de:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023e2:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023e6:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023ea:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023ee:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023f2:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023f6:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023fa:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023fe:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002400:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002402:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002406:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000240a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000240e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002412:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002416:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000241a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000241e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002422:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002426:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000242a:	8082                	ret

000000008000242c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000242c:	1141                	addi	sp,sp,-16
    8000242e:	e406                	sd	ra,8(sp)
    80002430:	e022                	sd	s0,0(sp)
    80002432:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002434:	00005597          	auipc	a1,0x5
    80002438:	ef458593          	addi	a1,a1,-268 # 80007328 <states.0+0x30>
    8000243c:	00014517          	auipc	a0,0x14
    80002440:	88450513          	addi	a0,a0,-1916 # 80015cc0 <tickslock>
    80002444:	ea8fe0ef          	jal	ra,80000aec <initlock>
}
    80002448:	60a2                	ld	ra,8(sp)
    8000244a:	6402                	ld	s0,0(sp)
    8000244c:	0141                	addi	sp,sp,16
    8000244e:	8082                	ret

0000000080002450 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002450:	1141                	addi	sp,sp,-16
    80002452:	e422                	sd	s0,8(sp)
    80002454:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002456:	00003797          	auipc	a5,0x3
    8000245a:	f3a78793          	addi	a5,a5,-198 # 80005390 <kernelvec>
    8000245e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002462:	6422                	ld	s0,8(sp)
    80002464:	0141                	addi	sp,sp,16
    80002466:	8082                	ret

0000000080002468 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002468:	1141                	addi	sp,sp,-16
    8000246a:	e406                	sd	ra,8(sp)
    8000246c:	e022                	sd	s0,0(sp)
    8000246e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002470:	ba8ff0ef          	jal	ra,80001818 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002474:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002478:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000247a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000247e:	04000737          	lui	a4,0x4000
    80002482:	00004797          	auipc	a5,0x4
    80002486:	b7e78793          	addi	a5,a5,-1154 # 80006000 <_trampoline>
    8000248a:	00004697          	auipc	a3,0x4
    8000248e:	b7668693          	addi	a3,a3,-1162 # 80006000 <_trampoline>
    80002492:	8f95                	sub	a5,a5,a3
    80002494:	177d                	addi	a4,a4,-1
    80002496:	0732                	slli	a4,a4,0xc
    80002498:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000249a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000249e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024a0:	18002773          	csrr	a4,satp
    800024a4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024a6:	6d38                	ld	a4,88(a0)
    800024a8:	613c                	ld	a5,64(a0)
    800024aa:	6685                	lui	a3,0x1
    800024ac:	97b6                	add	a5,a5,a3
    800024ae:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024b0:	6d3c                	ld	a5,88(a0)
    800024b2:	00000717          	auipc	a4,0x0
    800024b6:	0f470713          	addi	a4,a4,244 # 800025a6 <usertrap>
    800024ba:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024bc:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024be:	8712                	mv	a4,tp
    800024c0:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024c2:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024c6:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024ca:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024ce:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024d2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024d4:	6f9c                	ld	a5,24(a5)
    800024d6:	14179073          	csrw	sepc,a5
}
    800024da:	60a2                	ld	ra,8(sp)
    800024dc:	6402                	ld	s0,0(sp)
    800024de:	0141                	addi	sp,sp,16
    800024e0:	8082                	ret

00000000800024e2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024e2:	1101                	addi	sp,sp,-32
    800024e4:	ec06                	sd	ra,24(sp)
    800024e6:	e822                	sd	s0,16(sp)
    800024e8:	e426                	sd	s1,8(sp)
    800024ea:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024ec:	b00ff0ef          	jal	ra,800017ec <cpuid>
    800024f0:	cd19                	beqz	a0,8000250e <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024f2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024f6:	000f4737          	lui	a4,0xf4
    800024fa:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024fe:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002500:	14d79073          	csrw	0x14d,a5
}
    80002504:	60e2                	ld	ra,24(sp)
    80002506:	6442                	ld	s0,16(sp)
    80002508:	64a2                	ld	s1,8(sp)
    8000250a:	6105                	addi	sp,sp,32
    8000250c:	8082                	ret
    acquire(&tickslock);
    8000250e:	00013497          	auipc	s1,0x13
    80002512:	7b248493          	addi	s1,s1,1970 # 80015cc0 <tickslock>
    80002516:	8526                	mv	a0,s1
    80002518:	e54fe0ef          	jal	ra,80000b6c <acquire>
    ticks++;
    8000251c:	00005517          	auipc	a0,0x5
    80002520:	45450513          	addi	a0,a0,1108 # 80007970 <ticks>
    80002524:	411c                	lw	a5,0(a0)
    80002526:	2785                	addiw	a5,a5,1
    80002528:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000252a:	a53ff0ef          	jal	ra,80001f7c <wakeup>
    release(&tickslock);
    8000252e:	8526                	mv	a0,s1
    80002530:	ed4fe0ef          	jal	ra,80000c04 <release>
    80002534:	bf7d                	j	800024f2 <clockintr+0x10>

0000000080002536 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002536:	1101                	addi	sp,sp,-32
    80002538:	ec06                	sd	ra,24(sp)
    8000253a:	e822                	sd	s0,16(sp)
    8000253c:	e426                	sd	s1,8(sp)
    8000253e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002540:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002544:	57fd                	li	a5,-1
    80002546:	17fe                	slli	a5,a5,0x3f
    80002548:	07a5                	addi	a5,a5,9
    8000254a:	00f70d63          	beq	a4,a5,80002564 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000254e:	57fd                	li	a5,-1
    80002550:	17fe                	slli	a5,a5,0x3f
    80002552:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002554:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002556:	04f70463          	beq	a4,a5,8000259e <devintr+0x68>
  }
}
    8000255a:	60e2                	ld	ra,24(sp)
    8000255c:	6442                	ld	s0,16(sp)
    8000255e:	64a2                	ld	s1,8(sp)
    80002560:	6105                	addi	sp,sp,32
    80002562:	8082                	ret
    int irq = plic_claim();
    80002564:	6d5020ef          	jal	ra,80005438 <plic_claim>
    80002568:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000256a:	47a9                	li	a5,10
    8000256c:	02f50363          	beq	a0,a5,80002592 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002570:	4785                	li	a5,1
    80002572:	02f50363          	beq	a0,a5,80002598 <devintr+0x62>
    return 1;
    80002576:	4505                	li	a0,1
    } else if(irq){
    80002578:	d0ed                	beqz	s1,8000255a <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    8000257a:	85a6                	mv	a1,s1
    8000257c:	00005517          	auipc	a0,0x5
    80002580:	db450513          	addi	a0,a0,-588 # 80007330 <states.0+0x38>
    80002584:	f41fd0ef          	jal	ra,800004c4 <printf>
      plic_complete(irq);
    80002588:	8526                	mv	a0,s1
    8000258a:	6cf020ef          	jal	ra,80005458 <plic_complete>
    return 1;
    8000258e:	4505                	li	a0,1
    80002590:	b7e9                	j	8000255a <devintr+0x24>
      uartintr();
    80002592:	bc6fe0ef          	jal	ra,80000958 <uartintr>
    80002596:	bfcd                	j	80002588 <devintr+0x52>
      virtio_disk_intr();
    80002598:	330030ef          	jal	ra,800058c8 <virtio_disk_intr>
    8000259c:	b7f5                	j	80002588 <devintr+0x52>
    clockintr();
    8000259e:	f45ff0ef          	jal	ra,800024e2 <clockintr>
    return 2;
    800025a2:	4509                	li	a0,2
    800025a4:	bf5d                	j	8000255a <devintr+0x24>

00000000800025a6 <usertrap>:
{
    800025a6:	1101                	addi	sp,sp,-32
    800025a8:	ec06                	sd	ra,24(sp)
    800025aa:	e822                	sd	s0,16(sp)
    800025ac:	e426                	sd	s1,8(sp)
    800025ae:	e04a                	sd	s2,0(sp)
    800025b0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025b2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025b6:	1007f793          	andi	a5,a5,256
    800025ba:	eba5                	bnez	a5,8000262a <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025bc:	00003797          	auipc	a5,0x3
    800025c0:	dd478793          	addi	a5,a5,-556 # 80005390 <kernelvec>
    800025c4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025c8:	a50ff0ef          	jal	ra,80001818 <myproc>
    800025cc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025ce:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025d0:	14102773          	csrr	a4,sepc
    800025d4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025d6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025da:	47a1                	li	a5,8
    800025dc:	04f70d63          	beq	a4,a5,80002636 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800025e0:	f57ff0ef          	jal	ra,80002536 <devintr>
    800025e4:	892a                	mv	s2,a0
    800025e6:	e945                	bnez	a0,80002696 <usertrap+0xf0>
    800025e8:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025ec:	47bd                	li	a5,15
    800025ee:	08f70863          	beq	a4,a5,8000267e <usertrap+0xd8>
    800025f2:	14202773          	csrr	a4,scause
    800025f6:	47b5                	li	a5,13
    800025f8:	08f70363          	beq	a4,a5,8000267e <usertrap+0xd8>
    800025fc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002600:	5890                	lw	a2,48(s1)
    80002602:	00005517          	auipc	a0,0x5
    80002606:	d6e50513          	addi	a0,a0,-658 # 80007370 <states.0+0x78>
    8000260a:	ebbfd0ef          	jal	ra,800004c4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000260e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002612:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002616:	00005517          	auipc	a0,0x5
    8000261a:	d8a50513          	addi	a0,a0,-630 # 800073a0 <states.0+0xa8>
    8000261e:	ea7fd0ef          	jal	ra,800004c4 <printf>
    setkilled(p);
    80002622:	8526                	mv	a0,s1
    80002624:	b21ff0ef          	jal	ra,80002144 <setkilled>
    80002628:	a035                	j	80002654 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000262a:	00005517          	auipc	a0,0x5
    8000262e:	d2650513          	addi	a0,a0,-730 # 80007350 <states.0+0x58>
    80002632:	958fe0ef          	jal	ra,8000078a <panic>
    if(killed(p))
    80002636:	b33ff0ef          	jal	ra,80002168 <killed>
    8000263a:	ed15                	bnez	a0,80002676 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000263c:	6cb8                	ld	a4,88(s1)
    8000263e:	6f1c                	ld	a5,24(a4)
    80002640:	0791                	addi	a5,a5,4
    80002642:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002644:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002648:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000264c:	10079073          	csrw	sstatus,a5
    syscall();
    80002650:	29a000ef          	jal	ra,800028ea <syscall>
  if(killed(p))
    80002654:	8526                	mv	a0,s1
    80002656:	b13ff0ef          	jal	ra,80002168 <killed>
    8000265a:	e139                	bnez	a0,800026a0 <usertrap+0xfa>
  prepare_return();
    8000265c:	e0dff0ef          	jal	ra,80002468 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002660:	68a8                	ld	a0,80(s1)
    80002662:	8131                	srli	a0,a0,0xc
    80002664:	57fd                	li	a5,-1
    80002666:	17fe                	slli	a5,a5,0x3f
    80002668:	8d5d                	or	a0,a0,a5
}
    8000266a:	60e2                	ld	ra,24(sp)
    8000266c:	6442                	ld	s0,16(sp)
    8000266e:	64a2                	ld	s1,8(sp)
    80002670:	6902                	ld	s2,0(sp)
    80002672:	6105                	addi	sp,sp,32
    80002674:	8082                	ret
      kexit(-1);
    80002676:	557d                	li	a0,-1
    80002678:	9c5ff0ef          	jal	ra,8000203c <kexit>
    8000267c:	b7c1                	j	8000263c <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000267e:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002682:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002686:	164d                	addi	a2,a2,-13
    80002688:	00163613          	seqz	a2,a2
    8000268c:	68a8                	ld	a0,80(s1)
    8000268e:	e53fe0ef          	jal	ra,800014e0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002692:	f169                	bnez	a0,80002654 <usertrap+0xae>
    80002694:	b7a5                	j	800025fc <usertrap+0x56>
  if(killed(p))
    80002696:	8526                	mv	a0,s1
    80002698:	ad1ff0ef          	jal	ra,80002168 <killed>
    8000269c:	c511                	beqz	a0,800026a8 <usertrap+0x102>
    8000269e:	a011                	j	800026a2 <usertrap+0xfc>
    800026a0:	4901                	li	s2,0
    kexit(-1);
    800026a2:	557d                	li	a0,-1
    800026a4:	999ff0ef          	jal	ra,8000203c <kexit>
  if(which_dev == 2) {
    800026a8:	4789                	li	a5,2
    800026aa:	faf919e3          	bne	s2,a5,8000265c <usertrap+0xb6>
    p->time_slices++;
    800026ae:	16c4a783          	lw	a5,364(s1)
    800026b2:	2785                	addiw	a5,a5,1
    800026b4:	0007871b          	sext.w	a4,a5
    800026b8:	16f4a623          	sw	a5,364(s1)
    if(p->time_slices >= mlfq_time_quanta[p->priority]) {
    800026bc:	1684a603          	lw	a2,360(s1)
    800026c0:	00261693          	slli	a3,a2,0x2
    800026c4:	00005797          	auipc	a5,0x5
    800026c8:	26c78793          	addi	a5,a5,620 # 80007930 <mlfq_time_quanta>
    800026cc:	97b6                	add	a5,a5,a3
    800026ce:	439c                	lw	a5,0(a5)
    800026d0:	02f74963          	blt	a4,a5,80002702 <usertrap+0x15c>
      printf("[MLFQ] PID %d: Q%d->Q%d (slices=%d)\n", 
    800026d4:	588c                	lw	a1,48(s1)
    800026d6:	4789                	li	a5,2
    800026d8:	86b2                	mv	a3,a2
    800026da:	00c7c463          	blt	a5,a2,800026e2 <usertrap+0x13c>
    800026de:	0016069b          	addiw	a3,a2,1
    800026e2:	00005517          	auipc	a0,0x5
    800026e6:	ce650513          	addi	a0,a0,-794 # 800073c8 <states.0+0xd0>
    800026ea:	ddbfd0ef          	jal	ra,800004c4 <printf>
      if(p->priority < NMLFQ - 1) {
    800026ee:	1684a783          	lw	a5,360(s1)
    800026f2:	4709                	li	a4,2
    800026f4:	00f74563          	blt	a4,a5,800026fe <usertrap+0x158>
        p->priority++;  // Move to lower priority queue
    800026f8:	2785                	addiw	a5,a5,1
    800026fa:	16f4a423          	sw	a5,360(s1)
      p->time_slices = 0;  // Reset time slice counter for new queue
    800026fe:	1604a623          	sw	zero,364(s1)
    yield();
    80002702:	803ff0ef          	jal	ra,80001f04 <yield>
    80002706:	bf99                	j	8000265c <usertrap+0xb6>

0000000080002708 <kerneltrap>:
{
    80002708:	7179                	addi	sp,sp,-48
    8000270a:	f406                	sd	ra,40(sp)
    8000270c:	f022                	sd	s0,32(sp)
    8000270e:	ec26                	sd	s1,24(sp)
    80002710:	e84a                	sd	s2,16(sp)
    80002712:	e44e                	sd	s3,8(sp)
    80002714:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002716:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000271a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000271e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002722:	1004f793          	andi	a5,s1,256
    80002726:	c795                	beqz	a5,80002752 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002728:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000272c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000272e:	eb85                	bnez	a5,8000275e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002730:	e07ff0ef          	jal	ra,80002536 <devintr>
    80002734:	c91d                	beqz	a0,8000276a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002736:	4789                	li	a5,2
    80002738:	04f50a63          	beq	a0,a5,8000278c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000273c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002740:	10049073          	csrw	sstatus,s1
}
    80002744:	70a2                	ld	ra,40(sp)
    80002746:	7402                	ld	s0,32(sp)
    80002748:	64e2                	ld	s1,24(sp)
    8000274a:	6942                	ld	s2,16(sp)
    8000274c:	69a2                	ld	s3,8(sp)
    8000274e:	6145                	addi	sp,sp,48
    80002750:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002752:	00005517          	auipc	a0,0x5
    80002756:	c9e50513          	addi	a0,a0,-866 # 800073f0 <states.0+0xf8>
    8000275a:	830fe0ef          	jal	ra,8000078a <panic>
    panic("kerneltrap: interrupts enabled");
    8000275e:	00005517          	auipc	a0,0x5
    80002762:	cba50513          	addi	a0,a0,-838 # 80007418 <states.0+0x120>
    80002766:	824fe0ef          	jal	ra,8000078a <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000276a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000276e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002772:	85ce                	mv	a1,s3
    80002774:	00005517          	auipc	a0,0x5
    80002778:	cc450513          	addi	a0,a0,-828 # 80007438 <states.0+0x140>
    8000277c:	d49fd0ef          	jal	ra,800004c4 <printf>
    panic("kerneltrap");
    80002780:	00005517          	auipc	a0,0x5
    80002784:	ce050513          	addi	a0,a0,-800 # 80007460 <states.0+0x168>
    80002788:	802fe0ef          	jal	ra,8000078a <panic>
  if(which_dev == 2 && myproc() != 0)
    8000278c:	88cff0ef          	jal	ra,80001818 <myproc>
    80002790:	d555                	beqz	a0,8000273c <kerneltrap+0x34>
    yield();
    80002792:	f72ff0ef          	jal	ra,80001f04 <yield>
    80002796:	b75d                	j	8000273c <kerneltrap+0x34>

0000000080002798 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002798:	1101                	addi	sp,sp,-32
    8000279a:	ec06                	sd	ra,24(sp)
    8000279c:	e822                	sd	s0,16(sp)
    8000279e:	e426                	sd	s1,8(sp)
    800027a0:	1000                	addi	s0,sp,32
    800027a2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027a4:	874ff0ef          	jal	ra,80001818 <myproc>
  switch (n) {
    800027a8:	4795                	li	a5,5
    800027aa:	0497e163          	bltu	a5,s1,800027ec <argraw+0x54>
    800027ae:	048a                	slli	s1,s1,0x2
    800027b0:	00005717          	auipc	a4,0x5
    800027b4:	ce870713          	addi	a4,a4,-792 # 80007498 <states.0+0x1a0>
    800027b8:	94ba                	add	s1,s1,a4
    800027ba:	409c                	lw	a5,0(s1)
    800027bc:	97ba                	add	a5,a5,a4
    800027be:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027c0:	6d3c                	ld	a5,88(a0)
    800027c2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027c4:	60e2                	ld	ra,24(sp)
    800027c6:	6442                	ld	s0,16(sp)
    800027c8:	64a2                	ld	s1,8(sp)
    800027ca:	6105                	addi	sp,sp,32
    800027cc:	8082                	ret
    return p->trapframe->a1;
    800027ce:	6d3c                	ld	a5,88(a0)
    800027d0:	7fa8                	ld	a0,120(a5)
    800027d2:	bfcd                	j	800027c4 <argraw+0x2c>
    return p->trapframe->a2;
    800027d4:	6d3c                	ld	a5,88(a0)
    800027d6:	63c8                	ld	a0,128(a5)
    800027d8:	b7f5                	j	800027c4 <argraw+0x2c>
    return p->trapframe->a3;
    800027da:	6d3c                	ld	a5,88(a0)
    800027dc:	67c8                	ld	a0,136(a5)
    800027de:	b7dd                	j	800027c4 <argraw+0x2c>
    return p->trapframe->a4;
    800027e0:	6d3c                	ld	a5,88(a0)
    800027e2:	6bc8                	ld	a0,144(a5)
    800027e4:	b7c5                	j	800027c4 <argraw+0x2c>
    return p->trapframe->a5;
    800027e6:	6d3c                	ld	a5,88(a0)
    800027e8:	6fc8                	ld	a0,152(a5)
    800027ea:	bfe9                	j	800027c4 <argraw+0x2c>
  panic("argraw");
    800027ec:	00005517          	auipc	a0,0x5
    800027f0:	c8450513          	addi	a0,a0,-892 # 80007470 <states.0+0x178>
    800027f4:	f97fd0ef          	jal	ra,8000078a <panic>

00000000800027f8 <fetchaddr>:
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	e426                	sd	s1,8(sp)
    80002800:	e04a                	sd	s2,0(sp)
    80002802:	1000                	addi	s0,sp,32
    80002804:	84aa                	mv	s1,a0
    80002806:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002808:	810ff0ef          	jal	ra,80001818 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000280c:	653c                	ld	a5,72(a0)
    8000280e:	02f4f663          	bgeu	s1,a5,8000283a <fetchaddr+0x42>
    80002812:	00848713          	addi	a4,s1,8
    80002816:	02e7e463          	bltu	a5,a4,8000283e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000281a:	46a1                	li	a3,8
    8000281c:	8626                	mv	a2,s1
    8000281e:	85ca                	mv	a1,s2
    80002820:	6928                	ld	a0,80(a0)
    80002822:	df7fe0ef          	jal	ra,80001618 <copyin>
    80002826:	00a03533          	snez	a0,a0
    8000282a:	40a00533          	neg	a0,a0
}
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6902                	ld	s2,0(sp)
    80002836:	6105                	addi	sp,sp,32
    80002838:	8082                	ret
    return -1;
    8000283a:	557d                	li	a0,-1
    8000283c:	bfcd                	j	8000282e <fetchaddr+0x36>
    8000283e:	557d                	li	a0,-1
    80002840:	b7fd                	j	8000282e <fetchaddr+0x36>

0000000080002842 <fetchstr>:
{
    80002842:	7179                	addi	sp,sp,-48
    80002844:	f406                	sd	ra,40(sp)
    80002846:	f022                	sd	s0,32(sp)
    80002848:	ec26                	sd	s1,24(sp)
    8000284a:	e84a                	sd	s2,16(sp)
    8000284c:	e44e                	sd	s3,8(sp)
    8000284e:	1800                	addi	s0,sp,48
    80002850:	892a                	mv	s2,a0
    80002852:	84ae                	mv	s1,a1
    80002854:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002856:	fc3fe0ef          	jal	ra,80001818 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000285a:	86ce                	mv	a3,s3
    8000285c:	864a                	mv	a2,s2
    8000285e:	85a6                	mv	a1,s1
    80002860:	6928                	ld	a0,80(a0)
    80002862:	baffe0ef          	jal	ra,80001410 <copyinstr>
    80002866:	00054c63          	bltz	a0,8000287e <fetchstr+0x3c>
  return strlen(buf);
    8000286a:	8526                	mv	a0,s1
    8000286c:	d4cfe0ef          	jal	ra,80000db8 <strlen>
}
    80002870:	70a2                	ld	ra,40(sp)
    80002872:	7402                	ld	s0,32(sp)
    80002874:	64e2                	ld	s1,24(sp)
    80002876:	6942                	ld	s2,16(sp)
    80002878:	69a2                	ld	s3,8(sp)
    8000287a:	6145                	addi	sp,sp,48
    8000287c:	8082                	ret
    return -1;
    8000287e:	557d                	li	a0,-1
    80002880:	bfc5                	j	80002870 <fetchstr+0x2e>

0000000080002882 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002882:	1101                	addi	sp,sp,-32
    80002884:	ec06                	sd	ra,24(sp)
    80002886:	e822                	sd	s0,16(sp)
    80002888:	e426                	sd	s1,8(sp)
    8000288a:	1000                	addi	s0,sp,32
    8000288c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000288e:	f0bff0ef          	jal	ra,80002798 <argraw>
    80002892:	c088                	sw	a0,0(s1)
}
    80002894:	60e2                	ld	ra,24(sp)
    80002896:	6442                	ld	s0,16(sp)
    80002898:	64a2                	ld	s1,8(sp)
    8000289a:	6105                	addi	sp,sp,32
    8000289c:	8082                	ret

000000008000289e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000289e:	1101                	addi	sp,sp,-32
    800028a0:	ec06                	sd	ra,24(sp)
    800028a2:	e822                	sd	s0,16(sp)
    800028a4:	e426                	sd	s1,8(sp)
    800028a6:	1000                	addi	s0,sp,32
    800028a8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028aa:	eefff0ef          	jal	ra,80002798 <argraw>
    800028ae:	e088                	sd	a0,0(s1)
}
    800028b0:	60e2                	ld	ra,24(sp)
    800028b2:	6442                	ld	s0,16(sp)
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret

00000000800028ba <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028ba:	7179                	addi	sp,sp,-48
    800028bc:	f406                	sd	ra,40(sp)
    800028be:	f022                	sd	s0,32(sp)
    800028c0:	ec26                	sd	s1,24(sp)
    800028c2:	e84a                	sd	s2,16(sp)
    800028c4:	1800                	addi	s0,sp,48
    800028c6:	84ae                	mv	s1,a1
    800028c8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800028ca:	fd840593          	addi	a1,s0,-40
    800028ce:	fd1ff0ef          	jal	ra,8000289e <argaddr>
  return fetchstr(addr, buf, max);
    800028d2:	864a                	mv	a2,s2
    800028d4:	85a6                	mv	a1,s1
    800028d6:	fd843503          	ld	a0,-40(s0)
    800028da:	f69ff0ef          	jal	ra,80002842 <fetchstr>
}
    800028de:	70a2                	ld	ra,40(sp)
    800028e0:	7402                	ld	s0,32(sp)
    800028e2:	64e2                	ld	s1,24(sp)
    800028e4:	6942                	ld	s2,16(sp)
    800028e6:	6145                	addi	sp,sp,48
    800028e8:	8082                	ret

00000000800028ea <syscall>:
[SYS_boostproc] sys_boostproc,
};

void
syscall(void)
{
    800028ea:	1101                	addi	sp,sp,-32
    800028ec:	ec06                	sd	ra,24(sp)
    800028ee:	e822                	sd	s0,16(sp)
    800028f0:	e426                	sd	s1,8(sp)
    800028f2:	e04a                	sd	s2,0(sp)
    800028f4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028f6:	f23fe0ef          	jal	ra,80001818 <myproc>
    800028fa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028fc:	05853903          	ld	s2,88(a0)
    80002900:	0a893783          	ld	a5,168(s2)
    80002904:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002908:	37fd                	addiw	a5,a5,-1
    8000290a:	4759                	li	a4,22
    8000290c:	00f76f63          	bltu	a4,a5,8000292a <syscall+0x40>
    80002910:	00369713          	slli	a4,a3,0x3
    80002914:	00005797          	auipc	a5,0x5
    80002918:	b9c78793          	addi	a5,a5,-1124 # 800074b0 <syscalls>
    8000291c:	97ba                	add	a5,a5,a4
    8000291e:	639c                	ld	a5,0(a5)
    80002920:	c789                	beqz	a5,8000292a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002922:	9782                	jalr	a5
    80002924:	06a93823          	sd	a0,112(s2)
    80002928:	a829                	j	80002942 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000292a:	15848613          	addi	a2,s1,344
    8000292e:	588c                	lw	a1,48(s1)
    80002930:	00005517          	auipc	a0,0x5
    80002934:	b4850513          	addi	a0,a0,-1208 # 80007478 <states.0+0x180>
    80002938:	b8dfd0ef          	jal	ra,800004c4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000293c:	6cbc                	ld	a5,88(s1)
    8000293e:	577d                	li	a4,-1
    80002940:	fbb8                	sd	a4,112(a5)
  }
}
    80002942:	60e2                	ld	ra,24(sp)
    80002944:	6442                	ld	s0,16(sp)
    80002946:	64a2                	ld	s1,8(sp)
    80002948:	6902                	ld	s2,0(sp)
    8000294a:	6105                	addi	sp,sp,32
    8000294c:	8082                	ret

000000008000294e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000294e:	1101                	addi	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002956:	fec40593          	addi	a1,s0,-20
    8000295a:	4501                	li	a0,0
    8000295c:	f27ff0ef          	jal	ra,80002882 <argint>
  kexit(n);
    80002960:	fec42503          	lw	a0,-20(s0)
    80002964:	ed8ff0ef          	jal	ra,8000203c <kexit>
  return 0;  // not reached
}
    80002968:	4501                	li	a0,0
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	6105                	addi	sp,sp,32
    80002970:	8082                	ret

0000000080002972 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002972:	1141                	addi	sp,sp,-16
    80002974:	e406                	sd	ra,8(sp)
    80002976:	e022                	sd	s0,0(sp)
    80002978:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000297a:	e9ffe0ef          	jal	ra,80001818 <myproc>
}
    8000297e:	5908                	lw	a0,48(a0)
    80002980:	60a2                	ld	ra,8(sp)
    80002982:	6402                	ld	s0,0(sp)
    80002984:	0141                	addi	sp,sp,16
    80002986:	8082                	ret

0000000080002988 <sys_fork>:

uint64
sys_fork(void)
{
    80002988:	1141                	addi	sp,sp,-16
    8000298a:	e406                	sd	ra,8(sp)
    8000298c:	e022                	sd	s0,0(sp)
    8000298e:	0800                	addi	s0,sp,16
  return kfork();
    80002990:	9f8ff0ef          	jal	ra,80001b88 <kfork>
}
    80002994:	60a2                	ld	ra,8(sp)
    80002996:	6402                	ld	s0,0(sp)
    80002998:	0141                	addi	sp,sp,16
    8000299a:	8082                	ret

000000008000299c <sys_wait>:

uint64
sys_wait(void)
{
    8000299c:	1101                	addi	sp,sp,-32
    8000299e:	ec06                	sd	ra,24(sp)
    800029a0:	e822                	sd	s0,16(sp)
    800029a2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029a4:	fe840593          	addi	a1,s0,-24
    800029a8:	4501                	li	a0,0
    800029aa:	ef5ff0ef          	jal	ra,8000289e <argaddr>
  return kwait(p);
    800029ae:	fe843503          	ld	a0,-24(s0)
    800029b2:	fe0ff0ef          	jal	ra,80002192 <kwait>
}
    800029b6:	60e2                	ld	ra,24(sp)
    800029b8:	6442                	ld	s0,16(sp)
    800029ba:	6105                	addi	sp,sp,32
    800029bc:	8082                	ret

00000000800029be <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029be:	7179                	addi	sp,sp,-48
    800029c0:	f406                	sd	ra,40(sp)
    800029c2:	f022                	sd	s0,32(sp)
    800029c4:	ec26                	sd	s1,24(sp)
    800029c6:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029c8:	fd840593          	addi	a1,s0,-40
    800029cc:	4501                	li	a0,0
    800029ce:	eb5ff0ef          	jal	ra,80002882 <argint>
  argint(1, &t);
    800029d2:	fdc40593          	addi	a1,s0,-36
    800029d6:	4505                	li	a0,1
    800029d8:	eabff0ef          	jal	ra,80002882 <argint>
  addr = myproc()->sz;
    800029dc:	e3dfe0ef          	jal	ra,80001818 <myproc>
    800029e0:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029e2:	fdc42703          	lw	a4,-36(s0)
    800029e6:	4785                	li	a5,1
    800029e8:	02f70763          	beq	a4,a5,80002a16 <sys_sbrk+0x58>
    800029ec:	fd842783          	lw	a5,-40(s0)
    800029f0:	0207c363          	bltz	a5,80002a16 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800029f4:	97a6                	add	a5,a5,s1
    800029f6:	0297ee63          	bltu	a5,s1,80002a32 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    800029fa:	02000737          	lui	a4,0x2000
    800029fe:	177d                	addi	a4,a4,-1
    80002a00:	0736                	slli	a4,a4,0xd
    80002a02:	02f76a63          	bltu	a4,a5,80002a36 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002a06:	e13fe0ef          	jal	ra,80001818 <myproc>
    80002a0a:	fd842703          	lw	a4,-40(s0)
    80002a0e:	653c                	ld	a5,72(a0)
    80002a10:	97ba                	add	a5,a5,a4
    80002a12:	e53c                	sd	a5,72(a0)
    80002a14:	a039                	j	80002a22 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a16:	fd842503          	lw	a0,-40(s0)
    80002a1a:	90cff0ef          	jal	ra,80001b26 <growproc>
    80002a1e:	00054863          	bltz	a0,80002a2e <sys_sbrk+0x70>
  }
  return addr;
}
    80002a22:	8526                	mv	a0,s1
    80002a24:	70a2                	ld	ra,40(sp)
    80002a26:	7402                	ld	s0,32(sp)
    80002a28:	64e2                	ld	s1,24(sp)
    80002a2a:	6145                	addi	sp,sp,48
    80002a2c:	8082                	ret
      return -1;
    80002a2e:	54fd                	li	s1,-1
    80002a30:	bfcd                	j	80002a22 <sys_sbrk+0x64>
      return -1;
    80002a32:	54fd                	li	s1,-1
    80002a34:	b7fd                	j	80002a22 <sys_sbrk+0x64>
      return -1;
    80002a36:	54fd                	li	s1,-1
    80002a38:	b7ed                	j	80002a22 <sys_sbrk+0x64>

0000000080002a3a <sys_pause>:

uint64
sys_pause(void)
{
    80002a3a:	7139                	addi	sp,sp,-64
    80002a3c:	fc06                	sd	ra,56(sp)
    80002a3e:	f822                	sd	s0,48(sp)
    80002a40:	f426                	sd	s1,40(sp)
    80002a42:	f04a                	sd	s2,32(sp)
    80002a44:	ec4e                	sd	s3,24(sp)
    80002a46:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a48:	fcc40593          	addi	a1,s0,-52
    80002a4c:	4501                	li	a0,0
    80002a4e:	e35ff0ef          	jal	ra,80002882 <argint>
  if(n < 0)
    80002a52:	fcc42783          	lw	a5,-52(s0)
    80002a56:	0607c563          	bltz	a5,80002ac0 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a5a:	00013517          	auipc	a0,0x13
    80002a5e:	26650513          	addi	a0,a0,614 # 80015cc0 <tickslock>
    80002a62:	90afe0ef          	jal	ra,80000b6c <acquire>
  ticks0 = ticks;
    80002a66:	00005917          	auipc	s2,0x5
    80002a6a:	f0a92903          	lw	s2,-246(s2) # 80007970 <ticks>
  while(ticks - ticks0 < n){
    80002a6e:	fcc42783          	lw	a5,-52(s0)
    80002a72:	cb8d                	beqz	a5,80002aa4 <sys_pause+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a74:	00013997          	auipc	s3,0x13
    80002a78:	24c98993          	addi	s3,s3,588 # 80015cc0 <tickslock>
    80002a7c:	00005497          	auipc	s1,0x5
    80002a80:	ef448493          	addi	s1,s1,-268 # 80007970 <ticks>
    if(killed(myproc())){
    80002a84:	d95fe0ef          	jal	ra,80001818 <myproc>
    80002a88:	ee0ff0ef          	jal	ra,80002168 <killed>
    80002a8c:	ed0d                	bnez	a0,80002ac6 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a8e:	85ce                	mv	a1,s3
    80002a90:	8526                	mv	a0,s1
    80002a92:	c9eff0ef          	jal	ra,80001f30 <sleep>
  while(ticks - ticks0 < n){
    80002a96:	409c                	lw	a5,0(s1)
    80002a98:	412787bb          	subw	a5,a5,s2
    80002a9c:	fcc42703          	lw	a4,-52(s0)
    80002aa0:	fee7e2e3          	bltu	a5,a4,80002a84 <sys_pause+0x4a>
  }
  release(&tickslock);
    80002aa4:	00013517          	auipc	a0,0x13
    80002aa8:	21c50513          	addi	a0,a0,540 # 80015cc0 <tickslock>
    80002aac:	958fe0ef          	jal	ra,80000c04 <release>
  return 0;
    80002ab0:	4501                	li	a0,0
}
    80002ab2:	70e2                	ld	ra,56(sp)
    80002ab4:	7442                	ld	s0,48(sp)
    80002ab6:	74a2                	ld	s1,40(sp)
    80002ab8:	7902                	ld	s2,32(sp)
    80002aba:	69e2                	ld	s3,24(sp)
    80002abc:	6121                	addi	sp,sp,64
    80002abe:	8082                	ret
    n = 0;
    80002ac0:	fc042623          	sw	zero,-52(s0)
    80002ac4:	bf59                	j	80002a5a <sys_pause+0x20>
      release(&tickslock);
    80002ac6:	00013517          	auipc	a0,0x13
    80002aca:	1fa50513          	addi	a0,a0,506 # 80015cc0 <tickslock>
    80002ace:	936fe0ef          	jal	ra,80000c04 <release>
      return -1;
    80002ad2:	557d                	li	a0,-1
    80002ad4:	bff9                	j	80002ab2 <sys_pause+0x78>

0000000080002ad6 <sys_kill>:

uint64
sys_kill(void)
{
    80002ad6:	1101                	addi	sp,sp,-32
    80002ad8:	ec06                	sd	ra,24(sp)
    80002ada:	e822                	sd	s0,16(sp)
    80002adc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ade:	fec40593          	addi	a1,s0,-20
    80002ae2:	4501                	li	a0,0
    80002ae4:	d9fff0ef          	jal	ra,80002882 <argint>
  return kkill(pid);
    80002ae8:	fec42503          	lw	a0,-20(s0)
    80002aec:	df2ff0ef          	jal	ra,800020de <kkill>
}
    80002af0:	60e2                	ld	ra,24(sp)
    80002af2:	6442                	ld	s0,16(sp)
    80002af4:	6105                	addi	sp,sp,32
    80002af6:	8082                	ret

0000000080002af8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002af8:	1101                	addi	sp,sp,-32
    80002afa:	ec06                	sd	ra,24(sp)
    80002afc:	e822                	sd	s0,16(sp)
    80002afe:	e426                	sd	s1,8(sp)
    80002b00:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b02:	00013517          	auipc	a0,0x13
    80002b06:	1be50513          	addi	a0,a0,446 # 80015cc0 <tickslock>
    80002b0a:	862fe0ef          	jal	ra,80000b6c <acquire>
  xticks = ticks;
    80002b0e:	00005497          	auipc	s1,0x5
    80002b12:	e624a483          	lw	s1,-414(s1) # 80007970 <ticks>
  release(&tickslock);
    80002b16:	00013517          	auipc	a0,0x13
    80002b1a:	1aa50513          	addi	a0,a0,426 # 80015cc0 <tickslock>
    80002b1e:	8e6fe0ef          	jal	ra,80000c04 <release>
  return xticks;
}
    80002b22:	02049513          	slli	a0,s1,0x20
    80002b26:	9101                	srli	a0,a0,0x20
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret

0000000080002b32 <sys_getprocinfo>:

// Get process information for MLFQ debugging
uint64
sys_getprocinfo(void)
{
    80002b32:	7139                	addi	sp,sp,-64
    80002b34:	fc06                	sd	ra,56(sp)
    80002b36:	f822                	sd	s0,48(sp)
    80002b38:	f426                	sd	s1,40(sp)
    80002b3a:	0080                	addi	s0,sp,64
  uint64 addr;
  struct proc *p = myproc();
    80002b3c:	cddfe0ef          	jal	ra,80001818 <myproc>
    80002b40:	84aa                	mv	s1,a0
  
  argaddr(0, &addr);
    80002b42:	fd840593          	addi	a1,s0,-40
    80002b46:	4501                	li	a0,0
    80002b48:	d57ff0ef          	jal	ra,8000289e <argaddr>
    int state;
    int priority;
    int time_slices;
  } info;
  
  info.pid = p->pid;
    80002b4c:	589c                	lw	a5,48(s1)
    80002b4e:	fcf42423          	sw	a5,-56(s0)
  info.state = p->state;
    80002b52:	4c9c                	lw	a5,24(s1)
    80002b54:	fcf42623          	sw	a5,-52(s0)
  info.priority = p->priority;
    80002b58:	1684a783          	lw	a5,360(s1)
    80002b5c:	fcf42823          	sw	a5,-48(s0)
  info.time_slices = p->time_slices;
    80002b60:	16c4a783          	lw	a5,364(s1)
    80002b64:	fcf42a23          	sw	a5,-44(s0)
  
  if(copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    80002b68:	46c1                	li	a3,16
    80002b6a:	fc840613          	addi	a2,s0,-56
    80002b6e:	fd843583          	ld	a1,-40(s0)
    80002b72:	68a8                	ld	a0,80(s1)
    80002b74:	9dffe0ef          	jal	ra,80001552 <copyout>
    return -1;
  
  return 0;
}
    80002b78:	957d                	srai	a0,a0,0x3f
    80002b7a:	70e2                	ld	ra,56(sp)
    80002b7c:	7442                	ld	s0,48(sp)
    80002b7e:	74a2                	ld	s1,40(sp)
    80002b80:	6121                	addi	sp,sp,64
    80002b82:	8082                	ret

0000000080002b84 <sys_boostproc>:

uint64
sys_boostproc(void)
{
    80002b84:	1141                	addi	sp,sp,-16
    80002b86:	e406                	sd	ra,8(sp)
    80002b88:	e022                	sd	s0,0(sp)
    80002b8a:	0800                	addi	s0,sp,16
  extern void boost_all_priorities(void);
  
  printf("[SYSCALL] Manual boost requested by PID %d\n", myproc()->pid);
    80002b8c:	c8dfe0ef          	jal	ra,80001818 <myproc>
    80002b90:	590c                	lw	a1,48(a0)
    80002b92:	00005517          	auipc	a0,0x5
    80002b96:	9de50513          	addi	a0,a0,-1570 # 80007570 <syscalls+0xc0>
    80002b9a:	92bfd0ef          	jal	ra,800004c4 <printf>
  boost_all_priorities();
    80002b9e:	8f6ff0ef          	jal	ra,80001c94 <boost_all_priorities>
  
  return 0;
    80002ba2:	4501                	li	a0,0
    80002ba4:	60a2                	ld	ra,8(sp)
    80002ba6:	6402                	ld	s0,0(sp)
    80002ba8:	0141                	addi	sp,sp,16
    80002baa:	8082                	ret

0000000080002bac <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002bac:	7179                	addi	sp,sp,-48
    80002bae:	f406                	sd	ra,40(sp)
    80002bb0:	f022                	sd	s0,32(sp)
    80002bb2:	ec26                	sd	s1,24(sp)
    80002bb4:	e84a                	sd	s2,16(sp)
    80002bb6:	e44e                	sd	s3,8(sp)
    80002bb8:	e052                	sd	s4,0(sp)
    80002bba:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002bbc:	00005597          	auipc	a1,0x5
    80002bc0:	9e458593          	addi	a1,a1,-1564 # 800075a0 <syscalls+0xf0>
    80002bc4:	00013517          	auipc	a0,0x13
    80002bc8:	11450513          	addi	a0,a0,276 # 80015cd8 <bcache>
    80002bcc:	f21fd0ef          	jal	ra,80000aec <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002bd0:	0001b797          	auipc	a5,0x1b
    80002bd4:	10878793          	addi	a5,a5,264 # 8001dcd8 <bcache+0x8000>
    80002bd8:	0001b717          	auipc	a4,0x1b
    80002bdc:	36870713          	addi	a4,a4,872 # 8001df40 <bcache+0x8268>
    80002be0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002be4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002be8:	00013497          	auipc	s1,0x13
    80002bec:	10848493          	addi	s1,s1,264 # 80015cf0 <bcache+0x18>
    b->next = bcache.head.next;
    80002bf0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bf2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bf4:	00005a17          	auipc	s4,0x5
    80002bf8:	9b4a0a13          	addi	s4,s4,-1612 # 800075a8 <syscalls+0xf8>
    b->next = bcache.head.next;
    80002bfc:	2b893783          	ld	a5,696(s2)
    80002c00:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c02:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c06:	85d2                	mv	a1,s4
    80002c08:	01048513          	addi	a0,s1,16
    80002c0c:	2fe010ef          	jal	ra,80003f0a <initsleeplock>
    bcache.head.next->prev = b;
    80002c10:	2b893783          	ld	a5,696(s2)
    80002c14:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c16:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c1a:	45848493          	addi	s1,s1,1112
    80002c1e:	fd349fe3          	bne	s1,s3,80002bfc <binit+0x50>
  }
}
    80002c22:	70a2                	ld	ra,40(sp)
    80002c24:	7402                	ld	s0,32(sp)
    80002c26:	64e2                	ld	s1,24(sp)
    80002c28:	6942                	ld	s2,16(sp)
    80002c2a:	69a2                	ld	s3,8(sp)
    80002c2c:	6a02                	ld	s4,0(sp)
    80002c2e:	6145                	addi	sp,sp,48
    80002c30:	8082                	ret

0000000080002c32 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c32:	7179                	addi	sp,sp,-48
    80002c34:	f406                	sd	ra,40(sp)
    80002c36:	f022                	sd	s0,32(sp)
    80002c38:	ec26                	sd	s1,24(sp)
    80002c3a:	e84a                	sd	s2,16(sp)
    80002c3c:	e44e                	sd	s3,8(sp)
    80002c3e:	1800                	addi	s0,sp,48
    80002c40:	892a                	mv	s2,a0
    80002c42:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c44:	00013517          	auipc	a0,0x13
    80002c48:	09450513          	addi	a0,a0,148 # 80015cd8 <bcache>
    80002c4c:	f21fd0ef          	jal	ra,80000b6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c50:	0001b497          	auipc	s1,0x1b
    80002c54:	3404b483          	ld	s1,832(s1) # 8001df90 <bcache+0x82b8>
    80002c58:	0001b797          	auipc	a5,0x1b
    80002c5c:	2e878793          	addi	a5,a5,744 # 8001df40 <bcache+0x8268>
    80002c60:	02f48b63          	beq	s1,a5,80002c96 <bread+0x64>
    80002c64:	873e                	mv	a4,a5
    80002c66:	a021                	j	80002c6e <bread+0x3c>
    80002c68:	68a4                	ld	s1,80(s1)
    80002c6a:	02e48663          	beq	s1,a4,80002c96 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c6e:	449c                	lw	a5,8(s1)
    80002c70:	ff279ce3          	bne	a5,s2,80002c68 <bread+0x36>
    80002c74:	44dc                	lw	a5,12(s1)
    80002c76:	ff3799e3          	bne	a5,s3,80002c68 <bread+0x36>
      b->refcnt++;
    80002c7a:	40bc                	lw	a5,64(s1)
    80002c7c:	2785                	addiw	a5,a5,1
    80002c7e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c80:	00013517          	auipc	a0,0x13
    80002c84:	05850513          	addi	a0,a0,88 # 80015cd8 <bcache>
    80002c88:	f7dfd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002c8c:	01048513          	addi	a0,s1,16
    80002c90:	2b0010ef          	jal	ra,80003f40 <acquiresleep>
      return b;
    80002c94:	a889                	j	80002ce6 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c96:	0001b497          	auipc	s1,0x1b
    80002c9a:	2f24b483          	ld	s1,754(s1) # 8001df88 <bcache+0x82b0>
    80002c9e:	0001b797          	auipc	a5,0x1b
    80002ca2:	2a278793          	addi	a5,a5,674 # 8001df40 <bcache+0x8268>
    80002ca6:	00f48863          	beq	s1,a5,80002cb6 <bread+0x84>
    80002caa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002cac:	40bc                	lw	a5,64(s1)
    80002cae:	cb91                	beqz	a5,80002cc2 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cb0:	64a4                	ld	s1,72(s1)
    80002cb2:	fee49de3          	bne	s1,a4,80002cac <bread+0x7a>
  panic("bget: no buffers");
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	8fa50513          	addi	a0,a0,-1798 # 800075b0 <syscalls+0x100>
    80002cbe:	acdfd0ef          	jal	ra,8000078a <panic>
      b->dev = dev;
    80002cc2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002cc6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002cca:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002cce:	4785                	li	a5,1
    80002cd0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cd2:	00013517          	auipc	a0,0x13
    80002cd6:	00650513          	addi	a0,a0,6 # 80015cd8 <bcache>
    80002cda:	f2bfd0ef          	jal	ra,80000c04 <release>
      acquiresleep(&b->lock);
    80002cde:	01048513          	addi	a0,s1,16
    80002ce2:	25e010ef          	jal	ra,80003f40 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ce6:	409c                	lw	a5,0(s1)
    80002ce8:	cb89                	beqz	a5,80002cfa <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cea:	8526                	mv	a0,s1
    80002cec:	70a2                	ld	ra,40(sp)
    80002cee:	7402                	ld	s0,32(sp)
    80002cf0:	64e2                	ld	s1,24(sp)
    80002cf2:	6942                	ld	s2,16(sp)
    80002cf4:	69a2                	ld	s3,8(sp)
    80002cf6:	6145                	addi	sp,sp,48
    80002cf8:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cfa:	4581                	li	a1,0
    80002cfc:	8526                	mv	a0,s1
    80002cfe:	1af020ef          	jal	ra,800056ac <virtio_disk_rw>
    b->valid = 1;
    80002d02:	4785                	li	a5,1
    80002d04:	c09c                	sw	a5,0(s1)
  return b;
    80002d06:	b7d5                	j	80002cea <bread+0xb8>

0000000080002d08 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d08:	1101                	addi	sp,sp,-32
    80002d0a:	ec06                	sd	ra,24(sp)
    80002d0c:	e822                	sd	s0,16(sp)
    80002d0e:	e426                	sd	s1,8(sp)
    80002d10:	1000                	addi	s0,sp,32
    80002d12:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d14:	0541                	addi	a0,a0,16
    80002d16:	2a8010ef          	jal	ra,80003fbe <holdingsleep>
    80002d1a:	c911                	beqz	a0,80002d2e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d1c:	4585                	li	a1,1
    80002d1e:	8526                	mv	a0,s1
    80002d20:	18d020ef          	jal	ra,800056ac <virtio_disk_rw>
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6105                	addi	sp,sp,32
    80002d2c:	8082                	ret
    panic("bwrite");
    80002d2e:	00005517          	auipc	a0,0x5
    80002d32:	89a50513          	addi	a0,a0,-1894 # 800075c8 <syscalls+0x118>
    80002d36:	a55fd0ef          	jal	ra,8000078a <panic>

0000000080002d3a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d3a:	1101                	addi	sp,sp,-32
    80002d3c:	ec06                	sd	ra,24(sp)
    80002d3e:	e822                	sd	s0,16(sp)
    80002d40:	e426                	sd	s1,8(sp)
    80002d42:	e04a                	sd	s2,0(sp)
    80002d44:	1000                	addi	s0,sp,32
    80002d46:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d48:	01050913          	addi	s2,a0,16
    80002d4c:	854a                	mv	a0,s2
    80002d4e:	270010ef          	jal	ra,80003fbe <holdingsleep>
    80002d52:	c13d                	beqz	a0,80002db8 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002d54:	854a                	mv	a0,s2
    80002d56:	230010ef          	jal	ra,80003f86 <releasesleep>

  acquire(&bcache.lock);
    80002d5a:	00013517          	auipc	a0,0x13
    80002d5e:	f7e50513          	addi	a0,a0,-130 # 80015cd8 <bcache>
    80002d62:	e0bfd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002d66:	40bc                	lw	a5,64(s1)
    80002d68:	37fd                	addiw	a5,a5,-1
    80002d6a:	0007871b          	sext.w	a4,a5
    80002d6e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d70:	eb05                	bnez	a4,80002da0 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d72:	68bc                	ld	a5,80(s1)
    80002d74:	64b8                	ld	a4,72(s1)
    80002d76:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002d78:	64bc                	ld	a5,72(s1)
    80002d7a:	68b8                	ld	a4,80(s1)
    80002d7c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d7e:	0001b797          	auipc	a5,0x1b
    80002d82:	f5a78793          	addi	a5,a5,-166 # 8001dcd8 <bcache+0x8000>
    80002d86:	2b87b703          	ld	a4,696(a5)
    80002d8a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d8c:	0001b717          	auipc	a4,0x1b
    80002d90:	1b470713          	addi	a4,a4,436 # 8001df40 <bcache+0x8268>
    80002d94:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d96:	2b87b703          	ld	a4,696(a5)
    80002d9a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d9c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002da0:	00013517          	auipc	a0,0x13
    80002da4:	f3850513          	addi	a0,a0,-200 # 80015cd8 <bcache>
    80002da8:	e5dfd0ef          	jal	ra,80000c04 <release>
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	64a2                	ld	s1,8(sp)
    80002db2:	6902                	ld	s2,0(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret
    panic("brelse");
    80002db8:	00005517          	auipc	a0,0x5
    80002dbc:	81850513          	addi	a0,a0,-2024 # 800075d0 <syscalls+0x120>
    80002dc0:	9cbfd0ef          	jal	ra,8000078a <panic>

0000000080002dc4 <bpin>:

void
bpin(struct buf *b) {
    80002dc4:	1101                	addi	sp,sp,-32
    80002dc6:	ec06                	sd	ra,24(sp)
    80002dc8:	e822                	sd	s0,16(sp)
    80002dca:	e426                	sd	s1,8(sp)
    80002dcc:	1000                	addi	s0,sp,32
    80002dce:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dd0:	00013517          	auipc	a0,0x13
    80002dd4:	f0850513          	addi	a0,a0,-248 # 80015cd8 <bcache>
    80002dd8:	d95fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt++;
    80002ddc:	40bc                	lw	a5,64(s1)
    80002dde:	2785                	addiw	a5,a5,1
    80002de0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002de2:	00013517          	auipc	a0,0x13
    80002de6:	ef650513          	addi	a0,a0,-266 # 80015cd8 <bcache>
    80002dea:	e1bfd0ef          	jal	ra,80000c04 <release>
}
    80002dee:	60e2                	ld	ra,24(sp)
    80002df0:	6442                	ld	s0,16(sp)
    80002df2:	64a2                	ld	s1,8(sp)
    80002df4:	6105                	addi	sp,sp,32
    80002df6:	8082                	ret

0000000080002df8 <bunpin>:

void
bunpin(struct buf *b) {
    80002df8:	1101                	addi	sp,sp,-32
    80002dfa:	ec06                	sd	ra,24(sp)
    80002dfc:	e822                	sd	s0,16(sp)
    80002dfe:	e426                	sd	s1,8(sp)
    80002e00:	1000                	addi	s0,sp,32
    80002e02:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e04:	00013517          	auipc	a0,0x13
    80002e08:	ed450513          	addi	a0,a0,-300 # 80015cd8 <bcache>
    80002e0c:	d61fd0ef          	jal	ra,80000b6c <acquire>
  b->refcnt--;
    80002e10:	40bc                	lw	a5,64(s1)
    80002e12:	37fd                	addiw	a5,a5,-1
    80002e14:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e16:	00013517          	auipc	a0,0x13
    80002e1a:	ec250513          	addi	a0,a0,-318 # 80015cd8 <bcache>
    80002e1e:	de7fd0ef          	jal	ra,80000c04 <release>
}
    80002e22:	60e2                	ld	ra,24(sp)
    80002e24:	6442                	ld	s0,16(sp)
    80002e26:	64a2                	ld	s1,8(sp)
    80002e28:	6105                	addi	sp,sp,32
    80002e2a:	8082                	ret

0000000080002e2c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e2c:	1101                	addi	sp,sp,-32
    80002e2e:	ec06                	sd	ra,24(sp)
    80002e30:	e822                	sd	s0,16(sp)
    80002e32:	e426                	sd	s1,8(sp)
    80002e34:	e04a                	sd	s2,0(sp)
    80002e36:	1000                	addi	s0,sp,32
    80002e38:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e3a:	00d5d59b          	srliw	a1,a1,0xd
    80002e3e:	0001b797          	auipc	a5,0x1b
    80002e42:	5767a783          	lw	a5,1398(a5) # 8001e3b4 <sb+0x1c>
    80002e46:	9dbd                	addw	a1,a1,a5
    80002e48:	debff0ef          	jal	ra,80002c32 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e4c:	0074f713          	andi	a4,s1,7
    80002e50:	4785                	li	a5,1
    80002e52:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002e56:	14ce                	slli	s1,s1,0x33
    80002e58:	90d9                	srli	s1,s1,0x36
    80002e5a:	00950733          	add	a4,a0,s1
    80002e5e:	05874703          	lbu	a4,88(a4)
    80002e62:	00e7f6b3          	and	a3,a5,a4
    80002e66:	c29d                	beqz	a3,80002e8c <bfree+0x60>
    80002e68:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e6a:	94aa                	add	s1,s1,a0
    80002e6c:	fff7c793          	not	a5,a5
    80002e70:	8ff9                	and	a5,a5,a4
    80002e72:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002e76:	7d1000ef          	jal	ra,80003e46 <log_write>
  brelse(bp);
    80002e7a:	854a                	mv	a0,s2
    80002e7c:	ebfff0ef          	jal	ra,80002d3a <brelse>
}
    80002e80:	60e2                	ld	ra,24(sp)
    80002e82:	6442                	ld	s0,16(sp)
    80002e84:	64a2                	ld	s1,8(sp)
    80002e86:	6902                	ld	s2,0(sp)
    80002e88:	6105                	addi	sp,sp,32
    80002e8a:	8082                	ret
    panic("freeing free block");
    80002e8c:	00004517          	auipc	a0,0x4
    80002e90:	74c50513          	addi	a0,a0,1868 # 800075d8 <syscalls+0x128>
    80002e94:	8f7fd0ef          	jal	ra,8000078a <panic>

0000000080002e98 <balloc>:
{
    80002e98:	711d                	addi	sp,sp,-96
    80002e9a:	ec86                	sd	ra,88(sp)
    80002e9c:	e8a2                	sd	s0,80(sp)
    80002e9e:	e4a6                	sd	s1,72(sp)
    80002ea0:	e0ca                	sd	s2,64(sp)
    80002ea2:	fc4e                	sd	s3,56(sp)
    80002ea4:	f852                	sd	s4,48(sp)
    80002ea6:	f456                	sd	s5,40(sp)
    80002ea8:	f05a                	sd	s6,32(sp)
    80002eaa:	ec5e                	sd	s7,24(sp)
    80002eac:	e862                	sd	s8,16(sp)
    80002eae:	e466                	sd	s9,8(sp)
    80002eb0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002eb2:	0001b797          	auipc	a5,0x1b
    80002eb6:	4ea7a783          	lw	a5,1258(a5) # 8001e39c <sb+0x4>
    80002eba:	0e078163          	beqz	a5,80002f9c <balloc+0x104>
    80002ebe:	8baa                	mv	s7,a0
    80002ec0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002ec2:	0001bb17          	auipc	s6,0x1b
    80002ec6:	4d6b0b13          	addi	s6,s6,1238 # 8001e398 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002eca:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002ecc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ece:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002ed0:	6c89                	lui	s9,0x2
    80002ed2:	a0b5                	j	80002f3e <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ed4:	974a                	add	a4,a4,s2
    80002ed6:	8fd5                	or	a5,a5,a3
    80002ed8:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002edc:	854a                	mv	a0,s2
    80002ede:	769000ef          	jal	ra,80003e46 <log_write>
        brelse(bp);
    80002ee2:	854a                	mv	a0,s2
    80002ee4:	e57ff0ef          	jal	ra,80002d3a <brelse>
  bp = bread(dev, bno);
    80002ee8:	85a6                	mv	a1,s1
    80002eea:	855e                	mv	a0,s7
    80002eec:	d47ff0ef          	jal	ra,80002c32 <bread>
    80002ef0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ef2:	40000613          	li	a2,1024
    80002ef6:	4581                	li	a1,0
    80002ef8:	05850513          	addi	a0,a0,88
    80002efc:	d45fd0ef          	jal	ra,80000c40 <memset>
  log_write(bp);
    80002f00:	854a                	mv	a0,s2
    80002f02:	745000ef          	jal	ra,80003e46 <log_write>
  brelse(bp);
    80002f06:	854a                	mv	a0,s2
    80002f08:	e33ff0ef          	jal	ra,80002d3a <brelse>
}
    80002f0c:	8526                	mv	a0,s1
    80002f0e:	60e6                	ld	ra,88(sp)
    80002f10:	6446                	ld	s0,80(sp)
    80002f12:	64a6                	ld	s1,72(sp)
    80002f14:	6906                	ld	s2,64(sp)
    80002f16:	79e2                	ld	s3,56(sp)
    80002f18:	7a42                	ld	s4,48(sp)
    80002f1a:	7aa2                	ld	s5,40(sp)
    80002f1c:	7b02                	ld	s6,32(sp)
    80002f1e:	6be2                	ld	s7,24(sp)
    80002f20:	6c42                	ld	s8,16(sp)
    80002f22:	6ca2                	ld	s9,8(sp)
    80002f24:	6125                	addi	sp,sp,96
    80002f26:	8082                	ret
    brelse(bp);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	e11ff0ef          	jal	ra,80002d3a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f2e:	015c87bb          	addw	a5,s9,s5
    80002f32:	00078a9b          	sext.w	s5,a5
    80002f36:	004b2703          	lw	a4,4(s6)
    80002f3a:	06eaf163          	bgeu	s5,a4,80002f9c <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80002f3e:	41fad79b          	sraiw	a5,s5,0x1f
    80002f42:	0137d79b          	srliw	a5,a5,0x13
    80002f46:	015787bb          	addw	a5,a5,s5
    80002f4a:	40d7d79b          	sraiw	a5,a5,0xd
    80002f4e:	01cb2583          	lw	a1,28(s6)
    80002f52:	9dbd                	addw	a1,a1,a5
    80002f54:	855e                	mv	a0,s7
    80002f56:	cddff0ef          	jal	ra,80002c32 <bread>
    80002f5a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f5c:	004b2503          	lw	a0,4(s6)
    80002f60:	000a849b          	sext.w	s1,s5
    80002f64:	8662                	mv	a2,s8
    80002f66:	fca4f1e3          	bgeu	s1,a0,80002f28 <balloc+0x90>
      m = 1 << (bi % 8);
    80002f6a:	41f6579b          	sraiw	a5,a2,0x1f
    80002f6e:	01d7d69b          	srliw	a3,a5,0x1d
    80002f72:	00c6873b          	addw	a4,a3,a2
    80002f76:	00777793          	andi	a5,a4,7
    80002f7a:	9f95                	subw	a5,a5,a3
    80002f7c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f80:	4037571b          	sraiw	a4,a4,0x3
    80002f84:	00e906b3          	add	a3,s2,a4
    80002f88:	0586c683          	lbu	a3,88(a3) # 1058 <_entry-0x7fffefa8>
    80002f8c:	00d7f5b3          	and	a1,a5,a3
    80002f90:	d1b1                	beqz	a1,80002ed4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f92:	2605                	addiw	a2,a2,1
    80002f94:	2485                	addiw	s1,s1,1
    80002f96:	fd4618e3          	bne	a2,s4,80002f66 <balloc+0xce>
    80002f9a:	b779                	j	80002f28 <balloc+0x90>
  printf("balloc: out of blocks\n");
    80002f9c:	00004517          	auipc	a0,0x4
    80002fa0:	65450513          	addi	a0,a0,1620 # 800075f0 <syscalls+0x140>
    80002fa4:	d20fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    80002fa8:	4481                	li	s1,0
    80002faa:	b78d                	j	80002f0c <balloc+0x74>

0000000080002fac <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002fac:	7179                	addi	sp,sp,-48
    80002fae:	f406                	sd	ra,40(sp)
    80002fb0:	f022                	sd	s0,32(sp)
    80002fb2:	ec26                	sd	s1,24(sp)
    80002fb4:	e84a                	sd	s2,16(sp)
    80002fb6:	e44e                	sd	s3,8(sp)
    80002fb8:	e052                	sd	s4,0(sp)
    80002fba:	1800                	addi	s0,sp,48
    80002fbc:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002fbe:	47ad                	li	a5,11
    80002fc0:	02b7e563          	bltu	a5,a1,80002fea <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002fc4:	02059493          	slli	s1,a1,0x20
    80002fc8:	9081                	srli	s1,s1,0x20
    80002fca:	048a                	slli	s1,s1,0x2
    80002fcc:	94aa                	add	s1,s1,a0
    80002fce:	0504a903          	lw	s2,80(s1)
    80002fd2:	06091663          	bnez	s2,8000303e <bmap+0x92>
      addr = balloc(ip->dev);
    80002fd6:	4108                	lw	a0,0(a0)
    80002fd8:	ec1ff0ef          	jal	ra,80002e98 <balloc>
    80002fdc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002fe0:	04090f63          	beqz	s2,8000303e <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80002fe4:	0524a823          	sw	s2,80(s1)
    80002fe8:	a899                	j	8000303e <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fea:	ff45849b          	addiw	s1,a1,-12
    80002fee:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002ff2:	0ff00793          	li	a5,255
    80002ff6:	06e7eb63          	bltu	a5,a4,8000306c <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002ffa:	08052903          	lw	s2,128(a0)
    80002ffe:	00091b63          	bnez	s2,80003014 <bmap+0x68>
      addr = balloc(ip->dev);
    80003002:	4108                	lw	a0,0(a0)
    80003004:	e95ff0ef          	jal	ra,80002e98 <balloc>
    80003008:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000300c:	02090963          	beqz	s2,8000303e <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003010:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003014:	85ca                	mv	a1,s2
    80003016:	0009a503          	lw	a0,0(s3)
    8000301a:	c19ff0ef          	jal	ra,80002c32 <bread>
    8000301e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003020:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003024:	02049593          	slli	a1,s1,0x20
    80003028:	9181                	srli	a1,a1,0x20
    8000302a:	058a                	slli	a1,a1,0x2
    8000302c:	00b784b3          	add	s1,a5,a1
    80003030:	0004a903          	lw	s2,0(s1)
    80003034:	00090e63          	beqz	s2,80003050 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003038:	8552                	mv	a0,s4
    8000303a:	d01ff0ef          	jal	ra,80002d3a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000303e:	854a                	mv	a0,s2
    80003040:	70a2                	ld	ra,40(sp)
    80003042:	7402                	ld	s0,32(sp)
    80003044:	64e2                	ld	s1,24(sp)
    80003046:	6942                	ld	s2,16(sp)
    80003048:	69a2                	ld	s3,8(sp)
    8000304a:	6a02                	ld	s4,0(sp)
    8000304c:	6145                	addi	sp,sp,48
    8000304e:	8082                	ret
      addr = balloc(ip->dev);
    80003050:	0009a503          	lw	a0,0(s3)
    80003054:	e45ff0ef          	jal	ra,80002e98 <balloc>
    80003058:	0005091b          	sext.w	s2,a0
      if(addr){
    8000305c:	fc090ee3          	beqz	s2,80003038 <bmap+0x8c>
        a[bn] = addr;
    80003060:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003064:	8552                	mv	a0,s4
    80003066:	5e1000ef          	jal	ra,80003e46 <log_write>
    8000306a:	b7f9                	j	80003038 <bmap+0x8c>
  panic("bmap: out of range");
    8000306c:	00004517          	auipc	a0,0x4
    80003070:	59c50513          	addi	a0,a0,1436 # 80007608 <syscalls+0x158>
    80003074:	f16fd0ef          	jal	ra,8000078a <panic>

0000000080003078 <iget>:
{
    80003078:	7179                	addi	sp,sp,-48
    8000307a:	f406                	sd	ra,40(sp)
    8000307c:	f022                	sd	s0,32(sp)
    8000307e:	ec26                	sd	s1,24(sp)
    80003080:	e84a                	sd	s2,16(sp)
    80003082:	e44e                	sd	s3,8(sp)
    80003084:	e052                	sd	s4,0(sp)
    80003086:	1800                	addi	s0,sp,48
    80003088:	89aa                	mv	s3,a0
    8000308a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000308c:	0001b517          	auipc	a0,0x1b
    80003090:	32c50513          	addi	a0,a0,812 # 8001e3b8 <itable>
    80003094:	ad9fd0ef          	jal	ra,80000b6c <acquire>
  empty = 0;
    80003098:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000309a:	0001b497          	auipc	s1,0x1b
    8000309e:	33648493          	addi	s1,s1,822 # 8001e3d0 <itable+0x18>
    800030a2:	0001d697          	auipc	a3,0x1d
    800030a6:	dbe68693          	addi	a3,a3,-578 # 8001fe60 <log>
    800030aa:	a039                	j	800030b8 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030ac:	02090963          	beqz	s2,800030de <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800030b0:	08848493          	addi	s1,s1,136
    800030b4:	02d48863          	beq	s1,a3,800030e4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800030b8:	449c                	lw	a5,8(s1)
    800030ba:	fef059e3          	blez	a5,800030ac <iget+0x34>
    800030be:	4098                	lw	a4,0(s1)
    800030c0:	ff3716e3          	bne	a4,s3,800030ac <iget+0x34>
    800030c4:	40d8                	lw	a4,4(s1)
    800030c6:	ff4713e3          	bne	a4,s4,800030ac <iget+0x34>
      ip->ref++;
    800030ca:	2785                	addiw	a5,a5,1
    800030cc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800030ce:	0001b517          	auipc	a0,0x1b
    800030d2:	2ea50513          	addi	a0,a0,746 # 8001e3b8 <itable>
    800030d6:	b2ffd0ef          	jal	ra,80000c04 <release>
      return ip;
    800030da:	8926                	mv	s2,s1
    800030dc:	a02d                	j	80003106 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030de:	fbe9                	bnez	a5,800030b0 <iget+0x38>
    800030e0:	8926                	mv	s2,s1
    800030e2:	b7f9                	j	800030b0 <iget+0x38>
  if(empty == 0)
    800030e4:	02090a63          	beqz	s2,80003118 <iget+0xa0>
  ip->dev = dev;
    800030e8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030ec:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030f0:	4785                	li	a5,1
    800030f2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030f6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800030fa:	0001b517          	auipc	a0,0x1b
    800030fe:	2be50513          	addi	a0,a0,702 # 8001e3b8 <itable>
    80003102:	b03fd0ef          	jal	ra,80000c04 <release>
}
    80003106:	854a                	mv	a0,s2
    80003108:	70a2                	ld	ra,40(sp)
    8000310a:	7402                	ld	s0,32(sp)
    8000310c:	64e2                	ld	s1,24(sp)
    8000310e:	6942                	ld	s2,16(sp)
    80003110:	69a2                	ld	s3,8(sp)
    80003112:	6a02                	ld	s4,0(sp)
    80003114:	6145                	addi	sp,sp,48
    80003116:	8082                	ret
    panic("iget: no inodes");
    80003118:	00004517          	auipc	a0,0x4
    8000311c:	50850513          	addi	a0,a0,1288 # 80007620 <syscalls+0x170>
    80003120:	e6afd0ef          	jal	ra,8000078a <panic>

0000000080003124 <iinit>:
{
    80003124:	7179                	addi	sp,sp,-48
    80003126:	f406                	sd	ra,40(sp)
    80003128:	f022                	sd	s0,32(sp)
    8000312a:	ec26                	sd	s1,24(sp)
    8000312c:	e84a                	sd	s2,16(sp)
    8000312e:	e44e                	sd	s3,8(sp)
    80003130:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003132:	00004597          	auipc	a1,0x4
    80003136:	4fe58593          	addi	a1,a1,1278 # 80007630 <syscalls+0x180>
    8000313a:	0001b517          	auipc	a0,0x1b
    8000313e:	27e50513          	addi	a0,a0,638 # 8001e3b8 <itable>
    80003142:	9abfd0ef          	jal	ra,80000aec <initlock>
  for(i = 0; i < NINODE; i++) {
    80003146:	0001b497          	auipc	s1,0x1b
    8000314a:	29a48493          	addi	s1,s1,666 # 8001e3e0 <itable+0x28>
    8000314e:	0001d997          	auipc	s3,0x1d
    80003152:	d2298993          	addi	s3,s3,-734 # 8001fe70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003156:	00004917          	auipc	s2,0x4
    8000315a:	4e290913          	addi	s2,s2,1250 # 80007638 <syscalls+0x188>
    8000315e:	85ca                	mv	a1,s2
    80003160:	8526                	mv	a0,s1
    80003162:	5a9000ef          	jal	ra,80003f0a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003166:	08848493          	addi	s1,s1,136
    8000316a:	ff349ae3          	bne	s1,s3,8000315e <iinit+0x3a>
}
    8000316e:	70a2                	ld	ra,40(sp)
    80003170:	7402                	ld	s0,32(sp)
    80003172:	64e2                	ld	s1,24(sp)
    80003174:	6942                	ld	s2,16(sp)
    80003176:	69a2                	ld	s3,8(sp)
    80003178:	6145                	addi	sp,sp,48
    8000317a:	8082                	ret

000000008000317c <ialloc>:
{
    8000317c:	715d                	addi	sp,sp,-80
    8000317e:	e486                	sd	ra,72(sp)
    80003180:	e0a2                	sd	s0,64(sp)
    80003182:	fc26                	sd	s1,56(sp)
    80003184:	f84a                	sd	s2,48(sp)
    80003186:	f44e                	sd	s3,40(sp)
    80003188:	f052                	sd	s4,32(sp)
    8000318a:	ec56                	sd	s5,24(sp)
    8000318c:	e85a                	sd	s6,16(sp)
    8000318e:	e45e                	sd	s7,8(sp)
    80003190:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003192:	0001b717          	auipc	a4,0x1b
    80003196:	21272703          	lw	a4,530(a4) # 8001e3a4 <sb+0xc>
    8000319a:	4785                	li	a5,1
    8000319c:	04e7f663          	bgeu	a5,a4,800031e8 <ialloc+0x6c>
    800031a0:	8aaa                	mv	s5,a0
    800031a2:	8bae                	mv	s7,a1
    800031a4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800031a6:	0001ba17          	auipc	s4,0x1b
    800031aa:	1f2a0a13          	addi	s4,s4,498 # 8001e398 <sb>
    800031ae:	00048b1b          	sext.w	s6,s1
    800031b2:	0044d793          	srli	a5,s1,0x4
    800031b6:	018a2583          	lw	a1,24(s4)
    800031ba:	9dbd                	addw	a1,a1,a5
    800031bc:	8556                	mv	a0,s5
    800031be:	a75ff0ef          	jal	ra,80002c32 <bread>
    800031c2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031c4:	05850993          	addi	s3,a0,88
    800031c8:	00f4f793          	andi	a5,s1,15
    800031cc:	079a                	slli	a5,a5,0x6
    800031ce:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031d0:	00099783          	lh	a5,0(s3)
    800031d4:	cf85                	beqz	a5,8000320c <ialloc+0x90>
    brelse(bp);
    800031d6:	b65ff0ef          	jal	ra,80002d3a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031da:	0485                	addi	s1,s1,1
    800031dc:	00ca2703          	lw	a4,12(s4)
    800031e0:	0004879b          	sext.w	a5,s1
    800031e4:	fce7e5e3          	bltu	a5,a4,800031ae <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800031e8:	00004517          	auipc	a0,0x4
    800031ec:	45850513          	addi	a0,a0,1112 # 80007640 <syscalls+0x190>
    800031f0:	ad4fd0ef          	jal	ra,800004c4 <printf>
  return 0;
    800031f4:	4501                	li	a0,0
}
    800031f6:	60a6                	ld	ra,72(sp)
    800031f8:	6406                	ld	s0,64(sp)
    800031fa:	74e2                	ld	s1,56(sp)
    800031fc:	7942                	ld	s2,48(sp)
    800031fe:	79a2                	ld	s3,40(sp)
    80003200:	7a02                	ld	s4,32(sp)
    80003202:	6ae2                	ld	s5,24(sp)
    80003204:	6b42                	ld	s6,16(sp)
    80003206:	6ba2                	ld	s7,8(sp)
    80003208:	6161                	addi	sp,sp,80
    8000320a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000320c:	04000613          	li	a2,64
    80003210:	4581                	li	a1,0
    80003212:	854e                	mv	a0,s3
    80003214:	a2dfd0ef          	jal	ra,80000c40 <memset>
      dip->type = type;
    80003218:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000321c:	854a                	mv	a0,s2
    8000321e:	429000ef          	jal	ra,80003e46 <log_write>
      brelse(bp);
    80003222:	854a                	mv	a0,s2
    80003224:	b17ff0ef          	jal	ra,80002d3a <brelse>
      return iget(dev, inum);
    80003228:	85da                	mv	a1,s6
    8000322a:	8556                	mv	a0,s5
    8000322c:	e4dff0ef          	jal	ra,80003078 <iget>
    80003230:	b7d9                	j	800031f6 <ialloc+0x7a>

0000000080003232 <iupdate>:
{
    80003232:	1101                	addi	sp,sp,-32
    80003234:	ec06                	sd	ra,24(sp)
    80003236:	e822                	sd	s0,16(sp)
    80003238:	e426                	sd	s1,8(sp)
    8000323a:	e04a                	sd	s2,0(sp)
    8000323c:	1000                	addi	s0,sp,32
    8000323e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003240:	415c                	lw	a5,4(a0)
    80003242:	0047d79b          	srliw	a5,a5,0x4
    80003246:	0001b597          	auipc	a1,0x1b
    8000324a:	16a5a583          	lw	a1,362(a1) # 8001e3b0 <sb+0x18>
    8000324e:	9dbd                	addw	a1,a1,a5
    80003250:	4108                	lw	a0,0(a0)
    80003252:	9e1ff0ef          	jal	ra,80002c32 <bread>
    80003256:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003258:	05850793          	addi	a5,a0,88
    8000325c:	40c8                	lw	a0,4(s1)
    8000325e:	893d                	andi	a0,a0,15
    80003260:	051a                	slli	a0,a0,0x6
    80003262:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003264:	04449703          	lh	a4,68(s1)
    80003268:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000326c:	04649703          	lh	a4,70(s1)
    80003270:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003274:	04849703          	lh	a4,72(s1)
    80003278:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000327c:	04a49703          	lh	a4,74(s1)
    80003280:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003284:	44f8                	lw	a4,76(s1)
    80003286:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003288:	03400613          	li	a2,52
    8000328c:	05048593          	addi	a1,s1,80
    80003290:	0531                	addi	a0,a0,12
    80003292:	a0bfd0ef          	jal	ra,80000c9c <memmove>
  log_write(bp);
    80003296:	854a                	mv	a0,s2
    80003298:	3af000ef          	jal	ra,80003e46 <log_write>
  brelse(bp);
    8000329c:	854a                	mv	a0,s2
    8000329e:	a9dff0ef          	jal	ra,80002d3a <brelse>
}
    800032a2:	60e2                	ld	ra,24(sp)
    800032a4:	6442                	ld	s0,16(sp)
    800032a6:	64a2                	ld	s1,8(sp)
    800032a8:	6902                	ld	s2,0(sp)
    800032aa:	6105                	addi	sp,sp,32
    800032ac:	8082                	ret

00000000800032ae <idup>:
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	e426                	sd	s1,8(sp)
    800032b6:	1000                	addi	s0,sp,32
    800032b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032ba:	0001b517          	auipc	a0,0x1b
    800032be:	0fe50513          	addi	a0,a0,254 # 8001e3b8 <itable>
    800032c2:	8abfd0ef          	jal	ra,80000b6c <acquire>
  ip->ref++;
    800032c6:	449c                	lw	a5,8(s1)
    800032c8:	2785                	addiw	a5,a5,1
    800032ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032cc:	0001b517          	auipc	a0,0x1b
    800032d0:	0ec50513          	addi	a0,a0,236 # 8001e3b8 <itable>
    800032d4:	931fd0ef          	jal	ra,80000c04 <release>
}
    800032d8:	8526                	mv	a0,s1
    800032da:	60e2                	ld	ra,24(sp)
    800032dc:	6442                	ld	s0,16(sp)
    800032de:	64a2                	ld	s1,8(sp)
    800032e0:	6105                	addi	sp,sp,32
    800032e2:	8082                	ret

00000000800032e4 <ilock>:
{
    800032e4:	1101                	addi	sp,sp,-32
    800032e6:	ec06                	sd	ra,24(sp)
    800032e8:	e822                	sd	s0,16(sp)
    800032ea:	e426                	sd	s1,8(sp)
    800032ec:	e04a                	sd	s2,0(sp)
    800032ee:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032f0:	c105                	beqz	a0,80003310 <ilock+0x2c>
    800032f2:	84aa                	mv	s1,a0
    800032f4:	451c                	lw	a5,8(a0)
    800032f6:	00f05d63          	blez	a5,80003310 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800032fa:	0541                	addi	a0,a0,16
    800032fc:	445000ef          	jal	ra,80003f40 <acquiresleep>
  if(ip->valid == 0){
    80003300:	40bc                	lw	a5,64(s1)
    80003302:	cf89                	beqz	a5,8000331c <ilock+0x38>
}
    80003304:	60e2                	ld	ra,24(sp)
    80003306:	6442                	ld	s0,16(sp)
    80003308:	64a2                	ld	s1,8(sp)
    8000330a:	6902                	ld	s2,0(sp)
    8000330c:	6105                	addi	sp,sp,32
    8000330e:	8082                	ret
    panic("ilock");
    80003310:	00004517          	auipc	a0,0x4
    80003314:	34850513          	addi	a0,a0,840 # 80007658 <syscalls+0x1a8>
    80003318:	c72fd0ef          	jal	ra,8000078a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000331c:	40dc                	lw	a5,4(s1)
    8000331e:	0047d79b          	srliw	a5,a5,0x4
    80003322:	0001b597          	auipc	a1,0x1b
    80003326:	08e5a583          	lw	a1,142(a1) # 8001e3b0 <sb+0x18>
    8000332a:	9dbd                	addw	a1,a1,a5
    8000332c:	4088                	lw	a0,0(s1)
    8000332e:	905ff0ef          	jal	ra,80002c32 <bread>
    80003332:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003334:	05850593          	addi	a1,a0,88
    80003338:	40dc                	lw	a5,4(s1)
    8000333a:	8bbd                	andi	a5,a5,15
    8000333c:	079a                	slli	a5,a5,0x6
    8000333e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003340:	00059783          	lh	a5,0(a1)
    80003344:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003348:	00259783          	lh	a5,2(a1)
    8000334c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003350:	00459783          	lh	a5,4(a1)
    80003354:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003358:	00659783          	lh	a5,6(a1)
    8000335c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003360:	459c                	lw	a5,8(a1)
    80003362:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003364:	03400613          	li	a2,52
    80003368:	05b1                	addi	a1,a1,12
    8000336a:	05048513          	addi	a0,s1,80
    8000336e:	92ffd0ef          	jal	ra,80000c9c <memmove>
    brelse(bp);
    80003372:	854a                	mv	a0,s2
    80003374:	9c7ff0ef          	jal	ra,80002d3a <brelse>
    ip->valid = 1;
    80003378:	4785                	li	a5,1
    8000337a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000337c:	04449783          	lh	a5,68(s1)
    80003380:	f3d1                	bnez	a5,80003304 <ilock+0x20>
      panic("ilock: no type");
    80003382:	00004517          	auipc	a0,0x4
    80003386:	2de50513          	addi	a0,a0,734 # 80007660 <syscalls+0x1b0>
    8000338a:	c00fd0ef          	jal	ra,8000078a <panic>

000000008000338e <iunlock>:
{
    8000338e:	1101                	addi	sp,sp,-32
    80003390:	ec06                	sd	ra,24(sp)
    80003392:	e822                	sd	s0,16(sp)
    80003394:	e426                	sd	s1,8(sp)
    80003396:	e04a                	sd	s2,0(sp)
    80003398:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000339a:	c505                	beqz	a0,800033c2 <iunlock+0x34>
    8000339c:	84aa                	mv	s1,a0
    8000339e:	01050913          	addi	s2,a0,16
    800033a2:	854a                	mv	a0,s2
    800033a4:	41b000ef          	jal	ra,80003fbe <holdingsleep>
    800033a8:	cd09                	beqz	a0,800033c2 <iunlock+0x34>
    800033aa:	449c                	lw	a5,8(s1)
    800033ac:	00f05b63          	blez	a5,800033c2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033b0:	854a                	mv	a0,s2
    800033b2:	3d5000ef          	jal	ra,80003f86 <releasesleep>
}
    800033b6:	60e2                	ld	ra,24(sp)
    800033b8:	6442                	ld	s0,16(sp)
    800033ba:	64a2                	ld	s1,8(sp)
    800033bc:	6902                	ld	s2,0(sp)
    800033be:	6105                	addi	sp,sp,32
    800033c0:	8082                	ret
    panic("iunlock");
    800033c2:	00004517          	auipc	a0,0x4
    800033c6:	2ae50513          	addi	a0,a0,686 # 80007670 <syscalls+0x1c0>
    800033ca:	bc0fd0ef          	jal	ra,8000078a <panic>

00000000800033ce <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033ce:	7179                	addi	sp,sp,-48
    800033d0:	f406                	sd	ra,40(sp)
    800033d2:	f022                	sd	s0,32(sp)
    800033d4:	ec26                	sd	s1,24(sp)
    800033d6:	e84a                	sd	s2,16(sp)
    800033d8:	e44e                	sd	s3,8(sp)
    800033da:	e052                	sd	s4,0(sp)
    800033dc:	1800                	addi	s0,sp,48
    800033de:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033e0:	05050493          	addi	s1,a0,80
    800033e4:	08050913          	addi	s2,a0,128
    800033e8:	a021                	j	800033f0 <itrunc+0x22>
    800033ea:	0491                	addi	s1,s1,4
    800033ec:	01248b63          	beq	s1,s2,80003402 <itrunc+0x34>
    if(ip->addrs[i]){
    800033f0:	408c                	lw	a1,0(s1)
    800033f2:	dde5                	beqz	a1,800033ea <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800033f4:	0009a503          	lw	a0,0(s3)
    800033f8:	a35ff0ef          	jal	ra,80002e2c <bfree>
      ip->addrs[i] = 0;
    800033fc:	0004a023          	sw	zero,0(s1)
    80003400:	b7ed                	j	800033ea <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003402:	0809a583          	lw	a1,128(s3)
    80003406:	ed91                	bnez	a1,80003422 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003408:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000340c:	854e                	mv	a0,s3
    8000340e:	e25ff0ef          	jal	ra,80003232 <iupdate>
}
    80003412:	70a2                	ld	ra,40(sp)
    80003414:	7402                	ld	s0,32(sp)
    80003416:	64e2                	ld	s1,24(sp)
    80003418:	6942                	ld	s2,16(sp)
    8000341a:	69a2                	ld	s3,8(sp)
    8000341c:	6a02                	ld	s4,0(sp)
    8000341e:	6145                	addi	sp,sp,48
    80003420:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003422:	0009a503          	lw	a0,0(s3)
    80003426:	80dff0ef          	jal	ra,80002c32 <bread>
    8000342a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000342c:	05850493          	addi	s1,a0,88
    80003430:	45850913          	addi	s2,a0,1112
    80003434:	a021                	j	8000343c <itrunc+0x6e>
    80003436:	0491                	addi	s1,s1,4
    80003438:	01248963          	beq	s1,s2,8000344a <itrunc+0x7c>
      if(a[j])
    8000343c:	408c                	lw	a1,0(s1)
    8000343e:	dde5                	beqz	a1,80003436 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003440:	0009a503          	lw	a0,0(s3)
    80003444:	9e9ff0ef          	jal	ra,80002e2c <bfree>
    80003448:	b7fd                	j	80003436 <itrunc+0x68>
    brelse(bp);
    8000344a:	8552                	mv	a0,s4
    8000344c:	8efff0ef          	jal	ra,80002d3a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003450:	0809a583          	lw	a1,128(s3)
    80003454:	0009a503          	lw	a0,0(s3)
    80003458:	9d5ff0ef          	jal	ra,80002e2c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000345c:	0809a023          	sw	zero,128(s3)
    80003460:	b765                	j	80003408 <itrunc+0x3a>

0000000080003462 <iput>:
{
    80003462:	1101                	addi	sp,sp,-32
    80003464:	ec06                	sd	ra,24(sp)
    80003466:	e822                	sd	s0,16(sp)
    80003468:	e426                	sd	s1,8(sp)
    8000346a:	e04a                	sd	s2,0(sp)
    8000346c:	1000                	addi	s0,sp,32
    8000346e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003470:	0001b517          	auipc	a0,0x1b
    80003474:	f4850513          	addi	a0,a0,-184 # 8001e3b8 <itable>
    80003478:	ef4fd0ef          	jal	ra,80000b6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000347c:	4498                	lw	a4,8(s1)
    8000347e:	4785                	li	a5,1
    80003480:	02f70163          	beq	a4,a5,800034a2 <iput+0x40>
  ip->ref--;
    80003484:	449c                	lw	a5,8(s1)
    80003486:	37fd                	addiw	a5,a5,-1
    80003488:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000348a:	0001b517          	auipc	a0,0x1b
    8000348e:	f2e50513          	addi	a0,a0,-210 # 8001e3b8 <itable>
    80003492:	f72fd0ef          	jal	ra,80000c04 <release>
}
    80003496:	60e2                	ld	ra,24(sp)
    80003498:	6442                	ld	s0,16(sp)
    8000349a:	64a2                	ld	s1,8(sp)
    8000349c:	6902                	ld	s2,0(sp)
    8000349e:	6105                	addi	sp,sp,32
    800034a0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034a2:	40bc                	lw	a5,64(s1)
    800034a4:	d3e5                	beqz	a5,80003484 <iput+0x22>
    800034a6:	04a49783          	lh	a5,74(s1)
    800034aa:	ffe9                	bnez	a5,80003484 <iput+0x22>
    acquiresleep(&ip->lock);
    800034ac:	01048913          	addi	s2,s1,16
    800034b0:	854a                	mv	a0,s2
    800034b2:	28f000ef          	jal	ra,80003f40 <acquiresleep>
    release(&itable.lock);
    800034b6:	0001b517          	auipc	a0,0x1b
    800034ba:	f0250513          	addi	a0,a0,-254 # 8001e3b8 <itable>
    800034be:	f46fd0ef          	jal	ra,80000c04 <release>
    itrunc(ip);
    800034c2:	8526                	mv	a0,s1
    800034c4:	f0bff0ef          	jal	ra,800033ce <itrunc>
    ip->type = 0;
    800034c8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034cc:	8526                	mv	a0,s1
    800034ce:	d65ff0ef          	jal	ra,80003232 <iupdate>
    ip->valid = 0;
    800034d2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034d6:	854a                	mv	a0,s2
    800034d8:	2af000ef          	jal	ra,80003f86 <releasesleep>
    acquire(&itable.lock);
    800034dc:	0001b517          	auipc	a0,0x1b
    800034e0:	edc50513          	addi	a0,a0,-292 # 8001e3b8 <itable>
    800034e4:	e88fd0ef          	jal	ra,80000b6c <acquire>
    800034e8:	bf71                	j	80003484 <iput+0x22>

00000000800034ea <iunlockput>:
{
    800034ea:	1101                	addi	sp,sp,-32
    800034ec:	ec06                	sd	ra,24(sp)
    800034ee:	e822                	sd	s0,16(sp)
    800034f0:	e426                	sd	s1,8(sp)
    800034f2:	1000                	addi	s0,sp,32
    800034f4:	84aa                	mv	s1,a0
  iunlock(ip);
    800034f6:	e99ff0ef          	jal	ra,8000338e <iunlock>
  iput(ip);
    800034fa:	8526                	mv	a0,s1
    800034fc:	f67ff0ef          	jal	ra,80003462 <iput>
}
    80003500:	60e2                	ld	ra,24(sp)
    80003502:	6442                	ld	s0,16(sp)
    80003504:	64a2                	ld	s1,8(sp)
    80003506:	6105                	addi	sp,sp,32
    80003508:	8082                	ret

000000008000350a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000350a:	0001b717          	auipc	a4,0x1b
    8000350e:	e9a72703          	lw	a4,-358(a4) # 8001e3a4 <sb+0xc>
    80003512:	4785                	li	a5,1
    80003514:	0ae7ff63          	bgeu	a5,a4,800035d2 <ireclaim+0xc8>
{
    80003518:	7139                	addi	sp,sp,-64
    8000351a:	fc06                	sd	ra,56(sp)
    8000351c:	f822                	sd	s0,48(sp)
    8000351e:	f426                	sd	s1,40(sp)
    80003520:	f04a                	sd	s2,32(sp)
    80003522:	ec4e                	sd	s3,24(sp)
    80003524:	e852                	sd	s4,16(sp)
    80003526:	e456                	sd	s5,8(sp)
    80003528:	e05a                	sd	s6,0(sp)
    8000352a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000352c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000352e:	00050a1b          	sext.w	s4,a0
    80003532:	0001ba97          	auipc	s5,0x1b
    80003536:	e66a8a93          	addi	s5,s5,-410 # 8001e398 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000353a:	00004b17          	auipc	s6,0x4
    8000353e:	13eb0b13          	addi	s6,s6,318 # 80007678 <syscalls+0x1c8>
    80003542:	a099                	j	80003588 <ireclaim+0x7e>
    80003544:	85ce                	mv	a1,s3
    80003546:	855a                	mv	a0,s6
    80003548:	f7dfc0ef          	jal	ra,800004c4 <printf>
      ip = iget(dev, inum);
    8000354c:	85ce                	mv	a1,s3
    8000354e:	8552                	mv	a0,s4
    80003550:	b29ff0ef          	jal	ra,80003078 <iget>
    80003554:	89aa                	mv	s3,a0
    brelse(bp);
    80003556:	854a                	mv	a0,s2
    80003558:	fe2ff0ef          	jal	ra,80002d3a <brelse>
    if (ip) {
    8000355c:	00098f63          	beqz	s3,8000357a <ireclaim+0x70>
      begin_op();
    80003560:	762000ef          	jal	ra,80003cc2 <begin_op>
      ilock(ip);
    80003564:	854e                	mv	a0,s3
    80003566:	d7fff0ef          	jal	ra,800032e4 <ilock>
      iunlock(ip);
    8000356a:	854e                	mv	a0,s3
    8000356c:	e23ff0ef          	jal	ra,8000338e <iunlock>
      iput(ip);
    80003570:	854e                	mv	a0,s3
    80003572:	ef1ff0ef          	jal	ra,80003462 <iput>
      end_op();
    80003576:	7bc000ef          	jal	ra,80003d32 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000357a:	0485                	addi	s1,s1,1
    8000357c:	00caa703          	lw	a4,12(s5)
    80003580:	0004879b          	sext.w	a5,s1
    80003584:	02e7fd63          	bgeu	a5,a4,800035be <ireclaim+0xb4>
    80003588:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000358c:	0044d793          	srli	a5,s1,0x4
    80003590:	018aa583          	lw	a1,24(s5)
    80003594:	9dbd                	addw	a1,a1,a5
    80003596:	8552                	mv	a0,s4
    80003598:	e9aff0ef          	jal	ra,80002c32 <bread>
    8000359c:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000359e:	05850793          	addi	a5,a0,88
    800035a2:	00f9f713          	andi	a4,s3,15
    800035a6:	071a                	slli	a4,a4,0x6
    800035a8:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800035aa:	00079703          	lh	a4,0(a5)
    800035ae:	c701                	beqz	a4,800035b6 <ireclaim+0xac>
    800035b0:	00679783          	lh	a5,6(a5)
    800035b4:	dbc1                	beqz	a5,80003544 <ireclaim+0x3a>
    brelse(bp);
    800035b6:	854a                	mv	a0,s2
    800035b8:	f82ff0ef          	jal	ra,80002d3a <brelse>
    if (ip) {
    800035bc:	bf7d                	j	8000357a <ireclaim+0x70>
}
    800035be:	70e2                	ld	ra,56(sp)
    800035c0:	7442                	ld	s0,48(sp)
    800035c2:	74a2                	ld	s1,40(sp)
    800035c4:	7902                	ld	s2,32(sp)
    800035c6:	69e2                	ld	s3,24(sp)
    800035c8:	6a42                	ld	s4,16(sp)
    800035ca:	6aa2                	ld	s5,8(sp)
    800035cc:	6b02                	ld	s6,0(sp)
    800035ce:	6121                	addi	sp,sp,64
    800035d0:	8082                	ret
    800035d2:	8082                	ret

00000000800035d4 <fsinit>:
fsinit(int dev) {
    800035d4:	7179                	addi	sp,sp,-48
    800035d6:	f406                	sd	ra,40(sp)
    800035d8:	f022                	sd	s0,32(sp)
    800035da:	ec26                	sd	s1,24(sp)
    800035dc:	e84a                	sd	s2,16(sp)
    800035de:	e44e                	sd	s3,8(sp)
    800035e0:	1800                	addi	s0,sp,48
    800035e2:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800035e4:	4585                	li	a1,1
    800035e6:	e4cff0ef          	jal	ra,80002c32 <bread>
    800035ea:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035ec:	0001b997          	auipc	s3,0x1b
    800035f0:	dac98993          	addi	s3,s3,-596 # 8001e398 <sb>
    800035f4:	02000613          	li	a2,32
    800035f8:	05850593          	addi	a1,a0,88
    800035fc:	854e                	mv	a0,s3
    800035fe:	e9efd0ef          	jal	ra,80000c9c <memmove>
  brelse(bp);
    80003602:	854a                	mv	a0,s2
    80003604:	f36ff0ef          	jal	ra,80002d3a <brelse>
  if(sb.magic != FSMAGIC)
    80003608:	0009a703          	lw	a4,0(s3)
    8000360c:	102037b7          	lui	a5,0x10203
    80003610:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003614:	02f71363          	bne	a4,a5,8000363a <fsinit+0x66>
  initlog(dev, &sb);
    80003618:	0001b597          	auipc	a1,0x1b
    8000361c:	d8058593          	addi	a1,a1,-640 # 8001e398 <sb>
    80003620:	8526                	mv	a0,s1
    80003622:	616000ef          	jal	ra,80003c38 <initlog>
  ireclaim(dev);
    80003626:	8526                	mv	a0,s1
    80003628:	ee3ff0ef          	jal	ra,8000350a <ireclaim>
}
    8000362c:	70a2                	ld	ra,40(sp)
    8000362e:	7402                	ld	s0,32(sp)
    80003630:	64e2                	ld	s1,24(sp)
    80003632:	6942                	ld	s2,16(sp)
    80003634:	69a2                	ld	s3,8(sp)
    80003636:	6145                	addi	sp,sp,48
    80003638:	8082                	ret
    panic("invalid file system");
    8000363a:	00004517          	auipc	a0,0x4
    8000363e:	05e50513          	addi	a0,a0,94 # 80007698 <syscalls+0x1e8>
    80003642:	948fd0ef          	jal	ra,8000078a <panic>

0000000080003646 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003646:	1141                	addi	sp,sp,-16
    80003648:	e422                	sd	s0,8(sp)
    8000364a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000364c:	411c                	lw	a5,0(a0)
    8000364e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003650:	415c                	lw	a5,4(a0)
    80003652:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003654:	04451783          	lh	a5,68(a0)
    80003658:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000365c:	04a51783          	lh	a5,74(a0)
    80003660:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003664:	04c56783          	lwu	a5,76(a0)
    80003668:	e99c                	sd	a5,16(a1)
}
    8000366a:	6422                	ld	s0,8(sp)
    8000366c:	0141                	addi	sp,sp,16
    8000366e:	8082                	ret

0000000080003670 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003670:	457c                	lw	a5,76(a0)
    80003672:	0cd7ef63          	bltu	a5,a3,80003750 <readi+0xe0>
{
    80003676:	7159                	addi	sp,sp,-112
    80003678:	f486                	sd	ra,104(sp)
    8000367a:	f0a2                	sd	s0,96(sp)
    8000367c:	eca6                	sd	s1,88(sp)
    8000367e:	e8ca                	sd	s2,80(sp)
    80003680:	e4ce                	sd	s3,72(sp)
    80003682:	e0d2                	sd	s4,64(sp)
    80003684:	fc56                	sd	s5,56(sp)
    80003686:	f85a                	sd	s6,48(sp)
    80003688:	f45e                	sd	s7,40(sp)
    8000368a:	f062                	sd	s8,32(sp)
    8000368c:	ec66                	sd	s9,24(sp)
    8000368e:	e86a                	sd	s10,16(sp)
    80003690:	e46e                	sd	s11,8(sp)
    80003692:	1880                	addi	s0,sp,112
    80003694:	8b2a                	mv	s6,a0
    80003696:	8bae                	mv	s7,a1
    80003698:	8a32                	mv	s4,a2
    8000369a:	84b6                	mv	s1,a3
    8000369c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000369e:	9f35                	addw	a4,a4,a3
    return 0;
    800036a0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800036a2:	08d76663          	bltu	a4,a3,8000372e <readi+0xbe>
  if(off + n > ip->size)
    800036a6:	00e7f463          	bgeu	a5,a4,800036ae <readi+0x3e>
    n = ip->size - off;
    800036aa:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036ae:	080a8f63          	beqz	s5,8000374c <readi+0xdc>
    800036b2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036b4:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036b8:	5c7d                	li	s8,-1
    800036ba:	a80d                	j	800036ec <readi+0x7c>
    800036bc:	020d1d93          	slli	s11,s10,0x20
    800036c0:	020ddd93          	srli	s11,s11,0x20
    800036c4:	05890793          	addi	a5,s2,88
    800036c8:	86ee                	mv	a3,s11
    800036ca:	963e                	add	a2,a2,a5
    800036cc:	85d2                	mv	a1,s4
    800036ce:	855e                	mv	a0,s7
    800036d0:	bbdfe0ef          	jal	ra,8000228c <either_copyout>
    800036d4:	05850763          	beq	a0,s8,80003722 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036d8:	854a                	mv	a0,s2
    800036da:	e60ff0ef          	jal	ra,80002d3a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036de:	013d09bb          	addw	s3,s10,s3
    800036e2:	009d04bb          	addw	s1,s10,s1
    800036e6:	9a6e                	add	s4,s4,s11
    800036e8:	0559f163          	bgeu	s3,s5,8000372a <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800036ec:	00a4d59b          	srliw	a1,s1,0xa
    800036f0:	855a                	mv	a0,s6
    800036f2:	8bbff0ef          	jal	ra,80002fac <bmap>
    800036f6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036fa:	c985                	beqz	a1,8000372a <readi+0xba>
    bp = bread(ip->dev, addr);
    800036fc:	000b2503          	lw	a0,0(s6)
    80003700:	d32ff0ef          	jal	ra,80002c32 <bread>
    80003704:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003706:	3ff4f613          	andi	a2,s1,1023
    8000370a:	40cc87bb          	subw	a5,s9,a2
    8000370e:	413a873b          	subw	a4,s5,s3
    80003712:	8d3e                	mv	s10,a5
    80003714:	2781                	sext.w	a5,a5
    80003716:	0007069b          	sext.w	a3,a4
    8000371a:	faf6f1e3          	bgeu	a3,a5,800036bc <readi+0x4c>
    8000371e:	8d3a                	mv	s10,a4
    80003720:	bf71                	j	800036bc <readi+0x4c>
      brelse(bp);
    80003722:	854a                	mv	a0,s2
    80003724:	e16ff0ef          	jal	ra,80002d3a <brelse>
      tot = -1;
    80003728:	59fd                	li	s3,-1
  }
  return tot;
    8000372a:	0009851b          	sext.w	a0,s3
}
    8000372e:	70a6                	ld	ra,104(sp)
    80003730:	7406                	ld	s0,96(sp)
    80003732:	64e6                	ld	s1,88(sp)
    80003734:	6946                	ld	s2,80(sp)
    80003736:	69a6                	ld	s3,72(sp)
    80003738:	6a06                	ld	s4,64(sp)
    8000373a:	7ae2                	ld	s5,56(sp)
    8000373c:	7b42                	ld	s6,48(sp)
    8000373e:	7ba2                	ld	s7,40(sp)
    80003740:	7c02                	ld	s8,32(sp)
    80003742:	6ce2                	ld	s9,24(sp)
    80003744:	6d42                	ld	s10,16(sp)
    80003746:	6da2                	ld	s11,8(sp)
    80003748:	6165                	addi	sp,sp,112
    8000374a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000374c:	89d6                	mv	s3,s5
    8000374e:	bff1                	j	8000372a <readi+0xba>
    return 0;
    80003750:	4501                	li	a0,0
}
    80003752:	8082                	ret

0000000080003754 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003754:	457c                	lw	a5,76(a0)
    80003756:	0ed7ea63          	bltu	a5,a3,8000384a <writei+0xf6>
{
    8000375a:	7159                	addi	sp,sp,-112
    8000375c:	f486                	sd	ra,104(sp)
    8000375e:	f0a2                	sd	s0,96(sp)
    80003760:	eca6                	sd	s1,88(sp)
    80003762:	e8ca                	sd	s2,80(sp)
    80003764:	e4ce                	sd	s3,72(sp)
    80003766:	e0d2                	sd	s4,64(sp)
    80003768:	fc56                	sd	s5,56(sp)
    8000376a:	f85a                	sd	s6,48(sp)
    8000376c:	f45e                	sd	s7,40(sp)
    8000376e:	f062                	sd	s8,32(sp)
    80003770:	ec66                	sd	s9,24(sp)
    80003772:	e86a                	sd	s10,16(sp)
    80003774:	e46e                	sd	s11,8(sp)
    80003776:	1880                	addi	s0,sp,112
    80003778:	8aaa                	mv	s5,a0
    8000377a:	8bae                	mv	s7,a1
    8000377c:	8a32                	mv	s4,a2
    8000377e:	8936                	mv	s2,a3
    80003780:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003782:	00e687bb          	addw	a5,a3,a4
    80003786:	0cd7e463          	bltu	a5,a3,8000384e <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000378a:	00043737          	lui	a4,0x43
    8000378e:	0cf76263          	bltu	a4,a5,80003852 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003792:	0a0b0a63          	beqz	s6,80003846 <writei+0xf2>
    80003796:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003798:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000379c:	5c7d                	li	s8,-1
    8000379e:	a825                	j	800037d6 <writei+0x82>
    800037a0:	020d1d93          	slli	s11,s10,0x20
    800037a4:	020ddd93          	srli	s11,s11,0x20
    800037a8:	05848793          	addi	a5,s1,88
    800037ac:	86ee                	mv	a3,s11
    800037ae:	8652                	mv	a2,s4
    800037b0:	85de                	mv	a1,s7
    800037b2:	953e                	add	a0,a0,a5
    800037b4:	b23fe0ef          	jal	ra,800022d6 <either_copyin>
    800037b8:	05850a63          	beq	a0,s8,8000380c <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800037bc:	8526                	mv	a0,s1
    800037be:	688000ef          	jal	ra,80003e46 <log_write>
    brelse(bp);
    800037c2:	8526                	mv	a0,s1
    800037c4:	d76ff0ef          	jal	ra,80002d3a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037c8:	013d09bb          	addw	s3,s10,s3
    800037cc:	012d093b          	addw	s2,s10,s2
    800037d0:	9a6e                	add	s4,s4,s11
    800037d2:	0569f063          	bgeu	s3,s6,80003812 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800037d6:	00a9559b          	srliw	a1,s2,0xa
    800037da:	8556                	mv	a0,s5
    800037dc:	fd0ff0ef          	jal	ra,80002fac <bmap>
    800037e0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800037e4:	c59d                	beqz	a1,80003812 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800037e6:	000aa503          	lw	a0,0(s5)
    800037ea:	c48ff0ef          	jal	ra,80002c32 <bread>
    800037ee:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037f0:	3ff97513          	andi	a0,s2,1023
    800037f4:	40ac87bb          	subw	a5,s9,a0
    800037f8:	413b073b          	subw	a4,s6,s3
    800037fc:	8d3e                	mv	s10,a5
    800037fe:	2781                	sext.w	a5,a5
    80003800:	0007069b          	sext.w	a3,a4
    80003804:	f8f6fee3          	bgeu	a3,a5,800037a0 <writei+0x4c>
    80003808:	8d3a                	mv	s10,a4
    8000380a:	bf59                	j	800037a0 <writei+0x4c>
      brelse(bp);
    8000380c:	8526                	mv	a0,s1
    8000380e:	d2cff0ef          	jal	ra,80002d3a <brelse>
  }

  if(off > ip->size)
    80003812:	04caa783          	lw	a5,76(s5)
    80003816:	0127f463          	bgeu	a5,s2,8000381e <writei+0xca>
    ip->size = off;
    8000381a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000381e:	8556                	mv	a0,s5
    80003820:	a13ff0ef          	jal	ra,80003232 <iupdate>

  return tot;
    80003824:	0009851b          	sext.w	a0,s3
}
    80003828:	70a6                	ld	ra,104(sp)
    8000382a:	7406                	ld	s0,96(sp)
    8000382c:	64e6                	ld	s1,88(sp)
    8000382e:	6946                	ld	s2,80(sp)
    80003830:	69a6                	ld	s3,72(sp)
    80003832:	6a06                	ld	s4,64(sp)
    80003834:	7ae2                	ld	s5,56(sp)
    80003836:	7b42                	ld	s6,48(sp)
    80003838:	7ba2                	ld	s7,40(sp)
    8000383a:	7c02                	ld	s8,32(sp)
    8000383c:	6ce2                	ld	s9,24(sp)
    8000383e:	6d42                	ld	s10,16(sp)
    80003840:	6da2                	ld	s11,8(sp)
    80003842:	6165                	addi	sp,sp,112
    80003844:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003846:	89da                	mv	s3,s6
    80003848:	bfd9                	j	8000381e <writei+0xca>
    return -1;
    8000384a:	557d                	li	a0,-1
}
    8000384c:	8082                	ret
    return -1;
    8000384e:	557d                	li	a0,-1
    80003850:	bfe1                	j	80003828 <writei+0xd4>
    return -1;
    80003852:	557d                	li	a0,-1
    80003854:	bfd1                	j	80003828 <writei+0xd4>

0000000080003856 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003856:	1141                	addi	sp,sp,-16
    80003858:	e406                	sd	ra,8(sp)
    8000385a:	e022                	sd	s0,0(sp)
    8000385c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000385e:	4639                	li	a2,14
    80003860:	cacfd0ef          	jal	ra,80000d0c <strncmp>
}
    80003864:	60a2                	ld	ra,8(sp)
    80003866:	6402                	ld	s0,0(sp)
    80003868:	0141                	addi	sp,sp,16
    8000386a:	8082                	ret

000000008000386c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000386c:	7139                	addi	sp,sp,-64
    8000386e:	fc06                	sd	ra,56(sp)
    80003870:	f822                	sd	s0,48(sp)
    80003872:	f426                	sd	s1,40(sp)
    80003874:	f04a                	sd	s2,32(sp)
    80003876:	ec4e                	sd	s3,24(sp)
    80003878:	e852                	sd	s4,16(sp)
    8000387a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000387c:	04451703          	lh	a4,68(a0)
    80003880:	4785                	li	a5,1
    80003882:	00f71a63          	bne	a4,a5,80003896 <dirlookup+0x2a>
    80003886:	892a                	mv	s2,a0
    80003888:	89ae                	mv	s3,a1
    8000388a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000388c:	457c                	lw	a5,76(a0)
    8000388e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003890:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003892:	e39d                	bnez	a5,800038b8 <dirlookup+0x4c>
    80003894:	a095                	j	800038f8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003896:	00004517          	auipc	a0,0x4
    8000389a:	e1a50513          	addi	a0,a0,-486 # 800076b0 <syscalls+0x200>
    8000389e:	eedfc0ef          	jal	ra,8000078a <panic>
      panic("dirlookup read");
    800038a2:	00004517          	auipc	a0,0x4
    800038a6:	e2650513          	addi	a0,a0,-474 # 800076c8 <syscalls+0x218>
    800038aa:	ee1fc0ef          	jal	ra,8000078a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038ae:	24c1                	addiw	s1,s1,16
    800038b0:	04c92783          	lw	a5,76(s2)
    800038b4:	04f4f163          	bgeu	s1,a5,800038f6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038b8:	4741                	li	a4,16
    800038ba:	86a6                	mv	a3,s1
    800038bc:	fc040613          	addi	a2,s0,-64
    800038c0:	4581                	li	a1,0
    800038c2:	854a                	mv	a0,s2
    800038c4:	dadff0ef          	jal	ra,80003670 <readi>
    800038c8:	47c1                	li	a5,16
    800038ca:	fcf51ce3          	bne	a0,a5,800038a2 <dirlookup+0x36>
    if(de.inum == 0)
    800038ce:	fc045783          	lhu	a5,-64(s0)
    800038d2:	dff1                	beqz	a5,800038ae <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800038d4:	fc240593          	addi	a1,s0,-62
    800038d8:	854e                	mv	a0,s3
    800038da:	f7dff0ef          	jal	ra,80003856 <namecmp>
    800038de:	f961                	bnez	a0,800038ae <dirlookup+0x42>
      if(poff)
    800038e0:	000a0463          	beqz	s4,800038e8 <dirlookup+0x7c>
        *poff = off;
    800038e4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800038e8:	fc045583          	lhu	a1,-64(s0)
    800038ec:	00092503          	lw	a0,0(s2)
    800038f0:	f88ff0ef          	jal	ra,80003078 <iget>
    800038f4:	a011                	j	800038f8 <dirlookup+0x8c>
  return 0;
    800038f6:	4501                	li	a0,0
}
    800038f8:	70e2                	ld	ra,56(sp)
    800038fa:	7442                	ld	s0,48(sp)
    800038fc:	74a2                	ld	s1,40(sp)
    800038fe:	7902                	ld	s2,32(sp)
    80003900:	69e2                	ld	s3,24(sp)
    80003902:	6a42                	ld	s4,16(sp)
    80003904:	6121                	addi	sp,sp,64
    80003906:	8082                	ret

0000000080003908 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003908:	711d                	addi	sp,sp,-96
    8000390a:	ec86                	sd	ra,88(sp)
    8000390c:	e8a2                	sd	s0,80(sp)
    8000390e:	e4a6                	sd	s1,72(sp)
    80003910:	e0ca                	sd	s2,64(sp)
    80003912:	fc4e                	sd	s3,56(sp)
    80003914:	f852                	sd	s4,48(sp)
    80003916:	f456                	sd	s5,40(sp)
    80003918:	f05a                	sd	s6,32(sp)
    8000391a:	ec5e                	sd	s7,24(sp)
    8000391c:	e862                	sd	s8,16(sp)
    8000391e:	e466                	sd	s9,8(sp)
    80003920:	1080                	addi	s0,sp,96
    80003922:	84aa                	mv	s1,a0
    80003924:	8aae                	mv	s5,a1
    80003926:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003928:	00054703          	lbu	a4,0(a0)
    8000392c:	02f00793          	li	a5,47
    80003930:	00f70f63          	beq	a4,a5,8000394e <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003934:	ee5fd0ef          	jal	ra,80001818 <myproc>
    80003938:	15053503          	ld	a0,336(a0)
    8000393c:	973ff0ef          	jal	ra,800032ae <idup>
    80003940:	89aa                	mv	s3,a0
  while(*path == '/')
    80003942:	02f00913          	li	s2,47
  len = path - s;
    80003946:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003948:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000394a:	4b85                	li	s7,1
    8000394c:	a861                	j	800039e4 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    8000394e:	4585                	li	a1,1
    80003950:	4505                	li	a0,1
    80003952:	f26ff0ef          	jal	ra,80003078 <iget>
    80003956:	89aa                	mv	s3,a0
    80003958:	b7ed                	j	80003942 <namex+0x3a>
      iunlockput(ip);
    8000395a:	854e                	mv	a0,s3
    8000395c:	b8fff0ef          	jal	ra,800034ea <iunlockput>
      return 0;
    80003960:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003962:	854e                	mv	a0,s3
    80003964:	60e6                	ld	ra,88(sp)
    80003966:	6446                	ld	s0,80(sp)
    80003968:	64a6                	ld	s1,72(sp)
    8000396a:	6906                	ld	s2,64(sp)
    8000396c:	79e2                	ld	s3,56(sp)
    8000396e:	7a42                	ld	s4,48(sp)
    80003970:	7aa2                	ld	s5,40(sp)
    80003972:	7b02                	ld	s6,32(sp)
    80003974:	6be2                	ld	s7,24(sp)
    80003976:	6c42                	ld	s8,16(sp)
    80003978:	6ca2                	ld	s9,8(sp)
    8000397a:	6125                	addi	sp,sp,96
    8000397c:	8082                	ret
      iunlock(ip);
    8000397e:	854e                	mv	a0,s3
    80003980:	a0fff0ef          	jal	ra,8000338e <iunlock>
      return ip;
    80003984:	bff9                	j	80003962 <namex+0x5a>
      iunlockput(ip);
    80003986:	854e                	mv	a0,s3
    80003988:	b63ff0ef          	jal	ra,800034ea <iunlockput>
      return 0;
    8000398c:	89e6                	mv	s3,s9
    8000398e:	bfd1                	j	80003962 <namex+0x5a>
  len = path - s;
    80003990:	40b48633          	sub	a2,s1,a1
    80003994:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003998:	079c5c63          	bge	s8,s9,80003a10 <namex+0x108>
    memmove(name, s, DIRSIZ);
    8000399c:	4639                	li	a2,14
    8000399e:	8552                	mv	a0,s4
    800039a0:	afcfd0ef          	jal	ra,80000c9c <memmove>
  while(*path == '/')
    800039a4:	0004c783          	lbu	a5,0(s1)
    800039a8:	01279763          	bne	a5,s2,800039b6 <namex+0xae>
    path++;
    800039ac:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039ae:	0004c783          	lbu	a5,0(s1)
    800039b2:	ff278de3          	beq	a5,s2,800039ac <namex+0xa4>
    ilock(ip);
    800039b6:	854e                	mv	a0,s3
    800039b8:	92dff0ef          	jal	ra,800032e4 <ilock>
    if(ip->type != T_DIR){
    800039bc:	04499783          	lh	a5,68(s3)
    800039c0:	f9779de3          	bne	a5,s7,8000395a <namex+0x52>
    if(nameiparent && *path == '\0'){
    800039c4:	000a8563          	beqz	s5,800039ce <namex+0xc6>
    800039c8:	0004c783          	lbu	a5,0(s1)
    800039cc:	dbcd                	beqz	a5,8000397e <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039ce:	865a                	mv	a2,s6
    800039d0:	85d2                	mv	a1,s4
    800039d2:	854e                	mv	a0,s3
    800039d4:	e99ff0ef          	jal	ra,8000386c <dirlookup>
    800039d8:	8caa                	mv	s9,a0
    800039da:	d555                	beqz	a0,80003986 <namex+0x7e>
    iunlockput(ip);
    800039dc:	854e                	mv	a0,s3
    800039de:	b0dff0ef          	jal	ra,800034ea <iunlockput>
    ip = next;
    800039e2:	89e6                	mv	s3,s9
  while(*path == '/')
    800039e4:	0004c783          	lbu	a5,0(s1)
    800039e8:	05279363          	bne	a5,s2,80003a2e <namex+0x126>
    path++;
    800039ec:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039ee:	0004c783          	lbu	a5,0(s1)
    800039f2:	ff278de3          	beq	a5,s2,800039ec <namex+0xe4>
  if(*path == 0)
    800039f6:	c78d                	beqz	a5,80003a20 <namex+0x118>
    path++;
    800039f8:	85a6                	mv	a1,s1
  len = path - s;
    800039fa:	8cda                	mv	s9,s6
    800039fc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800039fe:	01278963          	beq	a5,s2,80003a10 <namex+0x108>
    80003a02:	d7d9                	beqz	a5,80003990 <namex+0x88>
    path++;
    80003a04:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003a06:	0004c783          	lbu	a5,0(s1)
    80003a0a:	ff279ce3          	bne	a5,s2,80003a02 <namex+0xfa>
    80003a0e:	b749                	j	80003990 <namex+0x88>
    memmove(name, s, len);
    80003a10:	2601                	sext.w	a2,a2
    80003a12:	8552                	mv	a0,s4
    80003a14:	a88fd0ef          	jal	ra,80000c9c <memmove>
    name[len] = 0;
    80003a18:	9cd2                	add	s9,s9,s4
    80003a1a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a1e:	b759                	j	800039a4 <namex+0x9c>
  if(nameiparent){
    80003a20:	f40a81e3          	beqz	s5,80003962 <namex+0x5a>
    iput(ip);
    80003a24:	854e                	mv	a0,s3
    80003a26:	a3dff0ef          	jal	ra,80003462 <iput>
    return 0;
    80003a2a:	4981                	li	s3,0
    80003a2c:	bf1d                	j	80003962 <namex+0x5a>
  if(*path == 0)
    80003a2e:	dbed                	beqz	a5,80003a20 <namex+0x118>
  while(*path != '/' && *path != 0)
    80003a30:	0004c783          	lbu	a5,0(s1)
    80003a34:	85a6                	mv	a1,s1
    80003a36:	b7f1                	j	80003a02 <namex+0xfa>

0000000080003a38 <dirlink>:
{
    80003a38:	7139                	addi	sp,sp,-64
    80003a3a:	fc06                	sd	ra,56(sp)
    80003a3c:	f822                	sd	s0,48(sp)
    80003a3e:	f426                	sd	s1,40(sp)
    80003a40:	f04a                	sd	s2,32(sp)
    80003a42:	ec4e                	sd	s3,24(sp)
    80003a44:	e852                	sd	s4,16(sp)
    80003a46:	0080                	addi	s0,sp,64
    80003a48:	892a                	mv	s2,a0
    80003a4a:	8a2e                	mv	s4,a1
    80003a4c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a4e:	4601                	li	a2,0
    80003a50:	e1dff0ef          	jal	ra,8000386c <dirlookup>
    80003a54:	e52d                	bnez	a0,80003abe <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a56:	04c92483          	lw	s1,76(s2)
    80003a5a:	c48d                	beqz	s1,80003a84 <dirlink+0x4c>
    80003a5c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a5e:	4741                	li	a4,16
    80003a60:	86a6                	mv	a3,s1
    80003a62:	fc040613          	addi	a2,s0,-64
    80003a66:	4581                	li	a1,0
    80003a68:	854a                	mv	a0,s2
    80003a6a:	c07ff0ef          	jal	ra,80003670 <readi>
    80003a6e:	47c1                	li	a5,16
    80003a70:	04f51b63          	bne	a0,a5,80003ac6 <dirlink+0x8e>
    if(de.inum == 0)
    80003a74:	fc045783          	lhu	a5,-64(s0)
    80003a78:	c791                	beqz	a5,80003a84 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a7a:	24c1                	addiw	s1,s1,16
    80003a7c:	04c92783          	lw	a5,76(s2)
    80003a80:	fcf4efe3          	bltu	s1,a5,80003a5e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003a84:	4639                	li	a2,14
    80003a86:	85d2                	mv	a1,s4
    80003a88:	fc240513          	addi	a0,s0,-62
    80003a8c:	abcfd0ef          	jal	ra,80000d48 <strncpy>
  de.inum = inum;
    80003a90:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a94:	4741                	li	a4,16
    80003a96:	86a6                	mv	a3,s1
    80003a98:	fc040613          	addi	a2,s0,-64
    80003a9c:	4581                	li	a1,0
    80003a9e:	854a                	mv	a0,s2
    80003aa0:	cb5ff0ef          	jal	ra,80003754 <writei>
    80003aa4:	1541                	addi	a0,a0,-16
    80003aa6:	00a03533          	snez	a0,a0
    80003aaa:	40a00533          	neg	a0,a0
}
    80003aae:	70e2                	ld	ra,56(sp)
    80003ab0:	7442                	ld	s0,48(sp)
    80003ab2:	74a2                	ld	s1,40(sp)
    80003ab4:	7902                	ld	s2,32(sp)
    80003ab6:	69e2                	ld	s3,24(sp)
    80003ab8:	6a42                	ld	s4,16(sp)
    80003aba:	6121                	addi	sp,sp,64
    80003abc:	8082                	ret
    iput(ip);
    80003abe:	9a5ff0ef          	jal	ra,80003462 <iput>
    return -1;
    80003ac2:	557d                	li	a0,-1
    80003ac4:	b7ed                	j	80003aae <dirlink+0x76>
      panic("dirlink read");
    80003ac6:	00004517          	auipc	a0,0x4
    80003aca:	c1250513          	addi	a0,a0,-1006 # 800076d8 <syscalls+0x228>
    80003ace:	cbdfc0ef          	jal	ra,8000078a <panic>

0000000080003ad2 <namei>:

struct inode*
namei(char *path)
{
    80003ad2:	1101                	addi	sp,sp,-32
    80003ad4:	ec06                	sd	ra,24(sp)
    80003ad6:	e822                	sd	s0,16(sp)
    80003ad8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ada:	fe040613          	addi	a2,s0,-32
    80003ade:	4581                	li	a1,0
    80003ae0:	e29ff0ef          	jal	ra,80003908 <namex>
}
    80003ae4:	60e2                	ld	ra,24(sp)
    80003ae6:	6442                	ld	s0,16(sp)
    80003ae8:	6105                	addi	sp,sp,32
    80003aea:	8082                	ret

0000000080003aec <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003aec:	1141                	addi	sp,sp,-16
    80003aee:	e406                	sd	ra,8(sp)
    80003af0:	e022                	sd	s0,0(sp)
    80003af2:	0800                	addi	s0,sp,16
    80003af4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003af6:	4585                	li	a1,1
    80003af8:	e11ff0ef          	jal	ra,80003908 <namex>
}
    80003afc:	60a2                	ld	ra,8(sp)
    80003afe:	6402                	ld	s0,0(sp)
    80003b00:	0141                	addi	sp,sp,16
    80003b02:	8082                	ret

0000000080003b04 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b04:	1101                	addi	sp,sp,-32
    80003b06:	ec06                	sd	ra,24(sp)
    80003b08:	e822                	sd	s0,16(sp)
    80003b0a:	e426                	sd	s1,8(sp)
    80003b0c:	e04a                	sd	s2,0(sp)
    80003b0e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b10:	0001c917          	auipc	s2,0x1c
    80003b14:	35090913          	addi	s2,s2,848 # 8001fe60 <log>
    80003b18:	01892583          	lw	a1,24(s2)
    80003b1c:	02492503          	lw	a0,36(s2)
    80003b20:	912ff0ef          	jal	ra,80002c32 <bread>
    80003b24:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b26:	02892683          	lw	a3,40(s2)
    80003b2a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b2c:	02d05763          	blez	a3,80003b5a <write_head+0x56>
    80003b30:	0001c797          	auipc	a5,0x1c
    80003b34:	35c78793          	addi	a5,a5,860 # 8001fe8c <log+0x2c>
    80003b38:	05c50713          	addi	a4,a0,92
    80003b3c:	36fd                	addiw	a3,a3,-1
    80003b3e:	1682                	slli	a3,a3,0x20
    80003b40:	9281                	srli	a3,a3,0x20
    80003b42:	068a                	slli	a3,a3,0x2
    80003b44:	0001c617          	auipc	a2,0x1c
    80003b48:	34c60613          	addi	a2,a2,844 # 8001fe90 <log+0x30>
    80003b4c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003b4e:	4390                	lw	a2,0(a5)
    80003b50:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b52:	0791                	addi	a5,a5,4
    80003b54:	0711                	addi	a4,a4,4
    80003b56:	fed79ce3          	bne	a5,a3,80003b4e <write_head+0x4a>
  }
  bwrite(buf);
    80003b5a:	8526                	mv	a0,s1
    80003b5c:	9acff0ef          	jal	ra,80002d08 <bwrite>
  brelse(buf);
    80003b60:	8526                	mv	a0,s1
    80003b62:	9d8ff0ef          	jal	ra,80002d3a <brelse>
}
    80003b66:	60e2                	ld	ra,24(sp)
    80003b68:	6442                	ld	s0,16(sp)
    80003b6a:	64a2                	ld	s1,8(sp)
    80003b6c:	6902                	ld	s2,0(sp)
    80003b6e:	6105                	addi	sp,sp,32
    80003b70:	8082                	ret

0000000080003b72 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b72:	0001c797          	auipc	a5,0x1c
    80003b76:	3167a783          	lw	a5,790(a5) # 8001fe88 <log+0x28>
    80003b7a:	0af05e63          	blez	a5,80003c36 <install_trans+0xc4>
{
    80003b7e:	715d                	addi	sp,sp,-80
    80003b80:	e486                	sd	ra,72(sp)
    80003b82:	e0a2                	sd	s0,64(sp)
    80003b84:	fc26                	sd	s1,56(sp)
    80003b86:	f84a                	sd	s2,48(sp)
    80003b88:	f44e                	sd	s3,40(sp)
    80003b8a:	f052                	sd	s4,32(sp)
    80003b8c:	ec56                	sd	s5,24(sp)
    80003b8e:	e85a                	sd	s6,16(sp)
    80003b90:	e45e                	sd	s7,8(sp)
    80003b92:	0880                	addi	s0,sp,80
    80003b94:	8b2a                	mv	s6,a0
    80003b96:	0001ca97          	auipc	s5,0x1c
    80003b9a:	2f6a8a93          	addi	s5,s5,758 # 8001fe8c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b9e:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ba0:	00004b97          	auipc	s7,0x4
    80003ba4:	b48b8b93          	addi	s7,s7,-1208 # 800076e8 <syscalls+0x238>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ba8:	0001ca17          	auipc	s4,0x1c
    80003bac:	2b8a0a13          	addi	s4,s4,696 # 8001fe60 <log>
    80003bb0:	a025                	j	80003bd8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bb2:	000aa603          	lw	a2,0(s5)
    80003bb6:	85ce                	mv	a1,s3
    80003bb8:	855e                	mv	a0,s7
    80003bba:	90bfc0ef          	jal	ra,800004c4 <printf>
    80003bbe:	a839                	j	80003bdc <install_trans+0x6a>
    brelse(lbuf);
    80003bc0:	854a                	mv	a0,s2
    80003bc2:	978ff0ef          	jal	ra,80002d3a <brelse>
    brelse(dbuf);
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	972ff0ef          	jal	ra,80002d3a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bcc:	2985                	addiw	s3,s3,1
    80003bce:	0a91                	addi	s5,s5,4
    80003bd0:	028a2783          	lw	a5,40(s4)
    80003bd4:	04f9d663          	bge	s3,a5,80003c20 <install_trans+0xae>
    if(recovering) {
    80003bd8:	fc0b1de3          	bnez	s6,80003bb2 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bdc:	018a2583          	lw	a1,24(s4)
    80003be0:	013585bb          	addw	a1,a1,s3
    80003be4:	2585                	addiw	a1,a1,1
    80003be6:	024a2503          	lw	a0,36(s4)
    80003bea:	848ff0ef          	jal	ra,80002c32 <bread>
    80003bee:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003bf0:	000aa583          	lw	a1,0(s5)
    80003bf4:	024a2503          	lw	a0,36(s4)
    80003bf8:	83aff0ef          	jal	ra,80002c32 <bread>
    80003bfc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bfe:	40000613          	li	a2,1024
    80003c02:	05890593          	addi	a1,s2,88
    80003c06:	05850513          	addi	a0,a0,88
    80003c0a:	892fd0ef          	jal	ra,80000c9c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c0e:	8526                	mv	a0,s1
    80003c10:	8f8ff0ef          	jal	ra,80002d08 <bwrite>
    if(recovering == 0)
    80003c14:	fa0b16e3          	bnez	s6,80003bc0 <install_trans+0x4e>
      bunpin(dbuf);
    80003c18:	8526                	mv	a0,s1
    80003c1a:	9deff0ef          	jal	ra,80002df8 <bunpin>
    80003c1e:	b74d                	j	80003bc0 <install_trans+0x4e>
}
    80003c20:	60a6                	ld	ra,72(sp)
    80003c22:	6406                	ld	s0,64(sp)
    80003c24:	74e2                	ld	s1,56(sp)
    80003c26:	7942                	ld	s2,48(sp)
    80003c28:	79a2                	ld	s3,40(sp)
    80003c2a:	7a02                	ld	s4,32(sp)
    80003c2c:	6ae2                	ld	s5,24(sp)
    80003c2e:	6b42                	ld	s6,16(sp)
    80003c30:	6ba2                	ld	s7,8(sp)
    80003c32:	6161                	addi	sp,sp,80
    80003c34:	8082                	ret
    80003c36:	8082                	ret

0000000080003c38 <initlog>:
{
    80003c38:	7179                	addi	sp,sp,-48
    80003c3a:	f406                	sd	ra,40(sp)
    80003c3c:	f022                	sd	s0,32(sp)
    80003c3e:	ec26                	sd	s1,24(sp)
    80003c40:	e84a                	sd	s2,16(sp)
    80003c42:	e44e                	sd	s3,8(sp)
    80003c44:	1800                	addi	s0,sp,48
    80003c46:	892a                	mv	s2,a0
    80003c48:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c4a:	0001c497          	auipc	s1,0x1c
    80003c4e:	21648493          	addi	s1,s1,534 # 8001fe60 <log>
    80003c52:	00004597          	auipc	a1,0x4
    80003c56:	ab658593          	addi	a1,a1,-1354 # 80007708 <syscalls+0x258>
    80003c5a:	8526                	mv	a0,s1
    80003c5c:	e91fc0ef          	jal	ra,80000aec <initlock>
  log.start = sb->logstart;
    80003c60:	0149a583          	lw	a1,20(s3)
    80003c64:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003c66:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003c6a:	854a                	mv	a0,s2
    80003c6c:	fc7fe0ef          	jal	ra,80002c32 <bread>
  log.lh.n = lh->n;
    80003c70:	4d34                	lw	a3,88(a0)
    80003c72:	d494                	sw	a3,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c74:	02d05563          	blez	a3,80003c9e <initlog+0x66>
    80003c78:	05c50793          	addi	a5,a0,92
    80003c7c:	0001c717          	auipc	a4,0x1c
    80003c80:	21070713          	addi	a4,a4,528 # 8001fe8c <log+0x2c>
    80003c84:	36fd                	addiw	a3,a3,-1
    80003c86:	1682                	slli	a3,a3,0x20
    80003c88:	9281                	srli	a3,a3,0x20
    80003c8a:	068a                	slli	a3,a3,0x2
    80003c8c:	06050613          	addi	a2,a0,96
    80003c90:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003c92:	4390                	lw	a2,0(a5)
    80003c94:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c96:	0791                	addi	a5,a5,4
    80003c98:	0711                	addi	a4,a4,4
    80003c9a:	fed79ce3          	bne	a5,a3,80003c92 <initlog+0x5a>
  brelse(buf);
    80003c9e:	89cff0ef          	jal	ra,80002d3a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ca2:	4505                	li	a0,1
    80003ca4:	ecfff0ef          	jal	ra,80003b72 <install_trans>
  log.lh.n = 0;
    80003ca8:	0001c797          	auipc	a5,0x1c
    80003cac:	1e07a023          	sw	zero,480(a5) # 8001fe88 <log+0x28>
  write_head(); // clear the log
    80003cb0:	e55ff0ef          	jal	ra,80003b04 <write_head>
}
    80003cb4:	70a2                	ld	ra,40(sp)
    80003cb6:	7402                	ld	s0,32(sp)
    80003cb8:	64e2                	ld	s1,24(sp)
    80003cba:	6942                	ld	s2,16(sp)
    80003cbc:	69a2                	ld	s3,8(sp)
    80003cbe:	6145                	addi	sp,sp,48
    80003cc0:	8082                	ret

0000000080003cc2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003cc2:	1101                	addi	sp,sp,-32
    80003cc4:	ec06                	sd	ra,24(sp)
    80003cc6:	e822                	sd	s0,16(sp)
    80003cc8:	e426                	sd	s1,8(sp)
    80003cca:	e04a                	sd	s2,0(sp)
    80003ccc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003cce:	0001c517          	auipc	a0,0x1c
    80003cd2:	19250513          	addi	a0,a0,402 # 8001fe60 <log>
    80003cd6:	e97fc0ef          	jal	ra,80000b6c <acquire>
  while(1){
    if(log.committing){
    80003cda:	0001c497          	auipc	s1,0x1c
    80003cde:	18648493          	addi	s1,s1,390 # 8001fe60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ce2:	4979                	li	s2,30
    80003ce4:	a029                	j	80003cee <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ce6:	85a6                	mv	a1,s1
    80003ce8:	8526                	mv	a0,s1
    80003cea:	a46fe0ef          	jal	ra,80001f30 <sleep>
    if(log.committing){
    80003cee:	509c                	lw	a5,32(s1)
    80003cf0:	fbfd                	bnez	a5,80003ce6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cf2:	4cdc                	lw	a5,28(s1)
    80003cf4:	0017871b          	addiw	a4,a5,1
    80003cf8:	0007069b          	sext.w	a3,a4
    80003cfc:	0027179b          	slliw	a5,a4,0x2
    80003d00:	9fb9                	addw	a5,a5,a4
    80003d02:	0017979b          	slliw	a5,a5,0x1
    80003d06:	5498                	lw	a4,40(s1)
    80003d08:	9fb9                	addw	a5,a5,a4
    80003d0a:	00f95763          	bge	s2,a5,80003d18 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d0e:	85a6                	mv	a1,s1
    80003d10:	8526                	mv	a0,s1
    80003d12:	a1efe0ef          	jal	ra,80001f30 <sleep>
    80003d16:	bfe1                	j	80003cee <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d18:	0001c517          	auipc	a0,0x1c
    80003d1c:	14850513          	addi	a0,a0,328 # 8001fe60 <log>
    80003d20:	cd54                	sw	a3,28(a0)
      release(&log.lock);
    80003d22:	ee3fc0ef          	jal	ra,80000c04 <release>
      break;
    }
  }
}
    80003d26:	60e2                	ld	ra,24(sp)
    80003d28:	6442                	ld	s0,16(sp)
    80003d2a:	64a2                	ld	s1,8(sp)
    80003d2c:	6902                	ld	s2,0(sp)
    80003d2e:	6105                	addi	sp,sp,32
    80003d30:	8082                	ret

0000000080003d32 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d32:	7139                	addi	sp,sp,-64
    80003d34:	fc06                	sd	ra,56(sp)
    80003d36:	f822                	sd	s0,48(sp)
    80003d38:	f426                	sd	s1,40(sp)
    80003d3a:	f04a                	sd	s2,32(sp)
    80003d3c:	ec4e                	sd	s3,24(sp)
    80003d3e:	e852                	sd	s4,16(sp)
    80003d40:	e456                	sd	s5,8(sp)
    80003d42:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d44:	0001c497          	auipc	s1,0x1c
    80003d48:	11c48493          	addi	s1,s1,284 # 8001fe60 <log>
    80003d4c:	8526                	mv	a0,s1
    80003d4e:	e1ffc0ef          	jal	ra,80000b6c <acquire>
  log.outstanding -= 1;
    80003d52:	4cdc                	lw	a5,28(s1)
    80003d54:	37fd                	addiw	a5,a5,-1
    80003d56:	0007891b          	sext.w	s2,a5
    80003d5a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d5c:	509c                	lw	a5,32(s1)
    80003d5e:	ef9d                	bnez	a5,80003d9c <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d60:	04091463          	bnez	s2,80003da8 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003d64:	0001c497          	auipc	s1,0x1c
    80003d68:	0fc48493          	addi	s1,s1,252 # 8001fe60 <log>
    80003d6c:	4785                	li	a5,1
    80003d6e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d70:	8526                	mv	a0,s1
    80003d72:	e93fc0ef          	jal	ra,80000c04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d76:	549c                	lw	a5,40(s1)
    80003d78:	04f04b63          	bgtz	a5,80003dce <end_op+0x9c>
    acquire(&log.lock);
    80003d7c:	0001c497          	auipc	s1,0x1c
    80003d80:	0e448493          	addi	s1,s1,228 # 8001fe60 <log>
    80003d84:	8526                	mv	a0,s1
    80003d86:	de7fc0ef          	jal	ra,80000b6c <acquire>
    log.committing = 0;
    80003d8a:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003d8e:	8526                	mv	a0,s1
    80003d90:	9ecfe0ef          	jal	ra,80001f7c <wakeup>
    release(&log.lock);
    80003d94:	8526                	mv	a0,s1
    80003d96:	e6ffc0ef          	jal	ra,80000c04 <release>
}
    80003d9a:	a00d                	j	80003dbc <end_op+0x8a>
    panic("log.committing");
    80003d9c:	00004517          	auipc	a0,0x4
    80003da0:	97450513          	addi	a0,a0,-1676 # 80007710 <syscalls+0x260>
    80003da4:	9e7fc0ef          	jal	ra,8000078a <panic>
    wakeup(&log);
    80003da8:	0001c497          	auipc	s1,0x1c
    80003dac:	0b848493          	addi	s1,s1,184 # 8001fe60 <log>
    80003db0:	8526                	mv	a0,s1
    80003db2:	9cafe0ef          	jal	ra,80001f7c <wakeup>
  release(&log.lock);
    80003db6:	8526                	mv	a0,s1
    80003db8:	e4dfc0ef          	jal	ra,80000c04 <release>
}
    80003dbc:	70e2                	ld	ra,56(sp)
    80003dbe:	7442                	ld	s0,48(sp)
    80003dc0:	74a2                	ld	s1,40(sp)
    80003dc2:	7902                	ld	s2,32(sp)
    80003dc4:	69e2                	ld	s3,24(sp)
    80003dc6:	6a42                	ld	s4,16(sp)
    80003dc8:	6aa2                	ld	s5,8(sp)
    80003dca:	6121                	addi	sp,sp,64
    80003dcc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dce:	0001ca97          	auipc	s5,0x1c
    80003dd2:	0bea8a93          	addi	s5,s5,190 # 8001fe8c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003dd6:	0001ca17          	auipc	s4,0x1c
    80003dda:	08aa0a13          	addi	s4,s4,138 # 8001fe60 <log>
    80003dde:	018a2583          	lw	a1,24(s4)
    80003de2:	012585bb          	addw	a1,a1,s2
    80003de6:	2585                	addiw	a1,a1,1
    80003de8:	024a2503          	lw	a0,36(s4)
    80003dec:	e47fe0ef          	jal	ra,80002c32 <bread>
    80003df0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003df2:	000aa583          	lw	a1,0(s5)
    80003df6:	024a2503          	lw	a0,36(s4)
    80003dfa:	e39fe0ef          	jal	ra,80002c32 <bread>
    80003dfe:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e00:	40000613          	li	a2,1024
    80003e04:	05850593          	addi	a1,a0,88
    80003e08:	05848513          	addi	a0,s1,88
    80003e0c:	e91fc0ef          	jal	ra,80000c9c <memmove>
    bwrite(to);  // write the log
    80003e10:	8526                	mv	a0,s1
    80003e12:	ef7fe0ef          	jal	ra,80002d08 <bwrite>
    brelse(from);
    80003e16:	854e                	mv	a0,s3
    80003e18:	f23fe0ef          	jal	ra,80002d3a <brelse>
    brelse(to);
    80003e1c:	8526                	mv	a0,s1
    80003e1e:	f1dfe0ef          	jal	ra,80002d3a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e22:	2905                	addiw	s2,s2,1
    80003e24:	0a91                	addi	s5,s5,4
    80003e26:	028a2783          	lw	a5,40(s4)
    80003e2a:	faf94ae3          	blt	s2,a5,80003dde <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e2e:	cd7ff0ef          	jal	ra,80003b04 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e32:	4501                	li	a0,0
    80003e34:	d3fff0ef          	jal	ra,80003b72 <install_trans>
    log.lh.n = 0;
    80003e38:	0001c797          	auipc	a5,0x1c
    80003e3c:	0407a823          	sw	zero,80(a5) # 8001fe88 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e40:	cc5ff0ef          	jal	ra,80003b04 <write_head>
    80003e44:	bf25                	j	80003d7c <end_op+0x4a>

0000000080003e46 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e46:	1101                	addi	sp,sp,-32
    80003e48:	ec06                	sd	ra,24(sp)
    80003e4a:	e822                	sd	s0,16(sp)
    80003e4c:	e426                	sd	s1,8(sp)
    80003e4e:	e04a                	sd	s2,0(sp)
    80003e50:	1000                	addi	s0,sp,32
    80003e52:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e54:	0001c917          	auipc	s2,0x1c
    80003e58:	00c90913          	addi	s2,s2,12 # 8001fe60 <log>
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	d0ffc0ef          	jal	ra,80000b6c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e62:	02892603          	lw	a2,40(s2)
    80003e66:	47f5                	li	a5,29
    80003e68:	04c7cc63          	blt	a5,a2,80003ec0 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e6c:	0001c797          	auipc	a5,0x1c
    80003e70:	0107a783          	lw	a5,16(a5) # 8001fe7c <log+0x1c>
    80003e74:	04f05c63          	blez	a5,80003ecc <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e78:	4781                	li	a5,0
    80003e7a:	04c05f63          	blez	a2,80003ed8 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e7e:	44cc                	lw	a1,12(s1)
    80003e80:	0001c717          	auipc	a4,0x1c
    80003e84:	00c70713          	addi	a4,a4,12 # 8001fe8c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003e88:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e8a:	4314                	lw	a3,0(a4)
    80003e8c:	04b68663          	beq	a3,a1,80003ed8 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003e90:	2785                	addiw	a5,a5,1
    80003e92:	0711                	addi	a4,a4,4
    80003e94:	fef61be3          	bne	a2,a5,80003e8a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e98:	0621                	addi	a2,a2,8
    80003e9a:	060a                	slli	a2,a2,0x2
    80003e9c:	0001c797          	auipc	a5,0x1c
    80003ea0:	fc478793          	addi	a5,a5,-60 # 8001fe60 <log>
    80003ea4:	963e                	add	a2,a2,a5
    80003ea6:	44dc                	lw	a5,12(s1)
    80003ea8:	c65c                	sw	a5,12(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003eaa:	8526                	mv	a0,s1
    80003eac:	f19fe0ef          	jal	ra,80002dc4 <bpin>
    log.lh.n++;
    80003eb0:	0001c717          	auipc	a4,0x1c
    80003eb4:	fb070713          	addi	a4,a4,-80 # 8001fe60 <log>
    80003eb8:	571c                	lw	a5,40(a4)
    80003eba:	2785                	addiw	a5,a5,1
    80003ebc:	d71c                	sw	a5,40(a4)
    80003ebe:	a815                	j	80003ef2 <log_write+0xac>
    panic("too big a transaction");
    80003ec0:	00004517          	auipc	a0,0x4
    80003ec4:	86050513          	addi	a0,a0,-1952 # 80007720 <syscalls+0x270>
    80003ec8:	8c3fc0ef          	jal	ra,8000078a <panic>
    panic("log_write outside of trans");
    80003ecc:	00004517          	auipc	a0,0x4
    80003ed0:	86c50513          	addi	a0,a0,-1940 # 80007738 <syscalls+0x288>
    80003ed4:	8b7fc0ef          	jal	ra,8000078a <panic>
  log.lh.block[i] = b->blockno;
    80003ed8:	00878713          	addi	a4,a5,8
    80003edc:	00271693          	slli	a3,a4,0x2
    80003ee0:	0001c717          	auipc	a4,0x1c
    80003ee4:	f8070713          	addi	a4,a4,-128 # 8001fe60 <log>
    80003ee8:	9736                	add	a4,a4,a3
    80003eea:	44d4                	lw	a3,12(s1)
    80003eec:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003eee:	faf60ee3          	beq	a2,a5,80003eaa <log_write+0x64>
  }
  release(&log.lock);
    80003ef2:	0001c517          	auipc	a0,0x1c
    80003ef6:	f6e50513          	addi	a0,a0,-146 # 8001fe60 <log>
    80003efa:	d0bfc0ef          	jal	ra,80000c04 <release>
}
    80003efe:	60e2                	ld	ra,24(sp)
    80003f00:	6442                	ld	s0,16(sp)
    80003f02:	64a2                	ld	s1,8(sp)
    80003f04:	6902                	ld	s2,0(sp)
    80003f06:	6105                	addi	sp,sp,32
    80003f08:	8082                	ret

0000000080003f0a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f0a:	1101                	addi	sp,sp,-32
    80003f0c:	ec06                	sd	ra,24(sp)
    80003f0e:	e822                	sd	s0,16(sp)
    80003f10:	e426                	sd	s1,8(sp)
    80003f12:	e04a                	sd	s2,0(sp)
    80003f14:	1000                	addi	s0,sp,32
    80003f16:	84aa                	mv	s1,a0
    80003f18:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f1a:	00004597          	auipc	a1,0x4
    80003f1e:	83e58593          	addi	a1,a1,-1986 # 80007758 <syscalls+0x2a8>
    80003f22:	0521                	addi	a0,a0,8
    80003f24:	bc9fc0ef          	jal	ra,80000aec <initlock>
  lk->name = name;
    80003f28:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f2c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f30:	0204a423          	sw	zero,40(s1)
}
    80003f34:	60e2                	ld	ra,24(sp)
    80003f36:	6442                	ld	s0,16(sp)
    80003f38:	64a2                	ld	s1,8(sp)
    80003f3a:	6902                	ld	s2,0(sp)
    80003f3c:	6105                	addi	sp,sp,32
    80003f3e:	8082                	ret

0000000080003f40 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f40:	1101                	addi	sp,sp,-32
    80003f42:	ec06                	sd	ra,24(sp)
    80003f44:	e822                	sd	s0,16(sp)
    80003f46:	e426                	sd	s1,8(sp)
    80003f48:	e04a                	sd	s2,0(sp)
    80003f4a:	1000                	addi	s0,sp,32
    80003f4c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f4e:	00850913          	addi	s2,a0,8
    80003f52:	854a                	mv	a0,s2
    80003f54:	c19fc0ef          	jal	ra,80000b6c <acquire>
  while (lk->locked) {
    80003f58:	409c                	lw	a5,0(s1)
    80003f5a:	c799                	beqz	a5,80003f68 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f5c:	85ca                	mv	a1,s2
    80003f5e:	8526                	mv	a0,s1
    80003f60:	fd1fd0ef          	jal	ra,80001f30 <sleep>
  while (lk->locked) {
    80003f64:	409c                	lw	a5,0(s1)
    80003f66:	fbfd                	bnez	a5,80003f5c <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f68:	4785                	li	a5,1
    80003f6a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f6c:	8adfd0ef          	jal	ra,80001818 <myproc>
    80003f70:	591c                	lw	a5,48(a0)
    80003f72:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f74:	854a                	mv	a0,s2
    80003f76:	c8ffc0ef          	jal	ra,80000c04 <release>
}
    80003f7a:	60e2                	ld	ra,24(sp)
    80003f7c:	6442                	ld	s0,16(sp)
    80003f7e:	64a2                	ld	s1,8(sp)
    80003f80:	6902                	ld	s2,0(sp)
    80003f82:	6105                	addi	sp,sp,32
    80003f84:	8082                	ret

0000000080003f86 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f86:	1101                	addi	sp,sp,-32
    80003f88:	ec06                	sd	ra,24(sp)
    80003f8a:	e822                	sd	s0,16(sp)
    80003f8c:	e426                	sd	s1,8(sp)
    80003f8e:	e04a                	sd	s2,0(sp)
    80003f90:	1000                	addi	s0,sp,32
    80003f92:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f94:	00850913          	addi	s2,a0,8
    80003f98:	854a                	mv	a0,s2
    80003f9a:	bd3fc0ef          	jal	ra,80000b6c <acquire>
  lk->locked = 0;
    80003f9e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fa2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	fd5fd0ef          	jal	ra,80001f7c <wakeup>
  release(&lk->lk);
    80003fac:	854a                	mv	a0,s2
    80003fae:	c57fc0ef          	jal	ra,80000c04 <release>
}
    80003fb2:	60e2                	ld	ra,24(sp)
    80003fb4:	6442                	ld	s0,16(sp)
    80003fb6:	64a2                	ld	s1,8(sp)
    80003fb8:	6902                	ld	s2,0(sp)
    80003fba:	6105                	addi	sp,sp,32
    80003fbc:	8082                	ret

0000000080003fbe <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003fbe:	7179                	addi	sp,sp,-48
    80003fc0:	f406                	sd	ra,40(sp)
    80003fc2:	f022                	sd	s0,32(sp)
    80003fc4:	ec26                	sd	s1,24(sp)
    80003fc6:	e84a                	sd	s2,16(sp)
    80003fc8:	e44e                	sd	s3,8(sp)
    80003fca:	1800                	addi	s0,sp,48
    80003fcc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003fce:	00850913          	addi	s2,a0,8
    80003fd2:	854a                	mv	a0,s2
    80003fd4:	b99fc0ef          	jal	ra,80000b6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fd8:	409c                	lw	a5,0(s1)
    80003fda:	ef89                	bnez	a5,80003ff4 <holdingsleep+0x36>
    80003fdc:	4481                	li	s1,0
  release(&lk->lk);
    80003fde:	854a                	mv	a0,s2
    80003fe0:	c25fc0ef          	jal	ra,80000c04 <release>
  return r;
}
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	70a2                	ld	ra,40(sp)
    80003fe8:	7402                	ld	s0,32(sp)
    80003fea:	64e2                	ld	s1,24(sp)
    80003fec:	6942                	ld	s2,16(sp)
    80003fee:	69a2                	ld	s3,8(sp)
    80003ff0:	6145                	addi	sp,sp,48
    80003ff2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ff4:	0284a983          	lw	s3,40(s1)
    80003ff8:	821fd0ef          	jal	ra,80001818 <myproc>
    80003ffc:	5904                	lw	s1,48(a0)
    80003ffe:	413484b3          	sub	s1,s1,s3
    80004002:	0014b493          	seqz	s1,s1
    80004006:	bfe1                	j	80003fde <holdingsleep+0x20>

0000000080004008 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004008:	1141                	addi	sp,sp,-16
    8000400a:	e406                	sd	ra,8(sp)
    8000400c:	e022                	sd	s0,0(sp)
    8000400e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004010:	00003597          	auipc	a1,0x3
    80004014:	75858593          	addi	a1,a1,1880 # 80007768 <syscalls+0x2b8>
    80004018:	0001c517          	auipc	a0,0x1c
    8000401c:	f9050513          	addi	a0,a0,-112 # 8001ffa8 <ftable>
    80004020:	acdfc0ef          	jal	ra,80000aec <initlock>
}
    80004024:	60a2                	ld	ra,8(sp)
    80004026:	6402                	ld	s0,0(sp)
    80004028:	0141                	addi	sp,sp,16
    8000402a:	8082                	ret

000000008000402c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000402c:	1101                	addi	sp,sp,-32
    8000402e:	ec06                	sd	ra,24(sp)
    80004030:	e822                	sd	s0,16(sp)
    80004032:	e426                	sd	s1,8(sp)
    80004034:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004036:	0001c517          	auipc	a0,0x1c
    8000403a:	f7250513          	addi	a0,a0,-142 # 8001ffa8 <ftable>
    8000403e:	b2ffc0ef          	jal	ra,80000b6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004042:	0001c497          	auipc	s1,0x1c
    80004046:	f7e48493          	addi	s1,s1,-130 # 8001ffc0 <ftable+0x18>
    8000404a:	0001d717          	auipc	a4,0x1d
    8000404e:	f1670713          	addi	a4,a4,-234 # 80020f60 <disk>
    if(f->ref == 0){
    80004052:	40dc                	lw	a5,4(s1)
    80004054:	cf89                	beqz	a5,8000406e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004056:	02848493          	addi	s1,s1,40
    8000405a:	fee49ce3          	bne	s1,a4,80004052 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000405e:	0001c517          	auipc	a0,0x1c
    80004062:	f4a50513          	addi	a0,a0,-182 # 8001ffa8 <ftable>
    80004066:	b9ffc0ef          	jal	ra,80000c04 <release>
  return 0;
    8000406a:	4481                	li	s1,0
    8000406c:	a809                	j	8000407e <filealloc+0x52>
      f->ref = 1;
    8000406e:	4785                	li	a5,1
    80004070:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004072:	0001c517          	auipc	a0,0x1c
    80004076:	f3650513          	addi	a0,a0,-202 # 8001ffa8 <ftable>
    8000407a:	b8bfc0ef          	jal	ra,80000c04 <release>
}
    8000407e:	8526                	mv	a0,s1
    80004080:	60e2                	ld	ra,24(sp)
    80004082:	6442                	ld	s0,16(sp)
    80004084:	64a2                	ld	s1,8(sp)
    80004086:	6105                	addi	sp,sp,32
    80004088:	8082                	ret

000000008000408a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000408a:	1101                	addi	sp,sp,-32
    8000408c:	ec06                	sd	ra,24(sp)
    8000408e:	e822                	sd	s0,16(sp)
    80004090:	e426                	sd	s1,8(sp)
    80004092:	1000                	addi	s0,sp,32
    80004094:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004096:	0001c517          	auipc	a0,0x1c
    8000409a:	f1250513          	addi	a0,a0,-238 # 8001ffa8 <ftable>
    8000409e:	acffc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    800040a2:	40dc                	lw	a5,4(s1)
    800040a4:	02f05063          	blez	a5,800040c4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800040a8:	2785                	addiw	a5,a5,1
    800040aa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800040ac:	0001c517          	auipc	a0,0x1c
    800040b0:	efc50513          	addi	a0,a0,-260 # 8001ffa8 <ftable>
    800040b4:	b51fc0ef          	jal	ra,80000c04 <release>
  return f;
}
    800040b8:	8526                	mv	a0,s1
    800040ba:	60e2                	ld	ra,24(sp)
    800040bc:	6442                	ld	s0,16(sp)
    800040be:	64a2                	ld	s1,8(sp)
    800040c0:	6105                	addi	sp,sp,32
    800040c2:	8082                	ret
    panic("filedup");
    800040c4:	00003517          	auipc	a0,0x3
    800040c8:	6ac50513          	addi	a0,a0,1708 # 80007770 <syscalls+0x2c0>
    800040cc:	ebefc0ef          	jal	ra,8000078a <panic>

00000000800040d0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040d0:	7139                	addi	sp,sp,-64
    800040d2:	fc06                	sd	ra,56(sp)
    800040d4:	f822                	sd	s0,48(sp)
    800040d6:	f426                	sd	s1,40(sp)
    800040d8:	f04a                	sd	s2,32(sp)
    800040da:	ec4e                	sd	s3,24(sp)
    800040dc:	e852                	sd	s4,16(sp)
    800040de:	e456                	sd	s5,8(sp)
    800040e0:	0080                	addi	s0,sp,64
    800040e2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040e4:	0001c517          	auipc	a0,0x1c
    800040e8:	ec450513          	addi	a0,a0,-316 # 8001ffa8 <ftable>
    800040ec:	a81fc0ef          	jal	ra,80000b6c <acquire>
  if(f->ref < 1)
    800040f0:	40dc                	lw	a5,4(s1)
    800040f2:	04f05963          	blez	a5,80004144 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    800040f6:	37fd                	addiw	a5,a5,-1
    800040f8:	0007871b          	sext.w	a4,a5
    800040fc:	c0dc                	sw	a5,4(s1)
    800040fe:	04e04963          	bgtz	a4,80004150 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004102:	0004a903          	lw	s2,0(s1)
    80004106:	0094ca83          	lbu	s5,9(s1)
    8000410a:	0104ba03          	ld	s4,16(s1)
    8000410e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004112:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004116:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000411a:	0001c517          	auipc	a0,0x1c
    8000411e:	e8e50513          	addi	a0,a0,-370 # 8001ffa8 <ftable>
    80004122:	ae3fc0ef          	jal	ra,80000c04 <release>

  if(ff.type == FD_PIPE){
    80004126:	4785                	li	a5,1
    80004128:	04f90363          	beq	s2,a5,8000416e <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000412c:	3979                	addiw	s2,s2,-2
    8000412e:	4785                	li	a5,1
    80004130:	0327e663          	bltu	a5,s2,8000415c <fileclose+0x8c>
    begin_op();
    80004134:	b8fff0ef          	jal	ra,80003cc2 <begin_op>
    iput(ff.ip);
    80004138:	854e                	mv	a0,s3
    8000413a:	b28ff0ef          	jal	ra,80003462 <iput>
    end_op();
    8000413e:	bf5ff0ef          	jal	ra,80003d32 <end_op>
    80004142:	a829                	j	8000415c <fileclose+0x8c>
    panic("fileclose");
    80004144:	00003517          	auipc	a0,0x3
    80004148:	63450513          	addi	a0,a0,1588 # 80007778 <syscalls+0x2c8>
    8000414c:	e3efc0ef          	jal	ra,8000078a <panic>
    release(&ftable.lock);
    80004150:	0001c517          	auipc	a0,0x1c
    80004154:	e5850513          	addi	a0,a0,-424 # 8001ffa8 <ftable>
    80004158:	aadfc0ef          	jal	ra,80000c04 <release>
  }
}
    8000415c:	70e2                	ld	ra,56(sp)
    8000415e:	7442                	ld	s0,48(sp)
    80004160:	74a2                	ld	s1,40(sp)
    80004162:	7902                	ld	s2,32(sp)
    80004164:	69e2                	ld	s3,24(sp)
    80004166:	6a42                	ld	s4,16(sp)
    80004168:	6aa2                	ld	s5,8(sp)
    8000416a:	6121                	addi	sp,sp,64
    8000416c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000416e:	85d6                	mv	a1,s5
    80004170:	8552                	mv	a0,s4
    80004172:	2ec000ef          	jal	ra,8000445e <pipeclose>
    80004176:	b7dd                	j	8000415c <fileclose+0x8c>

0000000080004178 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004178:	715d                	addi	sp,sp,-80
    8000417a:	e486                	sd	ra,72(sp)
    8000417c:	e0a2                	sd	s0,64(sp)
    8000417e:	fc26                	sd	s1,56(sp)
    80004180:	f84a                	sd	s2,48(sp)
    80004182:	f44e                	sd	s3,40(sp)
    80004184:	0880                	addi	s0,sp,80
    80004186:	84aa                	mv	s1,a0
    80004188:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000418a:	e8efd0ef          	jal	ra,80001818 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000418e:	409c                	lw	a5,0(s1)
    80004190:	37f9                	addiw	a5,a5,-2
    80004192:	4705                	li	a4,1
    80004194:	02f76f63          	bltu	a4,a5,800041d2 <filestat+0x5a>
    80004198:	892a                	mv	s2,a0
    ilock(f->ip);
    8000419a:	6c88                	ld	a0,24(s1)
    8000419c:	948ff0ef          	jal	ra,800032e4 <ilock>
    stati(f->ip, &st);
    800041a0:	fb840593          	addi	a1,s0,-72
    800041a4:	6c88                	ld	a0,24(s1)
    800041a6:	ca0ff0ef          	jal	ra,80003646 <stati>
    iunlock(f->ip);
    800041aa:	6c88                	ld	a0,24(s1)
    800041ac:	9e2ff0ef          	jal	ra,8000338e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800041b0:	46e1                	li	a3,24
    800041b2:	fb840613          	addi	a2,s0,-72
    800041b6:	85ce                	mv	a1,s3
    800041b8:	05093503          	ld	a0,80(s2)
    800041bc:	b96fd0ef          	jal	ra,80001552 <copyout>
    800041c0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800041c4:	60a6                	ld	ra,72(sp)
    800041c6:	6406                	ld	s0,64(sp)
    800041c8:	74e2                	ld	s1,56(sp)
    800041ca:	7942                	ld	s2,48(sp)
    800041cc:	79a2                	ld	s3,40(sp)
    800041ce:	6161                	addi	sp,sp,80
    800041d0:	8082                	ret
  return -1;
    800041d2:	557d                	li	a0,-1
    800041d4:	bfc5                	j	800041c4 <filestat+0x4c>

00000000800041d6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041d6:	7179                	addi	sp,sp,-48
    800041d8:	f406                	sd	ra,40(sp)
    800041da:	f022                	sd	s0,32(sp)
    800041dc:	ec26                	sd	s1,24(sp)
    800041de:	e84a                	sd	s2,16(sp)
    800041e0:	e44e                	sd	s3,8(sp)
    800041e2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041e4:	00854783          	lbu	a5,8(a0)
    800041e8:	cbc1                	beqz	a5,80004278 <fileread+0xa2>
    800041ea:	84aa                	mv	s1,a0
    800041ec:	89ae                	mv	s3,a1
    800041ee:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800041f0:	411c                	lw	a5,0(a0)
    800041f2:	4705                	li	a4,1
    800041f4:	04e78363          	beq	a5,a4,8000423a <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041f8:	470d                	li	a4,3
    800041fa:	04e78563          	beq	a5,a4,80004244 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800041fe:	4709                	li	a4,2
    80004200:	06e79663          	bne	a5,a4,8000426c <fileread+0x96>
    ilock(f->ip);
    80004204:	6d08                	ld	a0,24(a0)
    80004206:	8deff0ef          	jal	ra,800032e4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000420a:	874a                	mv	a4,s2
    8000420c:	5094                	lw	a3,32(s1)
    8000420e:	864e                	mv	a2,s3
    80004210:	4585                	li	a1,1
    80004212:	6c88                	ld	a0,24(s1)
    80004214:	c5cff0ef          	jal	ra,80003670 <readi>
    80004218:	892a                	mv	s2,a0
    8000421a:	00a05563          	blez	a0,80004224 <fileread+0x4e>
      f->off += r;
    8000421e:	509c                	lw	a5,32(s1)
    80004220:	9fa9                	addw	a5,a5,a0
    80004222:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004224:	6c88                	ld	a0,24(s1)
    80004226:	968ff0ef          	jal	ra,8000338e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000422a:	854a                	mv	a0,s2
    8000422c:	70a2                	ld	ra,40(sp)
    8000422e:	7402                	ld	s0,32(sp)
    80004230:	64e2                	ld	s1,24(sp)
    80004232:	6942                	ld	s2,16(sp)
    80004234:	69a2                	ld	s3,8(sp)
    80004236:	6145                	addi	sp,sp,48
    80004238:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000423a:	6908                	ld	a0,16(a0)
    8000423c:	34e000ef          	jal	ra,8000458a <piperead>
    80004240:	892a                	mv	s2,a0
    80004242:	b7e5                	j	8000422a <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004244:	02451783          	lh	a5,36(a0)
    80004248:	03079693          	slli	a3,a5,0x30
    8000424c:	92c1                	srli	a3,a3,0x30
    8000424e:	4725                	li	a4,9
    80004250:	02d76663          	bltu	a4,a3,8000427c <fileread+0xa6>
    80004254:	0792                	slli	a5,a5,0x4
    80004256:	0001c717          	auipc	a4,0x1c
    8000425a:	cb270713          	addi	a4,a4,-846 # 8001ff08 <devsw>
    8000425e:	97ba                	add	a5,a5,a4
    80004260:	639c                	ld	a5,0(a5)
    80004262:	cf99                	beqz	a5,80004280 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80004264:	4505                	li	a0,1
    80004266:	9782                	jalr	a5
    80004268:	892a                	mv	s2,a0
    8000426a:	b7c1                	j	8000422a <fileread+0x54>
    panic("fileread");
    8000426c:	00003517          	auipc	a0,0x3
    80004270:	51c50513          	addi	a0,a0,1308 # 80007788 <syscalls+0x2d8>
    80004274:	d16fc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004278:	597d                	li	s2,-1
    8000427a:	bf45                	j	8000422a <fileread+0x54>
      return -1;
    8000427c:	597d                	li	s2,-1
    8000427e:	b775                	j	8000422a <fileread+0x54>
    80004280:	597d                	li	s2,-1
    80004282:	b765                	j	8000422a <fileread+0x54>

0000000080004284 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004284:	715d                	addi	sp,sp,-80
    80004286:	e486                	sd	ra,72(sp)
    80004288:	e0a2                	sd	s0,64(sp)
    8000428a:	fc26                	sd	s1,56(sp)
    8000428c:	f84a                	sd	s2,48(sp)
    8000428e:	f44e                	sd	s3,40(sp)
    80004290:	f052                	sd	s4,32(sp)
    80004292:	ec56                	sd	s5,24(sp)
    80004294:	e85a                	sd	s6,16(sp)
    80004296:	e45e                	sd	s7,8(sp)
    80004298:	e062                	sd	s8,0(sp)
    8000429a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000429c:	00954783          	lbu	a5,9(a0)
    800042a0:	0e078863          	beqz	a5,80004390 <filewrite+0x10c>
    800042a4:	892a                	mv	s2,a0
    800042a6:	8aae                	mv	s5,a1
    800042a8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800042aa:	411c                	lw	a5,0(a0)
    800042ac:	4705                	li	a4,1
    800042ae:	02e78263          	beq	a5,a4,800042d2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042b2:	470d                	li	a4,3
    800042b4:	02e78463          	beq	a5,a4,800042dc <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042b8:	4709                	li	a4,2
    800042ba:	0ce79563          	bne	a5,a4,80004384 <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042be:	0ac05163          	blez	a2,80004360 <filewrite+0xdc>
    int i = 0;
    800042c2:	4981                	li	s3,0
    800042c4:	6b05                	lui	s6,0x1
    800042c6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800042ca:	6b85                	lui	s7,0x1
    800042cc:	c00b8b9b          	addiw	s7,s7,-1024
    800042d0:	a041                	j	80004350 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800042d2:	6908                	ld	a0,16(a0)
    800042d4:	1e2000ef          	jal	ra,800044b6 <pipewrite>
    800042d8:	8a2a                	mv	s4,a0
    800042da:	a071                	j	80004366 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042dc:	02451783          	lh	a5,36(a0)
    800042e0:	03079693          	slli	a3,a5,0x30
    800042e4:	92c1                	srli	a3,a3,0x30
    800042e6:	4725                	li	a4,9
    800042e8:	0ad76663          	bltu	a4,a3,80004394 <filewrite+0x110>
    800042ec:	0792                	slli	a5,a5,0x4
    800042ee:	0001c717          	auipc	a4,0x1c
    800042f2:	c1a70713          	addi	a4,a4,-998 # 8001ff08 <devsw>
    800042f6:	97ba                	add	a5,a5,a4
    800042f8:	679c                	ld	a5,8(a5)
    800042fa:	cfd9                	beqz	a5,80004398 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    800042fc:	4505                	li	a0,1
    800042fe:	9782                	jalr	a5
    80004300:	8a2a                	mv	s4,a0
    80004302:	a095                	j	80004366 <filewrite+0xe2>
    80004304:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004308:	9bbff0ef          	jal	ra,80003cc2 <begin_op>
      ilock(f->ip);
    8000430c:	01893503          	ld	a0,24(s2)
    80004310:	fd5fe0ef          	jal	ra,800032e4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004314:	8762                	mv	a4,s8
    80004316:	02092683          	lw	a3,32(s2)
    8000431a:	01598633          	add	a2,s3,s5
    8000431e:	4585                	li	a1,1
    80004320:	01893503          	ld	a0,24(s2)
    80004324:	c30ff0ef          	jal	ra,80003754 <writei>
    80004328:	84aa                	mv	s1,a0
    8000432a:	00a05763          	blez	a0,80004338 <filewrite+0xb4>
        f->off += r;
    8000432e:	02092783          	lw	a5,32(s2)
    80004332:	9fa9                	addw	a5,a5,a0
    80004334:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004338:	01893503          	ld	a0,24(s2)
    8000433c:	852ff0ef          	jal	ra,8000338e <iunlock>
      end_op();
    80004340:	9f3ff0ef          	jal	ra,80003d32 <end_op>

      if(r != n1){
    80004344:	009c1f63          	bne	s8,s1,80004362 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004348:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000434c:	0149db63          	bge	s3,s4,80004362 <filewrite+0xde>
      int n1 = n - i;
    80004350:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004354:	84be                	mv	s1,a5
    80004356:	2781                	sext.w	a5,a5
    80004358:	fafb56e3          	bge	s6,a5,80004304 <filewrite+0x80>
    8000435c:	84de                	mv	s1,s7
    8000435e:	b75d                	j	80004304 <filewrite+0x80>
    int i = 0;
    80004360:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004362:	013a1f63          	bne	s4,s3,80004380 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004366:	8552                	mv	a0,s4
    80004368:	60a6                	ld	ra,72(sp)
    8000436a:	6406                	ld	s0,64(sp)
    8000436c:	74e2                	ld	s1,56(sp)
    8000436e:	7942                	ld	s2,48(sp)
    80004370:	79a2                	ld	s3,40(sp)
    80004372:	7a02                	ld	s4,32(sp)
    80004374:	6ae2                	ld	s5,24(sp)
    80004376:	6b42                	ld	s6,16(sp)
    80004378:	6ba2                	ld	s7,8(sp)
    8000437a:	6c02                	ld	s8,0(sp)
    8000437c:	6161                	addi	sp,sp,80
    8000437e:	8082                	ret
    ret = (i == n ? n : -1);
    80004380:	5a7d                	li	s4,-1
    80004382:	b7d5                	j	80004366 <filewrite+0xe2>
    panic("filewrite");
    80004384:	00003517          	auipc	a0,0x3
    80004388:	41450513          	addi	a0,a0,1044 # 80007798 <syscalls+0x2e8>
    8000438c:	bfefc0ef          	jal	ra,8000078a <panic>
    return -1;
    80004390:	5a7d                	li	s4,-1
    80004392:	bfd1                	j	80004366 <filewrite+0xe2>
      return -1;
    80004394:	5a7d                	li	s4,-1
    80004396:	bfc1                	j	80004366 <filewrite+0xe2>
    80004398:	5a7d                	li	s4,-1
    8000439a:	b7f1                	j	80004366 <filewrite+0xe2>

000000008000439c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000439c:	7179                	addi	sp,sp,-48
    8000439e:	f406                	sd	ra,40(sp)
    800043a0:	f022                	sd	s0,32(sp)
    800043a2:	ec26                	sd	s1,24(sp)
    800043a4:	e84a                	sd	s2,16(sp)
    800043a6:	e44e                	sd	s3,8(sp)
    800043a8:	e052                	sd	s4,0(sp)
    800043aa:	1800                	addi	s0,sp,48
    800043ac:	84aa                	mv	s1,a0
    800043ae:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043b0:	0005b023          	sd	zero,0(a1)
    800043b4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043b8:	c75ff0ef          	jal	ra,8000402c <filealloc>
    800043bc:	e088                	sd	a0,0(s1)
    800043be:	cd35                	beqz	a0,8000443a <pipealloc+0x9e>
    800043c0:	c6dff0ef          	jal	ra,8000402c <filealloc>
    800043c4:	00aa3023          	sd	a0,0(s4)
    800043c8:	c52d                	beqz	a0,80004432 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800043ca:	ed2fc0ef          	jal	ra,80000a9c <kalloc>
    800043ce:	892a                	mv	s2,a0
    800043d0:	cd31                	beqz	a0,8000442c <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    800043d2:	4985                	li	s3,1
    800043d4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800043d8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800043dc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800043e0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800043e4:	00003597          	auipc	a1,0x3
    800043e8:	3c458593          	addi	a1,a1,964 # 800077a8 <syscalls+0x2f8>
    800043ec:	f00fc0ef          	jal	ra,80000aec <initlock>
  (*f0)->type = FD_PIPE;
    800043f0:	609c                	ld	a5,0(s1)
    800043f2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800043f6:	609c                	ld	a5,0(s1)
    800043f8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800043fc:	609c                	ld	a5,0(s1)
    800043fe:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004402:	609c                	ld	a5,0(s1)
    80004404:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004408:	000a3783          	ld	a5,0(s4)
    8000440c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004410:	000a3783          	ld	a5,0(s4)
    80004414:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004418:	000a3783          	ld	a5,0(s4)
    8000441c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004420:	000a3783          	ld	a5,0(s4)
    80004424:	0127b823          	sd	s2,16(a5)
  return 0;
    80004428:	4501                	li	a0,0
    8000442a:	a005                	j	8000444a <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000442c:	6088                	ld	a0,0(s1)
    8000442e:	e501                	bnez	a0,80004436 <pipealloc+0x9a>
    80004430:	a029                	j	8000443a <pipealloc+0x9e>
    80004432:	6088                	ld	a0,0(s1)
    80004434:	c11d                	beqz	a0,8000445a <pipealloc+0xbe>
    fileclose(*f0);
    80004436:	c9bff0ef          	jal	ra,800040d0 <fileclose>
  if(*f1)
    8000443a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000443e:	557d                	li	a0,-1
  if(*f1)
    80004440:	c789                	beqz	a5,8000444a <pipealloc+0xae>
    fileclose(*f1);
    80004442:	853e                	mv	a0,a5
    80004444:	c8dff0ef          	jal	ra,800040d0 <fileclose>
  return -1;
    80004448:	557d                	li	a0,-1
}
    8000444a:	70a2                	ld	ra,40(sp)
    8000444c:	7402                	ld	s0,32(sp)
    8000444e:	64e2                	ld	s1,24(sp)
    80004450:	6942                	ld	s2,16(sp)
    80004452:	69a2                	ld	s3,8(sp)
    80004454:	6a02                	ld	s4,0(sp)
    80004456:	6145                	addi	sp,sp,48
    80004458:	8082                	ret
  return -1;
    8000445a:	557d                	li	a0,-1
    8000445c:	b7fd                	j	8000444a <pipealloc+0xae>

000000008000445e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000445e:	1101                	addi	sp,sp,-32
    80004460:	ec06                	sd	ra,24(sp)
    80004462:	e822                	sd	s0,16(sp)
    80004464:	e426                	sd	s1,8(sp)
    80004466:	e04a                	sd	s2,0(sp)
    80004468:	1000                	addi	s0,sp,32
    8000446a:	84aa                	mv	s1,a0
    8000446c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000446e:	efefc0ef          	jal	ra,80000b6c <acquire>
  if(writable){
    80004472:	02090763          	beqz	s2,800044a0 <pipeclose+0x42>
    pi->writeopen = 0;
    80004476:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000447a:	21848513          	addi	a0,s1,536
    8000447e:	afffd0ef          	jal	ra,80001f7c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004482:	2204b783          	ld	a5,544(s1)
    80004486:	e785                	bnez	a5,800044ae <pipeclose+0x50>
    release(&pi->lock);
    80004488:	8526                	mv	a0,s1
    8000448a:	f7afc0ef          	jal	ra,80000c04 <release>
    kfree((char*)pi);
    8000448e:	8526                	mv	a0,s1
    80004490:	d2cfc0ef          	jal	ra,800009bc <kfree>
  } else
    release(&pi->lock);
}
    80004494:	60e2                	ld	ra,24(sp)
    80004496:	6442                	ld	s0,16(sp)
    80004498:	64a2                	ld	s1,8(sp)
    8000449a:	6902                	ld	s2,0(sp)
    8000449c:	6105                	addi	sp,sp,32
    8000449e:	8082                	ret
    pi->readopen = 0;
    800044a0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044a4:	21c48513          	addi	a0,s1,540
    800044a8:	ad5fd0ef          	jal	ra,80001f7c <wakeup>
    800044ac:	bfd9                	j	80004482 <pipeclose+0x24>
    release(&pi->lock);
    800044ae:	8526                	mv	a0,s1
    800044b0:	f54fc0ef          	jal	ra,80000c04 <release>
}
    800044b4:	b7c5                	j	80004494 <pipeclose+0x36>

00000000800044b6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044b6:	711d                	addi	sp,sp,-96
    800044b8:	ec86                	sd	ra,88(sp)
    800044ba:	e8a2                	sd	s0,80(sp)
    800044bc:	e4a6                	sd	s1,72(sp)
    800044be:	e0ca                	sd	s2,64(sp)
    800044c0:	fc4e                	sd	s3,56(sp)
    800044c2:	f852                	sd	s4,48(sp)
    800044c4:	f456                	sd	s5,40(sp)
    800044c6:	f05a                	sd	s6,32(sp)
    800044c8:	ec5e                	sd	s7,24(sp)
    800044ca:	e862                	sd	s8,16(sp)
    800044cc:	1080                	addi	s0,sp,96
    800044ce:	84aa                	mv	s1,a0
    800044d0:	8aae                	mv	s5,a1
    800044d2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800044d4:	b44fd0ef          	jal	ra,80001818 <myproc>
    800044d8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800044da:	8526                	mv	a0,s1
    800044dc:	e90fc0ef          	jal	ra,80000b6c <acquire>
  while(i < n){
    800044e0:	09405c63          	blez	s4,80004578 <pipewrite+0xc2>
  int i = 0;
    800044e4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044e6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800044e8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800044ec:	21c48b93          	addi	s7,s1,540
    800044f0:	a81d                	j	80004526 <pipewrite+0x70>
      release(&pi->lock);
    800044f2:	8526                	mv	a0,s1
    800044f4:	f10fc0ef          	jal	ra,80000c04 <release>
      return -1;
    800044f8:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800044fa:	854a                	mv	a0,s2
    800044fc:	60e6                	ld	ra,88(sp)
    800044fe:	6446                	ld	s0,80(sp)
    80004500:	64a6                	ld	s1,72(sp)
    80004502:	6906                	ld	s2,64(sp)
    80004504:	79e2                	ld	s3,56(sp)
    80004506:	7a42                	ld	s4,48(sp)
    80004508:	7aa2                	ld	s5,40(sp)
    8000450a:	7b02                	ld	s6,32(sp)
    8000450c:	6be2                	ld	s7,24(sp)
    8000450e:	6c42                	ld	s8,16(sp)
    80004510:	6125                	addi	sp,sp,96
    80004512:	8082                	ret
      wakeup(&pi->nread);
    80004514:	8562                	mv	a0,s8
    80004516:	a67fd0ef          	jal	ra,80001f7c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000451a:	85a6                	mv	a1,s1
    8000451c:	855e                	mv	a0,s7
    8000451e:	a13fd0ef          	jal	ra,80001f30 <sleep>
  while(i < n){
    80004522:	05495c63          	bge	s2,s4,8000457a <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    80004526:	2204a783          	lw	a5,544(s1)
    8000452a:	d7e1                	beqz	a5,800044f2 <pipewrite+0x3c>
    8000452c:	854e                	mv	a0,s3
    8000452e:	c3bfd0ef          	jal	ra,80002168 <killed>
    80004532:	f161                	bnez	a0,800044f2 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004534:	2184a783          	lw	a5,536(s1)
    80004538:	21c4a703          	lw	a4,540(s1)
    8000453c:	2007879b          	addiw	a5,a5,512
    80004540:	fcf70ae3          	beq	a4,a5,80004514 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004544:	4685                	li	a3,1
    80004546:	01590633          	add	a2,s2,s5
    8000454a:	faf40593          	addi	a1,s0,-81
    8000454e:	0509b503          	ld	a0,80(s3)
    80004552:	8c6fd0ef          	jal	ra,80001618 <copyin>
    80004556:	03650263          	beq	a0,s6,8000457a <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000455a:	21c4a783          	lw	a5,540(s1)
    8000455e:	0017871b          	addiw	a4,a5,1
    80004562:	20e4ae23          	sw	a4,540(s1)
    80004566:	1ff7f793          	andi	a5,a5,511
    8000456a:	97a6                	add	a5,a5,s1
    8000456c:	faf44703          	lbu	a4,-81(s0)
    80004570:	00e78c23          	sb	a4,24(a5)
      i++;
    80004574:	2905                	addiw	s2,s2,1
    80004576:	b775                	j	80004522 <pipewrite+0x6c>
  int i = 0;
    80004578:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000457a:	21848513          	addi	a0,s1,536
    8000457e:	9fffd0ef          	jal	ra,80001f7c <wakeup>
  release(&pi->lock);
    80004582:	8526                	mv	a0,s1
    80004584:	e80fc0ef          	jal	ra,80000c04 <release>
  return i;
    80004588:	bf8d                	j	800044fa <pipewrite+0x44>

000000008000458a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000458a:	715d                	addi	sp,sp,-80
    8000458c:	e486                	sd	ra,72(sp)
    8000458e:	e0a2                	sd	s0,64(sp)
    80004590:	fc26                	sd	s1,56(sp)
    80004592:	f84a                	sd	s2,48(sp)
    80004594:	f44e                	sd	s3,40(sp)
    80004596:	f052                	sd	s4,32(sp)
    80004598:	ec56                	sd	s5,24(sp)
    8000459a:	e85a                	sd	s6,16(sp)
    8000459c:	0880                	addi	s0,sp,80
    8000459e:	84aa                	mv	s1,a0
    800045a0:	892e                	mv	s2,a1
    800045a2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800045a4:	a74fd0ef          	jal	ra,80001818 <myproc>
    800045a8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800045aa:	8526                	mv	a0,s1
    800045ac:	dc0fc0ef          	jal	ra,80000b6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045b0:	2184a703          	lw	a4,536(s1)
    800045b4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045b8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045bc:	02f71363          	bne	a4,a5,800045e2 <piperead+0x58>
    800045c0:	2244a783          	lw	a5,548(s1)
    800045c4:	cf99                	beqz	a5,800045e2 <piperead+0x58>
    if(killed(pr)){
    800045c6:	8552                	mv	a0,s4
    800045c8:	ba1fd0ef          	jal	ra,80002168 <killed>
    800045cc:	e149                	bnez	a0,8000464e <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045ce:	85a6                	mv	a1,s1
    800045d0:	854e                	mv	a0,s3
    800045d2:	95ffd0ef          	jal	ra,80001f30 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045d6:	2184a703          	lw	a4,536(s1)
    800045da:	21c4a783          	lw	a5,540(s1)
    800045de:	fef701e3          	beq	a4,a5,800045c0 <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045e2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045e4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045e6:	05505263          	blez	s5,8000462a <piperead+0xa0>
    if(pi->nread == pi->nwrite)
    800045ea:	2184a783          	lw	a5,536(s1)
    800045ee:	21c4a703          	lw	a4,540(s1)
    800045f2:	02f70c63          	beq	a4,a5,8000462a <piperead+0xa0>
    ch = pi->data[pi->nread % PIPESIZE];
    800045f6:	1ff7f793          	andi	a5,a5,511
    800045fa:	97a6                	add	a5,a5,s1
    800045fc:	0187c783          	lbu	a5,24(a5)
    80004600:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004604:	4685                	li	a3,1
    80004606:	fbf40613          	addi	a2,s0,-65
    8000460a:	85ca                	mv	a1,s2
    8000460c:	050a3503          	ld	a0,80(s4)
    80004610:	f43fc0ef          	jal	ra,80001552 <copyout>
    80004614:	05650263          	beq	a0,s6,80004658 <piperead+0xce>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004618:	2184a783          	lw	a5,536(s1)
    8000461c:	2785                	addiw	a5,a5,1
    8000461e:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004622:	2985                	addiw	s3,s3,1
    80004624:	0905                	addi	s2,s2,1
    80004626:	fd3a92e3          	bne	s5,s3,800045ea <piperead+0x60>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000462a:	21c48513          	addi	a0,s1,540
    8000462e:	94ffd0ef          	jal	ra,80001f7c <wakeup>
  release(&pi->lock);
    80004632:	8526                	mv	a0,s1
    80004634:	dd0fc0ef          	jal	ra,80000c04 <release>
  return i;
}
    80004638:	854e                	mv	a0,s3
    8000463a:	60a6                	ld	ra,72(sp)
    8000463c:	6406                	ld	s0,64(sp)
    8000463e:	74e2                	ld	s1,56(sp)
    80004640:	7942                	ld	s2,48(sp)
    80004642:	79a2                	ld	s3,40(sp)
    80004644:	7a02                	ld	s4,32(sp)
    80004646:	6ae2                	ld	s5,24(sp)
    80004648:	6b42                	ld	s6,16(sp)
    8000464a:	6161                	addi	sp,sp,80
    8000464c:	8082                	ret
      release(&pi->lock);
    8000464e:	8526                	mv	a0,s1
    80004650:	db4fc0ef          	jal	ra,80000c04 <release>
      return -1;
    80004654:	59fd                	li	s3,-1
    80004656:	b7cd                	j	80004638 <piperead+0xae>
      if(i == 0)
    80004658:	fc0999e3          	bnez	s3,8000462a <piperead+0xa0>
        i = -1;
    8000465c:	89aa                	mv	s3,a0
    8000465e:	b7f1                	j	8000462a <piperead+0xa0>

0000000080004660 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004660:	1141                	addi	sp,sp,-16
    80004662:	e422                	sd	s0,8(sp)
    80004664:	0800                	addi	s0,sp,16
    80004666:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004668:	8905                	andi	a0,a0,1
    8000466a:	c111                	beqz	a0,8000466e <flags2perm+0xe>
      perm = PTE_X;
    8000466c:	4521                	li	a0,8
    if(flags & 0x2)
    8000466e:	8b89                	andi	a5,a5,2
    80004670:	c399                	beqz	a5,80004676 <flags2perm+0x16>
      perm |= PTE_W;
    80004672:	00456513          	ori	a0,a0,4
    return perm;
}
    80004676:	6422                	ld	s0,8(sp)
    80004678:	0141                	addi	sp,sp,16
    8000467a:	8082                	ret

000000008000467c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000467c:	de010113          	addi	sp,sp,-544
    80004680:	20113c23          	sd	ra,536(sp)
    80004684:	20813823          	sd	s0,528(sp)
    80004688:	20913423          	sd	s1,520(sp)
    8000468c:	21213023          	sd	s2,512(sp)
    80004690:	ffce                	sd	s3,504(sp)
    80004692:	fbd2                	sd	s4,496(sp)
    80004694:	f7d6                	sd	s5,488(sp)
    80004696:	f3da                	sd	s6,480(sp)
    80004698:	efde                	sd	s7,472(sp)
    8000469a:	ebe2                	sd	s8,464(sp)
    8000469c:	e7e6                	sd	s9,456(sp)
    8000469e:	e3ea                	sd	s10,448(sp)
    800046a0:	ff6e                	sd	s11,440(sp)
    800046a2:	1400                	addi	s0,sp,544
    800046a4:	892a                	mv	s2,a0
    800046a6:	dea43423          	sd	a0,-536(s0)
    800046aa:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800046ae:	96afd0ef          	jal	ra,80001818 <myproc>
    800046b2:	84aa                	mv	s1,a0

  begin_op();
    800046b4:	e0eff0ef          	jal	ra,80003cc2 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800046b8:	854a                	mv	a0,s2
    800046ba:	c18ff0ef          	jal	ra,80003ad2 <namei>
    800046be:	c13d                	beqz	a0,80004724 <kexec+0xa8>
    800046c0:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800046c2:	c23fe0ef          	jal	ra,800032e4 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800046c6:	04000713          	li	a4,64
    800046ca:	4681                	li	a3,0
    800046cc:	e5040613          	addi	a2,s0,-432
    800046d0:	4581                	li	a1,0
    800046d2:	8556                	mv	a0,s5
    800046d4:	f9dfe0ef          	jal	ra,80003670 <readi>
    800046d8:	04000793          	li	a5,64
    800046dc:	00f51a63          	bne	a0,a5,800046f0 <kexec+0x74>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800046e0:	e5042703          	lw	a4,-432(s0)
    800046e4:	464c47b7          	lui	a5,0x464c4
    800046e8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800046ec:	04f70063          	beq	a4,a5,8000472c <kexec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800046f0:	8556                	mv	a0,s5
    800046f2:	df9fe0ef          	jal	ra,800034ea <iunlockput>
    end_op();
    800046f6:	e3cff0ef          	jal	ra,80003d32 <end_op>
  }
  return -1;
    800046fa:	557d                	li	a0,-1
}
    800046fc:	21813083          	ld	ra,536(sp)
    80004700:	21013403          	ld	s0,528(sp)
    80004704:	20813483          	ld	s1,520(sp)
    80004708:	20013903          	ld	s2,512(sp)
    8000470c:	79fe                	ld	s3,504(sp)
    8000470e:	7a5e                	ld	s4,496(sp)
    80004710:	7abe                	ld	s5,488(sp)
    80004712:	7b1e                	ld	s6,480(sp)
    80004714:	6bfe                	ld	s7,472(sp)
    80004716:	6c5e                	ld	s8,464(sp)
    80004718:	6cbe                	ld	s9,456(sp)
    8000471a:	6d1e                	ld	s10,448(sp)
    8000471c:	7dfa                	ld	s11,440(sp)
    8000471e:	22010113          	addi	sp,sp,544
    80004722:	8082                	ret
    end_op();
    80004724:	e0eff0ef          	jal	ra,80003d32 <end_op>
    return -1;
    80004728:	557d                	li	a0,-1
    8000472a:	bfc9                	j	800046fc <kexec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    8000472c:	8526                	mv	a0,s1
    8000472e:	9f0fd0ef          	jal	ra,8000191e <proc_pagetable>
    80004732:	8b2a                	mv	s6,a0
    80004734:	dd55                	beqz	a0,800046f0 <kexec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004736:	e7042783          	lw	a5,-400(s0)
    8000473a:	e8845703          	lhu	a4,-376(s0)
    8000473e:	c325                	beqz	a4,8000479e <kexec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004740:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004742:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004746:	6a05                	lui	s4,0x1
    80004748:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000474c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004750:	6d85                	lui	s11,0x1
    80004752:	7d7d                	lui	s10,0xfffff
    80004754:	a411                	j	80004958 <kexec+0x2dc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004756:	00003517          	auipc	a0,0x3
    8000475a:	05a50513          	addi	a0,a0,90 # 800077b0 <syscalls+0x300>
    8000475e:	82cfc0ef          	jal	ra,8000078a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004762:	874a                	mv	a4,s2
    80004764:	009c86bb          	addw	a3,s9,s1
    80004768:	4581                	li	a1,0
    8000476a:	8556                	mv	a0,s5
    8000476c:	f05fe0ef          	jal	ra,80003670 <readi>
    80004770:	2501                	sext.w	a0,a0
    80004772:	18a91263          	bne	s2,a0,800048f6 <kexec+0x27a>
  for(i = 0; i < sz; i += PGSIZE){
    80004776:	009d84bb          	addw	s1,s11,s1
    8000477a:	013d09bb          	addw	s3,s10,s3
    8000477e:	1b74fd63          	bgeu	s1,s7,80004938 <kexec+0x2bc>
    pa = walkaddr(pagetable, va + i);
    80004782:	02049593          	slli	a1,s1,0x20
    80004786:	9181                	srli	a1,a1,0x20
    80004788:	95e2                	add	a1,a1,s8
    8000478a:	855a                	mv	a0,s6
    8000478c:	fcafc0ef          	jal	ra,80000f56 <walkaddr>
    80004790:	862a                	mv	a2,a0
    if(pa == 0)
    80004792:	d171                	beqz	a0,80004756 <kexec+0xda>
      n = PGSIZE;
    80004794:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004796:	fd49f6e3          	bgeu	s3,s4,80004762 <kexec+0xe6>
      n = sz - i;
    8000479a:	894e                	mv	s2,s3
    8000479c:	b7d9                	j	80004762 <kexec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000479e:	4901                	li	s2,0
  iunlockput(ip);
    800047a0:	8556                	mv	a0,s5
    800047a2:	d49fe0ef          	jal	ra,800034ea <iunlockput>
  end_op();
    800047a6:	d8cff0ef          	jal	ra,80003d32 <end_op>
  p = myproc();
    800047aa:	86efd0ef          	jal	ra,80001818 <myproc>
    800047ae:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800047b0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800047b4:	6785                	lui	a5,0x1
    800047b6:	17fd                	addi	a5,a5,-1
    800047b8:	993e                	add	s2,s2,a5
    800047ba:	77fd                	lui	a5,0xfffff
    800047bc:	00f977b3          	and	a5,s2,a5
    800047c0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800047c4:	4691                	li	a3,4
    800047c6:	6609                	lui	a2,0x2
    800047c8:	963e                	add	a2,a2,a5
    800047ca:	85be                	mv	a1,a5
    800047cc:	855a                	mv	a0,s6
    800047ce:	a53fc0ef          	jal	ra,80001220 <uvmalloc>
    800047d2:	8c2a                	mv	s8,a0
  ip = 0;
    800047d4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800047d6:	12050063          	beqz	a0,800048f6 <kexec+0x27a>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800047da:	75f9                	lui	a1,0xffffe
    800047dc:	95aa                	add	a1,a1,a0
    800047de:	855a                	mv	a0,s6
    800047e0:	c07fc0ef          	jal	ra,800013e6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800047e4:	7afd                	lui	s5,0xfffff
    800047e6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800047e8:	df043783          	ld	a5,-528(s0)
    800047ec:	6388                	ld	a0,0(a5)
    800047ee:	c135                	beqz	a0,80004852 <kexec+0x1d6>
    800047f0:	e9040993          	addi	s3,s0,-368
    800047f4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800047f8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800047fa:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800047fc:	dbcfc0ef          	jal	ra,80000db8 <strlen>
    80004800:	0015079b          	addiw	a5,a0,1
    80004804:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004808:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000480c:	11596a63          	bltu	s2,s5,80004920 <kexec+0x2a4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004810:	df043d83          	ld	s11,-528(s0)
    80004814:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004818:	8552                	mv	a0,s4
    8000481a:	d9efc0ef          	jal	ra,80000db8 <strlen>
    8000481e:	0015069b          	addiw	a3,a0,1
    80004822:	8652                	mv	a2,s4
    80004824:	85ca                	mv	a1,s2
    80004826:	855a                	mv	a0,s6
    80004828:	d2bfc0ef          	jal	ra,80001552 <copyout>
    8000482c:	0e054e63          	bltz	a0,80004928 <kexec+0x2ac>
    ustack[argc] = sp;
    80004830:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004834:	0485                	addi	s1,s1,1
    80004836:	008d8793          	addi	a5,s11,8
    8000483a:	def43823          	sd	a5,-528(s0)
    8000483e:	008db503          	ld	a0,8(s11)
    80004842:	c911                	beqz	a0,80004856 <kexec+0x1da>
    if(argc >= MAXARG)
    80004844:	09a1                	addi	s3,s3,8
    80004846:	fb3c9be3          	bne	s9,s3,800047fc <kexec+0x180>
  sz = sz1;
    8000484a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000484e:	4a81                	li	s5,0
    80004850:	a05d                	j	800048f6 <kexec+0x27a>
  sp = sz;
    80004852:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004854:	4481                	li	s1,0
  ustack[argc] = 0;
    80004856:	00349793          	slli	a5,s1,0x3
    8000485a:	f9040713          	addi	a4,s0,-112
    8000485e:	97ba                	add	a5,a5,a4
    80004860:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdde60>
  sp -= (argc+1) * sizeof(uint64);
    80004864:	00148693          	addi	a3,s1,1
    80004868:	068e                	slli	a3,a3,0x3
    8000486a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000486e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004872:	01597663          	bgeu	s2,s5,8000487e <kexec+0x202>
  sz = sz1;
    80004876:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000487a:	4a81                	li	s5,0
    8000487c:	a8ad                	j	800048f6 <kexec+0x27a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000487e:	e9040613          	addi	a2,s0,-368
    80004882:	85ca                	mv	a1,s2
    80004884:	855a                	mv	a0,s6
    80004886:	ccdfc0ef          	jal	ra,80001552 <copyout>
    8000488a:	0a054363          	bltz	a0,80004930 <kexec+0x2b4>
  p->trapframe->a1 = sp;
    8000488e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004892:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004896:	de843783          	ld	a5,-536(s0)
    8000489a:	0007c703          	lbu	a4,0(a5)
    8000489e:	cf11                	beqz	a4,800048ba <kexec+0x23e>
    800048a0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048a2:	02f00693          	li	a3,47
    800048a6:	a039                	j	800048b4 <kexec+0x238>
      last = s+1;
    800048a8:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800048ac:	0785                	addi	a5,a5,1
    800048ae:	fff7c703          	lbu	a4,-1(a5)
    800048b2:	c701                	beqz	a4,800048ba <kexec+0x23e>
    if(*s == '/')
    800048b4:	fed71ce3          	bne	a4,a3,800048ac <kexec+0x230>
    800048b8:	bfc5                	j	800048a8 <kexec+0x22c>
  safestrcpy(p->name, last, sizeof(p->name));
    800048ba:	4641                	li	a2,16
    800048bc:	de843583          	ld	a1,-536(s0)
    800048c0:	158b8513          	addi	a0,s7,344
    800048c4:	cc2fc0ef          	jal	ra,80000d86 <safestrcpy>
  oldpagetable = p->pagetable;
    800048c8:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800048cc:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800048d0:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800048d4:	058bb783          	ld	a5,88(s7)
    800048d8:	e6843703          	ld	a4,-408(s0)
    800048dc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800048de:	058bb783          	ld	a5,88(s7)
    800048e2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800048e6:	85ea                	mv	a1,s10
    800048e8:	8bafd0ef          	jal	ra,800019a2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800048ec:	0004851b          	sext.w	a0,s1
    800048f0:	b531                	j	800046fc <kexec+0x80>
    800048f2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800048f6:	df843583          	ld	a1,-520(s0)
    800048fa:	855a                	mv	a0,s6
    800048fc:	8a6fd0ef          	jal	ra,800019a2 <proc_freepagetable>
  if(ip){
    80004900:	de0a98e3          	bnez	s5,800046f0 <kexec+0x74>
  return -1;
    80004904:	557d                	li	a0,-1
    80004906:	bbdd                	j	800046fc <kexec+0x80>
    80004908:	df243c23          	sd	s2,-520(s0)
    8000490c:	b7ed                	j	800048f6 <kexec+0x27a>
    8000490e:	df243c23          	sd	s2,-520(s0)
    80004912:	b7d5                	j	800048f6 <kexec+0x27a>
    80004914:	df243c23          	sd	s2,-520(s0)
    80004918:	bff9                	j	800048f6 <kexec+0x27a>
    8000491a:	df243c23          	sd	s2,-520(s0)
    8000491e:	bfe1                	j	800048f6 <kexec+0x27a>
  sz = sz1;
    80004920:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004924:	4a81                	li	s5,0
    80004926:	bfc1                	j	800048f6 <kexec+0x27a>
  sz = sz1;
    80004928:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000492c:	4a81                	li	s5,0
    8000492e:	b7e1                	j	800048f6 <kexec+0x27a>
  sz = sz1;
    80004930:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004934:	4a81                	li	s5,0
    80004936:	b7c1                	j	800048f6 <kexec+0x27a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004938:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000493c:	e0843783          	ld	a5,-504(s0)
    80004940:	0017869b          	addiw	a3,a5,1
    80004944:	e0d43423          	sd	a3,-504(s0)
    80004948:	e0043783          	ld	a5,-512(s0)
    8000494c:	0387879b          	addiw	a5,a5,56
    80004950:	e8845703          	lhu	a4,-376(s0)
    80004954:	e4e6d6e3          	bge	a3,a4,800047a0 <kexec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004958:	2781                	sext.w	a5,a5
    8000495a:	e0f43023          	sd	a5,-512(s0)
    8000495e:	03800713          	li	a4,56
    80004962:	86be                	mv	a3,a5
    80004964:	e1840613          	addi	a2,s0,-488
    80004968:	4581                	li	a1,0
    8000496a:	8556                	mv	a0,s5
    8000496c:	d05fe0ef          	jal	ra,80003670 <readi>
    80004970:	03800793          	li	a5,56
    80004974:	f6f51fe3          	bne	a0,a5,800048f2 <kexec+0x276>
    if(ph.type != ELF_PROG_LOAD)
    80004978:	e1842783          	lw	a5,-488(s0)
    8000497c:	4705                	li	a4,1
    8000497e:	fae79fe3          	bne	a5,a4,8000493c <kexec+0x2c0>
    if(ph.memsz < ph.filesz)
    80004982:	e4043483          	ld	s1,-448(s0)
    80004986:	e3843783          	ld	a5,-456(s0)
    8000498a:	f6f4efe3          	bltu	s1,a5,80004908 <kexec+0x28c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000498e:	e2843783          	ld	a5,-472(s0)
    80004992:	94be                	add	s1,s1,a5
    80004994:	f6f4ede3          	bltu	s1,a5,8000490e <kexec+0x292>
    if(ph.vaddr % PGSIZE != 0)
    80004998:	de043703          	ld	a4,-544(s0)
    8000499c:	8ff9                	and	a5,a5,a4
    8000499e:	fbbd                	bnez	a5,80004914 <kexec+0x298>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049a0:	e1c42503          	lw	a0,-484(s0)
    800049a4:	cbdff0ef          	jal	ra,80004660 <flags2perm>
    800049a8:	86aa                	mv	a3,a0
    800049aa:	8626                	mv	a2,s1
    800049ac:	85ca                	mv	a1,s2
    800049ae:	855a                	mv	a0,s6
    800049b0:	871fc0ef          	jal	ra,80001220 <uvmalloc>
    800049b4:	dea43c23          	sd	a0,-520(s0)
    800049b8:	d12d                	beqz	a0,8000491a <kexec+0x29e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049ba:	e2843c03          	ld	s8,-472(s0)
    800049be:	e2042c83          	lw	s9,-480(s0)
    800049c2:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800049c6:	f60b89e3          	beqz	s7,80004938 <kexec+0x2bc>
    800049ca:	89de                	mv	s3,s7
    800049cc:	4481                	li	s1,0
    800049ce:	bb55                	j	80004782 <kexec+0x106>

00000000800049d0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800049d0:	7179                	addi	sp,sp,-48
    800049d2:	f406                	sd	ra,40(sp)
    800049d4:	f022                	sd	s0,32(sp)
    800049d6:	ec26                	sd	s1,24(sp)
    800049d8:	e84a                	sd	s2,16(sp)
    800049da:	1800                	addi	s0,sp,48
    800049dc:	892e                	mv	s2,a1
    800049de:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800049e0:	fdc40593          	addi	a1,s0,-36
    800049e4:	e9ffd0ef          	jal	ra,80002882 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800049e8:	fdc42703          	lw	a4,-36(s0)
    800049ec:	47bd                	li	a5,15
    800049ee:	02e7e963          	bltu	a5,a4,80004a20 <argfd+0x50>
    800049f2:	e27fc0ef          	jal	ra,80001818 <myproc>
    800049f6:	fdc42703          	lw	a4,-36(s0)
    800049fa:	01a70793          	addi	a5,a4,26
    800049fe:	078e                	slli	a5,a5,0x3
    80004a00:	953e                	add	a0,a0,a5
    80004a02:	611c                	ld	a5,0(a0)
    80004a04:	c385                	beqz	a5,80004a24 <argfd+0x54>
    return -1;
  if(pfd)
    80004a06:	00090463          	beqz	s2,80004a0e <argfd+0x3e>
    *pfd = fd;
    80004a0a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a0e:	4501                	li	a0,0
  if(pf)
    80004a10:	c091                	beqz	s1,80004a14 <argfd+0x44>
    *pf = f;
    80004a12:	e09c                	sd	a5,0(s1)
}
    80004a14:	70a2                	ld	ra,40(sp)
    80004a16:	7402                	ld	s0,32(sp)
    80004a18:	64e2                	ld	s1,24(sp)
    80004a1a:	6942                	ld	s2,16(sp)
    80004a1c:	6145                	addi	sp,sp,48
    80004a1e:	8082                	ret
    return -1;
    80004a20:	557d                	li	a0,-1
    80004a22:	bfcd                	j	80004a14 <argfd+0x44>
    80004a24:	557d                	li	a0,-1
    80004a26:	b7fd                	j	80004a14 <argfd+0x44>

0000000080004a28 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a28:	1101                	addi	sp,sp,-32
    80004a2a:	ec06                	sd	ra,24(sp)
    80004a2c:	e822                	sd	s0,16(sp)
    80004a2e:	e426                	sd	s1,8(sp)
    80004a30:	1000                	addi	s0,sp,32
    80004a32:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004a34:	de5fc0ef          	jal	ra,80001818 <myproc>
    80004a38:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004a3a:	0d050793          	addi	a5,a0,208
    80004a3e:	4501                	li	a0,0
    80004a40:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004a42:	6398                	ld	a4,0(a5)
    80004a44:	cb19                	beqz	a4,80004a5a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004a46:	2505                	addiw	a0,a0,1
    80004a48:	07a1                	addi	a5,a5,8
    80004a4a:	fed51ce3          	bne	a0,a3,80004a42 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004a4e:	557d                	li	a0,-1
}
    80004a50:	60e2                	ld	ra,24(sp)
    80004a52:	6442                	ld	s0,16(sp)
    80004a54:	64a2                	ld	s1,8(sp)
    80004a56:	6105                	addi	sp,sp,32
    80004a58:	8082                	ret
      p->ofile[fd] = f;
    80004a5a:	01a50793          	addi	a5,a0,26
    80004a5e:	078e                	slli	a5,a5,0x3
    80004a60:	963e                	add	a2,a2,a5
    80004a62:	e204                	sd	s1,0(a2)
      return fd;
    80004a64:	b7f5                	j	80004a50 <fdalloc+0x28>

0000000080004a66 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004a66:	715d                	addi	sp,sp,-80
    80004a68:	e486                	sd	ra,72(sp)
    80004a6a:	e0a2                	sd	s0,64(sp)
    80004a6c:	fc26                	sd	s1,56(sp)
    80004a6e:	f84a                	sd	s2,48(sp)
    80004a70:	f44e                	sd	s3,40(sp)
    80004a72:	f052                	sd	s4,32(sp)
    80004a74:	ec56                	sd	s5,24(sp)
    80004a76:	e85a                	sd	s6,16(sp)
    80004a78:	0880                	addi	s0,sp,80
    80004a7a:	8b2e                	mv	s6,a1
    80004a7c:	89b2                	mv	s3,a2
    80004a7e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a80:	fb040593          	addi	a1,s0,-80
    80004a84:	868ff0ef          	jal	ra,80003aec <nameiparent>
    80004a88:	84aa                	mv	s1,a0
    80004a8a:	10050b63          	beqz	a0,80004ba0 <create+0x13a>
    return 0;

  ilock(dp);
    80004a8e:	857fe0ef          	jal	ra,800032e4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a92:	4601                	li	a2,0
    80004a94:	fb040593          	addi	a1,s0,-80
    80004a98:	8526                	mv	a0,s1
    80004a9a:	dd3fe0ef          	jal	ra,8000386c <dirlookup>
    80004a9e:	8aaa                	mv	s5,a0
    80004aa0:	c521                	beqz	a0,80004ae8 <create+0x82>
    iunlockput(dp);
    80004aa2:	8526                	mv	a0,s1
    80004aa4:	a47fe0ef          	jal	ra,800034ea <iunlockput>
    ilock(ip);
    80004aa8:	8556                	mv	a0,s5
    80004aaa:	83bfe0ef          	jal	ra,800032e4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004aae:	000b059b          	sext.w	a1,s6
    80004ab2:	4789                	li	a5,2
    80004ab4:	02f59563          	bne	a1,a5,80004ade <create+0x78>
    80004ab8:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffddfa4>
    80004abc:	37f9                	addiw	a5,a5,-2
    80004abe:	17c2                	slli	a5,a5,0x30
    80004ac0:	93c1                	srli	a5,a5,0x30
    80004ac2:	4705                	li	a4,1
    80004ac4:	00f76d63          	bltu	a4,a5,80004ade <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ac8:	8556                	mv	a0,s5
    80004aca:	60a6                	ld	ra,72(sp)
    80004acc:	6406                	ld	s0,64(sp)
    80004ace:	74e2                	ld	s1,56(sp)
    80004ad0:	7942                	ld	s2,48(sp)
    80004ad2:	79a2                	ld	s3,40(sp)
    80004ad4:	7a02                	ld	s4,32(sp)
    80004ad6:	6ae2                	ld	s5,24(sp)
    80004ad8:	6b42                	ld	s6,16(sp)
    80004ada:	6161                	addi	sp,sp,80
    80004adc:	8082                	ret
    iunlockput(ip);
    80004ade:	8556                	mv	a0,s5
    80004ae0:	a0bfe0ef          	jal	ra,800034ea <iunlockput>
    return 0;
    80004ae4:	4a81                	li	s5,0
    80004ae6:	b7cd                	j	80004ac8 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004ae8:	85da                	mv	a1,s6
    80004aea:	4088                	lw	a0,0(s1)
    80004aec:	e90fe0ef          	jal	ra,8000317c <ialloc>
    80004af0:	8a2a                	mv	s4,a0
    80004af2:	cd1d                	beqz	a0,80004b30 <create+0xca>
  ilock(ip);
    80004af4:	ff0fe0ef          	jal	ra,800032e4 <ilock>
  ip->major = major;
    80004af8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004afc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b00:	4905                	li	s2,1
    80004b02:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b06:	8552                	mv	a0,s4
    80004b08:	f2afe0ef          	jal	ra,80003232 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b0c:	000b059b          	sext.w	a1,s6
    80004b10:	03258563          	beq	a1,s2,80004b3a <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b14:	004a2603          	lw	a2,4(s4)
    80004b18:	fb040593          	addi	a1,s0,-80
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	f1bfe0ef          	jal	ra,80003a38 <dirlink>
    80004b22:	06054363          	bltz	a0,80004b88 <create+0x122>
  iunlockput(dp);
    80004b26:	8526                	mv	a0,s1
    80004b28:	9c3fe0ef          	jal	ra,800034ea <iunlockput>
  return ip;
    80004b2c:	8ad2                	mv	s5,s4
    80004b2e:	bf69                	j	80004ac8 <create+0x62>
    iunlockput(dp);
    80004b30:	8526                	mv	a0,s1
    80004b32:	9b9fe0ef          	jal	ra,800034ea <iunlockput>
    return 0;
    80004b36:	8ad2                	mv	s5,s4
    80004b38:	bf41                	j	80004ac8 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004b3a:	004a2603          	lw	a2,4(s4)
    80004b3e:	00003597          	auipc	a1,0x3
    80004b42:	c9258593          	addi	a1,a1,-878 # 800077d0 <syscalls+0x320>
    80004b46:	8552                	mv	a0,s4
    80004b48:	ef1fe0ef          	jal	ra,80003a38 <dirlink>
    80004b4c:	02054e63          	bltz	a0,80004b88 <create+0x122>
    80004b50:	40d0                	lw	a2,4(s1)
    80004b52:	00003597          	auipc	a1,0x3
    80004b56:	c8658593          	addi	a1,a1,-890 # 800077d8 <syscalls+0x328>
    80004b5a:	8552                	mv	a0,s4
    80004b5c:	eddfe0ef          	jal	ra,80003a38 <dirlink>
    80004b60:	02054463          	bltz	a0,80004b88 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b64:	004a2603          	lw	a2,4(s4)
    80004b68:	fb040593          	addi	a1,s0,-80
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	ecbfe0ef          	jal	ra,80003a38 <dirlink>
    80004b72:	00054b63          	bltz	a0,80004b88 <create+0x122>
    dp->nlink++;  // for ".."
    80004b76:	04a4d783          	lhu	a5,74(s1)
    80004b7a:	2785                	addiw	a5,a5,1
    80004b7c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b80:	8526                	mv	a0,s1
    80004b82:	eb0fe0ef          	jal	ra,80003232 <iupdate>
    80004b86:	b745                	j	80004b26 <create+0xc0>
  ip->nlink = 0;
    80004b88:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b8c:	8552                	mv	a0,s4
    80004b8e:	ea4fe0ef          	jal	ra,80003232 <iupdate>
  iunlockput(ip);
    80004b92:	8552                	mv	a0,s4
    80004b94:	957fe0ef          	jal	ra,800034ea <iunlockput>
  iunlockput(dp);
    80004b98:	8526                	mv	a0,s1
    80004b9a:	951fe0ef          	jal	ra,800034ea <iunlockput>
  return 0;
    80004b9e:	b72d                	j	80004ac8 <create+0x62>
    return 0;
    80004ba0:	8aaa                	mv	s5,a0
    80004ba2:	b71d                	j	80004ac8 <create+0x62>

0000000080004ba4 <sys_dup>:
{
    80004ba4:	7179                	addi	sp,sp,-48
    80004ba6:	f406                	sd	ra,40(sp)
    80004ba8:	f022                	sd	s0,32(sp)
    80004baa:	ec26                	sd	s1,24(sp)
    80004bac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004bae:	fd840613          	addi	a2,s0,-40
    80004bb2:	4581                	li	a1,0
    80004bb4:	4501                	li	a0,0
    80004bb6:	e1bff0ef          	jal	ra,800049d0 <argfd>
    return -1;
    80004bba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004bbc:	00054f63          	bltz	a0,80004bda <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004bc0:	fd843503          	ld	a0,-40(s0)
    80004bc4:	e65ff0ef          	jal	ra,80004a28 <fdalloc>
    80004bc8:	84aa                	mv	s1,a0
    return -1;
    80004bca:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004bcc:	00054763          	bltz	a0,80004bda <sys_dup+0x36>
  filedup(f);
    80004bd0:	fd843503          	ld	a0,-40(s0)
    80004bd4:	cb6ff0ef          	jal	ra,8000408a <filedup>
  return fd;
    80004bd8:	87a6                	mv	a5,s1
}
    80004bda:	853e                	mv	a0,a5
    80004bdc:	70a2                	ld	ra,40(sp)
    80004bde:	7402                	ld	s0,32(sp)
    80004be0:	64e2                	ld	s1,24(sp)
    80004be2:	6145                	addi	sp,sp,48
    80004be4:	8082                	ret

0000000080004be6 <sys_read>:
{
    80004be6:	7179                	addi	sp,sp,-48
    80004be8:	f406                	sd	ra,40(sp)
    80004bea:	f022                	sd	s0,32(sp)
    80004bec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bee:	fd840593          	addi	a1,s0,-40
    80004bf2:	4505                	li	a0,1
    80004bf4:	cabfd0ef          	jal	ra,8000289e <argaddr>
  argint(2, &n);
    80004bf8:	fe440593          	addi	a1,s0,-28
    80004bfc:	4509                	li	a0,2
    80004bfe:	c85fd0ef          	jal	ra,80002882 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c02:	fe840613          	addi	a2,s0,-24
    80004c06:	4581                	li	a1,0
    80004c08:	4501                	li	a0,0
    80004c0a:	dc7ff0ef          	jal	ra,800049d0 <argfd>
    80004c0e:	87aa                	mv	a5,a0
    return -1;
    80004c10:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c12:	0007ca63          	bltz	a5,80004c26 <sys_read+0x40>
  return fileread(f, p, n);
    80004c16:	fe442603          	lw	a2,-28(s0)
    80004c1a:	fd843583          	ld	a1,-40(s0)
    80004c1e:	fe843503          	ld	a0,-24(s0)
    80004c22:	db4ff0ef          	jal	ra,800041d6 <fileread>
}
    80004c26:	70a2                	ld	ra,40(sp)
    80004c28:	7402                	ld	s0,32(sp)
    80004c2a:	6145                	addi	sp,sp,48
    80004c2c:	8082                	ret

0000000080004c2e <sys_write>:
{
    80004c2e:	7179                	addi	sp,sp,-48
    80004c30:	f406                	sd	ra,40(sp)
    80004c32:	f022                	sd	s0,32(sp)
    80004c34:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c36:	fd840593          	addi	a1,s0,-40
    80004c3a:	4505                	li	a0,1
    80004c3c:	c63fd0ef          	jal	ra,8000289e <argaddr>
  argint(2, &n);
    80004c40:	fe440593          	addi	a1,s0,-28
    80004c44:	4509                	li	a0,2
    80004c46:	c3dfd0ef          	jal	ra,80002882 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c4a:	fe840613          	addi	a2,s0,-24
    80004c4e:	4581                	li	a1,0
    80004c50:	4501                	li	a0,0
    80004c52:	d7fff0ef          	jal	ra,800049d0 <argfd>
    80004c56:	87aa                	mv	a5,a0
    return -1;
    80004c58:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c5a:	0007ca63          	bltz	a5,80004c6e <sys_write+0x40>
  return filewrite(f, p, n);
    80004c5e:	fe442603          	lw	a2,-28(s0)
    80004c62:	fd843583          	ld	a1,-40(s0)
    80004c66:	fe843503          	ld	a0,-24(s0)
    80004c6a:	e1aff0ef          	jal	ra,80004284 <filewrite>
}
    80004c6e:	70a2                	ld	ra,40(sp)
    80004c70:	7402                	ld	s0,32(sp)
    80004c72:	6145                	addi	sp,sp,48
    80004c74:	8082                	ret

0000000080004c76 <sys_close>:
{
    80004c76:	1101                	addi	sp,sp,-32
    80004c78:	ec06                	sd	ra,24(sp)
    80004c7a:	e822                	sd	s0,16(sp)
    80004c7c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c7e:	fe040613          	addi	a2,s0,-32
    80004c82:	fec40593          	addi	a1,s0,-20
    80004c86:	4501                	li	a0,0
    80004c88:	d49ff0ef          	jal	ra,800049d0 <argfd>
    return -1;
    80004c8c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c8e:	02054063          	bltz	a0,80004cae <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c92:	b87fc0ef          	jal	ra,80001818 <myproc>
    80004c96:	fec42783          	lw	a5,-20(s0)
    80004c9a:	07e9                	addi	a5,a5,26
    80004c9c:	078e                	slli	a5,a5,0x3
    80004c9e:	97aa                	add	a5,a5,a0
    80004ca0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004ca4:	fe043503          	ld	a0,-32(s0)
    80004ca8:	c28ff0ef          	jal	ra,800040d0 <fileclose>
  return 0;
    80004cac:	4781                	li	a5,0
}
    80004cae:	853e                	mv	a0,a5
    80004cb0:	60e2                	ld	ra,24(sp)
    80004cb2:	6442                	ld	s0,16(sp)
    80004cb4:	6105                	addi	sp,sp,32
    80004cb6:	8082                	ret

0000000080004cb8 <sys_fstat>:
{
    80004cb8:	1101                	addi	sp,sp,-32
    80004cba:	ec06                	sd	ra,24(sp)
    80004cbc:	e822                	sd	s0,16(sp)
    80004cbe:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004cc0:	fe040593          	addi	a1,s0,-32
    80004cc4:	4505                	li	a0,1
    80004cc6:	bd9fd0ef          	jal	ra,8000289e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004cca:	fe840613          	addi	a2,s0,-24
    80004cce:	4581                	li	a1,0
    80004cd0:	4501                	li	a0,0
    80004cd2:	cffff0ef          	jal	ra,800049d0 <argfd>
    80004cd6:	87aa                	mv	a5,a0
    return -1;
    80004cd8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cda:	0007c863          	bltz	a5,80004cea <sys_fstat+0x32>
  return filestat(f, st);
    80004cde:	fe043583          	ld	a1,-32(s0)
    80004ce2:	fe843503          	ld	a0,-24(s0)
    80004ce6:	c92ff0ef          	jal	ra,80004178 <filestat>
}
    80004cea:	60e2                	ld	ra,24(sp)
    80004cec:	6442                	ld	s0,16(sp)
    80004cee:	6105                	addi	sp,sp,32
    80004cf0:	8082                	ret

0000000080004cf2 <sys_link>:
{
    80004cf2:	7169                	addi	sp,sp,-304
    80004cf4:	f606                	sd	ra,296(sp)
    80004cf6:	f222                	sd	s0,288(sp)
    80004cf8:	ee26                	sd	s1,280(sp)
    80004cfa:	ea4a                	sd	s2,272(sp)
    80004cfc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cfe:	08000613          	li	a2,128
    80004d02:	ed040593          	addi	a1,s0,-304
    80004d06:	4501                	li	a0,0
    80004d08:	bb3fd0ef          	jal	ra,800028ba <argstr>
    return -1;
    80004d0c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d0e:	0c054663          	bltz	a0,80004dda <sys_link+0xe8>
    80004d12:	08000613          	li	a2,128
    80004d16:	f5040593          	addi	a1,s0,-176
    80004d1a:	4505                	li	a0,1
    80004d1c:	b9ffd0ef          	jal	ra,800028ba <argstr>
    return -1;
    80004d20:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d22:	0a054c63          	bltz	a0,80004dda <sys_link+0xe8>
  begin_op();
    80004d26:	f9dfe0ef          	jal	ra,80003cc2 <begin_op>
  if((ip = namei(old)) == 0){
    80004d2a:	ed040513          	addi	a0,s0,-304
    80004d2e:	da5fe0ef          	jal	ra,80003ad2 <namei>
    80004d32:	84aa                	mv	s1,a0
    80004d34:	c525                	beqz	a0,80004d9c <sys_link+0xaa>
  ilock(ip);
    80004d36:	daefe0ef          	jal	ra,800032e4 <ilock>
  if(ip->type == T_DIR){
    80004d3a:	04449703          	lh	a4,68(s1)
    80004d3e:	4785                	li	a5,1
    80004d40:	06f70263          	beq	a4,a5,80004da4 <sys_link+0xb2>
  ip->nlink++;
    80004d44:	04a4d783          	lhu	a5,74(s1)
    80004d48:	2785                	addiw	a5,a5,1
    80004d4a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d4e:	8526                	mv	a0,s1
    80004d50:	ce2fe0ef          	jal	ra,80003232 <iupdate>
  iunlock(ip);
    80004d54:	8526                	mv	a0,s1
    80004d56:	e38fe0ef          	jal	ra,8000338e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004d5a:	fd040593          	addi	a1,s0,-48
    80004d5e:	f5040513          	addi	a0,s0,-176
    80004d62:	d8bfe0ef          	jal	ra,80003aec <nameiparent>
    80004d66:	892a                	mv	s2,a0
    80004d68:	c921                	beqz	a0,80004db8 <sys_link+0xc6>
  ilock(dp);
    80004d6a:	d7afe0ef          	jal	ra,800032e4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004d6e:	00092703          	lw	a4,0(s2)
    80004d72:	409c                	lw	a5,0(s1)
    80004d74:	02f71f63          	bne	a4,a5,80004db2 <sys_link+0xc0>
    80004d78:	40d0                	lw	a2,4(s1)
    80004d7a:	fd040593          	addi	a1,s0,-48
    80004d7e:	854a                	mv	a0,s2
    80004d80:	cb9fe0ef          	jal	ra,80003a38 <dirlink>
    80004d84:	02054763          	bltz	a0,80004db2 <sys_link+0xc0>
  iunlockput(dp);
    80004d88:	854a                	mv	a0,s2
    80004d8a:	f60fe0ef          	jal	ra,800034ea <iunlockput>
  iput(ip);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	ed2fe0ef          	jal	ra,80003462 <iput>
  end_op();
    80004d94:	f9ffe0ef          	jal	ra,80003d32 <end_op>
  return 0;
    80004d98:	4781                	li	a5,0
    80004d9a:	a081                	j	80004dda <sys_link+0xe8>
    end_op();
    80004d9c:	f97fe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    80004da0:	57fd                	li	a5,-1
    80004da2:	a825                	j	80004dda <sys_link+0xe8>
    iunlockput(ip);
    80004da4:	8526                	mv	a0,s1
    80004da6:	f44fe0ef          	jal	ra,800034ea <iunlockput>
    end_op();
    80004daa:	f89fe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    80004dae:	57fd                	li	a5,-1
    80004db0:	a02d                	j	80004dda <sys_link+0xe8>
    iunlockput(dp);
    80004db2:	854a                	mv	a0,s2
    80004db4:	f36fe0ef          	jal	ra,800034ea <iunlockput>
  ilock(ip);
    80004db8:	8526                	mv	a0,s1
    80004dba:	d2afe0ef          	jal	ra,800032e4 <ilock>
  ip->nlink--;
    80004dbe:	04a4d783          	lhu	a5,74(s1)
    80004dc2:	37fd                	addiw	a5,a5,-1
    80004dc4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dc8:	8526                	mv	a0,s1
    80004dca:	c68fe0ef          	jal	ra,80003232 <iupdate>
  iunlockput(ip);
    80004dce:	8526                	mv	a0,s1
    80004dd0:	f1afe0ef          	jal	ra,800034ea <iunlockput>
  end_op();
    80004dd4:	f5ffe0ef          	jal	ra,80003d32 <end_op>
  return -1;
    80004dd8:	57fd                	li	a5,-1
}
    80004dda:	853e                	mv	a0,a5
    80004ddc:	70b2                	ld	ra,296(sp)
    80004dde:	7412                	ld	s0,288(sp)
    80004de0:	64f2                	ld	s1,280(sp)
    80004de2:	6952                	ld	s2,272(sp)
    80004de4:	6155                	addi	sp,sp,304
    80004de6:	8082                	ret

0000000080004de8 <sys_unlink>:
{
    80004de8:	7151                	addi	sp,sp,-240
    80004dea:	f586                	sd	ra,232(sp)
    80004dec:	f1a2                	sd	s0,224(sp)
    80004dee:	eda6                	sd	s1,216(sp)
    80004df0:	e9ca                	sd	s2,208(sp)
    80004df2:	e5ce                	sd	s3,200(sp)
    80004df4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004df6:	08000613          	li	a2,128
    80004dfa:	f3040593          	addi	a1,s0,-208
    80004dfe:	4501                	li	a0,0
    80004e00:	abbfd0ef          	jal	ra,800028ba <argstr>
    80004e04:	12054b63          	bltz	a0,80004f3a <sys_unlink+0x152>
  begin_op();
    80004e08:	ebbfe0ef          	jal	ra,80003cc2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e0c:	fb040593          	addi	a1,s0,-80
    80004e10:	f3040513          	addi	a0,s0,-208
    80004e14:	cd9fe0ef          	jal	ra,80003aec <nameiparent>
    80004e18:	84aa                	mv	s1,a0
    80004e1a:	c54d                	beqz	a0,80004ec4 <sys_unlink+0xdc>
  ilock(dp);
    80004e1c:	cc8fe0ef          	jal	ra,800032e4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e20:	00003597          	auipc	a1,0x3
    80004e24:	9b058593          	addi	a1,a1,-1616 # 800077d0 <syscalls+0x320>
    80004e28:	fb040513          	addi	a0,s0,-80
    80004e2c:	a2bfe0ef          	jal	ra,80003856 <namecmp>
    80004e30:	10050a63          	beqz	a0,80004f44 <sys_unlink+0x15c>
    80004e34:	00003597          	auipc	a1,0x3
    80004e38:	9a458593          	addi	a1,a1,-1628 # 800077d8 <syscalls+0x328>
    80004e3c:	fb040513          	addi	a0,s0,-80
    80004e40:	a17fe0ef          	jal	ra,80003856 <namecmp>
    80004e44:	10050063          	beqz	a0,80004f44 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004e48:	f2c40613          	addi	a2,s0,-212
    80004e4c:	fb040593          	addi	a1,s0,-80
    80004e50:	8526                	mv	a0,s1
    80004e52:	a1bfe0ef          	jal	ra,8000386c <dirlookup>
    80004e56:	892a                	mv	s2,a0
    80004e58:	0e050663          	beqz	a0,80004f44 <sys_unlink+0x15c>
  ilock(ip);
    80004e5c:	c88fe0ef          	jal	ra,800032e4 <ilock>
  if(ip->nlink < 1)
    80004e60:	04a91783          	lh	a5,74(s2)
    80004e64:	06f05463          	blez	a5,80004ecc <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004e68:	04491703          	lh	a4,68(s2)
    80004e6c:	4785                	li	a5,1
    80004e6e:	06f70563          	beq	a4,a5,80004ed8 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004e72:	4641                	li	a2,16
    80004e74:	4581                	li	a1,0
    80004e76:	fc040513          	addi	a0,s0,-64
    80004e7a:	dc7fb0ef          	jal	ra,80000c40 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e7e:	4741                	li	a4,16
    80004e80:	f2c42683          	lw	a3,-212(s0)
    80004e84:	fc040613          	addi	a2,s0,-64
    80004e88:	4581                	li	a1,0
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	8c9fe0ef          	jal	ra,80003754 <writei>
    80004e90:	47c1                	li	a5,16
    80004e92:	08f51563          	bne	a0,a5,80004f1c <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004e96:	04491703          	lh	a4,68(s2)
    80004e9a:	4785                	li	a5,1
    80004e9c:	08f70663          	beq	a4,a5,80004f28 <sys_unlink+0x140>
  iunlockput(dp);
    80004ea0:	8526                	mv	a0,s1
    80004ea2:	e48fe0ef          	jal	ra,800034ea <iunlockput>
  ip->nlink--;
    80004ea6:	04a95783          	lhu	a5,74(s2)
    80004eaa:	37fd                	addiw	a5,a5,-1
    80004eac:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004eb0:	854a                	mv	a0,s2
    80004eb2:	b80fe0ef          	jal	ra,80003232 <iupdate>
  iunlockput(ip);
    80004eb6:	854a                	mv	a0,s2
    80004eb8:	e32fe0ef          	jal	ra,800034ea <iunlockput>
  end_op();
    80004ebc:	e77fe0ef          	jal	ra,80003d32 <end_op>
  return 0;
    80004ec0:	4501                	li	a0,0
    80004ec2:	a079                	j	80004f50 <sys_unlink+0x168>
    end_op();
    80004ec4:	e6ffe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    80004ec8:	557d                	li	a0,-1
    80004eca:	a059                	j	80004f50 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004ecc:	00003517          	auipc	a0,0x3
    80004ed0:	91450513          	addi	a0,a0,-1772 # 800077e0 <syscalls+0x330>
    80004ed4:	8b7fb0ef          	jal	ra,8000078a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ed8:	04c92703          	lw	a4,76(s2)
    80004edc:	02000793          	li	a5,32
    80004ee0:	f8e7f9e3          	bgeu	a5,a4,80004e72 <sys_unlink+0x8a>
    80004ee4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ee8:	4741                	li	a4,16
    80004eea:	86ce                	mv	a3,s3
    80004eec:	f1840613          	addi	a2,s0,-232
    80004ef0:	4581                	li	a1,0
    80004ef2:	854a                	mv	a0,s2
    80004ef4:	f7cfe0ef          	jal	ra,80003670 <readi>
    80004ef8:	47c1                	li	a5,16
    80004efa:	00f51b63          	bne	a0,a5,80004f10 <sys_unlink+0x128>
    if(de.inum != 0)
    80004efe:	f1845783          	lhu	a5,-232(s0)
    80004f02:	ef95                	bnez	a5,80004f3e <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f04:	29c1                	addiw	s3,s3,16
    80004f06:	04c92783          	lw	a5,76(s2)
    80004f0a:	fcf9efe3          	bltu	s3,a5,80004ee8 <sys_unlink+0x100>
    80004f0e:	b795                	j	80004e72 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004f10:	00003517          	auipc	a0,0x3
    80004f14:	8e850513          	addi	a0,a0,-1816 # 800077f8 <syscalls+0x348>
    80004f18:	873fb0ef          	jal	ra,8000078a <panic>
    panic("unlink: writei");
    80004f1c:	00003517          	auipc	a0,0x3
    80004f20:	8f450513          	addi	a0,a0,-1804 # 80007810 <syscalls+0x360>
    80004f24:	867fb0ef          	jal	ra,8000078a <panic>
    dp->nlink--;
    80004f28:	04a4d783          	lhu	a5,74(s1)
    80004f2c:	37fd                	addiw	a5,a5,-1
    80004f2e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f32:	8526                	mv	a0,s1
    80004f34:	afefe0ef          	jal	ra,80003232 <iupdate>
    80004f38:	b7a5                	j	80004ea0 <sys_unlink+0xb8>
    return -1;
    80004f3a:	557d                	li	a0,-1
    80004f3c:	a811                	j	80004f50 <sys_unlink+0x168>
    iunlockput(ip);
    80004f3e:	854a                	mv	a0,s2
    80004f40:	daafe0ef          	jal	ra,800034ea <iunlockput>
  iunlockput(dp);
    80004f44:	8526                	mv	a0,s1
    80004f46:	da4fe0ef          	jal	ra,800034ea <iunlockput>
  end_op();
    80004f4a:	de9fe0ef          	jal	ra,80003d32 <end_op>
  return -1;
    80004f4e:	557d                	li	a0,-1
}
    80004f50:	70ae                	ld	ra,232(sp)
    80004f52:	740e                	ld	s0,224(sp)
    80004f54:	64ee                	ld	s1,216(sp)
    80004f56:	694e                	ld	s2,208(sp)
    80004f58:	69ae                	ld	s3,200(sp)
    80004f5a:	616d                	addi	sp,sp,240
    80004f5c:	8082                	ret

0000000080004f5e <sys_open>:

uint64
sys_open(void)
{
    80004f5e:	7131                	addi	sp,sp,-192
    80004f60:	fd06                	sd	ra,184(sp)
    80004f62:	f922                	sd	s0,176(sp)
    80004f64:	f526                	sd	s1,168(sp)
    80004f66:	f14a                	sd	s2,160(sp)
    80004f68:	ed4e                	sd	s3,152(sp)
    80004f6a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f6c:	f4c40593          	addi	a1,s0,-180
    80004f70:	4505                	li	a0,1
    80004f72:	911fd0ef          	jal	ra,80002882 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f76:	08000613          	li	a2,128
    80004f7a:	f5040593          	addi	a1,s0,-176
    80004f7e:	4501                	li	a0,0
    80004f80:	93bfd0ef          	jal	ra,800028ba <argstr>
    80004f84:	87aa                	mv	a5,a0
    return -1;
    80004f86:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f88:	0807cd63          	bltz	a5,80005022 <sys_open+0xc4>

  begin_op();
    80004f8c:	d37fe0ef          	jal	ra,80003cc2 <begin_op>

  if(omode & O_CREATE){
    80004f90:	f4c42783          	lw	a5,-180(s0)
    80004f94:	2007f793          	andi	a5,a5,512
    80004f98:	c3c5                	beqz	a5,80005038 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004f9a:	4681                	li	a3,0
    80004f9c:	4601                	li	a2,0
    80004f9e:	4589                	li	a1,2
    80004fa0:	f5040513          	addi	a0,s0,-176
    80004fa4:	ac3ff0ef          	jal	ra,80004a66 <create>
    80004fa8:	84aa                	mv	s1,a0
    if(ip == 0){
    80004faa:	c159                	beqz	a0,80005030 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004fac:	04449703          	lh	a4,68(s1)
    80004fb0:	478d                	li	a5,3
    80004fb2:	00f71763          	bne	a4,a5,80004fc0 <sys_open+0x62>
    80004fb6:	0464d703          	lhu	a4,70(s1)
    80004fba:	47a5                	li	a5,9
    80004fbc:	0ae7e963          	bltu	a5,a4,8000506e <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004fc0:	86cff0ef          	jal	ra,8000402c <filealloc>
    80004fc4:	89aa                	mv	s3,a0
    80004fc6:	0c050963          	beqz	a0,80005098 <sys_open+0x13a>
    80004fca:	a5fff0ef          	jal	ra,80004a28 <fdalloc>
    80004fce:	892a                	mv	s2,a0
    80004fd0:	0c054163          	bltz	a0,80005092 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004fd4:	04449703          	lh	a4,68(s1)
    80004fd8:	478d                	li	a5,3
    80004fda:	0af70163          	beq	a4,a5,8000507c <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004fde:	4789                	li	a5,2
    80004fe0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004fe4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004fe8:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004fec:	f4c42783          	lw	a5,-180(s0)
    80004ff0:	0017c713          	xori	a4,a5,1
    80004ff4:	8b05                	andi	a4,a4,1
    80004ff6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004ffa:	0037f713          	andi	a4,a5,3
    80004ffe:	00e03733          	snez	a4,a4
    80005002:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005006:	4007f793          	andi	a5,a5,1024
    8000500a:	c791                	beqz	a5,80005016 <sys_open+0xb8>
    8000500c:	04449703          	lh	a4,68(s1)
    80005010:	4789                	li	a5,2
    80005012:	06f70c63          	beq	a4,a5,8000508a <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80005016:	8526                	mv	a0,s1
    80005018:	b76fe0ef          	jal	ra,8000338e <iunlock>
  end_op();
    8000501c:	d17fe0ef          	jal	ra,80003d32 <end_op>

  return fd;
    80005020:	854a                	mv	a0,s2
}
    80005022:	70ea                	ld	ra,184(sp)
    80005024:	744a                	ld	s0,176(sp)
    80005026:	74aa                	ld	s1,168(sp)
    80005028:	790a                	ld	s2,160(sp)
    8000502a:	69ea                	ld	s3,152(sp)
    8000502c:	6129                	addi	sp,sp,192
    8000502e:	8082                	ret
      end_op();
    80005030:	d03fe0ef          	jal	ra,80003d32 <end_op>
      return -1;
    80005034:	557d                	li	a0,-1
    80005036:	b7f5                	j	80005022 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80005038:	f5040513          	addi	a0,s0,-176
    8000503c:	a97fe0ef          	jal	ra,80003ad2 <namei>
    80005040:	84aa                	mv	s1,a0
    80005042:	c115                	beqz	a0,80005066 <sys_open+0x108>
    ilock(ip);
    80005044:	aa0fe0ef          	jal	ra,800032e4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005048:	04449703          	lh	a4,68(s1)
    8000504c:	4785                	li	a5,1
    8000504e:	f4f71fe3          	bne	a4,a5,80004fac <sys_open+0x4e>
    80005052:	f4c42783          	lw	a5,-180(s0)
    80005056:	d7ad                	beqz	a5,80004fc0 <sys_open+0x62>
      iunlockput(ip);
    80005058:	8526                	mv	a0,s1
    8000505a:	c90fe0ef          	jal	ra,800034ea <iunlockput>
      end_op();
    8000505e:	cd5fe0ef          	jal	ra,80003d32 <end_op>
      return -1;
    80005062:	557d                	li	a0,-1
    80005064:	bf7d                	j	80005022 <sys_open+0xc4>
      end_op();
    80005066:	ccdfe0ef          	jal	ra,80003d32 <end_op>
      return -1;
    8000506a:	557d                	li	a0,-1
    8000506c:	bf5d                	j	80005022 <sys_open+0xc4>
    iunlockput(ip);
    8000506e:	8526                	mv	a0,s1
    80005070:	c7afe0ef          	jal	ra,800034ea <iunlockput>
    end_op();
    80005074:	cbffe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    80005078:	557d                	li	a0,-1
    8000507a:	b765                	j	80005022 <sys_open+0xc4>
    f->type = FD_DEVICE;
    8000507c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005080:	04649783          	lh	a5,70(s1)
    80005084:	02f99223          	sh	a5,36(s3)
    80005088:	b785                	j	80004fe8 <sys_open+0x8a>
    itrunc(ip);
    8000508a:	8526                	mv	a0,s1
    8000508c:	b42fe0ef          	jal	ra,800033ce <itrunc>
    80005090:	b759                	j	80005016 <sys_open+0xb8>
      fileclose(f);
    80005092:	854e                	mv	a0,s3
    80005094:	83cff0ef          	jal	ra,800040d0 <fileclose>
    iunlockput(ip);
    80005098:	8526                	mv	a0,s1
    8000509a:	c50fe0ef          	jal	ra,800034ea <iunlockput>
    end_op();
    8000509e:	c95fe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    800050a2:	557d                	li	a0,-1
    800050a4:	bfbd                	j	80005022 <sys_open+0xc4>

00000000800050a6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800050a6:	7175                	addi	sp,sp,-144
    800050a8:	e506                	sd	ra,136(sp)
    800050aa:	e122                	sd	s0,128(sp)
    800050ac:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800050ae:	c15fe0ef          	jal	ra,80003cc2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800050b2:	08000613          	li	a2,128
    800050b6:	f7040593          	addi	a1,s0,-144
    800050ba:	4501                	li	a0,0
    800050bc:	ffefd0ef          	jal	ra,800028ba <argstr>
    800050c0:	02054363          	bltz	a0,800050e6 <sys_mkdir+0x40>
    800050c4:	4681                	li	a3,0
    800050c6:	4601                	li	a2,0
    800050c8:	4585                	li	a1,1
    800050ca:	f7040513          	addi	a0,s0,-144
    800050ce:	999ff0ef          	jal	ra,80004a66 <create>
    800050d2:	c911                	beqz	a0,800050e6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050d4:	c16fe0ef          	jal	ra,800034ea <iunlockput>
  end_op();
    800050d8:	c5bfe0ef          	jal	ra,80003d32 <end_op>
  return 0;
    800050dc:	4501                	li	a0,0
}
    800050de:	60aa                	ld	ra,136(sp)
    800050e0:	640a                	ld	s0,128(sp)
    800050e2:	6149                	addi	sp,sp,144
    800050e4:	8082                	ret
    end_op();
    800050e6:	c4dfe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    800050ea:	557d                	li	a0,-1
    800050ec:	bfcd                	j	800050de <sys_mkdir+0x38>

00000000800050ee <sys_mknod>:

uint64
sys_mknod(void)
{
    800050ee:	7135                	addi	sp,sp,-160
    800050f0:	ed06                	sd	ra,152(sp)
    800050f2:	e922                	sd	s0,144(sp)
    800050f4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050f6:	bcdfe0ef          	jal	ra,80003cc2 <begin_op>
  argint(1, &major);
    800050fa:	f6c40593          	addi	a1,s0,-148
    800050fe:	4505                	li	a0,1
    80005100:	f82fd0ef          	jal	ra,80002882 <argint>
  argint(2, &minor);
    80005104:	f6840593          	addi	a1,s0,-152
    80005108:	4509                	li	a0,2
    8000510a:	f78fd0ef          	jal	ra,80002882 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000510e:	08000613          	li	a2,128
    80005112:	f7040593          	addi	a1,s0,-144
    80005116:	4501                	li	a0,0
    80005118:	fa2fd0ef          	jal	ra,800028ba <argstr>
    8000511c:	02054563          	bltz	a0,80005146 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005120:	f6841683          	lh	a3,-152(s0)
    80005124:	f6c41603          	lh	a2,-148(s0)
    80005128:	458d                	li	a1,3
    8000512a:	f7040513          	addi	a0,s0,-144
    8000512e:	939ff0ef          	jal	ra,80004a66 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005132:	c911                	beqz	a0,80005146 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005134:	bb6fe0ef          	jal	ra,800034ea <iunlockput>
  end_op();
    80005138:	bfbfe0ef          	jal	ra,80003d32 <end_op>
  return 0;
    8000513c:	4501                	li	a0,0
}
    8000513e:	60ea                	ld	ra,152(sp)
    80005140:	644a                	ld	s0,144(sp)
    80005142:	610d                	addi	sp,sp,160
    80005144:	8082                	ret
    end_op();
    80005146:	bedfe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    8000514a:	557d                	li	a0,-1
    8000514c:	bfcd                	j	8000513e <sys_mknod+0x50>

000000008000514e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000514e:	7135                	addi	sp,sp,-160
    80005150:	ed06                	sd	ra,152(sp)
    80005152:	e922                	sd	s0,144(sp)
    80005154:	e526                	sd	s1,136(sp)
    80005156:	e14a                	sd	s2,128(sp)
    80005158:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000515a:	ebefc0ef          	jal	ra,80001818 <myproc>
    8000515e:	892a                	mv	s2,a0
  
  begin_op();
    80005160:	b63fe0ef          	jal	ra,80003cc2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005164:	08000613          	li	a2,128
    80005168:	f6040593          	addi	a1,s0,-160
    8000516c:	4501                	li	a0,0
    8000516e:	f4cfd0ef          	jal	ra,800028ba <argstr>
    80005172:	04054163          	bltz	a0,800051b4 <sys_chdir+0x66>
    80005176:	f6040513          	addi	a0,s0,-160
    8000517a:	959fe0ef          	jal	ra,80003ad2 <namei>
    8000517e:	84aa                	mv	s1,a0
    80005180:	c915                	beqz	a0,800051b4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005182:	962fe0ef          	jal	ra,800032e4 <ilock>
  if(ip->type != T_DIR){
    80005186:	04449703          	lh	a4,68(s1)
    8000518a:	4785                	li	a5,1
    8000518c:	02f71863          	bne	a4,a5,800051bc <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005190:	8526                	mv	a0,s1
    80005192:	9fcfe0ef          	jal	ra,8000338e <iunlock>
  iput(p->cwd);
    80005196:	15093503          	ld	a0,336(s2)
    8000519a:	ac8fe0ef          	jal	ra,80003462 <iput>
  end_op();
    8000519e:	b95fe0ef          	jal	ra,80003d32 <end_op>
  p->cwd = ip;
    800051a2:	14993823          	sd	s1,336(s2)
  return 0;
    800051a6:	4501                	li	a0,0
}
    800051a8:	60ea                	ld	ra,152(sp)
    800051aa:	644a                	ld	s0,144(sp)
    800051ac:	64aa                	ld	s1,136(sp)
    800051ae:	690a                	ld	s2,128(sp)
    800051b0:	610d                	addi	sp,sp,160
    800051b2:	8082                	ret
    end_op();
    800051b4:	b7ffe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    800051b8:	557d                	li	a0,-1
    800051ba:	b7fd                	j	800051a8 <sys_chdir+0x5a>
    iunlockput(ip);
    800051bc:	8526                	mv	a0,s1
    800051be:	b2cfe0ef          	jal	ra,800034ea <iunlockput>
    end_op();
    800051c2:	b71fe0ef          	jal	ra,80003d32 <end_op>
    return -1;
    800051c6:	557d                	li	a0,-1
    800051c8:	b7c5                	j	800051a8 <sys_chdir+0x5a>

00000000800051ca <sys_exec>:

uint64
sys_exec(void)
{
    800051ca:	7145                	addi	sp,sp,-464
    800051cc:	e786                	sd	ra,456(sp)
    800051ce:	e3a2                	sd	s0,448(sp)
    800051d0:	ff26                	sd	s1,440(sp)
    800051d2:	fb4a                	sd	s2,432(sp)
    800051d4:	f74e                	sd	s3,424(sp)
    800051d6:	f352                	sd	s4,416(sp)
    800051d8:	ef56                	sd	s5,408(sp)
    800051da:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800051dc:	e3840593          	addi	a1,s0,-456
    800051e0:	4505                	li	a0,1
    800051e2:	ebcfd0ef          	jal	ra,8000289e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800051e6:	08000613          	li	a2,128
    800051ea:	f4040593          	addi	a1,s0,-192
    800051ee:	4501                	li	a0,0
    800051f0:	ecafd0ef          	jal	ra,800028ba <argstr>
    800051f4:	87aa                	mv	a5,a0
    return -1;
    800051f6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800051f8:	0a07c463          	bltz	a5,800052a0 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    800051fc:	10000613          	li	a2,256
    80005200:	4581                	li	a1,0
    80005202:	e4040513          	addi	a0,s0,-448
    80005206:	a3bfb0ef          	jal	ra,80000c40 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000520a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000520e:	89a6                	mv	s3,s1
    80005210:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005212:	02000a13          	li	s4,32
    80005216:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000521a:	00391793          	slli	a5,s2,0x3
    8000521e:	e3040593          	addi	a1,s0,-464
    80005222:	e3843503          	ld	a0,-456(s0)
    80005226:	953e                	add	a0,a0,a5
    80005228:	dd0fd0ef          	jal	ra,800027f8 <fetchaddr>
    8000522c:	02054663          	bltz	a0,80005258 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80005230:	e3043783          	ld	a5,-464(s0)
    80005234:	cf8d                	beqz	a5,8000526e <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005236:	867fb0ef          	jal	ra,80000a9c <kalloc>
    8000523a:	85aa                	mv	a1,a0
    8000523c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005240:	cd01                	beqz	a0,80005258 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005242:	6605                	lui	a2,0x1
    80005244:	e3043503          	ld	a0,-464(s0)
    80005248:	dfafd0ef          	jal	ra,80002842 <fetchstr>
    8000524c:	00054663          	bltz	a0,80005258 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80005250:	0905                	addi	s2,s2,1
    80005252:	09a1                	addi	s3,s3,8
    80005254:	fd4911e3          	bne	s2,s4,80005216 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005258:	10048913          	addi	s2,s1,256
    8000525c:	6088                	ld	a0,0(s1)
    8000525e:	c121                	beqz	a0,8000529e <sys_exec+0xd4>
    kfree(argv[i]);
    80005260:	f5cfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005264:	04a1                	addi	s1,s1,8
    80005266:	ff249be3          	bne	s1,s2,8000525c <sys_exec+0x92>
  return -1;
    8000526a:	557d                	li	a0,-1
    8000526c:	a815                	j	800052a0 <sys_exec+0xd6>
      argv[i] = 0;
    8000526e:	0a8e                	slli	s5,s5,0x3
    80005270:	fc040793          	addi	a5,s0,-64
    80005274:	9abe                	add	s5,s5,a5
    80005276:	e80ab023          	sd	zero,-384(s5)
  int ret = kexec(path, argv);
    8000527a:	e4040593          	addi	a1,s0,-448
    8000527e:	f4040513          	addi	a0,s0,-192
    80005282:	bfaff0ef          	jal	ra,8000467c <kexec>
    80005286:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005288:	10048993          	addi	s3,s1,256
    8000528c:	6088                	ld	a0,0(s1)
    8000528e:	c511                	beqz	a0,8000529a <sys_exec+0xd0>
    kfree(argv[i]);
    80005290:	f2cfb0ef          	jal	ra,800009bc <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005294:	04a1                	addi	s1,s1,8
    80005296:	ff349be3          	bne	s1,s3,8000528c <sys_exec+0xc2>
  return ret;
    8000529a:	854a                	mv	a0,s2
    8000529c:	a011                	j	800052a0 <sys_exec+0xd6>
  return -1;
    8000529e:	557d                	li	a0,-1
}
    800052a0:	60be                	ld	ra,456(sp)
    800052a2:	641e                	ld	s0,448(sp)
    800052a4:	74fa                	ld	s1,440(sp)
    800052a6:	795a                	ld	s2,432(sp)
    800052a8:	79ba                	ld	s3,424(sp)
    800052aa:	7a1a                	ld	s4,416(sp)
    800052ac:	6afa                	ld	s5,408(sp)
    800052ae:	6179                	addi	sp,sp,464
    800052b0:	8082                	ret

00000000800052b2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800052b2:	7139                	addi	sp,sp,-64
    800052b4:	fc06                	sd	ra,56(sp)
    800052b6:	f822                	sd	s0,48(sp)
    800052b8:	f426                	sd	s1,40(sp)
    800052ba:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052bc:	d5cfc0ef          	jal	ra,80001818 <myproc>
    800052c0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052c2:	fd840593          	addi	a1,s0,-40
    800052c6:	4501                	li	a0,0
    800052c8:	dd6fd0ef          	jal	ra,8000289e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800052cc:	fc840593          	addi	a1,s0,-56
    800052d0:	fd040513          	addi	a0,s0,-48
    800052d4:	8c8ff0ef          	jal	ra,8000439c <pipealloc>
    return -1;
    800052d8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800052da:	0a054463          	bltz	a0,80005382 <sys_pipe+0xd0>
  fd0 = -1;
    800052de:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800052e2:	fd043503          	ld	a0,-48(s0)
    800052e6:	f42ff0ef          	jal	ra,80004a28 <fdalloc>
    800052ea:	fca42223          	sw	a0,-60(s0)
    800052ee:	08054163          	bltz	a0,80005370 <sys_pipe+0xbe>
    800052f2:	fc843503          	ld	a0,-56(s0)
    800052f6:	f32ff0ef          	jal	ra,80004a28 <fdalloc>
    800052fa:	fca42023          	sw	a0,-64(s0)
    800052fe:	06054063          	bltz	a0,8000535e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005302:	4691                	li	a3,4
    80005304:	fc440613          	addi	a2,s0,-60
    80005308:	fd843583          	ld	a1,-40(s0)
    8000530c:	68a8                	ld	a0,80(s1)
    8000530e:	a44fc0ef          	jal	ra,80001552 <copyout>
    80005312:	00054e63          	bltz	a0,8000532e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005316:	4691                	li	a3,4
    80005318:	fc040613          	addi	a2,s0,-64
    8000531c:	fd843583          	ld	a1,-40(s0)
    80005320:	0591                	addi	a1,a1,4
    80005322:	68a8                	ld	a0,80(s1)
    80005324:	a2efc0ef          	jal	ra,80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005328:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000532a:	04055c63          	bgez	a0,80005382 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000532e:	fc442783          	lw	a5,-60(s0)
    80005332:	07e9                	addi	a5,a5,26
    80005334:	078e                	slli	a5,a5,0x3
    80005336:	97a6                	add	a5,a5,s1
    80005338:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000533c:	fc042503          	lw	a0,-64(s0)
    80005340:	0569                	addi	a0,a0,26
    80005342:	050e                	slli	a0,a0,0x3
    80005344:	94aa                	add	s1,s1,a0
    80005346:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000534a:	fd043503          	ld	a0,-48(s0)
    8000534e:	d83fe0ef          	jal	ra,800040d0 <fileclose>
    fileclose(wf);
    80005352:	fc843503          	ld	a0,-56(s0)
    80005356:	d7bfe0ef          	jal	ra,800040d0 <fileclose>
    return -1;
    8000535a:	57fd                	li	a5,-1
    8000535c:	a01d                	j	80005382 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000535e:	fc442783          	lw	a5,-60(s0)
    80005362:	0007c763          	bltz	a5,80005370 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005366:	07e9                	addi	a5,a5,26
    80005368:	078e                	slli	a5,a5,0x3
    8000536a:	94be                	add	s1,s1,a5
    8000536c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005370:	fd043503          	ld	a0,-48(s0)
    80005374:	d5dfe0ef          	jal	ra,800040d0 <fileclose>
    fileclose(wf);
    80005378:	fc843503          	ld	a0,-56(s0)
    8000537c:	d55fe0ef          	jal	ra,800040d0 <fileclose>
    return -1;
    80005380:	57fd                	li	a5,-1
}
    80005382:	853e                	mv	a0,a5
    80005384:	70e2                	ld	ra,56(sp)
    80005386:	7442                	ld	s0,48(sp)
    80005388:	74a2                	ld	s1,40(sp)
    8000538a:	6121                	addi	sp,sp,64
    8000538c:	8082                	ret
	...

0000000080005390 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005390:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005392:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005394:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005396:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005398:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000539a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000539c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000539e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800053a0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800053a2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800053a4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800053a6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800053a8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800053aa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800053ac:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800053ae:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800053b0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800053b2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800053b4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800053b6:	b52fd0ef          	jal	ra,80002708 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800053ba:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800053bc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800053be:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800053c0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800053c2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800053c4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800053c6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800053c8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800053ca:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800053cc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800053ce:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800053d0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800053d2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800053d4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800053d6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800053d8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800053da:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800053dc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800053de:	10200073          	sret
	...

00000000800053ee <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053ee:	1141                	addi	sp,sp,-16
    800053f0:	e422                	sd	s0,8(sp)
    800053f2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053f4:	0c0007b7          	lui	a5,0xc000
    800053f8:	4705                	li	a4,1
    800053fa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053fc:	c3d8                	sw	a4,4(a5)
}
    800053fe:	6422                	ld	s0,8(sp)
    80005400:	0141                	addi	sp,sp,16
    80005402:	8082                	ret

0000000080005404 <plicinithart>:

void
plicinithart(void)
{
    80005404:	1141                	addi	sp,sp,-16
    80005406:	e406                	sd	ra,8(sp)
    80005408:	e022                	sd	s0,0(sp)
    8000540a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000540c:	be0fc0ef          	jal	ra,800017ec <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005410:	0085171b          	slliw	a4,a0,0x8
    80005414:	0c0027b7          	lui	a5,0xc002
    80005418:	97ba                	add	a5,a5,a4
    8000541a:	40200713          	li	a4,1026
    8000541e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005422:	00d5151b          	slliw	a0,a0,0xd
    80005426:	0c2017b7          	lui	a5,0xc201
    8000542a:	953e                	add	a0,a0,a5
    8000542c:	00052023          	sw	zero,0(a0)
}
    80005430:	60a2                	ld	ra,8(sp)
    80005432:	6402                	ld	s0,0(sp)
    80005434:	0141                	addi	sp,sp,16
    80005436:	8082                	ret

0000000080005438 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005438:	1141                	addi	sp,sp,-16
    8000543a:	e406                	sd	ra,8(sp)
    8000543c:	e022                	sd	s0,0(sp)
    8000543e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005440:	bacfc0ef          	jal	ra,800017ec <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005444:	00d5179b          	slliw	a5,a0,0xd
    80005448:	0c201537          	lui	a0,0xc201
    8000544c:	953e                	add	a0,a0,a5
  return irq;
}
    8000544e:	4148                	lw	a0,4(a0)
    80005450:	60a2                	ld	ra,8(sp)
    80005452:	6402                	ld	s0,0(sp)
    80005454:	0141                	addi	sp,sp,16
    80005456:	8082                	ret

0000000080005458 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005458:	1101                	addi	sp,sp,-32
    8000545a:	ec06                	sd	ra,24(sp)
    8000545c:	e822                	sd	s0,16(sp)
    8000545e:	e426                	sd	s1,8(sp)
    80005460:	1000                	addi	s0,sp,32
    80005462:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005464:	b88fc0ef          	jal	ra,800017ec <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005468:	00d5151b          	slliw	a0,a0,0xd
    8000546c:	0c2017b7          	lui	a5,0xc201
    80005470:	97aa                	add	a5,a5,a0
    80005472:	c3c4                	sw	s1,4(a5)
}
    80005474:	60e2                	ld	ra,24(sp)
    80005476:	6442                	ld	s0,16(sp)
    80005478:	64a2                	ld	s1,8(sp)
    8000547a:	6105                	addi	sp,sp,32
    8000547c:	8082                	ret

000000008000547e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000547e:	1141                	addi	sp,sp,-16
    80005480:	e406                	sd	ra,8(sp)
    80005482:	e022                	sd	s0,0(sp)
    80005484:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005486:	479d                	li	a5,7
    80005488:	04a7ca63          	blt	a5,a0,800054dc <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000548c:	0001c797          	auipc	a5,0x1c
    80005490:	ad478793          	addi	a5,a5,-1324 # 80020f60 <disk>
    80005494:	97aa                	add	a5,a5,a0
    80005496:	0187c783          	lbu	a5,24(a5)
    8000549a:	e7b9                	bnez	a5,800054e8 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000549c:	00451613          	slli	a2,a0,0x4
    800054a0:	0001c797          	auipc	a5,0x1c
    800054a4:	ac078793          	addi	a5,a5,-1344 # 80020f60 <disk>
    800054a8:	6394                	ld	a3,0(a5)
    800054aa:	96b2                	add	a3,a3,a2
    800054ac:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800054b0:	6398                	ld	a4,0(a5)
    800054b2:	9732                	add	a4,a4,a2
    800054b4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054b8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054bc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054c0:	953e                	add	a0,a0,a5
    800054c2:	4785                	li	a5,1
    800054c4:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800054c8:	0001c517          	auipc	a0,0x1c
    800054cc:	ab050513          	addi	a0,a0,-1360 # 80020f78 <disk+0x18>
    800054d0:	aadfc0ef          	jal	ra,80001f7c <wakeup>
}
    800054d4:	60a2                	ld	ra,8(sp)
    800054d6:	6402                	ld	s0,0(sp)
    800054d8:	0141                	addi	sp,sp,16
    800054da:	8082                	ret
    panic("free_desc 1");
    800054dc:	00002517          	auipc	a0,0x2
    800054e0:	34450513          	addi	a0,a0,836 # 80007820 <syscalls+0x370>
    800054e4:	aa6fb0ef          	jal	ra,8000078a <panic>
    panic("free_desc 2");
    800054e8:	00002517          	auipc	a0,0x2
    800054ec:	34850513          	addi	a0,a0,840 # 80007830 <syscalls+0x380>
    800054f0:	a9afb0ef          	jal	ra,8000078a <panic>

00000000800054f4 <virtio_disk_init>:
{
    800054f4:	1101                	addi	sp,sp,-32
    800054f6:	ec06                	sd	ra,24(sp)
    800054f8:	e822                	sd	s0,16(sp)
    800054fa:	e426                	sd	s1,8(sp)
    800054fc:	e04a                	sd	s2,0(sp)
    800054fe:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005500:	00002597          	auipc	a1,0x2
    80005504:	34058593          	addi	a1,a1,832 # 80007840 <syscalls+0x390>
    80005508:	0001c517          	auipc	a0,0x1c
    8000550c:	b8050513          	addi	a0,a0,-1152 # 80021088 <disk+0x128>
    80005510:	ddcfb0ef          	jal	ra,80000aec <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005514:	100017b7          	lui	a5,0x10001
    80005518:	4398                	lw	a4,0(a5)
    8000551a:	2701                	sext.w	a4,a4
    8000551c:	747277b7          	lui	a5,0x74727
    80005520:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005524:	14f71063          	bne	a4,a5,80005664 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005528:	100017b7          	lui	a5,0x10001
    8000552c:	43dc                	lw	a5,4(a5)
    8000552e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005530:	4709                	li	a4,2
    80005532:	12e79963          	bne	a5,a4,80005664 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005536:	100017b7          	lui	a5,0x10001
    8000553a:	479c                	lw	a5,8(a5)
    8000553c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000553e:	12e79363          	bne	a5,a4,80005664 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005542:	100017b7          	lui	a5,0x10001
    80005546:	47d8                	lw	a4,12(a5)
    80005548:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000554a:	554d47b7          	lui	a5,0x554d4
    8000554e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005552:	10f71963          	bne	a4,a5,80005664 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005556:	100017b7          	lui	a5,0x10001
    8000555a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000555e:	4705                	li	a4,1
    80005560:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005562:	470d                	li	a4,3
    80005564:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005566:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005568:	c7ffe737          	lui	a4,0xc7ffe
    8000556c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd6bf>
    80005570:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005572:	2701                	sext.w	a4,a4
    80005574:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005576:	472d                	li	a4,11
    80005578:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000557a:	5bbc                	lw	a5,112(a5)
    8000557c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005580:	8ba1                	andi	a5,a5,8
    80005582:	0e078763          	beqz	a5,80005670 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005586:	100017b7          	lui	a5,0x10001
    8000558a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000558e:	43fc                	lw	a5,68(a5)
    80005590:	2781                	sext.w	a5,a5
    80005592:	0e079563          	bnez	a5,8000567c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005596:	100017b7          	lui	a5,0x10001
    8000559a:	5bdc                	lw	a5,52(a5)
    8000559c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000559e:	0e078563          	beqz	a5,80005688 <virtio_disk_init+0x194>
  if(max < NUM)
    800055a2:	471d                	li	a4,7
    800055a4:	0ef77863          	bgeu	a4,a5,80005694 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    800055a8:	cf4fb0ef          	jal	ra,80000a9c <kalloc>
    800055ac:	0001c497          	auipc	s1,0x1c
    800055b0:	9b448493          	addi	s1,s1,-1612 # 80020f60 <disk>
    800055b4:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055b6:	ce6fb0ef          	jal	ra,80000a9c <kalloc>
    800055ba:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055bc:	ce0fb0ef          	jal	ra,80000a9c <kalloc>
    800055c0:	87aa                	mv	a5,a0
    800055c2:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800055c4:	6088                	ld	a0,0(s1)
    800055c6:	cd69                	beqz	a0,800056a0 <virtio_disk_init+0x1ac>
    800055c8:	0001c717          	auipc	a4,0x1c
    800055cc:	9a073703          	ld	a4,-1632(a4) # 80020f68 <disk+0x8>
    800055d0:	cb61                	beqz	a4,800056a0 <virtio_disk_init+0x1ac>
    800055d2:	c7f9                	beqz	a5,800056a0 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    800055d4:	6605                	lui	a2,0x1
    800055d6:	4581                	li	a1,0
    800055d8:	e68fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.avail, 0, PGSIZE);
    800055dc:	0001c497          	auipc	s1,0x1c
    800055e0:	98448493          	addi	s1,s1,-1660 # 80020f60 <disk>
    800055e4:	6605                	lui	a2,0x1
    800055e6:	4581                	li	a1,0
    800055e8:	6488                	ld	a0,8(s1)
    800055ea:	e56fb0ef          	jal	ra,80000c40 <memset>
  memset(disk.used, 0, PGSIZE);
    800055ee:	6605                	lui	a2,0x1
    800055f0:	4581                	li	a1,0
    800055f2:	6888                	ld	a0,16(s1)
    800055f4:	e4cfb0ef          	jal	ra,80000c40 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055f8:	100017b7          	lui	a5,0x10001
    800055fc:	4721                	li	a4,8
    800055fe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005600:	4098                	lw	a4,0(s1)
    80005602:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005606:	40d8                	lw	a4,4(s1)
    80005608:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000560c:	6498                	ld	a4,8(s1)
    8000560e:	0007069b          	sext.w	a3,a4
    80005612:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005616:	9701                	srai	a4,a4,0x20
    80005618:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000561c:	6898                	ld	a4,16(s1)
    8000561e:	0007069b          	sext.w	a3,a4
    80005622:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005626:	9701                	srai	a4,a4,0x20
    80005628:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000562c:	4705                	li	a4,1
    8000562e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005630:	00e48c23          	sb	a4,24(s1)
    80005634:	00e48ca3          	sb	a4,25(s1)
    80005638:	00e48d23          	sb	a4,26(s1)
    8000563c:	00e48da3          	sb	a4,27(s1)
    80005640:	00e48e23          	sb	a4,28(s1)
    80005644:	00e48ea3          	sb	a4,29(s1)
    80005648:	00e48f23          	sb	a4,30(s1)
    8000564c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005650:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005654:	0727a823          	sw	s2,112(a5)
}
    80005658:	60e2                	ld	ra,24(sp)
    8000565a:	6442                	ld	s0,16(sp)
    8000565c:	64a2                	ld	s1,8(sp)
    8000565e:	6902                	ld	s2,0(sp)
    80005660:	6105                	addi	sp,sp,32
    80005662:	8082                	ret
    panic("could not find virtio disk");
    80005664:	00002517          	auipc	a0,0x2
    80005668:	1ec50513          	addi	a0,a0,492 # 80007850 <syscalls+0x3a0>
    8000566c:	91efb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk FEATURES_OK unset");
    80005670:	00002517          	auipc	a0,0x2
    80005674:	20050513          	addi	a0,a0,512 # 80007870 <syscalls+0x3c0>
    80005678:	912fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk should not be ready");
    8000567c:	00002517          	auipc	a0,0x2
    80005680:	21450513          	addi	a0,a0,532 # 80007890 <syscalls+0x3e0>
    80005684:	906fb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk has no queue 0");
    80005688:	00002517          	auipc	a0,0x2
    8000568c:	22850513          	addi	a0,a0,552 # 800078b0 <syscalls+0x400>
    80005690:	8fafb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk max queue too short");
    80005694:	00002517          	auipc	a0,0x2
    80005698:	23c50513          	addi	a0,a0,572 # 800078d0 <syscalls+0x420>
    8000569c:	8eefb0ef          	jal	ra,8000078a <panic>
    panic("virtio disk kalloc");
    800056a0:	00002517          	auipc	a0,0x2
    800056a4:	25050513          	addi	a0,a0,592 # 800078f0 <syscalls+0x440>
    800056a8:	8e2fb0ef          	jal	ra,8000078a <panic>

00000000800056ac <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056ac:	7119                	addi	sp,sp,-128
    800056ae:	fc86                	sd	ra,120(sp)
    800056b0:	f8a2                	sd	s0,112(sp)
    800056b2:	f4a6                	sd	s1,104(sp)
    800056b4:	f0ca                	sd	s2,96(sp)
    800056b6:	ecce                	sd	s3,88(sp)
    800056b8:	e8d2                	sd	s4,80(sp)
    800056ba:	e4d6                	sd	s5,72(sp)
    800056bc:	e0da                	sd	s6,64(sp)
    800056be:	fc5e                	sd	s7,56(sp)
    800056c0:	f862                	sd	s8,48(sp)
    800056c2:	f466                	sd	s9,40(sp)
    800056c4:	f06a                	sd	s10,32(sp)
    800056c6:	ec6e                	sd	s11,24(sp)
    800056c8:	0100                	addi	s0,sp,128
    800056ca:	8aaa                	mv	s5,a0
    800056cc:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800056ce:	00c52d03          	lw	s10,12(a0)
    800056d2:	001d1d1b          	slliw	s10,s10,0x1
    800056d6:	1d02                	slli	s10,s10,0x20
    800056d8:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800056dc:	0001c517          	auipc	a0,0x1c
    800056e0:	9ac50513          	addi	a0,a0,-1620 # 80021088 <disk+0x128>
    800056e4:	c88fb0ef          	jal	ra,80000b6c <acquire>
  for(int i = 0; i < 3; i++){
    800056e8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800056ea:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056ec:	0001cb97          	auipc	s7,0x1c
    800056f0:	874b8b93          	addi	s7,s7,-1932 # 80020f60 <disk>
  for(int i = 0; i < 3; i++){
    800056f4:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056f6:	0001cc97          	auipc	s9,0x1c
    800056fa:	992c8c93          	addi	s9,s9,-1646 # 80021088 <disk+0x128>
    800056fe:	a8a9                	j	80005758 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005700:	00fb8733          	add	a4,s7,a5
    80005704:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005708:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000570a:	0207c563          	bltz	a5,80005734 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000570e:	2905                	addiw	s2,s2,1
    80005710:	0611                	addi	a2,a2,4
    80005712:	05690863          	beq	s2,s6,80005762 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80005716:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005718:	0001c717          	auipc	a4,0x1c
    8000571c:	84870713          	addi	a4,a4,-1976 # 80020f60 <disk>
    80005720:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005722:	01874683          	lbu	a3,24(a4)
    80005726:	fee9                	bnez	a3,80005700 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80005728:	2785                	addiw	a5,a5,1
    8000572a:	0705                	addi	a4,a4,1
    8000572c:	fe979be3          	bne	a5,s1,80005722 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005730:	57fd                	li	a5,-1
    80005732:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005734:	01205b63          	blez	s2,8000574a <virtio_disk_rw+0x9e>
    80005738:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000573a:	000a2503          	lw	a0,0(s4)
    8000573e:	d41ff0ef          	jal	ra,8000547e <free_desc>
      for(int j = 0; j < i; j++)
    80005742:	2d85                	addiw	s11,s11,1
    80005744:	0a11                	addi	s4,s4,4
    80005746:	ffb91ae3          	bne	s2,s11,8000573a <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000574a:	85e6                	mv	a1,s9
    8000574c:	0001c517          	auipc	a0,0x1c
    80005750:	82c50513          	addi	a0,a0,-2004 # 80020f78 <disk+0x18>
    80005754:	fdcfc0ef          	jal	ra,80001f30 <sleep>
  for(int i = 0; i < 3; i++){
    80005758:	f8040a13          	addi	s4,s0,-128
{
    8000575c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000575e:	894e                	mv	s2,s3
    80005760:	bf5d                	j	80005716 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005762:	f8042583          	lw	a1,-128(s0)
    80005766:	00a58793          	addi	a5,a1,10
    8000576a:	0792                	slli	a5,a5,0x4

  if(write)
    8000576c:	0001b617          	auipc	a2,0x1b
    80005770:	7f460613          	addi	a2,a2,2036 # 80020f60 <disk>
    80005774:	00f60733          	add	a4,a2,a5
    80005778:	018036b3          	snez	a3,s8
    8000577c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000577e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005782:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005786:	f6078693          	addi	a3,a5,-160
    8000578a:	6218                	ld	a4,0(a2)
    8000578c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000578e:	00878513          	addi	a0,a5,8
    80005792:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005794:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005796:	6208                	ld	a0,0(a2)
    80005798:	96aa                	add	a3,a3,a0
    8000579a:	4741                	li	a4,16
    8000579c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000579e:	4705                	li	a4,1
    800057a0:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800057a4:	f8442703          	lw	a4,-124(s0)
    800057a8:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800057ac:	0712                	slli	a4,a4,0x4
    800057ae:	953a                	add	a0,a0,a4
    800057b0:	058a8693          	addi	a3,s5,88
    800057b4:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800057b6:	6208                	ld	a0,0(a2)
    800057b8:	972a                	add	a4,a4,a0
    800057ba:	40000693          	li	a3,1024
    800057be:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800057c0:	001c3c13          	seqz	s8,s8
    800057c4:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800057c6:	001c6c13          	ori	s8,s8,1
    800057ca:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057ce:	f8842603          	lw	a2,-120(s0)
    800057d2:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057d6:	0001b697          	auipc	a3,0x1b
    800057da:	78a68693          	addi	a3,a3,1930 # 80020f60 <disk>
    800057de:	00258713          	addi	a4,a1,2
    800057e2:	0712                	slli	a4,a4,0x4
    800057e4:	9736                	add	a4,a4,a3
    800057e6:	587d                	li	a6,-1
    800057e8:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057ec:	0612                	slli	a2,a2,0x4
    800057ee:	9532                	add	a0,a0,a2
    800057f0:	f9078793          	addi	a5,a5,-112
    800057f4:	97b6                	add	a5,a5,a3
    800057f6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800057f8:	629c                	ld	a5,0(a3)
    800057fa:	97b2                	add	a5,a5,a2
    800057fc:	4605                	li	a2,1
    800057fe:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005800:	4509                	li	a0,2
    80005802:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80005806:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000580a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000580e:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005812:	6698                	ld	a4,8(a3)
    80005814:	00275783          	lhu	a5,2(a4)
    80005818:	8b9d                	andi	a5,a5,7
    8000581a:	0786                	slli	a5,a5,0x1
    8000581c:	97ba                	add	a5,a5,a4
    8000581e:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005822:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005826:	6698                	ld	a4,8(a3)
    80005828:	00275783          	lhu	a5,2(a4)
    8000582c:	2785                	addiw	a5,a5,1
    8000582e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005832:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005836:	100017b7          	lui	a5,0x10001
    8000583a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000583e:	004aa783          	lw	a5,4(s5)
    80005842:	00c79f63          	bne	a5,a2,80005860 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80005846:	0001c917          	auipc	s2,0x1c
    8000584a:	84290913          	addi	s2,s2,-1982 # 80021088 <disk+0x128>
  while(b->disk == 1) {
    8000584e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005850:	85ca                	mv	a1,s2
    80005852:	8556                	mv	a0,s5
    80005854:	edcfc0ef          	jal	ra,80001f30 <sleep>
  while(b->disk == 1) {
    80005858:	004aa783          	lw	a5,4(s5)
    8000585c:	fe978ae3          	beq	a5,s1,80005850 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005860:	f8042903          	lw	s2,-128(s0)
    80005864:	00290793          	addi	a5,s2,2
    80005868:	00479713          	slli	a4,a5,0x4
    8000586c:	0001b797          	auipc	a5,0x1b
    80005870:	6f478793          	addi	a5,a5,1780 # 80020f60 <disk>
    80005874:	97ba                	add	a5,a5,a4
    80005876:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000587a:	0001b997          	auipc	s3,0x1b
    8000587e:	6e698993          	addi	s3,s3,1766 # 80020f60 <disk>
    80005882:	00491713          	slli	a4,s2,0x4
    80005886:	0009b783          	ld	a5,0(s3)
    8000588a:	97ba                	add	a5,a5,a4
    8000588c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005890:	854a                	mv	a0,s2
    80005892:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005896:	be9ff0ef          	jal	ra,8000547e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000589a:	8885                	andi	s1,s1,1
    8000589c:	f0fd                	bnez	s1,80005882 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000589e:	0001b517          	auipc	a0,0x1b
    800058a2:	7ea50513          	addi	a0,a0,2026 # 80021088 <disk+0x128>
    800058a6:	b5efb0ef          	jal	ra,80000c04 <release>
}
    800058aa:	70e6                	ld	ra,120(sp)
    800058ac:	7446                	ld	s0,112(sp)
    800058ae:	74a6                	ld	s1,104(sp)
    800058b0:	7906                	ld	s2,96(sp)
    800058b2:	69e6                	ld	s3,88(sp)
    800058b4:	6a46                	ld	s4,80(sp)
    800058b6:	6aa6                	ld	s5,72(sp)
    800058b8:	6b06                	ld	s6,64(sp)
    800058ba:	7be2                	ld	s7,56(sp)
    800058bc:	7c42                	ld	s8,48(sp)
    800058be:	7ca2                	ld	s9,40(sp)
    800058c0:	7d02                	ld	s10,32(sp)
    800058c2:	6de2                	ld	s11,24(sp)
    800058c4:	6109                	addi	sp,sp,128
    800058c6:	8082                	ret

00000000800058c8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058c8:	1101                	addi	sp,sp,-32
    800058ca:	ec06                	sd	ra,24(sp)
    800058cc:	e822                	sd	s0,16(sp)
    800058ce:	e426                	sd	s1,8(sp)
    800058d0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058d2:	0001b497          	auipc	s1,0x1b
    800058d6:	68e48493          	addi	s1,s1,1678 # 80020f60 <disk>
    800058da:	0001b517          	auipc	a0,0x1b
    800058de:	7ae50513          	addi	a0,a0,1966 # 80021088 <disk+0x128>
    800058e2:	a8afb0ef          	jal	ra,80000b6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058e6:	10001737          	lui	a4,0x10001
    800058ea:	533c                	lw	a5,96(a4)
    800058ec:	8b8d                	andi	a5,a5,3
    800058ee:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800058f0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058f4:	689c                	ld	a5,16(s1)
    800058f6:	0204d703          	lhu	a4,32(s1)
    800058fa:	0027d783          	lhu	a5,2(a5)
    800058fe:	04f70663          	beq	a4,a5,8000594a <virtio_disk_intr+0x82>
    __sync_synchronize();
    80005902:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005906:	6898                	ld	a4,16(s1)
    80005908:	0204d783          	lhu	a5,32(s1)
    8000590c:	8b9d                	andi	a5,a5,7
    8000590e:	078e                	slli	a5,a5,0x3
    80005910:	97ba                	add	a5,a5,a4
    80005912:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005914:	00278713          	addi	a4,a5,2
    80005918:	0712                	slli	a4,a4,0x4
    8000591a:	9726                	add	a4,a4,s1
    8000591c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005920:	e321                	bnez	a4,80005960 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005922:	0789                	addi	a5,a5,2
    80005924:	0792                	slli	a5,a5,0x4
    80005926:	97a6                	add	a5,a5,s1
    80005928:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000592a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000592e:	e4efc0ef          	jal	ra,80001f7c <wakeup>

    disk.used_idx += 1;
    80005932:	0204d783          	lhu	a5,32(s1)
    80005936:	2785                	addiw	a5,a5,1
    80005938:	17c2                	slli	a5,a5,0x30
    8000593a:	93c1                	srli	a5,a5,0x30
    8000593c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005940:	6898                	ld	a4,16(s1)
    80005942:	00275703          	lhu	a4,2(a4)
    80005946:	faf71ee3          	bne	a4,a5,80005902 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    8000594a:	0001b517          	auipc	a0,0x1b
    8000594e:	73e50513          	addi	a0,a0,1854 # 80021088 <disk+0x128>
    80005952:	ab2fb0ef          	jal	ra,80000c04 <release>
}
    80005956:	60e2                	ld	ra,24(sp)
    80005958:	6442                	ld	s0,16(sp)
    8000595a:	64a2                	ld	s1,8(sp)
    8000595c:	6105                	addi	sp,sp,32
    8000595e:	8082                	ret
      panic("virtio_disk_intr status");
    80005960:	00002517          	auipc	a0,0x2
    80005964:	fa850513          	addi	a0,a0,-88 # 80007908 <syscalls+0x458>
    80005968:	e23fa0ef          	jal	ra,8000078a <panic>
	...

0000000080006000 <_trampoline>:
        # user page table.
        #

        # save user a0 in sscratch so
        # a0 can be used to get at TRAPFRAME.
        csrw sscratch, a0
    80006000:	14051073          	csrw	sscratch,a0

        # each process has a separate p->trapframe memory area,
        # but it's mapped to the same virtual address
        # (TRAPFRAME) in every process's user page table.
        li a0, TRAPFRAME
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
        
        # save the user registers in TRAPFRAME
        sd ra, 40(a0)
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        sd sp, 48(a0)
    80006010:	02253823          	sd	sp,48(a0)
        sd gp, 56(a0)
    80006014:	02353c23          	sd	gp,56(a0)
        sd tp, 64(a0)
    80006018:	04453023          	sd	tp,64(a0)
        sd t0, 72(a0)
    8000601c:	04553423          	sd	t0,72(a0)
        sd t1, 80(a0)
    80006020:	04653823          	sd	t1,80(a0)
        sd t2, 88(a0)
    80006024:	04753c23          	sd	t2,88(a0)
        sd s0, 96(a0)
    80006028:	f120                	sd	s0,96(a0)
        sd s1, 104(a0)
    8000602a:	f524                	sd	s1,104(a0)
        sd a1, 120(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
        sd a2, 128(a0)
    8000602e:	e150                	sd	a2,128(a0)
        sd a3, 136(a0)
    80006030:	e554                	sd	a3,136(a0)
        sd a4, 144(a0)
    80006032:	e958                	sd	a4,144(a0)
        sd a5, 152(a0)
    80006034:	ed5c                	sd	a5,152(a0)
        sd a6, 160(a0)
    80006036:	0b053023          	sd	a6,160(a0)
        sd a7, 168(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
        sd s2, 176(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
        sd s3, 184(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
        sd s4, 192(a0)
    80006046:	0d453023          	sd	s4,192(a0)
        sd s5, 200(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
        sd s6, 208(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
        sd s7, 216(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
        sd s8, 224(a0)
    80006056:	0f853023          	sd	s8,224(a0)
        sd s9, 232(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
        sd s10, 240(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
        sd s11, 248(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
        sd t3, 256(a0)
    80006066:	11c53023          	sd	t3,256(a0)
        sd t4, 264(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
        sd t5, 272(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
        sd t6, 280(a0)
    80006072:	11f53c23          	sd	t6,280(a0)

	# save the user a0 in p->trapframe->a0
        csrr t0, sscratch
    80006076:	140022f3          	csrr	t0,sscratch
        sd t0, 112(a0)
    8000607a:	06553823          	sd	t0,112(a0)

        # initialize kernel stack pointer, from p->trapframe->kernel_sp
        ld sp, 8(a0)
    8000607e:	00853103          	ld	sp,8(a0)

        # make tp hold the current hartid, from p->trapframe->kernel_hartid
        ld tp, 32(a0)
    80006082:	02053203          	ld	tp,32(a0)

        # load the address of usertrap(), from p->trapframe->kernel_trap
        ld t0, 16(a0)
    80006086:	01053283          	ld	t0,16(a0)

        # fetch the kernel page table address, from p->trapframe->kernel_satp.
        ld t1, 0(a0)
    8000608a:	00053303          	ld	t1,0(a0)

        # wait for any previous memory operations to complete, so that
        # they use the user page table.
        sfence.vma zero, zero
    8000608e:	12000073          	sfence.vma

        # install the kernel page table.
        csrw satp, t1
    80006092:	18031073          	csrw	satp,t1

        # flush now-stale user entries from the TLB.
        sfence.vma zero, zero
    80006096:	12000073          	sfence.vma

        # call usertrap()
        jalr t0
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
userret:
        # usertrap() returns here, with user satp in a0.
        # return from kernel to user.

        # switch to the user page table.
        sfence.vma zero, zero
    8000609c:	12000073          	sfence.vma
        csrw satp, a0
    800060a0:	18051073          	csrw	satp,a0
        sfence.vma zero, zero
    800060a4:	12000073          	sfence.vma

        li a0, TRAPFRAME
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd

        # restore all but a0 from TRAPFRAME
        ld ra, 40(a0)
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
        ld sp, 48(a0)
    800060b4:	03053103          	ld	sp,48(a0)
        ld gp, 56(a0)
    800060b8:	03853183          	ld	gp,56(a0)
        ld tp, 64(a0)
    800060bc:	04053203          	ld	tp,64(a0)
        ld t0, 72(a0)
    800060c0:	04853283          	ld	t0,72(a0)
        ld t1, 80(a0)
    800060c4:	05053303          	ld	t1,80(a0)
        ld t2, 88(a0)
    800060c8:	05853383          	ld	t2,88(a0)
        ld s0, 96(a0)
    800060cc:	7120                	ld	s0,96(a0)
        ld s1, 104(a0)
    800060ce:	7524                	ld	s1,104(a0)
        ld a1, 120(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
        ld a2, 128(a0)
    800060d2:	6150                	ld	a2,128(a0)
        ld a3, 136(a0)
    800060d4:	6554                	ld	a3,136(a0)
        ld a4, 144(a0)
    800060d6:	6958                	ld	a4,144(a0)
        ld a5, 152(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
        ld a6, 160(a0)
    800060da:	0a053803          	ld	a6,160(a0)
        ld a7, 168(a0)
    800060de:	0a853883          	ld	a7,168(a0)
        ld s2, 176(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
        ld s3, 184(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
        ld s4, 192(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
        ld s5, 200(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
        ld s6, 208(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
        ld s7, 216(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
        ld s8, 224(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
        ld s9, 232(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
        ld s10, 240(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
        ld s11, 248(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
        ld t3, 256(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
        ld t4, 264(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
        ld t5, 272(a0)
    80006112:	11053f03          	ld	t5,272(a0)
        ld t6, 280(a0)
    80006116:	11853f83          	ld	t6,280(a0)

	# restore user a0
        ld a0, 112(a0)
    8000611a:	7928                	ld	a0,112(a0)
        
        # return to user mode and user pc.
        # usertrapret() set up sstatus and sepc.
        sret
    8000611c:	10200073          	sret
	...
