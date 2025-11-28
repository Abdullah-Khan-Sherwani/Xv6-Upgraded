
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
   c:	bb850513          	addi	a0,a0,-1096 # bc0 <malloc+0xf8>
  10:	205000ef          	jal	a14 <printf>
  printf("Running 3 different workloads for ~200 ticks\n");
  14:	00001517          	auipc	a0,0x1
  18:	be450513          	addi	a0,a0,-1052 # bf8 <malloc+0x130>
  1c:	1f9000ef          	jal	a14 <printf>
  printf("  1. Pure CPU-bound (should demote but get boosted)\n");
  20:	00001517          	auipc	a0,0x1
  24:	c0850513          	addi	a0,a0,-1016 # c28 <malloc+0x160>
  28:	1ed000ef          	jal	a14 <printf>
  printf("  2. Pure I/O-bound (should stay high priority)\n");
  2c:	00001517          	auipc	a0,0x1
  30:	c3450513          	addi	a0,a0,-972 # c60 <malloc+0x198>
  34:	1e1000ef          	jal	a14 <printf>
  printf("  3. Mixed workload\n\n");
  38:	00001517          	auipc	a0,0x1
  3c:	c6050513          	addi	a0,a0,-928 # c98 <malloc+0x1d0>
  40:	1d5000ef          	jal	a14 <printf>
  
  // Process 1: Pure CPU-bound
  cpu_pid = fork();
  44:	590000ef          	jal	5d4 <fork>
  if(cpu_pid == 0) {
  48:	10051263          	bnez	a0,14c <main+0x14c>
  4c:	f4a6                	sd	s1,104(sp)
  4e:	f0ca                	sd	s2,96(sp)
  50:	ecce                	sd	s3,88(sp)
  52:	e8d2                	sd	s4,80(sp)
  54:	e4d6                	sd	s5,72(sp)
  56:	e0da                	sd	s6,64(sp)
  58:	fc5e                	sd	s7,56(sp)
  5a:	f862                	sd	s8,48(sp)
  5c:	f466                	sd	s9,40(sp)
  5e:	8aaa                	mv	s5,a0
    struct procinfo info;
    volatile int dummy = 0;
  60:	f8042623          	sw	zero,-116(s0)
    int boost_count = 0;
    int prev_priority = 0;
    
    printf("[CPU-BOUND] Starting...\n");
  64:	00001517          	auipc	a0,0x1
  68:	c4c50513          	addi	a0,a0,-948 # cb0 <malloc+0x1e8>
  6c:	1a9000ef          	jal	a14 <printf>
    
    for(int iter = 0; iter < 80; iter++) {
  70:	89d6                	mv	s3,s5
    int prev_priority = 0;
  72:	8a56                	mv	s4,s5
      // Heavy computation
      for(long j = 0; j < 8000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
  74:	000f4937          	lui	s2,0xf4
  78:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2230>
      for(long j = 0; j < 8000000; j++) {
  7c:	007a14b7          	lui	s1,0x7a1
  80:	20048493          	addi	s1,s1,512 # 7a1200 <base+0x79f1f0>
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
                 boost_count, uptime(), prev_priority, info.priority);
        }
        prev_priority = info.priority;
        
        if(iter % 20 == 0) {
  84:	4bd1                	li	s7,20
          printf("[CPU-BOUND] Tick %d: Q%d (slices=%d)\n", 
  86:	00001c97          	auipc	s9,0x1
  8a:	c82c8c93          	addi	s9,s9,-894 # d08 <malloc+0x240>
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
  8e:	00001c17          	auipc	s8,0x1
  92:	c42c0c13          	addi	s8,s8,-958 # cd0 <malloc+0x208>
    for(int iter = 0; iter < 80; iter++) {
  96:	05000b13          	li	s6,80
  9a:	a005                	j	ba <main+0xba>
          boost_count++;
  9c:	2a85                	addiw	s5,s5,1
          printf("[CPU-BOUND] BOOST #%d detected at tick %d (Q%d->Q%d)\n", 
  9e:	5d6000ef          	jal	674 <uptime>
  a2:	862a                	mv	a2,a0
  a4:	f9842703          	lw	a4,-104(s0)
  a8:	86d2                	mv	a3,s4
  aa:	85d6                	mv	a1,s5
  ac:	8562                	mv	a0,s8
  ae:	167000ef          	jal	a14 <printf>
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
  dc:	5a0000ef          	jal	67c <getprocinfo>
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
  f4:	580000ef          	jal	674 <uptime>
  f8:	85aa                	mv	a1,a0
  fa:	f9c42683          	lw	a3,-100(s0)
  fe:	f9842603          	lw	a2,-104(s0)
 102:	8566                	mv	a0,s9
 104:	111000ef          	jal	a14 <printf>
 108:	b775                	j	b4 <main+0xb4>
                 uptime(), info.priority, info.time_slices);
        }
      }
    }
    
    if(getprocinfo(&info) == 0) {
 10a:	f9040513          	addi	a0,s0,-112
 10e:	56e000ef          	jal	67c <getprocinfo>
 112:	c501                	beqz	a0,11a <main+0x11a>
        printf("[CPU-BOUND] ✓ Received at least one boost!\n");
      } else {
        printf("[CPU-BOUND] ✗ No boosts detected (problem!)\n");
      }
    }
    exit(0);
 114:	4501                	li	a0,0
 116:	4c6000ef          	jal	5dc <exit>
      printf("[CPU-BOUND] FINAL: Q%d, %d boosts detected\n", 
 11a:	8656                	mv	a2,s5
 11c:	f9842583          	lw	a1,-104(s0)
 120:	00001517          	auipc	a0,0x1
 124:	c1050513          	addi	a0,a0,-1008 # d30 <malloc+0x268>
 128:	0ed000ef          	jal	a14 <printf>
      if(boost_count >= 1) {
 12c:	01505963          	blez	s5,13e <main+0x13e>
        printf("[CPU-BOUND] ✓ Received at least one boost!\n");
 130:	00001517          	auipc	a0,0x1
 134:	c3050513          	addi	a0,a0,-976 # d60 <malloc+0x298>
 138:	0dd000ef          	jal	a14 <printf>
 13c:	bfe1                	j	114 <main+0x114>
        printf("[CPU-BOUND] ✗ No boosts detected (problem!)\n");
 13e:	00001517          	auipc	a0,0x1
 142:	c5250513          	addi	a0,a0,-942 # d90 <malloc+0x2c8>
 146:	0cf000ef          	jal	a14 <printf>
 14a:	b7e9                	j	114 <main+0x114>
 14c:	f0ca                	sd	s2,96(sp)
 14e:	ecce                	sd	s3,88(sp)
  }
  
  pause(2);
 150:	4509                	li	a0,2
 152:	51a000ef          	jal	66c <pause>
  
  // Process 2: I/O-bound
  io_pid = fork();
 156:	47e000ef          	jal	5d4 <fork>
 15a:	892a                	mv	s2,a0
  if(io_pid == 0) {
 15c:	e955                	bnez	a0,210 <main+0x210>
 15e:	f4a6                	sd	s1,104(sp)
 160:	e8d2                	sd	s4,80(sp)
 162:	e4d6                	sd	s5,72(sp)
 164:	e0da                	sd	s6,64(sp)
 166:	fc5e                	sd	s7,56(sp)
 168:	f862                	sd	s8,48(sp)
 16a:	f466                	sd	s9,40(sp)
    struct procinfo info;
    volatile int dummy = 0;
 16c:	f8042623          	sw	zero,-116(s0)
    
    printf("[I/O-BOUND] Starting...\n");
 170:	00001517          	auipc	a0,0x1
 174:	c5050513          	addi	a0,a0,-944 # dc0 <malloc+0x2f8>
 178:	09d000ef          	jal	a14 <printf>
    
    for(int iter = 0; iter < 100; iter++) {
      // Brief work
      for(long j = 0; j < 1000000; j++) {
 17c:	000f44b7          	lui	s1,0xf4
 180:	24048493          	addi	s1,s1,576 # f4240 <base+0xf2230>
      }
      
      // Yield frequently
      pause(2);
      
      if(iter % 25 == 0 && getprocinfo(&info) == 0) {
 184:	4a65                	li	s4,25
        printf("[I/O-BOUND] Tick %d: Q%d (slices=%d)\n", 
 186:	00001a97          	auipc	s5,0x1
 18a:	c5aa8a93          	addi	s5,s5,-934 # de0 <malloc+0x318>
    for(int iter = 0; iter < 100; iter++) {
 18e:	06400993          	li	s3,100
 192:	a021                	j	19a <main+0x19a>
 194:	2905                	addiw	s2,s2,1
 196:	05390163          	beq	s2,s3,1d8 <main+0x1d8>
      for(long j = 0; j < 1000000; j++) {
 19a:	4781                	li	a5,0
        dummy = dummy + j;
 19c:	f8c42703          	lw	a4,-116(s0)
 1a0:	9f3d                	addw	a4,a4,a5
 1a2:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 1000000; j++) {
 1a6:	0785                	addi	a5,a5,1
 1a8:	fe979ae3          	bne	a5,s1,19c <main+0x19c>
      pause(2);
 1ac:	4509                	li	a0,2
 1ae:	4be000ef          	jal	66c <pause>
      if(iter % 25 == 0 && getprocinfo(&info) == 0) {
 1b2:	034967bb          	remw	a5,s2,s4
 1b6:	fff9                	bnez	a5,194 <main+0x194>
 1b8:	f9040513          	addi	a0,s0,-112
 1bc:	4c0000ef          	jal	67c <getprocinfo>
 1c0:	f971                	bnez	a0,194 <main+0x194>
        printf("[I/O-BOUND] Tick %d: Q%d (slices=%d)\n", 
 1c2:	4b2000ef          	jal	674 <uptime>
 1c6:	85aa                	mv	a1,a0
 1c8:	f9c42683          	lw	a3,-100(s0)
 1cc:	f9842603          	lw	a2,-104(s0)
 1d0:	8556                	mv	a0,s5
 1d2:	043000ef          	jal	a14 <printf>
 1d6:	bf7d                	j	194 <main+0x194>
               uptime(), info.priority, info.time_slices);
      }
    }
    
    if(getprocinfo(&info) == 0) {
 1d8:	f9040513          	addi	a0,s0,-112
 1dc:	4a0000ef          	jal	67c <getprocinfo>
 1e0:	c501                	beqz	a0,1e8 <main+0x1e8>
      printf("[I/O-BOUND] FINAL: Q%d\n", info.priority);
      if(info.priority <= 1) {
        printf("[I/O-BOUND] ✓ Maintained high priority\n");
      }
    }
    exit(0);
 1e2:	4501                	li	a0,0
 1e4:	3f8000ef          	jal	5dc <exit>
      printf("[I/O-BOUND] FINAL: Q%d\n", info.priority);
 1e8:	f9842583          	lw	a1,-104(s0)
 1ec:	00001517          	auipc	a0,0x1
 1f0:	c1c50513          	addi	a0,a0,-996 # e08 <malloc+0x340>
 1f4:	021000ef          	jal	a14 <printf>
      if(info.priority <= 1) {
 1f8:	f9842703          	lw	a4,-104(s0)
 1fc:	4785                	li	a5,1
 1fe:	fee7c2e3          	blt	a5,a4,1e2 <main+0x1e2>
        printf("[I/O-BOUND] ✓ Maintained high priority\n");
 202:	00001517          	auipc	a0,0x1
 206:	c1e50513          	addi	a0,a0,-994 # e20 <malloc+0x358>
 20a:	00b000ef          	jal	a14 <printf>
 20e:	bfd1                	j	1e2 <main+0x1e2>
  }
  
  pause(2);
 210:	4509                	li	a0,2
 212:	45a000ef          	jal	66c <pause>
  
  // Process 3: Mixed workload
  mixed_pid = fork();
 216:	3be000ef          	jal	5d4 <fork>
 21a:	89aa                	mv	s3,a0
  if(mixed_pid == 0) {
 21c:	e94d                	bnez	a0,2ce <main+0x2ce>
 21e:	f4a6                	sd	s1,104(sp)
 220:	e8d2                	sd	s4,80(sp)
 222:	e4d6                	sd	s5,72(sp)
 224:	e0da                	sd	s6,64(sp)
 226:	fc5e                	sd	s7,56(sp)
 228:	f862                	sd	s8,48(sp)
 22a:	f466                	sd	s9,40(sp)
    struct procinfo info;
    volatile int dummy = 0;
 22c:	f8042623          	sw	zero,-116(s0)
    
    printf("[MIXED] Starting...\n");
 230:	00001517          	auipc	a0,0x1
 234:	c2050513          	addi	a0,a0,-992 # e50 <malloc+0x388>
 238:	7dc000ef          	jal	a14 <printf>
    
    for(int iter = 0; iter < 50; iter++) {
      // Alternate: CPU burst then sleep
      for(long j = 0; j < 15000000; j++) {
        dummy = dummy + j;
        dummy = dummy % 1000000;
 23c:	000f4937          	lui	s2,0xf4
 240:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf2230>
      for(long j = 0; j < 15000000; j++) {
 244:	00e4e4b7          	lui	s1,0xe4e
 248:	1c048493          	addi	s1,s1,448 # e4e1c0 <base+0xe4c1b0>
      }
      
      pause(3);
      
      if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 24c:	4b3d                	li	s6,15
        printf("[MIXED] Tick %d: Q%d (slices=%d)\n", 
 24e:	00001a97          	auipc	s5,0x1
 252:	c1aa8a93          	addi	s5,s5,-998 # e68 <malloc+0x3a0>
    for(int iter = 0; iter < 50; iter++) {
 256:	03200a13          	li	s4,50
 25a:	a021                	j	262 <main+0x262>
 25c:	2985                	addiw	s3,s3,1
 25e:	05498763          	beq	s3,s4,2ac <main+0x2ac>
      for(long j = 0; j < 15000000; j++) {
 262:	4781                	li	a5,0
        dummy = dummy + j;
 264:	f8c42703          	lw	a4,-116(s0)
 268:	9f3d                	addw	a4,a4,a5
 26a:	f8e42623          	sw	a4,-116(s0)
        dummy = dummy % 1000000;
 26e:	f8c42703          	lw	a4,-116(s0)
 272:	0327673b          	remw	a4,a4,s2
 276:	f8e42623          	sw	a4,-116(s0)
      for(long j = 0; j < 15000000; j++) {
 27a:	0785                	addi	a5,a5,1
 27c:	fe9794e3          	bne	a5,s1,264 <main+0x264>
      pause(3);
 280:	450d                	li	a0,3
 282:	3ea000ef          	jal	66c <pause>
      if(iter % 15 == 0 && getprocinfo(&info) == 0) {
 286:	0369e7bb          	remw	a5,s3,s6
 28a:	fbe9                	bnez	a5,25c <main+0x25c>
 28c:	f9040513          	addi	a0,s0,-112
 290:	3ec000ef          	jal	67c <getprocinfo>
 294:	f561                	bnez	a0,25c <main+0x25c>
        printf("[MIXED] Tick %d: Q%d (slices=%d)\n", 
 296:	3de000ef          	jal	674 <uptime>
 29a:	85aa                	mv	a1,a0
 29c:	f9c42683          	lw	a3,-100(s0)
 2a0:	f9842603          	lw	a2,-104(s0)
 2a4:	8556                	mv	a0,s5
 2a6:	76e000ef          	jal	a14 <printf>
 2aa:	bf4d                	j	25c <main+0x25c>
               uptime(), info.priority, info.time_slices);
      }
    }
    
    if(getprocinfo(&info) == 0) {
 2ac:	f9040513          	addi	a0,s0,-112
 2b0:	3cc000ef          	jal	67c <getprocinfo>
 2b4:	c501                	beqz	a0,2bc <main+0x2bc>
      printf("[MIXED] FINAL: Q%d\n", info.priority);
    }
    exit(0);
 2b6:	4501                	li	a0,0
 2b8:	324000ef          	jal	5dc <exit>
      printf("[MIXED] FINAL: Q%d\n", info.priority);
 2bc:	f9842583          	lw	a1,-104(s0)
 2c0:	00001517          	auipc	a0,0x1
 2c4:	bd050513          	addi	a0,a0,-1072 # e90 <malloc+0x3c8>
 2c8:	74c000ef          	jal	a14 <printf>
 2cc:	b7ed                	j	2b6 <main+0x2b6>
 2ce:	f4a6                	sd	s1,104(sp)
 2d0:	e8d2                	sd	s4,80(sp)
 2d2:	e4d6                	sd	s5,72(sp)
 2d4:	e0da                	sd	s6,64(sp)
 2d6:	fc5e                	sd	s7,56(sp)
 2d8:	f862                	sd	s8,48(sp)
 2da:	f466                	sd	s9,40(sp)
  }
  
  // Parent waits
  printf("\n[Parent] All processes running...\n");
 2dc:	00001517          	auipc	a0,0x1
 2e0:	bcc50513          	addi	a0,a0,-1076 # ea8 <malloc+0x3e0>
 2e4:	730000ef          	jal	a14 <printf>
  wait(0);
 2e8:	4501                	li	a0,0
 2ea:	2fa000ef          	jal	5e4 <wait>
  wait(0);
 2ee:	4501                	li	a0,0
 2f0:	2f4000ef          	jal	5e4 <wait>
  wait(0);
 2f4:	4501                	li	a0,0
 2f6:	2ee000ef          	jal	5e4 <wait>
  
  printf("\n=== Fairness Test Complete ===\n");
 2fa:	00001517          	auipc	a0,0x1
 2fe:	bd650513          	addi	a0,a0,-1066 # ed0 <malloc+0x408>
 302:	712000ef          	jal	a14 <printf>
  printf("All three workloads completed successfully!\n");
 306:	00001517          	auipc	a0,0x1
 30a:	bf250513          	addi	a0,a0,-1038 # ef8 <malloc+0x430>
 30e:	706000ef          	jal	a14 <printf>
  printf("Expected results:\n");
 312:	00001517          	auipc	a0,0x1
 316:	c1650513          	addi	a0,a0,-1002 # f28 <malloc+0x460>
 31a:	6fa000ef          	jal	a14 <printf>
  printf("  - CPU-bound: Experienced boosts (no starvation)\n");
 31e:	00001517          	auipc	a0,0x1
 322:	c2250513          	addi	a0,a0,-990 # f40 <malloc+0x478>
 326:	6ee000ef          	jal	a14 <printf>
  printf("  - I/O-bound: Stayed in high priority queues\n");
 32a:	00001517          	auipc	a0,0x1
 32e:	c4e50513          	addi	a0,a0,-946 # f78 <malloc+0x4b0>
 332:	6e2000ef          	jal	a14 <printf>
  printf("  - Mixed: Balanced between Q1-Q2\n");
 336:	00001517          	auipc	a0,0x1
 33a:	c7250513          	addi	a0,a0,-910 # fa8 <malloc+0x4e0>
 33e:	6d6000ef          	jal	a14 <printf>
  
  exit(0);
 342:	4501                	li	a0,0
 344:	298000ef          	jal	5dc <exit>

0000000000000348 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 350:	cb1ff0ef          	jal	0 <main>
  exit(r);
 354:	288000ef          	jal	5dc <exit>

0000000000000358 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e422                	sd	s0,8(sp)
 35c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 35e:	87aa                	mv	a5,a0
 360:	0585                	addi	a1,a1,1
 362:	0785                	addi	a5,a5,1
 364:	fff5c703          	lbu	a4,-1(a1)
 368:	fee78fa3          	sb	a4,-1(a5)
 36c:	fb75                	bnez	a4,360 <strcpy+0x8>
    ;
  return os;
}
 36e:	6422                	ld	s0,8(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 374:	1141                	addi	sp,sp,-16
 376:	e422                	sd	s0,8(sp)
 378:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 37a:	00054783          	lbu	a5,0(a0)
 37e:	cb91                	beqz	a5,392 <strcmp+0x1e>
 380:	0005c703          	lbu	a4,0(a1)
 384:	00f71763          	bne	a4,a5,392 <strcmp+0x1e>
    p++, q++;
 388:	0505                	addi	a0,a0,1
 38a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 38c:	00054783          	lbu	a5,0(a0)
 390:	fbe5                	bnez	a5,380 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 392:	0005c503          	lbu	a0,0(a1)
}
 396:	40a7853b          	subw	a0,a5,a0
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret

00000000000003a0 <strlen>:

uint
strlen(const char *s)
{
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e422                	sd	s0,8(sp)
 3a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3a6:	00054783          	lbu	a5,0(a0)
 3aa:	cf91                	beqz	a5,3c6 <strlen+0x26>
 3ac:	0505                	addi	a0,a0,1
 3ae:	87aa                	mv	a5,a0
 3b0:	86be                	mv	a3,a5
 3b2:	0785                	addi	a5,a5,1
 3b4:	fff7c703          	lbu	a4,-1(a5)
 3b8:	ff65                	bnez	a4,3b0 <strlen+0x10>
 3ba:	40a6853b          	subw	a0,a3,a0
 3be:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  for(n = 0; s[n]; n++)
 3c6:	4501                	li	a0,0
 3c8:	bfe5                	j	3c0 <strlen+0x20>

00000000000003ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e422                	sd	s0,8(sp)
 3ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3d0:	ca19                	beqz	a2,3e6 <memset+0x1c>
 3d2:	87aa                	mv	a5,a0
 3d4:	1602                	slli	a2,a2,0x20
 3d6:	9201                	srli	a2,a2,0x20
 3d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3e0:	0785                	addi	a5,a5,1
 3e2:	fee79de3          	bne	a5,a4,3dc <memset+0x12>
  }
  return dst;
}
 3e6:	6422                	ld	s0,8(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret

00000000000003ec <strchr>:

char*
strchr(const char *s, char c)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e422                	sd	s0,8(sp)
 3f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3f2:	00054783          	lbu	a5,0(a0)
 3f6:	cb99                	beqz	a5,40c <strchr+0x20>
    if(*s == c)
 3f8:	00f58763          	beq	a1,a5,406 <strchr+0x1a>
  for(; *s; s++)
 3fc:	0505                	addi	a0,a0,1
 3fe:	00054783          	lbu	a5,0(a0)
 402:	fbfd                	bnez	a5,3f8 <strchr+0xc>
      return (char*)s;
  return 0;
 404:	4501                	li	a0,0
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret
  return 0;
 40c:	4501                	li	a0,0
 40e:	bfe5                	j	406 <strchr+0x1a>

0000000000000410 <gets>:

char*
gets(char *buf, int max)
{
 410:	711d                	addi	sp,sp,-96
 412:	ec86                	sd	ra,88(sp)
 414:	e8a2                	sd	s0,80(sp)
 416:	e4a6                	sd	s1,72(sp)
 418:	e0ca                	sd	s2,64(sp)
 41a:	fc4e                	sd	s3,56(sp)
 41c:	f852                	sd	s4,48(sp)
 41e:	f456                	sd	s5,40(sp)
 420:	f05a                	sd	s6,32(sp)
 422:	ec5e                	sd	s7,24(sp)
 424:	1080                	addi	s0,sp,96
 426:	8baa                	mv	s7,a0
 428:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 42a:	892a                	mv	s2,a0
 42c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 42e:	4aa9                	li	s5,10
 430:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 432:	89a6                	mv	s3,s1
 434:	2485                	addiw	s1,s1,1
 436:	0344d663          	bge	s1,s4,462 <gets+0x52>
    cc = read(0, &c, 1);
 43a:	4605                	li	a2,1
 43c:	faf40593          	addi	a1,s0,-81
 440:	4501                	li	a0,0
 442:	1b2000ef          	jal	5f4 <read>
    if(cc < 1)
 446:	00a05e63          	blez	a0,462 <gets+0x52>
    buf[i++] = c;
 44a:	faf44783          	lbu	a5,-81(s0)
 44e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 452:	01578763          	beq	a5,s5,460 <gets+0x50>
 456:	0905                	addi	s2,s2,1
 458:	fd679de3          	bne	a5,s6,432 <gets+0x22>
    buf[i++] = c;
 45c:	89a6                	mv	s3,s1
 45e:	a011                	j	462 <gets+0x52>
 460:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 462:	99de                	add	s3,s3,s7
 464:	00098023          	sb	zero,0(s3)
  return buf;
}
 468:	855e                	mv	a0,s7
 46a:	60e6                	ld	ra,88(sp)
 46c:	6446                	ld	s0,80(sp)
 46e:	64a6                	ld	s1,72(sp)
 470:	6906                	ld	s2,64(sp)
 472:	79e2                	ld	s3,56(sp)
 474:	7a42                	ld	s4,48(sp)
 476:	7aa2                	ld	s5,40(sp)
 478:	7b02                	ld	s6,32(sp)
 47a:	6be2                	ld	s7,24(sp)
 47c:	6125                	addi	sp,sp,96
 47e:	8082                	ret

0000000000000480 <stat>:

int
stat(const char *n, struct stat *st)
{
 480:	1101                	addi	sp,sp,-32
 482:	ec06                	sd	ra,24(sp)
 484:	e822                	sd	s0,16(sp)
 486:	e04a                	sd	s2,0(sp)
 488:	1000                	addi	s0,sp,32
 48a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 48c:	4581                	li	a1,0
 48e:	18e000ef          	jal	61c <open>
  if(fd < 0)
 492:	02054263          	bltz	a0,4b6 <stat+0x36>
 496:	e426                	sd	s1,8(sp)
 498:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 49a:	85ca                	mv	a1,s2
 49c:	198000ef          	jal	634 <fstat>
 4a0:	892a                	mv	s2,a0
  close(fd);
 4a2:	8526                	mv	a0,s1
 4a4:	160000ef          	jal	604 <close>
  return r;
 4a8:	64a2                	ld	s1,8(sp)
}
 4aa:	854a                	mv	a0,s2
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	6902                	ld	s2,0(sp)
 4b2:	6105                	addi	sp,sp,32
 4b4:	8082                	ret
    return -1;
 4b6:	597d                	li	s2,-1
 4b8:	bfcd                	j	4aa <stat+0x2a>

00000000000004ba <atoi>:

int
atoi(const char *s)
{
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e422                	sd	s0,8(sp)
 4be:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4c0:	00054683          	lbu	a3,0(a0)
 4c4:	fd06879b          	addiw	a5,a3,-48
 4c8:	0ff7f793          	zext.b	a5,a5
 4cc:	4625                	li	a2,9
 4ce:	02f66863          	bltu	a2,a5,4fe <atoi+0x44>
 4d2:	872a                	mv	a4,a0
  n = 0;
 4d4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 4d6:	0705                	addi	a4,a4,1
 4d8:	0025179b          	slliw	a5,a0,0x2
 4dc:	9fa9                	addw	a5,a5,a0
 4de:	0017979b          	slliw	a5,a5,0x1
 4e2:	9fb5                	addw	a5,a5,a3
 4e4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4e8:	00074683          	lbu	a3,0(a4)
 4ec:	fd06879b          	addiw	a5,a3,-48
 4f0:	0ff7f793          	zext.b	a5,a5
 4f4:	fef671e3          	bgeu	a2,a5,4d6 <atoi+0x1c>
  return n;
}
 4f8:	6422                	ld	s0,8(sp)
 4fa:	0141                	addi	sp,sp,16
 4fc:	8082                	ret
  n = 0;
 4fe:	4501                	li	a0,0
 500:	bfe5                	j	4f8 <atoi+0x3e>

0000000000000502 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 502:	1141                	addi	sp,sp,-16
 504:	e422                	sd	s0,8(sp)
 506:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 508:	02b57463          	bgeu	a0,a1,530 <memmove+0x2e>
    while(n-- > 0)
 50c:	00c05f63          	blez	a2,52a <memmove+0x28>
 510:	1602                	slli	a2,a2,0x20
 512:	9201                	srli	a2,a2,0x20
 514:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 518:	872a                	mv	a4,a0
      *dst++ = *src++;
 51a:	0585                	addi	a1,a1,1
 51c:	0705                	addi	a4,a4,1
 51e:	fff5c683          	lbu	a3,-1(a1)
 522:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 526:	fef71ae3          	bne	a4,a5,51a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 52a:	6422                	ld	s0,8(sp)
 52c:	0141                	addi	sp,sp,16
 52e:	8082                	ret
    dst += n;
 530:	00c50733          	add	a4,a0,a2
    src += n;
 534:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 536:	fec05ae3          	blez	a2,52a <memmove+0x28>
 53a:	fff6079b          	addiw	a5,a2,-1
 53e:	1782                	slli	a5,a5,0x20
 540:	9381                	srli	a5,a5,0x20
 542:	fff7c793          	not	a5,a5
 546:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 548:	15fd                	addi	a1,a1,-1
 54a:	177d                	addi	a4,a4,-1
 54c:	0005c683          	lbu	a3,0(a1)
 550:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 554:	fee79ae3          	bne	a5,a4,548 <memmove+0x46>
 558:	bfc9                	j	52a <memmove+0x28>

000000000000055a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 55a:	1141                	addi	sp,sp,-16
 55c:	e422                	sd	s0,8(sp)
 55e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 560:	ca05                	beqz	a2,590 <memcmp+0x36>
 562:	fff6069b          	addiw	a3,a2,-1
 566:	1682                	slli	a3,a3,0x20
 568:	9281                	srli	a3,a3,0x20
 56a:	0685                	addi	a3,a3,1
 56c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 56e:	00054783          	lbu	a5,0(a0)
 572:	0005c703          	lbu	a4,0(a1)
 576:	00e79863          	bne	a5,a4,586 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 57a:	0505                	addi	a0,a0,1
    p2++;
 57c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 57e:	fed518e3          	bne	a0,a3,56e <memcmp+0x14>
  }
  return 0;
 582:	4501                	li	a0,0
 584:	a019                	j	58a <memcmp+0x30>
      return *p1 - *p2;
 586:	40e7853b          	subw	a0,a5,a4
}
 58a:	6422                	ld	s0,8(sp)
 58c:	0141                	addi	sp,sp,16
 58e:	8082                	ret
  return 0;
 590:	4501                	li	a0,0
 592:	bfe5                	j	58a <memcmp+0x30>

0000000000000594 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 594:	1141                	addi	sp,sp,-16
 596:	e406                	sd	ra,8(sp)
 598:	e022                	sd	s0,0(sp)
 59a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 59c:	f67ff0ef          	jal	502 <memmove>
}
 5a0:	60a2                	ld	ra,8(sp)
 5a2:	6402                	ld	s0,0(sp)
 5a4:	0141                	addi	sp,sp,16
 5a6:	8082                	ret

00000000000005a8 <sbrk>:

char *
sbrk(int n) {
 5a8:	1141                	addi	sp,sp,-16
 5aa:	e406                	sd	ra,8(sp)
 5ac:	e022                	sd	s0,0(sp)
 5ae:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 5b0:	4585                	li	a1,1
 5b2:	0b2000ef          	jal	664 <sys_sbrk>
}
 5b6:	60a2                	ld	ra,8(sp)
 5b8:	6402                	ld	s0,0(sp)
 5ba:	0141                	addi	sp,sp,16
 5bc:	8082                	ret

00000000000005be <sbrklazy>:

char *
sbrklazy(int n) {
 5be:	1141                	addi	sp,sp,-16
 5c0:	e406                	sd	ra,8(sp)
 5c2:	e022                	sd	s0,0(sp)
 5c4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 5c6:	4589                	li	a1,2
 5c8:	09c000ef          	jal	664 <sys_sbrk>
}
 5cc:	60a2                	ld	ra,8(sp)
 5ce:	6402                	ld	s0,0(sp)
 5d0:	0141                	addi	sp,sp,16
 5d2:	8082                	ret

00000000000005d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5d4:	4885                	li	a7,1
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 5dc:	4889                	li	a7,2
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5e4:	488d                	li	a7,3
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ec:	4891                	li	a7,4
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <read>:
.global read
read:
 li a7, SYS_read
 5f4:	4895                	li	a7,5
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <write>:
.global write
write:
 li a7, SYS_write
 5fc:	48c1                	li	a7,16
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <close>:
.global close
close:
 li a7, SYS_close
 604:	48d5                	li	a7,21
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <kill>:
.global kill
kill:
 li a7, SYS_kill
 60c:	4899                	li	a7,6
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <exec>:
.global exec
exec:
 li a7, SYS_exec
 614:	489d                	li	a7,7
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <open>:
.global open
open:
 li a7, SYS_open
 61c:	48bd                	li	a7,15
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 624:	48c5                	li	a7,17
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 62c:	48c9                	li	a7,18
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 634:	48a1                	li	a7,8
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <link>:
.global link
link:
 li a7, SYS_link
 63c:	48cd                	li	a7,19
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 644:	48d1                	li	a7,20
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 64c:	48a5                	li	a7,9
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <dup>:
.global dup
dup:
 li a7, SYS_dup
 654:	48a9                	li	a7,10
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 65c:	48ad                	li	a7,11
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 664:	48b1                	li	a7,12
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <pause>:
.global pause
pause:
 li a7, SYS_pause
 66c:	48b5                	li	a7,13
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 674:	48b9                	li	a7,14
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 67c:	48d9                	li	a7,22
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 684:	48dd                	li	a7,23
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 68c:	1101                	addi	sp,sp,-32
 68e:	ec06                	sd	ra,24(sp)
 690:	e822                	sd	s0,16(sp)
 692:	1000                	addi	s0,sp,32
 694:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 698:	4605                	li	a2,1
 69a:	fef40593          	addi	a1,s0,-17
 69e:	f5fff0ef          	jal	5fc <write>
}
 6a2:	60e2                	ld	ra,24(sp)
 6a4:	6442                	ld	s0,16(sp)
 6a6:	6105                	addi	sp,sp,32
 6a8:	8082                	ret

00000000000006aa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 6aa:	715d                	addi	sp,sp,-80
 6ac:	e486                	sd	ra,72(sp)
 6ae:	e0a2                	sd	s0,64(sp)
 6b0:	f84a                	sd	s2,48(sp)
 6b2:	0880                	addi	s0,sp,80
 6b4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 6b6:	c299                	beqz	a3,6bc <printint+0x12>
 6b8:	0805c363          	bltz	a1,73e <printint+0x94>
  neg = 0;
 6bc:	4881                	li	a7,0
 6be:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 6c2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 6c4:	00001517          	auipc	a0,0x1
 6c8:	91450513          	addi	a0,a0,-1772 # fd8 <digits>
 6cc:	883e                	mv	a6,a5
 6ce:	2785                	addiw	a5,a5,1
 6d0:	02c5f733          	remu	a4,a1,a2
 6d4:	972a                	add	a4,a4,a0
 6d6:	00074703          	lbu	a4,0(a4)
 6da:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6de:	872e                	mv	a4,a1
 6e0:	02c5d5b3          	divu	a1,a1,a2
 6e4:	0685                	addi	a3,a3,1
 6e6:	fec773e3          	bgeu	a4,a2,6cc <printint+0x22>
  if(neg)
 6ea:	00088b63          	beqz	a7,700 <printint+0x56>
    buf[i++] = '-';
 6ee:	fd078793          	addi	a5,a5,-48
 6f2:	97a2                	add	a5,a5,s0
 6f4:	02d00713          	li	a4,45
 6f8:	fee78423          	sb	a4,-24(a5)
 6fc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 700:	02f05a63          	blez	a5,734 <printint+0x8a>
 704:	fc26                	sd	s1,56(sp)
 706:	f44e                	sd	s3,40(sp)
 708:	fb840713          	addi	a4,s0,-72
 70c:	00f704b3          	add	s1,a4,a5
 710:	fff70993          	addi	s3,a4,-1
 714:	99be                	add	s3,s3,a5
 716:	37fd                	addiw	a5,a5,-1
 718:	1782                	slli	a5,a5,0x20
 71a:	9381                	srli	a5,a5,0x20
 71c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 720:	fff4c583          	lbu	a1,-1(s1)
 724:	854a                	mv	a0,s2
 726:	f67ff0ef          	jal	68c <putc>
  while(--i >= 0)
 72a:	14fd                	addi	s1,s1,-1
 72c:	ff349ae3          	bne	s1,s3,720 <printint+0x76>
 730:	74e2                	ld	s1,56(sp)
 732:	79a2                	ld	s3,40(sp)
}
 734:	60a6                	ld	ra,72(sp)
 736:	6406                	ld	s0,64(sp)
 738:	7942                	ld	s2,48(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret
    x = -xx;
 73e:	40b005b3          	neg	a1,a1
    neg = 1;
 742:	4885                	li	a7,1
    x = -xx;
 744:	bfad                	j	6be <printint+0x14>

0000000000000746 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 746:	711d                	addi	sp,sp,-96
 748:	ec86                	sd	ra,88(sp)
 74a:	e8a2                	sd	s0,80(sp)
 74c:	e0ca                	sd	s2,64(sp)
 74e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 750:	0005c903          	lbu	s2,0(a1)
 754:	28090663          	beqz	s2,9e0 <vprintf+0x29a>
 758:	e4a6                	sd	s1,72(sp)
 75a:	fc4e                	sd	s3,56(sp)
 75c:	f852                	sd	s4,48(sp)
 75e:	f456                	sd	s5,40(sp)
 760:	f05a                	sd	s6,32(sp)
 762:	ec5e                	sd	s7,24(sp)
 764:	e862                	sd	s8,16(sp)
 766:	e466                	sd	s9,8(sp)
 768:	8b2a                	mv	s6,a0
 76a:	8a2e                	mv	s4,a1
 76c:	8bb2                	mv	s7,a2
  state = 0;
 76e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 770:	4481                	li	s1,0
 772:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 774:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 778:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 77c:	06c00c93          	li	s9,108
 780:	a005                	j	7a0 <vprintf+0x5a>
        putc(fd, c0);
 782:	85ca                	mv	a1,s2
 784:	855a                	mv	a0,s6
 786:	f07ff0ef          	jal	68c <putc>
 78a:	a019                	j	790 <vprintf+0x4a>
    } else if(state == '%'){
 78c:	03598263          	beq	s3,s5,7b0 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 790:	2485                	addiw	s1,s1,1
 792:	8726                	mv	a4,s1
 794:	009a07b3          	add	a5,s4,s1
 798:	0007c903          	lbu	s2,0(a5)
 79c:	22090a63          	beqz	s2,9d0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 7a0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7a4:	fe0994e3          	bnez	s3,78c <vprintf+0x46>
      if(c0 == '%'){
 7a8:	fd579de3          	bne	a5,s5,782 <vprintf+0x3c>
        state = '%';
 7ac:	89be                	mv	s3,a5
 7ae:	b7cd                	j	790 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 7b0:	00ea06b3          	add	a3,s4,a4
 7b4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7b8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 7ba:	c681                	beqz	a3,7c2 <vprintf+0x7c>
 7bc:	9752                	add	a4,a4,s4
 7be:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 7c2:	05878363          	beq	a5,s8,808 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 7c6:	05978d63          	beq	a5,s9,820 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 7ca:	07500713          	li	a4,117
 7ce:	0ee78763          	beq	a5,a4,8bc <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7d2:	07800713          	li	a4,120
 7d6:	12e78963          	beq	a5,a4,908 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7da:	07000713          	li	a4,112
 7de:	14e78e63          	beq	a5,a4,93a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7e2:	06300713          	li	a4,99
 7e6:	18e78e63          	beq	a5,a4,982 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 7ea:	07300713          	li	a4,115
 7ee:	1ae78463          	beq	a5,a4,996 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7f2:	02500713          	li	a4,37
 7f6:	04e79563          	bne	a5,a4,840 <vprintf+0xfa>
        putc(fd, '%');
 7fa:	02500593          	li	a1,37
 7fe:	855a                	mv	a0,s6
 800:	e8dff0ef          	jal	68c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 804:	4981                	li	s3,0
 806:	b769                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 808:	008b8913          	addi	s2,s7,8
 80c:	4685                	li	a3,1
 80e:	4629                	li	a2,10
 810:	000ba583          	lw	a1,0(s7)
 814:	855a                	mv	a0,s6
 816:	e95ff0ef          	jal	6aa <printint>
 81a:	8bca                	mv	s7,s2
      state = 0;
 81c:	4981                	li	s3,0
 81e:	bf8d                	j	790 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 820:	06400793          	li	a5,100
 824:	02f68963          	beq	a3,a5,856 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 828:	06c00793          	li	a5,108
 82c:	04f68263          	beq	a3,a5,870 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 830:	07500793          	li	a5,117
 834:	0af68063          	beq	a3,a5,8d4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 838:	07800793          	li	a5,120
 83c:	0ef68263          	beq	a3,a5,920 <vprintf+0x1da>
        putc(fd, '%');
 840:	02500593          	li	a1,37
 844:	855a                	mv	a0,s6
 846:	e47ff0ef          	jal	68c <putc>
        putc(fd, c0);
 84a:	85ca                	mv	a1,s2
 84c:	855a                	mv	a0,s6
 84e:	e3fff0ef          	jal	68c <putc>
      state = 0;
 852:	4981                	li	s3,0
 854:	bf35                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 856:	008b8913          	addi	s2,s7,8
 85a:	4685                	li	a3,1
 85c:	4629                	li	a2,10
 85e:	000bb583          	ld	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	e47ff0ef          	jal	6aa <printint>
        i += 1;
 868:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 86a:	8bca                	mv	s7,s2
      state = 0;
 86c:	4981                	li	s3,0
        i += 1;
 86e:	b70d                	j	790 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 870:	06400793          	li	a5,100
 874:	02f60763          	beq	a2,a5,8a2 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 878:	07500793          	li	a5,117
 87c:	06f60963          	beq	a2,a5,8ee <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 880:	07800793          	li	a5,120
 884:	faf61ee3          	bne	a2,a5,840 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 888:	008b8913          	addi	s2,s7,8
 88c:	4681                	li	a3,0
 88e:	4641                	li	a2,16
 890:	000bb583          	ld	a1,0(s7)
 894:	855a                	mv	a0,s6
 896:	e15ff0ef          	jal	6aa <printint>
        i += 2;
 89a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 89c:	8bca                	mv	s7,s2
      state = 0;
 89e:	4981                	li	s3,0
        i += 2;
 8a0:	bdc5                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8a2:	008b8913          	addi	s2,s7,8
 8a6:	4685                	li	a3,1
 8a8:	4629                	li	a2,10
 8aa:	000bb583          	ld	a1,0(s7)
 8ae:	855a                	mv	a0,s6
 8b0:	dfbff0ef          	jal	6aa <printint>
        i += 2;
 8b4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8b6:	8bca                	mv	s7,s2
      state = 0;
 8b8:	4981                	li	s3,0
        i += 2;
 8ba:	bdd9                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8bc:	008b8913          	addi	s2,s7,8
 8c0:	4681                	li	a3,0
 8c2:	4629                	li	a2,10
 8c4:	000be583          	lwu	a1,0(s7)
 8c8:	855a                	mv	a0,s6
 8ca:	de1ff0ef          	jal	6aa <printint>
 8ce:	8bca                	mv	s7,s2
      state = 0;
 8d0:	4981                	li	s3,0
 8d2:	bd7d                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d4:	008b8913          	addi	s2,s7,8
 8d8:	4681                	li	a3,0
 8da:	4629                	li	a2,10
 8dc:	000bb583          	ld	a1,0(s7)
 8e0:	855a                	mv	a0,s6
 8e2:	dc9ff0ef          	jal	6aa <printint>
        i += 1;
 8e6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8e8:	8bca                	mv	s7,s2
      state = 0;
 8ea:	4981                	li	s3,0
        i += 1;
 8ec:	b555                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ee:	008b8913          	addi	s2,s7,8
 8f2:	4681                	li	a3,0
 8f4:	4629                	li	a2,10
 8f6:	000bb583          	ld	a1,0(s7)
 8fa:	855a                	mv	a0,s6
 8fc:	dafff0ef          	jal	6aa <printint>
        i += 2;
 900:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 902:	8bca                	mv	s7,s2
      state = 0;
 904:	4981                	li	s3,0
        i += 2;
 906:	b569                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 908:	008b8913          	addi	s2,s7,8
 90c:	4681                	li	a3,0
 90e:	4641                	li	a2,16
 910:	000be583          	lwu	a1,0(s7)
 914:	855a                	mv	a0,s6
 916:	d95ff0ef          	jal	6aa <printint>
 91a:	8bca                	mv	s7,s2
      state = 0;
 91c:	4981                	li	s3,0
 91e:	bd8d                	j	790 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 920:	008b8913          	addi	s2,s7,8
 924:	4681                	li	a3,0
 926:	4641                	li	a2,16
 928:	000bb583          	ld	a1,0(s7)
 92c:	855a                	mv	a0,s6
 92e:	d7dff0ef          	jal	6aa <printint>
        i += 1;
 932:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 934:	8bca                	mv	s7,s2
      state = 0;
 936:	4981                	li	s3,0
        i += 1;
 938:	bda1                	j	790 <vprintf+0x4a>
 93a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 93c:	008b8d13          	addi	s10,s7,8
 940:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 944:	03000593          	li	a1,48
 948:	855a                	mv	a0,s6
 94a:	d43ff0ef          	jal	68c <putc>
  putc(fd, 'x');
 94e:	07800593          	li	a1,120
 952:	855a                	mv	a0,s6
 954:	d39ff0ef          	jal	68c <putc>
 958:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 95a:	00000b97          	auipc	s7,0x0
 95e:	67eb8b93          	addi	s7,s7,1662 # fd8 <digits>
 962:	03c9d793          	srli	a5,s3,0x3c
 966:	97de                	add	a5,a5,s7
 968:	0007c583          	lbu	a1,0(a5)
 96c:	855a                	mv	a0,s6
 96e:	d1fff0ef          	jal	68c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 972:	0992                	slli	s3,s3,0x4
 974:	397d                	addiw	s2,s2,-1
 976:	fe0916e3          	bnez	s2,962 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 97a:	8bea                	mv	s7,s10
      state = 0;
 97c:	4981                	li	s3,0
 97e:	6d02                	ld	s10,0(sp)
 980:	bd01                	j	790 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 982:	008b8913          	addi	s2,s7,8
 986:	000bc583          	lbu	a1,0(s7)
 98a:	855a                	mv	a0,s6
 98c:	d01ff0ef          	jal	68c <putc>
 990:	8bca                	mv	s7,s2
      state = 0;
 992:	4981                	li	s3,0
 994:	bbf5                	j	790 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 996:	008b8993          	addi	s3,s7,8
 99a:	000bb903          	ld	s2,0(s7)
 99e:	00090f63          	beqz	s2,9bc <vprintf+0x276>
        for(; *s; s++)
 9a2:	00094583          	lbu	a1,0(s2)
 9a6:	c195                	beqz	a1,9ca <vprintf+0x284>
          putc(fd, *s);
 9a8:	855a                	mv	a0,s6
 9aa:	ce3ff0ef          	jal	68c <putc>
        for(; *s; s++)
 9ae:	0905                	addi	s2,s2,1
 9b0:	00094583          	lbu	a1,0(s2)
 9b4:	f9f5                	bnez	a1,9a8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 9b6:	8bce                	mv	s7,s3
      state = 0;
 9b8:	4981                	li	s3,0
 9ba:	bbd9                	j	790 <vprintf+0x4a>
          s = "(null)";
 9bc:	00000917          	auipc	s2,0x0
 9c0:	61490913          	addi	s2,s2,1556 # fd0 <malloc+0x508>
        for(; *s; s++)
 9c4:	02800593          	li	a1,40
 9c8:	b7c5                	j	9a8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 9ca:	8bce                	mv	s7,s3
      state = 0;
 9cc:	4981                	li	s3,0
 9ce:	b3c9                	j	790 <vprintf+0x4a>
 9d0:	64a6                	ld	s1,72(sp)
 9d2:	79e2                	ld	s3,56(sp)
 9d4:	7a42                	ld	s4,48(sp)
 9d6:	7aa2                	ld	s5,40(sp)
 9d8:	7b02                	ld	s6,32(sp)
 9da:	6be2                	ld	s7,24(sp)
 9dc:	6c42                	ld	s8,16(sp)
 9de:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9e0:	60e6                	ld	ra,88(sp)
 9e2:	6446                	ld	s0,80(sp)
 9e4:	6906                	ld	s2,64(sp)
 9e6:	6125                	addi	sp,sp,96
 9e8:	8082                	ret

00000000000009ea <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9ea:	715d                	addi	sp,sp,-80
 9ec:	ec06                	sd	ra,24(sp)
 9ee:	e822                	sd	s0,16(sp)
 9f0:	1000                	addi	s0,sp,32
 9f2:	e010                	sd	a2,0(s0)
 9f4:	e414                	sd	a3,8(s0)
 9f6:	e818                	sd	a4,16(s0)
 9f8:	ec1c                	sd	a5,24(s0)
 9fa:	03043023          	sd	a6,32(s0)
 9fe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a02:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a06:	8622                	mv	a2,s0
 a08:	d3fff0ef          	jal	746 <vprintf>
}
 a0c:	60e2                	ld	ra,24(sp)
 a0e:	6442                	ld	s0,16(sp)
 a10:	6161                	addi	sp,sp,80
 a12:	8082                	ret

0000000000000a14 <printf>:

void
printf(const char *fmt, ...)
{
 a14:	711d                	addi	sp,sp,-96
 a16:	ec06                	sd	ra,24(sp)
 a18:	e822                	sd	s0,16(sp)
 a1a:	1000                	addi	s0,sp,32
 a1c:	e40c                	sd	a1,8(s0)
 a1e:	e810                	sd	a2,16(s0)
 a20:	ec14                	sd	a3,24(s0)
 a22:	f018                	sd	a4,32(s0)
 a24:	f41c                	sd	a5,40(s0)
 a26:	03043823          	sd	a6,48(s0)
 a2a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a2e:	00840613          	addi	a2,s0,8
 a32:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a36:	85aa                	mv	a1,a0
 a38:	4505                	li	a0,1
 a3a:	d0dff0ef          	jal	746 <vprintf>
}
 a3e:	60e2                	ld	ra,24(sp)
 a40:	6442                	ld	s0,16(sp)
 a42:	6125                	addi	sp,sp,96
 a44:	8082                	ret

0000000000000a46 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a46:	1141                	addi	sp,sp,-16
 a48:	e422                	sd	s0,8(sp)
 a4a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a4c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a50:	00001797          	auipc	a5,0x1
 a54:	5b07b783          	ld	a5,1456(a5) # 2000 <freep>
 a58:	a02d                	j	a82 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a5a:	4618                	lw	a4,8(a2)
 a5c:	9f2d                	addw	a4,a4,a1
 a5e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a62:	6398                	ld	a4,0(a5)
 a64:	6310                	ld	a2,0(a4)
 a66:	a83d                	j	aa4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a68:	ff852703          	lw	a4,-8(a0)
 a6c:	9f31                	addw	a4,a4,a2
 a6e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a70:	ff053683          	ld	a3,-16(a0)
 a74:	a091                	j	ab8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a76:	6398                	ld	a4,0(a5)
 a78:	00e7e463          	bltu	a5,a4,a80 <free+0x3a>
 a7c:	00e6ea63          	bltu	a3,a4,a90 <free+0x4a>
{
 a80:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a82:	fed7fae3          	bgeu	a5,a3,a76 <free+0x30>
 a86:	6398                	ld	a4,0(a5)
 a88:	00e6e463          	bltu	a3,a4,a90 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a8c:	fee7eae3          	bltu	a5,a4,a80 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a90:	ff852583          	lw	a1,-8(a0)
 a94:	6390                	ld	a2,0(a5)
 a96:	02059813          	slli	a6,a1,0x20
 a9a:	01c85713          	srli	a4,a6,0x1c
 a9e:	9736                	add	a4,a4,a3
 aa0:	fae60de3          	beq	a2,a4,a5a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 aa4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 aa8:	4790                	lw	a2,8(a5)
 aaa:	02061593          	slli	a1,a2,0x20
 aae:	01c5d713          	srli	a4,a1,0x1c
 ab2:	973e                	add	a4,a4,a5
 ab4:	fae68ae3          	beq	a3,a4,a68 <free+0x22>
    p->s.ptr = bp->s.ptr;
 ab8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 aba:	00001717          	auipc	a4,0x1
 abe:	54f73323          	sd	a5,1350(a4) # 2000 <freep>
}
 ac2:	6422                	ld	s0,8(sp)
 ac4:	0141                	addi	sp,sp,16
 ac6:	8082                	ret

0000000000000ac8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ac8:	7139                	addi	sp,sp,-64
 aca:	fc06                	sd	ra,56(sp)
 acc:	f822                	sd	s0,48(sp)
 ace:	f426                	sd	s1,40(sp)
 ad0:	ec4e                	sd	s3,24(sp)
 ad2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ad4:	02051493          	slli	s1,a0,0x20
 ad8:	9081                	srli	s1,s1,0x20
 ada:	04bd                	addi	s1,s1,15
 adc:	8091                	srli	s1,s1,0x4
 ade:	0014899b          	addiw	s3,s1,1
 ae2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ae4:	00001517          	auipc	a0,0x1
 ae8:	51c53503          	ld	a0,1308(a0) # 2000 <freep>
 aec:	c915                	beqz	a0,b20 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 af0:	4798                	lw	a4,8(a5)
 af2:	08977a63          	bgeu	a4,s1,b86 <malloc+0xbe>
 af6:	f04a                	sd	s2,32(sp)
 af8:	e852                	sd	s4,16(sp)
 afa:	e456                	sd	s5,8(sp)
 afc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 afe:	8a4e                	mv	s4,s3
 b00:	0009871b          	sext.w	a4,s3
 b04:	6685                	lui	a3,0x1
 b06:	00d77363          	bgeu	a4,a3,b0c <malloc+0x44>
 b0a:	6a05                	lui	s4,0x1
 b0c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b10:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b14:	00001917          	auipc	s2,0x1
 b18:	4ec90913          	addi	s2,s2,1260 # 2000 <freep>
  if(p == SBRK_ERROR)
 b1c:	5afd                	li	s5,-1
 b1e:	a081                	j	b5e <malloc+0x96>
 b20:	f04a                	sd	s2,32(sp)
 b22:	e852                	sd	s4,16(sp)
 b24:	e456                	sd	s5,8(sp)
 b26:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b28:	00001797          	auipc	a5,0x1
 b2c:	4e878793          	addi	a5,a5,1256 # 2010 <base>
 b30:	00001717          	auipc	a4,0x1
 b34:	4cf73823          	sd	a5,1232(a4) # 2000 <freep>
 b38:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b3a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b3e:	b7c1                	j	afe <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b40:	6398                	ld	a4,0(a5)
 b42:	e118                	sd	a4,0(a0)
 b44:	a8a9                	j	b9e <malloc+0xd6>
  hp->s.size = nu;
 b46:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b4a:	0541                	addi	a0,a0,16
 b4c:	efbff0ef          	jal	a46 <free>
  return freep;
 b50:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b54:	c12d                	beqz	a0,bb6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b56:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b58:	4798                	lw	a4,8(a5)
 b5a:	02977263          	bgeu	a4,s1,b7e <malloc+0xb6>
    if(p == freep)
 b5e:	00093703          	ld	a4,0(s2)
 b62:	853e                	mv	a0,a5
 b64:	fef719e3          	bne	a4,a5,b56 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b68:	8552                	mv	a0,s4
 b6a:	a3fff0ef          	jal	5a8 <sbrk>
  if(p == SBRK_ERROR)
 b6e:	fd551ce3          	bne	a0,s5,b46 <malloc+0x7e>
        return 0;
 b72:	4501                	li	a0,0
 b74:	7902                	ld	s2,32(sp)
 b76:	6a42                	ld	s4,16(sp)
 b78:	6aa2                	ld	s5,8(sp)
 b7a:	6b02                	ld	s6,0(sp)
 b7c:	a03d                	j	baa <malloc+0xe2>
 b7e:	7902                	ld	s2,32(sp)
 b80:	6a42                	ld	s4,16(sp)
 b82:	6aa2                	ld	s5,8(sp)
 b84:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b86:	fae48de3          	beq	s1,a4,b40 <malloc+0x78>
        p->s.size -= nunits;
 b8a:	4137073b          	subw	a4,a4,s3
 b8e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b90:	02071693          	slli	a3,a4,0x20
 b94:	01c6d713          	srli	a4,a3,0x1c
 b98:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b9a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b9e:	00001717          	auipc	a4,0x1
 ba2:	46a73123          	sd	a0,1122(a4) # 2000 <freep>
      return (void*)(p + 1);
 ba6:	01078513          	addi	a0,a5,16
  }
}
 baa:	70e2                	ld	ra,56(sp)
 bac:	7442                	ld	s0,48(sp)
 bae:	74a2                	ld	s1,40(sp)
 bb0:	69e2                	ld	s3,24(sp)
 bb2:	6121                	addi	sp,sp,64
 bb4:	8082                	ret
 bb6:	7902                	ld	s2,32(sp)
 bb8:	6a42                	ld	s4,16(sp)
 bba:	6aa2                	ld	s5,8(sp)
 bbc:	6b02                	ld	s6,0(sp)
 bbe:	b7f5                	j	baa <malloc+0xe2>
