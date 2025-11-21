
user/_cpubound:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// CPU-bound test: Long-running intensive computation
// Should demote from Q0 -> Q1 -> Q2 -> Q3 over time
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
  18:	0100                	addi	s0,sp,128
  struct procinfo info;
  volatile int dummy = 0;
  1a:	f8042623          	sw	zero,-116(s0)
  
  printf("=== Comprehensive CPU-Bound Test ===\n");
  1e:	00001517          	auipc	a0,0x1
  22:	9f250513          	addi	a0,a0,-1550 # a10 <malloc+0xe6>
  26:	04b000ef          	jal	ra,870 <printf>
  printf("This process will run CPU-intensive work for ~30 seconds.\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	a0e50513          	addi	a0,a0,-1522 # a38 <malloc+0x10e>
  32:	03f000ef          	jal	ra,870 <printf>
  printf("Watch priority change from Q0 -> Q1 -> Q2 -> Q3\n\n");
  36:	00001517          	auipc	a0,0x1
  3a:	a4250513          	addi	a0,a0,-1470 # a78 <malloc+0x14e>
  3e:	033000ef          	jal	ra,870 <printf>
  
  if(getprocinfo(&info) == 0) {
  42:	f9040513          	addi	a0,s0,-112
  46:	49e000ef          	jal	ra,4e4 <getprocinfo>
  4a:	c93d                	beqz	a0,c0 <main+0xc0>
           info.pid, info.priority, info.time_slices);
  }
  
  // Massive continuous CPU work without any yields
  // Each iteration takes significant time (multiple timer ticks)
  printf("Running continuous computation (no sleeps, no syscalls)...\n");
  4c:	00001517          	auipc	a0,0x1
  50:	a9450513          	addi	a0,a0,-1388 # ae0 <malloc+0x1b6>
  54:	01d000ef          	jal	ra,870 <printf>
  printf("Expected demotions:\n");
  58:	00001517          	auipc	a0,0x1
  5c:	ac850513          	addi	a0,a0,-1336 # b20 <malloc+0x1f6>
  60:	011000ef          	jal	ra,870 <printf>
  printf("  0-2 ticks   : Q0 (initial)\n");
  64:	00001517          	auipc	a0,0x1
  68:	ad450513          	addi	a0,a0,-1324 # b38 <malloc+0x20e>
  6c:	005000ef          	jal	ra,870 <printf>
  printf("  2-6 ticks   : Q1 (after first demotion)\n");
  70:	00001517          	auipc	a0,0x1
  74:	ae850513          	addi	a0,a0,-1304 # b58 <malloc+0x22e>
  78:	7f8000ef          	jal	ra,870 <printf>
  printf("  6-14 ticks  : Q2 (after second demotion)\n");
  7c:	00001517          	auipc	a0,0x1
  80:	b0c50513          	addi	a0,a0,-1268 # b88 <malloc+0x25e>
  84:	7ec000ef          	jal	ra,870 <printf>
  printf("  14+ ticks   : Q3 (after third demotion)\n\n");
  88:	00001517          	auipc	a0,0x1
  8c:	b3050513          	addi	a0,a0,-1232 # bb8 <malloc+0x28e>
  90:	7e0000ef          	jal	ra,870 <printf>
  94:	4a05                	li	s4,1
  96:	4981                	li	s3,0
  // Should easily hit all 4 queues multiple times
  for(int iter = 0; iter < 50; iter++) {
    // Each inner loop: 10M iterations
    for(long j = 0; j < 10000000; j++) {
      dummy = dummy + j;
      dummy = dummy % 1000000;
  98:	000f4937          	lui	s2,0xf4
  9c:	2409091b          	addiw	s2,s2,576
    for(long j = 0; j < 10000000; j++) {
  a0:	009894b7          	lui	s1,0x989
  a4:	68048493          	addi	s1,s1,1664 # 989680 <base+0x988670>
    }
    
    // Every iteration, check status
    if(getprocinfo(&info) == 0) {
      printf("Checkpoint %d: Priority=Q%d, TimeSlices=%d\n", 
  a8:	00001c17          	auipc	s8,0x1
  ac:	b40c0c13          	addi	s8,s8,-1216 # be8 <malloc+0x2be>
             iter, info.priority, info.time_slices);
    }
    
    // Stop if we've seen enough data
    if(iter == 30) {
  b0:	4b79                	li	s6,30
  for(int iter = 0; iter < 50; iter++) {
  b2:	03100b93          	li	s7,49
      printf("\n(Continuing in background for full test...)\n");
  b6:	00001c97          	auipc	s9,0x1
  ba:	b62c8c93          	addi	s9,s9,-1182 # c18 <malloc+0x2ee>
  be:	a035                	j	ea <main+0xea>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
  c0:	f9c42683          	lw	a3,-100(s0)
  c4:	f9842603          	lw	a2,-104(s0)
  c8:	f9042583          	lw	a1,-112(s0)
  cc:	00001517          	auipc	a0,0x1
  d0:	9e450513          	addi	a0,a0,-1564 # ab0 <malloc+0x186>
  d4:	79c000ef          	jal	ra,870 <printf>
  d8:	bf95                	j	4c <main+0x4c>
    if(iter == 30) {
  da:	056a8763          	beq	s5,s6,128 <main+0x128>
  for(int iter = 0; iter < 50; iter++) {
  de:	000a079b          	sext.w	a5,s4
  e2:	04fbc763          	blt	s7,a5,130 <main+0x130>
  e6:	2985                	addiw	s3,s3,1
  e8:	2a05                	addiw	s4,s4,1
  ea:	00098a9b          	sext.w	s5,s3
    for(long j = 0; j < 10000000; j++) {
  ee:	4781                	li	a5,0
      dummy = dummy + j;
  f0:	f8c42703          	lw	a4,-116(s0)
  f4:	9f3d                	addw	a4,a4,a5
  f6:	f8e42623          	sw	a4,-116(s0)
      dummy = dummy % 1000000;
  fa:	f8c42703          	lw	a4,-116(s0)
  fe:	0327673b          	remw	a4,a4,s2
 102:	f8e42623          	sw	a4,-116(s0)
    for(long j = 0; j < 10000000; j++) {
 106:	0785                	addi	a5,a5,1
 108:	fe9794e3          	bne	a5,s1,f0 <main+0xf0>
    if(getprocinfo(&info) == 0) {
 10c:	f9040513          	addi	a0,s0,-112
 110:	3d4000ef          	jal	ra,4e4 <getprocinfo>
 114:	f179                	bnez	a0,da <main+0xda>
      printf("Checkpoint %d: Priority=Q%d, TimeSlices=%d\n", 
 116:	f9c42683          	lw	a3,-100(s0)
 11a:	f9842603          	lw	a2,-104(s0)
 11e:	85d6                	mv	a1,s5
 120:	8562                	mv	a0,s8
 122:	74e000ef          	jal	ra,870 <printf>
 126:	bf55                	j	da <main+0xda>
      printf("\n(Continuing in background for full test...)\n");
 128:	8566                	mv	a0,s9
 12a:	746000ef          	jal	ra,870 <printf>
  for(int iter = 0; iter < 50; iter++) {
 12e:	bf65                	j	e6 <main+0xe6>
    }
  }
  
  // Final check
  printf("\n");
 130:	00001517          	auipc	a0,0x1
 134:	97850513          	addi	a0,a0,-1672 # aa8 <malloc+0x17e>
 138:	738000ef          	jal	ra,870 <printf>
  if(getprocinfo(&info) == 0) {
 13c:	f9040513          	addi	a0,s0,-112
 140:	3a4000ef          	jal	ra,4e4 <getprocinfo>
 144:	c501                	beqz	a0,14c <main+0x14c>
    } else {
      printf("✗ FAILED: Stayed at Q0\n");
    }
  }
  
  exit(0);
 146:	4501                	li	a0,0
 148:	2fc000ef          	jal	ra,444 <exit>
    printf("Final Result: Priority=Q%d, TimeSlices=%d\n", 
 14c:	f9c42603          	lw	a2,-100(s0)
 150:	f9842583          	lw	a1,-104(s0)
 154:	00001517          	auipc	a0,0x1
 158:	af450513          	addi	a0,a0,-1292 # c48 <malloc+0x31e>
 15c:	714000ef          	jal	ra,870 <printf>
    if(info.priority == 3) {
 160:	f9842783          	lw	a5,-104(s0)
 164:	470d                	li	a4,3
 166:	00e78f63          	beq	a5,a4,184 <main+0x184>
    } else if(info.priority == 2) {
 16a:	4709                	li	a4,2
 16c:	02e78363          	beq	a5,a4,192 <main+0x192>
    } else if(info.priority == 1) {
 170:	4705                	li	a4,1
 172:	02e78763          	beq	a5,a4,1a0 <main+0x1a0>
      printf("✗ FAILED: Stayed at Q0\n");
 176:	00001517          	auipc	a0,0x1
 17a:	b8250513          	addi	a0,a0,-1150 # cf8 <malloc+0x3ce>
 17e:	6f2000ef          	jal	ra,870 <printf>
 182:	b7d1                	j	146 <main+0x146>
      printf("✓ EXCELLENT: Reached Q3 (CPU-bound category)\n");
 184:	00001517          	auipc	a0,0x1
 188:	af450513          	addi	a0,a0,-1292 # c78 <malloc+0x34e>
 18c:	6e4000ef          	jal	ra,870 <printf>
 190:	bf5d                	j	146 <main+0x146>
      printf("✓ GOOD: Reached Q2 (mid-range demotion)\n");
 192:	00001517          	auipc	a0,0x1
 196:	b1650513          	addi	a0,a0,-1258 # ca8 <malloc+0x37e>
 19a:	6d6000ef          	jal	ra,870 <printf>
 19e:	b765                	j	146 <main+0x146>
      printf("~ PARTIAL: Only reached Q1\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	b3850513          	addi	a0,a0,-1224 # cd8 <malloc+0x3ae>
 1a8:	6c8000ef          	jal	ra,870 <printf>
 1ac:	bf69                	j	146 <main+0x146>

00000000000001ae <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e406                	sd	ra,8(sp)
 1b2:	e022                	sd	s0,0(sp)
 1b4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1b6:	e4bff0ef          	jal	ra,0 <main>
  exit(r);
 1ba:	28a000ef          	jal	ra,444 <exit>

00000000000001be <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c4:	87aa                	mv	a5,a0
 1c6:	0585                	addi	a1,a1,1
 1c8:	0785                	addi	a5,a5,1
 1ca:	fff5c703          	lbu	a4,-1(a1)
 1ce:	fee78fa3          	sb	a4,-1(a5)
 1d2:	fb75                	bnez	a4,1c6 <strcpy+0x8>
    ;
  return os;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret

00000000000001da <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1e0:	00054783          	lbu	a5,0(a0)
 1e4:	cb91                	beqz	a5,1f8 <strcmp+0x1e>
 1e6:	0005c703          	lbu	a4,0(a1)
 1ea:	00f71763          	bne	a4,a5,1f8 <strcmp+0x1e>
    p++, q++;
 1ee:	0505                	addi	a0,a0,1
 1f0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	fbe5                	bnez	a5,1e6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1f8:	0005c503          	lbu	a0,0(a1)
}
 1fc:	40a7853b          	subw	a0,a5,a0
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret

0000000000000206 <strlen>:

uint
strlen(const char *s)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cf91                	beqz	a5,22c <strlen+0x26>
 212:	0505                	addi	a0,a0,1
 214:	87aa                	mv	a5,a0
 216:	4685                	li	a3,1
 218:	9e89                	subw	a3,a3,a0
 21a:	00f6853b          	addw	a0,a3,a5
 21e:	0785                	addi	a5,a5,1
 220:	fff7c703          	lbu	a4,-1(a5)
 224:	fb7d                	bnez	a4,21a <strlen+0x14>
    ;
  return n;
}
 226:	6422                	ld	s0,8(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret
  for(n = 0; s[n]; n++)
 22c:	4501                	li	a0,0
 22e:	bfe5                	j	226 <strlen+0x20>

0000000000000230 <memset>:

void*
memset(void *dst, int c, uint n)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 236:	ca19                	beqz	a2,24c <memset+0x1c>
 238:	87aa                	mv	a5,a0
 23a:	1602                	slli	a2,a2,0x20
 23c:	9201                	srli	a2,a2,0x20
 23e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 242:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 246:	0785                	addi	a5,a5,1
 248:	fee79de3          	bne	a5,a4,242 <memset+0x12>
  }
  return dst;
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <strchr>:

char*
strchr(const char *s, char c)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  for(; *s; s++)
 258:	00054783          	lbu	a5,0(a0)
 25c:	cb99                	beqz	a5,272 <strchr+0x20>
    if(*s == c)
 25e:	00f58763          	beq	a1,a5,26c <strchr+0x1a>
  for(; *s; s++)
 262:	0505                	addi	a0,a0,1
 264:	00054783          	lbu	a5,0(a0)
 268:	fbfd                	bnez	a5,25e <strchr+0xc>
      return (char*)s;
  return 0;
 26a:	4501                	li	a0,0
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  return 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <strchr+0x1a>

0000000000000276 <gets>:

char*
gets(char *buf, int max)
{
 276:	711d                	addi	sp,sp,-96
 278:	ec86                	sd	ra,88(sp)
 27a:	e8a2                	sd	s0,80(sp)
 27c:	e4a6                	sd	s1,72(sp)
 27e:	e0ca                	sd	s2,64(sp)
 280:	fc4e                	sd	s3,56(sp)
 282:	f852                	sd	s4,48(sp)
 284:	f456                	sd	s5,40(sp)
 286:	f05a                	sd	s6,32(sp)
 288:	ec5e                	sd	s7,24(sp)
 28a:	1080                	addi	s0,sp,96
 28c:	8baa                	mv	s7,a0
 28e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 290:	892a                	mv	s2,a0
 292:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 294:	4aa9                	li	s5,10
 296:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 298:	89a6                	mv	s3,s1
 29a:	2485                	addiw	s1,s1,1
 29c:	0344d663          	bge	s1,s4,2c8 <gets+0x52>
    cc = read(0, &c, 1);
 2a0:	4605                	li	a2,1
 2a2:	faf40593          	addi	a1,s0,-81
 2a6:	4501                	li	a0,0
 2a8:	1b4000ef          	jal	ra,45c <read>
    if(cc < 1)
 2ac:	00a05e63          	blez	a0,2c8 <gets+0x52>
    buf[i++] = c;
 2b0:	faf44783          	lbu	a5,-81(s0)
 2b4:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 2b8:	01578763          	beq	a5,s5,2c6 <gets+0x50>
 2bc:	0905                	addi	s2,s2,1
 2be:	fd679de3          	bne	a5,s6,298 <gets+0x22>
  for(i=0; i+1 < max; ){
 2c2:	89a6                	mv	s3,s1
 2c4:	a011                	j	2c8 <gets+0x52>
 2c6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2c8:	99de                	add	s3,s3,s7
 2ca:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ce:	855e                	mv	a0,s7
 2d0:	60e6                	ld	ra,88(sp)
 2d2:	6446                	ld	s0,80(sp)
 2d4:	64a6                	ld	s1,72(sp)
 2d6:	6906                	ld	s2,64(sp)
 2d8:	79e2                	ld	s3,56(sp)
 2da:	7a42                	ld	s4,48(sp)
 2dc:	7aa2                	ld	s5,40(sp)
 2de:	7b02                	ld	s6,32(sp)
 2e0:	6be2                	ld	s7,24(sp)
 2e2:	6125                	addi	sp,sp,96
 2e4:	8082                	ret

00000000000002e6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e6:	1101                	addi	sp,sp,-32
 2e8:	ec06                	sd	ra,24(sp)
 2ea:	e822                	sd	s0,16(sp)
 2ec:	e426                	sd	s1,8(sp)
 2ee:	e04a                	sd	s2,0(sp)
 2f0:	1000                	addi	s0,sp,32
 2f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f4:	4581                	li	a1,0
 2f6:	18e000ef          	jal	ra,484 <open>
  if(fd < 0)
 2fa:	02054163          	bltz	a0,31c <stat+0x36>
 2fe:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 300:	85ca                	mv	a1,s2
 302:	19a000ef          	jal	ra,49c <fstat>
 306:	892a                	mv	s2,a0
  close(fd);
 308:	8526                	mv	a0,s1
 30a:	162000ef          	jal	ra,46c <close>
  return r;
}
 30e:	854a                	mv	a0,s2
 310:	60e2                	ld	ra,24(sp)
 312:	6442                	ld	s0,16(sp)
 314:	64a2                	ld	s1,8(sp)
 316:	6902                	ld	s2,0(sp)
 318:	6105                	addi	sp,sp,32
 31a:	8082                	ret
    return -1;
 31c:	597d                	li	s2,-1
 31e:	bfc5                	j	30e <stat+0x28>

0000000000000320 <atoi>:

int
atoi(const char *s)
{
 320:	1141                	addi	sp,sp,-16
 322:	e422                	sd	s0,8(sp)
 324:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 326:	00054603          	lbu	a2,0(a0)
 32a:	fd06079b          	addiw	a5,a2,-48
 32e:	0ff7f793          	andi	a5,a5,255
 332:	4725                	li	a4,9
 334:	02f76963          	bltu	a4,a5,366 <atoi+0x46>
 338:	86aa                	mv	a3,a0
  n = 0;
 33a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 33c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 33e:	0685                	addi	a3,a3,1
 340:	0025179b          	slliw	a5,a0,0x2
 344:	9fa9                	addw	a5,a5,a0
 346:	0017979b          	slliw	a5,a5,0x1
 34a:	9fb1                	addw	a5,a5,a2
 34c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 350:	0006c603          	lbu	a2,0(a3)
 354:	fd06071b          	addiw	a4,a2,-48
 358:	0ff77713          	andi	a4,a4,255
 35c:	fee5f1e3          	bgeu	a1,a4,33e <atoi+0x1e>
  return n;
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
  n = 0;
 366:	4501                	li	a0,0
 368:	bfe5                	j	360 <atoi+0x40>

000000000000036a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 370:	02b57463          	bgeu	a0,a1,398 <memmove+0x2e>
    while(n-- > 0)
 374:	00c05f63          	blez	a2,392 <memmove+0x28>
 378:	1602                	slli	a2,a2,0x20
 37a:	9201                	srli	a2,a2,0x20
 37c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 380:	872a                	mv	a4,a0
      *dst++ = *src++;
 382:	0585                	addi	a1,a1,1
 384:	0705                	addi	a4,a4,1
 386:	fff5c683          	lbu	a3,-1(a1)
 38a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 38e:	fee79ae3          	bne	a5,a4,382 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
    dst += n;
 398:	00c50733          	add	a4,a0,a2
    src += n;
 39c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 39e:	fec05ae3          	blez	a2,392 <memmove+0x28>
 3a2:	fff6079b          	addiw	a5,a2,-1
 3a6:	1782                	slli	a5,a5,0x20
 3a8:	9381                	srli	a5,a5,0x20
 3aa:	fff7c793          	not	a5,a5
 3ae:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3b0:	15fd                	addi	a1,a1,-1
 3b2:	177d                	addi	a4,a4,-1
 3b4:	0005c683          	lbu	a3,0(a1)
 3b8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3bc:	fee79ae3          	bne	a5,a4,3b0 <memmove+0x46>
 3c0:	bfc9                	j	392 <memmove+0x28>

00000000000003c2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e422                	sd	s0,8(sp)
 3c6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3c8:	ca05                	beqz	a2,3f8 <memcmp+0x36>
 3ca:	fff6069b          	addiw	a3,a2,-1
 3ce:	1682                	slli	a3,a3,0x20
 3d0:	9281                	srli	a3,a3,0x20
 3d2:	0685                	addi	a3,a3,1
 3d4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3d6:	00054783          	lbu	a5,0(a0)
 3da:	0005c703          	lbu	a4,0(a1)
 3de:	00e79863          	bne	a5,a4,3ee <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3e2:	0505                	addi	a0,a0,1
    p2++;
 3e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e6:	fed518e3          	bne	a0,a3,3d6 <memcmp+0x14>
  }
  return 0;
 3ea:	4501                	li	a0,0
 3ec:	a019                	j	3f2 <memcmp+0x30>
      return *p1 - *p2;
 3ee:	40e7853b          	subw	a0,a5,a4
}
 3f2:	6422                	ld	s0,8(sp)
 3f4:	0141                	addi	sp,sp,16
 3f6:	8082                	ret
  return 0;
 3f8:	4501                	li	a0,0
 3fa:	bfe5                	j	3f2 <memcmp+0x30>

00000000000003fc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e406                	sd	ra,8(sp)
 400:	e022                	sd	s0,0(sp)
 402:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 404:	f67ff0ef          	jal	ra,36a <memmove>
}
 408:	60a2                	ld	ra,8(sp)
 40a:	6402                	ld	s0,0(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret

0000000000000410 <sbrk>:

char *
sbrk(int n) {
 410:	1141                	addi	sp,sp,-16
 412:	e406                	sd	ra,8(sp)
 414:	e022                	sd	s0,0(sp)
 416:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 418:	4585                	li	a1,1
 41a:	0b2000ef          	jal	ra,4cc <sys_sbrk>
}
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret

0000000000000426 <sbrklazy>:

char *
sbrklazy(int n) {
 426:	1141                	addi	sp,sp,-16
 428:	e406                	sd	ra,8(sp)
 42a:	e022                	sd	s0,0(sp)
 42c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 42e:	4589                	li	a1,2
 430:	09c000ef          	jal	ra,4cc <sys_sbrk>
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43c:	4885                	li	a7,1
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <exit>:
.global exit
exit:
 li a7, SYS_exit
 444:	4889                	li	a7,2
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <wait>:
.global wait
wait:
 li a7, SYS_wait
 44c:	488d                	li	a7,3
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 454:	4891                	li	a7,4
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <read>:
.global read
read:
 li a7, SYS_read
 45c:	4895                	li	a7,5
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <write>:
.global write
write:
 li a7, SYS_write
 464:	48c1                	li	a7,16
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <close>:
.global close
close:
 li a7, SYS_close
 46c:	48d5                	li	a7,21
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <kill>:
.global kill
kill:
 li a7, SYS_kill
 474:	4899                	li	a7,6
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <exec>:
.global exec
exec:
 li a7, SYS_exec
 47c:	489d                	li	a7,7
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <open>:
.global open
open:
 li a7, SYS_open
 484:	48bd                	li	a7,15
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48c:	48c5                	li	a7,17
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 494:	48c9                	li	a7,18
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49c:	48a1                	li	a7,8
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <link>:
.global link
link:
 li a7, SYS_link
 4a4:	48cd                	li	a7,19
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ac:	48d1                	li	a7,20
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b4:	48a5                	li	a7,9
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4bc:	48a9                	li	a7,10
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c4:	48ad                	li	a7,11
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4cc:	48b1                	li	a7,12
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4d4:	48b5                	li	a7,13
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4dc:	48b9                	li	a7,14
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4e4:	48d9                	li	a7,22
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4ec:	48dd                	li	a7,23
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f4:	1101                	addi	sp,sp,-32
 4f6:	ec06                	sd	ra,24(sp)
 4f8:	e822                	sd	s0,16(sp)
 4fa:	1000                	addi	s0,sp,32
 4fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 500:	4605                	li	a2,1
 502:	fef40593          	addi	a1,s0,-17
 506:	f5fff0ef          	jal	ra,464 <write>
}
 50a:	60e2                	ld	ra,24(sp)
 50c:	6442                	ld	s0,16(sp)
 50e:	6105                	addi	sp,sp,32
 510:	8082                	ret

0000000000000512 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 512:	715d                	addi	sp,sp,-80
 514:	e486                	sd	ra,72(sp)
 516:	e0a2                	sd	s0,64(sp)
 518:	fc26                	sd	s1,56(sp)
 51a:	f84a                	sd	s2,48(sp)
 51c:	f44e                	sd	s3,40(sp)
 51e:	0880                	addi	s0,sp,80
 520:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 522:	c299                	beqz	a3,528 <printint+0x16>
 524:	0805c163          	bltz	a1,5a6 <printint+0x94>
  neg = 0;
 528:	4881                	li	a7,0
 52a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 52e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 530:	00000517          	auipc	a0,0x0
 534:	7f050513          	addi	a0,a0,2032 # d20 <digits>
 538:	883e                	mv	a6,a5
 53a:	2785                	addiw	a5,a5,1
 53c:	02c5f733          	remu	a4,a1,a2
 540:	972a                	add	a4,a4,a0
 542:	00074703          	lbu	a4,0(a4)
 546:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 54a:	872e                	mv	a4,a1
 54c:	02c5d5b3          	divu	a1,a1,a2
 550:	0685                	addi	a3,a3,1
 552:	fec773e3          	bgeu	a4,a2,538 <printint+0x26>
  if(neg)
 556:	00088b63          	beqz	a7,56c <printint+0x5a>
    buf[i++] = '-';
 55a:	fd040713          	addi	a4,s0,-48
 55e:	97ba                	add	a5,a5,a4
 560:	02d00713          	li	a4,45
 564:	fee78423          	sb	a4,-24(a5)
 568:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 56c:	02f05663          	blez	a5,598 <printint+0x86>
 570:	fb840713          	addi	a4,s0,-72
 574:	00f704b3          	add	s1,a4,a5
 578:	fff70993          	addi	s3,a4,-1
 57c:	99be                	add	s3,s3,a5
 57e:	37fd                	addiw	a5,a5,-1
 580:	1782                	slli	a5,a5,0x20
 582:	9381                	srli	a5,a5,0x20
 584:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 588:	fff4c583          	lbu	a1,-1(s1)
 58c:	854a                	mv	a0,s2
 58e:	f67ff0ef          	jal	ra,4f4 <putc>
  while(--i >= 0)
 592:	14fd                	addi	s1,s1,-1
 594:	ff349ae3          	bne	s1,s3,588 <printint+0x76>
}
 598:	60a6                	ld	ra,72(sp)
 59a:	6406                	ld	s0,64(sp)
 59c:	74e2                	ld	s1,56(sp)
 59e:	7942                	ld	s2,48(sp)
 5a0:	79a2                	ld	s3,40(sp)
 5a2:	6161                	addi	sp,sp,80
 5a4:	8082                	ret
    x = -xx;
 5a6:	40b005b3          	neg	a1,a1
    neg = 1;
 5aa:	4885                	li	a7,1
    x = -xx;
 5ac:	bfbd                	j	52a <printint+0x18>

00000000000005ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ae:	7119                	addi	sp,sp,-128
 5b0:	fc86                	sd	ra,120(sp)
 5b2:	f8a2                	sd	s0,112(sp)
 5b4:	f4a6                	sd	s1,104(sp)
 5b6:	f0ca                	sd	s2,96(sp)
 5b8:	ecce                	sd	s3,88(sp)
 5ba:	e8d2                	sd	s4,80(sp)
 5bc:	e4d6                	sd	s5,72(sp)
 5be:	e0da                	sd	s6,64(sp)
 5c0:	fc5e                	sd	s7,56(sp)
 5c2:	f862                	sd	s8,48(sp)
 5c4:	f466                	sd	s9,40(sp)
 5c6:	f06a                	sd	s10,32(sp)
 5c8:	ec6e                	sd	s11,24(sp)
 5ca:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5cc:	0005c903          	lbu	s2,0(a1)
 5d0:	24090c63          	beqz	s2,828 <vprintf+0x27a>
 5d4:	8b2a                	mv	s6,a0
 5d6:	8a2e                	mv	s4,a1
 5d8:	8bb2                	mv	s7,a2
  state = 0;
 5da:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5dc:	4481                	li	s1,0
 5de:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5e0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5e4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5e8:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ec:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f0:	00000c97          	auipc	s9,0x0
 5f4:	730c8c93          	addi	s9,s9,1840 # d20 <digits>
 5f8:	a005                	j	618 <vprintf+0x6a>
        putc(fd, c0);
 5fa:	85ca                	mv	a1,s2
 5fc:	855a                	mv	a0,s6
 5fe:	ef7ff0ef          	jal	ra,4f4 <putc>
 602:	a019                	j	608 <vprintf+0x5a>
    } else if(state == '%'){
 604:	03598263          	beq	s3,s5,628 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 608:	2485                	addiw	s1,s1,1
 60a:	8726                	mv	a4,s1
 60c:	009a07b3          	add	a5,s4,s1
 610:	0007c903          	lbu	s2,0(a5)
 614:	20090a63          	beqz	s2,828 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 618:	0009079b          	sext.w	a5,s2
    if(state == 0){
 61c:	fe0994e3          	bnez	s3,604 <vprintf+0x56>
      if(c0 == '%'){
 620:	fd579de3          	bne	a5,s5,5fa <vprintf+0x4c>
        state = '%';
 624:	89be                	mv	s3,a5
 626:	b7cd                	j	608 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 628:	c3c1                	beqz	a5,6a8 <vprintf+0xfa>
 62a:	00ea06b3          	add	a3,s4,a4
 62e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 632:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 634:	c681                	beqz	a3,63c <vprintf+0x8e>
 636:	9752                	add	a4,a4,s4
 638:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 63c:	03878e63          	beq	a5,s8,678 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 640:	05a78863          	beq	a5,s10,690 <vprintf+0xe2>
      } else if(c0 == 'u'){
 644:	0db78b63          	beq	a5,s11,71a <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 648:	07800713          	li	a4,120
 64c:	10e78d63          	beq	a5,a4,766 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 650:	07000713          	li	a4,112
 654:	14e78263          	beq	a5,a4,798 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 658:	06300713          	li	a4,99
 65c:	16e78f63          	beq	a5,a4,7da <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 660:	07300713          	li	a4,115
 664:	18e78563          	beq	a5,a4,7ee <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 668:	05579063          	bne	a5,s5,6a8 <vprintf+0xfa>
        putc(fd, '%');
 66c:	85d6                	mv	a1,s5
 66e:	855a                	mv	a0,s6
 670:	e85ff0ef          	jal	ra,4f4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 674:	4981                	li	s3,0
 676:	bf49                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 678:	008b8913          	addi	s2,s7,8
 67c:	4685                	li	a3,1
 67e:	4629                	li	a2,10
 680:	000ba583          	lw	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e8dff0ef          	jal	ra,512 <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bfad                	j	608 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 690:	03868663          	beq	a3,s8,6bc <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 694:	05a68163          	beq	a3,s10,6d6 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 698:	09b68d63          	beq	a3,s11,732 <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 69c:	03a68f63          	beq	a3,s10,6da <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 6a0:	07800793          	li	a5,120
 6a4:	0cf68d63          	beq	a3,a5,77e <vprintf+0x1d0>
        putc(fd, '%');
 6a8:	85d6                	mv	a1,s5
 6aa:	855a                	mv	a0,s6
 6ac:	e49ff0ef          	jal	ra,4f4 <putc>
        putc(fd, c0);
 6b0:	85ca                	mv	a1,s2
 6b2:	855a                	mv	a0,s6
 6b4:	e41ff0ef          	jal	ra,4f4 <putc>
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b7b9                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4685                	li	a3,1
 6c2:	4629                	li	a2,10
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	e49ff0ef          	jal	ra,512 <printint>
        i += 1;
 6ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 1;
 6d4:	bf15                	j	608 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6d6:	03860563          	beq	a2,s8,700 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6da:	07b60963          	beq	a2,s11,74c <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6de:	07800793          	li	a5,120
 6e2:	fcf613e3          	bne	a2,a5,6a8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	4681                	li	a3,0
 6ec:	4641                	li	a2,16
 6ee:	000bb583          	ld	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	e1fff0ef          	jal	ra,512 <printint>
        i += 2;
 6f8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fa:	8bca                	mv	s7,s2
      state = 0;
 6fc:	4981                	li	s3,0
        i += 2;
 6fe:	b729                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 700:	008b8913          	addi	s2,s7,8
 704:	4685                	li	a3,1
 706:	4629                	li	a2,10
 708:	000bb583          	ld	a1,0(s7)
 70c:	855a                	mv	a0,s6
 70e:	e05ff0ef          	jal	ra,512 <printint>
        i += 2;
 712:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 714:	8bca                	mv	s7,s2
      state = 0;
 716:	4981                	li	s3,0
        i += 2;
 718:	bdc5                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 71a:	008b8913          	addi	s2,s7,8
 71e:	4681                	li	a3,0
 720:	4629                	li	a2,10
 722:	000be583          	lwu	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	debff0ef          	jal	ra,512 <printint>
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
 730:	bde1                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	008b8913          	addi	s2,s7,8
 736:	4681                	li	a3,0
 738:	4629                	li	a2,10
 73a:	000bb583          	ld	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	dd3ff0ef          	jal	ra,512 <printint>
        i += 1;
 744:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
        i += 1;
 74a:	bd7d                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 74c:	008b8913          	addi	s2,s7,8
 750:	4681                	li	a3,0
 752:	4629                	li	a2,10
 754:	000bb583          	ld	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	db9ff0ef          	jal	ra,512 <printint>
        i += 2;
 75e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 760:	8bca                	mv	s7,s2
      state = 0;
 762:	4981                	li	s3,0
        i += 2;
 764:	b555                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 766:	008b8913          	addi	s2,s7,8
 76a:	4681                	li	a3,0
 76c:	4641                	li	a2,16
 76e:	000be583          	lwu	a1,0(s7)
 772:	855a                	mv	a0,s6
 774:	d9fff0ef          	jal	ra,512 <printint>
 778:	8bca                	mv	s7,s2
      state = 0;
 77a:	4981                	li	s3,0
 77c:	b571                	j	608 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 77e:	008b8913          	addi	s2,s7,8
 782:	4681                	li	a3,0
 784:	4641                	li	a2,16
 786:	000bb583          	ld	a1,0(s7)
 78a:	855a                	mv	a0,s6
 78c:	d87ff0ef          	jal	ra,512 <printint>
        i += 1;
 790:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 792:	8bca                	mv	s7,s2
      state = 0;
 794:	4981                	li	s3,0
        i += 1;
 796:	bd8d                	j	608 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 798:	008b8793          	addi	a5,s7,8
 79c:	f8f43423          	sd	a5,-120(s0)
 7a0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7a4:	03000593          	li	a1,48
 7a8:	855a                	mv	a0,s6
 7aa:	d4bff0ef          	jal	ra,4f4 <putc>
  putc(fd, 'x');
 7ae:	07800593          	li	a1,120
 7b2:	855a                	mv	a0,s6
 7b4:	d41ff0ef          	jal	ra,4f4 <putc>
 7b8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ba:	03c9d793          	srli	a5,s3,0x3c
 7be:	97e6                	add	a5,a5,s9
 7c0:	0007c583          	lbu	a1,0(a5)
 7c4:	855a                	mv	a0,s6
 7c6:	d2fff0ef          	jal	ra,4f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ca:	0992                	slli	s3,s3,0x4
 7cc:	397d                	addiw	s2,s2,-1
 7ce:	fe0916e3          	bnez	s2,7ba <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 7d2:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bd05                	j	608 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 7da:	008b8913          	addi	s2,s7,8
 7de:	000bc583          	lbu	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	d11ff0ef          	jal	ra,4f4 <putc>
 7e8:	8bca                	mv	s7,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bd31                	j	608 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 7ee:	008b8993          	addi	s3,s7,8
 7f2:	000bb903          	ld	s2,0(s7)
 7f6:	00090f63          	beqz	s2,814 <vprintf+0x266>
        for(; *s; s++)
 7fa:	00094583          	lbu	a1,0(s2)
 7fe:	c195                	beqz	a1,822 <vprintf+0x274>
          putc(fd, *s);
 800:	855a                	mv	a0,s6
 802:	cf3ff0ef          	jal	ra,4f4 <putc>
        for(; *s; s++)
 806:	0905                	addi	s2,s2,1
 808:	00094583          	lbu	a1,0(s2)
 80c:	f9f5                	bnez	a1,800 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 80e:	8bce                	mv	s7,s3
      state = 0;
 810:	4981                	li	s3,0
 812:	bbdd                	j	608 <vprintf+0x5a>
          s = "(null)";
 814:	00000917          	auipc	s2,0x0
 818:	50490913          	addi	s2,s2,1284 # d18 <malloc+0x3ee>
        for(; *s; s++)
 81c:	02800593          	li	a1,40
 820:	b7c5                	j	800 <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 822:	8bce                	mv	s7,s3
      state = 0;
 824:	4981                	li	s3,0
 826:	b3cd                	j	608 <vprintf+0x5a>
    }
  }
}
 828:	70e6                	ld	ra,120(sp)
 82a:	7446                	ld	s0,112(sp)
 82c:	74a6                	ld	s1,104(sp)
 82e:	7906                	ld	s2,96(sp)
 830:	69e6                	ld	s3,88(sp)
 832:	6a46                	ld	s4,80(sp)
 834:	6aa6                	ld	s5,72(sp)
 836:	6b06                	ld	s6,64(sp)
 838:	7be2                	ld	s7,56(sp)
 83a:	7c42                	ld	s8,48(sp)
 83c:	7ca2                	ld	s9,40(sp)
 83e:	7d02                	ld	s10,32(sp)
 840:	6de2                	ld	s11,24(sp)
 842:	6109                	addi	sp,sp,128
 844:	8082                	ret

0000000000000846 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 846:	715d                	addi	sp,sp,-80
 848:	ec06                	sd	ra,24(sp)
 84a:	e822                	sd	s0,16(sp)
 84c:	1000                	addi	s0,sp,32
 84e:	e010                	sd	a2,0(s0)
 850:	e414                	sd	a3,8(s0)
 852:	e818                	sd	a4,16(s0)
 854:	ec1c                	sd	a5,24(s0)
 856:	03043023          	sd	a6,32(s0)
 85a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 85e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 862:	8622                	mv	a2,s0
 864:	d4bff0ef          	jal	ra,5ae <vprintf>
}
 868:	60e2                	ld	ra,24(sp)
 86a:	6442                	ld	s0,16(sp)
 86c:	6161                	addi	sp,sp,80
 86e:	8082                	ret

0000000000000870 <printf>:

void
printf(const char *fmt, ...)
{
 870:	711d                	addi	sp,sp,-96
 872:	ec06                	sd	ra,24(sp)
 874:	e822                	sd	s0,16(sp)
 876:	1000                	addi	s0,sp,32
 878:	e40c                	sd	a1,8(s0)
 87a:	e810                	sd	a2,16(s0)
 87c:	ec14                	sd	a3,24(s0)
 87e:	f018                	sd	a4,32(s0)
 880:	f41c                	sd	a5,40(s0)
 882:	03043823          	sd	a6,48(s0)
 886:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 88a:	00840613          	addi	a2,s0,8
 88e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 892:	85aa                	mv	a1,a0
 894:	4505                	li	a0,1
 896:	d19ff0ef          	jal	ra,5ae <vprintf>
}
 89a:	60e2                	ld	ra,24(sp)
 89c:	6442                	ld	s0,16(sp)
 89e:	6125                	addi	sp,sp,96
 8a0:	8082                	ret

00000000000008a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a2:	1141                	addi	sp,sp,-16
 8a4:	e422                	sd	s0,8(sp)
 8a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ac:	00000797          	auipc	a5,0x0
 8b0:	7547b783          	ld	a5,1876(a5) # 1000 <freep>
 8b4:	a805                	j	8e4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8b6:	4618                	lw	a4,8(a2)
 8b8:	9db9                	addw	a1,a1,a4
 8ba:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8be:	6398                	ld	a4,0(a5)
 8c0:	6318                	ld	a4,0(a4)
 8c2:	fee53823          	sd	a4,-16(a0)
 8c6:	a091                	j	90a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8c8:	ff852703          	lw	a4,-8(a0)
 8cc:	9e39                	addw	a2,a2,a4
 8ce:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8d0:	ff053703          	ld	a4,-16(a0)
 8d4:	e398                	sd	a4,0(a5)
 8d6:	a099                	j	91c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d8:	6398                	ld	a4,0(a5)
 8da:	00e7e463          	bltu	a5,a4,8e2 <free+0x40>
 8de:	00e6ea63          	bltu	a3,a4,8f2 <free+0x50>
{
 8e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e4:	fed7fae3          	bgeu	a5,a3,8d8 <free+0x36>
 8e8:	6398                	ld	a4,0(a5)
 8ea:	00e6e463          	bltu	a3,a4,8f2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ee:	fee7eae3          	bltu	a5,a4,8e2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8f2:	ff852583          	lw	a1,-8(a0)
 8f6:	6390                	ld	a2,0(a5)
 8f8:	02059713          	slli	a4,a1,0x20
 8fc:	9301                	srli	a4,a4,0x20
 8fe:	0712                	slli	a4,a4,0x4
 900:	9736                	add	a4,a4,a3
 902:	fae60ae3          	beq	a2,a4,8b6 <free+0x14>
    bp->s.ptr = p->s.ptr;
 906:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 90a:	4790                	lw	a2,8(a5)
 90c:	02061713          	slli	a4,a2,0x20
 910:	9301                	srli	a4,a4,0x20
 912:	0712                	slli	a4,a4,0x4
 914:	973e                	add	a4,a4,a5
 916:	fae689e3          	beq	a3,a4,8c8 <free+0x26>
  } else
    p->s.ptr = bp;
 91a:	e394                	sd	a3,0(a5)
  freep = p;
 91c:	00000717          	auipc	a4,0x0
 920:	6ef73223          	sd	a5,1764(a4) # 1000 <freep>
}
 924:	6422                	ld	s0,8(sp)
 926:	0141                	addi	sp,sp,16
 928:	8082                	ret

000000000000092a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 92a:	7139                	addi	sp,sp,-64
 92c:	fc06                	sd	ra,56(sp)
 92e:	f822                	sd	s0,48(sp)
 930:	f426                	sd	s1,40(sp)
 932:	f04a                	sd	s2,32(sp)
 934:	ec4e                	sd	s3,24(sp)
 936:	e852                	sd	s4,16(sp)
 938:	e456                	sd	s5,8(sp)
 93a:	e05a                	sd	s6,0(sp)
 93c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 93e:	02051493          	slli	s1,a0,0x20
 942:	9081                	srli	s1,s1,0x20
 944:	04bd                	addi	s1,s1,15
 946:	8091                	srli	s1,s1,0x4
 948:	0014899b          	addiw	s3,s1,1
 94c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 94e:	00000517          	auipc	a0,0x0
 952:	6b253503          	ld	a0,1714(a0) # 1000 <freep>
 956:	c515                	beqz	a0,982 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 958:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95a:	4798                	lw	a4,8(a5)
 95c:	02977f63          	bgeu	a4,s1,99a <malloc+0x70>
 960:	8a4e                	mv	s4,s3
 962:	0009871b          	sext.w	a4,s3
 966:	6685                	lui	a3,0x1
 968:	00d77363          	bgeu	a4,a3,96e <malloc+0x44>
 96c:	6a05                	lui	s4,0x1
 96e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 972:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 976:	00000917          	auipc	s2,0x0
 97a:	68a90913          	addi	s2,s2,1674 # 1000 <freep>
  if(p == SBRK_ERROR)
 97e:	5afd                	li	s5,-1
 980:	a0bd                	j	9ee <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 982:	00000797          	auipc	a5,0x0
 986:	68e78793          	addi	a5,a5,1678 # 1010 <base>
 98a:	00000717          	auipc	a4,0x0
 98e:	66f73b23          	sd	a5,1654(a4) # 1000 <freep>
 992:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 994:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 998:	b7e1                	j	960 <malloc+0x36>
      if(p->s.size == nunits)
 99a:	02e48b63          	beq	s1,a4,9d0 <malloc+0xa6>
        p->s.size -= nunits;
 99e:	4137073b          	subw	a4,a4,s3
 9a2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a4:	1702                	slli	a4,a4,0x20
 9a6:	9301                	srli	a4,a4,0x20
 9a8:	0712                	slli	a4,a4,0x4
 9aa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ac:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9b0:	00000717          	auipc	a4,0x0
 9b4:	64a73823          	sd	a0,1616(a4) # 1000 <freep>
      return (void*)(p + 1);
 9b8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9bc:	70e2                	ld	ra,56(sp)
 9be:	7442                	ld	s0,48(sp)
 9c0:	74a2                	ld	s1,40(sp)
 9c2:	7902                	ld	s2,32(sp)
 9c4:	69e2                	ld	s3,24(sp)
 9c6:	6a42                	ld	s4,16(sp)
 9c8:	6aa2                	ld	s5,8(sp)
 9ca:	6b02                	ld	s6,0(sp)
 9cc:	6121                	addi	sp,sp,64
 9ce:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9d0:	6398                	ld	a4,0(a5)
 9d2:	e118                	sd	a4,0(a0)
 9d4:	bff1                	j	9b0 <malloc+0x86>
  hp->s.size = nu;
 9d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9da:	0541                	addi	a0,a0,16
 9dc:	ec7ff0ef          	jal	ra,8a2 <free>
  return freep;
 9e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9e4:	dd61                	beqz	a0,9bc <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e8:	4798                	lw	a4,8(a5)
 9ea:	fa9778e3          	bgeu	a4,s1,99a <malloc+0x70>
    if(p == freep)
 9ee:	00093703          	ld	a4,0(s2)
 9f2:	853e                	mv	a0,a5
 9f4:	fef719e3          	bne	a4,a5,9e6 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 9f8:	8552                	mv	a0,s4
 9fa:	a17ff0ef          	jal	ra,410 <sbrk>
  if(p == SBRK_ERROR)
 9fe:	fd551ce3          	bne	a0,s5,9d6 <malloc+0xac>
        return 0;
 a02:	4501                	li	a0,0
 a04:	bf65                	j	9bc <malloc+0x92>
