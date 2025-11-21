
user/_boost_t:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Test manual boostproc() syscall
// Demonstrates explicit priority reset functionality
int
main(int argc, char *argv[])
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	1080                	addi	s0,sp,96
  struct procinfo info;
  volatile int dummy = 0;
  14:	fa042623          	sw	zero,-84(s0)
  
  printf("=== Manual Boost Test (Week 3) ===\n");
  18:	00001517          	auipc	a0,0x1
  1c:	a1850513          	addi	a0,a0,-1512 # a30 <malloc+0xe2>
  20:	075000ef          	jal	ra,894 <printf>
  printf("Testing boostproc() system call\n\n");
  24:	00001517          	auipc	a0,0x1
  28:	a3450513          	addi	a0,a0,-1484 # a58 <malloc+0x10a>
  2c:	069000ef          	jal	ra,894 <printf>
  
  if(getprocinfo(&info) == 0) {
  30:	fb040513          	addi	a0,s0,-80
  34:	4d4000ef          	jal	ra,508 <getprocinfo>
  38:	c51d                	beqz	a0,66 <main+0x66>
    printf("Initial state: PID=%d, Q%d, slices=%d\n", 
           info.pid, info.priority, info.time_slices);
  }
  
  printf("\nPhase 1: Demote to lower priority through CPU work\n");
  3a:	00001517          	auipc	a0,0x1
  3e:	a6e50513          	addi	a0,a0,-1426 # aa8 <malloc+0x15a>
  42:	053000ef          	jal	ra,894 <printf>
  // Do enough work to demote to Q2 or Q3
  for(int iter = 0; iter < 20; iter++) {
  46:	4981                	li	s3,0
    for(long j = 0; j < 10000000; j++) {
      dummy = dummy + j;
      dummy = dummy % 1000000;
  48:	000f4937          	lui	s2,0xf4
  4c:	2409091b          	addiw	s2,s2,576
    for(long j = 0; j < 10000000; j++) {
  50:	009894b7          	lui	s1,0x989
  54:	68048493          	addi	s1,s1,1664 # 989680 <base+0x988670>
    }
    
    if(iter % 5 == 0 && getprocinfo(&info) == 0) {
  58:	4a95                	li	s5,5
      printf("  Iteration %d: Q%d (slices=%d)\n", 
  5a:	00001b17          	auipc	s6,0x1
  5e:	a86b0b13          	addi	s6,s6,-1402 # ae0 <malloc+0x192>
  for(int iter = 0; iter < 20; iter++) {
  62:	4a51                	li	s4,20
  64:	a00d                	j	86 <main+0x86>
    printf("Initial state: PID=%d, Q%d, slices=%d\n", 
  66:	fbc42683          	lw	a3,-68(s0)
  6a:	fb842603          	lw	a2,-72(s0)
  6e:	fb042583          	lw	a1,-80(s0)
  72:	00001517          	auipc	a0,0x1
  76:	a0e50513          	addi	a0,a0,-1522 # a80 <malloc+0x132>
  7a:	01b000ef          	jal	ra,894 <printf>
  7e:	bf75                	j	3a <main+0x3a>
  for(int iter = 0; iter < 20; iter++) {
  80:	2985                	addiw	s3,s3,1
  82:	05498263          	beq	s3,s4,c6 <main+0xc6>
    for(long j = 0; j < 10000000; j++) {
  86:	4781                	li	a5,0
      dummy = dummy + j;
  88:	fac42703          	lw	a4,-84(s0)
  8c:	9f3d                	addw	a4,a4,a5
  8e:	fae42623          	sw	a4,-84(s0)
      dummy = dummy % 1000000;
  92:	fac42703          	lw	a4,-84(s0)
  96:	0327673b          	remw	a4,a4,s2
  9a:	fae42623          	sw	a4,-84(s0)
    for(long j = 0; j < 10000000; j++) {
  9e:	0785                	addi	a5,a5,1
  a0:	fe9794e3          	bne	a5,s1,88 <main+0x88>
    if(iter % 5 == 0 && getprocinfo(&info) == 0) {
  a4:	0359e7bb          	remw	a5,s3,s5
  a8:	ffe1                	bnez	a5,80 <main+0x80>
  aa:	fb040513          	addi	a0,s0,-80
  ae:	45a000ef          	jal	ra,508 <getprocinfo>
  b2:	f579                	bnez	a0,80 <main+0x80>
      printf("  Iteration %d: Q%d (slices=%d)\n", 
  b4:	fbc42683          	lw	a3,-68(s0)
  b8:	fb842603          	lw	a2,-72(s0)
  bc:	85ce                	mv	a1,s3
  be:	855a                	mv	a0,s6
  c0:	7d4000ef          	jal	ra,894 <printf>
  c4:	bf75                	j	80 <main+0x80>
             iter, info.priority, info.time_slices);
    }
  }
  
  if(getprocinfo(&info) == 0) {
  c6:	fb040513          	addi	a0,s0,-80
  ca:	43e000ef          	jal	ra,508 <getprocinfo>
  ce:	c549                	beqz	a0,158 <main+0x158>
    printf("\nBefore boost: Q%d, slices=%d\n", 
           info.priority, info.time_slices);
  }
  
  printf("\nPhase 2: Manually trigger priority boost\n");
  d0:	00001517          	auipc	a0,0x1
  d4:	a5850513          	addi	a0,a0,-1448 # b28 <malloc+0x1da>
  d8:	7bc000ef          	jal	ra,894 <printf>
  printf("Calling boostproc()...\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	a7c50513          	addi	a0,a0,-1412 # b58 <malloc+0x20a>
  e4:	7b0000ef          	jal	ra,894 <printf>
  boostproc();
  e8:	428000ef          	jal	ra,510 <boostproc>
  
  // Small delay to let boost take effect
  pause(2);
  ec:	4509                	li	a0,2
  ee:	40a000ef          	jal	ra,4f8 <pause>
  
  if(getprocinfo(&info) == 0) {
  f2:	fb040513          	addi	a0,s0,-80
  f6:	412000ef          	jal	ra,508 <getprocinfo>
  fa:	c935                	beqz	a0,16e <main+0x16e>
    } else {
      printf("\n✗ FAILED: Boost didn't work correctly\n");
    }
  }
  
  printf("\nPhase 3: Verify normal demotion still works\n");
  fc:	00001517          	auipc	a0,0x1
 100:	b0450513          	addi	a0,a0,-1276 # c00 <malloc+0x2b2>
 104:	790000ef          	jal	ra,894 <printf>
 108:	45a9                	li	a1,10
  for(int iter = 0; iter < 10; iter++) {
    for(long j = 0; j < 10000000; j++) {
      dummy = dummy + j;
      dummy = dummy % 1000000;
 10a:	000f4637          	lui	a2,0xf4
 10e:	2406061b          	addiw	a2,a2,576
    for(long j = 0; j < 10000000; j++) {
 112:	009896b7          	lui	a3,0x989
 116:	68068693          	addi	a3,a3,1664 # 989680 <base+0x988670>
 11a:	4781                	li	a5,0
      dummy = dummy + j;
 11c:	fac42703          	lw	a4,-84(s0)
 120:	9f3d                	addw	a4,a4,a5
 122:	fae42623          	sw	a4,-84(s0)
      dummy = dummy % 1000000;
 126:	fac42703          	lw	a4,-84(s0)
 12a:	02c7673b          	remw	a4,a4,a2
 12e:	fae42623          	sw	a4,-84(s0)
    for(long j = 0; j < 10000000; j++) {
 132:	0785                	addi	a5,a5,1
 134:	fed794e3          	bne	a5,a3,11c <main+0x11c>
  for(int iter = 0; iter < 10; iter++) {
 138:	35fd                	addiw	a1,a1,-1
 13a:	f1e5                	bnez	a1,11a <main+0x11a>
    }
  }
  
  if(getprocinfo(&info) == 0) {
 13c:	fb040513          	addi	a0,s0,-80
 140:	3c8000ef          	jal	ra,508 <getprocinfo>
 144:	c525                	beqz	a0,1ac <main+0x1ac>
    if(info.priority > 0) {
      printf("✓ Demotion still working after manual boost\n");
    }
  }
  
  printf("\n=== Manual Boost Test Complete ===\n");
 146:	00001517          	auipc	a0,0x1
 14a:	b5250513          	addi	a0,a0,-1198 # c98 <malloc+0x34a>
 14e:	746000ef          	jal	ra,894 <printf>
  
  exit(0);
 152:	4501                	li	a0,0
 154:	314000ef          	jal	ra,468 <exit>
    printf("\nBefore boost: Q%d, slices=%d\n", 
 158:	fbc42603          	lw	a2,-68(s0)
 15c:	fb842583          	lw	a1,-72(s0)
 160:	00001517          	auipc	a0,0x1
 164:	9a850513          	addi	a0,a0,-1624 # b08 <malloc+0x1ba>
 168:	72c000ef          	jal	ra,894 <printf>
 16c:	b795                	j	d0 <main+0xd0>
    printf("After boost: Q%d, slices=%d\n", 
 16e:	fbc42603          	lw	a2,-68(s0)
 172:	fb842583          	lw	a1,-72(s0)
 176:	00001517          	auipc	a0,0x1
 17a:	9fa50513          	addi	a0,a0,-1542 # b70 <malloc+0x222>
 17e:	716000ef          	jal	ra,894 <printf>
    if(info.priority == 0 && info.time_slices == 0) {
 182:	fb842783          	lw	a5,-72(s0)
 186:	fbc42703          	lw	a4,-68(s0)
 18a:	8fd9                	or	a5,a5,a4
 18c:	2781                	sext.w	a5,a5
 18e:	cb81                	beqz	a5,19e <main+0x19e>
      printf("\n✗ FAILED: Boost didn't work correctly\n");
 190:	00001517          	auipc	a0,0x1
 194:	a4050513          	addi	a0,a0,-1472 # bd0 <malloc+0x282>
 198:	6fc000ef          	jal	ra,894 <printf>
 19c:	b785                	j	fc <main+0xfc>
      printf("\n✓ SUCCESS: Process was boosted to Q0 with reset slices!\n");
 19e:	00001517          	auipc	a0,0x1
 1a2:	9f250513          	addi	a0,a0,-1550 # b90 <malloc+0x242>
 1a6:	6ee000ef          	jal	ra,894 <printf>
 1aa:	bf89                	j	fc <main+0xfc>
    printf("After more work: Q%d (should have demoted again)\n", info.priority);
 1ac:	fb842583          	lw	a1,-72(s0)
 1b0:	00001517          	auipc	a0,0x1
 1b4:	a8050513          	addi	a0,a0,-1408 # c30 <malloc+0x2e2>
 1b8:	6dc000ef          	jal	ra,894 <printf>
    if(info.priority > 0) {
 1bc:	fb842783          	lw	a5,-72(s0)
 1c0:	f8f053e3          	blez	a5,146 <main+0x146>
      printf("✓ Demotion still working after manual boost\n");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	aa450513          	addi	a0,a0,-1372 # c68 <malloc+0x31a>
 1cc:	6c8000ef          	jal	ra,894 <printf>
 1d0:	bf9d                	j	146 <main+0x146>

00000000000001d2 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e406                	sd	ra,8(sp)
 1d6:	e022                	sd	s0,0(sp)
 1d8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1da:	e27ff0ef          	jal	ra,0 <main>
  exit(r);
 1de:	28a000ef          	jal	ra,468 <exit>

00000000000001e2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e8:	87aa                	mv	a5,a0
 1ea:	0585                	addi	a1,a1,1
 1ec:	0785                	addi	a5,a5,1
 1ee:	fff5c703          	lbu	a4,-1(a1)
 1f2:	fee78fa3          	sb	a4,-1(a5)
 1f6:	fb75                	bnez	a4,1ea <strcpy+0x8>
    ;
  return os;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret

00000000000001fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 204:	00054783          	lbu	a5,0(a0)
 208:	cb91                	beqz	a5,21c <strcmp+0x1e>
 20a:	0005c703          	lbu	a4,0(a1)
 20e:	00f71763          	bne	a4,a5,21c <strcmp+0x1e>
    p++, q++;
 212:	0505                	addi	a0,a0,1
 214:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 216:	00054783          	lbu	a5,0(a0)
 21a:	fbe5                	bnez	a5,20a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 21c:	0005c503          	lbu	a0,0(a1)
}
 220:	40a7853b          	subw	a0,a5,a0
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret

000000000000022a <strlen>:

uint
strlen(const char *s)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e422                	sd	s0,8(sp)
 22e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 230:	00054783          	lbu	a5,0(a0)
 234:	cf91                	beqz	a5,250 <strlen+0x26>
 236:	0505                	addi	a0,a0,1
 238:	87aa                	mv	a5,a0
 23a:	4685                	li	a3,1
 23c:	9e89                	subw	a3,a3,a0
 23e:	00f6853b          	addw	a0,a3,a5
 242:	0785                	addi	a5,a5,1
 244:	fff7c703          	lbu	a4,-1(a5)
 248:	fb7d                	bnez	a4,23e <strlen+0x14>
    ;
  return n;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  for(n = 0; s[n]; n++)
 250:	4501                	li	a0,0
 252:	bfe5                	j	24a <strlen+0x20>

0000000000000254 <memset>:

void*
memset(void *dst, int c, uint n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e422                	sd	s0,8(sp)
 258:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 25a:	ca19                	beqz	a2,270 <memset+0x1c>
 25c:	87aa                	mv	a5,a0
 25e:	1602                	slli	a2,a2,0x20
 260:	9201                	srli	a2,a2,0x20
 262:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 266:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 26a:	0785                	addi	a5,a5,1
 26c:	fee79de3          	bne	a5,a4,266 <memset+0x12>
  }
  return dst;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret

0000000000000276 <strchr>:

char*
strchr(const char *s, char c)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 27c:	00054783          	lbu	a5,0(a0)
 280:	cb99                	beqz	a5,296 <strchr+0x20>
    if(*s == c)
 282:	00f58763          	beq	a1,a5,290 <strchr+0x1a>
  for(; *s; s++)
 286:	0505                	addi	a0,a0,1
 288:	00054783          	lbu	a5,0(a0)
 28c:	fbfd                	bnez	a5,282 <strchr+0xc>
      return (char*)s;
  return 0;
 28e:	4501                	li	a0,0
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  return 0;
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <strchr+0x1a>

000000000000029a <gets>:

char*
gets(char *buf, int max)
{
 29a:	711d                	addi	sp,sp,-96
 29c:	ec86                	sd	ra,88(sp)
 29e:	e8a2                	sd	s0,80(sp)
 2a0:	e4a6                	sd	s1,72(sp)
 2a2:	e0ca                	sd	s2,64(sp)
 2a4:	fc4e                	sd	s3,56(sp)
 2a6:	f852                	sd	s4,48(sp)
 2a8:	f456                	sd	s5,40(sp)
 2aa:	f05a                	sd	s6,32(sp)
 2ac:	ec5e                	sd	s7,24(sp)
 2ae:	1080                	addi	s0,sp,96
 2b0:	8baa                	mv	s7,a0
 2b2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b4:	892a                	mv	s2,a0
 2b6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b8:	4aa9                	li	s5,10
 2ba:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2bc:	89a6                	mv	s3,s1
 2be:	2485                	addiw	s1,s1,1
 2c0:	0344d663          	bge	s1,s4,2ec <gets+0x52>
    cc = read(0, &c, 1);
 2c4:	4605                	li	a2,1
 2c6:	faf40593          	addi	a1,s0,-81
 2ca:	4501                	li	a0,0
 2cc:	1b4000ef          	jal	ra,480 <read>
    if(cc < 1)
 2d0:	00a05e63          	blez	a0,2ec <gets+0x52>
    buf[i++] = c;
 2d4:	faf44783          	lbu	a5,-81(s0)
 2d8:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 2dc:	01578763          	beq	a5,s5,2ea <gets+0x50>
 2e0:	0905                	addi	s2,s2,1
 2e2:	fd679de3          	bne	a5,s6,2bc <gets+0x22>
  for(i=0; i+1 < max; ){
 2e6:	89a6                	mv	s3,s1
 2e8:	a011                	j	2ec <gets+0x52>
 2ea:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ec:	99de                	add	s3,s3,s7
 2ee:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f2:	855e                	mv	a0,s7
 2f4:	60e6                	ld	ra,88(sp)
 2f6:	6446                	ld	s0,80(sp)
 2f8:	64a6                	ld	s1,72(sp)
 2fa:	6906                	ld	s2,64(sp)
 2fc:	79e2                	ld	s3,56(sp)
 2fe:	7a42                	ld	s4,48(sp)
 300:	7aa2                	ld	s5,40(sp)
 302:	7b02                	ld	s6,32(sp)
 304:	6be2                	ld	s7,24(sp)
 306:	6125                	addi	sp,sp,96
 308:	8082                	ret

000000000000030a <stat>:

int
stat(const char *n, struct stat *st)
{
 30a:	1101                	addi	sp,sp,-32
 30c:	ec06                	sd	ra,24(sp)
 30e:	e822                	sd	s0,16(sp)
 310:	e426                	sd	s1,8(sp)
 312:	e04a                	sd	s2,0(sp)
 314:	1000                	addi	s0,sp,32
 316:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 318:	4581                	li	a1,0
 31a:	18e000ef          	jal	ra,4a8 <open>
  if(fd < 0)
 31e:	02054163          	bltz	a0,340 <stat+0x36>
 322:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 324:	85ca                	mv	a1,s2
 326:	19a000ef          	jal	ra,4c0 <fstat>
 32a:	892a                	mv	s2,a0
  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	162000ef          	jal	ra,490 <close>
  return r;
}
 332:	854a                	mv	a0,s2
 334:	60e2                	ld	ra,24(sp)
 336:	6442                	ld	s0,16(sp)
 338:	64a2                	ld	s1,8(sp)
 33a:	6902                	ld	s2,0(sp)
 33c:	6105                	addi	sp,sp,32
 33e:	8082                	ret
    return -1;
 340:	597d                	li	s2,-1
 342:	bfc5                	j	332 <stat+0x28>

0000000000000344 <atoi>:

int
atoi(const char *s)
{
 344:	1141                	addi	sp,sp,-16
 346:	e422                	sd	s0,8(sp)
 348:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34a:	00054603          	lbu	a2,0(a0)
 34e:	fd06079b          	addiw	a5,a2,-48
 352:	0ff7f793          	andi	a5,a5,255
 356:	4725                	li	a4,9
 358:	02f76963          	bltu	a4,a5,38a <atoi+0x46>
 35c:	86aa                	mv	a3,a0
  n = 0;
 35e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 360:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 362:	0685                	addi	a3,a3,1
 364:	0025179b          	slliw	a5,a0,0x2
 368:	9fa9                	addw	a5,a5,a0
 36a:	0017979b          	slliw	a5,a5,0x1
 36e:	9fb1                	addw	a5,a5,a2
 370:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 374:	0006c603          	lbu	a2,0(a3)
 378:	fd06071b          	addiw	a4,a2,-48
 37c:	0ff77713          	andi	a4,a4,255
 380:	fee5f1e3          	bgeu	a1,a4,362 <atoi+0x1e>
  return n;
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
  n = 0;
 38a:	4501                	li	a0,0
 38c:	bfe5                	j	384 <atoi+0x40>

000000000000038e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 394:	02b57463          	bgeu	a0,a1,3bc <memmove+0x2e>
    while(n-- > 0)
 398:	00c05f63          	blez	a2,3b6 <memmove+0x28>
 39c:	1602                	slli	a2,a2,0x20
 39e:	9201                	srli	a2,a2,0x20
 3a0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3a4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3a6:	0585                	addi	a1,a1,1
 3a8:	0705                	addi	a4,a4,1
 3aa:	fff5c683          	lbu	a3,-1(a1)
 3ae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b2:	fee79ae3          	bne	a5,a4,3a6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
    dst += n;
 3bc:	00c50733          	add	a4,a0,a2
    src += n;
 3c0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c2:	fec05ae3          	blez	a2,3b6 <memmove+0x28>
 3c6:	fff6079b          	addiw	a5,a2,-1
 3ca:	1782                	slli	a5,a5,0x20
 3cc:	9381                	srli	a5,a5,0x20
 3ce:	fff7c793          	not	a5,a5
 3d2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d4:	15fd                	addi	a1,a1,-1
 3d6:	177d                	addi	a4,a4,-1
 3d8:	0005c683          	lbu	a3,0(a1)
 3dc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e0:	fee79ae3          	bne	a5,a4,3d4 <memmove+0x46>
 3e4:	bfc9                	j	3b6 <memmove+0x28>

00000000000003e6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e422                	sd	s0,8(sp)
 3ea:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ec:	ca05                	beqz	a2,41c <memcmp+0x36>
 3ee:	fff6069b          	addiw	a3,a2,-1
 3f2:	1682                	slli	a3,a3,0x20
 3f4:	9281                	srli	a3,a3,0x20
 3f6:	0685                	addi	a3,a3,1
 3f8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3fa:	00054783          	lbu	a5,0(a0)
 3fe:	0005c703          	lbu	a4,0(a1)
 402:	00e79863          	bne	a5,a4,412 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 406:	0505                	addi	a0,a0,1
    p2++;
 408:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 40a:	fed518e3          	bne	a0,a3,3fa <memcmp+0x14>
  }
  return 0;
 40e:	4501                	li	a0,0
 410:	a019                	j	416 <memcmp+0x30>
      return *p1 - *p2;
 412:	40e7853b          	subw	a0,a5,a4
}
 416:	6422                	ld	s0,8(sp)
 418:	0141                	addi	sp,sp,16
 41a:	8082                	ret
  return 0;
 41c:	4501                	li	a0,0
 41e:	bfe5                	j	416 <memcmp+0x30>

0000000000000420 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 420:	1141                	addi	sp,sp,-16
 422:	e406                	sd	ra,8(sp)
 424:	e022                	sd	s0,0(sp)
 426:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 428:	f67ff0ef          	jal	ra,38e <memmove>
}
 42c:	60a2                	ld	ra,8(sp)
 42e:	6402                	ld	s0,0(sp)
 430:	0141                	addi	sp,sp,16
 432:	8082                	ret

0000000000000434 <sbrk>:

char *
sbrk(int n) {
 434:	1141                	addi	sp,sp,-16
 436:	e406                	sd	ra,8(sp)
 438:	e022                	sd	s0,0(sp)
 43a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 43c:	4585                	li	a1,1
 43e:	0b2000ef          	jal	ra,4f0 <sys_sbrk>
}
 442:	60a2                	ld	ra,8(sp)
 444:	6402                	ld	s0,0(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret

000000000000044a <sbrklazy>:

char *
sbrklazy(int n) {
 44a:	1141                	addi	sp,sp,-16
 44c:	e406                	sd	ra,8(sp)
 44e:	e022                	sd	s0,0(sp)
 450:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 452:	4589                	li	a1,2
 454:	09c000ef          	jal	ra,4f0 <sys_sbrk>
}
 458:	60a2                	ld	ra,8(sp)
 45a:	6402                	ld	s0,0(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret

0000000000000460 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 460:	4885                	li	a7,1
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exit>:
.global exit
exit:
 li a7, SYS_exit
 468:	4889                	li	a7,2
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <wait>:
.global wait
wait:
 li a7, SYS_wait
 470:	488d                	li	a7,3
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 478:	4891                	li	a7,4
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <read>:
.global read
read:
 li a7, SYS_read
 480:	4895                	li	a7,5
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <write>:
.global write
write:
 li a7, SYS_write
 488:	48c1                	li	a7,16
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <close>:
.global close
close:
 li a7, SYS_close
 490:	48d5                	li	a7,21
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <kill>:
.global kill
kill:
 li a7, SYS_kill
 498:	4899                	li	a7,6
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a0:	489d                	li	a7,7
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <open>:
.global open
open:
 li a7, SYS_open
 4a8:	48bd                	li	a7,15
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b0:	48c5                	li	a7,17
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b8:	48c9                	li	a7,18
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c0:	48a1                	li	a7,8
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <link>:
.global link
link:
 li a7, SYS_link
 4c8:	48cd                	li	a7,19
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d0:	48d1                	li	a7,20
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d8:	48a5                	li	a7,9
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e0:	48a9                	li	a7,10
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e8:	48ad                	li	a7,11
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4f0:	48b1                	li	a7,12
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4f8:	48b5                	li	a7,13
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 500:	48b9                	li	a7,14
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 508:	48d9                	li	a7,22
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 510:	48dd                	li	a7,23
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 518:	1101                	addi	sp,sp,-32
 51a:	ec06                	sd	ra,24(sp)
 51c:	e822                	sd	s0,16(sp)
 51e:	1000                	addi	s0,sp,32
 520:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 524:	4605                	li	a2,1
 526:	fef40593          	addi	a1,s0,-17
 52a:	f5fff0ef          	jal	ra,488 <write>
}
 52e:	60e2                	ld	ra,24(sp)
 530:	6442                	ld	s0,16(sp)
 532:	6105                	addi	sp,sp,32
 534:	8082                	ret

0000000000000536 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 536:	715d                	addi	sp,sp,-80
 538:	e486                	sd	ra,72(sp)
 53a:	e0a2                	sd	s0,64(sp)
 53c:	fc26                	sd	s1,56(sp)
 53e:	f84a                	sd	s2,48(sp)
 540:	f44e                	sd	s3,40(sp)
 542:	0880                	addi	s0,sp,80
 544:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 546:	c299                	beqz	a3,54c <printint+0x16>
 548:	0805c163          	bltz	a1,5ca <printint+0x94>
  neg = 0;
 54c:	4881                	li	a7,0
 54e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 552:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 554:	00000517          	auipc	a0,0x0
 558:	77450513          	addi	a0,a0,1908 # cc8 <digits>
 55c:	883e                	mv	a6,a5
 55e:	2785                	addiw	a5,a5,1
 560:	02c5f733          	remu	a4,a1,a2
 564:	972a                	add	a4,a4,a0
 566:	00074703          	lbu	a4,0(a4)
 56a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 56e:	872e                	mv	a4,a1
 570:	02c5d5b3          	divu	a1,a1,a2
 574:	0685                	addi	a3,a3,1
 576:	fec773e3          	bgeu	a4,a2,55c <printint+0x26>
  if(neg)
 57a:	00088b63          	beqz	a7,590 <printint+0x5a>
    buf[i++] = '-';
 57e:	fd040713          	addi	a4,s0,-48
 582:	97ba                	add	a5,a5,a4
 584:	02d00713          	li	a4,45
 588:	fee78423          	sb	a4,-24(a5)
 58c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 590:	02f05663          	blez	a5,5bc <printint+0x86>
 594:	fb840713          	addi	a4,s0,-72
 598:	00f704b3          	add	s1,a4,a5
 59c:	fff70993          	addi	s3,a4,-1
 5a0:	99be                	add	s3,s3,a5
 5a2:	37fd                	addiw	a5,a5,-1
 5a4:	1782                	slli	a5,a5,0x20
 5a6:	9381                	srli	a5,a5,0x20
 5a8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5ac:	fff4c583          	lbu	a1,-1(s1)
 5b0:	854a                	mv	a0,s2
 5b2:	f67ff0ef          	jal	ra,518 <putc>
  while(--i >= 0)
 5b6:	14fd                	addi	s1,s1,-1
 5b8:	ff349ae3          	bne	s1,s3,5ac <printint+0x76>
}
 5bc:	60a6                	ld	ra,72(sp)
 5be:	6406                	ld	s0,64(sp)
 5c0:	74e2                	ld	s1,56(sp)
 5c2:	7942                	ld	s2,48(sp)
 5c4:	79a2                	ld	s3,40(sp)
 5c6:	6161                	addi	sp,sp,80
 5c8:	8082                	ret
    x = -xx;
 5ca:	40b005b3          	neg	a1,a1
    neg = 1;
 5ce:	4885                	li	a7,1
    x = -xx;
 5d0:	bfbd                	j	54e <printint+0x18>

00000000000005d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d2:	7119                	addi	sp,sp,-128
 5d4:	fc86                	sd	ra,120(sp)
 5d6:	f8a2                	sd	s0,112(sp)
 5d8:	f4a6                	sd	s1,104(sp)
 5da:	f0ca                	sd	s2,96(sp)
 5dc:	ecce                	sd	s3,88(sp)
 5de:	e8d2                	sd	s4,80(sp)
 5e0:	e4d6                	sd	s5,72(sp)
 5e2:	e0da                	sd	s6,64(sp)
 5e4:	fc5e                	sd	s7,56(sp)
 5e6:	f862                	sd	s8,48(sp)
 5e8:	f466                	sd	s9,40(sp)
 5ea:	f06a                	sd	s10,32(sp)
 5ec:	ec6e                	sd	s11,24(sp)
 5ee:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f0:	0005c903          	lbu	s2,0(a1)
 5f4:	24090c63          	beqz	s2,84c <vprintf+0x27a>
 5f8:	8b2a                	mv	s6,a0
 5fa:	8a2e                	mv	s4,a1
 5fc:	8bb2                	mv	s7,a2
  state = 0;
 5fe:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 600:	4481                	li	s1,0
 602:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 604:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 608:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 60c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 610:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 614:	00000c97          	auipc	s9,0x0
 618:	6b4c8c93          	addi	s9,s9,1716 # cc8 <digits>
 61c:	a005                	j	63c <vprintf+0x6a>
        putc(fd, c0);
 61e:	85ca                	mv	a1,s2
 620:	855a                	mv	a0,s6
 622:	ef7ff0ef          	jal	ra,518 <putc>
 626:	a019                	j	62c <vprintf+0x5a>
    } else if(state == '%'){
 628:	03598263          	beq	s3,s5,64c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 62c:	2485                	addiw	s1,s1,1
 62e:	8726                	mv	a4,s1
 630:	009a07b3          	add	a5,s4,s1
 634:	0007c903          	lbu	s2,0(a5)
 638:	20090a63          	beqz	s2,84c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 63c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 640:	fe0994e3          	bnez	s3,628 <vprintf+0x56>
      if(c0 == '%'){
 644:	fd579de3          	bne	a5,s5,61e <vprintf+0x4c>
        state = '%';
 648:	89be                	mv	s3,a5
 64a:	b7cd                	j	62c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 64c:	c3c1                	beqz	a5,6cc <vprintf+0xfa>
 64e:	00ea06b3          	add	a3,s4,a4
 652:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 656:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 658:	c681                	beqz	a3,660 <vprintf+0x8e>
 65a:	9752                	add	a4,a4,s4
 65c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 660:	03878e63          	beq	a5,s8,69c <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 664:	05a78863          	beq	a5,s10,6b4 <vprintf+0xe2>
      } else if(c0 == 'u'){
 668:	0db78b63          	beq	a5,s11,73e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 66c:	07800713          	li	a4,120
 670:	10e78d63          	beq	a5,a4,78a <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 674:	07000713          	li	a4,112
 678:	14e78263          	beq	a5,a4,7bc <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 67c:	06300713          	li	a4,99
 680:	16e78f63          	beq	a5,a4,7fe <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 684:	07300713          	li	a4,115
 688:	18e78563          	beq	a5,a4,812 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 68c:	05579063          	bne	a5,s5,6cc <vprintf+0xfa>
        putc(fd, '%');
 690:	85d6                	mv	a1,s5
 692:	855a                	mv	a0,s6
 694:	e85ff0ef          	jal	ra,518 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 698:	4981                	li	s3,0
 69a:	bf49                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 69c:	008b8913          	addi	s2,s7,8
 6a0:	4685                	li	a3,1
 6a2:	4629                	li	a2,10
 6a4:	000ba583          	lw	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	e8dff0ef          	jal	ra,536 <printint>
 6ae:	8bca                	mv	s7,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bfad                	j	62c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 6b4:	03868663          	beq	a3,s8,6e0 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b8:	05a68163          	beq	a3,s10,6fa <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 6bc:	09b68d63          	beq	a3,s11,756 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6c0:	03a68f63          	beq	a3,s10,6fe <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 6c4:	07800793          	li	a5,120
 6c8:	0cf68d63          	beq	a3,a5,7a2 <vprintf+0x1d0>
        putc(fd, '%');
 6cc:	85d6                	mv	a1,s5
 6ce:	855a                	mv	a0,s6
 6d0:	e49ff0ef          	jal	ra,518 <putc>
        putc(fd, c0);
 6d4:	85ca                	mv	a1,s2
 6d6:	855a                	mv	a0,s6
 6d8:	e41ff0ef          	jal	ra,518 <putc>
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b7b9                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4685                	li	a3,1
 6e6:	4629                	li	a2,10
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	e49ff0ef          	jal	ra,536 <printint>
        i += 1;
 6f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 1;
 6f8:	bf15                	j	62c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6fa:	03860563          	beq	a2,s8,724 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6fe:	07b60963          	beq	a2,s11,770 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 702:	07800793          	li	a5,120
 706:	fcf613e3          	bne	a2,a5,6cc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 70a:	008b8913          	addi	s2,s7,8
 70e:	4681                	li	a3,0
 710:	4641                	li	a2,16
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	e1fff0ef          	jal	ra,536 <printint>
        i += 2;
 71c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 71e:	8bca                	mv	s7,s2
      state = 0;
 720:	4981                	li	s3,0
        i += 2;
 722:	b729                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 724:	008b8913          	addi	s2,s7,8
 728:	4685                	li	a3,1
 72a:	4629                	li	a2,10
 72c:	000bb583          	ld	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	e05ff0ef          	jal	ra,536 <printint>
        i += 2;
 736:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 738:	8bca                	mv	s7,s2
      state = 0;
 73a:	4981                	li	s3,0
        i += 2;
 73c:	bdc5                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 73e:	008b8913          	addi	s2,s7,8
 742:	4681                	li	a3,0
 744:	4629                	li	a2,10
 746:	000be583          	lwu	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	debff0ef          	jal	ra,536 <printint>
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bde1                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 756:	008b8913          	addi	s2,s7,8
 75a:	4681                	li	a3,0
 75c:	4629                	li	a2,10
 75e:	000bb583          	ld	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	dd3ff0ef          	jal	ra,536 <printint>
        i += 1;
 768:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 76a:	8bca                	mv	s7,s2
      state = 0;
 76c:	4981                	li	s3,0
        i += 1;
 76e:	bd7d                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 770:	008b8913          	addi	s2,s7,8
 774:	4681                	li	a3,0
 776:	4629                	li	a2,10
 778:	000bb583          	ld	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	db9ff0ef          	jal	ra,536 <printint>
        i += 2;
 782:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 784:	8bca                	mv	s7,s2
      state = 0;
 786:	4981                	li	s3,0
        i += 2;
 788:	b555                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 78a:	008b8913          	addi	s2,s7,8
 78e:	4681                	li	a3,0
 790:	4641                	li	a2,16
 792:	000be583          	lwu	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	d9fff0ef          	jal	ra,536 <printint>
 79c:	8bca                	mv	s7,s2
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b571                	j	62c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a2:	008b8913          	addi	s2,s7,8
 7a6:	4681                	li	a3,0
 7a8:	4641                	li	a2,16
 7aa:	000bb583          	ld	a1,0(s7)
 7ae:	855a                	mv	a0,s6
 7b0:	d87ff0ef          	jal	ra,536 <printint>
        i += 1;
 7b4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b6:	8bca                	mv	s7,s2
      state = 0;
 7b8:	4981                	li	s3,0
        i += 1;
 7ba:	bd8d                	j	62c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 7bc:	008b8793          	addi	a5,s7,8
 7c0:	f8f43423          	sd	a5,-120(s0)
 7c4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7c8:	03000593          	li	a1,48
 7cc:	855a                	mv	a0,s6
 7ce:	d4bff0ef          	jal	ra,518 <putc>
  putc(fd, 'x');
 7d2:	07800593          	li	a1,120
 7d6:	855a                	mv	a0,s6
 7d8:	d41ff0ef          	jal	ra,518 <putc>
 7dc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7de:	03c9d793          	srli	a5,s3,0x3c
 7e2:	97e6                	add	a5,a5,s9
 7e4:	0007c583          	lbu	a1,0(a5)
 7e8:	855a                	mv	a0,s6
 7ea:	d2fff0ef          	jal	ra,518 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ee:	0992                	slli	s3,s3,0x4
 7f0:	397d                	addiw	s2,s2,-1
 7f2:	fe0916e3          	bnez	s2,7de <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7f6:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	bd05                	j	62c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7fe:	008b8913          	addi	s2,s7,8
 802:	000bc583          	lbu	a1,0(s7)
 806:	855a                	mv	a0,s6
 808:	d11ff0ef          	jal	ra,518 <putc>
 80c:	8bca                	mv	s7,s2
      state = 0;
 80e:	4981                	li	s3,0
 810:	bd31                	j	62c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 812:	008b8993          	addi	s3,s7,8
 816:	000bb903          	ld	s2,0(s7)
 81a:	00090f63          	beqz	s2,838 <vprintf+0x266>
        for(; *s; s++)
 81e:	00094583          	lbu	a1,0(s2)
 822:	c195                	beqz	a1,846 <vprintf+0x274>
          putc(fd, *s);
 824:	855a                	mv	a0,s6
 826:	cf3ff0ef          	jal	ra,518 <putc>
        for(; *s; s++)
 82a:	0905                	addi	s2,s2,1
 82c:	00094583          	lbu	a1,0(s2)
 830:	f9f5                	bnez	a1,824 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 832:	8bce                	mv	s7,s3
      state = 0;
 834:	4981                	li	s3,0
 836:	bbdd                	j	62c <vprintf+0x5a>
          s = "(null)";
 838:	00000917          	auipc	s2,0x0
 83c:	48890913          	addi	s2,s2,1160 # cc0 <malloc+0x372>
        for(; *s; s++)
 840:	02800593          	li	a1,40
 844:	b7c5                	j	824 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 846:	8bce                	mv	s7,s3
      state = 0;
 848:	4981                	li	s3,0
 84a:	b3cd                	j	62c <vprintf+0x5a>
    }
  }
}
 84c:	70e6                	ld	ra,120(sp)
 84e:	7446                	ld	s0,112(sp)
 850:	74a6                	ld	s1,104(sp)
 852:	7906                	ld	s2,96(sp)
 854:	69e6                	ld	s3,88(sp)
 856:	6a46                	ld	s4,80(sp)
 858:	6aa6                	ld	s5,72(sp)
 85a:	6b06                	ld	s6,64(sp)
 85c:	7be2                	ld	s7,56(sp)
 85e:	7c42                	ld	s8,48(sp)
 860:	7ca2                	ld	s9,40(sp)
 862:	7d02                	ld	s10,32(sp)
 864:	6de2                	ld	s11,24(sp)
 866:	6109                	addi	sp,sp,128
 868:	8082                	ret

000000000000086a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 86a:	715d                	addi	sp,sp,-80
 86c:	ec06                	sd	ra,24(sp)
 86e:	e822                	sd	s0,16(sp)
 870:	1000                	addi	s0,sp,32
 872:	e010                	sd	a2,0(s0)
 874:	e414                	sd	a3,8(s0)
 876:	e818                	sd	a4,16(s0)
 878:	ec1c                	sd	a5,24(s0)
 87a:	03043023          	sd	a6,32(s0)
 87e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 882:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 886:	8622                	mv	a2,s0
 888:	d4bff0ef          	jal	ra,5d2 <vprintf>
}
 88c:	60e2                	ld	ra,24(sp)
 88e:	6442                	ld	s0,16(sp)
 890:	6161                	addi	sp,sp,80
 892:	8082                	ret

0000000000000894 <printf>:

void
printf(const char *fmt, ...)
{
 894:	711d                	addi	sp,sp,-96
 896:	ec06                	sd	ra,24(sp)
 898:	e822                	sd	s0,16(sp)
 89a:	1000                	addi	s0,sp,32
 89c:	e40c                	sd	a1,8(s0)
 89e:	e810                	sd	a2,16(s0)
 8a0:	ec14                	sd	a3,24(s0)
 8a2:	f018                	sd	a4,32(s0)
 8a4:	f41c                	sd	a5,40(s0)
 8a6:	03043823          	sd	a6,48(s0)
 8aa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ae:	00840613          	addi	a2,s0,8
 8b2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b6:	85aa                	mv	a1,a0
 8b8:	4505                	li	a0,1
 8ba:	d19ff0ef          	jal	ra,5d2 <vprintf>
}
 8be:	60e2                	ld	ra,24(sp)
 8c0:	6442                	ld	s0,16(sp)
 8c2:	6125                	addi	sp,sp,96
 8c4:	8082                	ret

00000000000008c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c6:	1141                	addi	sp,sp,-16
 8c8:	e422                	sd	s0,8(sp)
 8ca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8cc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d0:	00000797          	auipc	a5,0x0
 8d4:	7307b783          	ld	a5,1840(a5) # 1000 <freep>
 8d8:	a805                	j	908 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8da:	4618                	lw	a4,8(a2)
 8dc:	9db9                	addw	a1,a1,a4
 8de:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e2:	6398                	ld	a4,0(a5)
 8e4:	6318                	ld	a4,0(a4)
 8e6:	fee53823          	sd	a4,-16(a0)
 8ea:	a091                	j	92e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ec:	ff852703          	lw	a4,-8(a0)
 8f0:	9e39                	addw	a2,a2,a4
 8f2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8f4:	ff053703          	ld	a4,-16(a0)
 8f8:	e398                	sd	a4,0(a5)
 8fa:	a099                	j	940 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fc:	6398                	ld	a4,0(a5)
 8fe:	00e7e463          	bltu	a5,a4,906 <free+0x40>
 902:	00e6ea63          	bltu	a3,a4,916 <free+0x50>
{
 906:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 908:	fed7fae3          	bgeu	a5,a3,8fc <free+0x36>
 90c:	6398                	ld	a4,0(a5)
 90e:	00e6e463          	bltu	a3,a4,916 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 912:	fee7eae3          	bltu	a5,a4,906 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 916:	ff852583          	lw	a1,-8(a0)
 91a:	6390                	ld	a2,0(a5)
 91c:	02059713          	slli	a4,a1,0x20
 920:	9301                	srli	a4,a4,0x20
 922:	0712                	slli	a4,a4,0x4
 924:	9736                	add	a4,a4,a3
 926:	fae60ae3          	beq	a2,a4,8da <free+0x14>
    bp->s.ptr = p->s.ptr;
 92a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 92e:	4790                	lw	a2,8(a5)
 930:	02061713          	slli	a4,a2,0x20
 934:	9301                	srli	a4,a4,0x20
 936:	0712                	slli	a4,a4,0x4
 938:	973e                	add	a4,a4,a5
 93a:	fae689e3          	beq	a3,a4,8ec <free+0x26>
  } else
    p->s.ptr = bp;
 93e:	e394                	sd	a3,0(a5)
  freep = p;
 940:	00000717          	auipc	a4,0x0
 944:	6cf73023          	sd	a5,1728(a4) # 1000 <freep>
}
 948:	6422                	ld	s0,8(sp)
 94a:	0141                	addi	sp,sp,16
 94c:	8082                	ret

000000000000094e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 94e:	7139                	addi	sp,sp,-64
 950:	fc06                	sd	ra,56(sp)
 952:	f822                	sd	s0,48(sp)
 954:	f426                	sd	s1,40(sp)
 956:	f04a                	sd	s2,32(sp)
 958:	ec4e                	sd	s3,24(sp)
 95a:	e852                	sd	s4,16(sp)
 95c:	e456                	sd	s5,8(sp)
 95e:	e05a                	sd	s6,0(sp)
 960:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 962:	02051493          	slli	s1,a0,0x20
 966:	9081                	srli	s1,s1,0x20
 968:	04bd                	addi	s1,s1,15
 96a:	8091                	srli	s1,s1,0x4
 96c:	0014899b          	addiw	s3,s1,1
 970:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 972:	00000517          	auipc	a0,0x0
 976:	68e53503          	ld	a0,1678(a0) # 1000 <freep>
 97a:	c515                	beqz	a0,9a6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97e:	4798                	lw	a4,8(a5)
 980:	02977f63          	bgeu	a4,s1,9be <malloc+0x70>
 984:	8a4e                	mv	s4,s3
 986:	0009871b          	sext.w	a4,s3
 98a:	6685                	lui	a3,0x1
 98c:	00d77363          	bgeu	a4,a3,992 <malloc+0x44>
 990:	6a05                	lui	s4,0x1
 992:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 996:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 99a:	00000917          	auipc	s2,0x0
 99e:	66690913          	addi	s2,s2,1638 # 1000 <freep>
  if(p == SBRK_ERROR)
 9a2:	5afd                	li	s5,-1
 9a4:	a0bd                	j	a12 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 9a6:	00000797          	auipc	a5,0x0
 9aa:	66a78793          	addi	a5,a5,1642 # 1010 <base>
 9ae:	00000717          	auipc	a4,0x0
 9b2:	64f73923          	sd	a5,1618(a4) # 1000 <freep>
 9b6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9b8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9bc:	b7e1                	j	984 <malloc+0x36>
      if(p->s.size == nunits)
 9be:	02e48b63          	beq	s1,a4,9f4 <malloc+0xa6>
        p->s.size -= nunits;
 9c2:	4137073b          	subw	a4,a4,s3
 9c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c8:	1702                	slli	a4,a4,0x20
 9ca:	9301                	srli	a4,a4,0x20
 9cc:	0712                	slli	a4,a4,0x4
 9ce:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9d0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d4:	00000717          	auipc	a4,0x0
 9d8:	62a73623          	sd	a0,1580(a4) # 1000 <freep>
      return (void*)(p + 1);
 9dc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9e0:	70e2                	ld	ra,56(sp)
 9e2:	7442                	ld	s0,48(sp)
 9e4:	74a2                	ld	s1,40(sp)
 9e6:	7902                	ld	s2,32(sp)
 9e8:	69e2                	ld	s3,24(sp)
 9ea:	6a42                	ld	s4,16(sp)
 9ec:	6aa2                	ld	s5,8(sp)
 9ee:	6b02                	ld	s6,0(sp)
 9f0:	6121                	addi	sp,sp,64
 9f2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9f4:	6398                	ld	a4,0(a5)
 9f6:	e118                	sd	a4,0(a0)
 9f8:	bff1                	j	9d4 <malloc+0x86>
  hp->s.size = nu;
 9fa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9fe:	0541                	addi	a0,a0,16
 a00:	ec7ff0ef          	jal	ra,8c6 <free>
  return freep;
 a04:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a08:	dd61                	beqz	a0,9e0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0c:	4798                	lw	a4,8(a5)
 a0e:	fa9778e3          	bgeu	a4,s1,9be <malloc+0x70>
    if(p == freep)
 a12:	00093703          	ld	a4,0(s2)
 a16:	853e                	mv	a0,a5
 a18:	fef719e3          	bne	a4,a5,a0a <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 a1c:	8552                	mv	a0,s4
 a1e:	a17ff0ef          	jal	ra,434 <sbrk>
  if(p == SBRK_ERROR)
 a22:	fd551ce3          	bne	a0,s5,9fa <malloc+0xac>
        return 0;
 a26:	4501                	li	a0,0
 a28:	bf65                	j	9e0 <malloc+0x92>
