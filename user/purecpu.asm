
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
  10:	9a450513          	addi	a0,a0,-1628 # 9b0 <malloc+0xf8>
  14:	7f0000ef          	jal	804 <printf>
  
  if(getprocinfo(&info) == 0) {
  18:	fe040513          	addi	a0,s0,-32
  1c:	450000ef          	jal	46c <getprocinfo>
  20:	c50d                	beqz	a0,4a <main+0x4a>
    printf("Starting: PID=%d, Q%d, slices=%d\n\n", 
           info.pid, info.priority, info.time_slices);
  }
  
  printf("Running continuous CPU work (no interruptions)...\n");
  22:	00001517          	auipc	a0,0x1
  26:	9d650513          	addi	a0,a0,-1578 # 9f8 <malloc+0x140>
  2a:	7da000ef          	jal	804 <printf>
  printf("This will take several seconds...\n\n");
  2e:	00001517          	auipc	a0,0x1
  32:	a0250513          	addi	a0,a0,-1534 # a30 <malloc+0x178>
  36:	7ce000ef          	jal	804 <printf>
  
  // Do MASSIVE amount of work without any syscalls
  // Increased significantly to trigger multiple demotions
  for(int i = 0; i < 500000000; i++) {
  3a:	4781                	li	a5,0
    dummy = dummy + i;
    // Add more computation to slow it down
    if(i % 1000 == 0) {
  3c:	3e800593          	li	a1,1000
  for(int i = 0; i < 500000000; i++) {
  40:	1dcd6637          	lui	a2,0x1dcd6
  44:	50060613          	addi	a2,a2,1280 # 1dcd6500 <base+0x1dcd44f0>
  48:	a00d                	j	6a <main+0x6a>
    printf("Starting: PID=%d, Q%d, slices=%d\n\n", 
  4a:	fec42683          	lw	a3,-20(s0)
  4e:	fe842603          	lw	a2,-24(s0)
  52:	fe042583          	lw	a1,-32(s0)
  56:	00001517          	auipc	a0,0x1
  5a:	97a50513          	addi	a0,a0,-1670 # 9d0 <malloc+0x118>
  5e:	7a6000ef          	jal	804 <printf>
  62:	b7c1                	j	22 <main+0x22>
  for(int i = 0; i < 500000000; i++) {
  64:	2785                	addiw	a5,a5,1
  66:	02c78a63          	beq	a5,a2,9a <main+0x9a>
    dummy = dummy + i;
  6a:	fdc42703          	lw	a4,-36(s0)
  6e:	9f3d                	addw	a4,a4,a5
  70:	fce42e23          	sw	a4,-36(s0)
    if(i % 1000 == 0) {
  74:	02b7e73b          	remw	a4,a5,a1
  78:	f775                	bnez	a4,64 <main+0x64>
      dummy = dummy * 2;
  7a:	fdc42703          	lw	a4,-36(s0)
  7e:	0017171b          	slliw	a4,a4,0x1
  82:	fce42e23          	sw	a4,-36(s0)
      dummy = dummy / 2;
  86:	fdc42683          	lw	a3,-36(s0)
  8a:	01f6d71b          	srliw	a4,a3,0x1f
  8e:	9f35                	addw	a4,a4,a3
  90:	4017571b          	sraiw	a4,a4,0x1
  94:	fce42e23          	sw	a4,-36(s0)
  98:	b7f1                	j	64 <main+0x64>
    }
  }
  
  printf("Work complete! Checking final state...\n\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	9be50513          	addi	a0,a0,-1602 # a58 <malloc+0x1a0>
  a2:	762000ef          	jal	804 <printf>
  
  if(getprocinfo(&info) == 0) {
  a6:	fe040513          	addi	a0,s0,-32
  aa:	3c2000ef          	jal	46c <getprocinfo>
  ae:	c501                	beqz	a0,b6 <main+0xb6>
    } else {
      printf("✗ FAILED: Still at Q0 (no demotion occurred)\n");
    }
  }
  
  exit(0);
  b0:	4501                	li	a0,0
  b2:	31a000ef          	jal	3cc <exit>
    printf("Final: PID=%d, Q%d, slices=%d\n", 
  b6:	fec42683          	lw	a3,-20(s0)
  ba:	fe842603          	lw	a2,-24(s0)
  be:	fe042583          	lw	a1,-32(s0)
  c2:	00001517          	auipc	a0,0x1
  c6:	9c650513          	addi	a0,a0,-1594 # a88 <malloc+0x1d0>
  ca:	73a000ef          	jal	804 <printf>
    printf("\nExpected behavior:\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	9da50513          	addi	a0,a0,-1574 # aa8 <malloc+0x1f0>
  d6:	72e000ef          	jal	804 <printf>
    printf("  - Should have used many timer ticks\n");
  da:	00001517          	auipc	a0,0x1
  de:	9e650513          	addi	a0,a0,-1562 # ac0 <malloc+0x208>
  e2:	722000ef          	jal	804 <printf>
    printf("  - Should have demoted through queues\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	a0250513          	addi	a0,a0,-1534 # ae8 <malloc+0x230>
  ee:	716000ef          	jal	804 <printf>
    printf("  - Should be at Q3 (or Q2/Q3)\n\n");
  f2:	00001517          	auipc	a0,0x1
  f6:	a1e50513          	addi	a0,a0,-1506 # b10 <malloc+0x258>
  fa:	70a000ef          	jal	804 <printf>
    if(info.priority >= 2) {
  fe:	fe842583          	lw	a1,-24(s0)
 102:	4785                	li	a5,1
 104:	00b7cc63          	blt	a5,a1,11c <main+0x11c>
    } else if(info.priority == 1) {
 108:	4785                	li	a5,1
 10a:	02f58063          	beq	a1,a5,12a <main+0x12a>
      printf("✗ FAILED: Still at Q0 (no demotion occurred)\n");
 10e:	00001517          	auipc	a0,0x1
 112:	a7a50513          	addi	a0,a0,-1414 # b88 <malloc+0x2d0>
 116:	6ee000ef          	jal	804 <printf>
 11a:	bf59                	j	b0 <main+0xb0>
      printf("✓ SUCCESS: Demoted to Q%d\n", info.priority);
 11c:	00001517          	auipc	a0,0x1
 120:	a1c50513          	addi	a0,a0,-1508 # b38 <malloc+0x280>
 124:	6e0000ef          	jal	804 <printf>
 128:	b761                	j	b0 <main+0xb0>
      printf("~ PARTIAL: Only reached Q1 (expected Q2 or Q3)\n");
 12a:	00001517          	auipc	a0,0x1
 12e:	a2e50513          	addi	a0,a0,-1490 # b58 <malloc+0x2a0>
 132:	6d2000ef          	jal	804 <printf>
 136:	bfad                	j	b0 <main+0xb0>

0000000000000138 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e406                	sd	ra,8(sp)
 13c:	e022                	sd	s0,0(sp)
 13e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 140:	ec1ff0ef          	jal	0 <main>
  exit(r);
 144:	288000ef          	jal	3cc <exit>

0000000000000148 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 14e:	87aa                	mv	a5,a0
 150:	0585                	addi	a1,a1,1
 152:	0785                	addi	a5,a5,1
 154:	fff5c703          	lbu	a4,-1(a1)
 158:	fee78fa3          	sb	a4,-1(a5)
 15c:	fb75                	bnez	a4,150 <strcpy+0x8>
    ;
  return os;
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret

0000000000000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cb91                	beqz	a5,182 <strcmp+0x1e>
 170:	0005c703          	lbu	a4,0(a1)
 174:	00f71763          	bne	a4,a5,182 <strcmp+0x1e>
    p++, q++;
 178:	0505                	addi	a0,a0,1
 17a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbe5                	bnez	a5,170 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 182:	0005c503          	lbu	a0,0(a1)
}
 186:	40a7853b          	subw	a0,a5,a0
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strlen>:

uint
strlen(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cf91                	beqz	a5,1b6 <strlen+0x26>
 19c:	0505                	addi	a0,a0,1
 19e:	87aa                	mv	a5,a0
 1a0:	86be                	mv	a3,a5
 1a2:	0785                	addi	a5,a5,1
 1a4:	fff7c703          	lbu	a4,-1(a5)
 1a8:	ff65                	bnez	a4,1a0 <strlen+0x10>
 1aa:	40a6853b          	subw	a0,a3,a0
 1ae:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret
  for(n = 0; s[n]; n++)
 1b6:	4501                	li	a0,0
 1b8:	bfe5                	j	1b0 <strlen+0x20>

00000000000001ba <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c0:	ca19                	beqz	a2,1d6 <memset+0x1c>
 1c2:	87aa                	mv	a5,a0
 1c4:	1602                	slli	a2,a2,0x20
 1c6:	9201                	srli	a2,a2,0x20
 1c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1cc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d0:	0785                	addi	a5,a5,1
 1d2:	fee79de3          	bne	a5,a4,1cc <memset+0x12>
  }
  return dst;
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret

00000000000001dc <strchr>:

char*
strchr(const char *s, char c)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cb99                	beqz	a5,1fc <strchr+0x20>
    if(*s == c)
 1e8:	00f58763          	beq	a1,a5,1f6 <strchr+0x1a>
  for(; *s; s++)
 1ec:	0505                	addi	a0,a0,1
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	fbfd                	bnez	a5,1e8 <strchr+0xc>
      return (char*)s;
  return 0;
 1f4:	4501                	li	a0,0
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  return 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <strchr+0x1a>

0000000000000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	711d                	addi	sp,sp,-96
 202:	ec86                	sd	ra,88(sp)
 204:	e8a2                	sd	s0,80(sp)
 206:	e4a6                	sd	s1,72(sp)
 208:	e0ca                	sd	s2,64(sp)
 20a:	fc4e                	sd	s3,56(sp)
 20c:	f852                	sd	s4,48(sp)
 20e:	f456                	sd	s5,40(sp)
 210:	f05a                	sd	s6,32(sp)
 212:	ec5e                	sd	s7,24(sp)
 214:	1080                	addi	s0,sp,96
 216:	8baa                	mv	s7,a0
 218:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21a:	892a                	mv	s2,a0
 21c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 21e:	4aa9                	li	s5,10
 220:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 222:	89a6                	mv	s3,s1
 224:	2485                	addiw	s1,s1,1
 226:	0344d663          	bge	s1,s4,252 <gets+0x52>
    cc = read(0, &c, 1);
 22a:	4605                	li	a2,1
 22c:	faf40593          	addi	a1,s0,-81
 230:	4501                	li	a0,0
 232:	1b2000ef          	jal	3e4 <read>
    if(cc < 1)
 236:	00a05e63          	blez	a0,252 <gets+0x52>
    buf[i++] = c;
 23a:	faf44783          	lbu	a5,-81(s0)
 23e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 242:	01578763          	beq	a5,s5,250 <gets+0x50>
 246:	0905                	addi	s2,s2,1
 248:	fd679de3          	bne	a5,s6,222 <gets+0x22>
    buf[i++] = c;
 24c:	89a6                	mv	s3,s1
 24e:	a011                	j	252 <gets+0x52>
 250:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 252:	99de                	add	s3,s3,s7
 254:	00098023          	sb	zero,0(s3)
  return buf;
}
 258:	855e                	mv	a0,s7
 25a:	60e6                	ld	ra,88(sp)
 25c:	6446                	ld	s0,80(sp)
 25e:	64a6                	ld	s1,72(sp)
 260:	6906                	ld	s2,64(sp)
 262:	79e2                	ld	s3,56(sp)
 264:	7a42                	ld	s4,48(sp)
 266:	7aa2                	ld	s5,40(sp)
 268:	7b02                	ld	s6,32(sp)
 26a:	6be2                	ld	s7,24(sp)
 26c:	6125                	addi	sp,sp,96
 26e:	8082                	ret

0000000000000270 <stat>:

int
stat(const char *n, struct stat *st)
{
 270:	1101                	addi	sp,sp,-32
 272:	ec06                	sd	ra,24(sp)
 274:	e822                	sd	s0,16(sp)
 276:	e04a                	sd	s2,0(sp)
 278:	1000                	addi	s0,sp,32
 27a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27c:	4581                	li	a1,0
 27e:	18e000ef          	jal	40c <open>
  if(fd < 0)
 282:	02054263          	bltz	a0,2a6 <stat+0x36>
 286:	e426                	sd	s1,8(sp)
 288:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 28a:	85ca                	mv	a1,s2
 28c:	198000ef          	jal	424 <fstat>
 290:	892a                	mv	s2,a0
  close(fd);
 292:	8526                	mv	a0,s1
 294:	160000ef          	jal	3f4 <close>
  return r;
 298:	64a2                	ld	s1,8(sp)
}
 29a:	854a                	mv	a0,s2
 29c:	60e2                	ld	ra,24(sp)
 29e:	6442                	ld	s0,16(sp)
 2a0:	6902                	ld	s2,0(sp)
 2a2:	6105                	addi	sp,sp,32
 2a4:	8082                	ret
    return -1;
 2a6:	597d                	li	s2,-1
 2a8:	bfcd                	j	29a <stat+0x2a>

00000000000002aa <atoi>:

int
atoi(const char *s)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b0:	00054683          	lbu	a3,0(a0)
 2b4:	fd06879b          	addiw	a5,a3,-48
 2b8:	0ff7f793          	zext.b	a5,a5
 2bc:	4625                	li	a2,9
 2be:	02f66863          	bltu	a2,a5,2ee <atoi+0x44>
 2c2:	872a                	mv	a4,a0
  n = 0;
 2c4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c6:	0705                	addi	a4,a4,1
 2c8:	0025179b          	slliw	a5,a0,0x2
 2cc:	9fa9                	addw	a5,a5,a0
 2ce:	0017979b          	slliw	a5,a5,0x1
 2d2:	9fb5                	addw	a5,a5,a3
 2d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d8:	00074683          	lbu	a3,0(a4)
 2dc:	fd06879b          	addiw	a5,a3,-48
 2e0:	0ff7f793          	zext.b	a5,a5
 2e4:	fef671e3          	bgeu	a2,a5,2c6 <atoi+0x1c>
  return n;
}
 2e8:	6422                	ld	s0,8(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  n = 0;
 2ee:	4501                	li	a0,0
 2f0:	bfe5                	j	2e8 <atoi+0x3e>

00000000000002f2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f8:	02b57463          	bgeu	a0,a1,320 <memmove+0x2e>
    while(n-- > 0)
 2fc:	00c05f63          	blez	a2,31a <memmove+0x28>
 300:	1602                	slli	a2,a2,0x20
 302:	9201                	srli	a2,a2,0x20
 304:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 308:	872a                	mv	a4,a0
      *dst++ = *src++;
 30a:	0585                	addi	a1,a1,1
 30c:	0705                	addi	a4,a4,1
 30e:	fff5c683          	lbu	a3,-1(a1)
 312:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 316:	fef71ae3          	bne	a4,a5,30a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
    dst += n;
 320:	00c50733          	add	a4,a0,a2
    src += n;
 324:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 326:	fec05ae3          	blez	a2,31a <memmove+0x28>
 32a:	fff6079b          	addiw	a5,a2,-1
 32e:	1782                	slli	a5,a5,0x20
 330:	9381                	srli	a5,a5,0x20
 332:	fff7c793          	not	a5,a5
 336:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 338:	15fd                	addi	a1,a1,-1
 33a:	177d                	addi	a4,a4,-1
 33c:	0005c683          	lbu	a3,0(a1)
 340:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 344:	fee79ae3          	bne	a5,a4,338 <memmove+0x46>
 348:	bfc9                	j	31a <memmove+0x28>

000000000000034a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 350:	ca05                	beqz	a2,380 <memcmp+0x36>
 352:	fff6069b          	addiw	a3,a2,-1
 356:	1682                	slli	a3,a3,0x20
 358:	9281                	srli	a3,a3,0x20
 35a:	0685                	addi	a3,a3,1
 35c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 35e:	00054783          	lbu	a5,0(a0)
 362:	0005c703          	lbu	a4,0(a1)
 366:	00e79863          	bne	a5,a4,376 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36a:	0505                	addi	a0,a0,1
    p2++;
 36c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 36e:	fed518e3          	bne	a0,a3,35e <memcmp+0x14>
  }
  return 0;
 372:	4501                	li	a0,0
 374:	a019                	j	37a <memcmp+0x30>
      return *p1 - *p2;
 376:	40e7853b          	subw	a0,a5,a4
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
  return 0;
 380:	4501                	li	a0,0
 382:	bfe5                	j	37a <memcmp+0x30>

0000000000000384 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38c:	f67ff0ef          	jal	2f2 <memmove>
}
 390:	60a2                	ld	ra,8(sp)
 392:	6402                	ld	s0,0(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret

0000000000000398 <sbrk>:

char *
sbrk(int n) {
 398:	1141                	addi	sp,sp,-16
 39a:	e406                	sd	ra,8(sp)
 39c:	e022                	sd	s0,0(sp)
 39e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3a0:	4585                	li	a1,1
 3a2:	0b2000ef          	jal	454 <sys_sbrk>
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret

00000000000003ae <sbrklazy>:

char *
sbrklazy(int n) {
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3b6:	4589                	li	a1,2
 3b8:	09c000ef          	jal	454 <sys_sbrk>
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c4:	4885                	li	a7,1
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3cc:	4889                	li	a7,2
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d4:	488d                	li	a7,3
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3dc:	4891                	li	a7,4
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <read>:
.global read
read:
 li a7, SYS_read
 3e4:	4895                	li	a7,5
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <write>:
.global write
write:
 li a7, SYS_write
 3ec:	48c1                	li	a7,16
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <close>:
.global close
close:
 li a7, SYS_close
 3f4:	48d5                	li	a7,21
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fc:	4899                	li	a7,6
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <exec>:
.global exec
exec:
 li a7, SYS_exec
 404:	489d                	li	a7,7
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <open>:
.global open
open:
 li a7, SYS_open
 40c:	48bd                	li	a7,15
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 414:	48c5                	li	a7,17
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41c:	48c9                	li	a7,18
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 424:	48a1                	li	a7,8
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <link>:
.global link
link:
 li a7, SYS_link
 42c:	48cd                	li	a7,19
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 434:	48d1                	li	a7,20
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43c:	48a5                	li	a7,9
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <dup>:
.global dup
dup:
 li a7, SYS_dup
 444:	48a9                	li	a7,10
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44c:	48ad                	li	a7,11
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 454:	48b1                	li	a7,12
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <pause>:
.global pause
pause:
 li a7, SYS_pause
 45c:	48b5                	li	a7,13
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 464:	48b9                	li	a7,14
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 46c:	48d9                	li	a7,22
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 474:	48dd                	li	a7,23
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47c:	1101                	addi	sp,sp,-32
 47e:	ec06                	sd	ra,24(sp)
 480:	e822                	sd	s0,16(sp)
 482:	1000                	addi	s0,sp,32
 484:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 488:	4605                	li	a2,1
 48a:	fef40593          	addi	a1,s0,-17
 48e:	f5fff0ef          	jal	3ec <write>
}
 492:	60e2                	ld	ra,24(sp)
 494:	6442                	ld	s0,16(sp)
 496:	6105                	addi	sp,sp,32
 498:	8082                	ret

000000000000049a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 49a:	715d                	addi	sp,sp,-80
 49c:	e486                	sd	ra,72(sp)
 49e:	e0a2                	sd	s0,64(sp)
 4a0:	f84a                	sd	s2,48(sp)
 4a2:	0880                	addi	s0,sp,80
 4a4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a6:	c299                	beqz	a3,4ac <printint+0x12>
 4a8:	0805c363          	bltz	a1,52e <printint+0x94>
  neg = 0;
 4ac:	4881                	li	a7,0
 4ae:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4b2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4b4:	00000517          	auipc	a0,0x0
 4b8:	70c50513          	addi	a0,a0,1804 # bc0 <digits>
 4bc:	883e                	mv	a6,a5
 4be:	2785                	addiw	a5,a5,1
 4c0:	02c5f733          	remu	a4,a1,a2
 4c4:	972a                	add	a4,a4,a0
 4c6:	00074703          	lbu	a4,0(a4)
 4ca:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ce:	872e                	mv	a4,a1
 4d0:	02c5d5b3          	divu	a1,a1,a2
 4d4:	0685                	addi	a3,a3,1
 4d6:	fec773e3          	bgeu	a4,a2,4bc <printint+0x22>
  if(neg)
 4da:	00088b63          	beqz	a7,4f0 <printint+0x56>
    buf[i++] = '-';
 4de:	fd078793          	addi	a5,a5,-48
 4e2:	97a2                	add	a5,a5,s0
 4e4:	02d00713          	li	a4,45
 4e8:	fee78423          	sb	a4,-24(a5)
 4ec:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4f0:	02f05a63          	blez	a5,524 <printint+0x8a>
 4f4:	fc26                	sd	s1,56(sp)
 4f6:	f44e                	sd	s3,40(sp)
 4f8:	fb840713          	addi	a4,s0,-72
 4fc:	00f704b3          	add	s1,a4,a5
 500:	fff70993          	addi	s3,a4,-1
 504:	99be                	add	s3,s3,a5
 506:	37fd                	addiw	a5,a5,-1
 508:	1782                	slli	a5,a5,0x20
 50a:	9381                	srli	a5,a5,0x20
 50c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 510:	fff4c583          	lbu	a1,-1(s1)
 514:	854a                	mv	a0,s2
 516:	f67ff0ef          	jal	47c <putc>
  while(--i >= 0)
 51a:	14fd                	addi	s1,s1,-1
 51c:	ff349ae3          	bne	s1,s3,510 <printint+0x76>
 520:	74e2                	ld	s1,56(sp)
 522:	79a2                	ld	s3,40(sp)
}
 524:	60a6                	ld	ra,72(sp)
 526:	6406                	ld	s0,64(sp)
 528:	7942                	ld	s2,48(sp)
 52a:	6161                	addi	sp,sp,80
 52c:	8082                	ret
    x = -xx;
 52e:	40b005b3          	neg	a1,a1
    neg = 1;
 532:	4885                	li	a7,1
    x = -xx;
 534:	bfad                	j	4ae <printint+0x14>

0000000000000536 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 536:	711d                	addi	sp,sp,-96
 538:	ec86                	sd	ra,88(sp)
 53a:	e8a2                	sd	s0,80(sp)
 53c:	e0ca                	sd	s2,64(sp)
 53e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 540:	0005c903          	lbu	s2,0(a1)
 544:	28090663          	beqz	s2,7d0 <vprintf+0x29a>
 548:	e4a6                	sd	s1,72(sp)
 54a:	fc4e                	sd	s3,56(sp)
 54c:	f852                	sd	s4,48(sp)
 54e:	f456                	sd	s5,40(sp)
 550:	f05a                	sd	s6,32(sp)
 552:	ec5e                	sd	s7,24(sp)
 554:	e862                	sd	s8,16(sp)
 556:	e466                	sd	s9,8(sp)
 558:	8b2a                	mv	s6,a0
 55a:	8a2e                	mv	s4,a1
 55c:	8bb2                	mv	s7,a2
  state = 0;
 55e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 560:	4481                	li	s1,0
 562:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 564:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 568:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 56c:	06c00c93          	li	s9,108
 570:	a005                	j	590 <vprintf+0x5a>
        putc(fd, c0);
 572:	85ca                	mv	a1,s2
 574:	855a                	mv	a0,s6
 576:	f07ff0ef          	jal	47c <putc>
 57a:	a019                	j	580 <vprintf+0x4a>
    } else if(state == '%'){
 57c:	03598263          	beq	s3,s5,5a0 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 580:	2485                	addiw	s1,s1,1
 582:	8726                	mv	a4,s1
 584:	009a07b3          	add	a5,s4,s1
 588:	0007c903          	lbu	s2,0(a5)
 58c:	22090a63          	beqz	s2,7c0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 590:	0009079b          	sext.w	a5,s2
    if(state == 0){
 594:	fe0994e3          	bnez	s3,57c <vprintf+0x46>
      if(c0 == '%'){
 598:	fd579de3          	bne	a5,s5,572 <vprintf+0x3c>
        state = '%';
 59c:	89be                	mv	s3,a5
 59e:	b7cd                	j	580 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a0:	00ea06b3          	add	a3,s4,a4
 5a4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5a8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5aa:	c681                	beqz	a3,5b2 <vprintf+0x7c>
 5ac:	9752                	add	a4,a4,s4
 5ae:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b2:	05878363          	beq	a5,s8,5f8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5b6:	05978d63          	beq	a5,s9,610 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ba:	07500713          	li	a4,117
 5be:	0ee78763          	beq	a5,a4,6ac <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c2:	07800713          	li	a4,120
 5c6:	12e78963          	beq	a5,a4,6f8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ca:	07000713          	li	a4,112
 5ce:	14e78e63          	beq	a5,a4,72a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5d2:	06300713          	li	a4,99
 5d6:	18e78e63          	beq	a5,a4,772 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5da:	07300713          	li	a4,115
 5de:	1ae78463          	beq	a5,a4,786 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5e2:	02500713          	li	a4,37
 5e6:	04e79563          	bne	a5,a4,630 <vprintf+0xfa>
        putc(fd, '%');
 5ea:	02500593          	li	a1,37
 5ee:	855a                	mv	a0,s6
 5f0:	e8dff0ef          	jal	47c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b769                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f8:	008b8913          	addi	s2,s7,8
 5fc:	4685                	li	a3,1
 5fe:	4629                	li	a2,10
 600:	000ba583          	lw	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	e95ff0ef          	jal	49a <printint>
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bf8d                	j	580 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 610:	06400793          	li	a5,100
 614:	02f68963          	beq	a3,a5,646 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 618:	06c00793          	li	a5,108
 61c:	04f68263          	beq	a3,a5,660 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 620:	07500793          	li	a5,117
 624:	0af68063          	beq	a3,a5,6c4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 628:	07800793          	li	a5,120
 62c:	0ef68263          	beq	a3,a5,710 <vprintf+0x1da>
        putc(fd, '%');
 630:	02500593          	li	a1,37
 634:	855a                	mv	a0,s6
 636:	e47ff0ef          	jal	47c <putc>
        putc(fd, c0);
 63a:	85ca                	mv	a1,s2
 63c:	855a                	mv	a0,s6
 63e:	e3fff0ef          	jal	47c <putc>
      state = 0;
 642:	4981                	li	s3,0
 644:	bf35                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 646:	008b8913          	addi	s2,s7,8
 64a:	4685                	li	a3,1
 64c:	4629                	li	a2,10
 64e:	000bb583          	ld	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	e47ff0ef          	jal	49a <printint>
        i += 1;
 658:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
        i += 1;
 65e:	b70d                	j	580 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 660:	06400793          	li	a5,100
 664:	02f60763          	beq	a2,a5,692 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 668:	07500793          	li	a5,117
 66c:	06f60963          	beq	a2,a5,6de <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 670:	07800793          	li	a5,120
 674:	faf61ee3          	bne	a2,a5,630 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4641                	li	a2,16
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e15ff0ef          	jal	49a <printint>
        i += 2;
 68a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 2;
 690:	bdc5                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 692:	008b8913          	addi	s2,s7,8
 696:	4685                	li	a3,1
 698:	4629                	li	a2,10
 69a:	000bb583          	ld	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	dfbff0ef          	jal	49a <printint>
        i += 2;
 6a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
        i += 2;
 6aa:	bdd9                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4629                	li	a2,10
 6b4:	000be583          	lwu	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	de1ff0ef          	jal	49a <printint>
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bd7d                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4629                	li	a2,10
 6cc:	000bb583          	ld	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	dc9ff0ef          	jal	49a <printint>
        i += 1;
 6d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
        i += 1;
 6dc:	b555                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6de:	008b8913          	addi	s2,s7,8
 6e2:	4681                	li	a3,0
 6e4:	4629                	li	a2,10
 6e6:	000bb583          	ld	a1,0(s7)
 6ea:	855a                	mv	a0,s6
 6ec:	dafff0ef          	jal	49a <printint>
        i += 2;
 6f0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	8bca                	mv	s7,s2
      state = 0;
 6f4:	4981                	li	s3,0
        i += 2;
 6f6:	b569                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f8:	008b8913          	addi	s2,s7,8
 6fc:	4681                	li	a3,0
 6fe:	4641                	li	a2,16
 700:	000be583          	lwu	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	d95ff0ef          	jal	49a <printint>
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bd8d                	j	580 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 710:	008b8913          	addi	s2,s7,8
 714:	4681                	li	a3,0
 716:	4641                	li	a2,16
 718:	000bb583          	ld	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	d7dff0ef          	jal	49a <printint>
        i += 1;
 722:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
        i += 1;
 728:	bda1                	j	580 <vprintf+0x4a>
 72a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 72c:	008b8d13          	addi	s10,s7,8
 730:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 734:	03000593          	li	a1,48
 738:	855a                	mv	a0,s6
 73a:	d43ff0ef          	jal	47c <putc>
  putc(fd, 'x');
 73e:	07800593          	li	a1,120
 742:	855a                	mv	a0,s6
 744:	d39ff0ef          	jal	47c <putc>
 748:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74a:	00000b97          	auipc	s7,0x0
 74e:	476b8b93          	addi	s7,s7,1142 # bc0 <digits>
 752:	03c9d793          	srli	a5,s3,0x3c
 756:	97de                	add	a5,a5,s7
 758:	0007c583          	lbu	a1,0(a5)
 75c:	855a                	mv	a0,s6
 75e:	d1fff0ef          	jal	47c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 762:	0992                	slli	s3,s3,0x4
 764:	397d                	addiw	s2,s2,-1
 766:	fe0916e3          	bnez	s2,752 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 76a:	8bea                	mv	s7,s10
      state = 0;
 76c:	4981                	li	s3,0
 76e:	6d02                	ld	s10,0(sp)
 770:	bd01                	j	580 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 772:	008b8913          	addi	s2,s7,8
 776:	000bc583          	lbu	a1,0(s7)
 77a:	855a                	mv	a0,s6
 77c:	d01ff0ef          	jal	47c <putc>
 780:	8bca                	mv	s7,s2
      state = 0;
 782:	4981                	li	s3,0
 784:	bbf5                	j	580 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 786:	008b8993          	addi	s3,s7,8
 78a:	000bb903          	ld	s2,0(s7)
 78e:	00090f63          	beqz	s2,7ac <vprintf+0x276>
        for(; *s; s++)
 792:	00094583          	lbu	a1,0(s2)
 796:	c195                	beqz	a1,7ba <vprintf+0x284>
          putc(fd, *s);
 798:	855a                	mv	a0,s6
 79a:	ce3ff0ef          	jal	47c <putc>
        for(; *s; s++)
 79e:	0905                	addi	s2,s2,1
 7a0:	00094583          	lbu	a1,0(s2)
 7a4:	f9f5                	bnez	a1,798 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a6:	8bce                	mv	s7,s3
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bbd9                	j	580 <vprintf+0x4a>
          s = "(null)";
 7ac:	00000917          	auipc	s2,0x0
 7b0:	40c90913          	addi	s2,s2,1036 # bb8 <malloc+0x300>
        for(; *s; s++)
 7b4:	02800593          	li	a1,40
 7b8:	b7c5                	j	798 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ba:	8bce                	mv	s7,s3
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	b3c9                	j	580 <vprintf+0x4a>
 7c0:	64a6                	ld	s1,72(sp)
 7c2:	79e2                	ld	s3,56(sp)
 7c4:	7a42                	ld	s4,48(sp)
 7c6:	7aa2                	ld	s5,40(sp)
 7c8:	7b02                	ld	s6,32(sp)
 7ca:	6be2                	ld	s7,24(sp)
 7cc:	6c42                	ld	s8,16(sp)
 7ce:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7d0:	60e6                	ld	ra,88(sp)
 7d2:	6446                	ld	s0,80(sp)
 7d4:	6906                	ld	s2,64(sp)
 7d6:	6125                	addi	sp,sp,96
 7d8:	8082                	ret

00000000000007da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7da:	715d                	addi	sp,sp,-80
 7dc:	ec06                	sd	ra,24(sp)
 7de:	e822                	sd	s0,16(sp)
 7e0:	1000                	addi	s0,sp,32
 7e2:	e010                	sd	a2,0(s0)
 7e4:	e414                	sd	a3,8(s0)
 7e6:	e818                	sd	a4,16(s0)
 7e8:	ec1c                	sd	a5,24(s0)
 7ea:	03043023          	sd	a6,32(s0)
 7ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f6:	8622                	mv	a2,s0
 7f8:	d3fff0ef          	jal	536 <vprintf>
}
 7fc:	60e2                	ld	ra,24(sp)
 7fe:	6442                	ld	s0,16(sp)
 800:	6161                	addi	sp,sp,80
 802:	8082                	ret

0000000000000804 <printf>:

void
printf(const char *fmt, ...)
{
 804:	711d                	addi	sp,sp,-96
 806:	ec06                	sd	ra,24(sp)
 808:	e822                	sd	s0,16(sp)
 80a:	1000                	addi	s0,sp,32
 80c:	e40c                	sd	a1,8(s0)
 80e:	e810                	sd	a2,16(s0)
 810:	ec14                	sd	a3,24(s0)
 812:	f018                	sd	a4,32(s0)
 814:	f41c                	sd	a5,40(s0)
 816:	03043823          	sd	a6,48(s0)
 81a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	00840613          	addi	a2,s0,8
 822:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 826:	85aa                	mv	a1,a0
 828:	4505                	li	a0,1
 82a:	d0dff0ef          	jal	536 <vprintf>
}
 82e:	60e2                	ld	ra,24(sp)
 830:	6442                	ld	s0,16(sp)
 832:	6125                	addi	sp,sp,96
 834:	8082                	ret

0000000000000836 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 836:	1141                	addi	sp,sp,-16
 838:	e422                	sd	s0,8(sp)
 83a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 840:	00001797          	auipc	a5,0x1
 844:	7c07b783          	ld	a5,1984(a5) # 2000 <freep>
 848:	a02d                	j	872 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84a:	4618                	lw	a4,8(a2)
 84c:	9f2d                	addw	a4,a4,a1
 84e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 852:	6398                	ld	a4,0(a5)
 854:	6310                	ld	a2,0(a4)
 856:	a83d                	j	894 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 858:	ff852703          	lw	a4,-8(a0)
 85c:	9f31                	addw	a4,a4,a2
 85e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 860:	ff053683          	ld	a3,-16(a0)
 864:	a091                	j	8a8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	6398                	ld	a4,0(a5)
 868:	00e7e463          	bltu	a5,a4,870 <free+0x3a>
 86c:	00e6ea63          	bltu	a3,a4,880 <free+0x4a>
{
 870:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 872:	fed7fae3          	bgeu	a5,a3,866 <free+0x30>
 876:	6398                	ld	a4,0(a5)
 878:	00e6e463          	bltu	a3,a4,880 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87c:	fee7eae3          	bltu	a5,a4,870 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 880:	ff852583          	lw	a1,-8(a0)
 884:	6390                	ld	a2,0(a5)
 886:	02059813          	slli	a6,a1,0x20
 88a:	01c85713          	srli	a4,a6,0x1c
 88e:	9736                	add	a4,a4,a3
 890:	fae60de3          	beq	a2,a4,84a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 894:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 898:	4790                	lw	a2,8(a5)
 89a:	02061593          	slli	a1,a2,0x20
 89e:	01c5d713          	srli	a4,a1,0x1c
 8a2:	973e                	add	a4,a4,a5
 8a4:	fae68ae3          	beq	a3,a4,858 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8aa:	00001717          	auipc	a4,0x1
 8ae:	74f73b23          	sd	a5,1878(a4) # 2000 <freep>
}
 8b2:	6422                	ld	s0,8(sp)
 8b4:	0141                	addi	sp,sp,16
 8b6:	8082                	ret

00000000000008b8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b8:	7139                	addi	sp,sp,-64
 8ba:	fc06                	sd	ra,56(sp)
 8bc:	f822                	sd	s0,48(sp)
 8be:	f426                	sd	s1,40(sp)
 8c0:	ec4e                	sd	s3,24(sp)
 8c2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c4:	02051493          	slli	s1,a0,0x20
 8c8:	9081                	srli	s1,s1,0x20
 8ca:	04bd                	addi	s1,s1,15
 8cc:	8091                	srli	s1,s1,0x4
 8ce:	0014899b          	addiw	s3,s1,1
 8d2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d4:	00001517          	auipc	a0,0x1
 8d8:	72c53503          	ld	a0,1836(a0) # 2000 <freep>
 8dc:	c915                	beqz	a0,910 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	08977a63          	bgeu	a4,s1,976 <malloc+0xbe>
 8e6:	f04a                	sd	s2,32(sp)
 8e8:	e852                	sd	s4,16(sp)
 8ea:	e456                	sd	s5,8(sp)
 8ec:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ee:	8a4e                	mv	s4,s3
 8f0:	0009871b          	sext.w	a4,s3
 8f4:	6685                	lui	a3,0x1
 8f6:	00d77363          	bgeu	a4,a3,8fc <malloc+0x44>
 8fa:	6a05                	lui	s4,0x1
 8fc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 900:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 904:	00001917          	auipc	s2,0x1
 908:	6fc90913          	addi	s2,s2,1788 # 2000 <freep>
  if(p == SBRK_ERROR)
 90c:	5afd                	li	s5,-1
 90e:	a081                	j	94e <malloc+0x96>
 910:	f04a                	sd	s2,32(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 918:	00001797          	auipc	a5,0x1
 91c:	6f878793          	addi	a5,a5,1784 # 2010 <base>
 920:	00001717          	auipc	a4,0x1
 924:	6ef73023          	sd	a5,1760(a4) # 2000 <freep>
 928:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92e:	b7c1                	j	8ee <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 930:	6398                	ld	a4,0(a5)
 932:	e118                	sd	a4,0(a0)
 934:	a8a9                	j	98e <malloc+0xd6>
  hp->s.size = nu;
 936:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93a:	0541                	addi	a0,a0,16
 93c:	efbff0ef          	jal	836 <free>
  return freep;
 940:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 944:	c12d                	beqz	a0,9a6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 948:	4798                	lw	a4,8(a5)
 94a:	02977263          	bgeu	a4,s1,96e <malloc+0xb6>
    if(p == freep)
 94e:	00093703          	ld	a4,0(s2)
 952:	853e                	mv	a0,a5
 954:	fef719e3          	bne	a4,a5,946 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 958:	8552                	mv	a0,s4
 95a:	a3fff0ef          	jal	398 <sbrk>
  if(p == SBRK_ERROR)
 95e:	fd551ce3          	bne	a0,s5,936 <malloc+0x7e>
        return 0;
 962:	4501                	li	a0,0
 964:	7902                	ld	s2,32(sp)
 966:	6a42                	ld	s4,16(sp)
 968:	6aa2                	ld	s5,8(sp)
 96a:	6b02                	ld	s6,0(sp)
 96c:	a03d                	j	99a <malloc+0xe2>
 96e:	7902                	ld	s2,32(sp)
 970:	6a42                	ld	s4,16(sp)
 972:	6aa2                	ld	s5,8(sp)
 974:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 976:	fae48de3          	beq	s1,a4,930 <malloc+0x78>
        p->s.size -= nunits;
 97a:	4137073b          	subw	a4,a4,s3
 97e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 980:	02071693          	slli	a3,a4,0x20
 984:	01c6d713          	srli	a4,a3,0x1c
 988:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98e:	00001717          	auipc	a4,0x1
 992:	66a73923          	sd	a0,1650(a4) # 2000 <freep>
      return (void*)(p + 1);
 996:	01078513          	addi	a0,a5,16
  }
}
 99a:	70e2                	ld	ra,56(sp)
 99c:	7442                	ld	s0,48(sp)
 99e:	74a2                	ld	s1,40(sp)
 9a0:	69e2                	ld	s3,24(sp)
 9a2:	6121                	addi	sp,sp,64
 9a4:	8082                	ret
 9a6:	7902                	ld	s2,32(sp)
 9a8:	6a42                	ld	s4,16(sp)
 9aa:	6aa2                	ld	s5,8(sp)
 9ac:	6b02                	ld	s6,0(sp)
 9ae:	b7f5                	j	99a <malloc+0xe2>
