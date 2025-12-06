
user/_cpubound:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// CPU-bound test: Long-running intensive computation
// Should demote from Q0 -> Q1 -> Q2 -> Q3 over time
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
  volatile int dummy = 0;
  18:	f8042e23          	sw	zero,-100(s0)
  
  printf("=== Comprehensive CPU-Bound Test ===\n");
  1c:	00001517          	auipc	a0,0x1
  20:	a6450513          	addi	a0,a0,-1436 # a80 <malloc+0x100>
  24:	0a5000ef          	jal	8c8 <printf>
  printf("This process will run CPU-intensive work for ~30 seconds.\n");
  28:	00001517          	auipc	a0,0x1
  2c:	a8850513          	addi	a0,a0,-1400 # ab0 <malloc+0x130>
  30:	099000ef          	jal	8c8 <printf>
  printf("Watch priority change from Q0 -> Q1 -> Q2 -> Q3\n\n");
  34:	00001517          	auipc	a0,0x1
  38:	abc50513          	addi	a0,a0,-1348 # af0 <malloc+0x170>
  3c:	08d000ef          	jal	8c8 <printf>
  
  if(getprocinfo(&info) == 0) {
  40:	fa040513          	addi	a0,s0,-96
  44:	4ce000ef          	jal	512 <getprocinfo>
  48:	cd25                	beqz	a0,c0 <main+0xc0>
           info.pid, info.priority, info.time_slices);
  }
  
  // Massive continuous CPU work without any yields
  // Each iteration takes significant time (multiple timer ticks)
  printf("Running continuous computation (no sleeps, no syscalls)...\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	b0e50513          	addi	a0,a0,-1266 # b58 <malloc+0x1d8>
  52:	077000ef          	jal	8c8 <printf>
  printf("Expected demotions:\n");
  56:	00001517          	auipc	a0,0x1
  5a:	b4250513          	addi	a0,a0,-1214 # b98 <malloc+0x218>
  5e:	06b000ef          	jal	8c8 <printf>
  printf("  0-2 ticks   : Q0 (initial)\n");
  62:	00001517          	auipc	a0,0x1
  66:	b4e50513          	addi	a0,a0,-1202 # bb0 <malloc+0x230>
  6a:	05f000ef          	jal	8c8 <printf>
  printf("  2-6 ticks   : Q1 (after first demotion)\n");
  6e:	00001517          	auipc	a0,0x1
  72:	b6250513          	addi	a0,a0,-1182 # bd0 <malloc+0x250>
  76:	053000ef          	jal	8c8 <printf>
  printf("  6-14 ticks  : Q2 (after second demotion)\n");
  7a:	00001517          	auipc	a0,0x1
  7e:	b8650513          	addi	a0,a0,-1146 # c00 <malloc+0x280>
  82:	047000ef          	jal	8c8 <printf>
  printf("  14+ ticks   : Q3 (after third demotion)\n\n");
  86:	00001517          	auipc	a0,0x1
  8a:	baa50513          	addi	a0,a0,-1110 # c30 <malloc+0x2b0>
  8e:	03b000ef          	jal	8c8 <printf>
  
  // Do MASSIVE amount of work - much more than purecpu
  // 500M iterations = ~5 seconds of continuous work
  // Should easily hit all 4 queues multiple times
  for(int iter = 0; iter < 50; iter++) {
  92:	4a01                	li	s4,0
    // Each inner loop: 10M iterations
    for(long j = 0; j < 10000000; j++) {
      dummy = dummy + j;
      dummy = dummy % 1000000;
  94:	431be9b7          	lui	s3,0x431be
  98:	e8398993          	addi	s3,s3,-381 # 431bde83 <base+0x431bce73>
  9c:	000f4937          	lui	s2,0xf4
  a0:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf3230>
    for(long j = 0; j < 10000000; j++) {
  a4:	009894b7          	lui	s1,0x989
  a8:	68048493          	addi	s1,s1,1664 # 989680 <base+0x988670>
    }
    
    // Every iteration, check status
    if(getprocinfo(&info) == 0) {
  ac:	fa040b13          	addi	s6,s0,-96
      printf("Checkpoint %d: Priority=Q%d, TimeSlices=%d\n", 
  b0:	00001c17          	auipc	s8,0x1
  b4:	bb0c0c13          	addi	s8,s8,-1104 # c60 <malloc+0x2e0>
             iter, info.priority, info.time_slices);
    }
    
    // Stop if we've seen enough data
    if(iter == 30) {
  b8:	4af9                	li	s5,30
  for(int iter = 0; iter < 50; iter++) {
  ba:	03200b93          	li	s7,50
  be:	a01d                	j	e4 <main+0xe4>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
  c0:	fac42683          	lw	a3,-84(s0)
  c4:	fa842603          	lw	a2,-88(s0)
  c8:	fa042583          	lw	a1,-96(s0)
  cc:	00001517          	auipc	a0,0x1
  d0:	a5c50513          	addi	a0,a0,-1444 # b28 <malloc+0x1a8>
  d4:	7f4000ef          	jal	8c8 <printf>
  d8:	bf8d                	j	4a <main+0x4a>
    if(iter == 30) {
  da:	055a0a63          	beq	s4,s5,12e <main+0x12e>
  for(int iter = 0; iter < 50; iter++) {
  de:	2a05                	addiw	s4,s4,1
  e0:	057a0f63          	beq	s4,s7,13e <main+0x13e>
    for(long j = 0; j < 10000000; j++) {
  e4:	4681                	li	a3,0
      dummy = dummy + j;
  e6:	f9c42783          	lw	a5,-100(s0)
  ea:	9fb5                	addw	a5,a5,a3
  ec:	f8f42e23          	sw	a5,-100(s0)
      dummy = dummy % 1000000;
  f0:	f9c42783          	lw	a5,-100(s0)
  f4:	0007871b          	sext.w	a4,a5
  f8:	033787b3          	mul	a5,a5,s3
  fc:	97c9                	srai	a5,a5,0x32
  fe:	41f7561b          	sraiw	a2,a4,0x1f
 102:	9f91                	subw	a5,a5,a2
 104:	02f907bb          	mulw	a5,s2,a5
 108:	9f1d                	subw	a4,a4,a5
 10a:	f8e42e23          	sw	a4,-100(s0)
    for(long j = 0; j < 10000000; j++) {
 10e:	0685                	addi	a3,a3,1
 110:	fc969be3          	bne	a3,s1,e6 <main+0xe6>
    if(getprocinfo(&info) == 0) {
 114:	855a                	mv	a0,s6
 116:	3fc000ef          	jal	512 <getprocinfo>
 11a:	f161                	bnez	a0,da <main+0xda>
      printf("Checkpoint %d: Priority=Q%d, TimeSlices=%d\n", 
 11c:	fac42683          	lw	a3,-84(s0)
 120:	fa842603          	lw	a2,-88(s0)
 124:	85d2                	mv	a1,s4
 126:	8562                	mv	a0,s8
 128:	7a0000ef          	jal	8c8 <printf>
 12c:	b77d                	j	da <main+0xda>
      printf("\n(Continuing in background for full test...)\n");
 12e:	00001517          	auipc	a0,0x1
 132:	b6250513          	addi	a0,a0,-1182 # c90 <malloc+0x310>
 136:	792000ef          	jal	8c8 <printf>
  for(int iter = 0; iter < 50; iter++) {
 13a:	2a05                	addiw	s4,s4,1
 13c:	b765                	j	e4 <main+0xe4>
    }
  }
  
  // Final check
  printf("\n");
 13e:	00001517          	auipc	a0,0x1
 142:	b8250513          	addi	a0,a0,-1150 # cc0 <malloc+0x340>
 146:	782000ef          	jal	8c8 <printf>
  if(getprocinfo(&info) == 0) {
 14a:	fa040513          	addi	a0,s0,-96
 14e:	3c4000ef          	jal	512 <getprocinfo>
 152:	c501                	beqz	a0,15a <main+0x15a>
    } else {
      printf("✗ FAILED: Stayed at Q0\n");
    }
  }
  
  exit(0);
 154:	4501                	li	a0,0
 156:	31c000ef          	jal	472 <exit>
    printf("Final Result: Priority=Q%d, TimeSlices=%d\n", 
 15a:	fac42603          	lw	a2,-84(s0)
 15e:	fa842583          	lw	a1,-88(s0)
 162:	00001517          	auipc	a0,0x1
 166:	b6650513          	addi	a0,a0,-1178 # cc8 <malloc+0x348>
 16a:	75e000ef          	jal	8c8 <printf>
    if(info.priority == 3) {
 16e:	fa842783          	lw	a5,-88(s0)
 172:	470d                	li	a4,3
 174:	00e78f63          	beq	a5,a4,192 <main+0x192>
    } else if(info.priority == 2) {
 178:	4709                	li	a4,2
 17a:	02e78363          	beq	a5,a4,1a0 <main+0x1a0>
    } else if(info.priority == 1) {
 17e:	4705                	li	a4,1
 180:	02e78763          	beq	a5,a4,1ae <main+0x1ae>
      printf("✗ FAILED: Stayed at Q0\n");
 184:	00001517          	auipc	a0,0x1
 188:	bf450513          	addi	a0,a0,-1036 # d78 <malloc+0x3f8>
 18c:	73c000ef          	jal	8c8 <printf>
 190:	b7d1                	j	154 <main+0x154>
      printf("✓ EXCELLENT: Reached Q3 (CPU-bound category)\n");
 192:	00001517          	auipc	a0,0x1
 196:	b6650513          	addi	a0,a0,-1178 # cf8 <malloc+0x378>
 19a:	72e000ef          	jal	8c8 <printf>
 19e:	bf5d                	j	154 <main+0x154>
      printf("✓ GOOD: Reached Q2 (mid-range demotion)\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	b8850513          	addi	a0,a0,-1144 # d28 <malloc+0x3a8>
 1a8:	720000ef          	jal	8c8 <printf>
 1ac:	b765                	j	154 <main+0x154>
      printf("~ PARTIAL: Only reached Q1\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	baa50513          	addi	a0,a0,-1110 # d58 <malloc+0x3d8>
 1b6:	712000ef          	jal	8c8 <printf>
 1ba:	bf69                	j	154 <main+0x154>

00000000000001bc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e406                	sd	ra,8(sp)
 1c0:	e022                	sd	s0,0(sp)
 1c2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1c4:	e3dff0ef          	jal	0 <main>
  exit(r);
 1c8:	2aa000ef          	jal	472 <exit>

00000000000001cc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e406                	sd	ra,8(sp)
 1d0:	e022                	sd	s0,0(sp)
 1d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1d4:	87aa                	mv	a5,a0
 1d6:	0585                	addi	a1,a1,1
 1d8:	0785                	addi	a5,a5,1
 1da:	fff5c703          	lbu	a4,-1(a1)
 1de:	fee78fa3          	sb	a4,-1(a5)
 1e2:	fb75                	bnez	a4,1d6 <strcpy+0xa>
    ;
  return os;
}
 1e4:	60a2                	ld	ra,8(sp)
 1e6:	6402                	ld	s0,0(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret

00000000000001ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e406                	sd	ra,8(sp)
 1f0:	e022                	sd	s0,0(sp)
 1f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f4:	00054783          	lbu	a5,0(a0)
 1f8:	cb91                	beqz	a5,20c <strcmp+0x20>
 1fa:	0005c703          	lbu	a4,0(a1)
 1fe:	00f71763          	bne	a4,a5,20c <strcmp+0x20>
    p++, q++;
 202:	0505                	addi	a0,a0,1
 204:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 206:	00054783          	lbu	a5,0(a0)
 20a:	fbe5                	bnez	a5,1fa <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 20c:	0005c503          	lbu	a0,0(a1)
}
 210:	40a7853b          	subw	a0,a5,a0
 214:	60a2                	ld	ra,8(sp)
 216:	6402                	ld	s0,0(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret

000000000000021c <strlen>:

uint
strlen(const char *s)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 224:	00054783          	lbu	a5,0(a0)
 228:	cf91                	beqz	a5,244 <strlen+0x28>
 22a:	00150793          	addi	a5,a0,1
 22e:	86be                	mv	a3,a5
 230:	0785                	addi	a5,a5,1
 232:	fff7c703          	lbu	a4,-1(a5)
 236:	ff65                	bnez	a4,22e <strlen+0x12>
 238:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 23c:	60a2                	ld	ra,8(sp)
 23e:	6402                	ld	s0,0(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
  for(n = 0; s[n]; n++)
 244:	4501                	li	a0,0
 246:	bfdd                	j	23c <strlen+0x20>

0000000000000248 <memset>:

void*
memset(void *dst, int c, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e406                	sd	ra,8(sp)
 24c:	e022                	sd	s0,0(sp)
 24e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 250:	ca19                	beqz	a2,266 <memset+0x1e>
 252:	87aa                	mv	a5,a0
 254:	1602                	slli	a2,a2,0x20
 256:	9201                	srli	a2,a2,0x20
 258:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 260:	0785                	addi	a5,a5,1
 262:	fee79de3          	bne	a5,a4,25c <memset+0x14>
  }
  return dst;
}
 266:	60a2                	ld	ra,8(sp)
 268:	6402                	ld	s0,0(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret

000000000000026e <strchr>:

char*
strchr(const char *s, char c)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e406                	sd	ra,8(sp)
 272:	e022                	sd	s0,0(sp)
 274:	0800                	addi	s0,sp,16
  for(; *s; s++)
 276:	00054783          	lbu	a5,0(a0)
 27a:	cf81                	beqz	a5,292 <strchr+0x24>
    if(*s == c)
 27c:	00f58763          	beq	a1,a5,28a <strchr+0x1c>
  for(; *s; s++)
 280:	0505                	addi	a0,a0,1
 282:	00054783          	lbu	a5,0(a0)
 286:	fbfd                	bnez	a5,27c <strchr+0xe>
      return (char*)s;
  return 0;
 288:	4501                	li	a0,0
}
 28a:	60a2                	ld	ra,8(sp)
 28c:	6402                	ld	s0,0(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret
  return 0;
 292:	4501                	li	a0,0
 294:	bfdd                	j	28a <strchr+0x1c>

0000000000000296 <gets>:

char*
gets(char *buf, int max)
{
 296:	711d                	addi	sp,sp,-96
 298:	ec86                	sd	ra,88(sp)
 29a:	e8a2                	sd	s0,80(sp)
 29c:	e4a6                	sd	s1,72(sp)
 29e:	e0ca                	sd	s2,64(sp)
 2a0:	fc4e                	sd	s3,56(sp)
 2a2:	f852                	sd	s4,48(sp)
 2a4:	f456                	sd	s5,40(sp)
 2a6:	f05a                	sd	s6,32(sp)
 2a8:	ec5e                	sd	s7,24(sp)
 2aa:	e862                	sd	s8,16(sp)
 2ac:	1080                	addi	s0,sp,96
 2ae:	8baa                	mv	s7,a0
 2b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b2:	892a                	mv	s2,a0
 2b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2b6:	faf40b13          	addi	s6,s0,-81
 2ba:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2bc:	8c26                	mv	s8,s1
 2be:	0014899b          	addiw	s3,s1,1
 2c2:	84ce                	mv	s1,s3
 2c4:	0349d463          	bge	s3,s4,2ec <gets+0x56>
    cc = read(0, &c, 1);
 2c8:	8656                	mv	a2,s5
 2ca:	85da                	mv	a1,s6
 2cc:	4501                	li	a0,0
 2ce:	1bc000ef          	jal	48a <read>
    if(cc < 1)
 2d2:	00a05d63          	blez	a0,2ec <gets+0x56>
      break;
    buf[i++] = c;
 2d6:	faf44783          	lbu	a5,-81(s0)
 2da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2de:	0905                	addi	s2,s2,1
 2e0:	ff678713          	addi	a4,a5,-10
 2e4:	c319                	beqz	a4,2ea <gets+0x54>
 2e6:	17cd                	addi	a5,a5,-13
 2e8:	fbf1                	bnez	a5,2bc <gets+0x26>
    buf[i++] = c;
 2ea:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2ec:	9c5e                	add	s8,s8,s7
 2ee:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2f2:	855e                	mv	a0,s7
 2f4:	60e6                	ld	ra,88(sp)
 2f6:	6446                	ld	s0,80(sp)
 2f8:	64a6                	ld	s1,72(sp)
 2fa:	6906                	ld	s2,64(sp)
 2fc:	79e2                	ld	s3,56(sp)
 2fe:	7a42                	ld	s4,48(sp)
 300:	7aa2                	ld	s5,40(sp)
 302:	7b02                	ld	s6,32(sp)
 304:	6be2                	ld	s7,24(sp)
 306:	6c42                	ld	s8,16(sp)
 308:	6125                	addi	sp,sp,96
 30a:	8082                	ret

000000000000030c <stat>:

int
stat(const char *n, struct stat *st)
{
 30c:	1101                	addi	sp,sp,-32
 30e:	ec06                	sd	ra,24(sp)
 310:	e822                	sd	s0,16(sp)
 312:	e04a                	sd	s2,0(sp)
 314:	1000                	addi	s0,sp,32
 316:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 318:	4581                	li	a1,0
 31a:	198000ef          	jal	4b2 <open>
  if(fd < 0)
 31e:	02054263          	bltz	a0,342 <stat+0x36>
 322:	e426                	sd	s1,8(sp)
 324:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 326:	85ca                	mv	a1,s2
 328:	1a2000ef          	jal	4ca <fstat>
 32c:	892a                	mv	s2,a0
  close(fd);
 32e:	8526                	mv	a0,s1
 330:	16a000ef          	jal	49a <close>
  return r;
 334:	64a2                	ld	s1,8(sp)
}
 336:	854a                	mv	a0,s2
 338:	60e2                	ld	ra,24(sp)
 33a:	6442                	ld	s0,16(sp)
 33c:	6902                	ld	s2,0(sp)
 33e:	6105                	addi	sp,sp,32
 340:	8082                	ret
    return -1;
 342:	57fd                	li	a5,-1
 344:	893e                	mv	s2,a5
 346:	bfc5                	j	336 <stat+0x2a>

0000000000000348 <atoi>:

int
atoi(const char *s)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 350:	00054683          	lbu	a3,0(a0)
 354:	fd06879b          	addiw	a5,a3,-48
 358:	0ff7f793          	zext.b	a5,a5
 35c:	4625                	li	a2,9
 35e:	02f66963          	bltu	a2,a5,390 <atoi+0x48>
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
 384:	fef671e3          	bgeu	a2,a5,366 <atoi+0x1e>
  return n;
}
 388:	60a2                	ld	ra,8(sp)
 38a:	6402                	ld	s0,0(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret
  n = 0;
 390:	4501                	li	a0,0
 392:	bfdd                	j	388 <atoi+0x40>

0000000000000394 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 394:	1141                	addi	sp,sp,-16
 396:	e406                	sd	ra,8(sp)
 398:	e022                	sd	s0,0(sp)
 39a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 39c:	02b57563          	bgeu	a0,a1,3c6 <memmove+0x32>
    while(n-- > 0)
 3a0:	00c05f63          	blez	a2,3be <memmove+0x2a>
 3a4:	1602                	slli	a2,a2,0x20
 3a6:	9201                	srli	a2,a2,0x20
 3a8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ae:	0585                	addi	a1,a1,1
 3b0:	0705                	addi	a4,a4,1
 3b2:	fff5c683          	lbu	a3,-1(a1)
 3b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3ba:	fee79ae3          	bne	a5,a4,3ae <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
    while(n-- > 0)
 3c6:	fec05ce3          	blez	a2,3be <memmove+0x2a>
    dst += n;
 3ca:	00c50733          	add	a4,a0,a2
    src += n;
 3ce:	95b2                	add	a1,a1,a2
 3d0:	fff6079b          	addiw	a5,a2,-1
 3d4:	1782                	slli	a5,a5,0x20
 3d6:	9381                	srli	a5,a5,0x20
 3d8:	fff7c793          	not	a5,a5
 3dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3de:	15fd                	addi	a1,a1,-1
 3e0:	177d                	addi	a4,a4,-1
 3e2:	0005c683          	lbu	a3,0(a1)
 3e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ea:	fef71ae3          	bne	a4,a5,3de <memmove+0x4a>
 3ee:	bfc1                	j	3be <memmove+0x2a>

00000000000003f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e406                	sd	ra,8(sp)
 3f4:	e022                	sd	s0,0(sp)
 3f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f8:	c61d                	beqz	a2,426 <memcmp+0x36>
 3fa:	1602                	slli	a2,a2,0x20
 3fc:	9201                	srli	a2,a2,0x20
 3fe:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 402:	00054783          	lbu	a5,0(a0)
 406:	0005c703          	lbu	a4,0(a1)
 40a:	00e79863          	bne	a5,a4,41a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 40e:	0505                	addi	a0,a0,1
    p2++;
 410:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 412:	fed518e3          	bne	a0,a3,402 <memcmp+0x12>
  }
  return 0;
 416:	4501                	li	a0,0
 418:	a019                	j	41e <memcmp+0x2e>
      return *p1 - *p2;
 41a:	40e7853b          	subw	a0,a5,a4
}
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
  return 0;
 426:	4501                	li	a0,0
 428:	bfdd                	j	41e <memcmp+0x2e>

000000000000042a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42a:	1141                	addi	sp,sp,-16
 42c:	e406                	sd	ra,8(sp)
 42e:	e022                	sd	s0,0(sp)
 430:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 432:	f63ff0ef          	jal	394 <memmove>
}
 436:	60a2                	ld	ra,8(sp)
 438:	6402                	ld	s0,0(sp)
 43a:	0141                	addi	sp,sp,16
 43c:	8082                	ret

000000000000043e <sbrk>:

char *
sbrk(int n) {
 43e:	1141                	addi	sp,sp,-16
 440:	e406                	sd	ra,8(sp)
 442:	e022                	sd	s0,0(sp)
 444:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 446:	4585                	li	a1,1
 448:	0b2000ef          	jal	4fa <sys_sbrk>
}
 44c:	60a2                	ld	ra,8(sp)
 44e:	6402                	ld	s0,0(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret

0000000000000454 <sbrklazy>:

char *
sbrklazy(int n) {
 454:	1141                	addi	sp,sp,-16
 456:	e406                	sd	ra,8(sp)
 458:	e022                	sd	s0,0(sp)
 45a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 45c:	4589                	li	a1,2
 45e:	09c000ef          	jal	4fa <sys_sbrk>
}
 462:	60a2                	ld	ra,8(sp)
 464:	6402                	ld	s0,0(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret

000000000000046a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 46a:	4885                	li	a7,1
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <exit>:
.global exit
exit:
 li a7, SYS_exit
 472:	4889                	li	a7,2
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <wait>:
.global wait
wait:
 li a7, SYS_wait
 47a:	488d                	li	a7,3
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 482:	4891                	li	a7,4
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <read>:
.global read
read:
 li a7, SYS_read
 48a:	4895                	li	a7,5
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <write>:
.global write
write:
 li a7, SYS_write
 492:	48c1                	li	a7,16
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <close>:
.global close
close:
 li a7, SYS_close
 49a:	48d5                	li	a7,21
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a2:	4899                	li	a7,6
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 4aa:	489d                	li	a7,7
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <open>:
.global open
open:
 li a7, SYS_open
 4b2:	48bd                	li	a7,15
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ba:	48c5                	li	a7,17
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c2:	48c9                	li	a7,18
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ca:	48a1                	li	a7,8
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <link>:
.global link
link:
 li a7, SYS_link
 4d2:	48cd                	li	a7,19
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4da:	48d1                	li	a7,20
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e2:	48a5                	li	a7,9
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ea:	48a9                	li	a7,10
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f2:	48ad                	li	a7,11
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4fa:	48b1                	li	a7,12
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <pause>:
.global pause
pause:
 li a7, SYS_pause
 502:	48b5                	li	a7,13
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 50a:	48b9                	li	a7,14
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 512:	48d9                	li	a7,22
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 51a:	48dd                	li	a7,23
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 522:	1101                	addi	sp,sp,-32
 524:	ec06                	sd	ra,24(sp)
 526:	e822                	sd	s0,16(sp)
 528:	1000                	addi	s0,sp,32
 52a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 52e:	4605                	li	a2,1
 530:	fef40593          	addi	a1,s0,-17
 534:	f5fff0ef          	jal	492 <write>
}
 538:	60e2                	ld	ra,24(sp)
 53a:	6442                	ld	s0,16(sp)
 53c:	6105                	addi	sp,sp,32
 53e:	8082                	ret

0000000000000540 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 540:	715d                	addi	sp,sp,-80
 542:	e486                	sd	ra,72(sp)
 544:	e0a2                	sd	s0,64(sp)
 546:	f84a                	sd	s2,48(sp)
 548:	f44e                	sd	s3,40(sp)
 54a:	0880                	addi	s0,sp,80
 54c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 54e:	c6d1                	beqz	a3,5da <printint+0x9a>
 550:	0805d563          	bgez	a1,5da <printint+0x9a>
    neg = 1;
    x = -xx;
 554:	40b005b3          	neg	a1,a1
    neg = 1;
 558:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 55a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 55e:	86ce                	mv	a3,s3
  i = 0;
 560:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 562:	00001817          	auipc	a6,0x1
 566:	83e80813          	addi	a6,a6,-1986 # da0 <digits>
 56a:	88ba                	mv	a7,a4
 56c:	0017051b          	addiw	a0,a4,1
 570:	872a                	mv	a4,a0
 572:	02c5f7b3          	remu	a5,a1,a2
 576:	97c2                	add	a5,a5,a6
 578:	0007c783          	lbu	a5,0(a5)
 57c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 580:	87ae                	mv	a5,a1
 582:	02c5d5b3          	divu	a1,a1,a2
 586:	0685                	addi	a3,a3,1
 588:	fec7f1e3          	bgeu	a5,a2,56a <printint+0x2a>
  if(neg)
 58c:	00030c63          	beqz	t1,5a4 <printint+0x64>
    buf[i++] = '-';
 590:	fd050793          	addi	a5,a0,-48
 594:	00878533          	add	a0,a5,s0
 598:	02d00793          	li	a5,45
 59c:	fef50423          	sb	a5,-24(a0)
 5a0:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 5a4:	02e05563          	blez	a4,5ce <printint+0x8e>
 5a8:	fc26                	sd	s1,56(sp)
 5aa:	377d                	addiw	a4,a4,-1
 5ac:	00e984b3          	add	s1,s3,a4
 5b0:	19fd                	addi	s3,s3,-1
 5b2:	99ba                	add	s3,s3,a4
 5b4:	1702                	slli	a4,a4,0x20
 5b6:	9301                	srli	a4,a4,0x20
 5b8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5bc:	0004c583          	lbu	a1,0(s1)
 5c0:	854a                	mv	a0,s2
 5c2:	f61ff0ef          	jal	522 <putc>
  while(--i >= 0)
 5c6:	14fd                	addi	s1,s1,-1
 5c8:	ff349ae3          	bne	s1,s3,5bc <printint+0x7c>
 5cc:	74e2                	ld	s1,56(sp)
}
 5ce:	60a6                	ld	ra,72(sp)
 5d0:	6406                	ld	s0,64(sp)
 5d2:	7942                	ld	s2,48(sp)
 5d4:	79a2                	ld	s3,40(sp)
 5d6:	6161                	addi	sp,sp,80
 5d8:	8082                	ret
  neg = 0;
 5da:	4301                	li	t1,0
 5dc:	bfbd                	j	55a <printint+0x1a>

00000000000005de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5de:	711d                	addi	sp,sp,-96
 5e0:	ec86                	sd	ra,88(sp)
 5e2:	e8a2                	sd	s0,80(sp)
 5e4:	e4a6                	sd	s1,72(sp)
 5e6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e8:	0005c483          	lbu	s1,0(a1)
 5ec:	22048363          	beqz	s1,812 <vprintf+0x234>
 5f0:	e0ca                	sd	s2,64(sp)
 5f2:	fc4e                	sd	s3,56(sp)
 5f4:	f852                	sd	s4,48(sp)
 5f6:	f456                	sd	s5,40(sp)
 5f8:	f05a                	sd	s6,32(sp)
 5fa:	ec5e                	sd	s7,24(sp)
 5fc:	e862                	sd	s8,16(sp)
 5fe:	8b2a                	mv	s6,a0
 600:	8a2e                	mv	s4,a1
 602:	8bb2                	mv	s7,a2
  state = 0;
 604:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 606:	4901                	li	s2,0
 608:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 60a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 60e:	06400c13          	li	s8,100
 612:	a00d                	j	634 <vprintf+0x56>
        putc(fd, c0);
 614:	85a6                	mv	a1,s1
 616:	855a                	mv	a0,s6
 618:	f0bff0ef          	jal	522 <putc>
 61c:	a019                	j	622 <vprintf+0x44>
    } else if(state == '%'){
 61e:	03598363          	beq	s3,s5,644 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 622:	0019079b          	addiw	a5,s2,1
 626:	893e                	mv	s2,a5
 628:	873e                	mv	a4,a5
 62a:	97d2                	add	a5,a5,s4
 62c:	0007c483          	lbu	s1,0(a5)
 630:	1c048a63          	beqz	s1,804 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 634:	0004879b          	sext.w	a5,s1
    if(state == 0){
 638:	fe0993e3          	bnez	s3,61e <vprintf+0x40>
      if(c0 == '%'){
 63c:	fd579ce3          	bne	a5,s5,614 <vprintf+0x36>
        state = '%';
 640:	89be                	mv	s3,a5
 642:	b7c5                	j	622 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 644:	00ea06b3          	add	a3,s4,a4
 648:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 64c:	1c060863          	beqz	a2,81c <vprintf+0x23e>
      if(c0 == 'd'){
 650:	03878763          	beq	a5,s8,67e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 654:	f9478693          	addi	a3,a5,-108
 658:	0016b693          	seqz	a3,a3
 65c:	f9c60593          	addi	a1,a2,-100
 660:	e99d                	bnez	a1,696 <vprintf+0xb8>
 662:	ca95                	beqz	a3,696 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 664:	008b8493          	addi	s1,s7,8
 668:	4685                	li	a3,1
 66a:	4629                	li	a2,10
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	ecfff0ef          	jal	540 <printint>
        i += 1;
 676:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 678:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 67a:	4981                	li	s3,0
 67c:	b75d                	j	622 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 67e:	008b8493          	addi	s1,s7,8
 682:	4685                	li	a3,1
 684:	4629                	li	a2,10
 686:	000ba583          	lw	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	eb5ff0ef          	jal	540 <printint>
 690:	8ba6                	mv	s7,s1
      state = 0;
 692:	4981                	li	s3,0
 694:	b779                	j	622 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 696:	9752                	add	a4,a4,s4
 698:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 69c:	f9460713          	addi	a4,a2,-108
 6a0:	00173713          	seqz	a4,a4
 6a4:	8f75                	and	a4,a4,a3
 6a6:	f9c58513          	addi	a0,a1,-100
 6aa:	18051363          	bnez	a0,830 <vprintf+0x252>
 6ae:	18070163          	beqz	a4,830 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b2:	008b8493          	addi	s1,s7,8
 6b6:	4685                	li	a3,1
 6b8:	4629                	li	a2,10
 6ba:	000bb583          	ld	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	e81ff0ef          	jal	540 <printint>
        i += 2;
 6c4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c6:	8ba6                	mv	s7,s1
      state = 0;
 6c8:	4981                	li	s3,0
        i += 2;
 6ca:	bfa1                	j	622 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6cc:	008b8493          	addi	s1,s7,8
 6d0:	4681                	li	a3,0
 6d2:	4629                	li	a2,10
 6d4:	000be583          	lwu	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	e67ff0ef          	jal	540 <printint>
 6de:	8ba6                	mv	s7,s1
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b781                	j	622 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e4:	008b8493          	addi	s1,s7,8
 6e8:	4681                	li	a3,0
 6ea:	4629                	li	a2,10
 6ec:	000bb583          	ld	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	e4fff0ef          	jal	540 <printint>
        i += 1;
 6f6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f8:	8ba6                	mv	s7,s1
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b71d                	j	622 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fe:	008b8493          	addi	s1,s7,8
 702:	4681                	li	a3,0
 704:	4629                	li	a2,10
 706:	000bb583          	ld	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	e35ff0ef          	jal	540 <printint>
        i += 2;
 710:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 712:	8ba6                	mv	s7,s1
      state = 0;
 714:	4981                	li	s3,0
        i += 2;
 716:	b731                	j	622 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 718:	008b8493          	addi	s1,s7,8
 71c:	4681                	li	a3,0
 71e:	4641                	li	a2,16
 720:	000be583          	lwu	a1,0(s7)
 724:	855a                	mv	a0,s6
 726:	e1bff0ef          	jal	540 <printint>
 72a:	8ba6                	mv	s7,s1
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bdd5                	j	622 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 730:	008b8493          	addi	s1,s7,8
 734:	4681                	li	a3,0
 736:	4641                	li	a2,16
 738:	000bb583          	ld	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	e03ff0ef          	jal	540 <printint>
        i += 1;
 742:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 744:	8ba6                	mv	s7,s1
      state = 0;
 746:	4981                	li	s3,0
 748:	bde9                	j	622 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 74a:	008b8493          	addi	s1,s7,8
 74e:	4681                	li	a3,0
 750:	4641                	li	a2,16
 752:	000bb583          	ld	a1,0(s7)
 756:	855a                	mv	a0,s6
 758:	de9ff0ef          	jal	540 <printint>
        i += 2;
 75c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 75e:	8ba6                	mv	s7,s1
      state = 0;
 760:	4981                	li	s3,0
        i += 2;
 762:	b5c1                	j	622 <vprintf+0x44>
 764:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 766:	008b8793          	addi	a5,s7,8
 76a:	8cbe                	mv	s9,a5
 76c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 770:	03000593          	li	a1,48
 774:	855a                	mv	a0,s6
 776:	dadff0ef          	jal	522 <putc>
  putc(fd, 'x');
 77a:	07800593          	li	a1,120
 77e:	855a                	mv	a0,s6
 780:	da3ff0ef          	jal	522 <putc>
 784:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 786:	00000b97          	auipc	s7,0x0
 78a:	61ab8b93          	addi	s7,s7,1562 # da0 <digits>
 78e:	03c9d793          	srli	a5,s3,0x3c
 792:	97de                	add	a5,a5,s7
 794:	0007c583          	lbu	a1,0(a5)
 798:	855a                	mv	a0,s6
 79a:	d89ff0ef          	jal	522 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 79e:	0992                	slli	s3,s3,0x4
 7a0:	34fd                	addiw	s1,s1,-1
 7a2:	f4f5                	bnez	s1,78e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 7a4:	8be6                	mv	s7,s9
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	6ca2                	ld	s9,8(sp)
 7aa:	bda5                	j	622 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 7ac:	008b8493          	addi	s1,s7,8
 7b0:	000bc583          	lbu	a1,0(s7)
 7b4:	855a                	mv	a0,s6
 7b6:	d6dff0ef          	jal	522 <putc>
 7ba:	8ba6                	mv	s7,s1
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	b595                	j	622 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7c0:	008b8993          	addi	s3,s7,8
 7c4:	000bb483          	ld	s1,0(s7)
 7c8:	cc91                	beqz	s1,7e4 <vprintf+0x206>
        for(; *s; s++)
 7ca:	0004c583          	lbu	a1,0(s1)
 7ce:	c985                	beqz	a1,7fe <vprintf+0x220>
          putc(fd, *s);
 7d0:	855a                	mv	a0,s6
 7d2:	d51ff0ef          	jal	522 <putc>
        for(; *s; s++)
 7d6:	0485                	addi	s1,s1,1
 7d8:	0004c583          	lbu	a1,0(s1)
 7dc:	f9f5                	bnez	a1,7d0 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7de:	8bce                	mv	s7,s3
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	b581                	j	622 <vprintf+0x44>
          s = "(null)";
 7e4:	00000497          	auipc	s1,0x0
 7e8:	5b448493          	addi	s1,s1,1460 # d98 <malloc+0x418>
        for(; *s; s++)
 7ec:	02800593          	li	a1,40
 7f0:	b7c5                	j	7d0 <vprintf+0x1f2>
        putc(fd, '%');
 7f2:	85be                	mv	a1,a5
 7f4:	855a                	mv	a0,s6
 7f6:	d2dff0ef          	jal	522 <putc>
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b51d                	j	622 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7fe:	8bce                	mv	s7,s3
      state = 0;
 800:	4981                	li	s3,0
 802:	b505                	j	622 <vprintf+0x44>
 804:	6906                	ld	s2,64(sp)
 806:	79e2                	ld	s3,56(sp)
 808:	7a42                	ld	s4,48(sp)
 80a:	7aa2                	ld	s5,40(sp)
 80c:	7b02                	ld	s6,32(sp)
 80e:	6be2                	ld	s7,24(sp)
 810:	6c42                	ld	s8,16(sp)
    }
  }
}
 812:	60e6                	ld	ra,88(sp)
 814:	6446                	ld	s0,80(sp)
 816:	64a6                	ld	s1,72(sp)
 818:	6125                	addi	sp,sp,96
 81a:	8082                	ret
      if(c0 == 'd'){
 81c:	06400713          	li	a4,100
 820:	e4e78fe3          	beq	a5,a4,67e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 824:	f9478693          	addi	a3,a5,-108
 828:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 82c:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 82e:	4701                	li	a4,0
      } else if(c0 == 'u'){
 830:	07500513          	li	a0,117
 834:	e8a78ce3          	beq	a5,a0,6cc <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 838:	f8b60513          	addi	a0,a2,-117
 83c:	e119                	bnez	a0,842 <vprintf+0x264>
 83e:	ea0693e3          	bnez	a3,6e4 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 842:	f8b58513          	addi	a0,a1,-117
 846:	e119                	bnez	a0,84c <vprintf+0x26e>
 848:	ea071be3          	bnez	a4,6fe <vprintf+0x120>
      } else if(c0 == 'x'){
 84c:	07800513          	li	a0,120
 850:	eca784e3          	beq	a5,a0,718 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 854:	f8860613          	addi	a2,a2,-120
 858:	e219                	bnez	a2,85e <vprintf+0x280>
 85a:	ec069be3          	bnez	a3,730 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 85e:	f8858593          	addi	a1,a1,-120
 862:	e199                	bnez	a1,868 <vprintf+0x28a>
 864:	ee0713e3          	bnez	a4,74a <vprintf+0x16c>
      } else if(c0 == 'p'){
 868:	07000713          	li	a4,112
 86c:	eee78ce3          	beq	a5,a4,764 <vprintf+0x186>
      } else if(c0 == 'c'){
 870:	06300713          	li	a4,99
 874:	f2e78ce3          	beq	a5,a4,7ac <vprintf+0x1ce>
      } else if(c0 == 's'){
 878:	07300713          	li	a4,115
 87c:	f4e782e3          	beq	a5,a4,7c0 <vprintf+0x1e2>
      } else if(c0 == '%'){
 880:	02500713          	li	a4,37
 884:	f6e787e3          	beq	a5,a4,7f2 <vprintf+0x214>
        putc(fd, '%');
 888:	02500593          	li	a1,37
 88c:	855a                	mv	a0,s6
 88e:	c95ff0ef          	jal	522 <putc>
        putc(fd, c0);
 892:	85a6                	mv	a1,s1
 894:	855a                	mv	a0,s6
 896:	c8dff0ef          	jal	522 <putc>
      state = 0;
 89a:	4981                	li	s3,0
 89c:	b359                	j	622 <vprintf+0x44>

000000000000089e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89e:	715d                	addi	sp,sp,-80
 8a0:	ec06                	sd	ra,24(sp)
 8a2:	e822                	sd	s0,16(sp)
 8a4:	1000                	addi	s0,sp,32
 8a6:	e010                	sd	a2,0(s0)
 8a8:	e414                	sd	a3,8(s0)
 8aa:	e818                	sd	a4,16(s0)
 8ac:	ec1c                	sd	a5,24(s0)
 8ae:	03043023          	sd	a6,32(s0)
 8b2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b6:	8622                	mv	a2,s0
 8b8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8bc:	d23ff0ef          	jal	5de <vprintf>
}
 8c0:	60e2                	ld	ra,24(sp)
 8c2:	6442                	ld	s0,16(sp)
 8c4:	6161                	addi	sp,sp,80
 8c6:	8082                	ret

00000000000008c8 <printf>:

void
printf(const char *fmt, ...)
{
 8c8:	711d                	addi	sp,sp,-96
 8ca:	ec06                	sd	ra,24(sp)
 8cc:	e822                	sd	s0,16(sp)
 8ce:	1000                	addi	s0,sp,32
 8d0:	e40c                	sd	a1,8(s0)
 8d2:	e810                	sd	a2,16(s0)
 8d4:	ec14                	sd	a3,24(s0)
 8d6:	f018                	sd	a4,32(s0)
 8d8:	f41c                	sd	a5,40(s0)
 8da:	03043823          	sd	a6,48(s0)
 8de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e2:	00840613          	addi	a2,s0,8
 8e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ea:	85aa                	mv	a1,a0
 8ec:	4505                	li	a0,1
 8ee:	cf1ff0ef          	jal	5de <vprintf>
}
 8f2:	60e2                	ld	ra,24(sp)
 8f4:	6442                	ld	s0,16(sp)
 8f6:	6125                	addi	sp,sp,96
 8f8:	8082                	ret

00000000000008fa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8fa:	1141                	addi	sp,sp,-16
 8fc:	e406                	sd	ra,8(sp)
 8fe:	e022                	sd	s0,0(sp)
 900:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 902:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 906:	00000797          	auipc	a5,0x0
 90a:	6fa7b783          	ld	a5,1786(a5) # 1000 <freep>
 90e:	a039                	j	91c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 910:	6398                	ld	a4,0(a5)
 912:	00e7e463          	bltu	a5,a4,91a <free+0x20>
 916:	00e6ea63          	bltu	a3,a4,92a <free+0x30>
{
 91a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91c:	fed7fae3          	bgeu	a5,a3,910 <free+0x16>
 920:	6398                	ld	a4,0(a5)
 922:	00e6e463          	bltu	a3,a4,92a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 926:	fee7eae3          	bltu	a5,a4,91a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 92a:	ff852583          	lw	a1,-8(a0)
 92e:	6390                	ld	a2,0(a5)
 930:	02059813          	slli	a6,a1,0x20
 934:	01c85713          	srli	a4,a6,0x1c
 938:	9736                	add	a4,a4,a3
 93a:	02e60563          	beq	a2,a4,964 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 93e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 942:	4790                	lw	a2,8(a5)
 944:	02061593          	slli	a1,a2,0x20
 948:	01c5d713          	srli	a4,a1,0x1c
 94c:	973e                	add	a4,a4,a5
 94e:	02e68263          	beq	a3,a4,972 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 952:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 954:	00000717          	auipc	a4,0x0
 958:	6af73623          	sd	a5,1708(a4) # 1000 <freep>
}
 95c:	60a2                	ld	ra,8(sp)
 95e:	6402                	ld	s0,0(sp)
 960:	0141                	addi	sp,sp,16
 962:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 964:	4618                	lw	a4,8(a2)
 966:	9f2d                	addw	a4,a4,a1
 968:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 96c:	6398                	ld	a4,0(a5)
 96e:	6310                	ld	a2,0(a4)
 970:	b7f9                	j	93e <free+0x44>
    p->s.size += bp->s.size;
 972:	ff852703          	lw	a4,-8(a0)
 976:	9f31                	addw	a4,a4,a2
 978:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 97a:	ff053683          	ld	a3,-16(a0)
 97e:	bfd1                	j	952 <free+0x58>

0000000000000980 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 980:	7139                	addi	sp,sp,-64
 982:	fc06                	sd	ra,56(sp)
 984:	f822                	sd	s0,48(sp)
 986:	f04a                	sd	s2,32(sp)
 988:	ec4e                	sd	s3,24(sp)
 98a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 98c:	02051993          	slli	s3,a0,0x20
 990:	0209d993          	srli	s3,s3,0x20
 994:	09bd                	addi	s3,s3,15
 996:	0049d993          	srli	s3,s3,0x4
 99a:	2985                	addiw	s3,s3,1
 99c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 99e:	00000517          	auipc	a0,0x0
 9a2:	66253503          	ld	a0,1634(a0) # 1000 <freep>
 9a6:	c905                	beqz	a0,9d6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9aa:	4798                	lw	a4,8(a5)
 9ac:	09377663          	bgeu	a4,s3,a38 <malloc+0xb8>
 9b0:	f426                	sd	s1,40(sp)
 9b2:	e852                	sd	s4,16(sp)
 9b4:	e456                	sd	s5,8(sp)
 9b6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9b8:	8a4e                	mv	s4,s3
 9ba:	6705                	lui	a4,0x1
 9bc:	00e9f363          	bgeu	s3,a4,9c2 <malloc+0x42>
 9c0:	6a05                	lui	s4,0x1
 9c2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9c6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ca:	00000497          	auipc	s1,0x0
 9ce:	63648493          	addi	s1,s1,1590 # 1000 <freep>
  if(p == SBRK_ERROR)
 9d2:	5afd                	li	s5,-1
 9d4:	a83d                	j	a12 <malloc+0x92>
 9d6:	f426                	sd	s1,40(sp)
 9d8:	e852                	sd	s4,16(sp)
 9da:	e456                	sd	s5,8(sp)
 9dc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9de:	00000797          	auipc	a5,0x0
 9e2:	63278793          	addi	a5,a5,1586 # 1010 <base>
 9e6:	00000717          	auipc	a4,0x0
 9ea:	60f73d23          	sd	a5,1562(a4) # 1000 <freep>
 9ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f4:	b7d1                	j	9b8 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9f6:	6398                	ld	a4,0(a5)
 9f8:	e118                	sd	a4,0(a0)
 9fa:	a899                	j	a50 <malloc+0xd0>
  hp->s.size = nu;
 9fc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a00:	0541                	addi	a0,a0,16
 a02:	ef9ff0ef          	jal	8fa <free>
  return freep;
 a06:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a08:	c125                	beqz	a0,a68 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0c:	4798                	lw	a4,8(a5)
 a0e:	03277163          	bgeu	a4,s2,a30 <malloc+0xb0>
    if(p == freep)
 a12:	6098                	ld	a4,0(s1)
 a14:	853e                	mv	a0,a5
 a16:	fef71ae3          	bne	a4,a5,a0a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a1a:	8552                	mv	a0,s4
 a1c:	a23ff0ef          	jal	43e <sbrk>
  if(p == SBRK_ERROR)
 a20:	fd551ee3          	bne	a0,s5,9fc <malloc+0x7c>
        return 0;
 a24:	4501                	li	a0,0
 a26:	74a2                	ld	s1,40(sp)
 a28:	6a42                	ld	s4,16(sp)
 a2a:	6aa2                	ld	s5,8(sp)
 a2c:	6b02                	ld	s6,0(sp)
 a2e:	a03d                	j	a5c <malloc+0xdc>
 a30:	74a2                	ld	s1,40(sp)
 a32:	6a42                	ld	s4,16(sp)
 a34:	6aa2                	ld	s5,8(sp)
 a36:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a38:	fae90fe3          	beq	s2,a4,9f6 <malloc+0x76>
        p->s.size -= nunits;
 a3c:	4137073b          	subw	a4,a4,s3
 a40:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a42:	02071693          	slli	a3,a4,0x20
 a46:	01c6d713          	srli	a4,a3,0x1c
 a4a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a4c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a50:	00000717          	auipc	a4,0x0
 a54:	5aa73823          	sd	a0,1456(a4) # 1000 <freep>
      return (void*)(p + 1);
 a58:	01078513          	addi	a0,a5,16
  }
}
 a5c:	70e2                	ld	ra,56(sp)
 a5e:	7442                	ld	s0,48(sp)
 a60:	7902                	ld	s2,32(sp)
 a62:	69e2                	ld	s3,24(sp)
 a64:	6121                	addi	sp,sp,64
 a66:	8082                	ret
 a68:	74a2                	ld	s1,40(sp)
 a6a:	6a42                	ld	s4,16(sp)
 a6c:	6aa2                	ld	s5,8(sp)
 a6e:	6b02                	ld	s6,0(sp)
 a70:	b7f5                	j	a5c <malloc+0xdc>
