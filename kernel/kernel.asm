
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd7ff>
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
    8000011a:	448020ef          	jal	80002562 <either_copyin>
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
    800001be:	7ea010ef          	jal	800019a8 <myproc>
    800001c2:	238020ef          	jal	800023fa <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	7b7010ef          	jal	80002182 <sleep>
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
    80000210:	308020ef          	jal	80002518 <either_copyout>
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
    800002da:	2d2020ef          	jal	800025ac <procdump>
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
    8000041a:	5b5010ef          	jal	800021ce <wakeup>
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
    80000444:	a2878793          	addi	a5,a5,-1496 # 8001fe68 <devsw>
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
    8000092c:	057010ef          	jal	80002182 <sleep>
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
    80000a4c:	782010ef          	jal	800021ce <wakeup>
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
    80000a6c:	59878793          	addi	a5,a5,1432 # 80021000 <end>
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
    80000b34:	4d050513          	addi	a0,a0,1232 # 80021000 <end>
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
    80000bce:	5bb000ef          	jal	80001988 <mycpu>
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
    80000bfe:	58b000ef          	jal	80001988 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	583000ef          	jal	80001988 <mycpu>
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
    80000c1a:	56f000ef          	jal	80001988 <mycpu>
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
    80000c50:	539000ef          	jal	80001988 <mycpu>
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
    80000c74:	515000ef          	jal	80001988 <mycpu>
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
    80000eb6:	2bf000ef          	jal	80001974 <cpuid>
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
    80000ece:	2a7000ef          	jal	80001974 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	7fa010ef          	jal	800026de <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	0c1040ef          	jal	800057a8 <plicinithart>
  }

  scheduler();        
    80000eec:	04e010ef          	jal	80001f3a <scheduler>
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
    80000f28:	161000ef          	jal	80001888 <procinit>
    trapinit();      // trap vectors
    80000f2c:	78e010ef          	jal	800026ba <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	7ae010ef          	jal	800026de <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	05b040ef          	jal	8000578e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	071040ef          	jal	800057a8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	6e1010ef          	jal	80002e1c <binit>
    iinit();         // inode table
    80000f40:	432020ef          	jal	80003372 <iinit>
    fileinit();      // file table
    80000f44:	35e030ef          	jal	800042a2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	151040ef          	jal	80005898 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	533000ef          	jal	80001c7e <userinit>
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
    800011dc:	60e000ef          	jal	800017ea <proc_mapstacks>
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
    800015e0:	3c8000ef          	jal	800019a8 <myproc>
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

00000000800017a0 <mlfq_enqueue>:


// Enqueue a process to its priority queue (must hold mlfq_lock)
static void
mlfq_enqueue(struct proc *p)
{
    800017a0:	1141                	addi	sp,sp,-16
    800017a2:	e406                	sd	ra,8(sp)
    800017a4:	e022                	sd	s0,0(sp)
    800017a6:	0800                	addi	s0,sp,16
  int pri = p->priority;
    800017a8:	16852783          	lw	a5,360(a0)
  p->queue_next = 0;
    800017ac:	16053823          	sd	zero,368(a0)
  
  if(mlfq_tails[pri] == 0) {
    800017b0:	00379693          	slli	a3,a5,0x3
    800017b4:	0000e717          	auipc	a4,0xe
    800017b8:	1e470713          	addi	a4,a4,484 # 8000f998 <mlfq_tails>
    800017bc:	9736                	add	a4,a4,a3
    800017be:	6318                	ld	a4,0(a4)
    800017c0:	cf11                	beqz	a4,800017dc <mlfq_enqueue+0x3c>
    // Queue is empty
    mlfq_heads[pri] = p;
    mlfq_tails[pri] = p;
  } else {
    // Add to tail
    mlfq_tails[pri]->queue_next = p;
    800017c2:	16a73823          	sd	a0,368(a4)
    mlfq_tails[pri] = p;
    800017c6:	078e                	slli	a5,a5,0x3
    800017c8:	0000e717          	auipc	a4,0xe
    800017cc:	1d070713          	addi	a4,a4,464 # 8000f998 <mlfq_tails>
    800017d0:	97ba                	add	a5,a5,a4
    800017d2:	e388                	sd	a0,0(a5)
    mlfq_tails[pri] = p;
  }
}
    800017d4:	60a2                	ld	ra,8(sp)
    800017d6:	6402                	ld	s0,0(sp)
    800017d8:	0141                	addi	sp,sp,16
    800017da:	8082                	ret
    mlfq_heads[pri] = p;
    800017dc:	0000e717          	auipc	a4,0xe
    800017e0:	1bc70713          	addi	a4,a4,444 # 8000f998 <mlfq_tails>
    800017e4:	9736                	add	a4,a4,a3
    800017e6:	f308                	sd	a0,32(a4)
    mlfq_tails[pri] = p;
    800017e8:	bff9                	j	800017c6 <mlfq_enqueue+0x26>

00000000800017ea <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017ea:	715d                	addi	sp,sp,-80
    800017ec:	e486                	sd	ra,72(sp)
    800017ee:	e0a2                	sd	s0,64(sp)
    800017f0:	fc26                	sd	s1,56(sp)
    800017f2:	f84a                	sd	s2,48(sp)
    800017f4:	f44e                	sd	s3,40(sp)
    800017f6:	f052                	sd	s4,32(sp)
    800017f8:	ec56                	sd	s5,24(sp)
    800017fa:	e85a                	sd	s6,16(sp)
    800017fc:	e45e                	sd	s7,8(sp)
    800017fe:	e062                	sd	s8,0(sp)
    80001800:	0880                	addi	s0,sp,80
    80001802:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001804:	0000e497          	auipc	s1,0xe
    80001808:	61c48493          	addi	s1,s1,1564 # 8000fe20 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000180c:	8c26                	mv	s8,s1
    8000180e:	677d47b7          	lui	a5,0x677d4
    80001812:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    80001816:	51b3c937          	lui	s2,0x51b3c
    8000181a:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    8000181e:	1902                	slli	s2,s2,0x20
    80001820:	993e                	add	s2,s2,a5
    80001822:	040009b7          	lui	s3,0x4000
    80001826:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001828:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000182a:	4b99                	li	s7,6
    8000182c:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000182e:	00014a97          	auipc	s5,0x14
    80001832:	3f2a8a93          	addi	s5,s5,1010 # 80015c20 <tickslock>
    char *pa = kalloc();
    80001836:	b0eff0ef          	jal	80000b44 <kalloc>
    8000183a:	862a                	mv	a2,a0
    if(pa == 0)
    8000183c:	c121                	beqz	a0,8000187c <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    8000183e:	418485b3          	sub	a1,s1,s8
    80001842:	858d                	srai	a1,a1,0x3
    80001844:	032585b3          	mul	a1,a1,s2
    80001848:	05b6                	slli	a1,a1,0xd
    8000184a:	6789                	lui	a5,0x2
    8000184c:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000184e:	875e                	mv	a4,s7
    80001850:	86da                	mv	a3,s6
    80001852:	40b985b3          	sub	a1,s3,a1
    80001856:	8552                	mv	a0,s4
    80001858:	8bfff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	17848493          	addi	s1,s1,376
    80001860:	fd549be3          	bne	s1,s5,80001836 <proc_mapstacks+0x4c>
  }
}
    80001864:	60a6                	ld	ra,72(sp)
    80001866:	6406                	ld	s0,64(sp)
    80001868:	74e2                	ld	s1,56(sp)
    8000186a:	7942                	ld	s2,48(sp)
    8000186c:	79a2                	ld	s3,40(sp)
    8000186e:	7a02                	ld	s4,32(sp)
    80001870:	6ae2                	ld	s5,24(sp)
    80001872:	6b42                	ld	s6,16(sp)
    80001874:	6ba2                	ld	s7,8(sp)
    80001876:	6c02                	ld	s8,0(sp)
    80001878:	6161                	addi	sp,sp,80
    8000187a:	8082                	ret
      panic("kalloc");
    8000187c:	00006517          	auipc	a0,0x6
    80001880:	8dc50513          	addi	a0,a0,-1828 # 80007158 <etext+0x158>
    80001884:	fa1fe0ef          	jal	80000824 <panic>

0000000080001888 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001888:	7139                	addi	sp,sp,-64
    8000188a:	fc06                	sd	ra,56(sp)
    8000188c:	f822                	sd	s0,48(sp)
    8000188e:	f426                	sd	s1,40(sp)
    80001890:	f04a                	sd	s2,32(sp)
    80001892:	ec4e                	sd	s3,24(sp)
    80001894:	e852                	sd	s4,16(sp)
    80001896:	e456                	sd	s5,8(sp)
    80001898:	e05a                	sd	s6,0(sp)
    8000189a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000189c:	0000e497          	auipc	s1,0xe
    800018a0:	0fc48493          	addi	s1,s1,252 # 8000f998 <mlfq_tails>
    800018a4:	00006597          	auipc	a1,0x6
    800018a8:	8bc58593          	addi	a1,a1,-1860 # 80007160 <etext+0x160>
    800018ac:	0000e517          	auipc	a0,0xe
    800018b0:	12c50513          	addi	a0,a0,300 # 8000f9d8 <pid_lock>
    800018b4:	aeaff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    800018b8:	00006597          	auipc	a1,0x6
    800018bc:	8b058593          	addi	a1,a1,-1872 # 80007168 <etext+0x168>
    800018c0:	0000e517          	auipc	a0,0xe
    800018c4:	13050513          	addi	a0,a0,304 # 8000f9f0 <wait_lock>
    800018c8:	ad6ff0ef          	jal	80000b9e <initlock>
  initlock(&mlfq_lock, "mlfq");
    800018cc:	00006597          	auipc	a1,0x6
    800018d0:	8ac58593          	addi	a1,a1,-1876 # 80007178 <etext+0x178>
    800018d4:	0000e517          	auipc	a0,0xe
    800018d8:	13450513          	addi	a0,a0,308 # 8000fa08 <mlfq_lock>
    800018dc:	ac2ff0ef          	jal	80000b9e <initlock>
  
  // Initialize MLFQ queues
  for(int i = 0; i < NMLFQ; i++) {
    mlfq_heads[i] = 0;
    800018e0:	0204b023          	sd	zero,32(s1)
    mlfq_tails[i] = 0;
    800018e4:	0004b023          	sd	zero,0(s1)
    mlfq_heads[i] = 0;
    800018e8:	0204b423          	sd	zero,40(s1)
    mlfq_tails[i] = 0;
    800018ec:	0004b423          	sd	zero,8(s1)
    mlfq_heads[i] = 0;
    800018f0:	0204b823          	sd	zero,48(s1)
    mlfq_tails[i] = 0;
    800018f4:	0004b823          	sd	zero,16(s1)
    mlfq_heads[i] = 0;
    800018f8:	0204bc23          	sd	zero,56(s1)
    mlfq_tails[i] = 0;
    800018fc:	0004bc23          	sd	zero,24(s1)
  }
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001900:	0000e497          	auipc	s1,0xe
    80001904:	52048493          	addi	s1,s1,1312 # 8000fe20 <proc>
      initlock(&p->lock, "proc");
    80001908:	00006b17          	auipc	s6,0x6
    8000190c:	878b0b13          	addi	s6,s6,-1928 # 80007180 <etext+0x180>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001910:	8aa6                	mv	s5,s1
    80001912:	677d47b7          	lui	a5,0x677d4
    80001916:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    8000191a:	51b3c937          	lui	s2,0x51b3c
    8000191e:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    80001922:	1902                	slli	s2,s2,0x20
    80001924:	993e                	add	s2,s2,a5
    80001926:	040009b7          	lui	s3,0x4000
    8000192a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000192c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192e:	00014a17          	auipc	s4,0x14
    80001932:	2f2a0a13          	addi	s4,s4,754 # 80015c20 <tickslock>
      initlock(&p->lock, "proc");
    80001936:	85da                	mv	a1,s6
    80001938:	8526                	mv	a0,s1
    8000193a:	a64ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    8000193e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001942:	415487b3          	sub	a5,s1,s5
    80001946:	878d                	srai	a5,a5,0x3
    80001948:	032787b3          	mul	a5,a5,s2
    8000194c:	07b6                	slli	a5,a5,0xd
    8000194e:	6709                	lui	a4,0x2
    80001950:	9fb9                	addw	a5,a5,a4
    80001952:	40f987b3          	sub	a5,s3,a5
    80001956:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001958:	17848493          	addi	s1,s1,376
    8000195c:	fd449de3          	bne	s1,s4,80001936 <procinit+0xae>
  }
}
    80001960:	70e2                	ld	ra,56(sp)
    80001962:	7442                	ld	s0,48(sp)
    80001964:	74a2                	ld	s1,40(sp)
    80001966:	7902                	ld	s2,32(sp)
    80001968:	69e2                	ld	s3,24(sp)
    8000196a:	6a42                	ld	s4,16(sp)
    8000196c:	6aa2                	ld	s5,8(sp)
    8000196e:	6b02                	ld	s6,0(sp)
    80001970:	6121                	addi	sp,sp,64
    80001972:	8082                	ret

0000000080001974 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001974:	1141                	addi	sp,sp,-16
    80001976:	e406                	sd	ra,8(sp)
    80001978:	e022                	sd	s0,0(sp)
    8000197a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000197c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000197e:	2501                	sext.w	a0,a0
    80001980:	60a2                	ld	ra,8(sp)
    80001982:	6402                	ld	s0,0(sp)
    80001984:	0141                	addi	sp,sp,16
    80001986:	8082                	ret

0000000080001988 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001988:	1141                	addi	sp,sp,-16
    8000198a:	e406                	sd	ra,8(sp)
    8000198c:	e022                	sd	s0,0(sp)
    8000198e:	0800                	addi	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
  return c;
}
    80001996:	0000e517          	auipc	a0,0xe
    8000199a:	08a50513          	addi	a0,a0,138 # 8000fa20 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	60a2                	ld	ra,8(sp)
    800019a2:	6402                	ld	s0,0(sp)
    800019a4:	0141                	addi	sp,sp,16
    800019a6:	8082                	ret

00000000800019a8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019a8:	1101                	addi	sp,sp,-32
    800019aa:	ec06                	sd	ra,24(sp)
    800019ac:	e822                	sd	s0,16(sp)
    800019ae:	e426                	sd	s1,8(sp)
    800019b0:	1000                	addi	s0,sp,32
  push_off();
    800019b2:	a32ff0ef          	jal	80000be4 <push_off>
    800019b6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019b8:	2781                	sext.w	a5,a5
    800019ba:	079e                	slli	a5,a5,0x7
    800019bc:	0000e717          	auipc	a4,0xe
    800019c0:	fdc70713          	addi	a4,a4,-36 # 8000f998 <mlfq_tails>
    800019c4:	97ba                	add	a5,a5,a4
    800019c6:	67dc                	ld	a5,136(a5)
    800019c8:	84be                	mv	s1,a5
  pop_off();
    800019ca:	aa2ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    800019ce:	8526                	mv	a0,s1
    800019d0:	60e2                	ld	ra,24(sp)
    800019d2:	6442                	ld	s0,16(sp)
    800019d4:	64a2                	ld	s1,8(sp)
    800019d6:	6105                	addi	sp,sp,32
    800019d8:	8082                	ret

00000000800019da <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019da:	7179                	addi	sp,sp,-48
    800019dc:	f406                	sd	ra,40(sp)
    800019de:	f022                	sd	s0,32(sp)
    800019e0:	ec26                	sd	s1,24(sp)
    800019e2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019e4:	fc5ff0ef          	jal	800019a8 <myproc>
    800019e8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019ea:	ad2ff0ef          	jal	80000cbc <release>

  if (first) {
    800019ee:	00006797          	auipc	a5,0x6
    800019f2:	e527a783          	lw	a5,-430(a5) # 80007840 <first.1>
    800019f6:	cf95                	beqz	a5,80001a32 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019f8:	4505                	li	a0,1
    800019fa:	635010ef          	jal	8000382e <fsinit>

    first = 0;
    800019fe:	00006797          	auipc	a5,0x6
    80001a02:	e407a123          	sw	zero,-446(a5) # 80007840 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001a06:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001a0a:	00005797          	auipc	a5,0x5
    80001a0e:	77e78793          	addi	a5,a5,1918 # 80007188 <etext+0x188>
    80001a12:	fcf43823          	sd	a5,-48(s0)
    80001a16:	fc043c23          	sd	zero,-40(s0)
    80001a1a:	fd040593          	addi	a1,s0,-48
    80001a1e:	853e                	mv	a0,a5
    80001a20:	797020ef          	jal	800049b6 <kexec>
    80001a24:	6cbc                	ld	a5,88(s1)
    80001a26:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a28:	6cbc                	ld	a5,88(s1)
    80001a2a:	7bb8                	ld	a4,112(a5)
    80001a2c:	57fd                	li	a5,-1
    80001a2e:	02f70d63          	beq	a4,a5,80001a68 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a32:	4c9000ef          	jal	800026fa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a36:	68a8                	ld	a0,80(s1)
    80001a38:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a3a:	04000737          	lui	a4,0x4000
    80001a3e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a40:	0732                	slli	a4,a4,0xc
    80001a42:	00004797          	auipc	a5,0x4
    80001a46:	65a78793          	addi	a5,a5,1626 # 8000609c <userret>
    80001a4a:	00004697          	auipc	a3,0x4
    80001a4e:	5b668693          	addi	a3,a3,1462 # 80006000 <_trampoline>
    80001a52:	8f95                	sub	a5,a5,a3
    80001a54:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a56:	577d                	li	a4,-1
    80001a58:	177e                	slli	a4,a4,0x3f
    80001a5a:	8d59                	or	a0,a0,a4
    80001a5c:	9782                	jalr	a5
}
    80001a5e:	70a2                	ld	ra,40(sp)
    80001a60:	7402                	ld	s0,32(sp)
    80001a62:	64e2                	ld	s1,24(sp)
    80001a64:	6145                	addi	sp,sp,48
    80001a66:	8082                	ret
      panic("exec");
    80001a68:	00005517          	auipc	a0,0x5
    80001a6c:	72850513          	addi	a0,a0,1832 # 80007190 <etext+0x190>
    80001a70:	db5fe0ef          	jal	80000824 <panic>

0000000080001a74 <allocpid>:
{
    80001a74:	1101                	addi	sp,sp,-32
    80001a76:	ec06                	sd	ra,24(sp)
    80001a78:	e822                	sd	s0,16(sp)
    80001a7a:	e426                	sd	s1,8(sp)
    80001a7c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a7e:	0000e517          	auipc	a0,0xe
    80001a82:	f5a50513          	addi	a0,a0,-166 # 8000f9d8 <pid_lock>
    80001a86:	9a2ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a8a:	00006797          	auipc	a5,0x6
    80001a8e:	dba78793          	addi	a5,a5,-582 # 80007844 <nextpid>
    80001a92:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a94:	0014871b          	addiw	a4,s1,1
    80001a98:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a9a:	0000e517          	auipc	a0,0xe
    80001a9e:	f3e50513          	addi	a0,a0,-194 # 8000f9d8 <pid_lock>
    80001aa2:	a1aff0ef          	jal	80000cbc <release>
}
    80001aa6:	8526                	mv	a0,s1
    80001aa8:	60e2                	ld	ra,24(sp)
    80001aaa:	6442                	ld	s0,16(sp)
    80001aac:	64a2                	ld	s1,8(sp)
    80001aae:	6105                	addi	sp,sp,32
    80001ab0:	8082                	ret

0000000080001ab2 <proc_pagetable>:
{
    80001ab2:	1101                	addi	sp,sp,-32
    80001ab4:	ec06                	sd	ra,24(sp)
    80001ab6:	e822                	sd	s0,16(sp)
    80001ab8:	e426                	sd	s1,8(sp)
    80001aba:	e04a                	sd	s2,0(sp)
    80001abc:	1000                	addi	s0,sp,32
    80001abe:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac0:	f48ff0ef          	jal	80001208 <uvmcreate>
    80001ac4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ac6:	cd05                	beqz	a0,80001afe <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ac8:	4729                	li	a4,10
    80001aca:	00004697          	auipc	a3,0x4
    80001ace:	53668693          	addi	a3,a3,1334 # 80006000 <_trampoline>
    80001ad2:	6605                	lui	a2,0x1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	d84ff0ef          	jal	80001060 <mappages>
    80001ae0:	02054663          	bltz	a0,80001b0c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ae4:	4719                	li	a4,6
    80001ae6:	05893683          	ld	a3,88(s2)
    80001aea:	6605                	lui	a2,0x1
    80001aec:	020005b7          	lui	a1,0x2000
    80001af0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001af2:	05b6                	slli	a1,a1,0xd
    80001af4:	8526                	mv	a0,s1
    80001af6:	d6aff0ef          	jal	80001060 <mappages>
    80001afa:	00054f63          	bltz	a0,80001b18 <proc_pagetable+0x66>
}
    80001afe:	8526                	mv	a0,s1
    80001b00:	60e2                	ld	ra,24(sp)
    80001b02:	6442                	ld	s0,16(sp)
    80001b04:	64a2                	ld	s1,8(sp)
    80001b06:	6902                	ld	s2,0(sp)
    80001b08:	6105                	addi	sp,sp,32
    80001b0a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b0c:	4581                	li	a1,0
    80001b0e:	8526                	mv	a0,s1
    80001b10:	8f3ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b14:	4481                	li	s1,0
    80001b16:	b7e5                	j	80001afe <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b18:	4681                	li	a3,0
    80001b1a:	4605                	li	a2,1
    80001b1c:	040005b7          	lui	a1,0x4000
    80001b20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b22:	05b2                	slli	a1,a1,0xc
    80001b24:	8526                	mv	a0,s1
    80001b26:	f08ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b2a:	4581                	li	a1,0
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	8d5ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b32:	4481                	li	s1,0
    80001b34:	b7e9                	j	80001afe <proc_pagetable+0x4c>

0000000080001b36 <proc_freepagetable>:
{
    80001b36:	1101                	addi	sp,sp,-32
    80001b38:	ec06                	sd	ra,24(sp)
    80001b3a:	e822                	sd	s0,16(sp)
    80001b3c:	e426                	sd	s1,8(sp)
    80001b3e:	e04a                	sd	s2,0(sp)
    80001b40:	1000                	addi	s0,sp,32
    80001b42:	84aa                	mv	s1,a0
    80001b44:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b46:	4681                	li	a3,0
    80001b48:	4605                	li	a2,1
    80001b4a:	040005b7          	lui	a1,0x4000
    80001b4e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b50:	05b2                	slli	a1,a1,0xc
    80001b52:	edcff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b56:	4681                	li	a3,0
    80001b58:	4605                	li	a2,1
    80001b5a:	020005b7          	lui	a1,0x2000
    80001b5e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b60:	05b6                	slli	a1,a1,0xd
    80001b62:	8526                	mv	a0,s1
    80001b64:	ecaff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b68:	85ca                	mv	a1,s2
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	897ff0ef          	jal	80001402 <uvmfree>
}
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret

0000000080001b7c <freeproc>:
{
    80001b7c:	1101                	addi	sp,sp,-32
    80001b7e:	ec06                	sd	ra,24(sp)
    80001b80:	e822                	sd	s0,16(sp)
    80001b82:	e426                	sd	s1,8(sp)
    80001b84:	1000                	addi	s0,sp,32
    80001b86:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b88:	6d28                	ld	a0,88(a0)
    80001b8a:	c119                	beqz	a0,80001b90 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b8c:	ed1fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b90:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b94:	68a8                	ld	a0,80(s1)
    80001b96:	c501                	beqz	a0,80001b9e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b98:	64ac                	ld	a1,72(s1)
    80001b9a:	f9dff0ef          	jal	80001b36 <proc_freepagetable>
  p->pagetable = 0;
    80001b9e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ba2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ba6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001baa:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bae:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bb2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bb6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bba:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bbe:	0004ac23          	sw	zero,24(s1)
}
    80001bc2:	60e2                	ld	ra,24(sp)
    80001bc4:	6442                	ld	s0,16(sp)
    80001bc6:	64a2                	ld	s1,8(sp)
    80001bc8:	6105                	addi	sp,sp,32
    80001bca:	8082                	ret

0000000080001bcc <allocproc>:
{
    80001bcc:	1101                	addi	sp,sp,-32
    80001bce:	ec06                	sd	ra,24(sp)
    80001bd0:	e822                	sd	s0,16(sp)
    80001bd2:	e426                	sd	s1,8(sp)
    80001bd4:	e04a                	sd	s2,0(sp)
    80001bd6:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd8:	0000e497          	auipc	s1,0xe
    80001bdc:	24848493          	addi	s1,s1,584 # 8000fe20 <proc>
    80001be0:	00014917          	auipc	s2,0x14
    80001be4:	04090913          	addi	s2,s2,64 # 80015c20 <tickslock>
    acquire(&p->lock);
    80001be8:	8526                	mv	a0,s1
    80001bea:	83eff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001bee:	4c9c                	lw	a5,24(s1)
    80001bf0:	cb91                	beqz	a5,80001c04 <allocproc+0x38>
      release(&p->lock);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	8c8ff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf8:	17848493          	addi	s1,s1,376
    80001bfc:	ff2496e3          	bne	s1,s2,80001be8 <allocproc+0x1c>
  return 0;
    80001c00:	4481                	li	s1,0
    80001c02:	a0b9                	j	80001c50 <allocproc+0x84>
  p->pid = allocpid();
    80001c04:	e71ff0ef          	jal	80001a74 <allocpid>
    80001c08:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c0a:	4785                	li	a5,1
    80001c0c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c0e:	f37fe0ef          	jal	80000b44 <kalloc>
    80001c12:	892a                	mv	s2,a0
    80001c14:	eca8                	sd	a0,88(s1)
    80001c16:	c521                	beqz	a0,80001c5e <allocproc+0x92>
  p->pagetable = proc_pagetable(p);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	e99ff0ef          	jal	80001ab2 <proc_pagetable>
    80001c1e:	892a                	mv	s2,a0
    80001c20:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c22:	c531                	beqz	a0,80001c6e <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80001c24:	07000613          	li	a2,112
    80001c28:	4581                	li	a1,0
    80001c2a:	06048513          	addi	a0,s1,96
    80001c2e:	8caff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001c32:	00000797          	auipc	a5,0x0
    80001c36:	da878793          	addi	a5,a5,-600 # 800019da <forkret>
    80001c3a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3c:	60bc                	ld	a5,64(s1)
    80001c3e:	6705                	lui	a4,0x1
    80001c40:	97ba                	add	a5,a5,a4
    80001c42:	f4bc                	sd	a5,104(s1)
  p->priority = 0;
    80001c44:	1604a423          	sw	zero,360(s1)
  p->time_slices = 0;
    80001c48:	1604a623          	sw	zero,364(s1)
  p->queue_next = 0;
    80001c4c:	1604b823          	sd	zero,368(s1)
}
    80001c50:	8526                	mv	a0,s1
    80001c52:	60e2                	ld	ra,24(sp)
    80001c54:	6442                	ld	s0,16(sp)
    80001c56:	64a2                	ld	s1,8(sp)
    80001c58:	6902                	ld	s2,0(sp)
    80001c5a:	6105                	addi	sp,sp,32
    80001c5c:	8082                	ret
    freeproc(p);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	f1dff0ef          	jal	80001b7c <freeproc>
    release(&p->lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	856ff0ef          	jal	80000cbc <release>
    return 0;
    80001c6a:	84ca                	mv	s1,s2
    80001c6c:	b7d5                	j	80001c50 <allocproc+0x84>
    freeproc(p);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	f0dff0ef          	jal	80001b7c <freeproc>
    release(&p->lock);
    80001c74:	8526                	mv	a0,s1
    80001c76:	846ff0ef          	jal	80000cbc <release>
    return 0;
    80001c7a:	84ca                	mv	s1,s2
    80001c7c:	bfd1                	j	80001c50 <allocproc+0x84>

0000000080001c7e <userinit>:
{
    80001c7e:	1101                	addi	sp,sp,-32
    80001c80:	ec06                	sd	ra,24(sp)
    80001c82:	e822                	sd	s0,16(sp)
    80001c84:	e426                	sd	s1,8(sp)
    80001c86:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c88:	f45ff0ef          	jal	80001bcc <allocproc>
    80001c8c:	84aa                	mv	s1,a0
  initproc = p;
    80001c8e:	00006797          	auipc	a5,0x6
    80001c92:	bea7bd23          	sd	a0,-1030(a5) # 80007888 <initproc>
  p->cwd = namei("/");
    80001c96:	00005517          	auipc	a0,0x5
    80001c9a:	50250513          	addi	a0,a0,1282 # 80007198 <etext+0x198>
    80001c9e:	0ca020ef          	jal	80003d68 <namei>
    80001ca2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ca6:	478d                	li	a5,3
    80001ca8:	cc9c                	sw	a5,24(s1)
  acquire(&mlfq_lock);
    80001caa:	0000e517          	auipc	a0,0xe
    80001cae:	d5e50513          	addi	a0,a0,-674 # 8000fa08 <mlfq_lock>
    80001cb2:	f77fe0ef          	jal	80000c28 <acquire>
  mlfq_enqueue(p);
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	ae9ff0ef          	jal	800017a0 <mlfq_enqueue>
  release(&mlfq_lock);
    80001cbc:	0000e517          	auipc	a0,0xe
    80001cc0:	d4c50513          	addi	a0,a0,-692 # 8000fa08 <mlfq_lock>
    80001cc4:	ff9fe0ef          	jal	80000cbc <release>
  release(&p->lock);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	ff3fe0ef          	jal	80000cbc <release>
}
    80001cce:	60e2                	ld	ra,24(sp)
    80001cd0:	6442                	ld	s0,16(sp)
    80001cd2:	64a2                	ld	s1,8(sp)
    80001cd4:	6105                	addi	sp,sp,32
    80001cd6:	8082                	ret

0000000080001cd8 <growproc>:
{
    80001cd8:	1101                	addi	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	e04a                	sd	s2,0(sp)
    80001ce2:	1000                	addi	s0,sp,32
    80001ce4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ce6:	cc3ff0ef          	jal	800019a8 <myproc>
    80001cea:	892a                	mv	s2,a0
  sz = p->sz;
    80001cec:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001cee:	02905963          	blez	s1,80001d20 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001cf2:	00b48633          	add	a2,s1,a1
    80001cf6:	020007b7          	lui	a5,0x2000
    80001cfa:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cfc:	07b6                	slli	a5,a5,0xd
    80001cfe:	02c7ea63          	bltu	a5,a2,80001d32 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d02:	4691                	li	a3,4
    80001d04:	6928                	ld	a0,80(a0)
    80001d06:	df6ff0ef          	jal	800012fc <uvmalloc>
    80001d0a:	85aa                	mv	a1,a0
    80001d0c:	c50d                	beqz	a0,80001d36 <growproc+0x5e>
  p->sz = sz;
    80001d0e:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d12:	4501                	li	a0,0
}
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6902                	ld	s2,0(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret
  } else if(n < 0){
    80001d20:	fe04d7e3          	bgez	s1,80001d0e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d24:	00b48633          	add	a2,s1,a1
    80001d28:	6928                	ld	a0,80(a0)
    80001d2a:	d8eff0ef          	jal	800012b8 <uvmdealloc>
    80001d2e:	85aa                	mv	a1,a0
    80001d30:	bff9                	j	80001d0e <growproc+0x36>
      return -1;
    80001d32:	557d                	li	a0,-1
    80001d34:	b7c5                	j	80001d14 <growproc+0x3c>
      return -1;
    80001d36:	557d                	li	a0,-1
    80001d38:	bff1                	j	80001d14 <growproc+0x3c>

0000000080001d3a <kfork>:
{
    80001d3a:	7139                	addi	sp,sp,-64
    80001d3c:	fc06                	sd	ra,56(sp)
    80001d3e:	f822                	sd	s0,48(sp)
    80001d40:	f426                	sd	s1,40(sp)
    80001d42:	e456                	sd	s5,8(sp)
    80001d44:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d46:	c63ff0ef          	jal	800019a8 <myproc>
    80001d4a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d4c:	e81ff0ef          	jal	80001bcc <allocproc>
    80001d50:	10050963          	beqz	a0,80001e62 <kfork+0x128>
    80001d54:	ec4e                	sd	s3,24(sp)
    80001d56:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d58:	048ab603          	ld	a2,72(s5)
    80001d5c:	692c                	ld	a1,80(a0)
    80001d5e:	050ab503          	ld	a0,80(s5)
    80001d62:	ed2ff0ef          	jal	80001434 <uvmcopy>
    80001d66:	04054863          	bltz	a0,80001db6 <kfork+0x7c>
    80001d6a:	f04a                	sd	s2,32(sp)
    80001d6c:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001d6e:	048ab783          	ld	a5,72(s5)
    80001d72:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001d76:	058ab683          	ld	a3,88(s5)
    80001d7a:	87b6                	mv	a5,a3
    80001d7c:	0589b703          	ld	a4,88(s3)
    80001d80:	12068693          	addi	a3,a3,288
    80001d84:	6388                	ld	a0,0(a5)
    80001d86:	678c                	ld	a1,8(a5)
    80001d88:	6b90                	ld	a2,16(a5)
    80001d8a:	e308                	sd	a0,0(a4)
    80001d8c:	e70c                	sd	a1,8(a4)
    80001d8e:	eb10                	sd	a2,16(a4)
    80001d90:	6f90                	ld	a2,24(a5)
    80001d92:	ef10                	sd	a2,24(a4)
    80001d94:	02078793          	addi	a5,a5,32
    80001d98:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d9c:	fed794e3          	bne	a5,a3,80001d84 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001da0:	0589b783          	ld	a5,88(s3)
    80001da4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001da8:	0d0a8493          	addi	s1,s5,208
    80001dac:	0d098913          	addi	s2,s3,208
    80001db0:	150a8a13          	addi	s4,s5,336
    80001db4:	a831                	j	80001dd0 <kfork+0x96>
    freeproc(np);
    80001db6:	854e                	mv	a0,s3
    80001db8:	dc5ff0ef          	jal	80001b7c <freeproc>
    release(&np->lock);
    80001dbc:	854e                	mv	a0,s3
    80001dbe:	efffe0ef          	jal	80000cbc <release>
    return -1;
    80001dc2:	54fd                	li	s1,-1
    80001dc4:	69e2                	ld	s3,24(sp)
    80001dc6:	a079                	j	80001e54 <kfork+0x11a>
  for(i = 0; i < NOFILE; i++)
    80001dc8:	04a1                	addi	s1,s1,8
    80001dca:	0921                	addi	s2,s2,8
    80001dcc:	01448963          	beq	s1,s4,80001dde <kfork+0xa4>
    if(p->ofile[i])
    80001dd0:	6088                	ld	a0,0(s1)
    80001dd2:	d97d                	beqz	a0,80001dc8 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001dd4:	550020ef          	jal	80004324 <filedup>
    80001dd8:	00a93023          	sd	a0,0(s2)
    80001ddc:	b7f5                	j	80001dc8 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001dde:	150ab503          	ld	a0,336(s5)
    80001de2:	722010ef          	jal	80003504 <idup>
    80001de6:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dea:	4641                	li	a2,16
    80001dec:	158a8593          	addi	a1,s5,344
    80001df0:	15898513          	addi	a0,s3,344
    80001df4:	858ff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001df8:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001dfc:	854e                	mv	a0,s3
    80001dfe:	ebffe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001e02:	0000e517          	auipc	a0,0xe
    80001e06:	bee50513          	addi	a0,a0,-1042 # 8000f9f0 <wait_lock>
    80001e0a:	e1ffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001e0e:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e12:	0000e517          	auipc	a0,0xe
    80001e16:	bde50513          	addi	a0,a0,-1058 # 8000f9f0 <wait_lock>
    80001e1a:	ea3fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001e1e:	854e                	mv	a0,s3
    80001e20:	e09fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e24:	478d                	li	a5,3
    80001e26:	00f9ac23          	sw	a5,24(s3)
  acquire(&mlfq_lock);
    80001e2a:	0000e517          	auipc	a0,0xe
    80001e2e:	bde50513          	addi	a0,a0,-1058 # 8000fa08 <mlfq_lock>
    80001e32:	df7fe0ef          	jal	80000c28 <acquire>
  mlfq_enqueue(np);
    80001e36:	854e                	mv	a0,s3
    80001e38:	969ff0ef          	jal	800017a0 <mlfq_enqueue>
  release(&mlfq_lock);
    80001e3c:	0000e517          	auipc	a0,0xe
    80001e40:	bcc50513          	addi	a0,a0,-1076 # 8000fa08 <mlfq_lock>
    80001e44:	e79fe0ef          	jal	80000cbc <release>
  release(&np->lock);
    80001e48:	854e                	mv	a0,s3
    80001e4a:	e73fe0ef          	jal	80000cbc <release>
  return pid;
    80001e4e:	7902                	ld	s2,32(sp)
    80001e50:	69e2                	ld	s3,24(sp)
    80001e52:	6a42                	ld	s4,16(sp)
}
    80001e54:	8526                	mv	a0,s1
    80001e56:	70e2                	ld	ra,56(sp)
    80001e58:	7442                	ld	s0,48(sp)
    80001e5a:	74a2                	ld	s1,40(sp)
    80001e5c:	6aa2                	ld	s5,8(sp)
    80001e5e:	6121                	addi	sp,sp,64
    80001e60:	8082                	ret
    return -1;
    80001e62:	54fd                	li	s1,-1
    80001e64:	bfc5                	j	80001e54 <kfork+0x11a>

0000000080001e66 <boost_all_priorities>:
{
    80001e66:	7179                	addi	sp,sp,-48
    80001e68:	f406                	sd	ra,40(sp)
    80001e6a:	f022                	sd	s0,32(sp)
    80001e6c:	ec26                	sd	s1,24(sp)
    80001e6e:	e84a                	sd	s2,16(sp)
    80001e70:	e44e                	sd	s3,8(sp)
    80001e72:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e74:	0000e497          	auipc	s1,0xe
    80001e78:	fac48493          	addi	s1,s1,-84 # 8000fe20 <proc>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001e7c:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e7e:	00014917          	auipc	s2,0x14
    80001e82:	da290913          	addi	s2,s2,-606 # 80015c20 <tickslock>
    80001e86:	a801                	j	80001e96 <boost_all_priorities+0x30>
    release(&p->lock);
    80001e88:	8526                	mv	a0,s1
    80001e8a:	e33fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e8e:	17848493          	addi	s1,s1,376
    80001e92:	03248063          	beq	s1,s2,80001eb2 <boost_all_priorities+0x4c>
    acquire(&p->lock);
    80001e96:	8526                	mv	a0,s1
    80001e98:	d91fe0ef          	jal	80000c28 <acquire>
    if(p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) {
    80001e9c:	4c9c                	lw	a5,24(s1)
    80001e9e:	37f9                	addiw	a5,a5,-2
    80001ea0:	fef9e4e3          	bltu	s3,a5,80001e88 <boost_all_priorities+0x22>
      p->priority = 0;
    80001ea4:	1604a423          	sw	zero,360(s1)
      p->time_slices = 0;
    80001ea8:	1604a623          	sw	zero,364(s1)
      p->queue_next = 0;
    80001eac:	1604b823          	sd	zero,368(s1)
    80001eb0:	bfe1                	j	80001e88 <boost_all_priorities+0x22>
  acquire(&mlfq_lock);
    80001eb2:	0000e497          	auipc	s1,0xe
    80001eb6:	ae648493          	addi	s1,s1,-1306 # 8000f998 <mlfq_tails>
    80001eba:	0000e517          	auipc	a0,0xe
    80001ebe:	b4e50513          	addi	a0,a0,-1202 # 8000fa08 <mlfq_lock>
    80001ec2:	d67fe0ef          	jal	80000c28 <acquire>
    mlfq_heads[i] = 0;
    80001ec6:	0204b023          	sd	zero,32(s1)
    mlfq_tails[i] = 0;
    80001eca:	0004b023          	sd	zero,0(s1)
    mlfq_heads[i] = 0;
    80001ece:	0204b423          	sd	zero,40(s1)
    mlfq_tails[i] = 0;
    80001ed2:	0004b423          	sd	zero,8(s1)
    mlfq_heads[i] = 0;
    80001ed6:	0204b823          	sd	zero,48(s1)
    mlfq_tails[i] = 0;
    80001eda:	0004b823          	sd	zero,16(s1)
    mlfq_heads[i] = 0;
    80001ede:	0204bc23          	sd	zero,56(s1)
    mlfq_tails[i] = 0;
    80001ee2:	0004bc23          	sd	zero,24(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ee6:	0000e497          	auipc	s1,0xe
    80001eea:	f3a48493          	addi	s1,s1,-198 # 8000fe20 <proc>
    if(p->state == RUNNABLE) {
    80001eee:	498d                	li	s3,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ef0:	00014917          	auipc	s2,0x14
    80001ef4:	d3090913          	addi	s2,s2,-720 # 80015c20 <tickslock>
    80001ef8:	a801                	j	80001f08 <boost_all_priorities+0xa2>
    release(&p->lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	dc1fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f00:	17848493          	addi	s1,s1,376
    80001f04:	01248e63          	beq	s1,s2,80001f20 <boost_all_priorities+0xba>
    acquire(&p->lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	d1ffe0ef          	jal	80000c28 <acquire>
    if(p->state == RUNNABLE) {
    80001f0e:	4c9c                	lw	a5,24(s1)
    80001f10:	ff3795e3          	bne	a5,s3,80001efa <boost_all_priorities+0x94>
      p->queue_next = 0;
    80001f14:	1604b823          	sd	zero,368(s1)
      mlfq_enqueue(p);
    80001f18:	8526                	mv	a0,s1
    80001f1a:	887ff0ef          	jal	800017a0 <mlfq_enqueue>
    80001f1e:	bff1                	j	80001efa <boost_all_priorities+0x94>
  release(&mlfq_lock);
    80001f20:	0000e517          	auipc	a0,0xe
    80001f24:	ae850513          	addi	a0,a0,-1304 # 8000fa08 <mlfq_lock>
    80001f28:	d95fe0ef          	jal	80000cbc <release>
}
    80001f2c:	70a2                	ld	ra,40(sp)
    80001f2e:	7402                	ld	s0,32(sp)
    80001f30:	64e2                	ld	s1,24(sp)
    80001f32:	6942                	ld	s2,16(sp)
    80001f34:	69a2                	ld	s3,8(sp)
    80001f36:	6145                	addi	sp,sp,48
    80001f38:	8082                	ret

0000000080001f3a <scheduler>:
{
    80001f3a:	711d                	addi	sp,sp,-96
    80001f3c:	ec86                	sd	ra,88(sp)
    80001f3e:	e8a2                	sd	s0,80(sp)
    80001f40:	e4a6                	sd	s1,72(sp)
    80001f42:	e0ca                	sd	s2,64(sp)
    80001f44:	fc4e                	sd	s3,56(sp)
    80001f46:	f852                	sd	s4,48(sp)
    80001f48:	f456                	sd	s5,40(sp)
    80001f4a:	f05a                	sd	s6,32(sp)
    80001f4c:	ec5e                	sd	s7,24(sp)
    80001f4e:	e862                	sd	s8,16(sp)
    80001f50:	e466                	sd	s9,8(sp)
    80001f52:	e06a                	sd	s10,0(sp)
    80001f54:	1080                	addi	s0,sp,96
    80001f56:	8c12                	mv	s8,tp
  int id = r_tp();
    80001f58:	2c01                	sext.w	s8,s8
  c->proc = 0;
    80001f5a:	007c1713          	slli	a4,s8,0x7
    80001f5e:	0000e797          	auipc	a5,0xe
    80001f62:	a3a78793          	addi	a5,a5,-1478 # 8000f998 <mlfq_tails>
    80001f66:	97ba                	add	a5,a5,a4
    80001f68:	0807b423          	sd	zero,136(a5)
    acquire(&mlfq_lock);
    80001f6c:	0000e917          	auipc	s2,0xe
    80001f70:	a9c90913          	addi	s2,s2,-1380 # 8000fa08 <mlfq_lock>
    for(int priority = 0; priority < NMLFQ; priority++) {
    80001f74:	4991                	li	s3,4
          c->proc = p;
    80001f76:	8c3a                	mv	s8,a4
          swtch(&c->context, &p->context);
    80001f78:	0000ec97          	auipc	s9,0xe
    80001f7c:	ab0c8c93          	addi	s9,s9,-1360 # 8000fa28 <cpus+0x8>
    80001f80:	9cba                	add	s9,s9,a4
    80001f82:	a0a9                	j	80001fcc <scheduler+0x92>
      release(&tickslock);
    80001f84:	8552                	mv	a0,s4
    80001f86:	d37fe0ef          	jal	80000cbc <release>
    80001f8a:	a0c5                	j	8000206a <scheduler+0x130>
    mlfq_tails[priority] = 0;
    80001f8c:	0000e717          	auipc	a4,0xe
    80001f90:	a0c70713          	addi	a4,a4,-1524 # 8000f998 <mlfq_tails>
    80001f94:	00c707b3          	add	a5,a4,a2
    80001f98:	0007b023          	sd	zero,0(a5)
    80001f9c:	a885                	j	8000200c <scheduler+0xd2>
          p->state = RUNNING;
    80001f9e:	0134ac23          	sw	s3,24(s1)
          c->proc = p;
    80001fa2:	0000ed17          	auipc	s10,0xe
    80001fa6:	9f6d0d13          	addi	s10,s10,-1546 # 8000f998 <mlfq_tails>
    80001faa:	9d62                	add	s10,s10,s8
    80001fac:	089d3423          	sd	s1,136(s10)
          swtch(&c->context, &p->context);
    80001fb0:	06048593          	addi	a1,s1,96
    80001fb4:	8566                	mv	a0,s9
    80001fb6:	69a000ef          	jal	80002650 <swtch>
          c->proc = 0;
    80001fba:	080d3423          	sd	zero,136(s10)
          found = 1;
    80001fbe:	4d05                	li	s10,1
    80001fc0:	a09d                	j	80002026 <scheduler+0xec>
      release(&mlfq_lock);
    80001fc2:	854a                	mv	a0,s2
    80001fc4:	cf9fe0ef          	jal	80000cbc <release>
      asm volatile("wfi");
    80001fc8:	10500073          	wfi
    acquire(&tickslock);
    80001fcc:	00014a17          	auipc	s4,0x14
    80001fd0:	c54a0a13          	addi	s4,s4,-940 # 80015c20 <tickslock>
    uint64 current_ticks = ticks;
    80001fd4:	00006b97          	auipc	s7,0x6
    80001fd8:	8bcb8b93          	addi	s7,s7,-1860 # 80007890 <ticks>
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80001fdc:	00006a97          	auipc	s5,0x6
    80001fe0:	8a4a8a93          	addi	s5,s5,-1884 # 80007880 <last_boost_time>
    80001fe4:	03100b13          	li	s6,49
    80001fe8:	a0a1                	j	80002030 <scheduler+0xf6>
    for(int priority = 0; priority < NMLFQ; priority++) {
    80001fea:	2785                	addiw	a5,a5,1
    80001fec:	0721                	addi	a4,a4,8
    80001fee:	fd378ae3          	beq	a5,s3,80001fc2 <scheduler+0x88>
  struct proc *p = mlfq_heads[priority];
    80001ff2:	6304                	ld	s1,0(a4)
  if(p == 0)
    80001ff4:	d8fd                	beqz	s1,80001fea <scheduler+0xb0>
  mlfq_heads[priority] = p->queue_next;
    80001ff6:	1704b683          	ld	a3,368(s1)
    80001ffa:	00379613          	slli	a2,a5,0x3
    80001ffe:	0000e717          	auipc	a4,0xe
    80002002:	99a70713          	addi	a4,a4,-1638 # 8000f998 <mlfq_tails>
    80002006:	9732                	add	a4,a4,a2
    80002008:	f314                	sd	a3,32(a4)
  if(mlfq_heads[priority] == 0) {
    8000200a:	d2c9                	beqz	a3,80001f8c <scheduler+0x52>
  p->queue_next = 0;
    8000200c:	1604b823          	sd	zero,368(s1)
        release(&mlfq_lock);
    80002010:	854a                	mv	a0,s2
    80002012:	cabfe0ef          	jal	80000cbc <release>
        acquire(&p->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	c11fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE) {
    8000201c:	4c98                	lw	a4,24(s1)
    8000201e:	478d                	li	a5,3
    int found = 0;
    80002020:	4d01                	li	s10,0
        if(p->state == RUNNABLE) {
    80002022:	f6f70ee3          	beq	a4,a5,80001f9e <scheduler+0x64>
        release(&p->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	c95fe0ef          	jal	80000cbc <release>
    if(!found) {
    8000202c:	f80d0be3          	beqz	s10,80001fc2 <scheduler+0x88>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002030:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002038:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002040:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002042:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80002046:	8552                	mv	a0,s4
    80002048:	be1fe0ef          	jal	80000c28 <acquire>
    uint64 current_ticks = ticks;
    8000204c:	000be703          	lwu	a4,0(s7)
    if(current_ticks - last_boost_time >= BOOST_INTERVAL) {
    80002050:	000ab783          	ld	a5,0(s5)
    80002054:	40f707b3          	sub	a5,a4,a5
    80002058:	f2fb76e3          	bgeu	s6,a5,80001f84 <scheduler+0x4a>
      last_boost_time = current_ticks;
    8000205c:	00eab023          	sd	a4,0(s5)
      release(&tickslock);
    80002060:	8552                	mv	a0,s4
    80002062:	c5bfe0ef          	jal	80000cbc <release>
      boost_all_priorities();
    80002066:	e01ff0ef          	jal	80001e66 <boost_all_priorities>
    acquire(&mlfq_lock);
    8000206a:	854a                	mv	a0,s2
    8000206c:	bbdfe0ef          	jal	80000c28 <acquire>
    for(int priority = 0; priority < NMLFQ; priority++) {
    80002070:	0000e717          	auipc	a4,0xe
    80002074:	94870713          	addi	a4,a4,-1720 # 8000f9b8 <mlfq_heads>
    80002078:	4781                	li	a5,0
    8000207a:	bfa5                	j	80001ff2 <scheduler+0xb8>

000000008000207c <sched>:
{
    8000207c:	7179                	addi	sp,sp,-48
    8000207e:	f406                	sd	ra,40(sp)
    80002080:	f022                	sd	s0,32(sp)
    80002082:	ec26                	sd	s1,24(sp)
    80002084:	e84a                	sd	s2,16(sp)
    80002086:	e44e                	sd	s3,8(sp)
    80002088:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000208a:	91fff0ef          	jal	800019a8 <myproc>
    8000208e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002090:	b29fe0ef          	jal	80000bb8 <holding>
    80002094:	c935                	beqz	a0,80002108 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002096:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002098:	2781                	sext.w	a5,a5
    8000209a:	079e                	slli	a5,a5,0x7
    8000209c:	0000e717          	auipc	a4,0xe
    800020a0:	8fc70713          	addi	a4,a4,-1796 # 8000f998 <mlfq_tails>
    800020a4:	97ba                	add	a5,a5,a4
    800020a6:	1007a703          	lw	a4,256(a5)
    800020aa:	4785                	li	a5,1
    800020ac:	06f71463          	bne	a4,a5,80002114 <sched+0x98>
  if(p->state == RUNNING)
    800020b0:	4c98                	lw	a4,24(s1)
    800020b2:	4791                	li	a5,4
    800020b4:	06f70663          	beq	a4,a5,80002120 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020b8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020bc:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020be:	e7bd                	bnez	a5,8000212c <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020c0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020c2:	0000e917          	auipc	s2,0xe
    800020c6:	8d690913          	addi	s2,s2,-1834 # 8000f998 <mlfq_tails>
    800020ca:	2781                	sext.w	a5,a5
    800020cc:	079e                	slli	a5,a5,0x7
    800020ce:	97ca                	add	a5,a5,s2
    800020d0:	1047a983          	lw	s3,260(a5)
    800020d4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020d6:	2781                	sext.w	a5,a5
    800020d8:	079e                	slli	a5,a5,0x7
    800020da:	07a1                	addi	a5,a5,8
    800020dc:	0000e597          	auipc	a1,0xe
    800020e0:	94458593          	addi	a1,a1,-1724 # 8000fa20 <cpus>
    800020e4:	95be                	add	a1,a1,a5
    800020e6:	06048513          	addi	a0,s1,96
    800020ea:	566000ef          	jal	80002650 <swtch>
    800020ee:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020f0:	2781                	sext.w	a5,a5
    800020f2:	079e                	slli	a5,a5,0x7
    800020f4:	993e                	add	s2,s2,a5
    800020f6:	11392223          	sw	s3,260(s2)
}
    800020fa:	70a2                	ld	ra,40(sp)
    800020fc:	7402                	ld	s0,32(sp)
    800020fe:	64e2                	ld	s1,24(sp)
    80002100:	6942                	ld	s2,16(sp)
    80002102:	69a2                	ld	s3,8(sp)
    80002104:	6145                	addi	sp,sp,48
    80002106:	8082                	ret
    panic("sched p->lock");
    80002108:	00005517          	auipc	a0,0x5
    8000210c:	09850513          	addi	a0,a0,152 # 800071a0 <etext+0x1a0>
    80002110:	f14fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80002114:	00005517          	auipc	a0,0x5
    80002118:	09c50513          	addi	a0,a0,156 # 800071b0 <etext+0x1b0>
    8000211c:	f08fe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80002120:	00005517          	auipc	a0,0x5
    80002124:	0a050513          	addi	a0,a0,160 # 800071c0 <etext+0x1c0>
    80002128:	efcfe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    8000212c:	00005517          	auipc	a0,0x5
    80002130:	0a450513          	addi	a0,a0,164 # 800071d0 <etext+0x1d0>
    80002134:	ef0fe0ef          	jal	80000824 <panic>

0000000080002138 <yield>:
{
    80002138:	1101                	addi	sp,sp,-32
    8000213a:	ec06                	sd	ra,24(sp)
    8000213c:	e822                	sd	s0,16(sp)
    8000213e:	e426                	sd	s1,8(sp)
    80002140:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002142:	867ff0ef          	jal	800019a8 <myproc>
    80002146:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002148:	ae1fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    8000214c:	478d                	li	a5,3
    8000214e:	cc9c                	sw	a5,24(s1)
  acquire(&mlfq_lock);
    80002150:	0000e517          	auipc	a0,0xe
    80002154:	8b850513          	addi	a0,a0,-1864 # 8000fa08 <mlfq_lock>
    80002158:	ad1fe0ef          	jal	80000c28 <acquire>
  mlfq_enqueue(p);
    8000215c:	8526                	mv	a0,s1
    8000215e:	e42ff0ef          	jal	800017a0 <mlfq_enqueue>
  release(&mlfq_lock);
    80002162:	0000e517          	auipc	a0,0xe
    80002166:	8a650513          	addi	a0,a0,-1882 # 8000fa08 <mlfq_lock>
    8000216a:	b53fe0ef          	jal	80000cbc <release>
  sched();
    8000216e:	f0fff0ef          	jal	8000207c <sched>
  release(&p->lock);
    80002172:	8526                	mv	a0,s1
    80002174:	b49fe0ef          	jal	80000cbc <release>
}
    80002178:	60e2                	ld	ra,24(sp)
    8000217a:	6442                	ld	s0,16(sp)
    8000217c:	64a2                	ld	s1,8(sp)
    8000217e:	6105                	addi	sp,sp,32
    80002180:	8082                	ret

0000000080002182 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002182:	7179                	addi	sp,sp,-48
    80002184:	f406                	sd	ra,40(sp)
    80002186:	f022                	sd	s0,32(sp)
    80002188:	ec26                	sd	s1,24(sp)
    8000218a:	e84a                	sd	s2,16(sp)
    8000218c:	e44e                	sd	s3,8(sp)
    8000218e:	1800                	addi	s0,sp,48
    80002190:	89aa                	mv	s3,a0
    80002192:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002194:	815ff0ef          	jal	800019a8 <myproc>
    80002198:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000219a:	a8ffe0ef          	jal	80000c28 <acquire>
  release(lk);
    8000219e:	854a                	mv	a0,s2
    800021a0:	b1dfe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    800021a4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021a8:	4789                	li	a5,2
    800021aa:	cc9c                	sw	a5,24(s1)

  sched();
    800021ac:	ed1ff0ef          	jal	8000207c <sched>

  // Tidy up.
  p->chan = 0;
    800021b0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	b07fe0ef          	jal	80000cbc <release>
  acquire(lk);
    800021ba:	854a                	mv	a0,s2
    800021bc:	a6dfe0ef          	jal	80000c28 <acquire>
}
    800021c0:	70a2                	ld	ra,40(sp)
    800021c2:	7402                	ld	s0,32(sp)
    800021c4:	64e2                	ld	s1,24(sp)
    800021c6:	6942                	ld	s2,16(sp)
    800021c8:	69a2                	ld	s3,8(sp)
    800021ca:	6145                	addi	sp,sp,48
    800021cc:	8082                	ret

00000000800021ce <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800021ce:	7139                	addi	sp,sp,-64
    800021d0:	fc06                	sd	ra,56(sp)
    800021d2:	f822                	sd	s0,48(sp)
    800021d4:	f426                	sd	s1,40(sp)
    800021d6:	f04a                	sd	s2,32(sp)
    800021d8:	ec4e                	sd	s3,24(sp)
    800021da:	e852                	sd	s4,16(sp)
    800021dc:	e456                	sd	s5,8(sp)
    800021de:	e05a                	sd	s6,0(sp)
    800021e0:	0080                	addi	s0,sp,64
    800021e2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021e4:	0000e497          	auipc	s1,0xe
    800021e8:	c3c48493          	addi	s1,s1,-964 # 8000fe20 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021ec:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021ee:	4b0d                	li	s6,3
        
        // Enqueue to MLFQ
        acquire(&mlfq_lock);
    800021f0:	0000ea97          	auipc	s5,0xe
    800021f4:	818a8a93          	addi	s5,s5,-2024 # 8000fa08 <mlfq_lock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021f8:	00014917          	auipc	s2,0x14
    800021fc:	a2890913          	addi	s2,s2,-1496 # 80015c20 <tickslock>
    80002200:	a801                	j	80002210 <wakeup+0x42>
        mlfq_enqueue(p);
        release(&mlfq_lock);
      }
      release(&p->lock);
    80002202:	8526                	mv	a0,s1
    80002204:	ab9fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002208:	17848493          	addi	s1,s1,376
    8000220c:	03248b63          	beq	s1,s2,80002242 <wakeup+0x74>
    if(p != myproc()){
    80002210:	f98ff0ef          	jal	800019a8 <myproc>
    80002214:	fe950ae3          	beq	a0,s1,80002208 <wakeup+0x3a>
      acquire(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	a0ffe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000221e:	4c9c                	lw	a5,24(s1)
    80002220:	ff3791e3          	bne	a5,s3,80002202 <wakeup+0x34>
    80002224:	709c                	ld	a5,32(s1)
    80002226:	fd479ee3          	bne	a5,s4,80002202 <wakeup+0x34>
        p->state = RUNNABLE;
    8000222a:	0164ac23          	sw	s6,24(s1)
        acquire(&mlfq_lock);
    8000222e:	8556                	mv	a0,s5
    80002230:	9f9fe0ef          	jal	80000c28 <acquire>
        mlfq_enqueue(p);
    80002234:	8526                	mv	a0,s1
    80002236:	d6aff0ef          	jal	800017a0 <mlfq_enqueue>
        release(&mlfq_lock);
    8000223a:	8556                	mv	a0,s5
    8000223c:	a81fe0ef          	jal	80000cbc <release>
    80002240:	b7c9                	j	80002202 <wakeup+0x34>
    }
  }
}
    80002242:	70e2                	ld	ra,56(sp)
    80002244:	7442                	ld	s0,48(sp)
    80002246:	74a2                	ld	s1,40(sp)
    80002248:	7902                	ld	s2,32(sp)
    8000224a:	69e2                	ld	s3,24(sp)
    8000224c:	6a42                	ld	s4,16(sp)
    8000224e:	6aa2                	ld	s5,8(sp)
    80002250:	6b02                	ld	s6,0(sp)
    80002252:	6121                	addi	sp,sp,64
    80002254:	8082                	ret

0000000080002256 <reparent>:
{
    80002256:	7179                	addi	sp,sp,-48
    80002258:	f406                	sd	ra,40(sp)
    8000225a:	f022                	sd	s0,32(sp)
    8000225c:	ec26                	sd	s1,24(sp)
    8000225e:	e84a                	sd	s2,16(sp)
    80002260:	e44e                	sd	s3,8(sp)
    80002262:	e052                	sd	s4,0(sp)
    80002264:	1800                	addi	s0,sp,48
    80002266:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002268:	0000e497          	auipc	s1,0xe
    8000226c:	bb848493          	addi	s1,s1,-1096 # 8000fe20 <proc>
      pp->parent = initproc;
    80002270:	00005a17          	auipc	s4,0x5
    80002274:	618a0a13          	addi	s4,s4,1560 # 80007888 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002278:	00014997          	auipc	s3,0x14
    8000227c:	9a898993          	addi	s3,s3,-1624 # 80015c20 <tickslock>
    80002280:	a029                	j	8000228a <reparent+0x34>
    80002282:	17848493          	addi	s1,s1,376
    80002286:	01348b63          	beq	s1,s3,8000229c <reparent+0x46>
    if(pp->parent == p){
    8000228a:	7c9c                	ld	a5,56(s1)
    8000228c:	ff279be3          	bne	a5,s2,80002282 <reparent+0x2c>
      pp->parent = initproc;
    80002290:	000a3503          	ld	a0,0(s4)
    80002294:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002296:	f39ff0ef          	jal	800021ce <wakeup>
    8000229a:	b7e5                	j	80002282 <reparent+0x2c>
}
    8000229c:	70a2                	ld	ra,40(sp)
    8000229e:	7402                	ld	s0,32(sp)
    800022a0:	64e2                	ld	s1,24(sp)
    800022a2:	6942                	ld	s2,16(sp)
    800022a4:	69a2                	ld	s3,8(sp)
    800022a6:	6a02                	ld	s4,0(sp)
    800022a8:	6145                	addi	sp,sp,48
    800022aa:	8082                	ret

00000000800022ac <kexit>:
{
    800022ac:	7179                	addi	sp,sp,-48
    800022ae:	f406                	sd	ra,40(sp)
    800022b0:	f022                	sd	s0,32(sp)
    800022b2:	ec26                	sd	s1,24(sp)
    800022b4:	e84a                	sd	s2,16(sp)
    800022b6:	e44e                	sd	s3,8(sp)
    800022b8:	e052                	sd	s4,0(sp)
    800022ba:	1800                	addi	s0,sp,48
    800022bc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022be:	eeaff0ef          	jal	800019a8 <myproc>
    800022c2:	89aa                	mv	s3,a0
  if(p == initproc)
    800022c4:	00005797          	auipc	a5,0x5
    800022c8:	5c47b783          	ld	a5,1476(a5) # 80007888 <initproc>
    800022cc:	0d050493          	addi	s1,a0,208
    800022d0:	15050913          	addi	s2,a0,336
    800022d4:	00a79b63          	bne	a5,a0,800022ea <kexit+0x3e>
    panic("init exiting");
    800022d8:	00005517          	auipc	a0,0x5
    800022dc:	f1050513          	addi	a0,a0,-240 # 800071e8 <etext+0x1e8>
    800022e0:	d44fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800022e4:	04a1                	addi	s1,s1,8
    800022e6:	01248963          	beq	s1,s2,800022f8 <kexit+0x4c>
    if(p->ofile[fd]){
    800022ea:	6088                	ld	a0,0(s1)
    800022ec:	dd65                	beqz	a0,800022e4 <kexit+0x38>
      fileclose(f);
    800022ee:	07c020ef          	jal	8000436a <fileclose>
      p->ofile[fd] = 0;
    800022f2:	0004b023          	sd	zero,0(s1)
    800022f6:	b7fd                	j	800022e4 <kexit+0x38>
  begin_op();
    800022f8:	44f010ef          	jal	80003f46 <begin_op>
  iput(p->cwd);
    800022fc:	1509b503          	ld	a0,336(s3)
    80002300:	3bc010ef          	jal	800036bc <iput>
  end_op();
    80002304:	4b3010ef          	jal	80003fb6 <end_op>
  p->cwd = 0;
    80002308:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000230c:	0000d517          	auipc	a0,0xd
    80002310:	6e450513          	addi	a0,a0,1764 # 8000f9f0 <wait_lock>
    80002314:	915fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002318:	854e                	mv	a0,s3
    8000231a:	f3dff0ef          	jal	80002256 <reparent>
  wakeup(p->parent);
    8000231e:	0389b503          	ld	a0,56(s3)
    80002322:	eadff0ef          	jal	800021ce <wakeup>
  acquire(&p->lock);
    80002326:	854e                	mv	a0,s3
    80002328:	901fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000232c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002330:	4795                	li	a5,5
    80002332:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002336:	0000d517          	auipc	a0,0xd
    8000233a:	6ba50513          	addi	a0,a0,1722 # 8000f9f0 <wait_lock>
    8000233e:	97ffe0ef          	jal	80000cbc <release>
  sched();
    80002342:	d3bff0ef          	jal	8000207c <sched>
  panic("zombie exit");
    80002346:	00005517          	auipc	a0,0x5
    8000234a:	eb250513          	addi	a0,a0,-334 # 800071f8 <etext+0x1f8>
    8000234e:	cd6fe0ef          	jal	80000824 <panic>

0000000080002352 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002352:	7179                	addi	sp,sp,-48
    80002354:	f406                	sd	ra,40(sp)
    80002356:	f022                	sd	s0,32(sp)
    80002358:	ec26                	sd	s1,24(sp)
    8000235a:	e84a                	sd	s2,16(sp)
    8000235c:	e44e                	sd	s3,8(sp)
    8000235e:	1800                	addi	s0,sp,48
    80002360:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002362:	0000e497          	auipc	s1,0xe
    80002366:	abe48493          	addi	s1,s1,-1346 # 8000fe20 <proc>
    8000236a:	00014997          	auipc	s3,0x14
    8000236e:	8b698993          	addi	s3,s3,-1866 # 80015c20 <tickslock>
    acquire(&p->lock);
    80002372:	8526                	mv	a0,s1
    80002374:	8b5fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002378:	589c                	lw	a5,48(s1)
    8000237a:	01278b63          	beq	a5,s2,80002390 <kkill+0x3e>
        release(&mlfq_lock);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000237e:	8526                	mv	a0,s1
    80002380:	93dfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002384:	17848493          	addi	s1,s1,376
    80002388:	ff3495e3          	bne	s1,s3,80002372 <kkill+0x20>
  }
  return -1;
    8000238c:	557d                	li	a0,-1
    8000238e:	a819                	j	800023a4 <kkill+0x52>
      p->killed = 1;
    80002390:	4785                	li	a5,1
    80002392:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002394:	4c98                	lw	a4,24(s1)
    80002396:	4789                	li	a5,2
    80002398:	00f70d63          	beq	a4,a5,800023b2 <kkill+0x60>
      release(&p->lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	91ffe0ef          	jal	80000cbc <release>
      return 0;
    800023a2:	4501                	li	a0,0
}
    800023a4:	70a2                	ld	ra,40(sp)
    800023a6:	7402                	ld	s0,32(sp)
    800023a8:	64e2                	ld	s1,24(sp)
    800023aa:	6942                	ld	s2,16(sp)
    800023ac:	69a2                	ld	s3,8(sp)
    800023ae:	6145                	addi	sp,sp,48
    800023b0:	8082                	ret
        p->state = RUNNABLE;
    800023b2:	478d                	li	a5,3
    800023b4:	cc9c                	sw	a5,24(s1)
        acquire(&mlfq_lock);
    800023b6:	0000d517          	auipc	a0,0xd
    800023ba:	65250513          	addi	a0,a0,1618 # 8000fa08 <mlfq_lock>
    800023be:	86bfe0ef          	jal	80000c28 <acquire>
        mlfq_enqueue(p);
    800023c2:	8526                	mv	a0,s1
    800023c4:	bdcff0ef          	jal	800017a0 <mlfq_enqueue>
        release(&mlfq_lock);
    800023c8:	0000d517          	auipc	a0,0xd
    800023cc:	64050513          	addi	a0,a0,1600 # 8000fa08 <mlfq_lock>
    800023d0:	8edfe0ef          	jal	80000cbc <release>
    800023d4:	b7e1                	j	8000239c <kkill+0x4a>

00000000800023d6 <setkilled>:

void
setkilled(struct proc *p)
{
    800023d6:	1101                	addi	sp,sp,-32
    800023d8:	ec06                	sd	ra,24(sp)
    800023da:	e822                	sd	s0,16(sp)
    800023dc:	e426                	sd	s1,8(sp)
    800023de:	1000                	addi	s0,sp,32
    800023e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023e2:	847fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800023e6:	4785                	li	a5,1
    800023e8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	8d1fe0ef          	jal	80000cbc <release>
}
    800023f0:	60e2                	ld	ra,24(sp)
    800023f2:	6442                	ld	s0,16(sp)
    800023f4:	64a2                	ld	s1,8(sp)
    800023f6:	6105                	addi	sp,sp,32
    800023f8:	8082                	ret

00000000800023fa <killed>:

int
killed(struct proc *p)
{
    800023fa:	1101                	addi	sp,sp,-32
    800023fc:	ec06                	sd	ra,24(sp)
    800023fe:	e822                	sd	s0,16(sp)
    80002400:	e426                	sd	s1,8(sp)
    80002402:	e04a                	sd	s2,0(sp)
    80002404:	1000                	addi	s0,sp,32
    80002406:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002408:	821fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    8000240c:	549c                	lw	a5,40(s1)
    8000240e:	893e                	mv	s2,a5
  release(&p->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	8abfe0ef          	jal	80000cbc <release>
  return k;
}
    80002416:	854a                	mv	a0,s2
    80002418:	60e2                	ld	ra,24(sp)
    8000241a:	6442                	ld	s0,16(sp)
    8000241c:	64a2                	ld	s1,8(sp)
    8000241e:	6902                	ld	s2,0(sp)
    80002420:	6105                	addi	sp,sp,32
    80002422:	8082                	ret

0000000080002424 <kwait>:
{
    80002424:	715d                	addi	sp,sp,-80
    80002426:	e486                	sd	ra,72(sp)
    80002428:	e0a2                	sd	s0,64(sp)
    8000242a:	fc26                	sd	s1,56(sp)
    8000242c:	f84a                	sd	s2,48(sp)
    8000242e:	f44e                	sd	s3,40(sp)
    80002430:	f052                	sd	s4,32(sp)
    80002432:	ec56                	sd	s5,24(sp)
    80002434:	e85a                	sd	s6,16(sp)
    80002436:	e45e                	sd	s7,8(sp)
    80002438:	0880                	addi	s0,sp,80
    8000243a:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000243c:	d6cff0ef          	jal	800019a8 <myproc>
    80002440:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002442:	0000d517          	auipc	a0,0xd
    80002446:	5ae50513          	addi	a0,a0,1454 # 8000f9f0 <wait_lock>
    8000244a:	fdefe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    8000244e:	4a15                	li	s4,5
        havekids = 1;
    80002450:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002452:	00013997          	auipc	s3,0x13
    80002456:	7ce98993          	addi	s3,s3,1998 # 80015c20 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000245a:	0000db17          	auipc	s6,0xd
    8000245e:	596b0b13          	addi	s6,s6,1430 # 8000f9f0 <wait_lock>
    80002462:	a869                	j	800024fc <kwait+0xd8>
          pid = pp->pid;
    80002464:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002468:	000b8c63          	beqz	s7,80002480 <kwait+0x5c>
    8000246c:	4691                	li	a3,4
    8000246e:	02c48613          	addi	a2,s1,44
    80002472:	85de                	mv	a1,s7
    80002474:	05093503          	ld	a0,80(s2)
    80002478:	9dcff0ef          	jal	80001654 <copyout>
    8000247c:	02054a63          	bltz	a0,800024b0 <kwait+0x8c>
          freeproc(pp);
    80002480:	8526                	mv	a0,s1
    80002482:	efaff0ef          	jal	80001b7c <freeproc>
          release(&pp->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	835fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    8000248c:	0000d517          	auipc	a0,0xd
    80002490:	56450513          	addi	a0,a0,1380 # 8000f9f0 <wait_lock>
    80002494:	829fe0ef          	jal	80000cbc <release>
}
    80002498:	854e                	mv	a0,s3
    8000249a:	60a6                	ld	ra,72(sp)
    8000249c:	6406                	ld	s0,64(sp)
    8000249e:	74e2                	ld	s1,56(sp)
    800024a0:	7942                	ld	s2,48(sp)
    800024a2:	79a2                	ld	s3,40(sp)
    800024a4:	7a02                	ld	s4,32(sp)
    800024a6:	6ae2                	ld	s5,24(sp)
    800024a8:	6b42                	ld	s6,16(sp)
    800024aa:	6ba2                	ld	s7,8(sp)
    800024ac:	6161                	addi	sp,sp,80
    800024ae:	8082                	ret
            release(&pp->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	80bfe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    800024b6:	0000d517          	auipc	a0,0xd
    800024ba:	53a50513          	addi	a0,a0,1338 # 8000f9f0 <wait_lock>
    800024be:	ffefe0ef          	jal	80000cbc <release>
            return -1;
    800024c2:	59fd                	li	s3,-1
    800024c4:	bfd1                	j	80002498 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024c6:	17848493          	addi	s1,s1,376
    800024ca:	03348063          	beq	s1,s3,800024ea <kwait+0xc6>
      if(pp->parent == p){
    800024ce:	7c9c                	ld	a5,56(s1)
    800024d0:	ff279be3          	bne	a5,s2,800024c6 <kwait+0xa2>
        acquire(&pp->lock);
    800024d4:	8526                	mv	a0,s1
    800024d6:	f52fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800024da:	4c9c                	lw	a5,24(s1)
    800024dc:	f94784e3          	beq	a5,s4,80002464 <kwait+0x40>
        release(&pp->lock);
    800024e0:	8526                	mv	a0,s1
    800024e2:	fdafe0ef          	jal	80000cbc <release>
        havekids = 1;
    800024e6:	8756                	mv	a4,s5
    800024e8:	bff9                	j	800024c6 <kwait+0xa2>
    if(!havekids || killed(p)){
    800024ea:	cf19                	beqz	a4,80002508 <kwait+0xe4>
    800024ec:	854a                	mv	a0,s2
    800024ee:	f0dff0ef          	jal	800023fa <killed>
    800024f2:	e919                	bnez	a0,80002508 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024f4:	85da                	mv	a1,s6
    800024f6:	854a                	mv	a0,s2
    800024f8:	c8bff0ef          	jal	80002182 <sleep>
    havekids = 0;
    800024fc:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024fe:	0000e497          	auipc	s1,0xe
    80002502:	92248493          	addi	s1,s1,-1758 # 8000fe20 <proc>
    80002506:	b7e1                	j	800024ce <kwait+0xaa>
      release(&wait_lock);
    80002508:	0000d517          	auipc	a0,0xd
    8000250c:	4e850513          	addi	a0,a0,1256 # 8000f9f0 <wait_lock>
    80002510:	facfe0ef          	jal	80000cbc <release>
      return -1;
    80002514:	59fd                	li	s3,-1
    80002516:	b749                	j	80002498 <kwait+0x74>

0000000080002518 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002518:	7179                	addi	sp,sp,-48
    8000251a:	f406                	sd	ra,40(sp)
    8000251c:	f022                	sd	s0,32(sp)
    8000251e:	ec26                	sd	s1,24(sp)
    80002520:	e84a                	sd	s2,16(sp)
    80002522:	e44e                	sd	s3,8(sp)
    80002524:	e052                	sd	s4,0(sp)
    80002526:	1800                	addi	s0,sp,48
    80002528:	84aa                	mv	s1,a0
    8000252a:	8a2e                	mv	s4,a1
    8000252c:	89b2                	mv	s3,a2
    8000252e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002530:	c78ff0ef          	jal	800019a8 <myproc>
  if(user_dst){
    80002534:	cc99                	beqz	s1,80002552 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002536:	86ca                	mv	a3,s2
    80002538:	864e                	mv	a2,s3
    8000253a:	85d2                	mv	a1,s4
    8000253c:	6928                	ld	a0,80(a0)
    8000253e:	916ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002542:	70a2                	ld	ra,40(sp)
    80002544:	7402                	ld	s0,32(sp)
    80002546:	64e2                	ld	s1,24(sp)
    80002548:	6942                	ld	s2,16(sp)
    8000254a:	69a2                	ld	s3,8(sp)
    8000254c:	6a02                	ld	s4,0(sp)
    8000254e:	6145                	addi	sp,sp,48
    80002550:	8082                	ret
    memmove((char *)dst, src, len);
    80002552:	0009061b          	sext.w	a2,s2
    80002556:	85ce                	mv	a1,s3
    80002558:	8552                	mv	a0,s4
    8000255a:	ffefe0ef          	jal	80000d58 <memmove>
    return 0;
    8000255e:	8526                	mv	a0,s1
    80002560:	b7cd                	j	80002542 <either_copyout+0x2a>

0000000080002562 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002562:	7179                	addi	sp,sp,-48
    80002564:	f406                	sd	ra,40(sp)
    80002566:	f022                	sd	s0,32(sp)
    80002568:	ec26                	sd	s1,24(sp)
    8000256a:	e84a                	sd	s2,16(sp)
    8000256c:	e44e                	sd	s3,8(sp)
    8000256e:	e052                	sd	s4,0(sp)
    80002570:	1800                	addi	s0,sp,48
    80002572:	8a2a                	mv	s4,a0
    80002574:	84ae                	mv	s1,a1
    80002576:	89b2                	mv	s3,a2
    80002578:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000257a:	c2eff0ef          	jal	800019a8 <myproc>
  if(user_src){
    8000257e:	cc99                	beqz	s1,8000259c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002580:	86ca                	mv	a3,s2
    80002582:	864e                	mv	a2,s3
    80002584:	85d2                	mv	a1,s4
    80002586:	6928                	ld	a0,80(a0)
    80002588:	98aff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000258c:	70a2                	ld	ra,40(sp)
    8000258e:	7402                	ld	s0,32(sp)
    80002590:	64e2                	ld	s1,24(sp)
    80002592:	6942                	ld	s2,16(sp)
    80002594:	69a2                	ld	s3,8(sp)
    80002596:	6a02                	ld	s4,0(sp)
    80002598:	6145                	addi	sp,sp,48
    8000259a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000259c:	0009061b          	sext.w	a2,s2
    800025a0:	85ce                	mv	a1,s3
    800025a2:	8552                	mv	a0,s4
    800025a4:	fb4fe0ef          	jal	80000d58 <memmove>
    return 0;
    800025a8:	8526                	mv	a0,s1
    800025aa:	b7cd                	j	8000258c <either_copyin+0x2a>

00000000800025ac <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ac:	715d                	addi	sp,sp,-80
    800025ae:	e486                	sd	ra,72(sp)
    800025b0:	e0a2                	sd	s0,64(sp)
    800025b2:	fc26                	sd	s1,56(sp)
    800025b4:	f84a                	sd	s2,48(sp)
    800025b6:	f44e                	sd	s3,40(sp)
    800025b8:	f052                	sd	s4,32(sp)
    800025ba:	ec56                	sd	s5,24(sp)
    800025bc:	e85a                	sd	s6,16(sp)
    800025be:	e45e                	sd	s7,8(sp)
    800025c0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025c2:	00005517          	auipc	a0,0x5
    800025c6:	ab650513          	addi	a0,a0,-1354 # 80007078 <etext+0x78>
    800025ca:	f31fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ce:	0000e497          	auipc	s1,0xe
    800025d2:	9aa48493          	addi	s1,s1,-1622 # 8000ff78 <proc+0x158>
    800025d6:	00013917          	auipc	s2,0x13
    800025da:	7a290913          	addi	s2,s2,1954 # 80015d78 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025de:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025e0:	00005997          	auipc	s3,0x5
    800025e4:	c2898993          	addi	s3,s3,-984 # 80007208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    800025e8:	00005a97          	auipc	s5,0x5
    800025ec:	c28a8a93          	addi	s5,s5,-984 # 80007210 <etext+0x210>
    printf("\n");
    800025f0:	00005a17          	auipc	s4,0x5
    800025f4:	a88a0a13          	addi	s4,s4,-1400 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f8:	00005b97          	auipc	s7,0x5
    800025fc:	138b8b93          	addi	s7,s7,312 # 80007730 <states.0>
    80002600:	a829                	j	8000261a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002602:	ed86a583          	lw	a1,-296(a3)
    80002606:	8556                	mv	a0,s5
    80002608:	ef3fd0ef          	jal	800004fa <printf>
    printf("\n");
    8000260c:	8552                	mv	a0,s4
    8000260e:	eedfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002612:	17848493          	addi	s1,s1,376
    80002616:	03248263          	beq	s1,s2,8000263a <procdump+0x8e>
    if(p->state == UNUSED)
    8000261a:	86a6                	mv	a3,s1
    8000261c:	ec04a783          	lw	a5,-320(s1)
    80002620:	dbed                	beqz	a5,80002612 <procdump+0x66>
      state = "???";
    80002622:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002624:	fcfb6fe3          	bltu	s6,a5,80002602 <procdump+0x56>
    80002628:	02079713          	slli	a4,a5,0x20
    8000262c:	01d75793          	srli	a5,a4,0x1d
    80002630:	97de                	add	a5,a5,s7
    80002632:	6390                	ld	a2,0(a5)
    80002634:	f679                	bnez	a2,80002602 <procdump+0x56>
      state = "???";
    80002636:	864e                	mv	a2,s3
    80002638:	b7e9                	j	80002602 <procdump+0x56>
  }
}
    8000263a:	60a6                	ld	ra,72(sp)
    8000263c:	6406                	ld	s0,64(sp)
    8000263e:	74e2                	ld	s1,56(sp)
    80002640:	7942                	ld	s2,48(sp)
    80002642:	79a2                	ld	s3,40(sp)
    80002644:	7a02                	ld	s4,32(sp)
    80002646:	6ae2                	ld	s5,24(sp)
    80002648:	6b42                	ld	s6,16(sp)
    8000264a:	6ba2                	ld	s7,8(sp)
    8000264c:	6161                	addi	sp,sp,80
    8000264e:	8082                	ret

0000000080002650 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002650:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002654:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002658:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000265a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000265c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002660:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002664:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002668:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000266c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002670:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002674:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002678:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000267c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002680:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002684:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002688:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000268c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000268e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002690:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002694:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002698:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000269c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800026a0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800026a4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800026a8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800026ac:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800026b0:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800026b4:	0685bd83          	ld	s11,104(a1)
        
        ret
    800026b8:	8082                	ret

00000000800026ba <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026ba:	1141                	addi	sp,sp,-16
    800026bc:	e406                	sd	ra,8(sp)
    800026be:	e022                	sd	s0,0(sp)
    800026c0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026c2:	00005597          	auipc	a1,0x5
    800026c6:	b8e58593          	addi	a1,a1,-1138 # 80007250 <etext+0x250>
    800026ca:	00013517          	auipc	a0,0x13
    800026ce:	55650513          	addi	a0,a0,1366 # 80015c20 <tickslock>
    800026d2:	cccfe0ef          	jal	80000b9e <initlock>
}
    800026d6:	60a2                	ld	ra,8(sp)
    800026d8:	6402                	ld	s0,0(sp)
    800026da:	0141                	addi	sp,sp,16
    800026dc:	8082                	ret

00000000800026de <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026de:	1141                	addi	sp,sp,-16
    800026e0:	e406                	sd	ra,8(sp)
    800026e2:	e022                	sd	s0,0(sp)
    800026e4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026e6:	00003797          	auipc	a5,0x3
    800026ea:	04a78793          	addi	a5,a5,74 # 80005730 <kernelvec>
    800026ee:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026f2:	60a2                	ld	ra,8(sp)
    800026f4:	6402                	ld	s0,0(sp)
    800026f6:	0141                	addi	sp,sp,16
    800026f8:	8082                	ret

00000000800026fa <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800026fa:	1141                	addi	sp,sp,-16
    800026fc:	e406                	sd	ra,8(sp)
    800026fe:	e022                	sd	s0,0(sp)
    80002700:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002702:	aa6ff0ef          	jal	800019a8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002706:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000270a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000270c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002710:	04000737          	lui	a4,0x4000
    80002714:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002716:	0732                	slli	a4,a4,0xc
    80002718:	00004797          	auipc	a5,0x4
    8000271c:	8e878793          	addi	a5,a5,-1816 # 80006000 <_trampoline>
    80002720:	00004697          	auipc	a3,0x4
    80002724:	8e068693          	addi	a3,a3,-1824 # 80006000 <_trampoline>
    80002728:	8f95                	sub	a5,a5,a3
    8000272a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000272c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002730:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002732:	18002773          	csrr	a4,satp
    80002736:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002738:	6d38                	ld	a4,88(a0)
    8000273a:	613c                	ld	a5,64(a0)
    8000273c:	6685                	lui	a3,0x1
    8000273e:	97b6                	add	a5,a5,a3
    80002740:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002742:	6d3c                	ld	a5,88(a0)
    80002744:	00000717          	auipc	a4,0x0
    80002748:	0fc70713          	addi	a4,a4,252 # 80002840 <usertrap>
    8000274c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000274e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002750:	8712                	mv	a4,tp
    80002752:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002754:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002758:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000275c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002760:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002764:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002766:	6f9c                	ld	a5,24(a5)
    80002768:	14179073          	csrw	sepc,a5
}
    8000276c:	60a2                	ld	ra,8(sp)
    8000276e:	6402                	ld	s0,0(sp)
    80002770:	0141                	addi	sp,sp,16
    80002772:	8082                	ret

0000000080002774 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002774:	1141                	addi	sp,sp,-16
    80002776:	e406                	sd	ra,8(sp)
    80002778:	e022                	sd	s0,0(sp)
    8000277a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000277c:	9f8ff0ef          	jal	80001974 <cpuid>
    80002780:	cd11                	beqz	a0,8000279c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002782:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002786:	000f4737          	lui	a4,0xf4
    8000278a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000278e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002790:	14d79073          	csrw	stimecmp,a5
}
    80002794:	60a2                	ld	ra,8(sp)
    80002796:	6402                	ld	s0,0(sp)
    80002798:	0141                	addi	sp,sp,16
    8000279a:	8082                	ret
    acquire(&tickslock);
    8000279c:	00013517          	auipc	a0,0x13
    800027a0:	48450513          	addi	a0,a0,1156 # 80015c20 <tickslock>
    800027a4:	c84fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800027a8:	00005717          	auipc	a4,0x5
    800027ac:	0e870713          	addi	a4,a4,232 # 80007890 <ticks>
    800027b0:	431c                	lw	a5,0(a4)
    800027b2:	2785                	addiw	a5,a5,1
    800027b4:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800027b6:	853a                	mv	a0,a4
    800027b8:	a17ff0ef          	jal	800021ce <wakeup>
    release(&tickslock);
    800027bc:	00013517          	auipc	a0,0x13
    800027c0:	46450513          	addi	a0,a0,1124 # 80015c20 <tickslock>
    800027c4:	cf8fe0ef          	jal	80000cbc <release>
    800027c8:	bf6d                	j	80002782 <clockintr+0xe>

00000000800027ca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ca:	1101                	addi	sp,sp,-32
    800027cc:	ec06                	sd	ra,24(sp)
    800027ce:	e822                	sd	s0,16(sp)
    800027d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027d2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800027d6:	57fd                	li	a5,-1
    800027d8:	17fe                	slli	a5,a5,0x3f
    800027da:	07a5                	addi	a5,a5,9
    800027dc:	00f70c63          	beq	a4,a5,800027f4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800027e0:	57fd                	li	a5,-1
    800027e2:	17fe                	slli	a5,a5,0x3f
    800027e4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800027e6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800027e8:	04f70863          	beq	a4,a5,80002838 <devintr+0x6e>
  }
}
    800027ec:	60e2                	ld	ra,24(sp)
    800027ee:	6442                	ld	s0,16(sp)
    800027f0:	6105                	addi	sp,sp,32
    800027f2:	8082                	ret
    800027f4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800027f6:	7e7020ef          	jal	800057dc <plic_claim>
    800027fa:	872a                	mv	a4,a0
    800027fc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027fe:	47a9                	li	a5,10
    80002800:	00f50963          	beq	a0,a5,80002812 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002804:	4785                	li	a5,1
    80002806:	00f50963          	beq	a0,a5,80002818 <devintr+0x4e>
    return 1;
    8000280a:	4505                	li	a0,1
    } else if(irq){
    8000280c:	eb09                	bnez	a4,8000281e <devintr+0x54>
    8000280e:	64a2                	ld	s1,8(sp)
    80002810:	bff1                	j	800027ec <devintr+0x22>
      uartintr();
    80002812:	9e2fe0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002816:	a819                	j	8000282c <devintr+0x62>
      virtio_disk_intr();
    80002818:	45a030ef          	jal	80005c72 <virtio_disk_intr>
    if(irq)
    8000281c:	a801                	j	8000282c <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    8000281e:	85ba                	mv	a1,a4
    80002820:	00005517          	auipc	a0,0x5
    80002824:	a3850513          	addi	a0,a0,-1480 # 80007258 <etext+0x258>
    80002828:	cd3fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000282c:	8526                	mv	a0,s1
    8000282e:	7cf020ef          	jal	800057fc <plic_complete>
    return 1;
    80002832:	4505                	li	a0,1
    80002834:	64a2                	ld	s1,8(sp)
    80002836:	bf5d                	j	800027ec <devintr+0x22>
    clockintr();
    80002838:	f3dff0ef          	jal	80002774 <clockintr>
    return 2;
    8000283c:	4509                	li	a0,2
    8000283e:	b77d                	j	800027ec <devintr+0x22>

0000000080002840 <usertrap>:
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	e04a                	sd	s2,0(sp)
    8000284a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000284c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002850:	1007f793          	andi	a5,a5,256
    80002854:	eba5                	bnez	a5,800028c4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002856:	00003797          	auipc	a5,0x3
    8000285a:	eda78793          	addi	a5,a5,-294 # 80005730 <kernelvec>
    8000285e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002862:	946ff0ef          	jal	800019a8 <myproc>
    80002866:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002868:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000286a:	14102773          	csrr	a4,sepc
    8000286e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002870:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002874:	47a1                	li	a5,8
    80002876:	04f70d63          	beq	a4,a5,800028d0 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000287a:	f51ff0ef          	jal	800027ca <devintr>
    8000287e:	892a                	mv	s2,a0
    80002880:	e945                	bnez	a0,80002930 <usertrap+0xf0>
    80002882:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002886:	47bd                	li	a5,15
    80002888:	08f70863          	beq	a4,a5,80002918 <usertrap+0xd8>
    8000288c:	14202773          	csrr	a4,scause
    80002890:	47b5                	li	a5,13
    80002892:	08f70363          	beq	a4,a5,80002918 <usertrap+0xd8>
    80002896:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000289a:	5890                	lw	a2,48(s1)
    8000289c:	00005517          	auipc	a0,0x5
    800028a0:	9fc50513          	addi	a0,a0,-1540 # 80007298 <etext+0x298>
    800028a4:	c57fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028a8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ac:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800028b0:	00005517          	auipc	a0,0x5
    800028b4:	a1850513          	addi	a0,a0,-1512 # 800072c8 <etext+0x2c8>
    800028b8:	c43fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800028bc:	8526                	mv	a0,s1
    800028be:	b19ff0ef          	jal	800023d6 <setkilled>
    800028c2:	a035                	j	800028ee <usertrap+0xae>
    panic("usertrap: not from user mode");
    800028c4:	00005517          	auipc	a0,0x5
    800028c8:	9b450513          	addi	a0,a0,-1612 # 80007278 <etext+0x278>
    800028cc:	f59fd0ef          	jal	80000824 <panic>
    if(killed(p))
    800028d0:	b2bff0ef          	jal	800023fa <killed>
    800028d4:	ed15                	bnez	a0,80002910 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800028d6:	6cb8                	ld	a4,88(s1)
    800028d8:	6f1c                	ld	a5,24(a4)
    800028da:	0791                	addi	a5,a5,4
    800028dc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028de:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028e2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028e6:	10079073          	csrw	sstatus,a5
    syscall();
    800028ea:	272000ef          	jal	80002b5c <syscall>
  if(killed(p))
    800028ee:	8526                	mv	a0,s1
    800028f0:	b0bff0ef          	jal	800023fa <killed>
    800028f4:	e139                	bnez	a0,8000293a <usertrap+0xfa>
  prepare_return();
    800028f6:	e05ff0ef          	jal	800026fa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800028fa:	68a8                	ld	a0,80(s1)
    800028fc:	8131                	srli	a0,a0,0xc
    800028fe:	57fd                	li	a5,-1
    80002900:	17fe                	slli	a5,a5,0x3f
    80002902:	8d5d                	or	a0,a0,a5
}
    80002904:	60e2                	ld	ra,24(sp)
    80002906:	6442                	ld	s0,16(sp)
    80002908:	64a2                	ld	s1,8(sp)
    8000290a:	6902                	ld	s2,0(sp)
    8000290c:	6105                	addi	sp,sp,32
    8000290e:	8082                	ret
      kexit(-1);
    80002910:	557d                	li	a0,-1
    80002912:	99bff0ef          	jal	800022ac <kexit>
    80002916:	b7c1                	j	800028d6 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002918:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002920:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002922:	00163613          	seqz	a2,a2
    80002926:	68a8                	ld	a0,80(s1)
    80002928:	ca9fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000292c:	f169                	bnez	a0,800028ee <usertrap+0xae>
    8000292e:	b7a5                	j	80002896 <usertrap+0x56>
  if(killed(p))
    80002930:	8526                	mv	a0,s1
    80002932:	ac9ff0ef          	jal	800023fa <killed>
    80002936:	c511                	beqz	a0,80002942 <usertrap+0x102>
    80002938:	a011                	j	8000293c <usertrap+0xfc>
    8000293a:	4901                	li	s2,0
    kexit(-1);
    8000293c:	557d                	li	a0,-1
    8000293e:	96fff0ef          	jal	800022ac <kexit>
  if(which_dev == 2) {
    80002942:	4789                	li	a5,2
    80002944:	faf919e3          	bne	s2,a5,800028f6 <usertrap+0xb6>
    p->time_slices++;
    80002948:	16c4a783          	lw	a5,364(s1)
    8000294c:	2785                	addiw	a5,a5,1
    8000294e:	16f4a623          	sw	a5,364(s1)
    if(p->time_slices >= mlfq_time_quanta[p->priority]) {
    80002952:	1684a683          	lw	a3,360(s1)
    80002956:	00269613          	slli	a2,a3,0x2
    8000295a:	00005717          	auipc	a4,0x5
    8000295e:	ef670713          	addi	a4,a4,-266 # 80007850 <mlfq_time_quanta>
    80002962:	9732                	add	a4,a4,a2
    80002964:	4318                	lw	a4,0(a4)
    80002966:	00e7ca63          	blt	a5,a4,8000297a <usertrap+0x13a>
      if(p->priority < NMLFQ - 1) {
    8000296a:	4789                	li	a5,2
    8000296c:	00d7c563          	blt	a5,a3,80002976 <usertrap+0x136>
        p->priority++;  // Move to lower priority queue
    80002970:	2685                	addiw	a3,a3,1 # 1001 <_entry-0x7fffefff>
    80002972:	16d4a423          	sw	a3,360(s1)
      p->time_slices = 0;  // Reset time slice counter for new queue
    80002976:	1604a623          	sw	zero,364(s1)
    yield();
    8000297a:	fbeff0ef          	jal	80002138 <yield>
    8000297e:	bfa5                	j	800028f6 <usertrap+0xb6>

0000000080002980 <kerneltrap>:
{
    80002980:	7179                	addi	sp,sp,-48
    80002982:	f406                	sd	ra,40(sp)
    80002984:	f022                	sd	s0,32(sp)
    80002986:	ec26                	sd	s1,24(sp)
    80002988:	e84a                	sd	s2,16(sp)
    8000298a:	e44e                	sd	s3,8(sp)
    8000298c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002992:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002996:	142027f3          	csrr	a5,scause
    8000299a:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    8000299c:	1004f793          	andi	a5,s1,256
    800029a0:	c795                	beqz	a5,800029cc <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029a6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029a8:	eb85                	bnez	a5,800029d8 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800029aa:	e21ff0ef          	jal	800027ca <devintr>
    800029ae:	c91d                	beqz	a0,800029e4 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800029b0:	4789                	li	a5,2
    800029b2:	04f50a63          	beq	a0,a5,80002a06 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029b6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ba:	10049073          	csrw	sstatus,s1
}
    800029be:	70a2                	ld	ra,40(sp)
    800029c0:	7402                	ld	s0,32(sp)
    800029c2:	64e2                	ld	s1,24(sp)
    800029c4:	6942                	ld	s2,16(sp)
    800029c6:	69a2                	ld	s3,8(sp)
    800029c8:	6145                	addi	sp,sp,48
    800029ca:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029cc:	00005517          	auipc	a0,0x5
    800029d0:	92450513          	addi	a0,a0,-1756 # 800072f0 <etext+0x2f0>
    800029d4:	e51fd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    800029d8:	00005517          	auipc	a0,0x5
    800029dc:	94050513          	addi	a0,a0,-1728 # 80007318 <etext+0x318>
    800029e0:	e45fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800029ec:	85ce                	mv	a1,s3
    800029ee:	00005517          	auipc	a0,0x5
    800029f2:	94a50513          	addi	a0,a0,-1718 # 80007338 <etext+0x338>
    800029f6:	b05fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800029fa:	00005517          	auipc	a0,0x5
    800029fe:	96650513          	addi	a0,a0,-1690 # 80007360 <etext+0x360>
    80002a02:	e23fd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002a06:	fa3fe0ef          	jal	800019a8 <myproc>
    80002a0a:	d555                	beqz	a0,800029b6 <kerneltrap+0x36>
    yield();
    80002a0c:	f2cff0ef          	jal	80002138 <yield>
    80002a10:	b75d                	j	800029b6 <kerneltrap+0x36>

0000000080002a12 <argraw>:
}


static uint64
argraw(int n)
{
    80002a12:	1101                	addi	sp,sp,-32
    80002a14:	ec06                	sd	ra,24(sp)
    80002a16:	e822                	sd	s0,16(sp)
    80002a18:	e426                	sd	s1,8(sp)
    80002a1a:	1000                	addi	s0,sp,32
    80002a1c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a1e:	f8bfe0ef          	jal	800019a8 <myproc>
  switch (n) {
    80002a22:	4795                	li	a5,5
    80002a24:	0497e163          	bltu	a5,s1,80002a66 <argraw+0x54>
    80002a28:	048a                	slli	s1,s1,0x2
    80002a2a:	00005717          	auipc	a4,0x5
    80002a2e:	d3670713          	addi	a4,a4,-714 # 80007760 <states.0+0x30>
    80002a32:	94ba                	add	s1,s1,a4
    80002a34:	409c                	lw	a5,0(s1)
    80002a36:	97ba                	add	a5,a5,a4
    80002a38:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a3a:	6d3c                	ld	a5,88(a0)
    80002a3c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a3e:	60e2                	ld	ra,24(sp)
    80002a40:	6442                	ld	s0,16(sp)
    80002a42:	64a2                	ld	s1,8(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret
    return p->trapframe->a1;
    80002a48:	6d3c                	ld	a5,88(a0)
    80002a4a:	7fa8                	ld	a0,120(a5)
    80002a4c:	bfcd                	j	80002a3e <argraw+0x2c>
    return p->trapframe->a2;
    80002a4e:	6d3c                	ld	a5,88(a0)
    80002a50:	63c8                	ld	a0,128(a5)
    80002a52:	b7f5                	j	80002a3e <argraw+0x2c>
    return p->trapframe->a3;
    80002a54:	6d3c                	ld	a5,88(a0)
    80002a56:	67c8                	ld	a0,136(a5)
    80002a58:	b7dd                	j	80002a3e <argraw+0x2c>
    return p->trapframe->a4;
    80002a5a:	6d3c                	ld	a5,88(a0)
    80002a5c:	6bc8                	ld	a0,144(a5)
    80002a5e:	b7c5                	j	80002a3e <argraw+0x2c>
    return p->trapframe->a5;
    80002a60:	6d3c                	ld	a5,88(a0)
    80002a62:	6fc8                	ld	a0,152(a5)
    80002a64:	bfe9                	j	80002a3e <argraw+0x2c>
  panic("argraw");
    80002a66:	00005517          	auipc	a0,0x5
    80002a6a:	90a50513          	addi	a0,a0,-1782 # 80007370 <etext+0x370>
    80002a6e:	db7fd0ef          	jal	80000824 <panic>

0000000080002a72 <fetchaddr>:
{
    80002a72:	1101                	addi	sp,sp,-32
    80002a74:	ec06                	sd	ra,24(sp)
    80002a76:	e822                	sd	s0,16(sp)
    80002a78:	e426                	sd	s1,8(sp)
    80002a7a:	e04a                	sd	s2,0(sp)
    80002a7c:	1000                	addi	s0,sp,32
    80002a7e:	84aa                	mv	s1,a0
    80002a80:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a82:	f27fe0ef          	jal	800019a8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a86:	653c                	ld	a5,72(a0)
    80002a88:	02f4f663          	bgeu	s1,a5,80002ab4 <fetchaddr+0x42>
    80002a8c:	00848713          	addi	a4,s1,8
    80002a90:	02e7e463          	bltu	a5,a4,80002ab8 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a94:	46a1                	li	a3,8
    80002a96:	8626                	mv	a2,s1
    80002a98:	85ca                	mv	a1,s2
    80002a9a:	6928                	ld	a0,80(a0)
    80002a9c:	c77fe0ef          	jal	80001712 <copyin>
    80002aa0:	00a03533          	snez	a0,a0
    80002aa4:	40a0053b          	negw	a0,a0
}
    80002aa8:	60e2                	ld	ra,24(sp)
    80002aaa:	6442                	ld	s0,16(sp)
    80002aac:	64a2                	ld	s1,8(sp)
    80002aae:	6902                	ld	s2,0(sp)
    80002ab0:	6105                	addi	sp,sp,32
    80002ab2:	8082                	ret
    return -1;
    80002ab4:	557d                	li	a0,-1
    80002ab6:	bfcd                	j	80002aa8 <fetchaddr+0x36>
    80002ab8:	557d                	li	a0,-1
    80002aba:	b7fd                	j	80002aa8 <fetchaddr+0x36>

0000000080002abc <fetchstr>:
{
    80002abc:	7179                	addi	sp,sp,-48
    80002abe:	f406                	sd	ra,40(sp)
    80002ac0:	f022                	sd	s0,32(sp)
    80002ac2:	ec26                	sd	s1,24(sp)
    80002ac4:	e84a                	sd	s2,16(sp)
    80002ac6:	e44e                	sd	s3,8(sp)
    80002ac8:	1800                	addi	s0,sp,48
    80002aca:	89aa                	mv	s3,a0
    80002acc:	84ae                	mv	s1,a1
    80002ace:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002ad0:	ed9fe0ef          	jal	800019a8 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ad4:	86ca                	mv	a3,s2
    80002ad6:	864e                	mv	a2,s3
    80002ad8:	85a6                	mv	a1,s1
    80002ada:	6928                	ld	a0,80(a0)
    80002adc:	a1dfe0ef          	jal	800014f8 <copyinstr>
    80002ae0:	00054c63          	bltz	a0,80002af8 <fetchstr+0x3c>
  return strlen(buf);
    80002ae4:	8526                	mv	a0,s1
    80002ae6:	b9cfe0ef          	jal	80000e82 <strlen>
}
    80002aea:	70a2                	ld	ra,40(sp)
    80002aec:	7402                	ld	s0,32(sp)
    80002aee:	64e2                	ld	s1,24(sp)
    80002af0:	6942                	ld	s2,16(sp)
    80002af2:	69a2                	ld	s3,8(sp)
    80002af4:	6145                	addi	sp,sp,48
    80002af6:	8082                	ret
    return -1;
    80002af8:	557d                	li	a0,-1
    80002afa:	bfc5                	j	80002aea <fetchstr+0x2e>

0000000080002afc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002afc:	1101                	addi	sp,sp,-32
    80002afe:	ec06                	sd	ra,24(sp)
    80002b00:	e822                	sd	s0,16(sp)
    80002b02:	e426                	sd	s1,8(sp)
    80002b04:	1000                	addi	s0,sp,32
    80002b06:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b08:	f0bff0ef          	jal	80002a12 <argraw>
    80002b0c:	c088                	sw	a0,0(s1)
}
    80002b0e:	60e2                	ld	ra,24(sp)
    80002b10:	6442                	ld	s0,16(sp)
    80002b12:	64a2                	ld	s1,8(sp)
    80002b14:	6105                	addi	sp,sp,32
    80002b16:	8082                	ret

0000000080002b18 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	1000                	addi	s0,sp,32
    80002b22:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b24:	eefff0ef          	jal	80002a12 <argraw>
    80002b28:	e088                	sd	a0,0(s1)
}
    80002b2a:	60e2                	ld	ra,24(sp)
    80002b2c:	6442                	ld	s0,16(sp)
    80002b2e:	64a2                	ld	s1,8(sp)
    80002b30:	6105                	addi	sp,sp,32
    80002b32:	8082                	ret

0000000080002b34 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b34:	1101                	addi	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	e426                	sd	s1,8(sp)
    80002b3c:	e04a                	sd	s2,0(sp)
    80002b3e:	1000                	addi	s0,sp,32
    80002b40:	892e                	mv	s2,a1
    80002b42:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002b44:	ecfff0ef          	jal	80002a12 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002b48:	8626                	mv	a2,s1
    80002b4a:	85ca                	mv	a1,s2
    80002b4c:	f71ff0ef          	jal	80002abc <fetchstr>
}
    80002b50:	60e2                	ld	ra,24(sp)
    80002b52:	6442                	ld	s0,16(sp)
    80002b54:	64a2                	ld	s1,8(sp)
    80002b56:	6902                	ld	s2,0(sp)
    80002b58:	6105                	addi	sp,sp,32
    80002b5a:	8082                	ret

0000000080002b5c <syscall>:
[SYS_boostproc] sys_boostproc,
};

void
syscall(void)
{
    80002b5c:	1101                	addi	sp,sp,-32
    80002b5e:	ec06                	sd	ra,24(sp)
    80002b60:	e822                	sd	s0,16(sp)
    80002b62:	e426                	sd	s1,8(sp)
    80002b64:	e04a                	sd	s2,0(sp)
    80002b66:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b68:	e41fe0ef          	jal	800019a8 <myproc>
    80002b6c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b6e:	05853903          	ld	s2,88(a0)
    80002b72:	0a893783          	ld	a5,168(s2)
    80002b76:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b7a:	37fd                	addiw	a5,a5,-1
    80002b7c:	4759                	li	a4,22
    80002b7e:	00f76f63          	bltu	a4,a5,80002b9c <syscall+0x40>
    80002b82:	00369713          	slli	a4,a3,0x3
    80002b86:	00005797          	auipc	a5,0x5
    80002b8a:	bf278793          	addi	a5,a5,-1038 # 80007778 <syscalls>
    80002b8e:	97ba                	add	a5,a5,a4
    80002b90:	639c                	ld	a5,0(a5)
    80002b92:	c789                	beqz	a5,80002b9c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b94:	9782                	jalr	a5
    80002b96:	06a93823          	sd	a0,112(s2)
    80002b9a:	a829                	j	80002bb4 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b9c:	15848613          	addi	a2,s1,344
    80002ba0:	588c                	lw	a1,48(s1)
    80002ba2:	00004517          	auipc	a0,0x4
    80002ba6:	7d650513          	addi	a0,a0,2006 # 80007378 <etext+0x378>
    80002baa:	951fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bae:	6cbc                	ld	a5,88(s1)
    80002bb0:	577d                	li	a4,-1
    80002bb2:	fbb8                	sd	a4,112(a5)
  }
}
    80002bb4:	60e2                	ld	ra,24(sp)
    80002bb6:	6442                	ld	s0,16(sp)
    80002bb8:	64a2                	ld	s1,8(sp)
    80002bba:	6902                	ld	s2,0(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret

0000000080002bc0 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002bc0:	1101                	addi	sp,sp,-32
    80002bc2:	ec06                	sd	ra,24(sp)
    80002bc4:	e822                	sd	s0,16(sp)
    80002bc6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bc8:	fec40593          	addi	a1,s0,-20
    80002bcc:	4501                	li	a0,0
    80002bce:	f2fff0ef          	jal	80002afc <argint>
  kexit(n);
    80002bd2:	fec42503          	lw	a0,-20(s0)
    80002bd6:	ed6ff0ef          	jal	800022ac <kexit>
  return 0;  // not reached
}
    80002bda:	4501                	li	a0,0
    80002bdc:	60e2                	ld	ra,24(sp)
    80002bde:	6442                	ld	s0,16(sp)
    80002be0:	6105                	addi	sp,sp,32
    80002be2:	8082                	ret

0000000080002be4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002be4:	1141                	addi	sp,sp,-16
    80002be6:	e406                	sd	ra,8(sp)
    80002be8:	e022                	sd	s0,0(sp)
    80002bea:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bec:	dbdfe0ef          	jal	800019a8 <myproc>
}
    80002bf0:	5908                	lw	a0,48(a0)
    80002bf2:	60a2                	ld	ra,8(sp)
    80002bf4:	6402                	ld	s0,0(sp)
    80002bf6:	0141                	addi	sp,sp,16
    80002bf8:	8082                	ret

0000000080002bfa <sys_fork>:

uint64
sys_fork(void)
{
    80002bfa:	1141                	addi	sp,sp,-16
    80002bfc:	e406                	sd	ra,8(sp)
    80002bfe:	e022                	sd	s0,0(sp)
    80002c00:	0800                	addi	s0,sp,16
  return kfork();
    80002c02:	938ff0ef          	jal	80001d3a <kfork>
}
    80002c06:	60a2                	ld	ra,8(sp)
    80002c08:	6402                	ld	s0,0(sp)
    80002c0a:	0141                	addi	sp,sp,16
    80002c0c:	8082                	ret

0000000080002c0e <sys_wait>:

uint64
sys_wait(void)
{
    80002c0e:	1101                	addi	sp,sp,-32
    80002c10:	ec06                	sd	ra,24(sp)
    80002c12:	e822                	sd	s0,16(sp)
    80002c14:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c16:	fe840593          	addi	a1,s0,-24
    80002c1a:	4501                	li	a0,0
    80002c1c:	efdff0ef          	jal	80002b18 <argaddr>
  return kwait(p);
    80002c20:	fe843503          	ld	a0,-24(s0)
    80002c24:	801ff0ef          	jal	80002424 <kwait>
}
    80002c28:	60e2                	ld	ra,24(sp)
    80002c2a:	6442                	ld	s0,16(sp)
    80002c2c:	6105                	addi	sp,sp,32
    80002c2e:	8082                	ret

0000000080002c30 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c30:	7179                	addi	sp,sp,-48
    80002c32:	f406                	sd	ra,40(sp)
    80002c34:	f022                	sd	s0,32(sp)
    80002c36:	ec26                	sd	s1,24(sp)
    80002c38:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002c3a:	fd840593          	addi	a1,s0,-40
    80002c3e:	4501                	li	a0,0
    80002c40:	ebdff0ef          	jal	80002afc <argint>
  argint(1, &t);
    80002c44:	fdc40593          	addi	a1,s0,-36
    80002c48:	4505                	li	a0,1
    80002c4a:	eb3ff0ef          	jal	80002afc <argint>
  addr = myproc()->sz;
    80002c4e:	d5bfe0ef          	jal	800019a8 <myproc>
    80002c52:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002c54:	fdc42703          	lw	a4,-36(s0)
    80002c58:	4785                	li	a5,1
    80002c5a:	02f70763          	beq	a4,a5,80002c88 <sys_sbrk+0x58>
    80002c5e:	fd842783          	lw	a5,-40(s0)
    80002c62:	0207c363          	bltz	a5,80002c88 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002c66:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002c68:	02000737          	lui	a4,0x2000
    80002c6c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002c6e:	0736                	slli	a4,a4,0xd
    80002c70:	02f76a63          	bltu	a4,a5,80002ca4 <sys_sbrk+0x74>
    80002c74:	0297e863          	bltu	a5,s1,80002ca4 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002c78:	d31fe0ef          	jal	800019a8 <myproc>
    80002c7c:	fd842703          	lw	a4,-40(s0)
    80002c80:	653c                	ld	a5,72(a0)
    80002c82:	97ba                	add	a5,a5,a4
    80002c84:	e53c                	sd	a5,72(a0)
    80002c86:	a039                	j	80002c94 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002c88:	fd842503          	lw	a0,-40(s0)
    80002c8c:	84cff0ef          	jal	80001cd8 <growproc>
    80002c90:	00054863          	bltz	a0,80002ca0 <sys_sbrk+0x70>
  }
  return addr;
}
    80002c94:	8526                	mv	a0,s1
    80002c96:	70a2                	ld	ra,40(sp)
    80002c98:	7402                	ld	s0,32(sp)
    80002c9a:	64e2                	ld	s1,24(sp)
    80002c9c:	6145                	addi	sp,sp,48
    80002c9e:	8082                	ret
      return -1;
    80002ca0:	54fd                	li	s1,-1
    80002ca2:	bfcd                	j	80002c94 <sys_sbrk+0x64>
      return -1;
    80002ca4:	54fd                	li	s1,-1
    80002ca6:	b7fd                	j	80002c94 <sys_sbrk+0x64>

0000000080002ca8 <sys_pause>:

uint64
sys_pause(void)
{
    80002ca8:	7139                	addi	sp,sp,-64
    80002caa:	fc06                	sd	ra,56(sp)
    80002cac:	f822                	sd	s0,48(sp)
    80002cae:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cb0:	fcc40593          	addi	a1,s0,-52
    80002cb4:	4501                	li	a0,0
    80002cb6:	e47ff0ef          	jal	80002afc <argint>
  if(n < 0)
    80002cba:	fcc42783          	lw	a5,-52(s0)
    80002cbe:	0607c863          	bltz	a5,80002d2e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002cc2:	00013517          	auipc	a0,0x13
    80002cc6:	f5e50513          	addi	a0,a0,-162 # 80015c20 <tickslock>
    80002cca:	f5ffd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002cce:	fcc42783          	lw	a5,-52(s0)
    80002cd2:	c3b9                	beqz	a5,80002d18 <sys_pause+0x70>
    80002cd4:	f426                	sd	s1,40(sp)
    80002cd6:	f04a                	sd	s2,32(sp)
    80002cd8:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002cda:	00005997          	auipc	s3,0x5
    80002cde:	bb69a983          	lw	s3,-1098(s3) # 80007890 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ce2:	00013917          	auipc	s2,0x13
    80002ce6:	f3e90913          	addi	s2,s2,-194 # 80015c20 <tickslock>
    80002cea:	00005497          	auipc	s1,0x5
    80002cee:	ba648493          	addi	s1,s1,-1114 # 80007890 <ticks>
    if(killed(myproc())){
    80002cf2:	cb7fe0ef          	jal	800019a8 <myproc>
    80002cf6:	f04ff0ef          	jal	800023fa <killed>
    80002cfa:	ed0d                	bnez	a0,80002d34 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002cfc:	85ca                	mv	a1,s2
    80002cfe:	8526                	mv	a0,s1
    80002d00:	c82ff0ef          	jal	80002182 <sleep>
  while(ticks - ticks0 < n){
    80002d04:	409c                	lw	a5,0(s1)
    80002d06:	413787bb          	subw	a5,a5,s3
    80002d0a:	fcc42703          	lw	a4,-52(s0)
    80002d0e:	fee7e2e3          	bltu	a5,a4,80002cf2 <sys_pause+0x4a>
    80002d12:	74a2                	ld	s1,40(sp)
    80002d14:	7902                	ld	s2,32(sp)
    80002d16:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d18:	00013517          	auipc	a0,0x13
    80002d1c:	f0850513          	addi	a0,a0,-248 # 80015c20 <tickslock>
    80002d20:	f9dfd0ef          	jal	80000cbc <release>
  return 0;
    80002d24:	4501                	li	a0,0
}
    80002d26:	70e2                	ld	ra,56(sp)
    80002d28:	7442                	ld	s0,48(sp)
    80002d2a:	6121                	addi	sp,sp,64
    80002d2c:	8082                	ret
    n = 0;
    80002d2e:	fc042623          	sw	zero,-52(s0)
    80002d32:	bf41                	j	80002cc2 <sys_pause+0x1a>
      release(&tickslock);
    80002d34:	00013517          	auipc	a0,0x13
    80002d38:	eec50513          	addi	a0,a0,-276 # 80015c20 <tickslock>
    80002d3c:	f81fd0ef          	jal	80000cbc <release>
      return -1;
    80002d40:	557d                	li	a0,-1
    80002d42:	74a2                	ld	s1,40(sp)
    80002d44:	7902                	ld	s2,32(sp)
    80002d46:	69e2                	ld	s3,24(sp)
    80002d48:	bff9                	j	80002d26 <sys_pause+0x7e>

0000000080002d4a <sys_kill>:

uint64
sys_kill(void)
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d52:	fec40593          	addi	a1,s0,-20
    80002d56:	4501                	li	a0,0
    80002d58:	da5ff0ef          	jal	80002afc <argint>
  return kkill(pid);
    80002d5c:	fec42503          	lw	a0,-20(s0)
    80002d60:	df2ff0ef          	jal	80002352 <kkill>
}
    80002d64:	60e2                	ld	ra,24(sp)
    80002d66:	6442                	ld	s0,16(sp)
    80002d68:	6105                	addi	sp,sp,32
    80002d6a:	8082                	ret

0000000080002d6c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d76:	00013517          	auipc	a0,0x13
    80002d7a:	eaa50513          	addi	a0,a0,-342 # 80015c20 <tickslock>
    80002d7e:	eabfd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002d82:	00005797          	auipc	a5,0x5
    80002d86:	b0e7a783          	lw	a5,-1266(a5) # 80007890 <ticks>
    80002d8a:	84be                	mv	s1,a5
  release(&tickslock);
    80002d8c:	00013517          	auipc	a0,0x13
    80002d90:	e9450513          	addi	a0,a0,-364 # 80015c20 <tickslock>
    80002d94:	f29fd0ef          	jal	80000cbc <release>
  return xticks;
}
    80002d98:	02049513          	slli	a0,s1,0x20
    80002d9c:	9101                	srli	a0,a0,0x20
    80002d9e:	60e2                	ld	ra,24(sp)
    80002da0:	6442                	ld	s0,16(sp)
    80002da2:	64a2                	ld	s1,8(sp)
    80002da4:	6105                	addi	sp,sp,32
    80002da6:	8082                	ret

0000000080002da8 <sys_getprocinfo>:

// Get process information for MLFQ debugging
uint64
sys_getprocinfo(void)
{
    80002da8:	7139                	addi	sp,sp,-64
    80002daa:	fc06                	sd	ra,56(sp)
    80002dac:	f822                	sd	s0,48(sp)
    80002dae:	f426                	sd	s1,40(sp)
    80002db0:	0080                	addi	s0,sp,64
  uint64 addr;
  struct proc *p = myproc();
    80002db2:	bf7fe0ef          	jal	800019a8 <myproc>
    80002db6:	84aa                	mv	s1,a0
  
  argaddr(0, &addr);
    80002db8:	fd840593          	addi	a1,s0,-40
    80002dbc:	4501                	li	a0,0
    80002dbe:	d5bff0ef          	jal	80002b18 <argaddr>
    int state;
    int priority;
    int time_slices;
  } info;
  
  acquire(&p->lock);
    80002dc2:	8526                	mv	a0,s1
    80002dc4:	e65fd0ef          	jal	80000c28 <acquire>
  info.pid = p->pid;
    80002dc8:	589c                	lw	a5,48(s1)
    80002dca:	fcf42423          	sw	a5,-56(s0)
  info.state = p->state;
    80002dce:	4c9c                	lw	a5,24(s1)
    80002dd0:	fcf42623          	sw	a5,-52(s0)
  info.priority = p->priority;
    80002dd4:	1684a783          	lw	a5,360(s1)
    80002dd8:	fcf42823          	sw	a5,-48(s0)
  info.time_slices = p->time_slices;
    80002ddc:	16c4a783          	lw	a5,364(s1)
    80002de0:	fcf42a23          	sw	a5,-44(s0)
  release(&p->lock);
    80002de4:	8526                	mv	a0,s1
    80002de6:	ed7fd0ef          	jal	80000cbc <release>
  
  if(copyout(p->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    80002dea:	46c1                	li	a3,16
    80002dec:	fc840613          	addi	a2,s0,-56
    80002df0:	fd843583          	ld	a1,-40(s0)
    80002df4:	68a8                	ld	a0,80(s1)
    80002df6:	85ffe0ef          	jal	80001654 <copyout>
    return -1;
  
  return 0;
}
    80002dfa:	957d                	srai	a0,a0,0x3f
    80002dfc:	70e2                	ld	ra,56(sp)
    80002dfe:	7442                	ld	s0,48(sp)
    80002e00:	74a2                	ld	s1,40(sp)
    80002e02:	6121                	addi	sp,sp,64
    80002e04:	8082                	ret

0000000080002e06 <sys_boostproc>:

uint64
sys_boostproc(void)
{
    80002e06:	1141                	addi	sp,sp,-16
    80002e08:	e406                	sd	ra,8(sp)
    80002e0a:	e022                	sd	s0,0(sp)
    80002e0c:	0800                	addi	s0,sp,16
  extern void boost_all_priorities(void);
  
  boost_all_priorities();
    80002e0e:	858ff0ef          	jal	80001e66 <boost_all_priorities>
  
  return 0;
    80002e12:	4501                	li	a0,0
    80002e14:	60a2                	ld	ra,8(sp)
    80002e16:	6402                	ld	s0,0(sp)
    80002e18:	0141                	addi	sp,sp,16
    80002e1a:	8082                	ret

0000000080002e1c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e1c:	7179                	addi	sp,sp,-48
    80002e1e:	f406                	sd	ra,40(sp)
    80002e20:	f022                	sd	s0,32(sp)
    80002e22:	ec26                	sd	s1,24(sp)
    80002e24:	e84a                	sd	s2,16(sp)
    80002e26:	e44e                	sd	s3,8(sp)
    80002e28:	e052                	sd	s4,0(sp)
    80002e2a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e2c:	00004597          	auipc	a1,0x4
    80002e30:	56c58593          	addi	a1,a1,1388 # 80007398 <etext+0x398>
    80002e34:	00013517          	auipc	a0,0x13
    80002e38:	e0450513          	addi	a0,a0,-508 # 80015c38 <bcache>
    80002e3c:	d63fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e40:	0001b797          	auipc	a5,0x1b
    80002e44:	df878793          	addi	a5,a5,-520 # 8001dc38 <bcache+0x8000>
    80002e48:	0001b717          	auipc	a4,0x1b
    80002e4c:	05870713          	addi	a4,a4,88 # 8001dea0 <bcache+0x8268>
    80002e50:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e54:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e58:	00013497          	auipc	s1,0x13
    80002e5c:	df848493          	addi	s1,s1,-520 # 80015c50 <bcache+0x18>
    b->next = bcache.head.next;
    80002e60:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e62:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e64:	00004a17          	auipc	s4,0x4
    80002e68:	53ca0a13          	addi	s4,s4,1340 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002e6c:	2b893783          	ld	a5,696(s2)
    80002e70:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e72:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e76:	85d2                	mv	a1,s4
    80002e78:	01048513          	addi	a0,s1,16
    80002e7c:	328010ef          	jal	800041a4 <initsleeplock>
    bcache.head.next->prev = b;
    80002e80:	2b893783          	ld	a5,696(s2)
    80002e84:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e86:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e8a:	45848493          	addi	s1,s1,1112
    80002e8e:	fd349fe3          	bne	s1,s3,80002e6c <binit+0x50>
  }
}
    80002e92:	70a2                	ld	ra,40(sp)
    80002e94:	7402                	ld	s0,32(sp)
    80002e96:	64e2                	ld	s1,24(sp)
    80002e98:	6942                	ld	s2,16(sp)
    80002e9a:	69a2                	ld	s3,8(sp)
    80002e9c:	6a02                	ld	s4,0(sp)
    80002e9e:	6145                	addi	sp,sp,48
    80002ea0:	8082                	ret

0000000080002ea2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ea2:	7179                	addi	sp,sp,-48
    80002ea4:	f406                	sd	ra,40(sp)
    80002ea6:	f022                	sd	s0,32(sp)
    80002ea8:	ec26                	sd	s1,24(sp)
    80002eaa:	e84a                	sd	s2,16(sp)
    80002eac:	e44e                	sd	s3,8(sp)
    80002eae:	1800                	addi	s0,sp,48
    80002eb0:	892a                	mv	s2,a0
    80002eb2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002eb4:	00013517          	auipc	a0,0x13
    80002eb8:	d8450513          	addi	a0,a0,-636 # 80015c38 <bcache>
    80002ebc:	d6dfd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ec0:	0001b497          	auipc	s1,0x1b
    80002ec4:	0304b483          	ld	s1,48(s1) # 8001def0 <bcache+0x82b8>
    80002ec8:	0001b797          	auipc	a5,0x1b
    80002ecc:	fd878793          	addi	a5,a5,-40 # 8001dea0 <bcache+0x8268>
    80002ed0:	02f48b63          	beq	s1,a5,80002f06 <bread+0x64>
    80002ed4:	873e                	mv	a4,a5
    80002ed6:	a021                	j	80002ede <bread+0x3c>
    80002ed8:	68a4                	ld	s1,80(s1)
    80002eda:	02e48663          	beq	s1,a4,80002f06 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ede:	449c                	lw	a5,8(s1)
    80002ee0:	ff279ce3          	bne	a5,s2,80002ed8 <bread+0x36>
    80002ee4:	44dc                	lw	a5,12(s1)
    80002ee6:	ff3799e3          	bne	a5,s3,80002ed8 <bread+0x36>
      b->refcnt++;
    80002eea:	40bc                	lw	a5,64(s1)
    80002eec:	2785                	addiw	a5,a5,1
    80002eee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ef0:	00013517          	auipc	a0,0x13
    80002ef4:	d4850513          	addi	a0,a0,-696 # 80015c38 <bcache>
    80002ef8:	dc5fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002efc:	01048513          	addi	a0,s1,16
    80002f00:	2da010ef          	jal	800041da <acquiresleep>
      return b;
    80002f04:	a889                	j	80002f56 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f06:	0001b497          	auipc	s1,0x1b
    80002f0a:	fe24b483          	ld	s1,-30(s1) # 8001dee8 <bcache+0x82b0>
    80002f0e:	0001b797          	auipc	a5,0x1b
    80002f12:	f9278793          	addi	a5,a5,-110 # 8001dea0 <bcache+0x8268>
    80002f16:	00f48863          	beq	s1,a5,80002f26 <bread+0x84>
    80002f1a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f1c:	40bc                	lw	a5,64(s1)
    80002f1e:	cb91                	beqz	a5,80002f32 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f20:	64a4                	ld	s1,72(s1)
    80002f22:	fee49de3          	bne	s1,a4,80002f1c <bread+0x7a>
  panic("bget: no buffers");
    80002f26:	00004517          	auipc	a0,0x4
    80002f2a:	48250513          	addi	a0,a0,1154 # 800073a8 <etext+0x3a8>
    80002f2e:	8f7fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002f32:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f36:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f3a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f3e:	4785                	li	a5,1
    80002f40:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f42:	00013517          	auipc	a0,0x13
    80002f46:	cf650513          	addi	a0,a0,-778 # 80015c38 <bcache>
    80002f4a:	d73fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002f4e:	01048513          	addi	a0,s1,16
    80002f52:	288010ef          	jal	800041da <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f56:	409c                	lw	a5,0(s1)
    80002f58:	cb89                	beqz	a5,80002f6a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f5a:	8526                	mv	a0,s1
    80002f5c:	70a2                	ld	ra,40(sp)
    80002f5e:	7402                	ld	s0,32(sp)
    80002f60:	64e2                	ld	s1,24(sp)
    80002f62:	6942                	ld	s2,16(sp)
    80002f64:	69a2                	ld	s3,8(sp)
    80002f66:	6145                	addi	sp,sp,48
    80002f68:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f6a:	4581                	li	a1,0
    80002f6c:	8526                	mv	a0,s1
    80002f6e:	2f3020ef          	jal	80005a60 <virtio_disk_rw>
    b->valid = 1;
    80002f72:	4785                	li	a5,1
    80002f74:	c09c                	sw	a5,0(s1)
  return b;
    80002f76:	b7d5                	j	80002f5a <bread+0xb8>

0000000080002f78 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f78:	1101                	addi	sp,sp,-32
    80002f7a:	ec06                	sd	ra,24(sp)
    80002f7c:	e822                	sd	s0,16(sp)
    80002f7e:	e426                	sd	s1,8(sp)
    80002f80:	1000                	addi	s0,sp,32
    80002f82:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f84:	0541                	addi	a0,a0,16
    80002f86:	2d2010ef          	jal	80004258 <holdingsleep>
    80002f8a:	c911                	beqz	a0,80002f9e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f8c:	4585                	li	a1,1
    80002f8e:	8526                	mv	a0,s1
    80002f90:	2d1020ef          	jal	80005a60 <virtio_disk_rw>
}
    80002f94:	60e2                	ld	ra,24(sp)
    80002f96:	6442                	ld	s0,16(sp)
    80002f98:	64a2                	ld	s1,8(sp)
    80002f9a:	6105                	addi	sp,sp,32
    80002f9c:	8082                	ret
    panic("bwrite");
    80002f9e:	00004517          	auipc	a0,0x4
    80002fa2:	42250513          	addi	a0,a0,1058 # 800073c0 <etext+0x3c0>
    80002fa6:	87ffd0ef          	jal	80000824 <panic>

0000000080002faa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002faa:	1101                	addi	sp,sp,-32
    80002fac:	ec06                	sd	ra,24(sp)
    80002fae:	e822                	sd	s0,16(sp)
    80002fb0:	e426                	sd	s1,8(sp)
    80002fb2:	e04a                	sd	s2,0(sp)
    80002fb4:	1000                	addi	s0,sp,32
    80002fb6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fb8:	01050913          	addi	s2,a0,16
    80002fbc:	854a                	mv	a0,s2
    80002fbe:	29a010ef          	jal	80004258 <holdingsleep>
    80002fc2:	c125                	beqz	a0,80003022 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002fc4:	854a                	mv	a0,s2
    80002fc6:	25a010ef          	jal	80004220 <releasesleep>

  acquire(&bcache.lock);
    80002fca:	00013517          	auipc	a0,0x13
    80002fce:	c6e50513          	addi	a0,a0,-914 # 80015c38 <bcache>
    80002fd2:	c57fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002fd6:	40bc                	lw	a5,64(s1)
    80002fd8:	37fd                	addiw	a5,a5,-1
    80002fda:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fdc:	e79d                	bnez	a5,8000300a <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fde:	68b8                	ld	a4,80(s1)
    80002fe0:	64bc                	ld	a5,72(s1)
    80002fe2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fe4:	68b8                	ld	a4,80(s1)
    80002fe6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fe8:	0001b797          	auipc	a5,0x1b
    80002fec:	c5078793          	addi	a5,a5,-944 # 8001dc38 <bcache+0x8000>
    80002ff0:	2b87b703          	ld	a4,696(a5)
    80002ff4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ff6:	0001b717          	auipc	a4,0x1b
    80002ffa:	eaa70713          	addi	a4,a4,-342 # 8001dea0 <bcache+0x8268>
    80002ffe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003000:	2b87b703          	ld	a4,696(a5)
    80003004:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003006:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000300a:	00013517          	auipc	a0,0x13
    8000300e:	c2e50513          	addi	a0,a0,-978 # 80015c38 <bcache>
    80003012:	cabfd0ef          	jal	80000cbc <release>
}
    80003016:	60e2                	ld	ra,24(sp)
    80003018:	6442                	ld	s0,16(sp)
    8000301a:	64a2                	ld	s1,8(sp)
    8000301c:	6902                	ld	s2,0(sp)
    8000301e:	6105                	addi	sp,sp,32
    80003020:	8082                	ret
    panic("brelse");
    80003022:	00004517          	auipc	a0,0x4
    80003026:	3a650513          	addi	a0,a0,934 # 800073c8 <etext+0x3c8>
    8000302a:	ffafd0ef          	jal	80000824 <panic>

000000008000302e <bpin>:

void
bpin(struct buf *b) {
    8000302e:	1101                	addi	sp,sp,-32
    80003030:	ec06                	sd	ra,24(sp)
    80003032:	e822                	sd	s0,16(sp)
    80003034:	e426                	sd	s1,8(sp)
    80003036:	1000                	addi	s0,sp,32
    80003038:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000303a:	00013517          	auipc	a0,0x13
    8000303e:	bfe50513          	addi	a0,a0,-1026 # 80015c38 <bcache>
    80003042:	be7fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80003046:	40bc                	lw	a5,64(s1)
    80003048:	2785                	addiw	a5,a5,1
    8000304a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000304c:	00013517          	auipc	a0,0x13
    80003050:	bec50513          	addi	a0,a0,-1044 # 80015c38 <bcache>
    80003054:	c69fd0ef          	jal	80000cbc <release>
}
    80003058:	60e2                	ld	ra,24(sp)
    8000305a:	6442                	ld	s0,16(sp)
    8000305c:	64a2                	ld	s1,8(sp)
    8000305e:	6105                	addi	sp,sp,32
    80003060:	8082                	ret

0000000080003062 <bunpin>:

void
bunpin(struct buf *b) {
    80003062:	1101                	addi	sp,sp,-32
    80003064:	ec06                	sd	ra,24(sp)
    80003066:	e822                	sd	s0,16(sp)
    80003068:	e426                	sd	s1,8(sp)
    8000306a:	1000                	addi	s0,sp,32
    8000306c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000306e:	00013517          	auipc	a0,0x13
    80003072:	bca50513          	addi	a0,a0,-1078 # 80015c38 <bcache>
    80003076:	bb3fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    8000307a:	40bc                	lw	a5,64(s1)
    8000307c:	37fd                	addiw	a5,a5,-1
    8000307e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003080:	00013517          	auipc	a0,0x13
    80003084:	bb850513          	addi	a0,a0,-1096 # 80015c38 <bcache>
    80003088:	c35fd0ef          	jal	80000cbc <release>
}
    8000308c:	60e2                	ld	ra,24(sp)
    8000308e:	6442                	ld	s0,16(sp)
    80003090:	64a2                	ld	s1,8(sp)
    80003092:	6105                	addi	sp,sp,32
    80003094:	8082                	ret

0000000080003096 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003096:	1101                	addi	sp,sp,-32
    80003098:	ec06                	sd	ra,24(sp)
    8000309a:	e822                	sd	s0,16(sp)
    8000309c:	e426                	sd	s1,8(sp)
    8000309e:	e04a                	sd	s2,0(sp)
    800030a0:	1000                	addi	s0,sp,32
    800030a2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030a4:	00d5d79b          	srliw	a5,a1,0xd
    800030a8:	0001b597          	auipc	a1,0x1b
    800030ac:	26c5a583          	lw	a1,620(a1) # 8001e314 <sb+0x1c>
    800030b0:	9dbd                	addw	a1,a1,a5
    800030b2:	df1ff0ef          	jal	80002ea2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030b6:	0074f713          	andi	a4,s1,7
    800030ba:	4785                	li	a5,1
    800030bc:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800030c0:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800030c2:	90d9                	srli	s1,s1,0x36
    800030c4:	00950733          	add	a4,a0,s1
    800030c8:	05874703          	lbu	a4,88(a4)
    800030cc:	00e7f6b3          	and	a3,a5,a4
    800030d0:	c29d                	beqz	a3,800030f6 <bfree+0x60>
    800030d2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030d4:	94aa                	add	s1,s1,a0
    800030d6:	fff7c793          	not	a5,a5
    800030da:	8f7d                	and	a4,a4,a5
    800030dc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030e0:	000010ef          	jal	800040e0 <log_write>
  brelse(bp);
    800030e4:	854a                	mv	a0,s2
    800030e6:	ec5ff0ef          	jal	80002faa <brelse>
}
    800030ea:	60e2                	ld	ra,24(sp)
    800030ec:	6442                	ld	s0,16(sp)
    800030ee:	64a2                	ld	s1,8(sp)
    800030f0:	6902                	ld	s2,0(sp)
    800030f2:	6105                	addi	sp,sp,32
    800030f4:	8082                	ret
    panic("freeing free block");
    800030f6:	00004517          	auipc	a0,0x4
    800030fa:	2da50513          	addi	a0,a0,730 # 800073d0 <etext+0x3d0>
    800030fe:	f26fd0ef          	jal	80000824 <panic>

0000000080003102 <balloc>:
{
    80003102:	715d                	addi	sp,sp,-80
    80003104:	e486                	sd	ra,72(sp)
    80003106:	e0a2                	sd	s0,64(sp)
    80003108:	fc26                	sd	s1,56(sp)
    8000310a:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    8000310c:	0001b797          	auipc	a5,0x1b
    80003110:	1f07a783          	lw	a5,496(a5) # 8001e2fc <sb+0x4>
    80003114:	0e078263          	beqz	a5,800031f8 <balloc+0xf6>
    80003118:	f84a                	sd	s2,48(sp)
    8000311a:	f44e                	sd	s3,40(sp)
    8000311c:	f052                	sd	s4,32(sp)
    8000311e:	ec56                	sd	s5,24(sp)
    80003120:	e85a                	sd	s6,16(sp)
    80003122:	e45e                	sd	s7,8(sp)
    80003124:	e062                	sd	s8,0(sp)
    80003126:	8baa                	mv	s7,a0
    80003128:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000312a:	0001bb17          	auipc	s6,0x1b
    8000312e:	1ceb0b13          	addi	s6,s6,462 # 8001e2f8 <sb>
      m = 1 << (bi % 8);
    80003132:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003134:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003136:	6c09                	lui	s8,0x2
    80003138:	a09d                	j	8000319e <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000313a:	97ca                	add	a5,a5,s2
    8000313c:	8e55                	or	a2,a2,a3
    8000313e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003142:	854a                	mv	a0,s2
    80003144:	79d000ef          	jal	800040e0 <log_write>
        brelse(bp);
    80003148:	854a                	mv	a0,s2
    8000314a:	e61ff0ef          	jal	80002faa <brelse>
  bp = bread(dev, bno);
    8000314e:	85a6                	mv	a1,s1
    80003150:	855e                	mv	a0,s7
    80003152:	d51ff0ef          	jal	80002ea2 <bread>
    80003156:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003158:	40000613          	li	a2,1024
    8000315c:	4581                	li	a1,0
    8000315e:	05850513          	addi	a0,a0,88
    80003162:	b97fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80003166:	854a                	mv	a0,s2
    80003168:	779000ef          	jal	800040e0 <log_write>
  brelse(bp);
    8000316c:	854a                	mv	a0,s2
    8000316e:	e3dff0ef          	jal	80002faa <brelse>
}
    80003172:	7942                	ld	s2,48(sp)
    80003174:	79a2                	ld	s3,40(sp)
    80003176:	7a02                	ld	s4,32(sp)
    80003178:	6ae2                	ld	s5,24(sp)
    8000317a:	6b42                	ld	s6,16(sp)
    8000317c:	6ba2                	ld	s7,8(sp)
    8000317e:	6c02                	ld	s8,0(sp)
}
    80003180:	8526                	mv	a0,s1
    80003182:	60a6                	ld	ra,72(sp)
    80003184:	6406                	ld	s0,64(sp)
    80003186:	74e2                	ld	s1,56(sp)
    80003188:	6161                	addi	sp,sp,80
    8000318a:	8082                	ret
    brelse(bp);
    8000318c:	854a                	mv	a0,s2
    8000318e:	e1dff0ef          	jal	80002faa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003192:	015c0abb          	addw	s5,s8,s5
    80003196:	004b2783          	lw	a5,4(s6)
    8000319a:	04faf863          	bgeu	s5,a5,800031ea <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    8000319e:	40dad59b          	sraiw	a1,s5,0xd
    800031a2:	01cb2783          	lw	a5,28(s6)
    800031a6:	9dbd                	addw	a1,a1,a5
    800031a8:	855e                	mv	a0,s7
    800031aa:	cf9ff0ef          	jal	80002ea2 <bread>
    800031ae:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b0:	004b2503          	lw	a0,4(s6)
    800031b4:	84d6                	mv	s1,s5
    800031b6:	4701                	li	a4,0
    800031b8:	fca4fae3          	bgeu	s1,a0,8000318c <balloc+0x8a>
      m = 1 << (bi % 8);
    800031bc:	00777693          	andi	a3,a4,7
    800031c0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031c4:	41f7579b          	sraiw	a5,a4,0x1f
    800031c8:	01d7d79b          	srliw	a5,a5,0x1d
    800031cc:	9fb9                	addw	a5,a5,a4
    800031ce:	4037d79b          	sraiw	a5,a5,0x3
    800031d2:	00f90633          	add	a2,s2,a5
    800031d6:	05864603          	lbu	a2,88(a2)
    800031da:	00c6f5b3          	and	a1,a3,a2
    800031de:	ddb1                	beqz	a1,8000313a <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031e0:	2705                	addiw	a4,a4,1
    800031e2:	2485                	addiw	s1,s1,1
    800031e4:	fd471ae3          	bne	a4,s4,800031b8 <balloc+0xb6>
    800031e8:	b755                	j	8000318c <balloc+0x8a>
    800031ea:	7942                	ld	s2,48(sp)
    800031ec:	79a2                	ld	s3,40(sp)
    800031ee:	7a02                	ld	s4,32(sp)
    800031f0:	6ae2                	ld	s5,24(sp)
    800031f2:	6b42                	ld	s6,16(sp)
    800031f4:	6ba2                	ld	s7,8(sp)
    800031f6:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800031f8:	00004517          	auipc	a0,0x4
    800031fc:	1f050513          	addi	a0,a0,496 # 800073e8 <etext+0x3e8>
    80003200:	afafd0ef          	jal	800004fa <printf>
  return 0;
    80003204:	4481                	li	s1,0
    80003206:	bfad                	j	80003180 <balloc+0x7e>

0000000080003208 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003208:	7179                	addi	sp,sp,-48
    8000320a:	f406                	sd	ra,40(sp)
    8000320c:	f022                	sd	s0,32(sp)
    8000320e:	ec26                	sd	s1,24(sp)
    80003210:	e84a                	sd	s2,16(sp)
    80003212:	e44e                	sd	s3,8(sp)
    80003214:	1800                	addi	s0,sp,48
    80003216:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003218:	47ad                	li	a5,11
    8000321a:	02b7e363          	bltu	a5,a1,80003240 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000321e:	02059793          	slli	a5,a1,0x20
    80003222:	01e7d593          	srli	a1,a5,0x1e
    80003226:	00b509b3          	add	s3,a0,a1
    8000322a:	0509a483          	lw	s1,80(s3)
    8000322e:	e0b5                	bnez	s1,80003292 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003230:	4108                	lw	a0,0(a0)
    80003232:	ed1ff0ef          	jal	80003102 <balloc>
    80003236:	84aa                	mv	s1,a0
      if(addr == 0)
    80003238:	cd29                	beqz	a0,80003292 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000323a:	04a9a823          	sw	a0,80(s3)
    8000323e:	a891                	j	80003292 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003240:	ff45879b          	addiw	a5,a1,-12
    80003244:	873e                	mv	a4,a5
    80003246:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003248:	0ff00793          	li	a5,255
    8000324c:	06e7e763          	bltu	a5,a4,800032ba <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003250:	08052483          	lw	s1,128(a0)
    80003254:	e891                	bnez	s1,80003268 <bmap+0x60>
      addr = balloc(ip->dev);
    80003256:	4108                	lw	a0,0(a0)
    80003258:	eabff0ef          	jal	80003102 <balloc>
    8000325c:	84aa                	mv	s1,a0
      if(addr == 0)
    8000325e:	c915                	beqz	a0,80003292 <bmap+0x8a>
    80003260:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003262:	08a92023          	sw	a0,128(s2)
    80003266:	a011                	j	8000326a <bmap+0x62>
    80003268:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000326a:	85a6                	mv	a1,s1
    8000326c:	00092503          	lw	a0,0(s2)
    80003270:	c33ff0ef          	jal	80002ea2 <bread>
    80003274:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003276:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000327a:	02099713          	slli	a4,s3,0x20
    8000327e:	01e75593          	srli	a1,a4,0x1e
    80003282:	97ae                	add	a5,a5,a1
    80003284:	89be                	mv	s3,a5
    80003286:	4384                	lw	s1,0(a5)
    80003288:	cc89                	beqz	s1,800032a2 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000328a:	8552                	mv	a0,s4
    8000328c:	d1fff0ef          	jal	80002faa <brelse>
    return addr;
    80003290:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003292:	8526                	mv	a0,s1
    80003294:	70a2                	ld	ra,40(sp)
    80003296:	7402                	ld	s0,32(sp)
    80003298:	64e2                	ld	s1,24(sp)
    8000329a:	6942                	ld	s2,16(sp)
    8000329c:	69a2                	ld	s3,8(sp)
    8000329e:	6145                	addi	sp,sp,48
    800032a0:	8082                	ret
      addr = balloc(ip->dev);
    800032a2:	00092503          	lw	a0,0(s2)
    800032a6:	e5dff0ef          	jal	80003102 <balloc>
    800032aa:	84aa                	mv	s1,a0
      if(addr){
    800032ac:	dd79                	beqz	a0,8000328a <bmap+0x82>
        a[bn] = addr;
    800032ae:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800032b2:	8552                	mv	a0,s4
    800032b4:	62d000ef          	jal	800040e0 <log_write>
    800032b8:	bfc9                	j	8000328a <bmap+0x82>
    800032ba:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800032bc:	00004517          	auipc	a0,0x4
    800032c0:	14450513          	addi	a0,a0,324 # 80007400 <etext+0x400>
    800032c4:	d60fd0ef          	jal	80000824 <panic>

00000000800032c8 <iget>:
{
    800032c8:	7179                	addi	sp,sp,-48
    800032ca:	f406                	sd	ra,40(sp)
    800032cc:	f022                	sd	s0,32(sp)
    800032ce:	ec26                	sd	s1,24(sp)
    800032d0:	e84a                	sd	s2,16(sp)
    800032d2:	e44e                	sd	s3,8(sp)
    800032d4:	e052                	sd	s4,0(sp)
    800032d6:	1800                	addi	s0,sp,48
    800032d8:	892a                	mv	s2,a0
    800032da:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800032dc:	0001b517          	auipc	a0,0x1b
    800032e0:	03c50513          	addi	a0,a0,60 # 8001e318 <itable>
    800032e4:	945fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800032e8:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032ea:	0001b497          	auipc	s1,0x1b
    800032ee:	04648493          	addi	s1,s1,70 # 8001e330 <itable+0x18>
    800032f2:	0001d697          	auipc	a3,0x1d
    800032f6:	ace68693          	addi	a3,a3,-1330 # 8001fdc0 <log>
    800032fa:	a809                	j	8000330c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032fc:	e781                	bnez	a5,80003304 <iget+0x3c>
    800032fe:	00099363          	bnez	s3,80003304 <iget+0x3c>
      empty = ip;
    80003302:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003304:	08848493          	addi	s1,s1,136
    80003308:	02d48563          	beq	s1,a3,80003332 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000330c:	449c                	lw	a5,8(s1)
    8000330e:	fef057e3          	blez	a5,800032fc <iget+0x34>
    80003312:	4098                	lw	a4,0(s1)
    80003314:	ff2718e3          	bne	a4,s2,80003304 <iget+0x3c>
    80003318:	40d8                	lw	a4,4(s1)
    8000331a:	ff4715e3          	bne	a4,s4,80003304 <iget+0x3c>
      ip->ref++;
    8000331e:	2785                	addiw	a5,a5,1
    80003320:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003322:	0001b517          	auipc	a0,0x1b
    80003326:	ff650513          	addi	a0,a0,-10 # 8001e318 <itable>
    8000332a:	993fd0ef          	jal	80000cbc <release>
      return ip;
    8000332e:	89a6                	mv	s3,s1
    80003330:	a015                	j	80003354 <iget+0x8c>
  if(empty == 0)
    80003332:	02098a63          	beqz	s3,80003366 <iget+0x9e>
  ip->dev = dev;
    80003336:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000333a:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000333e:	4785                	li	a5,1
    80003340:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003344:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003348:	0001b517          	auipc	a0,0x1b
    8000334c:	fd050513          	addi	a0,a0,-48 # 8001e318 <itable>
    80003350:	96dfd0ef          	jal	80000cbc <release>
}
    80003354:	854e                	mv	a0,s3
    80003356:	70a2                	ld	ra,40(sp)
    80003358:	7402                	ld	s0,32(sp)
    8000335a:	64e2                	ld	s1,24(sp)
    8000335c:	6942                	ld	s2,16(sp)
    8000335e:	69a2                	ld	s3,8(sp)
    80003360:	6a02                	ld	s4,0(sp)
    80003362:	6145                	addi	sp,sp,48
    80003364:	8082                	ret
    panic("iget: no inodes");
    80003366:	00004517          	auipc	a0,0x4
    8000336a:	0b250513          	addi	a0,a0,178 # 80007418 <etext+0x418>
    8000336e:	cb6fd0ef          	jal	80000824 <panic>

0000000080003372 <iinit>:
{
    80003372:	7179                	addi	sp,sp,-48
    80003374:	f406                	sd	ra,40(sp)
    80003376:	f022                	sd	s0,32(sp)
    80003378:	ec26                	sd	s1,24(sp)
    8000337a:	e84a                	sd	s2,16(sp)
    8000337c:	e44e                	sd	s3,8(sp)
    8000337e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003380:	00004597          	auipc	a1,0x4
    80003384:	0a858593          	addi	a1,a1,168 # 80007428 <etext+0x428>
    80003388:	0001b517          	auipc	a0,0x1b
    8000338c:	f9050513          	addi	a0,a0,-112 # 8001e318 <itable>
    80003390:	80ffd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003394:	0001b497          	auipc	s1,0x1b
    80003398:	fac48493          	addi	s1,s1,-84 # 8001e340 <itable+0x28>
    8000339c:	0001d997          	auipc	s3,0x1d
    800033a0:	a3498993          	addi	s3,s3,-1484 # 8001fdd0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800033a4:	00004917          	auipc	s2,0x4
    800033a8:	08c90913          	addi	s2,s2,140 # 80007430 <etext+0x430>
    800033ac:	85ca                	mv	a1,s2
    800033ae:	8526                	mv	a0,s1
    800033b0:	5f5000ef          	jal	800041a4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800033b4:	08848493          	addi	s1,s1,136
    800033b8:	ff349ae3          	bne	s1,s3,800033ac <iinit+0x3a>
}
    800033bc:	70a2                	ld	ra,40(sp)
    800033be:	7402                	ld	s0,32(sp)
    800033c0:	64e2                	ld	s1,24(sp)
    800033c2:	6942                	ld	s2,16(sp)
    800033c4:	69a2                	ld	s3,8(sp)
    800033c6:	6145                	addi	sp,sp,48
    800033c8:	8082                	ret

00000000800033ca <ialloc>:
{
    800033ca:	7139                	addi	sp,sp,-64
    800033cc:	fc06                	sd	ra,56(sp)
    800033ce:	f822                	sd	s0,48(sp)
    800033d0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800033d2:	0001b717          	auipc	a4,0x1b
    800033d6:	f3272703          	lw	a4,-206(a4) # 8001e304 <sb+0xc>
    800033da:	4785                	li	a5,1
    800033dc:	06e7f063          	bgeu	a5,a4,8000343c <ialloc+0x72>
    800033e0:	f426                	sd	s1,40(sp)
    800033e2:	f04a                	sd	s2,32(sp)
    800033e4:	ec4e                	sd	s3,24(sp)
    800033e6:	e852                	sd	s4,16(sp)
    800033e8:	e456                	sd	s5,8(sp)
    800033ea:	e05a                	sd	s6,0(sp)
    800033ec:	8aaa                	mv	s5,a0
    800033ee:	8b2e                	mv	s6,a1
    800033f0:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800033f2:	0001ba17          	auipc	s4,0x1b
    800033f6:	f06a0a13          	addi	s4,s4,-250 # 8001e2f8 <sb>
    800033fa:	00495593          	srli	a1,s2,0x4
    800033fe:	018a2783          	lw	a5,24(s4)
    80003402:	9dbd                	addw	a1,a1,a5
    80003404:	8556                	mv	a0,s5
    80003406:	a9dff0ef          	jal	80002ea2 <bread>
    8000340a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000340c:	05850993          	addi	s3,a0,88
    80003410:	00f97793          	andi	a5,s2,15
    80003414:	079a                	slli	a5,a5,0x6
    80003416:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003418:	00099783          	lh	a5,0(s3)
    8000341c:	cb9d                	beqz	a5,80003452 <ialloc+0x88>
    brelse(bp);
    8000341e:	b8dff0ef          	jal	80002faa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003422:	0905                	addi	s2,s2,1
    80003424:	00ca2703          	lw	a4,12(s4)
    80003428:	0009079b          	sext.w	a5,s2
    8000342c:	fce7e7e3          	bltu	a5,a4,800033fa <ialloc+0x30>
    80003430:	74a2                	ld	s1,40(sp)
    80003432:	7902                	ld	s2,32(sp)
    80003434:	69e2                	ld	s3,24(sp)
    80003436:	6a42                	ld	s4,16(sp)
    80003438:	6aa2                	ld	s5,8(sp)
    8000343a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000343c:	00004517          	auipc	a0,0x4
    80003440:	ffc50513          	addi	a0,a0,-4 # 80007438 <etext+0x438>
    80003444:	8b6fd0ef          	jal	800004fa <printf>
  return 0;
    80003448:	4501                	li	a0,0
}
    8000344a:	70e2                	ld	ra,56(sp)
    8000344c:	7442                	ld	s0,48(sp)
    8000344e:	6121                	addi	sp,sp,64
    80003450:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003452:	04000613          	li	a2,64
    80003456:	4581                	li	a1,0
    80003458:	854e                	mv	a0,s3
    8000345a:	89ffd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    8000345e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003462:	8526                	mv	a0,s1
    80003464:	47d000ef          	jal	800040e0 <log_write>
      brelse(bp);
    80003468:	8526                	mv	a0,s1
    8000346a:	b41ff0ef          	jal	80002faa <brelse>
      return iget(dev, inum);
    8000346e:	0009059b          	sext.w	a1,s2
    80003472:	8556                	mv	a0,s5
    80003474:	e55ff0ef          	jal	800032c8 <iget>
    80003478:	74a2                	ld	s1,40(sp)
    8000347a:	7902                	ld	s2,32(sp)
    8000347c:	69e2                	ld	s3,24(sp)
    8000347e:	6a42                	ld	s4,16(sp)
    80003480:	6aa2                	ld	s5,8(sp)
    80003482:	6b02                	ld	s6,0(sp)
    80003484:	b7d9                	j	8000344a <ialloc+0x80>

0000000080003486 <iupdate>:
{
    80003486:	1101                	addi	sp,sp,-32
    80003488:	ec06                	sd	ra,24(sp)
    8000348a:	e822                	sd	s0,16(sp)
    8000348c:	e426                	sd	s1,8(sp)
    8000348e:	e04a                	sd	s2,0(sp)
    80003490:	1000                	addi	s0,sp,32
    80003492:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003494:	415c                	lw	a5,4(a0)
    80003496:	0047d79b          	srliw	a5,a5,0x4
    8000349a:	0001b597          	auipc	a1,0x1b
    8000349e:	e765a583          	lw	a1,-394(a1) # 8001e310 <sb+0x18>
    800034a2:	9dbd                	addw	a1,a1,a5
    800034a4:	4108                	lw	a0,0(a0)
    800034a6:	9fdff0ef          	jal	80002ea2 <bread>
    800034aa:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034ac:	05850793          	addi	a5,a0,88
    800034b0:	40d8                	lw	a4,4(s1)
    800034b2:	8b3d                	andi	a4,a4,15
    800034b4:	071a                	slli	a4,a4,0x6
    800034b6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800034b8:	04449703          	lh	a4,68(s1)
    800034bc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800034c0:	04649703          	lh	a4,70(s1)
    800034c4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800034c8:	04849703          	lh	a4,72(s1)
    800034cc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800034d0:	04a49703          	lh	a4,74(s1)
    800034d4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800034d8:	44f8                	lw	a4,76(s1)
    800034da:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800034dc:	03400613          	li	a2,52
    800034e0:	05048593          	addi	a1,s1,80
    800034e4:	00c78513          	addi	a0,a5,12
    800034e8:	871fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    800034ec:	854a                	mv	a0,s2
    800034ee:	3f3000ef          	jal	800040e0 <log_write>
  brelse(bp);
    800034f2:	854a                	mv	a0,s2
    800034f4:	ab7ff0ef          	jal	80002faa <brelse>
}
    800034f8:	60e2                	ld	ra,24(sp)
    800034fa:	6442                	ld	s0,16(sp)
    800034fc:	64a2                	ld	s1,8(sp)
    800034fe:	6902                	ld	s2,0(sp)
    80003500:	6105                	addi	sp,sp,32
    80003502:	8082                	ret

0000000080003504 <idup>:
{
    80003504:	1101                	addi	sp,sp,-32
    80003506:	ec06                	sd	ra,24(sp)
    80003508:	e822                	sd	s0,16(sp)
    8000350a:	e426                	sd	s1,8(sp)
    8000350c:	1000                	addi	s0,sp,32
    8000350e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003510:	0001b517          	auipc	a0,0x1b
    80003514:	e0850513          	addi	a0,a0,-504 # 8001e318 <itable>
    80003518:	f10fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000351c:	449c                	lw	a5,8(s1)
    8000351e:	2785                	addiw	a5,a5,1
    80003520:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003522:	0001b517          	auipc	a0,0x1b
    80003526:	df650513          	addi	a0,a0,-522 # 8001e318 <itable>
    8000352a:	f92fd0ef          	jal	80000cbc <release>
}
    8000352e:	8526                	mv	a0,s1
    80003530:	60e2                	ld	ra,24(sp)
    80003532:	6442                	ld	s0,16(sp)
    80003534:	64a2                	ld	s1,8(sp)
    80003536:	6105                	addi	sp,sp,32
    80003538:	8082                	ret

000000008000353a <ilock>:
{
    8000353a:	1101                	addi	sp,sp,-32
    8000353c:	ec06                	sd	ra,24(sp)
    8000353e:	e822                	sd	s0,16(sp)
    80003540:	e426                	sd	s1,8(sp)
    80003542:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003544:	cd19                	beqz	a0,80003562 <ilock+0x28>
    80003546:	84aa                	mv	s1,a0
    80003548:	451c                	lw	a5,8(a0)
    8000354a:	00f05c63          	blez	a5,80003562 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000354e:	0541                	addi	a0,a0,16
    80003550:	48b000ef          	jal	800041da <acquiresleep>
  if(ip->valid == 0){
    80003554:	40bc                	lw	a5,64(s1)
    80003556:	cf89                	beqz	a5,80003570 <ilock+0x36>
}
    80003558:	60e2                	ld	ra,24(sp)
    8000355a:	6442                	ld	s0,16(sp)
    8000355c:	64a2                	ld	s1,8(sp)
    8000355e:	6105                	addi	sp,sp,32
    80003560:	8082                	ret
    80003562:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003564:	00004517          	auipc	a0,0x4
    80003568:	eec50513          	addi	a0,a0,-276 # 80007450 <etext+0x450>
    8000356c:	ab8fd0ef          	jal	80000824 <panic>
    80003570:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003572:	40dc                	lw	a5,4(s1)
    80003574:	0047d79b          	srliw	a5,a5,0x4
    80003578:	0001b597          	auipc	a1,0x1b
    8000357c:	d985a583          	lw	a1,-616(a1) # 8001e310 <sb+0x18>
    80003580:	9dbd                	addw	a1,a1,a5
    80003582:	4088                	lw	a0,0(s1)
    80003584:	91fff0ef          	jal	80002ea2 <bread>
    80003588:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000358a:	05850593          	addi	a1,a0,88
    8000358e:	40dc                	lw	a5,4(s1)
    80003590:	8bbd                	andi	a5,a5,15
    80003592:	079a                	slli	a5,a5,0x6
    80003594:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003596:	00059783          	lh	a5,0(a1)
    8000359a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000359e:	00259783          	lh	a5,2(a1)
    800035a2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800035a6:	00459783          	lh	a5,4(a1)
    800035aa:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800035ae:	00659783          	lh	a5,6(a1)
    800035b2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800035b6:	459c                	lw	a5,8(a1)
    800035b8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800035ba:	03400613          	li	a2,52
    800035be:	05b1                	addi	a1,a1,12
    800035c0:	05048513          	addi	a0,s1,80
    800035c4:	f94fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    800035c8:	854a                	mv	a0,s2
    800035ca:	9e1ff0ef          	jal	80002faa <brelse>
    ip->valid = 1;
    800035ce:	4785                	li	a5,1
    800035d0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800035d2:	04449783          	lh	a5,68(s1)
    800035d6:	c399                	beqz	a5,800035dc <ilock+0xa2>
    800035d8:	6902                	ld	s2,0(sp)
    800035da:	bfbd                	j	80003558 <ilock+0x1e>
      panic("ilock: no type");
    800035dc:	00004517          	auipc	a0,0x4
    800035e0:	e7c50513          	addi	a0,a0,-388 # 80007458 <etext+0x458>
    800035e4:	a40fd0ef          	jal	80000824 <panic>

00000000800035e8 <iunlock>:
{
    800035e8:	1101                	addi	sp,sp,-32
    800035ea:	ec06                	sd	ra,24(sp)
    800035ec:	e822                	sd	s0,16(sp)
    800035ee:	e426                	sd	s1,8(sp)
    800035f0:	e04a                	sd	s2,0(sp)
    800035f2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800035f4:	c505                	beqz	a0,8000361c <iunlock+0x34>
    800035f6:	84aa                	mv	s1,a0
    800035f8:	01050913          	addi	s2,a0,16
    800035fc:	854a                	mv	a0,s2
    800035fe:	45b000ef          	jal	80004258 <holdingsleep>
    80003602:	cd09                	beqz	a0,8000361c <iunlock+0x34>
    80003604:	449c                	lw	a5,8(s1)
    80003606:	00f05b63          	blez	a5,8000361c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000360a:	854a                	mv	a0,s2
    8000360c:	415000ef          	jal	80004220 <releasesleep>
}
    80003610:	60e2                	ld	ra,24(sp)
    80003612:	6442                	ld	s0,16(sp)
    80003614:	64a2                	ld	s1,8(sp)
    80003616:	6902                	ld	s2,0(sp)
    80003618:	6105                	addi	sp,sp,32
    8000361a:	8082                	ret
    panic("iunlock");
    8000361c:	00004517          	auipc	a0,0x4
    80003620:	e4c50513          	addi	a0,a0,-436 # 80007468 <etext+0x468>
    80003624:	a00fd0ef          	jal	80000824 <panic>

0000000080003628 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003628:	7179                	addi	sp,sp,-48
    8000362a:	f406                	sd	ra,40(sp)
    8000362c:	f022                	sd	s0,32(sp)
    8000362e:	ec26                	sd	s1,24(sp)
    80003630:	e84a                	sd	s2,16(sp)
    80003632:	e44e                	sd	s3,8(sp)
    80003634:	1800                	addi	s0,sp,48
    80003636:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003638:	05050493          	addi	s1,a0,80
    8000363c:	08050913          	addi	s2,a0,128
    80003640:	a021                	j	80003648 <itrunc+0x20>
    80003642:	0491                	addi	s1,s1,4
    80003644:	01248b63          	beq	s1,s2,8000365a <itrunc+0x32>
    if(ip->addrs[i]){
    80003648:	408c                	lw	a1,0(s1)
    8000364a:	dde5                	beqz	a1,80003642 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000364c:	0009a503          	lw	a0,0(s3)
    80003650:	a47ff0ef          	jal	80003096 <bfree>
      ip->addrs[i] = 0;
    80003654:	0004a023          	sw	zero,0(s1)
    80003658:	b7ed                	j	80003642 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000365a:	0809a583          	lw	a1,128(s3)
    8000365e:	ed89                	bnez	a1,80003678 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003660:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003664:	854e                	mv	a0,s3
    80003666:	e21ff0ef          	jal	80003486 <iupdate>
}
    8000366a:	70a2                	ld	ra,40(sp)
    8000366c:	7402                	ld	s0,32(sp)
    8000366e:	64e2                	ld	s1,24(sp)
    80003670:	6942                	ld	s2,16(sp)
    80003672:	69a2                	ld	s3,8(sp)
    80003674:	6145                	addi	sp,sp,48
    80003676:	8082                	ret
    80003678:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000367a:	0009a503          	lw	a0,0(s3)
    8000367e:	825ff0ef          	jal	80002ea2 <bread>
    80003682:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003684:	05850493          	addi	s1,a0,88
    80003688:	45850913          	addi	s2,a0,1112
    8000368c:	a021                	j	80003694 <itrunc+0x6c>
    8000368e:	0491                	addi	s1,s1,4
    80003690:	01248963          	beq	s1,s2,800036a2 <itrunc+0x7a>
      if(a[j])
    80003694:	408c                	lw	a1,0(s1)
    80003696:	dde5                	beqz	a1,8000368e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003698:	0009a503          	lw	a0,0(s3)
    8000369c:	9fbff0ef          	jal	80003096 <bfree>
    800036a0:	b7fd                	j	8000368e <itrunc+0x66>
    brelse(bp);
    800036a2:	8552                	mv	a0,s4
    800036a4:	907ff0ef          	jal	80002faa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800036a8:	0809a583          	lw	a1,128(s3)
    800036ac:	0009a503          	lw	a0,0(s3)
    800036b0:	9e7ff0ef          	jal	80003096 <bfree>
    ip->addrs[NDIRECT] = 0;
    800036b4:	0809a023          	sw	zero,128(s3)
    800036b8:	6a02                	ld	s4,0(sp)
    800036ba:	b75d                	j	80003660 <itrunc+0x38>

00000000800036bc <iput>:
{
    800036bc:	1101                	addi	sp,sp,-32
    800036be:	ec06                	sd	ra,24(sp)
    800036c0:	e822                	sd	s0,16(sp)
    800036c2:	e426                	sd	s1,8(sp)
    800036c4:	1000                	addi	s0,sp,32
    800036c6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036c8:	0001b517          	auipc	a0,0x1b
    800036cc:	c5050513          	addi	a0,a0,-944 # 8001e318 <itable>
    800036d0:	d58fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800036d4:	4498                	lw	a4,8(s1)
    800036d6:	4785                	li	a5,1
    800036d8:	02f70063          	beq	a4,a5,800036f8 <iput+0x3c>
  ip->ref--;
    800036dc:	449c                	lw	a5,8(s1)
    800036de:	37fd                	addiw	a5,a5,-1
    800036e0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036e2:	0001b517          	auipc	a0,0x1b
    800036e6:	c3650513          	addi	a0,a0,-970 # 8001e318 <itable>
    800036ea:	dd2fd0ef          	jal	80000cbc <release>
}
    800036ee:	60e2                	ld	ra,24(sp)
    800036f0:	6442                	ld	s0,16(sp)
    800036f2:	64a2                	ld	s1,8(sp)
    800036f4:	6105                	addi	sp,sp,32
    800036f6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800036f8:	40bc                	lw	a5,64(s1)
    800036fa:	d3ed                	beqz	a5,800036dc <iput+0x20>
    800036fc:	04a49783          	lh	a5,74(s1)
    80003700:	fff1                	bnez	a5,800036dc <iput+0x20>
    80003702:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003704:	01048793          	addi	a5,s1,16
    80003708:	893e                	mv	s2,a5
    8000370a:	853e                	mv	a0,a5
    8000370c:	2cf000ef          	jal	800041da <acquiresleep>
    release(&itable.lock);
    80003710:	0001b517          	auipc	a0,0x1b
    80003714:	c0850513          	addi	a0,a0,-1016 # 8001e318 <itable>
    80003718:	da4fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    8000371c:	8526                	mv	a0,s1
    8000371e:	f0bff0ef          	jal	80003628 <itrunc>
    ip->type = 0;
    80003722:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003726:	8526                	mv	a0,s1
    80003728:	d5fff0ef          	jal	80003486 <iupdate>
    ip->valid = 0;
    8000372c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003730:	854a                	mv	a0,s2
    80003732:	2ef000ef          	jal	80004220 <releasesleep>
    acquire(&itable.lock);
    80003736:	0001b517          	auipc	a0,0x1b
    8000373a:	be250513          	addi	a0,a0,-1054 # 8001e318 <itable>
    8000373e:	ceafd0ef          	jal	80000c28 <acquire>
    80003742:	6902                	ld	s2,0(sp)
    80003744:	bf61                	j	800036dc <iput+0x20>

0000000080003746 <iunlockput>:
{
    80003746:	1101                	addi	sp,sp,-32
    80003748:	ec06                	sd	ra,24(sp)
    8000374a:	e822                	sd	s0,16(sp)
    8000374c:	e426                	sd	s1,8(sp)
    8000374e:	1000                	addi	s0,sp,32
    80003750:	84aa                	mv	s1,a0
  iunlock(ip);
    80003752:	e97ff0ef          	jal	800035e8 <iunlock>
  iput(ip);
    80003756:	8526                	mv	a0,s1
    80003758:	f65ff0ef          	jal	800036bc <iput>
}
    8000375c:	60e2                	ld	ra,24(sp)
    8000375e:	6442                	ld	s0,16(sp)
    80003760:	64a2                	ld	s1,8(sp)
    80003762:	6105                	addi	sp,sp,32
    80003764:	8082                	ret

0000000080003766 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003766:	0001b717          	auipc	a4,0x1b
    8000376a:	b9e72703          	lw	a4,-1122(a4) # 8001e304 <sb+0xc>
    8000376e:	4785                	li	a5,1
    80003770:	0ae7fe63          	bgeu	a5,a4,8000382c <ireclaim+0xc6>
{
    80003774:	7139                	addi	sp,sp,-64
    80003776:	fc06                	sd	ra,56(sp)
    80003778:	f822                	sd	s0,48(sp)
    8000377a:	f426                	sd	s1,40(sp)
    8000377c:	f04a                	sd	s2,32(sp)
    8000377e:	ec4e                	sd	s3,24(sp)
    80003780:	e852                	sd	s4,16(sp)
    80003782:	e456                	sd	s5,8(sp)
    80003784:	e05a                	sd	s6,0(sp)
    80003786:	0080                	addi	s0,sp,64
    80003788:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000378a:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000378c:	0001ba17          	auipc	s4,0x1b
    80003790:	b6ca0a13          	addi	s4,s4,-1172 # 8001e2f8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003794:	00004b17          	auipc	s6,0x4
    80003798:	cdcb0b13          	addi	s6,s6,-804 # 80007470 <etext+0x470>
    8000379c:	a099                	j	800037e2 <ireclaim+0x7c>
    8000379e:	85ce                	mv	a1,s3
    800037a0:	855a                	mv	a0,s6
    800037a2:	d59fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800037a6:	85ce                	mv	a1,s3
    800037a8:	8556                	mv	a0,s5
    800037aa:	b1fff0ef          	jal	800032c8 <iget>
    800037ae:	89aa                	mv	s3,a0
    brelse(bp);
    800037b0:	854a                	mv	a0,s2
    800037b2:	ff8ff0ef          	jal	80002faa <brelse>
    if (ip) {
    800037b6:	00098f63          	beqz	s3,800037d4 <ireclaim+0x6e>
      begin_op();
    800037ba:	78c000ef          	jal	80003f46 <begin_op>
      ilock(ip);
    800037be:	854e                	mv	a0,s3
    800037c0:	d7bff0ef          	jal	8000353a <ilock>
      iunlock(ip);
    800037c4:	854e                	mv	a0,s3
    800037c6:	e23ff0ef          	jal	800035e8 <iunlock>
      iput(ip);
    800037ca:	854e                	mv	a0,s3
    800037cc:	ef1ff0ef          	jal	800036bc <iput>
      end_op();
    800037d0:	7e6000ef          	jal	80003fb6 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800037d4:	0485                	addi	s1,s1,1
    800037d6:	00ca2703          	lw	a4,12(s4)
    800037da:	0004879b          	sext.w	a5,s1
    800037de:	02e7fd63          	bgeu	a5,a4,80003818 <ireclaim+0xb2>
    800037e2:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800037e6:	0044d593          	srli	a1,s1,0x4
    800037ea:	018a2783          	lw	a5,24(s4)
    800037ee:	9dbd                	addw	a1,a1,a5
    800037f0:	8556                	mv	a0,s5
    800037f2:	eb0ff0ef          	jal	80002ea2 <bread>
    800037f6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037f8:	05850793          	addi	a5,a0,88
    800037fc:	00f9f713          	andi	a4,s3,15
    80003800:	071a                	slli	a4,a4,0x6
    80003802:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003804:	00079703          	lh	a4,0(a5)
    80003808:	c701                	beqz	a4,80003810 <ireclaim+0xaa>
    8000380a:	00679783          	lh	a5,6(a5)
    8000380e:	dbc1                	beqz	a5,8000379e <ireclaim+0x38>
    brelse(bp);
    80003810:	854a                	mv	a0,s2
    80003812:	f98ff0ef          	jal	80002faa <brelse>
    if (ip) {
    80003816:	bf7d                	j	800037d4 <ireclaim+0x6e>
}
    80003818:	70e2                	ld	ra,56(sp)
    8000381a:	7442                	ld	s0,48(sp)
    8000381c:	74a2                	ld	s1,40(sp)
    8000381e:	7902                	ld	s2,32(sp)
    80003820:	69e2                	ld	s3,24(sp)
    80003822:	6a42                	ld	s4,16(sp)
    80003824:	6aa2                	ld	s5,8(sp)
    80003826:	6b02                	ld	s6,0(sp)
    80003828:	6121                	addi	sp,sp,64
    8000382a:	8082                	ret
    8000382c:	8082                	ret

000000008000382e <fsinit>:
fsinit(int dev) {
    8000382e:	1101                	addi	sp,sp,-32
    80003830:	ec06                	sd	ra,24(sp)
    80003832:	e822                	sd	s0,16(sp)
    80003834:	e426                	sd	s1,8(sp)
    80003836:	e04a                	sd	s2,0(sp)
    80003838:	1000                	addi	s0,sp,32
    8000383a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000383c:	4585                	li	a1,1
    8000383e:	e64ff0ef          	jal	80002ea2 <bread>
    80003842:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003844:	02000613          	li	a2,32
    80003848:	05850593          	addi	a1,a0,88
    8000384c:	0001b517          	auipc	a0,0x1b
    80003850:	aac50513          	addi	a0,a0,-1364 # 8001e2f8 <sb>
    80003854:	d04fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003858:	8526                	mv	a0,s1
    8000385a:	f50ff0ef          	jal	80002faa <brelse>
  if(sb.magic != FSMAGIC)
    8000385e:	0001b717          	auipc	a4,0x1b
    80003862:	a9a72703          	lw	a4,-1382(a4) # 8001e2f8 <sb>
    80003866:	102037b7          	lui	a5,0x10203
    8000386a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000386e:	02f71263          	bne	a4,a5,80003892 <fsinit+0x64>
  initlog(dev, &sb);
    80003872:	0001b597          	auipc	a1,0x1b
    80003876:	a8658593          	addi	a1,a1,-1402 # 8001e2f8 <sb>
    8000387a:	854a                	mv	a0,s2
    8000387c:	648000ef          	jal	80003ec4 <initlog>
  ireclaim(dev);
    80003880:	854a                	mv	a0,s2
    80003882:	ee5ff0ef          	jal	80003766 <ireclaim>
}
    80003886:	60e2                	ld	ra,24(sp)
    80003888:	6442                	ld	s0,16(sp)
    8000388a:	64a2                	ld	s1,8(sp)
    8000388c:	6902                	ld	s2,0(sp)
    8000388e:	6105                	addi	sp,sp,32
    80003890:	8082                	ret
    panic("invalid file system");
    80003892:	00004517          	auipc	a0,0x4
    80003896:	bfe50513          	addi	a0,a0,-1026 # 80007490 <etext+0x490>
    8000389a:	f8bfc0ef          	jal	80000824 <panic>

000000008000389e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000389e:	1141                	addi	sp,sp,-16
    800038a0:	e406                	sd	ra,8(sp)
    800038a2:	e022                	sd	s0,0(sp)
    800038a4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038a6:	411c                	lw	a5,0(a0)
    800038a8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038aa:	415c                	lw	a5,4(a0)
    800038ac:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038ae:	04451783          	lh	a5,68(a0)
    800038b2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038b6:	04a51783          	lh	a5,74(a0)
    800038ba:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038be:	04c56783          	lwu	a5,76(a0)
    800038c2:	e99c                	sd	a5,16(a1)
}
    800038c4:	60a2                	ld	ra,8(sp)
    800038c6:	6402                	ld	s0,0(sp)
    800038c8:	0141                	addi	sp,sp,16
    800038ca:	8082                	ret

00000000800038cc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038cc:	457c                	lw	a5,76(a0)
    800038ce:	0ed7e663          	bltu	a5,a3,800039ba <readi+0xee>
{
    800038d2:	7159                	addi	sp,sp,-112
    800038d4:	f486                	sd	ra,104(sp)
    800038d6:	f0a2                	sd	s0,96(sp)
    800038d8:	eca6                	sd	s1,88(sp)
    800038da:	e0d2                	sd	s4,64(sp)
    800038dc:	fc56                	sd	s5,56(sp)
    800038de:	f85a                	sd	s6,48(sp)
    800038e0:	f45e                	sd	s7,40(sp)
    800038e2:	1880                	addi	s0,sp,112
    800038e4:	8b2a                	mv	s6,a0
    800038e6:	8bae                	mv	s7,a1
    800038e8:	8a32                	mv	s4,a2
    800038ea:	84b6                	mv	s1,a3
    800038ec:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800038ee:	9f35                	addw	a4,a4,a3
    return 0;
    800038f0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800038f2:	0ad76b63          	bltu	a4,a3,800039a8 <readi+0xdc>
    800038f6:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800038f8:	00e7f463          	bgeu	a5,a4,80003900 <readi+0x34>
    n = ip->size - off;
    800038fc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003900:	080a8b63          	beqz	s5,80003996 <readi+0xca>
    80003904:	e8ca                	sd	s2,80(sp)
    80003906:	f062                	sd	s8,32(sp)
    80003908:	ec66                	sd	s9,24(sp)
    8000390a:	e86a                	sd	s10,16(sp)
    8000390c:	e46e                	sd	s11,8(sp)
    8000390e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003910:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003914:	5c7d                	li	s8,-1
    80003916:	a80d                	j	80003948 <readi+0x7c>
    80003918:	020d1d93          	slli	s11,s10,0x20
    8000391c:	020ddd93          	srli	s11,s11,0x20
    80003920:	05890613          	addi	a2,s2,88
    80003924:	86ee                	mv	a3,s11
    80003926:	963e                	add	a2,a2,a5
    80003928:	85d2                	mv	a1,s4
    8000392a:	855e                	mv	a0,s7
    8000392c:	bedfe0ef          	jal	80002518 <either_copyout>
    80003930:	05850363          	beq	a0,s8,80003976 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003934:	854a                	mv	a0,s2
    80003936:	e74ff0ef          	jal	80002faa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000393a:	013d09bb          	addw	s3,s10,s3
    8000393e:	009d04bb          	addw	s1,s10,s1
    80003942:	9a6e                	add	s4,s4,s11
    80003944:	0559f363          	bgeu	s3,s5,8000398a <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003948:	00a4d59b          	srliw	a1,s1,0xa
    8000394c:	855a                	mv	a0,s6
    8000394e:	8bbff0ef          	jal	80003208 <bmap>
    80003952:	85aa                	mv	a1,a0
    if(addr == 0)
    80003954:	c139                	beqz	a0,8000399a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003956:	000b2503          	lw	a0,0(s6)
    8000395a:	d48ff0ef          	jal	80002ea2 <bread>
    8000395e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003960:	3ff4f793          	andi	a5,s1,1023
    80003964:	40fc873b          	subw	a4,s9,a5
    80003968:	413a86bb          	subw	a3,s5,s3
    8000396c:	8d3a                	mv	s10,a4
    8000396e:	fae6f5e3          	bgeu	a3,a4,80003918 <readi+0x4c>
    80003972:	8d36                	mv	s10,a3
    80003974:	b755                	j	80003918 <readi+0x4c>
      brelse(bp);
    80003976:	854a                	mv	a0,s2
    80003978:	e32ff0ef          	jal	80002faa <brelse>
      tot = -1;
    8000397c:	59fd                	li	s3,-1
      break;
    8000397e:	6946                	ld	s2,80(sp)
    80003980:	7c02                	ld	s8,32(sp)
    80003982:	6ce2                	ld	s9,24(sp)
    80003984:	6d42                	ld	s10,16(sp)
    80003986:	6da2                	ld	s11,8(sp)
    80003988:	a831                	j	800039a4 <readi+0xd8>
    8000398a:	6946                	ld	s2,80(sp)
    8000398c:	7c02                	ld	s8,32(sp)
    8000398e:	6ce2                	ld	s9,24(sp)
    80003990:	6d42                	ld	s10,16(sp)
    80003992:	6da2                	ld	s11,8(sp)
    80003994:	a801                	j	800039a4 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003996:	89d6                	mv	s3,s5
    80003998:	a031                	j	800039a4 <readi+0xd8>
    8000399a:	6946                	ld	s2,80(sp)
    8000399c:	7c02                	ld	s8,32(sp)
    8000399e:	6ce2                	ld	s9,24(sp)
    800039a0:	6d42                	ld	s10,16(sp)
    800039a2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800039a4:	854e                	mv	a0,s3
    800039a6:	69a6                	ld	s3,72(sp)
}
    800039a8:	70a6                	ld	ra,104(sp)
    800039aa:	7406                	ld	s0,96(sp)
    800039ac:	64e6                	ld	s1,88(sp)
    800039ae:	6a06                	ld	s4,64(sp)
    800039b0:	7ae2                	ld	s5,56(sp)
    800039b2:	7b42                	ld	s6,48(sp)
    800039b4:	7ba2                	ld	s7,40(sp)
    800039b6:	6165                	addi	sp,sp,112
    800039b8:	8082                	ret
    return 0;
    800039ba:	4501                	li	a0,0
}
    800039bc:	8082                	ret

00000000800039be <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039be:	457c                	lw	a5,76(a0)
    800039c0:	0ed7eb63          	bltu	a5,a3,80003ab6 <writei+0xf8>
{
    800039c4:	7159                	addi	sp,sp,-112
    800039c6:	f486                	sd	ra,104(sp)
    800039c8:	f0a2                	sd	s0,96(sp)
    800039ca:	e8ca                	sd	s2,80(sp)
    800039cc:	e0d2                	sd	s4,64(sp)
    800039ce:	fc56                	sd	s5,56(sp)
    800039d0:	f85a                	sd	s6,48(sp)
    800039d2:	f45e                	sd	s7,40(sp)
    800039d4:	1880                	addi	s0,sp,112
    800039d6:	8aaa                	mv	s5,a0
    800039d8:	8bae                	mv	s7,a1
    800039da:	8a32                	mv	s4,a2
    800039dc:	8936                	mv	s2,a3
    800039de:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039e0:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039e4:	00043737          	lui	a4,0x43
    800039e8:	0cf76963          	bltu	a4,a5,80003aba <writei+0xfc>
    800039ec:	0cd7e763          	bltu	a5,a3,80003aba <writei+0xfc>
    800039f0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039f2:	0a0b0a63          	beqz	s6,80003aa6 <writei+0xe8>
    800039f6:	eca6                	sd	s1,88(sp)
    800039f8:	f062                	sd	s8,32(sp)
    800039fa:	ec66                	sd	s9,24(sp)
    800039fc:	e86a                	sd	s10,16(sp)
    800039fe:	e46e                	sd	s11,8(sp)
    80003a00:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a02:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a06:	5c7d                	li	s8,-1
    80003a08:	a825                	j	80003a40 <writei+0x82>
    80003a0a:	020d1d93          	slli	s11,s10,0x20
    80003a0e:	020ddd93          	srli	s11,s11,0x20
    80003a12:	05848513          	addi	a0,s1,88
    80003a16:	86ee                	mv	a3,s11
    80003a18:	8652                	mv	a2,s4
    80003a1a:	85de                	mv	a1,s7
    80003a1c:	953e                	add	a0,a0,a5
    80003a1e:	b45fe0ef          	jal	80002562 <either_copyin>
    80003a22:	05850663          	beq	a0,s8,80003a6e <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a26:	8526                	mv	a0,s1
    80003a28:	6b8000ef          	jal	800040e0 <log_write>
    brelse(bp);
    80003a2c:	8526                	mv	a0,s1
    80003a2e:	d7cff0ef          	jal	80002faa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a32:	013d09bb          	addw	s3,s10,s3
    80003a36:	012d093b          	addw	s2,s10,s2
    80003a3a:	9a6e                	add	s4,s4,s11
    80003a3c:	0369fc63          	bgeu	s3,s6,80003a74 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003a40:	00a9559b          	srliw	a1,s2,0xa
    80003a44:	8556                	mv	a0,s5
    80003a46:	fc2ff0ef          	jal	80003208 <bmap>
    80003a4a:	85aa                	mv	a1,a0
    if(addr == 0)
    80003a4c:	c505                	beqz	a0,80003a74 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003a4e:	000aa503          	lw	a0,0(s5)
    80003a52:	c50ff0ef          	jal	80002ea2 <bread>
    80003a56:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a58:	3ff97793          	andi	a5,s2,1023
    80003a5c:	40fc873b          	subw	a4,s9,a5
    80003a60:	413b06bb          	subw	a3,s6,s3
    80003a64:	8d3a                	mv	s10,a4
    80003a66:	fae6f2e3          	bgeu	a3,a4,80003a0a <writei+0x4c>
    80003a6a:	8d36                	mv	s10,a3
    80003a6c:	bf79                	j	80003a0a <writei+0x4c>
      brelse(bp);
    80003a6e:	8526                	mv	a0,s1
    80003a70:	d3aff0ef          	jal	80002faa <brelse>
  }

  if(off > ip->size)
    80003a74:	04caa783          	lw	a5,76(s5)
    80003a78:	0327f963          	bgeu	a5,s2,80003aaa <writei+0xec>
    ip->size = off;
    80003a7c:	052aa623          	sw	s2,76(s5)
    80003a80:	64e6                	ld	s1,88(sp)
    80003a82:	7c02                	ld	s8,32(sp)
    80003a84:	6ce2                	ld	s9,24(sp)
    80003a86:	6d42                	ld	s10,16(sp)
    80003a88:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a8a:	8556                	mv	a0,s5
    80003a8c:	9fbff0ef          	jal	80003486 <iupdate>

  return tot;
    80003a90:	854e                	mv	a0,s3
    80003a92:	69a6                	ld	s3,72(sp)
}
    80003a94:	70a6                	ld	ra,104(sp)
    80003a96:	7406                	ld	s0,96(sp)
    80003a98:	6946                	ld	s2,80(sp)
    80003a9a:	6a06                	ld	s4,64(sp)
    80003a9c:	7ae2                	ld	s5,56(sp)
    80003a9e:	7b42                	ld	s6,48(sp)
    80003aa0:	7ba2                	ld	s7,40(sp)
    80003aa2:	6165                	addi	sp,sp,112
    80003aa4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aa6:	89da                	mv	s3,s6
    80003aa8:	b7cd                	j	80003a8a <writei+0xcc>
    80003aaa:	64e6                	ld	s1,88(sp)
    80003aac:	7c02                	ld	s8,32(sp)
    80003aae:	6ce2                	ld	s9,24(sp)
    80003ab0:	6d42                	ld	s10,16(sp)
    80003ab2:	6da2                	ld	s11,8(sp)
    80003ab4:	bfd9                	j	80003a8a <writei+0xcc>
    return -1;
    80003ab6:	557d                	li	a0,-1
}
    80003ab8:	8082                	ret
    return -1;
    80003aba:	557d                	li	a0,-1
    80003abc:	bfe1                	j	80003a94 <writei+0xd6>

0000000080003abe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003abe:	1141                	addi	sp,sp,-16
    80003ac0:	e406                	sd	ra,8(sp)
    80003ac2:	e022                	sd	s0,0(sp)
    80003ac4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ac6:	4639                	li	a2,14
    80003ac8:	b04fd0ef          	jal	80000dcc <strncmp>
}
    80003acc:	60a2                	ld	ra,8(sp)
    80003ace:	6402                	ld	s0,0(sp)
    80003ad0:	0141                	addi	sp,sp,16
    80003ad2:	8082                	ret

0000000080003ad4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ad4:	711d                	addi	sp,sp,-96
    80003ad6:	ec86                	sd	ra,88(sp)
    80003ad8:	e8a2                	sd	s0,80(sp)
    80003ada:	e4a6                	sd	s1,72(sp)
    80003adc:	e0ca                	sd	s2,64(sp)
    80003ade:	fc4e                	sd	s3,56(sp)
    80003ae0:	f852                	sd	s4,48(sp)
    80003ae2:	f456                	sd	s5,40(sp)
    80003ae4:	f05a                	sd	s6,32(sp)
    80003ae6:	ec5e                	sd	s7,24(sp)
    80003ae8:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003aea:	04451703          	lh	a4,68(a0)
    80003aee:	4785                	li	a5,1
    80003af0:	00f71f63          	bne	a4,a5,80003b0e <dirlookup+0x3a>
    80003af4:	892a                	mv	s2,a0
    80003af6:	8aae                	mv	s5,a1
    80003af8:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003afa:	457c                	lw	a5,76(a0)
    80003afc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003afe:	fa040a13          	addi	s4,s0,-96
    80003b02:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003b04:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b08:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b0a:	e39d                	bnez	a5,80003b30 <dirlookup+0x5c>
    80003b0c:	a8b9                	j	80003b6a <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003b0e:	00004517          	auipc	a0,0x4
    80003b12:	99a50513          	addi	a0,a0,-1638 # 800074a8 <etext+0x4a8>
    80003b16:	d0ffc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003b1a:	00004517          	auipc	a0,0x4
    80003b1e:	9a650513          	addi	a0,a0,-1626 # 800074c0 <etext+0x4c0>
    80003b22:	d03fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b26:	24c1                	addiw	s1,s1,16
    80003b28:	04c92783          	lw	a5,76(s2)
    80003b2c:	02f4fe63          	bgeu	s1,a5,80003b68 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b30:	874e                	mv	a4,s3
    80003b32:	86a6                	mv	a3,s1
    80003b34:	8652                	mv	a2,s4
    80003b36:	4581                	li	a1,0
    80003b38:	854a                	mv	a0,s2
    80003b3a:	d93ff0ef          	jal	800038cc <readi>
    80003b3e:	fd351ee3          	bne	a0,s3,80003b1a <dirlookup+0x46>
    if(de.inum == 0)
    80003b42:	fa045783          	lhu	a5,-96(s0)
    80003b46:	d3e5                	beqz	a5,80003b26 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003b48:	85da                	mv	a1,s6
    80003b4a:	8556                	mv	a0,s5
    80003b4c:	f73ff0ef          	jal	80003abe <namecmp>
    80003b50:	f979                	bnez	a0,80003b26 <dirlookup+0x52>
      if(poff)
    80003b52:	000b8463          	beqz	s7,80003b5a <dirlookup+0x86>
        *poff = off;
    80003b56:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003b5a:	fa045583          	lhu	a1,-96(s0)
    80003b5e:	00092503          	lw	a0,0(s2)
    80003b62:	f66ff0ef          	jal	800032c8 <iget>
    80003b66:	a011                	j	80003b6a <dirlookup+0x96>
  return 0;
    80003b68:	4501                	li	a0,0
}
    80003b6a:	60e6                	ld	ra,88(sp)
    80003b6c:	6446                	ld	s0,80(sp)
    80003b6e:	64a6                	ld	s1,72(sp)
    80003b70:	6906                	ld	s2,64(sp)
    80003b72:	79e2                	ld	s3,56(sp)
    80003b74:	7a42                	ld	s4,48(sp)
    80003b76:	7aa2                	ld	s5,40(sp)
    80003b78:	7b02                	ld	s6,32(sp)
    80003b7a:	6be2                	ld	s7,24(sp)
    80003b7c:	6125                	addi	sp,sp,96
    80003b7e:	8082                	ret

0000000080003b80 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b80:	711d                	addi	sp,sp,-96
    80003b82:	ec86                	sd	ra,88(sp)
    80003b84:	e8a2                	sd	s0,80(sp)
    80003b86:	e4a6                	sd	s1,72(sp)
    80003b88:	e0ca                	sd	s2,64(sp)
    80003b8a:	fc4e                	sd	s3,56(sp)
    80003b8c:	f852                	sd	s4,48(sp)
    80003b8e:	f456                	sd	s5,40(sp)
    80003b90:	f05a                	sd	s6,32(sp)
    80003b92:	ec5e                	sd	s7,24(sp)
    80003b94:	e862                	sd	s8,16(sp)
    80003b96:	e466                	sd	s9,8(sp)
    80003b98:	e06a                	sd	s10,0(sp)
    80003b9a:	1080                	addi	s0,sp,96
    80003b9c:	84aa                	mv	s1,a0
    80003b9e:	8b2e                	mv	s6,a1
    80003ba0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ba2:	00054703          	lbu	a4,0(a0)
    80003ba6:	02f00793          	li	a5,47
    80003baa:	00f70f63          	beq	a4,a5,80003bc8 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bae:	dfbfd0ef          	jal	800019a8 <myproc>
    80003bb2:	15053503          	ld	a0,336(a0)
    80003bb6:	94fff0ef          	jal	80003504 <idup>
    80003bba:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003bbc:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003bc0:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003bc2:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003bc4:	4b85                	li	s7,1
    80003bc6:	a879                	j	80003c64 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003bc8:	4585                	li	a1,1
    80003bca:	852e                	mv	a0,a1
    80003bcc:	efcff0ef          	jal	800032c8 <iget>
    80003bd0:	8a2a                	mv	s4,a0
    80003bd2:	b7ed                	j	80003bbc <namex+0x3c>
      iunlockput(ip);
    80003bd4:	8552                	mv	a0,s4
    80003bd6:	b71ff0ef          	jal	80003746 <iunlockput>
      return 0;
    80003bda:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003bdc:	8552                	mv	a0,s4
    80003bde:	60e6                	ld	ra,88(sp)
    80003be0:	6446                	ld	s0,80(sp)
    80003be2:	64a6                	ld	s1,72(sp)
    80003be4:	6906                	ld	s2,64(sp)
    80003be6:	79e2                	ld	s3,56(sp)
    80003be8:	7a42                	ld	s4,48(sp)
    80003bea:	7aa2                	ld	s5,40(sp)
    80003bec:	7b02                	ld	s6,32(sp)
    80003bee:	6be2                	ld	s7,24(sp)
    80003bf0:	6c42                	ld	s8,16(sp)
    80003bf2:	6ca2                	ld	s9,8(sp)
    80003bf4:	6d02                	ld	s10,0(sp)
    80003bf6:	6125                	addi	sp,sp,96
    80003bf8:	8082                	ret
      iunlock(ip);
    80003bfa:	8552                	mv	a0,s4
    80003bfc:	9edff0ef          	jal	800035e8 <iunlock>
      return ip;
    80003c00:	bff1                	j	80003bdc <namex+0x5c>
      iunlockput(ip);
    80003c02:	8552                	mv	a0,s4
    80003c04:	b43ff0ef          	jal	80003746 <iunlockput>
      return 0;
    80003c08:	8a4a                	mv	s4,s2
    80003c0a:	bfc9                	j	80003bdc <namex+0x5c>
  len = path - s;
    80003c0c:	40990633          	sub	a2,s2,s1
    80003c10:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003c14:	09ac5463          	bge	s8,s10,80003c9c <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003c18:	8666                	mv	a2,s9
    80003c1a:	85a6                	mv	a1,s1
    80003c1c:	8556                	mv	a0,s5
    80003c1e:	93afd0ef          	jal	80000d58 <memmove>
    80003c22:	84ca                	mv	s1,s2
  while(*path == '/')
    80003c24:	0004c783          	lbu	a5,0(s1)
    80003c28:	01379763          	bne	a5,s3,80003c36 <namex+0xb6>
    path++;
    80003c2c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c2e:	0004c783          	lbu	a5,0(s1)
    80003c32:	ff378de3          	beq	a5,s3,80003c2c <namex+0xac>
    ilock(ip);
    80003c36:	8552                	mv	a0,s4
    80003c38:	903ff0ef          	jal	8000353a <ilock>
    if(ip->type != T_DIR){
    80003c3c:	044a1783          	lh	a5,68(s4)
    80003c40:	f9779ae3          	bne	a5,s7,80003bd4 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003c44:	000b0563          	beqz	s6,80003c4e <namex+0xce>
    80003c48:	0004c783          	lbu	a5,0(s1)
    80003c4c:	d7dd                	beqz	a5,80003bfa <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c4e:	4601                	li	a2,0
    80003c50:	85d6                	mv	a1,s5
    80003c52:	8552                	mv	a0,s4
    80003c54:	e81ff0ef          	jal	80003ad4 <dirlookup>
    80003c58:	892a                	mv	s2,a0
    80003c5a:	d545                	beqz	a0,80003c02 <namex+0x82>
    iunlockput(ip);
    80003c5c:	8552                	mv	a0,s4
    80003c5e:	ae9ff0ef          	jal	80003746 <iunlockput>
    ip = next;
    80003c62:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003c64:	0004c783          	lbu	a5,0(s1)
    80003c68:	01379763          	bne	a5,s3,80003c76 <namex+0xf6>
    path++;
    80003c6c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c6e:	0004c783          	lbu	a5,0(s1)
    80003c72:	ff378de3          	beq	a5,s3,80003c6c <namex+0xec>
  if(*path == 0)
    80003c76:	cf8d                	beqz	a5,80003cb0 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003c78:	0004c783          	lbu	a5,0(s1)
    80003c7c:	fd178713          	addi	a4,a5,-47
    80003c80:	cb19                	beqz	a4,80003c96 <namex+0x116>
    80003c82:	cb91                	beqz	a5,80003c96 <namex+0x116>
    80003c84:	8926                	mv	s2,s1
    path++;
    80003c86:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003c88:	00094783          	lbu	a5,0(s2)
    80003c8c:	fd178713          	addi	a4,a5,-47
    80003c90:	df35                	beqz	a4,80003c0c <namex+0x8c>
    80003c92:	fbf5                	bnez	a5,80003c86 <namex+0x106>
    80003c94:	bfa5                	j	80003c0c <namex+0x8c>
    80003c96:	8926                	mv	s2,s1
  len = path - s;
    80003c98:	4d01                	li	s10,0
    80003c9a:	4601                	li	a2,0
    memmove(name, s, len);
    80003c9c:	2601                	sext.w	a2,a2
    80003c9e:	85a6                	mv	a1,s1
    80003ca0:	8556                	mv	a0,s5
    80003ca2:	8b6fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003ca6:	9d56                	add	s10,s10,s5
    80003ca8:	000d0023          	sb	zero,0(s10)
    80003cac:	84ca                	mv	s1,s2
    80003cae:	bf9d                	j	80003c24 <namex+0xa4>
  if(nameiparent){
    80003cb0:	f20b06e3          	beqz	s6,80003bdc <namex+0x5c>
    iput(ip);
    80003cb4:	8552                	mv	a0,s4
    80003cb6:	a07ff0ef          	jal	800036bc <iput>
    return 0;
    80003cba:	4a01                	li	s4,0
    80003cbc:	b705                	j	80003bdc <namex+0x5c>

0000000080003cbe <dirlink>:
{
    80003cbe:	715d                	addi	sp,sp,-80
    80003cc0:	e486                	sd	ra,72(sp)
    80003cc2:	e0a2                	sd	s0,64(sp)
    80003cc4:	f84a                	sd	s2,48(sp)
    80003cc6:	ec56                	sd	s5,24(sp)
    80003cc8:	e85a                	sd	s6,16(sp)
    80003cca:	0880                	addi	s0,sp,80
    80003ccc:	892a                	mv	s2,a0
    80003cce:	8aae                	mv	s5,a1
    80003cd0:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003cd2:	4601                	li	a2,0
    80003cd4:	e01ff0ef          	jal	80003ad4 <dirlookup>
    80003cd8:	ed1d                	bnez	a0,80003d16 <dirlink+0x58>
    80003cda:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cdc:	04c92483          	lw	s1,76(s2)
    80003ce0:	c4b9                	beqz	s1,80003d2e <dirlink+0x70>
    80003ce2:	f44e                	sd	s3,40(sp)
    80003ce4:	f052                	sd	s4,32(sp)
    80003ce6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ce8:	fb040a13          	addi	s4,s0,-80
    80003cec:	49c1                	li	s3,16
    80003cee:	874e                	mv	a4,s3
    80003cf0:	86a6                	mv	a3,s1
    80003cf2:	8652                	mv	a2,s4
    80003cf4:	4581                	li	a1,0
    80003cf6:	854a                	mv	a0,s2
    80003cf8:	bd5ff0ef          	jal	800038cc <readi>
    80003cfc:	03351163          	bne	a0,s3,80003d1e <dirlink+0x60>
    if(de.inum == 0)
    80003d00:	fb045783          	lhu	a5,-80(s0)
    80003d04:	c39d                	beqz	a5,80003d2a <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d06:	24c1                	addiw	s1,s1,16
    80003d08:	04c92783          	lw	a5,76(s2)
    80003d0c:	fef4e1e3          	bltu	s1,a5,80003cee <dirlink+0x30>
    80003d10:	79a2                	ld	s3,40(sp)
    80003d12:	7a02                	ld	s4,32(sp)
    80003d14:	a829                	j	80003d2e <dirlink+0x70>
    iput(ip);
    80003d16:	9a7ff0ef          	jal	800036bc <iput>
    return -1;
    80003d1a:	557d                	li	a0,-1
    80003d1c:	a83d                	j	80003d5a <dirlink+0x9c>
      panic("dirlink read");
    80003d1e:	00003517          	auipc	a0,0x3
    80003d22:	7b250513          	addi	a0,a0,1970 # 800074d0 <etext+0x4d0>
    80003d26:	afffc0ef          	jal	80000824 <panic>
    80003d2a:	79a2                	ld	s3,40(sp)
    80003d2c:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003d2e:	4639                	li	a2,14
    80003d30:	85d6                	mv	a1,s5
    80003d32:	fb240513          	addi	a0,s0,-78
    80003d36:	8d0fd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003d3a:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d3e:	4741                	li	a4,16
    80003d40:	86a6                	mv	a3,s1
    80003d42:	fb040613          	addi	a2,s0,-80
    80003d46:	4581                	li	a1,0
    80003d48:	854a                	mv	a0,s2
    80003d4a:	c75ff0ef          	jal	800039be <writei>
    80003d4e:	1541                	addi	a0,a0,-16
    80003d50:	00a03533          	snez	a0,a0
    80003d54:	40a0053b          	negw	a0,a0
    80003d58:	74e2                	ld	s1,56(sp)
}
    80003d5a:	60a6                	ld	ra,72(sp)
    80003d5c:	6406                	ld	s0,64(sp)
    80003d5e:	7942                	ld	s2,48(sp)
    80003d60:	6ae2                	ld	s5,24(sp)
    80003d62:	6b42                	ld	s6,16(sp)
    80003d64:	6161                	addi	sp,sp,80
    80003d66:	8082                	ret

0000000080003d68 <namei>:

struct inode*
namei(char *path)
{
    80003d68:	1101                	addi	sp,sp,-32
    80003d6a:	ec06                	sd	ra,24(sp)
    80003d6c:	e822                	sd	s0,16(sp)
    80003d6e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d70:	fe040613          	addi	a2,s0,-32
    80003d74:	4581                	li	a1,0
    80003d76:	e0bff0ef          	jal	80003b80 <namex>
}
    80003d7a:	60e2                	ld	ra,24(sp)
    80003d7c:	6442                	ld	s0,16(sp)
    80003d7e:	6105                	addi	sp,sp,32
    80003d80:	8082                	ret

0000000080003d82 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d82:	1141                	addi	sp,sp,-16
    80003d84:	e406                	sd	ra,8(sp)
    80003d86:	e022                	sd	s0,0(sp)
    80003d88:	0800                	addi	s0,sp,16
    80003d8a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d8c:	4585                	li	a1,1
    80003d8e:	df3ff0ef          	jal	80003b80 <namex>
}
    80003d92:	60a2                	ld	ra,8(sp)
    80003d94:	6402                	ld	s0,0(sp)
    80003d96:	0141                	addi	sp,sp,16
    80003d98:	8082                	ret

0000000080003d9a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d9a:	1101                	addi	sp,sp,-32
    80003d9c:	ec06                	sd	ra,24(sp)
    80003d9e:	e822                	sd	s0,16(sp)
    80003da0:	e426                	sd	s1,8(sp)
    80003da2:	e04a                	sd	s2,0(sp)
    80003da4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003da6:	0001c917          	auipc	s2,0x1c
    80003daa:	01a90913          	addi	s2,s2,26 # 8001fdc0 <log>
    80003dae:	01892583          	lw	a1,24(s2)
    80003db2:	02492503          	lw	a0,36(s2)
    80003db6:	8ecff0ef          	jal	80002ea2 <bread>
    80003dba:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003dbc:	02892603          	lw	a2,40(s2)
    80003dc0:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003dc2:	00c05f63          	blez	a2,80003de0 <write_head+0x46>
    80003dc6:	0001c717          	auipc	a4,0x1c
    80003dca:	02670713          	addi	a4,a4,38 # 8001fdec <log+0x2c>
    80003dce:	87aa                	mv	a5,a0
    80003dd0:	060a                	slli	a2,a2,0x2
    80003dd2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003dd4:	4314                	lw	a3,0(a4)
    80003dd6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003dd8:	0711                	addi	a4,a4,4
    80003dda:	0791                	addi	a5,a5,4
    80003ddc:	fec79ce3          	bne	a5,a2,80003dd4 <write_head+0x3a>
  }
  bwrite(buf);
    80003de0:	8526                	mv	a0,s1
    80003de2:	996ff0ef          	jal	80002f78 <bwrite>
  brelse(buf);
    80003de6:	8526                	mv	a0,s1
    80003de8:	9c2ff0ef          	jal	80002faa <brelse>
}
    80003dec:	60e2                	ld	ra,24(sp)
    80003dee:	6442                	ld	s0,16(sp)
    80003df0:	64a2                	ld	s1,8(sp)
    80003df2:	6902                	ld	s2,0(sp)
    80003df4:	6105                	addi	sp,sp,32
    80003df6:	8082                	ret

0000000080003df8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003df8:	0001c797          	auipc	a5,0x1c
    80003dfc:	ff07a783          	lw	a5,-16(a5) # 8001fde8 <log+0x28>
    80003e00:	0cf05163          	blez	a5,80003ec2 <install_trans+0xca>
{
    80003e04:	715d                	addi	sp,sp,-80
    80003e06:	e486                	sd	ra,72(sp)
    80003e08:	e0a2                	sd	s0,64(sp)
    80003e0a:	fc26                	sd	s1,56(sp)
    80003e0c:	f84a                	sd	s2,48(sp)
    80003e0e:	f44e                	sd	s3,40(sp)
    80003e10:	f052                	sd	s4,32(sp)
    80003e12:	ec56                	sd	s5,24(sp)
    80003e14:	e85a                	sd	s6,16(sp)
    80003e16:	e45e                	sd	s7,8(sp)
    80003e18:	e062                	sd	s8,0(sp)
    80003e1a:	0880                	addi	s0,sp,80
    80003e1c:	8b2a                	mv	s6,a0
    80003e1e:	0001ca97          	auipc	s5,0x1c
    80003e22:	fcea8a93          	addi	s5,s5,-50 # 8001fdec <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e26:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003e28:	00003c17          	auipc	s8,0x3
    80003e2c:	6b8c0c13          	addi	s8,s8,1720 # 800074e0 <etext+0x4e0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e30:	0001ca17          	auipc	s4,0x1c
    80003e34:	f90a0a13          	addi	s4,s4,-112 # 8001fdc0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e38:	40000b93          	li	s7,1024
    80003e3c:	a025                	j	80003e64 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003e3e:	000aa603          	lw	a2,0(s5)
    80003e42:	85ce                	mv	a1,s3
    80003e44:	8562                	mv	a0,s8
    80003e46:	eb4fc0ef          	jal	800004fa <printf>
    80003e4a:	a839                	j	80003e68 <install_trans+0x70>
    brelse(lbuf);
    80003e4c:	854a                	mv	a0,s2
    80003e4e:	95cff0ef          	jal	80002faa <brelse>
    brelse(dbuf);
    80003e52:	8526                	mv	a0,s1
    80003e54:	956ff0ef          	jal	80002faa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e58:	2985                	addiw	s3,s3,1
    80003e5a:	0a91                	addi	s5,s5,4
    80003e5c:	028a2783          	lw	a5,40(s4)
    80003e60:	04f9d563          	bge	s3,a5,80003eaa <install_trans+0xb2>
    if(recovering) {
    80003e64:	fc0b1de3          	bnez	s6,80003e3e <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e68:	018a2583          	lw	a1,24(s4)
    80003e6c:	013585bb          	addw	a1,a1,s3
    80003e70:	2585                	addiw	a1,a1,1
    80003e72:	024a2503          	lw	a0,36(s4)
    80003e76:	82cff0ef          	jal	80002ea2 <bread>
    80003e7a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003e7c:	000aa583          	lw	a1,0(s5)
    80003e80:	024a2503          	lw	a0,36(s4)
    80003e84:	81eff0ef          	jal	80002ea2 <bread>
    80003e88:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e8a:	865e                	mv	a2,s7
    80003e8c:	05890593          	addi	a1,s2,88
    80003e90:	05850513          	addi	a0,a0,88
    80003e94:	ec5fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e98:	8526                	mv	a0,s1
    80003e9a:	8deff0ef          	jal	80002f78 <bwrite>
    if(recovering == 0)
    80003e9e:	fa0b17e3          	bnez	s6,80003e4c <install_trans+0x54>
      bunpin(dbuf);
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	9beff0ef          	jal	80003062 <bunpin>
    80003ea8:	b755                	j	80003e4c <install_trans+0x54>
}
    80003eaa:	60a6                	ld	ra,72(sp)
    80003eac:	6406                	ld	s0,64(sp)
    80003eae:	74e2                	ld	s1,56(sp)
    80003eb0:	7942                	ld	s2,48(sp)
    80003eb2:	79a2                	ld	s3,40(sp)
    80003eb4:	7a02                	ld	s4,32(sp)
    80003eb6:	6ae2                	ld	s5,24(sp)
    80003eb8:	6b42                	ld	s6,16(sp)
    80003eba:	6ba2                	ld	s7,8(sp)
    80003ebc:	6c02                	ld	s8,0(sp)
    80003ebe:	6161                	addi	sp,sp,80
    80003ec0:	8082                	ret
    80003ec2:	8082                	ret

0000000080003ec4 <initlog>:
{
    80003ec4:	7179                	addi	sp,sp,-48
    80003ec6:	f406                	sd	ra,40(sp)
    80003ec8:	f022                	sd	s0,32(sp)
    80003eca:	ec26                	sd	s1,24(sp)
    80003ecc:	e84a                	sd	s2,16(sp)
    80003ece:	e44e                	sd	s3,8(sp)
    80003ed0:	1800                	addi	s0,sp,48
    80003ed2:	84aa                	mv	s1,a0
    80003ed4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ed6:	0001c917          	auipc	s2,0x1c
    80003eda:	eea90913          	addi	s2,s2,-278 # 8001fdc0 <log>
    80003ede:	00003597          	auipc	a1,0x3
    80003ee2:	62258593          	addi	a1,a1,1570 # 80007500 <etext+0x500>
    80003ee6:	854a                	mv	a0,s2
    80003ee8:	cb7fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003eec:	0149a583          	lw	a1,20(s3)
    80003ef0:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003ef4:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003ef8:	8526                	mv	a0,s1
    80003efa:	fa9fe0ef          	jal	80002ea2 <bread>
  log.lh.n = lh->n;
    80003efe:	4d30                	lw	a2,88(a0)
    80003f00:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003f04:	00c05f63          	blez	a2,80003f22 <initlog+0x5e>
    80003f08:	87aa                	mv	a5,a0
    80003f0a:	0001c717          	auipc	a4,0x1c
    80003f0e:	ee270713          	addi	a4,a4,-286 # 8001fdec <log+0x2c>
    80003f12:	060a                	slli	a2,a2,0x2
    80003f14:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003f16:	4ff4                	lw	a3,92(a5)
    80003f18:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f1a:	0791                	addi	a5,a5,4
    80003f1c:	0711                	addi	a4,a4,4
    80003f1e:	fec79ce3          	bne	a5,a2,80003f16 <initlog+0x52>
  brelse(buf);
    80003f22:	888ff0ef          	jal	80002faa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003f26:	4505                	li	a0,1
    80003f28:	ed1ff0ef          	jal	80003df8 <install_trans>
  log.lh.n = 0;
    80003f2c:	0001c797          	auipc	a5,0x1c
    80003f30:	ea07ae23          	sw	zero,-324(a5) # 8001fde8 <log+0x28>
  write_head(); // clear the log
    80003f34:	e67ff0ef          	jal	80003d9a <write_head>
}
    80003f38:	70a2                	ld	ra,40(sp)
    80003f3a:	7402                	ld	s0,32(sp)
    80003f3c:	64e2                	ld	s1,24(sp)
    80003f3e:	6942                	ld	s2,16(sp)
    80003f40:	69a2                	ld	s3,8(sp)
    80003f42:	6145                	addi	sp,sp,48
    80003f44:	8082                	ret

0000000080003f46 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f46:	1101                	addi	sp,sp,-32
    80003f48:	ec06                	sd	ra,24(sp)
    80003f4a:	e822                	sd	s0,16(sp)
    80003f4c:	e426                	sd	s1,8(sp)
    80003f4e:	e04a                	sd	s2,0(sp)
    80003f50:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f52:	0001c517          	auipc	a0,0x1c
    80003f56:	e6e50513          	addi	a0,a0,-402 # 8001fdc0 <log>
    80003f5a:	ccffc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003f5e:	0001c497          	auipc	s1,0x1c
    80003f62:	e6248493          	addi	s1,s1,-414 # 8001fdc0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003f66:	4979                	li	s2,30
    80003f68:	a029                	j	80003f72 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003f6a:	85a6                	mv	a1,s1
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	a14fe0ef          	jal	80002182 <sleep>
    if(log.committing){
    80003f72:	509c                	lw	a5,32(s1)
    80003f74:	fbfd                	bnez	a5,80003f6a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003f76:	4cd8                	lw	a4,28(s1)
    80003f78:	2705                	addiw	a4,a4,1
    80003f7a:	0027179b          	slliw	a5,a4,0x2
    80003f7e:	9fb9                	addw	a5,a5,a4
    80003f80:	0017979b          	slliw	a5,a5,0x1
    80003f84:	5494                	lw	a3,40(s1)
    80003f86:	9fb5                	addw	a5,a5,a3
    80003f88:	00f95763          	bge	s2,a5,80003f96 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f8c:	85a6                	mv	a1,s1
    80003f8e:	8526                	mv	a0,s1
    80003f90:	9f2fe0ef          	jal	80002182 <sleep>
    80003f94:	bff9                	j	80003f72 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003f96:	0001c797          	auipc	a5,0x1c
    80003f9a:	e4e7a323          	sw	a4,-442(a5) # 8001fddc <log+0x1c>
      release(&log.lock);
    80003f9e:	0001c517          	auipc	a0,0x1c
    80003fa2:	e2250513          	addi	a0,a0,-478 # 8001fdc0 <log>
    80003fa6:	d17fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003faa:	60e2                	ld	ra,24(sp)
    80003fac:	6442                	ld	s0,16(sp)
    80003fae:	64a2                	ld	s1,8(sp)
    80003fb0:	6902                	ld	s2,0(sp)
    80003fb2:	6105                	addi	sp,sp,32
    80003fb4:	8082                	ret

0000000080003fb6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003fb6:	7139                	addi	sp,sp,-64
    80003fb8:	fc06                	sd	ra,56(sp)
    80003fba:	f822                	sd	s0,48(sp)
    80003fbc:	f426                	sd	s1,40(sp)
    80003fbe:	f04a                	sd	s2,32(sp)
    80003fc0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003fc2:	0001c497          	auipc	s1,0x1c
    80003fc6:	dfe48493          	addi	s1,s1,-514 # 8001fdc0 <log>
    80003fca:	8526                	mv	a0,s1
    80003fcc:	c5dfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003fd0:	4cdc                	lw	a5,28(s1)
    80003fd2:	37fd                	addiw	a5,a5,-1
    80003fd4:	893e                	mv	s2,a5
    80003fd6:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003fd8:	509c                	lw	a5,32(s1)
    80003fda:	e7b1                	bnez	a5,80004026 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003fdc:	04091e63          	bnez	s2,80004038 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003fe0:	0001c497          	auipc	s1,0x1c
    80003fe4:	de048493          	addi	s1,s1,-544 # 8001fdc0 <log>
    80003fe8:	4785                	li	a5,1
    80003fea:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003fec:	8526                	mv	a0,s1
    80003fee:	ccffc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ff2:	549c                	lw	a5,40(s1)
    80003ff4:	06f04463          	bgtz	a5,8000405c <end_op+0xa6>
    acquire(&log.lock);
    80003ff8:	0001c517          	auipc	a0,0x1c
    80003ffc:	dc850513          	addi	a0,a0,-568 # 8001fdc0 <log>
    80004000:	c29fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80004004:	0001c797          	auipc	a5,0x1c
    80004008:	dc07ae23          	sw	zero,-548(a5) # 8001fde0 <log+0x20>
    wakeup(&log);
    8000400c:	0001c517          	auipc	a0,0x1c
    80004010:	db450513          	addi	a0,a0,-588 # 8001fdc0 <log>
    80004014:	9bafe0ef          	jal	800021ce <wakeup>
    release(&log.lock);
    80004018:	0001c517          	auipc	a0,0x1c
    8000401c:	da850513          	addi	a0,a0,-600 # 8001fdc0 <log>
    80004020:	c9dfc0ef          	jal	80000cbc <release>
}
    80004024:	a035                	j	80004050 <end_op+0x9a>
    80004026:	ec4e                	sd	s3,24(sp)
    80004028:	e852                	sd	s4,16(sp)
    8000402a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000402c:	00003517          	auipc	a0,0x3
    80004030:	4dc50513          	addi	a0,a0,1244 # 80007508 <etext+0x508>
    80004034:	ff0fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80004038:	0001c517          	auipc	a0,0x1c
    8000403c:	d8850513          	addi	a0,a0,-632 # 8001fdc0 <log>
    80004040:	98efe0ef          	jal	800021ce <wakeup>
  release(&log.lock);
    80004044:	0001c517          	auipc	a0,0x1c
    80004048:	d7c50513          	addi	a0,a0,-644 # 8001fdc0 <log>
    8000404c:	c71fc0ef          	jal	80000cbc <release>
}
    80004050:	70e2                	ld	ra,56(sp)
    80004052:	7442                	ld	s0,48(sp)
    80004054:	74a2                	ld	s1,40(sp)
    80004056:	7902                	ld	s2,32(sp)
    80004058:	6121                	addi	sp,sp,64
    8000405a:	8082                	ret
    8000405c:	ec4e                	sd	s3,24(sp)
    8000405e:	e852                	sd	s4,16(sp)
    80004060:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004062:	0001ca97          	auipc	s5,0x1c
    80004066:	d8aa8a93          	addi	s5,s5,-630 # 8001fdec <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000406a:	0001ca17          	auipc	s4,0x1c
    8000406e:	d56a0a13          	addi	s4,s4,-682 # 8001fdc0 <log>
    80004072:	018a2583          	lw	a1,24(s4)
    80004076:	012585bb          	addw	a1,a1,s2
    8000407a:	2585                	addiw	a1,a1,1
    8000407c:	024a2503          	lw	a0,36(s4)
    80004080:	e23fe0ef          	jal	80002ea2 <bread>
    80004084:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004086:	000aa583          	lw	a1,0(s5)
    8000408a:	024a2503          	lw	a0,36(s4)
    8000408e:	e15fe0ef          	jal	80002ea2 <bread>
    80004092:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004094:	40000613          	li	a2,1024
    80004098:	05850593          	addi	a1,a0,88
    8000409c:	05848513          	addi	a0,s1,88
    800040a0:	cb9fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    800040a4:	8526                	mv	a0,s1
    800040a6:	ed3fe0ef          	jal	80002f78 <bwrite>
    brelse(from);
    800040aa:	854e                	mv	a0,s3
    800040ac:	efffe0ef          	jal	80002faa <brelse>
    brelse(to);
    800040b0:	8526                	mv	a0,s1
    800040b2:	ef9fe0ef          	jal	80002faa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040b6:	2905                	addiw	s2,s2,1
    800040b8:	0a91                	addi	s5,s5,4
    800040ba:	028a2783          	lw	a5,40(s4)
    800040be:	faf94ae3          	blt	s2,a5,80004072 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800040c2:	cd9ff0ef          	jal	80003d9a <write_head>
    install_trans(0); // Now install writes to home locations
    800040c6:	4501                	li	a0,0
    800040c8:	d31ff0ef          	jal	80003df8 <install_trans>
    log.lh.n = 0;
    800040cc:	0001c797          	auipc	a5,0x1c
    800040d0:	d007ae23          	sw	zero,-740(a5) # 8001fde8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800040d4:	cc7ff0ef          	jal	80003d9a <write_head>
    800040d8:	69e2                	ld	s3,24(sp)
    800040da:	6a42                	ld	s4,16(sp)
    800040dc:	6aa2                	ld	s5,8(sp)
    800040de:	bf29                	j	80003ff8 <end_op+0x42>

00000000800040e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800040e0:	1101                	addi	sp,sp,-32
    800040e2:	ec06                	sd	ra,24(sp)
    800040e4:	e822                	sd	s0,16(sp)
    800040e6:	e426                	sd	s1,8(sp)
    800040e8:	1000                	addi	s0,sp,32
    800040ea:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800040ec:	0001c517          	auipc	a0,0x1c
    800040f0:	cd450513          	addi	a0,a0,-812 # 8001fdc0 <log>
    800040f4:	b35fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800040f8:	0001c617          	auipc	a2,0x1c
    800040fc:	cf062603          	lw	a2,-784(a2) # 8001fde8 <log+0x28>
    80004100:	47f5                	li	a5,29
    80004102:	04c7cd63          	blt	a5,a2,8000415c <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004106:	0001c797          	auipc	a5,0x1c
    8000410a:	cd67a783          	lw	a5,-810(a5) # 8001fddc <log+0x1c>
    8000410e:	04f05d63          	blez	a5,80004168 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004112:	4781                	li	a5,0
    80004114:	06c05063          	blez	a2,80004174 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004118:	44cc                	lw	a1,12(s1)
    8000411a:	0001c717          	auipc	a4,0x1c
    8000411e:	cd270713          	addi	a4,a4,-814 # 8001fdec <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004122:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004124:	4314                	lw	a3,0(a4)
    80004126:	04b68763          	beq	a3,a1,80004174 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000412a:	2785                	addiw	a5,a5,1
    8000412c:	0711                	addi	a4,a4,4
    8000412e:	fef61be3          	bne	a2,a5,80004124 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004132:	060a                	slli	a2,a2,0x2
    80004134:	02060613          	addi	a2,a2,32
    80004138:	0001c797          	auipc	a5,0x1c
    8000413c:	c8878793          	addi	a5,a5,-888 # 8001fdc0 <log>
    80004140:	97b2                	add	a5,a5,a2
    80004142:	44d8                	lw	a4,12(s1)
    80004144:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004146:	8526                	mv	a0,s1
    80004148:	ee7fe0ef          	jal	8000302e <bpin>
    log.lh.n++;
    8000414c:	0001c717          	auipc	a4,0x1c
    80004150:	c7470713          	addi	a4,a4,-908 # 8001fdc0 <log>
    80004154:	571c                	lw	a5,40(a4)
    80004156:	2785                	addiw	a5,a5,1
    80004158:	d71c                	sw	a5,40(a4)
    8000415a:	a815                	j	8000418e <log_write+0xae>
    panic("too big a transaction");
    8000415c:	00003517          	auipc	a0,0x3
    80004160:	3bc50513          	addi	a0,a0,956 # 80007518 <etext+0x518>
    80004164:	ec0fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80004168:	00003517          	auipc	a0,0x3
    8000416c:	3c850513          	addi	a0,a0,968 # 80007530 <etext+0x530>
    80004170:	eb4fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80004174:	00279693          	slli	a3,a5,0x2
    80004178:	02068693          	addi	a3,a3,32
    8000417c:	0001c717          	auipc	a4,0x1c
    80004180:	c4470713          	addi	a4,a4,-956 # 8001fdc0 <log>
    80004184:	9736                	add	a4,a4,a3
    80004186:	44d4                	lw	a3,12(s1)
    80004188:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000418a:	faf60ee3          	beq	a2,a5,80004146 <log_write+0x66>
  }
  release(&log.lock);
    8000418e:	0001c517          	auipc	a0,0x1c
    80004192:	c3250513          	addi	a0,a0,-974 # 8001fdc0 <log>
    80004196:	b27fc0ef          	jal	80000cbc <release>
}
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	64a2                	ld	s1,8(sp)
    800041a0:	6105                	addi	sp,sp,32
    800041a2:	8082                	ret

00000000800041a4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	e426                	sd	s1,8(sp)
    800041ac:	e04a                	sd	s2,0(sp)
    800041ae:	1000                	addi	s0,sp,32
    800041b0:	84aa                	mv	s1,a0
    800041b2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800041b4:	00003597          	auipc	a1,0x3
    800041b8:	39c58593          	addi	a1,a1,924 # 80007550 <etext+0x550>
    800041bc:	0521                	addi	a0,a0,8
    800041be:	9e1fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    800041c2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800041c6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041ca:	0204a423          	sw	zero,40(s1)
}
    800041ce:	60e2                	ld	ra,24(sp)
    800041d0:	6442                	ld	s0,16(sp)
    800041d2:	64a2                	ld	s1,8(sp)
    800041d4:	6902                	ld	s2,0(sp)
    800041d6:	6105                	addi	sp,sp,32
    800041d8:	8082                	ret

00000000800041da <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800041da:	1101                	addi	sp,sp,-32
    800041dc:	ec06                	sd	ra,24(sp)
    800041de:	e822                	sd	s0,16(sp)
    800041e0:	e426                	sd	s1,8(sp)
    800041e2:	e04a                	sd	s2,0(sp)
    800041e4:	1000                	addi	s0,sp,32
    800041e6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041e8:	00850913          	addi	s2,a0,8
    800041ec:	854a                	mv	a0,s2
    800041ee:	a3bfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800041f2:	409c                	lw	a5,0(s1)
    800041f4:	c799                	beqz	a5,80004202 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800041f6:	85ca                	mv	a1,s2
    800041f8:	8526                	mv	a0,s1
    800041fa:	f89fd0ef          	jal	80002182 <sleep>
  while (lk->locked) {
    800041fe:	409c                	lw	a5,0(s1)
    80004200:	fbfd                	bnez	a5,800041f6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004202:	4785                	li	a5,1
    80004204:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004206:	fa2fd0ef          	jal	800019a8 <myproc>
    8000420a:	591c                	lw	a5,48(a0)
    8000420c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000420e:	854a                	mv	a0,s2
    80004210:	aadfc0ef          	jal	80000cbc <release>
}
    80004214:	60e2                	ld	ra,24(sp)
    80004216:	6442                	ld	s0,16(sp)
    80004218:	64a2                	ld	s1,8(sp)
    8000421a:	6902                	ld	s2,0(sp)
    8000421c:	6105                	addi	sp,sp,32
    8000421e:	8082                	ret

0000000080004220 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004220:	1101                	addi	sp,sp,-32
    80004222:	ec06                	sd	ra,24(sp)
    80004224:	e822                	sd	s0,16(sp)
    80004226:	e426                	sd	s1,8(sp)
    80004228:	e04a                	sd	s2,0(sp)
    8000422a:	1000                	addi	s0,sp,32
    8000422c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000422e:	00850913          	addi	s2,a0,8
    80004232:	854a                	mv	a0,s2
    80004234:	9f5fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004238:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000423c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004240:	8526                	mv	a0,s1
    80004242:	f8dfd0ef          	jal	800021ce <wakeup>
  release(&lk->lk);
    80004246:	854a                	mv	a0,s2
    80004248:	a75fc0ef          	jal	80000cbc <release>
}
    8000424c:	60e2                	ld	ra,24(sp)
    8000424e:	6442                	ld	s0,16(sp)
    80004250:	64a2                	ld	s1,8(sp)
    80004252:	6902                	ld	s2,0(sp)
    80004254:	6105                	addi	sp,sp,32
    80004256:	8082                	ret

0000000080004258 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004258:	7179                	addi	sp,sp,-48
    8000425a:	f406                	sd	ra,40(sp)
    8000425c:	f022                	sd	s0,32(sp)
    8000425e:	ec26                	sd	s1,24(sp)
    80004260:	e84a                	sd	s2,16(sp)
    80004262:	1800                	addi	s0,sp,48
    80004264:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004266:	00850913          	addi	s2,a0,8
    8000426a:	854a                	mv	a0,s2
    8000426c:	9bdfc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004270:	409c                	lw	a5,0(s1)
    80004272:	ef81                	bnez	a5,8000428a <holdingsleep+0x32>
    80004274:	4481                	li	s1,0
  release(&lk->lk);
    80004276:	854a                	mv	a0,s2
    80004278:	a45fc0ef          	jal	80000cbc <release>
  return r;
}
    8000427c:	8526                	mv	a0,s1
    8000427e:	70a2                	ld	ra,40(sp)
    80004280:	7402                	ld	s0,32(sp)
    80004282:	64e2                	ld	s1,24(sp)
    80004284:	6942                	ld	s2,16(sp)
    80004286:	6145                	addi	sp,sp,48
    80004288:	8082                	ret
    8000428a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000428c:	0284a983          	lw	s3,40(s1)
    80004290:	f18fd0ef          	jal	800019a8 <myproc>
    80004294:	5904                	lw	s1,48(a0)
    80004296:	413484b3          	sub	s1,s1,s3
    8000429a:	0014b493          	seqz	s1,s1
    8000429e:	69a2                	ld	s3,8(sp)
    800042a0:	bfd9                	j	80004276 <holdingsleep+0x1e>

00000000800042a2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800042a2:	1141                	addi	sp,sp,-16
    800042a4:	e406                	sd	ra,8(sp)
    800042a6:	e022                	sd	s0,0(sp)
    800042a8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800042aa:	00003597          	auipc	a1,0x3
    800042ae:	2b658593          	addi	a1,a1,694 # 80007560 <etext+0x560>
    800042b2:	0001c517          	auipc	a0,0x1c
    800042b6:	c5650513          	addi	a0,a0,-938 # 8001ff08 <ftable>
    800042ba:	8e5fc0ef          	jal	80000b9e <initlock>
}
    800042be:	60a2                	ld	ra,8(sp)
    800042c0:	6402                	ld	s0,0(sp)
    800042c2:	0141                	addi	sp,sp,16
    800042c4:	8082                	ret

00000000800042c6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800042c6:	1101                	addi	sp,sp,-32
    800042c8:	ec06                	sd	ra,24(sp)
    800042ca:	e822                	sd	s0,16(sp)
    800042cc:	e426                	sd	s1,8(sp)
    800042ce:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800042d0:	0001c517          	auipc	a0,0x1c
    800042d4:	c3850513          	addi	a0,a0,-968 # 8001ff08 <ftable>
    800042d8:	951fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800042dc:	0001c497          	auipc	s1,0x1c
    800042e0:	c4448493          	addi	s1,s1,-956 # 8001ff20 <ftable+0x18>
    800042e4:	0001d717          	auipc	a4,0x1d
    800042e8:	bdc70713          	addi	a4,a4,-1060 # 80020ec0 <disk>
    if(f->ref == 0){
    800042ec:	40dc                	lw	a5,4(s1)
    800042ee:	cf89                	beqz	a5,80004308 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800042f0:	02848493          	addi	s1,s1,40
    800042f4:	fee49ce3          	bne	s1,a4,800042ec <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042f8:	0001c517          	auipc	a0,0x1c
    800042fc:	c1050513          	addi	a0,a0,-1008 # 8001ff08 <ftable>
    80004300:	9bdfc0ef          	jal	80000cbc <release>
  return 0;
    80004304:	4481                	li	s1,0
    80004306:	a809                	j	80004318 <filealloc+0x52>
      f->ref = 1;
    80004308:	4785                	li	a5,1
    8000430a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000430c:	0001c517          	auipc	a0,0x1c
    80004310:	bfc50513          	addi	a0,a0,-1028 # 8001ff08 <ftable>
    80004314:	9a9fc0ef          	jal	80000cbc <release>
}
    80004318:	8526                	mv	a0,s1
    8000431a:	60e2                	ld	ra,24(sp)
    8000431c:	6442                	ld	s0,16(sp)
    8000431e:	64a2                	ld	s1,8(sp)
    80004320:	6105                	addi	sp,sp,32
    80004322:	8082                	ret

0000000080004324 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004324:	1101                	addi	sp,sp,-32
    80004326:	ec06                	sd	ra,24(sp)
    80004328:	e822                	sd	s0,16(sp)
    8000432a:	e426                	sd	s1,8(sp)
    8000432c:	1000                	addi	s0,sp,32
    8000432e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004330:	0001c517          	auipc	a0,0x1c
    80004334:	bd850513          	addi	a0,a0,-1064 # 8001ff08 <ftable>
    80004338:	8f1fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000433c:	40dc                	lw	a5,4(s1)
    8000433e:	02f05063          	blez	a5,8000435e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004342:	2785                	addiw	a5,a5,1
    80004344:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004346:	0001c517          	auipc	a0,0x1c
    8000434a:	bc250513          	addi	a0,a0,-1086 # 8001ff08 <ftable>
    8000434e:	96ffc0ef          	jal	80000cbc <release>
  return f;
}
    80004352:	8526                	mv	a0,s1
    80004354:	60e2                	ld	ra,24(sp)
    80004356:	6442                	ld	s0,16(sp)
    80004358:	64a2                	ld	s1,8(sp)
    8000435a:	6105                	addi	sp,sp,32
    8000435c:	8082                	ret
    panic("filedup");
    8000435e:	00003517          	auipc	a0,0x3
    80004362:	20a50513          	addi	a0,a0,522 # 80007568 <etext+0x568>
    80004366:	cbefc0ef          	jal	80000824 <panic>

000000008000436a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000436a:	7139                	addi	sp,sp,-64
    8000436c:	fc06                	sd	ra,56(sp)
    8000436e:	f822                	sd	s0,48(sp)
    80004370:	f426                	sd	s1,40(sp)
    80004372:	0080                	addi	s0,sp,64
    80004374:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004376:	0001c517          	auipc	a0,0x1c
    8000437a:	b9250513          	addi	a0,a0,-1134 # 8001ff08 <ftable>
    8000437e:	8abfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004382:	40dc                	lw	a5,4(s1)
    80004384:	04f05a63          	blez	a5,800043d8 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004388:	37fd                	addiw	a5,a5,-1
    8000438a:	c0dc                	sw	a5,4(s1)
    8000438c:	06f04063          	bgtz	a5,800043ec <fileclose+0x82>
    80004390:	f04a                	sd	s2,32(sp)
    80004392:	ec4e                	sd	s3,24(sp)
    80004394:	e852                	sd	s4,16(sp)
    80004396:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004398:	0004a903          	lw	s2,0(s1)
    8000439c:	0094c783          	lbu	a5,9(s1)
    800043a0:	89be                	mv	s3,a5
    800043a2:	689c                	ld	a5,16(s1)
    800043a4:	8a3e                	mv	s4,a5
    800043a6:	6c9c                	ld	a5,24(s1)
    800043a8:	8abe                	mv	s5,a5
  f->ref = 0;
    800043aa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800043ae:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800043b2:	0001c517          	auipc	a0,0x1c
    800043b6:	b5650513          	addi	a0,a0,-1194 # 8001ff08 <ftable>
    800043ba:	903fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    800043be:	4785                	li	a5,1
    800043c0:	04f90163          	beq	s2,a5,80004402 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800043c4:	ffe9079b          	addiw	a5,s2,-2
    800043c8:	4705                	li	a4,1
    800043ca:	04f77563          	bgeu	a4,a5,80004414 <fileclose+0xaa>
    800043ce:	7902                	ld	s2,32(sp)
    800043d0:	69e2                	ld	s3,24(sp)
    800043d2:	6a42                	ld	s4,16(sp)
    800043d4:	6aa2                	ld	s5,8(sp)
    800043d6:	a00d                	j	800043f8 <fileclose+0x8e>
    800043d8:	f04a                	sd	s2,32(sp)
    800043da:	ec4e                	sd	s3,24(sp)
    800043dc:	e852                	sd	s4,16(sp)
    800043de:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800043e0:	00003517          	auipc	a0,0x3
    800043e4:	19050513          	addi	a0,a0,400 # 80007570 <etext+0x570>
    800043e8:	c3cfc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    800043ec:	0001c517          	auipc	a0,0x1c
    800043f0:	b1c50513          	addi	a0,a0,-1252 # 8001ff08 <ftable>
    800043f4:	8c9fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043f8:	70e2                	ld	ra,56(sp)
    800043fa:	7442                	ld	s0,48(sp)
    800043fc:	74a2                	ld	s1,40(sp)
    800043fe:	6121                	addi	sp,sp,64
    80004400:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004402:	85ce                	mv	a1,s3
    80004404:	8552                	mv	a0,s4
    80004406:	348000ef          	jal	8000474e <pipeclose>
    8000440a:	7902                	ld	s2,32(sp)
    8000440c:	69e2                	ld	s3,24(sp)
    8000440e:	6a42                	ld	s4,16(sp)
    80004410:	6aa2                	ld	s5,8(sp)
    80004412:	b7dd                	j	800043f8 <fileclose+0x8e>
    begin_op();
    80004414:	b33ff0ef          	jal	80003f46 <begin_op>
    iput(ff.ip);
    80004418:	8556                	mv	a0,s5
    8000441a:	aa2ff0ef          	jal	800036bc <iput>
    end_op();
    8000441e:	b99ff0ef          	jal	80003fb6 <end_op>
    80004422:	7902                	ld	s2,32(sp)
    80004424:	69e2                	ld	s3,24(sp)
    80004426:	6a42                	ld	s4,16(sp)
    80004428:	6aa2                	ld	s5,8(sp)
    8000442a:	b7f9                	j	800043f8 <fileclose+0x8e>

000000008000442c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000442c:	715d                	addi	sp,sp,-80
    8000442e:	e486                	sd	ra,72(sp)
    80004430:	e0a2                	sd	s0,64(sp)
    80004432:	fc26                	sd	s1,56(sp)
    80004434:	f052                	sd	s4,32(sp)
    80004436:	0880                	addi	s0,sp,80
    80004438:	84aa                	mv	s1,a0
    8000443a:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000443c:	d6cfd0ef          	jal	800019a8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004440:	409c                	lw	a5,0(s1)
    80004442:	37f9                	addiw	a5,a5,-2
    80004444:	4705                	li	a4,1
    80004446:	04f76263          	bltu	a4,a5,8000448a <filestat+0x5e>
    8000444a:	f84a                	sd	s2,48(sp)
    8000444c:	f44e                	sd	s3,40(sp)
    8000444e:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004450:	6c88                	ld	a0,24(s1)
    80004452:	8e8ff0ef          	jal	8000353a <ilock>
    stati(f->ip, &st);
    80004456:	fb840913          	addi	s2,s0,-72
    8000445a:	85ca                	mv	a1,s2
    8000445c:	6c88                	ld	a0,24(s1)
    8000445e:	c40ff0ef          	jal	8000389e <stati>
    iunlock(f->ip);
    80004462:	6c88                	ld	a0,24(s1)
    80004464:	984ff0ef          	jal	800035e8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004468:	46e1                	li	a3,24
    8000446a:	864a                	mv	a2,s2
    8000446c:	85d2                	mv	a1,s4
    8000446e:	0509b503          	ld	a0,80(s3)
    80004472:	9e2fd0ef          	jal	80001654 <copyout>
    80004476:	41f5551b          	sraiw	a0,a0,0x1f
    8000447a:	7942                	ld	s2,48(sp)
    8000447c:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000447e:	60a6                	ld	ra,72(sp)
    80004480:	6406                	ld	s0,64(sp)
    80004482:	74e2                	ld	s1,56(sp)
    80004484:	7a02                	ld	s4,32(sp)
    80004486:	6161                	addi	sp,sp,80
    80004488:	8082                	ret
  return -1;
    8000448a:	557d                	li	a0,-1
    8000448c:	bfcd                	j	8000447e <filestat+0x52>

000000008000448e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000448e:	7179                	addi	sp,sp,-48
    80004490:	f406                	sd	ra,40(sp)
    80004492:	f022                	sd	s0,32(sp)
    80004494:	e84a                	sd	s2,16(sp)
    80004496:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004498:	00854783          	lbu	a5,8(a0)
    8000449c:	cfd1                	beqz	a5,80004538 <fileread+0xaa>
    8000449e:	ec26                	sd	s1,24(sp)
    800044a0:	e44e                	sd	s3,8(sp)
    800044a2:	84aa                	mv	s1,a0
    800044a4:	892e                	mv	s2,a1
    800044a6:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800044a8:	411c                	lw	a5,0(a0)
    800044aa:	4705                	li	a4,1
    800044ac:	04e78363          	beq	a5,a4,800044f2 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044b0:	470d                	li	a4,3
    800044b2:	04e78763          	beq	a5,a4,80004500 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800044b6:	4709                	li	a4,2
    800044b8:	06e79a63          	bne	a5,a4,8000452c <fileread+0x9e>
    ilock(f->ip);
    800044bc:	6d08                	ld	a0,24(a0)
    800044be:	87cff0ef          	jal	8000353a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800044c2:	874e                	mv	a4,s3
    800044c4:	5094                	lw	a3,32(s1)
    800044c6:	864a                	mv	a2,s2
    800044c8:	4585                	li	a1,1
    800044ca:	6c88                	ld	a0,24(s1)
    800044cc:	c00ff0ef          	jal	800038cc <readi>
    800044d0:	892a                	mv	s2,a0
    800044d2:	00a05563          	blez	a0,800044dc <fileread+0x4e>
      f->off += r;
    800044d6:	509c                	lw	a5,32(s1)
    800044d8:	9fa9                	addw	a5,a5,a0
    800044da:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800044dc:	6c88                	ld	a0,24(s1)
    800044de:	90aff0ef          	jal	800035e8 <iunlock>
    800044e2:	64e2                	ld	s1,24(sp)
    800044e4:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800044e6:	854a                	mv	a0,s2
    800044e8:	70a2                	ld	ra,40(sp)
    800044ea:	7402                	ld	s0,32(sp)
    800044ec:	6942                	ld	s2,16(sp)
    800044ee:	6145                	addi	sp,sp,48
    800044f0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800044f2:	6908                	ld	a0,16(a0)
    800044f4:	3b0000ef          	jal	800048a4 <piperead>
    800044f8:	892a                	mv	s2,a0
    800044fa:	64e2                	ld	s1,24(sp)
    800044fc:	69a2                	ld	s3,8(sp)
    800044fe:	b7e5                	j	800044e6 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004500:	02451783          	lh	a5,36(a0)
    80004504:	03079693          	slli	a3,a5,0x30
    80004508:	92c1                	srli	a3,a3,0x30
    8000450a:	4725                	li	a4,9
    8000450c:	02d76963          	bltu	a4,a3,8000453e <fileread+0xb0>
    80004510:	0792                	slli	a5,a5,0x4
    80004512:	0001c717          	auipc	a4,0x1c
    80004516:	95670713          	addi	a4,a4,-1706 # 8001fe68 <devsw>
    8000451a:	97ba                	add	a5,a5,a4
    8000451c:	639c                	ld	a5,0(a5)
    8000451e:	c78d                	beqz	a5,80004548 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004520:	4505                	li	a0,1
    80004522:	9782                	jalr	a5
    80004524:	892a                	mv	s2,a0
    80004526:	64e2                	ld	s1,24(sp)
    80004528:	69a2                	ld	s3,8(sp)
    8000452a:	bf75                	j	800044e6 <fileread+0x58>
    panic("fileread");
    8000452c:	00003517          	auipc	a0,0x3
    80004530:	05450513          	addi	a0,a0,84 # 80007580 <etext+0x580>
    80004534:	af0fc0ef          	jal	80000824 <panic>
    return -1;
    80004538:	57fd                	li	a5,-1
    8000453a:	893e                	mv	s2,a5
    8000453c:	b76d                	j	800044e6 <fileread+0x58>
      return -1;
    8000453e:	57fd                	li	a5,-1
    80004540:	893e                	mv	s2,a5
    80004542:	64e2                	ld	s1,24(sp)
    80004544:	69a2                	ld	s3,8(sp)
    80004546:	b745                	j	800044e6 <fileread+0x58>
    80004548:	57fd                	li	a5,-1
    8000454a:	893e                	mv	s2,a5
    8000454c:	64e2                	ld	s1,24(sp)
    8000454e:	69a2                	ld	s3,8(sp)
    80004550:	bf59                	j	800044e6 <fileread+0x58>

0000000080004552 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004552:	00954783          	lbu	a5,9(a0)
    80004556:	10078f63          	beqz	a5,80004674 <filewrite+0x122>
{
    8000455a:	711d                	addi	sp,sp,-96
    8000455c:	ec86                	sd	ra,88(sp)
    8000455e:	e8a2                	sd	s0,80(sp)
    80004560:	e0ca                	sd	s2,64(sp)
    80004562:	f456                	sd	s5,40(sp)
    80004564:	f05a                	sd	s6,32(sp)
    80004566:	1080                	addi	s0,sp,96
    80004568:	892a                	mv	s2,a0
    8000456a:	8b2e                	mv	s6,a1
    8000456c:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000456e:	411c                	lw	a5,0(a0)
    80004570:	4705                	li	a4,1
    80004572:	02e78a63          	beq	a5,a4,800045a6 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004576:	470d                	li	a4,3
    80004578:	02e78b63          	beq	a5,a4,800045ae <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000457c:	4709                	li	a4,2
    8000457e:	0ce79f63          	bne	a5,a4,8000465c <filewrite+0x10a>
    80004582:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004584:	0ac05a63          	blez	a2,80004638 <filewrite+0xe6>
    80004588:	e4a6                	sd	s1,72(sp)
    8000458a:	fc4e                	sd	s3,56(sp)
    8000458c:	ec5e                	sd	s7,24(sp)
    8000458e:	e862                	sd	s8,16(sp)
    80004590:	e466                	sd	s9,8(sp)
    int i = 0;
    80004592:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004594:	6b85                	lui	s7,0x1
    80004596:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000459a:	6785                	lui	a5,0x1
    8000459c:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800045a0:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045a2:	4c05                	li	s8,1
    800045a4:	a8ad                	j	8000461e <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800045a6:	6908                	ld	a0,16(a0)
    800045a8:	204000ef          	jal	800047ac <pipewrite>
    800045ac:	a04d                	j	8000464e <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800045ae:	02451783          	lh	a5,36(a0)
    800045b2:	03079693          	slli	a3,a5,0x30
    800045b6:	92c1                	srli	a3,a3,0x30
    800045b8:	4725                	li	a4,9
    800045ba:	0ad76f63          	bltu	a4,a3,80004678 <filewrite+0x126>
    800045be:	0792                	slli	a5,a5,0x4
    800045c0:	0001c717          	auipc	a4,0x1c
    800045c4:	8a870713          	addi	a4,a4,-1880 # 8001fe68 <devsw>
    800045c8:	97ba                	add	a5,a5,a4
    800045ca:	679c                	ld	a5,8(a5)
    800045cc:	cbc5                	beqz	a5,8000467c <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    800045ce:	4505                	li	a0,1
    800045d0:	9782                	jalr	a5
    800045d2:	a8b5                	j	8000464e <filewrite+0xfc>
      if(n1 > max)
    800045d4:	2981                	sext.w	s3,s3
      begin_op();
    800045d6:	971ff0ef          	jal	80003f46 <begin_op>
      ilock(f->ip);
    800045da:	01893503          	ld	a0,24(s2)
    800045de:	f5dfe0ef          	jal	8000353a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800045e2:	874e                	mv	a4,s3
    800045e4:	02092683          	lw	a3,32(s2)
    800045e8:	016a0633          	add	a2,s4,s6
    800045ec:	85e2                	mv	a1,s8
    800045ee:	01893503          	ld	a0,24(s2)
    800045f2:	bccff0ef          	jal	800039be <writei>
    800045f6:	84aa                	mv	s1,a0
    800045f8:	00a05763          	blez	a0,80004606 <filewrite+0xb4>
        f->off += r;
    800045fc:	02092783          	lw	a5,32(s2)
    80004600:	9fa9                	addw	a5,a5,a0
    80004602:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004606:	01893503          	ld	a0,24(s2)
    8000460a:	fdffe0ef          	jal	800035e8 <iunlock>
      end_op();
    8000460e:	9a9ff0ef          	jal	80003fb6 <end_op>

      if(r != n1){
    80004612:	02999563          	bne	s3,s1,8000463c <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004616:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000461a:	015a5963          	bge	s4,s5,8000462c <filewrite+0xda>
      int n1 = n - i;
    8000461e:	414a87bb          	subw	a5,s5,s4
    80004622:	89be                	mv	s3,a5
      if(n1 > max)
    80004624:	fafbd8e3          	bge	s7,a5,800045d4 <filewrite+0x82>
    80004628:	89e6                	mv	s3,s9
    8000462a:	b76d                	j	800045d4 <filewrite+0x82>
    8000462c:	64a6                	ld	s1,72(sp)
    8000462e:	79e2                	ld	s3,56(sp)
    80004630:	6be2                	ld	s7,24(sp)
    80004632:	6c42                	ld	s8,16(sp)
    80004634:	6ca2                	ld	s9,8(sp)
    80004636:	a801                	j	80004646 <filewrite+0xf4>
    int i = 0;
    80004638:	4a01                	li	s4,0
    8000463a:	a031                	j	80004646 <filewrite+0xf4>
    8000463c:	64a6                	ld	s1,72(sp)
    8000463e:	79e2                	ld	s3,56(sp)
    80004640:	6be2                	ld	s7,24(sp)
    80004642:	6c42                	ld	s8,16(sp)
    80004644:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004646:	034a9d63          	bne	s5,s4,80004680 <filewrite+0x12e>
    8000464a:	8556                	mv	a0,s5
    8000464c:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000464e:	60e6                	ld	ra,88(sp)
    80004650:	6446                	ld	s0,80(sp)
    80004652:	6906                	ld	s2,64(sp)
    80004654:	7aa2                	ld	s5,40(sp)
    80004656:	7b02                	ld	s6,32(sp)
    80004658:	6125                	addi	sp,sp,96
    8000465a:	8082                	ret
    8000465c:	e4a6                	sd	s1,72(sp)
    8000465e:	fc4e                	sd	s3,56(sp)
    80004660:	f852                	sd	s4,48(sp)
    80004662:	ec5e                	sd	s7,24(sp)
    80004664:	e862                	sd	s8,16(sp)
    80004666:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004668:	00003517          	auipc	a0,0x3
    8000466c:	f2850513          	addi	a0,a0,-216 # 80007590 <etext+0x590>
    80004670:	9b4fc0ef          	jal	80000824 <panic>
    return -1;
    80004674:	557d                	li	a0,-1
}
    80004676:	8082                	ret
      return -1;
    80004678:	557d                	li	a0,-1
    8000467a:	bfd1                	j	8000464e <filewrite+0xfc>
    8000467c:	557d                	li	a0,-1
    8000467e:	bfc1                	j	8000464e <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004680:	557d                	li	a0,-1
    80004682:	7a42                	ld	s4,48(sp)
    80004684:	b7e9                	j	8000464e <filewrite+0xfc>

0000000080004686 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004686:	7179                	addi	sp,sp,-48
    80004688:	f406                	sd	ra,40(sp)
    8000468a:	f022                	sd	s0,32(sp)
    8000468c:	ec26                	sd	s1,24(sp)
    8000468e:	e052                	sd	s4,0(sp)
    80004690:	1800                	addi	s0,sp,48
    80004692:	84aa                	mv	s1,a0
    80004694:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004696:	0005b023          	sd	zero,0(a1)
    8000469a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000469e:	c29ff0ef          	jal	800042c6 <filealloc>
    800046a2:	e088                	sd	a0,0(s1)
    800046a4:	c549                	beqz	a0,8000472e <pipealloc+0xa8>
    800046a6:	c21ff0ef          	jal	800042c6 <filealloc>
    800046aa:	00aa3023          	sd	a0,0(s4)
    800046ae:	cd25                	beqz	a0,80004726 <pipealloc+0xa0>
    800046b0:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800046b2:	c92fc0ef          	jal	80000b44 <kalloc>
    800046b6:	892a                	mv	s2,a0
    800046b8:	c12d                	beqz	a0,8000471a <pipealloc+0x94>
    800046ba:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800046bc:	4985                	li	s3,1
    800046be:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800046c2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800046c6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800046ca:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800046ce:	00003597          	auipc	a1,0x3
    800046d2:	ed258593          	addi	a1,a1,-302 # 800075a0 <etext+0x5a0>
    800046d6:	cc8fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    800046da:	609c                	ld	a5,0(s1)
    800046dc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800046e0:	609c                	ld	a5,0(s1)
    800046e2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800046e6:	609c                	ld	a5,0(s1)
    800046e8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800046ec:	609c                	ld	a5,0(s1)
    800046ee:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800046f2:	000a3783          	ld	a5,0(s4)
    800046f6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046fa:	000a3783          	ld	a5,0(s4)
    800046fe:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004702:	000a3783          	ld	a5,0(s4)
    80004706:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000470a:	000a3783          	ld	a5,0(s4)
    8000470e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004712:	4501                	li	a0,0
    80004714:	6942                	ld	s2,16(sp)
    80004716:	69a2                	ld	s3,8(sp)
    80004718:	a01d                	j	8000473e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000471a:	6088                	ld	a0,0(s1)
    8000471c:	c119                	beqz	a0,80004722 <pipealloc+0x9c>
    8000471e:	6942                	ld	s2,16(sp)
    80004720:	a029                	j	8000472a <pipealloc+0xa4>
    80004722:	6942                	ld	s2,16(sp)
    80004724:	a029                	j	8000472e <pipealloc+0xa8>
    80004726:	6088                	ld	a0,0(s1)
    80004728:	c10d                	beqz	a0,8000474a <pipealloc+0xc4>
    fileclose(*f0);
    8000472a:	c41ff0ef          	jal	8000436a <fileclose>
  if(*f1)
    8000472e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004732:	557d                	li	a0,-1
  if(*f1)
    80004734:	c789                	beqz	a5,8000473e <pipealloc+0xb8>
    fileclose(*f1);
    80004736:	853e                	mv	a0,a5
    80004738:	c33ff0ef          	jal	8000436a <fileclose>
  return -1;
    8000473c:	557d                	li	a0,-1
}
    8000473e:	70a2                	ld	ra,40(sp)
    80004740:	7402                	ld	s0,32(sp)
    80004742:	64e2                	ld	s1,24(sp)
    80004744:	6a02                	ld	s4,0(sp)
    80004746:	6145                	addi	sp,sp,48
    80004748:	8082                	ret
  return -1;
    8000474a:	557d                	li	a0,-1
    8000474c:	bfcd                	j	8000473e <pipealloc+0xb8>

000000008000474e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000474e:	1101                	addi	sp,sp,-32
    80004750:	ec06                	sd	ra,24(sp)
    80004752:	e822                	sd	s0,16(sp)
    80004754:	e426                	sd	s1,8(sp)
    80004756:	e04a                	sd	s2,0(sp)
    80004758:	1000                	addi	s0,sp,32
    8000475a:	84aa                	mv	s1,a0
    8000475c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000475e:	ccafc0ef          	jal	80000c28 <acquire>
  if(writable){
    80004762:	02090763          	beqz	s2,80004790 <pipeclose+0x42>
    pi->writeopen = 0;
    80004766:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000476a:	21848513          	addi	a0,s1,536
    8000476e:	a61fd0ef          	jal	800021ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004772:	2204a783          	lw	a5,544(s1)
    80004776:	e781                	bnez	a5,8000477e <pipeclose+0x30>
    80004778:	2244a783          	lw	a5,548(s1)
    8000477c:	c38d                	beqz	a5,8000479e <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    8000477e:	8526                	mv	a0,s1
    80004780:	d3cfc0ef          	jal	80000cbc <release>
}
    80004784:	60e2                	ld	ra,24(sp)
    80004786:	6442                	ld	s0,16(sp)
    80004788:	64a2                	ld	s1,8(sp)
    8000478a:	6902                	ld	s2,0(sp)
    8000478c:	6105                	addi	sp,sp,32
    8000478e:	8082                	ret
    pi->readopen = 0;
    80004790:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004794:	21c48513          	addi	a0,s1,540
    80004798:	a37fd0ef          	jal	800021ce <wakeup>
    8000479c:	bfd9                	j	80004772 <pipeclose+0x24>
    release(&pi->lock);
    8000479e:	8526                	mv	a0,s1
    800047a0:	d1cfc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    800047a4:	8526                	mv	a0,s1
    800047a6:	ab6fc0ef          	jal	80000a5c <kfree>
    800047aa:	bfe9                	j	80004784 <pipeclose+0x36>

00000000800047ac <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800047ac:	7159                	addi	sp,sp,-112
    800047ae:	f486                	sd	ra,104(sp)
    800047b0:	f0a2                	sd	s0,96(sp)
    800047b2:	eca6                	sd	s1,88(sp)
    800047b4:	e8ca                	sd	s2,80(sp)
    800047b6:	e4ce                	sd	s3,72(sp)
    800047b8:	e0d2                	sd	s4,64(sp)
    800047ba:	fc56                	sd	s5,56(sp)
    800047bc:	1880                	addi	s0,sp,112
    800047be:	84aa                	mv	s1,a0
    800047c0:	8aae                	mv	s5,a1
    800047c2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800047c4:	9e4fd0ef          	jal	800019a8 <myproc>
    800047c8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800047ca:	8526                	mv	a0,s1
    800047cc:	c5cfc0ef          	jal	80000c28 <acquire>
  while(i < n){
    800047d0:	0d405263          	blez	s4,80004894 <pipewrite+0xe8>
    800047d4:	f85a                	sd	s6,48(sp)
    800047d6:	f45e                	sd	s7,40(sp)
    800047d8:	f062                	sd	s8,32(sp)
    800047da:	ec66                	sd	s9,24(sp)
    800047dc:	e86a                	sd	s10,16(sp)
  int i = 0;
    800047de:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047e0:	f9f40c13          	addi	s8,s0,-97
    800047e4:	4b85                	li	s7,1
    800047e6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800047e8:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800047ec:	21c48c93          	addi	s9,s1,540
    800047f0:	a82d                	j	8000482a <pipewrite+0x7e>
      release(&pi->lock);
    800047f2:	8526                	mv	a0,s1
    800047f4:	cc8fc0ef          	jal	80000cbc <release>
      return -1;
    800047f8:	597d                	li	s2,-1
    800047fa:	7b42                	ld	s6,48(sp)
    800047fc:	7ba2                	ld	s7,40(sp)
    800047fe:	7c02                	ld	s8,32(sp)
    80004800:	6ce2                	ld	s9,24(sp)
    80004802:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004804:	854a                	mv	a0,s2
    80004806:	70a6                	ld	ra,104(sp)
    80004808:	7406                	ld	s0,96(sp)
    8000480a:	64e6                	ld	s1,88(sp)
    8000480c:	6946                	ld	s2,80(sp)
    8000480e:	69a6                	ld	s3,72(sp)
    80004810:	6a06                	ld	s4,64(sp)
    80004812:	7ae2                	ld	s5,56(sp)
    80004814:	6165                	addi	sp,sp,112
    80004816:	8082                	ret
      wakeup(&pi->nread);
    80004818:	856a                	mv	a0,s10
    8000481a:	9b5fd0ef          	jal	800021ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000481e:	85a6                	mv	a1,s1
    80004820:	8566                	mv	a0,s9
    80004822:	961fd0ef          	jal	80002182 <sleep>
  while(i < n){
    80004826:	05495a63          	bge	s2,s4,8000487a <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000482a:	2204a783          	lw	a5,544(s1)
    8000482e:	d3f1                	beqz	a5,800047f2 <pipewrite+0x46>
    80004830:	854e                	mv	a0,s3
    80004832:	bc9fd0ef          	jal	800023fa <killed>
    80004836:	fd55                	bnez	a0,800047f2 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004838:	2184a783          	lw	a5,536(s1)
    8000483c:	21c4a703          	lw	a4,540(s1)
    80004840:	2007879b          	addiw	a5,a5,512
    80004844:	fcf70ae3          	beq	a4,a5,80004818 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004848:	86de                	mv	a3,s7
    8000484a:	01590633          	add	a2,s2,s5
    8000484e:	85e2                	mv	a1,s8
    80004850:	0509b503          	ld	a0,80(s3)
    80004854:	ebffc0ef          	jal	80001712 <copyin>
    80004858:	05650063          	beq	a0,s6,80004898 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000485c:	21c4a783          	lw	a5,540(s1)
    80004860:	0017871b          	addiw	a4,a5,1
    80004864:	20e4ae23          	sw	a4,540(s1)
    80004868:	1ff7f793          	andi	a5,a5,511
    8000486c:	97a6                	add	a5,a5,s1
    8000486e:	f9f44703          	lbu	a4,-97(s0)
    80004872:	00e78c23          	sb	a4,24(a5)
      i++;
    80004876:	2905                	addiw	s2,s2,1
    80004878:	b77d                	j	80004826 <pipewrite+0x7a>
    8000487a:	7b42                	ld	s6,48(sp)
    8000487c:	7ba2                	ld	s7,40(sp)
    8000487e:	7c02                	ld	s8,32(sp)
    80004880:	6ce2                	ld	s9,24(sp)
    80004882:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004884:	21848513          	addi	a0,s1,536
    80004888:	947fd0ef          	jal	800021ce <wakeup>
  release(&pi->lock);
    8000488c:	8526                	mv	a0,s1
    8000488e:	c2efc0ef          	jal	80000cbc <release>
  return i;
    80004892:	bf8d                	j	80004804 <pipewrite+0x58>
  int i = 0;
    80004894:	4901                	li	s2,0
    80004896:	b7fd                	j	80004884 <pipewrite+0xd8>
    80004898:	7b42                	ld	s6,48(sp)
    8000489a:	7ba2                	ld	s7,40(sp)
    8000489c:	7c02                	ld	s8,32(sp)
    8000489e:	6ce2                	ld	s9,24(sp)
    800048a0:	6d42                	ld	s10,16(sp)
    800048a2:	b7cd                	j	80004884 <pipewrite+0xd8>

00000000800048a4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048a4:	711d                	addi	sp,sp,-96
    800048a6:	ec86                	sd	ra,88(sp)
    800048a8:	e8a2                	sd	s0,80(sp)
    800048aa:	e4a6                	sd	s1,72(sp)
    800048ac:	e0ca                	sd	s2,64(sp)
    800048ae:	fc4e                	sd	s3,56(sp)
    800048b0:	f852                	sd	s4,48(sp)
    800048b2:	f456                	sd	s5,40(sp)
    800048b4:	1080                	addi	s0,sp,96
    800048b6:	84aa                	mv	s1,a0
    800048b8:	892e                	mv	s2,a1
    800048ba:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048bc:	8ecfd0ef          	jal	800019a8 <myproc>
    800048c0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800048c2:	8526                	mv	a0,s1
    800048c4:	b64fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800048c8:	2184a703          	lw	a4,536(s1)
    800048cc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800048d0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800048d4:	02f71763          	bne	a4,a5,80004902 <piperead+0x5e>
    800048d8:	2244a783          	lw	a5,548(s1)
    800048dc:	cf85                	beqz	a5,80004914 <piperead+0x70>
    if(killed(pr)){
    800048de:	8552                	mv	a0,s4
    800048e0:	b1bfd0ef          	jal	800023fa <killed>
    800048e4:	e11d                	bnez	a0,8000490a <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800048e6:	85a6                	mv	a1,s1
    800048e8:	854e                	mv	a0,s3
    800048ea:	899fd0ef          	jal	80002182 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800048ee:	2184a703          	lw	a4,536(s1)
    800048f2:	21c4a783          	lw	a5,540(s1)
    800048f6:	fef701e3          	beq	a4,a5,800048d8 <piperead+0x34>
    800048fa:	f05a                	sd	s6,32(sp)
    800048fc:	ec5e                	sd	s7,24(sp)
    800048fe:	e862                	sd	s8,16(sp)
    80004900:	a829                	j	8000491a <piperead+0x76>
    80004902:	f05a                	sd	s6,32(sp)
    80004904:	ec5e                	sd	s7,24(sp)
    80004906:	e862                	sd	s8,16(sp)
    80004908:	a809                	j	8000491a <piperead+0x76>
      release(&pi->lock);
    8000490a:	8526                	mv	a0,s1
    8000490c:	bb0fc0ef          	jal	80000cbc <release>
      return -1;
    80004910:	59fd                	li	s3,-1
    80004912:	a0a5                	j	8000497a <piperead+0xd6>
    80004914:	f05a                	sd	s6,32(sp)
    80004916:	ec5e                	sd	s7,24(sp)
    80004918:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000491a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000491c:	faf40c13          	addi	s8,s0,-81
    80004920:	4b85                	li	s7,1
    80004922:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004924:	05505163          	blez	s5,80004966 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004928:	2184a783          	lw	a5,536(s1)
    8000492c:	21c4a703          	lw	a4,540(s1)
    80004930:	02f70b63          	beq	a4,a5,80004966 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004934:	1ff7f793          	andi	a5,a5,511
    80004938:	97a6                	add	a5,a5,s1
    8000493a:	0187c783          	lbu	a5,24(a5)
    8000493e:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004942:	86de                	mv	a3,s7
    80004944:	8662                	mv	a2,s8
    80004946:	85ca                	mv	a1,s2
    80004948:	050a3503          	ld	a0,80(s4)
    8000494c:	d09fc0ef          	jal	80001654 <copyout>
    80004950:	03650f63          	beq	a0,s6,8000498e <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004954:	2184a783          	lw	a5,536(s1)
    80004958:	2785                	addiw	a5,a5,1
    8000495a:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000495e:	2985                	addiw	s3,s3,1
    80004960:	0905                	addi	s2,s2,1
    80004962:	fd3a93e3          	bne	s5,s3,80004928 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004966:	21c48513          	addi	a0,s1,540
    8000496a:	865fd0ef          	jal	800021ce <wakeup>
  release(&pi->lock);
    8000496e:	8526                	mv	a0,s1
    80004970:	b4cfc0ef          	jal	80000cbc <release>
    80004974:	7b02                	ld	s6,32(sp)
    80004976:	6be2                	ld	s7,24(sp)
    80004978:	6c42                	ld	s8,16(sp)
  return i;
}
    8000497a:	854e                	mv	a0,s3
    8000497c:	60e6                	ld	ra,88(sp)
    8000497e:	6446                	ld	s0,80(sp)
    80004980:	64a6                	ld	s1,72(sp)
    80004982:	6906                	ld	s2,64(sp)
    80004984:	79e2                	ld	s3,56(sp)
    80004986:	7a42                	ld	s4,48(sp)
    80004988:	7aa2                	ld	s5,40(sp)
    8000498a:	6125                	addi	sp,sp,96
    8000498c:	8082                	ret
      if(i == 0)
    8000498e:	fc099ce3          	bnez	s3,80004966 <piperead+0xc2>
        i = -1;
    80004992:	89aa                	mv	s3,a0
    80004994:	bfc9                	j	80004966 <piperead+0xc2>

0000000080004996 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004996:	1141                	addi	sp,sp,-16
    80004998:	e406                	sd	ra,8(sp)
    8000499a:	e022                	sd	s0,0(sp)
    8000499c:	0800                	addi	s0,sp,16
    8000499e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800049a0:	0035151b          	slliw	a0,a0,0x3
    800049a4:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800049a6:	8b89                	andi	a5,a5,2
    800049a8:	c399                	beqz	a5,800049ae <flags2perm+0x18>
      perm |= PTE_W;
    800049aa:	00456513          	ori	a0,a0,4
    return perm;
}
    800049ae:	60a2                	ld	ra,8(sp)
    800049b0:	6402                	ld	s0,0(sp)
    800049b2:	0141                	addi	sp,sp,16
    800049b4:	8082                	ret

00000000800049b6 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800049b6:	de010113          	addi	sp,sp,-544
    800049ba:	20113c23          	sd	ra,536(sp)
    800049be:	20813823          	sd	s0,528(sp)
    800049c2:	20913423          	sd	s1,520(sp)
    800049c6:	21213023          	sd	s2,512(sp)
    800049ca:	1400                	addi	s0,sp,544
    800049cc:	892a                	mv	s2,a0
    800049ce:	dea43823          	sd	a0,-528(s0)
    800049d2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049d6:	fd3fc0ef          	jal	800019a8 <myproc>
    800049da:	84aa                	mv	s1,a0

  begin_op();
    800049dc:	d6aff0ef          	jal	80003f46 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800049e0:	854a                	mv	a0,s2
    800049e2:	b86ff0ef          	jal	80003d68 <namei>
    800049e6:	cd21                	beqz	a0,80004a3e <kexec+0x88>
    800049e8:	fbd2                	sd	s4,496(sp)
    800049ea:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800049ec:	b4ffe0ef          	jal	8000353a <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800049f0:	04000713          	li	a4,64
    800049f4:	4681                	li	a3,0
    800049f6:	e5040613          	addi	a2,s0,-432
    800049fa:	4581                	li	a1,0
    800049fc:	8552                	mv	a0,s4
    800049fe:	ecffe0ef          	jal	800038cc <readi>
    80004a02:	04000793          	li	a5,64
    80004a06:	00f51a63          	bne	a0,a5,80004a1a <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004a0a:	e5042703          	lw	a4,-432(s0)
    80004a0e:	464c47b7          	lui	a5,0x464c4
    80004a12:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a16:	02f70863          	beq	a4,a5,80004a46 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004a1a:	8552                	mv	a0,s4
    80004a1c:	d2bfe0ef          	jal	80003746 <iunlockput>
    end_op();
    80004a20:	d96ff0ef          	jal	80003fb6 <end_op>
  }
  return -1;
    80004a24:	557d                	li	a0,-1
    80004a26:	7a5e                	ld	s4,496(sp)
}
    80004a28:	21813083          	ld	ra,536(sp)
    80004a2c:	21013403          	ld	s0,528(sp)
    80004a30:	20813483          	ld	s1,520(sp)
    80004a34:	20013903          	ld	s2,512(sp)
    80004a38:	22010113          	addi	sp,sp,544
    80004a3c:	8082                	ret
    end_op();
    80004a3e:	d78ff0ef          	jal	80003fb6 <end_op>
    return -1;
    80004a42:	557d                	li	a0,-1
    80004a44:	b7d5                	j	80004a28 <kexec+0x72>
    80004a46:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004a48:	8526                	mv	a0,s1
    80004a4a:	868fd0ef          	jal	80001ab2 <proc_pagetable>
    80004a4e:	8b2a                	mv	s6,a0
    80004a50:	26050f63          	beqz	a0,80004cce <kexec+0x318>
    80004a54:	ffce                	sd	s3,504(sp)
    80004a56:	f7d6                	sd	s5,488(sp)
    80004a58:	efde                	sd	s7,472(sp)
    80004a5a:	ebe2                	sd	s8,464(sp)
    80004a5c:	e7e6                	sd	s9,456(sp)
    80004a5e:	e3ea                	sd	s10,448(sp)
    80004a60:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a62:	e8845783          	lhu	a5,-376(s0)
    80004a66:	0e078963          	beqz	a5,80004b58 <kexec+0x1a2>
    80004a6a:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a6e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a70:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a72:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004a76:	6c85                	lui	s9,0x1
    80004a78:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a7c:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004a80:	6a85                	lui	s5,0x1
    80004a82:	a085                	j	80004ae2 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a84:	00003517          	auipc	a0,0x3
    80004a88:	b2450513          	addi	a0,a0,-1244 # 800075a8 <etext+0x5a8>
    80004a8c:	d99fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004a90:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a92:	874a                	mv	a4,s2
    80004a94:	009b86bb          	addw	a3,s7,s1
    80004a98:	4581                	li	a1,0
    80004a9a:	8552                	mv	a0,s4
    80004a9c:	e31fe0ef          	jal	800038cc <readi>
    80004aa0:	22a91b63          	bne	s2,a0,80004cd6 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004aa4:	009a84bb          	addw	s1,s5,s1
    80004aa8:	0334f263          	bgeu	s1,s3,80004acc <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004aac:	02049593          	slli	a1,s1,0x20
    80004ab0:	9181                	srli	a1,a1,0x20
    80004ab2:	95e2                	add	a1,a1,s8
    80004ab4:	855a                	mv	a0,s6
    80004ab6:	d70fc0ef          	jal	80001026 <walkaddr>
    80004aba:	862a                	mv	a2,a0
    if(pa == 0)
    80004abc:	d561                	beqz	a0,80004a84 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004abe:	409987bb          	subw	a5,s3,s1
    80004ac2:	893e                	mv	s2,a5
    80004ac4:	fcfcf6e3          	bgeu	s9,a5,80004a90 <kexec+0xda>
    80004ac8:	8956                	mv	s2,s5
    80004aca:	b7d9                	j	80004a90 <kexec+0xda>
    sz = sz1;
    80004acc:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ad0:	2d05                	addiw	s10,s10,1
    80004ad2:	e0843783          	ld	a5,-504(s0)
    80004ad6:	0387869b          	addiw	a3,a5,56
    80004ada:	e8845783          	lhu	a5,-376(s0)
    80004ade:	06fd5e63          	bge	s10,a5,80004b5a <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ae2:	e0d43423          	sd	a3,-504(s0)
    80004ae6:	876e                	mv	a4,s11
    80004ae8:	e1840613          	addi	a2,s0,-488
    80004aec:	4581                	li	a1,0
    80004aee:	8552                	mv	a0,s4
    80004af0:	dddfe0ef          	jal	800038cc <readi>
    80004af4:	1db51f63          	bne	a0,s11,80004cd2 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004af8:	e1842783          	lw	a5,-488(s0)
    80004afc:	4705                	li	a4,1
    80004afe:	fce799e3          	bne	a5,a4,80004ad0 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004b02:	e4043483          	ld	s1,-448(s0)
    80004b06:	e3843783          	ld	a5,-456(s0)
    80004b0a:	1ef4e463          	bltu	s1,a5,80004cf2 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b0e:	e2843783          	ld	a5,-472(s0)
    80004b12:	94be                	add	s1,s1,a5
    80004b14:	1ef4e263          	bltu	s1,a5,80004cf8 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004b18:	de843703          	ld	a4,-536(s0)
    80004b1c:	8ff9                	and	a5,a5,a4
    80004b1e:	1e079063          	bnez	a5,80004cfe <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004b22:	e1c42503          	lw	a0,-484(s0)
    80004b26:	e71ff0ef          	jal	80004996 <flags2perm>
    80004b2a:	86aa                	mv	a3,a0
    80004b2c:	8626                	mv	a2,s1
    80004b2e:	85ca                	mv	a1,s2
    80004b30:	855a                	mv	a0,s6
    80004b32:	fcafc0ef          	jal	800012fc <uvmalloc>
    80004b36:	dea43c23          	sd	a0,-520(s0)
    80004b3a:	1c050563          	beqz	a0,80004d04 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b3e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004b42:	00098863          	beqz	s3,80004b52 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b46:	e2843c03          	ld	s8,-472(s0)
    80004b4a:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004b4e:	4481                	li	s1,0
    80004b50:	bfb1                	j	80004aac <kexec+0xf6>
    sz = sz1;
    80004b52:	df843903          	ld	s2,-520(s0)
    80004b56:	bfad                	j	80004ad0 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b58:	4901                	li	s2,0
  iunlockput(ip);
    80004b5a:	8552                	mv	a0,s4
    80004b5c:	bebfe0ef          	jal	80003746 <iunlockput>
  end_op();
    80004b60:	c56ff0ef          	jal	80003fb6 <end_op>
  p = myproc();
    80004b64:	e45fc0ef          	jal	800019a8 <myproc>
    80004b68:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004b6a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004b6e:	6985                	lui	s3,0x1
    80004b70:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004b72:	99ca                	add	s3,s3,s2
    80004b74:	77fd                	lui	a5,0xfffff
    80004b76:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004b7a:	4691                	li	a3,4
    80004b7c:	6609                	lui	a2,0x2
    80004b7e:	964e                	add	a2,a2,s3
    80004b80:	85ce                	mv	a1,s3
    80004b82:	855a                	mv	a0,s6
    80004b84:	f78fc0ef          	jal	800012fc <uvmalloc>
    80004b88:	8a2a                	mv	s4,a0
    80004b8a:	e105                	bnez	a0,80004baa <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004b8c:	85ce                	mv	a1,s3
    80004b8e:	855a                	mv	a0,s6
    80004b90:	fa7fc0ef          	jal	80001b36 <proc_freepagetable>
  return -1;
    80004b94:	557d                	li	a0,-1
    80004b96:	79fe                	ld	s3,504(sp)
    80004b98:	7a5e                	ld	s4,496(sp)
    80004b9a:	7abe                	ld	s5,488(sp)
    80004b9c:	7b1e                	ld	s6,480(sp)
    80004b9e:	6bfe                	ld	s7,472(sp)
    80004ba0:	6c5e                	ld	s8,464(sp)
    80004ba2:	6cbe                	ld	s9,456(sp)
    80004ba4:	6d1e                	ld	s10,448(sp)
    80004ba6:	7dfa                	ld	s11,440(sp)
    80004ba8:	b541                	j	80004a28 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004baa:	75f9                	lui	a1,0xffffe
    80004bac:	95aa                	add	a1,a1,a0
    80004bae:	855a                	mv	a0,s6
    80004bb0:	91ffc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004bb4:	800a0b93          	addi	s7,s4,-2048
    80004bb8:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004bbc:	e0043783          	ld	a5,-512(s0)
    80004bc0:	6388                	ld	a0,0(a5)
  sp = sz;
    80004bc2:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004bc4:	4481                	li	s1,0
    ustack[argc] = sp;
    80004bc6:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004bca:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004bce:	cd21                	beqz	a0,80004c26 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004bd0:	ab2fc0ef          	jal	80000e82 <strlen>
    80004bd4:	0015079b          	addiw	a5,a0,1
    80004bd8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004bdc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004be0:	13796563          	bltu	s2,s7,80004d0a <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004be4:	e0043d83          	ld	s11,-512(s0)
    80004be8:	000db983          	ld	s3,0(s11)
    80004bec:	854e                	mv	a0,s3
    80004bee:	a94fc0ef          	jal	80000e82 <strlen>
    80004bf2:	0015069b          	addiw	a3,a0,1
    80004bf6:	864e                	mv	a2,s3
    80004bf8:	85ca                	mv	a1,s2
    80004bfa:	855a                	mv	a0,s6
    80004bfc:	a59fc0ef          	jal	80001654 <copyout>
    80004c00:	10054763          	bltz	a0,80004d0e <kexec+0x358>
    ustack[argc] = sp;
    80004c04:	00349793          	slli	a5,s1,0x3
    80004c08:	97e6                	add	a5,a5,s9
    80004c0a:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde000>
  for(argc = 0; argv[argc]; argc++) {
    80004c0e:	0485                	addi	s1,s1,1
    80004c10:	008d8793          	addi	a5,s11,8
    80004c14:	e0f43023          	sd	a5,-512(s0)
    80004c18:	008db503          	ld	a0,8(s11)
    80004c1c:	c509                	beqz	a0,80004c26 <kexec+0x270>
    if(argc >= MAXARG)
    80004c1e:	fb8499e3          	bne	s1,s8,80004bd0 <kexec+0x21a>
  sz = sz1;
    80004c22:	89d2                	mv	s3,s4
    80004c24:	b7a5                	j	80004b8c <kexec+0x1d6>
  ustack[argc] = 0;
    80004c26:	00349793          	slli	a5,s1,0x3
    80004c2a:	f9078793          	addi	a5,a5,-112
    80004c2e:	97a2                	add	a5,a5,s0
    80004c30:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004c34:	00349693          	slli	a3,s1,0x3
    80004c38:	06a1                	addi	a3,a3,8
    80004c3a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004c3e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004c42:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004c44:	f57964e3          	bltu	s2,s7,80004b8c <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004c48:	e9040613          	addi	a2,s0,-368
    80004c4c:	85ca                	mv	a1,s2
    80004c4e:	855a                	mv	a0,s6
    80004c50:	a05fc0ef          	jal	80001654 <copyout>
    80004c54:	f2054ce3          	bltz	a0,80004b8c <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c58:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004c5c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004c60:	df043783          	ld	a5,-528(s0)
    80004c64:	0007c703          	lbu	a4,0(a5)
    80004c68:	cf11                	beqz	a4,80004c84 <kexec+0x2ce>
    80004c6a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004c6c:	02f00693          	li	a3,47
    80004c70:	a029                	j	80004c7a <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004c72:	0785                	addi	a5,a5,1
    80004c74:	fff7c703          	lbu	a4,-1(a5)
    80004c78:	c711                	beqz	a4,80004c84 <kexec+0x2ce>
    if(*s == '/')
    80004c7a:	fed71ce3          	bne	a4,a3,80004c72 <kexec+0x2bc>
      last = s+1;
    80004c7e:	def43823          	sd	a5,-528(s0)
    80004c82:	bfc5                	j	80004c72 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c84:	4641                	li	a2,16
    80004c86:	df043583          	ld	a1,-528(s0)
    80004c8a:	158a8513          	addi	a0,s5,344
    80004c8e:	9befc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004c92:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004c96:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004c9a:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004c9e:	058ab783          	ld	a5,88(s5)
    80004ca2:	e6843703          	ld	a4,-408(s0)
    80004ca6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ca8:	058ab783          	ld	a5,88(s5)
    80004cac:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cb0:	85ea                	mv	a1,s10
    80004cb2:	e85fc0ef          	jal	80001b36 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cb6:	0004851b          	sext.w	a0,s1
    80004cba:	79fe                	ld	s3,504(sp)
    80004cbc:	7a5e                	ld	s4,496(sp)
    80004cbe:	7abe                	ld	s5,488(sp)
    80004cc0:	7b1e                	ld	s6,480(sp)
    80004cc2:	6bfe                	ld	s7,472(sp)
    80004cc4:	6c5e                	ld	s8,464(sp)
    80004cc6:	6cbe                	ld	s9,456(sp)
    80004cc8:	6d1e                	ld	s10,448(sp)
    80004cca:	7dfa                	ld	s11,440(sp)
    80004ccc:	bbb1                	j	80004a28 <kexec+0x72>
    80004cce:	7b1e                	ld	s6,480(sp)
    80004cd0:	b3a9                	j	80004a1a <kexec+0x64>
    80004cd2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004cd6:	df843583          	ld	a1,-520(s0)
    80004cda:	855a                	mv	a0,s6
    80004cdc:	e5bfc0ef          	jal	80001b36 <proc_freepagetable>
  if(ip){
    80004ce0:	79fe                	ld	s3,504(sp)
    80004ce2:	7abe                	ld	s5,488(sp)
    80004ce4:	7b1e                	ld	s6,480(sp)
    80004ce6:	6bfe                	ld	s7,472(sp)
    80004ce8:	6c5e                	ld	s8,464(sp)
    80004cea:	6cbe                	ld	s9,456(sp)
    80004cec:	6d1e                	ld	s10,448(sp)
    80004cee:	7dfa                	ld	s11,440(sp)
    80004cf0:	b32d                	j	80004a1a <kexec+0x64>
    80004cf2:	df243c23          	sd	s2,-520(s0)
    80004cf6:	b7c5                	j	80004cd6 <kexec+0x320>
    80004cf8:	df243c23          	sd	s2,-520(s0)
    80004cfc:	bfe9                	j	80004cd6 <kexec+0x320>
    80004cfe:	df243c23          	sd	s2,-520(s0)
    80004d02:	bfd1                	j	80004cd6 <kexec+0x320>
    80004d04:	df243c23          	sd	s2,-520(s0)
    80004d08:	b7f9                	j	80004cd6 <kexec+0x320>
  sz = sz1;
    80004d0a:	89d2                	mv	s3,s4
    80004d0c:	b541                	j	80004b8c <kexec+0x1d6>
    80004d0e:	89d2                	mv	s3,s4
    80004d10:	bdb5                	j	80004b8c <kexec+0x1d6>

0000000080004d12 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d12:	7179                	addi	sp,sp,-48
    80004d14:	f406                	sd	ra,40(sp)
    80004d16:	f022                	sd	s0,32(sp)
    80004d18:	ec26                	sd	s1,24(sp)
    80004d1a:	e84a                	sd	s2,16(sp)
    80004d1c:	1800                	addi	s0,sp,48
    80004d1e:	892e                	mv	s2,a1
    80004d20:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d22:	fdc40593          	addi	a1,s0,-36
    80004d26:	dd7fd0ef          	jal	80002afc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d2a:	fdc42703          	lw	a4,-36(s0)
    80004d2e:	47bd                	li	a5,15
    80004d30:	02e7ea63          	bltu	a5,a4,80004d64 <argfd+0x52>
    80004d34:	c75fc0ef          	jal	800019a8 <myproc>
    80004d38:	fdc42703          	lw	a4,-36(s0)
    80004d3c:	00371793          	slli	a5,a4,0x3
    80004d40:	0d078793          	addi	a5,a5,208
    80004d44:	953e                	add	a0,a0,a5
    80004d46:	611c                	ld	a5,0(a0)
    80004d48:	c385                	beqz	a5,80004d68 <argfd+0x56>
    return -1;
  if(pfd)
    80004d4a:	00090463          	beqz	s2,80004d52 <argfd+0x40>
    *pfd = fd;
    80004d4e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004d52:	4501                	li	a0,0
  if(pf)
    80004d54:	c091                	beqz	s1,80004d58 <argfd+0x46>
    *pf = f;
    80004d56:	e09c                	sd	a5,0(s1)
}
    80004d58:	70a2                	ld	ra,40(sp)
    80004d5a:	7402                	ld	s0,32(sp)
    80004d5c:	64e2                	ld	s1,24(sp)
    80004d5e:	6942                	ld	s2,16(sp)
    80004d60:	6145                	addi	sp,sp,48
    80004d62:	8082                	ret
    return -1;
    80004d64:	557d                	li	a0,-1
    80004d66:	bfcd                	j	80004d58 <argfd+0x46>
    80004d68:	557d                	li	a0,-1
    80004d6a:	b7fd                	j	80004d58 <argfd+0x46>

0000000080004d6c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d6c:	1101                	addi	sp,sp,-32
    80004d6e:	ec06                	sd	ra,24(sp)
    80004d70:	e822                	sd	s0,16(sp)
    80004d72:	e426                	sd	s1,8(sp)
    80004d74:	1000                	addi	s0,sp,32
    80004d76:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d78:	c31fc0ef          	jal	800019a8 <myproc>
    80004d7c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d7e:	0d050793          	addi	a5,a0,208
    80004d82:	4501                	li	a0,0
    80004d84:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d86:	6398                	ld	a4,0(a5)
    80004d88:	cb19                	beqz	a4,80004d9e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d8a:	2505                	addiw	a0,a0,1
    80004d8c:	07a1                	addi	a5,a5,8
    80004d8e:	fed51ce3          	bne	a0,a3,80004d86 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d92:	557d                	li	a0,-1
}
    80004d94:	60e2                	ld	ra,24(sp)
    80004d96:	6442                	ld	s0,16(sp)
    80004d98:	64a2                	ld	s1,8(sp)
    80004d9a:	6105                	addi	sp,sp,32
    80004d9c:	8082                	ret
      p->ofile[fd] = f;
    80004d9e:	00351793          	slli	a5,a0,0x3
    80004da2:	0d078793          	addi	a5,a5,208
    80004da6:	963e                	add	a2,a2,a5
    80004da8:	e204                	sd	s1,0(a2)
      return fd;
    80004daa:	b7ed                	j	80004d94 <fdalloc+0x28>

0000000080004dac <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004dac:	715d                	addi	sp,sp,-80
    80004dae:	e486                	sd	ra,72(sp)
    80004db0:	e0a2                	sd	s0,64(sp)
    80004db2:	fc26                	sd	s1,56(sp)
    80004db4:	f84a                	sd	s2,48(sp)
    80004db6:	f44e                	sd	s3,40(sp)
    80004db8:	f052                	sd	s4,32(sp)
    80004dba:	ec56                	sd	s5,24(sp)
    80004dbc:	e85a                	sd	s6,16(sp)
    80004dbe:	0880                	addi	s0,sp,80
    80004dc0:	892e                	mv	s2,a1
    80004dc2:	8a2e                	mv	s4,a1
    80004dc4:	8ab2                	mv	s5,a2
    80004dc6:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004dc8:	fb040593          	addi	a1,s0,-80
    80004dcc:	fb7fe0ef          	jal	80003d82 <nameiparent>
    80004dd0:	84aa                	mv	s1,a0
    80004dd2:	10050763          	beqz	a0,80004ee0 <create+0x134>
    return 0;

  ilock(dp);
    80004dd6:	f64fe0ef          	jal	8000353a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004dda:	4601                	li	a2,0
    80004ddc:	fb040593          	addi	a1,s0,-80
    80004de0:	8526                	mv	a0,s1
    80004de2:	cf3fe0ef          	jal	80003ad4 <dirlookup>
    80004de6:	89aa                	mv	s3,a0
    80004de8:	c131                	beqz	a0,80004e2c <create+0x80>
    iunlockput(dp);
    80004dea:	8526                	mv	a0,s1
    80004dec:	95bfe0ef          	jal	80003746 <iunlockput>
    ilock(ip);
    80004df0:	854e                	mv	a0,s3
    80004df2:	f48fe0ef          	jal	8000353a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004df6:	4789                	li	a5,2
    80004df8:	02f91563          	bne	s2,a5,80004e22 <create+0x76>
    80004dfc:	0449d783          	lhu	a5,68(s3)
    80004e00:	37f9                	addiw	a5,a5,-2
    80004e02:	17c2                	slli	a5,a5,0x30
    80004e04:	93c1                	srli	a5,a5,0x30
    80004e06:	4705                	li	a4,1
    80004e08:	00f76d63          	bltu	a4,a5,80004e22 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e0c:	854e                	mv	a0,s3
    80004e0e:	60a6                	ld	ra,72(sp)
    80004e10:	6406                	ld	s0,64(sp)
    80004e12:	74e2                	ld	s1,56(sp)
    80004e14:	7942                	ld	s2,48(sp)
    80004e16:	79a2                	ld	s3,40(sp)
    80004e18:	7a02                	ld	s4,32(sp)
    80004e1a:	6ae2                	ld	s5,24(sp)
    80004e1c:	6b42                	ld	s6,16(sp)
    80004e1e:	6161                	addi	sp,sp,80
    80004e20:	8082                	ret
    iunlockput(ip);
    80004e22:	854e                	mv	a0,s3
    80004e24:	923fe0ef          	jal	80003746 <iunlockput>
    return 0;
    80004e28:	4981                	li	s3,0
    80004e2a:	b7cd                	j	80004e0c <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e2c:	85ca                	mv	a1,s2
    80004e2e:	4088                	lw	a0,0(s1)
    80004e30:	d9afe0ef          	jal	800033ca <ialloc>
    80004e34:	892a                	mv	s2,a0
    80004e36:	cd15                	beqz	a0,80004e72 <create+0xc6>
  ilock(ip);
    80004e38:	f02fe0ef          	jal	8000353a <ilock>
  ip->major = major;
    80004e3c:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004e40:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004e44:	4785                	li	a5,1
    80004e46:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e4a:	854a                	mv	a0,s2
    80004e4c:	e3afe0ef          	jal	80003486 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004e50:	4705                	li	a4,1
    80004e52:	02ea0463          	beq	s4,a4,80004e7a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e56:	00492603          	lw	a2,4(s2)
    80004e5a:	fb040593          	addi	a1,s0,-80
    80004e5e:	8526                	mv	a0,s1
    80004e60:	e5ffe0ef          	jal	80003cbe <dirlink>
    80004e64:	06054263          	bltz	a0,80004ec8 <create+0x11c>
  iunlockput(dp);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	8ddfe0ef          	jal	80003746 <iunlockput>
  return ip;
    80004e6e:	89ca                	mv	s3,s2
    80004e70:	bf71                	j	80004e0c <create+0x60>
    iunlockput(dp);
    80004e72:	8526                	mv	a0,s1
    80004e74:	8d3fe0ef          	jal	80003746 <iunlockput>
    return 0;
    80004e78:	bf51                	j	80004e0c <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e7a:	00492603          	lw	a2,4(s2)
    80004e7e:	00002597          	auipc	a1,0x2
    80004e82:	74a58593          	addi	a1,a1,1866 # 800075c8 <etext+0x5c8>
    80004e86:	854a                	mv	a0,s2
    80004e88:	e37fe0ef          	jal	80003cbe <dirlink>
    80004e8c:	02054e63          	bltz	a0,80004ec8 <create+0x11c>
    80004e90:	40d0                	lw	a2,4(s1)
    80004e92:	00002597          	auipc	a1,0x2
    80004e96:	73e58593          	addi	a1,a1,1854 # 800075d0 <etext+0x5d0>
    80004e9a:	854a                	mv	a0,s2
    80004e9c:	e23fe0ef          	jal	80003cbe <dirlink>
    80004ea0:	02054463          	bltz	a0,80004ec8 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ea4:	00492603          	lw	a2,4(s2)
    80004ea8:	fb040593          	addi	a1,s0,-80
    80004eac:	8526                	mv	a0,s1
    80004eae:	e11fe0ef          	jal	80003cbe <dirlink>
    80004eb2:	00054b63          	bltz	a0,80004ec8 <create+0x11c>
    dp->nlink++;  // for ".."
    80004eb6:	04a4d783          	lhu	a5,74(s1)
    80004eba:	2785                	addiw	a5,a5,1
    80004ebc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	dc4fe0ef          	jal	80003486 <iupdate>
    80004ec6:	b74d                	j	80004e68 <create+0xbc>
  ip->nlink = 0;
    80004ec8:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004ecc:	854a                	mv	a0,s2
    80004ece:	db8fe0ef          	jal	80003486 <iupdate>
  iunlockput(ip);
    80004ed2:	854a                	mv	a0,s2
    80004ed4:	873fe0ef          	jal	80003746 <iunlockput>
  iunlockput(dp);
    80004ed8:	8526                	mv	a0,s1
    80004eda:	86dfe0ef          	jal	80003746 <iunlockput>
  return 0;
    80004ede:	b73d                	j	80004e0c <create+0x60>
    return 0;
    80004ee0:	89aa                	mv	s3,a0
    80004ee2:	b72d                	j	80004e0c <create+0x60>

0000000080004ee4 <sys_dup>:
{
    80004ee4:	7179                	addi	sp,sp,-48
    80004ee6:	f406                	sd	ra,40(sp)
    80004ee8:	f022                	sd	s0,32(sp)
    80004eea:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004eec:	fd840613          	addi	a2,s0,-40
    80004ef0:	4581                	li	a1,0
    80004ef2:	4501                	li	a0,0
    80004ef4:	e1fff0ef          	jal	80004d12 <argfd>
    return -1;
    80004ef8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004efa:	02054363          	bltz	a0,80004f20 <sys_dup+0x3c>
    80004efe:	ec26                	sd	s1,24(sp)
    80004f00:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004f02:	fd843483          	ld	s1,-40(s0)
    80004f06:	8526                	mv	a0,s1
    80004f08:	e65ff0ef          	jal	80004d6c <fdalloc>
    80004f0c:	892a                	mv	s2,a0
    return -1;
    80004f0e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004f10:	00054d63          	bltz	a0,80004f2a <sys_dup+0x46>
  filedup(f);
    80004f14:	8526                	mv	a0,s1
    80004f16:	c0eff0ef          	jal	80004324 <filedup>
  return fd;
    80004f1a:	87ca                	mv	a5,s2
    80004f1c:	64e2                	ld	s1,24(sp)
    80004f1e:	6942                	ld	s2,16(sp)
}
    80004f20:	853e                	mv	a0,a5
    80004f22:	70a2                	ld	ra,40(sp)
    80004f24:	7402                	ld	s0,32(sp)
    80004f26:	6145                	addi	sp,sp,48
    80004f28:	8082                	ret
    80004f2a:	64e2                	ld	s1,24(sp)
    80004f2c:	6942                	ld	s2,16(sp)
    80004f2e:	bfcd                	j	80004f20 <sys_dup+0x3c>

0000000080004f30 <sys_read>:
{
    80004f30:	7179                	addi	sp,sp,-48
    80004f32:	f406                	sd	ra,40(sp)
    80004f34:	f022                	sd	s0,32(sp)
    80004f36:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f38:	fd840593          	addi	a1,s0,-40
    80004f3c:	4505                	li	a0,1
    80004f3e:	bdbfd0ef          	jal	80002b18 <argaddr>
  argint(2, &n);
    80004f42:	fe440593          	addi	a1,s0,-28
    80004f46:	4509                	li	a0,2
    80004f48:	bb5fd0ef          	jal	80002afc <argint>
  if(argfd(0, 0, &f) < 0)
    80004f4c:	fe840613          	addi	a2,s0,-24
    80004f50:	4581                	li	a1,0
    80004f52:	4501                	li	a0,0
    80004f54:	dbfff0ef          	jal	80004d12 <argfd>
    80004f58:	87aa                	mv	a5,a0
    return -1;
    80004f5a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f5c:	0007ca63          	bltz	a5,80004f70 <sys_read+0x40>
  return fileread(f, p, n);
    80004f60:	fe442603          	lw	a2,-28(s0)
    80004f64:	fd843583          	ld	a1,-40(s0)
    80004f68:	fe843503          	ld	a0,-24(s0)
    80004f6c:	d22ff0ef          	jal	8000448e <fileread>
}
    80004f70:	70a2                	ld	ra,40(sp)
    80004f72:	7402                	ld	s0,32(sp)
    80004f74:	6145                	addi	sp,sp,48
    80004f76:	8082                	ret

0000000080004f78 <sys_write>:
{
    80004f78:	7179                	addi	sp,sp,-48
    80004f7a:	f406                	sd	ra,40(sp)
    80004f7c:	f022                	sd	s0,32(sp)
    80004f7e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f80:	fd840593          	addi	a1,s0,-40
    80004f84:	4505                	li	a0,1
    80004f86:	b93fd0ef          	jal	80002b18 <argaddr>
  argint(2, &n);
    80004f8a:	fe440593          	addi	a1,s0,-28
    80004f8e:	4509                	li	a0,2
    80004f90:	b6dfd0ef          	jal	80002afc <argint>
  if(argfd(0, 0, &f) < 0)
    80004f94:	fe840613          	addi	a2,s0,-24
    80004f98:	4581                	li	a1,0
    80004f9a:	4501                	li	a0,0
    80004f9c:	d77ff0ef          	jal	80004d12 <argfd>
    80004fa0:	87aa                	mv	a5,a0
    return -1;
    80004fa2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fa4:	0007ca63          	bltz	a5,80004fb8 <sys_write+0x40>
  return filewrite(f, p, n);
    80004fa8:	fe442603          	lw	a2,-28(s0)
    80004fac:	fd843583          	ld	a1,-40(s0)
    80004fb0:	fe843503          	ld	a0,-24(s0)
    80004fb4:	d9eff0ef          	jal	80004552 <filewrite>
}
    80004fb8:	70a2                	ld	ra,40(sp)
    80004fba:	7402                	ld	s0,32(sp)
    80004fbc:	6145                	addi	sp,sp,48
    80004fbe:	8082                	ret

0000000080004fc0 <sys_close>:
{
    80004fc0:	1101                	addi	sp,sp,-32
    80004fc2:	ec06                	sd	ra,24(sp)
    80004fc4:	e822                	sd	s0,16(sp)
    80004fc6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004fc8:	fe040613          	addi	a2,s0,-32
    80004fcc:	fec40593          	addi	a1,s0,-20
    80004fd0:	4501                	li	a0,0
    80004fd2:	d41ff0ef          	jal	80004d12 <argfd>
    return -1;
    80004fd6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004fd8:	02054163          	bltz	a0,80004ffa <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004fdc:	9cdfc0ef          	jal	800019a8 <myproc>
    80004fe0:	fec42783          	lw	a5,-20(s0)
    80004fe4:	078e                	slli	a5,a5,0x3
    80004fe6:	0d078793          	addi	a5,a5,208
    80004fea:	953e                	add	a0,a0,a5
    80004fec:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ff0:	fe043503          	ld	a0,-32(s0)
    80004ff4:	b76ff0ef          	jal	8000436a <fileclose>
  return 0;
    80004ff8:	4781                	li	a5,0
}
    80004ffa:	853e                	mv	a0,a5
    80004ffc:	60e2                	ld	ra,24(sp)
    80004ffe:	6442                	ld	s0,16(sp)
    80005000:	6105                	addi	sp,sp,32
    80005002:	8082                	ret

0000000080005004 <sys_fstat>:
{
    80005004:	1101                	addi	sp,sp,-32
    80005006:	ec06                	sd	ra,24(sp)
    80005008:	e822                	sd	s0,16(sp)
    8000500a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000500c:	fe040593          	addi	a1,s0,-32
    80005010:	4505                	li	a0,1
    80005012:	b07fd0ef          	jal	80002b18 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005016:	fe840613          	addi	a2,s0,-24
    8000501a:	4581                	li	a1,0
    8000501c:	4501                	li	a0,0
    8000501e:	cf5ff0ef          	jal	80004d12 <argfd>
    80005022:	87aa                	mv	a5,a0
    return -1;
    80005024:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005026:	0007c863          	bltz	a5,80005036 <sys_fstat+0x32>
  return filestat(f, st);
    8000502a:	fe043583          	ld	a1,-32(s0)
    8000502e:	fe843503          	ld	a0,-24(s0)
    80005032:	bfaff0ef          	jal	8000442c <filestat>
}
    80005036:	60e2                	ld	ra,24(sp)
    80005038:	6442                	ld	s0,16(sp)
    8000503a:	6105                	addi	sp,sp,32
    8000503c:	8082                	ret

000000008000503e <sys_link>:
{
    8000503e:	7169                	addi	sp,sp,-304
    80005040:	f606                	sd	ra,296(sp)
    80005042:	f222                	sd	s0,288(sp)
    80005044:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005046:	08000613          	li	a2,128
    8000504a:	ed040593          	addi	a1,s0,-304
    8000504e:	4501                	li	a0,0
    80005050:	ae5fd0ef          	jal	80002b34 <argstr>
    return -1;
    80005054:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005056:	0c054e63          	bltz	a0,80005132 <sys_link+0xf4>
    8000505a:	08000613          	li	a2,128
    8000505e:	f5040593          	addi	a1,s0,-176
    80005062:	4505                	li	a0,1
    80005064:	ad1fd0ef          	jal	80002b34 <argstr>
    return -1;
    80005068:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000506a:	0c054463          	bltz	a0,80005132 <sys_link+0xf4>
    8000506e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005070:	ed7fe0ef          	jal	80003f46 <begin_op>
  if((ip = namei(old)) == 0){
    80005074:	ed040513          	addi	a0,s0,-304
    80005078:	cf1fe0ef          	jal	80003d68 <namei>
    8000507c:	84aa                	mv	s1,a0
    8000507e:	c53d                	beqz	a0,800050ec <sys_link+0xae>
  ilock(ip);
    80005080:	cbafe0ef          	jal	8000353a <ilock>
  if(ip->type == T_DIR){
    80005084:	04449703          	lh	a4,68(s1)
    80005088:	4785                	li	a5,1
    8000508a:	06f70663          	beq	a4,a5,800050f6 <sys_link+0xb8>
    8000508e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005090:	04a4d783          	lhu	a5,74(s1)
    80005094:	2785                	addiw	a5,a5,1
    80005096:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000509a:	8526                	mv	a0,s1
    8000509c:	beafe0ef          	jal	80003486 <iupdate>
  iunlock(ip);
    800050a0:	8526                	mv	a0,s1
    800050a2:	d46fe0ef          	jal	800035e8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800050a6:	fd040593          	addi	a1,s0,-48
    800050aa:	f5040513          	addi	a0,s0,-176
    800050ae:	cd5fe0ef          	jal	80003d82 <nameiparent>
    800050b2:	892a                	mv	s2,a0
    800050b4:	cd21                	beqz	a0,8000510c <sys_link+0xce>
  ilock(dp);
    800050b6:	c84fe0ef          	jal	8000353a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800050ba:	854a                	mv	a0,s2
    800050bc:	00092703          	lw	a4,0(s2)
    800050c0:	409c                	lw	a5,0(s1)
    800050c2:	04f71263          	bne	a4,a5,80005106 <sys_link+0xc8>
    800050c6:	40d0                	lw	a2,4(s1)
    800050c8:	fd040593          	addi	a1,s0,-48
    800050cc:	bf3fe0ef          	jal	80003cbe <dirlink>
    800050d0:	02054b63          	bltz	a0,80005106 <sys_link+0xc8>
  iunlockput(dp);
    800050d4:	854a                	mv	a0,s2
    800050d6:	e70fe0ef          	jal	80003746 <iunlockput>
  iput(ip);
    800050da:	8526                	mv	a0,s1
    800050dc:	de0fe0ef          	jal	800036bc <iput>
  end_op();
    800050e0:	ed7fe0ef          	jal	80003fb6 <end_op>
  return 0;
    800050e4:	4781                	li	a5,0
    800050e6:	64f2                	ld	s1,280(sp)
    800050e8:	6952                	ld	s2,272(sp)
    800050ea:	a0a1                	j	80005132 <sys_link+0xf4>
    end_op();
    800050ec:	ecbfe0ef          	jal	80003fb6 <end_op>
    return -1;
    800050f0:	57fd                	li	a5,-1
    800050f2:	64f2                	ld	s1,280(sp)
    800050f4:	a83d                	j	80005132 <sys_link+0xf4>
    iunlockput(ip);
    800050f6:	8526                	mv	a0,s1
    800050f8:	e4efe0ef          	jal	80003746 <iunlockput>
    end_op();
    800050fc:	ebbfe0ef          	jal	80003fb6 <end_op>
    return -1;
    80005100:	57fd                	li	a5,-1
    80005102:	64f2                	ld	s1,280(sp)
    80005104:	a03d                	j	80005132 <sys_link+0xf4>
    iunlockput(dp);
    80005106:	854a                	mv	a0,s2
    80005108:	e3efe0ef          	jal	80003746 <iunlockput>
  ilock(ip);
    8000510c:	8526                	mv	a0,s1
    8000510e:	c2cfe0ef          	jal	8000353a <ilock>
  ip->nlink--;
    80005112:	04a4d783          	lhu	a5,74(s1)
    80005116:	37fd                	addiw	a5,a5,-1
    80005118:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000511c:	8526                	mv	a0,s1
    8000511e:	b68fe0ef          	jal	80003486 <iupdate>
  iunlockput(ip);
    80005122:	8526                	mv	a0,s1
    80005124:	e22fe0ef          	jal	80003746 <iunlockput>
  end_op();
    80005128:	e8ffe0ef          	jal	80003fb6 <end_op>
  return -1;
    8000512c:	57fd                	li	a5,-1
    8000512e:	64f2                	ld	s1,280(sp)
    80005130:	6952                	ld	s2,272(sp)
}
    80005132:	853e                	mv	a0,a5
    80005134:	70b2                	ld	ra,296(sp)
    80005136:	7412                	ld	s0,288(sp)
    80005138:	6155                	addi	sp,sp,304
    8000513a:	8082                	ret

000000008000513c <sys_unlink>:
{
    8000513c:	7151                	addi	sp,sp,-240
    8000513e:	f586                	sd	ra,232(sp)
    80005140:	f1a2                	sd	s0,224(sp)
    80005142:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005144:	08000613          	li	a2,128
    80005148:	f3040593          	addi	a1,s0,-208
    8000514c:	4501                	li	a0,0
    8000514e:	9e7fd0ef          	jal	80002b34 <argstr>
    80005152:	14054d63          	bltz	a0,800052ac <sys_unlink+0x170>
    80005156:	eda6                	sd	s1,216(sp)
  begin_op();
    80005158:	deffe0ef          	jal	80003f46 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000515c:	fb040593          	addi	a1,s0,-80
    80005160:	f3040513          	addi	a0,s0,-208
    80005164:	c1ffe0ef          	jal	80003d82 <nameiparent>
    80005168:	84aa                	mv	s1,a0
    8000516a:	c955                	beqz	a0,8000521e <sys_unlink+0xe2>
  ilock(dp);
    8000516c:	bcefe0ef          	jal	8000353a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005170:	00002597          	auipc	a1,0x2
    80005174:	45858593          	addi	a1,a1,1112 # 800075c8 <etext+0x5c8>
    80005178:	fb040513          	addi	a0,s0,-80
    8000517c:	943fe0ef          	jal	80003abe <namecmp>
    80005180:	10050b63          	beqz	a0,80005296 <sys_unlink+0x15a>
    80005184:	00002597          	auipc	a1,0x2
    80005188:	44c58593          	addi	a1,a1,1100 # 800075d0 <etext+0x5d0>
    8000518c:	fb040513          	addi	a0,s0,-80
    80005190:	92ffe0ef          	jal	80003abe <namecmp>
    80005194:	10050163          	beqz	a0,80005296 <sys_unlink+0x15a>
    80005198:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000519a:	f2c40613          	addi	a2,s0,-212
    8000519e:	fb040593          	addi	a1,s0,-80
    800051a2:	8526                	mv	a0,s1
    800051a4:	931fe0ef          	jal	80003ad4 <dirlookup>
    800051a8:	892a                	mv	s2,a0
    800051aa:	0e050563          	beqz	a0,80005294 <sys_unlink+0x158>
    800051ae:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800051b0:	b8afe0ef          	jal	8000353a <ilock>
  if(ip->nlink < 1)
    800051b4:	04a91783          	lh	a5,74(s2)
    800051b8:	06f05863          	blez	a5,80005228 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800051bc:	04491703          	lh	a4,68(s2)
    800051c0:	4785                	li	a5,1
    800051c2:	06f70963          	beq	a4,a5,80005234 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800051c6:	fc040993          	addi	s3,s0,-64
    800051ca:	4641                	li	a2,16
    800051cc:	4581                	li	a1,0
    800051ce:	854e                	mv	a0,s3
    800051d0:	b29fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051d4:	4741                	li	a4,16
    800051d6:	f2c42683          	lw	a3,-212(s0)
    800051da:	864e                	mv	a2,s3
    800051dc:	4581                	li	a1,0
    800051de:	8526                	mv	a0,s1
    800051e0:	fdefe0ef          	jal	800039be <writei>
    800051e4:	47c1                	li	a5,16
    800051e6:	08f51863          	bne	a0,a5,80005276 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800051ea:	04491703          	lh	a4,68(s2)
    800051ee:	4785                	li	a5,1
    800051f0:	08f70963          	beq	a4,a5,80005282 <sys_unlink+0x146>
  iunlockput(dp);
    800051f4:	8526                	mv	a0,s1
    800051f6:	d50fe0ef          	jal	80003746 <iunlockput>
  ip->nlink--;
    800051fa:	04a95783          	lhu	a5,74(s2)
    800051fe:	37fd                	addiw	a5,a5,-1
    80005200:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005204:	854a                	mv	a0,s2
    80005206:	a80fe0ef          	jal	80003486 <iupdate>
  iunlockput(ip);
    8000520a:	854a                	mv	a0,s2
    8000520c:	d3afe0ef          	jal	80003746 <iunlockput>
  end_op();
    80005210:	da7fe0ef          	jal	80003fb6 <end_op>
  return 0;
    80005214:	4501                	li	a0,0
    80005216:	64ee                	ld	s1,216(sp)
    80005218:	694e                	ld	s2,208(sp)
    8000521a:	69ae                	ld	s3,200(sp)
    8000521c:	a061                	j	800052a4 <sys_unlink+0x168>
    end_op();
    8000521e:	d99fe0ef          	jal	80003fb6 <end_op>
    return -1;
    80005222:	557d                	li	a0,-1
    80005224:	64ee                	ld	s1,216(sp)
    80005226:	a8bd                	j	800052a4 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005228:	00002517          	auipc	a0,0x2
    8000522c:	3b050513          	addi	a0,a0,944 # 800075d8 <etext+0x5d8>
    80005230:	df4fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005234:	04c92703          	lw	a4,76(s2)
    80005238:	02000793          	li	a5,32
    8000523c:	f8e7f5e3          	bgeu	a5,a4,800051c6 <sys_unlink+0x8a>
    80005240:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005242:	4741                	li	a4,16
    80005244:	86ce                	mv	a3,s3
    80005246:	f1840613          	addi	a2,s0,-232
    8000524a:	4581                	li	a1,0
    8000524c:	854a                	mv	a0,s2
    8000524e:	e7efe0ef          	jal	800038cc <readi>
    80005252:	47c1                	li	a5,16
    80005254:	00f51b63          	bne	a0,a5,8000526a <sys_unlink+0x12e>
    if(de.inum != 0)
    80005258:	f1845783          	lhu	a5,-232(s0)
    8000525c:	ebb1                	bnez	a5,800052b0 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000525e:	29c1                	addiw	s3,s3,16
    80005260:	04c92783          	lw	a5,76(s2)
    80005264:	fcf9efe3          	bltu	s3,a5,80005242 <sys_unlink+0x106>
    80005268:	bfb9                	j	800051c6 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000526a:	00002517          	auipc	a0,0x2
    8000526e:	38650513          	addi	a0,a0,902 # 800075f0 <etext+0x5f0>
    80005272:	db2fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005276:	00002517          	auipc	a0,0x2
    8000527a:	39250513          	addi	a0,a0,914 # 80007608 <etext+0x608>
    8000527e:	da6fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005282:	04a4d783          	lhu	a5,74(s1)
    80005286:	37fd                	addiw	a5,a5,-1
    80005288:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000528c:	8526                	mv	a0,s1
    8000528e:	9f8fe0ef          	jal	80003486 <iupdate>
    80005292:	b78d                	j	800051f4 <sys_unlink+0xb8>
    80005294:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005296:	8526                	mv	a0,s1
    80005298:	caefe0ef          	jal	80003746 <iunlockput>
  end_op();
    8000529c:	d1bfe0ef          	jal	80003fb6 <end_op>
  return -1;
    800052a0:	557d                	li	a0,-1
    800052a2:	64ee                	ld	s1,216(sp)
}
    800052a4:	70ae                	ld	ra,232(sp)
    800052a6:	740e                	ld	s0,224(sp)
    800052a8:	616d                	addi	sp,sp,240
    800052aa:	8082                	ret
    return -1;
    800052ac:	557d                	li	a0,-1
    800052ae:	bfdd                	j	800052a4 <sys_unlink+0x168>
    iunlockput(ip);
    800052b0:	854a                	mv	a0,s2
    800052b2:	c94fe0ef          	jal	80003746 <iunlockput>
    goto bad;
    800052b6:	694e                	ld	s2,208(sp)
    800052b8:	69ae                	ld	s3,200(sp)
    800052ba:	bff1                	j	80005296 <sys_unlink+0x15a>

00000000800052bc <sys_open>:

uint64
sys_open(void)
{
    800052bc:	7131                	addi	sp,sp,-192
    800052be:	fd06                	sd	ra,184(sp)
    800052c0:	f922                	sd	s0,176(sp)
    800052c2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800052c4:	f4c40593          	addi	a1,s0,-180
    800052c8:	4505                	li	a0,1
    800052ca:	833fd0ef          	jal	80002afc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800052ce:	08000613          	li	a2,128
    800052d2:	f5040593          	addi	a1,s0,-176
    800052d6:	4501                	li	a0,0
    800052d8:	85dfd0ef          	jal	80002b34 <argstr>
    800052dc:	87aa                	mv	a5,a0
    return -1;
    800052de:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800052e0:	0a07c363          	bltz	a5,80005386 <sys_open+0xca>
    800052e4:	f526                	sd	s1,168(sp)

  begin_op();
    800052e6:	c61fe0ef          	jal	80003f46 <begin_op>

  if(omode & O_CREATE){
    800052ea:	f4c42783          	lw	a5,-180(s0)
    800052ee:	2007f793          	andi	a5,a5,512
    800052f2:	c3dd                	beqz	a5,80005398 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800052f4:	4681                	li	a3,0
    800052f6:	4601                	li	a2,0
    800052f8:	4589                	li	a1,2
    800052fa:	f5040513          	addi	a0,s0,-176
    800052fe:	aafff0ef          	jal	80004dac <create>
    80005302:	84aa                	mv	s1,a0
    if(ip == 0){
    80005304:	c549                	beqz	a0,8000538e <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005306:	04449703          	lh	a4,68(s1)
    8000530a:	478d                	li	a5,3
    8000530c:	00f71763          	bne	a4,a5,8000531a <sys_open+0x5e>
    80005310:	0464d703          	lhu	a4,70(s1)
    80005314:	47a5                	li	a5,9
    80005316:	0ae7ee63          	bltu	a5,a4,800053d2 <sys_open+0x116>
    8000531a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000531c:	fabfe0ef          	jal	800042c6 <filealloc>
    80005320:	892a                	mv	s2,a0
    80005322:	c561                	beqz	a0,800053ea <sys_open+0x12e>
    80005324:	ed4e                	sd	s3,152(sp)
    80005326:	a47ff0ef          	jal	80004d6c <fdalloc>
    8000532a:	89aa                	mv	s3,a0
    8000532c:	0a054b63          	bltz	a0,800053e2 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005330:	04449703          	lh	a4,68(s1)
    80005334:	478d                	li	a5,3
    80005336:	0cf70363          	beq	a4,a5,800053fc <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000533a:	4789                	li	a5,2
    8000533c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005340:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005344:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005348:	f4c42783          	lw	a5,-180(s0)
    8000534c:	0017f713          	andi	a4,a5,1
    80005350:	00174713          	xori	a4,a4,1
    80005354:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005358:	0037f713          	andi	a4,a5,3
    8000535c:	00e03733          	snez	a4,a4
    80005360:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005364:	4007f793          	andi	a5,a5,1024
    80005368:	c791                	beqz	a5,80005374 <sys_open+0xb8>
    8000536a:	04449703          	lh	a4,68(s1)
    8000536e:	4789                	li	a5,2
    80005370:	08f70d63          	beq	a4,a5,8000540a <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005374:	8526                	mv	a0,s1
    80005376:	a72fe0ef          	jal	800035e8 <iunlock>
  end_op();
    8000537a:	c3dfe0ef          	jal	80003fb6 <end_op>

  return fd;
    8000537e:	854e                	mv	a0,s3
    80005380:	74aa                	ld	s1,168(sp)
    80005382:	790a                	ld	s2,160(sp)
    80005384:	69ea                	ld	s3,152(sp)
}
    80005386:	70ea                	ld	ra,184(sp)
    80005388:	744a                	ld	s0,176(sp)
    8000538a:	6129                	addi	sp,sp,192
    8000538c:	8082                	ret
      end_op();
    8000538e:	c29fe0ef          	jal	80003fb6 <end_op>
      return -1;
    80005392:	557d                	li	a0,-1
    80005394:	74aa                	ld	s1,168(sp)
    80005396:	bfc5                	j	80005386 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005398:	f5040513          	addi	a0,s0,-176
    8000539c:	9cdfe0ef          	jal	80003d68 <namei>
    800053a0:	84aa                	mv	s1,a0
    800053a2:	c11d                	beqz	a0,800053c8 <sys_open+0x10c>
    ilock(ip);
    800053a4:	996fe0ef          	jal	8000353a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800053a8:	04449703          	lh	a4,68(s1)
    800053ac:	4785                	li	a5,1
    800053ae:	f4f71ce3          	bne	a4,a5,80005306 <sys_open+0x4a>
    800053b2:	f4c42783          	lw	a5,-180(s0)
    800053b6:	d3b5                	beqz	a5,8000531a <sys_open+0x5e>
      iunlockput(ip);
    800053b8:	8526                	mv	a0,s1
    800053ba:	b8cfe0ef          	jal	80003746 <iunlockput>
      end_op();
    800053be:	bf9fe0ef          	jal	80003fb6 <end_op>
      return -1;
    800053c2:	557d                	li	a0,-1
    800053c4:	74aa                	ld	s1,168(sp)
    800053c6:	b7c1                	j	80005386 <sys_open+0xca>
      end_op();
    800053c8:	beffe0ef          	jal	80003fb6 <end_op>
      return -1;
    800053cc:	557d                	li	a0,-1
    800053ce:	74aa                	ld	s1,168(sp)
    800053d0:	bf5d                	j	80005386 <sys_open+0xca>
    iunlockput(ip);
    800053d2:	8526                	mv	a0,s1
    800053d4:	b72fe0ef          	jal	80003746 <iunlockput>
    end_op();
    800053d8:	bdffe0ef          	jal	80003fb6 <end_op>
    return -1;
    800053dc:	557d                	li	a0,-1
    800053de:	74aa                	ld	s1,168(sp)
    800053e0:	b75d                	j	80005386 <sys_open+0xca>
      fileclose(f);
    800053e2:	854a                	mv	a0,s2
    800053e4:	f87fe0ef          	jal	8000436a <fileclose>
    800053e8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800053ea:	8526                	mv	a0,s1
    800053ec:	b5afe0ef          	jal	80003746 <iunlockput>
    end_op();
    800053f0:	bc7fe0ef          	jal	80003fb6 <end_op>
    return -1;
    800053f4:	557d                	li	a0,-1
    800053f6:	74aa                	ld	s1,168(sp)
    800053f8:	790a                	ld	s2,160(sp)
    800053fa:	b771                	j	80005386 <sys_open+0xca>
    f->type = FD_DEVICE;
    800053fc:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005400:	04649783          	lh	a5,70(s1)
    80005404:	02f91223          	sh	a5,36(s2)
    80005408:	bf35                	j	80005344 <sys_open+0x88>
    itrunc(ip);
    8000540a:	8526                	mv	a0,s1
    8000540c:	a1cfe0ef          	jal	80003628 <itrunc>
    80005410:	b795                	j	80005374 <sys_open+0xb8>

0000000080005412 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005412:	7175                	addi	sp,sp,-144
    80005414:	e506                	sd	ra,136(sp)
    80005416:	e122                	sd	s0,128(sp)
    80005418:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000541a:	b2dfe0ef          	jal	80003f46 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000541e:	08000613          	li	a2,128
    80005422:	f7040593          	addi	a1,s0,-144
    80005426:	4501                	li	a0,0
    80005428:	f0cfd0ef          	jal	80002b34 <argstr>
    8000542c:	02054363          	bltz	a0,80005452 <sys_mkdir+0x40>
    80005430:	4681                	li	a3,0
    80005432:	4601                	li	a2,0
    80005434:	4585                	li	a1,1
    80005436:	f7040513          	addi	a0,s0,-144
    8000543a:	973ff0ef          	jal	80004dac <create>
    8000543e:	c911                	beqz	a0,80005452 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005440:	b06fe0ef          	jal	80003746 <iunlockput>
  end_op();
    80005444:	b73fe0ef          	jal	80003fb6 <end_op>
  return 0;
    80005448:	4501                	li	a0,0
}
    8000544a:	60aa                	ld	ra,136(sp)
    8000544c:	640a                	ld	s0,128(sp)
    8000544e:	6149                	addi	sp,sp,144
    80005450:	8082                	ret
    end_op();
    80005452:	b65fe0ef          	jal	80003fb6 <end_op>
    return -1;
    80005456:	557d                	li	a0,-1
    80005458:	bfcd                	j	8000544a <sys_mkdir+0x38>

000000008000545a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000545a:	7135                	addi	sp,sp,-160
    8000545c:	ed06                	sd	ra,152(sp)
    8000545e:	e922                	sd	s0,144(sp)
    80005460:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005462:	ae5fe0ef          	jal	80003f46 <begin_op>
  argint(1, &major);
    80005466:	f6c40593          	addi	a1,s0,-148
    8000546a:	4505                	li	a0,1
    8000546c:	e90fd0ef          	jal	80002afc <argint>
  argint(2, &minor);
    80005470:	f6840593          	addi	a1,s0,-152
    80005474:	4509                	li	a0,2
    80005476:	e86fd0ef          	jal	80002afc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000547a:	08000613          	li	a2,128
    8000547e:	f7040593          	addi	a1,s0,-144
    80005482:	4501                	li	a0,0
    80005484:	eb0fd0ef          	jal	80002b34 <argstr>
    80005488:	02054563          	bltz	a0,800054b2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000548c:	f6841683          	lh	a3,-152(s0)
    80005490:	f6c41603          	lh	a2,-148(s0)
    80005494:	458d                	li	a1,3
    80005496:	f7040513          	addi	a0,s0,-144
    8000549a:	913ff0ef          	jal	80004dac <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000549e:	c911                	beqz	a0,800054b2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054a0:	aa6fe0ef          	jal	80003746 <iunlockput>
  end_op();
    800054a4:	b13fe0ef          	jal	80003fb6 <end_op>
  return 0;
    800054a8:	4501                	li	a0,0
}
    800054aa:	60ea                	ld	ra,152(sp)
    800054ac:	644a                	ld	s0,144(sp)
    800054ae:	610d                	addi	sp,sp,160
    800054b0:	8082                	ret
    end_op();
    800054b2:	b05fe0ef          	jal	80003fb6 <end_op>
    return -1;
    800054b6:	557d                	li	a0,-1
    800054b8:	bfcd                	j	800054aa <sys_mknod+0x50>

00000000800054ba <sys_chdir>:

uint64
sys_chdir(void)
{
    800054ba:	7135                	addi	sp,sp,-160
    800054bc:	ed06                	sd	ra,152(sp)
    800054be:	e922                	sd	s0,144(sp)
    800054c0:	e14a                	sd	s2,128(sp)
    800054c2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054c4:	ce4fc0ef          	jal	800019a8 <myproc>
    800054c8:	892a                	mv	s2,a0
  
  begin_op();
    800054ca:	a7dfe0ef          	jal	80003f46 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800054ce:	08000613          	li	a2,128
    800054d2:	f6040593          	addi	a1,s0,-160
    800054d6:	4501                	li	a0,0
    800054d8:	e5cfd0ef          	jal	80002b34 <argstr>
    800054dc:	04054363          	bltz	a0,80005522 <sys_chdir+0x68>
    800054e0:	e526                	sd	s1,136(sp)
    800054e2:	f6040513          	addi	a0,s0,-160
    800054e6:	883fe0ef          	jal	80003d68 <namei>
    800054ea:	84aa                	mv	s1,a0
    800054ec:	c915                	beqz	a0,80005520 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800054ee:	84cfe0ef          	jal	8000353a <ilock>
  if(ip->type != T_DIR){
    800054f2:	04449703          	lh	a4,68(s1)
    800054f6:	4785                	li	a5,1
    800054f8:	02f71963          	bne	a4,a5,8000552a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054fc:	8526                	mv	a0,s1
    800054fe:	8eafe0ef          	jal	800035e8 <iunlock>
  iput(p->cwd);
    80005502:	15093503          	ld	a0,336(s2)
    80005506:	9b6fe0ef          	jal	800036bc <iput>
  end_op();
    8000550a:	aadfe0ef          	jal	80003fb6 <end_op>
  p->cwd = ip;
    8000550e:	14993823          	sd	s1,336(s2)
  return 0;
    80005512:	4501                	li	a0,0
    80005514:	64aa                	ld	s1,136(sp)
}
    80005516:	60ea                	ld	ra,152(sp)
    80005518:	644a                	ld	s0,144(sp)
    8000551a:	690a                	ld	s2,128(sp)
    8000551c:	610d                	addi	sp,sp,160
    8000551e:	8082                	ret
    80005520:	64aa                	ld	s1,136(sp)
    end_op();
    80005522:	a95fe0ef          	jal	80003fb6 <end_op>
    return -1;
    80005526:	557d                	li	a0,-1
    80005528:	b7fd                	j	80005516 <sys_chdir+0x5c>
    iunlockput(ip);
    8000552a:	8526                	mv	a0,s1
    8000552c:	a1afe0ef          	jal	80003746 <iunlockput>
    end_op();
    80005530:	a87fe0ef          	jal	80003fb6 <end_op>
    return -1;
    80005534:	557d                	li	a0,-1
    80005536:	64aa                	ld	s1,136(sp)
    80005538:	bff9                	j	80005516 <sys_chdir+0x5c>

000000008000553a <sys_exec>:

uint64
sys_exec(void)
{
    8000553a:	7105                	addi	sp,sp,-480
    8000553c:	ef86                	sd	ra,472(sp)
    8000553e:	eba2                	sd	s0,464(sp)
    80005540:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005542:	e2840593          	addi	a1,s0,-472
    80005546:	4505                	li	a0,1
    80005548:	dd0fd0ef          	jal	80002b18 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000554c:	08000613          	li	a2,128
    80005550:	f3040593          	addi	a1,s0,-208
    80005554:	4501                	li	a0,0
    80005556:	ddefd0ef          	jal	80002b34 <argstr>
    8000555a:	87aa                	mv	a5,a0
    return -1;
    8000555c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000555e:	0e07c063          	bltz	a5,8000563e <sys_exec+0x104>
    80005562:	e7a6                	sd	s1,456(sp)
    80005564:	e3ca                	sd	s2,448(sp)
    80005566:	ff4e                	sd	s3,440(sp)
    80005568:	fb52                	sd	s4,432(sp)
    8000556a:	f756                	sd	s5,424(sp)
    8000556c:	f35a                	sd	s6,416(sp)
    8000556e:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005570:	e3040a13          	addi	s4,s0,-464
    80005574:	10000613          	li	a2,256
    80005578:	4581                	li	a1,0
    8000557a:	8552                	mv	a0,s4
    8000557c:	f7cfb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005580:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005582:	89d2                	mv	s3,s4
    80005584:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005586:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000558a:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000558c:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005590:	00391513          	slli	a0,s2,0x3
    80005594:	85d6                	mv	a1,s5
    80005596:	e2843783          	ld	a5,-472(s0)
    8000559a:	953e                	add	a0,a0,a5
    8000559c:	cd6fd0ef          	jal	80002a72 <fetchaddr>
    800055a0:	02054663          	bltz	a0,800055cc <sys_exec+0x92>
    if(uarg == 0){
    800055a4:	e2043783          	ld	a5,-480(s0)
    800055a8:	c7a1                	beqz	a5,800055f0 <sys_exec+0xb6>
    argv[i] = kalloc();
    800055aa:	d9afb0ef          	jal	80000b44 <kalloc>
    800055ae:	85aa                	mv	a1,a0
    800055b0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800055b4:	cd01                	beqz	a0,800055cc <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055b6:	865a                	mv	a2,s6
    800055b8:	e2043503          	ld	a0,-480(s0)
    800055bc:	d00fd0ef          	jal	80002abc <fetchstr>
    800055c0:	00054663          	bltz	a0,800055cc <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800055c4:	0905                	addi	s2,s2,1
    800055c6:	09a1                	addi	s3,s3,8
    800055c8:	fd7914e3          	bne	s2,s7,80005590 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055cc:	100a0a13          	addi	s4,s4,256
    800055d0:	6088                	ld	a0,0(s1)
    800055d2:	cd31                	beqz	a0,8000562e <sys_exec+0xf4>
    kfree(argv[i]);
    800055d4:	c88fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055d8:	04a1                	addi	s1,s1,8
    800055da:	ff449be3          	bne	s1,s4,800055d0 <sys_exec+0x96>
  return -1;
    800055de:	557d                	li	a0,-1
    800055e0:	64be                	ld	s1,456(sp)
    800055e2:	691e                	ld	s2,448(sp)
    800055e4:	79fa                	ld	s3,440(sp)
    800055e6:	7a5a                	ld	s4,432(sp)
    800055e8:	7aba                	ld	s5,424(sp)
    800055ea:	7b1a                	ld	s6,416(sp)
    800055ec:	6bfa                	ld	s7,408(sp)
    800055ee:	a881                	j	8000563e <sys_exec+0x104>
      argv[i] = 0;
    800055f0:	0009079b          	sext.w	a5,s2
    800055f4:	e3040593          	addi	a1,s0,-464
    800055f8:	078e                	slli	a5,a5,0x3
    800055fa:	97ae                	add	a5,a5,a1
    800055fc:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005600:	f3040513          	addi	a0,s0,-208
    80005604:	bb2ff0ef          	jal	800049b6 <kexec>
    80005608:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000560a:	100a0a13          	addi	s4,s4,256
    8000560e:	6088                	ld	a0,0(s1)
    80005610:	c511                	beqz	a0,8000561c <sys_exec+0xe2>
    kfree(argv[i]);
    80005612:	c4afb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005616:	04a1                	addi	s1,s1,8
    80005618:	ff449be3          	bne	s1,s4,8000560e <sys_exec+0xd4>
  return ret;
    8000561c:	854a                	mv	a0,s2
    8000561e:	64be                	ld	s1,456(sp)
    80005620:	691e                	ld	s2,448(sp)
    80005622:	79fa                	ld	s3,440(sp)
    80005624:	7a5a                	ld	s4,432(sp)
    80005626:	7aba                	ld	s5,424(sp)
    80005628:	7b1a                	ld	s6,416(sp)
    8000562a:	6bfa                	ld	s7,408(sp)
    8000562c:	a809                	j	8000563e <sys_exec+0x104>
  return -1;
    8000562e:	557d                	li	a0,-1
    80005630:	64be                	ld	s1,456(sp)
    80005632:	691e                	ld	s2,448(sp)
    80005634:	79fa                	ld	s3,440(sp)
    80005636:	7a5a                	ld	s4,432(sp)
    80005638:	7aba                	ld	s5,424(sp)
    8000563a:	7b1a                	ld	s6,416(sp)
    8000563c:	6bfa                	ld	s7,408(sp)
}
    8000563e:	60fe                	ld	ra,472(sp)
    80005640:	645e                	ld	s0,464(sp)
    80005642:	613d                	addi	sp,sp,480
    80005644:	8082                	ret

0000000080005646 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005646:	7139                	addi	sp,sp,-64
    80005648:	fc06                	sd	ra,56(sp)
    8000564a:	f822                	sd	s0,48(sp)
    8000564c:	f426                	sd	s1,40(sp)
    8000564e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005650:	b58fc0ef          	jal	800019a8 <myproc>
    80005654:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005656:	fd840593          	addi	a1,s0,-40
    8000565a:	4501                	li	a0,0
    8000565c:	cbcfd0ef          	jal	80002b18 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005660:	fc840593          	addi	a1,s0,-56
    80005664:	fd040513          	addi	a0,s0,-48
    80005668:	81eff0ef          	jal	80004686 <pipealloc>
    return -1;
    8000566c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000566e:	0a054763          	bltz	a0,8000571c <sys_pipe+0xd6>
  fd0 = -1;
    80005672:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005676:	fd043503          	ld	a0,-48(s0)
    8000567a:	ef2ff0ef          	jal	80004d6c <fdalloc>
    8000567e:	fca42223          	sw	a0,-60(s0)
    80005682:	08054463          	bltz	a0,8000570a <sys_pipe+0xc4>
    80005686:	fc843503          	ld	a0,-56(s0)
    8000568a:	ee2ff0ef          	jal	80004d6c <fdalloc>
    8000568e:	fca42023          	sw	a0,-64(s0)
    80005692:	06054263          	bltz	a0,800056f6 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005696:	4691                	li	a3,4
    80005698:	fc440613          	addi	a2,s0,-60
    8000569c:	fd843583          	ld	a1,-40(s0)
    800056a0:	68a8                	ld	a0,80(s1)
    800056a2:	fb3fb0ef          	jal	80001654 <copyout>
    800056a6:	00054e63          	bltz	a0,800056c2 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800056aa:	4691                	li	a3,4
    800056ac:	fc040613          	addi	a2,s0,-64
    800056b0:	fd843583          	ld	a1,-40(s0)
    800056b4:	95b6                	add	a1,a1,a3
    800056b6:	68a8                	ld	a0,80(s1)
    800056b8:	f9dfb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800056bc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056be:	04055f63          	bgez	a0,8000571c <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    800056c2:	fc442783          	lw	a5,-60(s0)
    800056c6:	078e                	slli	a5,a5,0x3
    800056c8:	0d078793          	addi	a5,a5,208
    800056cc:	97a6                	add	a5,a5,s1
    800056ce:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800056d2:	fc042783          	lw	a5,-64(s0)
    800056d6:	078e                	slli	a5,a5,0x3
    800056d8:	0d078793          	addi	a5,a5,208
    800056dc:	97a6                	add	a5,a5,s1
    800056de:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800056e2:	fd043503          	ld	a0,-48(s0)
    800056e6:	c85fe0ef          	jal	8000436a <fileclose>
    fileclose(wf);
    800056ea:	fc843503          	ld	a0,-56(s0)
    800056ee:	c7dfe0ef          	jal	8000436a <fileclose>
    return -1;
    800056f2:	57fd                	li	a5,-1
    800056f4:	a025                	j	8000571c <sys_pipe+0xd6>
    if(fd0 >= 0)
    800056f6:	fc442783          	lw	a5,-60(s0)
    800056fa:	0007c863          	bltz	a5,8000570a <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800056fe:	078e                	slli	a5,a5,0x3
    80005700:	0d078793          	addi	a5,a5,208
    80005704:	97a6                	add	a5,a5,s1
    80005706:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000570a:	fd043503          	ld	a0,-48(s0)
    8000570e:	c5dfe0ef          	jal	8000436a <fileclose>
    fileclose(wf);
    80005712:	fc843503          	ld	a0,-56(s0)
    80005716:	c55fe0ef          	jal	8000436a <fileclose>
    return -1;
    8000571a:	57fd                	li	a5,-1
}
    8000571c:	853e                	mv	a0,a5
    8000571e:	70e2                	ld	ra,56(sp)
    80005720:	7442                	ld	s0,48(sp)
    80005722:	74a2                	ld	s1,40(sp)
    80005724:	6121                	addi	sp,sp,64
    80005726:	8082                	ret
	...

0000000080005730 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005730:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005732:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005734:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005736:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005738:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000573a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000573c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000573e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005740:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005742:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005744:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005746:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005748:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000574a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000574c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000574e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005750:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005752:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005754:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005756:	a2afd0ef          	jal	80002980 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000575a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000575c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000575e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005760:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005762:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005764:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005766:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005768:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000576a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000576c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000576e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005770:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005772:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005774:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005776:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005778:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000577a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000577c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000577e:	10200073          	sret
    80005782:	00000013          	nop
    80005786:	00000013          	nop
    8000578a:	00000013          	nop

000000008000578e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000578e:	1141                	addi	sp,sp,-16
    80005790:	e406                	sd	ra,8(sp)
    80005792:	e022                	sd	s0,0(sp)
    80005794:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005796:	0c000737          	lui	a4,0xc000
    8000579a:	4785                	li	a5,1
    8000579c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000579e:	c35c                	sw	a5,4(a4)
}
    800057a0:	60a2                	ld	ra,8(sp)
    800057a2:	6402                	ld	s0,0(sp)
    800057a4:	0141                	addi	sp,sp,16
    800057a6:	8082                	ret

00000000800057a8 <plicinithart>:

void
plicinithart(void)
{
    800057a8:	1141                	addi	sp,sp,-16
    800057aa:	e406                	sd	ra,8(sp)
    800057ac:	e022                	sd	s0,0(sp)
    800057ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057b0:	9c4fc0ef          	jal	80001974 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800057b4:	0085171b          	slliw	a4,a0,0x8
    800057b8:	0c0027b7          	lui	a5,0xc002
    800057bc:	97ba                	add	a5,a5,a4
    800057be:	40200713          	li	a4,1026
    800057c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800057c6:	00d5151b          	slliw	a0,a0,0xd
    800057ca:	0c2017b7          	lui	a5,0xc201
    800057ce:	97aa                	add	a5,a5,a0
    800057d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800057d4:	60a2                	ld	ra,8(sp)
    800057d6:	6402                	ld	s0,0(sp)
    800057d8:	0141                	addi	sp,sp,16
    800057da:	8082                	ret

00000000800057dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057dc:	1141                	addi	sp,sp,-16
    800057de:	e406                	sd	ra,8(sp)
    800057e0:	e022                	sd	s0,0(sp)
    800057e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057e4:	990fc0ef          	jal	80001974 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800057e8:	00d5151b          	slliw	a0,a0,0xd
    800057ec:	0c2017b7          	lui	a5,0xc201
    800057f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800057f2:	43c8                	lw	a0,4(a5)
    800057f4:	60a2                	ld	ra,8(sp)
    800057f6:	6402                	ld	s0,0(sp)
    800057f8:	0141                	addi	sp,sp,16
    800057fa:	8082                	ret

00000000800057fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057fc:	1101                	addi	sp,sp,-32
    800057fe:	ec06                	sd	ra,24(sp)
    80005800:	e822                	sd	s0,16(sp)
    80005802:	e426                	sd	s1,8(sp)
    80005804:	1000                	addi	s0,sp,32
    80005806:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005808:	96cfc0ef          	jal	80001974 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000580c:	00d5179b          	slliw	a5,a0,0xd
    80005810:	0c201737          	lui	a4,0xc201
    80005814:	97ba                	add	a5,a5,a4
    80005816:	c3c4                	sw	s1,4(a5)
}
    80005818:	60e2                	ld	ra,24(sp)
    8000581a:	6442                	ld	s0,16(sp)
    8000581c:	64a2                	ld	s1,8(sp)
    8000581e:	6105                	addi	sp,sp,32
    80005820:	8082                	ret

0000000080005822 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005822:	1141                	addi	sp,sp,-16
    80005824:	e406                	sd	ra,8(sp)
    80005826:	e022                	sd	s0,0(sp)
    80005828:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000582a:	479d                	li	a5,7
    8000582c:	04a7ca63          	blt	a5,a0,80005880 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005830:	0001b797          	auipc	a5,0x1b
    80005834:	69078793          	addi	a5,a5,1680 # 80020ec0 <disk>
    80005838:	97aa                	add	a5,a5,a0
    8000583a:	0187c783          	lbu	a5,24(a5)
    8000583e:	e7b9                	bnez	a5,8000588c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005840:	00451693          	slli	a3,a0,0x4
    80005844:	0001b797          	auipc	a5,0x1b
    80005848:	67c78793          	addi	a5,a5,1660 # 80020ec0 <disk>
    8000584c:	6398                	ld	a4,0(a5)
    8000584e:	9736                	add	a4,a4,a3
    80005850:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005854:	6398                	ld	a4,0(a5)
    80005856:	9736                	add	a4,a4,a3
    80005858:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000585c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005860:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005864:	97aa                	add	a5,a5,a0
    80005866:	4705                	li	a4,1
    80005868:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000586c:	0001b517          	auipc	a0,0x1b
    80005870:	66c50513          	addi	a0,a0,1644 # 80020ed8 <disk+0x18>
    80005874:	95bfc0ef          	jal	800021ce <wakeup>
}
    80005878:	60a2                	ld	ra,8(sp)
    8000587a:	6402                	ld	s0,0(sp)
    8000587c:	0141                	addi	sp,sp,16
    8000587e:	8082                	ret
    panic("free_desc 1");
    80005880:	00002517          	auipc	a0,0x2
    80005884:	d9850513          	addi	a0,a0,-616 # 80007618 <etext+0x618>
    80005888:	f9dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000588c:	00002517          	auipc	a0,0x2
    80005890:	d9c50513          	addi	a0,a0,-612 # 80007628 <etext+0x628>
    80005894:	f91fa0ef          	jal	80000824 <panic>

0000000080005898 <virtio_disk_init>:
{
    80005898:	1101                	addi	sp,sp,-32
    8000589a:	ec06                	sd	ra,24(sp)
    8000589c:	e822                	sd	s0,16(sp)
    8000589e:	e426                	sd	s1,8(sp)
    800058a0:	e04a                	sd	s2,0(sp)
    800058a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800058a4:	00002597          	auipc	a1,0x2
    800058a8:	d9458593          	addi	a1,a1,-620 # 80007638 <etext+0x638>
    800058ac:	0001b517          	auipc	a0,0x1b
    800058b0:	73c50513          	addi	a0,a0,1852 # 80020fe8 <disk+0x128>
    800058b4:	aeafb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058b8:	100017b7          	lui	a5,0x10001
    800058bc:	4398                	lw	a4,0(a5)
    800058be:	2701                	sext.w	a4,a4
    800058c0:	747277b7          	lui	a5,0x74727
    800058c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058c8:	14f71863          	bne	a4,a5,80005a18 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058cc:	100017b7          	lui	a5,0x10001
    800058d0:	43dc                	lw	a5,4(a5)
    800058d2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058d4:	4709                	li	a4,2
    800058d6:	14e79163          	bne	a5,a4,80005a18 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058da:	100017b7          	lui	a5,0x10001
    800058de:	479c                	lw	a5,8(a5)
    800058e0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058e2:	12e79b63          	bne	a5,a4,80005a18 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800058e6:	100017b7          	lui	a5,0x10001
    800058ea:	47d8                	lw	a4,12(a5)
    800058ec:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058ee:	554d47b7          	lui	a5,0x554d4
    800058f2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058f6:	12f71163          	bne	a4,a5,80005a18 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058fa:	100017b7          	lui	a5,0x10001
    800058fe:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005902:	4705                	li	a4,1
    80005904:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005906:	470d                	li	a4,3
    80005908:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000590a:	10001737          	lui	a4,0x10001
    8000590e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005910:	c7ffe6b7          	lui	a3,0xc7ffe
    80005914:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd75f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005918:	8f75                	and	a4,a4,a3
    8000591a:	100016b7          	lui	a3,0x10001
    8000591e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005920:	472d                	li	a4,11
    80005922:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005924:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005928:	439c                	lw	a5,0(a5)
    8000592a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000592e:	8ba1                	andi	a5,a5,8
    80005930:	0e078a63          	beqz	a5,80005a24 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005934:	100017b7          	lui	a5,0x10001
    80005938:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000593c:	43fc                	lw	a5,68(a5)
    8000593e:	2781                	sext.w	a5,a5
    80005940:	0e079863          	bnez	a5,80005a30 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005944:	100017b7          	lui	a5,0x10001
    80005948:	5bdc                	lw	a5,52(a5)
    8000594a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000594c:	0e078863          	beqz	a5,80005a3c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005950:	471d                	li	a4,7
    80005952:	0ef77b63          	bgeu	a4,a5,80005a48 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005956:	9eefb0ef          	jal	80000b44 <kalloc>
    8000595a:	0001b497          	auipc	s1,0x1b
    8000595e:	56648493          	addi	s1,s1,1382 # 80020ec0 <disk>
    80005962:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005964:	9e0fb0ef          	jal	80000b44 <kalloc>
    80005968:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000596a:	9dafb0ef          	jal	80000b44 <kalloc>
    8000596e:	87aa                	mv	a5,a0
    80005970:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005972:	6088                	ld	a0,0(s1)
    80005974:	0e050063          	beqz	a0,80005a54 <virtio_disk_init+0x1bc>
    80005978:	0001b717          	auipc	a4,0x1b
    8000597c:	55073703          	ld	a4,1360(a4) # 80020ec8 <disk+0x8>
    80005980:	cb71                	beqz	a4,80005a54 <virtio_disk_init+0x1bc>
    80005982:	cbe9                	beqz	a5,80005a54 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005984:	6605                	lui	a2,0x1
    80005986:	4581                	li	a1,0
    80005988:	b70fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000598c:	0001b497          	auipc	s1,0x1b
    80005990:	53448493          	addi	s1,s1,1332 # 80020ec0 <disk>
    80005994:	6605                	lui	a2,0x1
    80005996:	4581                	li	a1,0
    80005998:	6488                	ld	a0,8(s1)
    8000599a:	b5efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000599e:	6605                	lui	a2,0x1
    800059a0:	4581                	li	a1,0
    800059a2:	6888                	ld	a0,16(s1)
    800059a4:	b54fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800059a8:	100017b7          	lui	a5,0x10001
    800059ac:	4721                	li	a4,8
    800059ae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800059b0:	4098                	lw	a4,0(s1)
    800059b2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800059b6:	40d8                	lw	a4,4(s1)
    800059b8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800059bc:	649c                	ld	a5,8(s1)
    800059be:	0007869b          	sext.w	a3,a5
    800059c2:	10001737          	lui	a4,0x10001
    800059c6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059ca:	9781                	srai	a5,a5,0x20
    800059cc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059d0:	689c                	ld	a5,16(s1)
    800059d2:	0007869b          	sext.w	a3,a5
    800059d6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059da:	9781                	srai	a5,a5,0x20
    800059dc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800059e0:	4785                	li	a5,1
    800059e2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800059e4:	00f48c23          	sb	a5,24(s1)
    800059e8:	00f48ca3          	sb	a5,25(s1)
    800059ec:	00f48d23          	sb	a5,26(s1)
    800059f0:	00f48da3          	sb	a5,27(s1)
    800059f4:	00f48e23          	sb	a5,28(s1)
    800059f8:	00f48ea3          	sb	a5,29(s1)
    800059fc:	00f48f23          	sb	a5,30(s1)
    80005a00:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a04:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a08:	07272823          	sw	s2,112(a4)
}
    80005a0c:	60e2                	ld	ra,24(sp)
    80005a0e:	6442                	ld	s0,16(sp)
    80005a10:	64a2                	ld	s1,8(sp)
    80005a12:	6902                	ld	s2,0(sp)
    80005a14:	6105                	addi	sp,sp,32
    80005a16:	8082                	ret
    panic("could not find virtio disk");
    80005a18:	00002517          	auipc	a0,0x2
    80005a1c:	c3050513          	addi	a0,a0,-976 # 80007648 <etext+0x648>
    80005a20:	e05fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a24:	00002517          	auipc	a0,0x2
    80005a28:	c4450513          	addi	a0,a0,-956 # 80007668 <etext+0x668>
    80005a2c:	df9fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005a30:	00002517          	auipc	a0,0x2
    80005a34:	c5850513          	addi	a0,a0,-936 # 80007688 <etext+0x688>
    80005a38:	dedfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005a3c:	00002517          	auipc	a0,0x2
    80005a40:	c6c50513          	addi	a0,a0,-916 # 800076a8 <etext+0x6a8>
    80005a44:	de1fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005a48:	00002517          	auipc	a0,0x2
    80005a4c:	c8050513          	addi	a0,a0,-896 # 800076c8 <etext+0x6c8>
    80005a50:	dd5fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005a54:	00002517          	auipc	a0,0x2
    80005a58:	c9450513          	addi	a0,a0,-876 # 800076e8 <etext+0x6e8>
    80005a5c:	dc9fa0ef          	jal	80000824 <panic>

0000000080005a60 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a60:	711d                	addi	sp,sp,-96
    80005a62:	ec86                	sd	ra,88(sp)
    80005a64:	e8a2                	sd	s0,80(sp)
    80005a66:	e4a6                	sd	s1,72(sp)
    80005a68:	e0ca                	sd	s2,64(sp)
    80005a6a:	fc4e                	sd	s3,56(sp)
    80005a6c:	f852                	sd	s4,48(sp)
    80005a6e:	f456                	sd	s5,40(sp)
    80005a70:	f05a                	sd	s6,32(sp)
    80005a72:	ec5e                	sd	s7,24(sp)
    80005a74:	e862                	sd	s8,16(sp)
    80005a76:	1080                	addi	s0,sp,96
    80005a78:	89aa                	mv	s3,a0
    80005a7a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a7c:	00c52b83          	lw	s7,12(a0)
    80005a80:	001b9b9b          	slliw	s7,s7,0x1
    80005a84:	1b82                	slli	s7,s7,0x20
    80005a86:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005a8a:	0001b517          	auipc	a0,0x1b
    80005a8e:	55e50513          	addi	a0,a0,1374 # 80020fe8 <disk+0x128>
    80005a92:	996fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005a96:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a98:	0001ba97          	auipc	s5,0x1b
    80005a9c:	428a8a93          	addi	s5,s5,1064 # 80020ec0 <disk>
  for(int i = 0; i < 3; i++){
    80005aa0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005aa2:	5c7d                	li	s8,-1
    80005aa4:	a095                	j	80005b08 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005aa6:	00fa8733          	add	a4,s5,a5
    80005aaa:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005aae:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005ab0:	0207c563          	bltz	a5,80005ada <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005ab4:	2905                	addiw	s2,s2,1
    80005ab6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005ab8:	05490c63          	beq	s2,s4,80005b10 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005abc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005abe:	0001b717          	auipc	a4,0x1b
    80005ac2:	40270713          	addi	a4,a4,1026 # 80020ec0 <disk>
    80005ac6:	4781                	li	a5,0
    if(disk.free[i]){
    80005ac8:	01874683          	lbu	a3,24(a4)
    80005acc:	fee9                	bnez	a3,80005aa6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005ace:	2785                	addiw	a5,a5,1
    80005ad0:	0705                	addi	a4,a4,1
    80005ad2:	fe979be3          	bne	a5,s1,80005ac8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005ad6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005ada:	01205d63          	blez	s2,80005af4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005ade:	fa042503          	lw	a0,-96(s0)
    80005ae2:	d41ff0ef          	jal	80005822 <free_desc>
      for(int j = 0; j < i; j++)
    80005ae6:	4785                	li	a5,1
    80005ae8:	0127d663          	bge	a5,s2,80005af4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005aec:	fa442503          	lw	a0,-92(s0)
    80005af0:	d33ff0ef          	jal	80005822 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005af4:	0001b597          	auipc	a1,0x1b
    80005af8:	4f458593          	addi	a1,a1,1268 # 80020fe8 <disk+0x128>
    80005afc:	0001b517          	auipc	a0,0x1b
    80005b00:	3dc50513          	addi	a0,a0,988 # 80020ed8 <disk+0x18>
    80005b04:	e7efc0ef          	jal	80002182 <sleep>
  for(int i = 0; i < 3; i++){
    80005b08:	fa040613          	addi	a2,s0,-96
    80005b0c:	4901                	li	s2,0
    80005b0e:	b77d                	j	80005abc <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b10:	fa042503          	lw	a0,-96(s0)
    80005b14:	00451693          	slli	a3,a0,0x4

  if(write)
    80005b18:	0001b797          	auipc	a5,0x1b
    80005b1c:	3a878793          	addi	a5,a5,936 # 80020ec0 <disk>
    80005b20:	00451713          	slli	a4,a0,0x4
    80005b24:	0a070713          	addi	a4,a4,160
    80005b28:	973e                	add	a4,a4,a5
    80005b2a:	01603633          	snez	a2,s6
    80005b2e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b30:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b34:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b38:	6398                	ld	a4,0(a5)
    80005b3a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b3c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b40:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b42:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b44:	6390                	ld	a2,0(a5)
    80005b46:	00d60833          	add	a6,a2,a3
    80005b4a:	4741                	li	a4,16
    80005b4c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b50:	4585                	li	a1,1
    80005b52:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b56:	fa442703          	lw	a4,-92(s0)
    80005b5a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005b5e:	0712                	slli	a4,a4,0x4
    80005b60:	963a                	add	a2,a2,a4
    80005b62:	05898813          	addi	a6,s3,88
    80005b66:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b6a:	0007b883          	ld	a7,0(a5)
    80005b6e:	9746                	add	a4,a4,a7
    80005b70:	40000613          	li	a2,1024
    80005b74:	c710                	sw	a2,8(a4)
  if(write)
    80005b76:	001b3613          	seqz	a2,s6
    80005b7a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b7e:	8e4d                	or	a2,a2,a1
    80005b80:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b84:	fa842603          	lw	a2,-88(s0)
    80005b88:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b8c:	00451813          	slli	a6,a0,0x4
    80005b90:	02080813          	addi	a6,a6,32
    80005b94:	983e                	add	a6,a6,a5
    80005b96:	577d                	li	a4,-1
    80005b98:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b9c:	0612                	slli	a2,a2,0x4
    80005b9e:	98b2                	add	a7,a7,a2
    80005ba0:	03068713          	addi	a4,a3,48
    80005ba4:	973e                	add	a4,a4,a5
    80005ba6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005baa:	6398                	ld	a4,0(a5)
    80005bac:	9732                	add	a4,a4,a2
    80005bae:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005bb0:	4689                	li	a3,2
    80005bb2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005bb6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005bba:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005bbe:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005bc2:	6794                	ld	a3,8(a5)
    80005bc4:	0026d703          	lhu	a4,2(a3)
    80005bc8:	8b1d                	andi	a4,a4,7
    80005bca:	0706                	slli	a4,a4,0x1
    80005bcc:	96ba                	add	a3,a3,a4
    80005bce:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005bd2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005bd6:	6798                	ld	a4,8(a5)
    80005bd8:	00275783          	lhu	a5,2(a4)
    80005bdc:	2785                	addiw	a5,a5,1
    80005bde:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005be2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005be6:	100017b7          	lui	a5,0x10001
    80005bea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005bee:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005bf2:	0001b917          	auipc	s2,0x1b
    80005bf6:	3f690913          	addi	s2,s2,1014 # 80020fe8 <disk+0x128>
  while(b->disk == 1) {
    80005bfa:	84ae                	mv	s1,a1
    80005bfc:	00b79a63          	bne	a5,a1,80005c10 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005c00:	85ca                	mv	a1,s2
    80005c02:	854e                	mv	a0,s3
    80005c04:	d7efc0ef          	jal	80002182 <sleep>
  while(b->disk == 1) {
    80005c08:	0049a783          	lw	a5,4(s3)
    80005c0c:	fe978ae3          	beq	a5,s1,80005c00 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005c10:	fa042903          	lw	s2,-96(s0)
    80005c14:	00491713          	slli	a4,s2,0x4
    80005c18:	02070713          	addi	a4,a4,32
    80005c1c:	0001b797          	auipc	a5,0x1b
    80005c20:	2a478793          	addi	a5,a5,676 # 80020ec0 <disk>
    80005c24:	97ba                	add	a5,a5,a4
    80005c26:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c2a:	0001b997          	auipc	s3,0x1b
    80005c2e:	29698993          	addi	s3,s3,662 # 80020ec0 <disk>
    80005c32:	00491713          	slli	a4,s2,0x4
    80005c36:	0009b783          	ld	a5,0(s3)
    80005c3a:	97ba                	add	a5,a5,a4
    80005c3c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c40:	854a                	mv	a0,s2
    80005c42:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c46:	bddff0ef          	jal	80005822 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c4a:	8885                	andi	s1,s1,1
    80005c4c:	f0fd                	bnez	s1,80005c32 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c4e:	0001b517          	auipc	a0,0x1b
    80005c52:	39a50513          	addi	a0,a0,922 # 80020fe8 <disk+0x128>
    80005c56:	866fb0ef          	jal	80000cbc <release>
}
    80005c5a:	60e6                	ld	ra,88(sp)
    80005c5c:	6446                	ld	s0,80(sp)
    80005c5e:	64a6                	ld	s1,72(sp)
    80005c60:	6906                	ld	s2,64(sp)
    80005c62:	79e2                	ld	s3,56(sp)
    80005c64:	7a42                	ld	s4,48(sp)
    80005c66:	7aa2                	ld	s5,40(sp)
    80005c68:	7b02                	ld	s6,32(sp)
    80005c6a:	6be2                	ld	s7,24(sp)
    80005c6c:	6c42                	ld	s8,16(sp)
    80005c6e:	6125                	addi	sp,sp,96
    80005c70:	8082                	ret

0000000080005c72 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c72:	1101                	addi	sp,sp,-32
    80005c74:	ec06                	sd	ra,24(sp)
    80005c76:	e822                	sd	s0,16(sp)
    80005c78:	e426                	sd	s1,8(sp)
    80005c7a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c7c:	0001b497          	auipc	s1,0x1b
    80005c80:	24448493          	addi	s1,s1,580 # 80020ec0 <disk>
    80005c84:	0001b517          	auipc	a0,0x1b
    80005c88:	36450513          	addi	a0,a0,868 # 80020fe8 <disk+0x128>
    80005c8c:	f9dfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c90:	100017b7          	lui	a5,0x10001
    80005c94:	53bc                	lw	a5,96(a5)
    80005c96:	8b8d                	andi	a5,a5,3
    80005c98:	10001737          	lui	a4,0x10001
    80005c9c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005c9e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005ca2:	689c                	ld	a5,16(s1)
    80005ca4:	0204d703          	lhu	a4,32(s1)
    80005ca8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005cac:	04f70863          	beq	a4,a5,80005cfc <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005cb0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005cb4:	6898                	ld	a4,16(s1)
    80005cb6:	0204d783          	lhu	a5,32(s1)
    80005cba:	8b9d                	andi	a5,a5,7
    80005cbc:	078e                	slli	a5,a5,0x3
    80005cbe:	97ba                	add	a5,a5,a4
    80005cc0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005cc2:	00479713          	slli	a4,a5,0x4
    80005cc6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005cca:	9726                	add	a4,a4,s1
    80005ccc:	01074703          	lbu	a4,16(a4)
    80005cd0:	e329                	bnez	a4,80005d12 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cd2:	0792                	slli	a5,a5,0x4
    80005cd4:	02078793          	addi	a5,a5,32
    80005cd8:	97a6                	add	a5,a5,s1
    80005cda:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005cdc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005ce0:	ceefc0ef          	jal	800021ce <wakeup>

    disk.used_idx += 1;
    80005ce4:	0204d783          	lhu	a5,32(s1)
    80005ce8:	2785                	addiw	a5,a5,1
    80005cea:	17c2                	slli	a5,a5,0x30
    80005cec:	93c1                	srli	a5,a5,0x30
    80005cee:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005cf2:	6898                	ld	a4,16(s1)
    80005cf4:	00275703          	lhu	a4,2(a4)
    80005cf8:	faf71ce3          	bne	a4,a5,80005cb0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005cfc:	0001b517          	auipc	a0,0x1b
    80005d00:	2ec50513          	addi	a0,a0,748 # 80020fe8 <disk+0x128>
    80005d04:	fb9fa0ef          	jal	80000cbc <release>
}
    80005d08:	60e2                	ld	ra,24(sp)
    80005d0a:	6442                	ld	s0,16(sp)
    80005d0c:	64a2                	ld	s1,8(sp)
    80005d0e:	6105                	addi	sp,sp,32
    80005d10:	8082                	ret
      panic("virtio_disk_intr status");
    80005d12:	00002517          	auipc	a0,0x2
    80005d16:	9ee50513          	addi	a0,a0,-1554 # 80007700 <etext+0x700>
    80005d1a:	b0bfa0ef          	jal	80000824 <panic>
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
