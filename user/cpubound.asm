
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
  14:	1880                	addi	s0,sp,112
  struct procinfo info;
  volatile int dummy = 0;
  16:	f8042e23          	sw	zero,-100(s0)
  
  printf("=== Comprehensive CPU-Bound Test ===\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	a0650513          	addi	a0,a0,-1530 # a20 <malloc+0x100>
  22:	04b000ef          	jal	86c <printf>
  printf("This process will run CPU-intensive work for ~30 seconds.\n");
  26:	00001517          	auipc	a0,0x1
  2a:	a2a50513          	addi	a0,a0,-1494 # a50 <malloc+0x130>
  2e:	03f000ef          	jal	86c <printf>
  printf("Watch priority change from Q0 -> Q1 -> Q2 -> Q3\n\n");
  32:	00001517          	auipc	a0,0x1
  36:	a5e50513          	addi	a0,a0,-1442 # a90 <malloc+0x170>
  3a:	033000ef          	jal	86c <printf>
  
  if(getprocinfo(&info) == 0) {
  3e:	fa040513          	addi	a0,s0,-96
  42:	492000ef          	jal	4d4 <getprocinfo>
  46:	c935                	beqz	a0,ba <main+0xba>
           info.pid, info.priority, info.time_slices);
  }
  
  // Massive continuous CPU work without any yields
  // Each iteration takes significant time (multiple timer ticks)
  printf("Running continuous computation (no sleeps, no syscalls)...\n");
  48:	00001517          	auipc	a0,0x1
  4c:	ab050513          	addi	a0,a0,-1360 # af8 <malloc+0x1d8>
  50:	01d000ef          	jal	86c <printf>
  printf("Expected demotions:\n");
  54:	00001517          	auipc	a0,0x1
  58:	ae450513          	addi	a0,a0,-1308 # b38 <malloc+0x218>
  5c:	011000ef          	jal	86c <printf>
  printf("  0-2 ticks   : Q0 (initial)\n");
  60:	00001517          	auipc	a0,0x1
  64:	af050513          	addi	a0,a0,-1296 # b50 <malloc+0x230>
  68:	005000ef          	jal	86c <printf>
  printf("  2-6 ticks   : Q1 (after first demotion)\n");
  6c:	00001517          	auipc	a0,0x1
  70:	b0450513          	addi	a0,a0,-1276 # b70 <malloc+0x250>
  74:	7f8000ef          	jal	86c <printf>
  printf("  6-14 ticks  : Q2 (after second demotion)\n");
  78:	00001517          	auipc	a0,0x1
  7c:	b2850513          	addi	a0,a0,-1240 # ba0 <malloc+0x280>
  80:	7ec000ef          	jal	86c <printf>
  printf("  14+ ticks   : Q3 (after third demotion)\n\n");
  84:	00001517          	auipc	a0,0x1
  88:	b4c50513          	addi	a0,a0,-1204 # bd0 <malloc+0x2b0>
  8c:	7e0000ef          	jal	86c <printf>
  
  // Do MASSIVE amount of work - much more than purecpu
  // 500M iterations = ~5 seconds of continuous work
  // Should easily hit all 4 queues multiple times
  for(int iter = 0; iter < 50; iter++) {
  90:	4981                	li	s3,0
    // Each inner loop: 10M iterations
    for(long j = 0; j < 10000000; j++) {
      dummy = dummy + j;
      dummy = dummy % 1000000;
  92:	000f4937          	lui	s2,0xf4
  96:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2230>
    for(long j = 0; j < 10000000; j++) {
  9a:	009894b7          	lui	s1,0x989
  9e:	68048493          	addi	s1,s1,1664 # 989680 <base+0x987670>
    }
    
    // Every iteration, check status
    if(getprocinfo(&info) == 0) {
      printf("Checkpoint %d: Priority=Q%d, TimeSlices=%d\n", 
  a2:	00001b17          	auipc	s6,0x1
  a6:	b5eb0b13          	addi	s6,s6,-1186 # c00 <malloc+0x2e0>
             iter, info.priority, info.time_slices);
    }
    
    // Stop if we've seen enough data
    if(iter == 30) {
  aa:	4a79                	li	s4,30
  for(int iter = 0; iter < 50; iter++) {
  ac:	03200a93          	li	s5,50
      printf("\n(Continuing in background for full test...)\n");
  b0:	00001b97          	auipc	s7,0x1
  b4:	b80b8b93          	addi	s7,s7,-1152 # c30 <malloc+0x310>
  b8:	a01d                	j	de <main+0xde>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
  ba:	fac42683          	lw	a3,-84(s0)
  be:	fa842603          	lw	a2,-88(s0)
  c2:	fa042583          	lw	a1,-96(s0)
  c6:	00001517          	auipc	a0,0x1
  ca:	a0250513          	addi	a0,a0,-1534 # ac8 <malloc+0x1a8>
  ce:	79e000ef          	jal	86c <printf>
  d2:	bf9d                	j	48 <main+0x48>
    if(iter == 30) {
  d4:	05498263          	beq	s3,s4,118 <main+0x118>
  for(int iter = 0; iter < 50; iter++) {
  d8:	2985                	addiw	s3,s3,1
  da:	05598463          	beq	s3,s5,122 <main+0x122>
    for(long j = 0; j < 10000000; j++) {
  de:	4781                	li	a5,0
      dummy = dummy + j;
  e0:	f9c42703          	lw	a4,-100(s0)
  e4:	9f3d                	addw	a4,a4,a5
  e6:	f8e42e23          	sw	a4,-100(s0)
      dummy = dummy % 1000000;
  ea:	f9c42703          	lw	a4,-100(s0)
  ee:	0327673b          	remw	a4,a4,s2
  f2:	f8e42e23          	sw	a4,-100(s0)
    for(long j = 0; j < 10000000; j++) {
  f6:	0785                	addi	a5,a5,1
  f8:	fe9794e3          	bne	a5,s1,e0 <main+0xe0>
    if(getprocinfo(&info) == 0) {
  fc:	fa040513          	addi	a0,s0,-96
 100:	3d4000ef          	jal	4d4 <getprocinfo>
 104:	f961                	bnez	a0,d4 <main+0xd4>
      printf("Checkpoint %d: Priority=Q%d, TimeSlices=%d\n", 
 106:	fac42683          	lw	a3,-84(s0)
 10a:	fa842603          	lw	a2,-88(s0)
 10e:	85ce                	mv	a1,s3
 110:	855a                	mv	a0,s6
 112:	75a000ef          	jal	86c <printf>
 116:	bf7d                	j	d4 <main+0xd4>
      printf("\n(Continuing in background for full test...)\n");
 118:	855e                	mv	a0,s7
 11a:	752000ef          	jal	86c <printf>
  for(int iter = 0; iter < 50; iter++) {
 11e:	2985                	addiw	s3,s3,1
 120:	bf7d                	j	de <main+0xde>
    }
  }
  
  // Final check
  printf("\n");
 122:	00001517          	auipc	a0,0x1
 126:	b3e50513          	addi	a0,a0,-1218 # c60 <malloc+0x340>
 12a:	742000ef          	jal	86c <printf>
  if(getprocinfo(&info) == 0) {
 12e:	fa040513          	addi	a0,s0,-96
 132:	3a2000ef          	jal	4d4 <getprocinfo>
 136:	c501                	beqz	a0,13e <main+0x13e>
    } else {
      printf("✗ FAILED: Stayed at Q0\n");
    }
  }
  
  exit(0);
 138:	4501                	li	a0,0
 13a:	2fa000ef          	jal	434 <exit>
    printf("Final Result: Priority=Q%d, TimeSlices=%d\n", 
 13e:	fac42603          	lw	a2,-84(s0)
 142:	fa842583          	lw	a1,-88(s0)
 146:	00001517          	auipc	a0,0x1
 14a:	b2250513          	addi	a0,a0,-1246 # c68 <malloc+0x348>
 14e:	71e000ef          	jal	86c <printf>
    if(info.priority == 3) {
 152:	fa842783          	lw	a5,-88(s0)
 156:	470d                	li	a4,3
 158:	00e78f63          	beq	a5,a4,176 <main+0x176>
    } else if(info.priority == 2) {
 15c:	4709                	li	a4,2
 15e:	02e78363          	beq	a5,a4,184 <main+0x184>
    } else if(info.priority == 1) {
 162:	4705                	li	a4,1
 164:	02e78763          	beq	a5,a4,192 <main+0x192>
      printf("✗ FAILED: Stayed at Q0\n");
 168:	00001517          	auipc	a0,0x1
 16c:	bb050513          	addi	a0,a0,-1104 # d18 <malloc+0x3f8>
 170:	6fc000ef          	jal	86c <printf>
 174:	b7d1                	j	138 <main+0x138>
      printf("✓ EXCELLENT: Reached Q3 (CPU-bound category)\n");
 176:	00001517          	auipc	a0,0x1
 17a:	b2250513          	addi	a0,a0,-1246 # c98 <malloc+0x378>
 17e:	6ee000ef          	jal	86c <printf>
 182:	bf5d                	j	138 <main+0x138>
      printf("✓ GOOD: Reached Q2 (mid-range demotion)\n");
 184:	00001517          	auipc	a0,0x1
 188:	b4450513          	addi	a0,a0,-1212 # cc8 <malloc+0x3a8>
 18c:	6e0000ef          	jal	86c <printf>
 190:	b765                	j	138 <main+0x138>
      printf("~ PARTIAL: Only reached Q1\n");
 192:	00001517          	auipc	a0,0x1
 196:	b6650513          	addi	a0,a0,-1178 # cf8 <malloc+0x3d8>
 19a:	6d2000ef          	jal	86c <printf>
 19e:	bf69                	j	138 <main+0x138>

00000000000001a0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e406                	sd	ra,8(sp)
 1a4:	e022                	sd	s0,0(sp)
 1a6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1a8:	e59ff0ef          	jal	0 <main>
  exit(r);
 1ac:	288000ef          	jal	434 <exit>

00000000000001b0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b6:	87aa                	mv	a5,a0
 1b8:	0585                	addi	a1,a1,1
 1ba:	0785                	addi	a5,a5,1
 1bc:	fff5c703          	lbu	a4,-1(a1)
 1c0:	fee78fa3          	sb	a4,-1(a5)
 1c4:	fb75                	bnez	a4,1b8 <strcpy+0x8>
    ;
  return os;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb91                	beqz	a5,1ea <strcmp+0x1e>
 1d8:	0005c703          	lbu	a4,0(a1)
 1dc:	00f71763          	bne	a4,a5,1ea <strcmp+0x1e>
    p++, q++;
 1e0:	0505                	addi	a0,a0,1
 1e2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbe5                	bnez	a5,1d8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ea:	0005c503          	lbu	a0,0(a1)
}
 1ee:	40a7853b          	subw	a0,a5,a0
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strlen>:

uint
strlen(const char *s)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1fe:	00054783          	lbu	a5,0(a0)
 202:	cf91                	beqz	a5,21e <strlen+0x26>
 204:	0505                	addi	a0,a0,1
 206:	87aa                	mv	a5,a0
 208:	86be                	mv	a3,a5
 20a:	0785                	addi	a5,a5,1
 20c:	fff7c703          	lbu	a4,-1(a5)
 210:	ff65                	bnez	a4,208 <strlen+0x10>
 212:	40a6853b          	subw	a0,a3,a0
 216:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
  for(n = 0; s[n]; n++)
 21e:	4501                	li	a0,0
 220:	bfe5                	j	218 <strlen+0x20>

0000000000000222 <memset>:

void*
memset(void *dst, int c, uint n)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 228:	ca19                	beqz	a2,23e <memset+0x1c>
 22a:	87aa                	mv	a5,a0
 22c:	1602                	slli	a2,a2,0x20
 22e:	9201                	srli	a2,a2,0x20
 230:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 234:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 238:	0785                	addi	a5,a5,1
 23a:	fee79de3          	bne	a5,a4,234 <memset+0x12>
  }
  return dst;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret

0000000000000244 <strchr>:

char*
strchr(const char *s, char c)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  for(; *s; s++)
 24a:	00054783          	lbu	a5,0(a0)
 24e:	cb99                	beqz	a5,264 <strchr+0x20>
    if(*s == c)
 250:	00f58763          	beq	a1,a5,25e <strchr+0x1a>
  for(; *s; s++)
 254:	0505                	addi	a0,a0,1
 256:	00054783          	lbu	a5,0(a0)
 25a:	fbfd                	bnez	a5,250 <strchr+0xc>
      return (char*)s;
  return 0;
 25c:	4501                	li	a0,0
}
 25e:	6422                	ld	s0,8(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
  return 0;
 264:	4501                	li	a0,0
 266:	bfe5                	j	25e <strchr+0x1a>

0000000000000268 <gets>:

char*
gets(char *buf, int max)
{
 268:	711d                	addi	sp,sp,-96
 26a:	ec86                	sd	ra,88(sp)
 26c:	e8a2                	sd	s0,80(sp)
 26e:	e4a6                	sd	s1,72(sp)
 270:	e0ca                	sd	s2,64(sp)
 272:	fc4e                	sd	s3,56(sp)
 274:	f852                	sd	s4,48(sp)
 276:	f456                	sd	s5,40(sp)
 278:	f05a                	sd	s6,32(sp)
 27a:	ec5e                	sd	s7,24(sp)
 27c:	1080                	addi	s0,sp,96
 27e:	8baa                	mv	s7,a0
 280:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 282:	892a                	mv	s2,a0
 284:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 286:	4aa9                	li	s5,10
 288:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 28a:	89a6                	mv	s3,s1
 28c:	2485                	addiw	s1,s1,1
 28e:	0344d663          	bge	s1,s4,2ba <gets+0x52>
    cc = read(0, &c, 1);
 292:	4605                	li	a2,1
 294:	faf40593          	addi	a1,s0,-81
 298:	4501                	li	a0,0
 29a:	1b2000ef          	jal	44c <read>
    if(cc < 1)
 29e:	00a05e63          	blez	a0,2ba <gets+0x52>
    buf[i++] = c;
 2a2:	faf44783          	lbu	a5,-81(s0)
 2a6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2aa:	01578763          	beq	a5,s5,2b8 <gets+0x50>
 2ae:	0905                	addi	s2,s2,1
 2b0:	fd679de3          	bne	a5,s6,28a <gets+0x22>
    buf[i++] = c;
 2b4:	89a6                	mv	s3,s1
 2b6:	a011                	j	2ba <gets+0x52>
 2b8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ba:	99de                	add	s3,s3,s7
 2bc:	00098023          	sb	zero,0(s3)
  return buf;
}
 2c0:	855e                	mv	a0,s7
 2c2:	60e6                	ld	ra,88(sp)
 2c4:	6446                	ld	s0,80(sp)
 2c6:	64a6                	ld	s1,72(sp)
 2c8:	6906                	ld	s2,64(sp)
 2ca:	79e2                	ld	s3,56(sp)
 2cc:	7a42                	ld	s4,48(sp)
 2ce:	7aa2                	ld	s5,40(sp)
 2d0:	7b02                	ld	s6,32(sp)
 2d2:	6be2                	ld	s7,24(sp)
 2d4:	6125                	addi	sp,sp,96
 2d6:	8082                	ret

00000000000002d8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d8:	1101                	addi	sp,sp,-32
 2da:	ec06                	sd	ra,24(sp)
 2dc:	e822                	sd	s0,16(sp)
 2de:	e04a                	sd	s2,0(sp)
 2e0:	1000                	addi	s0,sp,32
 2e2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e4:	4581                	li	a1,0
 2e6:	18e000ef          	jal	474 <open>
  if(fd < 0)
 2ea:	02054263          	bltz	a0,30e <stat+0x36>
 2ee:	e426                	sd	s1,8(sp)
 2f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2f2:	85ca                	mv	a1,s2
 2f4:	198000ef          	jal	48c <fstat>
 2f8:	892a                	mv	s2,a0
  close(fd);
 2fa:	8526                	mv	a0,s1
 2fc:	160000ef          	jal	45c <close>
  return r;
 300:	64a2                	ld	s1,8(sp)
}
 302:	854a                	mv	a0,s2
 304:	60e2                	ld	ra,24(sp)
 306:	6442                	ld	s0,16(sp)
 308:	6902                	ld	s2,0(sp)
 30a:	6105                	addi	sp,sp,32
 30c:	8082                	ret
    return -1;
 30e:	597d                	li	s2,-1
 310:	bfcd                	j	302 <stat+0x2a>

0000000000000312 <atoi>:

int
atoi(const char *s)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 318:	00054683          	lbu	a3,0(a0)
 31c:	fd06879b          	addiw	a5,a3,-48
 320:	0ff7f793          	zext.b	a5,a5
 324:	4625                	li	a2,9
 326:	02f66863          	bltu	a2,a5,356 <atoi+0x44>
 32a:	872a                	mv	a4,a0
  n = 0;
 32c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 32e:	0705                	addi	a4,a4,1
 330:	0025179b          	slliw	a5,a0,0x2
 334:	9fa9                	addw	a5,a5,a0
 336:	0017979b          	slliw	a5,a5,0x1
 33a:	9fb5                	addw	a5,a5,a3
 33c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 340:	00074683          	lbu	a3,0(a4)
 344:	fd06879b          	addiw	a5,a3,-48
 348:	0ff7f793          	zext.b	a5,a5
 34c:	fef671e3          	bgeu	a2,a5,32e <atoi+0x1c>
  return n;
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
  n = 0;
 356:	4501                	li	a0,0
 358:	bfe5                	j	350 <atoi+0x3e>

000000000000035a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 360:	02b57463          	bgeu	a0,a1,388 <memmove+0x2e>
    while(n-- > 0)
 364:	00c05f63          	blez	a2,382 <memmove+0x28>
 368:	1602                	slli	a2,a2,0x20
 36a:	9201                	srli	a2,a2,0x20
 36c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 370:	872a                	mv	a4,a0
      *dst++ = *src++;
 372:	0585                	addi	a1,a1,1
 374:	0705                	addi	a4,a4,1
 376:	fff5c683          	lbu	a3,-1(a1)
 37a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 37e:	fef71ae3          	bne	a4,a5,372 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret
    dst += n;
 388:	00c50733          	add	a4,a0,a2
    src += n;
 38c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 38e:	fec05ae3          	blez	a2,382 <memmove+0x28>
 392:	fff6079b          	addiw	a5,a2,-1
 396:	1782                	slli	a5,a5,0x20
 398:	9381                	srli	a5,a5,0x20
 39a:	fff7c793          	not	a5,a5
 39e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a0:	15fd                	addi	a1,a1,-1
 3a2:	177d                	addi	a4,a4,-1
 3a4:	0005c683          	lbu	a3,0(a1)
 3a8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ac:	fee79ae3          	bne	a5,a4,3a0 <memmove+0x46>
 3b0:	bfc9                	j	382 <memmove+0x28>

00000000000003b2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e422                	sd	s0,8(sp)
 3b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b8:	ca05                	beqz	a2,3e8 <memcmp+0x36>
 3ba:	fff6069b          	addiw	a3,a2,-1
 3be:	1682                	slli	a3,a3,0x20
 3c0:	9281                	srli	a3,a3,0x20
 3c2:	0685                	addi	a3,a3,1
 3c4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c6:	00054783          	lbu	a5,0(a0)
 3ca:	0005c703          	lbu	a4,0(a1)
 3ce:	00e79863          	bne	a5,a4,3de <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d2:	0505                	addi	a0,a0,1
    p2++;
 3d4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d6:	fed518e3          	bne	a0,a3,3c6 <memcmp+0x14>
  }
  return 0;
 3da:	4501                	li	a0,0
 3dc:	a019                	j	3e2 <memcmp+0x30>
      return *p1 - *p2;
 3de:	40e7853b          	subw	a0,a5,a4
}
 3e2:	6422                	ld	s0,8(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret
  return 0;
 3e8:	4501                	li	a0,0
 3ea:	bfe5                	j	3e2 <memcmp+0x30>

00000000000003ec <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e406                	sd	ra,8(sp)
 3f0:	e022                	sd	s0,0(sp)
 3f2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f4:	f67ff0ef          	jal	35a <memmove>
}
 3f8:	60a2                	ld	ra,8(sp)
 3fa:	6402                	ld	s0,0(sp)
 3fc:	0141                	addi	sp,sp,16
 3fe:	8082                	ret

0000000000000400 <sbrk>:

char *
sbrk(int n) {
 400:	1141                	addi	sp,sp,-16
 402:	e406                	sd	ra,8(sp)
 404:	e022                	sd	s0,0(sp)
 406:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 408:	4585                	li	a1,1
 40a:	0b2000ef          	jal	4bc <sys_sbrk>
}
 40e:	60a2                	ld	ra,8(sp)
 410:	6402                	ld	s0,0(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret

0000000000000416 <sbrklazy>:

char *
sbrklazy(int n) {
 416:	1141                	addi	sp,sp,-16
 418:	e406                	sd	ra,8(sp)
 41a:	e022                	sd	s0,0(sp)
 41c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 41e:	4589                	li	a1,2
 420:	09c000ef          	jal	4bc <sys_sbrk>
}
 424:	60a2                	ld	ra,8(sp)
 426:	6402                	ld	s0,0(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret

000000000000042c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 42c:	4885                	li	a7,1
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <exit>:
.global exit
exit:
 li a7, SYS_exit
 434:	4889                	li	a7,2
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <wait>:
.global wait
wait:
 li a7, SYS_wait
 43c:	488d                	li	a7,3
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 444:	4891                	li	a7,4
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <read>:
.global read
read:
 li a7, SYS_read
 44c:	4895                	li	a7,5
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <write>:
.global write
write:
 li a7, SYS_write
 454:	48c1                	li	a7,16
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <close>:
.global close
close:
 li a7, SYS_close
 45c:	48d5                	li	a7,21
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <kill>:
.global kill
kill:
 li a7, SYS_kill
 464:	4899                	li	a7,6
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <exec>:
.global exec
exec:
 li a7, SYS_exec
 46c:	489d                	li	a7,7
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <open>:
.global open
open:
 li a7, SYS_open
 474:	48bd                	li	a7,15
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 47c:	48c5                	li	a7,17
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 484:	48c9                	li	a7,18
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 48c:	48a1                	li	a7,8
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <link>:
.global link
link:
 li a7, SYS_link
 494:	48cd                	li	a7,19
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 49c:	48d1                	li	a7,20
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a4:	48a5                	li	a7,9
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ac:	48a9                	li	a7,10
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b4:	48ad                	li	a7,11
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4bc:	48b1                	li	a7,12
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4c4:	48b5                	li	a7,13
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4cc:	48b9                	li	a7,14
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4d4:	48d9                	li	a7,22
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4dc:	48dd                	li	a7,23
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4e4:	1101                	addi	sp,sp,-32
 4e6:	ec06                	sd	ra,24(sp)
 4e8:	e822                	sd	s0,16(sp)
 4ea:	1000                	addi	s0,sp,32
 4ec:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4f0:	4605                	li	a2,1
 4f2:	fef40593          	addi	a1,s0,-17
 4f6:	f5fff0ef          	jal	454 <write>
}
 4fa:	60e2                	ld	ra,24(sp)
 4fc:	6442                	ld	s0,16(sp)
 4fe:	6105                	addi	sp,sp,32
 500:	8082                	ret

0000000000000502 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 502:	715d                	addi	sp,sp,-80
 504:	e486                	sd	ra,72(sp)
 506:	e0a2                	sd	s0,64(sp)
 508:	f84a                	sd	s2,48(sp)
 50a:	0880                	addi	s0,sp,80
 50c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 50e:	c299                	beqz	a3,514 <printint+0x12>
 510:	0805c363          	bltz	a1,596 <printint+0x94>
  neg = 0;
 514:	4881                	li	a7,0
 516:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 51a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 51c:	00001517          	auipc	a0,0x1
 520:	82450513          	addi	a0,a0,-2012 # d40 <digits>
 524:	883e                	mv	a6,a5
 526:	2785                	addiw	a5,a5,1
 528:	02c5f733          	remu	a4,a1,a2
 52c:	972a                	add	a4,a4,a0
 52e:	00074703          	lbu	a4,0(a4)
 532:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 536:	872e                	mv	a4,a1
 538:	02c5d5b3          	divu	a1,a1,a2
 53c:	0685                	addi	a3,a3,1
 53e:	fec773e3          	bgeu	a4,a2,524 <printint+0x22>
  if(neg)
 542:	00088b63          	beqz	a7,558 <printint+0x56>
    buf[i++] = '-';
 546:	fd078793          	addi	a5,a5,-48
 54a:	97a2                	add	a5,a5,s0
 54c:	02d00713          	li	a4,45
 550:	fee78423          	sb	a4,-24(a5)
 554:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 558:	02f05a63          	blez	a5,58c <printint+0x8a>
 55c:	fc26                	sd	s1,56(sp)
 55e:	f44e                	sd	s3,40(sp)
 560:	fb840713          	addi	a4,s0,-72
 564:	00f704b3          	add	s1,a4,a5
 568:	fff70993          	addi	s3,a4,-1
 56c:	99be                	add	s3,s3,a5
 56e:	37fd                	addiw	a5,a5,-1
 570:	1782                	slli	a5,a5,0x20
 572:	9381                	srli	a5,a5,0x20
 574:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 578:	fff4c583          	lbu	a1,-1(s1)
 57c:	854a                	mv	a0,s2
 57e:	f67ff0ef          	jal	4e4 <putc>
  while(--i >= 0)
 582:	14fd                	addi	s1,s1,-1
 584:	ff349ae3          	bne	s1,s3,578 <printint+0x76>
 588:	74e2                	ld	s1,56(sp)
 58a:	79a2                	ld	s3,40(sp)
}
 58c:	60a6                	ld	ra,72(sp)
 58e:	6406                	ld	s0,64(sp)
 590:	7942                	ld	s2,48(sp)
 592:	6161                	addi	sp,sp,80
 594:	8082                	ret
    x = -xx;
 596:	40b005b3          	neg	a1,a1
    neg = 1;
 59a:	4885                	li	a7,1
    x = -xx;
 59c:	bfad                	j	516 <printint+0x14>

000000000000059e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 59e:	711d                	addi	sp,sp,-96
 5a0:	ec86                	sd	ra,88(sp)
 5a2:	e8a2                	sd	s0,80(sp)
 5a4:	e0ca                	sd	s2,64(sp)
 5a6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a8:	0005c903          	lbu	s2,0(a1)
 5ac:	28090663          	beqz	s2,838 <vprintf+0x29a>
 5b0:	e4a6                	sd	s1,72(sp)
 5b2:	fc4e                	sd	s3,56(sp)
 5b4:	f852                	sd	s4,48(sp)
 5b6:	f456                	sd	s5,40(sp)
 5b8:	f05a                	sd	s6,32(sp)
 5ba:	ec5e                	sd	s7,24(sp)
 5bc:	e862                	sd	s8,16(sp)
 5be:	e466                	sd	s9,8(sp)
 5c0:	8b2a                	mv	s6,a0
 5c2:	8a2e                	mv	s4,a1
 5c4:	8bb2                	mv	s7,a2
  state = 0;
 5c6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c8:	4481                	li	s1,0
 5ca:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5cc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5d4:	06c00c93          	li	s9,108
 5d8:	a005                	j	5f8 <vprintf+0x5a>
        putc(fd, c0);
 5da:	85ca                	mv	a1,s2
 5dc:	855a                	mv	a0,s6
 5de:	f07ff0ef          	jal	4e4 <putc>
 5e2:	a019                	j	5e8 <vprintf+0x4a>
    } else if(state == '%'){
 5e4:	03598263          	beq	s3,s5,608 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5e8:	2485                	addiw	s1,s1,1
 5ea:	8726                	mv	a4,s1
 5ec:	009a07b3          	add	a5,s4,s1
 5f0:	0007c903          	lbu	s2,0(a5)
 5f4:	22090a63          	beqz	s2,828 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5f8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5fc:	fe0994e3          	bnez	s3,5e4 <vprintf+0x46>
      if(c0 == '%'){
 600:	fd579de3          	bne	a5,s5,5da <vprintf+0x3c>
        state = '%';
 604:	89be                	mv	s3,a5
 606:	b7cd                	j	5e8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 608:	00ea06b3          	add	a3,s4,a4
 60c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 610:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 612:	c681                	beqz	a3,61a <vprintf+0x7c>
 614:	9752                	add	a4,a4,s4
 616:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 61a:	05878363          	beq	a5,s8,660 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 61e:	05978d63          	beq	a5,s9,678 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 622:	07500713          	li	a4,117
 626:	0ee78763          	beq	a5,a4,714 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 62a:	07800713          	li	a4,120
 62e:	12e78963          	beq	a5,a4,760 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 632:	07000713          	li	a4,112
 636:	14e78e63          	beq	a5,a4,792 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 63a:	06300713          	li	a4,99
 63e:	18e78e63          	beq	a5,a4,7da <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 642:	07300713          	li	a4,115
 646:	1ae78463          	beq	a5,a4,7ee <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 64a:	02500713          	li	a4,37
 64e:	04e79563          	bne	a5,a4,698 <vprintf+0xfa>
        putc(fd, '%');
 652:	02500593          	li	a1,37
 656:	855a                	mv	a0,s6
 658:	e8dff0ef          	jal	4e4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 65c:	4981                	li	s3,0
 65e:	b769                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 660:	008b8913          	addi	s2,s7,8
 664:	4685                	li	a3,1
 666:	4629                	li	a2,10
 668:	000ba583          	lw	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	e95ff0ef          	jal	502 <printint>
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
 676:	bf8d                	j	5e8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 678:	06400793          	li	a5,100
 67c:	02f68963          	beq	a3,a5,6ae <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 680:	06c00793          	li	a5,108
 684:	04f68263          	beq	a3,a5,6c8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 688:	07500793          	li	a5,117
 68c:	0af68063          	beq	a3,a5,72c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 690:	07800793          	li	a5,120
 694:	0ef68263          	beq	a3,a5,778 <vprintf+0x1da>
        putc(fd, '%');
 698:	02500593          	li	a1,37
 69c:	855a                	mv	a0,s6
 69e:	e47ff0ef          	jal	4e4 <putc>
        putc(fd, c0);
 6a2:	85ca                	mv	a1,s2
 6a4:	855a                	mv	a0,s6
 6a6:	e3fff0ef          	jal	4e4 <putc>
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	bf35                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4685                	li	a3,1
 6b4:	4629                	li	a2,10
 6b6:	000bb583          	ld	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	e47ff0ef          	jal	502 <printint>
        i += 1;
 6c0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
        i += 1;
 6c6:	b70d                	j	5e8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c8:	06400793          	li	a5,100
 6cc:	02f60763          	beq	a2,a5,6fa <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6d0:	07500793          	li	a5,117
 6d4:	06f60963          	beq	a2,a5,746 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6d8:	07800793          	li	a5,120
 6dc:	faf61ee3          	bne	a2,a5,698 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4641                	li	a2,16
 6e8:	000bb583          	ld	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	e15ff0ef          	jal	502 <printint>
        i += 2;
 6f2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 2;
 6f8:	bdc5                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4685                	li	a3,1
 700:	4629                	li	a2,10
 702:	000bb583          	ld	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	dfbff0ef          	jal	502 <printint>
        i += 2;
 70c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
        i += 2;
 712:	bdd9                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 714:	008b8913          	addi	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4629                	li	a2,10
 71c:	000be583          	lwu	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	de1ff0ef          	jal	502 <printint>
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	bd7d                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 72c:	008b8913          	addi	s2,s7,8
 730:	4681                	li	a3,0
 732:	4629                	li	a2,10
 734:	000bb583          	ld	a1,0(s7)
 738:	855a                	mv	a0,s6
 73a:	dc9ff0ef          	jal	502 <printint>
        i += 1;
 73e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 740:	8bca                	mv	s7,s2
      state = 0;
 742:	4981                	li	s3,0
        i += 1;
 744:	b555                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 746:	008b8913          	addi	s2,s7,8
 74a:	4681                	li	a3,0
 74c:	4629                	li	a2,10
 74e:	000bb583          	ld	a1,0(s7)
 752:	855a                	mv	a0,s6
 754:	dafff0ef          	jal	502 <printint>
        i += 2;
 758:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 75a:	8bca                	mv	s7,s2
      state = 0;
 75c:	4981                	li	s3,0
        i += 2;
 75e:	b569                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 760:	008b8913          	addi	s2,s7,8
 764:	4681                	li	a3,0
 766:	4641                	li	a2,16
 768:	000be583          	lwu	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	d95ff0ef          	jal	502 <printint>
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	bd8d                	j	5e8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 778:	008b8913          	addi	s2,s7,8
 77c:	4681                	li	a3,0
 77e:	4641                	li	a2,16
 780:	000bb583          	ld	a1,0(s7)
 784:	855a                	mv	a0,s6
 786:	d7dff0ef          	jal	502 <printint>
        i += 1;
 78a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 78c:	8bca                	mv	s7,s2
      state = 0;
 78e:	4981                	li	s3,0
        i += 1;
 790:	bda1                	j	5e8 <vprintf+0x4a>
 792:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 794:	008b8d13          	addi	s10,s7,8
 798:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 79c:	03000593          	li	a1,48
 7a0:	855a                	mv	a0,s6
 7a2:	d43ff0ef          	jal	4e4 <putc>
  putc(fd, 'x');
 7a6:	07800593          	li	a1,120
 7aa:	855a                	mv	a0,s6
 7ac:	d39ff0ef          	jal	4e4 <putc>
 7b0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7b2:	00000b97          	auipc	s7,0x0
 7b6:	58eb8b93          	addi	s7,s7,1422 # d40 <digits>
 7ba:	03c9d793          	srli	a5,s3,0x3c
 7be:	97de                	add	a5,a5,s7
 7c0:	0007c583          	lbu	a1,0(a5)
 7c4:	855a                	mv	a0,s6
 7c6:	d1fff0ef          	jal	4e4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ca:	0992                	slli	s3,s3,0x4
 7cc:	397d                	addiw	s2,s2,-1
 7ce:	fe0916e3          	bnez	s2,7ba <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7d2:	8bea                	mv	s7,s10
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	6d02                	ld	s10,0(sp)
 7d8:	bd01                	j	5e8 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7da:	008b8913          	addi	s2,s7,8
 7de:	000bc583          	lbu	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	d01ff0ef          	jal	4e4 <putc>
 7e8:	8bca                	mv	s7,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bbf5                	j	5e8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7ee:	008b8993          	addi	s3,s7,8
 7f2:	000bb903          	ld	s2,0(s7)
 7f6:	00090f63          	beqz	s2,814 <vprintf+0x276>
        for(; *s; s++)
 7fa:	00094583          	lbu	a1,0(s2)
 7fe:	c195                	beqz	a1,822 <vprintf+0x284>
          putc(fd, *s);
 800:	855a                	mv	a0,s6
 802:	ce3ff0ef          	jal	4e4 <putc>
        for(; *s; s++)
 806:	0905                	addi	s2,s2,1
 808:	00094583          	lbu	a1,0(s2)
 80c:	f9f5                	bnez	a1,800 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 80e:	8bce                	mv	s7,s3
      state = 0;
 810:	4981                	li	s3,0
 812:	bbd9                	j	5e8 <vprintf+0x4a>
          s = "(null)";
 814:	00000917          	auipc	s2,0x0
 818:	52490913          	addi	s2,s2,1316 # d38 <malloc+0x418>
        for(; *s; s++)
 81c:	02800593          	li	a1,40
 820:	b7c5                	j	800 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 822:	8bce                	mv	s7,s3
      state = 0;
 824:	4981                	li	s3,0
 826:	b3c9                	j	5e8 <vprintf+0x4a>
 828:	64a6                	ld	s1,72(sp)
 82a:	79e2                	ld	s3,56(sp)
 82c:	7a42                	ld	s4,48(sp)
 82e:	7aa2                	ld	s5,40(sp)
 830:	7b02                	ld	s6,32(sp)
 832:	6be2                	ld	s7,24(sp)
 834:	6c42                	ld	s8,16(sp)
 836:	6ca2                	ld	s9,8(sp)
    }
  }
}
 838:	60e6                	ld	ra,88(sp)
 83a:	6446                	ld	s0,80(sp)
 83c:	6906                	ld	s2,64(sp)
 83e:	6125                	addi	sp,sp,96
 840:	8082                	ret

0000000000000842 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 842:	715d                	addi	sp,sp,-80
 844:	ec06                	sd	ra,24(sp)
 846:	e822                	sd	s0,16(sp)
 848:	1000                	addi	s0,sp,32
 84a:	e010                	sd	a2,0(s0)
 84c:	e414                	sd	a3,8(s0)
 84e:	e818                	sd	a4,16(s0)
 850:	ec1c                	sd	a5,24(s0)
 852:	03043023          	sd	a6,32(s0)
 856:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 85a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 85e:	8622                	mv	a2,s0
 860:	d3fff0ef          	jal	59e <vprintf>
}
 864:	60e2                	ld	ra,24(sp)
 866:	6442                	ld	s0,16(sp)
 868:	6161                	addi	sp,sp,80
 86a:	8082                	ret

000000000000086c <printf>:

void
printf(const char *fmt, ...)
{
 86c:	711d                	addi	sp,sp,-96
 86e:	ec06                	sd	ra,24(sp)
 870:	e822                	sd	s0,16(sp)
 872:	1000                	addi	s0,sp,32
 874:	e40c                	sd	a1,8(s0)
 876:	e810                	sd	a2,16(s0)
 878:	ec14                	sd	a3,24(s0)
 87a:	f018                	sd	a4,32(s0)
 87c:	f41c                	sd	a5,40(s0)
 87e:	03043823          	sd	a6,48(s0)
 882:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 886:	00840613          	addi	a2,s0,8
 88a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 88e:	85aa                	mv	a1,a0
 890:	4505                	li	a0,1
 892:	d0dff0ef          	jal	59e <vprintf>
}
 896:	60e2                	ld	ra,24(sp)
 898:	6442                	ld	s0,16(sp)
 89a:	6125                	addi	sp,sp,96
 89c:	8082                	ret

000000000000089e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 89e:	1141                	addi	sp,sp,-16
 8a0:	e422                	sd	s0,8(sp)
 8a2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a8:	00001797          	auipc	a5,0x1
 8ac:	7587b783          	ld	a5,1880(a5) # 2000 <freep>
 8b0:	a02d                	j	8da <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8b2:	4618                	lw	a4,8(a2)
 8b4:	9f2d                	addw	a4,a4,a1
 8b6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ba:	6398                	ld	a4,0(a5)
 8bc:	6310                	ld	a2,0(a4)
 8be:	a83d                	j	8fc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8c0:	ff852703          	lw	a4,-8(a0)
 8c4:	9f31                	addw	a4,a4,a2
 8c6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8c8:	ff053683          	ld	a3,-16(a0)
 8cc:	a091                	j	910 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ce:	6398                	ld	a4,0(a5)
 8d0:	00e7e463          	bltu	a5,a4,8d8 <free+0x3a>
 8d4:	00e6ea63          	bltu	a3,a4,8e8 <free+0x4a>
{
 8d8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8da:	fed7fae3          	bgeu	a5,a3,8ce <free+0x30>
 8de:	6398                	ld	a4,0(a5)
 8e0:	00e6e463          	bltu	a3,a4,8e8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e4:	fee7eae3          	bltu	a5,a4,8d8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8e8:	ff852583          	lw	a1,-8(a0)
 8ec:	6390                	ld	a2,0(a5)
 8ee:	02059813          	slli	a6,a1,0x20
 8f2:	01c85713          	srli	a4,a6,0x1c
 8f6:	9736                	add	a4,a4,a3
 8f8:	fae60de3          	beq	a2,a4,8b2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8fc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 900:	4790                	lw	a2,8(a5)
 902:	02061593          	slli	a1,a2,0x20
 906:	01c5d713          	srli	a4,a1,0x1c
 90a:	973e                	add	a4,a4,a5
 90c:	fae68ae3          	beq	a3,a4,8c0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 910:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 912:	00001717          	auipc	a4,0x1
 916:	6ef73723          	sd	a5,1774(a4) # 2000 <freep>
}
 91a:	6422                	ld	s0,8(sp)
 91c:	0141                	addi	sp,sp,16
 91e:	8082                	ret

0000000000000920 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 920:	7139                	addi	sp,sp,-64
 922:	fc06                	sd	ra,56(sp)
 924:	f822                	sd	s0,48(sp)
 926:	f426                	sd	s1,40(sp)
 928:	ec4e                	sd	s3,24(sp)
 92a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92c:	02051493          	slli	s1,a0,0x20
 930:	9081                	srli	s1,s1,0x20
 932:	04bd                	addi	s1,s1,15
 934:	8091                	srli	s1,s1,0x4
 936:	0014899b          	addiw	s3,s1,1
 93a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 93c:	00001517          	auipc	a0,0x1
 940:	6c453503          	ld	a0,1732(a0) # 2000 <freep>
 944:	c915                	beqz	a0,978 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 948:	4798                	lw	a4,8(a5)
 94a:	08977a63          	bgeu	a4,s1,9de <malloc+0xbe>
 94e:	f04a                	sd	s2,32(sp)
 950:	e852                	sd	s4,16(sp)
 952:	e456                	sd	s5,8(sp)
 954:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 956:	8a4e                	mv	s4,s3
 958:	0009871b          	sext.w	a4,s3
 95c:	6685                	lui	a3,0x1
 95e:	00d77363          	bgeu	a4,a3,964 <malloc+0x44>
 962:	6a05                	lui	s4,0x1
 964:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 968:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 96c:	00001917          	auipc	s2,0x1
 970:	69490913          	addi	s2,s2,1684 # 2000 <freep>
  if(p == SBRK_ERROR)
 974:	5afd                	li	s5,-1
 976:	a081                	j	9b6 <malloc+0x96>
 978:	f04a                	sd	s2,32(sp)
 97a:	e852                	sd	s4,16(sp)
 97c:	e456                	sd	s5,8(sp)
 97e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 980:	00001797          	auipc	a5,0x1
 984:	69078793          	addi	a5,a5,1680 # 2010 <base>
 988:	00001717          	auipc	a4,0x1
 98c:	66f73c23          	sd	a5,1656(a4) # 2000 <freep>
 990:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 992:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 996:	b7c1                	j	956 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 998:	6398                	ld	a4,0(a5)
 99a:	e118                	sd	a4,0(a0)
 99c:	a8a9                	j	9f6 <malloc+0xd6>
  hp->s.size = nu;
 99e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9a2:	0541                	addi	a0,a0,16
 9a4:	efbff0ef          	jal	89e <free>
  return freep;
 9a8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ac:	c12d                	beqz	a0,a0e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b0:	4798                	lw	a4,8(a5)
 9b2:	02977263          	bgeu	a4,s1,9d6 <malloc+0xb6>
    if(p == freep)
 9b6:	00093703          	ld	a4,0(s2)
 9ba:	853e                	mv	a0,a5
 9bc:	fef719e3          	bne	a4,a5,9ae <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9c0:	8552                	mv	a0,s4
 9c2:	a3fff0ef          	jal	400 <sbrk>
  if(p == SBRK_ERROR)
 9c6:	fd551ce3          	bne	a0,s5,99e <malloc+0x7e>
        return 0;
 9ca:	4501                	li	a0,0
 9cc:	7902                	ld	s2,32(sp)
 9ce:	6a42                	ld	s4,16(sp)
 9d0:	6aa2                	ld	s5,8(sp)
 9d2:	6b02                	ld	s6,0(sp)
 9d4:	a03d                	j	a02 <malloc+0xe2>
 9d6:	7902                	ld	s2,32(sp)
 9d8:	6a42                	ld	s4,16(sp)
 9da:	6aa2                	ld	s5,8(sp)
 9dc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9de:	fae48de3          	beq	s1,a4,998 <malloc+0x78>
        p->s.size -= nunits;
 9e2:	4137073b          	subw	a4,a4,s3
 9e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9e8:	02071693          	slli	a3,a4,0x20
 9ec:	01c6d713          	srli	a4,a3,0x1c
 9f0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9f2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9f6:	00001717          	auipc	a4,0x1
 9fa:	60a73523          	sd	a0,1546(a4) # 2000 <freep>
      return (void*)(p + 1);
 9fe:	01078513          	addi	a0,a5,16
  }
}
 a02:	70e2                	ld	ra,56(sp)
 a04:	7442                	ld	s0,48(sp)
 a06:	74a2                	ld	s1,40(sp)
 a08:	69e2                	ld	s3,24(sp)
 a0a:	6121                	addi	sp,sp,64
 a0c:	8082                	ret
 a0e:	7902                	ld	s2,32(sp)
 a10:	6a42                	ld	s4,16(sp)
 a12:	6aa2                	ld	s5,8(sp)
 a14:	6b02                	ld	s6,0(sp)
 a16:	b7f5                	j	a02 <malloc+0xe2>
