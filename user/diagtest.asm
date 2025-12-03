
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
  10:	f05a                	sd	s6,32(sp)
  12:	1080                	addi	s0,sp,96
  struct procinfo info;
  
  printf("=== MLFQ Diagnostics ===\n\n");
  14:	00001517          	auipc	a0,0x1
  18:	a7c50513          	addi	a0,a0,-1412 # a90 <malloc+0xf4>
  1c:	0c9000ef          	jal	8e4 <printf>
  
  // Check initial state
  if(getprocinfo(&info) == 0) {
  20:	fb040513          	addi	a0,s0,-80
  24:	50a000ef          	jal	52e <getprocinfo>
  28:	c50d                	beqz	a0,52 <main+0x52>
    printf("  Priority: Q%d\n", info.priority);
    printf("  Time Slices: %d\n\n", info.time_slices);
  }
  
  // Do a small amount of work and check repeatedly
  printf("Running work bursts and checking time_slices:\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	ae650513          	addi	a0,a0,-1306 # b10 <malloc+0x174>
  32:	0b3000ef          	jal	8e4 <printf>
  for(int i = 0; i < 20; i++) {
  36:	4481                	li	s1,0
    // Work burst - enough to trigger timer interrupts
    volatile int dummy = 0;
  38:	004c5937          	lui	s2,0x4c5
  3c:	b4090913          	addi	s2,s2,-1216 # 4c4b40 <base+0x4c3b30>
    for(int j = 0; j < 5000000; j++) {
      dummy++;
    }
    
    if(getprocinfo(&info) == 0) {
  40:	fb040993          	addi	s3,s0,-80
  for(int i = 0; i < 20; i++) {
  44:	4a51                	li	s4,20
      printf("  Iteration %2d: slices=%d priority=Q%d\n", 
  46:	00001b17          	auipc	s6,0x1
  4a:	afab0b13          	addi	s6,s6,-1286 # b40 <malloc+0x1a4>
             i, info.time_slices, info.priority);
      
      // If time_slices is still 0 after 10 iterations, something is wrong
      if(i == 10 && info.time_slices == 0) {
  4e:	4aa9                	li	s5,10
  50:	a049                	j	d2 <main+0xd2>
    printf("Initial state:\n");
  52:	00001517          	auipc	a0,0x1
  56:	a5e50513          	addi	a0,a0,-1442 # ab0 <malloc+0x114>
  5a:	08b000ef          	jal	8e4 <printf>
    printf("  PID: %d\n", info.pid);
  5e:	fb042583          	lw	a1,-80(s0)
  62:	00001517          	auipc	a0,0x1
  66:	a5e50513          	addi	a0,a0,-1442 # ac0 <malloc+0x124>
  6a:	07b000ef          	jal	8e4 <printf>
    printf("  State: %d\n", info.state);
  6e:	fb442583          	lw	a1,-76(s0)
  72:	00001517          	auipc	a0,0x1
  76:	a5e50513          	addi	a0,a0,-1442 # ad0 <malloc+0x134>
  7a:	06b000ef          	jal	8e4 <printf>
    printf("  Priority: Q%d\n", info.priority);
  7e:	fb842583          	lw	a1,-72(s0)
  82:	00001517          	auipc	a0,0x1
  86:	a5e50513          	addi	a0,a0,-1442 # ae0 <malloc+0x144>
  8a:	05b000ef          	jal	8e4 <printf>
    printf("  Time Slices: %d\n\n", info.time_slices);
  8e:	fbc42583          	lw	a1,-68(s0)
  92:	00001517          	auipc	a0,0x1
  96:	a6650513          	addi	a0,a0,-1434 # af8 <malloc+0x15c>
  9a:	04b000ef          	jal	8e4 <printf>
  9e:	b771                	j	2a <main+0x2a>
      if(i == 10 && info.time_slices == 0) {
  a0:	fbc42783          	lw	a5,-68(s0)
  a4:	c799                	beqz	a5,b2 <main+0xb2>
        printf("*** Timer interrupts may not be working ***\n\n");
        break;
      }
      
      // If we see demotion, report it
      if(info.priority > 0) {
  a6:	fb842583          	lw	a1,-72(s0)
  aa:	06b04063          	bgtz	a1,10a <main+0x10a>
  for(int i = 0; i < 20; i++) {
  ae:	2485                	addiw	s1,s1,1
  b0:	a00d                	j	d2 <main+0xd2>
        printf("\n*** ERROR: time_slices not incrementing! ***\n");
  b2:	00001517          	auipc	a0,0x1
  b6:	abe50513          	addi	a0,a0,-1346 # b70 <malloc+0x1d4>
  ba:	02b000ef          	jal	8e4 <printf>
        printf("*** Timer interrupts may not be working ***\n\n");
  be:	00001517          	auipc	a0,0x1
  c2:	ae250513          	addi	a0,a0,-1310 # ba0 <malloc+0x204>
  c6:	01f000ef          	jal	8e4 <printf>
        break;
  ca:	a881                	j	11a <main+0x11a>
  for(int i = 0; i < 20; i++) {
  cc:	2485                	addiw	s1,s1,1
  ce:	05448663          	beq	s1,s4,11a <main+0x11a>
    volatile int dummy = 0;
  d2:	fa042623          	sw	zero,-84(s0)
  d6:	874a                	mv	a4,s2
      dummy++;
  d8:	fac42783          	lw	a5,-84(s0)
  dc:	2785                	addiw	a5,a5,1
  de:	faf42623          	sw	a5,-84(s0)
    for(int j = 0; j < 5000000; j++) {
  e2:	377d                	addiw	a4,a4,-1
  e4:	fb75                	bnez	a4,d8 <main+0xd8>
    if(getprocinfo(&info) == 0) {
  e6:	854e                	mv	a0,s3
  e8:	446000ef          	jal	52e <getprocinfo>
  ec:	f165                	bnez	a0,cc <main+0xcc>
      printf("  Iteration %2d: slices=%d priority=Q%d\n", 
  ee:	fb842683          	lw	a3,-72(s0)
  f2:	fbc42603          	lw	a2,-68(s0)
  f6:	85a6                	mv	a1,s1
  f8:	855a                	mv	a0,s6
  fa:	7ea000ef          	jal	8e4 <printf>
      if(i == 10 && info.time_slices == 0) {
  fe:	fb5481e3          	beq	s1,s5,a0 <main+0xa0>
      if(info.priority > 0) {
 102:	fb842583          	lw	a1,-72(s0)
 106:	fcb053e3          	blez	a1,cc <main+0xcc>
        printf("\n*** GOOD: Process demoted to Q%d after %d slices! ***\n\n", 
 10a:	fbc42603          	lw	a2,-68(s0)
 10e:	00001517          	auipc	a0,0x1
 112:	ac250513          	addi	a0,a0,-1342 # bd0 <malloc+0x234>
 116:	7ce000ef          	jal	8e4 <printf>
      }
    }
  }
  
  // Final state
  if(getprocinfo(&info) == 0) {
 11a:	fb040513          	addi	a0,s0,-80
 11e:	410000ef          	jal	52e <getprocinfo>
 122:	c501                	beqz	a0,12a <main+0x12a>
      printf("\n=== SUCCESS ===\n");
      printf("Time slice tracking is working!\n");
    }
  }
  
  exit(0);
 124:	4501                	li	a0,0
 126:	368000ef          	jal	48e <exit>
    printf("\nFinal state:\n");
 12a:	00001517          	auipc	a0,0x1
 12e:	ae650513          	addi	a0,a0,-1306 # c10 <malloc+0x274>
 132:	7b2000ef          	jal	8e4 <printf>
    printf("  Priority: Q%d\n", info.priority);
 136:	fb842583          	lw	a1,-72(s0)
 13a:	00001517          	auipc	a0,0x1
 13e:	9a650513          	addi	a0,a0,-1626 # ae0 <malloc+0x144>
 142:	7a2000ef          	jal	8e4 <printf>
    printf("  Time Slices: %d\n", info.time_slices);
 146:	fbc42583          	lw	a1,-68(s0)
 14a:	00001517          	auipc	a0,0x1
 14e:	ad650513          	addi	a0,a0,-1322 # c20 <malloc+0x284>
 152:	792000ef          	jal	8e4 <printf>
    if(info.time_slices == 0) {
 156:	fbc42783          	lw	a5,-68(s0)
 15a:	e3b5                	bnez	a5,1be <main+0x1be>
      printf("\n=== DIAGNOSIS ===\n");
 15c:	00001517          	auipc	a0,0x1
 160:	adc50513          	addi	a0,a0,-1316 # c38 <malloc+0x29c>
 164:	780000ef          	jal	8e4 <printf>
      printf("Problem: time_slices never incremented\n");
 168:	00001517          	auipc	a0,0x1
 16c:	ae850513          	addi	a0,a0,-1304 # c50 <malloc+0x2b4>
 170:	774000ef          	jal	8e4 <printf>
      printf("Possible causes:\n");
 174:	00001517          	auipc	a0,0x1
 178:	b0450513          	addi	a0,a0,-1276 # c78 <malloc+0x2dc>
 17c:	768000ef          	jal	8e4 <printf>
      printf("  1. Timer interrupts not firing (check clockintr)\n");
 180:	00001517          	auipc	a0,0x1
 184:	b1050513          	addi	a0,a0,-1264 # c90 <malloc+0x2f4>
 188:	75c000ef          	jal	8e4 <printf>
      printf("  2. which_dev != 2 in usertrap()\n");
 18c:	00001517          	auipc	a0,0x1
 190:	b3c50513          	addi	a0,a0,-1220 # cc8 <malloc+0x32c>
 194:	750000ef          	jal	8e4 <printf>
      printf("  3. p->time_slices++ not executing\n");
 198:	00001517          	auipc	a0,0x1
 19c:	b5850513          	addi	a0,a0,-1192 # cf0 <malloc+0x354>
 1a0:	744000ef          	jal	8e4 <printf>
      printf("\nAdd debug prints in kernel/trap.c:\n");
 1a4:	00001517          	auipc	a0,0x1
 1a8:	b7450513          	addi	a0,a0,-1164 # d18 <malloc+0x37c>
 1ac:	738000ef          	jal	8e4 <printf>
      printf("  printf(\"Timer: which_dev=%%d pid=%%d\\n\", which_dev, p->pid);\n");
 1b0:	00001517          	auipc	a0,0x1
 1b4:	b9050513          	addi	a0,a0,-1136 # d40 <malloc+0x3a4>
 1b8:	72c000ef          	jal	8e4 <printf>
 1bc:	b7a5                	j	124 <main+0x124>
      printf("\n=== SUCCESS ===\n");
 1be:	00001517          	auipc	a0,0x1
 1c2:	bc250513          	addi	a0,a0,-1086 # d80 <malloc+0x3e4>
 1c6:	71e000ef          	jal	8e4 <printf>
      printf("Time slice tracking is working!\n");
 1ca:	00001517          	auipc	a0,0x1
 1ce:	bce50513          	addi	a0,a0,-1074 # d98 <malloc+0x3fc>
 1d2:	712000ef          	jal	8e4 <printf>
 1d6:	b7b9                	j	124 <main+0x124>

00000000000001d8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e406                	sd	ra,8(sp)
 1dc:	e022                	sd	s0,0(sp)
 1de:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1e0:	e21ff0ef          	jal	0 <main>
  exit(r);
 1e4:	2aa000ef          	jal	48e <exit>

00000000000001e8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e406                	sd	ra,8(sp)
 1ec:	e022                	sd	s0,0(sp)
 1ee:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f0:	87aa                	mv	a5,a0
 1f2:	0585                	addi	a1,a1,1
 1f4:	0785                	addi	a5,a5,1
 1f6:	fff5c703          	lbu	a4,-1(a1)
 1fa:	fee78fa3          	sb	a4,-1(a5)
 1fe:	fb75                	bnez	a4,1f2 <strcpy+0xa>
    ;
  return os;
}
 200:	60a2                	ld	ra,8(sp)
 202:	6402                	ld	s0,0(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret

0000000000000208 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e406                	sd	ra,8(sp)
 20c:	e022                	sd	s0,0(sp)
 20e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 210:	00054783          	lbu	a5,0(a0)
 214:	cb91                	beqz	a5,228 <strcmp+0x20>
 216:	0005c703          	lbu	a4,0(a1)
 21a:	00f71763          	bne	a4,a5,228 <strcmp+0x20>
    p++, q++;
 21e:	0505                	addi	a0,a0,1
 220:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 222:	00054783          	lbu	a5,0(a0)
 226:	fbe5                	bnez	a5,216 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 228:	0005c503          	lbu	a0,0(a1)
}
 22c:	40a7853b          	subw	a0,a5,a0
 230:	60a2                	ld	ra,8(sp)
 232:	6402                	ld	s0,0(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strlen>:

uint
strlen(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e406                	sd	ra,8(sp)
 23c:	e022                	sd	s0,0(sp)
 23e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 240:	00054783          	lbu	a5,0(a0)
 244:	cf91                	beqz	a5,260 <strlen+0x28>
 246:	00150793          	addi	a5,a0,1
 24a:	86be                	mv	a3,a5
 24c:	0785                	addi	a5,a5,1
 24e:	fff7c703          	lbu	a4,-1(a5)
 252:	ff65                	bnez	a4,24a <strlen+0x12>
 254:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 258:	60a2                	ld	ra,8(sp)
 25a:	6402                	ld	s0,0(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
  for(n = 0; s[n]; n++)
 260:	4501                	li	a0,0
 262:	bfdd                	j	258 <strlen+0x20>

0000000000000264 <memset>:

void*
memset(void *dst, int c, uint n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e406                	sd	ra,8(sp)
 268:	e022                	sd	s0,0(sp)
 26a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 26c:	ca19                	beqz	a2,282 <memset+0x1e>
 26e:	87aa                	mv	a5,a0
 270:	1602                	slli	a2,a2,0x20
 272:	9201                	srli	a2,a2,0x20
 274:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 278:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 27c:	0785                	addi	a5,a5,1
 27e:	fee79de3          	bne	a5,a4,278 <memset+0x14>
  }
  return dst;
}
 282:	60a2                	ld	ra,8(sp)
 284:	6402                	ld	s0,0(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret

000000000000028a <strchr>:

char*
strchr(const char *s, char c)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e406                	sd	ra,8(sp)
 28e:	e022                	sd	s0,0(sp)
 290:	0800                	addi	s0,sp,16
  for(; *s; s++)
 292:	00054783          	lbu	a5,0(a0)
 296:	cf81                	beqz	a5,2ae <strchr+0x24>
    if(*s == c)
 298:	00f58763          	beq	a1,a5,2a6 <strchr+0x1c>
  for(; *s; s++)
 29c:	0505                	addi	a0,a0,1
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	fbfd                	bnez	a5,298 <strchr+0xe>
      return (char*)s;
  return 0;
 2a4:	4501                	li	a0,0
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  return 0;
 2ae:	4501                	li	a0,0
 2b0:	bfdd                	j	2a6 <strchr+0x1c>

00000000000002b2 <gets>:

char*
gets(char *buf, int max)
{
 2b2:	711d                	addi	sp,sp,-96
 2b4:	ec86                	sd	ra,88(sp)
 2b6:	e8a2                	sd	s0,80(sp)
 2b8:	e4a6                	sd	s1,72(sp)
 2ba:	e0ca                	sd	s2,64(sp)
 2bc:	fc4e                	sd	s3,56(sp)
 2be:	f852                	sd	s4,48(sp)
 2c0:	f456                	sd	s5,40(sp)
 2c2:	f05a                	sd	s6,32(sp)
 2c4:	ec5e                	sd	s7,24(sp)
 2c6:	e862                	sd	s8,16(sp)
 2c8:	1080                	addi	s0,sp,96
 2ca:	8baa                	mv	s7,a0
 2cc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ce:	892a                	mv	s2,a0
 2d0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2d2:	faf40b13          	addi	s6,s0,-81
 2d6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2d8:	8c26                	mv	s8,s1
 2da:	0014899b          	addiw	s3,s1,1
 2de:	84ce                	mv	s1,s3
 2e0:	0349d463          	bge	s3,s4,308 <gets+0x56>
    cc = read(0, &c, 1);
 2e4:	8656                	mv	a2,s5
 2e6:	85da                	mv	a1,s6
 2e8:	4501                	li	a0,0
 2ea:	1bc000ef          	jal	4a6 <read>
    if(cc < 1)
 2ee:	00a05d63          	blez	a0,308 <gets+0x56>
      break;
    buf[i++] = c;
 2f2:	faf44783          	lbu	a5,-81(s0)
 2f6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2fa:	0905                	addi	s2,s2,1
 2fc:	ff678713          	addi	a4,a5,-10
 300:	c319                	beqz	a4,306 <gets+0x54>
 302:	17cd                	addi	a5,a5,-13
 304:	fbf1                	bnez	a5,2d8 <gets+0x26>
    buf[i++] = c;
 306:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 308:	9c5e                	add	s8,s8,s7
 30a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 30e:	855e                	mv	a0,s7
 310:	60e6                	ld	ra,88(sp)
 312:	6446                	ld	s0,80(sp)
 314:	64a6                	ld	s1,72(sp)
 316:	6906                	ld	s2,64(sp)
 318:	79e2                	ld	s3,56(sp)
 31a:	7a42                	ld	s4,48(sp)
 31c:	7aa2                	ld	s5,40(sp)
 31e:	7b02                	ld	s6,32(sp)
 320:	6be2                	ld	s7,24(sp)
 322:	6c42                	ld	s8,16(sp)
 324:	6125                	addi	sp,sp,96
 326:	8082                	ret

0000000000000328 <stat>:

int
stat(const char *n, struct stat *st)
{
 328:	1101                	addi	sp,sp,-32
 32a:	ec06                	sd	ra,24(sp)
 32c:	e822                	sd	s0,16(sp)
 32e:	e04a                	sd	s2,0(sp)
 330:	1000                	addi	s0,sp,32
 332:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 334:	4581                	li	a1,0
 336:	198000ef          	jal	4ce <open>
  if(fd < 0)
 33a:	02054263          	bltz	a0,35e <stat+0x36>
 33e:	e426                	sd	s1,8(sp)
 340:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 342:	85ca                	mv	a1,s2
 344:	1a2000ef          	jal	4e6 <fstat>
 348:	892a                	mv	s2,a0
  close(fd);
 34a:	8526                	mv	a0,s1
 34c:	16a000ef          	jal	4b6 <close>
  return r;
 350:	64a2                	ld	s1,8(sp)
}
 352:	854a                	mv	a0,s2
 354:	60e2                	ld	ra,24(sp)
 356:	6442                	ld	s0,16(sp)
 358:	6902                	ld	s2,0(sp)
 35a:	6105                	addi	sp,sp,32
 35c:	8082                	ret
    return -1;
 35e:	57fd                	li	a5,-1
 360:	893e                	mv	s2,a5
 362:	bfc5                	j	352 <stat+0x2a>

0000000000000364 <atoi>:

int
atoi(const char *s)
{
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 36c:	00054683          	lbu	a3,0(a0)
 370:	fd06879b          	addiw	a5,a3,-48
 374:	0ff7f793          	zext.b	a5,a5
 378:	4625                	li	a2,9
 37a:	02f66963          	bltu	a2,a5,3ac <atoi+0x48>
 37e:	872a                	mv	a4,a0
  n = 0;
 380:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 382:	0705                	addi	a4,a4,1
 384:	0025179b          	slliw	a5,a0,0x2
 388:	9fa9                	addw	a5,a5,a0
 38a:	0017979b          	slliw	a5,a5,0x1
 38e:	9fb5                	addw	a5,a5,a3
 390:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 394:	00074683          	lbu	a3,0(a4)
 398:	fd06879b          	addiw	a5,a3,-48
 39c:	0ff7f793          	zext.b	a5,a5
 3a0:	fef671e3          	bgeu	a2,a5,382 <atoi+0x1e>
  return n;
}
 3a4:	60a2                	ld	ra,8(sp)
 3a6:	6402                	ld	s0,0(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
  n = 0;
 3ac:	4501                	li	a0,0
 3ae:	bfdd                	j	3a4 <atoi+0x40>

00000000000003b0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e406                	sd	ra,8(sp)
 3b4:	e022                	sd	s0,0(sp)
 3b6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b8:	02b57563          	bgeu	a0,a1,3e2 <memmove+0x32>
    while(n-- > 0)
 3bc:	00c05f63          	blez	a2,3da <memmove+0x2a>
 3c0:	1602                	slli	a2,a2,0x20
 3c2:	9201                	srli	a2,a2,0x20
 3c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ca:	0585                	addi	a1,a1,1
 3cc:	0705                	addi	a4,a4,1
 3ce:	fff5c683          	lbu	a3,-1(a1)
 3d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d6:	fee79ae3          	bne	a5,a4,3ca <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3da:	60a2                	ld	ra,8(sp)
 3dc:	6402                	ld	s0,0(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
    while(n-- > 0)
 3e2:	fec05ce3          	blez	a2,3da <memmove+0x2a>
    dst += n;
 3e6:	00c50733          	add	a4,a0,a2
    src += n;
 3ea:	95b2                	add	a1,a1,a2
 3ec:	fff6079b          	addiw	a5,a2,-1
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	fff7c793          	not	a5,a5
 3f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fa:	15fd                	addi	a1,a1,-1
 3fc:	177d                	addi	a4,a4,-1
 3fe:	0005c683          	lbu	a3,0(a1)
 402:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 406:	fef71ae3          	bne	a4,a5,3fa <memmove+0x4a>
 40a:	bfc1                	j	3da <memmove+0x2a>

000000000000040c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40c:	1141                	addi	sp,sp,-16
 40e:	e406                	sd	ra,8(sp)
 410:	e022                	sd	s0,0(sp)
 412:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 414:	c61d                	beqz	a2,442 <memcmp+0x36>
 416:	1602                	slli	a2,a2,0x20
 418:	9201                	srli	a2,a2,0x20
 41a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 41e:	00054783          	lbu	a5,0(a0)
 422:	0005c703          	lbu	a4,0(a1)
 426:	00e79863          	bne	a5,a4,436 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 42a:	0505                	addi	a0,a0,1
    p2++;
 42c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 42e:	fed518e3          	bne	a0,a3,41e <memcmp+0x12>
  }
  return 0;
 432:	4501                	li	a0,0
 434:	a019                	j	43a <memcmp+0x2e>
      return *p1 - *p2;
 436:	40e7853b          	subw	a0,a5,a4
}
 43a:	60a2                	ld	ra,8(sp)
 43c:	6402                	ld	s0,0(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
  return 0;
 442:	4501                	li	a0,0
 444:	bfdd                	j	43a <memcmp+0x2e>

0000000000000446 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 446:	1141                	addi	sp,sp,-16
 448:	e406                	sd	ra,8(sp)
 44a:	e022                	sd	s0,0(sp)
 44c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44e:	f63ff0ef          	jal	3b0 <memmove>
}
 452:	60a2                	ld	ra,8(sp)
 454:	6402                	ld	s0,0(sp)
 456:	0141                	addi	sp,sp,16
 458:	8082                	ret

000000000000045a <sbrk>:

char *
sbrk(int n) {
 45a:	1141                	addi	sp,sp,-16
 45c:	e406                	sd	ra,8(sp)
 45e:	e022                	sd	s0,0(sp)
 460:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 462:	4585                	li	a1,1
 464:	0b2000ef          	jal	516 <sys_sbrk>
}
 468:	60a2                	ld	ra,8(sp)
 46a:	6402                	ld	s0,0(sp)
 46c:	0141                	addi	sp,sp,16
 46e:	8082                	ret

0000000000000470 <sbrklazy>:

char *
sbrklazy(int n) {
 470:	1141                	addi	sp,sp,-16
 472:	e406                	sd	ra,8(sp)
 474:	e022                	sd	s0,0(sp)
 476:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 478:	4589                	li	a1,2
 47a:	09c000ef          	jal	516 <sys_sbrk>
}
 47e:	60a2                	ld	ra,8(sp)
 480:	6402                	ld	s0,0(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret

0000000000000486 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 486:	4885                	li	a7,1
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <exit>:
.global exit
exit:
 li a7, SYS_exit
 48e:	4889                	li	a7,2
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <wait>:
.global wait
wait:
 li a7, SYS_wait
 496:	488d                	li	a7,3
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 49e:	4891                	li	a7,4
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <read>:
.global read
read:
 li a7, SYS_read
 4a6:	4895                	li	a7,5
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <write>:
.global write
write:
 li a7, SYS_write
 4ae:	48c1                	li	a7,16
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <close>:
.global close
close:
 li a7, SYS_close
 4b6:	48d5                	li	a7,21
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <kill>:
.global kill
kill:
 li a7, SYS_kill
 4be:	4899                	li	a7,6
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c6:	489d                	li	a7,7
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <open>:
.global open
open:
 li a7, SYS_open
 4ce:	48bd                	li	a7,15
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d6:	48c5                	li	a7,17
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4de:	48c9                	li	a7,18
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e6:	48a1                	li	a7,8
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <link>:
.global link
link:
 li a7, SYS_link
 4ee:	48cd                	li	a7,19
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f6:	48d1                	li	a7,20
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4fe:	48a5                	li	a7,9
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <dup>:
.global dup
dup:
 li a7, SYS_dup
 506:	48a9                	li	a7,10
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 50e:	48ad                	li	a7,11
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 516:	48b1                	li	a7,12
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <pause>:
.global pause
pause:
 li a7, SYS_pause
 51e:	48b5                	li	a7,13
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 526:	48b9                	li	a7,14
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 52e:	48d9                	li	a7,22
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 536:	48dd                	li	a7,23
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 53e:	1101                	addi	sp,sp,-32
 540:	ec06                	sd	ra,24(sp)
 542:	e822                	sd	s0,16(sp)
 544:	1000                	addi	s0,sp,32
 546:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 54a:	4605                	li	a2,1
 54c:	fef40593          	addi	a1,s0,-17
 550:	f5fff0ef          	jal	4ae <write>
}
 554:	60e2                	ld	ra,24(sp)
 556:	6442                	ld	s0,16(sp)
 558:	6105                	addi	sp,sp,32
 55a:	8082                	ret

000000000000055c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 55c:	715d                	addi	sp,sp,-80
 55e:	e486                	sd	ra,72(sp)
 560:	e0a2                	sd	s0,64(sp)
 562:	f84a                	sd	s2,48(sp)
 564:	f44e                	sd	s3,40(sp)
 566:	0880                	addi	s0,sp,80
 568:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 56a:	c6d1                	beqz	a3,5f6 <printint+0x9a>
 56c:	0805d563          	bgez	a1,5f6 <printint+0x9a>
    neg = 1;
    x = -xx;
 570:	40b005b3          	neg	a1,a1
    neg = 1;
 574:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 576:	fb840993          	addi	s3,s0,-72
  neg = 0;
 57a:	86ce                	mv	a3,s3
  i = 0;
 57c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 57e:	00001817          	auipc	a6,0x1
 582:	84a80813          	addi	a6,a6,-1974 # dc8 <digits>
 586:	88ba                	mv	a7,a4
 588:	0017051b          	addiw	a0,a4,1
 58c:	872a                	mv	a4,a0
 58e:	02c5f7b3          	remu	a5,a1,a2
 592:	97c2                	add	a5,a5,a6
 594:	0007c783          	lbu	a5,0(a5)
 598:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 59c:	87ae                	mv	a5,a1
 59e:	02c5d5b3          	divu	a1,a1,a2
 5a2:	0685                	addi	a3,a3,1
 5a4:	fec7f1e3          	bgeu	a5,a2,586 <printint+0x2a>
  if(neg)
 5a8:	00030c63          	beqz	t1,5c0 <printint+0x64>
    buf[i++] = '-';
 5ac:	fd050793          	addi	a5,a0,-48
 5b0:	00878533          	add	a0,a5,s0
 5b4:	02d00793          	li	a5,45
 5b8:	fef50423          	sb	a5,-24(a0)
 5bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 5c0:	02e05563          	blez	a4,5ea <printint+0x8e>
 5c4:	fc26                	sd	s1,56(sp)
 5c6:	377d                	addiw	a4,a4,-1
 5c8:	00e984b3          	add	s1,s3,a4
 5cc:	19fd                	addi	s3,s3,-1
 5ce:	99ba                	add	s3,s3,a4
 5d0:	1702                	slli	a4,a4,0x20
 5d2:	9301                	srli	a4,a4,0x20
 5d4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d8:	0004c583          	lbu	a1,0(s1)
 5dc:	854a                	mv	a0,s2
 5de:	f61ff0ef          	jal	53e <putc>
  while(--i >= 0)
 5e2:	14fd                	addi	s1,s1,-1
 5e4:	ff349ae3          	bne	s1,s3,5d8 <printint+0x7c>
 5e8:	74e2                	ld	s1,56(sp)
}
 5ea:	60a6                	ld	ra,72(sp)
 5ec:	6406                	ld	s0,64(sp)
 5ee:	7942                	ld	s2,48(sp)
 5f0:	79a2                	ld	s3,40(sp)
 5f2:	6161                	addi	sp,sp,80
 5f4:	8082                	ret
  neg = 0;
 5f6:	4301                	li	t1,0
 5f8:	bfbd                	j	576 <printint+0x1a>

00000000000005fa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5fa:	711d                	addi	sp,sp,-96
 5fc:	ec86                	sd	ra,88(sp)
 5fe:	e8a2                	sd	s0,80(sp)
 600:	e4a6                	sd	s1,72(sp)
 602:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 604:	0005c483          	lbu	s1,0(a1)
 608:	22048363          	beqz	s1,82e <vprintf+0x234>
 60c:	e0ca                	sd	s2,64(sp)
 60e:	fc4e                	sd	s3,56(sp)
 610:	f852                	sd	s4,48(sp)
 612:	f456                	sd	s5,40(sp)
 614:	f05a                	sd	s6,32(sp)
 616:	ec5e                	sd	s7,24(sp)
 618:	e862                	sd	s8,16(sp)
 61a:	8b2a                	mv	s6,a0
 61c:	8a2e                	mv	s4,a1
 61e:	8bb2                	mv	s7,a2
  state = 0;
 620:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 622:	4901                	li	s2,0
 624:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 626:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 62a:	06400c13          	li	s8,100
 62e:	a00d                	j	650 <vprintf+0x56>
        putc(fd, c0);
 630:	85a6                	mv	a1,s1
 632:	855a                	mv	a0,s6
 634:	f0bff0ef          	jal	53e <putc>
 638:	a019                	j	63e <vprintf+0x44>
    } else if(state == '%'){
 63a:	03598363          	beq	s3,s5,660 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 63e:	0019079b          	addiw	a5,s2,1
 642:	893e                	mv	s2,a5
 644:	873e                	mv	a4,a5
 646:	97d2                	add	a5,a5,s4
 648:	0007c483          	lbu	s1,0(a5)
 64c:	1c048a63          	beqz	s1,820 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 650:	0004879b          	sext.w	a5,s1
    if(state == 0){
 654:	fe0993e3          	bnez	s3,63a <vprintf+0x40>
      if(c0 == '%'){
 658:	fd579ce3          	bne	a5,s5,630 <vprintf+0x36>
        state = '%';
 65c:	89be                	mv	s3,a5
 65e:	b7c5                	j	63e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 660:	00ea06b3          	add	a3,s4,a4
 664:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 668:	1c060863          	beqz	a2,838 <vprintf+0x23e>
      if(c0 == 'd'){
 66c:	03878763          	beq	a5,s8,69a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 670:	f9478693          	addi	a3,a5,-108
 674:	0016b693          	seqz	a3,a3
 678:	f9c60593          	addi	a1,a2,-100
 67c:	e99d                	bnez	a1,6b2 <vprintf+0xb8>
 67e:	ca95                	beqz	a3,6b2 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 680:	008b8493          	addi	s1,s7,8
 684:	4685                	li	a3,1
 686:	4629                	li	a2,10
 688:	000bb583          	ld	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	ecfff0ef          	jal	55c <printint>
        i += 1;
 692:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 694:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 696:	4981                	li	s3,0
 698:	b75d                	j	63e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 69a:	008b8493          	addi	s1,s7,8
 69e:	4685                	li	a3,1
 6a0:	4629                	li	a2,10
 6a2:	000ba583          	lw	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	eb5ff0ef          	jal	55c <printint>
 6ac:	8ba6                	mv	s7,s1
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b779                	j	63e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 6b2:	9752                	add	a4,a4,s4
 6b4:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b8:	f9460713          	addi	a4,a2,-108
 6bc:	00173713          	seqz	a4,a4
 6c0:	8f75                	and	a4,a4,a3
 6c2:	f9c58513          	addi	a0,a1,-100
 6c6:	18051363          	bnez	a0,84c <vprintf+0x252>
 6ca:	18070163          	beqz	a4,84c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ce:	008b8493          	addi	s1,s7,8
 6d2:	4685                	li	a3,1
 6d4:	4629                	li	a2,10
 6d6:	000bb583          	ld	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	e81ff0ef          	jal	55c <printint>
        i += 2;
 6e0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e2:	8ba6                	mv	s7,s1
      state = 0;
 6e4:	4981                	li	s3,0
        i += 2;
 6e6:	bfa1                	j	63e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6e8:	008b8493          	addi	s1,s7,8
 6ec:	4681                	li	a3,0
 6ee:	4629                	li	a2,10
 6f0:	000be583          	lwu	a1,0(s7)
 6f4:	855a                	mv	a0,s6
 6f6:	e67ff0ef          	jal	55c <printint>
 6fa:	8ba6                	mv	s7,s1
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	b781                	j	63e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 700:	008b8493          	addi	s1,s7,8
 704:	4681                	li	a3,0
 706:	4629                	li	a2,10
 708:	000bb583          	ld	a1,0(s7)
 70c:	855a                	mv	a0,s6
 70e:	e4fff0ef          	jal	55c <printint>
        i += 1;
 712:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 714:	8ba6                	mv	s7,s1
      state = 0;
 716:	4981                	li	s3,0
 718:	b71d                	j	63e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71a:	008b8493          	addi	s1,s7,8
 71e:	4681                	li	a3,0
 720:	4629                	li	a2,10
 722:	000bb583          	ld	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	e35ff0ef          	jal	55c <printint>
        i += 2;
 72c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 72e:	8ba6                	mv	s7,s1
      state = 0;
 730:	4981                	li	s3,0
        i += 2;
 732:	b731                	j	63e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 734:	008b8493          	addi	s1,s7,8
 738:	4681                	li	a3,0
 73a:	4641                	li	a2,16
 73c:	000be583          	lwu	a1,0(s7)
 740:	855a                	mv	a0,s6
 742:	e1bff0ef          	jal	55c <printint>
 746:	8ba6                	mv	s7,s1
      state = 0;
 748:	4981                	li	s3,0
 74a:	bdd5                	j	63e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 74c:	008b8493          	addi	s1,s7,8
 750:	4681                	li	a3,0
 752:	4641                	li	a2,16
 754:	000bb583          	ld	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	e03ff0ef          	jal	55c <printint>
        i += 1;
 75e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 760:	8ba6                	mv	s7,s1
      state = 0;
 762:	4981                	li	s3,0
 764:	bde9                	j	63e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 766:	008b8493          	addi	s1,s7,8
 76a:	4681                	li	a3,0
 76c:	4641                	li	a2,16
 76e:	000bb583          	ld	a1,0(s7)
 772:	855a                	mv	a0,s6
 774:	de9ff0ef          	jal	55c <printint>
        i += 2;
 778:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 77a:	8ba6                	mv	s7,s1
      state = 0;
 77c:	4981                	li	s3,0
        i += 2;
 77e:	b5c1                	j	63e <vprintf+0x44>
 780:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 782:	008b8793          	addi	a5,s7,8
 786:	8cbe                	mv	s9,a5
 788:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 78c:	03000593          	li	a1,48
 790:	855a                	mv	a0,s6
 792:	dadff0ef          	jal	53e <putc>
  putc(fd, 'x');
 796:	07800593          	li	a1,120
 79a:	855a                	mv	a0,s6
 79c:	da3ff0ef          	jal	53e <putc>
 7a0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a2:	00000b97          	auipc	s7,0x0
 7a6:	626b8b93          	addi	s7,s7,1574 # dc8 <digits>
 7aa:	03c9d793          	srli	a5,s3,0x3c
 7ae:	97de                	add	a5,a5,s7
 7b0:	0007c583          	lbu	a1,0(a5)
 7b4:	855a                	mv	a0,s6
 7b6:	d89ff0ef          	jal	53e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ba:	0992                	slli	s3,s3,0x4
 7bc:	34fd                	addiw	s1,s1,-1
 7be:	f4f5                	bnez	s1,7aa <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7c0:	8be6                	mv	s7,s9
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	6ca2                	ld	s9,8(sp)
 7c6:	bda5                	j	63e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7c8:	008b8493          	addi	s1,s7,8
 7cc:	000bc583          	lbu	a1,0(s7)
 7d0:	855a                	mv	a0,s6
 7d2:	d6dff0ef          	jal	53e <putc>
 7d6:	8ba6                	mv	s7,s1
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	b595                	j	63e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7dc:	008b8993          	addi	s3,s7,8
 7e0:	000bb483          	ld	s1,0(s7)
 7e4:	cc91                	beqz	s1,800 <vprintf+0x206>
        for(; *s; s++)
 7e6:	0004c583          	lbu	a1,0(s1)
 7ea:	c985                	beqz	a1,81a <vprintf+0x220>
          putc(fd, *s);
 7ec:	855a                	mv	a0,s6
 7ee:	d51ff0ef          	jal	53e <putc>
        for(; *s; s++)
 7f2:	0485                	addi	s1,s1,1
 7f4:	0004c583          	lbu	a1,0(s1)
 7f8:	f9f5                	bnez	a1,7ec <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7fa:	8bce                	mv	s7,s3
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	b581                	j	63e <vprintf+0x44>
          s = "(null)";
 800:	00000497          	auipc	s1,0x0
 804:	5c048493          	addi	s1,s1,1472 # dc0 <malloc+0x424>
        for(; *s; s++)
 808:	02800593          	li	a1,40
 80c:	b7c5                	j	7ec <vprintf+0x1f2>
        putc(fd, '%');
 80e:	85be                	mv	a1,a5
 810:	855a                	mv	a0,s6
 812:	d2dff0ef          	jal	53e <putc>
      state = 0;
 816:	4981                	li	s3,0
 818:	b51d                	j	63e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 81a:	8bce                	mv	s7,s3
      state = 0;
 81c:	4981                	li	s3,0
 81e:	b505                	j	63e <vprintf+0x44>
 820:	6906                	ld	s2,64(sp)
 822:	79e2                	ld	s3,56(sp)
 824:	7a42                	ld	s4,48(sp)
 826:	7aa2                	ld	s5,40(sp)
 828:	7b02                	ld	s6,32(sp)
 82a:	6be2                	ld	s7,24(sp)
 82c:	6c42                	ld	s8,16(sp)
    }
  }
}
 82e:	60e6                	ld	ra,88(sp)
 830:	6446                	ld	s0,80(sp)
 832:	64a6                	ld	s1,72(sp)
 834:	6125                	addi	sp,sp,96
 836:	8082                	ret
      if(c0 == 'd'){
 838:	06400713          	li	a4,100
 83c:	e4e78fe3          	beq	a5,a4,69a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 840:	f9478693          	addi	a3,a5,-108
 844:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 848:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 84a:	4701                	li	a4,0
      } else if(c0 == 'u'){
 84c:	07500513          	li	a0,117
 850:	e8a78ce3          	beq	a5,a0,6e8 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 854:	f8b60513          	addi	a0,a2,-117
 858:	e119                	bnez	a0,85e <vprintf+0x264>
 85a:	ea0693e3          	bnez	a3,700 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 85e:	f8b58513          	addi	a0,a1,-117
 862:	e119                	bnez	a0,868 <vprintf+0x26e>
 864:	ea071be3          	bnez	a4,71a <vprintf+0x120>
      } else if(c0 == 'x'){
 868:	07800513          	li	a0,120
 86c:	eca784e3          	beq	a5,a0,734 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 870:	f8860613          	addi	a2,a2,-120
 874:	e219                	bnez	a2,87a <vprintf+0x280>
 876:	ec069be3          	bnez	a3,74c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 87a:	f8858593          	addi	a1,a1,-120
 87e:	e199                	bnez	a1,884 <vprintf+0x28a>
 880:	ee0713e3          	bnez	a4,766 <vprintf+0x16c>
      } else if(c0 == 'p'){
 884:	07000713          	li	a4,112
 888:	eee78ce3          	beq	a5,a4,780 <vprintf+0x186>
      } else if(c0 == 'c'){
 88c:	06300713          	li	a4,99
 890:	f2e78ce3          	beq	a5,a4,7c8 <vprintf+0x1ce>
      } else if(c0 == 's'){
 894:	07300713          	li	a4,115
 898:	f4e782e3          	beq	a5,a4,7dc <vprintf+0x1e2>
      } else if(c0 == '%'){
 89c:	02500713          	li	a4,37
 8a0:	f6e787e3          	beq	a5,a4,80e <vprintf+0x214>
        putc(fd, '%');
 8a4:	02500593          	li	a1,37
 8a8:	855a                	mv	a0,s6
 8aa:	c95ff0ef          	jal	53e <putc>
        putc(fd, c0);
 8ae:	85a6                	mv	a1,s1
 8b0:	855a                	mv	a0,s6
 8b2:	c8dff0ef          	jal	53e <putc>
      state = 0;
 8b6:	4981                	li	s3,0
 8b8:	b359                	j	63e <vprintf+0x44>

00000000000008ba <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8ba:	715d                	addi	sp,sp,-80
 8bc:	ec06                	sd	ra,24(sp)
 8be:	e822                	sd	s0,16(sp)
 8c0:	1000                	addi	s0,sp,32
 8c2:	e010                	sd	a2,0(s0)
 8c4:	e414                	sd	a3,8(s0)
 8c6:	e818                	sd	a4,16(s0)
 8c8:	ec1c                	sd	a5,24(s0)
 8ca:	03043023          	sd	a6,32(s0)
 8ce:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8d2:	8622                	mv	a2,s0
 8d4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8d8:	d23ff0ef          	jal	5fa <vprintf>
}
 8dc:	60e2                	ld	ra,24(sp)
 8de:	6442                	ld	s0,16(sp)
 8e0:	6161                	addi	sp,sp,80
 8e2:	8082                	ret

00000000000008e4 <printf>:

void
printf(const char *fmt, ...)
{
 8e4:	711d                	addi	sp,sp,-96
 8e6:	ec06                	sd	ra,24(sp)
 8e8:	e822                	sd	s0,16(sp)
 8ea:	1000                	addi	s0,sp,32
 8ec:	e40c                	sd	a1,8(s0)
 8ee:	e810                	sd	a2,16(s0)
 8f0:	ec14                	sd	a3,24(s0)
 8f2:	f018                	sd	a4,32(s0)
 8f4:	f41c                	sd	a5,40(s0)
 8f6:	03043823          	sd	a6,48(s0)
 8fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8fe:	00840613          	addi	a2,s0,8
 902:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 906:	85aa                	mv	a1,a0
 908:	4505                	li	a0,1
 90a:	cf1ff0ef          	jal	5fa <vprintf>
}
 90e:	60e2                	ld	ra,24(sp)
 910:	6442                	ld	s0,16(sp)
 912:	6125                	addi	sp,sp,96
 914:	8082                	ret

0000000000000916 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 916:	1141                	addi	sp,sp,-16
 918:	e406                	sd	ra,8(sp)
 91a:	e022                	sd	s0,0(sp)
 91c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 91e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 922:	00000797          	auipc	a5,0x0
 926:	6de7b783          	ld	a5,1758(a5) # 1000 <freep>
 92a:	a039                	j	938 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 92c:	6398                	ld	a4,0(a5)
 92e:	00e7e463          	bltu	a5,a4,936 <free+0x20>
 932:	00e6ea63          	bltu	a3,a4,946 <free+0x30>
{
 936:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 938:	fed7fae3          	bgeu	a5,a3,92c <free+0x16>
 93c:	6398                	ld	a4,0(a5)
 93e:	00e6e463          	bltu	a3,a4,946 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 942:	fee7eae3          	bltu	a5,a4,936 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 946:	ff852583          	lw	a1,-8(a0)
 94a:	6390                	ld	a2,0(a5)
 94c:	02059813          	slli	a6,a1,0x20
 950:	01c85713          	srli	a4,a6,0x1c
 954:	9736                	add	a4,a4,a3
 956:	02e60563          	beq	a2,a4,980 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 95a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 95e:	4790                	lw	a2,8(a5)
 960:	02061593          	slli	a1,a2,0x20
 964:	01c5d713          	srli	a4,a1,0x1c
 968:	973e                	add	a4,a4,a5
 96a:	02e68263          	beq	a3,a4,98e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 96e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 970:	00000717          	auipc	a4,0x0
 974:	68f73823          	sd	a5,1680(a4) # 1000 <freep>
}
 978:	60a2                	ld	ra,8(sp)
 97a:	6402                	ld	s0,0(sp)
 97c:	0141                	addi	sp,sp,16
 97e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 980:	4618                	lw	a4,8(a2)
 982:	9f2d                	addw	a4,a4,a1
 984:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 988:	6398                	ld	a4,0(a5)
 98a:	6310                	ld	a2,0(a4)
 98c:	b7f9                	j	95a <free+0x44>
    p->s.size += bp->s.size;
 98e:	ff852703          	lw	a4,-8(a0)
 992:	9f31                	addw	a4,a4,a2
 994:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 996:	ff053683          	ld	a3,-16(a0)
 99a:	bfd1                	j	96e <free+0x58>

000000000000099c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 99c:	7139                	addi	sp,sp,-64
 99e:	fc06                	sd	ra,56(sp)
 9a0:	f822                	sd	s0,48(sp)
 9a2:	f04a                	sd	s2,32(sp)
 9a4:	ec4e                	sd	s3,24(sp)
 9a6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9a8:	02051993          	slli	s3,a0,0x20
 9ac:	0209d993          	srli	s3,s3,0x20
 9b0:	09bd                	addi	s3,s3,15
 9b2:	0049d993          	srli	s3,s3,0x4
 9b6:	2985                	addiw	s3,s3,1
 9b8:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 9ba:	00000517          	auipc	a0,0x0
 9be:	64653503          	ld	a0,1606(a0) # 1000 <freep>
 9c2:	c905                	beqz	a0,9f2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c6:	4798                	lw	a4,8(a5)
 9c8:	09377663          	bgeu	a4,s3,a54 <malloc+0xb8>
 9cc:	f426                	sd	s1,40(sp)
 9ce:	e852                	sd	s4,16(sp)
 9d0:	e456                	sd	s5,8(sp)
 9d2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9d4:	8a4e                	mv	s4,s3
 9d6:	6705                	lui	a4,0x1
 9d8:	00e9f363          	bgeu	s3,a4,9de <malloc+0x42>
 9dc:	6a05                	lui	s4,0x1
 9de:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9e6:	00000497          	auipc	s1,0x0
 9ea:	61a48493          	addi	s1,s1,1562 # 1000 <freep>
  if(p == SBRK_ERROR)
 9ee:	5afd                	li	s5,-1
 9f0:	a83d                	j	a2e <malloc+0x92>
 9f2:	f426                	sd	s1,40(sp)
 9f4:	e852                	sd	s4,16(sp)
 9f6:	e456                	sd	s5,8(sp)
 9f8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9fa:	00000797          	auipc	a5,0x0
 9fe:	61678793          	addi	a5,a5,1558 # 1010 <base>
 a02:	00000717          	auipc	a4,0x0
 a06:	5ef73f23          	sd	a5,1534(a4) # 1000 <freep>
 a0a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a0c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a10:	b7d1                	j	9d4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a12:	6398                	ld	a4,0(a5)
 a14:	e118                	sd	a4,0(a0)
 a16:	a899                	j	a6c <malloc+0xd0>
  hp->s.size = nu;
 a18:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a1c:	0541                	addi	a0,a0,16
 a1e:	ef9ff0ef          	jal	916 <free>
  return freep;
 a22:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a24:	c125                	beqz	a0,a84 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a26:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a28:	4798                	lw	a4,8(a5)
 a2a:	03277163          	bgeu	a4,s2,a4c <malloc+0xb0>
    if(p == freep)
 a2e:	6098                	ld	a4,0(s1)
 a30:	853e                	mv	a0,a5
 a32:	fef71ae3          	bne	a4,a5,a26 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a36:	8552                	mv	a0,s4
 a38:	a23ff0ef          	jal	45a <sbrk>
  if(p == SBRK_ERROR)
 a3c:	fd551ee3          	bne	a0,s5,a18 <malloc+0x7c>
        return 0;
 a40:	4501                	li	a0,0
 a42:	74a2                	ld	s1,40(sp)
 a44:	6a42                	ld	s4,16(sp)
 a46:	6aa2                	ld	s5,8(sp)
 a48:	6b02                	ld	s6,0(sp)
 a4a:	a03d                	j	a78 <malloc+0xdc>
 a4c:	74a2                	ld	s1,40(sp)
 a4e:	6a42                	ld	s4,16(sp)
 a50:	6aa2                	ld	s5,8(sp)
 a52:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a54:	fae90fe3          	beq	s2,a4,a12 <malloc+0x76>
        p->s.size -= nunits;
 a58:	4137073b          	subw	a4,a4,s3
 a5c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a5e:	02071693          	slli	a3,a4,0x20
 a62:	01c6d713          	srli	a4,a3,0x1c
 a66:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a68:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a6c:	00000717          	auipc	a4,0x0
 a70:	58a73a23          	sd	a0,1428(a4) # 1000 <freep>
      return (void*)(p + 1);
 a74:	01078513          	addi	a0,a5,16
  }
}
 a78:	70e2                	ld	ra,56(sp)
 a7a:	7442                	ld	s0,48(sp)
 a7c:	7902                	ld	s2,32(sp)
 a7e:	69e2                	ld	s3,24(sp)
 a80:	6121                	addi	sp,sp,64
 a82:	8082                	ret
 a84:	74a2                	ld	s1,40(sp)
 a86:	6a42                	ld	s4,16(sp)
 a88:	6aa2                	ld	s5,8(sp)
 a8a:	6b02                	ld	s6,0(sp)
 a8c:	b7f5                	j	a78 <malloc+0xdc>
