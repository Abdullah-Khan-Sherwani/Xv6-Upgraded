
user/_iobound:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// I/O-bound test: Frequent yields (sleeps)
// Should stay in Q0 or Q1 (high priority) throughout
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
  struct procinfo info;
  int iter;
  
  printf("=== Comprehensive I/O-Bound Test ===\n");
  18:	00001517          	auipc	a0,0x1
  1c:	9e850513          	addi	a0,a0,-1560 # a00 <malloc+0x100>
  20:	02d000ef          	jal	84c <printf>
  printf("This process will alternate between brief work and sleep.\n");
  24:	00001517          	auipc	a0,0x1
  28:	a0c50513          	addi	a0,a0,-1524 # a30 <malloc+0x130>
  2c:	021000ef          	jal	84c <printf>
  printf("It should STAY in Q0 (never demote) because it yields frequently.\n\n");
  30:	00001517          	auipc	a0,0x1
  34:	a4050513          	addi	a0,a0,-1472 # a70 <malloc+0x170>
  38:	015000ef          	jal	84c <printf>
  
  if(getprocinfo(&info) == 0) {
  3c:	fa040513          	addi	a0,s0,-96
  40:	474000ef          	jal	4b4 <getprocinfo>
  44:	c131                	beqz	a0,88 <main+0x88>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
           info.pid, info.priority, info.time_slices);
  }
  
  printf("Running 30 iterations of: brief_work() -> sleep(1_tick)\n");
  46:	00001517          	auipc	a0,0x1
  4a:	aa250513          	addi	a0,a0,-1374 # ae8 <malloc+0x1e8>
  4e:	7fe000ef          	jal	84c <printf>
  printf("Expected: Priority stays Q0 throughout (slices reset after sleep)\n\n");
  52:	00001517          	auipc	a0,0x1
  56:	ad650513          	addi	a0,a0,-1322 # b28 <malloc+0x228>
  5a:	7f2000ef          	jal	84c <printf>
  
  // Simulate I/O-bound behavior: short bursts with frequent sleeps
  // 30 iterations × 1 second per iteration = ~30 seconds total
  for(iter = 0; iter < 30; iter++) {
  5e:	4901                	li	s2,0
    // Do minimal work (much less than 2 ticks - the Q0 quantum)
    volatile int dummy = 0;
    for(long j = 0; j < 2000000; j++) {  // Small computation
  60:	001e84b7          	lui	s1,0x1e8
  64:	48048493          	addi	s1,s1,1152 # 1e8480 <base+0x1e6470>
    // This is the KEY behavior: yields before exhausting quantum
    pause(1);  // Sleep for 1 tick (~100ms)
    
    // Check priority after wakeup
    if(getprocinfo(&info) == 0) {
      if(iter % 5 == 0) {  // Print every 5 iterations to reduce clutter
  68:	4a15                	li	s4,5
        printf("Iteration %d: Priority=Q%d, TimeSlices=%d\n", 
  6a:	00001c17          	auipc	s8,0x1
  6e:	b06c0c13          	addi	s8,s8,-1274 # b70 <malloc+0x270>
  72:	49f5                	li	s3,29
  74:	20100ab7          	lui	s5,0x20100
  78:	400a8a93          	addi	s5,s5,1024 # 20100400 <base+0x200fe3f0>
  for(iter = 0; iter < 30; iter++) {
  7c:	4b79                	li	s6,30
    }
    
    // Verify we stay in high priority
    if(iter == 10 || iter == 20 || iter == 29) {
      if(getprocinfo(&info) == 0) {
        printf("  [Checkpoint] Still at Q%d\n", info.priority);
  7e:	00001b97          	auipc	s7,0x1
  82:	b22b8b93          	addi	s7,s7,-1246 # ba0 <malloc+0x2a0>
  86:	a815                	j	ba <main+0xba>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
  88:	fac42683          	lw	a3,-84(s0)
  8c:	fa842603          	lw	a2,-88(s0)
  90:	fa042583          	lw	a1,-96(s0)
  94:	00001517          	auipc	a0,0x1
  98:	a2450513          	addi	a0,a0,-1500 # ab8 <malloc+0x1b8>
  9c:	7b0000ef          	jal	84c <printf>
  a0:	b75d                	j	46 <main+0x46>
        printf("Iteration %d: Priority=Q%d, TimeSlices=%d\n", 
  a2:	fac42683          	lw	a3,-84(s0)
  a6:	fa842603          	lw	a2,-88(s0)
  aa:	85ca                	mv	a1,s2
  ac:	8562                	mv	a0,s8
  ae:	79e000ef          	jal	84c <printf>
  b2:	a81d                	j	e8 <main+0xe8>
  for(iter = 0; iter < 30; iter++) {
  b4:	2905                	addiw	s2,s2,1
  b6:	05690c63          	beq	s2,s6,10e <main+0x10e>
    volatile int dummy = 0;
  ba:	f8042e23          	sw	zero,-100(s0)
    for(long j = 0; j < 2000000; j++) {  // Small computation
  be:	4781                	li	a5,0
      dummy = dummy + j;
  c0:	f9c42703          	lw	a4,-100(s0)
  c4:	9f3d                	addw	a4,a4,a5
  c6:	f8e42e23          	sw	a4,-100(s0)
    for(long j = 0; j < 2000000; j++) {  // Small computation
  ca:	0785                	addi	a5,a5,1
  cc:	fe979ae3          	bne	a5,s1,c0 <main+0xc0>
    pause(1);  // Sleep for 1 tick (~100ms)
  d0:	4505                	li	a0,1
  d2:	3d2000ef          	jal	4a4 <pause>
    if(getprocinfo(&info) == 0) {
  d6:	fa040513          	addi	a0,s0,-96
  da:	3da000ef          	jal	4b4 <getprocinfo>
      if(iter % 5 == 0) {  // Print every 5 iterations to reduce clutter
  de:	034967bb          	remw	a5,s2,s4
  e2:	8fc9                	or	a5,a5,a0
  e4:	2781                	sext.w	a5,a5
  e6:	dfd5                	beqz	a5,a2 <main+0xa2>
    if(iter == 10 || iter == 20 || iter == 29) {
  e8:	0009079b          	sext.w	a5,s2
  ec:	08f9e863          	bltu	s3,a5,17c <main+0x17c>
  f0:	00fad7b3          	srl	a5,s5,a5
  f4:	8b85                	andi	a5,a5,1
  f6:	dfdd                	beqz	a5,b4 <main+0xb4>
      if(getprocinfo(&info) == 0) {
  f8:	fa040513          	addi	a0,s0,-96
  fc:	3b8000ef          	jal	4b4 <getprocinfo>
 100:	f955                	bnez	a0,b4 <main+0xb4>
        printf("  [Checkpoint] Still at Q%d\n", info.priority);
 102:	fa842583          	lw	a1,-88(s0)
 106:	855e                	mv	a0,s7
 108:	744000ef          	jal	84c <printf>
 10c:	b765                	j	b4 <main+0xb4>
      }
    }
  }
  
  printf("\n");
 10e:	00001517          	auipc	a0,0x1
 112:	ab250513          	addi	a0,a0,-1358 # bc0 <malloc+0x2c0>
 116:	736000ef          	jal	84c <printf>
  if(getprocinfo(&info) == 0) {
 11a:	fa040513          	addi	a0,s0,-96
 11e:	396000ef          	jal	4b4 <getprocinfo>
 122:	c501                	beqz	a0,12a <main+0x12a>
      printf("✗ FAILED: Demoted to Q%d (should have stayed Q0/Q1)\n", info.priority);
      printf("  Sleep/pause may not be properly resetting time slices!\n");
    }
  }
  
  exit(0);
 124:	4501                	li	a0,0
 126:	2ee000ef          	jal	414 <exit>
    printf("Final Result: Priority=Q%d, TimeSlices=%d\n", 
 12a:	fac42603          	lw	a2,-84(s0)
 12e:	fa842583          	lw	a1,-88(s0)
 132:	00001517          	auipc	a0,0x1
 136:	a9650513          	addi	a0,a0,-1386 # bc8 <malloc+0x2c8>
 13a:	712000ef          	jal	84c <printf>
    if(info.priority <= 1) {
 13e:	fa842583          	lw	a1,-88(s0)
 142:	4785                	li	a5,1
 144:	00b7df63          	bge	a5,a1,162 <main+0x162>
      printf("✗ FAILED: Demoted to Q%d (should have stayed Q0/Q1)\n", info.priority);
 148:	00001517          	auipc	a0,0x1
 14c:	b2850513          	addi	a0,a0,-1240 # c70 <malloc+0x370>
 150:	6fc000ef          	jal	84c <printf>
      printf("  Sleep/pause may not be properly resetting time slices!\n");
 154:	00001517          	auipc	a0,0x1
 158:	b5450513          	addi	a0,a0,-1196 # ca8 <malloc+0x3a8>
 15c:	6f0000ef          	jal	84c <printf>
 160:	b7d1                	j	124 <main+0x124>
      printf("✓ SUCCESS: Stayed in Q%d (high priority maintained!)\n", info.priority);
 162:	00001517          	auipc	a0,0x1
 166:	a9650513          	addi	a0,a0,-1386 # bf8 <malloc+0x2f8>
 16a:	6e2000ef          	jal	84c <printf>
      printf("  Demonstrates I/O-bound processes get preferential treatment.\n");
 16e:	00001517          	auipc	a0,0x1
 172:	ac250513          	addi	a0,a0,-1342 # c30 <malloc+0x330>
 176:	6d6000ef          	jal	84c <printf>
 17a:	b76d                	j	124 <main+0x124>
  for(iter = 0; iter < 30; iter++) {
 17c:	2905                	addiw	s2,s2,1
 17e:	bf35                	j	ba <main+0xba>

0000000000000180 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 180:	1141                	addi	sp,sp,-16
 182:	e406                	sd	ra,8(sp)
 184:	e022                	sd	s0,0(sp)
 186:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 188:	e79ff0ef          	jal	0 <main>
  exit(r);
 18c:	288000ef          	jal	414 <exit>

0000000000000190 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 196:	87aa                	mv	a5,a0
 198:	0585                	addi	a1,a1,1
 19a:	0785                	addi	a5,a5,1
 19c:	fff5c703          	lbu	a4,-1(a1)
 1a0:	fee78fa3          	sb	a4,-1(a5)
 1a4:	fb75                	bnez	a4,198 <strcpy+0x8>
    ;
  return os;
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	addi	sp,sp,16
 1aa:	8082                	ret

00000000000001ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cb91                	beqz	a5,1ca <strcmp+0x1e>
 1b8:	0005c703          	lbu	a4,0(a1)
 1bc:	00f71763          	bne	a4,a5,1ca <strcmp+0x1e>
    p++, q++;
 1c0:	0505                	addi	a0,a0,1
 1c2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	fbe5                	bnez	a5,1b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ca:	0005c503          	lbu	a0,0(a1)
}
 1ce:	40a7853b          	subw	a0,a5,a0
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret

00000000000001d8 <strlen>:

uint
strlen(const char *s)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	cf91                	beqz	a5,1fe <strlen+0x26>
 1e4:	0505                	addi	a0,a0,1
 1e6:	87aa                	mv	a5,a0
 1e8:	86be                	mv	a3,a5
 1ea:	0785                	addi	a5,a5,1
 1ec:	fff7c703          	lbu	a4,-1(a5)
 1f0:	ff65                	bnez	a4,1e8 <strlen+0x10>
 1f2:	40a6853b          	subw	a0,a3,a0
 1f6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  for(n = 0; s[n]; n++)
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <strlen+0x20>

0000000000000202 <memset>:

void*
memset(void *dst, int c, uint n)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 208:	ca19                	beqz	a2,21e <memset+0x1c>
 20a:	87aa                	mv	a5,a0
 20c:	1602                	slli	a2,a2,0x20
 20e:	9201                	srli	a2,a2,0x20
 210:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 214:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 218:	0785                	addi	a5,a5,1
 21a:	fee79de3          	bne	a5,a4,214 <memset+0x12>
  }
  return dst;
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret

0000000000000224 <strchr>:

char*
strchr(const char *s, char c)
{
 224:	1141                	addi	sp,sp,-16
 226:	e422                	sd	s0,8(sp)
 228:	0800                	addi	s0,sp,16
  for(; *s; s++)
 22a:	00054783          	lbu	a5,0(a0)
 22e:	cb99                	beqz	a5,244 <strchr+0x20>
    if(*s == c)
 230:	00f58763          	beq	a1,a5,23e <strchr+0x1a>
  for(; *s; s++)
 234:	0505                	addi	a0,a0,1
 236:	00054783          	lbu	a5,0(a0)
 23a:	fbfd                	bnez	a5,230 <strchr+0xc>
      return (char*)s;
  return 0;
 23c:	4501                	li	a0,0
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
  return 0;
 244:	4501                	li	a0,0
 246:	bfe5                	j	23e <strchr+0x1a>

0000000000000248 <gets>:

char*
gets(char *buf, int max)
{
 248:	711d                	addi	sp,sp,-96
 24a:	ec86                	sd	ra,88(sp)
 24c:	e8a2                	sd	s0,80(sp)
 24e:	e4a6                	sd	s1,72(sp)
 250:	e0ca                	sd	s2,64(sp)
 252:	fc4e                	sd	s3,56(sp)
 254:	f852                	sd	s4,48(sp)
 256:	f456                	sd	s5,40(sp)
 258:	f05a                	sd	s6,32(sp)
 25a:	ec5e                	sd	s7,24(sp)
 25c:	1080                	addi	s0,sp,96
 25e:	8baa                	mv	s7,a0
 260:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 262:	892a                	mv	s2,a0
 264:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 266:	4aa9                	li	s5,10
 268:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 26a:	89a6                	mv	s3,s1
 26c:	2485                	addiw	s1,s1,1
 26e:	0344d663          	bge	s1,s4,29a <gets+0x52>
    cc = read(0, &c, 1);
 272:	4605                	li	a2,1
 274:	faf40593          	addi	a1,s0,-81
 278:	4501                	li	a0,0
 27a:	1b2000ef          	jal	42c <read>
    if(cc < 1)
 27e:	00a05e63          	blez	a0,29a <gets+0x52>
    buf[i++] = c;
 282:	faf44783          	lbu	a5,-81(s0)
 286:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 28a:	01578763          	beq	a5,s5,298 <gets+0x50>
 28e:	0905                	addi	s2,s2,1
 290:	fd679de3          	bne	a5,s6,26a <gets+0x22>
    buf[i++] = c;
 294:	89a6                	mv	s3,s1
 296:	a011                	j	29a <gets+0x52>
 298:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 29a:	99de                	add	s3,s3,s7
 29c:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a0:	855e                	mv	a0,s7
 2a2:	60e6                	ld	ra,88(sp)
 2a4:	6446                	ld	s0,80(sp)
 2a6:	64a6                	ld	s1,72(sp)
 2a8:	6906                	ld	s2,64(sp)
 2aa:	79e2                	ld	s3,56(sp)
 2ac:	7a42                	ld	s4,48(sp)
 2ae:	7aa2                	ld	s5,40(sp)
 2b0:	7b02                	ld	s6,32(sp)
 2b2:	6be2                	ld	s7,24(sp)
 2b4:	6125                	addi	sp,sp,96
 2b6:	8082                	ret

00000000000002b8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b8:	1101                	addi	sp,sp,-32
 2ba:	ec06                	sd	ra,24(sp)
 2bc:	e822                	sd	s0,16(sp)
 2be:	e04a                	sd	s2,0(sp)
 2c0:	1000                	addi	s0,sp,32
 2c2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c4:	4581                	li	a1,0
 2c6:	18e000ef          	jal	454 <open>
  if(fd < 0)
 2ca:	02054263          	bltz	a0,2ee <stat+0x36>
 2ce:	e426                	sd	s1,8(sp)
 2d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d2:	85ca                	mv	a1,s2
 2d4:	198000ef          	jal	46c <fstat>
 2d8:	892a                	mv	s2,a0
  close(fd);
 2da:	8526                	mv	a0,s1
 2dc:	160000ef          	jal	43c <close>
  return r;
 2e0:	64a2                	ld	s1,8(sp)
}
 2e2:	854a                	mv	a0,s2
 2e4:	60e2                	ld	ra,24(sp)
 2e6:	6442                	ld	s0,16(sp)
 2e8:	6902                	ld	s2,0(sp)
 2ea:	6105                	addi	sp,sp,32
 2ec:	8082                	ret
    return -1;
 2ee:	597d                	li	s2,-1
 2f0:	bfcd                	j	2e2 <stat+0x2a>

00000000000002f2 <atoi>:

int
atoi(const char *s)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f8:	00054683          	lbu	a3,0(a0)
 2fc:	fd06879b          	addiw	a5,a3,-48
 300:	0ff7f793          	zext.b	a5,a5
 304:	4625                	li	a2,9
 306:	02f66863          	bltu	a2,a5,336 <atoi+0x44>
 30a:	872a                	mv	a4,a0
  n = 0;
 30c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 30e:	0705                	addi	a4,a4,1
 310:	0025179b          	slliw	a5,a0,0x2
 314:	9fa9                	addw	a5,a5,a0
 316:	0017979b          	slliw	a5,a5,0x1
 31a:	9fb5                	addw	a5,a5,a3
 31c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 320:	00074683          	lbu	a3,0(a4)
 324:	fd06879b          	addiw	a5,a3,-48
 328:	0ff7f793          	zext.b	a5,a5
 32c:	fef671e3          	bgeu	a2,a5,30e <atoi+0x1c>
  return n;
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
  n = 0;
 336:	4501                	li	a0,0
 338:	bfe5                	j	330 <atoi+0x3e>

000000000000033a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 340:	02b57463          	bgeu	a0,a1,368 <memmove+0x2e>
    while(n-- > 0)
 344:	00c05f63          	blez	a2,362 <memmove+0x28>
 348:	1602                	slli	a2,a2,0x20
 34a:	9201                	srli	a2,a2,0x20
 34c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 350:	872a                	mv	a4,a0
      *dst++ = *src++;
 352:	0585                	addi	a1,a1,1
 354:	0705                	addi	a4,a4,1
 356:	fff5c683          	lbu	a3,-1(a1)
 35a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35e:	fef71ae3          	bne	a4,a5,352 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 362:	6422                	ld	s0,8(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret
    dst += n;
 368:	00c50733          	add	a4,a0,a2
    src += n;
 36c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36e:	fec05ae3          	blez	a2,362 <memmove+0x28>
 372:	fff6079b          	addiw	a5,a2,-1
 376:	1782                	slli	a5,a5,0x20
 378:	9381                	srli	a5,a5,0x20
 37a:	fff7c793          	not	a5,a5
 37e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 380:	15fd                	addi	a1,a1,-1
 382:	177d                	addi	a4,a4,-1
 384:	0005c683          	lbu	a3,0(a1)
 388:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38c:	fee79ae3          	bne	a5,a4,380 <memmove+0x46>
 390:	bfc9                	j	362 <memmove+0x28>

0000000000000392 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 392:	1141                	addi	sp,sp,-16
 394:	e422                	sd	s0,8(sp)
 396:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 398:	ca05                	beqz	a2,3c8 <memcmp+0x36>
 39a:	fff6069b          	addiw	a3,a2,-1
 39e:	1682                	slli	a3,a3,0x20
 3a0:	9281                	srli	a3,a3,0x20
 3a2:	0685                	addi	a3,a3,1
 3a4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a6:	00054783          	lbu	a5,0(a0)
 3aa:	0005c703          	lbu	a4,0(a1)
 3ae:	00e79863          	bne	a5,a4,3be <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b2:	0505                	addi	a0,a0,1
    p2++;
 3b4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b6:	fed518e3          	bne	a0,a3,3a6 <memcmp+0x14>
  }
  return 0;
 3ba:	4501                	li	a0,0
 3bc:	a019                	j	3c2 <memcmp+0x30>
      return *p1 - *p2;
 3be:	40e7853b          	subw	a0,a5,a4
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret
  return 0;
 3c8:	4501                	li	a0,0
 3ca:	bfe5                	j	3c2 <memcmp+0x30>

00000000000003cc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e406                	sd	ra,8(sp)
 3d0:	e022                	sd	s0,0(sp)
 3d2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d4:	f67ff0ef          	jal	33a <memmove>
}
 3d8:	60a2                	ld	ra,8(sp)
 3da:	6402                	ld	s0,0(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret

00000000000003e0 <sbrk>:

char *
sbrk(int n) {
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e406                	sd	ra,8(sp)
 3e4:	e022                	sd	s0,0(sp)
 3e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3e8:	4585                	li	a1,1
 3ea:	0b2000ef          	jal	49c <sys_sbrk>
}
 3ee:	60a2                	ld	ra,8(sp)
 3f0:	6402                	ld	s0,0(sp)
 3f2:	0141                	addi	sp,sp,16
 3f4:	8082                	ret

00000000000003f6 <sbrklazy>:

char *
sbrklazy(int n) {
 3f6:	1141                	addi	sp,sp,-16
 3f8:	e406                	sd	ra,8(sp)
 3fa:	e022                	sd	s0,0(sp)
 3fc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3fe:	4589                	li	a1,2
 400:	09c000ef          	jal	49c <sys_sbrk>
}
 404:	60a2                	ld	ra,8(sp)
 406:	6402                	ld	s0,0(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret

000000000000040c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40c:	4885                	li	a7,1
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <exit>:
.global exit
exit:
 li a7, SYS_exit
 414:	4889                	li	a7,2
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <wait>:
.global wait
wait:
 li a7, SYS_wait
 41c:	488d                	li	a7,3
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 424:	4891                	li	a7,4
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <read>:
.global read
read:
 li a7, SYS_read
 42c:	4895                	li	a7,5
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <write>:
.global write
write:
 li a7, SYS_write
 434:	48c1                	li	a7,16
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <close>:
.global close
close:
 li a7, SYS_close
 43c:	48d5                	li	a7,21
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <kill>:
.global kill
kill:
 li a7, SYS_kill
 444:	4899                	li	a7,6
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <exec>:
.global exec
exec:
 li a7, SYS_exec
 44c:	489d                	li	a7,7
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <open>:
.global open
open:
 li a7, SYS_open
 454:	48bd                	li	a7,15
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 45c:	48c5                	li	a7,17
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 464:	48c9                	li	a7,18
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 46c:	48a1                	li	a7,8
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <link>:
.global link
link:
 li a7, SYS_link
 474:	48cd                	li	a7,19
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 47c:	48d1                	li	a7,20
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 484:	48a5                	li	a7,9
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <dup>:
.global dup
dup:
 li a7, SYS_dup
 48c:	48a9                	li	a7,10
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 494:	48ad                	li	a7,11
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 49c:	48b1                	li	a7,12
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4a4:	48b5                	li	a7,13
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ac:	48b9                	li	a7,14
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4b4:	48d9                	li	a7,22
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4bc:	48dd                	li	a7,23
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c4:	1101                	addi	sp,sp,-32
 4c6:	ec06                	sd	ra,24(sp)
 4c8:	e822                	sd	s0,16(sp)
 4ca:	1000                	addi	s0,sp,32
 4cc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d0:	4605                	li	a2,1
 4d2:	fef40593          	addi	a1,s0,-17
 4d6:	f5fff0ef          	jal	434 <write>
}
 4da:	60e2                	ld	ra,24(sp)
 4dc:	6442                	ld	s0,16(sp)
 4de:	6105                	addi	sp,sp,32
 4e0:	8082                	ret

00000000000004e2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4e2:	715d                	addi	sp,sp,-80
 4e4:	e486                	sd	ra,72(sp)
 4e6:	e0a2                	sd	s0,64(sp)
 4e8:	f84a                	sd	s2,48(sp)
 4ea:	0880                	addi	s0,sp,80
 4ec:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4ee:	c299                	beqz	a3,4f4 <printint+0x12>
 4f0:	0805c363          	bltz	a1,576 <printint+0x94>
  neg = 0;
 4f4:	4881                	li	a7,0
 4f6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4fa:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4fc:	00000517          	auipc	a0,0x0
 500:	7f450513          	addi	a0,a0,2036 # cf0 <digits>
 504:	883e                	mv	a6,a5
 506:	2785                	addiw	a5,a5,1
 508:	02c5f733          	remu	a4,a1,a2
 50c:	972a                	add	a4,a4,a0
 50e:	00074703          	lbu	a4,0(a4)
 512:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 516:	872e                	mv	a4,a1
 518:	02c5d5b3          	divu	a1,a1,a2
 51c:	0685                	addi	a3,a3,1
 51e:	fec773e3          	bgeu	a4,a2,504 <printint+0x22>
  if(neg)
 522:	00088b63          	beqz	a7,538 <printint+0x56>
    buf[i++] = '-';
 526:	fd078793          	addi	a5,a5,-48
 52a:	97a2                	add	a5,a5,s0
 52c:	02d00713          	li	a4,45
 530:	fee78423          	sb	a4,-24(a5)
 534:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 538:	02f05a63          	blez	a5,56c <printint+0x8a>
 53c:	fc26                	sd	s1,56(sp)
 53e:	f44e                	sd	s3,40(sp)
 540:	fb840713          	addi	a4,s0,-72
 544:	00f704b3          	add	s1,a4,a5
 548:	fff70993          	addi	s3,a4,-1
 54c:	99be                	add	s3,s3,a5
 54e:	37fd                	addiw	a5,a5,-1
 550:	1782                	slli	a5,a5,0x20
 552:	9381                	srli	a5,a5,0x20
 554:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 558:	fff4c583          	lbu	a1,-1(s1)
 55c:	854a                	mv	a0,s2
 55e:	f67ff0ef          	jal	4c4 <putc>
  while(--i >= 0)
 562:	14fd                	addi	s1,s1,-1
 564:	ff349ae3          	bne	s1,s3,558 <printint+0x76>
 568:	74e2                	ld	s1,56(sp)
 56a:	79a2                	ld	s3,40(sp)
}
 56c:	60a6                	ld	ra,72(sp)
 56e:	6406                	ld	s0,64(sp)
 570:	7942                	ld	s2,48(sp)
 572:	6161                	addi	sp,sp,80
 574:	8082                	ret
    x = -xx;
 576:	40b005b3          	neg	a1,a1
    neg = 1;
 57a:	4885                	li	a7,1
    x = -xx;
 57c:	bfad                	j	4f6 <printint+0x14>

000000000000057e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57e:	711d                	addi	sp,sp,-96
 580:	ec86                	sd	ra,88(sp)
 582:	e8a2                	sd	s0,80(sp)
 584:	e0ca                	sd	s2,64(sp)
 586:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 588:	0005c903          	lbu	s2,0(a1)
 58c:	28090663          	beqz	s2,818 <vprintf+0x29a>
 590:	e4a6                	sd	s1,72(sp)
 592:	fc4e                	sd	s3,56(sp)
 594:	f852                	sd	s4,48(sp)
 596:	f456                	sd	s5,40(sp)
 598:	f05a                	sd	s6,32(sp)
 59a:	ec5e                	sd	s7,24(sp)
 59c:	e862                	sd	s8,16(sp)
 59e:	e466                	sd	s9,8(sp)
 5a0:	8b2a                	mv	s6,a0
 5a2:	8a2e                	mv	s4,a1
 5a4:	8bb2                	mv	s7,a2
  state = 0;
 5a6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5a8:	4481                	li	s1,0
 5aa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ac:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5b0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	06c00c93          	li	s9,108
 5b8:	a005                	j	5d8 <vprintf+0x5a>
        putc(fd, c0);
 5ba:	85ca                	mv	a1,s2
 5bc:	855a                	mv	a0,s6
 5be:	f07ff0ef          	jal	4c4 <putc>
 5c2:	a019                	j	5c8 <vprintf+0x4a>
    } else if(state == '%'){
 5c4:	03598263          	beq	s3,s5,5e8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5c8:	2485                	addiw	s1,s1,1
 5ca:	8726                	mv	a4,s1
 5cc:	009a07b3          	add	a5,s4,s1
 5d0:	0007c903          	lbu	s2,0(a5)
 5d4:	22090a63          	beqz	s2,808 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5dc:	fe0994e3          	bnez	s3,5c4 <vprintf+0x46>
      if(c0 == '%'){
 5e0:	fd579de3          	bne	a5,s5,5ba <vprintf+0x3c>
        state = '%';
 5e4:	89be                	mv	s3,a5
 5e6:	b7cd                	j	5c8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5e8:	00ea06b3          	add	a3,s4,a4
 5ec:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5f0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5f2:	c681                	beqz	a3,5fa <vprintf+0x7c>
 5f4:	9752                	add	a4,a4,s4
 5f6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5fa:	05878363          	beq	a5,s8,640 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5fe:	05978d63          	beq	a5,s9,658 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 602:	07500713          	li	a4,117
 606:	0ee78763          	beq	a5,a4,6f4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 60a:	07800713          	li	a4,120
 60e:	12e78963          	beq	a5,a4,740 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 612:	07000713          	li	a4,112
 616:	14e78e63          	beq	a5,a4,772 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 61a:	06300713          	li	a4,99
 61e:	18e78e63          	beq	a5,a4,7ba <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 622:	07300713          	li	a4,115
 626:	1ae78463          	beq	a5,a4,7ce <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 62a:	02500713          	li	a4,37
 62e:	04e79563          	bne	a5,a4,678 <vprintf+0xfa>
        putc(fd, '%');
 632:	02500593          	li	a1,37
 636:	855a                	mv	a0,s6
 638:	e8dff0ef          	jal	4c4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 63c:	4981                	li	s3,0
 63e:	b769                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 640:	008b8913          	addi	s2,s7,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000ba583          	lw	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e95ff0ef          	jal	4e2 <printint>
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bf8d                	j	5c8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 658:	06400793          	li	a5,100
 65c:	02f68963          	beq	a3,a5,68e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 660:	06c00793          	li	a5,108
 664:	04f68263          	beq	a3,a5,6a8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 668:	07500793          	li	a5,117
 66c:	0af68063          	beq	a3,a5,70c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 670:	07800793          	li	a5,120
 674:	0ef68263          	beq	a3,a5,758 <vprintf+0x1da>
        putc(fd, '%');
 678:	02500593          	li	a1,37
 67c:	855a                	mv	a0,s6
 67e:	e47ff0ef          	jal	4c4 <putc>
        putc(fd, c0);
 682:	85ca                	mv	a1,s2
 684:	855a                	mv	a0,s6
 686:	e3fff0ef          	jal	4c4 <putc>
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bf35                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68e:	008b8913          	addi	s2,s7,8
 692:	4685                	li	a3,1
 694:	4629                	li	a2,10
 696:	000bb583          	ld	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	e47ff0ef          	jal	4e2 <printint>
        i += 1;
 6a0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a2:	8bca                	mv	s7,s2
      state = 0;
 6a4:	4981                	li	s3,0
        i += 1;
 6a6:	b70d                	j	5c8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6a8:	06400793          	li	a5,100
 6ac:	02f60763          	beq	a2,a5,6da <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6b0:	07500793          	li	a5,117
 6b4:	06f60963          	beq	a2,a5,726 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6b8:	07800793          	li	a5,120
 6bc:	faf61ee3          	bne	a2,a5,678 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e15ff0ef          	jal	4e2 <printint>
        i += 2;
 6d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	bdc5                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4685                	li	a3,1
 6e0:	4629                	li	a2,10
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	dfbff0ef          	jal	4e2 <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	bdd9                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4629                	li	a2,10
 6fc:	000be583          	lwu	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	de1ff0ef          	jal	4e2 <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd7d                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4629                	li	a2,10
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	dc9ff0ef          	jal	4e2 <printint>
        i += 1;
 71e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 1;
 724:	b555                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4629                	li	a2,10
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	dafff0ef          	jal	4e2 <printint>
        i += 2;
 738:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
        i += 2;
 73e:	b569                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 740:	008b8913          	addi	s2,s7,8
 744:	4681                	li	a3,0
 746:	4641                	li	a2,16
 748:	000be583          	lwu	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	d95ff0ef          	jal	4e2 <printint>
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	bd8d                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 758:	008b8913          	addi	s2,s7,8
 75c:	4681                	li	a3,0
 75e:	4641                	li	a2,16
 760:	000bb583          	ld	a1,0(s7)
 764:	855a                	mv	a0,s6
 766:	d7dff0ef          	jal	4e2 <printint>
        i += 1;
 76a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 76c:	8bca                	mv	s7,s2
      state = 0;
 76e:	4981                	li	s3,0
        i += 1;
 770:	bda1                	j	5c8 <vprintf+0x4a>
 772:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 774:	008b8d13          	addi	s10,s7,8
 778:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 77c:	03000593          	li	a1,48
 780:	855a                	mv	a0,s6
 782:	d43ff0ef          	jal	4c4 <putc>
  putc(fd, 'x');
 786:	07800593          	li	a1,120
 78a:	855a                	mv	a0,s6
 78c:	d39ff0ef          	jal	4c4 <putc>
 790:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 792:	00000b97          	auipc	s7,0x0
 796:	55eb8b93          	addi	s7,s7,1374 # cf0 <digits>
 79a:	03c9d793          	srli	a5,s3,0x3c
 79e:	97de                	add	a5,a5,s7
 7a0:	0007c583          	lbu	a1,0(a5)
 7a4:	855a                	mv	a0,s6
 7a6:	d1fff0ef          	jal	4c4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7aa:	0992                	slli	s3,s3,0x4
 7ac:	397d                	addiw	s2,s2,-1
 7ae:	fe0916e3          	bnez	s2,79a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7b2:	8bea                	mv	s7,s10
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	6d02                	ld	s10,0(sp)
 7b8:	bd01                	j	5c8 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7ba:	008b8913          	addi	s2,s7,8
 7be:	000bc583          	lbu	a1,0(s7)
 7c2:	855a                	mv	a0,s6
 7c4:	d01ff0ef          	jal	4c4 <putc>
 7c8:	8bca                	mv	s7,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	bbf5                	j	5c8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7ce:	008b8993          	addi	s3,s7,8
 7d2:	000bb903          	ld	s2,0(s7)
 7d6:	00090f63          	beqz	s2,7f4 <vprintf+0x276>
        for(; *s; s++)
 7da:	00094583          	lbu	a1,0(s2)
 7de:	c195                	beqz	a1,802 <vprintf+0x284>
          putc(fd, *s);
 7e0:	855a                	mv	a0,s6
 7e2:	ce3ff0ef          	jal	4c4 <putc>
        for(; *s; s++)
 7e6:	0905                	addi	s2,s2,1
 7e8:	00094583          	lbu	a1,0(s2)
 7ec:	f9f5                	bnez	a1,7e0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ee:	8bce                	mv	s7,s3
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	bbd9                	j	5c8 <vprintf+0x4a>
          s = "(null)";
 7f4:	00000917          	auipc	s2,0x0
 7f8:	4f490913          	addi	s2,s2,1268 # ce8 <malloc+0x3e8>
        for(; *s; s++)
 7fc:	02800593          	li	a1,40
 800:	b7c5                	j	7e0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 802:	8bce                	mv	s7,s3
      state = 0;
 804:	4981                	li	s3,0
 806:	b3c9                	j	5c8 <vprintf+0x4a>
 808:	64a6                	ld	s1,72(sp)
 80a:	79e2                	ld	s3,56(sp)
 80c:	7a42                	ld	s4,48(sp)
 80e:	7aa2                	ld	s5,40(sp)
 810:	7b02                	ld	s6,32(sp)
 812:	6be2                	ld	s7,24(sp)
 814:	6c42                	ld	s8,16(sp)
 816:	6ca2                	ld	s9,8(sp)
    }
  }
}
 818:	60e6                	ld	ra,88(sp)
 81a:	6446                	ld	s0,80(sp)
 81c:	6906                	ld	s2,64(sp)
 81e:	6125                	addi	sp,sp,96
 820:	8082                	ret

0000000000000822 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 822:	715d                	addi	sp,sp,-80
 824:	ec06                	sd	ra,24(sp)
 826:	e822                	sd	s0,16(sp)
 828:	1000                	addi	s0,sp,32
 82a:	e010                	sd	a2,0(s0)
 82c:	e414                	sd	a3,8(s0)
 82e:	e818                	sd	a4,16(s0)
 830:	ec1c                	sd	a5,24(s0)
 832:	03043023          	sd	a6,32(s0)
 836:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 83a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83e:	8622                	mv	a2,s0
 840:	d3fff0ef          	jal	57e <vprintf>
}
 844:	60e2                	ld	ra,24(sp)
 846:	6442                	ld	s0,16(sp)
 848:	6161                	addi	sp,sp,80
 84a:	8082                	ret

000000000000084c <printf>:

void
printf(const char *fmt, ...)
{
 84c:	711d                	addi	sp,sp,-96
 84e:	ec06                	sd	ra,24(sp)
 850:	e822                	sd	s0,16(sp)
 852:	1000                	addi	s0,sp,32
 854:	e40c                	sd	a1,8(s0)
 856:	e810                	sd	a2,16(s0)
 858:	ec14                	sd	a3,24(s0)
 85a:	f018                	sd	a4,32(s0)
 85c:	f41c                	sd	a5,40(s0)
 85e:	03043823          	sd	a6,48(s0)
 862:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 866:	00840613          	addi	a2,s0,8
 86a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 86e:	85aa                	mv	a1,a0
 870:	4505                	li	a0,1
 872:	d0dff0ef          	jal	57e <vprintf>
}
 876:	60e2                	ld	ra,24(sp)
 878:	6442                	ld	s0,16(sp)
 87a:	6125                	addi	sp,sp,96
 87c:	8082                	ret

000000000000087e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87e:	1141                	addi	sp,sp,-16
 880:	e422                	sd	s0,8(sp)
 882:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 884:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 888:	00001797          	auipc	a5,0x1
 88c:	7787b783          	ld	a5,1912(a5) # 2000 <freep>
 890:	a02d                	j	8ba <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 892:	4618                	lw	a4,8(a2)
 894:	9f2d                	addw	a4,a4,a1
 896:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 89a:	6398                	ld	a4,0(a5)
 89c:	6310                	ld	a2,0(a4)
 89e:	a83d                	j	8dc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a0:	ff852703          	lw	a4,-8(a0)
 8a4:	9f31                	addw	a4,a4,a2
 8a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8a8:	ff053683          	ld	a3,-16(a0)
 8ac:	a091                	j	8f0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ae:	6398                	ld	a4,0(a5)
 8b0:	00e7e463          	bltu	a5,a4,8b8 <free+0x3a>
 8b4:	00e6ea63          	bltu	a3,a4,8c8 <free+0x4a>
{
 8b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ba:	fed7fae3          	bgeu	a5,a3,8ae <free+0x30>
 8be:	6398                	ld	a4,0(a5)
 8c0:	00e6e463          	bltu	a3,a4,8c8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c4:	fee7eae3          	bltu	a5,a4,8b8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8c8:	ff852583          	lw	a1,-8(a0)
 8cc:	6390                	ld	a2,0(a5)
 8ce:	02059813          	slli	a6,a1,0x20
 8d2:	01c85713          	srli	a4,a6,0x1c
 8d6:	9736                	add	a4,a4,a3
 8d8:	fae60de3          	beq	a2,a4,892 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e0:	4790                	lw	a2,8(a5)
 8e2:	02061593          	slli	a1,a2,0x20
 8e6:	01c5d713          	srli	a4,a1,0x1c
 8ea:	973e                	add	a4,a4,a5
 8ec:	fae68ae3          	beq	a3,a4,8a0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f2:	00001717          	auipc	a4,0x1
 8f6:	70f73723          	sd	a5,1806(a4) # 2000 <freep>
}
 8fa:	6422                	ld	s0,8(sp)
 8fc:	0141                	addi	sp,sp,16
 8fe:	8082                	ret

0000000000000900 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 900:	7139                	addi	sp,sp,-64
 902:	fc06                	sd	ra,56(sp)
 904:	f822                	sd	s0,48(sp)
 906:	f426                	sd	s1,40(sp)
 908:	ec4e                	sd	s3,24(sp)
 90a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 90c:	02051493          	slli	s1,a0,0x20
 910:	9081                	srli	s1,s1,0x20
 912:	04bd                	addi	s1,s1,15
 914:	8091                	srli	s1,s1,0x4
 916:	0014899b          	addiw	s3,s1,1
 91a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 91c:	00001517          	auipc	a0,0x1
 920:	6e453503          	ld	a0,1764(a0) # 2000 <freep>
 924:	c915                	beqz	a0,958 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 926:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 928:	4798                	lw	a4,8(a5)
 92a:	08977a63          	bgeu	a4,s1,9be <malloc+0xbe>
 92e:	f04a                	sd	s2,32(sp)
 930:	e852                	sd	s4,16(sp)
 932:	e456                	sd	s5,8(sp)
 934:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 936:	8a4e                	mv	s4,s3
 938:	0009871b          	sext.w	a4,s3
 93c:	6685                	lui	a3,0x1
 93e:	00d77363          	bgeu	a4,a3,944 <malloc+0x44>
 942:	6a05                	lui	s4,0x1
 944:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 948:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 94c:	00001917          	auipc	s2,0x1
 950:	6b490913          	addi	s2,s2,1716 # 2000 <freep>
  if(p == SBRK_ERROR)
 954:	5afd                	li	s5,-1
 956:	a081                	j	996 <malloc+0x96>
 958:	f04a                	sd	s2,32(sp)
 95a:	e852                	sd	s4,16(sp)
 95c:	e456                	sd	s5,8(sp)
 95e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 960:	00001797          	auipc	a5,0x1
 964:	6b078793          	addi	a5,a5,1712 # 2010 <base>
 968:	00001717          	auipc	a4,0x1
 96c:	68f73c23          	sd	a5,1688(a4) # 2000 <freep>
 970:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 972:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 976:	b7c1                	j	936 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 978:	6398                	ld	a4,0(a5)
 97a:	e118                	sd	a4,0(a0)
 97c:	a8a9                	j	9d6 <malloc+0xd6>
  hp->s.size = nu;
 97e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 982:	0541                	addi	a0,a0,16
 984:	efbff0ef          	jal	87e <free>
  return freep;
 988:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 98c:	c12d                	beqz	a0,9ee <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 990:	4798                	lw	a4,8(a5)
 992:	02977263          	bgeu	a4,s1,9b6 <malloc+0xb6>
    if(p == freep)
 996:	00093703          	ld	a4,0(s2)
 99a:	853e                	mv	a0,a5
 99c:	fef719e3          	bne	a4,a5,98e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9a0:	8552                	mv	a0,s4
 9a2:	a3fff0ef          	jal	3e0 <sbrk>
  if(p == SBRK_ERROR)
 9a6:	fd551ce3          	bne	a0,s5,97e <malloc+0x7e>
        return 0;
 9aa:	4501                	li	a0,0
 9ac:	7902                	ld	s2,32(sp)
 9ae:	6a42                	ld	s4,16(sp)
 9b0:	6aa2                	ld	s5,8(sp)
 9b2:	6b02                	ld	s6,0(sp)
 9b4:	a03d                	j	9e2 <malloc+0xe2>
 9b6:	7902                	ld	s2,32(sp)
 9b8:	6a42                	ld	s4,16(sp)
 9ba:	6aa2                	ld	s5,8(sp)
 9bc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9be:	fae48de3          	beq	s1,a4,978 <malloc+0x78>
        p->s.size -= nunits;
 9c2:	4137073b          	subw	a4,a4,s3
 9c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c8:	02071693          	slli	a3,a4,0x20
 9cc:	01c6d713          	srli	a4,a3,0x1c
 9d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d6:	00001717          	auipc	a4,0x1
 9da:	62a73523          	sd	a0,1578(a4) # 2000 <freep>
      return (void*)(p + 1);
 9de:	01078513          	addi	a0,a5,16
  }
}
 9e2:	70e2                	ld	ra,56(sp)
 9e4:	7442                	ld	s0,48(sp)
 9e6:	74a2                	ld	s1,40(sp)
 9e8:	69e2                	ld	s3,24(sp)
 9ea:	6121                	addi	sp,sp,64
 9ec:	8082                	ret
 9ee:	7902                	ld	s2,32(sp)
 9f0:	6a42                	ld	s4,16(sp)
 9f2:	6aa2                	ld	s5,8(sp)
 9f4:	6b02                	ld	s6,0(sp)
 9f6:	b7f5                	j	9e2 <malloc+0xe2>
