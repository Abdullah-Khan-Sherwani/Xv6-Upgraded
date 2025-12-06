
user/_boost_t:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_work>:

// Time quanta for each queue (must match kernel/proc.c)
// These define how many ticks a process runs before demotion
int time_quanta[4] = {2, 4, 8, 16};

void cpu_work(int iterations) {
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
  volatile int dummy = 0;
   6:	fe042623          	sw	zero,-20(s0)
  for(long j = 0; j < iterations; j++) {
   a:	02a05563          	blez	a0,34 <cpu_work+0x34>
   e:	4781                	li	a5,0
    dummy = dummy + j;
    dummy = dummy % 1000000;
  10:	000f46b7          	lui	a3,0xf4
  14:	2406869b          	addiw	a3,a3,576 # f4240 <base+0xf1220>
    dummy = dummy + j;
  18:	fec42703          	lw	a4,-20(s0)
  1c:	9f3d                	addw	a4,a4,a5
  1e:	fee42623          	sw	a4,-20(s0)
    dummy = dummy % 1000000;
  22:	fec42703          	lw	a4,-20(s0)
  26:	02d7673b          	remw	a4,a4,a3
  2a:	fee42623          	sw	a4,-20(s0)
  for(long j = 0; j < iterations; j++) {
  2e:	0785                	addi	a5,a5,1
  30:	fea794e3          	bne	a5,a0,18 <cpu_work+0x18>
  }
}
  34:	6462                	ld	s0,24(sp)
  36:	6105                	addi	sp,sp,32
  38:	8082                	ret

000000000000003a <print_status>:

void print_status(char *label, struct procinfo *info, int tick) {
  3a:	1141                	addi	sp,sp,-16
  3c:	e406                	sd	ra,8(sp)
  3e:	e022                	sd	s0,0(sp)
  40:	0800                	addi	s0,sp,16
  42:	86ae                	mv	a3,a1
  44:	85b2                	mv	a1,a2
  printf("  [Tick %d] %s: PID=%d, Queue=Q%d, Slices=%d/%d\n",
  46:	4698                	lw	a4,8(a3)
  48:	00271613          	slli	a2,a4,0x2
  4c:	00003797          	auipc	a5,0x3
  50:	fb478793          	addi	a5,a5,-76 # 3000 <time_quanta>
  54:	97b2                	add	a5,a5,a2
  56:	0007a803          	lw	a6,0(a5)
  5a:	46dc                	lw	a5,12(a3)
  5c:	4294                	lw	a3,0(a3)
  5e:	862a                	mv	a2,a0
  60:	00001517          	auipc	a0,0x1
  64:	f4050513          	addi	a0,a0,-192 # fa0 <malloc+0xfa>
  68:	58b000ef          	jal	df2 <printf>
         tick, label, info->pid, info->priority, info->time_slices,
         time_quanta[info->priority]);
}
  6c:	60a2                	ld	ra,8(sp)
  6e:	6402                	ld	s0,0(sp)
  70:	0141                	addi	sp,sp,16
  72:	8082                	ret

0000000000000074 <print_time_quanta_info>:

void print_time_quanta_info(void) {
  74:	1101                	addi	sp,sp,-32
  76:	ec06                	sd	ra,24(sp)
  78:	e822                	sd	s0,16(sp)
  7a:	e426                	sd	s1,8(sp)
  7c:	1000                	addi	s0,sp,32
  printf("  ┌─────────────────────────────────────────────────────┐\n");
  7e:	00001517          	auipc	a0,0x1
  82:	f5a50513          	addi	a0,a0,-166 # fd8 <malloc+0x132>
  86:	56d000ef          	jal	df2 <printf>
  printf("  │ Queue │ Time Quantum │ Meaning                      │\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	ffe50513          	addi	a0,a0,-2 # 1088 <malloc+0x1e2>
  92:	561000ef          	jal	df2 <printf>
  printf("  ├─────────────────────────────────────────────────────┤\n");
  96:	00001517          	auipc	a0,0x1
  9a:	03a50513          	addi	a0,a0,58 # 10d0 <malloc+0x22a>
  9e:	555000ef          	jal	df2 <printf>
  printf("  │  Q0   │   %d ticks    │ Highest priority, shortest   │\n", time_quanta[0]);
  a2:	00003497          	auipc	s1,0x3
  a6:	f5e48493          	addi	s1,s1,-162 # 3000 <time_quanta>
  aa:	408c                	lw	a1,0(s1)
  ac:	00001517          	auipc	a0,0x1
  b0:	0d450513          	addi	a0,a0,212 # 1180 <malloc+0x2da>
  b4:	53f000ef          	jal	df2 <printf>
  printf("  │  Q1   │   %d ticks    │                              │\n", time_quanta[1]);
  b8:	40cc                	lw	a1,4(s1)
  ba:	00001517          	auipc	a0,0x1
  be:	10e50513          	addi	a0,a0,270 # 11c8 <malloc+0x322>
  c2:	531000ef          	jal	df2 <printf>
  printf("  │  Q2   │   %d ticks    │                              │\n", time_quanta[2]);
  c6:	448c                	lw	a1,8(s1)
  c8:	00001517          	auipc	a0,0x1
  cc:	14850513          	addi	a0,a0,328 # 1210 <malloc+0x36a>
  d0:	523000ef          	jal	df2 <printf>
  printf("  │  Q3   │   %d ticks   │ Lowest priority, longest     │\n", time_quanta[3]);
  d4:	44cc                	lw	a1,12(s1)
  d6:	00001517          	auipc	a0,0x1
  da:	18250513          	addi	a0,a0,386 # 1258 <malloc+0x3b2>
  de:	515000ef          	jal	df2 <printf>
  printf("  └─────────────────────────────────────────────────────┘\n");
  e2:	00001517          	auipc	a0,0x1
  e6:	1be50513          	addi	a0,a0,446 # 12a0 <malloc+0x3fa>
  ea:	509000ef          	jal	df2 <printf>
  printf("  Note: 1 tick ~ 100ms. Process demotes when slices >= quantum.\n\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	26250513          	addi	a0,a0,610 # 1350 <malloc+0x4aa>
  f6:	4fd000ef          	jal	df2 <printf>
}
  fa:	60e2                	ld	ra,24(sp)
  fc:	6442                	ld	s0,16(sp)
  fe:	64a2                	ld	s1,8(sp)
 100:	6105                	addi	sp,sp,32
 102:	8082                	ret

0000000000000104 <main>:

int
main(int argc, char *argv[])
{
 104:	7135                	addi	sp,sp,-160
 106:	ed06                	sd	ra,152(sp)
 108:	e922                	sd	s0,144(sp)
 10a:	e526                	sd	s1,136(sp)
 10c:	e14a                	sd	s2,128(sp)
 10e:	fcce                	sd	s3,120(sp)
 110:	f8d2                	sd	s4,112(sp)
 112:	f4d6                	sd	s5,104(sp)
 114:	f0da                	sd	s6,96(sp)
 116:	ecde                	sd	s7,88(sp)
 118:	e8e2                	sd	s8,80(sp)
 11a:	e4e6                	sd	s9,72(sp)
 11c:	e0ea                	sd	s10,64(sp)
 11e:	fc6e                	sd	s11,56(sp)
 120:	1100                	addi	s0,sp,160
  struct procinfo info;
  int start_tick, current_tick;
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
  int test_passed = 1;
  
  printf("╔══════════════════════════════════════════════════════════╗\n");
 122:	00001517          	auipc	a0,0x1
 126:	2a650513          	addi	a0,a0,678 # 13c8 <malloc+0x522>
 12a:	4c9000ef          	jal	df2 <printf>
  printf("║     MLFQ BOOST TEST - Demotion & Promotion Cycles        ║\n");
 12e:	00001517          	auipc	a0,0x1
 132:	35250513          	addi	a0,a0,850 # 1480 <malloc+0x5da>
 136:	4bd000ef          	jal	df2 <printf>
  printf("╚══════════════════════════════════════════════════════════╝\n\n");
 13a:	00001517          	auipc	a0,0x1
 13e:	38e50513          	addi	a0,a0,910 # 14c8 <malloc+0x622>
 142:	4b1000ef          	jal	df2 <printf>
  
  start_tick = uptime();
 146:	10d000ef          	jal	a52 <uptime>
 14a:	8b2a                	mv	s6,a0
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 1: Verify Initial Priority
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 1: Initial Priority Check ─────────────────────────┐\n");
 14c:	00001517          	auipc	a0,0x1
 150:	43450513          	addi	a0,a0,1076 # 1580 <malloc+0x6da>
 154:	49f000ef          	jal	df2 <printf>
  
  if(getprocinfo(&info) == 0) {
 158:	f8040513          	addi	a0,s0,-128
 15c:	0ff000ef          	jal	a5a <getprocinfo>
 160:	f6a43423          	sd	a0,-152(s0)
 164:	c159                	beqz	a0,1ea <main+0xe6>
  int test_passed = 1;
 166:	4785                	li	a5,1
 168:	f6f43423          	sd	a5,-152(s0)
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
 16c:	f6043023          	sd	zero,-160(s0)
    } else {
      printf("  ✗ FAIL: Expected Q0, got Q%d\n", initial_priority);
      test_passed = 0;
    }
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
 170:	00001517          	auipc	a0,0x1
 174:	4f850513          	addi	a0,a0,1272 # 1668 <malloc+0x7c2>
 178:	47b000ef          	jal	df2 <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 2: Demotion through CPU-bound work
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 2: Demotion Test (CPU-bound work) ─────────────────┐\n");
 17c:	00001517          	auipc	a0,0x1
 180:	5ac50513          	addi	a0,a0,1452 # 1728 <malloc+0x882>
 184:	46f000ef          	jal	df2 <printf>
  printf("  Running CPU-intensive work to trigger demotion...\n\n");
 188:	00001517          	auipc	a0,0x1
 18c:	60850513          	addi	a0,a0,1544 # 1790 <malloc+0x8ea>
 190:	463000ef          	jal	df2 <printf>
  print_time_quanta_info();
 194:	ee1ff0ef          	jal	74 <print_time_quanta_info>
  
  int last_priority = 0;
  int last_slices = 0;
  int demotion_ticks[4] = {0, 0, 0, 0};  // Track exact tick of each demotion
 198:	f6042a23          	sw	zero,-140(s0)
 19c:	f6042c23          	sw	zero,-136(s0)
 1a0:	f6042e23          	sw	zero,-132(s0)
  
  printf("  Monitoring slices and demotions:\n");
 1a4:	00001517          	auipc	a0,0x1
 1a8:	62450513          	addi	a0,a0,1572 # 17c8 <malloc+0x922>
 1ac:	447000ef          	jal	df2 <printf>
  printf("  ─────────────────────────────────────────────────────────\n");
 1b0:	00001517          	auipc	a0,0x1
 1b4:	64050513          	addi	a0,a0,1600 # 17f0 <malloc+0x94a>
 1b8:	43b000ef          	jal	df2 <printf>
 1bc:	06400913          	li	s2,100
  
  // Run until we reach Q3 or max 80 phases
  // Q0(2) + Q1(4) + Q2(8) = 14 ticks to reach Q3
  // Continue a bit in Q3 to show it's working
  int reached_q3 = 0;
  int q3_slices_shown = 0;
 1c0:	4c01                	li	s8,0
  int last_slices = 0;
 1c2:	4a81                	li	s5,0
  int last_priority = 0;
 1c4:	4981                	li	s3,0
  
  for(int phase = 0; phase < 100; phase++) {
    // Small work unit to get finer granularity
    cpu_work(WORK_ITERATIONS / 4);
 1c6:	00131a37          	lui	s4,0x131
 1ca:	2d0a0a13          	addi	s4,s4,720 # 1312d0 <base+0x12e2b0>
    
    if(getprocinfo(&info) == 0) {
      current_tick = uptime() - start_tick;
      
      // Track when we reach Q3
      if(info.priority == 3 && !reached_q3) {
 1ce:	4b8d                	li	s7,3
                 current_tick, last_priority, info.priority,
                 time_quanta[last_priority], time_quanta[last_priority]);
        } 
        // Detect boost (priority went up)
        else if(info.priority < last_priority) {
          printf("  < TICK %d: BOOSTED Q%d->Q%d (auto boost)\n",
 1d0:	00001d97          	auipc	s11,0x1
 1d4:	708d8d93          	addi	s11,s11,1800 # 18d8 <malloc+0xa32>
          printf("  > TICK %d: DEMOTED Q%d->Q%d (used %d/%d slices)\n",
 1d8:	00003c97          	auipc	s9,0x3
 1dc:	e28c8c93          	addi	s9,s9,-472 # 3000 <time_quanta>
 1e0:	00001d17          	auipc	s10,0x1
 1e4:	6c0d0d13          	addi	s10,s10,1728 # 18a0 <malloc+0x9fa>
 1e8:	a849                	j	27a <main+0x176>
    initial_priority = info.priority;
 1ea:	f8842783          	lw	a5,-120(s0)
 1ee:	84be                	mv	s1,a5
 1f0:	f6f43023          	sd	a5,-160(s0)
    print_status("Initial", &info, uptime() - start_tick);
 1f4:	05f000ef          	jal	a52 <uptime>
 1f8:	4165063b          	subw	a2,a0,s6
 1fc:	f8040593          	addi	a1,s0,-128
 200:	00001517          	auipc	a0,0x1
 204:	3f850513          	addi	a0,a0,1016 # 15f8 <malloc+0x752>
 208:	e33ff0ef          	jal	3a <print_status>
    if(initial_priority == 0) {
 20c:	e899                	bnez	s1,222 <main+0x11e>
      printf("  ✓ PASS: New process starts at highest priority (Q0)\n");
 20e:	00001517          	auipc	a0,0x1
 212:	3f250513          	addi	a0,a0,1010 # 1600 <malloc+0x75a>
 216:	3dd000ef          	jal	df2 <printf>
  int test_passed = 1;
 21a:	4785                	li	a5,1
 21c:	f6f43423          	sd	a5,-152(s0)
 220:	bf81                	j	170 <main+0x6c>
      printf("  ✗ FAIL: Expected Q0, got Q%d\n", initial_priority);
 222:	f6043583          	ld	a1,-160(s0)
 226:	00001517          	auipc	a0,0x1
 22a:	41a50513          	addi	a0,a0,1050 # 1640 <malloc+0x79a>
 22e:	3c5000ef          	jal	df2 <printf>
      test_passed = 0;
 232:	bf3d                	j	170 <main+0x6c>
      if(info.time_slices != last_slices || info.priority != last_priority) {
 234:	05360063          	beq	a2,s3,274 <main+0x170>
        if(info.priority > last_priority) {
 238:	00c9c963          	blt	s3,a2,24a <main+0x146>
          printf("  < TICK %d: BOOSTED Q%d->Q%d (auto boost)\n",
 23c:	86b2                	mv	a3,a2
 23e:	864e                	mv	a2,s3
 240:	856e                	mv	a0,s11
 242:	3b1000ef          	jal	df2 <printf>
                 current_tick, last_priority, info.priority);
          // Reset Q3 tracking if boosted
          reached_q3 = 0;
          q3_slices_shown = 0;
 246:	8c26                	mv	s8,s1
 248:	a015                	j	26c <main+0x168>
          demotion_ticks[info.priority] = current_tick;
 24a:	00261793          	slli	a5,a2,0x2
 24e:	f9078793          	addi	a5,a5,-112
 252:	97a2                	add	a5,a5,s0
 254:	fea7a023          	sw	a0,-32(a5)
          printf("  > TICK %d: DEMOTED Q%d->Q%d (used %d/%d slices)\n",
 258:	00299793          	slli	a5,s3,0x2
 25c:	97e6                	add	a5,a5,s9
 25e:	4398                	lw	a4,0(a5)
 260:	87ba                	mv	a5,a4
 262:	86b2                	mv	a3,a2
 264:	864e                	mv	a2,s3
 266:	856a                	mv	a0,s10
 268:	38b000ef          	jal	df2 <printf>
        else if(info.time_slices < last_slices && info.priority == last_priority) {
          printf("    TICK %d: Q%d slices reset to %d\n",
                 current_tick, info.priority, info.time_slices);
        }
        
        last_slices = info.time_slices;
 26c:	f8c42a83          	lw	s5,-116(s0)
        last_priority = info.priority;
 270:	f8842983          	lw	s3,-120(s0)
  for(int phase = 0; phase < 100; phase++) {
 274:	397d                	addiw	s2,s2,-1
 276:	3e090963          	beqz	s2,668 <main+0x564>
    cpu_work(WORK_ITERATIONS / 4);
 27a:	8552                	mv	a0,s4
 27c:	d85ff0ef          	jal	0 <cpu_work>
    if(getprocinfo(&info) == 0) {
 280:	f8040513          	addi	a0,s0,-128
 284:	7d6000ef          	jal	a5a <getprocinfo>
 288:	84aa                	mv	s1,a0
 28a:	f56d                	bnez	a0,274 <main+0x170>
      current_tick = uptime() - start_tick;
 28c:	7c6000ef          	jal	a52 <uptime>
 290:	4165053b          	subw	a0,a0,s6
 294:	0005059b          	sext.w	a1,a0
      if(info.priority == 3 && !reached_q3) {
 298:	f8842603          	lw	a2,-120(s0)
 29c:	3d760463          	beq	a2,s7,664 <main+0x560>
      if(info.time_slices != last_slices || info.priority != last_priority) {
 2a0:	f8c42703          	lw	a4,-116(s0)
 2a4:	f95708e3          	beq	a4,s5,234 <main+0x130>
        if(info.priority > last_priority) {
 2a8:	fac9c1e3          	blt	s3,a2,24a <main+0x146>
        else if(info.priority < last_priority) {
 2ac:	f93648e3          	blt	a2,s3,23c <main+0x138>
        else if(info.time_slices > last_slices) {
 2b0:	00eaca63          	blt	s5,a4,2c4 <main+0x1c0>
          printf("    TICK %d: Q%d slices reset to %d\n",
 2b4:	86ba                	mv	a3,a4
 2b6:	00001517          	auipc	a0,0x1
 2ba:	68a50513          	addi	a0,a0,1674 # 1940 <malloc+0xa9a>
 2be:	335000ef          	jal	df2 <printf>
 2c2:	b76d                	j	26c <main+0x168>
          printf("    TICK %d: Q%d slices %d->%d (need %d for demotion)\n",
 2c4:	00261793          	slli	a5,a2,0x2
 2c8:	97e6                	add	a5,a5,s9
 2ca:	439c                	lw	a5,0(a5)
 2cc:	86d6                	mv	a3,s5
 2ce:	00001517          	auipc	a0,0x1
 2d2:	63a50513          	addi	a0,a0,1594 # 1908 <malloc+0xa62>
 2d6:	31d000ef          	jal	df2 <printf>
          if(info.priority == 3) {
 2da:	f8842783          	lw	a5,-120(s0)
 2de:	f97797e3          	bne	a5,s7,26c <main+0x168>
            q3_slices_shown++;
 2e2:	2c05                	addiw	s8,s8,1
 2e4:	b761                	j	26c <main+0x168>
  }
  
  printf("  ─────────────────────────────────────────────────────────\n");
  
  if(getprocinfo(&info) == 0) {
    demoted_priority = info.priority;
 2e6:	f8842c03          	lw	s8,-120(s0)
    print_status("After work", &info, uptime() - start_tick);
 2ea:	768000ef          	jal	a52 <uptime>
 2ee:	4165063b          	subw	a2,a0,s6
 2f2:	f8040593          	addi	a1,s0,-128
 2f6:	00001517          	auipc	a0,0x1
 2fa:	67250513          	addi	a0,a0,1650 # 1968 <malloc+0xac2>
 2fe:	d3dff0ef          	jal	3a <print_status>
    
    printf("\n  Demotion Summary:\n");
 302:	00001517          	auipc	a0,0x1
 306:	67650513          	addi	a0,a0,1654 # 1978 <malloc+0xad2>
 30a:	2e9000ef          	jal	df2 <printf>
    if(demotion_ticks[1] > 0)
 30e:	f7442583          	lw	a1,-140(s0)
 312:	02b04663          	bgtz	a1,33e <main+0x23a>
      printf("    Q0->Q1 at tick %d (expected after %d ticks in Q0)\n", 
             demotion_ticks[1], time_quanta[0]);
    if(demotion_ticks[2] > 0)
 316:	f7842583          	lw	a1,-136(s0)
 31a:	02b04d63          	bgtz	a1,354 <main+0x250>
      printf("    Q1->Q2 at tick %d (expected after %d more ticks in Q1)\n", 
             demotion_ticks[2], time_quanta[1]);
    if(demotion_ticks[3] > 0)
 31e:	f7c42583          	lw	a1,-132(s0)
 322:	04b04463          	bgtz	a1,36a <main+0x266>
      printf("    Q2->Q3 at tick %d (expected after %d more ticks in Q2)\n", 
             demotion_ticks[3], time_quanta[2]);
    
    if(demoted_priority > initial_priority) {
 326:	f6043583          	ld	a1,-160(s0)
 32a:	0585db63          	bge	a1,s8,380 <main+0x27c>
      printf("\n  ✓ PASS: Process demoted from Q%d to Q%d\n", 
 32e:	8662                	mv	a2,s8
 330:	00001517          	auipc	a0,0x1
 334:	71850513          	addi	a0,a0,1816 # 1a48 <malloc+0xba2>
 338:	2bb000ef          	jal	df2 <printf>
 33c:	a6a1                	j	684 <main+0x580>
      printf("    Q0->Q1 at tick %d (expected after %d ticks in Q0)\n", 
 33e:	00003617          	auipc	a2,0x3
 342:	cc262603          	lw	a2,-830(a2) # 3000 <time_quanta>
 346:	00001517          	auipc	a0,0x1
 34a:	64a50513          	addi	a0,a0,1610 # 1990 <malloc+0xaea>
 34e:	2a5000ef          	jal	df2 <printf>
 352:	b7d1                	j	316 <main+0x212>
      printf("    Q1->Q2 at tick %d (expected after %d more ticks in Q1)\n", 
 354:	00003617          	auipc	a2,0x3
 358:	cb062603          	lw	a2,-848(a2) # 3004 <time_quanta+0x4>
 35c:	00001517          	auipc	a0,0x1
 360:	66c50513          	addi	a0,a0,1644 # 19c8 <malloc+0xb22>
 364:	28f000ef          	jal	df2 <printf>
 368:	bf5d                	j	31e <main+0x21a>
      printf("    Q2->Q3 at tick %d (expected after %d more ticks in Q2)\n", 
 36a:	00003617          	auipc	a2,0x3
 36e:	c9e62603          	lw	a2,-866(a2) # 3008 <time_quanta+0x8>
 372:	00001517          	auipc	a0,0x1
 376:	69650513          	addi	a0,a0,1686 # 1a08 <malloc+0xb62>
 37a:	279000ef          	jal	df2 <printf>
 37e:	b765                	j	326 <main+0x222>
             initial_priority, demoted_priority);
    } else {
      printf("\n  ✗ FAIL: Process not demoted (still at Q%d)\n", demoted_priority);
 380:	85e2                	mv	a1,s8
 382:	00001517          	auipc	a0,0x1
 386:	6f650513          	addi	a0,a0,1782 # 1a78 <malloc+0xbd2>
 38a:	269000ef          	jal	df2 <printf>
      test_passed = 0;
 38e:	f6943423          	sd	s1,-152(s0)
 392:	accd                	j	684 <main+0x580>
  // TEST 3: Manual Boost via boostproc()
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 3: Manual Boost (boostproc syscall) ───────────────┐\n");
  
  if(getprocinfo(&info) == 0) {
    print_status("Before boost", &info, uptime() - start_tick);
 394:	6be000ef          	jal	a52 <uptime>
 398:	4165063b          	subw	a2,a0,s6
 39c:	f8040593          	addi	a1,s0,-128
 3a0:	00001517          	auipc	a0,0x1
 3a4:	77850513          	addi	a0,a0,1912 # 1b18 <malloc+0xc72>
 3a8:	c93ff0ef          	jal	3a <print_status>
 3ac:	acf5                	j	6a8 <main+0x5a4>
  }
  
  printf("  Calling boostproc()...\n");
  int before_boost_tick = uptime() - start_tick;
  boostproc();
  int after_boost_tick = uptime() - start_tick;
 3ae:	4169093b          	subw	s2,s2,s6
  
  if(getprocinfo(&info) == 0) {
    boosted_priority = info.priority;
 3b2:	f8842a03          	lw	s4,-120(s0)
    print_status("After boost", &info, after_boost_tick);
 3b6:	864a                	mv	a2,s2
 3b8:	f8040593          	addi	a1,s0,-128
 3bc:	00001517          	auipc	a0,0x1
 3c0:	78c50513          	addi	a0,a0,1932 # 1b48 <malloc+0xca2>
 3c4:	c77ff0ef          	jal	3a <print_status>
    printf("  Boost executed between tick %d and %d\n", before_boost_tick, after_boost_tick);
 3c8:	864a                	mv	a2,s2
 3ca:	416985bb          	subw	a1,s3,s6
 3ce:	00001517          	auipc	a0,0x1
 3d2:	78a50513          	addi	a0,a0,1930 # 1b58 <malloc+0xcb2>
 3d6:	21d000ef          	jal	df2 <printf>
    
    if(boosted_priority == 0 && info.time_slices == 0) {
 3da:	f8c42603          	lw	a2,-116(s0)
 3de:	01466cb3          	or	s9,a2,s4
 3e2:	000c8d63          	beqz	s9,3fc <main+0x2f8>
      printf("  ✓ PASS: Process boosted to Q0 with slices reset\n");
    } else {
      printf("  ✗ FAIL: Boost incomplete (Q%d, slices=%d)\n", 
 3e6:	85d2                	mv	a1,s4
 3e8:	00001517          	auipc	a0,0x1
 3ec:	7d850513          	addi	a0,a0,2008 # 1bc0 <malloc+0xd1a>
 3f0:	203000ef          	jal	df2 <printf>
             boosted_priority, info.time_slices);
      test_passed = 0;
 3f4:	f6943423          	sd	s1,-152(s0)
    boosted_priority = info.priority;
 3f8:	8cd2                	mv	s9,s4
 3fa:	ace9                	j	6d4 <main+0x5d0>
      printf("  ✓ PASS: Process boosted to Q0 with slices reset\n");
 3fc:	00001517          	auipc	a0,0x1
 400:	78c50513          	addi	a0,a0,1932 # 1b88 <malloc+0xce2>
 404:	1ef000ef          	jal	df2 <printf>
 408:	a4f1                	j	6d4 <main+0x5d0>
        if(info.priority > last_priority) {
          printf("  > TICK %d: DEMOTED Q%d->Q%d\n",
                 current_tick, last_priority, info.priority);
          demotion_seen = 1;
        } else {
          printf("  < TICK %d: AUTO BOOST Q%d->Q%d\n",
 40a:	864e                	mv	a2,s3
 40c:	855e                	mv	a0,s7
 40e:	1e5000ef          	jal	df2 <printf>
                 current_tick, last_priority, info.priority);
        }
        last_priority = info.priority;
 412:	f8842983          	lw	s3,-120(s0)
  for(int phase = 0; phase < 25; phase++) {
 416:	34fd                	addiw	s1,s1,-1
 418:	c88d                	beqz	s1,44a <main+0x346>
    cpu_work(WORK_ITERATIONS / 4);
 41a:	854a                	mv	a0,s2
 41c:	be5ff0ef          	jal	0 <cpu_work>
    if(getprocinfo(&info) == 0) {
 420:	f8040513          	addi	a0,s0,-128
 424:	636000ef          	jal	a5a <getprocinfo>
 428:	f57d                	bnez	a0,416 <main+0x312>
      current_tick = uptime() - start_tick;
 42a:	628000ef          	jal	a52 <uptime>
      if(info.priority != last_priority) {
 42e:	f8842683          	lw	a3,-120(s0)
 432:	ff3682e3          	beq	a3,s3,416 <main+0x312>
      current_tick = uptime() - start_tick;
 436:	416505bb          	subw	a1,a0,s6
        if(info.priority > last_priority) {
 43a:	fcd9d8e3          	bge	s3,a3,40a <main+0x306>
          printf("  > TICK %d: DEMOTED Q%d->Q%d\n",
 43e:	864e                	mv	a2,s3
 440:	8556                	mv	a0,s5
 442:	1b1000ef          	jal	df2 <printf>
          demotion_seen = 1;
 446:	8d52                	mv	s10,s4
 448:	b7e9                	j	412 <main+0x30e>
      }
      last_slices = info.time_slices;
    }
  }
  
  if(getprocinfo(&info) == 0) {
 44a:	f8040513          	addi	a0,s0,-128
 44e:	60c000ef          	jal	a5a <getprocinfo>
 452:	c551                	beqz	a0,4de <main+0x3da>
    } else {
      printf("  ✗ FAIL: No demotions observed\n");
      test_passed = 0;
    }
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
 454:	00001517          	auipc	a0,0x1
 458:	21450513          	addi	a0,a0,532 # 1668 <malloc+0x7c2>
 45c:	197000ef          	jal	df2 <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 5: Automatic Periodic Boost
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 5: Automatic Periodic Boost ───────────────────────┐\n");
 460:	00002517          	auipc	a0,0x2
 464:	93050513          	addi	a0,a0,-1744 # 1d90 <malloc+0xeea>
 468:	18b000ef          	jal	df2 <printf>
  printf("  Waiting and working until automatic boost triggers...\n");
 46c:	00002517          	auipc	a0,0x2
 470:	99c50513          	addi	a0,a0,-1636 # 1e08 <malloc+0xf62>
 474:	17f000ef          	jal	df2 <printf>
  printf("  This tests starvation prevention mechanism.\n\n");
 478:	00002517          	auipc	a0,0x2
 47c:	9d050513          	addi	a0,a0,-1584 # 1e48 <malloc+0xfa2>
 480:	173000ef          	jal	df2 <printf>
  
  int boost_detected = 0;
  int prev_priority = info.priority;
 484:	f8842a83          	lw	s5,-120(s0)
  int wait_start = uptime();
 488:	5ca000ef          	jal	a52 <uptime>
 48c:	84aa                	mv	s1,a0
  int boost_detected = 0;
 48e:	4901                	li	s2,0
  last_slices = info.time_slices;
  
  while(uptime() - wait_start < 150 && !boost_detected) {
 490:	09500a13          	li	s4,149
    cpu_work(WORK_ITERATIONS / 4);
 494:	001319b7          	lui	s3,0x131
 498:	2d098993          	addi	s3,s3,720 # 1312d0 <base+0x12e2b0>
  while(uptime() - wait_start < 150 && !boost_detected) {
 49c:	5b6000ef          	jal	a52 <uptime>
 4a0:	9d05                	subw	a0,a0,s1
 4a2:	08aa4d63          	blt	s4,a0,53c <main+0x438>
 4a6:	0a091a63          	bnez	s2,55a <main+0x456>
    cpu_work(WORK_ITERATIONS / 4);
 4aa:	854e                	mv	a0,s3
 4ac:	b55ff0ef          	jal	0 <cpu_work>
    
    if(getprocinfo(&info) == 0) {
 4b0:	f8040513          	addi	a0,s0,-128
 4b4:	5a6000ef          	jal	a5a <getprocinfo>
 4b8:	8baa                	mv	s7,a0
 4ba:	f16d                	bnez	a0,49c <main+0x398>
      current_tick = uptime() - start_tick;
 4bc:	596000ef          	jal	a52 <uptime>
 4c0:	416505bb          	subw	a1,a0,s6
      
      if(prev_priority > 0 && info.priority == 0) {
 4c4:	01505563          	blez	s5,4ce <main+0x3ca>
 4c8:	f8842783          	lw	a5,-120(s0)
 4cc:	c7b9                	beqz	a5,51a <main+0x416>
        printf("  < TICK %d: AUTO BOOST DETECTED Q%d->Q0\n", 
               current_tick, prev_priority);
        boost_detected = 1;
      } else if(info.priority > prev_priority) {
 4ce:	f8842683          	lw	a3,-120(s0)
 4d2:	04dacd63          	blt	s5,a3,52c <main+0x428>
        printf("  > TICK %d: Demotion Q%d->Q%d\n",
               current_tick, prev_priority, info.priority);
      }
      prev_priority = info.priority;
 4d6:	f8842a83          	lw	s5,-120(s0)
 4da:	895e                	mv	s2,s7
 4dc:	b7c1                	j	49c <main+0x398>
    print_status("Final", &info, uptime() - start_tick);
 4de:	574000ef          	jal	a52 <uptime>
 4e2:	4165063b          	subw	a2,a0,s6
 4e6:	f8040593          	addi	a1,s0,-128
 4ea:	00002517          	auipc	a0,0x2
 4ee:	83e50513          	addi	a0,a0,-1986 # 1d28 <malloc+0xe82>
 4f2:	b49ff0ef          	jal	3a <print_status>
    if(demotion_seen) {
 4f6:	000d0963          	beqz	s10,508 <main+0x404>
      printf("  ✓ PASS: Demotion mechanism working after boost\n");
 4fa:	00002517          	auipc	a0,0x2
 4fe:	83650513          	addi	a0,a0,-1994 # 1d30 <malloc+0xe8a>
 502:	0f1000ef          	jal	df2 <printf>
 506:	b7b9                	j	454 <main+0x350>
      printf("  ✗ FAIL: No demotions observed\n");
 508:	00002517          	auipc	a0,0x2
 50c:	86050513          	addi	a0,a0,-1952 # 1d68 <malloc+0xec2>
 510:	0e3000ef          	jal	df2 <printf>
      test_passed = 0;
 514:	f7a43423          	sd	s10,-152(s0)
 518:	bf35                	j	454 <main+0x350>
        printf("  < TICK %d: AUTO BOOST DETECTED Q%d->Q0\n", 
 51a:	8656                	mv	a2,s5
 51c:	00002517          	auipc	a0,0x2
 520:	95c50513          	addi	a0,a0,-1700 # 1e78 <malloc+0xfd2>
 524:	0cf000ef          	jal	df2 <printf>
        boost_detected = 1;
 528:	4b85                	li	s7,1
 52a:	b775                	j	4d6 <main+0x3d2>
        printf("  > TICK %d: Demotion Q%d->Q%d\n",
 52c:	8656                	mv	a2,s5
 52e:	00002517          	auipc	a0,0x2
 532:	97a50513          	addi	a0,a0,-1670 # 1ea8 <malloc+0x1002>
 536:	0bd000ef          	jal	df2 <printf>
 53a:	bf71                	j	4d6 <main+0x3d2>
      last_slices = info.time_slices;
    }
  }
  
  if(boost_detected) {
 53c:	00091f63          	bnez	s2,55a <main+0x456>
    printf("  ✓ PASS: Automatic periodic boost working!\n");
  } else {
    printf("  ? INFO: Auto boost not observed in time window\n");
 540:	00002517          	auipc	a0,0x2
 544:	9b850513          	addi	a0,a0,-1608 # 1ef8 <malloc+0x1052>
 548:	0ab000ef          	jal	df2 <printf>
    printf("          (May have been at Q0 when boost occurred)\n");
 54c:	00002517          	auipc	a0,0x2
 550:	9e450513          	addi	a0,a0,-1564 # 1f30 <malloc+0x108a>
 554:	09f000ef          	jal	df2 <printf>
 558:	a039                	j	566 <main+0x462>
    printf("  ✓ PASS: Automatic periodic boost working!\n");
 55a:	00002517          	auipc	a0,0x2
 55e:	96e50513          	addi	a0,a0,-1682 # 1ec8 <malloc+0x1022>
 562:	091000ef          	jal	df2 <printf>
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
 566:	00001517          	auipc	a0,0x1
 56a:	10250513          	addi	a0,a0,258 # 1668 <malloc+0x7c2>
 56e:	085000ef          	jal	df2 <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // Summary
  // ═══════════════════════════════════════════════════════════════
  printf("╔══════════════════════════════════════════════════════════╗\n");
 572:	00001517          	auipc	a0,0x1
 576:	e5650513          	addi	a0,a0,-426 # 13c8 <malloc+0x522>
 57a:	079000ef          	jal	df2 <printf>
  printf("║                    TEST SUMMARY                          ║\n");
 57e:	00002517          	auipc	a0,0x2
 582:	9ea50513          	addi	a0,a0,-1558 # 1f68 <malloc+0x10c2>
 586:	06d000ef          	jal	df2 <printf>
  printf("╠══════════════════════════════════════════════════════════╣\n");
 58a:	00002517          	auipc	a0,0x2
 58e:	a2650513          	addi	a0,a0,-1498 # 1fb0 <malloc+0x110a>
 592:	061000ef          	jal	df2 <printf>
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
         uptime() - start_tick, (uptime() - start_tick)/10, (uptime() - start_tick)%10);
 596:	4bc000ef          	jal	a52 <uptime>
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
 59a:	416509bb          	subw	s3,a0,s6
         uptime() - start_tick, (uptime() - start_tick)/10, (uptime() - start_tick)%10);
 59e:	4b4000ef          	jal	a52 <uptime>
 5a2:	84aa                	mv	s1,a0
 5a4:	4ae000ef          	jal	a52 <uptime>
 5a8:	416506bb          	subw	a3,a0,s6
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
 5ac:	4629                	li	a2,10
         uptime() - start_tick, (uptime() - start_tick)/10, (uptime() - start_tick)%10);
 5ae:	416484bb          	subw	s1,s1,s6
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
 5b2:	02c6e6bb          	remw	a3,a3,a2
 5b6:	02c4c63b          	divw	a2,s1,a2
 5ba:	85ce                	mv	a1,s3
 5bc:	00002517          	auipc	a0,0x2
 5c0:	aac50513          	addi	a0,a0,-1364 # 2068 <malloc+0x11c2>
 5c4:	02f000ef          	jal	df2 <printf>
  printf("║  Initial priority: Q%d                                    \n", initial_priority);
 5c8:	f6043583          	ld	a1,-160(s0)
 5cc:	00002517          	auipc	a0,0x2
 5d0:	adc50513          	addi	a0,a0,-1316 # 20a8 <malloc+0x1202>
 5d4:	01f000ef          	jal	df2 <printf>
  printf("║  Max demotion reached: Q%d                                \n", demoted_priority);
 5d8:	85e2                	mv	a1,s8
 5da:	00002517          	auipc	a0,0x2
 5de:	b0e50513          	addi	a0,a0,-1266 # 20e8 <malloc+0x1242>
 5e2:	011000ef          	jal	df2 <printf>
  printf("║  Manual boost: %s                                        \n", 
 5e6:	00001597          	auipc	a1,0x1
 5ea:	dba58593          	addi	a1,a1,-582 # 13a0 <malloc+0x4fa>
 5ee:	000c9663          	bnez	s9,5fa <main+0x4f6>
 5f2:	00001597          	auipc	a1,0x1
 5f6:	da658593          	addi	a1,a1,-602 # 1398 <malloc+0x4f2>
 5fa:	00002517          	auipc	a0,0x2
 5fe:	b2e50513          	addi	a0,a0,-1234 # 2128 <malloc+0x1282>
 602:	7f0000ef          	jal	df2 <printf>
         boosted_priority == 0 ? "Working" : "Failed");
  printf("║  Auto boost: %s                                          \n",
 606:	00001597          	auipc	a1,0x1
 60a:	db258593          	addi	a1,a1,-590 # 13b8 <malloc+0x512>
 60e:	00090663          	beqz	s2,61a <main+0x516>
 612:	00001597          	auipc	a1,0x1
 616:	d9658593          	addi	a1,a1,-618 # 13a8 <malloc+0x502>
 61a:	00002517          	auipc	a0,0x2
 61e:	b4e50513          	addi	a0,a0,-1202 # 2168 <malloc+0x12c2>
 622:	7d0000ef          	jal	df2 <printf>
         boost_detected ? "Detected" : "Not observed");
  printf("╠══════════════════════════════════════════════════════════╣\n");
 626:	00002517          	auipc	a0,0x2
 62a:	98a50513          	addi	a0,a0,-1654 # 1fb0 <malloc+0x110a>
 62e:	7c4000ef          	jal	df2 <printf>
  if(test_passed) {
 632:	f6843783          	ld	a5,-152(s0)
 636:	c385                	beqz	a5,656 <main+0x552>
    printf("║  ✓✓✓ ALL CORE TESTS PASSED ✓✓✓                          ║\n");
 638:	00002517          	auipc	a0,0x2
 63c:	b7050513          	addi	a0,a0,-1168 # 21a8 <malloc+0x1302>
 640:	7b2000ef          	jal	df2 <printf>
  } else {
    printf("║  ✗✗✗ SOME TESTS FAILED ✗✗✗                              ║\n");
  }
  printf("╚══════════════════════════════════════════════════════════╝\n");
 644:	00002517          	auipc	a0,0x2
 648:	c0450513          	addi	a0,a0,-1020 # 2248 <malloc+0x13a2>
 64c:	7a6000ef          	jal	df2 <printf>
  
  exit(0);
 650:	4501                	li	a0,0
 652:	368000ef          	jal	9ba <exit>
    printf("║  ✗✗✗ SOME TESTS FAILED ✗✗✗                              ║\n");
 656:	00002517          	auipc	a0,0x2
 65a:	ba250513          	addi	a0,a0,-1118 # 21f8 <malloc+0x1352>
 65e:	794000ef          	jal	df2 <printf>
 662:	b7cd                	j	644 <main+0x540>
      if(reached_q3 && info.priority == 3 && q3_slices_shown >= 4) {
 664:	c38bdee3          	bge	s7,s8,2a0 <main+0x19c>
  printf("  ─────────────────────────────────────────────────────────\n");
 668:	00001517          	auipc	a0,0x1
 66c:	18850513          	addi	a0,a0,392 # 17f0 <malloc+0x94a>
 670:	782000ef          	jal	df2 <printf>
  if(getprocinfo(&info) == 0) {
 674:	f8040513          	addi	a0,s0,-128
 678:	3e2000ef          	jal	a5a <getprocinfo>
 67c:	84aa                	mv	s1,a0
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
 67e:	4c01                	li	s8,0
  if(getprocinfo(&info) == 0) {
 680:	c60503e3          	beqz	a0,2e6 <main+0x1e2>
  printf("└────────────────────────────────────────────────────────────┘\n\n");
 684:	00001517          	auipc	a0,0x1
 688:	fe450513          	addi	a0,a0,-28 # 1668 <malloc+0x7c2>
 68c:	766000ef          	jal	df2 <printf>
  printf("┌─ TEST 3: Manual Boost (boostproc syscall) ───────────────┐\n");
 690:	00001517          	auipc	a0,0x1
 694:	42050513          	addi	a0,a0,1056 # 1ab0 <malloc+0xc0a>
 698:	75a000ef          	jal	df2 <printf>
  if(getprocinfo(&info) == 0) {
 69c:	f8040513          	addi	a0,s0,-128
 6a0:	3ba000ef          	jal	a5a <getprocinfo>
 6a4:	ce0508e3          	beqz	a0,394 <main+0x290>
  printf("  Calling boostproc()...\n");
 6a8:	00001517          	auipc	a0,0x1
 6ac:	48050513          	addi	a0,a0,1152 # 1b28 <malloc+0xc82>
 6b0:	742000ef          	jal	df2 <printf>
  int before_boost_tick = uptime() - start_tick;
 6b4:	39e000ef          	jal	a52 <uptime>
 6b8:	89aa                	mv	s3,a0
  boostproc();
 6ba:	3a8000ef          	jal	a62 <boostproc>
  int after_boost_tick = uptime() - start_tick;
 6be:	394000ef          	jal	a52 <uptime>
 6c2:	892a                	mv	s2,a0
  if(getprocinfo(&info) == 0) {
 6c4:	f8040513          	addi	a0,s0,-128
 6c8:	392000ef          	jal	a5a <getprocinfo>
 6cc:	84aa                	mv	s1,a0
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
 6ce:	4c81                	li	s9,0
  if(getprocinfo(&info) == 0) {
 6d0:	cc050fe3          	beqz	a0,3ae <main+0x2aa>
  printf("└────────────────────────────────────────────────────────────┘\n\n");
 6d4:	00001517          	auipc	a0,0x1
 6d8:	f9450513          	addi	a0,a0,-108 # 1668 <malloc+0x7c2>
 6dc:	716000ef          	jal	df2 <printf>
  printf("┌─ TEST 4: Re-demotion After Boost ────────────────────────┐\n");
 6e0:	00001517          	auipc	a0,0x1
 6e4:	51050513          	addi	a0,a0,1296 # 1bf0 <malloc+0xd4a>
 6e8:	70a000ef          	jal	df2 <printf>
  printf("  Verifying demotion still works after manual boost...\n");
 6ec:	00001517          	auipc	a0,0x1
 6f0:	57c50513          	addi	a0,a0,1404 # 1c68 <malloc+0xdc2>
 6f4:	6fe000ef          	jal	df2 <printf>
  printf("  (Note: Auto-boost may interfere if BOOST_INTERVAL is short)\n\n");
 6f8:	00001517          	auipc	a0,0x1
 6fc:	5a850513          	addi	a0,a0,1448 # 1ca0 <malloc+0xdfa>
 700:	6f2000ef          	jal	df2 <printf>
 704:	44e5                	li	s1,25
  int demotion_seen = 0;
 706:	4d01                	li	s10,0
  last_priority = 0;
 708:	4981                	li	s3,0
    cpu_work(WORK_ITERATIONS / 4);
 70a:	00131937          	lui	s2,0x131
 70e:	2d090913          	addi	s2,s2,720 # 1312d0 <base+0x12e2b0>
          printf("  < TICK %d: AUTO BOOST Q%d->Q%d\n",
 712:	00001b97          	auipc	s7,0x1
 716:	5eeb8b93          	addi	s7,s7,1518 # 1d00 <malloc+0xe5a>
          printf("  > TICK %d: DEMOTED Q%d->Q%d\n",
 71a:	00001a97          	auipc	s5,0x1
 71e:	5c6a8a93          	addi	s5,s5,1478 # 1ce0 <malloc+0xe3a>
          demotion_seen = 1;
 722:	4a05                	li	s4,1
 724:	b9dd                	j	41a <main+0x316>

0000000000000726 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 726:	1141                	addi	sp,sp,-16
 728:	e406                	sd	ra,8(sp)
 72a:	e022                	sd	s0,0(sp)
 72c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 72e:	9d7ff0ef          	jal	104 <main>
  exit(r);
 732:	288000ef          	jal	9ba <exit>

0000000000000736 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 736:	1141                	addi	sp,sp,-16
 738:	e422                	sd	s0,8(sp)
 73a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 73c:	87aa                	mv	a5,a0
 73e:	0585                	addi	a1,a1,1
 740:	0785                	addi	a5,a5,1
 742:	fff5c703          	lbu	a4,-1(a1)
 746:	fee78fa3          	sb	a4,-1(a5)
 74a:	fb75                	bnez	a4,73e <strcpy+0x8>
    ;
  return os;
}
 74c:	6422                	ld	s0,8(sp)
 74e:	0141                	addi	sp,sp,16
 750:	8082                	ret

0000000000000752 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 752:	1141                	addi	sp,sp,-16
 754:	e422                	sd	s0,8(sp)
 756:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 758:	00054783          	lbu	a5,0(a0)
 75c:	cb91                	beqz	a5,770 <strcmp+0x1e>
 75e:	0005c703          	lbu	a4,0(a1)
 762:	00f71763          	bne	a4,a5,770 <strcmp+0x1e>
    p++, q++;
 766:	0505                	addi	a0,a0,1
 768:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 76a:	00054783          	lbu	a5,0(a0)
 76e:	fbe5                	bnez	a5,75e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 770:	0005c503          	lbu	a0,0(a1)
}
 774:	40a7853b          	subw	a0,a5,a0
 778:	6422                	ld	s0,8(sp)
 77a:	0141                	addi	sp,sp,16
 77c:	8082                	ret

000000000000077e <strlen>:

uint
strlen(const char *s)
{
 77e:	1141                	addi	sp,sp,-16
 780:	e422                	sd	s0,8(sp)
 782:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 784:	00054783          	lbu	a5,0(a0)
 788:	cf91                	beqz	a5,7a4 <strlen+0x26>
 78a:	0505                	addi	a0,a0,1
 78c:	87aa                	mv	a5,a0
 78e:	86be                	mv	a3,a5
 790:	0785                	addi	a5,a5,1
 792:	fff7c703          	lbu	a4,-1(a5)
 796:	ff65                	bnez	a4,78e <strlen+0x10>
 798:	40a6853b          	subw	a0,a3,a0
 79c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 79e:	6422                	ld	s0,8(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret
  for(n = 0; s[n]; n++)
 7a4:	4501                	li	a0,0
 7a6:	bfe5                	j	79e <strlen+0x20>

00000000000007a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 7a8:	1141                	addi	sp,sp,-16
 7aa:	e422                	sd	s0,8(sp)
 7ac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 7ae:	ca19                	beqz	a2,7c4 <memset+0x1c>
 7b0:	87aa                	mv	a5,a0
 7b2:	1602                	slli	a2,a2,0x20
 7b4:	9201                	srli	a2,a2,0x20
 7b6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 7ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 7be:	0785                	addi	a5,a5,1
 7c0:	fee79de3          	bne	a5,a4,7ba <memset+0x12>
  }
  return dst;
}
 7c4:	6422                	ld	s0,8(sp)
 7c6:	0141                	addi	sp,sp,16
 7c8:	8082                	ret

00000000000007ca <strchr>:

char*
strchr(const char *s, char c)
{
 7ca:	1141                	addi	sp,sp,-16
 7cc:	e422                	sd	s0,8(sp)
 7ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 7d0:	00054783          	lbu	a5,0(a0)
 7d4:	cb99                	beqz	a5,7ea <strchr+0x20>
    if(*s == c)
 7d6:	00f58763          	beq	a1,a5,7e4 <strchr+0x1a>
  for(; *s; s++)
 7da:	0505                	addi	a0,a0,1
 7dc:	00054783          	lbu	a5,0(a0)
 7e0:	fbfd                	bnez	a5,7d6 <strchr+0xc>
      return (char*)s;
  return 0;
 7e2:	4501                	li	a0,0
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret
  return 0;
 7ea:	4501                	li	a0,0
 7ec:	bfe5                	j	7e4 <strchr+0x1a>

00000000000007ee <gets>:

char*
gets(char *buf, int max)
{
 7ee:	711d                	addi	sp,sp,-96
 7f0:	ec86                	sd	ra,88(sp)
 7f2:	e8a2                	sd	s0,80(sp)
 7f4:	e4a6                	sd	s1,72(sp)
 7f6:	e0ca                	sd	s2,64(sp)
 7f8:	fc4e                	sd	s3,56(sp)
 7fa:	f852                	sd	s4,48(sp)
 7fc:	f456                	sd	s5,40(sp)
 7fe:	f05a                	sd	s6,32(sp)
 800:	ec5e                	sd	s7,24(sp)
 802:	1080                	addi	s0,sp,96
 804:	8baa                	mv	s7,a0
 806:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 808:	892a                	mv	s2,a0
 80a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 80c:	4aa9                	li	s5,10
 80e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 810:	89a6                	mv	s3,s1
 812:	2485                	addiw	s1,s1,1
 814:	0344d663          	bge	s1,s4,840 <gets+0x52>
    cc = read(0, &c, 1);
 818:	4605                	li	a2,1
 81a:	faf40593          	addi	a1,s0,-81
 81e:	4501                	li	a0,0
 820:	1b2000ef          	jal	9d2 <read>
    if(cc < 1)
 824:	00a05e63          	blez	a0,840 <gets+0x52>
    buf[i++] = c;
 828:	faf44783          	lbu	a5,-81(s0)
 82c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 830:	01578763          	beq	a5,s5,83e <gets+0x50>
 834:	0905                	addi	s2,s2,1
 836:	fd679de3          	bne	a5,s6,810 <gets+0x22>
    buf[i++] = c;
 83a:	89a6                	mv	s3,s1
 83c:	a011                	j	840 <gets+0x52>
 83e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 840:	99de                	add	s3,s3,s7
 842:	00098023          	sb	zero,0(s3)
  return buf;
}
 846:	855e                	mv	a0,s7
 848:	60e6                	ld	ra,88(sp)
 84a:	6446                	ld	s0,80(sp)
 84c:	64a6                	ld	s1,72(sp)
 84e:	6906                	ld	s2,64(sp)
 850:	79e2                	ld	s3,56(sp)
 852:	7a42                	ld	s4,48(sp)
 854:	7aa2                	ld	s5,40(sp)
 856:	7b02                	ld	s6,32(sp)
 858:	6be2                	ld	s7,24(sp)
 85a:	6125                	addi	sp,sp,96
 85c:	8082                	ret

000000000000085e <stat>:

int
stat(const char *n, struct stat *st)
{
 85e:	1101                	addi	sp,sp,-32
 860:	ec06                	sd	ra,24(sp)
 862:	e822                	sd	s0,16(sp)
 864:	e04a                	sd	s2,0(sp)
 866:	1000                	addi	s0,sp,32
 868:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 86a:	4581                	li	a1,0
 86c:	18e000ef          	jal	9fa <open>
  if(fd < 0)
 870:	02054263          	bltz	a0,894 <stat+0x36>
 874:	e426                	sd	s1,8(sp)
 876:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 878:	85ca                	mv	a1,s2
 87a:	198000ef          	jal	a12 <fstat>
 87e:	892a                	mv	s2,a0
  close(fd);
 880:	8526                	mv	a0,s1
 882:	160000ef          	jal	9e2 <close>
  return r;
 886:	64a2                	ld	s1,8(sp)
}
 888:	854a                	mv	a0,s2
 88a:	60e2                	ld	ra,24(sp)
 88c:	6442                	ld	s0,16(sp)
 88e:	6902                	ld	s2,0(sp)
 890:	6105                	addi	sp,sp,32
 892:	8082                	ret
    return -1;
 894:	597d                	li	s2,-1
 896:	bfcd                	j	888 <stat+0x2a>

0000000000000898 <atoi>:

int
atoi(const char *s)
{
 898:	1141                	addi	sp,sp,-16
 89a:	e422                	sd	s0,8(sp)
 89c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 89e:	00054683          	lbu	a3,0(a0)
 8a2:	fd06879b          	addiw	a5,a3,-48
 8a6:	0ff7f793          	zext.b	a5,a5
 8aa:	4625                	li	a2,9
 8ac:	02f66863          	bltu	a2,a5,8dc <atoi+0x44>
 8b0:	872a                	mv	a4,a0
  n = 0;
 8b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 8b4:	0705                	addi	a4,a4,1
 8b6:	0025179b          	slliw	a5,a0,0x2
 8ba:	9fa9                	addw	a5,a5,a0
 8bc:	0017979b          	slliw	a5,a5,0x1
 8c0:	9fb5                	addw	a5,a5,a3
 8c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 8c6:	00074683          	lbu	a3,0(a4)
 8ca:	fd06879b          	addiw	a5,a3,-48
 8ce:	0ff7f793          	zext.b	a5,a5
 8d2:	fef671e3          	bgeu	a2,a5,8b4 <atoi+0x1c>
  return n;
}
 8d6:	6422                	ld	s0,8(sp)
 8d8:	0141                	addi	sp,sp,16
 8da:	8082                	ret
  n = 0;
 8dc:	4501                	li	a0,0
 8de:	bfe5                	j	8d6 <atoi+0x3e>

00000000000008e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 8e0:	1141                	addi	sp,sp,-16
 8e2:	e422                	sd	s0,8(sp)
 8e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 8e6:	02b57463          	bgeu	a0,a1,90e <memmove+0x2e>
    while(n-- > 0)
 8ea:	00c05f63          	blez	a2,908 <memmove+0x28>
 8ee:	1602                	slli	a2,a2,0x20
 8f0:	9201                	srli	a2,a2,0x20
 8f2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 8f6:	872a                	mv	a4,a0
      *dst++ = *src++;
 8f8:	0585                	addi	a1,a1,1
 8fa:	0705                	addi	a4,a4,1
 8fc:	fff5c683          	lbu	a3,-1(a1)
 900:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 904:	fef71ae3          	bne	a4,a5,8f8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 908:	6422                	ld	s0,8(sp)
 90a:	0141                	addi	sp,sp,16
 90c:	8082                	ret
    dst += n;
 90e:	00c50733          	add	a4,a0,a2
    src += n;
 912:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 914:	fec05ae3          	blez	a2,908 <memmove+0x28>
 918:	fff6079b          	addiw	a5,a2,-1
 91c:	1782                	slli	a5,a5,0x20
 91e:	9381                	srli	a5,a5,0x20
 920:	fff7c793          	not	a5,a5
 924:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 926:	15fd                	addi	a1,a1,-1
 928:	177d                	addi	a4,a4,-1
 92a:	0005c683          	lbu	a3,0(a1)
 92e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 932:	fee79ae3          	bne	a5,a4,926 <memmove+0x46>
 936:	bfc9                	j	908 <memmove+0x28>

0000000000000938 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 938:	1141                	addi	sp,sp,-16
 93a:	e422                	sd	s0,8(sp)
 93c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 93e:	ca05                	beqz	a2,96e <memcmp+0x36>
 940:	fff6069b          	addiw	a3,a2,-1
 944:	1682                	slli	a3,a3,0x20
 946:	9281                	srli	a3,a3,0x20
 948:	0685                	addi	a3,a3,1
 94a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 94c:	00054783          	lbu	a5,0(a0)
 950:	0005c703          	lbu	a4,0(a1)
 954:	00e79863          	bne	a5,a4,964 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 958:	0505                	addi	a0,a0,1
    p2++;
 95a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 95c:	fed518e3          	bne	a0,a3,94c <memcmp+0x14>
  }
  return 0;
 960:	4501                	li	a0,0
 962:	a019                	j	968 <memcmp+0x30>
      return *p1 - *p2;
 964:	40e7853b          	subw	a0,a5,a4
}
 968:	6422                	ld	s0,8(sp)
 96a:	0141                	addi	sp,sp,16
 96c:	8082                	ret
  return 0;
 96e:	4501                	li	a0,0
 970:	bfe5                	j	968 <memcmp+0x30>

0000000000000972 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 972:	1141                	addi	sp,sp,-16
 974:	e406                	sd	ra,8(sp)
 976:	e022                	sd	s0,0(sp)
 978:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 97a:	f67ff0ef          	jal	8e0 <memmove>
}
 97e:	60a2                	ld	ra,8(sp)
 980:	6402                	ld	s0,0(sp)
 982:	0141                	addi	sp,sp,16
 984:	8082                	ret

0000000000000986 <sbrk>:

char *
sbrk(int n) {
 986:	1141                	addi	sp,sp,-16
 988:	e406                	sd	ra,8(sp)
 98a:	e022                	sd	s0,0(sp)
 98c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 98e:	4585                	li	a1,1
 990:	0b2000ef          	jal	a42 <sys_sbrk>
}
 994:	60a2                	ld	ra,8(sp)
 996:	6402                	ld	s0,0(sp)
 998:	0141                	addi	sp,sp,16
 99a:	8082                	ret

000000000000099c <sbrklazy>:

char *
sbrklazy(int n) {
 99c:	1141                	addi	sp,sp,-16
 99e:	e406                	sd	ra,8(sp)
 9a0:	e022                	sd	s0,0(sp)
 9a2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 9a4:	4589                	li	a1,2
 9a6:	09c000ef          	jal	a42 <sys_sbrk>
}
 9aa:	60a2                	ld	ra,8(sp)
 9ac:	6402                	ld	s0,0(sp)
 9ae:	0141                	addi	sp,sp,16
 9b0:	8082                	ret

00000000000009b2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 9b2:	4885                	li	a7,1
 ecall
 9b4:	00000073          	ecall
 ret
 9b8:	8082                	ret

00000000000009ba <exit>:
.global exit
exit:
 li a7, SYS_exit
 9ba:	4889                	li	a7,2
 ecall
 9bc:	00000073          	ecall
 ret
 9c0:	8082                	ret

00000000000009c2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 9c2:	488d                	li	a7,3
 ecall
 9c4:	00000073          	ecall
 ret
 9c8:	8082                	ret

00000000000009ca <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 9ca:	4891                	li	a7,4
 ecall
 9cc:	00000073          	ecall
 ret
 9d0:	8082                	ret

00000000000009d2 <read>:
.global read
read:
 li a7, SYS_read
 9d2:	4895                	li	a7,5
 ecall
 9d4:	00000073          	ecall
 ret
 9d8:	8082                	ret

00000000000009da <write>:
.global write
write:
 li a7, SYS_write
 9da:	48c1                	li	a7,16
 ecall
 9dc:	00000073          	ecall
 ret
 9e0:	8082                	ret

00000000000009e2 <close>:
.global close
close:
 li a7, SYS_close
 9e2:	48d5                	li	a7,21
 ecall
 9e4:	00000073          	ecall
 ret
 9e8:	8082                	ret

00000000000009ea <kill>:
.global kill
kill:
 li a7, SYS_kill
 9ea:	4899                	li	a7,6
 ecall
 9ec:	00000073          	ecall
 ret
 9f0:	8082                	ret

00000000000009f2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 9f2:	489d                	li	a7,7
 ecall
 9f4:	00000073          	ecall
 ret
 9f8:	8082                	ret

00000000000009fa <open>:
.global open
open:
 li a7, SYS_open
 9fa:	48bd                	li	a7,15
 ecall
 9fc:	00000073          	ecall
 ret
 a00:	8082                	ret

0000000000000a02 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 a02:	48c5                	li	a7,17
 ecall
 a04:	00000073          	ecall
 ret
 a08:	8082                	ret

0000000000000a0a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a0a:	48c9                	li	a7,18
 ecall
 a0c:	00000073          	ecall
 ret
 a10:	8082                	ret

0000000000000a12 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a12:	48a1                	li	a7,8
 ecall
 a14:	00000073          	ecall
 ret
 a18:	8082                	ret

0000000000000a1a <link>:
.global link
link:
 li a7, SYS_link
 a1a:	48cd                	li	a7,19
 ecall
 a1c:	00000073          	ecall
 ret
 a20:	8082                	ret

0000000000000a22 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 a22:	48d1                	li	a7,20
 ecall
 a24:	00000073          	ecall
 ret
 a28:	8082                	ret

0000000000000a2a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 a2a:	48a5                	li	a7,9
 ecall
 a2c:	00000073          	ecall
 ret
 a30:	8082                	ret

0000000000000a32 <dup>:
.global dup
dup:
 li a7, SYS_dup
 a32:	48a9                	li	a7,10
 ecall
 a34:	00000073          	ecall
 ret
 a38:	8082                	ret

0000000000000a3a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 a3a:	48ad                	li	a7,11
 ecall
 a3c:	00000073          	ecall
 ret
 a40:	8082                	ret

0000000000000a42 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 a42:	48b1                	li	a7,12
 ecall
 a44:	00000073          	ecall
 ret
 a48:	8082                	ret

0000000000000a4a <pause>:
.global pause
pause:
 li a7, SYS_pause
 a4a:	48b5                	li	a7,13
 ecall
 a4c:	00000073          	ecall
 ret
 a50:	8082                	ret

0000000000000a52 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 a52:	48b9                	li	a7,14
 ecall
 a54:	00000073          	ecall
 ret
 a58:	8082                	ret

0000000000000a5a <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 a5a:	48d9                	li	a7,22
 ecall
 a5c:	00000073          	ecall
 ret
 a60:	8082                	ret

0000000000000a62 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 a62:	48dd                	li	a7,23
 ecall
 a64:	00000073          	ecall
 ret
 a68:	8082                	ret

0000000000000a6a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 a6a:	1101                	addi	sp,sp,-32
 a6c:	ec06                	sd	ra,24(sp)
 a6e:	e822                	sd	s0,16(sp)
 a70:	1000                	addi	s0,sp,32
 a72:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 a76:	4605                	li	a2,1
 a78:	fef40593          	addi	a1,s0,-17
 a7c:	f5fff0ef          	jal	9da <write>
}
 a80:	60e2                	ld	ra,24(sp)
 a82:	6442                	ld	s0,16(sp)
 a84:	6105                	addi	sp,sp,32
 a86:	8082                	ret

0000000000000a88 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 a88:	715d                	addi	sp,sp,-80
 a8a:	e486                	sd	ra,72(sp)
 a8c:	e0a2                	sd	s0,64(sp)
 a8e:	f84a                	sd	s2,48(sp)
 a90:	0880                	addi	s0,sp,80
 a92:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 a94:	c299                	beqz	a3,a9a <printint+0x12>
 a96:	0805c363          	bltz	a1,b1c <printint+0x94>
  neg = 0;
 a9a:	4881                	li	a7,0
 a9c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 aa0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 aa2:	00002517          	auipc	a0,0x2
 aa6:	86650513          	addi	a0,a0,-1946 # 2308 <digits>
 aaa:	883e                	mv	a6,a5
 aac:	2785                	addiw	a5,a5,1
 aae:	02c5f733          	remu	a4,a1,a2
 ab2:	972a                	add	a4,a4,a0
 ab4:	00074703          	lbu	a4,0(a4)
 ab8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 abc:	872e                	mv	a4,a1
 abe:	02c5d5b3          	divu	a1,a1,a2
 ac2:	0685                	addi	a3,a3,1
 ac4:	fec773e3          	bgeu	a4,a2,aaa <printint+0x22>
  if(neg)
 ac8:	00088b63          	beqz	a7,ade <printint+0x56>
    buf[i++] = '-';
 acc:	fd078793          	addi	a5,a5,-48
 ad0:	97a2                	add	a5,a5,s0
 ad2:	02d00713          	li	a4,45
 ad6:	fee78423          	sb	a4,-24(a5)
 ada:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 ade:	02f05a63          	blez	a5,b12 <printint+0x8a>
 ae2:	fc26                	sd	s1,56(sp)
 ae4:	f44e                	sd	s3,40(sp)
 ae6:	fb840713          	addi	a4,s0,-72
 aea:	00f704b3          	add	s1,a4,a5
 aee:	fff70993          	addi	s3,a4,-1
 af2:	99be                	add	s3,s3,a5
 af4:	37fd                	addiw	a5,a5,-1
 af6:	1782                	slli	a5,a5,0x20
 af8:	9381                	srli	a5,a5,0x20
 afa:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 afe:	fff4c583          	lbu	a1,-1(s1)
 b02:	854a                	mv	a0,s2
 b04:	f67ff0ef          	jal	a6a <putc>
  while(--i >= 0)
 b08:	14fd                	addi	s1,s1,-1
 b0a:	ff349ae3          	bne	s1,s3,afe <printint+0x76>
 b0e:	74e2                	ld	s1,56(sp)
 b10:	79a2                	ld	s3,40(sp)
}
 b12:	60a6                	ld	ra,72(sp)
 b14:	6406                	ld	s0,64(sp)
 b16:	7942                	ld	s2,48(sp)
 b18:	6161                	addi	sp,sp,80
 b1a:	8082                	ret
    x = -xx;
 b1c:	40b005b3          	neg	a1,a1
    neg = 1;
 b20:	4885                	li	a7,1
    x = -xx;
 b22:	bfad                	j	a9c <printint+0x14>

0000000000000b24 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 b24:	711d                	addi	sp,sp,-96
 b26:	ec86                	sd	ra,88(sp)
 b28:	e8a2                	sd	s0,80(sp)
 b2a:	e0ca                	sd	s2,64(sp)
 b2c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 b2e:	0005c903          	lbu	s2,0(a1)
 b32:	28090663          	beqz	s2,dbe <vprintf+0x29a>
 b36:	e4a6                	sd	s1,72(sp)
 b38:	fc4e                	sd	s3,56(sp)
 b3a:	f852                	sd	s4,48(sp)
 b3c:	f456                	sd	s5,40(sp)
 b3e:	f05a                	sd	s6,32(sp)
 b40:	ec5e                	sd	s7,24(sp)
 b42:	e862                	sd	s8,16(sp)
 b44:	e466                	sd	s9,8(sp)
 b46:	8b2a                	mv	s6,a0
 b48:	8a2e                	mv	s4,a1
 b4a:	8bb2                	mv	s7,a2
  state = 0;
 b4c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 b4e:	4481                	li	s1,0
 b50:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 b52:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 b56:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 b5a:	06c00c93          	li	s9,108
 b5e:	a005                	j	b7e <vprintf+0x5a>
        putc(fd, c0);
 b60:	85ca                	mv	a1,s2
 b62:	855a                	mv	a0,s6
 b64:	f07ff0ef          	jal	a6a <putc>
 b68:	a019                	j	b6e <vprintf+0x4a>
    } else if(state == '%'){
 b6a:	03598263          	beq	s3,s5,b8e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 b6e:	2485                	addiw	s1,s1,1
 b70:	8726                	mv	a4,s1
 b72:	009a07b3          	add	a5,s4,s1
 b76:	0007c903          	lbu	s2,0(a5)
 b7a:	22090a63          	beqz	s2,dae <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 b7e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 b82:	fe0994e3          	bnez	s3,b6a <vprintf+0x46>
      if(c0 == '%'){
 b86:	fd579de3          	bne	a5,s5,b60 <vprintf+0x3c>
        state = '%';
 b8a:	89be                	mv	s3,a5
 b8c:	b7cd                	j	b6e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 b8e:	00ea06b3          	add	a3,s4,a4
 b92:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 b96:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 b98:	c681                	beqz	a3,ba0 <vprintf+0x7c>
 b9a:	9752                	add	a4,a4,s4
 b9c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 ba0:	05878363          	beq	a5,s8,be6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 ba4:	05978d63          	beq	a5,s9,bfe <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 ba8:	07500713          	li	a4,117
 bac:	0ee78763          	beq	a5,a4,c9a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 bb0:	07800713          	li	a4,120
 bb4:	12e78963          	beq	a5,a4,ce6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 bb8:	07000713          	li	a4,112
 bbc:	14e78e63          	beq	a5,a4,d18 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 bc0:	06300713          	li	a4,99
 bc4:	18e78e63          	beq	a5,a4,d60 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 bc8:	07300713          	li	a4,115
 bcc:	1ae78463          	beq	a5,a4,d74 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 bd0:	02500713          	li	a4,37
 bd4:	04e79563          	bne	a5,a4,c1e <vprintf+0xfa>
        putc(fd, '%');
 bd8:	02500593          	li	a1,37
 bdc:	855a                	mv	a0,s6
 bde:	e8dff0ef          	jal	a6a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 be2:	4981                	li	s3,0
 be4:	b769                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 be6:	008b8913          	addi	s2,s7,8
 bea:	4685                	li	a3,1
 bec:	4629                	li	a2,10
 bee:	000ba583          	lw	a1,0(s7)
 bf2:	855a                	mv	a0,s6
 bf4:	e95ff0ef          	jal	a88 <printint>
 bf8:	8bca                	mv	s7,s2
      state = 0;
 bfa:	4981                	li	s3,0
 bfc:	bf8d                	j	b6e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 bfe:	06400793          	li	a5,100
 c02:	02f68963          	beq	a3,a5,c34 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 c06:	06c00793          	li	a5,108
 c0a:	04f68263          	beq	a3,a5,c4e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 c0e:	07500793          	li	a5,117
 c12:	0af68063          	beq	a3,a5,cb2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 c16:	07800793          	li	a5,120
 c1a:	0ef68263          	beq	a3,a5,cfe <vprintf+0x1da>
        putc(fd, '%');
 c1e:	02500593          	li	a1,37
 c22:	855a                	mv	a0,s6
 c24:	e47ff0ef          	jal	a6a <putc>
        putc(fd, c0);
 c28:	85ca                	mv	a1,s2
 c2a:	855a                	mv	a0,s6
 c2c:	e3fff0ef          	jal	a6a <putc>
      state = 0;
 c30:	4981                	li	s3,0
 c32:	bf35                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 c34:	008b8913          	addi	s2,s7,8
 c38:	4685                	li	a3,1
 c3a:	4629                	li	a2,10
 c3c:	000bb583          	ld	a1,0(s7)
 c40:	855a                	mv	a0,s6
 c42:	e47ff0ef          	jal	a88 <printint>
        i += 1;
 c46:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 c48:	8bca                	mv	s7,s2
      state = 0;
 c4a:	4981                	li	s3,0
        i += 1;
 c4c:	b70d                	j	b6e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 c4e:	06400793          	li	a5,100
 c52:	02f60763          	beq	a2,a5,c80 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 c56:	07500793          	li	a5,117
 c5a:	06f60963          	beq	a2,a5,ccc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 c5e:	07800793          	li	a5,120
 c62:	faf61ee3          	bne	a2,a5,c1e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 c66:	008b8913          	addi	s2,s7,8
 c6a:	4681                	li	a3,0
 c6c:	4641                	li	a2,16
 c6e:	000bb583          	ld	a1,0(s7)
 c72:	855a                	mv	a0,s6
 c74:	e15ff0ef          	jal	a88 <printint>
        i += 2;
 c78:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 c7a:	8bca                	mv	s7,s2
      state = 0;
 c7c:	4981                	li	s3,0
        i += 2;
 c7e:	bdc5                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 c80:	008b8913          	addi	s2,s7,8
 c84:	4685                	li	a3,1
 c86:	4629                	li	a2,10
 c88:	000bb583          	ld	a1,0(s7)
 c8c:	855a                	mv	a0,s6
 c8e:	dfbff0ef          	jal	a88 <printint>
        i += 2;
 c92:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 c94:	8bca                	mv	s7,s2
      state = 0;
 c96:	4981                	li	s3,0
        i += 2;
 c98:	bdd9                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 c9a:	008b8913          	addi	s2,s7,8
 c9e:	4681                	li	a3,0
 ca0:	4629                	li	a2,10
 ca2:	000be583          	lwu	a1,0(s7)
 ca6:	855a                	mv	a0,s6
 ca8:	de1ff0ef          	jal	a88 <printint>
 cac:	8bca                	mv	s7,s2
      state = 0;
 cae:	4981                	li	s3,0
 cb0:	bd7d                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 cb2:	008b8913          	addi	s2,s7,8
 cb6:	4681                	li	a3,0
 cb8:	4629                	li	a2,10
 cba:	000bb583          	ld	a1,0(s7)
 cbe:	855a                	mv	a0,s6
 cc0:	dc9ff0ef          	jal	a88 <printint>
        i += 1;
 cc4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 cc6:	8bca                	mv	s7,s2
      state = 0;
 cc8:	4981                	li	s3,0
        i += 1;
 cca:	b555                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ccc:	008b8913          	addi	s2,s7,8
 cd0:	4681                	li	a3,0
 cd2:	4629                	li	a2,10
 cd4:	000bb583          	ld	a1,0(s7)
 cd8:	855a                	mv	a0,s6
 cda:	dafff0ef          	jal	a88 <printint>
        i += 2;
 cde:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 ce0:	8bca                	mv	s7,s2
      state = 0;
 ce2:	4981                	li	s3,0
        i += 2;
 ce4:	b569                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 ce6:	008b8913          	addi	s2,s7,8
 cea:	4681                	li	a3,0
 cec:	4641                	li	a2,16
 cee:	000be583          	lwu	a1,0(s7)
 cf2:	855a                	mv	a0,s6
 cf4:	d95ff0ef          	jal	a88 <printint>
 cf8:	8bca                	mv	s7,s2
      state = 0;
 cfa:	4981                	li	s3,0
 cfc:	bd8d                	j	b6e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 cfe:	008b8913          	addi	s2,s7,8
 d02:	4681                	li	a3,0
 d04:	4641                	li	a2,16
 d06:	000bb583          	ld	a1,0(s7)
 d0a:	855a                	mv	a0,s6
 d0c:	d7dff0ef          	jal	a88 <printint>
        i += 1;
 d10:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 d12:	8bca                	mv	s7,s2
      state = 0;
 d14:	4981                	li	s3,0
        i += 1;
 d16:	bda1                	j	b6e <vprintf+0x4a>
 d18:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 d1a:	008b8d13          	addi	s10,s7,8
 d1e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 d22:	03000593          	li	a1,48
 d26:	855a                	mv	a0,s6
 d28:	d43ff0ef          	jal	a6a <putc>
  putc(fd, 'x');
 d2c:	07800593          	li	a1,120
 d30:	855a                	mv	a0,s6
 d32:	d39ff0ef          	jal	a6a <putc>
 d36:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d38:	00001b97          	auipc	s7,0x1
 d3c:	5d0b8b93          	addi	s7,s7,1488 # 2308 <digits>
 d40:	03c9d793          	srli	a5,s3,0x3c
 d44:	97de                	add	a5,a5,s7
 d46:	0007c583          	lbu	a1,0(a5)
 d4a:	855a                	mv	a0,s6
 d4c:	d1fff0ef          	jal	a6a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d50:	0992                	slli	s3,s3,0x4
 d52:	397d                	addiw	s2,s2,-1
 d54:	fe0916e3          	bnez	s2,d40 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 d58:	8bea                	mv	s7,s10
      state = 0;
 d5a:	4981                	li	s3,0
 d5c:	6d02                	ld	s10,0(sp)
 d5e:	bd01                	j	b6e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 d60:	008b8913          	addi	s2,s7,8
 d64:	000bc583          	lbu	a1,0(s7)
 d68:	855a                	mv	a0,s6
 d6a:	d01ff0ef          	jal	a6a <putc>
 d6e:	8bca                	mv	s7,s2
      state = 0;
 d70:	4981                	li	s3,0
 d72:	bbf5                	j	b6e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 d74:	008b8993          	addi	s3,s7,8
 d78:	000bb903          	ld	s2,0(s7)
 d7c:	00090f63          	beqz	s2,d9a <vprintf+0x276>
        for(; *s; s++)
 d80:	00094583          	lbu	a1,0(s2)
 d84:	c195                	beqz	a1,da8 <vprintf+0x284>
          putc(fd, *s);
 d86:	855a                	mv	a0,s6
 d88:	ce3ff0ef          	jal	a6a <putc>
        for(; *s; s++)
 d8c:	0905                	addi	s2,s2,1
 d8e:	00094583          	lbu	a1,0(s2)
 d92:	f9f5                	bnez	a1,d86 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 d94:	8bce                	mv	s7,s3
      state = 0;
 d96:	4981                	li	s3,0
 d98:	bbd9                	j	b6e <vprintf+0x4a>
          s = "(null)";
 d9a:	00001917          	auipc	s2,0x1
 d9e:	56690913          	addi	s2,s2,1382 # 2300 <malloc+0x145a>
        for(; *s; s++)
 da2:	02800593          	li	a1,40
 da6:	b7c5                	j	d86 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 da8:	8bce                	mv	s7,s3
      state = 0;
 daa:	4981                	li	s3,0
 dac:	b3c9                	j	b6e <vprintf+0x4a>
 dae:	64a6                	ld	s1,72(sp)
 db0:	79e2                	ld	s3,56(sp)
 db2:	7a42                	ld	s4,48(sp)
 db4:	7aa2                	ld	s5,40(sp)
 db6:	7b02                	ld	s6,32(sp)
 db8:	6be2                	ld	s7,24(sp)
 dba:	6c42                	ld	s8,16(sp)
 dbc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 dbe:	60e6                	ld	ra,88(sp)
 dc0:	6446                	ld	s0,80(sp)
 dc2:	6906                	ld	s2,64(sp)
 dc4:	6125                	addi	sp,sp,96
 dc6:	8082                	ret

0000000000000dc8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 dc8:	715d                	addi	sp,sp,-80
 dca:	ec06                	sd	ra,24(sp)
 dcc:	e822                	sd	s0,16(sp)
 dce:	1000                	addi	s0,sp,32
 dd0:	e010                	sd	a2,0(s0)
 dd2:	e414                	sd	a3,8(s0)
 dd4:	e818                	sd	a4,16(s0)
 dd6:	ec1c                	sd	a5,24(s0)
 dd8:	03043023          	sd	a6,32(s0)
 ddc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 de0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 de4:	8622                	mv	a2,s0
 de6:	d3fff0ef          	jal	b24 <vprintf>
}
 dea:	60e2                	ld	ra,24(sp)
 dec:	6442                	ld	s0,16(sp)
 dee:	6161                	addi	sp,sp,80
 df0:	8082                	ret

0000000000000df2 <printf>:

void
printf(const char *fmt, ...)
{
 df2:	711d                	addi	sp,sp,-96
 df4:	ec06                	sd	ra,24(sp)
 df6:	e822                	sd	s0,16(sp)
 df8:	1000                	addi	s0,sp,32
 dfa:	e40c                	sd	a1,8(s0)
 dfc:	e810                	sd	a2,16(s0)
 dfe:	ec14                	sd	a3,24(s0)
 e00:	f018                	sd	a4,32(s0)
 e02:	f41c                	sd	a5,40(s0)
 e04:	03043823          	sd	a6,48(s0)
 e08:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e0c:	00840613          	addi	a2,s0,8
 e10:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e14:	85aa                	mv	a1,a0
 e16:	4505                	li	a0,1
 e18:	d0dff0ef          	jal	b24 <vprintf>
}
 e1c:	60e2                	ld	ra,24(sp)
 e1e:	6442                	ld	s0,16(sp)
 e20:	6125                	addi	sp,sp,96
 e22:	8082                	ret

0000000000000e24 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e24:	1141                	addi	sp,sp,-16
 e26:	e422                	sd	s0,8(sp)
 e28:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e2a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e2e:	00002797          	auipc	a5,0x2
 e32:	1e27b783          	ld	a5,482(a5) # 3010 <freep>
 e36:	a02d                	j	e60 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e38:	4618                	lw	a4,8(a2)
 e3a:	9f2d                	addw	a4,a4,a1
 e3c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e40:	6398                	ld	a4,0(a5)
 e42:	6310                	ld	a2,0(a4)
 e44:	a83d                	j	e82 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e46:	ff852703          	lw	a4,-8(a0)
 e4a:	9f31                	addw	a4,a4,a2
 e4c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 e4e:	ff053683          	ld	a3,-16(a0)
 e52:	a091                	j	e96 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e54:	6398                	ld	a4,0(a5)
 e56:	00e7e463          	bltu	a5,a4,e5e <free+0x3a>
 e5a:	00e6ea63          	bltu	a3,a4,e6e <free+0x4a>
{
 e5e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e60:	fed7fae3          	bgeu	a5,a3,e54 <free+0x30>
 e64:	6398                	ld	a4,0(a5)
 e66:	00e6e463          	bltu	a3,a4,e6e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e6a:	fee7eae3          	bltu	a5,a4,e5e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 e6e:	ff852583          	lw	a1,-8(a0)
 e72:	6390                	ld	a2,0(a5)
 e74:	02059813          	slli	a6,a1,0x20
 e78:	01c85713          	srli	a4,a6,0x1c
 e7c:	9736                	add	a4,a4,a3
 e7e:	fae60de3          	beq	a2,a4,e38 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 e82:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e86:	4790                	lw	a2,8(a5)
 e88:	02061593          	slli	a1,a2,0x20
 e8c:	01c5d713          	srli	a4,a1,0x1c
 e90:	973e                	add	a4,a4,a5
 e92:	fae68ae3          	beq	a3,a4,e46 <free+0x22>
    p->s.ptr = bp->s.ptr;
 e96:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 e98:	00002717          	auipc	a4,0x2
 e9c:	16f73c23          	sd	a5,376(a4) # 3010 <freep>
}
 ea0:	6422                	ld	s0,8(sp)
 ea2:	0141                	addi	sp,sp,16
 ea4:	8082                	ret

0000000000000ea6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ea6:	7139                	addi	sp,sp,-64
 ea8:	fc06                	sd	ra,56(sp)
 eaa:	f822                	sd	s0,48(sp)
 eac:	f426                	sd	s1,40(sp)
 eae:	ec4e                	sd	s3,24(sp)
 eb0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 eb2:	02051493          	slli	s1,a0,0x20
 eb6:	9081                	srli	s1,s1,0x20
 eb8:	04bd                	addi	s1,s1,15
 eba:	8091                	srli	s1,s1,0x4
 ebc:	0014899b          	addiw	s3,s1,1
 ec0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ec2:	00002517          	auipc	a0,0x2
 ec6:	14e53503          	ld	a0,334(a0) # 3010 <freep>
 eca:	c915                	beqz	a0,efe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ecc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ece:	4798                	lw	a4,8(a5)
 ed0:	08977a63          	bgeu	a4,s1,f64 <malloc+0xbe>
 ed4:	f04a                	sd	s2,32(sp)
 ed6:	e852                	sd	s4,16(sp)
 ed8:	e456                	sd	s5,8(sp)
 eda:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 edc:	8a4e                	mv	s4,s3
 ede:	0009871b          	sext.w	a4,s3
 ee2:	6685                	lui	a3,0x1
 ee4:	00d77363          	bgeu	a4,a3,eea <malloc+0x44>
 ee8:	6a05                	lui	s4,0x1
 eea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 eee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ef2:	00002917          	auipc	s2,0x2
 ef6:	11e90913          	addi	s2,s2,286 # 3010 <freep>
  if(p == SBRK_ERROR)
 efa:	5afd                	li	s5,-1
 efc:	a081                	j	f3c <malloc+0x96>
 efe:	f04a                	sd	s2,32(sp)
 f00:	e852                	sd	s4,16(sp)
 f02:	e456                	sd	s5,8(sp)
 f04:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 f06:	00002797          	auipc	a5,0x2
 f0a:	11a78793          	addi	a5,a5,282 # 3020 <base>
 f0e:	00002717          	auipc	a4,0x2
 f12:	10f73123          	sd	a5,258(a4) # 3010 <freep>
 f16:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f18:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f1c:	b7c1                	j	edc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 f1e:	6398                	ld	a4,0(a5)
 f20:	e118                	sd	a4,0(a0)
 f22:	a8a9                	j	f7c <malloc+0xd6>
  hp->s.size = nu;
 f24:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f28:	0541                	addi	a0,a0,16
 f2a:	efbff0ef          	jal	e24 <free>
  return freep;
 f2e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f32:	c12d                	beqz	a0,f94 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f34:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f36:	4798                	lw	a4,8(a5)
 f38:	02977263          	bgeu	a4,s1,f5c <malloc+0xb6>
    if(p == freep)
 f3c:	00093703          	ld	a4,0(s2)
 f40:	853e                	mv	a0,a5
 f42:	fef719e3          	bne	a4,a5,f34 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 f46:	8552                	mv	a0,s4
 f48:	a3fff0ef          	jal	986 <sbrk>
  if(p == SBRK_ERROR)
 f4c:	fd551ce3          	bne	a0,s5,f24 <malloc+0x7e>
        return 0;
 f50:	4501                	li	a0,0
 f52:	7902                	ld	s2,32(sp)
 f54:	6a42                	ld	s4,16(sp)
 f56:	6aa2                	ld	s5,8(sp)
 f58:	6b02                	ld	s6,0(sp)
 f5a:	a03d                	j	f88 <malloc+0xe2>
 f5c:	7902                	ld	s2,32(sp)
 f5e:	6a42                	ld	s4,16(sp)
 f60:	6aa2                	ld	s5,8(sp)
 f62:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 f64:	fae48de3          	beq	s1,a4,f1e <malloc+0x78>
        p->s.size -= nunits;
 f68:	4137073b          	subw	a4,a4,s3
 f6c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f6e:	02071693          	slli	a3,a4,0x20
 f72:	01c6d713          	srli	a4,a3,0x1c
 f76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f7c:	00002717          	auipc	a4,0x2
 f80:	08a73a23          	sd	a0,148(a4) # 3010 <freep>
      return (void*)(p + 1);
 f84:	01078513          	addi	a0,a5,16
  }
}
 f88:	70e2                	ld	ra,56(sp)
 f8a:	7442                	ld	s0,48(sp)
 f8c:	74a2                	ld	s1,40(sp)
 f8e:	69e2                	ld	s3,24(sp)
 f90:	6121                	addi	sp,sp,64
 f92:	8082                	ret
 f94:	7902                	ld	s2,32(sp)
 f96:	6a42                	ld	s4,16(sp)
 f98:	6aa2                	ld	s5,8(sp)
 f9a:	6b02                	ld	s6,0(sp)
 f9c:	b7f5                	j	f88 <malloc+0xe2>
