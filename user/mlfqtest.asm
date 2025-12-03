
user/_mlfqtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Mixed workload test: CPU-bound vs I/O-bound side by side
// Demonstrates scheduler prioritizes I/O-bound over CPU-bound.
int
main(int argc, char *argv[])
{
   0:	7159                	addi	sp,sp,-112
   2:	f486                	sd	ra,104(sp)
   4:	f0a2                	sd	s0,96(sp)
   6:	e8ca                	sd	s2,80(sp)
   8:	1880                	addi	s0,sp,112
  int cpid1, cpid2;
  
  printf("=== Comprehensive Mixed Workload Test ===\n");
   a:	00001517          	auipc	a0,0x1
   e:	ae650513          	addi	a0,a0,-1306 # af0 <malloc+0xfc>
  12:	12b000ef          	jal	93c <printf>
  printf("Running CPU-bound and I/O-bound processes concurrently.\n");
  16:	00001517          	auipc	a0,0x1
  1a:	b0a50513          	addi	a0,a0,-1270 # b20 <malloc+0x12c>
  1e:	11f000ef          	jal	93c <printf>
  printf("This shows the scheduler's fairness: CPU-bound demotes, I/O-bound stays high.\n\n");
  22:	00001517          	auipc	a0,0x1
  26:	b3e50513          	addi	a0,a0,-1218 # b60 <malloc+0x16c>
  2a:	113000ef          	jal	93c <printf>
  
  // Fork CPU-bound process
  cpid1 = fork();
  2e:	4b0000ef          	jal	4de <fork>
  if(cpid1 == 0) {
  32:	e16d                	bnez	a0,114 <main+0x114>
  34:	eca6                	sd	s1,88(sp)
  36:	e4ce                	sd	s3,72(sp)
  38:	e0d2                	sd	s4,64(sp)
  3a:	fc56                	sd	s5,56(sp)
  3c:	f85a                	sd	s6,48(sp)
  3e:	f45e                	sd	s7,40(sp)
  40:	8a2a                	mv	s4,a0
    printf("[CPU-BOUND] Starting long computation...\n");
  42:	00001517          	auipc	a0,0x1
  46:	b6e50513          	addi	a0,a0,-1170 # bb0 <malloc+0x1bc>
  4a:	0f3000ef          	jal	93c <printf>
    volatile int dummy = 0;
  4e:	f8042e23          	sw	zero,-100(s0)
    
    // Do lots of CPU work continuously - should demote significantly
    for(int iter = 0; iter < 40; iter++) {
      for(long j = 0; j < 10000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
  52:	431be9b7          	lui	s3,0x431be
  56:	e8398993          	addi	s3,s3,-381 # 431bde83 <base+0x431bce73>
  5a:	000f4937          	lui	s2,0xf4
  5e:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf3230>
      for(long j = 0; j < 10000000; j++) {
  62:	009894b7          	lui	s1,0x989
  66:	68048493          	addi	s1,s1,1664 # 989680 <base+0x988670>
      }
      
      // Checkpoint every 10 iterations
      struct procinfo info;
      if(iter % 10 == 0 && getprocinfo(&info) == 0) {
  6a:	66666ab7          	lui	s5,0x66666
  6e:	667a8a93          	addi	s5,s5,1639 # 66666667 <base+0x66665657>
  72:	fa040b93          	addi	s7,s0,-96
    for(int iter = 0; iter < 40; iter++) {
  76:	02800b13          	li	s6,40
  7a:	a021                	j	82 <main+0x82>
  7c:	2a05                	addiw	s4,s4,1
  7e:	076a0863          	beq	s4,s6,ee <main+0xee>
      for(long j = 0; j < 10000000; j++) {
  82:	4681                	li	a3,0
        dummy = dummy + j;
  84:	f9c42783          	lw	a5,-100(s0)
  88:	9fb5                	addw	a5,a5,a3
  8a:	f8f42e23          	sw	a5,-100(s0)
        dummy = dummy % 1000000;
  8e:	f9c42783          	lw	a5,-100(s0)
  92:	0007871b          	sext.w	a4,a5
  96:	033787b3          	mul	a5,a5,s3
  9a:	97c9                	srai	a5,a5,0x32
  9c:	41f7561b          	sraiw	a2,a4,0x1f
  a0:	9f91                	subw	a5,a5,a2
  a2:	02f907bb          	mulw	a5,s2,a5
  a6:	9f1d                	subw	a4,a4,a5
  a8:	f8e42e23          	sw	a4,-100(s0)
      for(long j = 0; j < 10000000; j++) {
  ac:	0685                	addi	a3,a3,1
  ae:	fc969be3          	bne	a3,s1,84 <main+0x84>
      if(iter % 10 == 0 && getprocinfo(&info) == 0) {
  b2:	035a0733          	mul	a4,s4,s5
  b6:	9709                	srai	a4,a4,0x22
  b8:	41fa579b          	sraiw	a5,s4,0x1f
  bc:	9f1d                	subw	a4,a4,a5
  be:	0027179b          	slliw	a5,a4,0x2
  c2:	9fb9                	addw	a5,a5,a4
  c4:	0017979b          	slliw	a5,a5,0x1
  c8:	40fa07bb          	subw	a5,s4,a5
  cc:	fbc5                	bnez	a5,7c <main+0x7c>
  ce:	855e                	mv	a0,s7
  d0:	4b6000ef          	jal	586 <getprocinfo>
  d4:	f545                	bnez	a0,7c <main+0x7c>
        printf("[CPU-BOUND] Iteration %d: Q%d (slices=%d)\n", 
  d6:	fac42683          	lw	a3,-84(s0)
  da:	fa842603          	lw	a2,-88(s0)
  de:	85d2                	mv	a1,s4
  e0:	00001517          	auipc	a0,0x1
  e4:	b0050513          	addi	a0,a0,-1280 # be0 <malloc+0x1ec>
  e8:	055000ef          	jal	93c <printf>
  ec:	bf41                	j	7c <main+0x7c>
               iter, info.priority, info.time_slices);
      }
    }
    
    struct procinfo final;
    if(getprocinfo(&final) == 0) {
  ee:	fa040513          	addi	a0,s0,-96
  f2:	494000ef          	jal	586 <getprocinfo>
  f6:	c501                	beqz	a0,fe <main+0xfe>
      printf("[CPU-BOUND] Final: Q%d (TimeSlices=%d)\n", 
             final.priority, final.time_slices);
    }
    exit(0);
  f8:	4501                	li	a0,0
  fa:	3ec000ef          	jal	4e6 <exit>
      printf("[CPU-BOUND] Final: Q%d (TimeSlices=%d)\n", 
  fe:	fac42603          	lw	a2,-84(s0)
 102:	fa842583          	lw	a1,-88(s0)
 106:	00001517          	auipc	a0,0x1
 10a:	b0a50513          	addi	a0,a0,-1270 # c10 <malloc+0x21c>
 10e:	02f000ef          	jal	93c <printf>
 112:	b7dd                	j	f8 <main+0xf8>
  }
  
  // Small delay to let CPU process start first
  pause(1);
 114:	4505                	li	a0,1
 116:	460000ef          	jal	576 <pause>
  
  // Fork I/O-bound process
  cpid2 = fork();
 11a:	3c4000ef          	jal	4de <fork>
 11e:	892a                	mv	s2,a0
  if(cpid2 == 0) {
 120:	e95d                	bnez	a0,1d6 <main+0x1d6>
 122:	eca6                	sd	s1,88(sp)
 124:	e4ce                	sd	s3,72(sp)
 126:	e0d2                	sd	s4,64(sp)
 128:	fc56                	sd	s5,56(sp)
 12a:	f85a                	sd	s6,48(sp)
 12c:	f45e                	sd	s7,40(sp)
    printf("[I/O-BOUND] Starting brief work + frequent sleeps...\n");
 12e:	00001517          	auipc	a0,0x1
 132:	b0a50513          	addi	a0,a0,-1270 # c38 <malloc+0x244>
 136:	007000ef          	jal	93c <printf>
    
    // Do brief work then sleep - should stay high priority
    for(int iter = 0; iter < 25; iter++) {
      volatile int dummy = 0;
      for(long j = 0; j < 2000000; j++) {
 13a:	001e84b7          	lui	s1,0x1e8
 13e:	48048493          	addi	s1,s1,1152 # 1e8480 <base+0x1e7470>
        dummy = dummy + j;
      }
      
      pause(1);  // Sleep - yields before quantum exhausted
 142:	4a85                	li	s5,1
      
      // Checkpoint every 5 iterations
      struct procinfo info;
      if(iter % 5 == 0 && getprocinfo(&info) == 0) {
 144:	666669b7          	lui	s3,0x66666
 148:	66798993          	addi	s3,s3,1639 # 66666667 <base+0x66665657>
 14c:	fa040b93          	addi	s7,s0,-96
        printf("[I/O-BOUND] Iteration %d: Q%d (slices=%d)\n", 
 150:	00001b17          	auipc	s6,0x1
 154:	b20b0b13          	addi	s6,s6,-1248 # c70 <malloc+0x27c>
    for(int iter = 0; iter < 25; iter++) {
 158:	4a65                	li	s4,25
 15a:	a021                	j	162 <main+0x162>
 15c:	2905                	addiw	s2,s2,1
 15e:	05490963          	beq	s2,s4,1b0 <main+0x1b0>
      volatile int dummy = 0;
 162:	f8042e23          	sw	zero,-100(s0)
      for(long j = 0; j < 2000000; j++) {
 166:	4781                	li	a5,0
        dummy = dummy + j;
 168:	f9c42703          	lw	a4,-100(s0)
 16c:	9f3d                	addw	a4,a4,a5
 16e:	f8e42e23          	sw	a4,-100(s0)
      for(long j = 0; j < 2000000; j++) {
 172:	0785                	addi	a5,a5,1
 174:	fe979ae3          	bne	a5,s1,168 <main+0x168>
      pause(1);  // Sleep - yields before quantum exhausted
 178:	8556                	mv	a0,s5
 17a:	3fc000ef          	jal	576 <pause>
      if(iter % 5 == 0 && getprocinfo(&info) == 0) {
 17e:	033907b3          	mul	a5,s2,s3
 182:	9785                	srai	a5,a5,0x21
 184:	41f9571b          	sraiw	a4,s2,0x1f
 188:	9f99                	subw	a5,a5,a4
 18a:	0027971b          	slliw	a4,a5,0x2
 18e:	9fb9                	addw	a5,a5,a4
 190:	40f907bb          	subw	a5,s2,a5
 194:	f7e1                	bnez	a5,15c <main+0x15c>
 196:	855e                	mv	a0,s7
 198:	3ee000ef          	jal	586 <getprocinfo>
 19c:	f161                	bnez	a0,15c <main+0x15c>
        printf("[I/O-BOUND] Iteration %d: Q%d (slices=%d)\n", 
 19e:	fac42683          	lw	a3,-84(s0)
 1a2:	fa842603          	lw	a2,-88(s0)
 1a6:	85ca                	mv	a1,s2
 1a8:	855a                	mv	a0,s6
 1aa:	792000ef          	jal	93c <printf>
 1ae:	b77d                	j	15c <main+0x15c>
               iter, info.priority, info.time_slices);
      }
    }
    
    struct procinfo final;
    if(getprocinfo(&final) == 0) {
 1b0:	fa040513          	addi	a0,s0,-96
 1b4:	3d2000ef          	jal	586 <getprocinfo>
 1b8:	c501                	beqz	a0,1c0 <main+0x1c0>
      printf("[I/O-BOUND] Final: Q%d (TimeSlices=%d)\n", 
             final.priority, final.time_slices);
    }
    exit(0);
 1ba:	4501                	li	a0,0
 1bc:	32a000ef          	jal	4e6 <exit>
      printf("[I/O-BOUND] Final: Q%d (TimeSlices=%d)\n", 
 1c0:	fac42603          	lw	a2,-84(s0)
 1c4:	fa842583          	lw	a1,-88(s0)
 1c8:	00001517          	auipc	a0,0x1
 1cc:	ad850513          	addi	a0,a0,-1320 # ca0 <malloc+0x2ac>
 1d0:	76c000ef          	jal	93c <printf>
 1d4:	b7dd                	j	1ba <main+0x1ba>
 1d6:	eca6                	sd	s1,88(sp)
 1d8:	e4ce                	sd	s3,72(sp)
 1da:	e0d2                	sd	s4,64(sp)
 1dc:	fc56                	sd	s5,56(sp)
 1de:	f85a                	sd	s6,48(sp)
 1e0:	f45e                	sd	s7,40(sp)
  }
  
  // Parent waits for both children
  wait(0);
 1e2:	4501                	li	a0,0
 1e4:	30a000ef          	jal	4ee <wait>
  wait(0);
 1e8:	4501                	li	a0,0
 1ea:	304000ef          	jal	4ee <wait>
  
  printf("\n=== Test Complete ===\n");
 1ee:	00001517          	auipc	a0,0x1
 1f2:	ada50513          	addi	a0,a0,-1318 # cc8 <malloc+0x2d4>
 1f6:	746000ef          	jal	93c <printf>
  printf("Expected Behavior:\n");
 1fa:	00001517          	auipc	a0,0x1
 1fe:	ae650513          	addi	a0,a0,-1306 # ce0 <malloc+0x2ec>
 202:	73a000ef          	jal	93c <printf>
  printf("  CPU-bound:  Demoted to Q2 or Q3 (lower priority)\n");
 206:	00001517          	auipc	a0,0x1
 20a:	af250513          	addi	a0,a0,-1294 # cf8 <malloc+0x304>
 20e:	72e000ef          	jal	93c <printf>
  printf("  I/O-bound:  Stayed in Q0 or Q1 (higher priority)\n");
 212:	00001517          	auipc	a0,0x1
 216:	b1e50513          	addi	a0,a0,-1250 # d30 <malloc+0x33c>
 21a:	722000ef          	jal	93c <printf>
  printf("  Result:     I/O-bound process got preference despite CPU competition\n");
 21e:	00001517          	auipc	a0,0x1
 222:	b4a50513          	addi	a0,a0,-1206 # d68 <malloc+0x374>
 226:	716000ef          	jal	93c <printf>
  
  exit(0);
 22a:	4501                	li	a0,0
 22c:	2ba000ef          	jal	4e6 <exit>

0000000000000230 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 230:	1141                	addi	sp,sp,-16
 232:	e406                	sd	ra,8(sp)
 234:	e022                	sd	s0,0(sp)
 236:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 238:	dc9ff0ef          	jal	0 <main>
  exit(r);
 23c:	2aa000ef          	jal	4e6 <exit>

0000000000000240 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 240:	1141                	addi	sp,sp,-16
 242:	e406                	sd	ra,8(sp)
 244:	e022                	sd	s0,0(sp)
 246:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 248:	87aa                	mv	a5,a0
 24a:	0585                	addi	a1,a1,1
 24c:	0785                	addi	a5,a5,1
 24e:	fff5c703          	lbu	a4,-1(a1)
 252:	fee78fa3          	sb	a4,-1(a5)
 256:	fb75                	bnez	a4,24a <strcpy+0xa>
    ;
  return os;
}
 258:	60a2                	ld	ra,8(sp)
 25a:	6402                	ld	s0,0(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret

0000000000000260 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 260:	1141                	addi	sp,sp,-16
 262:	e406                	sd	ra,8(sp)
 264:	e022                	sd	s0,0(sp)
 266:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 268:	00054783          	lbu	a5,0(a0)
 26c:	cb91                	beqz	a5,280 <strcmp+0x20>
 26e:	0005c703          	lbu	a4,0(a1)
 272:	00f71763          	bne	a4,a5,280 <strcmp+0x20>
    p++, q++;
 276:	0505                	addi	a0,a0,1
 278:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	fbe5                	bnez	a5,26e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 280:	0005c503          	lbu	a0,0(a1)
}
 284:	40a7853b          	subw	a0,a5,a0
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret

0000000000000290 <strlen>:

uint
strlen(const char *s)
{
 290:	1141                	addi	sp,sp,-16
 292:	e406                	sd	ra,8(sp)
 294:	e022                	sd	s0,0(sp)
 296:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 298:	00054783          	lbu	a5,0(a0)
 29c:	cf91                	beqz	a5,2b8 <strlen+0x28>
 29e:	00150793          	addi	a5,a0,1
 2a2:	86be                	mv	a3,a5
 2a4:	0785                	addi	a5,a5,1
 2a6:	fff7c703          	lbu	a4,-1(a5)
 2aa:	ff65                	bnez	a4,2a2 <strlen+0x12>
 2ac:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2b0:	60a2                	ld	ra,8(sp)
 2b2:	6402                	ld	s0,0(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
  for(n = 0; s[n]; n++)
 2b8:	4501                	li	a0,0
 2ba:	bfdd                	j	2b0 <strlen+0x20>

00000000000002bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e406                	sd	ra,8(sp)
 2c0:	e022                	sd	s0,0(sp)
 2c2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2c4:	ca19                	beqz	a2,2da <memset+0x1e>
 2c6:	87aa                	mv	a5,a0
 2c8:	1602                	slli	a2,a2,0x20
 2ca:	9201                	srli	a2,a2,0x20
 2cc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2d4:	0785                	addi	a5,a5,1
 2d6:	fee79de3          	bne	a5,a4,2d0 <memset+0x14>
  }
  return dst;
}
 2da:	60a2                	ld	ra,8(sp)
 2dc:	6402                	ld	s0,0(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <strchr>:

char*
strchr(const char *s, char c)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e406                	sd	ra,8(sp)
 2e6:	e022                	sd	s0,0(sp)
 2e8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	cf81                	beqz	a5,306 <strchr+0x24>
    if(*s == c)
 2f0:	00f58763          	beq	a1,a5,2fe <strchr+0x1c>
  for(; *s; s++)
 2f4:	0505                	addi	a0,a0,1
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	fbfd                	bnez	a5,2f0 <strchr+0xe>
      return (char*)s;
  return 0;
 2fc:	4501                	li	a0,0
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret
  return 0;
 306:	4501                	li	a0,0
 308:	bfdd                	j	2fe <strchr+0x1c>

000000000000030a <gets>:

char*
gets(char *buf, int max)
{
 30a:	711d                	addi	sp,sp,-96
 30c:	ec86                	sd	ra,88(sp)
 30e:	e8a2                	sd	s0,80(sp)
 310:	e4a6                	sd	s1,72(sp)
 312:	e0ca                	sd	s2,64(sp)
 314:	fc4e                	sd	s3,56(sp)
 316:	f852                	sd	s4,48(sp)
 318:	f456                	sd	s5,40(sp)
 31a:	f05a                	sd	s6,32(sp)
 31c:	ec5e                	sd	s7,24(sp)
 31e:	e862                	sd	s8,16(sp)
 320:	1080                	addi	s0,sp,96
 322:	8baa                	mv	s7,a0
 324:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 326:	892a                	mv	s2,a0
 328:	4481                	li	s1,0
    cc = read(0, &c, 1);
 32a:	faf40b13          	addi	s6,s0,-81
 32e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 330:	8c26                	mv	s8,s1
 332:	0014899b          	addiw	s3,s1,1
 336:	84ce                	mv	s1,s3
 338:	0349d463          	bge	s3,s4,360 <gets+0x56>
    cc = read(0, &c, 1);
 33c:	8656                	mv	a2,s5
 33e:	85da                	mv	a1,s6
 340:	4501                	li	a0,0
 342:	1bc000ef          	jal	4fe <read>
    if(cc < 1)
 346:	00a05d63          	blez	a0,360 <gets+0x56>
      break;
    buf[i++] = c;
 34a:	faf44783          	lbu	a5,-81(s0)
 34e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 352:	0905                	addi	s2,s2,1
 354:	ff678713          	addi	a4,a5,-10
 358:	c319                	beqz	a4,35e <gets+0x54>
 35a:	17cd                	addi	a5,a5,-13
 35c:	fbf1                	bnez	a5,330 <gets+0x26>
    buf[i++] = c;
 35e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 360:	9c5e                	add	s8,s8,s7
 362:	000c0023          	sb	zero,0(s8)
  return buf;
}
 366:	855e                	mv	a0,s7
 368:	60e6                	ld	ra,88(sp)
 36a:	6446                	ld	s0,80(sp)
 36c:	64a6                	ld	s1,72(sp)
 36e:	6906                	ld	s2,64(sp)
 370:	79e2                	ld	s3,56(sp)
 372:	7a42                	ld	s4,48(sp)
 374:	7aa2                	ld	s5,40(sp)
 376:	7b02                	ld	s6,32(sp)
 378:	6be2                	ld	s7,24(sp)
 37a:	6c42                	ld	s8,16(sp)
 37c:	6125                	addi	sp,sp,96
 37e:	8082                	ret

0000000000000380 <stat>:

int
stat(const char *n, struct stat *st)
{
 380:	1101                	addi	sp,sp,-32
 382:	ec06                	sd	ra,24(sp)
 384:	e822                	sd	s0,16(sp)
 386:	e04a                	sd	s2,0(sp)
 388:	1000                	addi	s0,sp,32
 38a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 38c:	4581                	li	a1,0
 38e:	198000ef          	jal	526 <open>
  if(fd < 0)
 392:	02054263          	bltz	a0,3b6 <stat+0x36>
 396:	e426                	sd	s1,8(sp)
 398:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 39a:	85ca                	mv	a1,s2
 39c:	1a2000ef          	jal	53e <fstat>
 3a0:	892a                	mv	s2,a0
  close(fd);
 3a2:	8526                	mv	a0,s1
 3a4:	16a000ef          	jal	50e <close>
  return r;
 3a8:	64a2                	ld	s1,8(sp)
}
 3aa:	854a                	mv	a0,s2
 3ac:	60e2                	ld	ra,24(sp)
 3ae:	6442                	ld	s0,16(sp)
 3b0:	6902                	ld	s2,0(sp)
 3b2:	6105                	addi	sp,sp,32
 3b4:	8082                	ret
    return -1;
 3b6:	57fd                	li	a5,-1
 3b8:	893e                	mv	s2,a5
 3ba:	bfc5                	j	3aa <stat+0x2a>

00000000000003bc <atoi>:

int
atoi(const char *s)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e406                	sd	ra,8(sp)
 3c0:	e022                	sd	s0,0(sp)
 3c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c4:	00054683          	lbu	a3,0(a0)
 3c8:	fd06879b          	addiw	a5,a3,-48
 3cc:	0ff7f793          	zext.b	a5,a5
 3d0:	4625                	li	a2,9
 3d2:	02f66963          	bltu	a2,a5,404 <atoi+0x48>
 3d6:	872a                	mv	a4,a0
  n = 0;
 3d8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3da:	0705                	addi	a4,a4,1
 3dc:	0025179b          	slliw	a5,a0,0x2
 3e0:	9fa9                	addw	a5,a5,a0
 3e2:	0017979b          	slliw	a5,a5,0x1
 3e6:	9fb5                	addw	a5,a5,a3
 3e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3ec:	00074683          	lbu	a3,0(a4)
 3f0:	fd06879b          	addiw	a5,a3,-48
 3f4:	0ff7f793          	zext.b	a5,a5
 3f8:	fef671e3          	bgeu	a2,a5,3da <atoi+0x1e>
  return n;
}
 3fc:	60a2                	ld	ra,8(sp)
 3fe:	6402                	ld	s0,0(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
  n = 0;
 404:	4501                	li	a0,0
 406:	bfdd                	j	3fc <atoi+0x40>

0000000000000408 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 408:	1141                	addi	sp,sp,-16
 40a:	e406                	sd	ra,8(sp)
 40c:	e022                	sd	s0,0(sp)
 40e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 410:	02b57563          	bgeu	a0,a1,43a <memmove+0x32>
    while(n-- > 0)
 414:	00c05f63          	blez	a2,432 <memmove+0x2a>
 418:	1602                	slli	a2,a2,0x20
 41a:	9201                	srli	a2,a2,0x20
 41c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 420:	872a                	mv	a4,a0
      *dst++ = *src++;
 422:	0585                	addi	a1,a1,1
 424:	0705                	addi	a4,a4,1
 426:	fff5c683          	lbu	a3,-1(a1)
 42a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 42e:	fee79ae3          	bne	a5,a4,422 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 432:	60a2                	ld	ra,8(sp)
 434:	6402                	ld	s0,0(sp)
 436:	0141                	addi	sp,sp,16
 438:	8082                	ret
    while(n-- > 0)
 43a:	fec05ce3          	blez	a2,432 <memmove+0x2a>
    dst += n;
 43e:	00c50733          	add	a4,a0,a2
    src += n;
 442:	95b2                	add	a1,a1,a2
 444:	fff6079b          	addiw	a5,a2,-1
 448:	1782                	slli	a5,a5,0x20
 44a:	9381                	srli	a5,a5,0x20
 44c:	fff7c793          	not	a5,a5
 450:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 452:	15fd                	addi	a1,a1,-1
 454:	177d                	addi	a4,a4,-1
 456:	0005c683          	lbu	a3,0(a1)
 45a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 45e:	fef71ae3          	bne	a4,a5,452 <memmove+0x4a>
 462:	bfc1                	j	432 <memmove+0x2a>

0000000000000464 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 464:	1141                	addi	sp,sp,-16
 466:	e406                	sd	ra,8(sp)
 468:	e022                	sd	s0,0(sp)
 46a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 46c:	c61d                	beqz	a2,49a <memcmp+0x36>
 46e:	1602                	slli	a2,a2,0x20
 470:	9201                	srli	a2,a2,0x20
 472:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 476:	00054783          	lbu	a5,0(a0)
 47a:	0005c703          	lbu	a4,0(a1)
 47e:	00e79863          	bne	a5,a4,48e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 482:	0505                	addi	a0,a0,1
    p2++;
 484:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 486:	fed518e3          	bne	a0,a3,476 <memcmp+0x12>
  }
  return 0;
 48a:	4501                	li	a0,0
 48c:	a019                	j	492 <memcmp+0x2e>
      return *p1 - *p2;
 48e:	40e7853b          	subw	a0,a5,a4
}
 492:	60a2                	ld	ra,8(sp)
 494:	6402                	ld	s0,0(sp)
 496:	0141                	addi	sp,sp,16
 498:	8082                	ret
  return 0;
 49a:	4501                	li	a0,0
 49c:	bfdd                	j	492 <memcmp+0x2e>

000000000000049e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 49e:	1141                	addi	sp,sp,-16
 4a0:	e406                	sd	ra,8(sp)
 4a2:	e022                	sd	s0,0(sp)
 4a4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4a6:	f63ff0ef          	jal	408 <memmove>
}
 4aa:	60a2                	ld	ra,8(sp)
 4ac:	6402                	ld	s0,0(sp)
 4ae:	0141                	addi	sp,sp,16
 4b0:	8082                	ret

00000000000004b2 <sbrk>:

char *
sbrk(int n) {
 4b2:	1141                	addi	sp,sp,-16
 4b4:	e406                	sd	ra,8(sp)
 4b6:	e022                	sd	s0,0(sp)
 4b8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4ba:	4585                	li	a1,1
 4bc:	0b2000ef          	jal	56e <sys_sbrk>
}
 4c0:	60a2                	ld	ra,8(sp)
 4c2:	6402                	ld	s0,0(sp)
 4c4:	0141                	addi	sp,sp,16
 4c6:	8082                	ret

00000000000004c8 <sbrklazy>:

char *
sbrklazy(int n) {
 4c8:	1141                	addi	sp,sp,-16
 4ca:	e406                	sd	ra,8(sp)
 4cc:	e022                	sd	s0,0(sp)
 4ce:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4d0:	4589                	li	a1,2
 4d2:	09c000ef          	jal	56e <sys_sbrk>
}
 4d6:	60a2                	ld	ra,8(sp)
 4d8:	6402                	ld	s0,0(sp)
 4da:	0141                	addi	sp,sp,16
 4dc:	8082                	ret

00000000000004de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4de:	4885                	li	a7,1
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4e6:	4889                	li	a7,2
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ee:	488d                	li	a7,3
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4f6:	4891                	li	a7,4
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <read>:
.global read
read:
 li a7, SYS_read
 4fe:	4895                	li	a7,5
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <write>:
.global write
write:
 li a7, SYS_write
 506:	48c1                	li	a7,16
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <close>:
.global close
close:
 li a7, SYS_close
 50e:	48d5                	li	a7,21
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <kill>:
.global kill
kill:
 li a7, SYS_kill
 516:	4899                	li	a7,6
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <exec>:
.global exec
exec:
 li a7, SYS_exec
 51e:	489d                	li	a7,7
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <open>:
.global open
open:
 li a7, SYS_open
 526:	48bd                	li	a7,15
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 52e:	48c5                	li	a7,17
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 536:	48c9                	li	a7,18
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 53e:	48a1                	li	a7,8
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <link>:
.global link
link:
 li a7, SYS_link
 546:	48cd                	li	a7,19
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 54e:	48d1                	li	a7,20
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 556:	48a5                	li	a7,9
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <dup>:
.global dup
dup:
 li a7, SYS_dup
 55e:	48a9                	li	a7,10
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 566:	48ad                	li	a7,11
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 56e:	48b1                	li	a7,12
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <pause>:
.global pause
pause:
 li a7, SYS_pause
 576:	48b5                	li	a7,13
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 57e:	48b9                	li	a7,14
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 586:	48d9                	li	a7,22
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 58e:	48dd                	li	a7,23
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 596:	1101                	addi	sp,sp,-32
 598:	ec06                	sd	ra,24(sp)
 59a:	e822                	sd	s0,16(sp)
 59c:	1000                	addi	s0,sp,32
 59e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5a2:	4605                	li	a2,1
 5a4:	fef40593          	addi	a1,s0,-17
 5a8:	f5fff0ef          	jal	506 <write>
}
 5ac:	60e2                	ld	ra,24(sp)
 5ae:	6442                	ld	s0,16(sp)
 5b0:	6105                	addi	sp,sp,32
 5b2:	8082                	ret

00000000000005b4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5b4:	715d                	addi	sp,sp,-80
 5b6:	e486                	sd	ra,72(sp)
 5b8:	e0a2                	sd	s0,64(sp)
 5ba:	f84a                	sd	s2,48(sp)
 5bc:	f44e                	sd	s3,40(sp)
 5be:	0880                	addi	s0,sp,80
 5c0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5c2:	c6d1                	beqz	a3,64e <printint+0x9a>
 5c4:	0805d563          	bgez	a1,64e <printint+0x9a>
    neg = 1;
    x = -xx;
 5c8:	40b005b3          	neg	a1,a1
    neg = 1;
 5cc:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5ce:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5d2:	86ce                	mv	a3,s3
  i = 0;
 5d4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5d6:	00000817          	auipc	a6,0x0
 5da:	7e280813          	addi	a6,a6,2018 # db8 <digits>
 5de:	88ba                	mv	a7,a4
 5e0:	0017051b          	addiw	a0,a4,1
 5e4:	872a                	mv	a4,a0
 5e6:	02c5f7b3          	remu	a5,a1,a2
 5ea:	97c2                	add	a5,a5,a6
 5ec:	0007c783          	lbu	a5,0(a5)
 5f0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5f4:	87ae                	mv	a5,a1
 5f6:	02c5d5b3          	divu	a1,a1,a2
 5fa:	0685                	addi	a3,a3,1
 5fc:	fec7f1e3          	bgeu	a5,a2,5de <printint+0x2a>
  if(neg)
 600:	00030c63          	beqz	t1,618 <printint+0x64>
    buf[i++] = '-';
 604:	fd050793          	addi	a5,a0,-48
 608:	00878533          	add	a0,a5,s0
 60c:	02d00793          	li	a5,45
 610:	fef50423          	sb	a5,-24(a0)
 614:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 618:	02e05563          	blez	a4,642 <printint+0x8e>
 61c:	fc26                	sd	s1,56(sp)
 61e:	377d                	addiw	a4,a4,-1
 620:	00e984b3          	add	s1,s3,a4
 624:	19fd                	addi	s3,s3,-1
 626:	99ba                	add	s3,s3,a4
 628:	1702                	slli	a4,a4,0x20
 62a:	9301                	srli	a4,a4,0x20
 62c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 630:	0004c583          	lbu	a1,0(s1)
 634:	854a                	mv	a0,s2
 636:	f61ff0ef          	jal	596 <putc>
  while(--i >= 0)
 63a:	14fd                	addi	s1,s1,-1
 63c:	ff349ae3          	bne	s1,s3,630 <printint+0x7c>
 640:	74e2                	ld	s1,56(sp)
}
 642:	60a6                	ld	ra,72(sp)
 644:	6406                	ld	s0,64(sp)
 646:	7942                	ld	s2,48(sp)
 648:	79a2                	ld	s3,40(sp)
 64a:	6161                	addi	sp,sp,80
 64c:	8082                	ret
  neg = 0;
 64e:	4301                	li	t1,0
 650:	bfbd                	j	5ce <printint+0x1a>

0000000000000652 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 652:	711d                	addi	sp,sp,-96
 654:	ec86                	sd	ra,88(sp)
 656:	e8a2                	sd	s0,80(sp)
 658:	e4a6                	sd	s1,72(sp)
 65a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 65c:	0005c483          	lbu	s1,0(a1)
 660:	22048363          	beqz	s1,886 <vprintf+0x234>
 664:	e0ca                	sd	s2,64(sp)
 666:	fc4e                	sd	s3,56(sp)
 668:	f852                	sd	s4,48(sp)
 66a:	f456                	sd	s5,40(sp)
 66c:	f05a                	sd	s6,32(sp)
 66e:	ec5e                	sd	s7,24(sp)
 670:	e862                	sd	s8,16(sp)
 672:	8b2a                	mv	s6,a0
 674:	8a2e                	mv	s4,a1
 676:	8bb2                	mv	s7,a2
  state = 0;
 678:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 67a:	4901                	li	s2,0
 67c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 67e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 682:	06400c13          	li	s8,100
 686:	a00d                	j	6a8 <vprintf+0x56>
        putc(fd, c0);
 688:	85a6                	mv	a1,s1
 68a:	855a                	mv	a0,s6
 68c:	f0bff0ef          	jal	596 <putc>
 690:	a019                	j	696 <vprintf+0x44>
    } else if(state == '%'){
 692:	03598363          	beq	s3,s5,6b8 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 696:	0019079b          	addiw	a5,s2,1
 69a:	893e                	mv	s2,a5
 69c:	873e                	mv	a4,a5
 69e:	97d2                	add	a5,a5,s4
 6a0:	0007c483          	lbu	s1,0(a5)
 6a4:	1c048a63          	beqz	s1,878 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6a8:	0004879b          	sext.w	a5,s1
    if(state == 0){
 6ac:	fe0993e3          	bnez	s3,692 <vprintf+0x40>
      if(c0 == '%'){
 6b0:	fd579ce3          	bne	a5,s5,688 <vprintf+0x36>
        state = '%';
 6b4:	89be                	mv	s3,a5
 6b6:	b7c5                	j	696 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 6b8:	00ea06b3          	add	a3,s4,a4
 6bc:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 6c0:	1c060863          	beqz	a2,890 <vprintf+0x23e>
      if(c0 == 'd'){
 6c4:	03878763          	beq	a5,s8,6f2 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6c8:	f9478693          	addi	a3,a5,-108
 6cc:	0016b693          	seqz	a3,a3
 6d0:	f9c60593          	addi	a1,a2,-100
 6d4:	e99d                	bnez	a1,70a <vprintf+0xb8>
 6d6:	ca95                	beqz	a3,70a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d8:	008b8493          	addi	s1,s7,8
 6dc:	4685                	li	a3,1
 6de:	4629                	li	a2,10
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	ecfff0ef          	jal	5b4 <printint>
        i += 1;
 6ea:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ec:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b75d                	j	696 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6f2:	008b8493          	addi	s1,s7,8
 6f6:	4685                	li	a3,1
 6f8:	4629                	li	a2,10
 6fa:	000ba583          	lw	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	eb5ff0ef          	jal	5b4 <printint>
 704:	8ba6                	mv	s7,s1
      state = 0;
 706:	4981                	li	s3,0
 708:	b779                	j	696 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 70a:	9752                	add	a4,a4,s4
 70c:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 710:	f9460713          	addi	a4,a2,-108
 714:	00173713          	seqz	a4,a4
 718:	8f75                	and	a4,a4,a3
 71a:	f9c58513          	addi	a0,a1,-100
 71e:	18051363          	bnez	a0,8a4 <vprintf+0x252>
 722:	18070163          	beqz	a4,8a4 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 726:	008b8493          	addi	s1,s7,8
 72a:	4685                	li	a3,1
 72c:	4629                	li	a2,10
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	e81ff0ef          	jal	5b4 <printint>
        i += 2;
 738:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 73a:	8ba6                	mv	s7,s1
      state = 0;
 73c:	4981                	li	s3,0
        i += 2;
 73e:	bfa1                	j	696 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 740:	008b8493          	addi	s1,s7,8
 744:	4681                	li	a3,0
 746:	4629                	li	a2,10
 748:	000be583          	lwu	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	e67ff0ef          	jal	5b4 <printint>
 752:	8ba6                	mv	s7,s1
      state = 0;
 754:	4981                	li	s3,0
 756:	b781                	j	696 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 758:	008b8493          	addi	s1,s7,8
 75c:	4681                	li	a3,0
 75e:	4629                	li	a2,10
 760:	000bb583          	ld	a1,0(s7)
 764:	855a                	mv	a0,s6
 766:	e4fff0ef          	jal	5b4 <printint>
        i += 1;
 76a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 76c:	8ba6                	mv	s7,s1
      state = 0;
 76e:	4981                	li	s3,0
 770:	b71d                	j	696 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 772:	008b8493          	addi	s1,s7,8
 776:	4681                	li	a3,0
 778:	4629                	li	a2,10
 77a:	000bb583          	ld	a1,0(s7)
 77e:	855a                	mv	a0,s6
 780:	e35ff0ef          	jal	5b4 <printint>
        i += 2;
 784:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 786:	8ba6                	mv	s7,s1
      state = 0;
 788:	4981                	li	s3,0
        i += 2;
 78a:	b731                	j	696 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 78c:	008b8493          	addi	s1,s7,8
 790:	4681                	li	a3,0
 792:	4641                	li	a2,16
 794:	000be583          	lwu	a1,0(s7)
 798:	855a                	mv	a0,s6
 79a:	e1bff0ef          	jal	5b4 <printint>
 79e:	8ba6                	mv	s7,s1
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	bdd5                	j	696 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a4:	008b8493          	addi	s1,s7,8
 7a8:	4681                	li	a3,0
 7aa:	4641                	li	a2,16
 7ac:	000bb583          	ld	a1,0(s7)
 7b0:	855a                	mv	a0,s6
 7b2:	e03ff0ef          	jal	5b4 <printint>
        i += 1;
 7b6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b8:	8ba6                	mv	s7,s1
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	bde9                	j	696 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7be:	008b8493          	addi	s1,s7,8
 7c2:	4681                	li	a3,0
 7c4:	4641                	li	a2,16
 7c6:	000bb583          	ld	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	de9ff0ef          	jal	5b4 <printint>
        i += 2;
 7d0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d2:	8ba6                	mv	s7,s1
      state = 0;
 7d4:	4981                	li	s3,0
        i += 2;
 7d6:	b5c1                	j	696 <vprintf+0x44>
 7d8:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7da:	008b8793          	addi	a5,s7,8
 7de:	8cbe                	mv	s9,a5
 7e0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7e4:	03000593          	li	a1,48
 7e8:	855a                	mv	a0,s6
 7ea:	dadff0ef          	jal	596 <putc>
  putc(fd, 'x');
 7ee:	07800593          	li	a1,120
 7f2:	855a                	mv	a0,s6
 7f4:	da3ff0ef          	jal	596 <putc>
 7f8:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7fa:	00000b97          	auipc	s7,0x0
 7fe:	5beb8b93          	addi	s7,s7,1470 # db8 <digits>
 802:	03c9d793          	srli	a5,s3,0x3c
 806:	97de                	add	a5,a5,s7
 808:	0007c583          	lbu	a1,0(a5)
 80c:	855a                	mv	a0,s6
 80e:	d89ff0ef          	jal	596 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 812:	0992                	slli	s3,s3,0x4
 814:	34fd                	addiw	s1,s1,-1
 816:	f4f5                	bnez	s1,802 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 818:	8be6                	mv	s7,s9
      state = 0;
 81a:	4981                	li	s3,0
 81c:	6ca2                	ld	s9,8(sp)
 81e:	bda5                	j	696 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 820:	008b8493          	addi	s1,s7,8
 824:	000bc583          	lbu	a1,0(s7)
 828:	855a                	mv	a0,s6
 82a:	d6dff0ef          	jal	596 <putc>
 82e:	8ba6                	mv	s7,s1
      state = 0;
 830:	4981                	li	s3,0
 832:	b595                	j	696 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 834:	008b8993          	addi	s3,s7,8
 838:	000bb483          	ld	s1,0(s7)
 83c:	cc91                	beqz	s1,858 <vprintf+0x206>
        for(; *s; s++)
 83e:	0004c583          	lbu	a1,0(s1)
 842:	c985                	beqz	a1,872 <vprintf+0x220>
          putc(fd, *s);
 844:	855a                	mv	a0,s6
 846:	d51ff0ef          	jal	596 <putc>
        for(; *s; s++)
 84a:	0485                	addi	s1,s1,1
 84c:	0004c583          	lbu	a1,0(s1)
 850:	f9f5                	bnez	a1,844 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 852:	8bce                	mv	s7,s3
      state = 0;
 854:	4981                	li	s3,0
 856:	b581                	j	696 <vprintf+0x44>
          s = "(null)";
 858:	00000497          	auipc	s1,0x0
 85c:	55848493          	addi	s1,s1,1368 # db0 <malloc+0x3bc>
        for(; *s; s++)
 860:	02800593          	li	a1,40
 864:	b7c5                	j	844 <vprintf+0x1f2>
        putc(fd, '%');
 866:	85be                	mv	a1,a5
 868:	855a                	mv	a0,s6
 86a:	d2dff0ef          	jal	596 <putc>
      state = 0;
 86e:	4981                	li	s3,0
 870:	b51d                	j	696 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 872:	8bce                	mv	s7,s3
      state = 0;
 874:	4981                	li	s3,0
 876:	b505                	j	696 <vprintf+0x44>
 878:	6906                	ld	s2,64(sp)
 87a:	79e2                	ld	s3,56(sp)
 87c:	7a42                	ld	s4,48(sp)
 87e:	7aa2                	ld	s5,40(sp)
 880:	7b02                	ld	s6,32(sp)
 882:	6be2                	ld	s7,24(sp)
 884:	6c42                	ld	s8,16(sp)
    }
  }
}
 886:	60e6                	ld	ra,88(sp)
 888:	6446                	ld	s0,80(sp)
 88a:	64a6                	ld	s1,72(sp)
 88c:	6125                	addi	sp,sp,96
 88e:	8082                	ret
      if(c0 == 'd'){
 890:	06400713          	li	a4,100
 894:	e4e78fe3          	beq	a5,a4,6f2 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 898:	f9478693          	addi	a3,a5,-108
 89c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8a0:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8a2:	4701                	li	a4,0
      } else if(c0 == 'u'){
 8a4:	07500513          	li	a0,117
 8a8:	e8a78ce3          	beq	a5,a0,740 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 8ac:	f8b60513          	addi	a0,a2,-117
 8b0:	e119                	bnez	a0,8b6 <vprintf+0x264>
 8b2:	ea0693e3          	bnez	a3,758 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8b6:	f8b58513          	addi	a0,a1,-117
 8ba:	e119                	bnez	a0,8c0 <vprintf+0x26e>
 8bc:	ea071be3          	bnez	a4,772 <vprintf+0x120>
      } else if(c0 == 'x'){
 8c0:	07800513          	li	a0,120
 8c4:	eca784e3          	beq	a5,a0,78c <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 8c8:	f8860613          	addi	a2,a2,-120
 8cc:	e219                	bnez	a2,8d2 <vprintf+0x280>
 8ce:	ec069be3          	bnez	a3,7a4 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8d2:	f8858593          	addi	a1,a1,-120
 8d6:	e199                	bnez	a1,8dc <vprintf+0x28a>
 8d8:	ee0713e3          	bnez	a4,7be <vprintf+0x16c>
      } else if(c0 == 'p'){
 8dc:	07000713          	li	a4,112
 8e0:	eee78ce3          	beq	a5,a4,7d8 <vprintf+0x186>
      } else if(c0 == 'c'){
 8e4:	06300713          	li	a4,99
 8e8:	f2e78ce3          	beq	a5,a4,820 <vprintf+0x1ce>
      } else if(c0 == 's'){
 8ec:	07300713          	li	a4,115
 8f0:	f4e782e3          	beq	a5,a4,834 <vprintf+0x1e2>
      } else if(c0 == '%'){
 8f4:	02500713          	li	a4,37
 8f8:	f6e787e3          	beq	a5,a4,866 <vprintf+0x214>
        putc(fd, '%');
 8fc:	02500593          	li	a1,37
 900:	855a                	mv	a0,s6
 902:	c95ff0ef          	jal	596 <putc>
        putc(fd, c0);
 906:	85a6                	mv	a1,s1
 908:	855a                	mv	a0,s6
 90a:	c8dff0ef          	jal	596 <putc>
      state = 0;
 90e:	4981                	li	s3,0
 910:	b359                	j	696 <vprintf+0x44>

0000000000000912 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 912:	715d                	addi	sp,sp,-80
 914:	ec06                	sd	ra,24(sp)
 916:	e822                	sd	s0,16(sp)
 918:	1000                	addi	s0,sp,32
 91a:	e010                	sd	a2,0(s0)
 91c:	e414                	sd	a3,8(s0)
 91e:	e818                	sd	a4,16(s0)
 920:	ec1c                	sd	a5,24(s0)
 922:	03043023          	sd	a6,32(s0)
 926:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 92a:	8622                	mv	a2,s0
 92c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 930:	d23ff0ef          	jal	652 <vprintf>
}
 934:	60e2                	ld	ra,24(sp)
 936:	6442                	ld	s0,16(sp)
 938:	6161                	addi	sp,sp,80
 93a:	8082                	ret

000000000000093c <printf>:

void
printf(const char *fmt, ...)
{
 93c:	711d                	addi	sp,sp,-96
 93e:	ec06                	sd	ra,24(sp)
 940:	e822                	sd	s0,16(sp)
 942:	1000                	addi	s0,sp,32
 944:	e40c                	sd	a1,8(s0)
 946:	e810                	sd	a2,16(s0)
 948:	ec14                	sd	a3,24(s0)
 94a:	f018                	sd	a4,32(s0)
 94c:	f41c                	sd	a5,40(s0)
 94e:	03043823          	sd	a6,48(s0)
 952:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 956:	00840613          	addi	a2,s0,8
 95a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 95e:	85aa                	mv	a1,a0
 960:	4505                	li	a0,1
 962:	cf1ff0ef          	jal	652 <vprintf>
}
 966:	60e2                	ld	ra,24(sp)
 968:	6442                	ld	s0,16(sp)
 96a:	6125                	addi	sp,sp,96
 96c:	8082                	ret

000000000000096e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 96e:	1141                	addi	sp,sp,-16
 970:	e406                	sd	ra,8(sp)
 972:	e022                	sd	s0,0(sp)
 974:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 976:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97a:	00000797          	auipc	a5,0x0
 97e:	6867b783          	ld	a5,1670(a5) # 1000 <freep>
 982:	a039                	j	990 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 984:	6398                	ld	a4,0(a5)
 986:	00e7e463          	bltu	a5,a4,98e <free+0x20>
 98a:	00e6ea63          	bltu	a3,a4,99e <free+0x30>
{
 98e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 990:	fed7fae3          	bgeu	a5,a3,984 <free+0x16>
 994:	6398                	ld	a4,0(a5)
 996:	00e6e463          	bltu	a3,a4,99e <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 99a:	fee7eae3          	bltu	a5,a4,98e <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 99e:	ff852583          	lw	a1,-8(a0)
 9a2:	6390                	ld	a2,0(a5)
 9a4:	02059813          	slli	a6,a1,0x20
 9a8:	01c85713          	srli	a4,a6,0x1c
 9ac:	9736                	add	a4,a4,a3
 9ae:	02e60563          	beq	a2,a4,9d8 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9b2:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 9b6:	4790                	lw	a2,8(a5)
 9b8:	02061593          	slli	a1,a2,0x20
 9bc:	01c5d713          	srli	a4,a1,0x1c
 9c0:	973e                	add	a4,a4,a5
 9c2:	02e68263          	beq	a3,a4,9e6 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9c6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9c8:	00000717          	auipc	a4,0x0
 9cc:	62f73c23          	sd	a5,1592(a4) # 1000 <freep>
}
 9d0:	60a2                	ld	ra,8(sp)
 9d2:	6402                	ld	s0,0(sp)
 9d4:	0141                	addi	sp,sp,16
 9d6:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9d8:	4618                	lw	a4,8(a2)
 9da:	9f2d                	addw	a4,a4,a1
 9dc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9e0:	6398                	ld	a4,0(a5)
 9e2:	6310                	ld	a2,0(a4)
 9e4:	b7f9                	j	9b2 <free+0x44>
    p->s.size += bp->s.size;
 9e6:	ff852703          	lw	a4,-8(a0)
 9ea:	9f31                	addw	a4,a4,a2
 9ec:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9ee:	ff053683          	ld	a3,-16(a0)
 9f2:	bfd1                	j	9c6 <free+0x58>

00000000000009f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9f4:	7139                	addi	sp,sp,-64
 9f6:	fc06                	sd	ra,56(sp)
 9f8:	f822                	sd	s0,48(sp)
 9fa:	f04a                	sd	s2,32(sp)
 9fc:	ec4e                	sd	s3,24(sp)
 9fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a00:	02051993          	slli	s3,a0,0x20
 a04:	0209d993          	srli	s3,s3,0x20
 a08:	09bd                	addi	s3,s3,15
 a0a:	0049d993          	srli	s3,s3,0x4
 a0e:	2985                	addiw	s3,s3,1
 a10:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a12:	00000517          	auipc	a0,0x0
 a16:	5ee53503          	ld	a0,1518(a0) # 1000 <freep>
 a1a:	c905                	beqz	a0,a4a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a1e:	4798                	lw	a4,8(a5)
 a20:	09377663          	bgeu	a4,s3,aac <malloc+0xb8>
 a24:	f426                	sd	s1,40(sp)
 a26:	e852                	sd	s4,16(sp)
 a28:	e456                	sd	s5,8(sp)
 a2a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a2c:	8a4e                	mv	s4,s3
 a2e:	6705                	lui	a4,0x1
 a30:	00e9f363          	bgeu	s3,a4,a36 <malloc+0x42>
 a34:	6a05                	lui	s4,0x1
 a36:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a3a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a3e:	00000497          	auipc	s1,0x0
 a42:	5c248493          	addi	s1,s1,1474 # 1000 <freep>
  if(p == SBRK_ERROR)
 a46:	5afd                	li	s5,-1
 a48:	a83d                	j	a86 <malloc+0x92>
 a4a:	f426                	sd	s1,40(sp)
 a4c:	e852                	sd	s4,16(sp)
 a4e:	e456                	sd	s5,8(sp)
 a50:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a52:	00000797          	auipc	a5,0x0
 a56:	5be78793          	addi	a5,a5,1470 # 1010 <base>
 a5a:	00000717          	auipc	a4,0x0
 a5e:	5af73323          	sd	a5,1446(a4) # 1000 <freep>
 a62:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a64:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a68:	b7d1                	j	a2c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a6a:	6398                	ld	a4,0(a5)
 a6c:	e118                	sd	a4,0(a0)
 a6e:	a899                	j	ac4 <malloc+0xd0>
  hp->s.size = nu;
 a70:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a74:	0541                	addi	a0,a0,16
 a76:	ef9ff0ef          	jal	96e <free>
  return freep;
 a7a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a7c:	c125                	beqz	a0,adc <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a80:	4798                	lw	a4,8(a5)
 a82:	03277163          	bgeu	a4,s2,aa4 <malloc+0xb0>
    if(p == freep)
 a86:	6098                	ld	a4,0(s1)
 a88:	853e                	mv	a0,a5
 a8a:	fef71ae3          	bne	a4,a5,a7e <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a8e:	8552                	mv	a0,s4
 a90:	a23ff0ef          	jal	4b2 <sbrk>
  if(p == SBRK_ERROR)
 a94:	fd551ee3          	bne	a0,s5,a70 <malloc+0x7c>
        return 0;
 a98:	4501                	li	a0,0
 a9a:	74a2                	ld	s1,40(sp)
 a9c:	6a42                	ld	s4,16(sp)
 a9e:	6aa2                	ld	s5,8(sp)
 aa0:	6b02                	ld	s6,0(sp)
 aa2:	a03d                	j	ad0 <malloc+0xdc>
 aa4:	74a2                	ld	s1,40(sp)
 aa6:	6a42                	ld	s4,16(sp)
 aa8:	6aa2                	ld	s5,8(sp)
 aaa:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aac:	fae90fe3          	beq	s2,a4,a6a <malloc+0x76>
        p->s.size -= nunits;
 ab0:	4137073b          	subw	a4,a4,s3
 ab4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ab6:	02071693          	slli	a3,a4,0x20
 aba:	01c6d713          	srli	a4,a3,0x1c
 abe:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ac0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ac4:	00000717          	auipc	a4,0x0
 ac8:	52a73e23          	sd	a0,1340(a4) # 1000 <freep>
      return (void*)(p + 1);
 acc:	01078513          	addi	a0,a5,16
  }
}
 ad0:	70e2                	ld	ra,56(sp)
 ad2:	7442                	ld	s0,48(sp)
 ad4:	7902                	ld	s2,32(sp)
 ad6:	69e2                	ld	s3,24(sp)
 ad8:	6121                	addi	sp,sp,64
 ada:	8082                	ret
 adc:	74a2                	ld	s1,40(sp)
 ade:	6a42                	ld	s4,16(sp)
 ae0:	6aa2                	ld	s5,8(sp)
 ae2:	6b02                	ld	s6,0(sp)
 ae4:	b7f5                	j	ad0 <malloc+0xdc>
