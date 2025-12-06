
user/_diagtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

// Diagnostic test to check if time slices are being tracked
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
  10:	1080                	addi	s0,sp,96
  struct procinfo info;
  
  printf("=== MLFQ Diagnostics ===\n\n");
  12:	00001517          	auipc	a0,0x1
  16:	a3e50513          	addi	a0,a0,-1474 # a50 <malloc+0xfc>
  1a:	087000ef          	jal	8a0 <printf>
  
  // Check initial state
  if(getprocinfo(&info) == 0) {
  1e:	fb040513          	addi	a0,s0,-80
  22:	4e6000ef          	jal	508 <getprocinfo>
  26:	c11d                	beqz	a0,4c <main+0x4c>
    printf("  Priority: Q%d\n", info.priority);
    printf("  Time Slices: %d\n\n", info.time_slices);
  }
  
  // Do a small amount of work and check repeatedly
  printf("Running work bursts and checking time_slices:\n");
  28:	00001517          	auipc	a0,0x1
  2c:	aa850513          	addi	a0,a0,-1368 # ad0 <malloc+0x17c>
  30:	071000ef          	jal	8a0 <printf>
  for(int i = 0; i < 20; i++) {
  34:	4481                	li	s1,0
    // Work burst - enough to trigger timer interrupts
    volatile int dummy = 0;
  36:	004c5937          	lui	s2,0x4c5
  3a:	b4090913          	addi	s2,s2,-1216 # 4c4b40 <base+0x4c2b30>
  for(int i = 0; i < 20; i++) {
  3e:	49d1                	li	s3,20
    for(int j = 0; j < 5000000; j++) {
      dummy++;
    }
    
    if(getprocinfo(&info) == 0) {
      printf("  Iteration %2d: slices=%d priority=Q%d\n", 
  40:	00001a97          	auipc	s5,0x1
  44:	ac0a8a93          	addi	s5,s5,-1344 # b00 <malloc+0x1ac>
             i, info.time_slices, info.priority);
      
      // If time_slices is still 0 after 10 iterations, something is wrong
      if(i == 10 && info.time_slices == 0) {
  48:	4a29                	li	s4,10
  4a:	a049                	j	cc <main+0xcc>
    printf("Initial state:\n");
  4c:	00001517          	auipc	a0,0x1
  50:	a2450513          	addi	a0,a0,-1500 # a70 <malloc+0x11c>
  54:	04d000ef          	jal	8a0 <printf>
    printf("  PID: %d\n", info.pid);
  58:	fb042583          	lw	a1,-80(s0)
  5c:	00001517          	auipc	a0,0x1
  60:	a2450513          	addi	a0,a0,-1500 # a80 <malloc+0x12c>
  64:	03d000ef          	jal	8a0 <printf>
    printf("  State: %d\n", info.state);
  68:	fb442583          	lw	a1,-76(s0)
  6c:	00001517          	auipc	a0,0x1
  70:	a2450513          	addi	a0,a0,-1500 # a90 <malloc+0x13c>
  74:	02d000ef          	jal	8a0 <printf>
    printf("  Priority: Q%d\n", info.priority);
  78:	fb842583          	lw	a1,-72(s0)
  7c:	00001517          	auipc	a0,0x1
  80:	a2450513          	addi	a0,a0,-1500 # aa0 <malloc+0x14c>
  84:	01d000ef          	jal	8a0 <printf>
    printf("  Time Slices: %d\n\n", info.time_slices);
  88:	fbc42583          	lw	a1,-68(s0)
  8c:	00001517          	auipc	a0,0x1
  90:	a2c50513          	addi	a0,a0,-1492 # ab8 <malloc+0x164>
  94:	00d000ef          	jal	8a0 <printf>
  98:	bf41                	j	28 <main+0x28>
      if(i == 10 && info.time_slices == 0) {
  9a:	fbc42783          	lw	a5,-68(s0)
  9e:	c799                	beqz	a5,ac <main+0xac>
        printf("*** Timer interrupts may not be working ***\n\n");
        break;
      }
      
      // If we see demotion, report it
      if(info.priority > 0) {
  a0:	fb842583          	lw	a1,-72(s0)
  a4:	06b04163          	bgtz	a1,106 <main+0x106>
  for(int i = 0; i < 20; i++) {
  a8:	2485                	addiw	s1,s1,1
  aa:	a00d                	j	cc <main+0xcc>
        printf("\n*** ERROR: time_slices not incrementing! ***\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	a8450513          	addi	a0,a0,-1404 # b30 <malloc+0x1dc>
  b4:	7ec000ef          	jal	8a0 <printf>
        printf("*** Timer interrupts may not be working ***\n\n");
  b8:	00001517          	auipc	a0,0x1
  bc:	aa850513          	addi	a0,a0,-1368 # b60 <malloc+0x20c>
  c0:	7e0000ef          	jal	8a0 <printf>
        break;
  c4:	a889                	j	116 <main+0x116>
  for(int i = 0; i < 20; i++) {
  c6:	2485                	addiw	s1,s1,1
  c8:	05348763          	beq	s1,s3,116 <main+0x116>
    volatile int dummy = 0;
  cc:	fa042623          	sw	zero,-84(s0)
  d0:	874a                	mv	a4,s2
      dummy++;
  d2:	fac42783          	lw	a5,-84(s0)
  d6:	2785                	addiw	a5,a5,1
  d8:	faf42623          	sw	a5,-84(s0)
    for(int j = 0; j < 5000000; j++) {
  dc:	377d                	addiw	a4,a4,-1
  de:	fb75                	bnez	a4,d2 <main+0xd2>
    if(getprocinfo(&info) == 0) {
  e0:	fb040513          	addi	a0,s0,-80
  e4:	424000ef          	jal	508 <getprocinfo>
  e8:	fd79                	bnez	a0,c6 <main+0xc6>
      printf("  Iteration %2d: slices=%d priority=Q%d\n", 
  ea:	fb842683          	lw	a3,-72(s0)
  ee:	fbc42603          	lw	a2,-68(s0)
  f2:	85a6                	mv	a1,s1
  f4:	8556                	mv	a0,s5
  f6:	7aa000ef          	jal	8a0 <printf>
      if(i == 10 && info.time_slices == 0) {
  fa:	fb4480e3          	beq	s1,s4,9a <main+0x9a>
      if(info.priority > 0) {
  fe:	fb842583          	lw	a1,-72(s0)
 102:	fcb052e3          	blez	a1,c6 <main+0xc6>
        printf("\n*** GOOD: Process demoted to Q%d after %d slices! ***\n\n", 
 106:	fbc42603          	lw	a2,-68(s0)
 10a:	00001517          	auipc	a0,0x1
 10e:	a8650513          	addi	a0,a0,-1402 # b90 <malloc+0x23c>
 112:	78e000ef          	jal	8a0 <printf>
      }
    }
  }
  
  // Final state
  if(getprocinfo(&info) == 0) {
 116:	fb040513          	addi	a0,s0,-80
 11a:	3ee000ef          	jal	508 <getprocinfo>
 11e:	c501                	beqz	a0,126 <main+0x126>
      printf("\n=== SUCCESS ===\n");
      printf("Time slice tracking is working!\n");
    }
  }
  
  exit(0);
 120:	4501                	li	a0,0
 122:	346000ef          	jal	468 <exit>
    printf("\nFinal state:\n");
 126:	00001517          	auipc	a0,0x1
 12a:	aaa50513          	addi	a0,a0,-1366 # bd0 <malloc+0x27c>
 12e:	772000ef          	jal	8a0 <printf>
    printf("  Priority: Q%d\n", info.priority);
 132:	fb842583          	lw	a1,-72(s0)
 136:	00001517          	auipc	a0,0x1
 13a:	96a50513          	addi	a0,a0,-1686 # aa0 <malloc+0x14c>
 13e:	762000ef          	jal	8a0 <printf>
    printf("  Time Slices: %d\n", info.time_slices);
 142:	fbc42583          	lw	a1,-68(s0)
 146:	00001517          	auipc	a0,0x1
 14a:	a9a50513          	addi	a0,a0,-1382 # be0 <malloc+0x28c>
 14e:	752000ef          	jal	8a0 <printf>
    if(info.time_slices == 0) {
 152:	fbc42783          	lw	a5,-68(s0)
 156:	e3b5                	bnez	a5,1ba <main+0x1ba>
      printf("\n=== DIAGNOSIS ===\n");
 158:	00001517          	auipc	a0,0x1
 15c:	aa050513          	addi	a0,a0,-1376 # bf8 <malloc+0x2a4>
 160:	740000ef          	jal	8a0 <printf>
      printf("Problem: time_slices never incremented\n");
 164:	00001517          	auipc	a0,0x1
 168:	aac50513          	addi	a0,a0,-1364 # c10 <malloc+0x2bc>
 16c:	734000ef          	jal	8a0 <printf>
      printf("Possible causes:\n");
 170:	00001517          	auipc	a0,0x1
 174:	ac850513          	addi	a0,a0,-1336 # c38 <malloc+0x2e4>
 178:	728000ef          	jal	8a0 <printf>
      printf("  1. Timer interrupts not firing (check clockintr)\n");
 17c:	00001517          	auipc	a0,0x1
 180:	ad450513          	addi	a0,a0,-1324 # c50 <malloc+0x2fc>
 184:	71c000ef          	jal	8a0 <printf>
      printf("  2. which_dev != 2 in usertrap()\n");
 188:	00001517          	auipc	a0,0x1
 18c:	b0050513          	addi	a0,a0,-1280 # c88 <malloc+0x334>
 190:	710000ef          	jal	8a0 <printf>
      printf("  3. p->time_slices++ not executing\n");
 194:	00001517          	auipc	a0,0x1
 198:	b1c50513          	addi	a0,a0,-1252 # cb0 <malloc+0x35c>
 19c:	704000ef          	jal	8a0 <printf>
      printf("\nAdd debug prints in kernel/trap.c:\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	b3850513          	addi	a0,a0,-1224 # cd8 <malloc+0x384>
 1a8:	6f8000ef          	jal	8a0 <printf>
      printf("  printf(\"Timer: which_dev=%%d pid=%%d\\n\", which_dev, p->pid);\n");
 1ac:	00001517          	auipc	a0,0x1
 1b0:	b5450513          	addi	a0,a0,-1196 # d00 <malloc+0x3ac>
 1b4:	6ec000ef          	jal	8a0 <printf>
 1b8:	b7a5                	j	120 <main+0x120>
      printf("\n=== SUCCESS ===\n");
 1ba:	00001517          	auipc	a0,0x1
 1be:	b8650513          	addi	a0,a0,-1146 # d40 <malloc+0x3ec>
 1c2:	6de000ef          	jal	8a0 <printf>
      printf("Time slice tracking is working!\n");
 1c6:	00001517          	auipc	a0,0x1
 1ca:	b9250513          	addi	a0,a0,-1134 # d58 <malloc+0x404>
 1ce:	6d2000ef          	jal	8a0 <printf>
 1d2:	b7b9                	j	120 <main+0x120>

00000000000001d4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e406                	sd	ra,8(sp)
 1d8:	e022                	sd	s0,0(sp)
 1da:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1dc:	e25ff0ef          	jal	0 <main>
  exit(r);
 1e0:	288000ef          	jal	468 <exit>

00000000000001e4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ea:	87aa                	mv	a5,a0
 1ec:	0585                	addi	a1,a1,1
 1ee:	0785                	addi	a5,a5,1
 1f0:	fff5c703          	lbu	a4,-1(a1)
 1f4:	fee78fa3          	sb	a4,-1(a5)
 1f8:	fb75                	bnez	a4,1ec <strcpy+0x8>
    ;
  return os;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb91                	beqz	a5,21e <strcmp+0x1e>
 20c:	0005c703          	lbu	a4,0(a1)
 210:	00f71763          	bne	a4,a5,21e <strcmp+0x1e>
    p++, q++;
 214:	0505                	addi	a0,a0,1
 216:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 218:	00054783          	lbu	a5,0(a0)
 21c:	fbe5                	bnez	a5,20c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 21e:	0005c503          	lbu	a0,0(a1)
}
 222:	40a7853b          	subw	a0,a5,a0
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <strlen>:

uint
strlen(const char *s)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 232:	00054783          	lbu	a5,0(a0)
 236:	cf91                	beqz	a5,252 <strlen+0x26>
 238:	0505                	addi	a0,a0,1
 23a:	87aa                	mv	a5,a0
 23c:	86be                	mv	a3,a5
 23e:	0785                	addi	a5,a5,1
 240:	fff7c703          	lbu	a4,-1(a5)
 244:	ff65                	bnez	a4,23c <strlen+0x10>
 246:	40a6853b          	subw	a0,a3,a0
 24a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret
  for(n = 0; s[n]; n++)
 252:	4501                	li	a0,0
 254:	bfe5                	j	24c <strlen+0x20>

0000000000000256 <memset>:

void*
memset(void *dst, int c, uint n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 25c:	ca19                	beqz	a2,272 <memset+0x1c>
 25e:	87aa                	mv	a5,a0
 260:	1602                	slli	a2,a2,0x20
 262:	9201                	srli	a2,a2,0x20
 264:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 268:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 26c:	0785                	addi	a5,a5,1
 26e:	fee79de3          	bne	a5,a4,268 <memset+0x12>
  }
  return dst;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret

0000000000000278 <strchr>:

char*
strchr(const char *s, char c)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 27e:	00054783          	lbu	a5,0(a0)
 282:	cb99                	beqz	a5,298 <strchr+0x20>
    if(*s == c)
 284:	00f58763          	beq	a1,a5,292 <strchr+0x1a>
  for(; *s; s++)
 288:	0505                	addi	a0,a0,1
 28a:	00054783          	lbu	a5,0(a0)
 28e:	fbfd                	bnez	a5,284 <strchr+0xc>
      return (char*)s;
  return 0;
 290:	4501                	li	a0,0
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
  return 0;
 298:	4501                	li	a0,0
 29a:	bfe5                	j	292 <strchr+0x1a>

000000000000029c <gets>:

char*
gets(char *buf, int max)
{
 29c:	711d                	addi	sp,sp,-96
 29e:	ec86                	sd	ra,88(sp)
 2a0:	e8a2                	sd	s0,80(sp)
 2a2:	e4a6                	sd	s1,72(sp)
 2a4:	e0ca                	sd	s2,64(sp)
 2a6:	fc4e                	sd	s3,56(sp)
 2a8:	f852                	sd	s4,48(sp)
 2aa:	f456                	sd	s5,40(sp)
 2ac:	f05a                	sd	s6,32(sp)
 2ae:	ec5e                	sd	s7,24(sp)
 2b0:	1080                	addi	s0,sp,96
 2b2:	8baa                	mv	s7,a0
 2b4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b6:	892a                	mv	s2,a0
 2b8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ba:	4aa9                	li	s5,10
 2bc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2be:	89a6                	mv	s3,s1
 2c0:	2485                	addiw	s1,s1,1
 2c2:	0344d663          	bge	s1,s4,2ee <gets+0x52>
    cc = read(0, &c, 1);
 2c6:	4605                	li	a2,1
 2c8:	faf40593          	addi	a1,s0,-81
 2cc:	4501                	li	a0,0
 2ce:	1b2000ef          	jal	480 <read>
    if(cc < 1)
 2d2:	00a05e63          	blez	a0,2ee <gets+0x52>
    buf[i++] = c;
 2d6:	faf44783          	lbu	a5,-81(s0)
 2da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2de:	01578763          	beq	a5,s5,2ec <gets+0x50>
 2e2:	0905                	addi	s2,s2,1
 2e4:	fd679de3          	bne	a5,s6,2be <gets+0x22>
    buf[i++] = c;
 2e8:	89a6                	mv	s3,s1
 2ea:	a011                	j	2ee <gets+0x52>
 2ec:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ee:	99de                	add	s3,s3,s7
 2f0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f4:	855e                	mv	a0,s7
 2f6:	60e6                	ld	ra,88(sp)
 2f8:	6446                	ld	s0,80(sp)
 2fa:	64a6                	ld	s1,72(sp)
 2fc:	6906                	ld	s2,64(sp)
 2fe:	79e2                	ld	s3,56(sp)
 300:	7a42                	ld	s4,48(sp)
 302:	7aa2                	ld	s5,40(sp)
 304:	7b02                	ld	s6,32(sp)
 306:	6be2                	ld	s7,24(sp)
 308:	6125                	addi	sp,sp,96
 30a:	8082                	ret

000000000000030c <stat>:

int
stat(const char *n, struct stat *st)
{
 30c:	1101                	addi	sp,sp,-32
 30e:	ec06                	sd	ra,24(sp)
 310:	e822                	sd	s0,16(sp)
 312:	e04a                	sd	s2,0(sp)
 314:	1000                	addi	s0,sp,32
 316:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 318:	4581                	li	a1,0
 31a:	18e000ef          	jal	4a8 <open>
  if(fd < 0)
 31e:	02054263          	bltz	a0,342 <stat+0x36>
 322:	e426                	sd	s1,8(sp)
 324:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 326:	85ca                	mv	a1,s2
 328:	198000ef          	jal	4c0 <fstat>
 32c:	892a                	mv	s2,a0
  close(fd);
 32e:	8526                	mv	a0,s1
 330:	160000ef          	jal	490 <close>
  return r;
 334:	64a2                	ld	s1,8(sp)
}
 336:	854a                	mv	a0,s2
 338:	60e2                	ld	ra,24(sp)
 33a:	6442                	ld	s0,16(sp)
 33c:	6902                	ld	s2,0(sp)
 33e:	6105                	addi	sp,sp,32
 340:	8082                	ret
    return -1;
 342:	597d                	li	s2,-1
 344:	bfcd                	j	336 <stat+0x2a>

0000000000000346 <atoi>:

int
atoi(const char *s)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34c:	00054683          	lbu	a3,0(a0)
 350:	fd06879b          	addiw	a5,a3,-48
 354:	0ff7f793          	zext.b	a5,a5
 358:	4625                	li	a2,9
 35a:	02f66863          	bltu	a2,a5,38a <atoi+0x44>
 35e:	872a                	mv	a4,a0
  n = 0;
 360:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 362:	0705                	addi	a4,a4,1
 364:	0025179b          	slliw	a5,a0,0x2
 368:	9fa9                	addw	a5,a5,a0
 36a:	0017979b          	slliw	a5,a5,0x1
 36e:	9fb5                	addw	a5,a5,a3
 370:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 374:	00074683          	lbu	a3,0(a4)
 378:	fd06879b          	addiw	a5,a3,-48
 37c:	0ff7f793          	zext.b	a5,a5
 380:	fef671e3          	bgeu	a2,a5,362 <atoi+0x1c>
  return n;
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
  n = 0;
 38a:	4501                	li	a0,0
 38c:	bfe5                	j	384 <atoi+0x3e>

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
 3b2:	fef71ae3          	bne	a4,a5,3a6 <memmove+0x18>
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
 428:	f67ff0ef          	jal	38e <memmove>
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
 43e:	0b2000ef          	jal	4f0 <sys_sbrk>
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
 454:	09c000ef          	jal	4f0 <sys_sbrk>
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
 52a:	f5fff0ef          	jal	488 <write>
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
 53c:	f84a                	sd	s2,48(sp)
 53e:	0880                	addi	s0,sp,80
 540:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 542:	c299                	beqz	a3,548 <printint+0x12>
 544:	0805c363          	bltz	a1,5ca <printint+0x94>
  neg = 0;
 548:	4881                	li	a7,0
 54a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 54e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 550:	00001517          	auipc	a0,0x1
 554:	83850513          	addi	a0,a0,-1992 # d88 <digits>
 558:	883e                	mv	a6,a5
 55a:	2785                	addiw	a5,a5,1
 55c:	02c5f733          	remu	a4,a1,a2
 560:	972a                	add	a4,a4,a0
 562:	00074703          	lbu	a4,0(a4)
 566:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 56a:	872e                	mv	a4,a1
 56c:	02c5d5b3          	divu	a1,a1,a2
 570:	0685                	addi	a3,a3,1
 572:	fec773e3          	bgeu	a4,a2,558 <printint+0x22>
  if(neg)
 576:	00088b63          	beqz	a7,58c <printint+0x56>
    buf[i++] = '-';
 57a:	fd078793          	addi	a5,a5,-48
 57e:	97a2                	add	a5,a5,s0
 580:	02d00713          	li	a4,45
 584:	fee78423          	sb	a4,-24(a5)
 588:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 58c:	02f05a63          	blez	a5,5c0 <printint+0x8a>
 590:	fc26                	sd	s1,56(sp)
 592:	f44e                	sd	s3,40(sp)
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
 5b2:	f67ff0ef          	jal	518 <putc>
  while(--i >= 0)
 5b6:	14fd                	addi	s1,s1,-1
 5b8:	ff349ae3          	bne	s1,s3,5ac <printint+0x76>
 5bc:	74e2                	ld	s1,56(sp)
 5be:	79a2                	ld	s3,40(sp)
}
 5c0:	60a6                	ld	ra,72(sp)
 5c2:	6406                	ld	s0,64(sp)
 5c4:	7942                	ld	s2,48(sp)
 5c6:	6161                	addi	sp,sp,80
 5c8:	8082                	ret
    x = -xx;
 5ca:	40b005b3          	neg	a1,a1
    neg = 1;
 5ce:	4885                	li	a7,1
    x = -xx;
 5d0:	bfad                	j	54a <printint+0x14>

00000000000005d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d2:	711d                	addi	sp,sp,-96
 5d4:	ec86                	sd	ra,88(sp)
 5d6:	e8a2                	sd	s0,80(sp)
 5d8:	e0ca                	sd	s2,64(sp)
 5da:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5dc:	0005c903          	lbu	s2,0(a1)
 5e0:	28090663          	beqz	s2,86c <vprintf+0x29a>
 5e4:	e4a6                	sd	s1,72(sp)
 5e6:	fc4e                	sd	s3,56(sp)
 5e8:	f852                	sd	s4,48(sp)
 5ea:	f456                	sd	s5,40(sp)
 5ec:	f05a                	sd	s6,32(sp)
 5ee:	ec5e                	sd	s7,24(sp)
 5f0:	e862                	sd	s8,16(sp)
 5f2:	e466                	sd	s9,8(sp)
 5f4:	8b2a                	mv	s6,a0
 5f6:	8a2e                	mv	s4,a1
 5f8:	8bb2                	mv	s7,a2
  state = 0;
 5fa:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5fc:	4481                	li	s1,0
 5fe:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 600:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 604:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 608:	06c00c93          	li	s9,108
 60c:	a005                	j	62c <vprintf+0x5a>
        putc(fd, c0);
 60e:	85ca                	mv	a1,s2
 610:	855a                	mv	a0,s6
 612:	f07ff0ef          	jal	518 <putc>
 616:	a019                	j	61c <vprintf+0x4a>
    } else if(state == '%'){
 618:	03598263          	beq	s3,s5,63c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 61c:	2485                	addiw	s1,s1,1
 61e:	8726                	mv	a4,s1
 620:	009a07b3          	add	a5,s4,s1
 624:	0007c903          	lbu	s2,0(a5)
 628:	22090a63          	beqz	s2,85c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 62c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 630:	fe0994e3          	bnez	s3,618 <vprintf+0x46>
      if(c0 == '%'){
 634:	fd579de3          	bne	a5,s5,60e <vprintf+0x3c>
        state = '%';
 638:	89be                	mv	s3,a5
 63a:	b7cd                	j	61c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 63c:	00ea06b3          	add	a3,s4,a4
 640:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 644:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 646:	c681                	beqz	a3,64e <vprintf+0x7c>
 648:	9752                	add	a4,a4,s4
 64a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 64e:	05878363          	beq	a5,s8,694 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 652:	05978d63          	beq	a5,s9,6ac <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 656:	07500713          	li	a4,117
 65a:	0ee78763          	beq	a5,a4,748 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 65e:	07800713          	li	a4,120
 662:	12e78963          	beq	a5,a4,794 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 666:	07000713          	li	a4,112
 66a:	14e78e63          	beq	a5,a4,7c6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 66e:	06300713          	li	a4,99
 672:	18e78e63          	beq	a5,a4,80e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 676:	07300713          	li	a4,115
 67a:	1ae78463          	beq	a5,a4,822 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 67e:	02500713          	li	a4,37
 682:	04e79563          	bne	a5,a4,6cc <vprintf+0xfa>
        putc(fd, '%');
 686:	02500593          	li	a1,37
 68a:	855a                	mv	a0,s6
 68c:	e8dff0ef          	jal	518 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 690:	4981                	li	s3,0
 692:	b769                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 694:	008b8913          	addi	s2,s7,8
 698:	4685                	li	a3,1
 69a:	4629                	li	a2,10
 69c:	000ba583          	lw	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	e95ff0ef          	jal	536 <printint>
 6a6:	8bca                	mv	s7,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bf8d                	j	61c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6ac:	06400793          	li	a5,100
 6b0:	02f68963          	beq	a3,a5,6e2 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b4:	06c00793          	li	a5,108
 6b8:	04f68263          	beq	a3,a5,6fc <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6bc:	07500793          	li	a5,117
 6c0:	0af68063          	beq	a3,a5,760 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6c4:	07800793          	li	a5,120
 6c8:	0ef68263          	beq	a3,a5,7ac <vprintf+0x1da>
        putc(fd, '%');
 6cc:	02500593          	li	a1,37
 6d0:	855a                	mv	a0,s6
 6d2:	e47ff0ef          	jal	518 <putc>
        putc(fd, c0);
 6d6:	85ca                	mv	a1,s2
 6d8:	855a                	mv	a0,s6
 6da:	e3fff0ef          	jal	518 <putc>
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bf35                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	4685                	li	a3,1
 6e8:	4629                	li	a2,10
 6ea:	000bb583          	ld	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	e47ff0ef          	jal	536 <printint>
        i += 1;
 6f4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f6:	8bca                	mv	s7,s2
      state = 0;
 6f8:	4981                	li	s3,0
        i += 1;
 6fa:	b70d                	j	61c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6fc:	06400793          	li	a5,100
 700:	02f60763          	beq	a2,a5,72e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 704:	07500793          	li	a5,117
 708:	06f60963          	beq	a2,a5,77a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 70c:	07800793          	li	a5,120
 710:	faf61ee3          	bne	a2,a5,6cc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 714:	008b8913          	addi	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4641                	li	a2,16
 71c:	000bb583          	ld	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	e15ff0ef          	jal	536 <printint>
        i += 2;
 726:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
        i += 2;
 72c:	bdc5                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 72e:	008b8913          	addi	s2,s7,8
 732:	4685                	li	a3,1
 734:	4629                	li	a2,10
 736:	000bb583          	ld	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	dfbff0ef          	jal	536 <printint>
        i += 2;
 740:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
        i += 2;
 746:	bdd9                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 748:	008b8913          	addi	s2,s7,8
 74c:	4681                	li	a3,0
 74e:	4629                	li	a2,10
 750:	000be583          	lwu	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	de1ff0ef          	jal	536 <printint>
 75a:	8bca                	mv	s7,s2
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bd7d                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 760:	008b8913          	addi	s2,s7,8
 764:	4681                	li	a3,0
 766:	4629                	li	a2,10
 768:	000bb583          	ld	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	dc9ff0ef          	jal	536 <printint>
        i += 1;
 772:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 774:	8bca                	mv	s7,s2
      state = 0;
 776:	4981                	li	s3,0
        i += 1;
 778:	b555                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77a:	008b8913          	addi	s2,s7,8
 77e:	4681                	li	a3,0
 780:	4629                	li	a2,10
 782:	000bb583          	ld	a1,0(s7)
 786:	855a                	mv	a0,s6
 788:	dafff0ef          	jal	536 <printint>
        i += 2;
 78c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 78e:	8bca                	mv	s7,s2
      state = 0;
 790:	4981                	li	s3,0
        i += 2;
 792:	b569                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 794:	008b8913          	addi	s2,s7,8
 798:	4681                	li	a3,0
 79a:	4641                	li	a2,16
 79c:	000be583          	lwu	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	d95ff0ef          	jal	536 <printint>
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bd8d                	j	61c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ac:	008b8913          	addi	s2,s7,8
 7b0:	4681                	li	a3,0
 7b2:	4641                	li	a2,16
 7b4:	000bb583          	ld	a1,0(s7)
 7b8:	855a                	mv	a0,s6
 7ba:	d7dff0ef          	jal	536 <printint>
        i += 1;
 7be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c0:	8bca                	mv	s7,s2
      state = 0;
 7c2:	4981                	li	s3,0
        i += 1;
 7c4:	bda1                	j	61c <vprintf+0x4a>
 7c6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7c8:	008b8d13          	addi	s10,s7,8
 7cc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7d0:	03000593          	li	a1,48
 7d4:	855a                	mv	a0,s6
 7d6:	d43ff0ef          	jal	518 <putc>
  putc(fd, 'x');
 7da:	07800593          	li	a1,120
 7de:	855a                	mv	a0,s6
 7e0:	d39ff0ef          	jal	518 <putc>
 7e4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7e6:	00000b97          	auipc	s7,0x0
 7ea:	5a2b8b93          	addi	s7,s7,1442 # d88 <digits>
 7ee:	03c9d793          	srli	a5,s3,0x3c
 7f2:	97de                	add	a5,a5,s7
 7f4:	0007c583          	lbu	a1,0(a5)
 7f8:	855a                	mv	a0,s6
 7fa:	d1fff0ef          	jal	518 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7fe:	0992                	slli	s3,s3,0x4
 800:	397d                	addiw	s2,s2,-1
 802:	fe0916e3          	bnez	s2,7ee <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 806:	8bea                	mv	s7,s10
      state = 0;
 808:	4981                	li	s3,0
 80a:	6d02                	ld	s10,0(sp)
 80c:	bd01                	j	61c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 80e:	008b8913          	addi	s2,s7,8
 812:	000bc583          	lbu	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	d01ff0ef          	jal	518 <putc>
 81c:	8bca                	mv	s7,s2
      state = 0;
 81e:	4981                	li	s3,0
 820:	bbf5                	j	61c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 822:	008b8993          	addi	s3,s7,8
 826:	000bb903          	ld	s2,0(s7)
 82a:	00090f63          	beqz	s2,848 <vprintf+0x276>
        for(; *s; s++)
 82e:	00094583          	lbu	a1,0(s2)
 832:	c195                	beqz	a1,856 <vprintf+0x284>
          putc(fd, *s);
 834:	855a                	mv	a0,s6
 836:	ce3ff0ef          	jal	518 <putc>
        for(; *s; s++)
 83a:	0905                	addi	s2,s2,1
 83c:	00094583          	lbu	a1,0(s2)
 840:	f9f5                	bnez	a1,834 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 842:	8bce                	mv	s7,s3
      state = 0;
 844:	4981                	li	s3,0
 846:	bbd9                	j	61c <vprintf+0x4a>
          s = "(null)";
 848:	00000917          	auipc	s2,0x0
 84c:	53890913          	addi	s2,s2,1336 # d80 <malloc+0x42c>
        for(; *s; s++)
 850:	02800593          	li	a1,40
 854:	b7c5                	j	834 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 856:	8bce                	mv	s7,s3
      state = 0;
 858:	4981                	li	s3,0
 85a:	b3c9                	j	61c <vprintf+0x4a>
 85c:	64a6                	ld	s1,72(sp)
 85e:	79e2                	ld	s3,56(sp)
 860:	7a42                	ld	s4,48(sp)
 862:	7aa2                	ld	s5,40(sp)
 864:	7b02                	ld	s6,32(sp)
 866:	6be2                	ld	s7,24(sp)
 868:	6c42                	ld	s8,16(sp)
 86a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 86c:	60e6                	ld	ra,88(sp)
 86e:	6446                	ld	s0,80(sp)
 870:	6906                	ld	s2,64(sp)
 872:	6125                	addi	sp,sp,96
 874:	8082                	ret

0000000000000876 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 876:	715d                	addi	sp,sp,-80
 878:	ec06                	sd	ra,24(sp)
 87a:	e822                	sd	s0,16(sp)
 87c:	1000                	addi	s0,sp,32
 87e:	e010                	sd	a2,0(s0)
 880:	e414                	sd	a3,8(s0)
 882:	e818                	sd	a4,16(s0)
 884:	ec1c                	sd	a5,24(s0)
 886:	03043023          	sd	a6,32(s0)
 88a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 88e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 892:	8622                	mv	a2,s0
 894:	d3fff0ef          	jal	5d2 <vprintf>
}
 898:	60e2                	ld	ra,24(sp)
 89a:	6442                	ld	s0,16(sp)
 89c:	6161                	addi	sp,sp,80
 89e:	8082                	ret

00000000000008a0 <printf>:

void
printf(const char *fmt, ...)
{
 8a0:	711d                	addi	sp,sp,-96
 8a2:	ec06                	sd	ra,24(sp)
 8a4:	e822                	sd	s0,16(sp)
 8a6:	1000                	addi	s0,sp,32
 8a8:	e40c                	sd	a1,8(s0)
 8aa:	e810                	sd	a2,16(s0)
 8ac:	ec14                	sd	a3,24(s0)
 8ae:	f018                	sd	a4,32(s0)
 8b0:	f41c                	sd	a5,40(s0)
 8b2:	03043823          	sd	a6,48(s0)
 8b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ba:	00840613          	addi	a2,s0,8
 8be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8c2:	85aa                	mv	a1,a0
 8c4:	4505                	li	a0,1
 8c6:	d0dff0ef          	jal	5d2 <vprintf>
}
 8ca:	60e2                	ld	ra,24(sp)
 8cc:	6442                	ld	s0,16(sp)
 8ce:	6125                	addi	sp,sp,96
 8d0:	8082                	ret

00000000000008d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d2:	1141                	addi	sp,sp,-16
 8d4:	e422                	sd	s0,8(sp)
 8d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8dc:	00001797          	auipc	a5,0x1
 8e0:	7247b783          	ld	a5,1828(a5) # 2000 <freep>
 8e4:	a02d                	j	90e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8e6:	4618                	lw	a4,8(a2)
 8e8:	9f2d                	addw	a4,a4,a1
 8ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ee:	6398                	ld	a4,0(a5)
 8f0:	6310                	ld	a2,0(a4)
 8f2:	a83d                	j	930 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8f4:	ff852703          	lw	a4,-8(a0)
 8f8:	9f31                	addw	a4,a4,a2
 8fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8fc:	ff053683          	ld	a3,-16(a0)
 900:	a091                	j	944 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 902:	6398                	ld	a4,0(a5)
 904:	00e7e463          	bltu	a5,a4,90c <free+0x3a>
 908:	00e6ea63          	bltu	a3,a4,91c <free+0x4a>
{
 90c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90e:	fed7fae3          	bgeu	a5,a3,902 <free+0x30>
 912:	6398                	ld	a4,0(a5)
 914:	00e6e463          	bltu	a3,a4,91c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 918:	fee7eae3          	bltu	a5,a4,90c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 91c:	ff852583          	lw	a1,-8(a0)
 920:	6390                	ld	a2,0(a5)
 922:	02059813          	slli	a6,a1,0x20
 926:	01c85713          	srli	a4,a6,0x1c
 92a:	9736                	add	a4,a4,a3
 92c:	fae60de3          	beq	a2,a4,8e6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 930:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 934:	4790                	lw	a2,8(a5)
 936:	02061593          	slli	a1,a2,0x20
 93a:	01c5d713          	srli	a4,a1,0x1c
 93e:	973e                	add	a4,a4,a5
 940:	fae68ae3          	beq	a3,a4,8f4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 944:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 946:	00001717          	auipc	a4,0x1
 94a:	6af73d23          	sd	a5,1722(a4) # 2000 <freep>
}
 94e:	6422                	ld	s0,8(sp)
 950:	0141                	addi	sp,sp,16
 952:	8082                	ret

0000000000000954 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 954:	7139                	addi	sp,sp,-64
 956:	fc06                	sd	ra,56(sp)
 958:	f822                	sd	s0,48(sp)
 95a:	f426                	sd	s1,40(sp)
 95c:	ec4e                	sd	s3,24(sp)
 95e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 960:	02051493          	slli	s1,a0,0x20
 964:	9081                	srli	s1,s1,0x20
 966:	04bd                	addi	s1,s1,15
 968:	8091                	srli	s1,s1,0x4
 96a:	0014899b          	addiw	s3,s1,1
 96e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 970:	00001517          	auipc	a0,0x1
 974:	69053503          	ld	a0,1680(a0) # 2000 <freep>
 978:	c915                	beqz	a0,9ac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97c:	4798                	lw	a4,8(a5)
 97e:	08977a63          	bgeu	a4,s1,a12 <malloc+0xbe>
 982:	f04a                	sd	s2,32(sp)
 984:	e852                	sd	s4,16(sp)
 986:	e456                	sd	s5,8(sp)
 988:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 98a:	8a4e                	mv	s4,s3
 98c:	0009871b          	sext.w	a4,s3
 990:	6685                	lui	a3,0x1
 992:	00d77363          	bgeu	a4,a3,998 <malloc+0x44>
 996:	6a05                	lui	s4,0x1
 998:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 99c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9a0:	00001917          	auipc	s2,0x1
 9a4:	66090913          	addi	s2,s2,1632 # 2000 <freep>
  if(p == SBRK_ERROR)
 9a8:	5afd                	li	s5,-1
 9aa:	a081                	j	9ea <malloc+0x96>
 9ac:	f04a                	sd	s2,32(sp)
 9ae:	e852                	sd	s4,16(sp)
 9b0:	e456                	sd	s5,8(sp)
 9b2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9b4:	00001797          	auipc	a5,0x1
 9b8:	65c78793          	addi	a5,a5,1628 # 2010 <base>
 9bc:	00001717          	auipc	a4,0x1
 9c0:	64f73223          	sd	a5,1604(a4) # 2000 <freep>
 9c4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ca:	b7c1                	j	98a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9cc:	6398                	ld	a4,0(a5)
 9ce:	e118                	sd	a4,0(a0)
 9d0:	a8a9                	j	a2a <malloc+0xd6>
  hp->s.size = nu;
 9d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9d6:	0541                	addi	a0,a0,16
 9d8:	efbff0ef          	jal	8d2 <free>
  return freep;
 9dc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9e0:	c12d                	beqz	a0,a42 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e4:	4798                	lw	a4,8(a5)
 9e6:	02977263          	bgeu	a4,s1,a0a <malloc+0xb6>
    if(p == freep)
 9ea:	00093703          	ld	a4,0(s2)
 9ee:	853e                	mv	a0,a5
 9f0:	fef719e3          	bne	a4,a5,9e2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9f4:	8552                	mv	a0,s4
 9f6:	a3fff0ef          	jal	434 <sbrk>
  if(p == SBRK_ERROR)
 9fa:	fd551ce3          	bne	a0,s5,9d2 <malloc+0x7e>
        return 0;
 9fe:	4501                	li	a0,0
 a00:	7902                	ld	s2,32(sp)
 a02:	6a42                	ld	s4,16(sp)
 a04:	6aa2                	ld	s5,8(sp)
 a06:	6b02                	ld	s6,0(sp)
 a08:	a03d                	j	a36 <malloc+0xe2>
 a0a:	7902                	ld	s2,32(sp)
 a0c:	6a42                	ld	s4,16(sp)
 a0e:	6aa2                	ld	s5,8(sp)
 a10:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a12:	fae48de3          	beq	s1,a4,9cc <malloc+0x78>
        p->s.size -= nunits;
 a16:	4137073b          	subw	a4,a4,s3
 a1a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a1c:	02071693          	slli	a3,a4,0x20
 a20:	01c6d713          	srli	a4,a3,0x1c
 a24:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a26:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a2a:	00001717          	auipc	a4,0x1
 a2e:	5ca73b23          	sd	a0,1494(a4) # 2000 <freep>
      return (void*)(p + 1);
 a32:	01078513          	addi	a0,a5,16
  }
}
 a36:	70e2                	ld	ra,56(sp)
 a38:	7442                	ld	s0,48(sp)
 a3a:	74a2                	ld	s1,40(sp)
 a3c:	69e2                	ld	s3,24(sp)
 a3e:	6121                	addi	sp,sp,64
 a40:	8082                	ret
 a42:	7902                	ld	s2,32(sp)
 a44:	6a42                	ld	s4,16(sp)
 a46:	6aa2                	ld	s5,8(sp)
 a48:	6b02                	ld	s6,0(sp)
 a4a:	b7f5                	j	a36 <malloc+0xe2>
