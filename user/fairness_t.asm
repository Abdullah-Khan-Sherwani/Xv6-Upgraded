
user/_fairness_t:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Long-running fairness test: Multiple workloads competing
// Tests that boosting prevents starvation over extended period
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
  int cpu_pid, io_pid, mixed_pid;
  
  printf("=== Long-Running Fairness Test (Week 3) ===\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	b6650513          	addi	a0,a0,-1178 # b80 <malloc+0xea>
  22:	1bb000ef          	jal	ra,9dc <printf>
  printf("Running 3 different workloads for ~200 ticks\n");
  26:	00001517          	auipc	a0,0x1
  2a:	b8a50513          	addi	a0,a0,-1142 # bb0 <malloc+0x11a>
  2e:	1af000ef          	jal	ra,9dc <printf>
  printf("  1. Pure CPU-bound (should demote but get boosted)\n");
  32:	00001517          	auipc	a0,0x1
  36:	bae50513          	addi	a0,a0,-1106 # be0 <malloc+0x14a>
  3a:	1a3000ef          	jal	ra,9dc <printf>
  printf("  2. Pure I/O-bound (should stay high priority)\n");
  3e:	00001517          	auipc	a0,0x1
  42:	bda50513          	addi	a0,a0,-1062 # c18 <malloc+0x182>
  46:	197000ef          	jal	ra,9dc <printf>
  printf("  3. Mixed workload\n\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	c0650513          	addi	a0,a0,-1018 # c50 <malloc+0x1ba>
  52:	18b000ef          	jal	ra,9dc <printf>
  
  // Process 1: Pure CPU-bound
  cpu_pid = fork();
  56:	552000ef          	jal	ra,5a8 <fork>
  if(cpu_pid == 0) {
  5a:	0e051963          	bnez	a0,14c <main+0x14c>
  5e:	8aaa                	mv	s5,a0
    struct procinfo info;
    volatile int dummy = 0;
  60:	f8042623          	sw	zero,-116(s0)
    int boost_count = 0;
    int prev_priority = 0;
    
    printf("[CPU-BOUND] Starting...\n");
  64:	00001517          	auipc	a0,0x1
  68:	c0450513          	addi	a0,a0,-1020 # c68 <malloc+0x1d2>
  6c:	171000ef          	jal	ra,9dc <printf>
    
    for(int iter = 0; iter < 80; iter++) {
  70:	89d6                	mv	s3,s5
    int prev_priority = 0;
  72:	8a56                	mv	s4,s5
      // Heavy computation
      for(long j = 0; j < 8000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
  74:	000f4937          	lui	s2,0xf4
  78:	2409091b          	addiw	s2,s2,576
      for(long j = 0; j < 8000000; j++) {
  7c:	007a14b7          	lui	s1,0x7a1
  80:	20048493          	addi	s1,s1,512 # 7a1200 <base+0x7a01f0>
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
                 boost_count, uptime(), prev_priority, info.priority);
        }
        prev_priority = info.priority;
        
        if(iter % 20 == 0) {
  84:	4bd1                	li	s7,20
          printf("[CPU-BOUND] Tick %d: Q%d (slices=%d)\n", 
  86:	00001c97          	auipc	s9,0x1
  8a:	c3ac8c93          	addi	s9,s9,-966 # cc0 <malloc+0x22a>
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
  8e:	00001c17          	auipc	s8,0x1
  92:	bfac0c13          	addi	s8,s8,-1030 # c88 <malloc+0x1f2>
    for(int iter = 0; iter < 80; iter++) {
  96:	05000b13          	li	s6,80
  9a:	a005                	j	ba <main+0xba>
          boost_count++;
  9c:	2a85                	addiw	s5,s5,1
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
  9e:	5aa000ef          	jal	ra,648 <uptime>
  a2:	862a                	mv	a2,a0
  a4:	f9842703          	lw	a4,-104(s0)
  a8:	86d2                	mv	a3,s4
  aa:	85d6                	mv	a1,s5
  ac:	8562                	mv	a0,s8
  ae:	12f000ef          	jal	ra,9dc <printf>
  b2:	a825                	j	ea <main+0xea>
    for(int iter = 0; iter < 80; iter++) {
  b4:	2985                	addiw	s3,s3,1
  b6:	05698a63          	beq	s3,s6,10a <main+0x10a>
      for(long j = 0; j < 8000000; j++) {
  ba:	4781                	li	a5,0
        dummy = dummy + j;
  bc:	f8c42703          	lw	a4,-116(s0)
  c0:	9f3d                	addw	a4,a4,a5
  c2:	f8e42623          	sw	a4,-116(s0)
        dummy = dummy % 1000000;
  c6:	f8c42703          	lw	a4,-116(s0)
  ca:	0327673b          	remw	a4,a4,s2
  ce:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 8000000; j++) {
  d2:	0785                	addi	a5,a5,1
  d4:	fe9794e3          	bne	a5,s1,bc <main+0xbc>
      if(getprocinfo(&info) == 0) {
  d8:	f9040513          	addi	a0,s0,-112
  dc:	574000ef          	jal	ra,650 <getprocinfo>
  e0:	f971                	bnez	a0,b4 <main+0xb4>
        if(info.priority < prev_priority) {
  e2:	f9842783          	lw	a5,-104(s0)
  e6:	fb47cbe3          	blt	a5,s4,9c <main+0x9c>
        prev_priority = info.priority;
  ea:	f9842a03          	lw	s4,-104(s0)
        if(iter % 20 == 0) {
  ee:	0379e7bb          	remw	a5,s3,s7
  f2:	f3e9                	bnez	a5,b4 <main+0xb4>
          printf("[CPU-BOUND] Tick %d: Q%d (slices=%d)\n", 
  f4:	554000ef          	jal	ra,648 <uptime>
  f8:	85aa                	mv	a1,a0
  fa:	f9c42683          	lw	a3,-100(s0)
  fe:	f9842603          	lw	a2,-104(s0)
 102:	8566                	mv	a0,s9
 104:	0d9000ef          	jal	ra,9dc <printf>
 108:	b775                	j	b4 <main+0xb4>
                 uptime(), info.priority, info.time_slices);
        }
      }
    }
    
    if(getprocinfo(&info) == 0) {
 10a:	f9040513          	addi	a0,s0,-112
 10e:	542000ef          	jal	ra,650 <getprocinfo>
 112:	c501                	beqz	a0,11a <main+0x11a>
        printf("[CPU-BOUND] ✓ Received at least one boost!\n");
      } else {
        printf("[CPU-BOUND] ✗ No boosts detected (problem!)\n");
      }
    }
    exit(0);
 114:	4501                	li	a0,0
 116:	49a000ef          	jal	ra,5b0 <exit>
      printf("[CPU-BOUND] FINAL: Q%d, %d boosts detected\n", 
 11a:	8656                	mv	a2,s5
 11c:	f9842583          	lw	a1,-104(s0)
 120:	00001517          	auipc	a0,0x1
 124:	bc850513          	addi	a0,a0,-1080 # ce8 <malloc+0x252>
 128:	0b5000ef          	jal	ra,9dc <printf>
      if(boost_count >= 1) {
 12c:	01505963          	blez	s5,13e <main+0x13e>
        printf("[CPU-BOUND] ✓ Received at least one boost!\n");
 130:	00001517          	auipc	a0,0x1
 134:	be850513          	addi	a0,a0,-1048 # d18 <malloc+0x282>
 138:	0a5000ef          	jal	ra,9dc <printf>
 13c:	bfe1                	j	114 <main+0x114>
        printf("[CPU-BOUND] ✗ No boosts detected (problem!)\n");
 13e:	00001517          	auipc	a0,0x1
 142:	c0a50513          	addi	a0,a0,-1014 # d48 <malloc+0x2b2>
 146:	097000ef          	jal	ra,9dc <printf>
 14a:	b7e9                	j	114 <main+0x114>
  }
  
  pause(2);
 14c:	4509                	li	a0,2
 14e:	4f2000ef          	jal	ra,640 <pause>
  
  // Process 2: I/O-bound
  io_pid = fork();
 152:	456000ef          	jal	ra,5a8 <fork>
 156:	892a                	mv	s2,a0
  if(io_pid == 0) {
 158:	e15d                	bnez	a0,1fe <main+0x1fe>
    struct procinfo info;
    volatile int dummy = 0;
 15a:	f8042623          	sw	zero,-116(s0)
    
    printf("[I/O-BOUND] Starting...\n");
 15e:	00001517          	auipc	a0,0x1
 162:	c1a50513          	addi	a0,a0,-998 # d78 <malloc+0x2e2>
 166:	077000ef          	jal	ra,9dc <printf>
    
    for(int iter = 0; iter < 100; iter++) {
      // Brief work
      for(long j = 0; j < 1000000; j++) {
 16a:	000f44b7          	lui	s1,0xf4
 16e:	24048493          	addi	s1,s1,576 # f4240 <base+0xf3230>
      }
      
      // Yield frequently
      pause(2);
      
      if(iter % 25 == 0 && getprocinfo(&info) == 0) {
 172:	4a65                	li	s4,25
        printf("[I/O-BOUND] Tick %d: Q%d (slices=%d)\n", 
 174:	00001a97          	auipc	s5,0x1
 178:	c24a8a93          	addi	s5,s5,-988 # d98 <malloc+0x302>
    for(int iter = 0; iter < 100; iter++) {
 17c:	06400993          	li	s3,100
 180:	a021                	j	188 <main+0x188>
 182:	2905                	addiw	s2,s2,1
 184:	05390163          	beq	s2,s3,1c6 <main+0x1c6>
      for(long j = 0; j < 1000000; j++) {
 188:	4781                	li	a5,0
        dummy = dummy + j;
 18a:	f8c42703          	lw	a4,-116(s0)
 18e:	9f3d                	addw	a4,a4,a5
 190:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 1000000; j++) {
 194:	0785                	addi	a5,a5,1
 196:	fe979ae3          	bne	a5,s1,18a <main+0x18a>
      pause(2);
 19a:	4509                	li	a0,2
 19c:	4a4000ef          	jal	ra,640 <pause>
      if(iter % 25 == 0 && getprocinfo(&info) == 0) {
 1a0:	034967bb          	remw	a5,s2,s4
 1a4:	fff9                	bnez	a5,182 <main+0x182>
 1a6:	f9040513          	addi	a0,s0,-112
 1aa:	4a6000ef          	jal	ra,650 <getprocinfo>
 1ae:	f971                	bnez	a0,182 <main+0x182>
        printf("[I/O-BOUND] Tick %d: Q%d (slices=%d)\n", 
 1b0:	498000ef          	jal	ra,648 <uptime>
 1b4:	85aa                	mv	a1,a0
 1b6:	f9c42683          	lw	a3,-100(s0)
 1ba:	f9842603          	lw	a2,-104(s0)
 1be:	8556                	mv	a0,s5
 1c0:	01d000ef          	jal	ra,9dc <printf>
 1c4:	bf7d                	j	182 <main+0x182>
               uptime(), info.priority, info.time_slices);
      }
    }
    
    if(getprocinfo(&info) == 0) {
 1c6:	f9040513          	addi	a0,s0,-112
 1ca:	486000ef          	jal	ra,650 <getprocinfo>
 1ce:	c501                	beqz	a0,1d6 <main+0x1d6>
      printf("[I/O-BOUND] FINAL: Q%d\n", info.priority);
      if(info.priority <= 1) {
        printf("[I/O-BOUND] ✓ Maintained high priority\n");
      }
    }
    exit(0);
 1d0:	4501                	li	a0,0
 1d2:	3de000ef          	jal	ra,5b0 <exit>
      printf("[I/O-BOUND] FINAL: Q%d\n", info.priority);
 1d6:	f9842583          	lw	a1,-104(s0)
 1da:	00001517          	auipc	a0,0x1
 1de:	be650513          	addi	a0,a0,-1050 # dc0 <malloc+0x32a>
 1e2:	7fa000ef          	jal	ra,9dc <printf>
      if(info.priority <= 1) {
 1e6:	f9842703          	lw	a4,-104(s0)
 1ea:	4785                	li	a5,1
 1ec:	fee7c2e3          	blt	a5,a4,1d0 <main+0x1d0>
        printf("[I/O-BOUND] ✓ Maintained high priority\n");
 1f0:	00001517          	auipc	a0,0x1
 1f4:	be850513          	addi	a0,a0,-1048 # dd8 <malloc+0x342>
 1f8:	7e4000ef          	jal	ra,9dc <printf>
 1fc:	bfd1                	j	1d0 <main+0x1d0>
  }
  
  pause(2);
 1fe:	4509                	li	a0,2
 200:	440000ef          	jal	ra,640 <pause>
  
  // Process 3: Mixed workload
  mixed_pid = fork();
 204:	3a4000ef          	jal	ra,5a8 <fork>
 208:	89aa                	mv	s3,a0
  if(mixed_pid == 0) {
 20a:	e155                	bnez	a0,2ae <main+0x2ae>
    struct procinfo info;
    volatile int dummy = 0;
 20c:	f8042623          	sw	zero,-116(s0)
    
    printf("[MIXED] Starting...\n");
 210:	00001517          	auipc	a0,0x1
 214:	bf850513          	addi	a0,a0,-1032 # e08 <malloc+0x372>
 218:	7c4000ef          	jal	ra,9dc <printf>
    
    for(int iter = 0; iter < 50; iter++) {
      // Alternate: CPU burst then sleep
      for(long j = 0; j < 15000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
 21c:	000f4937          	lui	s2,0xf4
 220:	2409091b          	addiw	s2,s2,576
      for(long j = 0; j < 15000000; j++) {
 224:	00e4e4b7          	lui	s1,0xe4e
 228:	1c048493          	addi	s1,s1,448 # e4e1c0 <base+0xe4d1b0>
      }
      
      pause(3);
      
      if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 22c:	4b3d                	li	s6,15
        printf("[MIXED] Tick %d: Q%d (slices=%d)\n", 
 22e:	00001a97          	auipc	s5,0x1
 232:	bf2a8a93          	addi	s5,s5,-1038 # e20 <malloc+0x38a>
    for(int iter = 0; iter < 50; iter++) {
 236:	03200a13          	li	s4,50
 23a:	a021                	j	242 <main+0x242>
 23c:	2985                	addiw	s3,s3,1
 23e:	05498763          	beq	s3,s4,28c <main+0x28c>
      for(long j = 0; j < 15000000; j++) {
 242:	4781                	li	a5,0
        dummy = dummy + j;
 244:	f8c42703          	lw	a4,-116(s0)
 248:	9f3d                	addw	a4,a4,a5
 24a:	f8e42623          	sw	a4,-116(s0)
        dummy = dummy % 1000000;
 24e:	f8c42703          	lw	a4,-116(s0)
 252:	0327673b          	remw	a4,a4,s2
 256:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 15000000; j++) {
 25a:	0785                	addi	a5,a5,1
 25c:	fe9794e3          	bne	a5,s1,244 <main+0x244>
      pause(3);
 260:	450d                	li	a0,3
 262:	3de000ef          	jal	ra,640 <pause>
      if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 266:	0369e7bb          	remw	a5,s3,s6
 26a:	fbe9                	bnez	a5,23c <main+0x23c>
 26c:	f9040513          	addi	a0,s0,-112
 270:	3e0000ef          	jal	ra,650 <getprocinfo>
 274:	f561                	bnez	a0,23c <main+0x23c>
        printf("[MIXED] Tick %d: Q%d (slices=%d)\n", 
 276:	3d2000ef          	jal	ra,648 <uptime>
 27a:	85aa                	mv	a1,a0
 27c:	f9c42683          	lw	a3,-100(s0)
 280:	f9842603          	lw	a2,-104(s0)
 284:	8556                	mv	a0,s5
 286:	756000ef          	jal	ra,9dc <printf>
 28a:	bf4d                	j	23c <main+0x23c>
               uptime(), info.priority, info.time_slices);
      }
    }
    
    if(getprocinfo(&info) == 0) {
 28c:	f9040513          	addi	a0,s0,-112
 290:	3c0000ef          	jal	ra,650 <getprocinfo>
 294:	c501                	beqz	a0,29c <main+0x29c>
      printf("[MIXED] FINAL: Q%d\n", info.priority);
    }
    exit(0);
 296:	4501                	li	a0,0
 298:	318000ef          	jal	ra,5b0 <exit>
      printf("[MIXED] FINAL: Q%d\n", info.priority);
 29c:	f9842583          	lw	a1,-104(s0)
 2a0:	00001517          	auipc	a0,0x1
 2a4:	ba850513          	addi	a0,a0,-1112 # e48 <malloc+0x3b2>
 2a8:	734000ef          	jal	ra,9dc <printf>
 2ac:	b7ed                	j	296 <main+0x296>
  }
  
  // Parent waits
  printf("\n[Parent] All processes running...\n");
 2ae:	00001517          	auipc	a0,0x1
 2b2:	bb250513          	addi	a0,a0,-1102 # e60 <malloc+0x3ca>
 2b6:	726000ef          	jal	ra,9dc <printf>
  wait(0);
 2ba:	4501                	li	a0,0
 2bc:	2fc000ef          	jal	ra,5b8 <wait>
  wait(0);
 2c0:	4501                	li	a0,0
 2c2:	2f6000ef          	jal	ra,5b8 <wait>
  wait(0);
 2c6:	4501                	li	a0,0
 2c8:	2f0000ef          	jal	ra,5b8 <wait>
  
  printf("\n=== Fairness Test Complete ===\n");
 2cc:	00001517          	auipc	a0,0x1
 2d0:	bbc50513          	addi	a0,a0,-1092 # e88 <malloc+0x3f2>
 2d4:	708000ef          	jal	ra,9dc <printf>
  printf("All three workloads completed successfully!\n");
 2d8:	00001517          	auipc	a0,0x1
 2dc:	bd850513          	addi	a0,a0,-1064 # eb0 <malloc+0x41a>
 2e0:	6fc000ef          	jal	ra,9dc <printf>
  printf("Expected results:\n");
 2e4:	00001517          	auipc	a0,0x1
 2e8:	bfc50513          	addi	a0,a0,-1028 # ee0 <malloc+0x44a>
 2ec:	6f0000ef          	jal	ra,9dc <printf>
  printf("  - CPU-bound: Experienced boosts (no starvation)\n");
 2f0:	00001517          	auipc	a0,0x1
 2f4:	c0850513          	addi	a0,a0,-1016 # ef8 <malloc+0x462>
 2f8:	6e4000ef          	jal	ra,9dc <printf>
  printf("  - I/O-bound: Stayed in high priority queues\n");
 2fc:	00001517          	auipc	a0,0x1
 300:	c3450513          	addi	a0,a0,-972 # f30 <malloc+0x49a>
 304:	6d8000ef          	jal	ra,9dc <printf>
  printf("  - Mixed: Balanced between Q1-Q2\n");
 308:	00001517          	auipc	a0,0x1
 30c:	c5850513          	addi	a0,a0,-936 # f60 <malloc+0x4ca>
 310:	6cc000ef          	jal	ra,9dc <printf>
  
  exit(0);
 314:	4501                	li	a0,0
 316:	29a000ef          	jal	ra,5b0 <exit>

000000000000031a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e406                	sd	ra,8(sp)
 31e:	e022                	sd	s0,0(sp)
 320:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 322:	cdfff0ef          	jal	ra,0 <main>
  exit(r);
 326:	28a000ef          	jal	ra,5b0 <exit>

000000000000032a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 330:	87aa                	mv	a5,a0
 332:	0585                	addi	a1,a1,1
 334:	0785                	addi	a5,a5,1
 336:	fff5c703          	lbu	a4,-1(a1)
 33a:	fee78fa3          	sb	a4,-1(a5)
 33e:	fb75                	bnez	a4,332 <strcpy+0x8>
    ;
  return os;
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 34c:	00054783          	lbu	a5,0(a0)
 350:	cb91                	beqz	a5,364 <strcmp+0x1e>
 352:	0005c703          	lbu	a4,0(a1)
 356:	00f71763          	bne	a4,a5,364 <strcmp+0x1e>
    p++, q++;
 35a:	0505                	addi	a0,a0,1
 35c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 35e:	00054783          	lbu	a5,0(a0)
 362:	fbe5                	bnez	a5,352 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 364:	0005c503          	lbu	a0,0(a1)
}
 368:	40a7853b          	subw	a0,a5,a0
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <strlen>:

uint
strlen(const char *s)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 378:	00054783          	lbu	a5,0(a0)
 37c:	cf91                	beqz	a5,398 <strlen+0x26>
 37e:	0505                	addi	a0,a0,1
 380:	87aa                	mv	a5,a0
 382:	4685                	li	a3,1
 384:	9e89                	subw	a3,a3,a0
 386:	00f6853b          	addw	a0,a3,a5
 38a:	0785                	addi	a5,a5,1
 38c:	fff7c703          	lbu	a4,-1(a5)
 390:	fb7d                	bnez	a4,386 <strlen+0x14>
    ;
  return n;
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  for(n = 0; s[n]; n++)
 398:	4501                	li	a0,0
 39a:	bfe5                	j	392 <strlen+0x20>

000000000000039c <memset>:

void*
memset(void *dst, int c, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e422                	sd	s0,8(sp)
 3a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3a2:	ca19                	beqz	a2,3b8 <memset+0x1c>
 3a4:	87aa                	mv	a5,a0
 3a6:	1602                	slli	a2,a2,0x20
 3a8:	9201                	srli	a2,a2,0x20
 3aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3b2:	0785                	addi	a5,a5,1
 3b4:	fee79de3          	bne	a5,a4,3ae <memset+0x12>
  }
  return dst;
}
 3b8:	6422                	ld	s0,8(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret

00000000000003be <strchr>:

char*
strchr(const char *s, char c)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e422                	sd	s0,8(sp)
 3c2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3c4:	00054783          	lbu	a5,0(a0)
 3c8:	cb99                	beqz	a5,3de <strchr+0x20>
    if(*s == c)
 3ca:	00f58763          	beq	a1,a5,3d8 <strchr+0x1a>
  for(; *s; s++)
 3ce:	0505                	addi	a0,a0,1
 3d0:	00054783          	lbu	a5,0(a0)
 3d4:	fbfd                	bnez	a5,3ca <strchr+0xc>
      return (char*)s;
  return 0;
 3d6:	4501                	li	a0,0
}
 3d8:	6422                	ld	s0,8(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret
  return 0;
 3de:	4501                	li	a0,0
 3e0:	bfe5                	j	3d8 <strchr+0x1a>

00000000000003e2 <gets>:

char*
gets(char *buf, int max)
{
 3e2:	711d                	addi	sp,sp,-96
 3e4:	ec86                	sd	ra,88(sp)
 3e6:	e8a2                	sd	s0,80(sp)
 3e8:	e4a6                	sd	s1,72(sp)
 3ea:	e0ca                	sd	s2,64(sp)
 3ec:	fc4e                	sd	s3,56(sp)
 3ee:	f852                	sd	s4,48(sp)
 3f0:	f456                	sd	s5,40(sp)
 3f2:	f05a                	sd	s6,32(sp)
 3f4:	ec5e                	sd	s7,24(sp)
 3f6:	1080                	addi	s0,sp,96
 3f8:	8baa                	mv	s7,a0
 3fa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3fc:	892a                	mv	s2,a0
 3fe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 400:	4aa9                	li	s5,10
 402:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 404:	89a6                	mv	s3,s1
 406:	2485                	addiw	s1,s1,1
 408:	0344d663          	bge	s1,s4,434 <gets+0x52>
    cc = read(0, &c, 1);
 40c:	4605                	li	a2,1
 40e:	faf40593          	addi	a1,s0,-81
 412:	4501                	li	a0,0
 414:	1b4000ef          	jal	ra,5c8 <read>
    if(cc < 1)
 418:	00a05e63          	blez	a0,434 <gets+0x52>
    buf[i++] = c;
 41c:	faf44783          	lbu	a5,-81(s0)
 420:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 424:	01578763          	beq	a5,s5,432 <gets+0x50>
 428:	0905                	addi	s2,s2,1
 42a:	fd679de3          	bne	a5,s6,404 <gets+0x22>
  for(i=0; i+1 < max; ){
 42e:	89a6                	mv	s3,s1
 430:	a011                	j	434 <gets+0x52>
 432:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 434:	99de                	add	s3,s3,s7
 436:	00098023          	sb	zero,0(s3)
  return buf;
}
 43a:	855e                	mv	a0,s7
 43c:	60e6                	ld	ra,88(sp)
 43e:	6446                	ld	s0,80(sp)
 440:	64a6                	ld	s1,72(sp)
 442:	6906                	ld	s2,64(sp)
 444:	79e2                	ld	s3,56(sp)
 446:	7a42                	ld	s4,48(sp)
 448:	7aa2                	ld	s5,40(sp)
 44a:	7b02                	ld	s6,32(sp)
 44c:	6be2                	ld	s7,24(sp)
 44e:	6125                	addi	sp,sp,96
 450:	8082                	ret

0000000000000452 <stat>:

int
stat(const char *n, struct stat *st)
{
 452:	1101                	addi	sp,sp,-32
 454:	ec06                	sd	ra,24(sp)
 456:	e822                	sd	s0,16(sp)
 458:	e426                	sd	s1,8(sp)
 45a:	e04a                	sd	s2,0(sp)
 45c:	1000                	addi	s0,sp,32
 45e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 460:	4581                	li	a1,0
 462:	18e000ef          	jal	ra,5f0 <open>
  if(fd < 0)
 466:	02054163          	bltz	a0,488 <stat+0x36>
 46a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 46c:	85ca                	mv	a1,s2
 46e:	19a000ef          	jal	ra,608 <fstat>
 472:	892a                	mv	s2,a0
  close(fd);
 474:	8526                	mv	a0,s1
 476:	162000ef          	jal	ra,5d8 <close>
  return r;
}
 47a:	854a                	mv	a0,s2
 47c:	60e2                	ld	ra,24(sp)
 47e:	6442                	ld	s0,16(sp)
 480:	64a2                	ld	s1,8(sp)
 482:	6902                	ld	s2,0(sp)
 484:	6105                	addi	sp,sp,32
 486:	8082                	ret
    return -1;
 488:	597d                	li	s2,-1
 48a:	bfc5                	j	47a <stat+0x28>

000000000000048c <atoi>:

int
atoi(const char *s)
{
 48c:	1141                	addi	sp,sp,-16
 48e:	e422                	sd	s0,8(sp)
 490:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 492:	00054603          	lbu	a2,0(a0)
 496:	fd06079b          	addiw	a5,a2,-48
 49a:	0ff7f793          	andi	a5,a5,255
 49e:	4725                	li	a4,9
 4a0:	02f76963          	bltu	a4,a5,4d2 <atoi+0x46>
 4a4:	86aa                	mv	a3,a0
  n = 0;
 4a6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4a8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4aa:	0685                	addi	a3,a3,1
 4ac:	0025179b          	slliw	a5,a0,0x2
 4b0:	9fa9                	addw	a5,a5,a0
 4b2:	0017979b          	slliw	a5,a5,0x1
 4b6:	9fb1                	addw	a5,a5,a2
 4b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4bc:	0006c603          	lbu	a2,0(a3)
 4c0:	fd06071b          	addiw	a4,a2,-48
 4c4:	0ff77713          	andi	a4,a4,255
 4c8:	fee5f1e3          	bgeu	a1,a4,4aa <atoi+0x1e>
  return n;
}
 4cc:	6422                	ld	s0,8(sp)
 4ce:	0141                	addi	sp,sp,16
 4d0:	8082                	ret
  n = 0;
 4d2:	4501                	li	a0,0
 4d4:	bfe5                	j	4cc <atoi+0x40>

00000000000004d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4d6:	1141                	addi	sp,sp,-16
 4d8:	e422                	sd	s0,8(sp)
 4da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4dc:	02b57463          	bgeu	a0,a1,504 <memmove+0x2e>
    while(n-- > 0)
 4e0:	00c05f63          	blez	a2,4fe <memmove+0x28>
 4e4:	1602                	slli	a2,a2,0x20
 4e6:	9201                	srli	a2,a2,0x20
 4e8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4ec:	872a                	mv	a4,a0
      *dst++ = *src++;
 4ee:	0585                	addi	a1,a1,1
 4f0:	0705                	addi	a4,a4,1
 4f2:	fff5c683          	lbu	a3,-1(a1)
 4f6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4fa:	fee79ae3          	bne	a5,a4,4ee <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4fe:	6422                	ld	s0,8(sp)
 500:	0141                	addi	sp,sp,16
 502:	8082                	ret
    dst += n;
 504:	00c50733          	add	a4,a0,a2
    src += n;
 508:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 50a:	fec05ae3          	blez	a2,4fe <memmove+0x28>
 50e:	fff6079b          	addiw	a5,a2,-1
 512:	1782                	slli	a5,a5,0x20
 514:	9381                	srli	a5,a5,0x20
 516:	fff7c793          	not	a5,a5
 51a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 51c:	15fd                	addi	a1,a1,-1
 51e:	177d                	addi	a4,a4,-1
 520:	0005c683          	lbu	a3,0(a1)
 524:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 528:	fee79ae3          	bne	a5,a4,51c <memmove+0x46>
 52c:	bfc9                	j	4fe <memmove+0x28>

000000000000052e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 52e:	1141                	addi	sp,sp,-16
 530:	e422                	sd	s0,8(sp)
 532:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 534:	ca05                	beqz	a2,564 <memcmp+0x36>
 536:	fff6069b          	addiw	a3,a2,-1
 53a:	1682                	slli	a3,a3,0x20
 53c:	9281                	srli	a3,a3,0x20
 53e:	0685                	addi	a3,a3,1
 540:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 542:	00054783          	lbu	a5,0(a0)
 546:	0005c703          	lbu	a4,0(a1)
 54a:	00e79863          	bne	a5,a4,55a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 54e:	0505                	addi	a0,a0,1
    p2++;
 550:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 552:	fed518e3          	bne	a0,a3,542 <memcmp+0x14>
  }
  return 0;
 556:	4501                	li	a0,0
 558:	a019                	j	55e <memcmp+0x30>
      return *p1 - *p2;
 55a:	40e7853b          	subw	a0,a5,a4
}
 55e:	6422                	ld	s0,8(sp)
 560:	0141                	addi	sp,sp,16
 562:	8082                	ret
  return 0;
 564:	4501                	li	a0,0
 566:	bfe5                	j	55e <memcmp+0x30>

0000000000000568 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 568:	1141                	addi	sp,sp,-16
 56a:	e406                	sd	ra,8(sp)
 56c:	e022                	sd	s0,0(sp)
 56e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 570:	f67ff0ef          	jal	ra,4d6 <memmove>
}
 574:	60a2                	ld	ra,8(sp)
 576:	6402                	ld	s0,0(sp)
 578:	0141                	addi	sp,sp,16
 57a:	8082                	ret

000000000000057c <sbrk>:

char *
sbrk(int n) {
 57c:	1141                	addi	sp,sp,-16
 57e:	e406                	sd	ra,8(sp)
 580:	e022                	sd	s0,0(sp)
 582:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 584:	4585                	li	a1,1
 586:	0b2000ef          	jal	ra,638 <sys_sbrk>
}
 58a:	60a2                	ld	ra,8(sp)
 58c:	6402                	ld	s0,0(sp)
 58e:	0141                	addi	sp,sp,16
 590:	8082                	ret

0000000000000592 <sbrklazy>:

char *
sbrklazy(int n) {
 592:	1141                	addi	sp,sp,-16
 594:	e406                	sd	ra,8(sp)
 596:	e022                	sd	s0,0(sp)
 598:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 59a:	4589                	li	a1,2
 59c:	09c000ef          	jal	ra,638 <sys_sbrk>
}
 5a0:	60a2                	ld	ra,8(sp)
 5a2:	6402                	ld	s0,0(sp)
 5a4:	0141                	addi	sp,sp,16
 5a6:	8082                	ret

00000000000005a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5a8:	4885                	li	a7,1
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5b0:	4889                	li	a7,2
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b8:	488d                	li	a7,3
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5c0:	4891                	li	a7,4
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <read>:
.global read
read:
 li a7, SYS_read
 5c8:	4895                	li	a7,5
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <write>:
.global write
write:
 li a7, SYS_write
 5d0:	48c1                	li	a7,16
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <close>:
.global close
close:
 li a7, SYS_close
 5d8:	48d5                	li	a7,21
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5e0:	4899                	li	a7,6
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e8:	489d                	li	a7,7
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <open>:
.global open
open:
 li a7, SYS_open
 5f0:	48bd                	li	a7,15
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f8:	48c5                	li	a7,17
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 600:	48c9                	li	a7,18
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 608:	48a1                	li	a7,8
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <link>:
.global link
link:
 li a7, SYS_link
 610:	48cd                	li	a7,19
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 618:	48d1                	li	a7,20
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 620:	48a5                	li	a7,9
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <dup>:
.global dup
dup:
 li a7, SYS_dup
 628:	48a9                	li	a7,10
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 630:	48ad                	li	a7,11
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 638:	48b1                	li	a7,12
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <pause>:
.global pause
pause:
 li a7, SYS_pause
 640:	48b5                	li	a7,13
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 648:	48b9                	li	a7,14
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 650:	48d9                	li	a7,22
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 658:	48dd                	li	a7,23
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 660:	1101                	addi	sp,sp,-32
 662:	ec06                	sd	ra,24(sp)
 664:	e822                	sd	s0,16(sp)
 666:	1000                	addi	s0,sp,32
 668:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 66c:	4605                	li	a2,1
 66e:	fef40593          	addi	a1,s0,-17
 672:	f5fff0ef          	jal	ra,5d0 <write>
}
 676:	60e2                	ld	ra,24(sp)
 678:	6442                	ld	s0,16(sp)
 67a:	6105                	addi	sp,sp,32
 67c:	8082                	ret

000000000000067e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 67e:	715d                	addi	sp,sp,-80
 680:	e486                	sd	ra,72(sp)
 682:	e0a2                	sd	s0,64(sp)
 684:	fc26                	sd	s1,56(sp)
 686:	f84a                	sd	s2,48(sp)
 688:	f44e                	sd	s3,40(sp)
 68a:	0880                	addi	s0,sp,80
 68c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 68e:	c299                	beqz	a3,694 <printint+0x16>
 690:	0805c163          	bltz	a1,712 <printint+0x94>
  neg = 0;
 694:	4881                	li	a7,0
 696:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 69a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 69c:	00001517          	auipc	a0,0x1
 6a0:	8f450513          	addi	a0,a0,-1804 # f90 <digits>
 6a4:	883e                	mv	a6,a5
 6a6:	2785                	addiw	a5,a5,1
 6a8:	02c5f733          	remu	a4,a1,a2
 6ac:	972a                	add	a4,a4,a0
 6ae:	00074703          	lbu	a4,0(a4)
 6b2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6b6:	872e                	mv	a4,a1
 6b8:	02c5d5b3          	divu	a1,a1,a2
 6bc:	0685                	addi	a3,a3,1
 6be:	fec773e3          	bgeu	a4,a2,6a4 <printint+0x26>
  if(neg)
 6c2:	00088b63          	beqz	a7,6d8 <printint+0x5a>
    buf[i++] = '-';
 6c6:	fd040713          	addi	a4,s0,-48
 6ca:	97ba                	add	a5,a5,a4
 6cc:	02d00713          	li	a4,45
 6d0:	fee78423          	sb	a4,-24(a5)
 6d4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 6d8:	02f05663          	blez	a5,704 <printint+0x86>
 6dc:	fb840713          	addi	a4,s0,-72
 6e0:	00f704b3          	add	s1,a4,a5
 6e4:	fff70993          	addi	s3,a4,-1
 6e8:	99be                	add	s3,s3,a5
 6ea:	37fd                	addiw	a5,a5,-1
 6ec:	1782                	slli	a5,a5,0x20
 6ee:	9381                	srli	a5,a5,0x20
 6f0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 6f4:	fff4c583          	lbu	a1,-1(s1)
 6f8:	854a                	mv	a0,s2
 6fa:	f67ff0ef          	jal	ra,660 <putc>
  while(--i >= 0)
 6fe:	14fd                	addi	s1,s1,-1
 700:	ff349ae3          	bne	s1,s3,6f4 <printint+0x76>
}
 704:	60a6                	ld	ra,72(sp)
 706:	6406                	ld	s0,64(sp)
 708:	74e2                	ld	s1,56(sp)
 70a:	7942                	ld	s2,48(sp)
 70c:	79a2                	ld	s3,40(sp)
 70e:	6161                	addi	sp,sp,80
 710:	8082                	ret
    x = -xx;
 712:	40b005b3          	neg	a1,a1
    neg = 1;
 716:	4885                	li	a7,1
    x = -xx;
 718:	bfbd                	j	696 <printint+0x18>

000000000000071a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 71a:	7119                	addi	sp,sp,-128
 71c:	fc86                	sd	ra,120(sp)
 71e:	f8a2                	sd	s0,112(sp)
 720:	f4a6                	sd	s1,104(sp)
 722:	f0ca                	sd	s2,96(sp)
 724:	ecce                	sd	s3,88(sp)
 726:	e8d2                	sd	s4,80(sp)
 728:	e4d6                	sd	s5,72(sp)
 72a:	e0da                	sd	s6,64(sp)
 72c:	fc5e                	sd	s7,56(sp)
 72e:	f862                	sd	s8,48(sp)
 730:	f466                	sd	s9,40(sp)
 732:	f06a                	sd	s10,32(sp)
 734:	ec6e                	sd	s11,24(sp)
 736:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 738:	0005c903          	lbu	s2,0(a1)
 73c:	24090c63          	beqz	s2,994 <vprintf+0x27a>
 740:	8b2a                	mv	s6,a0
 742:	8a2e                	mv	s4,a1
 744:	8bb2                	mv	s7,a2
  state = 0;
 746:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 748:	4481                	li	s1,0
 74a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 74c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 750:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 754:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 758:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 75c:	00001c97          	auipc	s9,0x1
 760:	834c8c93          	addi	s9,s9,-1996 # f90 <digits>
 764:	a005                	j	784 <vprintf+0x6a>
        putc(fd, c0);
 766:	85ca                	mv	a1,s2
 768:	855a                	mv	a0,s6
 76a:	ef7ff0ef          	jal	ra,660 <putc>
 76e:	a019                	j	774 <vprintf+0x5a>
    } else if(state == '%'){
 770:	03598263          	beq	s3,s5,794 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 774:	2485                	addiw	s1,s1,1
 776:	8726                	mv	a4,s1
 778:	009a07b3          	add	a5,s4,s1
 77c:	0007c903          	lbu	s2,0(a5)
 780:	20090a63          	beqz	s2,994 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 784:	0009079b          	sext.w	a5,s2
    if(state == 0){
 788:	fe0994e3          	bnez	s3,770 <vprintf+0x56>
      if(c0 == '%'){
 78c:	fd579de3          	bne	a5,s5,766 <vprintf+0x4c>
        state = '%';
 790:	89be                	mv	s3,a5
 792:	b7cd                	j	774 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 794:	c3c1                	beqz	a5,814 <vprintf+0xfa>
 796:	00ea06b3          	add	a3,s4,a4
 79a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 79e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 7a0:	c681                	beqz	a3,7a8 <vprintf+0x8e>
 7a2:	9752                	add	a4,a4,s4
 7a4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 7a8:	03878e63          	beq	a5,s8,7e4 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 7ac:	05a78863          	beq	a5,s10,7fc <vprintf+0xe2>
      } else if(c0 == 'u'){
 7b0:	0db78b63          	beq	a5,s11,886 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7b4:	07800713          	li	a4,120
 7b8:	10e78d63          	beq	a5,a4,8d2 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7bc:	07000713          	li	a4,112
 7c0:	14e78263          	beq	a5,a4,904 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7c4:	06300713          	li	a4,99
 7c8:	16e78f63          	beq	a5,a4,946 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 7cc:	07300713          	li	a4,115
 7d0:	18e78563          	beq	a5,a4,95a <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7d4:	05579063          	bne	a5,s5,814 <vprintf+0xfa>
        putc(fd, '%');
 7d8:	85d6                	mv	a1,s5
 7da:	855a                	mv	a0,s6
 7dc:	e85ff0ef          	jal	ra,660 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	bf49                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 7e4:	008b8913          	addi	s2,s7,8
 7e8:	4685                	li	a3,1
 7ea:	4629                	li	a2,10
 7ec:	000ba583          	lw	a1,0(s7)
 7f0:	855a                	mv	a0,s6
 7f2:	e8dff0ef          	jal	ra,67e <printint>
 7f6:	8bca                	mv	s7,s2
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	bfad                	j	774 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 7fc:	03868663          	beq	a3,s8,828 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 800:	05a68163          	beq	a3,s10,842 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 804:	09b68d63          	beq	a3,s11,89e <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 808:	03a68f63          	beq	a3,s10,846 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 80c:	07800793          	li	a5,120
 810:	0cf68d63          	beq	a3,a5,8ea <vprintf+0x1d0>
        putc(fd, '%');
 814:	85d6                	mv	a1,s5
 816:	855a                	mv	a0,s6
 818:	e49ff0ef          	jal	ra,660 <putc>
        putc(fd, c0);
 81c:	85ca                	mv	a1,s2
 81e:	855a                	mv	a0,s6
 820:	e41ff0ef          	jal	ra,660 <putc>
      state = 0;
 824:	4981                	li	s3,0
 826:	b7b9                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 828:	008b8913          	addi	s2,s7,8
 82c:	4685                	li	a3,1
 82e:	4629                	li	a2,10
 830:	000bb583          	ld	a1,0(s7)
 834:	855a                	mv	a0,s6
 836:	e49ff0ef          	jal	ra,67e <printint>
        i += 1;
 83a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 83c:	8bca                	mv	s7,s2
      state = 0;
 83e:	4981                	li	s3,0
        i += 1;
 840:	bf15                	j	774 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 842:	03860563          	beq	a2,s8,86c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 846:	07b60963          	beq	a2,s11,8b8 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 84a:	07800793          	li	a5,120
 84e:	fcf613e3          	bne	a2,a5,814 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 852:	008b8913          	addi	s2,s7,8
 856:	4681                	li	a3,0
 858:	4641                	li	a2,16
 85a:	000bb583          	ld	a1,0(s7)
 85e:	855a                	mv	a0,s6
 860:	e1fff0ef          	jal	ra,67e <printint>
        i += 2;
 864:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 866:	8bca                	mv	s7,s2
      state = 0;
 868:	4981                	li	s3,0
        i += 2;
 86a:	b729                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 86c:	008b8913          	addi	s2,s7,8
 870:	4685                	li	a3,1
 872:	4629                	li	a2,10
 874:	000bb583          	ld	a1,0(s7)
 878:	855a                	mv	a0,s6
 87a:	e05ff0ef          	jal	ra,67e <printint>
        i += 2;
 87e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 880:	8bca                	mv	s7,s2
      state = 0;
 882:	4981                	li	s3,0
        i += 2;
 884:	bdc5                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 886:	008b8913          	addi	s2,s7,8
 88a:	4681                	li	a3,0
 88c:	4629                	li	a2,10
 88e:	000be583          	lwu	a1,0(s7)
 892:	855a                	mv	a0,s6
 894:	debff0ef          	jal	ra,67e <printint>
 898:	8bca                	mv	s7,s2
      state = 0;
 89a:	4981                	li	s3,0
 89c:	bde1                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 89e:	008b8913          	addi	s2,s7,8
 8a2:	4681                	li	a3,0
 8a4:	4629                	li	a2,10
 8a6:	000bb583          	ld	a1,0(s7)
 8aa:	855a                	mv	a0,s6
 8ac:	dd3ff0ef          	jal	ra,67e <printint>
        i += 1;
 8b0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b2:	8bca                	mv	s7,s2
      state = 0;
 8b4:	4981                	li	s3,0
        i += 1;
 8b6:	bd7d                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b8:	008b8913          	addi	s2,s7,8
 8bc:	4681                	li	a3,0
 8be:	4629                	li	a2,10
 8c0:	000bb583          	ld	a1,0(s7)
 8c4:	855a                	mv	a0,s6
 8c6:	db9ff0ef          	jal	ra,67e <printint>
        i += 2;
 8ca:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8cc:	8bca                	mv	s7,s2
      state = 0;
 8ce:	4981                	li	s3,0
        i += 2;
 8d0:	b555                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8d2:	008b8913          	addi	s2,s7,8
 8d6:	4681                	li	a3,0
 8d8:	4641                	li	a2,16
 8da:	000be583          	lwu	a1,0(s7)
 8de:	855a                	mv	a0,s6
 8e0:	d9fff0ef          	jal	ra,67e <printint>
 8e4:	8bca                	mv	s7,s2
      state = 0;
 8e6:	4981                	li	s3,0
 8e8:	b571                	j	774 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8ea:	008b8913          	addi	s2,s7,8
 8ee:	4681                	li	a3,0
 8f0:	4641                	li	a2,16
 8f2:	000bb583          	ld	a1,0(s7)
 8f6:	855a                	mv	a0,s6
 8f8:	d87ff0ef          	jal	ra,67e <printint>
        i += 1;
 8fc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8fe:	8bca                	mv	s7,s2
      state = 0;
 900:	4981                	li	s3,0
        i += 1;
 902:	bd8d                	j	774 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 904:	008b8793          	addi	a5,s7,8
 908:	f8f43423          	sd	a5,-120(s0)
 90c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 910:	03000593          	li	a1,48
 914:	855a                	mv	a0,s6
 916:	d4bff0ef          	jal	ra,660 <putc>
  putc(fd, 'x');
 91a:	07800593          	li	a1,120
 91e:	855a                	mv	a0,s6
 920:	d41ff0ef          	jal	ra,660 <putc>
 924:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 926:	03c9d793          	srli	a5,s3,0x3c
 92a:	97e6                	add	a5,a5,s9
 92c:	0007c583          	lbu	a1,0(a5)
 930:	855a                	mv	a0,s6
 932:	d2fff0ef          	jal	ra,660 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 936:	0992                	slli	s3,s3,0x4
 938:	397d                	addiw	s2,s2,-1
 93a:	fe0916e3          	bnez	s2,926 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 93e:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 942:	4981                	li	s3,0
 944:	bd05                	j	774 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 946:	008b8913          	addi	s2,s7,8
 94a:	000bc583          	lbu	a1,0(s7)
 94e:	855a                	mv	a0,s6
 950:	d11ff0ef          	jal	ra,660 <putc>
 954:	8bca                	mv	s7,s2
      state = 0;
 956:	4981                	li	s3,0
 958:	bd31                	j	774 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 95a:	008b8993          	addi	s3,s7,8
 95e:	000bb903          	ld	s2,0(s7)
 962:	00090f63          	beqz	s2,980 <vprintf+0x266>
        for(; *s; s++)
 966:	00094583          	lbu	a1,0(s2)
 96a:	c195                	beqz	a1,98e <vprintf+0x274>
          putc(fd, *s);
 96c:	855a                	mv	a0,s6
 96e:	cf3ff0ef          	jal	ra,660 <putc>
        for(; *s; s++)
 972:	0905                	addi	s2,s2,1
 974:	00094583          	lbu	a1,0(s2)
 978:	f9f5                	bnez	a1,96c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 97a:	8bce                	mv	s7,s3
      state = 0;
 97c:	4981                	li	s3,0
 97e:	bbdd                	j	774 <vprintf+0x5a>
          s = "(null)";
 980:	00000917          	auipc	s2,0x0
 984:	60890913          	addi	s2,s2,1544 # f88 <malloc+0x4f2>
        for(; *s; s++)
 988:	02800593          	li	a1,40
 98c:	b7c5                	j	96c <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 98e:	8bce                	mv	s7,s3
      state = 0;
 990:	4981                	li	s3,0
 992:	b3cd                	j	774 <vprintf+0x5a>
    }
  }
}
 994:	70e6                	ld	ra,120(sp)
 996:	7446                	ld	s0,112(sp)
 998:	74a6                	ld	s1,104(sp)
 99a:	7906                	ld	s2,96(sp)
 99c:	69e6                	ld	s3,88(sp)
 99e:	6a46                	ld	s4,80(sp)
 9a0:	6aa6                	ld	s5,72(sp)
 9a2:	6b06                	ld	s6,64(sp)
 9a4:	7be2                	ld	s7,56(sp)
 9a6:	7c42                	ld	s8,48(sp)
 9a8:	7ca2                	ld	s9,40(sp)
 9aa:	7d02                	ld	s10,32(sp)
 9ac:	6de2                	ld	s11,24(sp)
 9ae:	6109                	addi	sp,sp,128
 9b0:	8082                	ret

00000000000009b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9b2:	715d                	addi	sp,sp,-80
 9b4:	ec06                	sd	ra,24(sp)
 9b6:	e822                	sd	s0,16(sp)
 9b8:	1000                	addi	s0,sp,32
 9ba:	e010                	sd	a2,0(s0)
 9bc:	e414                	sd	a3,8(s0)
 9be:	e818                	sd	a4,16(s0)
 9c0:	ec1c                	sd	a5,24(s0)
 9c2:	03043023          	sd	a6,32(s0)
 9c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ce:	8622                	mv	a2,s0
 9d0:	d4bff0ef          	jal	ra,71a <vprintf>
}
 9d4:	60e2                	ld	ra,24(sp)
 9d6:	6442                	ld	s0,16(sp)
 9d8:	6161                	addi	sp,sp,80
 9da:	8082                	ret

00000000000009dc <printf>:

void
printf(const char *fmt, ...)
{
 9dc:	711d                	addi	sp,sp,-96
 9de:	ec06                	sd	ra,24(sp)
 9e0:	e822                	sd	s0,16(sp)
 9e2:	1000                	addi	s0,sp,32
 9e4:	e40c                	sd	a1,8(s0)
 9e6:	e810                	sd	a2,16(s0)
 9e8:	ec14                	sd	a3,24(s0)
 9ea:	f018                	sd	a4,32(s0)
 9ec:	f41c                	sd	a5,40(s0)
 9ee:	03043823          	sd	a6,48(s0)
 9f2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9f6:	00840613          	addi	a2,s0,8
 9fa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9fe:	85aa                	mv	a1,a0
 a00:	4505                	li	a0,1
 a02:	d19ff0ef          	jal	ra,71a <vprintf>
}
 a06:	60e2                	ld	ra,24(sp)
 a08:	6442                	ld	s0,16(sp)
 a0a:	6125                	addi	sp,sp,96
 a0c:	8082                	ret

0000000000000a0e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a0e:	1141                	addi	sp,sp,-16
 a10:	e422                	sd	s0,8(sp)
 a12:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a14:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a18:	00000797          	auipc	a5,0x0
 a1c:	5e87b783          	ld	a5,1512(a5) # 1000 <freep>
 a20:	a805                	j	a50 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a22:	4618                	lw	a4,8(a2)
 a24:	9db9                	addw	a1,a1,a4
 a26:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a2a:	6398                	ld	a4,0(a5)
 a2c:	6318                	ld	a4,0(a4)
 a2e:	fee53823          	sd	a4,-16(a0)
 a32:	a091                	j	a76 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a34:	ff852703          	lw	a4,-8(a0)
 a38:	9e39                	addw	a2,a2,a4
 a3a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a3c:	ff053703          	ld	a4,-16(a0)
 a40:	e398                	sd	a4,0(a5)
 a42:	a099                	j	a88 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a44:	6398                	ld	a4,0(a5)
 a46:	00e7e463          	bltu	a5,a4,a4e <free+0x40>
 a4a:	00e6ea63          	bltu	a3,a4,a5e <free+0x50>
{
 a4e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a50:	fed7fae3          	bgeu	a5,a3,a44 <free+0x36>
 a54:	6398                	ld	a4,0(a5)
 a56:	00e6e463          	bltu	a3,a4,a5e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a5a:	fee7eae3          	bltu	a5,a4,a4e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a5e:	ff852583          	lw	a1,-8(a0)
 a62:	6390                	ld	a2,0(a5)
 a64:	02059713          	slli	a4,a1,0x20
 a68:	9301                	srli	a4,a4,0x20
 a6a:	0712                	slli	a4,a4,0x4
 a6c:	9736                	add	a4,a4,a3
 a6e:	fae60ae3          	beq	a2,a4,a22 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a72:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a76:	4790                	lw	a2,8(a5)
 a78:	02061713          	slli	a4,a2,0x20
 a7c:	9301                	srli	a4,a4,0x20
 a7e:	0712                	slli	a4,a4,0x4
 a80:	973e                	add	a4,a4,a5
 a82:	fae689e3          	beq	a3,a4,a34 <free+0x26>
  } else
    p->s.ptr = bp;
 a86:	e394                	sd	a3,0(a5)
  freep = p;
 a88:	00000717          	auipc	a4,0x0
 a8c:	56f73c23          	sd	a5,1400(a4) # 1000 <freep>
}
 a90:	6422                	ld	s0,8(sp)
 a92:	0141                	addi	sp,sp,16
 a94:	8082                	ret

0000000000000a96 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a96:	7139                	addi	sp,sp,-64
 a98:	fc06                	sd	ra,56(sp)
 a9a:	f822                	sd	s0,48(sp)
 a9c:	f426                	sd	s1,40(sp)
 a9e:	f04a                	sd	s2,32(sp)
 aa0:	ec4e                	sd	s3,24(sp)
 aa2:	e852                	sd	s4,16(sp)
 aa4:	e456                	sd	s5,8(sp)
 aa6:	e05a                	sd	s6,0(sp)
 aa8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aaa:	02051493          	slli	s1,a0,0x20
 aae:	9081                	srli	s1,s1,0x20
 ab0:	04bd                	addi	s1,s1,15
 ab2:	8091                	srli	s1,s1,0x4
 ab4:	0014899b          	addiw	s3,s1,1
 ab8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 aba:	00000517          	auipc	a0,0x0
 abe:	54653503          	ld	a0,1350(a0) # 1000 <freep>
 ac2:	c515                	beqz	a0,aee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ac6:	4798                	lw	a4,8(a5)
 ac8:	02977f63          	bgeu	a4,s1,b06 <malloc+0x70>
 acc:	8a4e                	mv	s4,s3
 ace:	0009871b          	sext.w	a4,s3
 ad2:	6685                	lui	a3,0x1
 ad4:	00d77363          	bgeu	a4,a3,ada <malloc+0x44>
 ad8:	6a05                	lui	s4,0x1
 ada:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ade:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ae2:	00000917          	auipc	s2,0x0
 ae6:	51e90913          	addi	s2,s2,1310 # 1000 <freep>
  if(p == SBRK_ERROR)
 aea:	5afd                	li	s5,-1
 aec:	a0bd                	j	b5a <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 aee:	00000797          	auipc	a5,0x0
 af2:	52278793          	addi	a5,a5,1314 # 1010 <base>
 af6:	00000717          	auipc	a4,0x0
 afa:	50f73523          	sd	a5,1290(a4) # 1000 <freep>
 afe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b00:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b04:	b7e1                	j	acc <malloc+0x36>
      if(p->s.size == nunits)
 b06:	02e48b63          	beq	s1,a4,b3c <malloc+0xa6>
        p->s.size -= nunits;
 b0a:	4137073b          	subw	a4,a4,s3
 b0e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b10:	1702                	slli	a4,a4,0x20
 b12:	9301                	srli	a4,a4,0x20
 b14:	0712                	slli	a4,a4,0x4
 b16:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b18:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b1c:	00000717          	auipc	a4,0x0
 b20:	4ea73223          	sd	a0,1252(a4) # 1000 <freep>
      return (void*)(p + 1);
 b24:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b28:	70e2                	ld	ra,56(sp)
 b2a:	7442                	ld	s0,48(sp)
 b2c:	74a2                	ld	s1,40(sp)
 b2e:	7902                	ld	s2,32(sp)
 b30:	69e2                	ld	s3,24(sp)
 b32:	6a42                	ld	s4,16(sp)
 b34:	6aa2                	ld	s5,8(sp)
 b36:	6b02                	ld	s6,0(sp)
 b38:	6121                	addi	sp,sp,64
 b3a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b3c:	6398                	ld	a4,0(a5)
 b3e:	e118                	sd	a4,0(a0)
 b40:	bff1                	j	b1c <malloc+0x86>
  hp->s.size = nu;
 b42:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b46:	0541                	addi	a0,a0,16
 b48:	ec7ff0ef          	jal	ra,a0e <free>
  return freep;
 b4c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b50:	dd61                	beqz	a0,b28 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b52:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b54:	4798                	lw	a4,8(a5)
 b56:	fa9778e3          	bgeu	a4,s1,b06 <malloc+0x70>
    if(p == freep)
 b5a:	00093703          	ld	a4,0(s2)
 b5e:	853e                	mv	a0,a5
 b60:	fef719e3          	bne	a4,a5,b52 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 b64:	8552                	mv	a0,s4
 b66:	a17ff0ef          	jal	ra,57c <sbrk>
  if(p == SBRK_ERROR)
 b6a:	fd551ce3          	bne	a0,s5,b42 <malloc+0xac>
        return 0;
 b6e:	4501                	li	a0,0
 b70:	bf65                	j	b28 <malloc+0x92>
