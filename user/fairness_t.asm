
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
   6:	0100                	addi	s0,sp,128
  int cpu_pid, io_pid, mixed_pid;
  
  printf("=== Long-Running Fairness Test (Week 3) ===\n");
   8:	00001517          	auipc	a0,0x1
   c:	c9850513          	addi	a0,a0,-872 # ca0 <malloc+0xf8>
  10:	2e1000ef          	jal	af0 <printf>
  printf("Running 3 different workloads for ~200 ticks\n");
  14:	00001517          	auipc	a0,0x1
  18:	cc450513          	addi	a0,a0,-828 # cd8 <malloc+0x130>
  1c:	2d5000ef          	jal	af0 <printf>
  printf("  1. Pure CPU-bound (should demote but get boosted)\n");
  20:	00001517          	auipc	a0,0x1
  24:	ce850513          	addi	a0,a0,-792 # d08 <malloc+0x160>
  28:	2c9000ef          	jal	af0 <printf>
  printf("  2. Pure I/O-bound (should stay high priority)\n");
  2c:	00001517          	auipc	a0,0x1
  30:	d1450513          	addi	a0,a0,-748 # d40 <malloc+0x198>
  34:	2bd000ef          	jal	af0 <printf>
  printf("  3. Mixed workload\n\n");
  38:	00001517          	auipc	a0,0x1
  3c:	d4050513          	addi	a0,a0,-704 # d78 <malloc+0x1d0>
  40:	2b1000ef          	jal	af0 <printf>
  
  // Process 1: Pure CPU-bound
  cpu_pid = fork();
  44:	64e000ef          	jal	692 <fork>
  if(cpu_pid == 0) {
  48:	12051e63          	bnez	a0,184 <main+0x184>
  4c:	f4a6                	sd	s1,104(sp)
  4e:	f0ca                	sd	s2,96(sp)
  50:	ecce                	sd	s3,88(sp)
  52:	e8d2                	sd	s4,80(sp)
  54:	e4d6                	sd	s5,72(sp)
  56:	e0da                	sd	s6,64(sp)
  58:	fc5e                	sd	s7,56(sp)
  5a:	f862                	sd	s8,48(sp)
  5c:	f466                	sd	s9,40(sp)
  5e:	8baa                	mv	s7,a0
    struct procinfo info;
    volatile int dummy = 0;
  60:	f8042623          	sw	zero,-116(s0)
    int boost_count = 0;
    int prev_priority = 0;
    
    printf("[CPU-BOUND] Starting...\n");
  64:	00001517          	auipc	a0,0x1
  68:	d2c50513          	addi	a0,a0,-724 # d90 <malloc+0x1e8>
  6c:	285000ef          	jal	af0 <printf>
    
    for(int iter = 0; iter < 80; iter++) {
  70:	8a5e                	mv	s4,s7
    int prev_priority = 0;
  72:	8ade                	mv	s5,s7
      // Heavy computation
      for(long j = 0; j < 8000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
  74:	431be9b7          	lui	s3,0x431be
  78:	e8398993          	addi	s3,s3,-381 # 431bde83 <base+0x431bbe73>
  7c:	000f4937          	lui	s2,0xf4
  80:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2230>
      for(long j = 0; j < 8000000; j++) {
  84:	007a14b7          	lui	s1,0x7a1
  88:	20048493          	addi	s1,s1,512 # 7a1200 <base+0x79f1f0>
      }
      
      if(getprocinfo(&info) == 0) {
  8c:	f9040b13          	addi	s6,s0,-112
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
                 boost_count, uptime(), prev_priority, info.priority);
        }
        prev_priority = info.priority;
        
        if(iter % 20 == 0) {
  90:	66666c37          	lui	s8,0x66666
  94:	667c0c13          	addi	s8,s8,1639 # 66666667 <base+0x66664657>
  98:	a03d                	j	c6 <main+0xc6>
          boost_count++;
  9a:	001b8c9b          	addiw	s9,s7,1
  9e:	8be6                	mv	s7,s9
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
  a0:	692000ef          	jal	732 <uptime>
  a4:	862a                	mv	a2,a0
  a6:	f9842703          	lw	a4,-104(s0)
  aa:	86d6                	mv	a3,s5
  ac:	85e6                	mv	a1,s9
  ae:	00001517          	auipc	a0,0x1
  b2:	d0250513          	addi	a0,a0,-766 # db0 <malloc+0x208>
  b6:	23b000ef          	jal	af0 <printf>
  ba:	a0b1                	j	106 <main+0x106>
    for(int iter = 0; iter < 80; iter++) {
  bc:	2a05                	addiw	s4,s4,1
  be:	05000793          	li	a5,80
  c2:	08fa0063          	beq	s4,a5,142 <main+0x142>
      for(long j = 0; j < 8000000; j++) {
  c6:	4681                	li	a3,0
        dummy = dummy + j;
  c8:	f8c42783          	lw	a5,-116(s0)
  cc:	9fb5                	addw	a5,a5,a3
  ce:	f8f42623          	sw	a5,-116(s0)
        dummy = dummy % 1000000;
  d2:	f8c42783          	lw	a5,-116(s0)
  d6:	0007871b          	sext.w	a4,a5
  da:	033787b3          	mul	a5,a5,s3
  de:	97c9                	srai	a5,a5,0x32
  e0:	41f7561b          	sraiw	a2,a4,0x1f
  e4:	9f91                	subw	a5,a5,a2
  e6:	02f907bb          	mulw	a5,s2,a5
  ea:	9f1d                	subw	a4,a4,a5
  ec:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 8000000; j++) {
  f0:	0685                	addi	a3,a3,1
  f2:	fc969be3          	bne	a3,s1,c8 <main+0xc8>
      if(getprocinfo(&info) == 0) {
  f6:	855a                	mv	a0,s6
  f8:	642000ef          	jal	73a <getprocinfo>
  fc:	f161                	bnez	a0,bc <main+0xbc>
        if(info.priority < prev_priority) {
  fe:	f9842783          	lw	a5,-104(s0)
 102:	f957cce3          	blt	a5,s5,9a <main+0x9a>
        prev_priority = info.priority;
 106:	f9842a83          	lw	s5,-104(s0)
        if(iter % 20 == 0) {
 10a:	038a0733          	mul	a4,s4,s8
 10e:	970d                	srai	a4,a4,0x23
 110:	41fa579b          	sraiw	a5,s4,0x1f
 114:	9f1d                	subw	a4,a4,a5
 116:	0027179b          	slliw	a5,a4,0x2
 11a:	9fb9                	addw	a5,a5,a4
 11c:	0027979b          	slliw	a5,a5,0x2
 120:	40fa07bb          	subw	a5,s4,a5
 124:	ffc1                	bnez	a5,bc <main+0xbc>
          printf("[CPU-BOUND] Tick %d: Q%d (slices=%d)\n", 
 126:	60c000ef          	jal	732 <uptime>
 12a:	85aa                	mv	a1,a0
 12c:	f9c42683          	lw	a3,-100(s0)
 130:	f9842603          	lw	a2,-104(s0)
 134:	00001517          	auipc	a0,0x1
 138:	cb450513          	addi	a0,a0,-844 # de8 <malloc+0x240>
 13c:	1b5000ef          	jal	af0 <printf>
 140:	bfb5                	j	bc <main+0xbc>
                 uptime(), info.priority, info.time_slices);
        }
      }
    }
    
    if(getprocinfo(&info) == 0) {
 142:	f9040513          	addi	a0,s0,-112
 146:	5f4000ef          	jal	73a <getprocinfo>
 14a:	c501                	beqz	a0,152 <main+0x152>
        printf("[CPU-BOUND] ✓ Received at least one boost!\n");
      } else {
        printf("[CPU-BOUND] ✗ No boosts detected (problem!)\n");
      }
    }
    exit(0);
 14c:	4501                	li	a0,0
 14e:	54c000ef          	jal	69a <exit>
      printf("[CPU-BOUND] FINAL: Q%d, %d boosts detected\n", 
 152:	865e                	mv	a2,s7
 154:	f9842583          	lw	a1,-104(s0)
 158:	00001517          	auipc	a0,0x1
 15c:	cb850513          	addi	a0,a0,-840 # e10 <malloc+0x268>
 160:	191000ef          	jal	af0 <printf>
      if(boost_count >= 1) {
 164:	01705963          	blez	s7,176 <main+0x176>
        printf("[CPU-BOUND] ✓ Received at least one boost!\n");
 168:	00001517          	auipc	a0,0x1
 16c:	cd850513          	addi	a0,a0,-808 # e40 <malloc+0x298>
 170:	181000ef          	jal	af0 <printf>
 174:	bfe1                	j	14c <main+0x14c>
        printf("[CPU-BOUND] ✗ No boosts detected (problem!)\n");
 176:	00001517          	auipc	a0,0x1
 17a:	cfa50513          	addi	a0,a0,-774 # e70 <malloc+0x2c8>
 17e:	173000ef          	jal	af0 <printf>
 182:	b7e9                	j	14c <main+0x14c>
 184:	f0ca                	sd	s2,96(sp)
 186:	e8d2                	sd	s4,80(sp)
  }
  
  pause(2);
 188:	4509                	li	a0,2
 18a:	5a0000ef          	jal	72a <pause>
  
  // Process 2: I/O-bound
  io_pid = fork();
 18e:	504000ef          	jal	692 <fork>
 192:	892a                	mv	s2,a0
  if(io_pid == 0) {
 194:	e979                	bnez	a0,26a <main+0x26a>
 196:	f4a6                	sd	s1,104(sp)
 198:	ecce                	sd	s3,88(sp)
 19a:	e4d6                	sd	s5,72(sp)
 19c:	e0da                	sd	s6,64(sp)
 19e:	fc5e                	sd	s7,56(sp)
 1a0:	f862                	sd	s8,48(sp)
 1a2:	f466                	sd	s9,40(sp)
    struct procinfo info;
    volatile int dummy = 0;
 1a4:	f8042623          	sw	zero,-116(s0)
    
    printf("[I/O-BOUND] Starting...\n");
 1a8:	00001517          	auipc	a0,0x1
 1ac:	cf850513          	addi	a0,a0,-776 # ea0 <malloc+0x2f8>
 1b0:	141000ef          	jal	af0 <printf>
    
    for(int iter = 0; iter < 100; iter++) {
      // Brief work
      for(long j = 0; j < 1000000; j++) {
 1b4:	000f44b7          	lui	s1,0xf4
 1b8:	24048493          	addi	s1,s1,576 # f4240 <base+0xf2230>
        dummy = dummy + j;
      }
      
      // Yield frequently
      pause(2);
 1bc:	4a89                	li	s5,2
      
      if(iter % 25 == 0 && getprocinfo(&info) == 0) {
 1be:	51eb89b7          	lui	s3,0x51eb8
 1c2:	51f98993          	addi	s3,s3,1311 # 51eb851f <base+0x51eb650f>
 1c6:	f9040b13          	addi	s6,s0,-112
        printf("[I/O-BOUND] Tick %d: Q%d (slices=%d)\n", 
 1ca:	00001b97          	auipc	s7,0x1
 1ce:	cf6b8b93          	addi	s7,s7,-778 # ec0 <malloc+0x318>
    for(int iter = 0; iter < 100; iter++) {
 1d2:	06400a13          	li	s4,100
 1d6:	a021                	j	1de <main+0x1de>
 1d8:	2905                	addiw	s2,s2,1
 1da:	05490c63          	beq	s2,s4,232 <main+0x232>
      for(long j = 0; j < 1000000; j++) {
 1de:	4781                	li	a5,0
        dummy = dummy + j;
 1e0:	f8c42703          	lw	a4,-116(s0)
 1e4:	9f3d                	addw	a4,a4,a5
 1e6:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 1000000; j++) {
 1ea:	0785                	addi	a5,a5,1
 1ec:	fe979ae3          	bne	a5,s1,1e0 <main+0x1e0>
      pause(2);
 1f0:	8556                	mv	a0,s5
 1f2:	538000ef          	jal	72a <pause>
      if(iter % 25 == 0 && getprocinfo(&info) == 0) {
 1f6:	03390733          	mul	a4,s2,s3
 1fa:	970d                	srai	a4,a4,0x23
 1fc:	41f9579b          	sraiw	a5,s2,0x1f
 200:	9f1d                	subw	a4,a4,a5
 202:	0017179b          	slliw	a5,a4,0x1
 206:	9fb9                	addw	a5,a5,a4
 208:	0037979b          	slliw	a5,a5,0x3
 20c:	9fb9                	addw	a5,a5,a4
 20e:	40f907bb          	subw	a5,s2,a5
 212:	f3f9                	bnez	a5,1d8 <main+0x1d8>
 214:	855a                	mv	a0,s6
 216:	524000ef          	jal	73a <getprocinfo>
 21a:	fd5d                	bnez	a0,1d8 <main+0x1d8>
        printf("[I/O-BOUND] Tick %d: Q%d (slices=%d)\n", 
 21c:	516000ef          	jal	732 <uptime>
 220:	85aa                	mv	a1,a0
 222:	f9c42683          	lw	a3,-100(s0)
 226:	f9842603          	lw	a2,-104(s0)
 22a:	855e                	mv	a0,s7
 22c:	0c5000ef          	jal	af0 <printf>
 230:	b765                	j	1d8 <main+0x1d8>
               uptime(), info.priority, info.time_slices);
      }
    }
    
    if(getprocinfo(&info) == 0) {
 232:	f9040513          	addi	a0,s0,-112
 236:	504000ef          	jal	73a <getprocinfo>
 23a:	c501                	beqz	a0,242 <main+0x242>
      printf("[I/O-BOUND] FINAL: Q%d\n", info.priority);
      if(info.priority <= 1) {
        printf("[I/O-BOUND] ✓ Maintained high priority\n");
      }
    }
    exit(0);
 23c:	4501                	li	a0,0
 23e:	45c000ef          	jal	69a <exit>
      printf("[I/O-BOUND] FINAL: Q%d\n", info.priority);
 242:	f9842583          	lw	a1,-104(s0)
 246:	00001517          	auipc	a0,0x1
 24a:	ca250513          	addi	a0,a0,-862 # ee8 <malloc+0x340>
 24e:	0a3000ef          	jal	af0 <printf>
      if(info.priority <= 1) {
 252:	f9842703          	lw	a4,-104(s0)
 256:	4785                	li	a5,1
 258:	fee7c2e3          	blt	a5,a4,23c <main+0x23c>
        printf("[I/O-BOUND] ✓ Maintained high priority\n");
 25c:	00001517          	auipc	a0,0x1
 260:	ca450513          	addi	a0,a0,-860 # f00 <malloc+0x358>
 264:	08d000ef          	jal	af0 <printf>
 268:	bfd1                	j	23c <main+0x23c>
  }
  
  pause(2);
 26a:	4509                	li	a0,2
 26c:	4be000ef          	jal	72a <pause>
  
  // Process 3: Mixed workload
  mixed_pid = fork();
 270:	422000ef          	jal	692 <fork>
 274:	8a2a                	mv	s4,a0
  if(mixed_pid == 0) {
 276:	0e051a63          	bnez	a0,36a <main+0x36a>
 27a:	f4a6                	sd	s1,104(sp)
 27c:	ecce                	sd	s3,88(sp)
 27e:	e4d6                	sd	s5,72(sp)
 280:	e0da                	sd	s6,64(sp)
 282:	fc5e                	sd	s7,56(sp)
 284:	f862                	sd	s8,48(sp)
 286:	f466                	sd	s9,40(sp)
    struct procinfo info;
    volatile int dummy = 0;
 288:	f8042623          	sw	zero,-116(s0)
    
    printf("[MIXED] Starting...\n");
 28c:	00001517          	auipc	a0,0x1
 290:	ca450513          	addi	a0,a0,-860 # f30 <malloc+0x388>
 294:	05d000ef          	jal	af0 <printf>
    
    for(int iter = 0; iter < 50; iter++) {
      // Alternate: CPU burst then sleep
      for(long j = 0; j < 15000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
 298:	431be9b7          	lui	s3,0x431be
 29c:	e8398993          	addi	s3,s3,-381 # 431bde83 <base+0x431bbe73>
 2a0:	000f4937          	lui	s2,0xf4
 2a4:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2230>
      for(long j = 0; j < 15000000; j++) {
 2a8:	00e4e4b7          	lui	s1,0xe4e
 2ac:	1c048493          	addi	s1,s1,448 # e4e1c0 <base+0xe4c1b0>
      }
      
      pause(3);
 2b0:	4c0d                	li	s8,3
      
      if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 2b2:	88889ab7          	lui	s5,0x88889
 2b6:	889a8a93          	addi	s5,s5,-1911 # ffffffff88888889 <base+0xffffffff88886879>
 2ba:	f9040b93          	addi	s7,s0,-112
        printf("[MIXED] Tick %d: Q%d (slices=%d)\n", 
 2be:	00001b17          	auipc	s6,0x1
 2c2:	c8ab0b13          	addi	s6,s6,-886 # f48 <malloc+0x3a0>
 2c6:	a031                	j	2d2 <main+0x2d2>
    for(int iter = 0; iter < 50; iter++) {
 2c8:	2a05                	addiw	s4,s4,1
 2ca:	03200793          	li	a5,50
 2ce:	06fa0d63          	beq	s4,a5,348 <main+0x348>
      for(long j = 0; j < 15000000; j++) {
 2d2:	4681                	li	a3,0
        dummy = dummy + j;
 2d4:	f8c42783          	lw	a5,-116(s0)
 2d8:	9fb5                	addw	a5,a5,a3
 2da:	f8f42623          	sw	a5,-116(s0)
        dummy = dummy % 1000000;
 2de:	f8c42783          	lw	a5,-116(s0)
 2e2:	0007871b          	sext.w	a4,a5
 2e6:	033787b3          	mul	a5,a5,s3
 2ea:	97c9                	srai	a5,a5,0x32
 2ec:	41f7561b          	sraiw	a2,a4,0x1f
 2f0:	9f91                	subw	a5,a5,a2
 2f2:	02f907bb          	mulw	a5,s2,a5
 2f6:	9f1d                	subw	a4,a4,a5
 2f8:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 15000000; j++) {
 2fc:	0685                	addi	a3,a3,1
 2fe:	fc969be3          	bne	a3,s1,2d4 <main+0x2d4>
      pause(3);
 302:	8562                	mv	a0,s8
 304:	426000ef          	jal	72a <pause>
      if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 308:	035a07b3          	mul	a5,s4,s5
 30c:	9381                	srli	a5,a5,0x20
 30e:	00fa07bb          	addw	a5,s4,a5
 312:	4037d79b          	sraiw	a5,a5,0x3
 316:	41fa571b          	sraiw	a4,s4,0x1f
 31a:	9f99                	subw	a5,a5,a4
 31c:	0047971b          	slliw	a4,a5,0x4
 320:	40f707bb          	subw	a5,a4,a5
 324:	40fa07bb          	subw	a5,s4,a5
 328:	f3c5                	bnez	a5,2c8 <main+0x2c8>
 32a:	855e                	mv	a0,s7
 32c:	40e000ef          	jal	73a <getprocinfo>
 330:	fd41                	bnez	a0,2c8 <main+0x2c8>
        printf("[MIXED] Tick %d: Q%d (slices=%d)\n", 
 332:	400000ef          	jal	732 <uptime>
 336:	85aa                	mv	a1,a0
 338:	f9c42683          	lw	a3,-100(s0)
 33c:	f9842603          	lw	a2,-104(s0)
 340:	855a                	mv	a0,s6
 342:	7ae000ef          	jal	af0 <printf>
 346:	b749                	j	2c8 <main+0x2c8>
               uptime(), info.priority, info.time_slices);
      }
    }
    
    if(getprocinfo(&info) == 0) {
 348:	f9040513          	addi	a0,s0,-112
 34c:	3ee000ef          	jal	73a <getprocinfo>
 350:	c501                	beqz	a0,358 <main+0x358>
      printf("[MIXED] FINAL: Q%d\n", info.priority);
    }
    exit(0);
 352:	4501                	li	a0,0
 354:	346000ef          	jal	69a <exit>
      printf("[MIXED] FINAL: Q%d\n", info.priority);
 358:	f9842583          	lw	a1,-104(s0)
 35c:	00001517          	auipc	a0,0x1
 360:	c1450513          	addi	a0,a0,-1004 # f70 <malloc+0x3c8>
 364:	78c000ef          	jal	af0 <printf>
 368:	b7ed                	j	352 <main+0x352>
 36a:	f4a6                	sd	s1,104(sp)
 36c:	ecce                	sd	s3,88(sp)
 36e:	e4d6                	sd	s5,72(sp)
 370:	e0da                	sd	s6,64(sp)
 372:	fc5e                	sd	s7,56(sp)
 374:	f862                	sd	s8,48(sp)
 376:	f466                	sd	s9,40(sp)
  }
  
  // Parent waits
  printf("\n[Parent] All processes running...\n");
 378:	00001517          	auipc	a0,0x1
 37c:	c1050513          	addi	a0,a0,-1008 # f88 <malloc+0x3e0>
 380:	770000ef          	jal	af0 <printf>
  wait(0);
 384:	4501                	li	a0,0
 386:	31c000ef          	jal	6a2 <wait>
  wait(0);
 38a:	4501                	li	a0,0
 38c:	316000ef          	jal	6a2 <wait>
  wait(0);
 390:	4501                	li	a0,0
 392:	310000ef          	jal	6a2 <wait>
  
  printf("\n=== Fairness Test Complete ===\n");
 396:	00001517          	auipc	a0,0x1
 39a:	c1a50513          	addi	a0,a0,-998 # fb0 <malloc+0x408>
 39e:	752000ef          	jal	af0 <printf>
  printf("All three workloads completed successfully!\n");
 3a2:	00001517          	auipc	a0,0x1
 3a6:	c3650513          	addi	a0,a0,-970 # fd8 <malloc+0x430>
 3aa:	746000ef          	jal	af0 <printf>
  printf("Expected results:\n");
 3ae:	00001517          	auipc	a0,0x1
 3b2:	c5a50513          	addi	a0,a0,-934 # 1008 <malloc+0x460>
 3b6:	73a000ef          	jal	af0 <printf>
  printf("  - CPU-bound: Experienced boosts (no starvation)\n");
 3ba:	00001517          	auipc	a0,0x1
 3be:	c6650513          	addi	a0,a0,-922 # 1020 <malloc+0x478>
 3c2:	72e000ef          	jal	af0 <printf>
  printf("  - I/O-bound: Stayed in high priority queues\n");
 3c6:	00001517          	auipc	a0,0x1
 3ca:	c9250513          	addi	a0,a0,-878 # 1058 <malloc+0x4b0>
 3ce:	722000ef          	jal	af0 <printf>
  printf("  - Mixed: Balanced between Q1-Q2\n");
 3d2:	00001517          	auipc	a0,0x1
 3d6:	cb650513          	addi	a0,a0,-842 # 1088 <malloc+0x4e0>
 3da:	716000ef          	jal	af0 <printf>
  
  exit(0);
 3de:	4501                	li	a0,0
 3e0:	2ba000ef          	jal	69a <exit>

00000000000003e4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e406                	sd	ra,8(sp)
 3e8:	e022                	sd	s0,0(sp)
 3ea:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 3ec:	c15ff0ef          	jal	0 <main>
  exit(r);
 3f0:	2aa000ef          	jal	69a <exit>

00000000000003f4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e406                	sd	ra,8(sp)
 3f8:	e022                	sd	s0,0(sp)
 3fa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3fc:	87aa                	mv	a5,a0
 3fe:	0585                	addi	a1,a1,1
 400:	0785                	addi	a5,a5,1
 402:	fff5c703          	lbu	a4,-1(a1)
 406:	fee78fa3          	sb	a4,-1(a5)
 40a:	fb75                	bnez	a4,3fe <strcpy+0xa>
    ;
  return os;
}
 40c:	60a2                	ld	ra,8(sp)
 40e:	6402                	ld	s0,0(sp)
 410:	0141                	addi	sp,sp,16
 412:	8082                	ret

0000000000000414 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 414:	1141                	addi	sp,sp,-16
 416:	e406                	sd	ra,8(sp)
 418:	e022                	sd	s0,0(sp)
 41a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 41c:	00054783          	lbu	a5,0(a0)
 420:	cb91                	beqz	a5,434 <strcmp+0x20>
 422:	0005c703          	lbu	a4,0(a1)
 426:	00f71763          	bne	a4,a5,434 <strcmp+0x20>
    p++, q++;
 42a:	0505                	addi	a0,a0,1
 42c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 42e:	00054783          	lbu	a5,0(a0)
 432:	fbe5                	bnez	a5,422 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 434:	0005c503          	lbu	a0,0(a1)
}
 438:	40a7853b          	subw	a0,a5,a0
 43c:	60a2                	ld	ra,8(sp)
 43e:	6402                	ld	s0,0(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret

0000000000000444 <strlen>:

uint
strlen(const char *s)
{
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 44c:	00054783          	lbu	a5,0(a0)
 450:	cf91                	beqz	a5,46c <strlen+0x28>
 452:	00150793          	addi	a5,a0,1
 456:	86be                	mv	a3,a5
 458:	0785                	addi	a5,a5,1
 45a:	fff7c703          	lbu	a4,-1(a5)
 45e:	ff65                	bnez	a4,456 <strlen+0x12>
 460:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 464:	60a2                	ld	ra,8(sp)
 466:	6402                	ld	s0,0(sp)
 468:	0141                	addi	sp,sp,16
 46a:	8082                	ret
  for(n = 0; s[n]; n++)
 46c:	4501                	li	a0,0
 46e:	bfdd                	j	464 <strlen+0x20>

0000000000000470 <memset>:

void*
memset(void *dst, int c, uint n)
{
 470:	1141                	addi	sp,sp,-16
 472:	e406                	sd	ra,8(sp)
 474:	e022                	sd	s0,0(sp)
 476:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 478:	ca19                	beqz	a2,48e <memset+0x1e>
 47a:	87aa                	mv	a5,a0
 47c:	1602                	slli	a2,a2,0x20
 47e:	9201                	srli	a2,a2,0x20
 480:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 484:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 488:	0785                	addi	a5,a5,1
 48a:	fee79de3          	bne	a5,a4,484 <memset+0x14>
  }
  return dst;
}
 48e:	60a2                	ld	ra,8(sp)
 490:	6402                	ld	s0,0(sp)
 492:	0141                	addi	sp,sp,16
 494:	8082                	ret

0000000000000496 <strchr>:

char*
strchr(const char *s, char c)
{
 496:	1141                	addi	sp,sp,-16
 498:	e406                	sd	ra,8(sp)
 49a:	e022                	sd	s0,0(sp)
 49c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 49e:	00054783          	lbu	a5,0(a0)
 4a2:	cf81                	beqz	a5,4ba <strchr+0x24>
    if(*s == c)
 4a4:	00f58763          	beq	a1,a5,4b2 <strchr+0x1c>
  for(; *s; s++)
 4a8:	0505                	addi	a0,a0,1
 4aa:	00054783          	lbu	a5,0(a0)
 4ae:	fbfd                	bnez	a5,4a4 <strchr+0xe>
      return (char*)s;
  return 0;
 4b0:	4501                	li	a0,0
}
 4b2:	60a2                	ld	ra,8(sp)
 4b4:	6402                	ld	s0,0(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret
  return 0;
 4ba:	4501                	li	a0,0
 4bc:	bfdd                	j	4b2 <strchr+0x1c>

00000000000004be <gets>:

char*
gets(char *buf, int max)
{
 4be:	711d                	addi	sp,sp,-96
 4c0:	ec86                	sd	ra,88(sp)
 4c2:	e8a2                	sd	s0,80(sp)
 4c4:	e4a6                	sd	s1,72(sp)
 4c6:	e0ca                	sd	s2,64(sp)
 4c8:	fc4e                	sd	s3,56(sp)
 4ca:	f852                	sd	s4,48(sp)
 4cc:	f456                	sd	s5,40(sp)
 4ce:	f05a                	sd	s6,32(sp)
 4d0:	ec5e                	sd	s7,24(sp)
 4d2:	e862                	sd	s8,16(sp)
 4d4:	1080                	addi	s0,sp,96
 4d6:	8baa                	mv	s7,a0
 4d8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4da:	892a                	mv	s2,a0
 4dc:	4481                	li	s1,0
    cc = read(0, &c, 1);
 4de:	faf40b13          	addi	s6,s0,-81
 4e2:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 4e4:	8c26                	mv	s8,s1
 4e6:	0014899b          	addiw	s3,s1,1
 4ea:	84ce                	mv	s1,s3
 4ec:	0349d463          	bge	s3,s4,514 <gets+0x56>
    cc = read(0, &c, 1);
 4f0:	8656                	mv	a2,s5
 4f2:	85da                	mv	a1,s6
 4f4:	4501                	li	a0,0
 4f6:	1bc000ef          	jal	6b2 <read>
    if(cc < 1)
 4fa:	00a05d63          	blez	a0,514 <gets+0x56>
      break;
    buf[i++] = c;
 4fe:	faf44783          	lbu	a5,-81(s0)
 502:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 506:	0905                	addi	s2,s2,1
 508:	ff678713          	addi	a4,a5,-10
 50c:	c319                	beqz	a4,512 <gets+0x54>
 50e:	17cd                	addi	a5,a5,-13
 510:	fbf1                	bnez	a5,4e4 <gets+0x26>
    buf[i++] = c;
 512:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 514:	9c5e                	add	s8,s8,s7
 516:	000c0023          	sb	zero,0(s8)
  return buf;
}
 51a:	855e                	mv	a0,s7
 51c:	60e6                	ld	ra,88(sp)
 51e:	6446                	ld	s0,80(sp)
 520:	64a6                	ld	s1,72(sp)
 522:	6906                	ld	s2,64(sp)
 524:	79e2                	ld	s3,56(sp)
 526:	7a42                	ld	s4,48(sp)
 528:	7aa2                	ld	s5,40(sp)
 52a:	7b02                	ld	s6,32(sp)
 52c:	6be2                	ld	s7,24(sp)
 52e:	6c42                	ld	s8,16(sp)
 530:	6125                	addi	sp,sp,96
 532:	8082                	ret

0000000000000534 <stat>:

int
stat(const char *n, struct stat *st)
{
 534:	1101                	addi	sp,sp,-32
 536:	ec06                	sd	ra,24(sp)
 538:	e822                	sd	s0,16(sp)
 53a:	e04a                	sd	s2,0(sp)
 53c:	1000                	addi	s0,sp,32
 53e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 540:	4581                	li	a1,0
 542:	198000ef          	jal	6da <open>
  if(fd < 0)
 546:	02054263          	bltz	a0,56a <stat+0x36>
 54a:	e426                	sd	s1,8(sp)
 54c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 54e:	85ca                	mv	a1,s2
 550:	1a2000ef          	jal	6f2 <fstat>
 554:	892a                	mv	s2,a0
  close(fd);
 556:	8526                	mv	a0,s1
 558:	16a000ef          	jal	6c2 <close>
  return r;
 55c:	64a2                	ld	s1,8(sp)
}
 55e:	854a                	mv	a0,s2
 560:	60e2                	ld	ra,24(sp)
 562:	6442                	ld	s0,16(sp)
 564:	6902                	ld	s2,0(sp)
 566:	6105                	addi	sp,sp,32
 568:	8082                	ret
    return -1;
 56a:	57fd                	li	a5,-1
 56c:	893e                	mv	s2,a5
 56e:	bfc5                	j	55e <stat+0x2a>

0000000000000570 <atoi>:

int
atoi(const char *s)
{
 570:	1141                	addi	sp,sp,-16
 572:	e406                	sd	ra,8(sp)
 574:	e022                	sd	s0,0(sp)
 576:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 578:	00054683          	lbu	a3,0(a0)
 57c:	fd06879b          	addiw	a5,a3,-48
 580:	0ff7f793          	zext.b	a5,a5
 584:	4625                	li	a2,9
 586:	02f66963          	bltu	a2,a5,5b8 <atoi+0x48>
 58a:	872a                	mv	a4,a0
  n = 0;
 58c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 58e:	0705                	addi	a4,a4,1
 590:	0025179b          	slliw	a5,a0,0x2
 594:	9fa9                	addw	a5,a5,a0
 596:	0017979b          	slliw	a5,a5,0x1
 59a:	9fb5                	addw	a5,a5,a3
 59c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 5a0:	00074683          	lbu	a3,0(a4)
 5a4:	fd06879b          	addiw	a5,a3,-48
 5a8:	0ff7f793          	zext.b	a5,a5
 5ac:	fef671e3          	bgeu	a2,a5,58e <atoi+0x1e>
  return n;
}
 5b0:	60a2                	ld	ra,8(sp)
 5b2:	6402                	ld	s0,0(sp)
 5b4:	0141                	addi	sp,sp,16
 5b6:	8082                	ret
  n = 0;
 5b8:	4501                	li	a0,0
 5ba:	bfdd                	j	5b0 <atoi+0x40>

00000000000005bc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5bc:	1141                	addi	sp,sp,-16
 5be:	e406                	sd	ra,8(sp)
 5c0:	e022                	sd	s0,0(sp)
 5c2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5c4:	02b57563          	bgeu	a0,a1,5ee <memmove+0x32>
    while(n-- > 0)
 5c8:	00c05f63          	blez	a2,5e6 <memmove+0x2a>
 5cc:	1602                	slli	a2,a2,0x20
 5ce:	9201                	srli	a2,a2,0x20
 5d0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5d4:	872a                	mv	a4,a0
      *dst++ = *src++;
 5d6:	0585                	addi	a1,a1,1
 5d8:	0705                	addi	a4,a4,1
 5da:	fff5c683          	lbu	a3,-1(a1)
 5de:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5e2:	fee79ae3          	bne	a5,a4,5d6 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5e6:	60a2                	ld	ra,8(sp)
 5e8:	6402                	ld	s0,0(sp)
 5ea:	0141                	addi	sp,sp,16
 5ec:	8082                	ret
    while(n-- > 0)
 5ee:	fec05ce3          	blez	a2,5e6 <memmove+0x2a>
    dst += n;
 5f2:	00c50733          	add	a4,a0,a2
    src += n;
 5f6:	95b2                	add	a1,a1,a2
 5f8:	fff6079b          	addiw	a5,a2,-1
 5fc:	1782                	slli	a5,a5,0x20
 5fe:	9381                	srli	a5,a5,0x20
 600:	fff7c793          	not	a5,a5
 604:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 606:	15fd                	addi	a1,a1,-1
 608:	177d                	addi	a4,a4,-1
 60a:	0005c683          	lbu	a3,0(a1)
 60e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 612:	fef71ae3          	bne	a4,a5,606 <memmove+0x4a>
 616:	bfc1                	j	5e6 <memmove+0x2a>

0000000000000618 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 618:	1141                	addi	sp,sp,-16
 61a:	e406                	sd	ra,8(sp)
 61c:	e022                	sd	s0,0(sp)
 61e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 620:	c61d                	beqz	a2,64e <memcmp+0x36>
 622:	1602                	slli	a2,a2,0x20
 624:	9201                	srli	a2,a2,0x20
 626:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 62a:	00054783          	lbu	a5,0(a0)
 62e:	0005c703          	lbu	a4,0(a1)
 632:	00e79863          	bne	a5,a4,642 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 636:	0505                	addi	a0,a0,1
    p2++;
 638:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 63a:	fed518e3          	bne	a0,a3,62a <memcmp+0x12>
  }
  return 0;
 63e:	4501                	li	a0,0
 640:	a019                	j	646 <memcmp+0x2e>
      return *p1 - *p2;
 642:	40e7853b          	subw	a0,a5,a4
}
 646:	60a2                	ld	ra,8(sp)
 648:	6402                	ld	s0,0(sp)
 64a:	0141                	addi	sp,sp,16
 64c:	8082                	ret
  return 0;
 64e:	4501                	li	a0,0
 650:	bfdd                	j	646 <memcmp+0x2e>

0000000000000652 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 652:	1141                	addi	sp,sp,-16
 654:	e406                	sd	ra,8(sp)
 656:	e022                	sd	s0,0(sp)
 658:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 65a:	f63ff0ef          	jal	5bc <memmove>
}
 65e:	60a2                	ld	ra,8(sp)
 660:	6402                	ld	s0,0(sp)
 662:	0141                	addi	sp,sp,16
 664:	8082                	ret

0000000000000666 <sbrk>:

char *
sbrk(int n) {
 666:	1141                	addi	sp,sp,-16
 668:	e406                	sd	ra,8(sp)
 66a:	e022                	sd	s0,0(sp)
 66c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 66e:	4585                	li	a1,1
 670:	0b2000ef          	jal	722 <sys_sbrk>
}
 674:	60a2                	ld	ra,8(sp)
 676:	6402                	ld	s0,0(sp)
 678:	0141                	addi	sp,sp,16
 67a:	8082                	ret

000000000000067c <sbrklazy>:

char *
sbrklazy(int n) {
 67c:	1141                	addi	sp,sp,-16
 67e:	e406                	sd	ra,8(sp)
 680:	e022                	sd	s0,0(sp)
 682:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 684:	4589                	li	a1,2
 686:	09c000ef          	jal	722 <sys_sbrk>
}
 68a:	60a2                	ld	ra,8(sp)
 68c:	6402                	ld	s0,0(sp)
 68e:	0141                	addi	sp,sp,16
 690:	8082                	ret

0000000000000692 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 692:	4885                	li	a7,1
 ecall
 694:	00000073          	ecall
 ret
 698:	8082                	ret

000000000000069a <exit>:
.global exit
exit:
 li a7, SYS_exit
 69a:	4889                	li	a7,2
 ecall
 69c:	00000073          	ecall
 ret
 6a0:	8082                	ret

00000000000006a2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6a2:	488d                	li	a7,3
 ecall
 6a4:	00000073          	ecall
 ret
 6a8:	8082                	ret

00000000000006aa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6aa:	4891                	li	a7,4
 ecall
 6ac:	00000073          	ecall
 ret
 6b0:	8082                	ret

00000000000006b2 <read>:
.global read
read:
 li a7, SYS_read
 6b2:	4895                	li	a7,5
 ecall
 6b4:	00000073          	ecall
 ret
 6b8:	8082                	ret

00000000000006ba <write>:
.global write
write:
 li a7, SYS_write
 6ba:	48c1                	li	a7,16
 ecall
 6bc:	00000073          	ecall
 ret
 6c0:	8082                	ret

00000000000006c2 <close>:
.global close
close:
 li a7, SYS_close
 6c2:	48d5                	li	a7,21
 ecall
 6c4:	00000073          	ecall
 ret
 6c8:	8082                	ret

00000000000006ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 6ca:	4899                	li	a7,6
 ecall
 6cc:	00000073          	ecall
 ret
 6d0:	8082                	ret

00000000000006d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6d2:	489d                	li	a7,7
 ecall
 6d4:	00000073          	ecall
 ret
 6d8:	8082                	ret

00000000000006da <open>:
.global open
open:
 li a7, SYS_open
 6da:	48bd                	li	a7,15
 ecall
 6dc:	00000073          	ecall
 ret
 6e0:	8082                	ret

00000000000006e2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6e2:	48c5                	li	a7,17
 ecall
 6e4:	00000073          	ecall
 ret
 6e8:	8082                	ret

00000000000006ea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6ea:	48c9                	li	a7,18
 ecall
 6ec:	00000073          	ecall
 ret
 6f0:	8082                	ret

00000000000006f2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6f2:	48a1                	li	a7,8
 ecall
 6f4:	00000073          	ecall
 ret
 6f8:	8082                	ret

00000000000006fa <link>:
.global link
link:
 li a7, SYS_link
 6fa:	48cd                	li	a7,19
 ecall
 6fc:	00000073          	ecall
 ret
 700:	8082                	ret

0000000000000702 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 702:	48d1                	li	a7,20
 ecall
 704:	00000073          	ecall
 ret
 708:	8082                	ret

000000000000070a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 70a:	48a5                	li	a7,9
 ecall
 70c:	00000073          	ecall
 ret
 710:	8082                	ret

0000000000000712 <dup>:
.global dup
dup:
 li a7, SYS_dup
 712:	48a9                	li	a7,10
 ecall
 714:	00000073          	ecall
 ret
 718:	8082                	ret

000000000000071a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 71a:	48ad                	li	a7,11
 ecall
 71c:	00000073          	ecall
 ret
 720:	8082                	ret

0000000000000722 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 722:	48b1                	li	a7,12
 ecall
 724:	00000073          	ecall
 ret
 728:	8082                	ret

000000000000072a <pause>:
.global pause
pause:
 li a7, SYS_pause
 72a:	48b5                	li	a7,13
 ecall
 72c:	00000073          	ecall
 ret
 730:	8082                	ret

0000000000000732 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 732:	48b9                	li	a7,14
 ecall
 734:	00000073          	ecall
 ret
 738:	8082                	ret

000000000000073a <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 73a:	48d9                	li	a7,22
 ecall
 73c:	00000073          	ecall
 ret
 740:	8082                	ret

0000000000000742 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 742:	48dd                	li	a7,23
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 74a:	1101                	addi	sp,sp,-32
 74c:	ec06                	sd	ra,24(sp)
 74e:	e822                	sd	s0,16(sp)
 750:	1000                	addi	s0,sp,32
 752:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 756:	4605                	li	a2,1
 758:	fef40593          	addi	a1,s0,-17
 75c:	f5fff0ef          	jal	6ba <write>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6105                	addi	sp,sp,32
 766:	8082                	ret

0000000000000768 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 768:	715d                	addi	sp,sp,-80
 76a:	e486                	sd	ra,72(sp)
 76c:	e0a2                	sd	s0,64(sp)
 76e:	f84a                	sd	s2,48(sp)
 770:	f44e                	sd	s3,40(sp)
 772:	0880                	addi	s0,sp,80
 774:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 776:	c6d1                	beqz	a3,802 <printint+0x9a>
 778:	0805d563          	bgez	a1,802 <printint+0x9a>
    neg = 1;
    x = -xx;
 77c:	40b005b3          	neg	a1,a1
    neg = 1;
 780:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 782:	fb840993          	addi	s3,s0,-72
  neg = 0;
 786:	86ce                	mv	a3,s3
  i = 0;
 788:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 78a:	00001817          	auipc	a6,0x1
 78e:	92e80813          	addi	a6,a6,-1746 # 10b8 <digits>
 792:	88ba                	mv	a7,a4
 794:	0017051b          	addiw	a0,a4,1
 798:	872a                	mv	a4,a0
 79a:	02c5f7b3          	remu	a5,a1,a2
 79e:	97c2                	add	a5,a5,a6
 7a0:	0007c783          	lbu	a5,0(a5)
 7a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7a8:	87ae                	mv	a5,a1
 7aa:	02c5d5b3          	divu	a1,a1,a2
 7ae:	0685                	addi	a3,a3,1
 7b0:	fec7f1e3          	bgeu	a5,a2,792 <printint+0x2a>
  if(neg)
 7b4:	00030c63          	beqz	t1,7cc <printint+0x64>
    buf[i++] = '-';
 7b8:	fd050793          	addi	a5,a0,-48
 7bc:	00878533          	add	a0,a5,s0
 7c0:	02d00793          	li	a5,45
 7c4:	fef50423          	sb	a5,-24(a0)
 7c8:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 7cc:	02e05563          	blez	a4,7f6 <printint+0x8e>
 7d0:	fc26                	sd	s1,56(sp)
 7d2:	377d                	addiw	a4,a4,-1
 7d4:	00e984b3          	add	s1,s3,a4
 7d8:	19fd                	addi	s3,s3,-1
 7da:	99ba                	add	s3,s3,a4
 7dc:	1702                	slli	a4,a4,0x20
 7de:	9301                	srli	a4,a4,0x20
 7e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7e4:	0004c583          	lbu	a1,0(s1)
 7e8:	854a                	mv	a0,s2
 7ea:	f61ff0ef          	jal	74a <putc>
  while(--i >= 0)
 7ee:	14fd                	addi	s1,s1,-1
 7f0:	ff349ae3          	bne	s1,s3,7e4 <printint+0x7c>
 7f4:	74e2                	ld	s1,56(sp)
}
 7f6:	60a6                	ld	ra,72(sp)
 7f8:	6406                	ld	s0,64(sp)
 7fa:	7942                	ld	s2,48(sp)
 7fc:	79a2                	ld	s3,40(sp)
 7fe:	6161                	addi	sp,sp,80
 800:	8082                	ret
  neg = 0;
 802:	4301                	li	t1,0
 804:	bfbd                	j	782 <printint+0x1a>

0000000000000806 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 806:	711d                	addi	sp,sp,-96
 808:	ec86                	sd	ra,88(sp)
 80a:	e8a2                	sd	s0,80(sp)
 80c:	e4a6                	sd	s1,72(sp)
 80e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 810:	0005c483          	lbu	s1,0(a1)
 814:	22048363          	beqz	s1,a3a <vprintf+0x234>
 818:	e0ca                	sd	s2,64(sp)
 81a:	fc4e                	sd	s3,56(sp)
 81c:	f852                	sd	s4,48(sp)
 81e:	f456                	sd	s5,40(sp)
 820:	f05a                	sd	s6,32(sp)
 822:	ec5e                	sd	s7,24(sp)
 824:	e862                	sd	s8,16(sp)
 826:	8b2a                	mv	s6,a0
 828:	8a2e                	mv	s4,a1
 82a:	8bb2                	mv	s7,a2
  state = 0;
 82c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 82e:	4901                	li	s2,0
 830:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 832:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 836:	06400c13          	li	s8,100
 83a:	a00d                	j	85c <vprintf+0x56>
        putc(fd, c0);
 83c:	85a6                	mv	a1,s1
 83e:	855a                	mv	a0,s6
 840:	f0bff0ef          	jal	74a <putc>
 844:	a019                	j	84a <vprintf+0x44>
    } else if(state == '%'){
 846:	03598363          	beq	s3,s5,86c <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 84a:	0019079b          	addiw	a5,s2,1
 84e:	893e                	mv	s2,a5
 850:	873e                	mv	a4,a5
 852:	97d2                	add	a5,a5,s4
 854:	0007c483          	lbu	s1,0(a5)
 858:	1c048a63          	beqz	s1,a2c <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 85c:	0004879b          	sext.w	a5,s1
    if(state == 0){
 860:	fe0993e3          	bnez	s3,846 <vprintf+0x40>
      if(c0 == '%'){
 864:	fd579ce3          	bne	a5,s5,83c <vprintf+0x36>
        state = '%';
 868:	89be                	mv	s3,a5
 86a:	b7c5                	j	84a <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 86c:	00ea06b3          	add	a3,s4,a4
 870:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 874:	1c060863          	beqz	a2,a44 <vprintf+0x23e>
      if(c0 == 'd'){
 878:	03878763          	beq	a5,s8,8a6 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 87c:	f9478693          	addi	a3,a5,-108
 880:	0016b693          	seqz	a3,a3
 884:	f9c60593          	addi	a1,a2,-100
 888:	e99d                	bnez	a1,8be <vprintf+0xb8>
 88a:	ca95                	beqz	a3,8be <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 88c:	008b8493          	addi	s1,s7,8
 890:	4685                	li	a3,1
 892:	4629                	li	a2,10
 894:	000bb583          	ld	a1,0(s7)
 898:	855a                	mv	a0,s6
 89a:	ecfff0ef          	jal	768 <printint>
        i += 1;
 89e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 8a0:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 8a2:	4981                	li	s3,0
 8a4:	b75d                	j	84a <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 8a6:	008b8493          	addi	s1,s7,8
 8aa:	4685                	li	a3,1
 8ac:	4629                	li	a2,10
 8ae:	000ba583          	lw	a1,0(s7)
 8b2:	855a                	mv	a0,s6
 8b4:	eb5ff0ef          	jal	768 <printint>
 8b8:	8ba6                	mv	s7,s1
      state = 0;
 8ba:	4981                	li	s3,0
 8bc:	b779                	j	84a <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 8be:	9752                	add	a4,a4,s4
 8c0:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8c4:	f9460713          	addi	a4,a2,-108
 8c8:	00173713          	seqz	a4,a4
 8cc:	8f75                	and	a4,a4,a3
 8ce:	f9c58513          	addi	a0,a1,-100
 8d2:	18051363          	bnez	a0,a58 <vprintf+0x252>
 8d6:	18070163          	beqz	a4,a58 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8da:	008b8493          	addi	s1,s7,8
 8de:	4685                	li	a3,1
 8e0:	4629                	li	a2,10
 8e2:	000bb583          	ld	a1,0(s7)
 8e6:	855a                	mv	a0,s6
 8e8:	e81ff0ef          	jal	768 <printint>
        i += 2;
 8ec:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8ee:	8ba6                	mv	s7,s1
      state = 0;
 8f0:	4981                	li	s3,0
        i += 2;
 8f2:	bfa1                	j	84a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8f4:	008b8493          	addi	s1,s7,8
 8f8:	4681                	li	a3,0
 8fa:	4629                	li	a2,10
 8fc:	000be583          	lwu	a1,0(s7)
 900:	855a                	mv	a0,s6
 902:	e67ff0ef          	jal	768 <printint>
 906:	8ba6                	mv	s7,s1
      state = 0;
 908:	4981                	li	s3,0
 90a:	b781                	j	84a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 90c:	008b8493          	addi	s1,s7,8
 910:	4681                	li	a3,0
 912:	4629                	li	a2,10
 914:	000bb583          	ld	a1,0(s7)
 918:	855a                	mv	a0,s6
 91a:	e4fff0ef          	jal	768 <printint>
        i += 1;
 91e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 920:	8ba6                	mv	s7,s1
      state = 0;
 922:	4981                	li	s3,0
 924:	b71d                	j	84a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 926:	008b8493          	addi	s1,s7,8
 92a:	4681                	li	a3,0
 92c:	4629                	li	a2,10
 92e:	000bb583          	ld	a1,0(s7)
 932:	855a                	mv	a0,s6
 934:	e35ff0ef          	jal	768 <printint>
        i += 2;
 938:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 93a:	8ba6                	mv	s7,s1
      state = 0;
 93c:	4981                	li	s3,0
        i += 2;
 93e:	b731                	j	84a <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 940:	008b8493          	addi	s1,s7,8
 944:	4681                	li	a3,0
 946:	4641                	li	a2,16
 948:	000be583          	lwu	a1,0(s7)
 94c:	855a                	mv	a0,s6
 94e:	e1bff0ef          	jal	768 <printint>
 952:	8ba6                	mv	s7,s1
      state = 0;
 954:	4981                	li	s3,0
 956:	bdd5                	j	84a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 958:	008b8493          	addi	s1,s7,8
 95c:	4681                	li	a3,0
 95e:	4641                	li	a2,16
 960:	000bb583          	ld	a1,0(s7)
 964:	855a                	mv	a0,s6
 966:	e03ff0ef          	jal	768 <printint>
        i += 1;
 96a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 96c:	8ba6                	mv	s7,s1
      state = 0;
 96e:	4981                	li	s3,0
 970:	bde9                	j	84a <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 972:	008b8493          	addi	s1,s7,8
 976:	4681                	li	a3,0
 978:	4641                	li	a2,16
 97a:	000bb583          	ld	a1,0(s7)
 97e:	855a                	mv	a0,s6
 980:	de9ff0ef          	jal	768 <printint>
        i += 2;
 984:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 986:	8ba6                	mv	s7,s1
      state = 0;
 988:	4981                	li	s3,0
        i += 2;
 98a:	b5c1                	j	84a <vprintf+0x44>
 98c:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 98e:	008b8793          	addi	a5,s7,8
 992:	8cbe                	mv	s9,a5
 994:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 998:	03000593          	li	a1,48
 99c:	855a                	mv	a0,s6
 99e:	dadff0ef          	jal	74a <putc>
  putc(fd, 'x');
 9a2:	07800593          	li	a1,120
 9a6:	855a                	mv	a0,s6
 9a8:	da3ff0ef          	jal	74a <putc>
 9ac:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9ae:	00000b97          	auipc	s7,0x0
 9b2:	70ab8b93          	addi	s7,s7,1802 # 10b8 <digits>
 9b6:	03c9d793          	srli	a5,s3,0x3c
 9ba:	97de                	add	a5,a5,s7
 9bc:	0007c583          	lbu	a1,0(a5)
 9c0:	855a                	mv	a0,s6
 9c2:	d89ff0ef          	jal	74a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9c6:	0992                	slli	s3,s3,0x4
 9c8:	34fd                	addiw	s1,s1,-1
 9ca:	f4f5                	bnez	s1,9b6 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 9cc:	8be6                	mv	s7,s9
      state = 0;
 9ce:	4981                	li	s3,0
 9d0:	6ca2                	ld	s9,8(sp)
 9d2:	bda5                	j	84a <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 9d4:	008b8493          	addi	s1,s7,8
 9d8:	000bc583          	lbu	a1,0(s7)
 9dc:	855a                	mv	a0,s6
 9de:	d6dff0ef          	jal	74a <putc>
 9e2:	8ba6                	mv	s7,s1
      state = 0;
 9e4:	4981                	li	s3,0
 9e6:	b595                	j	84a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 9e8:	008b8993          	addi	s3,s7,8
 9ec:	000bb483          	ld	s1,0(s7)
 9f0:	cc91                	beqz	s1,a0c <vprintf+0x206>
        for(; *s; s++)
 9f2:	0004c583          	lbu	a1,0(s1)
 9f6:	c985                	beqz	a1,a26 <vprintf+0x220>
          putc(fd, *s);
 9f8:	855a                	mv	a0,s6
 9fa:	d51ff0ef          	jal	74a <putc>
        for(; *s; s++)
 9fe:	0485                	addi	s1,s1,1
 a00:	0004c583          	lbu	a1,0(s1)
 a04:	f9f5                	bnez	a1,9f8 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 a06:	8bce                	mv	s7,s3
      state = 0;
 a08:	4981                	li	s3,0
 a0a:	b581                	j	84a <vprintf+0x44>
          s = "(null)";
 a0c:	00000497          	auipc	s1,0x0
 a10:	6a448493          	addi	s1,s1,1700 # 10b0 <malloc+0x508>
        for(; *s; s++)
 a14:	02800593          	li	a1,40
 a18:	b7c5                	j	9f8 <vprintf+0x1f2>
        putc(fd, '%');
 a1a:	85be                	mv	a1,a5
 a1c:	855a                	mv	a0,s6
 a1e:	d2dff0ef          	jal	74a <putc>
      state = 0;
 a22:	4981                	li	s3,0
 a24:	b51d                	j	84a <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 a26:	8bce                	mv	s7,s3
      state = 0;
 a28:	4981                	li	s3,0
 a2a:	b505                	j	84a <vprintf+0x44>
 a2c:	6906                	ld	s2,64(sp)
 a2e:	79e2                	ld	s3,56(sp)
 a30:	7a42                	ld	s4,48(sp)
 a32:	7aa2                	ld	s5,40(sp)
 a34:	7b02                	ld	s6,32(sp)
 a36:	6be2                	ld	s7,24(sp)
 a38:	6c42                	ld	s8,16(sp)
    }
  }
}
 a3a:	60e6                	ld	ra,88(sp)
 a3c:	6446                	ld	s0,80(sp)
 a3e:	64a6                	ld	s1,72(sp)
 a40:	6125                	addi	sp,sp,96
 a42:	8082                	ret
      if(c0 == 'd'){
 a44:	06400713          	li	a4,100
 a48:	e4e78fe3          	beq	a5,a4,8a6 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 a4c:	f9478693          	addi	a3,a5,-108
 a50:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 a54:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 a56:	4701                	li	a4,0
      } else if(c0 == 'u'){
 a58:	07500513          	li	a0,117
 a5c:	e8a78ce3          	beq	a5,a0,8f4 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 a60:	f8b60513          	addi	a0,a2,-117
 a64:	e119                	bnez	a0,a6a <vprintf+0x264>
 a66:	ea0693e3          	bnez	a3,90c <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 a6a:	f8b58513          	addi	a0,a1,-117
 a6e:	e119                	bnez	a0,a74 <vprintf+0x26e>
 a70:	ea071be3          	bnez	a4,926 <vprintf+0x120>
      } else if(c0 == 'x'){
 a74:	07800513          	li	a0,120
 a78:	eca784e3          	beq	a5,a0,940 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 a7c:	f8860613          	addi	a2,a2,-120
 a80:	e219                	bnez	a2,a86 <vprintf+0x280>
 a82:	ec069be3          	bnez	a3,958 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 a86:	f8858593          	addi	a1,a1,-120
 a8a:	e199                	bnez	a1,a90 <vprintf+0x28a>
 a8c:	ee0713e3          	bnez	a4,972 <vprintf+0x16c>
      } else if(c0 == 'p'){
 a90:	07000713          	li	a4,112
 a94:	eee78ce3          	beq	a5,a4,98c <vprintf+0x186>
      } else if(c0 == 'c'){
 a98:	06300713          	li	a4,99
 a9c:	f2e78ce3          	beq	a5,a4,9d4 <vprintf+0x1ce>
      } else if(c0 == 's'){
 aa0:	07300713          	li	a4,115
 aa4:	f4e782e3          	beq	a5,a4,9e8 <vprintf+0x1e2>
      } else if(c0 == '%'){
 aa8:	02500713          	li	a4,37
 aac:	f6e787e3          	beq	a5,a4,a1a <vprintf+0x214>
        putc(fd, '%');
 ab0:	02500593          	li	a1,37
 ab4:	855a                	mv	a0,s6
 ab6:	c95ff0ef          	jal	74a <putc>
        putc(fd, c0);
 aba:	85a6                	mv	a1,s1
 abc:	855a                	mv	a0,s6
 abe:	c8dff0ef          	jal	74a <putc>
      state = 0;
 ac2:	4981                	li	s3,0
 ac4:	b359                	j	84a <vprintf+0x44>

0000000000000ac6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ac6:	715d                	addi	sp,sp,-80
 ac8:	ec06                	sd	ra,24(sp)
 aca:	e822                	sd	s0,16(sp)
 acc:	1000                	addi	s0,sp,32
 ace:	e010                	sd	a2,0(s0)
 ad0:	e414                	sd	a3,8(s0)
 ad2:	e818                	sd	a4,16(s0)
 ad4:	ec1c                	sd	a5,24(s0)
 ad6:	03043023          	sd	a6,32(s0)
 ada:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ade:	8622                	mv	a2,s0
 ae0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ae4:	d23ff0ef          	jal	806 <vprintf>
}
 ae8:	60e2                	ld	ra,24(sp)
 aea:	6442                	ld	s0,16(sp)
 aec:	6161                	addi	sp,sp,80
 aee:	8082                	ret

0000000000000af0 <printf>:

void
printf(const char *fmt, ...)
{
 af0:	711d                	addi	sp,sp,-96
 af2:	ec06                	sd	ra,24(sp)
 af4:	e822                	sd	s0,16(sp)
 af6:	1000                	addi	s0,sp,32
 af8:	e40c                	sd	a1,8(s0)
 afa:	e810                	sd	a2,16(s0)
 afc:	ec14                	sd	a3,24(s0)
 afe:	f018                	sd	a4,32(s0)
 b00:	f41c                	sd	a5,40(s0)
 b02:	03043823          	sd	a6,48(s0)
 b06:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b0a:	00840613          	addi	a2,s0,8
 b0e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b12:	85aa                	mv	a1,a0
 b14:	4505                	li	a0,1
 b16:	cf1ff0ef          	jal	806 <vprintf>
}
 b1a:	60e2                	ld	ra,24(sp)
 b1c:	6442                	ld	s0,16(sp)
 b1e:	6125                	addi	sp,sp,96
 b20:	8082                	ret

0000000000000b22 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b22:	1141                	addi	sp,sp,-16
 b24:	e406                	sd	ra,8(sp)
 b26:	e022                	sd	s0,0(sp)
 b28:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b2a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b2e:	00001797          	auipc	a5,0x1
 b32:	4d27b783          	ld	a5,1234(a5) # 2000 <freep>
 b36:	a039                	j	b44 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b38:	6398                	ld	a4,0(a5)
 b3a:	00e7e463          	bltu	a5,a4,b42 <free+0x20>
 b3e:	00e6ea63          	bltu	a3,a4,b52 <free+0x30>
{
 b42:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b44:	fed7fae3          	bgeu	a5,a3,b38 <free+0x16>
 b48:	6398                	ld	a4,0(a5)
 b4a:	00e6e463          	bltu	a3,a4,b52 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b4e:	fee7eae3          	bltu	a5,a4,b42 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b52:	ff852583          	lw	a1,-8(a0)
 b56:	6390                	ld	a2,0(a5)
 b58:	02059813          	slli	a6,a1,0x20
 b5c:	01c85713          	srli	a4,a6,0x1c
 b60:	9736                	add	a4,a4,a3
 b62:	02e60563          	beq	a2,a4,b8c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 b66:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 b6a:	4790                	lw	a2,8(a5)
 b6c:	02061593          	slli	a1,a2,0x20
 b70:	01c5d713          	srli	a4,a1,0x1c
 b74:	973e                	add	a4,a4,a5
 b76:	02e68263          	beq	a3,a4,b9a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 b7a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b7c:	00001717          	auipc	a4,0x1
 b80:	48f73223          	sd	a5,1156(a4) # 2000 <freep>
}
 b84:	60a2                	ld	ra,8(sp)
 b86:	6402                	ld	s0,0(sp)
 b88:	0141                	addi	sp,sp,16
 b8a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 b8c:	4618                	lw	a4,8(a2)
 b8e:	9f2d                	addw	a4,a4,a1
 b90:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b94:	6398                	ld	a4,0(a5)
 b96:	6310                	ld	a2,0(a4)
 b98:	b7f9                	j	b66 <free+0x44>
    p->s.size += bp->s.size;
 b9a:	ff852703          	lw	a4,-8(a0)
 b9e:	9f31                	addw	a4,a4,a2
 ba0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 ba2:	ff053683          	ld	a3,-16(a0)
 ba6:	bfd1                	j	b7a <free+0x58>

0000000000000ba8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ba8:	7139                	addi	sp,sp,-64
 baa:	fc06                	sd	ra,56(sp)
 bac:	f822                	sd	s0,48(sp)
 bae:	f04a                	sd	s2,32(sp)
 bb0:	ec4e                	sd	s3,24(sp)
 bb2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bb4:	02051993          	slli	s3,a0,0x20
 bb8:	0209d993          	srli	s3,s3,0x20
 bbc:	09bd                	addi	s3,s3,15
 bbe:	0049d993          	srli	s3,s3,0x4
 bc2:	2985                	addiw	s3,s3,1
 bc4:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 bc6:	00001517          	auipc	a0,0x1
 bca:	43a53503          	ld	a0,1082(a0) # 2000 <freep>
 bce:	c905                	beqz	a0,bfe <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bd0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bd2:	4798                	lw	a4,8(a5)
 bd4:	09377663          	bgeu	a4,s3,c60 <malloc+0xb8>
 bd8:	f426                	sd	s1,40(sp)
 bda:	e852                	sd	s4,16(sp)
 bdc:	e456                	sd	s5,8(sp)
 bde:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 be0:	8a4e                	mv	s4,s3
 be2:	6705                	lui	a4,0x1
 be4:	00e9f363          	bgeu	s3,a4,bea <malloc+0x42>
 be8:	6a05                	lui	s4,0x1
 bea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bf2:	00001497          	auipc	s1,0x1
 bf6:	40e48493          	addi	s1,s1,1038 # 2000 <freep>
  if(p == SBRK_ERROR)
 bfa:	5afd                	li	s5,-1
 bfc:	a83d                	j	c3a <malloc+0x92>
 bfe:	f426                	sd	s1,40(sp)
 c00:	e852                	sd	s4,16(sp)
 c02:	e456                	sd	s5,8(sp)
 c04:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c06:	00001797          	auipc	a5,0x1
 c0a:	40a78793          	addi	a5,a5,1034 # 2010 <base>
 c0e:	00001717          	auipc	a4,0x1
 c12:	3ef73923          	sd	a5,1010(a4) # 2000 <freep>
 c16:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c18:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c1c:	b7d1                	j	be0 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 c1e:	6398                	ld	a4,0(a5)
 c20:	e118                	sd	a4,0(a0)
 c22:	a899                	j	c78 <malloc+0xd0>
  hp->s.size = nu;
 c24:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c28:	0541                	addi	a0,a0,16
 c2a:	ef9ff0ef          	jal	b22 <free>
  return freep;
 c2e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 c30:	c125                	beqz	a0,c90 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c32:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c34:	4798                	lw	a4,8(a5)
 c36:	03277163          	bgeu	a4,s2,c58 <malloc+0xb0>
    if(p == freep)
 c3a:	6098                	ld	a4,0(s1)
 c3c:	853e                	mv	a0,a5
 c3e:	fef71ae3          	bne	a4,a5,c32 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 c42:	8552                	mv	a0,s4
 c44:	a23ff0ef          	jal	666 <sbrk>
  if(p == SBRK_ERROR)
 c48:	fd551ee3          	bne	a0,s5,c24 <malloc+0x7c>
        return 0;
 c4c:	4501                	li	a0,0
 c4e:	74a2                	ld	s1,40(sp)
 c50:	6a42                	ld	s4,16(sp)
 c52:	6aa2                	ld	s5,8(sp)
 c54:	6b02                	ld	s6,0(sp)
 c56:	a03d                	j	c84 <malloc+0xdc>
 c58:	74a2                	ld	s1,40(sp)
 c5a:	6a42                	ld	s4,16(sp)
 c5c:	6aa2                	ld	s5,8(sp)
 c5e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 c60:	fae90fe3          	beq	s2,a4,c1e <malloc+0x76>
        p->s.size -= nunits;
 c64:	4137073b          	subw	a4,a4,s3
 c68:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c6a:	02071693          	slli	a3,a4,0x20
 c6e:	01c6d713          	srli	a4,a3,0x1c
 c72:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c74:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c78:	00001717          	auipc	a4,0x1
 c7c:	38a73423          	sd	a0,904(a4) # 2000 <freep>
      return (void*)(p + 1);
 c80:	01078513          	addi	a0,a5,16
  }
}
 c84:	70e2                	ld	ra,56(sp)
 c86:	7442                	ld	s0,48(sp)
 c88:	7902                	ld	s2,32(sp)
 c8a:	69e2                	ld	s3,24(sp)
 c8c:	6121                	addi	sp,sp,64
 c8e:	8082                	ret
 c90:	74a2                	ld	s1,40(sp)
 c92:	6a42                	ld	s4,16(sp)
 c94:	6aa2                	ld	s5,8(sp)
 c96:	6b02                	ld	s6,0(sp)
 c98:	b7f5                	j	c84 <malloc+0xdc>
