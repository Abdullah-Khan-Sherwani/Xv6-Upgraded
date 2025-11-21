
user/_diagtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

// Diagnostic test to check if time slices are being tracked
int
main(int argc, char *argv[])
{
   0:	7159                	addi	sp,sp,-112
   2:	f486                	sd	ra,104(sp)
   4:	f0a2                	sd	s0,96(sp)
   6:	eca6                	sd	s1,88(sp)
   8:	e8ca                	sd	s2,80(sp)
   a:	e4ce                	sd	s3,72(sp)
   c:	e0d2                	sd	s4,64(sp)
   e:	fc56                	sd	s5,56(sp)
  10:	f85a                	sd	s6,48(sp)
  12:	f45e                	sd	s7,40(sp)
  14:	1880                	addi	s0,sp,112
  struct procinfo info;
  
  printf("=== MLFQ Diagnostics ===\n\n");
  16:	00001517          	auipc	a0,0x1
  1a:	a2a50513          	addi	a0,a0,-1494 # a40 <malloc+0xe2>
  1e:	087000ef          	jal	ra,8a4 <printf>
  
  // Check initial state
  if(getprocinfo(&info) == 0) {
  22:	fa040513          	addi	a0,s0,-96
  26:	4f2000ef          	jal	ra,518 <getprocinfo>
  2a:	c505                	beqz	a0,52 <main+0x52>
    printf("  Priority: Q%d\n", info.priority);
    printf("  Time Slices: %d\n\n", info.time_slices);
  }
  
  // Do a small amount of work and check repeatedly
  printf("Running work bursts and checking time_slices:\n");
  2c:	00001517          	auipc	a0,0x1
  30:	a9450513          	addi	a0,a0,-1388 # ac0 <malloc+0x162>
  34:	071000ef          	jal	ra,8a4 <printf>
  38:	4905                	li	s2,1
  3a:	4481                	li	s1,0
  for(int i = 0; i < 20; i++) {
    // Work burst - enough to trigger timer interrupts
    volatile int dummy = 0;
  3c:	004c59b7          	lui	s3,0x4c5
  40:	b4098993          	addi	s3,s3,-1216 # 4c4b40 <base+0x4c3b30>
  for(int i = 0; i < 20; i++) {
  44:	4a4d                	li	s4,19
    for(int j = 0; j < 5000000; j++) {
      dummy++;
    }
    
    if(getprocinfo(&info) == 0) {
      printf("  Iteration %2d: slices=%d priority=Q%d\n", 
  46:	00001b17          	auipc	s6,0x1
  4a:	aaab0b13          	addi	s6,s6,-1366 # af0 <malloc+0x192>
             i, info.time_slices, info.priority);
      
      // If time_slices is still 0 after 10 iterations, something is wrong
      if(i == 10 && info.time_slices == 0) {
  4e:	4aa9                	li	s5,10
  50:	a059                	j	d6 <main+0xd6>
    printf("Initial state:\n");
  52:	00001517          	auipc	a0,0x1
  56:	a0e50513          	addi	a0,a0,-1522 # a60 <malloc+0x102>
  5a:	04b000ef          	jal	ra,8a4 <printf>
    printf("  PID: %d\n", info.pid);
  5e:	fa042583          	lw	a1,-96(s0)
  62:	00001517          	auipc	a0,0x1
  66:	a0e50513          	addi	a0,a0,-1522 # a70 <malloc+0x112>
  6a:	03b000ef          	jal	ra,8a4 <printf>
    printf("  State: %d\n", info.state);
  6e:	fa442583          	lw	a1,-92(s0)
  72:	00001517          	auipc	a0,0x1
  76:	a0e50513          	addi	a0,a0,-1522 # a80 <malloc+0x122>
  7a:	02b000ef          	jal	ra,8a4 <printf>
    printf("  Priority: Q%d\n", info.priority);
  7e:	fa842583          	lw	a1,-88(s0)
  82:	00001517          	auipc	a0,0x1
  86:	a0e50513          	addi	a0,a0,-1522 # a90 <malloc+0x132>
  8a:	01b000ef          	jal	ra,8a4 <printf>
    printf("  Time Slices: %d\n\n", info.time_slices);
  8e:	fac42583          	lw	a1,-84(s0)
  92:	00001517          	auipc	a0,0x1
  96:	a1650513          	addi	a0,a0,-1514 # aa8 <malloc+0x14a>
  9a:	00b000ef          	jal	ra,8a4 <printf>
  9e:	b779                	j	2c <main+0x2c>
      if(i == 10 && info.time_slices == 0) {
  a0:	fac42783          	lw	a5,-84(s0)
  a4:	c791                	beqz	a5,b0 <main+0xb0>
        printf("*** Timer interrupts may not be working ***\n\n");
        break;
      }
      
      // If we see demotion, report it
      if(info.priority > 0) {
  a6:	fa842583          	lw	a1,-88(s0)
  aa:	02b05463          	blez	a1,d2 <main+0xd2>
  ae:	a09d                	j	114 <main+0x114>
        printf("\n*** ERROR: time_slices not incrementing! ***\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	a7050513          	addi	a0,a0,-1424 # b20 <malloc+0x1c2>
  b8:	7ec000ef          	jal	ra,8a4 <printf>
        printf("*** Timer interrupts may not be working ***\n\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	a9450513          	addi	a0,a0,-1388 # b50 <malloc+0x1f2>
  c4:	7e0000ef          	jal	ra,8a4 <printf>
        break;
  c8:	a8b1                	j	124 <main+0x124>
  for(int i = 0; i < 20; i++) {
  ca:	0009079b          	sext.w	a5,s2
  ce:	04fa4b63          	blt	s4,a5,124 <main+0x124>
  d2:	2485                	addiw	s1,s1,1
  d4:	2905                	addiw	s2,s2,1
  d6:	00048b9b          	sext.w	s7,s1
    volatile int dummy = 0;
  da:	f8042e23          	sw	zero,-100(s0)
  de:	874e                	mv	a4,s3
      dummy++;
  e0:	f9c42783          	lw	a5,-100(s0)
  e4:	2785                	addiw	a5,a5,1
  e6:	f8f42e23          	sw	a5,-100(s0)
    for(int j = 0; j < 5000000; j++) {
  ea:	377d                	addiw	a4,a4,-1
  ec:	fb75                	bnez	a4,e0 <main+0xe0>
    if(getprocinfo(&info) == 0) {
  ee:	fa040513          	addi	a0,s0,-96
  f2:	426000ef          	jal	ra,518 <getprocinfo>
  f6:	f971                	bnez	a0,ca <main+0xca>
      printf("  Iteration %2d: slices=%d priority=Q%d\n", 
  f8:	fa842683          	lw	a3,-88(s0)
  fc:	fac42603          	lw	a2,-84(s0)
 100:	85de                	mv	a1,s7
 102:	855a                	mv	a0,s6
 104:	7a0000ef          	jal	ra,8a4 <printf>
      if(i == 10 && info.time_slices == 0) {
 108:	f95b8ce3          	beq	s7,s5,a0 <main+0xa0>
      if(info.priority > 0) {
 10c:	fa842583          	lw	a1,-88(s0)
 110:	fab05de3          	blez	a1,ca <main+0xca>
        printf("\n*** GOOD: Process demoted to Q%d after %d slices! ***\n\n", 
 114:	fac42603          	lw	a2,-84(s0)
 118:	00001517          	auipc	a0,0x1
 11c:	a6850513          	addi	a0,a0,-1432 # b80 <malloc+0x222>
 120:	784000ef          	jal	ra,8a4 <printf>
      }
    }
  }
  
  // Final state
  if(getprocinfo(&info) == 0) {
 124:	fa040513          	addi	a0,s0,-96
 128:	3f0000ef          	jal	ra,518 <getprocinfo>
 12c:	c501                	beqz	a0,134 <main+0x134>
      printf("\n=== SUCCESS ===\n");
      printf("Time slice tracking is working!\n");
    }
  }
  
  exit(0);
 12e:	4501                	li	a0,0
 130:	348000ef          	jal	ra,478 <exit>
    printf("\nFinal state:\n");
 134:	00001517          	auipc	a0,0x1
 138:	a8c50513          	addi	a0,a0,-1396 # bc0 <malloc+0x262>
 13c:	768000ef          	jal	ra,8a4 <printf>
    printf("  Priority: Q%d\n", info.priority);
 140:	fa842583          	lw	a1,-88(s0)
 144:	00001517          	auipc	a0,0x1
 148:	94c50513          	addi	a0,a0,-1716 # a90 <malloc+0x132>
 14c:	758000ef          	jal	ra,8a4 <printf>
    printf("  Time Slices: %d\n", info.time_slices);
 150:	fac42583          	lw	a1,-84(s0)
 154:	00001517          	auipc	a0,0x1
 158:	a7c50513          	addi	a0,a0,-1412 # bd0 <malloc+0x272>
 15c:	748000ef          	jal	ra,8a4 <printf>
    if(info.time_slices == 0) {
 160:	fac42783          	lw	a5,-84(s0)
 164:	e3b5                	bnez	a5,1c8 <main+0x1c8>
      printf("\n=== DIAGNOSIS ===\n");
 166:	00001517          	auipc	a0,0x1
 16a:	a8250513          	addi	a0,a0,-1406 # be8 <malloc+0x28a>
 16e:	736000ef          	jal	ra,8a4 <printf>
      printf("Problem: time_slices never incremented\n");
 172:	00001517          	auipc	a0,0x1
 176:	a8e50513          	addi	a0,a0,-1394 # c00 <malloc+0x2a2>
 17a:	72a000ef          	jal	ra,8a4 <printf>
      printf("Possible causes:\n");
 17e:	00001517          	auipc	a0,0x1
 182:	aaa50513          	addi	a0,a0,-1366 # c28 <malloc+0x2ca>
 186:	71e000ef          	jal	ra,8a4 <printf>
      printf("  1. Timer interrupts not firing (check clockintr)\n");
 18a:	00001517          	auipc	a0,0x1
 18e:	ab650513          	addi	a0,a0,-1354 # c40 <malloc+0x2e2>
 192:	712000ef          	jal	ra,8a4 <printf>
      printf("  2. which_dev != 2 in usertrap()\n");
 196:	00001517          	auipc	a0,0x1
 19a:	ae250513          	addi	a0,a0,-1310 # c78 <malloc+0x31a>
 19e:	706000ef          	jal	ra,8a4 <printf>
      printf("  3. p->time_slices++ not executing\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	afe50513          	addi	a0,a0,-1282 # ca0 <malloc+0x342>
 1aa:	6fa000ef          	jal	ra,8a4 <printf>
      printf("\nAdd debug prints in kernel/trap.c:\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	b1a50513          	addi	a0,a0,-1254 # cc8 <malloc+0x36a>
 1b6:	6ee000ef          	jal	ra,8a4 <printf>
      printf("  printf(\"Timer: which_dev=%%d pid=%%d\\n\", which_dev, p->pid);\n");
 1ba:	00001517          	auipc	a0,0x1
 1be:	b3650513          	addi	a0,a0,-1226 # cf0 <malloc+0x392>
 1c2:	6e2000ef          	jal	ra,8a4 <printf>
 1c6:	b7a5                	j	12e <main+0x12e>
      printf("\n=== SUCCESS ===\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	b6850513          	addi	a0,a0,-1176 # d30 <malloc+0x3d2>
 1d0:	6d4000ef          	jal	ra,8a4 <printf>
      printf("Time slice tracking is working!\n");
 1d4:	00001517          	auipc	a0,0x1
 1d8:	b7450513          	addi	a0,a0,-1164 # d48 <malloc+0x3ea>
 1dc:	6c8000ef          	jal	ra,8a4 <printf>
 1e0:	b7b9                	j	12e <main+0x12e>

00000000000001e2 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e406                	sd	ra,8(sp)
 1e6:	e022                	sd	s0,0(sp)
 1e8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1ea:	e17ff0ef          	jal	ra,0 <main>
  exit(r);
 1ee:	28a000ef          	jal	ra,478 <exit>

00000000000001f2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f8:	87aa                	mv	a5,a0
 1fa:	0585                	addi	a1,a1,1
 1fc:	0785                	addi	a5,a5,1
 1fe:	fff5c703          	lbu	a4,-1(a1)
 202:	fee78fa3          	sb	a4,-1(a5)
 206:	fb75                	bnez	a4,1fa <strcpy+0x8>
    ;
  return os;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret

000000000000020e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e422                	sd	s0,8(sp)
 212:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 214:	00054783          	lbu	a5,0(a0)
 218:	cb91                	beqz	a5,22c <strcmp+0x1e>
 21a:	0005c703          	lbu	a4,0(a1)
 21e:	00f71763          	bne	a4,a5,22c <strcmp+0x1e>
    p++, q++;
 222:	0505                	addi	a0,a0,1
 224:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 226:	00054783          	lbu	a5,0(a0)
 22a:	fbe5                	bnez	a5,21a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 22c:	0005c503          	lbu	a0,0(a1)
}
 230:	40a7853b          	subw	a0,a5,a0
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret

000000000000023a <strlen>:

uint
strlen(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 240:	00054783          	lbu	a5,0(a0)
 244:	cf91                	beqz	a5,260 <strlen+0x26>
 246:	0505                	addi	a0,a0,1
 248:	87aa                	mv	a5,a0
 24a:	4685                	li	a3,1
 24c:	9e89                	subw	a3,a3,a0
 24e:	00f6853b          	addw	a0,a3,a5
 252:	0785                	addi	a5,a5,1
 254:	fff7c703          	lbu	a4,-1(a5)
 258:	fb7d                	bnez	a4,24e <strlen+0x14>
    ;
  return n;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
  for(n = 0; s[n]; n++)
 260:	4501                	li	a0,0
 262:	bfe5                	j	25a <strlen+0x20>

0000000000000264 <memset>:

void*
memset(void *dst, int c, uint n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 26a:	ca19                	beqz	a2,280 <memset+0x1c>
 26c:	87aa                	mv	a5,a0
 26e:	1602                	slli	a2,a2,0x20
 270:	9201                	srli	a2,a2,0x20
 272:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 276:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 27a:	0785                	addi	a5,a5,1
 27c:	fee79de3          	bne	a5,a4,276 <memset+0x12>
  }
  return dst;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strchr>:

char*
strchr(const char *s, char c)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cb99                	beqz	a5,2a6 <strchr+0x20>
    if(*s == c)
 292:	00f58763          	beq	a1,a5,2a0 <strchr+0x1a>
  for(; *s; s++)
 296:	0505                	addi	a0,a0,1
 298:	00054783          	lbu	a5,0(a0)
 29c:	fbfd                	bnez	a5,292 <strchr+0xc>
      return (char*)s;
  return 0;
 29e:	4501                	li	a0,0
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
  return 0;
 2a6:	4501                	li	a0,0
 2a8:	bfe5                	j	2a0 <strchr+0x1a>

00000000000002aa <gets>:

char*
gets(char *buf, int max)
{
 2aa:	711d                	addi	sp,sp,-96
 2ac:	ec86                	sd	ra,88(sp)
 2ae:	e8a2                	sd	s0,80(sp)
 2b0:	e4a6                	sd	s1,72(sp)
 2b2:	e0ca                	sd	s2,64(sp)
 2b4:	fc4e                	sd	s3,56(sp)
 2b6:	f852                	sd	s4,48(sp)
 2b8:	f456                	sd	s5,40(sp)
 2ba:	f05a                	sd	s6,32(sp)
 2bc:	ec5e                	sd	s7,24(sp)
 2be:	1080                	addi	s0,sp,96
 2c0:	8baa                	mv	s7,a0
 2c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c4:	892a                	mv	s2,a0
 2c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c8:	4aa9                	li	s5,10
 2ca:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2cc:	89a6                	mv	s3,s1
 2ce:	2485                	addiw	s1,s1,1
 2d0:	0344d663          	bge	s1,s4,2fc <gets+0x52>
    cc = read(0, &c, 1);
 2d4:	4605                	li	a2,1
 2d6:	faf40593          	addi	a1,s0,-81
 2da:	4501                	li	a0,0
 2dc:	1b4000ef          	jal	ra,490 <read>
    if(cc < 1)
 2e0:	00a05e63          	blez	a0,2fc <gets+0x52>
    buf[i++] = c;
 2e4:	faf44783          	lbu	a5,-81(s0)
 2e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ec:	01578763          	beq	a5,s5,2fa <gets+0x50>
 2f0:	0905                	addi	s2,s2,1
 2f2:	fd679de3          	bne	a5,s6,2cc <gets+0x22>
  for(i=0; i+1 < max; ){
 2f6:	89a6                	mv	s3,s1
 2f8:	a011                	j	2fc <gets+0x52>
 2fa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2fc:	99de                	add	s3,s3,s7
 2fe:	00098023          	sb	zero,0(s3)
  return buf;
}
 302:	855e                	mv	a0,s7
 304:	60e6                	ld	ra,88(sp)
 306:	6446                	ld	s0,80(sp)
 308:	64a6                	ld	s1,72(sp)
 30a:	6906                	ld	s2,64(sp)
 30c:	79e2                	ld	s3,56(sp)
 30e:	7a42                	ld	s4,48(sp)
 310:	7aa2                	ld	s5,40(sp)
 312:	7b02                	ld	s6,32(sp)
 314:	6be2                	ld	s7,24(sp)
 316:	6125                	addi	sp,sp,96
 318:	8082                	ret

000000000000031a <stat>:

int
stat(const char *n, struct stat *st)
{
 31a:	1101                	addi	sp,sp,-32
 31c:	ec06                	sd	ra,24(sp)
 31e:	e822                	sd	s0,16(sp)
 320:	e426                	sd	s1,8(sp)
 322:	e04a                	sd	s2,0(sp)
 324:	1000                	addi	s0,sp,32
 326:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 328:	4581                	li	a1,0
 32a:	18e000ef          	jal	ra,4b8 <open>
  if(fd < 0)
 32e:	02054163          	bltz	a0,350 <stat+0x36>
 332:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 334:	85ca                	mv	a1,s2
 336:	19a000ef          	jal	ra,4d0 <fstat>
 33a:	892a                	mv	s2,a0
  close(fd);
 33c:	8526                	mv	a0,s1
 33e:	162000ef          	jal	ra,4a0 <close>
  return r;
}
 342:	854a                	mv	a0,s2
 344:	60e2                	ld	ra,24(sp)
 346:	6442                	ld	s0,16(sp)
 348:	64a2                	ld	s1,8(sp)
 34a:	6902                	ld	s2,0(sp)
 34c:	6105                	addi	sp,sp,32
 34e:	8082                	ret
    return -1;
 350:	597d                	li	s2,-1
 352:	bfc5                	j	342 <stat+0x28>

0000000000000354 <atoi>:

int
atoi(const char *s)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 35a:	00054603          	lbu	a2,0(a0)
 35e:	fd06079b          	addiw	a5,a2,-48
 362:	0ff7f793          	andi	a5,a5,255
 366:	4725                	li	a4,9
 368:	02f76963          	bltu	a4,a5,39a <atoi+0x46>
 36c:	86aa                	mv	a3,a0
  n = 0;
 36e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 370:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 372:	0685                	addi	a3,a3,1
 374:	0025179b          	slliw	a5,a0,0x2
 378:	9fa9                	addw	a5,a5,a0
 37a:	0017979b          	slliw	a5,a5,0x1
 37e:	9fb1                	addw	a5,a5,a2
 380:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 384:	0006c603          	lbu	a2,0(a3)
 388:	fd06071b          	addiw	a4,a2,-48
 38c:	0ff77713          	andi	a4,a4,255
 390:	fee5f1e3          	bgeu	a1,a4,372 <atoi+0x1e>
  return n;
}
 394:	6422                	ld	s0,8(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret
  n = 0;
 39a:	4501                	li	a0,0
 39c:	bfe5                	j	394 <atoi+0x40>

000000000000039e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a4:	02b57463          	bgeu	a0,a1,3cc <memmove+0x2e>
    while(n-- > 0)
 3a8:	00c05f63          	blez	a2,3c6 <memmove+0x28>
 3ac:	1602                	slli	a2,a2,0x20
 3ae:	9201                	srli	a2,a2,0x20
 3b0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b6:	0585                	addi	a1,a1,1
 3b8:	0705                	addi	a4,a4,1
 3ba:	fff5c683          	lbu	a3,-1(a1)
 3be:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c2:	fee79ae3          	bne	a5,a4,3b6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c6:	6422                	ld	s0,8(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret
    dst += n;
 3cc:	00c50733          	add	a4,a0,a2
    src += n;
 3d0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3d2:	fec05ae3          	blez	a2,3c6 <memmove+0x28>
 3d6:	fff6079b          	addiw	a5,a2,-1
 3da:	1782                	slli	a5,a5,0x20
 3dc:	9381                	srli	a5,a5,0x20
 3de:	fff7c793          	not	a5,a5
 3e2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e4:	15fd                	addi	a1,a1,-1
 3e6:	177d                	addi	a4,a4,-1
 3e8:	0005c683          	lbu	a3,0(a1)
 3ec:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3f0:	fee79ae3          	bne	a5,a4,3e4 <memmove+0x46>
 3f4:	bfc9                	j	3c6 <memmove+0x28>

00000000000003f6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f6:	1141                	addi	sp,sp,-16
 3f8:	e422                	sd	s0,8(sp)
 3fa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3fc:	ca05                	beqz	a2,42c <memcmp+0x36>
 3fe:	fff6069b          	addiw	a3,a2,-1
 402:	1682                	slli	a3,a3,0x20
 404:	9281                	srli	a3,a3,0x20
 406:	0685                	addi	a3,a3,1
 408:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 40a:	00054783          	lbu	a5,0(a0)
 40e:	0005c703          	lbu	a4,0(a1)
 412:	00e79863          	bne	a5,a4,422 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 416:	0505                	addi	a0,a0,1
    p2++;
 418:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 41a:	fed518e3          	bne	a0,a3,40a <memcmp+0x14>
  }
  return 0;
 41e:	4501                	li	a0,0
 420:	a019                	j	426 <memcmp+0x30>
      return *p1 - *p2;
 422:	40e7853b          	subw	a0,a5,a4
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
  return 0;
 42c:	4501                	li	a0,0
 42e:	bfe5                	j	426 <memcmp+0x30>

0000000000000430 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 430:	1141                	addi	sp,sp,-16
 432:	e406                	sd	ra,8(sp)
 434:	e022                	sd	s0,0(sp)
 436:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 438:	f67ff0ef          	jal	ra,39e <memmove>
}
 43c:	60a2                	ld	ra,8(sp)
 43e:	6402                	ld	s0,0(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret

0000000000000444 <sbrk>:

char *
sbrk(int n) {
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 44c:	4585                	li	a1,1
 44e:	0b2000ef          	jal	ra,500 <sys_sbrk>
}
 452:	60a2                	ld	ra,8(sp)
 454:	6402                	ld	s0,0(sp)
 456:	0141                	addi	sp,sp,16
 458:	8082                	ret

000000000000045a <sbrklazy>:

char *
sbrklazy(int n) {
 45a:	1141                	addi	sp,sp,-16
 45c:	e406                	sd	ra,8(sp)
 45e:	e022                	sd	s0,0(sp)
 460:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 462:	4589                	li	a1,2
 464:	09c000ef          	jal	ra,500 <sys_sbrk>
}
 468:	60a2                	ld	ra,8(sp)
 46a:	6402                	ld	s0,0(sp)
 46c:	0141                	addi	sp,sp,16
 46e:	8082                	ret

0000000000000470 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 470:	4885                	li	a7,1
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <exit>:
.global exit
exit:
 li a7, SYS_exit
 478:	4889                	li	a7,2
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <wait>:
.global wait
wait:
 li a7, SYS_wait
 480:	488d                	li	a7,3
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 488:	4891                	li	a7,4
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <read>:
.global read
read:
 li a7, SYS_read
 490:	4895                	li	a7,5
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <write>:
.global write
write:
 li a7, SYS_write
 498:	48c1                	li	a7,16
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <close>:
.global close
close:
 li a7, SYS_close
 4a0:	48d5                	li	a7,21
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a8:	4899                	li	a7,6
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b0:	489d                	li	a7,7
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <open>:
.global open
open:
 li a7, SYS_open
 4b8:	48bd                	li	a7,15
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c0:	48c5                	li	a7,17
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c8:	48c9                	li	a7,18
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d0:	48a1                	li	a7,8
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <link>:
.global link
link:
 li a7, SYS_link
 4d8:	48cd                	li	a7,19
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e0:	48d1                	li	a7,20
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e8:	48a5                	li	a7,9
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f0:	48a9                	li	a7,10
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f8:	48ad                	li	a7,11
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 500:	48b1                	li	a7,12
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <pause>:
.global pause
pause:
 li a7, SYS_pause
 508:	48b5                	li	a7,13
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 510:	48b9                	li	a7,14
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 518:	48d9                	li	a7,22
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 520:	48dd                	li	a7,23
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 528:	1101                	addi	sp,sp,-32
 52a:	ec06                	sd	ra,24(sp)
 52c:	e822                	sd	s0,16(sp)
 52e:	1000                	addi	s0,sp,32
 530:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 534:	4605                	li	a2,1
 536:	fef40593          	addi	a1,s0,-17
 53a:	f5fff0ef          	jal	ra,498 <write>
}
 53e:	60e2                	ld	ra,24(sp)
 540:	6442                	ld	s0,16(sp)
 542:	6105                	addi	sp,sp,32
 544:	8082                	ret

0000000000000546 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 546:	715d                	addi	sp,sp,-80
 548:	e486                	sd	ra,72(sp)
 54a:	e0a2                	sd	s0,64(sp)
 54c:	fc26                	sd	s1,56(sp)
 54e:	f84a                	sd	s2,48(sp)
 550:	f44e                	sd	s3,40(sp)
 552:	0880                	addi	s0,sp,80
 554:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 556:	c299                	beqz	a3,55c <printint+0x16>
 558:	0805c163          	bltz	a1,5da <printint+0x94>
  neg = 0;
 55c:	4881                	li	a7,0
 55e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 562:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 564:	00001517          	auipc	a0,0x1
 568:	81450513          	addi	a0,a0,-2028 # d78 <digits>
 56c:	883e                	mv	a6,a5
 56e:	2785                	addiw	a5,a5,1
 570:	02c5f733          	remu	a4,a1,a2
 574:	972a                	add	a4,a4,a0
 576:	00074703          	lbu	a4,0(a4)
 57a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 57e:	872e                	mv	a4,a1
 580:	02c5d5b3          	divu	a1,a1,a2
 584:	0685                	addi	a3,a3,1
 586:	fec773e3          	bgeu	a4,a2,56c <printint+0x26>
  if(neg)
 58a:	00088b63          	beqz	a7,5a0 <printint+0x5a>
    buf[i++] = '-';
 58e:	fd040713          	addi	a4,s0,-48
 592:	97ba                	add	a5,a5,a4
 594:	02d00713          	li	a4,45
 598:	fee78423          	sb	a4,-24(a5)
 59c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5a0:	02f05663          	blez	a5,5cc <printint+0x86>
 5a4:	fb840713          	addi	a4,s0,-72
 5a8:	00f704b3          	add	s1,a4,a5
 5ac:	fff70993          	addi	s3,a4,-1
 5b0:	99be                	add	s3,s3,a5
 5b2:	37fd                	addiw	a5,a5,-1
 5b4:	1782                	slli	a5,a5,0x20
 5b6:	9381                	srli	a5,a5,0x20
 5b8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5bc:	fff4c583          	lbu	a1,-1(s1)
 5c0:	854a                	mv	a0,s2
 5c2:	f67ff0ef          	jal	ra,528 <putc>
  while(--i >= 0)
 5c6:	14fd                	addi	s1,s1,-1
 5c8:	ff349ae3          	bne	s1,s3,5bc <printint+0x76>
}
 5cc:	60a6                	ld	ra,72(sp)
 5ce:	6406                	ld	s0,64(sp)
 5d0:	74e2                	ld	s1,56(sp)
 5d2:	7942                	ld	s2,48(sp)
 5d4:	79a2                	ld	s3,40(sp)
 5d6:	6161                	addi	sp,sp,80
 5d8:	8082                	ret
    x = -xx;
 5da:	40b005b3          	neg	a1,a1
    neg = 1;
 5de:	4885                	li	a7,1
    x = -xx;
 5e0:	bfbd                	j	55e <printint+0x18>

00000000000005e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5e2:	7119                	addi	sp,sp,-128
 5e4:	fc86                	sd	ra,120(sp)
 5e6:	f8a2                	sd	s0,112(sp)
 5e8:	f4a6                	sd	s1,104(sp)
 5ea:	f0ca                	sd	s2,96(sp)
 5ec:	ecce                	sd	s3,88(sp)
 5ee:	e8d2                	sd	s4,80(sp)
 5f0:	e4d6                	sd	s5,72(sp)
 5f2:	e0da                	sd	s6,64(sp)
 5f4:	fc5e                	sd	s7,56(sp)
 5f6:	f862                	sd	s8,48(sp)
 5f8:	f466                	sd	s9,40(sp)
 5fa:	f06a                	sd	s10,32(sp)
 5fc:	ec6e                	sd	s11,24(sp)
 5fe:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 600:	0005c903          	lbu	s2,0(a1)
 604:	24090c63          	beqz	s2,85c <vprintf+0x27a>
 608:	8b2a                	mv	s6,a0
 60a:	8a2e                	mv	s4,a1
 60c:	8bb2                	mv	s7,a2
  state = 0;
 60e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 610:	4481                	li	s1,0
 612:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 614:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 618:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 61c:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 620:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 624:	00000c97          	auipc	s9,0x0
 628:	754c8c93          	addi	s9,s9,1876 # d78 <digits>
 62c:	a005                	j	64c <vprintf+0x6a>
        putc(fd, c0);
 62e:	85ca                	mv	a1,s2
 630:	855a                	mv	a0,s6
 632:	ef7ff0ef          	jal	ra,528 <putc>
 636:	a019                	j	63c <vprintf+0x5a>
    } else if(state == '%'){
 638:	03598263          	beq	s3,s5,65c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 63c:	2485                	addiw	s1,s1,1
 63e:	8726                	mv	a4,s1
 640:	009a07b3          	add	a5,s4,s1
 644:	0007c903          	lbu	s2,0(a5)
 648:	20090a63          	beqz	s2,85c <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 64c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 650:	fe0994e3          	bnez	s3,638 <vprintf+0x56>
      if(c0 == '%'){
 654:	fd579de3          	bne	a5,s5,62e <vprintf+0x4c>
        state = '%';
 658:	89be                	mv	s3,a5
 65a:	b7cd                	j	63c <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 65c:	c3c1                	beqz	a5,6dc <vprintf+0xfa>
 65e:	00ea06b3          	add	a3,s4,a4
 662:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 666:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 668:	c681                	beqz	a3,670 <vprintf+0x8e>
 66a:	9752                	add	a4,a4,s4
 66c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 670:	03878e63          	beq	a5,s8,6ac <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 674:	05a78863          	beq	a5,s10,6c4 <vprintf+0xe2>
      } else if(c0 == 'u'){
 678:	0db78b63          	beq	a5,s11,74e <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 67c:	07800713          	li	a4,120
 680:	10e78d63          	beq	a5,a4,79a <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 684:	07000713          	li	a4,112
 688:	14e78263          	beq	a5,a4,7cc <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 68c:	06300713          	li	a4,99
 690:	16e78f63          	beq	a5,a4,80e <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 694:	07300713          	li	a4,115
 698:	18e78563          	beq	a5,a4,822 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 69c:	05579063          	bne	a5,s5,6dc <vprintf+0xfa>
        putc(fd, '%');
 6a0:	85d6                	mv	a1,s5
 6a2:	855a                	mv	a0,s6
 6a4:	e85ff0ef          	jal	ra,528 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bf49                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4685                	li	a3,1
 6b2:	4629                	li	a2,10
 6b4:	000ba583          	lw	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	e8dff0ef          	jal	ra,546 <printint>
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bfad                	j	63c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 6c4:	03868663          	beq	a3,s8,6f0 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c8:	05a68163          	beq	a3,s10,70a <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 6cc:	09b68d63          	beq	a3,s11,766 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6d0:	03a68f63          	beq	a3,s10,70e <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 6d4:	07800793          	li	a5,120
 6d8:	0cf68d63          	beq	a3,a5,7b2 <vprintf+0x1d0>
        putc(fd, '%');
 6dc:	85d6                	mv	a1,s5
 6de:	855a                	mv	a0,s6
 6e0:	e49ff0ef          	jal	ra,528 <putc>
        putc(fd, c0);
 6e4:	85ca                	mv	a1,s2
 6e6:	855a                	mv	a0,s6
 6e8:	e41ff0ef          	jal	ra,528 <putc>
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b7b9                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4685                	li	a3,1
 6f6:	4629                	li	a2,10
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	e49ff0ef          	jal	ra,546 <printint>
        i += 1;
 702:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
        i += 1;
 708:	bf15                	j	63c <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 70a:	03860563          	beq	a2,s8,734 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 70e:	07b60963          	beq	a2,s11,780 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 712:	07800793          	li	a5,120
 716:	fcf613e3          	bne	a2,a5,6dc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 71a:	008b8913          	addi	s2,s7,8
 71e:	4681                	li	a3,0
 720:	4641                	li	a2,16
 722:	000bb583          	ld	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	e1fff0ef          	jal	ra,546 <printint>
        i += 2;
 72c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 72e:	8bca                	mv	s7,s2
      state = 0;
 730:	4981                	li	s3,0
        i += 2;
 732:	b729                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 734:	008b8913          	addi	s2,s7,8
 738:	4685                	li	a3,1
 73a:	4629                	li	a2,10
 73c:	000bb583          	ld	a1,0(s7)
 740:	855a                	mv	a0,s6
 742:	e05ff0ef          	jal	ra,546 <printint>
        i += 2;
 746:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 748:	8bca                	mv	s7,s2
      state = 0;
 74a:	4981                	li	s3,0
        i += 2;
 74c:	bdc5                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 74e:	008b8913          	addi	s2,s7,8
 752:	4681                	li	a3,0
 754:	4629                	li	a2,10
 756:	000be583          	lwu	a1,0(s7)
 75a:	855a                	mv	a0,s6
 75c:	debff0ef          	jal	ra,546 <printint>
 760:	8bca                	mv	s7,s2
      state = 0;
 762:	4981                	li	s3,0
 764:	bde1                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 766:	008b8913          	addi	s2,s7,8
 76a:	4681                	li	a3,0
 76c:	4629                	li	a2,10
 76e:	000bb583          	ld	a1,0(s7)
 772:	855a                	mv	a0,s6
 774:	dd3ff0ef          	jal	ra,546 <printint>
        i += 1;
 778:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 77a:	8bca                	mv	s7,s2
      state = 0;
 77c:	4981                	li	s3,0
        i += 1;
 77e:	bd7d                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 780:	008b8913          	addi	s2,s7,8
 784:	4681                	li	a3,0
 786:	4629                	li	a2,10
 788:	000bb583          	ld	a1,0(s7)
 78c:	855a                	mv	a0,s6
 78e:	db9ff0ef          	jal	ra,546 <printint>
        i += 2;
 792:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 794:	8bca                	mv	s7,s2
      state = 0;
 796:	4981                	li	s3,0
        i += 2;
 798:	b555                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 79a:	008b8913          	addi	s2,s7,8
 79e:	4681                	li	a3,0
 7a0:	4641                	li	a2,16
 7a2:	000be583          	lwu	a1,0(s7)
 7a6:	855a                	mv	a0,s6
 7a8:	d9fff0ef          	jal	ra,546 <printint>
 7ac:	8bca                	mv	s7,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b571                	j	63c <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b2:	008b8913          	addi	s2,s7,8
 7b6:	4681                	li	a3,0
 7b8:	4641                	li	a2,16
 7ba:	000bb583          	ld	a1,0(s7)
 7be:	855a                	mv	a0,s6
 7c0:	d87ff0ef          	jal	ra,546 <printint>
        i += 1;
 7c4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c6:	8bca                	mv	s7,s2
      state = 0;
 7c8:	4981                	li	s3,0
        i += 1;
 7ca:	bd8d                	j	63c <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 7cc:	008b8793          	addi	a5,s7,8
 7d0:	f8f43423          	sd	a5,-120(s0)
 7d4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7d8:	03000593          	li	a1,48
 7dc:	855a                	mv	a0,s6
 7de:	d4bff0ef          	jal	ra,528 <putc>
  putc(fd, 'x');
 7e2:	07800593          	li	a1,120
 7e6:	855a                	mv	a0,s6
 7e8:	d41ff0ef          	jal	ra,528 <putc>
 7ec:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ee:	03c9d793          	srli	a5,s3,0x3c
 7f2:	97e6                	add	a5,a5,s9
 7f4:	0007c583          	lbu	a1,0(a5)
 7f8:	855a                	mv	a0,s6
 7fa:	d2fff0ef          	jal	ra,528 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7fe:	0992                	slli	s3,s3,0x4
 800:	397d                	addiw	s2,s2,-1
 802:	fe0916e3          	bnez	s2,7ee <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 806:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 80a:	4981                	li	s3,0
 80c:	bd05                	j	63c <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 80e:	008b8913          	addi	s2,s7,8
 812:	000bc583          	lbu	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	d11ff0ef          	jal	ra,528 <putc>
 81c:	8bca                	mv	s7,s2
      state = 0;
 81e:	4981                	li	s3,0
 820:	bd31                	j	63c <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 822:	008b8993          	addi	s3,s7,8
 826:	000bb903          	ld	s2,0(s7)
 82a:	00090f63          	beqz	s2,848 <vprintf+0x266>
        for(; *s; s++)
 82e:	00094583          	lbu	a1,0(s2)
 832:	c195                	beqz	a1,856 <vprintf+0x274>
          putc(fd, *s);
 834:	855a                	mv	a0,s6
 836:	cf3ff0ef          	jal	ra,528 <putc>
        for(; *s; s++)
 83a:	0905                	addi	s2,s2,1
 83c:	00094583          	lbu	a1,0(s2)
 840:	f9f5                	bnez	a1,834 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 842:	8bce                	mv	s7,s3
      state = 0;
 844:	4981                	li	s3,0
 846:	bbdd                	j	63c <vprintf+0x5a>
          s = "(null)";
 848:	00000917          	auipc	s2,0x0
 84c:	52890913          	addi	s2,s2,1320 # d70 <malloc+0x412>
        for(; *s; s++)
 850:	02800593          	li	a1,40
 854:	b7c5                	j	834 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 856:	8bce                	mv	s7,s3
      state = 0;
 858:	4981                	li	s3,0
 85a:	b3cd                	j	63c <vprintf+0x5a>
    }
  }
}
 85c:	70e6                	ld	ra,120(sp)
 85e:	7446                	ld	s0,112(sp)
 860:	74a6                	ld	s1,104(sp)
 862:	7906                	ld	s2,96(sp)
 864:	69e6                	ld	s3,88(sp)
 866:	6a46                	ld	s4,80(sp)
 868:	6aa6                	ld	s5,72(sp)
 86a:	6b06                	ld	s6,64(sp)
 86c:	7be2                	ld	s7,56(sp)
 86e:	7c42                	ld	s8,48(sp)
 870:	7ca2                	ld	s9,40(sp)
 872:	7d02                	ld	s10,32(sp)
 874:	6de2                	ld	s11,24(sp)
 876:	6109                	addi	sp,sp,128
 878:	8082                	ret

000000000000087a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 87a:	715d                	addi	sp,sp,-80
 87c:	ec06                	sd	ra,24(sp)
 87e:	e822                	sd	s0,16(sp)
 880:	1000                	addi	s0,sp,32
 882:	e010                	sd	a2,0(s0)
 884:	e414                	sd	a3,8(s0)
 886:	e818                	sd	a4,16(s0)
 888:	ec1c                	sd	a5,24(s0)
 88a:	03043023          	sd	a6,32(s0)
 88e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 892:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 896:	8622                	mv	a2,s0
 898:	d4bff0ef          	jal	ra,5e2 <vprintf>
}
 89c:	60e2                	ld	ra,24(sp)
 89e:	6442                	ld	s0,16(sp)
 8a0:	6161                	addi	sp,sp,80
 8a2:	8082                	ret

00000000000008a4 <printf>:

void
printf(const char *fmt, ...)
{
 8a4:	711d                	addi	sp,sp,-96
 8a6:	ec06                	sd	ra,24(sp)
 8a8:	e822                	sd	s0,16(sp)
 8aa:	1000                	addi	s0,sp,32
 8ac:	e40c                	sd	a1,8(s0)
 8ae:	e810                	sd	a2,16(s0)
 8b0:	ec14                	sd	a3,24(s0)
 8b2:	f018                	sd	a4,32(s0)
 8b4:	f41c                	sd	a5,40(s0)
 8b6:	03043823          	sd	a6,48(s0)
 8ba:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8be:	00840613          	addi	a2,s0,8
 8c2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8c6:	85aa                	mv	a1,a0
 8c8:	4505                	li	a0,1
 8ca:	d19ff0ef          	jal	ra,5e2 <vprintf>
}
 8ce:	60e2                	ld	ra,24(sp)
 8d0:	6442                	ld	s0,16(sp)
 8d2:	6125                	addi	sp,sp,96
 8d4:	8082                	ret

00000000000008d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d6:	1141                	addi	sp,sp,-16
 8d8:	e422                	sd	s0,8(sp)
 8da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e0:	00000797          	auipc	a5,0x0
 8e4:	7207b783          	ld	a5,1824(a5) # 1000 <freep>
 8e8:	a805                	j	918 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ea:	4618                	lw	a4,8(a2)
 8ec:	9db9                	addw	a1,a1,a4
 8ee:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	6318                	ld	a4,0(a4)
 8f6:	fee53823          	sd	a4,-16(a0)
 8fa:	a091                	j	93e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8fc:	ff852703          	lw	a4,-8(a0)
 900:	9e39                	addw	a2,a2,a4
 902:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 904:	ff053703          	ld	a4,-16(a0)
 908:	e398                	sd	a4,0(a5)
 90a:	a099                	j	950 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90c:	6398                	ld	a4,0(a5)
 90e:	00e7e463          	bltu	a5,a4,916 <free+0x40>
 912:	00e6ea63          	bltu	a3,a4,926 <free+0x50>
{
 916:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 918:	fed7fae3          	bgeu	a5,a3,90c <free+0x36>
 91c:	6398                	ld	a4,0(a5)
 91e:	00e6e463          	bltu	a3,a4,926 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 922:	fee7eae3          	bltu	a5,a4,916 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 926:	ff852583          	lw	a1,-8(a0)
 92a:	6390                	ld	a2,0(a5)
 92c:	02059713          	slli	a4,a1,0x20
 930:	9301                	srli	a4,a4,0x20
 932:	0712                	slli	a4,a4,0x4
 934:	9736                	add	a4,a4,a3
 936:	fae60ae3          	beq	a2,a4,8ea <free+0x14>
    bp->s.ptr = p->s.ptr;
 93a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 93e:	4790                	lw	a2,8(a5)
 940:	02061713          	slli	a4,a2,0x20
 944:	9301                	srli	a4,a4,0x20
 946:	0712                	slli	a4,a4,0x4
 948:	973e                	add	a4,a4,a5
 94a:	fae689e3          	beq	a3,a4,8fc <free+0x26>
  } else
    p->s.ptr = bp;
 94e:	e394                	sd	a3,0(a5)
  freep = p;
 950:	00000717          	auipc	a4,0x0
 954:	6af73823          	sd	a5,1712(a4) # 1000 <freep>
}
 958:	6422                	ld	s0,8(sp)
 95a:	0141                	addi	sp,sp,16
 95c:	8082                	ret

000000000000095e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 95e:	7139                	addi	sp,sp,-64
 960:	fc06                	sd	ra,56(sp)
 962:	f822                	sd	s0,48(sp)
 964:	f426                	sd	s1,40(sp)
 966:	f04a                	sd	s2,32(sp)
 968:	ec4e                	sd	s3,24(sp)
 96a:	e852                	sd	s4,16(sp)
 96c:	e456                	sd	s5,8(sp)
 96e:	e05a                	sd	s6,0(sp)
 970:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 972:	02051493          	slli	s1,a0,0x20
 976:	9081                	srli	s1,s1,0x20
 978:	04bd                	addi	s1,s1,15
 97a:	8091                	srli	s1,s1,0x4
 97c:	0014899b          	addiw	s3,s1,1
 980:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 982:	00000517          	auipc	a0,0x0
 986:	67e53503          	ld	a0,1662(a0) # 1000 <freep>
 98a:	c515                	beqz	a0,9b6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 98e:	4798                	lw	a4,8(a5)
 990:	02977f63          	bgeu	a4,s1,9ce <malloc+0x70>
 994:	8a4e                	mv	s4,s3
 996:	0009871b          	sext.w	a4,s3
 99a:	6685                	lui	a3,0x1
 99c:	00d77363          	bgeu	a4,a3,9a2 <malloc+0x44>
 9a0:	6a05                	lui	s4,0x1
 9a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9aa:	00000917          	auipc	s2,0x0
 9ae:	65690913          	addi	s2,s2,1622 # 1000 <freep>
  if(p == SBRK_ERROR)
 9b2:	5afd                	li	s5,-1
 9b4:	a0bd                	j	a22 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 9b6:	00000797          	auipc	a5,0x0
 9ba:	65a78793          	addi	a5,a5,1626 # 1010 <base>
 9be:	00000717          	auipc	a4,0x0
 9c2:	64f73123          	sd	a5,1602(a4) # 1000 <freep>
 9c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9cc:	b7e1                	j	994 <malloc+0x36>
      if(p->s.size == nunits)
 9ce:	02e48b63          	beq	s1,a4,a04 <malloc+0xa6>
        p->s.size -= nunits;
 9d2:	4137073b          	subw	a4,a4,s3
 9d6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d8:	1702                	slli	a4,a4,0x20
 9da:	9301                	srli	a4,a4,0x20
 9dc:	0712                	slli	a4,a4,0x4
 9de:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9e0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e4:	00000717          	auipc	a4,0x0
 9e8:	60a73e23          	sd	a0,1564(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ec:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9f0:	70e2                	ld	ra,56(sp)
 9f2:	7442                	ld	s0,48(sp)
 9f4:	74a2                	ld	s1,40(sp)
 9f6:	7902                	ld	s2,32(sp)
 9f8:	69e2                	ld	s3,24(sp)
 9fa:	6a42                	ld	s4,16(sp)
 9fc:	6aa2                	ld	s5,8(sp)
 9fe:	6b02                	ld	s6,0(sp)
 a00:	6121                	addi	sp,sp,64
 a02:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a04:	6398                	ld	a4,0(a5)
 a06:	e118                	sd	a4,0(a0)
 a08:	bff1                	j	9e4 <malloc+0x86>
  hp->s.size = nu;
 a0a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a0e:	0541                	addi	a0,a0,16
 a10:	ec7ff0ef          	jal	ra,8d6 <free>
  return freep;
 a14:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a18:	dd61                	beqz	a0,9f0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a1c:	4798                	lw	a4,8(a5)
 a1e:	fa9778e3          	bgeu	a4,s1,9ce <malloc+0x70>
    if(p == freep)
 a22:	00093703          	ld	a4,0(s2)
 a26:	853e                	mv	a0,a5
 a28:	fef719e3          	bne	a4,a5,a1a <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 a2c:	8552                	mv	a0,s4
 a2e:	a17ff0ef          	jal	ra,444 <sbrk>
  if(p == SBRK_ERROR)
 a32:	fd551ce3          	bne	a0,s5,a0a <malloc+0xac>
        return 0;
 a36:	4501                	li	a0,0
 a38:	bf65                	j	9f0 <malloc+0x92>
