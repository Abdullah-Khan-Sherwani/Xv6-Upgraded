
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
    80000004:	8a010113          	addi	sp,sp,-1888 # 800078a0 <stack0>
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
    80000016:	04e000ef          	jal	80000064 <start>

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
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd83f>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	28c020ef          	jal	800023a6 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	70e50513          	addi	a0,a0,1806 # 8000f8a0 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	70248493          	addi	s1,s1,1794 # 8000f8a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	0000f917          	auipc	s2,0xf
    800001aa:	79290913          	addi	s2,s2,1938 # 8000f938 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	778010ef          	jal	80001936 <myproc>
    800001c2:	07c020ef          	jal	8000223e <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	637010ef          	jal	80002002 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	6c270713          	addi	a4,a4,1730 # 8000f8a0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	14c020ef          	jal	8000235c <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	67850513          	addi	a0,a0,1656 # 8000f8a0 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	6ef72523          	sw	a5,1770(a4) # 8000f938 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	63c50513          	addi	a0,a0,1596 # 8000f8a0 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	5e850513          	addi	a0,a0,1512 # 8000f8a0 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	116020ef          	jal	800023f0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	5c250513          	addi	a0,a0,1474 # 8000f8a0 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	5a470713          	addi	a4,a4,1444 # 8000f8a0 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	57e70713          	addi	a4,a4,1406 # 8000f8a0 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	0000f717          	auipc	a4,0xf
    80000350:	5ec72703          	lw	a4,1516(a4) # 8000f938 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	53e70713          	addi	a4,a4,1342 # 8000f8a0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	52e48493          	addi	s1,s1,1326 # 8000f8a0 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	0000f717          	auipc	a4,0xf
    800003b8:	4ec70713          	addi	a4,a4,1260 # 8000f8a0 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	56f72b23          	sw	a5,1398(a4) # 8000f940 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	0000f797          	auipc	a5,0xf
    800003ec:	4b878793          	addi	a5,a5,1208 # 8000f8a0 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	0000f797          	auipc	a5,0xf
    8000040e:	52c7a923          	sw	a2,1330(a5) # 8000f93c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	52650513          	addi	a0,a0,1318 # 8000f938 <cons+0x98>
    8000041a:	435010ef          	jal	8000204e <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	0000f517          	auipc	a0,0xf
    80000434:	47050513          	addi	a0,a0,1136 # 8000f8a0 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00020797          	auipc	a5,0x20
    80000444:	9e878793          	addi	a5,a5,-1560 # 8001fe28 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	29a80813          	addi	a6,a6,666 # 80007718 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
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
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	34c7a783          	lw	a5,844(a5) # 80007864 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	0000f517          	auipc	a0,0xf
    80000562:	3ea50513          	addi	a0,a0,1002 # 8000f948 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	046c8c93          	addi	s9,s9,70 # 80007718 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	10a7a783          	lw	a5,266(a5) # 80007864 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	1c450513          	addi	a0,a0,452 # 8000f948 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	00007797          	auipc	a5,0x7
    80000838:	0297a823          	sw	s1,48(a5) # 80007864 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	00007797          	auipc	a5,0x7
    8000085a:	0097a523          	sw	s1,10(a5) # 80007860 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	0000f517          	auipc	a0,0xf
    80000874:	0d850513          	addi	a0,a0,216 # 8000f948 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	0000f517          	auipc	a0,0xf
    800008ca:	09a50513          	addi	a0,a0,154 # 8000f960 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	0000f517          	auipc	a0,0xf
    800008ee:	07650513          	addi	a0,a0,118 # 8000f960 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	00007497          	auipc	s1,0x7
    8000090c:	f6448493          	addi	s1,s1,-156 # 8000786c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	05098993          	addi	s3,s3,80 # 8000f960 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	f5090913          	addi	s2,s2,-176 # 80007868 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	6d6010ef          	jal	80002002 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	0000f517          	auipc	a0,0xf
    8000095a:	00a50513          	addi	a0,a0,10 # 8000f960 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	00007797          	auipc	a5,0x7
    8000097e:	eea7a783          	lw	a5,-278(a5) # 80007864 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	edc7a783          	lw	a5,-292(a5) # 80007860 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	eba7a783          	lw	a5,-326(a5) # 80007864 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	0000f517          	auipc	a0,0xf
    80000a0a:	f5a50513          	addi	a0,a0,-166 # 8000f960 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	0000f517          	auipc	a0,0xf
    80000a24:	f4050513          	addi	a0,a0,-192 # 8000f960 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	00007797          	auipc	a5,0x7
    80000a40:	e207a823          	sw	zero,-464(a5) # 8000786c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	e2450513          	addi	a0,a0,-476 # 80007868 <tx_chan>
    80000a4c:	602010ef          	jal	8000204e <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00020797          	auipc	a5,0x20
    80000a6c:	55878793          	addi	a5,a5,1368 # 80020fc0 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	0000f917          	auipc	s2,0xf
    80000a96:	ee690913          	addi	s2,s2,-282 # 8000f978 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00006517          	auipc	a0,0x6
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80007038 <etext+0x38>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00006597          	auipc	a1,0x6
    80000b1c:	52858593          	addi	a1,a1,1320 # 80007040 <etext+0x40>
    80000b20:	0000f517          	auipc	a0,0xf
    80000b24:	e5850513          	addi	a0,a0,-424 # 8000f978 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00020517          	auipc	a0,0x20
    80000b34:	49050513          	addi	a0,a0,1168 # 80020fc0 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	0000f517          	auipc	a0,0xf
    80000b52:	e2a50513          	addi	a0,a0,-470 # 8000f978 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	0000f497          	auipc	s1,0xf
    80000b5e:	e364b483          	ld	s1,-458(s1) # 8000f990 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	0000f717          	auipc	a4,0xf
    80000b6a:	e2f73523          	sd	a5,-470(a4) # 8000f990 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	e0a50513          	addi	a0,a0,-502 # 8000f978 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	0000f517          	auipc	a0,0xf
    80000b94:	de850513          	addi	a0,a0,-536 # 8000f978 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	549000ef          	jal	80001916 <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	519000ef          	jal	80001916 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	511000ef          	jal	80001916 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	4fd000ef          	jal	80001916 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	4c7000ef          	jal	80001916 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	4a3000ef          	jal	80001916 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80007050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3b850513          	addi	a0,a0,952 # 80007068 <etext+0x68>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00006517          	auipc	a0,0x6
    80000cf0:	38450513          	addi	a0,a0,900 # 80007070 <etext+0x70>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	24d000ef          	jal	80001902 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00007717          	auipc	a4,0x7
    80000ebe:	9b670713          	addi	a4,a4,-1610 # 80007870 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	235000ef          	jal	80001902 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	63e010ef          	jal	80002522 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	700040ef          	jal	800055e8 <plicinithart>
  }

  scheduler();        
    80000eec:	723000ef          	jal	80001e0e <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	117000ef          	jal	8000183e <procinit>
    trapinit();      // trap vectors
    80000f2c:	5d2010ef          	jal	800024fe <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	5f2010ef          	jal	80002522 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	69a040ef          	jal	800055ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	6b0040ef          	jal	800055e8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	525010ef          	jal	80002c60 <binit>
    iinit();         // inode table
    80000f40:	276020ef          	jal	800031b6 <iinit>
    fileinit();      // file table
    80000f44:	1a2030ef          	jal	800040e6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	790040ef          	jal	800056d8 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	4c1000ef          	jal	80001c0c <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	90f72d23          	sw	a5,-1766(a4) # 80007870 <started>
    80000f5e:	b779                	j	80000eec <main+0x3e>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	00007797          	auipc	a5,0x7
    80000f70:	90c7b783          	ld	a5,-1780(a5) # 80007878 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	04b7e263          	bltu	a5,a1,80000ff2 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
    80000fc6:	cf85                	beqz	a5,80000ffe <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc8:	80a9                	srli	s1,s1,0xa
    80000fca:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fcc:	3a5d                	addiw	s4,s4,-9
    80000fce:	ff5a12e3          	bne	s4,s5,80000fb2 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd2:	00c9d513          	srli	a0,s3,0xc
    80000fd6:	1ff57513          	andi	a0,a0,511
    80000fda:	050e                	slli	a0,a0,0x3
    80000fdc:	9526                	add	a0,a0,s1
}
    80000fde:	70e2                	ld	ra,56(sp)
    80000fe0:	7442                	ld	s0,48(sp)
    80000fe2:	74a2                	ld	s1,40(sp)
    80000fe4:	7902                	ld	s2,32(sp)
    80000fe6:	69e2                	ld	s3,24(sp)
    80000fe8:	6a42                	ld	s4,16(sp)
    80000fea:	6aa2                	ld	s5,8(sp)
    80000fec:	6b02                	ld	s6,0(sp)
    80000fee:	6121                	addi	sp,sp,64
    80000ff0:	8082                	ret
    panic("walk");
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	0be50513          	addi	a0,a0,190 # 800070b0 <etext+0xb0>
    80000ffa:	82bff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	020b0263          	beqz	s6,80001022 <walk+0x96>
    80001002:	b43ff0ef          	jal	80000b44 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	d979                	beqz	a0,80000fde <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cebff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
    80001020:	b775                	j	80000fcc <walk+0x40>
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	bf6d                	j	80000fde <walk+0x52>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    80001040:	c901                	beqz	a0,80001050 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>

0000000080001060 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001060:	715d                	addi	sp,sp,-80
    80001062:	e486                	sd	ra,72(sp)
    80001064:	e0a2                	sd	s0,64(sp)
    80001066:	fc26                	sd	s1,56(sp)
    80001068:	f84a                	sd	s2,48(sp)
    8000106a:	f44e                	sd	s3,40(sp)
    8000106c:	f052                	sd	s4,32(sp)
    8000106e:	ec56                	sd	s5,24(sp)
    80001070:	e85a                	sd	s6,16(sp)
    80001072:	e45e                	sd	s7,8(sp)
    80001074:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001076:	03459793          	slli	a5,a1,0x34
    8000107a:	eba1                	bnez	a5,800010ca <mappages+0x6a>
    8000107c:	8a2a                	mv	s4,a0
    8000107e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001080:	03461793          	slli	a5,a2,0x34
    80001084:	eba9                	bnez	a5,800010d6 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    80001086:	ce31                	beqz	a2,800010e2 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001088:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000108c:	80060613          	addi	a2,a2,-2048
    80001090:	00b60933          	add	s2,a2,a1
  a = va;
    80001094:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	4b05                	li	s6,1
    80001098:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000109c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	865a                	mv	a2,s6
    800010a0:	85a6                	mv	a1,s1
    800010a2:	8552                	mv	a0,s4
    800010a4:	ee9ff0ef          	jal	80000f8c <walk>
    800010a8:	c929                	beqz	a0,800010fa <mappages+0x9a>
    if(*pte & PTE_V)
    800010aa:	611c                	ld	a5,0(a0)
    800010ac:	8b85                	andi	a5,a5,1
    800010ae:	e3a1                	bnez	a5,800010ee <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b0:	013487b3          	add	a5,s1,s3
    800010b4:	83b1                	srli	a5,a5,0xc
    800010b6:	07aa                	slli	a5,a5,0xa
    800010b8:	0157e7b3          	or	a5,a5,s5
    800010bc:	0017e793          	ori	a5,a5,1
    800010c0:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c2:	05248863          	beq	s1,s2,80001112 <mappages+0xb2>
    a += PGSIZE;
    800010c6:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c8:	bfd9                	j	8000109e <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ca:	00006517          	auipc	a0,0x6
    800010ce:	fee50513          	addi	a0,a0,-18 # 800070b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00006517          	auipc	a0,0x6
    800010da:	00250513          	addi	a0,a0,2 # 800070d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00006517          	auipc	a0,0x6
    800010e6:	01650513          	addi	a0,a0,22 # 800070f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00006517          	auipc	a0,0x6
    800010f2:	01a50513          	addi	a0,a0,26 # 80007108 <etext+0x108>
    800010f6:	f2eff0ef          	jal	80000824 <panic>
      return -1;
    800010fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fc:	60a6                	ld	ra,72(sp)
    800010fe:	6406                	ld	s0,64(sp)
    80001100:	74e2                	ld	s1,56(sp)
    80001102:	7942                	ld	s2,48(sp)
    80001104:	79a2                	ld	s3,40(sp)
    80001106:	7a02                	ld	s4,32(sp)
    80001108:	6ae2                	ld	s5,24(sp)
    8000110a:	6b42                	ld	s6,16(sp)
    8000110c:	6ba2                	ld	s7,8(sp)
    8000110e:	6161                	addi	sp,sp,80
    80001110:	8082                	ret
  return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7e5                	j	800010fc <mappages+0x9c>

0000000080001116 <kvmmap>:
{
    80001116:	1141                	addi	sp,sp,-16
    80001118:	e406                	sd	ra,8(sp)
    8000111a:	e022                	sd	s0,0(sp)
    8000111c:	0800                	addi	s0,sp,16
    8000111e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001120:	86b2                	mv	a3,a2
    80001122:	863e                	mv	a2,a5
    80001124:	f3dff0ef          	jal	80001060 <mappages>
    80001128:	e509                	bnez	a0,80001132 <kvmmap+0x1c>
}
    8000112a:	60a2                	ld	ra,8(sp)
    8000112c:	6402                	ld	s0,0(sp)
    8000112e:	0141                	addi	sp,sp,16
    80001130:	8082                	ret
    panic("kvmmap");
    80001132:	00006517          	auipc	a0,0x6
    80001136:	fe650513          	addi	a0,a0,-26 # 80007118 <etext+0x118>
    8000113a:	eeaff0ef          	jal	80000824 <panic>

000000008000113e <kvmmake>:
{
    8000113e:	1101                	addi	sp,sp,-32
    80001140:	ec06                	sd	ra,24(sp)
    80001142:	e822                	sd	s0,16(sp)
    80001144:	e426                	sd	s1,8(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001148:	9fdff0ef          	jal	80000b44 <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	ba7ff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	85b2                	mv	a1,a2
    80001160:	8526                	mv	a0,s1
    80001162:	fb5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001166:	4719                	li	a4,6
    80001168:	6685                	lui	a3,0x1
    8000116a:	10001637          	lui	a2,0x10001
    8000116e:	85b2                	mv	a1,a2
    80001170:	8526                	mv	a0,s1
    80001172:	fa5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	040006b7          	lui	a3,0x4000
    8000117c:	0c000637          	lui	a2,0xc000
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	f93ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001188:	4729                	li	a4,10
    8000118a:	80006697          	auipc	a3,0x80006
    8000118e:	e7668693          	addi	a3,a3,-394 # 7000 <_entry-0x7fff9000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00006697          	auipc	a3,0x6
    800011a4:	e6068693          	addi	a3,a3,-416 # 80007000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00006617          	auipc	a2,0x6
    800011b4:	e5060613          	addi	a2,a2,-432 # 80007000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00005617          	auipc	a2,0x5
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80006000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	5c4000ef          	jal	800017a0 <proc_mapstacks>
}
    800011e0:	8526                	mv	a0,s1
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <kvminit>:
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e406                	sd	ra,8(sp)
    800011f0:	e022                	sd	s0,0(sp)
    800011f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011f4:	f4bff0ef          	jal	8000113e <kvmmake>
    800011f8:	00006797          	auipc	a5,0x6
    800011fc:	68a7b023          	sd	a0,1664(a5) # 80007878 <kernel_pagetable>
}
    80001200:	60a2                	ld	ra,8(sp)
    80001202:	6402                	ld	s0,0(sp)
    80001204:	0141                	addi	sp,sp,16
    80001206:	8082                	ret

0000000080001208 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001212:	933ff0ef          	jal	80000b44 <kalloc>
    80001216:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001218:	c509                	beqz	a0,80001222 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	adbff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001236:	03459793          	slli	a5,a1,0x34
    8000123a:	e38d                	bnez	a5,8000125c <uvmunmap+0x2e>
    8000123c:	f04a                	sd	s2,32(sp)
    8000123e:	ec4e                	sd	s3,24(sp)
    80001240:	e852                	sd	s4,16(sp)
    80001242:	e456                	sd	s5,8(sp)
    80001244:	e05a                	sd	s6,0(sp)
    80001246:	8a2a                	mv	s4,a0
    80001248:	892e                	mv	s2,a1
    8000124a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000124c:	0632                	slli	a2,a2,0xc
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	6b05                	lui	s6,0x1
    80001254:	0535f963          	bgeu	a1,s3,800012a6 <uvmunmap+0x78>
    80001258:	f426                	sd	s1,40(sp)
    8000125a:	a015                	j	8000127e <uvmunmap+0x50>
    8000125c:	f426                	sd	s1,40(sp)
    8000125e:	f04a                	sd	s2,32(sp)
    80001260:	ec4e                	sd	s3,24(sp)
    80001262:	e852                	sd	s4,16(sp)
    80001264:	e456                	sd	s5,8(sp)
    80001266:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001268:	00006517          	auipc	a0,0x6
    8000126c:	eb850513          	addi	a0,a0,-328 # 80007120 <etext+0x120>
    80001270:	db4ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001274:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	995a                	add	s2,s2,s6
    8000127a:	03397563          	bgeu	s2,s3,800012a4 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000127e:	4601                	li	a2,0
    80001280:	85ca                	mv	a1,s2
    80001282:	8552                	mv	a0,s4
    80001284:	d09ff0ef          	jal	80000f8c <walk>
    80001288:	84aa                	mv	s1,a0
    8000128a:	d57d                	beqz	a0,80001278 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000128c:	611c                	ld	a5,0(a0)
    8000128e:	0017f713          	andi	a4,a5,1
    80001292:	d37d                	beqz	a4,80001278 <uvmunmap+0x4a>
    if(do_free){
    80001294:	fe0a80e3          	beqz	s5,80001274 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001298:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000129a:	00c79513          	slli	a0,a5,0xc
    8000129e:	fbeff0ef          	jal	80000a5c <kfree>
    800012a2:	bfc9                	j	80001274 <uvmunmap+0x46>
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
  }
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret

00000000800012b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012c4:	00b67d63          	bgeu	a2,a1,800012de <uvmdealloc+0x26>
    800012c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012ca:	6785                	lui	a5,0x1
    800012cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ce:	00f60733          	add	a4,a2,a5
    800012d2:	76fd                	lui	a3,0xfffff
    800012d4:	8f75                	and	a4,a4,a3
    800012d6:	97ae                	add	a5,a5,a1
    800012d8:	8ff5                	and	a5,a5,a3
    800012da:	00f76863          	bltu	a4,a5,800012ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012de:	8526                	mv	a0,s1
    800012e0:	60e2                	ld	ra,24(sp)
    800012e2:	6442                	ld	s0,16(sp)
    800012e4:	64a2                	ld	s1,8(sp)
    800012e6:	6105                	addi	sp,sp,32
    800012e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ea:	8f99                	sub	a5,a5,a4
    800012ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ee:	4685                	li	a3,1
    800012f0:	0007861b          	sext.w	a2,a5
    800012f4:	85ba                	mv	a1,a4
    800012f6:	f39ff0ef          	jal	8000122e <uvmunmap>
    800012fa:	b7d5                	j	800012de <uvmdealloc+0x26>

00000000800012fc <uvmalloc>:
  if(newsz < oldsz)
    800012fc:	0ab66163          	bltu	a2,a1,8000139e <uvmalloc+0xa2>
{
    80001300:	715d                	addi	sp,sp,-80
    80001302:	e486                	sd	ra,72(sp)
    80001304:	e0a2                	sd	s0,64(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e45e                	sd	s7,8(sp)
    8000130e:	0880                	addi	s0,sp,80
    80001310:	8aaa                	mv	s5,a0
    80001312:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001318:	95be                	add	a1,a1,a5
    8000131a:	77fd                	lui	a5,0xfffff
    8000131c:	00f5f933          	and	s2,a1,a5
    80001320:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001322:	08c97063          	bgeu	s2,a2,800013a2 <uvmalloc+0xa6>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000132c:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000132e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001332:	813ff0ef          	jal	80000b44 <kalloc>
    80001336:	84aa                	mv	s1,a0
    if(mem == 0){
    80001338:	c50d                	beqz	a0,80001362 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000133a:	864e                	mv	a2,s3
    8000133c:	4581                	li	a1,0
    8000133e:	9bbff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001342:	875a                	mv	a4,s6
    80001344:	86a6                	mv	a3,s1
    80001346:	864e                	mv	a2,s3
    80001348:	85ca                	mv	a1,s2
    8000134a:	8556                	mv	a0,s5
    8000134c:	d15ff0ef          	jal	80001060 <mappages>
    80001350:	e915                	bnez	a0,80001384 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001352:	994e                	add	s2,s2,s3
    80001354:	fd496fe3          	bltu	s2,s4,80001332 <uvmalloc+0x36>
  return newsz;
    80001358:	8552                	mv	a0,s4
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	79a2                	ld	s3,40(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	a811                	j	80001374 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001362:	865e                	mv	a2,s7
    80001364:	85ca                	mv	a1,s2
    80001366:	8556                	mv	a0,s5
    80001368:	f51ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    8000136c:	4501                	li	a0,0
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	79a2                	ld	s3,40(sp)
    80001372:	6b42                	ld	s6,16(sp)
}
    80001374:	60a6                	ld	ra,72(sp)
    80001376:	6406                	ld	s0,64(sp)
    80001378:	7942                	ld	s2,48(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
    80001380:	6161                	addi	sp,sp,80
    80001382:	8082                	ret
      kfree(mem);
    80001384:	8526                	mv	a0,s1
    80001386:	ed6ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000138a:	865e                	mv	a2,s7
    8000138c:	85ca                	mv	a1,s2
    8000138e:	8556                	mv	a0,s5
    80001390:	f29ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    80001394:	4501                	li	a0,0
    80001396:	74e2                	ld	s1,56(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	bfe1                	j	80001374 <uvmalloc+0x78>
    return oldsz;
    8000139e:	852e                	mv	a0,a1
}
    800013a0:	8082                	ret
  return newsz;
    800013a2:	8532                	mv	a0,a2
    800013a4:	bfc1                	j	80001374 <uvmalloc+0x78>

00000000800013a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	1800                	addi	s0,sp,48
    800013b4:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013b6:	84aa                	mv	s1,a0
    800013b8:	6905                	lui	s2,0x1
    800013ba:	992a                	add	s2,s2,a0
    800013bc:	a811                	j	800013d0 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013be:	00006517          	auipc	a0,0x6
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80007138 <etext+0x138>
    800013c6:	c5eff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	03248163          	beq	s1,s2,800013ee <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	db75                	beqz	a4,800013ca <freewalk+0x24>
    800013d8:	00e7f713          	andi	a4,a5,14
    800013dc:	f36d                	bnez	a4,800013be <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e0:	00c79513          	slli	a0,a5,0xc
    800013e4:	fc3ff0ef          	jal	800013a6 <freewalk>
      pagetable[i] = 0;
    800013e8:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013ec:	bff9                	j	800013ca <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013ee:	854e                	mv	a0,s3
    800013f0:	e6cff0ef          	jal	80000a5c <kfree>
}
    800013f4:	70a2                	ld	ra,40(sp)
    800013f6:	7402                	ld	s0,32(sp)
    800013f8:	64e2                	ld	s1,24(sp)
    800013fa:	6942                	ld	s2,16(sp)
    800013fc:	69a2                	ld	s3,8(sp)
    800013fe:	6145                	addi	sp,sp,48
    80001400:	8082                	ret

0000000080001402 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001402:	1101                	addi	sp,sp,-32
    80001404:	ec06                	sd	ra,24(sp)
    80001406:	e822                	sd	s0,16(sp)
    80001408:	e426                	sd	s1,8(sp)
    8000140a:	1000                	addi	s0,sp,32
    8000140c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000140e:	e989                	bnez	a1,80001420 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001410:	8526                	mv	a0,s1
    80001412:	f95ff0ef          	jal	800013a6 <freewalk>
}
    80001416:	60e2                	ld	ra,24(sp)
    80001418:	6442                	ld	s0,16(sp)
    8000141a:	64a2                	ld	s1,8(sp)
    8000141c:	6105                	addi	sp,sp,32
    8000141e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	4685                	li	a3,1
    80001428:	00c5d613          	srli	a2,a1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	e01ff0ef          	jal	8000122e <uvmunmap>
    80001432:	bff9                	j	80001410 <uvmfree+0xe>

0000000080001434 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001434:	ca59                	beqz	a2,800014ca <uvmcopy+0x96>
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
    8000144c:	8b2a                	mv	s6,a0
    8000144e:	8bae                	mv	s7,a1
    80001450:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001452:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001454:	6a05                	lui	s4,0x1
    80001456:	a021                	j	8000145e <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001458:	94d2                	add	s1,s1,s4
    8000145a:	0554fc63          	bgeu	s1,s5,800014b2 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85a6                	mv	a1,s1
    80001462:	855a                	mv	a0,s6
    80001464:	b29ff0ef          	jal	80000f8c <walk>
    80001468:	d965                	beqz	a0,80001458 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    8000146a:	00053983          	ld	s3,0(a0)
    8000146e:	0019f793          	andi	a5,s3,1
    80001472:	d3fd                	beqz	a5,80001458 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001474:	ed0ff0ef          	jal	80000b44 <kalloc>
    80001478:	892a                	mv	s2,a0
    8000147a:	c11d                	beqz	a0,800014a0 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000147c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001480:	8652                	mv	a2,s4
    80001482:	05b2                	slli	a1,a1,0xc
    80001484:	8d5ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001488:	3ff9f713          	andi	a4,s3,1023
    8000148c:	86ca                	mv	a3,s2
    8000148e:	8652                	mv	a2,s4
    80001490:	85a6                	mv	a1,s1
    80001492:	855e                	mv	a0,s7
    80001494:	bcdff0ef          	jal	80001060 <mappages>
    80001498:	d161                	beqz	a0,80001458 <uvmcopy+0x24>
      kfree(mem);
    8000149a:	854a                	mv	a0,s2
    8000149c:	dc0ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a0:	4685                	li	a3,1
    800014a2:	00c4d613          	srli	a2,s1,0xc
    800014a6:	4581                	li	a1,0
    800014a8:	855e                	mv	a0,s7
    800014aa:	d85ff0ef          	jal	8000122e <uvmunmap>
  return -1;
    800014ae:	557d                	li	a0,-1
    800014b0:	a011                	j	800014b4 <uvmcopy+0x80>
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	60a6                	ld	ra,72(sp)
    800014b6:	6406                	ld	s0,64(sp)
    800014b8:	74e2                	ld	s1,56(sp)
    800014ba:	7942                	ld	s2,48(sp)
    800014bc:	79a2                	ld	s3,40(sp)
    800014be:	7a02                	ld	s4,32(sp)
    800014c0:	6ae2                	ld	s5,24(sp)
    800014c2:	6b42                	ld	s6,16(sp)
    800014c4:	6ba2                	ld	s7,8(sp)
    800014c6:	6161                	addi	sp,sp,80
    800014c8:	8082                	ret
  return 0;
    800014ca:	4501                	li	a0,0
}
    800014cc:	8082                	ret

00000000800014ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ce:	1141                	addi	sp,sp,-16
    800014d0:	e406                	sd	ra,8(sp)
    800014d2:	e022                	sd	s0,0(sp)
    800014d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d6:	4601                	li	a2,0
    800014d8:	ab5ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014dc:	c901                	beqz	a0,800014ec <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014de:	611c                	ld	a5,0(a0)
    800014e0:	9bbd                	andi	a5,a5,-17
    800014e2:	e11c                	sd	a5,0(a0)
}
    800014e4:	60a2                	ld	ra,8(sp)
    800014e6:	6402                	ld	s0,0(sp)
    800014e8:	0141                	addi	sp,sp,16
    800014ea:	8082                	ret
    panic("uvmclear");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80007148 <etext+0x148>
    800014f4:	b30ff0ef          	jal	80000824 <panic>

00000000800014f8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014f8:	cac5                	beqz	a3,800015a8 <copyinstr+0xb0>
{
    800014fa:	715d                	addi	sp,sp,-80
    800014fc:	e486                	sd	ra,72(sp)
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	fc26                	sd	s1,56(sp)
    80001502:	f84a                	sd	s2,48(sp)
    80001504:	f44e                	sd	s3,40(sp)
    80001506:	f052                	sd	s4,32(sp)
    80001508:	ec56                	sd	s5,24(sp)
    8000150a:	e85a                	sd	s6,16(sp)
    8000150c:	e45e                	sd	s7,8(sp)
    8000150e:	0880                	addi	s0,sp,80
    80001510:	8aaa                	mv	s5,a0
    80001512:	84ae                	mv	s1,a1
    80001514:	8bb2                	mv	s7,a2
    80001516:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001518:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000151a:	6a05                	lui	s4,0x1
    8000151c:	a82d                	j	80001556 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000151e:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001522:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001524:	0017c793          	xori	a5,a5,1
    80001528:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000152c:	60a6                	ld	ra,72(sp)
    8000152e:	6406                	ld	s0,64(sp)
    80001530:	74e2                	ld	s1,56(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	79a2                	ld	s3,40(sp)
    80001536:	7a02                	ld	s4,32(sp)
    80001538:	6ae2                	ld	s5,24(sp)
    8000153a:	6b42                	ld	s6,16(sp)
    8000153c:	6ba2                	ld	s7,8(sp)
    8000153e:	6161                	addi	sp,sp,80
    80001540:	8082                	ret
    80001542:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001546:	9726                	add	a4,a4,s1
      --max;
    80001548:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000154c:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001550:	04e58463          	beq	a1,a4,80001598 <copyinstr+0xa0>
{
    80001554:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001556:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8556                	mv	a0,s5
    8000155e:	ac9ff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0)
    80001562:	cd0d                	beqz	a0,8000159c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001564:	417906b3          	sub	a3,s2,s7
    80001568:	96d2                	add	a3,a3,s4
    if(n > max)
    8000156a:	00d9f363          	bgeu	s3,a3,80001570 <copyinstr+0x78>
    8000156e:	86ce                	mv	a3,s3
    while(n > 0){
    80001570:	ca85                	beqz	a3,800015a0 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001572:	01750633          	add	a2,a0,s7
    80001576:	41260633          	sub	a2,a2,s2
    8000157a:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000157c:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000157e:	96a6                	add	a3,a3,s1
    80001580:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001582:	00f60733          	add	a4,a2,a5
    80001586:	00074703          	lbu	a4,0(a4)
    8000158a:	db51                	beqz	a4,8000151e <copyinstr+0x26>
        *dst = *p;
    8000158c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001590:	0785                	addi	a5,a5,1
    while(n > 0){
    80001592:	fed797e3          	bne	a5,a3,80001580 <copyinstr+0x88>
    80001596:	b775                	j	80001542 <copyinstr+0x4a>
    80001598:	4781                	li	a5,0
    8000159a:	b769                	j	80001524 <copyinstr+0x2c>
      return -1;
    8000159c:	557d                	li	a0,-1
    8000159e:	b779                	j	8000152c <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a0:	6b85                	lui	s7,0x1
    800015a2:	9bca                	add	s7,s7,s2
    800015a4:	87a6                	mv	a5,s1
    800015a6:	b77d                	j	80001554 <copyinstr+0x5c>
  int got_null = 0;
    800015a8:	4781                	li	a5,0
  if(got_null){
    800015aa:	0017c793          	xori	a5,a5,1
    800015ae:	40f0053b          	negw	a0,a5
}
    800015b2:	8082                	ret

00000000800015b4 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015b4:	1141                	addi	sp,sp,-16
    800015b6:	e406                	sd	ra,8(sp)
    800015b8:	e022                	sd	s0,0(sp)
    800015ba:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015bc:	4601                	li	a2,0
    800015be:	9cfff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015c2:	c119                	beqz	a0,800015c8 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015c4:	6108                	ld	a0,0(a0)
    800015c6:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015c8:	60a2                	ld	ra,8(sp)
    800015ca:	6402                	ld	s0,0(sp)
    800015cc:	0141                	addi	sp,sp,16
    800015ce:	8082                	ret

00000000800015d0 <vmfault>:
{
    800015d0:	7179                	addi	sp,sp,-48
    800015d2:	f406                	sd	ra,40(sp)
    800015d4:	f022                	sd	s0,32(sp)
    800015d6:	e84a                	sd	s2,16(sp)
    800015d8:	e44e                	sd	s3,8(sp)
    800015da:	1800                	addi	s0,sp,48
    800015dc:	89aa                	mv	s3,a0
    800015de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e0:	356000ef          	jal	80001936 <myproc>
  if (va >= p->sz)
    800015e4:	653c                	ld	a5,72(a0)
    800015e6:	00f96a63          	bltu	s2,a5,800015fa <vmfault+0x2a>
    return 0;
    800015ea:	4981                	li	s3,0
}
    800015ec:	854e                	mv	a0,s3
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    800015fa:	ec26                	sd	s1,24(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001600:	77fd                	lui	a5,0xfffff
    80001602:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001606:	85d2                	mv	a1,s4
    80001608:	854e                	mv	a0,s3
    8000160a:	fabff0ef          	jal	800015b4 <ismapped>
    return 0;
    8000160e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001610:	c501                	beqz	a0,80001618 <vmfault+0x48>
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	bfd9                	j	800015ec <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001618:	d2cff0ef          	jal	80000b44 <kalloc>
    8000161c:	892a                	mv	s2,a0
  if(mem == 0)
    8000161e:	c905                	beqz	a0,8000164e <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001620:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001622:	6605                	lui	a2,0x1
    80001624:	4581                	li	a1,0
    80001626:	ed2ff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000162a:	4759                	li	a4,22
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85d2                	mv	a1,s4
    80001632:	68a8                	ld	a0,80(s1)
    80001634:	a2dff0ef          	jal	80001060 <mappages>
    80001638:	e501                	bnez	a0,80001640 <vmfault+0x70>
    8000163a:	64e2                	ld	s1,24(sp)
    8000163c:	6a02                	ld	s4,0(sp)
    8000163e:	b77d                	j	800015ec <vmfault+0x1c>
    kfree((void *)mem);
    80001640:	854a                	mv	a0,s2
    80001642:	c1aff0ef          	jal	80000a5c <kfree>
    return 0;
    80001646:	4981                	li	s3,0
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	b745                	j	800015ec <vmfault+0x1c>
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6a02                	ld	s4,0(sp)
    80001652:	bf69                	j	800015ec <vmfault+0x1c>

0000000080001654 <copyout>:
  while(len > 0){
    80001654:	cad1                	beqz	a3,800016e8 <copyout+0x94>
{
    80001656:	711d                	addi	sp,sp,-96
    80001658:	ec86                	sd	ra,88(sp)
    8000165a:	e8a2                	sd	s0,80(sp)
    8000165c:	e4a6                	sd	s1,72(sp)
    8000165e:	e0ca                	sd	s2,64(sp)
    80001660:	fc4e                	sd	s3,56(sp)
    80001662:	f852                	sd	s4,48(sp)
    80001664:	f456                	sd	s5,40(sp)
    80001666:	f05a                	sd	s6,32(sp)
    80001668:	ec5e                	sd	s7,24(sp)
    8000166a:	e862                	sd	s8,16(sp)
    8000166c:	e466                	sd	s9,8(sp)
    8000166e:	e06a                	sd	s10,0(sp)
    80001670:	1080                	addi	s0,sp,96
    80001672:	8baa                	mv	s7,a0
    80001674:	8a2e                	mv	s4,a1
    80001676:	8b32                	mv	s6,a2
    80001678:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000167c:	5cfd                	li	s9,-1
    8000167e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001682:	6c05                	lui	s8,0x1
    80001684:	a005                	j	800016a4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001686:	409a0533          	sub	a0,s4,s1
    8000168a:	0009061b          	sext.w	a2,s2
    8000168e:	85da                	mv	a1,s6
    80001690:	954e                	add	a0,a0,s3
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001696:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000169a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000169c:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a0:	040a8263          	beqz	s5,800016e4 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016a8:	049ce263          	bltu	s9,s1,800016ec <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ac:	85a6                	mv	a1,s1
    800016ae:	855e                	mv	a0,s7
    800016b0:	977ff0ef          	jal	80001026 <walkaddr>
    800016b4:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016b6:	e901                	bnez	a0,800016c6 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016b8:	4601                	li	a2,0
    800016ba:	85a6                	mv	a1,s1
    800016bc:	855e                	mv	a0,s7
    800016be:	f13ff0ef          	jal	800015d0 <vmfault>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c139                	beqz	a0,8000170a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	855e                	mv	a0,s7
    800016cc:	8c1ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	8b91                	andi	a5,a5,4
    800016d4:	cf8d                	beqz	a5,8000170e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016d6:	41448933          	sub	s2,s1,s4
    800016da:	9962                	add	s2,s2,s8
    if(n > len)
    800016dc:	fb2af5e3          	bgeu	s5,s2,80001686 <copyout+0x32>
    800016e0:	8956                	mv	s2,s5
    800016e2:	b755                	j	80001686 <copyout+0x32>
  return 0;
    800016e4:	4501                	li	a0,0
    800016e6:	a021                	j	800016ee <copyout+0x9a>
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret
      return -1;
    800016ec:	557d                	li	a0,-1
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	6906                	ld	s2,64(sp)
    800016f6:	79e2                	ld	s3,56(sp)
    800016f8:	7a42                	ld	s4,48(sp)
    800016fa:	7aa2                	ld	s5,40(sp)
    800016fc:	7b02                	ld	s6,32(sp)
    800016fe:	6be2                	ld	s7,24(sp)
    80001700:	6c42                	ld	s8,16(sp)
    80001702:	6ca2                	ld	s9,8(sp)
    80001704:	6d02                	ld	s10,0(sp)
    80001706:	6125                	addi	sp,sp,96
    80001708:	8082                	ret
        return -1;
    8000170a:	557d                	li	a0,-1
    8000170c:	b7cd                	j	800016ee <copyout+0x9a>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	bff9                	j	800016ee <copyout+0x9a>

0000000080001712 <copyin>:
  while(len > 0){
    80001712:	c6c9                	beqz	a3,8000179c <copyin+0x8a>
{
    80001714:	715d                	addi	sp,sp,-80
    80001716:	e486                	sd	ra,72(sp)
    80001718:	e0a2                	sd	s0,64(sp)
    8000171a:	fc26                	sd	s1,56(sp)
    8000171c:	f84a                	sd	s2,48(sp)
    8000171e:	f44e                	sd	s3,40(sp)
    80001720:	f052                	sd	s4,32(sp)
    80001722:	ec56                	sd	s5,24(sp)
    80001724:	e85a                	sd	s6,16(sp)
    80001726:	e45e                	sd	s7,8(sp)
    80001728:	e062                	sd	s8,0(sp)
    8000172a:	0880                	addi	s0,sp,80
    8000172c:	8baa                	mv	s7,a0
    8000172e:	8aae                	mv	s5,a1
    80001730:	8932                	mv	s2,a2
    80001732:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001734:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001736:	6b05                	lui	s6,0x1
    80001738:	a035                	j	80001764 <copyin+0x52>
    8000173a:	412984b3          	sub	s1,s3,s2
    8000173e:	94da                	add	s1,s1,s6
    if(n > len)
    80001740:	009a7363          	bgeu	s4,s1,80001746 <copyin+0x34>
    80001744:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	413905b3          	sub	a1,s2,s3
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	95aa                	add	a1,a1,a0
    80001750:	8556                	mv	a0,s5
    80001752:	e06ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001756:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000175a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000175c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001760:	020a0163          	beqz	s4,80001782 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001764:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ce                	mv	a1,s3
    8000176a:	855e                	mv	a0,s7
    8000176c:	8bbff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0) {
    80001770:	f569                	bnez	a0,8000173a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001772:	4601                	li	a2,0
    80001774:	85ce                	mv	a1,s3
    80001776:	855e                	mv	a0,s7
    80001778:	e59ff0ef          	jal	800015d0 <vmfault>
    8000177c:	fd5d                	bnez	a0,8000173a <copyin+0x28>
        return -1;
    8000177e:	557d                	li	a0,-1
    80001780:	a011                	j	80001784 <copyin+0x72>
  return 0;
    80001782:	4501                	li	a0,0
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret
  return 0;
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret

00000000800017a0 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017a0:	715d                	addi	sp,sp,-80
    800017a2:	e486                	sd	ra,72(sp)
    800017a4:	e0a2                	sd	s0,64(sp)
    800017a6:	fc26                	sd	s1,56(sp)
    800017a8:	f84a                	sd	s2,48(sp)
    800017aa:	f44e                	sd	s3,40(sp)
    800017ac:	f052                	sd	s4,32(sp)
    800017ae:	ec56                	sd	s5,24(sp)
    800017b0:	e85a                	sd	s6,16(sp)
    800017b2:	e45e                	sd	s7,8(sp)
    800017b4:	e062                	sd	s8,0(sp)
    800017b6:	0880                	addi	s0,sp,80
    800017b8:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ba:	0000e497          	auipc	s1,0xe
    800017be:	62648493          	addi	s1,s1,1574 # 8000fde0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017c2:	8c26                	mv	s8,s1
    800017c4:	677d47b7          	lui	a5,0x677d4
    800017c8:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    800017cc:	51b3c937          	lui	s2,0x51b3c
    800017d0:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    800017d4:	1902                	slli	s2,s2,0x20
    800017d6:	993e                	add	s2,s2,a5
    800017d8:	040009b7          	lui	s3,0x4000
    800017dc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017de:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e0:	4b99                	li	s7,6
    800017e2:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e4:	00014a97          	auipc	s5,0x14
    800017e8:	3fca8a93          	addi	s5,s5,1020 # 80015be0 <tickslock>
    char *pa = kalloc();
    800017ec:	b58ff0ef          	jal	80000b44 <kalloc>
    800017f0:	862a                	mv	a2,a0
    if(pa == 0)
    800017f2:	c121                	beqz	a0,80001832 <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017f4:	418485b3          	sub	a1,s1,s8
    800017f8:	858d                	srai	a1,a1,0x3
    800017fa:	032585b3          	mul	a1,a1,s2
    800017fe:	05b6                	slli	a1,a1,0xd
    80001800:	6789                	lui	a5,0x2
    80001802:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001804:	875e                	mv	a4,s7
    80001806:	86da                	mv	a3,s6
    80001808:	40b985b3          	sub	a1,s3,a1
    8000180c:	8552                	mv	a0,s4
    8000180e:	909ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001812:	17848493          	addi	s1,s1,376
    80001816:	fd549be3          	bne	s1,s5,800017ec <proc_mapstacks+0x4c>
  }
}
    8000181a:	60a6                	ld	ra,72(sp)
    8000181c:	6406                	ld	s0,64(sp)
    8000181e:	74e2                	ld	s1,56(sp)
    80001820:	7942                	ld	s2,48(sp)
    80001822:	79a2                	ld	s3,40(sp)
    80001824:	7a02                	ld	s4,32(sp)
    80001826:	6ae2                	ld	s5,24(sp)
    80001828:	6b42                	ld	s6,16(sp)
    8000182a:	6ba2                	ld	s7,8(sp)
    8000182c:	6c02                	ld	s8,0(sp)
    8000182e:	6161                	addi	sp,sp,80
    80001830:	8082                	ret
      panic("kalloc");
    80001832:	00006517          	auipc	a0,0x6
    80001836:	92650513          	addi	a0,a0,-1754 # 80007158 <etext+0x158>
    8000183a:	febfe0ef          	jal	80000824 <panic>

000000008000183e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001852:	00006597          	auipc	a1,0x6
    80001856:	90e58593          	addi	a1,a1,-1778 # 80007160 <etext+0x160>
    8000185a:	0000e517          	auipc	a0,0xe
    8000185e:	13e50513          	addi	a0,a0,318 # 8000f998 <pid_lock>
    80001862:	b3cff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001866:	00006597          	auipc	a1,0x6
    8000186a:	90258593          	addi	a1,a1,-1790 # 80007168 <etext+0x168>
    8000186e:	0000e517          	auipc	a0,0xe
    80001872:	14250513          	addi	a0,a0,322 # 8000f9b0 <wait_lock>
    80001876:	b28ff0ef          	jal	80000b9e <initlock>
  initlock(&mlfq_lock, "mlfq");
    8000187a:	00006597          	auipc	a1,0x6
    8000187e:	8fe58593          	addi	a1,a1,-1794 # 80007178 <etext+0x178>
    80001882:	0000e517          	auipc	a0,0xe
    80001886:	14650513          	addi	a0,a0,326 # 8000f9c8 <mlfq_lock>
    8000188a:	b14ff0ef          	jal	80000b9e <initlock>
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188e:	0000e497          	auipc	s1,0xe
    80001892:	55248493          	addi	s1,s1,1362 # 8000fde0 <proc>
      initlock(&p->lock, "proc");
    80001896:	00006b17          	auipc	s6,0x6
    8000189a:	8eab0b13          	addi	s6,s6,-1814 # 80007180 <etext+0x180>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000189e:	8aa6                	mv	s5,s1
    800018a0:	677d47b7          	lui	a5,0x677d4
    800018a4:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    800018a8:	51b3c937          	lui	s2,0x51b3c
    800018ac:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    800018b0:	1902                	slli	s2,s2,0x20
    800018b2:	993e                	add	s2,s2,a5
    800018b4:	040009b7          	lui	s3,0x4000
    800018b8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018ba:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018bc:	00014a17          	auipc	s4,0x14
    800018c0:	324a0a13          	addi	s4,s4,804 # 80015be0 <tickslock>
      initlock(&p->lock, "proc");
    800018c4:	85da                	mv	a1,s6
    800018c6:	8526                	mv	a0,s1
    800018c8:	ad6ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    800018cc:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018d0:	415487b3          	sub	a5,s1,s5
    800018d4:	878d                	srai	a5,a5,0x3
    800018d6:	032787b3          	mul	a5,a5,s2
    800018da:	07b6                	slli	a5,a5,0xd
    800018dc:	6709                	lui	a4,0x2
    800018de:	9fb9                	addw	a5,a5,a4
    800018e0:	40f987b3          	sub	a5,s3,a5
    800018e4:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	17848493          	addi	s1,s1,376
    800018ea:	fd449de3          	bne	s1,s4,800018c4 <procinit+0x86>
  }
}
    800018ee:	70e2                	ld	ra,56(sp)
    800018f0:	7442                	ld	s0,48(sp)
    800018f2:	74a2                	ld	s1,40(sp)
    800018f4:	7902                	ld	s2,32(sp)
    800018f6:	69e2                	ld	s3,24(sp)
    800018f8:	6a42                	ld	s4,16(sp)
    800018fa:	6aa2                	ld	s5,8(sp)
    800018fc:	6b02                	ld	s6,0(sp)
    800018fe:	6121                	addi	sp,sp,64
    80001900:	8082                	ret

0000000080001902 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001902:	1141                	addi	sp,sp,-16
    80001904:	e406                	sd	ra,8(sp)
    80001906:	e022                	sd	s0,0(sp)
    80001908:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000190a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000190c:	2501                	sext.w	a0,a0
    8000190e:	60a2                	ld	ra,8(sp)
    80001910:	6402                	ld	s0,0(sp)
    80001912:	0141                	addi	sp,sp,16
    80001914:	8082                	ret

0000000080001916 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001916:	1141                	addi	sp,sp,-16
    80001918:	e406                	sd	ra,8(sp)
    8000191a:	e022                	sd	s0,0(sp)
    8000191c:	0800                	addi	s0,sp,16
    8000191e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001920:	2781                	sext.w	a5,a5
    80001922:	079e                	slli	a5,a5,0x7
  return c;
}
    80001924:	0000e517          	auipc	a0,0xe
    80001928:	0bc50513          	addi	a0,a0,188 # 8000f9e0 <cpus>
    8000192c:	953e                	add	a0,a0,a5
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret

0000000080001936 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001936:	1101                	addi	sp,sp,-32
    80001938:	ec06                	sd	ra,24(sp)
    8000193a:	e822                	sd	s0,16(sp)
    8000193c:	e426                	sd	s1,8(sp)
    8000193e:	1000                	addi	s0,sp,32
  push_off();
    80001940:	aa4ff0ef          	jal	80000be4 <push_off>
    80001944:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001946:	2781                	sext.w	a5,a5
    80001948:	079e                	slli	a5,a5,0x7
    8000194a:	0000e717          	auipc	a4,0xe
    8000194e:	04e70713          	addi	a4,a4,78 # 8000f998 <pid_lock>
    80001952:	97ba                	add	a5,a5,a4
    80001954:	67bc                	ld	a5,72(a5)
    80001956:	84be                	mv	s1,a5
  pop_off();
    80001958:	b14ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    8000195c:	8526                	mv	a0,s1
    8000195e:	60e2                	ld	ra,24(sp)
    80001960:	6442                	ld	s0,16(sp)
    80001962:	64a2                	ld	s1,8(sp)
    80001964:	6105                	addi	sp,sp,32
    80001966:	8082                	ret

0000000080001968 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001968:	7179                	addi	sp,sp,-48
    8000196a:	f406                	sd	ra,40(sp)
    8000196c:	f022                	sd	s0,32(sp)
    8000196e:	ec26                	sd	s1,24(sp)
    80001970:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001972:	fc5ff0ef          	jal	80001936 <myproc>
    80001976:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001978:	b44ff0ef          	jal	80000cbc <release>

  if (first) {
    8000197c:	00006797          	auipc	a5,0x6
    80001980:	ec47a783          	lw	a5,-316(a5) # 80007840 <first.1>
    80001984:	cf95                	beqz	a5,800019c0 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001986:	4505                	li	a0,1
    80001988:	4eb010ef          	jal	80003672 <fsinit>

    first = 0;
    8000198c:	00006797          	auipc	a5,0x6
    80001990:	ea07aa23          	sw	zero,-332(a5) # 80007840 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001994:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001998:	00005797          	auipc	a5,0x5
    8000199c:	7f078793          	addi	a5,a5,2032 # 80007188 <etext+0x188>
    800019a0:	fcf43823          	sd	a5,-48(s0)
    800019a4:	fc043c23          	sd	zero,-40(s0)
    800019a8:	fd040593          	addi	a1,s0,-48
    800019ac:	853e                	mv	a0,a5
    800019ae:	64d020ef          	jal	800047fa <kexec>
    800019b2:	6cbc                	ld	a5,88(s1)
    800019b4:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019b6:	6cbc                	ld	a5,88(s1)
    800019b8:	7bb8                	ld	a4,112(a5)
    800019ba:	57fd                	li	a5,-1
    800019bc:	02f70d63          	beq	a4,a5,800019f6 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019c0:	37f000ef          	jal	8000253e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019c4:	68a8                	ld	a0,80(s1)
    800019c6:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019c8:	04000737          	lui	a4,0x4000
    800019cc:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019ce:	0732                	slli	a4,a4,0xc
    800019d0:	00004797          	auipc	a5,0x4
    800019d4:	6cc78793          	addi	a5,a5,1740 # 8000609c <userret>
    800019d8:	00004697          	auipc	a3,0x4
    800019dc:	62868693          	addi	a3,a3,1576 # 80006000 <_trampoline>
    800019e0:	8f95                	sub	a5,a5,a3
    800019e2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019e4:	577d                	li	a4,-1
    800019e6:	177e                	slli	a4,a4,0x3f
    800019e8:	8d59                	or	a0,a0,a4
    800019ea:	9782                	jalr	a5
}
    800019ec:	70a2                	ld	ra,40(sp)
    800019ee:	7402                	ld	s0,32(sp)
    800019f0:	64e2                	ld	s1,24(sp)
    800019f2:	6145                	addi	sp,sp,48
    800019f4:	8082                	ret
      panic("exec");
    800019f6:	00005517          	auipc	a0,0x5
    800019fa:	79a50513          	addi	a0,a0,1946 # 80007190 <etext+0x190>
    800019fe:	e27fe0ef          	jal	80000824 <panic>

0000000080001a02 <allocpid>:
{
    80001a02:	1101                	addi	sp,sp,-32
    80001a04:	ec06                	sd	ra,24(sp)
    80001a06:	e822                	sd	s0,16(sp)
    80001a08:	e426                	sd	s1,8(sp)
    80001a0a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a0c:	0000e517          	auipc	a0,0xe
    80001a10:	f8c50513          	addi	a0,a0,-116 # 8000f998 <pid_lock>
    80001a14:	a14ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a18:	00006797          	auipc	a5,0x6
    80001a1c:	e2c78793          	addi	a5,a5,-468 # 80007844 <nextpid>
    80001a20:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a22:	0014871b          	addiw	a4,s1,1
    80001a26:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a28:	0000e517          	auipc	a0,0xe
    80001a2c:	f7050513          	addi	a0,a0,-144 # 8000f998 <pid_lock>
    80001a30:	a8cff0ef          	jal	80000cbc <release>
}
    80001a34:	8526                	mv	a0,s1
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6105                	addi	sp,sp,32
    80001a3e:	8082                	ret

0000000080001a40 <proc_pagetable>:
{
    80001a40:	1101                	addi	sp,sp,-32
    80001a42:	ec06                	sd	ra,24(sp)
    80001a44:	e822                	sd	s0,16(sp)
    80001a46:	e426                	sd	s1,8(sp)
    80001a48:	e04a                	sd	s2,0(sp)
    80001a4a:	1000                	addi	s0,sp,32
    80001a4c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a4e:	fbaff0ef          	jal	80001208 <uvmcreate>
    80001a52:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a54:	cd05                	beqz	a0,80001a8c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a56:	4729                	li	a4,10
    80001a58:	00004697          	auipc	a3,0x4
    80001a5c:	5a868693          	addi	a3,a3,1448 # 80006000 <_trampoline>
    80001a60:	6605                	lui	a2,0x1
    80001a62:	040005b7          	lui	a1,0x4000
    80001a66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a68:	05b2                	slli	a1,a1,0xc
    80001a6a:	df6ff0ef          	jal	80001060 <mappages>
    80001a6e:	02054663          	bltz	a0,80001a9a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a72:	4719                	li	a4,6
    80001a74:	05893683          	ld	a3,88(s2)
    80001a78:	6605                	lui	a2,0x1
    80001a7a:	020005b7          	lui	a1,0x2000
    80001a7e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a80:	05b6                	slli	a1,a1,0xd
    80001a82:	8526                	mv	a0,s1
    80001a84:	ddcff0ef          	jal	80001060 <mappages>
    80001a88:	00054f63          	bltz	a0,80001aa6 <proc_pagetable+0x66>
}
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	60e2                	ld	ra,24(sp)
    80001a90:	6442                	ld	s0,16(sp)
    80001a92:	64a2                	ld	s1,8(sp)
    80001a94:	6902                	ld	s2,0(sp)
    80001a96:	6105                	addi	sp,sp,32
    80001a98:	8082                	ret
    uvmfree(pagetable, 0);
    80001a9a:	4581                	li	a1,0
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	965ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001aa2:	4481                	li	s1,0
    80001aa4:	b7e5                	j	80001a8c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa6:	4681                	li	a3,0
    80001aa8:	4605                	li	a2,1
    80001aaa:	040005b7          	lui	a1,0x4000
    80001aae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ab0:	05b2                	slli	a1,a1,0xc
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	f7aff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001ab8:	4581                	li	a1,0
    80001aba:	8526                	mv	a0,s1
    80001abc:	947ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001ac0:	4481                	li	s1,0
    80001ac2:	b7e9                	j	80001a8c <proc_pagetable+0x4c>

0000000080001ac4 <proc_freepagetable>:
{
    80001ac4:	1101                	addi	sp,sp,-32
    80001ac6:	ec06                	sd	ra,24(sp)
    80001ac8:	e822                	sd	s0,16(sp)
    80001aca:	e426                	sd	s1,8(sp)
    80001acc:	e04a                	sd	s2,0(sp)
    80001ace:	1000                	addi	s0,sp,32
    80001ad0:	84aa                	mv	s1,a0
    80001ad2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad4:	4681                	li	a3,0
    80001ad6:	4605                	li	a2,1
    80001ad8:	040005b7          	lui	a1,0x4000
    80001adc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ade:	05b2                	slli	a1,a1,0xc
    80001ae0:	f4eff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ae4:	4681                	li	a3,0
    80001ae6:	4605                	li	a2,1
    80001ae8:	020005b7          	lui	a1,0x2000
    80001aec:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aee:	05b6                	slli	a1,a1,0xd
    80001af0:	8526                	mv	a0,s1
    80001af2:	f3cff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001af6:	85ca                	mv	a1,s2
    80001af8:	8526                	mv	a0,s1
    80001afa:	909ff0ef          	jal	80001402 <uvmfree>
}
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6902                	ld	s2,0(sp)
    80001b06:	6105                	addi	sp,sp,32
    80001b08:	8082                	ret

0000000080001b0a <freeproc>:
{
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	1000                	addi	s0,sp,32
    80001b14:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b16:	6d28                	ld	a0,88(a0)
    80001b18:	c119                	beqz	a0,80001b1e <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b1a:	f43fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b1e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b22:	68a8                	ld	a0,80(s1)
    80001b24:	c501                	beqz	a0,80001b2c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b26:	64ac                	ld	a1,72(s1)
    80001b28:	f9dff0ef          	jal	80001ac4 <proc_freepagetable>
  p->pagetable = 0;
    80001b2c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b30:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b34:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b38:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b3c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b40:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b44:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b48:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b4c:	0004ac23          	sw	zero,24(s1)
}
    80001b50:	60e2                	ld	ra,24(sp)
    80001b52:	6442                	ld	s0,16(sp)
    80001b54:	64a2                	ld	s1,8(sp)
    80001b56:	6105                	addi	sp,sp,32
    80001b58:	8082                	ret

0000000080001b5a <allocproc>:
{
    80001b5a:	1101                	addi	sp,sp,-32
    80001b5c:	ec06                	sd	ra,24(sp)
    80001b5e:	e822                	sd	s0,16(sp)
    80001b60:	e426                	sd	s1,8(sp)
    80001b62:	e04a                	sd	s2,0(sp)
    80001b64:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b66:	0000e497          	auipc	s1,0xe
    80001b6a:	27a48493          	addi	s1,s1,634 # 8000fde0 <proc>
    80001b6e:	00014917          	auipc	s2,0x14
    80001b72:	07290913          	addi	s2,s2,114 # 80015be0 <tickslock>
    acquire(&p->lock);
    80001b76:	8526                	mv	a0,s1
    80001b78:	8b0ff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001b7c:	4c9c                	lw	a5,24(s1)
    80001b7e:	cb91                	beqz	a5,80001b92 <allocproc+0x38>
      release(&p->lock);
    80001b80:	8526                	mv	a0,s1
    80001b82:	93aff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b86:	17848493          	addi	s1,s1,376
    80001b8a:	ff2496e3          	bne	s1,s2,80001b76 <allocproc+0x1c>
  return 0;
    80001b8e:	4481                	li	s1,0
    80001b90:	a0b9                	j	80001bde <allocproc+0x84>
  p->pid = allocpid();
    80001b92:	e71ff0ef          	jal	80001a02 <allocpid>
    80001b96:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b98:	4785                	li	a5,1
    80001b9a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b9c:	fa9fe0ef          	jal	80000b44 <kalloc>
    80001ba0:	892a                	mv	s2,a0
    80001ba2:	eca8                	sd	a0,88(s1)
    80001ba4:	c521                	beqz	a0,80001bec <allocproc+0x92>
  p->pagetable = proc_pagetable(p);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	e99ff0ef          	jal	80001a40 <proc_pagetable>
    80001bac:	892a                	mv	s2,a0
    80001bae:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001bb0:	c531                	beqz	a0,80001bfc <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80001bb2:	07000613          	li	a2,112
    80001bb6:	4581                	li	a1,0
    80001bb8:	06048513          	addi	a0,s1,96
    80001bbc:	93cff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001bc0:	00000797          	auipc	a5,0x0
    80001bc4:	da878793          	addi	a5,a5,-600 # 80001968 <forkret>
    80001bc8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bca:	60bc                	ld	a5,64(s1)
    80001bcc:	6705                	lui	a4,0x1
    80001bce:	97ba                	add	a5,a5,a4
    80001bd0:	f4bc                	sd	a5,104(s1)
  p->priority = 0;
    80001bd2:	1604a423          	sw	zero,360(s1)
  p->time_slices = 0;
    80001bd6:	1604a623          	sw	zero,364(s1)
  p->arrival_time = 0;
    80001bda:	1604b823          	sd	zero,368(s1)
}
    80001bde:	8526                	mv	a0,s1
    80001be0:	60e2                	ld	ra,24(sp)
    80001be2:	6442                	ld	s0,16(sp)
    80001be4:	64a2                	ld	s1,8(sp)
    80001be6:	6902                	ld	s2,0(sp)
    80001be8:	6105                	addi	sp,sp,32
    80001bea:	8082                	ret
    freeproc(p);
    80001bec:	8526                	mv	a0,s1
    80001bee:	f1dff0ef          	jal	80001b0a <freeproc>
    release(&p->lock);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	8c8ff0ef          	jal	80000cbc <release>
    return 0;
    80001bf8:	84ca                	mv	s1,s2
    80001bfa:	b7d5                	j	80001bde <allocproc+0x84>
    freeproc(p);
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	f0dff0ef          	jal	80001b0a <freeproc>
    release(&p->lock);
    80001c02:	8526                	mv	a0,s1
    80001c04:	8b8ff0ef          	jal	80000cbc <release>
    return 0;
    80001c08:	84ca                	mv	s1,s2
    80001c0a:	bfd1                	j	80001bde <allocproc+0x84>

0000000080001c0c <userinit>:
{
    80001c0c:	1101                	addi	sp,sp,-32
    80001c0e:	ec06                	sd	ra,24(sp)
    80001c10:	e822                	sd	s0,16(sp)
    80001c12:	e426                	sd	s1,8(sp)
    80001c14:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c16:	f45ff0ef          	jal	80001b5a <allocproc>
    80001c1a:	84aa                	mv	s1,a0
  initproc = p;
    80001c1c:	00006797          	auipc	a5,0x6
    80001c20:	c6a7b623          	sd	a0,-916(a5) # 80007888 <initproc>
  p->cwd = namei("/");
    80001c24:	00005517          	auipc	a0,0x5
    80001c28:	57450513          	addi	a0,a0,1396 # 80007198 <etext+0x198>
    80001c2c:	781010ef          	jal	80003bac <namei>
    80001c30:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c34:	478d                	li	a5,3
    80001c36:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	882ff0ef          	jal	80000cbc <release>
}
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6105                	addi	sp,sp,32
    80001c46:	8082                	ret

0000000080001c48 <growproc>:
{
    80001c48:	1101                	addi	sp,sp,-32
    80001c4a:	ec06                	sd	ra,24(sp)
    80001c4c:	e822                	sd	s0,16(sp)
    80001c4e:	e426                	sd	s1,8(sp)
    80001c50:	e04a                	sd	s2,0(sp)
    80001c52:	1000                	addi	s0,sp,32
    80001c54:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c56:	ce1ff0ef          	jal	80001936 <myproc>
    80001c5a:	892a                	mv	s2,a0
  sz = p->sz;
    80001c5c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c5e:	02905963          	blez	s1,80001c90 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c62:	00b48633          	add	a2,s1,a1
    80001c66:	020007b7          	lui	a5,0x2000
    80001c6a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c6c:	07b6                	slli	a5,a5,0xd
    80001c6e:	02c7ea63          	bltu	a5,a2,80001ca2 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c72:	4691                	li	a3,4
    80001c74:	6928                	ld	a0,80(a0)
    80001c76:	e86ff0ef          	jal	800012fc <uvmalloc>
    80001c7a:	85aa                	mv	a1,a0
    80001c7c:	c50d                	beqz	a0,80001ca6 <growproc+0x5e>
  p->sz = sz;
    80001c7e:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c82:	4501                	li	a0,0
}
    80001c84:	60e2                	ld	ra,24(sp)
    80001c86:	6442                	ld	s0,16(sp)
    80001c88:	64a2                	ld	s1,8(sp)
    80001c8a:	6902                	ld	s2,0(sp)
    80001c8c:	6105                	addi	sp,sp,32
    80001c8e:	8082                	ret
  } else if(n < 0){
    80001c90:	fe04d7e3          	bgez	s1,80001c7e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c94:	00b48633          	add	a2,s1,a1
    80001c98:	6928                	ld	a0,80(a0)
    80001c9a:	e1eff0ef          	jal	800012b8 <uvmdealloc>
    80001c9e:	85aa                	mv	a1,a0
    80001ca0:	bff9                	j	80001c7e <growproc+0x36>
      return -1;
    80001ca2:	557d                	li	a0,-1
    80001ca4:	b7c5                	j	80001c84 <growproc+0x3c>
      return -1;
    80001ca6:	557d                	li	a0,-1
    80001ca8:	bff1                	j	80001c84 <growproc+0x3c>

0000000080001caa <kfork>:
{
    80001caa:	7139                	addi	sp,sp,-64
    80001cac:	fc06                	sd	ra,56(sp)
    80001cae:	f822                	sd	s0,48(sp)
    80001cb0:	f426                	sd	s1,40(sp)
    80001cb2:	e456                	sd	s5,8(sp)
    80001cb4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cb6:	c81ff0ef          	jal	80001936 <myproc>
    80001cba:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001cbc:	e9fff0ef          	jal	80001b5a <allocproc>
    80001cc0:	0e050a63          	beqz	a0,80001db4 <kfork+0x10a>
    80001cc4:	e852                	sd	s4,16(sp)
    80001cc6:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001cc8:	048ab603          	ld	a2,72(s5)
    80001ccc:	692c                	ld	a1,80(a0)
    80001cce:	050ab503          	ld	a0,80(s5)
    80001cd2:	f62ff0ef          	jal	80001434 <uvmcopy>
    80001cd6:	04054863          	bltz	a0,80001d26 <kfork+0x7c>
    80001cda:	f04a                	sd	s2,32(sp)
    80001cdc:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cde:	048ab783          	ld	a5,72(s5)
    80001ce2:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ce6:	058ab683          	ld	a3,88(s5)
    80001cea:	87b6                	mv	a5,a3
    80001cec:	058a3703          	ld	a4,88(s4)
    80001cf0:	12068693          	addi	a3,a3,288
    80001cf4:	6388                	ld	a0,0(a5)
    80001cf6:	678c                	ld	a1,8(a5)
    80001cf8:	6b90                	ld	a2,16(a5)
    80001cfa:	e308                	sd	a0,0(a4)
    80001cfc:	e70c                	sd	a1,8(a4)
    80001cfe:	eb10                	sd	a2,16(a4)
    80001d00:	6f90                	ld	a2,24(a5)
    80001d02:	ef10                	sd	a2,24(a4)
    80001d04:	02078793          	addi	a5,a5,32
    80001d08:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d0c:	fed794e3          	bne	a5,a3,80001cf4 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d10:	058a3783          	ld	a5,88(s4)
    80001d14:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d18:	0d0a8493          	addi	s1,s5,208
    80001d1c:	0d0a0913          	addi	s2,s4,208
    80001d20:	150a8993          	addi	s3,s5,336
    80001d24:	a831                	j	80001d40 <kfork+0x96>
    freeproc(np);
    80001d26:	8552                	mv	a0,s4
    80001d28:	de3ff0ef          	jal	80001b0a <freeproc>
    release(&np->lock);
    80001d2c:	8552                	mv	a0,s4
    80001d2e:	f8ffe0ef          	jal	80000cbc <release>
    return -1;
    80001d32:	54fd                	li	s1,-1
    80001d34:	6a42                	ld	s4,16(sp)
    80001d36:	a885                	j	80001da6 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001d38:	04a1                	addi	s1,s1,8
    80001d3a:	0921                	addi	s2,s2,8
    80001d3c:	01348963          	beq	s1,s3,80001d4e <kfork+0xa4>
    if(p->ofile[i])
    80001d40:	6088                	ld	a0,0(s1)
    80001d42:	d97d                	beqz	a0,80001d38 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d44:	424020ef          	jal	80004168 <filedup>
    80001d48:	00a93023          	sd	a0,0(s2)
    80001d4c:	b7f5                	j	80001d38 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d4e:	150ab503          	ld	a0,336(s5)
    80001d52:	5f6010ef          	jal	80003348 <idup>
    80001d56:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d5a:	4641                	li	a2,16
    80001d5c:	158a8593          	addi	a1,s5,344
    80001d60:	158a0513          	addi	a0,s4,344
    80001d64:	8e8ff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001d68:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d6c:	8552                	mv	a0,s4
    80001d6e:	f4ffe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001d72:	0000e517          	auipc	a0,0xe
    80001d76:	c3e50513          	addi	a0,a0,-962 # 8000f9b0 <wait_lock>
    80001d7a:	eaffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d7e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d82:	0000e517          	auipc	a0,0xe
    80001d86:	c2e50513          	addi	a0,a0,-978 # 8000f9b0 <wait_lock>
    80001d8a:	f33fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001d8e:	8552                	mv	a0,s4
    80001d90:	e99fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d94:	478d                	li	a5,3
    80001d96:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d9a:	8552                	mv	a0,s4
    80001d9c:	f21fe0ef          	jal	80000cbc <release>
  return pid;
    80001da0:	7902                	ld	s2,32(sp)
    80001da2:	69e2                	ld	s3,24(sp)
    80001da4:	6a42                	ld	s4,16(sp)
}
    80001da6:	8526                	mv	a0,s1
    80001da8:	70e2                	ld	ra,56(sp)
    80001daa:	7442                	ld	s0,48(sp)
    80001dac:	74a2                	ld	s1,40(sp)
    80001dae:	6aa2                	ld	s5,8(sp)
    80001db0:	6121                	addi	sp,sp,64
    80001db2:	8082                	ret
    return -1;
    80001db4:	54fd                	li	s1,-1
    80001db6:	bfc5                	j	80001da6 <kfork+0xfc>

0000000080001db8 <boost_all_priorities>:
{
    80001db8:	7179                	addi	sp,sp,-48
    80001dba:	f406                	sd	ra,40(sp)
    80001dbc:	f022                	sd	s0,32(sp)
    80001dbe:	ec26                	sd	s1,24(sp)
    80001dc0:	e84a                	sd	s2,16(sp)
    80001dc2:	e44e                	sd	s3,8(sp)
    80001dc4:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dc6:	0000e497          	auipc	s1,0xe
    80001dca:	01a48493          	addi	s1,s1,26 # 8000fde0 <proc>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001dce:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dd0:	00014917          	auipc	s2,0x14
    80001dd4:	e1090913          	addi	s2,s2,-496 # 80015be0 <tickslock>
    80001dd8:	a801                	j	80001de8 <boost_all_priorities+0x30>
    release(&p->lock);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	ee1fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001de0:	17848493          	addi	s1,s1,376
    80001de4:	01248e63          	beq	s1,s2,80001e00 <boost_all_priorities+0x48>
    acquire(&p->lock);
    80001de8:	8526                	mv	a0,s1
    80001dea:	e3ffe0ef          	jal	80000c28 <acquire>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001dee:	4c9c                	lw	a5,24(s1)
    80001df0:	37f9                	addiw	a5,a5,-2
    80001df2:	fef9e4e3          	bltu	s3,a5,80001dda <boost_all_priorities+0x22>
      p->priority = 0;
    80001df6:	1604a423          	sw	zero,360(s1)
      p->time_slices = 0;
    80001dfa:	1604a623          	sw	zero,364(s1)
    80001dfe:	bff1                	j	80001dda <boost_all_priorities+0x22>
}
    80001e00:	70a2                	ld	ra,40(sp)
    80001e02:	7402                	ld	s0,32(sp)
    80001e04:	64e2                	ld	s1,24(sp)
    80001e06:	6942                	ld	s2,16(sp)
    80001e08:	69a2                	ld	s3,8(sp)
    80001e0a:	6145                	addi	sp,sp,48
    80001e0c:	8082                	ret

0000000080001e0e <scheduler>:
{
    80001e0e:	715d                	addi	sp,sp,-80
    80001e10:	e486                	sd	ra,72(sp)
    80001e12:	e0a2                	sd	s0,64(sp)
    80001e14:	fc26                	sd	s1,56(sp)
    80001e16:	f84a                	sd	s2,48(sp)
    80001e18:	f44e                	sd	s3,40(sp)
    80001e1a:	f052                	sd	s4,32(sp)
    80001e1c:	ec56                	sd	s5,24(sp)
    80001e1e:	e85a                	sd	s6,16(sp)
    80001e20:	e45e                	sd	s7,8(sp)
    80001e22:	0880                	addi	s0,sp,80
    80001e24:	8792                	mv	a5,tp
  int id = r_tp();
    80001e26:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e28:	00779b93          	slli	s7,a5,0x7
    80001e2c:	0000e717          	auipc	a4,0xe
    80001e30:	b6c70713          	addi	a4,a4,-1172 # 8000f998 <pid_lock>
    80001e34:	975e                	add	a4,a4,s7
    80001e36:	04073423          	sd	zero,72(a4)
          swtch(&c->context, &p->context);
    80001e3a:	0000e717          	auipc	a4,0xe
    80001e3e:	bae70713          	addi	a4,a4,-1106 # 8000f9e8 <cpus+0x8>
    80001e42:	9bba                	add	s7,s7,a4
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e44:	00014997          	auipc	s3,0x14
    80001e48:	d9c98993          	addi	s3,s3,-612 # 80015be0 <tickslock>
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001e4c:	4a91                	li	s5,4
          c->proc = p;
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	0000eb17          	auipc	s6,0xe
    80001e54:	b48b0b13          	addi	s6,s6,-1208 # 8000f998 <pid_lock>
    80001e58:	9b3e                	add	s6,s6,a5
    80001e5a:	a0b9                	j	80001ea8 <scheduler+0x9a>
      release(&tickslock);
    80001e5c:	00014517          	auipc	a0,0x14
    80001e60:	d8450513          	addi	a0,a0,-636 # 80015be0 <tickslock>
    80001e64:	e59fe0ef          	jal	80000cbc <release>
    80001e68:	a859                	j	80001efe <scheduler+0xf0>
        release(&p->lock);
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	e51fe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e70:	17848493          	addi	s1,s1,376
    80001e74:	09348863          	beq	s1,s3,80001f04 <scheduler+0xf6>
        acquire(&p->lock);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	daffe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE && p->priority == priority) {
    80001e7e:	4c9c                	lw	a5,24(s1)
    80001e80:	ff2795e3          	bne	a5,s2,80001e6a <scheduler+0x5c>
    80001e84:	1684a783          	lw	a5,360(s1)
    80001e88:	ff4791e3          	bne	a5,s4,80001e6a <scheduler+0x5c>
          p->state = RUNNING;
    80001e8c:	0154ac23          	sw	s5,24(s1)
          c->proc = p;
    80001e90:	049b3423          	sd	s1,72(s6)
          swtch(&c->context, &p->context);
    80001e94:	06048593          	addi	a1,s1,96
    80001e98:	855e                	mv	a0,s7
    80001e9a:	5fa000ef          	jal	80002494 <swtch>
          c->proc = 0;
    80001e9e:	040b3423          	sd	zero,72(s6)
          release(&p->lock);
    80001ea2:	8526                	mv	a0,s1
    80001ea4:	e19fe0ef          	jal	80000cbc <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ea8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eb0:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eb4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001eb8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eba:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80001ebe:	00014517          	auipc	a0,0x14
    80001ec2:	d2250513          	addi	a0,a0,-734 # 80015be0 <tickslock>
    80001ec6:	d63fe0ef          	jal	80000c28 <acquire>
    uint64 current_ticks = ticks;
    80001eca:	00006717          	auipc	a4,0x6
    80001ece:	9c676703          	lwu	a4,-1594(a4) # 80007890 <ticks>
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001ed2:	00006797          	auipc	a5,0x6
    80001ed6:	9ae7b783          	ld	a5,-1618(a5) # 80007880 <last_boost_time>
    80001eda:	40f707b3          	sub	a5,a4,a5
    80001ede:	03100693          	li	a3,49
    80001ee2:	f6f6fde3          	bgeu	a3,a5,80001e5c <scheduler+0x4e>
      last_boost_time = current_ticks;
    80001ee6:	00006797          	auipc	a5,0x6
    80001eea:	98e7bd23          	sd	a4,-1638(a5) # 80007880 <last_boost_time>
      release(&tickslock);
    80001eee:	00014517          	auipc	a0,0x14
    80001ef2:	cf250513          	addi	a0,a0,-782 # 80015be0 <tickslock>
    80001ef6:	dc7fe0ef          	jal	80000cbc <release>
      boost_all_priorities();
    80001efa:	ebfff0ef          	jal	80001db8 <boost_all_priorities>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001efe:	4a01                	li	s4,0
        if(p->state == RUNNABLE && p->priority == priority) {
    80001f00:	490d                	li	s2,3
    80001f02:	a021                	j	80001f0a <scheduler+0xfc>
    for(int priority = 0; priority < NMLFQ && !found; priority++) {
    80001f04:	2a05                	addiw	s4,s4,1
    80001f06:	015a0763          	beq	s4,s5,80001f14 <scheduler+0x106>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001f0a:	0000e497          	auipc	s1,0xe
    80001f0e:	ed648493          	addi	s1,s1,-298 # 8000fde0 <proc>
    80001f12:	b79d                	j	80001e78 <scheduler+0x6a>
      asm volatile("wfi");
    80001f14:	10500073          	wfi
    80001f18:	bf41                	j	80001ea8 <scheduler+0x9a>

0000000080001f1a <sched>:
{
    80001f1a:	7179                	addi	sp,sp,-48
    80001f1c:	f406                	sd	ra,40(sp)
    80001f1e:	f022                	sd	s0,32(sp)
    80001f20:	ec26                	sd	s1,24(sp)
    80001f22:	e84a                	sd	s2,16(sp)
    80001f24:	e44e                	sd	s3,8(sp)
    80001f26:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f28:	a0fff0ef          	jal	80001936 <myproc>
    80001f2c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f2e:	c8bfe0ef          	jal	80000bb8 <holding>
    80001f32:	c935                	beqz	a0,80001fa6 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f34:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f36:	2781                	sext.w	a5,a5
    80001f38:	079e                	slli	a5,a5,0x7
    80001f3a:	0000e717          	auipc	a4,0xe
    80001f3e:	a5e70713          	addi	a4,a4,-1442 # 8000f998 <pid_lock>
    80001f42:	97ba                	add	a5,a5,a4
    80001f44:	0c07a703          	lw	a4,192(a5)
    80001f48:	4785                	li	a5,1
    80001f4a:	06f71463          	bne	a4,a5,80001fb2 <sched+0x98>
  if(p->state == RUNNING)
    80001f4e:	4c98                	lw	a4,24(s1)
    80001f50:	4791                	li	a5,4
    80001f52:	06f70663          	beq	a4,a5,80001fbe <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f56:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f5a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f5c:	e7bd                	bnez	a5,80001fca <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f5e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f60:	0000e917          	auipc	s2,0xe
    80001f64:	a3890913          	addi	s2,s2,-1480 # 8000f998 <pid_lock>
    80001f68:	2781                	sext.w	a5,a5
    80001f6a:	079e                	slli	a5,a5,0x7
    80001f6c:	97ca                	add	a5,a5,s2
    80001f6e:	0c47a983          	lw	s3,196(a5)
    80001f72:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f74:	2781                	sext.w	a5,a5
    80001f76:	079e                	slli	a5,a5,0x7
    80001f78:	07a1                	addi	a5,a5,8
    80001f7a:	0000e597          	auipc	a1,0xe
    80001f7e:	a6658593          	addi	a1,a1,-1434 # 8000f9e0 <cpus>
    80001f82:	95be                	add	a1,a1,a5
    80001f84:	06048513          	addi	a0,s1,96
    80001f88:	50c000ef          	jal	80002494 <swtch>
    80001f8c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f8e:	2781                	sext.w	a5,a5
    80001f90:	079e                	slli	a5,a5,0x7
    80001f92:	993e                	add	s2,s2,a5
    80001f94:	0d392223          	sw	s3,196(s2)
}
    80001f98:	70a2                	ld	ra,40(sp)
    80001f9a:	7402                	ld	s0,32(sp)
    80001f9c:	64e2                	ld	s1,24(sp)
    80001f9e:	6942                	ld	s2,16(sp)
    80001fa0:	69a2                	ld	s3,8(sp)
    80001fa2:	6145                	addi	sp,sp,48
    80001fa4:	8082                	ret
    panic("sched p->lock");
    80001fa6:	00005517          	auipc	a0,0x5
    80001faa:	1fa50513          	addi	a0,a0,506 # 800071a0 <etext+0x1a0>
    80001fae:	877fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001fb2:	00005517          	auipc	a0,0x5
    80001fb6:	1fe50513          	addi	a0,a0,510 # 800071b0 <etext+0x1b0>
    80001fba:	86bfe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001fbe:	00005517          	auipc	a0,0x5
    80001fc2:	20250513          	addi	a0,a0,514 # 800071c0 <etext+0x1c0>
    80001fc6:	85ffe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001fca:	00005517          	auipc	a0,0x5
    80001fce:	20650513          	addi	a0,a0,518 # 800071d0 <etext+0x1d0>
    80001fd2:	853fe0ef          	jal	80000824 <panic>

0000000080001fd6 <yield>:
{
    80001fd6:	1101                	addi	sp,sp,-32
    80001fd8:	ec06                	sd	ra,24(sp)
    80001fda:	e822                	sd	s0,16(sp)
    80001fdc:	e426                	sd	s1,8(sp)
    80001fde:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fe0:	957ff0ef          	jal	80001936 <myproc>
    80001fe4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fe6:	c43fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fea:	478d                	li	a5,3
    80001fec:	cc9c                	sw	a5,24(s1)
  sched();
    80001fee:	f2dff0ef          	jal	80001f1a <sched>
  release(&p->lock);
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	cc9fe0ef          	jal	80000cbc <release>
}
    80001ff8:	60e2                	ld	ra,24(sp)
    80001ffa:	6442                	ld	s0,16(sp)
    80001ffc:	64a2                	ld	s1,8(sp)
    80001ffe:	6105                	addi	sp,sp,32
    80002000:	8082                	ret

0000000080002002 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002002:	7179                	addi	sp,sp,-48
    80002004:	f406                	sd	ra,40(sp)
    80002006:	f022                	sd	s0,32(sp)
    80002008:	ec26                	sd	s1,24(sp)
    8000200a:	e84a                	sd	s2,16(sp)
    8000200c:	e44e                	sd	s3,8(sp)
    8000200e:	1800                	addi	s0,sp,48
    80002010:	89aa                	mv	s3,a0
    80002012:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002014:	923ff0ef          	jal	80001936 <myproc>
    80002018:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000201a:	c0ffe0ef          	jal	80000c28 <acquire>
  release(lk);
    8000201e:	854a                	mv	a0,s2
    80002020:	c9dfe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80002024:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002028:	4789                	li	a5,2
    8000202a:	cc9c                	sw	a5,24(s1)

  sched();
    8000202c:	eefff0ef          	jal	80001f1a <sched>

  // Tidy up.
  p->chan = 0;
    80002030:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	c87fe0ef          	jal	80000cbc <release>
  acquire(lk);
    8000203a:	854a                	mv	a0,s2
    8000203c:	bedfe0ef          	jal	80000c28 <acquire>
}
    80002040:	70a2                	ld	ra,40(sp)
    80002042:	7402                	ld	s0,32(sp)
    80002044:	64e2                	ld	s1,24(sp)
    80002046:	6942                	ld	s2,16(sp)
    80002048:	69a2                	ld	s3,8(sp)
    8000204a:	6145                	addi	sp,sp,48
    8000204c:	8082                	ret

000000008000204e <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000204e:	7139                	addi	sp,sp,-64
    80002050:	fc06                	sd	ra,56(sp)
    80002052:	f822                	sd	s0,48(sp)
    80002054:	f426                	sd	s1,40(sp)
    80002056:	f04a                	sd	s2,32(sp)
    80002058:	ec4e                	sd	s3,24(sp)
    8000205a:	e852                	sd	s4,16(sp)
    8000205c:	e456                	sd	s5,8(sp)
    8000205e:	0080                	addi	s0,sp,64
    80002060:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002062:	0000e497          	auipc	s1,0xe
    80002066:	d7e48493          	addi	s1,s1,-642 # 8000fde0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000206a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000206c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000206e:	00014917          	auipc	s2,0x14
    80002072:	b7290913          	addi	s2,s2,-1166 # 80015be0 <tickslock>
    80002076:	a801                	j	80002086 <wakeup+0x38>
      }
      release(&p->lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	c43fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000207e:	17848493          	addi	s1,s1,376
    80002082:	03248263          	beq	s1,s2,800020a6 <wakeup+0x58>
    if(p != myproc()){
    80002086:	8b1ff0ef          	jal	80001936 <myproc>
    8000208a:	fe950ae3          	beq	a0,s1,8000207e <wakeup+0x30>
      acquire(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	b99fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002094:	4c9c                	lw	a5,24(s1)
    80002096:	ff3791e3          	bne	a5,s3,80002078 <wakeup+0x2a>
    8000209a:	709c                	ld	a5,32(s1)
    8000209c:	fd479ee3          	bne	a5,s4,80002078 <wakeup+0x2a>
        p->state = RUNNABLE;
    800020a0:	0154ac23          	sw	s5,24(s1)
    800020a4:	bfd1                	j	80002078 <wakeup+0x2a>
    }
  }
}
    800020a6:	70e2                	ld	ra,56(sp)
    800020a8:	7442                	ld	s0,48(sp)
    800020aa:	74a2                	ld	s1,40(sp)
    800020ac:	7902                	ld	s2,32(sp)
    800020ae:	69e2                	ld	s3,24(sp)
    800020b0:	6a42                	ld	s4,16(sp)
    800020b2:	6aa2                	ld	s5,8(sp)
    800020b4:	6121                	addi	sp,sp,64
    800020b6:	8082                	ret

00000000800020b8 <reparent>:
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	e84a                	sd	s2,16(sp)
    800020c2:	e44e                	sd	s3,8(sp)
    800020c4:	e052                	sd	s4,0(sp)
    800020c6:	1800                	addi	s0,sp,48
    800020c8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020ca:	0000e497          	auipc	s1,0xe
    800020ce:	d1648493          	addi	s1,s1,-746 # 8000fde0 <proc>
      pp->parent = initproc;
    800020d2:	00005a17          	auipc	s4,0x5
    800020d6:	7b6a0a13          	addi	s4,s4,1974 # 80007888 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020da:	00014997          	auipc	s3,0x14
    800020de:	b0698993          	addi	s3,s3,-1274 # 80015be0 <tickslock>
    800020e2:	a029                	j	800020ec <reparent+0x34>
    800020e4:	17848493          	addi	s1,s1,376
    800020e8:	01348b63          	beq	s1,s3,800020fe <reparent+0x46>
    if(pp->parent == p){
    800020ec:	7c9c                	ld	a5,56(s1)
    800020ee:	ff279be3          	bne	a5,s2,800020e4 <reparent+0x2c>
      pp->parent = initproc;
    800020f2:	000a3503          	ld	a0,0(s4)
    800020f6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020f8:	f57ff0ef          	jal	8000204e <wakeup>
    800020fc:	b7e5                	j	800020e4 <reparent+0x2c>
}
    800020fe:	70a2                	ld	ra,40(sp)
    80002100:	7402                	ld	s0,32(sp)
    80002102:	64e2                	ld	s1,24(sp)
    80002104:	6942                	ld	s2,16(sp)
    80002106:	69a2                	ld	s3,8(sp)
    80002108:	6a02                	ld	s4,0(sp)
    8000210a:	6145                	addi	sp,sp,48
    8000210c:	8082                	ret

000000008000210e <kexit>:
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	e052                	sd	s4,0(sp)
    8000211c:	1800                	addi	s0,sp,48
    8000211e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002120:	817ff0ef          	jal	80001936 <myproc>
    80002124:	89aa                	mv	s3,a0
  if(p == initproc)
    80002126:	00005797          	auipc	a5,0x5
    8000212a:	7627b783          	ld	a5,1890(a5) # 80007888 <initproc>
    8000212e:	0d050493          	addi	s1,a0,208
    80002132:	15050913          	addi	s2,a0,336
    80002136:	00a79b63          	bne	a5,a0,8000214c <kexit+0x3e>
    panic("init exiting");
    8000213a:	00005517          	auipc	a0,0x5
    8000213e:	0ae50513          	addi	a0,a0,174 # 800071e8 <etext+0x1e8>
    80002142:	ee2fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002146:	04a1                	addi	s1,s1,8
    80002148:	01248963          	beq	s1,s2,8000215a <kexit+0x4c>
    if(p->ofile[fd]){
    8000214c:	6088                	ld	a0,0(s1)
    8000214e:	dd65                	beqz	a0,80002146 <kexit+0x38>
      fileclose(f);
    80002150:	05e020ef          	jal	800041ae <fileclose>
      p->ofile[fd] = 0;
    80002154:	0004b023          	sd	zero,0(s1)
    80002158:	b7fd                	j	80002146 <kexit+0x38>
  begin_op();
    8000215a:	431010ef          	jal	80003d8a <begin_op>
  iput(p->cwd);
    8000215e:	1509b503          	ld	a0,336(s3)
    80002162:	39e010ef          	jal	80003500 <iput>
  end_op();
    80002166:	495010ef          	jal	80003dfa <end_op>
  p->cwd = 0;
    8000216a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000216e:	0000e517          	auipc	a0,0xe
    80002172:	84250513          	addi	a0,a0,-1982 # 8000f9b0 <wait_lock>
    80002176:	ab3fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    8000217a:	854e                	mv	a0,s3
    8000217c:	f3dff0ef          	jal	800020b8 <reparent>
  wakeup(p->parent);
    80002180:	0389b503          	ld	a0,56(s3)
    80002184:	ecbff0ef          	jal	8000204e <wakeup>
  acquire(&p->lock);
    80002188:	854e                	mv	a0,s3
    8000218a:	a9ffe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000218e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002192:	4795                	li	a5,5
    80002194:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002198:	0000e517          	auipc	a0,0xe
    8000219c:	81850513          	addi	a0,a0,-2024 # 8000f9b0 <wait_lock>
    800021a0:	b1dfe0ef          	jal	80000cbc <release>
  sched();
    800021a4:	d77ff0ef          	jal	80001f1a <sched>
  panic("zombie exit");
    800021a8:	00005517          	auipc	a0,0x5
    800021ac:	05050513          	addi	a0,a0,80 # 800071f8 <etext+0x1f8>
    800021b0:	e74fe0ef          	jal	80000824 <panic>

00000000800021b4 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800021b4:	7179                	addi	sp,sp,-48
    800021b6:	f406                	sd	ra,40(sp)
    800021b8:	f022                	sd	s0,32(sp)
    800021ba:	ec26                	sd	s1,24(sp)
    800021bc:	e84a                	sd	s2,16(sp)
    800021be:	e44e                	sd	s3,8(sp)
    800021c0:	1800                	addi	s0,sp,48
    800021c2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800021c4:	0000e497          	auipc	s1,0xe
    800021c8:	c1c48493          	addi	s1,s1,-996 # 8000fde0 <proc>
    800021cc:	00014997          	auipc	s3,0x14
    800021d0:	a1498993          	addi	s3,s3,-1516 # 80015be0 <tickslock>
    acquire(&p->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	a53fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    800021da:	589c                	lw	a5,48(s1)
    800021dc:	01278b63          	beq	a5,s2,800021f2 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021e0:	8526                	mv	a0,s1
    800021e2:	adbfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800021e6:	17848493          	addi	s1,s1,376
    800021ea:	ff3495e3          	bne	s1,s3,800021d4 <kkill+0x20>
  }
  return -1;
    800021ee:	557d                	li	a0,-1
    800021f0:	a819                	j	80002206 <kkill+0x52>
      p->killed = 1;
    800021f2:	4785                	li	a5,1
    800021f4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800021f6:	4c98                	lw	a4,24(s1)
    800021f8:	4789                	li	a5,2
    800021fa:	00f70d63          	beq	a4,a5,80002214 <kkill+0x60>
      release(&p->lock);
    800021fe:	8526                	mv	a0,s1
    80002200:	abdfe0ef          	jal	80000cbc <release>
      return 0;
    80002204:	4501                	li	a0,0
}
    80002206:	70a2                	ld	ra,40(sp)
    80002208:	7402                	ld	s0,32(sp)
    8000220a:	64e2                	ld	s1,24(sp)
    8000220c:	6942                	ld	s2,16(sp)
    8000220e:	69a2                	ld	s3,8(sp)
    80002210:	6145                	addi	sp,sp,48
    80002212:	8082                	ret
        p->state = RUNNABLE;
    80002214:	478d                	li	a5,3
    80002216:	cc9c                	sw	a5,24(s1)
    80002218:	b7dd                	j	800021fe <kkill+0x4a>

000000008000221a <setkilled>:

void
setkilled(struct proc *p)
{
    8000221a:	1101                	addi	sp,sp,-32
    8000221c:	ec06                	sd	ra,24(sp)
    8000221e:	e822                	sd	s0,16(sp)
    80002220:	e426                	sd	s1,8(sp)
    80002222:	1000                	addi	s0,sp,32
    80002224:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002226:	a03fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000222a:	4785                	li	a5,1
    8000222c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	a8dfe0ef          	jal	80000cbc <release>
}
    80002234:	60e2                	ld	ra,24(sp)
    80002236:	6442                	ld	s0,16(sp)
    80002238:	64a2                	ld	s1,8(sp)
    8000223a:	6105                	addi	sp,sp,32
    8000223c:	8082                	ret

000000008000223e <killed>:

int
killed(struct proc *p)
{
    8000223e:	1101                	addi	sp,sp,-32
    80002240:	ec06                	sd	ra,24(sp)
    80002242:	e822                	sd	s0,16(sp)
    80002244:	e426                	sd	s1,8(sp)
    80002246:	e04a                	sd	s2,0(sp)
    80002248:	1000                	addi	s0,sp,32
    8000224a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000224c:	9ddfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002250:	549c                	lw	a5,40(s1)
    80002252:	893e                	mv	s2,a5
  release(&p->lock);
    80002254:	8526                	mv	a0,s1
    80002256:	a67fe0ef          	jal	80000cbc <release>
  return k;
}
    8000225a:	854a                	mv	a0,s2
    8000225c:	60e2                	ld	ra,24(sp)
    8000225e:	6442                	ld	s0,16(sp)
    80002260:	64a2                	ld	s1,8(sp)
    80002262:	6902                	ld	s2,0(sp)
    80002264:	6105                	addi	sp,sp,32
    80002266:	8082                	ret

0000000080002268 <kwait>:
{
    80002268:	715d                	addi	sp,sp,-80
    8000226a:	e486                	sd	ra,72(sp)
    8000226c:	e0a2                	sd	s0,64(sp)
    8000226e:	fc26                	sd	s1,56(sp)
    80002270:	f84a                	sd	s2,48(sp)
    80002272:	f44e                	sd	s3,40(sp)
    80002274:	f052                	sd	s4,32(sp)
    80002276:	ec56                	sd	s5,24(sp)
    80002278:	e85a                	sd	s6,16(sp)
    8000227a:	e45e                	sd	s7,8(sp)
    8000227c:	0880                	addi	s0,sp,80
    8000227e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002280:	eb6ff0ef          	jal	80001936 <myproc>
    80002284:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002286:	0000d517          	auipc	a0,0xd
    8000228a:	72a50513          	addi	a0,a0,1834 # 8000f9b0 <wait_lock>
    8000228e:	99bfe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002292:	4a15                	li	s4,5
        havekids = 1;
    80002294:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002296:	00014997          	auipc	s3,0x14
    8000229a:	94a98993          	addi	s3,s3,-1718 # 80015be0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000229e:	0000db17          	auipc	s6,0xd
    800022a2:	712b0b13          	addi	s6,s6,1810 # 8000f9b0 <wait_lock>
    800022a6:	a869                	j	80002340 <kwait+0xd8>
          pid = pp->pid;
    800022a8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800022ac:	000b8c63          	beqz	s7,800022c4 <kwait+0x5c>
    800022b0:	4691                	li	a3,4
    800022b2:	02c48613          	addi	a2,s1,44
    800022b6:	85de                	mv	a1,s7
    800022b8:	05093503          	ld	a0,80(s2)
    800022bc:	b98ff0ef          	jal	80001654 <copyout>
    800022c0:	02054a63          	bltz	a0,800022f4 <kwait+0x8c>
          freeproc(pp);
    800022c4:	8526                	mv	a0,s1
    800022c6:	845ff0ef          	jal	80001b0a <freeproc>
          release(&pp->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	9f1fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    800022d0:	0000d517          	auipc	a0,0xd
    800022d4:	6e050513          	addi	a0,a0,1760 # 8000f9b0 <wait_lock>
    800022d8:	9e5fe0ef          	jal	80000cbc <release>
}
    800022dc:	854e                	mv	a0,s3
    800022de:	60a6                	ld	ra,72(sp)
    800022e0:	6406                	ld	s0,64(sp)
    800022e2:	74e2                	ld	s1,56(sp)
    800022e4:	7942                	ld	s2,48(sp)
    800022e6:	79a2                	ld	s3,40(sp)
    800022e8:	7a02                	ld	s4,32(sp)
    800022ea:	6ae2                	ld	s5,24(sp)
    800022ec:	6b42                	ld	s6,16(sp)
    800022ee:	6ba2                	ld	s7,8(sp)
    800022f0:	6161                	addi	sp,sp,80
    800022f2:	8082                	ret
            release(&pp->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	9c7fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    800022fa:	0000d517          	auipc	a0,0xd
    800022fe:	6b650513          	addi	a0,a0,1718 # 8000f9b0 <wait_lock>
    80002302:	9bbfe0ef          	jal	80000cbc <release>
            return -1;
    80002306:	59fd                	li	s3,-1
    80002308:	bfd1                	j	800022dc <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000230a:	17848493          	addi	s1,s1,376
    8000230e:	03348063          	beq	s1,s3,8000232e <kwait+0xc6>
      if(pp->parent == p){
    80002312:	7c9c                	ld	a5,56(s1)
    80002314:	ff279be3          	bne	a5,s2,8000230a <kwait+0xa2>
        acquire(&pp->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	90ffe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    8000231e:	4c9c                	lw	a5,24(s1)
    80002320:	f94784e3          	beq	a5,s4,800022a8 <kwait+0x40>
        release(&pp->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	997fe0ef          	jal	80000cbc <release>
        havekids = 1;
    8000232a:	8756                	mv	a4,s5
    8000232c:	bff9                	j	8000230a <kwait+0xa2>
    if(!havekids || killed(p)){
    8000232e:	cf19                	beqz	a4,8000234c <kwait+0xe4>
    80002330:	854a                	mv	a0,s2
    80002332:	f0dff0ef          	jal	8000223e <killed>
    80002336:	e919                	bnez	a0,8000234c <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002338:	85da                	mv	a1,s6
    8000233a:	854a                	mv	a0,s2
    8000233c:	cc7ff0ef          	jal	80002002 <sleep>
    havekids = 0;
    80002340:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002342:	0000e497          	auipc	s1,0xe
    80002346:	a9e48493          	addi	s1,s1,-1378 # 8000fde0 <proc>
    8000234a:	b7e1                	j	80002312 <kwait+0xaa>
      release(&wait_lock);
    8000234c:	0000d517          	auipc	a0,0xd
    80002350:	66450513          	addi	a0,a0,1636 # 8000f9b0 <wait_lock>
    80002354:	969fe0ef          	jal	80000cbc <release>
      return -1;
    80002358:	59fd                	li	s3,-1
    8000235a:	b749                	j	800022dc <kwait+0x74>

000000008000235c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000235c:	7179                	addi	sp,sp,-48
    8000235e:	f406                	sd	ra,40(sp)
    80002360:	f022                	sd	s0,32(sp)
    80002362:	ec26                	sd	s1,24(sp)
    80002364:	e84a                	sd	s2,16(sp)
    80002366:	e44e                	sd	s3,8(sp)
    80002368:	e052                	sd	s4,0(sp)
    8000236a:	1800                	addi	s0,sp,48
    8000236c:	84aa                	mv	s1,a0
    8000236e:	8a2e                	mv	s4,a1
    80002370:	89b2                	mv	s3,a2
    80002372:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002374:	dc2ff0ef          	jal	80001936 <myproc>
  if(user_dst){
    80002378:	cc99                	beqz	s1,80002396 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000237a:	86ca                	mv	a3,s2
    8000237c:	864e                	mv	a2,s3
    8000237e:	85d2                	mv	a1,s4
    80002380:	6928                	ld	a0,80(a0)
    80002382:	ad2ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002386:	70a2                	ld	ra,40(sp)
    80002388:	7402                	ld	s0,32(sp)
    8000238a:	64e2                	ld	s1,24(sp)
    8000238c:	6942                	ld	s2,16(sp)
    8000238e:	69a2                	ld	s3,8(sp)
    80002390:	6a02                	ld	s4,0(sp)
    80002392:	6145                	addi	sp,sp,48
    80002394:	8082                	ret
    memmove((char *)dst, src, len);
    80002396:	0009061b          	sext.w	a2,s2
    8000239a:	85ce                	mv	a1,s3
    8000239c:	8552                	mv	a0,s4
    8000239e:	9bbfe0ef          	jal	80000d58 <memmove>
    return 0;
    800023a2:	8526                	mv	a0,s1
    800023a4:	b7cd                	j	80002386 <either_copyout+0x2a>

00000000800023a6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023a6:	7179                	addi	sp,sp,-48
    800023a8:	f406                	sd	ra,40(sp)
    800023aa:	f022                	sd	s0,32(sp)
    800023ac:	ec26                	sd	s1,24(sp)
    800023ae:	e84a                	sd	s2,16(sp)
    800023b0:	e44e                	sd	s3,8(sp)
    800023b2:	e052                	sd	s4,0(sp)
    800023b4:	1800                	addi	s0,sp,48
    800023b6:	8a2a                	mv	s4,a0
    800023b8:	84ae                	mv	s1,a1
    800023ba:	89b2                	mv	s3,a2
    800023bc:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023be:	d78ff0ef          	jal	80001936 <myproc>
  if(user_src){
    800023c2:	cc99                	beqz	s1,800023e0 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800023c4:	86ca                	mv	a3,s2
    800023c6:	864e                	mv	a2,s3
    800023c8:	85d2                	mv	a1,s4
    800023ca:	6928                	ld	a0,80(a0)
    800023cc:	b46ff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800023d0:	70a2                	ld	ra,40(sp)
    800023d2:	7402                	ld	s0,32(sp)
    800023d4:	64e2                	ld	s1,24(sp)
    800023d6:	6942                	ld	s2,16(sp)
    800023d8:	69a2                	ld	s3,8(sp)
    800023da:	6a02                	ld	s4,0(sp)
    800023dc:	6145                	addi	sp,sp,48
    800023de:	8082                	ret
    memmove(dst, (char*)src, len);
    800023e0:	0009061b          	sext.w	a2,s2
    800023e4:	85ce                	mv	a1,s3
    800023e6:	8552                	mv	a0,s4
    800023e8:	971fe0ef          	jal	80000d58 <memmove>
    return 0;
    800023ec:	8526                	mv	a0,s1
    800023ee:	b7cd                	j	800023d0 <either_copyin+0x2a>

00000000800023f0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023f0:	715d                	addi	sp,sp,-80
    800023f2:	e486                	sd	ra,72(sp)
    800023f4:	e0a2                	sd	s0,64(sp)
    800023f6:	fc26                	sd	s1,56(sp)
    800023f8:	f84a                	sd	s2,48(sp)
    800023fa:	f44e                	sd	s3,40(sp)
    800023fc:	f052                	sd	s4,32(sp)
    800023fe:	ec56                	sd	s5,24(sp)
    80002400:	e85a                	sd	s6,16(sp)
    80002402:	e45e                	sd	s7,8(sp)
    80002404:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002406:	00005517          	auipc	a0,0x5
    8000240a:	c7250513          	addi	a0,a0,-910 # 80007078 <etext+0x78>
    8000240e:	8ecfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002412:	0000e497          	auipc	s1,0xe
    80002416:	b2648493          	addi	s1,s1,-1242 # 8000ff38 <proc+0x158>
    8000241a:	00014917          	auipc	s2,0x14
    8000241e:	91e90913          	addi	s2,s2,-1762 # 80015d38 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002422:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002424:	00005997          	auipc	s3,0x5
    80002428:	de498993          	addi	s3,s3,-540 # 80007208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    8000242c:	00005a97          	auipc	s5,0x5
    80002430:	de4a8a93          	addi	s5,s5,-540 # 80007210 <etext+0x210>
    printf("\n");
    80002434:	00005a17          	auipc	s4,0x5
    80002438:	c44a0a13          	addi	s4,s4,-956 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000243c:	00005b97          	auipc	s7,0x5
    80002440:	2f4b8b93          	addi	s7,s7,756 # 80007730 <states.0>
    80002444:	a829                	j	8000245e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002446:	ed86a583          	lw	a1,-296(a3)
    8000244a:	8556                	mv	a0,s5
    8000244c:	8aefe0ef          	jal	800004fa <printf>
    printf("\n");
    80002450:	8552                	mv	a0,s4
    80002452:	8a8fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002456:	17848493          	addi	s1,s1,376
    8000245a:	03248263          	beq	s1,s2,8000247e <procdump+0x8e>
    if(p->state == UNUSED)
    8000245e:	86a6                	mv	a3,s1
    80002460:	ec04a783          	lw	a5,-320(s1)
    80002464:	dbed                	beqz	a5,80002456 <procdump+0x66>
      state = "???";
    80002466:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002468:	fcfb6fe3          	bltu	s6,a5,80002446 <procdump+0x56>
    8000246c:	02079713          	slli	a4,a5,0x20
    80002470:	01d75793          	srli	a5,a4,0x1d
    80002474:	97de                	add	a5,a5,s7
    80002476:	6390                	ld	a2,0(a5)
    80002478:	f679                	bnez	a2,80002446 <procdump+0x56>
      state = "???";
    8000247a:	864e                	mv	a2,s3
    8000247c:	b7e9                	j	80002446 <procdump+0x56>
  }
}
    8000247e:	60a6                	ld	ra,72(sp)
    80002480:	6406                	ld	s0,64(sp)
    80002482:	74e2                	ld	s1,56(sp)
    80002484:	7942                	ld	s2,48(sp)
    80002486:	79a2                	ld	s3,40(sp)
    80002488:	7a02                	ld	s4,32(sp)
    8000248a:	6ae2                	ld	s5,24(sp)
    8000248c:	6b42                	ld	s6,16(sp)
    8000248e:	6ba2                	ld	s7,8(sp)
    80002490:	6161                	addi	sp,sp,80
    80002492:	8082                	ret

0000000080002494 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002494:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002498:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000249c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000249e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024a0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024a4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024a8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024ac:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024b0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024b4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024b8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024bc:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024c0:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024c4:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024c8:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024cc:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024d0:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024d2:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024d4:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024d8:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024dc:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024e0:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024e4:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024e8:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024ec:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024f0:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024f4:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024f8:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024fc:	8082                	ret

00000000800024fe <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024fe:	1141                	addi	sp,sp,-16
    80002500:	e406                	sd	ra,8(sp)
    80002502:	e022                	sd	s0,0(sp)
    80002504:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002506:	00005597          	auipc	a1,0x5
    8000250a:	d4a58593          	addi	a1,a1,-694 # 80007250 <etext+0x250>
    8000250e:	00013517          	auipc	a0,0x13
    80002512:	6d250513          	addi	a0,a0,1746 # 80015be0 <tickslock>
    80002516:	e88fe0ef          	jal	80000b9e <initlock>
}
    8000251a:	60a2                	ld	ra,8(sp)
    8000251c:	6402                	ld	s0,0(sp)
    8000251e:	0141                	addi	sp,sp,16
    80002520:	8082                	ret

0000000080002522 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002522:	1141                	addi	sp,sp,-16
    80002524:	e406                	sd	ra,8(sp)
    80002526:	e022                	sd	s0,0(sp)
    80002528:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000252a:	00003797          	auipc	a5,0x3
    8000252e:	04678793          	addi	a5,a5,70 # 80005570 <kernelvec>
    80002532:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002536:	60a2                	ld	ra,8(sp)
    80002538:	6402                	ld	s0,0(sp)
    8000253a:	0141                	addi	sp,sp,16
    8000253c:	8082                	ret

000000008000253e <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000253e:	1141                	addi	sp,sp,-16
    80002540:	e406                	sd	ra,8(sp)
    80002542:	e022                	sd	s0,0(sp)
    80002544:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002546:	bf0ff0ef          	jal	80001936 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000254a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000254e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002550:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002554:	04000737          	lui	a4,0x4000
    80002558:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000255a:	0732                	slli	a4,a4,0xc
    8000255c:	00004797          	auipc	a5,0x4
    80002560:	aa478793          	addi	a5,a5,-1372 # 80006000 <_trampoline>
    80002564:	00004697          	auipc	a3,0x4
    80002568:	a9c68693          	addi	a3,a3,-1380 # 80006000 <_trampoline>
    8000256c:	8f95                	sub	a5,a5,a3
    8000256e:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002570:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002574:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002576:	18002773          	csrr	a4,satp
    8000257a:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000257c:	6d38                	ld	a4,88(a0)
    8000257e:	613c                	ld	a5,64(a0)
    80002580:	6685                	lui	a3,0x1
    80002582:	97b6                	add	a5,a5,a3
    80002584:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002586:	6d3c                	ld	a5,88(a0)
    80002588:	00000717          	auipc	a4,0x0
    8000258c:	0fc70713          	addi	a4,a4,252 # 80002684 <usertrap>
    80002590:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002592:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002594:	8712                	mv	a4,tp
    80002596:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002598:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000259c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025a0:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025a4:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025a8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025aa:	6f9c                	ld	a5,24(a5)
    800025ac:	14179073          	csrw	sepc,a5
}
    800025b0:	60a2                	ld	ra,8(sp)
    800025b2:	6402                	ld	s0,0(sp)
    800025b4:	0141                	addi	sp,sp,16
    800025b6:	8082                	ret

00000000800025b8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025b8:	1141                	addi	sp,sp,-16
    800025ba:	e406                	sd	ra,8(sp)
    800025bc:	e022                	sd	s0,0(sp)
    800025be:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800025c0:	b42ff0ef          	jal	80001902 <cpuid>
    800025c4:	cd11                	beqz	a0,800025e0 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800025c6:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025ca:	000f4737          	lui	a4,0xf4
    800025ce:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025d2:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800025d4:	14d79073          	csrw	stimecmp,a5
}
    800025d8:	60a2                	ld	ra,8(sp)
    800025da:	6402                	ld	s0,0(sp)
    800025dc:	0141                	addi	sp,sp,16
    800025de:	8082                	ret
    acquire(&tickslock);
    800025e0:	00013517          	auipc	a0,0x13
    800025e4:	60050513          	addi	a0,a0,1536 # 80015be0 <tickslock>
    800025e8:	e40fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025ec:	00005717          	auipc	a4,0x5
    800025f0:	2a470713          	addi	a4,a4,676 # 80007890 <ticks>
    800025f4:	431c                	lw	a5,0(a4)
    800025f6:	2785                	addiw	a5,a5,1
    800025f8:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025fa:	853a                	mv	a0,a4
    800025fc:	a53ff0ef          	jal	8000204e <wakeup>
    release(&tickslock);
    80002600:	00013517          	auipc	a0,0x13
    80002604:	5e050513          	addi	a0,a0,1504 # 80015be0 <tickslock>
    80002608:	eb4fe0ef          	jal	80000cbc <release>
    8000260c:	bf6d                	j	800025c6 <clockintr+0xe>

000000008000260e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000260e:	1101                	addi	sp,sp,-32
    80002610:	ec06                	sd	ra,24(sp)
    80002612:	e822                	sd	s0,16(sp)
    80002614:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002616:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000261a:	57fd                	li	a5,-1
    8000261c:	17fe                	slli	a5,a5,0x3f
    8000261e:	07a5                	addi	a5,a5,9
    80002620:	00f70c63          	beq	a4,a5,80002638 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002624:	57fd                	li	a5,-1
    80002626:	17fe                	slli	a5,a5,0x3f
    80002628:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000262a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000262c:	04f70863          	beq	a4,a5,8000267c <devintr+0x6e>
  }
}
    80002630:	60e2                	ld	ra,24(sp)
    80002632:	6442                	ld	s0,16(sp)
    80002634:	6105                	addi	sp,sp,32
    80002636:	8082                	ret
    80002638:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000263a:	7e3020ef          	jal	8000561c <plic_claim>
    8000263e:	872a                	mv	a4,a0
    80002640:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002642:	47a9                	li	a5,10
    80002644:	00f50963          	beq	a0,a5,80002656 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002648:	4785                	li	a5,1
    8000264a:	00f50963          	beq	a0,a5,8000265c <devintr+0x4e>
    return 1;
    8000264e:	4505                	li	a0,1
    } else if(irq){
    80002650:	eb09                	bnez	a4,80002662 <devintr+0x54>
    80002652:	64a2                	ld	s1,8(sp)
    80002654:	bff1                	j	80002630 <devintr+0x22>
      uartintr();
    80002656:	b9efe0ef          	jal	800009f4 <uartintr>
    if(irq)
    8000265a:	a819                	j	80002670 <devintr+0x62>
      virtio_disk_intr();
    8000265c:	456030ef          	jal	80005ab2 <virtio_disk_intr>
    if(irq)
    80002660:	a801                	j	80002670 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002662:	85ba                	mv	a1,a4
    80002664:	00005517          	auipc	a0,0x5
    80002668:	bf450513          	addi	a0,a0,-1036 # 80007258 <etext+0x258>
    8000266c:	e8ffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002670:	8526                	mv	a0,s1
    80002672:	7cb020ef          	jal	8000563c <plic_complete>
    return 1;
    80002676:	4505                	li	a0,1
    80002678:	64a2                	ld	s1,8(sp)
    8000267a:	bf5d                	j	80002630 <devintr+0x22>
    clockintr();
    8000267c:	f3dff0ef          	jal	800025b8 <clockintr>
    return 2;
    80002680:	4509                	li	a0,2
    80002682:	b77d                	j	80002630 <devintr+0x22>

0000000080002684 <usertrap>:
{
    80002684:	1101                	addi	sp,sp,-32
    80002686:	ec06                	sd	ra,24(sp)
    80002688:	e822                	sd	s0,16(sp)
    8000268a:	e426                	sd	s1,8(sp)
    8000268c:	e04a                	sd	s2,0(sp)
    8000268e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002690:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002694:	1007f793          	andi	a5,a5,256
    80002698:	eba5                	bnez	a5,80002708 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000269a:	00003797          	auipc	a5,0x3
    8000269e:	ed678793          	addi	a5,a5,-298 # 80005570 <kernelvec>
    800026a2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026a6:	a90ff0ef          	jal	80001936 <myproc>
    800026aa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026ac:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026ae:	14102773          	csrr	a4,sepc
    800026b2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026b4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800026b8:	47a1                	li	a5,8
    800026ba:	04f70d63          	beq	a4,a5,80002714 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800026be:	f51ff0ef          	jal	8000260e <devintr>
    800026c2:	892a                	mv	s2,a0
    800026c4:	e945                	bnez	a0,80002774 <usertrap+0xf0>
    800026c6:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026ca:	47bd                	li	a5,15
    800026cc:	08f70863          	beq	a4,a5,8000275c <usertrap+0xd8>
    800026d0:	14202773          	csrr	a4,scause
    800026d4:	47b5                	li	a5,13
    800026d6:	08f70363          	beq	a4,a5,8000275c <usertrap+0xd8>
    800026da:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026de:	5890                	lw	a2,48(s1)
    800026e0:	00005517          	auipc	a0,0x5
    800026e4:	bb850513          	addi	a0,a0,-1096 # 80007298 <etext+0x298>
    800026e8:	e13fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026ec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026f0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026f4:	00005517          	auipc	a0,0x5
    800026f8:	bd450513          	addi	a0,a0,-1068 # 800072c8 <etext+0x2c8>
    800026fc:	dfffd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002700:	8526                	mv	a0,s1
    80002702:	b19ff0ef          	jal	8000221a <setkilled>
    80002706:	a035                	j	80002732 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002708:	00005517          	auipc	a0,0x5
    8000270c:	b7050513          	addi	a0,a0,-1168 # 80007278 <etext+0x278>
    80002710:	914fe0ef          	jal	80000824 <panic>
    if(killed(p))
    80002714:	b2bff0ef          	jal	8000223e <killed>
    80002718:	ed15                	bnez	a0,80002754 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000271a:	6cb8                	ld	a4,88(s1)
    8000271c:	6f1c                	ld	a5,24(a4)
    8000271e:	0791                	addi	a5,a5,4
    80002720:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002722:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002726:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000272a:	10079073          	csrw	sstatus,a5
    syscall();
    8000272e:	272000ef          	jal	800029a0 <syscall>
  if(killed(p))
    80002732:	8526                	mv	a0,s1
    80002734:	b0bff0ef          	jal	8000223e <killed>
    80002738:	e139                	bnez	a0,8000277e <usertrap+0xfa>
  prepare_return();
    8000273a:	e05ff0ef          	jal	8000253e <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000273e:	68a8                	ld	a0,80(s1)
    80002740:	8131                	srli	a0,a0,0xc
    80002742:	57fd                	li	a5,-1
    80002744:	17fe                	slli	a5,a5,0x3f
    80002746:	8d5d                	or	a0,a0,a5
}
    80002748:	60e2                	ld	ra,24(sp)
    8000274a:	6442                	ld	s0,16(sp)
    8000274c:	64a2                	ld	s1,8(sp)
    8000274e:	6902                	ld	s2,0(sp)
    80002750:	6105                	addi	sp,sp,32
    80002752:	8082                	ret
      kexit(-1);
    80002754:	557d                	li	a0,-1
    80002756:	9b9ff0ef          	jal	8000210e <kexit>
    8000275a:	b7c1                	j	8000271a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000275c:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002760:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002764:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002766:	00163613          	seqz	a2,a2
    8000276a:	68a8                	ld	a0,80(s1)
    8000276c:	e65fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002770:	f169                	bnez	a0,80002732 <usertrap+0xae>
    80002772:	b7a5                	j	800026da <usertrap+0x56>
  if(killed(p))
    80002774:	8526                	mv	a0,s1
    80002776:	ac9ff0ef          	jal	8000223e <killed>
    8000277a:	c511                	beqz	a0,80002786 <usertrap+0x102>
    8000277c:	a011                	j	80002780 <usertrap+0xfc>
    8000277e:	4901                	li	s2,0
    kexit(-1);
    80002780:	557d                	li	a0,-1
    80002782:	98dff0ef          	jal	8000210e <kexit>
  if(which_dev == 2) {
    80002786:	4789                	li	a5,2
    80002788:	faf919e3          	bne	s2,a5,8000273a <usertrap+0xb6>
    p->time_slices++;
    8000278c:	16c4a783          	lw	a5,364(s1)
    80002790:	2785                	addiw	a5,a5,1
    80002792:	16f4a623          	sw	a5,364(s1)
    if(p->time_slices >= mlfq_time_quanta[p->priority]) {
    80002796:	1684a683          	lw	a3,360(s1)
    8000279a:	00269613          	slli	a2,a3,0x2
    8000279e:	00005717          	auipc	a4,0x5
    800027a2:	0b270713          	addi	a4,a4,178 # 80007850 <mlfq_time_quanta>
    800027a6:	9732                	add	a4,a4,a2
    800027a8:	4318                	lw	a4,0(a4)
    800027aa:	00e7ca63          	blt	a5,a4,800027be <usertrap+0x13a>
      if(p->priority < NMLFQ - 1) {
    800027ae:	4789                	li	a5,2
    800027b0:	00d7c563          	blt	a5,a3,800027ba <usertrap+0x136>
        p->priority++;  // Move to lower priority queue
    800027b4:	2685                	addiw	a3,a3,1 # 1001 <_entry-0x7fffefff>
    800027b6:	16d4a423          	sw	a3,360(s1)
      p->time_slices = 0;  // Reset time slice counter for new queue
    800027ba:	1604a623          	sw	zero,364(s1)
    yield();
    800027be:	819ff0ef          	jal	80001fd6 <yield>
    800027c2:	bfa5                	j	8000273a <usertrap+0xb6>

00000000800027c4 <kerneltrap>:
{
    800027c4:	7179                	addi	sp,sp,-48
    800027c6:	f406                	sd	ra,40(sp)
    800027c8:	f022                	sd	s0,32(sp)
    800027ca:	ec26                	sd	s1,24(sp)
    800027cc:	e84a                	sd	s2,16(sp)
    800027ce:	e44e                	sd	s3,8(sp)
    800027d0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027d2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027d6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027da:	142027f3          	csrr	a5,scause
    800027de:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    800027e0:	1004f793          	andi	a5,s1,256
    800027e4:	c795                	beqz	a5,80002810 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027ea:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800027ec:	eb85                	bnez	a5,8000281c <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800027ee:	e21ff0ef          	jal	8000260e <devintr>
    800027f2:	c91d                	beqz	a0,80002828 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800027f4:	4789                	li	a5,2
    800027f6:	04f50a63          	beq	a0,a5,8000284a <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027fa:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027fe:	10049073          	csrw	sstatus,s1
}
    80002802:	70a2                	ld	ra,40(sp)
    80002804:	7402                	ld	s0,32(sp)
    80002806:	64e2                	ld	s1,24(sp)
    80002808:	6942                	ld	s2,16(sp)
    8000280a:	69a2                	ld	s3,8(sp)
    8000280c:	6145                	addi	sp,sp,48
    8000280e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002810:	00005517          	auipc	a0,0x5
    80002814:	ae050513          	addi	a0,a0,-1312 # 800072f0 <etext+0x2f0>
    80002818:	80cfe0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    8000281c:	00005517          	auipc	a0,0x5
    80002820:	afc50513          	addi	a0,a0,-1284 # 80007318 <etext+0x318>
    80002824:	800fe0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002828:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000282c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002830:	85ce                	mv	a1,s3
    80002832:	00005517          	auipc	a0,0x5
    80002836:	b0650513          	addi	a0,a0,-1274 # 80007338 <etext+0x338>
    8000283a:	cc1fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000283e:	00005517          	auipc	a0,0x5
    80002842:	b2250513          	addi	a0,a0,-1246 # 80007360 <etext+0x360>
    80002846:	fdffd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000284a:	8ecff0ef          	jal	80001936 <myproc>
    8000284e:	d555                	beqz	a0,800027fa <kerneltrap+0x36>
    yield();
    80002850:	f86ff0ef          	jal	80001fd6 <yield>
    80002854:	b75d                	j	800027fa <kerneltrap+0x36>

0000000080002856 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002856:	1101                	addi	sp,sp,-32
    80002858:	ec06                	sd	ra,24(sp)
    8000285a:	e822                	sd	s0,16(sp)
    8000285c:	e426                	sd	s1,8(sp)
    8000285e:	1000                	addi	s0,sp,32
    80002860:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002862:	8d4ff0ef          	jal	80001936 <myproc>
  switch (n) {
    80002866:	4795                	li	a5,5
    80002868:	0497e163          	bltu	a5,s1,800028aa <argraw+0x54>
    8000286c:	048a                	slli	s1,s1,0x2
    8000286e:	00005717          	auipc	a4,0x5
    80002872:	ef270713          	addi	a4,a4,-270 # 80007760 <states.0+0x30>
    80002876:	94ba                	add	s1,s1,a4
    80002878:	409c                	lw	a5,0(s1)
    8000287a:	97ba                	add	a5,a5,a4
    8000287c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000287e:	6d3c                	ld	a5,88(a0)
    80002880:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002882:	60e2                	ld	ra,24(sp)
    80002884:	6442                	ld	s0,16(sp)
    80002886:	64a2                	ld	s1,8(sp)
    80002888:	6105                	addi	sp,sp,32
    8000288a:	8082                	ret
    return p->trapframe->a1;
    8000288c:	6d3c                	ld	a5,88(a0)
    8000288e:	7fa8                	ld	a0,120(a5)
    80002890:	bfcd                	j	80002882 <argraw+0x2c>
    return p->trapframe->a2;
    80002892:	6d3c                	ld	a5,88(a0)
    80002894:	63c8                	ld	a0,128(a5)
    80002896:	b7f5                	j	80002882 <argraw+0x2c>
    return p->trapframe->a3;
    80002898:	6d3c                	ld	a5,88(a0)
    8000289a:	67c8                	ld	a0,136(a5)
    8000289c:	b7dd                	j	80002882 <argraw+0x2c>
    return p->trapframe->a4;
    8000289e:	6d3c                	ld	a5,88(a0)
    800028a0:	6bc8                	ld	a0,144(a5)
    800028a2:	b7c5                	j	80002882 <argraw+0x2c>
    return p->trapframe->a5;
    800028a4:	6d3c                	ld	a5,88(a0)
    800028a6:	6fc8                	ld	a0,152(a5)
    800028a8:	bfe9                	j	80002882 <argraw+0x2c>
  panic("argraw");
    800028aa:	00005517          	auipc	a0,0x5
    800028ae:	ac650513          	addi	a0,a0,-1338 # 80007370 <etext+0x370>
    800028b2:	f73fd0ef          	jal	80000824 <panic>

00000000800028b6 <fetchaddr>:
{
    800028b6:	1101                	addi	sp,sp,-32
    800028b8:	ec06                	sd	ra,24(sp)
    800028ba:	e822                	sd	s0,16(sp)
    800028bc:	e426                	sd	s1,8(sp)
    800028be:	e04a                	sd	s2,0(sp)
    800028c0:	1000                	addi	s0,sp,32
    800028c2:	84aa                	mv	s1,a0
    800028c4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028c6:	870ff0ef          	jal	80001936 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028ca:	653c                	ld	a5,72(a0)
    800028cc:	02f4f663          	bgeu	s1,a5,800028f8 <fetchaddr+0x42>
    800028d0:	00848713          	addi	a4,s1,8
    800028d4:	02e7e463          	bltu	a5,a4,800028fc <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800028d8:	46a1                	li	a3,8
    800028da:	8626                	mv	a2,s1
    800028dc:	85ca                	mv	a1,s2
    800028de:	6928                	ld	a0,80(a0)
    800028e0:	e33fe0ef          	jal	80001712 <copyin>
    800028e4:	00a03533          	snez	a0,a0
    800028e8:	40a0053b          	negw	a0,a0
}
    800028ec:	60e2                	ld	ra,24(sp)
    800028ee:	6442                	ld	s0,16(sp)
    800028f0:	64a2                	ld	s1,8(sp)
    800028f2:	6902                	ld	s2,0(sp)
    800028f4:	6105                	addi	sp,sp,32
    800028f6:	8082                	ret
    return -1;
    800028f8:	557d                	li	a0,-1
    800028fa:	bfcd                	j	800028ec <fetchaddr+0x36>
    800028fc:	557d                	li	a0,-1
    800028fe:	b7fd                	j	800028ec <fetchaddr+0x36>

0000000080002900 <fetchstr>:
{
    80002900:	7179                	addi	sp,sp,-48
    80002902:	f406                	sd	ra,40(sp)
    80002904:	f022                	sd	s0,32(sp)
    80002906:	ec26                	sd	s1,24(sp)
    80002908:	e84a                	sd	s2,16(sp)
    8000290a:	e44e                	sd	s3,8(sp)
    8000290c:	1800                	addi	s0,sp,48
    8000290e:	89aa                	mv	s3,a0
    80002910:	84ae                	mv	s1,a1
    80002912:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002914:	822ff0ef          	jal	80001936 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002918:	86ca                	mv	a3,s2
    8000291a:	864e                	mv	a2,s3
    8000291c:	85a6                	mv	a1,s1
    8000291e:	6928                	ld	a0,80(a0)
    80002920:	bd9fe0ef          	jal	800014f8 <copyinstr>
    80002924:	00054c63          	bltz	a0,8000293c <fetchstr+0x3c>
  return strlen(buf);
    80002928:	8526                	mv	a0,s1
    8000292a:	d58fe0ef          	jal	80000e82 <strlen>
}
    8000292e:	70a2                	ld	ra,40(sp)
    80002930:	7402                	ld	s0,32(sp)
    80002932:	64e2                	ld	s1,24(sp)
    80002934:	6942                	ld	s2,16(sp)
    80002936:	69a2                	ld	s3,8(sp)
    80002938:	6145                	addi	sp,sp,48
    8000293a:	8082                	ret
    return -1;
    8000293c:	557d                	li	a0,-1
    8000293e:	bfc5                	j	8000292e <fetchstr+0x2e>

0000000080002940 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002940:	1101                	addi	sp,sp,-32
    80002942:	ec06                	sd	ra,24(sp)
    80002944:	e822                	sd	s0,16(sp)
    80002946:	e426                	sd	s1,8(sp)
    80002948:	1000                	addi	s0,sp,32
    8000294a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000294c:	f0bff0ef          	jal	80002856 <argraw>
    80002950:	c088                	sw	a0,0(s1)
}
    80002952:	60e2                	ld	ra,24(sp)
    80002954:	6442                	ld	s0,16(sp)
    80002956:	64a2                	ld	s1,8(sp)
    80002958:	6105                	addi	sp,sp,32
    8000295a:	8082                	ret

000000008000295c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000295c:	1101                	addi	sp,sp,-32
    8000295e:	ec06                	sd	ra,24(sp)
    80002960:	e822                	sd	s0,16(sp)
    80002962:	e426                	sd	s1,8(sp)
    80002964:	1000                	addi	s0,sp,32
    80002966:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002968:	eefff0ef          	jal	80002856 <argraw>
    8000296c:	e088                	sd	a0,0(s1)
}
    8000296e:	60e2                	ld	ra,24(sp)
    80002970:	6442                	ld	s0,16(sp)
    80002972:	64a2                	ld	s1,8(sp)
    80002974:	6105                	addi	sp,sp,32
    80002976:	8082                	ret

0000000080002978 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002978:	1101                	addi	sp,sp,-32
    8000297a:	ec06                	sd	ra,24(sp)
    8000297c:	e822                	sd	s0,16(sp)
    8000297e:	e426                	sd	s1,8(sp)
    80002980:	e04a                	sd	s2,0(sp)
    80002982:	1000                	addi	s0,sp,32
    80002984:	892e                	mv	s2,a1
    80002986:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002988:	ecfff0ef          	jal	80002856 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000298c:	8626                	mv	a2,s1
    8000298e:	85ca                	mv	a1,s2
    80002990:	f71ff0ef          	jal	80002900 <fetchstr>
}
    80002994:	60e2                	ld	ra,24(sp)
    80002996:	6442                	ld	s0,16(sp)
    80002998:	64a2                	ld	s1,8(sp)
    8000299a:	6902                	ld	s2,0(sp)
    8000299c:	6105                	addi	sp,sp,32
    8000299e:	8082                	ret

00000000800029a0 <syscall>:
[SYS_boostproc] sys_boostproc,
};

void
syscall(void)
{
    800029a0:	1101                	addi	sp,sp,-32
    800029a2:	ec06                	sd	ra,24(sp)
    800029a4:	e822                	sd	s0,16(sp)
    800029a6:	e426                	sd	s1,8(sp)
    800029a8:	e04a                	sd	s2,0(sp)
    800029aa:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029ac:	f8bfe0ef          	jal	80001936 <myproc>
    800029b0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029b2:	05853903          	ld	s2,88(a0)
    800029b6:	0a893783          	ld	a5,168(s2)
    800029ba:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029be:	37fd                	addiw	a5,a5,-1
    800029c0:	4759                	li	a4,22
    800029c2:	00f76f63          	bltu	a4,a5,800029e0 <syscall+0x40>
    800029c6:	00369713          	slli	a4,a3,0x3
    800029ca:	00005797          	auipc	a5,0x5
    800029ce:	dae78793          	addi	a5,a5,-594 # 80007778 <syscalls>
    800029d2:	97ba                	add	a5,a5,a4
    800029d4:	639c                	ld	a5,0(a5)
    800029d6:	c789                	beqz	a5,800029e0 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029d8:	9782                	jalr	a5
    800029da:	06a93823          	sd	a0,112(s2)
    800029de:	a829                	j	800029f8 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800029e0:	15848613          	addi	a2,s1,344
    800029e4:	588c                	lw	a1,48(s1)
    800029e6:	00005517          	auipc	a0,0x5
    800029ea:	99250513          	addi	a0,a0,-1646 # 80007378 <etext+0x378>
    800029ee:	b0dfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800029f2:	6cbc                	ld	a5,88(s1)
    800029f4:	577d                	li	a4,-1
    800029f6:	fbb8                	sd	a4,112(a5)
  }
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6902                	ld	s2,0(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret

0000000080002a04 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a04:	1101                	addi	sp,sp,-32
    80002a06:	ec06                	sd	ra,24(sp)
    80002a08:	e822                	sd	s0,16(sp)
    80002a0a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a0c:	fec40593          	addi	a1,s0,-20
    80002a10:	4501                	li	a0,0
    80002a12:	f2fff0ef          	jal	80002940 <argint>
  kexit(n);
    80002a16:	fec42503          	lw	a0,-20(s0)
    80002a1a:	ef4ff0ef          	jal	8000210e <kexit>
  return 0;  // not reached
}
    80002a1e:	4501                	li	a0,0
    80002a20:	60e2                	ld	ra,24(sp)
    80002a22:	6442                	ld	s0,16(sp)
    80002a24:	6105                	addi	sp,sp,32
    80002a26:	8082                	ret

0000000080002a28 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a28:	1141                	addi	sp,sp,-16
    80002a2a:	e406                	sd	ra,8(sp)
    80002a2c:	e022                	sd	s0,0(sp)
    80002a2e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a30:	f07fe0ef          	jal	80001936 <myproc>
}
    80002a34:	5908                	lw	a0,48(a0)
    80002a36:	60a2                	ld	ra,8(sp)
    80002a38:	6402                	ld	s0,0(sp)
    80002a3a:	0141                	addi	sp,sp,16
    80002a3c:	8082                	ret

0000000080002a3e <sys_fork>:

uint64
sys_fork(void)
{
    80002a3e:	1141                	addi	sp,sp,-16
    80002a40:	e406                	sd	ra,8(sp)
    80002a42:	e022                	sd	s0,0(sp)
    80002a44:	0800                	addi	s0,sp,16
  return kfork();
    80002a46:	a64ff0ef          	jal	80001caa <kfork>
}
    80002a4a:	60a2                	ld	ra,8(sp)
    80002a4c:	6402                	ld	s0,0(sp)
    80002a4e:	0141                	addi	sp,sp,16
    80002a50:	8082                	ret

0000000080002a52 <sys_wait>:

uint64
sys_wait(void)
{
    80002a52:	1101                	addi	sp,sp,-32
    80002a54:	ec06                	sd	ra,24(sp)
    80002a56:	e822                	sd	s0,16(sp)
    80002a58:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a5a:	fe840593          	addi	a1,s0,-24
    80002a5e:	4501                	li	a0,0
    80002a60:	efdff0ef          	jal	8000295c <argaddr>
  return kwait(p);
    80002a64:	fe843503          	ld	a0,-24(s0)
    80002a68:	801ff0ef          	jal	80002268 <kwait>
}
    80002a6c:	60e2                	ld	ra,24(sp)
    80002a6e:	6442                	ld	s0,16(sp)
    80002a70:	6105                	addi	sp,sp,32
    80002a72:	8082                	ret

0000000080002a74 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a74:	7179                	addi	sp,sp,-48
    80002a76:	f406                	sd	ra,40(sp)
    80002a78:	f022                	sd	s0,32(sp)
    80002a7a:	ec26                	sd	s1,24(sp)
    80002a7c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a7e:	fd840593          	addi	a1,s0,-40
    80002a82:	4501                	li	a0,0
    80002a84:	ebdff0ef          	jal	80002940 <argint>
  argint(1, &t);
    80002a88:	fdc40593          	addi	a1,s0,-36
    80002a8c:	4505                	li	a0,1
    80002a8e:	eb3ff0ef          	jal	80002940 <argint>
  addr = myproc()->sz;
    80002a92:	ea5fe0ef          	jal	80001936 <myproc>
    80002a96:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002a98:	fdc42703          	lw	a4,-36(s0)
    80002a9c:	4785                	li	a5,1
    80002a9e:	02f70763          	beq	a4,a5,80002acc <sys_sbrk+0x58>
    80002aa2:	fd842783          	lw	a5,-40(s0)
    80002aa6:	0207c363          	bltz	a5,80002acc <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002aaa:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002aac:	02000737          	lui	a4,0x2000
    80002ab0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ab2:	0736                	slli	a4,a4,0xd
    80002ab4:	02f76a63          	bltu	a4,a5,80002ae8 <sys_sbrk+0x74>
    80002ab8:	0297e863          	bltu	a5,s1,80002ae8 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002abc:	e7bfe0ef          	jal	80001936 <myproc>
    80002ac0:	fd842703          	lw	a4,-40(s0)
    80002ac4:	653c                	ld	a5,72(a0)
    80002ac6:	97ba                	add	a5,a5,a4
    80002ac8:	e53c                	sd	a5,72(a0)
    80002aca:	a039                	j	80002ad8 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002acc:	fd842503          	lw	a0,-40(s0)
    80002ad0:	978ff0ef          	jal	80001c48 <growproc>
    80002ad4:	00054863          	bltz	a0,80002ae4 <sys_sbrk+0x70>
  }
  return addr;
}
    80002ad8:	8526                	mv	a0,s1
    80002ada:	70a2                	ld	ra,40(sp)
    80002adc:	7402                	ld	s0,32(sp)
    80002ade:	64e2                	ld	s1,24(sp)
    80002ae0:	6145                	addi	sp,sp,48
    80002ae2:	8082                	ret
      return -1;
    80002ae4:	54fd                	li	s1,-1
    80002ae6:	bfcd                	j	80002ad8 <sys_sbrk+0x64>
      return -1;
    80002ae8:	54fd                	li	s1,-1
    80002aea:	b7fd                	j	80002ad8 <sys_sbrk+0x64>

0000000080002aec <sys_pause>:

uint64
sys_pause(void)
{
    80002aec:	7139                	addi	sp,sp,-64
    80002aee:	fc06                	sd	ra,56(sp)
    80002af0:	f822                	sd	s0,48(sp)
    80002af2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002af4:	fcc40593          	addi	a1,s0,-52
    80002af8:	4501                	li	a0,0
    80002afa:	e47ff0ef          	jal	80002940 <argint>
  if(n < 0)
    80002afe:	fcc42783          	lw	a5,-52(s0)
    80002b02:	0607c863          	bltz	a5,80002b72 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002b06:	00013517          	auipc	a0,0x13
    80002b0a:	0da50513          	addi	a0,a0,218 # 80015be0 <tickslock>
    80002b0e:	91afe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002b12:	fcc42783          	lw	a5,-52(s0)
    80002b16:	c3b9                	beqz	a5,80002b5c <sys_pause+0x70>
    80002b18:	f426                	sd	s1,40(sp)
    80002b1a:	f04a                	sd	s2,32(sp)
    80002b1c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002b1e:	00005997          	auipc	s3,0x5
    80002b22:	d729a983          	lw	s3,-654(s3) # 80007890 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b26:	00013917          	auipc	s2,0x13
    80002b2a:	0ba90913          	addi	s2,s2,186 # 80015be0 <tickslock>
    80002b2e:	00005497          	auipc	s1,0x5
    80002b32:	d6248493          	addi	s1,s1,-670 # 80007890 <ticks>
    if(killed(myproc())){
    80002b36:	e01fe0ef          	jal	80001936 <myproc>
    80002b3a:	f04ff0ef          	jal	8000223e <killed>
    80002b3e:	ed0d                	bnez	a0,80002b78 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002b40:	85ca                	mv	a1,s2
    80002b42:	8526                	mv	a0,s1
    80002b44:	cbeff0ef          	jal	80002002 <sleep>
  while(ticks - ticks0 < n){
    80002b48:	409c                	lw	a5,0(s1)
    80002b4a:	413787bb          	subw	a5,a5,s3
    80002b4e:	fcc42703          	lw	a4,-52(s0)
    80002b52:	fee7e2e3          	bltu	a5,a4,80002b36 <sys_pause+0x4a>
    80002b56:	74a2                	ld	s1,40(sp)
    80002b58:	7902                	ld	s2,32(sp)
    80002b5a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b5c:	00013517          	auipc	a0,0x13
    80002b60:	08450513          	addi	a0,a0,132 # 80015be0 <tickslock>
    80002b64:	958fe0ef          	jal	80000cbc <release>
  return 0;
    80002b68:	4501                	li	a0,0
}
    80002b6a:	70e2                	ld	ra,56(sp)
    80002b6c:	7442                	ld	s0,48(sp)
    80002b6e:	6121                	addi	sp,sp,64
    80002b70:	8082                	ret
    n = 0;
    80002b72:	fc042623          	sw	zero,-52(s0)
    80002b76:	bf41                	j	80002b06 <sys_pause+0x1a>
      release(&tickslock);
    80002b78:	00013517          	auipc	a0,0x13
    80002b7c:	06850513          	addi	a0,a0,104 # 80015be0 <tickslock>
    80002b80:	93cfe0ef          	jal	80000cbc <release>
      return -1;
    80002b84:	557d                	li	a0,-1
    80002b86:	74a2                	ld	s1,40(sp)
    80002b88:	7902                	ld	s2,32(sp)
    80002b8a:	69e2                	ld	s3,24(sp)
    80002b8c:	bff9                	j	80002b6a <sys_pause+0x7e>

0000000080002b8e <sys_kill>:

uint64
sys_kill(void)
{
    80002b8e:	1101                	addi	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b96:	fec40593          	addi	a1,s0,-20
    80002b9a:	4501                	li	a0,0
    80002b9c:	da5ff0ef          	jal	80002940 <argint>
  return kkill(pid);
    80002ba0:	fec42503          	lw	a0,-20(s0)
    80002ba4:	e10ff0ef          	jal	800021b4 <kkill>
}
    80002ba8:	60e2                	ld	ra,24(sp)
    80002baa:	6442                	ld	s0,16(sp)
    80002bac:	6105                	addi	sp,sp,32
    80002bae:	8082                	ret

0000000080002bb0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bba:	00013517          	auipc	a0,0x13
    80002bbe:	02650513          	addi	a0,a0,38 # 80015be0 <tickslock>
    80002bc2:	866fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002bc6:	00005797          	auipc	a5,0x5
    80002bca:	cca7a783          	lw	a5,-822(a5) # 80007890 <ticks>
    80002bce:	84be                	mv	s1,a5
  release(&tickslock);
    80002bd0:	00013517          	auipc	a0,0x13
    80002bd4:	01050513          	addi	a0,a0,16 # 80015be0 <tickslock>
    80002bd8:	8e4fe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002bdc:	02049513          	slli	a0,s1,0x20
    80002be0:	9101                	srli	a0,a0,0x20
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	64a2                	ld	s1,8(sp)
    80002be8:	6105                	addi	sp,sp,32
    80002bea:	8082                	ret

0000000080002bec <sys_getprocinfo>:

// Get process information for MLFQ debugging
uint64
sys_getprocinfo(void)
{
    80002bec:	7139                	addi	sp,sp,-64
    80002bee:	fc06                	sd	ra,56(sp)
    80002bf0:	f822                	sd	s0,48(sp)
    80002bf2:	f426                	sd	s1,40(sp)
    80002bf4:	0080                	addi	s0,sp,64
  uint64 addr;
  struct proc *p = myproc();
    80002bf6:	d41fe0ef          	jal	80001936 <myproc>
    80002bfa:	84aa                	mv	s1,a0
  
  argaddr(0, &addr);
    80002bfc:	fd840593          	addi	a1,s0,-40
    80002c00:	4501                	li	a0,0
    80002c02:	d5bff0ef          	jal	8000295c <argaddr>
    int state;
    int priority;
    int time_slices;
  } info;
  
  acquire(&p->lock);
    80002c06:	8526                	mv	a0,s1
    80002c08:	820fe0ef          	jal	80000c28 <acquire>
  info.pid = p->pid;
    80002c0c:	589c                	lw	a5,48(s1)
    80002c0e:	fcf42423          	sw	a5,-56(s0)
  info.state = p->state;
    80002c12:	4c9c                	lw	a5,24(s1)
    80002c14:	fcf42623          	sw	a5,-52(s0)
  info.priority = p->priority;
    80002c18:	1684a783          	lw	a5,360(s1)
    80002c1c:	fcf42823          	sw	a5,-48(s0)
  info.time_slices = p->time_slices;
    80002c20:	16c4a783          	lw	a5,364(s1)
    80002c24:	fcf42a23          	sw	a5,-44(s0)
  release(&p->lock);
    80002c28:	8526                	mv	a0,s1
    80002c2a:	892fe0ef          	jal	80000cbc <release>
  
  if(copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    80002c2e:	46c1                	li	a3,16
    80002c30:	fc840613          	addi	a2,s0,-56
    80002c34:	fd843583          	ld	a1,-40(s0)
    80002c38:	68a8                	ld	a0,80(s1)
    80002c3a:	a1bfe0ef          	jal	80001654 <copyout>
    return -1;
  
  return 0;
}
    80002c3e:	957d                	srai	a0,a0,0x3f
    80002c40:	70e2                	ld	ra,56(sp)
    80002c42:	7442                	ld	s0,48(sp)
    80002c44:	74a2                	ld	s1,40(sp)
    80002c46:	6121                	addi	sp,sp,64
    80002c48:	8082                	ret

0000000080002c4a <sys_boostproc>:

uint64
sys_boostproc(void)
{
    80002c4a:	1141                	addi	sp,sp,-16
    80002c4c:	e406                	sd	ra,8(sp)
    80002c4e:	e022                	sd	s0,0(sp)
    80002c50:	0800                	addi	s0,sp,16
  extern void boost_all_priorities(void);
  
  boost_all_priorities();
    80002c52:	966ff0ef          	jal	80001db8 <boost_all_priorities>
  
  return 0;
    80002c56:	4501                	li	a0,0
    80002c58:	60a2                	ld	ra,8(sp)
    80002c5a:	6402                	ld	s0,0(sp)
    80002c5c:	0141                	addi	sp,sp,16
    80002c5e:	8082                	ret

0000000080002c60 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c60:	7179                	addi	sp,sp,-48
    80002c62:	f406                	sd	ra,40(sp)
    80002c64:	f022                	sd	s0,32(sp)
    80002c66:	ec26                	sd	s1,24(sp)
    80002c68:	e84a                	sd	s2,16(sp)
    80002c6a:	e44e                	sd	s3,8(sp)
    80002c6c:	e052                	sd	s4,0(sp)
    80002c6e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c70:	00004597          	auipc	a1,0x4
    80002c74:	72858593          	addi	a1,a1,1832 # 80007398 <etext+0x398>
    80002c78:	00013517          	auipc	a0,0x13
    80002c7c:	f8050513          	addi	a0,a0,-128 # 80015bf8 <bcache>
    80002c80:	f1ffd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c84:	0001b797          	auipc	a5,0x1b
    80002c88:	f7478793          	addi	a5,a5,-140 # 8001dbf8 <bcache+0x8000>
    80002c8c:	0001b717          	auipc	a4,0x1b
    80002c90:	1d470713          	addi	a4,a4,468 # 8001de60 <bcache+0x8268>
    80002c94:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c98:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c9c:	00013497          	auipc	s1,0x13
    80002ca0:	f7448493          	addi	s1,s1,-140 # 80015c10 <bcache+0x18>
    b->next = bcache.head.next;
    80002ca4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ca6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ca8:	00004a17          	auipc	s4,0x4
    80002cac:	6f8a0a13          	addi	s4,s4,1784 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002cb0:	2b893783          	ld	a5,696(s2)
    80002cb4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002cb6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002cba:	85d2                	mv	a1,s4
    80002cbc:	01048513          	addi	a0,s1,16
    80002cc0:	328010ef          	jal	80003fe8 <initsleeplock>
    bcache.head.next->prev = b;
    80002cc4:	2b893783          	ld	a5,696(s2)
    80002cc8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cca:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cce:	45848493          	addi	s1,s1,1112
    80002cd2:	fd349fe3          	bne	s1,s3,80002cb0 <binit+0x50>
  }
}
    80002cd6:	70a2                	ld	ra,40(sp)
    80002cd8:	7402                	ld	s0,32(sp)
    80002cda:	64e2                	ld	s1,24(sp)
    80002cdc:	6942                	ld	s2,16(sp)
    80002cde:	69a2                	ld	s3,8(sp)
    80002ce0:	6a02                	ld	s4,0(sp)
    80002ce2:	6145                	addi	sp,sp,48
    80002ce4:	8082                	ret

0000000080002ce6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ce6:	7179                	addi	sp,sp,-48
    80002ce8:	f406                	sd	ra,40(sp)
    80002cea:	f022                	sd	s0,32(sp)
    80002cec:	ec26                	sd	s1,24(sp)
    80002cee:	e84a                	sd	s2,16(sp)
    80002cf0:	e44e                	sd	s3,8(sp)
    80002cf2:	1800                	addi	s0,sp,48
    80002cf4:	892a                	mv	s2,a0
    80002cf6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002cf8:	00013517          	auipc	a0,0x13
    80002cfc:	f0050513          	addi	a0,a0,-256 # 80015bf8 <bcache>
    80002d00:	f29fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d04:	0001b497          	auipc	s1,0x1b
    80002d08:	1ac4b483          	ld	s1,428(s1) # 8001deb0 <bcache+0x82b8>
    80002d0c:	0001b797          	auipc	a5,0x1b
    80002d10:	15478793          	addi	a5,a5,340 # 8001de60 <bcache+0x8268>
    80002d14:	02f48b63          	beq	s1,a5,80002d4a <bread+0x64>
    80002d18:	873e                	mv	a4,a5
    80002d1a:	a021                	j	80002d22 <bread+0x3c>
    80002d1c:	68a4                	ld	s1,80(s1)
    80002d1e:	02e48663          	beq	s1,a4,80002d4a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d22:	449c                	lw	a5,8(s1)
    80002d24:	ff279ce3          	bne	a5,s2,80002d1c <bread+0x36>
    80002d28:	44dc                	lw	a5,12(s1)
    80002d2a:	ff3799e3          	bne	a5,s3,80002d1c <bread+0x36>
      b->refcnt++;
    80002d2e:	40bc                	lw	a5,64(s1)
    80002d30:	2785                	addiw	a5,a5,1
    80002d32:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d34:	00013517          	auipc	a0,0x13
    80002d38:	ec450513          	addi	a0,a0,-316 # 80015bf8 <bcache>
    80002d3c:	f81fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002d40:	01048513          	addi	a0,s1,16
    80002d44:	2da010ef          	jal	8000401e <acquiresleep>
      return b;
    80002d48:	a889                	j	80002d9a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d4a:	0001b497          	auipc	s1,0x1b
    80002d4e:	15e4b483          	ld	s1,350(s1) # 8001dea8 <bcache+0x82b0>
    80002d52:	0001b797          	auipc	a5,0x1b
    80002d56:	10e78793          	addi	a5,a5,270 # 8001de60 <bcache+0x8268>
    80002d5a:	00f48863          	beq	s1,a5,80002d6a <bread+0x84>
    80002d5e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d60:	40bc                	lw	a5,64(s1)
    80002d62:	cb91                	beqz	a5,80002d76 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d64:	64a4                	ld	s1,72(s1)
    80002d66:	fee49de3          	bne	s1,a4,80002d60 <bread+0x7a>
  panic("bget: no buffers");
    80002d6a:	00004517          	auipc	a0,0x4
    80002d6e:	63e50513          	addi	a0,a0,1598 # 800073a8 <etext+0x3a8>
    80002d72:	ab3fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002d76:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d7a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d7e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d82:	4785                	li	a5,1
    80002d84:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d86:	00013517          	auipc	a0,0x13
    80002d8a:	e7250513          	addi	a0,a0,-398 # 80015bf8 <bcache>
    80002d8e:	f2ffd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002d92:	01048513          	addi	a0,s1,16
    80002d96:	288010ef          	jal	8000401e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d9a:	409c                	lw	a5,0(s1)
    80002d9c:	cb89                	beqz	a5,80002dae <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d9e:	8526                	mv	a0,s1
    80002da0:	70a2                	ld	ra,40(sp)
    80002da2:	7402                	ld	s0,32(sp)
    80002da4:	64e2                	ld	s1,24(sp)
    80002da6:	6942                	ld	s2,16(sp)
    80002da8:	69a2                	ld	s3,8(sp)
    80002daa:	6145                	addi	sp,sp,48
    80002dac:	8082                	ret
    virtio_disk_rw(b, 0);
    80002dae:	4581                	li	a1,0
    80002db0:	8526                	mv	a0,s1
    80002db2:	2ef020ef          	jal	800058a0 <virtio_disk_rw>
    b->valid = 1;
    80002db6:	4785                	li	a5,1
    80002db8:	c09c                	sw	a5,0(s1)
  return b;
    80002dba:	b7d5                	j	80002d9e <bread+0xb8>

0000000080002dbc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002dbc:	1101                	addi	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	e426                	sd	s1,8(sp)
    80002dc4:	1000                	addi	s0,sp,32
    80002dc6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002dc8:	0541                	addi	a0,a0,16
    80002dca:	2d2010ef          	jal	8000409c <holdingsleep>
    80002dce:	c911                	beqz	a0,80002de2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002dd0:	4585                	li	a1,1
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	2cd020ef          	jal	800058a0 <virtio_disk_rw>
}
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret
    panic("bwrite");
    80002de2:	00004517          	auipc	a0,0x4
    80002de6:	5de50513          	addi	a0,a0,1502 # 800073c0 <etext+0x3c0>
    80002dea:	a3bfd0ef          	jal	80000824 <panic>

0000000080002dee <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002dee:	1101                	addi	sp,sp,-32
    80002df0:	ec06                	sd	ra,24(sp)
    80002df2:	e822                	sd	s0,16(sp)
    80002df4:	e426                	sd	s1,8(sp)
    80002df6:	e04a                	sd	s2,0(sp)
    80002df8:	1000                	addi	s0,sp,32
    80002dfa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002dfc:	01050913          	addi	s2,a0,16
    80002e00:	854a                	mv	a0,s2
    80002e02:	29a010ef          	jal	8000409c <holdingsleep>
    80002e06:	c125                	beqz	a0,80002e66 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e08:	854a                	mv	a0,s2
    80002e0a:	25a010ef          	jal	80004064 <releasesleep>

  acquire(&bcache.lock);
    80002e0e:	00013517          	auipc	a0,0x13
    80002e12:	dea50513          	addi	a0,a0,-534 # 80015bf8 <bcache>
    80002e16:	e13fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e1a:	40bc                	lw	a5,64(s1)
    80002e1c:	37fd                	addiw	a5,a5,-1
    80002e1e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e20:	e79d                	bnez	a5,80002e4e <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e22:	68b8                	ld	a4,80(s1)
    80002e24:	64bc                	ld	a5,72(s1)
    80002e26:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e28:	68b8                	ld	a4,80(s1)
    80002e2a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e2c:	0001b797          	auipc	a5,0x1b
    80002e30:	dcc78793          	addi	a5,a5,-564 # 8001dbf8 <bcache+0x8000>
    80002e34:	2b87b703          	ld	a4,696(a5)
    80002e38:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e3a:	0001b717          	auipc	a4,0x1b
    80002e3e:	02670713          	addi	a4,a4,38 # 8001de60 <bcache+0x8268>
    80002e42:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e44:	2b87b703          	ld	a4,696(a5)
    80002e48:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e4a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e4e:	00013517          	auipc	a0,0x13
    80002e52:	daa50513          	addi	a0,a0,-598 # 80015bf8 <bcache>
    80002e56:	e67fd0ef          	jal	80000cbc <release>
}
    80002e5a:	60e2                	ld	ra,24(sp)
    80002e5c:	6442                	ld	s0,16(sp)
    80002e5e:	64a2                	ld	s1,8(sp)
    80002e60:	6902                	ld	s2,0(sp)
    80002e62:	6105                	addi	sp,sp,32
    80002e64:	8082                	ret
    panic("brelse");
    80002e66:	00004517          	auipc	a0,0x4
    80002e6a:	56250513          	addi	a0,a0,1378 # 800073c8 <etext+0x3c8>
    80002e6e:	9b7fd0ef          	jal	80000824 <panic>

0000000080002e72 <bpin>:

void
bpin(struct buf *b) {
    80002e72:	1101                	addi	sp,sp,-32
    80002e74:	ec06                	sd	ra,24(sp)
    80002e76:	e822                	sd	s0,16(sp)
    80002e78:	e426                	sd	s1,8(sp)
    80002e7a:	1000                	addi	s0,sp,32
    80002e7c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e7e:	00013517          	auipc	a0,0x13
    80002e82:	d7a50513          	addi	a0,a0,-646 # 80015bf8 <bcache>
    80002e86:	da3fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002e8a:	40bc                	lw	a5,64(s1)
    80002e8c:	2785                	addiw	a5,a5,1
    80002e8e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e90:	00013517          	auipc	a0,0x13
    80002e94:	d6850513          	addi	a0,a0,-664 # 80015bf8 <bcache>
    80002e98:	e25fd0ef          	jal	80000cbc <release>
}
    80002e9c:	60e2                	ld	ra,24(sp)
    80002e9e:	6442                	ld	s0,16(sp)
    80002ea0:	64a2                	ld	s1,8(sp)
    80002ea2:	6105                	addi	sp,sp,32
    80002ea4:	8082                	ret

0000000080002ea6 <bunpin>:

void
bunpin(struct buf *b) {
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	e426                	sd	s1,8(sp)
    80002eae:	1000                	addi	s0,sp,32
    80002eb0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002eb2:	00013517          	auipc	a0,0x13
    80002eb6:	d4650513          	addi	a0,a0,-698 # 80015bf8 <bcache>
    80002eba:	d6ffd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002ebe:	40bc                	lw	a5,64(s1)
    80002ec0:	37fd                	addiw	a5,a5,-1
    80002ec2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ec4:	00013517          	auipc	a0,0x13
    80002ec8:	d3450513          	addi	a0,a0,-716 # 80015bf8 <bcache>
    80002ecc:	df1fd0ef          	jal	80000cbc <release>
}
    80002ed0:	60e2                	ld	ra,24(sp)
    80002ed2:	6442                	ld	s0,16(sp)
    80002ed4:	64a2                	ld	s1,8(sp)
    80002ed6:	6105                	addi	sp,sp,32
    80002ed8:	8082                	ret

0000000080002eda <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002eda:	1101                	addi	sp,sp,-32
    80002edc:	ec06                	sd	ra,24(sp)
    80002ede:	e822                	sd	s0,16(sp)
    80002ee0:	e426                	sd	s1,8(sp)
    80002ee2:	e04a                	sd	s2,0(sp)
    80002ee4:	1000                	addi	s0,sp,32
    80002ee6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ee8:	00d5d79b          	srliw	a5,a1,0xd
    80002eec:	0001b597          	auipc	a1,0x1b
    80002ef0:	3e85a583          	lw	a1,1000(a1) # 8001e2d4 <sb+0x1c>
    80002ef4:	9dbd                	addw	a1,a1,a5
    80002ef6:	df1ff0ef          	jal	80002ce6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002efa:	0074f713          	andi	a4,s1,7
    80002efe:	4785                	li	a5,1
    80002f00:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f04:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002f06:	90d9                	srli	s1,s1,0x36
    80002f08:	00950733          	add	a4,a0,s1
    80002f0c:	05874703          	lbu	a4,88(a4)
    80002f10:	00e7f6b3          	and	a3,a5,a4
    80002f14:	c29d                	beqz	a3,80002f3a <bfree+0x60>
    80002f16:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f18:	94aa                	add	s1,s1,a0
    80002f1a:	fff7c793          	not	a5,a5
    80002f1e:	8f7d                	and	a4,a4,a5
    80002f20:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f24:	000010ef          	jal	80003f24 <log_write>
  brelse(bp);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	ec5ff0ef          	jal	80002dee <brelse>
}
    80002f2e:	60e2                	ld	ra,24(sp)
    80002f30:	6442                	ld	s0,16(sp)
    80002f32:	64a2                	ld	s1,8(sp)
    80002f34:	6902                	ld	s2,0(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret
    panic("freeing free block");
    80002f3a:	00004517          	auipc	a0,0x4
    80002f3e:	49650513          	addi	a0,a0,1174 # 800073d0 <etext+0x3d0>
    80002f42:	8e3fd0ef          	jal	80000824 <panic>

0000000080002f46 <balloc>:
{
    80002f46:	715d                	addi	sp,sp,-80
    80002f48:	e486                	sd	ra,72(sp)
    80002f4a:	e0a2                	sd	s0,64(sp)
    80002f4c:	fc26                	sd	s1,56(sp)
    80002f4e:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002f50:	0001b797          	auipc	a5,0x1b
    80002f54:	36c7a783          	lw	a5,876(a5) # 8001e2bc <sb+0x4>
    80002f58:	0e078263          	beqz	a5,8000303c <balloc+0xf6>
    80002f5c:	f84a                	sd	s2,48(sp)
    80002f5e:	f44e                	sd	s3,40(sp)
    80002f60:	f052                	sd	s4,32(sp)
    80002f62:	ec56                	sd	s5,24(sp)
    80002f64:	e85a                	sd	s6,16(sp)
    80002f66:	e45e                	sd	s7,8(sp)
    80002f68:	e062                	sd	s8,0(sp)
    80002f6a:	8baa                	mv	s7,a0
    80002f6c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f6e:	0001bb17          	auipc	s6,0x1b
    80002f72:	34ab0b13          	addi	s6,s6,842 # 8001e2b8 <sb>
      m = 1 << (bi % 8);
    80002f76:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f78:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f7a:	6c09                	lui	s8,0x2
    80002f7c:	a09d                	j	80002fe2 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f7e:	97ca                	add	a5,a5,s2
    80002f80:	8e55                	or	a2,a2,a3
    80002f82:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f86:	854a                	mv	a0,s2
    80002f88:	79d000ef          	jal	80003f24 <log_write>
        brelse(bp);
    80002f8c:	854a                	mv	a0,s2
    80002f8e:	e61ff0ef          	jal	80002dee <brelse>
  bp = bread(dev, bno);
    80002f92:	85a6                	mv	a1,s1
    80002f94:	855e                	mv	a0,s7
    80002f96:	d51ff0ef          	jal	80002ce6 <bread>
    80002f9a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f9c:	40000613          	li	a2,1024
    80002fa0:	4581                	li	a1,0
    80002fa2:	05850513          	addi	a0,a0,88
    80002fa6:	d53fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80002faa:	854a                	mv	a0,s2
    80002fac:	779000ef          	jal	80003f24 <log_write>
  brelse(bp);
    80002fb0:	854a                	mv	a0,s2
    80002fb2:	e3dff0ef          	jal	80002dee <brelse>
}
    80002fb6:	7942                	ld	s2,48(sp)
    80002fb8:	79a2                	ld	s3,40(sp)
    80002fba:	7a02                	ld	s4,32(sp)
    80002fbc:	6ae2                	ld	s5,24(sp)
    80002fbe:	6b42                	ld	s6,16(sp)
    80002fc0:	6ba2                	ld	s7,8(sp)
    80002fc2:	6c02                	ld	s8,0(sp)
}
    80002fc4:	8526                	mv	a0,s1
    80002fc6:	60a6                	ld	ra,72(sp)
    80002fc8:	6406                	ld	s0,64(sp)
    80002fca:	74e2                	ld	s1,56(sp)
    80002fcc:	6161                	addi	sp,sp,80
    80002fce:	8082                	ret
    brelse(bp);
    80002fd0:	854a                	mv	a0,s2
    80002fd2:	e1dff0ef          	jal	80002dee <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002fd6:	015c0abb          	addw	s5,s8,s5
    80002fda:	004b2783          	lw	a5,4(s6)
    80002fde:	04faf863          	bgeu	s5,a5,8000302e <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002fe2:	40dad59b          	sraiw	a1,s5,0xd
    80002fe6:	01cb2783          	lw	a5,28(s6)
    80002fea:	9dbd                	addw	a1,a1,a5
    80002fec:	855e                	mv	a0,s7
    80002fee:	cf9ff0ef          	jal	80002ce6 <bread>
    80002ff2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ff4:	004b2503          	lw	a0,4(s6)
    80002ff8:	84d6                	mv	s1,s5
    80002ffa:	4701                	li	a4,0
    80002ffc:	fca4fae3          	bgeu	s1,a0,80002fd0 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003000:	00777693          	andi	a3,a4,7
    80003004:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003008:	41f7579b          	sraiw	a5,a4,0x1f
    8000300c:	01d7d79b          	srliw	a5,a5,0x1d
    80003010:	9fb9                	addw	a5,a5,a4
    80003012:	4037d79b          	sraiw	a5,a5,0x3
    80003016:	00f90633          	add	a2,s2,a5
    8000301a:	05864603          	lbu	a2,88(a2)
    8000301e:	00c6f5b3          	and	a1,a3,a2
    80003022:	ddb1                	beqz	a1,80002f7e <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003024:	2705                	addiw	a4,a4,1
    80003026:	2485                	addiw	s1,s1,1
    80003028:	fd471ae3          	bne	a4,s4,80002ffc <balloc+0xb6>
    8000302c:	b755                	j	80002fd0 <balloc+0x8a>
    8000302e:	7942                	ld	s2,48(sp)
    80003030:	79a2                	ld	s3,40(sp)
    80003032:	7a02                	ld	s4,32(sp)
    80003034:	6ae2                	ld	s5,24(sp)
    80003036:	6b42                	ld	s6,16(sp)
    80003038:	6ba2                	ld	s7,8(sp)
    8000303a:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    8000303c:	00004517          	auipc	a0,0x4
    80003040:	3ac50513          	addi	a0,a0,940 # 800073e8 <etext+0x3e8>
    80003044:	cb6fd0ef          	jal	800004fa <printf>
  return 0;
    80003048:	4481                	li	s1,0
    8000304a:	bfad                	j	80002fc4 <balloc+0x7e>

000000008000304c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000304c:	7179                	addi	sp,sp,-48
    8000304e:	f406                	sd	ra,40(sp)
    80003050:	f022                	sd	s0,32(sp)
    80003052:	ec26                	sd	s1,24(sp)
    80003054:	e84a                	sd	s2,16(sp)
    80003056:	e44e                	sd	s3,8(sp)
    80003058:	1800                	addi	s0,sp,48
    8000305a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000305c:	47ad                	li	a5,11
    8000305e:	02b7e363          	bltu	a5,a1,80003084 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80003062:	02059793          	slli	a5,a1,0x20
    80003066:	01e7d593          	srli	a1,a5,0x1e
    8000306a:	00b509b3          	add	s3,a0,a1
    8000306e:	0509a483          	lw	s1,80(s3)
    80003072:	e0b5                	bnez	s1,800030d6 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003074:	4108                	lw	a0,0(a0)
    80003076:	ed1ff0ef          	jal	80002f46 <balloc>
    8000307a:	84aa                	mv	s1,a0
      if(addr == 0)
    8000307c:	cd29                	beqz	a0,800030d6 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000307e:	04a9a823          	sw	a0,80(s3)
    80003082:	a891                	j	800030d6 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003084:	ff45879b          	addiw	a5,a1,-12
    80003088:	873e                	mv	a4,a5
    8000308a:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    8000308c:	0ff00793          	li	a5,255
    80003090:	06e7e763          	bltu	a5,a4,800030fe <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003094:	08052483          	lw	s1,128(a0)
    80003098:	e891                	bnez	s1,800030ac <bmap+0x60>
      addr = balloc(ip->dev);
    8000309a:	4108                	lw	a0,0(a0)
    8000309c:	eabff0ef          	jal	80002f46 <balloc>
    800030a0:	84aa                	mv	s1,a0
      if(addr == 0)
    800030a2:	c915                	beqz	a0,800030d6 <bmap+0x8a>
    800030a4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030a6:	08a92023          	sw	a0,128(s2)
    800030aa:	a011                	j	800030ae <bmap+0x62>
    800030ac:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030ae:	85a6                	mv	a1,s1
    800030b0:	00092503          	lw	a0,0(s2)
    800030b4:	c33ff0ef          	jal	80002ce6 <bread>
    800030b8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800030ba:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800030be:	02099713          	slli	a4,s3,0x20
    800030c2:	01e75593          	srli	a1,a4,0x1e
    800030c6:	97ae                	add	a5,a5,a1
    800030c8:	89be                	mv	s3,a5
    800030ca:	4384                	lw	s1,0(a5)
    800030cc:	cc89                	beqz	s1,800030e6 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030ce:	8552                	mv	a0,s4
    800030d0:	d1fff0ef          	jal	80002dee <brelse>
    return addr;
    800030d4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030d6:	8526                	mv	a0,s1
    800030d8:	70a2                	ld	ra,40(sp)
    800030da:	7402                	ld	s0,32(sp)
    800030dc:	64e2                	ld	s1,24(sp)
    800030de:	6942                	ld	s2,16(sp)
    800030e0:	69a2                	ld	s3,8(sp)
    800030e2:	6145                	addi	sp,sp,48
    800030e4:	8082                	ret
      addr = balloc(ip->dev);
    800030e6:	00092503          	lw	a0,0(s2)
    800030ea:	e5dff0ef          	jal	80002f46 <balloc>
    800030ee:	84aa                	mv	s1,a0
      if(addr){
    800030f0:	dd79                	beqz	a0,800030ce <bmap+0x82>
        a[bn] = addr;
    800030f2:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800030f6:	8552                	mv	a0,s4
    800030f8:	62d000ef          	jal	80003f24 <log_write>
    800030fc:	bfc9                	j	800030ce <bmap+0x82>
    800030fe:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003100:	00004517          	auipc	a0,0x4
    80003104:	30050513          	addi	a0,a0,768 # 80007400 <etext+0x400>
    80003108:	f1cfd0ef          	jal	80000824 <panic>

000000008000310c <iget>:
{
    8000310c:	7179                	addi	sp,sp,-48
    8000310e:	f406                	sd	ra,40(sp)
    80003110:	f022                	sd	s0,32(sp)
    80003112:	ec26                	sd	s1,24(sp)
    80003114:	e84a                	sd	s2,16(sp)
    80003116:	e44e                	sd	s3,8(sp)
    80003118:	e052                	sd	s4,0(sp)
    8000311a:	1800                	addi	s0,sp,48
    8000311c:	892a                	mv	s2,a0
    8000311e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003120:	0001b517          	auipc	a0,0x1b
    80003124:	1b850513          	addi	a0,a0,440 # 8001e2d8 <itable>
    80003128:	b01fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000312c:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000312e:	0001b497          	auipc	s1,0x1b
    80003132:	1c248493          	addi	s1,s1,450 # 8001e2f0 <itable+0x18>
    80003136:	0001d697          	auipc	a3,0x1d
    8000313a:	c4a68693          	addi	a3,a3,-950 # 8001fd80 <log>
    8000313e:	a809                	j	80003150 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003140:	e781                	bnez	a5,80003148 <iget+0x3c>
    80003142:	00099363          	bnez	s3,80003148 <iget+0x3c>
      empty = ip;
    80003146:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003148:	08848493          	addi	s1,s1,136
    8000314c:	02d48563          	beq	s1,a3,80003176 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003150:	449c                	lw	a5,8(s1)
    80003152:	fef057e3          	blez	a5,80003140 <iget+0x34>
    80003156:	4098                	lw	a4,0(s1)
    80003158:	ff2718e3          	bne	a4,s2,80003148 <iget+0x3c>
    8000315c:	40d8                	lw	a4,4(s1)
    8000315e:	ff4715e3          	bne	a4,s4,80003148 <iget+0x3c>
      ip->ref++;
    80003162:	2785                	addiw	a5,a5,1
    80003164:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003166:	0001b517          	auipc	a0,0x1b
    8000316a:	17250513          	addi	a0,a0,370 # 8001e2d8 <itable>
    8000316e:	b4ffd0ef          	jal	80000cbc <release>
      return ip;
    80003172:	89a6                	mv	s3,s1
    80003174:	a015                	j	80003198 <iget+0x8c>
  if(empty == 0)
    80003176:	02098a63          	beqz	s3,800031aa <iget+0x9e>
  ip->dev = dev;
    8000317a:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000317e:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003182:	4785                	li	a5,1
    80003184:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003188:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000318c:	0001b517          	auipc	a0,0x1b
    80003190:	14c50513          	addi	a0,a0,332 # 8001e2d8 <itable>
    80003194:	b29fd0ef          	jal	80000cbc <release>
}
    80003198:	854e                	mv	a0,s3
    8000319a:	70a2                	ld	ra,40(sp)
    8000319c:	7402                	ld	s0,32(sp)
    8000319e:	64e2                	ld	s1,24(sp)
    800031a0:	6942                	ld	s2,16(sp)
    800031a2:	69a2                	ld	s3,8(sp)
    800031a4:	6a02                	ld	s4,0(sp)
    800031a6:	6145                	addi	sp,sp,48
    800031a8:	8082                	ret
    panic("iget: no inodes");
    800031aa:	00004517          	auipc	a0,0x4
    800031ae:	26e50513          	addi	a0,a0,622 # 80007418 <etext+0x418>
    800031b2:	e72fd0ef          	jal	80000824 <panic>

00000000800031b6 <iinit>:
{
    800031b6:	7179                	addi	sp,sp,-48
    800031b8:	f406                	sd	ra,40(sp)
    800031ba:	f022                	sd	s0,32(sp)
    800031bc:	ec26                	sd	s1,24(sp)
    800031be:	e84a                	sd	s2,16(sp)
    800031c0:	e44e                	sd	s3,8(sp)
    800031c2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031c4:	00004597          	auipc	a1,0x4
    800031c8:	26458593          	addi	a1,a1,612 # 80007428 <etext+0x428>
    800031cc:	0001b517          	auipc	a0,0x1b
    800031d0:	10c50513          	addi	a0,a0,268 # 8001e2d8 <itable>
    800031d4:	9cbfd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    800031d8:	0001b497          	auipc	s1,0x1b
    800031dc:	12848493          	addi	s1,s1,296 # 8001e300 <itable+0x28>
    800031e0:	0001d997          	auipc	s3,0x1d
    800031e4:	bb098993          	addi	s3,s3,-1104 # 8001fd90 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031e8:	00004917          	auipc	s2,0x4
    800031ec:	24890913          	addi	s2,s2,584 # 80007430 <etext+0x430>
    800031f0:	85ca                	mv	a1,s2
    800031f2:	8526                	mv	a0,s1
    800031f4:	5f5000ef          	jal	80003fe8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800031f8:	08848493          	addi	s1,s1,136
    800031fc:	ff349ae3          	bne	s1,s3,800031f0 <iinit+0x3a>
}
    80003200:	70a2                	ld	ra,40(sp)
    80003202:	7402                	ld	s0,32(sp)
    80003204:	64e2                	ld	s1,24(sp)
    80003206:	6942                	ld	s2,16(sp)
    80003208:	69a2                	ld	s3,8(sp)
    8000320a:	6145                	addi	sp,sp,48
    8000320c:	8082                	ret

000000008000320e <ialloc>:
{
    8000320e:	7139                	addi	sp,sp,-64
    80003210:	fc06                	sd	ra,56(sp)
    80003212:	f822                	sd	s0,48(sp)
    80003214:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003216:	0001b717          	auipc	a4,0x1b
    8000321a:	0ae72703          	lw	a4,174(a4) # 8001e2c4 <sb+0xc>
    8000321e:	4785                	li	a5,1
    80003220:	06e7f063          	bgeu	a5,a4,80003280 <ialloc+0x72>
    80003224:	f426                	sd	s1,40(sp)
    80003226:	f04a                	sd	s2,32(sp)
    80003228:	ec4e                	sd	s3,24(sp)
    8000322a:	e852                	sd	s4,16(sp)
    8000322c:	e456                	sd	s5,8(sp)
    8000322e:	e05a                	sd	s6,0(sp)
    80003230:	8aaa                	mv	s5,a0
    80003232:	8b2e                	mv	s6,a1
    80003234:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003236:	0001ba17          	auipc	s4,0x1b
    8000323a:	082a0a13          	addi	s4,s4,130 # 8001e2b8 <sb>
    8000323e:	00495593          	srli	a1,s2,0x4
    80003242:	018a2783          	lw	a5,24(s4)
    80003246:	9dbd                	addw	a1,a1,a5
    80003248:	8556                	mv	a0,s5
    8000324a:	a9dff0ef          	jal	80002ce6 <bread>
    8000324e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003250:	05850993          	addi	s3,a0,88
    80003254:	00f97793          	andi	a5,s2,15
    80003258:	079a                	slli	a5,a5,0x6
    8000325a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000325c:	00099783          	lh	a5,0(s3)
    80003260:	cb9d                	beqz	a5,80003296 <ialloc+0x88>
    brelse(bp);
    80003262:	b8dff0ef          	jal	80002dee <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003266:	0905                	addi	s2,s2,1
    80003268:	00ca2703          	lw	a4,12(s4)
    8000326c:	0009079b          	sext.w	a5,s2
    80003270:	fce7e7e3          	bltu	a5,a4,8000323e <ialloc+0x30>
    80003274:	74a2                	ld	s1,40(sp)
    80003276:	7902                	ld	s2,32(sp)
    80003278:	69e2                	ld	s3,24(sp)
    8000327a:	6a42                	ld	s4,16(sp)
    8000327c:	6aa2                	ld	s5,8(sp)
    8000327e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003280:	00004517          	auipc	a0,0x4
    80003284:	1b850513          	addi	a0,a0,440 # 80007438 <etext+0x438>
    80003288:	a72fd0ef          	jal	800004fa <printf>
  return 0;
    8000328c:	4501                	li	a0,0
}
    8000328e:	70e2                	ld	ra,56(sp)
    80003290:	7442                	ld	s0,48(sp)
    80003292:	6121                	addi	sp,sp,64
    80003294:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003296:	04000613          	li	a2,64
    8000329a:	4581                	li	a1,0
    8000329c:	854e                	mv	a0,s3
    8000329e:	a5bfd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    800032a2:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800032a6:	8526                	mv	a0,s1
    800032a8:	47d000ef          	jal	80003f24 <log_write>
      brelse(bp);
    800032ac:	8526                	mv	a0,s1
    800032ae:	b41ff0ef          	jal	80002dee <brelse>
      return iget(dev, inum);
    800032b2:	0009059b          	sext.w	a1,s2
    800032b6:	8556                	mv	a0,s5
    800032b8:	e55ff0ef          	jal	8000310c <iget>
    800032bc:	74a2                	ld	s1,40(sp)
    800032be:	7902                	ld	s2,32(sp)
    800032c0:	69e2                	ld	s3,24(sp)
    800032c2:	6a42                	ld	s4,16(sp)
    800032c4:	6aa2                	ld	s5,8(sp)
    800032c6:	6b02                	ld	s6,0(sp)
    800032c8:	b7d9                	j	8000328e <ialloc+0x80>

00000000800032ca <iupdate>:
{
    800032ca:	1101                	addi	sp,sp,-32
    800032cc:	ec06                	sd	ra,24(sp)
    800032ce:	e822                	sd	s0,16(sp)
    800032d0:	e426                	sd	s1,8(sp)
    800032d2:	e04a                	sd	s2,0(sp)
    800032d4:	1000                	addi	s0,sp,32
    800032d6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032d8:	415c                	lw	a5,4(a0)
    800032da:	0047d79b          	srliw	a5,a5,0x4
    800032de:	0001b597          	auipc	a1,0x1b
    800032e2:	ff25a583          	lw	a1,-14(a1) # 8001e2d0 <sb+0x18>
    800032e6:	9dbd                	addw	a1,a1,a5
    800032e8:	4108                	lw	a0,0(a0)
    800032ea:	9fdff0ef          	jal	80002ce6 <bread>
    800032ee:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032f0:	05850793          	addi	a5,a0,88
    800032f4:	40d8                	lw	a4,4(s1)
    800032f6:	8b3d                	andi	a4,a4,15
    800032f8:	071a                	slli	a4,a4,0x6
    800032fa:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800032fc:	04449703          	lh	a4,68(s1)
    80003300:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003304:	04649703          	lh	a4,70(s1)
    80003308:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000330c:	04849703          	lh	a4,72(s1)
    80003310:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003314:	04a49703          	lh	a4,74(s1)
    80003318:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000331c:	44f8                	lw	a4,76(s1)
    8000331e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003320:	03400613          	li	a2,52
    80003324:	05048593          	addi	a1,s1,80
    80003328:	00c78513          	addi	a0,a5,12
    8000332c:	a2dfd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003330:	854a                	mv	a0,s2
    80003332:	3f3000ef          	jal	80003f24 <log_write>
  brelse(bp);
    80003336:	854a                	mv	a0,s2
    80003338:	ab7ff0ef          	jal	80002dee <brelse>
}
    8000333c:	60e2                	ld	ra,24(sp)
    8000333e:	6442                	ld	s0,16(sp)
    80003340:	64a2                	ld	s1,8(sp)
    80003342:	6902                	ld	s2,0(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <idup>:
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	e426                	sd	s1,8(sp)
    80003350:	1000                	addi	s0,sp,32
    80003352:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003354:	0001b517          	auipc	a0,0x1b
    80003358:	f8450513          	addi	a0,a0,-124 # 8001e2d8 <itable>
    8000335c:	8cdfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003360:	449c                	lw	a5,8(s1)
    80003362:	2785                	addiw	a5,a5,1
    80003364:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003366:	0001b517          	auipc	a0,0x1b
    8000336a:	f7250513          	addi	a0,a0,-142 # 8001e2d8 <itable>
    8000336e:	94ffd0ef          	jal	80000cbc <release>
}
    80003372:	8526                	mv	a0,s1
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	64a2                	ld	s1,8(sp)
    8000337a:	6105                	addi	sp,sp,32
    8000337c:	8082                	ret

000000008000337e <ilock>:
{
    8000337e:	1101                	addi	sp,sp,-32
    80003380:	ec06                	sd	ra,24(sp)
    80003382:	e822                	sd	s0,16(sp)
    80003384:	e426                	sd	s1,8(sp)
    80003386:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003388:	cd19                	beqz	a0,800033a6 <ilock+0x28>
    8000338a:	84aa                	mv	s1,a0
    8000338c:	451c                	lw	a5,8(a0)
    8000338e:	00f05c63          	blez	a5,800033a6 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003392:	0541                	addi	a0,a0,16
    80003394:	48b000ef          	jal	8000401e <acquiresleep>
  if(ip->valid == 0){
    80003398:	40bc                	lw	a5,64(s1)
    8000339a:	cf89                	beqz	a5,800033b4 <ilock+0x36>
}
    8000339c:	60e2                	ld	ra,24(sp)
    8000339e:	6442                	ld	s0,16(sp)
    800033a0:	64a2                	ld	s1,8(sp)
    800033a2:	6105                	addi	sp,sp,32
    800033a4:	8082                	ret
    800033a6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033a8:	00004517          	auipc	a0,0x4
    800033ac:	0a850513          	addi	a0,a0,168 # 80007450 <etext+0x450>
    800033b0:	c74fd0ef          	jal	80000824 <panic>
    800033b4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033b6:	40dc                	lw	a5,4(s1)
    800033b8:	0047d79b          	srliw	a5,a5,0x4
    800033bc:	0001b597          	auipc	a1,0x1b
    800033c0:	f145a583          	lw	a1,-236(a1) # 8001e2d0 <sb+0x18>
    800033c4:	9dbd                	addw	a1,a1,a5
    800033c6:	4088                	lw	a0,0(s1)
    800033c8:	91fff0ef          	jal	80002ce6 <bread>
    800033cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033ce:	05850593          	addi	a1,a0,88
    800033d2:	40dc                	lw	a5,4(s1)
    800033d4:	8bbd                	andi	a5,a5,15
    800033d6:	079a                	slli	a5,a5,0x6
    800033d8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033da:	00059783          	lh	a5,0(a1)
    800033de:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033e2:	00259783          	lh	a5,2(a1)
    800033e6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033ea:	00459783          	lh	a5,4(a1)
    800033ee:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033f2:	00659783          	lh	a5,6(a1)
    800033f6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033fa:	459c                	lw	a5,8(a1)
    800033fc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033fe:	03400613          	li	a2,52
    80003402:	05b1                	addi	a1,a1,12
    80003404:	05048513          	addi	a0,s1,80
    80003408:	951fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    8000340c:	854a                	mv	a0,s2
    8000340e:	9e1ff0ef          	jal	80002dee <brelse>
    ip->valid = 1;
    80003412:	4785                	li	a5,1
    80003414:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003416:	04449783          	lh	a5,68(s1)
    8000341a:	c399                	beqz	a5,80003420 <ilock+0xa2>
    8000341c:	6902                	ld	s2,0(sp)
    8000341e:	bfbd                	j	8000339c <ilock+0x1e>
      panic("ilock: no type");
    80003420:	00004517          	auipc	a0,0x4
    80003424:	03850513          	addi	a0,a0,56 # 80007458 <etext+0x458>
    80003428:	bfcfd0ef          	jal	80000824 <panic>

000000008000342c <iunlock>:
{
    8000342c:	1101                	addi	sp,sp,-32
    8000342e:	ec06                	sd	ra,24(sp)
    80003430:	e822                	sd	s0,16(sp)
    80003432:	e426                	sd	s1,8(sp)
    80003434:	e04a                	sd	s2,0(sp)
    80003436:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003438:	c505                	beqz	a0,80003460 <iunlock+0x34>
    8000343a:	84aa                	mv	s1,a0
    8000343c:	01050913          	addi	s2,a0,16
    80003440:	854a                	mv	a0,s2
    80003442:	45b000ef          	jal	8000409c <holdingsleep>
    80003446:	cd09                	beqz	a0,80003460 <iunlock+0x34>
    80003448:	449c                	lw	a5,8(s1)
    8000344a:	00f05b63          	blez	a5,80003460 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000344e:	854a                	mv	a0,s2
    80003450:	415000ef          	jal	80004064 <releasesleep>
}
    80003454:	60e2                	ld	ra,24(sp)
    80003456:	6442                	ld	s0,16(sp)
    80003458:	64a2                	ld	s1,8(sp)
    8000345a:	6902                	ld	s2,0(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret
    panic("iunlock");
    80003460:	00004517          	auipc	a0,0x4
    80003464:	00850513          	addi	a0,a0,8 # 80007468 <etext+0x468>
    80003468:	bbcfd0ef          	jal	80000824 <panic>

000000008000346c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000346c:	7179                	addi	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	ec26                	sd	s1,24(sp)
    80003474:	e84a                	sd	s2,16(sp)
    80003476:	e44e                	sd	s3,8(sp)
    80003478:	1800                	addi	s0,sp,48
    8000347a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000347c:	05050493          	addi	s1,a0,80
    80003480:	08050913          	addi	s2,a0,128
    80003484:	a021                	j	8000348c <itrunc+0x20>
    80003486:	0491                	addi	s1,s1,4
    80003488:	01248b63          	beq	s1,s2,8000349e <itrunc+0x32>
    if(ip->addrs[i]){
    8000348c:	408c                	lw	a1,0(s1)
    8000348e:	dde5                	beqz	a1,80003486 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003490:	0009a503          	lw	a0,0(s3)
    80003494:	a47ff0ef          	jal	80002eda <bfree>
      ip->addrs[i] = 0;
    80003498:	0004a023          	sw	zero,0(s1)
    8000349c:	b7ed                	j	80003486 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000349e:	0809a583          	lw	a1,128(s3)
    800034a2:	ed89                	bnez	a1,800034bc <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034a4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034a8:	854e                	mv	a0,s3
    800034aa:	e21ff0ef          	jal	800032ca <iupdate>
}
    800034ae:	70a2                	ld	ra,40(sp)
    800034b0:	7402                	ld	s0,32(sp)
    800034b2:	64e2                	ld	s1,24(sp)
    800034b4:	6942                	ld	s2,16(sp)
    800034b6:	69a2                	ld	s3,8(sp)
    800034b8:	6145                	addi	sp,sp,48
    800034ba:	8082                	ret
    800034bc:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034be:	0009a503          	lw	a0,0(s3)
    800034c2:	825ff0ef          	jal	80002ce6 <bread>
    800034c6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800034c8:	05850493          	addi	s1,a0,88
    800034cc:	45850913          	addi	s2,a0,1112
    800034d0:	a021                	j	800034d8 <itrunc+0x6c>
    800034d2:	0491                	addi	s1,s1,4
    800034d4:	01248963          	beq	s1,s2,800034e6 <itrunc+0x7a>
      if(a[j])
    800034d8:	408c                	lw	a1,0(s1)
    800034da:	dde5                	beqz	a1,800034d2 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034dc:	0009a503          	lw	a0,0(s3)
    800034e0:	9fbff0ef          	jal	80002eda <bfree>
    800034e4:	b7fd                	j	800034d2 <itrunc+0x66>
    brelse(bp);
    800034e6:	8552                	mv	a0,s4
    800034e8:	907ff0ef          	jal	80002dee <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034ec:	0809a583          	lw	a1,128(s3)
    800034f0:	0009a503          	lw	a0,0(s3)
    800034f4:	9e7ff0ef          	jal	80002eda <bfree>
    ip->addrs[NDIRECT] = 0;
    800034f8:	0809a023          	sw	zero,128(s3)
    800034fc:	6a02                	ld	s4,0(sp)
    800034fe:	b75d                	j	800034a4 <itrunc+0x38>

0000000080003500 <iput>:
{
    80003500:	1101                	addi	sp,sp,-32
    80003502:	ec06                	sd	ra,24(sp)
    80003504:	e822                	sd	s0,16(sp)
    80003506:	e426                	sd	s1,8(sp)
    80003508:	1000                	addi	s0,sp,32
    8000350a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000350c:	0001b517          	auipc	a0,0x1b
    80003510:	dcc50513          	addi	a0,a0,-564 # 8001e2d8 <itable>
    80003514:	f14fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003518:	4498                	lw	a4,8(s1)
    8000351a:	4785                	li	a5,1
    8000351c:	02f70063          	beq	a4,a5,8000353c <iput+0x3c>
  ip->ref--;
    80003520:	449c                	lw	a5,8(s1)
    80003522:	37fd                	addiw	a5,a5,-1
    80003524:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003526:	0001b517          	auipc	a0,0x1b
    8000352a:	db250513          	addi	a0,a0,-590 # 8001e2d8 <itable>
    8000352e:	f8efd0ef          	jal	80000cbc <release>
}
    80003532:	60e2                	ld	ra,24(sp)
    80003534:	6442                	ld	s0,16(sp)
    80003536:	64a2                	ld	s1,8(sp)
    80003538:	6105                	addi	sp,sp,32
    8000353a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000353c:	40bc                	lw	a5,64(s1)
    8000353e:	d3ed                	beqz	a5,80003520 <iput+0x20>
    80003540:	04a49783          	lh	a5,74(s1)
    80003544:	fff1                	bnez	a5,80003520 <iput+0x20>
    80003546:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003548:	01048793          	addi	a5,s1,16
    8000354c:	893e                	mv	s2,a5
    8000354e:	853e                	mv	a0,a5
    80003550:	2cf000ef          	jal	8000401e <acquiresleep>
    release(&itable.lock);
    80003554:	0001b517          	auipc	a0,0x1b
    80003558:	d8450513          	addi	a0,a0,-636 # 8001e2d8 <itable>
    8000355c:	f60fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003560:	8526                	mv	a0,s1
    80003562:	f0bff0ef          	jal	8000346c <itrunc>
    ip->type = 0;
    80003566:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000356a:	8526                	mv	a0,s1
    8000356c:	d5fff0ef          	jal	800032ca <iupdate>
    ip->valid = 0;
    80003570:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003574:	854a                	mv	a0,s2
    80003576:	2ef000ef          	jal	80004064 <releasesleep>
    acquire(&itable.lock);
    8000357a:	0001b517          	auipc	a0,0x1b
    8000357e:	d5e50513          	addi	a0,a0,-674 # 8001e2d8 <itable>
    80003582:	ea6fd0ef          	jal	80000c28 <acquire>
    80003586:	6902                	ld	s2,0(sp)
    80003588:	bf61                	j	80003520 <iput+0x20>

000000008000358a <iunlockput>:
{
    8000358a:	1101                	addi	sp,sp,-32
    8000358c:	ec06                	sd	ra,24(sp)
    8000358e:	e822                	sd	s0,16(sp)
    80003590:	e426                	sd	s1,8(sp)
    80003592:	1000                	addi	s0,sp,32
    80003594:	84aa                	mv	s1,a0
  iunlock(ip);
    80003596:	e97ff0ef          	jal	8000342c <iunlock>
  iput(ip);
    8000359a:	8526                	mv	a0,s1
    8000359c:	f65ff0ef          	jal	80003500 <iput>
}
    800035a0:	60e2                	ld	ra,24(sp)
    800035a2:	6442                	ld	s0,16(sp)
    800035a4:	64a2                	ld	s1,8(sp)
    800035a6:	6105                	addi	sp,sp,32
    800035a8:	8082                	ret

00000000800035aa <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035aa:	0001b717          	auipc	a4,0x1b
    800035ae:	d1a72703          	lw	a4,-742(a4) # 8001e2c4 <sb+0xc>
    800035b2:	4785                	li	a5,1
    800035b4:	0ae7fe63          	bgeu	a5,a4,80003670 <ireclaim+0xc6>
{
    800035b8:	7139                	addi	sp,sp,-64
    800035ba:	fc06                	sd	ra,56(sp)
    800035bc:	f822                	sd	s0,48(sp)
    800035be:	f426                	sd	s1,40(sp)
    800035c0:	f04a                	sd	s2,32(sp)
    800035c2:	ec4e                	sd	s3,24(sp)
    800035c4:	e852                	sd	s4,16(sp)
    800035c6:	e456                	sd	s5,8(sp)
    800035c8:	e05a                	sd	s6,0(sp)
    800035ca:	0080                	addi	s0,sp,64
    800035cc:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035ce:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035d0:	0001ba17          	auipc	s4,0x1b
    800035d4:	ce8a0a13          	addi	s4,s4,-792 # 8001e2b8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800035d8:	00004b17          	auipc	s6,0x4
    800035dc:	e98b0b13          	addi	s6,s6,-360 # 80007470 <etext+0x470>
    800035e0:	a099                	j	80003626 <ireclaim+0x7c>
    800035e2:	85ce                	mv	a1,s3
    800035e4:	855a                	mv	a0,s6
    800035e6:	f15fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800035ea:	85ce                	mv	a1,s3
    800035ec:	8556                	mv	a0,s5
    800035ee:	b1fff0ef          	jal	8000310c <iget>
    800035f2:	89aa                	mv	s3,a0
    brelse(bp);
    800035f4:	854a                	mv	a0,s2
    800035f6:	ff8ff0ef          	jal	80002dee <brelse>
    if (ip) {
    800035fa:	00098f63          	beqz	s3,80003618 <ireclaim+0x6e>
      begin_op();
    800035fe:	78c000ef          	jal	80003d8a <begin_op>
      ilock(ip);
    80003602:	854e                	mv	a0,s3
    80003604:	d7bff0ef          	jal	8000337e <ilock>
      iunlock(ip);
    80003608:	854e                	mv	a0,s3
    8000360a:	e23ff0ef          	jal	8000342c <iunlock>
      iput(ip);
    8000360e:	854e                	mv	a0,s3
    80003610:	ef1ff0ef          	jal	80003500 <iput>
      end_op();
    80003614:	7e6000ef          	jal	80003dfa <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003618:	0485                	addi	s1,s1,1
    8000361a:	00ca2703          	lw	a4,12(s4)
    8000361e:	0004879b          	sext.w	a5,s1
    80003622:	02e7fd63          	bgeu	a5,a4,8000365c <ireclaim+0xb2>
    80003626:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000362a:	0044d593          	srli	a1,s1,0x4
    8000362e:	018a2783          	lw	a5,24(s4)
    80003632:	9dbd                	addw	a1,a1,a5
    80003634:	8556                	mv	a0,s5
    80003636:	eb0ff0ef          	jal	80002ce6 <bread>
    8000363a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000363c:	05850793          	addi	a5,a0,88
    80003640:	00f9f713          	andi	a4,s3,15
    80003644:	071a                	slli	a4,a4,0x6
    80003646:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003648:	00079703          	lh	a4,0(a5)
    8000364c:	c701                	beqz	a4,80003654 <ireclaim+0xaa>
    8000364e:	00679783          	lh	a5,6(a5)
    80003652:	dbc1                	beqz	a5,800035e2 <ireclaim+0x38>
    brelse(bp);
    80003654:	854a                	mv	a0,s2
    80003656:	f98ff0ef          	jal	80002dee <brelse>
    if (ip) {
    8000365a:	bf7d                	j	80003618 <ireclaim+0x6e>
}
    8000365c:	70e2                	ld	ra,56(sp)
    8000365e:	7442                	ld	s0,48(sp)
    80003660:	74a2                	ld	s1,40(sp)
    80003662:	7902                	ld	s2,32(sp)
    80003664:	69e2                	ld	s3,24(sp)
    80003666:	6a42                	ld	s4,16(sp)
    80003668:	6aa2                	ld	s5,8(sp)
    8000366a:	6b02                	ld	s6,0(sp)
    8000366c:	6121                	addi	sp,sp,64
    8000366e:	8082                	ret
    80003670:	8082                	ret

0000000080003672 <fsinit>:
fsinit(int dev) {
    80003672:	1101                	addi	sp,sp,-32
    80003674:	ec06                	sd	ra,24(sp)
    80003676:	e822                	sd	s0,16(sp)
    80003678:	e426                	sd	s1,8(sp)
    8000367a:	e04a                	sd	s2,0(sp)
    8000367c:	1000                	addi	s0,sp,32
    8000367e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003680:	4585                	li	a1,1
    80003682:	e64ff0ef          	jal	80002ce6 <bread>
    80003686:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003688:	02000613          	li	a2,32
    8000368c:	05850593          	addi	a1,a0,88
    80003690:	0001b517          	auipc	a0,0x1b
    80003694:	c2850513          	addi	a0,a0,-984 # 8001e2b8 <sb>
    80003698:	ec0fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    8000369c:	8526                	mv	a0,s1
    8000369e:	f50ff0ef          	jal	80002dee <brelse>
  if(sb.magic != FSMAGIC)
    800036a2:	0001b717          	auipc	a4,0x1b
    800036a6:	c1672703          	lw	a4,-1002(a4) # 8001e2b8 <sb>
    800036aa:	102037b7          	lui	a5,0x10203
    800036ae:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036b2:	02f71263          	bne	a4,a5,800036d6 <fsinit+0x64>
  initlog(dev, &sb);
    800036b6:	0001b597          	auipc	a1,0x1b
    800036ba:	c0258593          	addi	a1,a1,-1022 # 8001e2b8 <sb>
    800036be:	854a                	mv	a0,s2
    800036c0:	648000ef          	jal	80003d08 <initlog>
  ireclaim(dev);
    800036c4:	854a                	mv	a0,s2
    800036c6:	ee5ff0ef          	jal	800035aa <ireclaim>
}
    800036ca:	60e2                	ld	ra,24(sp)
    800036cc:	6442                	ld	s0,16(sp)
    800036ce:	64a2                	ld	s1,8(sp)
    800036d0:	6902                	ld	s2,0(sp)
    800036d2:	6105                	addi	sp,sp,32
    800036d4:	8082                	ret
    panic("invalid file system");
    800036d6:	00004517          	auipc	a0,0x4
    800036da:	dba50513          	addi	a0,a0,-582 # 80007490 <etext+0x490>
    800036de:	946fd0ef          	jal	80000824 <panic>

00000000800036e2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036e2:	1141                	addi	sp,sp,-16
    800036e4:	e406                	sd	ra,8(sp)
    800036e6:	e022                	sd	s0,0(sp)
    800036e8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036ea:	411c                	lw	a5,0(a0)
    800036ec:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036ee:	415c                	lw	a5,4(a0)
    800036f0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036f2:	04451783          	lh	a5,68(a0)
    800036f6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036fa:	04a51783          	lh	a5,74(a0)
    800036fe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003702:	04c56783          	lwu	a5,76(a0)
    80003706:	e99c                	sd	a5,16(a1)
}
    80003708:	60a2                	ld	ra,8(sp)
    8000370a:	6402                	ld	s0,0(sp)
    8000370c:	0141                	addi	sp,sp,16
    8000370e:	8082                	ret

0000000080003710 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003710:	457c                	lw	a5,76(a0)
    80003712:	0ed7e663          	bltu	a5,a3,800037fe <readi+0xee>
{
    80003716:	7159                	addi	sp,sp,-112
    80003718:	f486                	sd	ra,104(sp)
    8000371a:	f0a2                	sd	s0,96(sp)
    8000371c:	eca6                	sd	s1,88(sp)
    8000371e:	e0d2                	sd	s4,64(sp)
    80003720:	fc56                	sd	s5,56(sp)
    80003722:	f85a                	sd	s6,48(sp)
    80003724:	f45e                	sd	s7,40(sp)
    80003726:	1880                	addi	s0,sp,112
    80003728:	8b2a                	mv	s6,a0
    8000372a:	8bae                	mv	s7,a1
    8000372c:	8a32                	mv	s4,a2
    8000372e:	84b6                	mv	s1,a3
    80003730:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003732:	9f35                	addw	a4,a4,a3
    return 0;
    80003734:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003736:	0ad76b63          	bltu	a4,a3,800037ec <readi+0xdc>
    8000373a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000373c:	00e7f463          	bgeu	a5,a4,80003744 <readi+0x34>
    n = ip->size - off;
    80003740:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003744:	080a8b63          	beqz	s5,800037da <readi+0xca>
    80003748:	e8ca                	sd	s2,80(sp)
    8000374a:	f062                	sd	s8,32(sp)
    8000374c:	ec66                	sd	s9,24(sp)
    8000374e:	e86a                	sd	s10,16(sp)
    80003750:	e46e                	sd	s11,8(sp)
    80003752:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003754:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003758:	5c7d                	li	s8,-1
    8000375a:	a80d                	j	8000378c <readi+0x7c>
    8000375c:	020d1d93          	slli	s11,s10,0x20
    80003760:	020ddd93          	srli	s11,s11,0x20
    80003764:	05890613          	addi	a2,s2,88
    80003768:	86ee                	mv	a3,s11
    8000376a:	963e                	add	a2,a2,a5
    8000376c:	85d2                	mv	a1,s4
    8000376e:	855e                	mv	a0,s7
    80003770:	bedfe0ef          	jal	8000235c <either_copyout>
    80003774:	05850363          	beq	a0,s8,800037ba <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003778:	854a                	mv	a0,s2
    8000377a:	e74ff0ef          	jal	80002dee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000377e:	013d09bb          	addw	s3,s10,s3
    80003782:	009d04bb          	addw	s1,s10,s1
    80003786:	9a6e                	add	s4,s4,s11
    80003788:	0559f363          	bgeu	s3,s5,800037ce <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000378c:	00a4d59b          	srliw	a1,s1,0xa
    80003790:	855a                	mv	a0,s6
    80003792:	8bbff0ef          	jal	8000304c <bmap>
    80003796:	85aa                	mv	a1,a0
    if(addr == 0)
    80003798:	c139                	beqz	a0,800037de <readi+0xce>
    bp = bread(ip->dev, addr);
    8000379a:	000b2503          	lw	a0,0(s6)
    8000379e:	d48ff0ef          	jal	80002ce6 <bread>
    800037a2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037a4:	3ff4f793          	andi	a5,s1,1023
    800037a8:	40fc873b          	subw	a4,s9,a5
    800037ac:	413a86bb          	subw	a3,s5,s3
    800037b0:	8d3a                	mv	s10,a4
    800037b2:	fae6f5e3          	bgeu	a3,a4,8000375c <readi+0x4c>
    800037b6:	8d36                	mv	s10,a3
    800037b8:	b755                	j	8000375c <readi+0x4c>
      brelse(bp);
    800037ba:	854a                	mv	a0,s2
    800037bc:	e32ff0ef          	jal	80002dee <brelse>
      tot = -1;
    800037c0:	59fd                	li	s3,-1
      break;
    800037c2:	6946                	ld	s2,80(sp)
    800037c4:	7c02                	ld	s8,32(sp)
    800037c6:	6ce2                	ld	s9,24(sp)
    800037c8:	6d42                	ld	s10,16(sp)
    800037ca:	6da2                	ld	s11,8(sp)
    800037cc:	a831                	j	800037e8 <readi+0xd8>
    800037ce:	6946                	ld	s2,80(sp)
    800037d0:	7c02                	ld	s8,32(sp)
    800037d2:	6ce2                	ld	s9,24(sp)
    800037d4:	6d42                	ld	s10,16(sp)
    800037d6:	6da2                	ld	s11,8(sp)
    800037d8:	a801                	j	800037e8 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037da:	89d6                	mv	s3,s5
    800037dc:	a031                	j	800037e8 <readi+0xd8>
    800037de:	6946                	ld	s2,80(sp)
    800037e0:	7c02                	ld	s8,32(sp)
    800037e2:	6ce2                	ld	s9,24(sp)
    800037e4:	6d42                	ld	s10,16(sp)
    800037e6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800037e8:	854e                	mv	a0,s3
    800037ea:	69a6                	ld	s3,72(sp)
}
    800037ec:	70a6                	ld	ra,104(sp)
    800037ee:	7406                	ld	s0,96(sp)
    800037f0:	64e6                	ld	s1,88(sp)
    800037f2:	6a06                	ld	s4,64(sp)
    800037f4:	7ae2                	ld	s5,56(sp)
    800037f6:	7b42                	ld	s6,48(sp)
    800037f8:	7ba2                	ld	s7,40(sp)
    800037fa:	6165                	addi	sp,sp,112
    800037fc:	8082                	ret
    return 0;
    800037fe:	4501                	li	a0,0
}
    80003800:	8082                	ret

0000000080003802 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003802:	457c                	lw	a5,76(a0)
    80003804:	0ed7eb63          	bltu	a5,a3,800038fa <writei+0xf8>
{
    80003808:	7159                	addi	sp,sp,-112
    8000380a:	f486                	sd	ra,104(sp)
    8000380c:	f0a2                	sd	s0,96(sp)
    8000380e:	e8ca                	sd	s2,80(sp)
    80003810:	e0d2                	sd	s4,64(sp)
    80003812:	fc56                	sd	s5,56(sp)
    80003814:	f85a                	sd	s6,48(sp)
    80003816:	f45e                	sd	s7,40(sp)
    80003818:	1880                	addi	s0,sp,112
    8000381a:	8aaa                	mv	s5,a0
    8000381c:	8bae                	mv	s7,a1
    8000381e:	8a32                	mv	s4,a2
    80003820:	8936                	mv	s2,a3
    80003822:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003824:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003828:	00043737          	lui	a4,0x43
    8000382c:	0cf76963          	bltu	a4,a5,800038fe <writei+0xfc>
    80003830:	0cd7e763          	bltu	a5,a3,800038fe <writei+0xfc>
    80003834:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003836:	0a0b0a63          	beqz	s6,800038ea <writei+0xe8>
    8000383a:	eca6                	sd	s1,88(sp)
    8000383c:	f062                	sd	s8,32(sp)
    8000383e:	ec66                	sd	s9,24(sp)
    80003840:	e86a                	sd	s10,16(sp)
    80003842:	e46e                	sd	s11,8(sp)
    80003844:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003846:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000384a:	5c7d                	li	s8,-1
    8000384c:	a825                	j	80003884 <writei+0x82>
    8000384e:	020d1d93          	slli	s11,s10,0x20
    80003852:	020ddd93          	srli	s11,s11,0x20
    80003856:	05848513          	addi	a0,s1,88
    8000385a:	86ee                	mv	a3,s11
    8000385c:	8652                	mv	a2,s4
    8000385e:	85de                	mv	a1,s7
    80003860:	953e                	add	a0,a0,a5
    80003862:	b45fe0ef          	jal	800023a6 <either_copyin>
    80003866:	05850663          	beq	a0,s8,800038b2 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000386a:	8526                	mv	a0,s1
    8000386c:	6b8000ef          	jal	80003f24 <log_write>
    brelse(bp);
    80003870:	8526                	mv	a0,s1
    80003872:	d7cff0ef          	jal	80002dee <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003876:	013d09bb          	addw	s3,s10,s3
    8000387a:	012d093b          	addw	s2,s10,s2
    8000387e:	9a6e                	add	s4,s4,s11
    80003880:	0369fc63          	bgeu	s3,s6,800038b8 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003884:	00a9559b          	srliw	a1,s2,0xa
    80003888:	8556                	mv	a0,s5
    8000388a:	fc2ff0ef          	jal	8000304c <bmap>
    8000388e:	85aa                	mv	a1,a0
    if(addr == 0)
    80003890:	c505                	beqz	a0,800038b8 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003892:	000aa503          	lw	a0,0(s5)
    80003896:	c50ff0ef          	jal	80002ce6 <bread>
    8000389a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000389c:	3ff97793          	andi	a5,s2,1023
    800038a0:	40fc873b          	subw	a4,s9,a5
    800038a4:	413b06bb          	subw	a3,s6,s3
    800038a8:	8d3a                	mv	s10,a4
    800038aa:	fae6f2e3          	bgeu	a3,a4,8000384e <writei+0x4c>
    800038ae:	8d36                	mv	s10,a3
    800038b0:	bf79                	j	8000384e <writei+0x4c>
      brelse(bp);
    800038b2:	8526                	mv	a0,s1
    800038b4:	d3aff0ef          	jal	80002dee <brelse>
  }

  if(off > ip->size)
    800038b8:	04caa783          	lw	a5,76(s5)
    800038bc:	0327f963          	bgeu	a5,s2,800038ee <writei+0xec>
    ip->size = off;
    800038c0:	052aa623          	sw	s2,76(s5)
    800038c4:	64e6                	ld	s1,88(sp)
    800038c6:	7c02                	ld	s8,32(sp)
    800038c8:	6ce2                	ld	s9,24(sp)
    800038ca:	6d42                	ld	s10,16(sp)
    800038cc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038ce:	8556                	mv	a0,s5
    800038d0:	9fbff0ef          	jal	800032ca <iupdate>

  return tot;
    800038d4:	854e                	mv	a0,s3
    800038d6:	69a6                	ld	s3,72(sp)
}
    800038d8:	70a6                	ld	ra,104(sp)
    800038da:	7406                	ld	s0,96(sp)
    800038dc:	6946                	ld	s2,80(sp)
    800038de:	6a06                	ld	s4,64(sp)
    800038e0:	7ae2                	ld	s5,56(sp)
    800038e2:	7b42                	ld	s6,48(sp)
    800038e4:	7ba2                	ld	s7,40(sp)
    800038e6:	6165                	addi	sp,sp,112
    800038e8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038ea:	89da                	mv	s3,s6
    800038ec:	b7cd                	j	800038ce <writei+0xcc>
    800038ee:	64e6                	ld	s1,88(sp)
    800038f0:	7c02                	ld	s8,32(sp)
    800038f2:	6ce2                	ld	s9,24(sp)
    800038f4:	6d42                	ld	s10,16(sp)
    800038f6:	6da2                	ld	s11,8(sp)
    800038f8:	bfd9                	j	800038ce <writei+0xcc>
    return -1;
    800038fa:	557d                	li	a0,-1
}
    800038fc:	8082                	ret
    return -1;
    800038fe:	557d                	li	a0,-1
    80003900:	bfe1                	j	800038d8 <writei+0xd6>

0000000080003902 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003902:	1141                	addi	sp,sp,-16
    80003904:	e406                	sd	ra,8(sp)
    80003906:	e022                	sd	s0,0(sp)
    80003908:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000390a:	4639                	li	a2,14
    8000390c:	cc0fd0ef          	jal	80000dcc <strncmp>
}
    80003910:	60a2                	ld	ra,8(sp)
    80003912:	6402                	ld	s0,0(sp)
    80003914:	0141                	addi	sp,sp,16
    80003916:	8082                	ret

0000000080003918 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003918:	711d                	addi	sp,sp,-96
    8000391a:	ec86                	sd	ra,88(sp)
    8000391c:	e8a2                	sd	s0,80(sp)
    8000391e:	e4a6                	sd	s1,72(sp)
    80003920:	e0ca                	sd	s2,64(sp)
    80003922:	fc4e                	sd	s3,56(sp)
    80003924:	f852                	sd	s4,48(sp)
    80003926:	f456                	sd	s5,40(sp)
    80003928:	f05a                	sd	s6,32(sp)
    8000392a:	ec5e                	sd	s7,24(sp)
    8000392c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000392e:	04451703          	lh	a4,68(a0)
    80003932:	4785                	li	a5,1
    80003934:	00f71f63          	bne	a4,a5,80003952 <dirlookup+0x3a>
    80003938:	892a                	mv	s2,a0
    8000393a:	8aae                	mv	s5,a1
    8000393c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000393e:	457c                	lw	a5,76(a0)
    80003940:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003942:	fa040a13          	addi	s4,s0,-96
    80003946:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003948:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000394c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000394e:	e39d                	bnez	a5,80003974 <dirlookup+0x5c>
    80003950:	a8b9                	j	800039ae <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003952:	00004517          	auipc	a0,0x4
    80003956:	b5650513          	addi	a0,a0,-1194 # 800074a8 <etext+0x4a8>
    8000395a:	ecbfc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    8000395e:	00004517          	auipc	a0,0x4
    80003962:	b6250513          	addi	a0,a0,-1182 # 800074c0 <etext+0x4c0>
    80003966:	ebffc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000396a:	24c1                	addiw	s1,s1,16
    8000396c:	04c92783          	lw	a5,76(s2)
    80003970:	02f4fe63          	bgeu	s1,a5,800039ac <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003974:	874e                	mv	a4,s3
    80003976:	86a6                	mv	a3,s1
    80003978:	8652                	mv	a2,s4
    8000397a:	4581                	li	a1,0
    8000397c:	854a                	mv	a0,s2
    8000397e:	d93ff0ef          	jal	80003710 <readi>
    80003982:	fd351ee3          	bne	a0,s3,8000395e <dirlookup+0x46>
    if(de.inum == 0)
    80003986:	fa045783          	lhu	a5,-96(s0)
    8000398a:	d3e5                	beqz	a5,8000396a <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    8000398c:	85da                	mv	a1,s6
    8000398e:	8556                	mv	a0,s5
    80003990:	f73ff0ef          	jal	80003902 <namecmp>
    80003994:	f979                	bnez	a0,8000396a <dirlookup+0x52>
      if(poff)
    80003996:	000b8463          	beqz	s7,8000399e <dirlookup+0x86>
        *poff = off;
    8000399a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000399e:	fa045583          	lhu	a1,-96(s0)
    800039a2:	00092503          	lw	a0,0(s2)
    800039a6:	f66ff0ef          	jal	8000310c <iget>
    800039aa:	a011                	j	800039ae <dirlookup+0x96>
  return 0;
    800039ac:	4501                	li	a0,0
}
    800039ae:	60e6                	ld	ra,88(sp)
    800039b0:	6446                	ld	s0,80(sp)
    800039b2:	64a6                	ld	s1,72(sp)
    800039b4:	6906                	ld	s2,64(sp)
    800039b6:	79e2                	ld	s3,56(sp)
    800039b8:	7a42                	ld	s4,48(sp)
    800039ba:	7aa2                	ld	s5,40(sp)
    800039bc:	7b02                	ld	s6,32(sp)
    800039be:	6be2                	ld	s7,24(sp)
    800039c0:	6125                	addi	sp,sp,96
    800039c2:	8082                	ret

00000000800039c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800039c4:	711d                	addi	sp,sp,-96
    800039c6:	ec86                	sd	ra,88(sp)
    800039c8:	e8a2                	sd	s0,80(sp)
    800039ca:	e4a6                	sd	s1,72(sp)
    800039cc:	e0ca                	sd	s2,64(sp)
    800039ce:	fc4e                	sd	s3,56(sp)
    800039d0:	f852                	sd	s4,48(sp)
    800039d2:	f456                	sd	s5,40(sp)
    800039d4:	f05a                	sd	s6,32(sp)
    800039d6:	ec5e                	sd	s7,24(sp)
    800039d8:	e862                	sd	s8,16(sp)
    800039da:	e466                	sd	s9,8(sp)
    800039dc:	e06a                	sd	s10,0(sp)
    800039de:	1080                	addi	s0,sp,96
    800039e0:	84aa                	mv	s1,a0
    800039e2:	8b2e                	mv	s6,a1
    800039e4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800039e6:	00054703          	lbu	a4,0(a0)
    800039ea:	02f00793          	li	a5,47
    800039ee:	00f70f63          	beq	a4,a5,80003a0c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039f2:	f45fd0ef          	jal	80001936 <myproc>
    800039f6:	15053503          	ld	a0,336(a0)
    800039fa:	94fff0ef          	jal	80003348 <idup>
    800039fe:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003a00:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003a04:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a06:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a08:	4b85                	li	s7,1
    80003a0a:	a879                	j	80003aa8 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a0c:	4585                	li	a1,1
    80003a0e:	852e                	mv	a0,a1
    80003a10:	efcff0ef          	jal	8000310c <iget>
    80003a14:	8a2a                	mv	s4,a0
    80003a16:	b7ed                	j	80003a00 <namex+0x3c>
      iunlockput(ip);
    80003a18:	8552                	mv	a0,s4
    80003a1a:	b71ff0ef          	jal	8000358a <iunlockput>
      return 0;
    80003a1e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a20:	8552                	mv	a0,s4
    80003a22:	60e6                	ld	ra,88(sp)
    80003a24:	6446                	ld	s0,80(sp)
    80003a26:	64a6                	ld	s1,72(sp)
    80003a28:	6906                	ld	s2,64(sp)
    80003a2a:	79e2                	ld	s3,56(sp)
    80003a2c:	7a42                	ld	s4,48(sp)
    80003a2e:	7aa2                	ld	s5,40(sp)
    80003a30:	7b02                	ld	s6,32(sp)
    80003a32:	6be2                	ld	s7,24(sp)
    80003a34:	6c42                	ld	s8,16(sp)
    80003a36:	6ca2                	ld	s9,8(sp)
    80003a38:	6d02                	ld	s10,0(sp)
    80003a3a:	6125                	addi	sp,sp,96
    80003a3c:	8082                	ret
      iunlock(ip);
    80003a3e:	8552                	mv	a0,s4
    80003a40:	9edff0ef          	jal	8000342c <iunlock>
      return ip;
    80003a44:	bff1                	j	80003a20 <namex+0x5c>
      iunlockput(ip);
    80003a46:	8552                	mv	a0,s4
    80003a48:	b43ff0ef          	jal	8000358a <iunlockput>
      return 0;
    80003a4c:	8a4a                	mv	s4,s2
    80003a4e:	bfc9                	j	80003a20 <namex+0x5c>
  len = path - s;
    80003a50:	40990633          	sub	a2,s2,s1
    80003a54:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003a58:	09ac5463          	bge	s8,s10,80003ae0 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003a5c:	8666                	mv	a2,s9
    80003a5e:	85a6                	mv	a1,s1
    80003a60:	8556                	mv	a0,s5
    80003a62:	af6fd0ef          	jal	80000d58 <memmove>
    80003a66:	84ca                	mv	s1,s2
  while(*path == '/')
    80003a68:	0004c783          	lbu	a5,0(s1)
    80003a6c:	01379763          	bne	a5,s3,80003a7a <namex+0xb6>
    path++;
    80003a70:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a72:	0004c783          	lbu	a5,0(s1)
    80003a76:	ff378de3          	beq	a5,s3,80003a70 <namex+0xac>
    ilock(ip);
    80003a7a:	8552                	mv	a0,s4
    80003a7c:	903ff0ef          	jal	8000337e <ilock>
    if(ip->type != T_DIR){
    80003a80:	044a1783          	lh	a5,68(s4)
    80003a84:	f9779ae3          	bne	a5,s7,80003a18 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003a88:	000b0563          	beqz	s6,80003a92 <namex+0xce>
    80003a8c:	0004c783          	lbu	a5,0(s1)
    80003a90:	d7dd                	beqz	a5,80003a3e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a92:	4601                	li	a2,0
    80003a94:	85d6                	mv	a1,s5
    80003a96:	8552                	mv	a0,s4
    80003a98:	e81ff0ef          	jal	80003918 <dirlookup>
    80003a9c:	892a                	mv	s2,a0
    80003a9e:	d545                	beqz	a0,80003a46 <namex+0x82>
    iunlockput(ip);
    80003aa0:	8552                	mv	a0,s4
    80003aa2:	ae9ff0ef          	jal	8000358a <iunlockput>
    ip = next;
    80003aa6:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003aa8:	0004c783          	lbu	a5,0(s1)
    80003aac:	01379763          	bne	a5,s3,80003aba <namex+0xf6>
    path++;
    80003ab0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ab2:	0004c783          	lbu	a5,0(s1)
    80003ab6:	ff378de3          	beq	a5,s3,80003ab0 <namex+0xec>
  if(*path == 0)
    80003aba:	cf8d                	beqz	a5,80003af4 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003abc:	0004c783          	lbu	a5,0(s1)
    80003ac0:	fd178713          	addi	a4,a5,-47
    80003ac4:	cb19                	beqz	a4,80003ada <namex+0x116>
    80003ac6:	cb91                	beqz	a5,80003ada <namex+0x116>
    80003ac8:	8926                	mv	s2,s1
    path++;
    80003aca:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003acc:	00094783          	lbu	a5,0(s2)
    80003ad0:	fd178713          	addi	a4,a5,-47
    80003ad4:	df35                	beqz	a4,80003a50 <namex+0x8c>
    80003ad6:	fbf5                	bnez	a5,80003aca <namex+0x106>
    80003ad8:	bfa5                	j	80003a50 <namex+0x8c>
    80003ada:	8926                	mv	s2,s1
  len = path - s;
    80003adc:	4d01                	li	s10,0
    80003ade:	4601                	li	a2,0
    memmove(name, s, len);
    80003ae0:	2601                	sext.w	a2,a2
    80003ae2:	85a6                	mv	a1,s1
    80003ae4:	8556                	mv	a0,s5
    80003ae6:	a72fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003aea:	9d56                	add	s10,s10,s5
    80003aec:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde040>
    80003af0:	84ca                	mv	s1,s2
    80003af2:	bf9d                	j	80003a68 <namex+0xa4>
  if(nameiparent){
    80003af4:	f20b06e3          	beqz	s6,80003a20 <namex+0x5c>
    iput(ip);
    80003af8:	8552                	mv	a0,s4
    80003afa:	a07ff0ef          	jal	80003500 <iput>
    return 0;
    80003afe:	4a01                	li	s4,0
    80003b00:	b705                	j	80003a20 <namex+0x5c>

0000000080003b02 <dirlink>:
{
    80003b02:	715d                	addi	sp,sp,-80
    80003b04:	e486                	sd	ra,72(sp)
    80003b06:	e0a2                	sd	s0,64(sp)
    80003b08:	f84a                	sd	s2,48(sp)
    80003b0a:	ec56                	sd	s5,24(sp)
    80003b0c:	e85a                	sd	s6,16(sp)
    80003b0e:	0880                	addi	s0,sp,80
    80003b10:	892a                	mv	s2,a0
    80003b12:	8aae                	mv	s5,a1
    80003b14:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b16:	4601                	li	a2,0
    80003b18:	e01ff0ef          	jal	80003918 <dirlookup>
    80003b1c:	ed1d                	bnez	a0,80003b5a <dirlink+0x58>
    80003b1e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b20:	04c92483          	lw	s1,76(s2)
    80003b24:	c4b9                	beqz	s1,80003b72 <dirlink+0x70>
    80003b26:	f44e                	sd	s3,40(sp)
    80003b28:	f052                	sd	s4,32(sp)
    80003b2a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b2c:	fb040a13          	addi	s4,s0,-80
    80003b30:	49c1                	li	s3,16
    80003b32:	874e                	mv	a4,s3
    80003b34:	86a6                	mv	a3,s1
    80003b36:	8652                	mv	a2,s4
    80003b38:	4581                	li	a1,0
    80003b3a:	854a                	mv	a0,s2
    80003b3c:	bd5ff0ef          	jal	80003710 <readi>
    80003b40:	03351163          	bne	a0,s3,80003b62 <dirlink+0x60>
    if(de.inum == 0)
    80003b44:	fb045783          	lhu	a5,-80(s0)
    80003b48:	c39d                	beqz	a5,80003b6e <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b4a:	24c1                	addiw	s1,s1,16
    80003b4c:	04c92783          	lw	a5,76(s2)
    80003b50:	fef4e1e3          	bltu	s1,a5,80003b32 <dirlink+0x30>
    80003b54:	79a2                	ld	s3,40(sp)
    80003b56:	7a02                	ld	s4,32(sp)
    80003b58:	a829                	j	80003b72 <dirlink+0x70>
    iput(ip);
    80003b5a:	9a7ff0ef          	jal	80003500 <iput>
    return -1;
    80003b5e:	557d                	li	a0,-1
    80003b60:	a83d                	j	80003b9e <dirlink+0x9c>
      panic("dirlink read");
    80003b62:	00004517          	auipc	a0,0x4
    80003b66:	96e50513          	addi	a0,a0,-1682 # 800074d0 <etext+0x4d0>
    80003b6a:	cbbfc0ef          	jal	80000824 <panic>
    80003b6e:	79a2                	ld	s3,40(sp)
    80003b70:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003b72:	4639                	li	a2,14
    80003b74:	85d6                	mv	a1,s5
    80003b76:	fb240513          	addi	a0,s0,-78
    80003b7a:	a8cfd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003b7e:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b82:	4741                	li	a4,16
    80003b84:	86a6                	mv	a3,s1
    80003b86:	fb040613          	addi	a2,s0,-80
    80003b8a:	4581                	li	a1,0
    80003b8c:	854a                	mv	a0,s2
    80003b8e:	c75ff0ef          	jal	80003802 <writei>
    80003b92:	1541                	addi	a0,a0,-16
    80003b94:	00a03533          	snez	a0,a0
    80003b98:	40a0053b          	negw	a0,a0
    80003b9c:	74e2                	ld	s1,56(sp)
}
    80003b9e:	60a6                	ld	ra,72(sp)
    80003ba0:	6406                	ld	s0,64(sp)
    80003ba2:	7942                	ld	s2,48(sp)
    80003ba4:	6ae2                	ld	s5,24(sp)
    80003ba6:	6b42                	ld	s6,16(sp)
    80003ba8:	6161                	addi	sp,sp,80
    80003baa:	8082                	ret

0000000080003bac <namei>:

struct inode*
namei(char *path)
{
    80003bac:	1101                	addi	sp,sp,-32
    80003bae:	ec06                	sd	ra,24(sp)
    80003bb0:	e822                	sd	s0,16(sp)
    80003bb2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bb4:	fe040613          	addi	a2,s0,-32
    80003bb8:	4581                	li	a1,0
    80003bba:	e0bff0ef          	jal	800039c4 <namex>
}
    80003bbe:	60e2                	ld	ra,24(sp)
    80003bc0:	6442                	ld	s0,16(sp)
    80003bc2:	6105                	addi	sp,sp,32
    80003bc4:	8082                	ret

0000000080003bc6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003bc6:	1141                	addi	sp,sp,-16
    80003bc8:	e406                	sd	ra,8(sp)
    80003bca:	e022                	sd	s0,0(sp)
    80003bcc:	0800                	addi	s0,sp,16
    80003bce:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bd0:	4585                	li	a1,1
    80003bd2:	df3ff0ef          	jal	800039c4 <namex>
}
    80003bd6:	60a2                	ld	ra,8(sp)
    80003bd8:	6402                	ld	s0,0(sp)
    80003bda:	0141                	addi	sp,sp,16
    80003bdc:	8082                	ret

0000000080003bde <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003bde:	1101                	addi	sp,sp,-32
    80003be0:	ec06                	sd	ra,24(sp)
    80003be2:	e822                	sd	s0,16(sp)
    80003be4:	e426                	sd	s1,8(sp)
    80003be6:	e04a                	sd	s2,0(sp)
    80003be8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003bea:	0001c917          	auipc	s2,0x1c
    80003bee:	19690913          	addi	s2,s2,406 # 8001fd80 <log>
    80003bf2:	01892583          	lw	a1,24(s2)
    80003bf6:	02492503          	lw	a0,36(s2)
    80003bfa:	8ecff0ef          	jal	80002ce6 <bread>
    80003bfe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c00:	02892603          	lw	a2,40(s2)
    80003c04:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c06:	00c05f63          	blez	a2,80003c24 <write_head+0x46>
    80003c0a:	0001c717          	auipc	a4,0x1c
    80003c0e:	1a270713          	addi	a4,a4,418 # 8001fdac <log+0x2c>
    80003c12:	87aa                	mv	a5,a0
    80003c14:	060a                	slli	a2,a2,0x2
    80003c16:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c18:	4314                	lw	a3,0(a4)
    80003c1a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c1c:	0711                	addi	a4,a4,4
    80003c1e:	0791                	addi	a5,a5,4
    80003c20:	fec79ce3          	bne	a5,a2,80003c18 <write_head+0x3a>
  }
  bwrite(buf);
    80003c24:	8526                	mv	a0,s1
    80003c26:	996ff0ef          	jal	80002dbc <bwrite>
  brelse(buf);
    80003c2a:	8526                	mv	a0,s1
    80003c2c:	9c2ff0ef          	jal	80002dee <brelse>
}
    80003c30:	60e2                	ld	ra,24(sp)
    80003c32:	6442                	ld	s0,16(sp)
    80003c34:	64a2                	ld	s1,8(sp)
    80003c36:	6902                	ld	s2,0(sp)
    80003c38:	6105                	addi	sp,sp,32
    80003c3a:	8082                	ret

0000000080003c3c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c3c:	0001c797          	auipc	a5,0x1c
    80003c40:	16c7a783          	lw	a5,364(a5) # 8001fda8 <log+0x28>
    80003c44:	0cf05163          	blez	a5,80003d06 <install_trans+0xca>
{
    80003c48:	715d                	addi	sp,sp,-80
    80003c4a:	e486                	sd	ra,72(sp)
    80003c4c:	e0a2                	sd	s0,64(sp)
    80003c4e:	fc26                	sd	s1,56(sp)
    80003c50:	f84a                	sd	s2,48(sp)
    80003c52:	f44e                	sd	s3,40(sp)
    80003c54:	f052                	sd	s4,32(sp)
    80003c56:	ec56                	sd	s5,24(sp)
    80003c58:	e85a                	sd	s6,16(sp)
    80003c5a:	e45e                	sd	s7,8(sp)
    80003c5c:	e062                	sd	s8,0(sp)
    80003c5e:	0880                	addi	s0,sp,80
    80003c60:	8b2a                	mv	s6,a0
    80003c62:	0001ca97          	auipc	s5,0x1c
    80003c66:	14aa8a93          	addi	s5,s5,330 # 8001fdac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c6a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c6c:	00004c17          	auipc	s8,0x4
    80003c70:	874c0c13          	addi	s8,s8,-1932 # 800074e0 <etext+0x4e0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c74:	0001ca17          	auipc	s4,0x1c
    80003c78:	10ca0a13          	addi	s4,s4,268 # 8001fd80 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c7c:	40000b93          	li	s7,1024
    80003c80:	a025                	j	80003ca8 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c82:	000aa603          	lw	a2,0(s5)
    80003c86:	85ce                	mv	a1,s3
    80003c88:	8562                	mv	a0,s8
    80003c8a:	871fc0ef          	jal	800004fa <printf>
    80003c8e:	a839                	j	80003cac <install_trans+0x70>
    brelse(lbuf);
    80003c90:	854a                	mv	a0,s2
    80003c92:	95cff0ef          	jal	80002dee <brelse>
    brelse(dbuf);
    80003c96:	8526                	mv	a0,s1
    80003c98:	956ff0ef          	jal	80002dee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c9c:	2985                	addiw	s3,s3,1
    80003c9e:	0a91                	addi	s5,s5,4
    80003ca0:	028a2783          	lw	a5,40(s4)
    80003ca4:	04f9d563          	bge	s3,a5,80003cee <install_trans+0xb2>
    if(recovering) {
    80003ca8:	fc0b1de3          	bnez	s6,80003c82 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cac:	018a2583          	lw	a1,24(s4)
    80003cb0:	013585bb          	addw	a1,a1,s3
    80003cb4:	2585                	addiw	a1,a1,1
    80003cb6:	024a2503          	lw	a0,36(s4)
    80003cba:	82cff0ef          	jal	80002ce6 <bread>
    80003cbe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003cc0:	000aa583          	lw	a1,0(s5)
    80003cc4:	024a2503          	lw	a0,36(s4)
    80003cc8:	81eff0ef          	jal	80002ce6 <bread>
    80003ccc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003cce:	865e                	mv	a2,s7
    80003cd0:	05890593          	addi	a1,s2,88
    80003cd4:	05850513          	addi	a0,a0,88
    80003cd8:	880fd0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003cdc:	8526                	mv	a0,s1
    80003cde:	8deff0ef          	jal	80002dbc <bwrite>
    if(recovering == 0)
    80003ce2:	fa0b17e3          	bnez	s6,80003c90 <install_trans+0x54>
      bunpin(dbuf);
    80003ce6:	8526                	mv	a0,s1
    80003ce8:	9beff0ef          	jal	80002ea6 <bunpin>
    80003cec:	b755                	j	80003c90 <install_trans+0x54>
}
    80003cee:	60a6                	ld	ra,72(sp)
    80003cf0:	6406                	ld	s0,64(sp)
    80003cf2:	74e2                	ld	s1,56(sp)
    80003cf4:	7942                	ld	s2,48(sp)
    80003cf6:	79a2                	ld	s3,40(sp)
    80003cf8:	7a02                	ld	s4,32(sp)
    80003cfa:	6ae2                	ld	s5,24(sp)
    80003cfc:	6b42                	ld	s6,16(sp)
    80003cfe:	6ba2                	ld	s7,8(sp)
    80003d00:	6c02                	ld	s8,0(sp)
    80003d02:	6161                	addi	sp,sp,80
    80003d04:	8082                	ret
    80003d06:	8082                	ret

0000000080003d08 <initlog>:
{
    80003d08:	7179                	addi	sp,sp,-48
    80003d0a:	f406                	sd	ra,40(sp)
    80003d0c:	f022                	sd	s0,32(sp)
    80003d0e:	ec26                	sd	s1,24(sp)
    80003d10:	e84a                	sd	s2,16(sp)
    80003d12:	e44e                	sd	s3,8(sp)
    80003d14:	1800                	addi	s0,sp,48
    80003d16:	84aa                	mv	s1,a0
    80003d18:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d1a:	0001c917          	auipc	s2,0x1c
    80003d1e:	06690913          	addi	s2,s2,102 # 8001fd80 <log>
    80003d22:	00003597          	auipc	a1,0x3
    80003d26:	7de58593          	addi	a1,a1,2014 # 80007500 <etext+0x500>
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	e73fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003d30:	0149a583          	lw	a1,20(s3)
    80003d34:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003d38:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	fa9fe0ef          	jal	80002ce6 <bread>
  log.lh.n = lh->n;
    80003d42:	4d30                	lw	a2,88(a0)
    80003d44:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003d48:	00c05f63          	blez	a2,80003d66 <initlog+0x5e>
    80003d4c:	87aa                	mv	a5,a0
    80003d4e:	0001c717          	auipc	a4,0x1c
    80003d52:	05e70713          	addi	a4,a4,94 # 8001fdac <log+0x2c>
    80003d56:	060a                	slli	a2,a2,0x2
    80003d58:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d5a:	4ff4                	lw	a3,92(a5)
    80003d5c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d5e:	0791                	addi	a5,a5,4
    80003d60:	0711                	addi	a4,a4,4
    80003d62:	fec79ce3          	bne	a5,a2,80003d5a <initlog+0x52>
  brelse(buf);
    80003d66:	888ff0ef          	jal	80002dee <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d6a:	4505                	li	a0,1
    80003d6c:	ed1ff0ef          	jal	80003c3c <install_trans>
  log.lh.n = 0;
    80003d70:	0001c797          	auipc	a5,0x1c
    80003d74:	0207ac23          	sw	zero,56(a5) # 8001fda8 <log+0x28>
  write_head(); // clear the log
    80003d78:	e67ff0ef          	jal	80003bde <write_head>
}
    80003d7c:	70a2                	ld	ra,40(sp)
    80003d7e:	7402                	ld	s0,32(sp)
    80003d80:	64e2                	ld	s1,24(sp)
    80003d82:	6942                	ld	s2,16(sp)
    80003d84:	69a2                	ld	s3,8(sp)
    80003d86:	6145                	addi	sp,sp,48
    80003d88:	8082                	ret

0000000080003d8a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d8a:	1101                	addi	sp,sp,-32
    80003d8c:	ec06                	sd	ra,24(sp)
    80003d8e:	e822                	sd	s0,16(sp)
    80003d90:	e426                	sd	s1,8(sp)
    80003d92:	e04a                	sd	s2,0(sp)
    80003d94:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d96:	0001c517          	auipc	a0,0x1c
    80003d9a:	fea50513          	addi	a0,a0,-22 # 8001fd80 <log>
    80003d9e:	e8bfc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003da2:	0001c497          	auipc	s1,0x1c
    80003da6:	fde48493          	addi	s1,s1,-34 # 8001fd80 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003daa:	4979                	li	s2,30
    80003dac:	a029                	j	80003db6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003dae:	85a6                	mv	a1,s1
    80003db0:	8526                	mv	a0,s1
    80003db2:	a50fe0ef          	jal	80002002 <sleep>
    if(log.committing){
    80003db6:	509c                	lw	a5,32(s1)
    80003db8:	fbfd                	bnez	a5,80003dae <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dba:	4cd8                	lw	a4,28(s1)
    80003dbc:	2705                	addiw	a4,a4,1
    80003dbe:	0027179b          	slliw	a5,a4,0x2
    80003dc2:	9fb9                	addw	a5,a5,a4
    80003dc4:	0017979b          	slliw	a5,a5,0x1
    80003dc8:	5494                	lw	a3,40(s1)
    80003dca:	9fb5                	addw	a5,a5,a3
    80003dcc:	00f95763          	bge	s2,a5,80003dda <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003dd0:	85a6                	mv	a1,s1
    80003dd2:	8526                	mv	a0,s1
    80003dd4:	a2efe0ef          	jal	80002002 <sleep>
    80003dd8:	bff9                	j	80003db6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003dda:	0001c797          	auipc	a5,0x1c
    80003dde:	fce7a123          	sw	a4,-62(a5) # 8001fd9c <log+0x1c>
      release(&log.lock);
    80003de2:	0001c517          	auipc	a0,0x1c
    80003de6:	f9e50513          	addi	a0,a0,-98 # 8001fd80 <log>
    80003dea:	ed3fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003dee:	60e2                	ld	ra,24(sp)
    80003df0:	6442                	ld	s0,16(sp)
    80003df2:	64a2                	ld	s1,8(sp)
    80003df4:	6902                	ld	s2,0(sp)
    80003df6:	6105                	addi	sp,sp,32
    80003df8:	8082                	ret

0000000080003dfa <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003dfa:	7139                	addi	sp,sp,-64
    80003dfc:	fc06                	sd	ra,56(sp)
    80003dfe:	f822                	sd	s0,48(sp)
    80003e00:	f426                	sd	s1,40(sp)
    80003e02:	f04a                	sd	s2,32(sp)
    80003e04:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e06:	0001c497          	auipc	s1,0x1c
    80003e0a:	f7a48493          	addi	s1,s1,-134 # 8001fd80 <log>
    80003e0e:	8526                	mv	a0,s1
    80003e10:	e19fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003e14:	4cdc                	lw	a5,28(s1)
    80003e16:	37fd                	addiw	a5,a5,-1
    80003e18:	893e                	mv	s2,a5
    80003e1a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e1c:	509c                	lw	a5,32(s1)
    80003e1e:	e7b1                	bnez	a5,80003e6a <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e20:	04091e63          	bnez	s2,80003e7c <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003e24:	0001c497          	auipc	s1,0x1c
    80003e28:	f5c48493          	addi	s1,s1,-164 # 8001fd80 <log>
    80003e2c:	4785                	li	a5,1
    80003e2e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e30:	8526                	mv	a0,s1
    80003e32:	e8bfc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e36:	549c                	lw	a5,40(s1)
    80003e38:	06f04463          	bgtz	a5,80003ea0 <end_op+0xa6>
    acquire(&log.lock);
    80003e3c:	0001c517          	auipc	a0,0x1c
    80003e40:	f4450513          	addi	a0,a0,-188 # 8001fd80 <log>
    80003e44:	de5fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003e48:	0001c797          	auipc	a5,0x1c
    80003e4c:	f407ac23          	sw	zero,-168(a5) # 8001fda0 <log+0x20>
    wakeup(&log);
    80003e50:	0001c517          	auipc	a0,0x1c
    80003e54:	f3050513          	addi	a0,a0,-208 # 8001fd80 <log>
    80003e58:	9f6fe0ef          	jal	8000204e <wakeup>
    release(&log.lock);
    80003e5c:	0001c517          	auipc	a0,0x1c
    80003e60:	f2450513          	addi	a0,a0,-220 # 8001fd80 <log>
    80003e64:	e59fc0ef          	jal	80000cbc <release>
}
    80003e68:	a035                	j	80003e94 <end_op+0x9a>
    80003e6a:	ec4e                	sd	s3,24(sp)
    80003e6c:	e852                	sd	s4,16(sp)
    80003e6e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e70:	00003517          	auipc	a0,0x3
    80003e74:	69850513          	addi	a0,a0,1688 # 80007508 <etext+0x508>
    80003e78:	9adfc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003e7c:	0001c517          	auipc	a0,0x1c
    80003e80:	f0450513          	addi	a0,a0,-252 # 8001fd80 <log>
    80003e84:	9cafe0ef          	jal	8000204e <wakeup>
  release(&log.lock);
    80003e88:	0001c517          	auipc	a0,0x1c
    80003e8c:	ef850513          	addi	a0,a0,-264 # 8001fd80 <log>
    80003e90:	e2dfc0ef          	jal	80000cbc <release>
}
    80003e94:	70e2                	ld	ra,56(sp)
    80003e96:	7442                	ld	s0,48(sp)
    80003e98:	74a2                	ld	s1,40(sp)
    80003e9a:	7902                	ld	s2,32(sp)
    80003e9c:	6121                	addi	sp,sp,64
    80003e9e:	8082                	ret
    80003ea0:	ec4e                	sd	s3,24(sp)
    80003ea2:	e852                	sd	s4,16(sp)
    80003ea4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ea6:	0001ca97          	auipc	s5,0x1c
    80003eaa:	f06a8a93          	addi	s5,s5,-250 # 8001fdac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003eae:	0001ca17          	auipc	s4,0x1c
    80003eb2:	ed2a0a13          	addi	s4,s4,-302 # 8001fd80 <log>
    80003eb6:	018a2583          	lw	a1,24(s4)
    80003eba:	012585bb          	addw	a1,a1,s2
    80003ebe:	2585                	addiw	a1,a1,1
    80003ec0:	024a2503          	lw	a0,36(s4)
    80003ec4:	e23fe0ef          	jal	80002ce6 <bread>
    80003ec8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003eca:	000aa583          	lw	a1,0(s5)
    80003ece:	024a2503          	lw	a0,36(s4)
    80003ed2:	e15fe0ef          	jal	80002ce6 <bread>
    80003ed6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ed8:	40000613          	li	a2,1024
    80003edc:	05850593          	addi	a1,a0,88
    80003ee0:	05848513          	addi	a0,s1,88
    80003ee4:	e75fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003ee8:	8526                	mv	a0,s1
    80003eea:	ed3fe0ef          	jal	80002dbc <bwrite>
    brelse(from);
    80003eee:	854e                	mv	a0,s3
    80003ef0:	efffe0ef          	jal	80002dee <brelse>
    brelse(to);
    80003ef4:	8526                	mv	a0,s1
    80003ef6:	ef9fe0ef          	jal	80002dee <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003efa:	2905                	addiw	s2,s2,1
    80003efc:	0a91                	addi	s5,s5,4
    80003efe:	028a2783          	lw	a5,40(s4)
    80003f02:	faf94ae3          	blt	s2,a5,80003eb6 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f06:	cd9ff0ef          	jal	80003bde <write_head>
    install_trans(0); // Now install writes to home locations
    80003f0a:	4501                	li	a0,0
    80003f0c:	d31ff0ef          	jal	80003c3c <install_trans>
    log.lh.n = 0;
    80003f10:	0001c797          	auipc	a5,0x1c
    80003f14:	e807ac23          	sw	zero,-360(a5) # 8001fda8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f18:	cc7ff0ef          	jal	80003bde <write_head>
    80003f1c:	69e2                	ld	s3,24(sp)
    80003f1e:	6a42                	ld	s4,16(sp)
    80003f20:	6aa2                	ld	s5,8(sp)
    80003f22:	bf29                	j	80003e3c <end_op+0x42>

0000000080003f24 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f24:	1101                	addi	sp,sp,-32
    80003f26:	ec06                	sd	ra,24(sp)
    80003f28:	e822                	sd	s0,16(sp)
    80003f2a:	e426                	sd	s1,8(sp)
    80003f2c:	1000                	addi	s0,sp,32
    80003f2e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f30:	0001c517          	auipc	a0,0x1c
    80003f34:	e5050513          	addi	a0,a0,-432 # 8001fd80 <log>
    80003f38:	cf1fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f3c:	0001c617          	auipc	a2,0x1c
    80003f40:	e6c62603          	lw	a2,-404(a2) # 8001fda8 <log+0x28>
    80003f44:	47f5                	li	a5,29
    80003f46:	04c7cd63          	blt	a5,a2,80003fa0 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f4a:	0001c797          	auipc	a5,0x1c
    80003f4e:	e527a783          	lw	a5,-430(a5) # 8001fd9c <log+0x1c>
    80003f52:	04f05d63          	blez	a5,80003fac <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f56:	4781                	li	a5,0
    80003f58:	06c05063          	blez	a2,80003fb8 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f5c:	44cc                	lw	a1,12(s1)
    80003f5e:	0001c717          	auipc	a4,0x1c
    80003f62:	e4e70713          	addi	a4,a4,-434 # 8001fdac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f66:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f68:	4314                	lw	a3,0(a4)
    80003f6a:	04b68763          	beq	a3,a1,80003fb8 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003f6e:	2785                	addiw	a5,a5,1
    80003f70:	0711                	addi	a4,a4,4
    80003f72:	fef61be3          	bne	a2,a5,80003f68 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f76:	060a                	slli	a2,a2,0x2
    80003f78:	02060613          	addi	a2,a2,32
    80003f7c:	0001c797          	auipc	a5,0x1c
    80003f80:	e0478793          	addi	a5,a5,-508 # 8001fd80 <log>
    80003f84:	97b2                	add	a5,a5,a2
    80003f86:	44d8                	lw	a4,12(s1)
    80003f88:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f8a:	8526                	mv	a0,s1
    80003f8c:	ee7fe0ef          	jal	80002e72 <bpin>
    log.lh.n++;
    80003f90:	0001c717          	auipc	a4,0x1c
    80003f94:	df070713          	addi	a4,a4,-528 # 8001fd80 <log>
    80003f98:	571c                	lw	a5,40(a4)
    80003f9a:	2785                	addiw	a5,a5,1
    80003f9c:	d71c                	sw	a5,40(a4)
    80003f9e:	a815                	j	80003fd2 <log_write+0xae>
    panic("too big a transaction");
    80003fa0:	00003517          	auipc	a0,0x3
    80003fa4:	57850513          	addi	a0,a0,1400 # 80007518 <etext+0x518>
    80003fa8:	87dfc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80003fac:	00003517          	auipc	a0,0x3
    80003fb0:	58450513          	addi	a0,a0,1412 # 80007530 <etext+0x530>
    80003fb4:	871fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80003fb8:	00279693          	slli	a3,a5,0x2
    80003fbc:	02068693          	addi	a3,a3,32
    80003fc0:	0001c717          	auipc	a4,0x1c
    80003fc4:	dc070713          	addi	a4,a4,-576 # 8001fd80 <log>
    80003fc8:	9736                	add	a4,a4,a3
    80003fca:	44d4                	lw	a3,12(s1)
    80003fcc:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003fce:	faf60ee3          	beq	a2,a5,80003f8a <log_write+0x66>
  }
  release(&log.lock);
    80003fd2:	0001c517          	auipc	a0,0x1c
    80003fd6:	dae50513          	addi	a0,a0,-594 # 8001fd80 <log>
    80003fda:	ce3fc0ef          	jal	80000cbc <release>
}
    80003fde:	60e2                	ld	ra,24(sp)
    80003fe0:	6442                	ld	s0,16(sp)
    80003fe2:	64a2                	ld	s1,8(sp)
    80003fe4:	6105                	addi	sp,sp,32
    80003fe6:	8082                	ret

0000000080003fe8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fe8:	1101                	addi	sp,sp,-32
    80003fea:	ec06                	sd	ra,24(sp)
    80003fec:	e822                	sd	s0,16(sp)
    80003fee:	e426                	sd	s1,8(sp)
    80003ff0:	e04a                	sd	s2,0(sp)
    80003ff2:	1000                	addi	s0,sp,32
    80003ff4:	84aa                	mv	s1,a0
    80003ff6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ff8:	00003597          	auipc	a1,0x3
    80003ffc:	55858593          	addi	a1,a1,1368 # 80007550 <etext+0x550>
    80004000:	0521                	addi	a0,a0,8
    80004002:	b9dfc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80004006:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000400a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000400e:	0204a423          	sw	zero,40(s1)
}
    80004012:	60e2                	ld	ra,24(sp)
    80004014:	6442                	ld	s0,16(sp)
    80004016:	64a2                	ld	s1,8(sp)
    80004018:	6902                	ld	s2,0(sp)
    8000401a:	6105                	addi	sp,sp,32
    8000401c:	8082                	ret

000000008000401e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000401e:	1101                	addi	sp,sp,-32
    80004020:	ec06                	sd	ra,24(sp)
    80004022:	e822                	sd	s0,16(sp)
    80004024:	e426                	sd	s1,8(sp)
    80004026:	e04a                	sd	s2,0(sp)
    80004028:	1000                	addi	s0,sp,32
    8000402a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000402c:	00850913          	addi	s2,a0,8
    80004030:	854a                	mv	a0,s2
    80004032:	bf7fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004036:	409c                	lw	a5,0(s1)
    80004038:	c799                	beqz	a5,80004046 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000403a:	85ca                	mv	a1,s2
    8000403c:	8526                	mv	a0,s1
    8000403e:	fc5fd0ef          	jal	80002002 <sleep>
  while (lk->locked) {
    80004042:	409c                	lw	a5,0(s1)
    80004044:	fbfd                	bnez	a5,8000403a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004046:	4785                	li	a5,1
    80004048:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000404a:	8edfd0ef          	jal	80001936 <myproc>
    8000404e:	591c                	lw	a5,48(a0)
    80004050:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004052:	854a                	mv	a0,s2
    80004054:	c69fc0ef          	jal	80000cbc <release>
}
    80004058:	60e2                	ld	ra,24(sp)
    8000405a:	6442                	ld	s0,16(sp)
    8000405c:	64a2                	ld	s1,8(sp)
    8000405e:	6902                	ld	s2,0(sp)
    80004060:	6105                	addi	sp,sp,32
    80004062:	8082                	ret

0000000080004064 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004064:	1101                	addi	sp,sp,-32
    80004066:	ec06                	sd	ra,24(sp)
    80004068:	e822                	sd	s0,16(sp)
    8000406a:	e426                	sd	s1,8(sp)
    8000406c:	e04a                	sd	s2,0(sp)
    8000406e:	1000                	addi	s0,sp,32
    80004070:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004072:	00850913          	addi	s2,a0,8
    80004076:	854a                	mv	a0,s2
    80004078:	bb1fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000407c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004080:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004084:	8526                	mv	a0,s1
    80004086:	fc9fd0ef          	jal	8000204e <wakeup>
  release(&lk->lk);
    8000408a:	854a                	mv	a0,s2
    8000408c:	c31fc0ef          	jal	80000cbc <release>
}
    80004090:	60e2                	ld	ra,24(sp)
    80004092:	6442                	ld	s0,16(sp)
    80004094:	64a2                	ld	s1,8(sp)
    80004096:	6902                	ld	s2,0(sp)
    80004098:	6105                	addi	sp,sp,32
    8000409a:	8082                	ret

000000008000409c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000409c:	7179                	addi	sp,sp,-48
    8000409e:	f406                	sd	ra,40(sp)
    800040a0:	f022                	sd	s0,32(sp)
    800040a2:	ec26                	sd	s1,24(sp)
    800040a4:	e84a                	sd	s2,16(sp)
    800040a6:	1800                	addi	s0,sp,48
    800040a8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800040aa:	00850913          	addi	s2,a0,8
    800040ae:	854a                	mv	a0,s2
    800040b0:	b79fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040b4:	409c                	lw	a5,0(s1)
    800040b6:	ef81                	bnez	a5,800040ce <holdingsleep+0x32>
    800040b8:	4481                	li	s1,0
  release(&lk->lk);
    800040ba:	854a                	mv	a0,s2
    800040bc:	c01fc0ef          	jal	80000cbc <release>
  return r;
}
    800040c0:	8526                	mv	a0,s1
    800040c2:	70a2                	ld	ra,40(sp)
    800040c4:	7402                	ld	s0,32(sp)
    800040c6:	64e2                	ld	s1,24(sp)
    800040c8:	6942                	ld	s2,16(sp)
    800040ca:	6145                	addi	sp,sp,48
    800040cc:	8082                	ret
    800040ce:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040d0:	0284a983          	lw	s3,40(s1)
    800040d4:	863fd0ef          	jal	80001936 <myproc>
    800040d8:	5904                	lw	s1,48(a0)
    800040da:	413484b3          	sub	s1,s1,s3
    800040de:	0014b493          	seqz	s1,s1
    800040e2:	69a2                	ld	s3,8(sp)
    800040e4:	bfd9                	j	800040ba <holdingsleep+0x1e>

00000000800040e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040e6:	1141                	addi	sp,sp,-16
    800040e8:	e406                	sd	ra,8(sp)
    800040ea:	e022                	sd	s0,0(sp)
    800040ec:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040ee:	00003597          	auipc	a1,0x3
    800040f2:	47258593          	addi	a1,a1,1138 # 80007560 <etext+0x560>
    800040f6:	0001c517          	auipc	a0,0x1c
    800040fa:	dd250513          	addi	a0,a0,-558 # 8001fec8 <ftable>
    800040fe:	aa1fc0ef          	jal	80000b9e <initlock>
}
    80004102:	60a2                	ld	ra,8(sp)
    80004104:	6402                	ld	s0,0(sp)
    80004106:	0141                	addi	sp,sp,16
    80004108:	8082                	ret

000000008000410a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000410a:	1101                	addi	sp,sp,-32
    8000410c:	ec06                	sd	ra,24(sp)
    8000410e:	e822                	sd	s0,16(sp)
    80004110:	e426                	sd	s1,8(sp)
    80004112:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004114:	0001c517          	auipc	a0,0x1c
    80004118:	db450513          	addi	a0,a0,-588 # 8001fec8 <ftable>
    8000411c:	b0dfc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004120:	0001c497          	auipc	s1,0x1c
    80004124:	dc048493          	addi	s1,s1,-576 # 8001fee0 <ftable+0x18>
    80004128:	0001d717          	auipc	a4,0x1d
    8000412c:	d5870713          	addi	a4,a4,-680 # 80020e80 <disk>
    if(f->ref == 0){
    80004130:	40dc                	lw	a5,4(s1)
    80004132:	cf89                	beqz	a5,8000414c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004134:	02848493          	addi	s1,s1,40
    80004138:	fee49ce3          	bne	s1,a4,80004130 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000413c:	0001c517          	auipc	a0,0x1c
    80004140:	d8c50513          	addi	a0,a0,-628 # 8001fec8 <ftable>
    80004144:	b79fc0ef          	jal	80000cbc <release>
  return 0;
    80004148:	4481                	li	s1,0
    8000414a:	a809                	j	8000415c <filealloc+0x52>
      f->ref = 1;
    8000414c:	4785                	li	a5,1
    8000414e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004150:	0001c517          	auipc	a0,0x1c
    80004154:	d7850513          	addi	a0,a0,-648 # 8001fec8 <ftable>
    80004158:	b65fc0ef          	jal	80000cbc <release>
}
    8000415c:	8526                	mv	a0,s1
    8000415e:	60e2                	ld	ra,24(sp)
    80004160:	6442                	ld	s0,16(sp)
    80004162:	64a2                	ld	s1,8(sp)
    80004164:	6105                	addi	sp,sp,32
    80004166:	8082                	ret

0000000080004168 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004168:	1101                	addi	sp,sp,-32
    8000416a:	ec06                	sd	ra,24(sp)
    8000416c:	e822                	sd	s0,16(sp)
    8000416e:	e426                	sd	s1,8(sp)
    80004170:	1000                	addi	s0,sp,32
    80004172:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004174:	0001c517          	auipc	a0,0x1c
    80004178:	d5450513          	addi	a0,a0,-684 # 8001fec8 <ftable>
    8000417c:	aadfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004180:	40dc                	lw	a5,4(s1)
    80004182:	02f05063          	blez	a5,800041a2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004186:	2785                	addiw	a5,a5,1
    80004188:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000418a:	0001c517          	auipc	a0,0x1c
    8000418e:	d3e50513          	addi	a0,a0,-706 # 8001fec8 <ftable>
    80004192:	b2bfc0ef          	jal	80000cbc <release>
  return f;
}
    80004196:	8526                	mv	a0,s1
    80004198:	60e2                	ld	ra,24(sp)
    8000419a:	6442                	ld	s0,16(sp)
    8000419c:	64a2                	ld	s1,8(sp)
    8000419e:	6105                	addi	sp,sp,32
    800041a0:	8082                	ret
    panic("filedup");
    800041a2:	00003517          	auipc	a0,0x3
    800041a6:	3c650513          	addi	a0,a0,966 # 80007568 <etext+0x568>
    800041aa:	e7afc0ef          	jal	80000824 <panic>

00000000800041ae <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041ae:	7139                	addi	sp,sp,-64
    800041b0:	fc06                	sd	ra,56(sp)
    800041b2:	f822                	sd	s0,48(sp)
    800041b4:	f426                	sd	s1,40(sp)
    800041b6:	0080                	addi	s0,sp,64
    800041b8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041ba:	0001c517          	auipc	a0,0x1c
    800041be:	d0e50513          	addi	a0,a0,-754 # 8001fec8 <ftable>
    800041c2:	a67fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800041c6:	40dc                	lw	a5,4(s1)
    800041c8:	04f05a63          	blez	a5,8000421c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800041cc:	37fd                	addiw	a5,a5,-1
    800041ce:	c0dc                	sw	a5,4(s1)
    800041d0:	06f04063          	bgtz	a5,80004230 <fileclose+0x82>
    800041d4:	f04a                	sd	s2,32(sp)
    800041d6:	ec4e                	sd	s3,24(sp)
    800041d8:	e852                	sd	s4,16(sp)
    800041da:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041dc:	0004a903          	lw	s2,0(s1)
    800041e0:	0094c783          	lbu	a5,9(s1)
    800041e4:	89be                	mv	s3,a5
    800041e6:	689c                	ld	a5,16(s1)
    800041e8:	8a3e                	mv	s4,a5
    800041ea:	6c9c                	ld	a5,24(s1)
    800041ec:	8abe                	mv	s5,a5
  f->ref = 0;
    800041ee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041f2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041f6:	0001c517          	auipc	a0,0x1c
    800041fa:	cd250513          	addi	a0,a0,-814 # 8001fec8 <ftable>
    800041fe:	abffc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004202:	4785                	li	a5,1
    80004204:	04f90163          	beq	s2,a5,80004246 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004208:	ffe9079b          	addiw	a5,s2,-2
    8000420c:	4705                	li	a4,1
    8000420e:	04f77563          	bgeu	a4,a5,80004258 <fileclose+0xaa>
    80004212:	7902                	ld	s2,32(sp)
    80004214:	69e2                	ld	s3,24(sp)
    80004216:	6a42                	ld	s4,16(sp)
    80004218:	6aa2                	ld	s5,8(sp)
    8000421a:	a00d                	j	8000423c <fileclose+0x8e>
    8000421c:	f04a                	sd	s2,32(sp)
    8000421e:	ec4e                	sd	s3,24(sp)
    80004220:	e852                	sd	s4,16(sp)
    80004222:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004224:	00003517          	auipc	a0,0x3
    80004228:	34c50513          	addi	a0,a0,844 # 80007570 <etext+0x570>
    8000422c:	df8fc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004230:	0001c517          	auipc	a0,0x1c
    80004234:	c9850513          	addi	a0,a0,-872 # 8001fec8 <ftable>
    80004238:	a85fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000423c:	70e2                	ld	ra,56(sp)
    8000423e:	7442                	ld	s0,48(sp)
    80004240:	74a2                	ld	s1,40(sp)
    80004242:	6121                	addi	sp,sp,64
    80004244:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004246:	85ce                	mv	a1,s3
    80004248:	8552                	mv	a0,s4
    8000424a:	348000ef          	jal	80004592 <pipeclose>
    8000424e:	7902                	ld	s2,32(sp)
    80004250:	69e2                	ld	s3,24(sp)
    80004252:	6a42                	ld	s4,16(sp)
    80004254:	6aa2                	ld	s5,8(sp)
    80004256:	b7dd                	j	8000423c <fileclose+0x8e>
    begin_op();
    80004258:	b33ff0ef          	jal	80003d8a <begin_op>
    iput(ff.ip);
    8000425c:	8556                	mv	a0,s5
    8000425e:	aa2ff0ef          	jal	80003500 <iput>
    end_op();
    80004262:	b99ff0ef          	jal	80003dfa <end_op>
    80004266:	7902                	ld	s2,32(sp)
    80004268:	69e2                	ld	s3,24(sp)
    8000426a:	6a42                	ld	s4,16(sp)
    8000426c:	6aa2                	ld	s5,8(sp)
    8000426e:	b7f9                	j	8000423c <fileclose+0x8e>

0000000080004270 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004270:	715d                	addi	sp,sp,-80
    80004272:	e486                	sd	ra,72(sp)
    80004274:	e0a2                	sd	s0,64(sp)
    80004276:	fc26                	sd	s1,56(sp)
    80004278:	f052                	sd	s4,32(sp)
    8000427a:	0880                	addi	s0,sp,80
    8000427c:	84aa                	mv	s1,a0
    8000427e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004280:	eb6fd0ef          	jal	80001936 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004284:	409c                	lw	a5,0(s1)
    80004286:	37f9                	addiw	a5,a5,-2
    80004288:	4705                	li	a4,1
    8000428a:	04f76263          	bltu	a4,a5,800042ce <filestat+0x5e>
    8000428e:	f84a                	sd	s2,48(sp)
    80004290:	f44e                	sd	s3,40(sp)
    80004292:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004294:	6c88                	ld	a0,24(s1)
    80004296:	8e8ff0ef          	jal	8000337e <ilock>
    stati(f->ip, &st);
    8000429a:	fb840913          	addi	s2,s0,-72
    8000429e:	85ca                	mv	a1,s2
    800042a0:	6c88                	ld	a0,24(s1)
    800042a2:	c40ff0ef          	jal	800036e2 <stati>
    iunlock(f->ip);
    800042a6:	6c88                	ld	a0,24(s1)
    800042a8:	984ff0ef          	jal	8000342c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800042ac:	46e1                	li	a3,24
    800042ae:	864a                	mv	a2,s2
    800042b0:	85d2                	mv	a1,s4
    800042b2:	0509b503          	ld	a0,80(s3)
    800042b6:	b9efd0ef          	jal	80001654 <copyout>
    800042ba:	41f5551b          	sraiw	a0,a0,0x1f
    800042be:	7942                	ld	s2,48(sp)
    800042c0:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042c2:	60a6                	ld	ra,72(sp)
    800042c4:	6406                	ld	s0,64(sp)
    800042c6:	74e2                	ld	s1,56(sp)
    800042c8:	7a02                	ld	s4,32(sp)
    800042ca:	6161                	addi	sp,sp,80
    800042cc:	8082                	ret
  return -1;
    800042ce:	557d                	li	a0,-1
    800042d0:	bfcd                	j	800042c2 <filestat+0x52>

00000000800042d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042d2:	7179                	addi	sp,sp,-48
    800042d4:	f406                	sd	ra,40(sp)
    800042d6:	f022                	sd	s0,32(sp)
    800042d8:	e84a                	sd	s2,16(sp)
    800042da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800042dc:	00854783          	lbu	a5,8(a0)
    800042e0:	cfd1                	beqz	a5,8000437c <fileread+0xaa>
    800042e2:	ec26                	sd	s1,24(sp)
    800042e4:	e44e                	sd	s3,8(sp)
    800042e6:	84aa                	mv	s1,a0
    800042e8:	892e                	mv	s2,a1
    800042ea:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800042ec:	411c                	lw	a5,0(a0)
    800042ee:	4705                	li	a4,1
    800042f0:	04e78363          	beq	a5,a4,80004336 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042f4:	470d                	li	a4,3
    800042f6:	04e78763          	beq	a5,a4,80004344 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800042fa:	4709                	li	a4,2
    800042fc:	06e79a63          	bne	a5,a4,80004370 <fileread+0x9e>
    ilock(f->ip);
    80004300:	6d08                	ld	a0,24(a0)
    80004302:	87cff0ef          	jal	8000337e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004306:	874e                	mv	a4,s3
    80004308:	5094                	lw	a3,32(s1)
    8000430a:	864a                	mv	a2,s2
    8000430c:	4585                	li	a1,1
    8000430e:	6c88                	ld	a0,24(s1)
    80004310:	c00ff0ef          	jal	80003710 <readi>
    80004314:	892a                	mv	s2,a0
    80004316:	00a05563          	blez	a0,80004320 <fileread+0x4e>
      f->off += r;
    8000431a:	509c                	lw	a5,32(s1)
    8000431c:	9fa9                	addw	a5,a5,a0
    8000431e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004320:	6c88                	ld	a0,24(s1)
    80004322:	90aff0ef          	jal	8000342c <iunlock>
    80004326:	64e2                	ld	s1,24(sp)
    80004328:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000432a:	854a                	mv	a0,s2
    8000432c:	70a2                	ld	ra,40(sp)
    8000432e:	7402                	ld	s0,32(sp)
    80004330:	6942                	ld	s2,16(sp)
    80004332:	6145                	addi	sp,sp,48
    80004334:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004336:	6908                	ld	a0,16(a0)
    80004338:	3b0000ef          	jal	800046e8 <piperead>
    8000433c:	892a                	mv	s2,a0
    8000433e:	64e2                	ld	s1,24(sp)
    80004340:	69a2                	ld	s3,8(sp)
    80004342:	b7e5                	j	8000432a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004344:	02451783          	lh	a5,36(a0)
    80004348:	03079693          	slli	a3,a5,0x30
    8000434c:	92c1                	srli	a3,a3,0x30
    8000434e:	4725                	li	a4,9
    80004350:	02d76963          	bltu	a4,a3,80004382 <fileread+0xb0>
    80004354:	0792                	slli	a5,a5,0x4
    80004356:	0001c717          	auipc	a4,0x1c
    8000435a:	ad270713          	addi	a4,a4,-1326 # 8001fe28 <devsw>
    8000435e:	97ba                	add	a5,a5,a4
    80004360:	639c                	ld	a5,0(a5)
    80004362:	c78d                	beqz	a5,8000438c <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004364:	4505                	li	a0,1
    80004366:	9782                	jalr	a5
    80004368:	892a                	mv	s2,a0
    8000436a:	64e2                	ld	s1,24(sp)
    8000436c:	69a2                	ld	s3,8(sp)
    8000436e:	bf75                	j	8000432a <fileread+0x58>
    panic("fileread");
    80004370:	00003517          	auipc	a0,0x3
    80004374:	21050513          	addi	a0,a0,528 # 80007580 <etext+0x580>
    80004378:	cacfc0ef          	jal	80000824 <panic>
    return -1;
    8000437c:	57fd                	li	a5,-1
    8000437e:	893e                	mv	s2,a5
    80004380:	b76d                	j	8000432a <fileread+0x58>
      return -1;
    80004382:	57fd                	li	a5,-1
    80004384:	893e                	mv	s2,a5
    80004386:	64e2                	ld	s1,24(sp)
    80004388:	69a2                	ld	s3,8(sp)
    8000438a:	b745                	j	8000432a <fileread+0x58>
    8000438c:	57fd                	li	a5,-1
    8000438e:	893e                	mv	s2,a5
    80004390:	64e2                	ld	s1,24(sp)
    80004392:	69a2                	ld	s3,8(sp)
    80004394:	bf59                	j	8000432a <fileread+0x58>

0000000080004396 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004396:	00954783          	lbu	a5,9(a0)
    8000439a:	10078f63          	beqz	a5,800044b8 <filewrite+0x122>
{
    8000439e:	711d                	addi	sp,sp,-96
    800043a0:	ec86                	sd	ra,88(sp)
    800043a2:	e8a2                	sd	s0,80(sp)
    800043a4:	e0ca                	sd	s2,64(sp)
    800043a6:	f456                	sd	s5,40(sp)
    800043a8:	f05a                	sd	s6,32(sp)
    800043aa:	1080                	addi	s0,sp,96
    800043ac:	892a                	mv	s2,a0
    800043ae:	8b2e                	mv	s6,a1
    800043b0:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800043b2:	411c                	lw	a5,0(a0)
    800043b4:	4705                	li	a4,1
    800043b6:	02e78a63          	beq	a5,a4,800043ea <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043ba:	470d                	li	a4,3
    800043bc:	02e78b63          	beq	a5,a4,800043f2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800043c0:	4709                	li	a4,2
    800043c2:	0ce79f63          	bne	a5,a4,800044a0 <filewrite+0x10a>
    800043c6:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800043c8:	0ac05a63          	blez	a2,8000447c <filewrite+0xe6>
    800043cc:	e4a6                	sd	s1,72(sp)
    800043ce:	fc4e                	sd	s3,56(sp)
    800043d0:	ec5e                	sd	s7,24(sp)
    800043d2:	e862                	sd	s8,16(sp)
    800043d4:	e466                	sd	s9,8(sp)
    int i = 0;
    800043d6:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800043d8:	6b85                	lui	s7,0x1
    800043da:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800043de:	6785                	lui	a5,0x1
    800043e0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800043e4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043e6:	4c05                	li	s8,1
    800043e8:	a8ad                	j	80004462 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800043ea:	6908                	ld	a0,16(a0)
    800043ec:	204000ef          	jal	800045f0 <pipewrite>
    800043f0:	a04d                	j	80004492 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043f2:	02451783          	lh	a5,36(a0)
    800043f6:	03079693          	slli	a3,a5,0x30
    800043fa:	92c1                	srli	a3,a3,0x30
    800043fc:	4725                	li	a4,9
    800043fe:	0ad76f63          	bltu	a4,a3,800044bc <filewrite+0x126>
    80004402:	0792                	slli	a5,a5,0x4
    80004404:	0001c717          	auipc	a4,0x1c
    80004408:	a2470713          	addi	a4,a4,-1500 # 8001fe28 <devsw>
    8000440c:	97ba                	add	a5,a5,a4
    8000440e:	679c                	ld	a5,8(a5)
    80004410:	cbc5                	beqz	a5,800044c0 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004412:	4505                	li	a0,1
    80004414:	9782                	jalr	a5
    80004416:	a8b5                	j	80004492 <filewrite+0xfc>
      if(n1 > max)
    80004418:	2981                	sext.w	s3,s3
      begin_op();
    8000441a:	971ff0ef          	jal	80003d8a <begin_op>
      ilock(f->ip);
    8000441e:	01893503          	ld	a0,24(s2)
    80004422:	f5dfe0ef          	jal	8000337e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004426:	874e                	mv	a4,s3
    80004428:	02092683          	lw	a3,32(s2)
    8000442c:	016a0633          	add	a2,s4,s6
    80004430:	85e2                	mv	a1,s8
    80004432:	01893503          	ld	a0,24(s2)
    80004436:	bccff0ef          	jal	80003802 <writei>
    8000443a:	84aa                	mv	s1,a0
    8000443c:	00a05763          	blez	a0,8000444a <filewrite+0xb4>
        f->off += r;
    80004440:	02092783          	lw	a5,32(s2)
    80004444:	9fa9                	addw	a5,a5,a0
    80004446:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000444a:	01893503          	ld	a0,24(s2)
    8000444e:	fdffe0ef          	jal	8000342c <iunlock>
      end_op();
    80004452:	9a9ff0ef          	jal	80003dfa <end_op>

      if(r != n1){
    80004456:	02999563          	bne	s3,s1,80004480 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    8000445a:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000445e:	015a5963          	bge	s4,s5,80004470 <filewrite+0xda>
      int n1 = n - i;
    80004462:	414a87bb          	subw	a5,s5,s4
    80004466:	89be                	mv	s3,a5
      if(n1 > max)
    80004468:	fafbd8e3          	bge	s7,a5,80004418 <filewrite+0x82>
    8000446c:	89e6                	mv	s3,s9
    8000446e:	b76d                	j	80004418 <filewrite+0x82>
    80004470:	64a6                	ld	s1,72(sp)
    80004472:	79e2                	ld	s3,56(sp)
    80004474:	6be2                	ld	s7,24(sp)
    80004476:	6c42                	ld	s8,16(sp)
    80004478:	6ca2                	ld	s9,8(sp)
    8000447a:	a801                	j	8000448a <filewrite+0xf4>
    int i = 0;
    8000447c:	4a01                	li	s4,0
    8000447e:	a031                	j	8000448a <filewrite+0xf4>
    80004480:	64a6                	ld	s1,72(sp)
    80004482:	79e2                	ld	s3,56(sp)
    80004484:	6be2                	ld	s7,24(sp)
    80004486:	6c42                	ld	s8,16(sp)
    80004488:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    8000448a:	034a9d63          	bne	s5,s4,800044c4 <filewrite+0x12e>
    8000448e:	8556                	mv	a0,s5
    80004490:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004492:	60e6                	ld	ra,88(sp)
    80004494:	6446                	ld	s0,80(sp)
    80004496:	6906                	ld	s2,64(sp)
    80004498:	7aa2                	ld	s5,40(sp)
    8000449a:	7b02                	ld	s6,32(sp)
    8000449c:	6125                	addi	sp,sp,96
    8000449e:	8082                	ret
    800044a0:	e4a6                	sd	s1,72(sp)
    800044a2:	fc4e                	sd	s3,56(sp)
    800044a4:	f852                	sd	s4,48(sp)
    800044a6:	ec5e                	sd	s7,24(sp)
    800044a8:	e862                	sd	s8,16(sp)
    800044aa:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800044ac:	00003517          	auipc	a0,0x3
    800044b0:	0e450513          	addi	a0,a0,228 # 80007590 <etext+0x590>
    800044b4:	b70fc0ef          	jal	80000824 <panic>
    return -1;
    800044b8:	557d                	li	a0,-1
}
    800044ba:	8082                	ret
      return -1;
    800044bc:	557d                	li	a0,-1
    800044be:	bfd1                	j	80004492 <filewrite+0xfc>
    800044c0:	557d                	li	a0,-1
    800044c2:	bfc1                	j	80004492 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800044c4:	557d                	li	a0,-1
    800044c6:	7a42                	ld	s4,48(sp)
    800044c8:	b7e9                	j	80004492 <filewrite+0xfc>

00000000800044ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044ca:	7179                	addi	sp,sp,-48
    800044cc:	f406                	sd	ra,40(sp)
    800044ce:	f022                	sd	s0,32(sp)
    800044d0:	ec26                	sd	s1,24(sp)
    800044d2:	e052                	sd	s4,0(sp)
    800044d4:	1800                	addi	s0,sp,48
    800044d6:	84aa                	mv	s1,a0
    800044d8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044da:	0005b023          	sd	zero,0(a1)
    800044de:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044e2:	c29ff0ef          	jal	8000410a <filealloc>
    800044e6:	e088                	sd	a0,0(s1)
    800044e8:	c549                	beqz	a0,80004572 <pipealloc+0xa8>
    800044ea:	c21ff0ef          	jal	8000410a <filealloc>
    800044ee:	00aa3023          	sd	a0,0(s4)
    800044f2:	cd25                	beqz	a0,8000456a <pipealloc+0xa0>
    800044f4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800044f6:	e4efc0ef          	jal	80000b44 <kalloc>
    800044fa:	892a                	mv	s2,a0
    800044fc:	c12d                	beqz	a0,8000455e <pipealloc+0x94>
    800044fe:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004500:	4985                	li	s3,1
    80004502:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004506:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000450a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000450e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004512:	00003597          	auipc	a1,0x3
    80004516:	08e58593          	addi	a1,a1,142 # 800075a0 <etext+0x5a0>
    8000451a:	e84fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    8000451e:	609c                	ld	a5,0(s1)
    80004520:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004524:	609c                	ld	a5,0(s1)
    80004526:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000452a:	609c                	ld	a5,0(s1)
    8000452c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004530:	609c                	ld	a5,0(s1)
    80004532:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004536:	000a3783          	ld	a5,0(s4)
    8000453a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000453e:	000a3783          	ld	a5,0(s4)
    80004542:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004546:	000a3783          	ld	a5,0(s4)
    8000454a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000454e:	000a3783          	ld	a5,0(s4)
    80004552:	0127b823          	sd	s2,16(a5)
  return 0;
    80004556:	4501                	li	a0,0
    80004558:	6942                	ld	s2,16(sp)
    8000455a:	69a2                	ld	s3,8(sp)
    8000455c:	a01d                	j	80004582 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000455e:	6088                	ld	a0,0(s1)
    80004560:	c119                	beqz	a0,80004566 <pipealloc+0x9c>
    80004562:	6942                	ld	s2,16(sp)
    80004564:	a029                	j	8000456e <pipealloc+0xa4>
    80004566:	6942                	ld	s2,16(sp)
    80004568:	a029                	j	80004572 <pipealloc+0xa8>
    8000456a:	6088                	ld	a0,0(s1)
    8000456c:	c10d                	beqz	a0,8000458e <pipealloc+0xc4>
    fileclose(*f0);
    8000456e:	c41ff0ef          	jal	800041ae <fileclose>
  if(*f1)
    80004572:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004576:	557d                	li	a0,-1
  if(*f1)
    80004578:	c789                	beqz	a5,80004582 <pipealloc+0xb8>
    fileclose(*f1);
    8000457a:	853e                	mv	a0,a5
    8000457c:	c33ff0ef          	jal	800041ae <fileclose>
  return -1;
    80004580:	557d                	li	a0,-1
}
    80004582:	70a2                	ld	ra,40(sp)
    80004584:	7402                	ld	s0,32(sp)
    80004586:	64e2                	ld	s1,24(sp)
    80004588:	6a02                	ld	s4,0(sp)
    8000458a:	6145                	addi	sp,sp,48
    8000458c:	8082                	ret
  return -1;
    8000458e:	557d                	li	a0,-1
    80004590:	bfcd                	j	80004582 <pipealloc+0xb8>

0000000080004592 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004592:	1101                	addi	sp,sp,-32
    80004594:	ec06                	sd	ra,24(sp)
    80004596:	e822                	sd	s0,16(sp)
    80004598:	e426                	sd	s1,8(sp)
    8000459a:	e04a                	sd	s2,0(sp)
    8000459c:	1000                	addi	s0,sp,32
    8000459e:	84aa                	mv	s1,a0
    800045a0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800045a2:	e86fc0ef          	jal	80000c28 <acquire>
  if(writable){
    800045a6:	02090763          	beqz	s2,800045d4 <pipeclose+0x42>
    pi->writeopen = 0;
    800045aa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800045ae:	21848513          	addi	a0,s1,536
    800045b2:	a9dfd0ef          	jal	8000204e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800045b6:	2204a783          	lw	a5,544(s1)
    800045ba:	e781                	bnez	a5,800045c2 <pipeclose+0x30>
    800045bc:	2244a783          	lw	a5,548(s1)
    800045c0:	c38d                	beqz	a5,800045e2 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    800045c2:	8526                	mv	a0,s1
    800045c4:	ef8fc0ef          	jal	80000cbc <release>
}
    800045c8:	60e2                	ld	ra,24(sp)
    800045ca:	6442                	ld	s0,16(sp)
    800045cc:	64a2                	ld	s1,8(sp)
    800045ce:	6902                	ld	s2,0(sp)
    800045d0:	6105                	addi	sp,sp,32
    800045d2:	8082                	ret
    pi->readopen = 0;
    800045d4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045d8:	21c48513          	addi	a0,s1,540
    800045dc:	a73fd0ef          	jal	8000204e <wakeup>
    800045e0:	bfd9                	j	800045b6 <pipeclose+0x24>
    release(&pi->lock);
    800045e2:	8526                	mv	a0,s1
    800045e4:	ed8fc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    800045e8:	8526                	mv	a0,s1
    800045ea:	c72fc0ef          	jal	80000a5c <kfree>
    800045ee:	bfe9                	j	800045c8 <pipeclose+0x36>

00000000800045f0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045f0:	7159                	addi	sp,sp,-112
    800045f2:	f486                	sd	ra,104(sp)
    800045f4:	f0a2                	sd	s0,96(sp)
    800045f6:	eca6                	sd	s1,88(sp)
    800045f8:	e8ca                	sd	s2,80(sp)
    800045fa:	e4ce                	sd	s3,72(sp)
    800045fc:	e0d2                	sd	s4,64(sp)
    800045fe:	fc56                	sd	s5,56(sp)
    80004600:	1880                	addi	s0,sp,112
    80004602:	84aa                	mv	s1,a0
    80004604:	8aae                	mv	s5,a1
    80004606:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004608:	b2efd0ef          	jal	80001936 <myproc>
    8000460c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000460e:	8526                	mv	a0,s1
    80004610:	e18fc0ef          	jal	80000c28 <acquire>
  while(i < n){
    80004614:	0d405263          	blez	s4,800046d8 <pipewrite+0xe8>
    80004618:	f85a                	sd	s6,48(sp)
    8000461a:	f45e                	sd	s7,40(sp)
    8000461c:	f062                	sd	s8,32(sp)
    8000461e:	ec66                	sd	s9,24(sp)
    80004620:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004622:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004624:	f9f40c13          	addi	s8,s0,-97
    80004628:	4b85                	li	s7,1
    8000462a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000462c:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004630:	21c48c93          	addi	s9,s1,540
    80004634:	a82d                	j	8000466e <pipewrite+0x7e>
      release(&pi->lock);
    80004636:	8526                	mv	a0,s1
    80004638:	e84fc0ef          	jal	80000cbc <release>
      return -1;
    8000463c:	597d                	li	s2,-1
    8000463e:	7b42                	ld	s6,48(sp)
    80004640:	7ba2                	ld	s7,40(sp)
    80004642:	7c02                	ld	s8,32(sp)
    80004644:	6ce2                	ld	s9,24(sp)
    80004646:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004648:	854a                	mv	a0,s2
    8000464a:	70a6                	ld	ra,104(sp)
    8000464c:	7406                	ld	s0,96(sp)
    8000464e:	64e6                	ld	s1,88(sp)
    80004650:	6946                	ld	s2,80(sp)
    80004652:	69a6                	ld	s3,72(sp)
    80004654:	6a06                	ld	s4,64(sp)
    80004656:	7ae2                	ld	s5,56(sp)
    80004658:	6165                	addi	sp,sp,112
    8000465a:	8082                	ret
      wakeup(&pi->nread);
    8000465c:	856a                	mv	a0,s10
    8000465e:	9f1fd0ef          	jal	8000204e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004662:	85a6                	mv	a1,s1
    80004664:	8566                	mv	a0,s9
    80004666:	99dfd0ef          	jal	80002002 <sleep>
  while(i < n){
    8000466a:	05495a63          	bge	s2,s4,800046be <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000466e:	2204a783          	lw	a5,544(s1)
    80004672:	d3f1                	beqz	a5,80004636 <pipewrite+0x46>
    80004674:	854e                	mv	a0,s3
    80004676:	bc9fd0ef          	jal	8000223e <killed>
    8000467a:	fd55                	bnez	a0,80004636 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000467c:	2184a783          	lw	a5,536(s1)
    80004680:	21c4a703          	lw	a4,540(s1)
    80004684:	2007879b          	addiw	a5,a5,512
    80004688:	fcf70ae3          	beq	a4,a5,8000465c <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000468c:	86de                	mv	a3,s7
    8000468e:	01590633          	add	a2,s2,s5
    80004692:	85e2                	mv	a1,s8
    80004694:	0509b503          	ld	a0,80(s3)
    80004698:	87afd0ef          	jal	80001712 <copyin>
    8000469c:	05650063          	beq	a0,s6,800046dc <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800046a0:	21c4a783          	lw	a5,540(s1)
    800046a4:	0017871b          	addiw	a4,a5,1
    800046a8:	20e4ae23          	sw	a4,540(s1)
    800046ac:	1ff7f793          	andi	a5,a5,511
    800046b0:	97a6                	add	a5,a5,s1
    800046b2:	f9f44703          	lbu	a4,-97(s0)
    800046b6:	00e78c23          	sb	a4,24(a5)
      i++;
    800046ba:	2905                	addiw	s2,s2,1
    800046bc:	b77d                	j	8000466a <pipewrite+0x7a>
    800046be:	7b42                	ld	s6,48(sp)
    800046c0:	7ba2                	ld	s7,40(sp)
    800046c2:	7c02                	ld	s8,32(sp)
    800046c4:	6ce2                	ld	s9,24(sp)
    800046c6:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800046c8:	21848513          	addi	a0,s1,536
    800046cc:	983fd0ef          	jal	8000204e <wakeup>
  release(&pi->lock);
    800046d0:	8526                	mv	a0,s1
    800046d2:	deafc0ef          	jal	80000cbc <release>
  return i;
    800046d6:	bf8d                	j	80004648 <pipewrite+0x58>
  int i = 0;
    800046d8:	4901                	li	s2,0
    800046da:	b7fd                	j	800046c8 <pipewrite+0xd8>
    800046dc:	7b42                	ld	s6,48(sp)
    800046de:	7ba2                	ld	s7,40(sp)
    800046e0:	7c02                	ld	s8,32(sp)
    800046e2:	6ce2                	ld	s9,24(sp)
    800046e4:	6d42                	ld	s10,16(sp)
    800046e6:	b7cd                	j	800046c8 <pipewrite+0xd8>

00000000800046e8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046e8:	711d                	addi	sp,sp,-96
    800046ea:	ec86                	sd	ra,88(sp)
    800046ec:	e8a2                	sd	s0,80(sp)
    800046ee:	e4a6                	sd	s1,72(sp)
    800046f0:	e0ca                	sd	s2,64(sp)
    800046f2:	fc4e                	sd	s3,56(sp)
    800046f4:	f852                	sd	s4,48(sp)
    800046f6:	f456                	sd	s5,40(sp)
    800046f8:	1080                	addi	s0,sp,96
    800046fa:	84aa                	mv	s1,a0
    800046fc:	892e                	mv	s2,a1
    800046fe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004700:	a36fd0ef          	jal	80001936 <myproc>
    80004704:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004706:	8526                	mv	a0,s1
    80004708:	d20fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000470c:	2184a703          	lw	a4,536(s1)
    80004710:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004714:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004718:	02f71763          	bne	a4,a5,80004746 <piperead+0x5e>
    8000471c:	2244a783          	lw	a5,548(s1)
    80004720:	cf85                	beqz	a5,80004758 <piperead+0x70>
    if(killed(pr)){
    80004722:	8552                	mv	a0,s4
    80004724:	b1bfd0ef          	jal	8000223e <killed>
    80004728:	e11d                	bnez	a0,8000474e <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000472a:	85a6                	mv	a1,s1
    8000472c:	854e                	mv	a0,s3
    8000472e:	8d5fd0ef          	jal	80002002 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004732:	2184a703          	lw	a4,536(s1)
    80004736:	21c4a783          	lw	a5,540(s1)
    8000473a:	fef701e3          	beq	a4,a5,8000471c <piperead+0x34>
    8000473e:	f05a                	sd	s6,32(sp)
    80004740:	ec5e                	sd	s7,24(sp)
    80004742:	e862                	sd	s8,16(sp)
    80004744:	a829                	j	8000475e <piperead+0x76>
    80004746:	f05a                	sd	s6,32(sp)
    80004748:	ec5e                	sd	s7,24(sp)
    8000474a:	e862                	sd	s8,16(sp)
    8000474c:	a809                	j	8000475e <piperead+0x76>
      release(&pi->lock);
    8000474e:	8526                	mv	a0,s1
    80004750:	d6cfc0ef          	jal	80000cbc <release>
      return -1;
    80004754:	59fd                	li	s3,-1
    80004756:	a0a5                	j	800047be <piperead+0xd6>
    80004758:	f05a                	sd	s6,32(sp)
    8000475a:	ec5e                	sd	s7,24(sp)
    8000475c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000475e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004760:	faf40c13          	addi	s8,s0,-81
    80004764:	4b85                	li	s7,1
    80004766:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004768:	05505163          	blez	s5,800047aa <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000476c:	2184a783          	lw	a5,536(s1)
    80004770:	21c4a703          	lw	a4,540(s1)
    80004774:	02f70b63          	beq	a4,a5,800047aa <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004778:	1ff7f793          	andi	a5,a5,511
    8000477c:	97a6                	add	a5,a5,s1
    8000477e:	0187c783          	lbu	a5,24(a5)
    80004782:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004786:	86de                	mv	a3,s7
    80004788:	8662                	mv	a2,s8
    8000478a:	85ca                	mv	a1,s2
    8000478c:	050a3503          	ld	a0,80(s4)
    80004790:	ec5fc0ef          	jal	80001654 <copyout>
    80004794:	03650f63          	beq	a0,s6,800047d2 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004798:	2184a783          	lw	a5,536(s1)
    8000479c:	2785                	addiw	a5,a5,1
    8000479e:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047a2:	2985                	addiw	s3,s3,1
    800047a4:	0905                	addi	s2,s2,1
    800047a6:	fd3a93e3          	bne	s5,s3,8000476c <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800047aa:	21c48513          	addi	a0,s1,540
    800047ae:	8a1fd0ef          	jal	8000204e <wakeup>
  release(&pi->lock);
    800047b2:	8526                	mv	a0,s1
    800047b4:	d08fc0ef          	jal	80000cbc <release>
    800047b8:	7b02                	ld	s6,32(sp)
    800047ba:	6be2                	ld	s7,24(sp)
    800047bc:	6c42                	ld	s8,16(sp)
  return i;
}
    800047be:	854e                	mv	a0,s3
    800047c0:	60e6                	ld	ra,88(sp)
    800047c2:	6446                	ld	s0,80(sp)
    800047c4:	64a6                	ld	s1,72(sp)
    800047c6:	6906                	ld	s2,64(sp)
    800047c8:	79e2                	ld	s3,56(sp)
    800047ca:	7a42                	ld	s4,48(sp)
    800047cc:	7aa2                	ld	s5,40(sp)
    800047ce:	6125                	addi	sp,sp,96
    800047d0:	8082                	ret
      if(i == 0)
    800047d2:	fc099ce3          	bnez	s3,800047aa <piperead+0xc2>
        i = -1;
    800047d6:	89aa                	mv	s3,a0
    800047d8:	bfc9                	j	800047aa <piperead+0xc2>

00000000800047da <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800047da:	1141                	addi	sp,sp,-16
    800047dc:	e406                	sd	ra,8(sp)
    800047de:	e022                	sd	s0,0(sp)
    800047e0:	0800                	addi	s0,sp,16
    800047e2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800047e4:	0035151b          	slliw	a0,a0,0x3
    800047e8:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800047ea:	8b89                	andi	a5,a5,2
    800047ec:	c399                	beqz	a5,800047f2 <flags2perm+0x18>
      perm |= PTE_W;
    800047ee:	00456513          	ori	a0,a0,4
    return perm;
}
    800047f2:	60a2                	ld	ra,8(sp)
    800047f4:	6402                	ld	s0,0(sp)
    800047f6:	0141                	addi	sp,sp,16
    800047f8:	8082                	ret

00000000800047fa <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800047fa:	de010113          	addi	sp,sp,-544
    800047fe:	20113c23          	sd	ra,536(sp)
    80004802:	20813823          	sd	s0,528(sp)
    80004806:	20913423          	sd	s1,520(sp)
    8000480a:	21213023          	sd	s2,512(sp)
    8000480e:	1400                	addi	s0,sp,544
    80004810:	892a                	mv	s2,a0
    80004812:	dea43823          	sd	a0,-528(s0)
    80004816:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000481a:	91cfd0ef          	jal	80001936 <myproc>
    8000481e:	84aa                	mv	s1,a0

  begin_op();
    80004820:	d6aff0ef          	jal	80003d8a <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004824:	854a                	mv	a0,s2
    80004826:	b86ff0ef          	jal	80003bac <namei>
    8000482a:	cd21                	beqz	a0,80004882 <kexec+0x88>
    8000482c:	fbd2                	sd	s4,496(sp)
    8000482e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004830:	b4ffe0ef          	jal	8000337e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004834:	04000713          	li	a4,64
    80004838:	4681                	li	a3,0
    8000483a:	e5040613          	addi	a2,s0,-432
    8000483e:	4581                	li	a1,0
    80004840:	8552                	mv	a0,s4
    80004842:	ecffe0ef          	jal	80003710 <readi>
    80004846:	04000793          	li	a5,64
    8000484a:	00f51a63          	bne	a0,a5,8000485e <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000484e:	e5042703          	lw	a4,-432(s0)
    80004852:	464c47b7          	lui	a5,0x464c4
    80004856:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000485a:	02f70863          	beq	a4,a5,8000488a <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000485e:	8552                	mv	a0,s4
    80004860:	d2bfe0ef          	jal	8000358a <iunlockput>
    end_op();
    80004864:	d96ff0ef          	jal	80003dfa <end_op>
  }
  return -1;
    80004868:	557d                	li	a0,-1
    8000486a:	7a5e                	ld	s4,496(sp)
}
    8000486c:	21813083          	ld	ra,536(sp)
    80004870:	21013403          	ld	s0,528(sp)
    80004874:	20813483          	ld	s1,520(sp)
    80004878:	20013903          	ld	s2,512(sp)
    8000487c:	22010113          	addi	sp,sp,544
    80004880:	8082                	ret
    end_op();
    80004882:	d78ff0ef          	jal	80003dfa <end_op>
    return -1;
    80004886:	557d                	li	a0,-1
    80004888:	b7d5                	j	8000486c <kexec+0x72>
    8000488a:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000488c:	8526                	mv	a0,s1
    8000488e:	9b2fd0ef          	jal	80001a40 <proc_pagetable>
    80004892:	8b2a                	mv	s6,a0
    80004894:	26050f63          	beqz	a0,80004b12 <kexec+0x318>
    80004898:	ffce                	sd	s3,504(sp)
    8000489a:	f7d6                	sd	s5,488(sp)
    8000489c:	efde                	sd	s7,472(sp)
    8000489e:	ebe2                	sd	s8,464(sp)
    800048a0:	e7e6                	sd	s9,456(sp)
    800048a2:	e3ea                	sd	s10,448(sp)
    800048a4:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048a6:	e8845783          	lhu	a5,-376(s0)
    800048aa:	0e078963          	beqz	a5,8000499c <kexec+0x1a2>
    800048ae:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048b2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048b4:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800048b6:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800048ba:	6c85                	lui	s9,0x1
    800048bc:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048c0:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800048c4:	6a85                	lui	s5,0x1
    800048c6:	a085                	j	80004926 <kexec+0x12c>
      panic("loadseg: address should exist");
    800048c8:	00003517          	auipc	a0,0x3
    800048cc:	ce050513          	addi	a0,a0,-800 # 800075a8 <etext+0x5a8>
    800048d0:	f55fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    800048d4:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800048d6:	874a                	mv	a4,s2
    800048d8:	009b86bb          	addw	a3,s7,s1
    800048dc:	4581                	li	a1,0
    800048de:	8552                	mv	a0,s4
    800048e0:	e31fe0ef          	jal	80003710 <readi>
    800048e4:	22a91b63          	bne	s2,a0,80004b1a <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    800048e8:	009a84bb          	addw	s1,s5,s1
    800048ec:	0334f263          	bgeu	s1,s3,80004910 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800048f0:	02049593          	slli	a1,s1,0x20
    800048f4:	9181                	srli	a1,a1,0x20
    800048f6:	95e2                	add	a1,a1,s8
    800048f8:	855a                	mv	a0,s6
    800048fa:	f2cfc0ef          	jal	80001026 <walkaddr>
    800048fe:	862a                	mv	a2,a0
    if(pa == 0)
    80004900:	d561                	beqz	a0,800048c8 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004902:	409987bb          	subw	a5,s3,s1
    80004906:	893e                	mv	s2,a5
    80004908:	fcfcf6e3          	bgeu	s9,a5,800048d4 <kexec+0xda>
    8000490c:	8956                	mv	s2,s5
    8000490e:	b7d9                	j	800048d4 <kexec+0xda>
    sz = sz1;
    80004910:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004914:	2d05                	addiw	s10,s10,1
    80004916:	e0843783          	ld	a5,-504(s0)
    8000491a:	0387869b          	addiw	a3,a5,56
    8000491e:	e8845783          	lhu	a5,-376(s0)
    80004922:	06fd5e63          	bge	s10,a5,8000499e <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004926:	e0d43423          	sd	a3,-504(s0)
    8000492a:	876e                	mv	a4,s11
    8000492c:	e1840613          	addi	a2,s0,-488
    80004930:	4581                	li	a1,0
    80004932:	8552                	mv	a0,s4
    80004934:	dddfe0ef          	jal	80003710 <readi>
    80004938:	1db51f63          	bne	a0,s11,80004b16 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    8000493c:	e1842783          	lw	a5,-488(s0)
    80004940:	4705                	li	a4,1
    80004942:	fce799e3          	bne	a5,a4,80004914 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004946:	e4043483          	ld	s1,-448(s0)
    8000494a:	e3843783          	ld	a5,-456(s0)
    8000494e:	1ef4e463          	bltu	s1,a5,80004b36 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004952:	e2843783          	ld	a5,-472(s0)
    80004956:	94be                	add	s1,s1,a5
    80004958:	1ef4e263          	bltu	s1,a5,80004b3c <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    8000495c:	de843703          	ld	a4,-536(s0)
    80004960:	8ff9                	and	a5,a5,a4
    80004962:	1e079063          	bnez	a5,80004b42 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004966:	e1c42503          	lw	a0,-484(s0)
    8000496a:	e71ff0ef          	jal	800047da <flags2perm>
    8000496e:	86aa                	mv	a3,a0
    80004970:	8626                	mv	a2,s1
    80004972:	85ca                	mv	a1,s2
    80004974:	855a                	mv	a0,s6
    80004976:	987fc0ef          	jal	800012fc <uvmalloc>
    8000497a:	dea43c23          	sd	a0,-520(s0)
    8000497e:	1c050563          	beqz	a0,80004b48 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004982:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004986:	00098863          	beqz	s3,80004996 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000498a:	e2843c03          	ld	s8,-472(s0)
    8000498e:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004992:	4481                	li	s1,0
    80004994:	bfb1                	j	800048f0 <kexec+0xf6>
    sz = sz1;
    80004996:	df843903          	ld	s2,-520(s0)
    8000499a:	bfad                	j	80004914 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000499c:	4901                	li	s2,0
  iunlockput(ip);
    8000499e:	8552                	mv	a0,s4
    800049a0:	bebfe0ef          	jal	8000358a <iunlockput>
  end_op();
    800049a4:	c56ff0ef          	jal	80003dfa <end_op>
  p = myproc();
    800049a8:	f8ffc0ef          	jal	80001936 <myproc>
    800049ac:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800049ae:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800049b2:	6985                	lui	s3,0x1
    800049b4:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800049b6:	99ca                	add	s3,s3,s2
    800049b8:	77fd                	lui	a5,0xfffff
    800049ba:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800049be:	4691                	li	a3,4
    800049c0:	6609                	lui	a2,0x2
    800049c2:	964e                	add	a2,a2,s3
    800049c4:	85ce                	mv	a1,s3
    800049c6:	855a                	mv	a0,s6
    800049c8:	935fc0ef          	jal	800012fc <uvmalloc>
    800049cc:	8a2a                	mv	s4,a0
    800049ce:	e105                	bnez	a0,800049ee <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800049d0:	85ce                	mv	a1,s3
    800049d2:	855a                	mv	a0,s6
    800049d4:	8f0fd0ef          	jal	80001ac4 <proc_freepagetable>
  return -1;
    800049d8:	557d                	li	a0,-1
    800049da:	79fe                	ld	s3,504(sp)
    800049dc:	7a5e                	ld	s4,496(sp)
    800049de:	7abe                	ld	s5,488(sp)
    800049e0:	7b1e                	ld	s6,480(sp)
    800049e2:	6bfe                	ld	s7,472(sp)
    800049e4:	6c5e                	ld	s8,464(sp)
    800049e6:	6cbe                	ld	s9,456(sp)
    800049e8:	6d1e                	ld	s10,448(sp)
    800049ea:	7dfa                	ld	s11,440(sp)
    800049ec:	b541                	j	8000486c <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800049ee:	75f9                	lui	a1,0xffffe
    800049f0:	95aa                	add	a1,a1,a0
    800049f2:	855a                	mv	a0,s6
    800049f4:	adbfc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800049f8:	800a0b93          	addi	s7,s4,-2048
    800049fc:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004a00:	e0043783          	ld	a5,-512(s0)
    80004a04:	6388                	ld	a0,0(a5)
  sp = sz;
    80004a06:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004a08:	4481                	li	s1,0
    ustack[argc] = sp;
    80004a0a:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004a0e:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004a12:	cd21                	beqz	a0,80004a6a <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004a14:	c6efc0ef          	jal	80000e82 <strlen>
    80004a18:	0015079b          	addiw	a5,a0,1
    80004a1c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a20:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004a24:	13796563          	bltu	s2,s7,80004b4e <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a28:	e0043d83          	ld	s11,-512(s0)
    80004a2c:	000db983          	ld	s3,0(s11)
    80004a30:	854e                	mv	a0,s3
    80004a32:	c50fc0ef          	jal	80000e82 <strlen>
    80004a36:	0015069b          	addiw	a3,a0,1
    80004a3a:	864e                	mv	a2,s3
    80004a3c:	85ca                	mv	a1,s2
    80004a3e:	855a                	mv	a0,s6
    80004a40:	c15fc0ef          	jal	80001654 <copyout>
    80004a44:	10054763          	bltz	a0,80004b52 <kexec+0x358>
    ustack[argc] = sp;
    80004a48:	00349793          	slli	a5,s1,0x3
    80004a4c:	97e6                	add	a5,a5,s9
    80004a4e:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde040>
  for(argc = 0; argv[argc]; argc++) {
    80004a52:	0485                	addi	s1,s1,1
    80004a54:	008d8793          	addi	a5,s11,8
    80004a58:	e0f43023          	sd	a5,-512(s0)
    80004a5c:	008db503          	ld	a0,8(s11)
    80004a60:	c509                	beqz	a0,80004a6a <kexec+0x270>
    if(argc >= MAXARG)
    80004a62:	fb8499e3          	bne	s1,s8,80004a14 <kexec+0x21a>
  sz = sz1;
    80004a66:	89d2                	mv	s3,s4
    80004a68:	b7a5                	j	800049d0 <kexec+0x1d6>
  ustack[argc] = 0;
    80004a6a:	00349793          	slli	a5,s1,0x3
    80004a6e:	f9078793          	addi	a5,a5,-112
    80004a72:	97a2                	add	a5,a5,s0
    80004a74:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004a78:	00349693          	slli	a3,s1,0x3
    80004a7c:	06a1                	addi	a3,a3,8
    80004a7e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004a82:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004a86:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004a88:	f57964e3          	bltu	s2,s7,800049d0 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004a8c:	e9040613          	addi	a2,s0,-368
    80004a90:	85ca                	mv	a1,s2
    80004a92:	855a                	mv	a0,s6
    80004a94:	bc1fc0ef          	jal	80001654 <copyout>
    80004a98:	f2054ce3          	bltz	a0,800049d0 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004a9c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004aa0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004aa4:	df043783          	ld	a5,-528(s0)
    80004aa8:	0007c703          	lbu	a4,0(a5)
    80004aac:	cf11                	beqz	a4,80004ac8 <kexec+0x2ce>
    80004aae:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004ab0:	02f00693          	li	a3,47
    80004ab4:	a029                	j	80004abe <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004ab6:	0785                	addi	a5,a5,1
    80004ab8:	fff7c703          	lbu	a4,-1(a5)
    80004abc:	c711                	beqz	a4,80004ac8 <kexec+0x2ce>
    if(*s == '/')
    80004abe:	fed71ce3          	bne	a4,a3,80004ab6 <kexec+0x2bc>
      last = s+1;
    80004ac2:	def43823          	sd	a5,-528(s0)
    80004ac6:	bfc5                	j	80004ab6 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ac8:	4641                	li	a2,16
    80004aca:	df043583          	ld	a1,-528(s0)
    80004ace:	158a8513          	addi	a0,s5,344
    80004ad2:	b7afc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004ad6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004ada:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004ade:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004ae2:	058ab783          	ld	a5,88(s5)
    80004ae6:	e6843703          	ld	a4,-408(s0)
    80004aea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004aec:	058ab783          	ld	a5,88(s5)
    80004af0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004af4:	85ea                	mv	a1,s10
    80004af6:	fcffc0ef          	jal	80001ac4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004afa:	0004851b          	sext.w	a0,s1
    80004afe:	79fe                	ld	s3,504(sp)
    80004b00:	7a5e                	ld	s4,496(sp)
    80004b02:	7abe                	ld	s5,488(sp)
    80004b04:	7b1e                	ld	s6,480(sp)
    80004b06:	6bfe                	ld	s7,472(sp)
    80004b08:	6c5e                	ld	s8,464(sp)
    80004b0a:	6cbe                	ld	s9,456(sp)
    80004b0c:	6d1e                	ld	s10,448(sp)
    80004b0e:	7dfa                	ld	s11,440(sp)
    80004b10:	bbb1                	j	8000486c <kexec+0x72>
    80004b12:	7b1e                	ld	s6,480(sp)
    80004b14:	b3a9                	j	8000485e <kexec+0x64>
    80004b16:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004b1a:	df843583          	ld	a1,-520(s0)
    80004b1e:	855a                	mv	a0,s6
    80004b20:	fa5fc0ef          	jal	80001ac4 <proc_freepagetable>
  if(ip){
    80004b24:	79fe                	ld	s3,504(sp)
    80004b26:	7abe                	ld	s5,488(sp)
    80004b28:	7b1e                	ld	s6,480(sp)
    80004b2a:	6bfe                	ld	s7,472(sp)
    80004b2c:	6c5e                	ld	s8,464(sp)
    80004b2e:	6cbe                	ld	s9,456(sp)
    80004b30:	6d1e                	ld	s10,448(sp)
    80004b32:	7dfa                	ld	s11,440(sp)
    80004b34:	b32d                	j	8000485e <kexec+0x64>
    80004b36:	df243c23          	sd	s2,-520(s0)
    80004b3a:	b7c5                	j	80004b1a <kexec+0x320>
    80004b3c:	df243c23          	sd	s2,-520(s0)
    80004b40:	bfe9                	j	80004b1a <kexec+0x320>
    80004b42:	df243c23          	sd	s2,-520(s0)
    80004b46:	bfd1                	j	80004b1a <kexec+0x320>
    80004b48:	df243c23          	sd	s2,-520(s0)
    80004b4c:	b7f9                	j	80004b1a <kexec+0x320>
  sz = sz1;
    80004b4e:	89d2                	mv	s3,s4
    80004b50:	b541                	j	800049d0 <kexec+0x1d6>
    80004b52:	89d2                	mv	s3,s4
    80004b54:	bdb5                	j	800049d0 <kexec+0x1d6>

0000000080004b56 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b56:	7179                	addi	sp,sp,-48
    80004b58:	f406                	sd	ra,40(sp)
    80004b5a:	f022                	sd	s0,32(sp)
    80004b5c:	ec26                	sd	s1,24(sp)
    80004b5e:	e84a                	sd	s2,16(sp)
    80004b60:	1800                	addi	s0,sp,48
    80004b62:	892e                	mv	s2,a1
    80004b64:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b66:	fdc40593          	addi	a1,s0,-36
    80004b6a:	dd7fd0ef          	jal	80002940 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004b6e:	fdc42703          	lw	a4,-36(s0)
    80004b72:	47bd                	li	a5,15
    80004b74:	02e7ea63          	bltu	a5,a4,80004ba8 <argfd+0x52>
    80004b78:	dbffc0ef          	jal	80001936 <myproc>
    80004b7c:	fdc42703          	lw	a4,-36(s0)
    80004b80:	00371793          	slli	a5,a4,0x3
    80004b84:	0d078793          	addi	a5,a5,208
    80004b88:	953e                	add	a0,a0,a5
    80004b8a:	611c                	ld	a5,0(a0)
    80004b8c:	c385                	beqz	a5,80004bac <argfd+0x56>
    return -1;
  if(pfd)
    80004b8e:	00090463          	beqz	s2,80004b96 <argfd+0x40>
    *pfd = fd;
    80004b92:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004b96:	4501                	li	a0,0
  if(pf)
    80004b98:	c091                	beqz	s1,80004b9c <argfd+0x46>
    *pf = f;
    80004b9a:	e09c                	sd	a5,0(s1)
}
    80004b9c:	70a2                	ld	ra,40(sp)
    80004b9e:	7402                	ld	s0,32(sp)
    80004ba0:	64e2                	ld	s1,24(sp)
    80004ba2:	6942                	ld	s2,16(sp)
    80004ba4:	6145                	addi	sp,sp,48
    80004ba6:	8082                	ret
    return -1;
    80004ba8:	557d                	li	a0,-1
    80004baa:	bfcd                	j	80004b9c <argfd+0x46>
    80004bac:	557d                	li	a0,-1
    80004bae:	b7fd                	j	80004b9c <argfd+0x46>

0000000080004bb0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004bb0:	1101                	addi	sp,sp,-32
    80004bb2:	ec06                	sd	ra,24(sp)
    80004bb4:	e822                	sd	s0,16(sp)
    80004bb6:	e426                	sd	s1,8(sp)
    80004bb8:	1000                	addi	s0,sp,32
    80004bba:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004bbc:	d7bfc0ef          	jal	80001936 <myproc>
    80004bc0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004bc2:	0d050793          	addi	a5,a0,208
    80004bc6:	4501                	li	a0,0
    80004bc8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004bca:	6398                	ld	a4,0(a5)
    80004bcc:	cb19                	beqz	a4,80004be2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004bce:	2505                	addiw	a0,a0,1
    80004bd0:	07a1                	addi	a5,a5,8
    80004bd2:	fed51ce3          	bne	a0,a3,80004bca <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004bd6:	557d                	li	a0,-1
}
    80004bd8:	60e2                	ld	ra,24(sp)
    80004bda:	6442                	ld	s0,16(sp)
    80004bdc:	64a2                	ld	s1,8(sp)
    80004bde:	6105                	addi	sp,sp,32
    80004be0:	8082                	ret
      p->ofile[fd] = f;
    80004be2:	00351793          	slli	a5,a0,0x3
    80004be6:	0d078793          	addi	a5,a5,208
    80004bea:	963e                	add	a2,a2,a5
    80004bec:	e204                	sd	s1,0(a2)
      return fd;
    80004bee:	b7ed                	j	80004bd8 <fdalloc+0x28>

0000000080004bf0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004bf0:	715d                	addi	sp,sp,-80
    80004bf2:	e486                	sd	ra,72(sp)
    80004bf4:	e0a2                	sd	s0,64(sp)
    80004bf6:	fc26                	sd	s1,56(sp)
    80004bf8:	f84a                	sd	s2,48(sp)
    80004bfa:	f44e                	sd	s3,40(sp)
    80004bfc:	f052                	sd	s4,32(sp)
    80004bfe:	ec56                	sd	s5,24(sp)
    80004c00:	e85a                	sd	s6,16(sp)
    80004c02:	0880                	addi	s0,sp,80
    80004c04:	892e                	mv	s2,a1
    80004c06:	8a2e                	mv	s4,a1
    80004c08:	8ab2                	mv	s5,a2
    80004c0a:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004c0c:	fb040593          	addi	a1,s0,-80
    80004c10:	fb7fe0ef          	jal	80003bc6 <nameiparent>
    80004c14:	84aa                	mv	s1,a0
    80004c16:	10050763          	beqz	a0,80004d24 <create+0x134>
    return 0;

  ilock(dp);
    80004c1a:	f64fe0ef          	jal	8000337e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004c1e:	4601                	li	a2,0
    80004c20:	fb040593          	addi	a1,s0,-80
    80004c24:	8526                	mv	a0,s1
    80004c26:	cf3fe0ef          	jal	80003918 <dirlookup>
    80004c2a:	89aa                	mv	s3,a0
    80004c2c:	c131                	beqz	a0,80004c70 <create+0x80>
    iunlockput(dp);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	95bfe0ef          	jal	8000358a <iunlockput>
    ilock(ip);
    80004c34:	854e                	mv	a0,s3
    80004c36:	f48fe0ef          	jal	8000337e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c3a:	4789                	li	a5,2
    80004c3c:	02f91563          	bne	s2,a5,80004c66 <create+0x76>
    80004c40:	0449d783          	lhu	a5,68(s3)
    80004c44:	37f9                	addiw	a5,a5,-2
    80004c46:	17c2                	slli	a5,a5,0x30
    80004c48:	93c1                	srli	a5,a5,0x30
    80004c4a:	4705                	li	a4,1
    80004c4c:	00f76d63          	bltu	a4,a5,80004c66 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004c50:	854e                	mv	a0,s3
    80004c52:	60a6                	ld	ra,72(sp)
    80004c54:	6406                	ld	s0,64(sp)
    80004c56:	74e2                	ld	s1,56(sp)
    80004c58:	7942                	ld	s2,48(sp)
    80004c5a:	79a2                	ld	s3,40(sp)
    80004c5c:	7a02                	ld	s4,32(sp)
    80004c5e:	6ae2                	ld	s5,24(sp)
    80004c60:	6b42                	ld	s6,16(sp)
    80004c62:	6161                	addi	sp,sp,80
    80004c64:	8082                	ret
    iunlockput(ip);
    80004c66:	854e                	mv	a0,s3
    80004c68:	923fe0ef          	jal	8000358a <iunlockput>
    return 0;
    80004c6c:	4981                	li	s3,0
    80004c6e:	b7cd                	j	80004c50 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004c70:	85ca                	mv	a1,s2
    80004c72:	4088                	lw	a0,0(s1)
    80004c74:	d9afe0ef          	jal	8000320e <ialloc>
    80004c78:	892a                	mv	s2,a0
    80004c7a:	cd15                	beqz	a0,80004cb6 <create+0xc6>
  ilock(ip);
    80004c7c:	f02fe0ef          	jal	8000337e <ilock>
  ip->major = major;
    80004c80:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004c84:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004c88:	4785                	li	a5,1
    80004c8a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004c8e:	854a                	mv	a0,s2
    80004c90:	e3afe0ef          	jal	800032ca <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004c94:	4705                	li	a4,1
    80004c96:	02ea0463          	beq	s4,a4,80004cbe <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c9a:	00492603          	lw	a2,4(s2)
    80004c9e:	fb040593          	addi	a1,s0,-80
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	e5ffe0ef          	jal	80003b02 <dirlink>
    80004ca8:	06054263          	bltz	a0,80004d0c <create+0x11c>
  iunlockput(dp);
    80004cac:	8526                	mv	a0,s1
    80004cae:	8ddfe0ef          	jal	8000358a <iunlockput>
  return ip;
    80004cb2:	89ca                	mv	s3,s2
    80004cb4:	bf71                	j	80004c50 <create+0x60>
    iunlockput(dp);
    80004cb6:	8526                	mv	a0,s1
    80004cb8:	8d3fe0ef          	jal	8000358a <iunlockput>
    return 0;
    80004cbc:	bf51                	j	80004c50 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004cbe:	00492603          	lw	a2,4(s2)
    80004cc2:	00003597          	auipc	a1,0x3
    80004cc6:	90658593          	addi	a1,a1,-1786 # 800075c8 <etext+0x5c8>
    80004cca:	854a                	mv	a0,s2
    80004ccc:	e37fe0ef          	jal	80003b02 <dirlink>
    80004cd0:	02054e63          	bltz	a0,80004d0c <create+0x11c>
    80004cd4:	40d0                	lw	a2,4(s1)
    80004cd6:	00003597          	auipc	a1,0x3
    80004cda:	8fa58593          	addi	a1,a1,-1798 # 800075d0 <etext+0x5d0>
    80004cde:	854a                	mv	a0,s2
    80004ce0:	e23fe0ef          	jal	80003b02 <dirlink>
    80004ce4:	02054463          	bltz	a0,80004d0c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ce8:	00492603          	lw	a2,4(s2)
    80004cec:	fb040593          	addi	a1,s0,-80
    80004cf0:	8526                	mv	a0,s1
    80004cf2:	e11fe0ef          	jal	80003b02 <dirlink>
    80004cf6:	00054b63          	bltz	a0,80004d0c <create+0x11c>
    dp->nlink++;  // for ".."
    80004cfa:	04a4d783          	lhu	a5,74(s1)
    80004cfe:	2785                	addiw	a5,a5,1
    80004d00:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d04:	8526                	mv	a0,s1
    80004d06:	dc4fe0ef          	jal	800032ca <iupdate>
    80004d0a:	b74d                	j	80004cac <create+0xbc>
  ip->nlink = 0;
    80004d0c:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004d10:	854a                	mv	a0,s2
    80004d12:	db8fe0ef          	jal	800032ca <iupdate>
  iunlockput(ip);
    80004d16:	854a                	mv	a0,s2
    80004d18:	873fe0ef          	jal	8000358a <iunlockput>
  iunlockput(dp);
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	86dfe0ef          	jal	8000358a <iunlockput>
  return 0;
    80004d22:	b73d                	j	80004c50 <create+0x60>
    return 0;
    80004d24:	89aa                	mv	s3,a0
    80004d26:	b72d                	j	80004c50 <create+0x60>

0000000080004d28 <sys_dup>:
{
    80004d28:	7179                	addi	sp,sp,-48
    80004d2a:	f406                	sd	ra,40(sp)
    80004d2c:	f022                	sd	s0,32(sp)
    80004d2e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004d30:	fd840613          	addi	a2,s0,-40
    80004d34:	4581                	li	a1,0
    80004d36:	4501                	li	a0,0
    80004d38:	e1fff0ef          	jal	80004b56 <argfd>
    return -1;
    80004d3c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004d3e:	02054363          	bltz	a0,80004d64 <sys_dup+0x3c>
    80004d42:	ec26                	sd	s1,24(sp)
    80004d44:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004d46:	fd843483          	ld	s1,-40(s0)
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	e65ff0ef          	jal	80004bb0 <fdalloc>
    80004d50:	892a                	mv	s2,a0
    return -1;
    80004d52:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004d54:	00054d63          	bltz	a0,80004d6e <sys_dup+0x46>
  filedup(f);
    80004d58:	8526                	mv	a0,s1
    80004d5a:	c0eff0ef          	jal	80004168 <filedup>
  return fd;
    80004d5e:	87ca                	mv	a5,s2
    80004d60:	64e2                	ld	s1,24(sp)
    80004d62:	6942                	ld	s2,16(sp)
}
    80004d64:	853e                	mv	a0,a5
    80004d66:	70a2                	ld	ra,40(sp)
    80004d68:	7402                	ld	s0,32(sp)
    80004d6a:	6145                	addi	sp,sp,48
    80004d6c:	8082                	ret
    80004d6e:	64e2                	ld	s1,24(sp)
    80004d70:	6942                	ld	s2,16(sp)
    80004d72:	bfcd                	j	80004d64 <sys_dup+0x3c>

0000000080004d74 <sys_read>:
{
    80004d74:	7179                	addi	sp,sp,-48
    80004d76:	f406                	sd	ra,40(sp)
    80004d78:	f022                	sd	s0,32(sp)
    80004d7a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d7c:	fd840593          	addi	a1,s0,-40
    80004d80:	4505                	li	a0,1
    80004d82:	bdbfd0ef          	jal	8000295c <argaddr>
  argint(2, &n);
    80004d86:	fe440593          	addi	a1,s0,-28
    80004d8a:	4509                	li	a0,2
    80004d8c:	bb5fd0ef          	jal	80002940 <argint>
  if(argfd(0, 0, &f) < 0)
    80004d90:	fe840613          	addi	a2,s0,-24
    80004d94:	4581                	li	a1,0
    80004d96:	4501                	li	a0,0
    80004d98:	dbfff0ef          	jal	80004b56 <argfd>
    80004d9c:	87aa                	mv	a5,a0
    return -1;
    80004d9e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004da0:	0007ca63          	bltz	a5,80004db4 <sys_read+0x40>
  return fileread(f, p, n);
    80004da4:	fe442603          	lw	a2,-28(s0)
    80004da8:	fd843583          	ld	a1,-40(s0)
    80004dac:	fe843503          	ld	a0,-24(s0)
    80004db0:	d22ff0ef          	jal	800042d2 <fileread>
}
    80004db4:	70a2                	ld	ra,40(sp)
    80004db6:	7402                	ld	s0,32(sp)
    80004db8:	6145                	addi	sp,sp,48
    80004dba:	8082                	ret

0000000080004dbc <sys_write>:
{
    80004dbc:	7179                	addi	sp,sp,-48
    80004dbe:	f406                	sd	ra,40(sp)
    80004dc0:	f022                	sd	s0,32(sp)
    80004dc2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004dc4:	fd840593          	addi	a1,s0,-40
    80004dc8:	4505                	li	a0,1
    80004dca:	b93fd0ef          	jal	8000295c <argaddr>
  argint(2, &n);
    80004dce:	fe440593          	addi	a1,s0,-28
    80004dd2:	4509                	li	a0,2
    80004dd4:	b6dfd0ef          	jal	80002940 <argint>
  if(argfd(0, 0, &f) < 0)
    80004dd8:	fe840613          	addi	a2,s0,-24
    80004ddc:	4581                	li	a1,0
    80004dde:	4501                	li	a0,0
    80004de0:	d77ff0ef          	jal	80004b56 <argfd>
    80004de4:	87aa                	mv	a5,a0
    return -1;
    80004de6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004de8:	0007ca63          	bltz	a5,80004dfc <sys_write+0x40>
  return filewrite(f, p, n);
    80004dec:	fe442603          	lw	a2,-28(s0)
    80004df0:	fd843583          	ld	a1,-40(s0)
    80004df4:	fe843503          	ld	a0,-24(s0)
    80004df8:	d9eff0ef          	jal	80004396 <filewrite>
}
    80004dfc:	70a2                	ld	ra,40(sp)
    80004dfe:	7402                	ld	s0,32(sp)
    80004e00:	6145                	addi	sp,sp,48
    80004e02:	8082                	ret

0000000080004e04 <sys_close>:
{
    80004e04:	1101                	addi	sp,sp,-32
    80004e06:	ec06                	sd	ra,24(sp)
    80004e08:	e822                	sd	s0,16(sp)
    80004e0a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004e0c:	fe040613          	addi	a2,s0,-32
    80004e10:	fec40593          	addi	a1,s0,-20
    80004e14:	4501                	li	a0,0
    80004e16:	d41ff0ef          	jal	80004b56 <argfd>
    return -1;
    80004e1a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004e1c:	02054163          	bltz	a0,80004e3e <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004e20:	b17fc0ef          	jal	80001936 <myproc>
    80004e24:	fec42783          	lw	a5,-20(s0)
    80004e28:	078e                	slli	a5,a5,0x3
    80004e2a:	0d078793          	addi	a5,a5,208
    80004e2e:	953e                	add	a0,a0,a5
    80004e30:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e34:	fe043503          	ld	a0,-32(s0)
    80004e38:	b76ff0ef          	jal	800041ae <fileclose>
  return 0;
    80004e3c:	4781                	li	a5,0
}
    80004e3e:	853e                	mv	a0,a5
    80004e40:	60e2                	ld	ra,24(sp)
    80004e42:	6442                	ld	s0,16(sp)
    80004e44:	6105                	addi	sp,sp,32
    80004e46:	8082                	ret

0000000080004e48 <sys_fstat>:
{
    80004e48:	1101                	addi	sp,sp,-32
    80004e4a:	ec06                	sd	ra,24(sp)
    80004e4c:	e822                	sd	s0,16(sp)
    80004e4e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e50:	fe040593          	addi	a1,s0,-32
    80004e54:	4505                	li	a0,1
    80004e56:	b07fd0ef          	jal	8000295c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004e5a:	fe840613          	addi	a2,s0,-24
    80004e5e:	4581                	li	a1,0
    80004e60:	4501                	li	a0,0
    80004e62:	cf5ff0ef          	jal	80004b56 <argfd>
    80004e66:	87aa                	mv	a5,a0
    return -1;
    80004e68:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e6a:	0007c863          	bltz	a5,80004e7a <sys_fstat+0x32>
  return filestat(f, st);
    80004e6e:	fe043583          	ld	a1,-32(s0)
    80004e72:	fe843503          	ld	a0,-24(s0)
    80004e76:	bfaff0ef          	jal	80004270 <filestat>
}
    80004e7a:	60e2                	ld	ra,24(sp)
    80004e7c:	6442                	ld	s0,16(sp)
    80004e7e:	6105                	addi	sp,sp,32
    80004e80:	8082                	ret

0000000080004e82 <sys_link>:
{
    80004e82:	7169                	addi	sp,sp,-304
    80004e84:	f606                	sd	ra,296(sp)
    80004e86:	f222                	sd	s0,288(sp)
    80004e88:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e8a:	08000613          	li	a2,128
    80004e8e:	ed040593          	addi	a1,s0,-304
    80004e92:	4501                	li	a0,0
    80004e94:	ae5fd0ef          	jal	80002978 <argstr>
    return -1;
    80004e98:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e9a:	0c054e63          	bltz	a0,80004f76 <sys_link+0xf4>
    80004e9e:	08000613          	li	a2,128
    80004ea2:	f5040593          	addi	a1,s0,-176
    80004ea6:	4505                	li	a0,1
    80004ea8:	ad1fd0ef          	jal	80002978 <argstr>
    return -1;
    80004eac:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004eae:	0c054463          	bltz	a0,80004f76 <sys_link+0xf4>
    80004eb2:	ee26                	sd	s1,280(sp)
  begin_op();
    80004eb4:	ed7fe0ef          	jal	80003d8a <begin_op>
  if((ip = namei(old)) == 0){
    80004eb8:	ed040513          	addi	a0,s0,-304
    80004ebc:	cf1fe0ef          	jal	80003bac <namei>
    80004ec0:	84aa                	mv	s1,a0
    80004ec2:	c53d                	beqz	a0,80004f30 <sys_link+0xae>
  ilock(ip);
    80004ec4:	cbafe0ef          	jal	8000337e <ilock>
  if(ip->type == T_DIR){
    80004ec8:	04449703          	lh	a4,68(s1)
    80004ecc:	4785                	li	a5,1
    80004ece:	06f70663          	beq	a4,a5,80004f3a <sys_link+0xb8>
    80004ed2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ed4:	04a4d783          	lhu	a5,74(s1)
    80004ed8:	2785                	addiw	a5,a5,1
    80004eda:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ede:	8526                	mv	a0,s1
    80004ee0:	beafe0ef          	jal	800032ca <iupdate>
  iunlock(ip);
    80004ee4:	8526                	mv	a0,s1
    80004ee6:	d46fe0ef          	jal	8000342c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004eea:	fd040593          	addi	a1,s0,-48
    80004eee:	f5040513          	addi	a0,s0,-176
    80004ef2:	cd5fe0ef          	jal	80003bc6 <nameiparent>
    80004ef6:	892a                	mv	s2,a0
    80004ef8:	cd21                	beqz	a0,80004f50 <sys_link+0xce>
  ilock(dp);
    80004efa:	c84fe0ef          	jal	8000337e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004efe:	854a                	mv	a0,s2
    80004f00:	00092703          	lw	a4,0(s2)
    80004f04:	409c                	lw	a5,0(s1)
    80004f06:	04f71263          	bne	a4,a5,80004f4a <sys_link+0xc8>
    80004f0a:	40d0                	lw	a2,4(s1)
    80004f0c:	fd040593          	addi	a1,s0,-48
    80004f10:	bf3fe0ef          	jal	80003b02 <dirlink>
    80004f14:	02054b63          	bltz	a0,80004f4a <sys_link+0xc8>
  iunlockput(dp);
    80004f18:	854a                	mv	a0,s2
    80004f1a:	e70fe0ef          	jal	8000358a <iunlockput>
  iput(ip);
    80004f1e:	8526                	mv	a0,s1
    80004f20:	de0fe0ef          	jal	80003500 <iput>
  end_op();
    80004f24:	ed7fe0ef          	jal	80003dfa <end_op>
  return 0;
    80004f28:	4781                	li	a5,0
    80004f2a:	64f2                	ld	s1,280(sp)
    80004f2c:	6952                	ld	s2,272(sp)
    80004f2e:	a0a1                	j	80004f76 <sys_link+0xf4>
    end_op();
    80004f30:	ecbfe0ef          	jal	80003dfa <end_op>
    return -1;
    80004f34:	57fd                	li	a5,-1
    80004f36:	64f2                	ld	s1,280(sp)
    80004f38:	a83d                	j	80004f76 <sys_link+0xf4>
    iunlockput(ip);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	e4efe0ef          	jal	8000358a <iunlockput>
    end_op();
    80004f40:	ebbfe0ef          	jal	80003dfa <end_op>
    return -1;
    80004f44:	57fd                	li	a5,-1
    80004f46:	64f2                	ld	s1,280(sp)
    80004f48:	a03d                	j	80004f76 <sys_link+0xf4>
    iunlockput(dp);
    80004f4a:	854a                	mv	a0,s2
    80004f4c:	e3efe0ef          	jal	8000358a <iunlockput>
  ilock(ip);
    80004f50:	8526                	mv	a0,s1
    80004f52:	c2cfe0ef          	jal	8000337e <ilock>
  ip->nlink--;
    80004f56:	04a4d783          	lhu	a5,74(s1)
    80004f5a:	37fd                	addiw	a5,a5,-1
    80004f5c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f60:	8526                	mv	a0,s1
    80004f62:	b68fe0ef          	jal	800032ca <iupdate>
  iunlockput(ip);
    80004f66:	8526                	mv	a0,s1
    80004f68:	e22fe0ef          	jal	8000358a <iunlockput>
  end_op();
    80004f6c:	e8ffe0ef          	jal	80003dfa <end_op>
  return -1;
    80004f70:	57fd                	li	a5,-1
    80004f72:	64f2                	ld	s1,280(sp)
    80004f74:	6952                	ld	s2,272(sp)
}
    80004f76:	853e                	mv	a0,a5
    80004f78:	70b2                	ld	ra,296(sp)
    80004f7a:	7412                	ld	s0,288(sp)
    80004f7c:	6155                	addi	sp,sp,304
    80004f7e:	8082                	ret

0000000080004f80 <sys_unlink>:
{
    80004f80:	7151                	addi	sp,sp,-240
    80004f82:	f586                	sd	ra,232(sp)
    80004f84:	f1a2                	sd	s0,224(sp)
    80004f86:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004f88:	08000613          	li	a2,128
    80004f8c:	f3040593          	addi	a1,s0,-208
    80004f90:	4501                	li	a0,0
    80004f92:	9e7fd0ef          	jal	80002978 <argstr>
    80004f96:	14054d63          	bltz	a0,800050f0 <sys_unlink+0x170>
    80004f9a:	eda6                	sd	s1,216(sp)
  begin_op();
    80004f9c:	deffe0ef          	jal	80003d8a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004fa0:	fb040593          	addi	a1,s0,-80
    80004fa4:	f3040513          	addi	a0,s0,-208
    80004fa8:	c1ffe0ef          	jal	80003bc6 <nameiparent>
    80004fac:	84aa                	mv	s1,a0
    80004fae:	c955                	beqz	a0,80005062 <sys_unlink+0xe2>
  ilock(dp);
    80004fb0:	bcefe0ef          	jal	8000337e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004fb4:	00002597          	auipc	a1,0x2
    80004fb8:	61458593          	addi	a1,a1,1556 # 800075c8 <etext+0x5c8>
    80004fbc:	fb040513          	addi	a0,s0,-80
    80004fc0:	943fe0ef          	jal	80003902 <namecmp>
    80004fc4:	10050b63          	beqz	a0,800050da <sys_unlink+0x15a>
    80004fc8:	00002597          	auipc	a1,0x2
    80004fcc:	60858593          	addi	a1,a1,1544 # 800075d0 <etext+0x5d0>
    80004fd0:	fb040513          	addi	a0,s0,-80
    80004fd4:	92ffe0ef          	jal	80003902 <namecmp>
    80004fd8:	10050163          	beqz	a0,800050da <sys_unlink+0x15a>
    80004fdc:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004fde:	f2c40613          	addi	a2,s0,-212
    80004fe2:	fb040593          	addi	a1,s0,-80
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	931fe0ef          	jal	80003918 <dirlookup>
    80004fec:	892a                	mv	s2,a0
    80004fee:	0e050563          	beqz	a0,800050d8 <sys_unlink+0x158>
    80004ff2:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004ff4:	b8afe0ef          	jal	8000337e <ilock>
  if(ip->nlink < 1)
    80004ff8:	04a91783          	lh	a5,74(s2)
    80004ffc:	06f05863          	blez	a5,8000506c <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005000:	04491703          	lh	a4,68(s2)
    80005004:	4785                	li	a5,1
    80005006:	06f70963          	beq	a4,a5,80005078 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    8000500a:	fc040993          	addi	s3,s0,-64
    8000500e:	4641                	li	a2,16
    80005010:	4581                	li	a1,0
    80005012:	854e                	mv	a0,s3
    80005014:	ce5fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005018:	4741                	li	a4,16
    8000501a:	f2c42683          	lw	a3,-212(s0)
    8000501e:	864e                	mv	a2,s3
    80005020:	4581                	li	a1,0
    80005022:	8526                	mv	a0,s1
    80005024:	fdefe0ef          	jal	80003802 <writei>
    80005028:	47c1                	li	a5,16
    8000502a:	08f51863          	bne	a0,a5,800050ba <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    8000502e:	04491703          	lh	a4,68(s2)
    80005032:	4785                	li	a5,1
    80005034:	08f70963          	beq	a4,a5,800050c6 <sys_unlink+0x146>
  iunlockput(dp);
    80005038:	8526                	mv	a0,s1
    8000503a:	d50fe0ef          	jal	8000358a <iunlockput>
  ip->nlink--;
    8000503e:	04a95783          	lhu	a5,74(s2)
    80005042:	37fd                	addiw	a5,a5,-1
    80005044:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005048:	854a                	mv	a0,s2
    8000504a:	a80fe0ef          	jal	800032ca <iupdate>
  iunlockput(ip);
    8000504e:	854a                	mv	a0,s2
    80005050:	d3afe0ef          	jal	8000358a <iunlockput>
  end_op();
    80005054:	da7fe0ef          	jal	80003dfa <end_op>
  return 0;
    80005058:	4501                	li	a0,0
    8000505a:	64ee                	ld	s1,216(sp)
    8000505c:	694e                	ld	s2,208(sp)
    8000505e:	69ae                	ld	s3,200(sp)
    80005060:	a061                	j	800050e8 <sys_unlink+0x168>
    end_op();
    80005062:	d99fe0ef          	jal	80003dfa <end_op>
    return -1;
    80005066:	557d                	li	a0,-1
    80005068:	64ee                	ld	s1,216(sp)
    8000506a:	a8bd                	j	800050e8 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000506c:	00002517          	auipc	a0,0x2
    80005070:	56c50513          	addi	a0,a0,1388 # 800075d8 <etext+0x5d8>
    80005074:	fb0fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005078:	04c92703          	lw	a4,76(s2)
    8000507c:	02000793          	li	a5,32
    80005080:	f8e7f5e3          	bgeu	a5,a4,8000500a <sys_unlink+0x8a>
    80005084:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005086:	4741                	li	a4,16
    80005088:	86ce                	mv	a3,s3
    8000508a:	f1840613          	addi	a2,s0,-232
    8000508e:	4581                	li	a1,0
    80005090:	854a                	mv	a0,s2
    80005092:	e7efe0ef          	jal	80003710 <readi>
    80005096:	47c1                	li	a5,16
    80005098:	00f51b63          	bne	a0,a5,800050ae <sys_unlink+0x12e>
    if(de.inum != 0)
    8000509c:	f1845783          	lhu	a5,-232(s0)
    800050a0:	ebb1                	bnez	a5,800050f4 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800050a2:	29c1                	addiw	s3,s3,16
    800050a4:	04c92783          	lw	a5,76(s2)
    800050a8:	fcf9efe3          	bltu	s3,a5,80005086 <sys_unlink+0x106>
    800050ac:	bfb9                	j	8000500a <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800050ae:	00002517          	auipc	a0,0x2
    800050b2:	54250513          	addi	a0,a0,1346 # 800075f0 <etext+0x5f0>
    800050b6:	f6efb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    800050ba:	00002517          	auipc	a0,0x2
    800050be:	54e50513          	addi	a0,a0,1358 # 80007608 <etext+0x608>
    800050c2:	f62fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    800050c6:	04a4d783          	lhu	a5,74(s1)
    800050ca:	37fd                	addiw	a5,a5,-1
    800050cc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050d0:	8526                	mv	a0,s1
    800050d2:	9f8fe0ef          	jal	800032ca <iupdate>
    800050d6:	b78d                	j	80005038 <sys_unlink+0xb8>
    800050d8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800050da:	8526                	mv	a0,s1
    800050dc:	caefe0ef          	jal	8000358a <iunlockput>
  end_op();
    800050e0:	d1bfe0ef          	jal	80003dfa <end_op>
  return -1;
    800050e4:	557d                	li	a0,-1
    800050e6:	64ee                	ld	s1,216(sp)
}
    800050e8:	70ae                	ld	ra,232(sp)
    800050ea:	740e                	ld	s0,224(sp)
    800050ec:	616d                	addi	sp,sp,240
    800050ee:	8082                	ret
    return -1;
    800050f0:	557d                	li	a0,-1
    800050f2:	bfdd                	j	800050e8 <sys_unlink+0x168>
    iunlockput(ip);
    800050f4:	854a                	mv	a0,s2
    800050f6:	c94fe0ef          	jal	8000358a <iunlockput>
    goto bad;
    800050fa:	694e                	ld	s2,208(sp)
    800050fc:	69ae                	ld	s3,200(sp)
    800050fe:	bff1                	j	800050da <sys_unlink+0x15a>

0000000080005100 <sys_open>:

uint64
sys_open(void)
{
    80005100:	7131                	addi	sp,sp,-192
    80005102:	fd06                	sd	ra,184(sp)
    80005104:	f922                	sd	s0,176(sp)
    80005106:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005108:	f4c40593          	addi	a1,s0,-180
    8000510c:	4505                	li	a0,1
    8000510e:	833fd0ef          	jal	80002940 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005112:	08000613          	li	a2,128
    80005116:	f5040593          	addi	a1,s0,-176
    8000511a:	4501                	li	a0,0
    8000511c:	85dfd0ef          	jal	80002978 <argstr>
    80005120:	87aa                	mv	a5,a0
    return -1;
    80005122:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005124:	0a07c363          	bltz	a5,800051ca <sys_open+0xca>
    80005128:	f526                	sd	s1,168(sp)

  begin_op();
    8000512a:	c61fe0ef          	jal	80003d8a <begin_op>

  if(omode & O_CREATE){
    8000512e:	f4c42783          	lw	a5,-180(s0)
    80005132:	2007f793          	andi	a5,a5,512
    80005136:	c3dd                	beqz	a5,800051dc <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005138:	4681                	li	a3,0
    8000513a:	4601                	li	a2,0
    8000513c:	4589                	li	a1,2
    8000513e:	f5040513          	addi	a0,s0,-176
    80005142:	aafff0ef          	jal	80004bf0 <create>
    80005146:	84aa                	mv	s1,a0
    if(ip == 0){
    80005148:	c549                	beqz	a0,800051d2 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000514a:	04449703          	lh	a4,68(s1)
    8000514e:	478d                	li	a5,3
    80005150:	00f71763          	bne	a4,a5,8000515e <sys_open+0x5e>
    80005154:	0464d703          	lhu	a4,70(s1)
    80005158:	47a5                	li	a5,9
    8000515a:	0ae7ee63          	bltu	a5,a4,80005216 <sys_open+0x116>
    8000515e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005160:	fabfe0ef          	jal	8000410a <filealloc>
    80005164:	892a                	mv	s2,a0
    80005166:	c561                	beqz	a0,8000522e <sys_open+0x12e>
    80005168:	ed4e                	sd	s3,152(sp)
    8000516a:	a47ff0ef          	jal	80004bb0 <fdalloc>
    8000516e:	89aa                	mv	s3,a0
    80005170:	0a054b63          	bltz	a0,80005226 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005174:	04449703          	lh	a4,68(s1)
    80005178:	478d                	li	a5,3
    8000517a:	0cf70363          	beq	a4,a5,80005240 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000517e:	4789                	li	a5,2
    80005180:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005184:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005188:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000518c:	f4c42783          	lw	a5,-180(s0)
    80005190:	0017f713          	andi	a4,a5,1
    80005194:	00174713          	xori	a4,a4,1
    80005198:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000519c:	0037f713          	andi	a4,a5,3
    800051a0:	00e03733          	snez	a4,a4
    800051a4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800051a8:	4007f793          	andi	a5,a5,1024
    800051ac:	c791                	beqz	a5,800051b8 <sys_open+0xb8>
    800051ae:	04449703          	lh	a4,68(s1)
    800051b2:	4789                	li	a5,2
    800051b4:	08f70d63          	beq	a4,a5,8000524e <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800051b8:	8526                	mv	a0,s1
    800051ba:	a72fe0ef          	jal	8000342c <iunlock>
  end_op();
    800051be:	c3dfe0ef          	jal	80003dfa <end_op>

  return fd;
    800051c2:	854e                	mv	a0,s3
    800051c4:	74aa                	ld	s1,168(sp)
    800051c6:	790a                	ld	s2,160(sp)
    800051c8:	69ea                	ld	s3,152(sp)
}
    800051ca:	70ea                	ld	ra,184(sp)
    800051cc:	744a                	ld	s0,176(sp)
    800051ce:	6129                	addi	sp,sp,192
    800051d0:	8082                	ret
      end_op();
    800051d2:	c29fe0ef          	jal	80003dfa <end_op>
      return -1;
    800051d6:	557d                	li	a0,-1
    800051d8:	74aa                	ld	s1,168(sp)
    800051da:	bfc5                	j	800051ca <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800051dc:	f5040513          	addi	a0,s0,-176
    800051e0:	9cdfe0ef          	jal	80003bac <namei>
    800051e4:	84aa                	mv	s1,a0
    800051e6:	c11d                	beqz	a0,8000520c <sys_open+0x10c>
    ilock(ip);
    800051e8:	996fe0ef          	jal	8000337e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800051ec:	04449703          	lh	a4,68(s1)
    800051f0:	4785                	li	a5,1
    800051f2:	f4f71ce3          	bne	a4,a5,8000514a <sys_open+0x4a>
    800051f6:	f4c42783          	lw	a5,-180(s0)
    800051fa:	d3b5                	beqz	a5,8000515e <sys_open+0x5e>
      iunlockput(ip);
    800051fc:	8526                	mv	a0,s1
    800051fe:	b8cfe0ef          	jal	8000358a <iunlockput>
      end_op();
    80005202:	bf9fe0ef          	jal	80003dfa <end_op>
      return -1;
    80005206:	557d                	li	a0,-1
    80005208:	74aa                	ld	s1,168(sp)
    8000520a:	b7c1                	j	800051ca <sys_open+0xca>
      end_op();
    8000520c:	beffe0ef          	jal	80003dfa <end_op>
      return -1;
    80005210:	557d                	li	a0,-1
    80005212:	74aa                	ld	s1,168(sp)
    80005214:	bf5d                	j	800051ca <sys_open+0xca>
    iunlockput(ip);
    80005216:	8526                	mv	a0,s1
    80005218:	b72fe0ef          	jal	8000358a <iunlockput>
    end_op();
    8000521c:	bdffe0ef          	jal	80003dfa <end_op>
    return -1;
    80005220:	557d                	li	a0,-1
    80005222:	74aa                	ld	s1,168(sp)
    80005224:	b75d                	j	800051ca <sys_open+0xca>
      fileclose(f);
    80005226:	854a                	mv	a0,s2
    80005228:	f87fe0ef          	jal	800041ae <fileclose>
    8000522c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000522e:	8526                	mv	a0,s1
    80005230:	b5afe0ef          	jal	8000358a <iunlockput>
    end_op();
    80005234:	bc7fe0ef          	jal	80003dfa <end_op>
    return -1;
    80005238:	557d                	li	a0,-1
    8000523a:	74aa                	ld	s1,168(sp)
    8000523c:	790a                	ld	s2,160(sp)
    8000523e:	b771                	j	800051ca <sys_open+0xca>
    f->type = FD_DEVICE;
    80005240:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005244:	04649783          	lh	a5,70(s1)
    80005248:	02f91223          	sh	a5,36(s2)
    8000524c:	bf35                	j	80005188 <sys_open+0x88>
    itrunc(ip);
    8000524e:	8526                	mv	a0,s1
    80005250:	a1cfe0ef          	jal	8000346c <itrunc>
    80005254:	b795                	j	800051b8 <sys_open+0xb8>

0000000080005256 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005256:	7175                	addi	sp,sp,-144
    80005258:	e506                	sd	ra,136(sp)
    8000525a:	e122                	sd	s0,128(sp)
    8000525c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000525e:	b2dfe0ef          	jal	80003d8a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005262:	08000613          	li	a2,128
    80005266:	f7040593          	addi	a1,s0,-144
    8000526a:	4501                	li	a0,0
    8000526c:	f0cfd0ef          	jal	80002978 <argstr>
    80005270:	02054363          	bltz	a0,80005296 <sys_mkdir+0x40>
    80005274:	4681                	li	a3,0
    80005276:	4601                	li	a2,0
    80005278:	4585                	li	a1,1
    8000527a:	f7040513          	addi	a0,s0,-144
    8000527e:	973ff0ef          	jal	80004bf0 <create>
    80005282:	c911                	beqz	a0,80005296 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005284:	b06fe0ef          	jal	8000358a <iunlockput>
  end_op();
    80005288:	b73fe0ef          	jal	80003dfa <end_op>
  return 0;
    8000528c:	4501                	li	a0,0
}
    8000528e:	60aa                	ld	ra,136(sp)
    80005290:	640a                	ld	s0,128(sp)
    80005292:	6149                	addi	sp,sp,144
    80005294:	8082                	ret
    end_op();
    80005296:	b65fe0ef          	jal	80003dfa <end_op>
    return -1;
    8000529a:	557d                	li	a0,-1
    8000529c:	bfcd                	j	8000528e <sys_mkdir+0x38>

000000008000529e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000529e:	7135                	addi	sp,sp,-160
    800052a0:	ed06                	sd	ra,152(sp)
    800052a2:	e922                	sd	s0,144(sp)
    800052a4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800052a6:	ae5fe0ef          	jal	80003d8a <begin_op>
  argint(1, &major);
    800052aa:	f6c40593          	addi	a1,s0,-148
    800052ae:	4505                	li	a0,1
    800052b0:	e90fd0ef          	jal	80002940 <argint>
  argint(2, &minor);
    800052b4:	f6840593          	addi	a1,s0,-152
    800052b8:	4509                	li	a0,2
    800052ba:	e86fd0ef          	jal	80002940 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800052be:	08000613          	li	a2,128
    800052c2:	f7040593          	addi	a1,s0,-144
    800052c6:	4501                	li	a0,0
    800052c8:	eb0fd0ef          	jal	80002978 <argstr>
    800052cc:	02054563          	bltz	a0,800052f6 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800052d0:	f6841683          	lh	a3,-152(s0)
    800052d4:	f6c41603          	lh	a2,-148(s0)
    800052d8:	458d                	li	a1,3
    800052da:	f7040513          	addi	a0,s0,-144
    800052de:	913ff0ef          	jal	80004bf0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800052e2:	c911                	beqz	a0,800052f6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052e4:	aa6fe0ef          	jal	8000358a <iunlockput>
  end_op();
    800052e8:	b13fe0ef          	jal	80003dfa <end_op>
  return 0;
    800052ec:	4501                	li	a0,0
}
    800052ee:	60ea                	ld	ra,152(sp)
    800052f0:	644a                	ld	s0,144(sp)
    800052f2:	610d                	addi	sp,sp,160
    800052f4:	8082                	ret
    end_op();
    800052f6:	b05fe0ef          	jal	80003dfa <end_op>
    return -1;
    800052fa:	557d                	li	a0,-1
    800052fc:	bfcd                	j	800052ee <sys_mknod+0x50>

00000000800052fe <sys_chdir>:

uint64
sys_chdir(void)
{
    800052fe:	7135                	addi	sp,sp,-160
    80005300:	ed06                	sd	ra,152(sp)
    80005302:	e922                	sd	s0,144(sp)
    80005304:	e14a                	sd	s2,128(sp)
    80005306:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005308:	e2efc0ef          	jal	80001936 <myproc>
    8000530c:	892a                	mv	s2,a0
  
  begin_op();
    8000530e:	a7dfe0ef          	jal	80003d8a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005312:	08000613          	li	a2,128
    80005316:	f6040593          	addi	a1,s0,-160
    8000531a:	4501                	li	a0,0
    8000531c:	e5cfd0ef          	jal	80002978 <argstr>
    80005320:	04054363          	bltz	a0,80005366 <sys_chdir+0x68>
    80005324:	e526                	sd	s1,136(sp)
    80005326:	f6040513          	addi	a0,s0,-160
    8000532a:	883fe0ef          	jal	80003bac <namei>
    8000532e:	84aa                	mv	s1,a0
    80005330:	c915                	beqz	a0,80005364 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005332:	84cfe0ef          	jal	8000337e <ilock>
  if(ip->type != T_DIR){
    80005336:	04449703          	lh	a4,68(s1)
    8000533a:	4785                	li	a5,1
    8000533c:	02f71963          	bne	a4,a5,8000536e <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	8eafe0ef          	jal	8000342c <iunlock>
  iput(p->cwd);
    80005346:	15093503          	ld	a0,336(s2)
    8000534a:	9b6fe0ef          	jal	80003500 <iput>
  end_op();
    8000534e:	aadfe0ef          	jal	80003dfa <end_op>
  p->cwd = ip;
    80005352:	14993823          	sd	s1,336(s2)
  return 0;
    80005356:	4501                	li	a0,0
    80005358:	64aa                	ld	s1,136(sp)
}
    8000535a:	60ea                	ld	ra,152(sp)
    8000535c:	644a                	ld	s0,144(sp)
    8000535e:	690a                	ld	s2,128(sp)
    80005360:	610d                	addi	sp,sp,160
    80005362:	8082                	ret
    80005364:	64aa                	ld	s1,136(sp)
    end_op();
    80005366:	a95fe0ef          	jal	80003dfa <end_op>
    return -1;
    8000536a:	557d                	li	a0,-1
    8000536c:	b7fd                	j	8000535a <sys_chdir+0x5c>
    iunlockput(ip);
    8000536e:	8526                	mv	a0,s1
    80005370:	a1afe0ef          	jal	8000358a <iunlockput>
    end_op();
    80005374:	a87fe0ef          	jal	80003dfa <end_op>
    return -1;
    80005378:	557d                	li	a0,-1
    8000537a:	64aa                	ld	s1,136(sp)
    8000537c:	bff9                	j	8000535a <sys_chdir+0x5c>

000000008000537e <sys_exec>:

uint64
sys_exec(void)
{
    8000537e:	7105                	addi	sp,sp,-480
    80005380:	ef86                	sd	ra,472(sp)
    80005382:	eba2                	sd	s0,464(sp)
    80005384:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005386:	e2840593          	addi	a1,s0,-472
    8000538a:	4505                	li	a0,1
    8000538c:	dd0fd0ef          	jal	8000295c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005390:	08000613          	li	a2,128
    80005394:	f3040593          	addi	a1,s0,-208
    80005398:	4501                	li	a0,0
    8000539a:	ddefd0ef          	jal	80002978 <argstr>
    8000539e:	87aa                	mv	a5,a0
    return -1;
    800053a0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800053a2:	0e07c063          	bltz	a5,80005482 <sys_exec+0x104>
    800053a6:	e7a6                	sd	s1,456(sp)
    800053a8:	e3ca                	sd	s2,448(sp)
    800053aa:	ff4e                	sd	s3,440(sp)
    800053ac:	fb52                	sd	s4,432(sp)
    800053ae:	f756                	sd	s5,424(sp)
    800053b0:	f35a                	sd	s6,416(sp)
    800053b2:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800053b4:	e3040a13          	addi	s4,s0,-464
    800053b8:	10000613          	li	a2,256
    800053bc:	4581                	li	a1,0
    800053be:	8552                	mv	a0,s4
    800053c0:	939fb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800053c4:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800053c6:	89d2                	mv	s3,s4
    800053c8:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800053ca:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800053ce:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800053d0:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800053d4:	00391513          	slli	a0,s2,0x3
    800053d8:	85d6                	mv	a1,s5
    800053da:	e2843783          	ld	a5,-472(s0)
    800053de:	953e                	add	a0,a0,a5
    800053e0:	cd6fd0ef          	jal	800028b6 <fetchaddr>
    800053e4:	02054663          	bltz	a0,80005410 <sys_exec+0x92>
    if(uarg == 0){
    800053e8:	e2043783          	ld	a5,-480(s0)
    800053ec:	c7a1                	beqz	a5,80005434 <sys_exec+0xb6>
    argv[i] = kalloc();
    800053ee:	f56fb0ef          	jal	80000b44 <kalloc>
    800053f2:	85aa                	mv	a1,a0
    800053f4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800053f8:	cd01                	beqz	a0,80005410 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800053fa:	865a                	mv	a2,s6
    800053fc:	e2043503          	ld	a0,-480(s0)
    80005400:	d00fd0ef          	jal	80002900 <fetchstr>
    80005404:	00054663          	bltz	a0,80005410 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005408:	0905                	addi	s2,s2,1
    8000540a:	09a1                	addi	s3,s3,8
    8000540c:	fd7914e3          	bne	s2,s7,800053d4 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005410:	100a0a13          	addi	s4,s4,256
    80005414:	6088                	ld	a0,0(s1)
    80005416:	cd31                	beqz	a0,80005472 <sys_exec+0xf4>
    kfree(argv[i]);
    80005418:	e44fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000541c:	04a1                	addi	s1,s1,8
    8000541e:	ff449be3          	bne	s1,s4,80005414 <sys_exec+0x96>
  return -1;
    80005422:	557d                	li	a0,-1
    80005424:	64be                	ld	s1,456(sp)
    80005426:	691e                	ld	s2,448(sp)
    80005428:	79fa                	ld	s3,440(sp)
    8000542a:	7a5a                	ld	s4,432(sp)
    8000542c:	7aba                	ld	s5,424(sp)
    8000542e:	7b1a                	ld	s6,416(sp)
    80005430:	6bfa                	ld	s7,408(sp)
    80005432:	a881                	j	80005482 <sys_exec+0x104>
      argv[i] = 0;
    80005434:	0009079b          	sext.w	a5,s2
    80005438:	e3040593          	addi	a1,s0,-464
    8000543c:	078e                	slli	a5,a5,0x3
    8000543e:	97ae                	add	a5,a5,a1
    80005440:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005444:	f3040513          	addi	a0,s0,-208
    80005448:	bb2ff0ef          	jal	800047fa <kexec>
    8000544c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000544e:	100a0a13          	addi	s4,s4,256
    80005452:	6088                	ld	a0,0(s1)
    80005454:	c511                	beqz	a0,80005460 <sys_exec+0xe2>
    kfree(argv[i]);
    80005456:	e06fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000545a:	04a1                	addi	s1,s1,8
    8000545c:	ff449be3          	bne	s1,s4,80005452 <sys_exec+0xd4>
  return ret;
    80005460:	854a                	mv	a0,s2
    80005462:	64be                	ld	s1,456(sp)
    80005464:	691e                	ld	s2,448(sp)
    80005466:	79fa                	ld	s3,440(sp)
    80005468:	7a5a                	ld	s4,432(sp)
    8000546a:	7aba                	ld	s5,424(sp)
    8000546c:	7b1a                	ld	s6,416(sp)
    8000546e:	6bfa                	ld	s7,408(sp)
    80005470:	a809                	j	80005482 <sys_exec+0x104>
  return -1;
    80005472:	557d                	li	a0,-1
    80005474:	64be                	ld	s1,456(sp)
    80005476:	691e                	ld	s2,448(sp)
    80005478:	79fa                	ld	s3,440(sp)
    8000547a:	7a5a                	ld	s4,432(sp)
    8000547c:	7aba                	ld	s5,424(sp)
    8000547e:	7b1a                	ld	s6,416(sp)
    80005480:	6bfa                	ld	s7,408(sp)
}
    80005482:	60fe                	ld	ra,472(sp)
    80005484:	645e                	ld	s0,464(sp)
    80005486:	613d                	addi	sp,sp,480
    80005488:	8082                	ret

000000008000548a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000548a:	7139                	addi	sp,sp,-64
    8000548c:	fc06                	sd	ra,56(sp)
    8000548e:	f822                	sd	s0,48(sp)
    80005490:	f426                	sd	s1,40(sp)
    80005492:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005494:	ca2fc0ef          	jal	80001936 <myproc>
    80005498:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000549a:	fd840593          	addi	a1,s0,-40
    8000549e:	4501                	li	a0,0
    800054a0:	cbcfd0ef          	jal	8000295c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800054a4:	fc840593          	addi	a1,s0,-56
    800054a8:	fd040513          	addi	a0,s0,-48
    800054ac:	81eff0ef          	jal	800044ca <pipealloc>
    return -1;
    800054b0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800054b2:	0a054763          	bltz	a0,80005560 <sys_pipe+0xd6>
  fd0 = -1;
    800054b6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800054ba:	fd043503          	ld	a0,-48(s0)
    800054be:	ef2ff0ef          	jal	80004bb0 <fdalloc>
    800054c2:	fca42223          	sw	a0,-60(s0)
    800054c6:	08054463          	bltz	a0,8000554e <sys_pipe+0xc4>
    800054ca:	fc843503          	ld	a0,-56(s0)
    800054ce:	ee2ff0ef          	jal	80004bb0 <fdalloc>
    800054d2:	fca42023          	sw	a0,-64(s0)
    800054d6:	06054263          	bltz	a0,8000553a <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800054da:	4691                	li	a3,4
    800054dc:	fc440613          	addi	a2,s0,-60
    800054e0:	fd843583          	ld	a1,-40(s0)
    800054e4:	68a8                	ld	a0,80(s1)
    800054e6:	96efc0ef          	jal	80001654 <copyout>
    800054ea:	00054e63          	bltz	a0,80005506 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800054ee:	4691                	li	a3,4
    800054f0:	fc040613          	addi	a2,s0,-64
    800054f4:	fd843583          	ld	a1,-40(s0)
    800054f8:	95b6                	add	a1,a1,a3
    800054fa:	68a8                	ld	a0,80(s1)
    800054fc:	958fc0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005500:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005502:	04055f63          	bgez	a0,80005560 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005506:	fc442783          	lw	a5,-60(s0)
    8000550a:	078e                	slli	a5,a5,0x3
    8000550c:	0d078793          	addi	a5,a5,208
    80005510:	97a6                	add	a5,a5,s1
    80005512:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005516:	fc042783          	lw	a5,-64(s0)
    8000551a:	078e                	slli	a5,a5,0x3
    8000551c:	0d078793          	addi	a5,a5,208
    80005520:	97a6                	add	a5,a5,s1
    80005522:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005526:	fd043503          	ld	a0,-48(s0)
    8000552a:	c85fe0ef          	jal	800041ae <fileclose>
    fileclose(wf);
    8000552e:	fc843503          	ld	a0,-56(s0)
    80005532:	c7dfe0ef          	jal	800041ae <fileclose>
    return -1;
    80005536:	57fd                	li	a5,-1
    80005538:	a025                	j	80005560 <sys_pipe+0xd6>
    if(fd0 >= 0)
    8000553a:	fc442783          	lw	a5,-60(s0)
    8000553e:	0007c863          	bltz	a5,8000554e <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005542:	078e                	slli	a5,a5,0x3
    80005544:	0d078793          	addi	a5,a5,208
    80005548:	97a6                	add	a5,a5,s1
    8000554a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000554e:	fd043503          	ld	a0,-48(s0)
    80005552:	c5dfe0ef          	jal	800041ae <fileclose>
    fileclose(wf);
    80005556:	fc843503          	ld	a0,-56(s0)
    8000555a:	c55fe0ef          	jal	800041ae <fileclose>
    return -1;
    8000555e:	57fd                	li	a5,-1
}
    80005560:	853e                	mv	a0,a5
    80005562:	70e2                	ld	ra,56(sp)
    80005564:	7442                	ld	s0,48(sp)
    80005566:	74a2                	ld	s1,40(sp)
    80005568:	6121                	addi	sp,sp,64
    8000556a:	8082                	ret
    8000556c:	0000                	unimp
	...

0000000080005570 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005570:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005572:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005574:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005576:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005578:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000557a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000557c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000557e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005580:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005582:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005584:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005586:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005588:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000558a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000558c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000558e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005590:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005592:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005594:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005596:	a2efd0ef          	jal	800027c4 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000559a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000559c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000559e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800055a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800055a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800055a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800055a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800055a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800055aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800055ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800055ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800055b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800055b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800055b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800055b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800055b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800055ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800055bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800055be:	10200073          	sret
    800055c2:	00000013          	nop
    800055c6:	00000013          	nop
    800055ca:	00000013          	nop

00000000800055ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800055ce:	1141                	addi	sp,sp,-16
    800055d0:	e406                	sd	ra,8(sp)
    800055d2:	e022                	sd	s0,0(sp)
    800055d4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800055d6:	0c000737          	lui	a4,0xc000
    800055da:	4785                	li	a5,1
    800055dc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800055de:	c35c                	sw	a5,4(a4)
}
    800055e0:	60a2                	ld	ra,8(sp)
    800055e2:	6402                	ld	s0,0(sp)
    800055e4:	0141                	addi	sp,sp,16
    800055e6:	8082                	ret

00000000800055e8 <plicinithart>:

void
plicinithart(void)
{
    800055e8:	1141                	addi	sp,sp,-16
    800055ea:	e406                	sd	ra,8(sp)
    800055ec:	e022                	sd	s0,0(sp)
    800055ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055f0:	b12fc0ef          	jal	80001902 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800055f4:	0085171b          	slliw	a4,a0,0x8
    800055f8:	0c0027b7          	lui	a5,0xc002
    800055fc:	97ba                	add	a5,a5,a4
    800055fe:	40200713          	li	a4,1026
    80005602:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005606:	00d5151b          	slliw	a0,a0,0xd
    8000560a:	0c2017b7          	lui	a5,0xc201
    8000560e:	97aa                	add	a5,a5,a0
    80005610:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005614:	60a2                	ld	ra,8(sp)
    80005616:	6402                	ld	s0,0(sp)
    80005618:	0141                	addi	sp,sp,16
    8000561a:	8082                	ret

000000008000561c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000561c:	1141                	addi	sp,sp,-16
    8000561e:	e406                	sd	ra,8(sp)
    80005620:	e022                	sd	s0,0(sp)
    80005622:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005624:	adefc0ef          	jal	80001902 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005628:	00d5151b          	slliw	a0,a0,0xd
    8000562c:	0c2017b7          	lui	a5,0xc201
    80005630:	97aa                	add	a5,a5,a0
  return irq;
}
    80005632:	43c8                	lw	a0,4(a5)
    80005634:	60a2                	ld	ra,8(sp)
    80005636:	6402                	ld	s0,0(sp)
    80005638:	0141                	addi	sp,sp,16
    8000563a:	8082                	ret

000000008000563c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000563c:	1101                	addi	sp,sp,-32
    8000563e:	ec06                	sd	ra,24(sp)
    80005640:	e822                	sd	s0,16(sp)
    80005642:	e426                	sd	s1,8(sp)
    80005644:	1000                	addi	s0,sp,32
    80005646:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005648:	abafc0ef          	jal	80001902 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000564c:	00d5179b          	slliw	a5,a0,0xd
    80005650:	0c201737          	lui	a4,0xc201
    80005654:	97ba                	add	a5,a5,a4
    80005656:	c3c4                	sw	s1,4(a5)
}
    80005658:	60e2                	ld	ra,24(sp)
    8000565a:	6442                	ld	s0,16(sp)
    8000565c:	64a2                	ld	s1,8(sp)
    8000565e:	6105                	addi	sp,sp,32
    80005660:	8082                	ret

0000000080005662 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005662:	1141                	addi	sp,sp,-16
    80005664:	e406                	sd	ra,8(sp)
    80005666:	e022                	sd	s0,0(sp)
    80005668:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000566a:	479d                	li	a5,7
    8000566c:	04a7ca63          	blt	a5,a0,800056c0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005670:	0001c797          	auipc	a5,0x1c
    80005674:	81078793          	addi	a5,a5,-2032 # 80020e80 <disk>
    80005678:	97aa                	add	a5,a5,a0
    8000567a:	0187c783          	lbu	a5,24(a5)
    8000567e:	e7b9                	bnez	a5,800056cc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005680:	00451693          	slli	a3,a0,0x4
    80005684:	0001b797          	auipc	a5,0x1b
    80005688:	7fc78793          	addi	a5,a5,2044 # 80020e80 <disk>
    8000568c:	6398                	ld	a4,0(a5)
    8000568e:	9736                	add	a4,a4,a3
    80005690:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005694:	6398                	ld	a4,0(a5)
    80005696:	9736                	add	a4,a4,a3
    80005698:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000569c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800056a0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800056a4:	97aa                	add	a5,a5,a0
    800056a6:	4705                	li	a4,1
    800056a8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800056ac:	0001b517          	auipc	a0,0x1b
    800056b0:	7ec50513          	addi	a0,a0,2028 # 80020e98 <disk+0x18>
    800056b4:	99bfc0ef          	jal	8000204e <wakeup>
}
    800056b8:	60a2                	ld	ra,8(sp)
    800056ba:	6402                	ld	s0,0(sp)
    800056bc:	0141                	addi	sp,sp,16
    800056be:	8082                	ret
    panic("free_desc 1");
    800056c0:	00002517          	auipc	a0,0x2
    800056c4:	f5850513          	addi	a0,a0,-168 # 80007618 <etext+0x618>
    800056c8:	95cfb0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    800056cc:	00002517          	auipc	a0,0x2
    800056d0:	f5c50513          	addi	a0,a0,-164 # 80007628 <etext+0x628>
    800056d4:	950fb0ef          	jal	80000824 <panic>

00000000800056d8 <virtio_disk_init>:
{
    800056d8:	1101                	addi	sp,sp,-32
    800056da:	ec06                	sd	ra,24(sp)
    800056dc:	e822                	sd	s0,16(sp)
    800056de:	e426                	sd	s1,8(sp)
    800056e0:	e04a                	sd	s2,0(sp)
    800056e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800056e4:	00002597          	auipc	a1,0x2
    800056e8:	f5458593          	addi	a1,a1,-172 # 80007638 <etext+0x638>
    800056ec:	0001c517          	auipc	a0,0x1c
    800056f0:	8bc50513          	addi	a0,a0,-1860 # 80020fa8 <disk+0x128>
    800056f4:	caafb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056f8:	100017b7          	lui	a5,0x10001
    800056fc:	4398                	lw	a4,0(a5)
    800056fe:	2701                	sext.w	a4,a4
    80005700:	747277b7          	lui	a5,0x74727
    80005704:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005708:	14f71863          	bne	a4,a5,80005858 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000570c:	100017b7          	lui	a5,0x10001
    80005710:	43dc                	lw	a5,4(a5)
    80005712:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005714:	4709                	li	a4,2
    80005716:	14e79163          	bne	a5,a4,80005858 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000571a:	100017b7          	lui	a5,0x10001
    8000571e:	479c                	lw	a5,8(a5)
    80005720:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005722:	12e79b63          	bne	a5,a4,80005858 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005726:	100017b7          	lui	a5,0x10001
    8000572a:	47d8                	lw	a4,12(a5)
    8000572c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000572e:	554d47b7          	lui	a5,0x554d4
    80005732:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005736:	12f71163          	bne	a4,a5,80005858 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000573a:	100017b7          	lui	a5,0x10001
    8000573e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005742:	4705                	li	a4,1
    80005744:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005746:	470d                	li	a4,3
    80005748:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000574a:	10001737          	lui	a4,0x10001
    8000574e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005750:	c7ffe6b7          	lui	a3,0xc7ffe
    80005754:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd79f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005758:	8f75                	and	a4,a4,a3
    8000575a:	100016b7          	lui	a3,0x10001
    8000575e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005760:	472d                	li	a4,11
    80005762:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005764:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005768:	439c                	lw	a5,0(a5)
    8000576a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000576e:	8ba1                	andi	a5,a5,8
    80005770:	0e078a63          	beqz	a5,80005864 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005774:	100017b7          	lui	a5,0x10001
    80005778:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000577c:	43fc                	lw	a5,68(a5)
    8000577e:	2781                	sext.w	a5,a5
    80005780:	0e079863          	bnez	a5,80005870 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005784:	100017b7          	lui	a5,0x10001
    80005788:	5bdc                	lw	a5,52(a5)
    8000578a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000578c:	0e078863          	beqz	a5,8000587c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005790:	471d                	li	a4,7
    80005792:	0ef77b63          	bgeu	a4,a5,80005888 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005796:	baefb0ef          	jal	80000b44 <kalloc>
    8000579a:	0001b497          	auipc	s1,0x1b
    8000579e:	6e648493          	addi	s1,s1,1766 # 80020e80 <disk>
    800057a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800057a4:	ba0fb0ef          	jal	80000b44 <kalloc>
    800057a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800057aa:	b9afb0ef          	jal	80000b44 <kalloc>
    800057ae:	87aa                	mv	a5,a0
    800057b0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800057b2:	6088                	ld	a0,0(s1)
    800057b4:	0e050063          	beqz	a0,80005894 <virtio_disk_init+0x1bc>
    800057b8:	0001b717          	auipc	a4,0x1b
    800057bc:	6d073703          	ld	a4,1744(a4) # 80020e88 <disk+0x8>
    800057c0:	cb71                	beqz	a4,80005894 <virtio_disk_init+0x1bc>
    800057c2:	cbe9                	beqz	a5,80005894 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800057c4:	6605                	lui	a2,0x1
    800057c6:	4581                	li	a1,0
    800057c8:	d30fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800057cc:	0001b497          	auipc	s1,0x1b
    800057d0:	6b448493          	addi	s1,s1,1716 # 80020e80 <disk>
    800057d4:	6605                	lui	a2,0x1
    800057d6:	4581                	li	a1,0
    800057d8:	6488                	ld	a0,8(s1)
    800057da:	d1efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    800057de:	6605                	lui	a2,0x1
    800057e0:	4581                	li	a1,0
    800057e2:	6888                	ld	a0,16(s1)
    800057e4:	d14fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800057e8:	100017b7          	lui	a5,0x10001
    800057ec:	4721                	li	a4,8
    800057ee:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800057f0:	4098                	lw	a4,0(s1)
    800057f2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800057f6:	40d8                	lw	a4,4(s1)
    800057f8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800057fc:	649c                	ld	a5,8(s1)
    800057fe:	0007869b          	sext.w	a3,a5
    80005802:	10001737          	lui	a4,0x10001
    80005806:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000580a:	9781                	srai	a5,a5,0x20
    8000580c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005810:	689c                	ld	a5,16(s1)
    80005812:	0007869b          	sext.w	a3,a5
    80005816:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000581a:	9781                	srai	a5,a5,0x20
    8000581c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005820:	4785                	li	a5,1
    80005822:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005824:	00f48c23          	sb	a5,24(s1)
    80005828:	00f48ca3          	sb	a5,25(s1)
    8000582c:	00f48d23          	sb	a5,26(s1)
    80005830:	00f48da3          	sb	a5,27(s1)
    80005834:	00f48e23          	sb	a5,28(s1)
    80005838:	00f48ea3          	sb	a5,29(s1)
    8000583c:	00f48f23          	sb	a5,30(s1)
    80005840:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005844:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005848:	07272823          	sw	s2,112(a4)
}
    8000584c:	60e2                	ld	ra,24(sp)
    8000584e:	6442                	ld	s0,16(sp)
    80005850:	64a2                	ld	s1,8(sp)
    80005852:	6902                	ld	s2,0(sp)
    80005854:	6105                	addi	sp,sp,32
    80005856:	8082                	ret
    panic("could not find virtio disk");
    80005858:	00002517          	auipc	a0,0x2
    8000585c:	df050513          	addi	a0,a0,-528 # 80007648 <etext+0x648>
    80005860:	fc5fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005864:	00002517          	auipc	a0,0x2
    80005868:	e0450513          	addi	a0,a0,-508 # 80007668 <etext+0x668>
    8000586c:	fb9fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005870:	00002517          	auipc	a0,0x2
    80005874:	e1850513          	addi	a0,a0,-488 # 80007688 <etext+0x688>
    80005878:	fadfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    8000587c:	00002517          	auipc	a0,0x2
    80005880:	e2c50513          	addi	a0,a0,-468 # 800076a8 <etext+0x6a8>
    80005884:	fa1fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005888:	00002517          	auipc	a0,0x2
    8000588c:	e4050513          	addi	a0,a0,-448 # 800076c8 <etext+0x6c8>
    80005890:	f95fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005894:	00002517          	auipc	a0,0x2
    80005898:	e5450513          	addi	a0,a0,-428 # 800076e8 <etext+0x6e8>
    8000589c:	f89fa0ef          	jal	80000824 <panic>

00000000800058a0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800058a0:	711d                	addi	sp,sp,-96
    800058a2:	ec86                	sd	ra,88(sp)
    800058a4:	e8a2                	sd	s0,80(sp)
    800058a6:	e4a6                	sd	s1,72(sp)
    800058a8:	e0ca                	sd	s2,64(sp)
    800058aa:	fc4e                	sd	s3,56(sp)
    800058ac:	f852                	sd	s4,48(sp)
    800058ae:	f456                	sd	s5,40(sp)
    800058b0:	f05a                	sd	s6,32(sp)
    800058b2:	ec5e                	sd	s7,24(sp)
    800058b4:	e862                	sd	s8,16(sp)
    800058b6:	1080                	addi	s0,sp,96
    800058b8:	89aa                	mv	s3,a0
    800058ba:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800058bc:	00c52b83          	lw	s7,12(a0)
    800058c0:	001b9b9b          	slliw	s7,s7,0x1
    800058c4:	1b82                	slli	s7,s7,0x20
    800058c6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800058ca:	0001b517          	auipc	a0,0x1b
    800058ce:	6de50513          	addi	a0,a0,1758 # 80020fa8 <disk+0x128>
    800058d2:	b56fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    800058d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800058d8:	0001ba97          	auipc	s5,0x1b
    800058dc:	5a8a8a93          	addi	s5,s5,1448 # 80020e80 <disk>
  for(int i = 0; i < 3; i++){
    800058e0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800058e2:	5c7d                	li	s8,-1
    800058e4:	a095                	j	80005948 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800058e6:	00fa8733          	add	a4,s5,a5
    800058ea:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800058ee:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800058f0:	0207c563          	bltz	a5,8000591a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800058f4:	2905                	addiw	s2,s2,1
    800058f6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800058f8:	05490c63          	beq	s2,s4,80005950 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800058fc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800058fe:	0001b717          	auipc	a4,0x1b
    80005902:	58270713          	addi	a4,a4,1410 # 80020e80 <disk>
    80005906:	4781                	li	a5,0
    if(disk.free[i]){
    80005908:	01874683          	lbu	a3,24(a4)
    8000590c:	fee9                	bnez	a3,800058e6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000590e:	2785                	addiw	a5,a5,1
    80005910:	0705                	addi	a4,a4,1
    80005912:	fe979be3          	bne	a5,s1,80005908 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005916:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000591a:	01205d63          	blez	s2,80005934 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000591e:	fa042503          	lw	a0,-96(s0)
    80005922:	d41ff0ef          	jal	80005662 <free_desc>
      for(int j = 0; j < i; j++)
    80005926:	4785                	li	a5,1
    80005928:	0127d663          	bge	a5,s2,80005934 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000592c:	fa442503          	lw	a0,-92(s0)
    80005930:	d33ff0ef          	jal	80005662 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005934:	0001b597          	auipc	a1,0x1b
    80005938:	67458593          	addi	a1,a1,1652 # 80020fa8 <disk+0x128>
    8000593c:	0001b517          	auipc	a0,0x1b
    80005940:	55c50513          	addi	a0,a0,1372 # 80020e98 <disk+0x18>
    80005944:	ebefc0ef          	jal	80002002 <sleep>
  for(int i = 0; i < 3; i++){
    80005948:	fa040613          	addi	a2,s0,-96
    8000594c:	4901                	li	s2,0
    8000594e:	b77d                	j	800058fc <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005950:	fa042503          	lw	a0,-96(s0)
    80005954:	00451693          	slli	a3,a0,0x4

  if(write)
    80005958:	0001b797          	auipc	a5,0x1b
    8000595c:	52878793          	addi	a5,a5,1320 # 80020e80 <disk>
    80005960:	00451713          	slli	a4,a0,0x4
    80005964:	0a070713          	addi	a4,a4,160
    80005968:	973e                	add	a4,a4,a5
    8000596a:	01603633          	snez	a2,s6
    8000596e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005970:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005974:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005978:	6398                	ld	a4,0(a5)
    8000597a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000597c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005980:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005982:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005984:	6390                	ld	a2,0(a5)
    80005986:	00d60833          	add	a6,a2,a3
    8000598a:	4741                	li	a4,16
    8000598c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005990:	4585                	li	a1,1
    80005992:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005996:	fa442703          	lw	a4,-92(s0)
    8000599a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000599e:	0712                	slli	a4,a4,0x4
    800059a0:	963a                	add	a2,a2,a4
    800059a2:	05898813          	addi	a6,s3,88
    800059a6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800059aa:	0007b883          	ld	a7,0(a5)
    800059ae:	9746                	add	a4,a4,a7
    800059b0:	40000613          	li	a2,1024
    800059b4:	c710                	sw	a2,8(a4)
  if(write)
    800059b6:	001b3613          	seqz	a2,s6
    800059ba:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800059be:	8e4d                	or	a2,a2,a1
    800059c0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800059c4:	fa842603          	lw	a2,-88(s0)
    800059c8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800059cc:	00451813          	slli	a6,a0,0x4
    800059d0:	02080813          	addi	a6,a6,32
    800059d4:	983e                	add	a6,a6,a5
    800059d6:	577d                	li	a4,-1
    800059d8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800059dc:	0612                	slli	a2,a2,0x4
    800059de:	98b2                	add	a7,a7,a2
    800059e0:	03068713          	addi	a4,a3,48
    800059e4:	973e                	add	a4,a4,a5
    800059e6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800059ea:	6398                	ld	a4,0(a5)
    800059ec:	9732                	add	a4,a4,a2
    800059ee:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800059f0:	4689                	li	a3,2
    800059f2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800059f6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800059fa:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800059fe:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a02:	6794                	ld	a3,8(a5)
    80005a04:	0026d703          	lhu	a4,2(a3)
    80005a08:	8b1d                	andi	a4,a4,7
    80005a0a:	0706                	slli	a4,a4,0x1
    80005a0c:	96ba                	add	a3,a3,a4
    80005a0e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005a12:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a16:	6798                	ld	a4,8(a5)
    80005a18:	00275783          	lhu	a5,2(a4)
    80005a1c:	2785                	addiw	a5,a5,1
    80005a1e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005a22:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a26:	100017b7          	lui	a5,0x10001
    80005a2a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005a2e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005a32:	0001b917          	auipc	s2,0x1b
    80005a36:	57690913          	addi	s2,s2,1398 # 80020fa8 <disk+0x128>
  while(b->disk == 1) {
    80005a3a:	84ae                	mv	s1,a1
    80005a3c:	00b79a63          	bne	a5,a1,80005a50 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005a40:	85ca                	mv	a1,s2
    80005a42:	854e                	mv	a0,s3
    80005a44:	dbefc0ef          	jal	80002002 <sleep>
  while(b->disk == 1) {
    80005a48:	0049a783          	lw	a5,4(s3)
    80005a4c:	fe978ae3          	beq	a5,s1,80005a40 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005a50:	fa042903          	lw	s2,-96(s0)
    80005a54:	00491713          	slli	a4,s2,0x4
    80005a58:	02070713          	addi	a4,a4,32
    80005a5c:	0001b797          	auipc	a5,0x1b
    80005a60:	42478793          	addi	a5,a5,1060 # 80020e80 <disk>
    80005a64:	97ba                	add	a5,a5,a4
    80005a66:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005a6a:	0001b997          	auipc	s3,0x1b
    80005a6e:	41698993          	addi	s3,s3,1046 # 80020e80 <disk>
    80005a72:	00491713          	slli	a4,s2,0x4
    80005a76:	0009b783          	ld	a5,0(s3)
    80005a7a:	97ba                	add	a5,a5,a4
    80005a7c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005a80:	854a                	mv	a0,s2
    80005a82:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005a86:	bddff0ef          	jal	80005662 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005a8a:	8885                	andi	s1,s1,1
    80005a8c:	f0fd                	bnez	s1,80005a72 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005a8e:	0001b517          	auipc	a0,0x1b
    80005a92:	51a50513          	addi	a0,a0,1306 # 80020fa8 <disk+0x128>
    80005a96:	a26fb0ef          	jal	80000cbc <release>
}
    80005a9a:	60e6                	ld	ra,88(sp)
    80005a9c:	6446                	ld	s0,80(sp)
    80005a9e:	64a6                	ld	s1,72(sp)
    80005aa0:	6906                	ld	s2,64(sp)
    80005aa2:	79e2                	ld	s3,56(sp)
    80005aa4:	7a42                	ld	s4,48(sp)
    80005aa6:	7aa2                	ld	s5,40(sp)
    80005aa8:	7b02                	ld	s6,32(sp)
    80005aaa:	6be2                	ld	s7,24(sp)
    80005aac:	6c42                	ld	s8,16(sp)
    80005aae:	6125                	addi	sp,sp,96
    80005ab0:	8082                	ret

0000000080005ab2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ab2:	1101                	addi	sp,sp,-32
    80005ab4:	ec06                	sd	ra,24(sp)
    80005ab6:	e822                	sd	s0,16(sp)
    80005ab8:	e426                	sd	s1,8(sp)
    80005aba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005abc:	0001b497          	auipc	s1,0x1b
    80005ac0:	3c448493          	addi	s1,s1,964 # 80020e80 <disk>
    80005ac4:	0001b517          	auipc	a0,0x1b
    80005ac8:	4e450513          	addi	a0,a0,1252 # 80020fa8 <disk+0x128>
    80005acc:	95cfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ad0:	100017b7          	lui	a5,0x10001
    80005ad4:	53bc                	lw	a5,96(a5)
    80005ad6:	8b8d                	andi	a5,a5,3
    80005ad8:	10001737          	lui	a4,0x10001
    80005adc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005ade:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005ae2:	689c                	ld	a5,16(s1)
    80005ae4:	0204d703          	lhu	a4,32(s1)
    80005ae8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005aec:	04f70863          	beq	a4,a5,80005b3c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005af0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005af4:	6898                	ld	a4,16(s1)
    80005af6:	0204d783          	lhu	a5,32(s1)
    80005afa:	8b9d                	andi	a5,a5,7
    80005afc:	078e                	slli	a5,a5,0x3
    80005afe:	97ba                	add	a5,a5,a4
    80005b00:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005b02:	00479713          	slli	a4,a5,0x4
    80005b06:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005b0a:	9726                	add	a4,a4,s1
    80005b0c:	01074703          	lbu	a4,16(a4)
    80005b10:	e329                	bnez	a4,80005b52 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005b12:	0792                	slli	a5,a5,0x4
    80005b14:	02078793          	addi	a5,a5,32
    80005b18:	97a6                	add	a5,a5,s1
    80005b1a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005b1c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b20:	d2efc0ef          	jal	8000204e <wakeup>

    disk.used_idx += 1;
    80005b24:	0204d783          	lhu	a5,32(s1)
    80005b28:	2785                	addiw	a5,a5,1
    80005b2a:	17c2                	slli	a5,a5,0x30
    80005b2c:	93c1                	srli	a5,a5,0x30
    80005b2e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005b32:	6898                	ld	a4,16(s1)
    80005b34:	00275703          	lhu	a4,2(a4)
    80005b38:	faf71ce3          	bne	a4,a5,80005af0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005b3c:	0001b517          	auipc	a0,0x1b
    80005b40:	46c50513          	addi	a0,a0,1132 # 80020fa8 <disk+0x128>
    80005b44:	978fb0ef          	jal	80000cbc <release>
}
    80005b48:	60e2                	ld	ra,24(sp)
    80005b4a:	6442                	ld	s0,16(sp)
    80005b4c:	64a2                	ld	s1,8(sp)
    80005b4e:	6105                	addi	sp,sp,32
    80005b50:	8082                	ret
      panic("virtio_disk_intr status");
    80005b52:	00002517          	auipc	a0,0x2
    80005b56:	bae50513          	addi	a0,a0,-1106 # 80007700 <etext+0x700>
    80005b5a:	ccbfa0ef          	jal	80000824 <panic>
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
