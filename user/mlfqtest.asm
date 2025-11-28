
user/_mlfqtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Mixed workload test: CPU-bound vs I/O-bound side by side
// Demonstrates scheduler prioritizes I/O-bound over CPU-bound.
int
main(int argc, char *argv[])
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e0ca                	sd	s2,64(sp)
   8:	1080                	addi	s0,sp,96
  int cpid1, cpid2;
  
  printf("=== Comprehensive Mixed Workload Test ===\n");
   a:	00001517          	auipc	a0,0x1
   e:	a4650513          	addi	a0,a0,-1466 # a50 <malloc+0xf8>
  12:	093000ef          	jal	8a4 <printf>
  printf("Running CPU-bound and I/O-bound processes concurrently.\n");
  16:	00001517          	auipc	a0,0x1
  1a:	a6a50513          	addi	a0,a0,-1430 # a80 <malloc+0x128>
  1e:	087000ef          	jal	8a4 <printf>
  printf("This shows the scheduler's fairness: CPU-bound demotes, I/O-bound stays high.\n\n");
  22:	00001517          	auipc	a0,0x1
  26:	a9e50513          	addi	a0,a0,-1378 # ac0 <malloc+0x168>
  2a:	07b000ef          	jal	8a4 <printf>
  
  // Fork CPU-bound process
  cpid1 = fork();
  2e:	436000ef          	jal	464 <fork>
  if(cpid1 == 0) {
  32:	e54d                	bnez	a0,dc <main+0xdc>
  34:	e4a6                	sd	s1,72(sp)
  36:	fc4e                	sd	s3,56(sp)
  38:	f852                	sd	s4,48(sp)
  3a:	f456                	sd	s5,40(sp)
  3c:	f05a                	sd	s6,32(sp)
  3e:	89aa                	mv	s3,a0
    printf("[CPU-BOUND] Starting long computation...\n");
  40:	00001517          	auipc	a0,0x1
  44:	ad050513          	addi	a0,a0,-1328 # b10 <malloc+0x1b8>
  48:	05d000ef          	jal	8a4 <printf>
    volatile int dummy = 0;
  4c:	fa042623          	sw	zero,-84(s0)
    
    // Do lots of CPU work continuously - should demote significantly
    for(int iter = 0; iter < 40; iter++) {
      for(long j = 0; j < 10000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
  50:	000f4937          	lui	s2,0xf4
  54:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2230>
      for(long j = 0; j < 10000000; j++) {
  58:	009894b7          	lui	s1,0x989
  5c:	68048493          	addi	s1,s1,1664 # 989680 <base+0x987670>
      }
      
      // Checkpoint every 10 iterations
      struct procinfo info;
      if(iter % 10 == 0 && getprocinfo(&info) == 0) {
  60:	4aa9                	li	s5,10
        printf("[CPU-BOUND] Iteration %d: Q%d (slices=%d)\n", 
  62:	00001b17          	auipc	s6,0x1
  66:	adeb0b13          	addi	s6,s6,-1314 # b40 <malloc+0x1e8>
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
  9e:	46e000ef          	jal	50c <getprocinfo>
  a2:	f579                	bnez	a0,70 <main+0x70>
        printf("[CPU-BOUND] Iteration %d: Q%d (slices=%d)\n", 
  a4:	fbc42683          	lw	a3,-68(s0)
  a8:	fb842603          	lw	a2,-72(s0)
  ac:	85ce                	mv	a1,s3
  ae:	855a                	mv	a0,s6
  b0:	7f4000ef          	jal	8a4 <printf>
  b4:	bf75                	j	70 <main+0x70>
               iter, info.priority, info.time_slices);
      }
    }
    
    struct procinfo final;
    if(getprocinfo(&final) == 0) {
  b6:	fb040513          	addi	a0,s0,-80
  ba:	452000ef          	jal	50c <getprocinfo>
  be:	c501                	beqz	a0,c6 <main+0xc6>
      printf("[CPU-BOUND] Final: Q%d (TimeSlices=%d)\n", 
             final.priority, final.time_slices);
    }
    exit(0);
  c0:	4501                	li	a0,0
  c2:	3aa000ef          	jal	46c <exit>
      printf("[CPU-BOUND] Final: Q%d (TimeSlices=%d)\n", 
  c6:	fbc42603          	lw	a2,-68(s0)
  ca:	fb842583          	lw	a1,-72(s0)
  ce:	00001517          	auipc	a0,0x1
  d2:	aa250513          	addi	a0,a0,-1374 # b70 <malloc+0x218>
  d6:	7ce000ef          	jal	8a4 <printf>
  da:	b7dd                	j	c0 <main+0xc0>
  }
  
  // Small delay to let CPU process start first
  pause(1);
  dc:	4505                	li	a0,1
  de:	41e000ef          	jal	4fc <pause>
  
  // Fork I/O-bound process
  cpid2 = fork();
  e2:	382000ef          	jal	464 <fork>
  e6:	892a                	mv	s2,a0
  if(cpid2 == 0) {
  e8:	ed41                	bnez	a0,180 <main+0x180>
  ea:	e4a6                	sd	s1,72(sp)
  ec:	fc4e                	sd	s3,56(sp)
  ee:	f852                	sd	s4,48(sp)
  f0:	f456                	sd	s5,40(sp)
  f2:	f05a                	sd	s6,32(sp)
    printf("[I/O-BOUND] Starting brief work + frequent sleeps...\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	aa450513          	addi	a0,a0,-1372 # b98 <malloc+0x240>
  fc:	7a8000ef          	jal	8a4 <printf>
    
    // Do brief work then sleep - should stay high priority
    for(int iter = 0; iter < 25; iter++) {
      volatile int dummy = 0;
      for(long j = 0; j < 2000000; j++) {
 100:	001e84b7          	lui	s1,0x1e8
 104:	48048493          	addi	s1,s1,1152 # 1e8480 <base+0x1e6470>
      
      pause(1);  // Sleep - yields before quantum exhausted
      
      // Checkpoint every 5 iterations
      struct procinfo info;
      if(iter % 5 == 0 && getprocinfo(&info) == 0) {
 108:	4a15                	li	s4,5
        printf("[I/O-BOUND] Iteration %d: Q%d (slices=%d)\n", 
 10a:	00001a97          	auipc	s5,0x1
 10e:	ac6a8a93          	addi	s5,s5,-1338 # bd0 <malloc+0x278>
    for(int iter = 0; iter < 25; iter++) {
 112:	49e5                	li	s3,25
 114:	a021                	j	11c <main+0x11c>
 116:	2905                	addiw	s2,s2,1
 118:	05390163          	beq	s2,s3,15a <main+0x15a>
      volatile int dummy = 0;
 11c:	fa042623          	sw	zero,-84(s0)
      for(long j = 0; j < 2000000; j++) {
 120:	4781                	li	a5,0
        dummy = dummy + j;
 122:	fac42703          	lw	a4,-84(s0)
 126:	9f3d                	addw	a4,a4,a5
 128:	fae42623          	sw	a4,-84(s0)
      for(long j = 0; j < 2000000; j++) {
 12c:	0785                	addi	a5,a5,1
 12e:	fe979ae3          	bne	a5,s1,122 <main+0x122>
      pause(1);  // Sleep - yields before quantum exhausted
 132:	4505                	li	a0,1
 134:	3c8000ef          	jal	4fc <pause>
      if(iter % 5 == 0 && getprocinfo(&info) == 0) {
 138:	034967bb          	remw	a5,s2,s4
 13c:	ffe9                	bnez	a5,116 <main+0x116>
 13e:	fb040513          	addi	a0,s0,-80
 142:	3ca000ef          	jal	50c <getprocinfo>
 146:	f961                	bnez	a0,116 <main+0x116>
        printf("[I/O-BOUND] Iteration %d: Q%d (slices=%d)\n", 
 148:	fbc42683          	lw	a3,-68(s0)
 14c:	fb842603          	lw	a2,-72(s0)
 150:	85ca                	mv	a1,s2
 152:	8556                	mv	a0,s5
 154:	750000ef          	jal	8a4 <printf>
 158:	bf7d                	j	116 <main+0x116>
               iter, info.priority, info.time_slices);
      }
    }
    
    struct procinfo final;
    if(getprocinfo(&final) == 0) {
 15a:	fb040513          	addi	a0,s0,-80
 15e:	3ae000ef          	jal	50c <getprocinfo>
 162:	c501                	beqz	a0,16a <main+0x16a>
      printf("[I/O-BOUND] Final: Q%d (TimeSlices=%d)\n", 
             final.priority, final.time_slices);
    }
    exit(0);
 164:	4501                	li	a0,0
 166:	306000ef          	jal	46c <exit>
      printf("[I/O-BOUND] Final: Q%d (TimeSlices=%d)\n", 
 16a:	fbc42603          	lw	a2,-68(s0)
 16e:	fb842583          	lw	a1,-72(s0)
 172:	00001517          	auipc	a0,0x1
 176:	a8e50513          	addi	a0,a0,-1394 # c00 <malloc+0x2a8>
 17a:	72a000ef          	jal	8a4 <printf>
 17e:	b7dd                	j	164 <main+0x164>
 180:	e4a6                	sd	s1,72(sp)
 182:	fc4e                	sd	s3,56(sp)
 184:	f852                	sd	s4,48(sp)
 186:	f456                	sd	s5,40(sp)
 188:	f05a                	sd	s6,32(sp)
  }
  
  // Parent waits for both children
  wait(0);
 18a:	4501                	li	a0,0
 18c:	2e8000ef          	jal	474 <wait>
  wait(0);
 190:	4501                	li	a0,0
 192:	2e2000ef          	jal	474 <wait>
  
  printf("\n=== Test Complete ===\n");
 196:	00001517          	auipc	a0,0x1
 19a:	a9250513          	addi	a0,a0,-1390 # c28 <malloc+0x2d0>
 19e:	706000ef          	jal	8a4 <printf>
  printf("Expected Behavior:\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	a9e50513          	addi	a0,a0,-1378 # c40 <malloc+0x2e8>
 1aa:	6fa000ef          	jal	8a4 <printf>
  printf("  CPU-bound:  Demoted to Q2 or Q3 (lower priority)\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	aaa50513          	addi	a0,a0,-1366 # c58 <malloc+0x300>
 1b6:	6ee000ef          	jal	8a4 <printf>
  printf("  I/O-bound:  Stayed in Q0 or Q1 (higher priority)\n");
 1ba:	00001517          	auipc	a0,0x1
 1be:	ad650513          	addi	a0,a0,-1322 # c90 <malloc+0x338>
 1c2:	6e2000ef          	jal	8a4 <printf>
  printf("  Result:     I/O-bound process got preference despite CPU competition\n");
 1c6:	00001517          	auipc	a0,0x1
 1ca:	b0250513          	addi	a0,a0,-1278 # cc8 <malloc+0x370>
 1ce:	6d6000ef          	jal	8a4 <printf>
  
  exit(0);
 1d2:	4501                	li	a0,0
 1d4:	298000ef          	jal	46c <exit>

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
 1e4:	288000ef          	jal	46c <exit>

00000000000001e8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ee:	87aa                	mv	a5,a0
 1f0:	0585                	addi	a1,a1,1
 1f2:	0785                	addi	a5,a5,1
 1f4:	fff5c703          	lbu	a4,-1(a1)
 1f8:	fee78fa3          	sb	a4,-1(a5)
 1fc:	fb75                	bnez	a4,1f0 <strcpy+0x8>
    ;
  return os;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cb91                	beqz	a5,222 <strcmp+0x1e>
 210:	0005c703          	lbu	a4,0(a1)
 214:	00f71763          	bne	a4,a5,222 <strcmp+0x1e>
    p++, q++;
 218:	0505                	addi	a0,a0,1
 21a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 21c:	00054783          	lbu	a5,0(a0)
 220:	fbe5                	bnez	a5,210 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 222:	0005c503          	lbu	a0,0(a1)
}
 226:	40a7853b          	subw	a0,a5,a0
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret

0000000000000230 <strlen>:

uint
strlen(const char *s)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 236:	00054783          	lbu	a5,0(a0)
 23a:	cf91                	beqz	a5,256 <strlen+0x26>
 23c:	0505                	addi	a0,a0,1
 23e:	87aa                	mv	a5,a0
 240:	86be                	mv	a3,a5
 242:	0785                	addi	a5,a5,1
 244:	fff7c703          	lbu	a4,-1(a5)
 248:	ff65                	bnez	a4,240 <strlen+0x10>
 24a:	40a6853b          	subw	a0,a3,a0
 24e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 250:	6422                	ld	s0,8(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret
  for(n = 0; s[n]; n++)
 256:	4501                	li	a0,0
 258:	bfe5                	j	250 <strlen+0x20>

000000000000025a <memset>:

void*
memset(void *dst, int c, uint n)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 260:	ca19                	beqz	a2,276 <memset+0x1c>
 262:	87aa                	mv	a5,a0
 264:	1602                	slli	a2,a2,0x20
 266:	9201                	srli	a2,a2,0x20
 268:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 26c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 270:	0785                	addi	a5,a5,1
 272:	fee79de3          	bne	a5,a4,26c <memset+0x12>
  }
  return dst;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret

000000000000027c <strchr>:

char*
strchr(const char *s, char c)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  for(; *s; s++)
 282:	00054783          	lbu	a5,0(a0)
 286:	cb99                	beqz	a5,29c <strchr+0x20>
    if(*s == c)
 288:	00f58763          	beq	a1,a5,296 <strchr+0x1a>
  for(; *s; s++)
 28c:	0505                	addi	a0,a0,1
 28e:	00054783          	lbu	a5,0(a0)
 292:	fbfd                	bnez	a5,288 <strchr+0xc>
      return (char*)s;
  return 0;
 294:	4501                	li	a0,0
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  return 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <strchr+0x1a>

00000000000002a0 <gets>:

char*
gets(char *buf, int max)
{
 2a0:	711d                	addi	sp,sp,-96
 2a2:	ec86                	sd	ra,88(sp)
 2a4:	e8a2                	sd	s0,80(sp)
 2a6:	e4a6                	sd	s1,72(sp)
 2a8:	e0ca                	sd	s2,64(sp)
 2aa:	fc4e                	sd	s3,56(sp)
 2ac:	f852                	sd	s4,48(sp)
 2ae:	f456                	sd	s5,40(sp)
 2b0:	f05a                	sd	s6,32(sp)
 2b2:	ec5e                	sd	s7,24(sp)
 2b4:	1080                	addi	s0,sp,96
 2b6:	8baa                	mv	s7,a0
 2b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ba:	892a                	mv	s2,a0
 2bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2be:	4aa9                	li	s5,10
 2c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c2:	89a6                	mv	s3,s1
 2c4:	2485                	addiw	s1,s1,1
 2c6:	0344d663          	bge	s1,s4,2f2 <gets+0x52>
    cc = read(0, &c, 1);
 2ca:	4605                	li	a2,1
 2cc:	faf40593          	addi	a1,s0,-81
 2d0:	4501                	li	a0,0
 2d2:	1b2000ef          	jal	484 <read>
    if(cc < 1)
 2d6:	00a05e63          	blez	a0,2f2 <gets+0x52>
    buf[i++] = c;
 2da:	faf44783          	lbu	a5,-81(s0)
 2de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2e2:	01578763          	beq	a5,s5,2f0 <gets+0x50>
 2e6:	0905                	addi	s2,s2,1
 2e8:	fd679de3          	bne	a5,s6,2c2 <gets+0x22>
    buf[i++] = c;
 2ec:	89a6                	mv	s3,s1
 2ee:	a011                	j	2f2 <gets+0x52>
 2f0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2f2:	99de                	add	s3,s3,s7
 2f4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f8:	855e                	mv	a0,s7
 2fa:	60e6                	ld	ra,88(sp)
 2fc:	6446                	ld	s0,80(sp)
 2fe:	64a6                	ld	s1,72(sp)
 300:	6906                	ld	s2,64(sp)
 302:	79e2                	ld	s3,56(sp)
 304:	7a42                	ld	s4,48(sp)
 306:	7aa2                	ld	s5,40(sp)
 308:	7b02                	ld	s6,32(sp)
 30a:	6be2                	ld	s7,24(sp)
 30c:	6125                	addi	sp,sp,96
 30e:	8082                	ret

0000000000000310 <stat>:

int
stat(const char *n, struct stat *st)
{
 310:	1101                	addi	sp,sp,-32
 312:	ec06                	sd	ra,24(sp)
 314:	e822                	sd	s0,16(sp)
 316:	e04a                	sd	s2,0(sp)
 318:	1000                	addi	s0,sp,32
 31a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 31c:	4581                	li	a1,0
 31e:	18e000ef          	jal	4ac <open>
  if(fd < 0)
 322:	02054263          	bltz	a0,346 <stat+0x36>
 326:	e426                	sd	s1,8(sp)
 328:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 32a:	85ca                	mv	a1,s2
 32c:	198000ef          	jal	4c4 <fstat>
 330:	892a                	mv	s2,a0
  close(fd);
 332:	8526                	mv	a0,s1
 334:	160000ef          	jal	494 <close>
  return r;
 338:	64a2                	ld	s1,8(sp)
}
 33a:	854a                	mv	a0,s2
 33c:	60e2                	ld	ra,24(sp)
 33e:	6442                	ld	s0,16(sp)
 340:	6902                	ld	s2,0(sp)
 342:	6105                	addi	sp,sp,32
 344:	8082                	ret
    return -1;
 346:	597d                	li	s2,-1
 348:	bfcd                	j	33a <stat+0x2a>

000000000000034a <atoi>:

int
atoi(const char *s)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 350:	00054683          	lbu	a3,0(a0)
 354:	fd06879b          	addiw	a5,a3,-48
 358:	0ff7f793          	zext.b	a5,a5
 35c:	4625                	li	a2,9
 35e:	02f66863          	bltu	a2,a5,38e <atoi+0x44>
 362:	872a                	mv	a4,a0
  n = 0;
 364:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 366:	0705                	addi	a4,a4,1
 368:	0025179b          	slliw	a5,a0,0x2
 36c:	9fa9                	addw	a5,a5,a0
 36e:	0017979b          	slliw	a5,a5,0x1
 372:	9fb5                	addw	a5,a5,a3
 374:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 378:	00074683          	lbu	a3,0(a4)
 37c:	fd06879b          	addiw	a5,a3,-48
 380:	0ff7f793          	zext.b	a5,a5
 384:	fef671e3          	bgeu	a2,a5,366 <atoi+0x1c>
  return n;
}
 388:	6422                	ld	s0,8(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
  n = 0;
 38e:	4501                	li	a0,0
 390:	bfe5                	j	388 <atoi+0x3e>

0000000000000392 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 392:	1141                	addi	sp,sp,-16
 394:	e422                	sd	s0,8(sp)
 396:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 398:	02b57463          	bgeu	a0,a1,3c0 <memmove+0x2e>
    while(n-- > 0)
 39c:	00c05f63          	blez	a2,3ba <memmove+0x28>
 3a0:	1602                	slli	a2,a2,0x20
 3a2:	9201                	srli	a2,a2,0x20
 3a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3aa:	0585                	addi	a1,a1,1
 3ac:	0705                	addi	a4,a4,1
 3ae:	fff5c683          	lbu	a3,-1(a1)
 3b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b6:	fef71ae3          	bne	a4,a5,3aa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret
    dst += n;
 3c0:	00c50733          	add	a4,a0,a2
    src += n;
 3c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c6:	fec05ae3          	blez	a2,3ba <memmove+0x28>
 3ca:	fff6079b          	addiw	a5,a2,-1
 3ce:	1782                	slli	a5,a5,0x20
 3d0:	9381                	srli	a5,a5,0x20
 3d2:	fff7c793          	not	a5,a5
 3d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d8:	15fd                	addi	a1,a1,-1
 3da:	177d                	addi	a4,a4,-1
 3dc:	0005c683          	lbu	a3,0(a1)
 3e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e4:	fee79ae3          	bne	a5,a4,3d8 <memmove+0x46>
 3e8:	bfc9                	j	3ba <memmove+0x28>

00000000000003ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f0:	ca05                	beqz	a2,420 <memcmp+0x36>
 3f2:	fff6069b          	addiw	a3,a2,-1
 3f6:	1682                	slli	a3,a3,0x20
 3f8:	9281                	srli	a3,a3,0x20
 3fa:	0685                	addi	a3,a3,1
 3fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3fe:	00054783          	lbu	a5,0(a0)
 402:	0005c703          	lbu	a4,0(a1)
 406:	00e79863          	bne	a5,a4,416 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 40a:	0505                	addi	a0,a0,1
    p2++;
 40c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 40e:	fed518e3          	bne	a0,a3,3fe <memcmp+0x14>
  }
  return 0;
 412:	4501                	li	a0,0
 414:	a019                	j	41a <memcmp+0x30>
      return *p1 - *p2;
 416:	40e7853b          	subw	a0,a5,a4
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  return 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <memcmp+0x30>

0000000000000424 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 42c:	f67ff0ef          	jal	392 <memmove>
}
 430:	60a2                	ld	ra,8(sp)
 432:	6402                	ld	s0,0(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret

0000000000000438 <sbrk>:

char *
sbrk(int n) {
 438:	1141                	addi	sp,sp,-16
 43a:	e406                	sd	ra,8(sp)
 43c:	e022                	sd	s0,0(sp)
 43e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 440:	4585                	li	a1,1
 442:	0b2000ef          	jal	4f4 <sys_sbrk>
}
 446:	60a2                	ld	ra,8(sp)
 448:	6402                	ld	s0,0(sp)
 44a:	0141                	addi	sp,sp,16
 44c:	8082                	ret

000000000000044e <sbrklazy>:

char *
sbrklazy(int n) {
 44e:	1141                	addi	sp,sp,-16
 450:	e406                	sd	ra,8(sp)
 452:	e022                	sd	s0,0(sp)
 454:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 456:	4589                	li	a1,2
 458:	09c000ef          	jal	4f4 <sys_sbrk>
}
 45c:	60a2                	ld	ra,8(sp)
 45e:	6402                	ld	s0,0(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret

0000000000000464 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 464:	4885                	li	a7,1
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <exit>:
.global exit
exit:
 li a7, SYS_exit
 46c:	4889                	li	a7,2
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <wait>:
.global wait
wait:
 li a7, SYS_wait
 474:	488d                	li	a7,3
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 47c:	4891                	li	a7,4
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <read>:
.global read
read:
 li a7, SYS_read
 484:	4895                	li	a7,5
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <write>:
.global write
write:
 li a7, SYS_write
 48c:	48c1                	li	a7,16
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <close>:
.global close
close:
 li a7, SYS_close
 494:	48d5                	li	a7,21
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <kill>:
.global kill
kill:
 li a7, SYS_kill
 49c:	4899                	li	a7,6
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a4:	489d                	li	a7,7
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <open>:
.global open
open:
 li a7, SYS_open
 4ac:	48bd                	li	a7,15
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b4:	48c5                	li	a7,17
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4bc:	48c9                	li	a7,18
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c4:	48a1                	li	a7,8
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <link>:
.global link
link:
 li a7, SYS_link
 4cc:	48cd                	li	a7,19
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d4:	48d1                	li	a7,20
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4dc:	48a5                	li	a7,9
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e4:	48a9                	li	a7,10
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ec:	48ad                	li	a7,11
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4f4:	48b1                	li	a7,12
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <pause>:
.global pause
pause:
 li a7, SYS_pause
 4fc:	48b5                	li	a7,13
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 504:	48b9                	li	a7,14
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 50c:	48d9                	li	a7,22
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 514:	48dd                	li	a7,23
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 51c:	1101                	addi	sp,sp,-32
 51e:	ec06                	sd	ra,24(sp)
 520:	e822                	sd	s0,16(sp)
 522:	1000                	addi	s0,sp,32
 524:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 528:	4605                	li	a2,1
 52a:	fef40593          	addi	a1,s0,-17
 52e:	f5fff0ef          	jal	48c <write>
}
 532:	60e2                	ld	ra,24(sp)
 534:	6442                	ld	s0,16(sp)
 536:	6105                	addi	sp,sp,32
 538:	8082                	ret

000000000000053a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 53a:	715d                	addi	sp,sp,-80
 53c:	e486                	sd	ra,72(sp)
 53e:	e0a2                	sd	s0,64(sp)
 540:	f84a                	sd	s2,48(sp)
 542:	0880                	addi	s0,sp,80
 544:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 546:	c299                	beqz	a3,54c <printint+0x12>
 548:	0805c363          	bltz	a1,5ce <printint+0x94>
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
 558:	7c450513          	addi	a0,a0,1988 # d18 <digits>
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
 576:	fec773e3          	bgeu	a4,a2,55c <printint+0x22>
  if(neg)
 57a:	00088b63          	beqz	a7,590 <printint+0x56>
    buf[i++] = '-';
 57e:	fd078793          	addi	a5,a5,-48
 582:	97a2                	add	a5,a5,s0
 584:	02d00713          	li	a4,45
 588:	fee78423          	sb	a4,-24(a5)
 58c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 590:	02f05a63          	blez	a5,5c4 <printint+0x8a>
 594:	fc26                	sd	s1,56(sp)
 596:	f44e                	sd	s3,40(sp)
 598:	fb840713          	addi	a4,s0,-72
 59c:	00f704b3          	add	s1,a4,a5
 5a0:	fff70993          	addi	s3,a4,-1
 5a4:	99be                	add	s3,s3,a5
 5a6:	37fd                	addiw	a5,a5,-1
 5a8:	1782                	slli	a5,a5,0x20
 5aa:	9381                	srli	a5,a5,0x20
 5ac:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5b0:	fff4c583          	lbu	a1,-1(s1)
 5b4:	854a                	mv	a0,s2
 5b6:	f67ff0ef          	jal	51c <putc>
  while(--i >= 0)
 5ba:	14fd                	addi	s1,s1,-1
 5bc:	ff349ae3          	bne	s1,s3,5b0 <printint+0x76>
 5c0:	74e2                	ld	s1,56(sp)
 5c2:	79a2                	ld	s3,40(sp)
}
 5c4:	60a6                	ld	ra,72(sp)
 5c6:	6406                	ld	s0,64(sp)
 5c8:	7942                	ld	s2,48(sp)
 5ca:	6161                	addi	sp,sp,80
 5cc:	8082                	ret
    x = -xx;
 5ce:	40b005b3          	neg	a1,a1
    neg = 1;
 5d2:	4885                	li	a7,1
    x = -xx;
 5d4:	bfad                	j	54e <printint+0x14>

00000000000005d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d6:	711d                	addi	sp,sp,-96
 5d8:	ec86                	sd	ra,88(sp)
 5da:	e8a2                	sd	s0,80(sp)
 5dc:	e0ca                	sd	s2,64(sp)
 5de:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e0:	0005c903          	lbu	s2,0(a1)
 5e4:	28090663          	beqz	s2,870 <vprintf+0x29a>
 5e8:	e4a6                	sd	s1,72(sp)
 5ea:	fc4e                	sd	s3,56(sp)
 5ec:	f852                	sd	s4,48(sp)
 5ee:	f456                	sd	s5,40(sp)
 5f0:	f05a                	sd	s6,32(sp)
 5f2:	ec5e                	sd	s7,24(sp)
 5f4:	e862                	sd	s8,16(sp)
 5f6:	e466                	sd	s9,8(sp)
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
 60c:	06c00c93          	li	s9,108
 610:	a005                	j	630 <vprintf+0x5a>
        putc(fd, c0);
 612:	85ca                	mv	a1,s2
 614:	855a                	mv	a0,s6
 616:	f07ff0ef          	jal	51c <putc>
 61a:	a019                	j	620 <vprintf+0x4a>
    } else if(state == '%'){
 61c:	03598263          	beq	s3,s5,640 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 620:	2485                	addiw	s1,s1,1
 622:	8726                	mv	a4,s1
 624:	009a07b3          	add	a5,s4,s1
 628:	0007c903          	lbu	s2,0(a5)
 62c:	22090a63          	beqz	s2,860 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 630:	0009079b          	sext.w	a5,s2
    if(state == 0){
 634:	fe0994e3          	bnez	s3,61c <vprintf+0x46>
      if(c0 == '%'){
 638:	fd579de3          	bne	a5,s5,612 <vprintf+0x3c>
        state = '%';
 63c:	89be                	mv	s3,a5
 63e:	b7cd                	j	620 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 640:	00ea06b3          	add	a3,s4,a4
 644:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 648:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 64a:	c681                	beqz	a3,652 <vprintf+0x7c>
 64c:	9752                	add	a4,a4,s4
 64e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 652:	05878363          	beq	a5,s8,698 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 656:	05978d63          	beq	a5,s9,6b0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 65a:	07500713          	li	a4,117
 65e:	0ee78763          	beq	a5,a4,74c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 662:	07800713          	li	a4,120
 666:	12e78963          	beq	a5,a4,798 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 66a:	07000713          	li	a4,112
 66e:	14e78e63          	beq	a5,a4,7ca <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 672:	06300713          	li	a4,99
 676:	18e78e63          	beq	a5,a4,812 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 67a:	07300713          	li	a4,115
 67e:	1ae78463          	beq	a5,a4,826 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 682:	02500713          	li	a4,37
 686:	04e79563          	bne	a5,a4,6d0 <vprintf+0xfa>
        putc(fd, '%');
 68a:	02500593          	li	a1,37
 68e:	855a                	mv	a0,s6
 690:	e8dff0ef          	jal	51c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 694:	4981                	li	s3,0
 696:	b769                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 698:	008b8913          	addi	s2,s7,8
 69c:	4685                	li	a3,1
 69e:	4629                	li	a2,10
 6a0:	000ba583          	lw	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	e95ff0ef          	jal	53a <printint>
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bf8d                	j	620 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6b0:	06400793          	li	a5,100
 6b4:	02f68963          	beq	a3,a5,6e6 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b8:	06c00793          	li	a5,108
 6bc:	04f68263          	beq	a3,a5,700 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6c0:	07500793          	li	a5,117
 6c4:	0af68063          	beq	a3,a5,764 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6c8:	07800793          	li	a5,120
 6cc:	0ef68263          	beq	a3,a5,7b0 <vprintf+0x1da>
        putc(fd, '%');
 6d0:	02500593          	li	a1,37
 6d4:	855a                	mv	a0,s6
 6d6:	e47ff0ef          	jal	51c <putc>
        putc(fd, c0);
 6da:	85ca                	mv	a1,s2
 6dc:	855a                	mv	a0,s6
 6de:	e3fff0ef          	jal	51c <putc>
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bf35                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	4685                	li	a3,1
 6ec:	4629                	li	a2,10
 6ee:	000bb583          	ld	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	e47ff0ef          	jal	53a <printint>
        i += 1;
 6f8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6fa:	8bca                	mv	s7,s2
      state = 0;
 6fc:	4981                	li	s3,0
        i += 1;
 6fe:	b70d                	j	620 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 700:	06400793          	li	a5,100
 704:	02f60763          	beq	a2,a5,732 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 708:	07500793          	li	a5,117
 70c:	06f60963          	beq	a2,a5,77e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 710:	07800793          	li	a5,120
 714:	faf61ee3          	bne	a2,a5,6d0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 718:	008b8913          	addi	s2,s7,8
 71c:	4681                	li	a3,0
 71e:	4641                	li	a2,16
 720:	000bb583          	ld	a1,0(s7)
 724:	855a                	mv	a0,s6
 726:	e15ff0ef          	jal	53a <printint>
        i += 2;
 72a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
        i += 2;
 730:	bdc5                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 732:	008b8913          	addi	s2,s7,8
 736:	4685                	li	a3,1
 738:	4629                	li	a2,10
 73a:	000bb583          	ld	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	dfbff0ef          	jal	53a <printint>
        i += 2;
 744:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
        i += 2;
 74a:	bdd9                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 74c:	008b8913          	addi	s2,s7,8
 750:	4681                	li	a3,0
 752:	4629                	li	a2,10
 754:	000be583          	lwu	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	de1ff0ef          	jal	53a <printint>
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bd7d                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 764:	008b8913          	addi	s2,s7,8
 768:	4681                	li	a3,0
 76a:	4629                	li	a2,10
 76c:	000bb583          	ld	a1,0(s7)
 770:	855a                	mv	a0,s6
 772:	dc9ff0ef          	jal	53a <printint>
        i += 1;
 776:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 778:	8bca                	mv	s7,s2
      state = 0;
 77a:	4981                	li	s3,0
        i += 1;
 77c:	b555                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77e:	008b8913          	addi	s2,s7,8
 782:	4681                	li	a3,0
 784:	4629                	li	a2,10
 786:	000bb583          	ld	a1,0(s7)
 78a:	855a                	mv	a0,s6
 78c:	dafff0ef          	jal	53a <printint>
        i += 2;
 790:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 792:	8bca                	mv	s7,s2
      state = 0;
 794:	4981                	li	s3,0
        i += 2;
 796:	b569                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 798:	008b8913          	addi	s2,s7,8
 79c:	4681                	li	a3,0
 79e:	4641                	li	a2,16
 7a0:	000be583          	lwu	a1,0(s7)
 7a4:	855a                	mv	a0,s6
 7a6:	d95ff0ef          	jal	53a <printint>
 7aa:	8bca                	mv	s7,s2
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	bd8d                	j	620 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b0:	008b8913          	addi	s2,s7,8
 7b4:	4681                	li	a3,0
 7b6:	4641                	li	a2,16
 7b8:	000bb583          	ld	a1,0(s7)
 7bc:	855a                	mv	a0,s6
 7be:	d7dff0ef          	jal	53a <printint>
        i += 1;
 7c2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c4:	8bca                	mv	s7,s2
      state = 0;
 7c6:	4981                	li	s3,0
        i += 1;
 7c8:	bda1                	j	620 <vprintf+0x4a>
 7ca:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7cc:	008b8d13          	addi	s10,s7,8
 7d0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7d4:	03000593          	li	a1,48
 7d8:	855a                	mv	a0,s6
 7da:	d43ff0ef          	jal	51c <putc>
  putc(fd, 'x');
 7de:	07800593          	li	a1,120
 7e2:	855a                	mv	a0,s6
 7e4:	d39ff0ef          	jal	51c <putc>
 7e8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ea:	00000b97          	auipc	s7,0x0
 7ee:	52eb8b93          	addi	s7,s7,1326 # d18 <digits>
 7f2:	03c9d793          	srli	a5,s3,0x3c
 7f6:	97de                	add	a5,a5,s7
 7f8:	0007c583          	lbu	a1,0(a5)
 7fc:	855a                	mv	a0,s6
 7fe:	d1fff0ef          	jal	51c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 802:	0992                	slli	s3,s3,0x4
 804:	397d                	addiw	s2,s2,-1
 806:	fe0916e3          	bnez	s2,7f2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 80a:	8bea                	mv	s7,s10
      state = 0;
 80c:	4981                	li	s3,0
 80e:	6d02                	ld	s10,0(sp)
 810:	bd01                	j	620 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 812:	008b8913          	addi	s2,s7,8
 816:	000bc583          	lbu	a1,0(s7)
 81a:	855a                	mv	a0,s6
 81c:	d01ff0ef          	jal	51c <putc>
 820:	8bca                	mv	s7,s2
      state = 0;
 822:	4981                	li	s3,0
 824:	bbf5                	j	620 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 826:	008b8993          	addi	s3,s7,8
 82a:	000bb903          	ld	s2,0(s7)
 82e:	00090f63          	beqz	s2,84c <vprintf+0x276>
        for(; *s; s++)
 832:	00094583          	lbu	a1,0(s2)
 836:	c195                	beqz	a1,85a <vprintf+0x284>
          putc(fd, *s);
 838:	855a                	mv	a0,s6
 83a:	ce3ff0ef          	jal	51c <putc>
        for(; *s; s++)
 83e:	0905                	addi	s2,s2,1
 840:	00094583          	lbu	a1,0(s2)
 844:	f9f5                	bnez	a1,838 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 846:	8bce                	mv	s7,s3
      state = 0;
 848:	4981                	li	s3,0
 84a:	bbd9                	j	620 <vprintf+0x4a>
          s = "(null)";
 84c:	00000917          	auipc	s2,0x0
 850:	4c490913          	addi	s2,s2,1220 # d10 <malloc+0x3b8>
        for(; *s; s++)
 854:	02800593          	li	a1,40
 858:	b7c5                	j	838 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 85a:	8bce                	mv	s7,s3
      state = 0;
 85c:	4981                	li	s3,0
 85e:	b3c9                	j	620 <vprintf+0x4a>
 860:	64a6                	ld	s1,72(sp)
 862:	79e2                	ld	s3,56(sp)
 864:	7a42                	ld	s4,48(sp)
 866:	7aa2                	ld	s5,40(sp)
 868:	7b02                	ld	s6,32(sp)
 86a:	6be2                	ld	s7,24(sp)
 86c:	6c42                	ld	s8,16(sp)
 86e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 870:	60e6                	ld	ra,88(sp)
 872:	6446                	ld	s0,80(sp)
 874:	6906                	ld	s2,64(sp)
 876:	6125                	addi	sp,sp,96
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
 898:	d3fff0ef          	jal	5d6 <vprintf>
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
 8ca:	d0dff0ef          	jal	5d6 <vprintf>
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
 8e0:	00001797          	auipc	a5,0x1
 8e4:	7207b783          	ld	a5,1824(a5) # 2000 <freep>
 8e8:	a02d                	j	912 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ea:	4618                	lw	a4,8(a2)
 8ec:	9f2d                	addw	a4,a4,a1
 8ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	6310                	ld	a2,0(a4)
 8f6:	a83d                	j	934 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8f8:	ff852703          	lw	a4,-8(a0)
 8fc:	9f31                	addw	a4,a4,a2
 8fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 900:	ff053683          	ld	a3,-16(a0)
 904:	a091                	j	948 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 906:	6398                	ld	a4,0(a5)
 908:	00e7e463          	bltu	a5,a4,910 <free+0x3a>
 90c:	00e6ea63          	bltu	a3,a4,920 <free+0x4a>
{
 910:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 912:	fed7fae3          	bgeu	a5,a3,906 <free+0x30>
 916:	6398                	ld	a4,0(a5)
 918:	00e6e463          	bltu	a3,a4,920 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91c:	fee7eae3          	bltu	a5,a4,910 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 920:	ff852583          	lw	a1,-8(a0)
 924:	6390                	ld	a2,0(a5)
 926:	02059813          	slli	a6,a1,0x20
 92a:	01c85713          	srli	a4,a6,0x1c
 92e:	9736                	add	a4,a4,a3
 930:	fae60de3          	beq	a2,a4,8ea <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 934:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 938:	4790                	lw	a2,8(a5)
 93a:	02061593          	slli	a1,a2,0x20
 93e:	01c5d713          	srli	a4,a1,0x1c
 942:	973e                	add	a4,a4,a5
 944:	fae68ae3          	beq	a3,a4,8f8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 948:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 94a:	00001717          	auipc	a4,0x1
 94e:	6af73b23          	sd	a5,1718(a4) # 2000 <freep>
}
 952:	6422                	ld	s0,8(sp)
 954:	0141                	addi	sp,sp,16
 956:	8082                	ret

0000000000000958 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 958:	7139                	addi	sp,sp,-64
 95a:	fc06                	sd	ra,56(sp)
 95c:	f822                	sd	s0,48(sp)
 95e:	f426                	sd	s1,40(sp)
 960:	ec4e                	sd	s3,24(sp)
 962:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 964:	02051493          	slli	s1,a0,0x20
 968:	9081                	srli	s1,s1,0x20
 96a:	04bd                	addi	s1,s1,15
 96c:	8091                	srli	s1,s1,0x4
 96e:	0014899b          	addiw	s3,s1,1
 972:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 974:	00001517          	auipc	a0,0x1
 978:	68c53503          	ld	a0,1676(a0) # 2000 <freep>
 97c:	c915                	beqz	a0,9b0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 980:	4798                	lw	a4,8(a5)
 982:	08977a63          	bgeu	a4,s1,a16 <malloc+0xbe>
 986:	f04a                	sd	s2,32(sp)
 988:	e852                	sd	s4,16(sp)
 98a:	e456                	sd	s5,8(sp)
 98c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 98e:	8a4e                	mv	s4,s3
 990:	0009871b          	sext.w	a4,s3
 994:	6685                	lui	a3,0x1
 996:	00d77363          	bgeu	a4,a3,99c <malloc+0x44>
 99a:	6a05                	lui	s4,0x1
 99c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9a4:	00001917          	auipc	s2,0x1
 9a8:	65c90913          	addi	s2,s2,1628 # 2000 <freep>
  if(p == SBRK_ERROR)
 9ac:	5afd                	li	s5,-1
 9ae:	a081                	j	9ee <malloc+0x96>
 9b0:	f04a                	sd	s2,32(sp)
 9b2:	e852                	sd	s4,16(sp)
 9b4:	e456                	sd	s5,8(sp)
 9b6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9b8:	00001797          	auipc	a5,0x1
 9bc:	65878793          	addi	a5,a5,1624 # 2010 <base>
 9c0:	00001717          	auipc	a4,0x1
 9c4:	64f73023          	sd	a5,1600(a4) # 2000 <freep>
 9c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ce:	b7c1                	j	98e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9d0:	6398                	ld	a4,0(a5)
 9d2:	e118                	sd	a4,0(a0)
 9d4:	a8a9                	j	a2e <malloc+0xd6>
  hp->s.size = nu;
 9d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9da:	0541                	addi	a0,a0,16
 9dc:	efbff0ef          	jal	8d6 <free>
  return freep;
 9e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9e4:	c12d                	beqz	a0,a46 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e8:	4798                	lw	a4,8(a5)
 9ea:	02977263          	bgeu	a4,s1,a0e <malloc+0xb6>
    if(p == freep)
 9ee:	00093703          	ld	a4,0(s2)
 9f2:	853e                	mv	a0,a5
 9f4:	fef719e3          	bne	a4,a5,9e6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9f8:	8552                	mv	a0,s4
 9fa:	a3fff0ef          	jal	438 <sbrk>
  if(p == SBRK_ERROR)
 9fe:	fd551ce3          	bne	a0,s5,9d6 <malloc+0x7e>
        return 0;
 a02:	4501                	li	a0,0
 a04:	7902                	ld	s2,32(sp)
 a06:	6a42                	ld	s4,16(sp)
 a08:	6aa2                	ld	s5,8(sp)
 a0a:	6b02                	ld	s6,0(sp)
 a0c:	a03d                	j	a3a <malloc+0xe2>
 a0e:	7902                	ld	s2,32(sp)
 a10:	6a42                	ld	s4,16(sp)
 a12:	6aa2                	ld	s5,8(sp)
 a14:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a16:	fae48de3          	beq	s1,a4,9d0 <malloc+0x78>
        p->s.size -= nunits;
 a1a:	4137073b          	subw	a4,a4,s3
 a1e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a20:	02071693          	slli	a3,a4,0x20
 a24:	01c6d713          	srli	a4,a3,0x1c
 a28:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a2a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a2e:	00001717          	auipc	a4,0x1
 a32:	5ca73923          	sd	a0,1490(a4) # 2000 <freep>
      return (void*)(p + 1);
 a36:	01078513          	addi	a0,a5,16
  }
}
 a3a:	70e2                	ld	ra,56(sp)
 a3c:	7442                	ld	s0,48(sp)
 a3e:	74a2                	ld	s1,40(sp)
 a40:	69e2                	ld	s3,24(sp)
 a42:	6121                	addi	sp,sp,64
 a44:	8082                	ret
 a46:	7902                	ld	s2,32(sp)
 a48:	6a42                	ld	s4,16(sp)
 a4a:	6aa2                	ld	s5,8(sp)
 a4c:	6b02                	ld	s6,0(sp)
 a4e:	b7f5                	j	a3a <malloc+0xe2>
