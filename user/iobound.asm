
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
  14:	1880                	addi	s0,sp,112
  struct procinfo info;
  int iter;
  
  printf("=== Comprehensive I/O-Bound Test ===\n");
  16:	00001517          	auipc	a0,0x1
  1a:	a3a50513          	addi	a0,a0,-1478 # a50 <malloc+0xfc>
  1e:	07f000ef          	jal	89c <printf>
  printf("This process will alternate between brief work and sleep.\n");
  22:	00001517          	auipc	a0,0x1
  26:	a5e50513          	addi	a0,a0,-1442 # a80 <malloc+0x12c>
  2a:	073000ef          	jal	89c <printf>
  printf("It should STAY in Q0 (never demote) because it yields frequently.\n\n");
  2e:	00001517          	auipc	a0,0x1
  32:	a9250513          	addi	a0,a0,-1390 # ac0 <malloc+0x16c>
  36:	067000ef          	jal	89c <printf>
  
  if(getprocinfo(&info) == 0) {
  3a:	fa040513          	addi	a0,s0,-96
  3e:	4a8000ef          	jal	4e6 <getprocinfo>
  42:	cd1d                	beqz	a0,80 <main+0x80>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
           info.pid, info.priority, info.time_slices);
  }
  
  printf("Running 30 iterations of: brief_work() -> sleep(1_tick)\n");
  44:	00001517          	auipc	a0,0x1
  48:	af450513          	addi	a0,a0,-1292 # b38 <malloc+0x1e4>
  4c:	051000ef          	jal	89c <printf>
  printf("Expected: Priority stays Q0 throughout (slices reset after sleep)\n\n");
  50:	00001517          	auipc	a0,0x1
  54:	b2850513          	addi	a0,a0,-1240 # b78 <malloc+0x224>
  58:	045000ef          	jal	89c <printf>
  
  // Simulate I/O-bound behavior: short bursts with frequent sleeps
  // 30 iterations × 1 second per iteration = ~30 seconds total
  for(iter = 0; iter < 30; iter++) {
  5c:	4901                	li	s2,0
    // Do minimal work (much less than 2 ticks - the Q0 quantum)
    volatile int dummy = 0;
    for(long j = 0; j < 2000000; j++) {  // Small computation
  5e:	001e84b7          	lui	s1,0x1e8
  62:	48048493          	addi	s1,s1,1152 # 1e8480 <base+0x1e7470>
      dummy = dummy + j;
    }
    
    // Sleep (simulating I/O wait) - voluntarily yields
    // This is the KEY behavior: yields before exhausting quantum
    pause(1);  // Sleep for 1 tick (~100ms)
  66:	4b05                	li	s6,1
    
    // Check priority after wakeup
    if(getprocinfo(&info) == 0) {
  68:	fa040993          	addi	s3,s0,-96
      if(iter % 5 == 0) {  // Print every 5 iterations to reduce clutter
  6c:	66666a37          	lui	s4,0x66666
  70:	667a0a13          	addi	s4,s4,1639 # 66666667 <base+0x66665657>
  74:	4af5                	li	s5,29
  76:	20100bb7          	lui	s7,0x20100
  7a:	400b8b93          	addi	s7,s7,1024 # 20100400 <base+0x200ff3f0>
  7e:	a835                	j	ba <main+0xba>
    printf("Starting: PID=%d, Priority=Q%d, TimeSlices=%d\n\n", 
  80:	fac42683          	lw	a3,-84(s0)
  84:	fa842603          	lw	a2,-88(s0)
  88:	fa042583          	lw	a1,-96(s0)
  8c:	00001517          	auipc	a0,0x1
  90:	a7c50513          	addi	a0,a0,-1412 # b08 <malloc+0x1b4>
  94:	009000ef          	jal	89c <printf>
  98:	b775                	j	44 <main+0x44>
        printf("Iteration %d: Priority=Q%d, TimeSlices=%d\n", 
  9a:	fac42683          	lw	a3,-84(s0)
  9e:	fa842603          	lw	a2,-88(s0)
  a2:	85ca                	mv	a1,s2
  a4:	00001517          	auipc	a0,0x1
  a8:	b1c50513          	addi	a0,a0,-1252 # bc0 <malloc+0x26c>
  ac:	7f0000ef          	jal	89c <printf>
  b0:	a0a1                	j	f8 <main+0xf8>
  for(iter = 0; iter < 30; iter++) {
  b2:	2905                	addiw	s2,s2,1
  b4:	47f9                	li	a5,30
  b6:	06f90463          	beq	s2,a5,11e <main+0x11e>
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
  d0:	855a                	mv	a0,s6
  d2:	404000ef          	jal	4d6 <pause>
    if(getprocinfo(&info) == 0) {
  d6:	854e                	mv	a0,s3
  d8:	40e000ef          	jal	4e6 <getprocinfo>
      if(iter % 5 == 0) {  // Print every 5 iterations to reduce clutter
  dc:	034907b3          	mul	a5,s2,s4
  e0:	9785                	srai	a5,a5,0x21
  e2:	41f9571b          	sraiw	a4,s2,0x1f
  e6:	9f99                	subw	a5,a5,a4
  e8:	0027971b          	slliw	a4,a5,0x2
  ec:	9fb9                	addw	a5,a5,a4
  ee:	40f907bb          	subw	a5,s2,a5
  f2:	8fc9                	or	a5,a5,a0
  f4:	2781                	sext.w	a5,a5
  f6:	d3d5                	beqz	a5,9a <main+0x9a>
               iter, info.priority, info.time_slices);
      }
    }
    
    // Verify we stay in high priority
    if(iter == 10 || iter == 20 || iter == 29) {
  f8:	092aea63          	bltu	s5,s2,18c <main+0x18c>
  fc:	012bd7b3          	srl	a5,s7,s2
 100:	8b85                	andi	a5,a5,1
 102:	dbc5                	beqz	a5,b2 <main+0xb2>
      if(getprocinfo(&info) == 0) {
 104:	854e                	mv	a0,s3
 106:	3e0000ef          	jal	4e6 <getprocinfo>
 10a:	f545                	bnez	a0,b2 <main+0xb2>
        printf("  [Checkpoint] Still at Q%d\n", info.priority);
 10c:	fa842583          	lw	a1,-88(s0)
 110:	00001517          	auipc	a0,0x1
 114:	ae050513          	addi	a0,a0,-1312 # bf0 <malloc+0x29c>
 118:	784000ef          	jal	89c <printf>
 11c:	bf59                	j	b2 <main+0xb2>
      }
    }
  }
  
  printf("\n");
 11e:	00001517          	auipc	a0,0x1
 122:	af250513          	addi	a0,a0,-1294 # c10 <malloc+0x2bc>
 126:	776000ef          	jal	89c <printf>
  if(getprocinfo(&info) == 0) {
 12a:	fa040513          	addi	a0,s0,-96
 12e:	3b8000ef          	jal	4e6 <getprocinfo>
 132:	c501                	beqz	a0,13a <main+0x13a>
      printf("✗ FAILED: Demoted to Q%d (should have stayed Q0/Q1)\n", info.priority);
      printf("  Sleep/pause may not be properly resetting time slices!\n");
    }
  }
  
  exit(0);
 134:	4501                	li	a0,0
 136:	310000ef          	jal	446 <exit>
    printf("Final Result: Priority=Q%d, TimeSlices=%d\n", 
 13a:	fac42603          	lw	a2,-84(s0)
 13e:	fa842583          	lw	a1,-88(s0)
 142:	00001517          	auipc	a0,0x1
 146:	ad650513          	addi	a0,a0,-1322 # c18 <malloc+0x2c4>
 14a:	752000ef          	jal	89c <printf>
    if(info.priority <= 1) {
 14e:	fa842583          	lw	a1,-88(s0)
 152:	4785                	li	a5,1
 154:	00b7df63          	bge	a5,a1,172 <main+0x172>
      printf("✗ FAILED: Demoted to Q%d (should have stayed Q0/Q1)\n", info.priority);
 158:	00001517          	auipc	a0,0x1
 15c:	b6850513          	addi	a0,a0,-1176 # cc0 <malloc+0x36c>
 160:	73c000ef          	jal	89c <printf>
      printf("  Sleep/pause may not be properly resetting time slices!\n");
 164:	00001517          	auipc	a0,0x1
 168:	b9450513          	addi	a0,a0,-1132 # cf8 <malloc+0x3a4>
 16c:	730000ef          	jal	89c <printf>
 170:	b7d1                	j	134 <main+0x134>
      printf("✓ SUCCESS: Stayed in Q%d (high priority maintained!)\n", info.priority);
 172:	00001517          	auipc	a0,0x1
 176:	ad650513          	addi	a0,a0,-1322 # c48 <malloc+0x2f4>
 17a:	722000ef          	jal	89c <printf>
      printf("  Demonstrates I/O-bound processes get preferential treatment.\n");
 17e:	00001517          	auipc	a0,0x1
 182:	b0250513          	addi	a0,a0,-1278 # c80 <malloc+0x32c>
 186:	716000ef          	jal	89c <printf>
 18a:	b76d                	j	134 <main+0x134>
  for(iter = 0; iter < 30; iter++) {
 18c:	2905                	addiw	s2,s2,1
 18e:	b735                	j	ba <main+0xba>

0000000000000190 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 190:	1141                	addi	sp,sp,-16
 192:	e406                	sd	ra,8(sp)
 194:	e022                	sd	s0,0(sp)
 196:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 198:	e69ff0ef          	jal	0 <main>
  exit(r);
 19c:	2aa000ef          	jal	446 <exit>

00000000000001a0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e406                	sd	ra,8(sp)
 1a4:	e022                	sd	s0,0(sp)
 1a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a8:	87aa                	mv	a5,a0
 1aa:	0585                	addi	a1,a1,1
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff5c703          	lbu	a4,-1(a1)
 1b2:	fee78fa3          	sb	a4,-1(a5)
 1b6:	fb75                	bnez	a4,1aa <strcpy+0xa>
    ;
  return os;
}
 1b8:	60a2                	ld	ra,8(sp)
 1ba:	6402                	ld	s0,0(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e406                	sd	ra,8(sp)
 1c4:	e022                	sd	s0,0(sp)
 1c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	cb91                	beqz	a5,1e0 <strcmp+0x20>
 1ce:	0005c703          	lbu	a4,0(a1)
 1d2:	00f71763          	bne	a4,a5,1e0 <strcmp+0x20>
    p++, q++;
 1d6:	0505                	addi	a0,a0,1
 1d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1da:	00054783          	lbu	a5,0(a0)
 1de:	fbe5                	bnez	a5,1ce <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1e0:	0005c503          	lbu	a0,0(a1)
}
 1e4:	40a7853b          	subw	a0,a5,a0
 1e8:	60a2                	ld	ra,8(sp)
 1ea:	6402                	ld	s0,0(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret

00000000000001f0 <strlen>:

uint
strlen(const char *s)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e406                	sd	ra,8(sp)
 1f4:	e022                	sd	s0,0(sp)
 1f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cf91                	beqz	a5,218 <strlen+0x28>
 1fe:	00150793          	addi	a5,a0,1
 202:	86be                	mv	a3,a5
 204:	0785                	addi	a5,a5,1
 206:	fff7c703          	lbu	a4,-1(a5)
 20a:	ff65                	bnez	a4,202 <strlen+0x12>
 20c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 210:	60a2                	ld	ra,8(sp)
 212:	6402                	ld	s0,0(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
  for(n = 0; s[n]; n++)
 218:	4501                	li	a0,0
 21a:	bfdd                	j	210 <strlen+0x20>

000000000000021c <memset>:

void*
memset(void *dst, int c, uint n)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 224:	ca19                	beqz	a2,23a <memset+0x1e>
 226:	87aa                	mv	a5,a0
 228:	1602                	slli	a2,a2,0x20
 22a:	9201                	srli	a2,a2,0x20
 22c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 230:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 234:	0785                	addi	a5,a5,1
 236:	fee79de3          	bne	a5,a4,230 <memset+0x14>
  }
  return dst;
}
 23a:	60a2                	ld	ra,8(sp)
 23c:	6402                	ld	s0,0(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret

0000000000000242 <strchr>:

char*
strchr(const char *s, char c)
{
 242:	1141                	addi	sp,sp,-16
 244:	e406                	sd	ra,8(sp)
 246:	e022                	sd	s0,0(sp)
 248:	0800                	addi	s0,sp,16
  for(; *s; s++)
 24a:	00054783          	lbu	a5,0(a0)
 24e:	cf81                	beqz	a5,266 <strchr+0x24>
    if(*s == c)
 250:	00f58763          	beq	a1,a5,25e <strchr+0x1c>
  for(; *s; s++)
 254:	0505                	addi	a0,a0,1
 256:	00054783          	lbu	a5,0(a0)
 25a:	fbfd                	bnez	a5,250 <strchr+0xe>
      return (char*)s;
  return 0;
 25c:	4501                	li	a0,0
}
 25e:	60a2                	ld	ra,8(sp)
 260:	6402                	ld	s0,0(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  return 0;
 266:	4501                	li	a0,0
 268:	bfdd                	j	25e <strchr+0x1c>

000000000000026a <gets>:

char*
gets(char *buf, int max)
{
 26a:	711d                	addi	sp,sp,-96
 26c:	ec86                	sd	ra,88(sp)
 26e:	e8a2                	sd	s0,80(sp)
 270:	e4a6                	sd	s1,72(sp)
 272:	e0ca                	sd	s2,64(sp)
 274:	fc4e                	sd	s3,56(sp)
 276:	f852                	sd	s4,48(sp)
 278:	f456                	sd	s5,40(sp)
 27a:	f05a                	sd	s6,32(sp)
 27c:	ec5e                	sd	s7,24(sp)
 27e:	e862                	sd	s8,16(sp)
 280:	1080                	addi	s0,sp,96
 282:	8baa                	mv	s7,a0
 284:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 286:	892a                	mv	s2,a0
 288:	4481                	li	s1,0
    cc = read(0, &c, 1);
 28a:	faf40b13          	addi	s6,s0,-81
 28e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 290:	8c26                	mv	s8,s1
 292:	0014899b          	addiw	s3,s1,1
 296:	84ce                	mv	s1,s3
 298:	0349d463          	bge	s3,s4,2c0 <gets+0x56>
    cc = read(0, &c, 1);
 29c:	8656                	mv	a2,s5
 29e:	85da                	mv	a1,s6
 2a0:	4501                	li	a0,0
 2a2:	1bc000ef          	jal	45e <read>
    if(cc < 1)
 2a6:	00a05d63          	blez	a0,2c0 <gets+0x56>
      break;
    buf[i++] = c;
 2aa:	faf44783          	lbu	a5,-81(s0)
 2ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2b2:	0905                	addi	s2,s2,1
 2b4:	ff678713          	addi	a4,a5,-10
 2b8:	c319                	beqz	a4,2be <gets+0x54>
 2ba:	17cd                	addi	a5,a5,-13
 2bc:	fbf1                	bnez	a5,290 <gets+0x26>
    buf[i++] = c;
 2be:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2c0:	9c5e                	add	s8,s8,s7
 2c2:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2c6:	855e                	mv	a0,s7
 2c8:	60e6                	ld	ra,88(sp)
 2ca:	6446                	ld	s0,80(sp)
 2cc:	64a6                	ld	s1,72(sp)
 2ce:	6906                	ld	s2,64(sp)
 2d0:	79e2                	ld	s3,56(sp)
 2d2:	7a42                	ld	s4,48(sp)
 2d4:	7aa2                	ld	s5,40(sp)
 2d6:	7b02                	ld	s6,32(sp)
 2d8:	6be2                	ld	s7,24(sp)
 2da:	6c42                	ld	s8,16(sp)
 2dc:	6125                	addi	sp,sp,96
 2de:	8082                	ret

00000000000002e0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e0:	1101                	addi	sp,sp,-32
 2e2:	ec06                	sd	ra,24(sp)
 2e4:	e822                	sd	s0,16(sp)
 2e6:	e04a                	sd	s2,0(sp)
 2e8:	1000                	addi	s0,sp,32
 2ea:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ec:	4581                	li	a1,0
 2ee:	198000ef          	jal	486 <open>
  if(fd < 0)
 2f2:	02054263          	bltz	a0,316 <stat+0x36>
 2f6:	e426                	sd	s1,8(sp)
 2f8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2fa:	85ca                	mv	a1,s2
 2fc:	1a2000ef          	jal	49e <fstat>
 300:	892a                	mv	s2,a0
  close(fd);
 302:	8526                	mv	a0,s1
 304:	16a000ef          	jal	46e <close>
  return r;
 308:	64a2                	ld	s1,8(sp)
}
 30a:	854a                	mv	a0,s2
 30c:	60e2                	ld	ra,24(sp)
 30e:	6442                	ld	s0,16(sp)
 310:	6902                	ld	s2,0(sp)
 312:	6105                	addi	sp,sp,32
 314:	8082                	ret
    return -1;
 316:	57fd                	li	a5,-1
 318:	893e                	mv	s2,a5
 31a:	bfc5                	j	30a <stat+0x2a>

000000000000031c <atoi>:

int
atoi(const char *s)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 324:	00054683          	lbu	a3,0(a0)
 328:	fd06879b          	addiw	a5,a3,-48
 32c:	0ff7f793          	zext.b	a5,a5
 330:	4625                	li	a2,9
 332:	02f66963          	bltu	a2,a5,364 <atoi+0x48>
 336:	872a                	mv	a4,a0
  n = 0;
 338:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 33a:	0705                	addi	a4,a4,1
 33c:	0025179b          	slliw	a5,a0,0x2
 340:	9fa9                	addw	a5,a5,a0
 342:	0017979b          	slliw	a5,a5,0x1
 346:	9fb5                	addw	a5,a5,a3
 348:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 34c:	00074683          	lbu	a3,0(a4)
 350:	fd06879b          	addiw	a5,a3,-48
 354:	0ff7f793          	zext.b	a5,a5
 358:	fef671e3          	bgeu	a2,a5,33a <atoi+0x1e>
  return n;
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
  n = 0;
 364:	4501                	li	a0,0
 366:	bfdd                	j	35c <atoi+0x40>

0000000000000368 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 370:	02b57563          	bgeu	a0,a1,39a <memmove+0x32>
    while(n-- > 0)
 374:	00c05f63          	blez	a2,392 <memmove+0x2a>
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
 38e:	fee79ae3          	bne	a5,a4,382 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 392:	60a2                	ld	ra,8(sp)
 394:	6402                	ld	s0,0(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret
    while(n-- > 0)
 39a:	fec05ce3          	blez	a2,392 <memmove+0x2a>
    dst += n;
 39e:	00c50733          	add	a4,a0,a2
    src += n;
 3a2:	95b2                	add	a1,a1,a2
 3a4:	fff6079b          	addiw	a5,a2,-1
 3a8:	1782                	slli	a5,a5,0x20
 3aa:	9381                	srli	a5,a5,0x20
 3ac:	fff7c793          	not	a5,a5
 3b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3b2:	15fd                	addi	a1,a1,-1
 3b4:	177d                	addi	a4,a4,-1
 3b6:	0005c683          	lbu	a3,0(a1)
 3ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3be:	fef71ae3          	bne	a4,a5,3b2 <memmove+0x4a>
 3c2:	bfc1                	j	392 <memmove+0x2a>

00000000000003c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e406                	sd	ra,8(sp)
 3c8:	e022                	sd	s0,0(sp)
 3ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3cc:	c61d                	beqz	a2,3fa <memcmp+0x36>
 3ce:	1602                	slli	a2,a2,0x20
 3d0:	9201                	srli	a2,a2,0x20
 3d2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3d6:	00054783          	lbu	a5,0(a0)
 3da:	0005c703          	lbu	a4,0(a1)
 3de:	00e79863          	bne	a5,a4,3ee <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3e2:	0505                	addi	a0,a0,1
    p2++;
 3e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e6:	fed518e3          	bne	a0,a3,3d6 <memcmp+0x12>
  }
  return 0;
 3ea:	4501                	li	a0,0
 3ec:	a019                	j	3f2 <memcmp+0x2e>
      return *p1 - *p2;
 3ee:	40e7853b          	subw	a0,a5,a4
}
 3f2:	60a2                	ld	ra,8(sp)
 3f4:	6402                	ld	s0,0(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret
  return 0;
 3fa:	4501                	li	a0,0
 3fc:	bfdd                	j	3f2 <memcmp+0x2e>

00000000000003fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e406                	sd	ra,8(sp)
 402:	e022                	sd	s0,0(sp)
 404:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 406:	f63ff0ef          	jal	368 <memmove>
}
 40a:	60a2                	ld	ra,8(sp)
 40c:	6402                	ld	s0,0(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret

0000000000000412 <sbrk>:

char *
sbrk(int n) {
 412:	1141                	addi	sp,sp,-16
 414:	e406                	sd	ra,8(sp)
 416:	e022                	sd	s0,0(sp)
 418:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 41a:	4585                	li	a1,1
 41c:	0b2000ef          	jal	4ce <sys_sbrk>
}
 420:	60a2                	ld	ra,8(sp)
 422:	6402                	ld	s0,0(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret

0000000000000428 <sbrklazy>:

char *
sbrklazy(int n) {
 428:	1141                	addi	sp,sp,-16
 42a:	e406                	sd	ra,8(sp)
 42c:	e022                	sd	s0,0(sp)
 42e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 430:	4589                	li	a1,2
 432:	09c000ef          	jal	4ce <sys_sbrk>
}
 436:	60a2                	ld	ra,8(sp)
 438:	6402                	ld	s0,0(sp)
 43a:	0141                	addi	sp,sp,16
 43c:	8082                	ret

000000000000043e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43e:	4885                	li	a7,1
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <exit>:
.global exit
exit:
 li a7, SYS_exit
 446:	4889                	li	a7,2
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <wait>:
.global wait
wait:
 li a7, SYS_wait
 44e:	488d                	li	a7,3
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 456:	4891                	li	a7,4
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <read>:
.global read
read:
 li a7, SYS_read
 45e:	4895                	li	a7,5
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <write>:
.global write
write:
 li a7, SYS_write
 466:	48c1                	li	a7,16
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <close>:
.global close
close:
 li a7, SYS_close
 46e:	48d5                	li	a7,21
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <kill>:
.global kill
kill:
 li a7, SYS_kill
 476:	4899                	li	a7,6
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <exec>:
.global exec
exec:
 li a7, SYS_exec
 47e:	489d                	li	a7,7
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <open>:
.global open
open:
 li a7, SYS_open
 486:	48bd                	li	a7,15
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48e:	48c5                	li	a7,17
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 496:	48c9                	li	a7,18
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49e:	48a1                	li	a7,8
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <link>:
.global link
link:
 li a7, SYS_link
 4a6:	48cd                	li	a7,19
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ae:	48d1                	li	a7,20
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b6:	48a5                	li	a7,9
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <dup>:
.global dup
dup:
 li a7, SYS_dup
 4be:	48a9                	li	a7,10
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c6:	48ad                	li	a7,11
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4ce:	48b1                	li	a7,12
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4d6:	48b5                	li	a7,13
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4de:	48b9                	li	a7,14
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 4e6:	48d9                	li	a7,22
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 4ee:	48dd                	li	a7,23
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f6:	1101                	addi	sp,sp,-32
 4f8:	ec06                	sd	ra,24(sp)
 4fa:	e822                	sd	s0,16(sp)
 4fc:	1000                	addi	s0,sp,32
 4fe:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 502:	4605                	li	a2,1
 504:	fef40593          	addi	a1,s0,-17
 508:	f5fff0ef          	jal	466 <write>
}
 50c:	60e2                	ld	ra,24(sp)
 50e:	6442                	ld	s0,16(sp)
 510:	6105                	addi	sp,sp,32
 512:	8082                	ret

0000000000000514 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 514:	715d                	addi	sp,sp,-80
 516:	e486                	sd	ra,72(sp)
 518:	e0a2                	sd	s0,64(sp)
 51a:	f84a                	sd	s2,48(sp)
 51c:	f44e                	sd	s3,40(sp)
 51e:	0880                	addi	s0,sp,80
 520:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 522:	c6d1                	beqz	a3,5ae <printint+0x9a>
 524:	0805d563          	bgez	a1,5ae <printint+0x9a>
    neg = 1;
    x = -xx;
 528:	40b005b3          	neg	a1,a1
    neg = 1;
 52c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 52e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 532:	86ce                	mv	a3,s3
  i = 0;
 534:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 536:	00001817          	auipc	a6,0x1
 53a:	80a80813          	addi	a6,a6,-2038 # d40 <digits>
 53e:	88ba                	mv	a7,a4
 540:	0017051b          	addiw	a0,a4,1
 544:	872a                	mv	a4,a0
 546:	02c5f7b3          	remu	a5,a1,a2
 54a:	97c2                	add	a5,a5,a6
 54c:	0007c783          	lbu	a5,0(a5)
 550:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 554:	87ae                	mv	a5,a1
 556:	02c5d5b3          	divu	a1,a1,a2
 55a:	0685                	addi	a3,a3,1
 55c:	fec7f1e3          	bgeu	a5,a2,53e <printint+0x2a>
  if(neg)
 560:	00030c63          	beqz	t1,578 <printint+0x64>
    buf[i++] = '-';
 564:	fd050793          	addi	a5,a0,-48
 568:	00878533          	add	a0,a5,s0
 56c:	02d00793          	li	a5,45
 570:	fef50423          	sb	a5,-24(a0)
 574:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 578:	02e05563          	blez	a4,5a2 <printint+0x8e>
 57c:	fc26                	sd	s1,56(sp)
 57e:	377d                	addiw	a4,a4,-1
 580:	00e984b3          	add	s1,s3,a4
 584:	19fd                	addi	s3,s3,-1
 586:	99ba                	add	s3,s3,a4
 588:	1702                	slli	a4,a4,0x20
 58a:	9301                	srli	a4,a4,0x20
 58c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 590:	0004c583          	lbu	a1,0(s1)
 594:	854a                	mv	a0,s2
 596:	f61ff0ef          	jal	4f6 <putc>
  while(--i >= 0)
 59a:	14fd                	addi	s1,s1,-1
 59c:	ff349ae3          	bne	s1,s3,590 <printint+0x7c>
 5a0:	74e2                	ld	s1,56(sp)
}
 5a2:	60a6                	ld	ra,72(sp)
 5a4:	6406                	ld	s0,64(sp)
 5a6:	7942                	ld	s2,48(sp)
 5a8:	79a2                	ld	s3,40(sp)
 5aa:	6161                	addi	sp,sp,80
 5ac:	8082                	ret
  neg = 0;
 5ae:	4301                	li	t1,0
 5b0:	bfbd                	j	52e <printint+0x1a>

00000000000005b2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5b2:	711d                	addi	sp,sp,-96
 5b4:	ec86                	sd	ra,88(sp)
 5b6:	e8a2                	sd	s0,80(sp)
 5b8:	e4a6                	sd	s1,72(sp)
 5ba:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5bc:	0005c483          	lbu	s1,0(a1)
 5c0:	22048363          	beqz	s1,7e6 <vprintf+0x234>
 5c4:	e0ca                	sd	s2,64(sp)
 5c6:	fc4e                	sd	s3,56(sp)
 5c8:	f852                	sd	s4,48(sp)
 5ca:	f456                	sd	s5,40(sp)
 5cc:	f05a                	sd	s6,32(sp)
 5ce:	ec5e                	sd	s7,24(sp)
 5d0:	e862                	sd	s8,16(sp)
 5d2:	8b2a                	mv	s6,a0
 5d4:	8a2e                	mv	s4,a1
 5d6:	8bb2                	mv	s7,a2
  state = 0;
 5d8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5da:	4901                	li	s2,0
 5dc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5de:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5e2:	06400c13          	li	s8,100
 5e6:	a00d                	j	608 <vprintf+0x56>
        putc(fd, c0);
 5e8:	85a6                	mv	a1,s1
 5ea:	855a                	mv	a0,s6
 5ec:	f0bff0ef          	jal	4f6 <putc>
 5f0:	a019                	j	5f6 <vprintf+0x44>
    } else if(state == '%'){
 5f2:	03598363          	beq	s3,s5,618 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5f6:	0019079b          	addiw	a5,s2,1
 5fa:	893e                	mv	s2,a5
 5fc:	873e                	mv	a4,a5
 5fe:	97d2                	add	a5,a5,s4
 600:	0007c483          	lbu	s1,0(a5)
 604:	1c048a63          	beqz	s1,7d8 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 608:	0004879b          	sext.w	a5,s1
    if(state == 0){
 60c:	fe0993e3          	bnez	s3,5f2 <vprintf+0x40>
      if(c0 == '%'){
 610:	fd579ce3          	bne	a5,s5,5e8 <vprintf+0x36>
        state = '%';
 614:	89be                	mv	s3,a5
 616:	b7c5                	j	5f6 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 618:	00ea06b3          	add	a3,s4,a4
 61c:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 620:	1c060863          	beqz	a2,7f0 <vprintf+0x23e>
      if(c0 == 'd'){
 624:	03878763          	beq	a5,s8,652 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 628:	f9478693          	addi	a3,a5,-108
 62c:	0016b693          	seqz	a3,a3
 630:	f9c60593          	addi	a1,a2,-100
 634:	e99d                	bnez	a1,66a <vprintf+0xb8>
 636:	ca95                	beqz	a3,66a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	008b8493          	addi	s1,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	ecfff0ef          	jal	514 <printint>
        i += 1;
 64a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 64c:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 64e:	4981                	li	s3,0
 650:	b75d                	j	5f6 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 652:	008b8493          	addi	s1,s7,8
 656:	4685                	li	a3,1
 658:	4629                	li	a2,10
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	eb5ff0ef          	jal	514 <printint>
 664:	8ba6                	mv	s7,s1
      state = 0;
 666:	4981                	li	s3,0
 668:	b779                	j	5f6 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 66a:	9752                	add	a4,a4,s4
 66c:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 670:	f9460713          	addi	a4,a2,-108
 674:	00173713          	seqz	a4,a4
 678:	8f75                	and	a4,a4,a3
 67a:	f9c58513          	addi	a0,a1,-100
 67e:	18051363          	bnez	a0,804 <vprintf+0x252>
 682:	18070163          	beqz	a4,804 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 686:	008b8493          	addi	s1,s7,8
 68a:	4685                	li	a3,1
 68c:	4629                	li	a2,10
 68e:	000bb583          	ld	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	e81ff0ef          	jal	514 <printint>
        i += 2;
 698:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 69a:	8ba6                	mv	s7,s1
      state = 0;
 69c:	4981                	li	s3,0
        i += 2;
 69e:	bfa1                	j	5f6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6a0:	008b8493          	addi	s1,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4629                	li	a2,10
 6a8:	000be583          	lwu	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	e67ff0ef          	jal	514 <printint>
 6b2:	8ba6                	mv	s7,s1
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b781                	j	5f6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b8:	008b8493          	addi	s1,s7,8
 6bc:	4681                	li	a3,0
 6be:	4629                	li	a2,10
 6c0:	000bb583          	ld	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	e4fff0ef          	jal	514 <printint>
        i += 1;
 6ca:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6cc:	8ba6                	mv	s7,s1
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b71d                	j	5f6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d2:	008b8493          	addi	s1,s7,8
 6d6:	4681                	li	a3,0
 6d8:	4629                	li	a2,10
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	e35ff0ef          	jal	514 <printint>
        i += 2;
 6e4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e6:	8ba6                	mv	s7,s1
      state = 0;
 6e8:	4981                	li	s3,0
        i += 2;
 6ea:	b731                	j	5f6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ec:	008b8493          	addi	s1,s7,8
 6f0:	4681                	li	a3,0
 6f2:	4641                	li	a2,16
 6f4:	000be583          	lwu	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	e1bff0ef          	jal	514 <printint>
 6fe:	8ba6                	mv	s7,s1
      state = 0;
 700:	4981                	li	s3,0
 702:	bdd5                	j	5f6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 704:	008b8493          	addi	s1,s7,8
 708:	4681                	li	a3,0
 70a:	4641                	li	a2,16
 70c:	000bb583          	ld	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	e03ff0ef          	jal	514 <printint>
        i += 1;
 716:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 718:	8ba6                	mv	s7,s1
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bde9                	j	5f6 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 71e:	008b8493          	addi	s1,s7,8
 722:	4681                	li	a3,0
 724:	4641                	li	a2,16
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	de9ff0ef          	jal	514 <printint>
        i += 2;
 730:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 732:	8ba6                	mv	s7,s1
      state = 0;
 734:	4981                	li	s3,0
        i += 2;
 736:	b5c1                	j	5f6 <vprintf+0x44>
 738:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 73a:	008b8793          	addi	a5,s7,8
 73e:	8cbe                	mv	s9,a5
 740:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 744:	03000593          	li	a1,48
 748:	855a                	mv	a0,s6
 74a:	dadff0ef          	jal	4f6 <putc>
  putc(fd, 'x');
 74e:	07800593          	li	a1,120
 752:	855a                	mv	a0,s6
 754:	da3ff0ef          	jal	4f6 <putc>
 758:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 75a:	00000b97          	auipc	s7,0x0
 75e:	5e6b8b93          	addi	s7,s7,1510 # d40 <digits>
 762:	03c9d793          	srli	a5,s3,0x3c
 766:	97de                	add	a5,a5,s7
 768:	0007c583          	lbu	a1,0(a5)
 76c:	855a                	mv	a0,s6
 76e:	d89ff0ef          	jal	4f6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 772:	0992                	slli	s3,s3,0x4
 774:	34fd                	addiw	s1,s1,-1
 776:	f4f5                	bnez	s1,762 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 778:	8be6                	mv	s7,s9
      state = 0;
 77a:	4981                	li	s3,0
 77c:	6ca2                	ld	s9,8(sp)
 77e:	bda5                	j	5f6 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 780:	008b8493          	addi	s1,s7,8
 784:	000bc583          	lbu	a1,0(s7)
 788:	855a                	mv	a0,s6
 78a:	d6dff0ef          	jal	4f6 <putc>
 78e:	8ba6                	mv	s7,s1
      state = 0;
 790:	4981                	li	s3,0
 792:	b595                	j	5f6 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 794:	008b8993          	addi	s3,s7,8
 798:	000bb483          	ld	s1,0(s7)
 79c:	cc91                	beqz	s1,7b8 <vprintf+0x206>
        for(; *s; s++)
 79e:	0004c583          	lbu	a1,0(s1)
 7a2:	c985                	beqz	a1,7d2 <vprintf+0x220>
          putc(fd, *s);
 7a4:	855a                	mv	a0,s6
 7a6:	d51ff0ef          	jal	4f6 <putc>
        for(; *s; s++)
 7aa:	0485                	addi	s1,s1,1
 7ac:	0004c583          	lbu	a1,0(s1)
 7b0:	f9f5                	bnez	a1,7a4 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7b2:	8bce                	mv	s7,s3
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b581                	j	5f6 <vprintf+0x44>
          s = "(null)";
 7b8:	00000497          	auipc	s1,0x0
 7bc:	58048493          	addi	s1,s1,1408 # d38 <malloc+0x3e4>
        for(; *s; s++)
 7c0:	02800593          	li	a1,40
 7c4:	b7c5                	j	7a4 <vprintf+0x1f2>
        putc(fd, '%');
 7c6:	85be                	mv	a1,a5
 7c8:	855a                	mv	a0,s6
 7ca:	d2dff0ef          	jal	4f6 <putc>
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	b51d                	j	5f6 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7d2:	8bce                	mv	s7,s3
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b505                	j	5f6 <vprintf+0x44>
 7d8:	6906                	ld	s2,64(sp)
 7da:	79e2                	ld	s3,56(sp)
 7dc:	7a42                	ld	s4,48(sp)
 7de:	7aa2                	ld	s5,40(sp)
 7e0:	7b02                	ld	s6,32(sp)
 7e2:	6be2                	ld	s7,24(sp)
 7e4:	6c42                	ld	s8,16(sp)
    }
  }
}
 7e6:	60e6                	ld	ra,88(sp)
 7e8:	6446                	ld	s0,80(sp)
 7ea:	64a6                	ld	s1,72(sp)
 7ec:	6125                	addi	sp,sp,96
 7ee:	8082                	ret
      if(c0 == 'd'){
 7f0:	06400713          	li	a4,100
 7f4:	e4e78fe3          	beq	a5,a4,652 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7f8:	f9478693          	addi	a3,a5,-108
 7fc:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 800:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 802:	4701                	li	a4,0
      } else if(c0 == 'u'){
 804:	07500513          	li	a0,117
 808:	e8a78ce3          	beq	a5,a0,6a0 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 80c:	f8b60513          	addi	a0,a2,-117
 810:	e119                	bnez	a0,816 <vprintf+0x264>
 812:	ea0693e3          	bnez	a3,6b8 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 816:	f8b58513          	addi	a0,a1,-117
 81a:	e119                	bnez	a0,820 <vprintf+0x26e>
 81c:	ea071be3          	bnez	a4,6d2 <vprintf+0x120>
      } else if(c0 == 'x'){
 820:	07800513          	li	a0,120
 824:	eca784e3          	beq	a5,a0,6ec <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 828:	f8860613          	addi	a2,a2,-120
 82c:	e219                	bnez	a2,832 <vprintf+0x280>
 82e:	ec069be3          	bnez	a3,704 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 832:	f8858593          	addi	a1,a1,-120
 836:	e199                	bnez	a1,83c <vprintf+0x28a>
 838:	ee0713e3          	bnez	a4,71e <vprintf+0x16c>
      } else if(c0 == 'p'){
 83c:	07000713          	li	a4,112
 840:	eee78ce3          	beq	a5,a4,738 <vprintf+0x186>
      } else if(c0 == 'c'){
 844:	06300713          	li	a4,99
 848:	f2e78ce3          	beq	a5,a4,780 <vprintf+0x1ce>
      } else if(c0 == 's'){
 84c:	07300713          	li	a4,115
 850:	f4e782e3          	beq	a5,a4,794 <vprintf+0x1e2>
      } else if(c0 == '%'){
 854:	02500713          	li	a4,37
 858:	f6e787e3          	beq	a5,a4,7c6 <vprintf+0x214>
        putc(fd, '%');
 85c:	02500593          	li	a1,37
 860:	855a                	mv	a0,s6
 862:	c95ff0ef          	jal	4f6 <putc>
        putc(fd, c0);
 866:	85a6                	mv	a1,s1
 868:	855a                	mv	a0,s6
 86a:	c8dff0ef          	jal	4f6 <putc>
      state = 0;
 86e:	4981                	li	s3,0
 870:	b359                	j	5f6 <vprintf+0x44>

0000000000000872 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 872:	715d                	addi	sp,sp,-80
 874:	ec06                	sd	ra,24(sp)
 876:	e822                	sd	s0,16(sp)
 878:	1000                	addi	s0,sp,32
 87a:	e010                	sd	a2,0(s0)
 87c:	e414                	sd	a3,8(s0)
 87e:	e818                	sd	a4,16(s0)
 880:	ec1c                	sd	a5,24(s0)
 882:	03043023          	sd	a6,32(s0)
 886:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 88a:	8622                	mv	a2,s0
 88c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 890:	d23ff0ef          	jal	5b2 <vprintf>
}
 894:	60e2                	ld	ra,24(sp)
 896:	6442                	ld	s0,16(sp)
 898:	6161                	addi	sp,sp,80
 89a:	8082                	ret

000000000000089c <printf>:

void
printf(const char *fmt, ...)
{
 89c:	711d                	addi	sp,sp,-96
 89e:	ec06                	sd	ra,24(sp)
 8a0:	e822                	sd	s0,16(sp)
 8a2:	1000                	addi	s0,sp,32
 8a4:	e40c                	sd	a1,8(s0)
 8a6:	e810                	sd	a2,16(s0)
 8a8:	ec14                	sd	a3,24(s0)
 8aa:	f018                	sd	a4,32(s0)
 8ac:	f41c                	sd	a5,40(s0)
 8ae:	03043823          	sd	a6,48(s0)
 8b2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8b6:	00840613          	addi	a2,s0,8
 8ba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8be:	85aa                	mv	a1,a0
 8c0:	4505                	li	a0,1
 8c2:	cf1ff0ef          	jal	5b2 <vprintf>
}
 8c6:	60e2                	ld	ra,24(sp)
 8c8:	6442                	ld	s0,16(sp)
 8ca:	6125                	addi	sp,sp,96
 8cc:	8082                	ret

00000000000008ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ce:	1141                	addi	sp,sp,-16
 8d0:	e406                	sd	ra,8(sp)
 8d2:	e022                	sd	s0,0(sp)
 8d4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8da:	00000797          	auipc	a5,0x0
 8de:	7267b783          	ld	a5,1830(a5) # 1000 <freep>
 8e2:	a039                	j	8f0 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e4:	6398                	ld	a4,0(a5)
 8e6:	00e7e463          	bltu	a5,a4,8ee <free+0x20>
 8ea:	00e6ea63          	bltu	a3,a4,8fe <free+0x30>
{
 8ee:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f0:	fed7fae3          	bgeu	a5,a3,8e4 <free+0x16>
 8f4:	6398                	ld	a4,0(a5)
 8f6:	00e6e463          	bltu	a3,a4,8fe <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fa:	fee7eae3          	bltu	a5,a4,8ee <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8fe:	ff852583          	lw	a1,-8(a0)
 902:	6390                	ld	a2,0(a5)
 904:	02059813          	slli	a6,a1,0x20
 908:	01c85713          	srli	a4,a6,0x1c
 90c:	9736                	add	a4,a4,a3
 90e:	02e60563          	beq	a2,a4,938 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 912:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 916:	4790                	lw	a2,8(a5)
 918:	02061593          	slli	a1,a2,0x20
 91c:	01c5d713          	srli	a4,a1,0x1c
 920:	973e                	add	a4,a4,a5
 922:	02e68263          	beq	a3,a4,946 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 926:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 928:	00000717          	auipc	a4,0x0
 92c:	6cf73c23          	sd	a5,1752(a4) # 1000 <freep>
}
 930:	60a2                	ld	ra,8(sp)
 932:	6402                	ld	s0,0(sp)
 934:	0141                	addi	sp,sp,16
 936:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 938:	4618                	lw	a4,8(a2)
 93a:	9f2d                	addw	a4,a4,a1
 93c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 940:	6398                	ld	a4,0(a5)
 942:	6310                	ld	a2,0(a4)
 944:	b7f9                	j	912 <free+0x44>
    p->s.size += bp->s.size;
 946:	ff852703          	lw	a4,-8(a0)
 94a:	9f31                	addw	a4,a4,a2
 94c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 94e:	ff053683          	ld	a3,-16(a0)
 952:	bfd1                	j	926 <free+0x58>

0000000000000954 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 954:	7139                	addi	sp,sp,-64
 956:	fc06                	sd	ra,56(sp)
 958:	f822                	sd	s0,48(sp)
 95a:	f04a                	sd	s2,32(sp)
 95c:	ec4e                	sd	s3,24(sp)
 95e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 960:	02051993          	slli	s3,a0,0x20
 964:	0209d993          	srli	s3,s3,0x20
 968:	09bd                	addi	s3,s3,15
 96a:	0049d993          	srli	s3,s3,0x4
 96e:	2985                	addiw	s3,s3,1
 970:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 972:	00000517          	auipc	a0,0x0
 976:	68e53503          	ld	a0,1678(a0) # 1000 <freep>
 97a:	c905                	beqz	a0,9aa <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97e:	4798                	lw	a4,8(a5)
 980:	09377663          	bgeu	a4,s3,a0c <malloc+0xb8>
 984:	f426                	sd	s1,40(sp)
 986:	e852                	sd	s4,16(sp)
 988:	e456                	sd	s5,8(sp)
 98a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 98c:	8a4e                	mv	s4,s3
 98e:	6705                	lui	a4,0x1
 990:	00e9f363          	bgeu	s3,a4,996 <malloc+0x42>
 994:	6a05                	lui	s4,0x1
 996:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 99a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 99e:	00000497          	auipc	s1,0x0
 9a2:	66248493          	addi	s1,s1,1634 # 1000 <freep>
  if(p == SBRK_ERROR)
 9a6:	5afd                	li	s5,-1
 9a8:	a83d                	j	9e6 <malloc+0x92>
 9aa:	f426                	sd	s1,40(sp)
 9ac:	e852                	sd	s4,16(sp)
 9ae:	e456                	sd	s5,8(sp)
 9b0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9b2:	00000797          	auipc	a5,0x0
 9b6:	65e78793          	addi	a5,a5,1630 # 1010 <base>
 9ba:	00000717          	auipc	a4,0x0
 9be:	64f73323          	sd	a5,1606(a4) # 1000 <freep>
 9c2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9c8:	b7d1                	j	98c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9ca:	6398                	ld	a4,0(a5)
 9cc:	e118                	sd	a4,0(a0)
 9ce:	a899                	j	a24 <malloc+0xd0>
  hp->s.size = nu;
 9d0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9d4:	0541                	addi	a0,a0,16
 9d6:	ef9ff0ef          	jal	8ce <free>
  return freep;
 9da:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9dc:	c125                	beqz	a0,a3c <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e0:	4798                	lw	a4,8(a5)
 9e2:	03277163          	bgeu	a4,s2,a04 <malloc+0xb0>
    if(p == freep)
 9e6:	6098                	ld	a4,0(s1)
 9e8:	853e                	mv	a0,a5
 9ea:	fef71ae3          	bne	a4,a5,9de <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9ee:	8552                	mv	a0,s4
 9f0:	a23ff0ef          	jal	412 <sbrk>
  if(p == SBRK_ERROR)
 9f4:	fd551ee3          	bne	a0,s5,9d0 <malloc+0x7c>
        return 0;
 9f8:	4501                	li	a0,0
 9fa:	74a2                	ld	s1,40(sp)
 9fc:	6a42                	ld	s4,16(sp)
 9fe:	6aa2                	ld	s5,8(sp)
 a00:	6b02                	ld	s6,0(sp)
 a02:	a03d                	j	a30 <malloc+0xdc>
 a04:	74a2                	ld	s1,40(sp)
 a06:	6a42                	ld	s4,16(sp)
 a08:	6aa2                	ld	s5,8(sp)
 a0a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a0c:	fae90fe3          	beq	s2,a4,9ca <malloc+0x76>
        p->s.size -= nunits;
 a10:	4137073b          	subw	a4,a4,s3
 a14:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a16:	02071693          	slli	a3,a4,0x20
 a1a:	01c6d713          	srli	a4,a3,0x1c
 a1e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a20:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a24:	00000717          	auipc	a4,0x0
 a28:	5ca73e23          	sd	a0,1500(a4) # 1000 <freep>
      return (void*)(p + 1);
 a2c:	01078513          	addi	a0,a5,16
  }
}
 a30:	70e2                	ld	ra,56(sp)
 a32:	7442                	ld	s0,48(sp)
 a34:	7902                	ld	s2,32(sp)
 a36:	69e2                	ld	s3,24(sp)
 a38:	6121                	addi	sp,sp,64
 a3a:	8082                	ret
 a3c:	74a2                	ld	s1,40(sp)
 a3e:	6a42                	ld	s4,16(sp)
 a40:	6aa2                	ld	s5,8(sp)
 a42:	6b02                	ld	s6,0(sp)
 a44:	b7f5                	j	a30 <malloc+0xdc>
