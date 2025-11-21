
user/_iobound:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// I/O-bound test: Frequent yields (sleeps)
// Should stay in Q0 or Q1 (high priority) throughout
int
main(int argc, char *argv[])
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	0100                	addi	s0,sp,128
  struct procinfo info;
  int iter;
  
  printf("=== Comprehensive I/O-Bound Test ===\n");
  1c:	00001517          	auipc	a0,0x1
  20:	9d450513          	addi	a0,a0,-1580 # 9f0 <malloc+0xea>
  24:	029000ef          	jal	ra,84c <printf>
  printf("This process will alternate between brief work and sleep.\n");
  28:	00001517          	auipc	a0,0x1
  2c:	9f050513          	addi	a0,a0,-1552 # a18 <malloc+0x112>
  30:	01d000ef          	jal	ra,84c <printf>
  printf("It should STAY in Q0 (never demote) because it yields frequently.\n\n");
  34:	00001517          	auipc	a0,0x1
  38:	a2450513          	addi	a0,a0,-1500 # a58 <malloc+0x152>
  3c:	011000ef          	jal	ra,84c <printf>
  
  if(getprocinfo(&info) == 0) {
  40:	f9040513          	addi	a0,s0,-112
  44:	47c000ef          	jal	ra,4c0 <getprocinfo>
  48:	c121                	beqz	a0,88 <main+0x88>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
           info.pid, info.priority, info.time_slices);
  }
  
  printf("Running 30 iterations of: brief_work() -> sleep(1_tick)\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	a8650513          	addi	a0,a0,-1402 # ad0 <malloc+0x1ca>
  52:	7fa000ef          	jal	ra,84c <printf>
  printf("Expected: Priority stays Q0 throughout (slices reset after sleep)\n\n");
  56:	00001517          	auipc	a0,0x1
  5a:	aba50513          	addi	a0,a0,-1350 # b10 <malloc+0x20a>
  5e:	7ee000ef          	jal	ra,84c <printf>
  62:	4a05                	li	s4,1
  64:	4981                	li	s3,0
  // Simulate I/O-bound behavior: short bursts with frequent sleeps
  // 30 iterations × 1 second per iteration = ~30 seconds total
  for(iter = 0; iter < 30; iter++) {
    // Do minimal work (much less than 2 ticks - the Q0 quantum)
    volatile int dummy = 0;
    for(long j = 0; j < 2000000; j++) {  // Small computation
  66:	001e84b7          	lui	s1,0x1e8
  6a:	48048493          	addi	s1,s1,1152 # 1e8480 <base+0x1e7470>
    // This is the KEY behavior: yields before exhausting quantum
    pause(1);  // Sleep for 1 tick (~100ms)
    
    // Check priority after wakeup
    if(getprocinfo(&info) == 0) {
      if(iter % 5 == 0) {  // Print every 5 iterations to reduce clutter
  6e:	4b95                	li	s7,5
        printf("Iteration %d: Priority=Q%d, TimeSlices=%d\n", 
  70:	00001d17          	auipc	s10,0x1
  74:	ae8d0d13          	addi	s10,s10,-1304 # b58 <malloc+0x252>
               iter, info.priority, info.time_slices);
      }
    }
    
    // Verify we stay in high priority
    if(iter == 10 || iter == 20 || iter == 29) {
  78:	4b29                	li	s6,10
  for(iter = 0; iter < 30; iter++) {
  7a:	4af5                	li	s5,29
      if(getprocinfo(&info) == 0) {
        printf("  [Checkpoint] Still at Q%d\n", info.priority);
  7c:	00001c97          	auipc	s9,0x1
  80:	b0cc8c93          	addi	s9,s9,-1268 # b88 <malloc+0x282>
    if(iter == 10 || iter == 20 || iter == 29) {
  84:	4c51                	li	s8,20
  86:	a045                	j	126 <main+0x126>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
  88:	f9c42683          	lw	a3,-100(s0)
  8c:	f9842603          	lw	a2,-104(s0)
  90:	f9042583          	lw	a1,-112(s0)
  94:	00001517          	auipc	a0,0x1
  98:	a0c50513          	addi	a0,a0,-1524 # aa0 <malloc+0x19a>
  9c:	7b0000ef          	jal	ra,84c <printf>
  a0:	b76d                	j	4a <main+0x4a>
        printf("Iteration %d: Priority=Q%d, TimeSlices=%d\n", 
  a2:	f9c42683          	lw	a3,-100(s0)
  a6:	f9842603          	lw	a2,-104(s0)
  aa:	85ca                	mv	a1,s2
  ac:	856a                	mv	a0,s10
  ae:	79e000ef          	jal	ra,84c <printf>
  b2:	a05d                	j	158 <main+0x158>
    }
  }
  
  printf("\n");
  if(getprocinfo(&info) == 0) {
    printf("Final Result: Priority=Q%d, TimeSlices=%d\n", 
  b4:	f9c42603          	lw	a2,-100(s0)
  b8:	f9842583          	lw	a1,-104(s0)
  bc:	00001517          	auipc	a0,0x1
  c0:	aec50513          	addi	a0,a0,-1300 # ba8 <malloc+0x2a2>
  c4:	788000ef          	jal	ra,84c <printf>
           info.priority, info.time_slices);
    
    if(info.priority <= 1) {
  c8:	f9842583          	lw	a1,-104(s0)
  cc:	4785                	li	a5,1
  ce:	00b7df63          	bge	a5,a1,ec <main+0xec>
      printf("✓ SUCCESS: Stayed in Q%d (high priority maintained!)\n", info.priority);
      printf("  Demonstrates I/O-bound processes get preferential treatment.\n");
    } else {
      printf("✗ FAILED: Demoted to Q%d (should have stayed Q0/Q1)\n", info.priority);
  d2:	00001517          	auipc	a0,0x1
  d6:	b7e50513          	addi	a0,a0,-1154 # c50 <malloc+0x34a>
  da:	772000ef          	jal	ra,84c <printf>
      printf("  Sleep/pause may not be properly resetting time slices!\n");
  de:	00001517          	auipc	a0,0x1
  e2:	baa50513          	addi	a0,a0,-1110 # c88 <malloc+0x382>
  e6:	766000ef          	jal	ra,84c <printf>
  ea:	a869                	j	184 <main+0x184>
      printf("✓ SUCCESS: Stayed in Q%d (high priority maintained!)\n", info.priority);
  ec:	00001517          	auipc	a0,0x1
  f0:	aec50513          	addi	a0,a0,-1300 # bd8 <malloc+0x2d2>
  f4:	758000ef          	jal	ra,84c <printf>
      printf("  Demonstrates I/O-bound processes get preferential treatment.\n");
  f8:	00001517          	auipc	a0,0x1
  fc:	b1850513          	addi	a0,a0,-1256 # c10 <malloc+0x30a>
 100:	74c000ef          	jal	ra,84c <printf>
 104:	a041                	j	184 <main+0x184>
      if(getprocinfo(&info) == 0) {
 106:	f9040513          	addi	a0,s0,-112
 10a:	3b6000ef          	jal	ra,4c0 <getprocinfo>
 10e:	e911                	bnez	a0,122 <main+0x122>
        printf("  [Checkpoint] Still at Q%d\n", info.priority);
 110:	f9842583          	lw	a1,-104(s0)
 114:	8566                	mv	a0,s9
 116:	736000ef          	jal	ra,84c <printf>
  for(iter = 0; iter < 30; iter++) {
 11a:	000a079b          	sext.w	a5,s4
 11e:	04fac863          	blt	s5,a5,16e <main+0x16e>
 122:	2985                	addiw	s3,s3,1
 124:	2a05                	addiw	s4,s4,1
 126:	0009891b          	sext.w	s2,s3
    volatile int dummy = 0;
 12a:	f8042623          	sw	zero,-116(s0)
    for(long j = 0; j < 2000000; j++) {  // Small computation
 12e:	4781                	li	a5,0
      dummy = dummy + j;
 130:	f8c42703          	lw	a4,-116(s0)
 134:	9f3d                	addw	a4,a4,a5
 136:	f8e42623          	sw	a4,-116(s0)
    for(long j = 0; j < 2000000; j++) {  // Small computation
 13a:	0785                	addi	a5,a5,1
 13c:	fe979ae3          	bne	a5,s1,130 <main+0x130>
    pause(1);  // Sleep for 1 tick (~100ms)
 140:	4505                	li	a0,1
 142:	36e000ef          	jal	ra,4b0 <pause>
    if(getprocinfo(&info) == 0) {
 146:	f9040513          	addi	a0,s0,-112
 14a:	376000ef          	jal	ra,4c0 <getprocinfo>
      if(iter % 5 == 0) {  // Print every 5 iterations to reduce clutter
 14e:	037967bb          	remw	a5,s2,s7
 152:	8fc9                	or	a5,a5,a0
 154:	2781                	sext.w	a5,a5
 156:	d7b1                	beqz	a5,a2 <main+0xa2>
    if(iter == 10 || iter == 20 || iter == 29) {
 158:	fb6907e3          	beq	s2,s6,106 <main+0x106>
 15c:	fb8905e3          	beq	s2,s8,106 <main+0x106>
 160:	fb591de3          	bne	s2,s5,11a <main+0x11a>
      if(getprocinfo(&info) == 0) {
 164:	f9040513          	addi	a0,s0,-112
 168:	358000ef          	jal	ra,4c0 <getprocinfo>
 16c:	d155                	beqz	a0,110 <main+0x110>
  printf("\n");
 16e:	00001517          	auipc	a0,0x1
 172:	b5250513          	addi	a0,a0,-1198 # cc0 <malloc+0x3ba>
 176:	6d6000ef          	jal	ra,84c <printf>
  if(getprocinfo(&info) == 0) {
 17a:	f9040513          	addi	a0,s0,-112
 17e:	342000ef          	jal	ra,4c0 <getprocinfo>
 182:	d90d                	beqz	a0,b4 <main+0xb4>
    }
  }
  
  exit(0);
 184:	4501                	li	a0,0
 186:	29a000ef          	jal	ra,420 <exit>

000000000000018a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e406                	sd	ra,8(sp)
 18e:	e022                	sd	s0,0(sp)
 190:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 192:	e6fff0ef          	jal	ra,0 <main>
  exit(r);
 196:	28a000ef          	jal	ra,420 <exit>

000000000000019a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a0:	87aa                	mv	a5,a0
 1a2:	0585                	addi	a1,a1,1
 1a4:	0785                	addi	a5,a5,1
 1a6:	fff5c703          	lbu	a4,-1(a1)
 1aa:	fee78fa3          	sb	a4,-1(a5)
 1ae:	fb75                	bnez	a4,1a2 <strcpy+0x8>
    ;
  return os;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cb91                	beqz	a5,1d4 <strcmp+0x1e>
 1c2:	0005c703          	lbu	a4,0(a1)
 1c6:	00f71763          	bne	a4,a5,1d4 <strcmp+0x1e>
    p++, q++;
 1ca:	0505                	addi	a0,a0,1
 1cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	fbe5                	bnez	a5,1c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d4:	0005c503          	lbu	a0,0(a1)
}
 1d8:	40a7853b          	subw	a0,a5,a0
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret

00000000000001e2 <strlen>:

uint
strlen(const char *s)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	cf91                	beqz	a5,208 <strlen+0x26>
 1ee:	0505                	addi	a0,a0,1
 1f0:	87aa                	mv	a5,a0
 1f2:	4685                	li	a3,1
 1f4:	9e89                	subw	a3,a3,a0
 1f6:	00f6853b          	addw	a0,a3,a5
 1fa:	0785                	addi	a5,a5,1
 1fc:	fff7c703          	lbu	a4,-1(a5)
 200:	fb7d                	bnez	a4,1f6 <strlen+0x14>
    ;
  return n;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
  for(n = 0; s[n]; n++)
 208:	4501                	li	a0,0
 20a:	bfe5                	j	202 <strlen+0x20>

000000000000020c <memset>:

void*
memset(void *dst, int c, uint n)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 212:	ca19                	beqz	a2,228 <memset+0x1c>
 214:	87aa                	mv	a5,a0
 216:	1602                	slli	a2,a2,0x20
 218:	9201                	srli	a2,a2,0x20
 21a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 222:	0785                	addi	a5,a5,1
 224:	fee79de3          	bne	a5,a4,21e <memset+0x12>
  }
  return dst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret

000000000000022e <strchr>:

char*
strchr(const char *s, char c)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  for(; *s; s++)
 234:	00054783          	lbu	a5,0(a0)
 238:	cb99                	beqz	a5,24e <strchr+0x20>
    if(*s == c)
 23a:	00f58763          	beq	a1,a5,248 <strchr+0x1a>
  for(; *s; s++)
 23e:	0505                	addi	a0,a0,1
 240:	00054783          	lbu	a5,0(a0)
 244:	fbfd                	bnez	a5,23a <strchr+0xc>
      return (char*)s;
  return 0;
 246:	4501                	li	a0,0
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  return 0;
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strchr+0x1a>

0000000000000252 <gets>:

char*
gets(char *buf, int max)
{
 252:	711d                	addi	sp,sp,-96
 254:	ec86                	sd	ra,88(sp)
 256:	e8a2                	sd	s0,80(sp)
 258:	e4a6                	sd	s1,72(sp)
 25a:	e0ca                	sd	s2,64(sp)
 25c:	fc4e                	sd	s3,56(sp)
 25e:	f852                	sd	s4,48(sp)
 260:	f456                	sd	s5,40(sp)
 262:	f05a                	sd	s6,32(sp)
 264:	ec5e                	sd	s7,24(sp)
 266:	1080                	addi	s0,sp,96
 268:	8baa                	mv	s7,a0
 26a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26c:	892a                	mv	s2,a0
 26e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 270:	4aa9                	li	s5,10
 272:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	2485                	addiw	s1,s1,1
 278:	0344d663          	bge	s1,s4,2a4 <gets+0x52>
    cc = read(0, &c, 1);
 27c:	4605                	li	a2,1
 27e:	faf40593          	addi	a1,s0,-81
 282:	4501                	li	a0,0
 284:	1b4000ef          	jal	ra,438 <read>
    if(cc < 1)
 288:	00a05e63          	blez	a0,2a4 <gets+0x52>
    buf[i++] = c;
 28c:	faf44783          	lbu	a5,-81(s0)
 290:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 294:	01578763          	beq	a5,s5,2a2 <gets+0x50>
 298:	0905                	addi	s2,s2,1
 29a:	fd679de3          	bne	a5,s6,274 <gets+0x22>
  for(i=0; i+1 < max; ){
 29e:	89a6                	mv	s3,s1
 2a0:	a011                	j	2a4 <gets+0x52>
 2a2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a4:	99de                	add	s3,s3,s7
 2a6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2aa:	855e                	mv	a0,s7
 2ac:	60e6                	ld	ra,88(sp)
 2ae:	6446                	ld	s0,80(sp)
 2b0:	64a6                	ld	s1,72(sp)
 2b2:	6906                	ld	s2,64(sp)
 2b4:	79e2                	ld	s3,56(sp)
 2b6:	7a42                	ld	s4,48(sp)
 2b8:	7aa2                	ld	s5,40(sp)
 2ba:	7b02                	ld	s6,32(sp)
 2bc:	6be2                	ld	s7,24(sp)
 2be:	6125                	addi	sp,sp,96
 2c0:	8082                	ret

00000000000002c2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c2:	1101                	addi	sp,sp,-32
 2c4:	ec06                	sd	ra,24(sp)
 2c6:	e822                	sd	s0,16(sp)
 2c8:	e426                	sd	s1,8(sp)
 2ca:	e04a                	sd	s2,0(sp)
 2cc:	1000                	addi	s0,sp,32
 2ce:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d0:	4581                	li	a1,0
 2d2:	18e000ef          	jal	ra,460 <open>
  if(fd < 0)
 2d6:	02054163          	bltz	a0,2f8 <stat+0x36>
 2da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2dc:	85ca                	mv	a1,s2
 2de:	19a000ef          	jal	ra,478 <fstat>
 2e2:	892a                	mv	s2,a0
  close(fd);
 2e4:	8526                	mv	a0,s1
 2e6:	162000ef          	jal	ra,448 <close>
  return r;
}
 2ea:	854a                	mv	a0,s2
 2ec:	60e2                	ld	ra,24(sp)
 2ee:	6442                	ld	s0,16(sp)
 2f0:	64a2                	ld	s1,8(sp)
 2f2:	6902                	ld	s2,0(sp)
 2f4:	6105                	addi	sp,sp,32
 2f6:	8082                	ret
    return -1;
 2f8:	597d                	li	s2,-1
 2fa:	bfc5                	j	2ea <stat+0x28>

00000000000002fc <atoi>:

int
atoi(const char *s)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e422                	sd	s0,8(sp)
 300:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 302:	00054603          	lbu	a2,0(a0)
 306:	fd06079b          	addiw	a5,a2,-48
 30a:	0ff7f793          	andi	a5,a5,255
 30e:	4725                	li	a4,9
 310:	02f76963          	bltu	a4,a5,342 <atoi+0x46>
 314:	86aa                	mv	a3,a0
  n = 0;
 316:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 318:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 31a:	0685                	addi	a3,a3,1
 31c:	0025179b          	slliw	a5,a0,0x2
 320:	9fa9                	addw	a5,a5,a0
 322:	0017979b          	slliw	a5,a5,0x1
 326:	9fb1                	addw	a5,a5,a2
 328:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 32c:	0006c603          	lbu	a2,0(a3)
 330:	fd06071b          	addiw	a4,a2,-48
 334:	0ff77713          	andi	a4,a4,255
 338:	fee5f1e3          	bgeu	a1,a4,31a <atoi+0x1e>
  return n;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  n = 0;
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <atoi+0x40>

0000000000000346 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 34c:	02b57463          	bgeu	a0,a1,374 <memmove+0x2e>
    while(n-- > 0)
 350:	00c05f63          	blez	a2,36e <memmove+0x28>
 354:	1602                	slli	a2,a2,0x20
 356:	9201                	srli	a2,a2,0x20
 358:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 35c:	872a                	mv	a4,a0
      *dst++ = *src++;
 35e:	0585                	addi	a1,a1,1
 360:	0705                	addi	a4,a4,1
 362:	fff5c683          	lbu	a3,-1(a1)
 366:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 36a:	fee79ae3          	bne	a5,a4,35e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36e:	6422                	ld	s0,8(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret
    dst += n;
 374:	00c50733          	add	a4,a0,a2
    src += n;
 378:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 37a:	fec05ae3          	blez	a2,36e <memmove+0x28>
 37e:	fff6079b          	addiw	a5,a2,-1
 382:	1782                	slli	a5,a5,0x20
 384:	9381                	srli	a5,a5,0x20
 386:	fff7c793          	not	a5,a5
 38a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 38c:	15fd                	addi	a1,a1,-1
 38e:	177d                	addi	a4,a4,-1
 390:	0005c683          	lbu	a3,0(a1)
 394:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 398:	fee79ae3          	bne	a5,a4,38c <memmove+0x46>
 39c:	bfc9                	j	36e <memmove+0x28>

000000000000039e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a4:	ca05                	beqz	a2,3d4 <memcmp+0x36>
 3a6:	fff6069b          	addiw	a3,a2,-1
 3aa:	1682                	slli	a3,a3,0x20
 3ac:	9281                	srli	a3,a3,0x20
 3ae:	0685                	addi	a3,a3,1
 3b0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b2:	00054783          	lbu	a5,0(a0)
 3b6:	0005c703          	lbu	a4,0(a1)
 3ba:	00e79863          	bne	a5,a4,3ca <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3be:	0505                	addi	a0,a0,1
    p2++;
 3c0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3c2:	fed518e3          	bne	a0,a3,3b2 <memcmp+0x14>
  }
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	a019                	j	3ce <memcmp+0x30>
      return *p1 - *p2;
 3ca:	40e7853b          	subw	a0,a5,a4
}
 3ce:	6422                	ld	s0,8(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret
  return 0;
 3d4:	4501                	li	a0,0
 3d6:	bfe5                	j	3ce <memcmp+0x30>

00000000000003d8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e406                	sd	ra,8(sp)
 3dc:	e022                	sd	s0,0(sp)
 3de:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3e0:	f67ff0ef          	jal	ra,346 <memmove>
}
 3e4:	60a2                	ld	ra,8(sp)
 3e6:	6402                	ld	s0,0(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret

00000000000003ec <sbrk>:

char *
sbrk(int n) {
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e406                	sd	ra,8(sp)
 3f0:	e022                	sd	s0,0(sp)
 3f2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3f4:	4585                	li	a1,1
 3f6:	0b2000ef          	jal	ra,4a8 <sys_sbrk>
}
 3fa:	60a2                	ld	ra,8(sp)
 3fc:	6402                	ld	s0,0(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret

0000000000000402 <sbrklazy>:

char *
sbrklazy(int n) {
 402:	1141                	addi	sp,sp,-16
 404:	e406                	sd	ra,8(sp)
 406:	e022                	sd	s0,0(sp)
 408:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 40a:	4589                	li	a1,2
 40c:	09c000ef          	jal	ra,4a8 <sys_sbrk>
}
 410:	60a2                	ld	ra,8(sp)
 412:	6402                	ld	s0,0(sp)
 414:	0141                	addi	sp,sp,16
 416:	8082                	ret

0000000000000418 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 418:	4885                	li	a7,1
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <exit>:
.global exit
exit:
 li a7, SYS_exit
 420:	4889                	li	a7,2
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <wait>:
.global wait
wait:
 li a7, SYS_wait
 428:	488d                	li	a7,3
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 430:	4891                	li	a7,4
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <read>:
.global read
read:
 li a7, SYS_read
 438:	4895                	li	a7,5
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <write>:
.global write
write:
 li a7, SYS_write
 440:	48c1                	li	a7,16
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <close>:
.global close
close:
 li a7, SYS_close
 448:	48d5                	li	a7,21
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <kill>:
.global kill
kill:
 li a7, SYS_kill
 450:	4899                	li	a7,6
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <exec>:
.global exec
exec:
 li a7, SYS_exec
 458:	489d                	li	a7,7
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <open>:
.global open
open:
 li a7, SYS_open
 460:	48bd                	li	a7,15
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 468:	48c5                	li	a7,17
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 470:	48c9                	li	a7,18
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 478:	48a1                	li	a7,8
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <link>:
.global link
link:
 li a7, SYS_link
 480:	48cd                	li	a7,19
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 488:	48d1                	li	a7,20
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 490:	48a5                	li	a7,9
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <dup>:
.global dup
dup:
 li a7, SYS_dup
 498:	48a9                	li	a7,10
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4a0:	48ad                	li	a7,11
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4a8:	48b1                	li	a7,12
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4b0:	48b5                	li	a7,13
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b8:	48b9                	li	a7,14
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4c0:	48d9                	li	a7,22
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4c8:	48dd                	li	a7,23
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d0:	1101                	addi	sp,sp,-32
 4d2:	ec06                	sd	ra,24(sp)
 4d4:	e822                	sd	s0,16(sp)
 4d6:	1000                	addi	s0,sp,32
 4d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4dc:	4605                	li	a2,1
 4de:	fef40593          	addi	a1,s0,-17
 4e2:	f5fff0ef          	jal	ra,440 <write>
}
 4e6:	60e2                	ld	ra,24(sp)
 4e8:	6442                	ld	s0,16(sp)
 4ea:	6105                	addi	sp,sp,32
 4ec:	8082                	ret

00000000000004ee <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ee:	715d                	addi	sp,sp,-80
 4f0:	e486                	sd	ra,72(sp)
 4f2:	e0a2                	sd	s0,64(sp)
 4f4:	fc26                	sd	s1,56(sp)
 4f6:	f84a                	sd	s2,48(sp)
 4f8:	f44e                	sd	s3,40(sp)
 4fa:	0880                	addi	s0,sp,80
 4fc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4fe:	c299                	beqz	a3,504 <printint+0x16>
 500:	0805c163          	bltz	a1,582 <printint+0x94>
  neg = 0;
 504:	4881                	li	a7,0
 506:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 50a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 50c:	00000517          	auipc	a0,0x0
 510:	7c450513          	addi	a0,a0,1988 # cd0 <digits>
 514:	883e                	mv	a6,a5
 516:	2785                	addiw	a5,a5,1
 518:	02c5f733          	remu	a4,a1,a2
 51c:	972a                	add	a4,a4,a0
 51e:	00074703          	lbu	a4,0(a4)
 522:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 526:	872e                	mv	a4,a1
 528:	02c5d5b3          	divu	a1,a1,a2
 52c:	0685                	addi	a3,a3,1
 52e:	fec773e3          	bgeu	a4,a2,514 <printint+0x26>
  if(neg)
 532:	00088b63          	beqz	a7,548 <printint+0x5a>
    buf[i++] = '-';
 536:	fd040713          	addi	a4,s0,-48
 53a:	97ba                	add	a5,a5,a4
 53c:	02d00713          	li	a4,45
 540:	fee78423          	sb	a4,-24(a5)
 544:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 548:	02f05663          	blez	a5,574 <printint+0x86>
 54c:	fb840713          	addi	a4,s0,-72
 550:	00f704b3          	add	s1,a4,a5
 554:	fff70993          	addi	s3,a4,-1
 558:	99be                	add	s3,s3,a5
 55a:	37fd                	addiw	a5,a5,-1
 55c:	1782                	slli	a5,a5,0x20
 55e:	9381                	srli	a5,a5,0x20
 560:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 564:	fff4c583          	lbu	a1,-1(s1)
 568:	854a                	mv	a0,s2
 56a:	f67ff0ef          	jal	ra,4d0 <putc>
  while(--i >= 0)
 56e:	14fd                	addi	s1,s1,-1
 570:	ff349ae3          	bne	s1,s3,564 <printint+0x76>
}
 574:	60a6                	ld	ra,72(sp)
 576:	6406                	ld	s0,64(sp)
 578:	74e2                	ld	s1,56(sp)
 57a:	7942                	ld	s2,48(sp)
 57c:	79a2                	ld	s3,40(sp)
 57e:	6161                	addi	sp,sp,80
 580:	8082                	ret
    x = -xx;
 582:	40b005b3          	neg	a1,a1
    neg = 1;
 586:	4885                	li	a7,1
    x = -xx;
 588:	bfbd                	j	506 <printint+0x18>

000000000000058a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 58a:	7119                	addi	sp,sp,-128
 58c:	fc86                	sd	ra,120(sp)
 58e:	f8a2                	sd	s0,112(sp)
 590:	f4a6                	sd	s1,104(sp)
 592:	f0ca                	sd	s2,96(sp)
 594:	ecce                	sd	s3,88(sp)
 596:	e8d2                	sd	s4,80(sp)
 598:	e4d6                	sd	s5,72(sp)
 59a:	e0da                	sd	s6,64(sp)
 59c:	fc5e                	sd	s7,56(sp)
 59e:	f862                	sd	s8,48(sp)
 5a0:	f466                	sd	s9,40(sp)
 5a2:	f06a                	sd	s10,32(sp)
 5a4:	ec6e                	sd	s11,24(sp)
 5a6:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a8:	0005c903          	lbu	s2,0(a1)
 5ac:	24090c63          	beqz	s2,804 <vprintf+0x27a>
 5b0:	8b2a                	mv	s6,a0
 5b2:	8a2e                	mv	s4,a1
 5b4:	8bb2                	mv	s7,a2
  state = 0;
 5b6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5b8:	4481                	li	s1,0
 5ba:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5bc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5c0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5c4:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5c8:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5cc:	00000c97          	auipc	s9,0x0
 5d0:	704c8c93          	addi	s9,s9,1796 # cd0 <digits>
 5d4:	a005                	j	5f4 <vprintf+0x6a>
        putc(fd, c0);
 5d6:	85ca                	mv	a1,s2
 5d8:	855a                	mv	a0,s6
 5da:	ef7ff0ef          	jal	ra,4d0 <putc>
 5de:	a019                	j	5e4 <vprintf+0x5a>
    } else if(state == '%'){
 5e0:	03598263          	beq	s3,s5,604 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5e4:	2485                	addiw	s1,s1,1
 5e6:	8726                	mv	a4,s1
 5e8:	009a07b3          	add	a5,s4,s1
 5ec:	0007c903          	lbu	s2,0(a5)
 5f0:	20090a63          	beqz	s2,804 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5f4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f8:	fe0994e3          	bnez	s3,5e0 <vprintf+0x56>
      if(c0 == '%'){
 5fc:	fd579de3          	bne	a5,s5,5d6 <vprintf+0x4c>
        state = '%';
 600:	89be                	mv	s3,a5
 602:	b7cd                	j	5e4 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 604:	c3c1                	beqz	a5,684 <vprintf+0xfa>
 606:	00ea06b3          	add	a3,s4,a4
 60a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 60e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 610:	c681                	beqz	a3,618 <vprintf+0x8e>
 612:	9752                	add	a4,a4,s4
 614:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 618:	03878e63          	beq	a5,s8,654 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 61c:	05a78863          	beq	a5,s10,66c <vprintf+0xe2>
      } else if(c0 == 'u'){
 620:	0db78b63          	beq	a5,s11,6f6 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 624:	07800713          	li	a4,120
 628:	10e78d63          	beq	a5,a4,742 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 62c:	07000713          	li	a4,112
 630:	14e78263          	beq	a5,a4,774 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 634:	06300713          	li	a4,99
 638:	16e78f63          	beq	a5,a4,7b6 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 63c:	07300713          	li	a4,115
 640:	18e78563          	beq	a5,a4,7ca <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 644:	05579063          	bne	a5,s5,684 <vprintf+0xfa>
        putc(fd, '%');
 648:	85d6                	mv	a1,s5
 64a:	855a                	mv	a0,s6
 64c:	e85ff0ef          	jal	ra,4d0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 650:	4981                	li	s3,0
 652:	bf49                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 654:	008b8913          	addi	s2,s7,8
 658:	4685                	li	a3,1
 65a:	4629                	li	a2,10
 65c:	000ba583          	lw	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	e8dff0ef          	jal	ra,4ee <printint>
 666:	8bca                	mv	s7,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	bfad                	j	5e4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 66c:	03868663          	beq	a3,s8,698 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 670:	05a68163          	beq	a3,s10,6b2 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 674:	09b68d63          	beq	a3,s11,70e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 678:	03a68f63          	beq	a3,s10,6b6 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 67c:	07800793          	li	a5,120
 680:	0cf68d63          	beq	a3,a5,75a <vprintf+0x1d0>
        putc(fd, '%');
 684:	85d6                	mv	a1,s5
 686:	855a                	mv	a0,s6
 688:	e49ff0ef          	jal	ra,4d0 <putc>
        putc(fd, c0);
 68c:	85ca                	mv	a1,s2
 68e:	855a                	mv	a0,s6
 690:	e41ff0ef          	jal	ra,4d0 <putc>
      state = 0;
 694:	4981                	li	s3,0
 696:	b7b9                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	008b8913          	addi	s2,s7,8
 69c:	4685                	li	a3,1
 69e:	4629                	li	a2,10
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	e49ff0ef          	jal	ra,4ee <printint>
        i += 1;
 6aa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
        i += 1;
 6b0:	bf15                	j	5e4 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b2:	03860563          	beq	a2,s8,6dc <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6b6:	07b60963          	beq	a2,s11,728 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6ba:	07800793          	li	a5,120
 6be:	fcf613e3          	bne	a2,a5,684 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000bb583          	ld	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	e1fff0ef          	jal	ra,4ee <printint>
        i += 2;
 6d4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
        i += 2;
 6da:	b729                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	4685                	li	a3,1
 6e2:	4629                	li	a2,10
 6e4:	000bb583          	ld	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	e05ff0ef          	jal	ra,4ee <printint>
        i += 2;
 6ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
        i += 2;
 6f4:	bdc5                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6f6:	008b8913          	addi	s2,s7,8
 6fa:	4681                	li	a3,0
 6fc:	4629                	li	a2,10
 6fe:	000be583          	lwu	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	debff0ef          	jal	ra,4ee <printint>
 708:	8bca                	mv	s7,s2
      state = 0;
 70a:	4981                	li	s3,0
 70c:	bde1                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70e:	008b8913          	addi	s2,s7,8
 712:	4681                	li	a3,0
 714:	4629                	li	a2,10
 716:	000bb583          	ld	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	dd3ff0ef          	jal	ra,4ee <printint>
        i += 1;
 720:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 722:	8bca                	mv	s7,s2
      state = 0;
 724:	4981                	li	s3,0
        i += 1;
 726:	bd7d                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 728:	008b8913          	addi	s2,s7,8
 72c:	4681                	li	a3,0
 72e:	4629                	li	a2,10
 730:	000bb583          	ld	a1,0(s7)
 734:	855a                	mv	a0,s6
 736:	db9ff0ef          	jal	ra,4ee <printint>
        i += 2;
 73a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
        i += 2;
 740:	b555                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 742:	008b8913          	addi	s2,s7,8
 746:	4681                	li	a3,0
 748:	4641                	li	a2,16
 74a:	000be583          	lwu	a1,0(s7)
 74e:	855a                	mv	a0,s6
 750:	d9fff0ef          	jal	ra,4ee <printint>
 754:	8bca                	mv	s7,s2
      state = 0;
 756:	4981                	li	s3,0
 758:	b571                	j	5e4 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 75a:	008b8913          	addi	s2,s7,8
 75e:	4681                	li	a3,0
 760:	4641                	li	a2,16
 762:	000bb583          	ld	a1,0(s7)
 766:	855a                	mv	a0,s6
 768:	d87ff0ef          	jal	ra,4ee <printint>
        i += 1;
 76c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 76e:	8bca                	mv	s7,s2
      state = 0;
 770:	4981                	li	s3,0
        i += 1;
 772:	bd8d                	j	5e4 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 774:	008b8793          	addi	a5,s7,8
 778:	f8f43423          	sd	a5,-120(s0)
 77c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 780:	03000593          	li	a1,48
 784:	855a                	mv	a0,s6
 786:	d4bff0ef          	jal	ra,4d0 <putc>
  putc(fd, 'x');
 78a:	07800593          	li	a1,120
 78e:	855a                	mv	a0,s6
 790:	d41ff0ef          	jal	ra,4d0 <putc>
 794:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 796:	03c9d793          	srli	a5,s3,0x3c
 79a:	97e6                	add	a5,a5,s9
 79c:	0007c583          	lbu	a1,0(a5)
 7a0:	855a                	mv	a0,s6
 7a2:	d2fff0ef          	jal	ra,4d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a6:	0992                	slli	s3,s3,0x4
 7a8:	397d                	addiw	s2,s2,-1
 7aa:	fe0916e3          	bnez	s2,796 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7ae:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	bd05                	j	5e4 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7b6:	008b8913          	addi	s2,s7,8
 7ba:	000bc583          	lbu	a1,0(s7)
 7be:	855a                	mv	a0,s6
 7c0:	d11ff0ef          	jal	ra,4d0 <putc>
 7c4:	8bca                	mv	s7,s2
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	bd31                	j	5e4 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7ca:	008b8993          	addi	s3,s7,8
 7ce:	000bb903          	ld	s2,0(s7)
 7d2:	00090f63          	beqz	s2,7f0 <vprintf+0x266>
        for(; *s; s++)
 7d6:	00094583          	lbu	a1,0(s2)
 7da:	c195                	beqz	a1,7fe <vprintf+0x274>
          putc(fd, *s);
 7dc:	855a                	mv	a0,s6
 7de:	cf3ff0ef          	jal	ra,4d0 <putc>
        for(; *s; s++)
 7e2:	0905                	addi	s2,s2,1
 7e4:	00094583          	lbu	a1,0(s2)
 7e8:	f9f5                	bnez	a1,7dc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7ea:	8bce                	mv	s7,s3
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	bbdd                	j	5e4 <vprintf+0x5a>
          s = "(null)";
 7f0:	00000917          	auipc	s2,0x0
 7f4:	4d890913          	addi	s2,s2,1240 # cc8 <malloc+0x3c2>
        for(; *s; s++)
 7f8:	02800593          	li	a1,40
 7fc:	b7c5                	j	7dc <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7fe:	8bce                	mv	s7,s3
      state = 0;
 800:	4981                	li	s3,0
 802:	b3cd                	j	5e4 <vprintf+0x5a>
    }
  }
}
 804:	70e6                	ld	ra,120(sp)
 806:	7446                	ld	s0,112(sp)
 808:	74a6                	ld	s1,104(sp)
 80a:	7906                	ld	s2,96(sp)
 80c:	69e6                	ld	s3,88(sp)
 80e:	6a46                	ld	s4,80(sp)
 810:	6aa6                	ld	s5,72(sp)
 812:	6b06                	ld	s6,64(sp)
 814:	7be2                	ld	s7,56(sp)
 816:	7c42                	ld	s8,48(sp)
 818:	7ca2                	ld	s9,40(sp)
 81a:	7d02                	ld	s10,32(sp)
 81c:	6de2                	ld	s11,24(sp)
 81e:	6109                	addi	sp,sp,128
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
 840:	d4bff0ef          	jal	ra,58a <vprintf>
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
 872:	d19ff0ef          	jal	ra,58a <vprintf>
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
 888:	00000797          	auipc	a5,0x0
 88c:	7787b783          	ld	a5,1912(a5) # 1000 <freep>
 890:	a805                	j	8c0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 892:	4618                	lw	a4,8(a2)
 894:	9db9                	addw	a1,a1,a4
 896:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 89a:	6398                	ld	a4,0(a5)
 89c:	6318                	ld	a4,0(a4)
 89e:	fee53823          	sd	a4,-16(a0)
 8a2:	a091                	j	8e6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a4:	ff852703          	lw	a4,-8(a0)
 8a8:	9e39                	addw	a2,a2,a4
 8aa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8ac:	ff053703          	ld	a4,-16(a0)
 8b0:	e398                	sd	a4,0(a5)
 8b2:	a099                	j	8f8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b4:	6398                	ld	a4,0(a5)
 8b6:	00e7e463          	bltu	a5,a4,8be <free+0x40>
 8ba:	00e6ea63          	bltu	a3,a4,8ce <free+0x50>
{
 8be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c0:	fed7fae3          	bgeu	a5,a3,8b4 <free+0x36>
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e6e463          	bltu	a3,a4,8ce <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ca:	fee7eae3          	bltu	a5,a4,8be <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ce:	ff852583          	lw	a1,-8(a0)
 8d2:	6390                	ld	a2,0(a5)
 8d4:	02059713          	slli	a4,a1,0x20
 8d8:	9301                	srli	a4,a4,0x20
 8da:	0712                	slli	a4,a4,0x4
 8dc:	9736                	add	a4,a4,a3
 8de:	fae60ae3          	beq	a2,a4,892 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e6:	4790                	lw	a2,8(a5)
 8e8:	02061713          	slli	a4,a2,0x20
 8ec:	9301                	srli	a4,a4,0x20
 8ee:	0712                	slli	a4,a4,0x4
 8f0:	973e                	add	a4,a4,a5
 8f2:	fae689e3          	beq	a3,a4,8a4 <free+0x26>
  } else
    p->s.ptr = bp;
 8f6:	e394                	sd	a3,0(a5)
  freep = p;
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70f73423          	sd	a5,1800(a4) # 1000 <freep>
}
 900:	6422                	ld	s0,8(sp)
 902:	0141                	addi	sp,sp,16
 904:	8082                	ret

0000000000000906 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 906:	7139                	addi	sp,sp,-64
 908:	fc06                	sd	ra,56(sp)
 90a:	f822                	sd	s0,48(sp)
 90c:	f426                	sd	s1,40(sp)
 90e:	f04a                	sd	s2,32(sp)
 910:	ec4e                	sd	s3,24(sp)
 912:	e852                	sd	s4,16(sp)
 914:	e456                	sd	s5,8(sp)
 916:	e05a                	sd	s6,0(sp)
 918:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91a:	02051493          	slli	s1,a0,0x20
 91e:	9081                	srli	s1,s1,0x20
 920:	04bd                	addi	s1,s1,15
 922:	8091                	srli	s1,s1,0x4
 924:	0014899b          	addiw	s3,s1,1
 928:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 92a:	00000517          	auipc	a0,0x0
 92e:	6d653503          	ld	a0,1750(a0) # 1000 <freep>
 932:	c515                	beqz	a0,95e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 936:	4798                	lw	a4,8(a5)
 938:	02977f63          	bgeu	a4,s1,976 <malloc+0x70>
 93c:	8a4e                	mv	s4,s3
 93e:	0009871b          	sext.w	a4,s3
 942:	6685                	lui	a3,0x1
 944:	00d77363          	bgeu	a4,a3,94a <malloc+0x44>
 948:	6a05                	lui	s4,0x1
 94a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 94e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 952:	00000917          	auipc	s2,0x0
 956:	6ae90913          	addi	s2,s2,1710 # 1000 <freep>
  if(p == SBRK_ERROR)
 95a:	5afd                	li	s5,-1
 95c:	a0bd                	j	9ca <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 95e:	00000797          	auipc	a5,0x0
 962:	6b278793          	addi	a5,a5,1714 # 1010 <base>
 966:	00000717          	auipc	a4,0x0
 96a:	68f73d23          	sd	a5,1690(a4) # 1000 <freep>
 96e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 970:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 974:	b7e1                	j	93c <malloc+0x36>
      if(p->s.size == nunits)
 976:	02e48b63          	beq	s1,a4,9ac <malloc+0xa6>
        p->s.size -= nunits;
 97a:	4137073b          	subw	a4,a4,s3
 97e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 980:	1702                	slli	a4,a4,0x20
 982:	9301                	srli	a4,a4,0x20
 984:	0712                	slli	a4,a4,0x4
 986:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 988:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98c:	00000717          	auipc	a4,0x0
 990:	66a73a23          	sd	a0,1652(a4) # 1000 <freep>
      return (void*)(p + 1);
 994:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 998:	70e2                	ld	ra,56(sp)
 99a:	7442                	ld	s0,48(sp)
 99c:	74a2                	ld	s1,40(sp)
 99e:	7902                	ld	s2,32(sp)
 9a0:	69e2                	ld	s3,24(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
 9a8:	6121                	addi	sp,sp,64
 9aa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9ac:	6398                	ld	a4,0(a5)
 9ae:	e118                	sd	a4,0(a0)
 9b0:	bff1                	j	98c <malloc+0x86>
  hp->s.size = nu;
 9b2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9b6:	0541                	addi	a0,a0,16
 9b8:	ec7ff0ef          	jal	ra,87e <free>
  return freep;
 9bc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9c0:	dd61                	beqz	a0,998 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c4:	4798                	lw	a4,8(a5)
 9c6:	fa9778e3          	bgeu	a4,s1,976 <malloc+0x70>
    if(p == freep)
 9ca:	00093703          	ld	a4,0(s2)
 9ce:	853e                	mv	a0,a5
 9d0:	fef719e3          	bne	a4,a5,9c2 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 9d4:	8552                	mv	a0,s4
 9d6:	a17ff0ef          	jal	ra,3ec <sbrk>
  if(p == SBRK_ERROR)
 9da:	fd551ce3          	bne	a0,s5,9b2 <malloc+0xac>
        return 0;
 9de:	4501                	li	a0,0
 9e0:	bf65                	j	998 <malloc+0x92>
