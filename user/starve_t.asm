
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
  1a:	9ea50513          	addi	a0,a0,-1558 # a00 <malloc+0xf8>
  1e:	037000ef          	jal	854 <printf>
  printf("Testing automatic priority boosting every 100 ticks\n");
  22:	00001517          	auipc	a0,0x1
  26:	a0e50513          	addi	a0,a0,-1522 # a30 <malloc+0x128>
  2a:	02b000ef          	jal	854 <printf>
  printf("Running %d CPU-bound processes concurrently\n", num_procs);
  2e:	458d                	li	a1,3
  30:	00001517          	auipc	a0,0x1
  34:	a3850513          	addi	a0,a0,-1480 # a68 <malloc+0x160>
  38:	01d000ef          	jal	854 <printf>
  printf("All processes should get CPU time due to periodic boosting\n\n");
  3c:	00001517          	auipc	a0,0x1
  40:	a5c50513          	addi	a0,a0,-1444 # a98 <malloc+0x190>
  44:	011000ef          	jal	854 <printf>
  
  // Fork multiple CPU-bound processes
  for(int i = 0; i < num_procs; i++) {
  48:	4b01                	li	s6,0
  4a:	448d                	li	s1,3
    pids[i] = fork();
  4c:	3c8000ef          	jal	414 <fork>
  50:	89aa                	mv	s3,a0
    
    if(pids[i] == 0) {
  52:	c541                	beqz	a0,da <main+0xda>
      
      exit(0);
    }
    
    // Small delay between forks
    pause(1);
  54:	4505                	li	a0,1
  56:	456000ef          	jal	4ac <pause>
  for(int i = 0; i < num_procs; i++) {
  5a:	2b05                	addiw	s6,s6,1
  5c:	fe9b18e3          	bne	s6,s1,4c <main+0x4c>
  }
  
  // Parent waits for all children
  printf("\n[Parent] Waiting for all processes to complete...\n");
  60:	00001517          	auipc	a0,0x1
  64:	af050513          	addi	a0,a0,-1296 # b50 <malloc+0x248>
  68:	7ec000ef          	jal	854 <printf>
  for(int i = 0; i < num_procs; i++) {
  6c:	4481                	li	s1,0
    wait(0);
    printf("[Parent] Process %d finished\n", i);
  6e:	00001997          	auipc	s3,0x1
  72:	b1a98993          	addi	s3,s3,-1254 # b88 <malloc+0x280>
  for(int i = 0; i < num_procs; i++) {
  76:	490d                	li	s2,3
    wait(0);
  78:	4501                	li	a0,0
  7a:	3aa000ef          	jal	424 <wait>
    printf("[Parent] Process %d finished\n", i);
  7e:	85a6                	mv	a1,s1
  80:	854e                	mv	a0,s3
  82:	7d2000ef          	jal	854 <printf>
  for(int i = 0; i < num_procs; i++) {
  86:	2485                	addiw	s1,s1,1
  88:	ff2498e3          	bne	s1,s2,78 <main+0x78>
  }
  
  printf("\n=== Starvation Test Complete ===\n");
  8c:	00001517          	auipc	a0,0x1
  90:	b1c50513          	addi	a0,a0,-1252 # ba8 <malloc+0x2a0>
  94:	7c0000ef          	jal	854 <printf>
  printf("Analysis:\n");
  98:	00001517          	auipc	a0,0x1
  9c:	b3850513          	addi	a0,a0,-1224 # bd0 <malloc+0x2c8>
  a0:	7b4000ef          	jal	854 <printf>
  printf("  - All processes should have completed\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	b3c50513          	addi	a0,a0,-1220 # be0 <malloc+0x2d8>
  ac:	7a8000ef          	jal	854 <printf>
  printf("  - Processes should have been boosted to Q0 every ~100 ticks\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	b6050513          	addi	a0,a0,-1184 # c10 <malloc+0x308>
  b8:	79c000ef          	jal	854 <printf>
  printf("  - Even low-priority processes got CPU time\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	b9450513          	addi	a0,a0,-1132 # c50 <malloc+0x348>
  c4:	790000ef          	jal	854 <printf>
  printf("  - No process was starved!\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	bb850513          	addi	a0,a0,-1096 # c80 <malloc+0x378>
  d0:	784000ef          	jal	854 <printf>
  
  exit(0);
  d4:	4501                	li	a0,0
  d6:	346000ef          	jal	41c <exit>
      volatile int dummy = 0;
  da:	f8042e23          	sw	zero,-100(s0)
      printf("[Process %d] Started (PID=%d)\n", my_id, getpid());
  de:	3be000ef          	jal	49c <getpid>
  e2:	862a                	mv	a2,a0
  e4:	85da                	mv	a1,s6
  e6:	00001517          	auipc	a0,0x1
  ea:	9f250513          	addi	a0,a0,-1550 # ad8 <malloc+0x1d0>
  ee:	766000ef          	jal	854 <printf>
          dummy = dummy % 1000000;
  f2:	000f4937          	lui	s2,0xf4
  f6:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2230>
        for(long j = 0; j < 5000000; j++) {
  fa:	004c54b7          	lui	s1,0x4c5
  fe:	b4048493          	addi	s1,s1,-1216 # 4c4b40 <base+0x4c2b30>
        if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 102:	4abd                	li	s5,15
          printf("[Process %d] Tick %d: Q%d (slices=%d)\n", 
 104:	00001b97          	auipc	s7,0x1
 108:	9f4b8b93          	addi	s7,s7,-1548 # af8 <malloc+0x1f0>
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
 140:	37c000ef          	jal	4bc <getprocinfo>
 144:	f579                	bnez	a0,112 <main+0x112>
          int current_ticks = uptime();
 146:	36e000ef          	jal	4b4 <uptime>
 14a:	862a                	mv	a2,a0
          printf("[Process %d] Tick %d: Q%d (slices=%d)\n", 
 14c:	fac42703          	lw	a4,-84(s0)
 150:	fa842683          	lw	a3,-88(s0)
 154:	85da                	mv	a1,s6
 156:	855e                	mv	a0,s7
 158:	6fc000ef          	jal	854 <printf>
 15c:	bf5d                	j	112 <main+0x112>
      if(getprocinfo(&info) == 0) {
 15e:	fa040513          	addi	a0,s0,-96
 162:	35a000ef          	jal	4bc <getprocinfo>
 166:	c501                	beqz	a0,16e <main+0x16e>
      exit(0);
 168:	4501                	li	a0,0
 16a:	2b2000ef          	jal	41c <exit>
        printf("[Process %d] COMPLETED at tick %d: Final Q%d\n", 
 16e:	346000ef          	jal	4b4 <uptime>
 172:	862a                	mv	a2,a0
 174:	fa842683          	lw	a3,-88(s0)
 178:	85da                	mv	a1,s6
 17a:	00001517          	auipc	a0,0x1
 17e:	9a650513          	addi	a0,a0,-1626 # b20 <malloc+0x218>
 182:	6d2000ef          	jal	854 <printf>
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
 190:	e71ff0ef          	jal	0 <main>
  exit(r);
 194:	288000ef          	jal	41c <exit>

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
 1f0:	86be                	mv	a3,a5
 1f2:	0785                	addi	a5,a5,1
 1f4:	fff7c703          	lbu	a4,-1(a5)
 1f8:	ff65                	bnez	a4,1f0 <strlen+0x10>
 1fa:	40a6853b          	subw	a0,a3,a0
 1fe:	2505                	addiw	a0,a0,1
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
 282:	1b2000ef          	jal	434 <read>
    if(cc < 1)
 286:	00a05e63          	blez	a0,2a2 <gets+0x52>
    buf[i++] = c;
 28a:	faf44783          	lbu	a5,-81(s0)
 28e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 292:	01578763          	beq	a5,s5,2a0 <gets+0x50>
 296:	0905                	addi	s2,s2,1
 298:	fd679de3          	bne	a5,s6,272 <gets+0x22>
    buf[i++] = c;
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
 2c6:	e04a                	sd	s2,0(sp)
 2c8:	1000                	addi	s0,sp,32
 2ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2cc:	4581                	li	a1,0
 2ce:	18e000ef          	jal	45c <open>
  if(fd < 0)
 2d2:	02054263          	bltz	a0,2f6 <stat+0x36>
 2d6:	e426                	sd	s1,8(sp)
 2d8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2da:	85ca                	mv	a1,s2
 2dc:	198000ef          	jal	474 <fstat>
 2e0:	892a                	mv	s2,a0
  close(fd);
 2e2:	8526                	mv	a0,s1
 2e4:	160000ef          	jal	444 <close>
  return r;
 2e8:	64a2                	ld	s1,8(sp)
}
 2ea:	854a                	mv	a0,s2
 2ec:	60e2                	ld	ra,24(sp)
 2ee:	6442                	ld	s0,16(sp)
 2f0:	6902                	ld	s2,0(sp)
 2f2:	6105                	addi	sp,sp,32
 2f4:	8082                	ret
    return -1;
 2f6:	597d                	li	s2,-1
 2f8:	bfcd                	j	2ea <stat+0x2a>

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
 300:	00054683          	lbu	a3,0(a0)
 304:	fd06879b          	addiw	a5,a3,-48
 308:	0ff7f793          	zext.b	a5,a5
 30c:	4625                	li	a2,9
 30e:	02f66863          	bltu	a2,a5,33e <atoi+0x44>
 312:	872a                	mv	a4,a0
  n = 0;
 314:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 316:	0705                	addi	a4,a4,1
 318:	0025179b          	slliw	a5,a0,0x2
 31c:	9fa9                	addw	a5,a5,a0
 31e:	0017979b          	slliw	a5,a5,0x1
 322:	9fb5                	addw	a5,a5,a3
 324:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 328:	00074683          	lbu	a3,0(a4)
 32c:	fd06879b          	addiw	a5,a3,-48
 330:	0ff7f793          	zext.b	a5,a5
 334:	fef671e3          	bgeu	a2,a5,316 <atoi+0x1c>
  return n;
}
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret
  n = 0;
 33e:	4501                	li	a0,0
 340:	bfe5                	j	338 <atoi+0x3e>

0000000000000342 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 348:	02b57463          	bgeu	a0,a1,370 <memmove+0x2e>
    while(n-- > 0)
 34c:	00c05f63          	blez	a2,36a <memmove+0x28>
 350:	1602                	slli	a2,a2,0x20
 352:	9201                	srli	a2,a2,0x20
 354:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 358:	872a                	mv	a4,a0
      *dst++ = *src++;
 35a:	0585                	addi	a1,a1,1
 35c:	0705                	addi	a4,a4,1
 35e:	fff5c683          	lbu	a3,-1(a1)
 362:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 366:	fef71ae3          	bne	a4,a5,35a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36a:	6422                	ld	s0,8(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret
    dst += n;
 370:	00c50733          	add	a4,a0,a2
    src += n;
 374:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 376:	fec05ae3          	blez	a2,36a <memmove+0x28>
 37a:	fff6079b          	addiw	a5,a2,-1
 37e:	1782                	slli	a5,a5,0x20
 380:	9381                	srli	a5,a5,0x20
 382:	fff7c793          	not	a5,a5
 386:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 388:	15fd                	addi	a1,a1,-1
 38a:	177d                	addi	a4,a4,-1
 38c:	0005c683          	lbu	a3,0(a1)
 390:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 394:	fee79ae3          	bne	a5,a4,388 <memmove+0x46>
 398:	bfc9                	j	36a <memmove+0x28>

000000000000039a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e422                	sd	s0,8(sp)
 39e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a0:	ca05                	beqz	a2,3d0 <memcmp+0x36>
 3a2:	fff6069b          	addiw	a3,a2,-1
 3a6:	1682                	slli	a3,a3,0x20
 3a8:	9281                	srli	a3,a3,0x20
 3aa:	0685                	addi	a3,a3,1
 3ac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ae:	00054783          	lbu	a5,0(a0)
 3b2:	0005c703          	lbu	a4,0(a1)
 3b6:	00e79863          	bne	a5,a4,3c6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ba:	0505                	addi	a0,a0,1
    p2++;
 3bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3be:	fed518e3          	bne	a0,a3,3ae <memcmp+0x14>
  }
  return 0;
 3c2:	4501                	li	a0,0
 3c4:	a019                	j	3ca <memcmp+0x30>
      return *p1 - *p2;
 3c6:	40e7853b          	subw	a0,a5,a4
}
 3ca:	6422                	ld	s0,8(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret
  return 0;
 3d0:	4501                	li	a0,0
 3d2:	bfe5                	j	3ca <memcmp+0x30>

00000000000003d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e406                	sd	ra,8(sp)
 3d8:	e022                	sd	s0,0(sp)
 3da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3dc:	f67ff0ef          	jal	342 <memmove>
}
 3e0:	60a2                	ld	ra,8(sp)
 3e2:	6402                	ld	s0,0(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret

00000000000003e8 <sbrk>:

char *
sbrk(int n) {
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e406                	sd	ra,8(sp)
 3ec:	e022                	sd	s0,0(sp)
 3ee:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3f0:	4585                	li	a1,1
 3f2:	0b2000ef          	jal	4a4 <sys_sbrk>
}
 3f6:	60a2                	ld	ra,8(sp)
 3f8:	6402                	ld	s0,0(sp)
 3fa:	0141                	addi	sp,sp,16
 3fc:	8082                	ret

00000000000003fe <sbrklazy>:

char *
sbrklazy(int n) {
 3fe:	1141                	addi	sp,sp,-16
 400:	e406                	sd	ra,8(sp)
 402:	e022                	sd	s0,0(sp)
 404:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 406:	4589                	li	a1,2
 408:	09c000ef          	jal	4a4 <sys_sbrk>
}
 40c:	60a2                	ld	ra,8(sp)
 40e:	6402                	ld	s0,0(sp)
 410:	0141                	addi	sp,sp,16
 412:	8082                	ret

0000000000000414 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 414:	4885                	li	a7,1
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <exit>:
.global exit
exit:
 li a7, SYS_exit
 41c:	4889                	li	a7,2
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <wait>:
.global wait
wait:
 li a7, SYS_wait
 424:	488d                	li	a7,3
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 42c:	4891                	li	a7,4
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <read>:
.global read
read:
 li a7, SYS_read
 434:	4895                	li	a7,5
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <write>:
.global write
write:
 li a7, SYS_write
 43c:	48c1                	li	a7,16
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <close>:
.global close
close:
 li a7, SYS_close
 444:	48d5                	li	a7,21
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <kill>:
.global kill
kill:
 li a7, SYS_kill
 44c:	4899                	li	a7,6
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <exec>:
.global exec
exec:
 li a7, SYS_exec
 454:	489d                	li	a7,7
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <open>:
.global open
open:
 li a7, SYS_open
 45c:	48bd                	li	a7,15
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 464:	48c5                	li	a7,17
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 46c:	48c9                	li	a7,18
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 474:	48a1                	li	a7,8
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <link>:
.global link
link:
 li a7, SYS_link
 47c:	48cd                	li	a7,19
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 484:	48d1                	li	a7,20
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 48c:	48a5                	li	a7,9
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <dup>:
.global dup
dup:
 li a7, SYS_dup
 494:	48a9                	li	a7,10
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 49c:	48ad                	li	a7,11
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4a4:	48b1                	li	a7,12
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <pause>:
.global pause
pause:
 li a7, SYS_pause
 4ac:	48b5                	li	a7,13
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b4:	48b9                	li	a7,14
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4bc:	48d9                	li	a7,22
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4c4:	48dd                	li	a7,23
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4cc:	1101                	addi	sp,sp,-32
 4ce:	ec06                	sd	ra,24(sp)
 4d0:	e822                	sd	s0,16(sp)
 4d2:	1000                	addi	s0,sp,32
 4d4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d8:	4605                	li	a2,1
 4da:	fef40593          	addi	a1,s0,-17
 4de:	f5fff0ef          	jal	43c <write>
}
 4e2:	60e2                	ld	ra,24(sp)
 4e4:	6442                	ld	s0,16(sp)
 4e6:	6105                	addi	sp,sp,32
 4e8:	8082                	ret

00000000000004ea <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ea:	715d                	addi	sp,sp,-80
 4ec:	e486                	sd	ra,72(sp)
 4ee:	e0a2                	sd	s0,64(sp)
 4f0:	f84a                	sd	s2,48(sp)
 4f2:	0880                	addi	s0,sp,80
 4f4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4f6:	c299                	beqz	a3,4fc <printint+0x12>
 4f8:	0805c363          	bltz	a1,57e <printint+0x94>
  neg = 0;
 4fc:	4881                	li	a7,0
 4fe:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 502:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 504:	00000517          	auipc	a0,0x0
 508:	7a450513          	addi	a0,a0,1956 # ca8 <digits>
 50c:	883e                	mv	a6,a5
 50e:	2785                	addiw	a5,a5,1
 510:	02c5f733          	remu	a4,a1,a2
 514:	972a                	add	a4,a4,a0
 516:	00074703          	lbu	a4,0(a4)
 51a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 51e:	872e                	mv	a4,a1
 520:	02c5d5b3          	divu	a1,a1,a2
 524:	0685                	addi	a3,a3,1
 526:	fec773e3          	bgeu	a4,a2,50c <printint+0x22>
  if(neg)
 52a:	00088b63          	beqz	a7,540 <printint+0x56>
    buf[i++] = '-';
 52e:	fd078793          	addi	a5,a5,-48
 532:	97a2                	add	a5,a5,s0
 534:	02d00713          	li	a4,45
 538:	fee78423          	sb	a4,-24(a5)
 53c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 540:	02f05a63          	blez	a5,574 <printint+0x8a>
 544:	fc26                	sd	s1,56(sp)
 546:	f44e                	sd	s3,40(sp)
 548:	fb840713          	addi	a4,s0,-72
 54c:	00f704b3          	add	s1,a4,a5
 550:	fff70993          	addi	s3,a4,-1
 554:	99be                	add	s3,s3,a5
 556:	37fd                	addiw	a5,a5,-1
 558:	1782                	slli	a5,a5,0x20
 55a:	9381                	srli	a5,a5,0x20
 55c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 560:	fff4c583          	lbu	a1,-1(s1)
 564:	854a                	mv	a0,s2
 566:	f67ff0ef          	jal	4cc <putc>
  while(--i >= 0)
 56a:	14fd                	addi	s1,s1,-1
 56c:	ff349ae3          	bne	s1,s3,560 <printint+0x76>
 570:	74e2                	ld	s1,56(sp)
 572:	79a2                	ld	s3,40(sp)
}
 574:	60a6                	ld	ra,72(sp)
 576:	6406                	ld	s0,64(sp)
 578:	7942                	ld	s2,48(sp)
 57a:	6161                	addi	sp,sp,80
 57c:	8082                	ret
    x = -xx;
 57e:	40b005b3          	neg	a1,a1
    neg = 1;
 582:	4885                	li	a7,1
    x = -xx;
 584:	bfad                	j	4fe <printint+0x14>

0000000000000586 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 586:	711d                	addi	sp,sp,-96
 588:	ec86                	sd	ra,88(sp)
 58a:	e8a2                	sd	s0,80(sp)
 58c:	e0ca                	sd	s2,64(sp)
 58e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 590:	0005c903          	lbu	s2,0(a1)
 594:	28090663          	beqz	s2,820 <vprintf+0x29a>
 598:	e4a6                	sd	s1,72(sp)
 59a:	fc4e                	sd	s3,56(sp)
 59c:	f852                	sd	s4,48(sp)
 59e:	f456                	sd	s5,40(sp)
 5a0:	f05a                	sd	s6,32(sp)
 5a2:	ec5e                	sd	s7,24(sp)
 5a4:	e862                	sd	s8,16(sp)
 5a6:	e466                	sd	s9,8(sp)
 5a8:	8b2a                	mv	s6,a0
 5aa:	8a2e                	mv	s4,a1
 5ac:	8bb2                	mv	s7,a2
  state = 0;
 5ae:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b0:	4481                	li	s1,0
 5b2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5b4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5b8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5bc:	06c00c93          	li	s9,108
 5c0:	a005                	j	5e0 <vprintf+0x5a>
        putc(fd, c0);
 5c2:	85ca                	mv	a1,s2
 5c4:	855a                	mv	a0,s6
 5c6:	f07ff0ef          	jal	4cc <putc>
 5ca:	a019                	j	5d0 <vprintf+0x4a>
    } else if(state == '%'){
 5cc:	03598263          	beq	s3,s5,5f0 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5d0:	2485                	addiw	s1,s1,1
 5d2:	8726                	mv	a4,s1
 5d4:	009a07b3          	add	a5,s4,s1
 5d8:	0007c903          	lbu	s2,0(a5)
 5dc:	22090a63          	beqz	s2,810 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5e0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e4:	fe0994e3          	bnez	s3,5cc <vprintf+0x46>
      if(c0 == '%'){
 5e8:	fd579de3          	bne	a5,s5,5c2 <vprintf+0x3c>
        state = '%';
 5ec:	89be                	mv	s3,a5
 5ee:	b7cd                	j	5d0 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5f0:	00ea06b3          	add	a3,s4,a4
 5f4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5f8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5fa:	c681                	beqz	a3,602 <vprintf+0x7c>
 5fc:	9752                	add	a4,a4,s4
 5fe:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 602:	05878363          	beq	a5,s8,648 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 606:	05978d63          	beq	a5,s9,660 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 60a:	07500713          	li	a4,117
 60e:	0ee78763          	beq	a5,a4,6fc <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 612:	07800713          	li	a4,120
 616:	12e78963          	beq	a5,a4,748 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 61a:	07000713          	li	a4,112
 61e:	14e78e63          	beq	a5,a4,77a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 622:	06300713          	li	a4,99
 626:	18e78e63          	beq	a5,a4,7c2 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 62a:	07300713          	li	a4,115
 62e:	1ae78463          	beq	a5,a4,7d6 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 632:	02500713          	li	a4,37
 636:	04e79563          	bne	a5,a4,680 <vprintf+0xfa>
        putc(fd, '%');
 63a:	02500593          	li	a1,37
 63e:	855a                	mv	a0,s6
 640:	e8dff0ef          	jal	4cc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 644:	4981                	li	s3,0
 646:	b769                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 648:	008b8913          	addi	s2,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000ba583          	lw	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	e95ff0ef          	jal	4ea <printint>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bf8d                	j	5d0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 660:	06400793          	li	a5,100
 664:	02f68963          	beq	a3,a5,696 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 668:	06c00793          	li	a5,108
 66c:	04f68263          	beq	a3,a5,6b0 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 670:	07500793          	li	a5,117
 674:	0af68063          	beq	a3,a5,714 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 678:	07800793          	li	a5,120
 67c:	0ef68263          	beq	a3,a5,760 <vprintf+0x1da>
        putc(fd, '%');
 680:	02500593          	li	a1,37
 684:	855a                	mv	a0,s6
 686:	e47ff0ef          	jal	4cc <putc>
        putc(fd, c0);
 68a:	85ca                	mv	a1,s2
 68c:	855a                	mv	a0,s6
 68e:	e3fff0ef          	jal	4cc <putc>
      state = 0;
 692:	4981                	li	s3,0
 694:	bf35                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 696:	008b8913          	addi	s2,s7,8
 69a:	4685                	li	a3,1
 69c:	4629                	li	a2,10
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	e47ff0ef          	jal	4ea <printint>
        i += 1;
 6a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 1;
 6ae:	b70d                	j	5d0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b0:	06400793          	li	a5,100
 6b4:	02f60763          	beq	a2,a5,6e2 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6b8:	07500793          	li	a5,117
 6bc:	06f60963          	beq	a2,a5,72e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6c0:	07800793          	li	a5,120
 6c4:	faf61ee3          	bne	a2,a5,680 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4641                	li	a2,16
 6d0:	000bb583          	ld	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	e15ff0ef          	jal	4ea <printint>
        i += 2;
 6da:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6dc:	8bca                	mv	s7,s2
      state = 0;
 6de:	4981                	li	s3,0
        i += 2;
 6e0:	bdc5                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	4685                	li	a3,1
 6e8:	4629                	li	a2,10
 6ea:	000bb583          	ld	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	dfbff0ef          	jal	4ea <printint>
        i += 2;
 6f4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f6:	8bca                	mv	s7,s2
      state = 0;
 6f8:	4981                	li	s3,0
        i += 2;
 6fa:	bdd9                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6fc:	008b8913          	addi	s2,s7,8
 700:	4681                	li	a3,0
 702:	4629                	li	a2,10
 704:	000be583          	lwu	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	de1ff0ef          	jal	4ea <printint>
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
 712:	bd7d                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 714:	008b8913          	addi	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4629                	li	a2,10
 71c:	000bb583          	ld	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	dc9ff0ef          	jal	4ea <printint>
        i += 1;
 726:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
        i += 1;
 72c:	b555                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 72e:	008b8913          	addi	s2,s7,8
 732:	4681                	li	a3,0
 734:	4629                	li	a2,10
 736:	000bb583          	ld	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	dafff0ef          	jal	4ea <printint>
        i += 2;
 740:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
        i += 2;
 746:	b569                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 748:	008b8913          	addi	s2,s7,8
 74c:	4681                	li	a3,0
 74e:	4641                	li	a2,16
 750:	000be583          	lwu	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	d95ff0ef          	jal	4ea <printint>
 75a:	8bca                	mv	s7,s2
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bd8d                	j	5d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 760:	008b8913          	addi	s2,s7,8
 764:	4681                	li	a3,0
 766:	4641                	li	a2,16
 768:	000bb583          	ld	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	d7dff0ef          	jal	4ea <printint>
        i += 1;
 772:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 774:	8bca                	mv	s7,s2
      state = 0;
 776:	4981                	li	s3,0
        i += 1;
 778:	bda1                	j	5d0 <vprintf+0x4a>
 77a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 77c:	008b8d13          	addi	s10,s7,8
 780:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 784:	03000593          	li	a1,48
 788:	855a                	mv	a0,s6
 78a:	d43ff0ef          	jal	4cc <putc>
  putc(fd, 'x');
 78e:	07800593          	li	a1,120
 792:	855a                	mv	a0,s6
 794:	d39ff0ef          	jal	4cc <putc>
 798:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79a:	00000b97          	auipc	s7,0x0
 79e:	50eb8b93          	addi	s7,s7,1294 # ca8 <digits>
 7a2:	03c9d793          	srli	a5,s3,0x3c
 7a6:	97de                	add	a5,a5,s7
 7a8:	0007c583          	lbu	a1,0(a5)
 7ac:	855a                	mv	a0,s6
 7ae:	d1fff0ef          	jal	4cc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b2:	0992                	slli	s3,s3,0x4
 7b4:	397d                	addiw	s2,s2,-1
 7b6:	fe0916e3          	bnez	s2,7a2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7ba:	8bea                	mv	s7,s10
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	6d02                	ld	s10,0(sp)
 7c0:	bd01                	j	5d0 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7c2:	008b8913          	addi	s2,s7,8
 7c6:	000bc583          	lbu	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	d01ff0ef          	jal	4cc <putc>
 7d0:	8bca                	mv	s7,s2
      state = 0;
 7d2:	4981                	li	s3,0
 7d4:	bbf5                	j	5d0 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7d6:	008b8993          	addi	s3,s7,8
 7da:	000bb903          	ld	s2,0(s7)
 7de:	00090f63          	beqz	s2,7fc <vprintf+0x276>
        for(; *s; s++)
 7e2:	00094583          	lbu	a1,0(s2)
 7e6:	c195                	beqz	a1,80a <vprintf+0x284>
          putc(fd, *s);
 7e8:	855a                	mv	a0,s6
 7ea:	ce3ff0ef          	jal	4cc <putc>
        for(; *s; s++)
 7ee:	0905                	addi	s2,s2,1
 7f0:	00094583          	lbu	a1,0(s2)
 7f4:	f9f5                	bnez	a1,7e8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7f6:	8bce                	mv	s7,s3
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	bbd9                	j	5d0 <vprintf+0x4a>
          s = "(null)";
 7fc:	00000917          	auipc	s2,0x0
 800:	4a490913          	addi	s2,s2,1188 # ca0 <malloc+0x398>
        for(; *s; s++)
 804:	02800593          	li	a1,40
 808:	b7c5                	j	7e8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 80a:	8bce                	mv	s7,s3
      state = 0;
 80c:	4981                	li	s3,0
 80e:	b3c9                	j	5d0 <vprintf+0x4a>
 810:	64a6                	ld	s1,72(sp)
 812:	79e2                	ld	s3,56(sp)
 814:	7a42                	ld	s4,48(sp)
 816:	7aa2                	ld	s5,40(sp)
 818:	7b02                	ld	s6,32(sp)
 81a:	6be2                	ld	s7,24(sp)
 81c:	6c42                	ld	s8,16(sp)
 81e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 820:	60e6                	ld	ra,88(sp)
 822:	6446                	ld	s0,80(sp)
 824:	6906                	ld	s2,64(sp)
 826:	6125                	addi	sp,sp,96
 828:	8082                	ret

000000000000082a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 82a:	715d                	addi	sp,sp,-80
 82c:	ec06                	sd	ra,24(sp)
 82e:	e822                	sd	s0,16(sp)
 830:	1000                	addi	s0,sp,32
 832:	e010                	sd	a2,0(s0)
 834:	e414                	sd	a3,8(s0)
 836:	e818                	sd	a4,16(s0)
 838:	ec1c                	sd	a5,24(s0)
 83a:	03043023          	sd	a6,32(s0)
 83e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 842:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 846:	8622                	mv	a2,s0
 848:	d3fff0ef          	jal	586 <vprintf>
}
 84c:	60e2                	ld	ra,24(sp)
 84e:	6442                	ld	s0,16(sp)
 850:	6161                	addi	sp,sp,80
 852:	8082                	ret

0000000000000854 <printf>:

void
printf(const char *fmt, ...)
{
 854:	711d                	addi	sp,sp,-96
 856:	ec06                	sd	ra,24(sp)
 858:	e822                	sd	s0,16(sp)
 85a:	1000                	addi	s0,sp,32
 85c:	e40c                	sd	a1,8(s0)
 85e:	e810                	sd	a2,16(s0)
 860:	ec14                	sd	a3,24(s0)
 862:	f018                	sd	a4,32(s0)
 864:	f41c                	sd	a5,40(s0)
 866:	03043823          	sd	a6,48(s0)
 86a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 86e:	00840613          	addi	a2,s0,8
 872:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 876:	85aa                	mv	a1,a0
 878:	4505                	li	a0,1
 87a:	d0dff0ef          	jal	586 <vprintf>
}
 87e:	60e2                	ld	ra,24(sp)
 880:	6442                	ld	s0,16(sp)
 882:	6125                	addi	sp,sp,96
 884:	8082                	ret

0000000000000886 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 886:	1141                	addi	sp,sp,-16
 888:	e422                	sd	s0,8(sp)
 88a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 890:	00001797          	auipc	a5,0x1
 894:	7707b783          	ld	a5,1904(a5) # 2000 <freep>
 898:	a02d                	j	8c2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 89a:	4618                	lw	a4,8(a2)
 89c:	9f2d                	addw	a4,a4,a1
 89e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a2:	6398                	ld	a4,0(a5)
 8a4:	6310                	ld	a2,0(a4)
 8a6:	a83d                	j	8e4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a8:	ff852703          	lw	a4,-8(a0)
 8ac:	9f31                	addw	a4,a4,a2
 8ae:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8b0:	ff053683          	ld	a3,-16(a0)
 8b4:	a091                	j	8f8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b6:	6398                	ld	a4,0(a5)
 8b8:	00e7e463          	bltu	a5,a4,8c0 <free+0x3a>
 8bc:	00e6ea63          	bltu	a3,a4,8d0 <free+0x4a>
{
 8c0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c2:	fed7fae3          	bgeu	a5,a3,8b6 <free+0x30>
 8c6:	6398                	ld	a4,0(a5)
 8c8:	00e6e463          	bltu	a3,a4,8d0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8cc:	fee7eae3          	bltu	a5,a4,8c0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8d0:	ff852583          	lw	a1,-8(a0)
 8d4:	6390                	ld	a2,0(a5)
 8d6:	02059813          	slli	a6,a1,0x20
 8da:	01c85713          	srli	a4,a6,0x1c
 8de:	9736                	add	a4,a4,a3
 8e0:	fae60de3          	beq	a2,a4,89a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e8:	4790                	lw	a2,8(a5)
 8ea:	02061593          	slli	a1,a2,0x20
 8ee:	01c5d713          	srli	a4,a1,0x1c
 8f2:	973e                	add	a4,a4,a5
 8f4:	fae68ae3          	beq	a3,a4,8a8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8fa:	00001717          	auipc	a4,0x1
 8fe:	70f73323          	sd	a5,1798(a4) # 2000 <freep>
}
 902:	6422                	ld	s0,8(sp)
 904:	0141                	addi	sp,sp,16
 906:	8082                	ret

0000000000000908 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 908:	7139                	addi	sp,sp,-64
 90a:	fc06                	sd	ra,56(sp)
 90c:	f822                	sd	s0,48(sp)
 90e:	f426                	sd	s1,40(sp)
 910:	ec4e                	sd	s3,24(sp)
 912:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 914:	02051493          	slli	s1,a0,0x20
 918:	9081                	srli	s1,s1,0x20
 91a:	04bd                	addi	s1,s1,15
 91c:	8091                	srli	s1,s1,0x4
 91e:	0014899b          	addiw	s3,s1,1
 922:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 924:	00001517          	auipc	a0,0x1
 928:	6dc53503          	ld	a0,1756(a0) # 2000 <freep>
 92c:	c915                	beqz	a0,960 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 930:	4798                	lw	a4,8(a5)
 932:	08977a63          	bgeu	a4,s1,9c6 <malloc+0xbe>
 936:	f04a                	sd	s2,32(sp)
 938:	e852                	sd	s4,16(sp)
 93a:	e456                	sd	s5,8(sp)
 93c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 93e:	8a4e                	mv	s4,s3
 940:	0009871b          	sext.w	a4,s3
 944:	6685                	lui	a3,0x1
 946:	00d77363          	bgeu	a4,a3,94c <malloc+0x44>
 94a:	6a05                	lui	s4,0x1
 94c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 950:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 954:	00001917          	auipc	s2,0x1
 958:	6ac90913          	addi	s2,s2,1708 # 2000 <freep>
  if(p == SBRK_ERROR)
 95c:	5afd                	li	s5,-1
 95e:	a081                	j	99e <malloc+0x96>
 960:	f04a                	sd	s2,32(sp)
 962:	e852                	sd	s4,16(sp)
 964:	e456                	sd	s5,8(sp)
 966:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 968:	00001797          	auipc	a5,0x1
 96c:	6a878793          	addi	a5,a5,1704 # 2010 <base>
 970:	00001717          	auipc	a4,0x1
 974:	68f73823          	sd	a5,1680(a4) # 2000 <freep>
 978:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 97a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 97e:	b7c1                	j	93e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 980:	6398                	ld	a4,0(a5)
 982:	e118                	sd	a4,0(a0)
 984:	a8a9                	j	9de <malloc+0xd6>
  hp->s.size = nu;
 986:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 98a:	0541                	addi	a0,a0,16
 98c:	efbff0ef          	jal	886 <free>
  return freep;
 990:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 994:	c12d                	beqz	a0,9f6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 996:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 998:	4798                	lw	a4,8(a5)
 99a:	02977263          	bgeu	a4,s1,9be <malloc+0xb6>
    if(p == freep)
 99e:	00093703          	ld	a4,0(s2)
 9a2:	853e                	mv	a0,a5
 9a4:	fef719e3          	bne	a4,a5,996 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9a8:	8552                	mv	a0,s4
 9aa:	a3fff0ef          	jal	3e8 <sbrk>
  if(p == SBRK_ERROR)
 9ae:	fd551ce3          	bne	a0,s5,986 <malloc+0x7e>
        return 0;
 9b2:	4501                	li	a0,0
 9b4:	7902                	ld	s2,32(sp)
 9b6:	6a42                	ld	s4,16(sp)
 9b8:	6aa2                	ld	s5,8(sp)
 9ba:	6b02                	ld	s6,0(sp)
 9bc:	a03d                	j	9ea <malloc+0xe2>
 9be:	7902                	ld	s2,32(sp)
 9c0:	6a42                	ld	s4,16(sp)
 9c2:	6aa2                	ld	s5,8(sp)
 9c4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9c6:	fae48de3          	beq	s1,a4,980 <malloc+0x78>
        p->s.size -= nunits;
 9ca:	4137073b          	subw	a4,a4,s3
 9ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d0:	02071693          	slli	a3,a4,0x20
 9d4:	01c6d713          	srli	a4,a3,0x1c
 9d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9de:	00001717          	auipc	a4,0x1
 9e2:	62a73123          	sd	a0,1570(a4) # 2000 <freep>
      return (void*)(p + 1);
 9e6:	01078513          	addi	a0,a5,16
  }
}
 9ea:	70e2                	ld	ra,56(sp)
 9ec:	7442                	ld	s0,48(sp)
 9ee:	74a2                	ld	s1,40(sp)
 9f0:	69e2                	ld	s3,24(sp)
 9f2:	6121                	addi	sp,sp,64
 9f4:	8082                	ret
 9f6:	7902                	ld	s2,32(sp)
 9f8:	6a42                	ld	s4,16(sp)
 9fa:	6aa2                	ld	s5,8(sp)
 9fc:	6b02                	ld	s6,0(sp)
 9fe:	b7f5                	j	9ea <malloc+0xe2>
