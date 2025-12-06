
user/_starve_t:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Test starvation prevention: Run multiple CPU-bound processes
// Ensure low-priority processes get boosted and execute
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
  14:	f062                	sd	s8,32(sp)
  16:	1880                	addi	s0,sp,112
  int pids[3];
  int num_procs = 3;
  
  printf("=== Starvation Prevention Test (Week 3) ===\n");
  18:	00001517          	auipc	a0,0x1
  1c:	a6850513          	addi	a0,a0,-1432 # a80 <malloc+0xf4>
  20:	0b5000ef          	jal	8d4 <printf>
  printf("Testing automatic priority boosting every 100 ticks\n");
  24:	00001517          	auipc	a0,0x1
  28:	a8c50513          	addi	a0,a0,-1396 # ab0 <malloc+0x124>
  2c:	0a9000ef          	jal	8d4 <printf>
  printf("Running %d CPU-bound processes concurrently\n", num_procs);
  30:	458d                	li	a1,3
  32:	00001517          	auipc	a0,0x1
  36:	ab650513          	addi	a0,a0,-1354 # ae8 <malloc+0x15c>
  3a:	09b000ef          	jal	8d4 <printf>
  printf("All processes should get CPU time due to periodic boosting\n\n");
  3e:	00001517          	auipc	a0,0x1
  42:	ada50513          	addi	a0,a0,-1318 # b18 <malloc+0x18c>
  46:	08f000ef          	jal	8d4 <printf>
  
  // Fork multiple CPU-bound processes
  for(int i = 0; i < num_procs; i++) {
  4a:	4b81                	li	s7,0
      
      exit(0);
    }
    
    // Small delay between forks
    pause(1);
  4c:	4905                	li	s2,1
  for(int i = 0; i < num_procs; i++) {
  4e:	448d                	li	s1,3
    pids[i] = fork();
  50:	426000ef          	jal	476 <fork>
  54:	8a2a                	mv	s4,a0
    if(pids[i] == 0) {
  56:	c541                	beqz	a0,de <main+0xde>
    pause(1);
  58:	854a                	mv	a0,s2
  5a:	4b4000ef          	jal	50e <pause>
  for(int i = 0; i < num_procs; i++) {
  5e:	2b85                	addiw	s7,s7,1
  60:	fe9b98e3          	bne	s7,s1,50 <main+0x50>
  }
  
  // Parent waits for all children
  printf("\n[Parent] Waiting for all processes to complete...\n");
  64:	00001517          	auipc	a0,0x1
  68:	b6c50513          	addi	a0,a0,-1172 # bd0 <malloc+0x244>
  6c:	069000ef          	jal	8d4 <printf>
  for(int i = 0; i < num_procs; i++) {
  70:	4481                	li	s1,0
    wait(0);
    printf("[Parent] Process %d finished\n", i);
  72:	00001997          	auipc	s3,0x1
  76:	b9698993          	addi	s3,s3,-1130 # c08 <malloc+0x27c>
  for(int i = 0; i < num_procs; i++) {
  7a:	490d                	li	s2,3
    wait(0);
  7c:	4501                	li	a0,0
  7e:	408000ef          	jal	486 <wait>
    printf("[Parent] Process %d finished\n", i);
  82:	85a6                	mv	a1,s1
  84:	854e                	mv	a0,s3
  86:	04f000ef          	jal	8d4 <printf>
  for(int i = 0; i < num_procs; i++) {
  8a:	2485                	addiw	s1,s1,1
  8c:	ff2498e3          	bne	s1,s2,7c <main+0x7c>
  }
  
  printf("\n=== Starvation Test Complete ===\n");
  90:	00001517          	auipc	a0,0x1
  94:	b9850513          	addi	a0,a0,-1128 # c28 <malloc+0x29c>
  98:	03d000ef          	jal	8d4 <printf>
  printf("Analysis:\n");
  9c:	00001517          	auipc	a0,0x1
  a0:	bb450513          	addi	a0,a0,-1100 # c50 <malloc+0x2c4>
  a4:	031000ef          	jal	8d4 <printf>
  printf("  - All processes should have completed\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	bb850513          	addi	a0,a0,-1096 # c60 <malloc+0x2d4>
  b0:	025000ef          	jal	8d4 <printf>
  printf("  - Processes should have been boosted to Q0 every ~100 ticks\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	bdc50513          	addi	a0,a0,-1060 # c90 <malloc+0x304>
  bc:	019000ef          	jal	8d4 <printf>
  printf("  - Even low-priority processes got CPU time\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	c1050513          	addi	a0,a0,-1008 # cd0 <malloc+0x344>
  c8:	00d000ef          	jal	8d4 <printf>
  printf("  - No process was starved!\n");
  cc:	00001517          	auipc	a0,0x1
  d0:	c3450513          	addi	a0,a0,-972 # d00 <malloc+0x374>
  d4:	001000ef          	jal	8d4 <printf>
  
  exit(0);
  d8:	4501                	li	a0,0
  da:	3a4000ef          	jal	47e <exit>
      volatile int dummy = 0;
  de:	f8042e23          	sw	zero,-100(s0)
      printf("[Process %d] Started (PID=%d)\n", my_id, getpid());
  e2:	41c000ef          	jal	4fe <getpid>
  e6:	862a                	mv	a2,a0
  e8:	85de                	mv	a1,s7
  ea:	00001517          	auipc	a0,0x1
  ee:	a6e50513          	addi	a0,a0,-1426 # b58 <malloc+0x1cc>
  f2:	7e2000ef          	jal	8d4 <printf>
          dummy = dummy % 1000000;
  f6:	431be9b7          	lui	s3,0x431be
  fa:	e8398993          	addi	s3,s3,-381 # 431bde83 <base+0x431bce73>
  fe:	000f4937          	lui	s2,0xf4
 102:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf3230>
        for(long j = 0; j < 5000000; j++) {
 106:	004c54b7          	lui	s1,0x4c5
 10a:	b4048493          	addi	s1,s1,-1216 # 4c4b40 <base+0x4c3b30>
        if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 10e:	88889ab7          	lui	s5,0x88889
 112:	889a8a93          	addi	s5,s5,-1911 # ffffffff88888889 <base+0xffffffff88887879>
 116:	fa040c13          	addi	s8,s0,-96
      for(int iter = 0; iter < 60; iter++) {
 11a:	03c00b13          	li	s6,60
 11e:	a021                	j	126 <main+0x126>
 120:	2a05                	addiw	s4,s4,1
 122:	076a0e63          	beq	s4,s6,19e <main+0x19e>
        for(long j = 0; j < 5000000; j++) {
 126:	4681                	li	a3,0
          dummy = dummy + j;
 128:	f9c42783          	lw	a5,-100(s0)
 12c:	9fb5                	addw	a5,a5,a3
 12e:	f8f42e23          	sw	a5,-100(s0)
          dummy = dummy % 1000000;
 132:	f9c42783          	lw	a5,-100(s0)
 136:	0007871b          	sext.w	a4,a5
 13a:	033787b3          	mul	a5,a5,s3
 13e:	97c9                	srai	a5,a5,0x32
 140:	41f7561b          	sraiw	a2,a4,0x1f
 144:	9f91                	subw	a5,a5,a2
 146:	02f907bb          	mulw	a5,s2,a5
 14a:	9f1d                	subw	a4,a4,a5
 14c:	f8e42e23          	sw	a4,-100(s0)
        for(long j = 0; j < 5000000; j++) {
 150:	0685                	addi	a3,a3,1
 152:	fc969be3          	bne	a3,s1,128 <main+0x128>
        if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 156:	035a07b3          	mul	a5,s4,s5
 15a:	9381                	srli	a5,a5,0x20
 15c:	00fa07bb          	addw	a5,s4,a5
 160:	4037d79b          	sraiw	a5,a5,0x3
 164:	41fa571b          	sraiw	a4,s4,0x1f
 168:	9f99                	subw	a5,a5,a4
 16a:	0047971b          	slliw	a4,a5,0x4
 16e:	40f707bb          	subw	a5,a4,a5
 172:	40fa07bb          	subw	a5,s4,a5
 176:	f7cd                	bnez	a5,120 <main+0x120>
 178:	8562                	mv	a0,s8
 17a:	3a4000ef          	jal	51e <getprocinfo>
 17e:	f14d                	bnez	a0,120 <main+0x120>
          int current_ticks = uptime();
 180:	396000ef          	jal	516 <uptime>
 184:	862a                	mv	a2,a0
          printf("[Process %d] Tick %d: Q%d (slices=%d)\n", 
 186:	fac42703          	lw	a4,-84(s0)
 18a:	fa842683          	lw	a3,-88(s0)
 18e:	85de                	mv	a1,s7
 190:	00001517          	auipc	a0,0x1
 194:	9e850513          	addi	a0,a0,-1560 # b78 <malloc+0x1ec>
 198:	73c000ef          	jal	8d4 <printf>
 19c:	b751                	j	120 <main+0x120>
      if(getprocinfo(&info) == 0) {
 19e:	fa040513          	addi	a0,s0,-96
 1a2:	37c000ef          	jal	51e <getprocinfo>
 1a6:	c501                	beqz	a0,1ae <main+0x1ae>
      exit(0);
 1a8:	4501                	li	a0,0
 1aa:	2d4000ef          	jal	47e <exit>
        printf("[Process %d] COMPLETED at tick %d: Final Q%d\n", 
 1ae:	368000ef          	jal	516 <uptime>
 1b2:	862a                	mv	a2,a0
 1b4:	fa842683          	lw	a3,-88(s0)
 1b8:	85de                	mv	a1,s7
 1ba:	00001517          	auipc	a0,0x1
 1be:	9e650513          	addi	a0,a0,-1562 # ba0 <malloc+0x214>
 1c2:	712000ef          	jal	8d4 <printf>
 1c6:	b7cd                	j	1a8 <main+0x1a8>

00000000000001c8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e406                	sd	ra,8(sp)
 1cc:	e022                	sd	s0,0(sp)
 1ce:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1d0:	e31ff0ef          	jal	0 <main>
  exit(r);
 1d4:	2aa000ef          	jal	47e <exit>

00000000000001d8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e406                	sd	ra,8(sp)
 1dc:	e022                	sd	s0,0(sp)
 1de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e0:	87aa                	mv	a5,a0
 1e2:	0585                	addi	a1,a1,1
 1e4:	0785                	addi	a5,a5,1
 1e6:	fff5c703          	lbu	a4,-1(a1)
 1ea:	fee78fa3          	sb	a4,-1(a5)
 1ee:	fb75                	bnez	a4,1e2 <strcpy+0xa>
    ;
  return os;
}
 1f0:	60a2                	ld	ra,8(sp)
 1f2:	6402                	ld	s0,0(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 200:	00054783          	lbu	a5,0(a0)
 204:	cb91                	beqz	a5,218 <strcmp+0x20>
 206:	0005c703          	lbu	a4,0(a1)
 20a:	00f71763          	bne	a4,a5,218 <strcmp+0x20>
    p++, q++;
 20e:	0505                	addi	a0,a0,1
 210:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 212:	00054783          	lbu	a5,0(a0)
 216:	fbe5                	bnez	a5,206 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 218:	0005c503          	lbu	a0,0(a1)
}
 21c:	40a7853b          	subw	a0,a5,a0
 220:	60a2                	ld	ra,8(sp)
 222:	6402                	ld	s0,0(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strlen>:

uint
strlen(const char *s)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e406                	sd	ra,8(sp)
 22c:	e022                	sd	s0,0(sp)
 22e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 230:	00054783          	lbu	a5,0(a0)
 234:	cf91                	beqz	a5,250 <strlen+0x28>
 236:	00150793          	addi	a5,a0,1
 23a:	86be                	mv	a3,a5
 23c:	0785                	addi	a5,a5,1
 23e:	fff7c703          	lbu	a4,-1(a5)
 242:	ff65                	bnez	a4,23a <strlen+0x12>
 244:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 248:	60a2                	ld	ra,8(sp)
 24a:	6402                	ld	s0,0(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  for(n = 0; s[n]; n++)
 250:	4501                	li	a0,0
 252:	bfdd                	j	248 <strlen+0x20>

0000000000000254 <memset>:

void*
memset(void *dst, int c, uint n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e406                	sd	ra,8(sp)
 258:	e022                	sd	s0,0(sp)
 25a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 25c:	ca19                	beqz	a2,272 <memset+0x1e>
 25e:	87aa                	mv	a5,a0
 260:	1602                	slli	a2,a2,0x20
 262:	9201                	srli	a2,a2,0x20
 264:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 268:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 26c:	0785                	addi	a5,a5,1
 26e:	fee79de3          	bne	a5,a4,268 <memset+0x14>
  }
  return dst;
}
 272:	60a2                	ld	ra,8(sp)
 274:	6402                	ld	s0,0(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <strchr>:

char*
strchr(const char *s, char c)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e406                	sd	ra,8(sp)
 27e:	e022                	sd	s0,0(sp)
 280:	0800                	addi	s0,sp,16
  for(; *s; s++)
 282:	00054783          	lbu	a5,0(a0)
 286:	cf81                	beqz	a5,29e <strchr+0x24>
    if(*s == c)
 288:	00f58763          	beq	a1,a5,296 <strchr+0x1c>
  for(; *s; s++)
 28c:	0505                	addi	a0,a0,1
 28e:	00054783          	lbu	a5,0(a0)
 292:	fbfd                	bnez	a5,288 <strchr+0xe>
      return (char*)s;
  return 0;
 294:	4501                	li	a0,0
}
 296:	60a2                	ld	ra,8(sp)
 298:	6402                	ld	s0,0(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
  return 0;
 29e:	4501                	li	a0,0
 2a0:	bfdd                	j	296 <strchr+0x1c>

00000000000002a2 <gets>:

char*
gets(char *buf, int max)
{
 2a2:	711d                	addi	sp,sp,-96
 2a4:	ec86                	sd	ra,88(sp)
 2a6:	e8a2                	sd	s0,80(sp)
 2a8:	e4a6                	sd	s1,72(sp)
 2aa:	e0ca                	sd	s2,64(sp)
 2ac:	fc4e                	sd	s3,56(sp)
 2ae:	f852                	sd	s4,48(sp)
 2b0:	f456                	sd	s5,40(sp)
 2b2:	f05a                	sd	s6,32(sp)
 2b4:	ec5e                	sd	s7,24(sp)
 2b6:	e862                	sd	s8,16(sp)
 2b8:	1080                	addi	s0,sp,96
 2ba:	8baa                	mv	s7,a0
 2bc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2be:	892a                	mv	s2,a0
 2c0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2c2:	faf40b13          	addi	s6,s0,-81
 2c6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2c8:	8c26                	mv	s8,s1
 2ca:	0014899b          	addiw	s3,s1,1
 2ce:	84ce                	mv	s1,s3
 2d0:	0349d463          	bge	s3,s4,2f8 <gets+0x56>
    cc = read(0, &c, 1);
 2d4:	8656                	mv	a2,s5
 2d6:	85da                	mv	a1,s6
 2d8:	4501                	li	a0,0
 2da:	1bc000ef          	jal	496 <read>
    if(cc < 1)
 2de:	00a05d63          	blez	a0,2f8 <gets+0x56>
      break;
    buf[i++] = c;
 2e2:	faf44783          	lbu	a5,-81(s0)
 2e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ea:	0905                	addi	s2,s2,1
 2ec:	ff678713          	addi	a4,a5,-10
 2f0:	c319                	beqz	a4,2f6 <gets+0x54>
 2f2:	17cd                	addi	a5,a5,-13
 2f4:	fbf1                	bnez	a5,2c8 <gets+0x26>
    buf[i++] = c;
 2f6:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2f8:	9c5e                	add	s8,s8,s7
 2fa:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2fe:	855e                	mv	a0,s7
 300:	60e6                	ld	ra,88(sp)
 302:	6446                	ld	s0,80(sp)
 304:	64a6                	ld	s1,72(sp)
 306:	6906                	ld	s2,64(sp)
 308:	79e2                	ld	s3,56(sp)
 30a:	7a42                	ld	s4,48(sp)
 30c:	7aa2                	ld	s5,40(sp)
 30e:	7b02                	ld	s6,32(sp)
 310:	6be2                	ld	s7,24(sp)
 312:	6c42                	ld	s8,16(sp)
 314:	6125                	addi	sp,sp,96
 316:	8082                	ret

0000000000000318 <stat>:

int
stat(const char *n, struct stat *st)
{
 318:	1101                	addi	sp,sp,-32
 31a:	ec06                	sd	ra,24(sp)
 31c:	e822                	sd	s0,16(sp)
 31e:	e04a                	sd	s2,0(sp)
 320:	1000                	addi	s0,sp,32
 322:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 324:	4581                	li	a1,0
 326:	198000ef          	jal	4be <open>
  if(fd < 0)
 32a:	02054263          	bltz	a0,34e <stat+0x36>
 32e:	e426                	sd	s1,8(sp)
 330:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 332:	85ca                	mv	a1,s2
 334:	1a2000ef          	jal	4d6 <fstat>
 338:	892a                	mv	s2,a0
  close(fd);
 33a:	8526                	mv	a0,s1
 33c:	16a000ef          	jal	4a6 <close>
  return r;
 340:	64a2                	ld	s1,8(sp)
}
 342:	854a                	mv	a0,s2
 344:	60e2                	ld	ra,24(sp)
 346:	6442                	ld	s0,16(sp)
 348:	6902                	ld	s2,0(sp)
 34a:	6105                	addi	sp,sp,32
 34c:	8082                	ret
    return -1;
 34e:	57fd                	li	a5,-1
 350:	893e                	mv	s2,a5
 352:	bfc5                	j	342 <stat+0x2a>

0000000000000354 <atoi>:

int
atoi(const char *s)
{
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 35c:	00054683          	lbu	a3,0(a0)
 360:	fd06879b          	addiw	a5,a3,-48
 364:	0ff7f793          	zext.b	a5,a5
 368:	4625                	li	a2,9
 36a:	02f66963          	bltu	a2,a5,39c <atoi+0x48>
 36e:	872a                	mv	a4,a0
  n = 0;
 370:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 372:	0705                	addi	a4,a4,1
 374:	0025179b          	slliw	a5,a0,0x2
 378:	9fa9                	addw	a5,a5,a0
 37a:	0017979b          	slliw	a5,a5,0x1
 37e:	9fb5                	addw	a5,a5,a3
 380:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 384:	00074683          	lbu	a3,0(a4)
 388:	fd06879b          	addiw	a5,a3,-48
 38c:	0ff7f793          	zext.b	a5,a5
 390:	fef671e3          	bgeu	a2,a5,372 <atoi+0x1e>
  return n;
}
 394:	60a2                	ld	ra,8(sp)
 396:	6402                	ld	s0,0(sp)
 398:	0141                	addi	sp,sp,16
 39a:	8082                	ret
  n = 0;
 39c:	4501                	li	a0,0
 39e:	bfdd                	j	394 <atoi+0x40>

00000000000003a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e406                	sd	ra,8(sp)
 3a4:	e022                	sd	s0,0(sp)
 3a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a8:	02b57563          	bgeu	a0,a1,3d2 <memmove+0x32>
    while(n-- > 0)
 3ac:	00c05f63          	blez	a2,3ca <memmove+0x2a>
 3b0:	1602                	slli	a2,a2,0x20
 3b2:	9201                	srli	a2,a2,0x20
 3b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ba:	0585                	addi	a1,a1,1
 3bc:	0705                	addi	a4,a4,1
 3be:	fff5c683          	lbu	a3,-1(a1)
 3c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c6:	fee79ae3          	bne	a5,a4,3ba <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
    while(n-- > 0)
 3d2:	fec05ce3          	blez	a2,3ca <memmove+0x2a>
    dst += n;
 3d6:	00c50733          	add	a4,a0,a2
    src += n;
 3da:	95b2                	add	a1,a1,a2
 3dc:	fff6079b          	addiw	a5,a2,-1
 3e0:	1782                	slli	a5,a5,0x20
 3e2:	9381                	srli	a5,a5,0x20
 3e4:	fff7c793          	not	a5,a5
 3e8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ea:	15fd                	addi	a1,a1,-1
 3ec:	177d                	addi	a4,a4,-1
 3ee:	0005c683          	lbu	a3,0(a1)
 3f2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3f6:	fef71ae3          	bne	a4,a5,3ea <memmove+0x4a>
 3fa:	bfc1                	j	3ca <memmove+0x2a>

00000000000003fc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e406                	sd	ra,8(sp)
 400:	e022                	sd	s0,0(sp)
 402:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 404:	c61d                	beqz	a2,432 <memcmp+0x36>
 406:	1602                	slli	a2,a2,0x20
 408:	9201                	srli	a2,a2,0x20
 40a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 40e:	00054783          	lbu	a5,0(a0)
 412:	0005c703          	lbu	a4,0(a1)
 416:	00e79863          	bne	a5,a4,426 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 41a:	0505                	addi	a0,a0,1
    p2++;
 41c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 41e:	fed518e3          	bne	a0,a3,40e <memcmp+0x12>
  }
  return 0;
 422:	4501                	li	a0,0
 424:	a019                	j	42a <memcmp+0x2e>
      return *p1 - *p2;
 426:	40e7853b          	subw	a0,a5,a4
}
 42a:	60a2                	ld	ra,8(sp)
 42c:	6402                	ld	s0,0(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret
  return 0;
 432:	4501                	li	a0,0
 434:	bfdd                	j	42a <memcmp+0x2e>

0000000000000436 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 436:	1141                	addi	sp,sp,-16
 438:	e406                	sd	ra,8(sp)
 43a:	e022                	sd	s0,0(sp)
 43c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 43e:	f63ff0ef          	jal	3a0 <memmove>
}
 442:	60a2                	ld	ra,8(sp)
 444:	6402                	ld	s0,0(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret

000000000000044a <sbrk>:

char *
sbrk(int n) {
 44a:	1141                	addi	sp,sp,-16
 44c:	e406                	sd	ra,8(sp)
 44e:	e022                	sd	s0,0(sp)
 450:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 452:	4585                	li	a1,1
 454:	0b2000ef          	jal	506 <sys_sbrk>
}
 458:	60a2                	ld	ra,8(sp)
 45a:	6402                	ld	s0,0(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret

0000000000000460 <sbrklazy>:

char *
sbrklazy(int n) {
 460:	1141                	addi	sp,sp,-16
 462:	e406                	sd	ra,8(sp)
 464:	e022                	sd	s0,0(sp)
 466:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 468:	4589                	li	a1,2
 46a:	09c000ef          	jal	506 <sys_sbrk>
}
 46e:	60a2                	ld	ra,8(sp)
 470:	6402                	ld	s0,0(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret

0000000000000476 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 476:	4885                	li	a7,1
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <exit>:
.global exit
exit:
 li a7, SYS_exit
 47e:	4889                	li	a7,2
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <wait>:
.global wait
wait:
 li a7, SYS_wait
 486:	488d                	li	a7,3
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 48e:	4891                	li	a7,4
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <read>:
.global read
read:
 li a7, SYS_read
 496:	4895                	li	a7,5
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <write>:
.global write
write:
 li a7, SYS_write
 49e:	48c1                	li	a7,16
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <close>:
.global close
close:
 li a7, SYS_close
 4a6:	48d5                	li	a7,21
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ae:	4899                	li	a7,6
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b6:	489d                	li	a7,7
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <open>:
.global open
open:
 li a7, SYS_open
 4be:	48bd                	li	a7,15
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c6:	48c5                	li	a7,17
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4ce:	48c9                	li	a7,18
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d6:	48a1                	li	a7,8
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <link>:
.global link
link:
 li a7, SYS_link
 4de:	48cd                	li	a7,19
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e6:	48d1                	li	a7,20
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ee:	48a5                	li	a7,9
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f6:	48a9                	li	a7,10
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4fe:	48ad                	li	a7,11
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 506:	48b1                	li	a7,12
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <pause>:
.global pause
pause:
 li a7, SYS_pause
 50e:	48b5                	li	a7,13
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 516:	48b9                	li	a7,14
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 51e:	48d9                	li	a7,22
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 526:	48dd                	li	a7,23
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 52e:	1101                	addi	sp,sp,-32
 530:	ec06                	sd	ra,24(sp)
 532:	e822                	sd	s0,16(sp)
 534:	1000                	addi	s0,sp,32
 536:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 53a:	4605                	li	a2,1
 53c:	fef40593          	addi	a1,s0,-17
 540:	f5fff0ef          	jal	49e <write>
}
 544:	60e2                	ld	ra,24(sp)
 546:	6442                	ld	s0,16(sp)
 548:	6105                	addi	sp,sp,32
 54a:	8082                	ret

000000000000054c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 54c:	715d                	addi	sp,sp,-80
 54e:	e486                	sd	ra,72(sp)
 550:	e0a2                	sd	s0,64(sp)
 552:	f84a                	sd	s2,48(sp)
 554:	f44e                	sd	s3,40(sp)
 556:	0880                	addi	s0,sp,80
 558:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 55a:	c6d1                	beqz	a3,5e6 <printint+0x9a>
 55c:	0805d563          	bgez	a1,5e6 <printint+0x9a>
    neg = 1;
    x = -xx;
 560:	40b005b3          	neg	a1,a1
    neg = 1;
 564:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 566:	fb840993          	addi	s3,s0,-72
  neg = 0;
 56a:	86ce                	mv	a3,s3
  i = 0;
 56c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 56e:	00000817          	auipc	a6,0x0
 572:	7ba80813          	addi	a6,a6,1978 # d28 <digits>
 576:	88ba                	mv	a7,a4
 578:	0017051b          	addiw	a0,a4,1
 57c:	872a                	mv	a4,a0
 57e:	02c5f7b3          	remu	a5,a1,a2
 582:	97c2                	add	a5,a5,a6
 584:	0007c783          	lbu	a5,0(a5)
 588:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 58c:	87ae                	mv	a5,a1
 58e:	02c5d5b3          	divu	a1,a1,a2
 592:	0685                	addi	a3,a3,1
 594:	fec7f1e3          	bgeu	a5,a2,576 <printint+0x2a>
  if(neg)
 598:	00030c63          	beqz	t1,5b0 <printint+0x64>
    buf[i++] = '-';
 59c:	fd050793          	addi	a5,a0,-48
 5a0:	00878533          	add	a0,a5,s0
 5a4:	02d00793          	li	a5,45
 5a8:	fef50423          	sb	a5,-24(a0)
 5ac:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 5b0:	02e05563          	blez	a4,5da <printint+0x8e>
 5b4:	fc26                	sd	s1,56(sp)
 5b6:	377d                	addiw	a4,a4,-1
 5b8:	00e984b3          	add	s1,s3,a4
 5bc:	19fd                	addi	s3,s3,-1
 5be:	99ba                	add	s3,s3,a4
 5c0:	1702                	slli	a4,a4,0x20
 5c2:	9301                	srli	a4,a4,0x20
 5c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5c8:	0004c583          	lbu	a1,0(s1)
 5cc:	854a                	mv	a0,s2
 5ce:	f61ff0ef          	jal	52e <putc>
  while(--i >= 0)
 5d2:	14fd                	addi	s1,s1,-1
 5d4:	ff349ae3          	bne	s1,s3,5c8 <printint+0x7c>
 5d8:	74e2                	ld	s1,56(sp)
}
 5da:	60a6                	ld	ra,72(sp)
 5dc:	6406                	ld	s0,64(sp)
 5de:	7942                	ld	s2,48(sp)
 5e0:	79a2                	ld	s3,40(sp)
 5e2:	6161                	addi	sp,sp,80
 5e4:	8082                	ret
  neg = 0;
 5e6:	4301                	li	t1,0
 5e8:	bfbd                	j	566 <printint+0x1a>

00000000000005ea <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ea:	711d                	addi	sp,sp,-96
 5ec:	ec86                	sd	ra,88(sp)
 5ee:	e8a2                	sd	s0,80(sp)
 5f0:	e4a6                	sd	s1,72(sp)
 5f2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f4:	0005c483          	lbu	s1,0(a1)
 5f8:	22048363          	beqz	s1,81e <vprintf+0x234>
 5fc:	e0ca                	sd	s2,64(sp)
 5fe:	fc4e                	sd	s3,56(sp)
 600:	f852                	sd	s4,48(sp)
 602:	f456                	sd	s5,40(sp)
 604:	f05a                	sd	s6,32(sp)
 606:	ec5e                	sd	s7,24(sp)
 608:	e862                	sd	s8,16(sp)
 60a:	8b2a                	mv	s6,a0
 60c:	8a2e                	mv	s4,a1
 60e:	8bb2                	mv	s7,a2
  state = 0;
 610:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 612:	4901                	li	s2,0
 614:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 616:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 61a:	06400c13          	li	s8,100
 61e:	a00d                	j	640 <vprintf+0x56>
        putc(fd, c0);
 620:	85a6                	mv	a1,s1
 622:	855a                	mv	a0,s6
 624:	f0bff0ef          	jal	52e <putc>
 628:	a019                	j	62e <vprintf+0x44>
    } else if(state == '%'){
 62a:	03598363          	beq	s3,s5,650 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 62e:	0019079b          	addiw	a5,s2,1
 632:	893e                	mv	s2,a5
 634:	873e                	mv	a4,a5
 636:	97d2                	add	a5,a5,s4
 638:	0007c483          	lbu	s1,0(a5)
 63c:	1c048a63          	beqz	s1,810 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 640:	0004879b          	sext.w	a5,s1
    if(state == 0){
 644:	fe0993e3          	bnez	s3,62a <vprintf+0x40>
      if(c0 == '%'){
 648:	fd579ce3          	bne	a5,s5,620 <vprintf+0x36>
        state = '%';
 64c:	89be                	mv	s3,a5
 64e:	b7c5                	j	62e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 650:	00ea06b3          	add	a3,s4,a4
 654:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 658:	1c060863          	beqz	a2,828 <vprintf+0x23e>
      if(c0 == 'd'){
 65c:	03878763          	beq	a5,s8,68a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 660:	f9478693          	addi	a3,a5,-108
 664:	0016b693          	seqz	a3,a3
 668:	f9c60593          	addi	a1,a2,-100
 66c:	e99d                	bnez	a1,6a2 <vprintf+0xb8>
 66e:	ca95                	beqz	a3,6a2 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 670:	008b8493          	addi	s1,s7,8
 674:	4685                	li	a3,1
 676:	4629                	li	a2,10
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	ecfff0ef          	jal	54c <printint>
        i += 1;
 682:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 686:	4981                	li	s3,0
 688:	b75d                	j	62e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 68a:	008b8493          	addi	s1,s7,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000ba583          	lw	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	eb5ff0ef          	jal	54c <printint>
 69c:	8ba6                	mv	s7,s1
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b779                	j	62e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 6a2:	9752                	add	a4,a4,s4
 6a4:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6a8:	f9460713          	addi	a4,a2,-108
 6ac:	00173713          	seqz	a4,a4
 6b0:	8f75                	and	a4,a4,a3
 6b2:	f9c58513          	addi	a0,a1,-100
 6b6:	18051363          	bnez	a0,83c <vprintf+0x252>
 6ba:	18070163          	beqz	a4,83c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6be:	008b8493          	addi	s1,s7,8
 6c2:	4685                	li	a3,1
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	e81ff0ef          	jal	54c <printint>
        i += 2;
 6d0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	8ba6                	mv	s7,s1
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	bfa1                	j	62e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6d8:	008b8493          	addi	s1,s7,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000be583          	lwu	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	e67ff0ef          	jal	54c <printint>
 6ea:	8ba6                	mv	s7,s1
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b781                	j	62e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	008b8493          	addi	s1,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4629                	li	a2,10
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	e4fff0ef          	jal	54c <printint>
        i += 1;
 702:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 704:	8ba6                	mv	s7,s1
      state = 0;
 706:	4981                	li	s3,0
 708:	b71d                	j	62e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b8493          	addi	s1,s7,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	e35ff0ef          	jal	54c <printint>
        i += 2;
 71c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	8ba6                	mv	s7,s1
      state = 0;
 720:	4981                	li	s3,0
        i += 2;
 722:	b731                	j	62e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 724:	008b8493          	addi	s1,s7,8
 728:	4681                	li	a3,0
 72a:	4641                	li	a2,16
 72c:	000be583          	lwu	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	e1bff0ef          	jal	54c <printint>
 736:	8ba6                	mv	s7,s1
      state = 0;
 738:	4981                	li	s3,0
 73a:	bdd5                	j	62e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 73c:	008b8493          	addi	s1,s7,8
 740:	4681                	li	a3,0
 742:	4641                	li	a2,16
 744:	000bb583          	ld	a1,0(s7)
 748:	855a                	mv	a0,s6
 74a:	e03ff0ef          	jal	54c <printint>
        i += 1;
 74e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 750:	8ba6                	mv	s7,s1
      state = 0;
 752:	4981                	li	s3,0
 754:	bde9                	j	62e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 756:	008b8493          	addi	s1,s7,8
 75a:	4681                	li	a3,0
 75c:	4641                	li	a2,16
 75e:	000bb583          	ld	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	de9ff0ef          	jal	54c <printint>
        i += 2;
 768:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	8ba6                	mv	s7,s1
      state = 0;
 76c:	4981                	li	s3,0
        i += 2;
 76e:	b5c1                	j	62e <vprintf+0x44>
 770:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 772:	008b8793          	addi	a5,s7,8
 776:	8cbe                	mv	s9,a5
 778:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 77c:	03000593          	li	a1,48
 780:	855a                	mv	a0,s6
 782:	dadff0ef          	jal	52e <putc>
  putc(fd, 'x');
 786:	07800593          	li	a1,120
 78a:	855a                	mv	a0,s6
 78c:	da3ff0ef          	jal	52e <putc>
 790:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 792:	00000b97          	auipc	s7,0x0
 796:	596b8b93          	addi	s7,s7,1430 # d28 <digits>
 79a:	03c9d793          	srli	a5,s3,0x3c
 79e:	97de                	add	a5,a5,s7
 7a0:	0007c583          	lbu	a1,0(a5)
 7a4:	855a                	mv	a0,s6
 7a6:	d89ff0ef          	jal	52e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7aa:	0992                	slli	s3,s3,0x4
 7ac:	34fd                	addiw	s1,s1,-1
 7ae:	f4f5                	bnez	s1,79a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7b0:	8be6                	mv	s7,s9
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	6ca2                	ld	s9,8(sp)
 7b6:	bda5                	j	62e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7b8:	008b8493          	addi	s1,s7,8
 7bc:	000bc583          	lbu	a1,0(s7)
 7c0:	855a                	mv	a0,s6
 7c2:	d6dff0ef          	jal	52e <putc>
 7c6:	8ba6                	mv	s7,s1
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	b595                	j	62e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7cc:	008b8993          	addi	s3,s7,8
 7d0:	000bb483          	ld	s1,0(s7)
 7d4:	cc91                	beqz	s1,7f0 <vprintf+0x206>
        for(; *s; s++)
 7d6:	0004c583          	lbu	a1,0(s1)
 7da:	c985                	beqz	a1,80a <vprintf+0x220>
          putc(fd, *s);
 7dc:	855a                	mv	a0,s6
 7de:	d51ff0ef          	jal	52e <putc>
        for(; *s; s++)
 7e2:	0485                	addi	s1,s1,1
 7e4:	0004c583          	lbu	a1,0(s1)
 7e8:	f9f5                	bnez	a1,7dc <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7ea:	8bce                	mv	s7,s3
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b581                	j	62e <vprintf+0x44>
          s = "(null)";
 7f0:	00000497          	auipc	s1,0x0
 7f4:	53048493          	addi	s1,s1,1328 # d20 <malloc+0x394>
        for(; *s; s++)
 7f8:	02800593          	li	a1,40
 7fc:	b7c5                	j	7dc <vprintf+0x1f2>
        putc(fd, '%');
 7fe:	85be                	mv	a1,a5
 800:	855a                	mv	a0,s6
 802:	d2dff0ef          	jal	52e <putc>
      state = 0;
 806:	4981                	li	s3,0
 808:	b51d                	j	62e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 80a:	8bce                	mv	s7,s3
      state = 0;
 80c:	4981                	li	s3,0
 80e:	b505                	j	62e <vprintf+0x44>
 810:	6906                	ld	s2,64(sp)
 812:	79e2                	ld	s3,56(sp)
 814:	7a42                	ld	s4,48(sp)
 816:	7aa2                	ld	s5,40(sp)
 818:	7b02                	ld	s6,32(sp)
 81a:	6be2                	ld	s7,24(sp)
 81c:	6c42                	ld	s8,16(sp)
    }
  }
}
 81e:	60e6                	ld	ra,88(sp)
 820:	6446                	ld	s0,80(sp)
 822:	64a6                	ld	s1,72(sp)
 824:	6125                	addi	sp,sp,96
 826:	8082                	ret
      if(c0 == 'd'){
 828:	06400713          	li	a4,100
 82c:	e4e78fe3          	beq	a5,a4,68a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 830:	f9478693          	addi	a3,a5,-108
 834:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 838:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 83a:	4701                	li	a4,0
      } else if(c0 == 'u'){
 83c:	07500513          	li	a0,117
 840:	e8a78ce3          	beq	a5,a0,6d8 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 844:	f8b60513          	addi	a0,a2,-117
 848:	e119                	bnez	a0,84e <vprintf+0x264>
 84a:	ea0693e3          	bnez	a3,6f0 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 84e:	f8b58513          	addi	a0,a1,-117
 852:	e119                	bnez	a0,858 <vprintf+0x26e>
 854:	ea071be3          	bnez	a4,70a <vprintf+0x120>
      } else if(c0 == 'x'){
 858:	07800513          	li	a0,120
 85c:	eca784e3          	beq	a5,a0,724 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 860:	f8860613          	addi	a2,a2,-120
 864:	e219                	bnez	a2,86a <vprintf+0x280>
 866:	ec069be3          	bnez	a3,73c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 86a:	f8858593          	addi	a1,a1,-120
 86e:	e199                	bnez	a1,874 <vprintf+0x28a>
 870:	ee0713e3          	bnez	a4,756 <vprintf+0x16c>
      } else if(c0 == 'p'){
 874:	07000713          	li	a4,112
 878:	eee78ce3          	beq	a5,a4,770 <vprintf+0x186>
      } else if(c0 == 'c'){
 87c:	06300713          	li	a4,99
 880:	f2e78ce3          	beq	a5,a4,7b8 <vprintf+0x1ce>
      } else if(c0 == 's'){
 884:	07300713          	li	a4,115
 888:	f4e782e3          	beq	a5,a4,7cc <vprintf+0x1e2>
      } else if(c0 == '%'){
 88c:	02500713          	li	a4,37
 890:	f6e787e3          	beq	a5,a4,7fe <vprintf+0x214>
        putc(fd, '%');
 894:	02500593          	li	a1,37
 898:	855a                	mv	a0,s6
 89a:	c95ff0ef          	jal	52e <putc>
        putc(fd, c0);
 89e:	85a6                	mv	a1,s1
 8a0:	855a                	mv	a0,s6
 8a2:	c8dff0ef          	jal	52e <putc>
      state = 0;
 8a6:	4981                	li	s3,0
 8a8:	b359                	j	62e <vprintf+0x44>

00000000000008aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8aa:	715d                	addi	sp,sp,-80
 8ac:	ec06                	sd	ra,24(sp)
 8ae:	e822                	sd	s0,16(sp)
 8b0:	1000                	addi	s0,sp,32
 8b2:	e010                	sd	a2,0(s0)
 8b4:	e414                	sd	a3,8(s0)
 8b6:	e818                	sd	a4,16(s0)
 8b8:	ec1c                	sd	a5,24(s0)
 8ba:	03043023          	sd	a6,32(s0)
 8be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8c2:	8622                	mv	a2,s0
 8c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8c8:	d23ff0ef          	jal	5ea <vprintf>
}
 8cc:	60e2                	ld	ra,24(sp)
 8ce:	6442                	ld	s0,16(sp)
 8d0:	6161                	addi	sp,sp,80
 8d2:	8082                	ret

00000000000008d4 <printf>:

void
printf(const char *fmt, ...)
{
 8d4:	711d                	addi	sp,sp,-96
 8d6:	ec06                	sd	ra,24(sp)
 8d8:	e822                	sd	s0,16(sp)
 8da:	1000                	addi	s0,sp,32
 8dc:	e40c                	sd	a1,8(s0)
 8de:	e810                	sd	a2,16(s0)
 8e0:	ec14                	sd	a3,24(s0)
 8e2:	f018                	sd	a4,32(s0)
 8e4:	f41c                	sd	a5,40(s0)
 8e6:	03043823          	sd	a6,48(s0)
 8ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ee:	00840613          	addi	a2,s0,8
 8f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8f6:	85aa                	mv	a1,a0
 8f8:	4505                	li	a0,1
 8fa:	cf1ff0ef          	jal	5ea <vprintf>
}
 8fe:	60e2                	ld	ra,24(sp)
 900:	6442                	ld	s0,16(sp)
 902:	6125                	addi	sp,sp,96
 904:	8082                	ret

0000000000000906 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 906:	1141                	addi	sp,sp,-16
 908:	e406                	sd	ra,8(sp)
 90a:	e022                	sd	s0,0(sp)
 90c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 90e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 912:	00000797          	auipc	a5,0x0
 916:	6ee7b783          	ld	a5,1774(a5) # 1000 <freep>
 91a:	a039                	j	928 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91c:	6398                	ld	a4,0(a5)
 91e:	00e7e463          	bltu	a5,a4,926 <free+0x20>
 922:	00e6ea63          	bltu	a3,a4,936 <free+0x30>
{
 926:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 928:	fed7fae3          	bgeu	a5,a3,91c <free+0x16>
 92c:	6398                	ld	a4,0(a5)
 92e:	00e6e463          	bltu	a3,a4,936 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 932:	fee7eae3          	bltu	a5,a4,926 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 936:	ff852583          	lw	a1,-8(a0)
 93a:	6390                	ld	a2,0(a5)
 93c:	02059813          	slli	a6,a1,0x20
 940:	01c85713          	srli	a4,a6,0x1c
 944:	9736                	add	a4,a4,a3
 946:	02e60563          	beq	a2,a4,970 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 94a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 94e:	4790                	lw	a2,8(a5)
 950:	02061593          	slli	a1,a2,0x20
 954:	01c5d713          	srli	a4,a1,0x1c
 958:	973e                	add	a4,a4,a5
 95a:	02e68263          	beq	a3,a4,97e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 95e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 960:	00000717          	auipc	a4,0x0
 964:	6af73023          	sd	a5,1696(a4) # 1000 <freep>
}
 968:	60a2                	ld	ra,8(sp)
 96a:	6402                	ld	s0,0(sp)
 96c:	0141                	addi	sp,sp,16
 96e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 970:	4618                	lw	a4,8(a2)
 972:	9f2d                	addw	a4,a4,a1
 974:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 978:	6398                	ld	a4,0(a5)
 97a:	6310                	ld	a2,0(a4)
 97c:	b7f9                	j	94a <free+0x44>
    p->s.size += bp->s.size;
 97e:	ff852703          	lw	a4,-8(a0)
 982:	9f31                	addw	a4,a4,a2
 984:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 986:	ff053683          	ld	a3,-16(a0)
 98a:	bfd1                	j	95e <free+0x58>

000000000000098c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 98c:	7139                	addi	sp,sp,-64
 98e:	fc06                	sd	ra,56(sp)
 990:	f822                	sd	s0,48(sp)
 992:	f04a                	sd	s2,32(sp)
 994:	ec4e                	sd	s3,24(sp)
 996:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 998:	02051993          	slli	s3,a0,0x20
 99c:	0209d993          	srli	s3,s3,0x20
 9a0:	09bd                	addi	s3,s3,15
 9a2:	0049d993          	srli	s3,s3,0x4
 9a6:	2985                	addiw	s3,s3,1
 9a8:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 9aa:	00000517          	auipc	a0,0x0
 9ae:	65653503          	ld	a0,1622(a0) # 1000 <freep>
 9b2:	c905                	beqz	a0,9e2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b6:	4798                	lw	a4,8(a5)
 9b8:	09377663          	bgeu	a4,s3,a44 <malloc+0xb8>
 9bc:	f426                	sd	s1,40(sp)
 9be:	e852                	sd	s4,16(sp)
 9c0:	e456                	sd	s5,8(sp)
 9c2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9c4:	8a4e                	mv	s4,s3
 9c6:	6705                	lui	a4,0x1
 9c8:	00e9f363          	bgeu	s3,a4,9ce <malloc+0x42>
 9cc:	6a05                	lui	s4,0x1
 9ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9d2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9d6:	00000497          	auipc	s1,0x0
 9da:	62a48493          	addi	s1,s1,1578 # 1000 <freep>
  if(p == SBRK_ERROR)
 9de:	5afd                	li	s5,-1
 9e0:	a83d                	j	a1e <malloc+0x92>
 9e2:	f426                	sd	s1,40(sp)
 9e4:	e852                	sd	s4,16(sp)
 9e6:	e456                	sd	s5,8(sp)
 9e8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9ea:	00000797          	auipc	a5,0x0
 9ee:	62678793          	addi	a5,a5,1574 # 1010 <base>
 9f2:	00000717          	auipc	a4,0x0
 9f6:	60f73723          	sd	a5,1550(a4) # 1000 <freep>
 9fa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9fc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a00:	b7d1                	j	9c4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a02:	6398                	ld	a4,0(a5)
 a04:	e118                	sd	a4,0(a0)
 a06:	a899                	j	a5c <malloc+0xd0>
  hp->s.size = nu;
 a08:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a0c:	0541                	addi	a0,a0,16
 a0e:	ef9ff0ef          	jal	906 <free>
  return freep;
 a12:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a14:	c125                	beqz	a0,a74 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a16:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a18:	4798                	lw	a4,8(a5)
 a1a:	03277163          	bgeu	a4,s2,a3c <malloc+0xb0>
    if(p == freep)
 a1e:	6098                	ld	a4,0(s1)
 a20:	853e                	mv	a0,a5
 a22:	fef71ae3          	bne	a4,a5,a16 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a26:	8552                	mv	a0,s4
 a28:	a23ff0ef          	jal	44a <sbrk>
  if(p == SBRK_ERROR)
 a2c:	fd551ee3          	bne	a0,s5,a08 <malloc+0x7c>
        return 0;
 a30:	4501                	li	a0,0
 a32:	74a2                	ld	s1,40(sp)
 a34:	6a42                	ld	s4,16(sp)
 a36:	6aa2                	ld	s5,8(sp)
 a38:	6b02                	ld	s6,0(sp)
 a3a:	a03d                	j	a68 <malloc+0xdc>
 a3c:	74a2                	ld	s1,40(sp)
 a3e:	6a42                	ld	s4,16(sp)
 a40:	6aa2                	ld	s5,8(sp)
 a42:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a44:	fae90fe3          	beq	s2,a4,a02 <malloc+0x76>
        p->s.size -= nunits;
 a48:	4137073b          	subw	a4,a4,s3
 a4c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a4e:	02071693          	slli	a3,a4,0x20
 a52:	01c6d713          	srli	a4,a3,0x1c
 a56:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a58:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a5c:	00000717          	auipc	a4,0x0
 a60:	5aa73223          	sd	a0,1444(a4) # 1000 <freep>
      return (void*)(p + 1);
 a64:	01078513          	addi	a0,a5,16
  }
}
 a68:	70e2                	ld	ra,56(sp)
 a6a:	7442                	ld	s0,48(sp)
 a6c:	7902                	ld	s2,32(sp)
 a6e:	69e2                	ld	s3,24(sp)
 a70:	6121                	addi	sp,sp,64
 a72:	8082                	ret
 a74:	74a2                	ld	s1,40(sp)
 a76:	6a42                	ld	s4,16(sp)
 a78:	6aa2                	ld	s5,8(sp)
 a7a:	6b02                	ld	s6,0(sp)
 a7c:	b7f5                	j	a68 <malloc+0xdc>
