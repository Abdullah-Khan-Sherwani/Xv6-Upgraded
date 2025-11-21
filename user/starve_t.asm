
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
  14:	1880                	addi	s0,sp,112
  int pids[3];
  int num_procs = 3;
  
  printf("=== Starvation Prevention Test (Week 3) ===\n");
  16:	00001517          	auipc	a0,0x1
  1a:	9ca50513          	addi	a0,a0,-1590 # 9e0 <malloc+0xdc>
  1e:	02d000ef          	jal	ra,84a <printf>
  printf("Testing automatic priority boosting every 100 ticks\n");
  22:	00001517          	auipc	a0,0x1
  26:	9ee50513          	addi	a0,a0,-1554 # a10 <malloc+0x10c>
  2a:	021000ef          	jal	ra,84a <printf>
  printf("Running %d CPU-bound processes concurrently\n", num_procs);
  2e:	458d                	li	a1,3
  30:	00001517          	auipc	a0,0x1
  34:	a1850513          	addi	a0,a0,-1512 # a48 <malloc+0x144>
  38:	013000ef          	jal	ra,84a <printf>
  printf("All processes should get CPU time due to periodic boosting\n\n");
  3c:	00001517          	auipc	a0,0x1
  40:	a3c50513          	addi	a0,a0,-1476 # a78 <malloc+0x174>
  44:	007000ef          	jal	ra,84a <printf>
  
  // Fork multiple CPU-bound processes
  for(int i = 0; i < num_procs; i++) {
  48:	4b01                	li	s6,0
  4a:	448d                	li	s1,3
    pids[i] = fork();
  4c:	3ca000ef          	jal	ra,416 <fork>
  50:	89aa                	mv	s3,a0
    
    if(pids[i] == 0) {
  52:	c541                	beqz	a0,da <main+0xda>
      
      exit(0);
    }
    
    // Small delay between forks
    pause(1);
  54:	4505                	li	a0,1
  56:	458000ef          	jal	ra,4ae <pause>
  for(int i = 0; i < num_procs; i++) {
  5a:	2b05                	addiw	s6,s6,1
  5c:	fe9b18e3          	bne	s6,s1,4c <main+0x4c>
  }
  
  // Parent waits for all children
  printf("\n[Parent] Waiting for all processes to complete...\n");
  60:	00001517          	auipc	a0,0x1
  64:	ad050513          	addi	a0,a0,-1328 # b30 <malloc+0x22c>
  68:	7e2000ef          	jal	ra,84a <printf>
  for(int i = 0; i < num_procs; i++) {
  6c:	4481                	li	s1,0
    wait(0);
    printf("[Parent] Process %d finished\n", i);
  6e:	00001997          	auipc	s3,0x1
  72:	afa98993          	addi	s3,s3,-1286 # b68 <malloc+0x264>
  for(int i = 0; i < num_procs; i++) {
  76:	490d                	li	s2,3
    wait(0);
  78:	4501                	li	a0,0
  7a:	3ac000ef          	jal	ra,426 <wait>
    printf("[Parent] Process %d finished\n", i);
  7e:	85a6                	mv	a1,s1
  80:	854e                	mv	a0,s3
  82:	7c8000ef          	jal	ra,84a <printf>
  for(int i = 0; i < num_procs; i++) {
  86:	2485                	addiw	s1,s1,1
  88:	ff2498e3          	bne	s1,s2,78 <main+0x78>
  }
  
  printf("\n=== Starvation Test Complete ===\n");
  8c:	00001517          	auipc	a0,0x1
  90:	afc50513          	addi	a0,a0,-1284 # b88 <malloc+0x284>
  94:	7b6000ef          	jal	ra,84a <printf>
  printf("Analysis:\n");
  98:	00001517          	auipc	a0,0x1
  9c:	b1850513          	addi	a0,a0,-1256 # bb0 <malloc+0x2ac>
  a0:	7aa000ef          	jal	ra,84a <printf>
  printf("  - All processes should have completed\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	b1c50513          	addi	a0,a0,-1252 # bc0 <malloc+0x2bc>
  ac:	79e000ef          	jal	ra,84a <printf>
  printf("  - Processes should have been boosted to Q0 every ~100 ticks\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	b4050513          	addi	a0,a0,-1216 # bf0 <malloc+0x2ec>
  b8:	792000ef          	jal	ra,84a <printf>
  printf("  - Even low-priority processes got CPU time\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	b7450513          	addi	a0,a0,-1164 # c30 <malloc+0x32c>
  c4:	786000ef          	jal	ra,84a <printf>
  printf("  - No process was starved!\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	b9850513          	addi	a0,a0,-1128 # c60 <malloc+0x35c>
  d0:	77a000ef          	jal	ra,84a <printf>
  
  exit(0);
  d4:	4501                	li	a0,0
  d6:	348000ef          	jal	ra,41e <exit>
      volatile int dummy = 0;
  da:	f8042e23          	sw	zero,-100(s0)
      printf("[Process %d] Started (PID=%d)\n", my_id, getpid());
  de:	3c0000ef          	jal	ra,49e <getpid>
  e2:	862a                	mv	a2,a0
  e4:	85da                	mv	a1,s6
  e6:	00001517          	auipc	a0,0x1
  ea:	9d250513          	addi	a0,a0,-1582 # ab8 <malloc+0x1b4>
  ee:	75c000ef          	jal	ra,84a <printf>
          dummy = dummy % 1000000;
  f2:	000f4937          	lui	s2,0xf4
  f6:	2409091b          	addiw	s2,s2,576
        for(long j = 0; j < 5000000; j++) {
  fa:	004c54b7          	lui	s1,0x4c5
  fe:	b4048493          	addi	s1,s1,-1216 # 4c4b40 <base+0x4c3b30>
        if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 102:	4abd                	li	s5,15
          printf("[Process %d] Tick %d: Q%d (slices=%d)\n", 
 104:	00001b97          	auipc	s7,0x1
 108:	9d4b8b93          	addi	s7,s7,-1580 # ad8 <malloc+0x1d4>
      for(int iter = 0; iter < 60; iter++) {
 10c:	03c00a13          	li	s4,60
 110:	a021                	j	118 <main+0x118>
 112:	2985                	addiw	s3,s3,1
 114:	05498563          	beq	s3,s4,15e <main+0x15e>
        for(long j = 0; j < 5000000; j++) {
 118:	4781                	li	a5,0
          dummy = dummy + j;
 11a:	f9c42703          	lw	a4,-100(s0)
 11e:	9f3d                	addw	a4,a4,a5
 120:	f8e42e23          	sw	a4,-100(s0)
          dummy = dummy % 1000000;
 124:	f9c42703          	lw	a4,-100(s0)
 128:	0327673b          	remw	a4,a4,s2
 12c:	f8e42e23          	sw	a4,-100(s0)
        for(long j = 0; j < 5000000; j++) {
 130:	0785                	addi	a5,a5,1
 132:	fe9794e3          	bne	a5,s1,11a <main+0x11a>
        if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 136:	0359e7bb          	remw	a5,s3,s5
 13a:	ffe1                	bnez	a5,112 <main+0x112>
 13c:	fa040513          	addi	a0,s0,-96
 140:	37e000ef          	jal	ra,4be <getprocinfo>
 144:	f579                	bnez	a0,112 <main+0x112>
          int current_ticks = uptime();
 146:	370000ef          	jal	ra,4b6 <uptime>
 14a:	862a                	mv	a2,a0
          printf("[Process %d] Tick %d: Q%d (slices=%d)\n", 
 14c:	fac42703          	lw	a4,-84(s0)
 150:	fa842683          	lw	a3,-88(s0)
 154:	85da                	mv	a1,s6
 156:	855e                	mv	a0,s7
 158:	6f2000ef          	jal	ra,84a <printf>
 15c:	bf5d                	j	112 <main+0x112>
      if(getprocinfo(&info) == 0) {
 15e:	fa040513          	addi	a0,s0,-96
 162:	35c000ef          	jal	ra,4be <getprocinfo>
 166:	c501                	beqz	a0,16e <main+0x16e>
      exit(0);
 168:	4501                	li	a0,0
 16a:	2b4000ef          	jal	ra,41e <exit>
        printf("[Process %d] COMPLETED at tick %d: Final Q%d\n", 
 16e:	348000ef          	jal	ra,4b6 <uptime>
 172:	862a                	mv	a2,a0
 174:	fa842683          	lw	a3,-88(s0)
 178:	85da                	mv	a1,s6
 17a:	00001517          	auipc	a0,0x1
 17e:	98650513          	addi	a0,a0,-1658 # b00 <malloc+0x1fc>
 182:	6c8000ef          	jal	ra,84a <printf>
 186:	b7cd                	j	168 <main+0x168>

0000000000000188 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e406                	sd	ra,8(sp)
 18c:	e022                	sd	s0,0(sp)
 18e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 190:	e71ff0ef          	jal	ra,0 <main>
  exit(r);
 194:	28a000ef          	jal	ra,41e <exit>

0000000000000198 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19e:	87aa                	mv	a5,a0
 1a0:	0585                	addi	a1,a1,1
 1a2:	0785                	addi	a5,a5,1
 1a4:	fff5c703          	lbu	a4,-1(a1)
 1a8:	fee78fa3          	sb	a4,-1(a5)
 1ac:	fb75                	bnez	a4,1a0 <strcpy+0x8>
    ;
  return os;
}
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cb91                	beqz	a5,1d2 <strcmp+0x1e>
 1c0:	0005c703          	lbu	a4,0(a1)
 1c4:	00f71763          	bne	a4,a5,1d2 <strcmp+0x1e>
    p++, q++;
 1c8:	0505                	addi	a0,a0,1
 1ca:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	fbe5                	bnez	a5,1c0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d2:	0005c503          	lbu	a0,0(a1)
}
 1d6:	40a7853b          	subw	a0,a5,a0
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret

00000000000001e0 <strlen>:

uint
strlen(const char *s)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e6:	00054783          	lbu	a5,0(a0)
 1ea:	cf91                	beqz	a5,206 <strlen+0x26>
 1ec:	0505                	addi	a0,a0,1
 1ee:	87aa                	mv	a5,a0
 1f0:	4685                	li	a3,1
 1f2:	9e89                	subw	a3,a3,a0
 1f4:	00f6853b          	addw	a0,a3,a5
 1f8:	0785                	addi	a5,a5,1
 1fa:	fff7c703          	lbu	a4,-1(a5)
 1fe:	fb7d                	bnez	a4,1f4 <strlen+0x14>
    ;
  return n;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
  for(n = 0; s[n]; n++)
 206:	4501                	li	a0,0
 208:	bfe5                	j	200 <strlen+0x20>

000000000000020a <memset>:

void*
memset(void *dst, int c, uint n)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 210:	ca19                	beqz	a2,226 <memset+0x1c>
 212:	87aa                	mv	a5,a0
 214:	1602                	slli	a2,a2,0x20
 216:	9201                	srli	a2,a2,0x20
 218:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 220:	0785                	addi	a5,a5,1
 222:	fee79de3          	bne	a5,a4,21c <memset+0x12>
  }
  return dst;
}
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret

000000000000022c <strchr>:

char*
strchr(const char *s, char c)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  for(; *s; s++)
 232:	00054783          	lbu	a5,0(a0)
 236:	cb99                	beqz	a5,24c <strchr+0x20>
    if(*s == c)
 238:	00f58763          	beq	a1,a5,246 <strchr+0x1a>
  for(; *s; s++)
 23c:	0505                	addi	a0,a0,1
 23e:	00054783          	lbu	a5,0(a0)
 242:	fbfd                	bnez	a5,238 <strchr+0xc>
      return (char*)s;
  return 0;
 244:	4501                	li	a0,0
}
 246:	6422                	ld	s0,8(sp)
 248:	0141                	addi	sp,sp,16
 24a:	8082                	ret
  return 0;
 24c:	4501                	li	a0,0
 24e:	bfe5                	j	246 <strchr+0x1a>

0000000000000250 <gets>:

char*
gets(char *buf, int max)
{
 250:	711d                	addi	sp,sp,-96
 252:	ec86                	sd	ra,88(sp)
 254:	e8a2                	sd	s0,80(sp)
 256:	e4a6                	sd	s1,72(sp)
 258:	e0ca                	sd	s2,64(sp)
 25a:	fc4e                	sd	s3,56(sp)
 25c:	f852                	sd	s4,48(sp)
 25e:	f456                	sd	s5,40(sp)
 260:	f05a                	sd	s6,32(sp)
 262:	ec5e                	sd	s7,24(sp)
 264:	1080                	addi	s0,sp,96
 266:	8baa                	mv	s7,a0
 268:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26a:	892a                	mv	s2,a0
 26c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26e:	4aa9                	li	s5,10
 270:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 272:	89a6                	mv	s3,s1
 274:	2485                	addiw	s1,s1,1
 276:	0344d663          	bge	s1,s4,2a2 <gets+0x52>
    cc = read(0, &c, 1);
 27a:	4605                	li	a2,1
 27c:	faf40593          	addi	a1,s0,-81
 280:	4501                	li	a0,0
 282:	1b4000ef          	jal	ra,436 <read>
    if(cc < 1)
 286:	00a05e63          	blez	a0,2a2 <gets+0x52>
    buf[i++] = c;
 28a:	faf44783          	lbu	a5,-81(s0)
 28e:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 292:	01578763          	beq	a5,s5,2a0 <gets+0x50>
 296:	0905                	addi	s2,s2,1
 298:	fd679de3          	bne	a5,s6,272 <gets+0x22>
  for(i=0; i+1 < max; ){
 29c:	89a6                	mv	s3,s1
 29e:	a011                	j	2a2 <gets+0x52>
 2a0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a2:	99de                	add	s3,s3,s7
 2a4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a8:	855e                	mv	a0,s7
 2aa:	60e6                	ld	ra,88(sp)
 2ac:	6446                	ld	s0,80(sp)
 2ae:	64a6                	ld	s1,72(sp)
 2b0:	6906                	ld	s2,64(sp)
 2b2:	79e2                	ld	s3,56(sp)
 2b4:	7a42                	ld	s4,48(sp)
 2b6:	7aa2                	ld	s5,40(sp)
 2b8:	7b02                	ld	s6,32(sp)
 2ba:	6be2                	ld	s7,24(sp)
 2bc:	6125                	addi	sp,sp,96
 2be:	8082                	ret

00000000000002c0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c0:	1101                	addi	sp,sp,-32
 2c2:	ec06                	sd	ra,24(sp)
 2c4:	e822                	sd	s0,16(sp)
 2c6:	e426                	sd	s1,8(sp)
 2c8:	e04a                	sd	s2,0(sp)
 2ca:	1000                	addi	s0,sp,32
 2cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ce:	4581                	li	a1,0
 2d0:	18e000ef          	jal	ra,45e <open>
  if(fd < 0)
 2d4:	02054163          	bltz	a0,2f6 <stat+0x36>
 2d8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2da:	85ca                	mv	a1,s2
 2dc:	19a000ef          	jal	ra,476 <fstat>
 2e0:	892a                	mv	s2,a0
  close(fd);
 2e2:	8526                	mv	a0,s1
 2e4:	162000ef          	jal	ra,446 <close>
  return r;
}
 2e8:	854a                	mv	a0,s2
 2ea:	60e2                	ld	ra,24(sp)
 2ec:	6442                	ld	s0,16(sp)
 2ee:	64a2                	ld	s1,8(sp)
 2f0:	6902                	ld	s2,0(sp)
 2f2:	6105                	addi	sp,sp,32
 2f4:	8082                	ret
    return -1;
 2f6:	597d                	li	s2,-1
 2f8:	bfc5                	j	2e8 <stat+0x28>

00000000000002fa <atoi>:

int
atoi(const char *s)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 300:	00054603          	lbu	a2,0(a0)
 304:	fd06079b          	addiw	a5,a2,-48
 308:	0ff7f793          	andi	a5,a5,255
 30c:	4725                	li	a4,9
 30e:	02f76963          	bltu	a4,a5,340 <atoi+0x46>
 312:	86aa                	mv	a3,a0
  n = 0;
 314:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 316:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 318:	0685                	addi	a3,a3,1
 31a:	0025179b          	slliw	a5,a0,0x2
 31e:	9fa9                	addw	a5,a5,a0
 320:	0017979b          	slliw	a5,a5,0x1
 324:	9fb1                	addw	a5,a5,a2
 326:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 32a:	0006c603          	lbu	a2,0(a3)
 32e:	fd06071b          	addiw	a4,a2,-48
 332:	0ff77713          	andi	a4,a4,255
 336:	fee5f1e3          	bgeu	a1,a4,318 <atoi+0x1e>
  return n;
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
  n = 0;
 340:	4501                	li	a0,0
 342:	bfe5                	j	33a <atoi+0x40>

0000000000000344 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 344:	1141                	addi	sp,sp,-16
 346:	e422                	sd	s0,8(sp)
 348:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 34a:	02b57463          	bgeu	a0,a1,372 <memmove+0x2e>
    while(n-- > 0)
 34e:	00c05f63          	blez	a2,36c <memmove+0x28>
 352:	1602                	slli	a2,a2,0x20
 354:	9201                	srli	a2,a2,0x20
 356:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 35a:	872a                	mv	a4,a0
      *dst++ = *src++;
 35c:	0585                	addi	a1,a1,1
 35e:	0705                	addi	a4,a4,1
 360:	fff5c683          	lbu	a3,-1(a1)
 364:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret
    dst += n;
 372:	00c50733          	add	a4,a0,a2
    src += n;
 376:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 378:	fec05ae3          	blez	a2,36c <memmove+0x28>
 37c:	fff6079b          	addiw	a5,a2,-1
 380:	1782                	slli	a5,a5,0x20
 382:	9381                	srli	a5,a5,0x20
 384:	fff7c793          	not	a5,a5
 388:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 38a:	15fd                	addi	a1,a1,-1
 38c:	177d                	addi	a4,a4,-1
 38e:	0005c683          	lbu	a3,0(a1)
 392:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 396:	fee79ae3          	bne	a5,a4,38a <memmove+0x46>
 39a:	bfc9                	j	36c <memmove+0x28>

000000000000039c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e422                	sd	s0,8(sp)
 3a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a2:	ca05                	beqz	a2,3d2 <memcmp+0x36>
 3a4:	fff6069b          	addiw	a3,a2,-1
 3a8:	1682                	slli	a3,a3,0x20
 3aa:	9281                	srli	a3,a3,0x20
 3ac:	0685                	addi	a3,a3,1
 3ae:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b0:	00054783          	lbu	a5,0(a0)
 3b4:	0005c703          	lbu	a4,0(a1)
 3b8:	00e79863          	bne	a5,a4,3c8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3bc:	0505                	addi	a0,a0,1
    p2++;
 3be:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3c0:	fed518e3          	bne	a0,a3,3b0 <memcmp+0x14>
  }
  return 0;
 3c4:	4501                	li	a0,0
 3c6:	a019                	j	3cc <memcmp+0x30>
      return *p1 - *p2;
 3c8:	40e7853b          	subw	a0,a5,a4
}
 3cc:	6422                	ld	s0,8(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
  return 0;
 3d2:	4501                	li	a0,0
 3d4:	bfe5                	j	3cc <memcmp+0x30>

00000000000003d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e406                	sd	ra,8(sp)
 3da:	e022                	sd	s0,0(sp)
 3dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3de:	f67ff0ef          	jal	ra,344 <memmove>
}
 3e2:	60a2                	ld	ra,8(sp)
 3e4:	6402                	ld	s0,0(sp)
 3e6:	0141                	addi	sp,sp,16
 3e8:	8082                	ret

00000000000003ea <sbrk>:

char *
sbrk(int n) {
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e406                	sd	ra,8(sp)
 3ee:	e022                	sd	s0,0(sp)
 3f0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3f2:	4585                	li	a1,1
 3f4:	0b2000ef          	jal	ra,4a6 <sys_sbrk>
}
 3f8:	60a2                	ld	ra,8(sp)
 3fa:	6402                	ld	s0,0(sp)
 3fc:	0141                	addi	sp,sp,16
 3fe:	8082                	ret

0000000000000400 <sbrklazy>:

char *
sbrklazy(int n) {
 400:	1141                	addi	sp,sp,-16
 402:	e406                	sd	ra,8(sp)
 404:	e022                	sd	s0,0(sp)
 406:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 408:	4589                	li	a1,2
 40a:	09c000ef          	jal	ra,4a6 <sys_sbrk>
}
 40e:	60a2                	ld	ra,8(sp)
 410:	6402                	ld	s0,0(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret

0000000000000416 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 416:	4885                	li	a7,1
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <exit>:
.global exit
exit:
 li a7, SYS_exit
 41e:	4889                	li	a7,2
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <wait>:
.global wait
wait:
 li a7, SYS_wait
 426:	488d                	li	a7,3
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 42e:	4891                	li	a7,4
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <read>:
.global read
read:
 li a7, SYS_read
 436:	4895                	li	a7,5
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <write>:
.global write
write:
 li a7, SYS_write
 43e:	48c1                	li	a7,16
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <close>:
.global close
close:
 li a7, SYS_close
 446:	48d5                	li	a7,21
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <kill>:
.global kill
kill:
 li a7, SYS_kill
 44e:	4899                	li	a7,6
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <exec>:
.global exec
exec:
 li a7, SYS_exec
 456:	489d                	li	a7,7
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <open>:
.global open
open:
 li a7, SYS_open
 45e:	48bd                	li	a7,15
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 466:	48c5                	li	a7,17
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 46e:	48c9                	li	a7,18
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 476:	48a1                	li	a7,8
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <link>:
.global link
link:
 li a7, SYS_link
 47e:	48cd                	li	a7,19
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 486:	48d1                	li	a7,20
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 48e:	48a5                	li	a7,9
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <dup>:
.global dup
dup:
 li a7, SYS_dup
 496:	48a9                	li	a7,10
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 49e:	48ad                	li	a7,11
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4a6:	48b1                	li	a7,12
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <pause>:
.global pause
pause:
 li a7, SYS_pause
 4ae:	48b5                	li	a7,13
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b6:	48b9                	li	a7,14
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4be:	48d9                	li	a7,22
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4c6:	48dd                	li	a7,23
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ce:	1101                	addi	sp,sp,-32
 4d0:	ec06                	sd	ra,24(sp)
 4d2:	e822                	sd	s0,16(sp)
 4d4:	1000                	addi	s0,sp,32
 4d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4da:	4605                	li	a2,1
 4dc:	fef40593          	addi	a1,s0,-17
 4e0:	f5fff0ef          	jal	ra,43e <write>
}
 4e4:	60e2                	ld	ra,24(sp)
 4e6:	6442                	ld	s0,16(sp)
 4e8:	6105                	addi	sp,sp,32
 4ea:	8082                	ret

00000000000004ec <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ec:	715d                	addi	sp,sp,-80
 4ee:	e486                	sd	ra,72(sp)
 4f0:	e0a2                	sd	s0,64(sp)
 4f2:	fc26                	sd	s1,56(sp)
 4f4:	f84a                	sd	s2,48(sp)
 4f6:	f44e                	sd	s3,40(sp)
 4f8:	0880                	addi	s0,sp,80
 4fa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4fc:	c299                	beqz	a3,502 <printint+0x16>
 4fe:	0805c163          	bltz	a1,580 <printint+0x94>
  neg = 0;
 502:	4881                	li	a7,0
 504:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 508:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 50a:	00000517          	auipc	a0,0x0
 50e:	77e50513          	addi	a0,a0,1918 # c88 <digits>
 512:	883e                	mv	a6,a5
 514:	2785                	addiw	a5,a5,1
 516:	02c5f733          	remu	a4,a1,a2
 51a:	972a                	add	a4,a4,a0
 51c:	00074703          	lbu	a4,0(a4)
 520:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 524:	872e                	mv	a4,a1
 526:	02c5d5b3          	divu	a1,a1,a2
 52a:	0685                	addi	a3,a3,1
 52c:	fec773e3          	bgeu	a4,a2,512 <printint+0x26>
  if(neg)
 530:	00088b63          	beqz	a7,546 <printint+0x5a>
    buf[i++] = '-';
 534:	fd040713          	addi	a4,s0,-48
 538:	97ba                	add	a5,a5,a4
 53a:	02d00713          	li	a4,45
 53e:	fee78423          	sb	a4,-24(a5)
 542:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 546:	02f05663          	blez	a5,572 <printint+0x86>
 54a:	fb840713          	addi	a4,s0,-72
 54e:	00f704b3          	add	s1,a4,a5
 552:	fff70993          	addi	s3,a4,-1
 556:	99be                	add	s3,s3,a5
 558:	37fd                	addiw	a5,a5,-1
 55a:	1782                	slli	a5,a5,0x20
 55c:	9381                	srli	a5,a5,0x20
 55e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 562:	fff4c583          	lbu	a1,-1(s1)
 566:	854a                	mv	a0,s2
 568:	f67ff0ef          	jal	ra,4ce <putc>
  while(--i >= 0)
 56c:	14fd                	addi	s1,s1,-1
 56e:	ff349ae3          	bne	s1,s3,562 <printint+0x76>
}
 572:	60a6                	ld	ra,72(sp)
 574:	6406                	ld	s0,64(sp)
 576:	74e2                	ld	s1,56(sp)
 578:	7942                	ld	s2,48(sp)
 57a:	79a2                	ld	s3,40(sp)
 57c:	6161                	addi	sp,sp,80
 57e:	8082                	ret
    x = -xx;
 580:	40b005b3          	neg	a1,a1
    neg = 1;
 584:	4885                	li	a7,1
    x = -xx;
 586:	bfbd                	j	504 <printint+0x18>

0000000000000588 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 588:	7119                	addi	sp,sp,-128
 58a:	fc86                	sd	ra,120(sp)
 58c:	f8a2                	sd	s0,112(sp)
 58e:	f4a6                	sd	s1,104(sp)
 590:	f0ca                	sd	s2,96(sp)
 592:	ecce                	sd	s3,88(sp)
 594:	e8d2                	sd	s4,80(sp)
 596:	e4d6                	sd	s5,72(sp)
 598:	e0da                	sd	s6,64(sp)
 59a:	fc5e                	sd	s7,56(sp)
 59c:	f862                	sd	s8,48(sp)
 59e:	f466                	sd	s9,40(sp)
 5a0:	f06a                	sd	s10,32(sp)
 5a2:	ec6e                	sd	s11,24(sp)
 5a4:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a6:	0005c903          	lbu	s2,0(a1)
 5aa:	24090c63          	beqz	s2,802 <vprintf+0x27a>
 5ae:	8b2a                	mv	s6,a0
 5b0:	8a2e                	mv	s4,a1
 5b2:	8bb2                	mv	s7,a2
  state = 0;
 5b4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b6:	4481                	li	s1,0
 5b8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ba:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5be:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5c2:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5c6:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ca:	00000c97          	auipc	s9,0x0
 5ce:	6bec8c93          	addi	s9,s9,1726 # c88 <digits>
 5d2:	a005                	j	5f2 <vprintf+0x6a>
        putc(fd, c0);
 5d4:	85ca                	mv	a1,s2
 5d6:	855a                	mv	a0,s6
 5d8:	ef7ff0ef          	jal	ra,4ce <putc>
 5dc:	a019                	j	5e2 <vprintf+0x5a>
    } else if(state == '%'){
 5de:	03598263          	beq	s3,s5,602 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5e2:	2485                	addiw	s1,s1,1
 5e4:	8726                	mv	a4,s1
 5e6:	009a07b3          	add	a5,s4,s1
 5ea:	0007c903          	lbu	s2,0(a5)
 5ee:	20090a63          	beqz	s2,802 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5f2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f6:	fe0994e3          	bnez	s3,5de <vprintf+0x56>
      if(c0 == '%'){
 5fa:	fd579de3          	bne	a5,s5,5d4 <vprintf+0x4c>
        state = '%';
 5fe:	89be                	mv	s3,a5
 600:	b7cd                	j	5e2 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 602:	c3c1                	beqz	a5,682 <vprintf+0xfa>
 604:	00ea06b3          	add	a3,s4,a4
 608:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 60c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 60e:	c681                	beqz	a3,616 <vprintf+0x8e>
 610:	9752                	add	a4,a4,s4
 612:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 616:	03878e63          	beq	a5,s8,652 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 61a:	05a78863          	beq	a5,s10,66a <vprintf+0xe2>
      } else if(c0 == 'u'){
 61e:	0db78b63          	beq	a5,s11,6f4 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 622:	07800713          	li	a4,120
 626:	10e78d63          	beq	a5,a4,740 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 62a:	07000713          	li	a4,112
 62e:	14e78263          	beq	a5,a4,772 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 632:	06300713          	li	a4,99
 636:	16e78f63          	beq	a5,a4,7b4 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 63a:	07300713          	li	a4,115
 63e:	18e78563          	beq	a5,a4,7c8 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 642:	05579063          	bne	a5,s5,682 <vprintf+0xfa>
        putc(fd, '%');
 646:	85d6                	mv	a1,s5
 648:	855a                	mv	a0,s6
 64a:	e85ff0ef          	jal	ra,4ce <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 64e:	4981                	li	s3,0
 650:	bf49                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 652:	008b8913          	addi	s2,s7,8
 656:	4685                	li	a3,1
 658:	4629                	li	a2,10
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	e8dff0ef          	jal	ra,4ec <printint>
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bfad                	j	5e2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 66a:	03868663          	beq	a3,s8,696 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66e:	05a68163          	beq	a3,s10,6b0 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 672:	09b68d63          	beq	a3,s11,70c <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 676:	03a68f63          	beq	a3,s10,6b4 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 67a:	07800793          	li	a5,120
 67e:	0cf68d63          	beq	a3,a5,758 <vprintf+0x1d0>
        putc(fd, '%');
 682:	85d6                	mv	a1,s5
 684:	855a                	mv	a0,s6
 686:	e49ff0ef          	jal	ra,4ce <putc>
        putc(fd, c0);
 68a:	85ca                	mv	a1,s2
 68c:	855a                	mv	a0,s6
 68e:	e41ff0ef          	jal	ra,4ce <putc>
      state = 0;
 692:	4981                	li	s3,0
 694:	b7b9                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 696:	008b8913          	addi	s2,s7,8
 69a:	4685                	li	a3,1
 69c:	4629                	li	a2,10
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	e49ff0ef          	jal	ra,4ec <printint>
        i += 1;
 6a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 1;
 6ae:	bf15                	j	5e2 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b0:	03860563          	beq	a2,s8,6da <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6b4:	07b60963          	beq	a2,s11,726 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6b8:	07800793          	li	a5,120
 6bc:	fcf613e3          	bne	a2,a5,682 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e1fff0ef          	jal	ra,4ec <printint>
        i += 2;
 6d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	b729                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4685                	li	a3,1
 6e0:	4629                	li	a2,10
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	e05ff0ef          	jal	ra,4ec <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	bdc5                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4629                	li	a2,10
 6fc:	000be583          	lwu	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	debff0ef          	jal	ra,4ec <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bde1                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4629                	li	a2,10
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	dd3ff0ef          	jal	ra,4ec <printint>
        i += 1;
 71e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 1;
 724:	bd7d                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4629                	li	a2,10
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	db9ff0ef          	jal	ra,4ec <printint>
        i += 2;
 738:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
        i += 2;
 73e:	b555                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 740:	008b8913          	addi	s2,s7,8
 744:	4681                	li	a3,0
 746:	4641                	li	a2,16
 748:	000be583          	lwu	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	d9fff0ef          	jal	ra,4ec <printint>
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	b571                	j	5e2 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 758:	008b8913          	addi	s2,s7,8
 75c:	4681                	li	a3,0
 75e:	4641                	li	a2,16
 760:	000bb583          	ld	a1,0(s7)
 764:	855a                	mv	a0,s6
 766:	d87ff0ef          	jal	ra,4ec <printint>
        i += 1;
 76a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 76c:	8bca                	mv	s7,s2
      state = 0;
 76e:	4981                	li	s3,0
        i += 1;
 770:	bd8d                	j	5e2 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 772:	008b8793          	addi	a5,s7,8
 776:	f8f43423          	sd	a5,-120(s0)
 77a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 77e:	03000593          	li	a1,48
 782:	855a                	mv	a0,s6
 784:	d4bff0ef          	jal	ra,4ce <putc>
  putc(fd, 'x');
 788:	07800593          	li	a1,120
 78c:	855a                	mv	a0,s6
 78e:	d41ff0ef          	jal	ra,4ce <putc>
 792:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 794:	03c9d793          	srli	a5,s3,0x3c
 798:	97e6                	add	a5,a5,s9
 79a:	0007c583          	lbu	a1,0(a5)
 79e:	855a                	mv	a0,s6
 7a0:	d2fff0ef          	jal	ra,4ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a4:	0992                	slli	s3,s3,0x4
 7a6:	397d                	addiw	s2,s2,-1
 7a8:	fe0916e3          	bnez	s2,794 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7ac:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	bd05                	j	5e2 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7b4:	008b8913          	addi	s2,s7,8
 7b8:	000bc583          	lbu	a1,0(s7)
 7bc:	855a                	mv	a0,s6
 7be:	d11ff0ef          	jal	ra,4ce <putc>
 7c2:	8bca                	mv	s7,s2
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bd31                	j	5e2 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7c8:	008b8993          	addi	s3,s7,8
 7cc:	000bb903          	ld	s2,0(s7)
 7d0:	00090f63          	beqz	s2,7ee <vprintf+0x266>
        for(; *s; s++)
 7d4:	00094583          	lbu	a1,0(s2)
 7d8:	c195                	beqz	a1,7fc <vprintf+0x274>
          putc(fd, *s);
 7da:	855a                	mv	a0,s6
 7dc:	cf3ff0ef          	jal	ra,4ce <putc>
        for(; *s; s++)
 7e0:	0905                	addi	s2,s2,1
 7e2:	00094583          	lbu	a1,0(s2)
 7e6:	f9f5                	bnez	a1,7da <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7e8:	8bce                	mv	s7,s3
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bbdd                	j	5e2 <vprintf+0x5a>
          s = "(null)";
 7ee:	00000917          	auipc	s2,0x0
 7f2:	49290913          	addi	s2,s2,1170 # c80 <malloc+0x37c>
        for(; *s; s++)
 7f6:	02800593          	li	a1,40
 7fa:	b7c5                	j	7da <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7fc:	8bce                	mv	s7,s3
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b3cd                	j	5e2 <vprintf+0x5a>
    }
  }
}
 802:	70e6                	ld	ra,120(sp)
 804:	7446                	ld	s0,112(sp)
 806:	74a6                	ld	s1,104(sp)
 808:	7906                	ld	s2,96(sp)
 80a:	69e6                	ld	s3,88(sp)
 80c:	6a46                	ld	s4,80(sp)
 80e:	6aa6                	ld	s5,72(sp)
 810:	6b06                	ld	s6,64(sp)
 812:	7be2                	ld	s7,56(sp)
 814:	7c42                	ld	s8,48(sp)
 816:	7ca2                	ld	s9,40(sp)
 818:	7d02                	ld	s10,32(sp)
 81a:	6de2                	ld	s11,24(sp)
 81c:	6109                	addi	sp,sp,128
 81e:	8082                	ret

0000000000000820 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 820:	715d                	addi	sp,sp,-80
 822:	ec06                	sd	ra,24(sp)
 824:	e822                	sd	s0,16(sp)
 826:	1000                	addi	s0,sp,32
 828:	e010                	sd	a2,0(s0)
 82a:	e414                	sd	a3,8(s0)
 82c:	e818                	sd	a4,16(s0)
 82e:	ec1c                	sd	a5,24(s0)
 830:	03043023          	sd	a6,32(s0)
 834:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83c:	8622                	mv	a2,s0
 83e:	d4bff0ef          	jal	ra,588 <vprintf>
}
 842:	60e2                	ld	ra,24(sp)
 844:	6442                	ld	s0,16(sp)
 846:	6161                	addi	sp,sp,80
 848:	8082                	ret

000000000000084a <printf>:

void
printf(const char *fmt, ...)
{
 84a:	711d                	addi	sp,sp,-96
 84c:	ec06                	sd	ra,24(sp)
 84e:	e822                	sd	s0,16(sp)
 850:	1000                	addi	s0,sp,32
 852:	e40c                	sd	a1,8(s0)
 854:	e810                	sd	a2,16(s0)
 856:	ec14                	sd	a3,24(s0)
 858:	f018                	sd	a4,32(s0)
 85a:	f41c                	sd	a5,40(s0)
 85c:	03043823          	sd	a6,48(s0)
 860:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 864:	00840613          	addi	a2,s0,8
 868:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 86c:	85aa                	mv	a1,a0
 86e:	4505                	li	a0,1
 870:	d19ff0ef          	jal	ra,588 <vprintf>
}
 874:	60e2                	ld	ra,24(sp)
 876:	6442                	ld	s0,16(sp)
 878:	6125                	addi	sp,sp,96
 87a:	8082                	ret

000000000000087c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87c:	1141                	addi	sp,sp,-16
 87e:	e422                	sd	s0,8(sp)
 880:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 882:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 886:	00000797          	auipc	a5,0x0
 88a:	77a7b783          	ld	a5,1914(a5) # 1000 <freep>
 88e:	a805                	j	8be <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 890:	4618                	lw	a4,8(a2)
 892:	9db9                	addw	a1,a1,a4
 894:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 898:	6398                	ld	a4,0(a5)
 89a:	6318                	ld	a4,0(a4)
 89c:	fee53823          	sd	a4,-16(a0)
 8a0:	a091                	j	8e4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a2:	ff852703          	lw	a4,-8(a0)
 8a6:	9e39                	addw	a2,a2,a4
 8a8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8aa:	ff053703          	ld	a4,-16(a0)
 8ae:	e398                	sd	a4,0(a5)
 8b0:	a099                	j	8f6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b2:	6398                	ld	a4,0(a5)
 8b4:	00e7e463          	bltu	a5,a4,8bc <free+0x40>
 8b8:	00e6ea63          	bltu	a3,a4,8cc <free+0x50>
{
 8bc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8be:	fed7fae3          	bgeu	a5,a3,8b2 <free+0x36>
 8c2:	6398                	ld	a4,0(a5)
 8c4:	00e6e463          	bltu	a3,a4,8cc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c8:	fee7eae3          	bltu	a5,a4,8bc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8cc:	ff852583          	lw	a1,-8(a0)
 8d0:	6390                	ld	a2,0(a5)
 8d2:	02059713          	slli	a4,a1,0x20
 8d6:	9301                	srli	a4,a4,0x20
 8d8:	0712                	slli	a4,a4,0x4
 8da:	9736                	add	a4,a4,a3
 8dc:	fae60ae3          	beq	a2,a4,890 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8e0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e4:	4790                	lw	a2,8(a5)
 8e6:	02061713          	slli	a4,a2,0x20
 8ea:	9301                	srli	a4,a4,0x20
 8ec:	0712                	slli	a4,a4,0x4
 8ee:	973e                	add	a4,a4,a5
 8f0:	fae689e3          	beq	a3,a4,8a2 <free+0x26>
  } else
    p->s.ptr = bp;
 8f4:	e394                	sd	a3,0(a5)
  freep = p;
 8f6:	00000717          	auipc	a4,0x0
 8fa:	70f73523          	sd	a5,1802(a4) # 1000 <freep>
}
 8fe:	6422                	ld	s0,8(sp)
 900:	0141                	addi	sp,sp,16
 902:	8082                	ret

0000000000000904 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 904:	7139                	addi	sp,sp,-64
 906:	fc06                	sd	ra,56(sp)
 908:	f822                	sd	s0,48(sp)
 90a:	f426                	sd	s1,40(sp)
 90c:	f04a                	sd	s2,32(sp)
 90e:	ec4e                	sd	s3,24(sp)
 910:	e852                	sd	s4,16(sp)
 912:	e456                	sd	s5,8(sp)
 914:	e05a                	sd	s6,0(sp)
 916:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 918:	02051493          	slli	s1,a0,0x20
 91c:	9081                	srli	s1,s1,0x20
 91e:	04bd                	addi	s1,s1,15
 920:	8091                	srli	s1,s1,0x4
 922:	0014899b          	addiw	s3,s1,1
 926:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 928:	00000517          	auipc	a0,0x0
 92c:	6d853503          	ld	a0,1752(a0) # 1000 <freep>
 930:	c515                	beqz	a0,95c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 932:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 934:	4798                	lw	a4,8(a5)
 936:	02977f63          	bgeu	a4,s1,974 <malloc+0x70>
 93a:	8a4e                	mv	s4,s3
 93c:	0009871b          	sext.w	a4,s3
 940:	6685                	lui	a3,0x1
 942:	00d77363          	bgeu	a4,a3,948 <malloc+0x44>
 946:	6a05                	lui	s4,0x1
 948:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 94c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 950:	00000917          	auipc	s2,0x0
 954:	6b090913          	addi	s2,s2,1712 # 1000 <freep>
  if(p == SBRK_ERROR)
 958:	5afd                	li	s5,-1
 95a:	a0bd                	j	9c8 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 95c:	00000797          	auipc	a5,0x0
 960:	6b478793          	addi	a5,a5,1716 # 1010 <base>
 964:	00000717          	auipc	a4,0x0
 968:	68f73e23          	sd	a5,1692(a4) # 1000 <freep>
 96c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 96e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 972:	b7e1                	j	93a <malloc+0x36>
      if(p->s.size == nunits)
 974:	02e48b63          	beq	s1,a4,9aa <malloc+0xa6>
        p->s.size -= nunits;
 978:	4137073b          	subw	a4,a4,s3
 97c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 97e:	1702                	slli	a4,a4,0x20
 980:	9301                	srli	a4,a4,0x20
 982:	0712                	slli	a4,a4,0x4
 984:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 986:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98a:	00000717          	auipc	a4,0x0
 98e:	66a73b23          	sd	a0,1654(a4) # 1000 <freep>
      return (void*)(p + 1);
 992:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 996:	70e2                	ld	ra,56(sp)
 998:	7442                	ld	s0,48(sp)
 99a:	74a2                	ld	s1,40(sp)
 99c:	7902                	ld	s2,32(sp)
 99e:	69e2                	ld	s3,24(sp)
 9a0:	6a42                	ld	s4,16(sp)
 9a2:	6aa2                	ld	s5,8(sp)
 9a4:	6b02                	ld	s6,0(sp)
 9a6:	6121                	addi	sp,sp,64
 9a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9aa:	6398                	ld	a4,0(a5)
 9ac:	e118                	sd	a4,0(a0)
 9ae:	bff1                	j	98a <malloc+0x86>
  hp->s.size = nu;
 9b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b4:	0541                	addi	a0,a0,16
 9b6:	ec7ff0ef          	jal	ra,87c <free>
  return freep;
 9ba:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9be:	dd61                	beqz	a0,996 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c2:	4798                	lw	a4,8(a5)
 9c4:	fa9778e3          	bgeu	a4,s1,974 <malloc+0x70>
    if(p == freep)
 9c8:	00093703          	ld	a4,0(s2)
 9cc:	853e                	mv	a0,a5
 9ce:	fef719e3          	bne	a4,a5,9c0 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 9d2:	8552                	mv	a0,s4
 9d4:	a17ff0ef          	jal	ra,3ea <sbrk>
  if(p == SBRK_ERROR)
 9d8:	fd551ce3          	bne	a0,s5,9b0 <malloc+0xac>
        return 0;
 9dc:	4501                	li	a0,0
 9de:	bf65                	j	996 <malloc+0x92>
