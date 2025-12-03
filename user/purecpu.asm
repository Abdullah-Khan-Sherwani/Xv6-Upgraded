
user/_purecpu:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

// Pure CPU-bound test: Does ONLY computation, checks priority at end
int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  struct procinfo info;
  volatile int dummy = 0;
   8:	fc042e23          	sw	zero,-36(s0)
  
  printf("\n=== Pure CPU-Bound Test ===\n");
   c:	00001517          	auipc	a0,0x1
  10:	a0450513          	addi	a0,a0,-1532 # a10 <malloc+0xfa>
  14:	04b000ef          	jal	85e <printf>
  
  if(getprocinfo(&info) == 0) {
  18:	fe040513          	addi	a0,s0,-32
  1c:	48c000ef          	jal	4a8 <getprocinfo>
  20:	c90d                	beqz	a0,52 <main+0x52>
    printf("Starting: PID=%d, Q%d, slices=%d\n\n", 
           info.pid, info.priority, info.time_slices);
  }
  
  printf("Running continuous CPU work (no interruptions)...\n");
  22:	00001517          	auipc	a0,0x1
  26:	a3650513          	addi	a0,a0,-1482 # a58 <malloc+0x142>
  2a:	035000ef          	jal	85e <printf>
  printf("This will take several seconds...\n\n");
  2e:	00001517          	auipc	a0,0x1
  32:	a6250513          	addi	a0,a0,-1438 # a90 <malloc+0x17a>
  36:	029000ef          	jal	85e <printf>
  
  // Do MASSIVE amount of work without any syscalls
  // Increased significantly to trigger multiple demotions
  for(int i = 0; i < 500000000; i++) {
  3a:	4701                	li	a4,0
    dummy = dummy + i;
    // Add more computation to slow it down
    if(i % 1000 == 0) {
  3c:	106255b7          	lui	a1,0x10625
  40:	dd358593          	addi	a1,a1,-557 # 10624dd3 <base+0x10623dc3>
  44:	3e800513          	li	a0,1000
  for(int i = 0; i < 500000000; i++) {
  48:	1dcd6637          	lui	a2,0x1dcd6
  4c:	50060613          	addi	a2,a2,1280 # 1dcd6500 <base+0x1dcd54f0>
  50:	a00d                	j	72 <main+0x72>
    printf("Starting: PID=%d, Q%d, slices=%d\n\n", 
  52:	fec42683          	lw	a3,-20(s0)
  56:	fe842603          	lw	a2,-24(s0)
  5a:	fe042583          	lw	a1,-32(s0)
  5e:	00001517          	auipc	a0,0x1
  62:	9d250513          	addi	a0,a0,-1582 # a30 <malloc+0x11a>
  66:	7f8000ef          	jal	85e <printf>
  6a:	bf65                	j	22 <main+0x22>
  for(int i = 0; i < 500000000; i++) {
  6c:	2705                	addiw	a4,a4,1
  6e:	04c70363          	beq	a4,a2,b4 <main+0xb4>
    dummy = dummy + i;
  72:	fdc42783          	lw	a5,-36(s0)
  76:	9fb9                	addw	a5,a5,a4
  78:	fcf42e23          	sw	a5,-36(s0)
    if(i % 1000 == 0) {
  7c:	02b707b3          	mul	a5,a4,a1
  80:	9799                	srai	a5,a5,0x26
  82:	41f7569b          	sraiw	a3,a4,0x1f
  86:	9f95                	subw	a5,a5,a3
  88:	02f507bb          	mulw	a5,a0,a5
  8c:	40f707bb          	subw	a5,a4,a5
  90:	fff1                	bnez	a5,6c <main+0x6c>
      dummy = dummy * 2;
  92:	fdc42783          	lw	a5,-36(s0)
  96:	2781                	sext.w	a5,a5
  98:	0017979b          	slliw	a5,a5,0x1
  9c:	fcf42e23          	sw	a5,-36(s0)
      dummy = dummy / 2;
  a0:	fdc42683          	lw	a3,-36(s0)
  a4:	01f6d79b          	srliw	a5,a3,0x1f
  a8:	9fb5                	addw	a5,a5,a3
  aa:	4017d79b          	sraiw	a5,a5,0x1
  ae:	fcf42e23          	sw	a5,-36(s0)
  b2:	bf6d                	j	6c <main+0x6c>
    }
  }
  
  printf("Work complete! Checking final state...\n\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	a0450513          	addi	a0,a0,-1532 # ab8 <malloc+0x1a2>
  bc:	7a2000ef          	jal	85e <printf>
  
  if(getprocinfo(&info) == 0) {
  c0:	fe040513          	addi	a0,s0,-32
  c4:	3e4000ef          	jal	4a8 <getprocinfo>
  c8:	c501                	beqz	a0,d0 <main+0xd0>
    } else {
      printf("✗ FAILED: Still at Q0 (no demotion occurred)\n");
    }
  }
  
  exit(0);
  ca:	4501                	li	a0,0
  cc:	33c000ef          	jal	408 <exit>
    printf("Final: PID=%d, Q%d, slices=%d\n", 
  d0:	fec42683          	lw	a3,-20(s0)
  d4:	fe842603          	lw	a2,-24(s0)
  d8:	fe042583          	lw	a1,-32(s0)
  dc:	00001517          	auipc	a0,0x1
  e0:	a0c50513          	addi	a0,a0,-1524 # ae8 <malloc+0x1d2>
  e4:	77a000ef          	jal	85e <printf>
    printf("\nExpected behavior:\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	a2050513          	addi	a0,a0,-1504 # b08 <malloc+0x1f2>
  f0:	76e000ef          	jal	85e <printf>
    printf("  - Should have used many timer ticks\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	a2c50513          	addi	a0,a0,-1492 # b20 <malloc+0x20a>
  fc:	762000ef          	jal	85e <printf>
    printf("  - Should have demoted through queues\n");
 100:	00001517          	auipc	a0,0x1
 104:	a4850513          	addi	a0,a0,-1464 # b48 <malloc+0x232>
 108:	756000ef          	jal	85e <printf>
    printf("  - Should be at Q3 (or Q2/Q3)\n\n");
 10c:	00001517          	auipc	a0,0x1
 110:	a6450513          	addi	a0,a0,-1436 # b70 <malloc+0x25a>
 114:	74a000ef          	jal	85e <printf>
    if(info.priority >= 2) {
 118:	fe842583          	lw	a1,-24(s0)
 11c:	4785                	li	a5,1
 11e:	00b7cc63          	blt	a5,a1,136 <main+0x136>
    } else if(info.priority == 1) {
 122:	4785                	li	a5,1
 124:	02f58063          	beq	a1,a5,144 <main+0x144>
      printf("✗ FAILED: Still at Q0 (no demotion occurred)\n");
 128:	00001517          	auipc	a0,0x1
 12c:	ac050513          	addi	a0,a0,-1344 # be8 <malloc+0x2d2>
 130:	72e000ef          	jal	85e <printf>
 134:	bf59                	j	ca <main+0xca>
      printf("✓ SUCCESS: Demoted to Q%d\n", info.priority);
 136:	00001517          	auipc	a0,0x1
 13a:	a6250513          	addi	a0,a0,-1438 # b98 <malloc+0x282>
 13e:	720000ef          	jal	85e <printf>
 142:	b761                	j	ca <main+0xca>
      printf("~ PARTIAL: Only reached Q1 (expected Q2 or Q3)\n");
 144:	00001517          	auipc	a0,0x1
 148:	a7450513          	addi	a0,a0,-1420 # bb8 <malloc+0x2a2>
 14c:	712000ef          	jal	85e <printf>
 150:	bfad                	j	ca <main+0xca>

0000000000000152 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 152:	1141                	addi	sp,sp,-16
 154:	e406                	sd	ra,8(sp)
 156:	e022                	sd	s0,0(sp)
 158:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 15a:	ea7ff0ef          	jal	0 <main>
  exit(r);
 15e:	2aa000ef          	jal	408 <exit>

0000000000000162 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 162:	1141                	addi	sp,sp,-16
 164:	e406                	sd	ra,8(sp)
 166:	e022                	sd	s0,0(sp)
 168:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 16a:	87aa                	mv	a5,a0
 16c:	0585                	addi	a1,a1,1
 16e:	0785                	addi	a5,a5,1
 170:	fff5c703          	lbu	a4,-1(a1)
 174:	fee78fa3          	sb	a4,-1(a5)
 178:	fb75                	bnez	a4,16c <strcpy+0xa>
    ;
  return os;
}
 17a:	60a2                	ld	ra,8(sp)
 17c:	6402                	ld	s0,0(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 182:	1141                	addi	sp,sp,-16
 184:	e406                	sd	ra,8(sp)
 186:	e022                	sd	s0,0(sp)
 188:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18a:	00054783          	lbu	a5,0(a0)
 18e:	cb91                	beqz	a5,1a2 <strcmp+0x20>
 190:	0005c703          	lbu	a4,0(a1)
 194:	00f71763          	bne	a4,a5,1a2 <strcmp+0x20>
    p++, q++;
 198:	0505                	addi	a0,a0,1
 19a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	fbe5                	bnez	a5,190 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1a2:	0005c503          	lbu	a0,0(a1)
}
 1a6:	40a7853b          	subw	a0,a5,a0
 1aa:	60a2                	ld	ra,8(sp)
 1ac:	6402                	ld	s0,0(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strlen>:

uint
strlen(const char *s)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e406                	sd	ra,8(sp)
 1b6:	e022                	sd	s0,0(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x28>
 1c0:	00150793          	addi	a5,a0,1
 1c4:	86be                	mv	a3,a5
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	ff65                	bnez	a4,1c4 <strlen+0x12>
 1ce:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1d2:	60a2                	ld	ra,8(sp)
 1d4:	6402                	ld	s0,0(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfdd                	j	1d2 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e406                	sd	ra,8(sp)
 1e2:	e022                	sd	s0,0(sp)
 1e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e6:	ca19                	beqz	a2,1fc <memset+0x1e>
 1e8:	87aa                	mv	a5,a0
 1ea:	1602                	slli	a2,a2,0x20
 1ec:	9201                	srli	a2,a2,0x20
 1ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f6:	0785                	addi	a5,a5,1
 1f8:	fee79de3          	bne	a5,a4,1f2 <memset+0x14>
  }
  return dst;
}
 1fc:	60a2                	ld	ra,8(sp)
 1fe:	6402                	ld	s0,0(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strchr>:

char*
strchr(const char *s, char c)
{
 204:	1141                	addi	sp,sp,-16
 206:	e406                	sd	ra,8(sp)
 208:	e022                	sd	s0,0(sp)
 20a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cf81                	beqz	a5,228 <strchr+0x24>
    if(*s == c)
 212:	00f58763          	beq	a1,a5,220 <strchr+0x1c>
  for(; *s; s++)
 216:	0505                	addi	a0,a0,1
 218:	00054783          	lbu	a5,0(a0)
 21c:	fbfd                	bnez	a5,212 <strchr+0xe>
      return (char*)s;
  return 0;
 21e:	4501                	li	a0,0
}
 220:	60a2                	ld	ra,8(sp)
 222:	6402                	ld	s0,0(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
  return 0;
 228:	4501                	li	a0,0
 22a:	bfdd                	j	220 <strchr+0x1c>

000000000000022c <gets>:

char*
gets(char *buf, int max)
{
 22c:	711d                	addi	sp,sp,-96
 22e:	ec86                	sd	ra,88(sp)
 230:	e8a2                	sd	s0,80(sp)
 232:	e4a6                	sd	s1,72(sp)
 234:	e0ca                	sd	s2,64(sp)
 236:	fc4e                	sd	s3,56(sp)
 238:	f852                	sd	s4,48(sp)
 23a:	f456                	sd	s5,40(sp)
 23c:	f05a                	sd	s6,32(sp)
 23e:	ec5e                	sd	s7,24(sp)
 240:	e862                	sd	s8,16(sp)
 242:	1080                	addi	s0,sp,96
 244:	8baa                	mv	s7,a0
 246:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 248:	892a                	mv	s2,a0
 24a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 24c:	faf40b13          	addi	s6,s0,-81
 250:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 252:	8c26                	mv	s8,s1
 254:	0014899b          	addiw	s3,s1,1
 258:	84ce                	mv	s1,s3
 25a:	0349d463          	bge	s3,s4,282 <gets+0x56>
    cc = read(0, &c, 1);
 25e:	8656                	mv	a2,s5
 260:	85da                	mv	a1,s6
 262:	4501                	li	a0,0
 264:	1bc000ef          	jal	420 <read>
    if(cc < 1)
 268:	00a05d63          	blez	a0,282 <gets+0x56>
      break;
    buf[i++] = c;
 26c:	faf44783          	lbu	a5,-81(s0)
 270:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 274:	0905                	addi	s2,s2,1
 276:	ff678713          	addi	a4,a5,-10
 27a:	c319                	beqz	a4,280 <gets+0x54>
 27c:	17cd                	addi	a5,a5,-13
 27e:	fbf1                	bnez	a5,252 <gets+0x26>
    buf[i++] = c;
 280:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 282:	9c5e                	add	s8,s8,s7
 284:	000c0023          	sb	zero,0(s8)
  return buf;
}
 288:	855e                	mv	a0,s7
 28a:	60e6                	ld	ra,88(sp)
 28c:	6446                	ld	s0,80(sp)
 28e:	64a6                	ld	s1,72(sp)
 290:	6906                	ld	s2,64(sp)
 292:	79e2                	ld	s3,56(sp)
 294:	7a42                	ld	s4,48(sp)
 296:	7aa2                	ld	s5,40(sp)
 298:	7b02                	ld	s6,32(sp)
 29a:	6be2                	ld	s7,24(sp)
 29c:	6c42                	ld	s8,16(sp)
 29e:	6125                	addi	sp,sp,96
 2a0:	8082                	ret

00000000000002a2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a2:	1101                	addi	sp,sp,-32
 2a4:	ec06                	sd	ra,24(sp)
 2a6:	e822                	sd	s0,16(sp)
 2a8:	e04a                	sd	s2,0(sp)
 2aa:	1000                	addi	s0,sp,32
 2ac:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ae:	4581                	li	a1,0
 2b0:	198000ef          	jal	448 <open>
  if(fd < 0)
 2b4:	02054263          	bltz	a0,2d8 <stat+0x36>
 2b8:	e426                	sd	s1,8(sp)
 2ba:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2bc:	85ca                	mv	a1,s2
 2be:	1a2000ef          	jal	460 <fstat>
 2c2:	892a                	mv	s2,a0
  close(fd);
 2c4:	8526                	mv	a0,s1
 2c6:	16a000ef          	jal	430 <close>
  return r;
 2ca:	64a2                	ld	s1,8(sp)
}
 2cc:	854a                	mv	a0,s2
 2ce:	60e2                	ld	ra,24(sp)
 2d0:	6442                	ld	s0,16(sp)
 2d2:	6902                	ld	s2,0(sp)
 2d4:	6105                	addi	sp,sp,32
 2d6:	8082                	ret
    return -1;
 2d8:	57fd                	li	a5,-1
 2da:	893e                	mv	s2,a5
 2dc:	bfc5                	j	2cc <stat+0x2a>

00000000000002de <atoi>:

int
atoi(const char *s)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e406                	sd	ra,8(sp)
 2e2:	e022                	sd	s0,0(sp)
 2e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e6:	00054683          	lbu	a3,0(a0)
 2ea:	fd06879b          	addiw	a5,a3,-48
 2ee:	0ff7f793          	zext.b	a5,a5
 2f2:	4625                	li	a2,9
 2f4:	02f66963          	bltu	a2,a5,326 <atoi+0x48>
 2f8:	872a                	mv	a4,a0
  n = 0;
 2fa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2fc:	0705                	addi	a4,a4,1
 2fe:	0025179b          	slliw	a5,a0,0x2
 302:	9fa9                	addw	a5,a5,a0
 304:	0017979b          	slliw	a5,a5,0x1
 308:	9fb5                	addw	a5,a5,a3
 30a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30e:	00074683          	lbu	a3,0(a4)
 312:	fd06879b          	addiw	a5,a3,-48
 316:	0ff7f793          	zext.b	a5,a5
 31a:	fef671e3          	bgeu	a2,a5,2fc <atoi+0x1e>
  return n;
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  n = 0;
 326:	4501                	li	a0,0
 328:	bfdd                	j	31e <atoi+0x40>

000000000000032a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 332:	02b57563          	bgeu	a0,a1,35c <memmove+0x32>
    while(n-- > 0)
 336:	00c05f63          	blez	a2,354 <memmove+0x2a>
 33a:	1602                	slli	a2,a2,0x20
 33c:	9201                	srli	a2,a2,0x20
 33e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 342:	872a                	mv	a4,a0
      *dst++ = *src++;
 344:	0585                	addi	a1,a1,1
 346:	0705                	addi	a4,a4,1
 348:	fff5c683          	lbu	a3,-1(a1)
 34c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 350:	fee79ae3          	bne	a5,a4,344 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
    while(n-- > 0)
 35c:	fec05ce3          	blez	a2,354 <memmove+0x2a>
    dst += n;
 360:	00c50733          	add	a4,a0,a2
    src += n;
 364:	95b2                	add	a1,a1,a2
 366:	fff6079b          	addiw	a5,a2,-1
 36a:	1782                	slli	a5,a5,0x20
 36c:	9381                	srli	a5,a5,0x20
 36e:	fff7c793          	not	a5,a5
 372:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 374:	15fd                	addi	a1,a1,-1
 376:	177d                	addi	a4,a4,-1
 378:	0005c683          	lbu	a3,0(a1)
 37c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 380:	fef71ae3          	bne	a4,a5,374 <memmove+0x4a>
 384:	bfc1                	j	354 <memmove+0x2a>

0000000000000386 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38e:	c61d                	beqz	a2,3bc <memcmp+0x36>
 390:	1602                	slli	a2,a2,0x20
 392:	9201                	srli	a2,a2,0x20
 394:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 398:	00054783          	lbu	a5,0(a0)
 39c:	0005c703          	lbu	a4,0(a1)
 3a0:	00e79863          	bne	a5,a4,3b0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3a4:	0505                	addi	a0,a0,1
    p2++;
 3a6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a8:	fed518e3          	bne	a0,a3,398 <memcmp+0x12>
  }
  return 0;
 3ac:	4501                	li	a0,0
 3ae:	a019                	j	3b4 <memcmp+0x2e>
      return *p1 - *p2;
 3b0:	40e7853b          	subw	a0,a5,a4
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  return 0;
 3bc:	4501                	li	a0,0
 3be:	bfdd                	j	3b4 <memcmp+0x2e>

00000000000003c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c8:	f63ff0ef          	jal	32a <memmove>
}
 3cc:	60a2                	ld	ra,8(sp)
 3ce:	6402                	ld	s0,0(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret

00000000000003d4 <sbrk>:

char *
sbrk(int n) {
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e406                	sd	ra,8(sp)
 3d8:	e022                	sd	s0,0(sp)
 3da:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3dc:	4585                	li	a1,1
 3de:	0b2000ef          	jal	490 <sys_sbrk>
}
 3e2:	60a2                	ld	ra,8(sp)
 3e4:	6402                	ld	s0,0(sp)
 3e6:	0141                	addi	sp,sp,16
 3e8:	8082                	ret

00000000000003ea <sbrklazy>:

char *
sbrklazy(int n) {
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e406                	sd	ra,8(sp)
 3ee:	e022                	sd	s0,0(sp)
 3f0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3f2:	4589                	li	a1,2
 3f4:	09c000ef          	jal	490 <sys_sbrk>
}
 3f8:	60a2                	ld	ra,8(sp)
 3fa:	6402                	ld	s0,0(sp)
 3fc:	0141                	addi	sp,sp,16
 3fe:	8082                	ret

0000000000000400 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 400:	4885                	li	a7,1
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <exit>:
.global exit
exit:
 li a7, SYS_exit
 408:	4889                	li	a7,2
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <wait>:
.global wait
wait:
 li a7, SYS_wait
 410:	488d                	li	a7,3
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 418:	4891                	li	a7,4
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <read>:
.global read
read:
 li a7, SYS_read
 420:	4895                	li	a7,5
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <write>:
.global write
write:
 li a7, SYS_write
 428:	48c1                	li	a7,16
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <close>:
.global close
close:
 li a7, SYS_close
 430:	48d5                	li	a7,21
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <kill>:
.global kill
kill:
 li a7, SYS_kill
 438:	4899                	li	a7,6
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <exec>:
.global exec
exec:
 li a7, SYS_exec
 440:	489d                	li	a7,7
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <open>:
.global open
open:
 li a7, SYS_open
 448:	48bd                	li	a7,15
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 450:	48c5                	li	a7,17
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 458:	48c9                	li	a7,18
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 460:	48a1                	li	a7,8
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <link>:
.global link
link:
 li a7, SYS_link
 468:	48cd                	li	a7,19
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 470:	48d1                	li	a7,20
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 478:	48a5                	li	a7,9
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <dup>:
.global dup
dup:
 li a7, SYS_dup
 480:	48a9                	li	a7,10
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 488:	48ad                	li	a7,11
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 490:	48b1                	li	a7,12
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <pause>:
.global pause
pause:
 li a7, SYS_pause
 498:	48b5                	li	a7,13
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a0:	48b9                	li	a7,14
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4a8:	48d9                	li	a7,22
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4b0:	48dd                	li	a7,23
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b8:	1101                	addi	sp,sp,-32
 4ba:	ec06                	sd	ra,24(sp)
 4bc:	e822                	sd	s0,16(sp)
 4be:	1000                	addi	s0,sp,32
 4c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c4:	4605                	li	a2,1
 4c6:	fef40593          	addi	a1,s0,-17
 4ca:	f5fff0ef          	jal	428 <write>
}
 4ce:	60e2                	ld	ra,24(sp)
 4d0:	6442                	ld	s0,16(sp)
 4d2:	6105                	addi	sp,sp,32
 4d4:	8082                	ret

00000000000004d6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4d6:	715d                	addi	sp,sp,-80
 4d8:	e486                	sd	ra,72(sp)
 4da:	e0a2                	sd	s0,64(sp)
 4dc:	f84a                	sd	s2,48(sp)
 4de:	f44e                	sd	s3,40(sp)
 4e0:	0880                	addi	s0,sp,80
 4e2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4e4:	c6d1                	beqz	a3,570 <printint+0x9a>
 4e6:	0805d563          	bgez	a1,570 <printint+0x9a>
    neg = 1;
    x = -xx;
 4ea:	40b005b3          	neg	a1,a1
    neg = 1;
 4ee:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4f0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4f4:	86ce                	mv	a3,s3
  i = 0;
 4f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f8:	00000817          	auipc	a6,0x0
 4fc:	72880813          	addi	a6,a6,1832 # c20 <digits>
 500:	88ba                	mv	a7,a4
 502:	0017051b          	addiw	a0,a4,1
 506:	872a                	mv	a4,a0
 508:	02c5f7b3          	remu	a5,a1,a2
 50c:	97c2                	add	a5,a5,a6
 50e:	0007c783          	lbu	a5,0(a5)
 512:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 516:	87ae                	mv	a5,a1
 518:	02c5d5b3          	divu	a1,a1,a2
 51c:	0685                	addi	a3,a3,1
 51e:	fec7f1e3          	bgeu	a5,a2,500 <printint+0x2a>
  if(neg)
 522:	00030c63          	beqz	t1,53a <printint+0x64>
    buf[i++] = '-';
 526:	fd050793          	addi	a5,a0,-48
 52a:	00878533          	add	a0,a5,s0
 52e:	02d00793          	li	a5,45
 532:	fef50423          	sb	a5,-24(a0)
 536:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 53a:	02e05563          	blez	a4,564 <printint+0x8e>
 53e:	fc26                	sd	s1,56(sp)
 540:	377d                	addiw	a4,a4,-1
 542:	00e984b3          	add	s1,s3,a4
 546:	19fd                	addi	s3,s3,-1
 548:	99ba                	add	s3,s3,a4
 54a:	1702                	slli	a4,a4,0x20
 54c:	9301                	srli	a4,a4,0x20
 54e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 552:	0004c583          	lbu	a1,0(s1)
 556:	854a                	mv	a0,s2
 558:	f61ff0ef          	jal	4b8 <putc>
  while(--i >= 0)
 55c:	14fd                	addi	s1,s1,-1
 55e:	ff349ae3          	bne	s1,s3,552 <printint+0x7c>
 562:	74e2                	ld	s1,56(sp)
}
 564:	60a6                	ld	ra,72(sp)
 566:	6406                	ld	s0,64(sp)
 568:	7942                	ld	s2,48(sp)
 56a:	79a2                	ld	s3,40(sp)
 56c:	6161                	addi	sp,sp,80
 56e:	8082                	ret
  neg = 0;
 570:	4301                	li	t1,0
 572:	bfbd                	j	4f0 <printint+0x1a>

0000000000000574 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 574:	711d                	addi	sp,sp,-96
 576:	ec86                	sd	ra,88(sp)
 578:	e8a2                	sd	s0,80(sp)
 57a:	e4a6                	sd	s1,72(sp)
 57c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57e:	0005c483          	lbu	s1,0(a1)
 582:	22048363          	beqz	s1,7a8 <vprintf+0x234>
 586:	e0ca                	sd	s2,64(sp)
 588:	fc4e                	sd	s3,56(sp)
 58a:	f852                	sd	s4,48(sp)
 58c:	f456                	sd	s5,40(sp)
 58e:	f05a                	sd	s6,32(sp)
 590:	ec5e                	sd	s7,24(sp)
 592:	e862                	sd	s8,16(sp)
 594:	8b2a                	mv	s6,a0
 596:	8a2e                	mv	s4,a1
 598:	8bb2                	mv	s7,a2
  state = 0;
 59a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 59c:	4901                	li	s2,0
 59e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5a0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5a4:	06400c13          	li	s8,100
 5a8:	a00d                	j	5ca <vprintf+0x56>
        putc(fd, c0);
 5aa:	85a6                	mv	a1,s1
 5ac:	855a                	mv	a0,s6
 5ae:	f0bff0ef          	jal	4b8 <putc>
 5b2:	a019                	j	5b8 <vprintf+0x44>
    } else if(state == '%'){
 5b4:	03598363          	beq	s3,s5,5da <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5b8:	0019079b          	addiw	a5,s2,1
 5bc:	893e                	mv	s2,a5
 5be:	873e                	mv	a4,a5
 5c0:	97d2                	add	a5,a5,s4
 5c2:	0007c483          	lbu	s1,0(a5)
 5c6:	1c048a63          	beqz	s1,79a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5ca:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5ce:	fe0993e3          	bnez	s3,5b4 <vprintf+0x40>
      if(c0 == '%'){
 5d2:	fd579ce3          	bne	a5,s5,5aa <vprintf+0x36>
        state = '%';
 5d6:	89be                	mv	s3,a5
 5d8:	b7c5                	j	5b8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5da:	00ea06b3          	add	a3,s4,a4
 5de:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5e2:	1c060863          	beqz	a2,7b2 <vprintf+0x23e>
      if(c0 == 'd'){
 5e6:	03878763          	beq	a5,s8,614 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5ea:	f9478693          	addi	a3,a5,-108
 5ee:	0016b693          	seqz	a3,a3
 5f2:	f9c60593          	addi	a1,a2,-100
 5f6:	e99d                	bnez	a1,62c <vprintf+0xb8>
 5f8:	ca95                	beqz	a3,62c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fa:	008b8493          	addi	s1,s7,8
 5fe:	4685                	li	a3,1
 600:	4629                	li	a2,10
 602:	000bb583          	ld	a1,0(s7)
 606:	855a                	mv	a0,s6
 608:	ecfff0ef          	jal	4d6 <printint>
        i += 1;
 60c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 60e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 610:	4981                	li	s3,0
 612:	b75d                	j	5b8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 614:	008b8493          	addi	s1,s7,8
 618:	4685                	li	a3,1
 61a:	4629                	li	a2,10
 61c:	000ba583          	lw	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	eb5ff0ef          	jal	4d6 <printint>
 626:	8ba6                	mv	s7,s1
      state = 0;
 628:	4981                	li	s3,0
 62a:	b779                	j	5b8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 62c:	9752                	add	a4,a4,s4
 62e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 632:	f9460713          	addi	a4,a2,-108
 636:	00173713          	seqz	a4,a4
 63a:	8f75                	and	a4,a4,a3
 63c:	f9c58513          	addi	a0,a1,-100
 640:	18051363          	bnez	a0,7c6 <vprintf+0x252>
 644:	18070163          	beqz	a4,7c6 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	008b8493          	addi	s1,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e81ff0ef          	jal	4d6 <printint>
        i += 2;
 65a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	8ba6                	mv	s7,s1
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	bfa1                	j	5b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 662:	008b8493          	addi	s1,s7,8
 666:	4681                	li	a3,0
 668:	4629                	li	a2,10
 66a:	000be583          	lwu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	e67ff0ef          	jal	4d6 <printint>
 674:	8ba6                	mv	s7,s1
      state = 0;
 676:	4981                	li	s3,0
 678:	b781                	j	5b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67a:	008b8493          	addi	s1,s7,8
 67e:	4681                	li	a3,0
 680:	4629                	li	a2,10
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	e4fff0ef          	jal	4d6 <printint>
        i += 1;
 68c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	8ba6                	mv	s7,s1
      state = 0;
 690:	4981                	li	s3,0
 692:	b71d                	j	5b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 694:	008b8493          	addi	s1,s7,8
 698:	4681                	li	a3,0
 69a:	4629                	li	a2,10
 69c:	000bb583          	ld	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	e35ff0ef          	jal	4d6 <printint>
        i += 2;
 6a6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a8:	8ba6                	mv	s7,s1
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	b731                	j	5b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ae:	008b8493          	addi	s1,s7,8
 6b2:	4681                	li	a3,0
 6b4:	4641                	li	a2,16
 6b6:	000be583          	lwu	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	e1bff0ef          	jal	4d6 <printint>
 6c0:	8ba6                	mv	s7,s1
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bdd5                	j	5b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c6:	008b8493          	addi	s1,s7,8
 6ca:	4681                	li	a3,0
 6cc:	4641                	li	a2,16
 6ce:	000bb583          	ld	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	e03ff0ef          	jal	4d6 <printint>
        i += 1;
 6d8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	8ba6                	mv	s7,s1
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bde9                	j	5b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e0:	008b8493          	addi	s1,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4641                	li	a2,16
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	de9ff0ef          	jal	4d6 <printint>
        i += 2;
 6f2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f4:	8ba6                	mv	s7,s1
      state = 0;
 6f6:	4981                	li	s3,0
        i += 2;
 6f8:	b5c1                	j	5b8 <vprintf+0x44>
 6fa:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6fc:	008b8793          	addi	a5,s7,8
 700:	8cbe                	mv	s9,a5
 702:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 706:	03000593          	li	a1,48
 70a:	855a                	mv	a0,s6
 70c:	dadff0ef          	jal	4b8 <putc>
  putc(fd, 'x');
 710:	07800593          	li	a1,120
 714:	855a                	mv	a0,s6
 716:	da3ff0ef          	jal	4b8 <putc>
 71a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71c:	00000b97          	auipc	s7,0x0
 720:	504b8b93          	addi	s7,s7,1284 # c20 <digits>
 724:	03c9d793          	srli	a5,s3,0x3c
 728:	97de                	add	a5,a5,s7
 72a:	0007c583          	lbu	a1,0(a5)
 72e:	855a                	mv	a0,s6
 730:	d89ff0ef          	jal	4b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 734:	0992                	slli	s3,s3,0x4
 736:	34fd                	addiw	s1,s1,-1
 738:	f4f5                	bnez	s1,724 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 73a:	8be6                	mv	s7,s9
      state = 0;
 73c:	4981                	li	s3,0
 73e:	6ca2                	ld	s9,8(sp)
 740:	bda5                	j	5b8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 742:	008b8493          	addi	s1,s7,8
 746:	000bc583          	lbu	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	d6dff0ef          	jal	4b8 <putc>
 750:	8ba6                	mv	s7,s1
      state = 0;
 752:	4981                	li	s3,0
 754:	b595                	j	5b8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 756:	008b8993          	addi	s3,s7,8
 75a:	000bb483          	ld	s1,0(s7)
 75e:	cc91                	beqz	s1,77a <vprintf+0x206>
        for(; *s; s++)
 760:	0004c583          	lbu	a1,0(s1)
 764:	c985                	beqz	a1,794 <vprintf+0x220>
          putc(fd, *s);
 766:	855a                	mv	a0,s6
 768:	d51ff0ef          	jal	4b8 <putc>
        for(; *s; s++)
 76c:	0485                	addi	s1,s1,1
 76e:	0004c583          	lbu	a1,0(s1)
 772:	f9f5                	bnez	a1,766 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 774:	8bce                	mv	s7,s3
      state = 0;
 776:	4981                	li	s3,0
 778:	b581                	j	5b8 <vprintf+0x44>
          s = "(null)";
 77a:	00000497          	auipc	s1,0x0
 77e:	49e48493          	addi	s1,s1,1182 # c18 <malloc+0x302>
        for(; *s; s++)
 782:	02800593          	li	a1,40
 786:	b7c5                	j	766 <vprintf+0x1f2>
        putc(fd, '%');
 788:	85be                	mv	a1,a5
 78a:	855a                	mv	a0,s6
 78c:	d2dff0ef          	jal	4b8 <putc>
      state = 0;
 790:	4981                	li	s3,0
 792:	b51d                	j	5b8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 794:	8bce                	mv	s7,s3
      state = 0;
 796:	4981                	li	s3,0
 798:	b505                	j	5b8 <vprintf+0x44>
 79a:	6906                	ld	s2,64(sp)
 79c:	79e2                	ld	s3,56(sp)
 79e:	7a42                	ld	s4,48(sp)
 7a0:	7aa2                	ld	s5,40(sp)
 7a2:	7b02                	ld	s6,32(sp)
 7a4:	6be2                	ld	s7,24(sp)
 7a6:	6c42                	ld	s8,16(sp)
    }
  }
}
 7a8:	60e6                	ld	ra,88(sp)
 7aa:	6446                	ld	s0,80(sp)
 7ac:	64a6                	ld	s1,72(sp)
 7ae:	6125                	addi	sp,sp,96
 7b0:	8082                	ret
      if(c0 == 'd'){
 7b2:	06400713          	li	a4,100
 7b6:	e4e78fe3          	beq	a5,a4,614 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7ba:	f9478693          	addi	a3,a5,-108
 7be:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7c2:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7c4:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7c6:	07500513          	li	a0,117
 7ca:	e8a78ce3          	beq	a5,a0,662 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7ce:	f8b60513          	addi	a0,a2,-117
 7d2:	e119                	bnez	a0,7d8 <vprintf+0x264>
 7d4:	ea0693e3          	bnez	a3,67a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7d8:	f8b58513          	addi	a0,a1,-117
 7dc:	e119                	bnez	a0,7e2 <vprintf+0x26e>
 7de:	ea071be3          	bnez	a4,694 <vprintf+0x120>
      } else if(c0 == 'x'){
 7e2:	07800513          	li	a0,120
 7e6:	eca784e3          	beq	a5,a0,6ae <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7ea:	f8860613          	addi	a2,a2,-120
 7ee:	e219                	bnez	a2,7f4 <vprintf+0x280>
 7f0:	ec069be3          	bnez	a3,6c6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7f4:	f8858593          	addi	a1,a1,-120
 7f8:	e199                	bnez	a1,7fe <vprintf+0x28a>
 7fa:	ee0713e3          	bnez	a4,6e0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 7fe:	07000713          	li	a4,112
 802:	eee78ce3          	beq	a5,a4,6fa <vprintf+0x186>
      } else if(c0 == 'c'){
 806:	06300713          	li	a4,99
 80a:	f2e78ce3          	beq	a5,a4,742 <vprintf+0x1ce>
      } else if(c0 == 's'){
 80e:	07300713          	li	a4,115
 812:	f4e782e3          	beq	a5,a4,756 <vprintf+0x1e2>
      } else if(c0 == '%'){
 816:	02500713          	li	a4,37
 81a:	f6e787e3          	beq	a5,a4,788 <vprintf+0x214>
        putc(fd, '%');
 81e:	02500593          	li	a1,37
 822:	855a                	mv	a0,s6
 824:	c95ff0ef          	jal	4b8 <putc>
        putc(fd, c0);
 828:	85a6                	mv	a1,s1
 82a:	855a                	mv	a0,s6
 82c:	c8dff0ef          	jal	4b8 <putc>
      state = 0;
 830:	4981                	li	s3,0
 832:	b359                	j	5b8 <vprintf+0x44>

0000000000000834 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 834:	715d                	addi	sp,sp,-80
 836:	ec06                	sd	ra,24(sp)
 838:	e822                	sd	s0,16(sp)
 83a:	1000                	addi	s0,sp,32
 83c:	e010                	sd	a2,0(s0)
 83e:	e414                	sd	a3,8(s0)
 840:	e818                	sd	a4,16(s0)
 842:	ec1c                	sd	a5,24(s0)
 844:	03043023          	sd	a6,32(s0)
 848:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 84c:	8622                	mv	a2,s0
 84e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 852:	d23ff0ef          	jal	574 <vprintf>
}
 856:	60e2                	ld	ra,24(sp)
 858:	6442                	ld	s0,16(sp)
 85a:	6161                	addi	sp,sp,80
 85c:	8082                	ret

000000000000085e <printf>:

void
printf(const char *fmt, ...)
{
 85e:	711d                	addi	sp,sp,-96
 860:	ec06                	sd	ra,24(sp)
 862:	e822                	sd	s0,16(sp)
 864:	1000                	addi	s0,sp,32
 866:	e40c                	sd	a1,8(s0)
 868:	e810                	sd	a2,16(s0)
 86a:	ec14                	sd	a3,24(s0)
 86c:	f018                	sd	a4,32(s0)
 86e:	f41c                	sd	a5,40(s0)
 870:	03043823          	sd	a6,48(s0)
 874:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 878:	00840613          	addi	a2,s0,8
 87c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 880:	85aa                	mv	a1,a0
 882:	4505                	li	a0,1
 884:	cf1ff0ef          	jal	574 <vprintf>
}
 888:	60e2                	ld	ra,24(sp)
 88a:	6442                	ld	s0,16(sp)
 88c:	6125                	addi	sp,sp,96
 88e:	8082                	ret

0000000000000890 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 890:	1141                	addi	sp,sp,-16
 892:	e406                	sd	ra,8(sp)
 894:	e022                	sd	s0,0(sp)
 896:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 898:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89c:	00000797          	auipc	a5,0x0
 8a0:	7647b783          	ld	a5,1892(a5) # 1000 <freep>
 8a4:	a039                	j	8b2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a6:	6398                	ld	a4,0(a5)
 8a8:	00e7e463          	bltu	a5,a4,8b0 <free+0x20>
 8ac:	00e6ea63          	bltu	a3,a4,8c0 <free+0x30>
{
 8b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b2:	fed7fae3          	bgeu	a5,a3,8a6 <free+0x16>
 8b6:	6398                	ld	a4,0(a5)
 8b8:	00e6e463          	bltu	a3,a4,8c0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8bc:	fee7eae3          	bltu	a5,a4,8b0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8c0:	ff852583          	lw	a1,-8(a0)
 8c4:	6390                	ld	a2,0(a5)
 8c6:	02059813          	slli	a6,a1,0x20
 8ca:	01c85713          	srli	a4,a6,0x1c
 8ce:	9736                	add	a4,a4,a3
 8d0:	02e60563          	beq	a2,a4,8fa <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8d4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8d8:	4790                	lw	a2,8(a5)
 8da:	02061593          	slli	a1,a2,0x20
 8de:	01c5d713          	srli	a4,a1,0x1c
 8e2:	973e                	add	a4,a4,a5
 8e4:	02e68263          	beq	a3,a4,908 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8e8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	70f73b23          	sd	a5,1814(a4) # 1000 <freep>
}
 8f2:	60a2                	ld	ra,8(sp)
 8f4:	6402                	ld	s0,0(sp)
 8f6:	0141                	addi	sp,sp,16
 8f8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8fa:	4618                	lw	a4,8(a2)
 8fc:	9f2d                	addw	a4,a4,a1
 8fe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 902:	6398                	ld	a4,0(a5)
 904:	6310                	ld	a2,0(a4)
 906:	b7f9                	j	8d4 <free+0x44>
    p->s.size += bp->s.size;
 908:	ff852703          	lw	a4,-8(a0)
 90c:	9f31                	addw	a4,a4,a2
 90e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 910:	ff053683          	ld	a3,-16(a0)
 914:	bfd1                	j	8e8 <free+0x58>

0000000000000916 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 916:	7139                	addi	sp,sp,-64
 918:	fc06                	sd	ra,56(sp)
 91a:	f822                	sd	s0,48(sp)
 91c:	f04a                	sd	s2,32(sp)
 91e:	ec4e                	sd	s3,24(sp)
 920:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 922:	02051993          	slli	s3,a0,0x20
 926:	0209d993          	srli	s3,s3,0x20
 92a:	09bd                	addi	s3,s3,15
 92c:	0049d993          	srli	s3,s3,0x4
 930:	2985                	addiw	s3,s3,1
 932:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 934:	00000517          	auipc	a0,0x0
 938:	6cc53503          	ld	a0,1740(a0) # 1000 <freep>
 93c:	c905                	beqz	a0,96c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 940:	4798                	lw	a4,8(a5)
 942:	09377663          	bgeu	a4,s3,9ce <malloc+0xb8>
 946:	f426                	sd	s1,40(sp)
 948:	e852                	sd	s4,16(sp)
 94a:	e456                	sd	s5,8(sp)
 94c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 94e:	8a4e                	mv	s4,s3
 950:	6705                	lui	a4,0x1
 952:	00e9f363          	bgeu	s3,a4,958 <malloc+0x42>
 956:	6a05                	lui	s4,0x1
 958:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 95c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 960:	00000497          	auipc	s1,0x0
 964:	6a048493          	addi	s1,s1,1696 # 1000 <freep>
  if(p == SBRK_ERROR)
 968:	5afd                	li	s5,-1
 96a:	a83d                	j	9a8 <malloc+0x92>
 96c:	f426                	sd	s1,40(sp)
 96e:	e852                	sd	s4,16(sp)
 970:	e456                	sd	s5,8(sp)
 972:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 974:	00000797          	auipc	a5,0x0
 978:	69c78793          	addi	a5,a5,1692 # 1010 <base>
 97c:	00000717          	auipc	a4,0x0
 980:	68f73223          	sd	a5,1668(a4) # 1000 <freep>
 984:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 986:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 98a:	b7d1                	j	94e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 98c:	6398                	ld	a4,0(a5)
 98e:	e118                	sd	a4,0(a0)
 990:	a899                	j	9e6 <malloc+0xd0>
  hp->s.size = nu;
 992:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 996:	0541                	addi	a0,a0,16
 998:	ef9ff0ef          	jal	890 <free>
  return freep;
 99c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 99e:	c125                	beqz	a0,9fe <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a2:	4798                	lw	a4,8(a5)
 9a4:	03277163          	bgeu	a4,s2,9c6 <malloc+0xb0>
    if(p == freep)
 9a8:	6098                	ld	a4,0(s1)
 9aa:	853e                	mv	a0,a5
 9ac:	fef71ae3          	bne	a4,a5,9a0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9b0:	8552                	mv	a0,s4
 9b2:	a23ff0ef          	jal	3d4 <sbrk>
  if(p == SBRK_ERROR)
 9b6:	fd551ee3          	bne	a0,s5,992 <malloc+0x7c>
        return 0;
 9ba:	4501                	li	a0,0
 9bc:	74a2                	ld	s1,40(sp)
 9be:	6a42                	ld	s4,16(sp)
 9c0:	6aa2                	ld	s5,8(sp)
 9c2:	6b02                	ld	s6,0(sp)
 9c4:	a03d                	j	9f2 <malloc+0xdc>
 9c6:	74a2                	ld	s1,40(sp)
 9c8:	6a42                	ld	s4,16(sp)
 9ca:	6aa2                	ld	s5,8(sp)
 9cc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9ce:	fae90fe3          	beq	s2,a4,98c <malloc+0x76>
        p->s.size -= nunits;
 9d2:	4137073b          	subw	a4,a4,s3
 9d6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d8:	02071693          	slli	a3,a4,0x20
 9dc:	01c6d713          	srli	a4,a3,0x1c
 9e0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9e2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e6:	00000717          	auipc	a4,0x0
 9ea:	60a73d23          	sd	a0,1562(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ee:	01078513          	addi	a0,a5,16
  }
}
 9f2:	70e2                	ld	ra,56(sp)
 9f4:	7442                	ld	s0,48(sp)
 9f6:	7902                	ld	s2,32(sp)
 9f8:	69e2                	ld	s3,24(sp)
 9fa:	6121                	addi	sp,sp,64
 9fc:	8082                	ret
 9fe:	74a2                	ld	s1,40(sp)
 a00:	6a42                	ld	s4,16(sp)
 a02:	6aa2                	ld	s5,8(sp)
 a04:	6b02                	ld	s6,0(sp)
 a06:	b7f5                	j	9f2 <malloc+0xdc>
