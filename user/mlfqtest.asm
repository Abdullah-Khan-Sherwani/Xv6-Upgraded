
user/_mlfqtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Mixed workload test: CPU-bound vs I/O-bound side by side
// Demonstrates scheduler prioritizes I/O-bound over CPU-bound
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
  int cpid1, cpid2;
  
  printf("=== Comprehensive Mixed Workload Test ===\n");
  14:	00001517          	auipc	a0,0x1
  18:	a0c50513          	addi	a0,a0,-1524 # a20 <malloc+0xe0>
  1c:	06b000ef          	jal	ra,886 <printf>
  printf("Running CPU-bound and I/O-bound processes concurrently.\n");
  20:	00001517          	auipc	a0,0x1
  24:	a3050513          	addi	a0,a0,-1488 # a50 <malloc+0x110>
  28:	05f000ef          	jal	ra,886 <printf>
  printf("This shows the scheduler's fairness: CPU-bound demotes, I/O-bound stays high.\n\n");
  2c:	00001517          	auipc	a0,0x1
  30:	a6450513          	addi	a0,a0,-1436 # a90 <malloc+0x150>
  34:	053000ef          	jal	ra,886 <printf>
  
  // Fork CPU-bound process
  cpid1 = fork();
  38:	41a000ef          	jal	ra,452 <fork>
  if(cpid1 == 0) {
  3c:	e145                	bnez	a0,dc <main+0xdc>
  3e:	89aa                	mv	s3,a0
    printf("[CPU-BOUND] Starting long computation...\n");
  40:	00001517          	auipc	a0,0x1
  44:	aa050513          	addi	a0,a0,-1376 # ae0 <malloc+0x1a0>
  48:	03f000ef          	jal	ra,886 <printf>
    volatile int dummy = 0;
  4c:	fa042623          	sw	zero,-84(s0)
    
    // Do lots of CPU work continuously - should demote significantly
    for(int iter = 0; iter < 40; iter++) {
      for(long j = 0; j < 10000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
  50:	000f4937          	lui	s2,0xf4
  54:	2409091b          	addiw	s2,s2,576
      for(long j = 0; j < 10000000; j++) {
  58:	009894b7          	lui	s1,0x989
  5c:	68048493          	addi	s1,s1,1664 # 989680 <base+0x988670>
      }
      
      // Checkpoint every 10 iterations
      struct procinfo info;
      if(iter % 10 == 0 && getprocinfo(&info) == 0) {
  60:	4aa9                	li	s5,10
        printf("[CPU-BOUND] Iteration %d: Q%d (slices=%d)\n", 
  62:	00001b17          	auipc	s6,0x1
  66:	aaeb0b13          	addi	s6,s6,-1362 # b10 <malloc+0x1d0>
    for(int iter = 0; iter < 40; iter++) {
  6a:	02800a13          	li	s4,40
  6e:	a021                	j	76 <main+0x76>
  70:	2985                	addiw	s3,s3,1
  72:	05498263          	beq	s3,s4,b6 <main+0xb6>
      for(long j = 0; j < 10000000; j++) {
  76:	4781                	li	a5,0
        dummy = dummy + j;
  78:	fac42703          	lw	a4,-84(s0)
  7c:	9f3d                	addw	a4,a4,a5
  7e:	fae42623          	sw	a4,-84(s0)
        dummy = dummy % 1000000;
  82:	fac42703          	lw	a4,-84(s0)
  86:	0327673b          	remw	a4,a4,s2
  8a:	fae42623          	sw	a4,-84(s0)
      for(long j = 0; j < 10000000; j++) {
  8e:	0785                	addi	a5,a5,1
  90:	fe9794e3          	bne	a5,s1,78 <main+0x78>
      if(iter % 10 == 0 && getprocinfo(&info) == 0) {
  94:	0359e7bb          	remw	a5,s3,s5
  98:	ffe1                	bnez	a5,70 <main+0x70>
  9a:	fb040513          	addi	a0,s0,-80
  9e:	45c000ef          	jal	ra,4fa <getprocinfo>
  a2:	f579                	bnez	a0,70 <main+0x70>
        printf("[CPU-BOUND] Iteration %d: Q%d (slices=%d)\n", 
  a4:	fbc42683          	lw	a3,-68(s0)
  a8:	fb842603          	lw	a2,-72(s0)
  ac:	85ce                	mv	a1,s3
  ae:	855a                	mv	a0,s6
  b0:	7d6000ef          	jal	ra,886 <printf>
  b4:	bf75                	j	70 <main+0x70>
               iter, info.priority, info.time_slices);
      }
    }
    
    struct procinfo final;
    if(getprocinfo(&final) == 0) {
  b6:	fb040513          	addi	a0,s0,-80
  ba:	440000ef          	jal	ra,4fa <getprocinfo>
  be:	c501                	beqz	a0,c6 <main+0xc6>
      printf("[CPU-BOUND] Final: Q%d (TimeSlices=%d)\n", 
             final.priority, final.time_slices);
    }
    exit(0);
  c0:	4501                	li	a0,0
  c2:	398000ef          	jal	ra,45a <exit>
      printf("[CPU-BOUND] Final: Q%d (TimeSlices=%d)\n", 
  c6:	fbc42603          	lw	a2,-68(s0)
  ca:	fb842583          	lw	a1,-72(s0)
  ce:	00001517          	auipc	a0,0x1
  d2:	a7250513          	addi	a0,a0,-1422 # b40 <malloc+0x200>
  d6:	7b0000ef          	jal	ra,886 <printf>
  da:	b7dd                	j	c0 <main+0xc0>
  }
  
  // Small delay to let CPU process start first
  pause(1);
  dc:	4505                	li	a0,1
  de:	40c000ef          	jal	ra,4ea <pause>
  
  // Fork I/O-bound process
  cpid2 = fork();
  e2:	370000ef          	jal	ra,452 <fork>
  e6:	892a                	mv	s2,a0
  if(cpid2 == 0) {
  e8:	e559                	bnez	a0,176 <main+0x176>
    printf("[I/O-BOUND] Starting brief work + frequent sleeps...\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	a7e50513          	addi	a0,a0,-1410 # b68 <malloc+0x228>
  f2:	794000ef          	jal	ra,886 <printf>
    
    // Do brief work then sleep - should stay high priority
    for(int iter = 0; iter < 25; iter++) {
      volatile int dummy = 0;
      for(long j = 0; j < 2000000; j++) {
  f6:	001e84b7          	lui	s1,0x1e8
  fa:	48048493          	addi	s1,s1,1152 # 1e8480 <base+0x1e7470>
      
      pause(1);  // Sleep - yields before quantum exhausted
      
      // Checkpoint every 5 iterations
      struct procinfo info;
      if(iter % 5 == 0 && getprocinfo(&info) == 0) {
  fe:	4a15                	li	s4,5
        printf("[I/O-BOUND] Iteration %d: Q%d (slices=%d)\n", 
 100:	00001a97          	auipc	s5,0x1
 104:	aa0a8a93          	addi	s5,s5,-1376 # ba0 <malloc+0x260>
    for(int iter = 0; iter < 25; iter++) {
 108:	49e5                	li	s3,25
 10a:	a021                	j	112 <main+0x112>
 10c:	2905                	addiw	s2,s2,1
 10e:	05390163          	beq	s2,s3,150 <main+0x150>
      volatile int dummy = 0;
 112:	fa042623          	sw	zero,-84(s0)
      for(long j = 0; j < 2000000; j++) {
 116:	4781                	li	a5,0
        dummy = dummy + j;
 118:	fac42703          	lw	a4,-84(s0)
 11c:	9f3d                	addw	a4,a4,a5
 11e:	fae42623          	sw	a4,-84(s0)
      for(long j = 0; j < 2000000; j++) {
 122:	0785                	addi	a5,a5,1
 124:	fe979ae3          	bne	a5,s1,118 <main+0x118>
      pause(1);  // Sleep - yields before quantum exhausted
 128:	4505                	li	a0,1
 12a:	3c0000ef          	jal	ra,4ea <pause>
      if(iter % 5 == 0 && getprocinfo(&info) == 0) {
 12e:	034967bb          	remw	a5,s2,s4
 132:	ffe9                	bnez	a5,10c <main+0x10c>
 134:	fb040513          	addi	a0,s0,-80
 138:	3c2000ef          	jal	ra,4fa <getprocinfo>
 13c:	f961                	bnez	a0,10c <main+0x10c>
        printf("[I/O-BOUND] Iteration %d: Q%d (slices=%d)\n", 
 13e:	fbc42683          	lw	a3,-68(s0)
 142:	fb842603          	lw	a2,-72(s0)
 146:	85ca                	mv	a1,s2
 148:	8556                	mv	a0,s5
 14a:	73c000ef          	jal	ra,886 <printf>
 14e:	bf7d                	j	10c <main+0x10c>
               iter, info.priority, info.time_slices);
      }
    }
    
    struct procinfo final;
    if(getprocinfo(&final) == 0) {
 150:	fb040513          	addi	a0,s0,-80
 154:	3a6000ef          	jal	ra,4fa <getprocinfo>
 158:	c501                	beqz	a0,160 <main+0x160>
      printf("[I/O-BOUND] Final: Q%d (TimeSlices=%d)\n", 
             final.priority, final.time_slices);
    }
    exit(0);
 15a:	4501                	li	a0,0
 15c:	2fe000ef          	jal	ra,45a <exit>
      printf("[I/O-BOUND] Final: Q%d (TimeSlices=%d)\n", 
 160:	fbc42603          	lw	a2,-68(s0)
 164:	fb842583          	lw	a1,-72(s0)
 168:	00001517          	auipc	a0,0x1
 16c:	a6850513          	addi	a0,a0,-1432 # bd0 <malloc+0x290>
 170:	716000ef          	jal	ra,886 <printf>
 174:	b7dd                	j	15a <main+0x15a>
  }
  
  // Parent waits for both children
  wait(0);
 176:	4501                	li	a0,0
 178:	2ea000ef          	jal	ra,462 <wait>
  wait(0);
 17c:	4501                	li	a0,0
 17e:	2e4000ef          	jal	ra,462 <wait>
  
  printf("\n=== Test Complete ===\n");
 182:	00001517          	auipc	a0,0x1
 186:	a7650513          	addi	a0,a0,-1418 # bf8 <malloc+0x2b8>
 18a:	6fc000ef          	jal	ra,886 <printf>
  printf("Expected Behavior:\n");
 18e:	00001517          	auipc	a0,0x1
 192:	a8250513          	addi	a0,a0,-1406 # c10 <malloc+0x2d0>
 196:	6f0000ef          	jal	ra,886 <printf>
  printf("  CPU-bound:  Demoted to Q2 or Q3 (lower priority)\n");
 19a:	00001517          	auipc	a0,0x1
 19e:	a8e50513          	addi	a0,a0,-1394 # c28 <malloc+0x2e8>
 1a2:	6e4000ef          	jal	ra,886 <printf>
  printf("  I/O-bound:  Stayed in Q0 or Q1 (higher priority)\n");
 1a6:	00001517          	auipc	a0,0x1
 1aa:	aba50513          	addi	a0,a0,-1350 # c60 <malloc+0x320>
 1ae:	6d8000ef          	jal	ra,886 <printf>
  printf("  Result:     I/O-bound process got preference despite CPU competition\n");
 1b2:	00001517          	auipc	a0,0x1
 1b6:	ae650513          	addi	a0,a0,-1306 # c98 <malloc+0x358>
 1ba:	6cc000ef          	jal	ra,886 <printf>
  
  exit(0);
 1be:	4501                	li	a0,0
 1c0:	29a000ef          	jal	ra,45a <exit>

00000000000001c4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e406                	sd	ra,8(sp)
 1c8:	e022                	sd	s0,0(sp)
 1ca:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1cc:	e35ff0ef          	jal	ra,0 <main>
  exit(r);
 1d0:	28a000ef          	jal	ra,45a <exit>

00000000000001d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1da:	87aa                	mv	a5,a0
 1dc:	0585                	addi	a1,a1,1
 1de:	0785                	addi	a5,a5,1
 1e0:	fff5c703          	lbu	a4,-1(a1)
 1e4:	fee78fa3          	sb	a4,-1(a5)
 1e8:	fb75                	bnez	a4,1dc <strcpy+0x8>
    ;
  return os;
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret

00000000000001f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f6:	00054783          	lbu	a5,0(a0)
 1fa:	cb91                	beqz	a5,20e <strcmp+0x1e>
 1fc:	0005c703          	lbu	a4,0(a1)
 200:	00f71763          	bne	a4,a5,20e <strcmp+0x1e>
    p++, q++;
 204:	0505                	addi	a0,a0,1
 206:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 208:	00054783          	lbu	a5,0(a0)
 20c:	fbe5                	bnez	a5,1fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 20e:	0005c503          	lbu	a0,0(a1)
}
 212:	40a7853b          	subw	a0,a5,a0
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret

000000000000021c <strlen>:

uint
strlen(const char *s)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 222:	00054783          	lbu	a5,0(a0)
 226:	cf91                	beqz	a5,242 <strlen+0x26>
 228:	0505                	addi	a0,a0,1
 22a:	87aa                	mv	a5,a0
 22c:	4685                	li	a3,1
 22e:	9e89                	subw	a3,a3,a0
 230:	00f6853b          	addw	a0,a3,a5
 234:	0785                	addi	a5,a5,1
 236:	fff7c703          	lbu	a4,-1(a5)
 23a:	fb7d                	bnez	a4,230 <strlen+0x14>
    ;
  return n;
}
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret
  for(n = 0; s[n]; n++)
 242:	4501                	li	a0,0
 244:	bfe5                	j	23c <strlen+0x20>

0000000000000246 <memset>:

void*
memset(void *dst, int c, uint n)
{
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 24c:	ca19                	beqz	a2,262 <memset+0x1c>
 24e:	87aa                	mv	a5,a0
 250:	1602                	slli	a2,a2,0x20
 252:	9201                	srli	a2,a2,0x20
 254:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 258:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 25c:	0785                	addi	a5,a5,1
 25e:	fee79de3          	bne	a5,a4,258 <memset+0x12>
  }
  return dst;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret

0000000000000268 <strchr>:

char*
strchr(const char *s, char c)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e422                	sd	s0,8(sp)
 26c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 26e:	00054783          	lbu	a5,0(a0)
 272:	cb99                	beqz	a5,288 <strchr+0x20>
    if(*s == c)
 274:	00f58763          	beq	a1,a5,282 <strchr+0x1a>
  for(; *s; s++)
 278:	0505                	addi	a0,a0,1
 27a:	00054783          	lbu	a5,0(a0)
 27e:	fbfd                	bnez	a5,274 <strchr+0xc>
      return (char*)s;
  return 0;
 280:	4501                	li	a0,0
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
  return 0;
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <strchr+0x1a>

000000000000028c <gets>:

char*
gets(char *buf, int max)
{
 28c:	711d                	addi	sp,sp,-96
 28e:	ec86                	sd	ra,88(sp)
 290:	e8a2                	sd	s0,80(sp)
 292:	e4a6                	sd	s1,72(sp)
 294:	e0ca                	sd	s2,64(sp)
 296:	fc4e                	sd	s3,56(sp)
 298:	f852                	sd	s4,48(sp)
 29a:	f456                	sd	s5,40(sp)
 29c:	f05a                	sd	s6,32(sp)
 29e:	ec5e                	sd	s7,24(sp)
 2a0:	1080                	addi	s0,sp,96
 2a2:	8baa                	mv	s7,a0
 2a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a6:	892a                	mv	s2,a0
 2a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2aa:	4aa9                	li	s5,10
 2ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ae:	89a6                	mv	s3,s1
 2b0:	2485                	addiw	s1,s1,1
 2b2:	0344d663          	bge	s1,s4,2de <gets+0x52>
    cc = read(0, &c, 1);
 2b6:	4605                	li	a2,1
 2b8:	faf40593          	addi	a1,s0,-81
 2bc:	4501                	li	a0,0
 2be:	1b4000ef          	jal	ra,472 <read>
    if(cc < 1)
 2c2:	00a05e63          	blez	a0,2de <gets+0x52>
    buf[i++] = c;
 2c6:	faf44783          	lbu	a5,-81(s0)
 2ca:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 2ce:	01578763          	beq	a5,s5,2dc <gets+0x50>
 2d2:	0905                	addi	s2,s2,1
 2d4:	fd679de3          	bne	a5,s6,2ae <gets+0x22>
  for(i=0; i+1 < max; ){
 2d8:	89a6                	mv	s3,s1
 2da:	a011                	j	2de <gets+0x52>
 2dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2de:	99de                	add	s3,s3,s7
 2e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2e4:	855e                	mv	a0,s7
 2e6:	60e6                	ld	ra,88(sp)
 2e8:	6446                	ld	s0,80(sp)
 2ea:	64a6                	ld	s1,72(sp)
 2ec:	6906                	ld	s2,64(sp)
 2ee:	79e2                	ld	s3,56(sp)
 2f0:	7a42                	ld	s4,48(sp)
 2f2:	7aa2                	ld	s5,40(sp)
 2f4:	7b02                	ld	s6,32(sp)
 2f6:	6be2                	ld	s7,24(sp)
 2f8:	6125                	addi	sp,sp,96
 2fa:	8082                	ret

00000000000002fc <stat>:

int
stat(const char *n, struct stat *st)
{
 2fc:	1101                	addi	sp,sp,-32
 2fe:	ec06                	sd	ra,24(sp)
 300:	e822                	sd	s0,16(sp)
 302:	e426                	sd	s1,8(sp)
 304:	e04a                	sd	s2,0(sp)
 306:	1000                	addi	s0,sp,32
 308:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30a:	4581                	li	a1,0
 30c:	18e000ef          	jal	ra,49a <open>
  if(fd < 0)
 310:	02054163          	bltz	a0,332 <stat+0x36>
 314:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 316:	85ca                	mv	a1,s2
 318:	19a000ef          	jal	ra,4b2 <fstat>
 31c:	892a                	mv	s2,a0
  close(fd);
 31e:	8526                	mv	a0,s1
 320:	162000ef          	jal	ra,482 <close>
  return r;
}
 324:	854a                	mv	a0,s2
 326:	60e2                	ld	ra,24(sp)
 328:	6442                	ld	s0,16(sp)
 32a:	64a2                	ld	s1,8(sp)
 32c:	6902                	ld	s2,0(sp)
 32e:	6105                	addi	sp,sp,32
 330:	8082                	ret
    return -1;
 332:	597d                	li	s2,-1
 334:	bfc5                	j	324 <stat+0x28>

0000000000000336 <atoi>:

int
atoi(const char *s)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 33c:	00054603          	lbu	a2,0(a0)
 340:	fd06079b          	addiw	a5,a2,-48
 344:	0ff7f793          	andi	a5,a5,255
 348:	4725                	li	a4,9
 34a:	02f76963          	bltu	a4,a5,37c <atoi+0x46>
 34e:	86aa                	mv	a3,a0
  n = 0;
 350:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 352:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 354:	0685                	addi	a3,a3,1
 356:	0025179b          	slliw	a5,a0,0x2
 35a:	9fa9                	addw	a5,a5,a0
 35c:	0017979b          	slliw	a5,a5,0x1
 360:	9fb1                	addw	a5,a5,a2
 362:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 366:	0006c603          	lbu	a2,0(a3)
 36a:	fd06071b          	addiw	a4,a2,-48
 36e:	0ff77713          	andi	a4,a4,255
 372:	fee5f1e3          	bgeu	a1,a4,354 <atoi+0x1e>
  return n;
}
 376:	6422                	ld	s0,8(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret
  n = 0;
 37c:	4501                	li	a0,0
 37e:	bfe5                	j	376 <atoi+0x40>

0000000000000380 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 386:	02b57463          	bgeu	a0,a1,3ae <memmove+0x2e>
    while(n-- > 0)
 38a:	00c05f63          	blez	a2,3a8 <memmove+0x28>
 38e:	1602                	slli	a2,a2,0x20
 390:	9201                	srli	a2,a2,0x20
 392:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 396:	872a                	mv	a4,a0
      *dst++ = *src++;
 398:	0585                	addi	a1,a1,1
 39a:	0705                	addi	a4,a4,1
 39c:	fff5c683          	lbu	a3,-1(a1)
 3a0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a4:	fee79ae3          	bne	a5,a4,398 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
    dst += n;
 3ae:	00c50733          	add	a4,a0,a2
    src += n;
 3b2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3b4:	fec05ae3          	blez	a2,3a8 <memmove+0x28>
 3b8:	fff6079b          	addiw	a5,a2,-1
 3bc:	1782                	slli	a5,a5,0x20
 3be:	9381                	srli	a5,a5,0x20
 3c0:	fff7c793          	not	a5,a5
 3c4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c6:	15fd                	addi	a1,a1,-1
 3c8:	177d                	addi	a4,a4,-1
 3ca:	0005c683          	lbu	a3,0(a1)
 3ce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d2:	fee79ae3          	bne	a5,a4,3c6 <memmove+0x46>
 3d6:	bfc9                	j	3a8 <memmove+0x28>

00000000000003d8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3de:	ca05                	beqz	a2,40e <memcmp+0x36>
 3e0:	fff6069b          	addiw	a3,a2,-1
 3e4:	1682                	slli	a3,a3,0x20
 3e6:	9281                	srli	a3,a3,0x20
 3e8:	0685                	addi	a3,a3,1
 3ea:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ec:	00054783          	lbu	a5,0(a0)
 3f0:	0005c703          	lbu	a4,0(a1)
 3f4:	00e79863          	bne	a5,a4,404 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3f8:	0505                	addi	a0,a0,1
    p2++;
 3fa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3fc:	fed518e3          	bne	a0,a3,3ec <memcmp+0x14>
  }
  return 0;
 400:	4501                	li	a0,0
 402:	a019                	j	408 <memcmp+0x30>
      return *p1 - *p2;
 404:	40e7853b          	subw	a0,a5,a4
}
 408:	6422                	ld	s0,8(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
  return 0;
 40e:	4501                	li	a0,0
 410:	bfe5                	j	408 <memcmp+0x30>

0000000000000412 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e406                	sd	ra,8(sp)
 416:	e022                	sd	s0,0(sp)
 418:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 41a:	f67ff0ef          	jal	ra,380 <memmove>
}
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret

0000000000000426 <sbrk>:

char *
sbrk(int n) {
 426:	1141                	addi	sp,sp,-16
 428:	e406                	sd	ra,8(sp)
 42a:	e022                	sd	s0,0(sp)
 42c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 42e:	4585                	li	a1,1
 430:	0b2000ef          	jal	ra,4e2 <sys_sbrk>
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <sbrklazy>:

char *
sbrklazy(int n) {
 43c:	1141                	addi	sp,sp,-16
 43e:	e406                	sd	ra,8(sp)
 440:	e022                	sd	s0,0(sp)
 442:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 444:	4589                	li	a1,2
 446:	09c000ef          	jal	ra,4e2 <sys_sbrk>
}
 44a:	60a2                	ld	ra,8(sp)
 44c:	6402                	ld	s0,0(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 452:	4885                	li	a7,1
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <exit>:
.global exit
exit:
 li a7, SYS_exit
 45a:	4889                	li	a7,2
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <wait>:
.global wait
wait:
 li a7, SYS_wait
 462:	488d                	li	a7,3
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 46a:	4891                	li	a7,4
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <read>:
.global read
read:
 li a7, SYS_read
 472:	4895                	li	a7,5
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <write>:
.global write
write:
 li a7, SYS_write
 47a:	48c1                	li	a7,16
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <close>:
.global close
close:
 li a7, SYS_close
 482:	48d5                	li	a7,21
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <kill>:
.global kill
kill:
 li a7, SYS_kill
 48a:	4899                	li	a7,6
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <exec>:
.global exec
exec:
 li a7, SYS_exec
 492:	489d                	li	a7,7
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <open>:
.global open
open:
 li a7, SYS_open
 49a:	48bd                	li	a7,15
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a2:	48c5                	li	a7,17
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4aa:	48c9                	li	a7,18
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b2:	48a1                	li	a7,8
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <link>:
.global link
link:
 li a7, SYS_link
 4ba:	48cd                	li	a7,19
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c2:	48d1                	li	a7,20
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ca:	48a5                	li	a7,9
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d2:	48a9                	li	a7,10
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4da:	48ad                	li	a7,11
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4e2:	48b1                	li	a7,12
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <pause>:
.global pause
pause:
 li a7, SYS_pause
 4ea:	48b5                	li	a7,13
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f2:	48b9                	li	a7,14
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4fa:	48d9                	li	a7,22
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 502:	48dd                	li	a7,23
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 50a:	1101                	addi	sp,sp,-32
 50c:	ec06                	sd	ra,24(sp)
 50e:	e822                	sd	s0,16(sp)
 510:	1000                	addi	s0,sp,32
 512:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 516:	4605                	li	a2,1
 518:	fef40593          	addi	a1,s0,-17
 51c:	f5fff0ef          	jal	ra,47a <write>
}
 520:	60e2                	ld	ra,24(sp)
 522:	6442                	ld	s0,16(sp)
 524:	6105                	addi	sp,sp,32
 526:	8082                	ret

0000000000000528 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 528:	715d                	addi	sp,sp,-80
 52a:	e486                	sd	ra,72(sp)
 52c:	e0a2                	sd	s0,64(sp)
 52e:	fc26                	sd	s1,56(sp)
 530:	f84a                	sd	s2,48(sp)
 532:	f44e                	sd	s3,40(sp)
 534:	0880                	addi	s0,sp,80
 536:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 538:	c299                	beqz	a3,53e <printint+0x16>
 53a:	0805c163          	bltz	a1,5bc <printint+0x94>
  neg = 0;
 53e:	4881                	li	a7,0
 540:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 544:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 546:	00000517          	auipc	a0,0x0
 54a:	7a250513          	addi	a0,a0,1954 # ce8 <digits>
 54e:	883e                	mv	a6,a5
 550:	2785                	addiw	a5,a5,1
 552:	02c5f733          	remu	a4,a1,a2
 556:	972a                	add	a4,a4,a0
 558:	00074703          	lbu	a4,0(a4)
 55c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 560:	872e                	mv	a4,a1
 562:	02c5d5b3          	divu	a1,a1,a2
 566:	0685                	addi	a3,a3,1
 568:	fec773e3          	bgeu	a4,a2,54e <printint+0x26>
  if(neg)
 56c:	00088b63          	beqz	a7,582 <printint+0x5a>
    buf[i++] = '-';
 570:	fd040713          	addi	a4,s0,-48
 574:	97ba                	add	a5,a5,a4
 576:	02d00713          	li	a4,45
 57a:	fee78423          	sb	a4,-24(a5)
 57e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 582:	02f05663          	blez	a5,5ae <printint+0x86>
 586:	fb840713          	addi	a4,s0,-72
 58a:	00f704b3          	add	s1,a4,a5
 58e:	fff70993          	addi	s3,a4,-1
 592:	99be                	add	s3,s3,a5
 594:	37fd                	addiw	a5,a5,-1
 596:	1782                	slli	a5,a5,0x20
 598:	9381                	srli	a5,a5,0x20
 59a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 59e:	fff4c583          	lbu	a1,-1(s1)
 5a2:	854a                	mv	a0,s2
 5a4:	f67ff0ef          	jal	ra,50a <putc>
  while(--i >= 0)
 5a8:	14fd                	addi	s1,s1,-1
 5aa:	ff349ae3          	bne	s1,s3,59e <printint+0x76>
}
 5ae:	60a6                	ld	ra,72(sp)
 5b0:	6406                	ld	s0,64(sp)
 5b2:	74e2                	ld	s1,56(sp)
 5b4:	7942                	ld	s2,48(sp)
 5b6:	79a2                	ld	s3,40(sp)
 5b8:	6161                	addi	sp,sp,80
 5ba:	8082                	ret
    x = -xx;
 5bc:	40b005b3          	neg	a1,a1
    neg = 1;
 5c0:	4885                	li	a7,1
    x = -xx;
 5c2:	bfbd                	j	540 <printint+0x18>

00000000000005c4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c4:	7119                	addi	sp,sp,-128
 5c6:	fc86                	sd	ra,120(sp)
 5c8:	f8a2                	sd	s0,112(sp)
 5ca:	f4a6                	sd	s1,104(sp)
 5cc:	f0ca                	sd	s2,96(sp)
 5ce:	ecce                	sd	s3,88(sp)
 5d0:	e8d2                	sd	s4,80(sp)
 5d2:	e4d6                	sd	s5,72(sp)
 5d4:	e0da                	sd	s6,64(sp)
 5d6:	fc5e                	sd	s7,56(sp)
 5d8:	f862                	sd	s8,48(sp)
 5da:	f466                	sd	s9,40(sp)
 5dc:	f06a                	sd	s10,32(sp)
 5de:	ec6e                	sd	s11,24(sp)
 5e0:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e2:	0005c903          	lbu	s2,0(a1)
 5e6:	24090c63          	beqz	s2,83e <vprintf+0x27a>
 5ea:	8b2a                	mv	s6,a0
 5ec:	8a2e                	mv	s4,a1
 5ee:	8bb2                	mv	s7,a2
  state = 0;
 5f0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5f2:	4481                	li	s1,0
 5f4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5f6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5fa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5fe:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 602:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 606:	00000c97          	auipc	s9,0x0
 60a:	6e2c8c93          	addi	s9,s9,1762 # ce8 <digits>
 60e:	a005                	j	62e <vprintf+0x6a>
        putc(fd, c0);
 610:	85ca                	mv	a1,s2
 612:	855a                	mv	a0,s6
 614:	ef7ff0ef          	jal	ra,50a <putc>
 618:	a019                	j	61e <vprintf+0x5a>
    } else if(state == '%'){
 61a:	03598263          	beq	s3,s5,63e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 61e:	2485                	addiw	s1,s1,1
 620:	8726                	mv	a4,s1
 622:	009a07b3          	add	a5,s4,s1
 626:	0007c903          	lbu	s2,0(a5)
 62a:	20090a63          	beqz	s2,83e <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 62e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 632:	fe0994e3          	bnez	s3,61a <vprintf+0x56>
      if(c0 == '%'){
 636:	fd579de3          	bne	a5,s5,610 <vprintf+0x4c>
        state = '%';
 63a:	89be                	mv	s3,a5
 63c:	b7cd                	j	61e <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 63e:	c3c1                	beqz	a5,6be <vprintf+0xfa>
 640:	00ea06b3          	add	a3,s4,a4
 644:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 648:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 64a:	c681                	beqz	a3,652 <vprintf+0x8e>
 64c:	9752                	add	a4,a4,s4
 64e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 652:	03878e63          	beq	a5,s8,68e <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 656:	05a78863          	beq	a5,s10,6a6 <vprintf+0xe2>
      } else if(c0 == 'u'){
 65a:	0db78b63          	beq	a5,s11,730 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 65e:	07800713          	li	a4,120
 662:	10e78d63          	beq	a5,a4,77c <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 666:	07000713          	li	a4,112
 66a:	14e78263          	beq	a5,a4,7ae <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 66e:	06300713          	li	a4,99
 672:	16e78f63          	beq	a5,a4,7f0 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 676:	07300713          	li	a4,115
 67a:	18e78563          	beq	a5,a4,804 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 67e:	05579063          	bne	a5,s5,6be <vprintf+0xfa>
        putc(fd, '%');
 682:	85d6                	mv	a1,s5
 684:	855a                	mv	a0,s6
 686:	e85ff0ef          	jal	ra,50a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 68a:	4981                	li	s3,0
 68c:	bf49                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 68e:	008b8913          	addi	s2,s7,8
 692:	4685                	li	a3,1
 694:	4629                	li	a2,10
 696:	000ba583          	lw	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	e8dff0ef          	jal	ra,528 <printint>
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bfad                	j	61e <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 6a6:	03868663          	beq	a3,s8,6d2 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6aa:	05a68163          	beq	a3,s10,6ec <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 6ae:	09b68d63          	beq	a3,s11,748 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6b2:	03a68f63          	beq	a3,s10,6f0 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 6b6:	07800793          	li	a5,120
 6ba:	0cf68d63          	beq	a3,a5,794 <vprintf+0x1d0>
        putc(fd, '%');
 6be:	85d6                	mv	a1,s5
 6c0:	855a                	mv	a0,s6
 6c2:	e49ff0ef          	jal	ra,50a <putc>
        putc(fd, c0);
 6c6:	85ca                	mv	a1,s2
 6c8:	855a                	mv	a0,s6
 6ca:	e41ff0ef          	jal	ra,50a <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b7b9                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	4685                	li	a3,1
 6d8:	4629                	li	a2,10
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	e49ff0ef          	jal	ra,528 <printint>
        i += 1;
 6e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
        i += 1;
 6ea:	bf15                	j	61e <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ec:	03860563          	beq	a2,s8,716 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6f0:	07b60963          	beq	a2,s11,762 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6f4:	07800793          	li	a5,120
 6f8:	fcf613e3          	bne	a2,a5,6be <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fc:	008b8913          	addi	s2,s7,8
 700:	4681                	li	a3,0
 702:	4641                	li	a2,16
 704:	000bb583          	ld	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	e1fff0ef          	jal	ra,528 <printint>
        i += 2;
 70e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
        i += 2;
 714:	b729                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 716:	008b8913          	addi	s2,s7,8
 71a:	4685                	li	a3,1
 71c:	4629                	li	a2,10
 71e:	000bb583          	ld	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	e05ff0ef          	jal	ra,528 <printint>
        i += 2;
 728:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 72a:	8bca                	mv	s7,s2
      state = 0;
 72c:	4981                	li	s3,0
        i += 2;
 72e:	bdc5                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 730:	008b8913          	addi	s2,s7,8
 734:	4681                	li	a3,0
 736:	4629                	li	a2,10
 738:	000be583          	lwu	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	debff0ef          	jal	ra,528 <printint>
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
 746:	bde1                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 748:	008b8913          	addi	s2,s7,8
 74c:	4681                	li	a3,0
 74e:	4629                	li	a2,10
 750:	000bb583          	ld	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	dd3ff0ef          	jal	ra,528 <printint>
        i += 1;
 75a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 75c:	8bca                	mv	s7,s2
      state = 0;
 75e:	4981                	li	s3,0
        i += 1;
 760:	bd7d                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 762:	008b8913          	addi	s2,s7,8
 766:	4681                	li	a3,0
 768:	4629                	li	a2,10
 76a:	000bb583          	ld	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	db9ff0ef          	jal	ra,528 <printint>
        i += 2;
 774:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 776:	8bca                	mv	s7,s2
      state = 0;
 778:	4981                	li	s3,0
        i += 2;
 77a:	b555                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 77c:	008b8913          	addi	s2,s7,8
 780:	4681                	li	a3,0
 782:	4641                	li	a2,16
 784:	000be583          	lwu	a1,0(s7)
 788:	855a                	mv	a0,s6
 78a:	d9fff0ef          	jal	ra,528 <printint>
 78e:	8bca                	mv	s7,s2
      state = 0;
 790:	4981                	li	s3,0
 792:	b571                	j	61e <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 794:	008b8913          	addi	s2,s7,8
 798:	4681                	li	a3,0
 79a:	4641                	li	a2,16
 79c:	000bb583          	ld	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	d87ff0ef          	jal	ra,528 <printint>
        i += 1;
 7a6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a8:	8bca                	mv	s7,s2
      state = 0;
 7aa:	4981                	li	s3,0
        i += 1;
 7ac:	bd8d                	j	61e <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 7ae:	008b8793          	addi	a5,s7,8
 7b2:	f8f43423          	sd	a5,-120(s0)
 7b6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7ba:	03000593          	li	a1,48
 7be:	855a                	mv	a0,s6
 7c0:	d4bff0ef          	jal	ra,50a <putc>
  putc(fd, 'x');
 7c4:	07800593          	li	a1,120
 7c8:	855a                	mv	a0,s6
 7ca:	d41ff0ef          	jal	ra,50a <putc>
 7ce:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d0:	03c9d793          	srli	a5,s3,0x3c
 7d4:	97e6                	add	a5,a5,s9
 7d6:	0007c583          	lbu	a1,0(a5)
 7da:	855a                	mv	a0,s6
 7dc:	d2fff0ef          	jal	ra,50a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7e0:	0992                	slli	s3,s3,0x4
 7e2:	397d                	addiw	s2,s2,-1
 7e4:	fe0916e3          	bnez	s2,7d0 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7e8:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	bd05                	j	61e <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7f0:	008b8913          	addi	s2,s7,8
 7f4:	000bc583          	lbu	a1,0(s7)
 7f8:	855a                	mv	a0,s6
 7fa:	d11ff0ef          	jal	ra,50a <putc>
 7fe:	8bca                	mv	s7,s2
      state = 0;
 800:	4981                	li	s3,0
 802:	bd31                	j	61e <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 804:	008b8993          	addi	s3,s7,8
 808:	000bb903          	ld	s2,0(s7)
 80c:	00090f63          	beqz	s2,82a <vprintf+0x266>
        for(; *s; s++)
 810:	00094583          	lbu	a1,0(s2)
 814:	c195                	beqz	a1,838 <vprintf+0x274>
          putc(fd, *s);
 816:	855a                	mv	a0,s6
 818:	cf3ff0ef          	jal	ra,50a <putc>
        for(; *s; s++)
 81c:	0905                	addi	s2,s2,1
 81e:	00094583          	lbu	a1,0(s2)
 822:	f9f5                	bnez	a1,816 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 824:	8bce                	mv	s7,s3
      state = 0;
 826:	4981                	li	s3,0
 828:	bbdd                	j	61e <vprintf+0x5a>
          s = "(null)";
 82a:	00000917          	auipc	s2,0x0
 82e:	4b690913          	addi	s2,s2,1206 # ce0 <malloc+0x3a0>
        for(; *s; s++)
 832:	02800593          	li	a1,40
 836:	b7c5                	j	816 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 838:	8bce                	mv	s7,s3
      state = 0;
 83a:	4981                	li	s3,0
 83c:	b3cd                	j	61e <vprintf+0x5a>
    }
  }
}
 83e:	70e6                	ld	ra,120(sp)
 840:	7446                	ld	s0,112(sp)
 842:	74a6                	ld	s1,104(sp)
 844:	7906                	ld	s2,96(sp)
 846:	69e6                	ld	s3,88(sp)
 848:	6a46                	ld	s4,80(sp)
 84a:	6aa6                	ld	s5,72(sp)
 84c:	6b06                	ld	s6,64(sp)
 84e:	7be2                	ld	s7,56(sp)
 850:	7c42                	ld	s8,48(sp)
 852:	7ca2                	ld	s9,40(sp)
 854:	7d02                	ld	s10,32(sp)
 856:	6de2                	ld	s11,24(sp)
 858:	6109                	addi	sp,sp,128
 85a:	8082                	ret

000000000000085c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 85c:	715d                	addi	sp,sp,-80
 85e:	ec06                	sd	ra,24(sp)
 860:	e822                	sd	s0,16(sp)
 862:	1000                	addi	s0,sp,32
 864:	e010                	sd	a2,0(s0)
 866:	e414                	sd	a3,8(s0)
 868:	e818                	sd	a4,16(s0)
 86a:	ec1c                	sd	a5,24(s0)
 86c:	03043023          	sd	a6,32(s0)
 870:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 874:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 878:	8622                	mv	a2,s0
 87a:	d4bff0ef          	jal	ra,5c4 <vprintf>
}
 87e:	60e2                	ld	ra,24(sp)
 880:	6442                	ld	s0,16(sp)
 882:	6161                	addi	sp,sp,80
 884:	8082                	ret

0000000000000886 <printf>:

void
printf(const char *fmt, ...)
{
 886:	711d                	addi	sp,sp,-96
 888:	ec06                	sd	ra,24(sp)
 88a:	e822                	sd	s0,16(sp)
 88c:	1000                	addi	s0,sp,32
 88e:	e40c                	sd	a1,8(s0)
 890:	e810                	sd	a2,16(s0)
 892:	ec14                	sd	a3,24(s0)
 894:	f018                	sd	a4,32(s0)
 896:	f41c                	sd	a5,40(s0)
 898:	03043823          	sd	a6,48(s0)
 89c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8a0:	00840613          	addi	a2,s0,8
 8a4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8a8:	85aa                	mv	a1,a0
 8aa:	4505                	li	a0,1
 8ac:	d19ff0ef          	jal	ra,5c4 <vprintf>
}
 8b0:	60e2                	ld	ra,24(sp)
 8b2:	6442                	ld	s0,16(sp)
 8b4:	6125                	addi	sp,sp,96
 8b6:	8082                	ret

00000000000008b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8b8:	1141                	addi	sp,sp,-16
 8ba:	e422                	sd	s0,8(sp)
 8bc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8be:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c2:	00000797          	auipc	a5,0x0
 8c6:	73e7b783          	ld	a5,1854(a5) # 1000 <freep>
 8ca:	a805                	j	8fa <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8cc:	4618                	lw	a4,8(a2)
 8ce:	9db9                	addw	a1,a1,a4
 8d0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d4:	6398                	ld	a4,0(a5)
 8d6:	6318                	ld	a4,0(a4)
 8d8:	fee53823          	sd	a4,-16(a0)
 8dc:	a091                	j	920 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8de:	ff852703          	lw	a4,-8(a0)
 8e2:	9e39                	addw	a2,a2,a4
 8e4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8e6:	ff053703          	ld	a4,-16(a0)
 8ea:	e398                	sd	a4,0(a5)
 8ec:	a099                	j	932 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ee:	6398                	ld	a4,0(a5)
 8f0:	00e7e463          	bltu	a5,a4,8f8 <free+0x40>
 8f4:	00e6ea63          	bltu	a3,a4,908 <free+0x50>
{
 8f8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fa:	fed7fae3          	bgeu	a5,a3,8ee <free+0x36>
 8fe:	6398                	ld	a4,0(a5)
 900:	00e6e463          	bltu	a3,a4,908 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 904:	fee7eae3          	bltu	a5,a4,8f8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 908:	ff852583          	lw	a1,-8(a0)
 90c:	6390                	ld	a2,0(a5)
 90e:	02059713          	slli	a4,a1,0x20
 912:	9301                	srli	a4,a4,0x20
 914:	0712                	slli	a4,a4,0x4
 916:	9736                	add	a4,a4,a3
 918:	fae60ae3          	beq	a2,a4,8cc <free+0x14>
    bp->s.ptr = p->s.ptr;
 91c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 920:	4790                	lw	a2,8(a5)
 922:	02061713          	slli	a4,a2,0x20
 926:	9301                	srli	a4,a4,0x20
 928:	0712                	slli	a4,a4,0x4
 92a:	973e                	add	a4,a4,a5
 92c:	fae689e3          	beq	a3,a4,8de <free+0x26>
  } else
    p->s.ptr = bp;
 930:	e394                	sd	a3,0(a5)
  freep = p;
 932:	00000717          	auipc	a4,0x0
 936:	6cf73723          	sd	a5,1742(a4) # 1000 <freep>
}
 93a:	6422                	ld	s0,8(sp)
 93c:	0141                	addi	sp,sp,16
 93e:	8082                	ret

0000000000000940 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 940:	7139                	addi	sp,sp,-64
 942:	fc06                	sd	ra,56(sp)
 944:	f822                	sd	s0,48(sp)
 946:	f426                	sd	s1,40(sp)
 948:	f04a                	sd	s2,32(sp)
 94a:	ec4e                	sd	s3,24(sp)
 94c:	e852                	sd	s4,16(sp)
 94e:	e456                	sd	s5,8(sp)
 950:	e05a                	sd	s6,0(sp)
 952:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 954:	02051493          	slli	s1,a0,0x20
 958:	9081                	srli	s1,s1,0x20
 95a:	04bd                	addi	s1,s1,15
 95c:	8091                	srli	s1,s1,0x4
 95e:	0014899b          	addiw	s3,s1,1
 962:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 964:	00000517          	auipc	a0,0x0
 968:	69c53503          	ld	a0,1692(a0) # 1000 <freep>
 96c:	c515                	beqz	a0,998 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 970:	4798                	lw	a4,8(a5)
 972:	02977f63          	bgeu	a4,s1,9b0 <malloc+0x70>
 976:	8a4e                	mv	s4,s3
 978:	0009871b          	sext.w	a4,s3
 97c:	6685                	lui	a3,0x1
 97e:	00d77363          	bgeu	a4,a3,984 <malloc+0x44>
 982:	6a05                	lui	s4,0x1
 984:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 988:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 98c:	00000917          	auipc	s2,0x0
 990:	67490913          	addi	s2,s2,1652 # 1000 <freep>
  if(p == SBRK_ERROR)
 994:	5afd                	li	s5,-1
 996:	a0bd                	j	a04 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 998:	00000797          	auipc	a5,0x0
 99c:	67878793          	addi	a5,a5,1656 # 1010 <base>
 9a0:	00000717          	auipc	a4,0x0
 9a4:	66f73023          	sd	a5,1632(a4) # 1000 <freep>
 9a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9aa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ae:	b7e1                	j	976 <malloc+0x36>
      if(p->s.size == nunits)
 9b0:	02e48b63          	beq	s1,a4,9e6 <malloc+0xa6>
        p->s.size -= nunits;
 9b4:	4137073b          	subw	a4,a4,s3
 9b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ba:	1702                	slli	a4,a4,0x20
 9bc:	9301                	srli	a4,a4,0x20
 9be:	0712                	slli	a4,a4,0x4
 9c0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9c2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c6:	00000717          	auipc	a4,0x0
 9ca:	62a73d23          	sd	a0,1594(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ce:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9d2:	70e2                	ld	ra,56(sp)
 9d4:	7442                	ld	s0,48(sp)
 9d6:	74a2                	ld	s1,40(sp)
 9d8:	7902                	ld	s2,32(sp)
 9da:	69e2                	ld	s3,24(sp)
 9dc:	6a42                	ld	s4,16(sp)
 9de:	6aa2                	ld	s5,8(sp)
 9e0:	6b02                	ld	s6,0(sp)
 9e2:	6121                	addi	sp,sp,64
 9e4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9e6:	6398                	ld	a4,0(a5)
 9e8:	e118                	sd	a4,0(a0)
 9ea:	bff1                	j	9c6 <malloc+0x86>
  hp->s.size = nu;
 9ec:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9f0:	0541                	addi	a0,a0,16
 9f2:	ec7ff0ef          	jal	ra,8b8 <free>
  return freep;
 9f6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9fa:	dd61                	beqz	a0,9d2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9fe:	4798                	lw	a4,8(a5)
 a00:	fa9778e3          	bgeu	a4,s1,9b0 <malloc+0x70>
    if(p == freep)
 a04:	00093703          	ld	a4,0(s2)
 a08:	853e                	mv	a0,a5
 a0a:	fef719e3          	bne	a4,a5,9fc <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 a0e:	8552                	mv	a0,s4
 a10:	a17ff0ef          	jal	ra,426 <sbrk>
  if(p == SBRK_ERROR)
 a14:	fd551ce3          	bne	a0,s5,9ec <malloc+0xac>
        return 0;
 a18:	4501                	li	a0,0
 a1a:	bf65                	j	9d2 <malloc+0x92>
