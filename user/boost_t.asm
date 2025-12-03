
user/_boost_t:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_work>:

// Time quanta for each queue (must match kernel/proc.c)
// These define how many ticks a process runs before demotion
int time_quanta[4] = {2, 4, 8, 16};

void cpu_work(int iterations) {
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	1000                	addi	s0,sp,32
  volatile int dummy = 0;
       8:	fe042623          	sw	zero,-20(s0)
  for(long j = 0; j < iterations; j++) {
       c:	04a05263          	blez	a0,50 <cpu_work+0x50>
      10:	4681                	li	a3,0
    dummy = dummy + j;
    dummy = dummy % 1000000;
      12:	431be837          	lui	a6,0x431be
      16:	e8380813          	addi	a6,a6,-381 # 431bde83 <base+0x431bae63>
      1a:	000f45b7          	lui	a1,0xf4
      1e:	2405859b          	addiw	a1,a1,576 # f4240 <base+0xf1220>
    dummy = dummy + j;
      22:	fec42783          	lw	a5,-20(s0)
      26:	9fb5                	addw	a5,a5,a3
      28:	fef42623          	sw	a5,-20(s0)
    dummy = dummy % 1000000;
      2c:	fec42783          	lw	a5,-20(s0)
      30:	0007871b          	sext.w	a4,a5
      34:	030787b3          	mul	a5,a5,a6
      38:	97c9                	srai	a5,a5,0x32
      3a:	41f7561b          	sraiw	a2,a4,0x1f
      3e:	9f91                	subw	a5,a5,a2
      40:	02f587bb          	mulw	a5,a1,a5
      44:	9f1d                	subw	a4,a4,a5
      46:	fee42623          	sw	a4,-20(s0)
  for(long j = 0; j < iterations; j++) {
      4a:	0685                	addi	a3,a3,1
      4c:	fca69be3          	bne	a3,a0,22 <cpu_work+0x22>
  }
}
      50:	60e2                	ld	ra,24(sp)
      52:	6442                	ld	s0,16(sp)
      54:	6105                	addi	sp,sp,32
      56:	8082                	ret

0000000000000058 <print_status>:

void print_status(char *label, struct procinfo *info, int tick) {
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
      60:	86ae                	mv	a3,a1
      62:	85b2                	mv	a1,a2
  printf("  [Tick %d] %s: PID=%d, Queue=Q%d, Slices=%d/%d\n",
      64:	4698                	lw	a4,8(a3)
      66:	00271613          	slli	a2,a4,0x2
      6a:	00003797          	auipc	a5,0x3
      6e:	f9678793          	addi	a5,a5,-106 # 3000 <time_quanta>
      72:	97b2                	add	a5,a5,a2
      74:	0007a803          	lw	a6,0(a5)
      78:	46dc                	lw	a5,12(a3)
      7a:	4294                	lw	a3,0(a3)
      7c:	862a                	mv	a2,a0
      7e:	00001517          	auipc	a0,0x1
      82:	fb250513          	addi	a0,a0,-78 # 1030 <malloc+0xfe>
      86:	5f5000ef          	jal	e7a <printf>
         tick, label, info->pid, info->priority, info->time_slices,
         time_quanta[info->priority]);
}
      8a:	60a2                	ld	ra,8(sp)
      8c:	6402                	ld	s0,0(sp)
      8e:	0141                	addi	sp,sp,16
      90:	8082                	ret

0000000000000092 <print_time_quanta_info>:

void print_time_quanta_info(void) {
      92:	1101                	addi	sp,sp,-32
      94:	ec06                	sd	ra,24(sp)
      96:	e822                	sd	s0,16(sp)
      98:	e426                	sd	s1,8(sp)
      9a:	1000                	addi	s0,sp,32
  printf("  ┌─────────────────────────────────────────────────────┐\n");
      9c:	00001517          	auipc	a0,0x1
      a0:	fcc50513          	addi	a0,a0,-52 # 1068 <malloc+0x136>
      a4:	5d7000ef          	jal	e7a <printf>
  printf("  │ Queue │ Time Quantum │ Meaning                      │\n");
      a8:	00001517          	auipc	a0,0x1
      ac:	07050513          	addi	a0,a0,112 # 1118 <malloc+0x1e6>
      b0:	5cb000ef          	jal	e7a <printf>
  printf("  ├─────────────────────────────────────────────────────┤\n");
      b4:	00001517          	auipc	a0,0x1
      b8:	0ac50513          	addi	a0,a0,172 # 1160 <malloc+0x22e>
      bc:	5bf000ef          	jal	e7a <printf>
  printf("  │  Q0   │   %d ticks    │ Highest priority, shortest   │\n", time_quanta[0]);
      c0:	00003497          	auipc	s1,0x3
      c4:	f4048493          	addi	s1,s1,-192 # 3000 <time_quanta>
      c8:	408c                	lw	a1,0(s1)
      ca:	00001517          	auipc	a0,0x1
      ce:	14650513          	addi	a0,a0,326 # 1210 <malloc+0x2de>
      d2:	5a9000ef          	jal	e7a <printf>
  printf("  │  Q1   │   %d ticks    │                              │\n", time_quanta[1]);
      d6:	40cc                	lw	a1,4(s1)
      d8:	00001517          	auipc	a0,0x1
      dc:	18050513          	addi	a0,a0,384 # 1258 <malloc+0x326>
      e0:	59b000ef          	jal	e7a <printf>
  printf("  │  Q2   │   %d ticks    │                              │\n", time_quanta[2]);
      e4:	448c                	lw	a1,8(s1)
      e6:	00001517          	auipc	a0,0x1
      ea:	1ba50513          	addi	a0,a0,442 # 12a0 <malloc+0x36e>
      ee:	58d000ef          	jal	e7a <printf>
  printf("  │  Q3   │   %d ticks   │ Lowest priority, longest     │\n", time_quanta[3]);
      f2:	44cc                	lw	a1,12(s1)
      f4:	00001517          	auipc	a0,0x1
      f8:	1f450513          	addi	a0,a0,500 # 12e8 <malloc+0x3b6>
      fc:	57f000ef          	jal	e7a <printf>
  printf("  └─────────────────────────────────────────────────────┘\n");
     100:	00001517          	auipc	a0,0x1
     104:	23050513          	addi	a0,a0,560 # 1330 <malloc+0x3fe>
     108:	573000ef          	jal	e7a <printf>
  printf("  Note: 1 tick ~ 100ms. Process demotes when slices >= quantum.\n\n");
     10c:	00001517          	auipc	a0,0x1
     110:	2d450513          	addi	a0,a0,724 # 13e0 <malloc+0x4ae>
     114:	567000ef          	jal	e7a <printf>
}
     118:	60e2                	ld	ra,24(sp)
     11a:	6442                	ld	s0,16(sp)
     11c:	64a2                	ld	s1,8(sp)
     11e:	6105                	addi	sp,sp,32
     120:	8082                	ret

0000000000000122 <main>:

int
main(int argc, char *argv[])
{
     122:	7135                	addi	sp,sp,-160
     124:	ed06                	sd	ra,152(sp)
     126:	e922                	sd	s0,144(sp)
     128:	e526                	sd	s1,136(sp)
     12a:	e14a                	sd	s2,128(sp)
     12c:	fcce                	sd	s3,120(sp)
     12e:	f8d2                	sd	s4,112(sp)
     130:	f4d6                	sd	s5,104(sp)
     132:	f0da                	sd	s6,96(sp)
     134:	ecde                	sd	s7,88(sp)
     136:	e8e2                	sd	s8,80(sp)
     138:	e4e6                	sd	s9,72(sp)
     13a:	e0ea                	sd	s10,64(sp)
     13c:	fc6e                	sd	s11,56(sp)
     13e:	1100                	addi	s0,sp,160
  struct procinfo info;
  int start_tick, current_tick;
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
  int test_passed = 1;
  
  printf("╔══════════════════════════════════════════════════════════╗\n");
     140:	00001517          	auipc	a0,0x1
     144:	31850513          	addi	a0,a0,792 # 1458 <malloc+0x526>
     148:	533000ef          	jal	e7a <printf>
  printf("║     MLFQ BOOST TEST - Demotion & Promotion Cycles        ║\n");
     14c:	00001517          	auipc	a0,0x1
     150:	3c450513          	addi	a0,a0,964 # 1510 <malloc+0x5de>
     154:	527000ef          	jal	e7a <printf>
  printf("╚══════════════════════════════════════════════════════════╝\n\n");
     158:	00001517          	auipc	a0,0x1
     15c:	40050513          	addi	a0,a0,1024 # 1558 <malloc+0x626>
     160:	51b000ef          	jal	e7a <printf>
  
  start_tick = uptime();
     164:	159000ef          	jal	abc <uptime>
     168:	8c2a                	mv	s8,a0
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 1: Verify Initial Priority
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 1: Initial Priority Check ─────────────────────────┐\n");
     16a:	00001517          	auipc	a0,0x1
     16e:	4a650513          	addi	a0,a0,1190 # 1610 <malloc+0x6de>
     172:	509000ef          	jal	e7a <printf>
  
  if(getprocinfo(&info) == 0) {
     176:	f8040513          	addi	a0,s0,-128
     17a:	14b000ef          	jal	ac4 <getprocinfo>
     17e:	f6a43423          	sd	a0,-152(s0)
     182:	cd3d                	beqz	a0,200 <main+0xde>
  int test_passed = 1;
     184:	4785                	li	a5,1
     186:	f6f43423          	sd	a5,-152(s0)
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
     18a:	f6043023          	sd	zero,-160(s0)
    } else {
      printf("  ✗ FAIL: Expected Q0, got Q%d\n", initial_priority);
      test_passed = 0;
    }
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
     18e:	00001517          	auipc	a0,0x1
     192:	56a50513          	addi	a0,a0,1386 # 16f8 <malloc+0x7c6>
     196:	4e5000ef          	jal	e7a <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 2: Demotion through CPU-bound work
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 2: Demotion Test (CPU-bound work) ─────────────────┐\n");
     19a:	00001517          	auipc	a0,0x1
     19e:	61e50513          	addi	a0,a0,1566 # 17b8 <malloc+0x886>
     1a2:	4d9000ef          	jal	e7a <printf>
  printf("  Running CPU-intensive work to trigger demotion...\n\n");
     1a6:	00001517          	auipc	a0,0x1
     1aa:	67a50513          	addi	a0,a0,1658 # 1820 <malloc+0x8ee>
     1ae:	4cd000ef          	jal	e7a <printf>
  print_time_quanta_info();
     1b2:	ee1ff0ef          	jal	92 <print_time_quanta_info>
  
  int last_priority = 0;
  int last_slices = 0;
  int demotion_ticks[4] = {0, 0, 0, 0};  // Track exact tick of each demotion
     1b6:	f6042a23          	sw	zero,-140(s0)
     1ba:	f6042c23          	sw	zero,-136(s0)
     1be:	f6042e23          	sw	zero,-132(s0)
  
  printf("  Monitoring slices and demotions:\n");
     1c2:	00001517          	auipc	a0,0x1
     1c6:	69650513          	addi	a0,a0,1686 # 1858 <malloc+0x926>
     1ca:	4b1000ef          	jal	e7a <printf>
  printf("  ─────────────────────────────────────────────────────────\n");
     1ce:	00001517          	auipc	a0,0x1
     1d2:	6b250513          	addi	a0,a0,1714 # 1880 <malloc+0x94e>
     1d6:	4a5000ef          	jal	e7a <printf>
     1da:	06400913          	li	s2,100
  
  // Run until we reach Q3 or max 80 phases
  // Q0(2) + Q1(4) + Q2(8) = 14 ticks to reach Q3
  // Continue a bit in Q3 to show it's working
  int reached_q3 = 0;
  int q3_slices_shown = 0;
     1de:	4c81                	li	s9,0
  int last_slices = 0;
     1e0:	4b01                	li	s6,0
  int last_priority = 0;
     1e2:	4981                	li	s3,0
  
  for(int phase = 0; phase < 100; phase++) {
    // Small work unit to get finer granularity
    cpu_work(WORK_ITERATIONS / 4);
     1e4:	00131a37          	lui	s4,0x131
     1e8:	2d0a0a13          	addi	s4,s4,720 # 1312d0 <base+0x12e2b0>
    
    if(getprocinfo(&info) == 0) {
     1ec:	f8040a93          	addi	s5,s0,-128
      current_tick = uptime() - start_tick;
      
      // Track when we reach Q3
      if(info.priority == 3 && !reached_q3) {
     1f0:	4b8d                	li	s7,3
          reached_q3 = 0;
          q3_slices_shown = 0;
        }
        // Just slice increment
        else if(info.time_slices > last_slices) {
          printf("    TICK %d: Q%d slices %d->%d (need %d for demotion)\n",
     1f2:	00003d17          	auipc	s10,0x3
     1f6:	e0ed0d13          	addi	s10,s10,-498 # 3000 <time_quanta>
          demotion_ticks[info.priority] = current_tick;
     1fa:	f7040d93          	addi	s11,s0,-144
     1fe:	a289                	j	340 <main+0x21e>
    initial_priority = info.priority;
     200:	f8842783          	lw	a5,-120(s0)
     204:	84be                	mv	s1,a5
     206:	f6f43023          	sd	a5,-160(s0)
    print_status("Initial", &info, uptime() - start_tick);
     20a:	0b3000ef          	jal	abc <uptime>
     20e:	4185063b          	subw	a2,a0,s8
     212:	f8040593          	addi	a1,s0,-128
     216:	00001517          	auipc	a0,0x1
     21a:	47250513          	addi	a0,a0,1138 # 1688 <malloc+0x756>
     21e:	e3bff0ef          	jal	58 <print_status>
    if(initial_priority == 0) {
     222:	e899                	bnez	s1,238 <main+0x116>
      printf("  ✓ PASS: New process starts at highest priority (Q0)\n");
     224:	00001517          	auipc	a0,0x1
     228:	46c50513          	addi	a0,a0,1132 # 1690 <malloc+0x75e>
     22c:	44f000ef          	jal	e7a <printf>
  int test_passed = 1;
     230:	4785                	li	a5,1
     232:	f6f43423          	sd	a5,-152(s0)
     236:	bfa1                	j	18e <main+0x6c>
      printf("  ✗ FAIL: Expected Q0, got Q%d\n", initial_priority);
     238:	f6043583          	ld	a1,-160(s0)
     23c:	00001517          	auipc	a0,0x1
     240:	49450513          	addi	a0,a0,1172 # 16d0 <malloc+0x79e>
     244:	437000ef          	jal	e7a <printf>
      test_passed = 0;
     248:	b799                	j	18e <main+0x6c>
      if(reached_q3 && info.priority == 3 && q3_slices_shown >= 4) {
     24a:	119bd963          	bge	s7,s9,35c <main+0x23a>
        last_priority = info.priority;
      }
    }
  }
  
  printf("  ─────────────────────────────────────────────────────────\n");
     24e:	00001517          	auipc	a0,0x1
     252:	63250513          	addi	a0,a0,1586 # 1880 <malloc+0x94e>
     256:	425000ef          	jal	e7a <printf>
  
  if(getprocinfo(&info) == 0) {
     25a:	f8040513          	addi	a0,s0,-128
     25e:	067000ef          	jal	ac4 <getprocinfo>
     262:	84aa                	mv	s1,a0
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
     264:	4b81                	li	s7,0
  if(getprocinfo(&info) == 0) {
     266:	14050e63          	beqz	a0,3c2 <main+0x2a0>
    } else {
      printf("\n  ✗ FAIL: Process not demoted (still at Q%d)\n", demoted_priority);
      test_passed = 0;
    }
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
     26a:	00001517          	auipc	a0,0x1
     26e:	48e50513          	addi	a0,a0,1166 # 16f8 <malloc+0x7c6>
     272:	409000ef          	jal	e7a <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 3: Manual Boost via boostproc()
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 3: Manual Boost (boostproc syscall) ───────────────┐\n");
     276:	00002517          	auipc	a0,0x2
     27a:	8ca50513          	addi	a0,a0,-1846 # 1b40 <malloc+0xc0e>
     27e:	3fd000ef          	jal	e7a <printf>
  
  if(getprocinfo(&info) == 0) {
     282:	f8040513          	addi	a0,s0,-128
     286:	03f000ef          	jal	ac4 <getprocinfo>
     28a:	1e050363          	beqz	a0,470 <main+0x34e>
    print_status("Before boost", &info, uptime() - start_tick);
  }
  
  printf("  Calling boostproc()...\n");
     28e:	00002517          	auipc	a0,0x2
     292:	92a50513          	addi	a0,a0,-1750 # 1bb8 <malloc+0xc86>
     296:	3e5000ef          	jal	e7a <printf>
  int before_boost_tick = uptime() - start_tick;
     29a:	023000ef          	jal	abc <uptime>
     29e:	89aa                	mv	s3,a0
  boostproc();
     2a0:	02d000ef          	jal	acc <boostproc>
  int after_boost_tick = uptime() - start_tick;
     2a4:	019000ef          	jal	abc <uptime>
     2a8:	892a                	mv	s2,a0
  
  if(getprocinfo(&info) == 0) {
     2aa:	f8040513          	addi	a0,s0,-128
     2ae:	017000ef          	jal	ac4 <getprocinfo>
     2b2:	84aa                	mv	s1,a0
  int initial_priority = 0, demoted_priority = 0, boosted_priority = 0;
     2b4:	4d01                	li	s10,0
  if(getprocinfo(&info) == 0) {
     2b6:	1c050a63          	beqz	a0,48a <main+0x368>
      printf("  ✗ FAIL: Boost incomplete (Q%d, slices=%d)\n", 
             boosted_priority, info.time_slices);
      test_passed = 0;
    }
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
     2ba:	00001517          	auipc	a0,0x1
     2be:	43e50513          	addi	a0,a0,1086 # 16f8 <malloc+0x7c6>
     2c2:	3b9000ef          	jal	e7a <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 4: Re-demotion after boost
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 4: Re-demotion After Boost ────────────────────────┐\n");
     2c6:	00002517          	auipc	a0,0x2
     2ca:	9ba50513          	addi	a0,a0,-1606 # 1c80 <malloc+0xd4e>
     2ce:	3ad000ef          	jal	e7a <printf>
  printf("  Verifying demotion still works after manual boost...\n");
     2d2:	00002517          	auipc	a0,0x2
     2d6:	a2650513          	addi	a0,a0,-1498 # 1cf8 <malloc+0xdc6>
     2da:	3a1000ef          	jal	e7a <printf>
  printf("  (Note: Auto-boost may interfere if BOOST_INTERVAL is short)\n\n");
     2de:	00002517          	auipc	a0,0x2
     2e2:	a5250513          	addi	a0,a0,-1454 # 1d30 <malloc+0xdfe>
     2e6:	395000ef          	jal	e7a <printf>
     2ea:	44e5                	li	s1,25
  
  last_priority = 0;
  last_slices = 0;
  int demotion_seen = 0;
     2ec:	4d81                	li	s11,0
  last_priority = 0;
     2ee:	4a01                	li	s4,0
  
  for(int phase = 0; phase < 25; phase++) {
    cpu_work(WORK_ITERATIONS / 4);
     2f0:	00131937          	lui	s2,0x131
     2f4:	2d090913          	addi	s2,s2,720 # 1312d0 <base+0x12e2b0>
    
    if(getprocinfo(&info) == 0) {
     2f8:	f8040993          	addi	s3,s0,-128
        if(info.priority > last_priority) {
          printf("  > TICK %d: DEMOTED Q%d->Q%d\n",
                 current_tick, last_priority, info.priority);
          demotion_seen = 1;
        } else {
          printf("  < TICK %d: AUTO BOOST Q%d->Q%d\n",
     2fc:	00002b17          	auipc	s6,0x2
     300:	a94b0b13          	addi	s6,s6,-1388 # 1d90 <malloc+0xe5e>
          printf("  > TICK %d: DEMOTED Q%d->Q%d\n",
     304:	00002a97          	auipc	s5,0x2
     308:	a6ca8a93          	addi	s5,s5,-1428 # 1d70 <malloc+0xe3e>
          demotion_seen = 1;
     30c:	4c85                	li	s9,1
     30e:	a2ed                	j	4f8 <main+0x3d6>
          demotion_ticks[info.priority] = current_tick;
     310:	00261793          	slli	a5,a2,0x2
     314:	97ee                	add	a5,a5,s11
     316:	c38c                	sw	a1,0(a5)
          printf("  > TICK %d: DEMOTED Q%d->Q%d (used %d/%d slices)\n",
     318:	00299793          	slli	a5,s3,0x2
     31c:	97ea                	add	a5,a5,s10
     31e:	4398                	lw	a4,0(a5)
     320:	87ba                	mv	a5,a4
     322:	86b2                	mv	a3,a2
     324:	864e                	mv	a2,s3
     326:	00001517          	auipc	a0,0x1
     32a:	60a50513          	addi	a0,a0,1546 # 1930 <malloc+0x9fe>
     32e:	34d000ef          	jal	e7a <printf>
        last_slices = info.time_slices;
     332:	f8c42b03          	lw	s6,-116(s0)
        last_priority = info.priority;
     336:	f8842983          	lw	s3,-120(s0)
  for(int phase = 0; phase < 100; phase++) {
     33a:	397d                	addiw	s2,s2,-1
     33c:	f00909e3          	beqz	s2,24e <main+0x12c>
    cpu_work(WORK_ITERATIONS / 4);
     340:	8552                	mv	a0,s4
     342:	cbfff0ef          	jal	0 <cpu_work>
    if(getprocinfo(&info) == 0) {
     346:	8556                	mv	a0,s5
     348:	77c000ef          	jal	ac4 <getprocinfo>
     34c:	84aa                	mv	s1,a0
     34e:	f575                	bnez	a0,33a <main+0x218>
      current_tick = uptime() - start_tick;
     350:	76c000ef          	jal	abc <uptime>
      if(info.priority == 3 && !reached_q3) {
     354:	f8842603          	lw	a2,-120(s0)
     358:	ef7609e3          	beq	a2,s7,24a <main+0x128>
      if(info.time_slices != last_slices || info.priority != last_priority) {
     35c:	f8c42703          	lw	a4,-116(s0)
     360:	01361463          	bne	a2,s3,368 <main+0x246>
     364:	fd670be3          	beq	a4,s6,33a <main+0x218>
      current_tick = uptime() - start_tick;
     368:	418505bb          	subw	a1,a0,s8
        if(info.priority > last_priority) {
     36c:	fac9c2e3          	blt	s3,a2,310 <main+0x1ee>
        else if(info.priority < last_priority) {
     370:	01364e63          	blt	a2,s3,38c <main+0x26a>
        else if(info.time_slices > last_slices) {
     374:	02eb4663          	blt	s6,a4,3a0 <main+0x27e>
        else if(info.time_slices < last_slices && info.priority == last_priority) {
     378:	fb675de3          	bge	a4,s6,332 <main+0x210>
          printf("    TICK %d: Q%d slices reset to %d\n",
     37c:	86ba                	mv	a3,a4
     37e:	00001517          	auipc	a0,0x1
     382:	65250513          	addi	a0,a0,1618 # 19d0 <malloc+0xa9e>
     386:	2f5000ef          	jal	e7a <printf>
     38a:	b765                	j	332 <main+0x210>
          printf("  < TICK %d: BOOSTED Q%d->Q%d (auto boost)\n",
     38c:	86b2                	mv	a3,a2
     38e:	864e                	mv	a2,s3
     390:	00001517          	auipc	a0,0x1
     394:	5d850513          	addi	a0,a0,1496 # 1968 <malloc+0xa36>
     398:	2e3000ef          	jal	e7a <printf>
          q3_slices_shown = 0;
     39c:	8ca6                	mv	s9,s1
     39e:	bf51                	j	332 <main+0x210>
          printf("    TICK %d: Q%d slices %d->%d (need %d for demotion)\n",
     3a0:	00261793          	slli	a5,a2,0x2
     3a4:	97ea                	add	a5,a5,s10
     3a6:	439c                	lw	a5,0(a5)
     3a8:	86da                	mv	a3,s6
     3aa:	00001517          	auipc	a0,0x1
     3ae:	5ee50513          	addi	a0,a0,1518 # 1998 <malloc+0xa66>
     3b2:	2c9000ef          	jal	e7a <printf>
          if(info.priority == 3) {
     3b6:	f8842783          	lw	a5,-120(s0)
     3ba:	f7779ce3          	bne	a5,s7,332 <main+0x210>
            q3_slices_shown++;
     3be:	2c85                	addiw	s9,s9,1
     3c0:	bf8d                	j	332 <main+0x210>
    demoted_priority = info.priority;
     3c2:	f8842b83          	lw	s7,-120(s0)
    print_status("After work", &info, uptime() - start_tick);
     3c6:	6f6000ef          	jal	abc <uptime>
     3ca:	4185063b          	subw	a2,a0,s8
     3ce:	f8040593          	addi	a1,s0,-128
     3d2:	00001517          	auipc	a0,0x1
     3d6:	62650513          	addi	a0,a0,1574 # 19f8 <malloc+0xac6>
     3da:	c7fff0ef          	jal	58 <print_status>
    printf("\n  Demotion Summary:\n");
     3de:	00001517          	auipc	a0,0x1
     3e2:	62a50513          	addi	a0,a0,1578 # 1a08 <malloc+0xad6>
     3e6:	295000ef          	jal	e7a <printf>
    if(demotion_ticks[1] > 0)
     3ea:	f7442583          	lw	a1,-140(s0)
     3ee:	02b04663          	bgtz	a1,41a <main+0x2f8>
    if(demotion_ticks[2] > 0)
     3f2:	f7842583          	lw	a1,-136(s0)
     3f6:	02b04d63          	bgtz	a1,430 <main+0x30e>
    if(demotion_ticks[3] > 0)
     3fa:	f7c42583          	lw	a1,-132(s0)
     3fe:	04b04463          	bgtz	a1,446 <main+0x324>
    if(demoted_priority > initial_priority) {
     402:	f6043583          	ld	a1,-160(s0)
     406:	0575db63          	bge	a1,s7,45c <main+0x33a>
      printf("\n  ✓ PASS: Process demoted from Q%d to Q%d\n", 
     40a:	865e                	mv	a2,s7
     40c:	00001517          	auipc	a0,0x1
     410:	6cc50513          	addi	a0,a0,1740 # 1ad8 <malloc+0xba6>
     414:	267000ef          	jal	e7a <printf>
     418:	bd89                	j	26a <main+0x148>
      printf("    Q0->Q1 at tick %d (expected after %d ticks in Q0)\n", 
     41a:	00003617          	auipc	a2,0x3
     41e:	be662603          	lw	a2,-1050(a2) # 3000 <time_quanta>
     422:	00001517          	auipc	a0,0x1
     426:	5fe50513          	addi	a0,a0,1534 # 1a20 <malloc+0xaee>
     42a:	251000ef          	jal	e7a <printf>
     42e:	b7d1                	j	3f2 <main+0x2d0>
      printf("    Q1->Q2 at tick %d (expected after %d more ticks in Q1)\n", 
     430:	00003617          	auipc	a2,0x3
     434:	bd462603          	lw	a2,-1068(a2) # 3004 <time_quanta+0x4>
     438:	00001517          	auipc	a0,0x1
     43c:	62050513          	addi	a0,a0,1568 # 1a58 <malloc+0xb26>
     440:	23b000ef          	jal	e7a <printf>
     444:	bf5d                	j	3fa <main+0x2d8>
      printf("    Q2->Q3 at tick %d (expected after %d more ticks in Q2)\n", 
     446:	00003617          	auipc	a2,0x3
     44a:	bc262603          	lw	a2,-1086(a2) # 3008 <time_quanta+0x8>
     44e:	00001517          	auipc	a0,0x1
     452:	64a50513          	addi	a0,a0,1610 # 1a98 <malloc+0xb66>
     456:	225000ef          	jal	e7a <printf>
     45a:	b765                	j	402 <main+0x2e0>
      printf("\n  ✗ FAIL: Process not demoted (still at Q%d)\n", demoted_priority);
     45c:	85de                	mv	a1,s7
     45e:	00001517          	auipc	a0,0x1
     462:	6aa50513          	addi	a0,a0,1706 # 1b08 <malloc+0xbd6>
     466:	215000ef          	jal	e7a <printf>
      test_passed = 0;
     46a:	f6943423          	sd	s1,-152(s0)
     46e:	bbf5                	j	26a <main+0x148>
    print_status("Before boost", &info, uptime() - start_tick);
     470:	64c000ef          	jal	abc <uptime>
     474:	4185063b          	subw	a2,a0,s8
     478:	f8040593          	addi	a1,s0,-128
     47c:	00001517          	auipc	a0,0x1
     480:	72c50513          	addi	a0,a0,1836 # 1ba8 <malloc+0xc76>
     484:	bd5ff0ef          	jal	58 <print_status>
     488:	b519                	j	28e <main+0x16c>
  int before_boost_tick = uptime() - start_tick;
     48a:	418989bb          	subw	s3,s3,s8
  int after_boost_tick = uptime() - start_tick;
     48e:	4189093b          	subw	s2,s2,s8
    boosted_priority = info.priority;
     492:	f8842a03          	lw	s4,-120(s0)
    print_status("After boost", &info, after_boost_tick);
     496:	864a                	mv	a2,s2
     498:	f8040593          	addi	a1,s0,-128
     49c:	00001517          	auipc	a0,0x1
     4a0:	73c50513          	addi	a0,a0,1852 # 1bd8 <malloc+0xca6>
     4a4:	bb5ff0ef          	jal	58 <print_status>
    printf("  Boost executed between tick %d and %d\n", before_boost_tick, after_boost_tick);
     4a8:	864a                	mv	a2,s2
     4aa:	85ce                	mv	a1,s3
     4ac:	00001517          	auipc	a0,0x1
     4b0:	73c50513          	addi	a0,a0,1852 # 1be8 <malloc+0xcb6>
     4b4:	1c7000ef          	jal	e7a <printf>
    if(boosted_priority == 0 && info.time_slices == 0) {
     4b8:	f8c42603          	lw	a2,-116(s0)
     4bc:	01466d33          	or	s10,a2,s4
     4c0:	000d0d63          	beqz	s10,4da <main+0x3b8>
      printf("  ✗ FAIL: Boost incomplete (Q%d, slices=%d)\n", 
     4c4:	85d2                	mv	a1,s4
     4c6:	00001517          	auipc	a0,0x1
     4ca:	78a50513          	addi	a0,a0,1930 # 1c50 <malloc+0xd1e>
     4ce:	1ad000ef          	jal	e7a <printf>
      test_passed = 0;
     4d2:	f6943423          	sd	s1,-152(s0)
    boosted_priority = info.priority;
     4d6:	8d52                	mv	s10,s4
     4d8:	b3cd                	j	2ba <main+0x198>
      printf("  ✓ PASS: Process boosted to Q0 with slices reset\n");
     4da:	00001517          	auipc	a0,0x1
     4de:	73e50513          	addi	a0,a0,1854 # 1c18 <malloc+0xce6>
     4e2:	199000ef          	jal	e7a <printf>
     4e6:	bbd1                	j	2ba <main+0x198>
          printf("  < TICK %d: AUTO BOOST Q%d->Q%d\n",
     4e8:	8652                	mv	a2,s4
     4ea:	855a                	mv	a0,s6
     4ec:	18f000ef          	jal	e7a <printf>
                 current_tick, last_priority, info.priority);
        }
        last_priority = info.priority;
     4f0:	f8842a03          	lw	s4,-120(s0)
  for(int phase = 0; phase < 25; phase++) {
     4f4:	34fd                	addiw	s1,s1,-1
     4f6:	c885                	beqz	s1,526 <main+0x404>
    cpu_work(WORK_ITERATIONS / 4);
     4f8:	854a                	mv	a0,s2
     4fa:	b07ff0ef          	jal	0 <cpu_work>
    if(getprocinfo(&info) == 0) {
     4fe:	854e                	mv	a0,s3
     500:	5c4000ef          	jal	ac4 <getprocinfo>
     504:	f965                	bnez	a0,4f4 <main+0x3d2>
      current_tick = uptime() - start_tick;
     506:	5b6000ef          	jal	abc <uptime>
      if(info.priority != last_priority) {
     50a:	f8842683          	lw	a3,-120(s0)
     50e:	ff4683e3          	beq	a3,s4,4f4 <main+0x3d2>
      current_tick = uptime() - start_tick;
     512:	418505bb          	subw	a1,a0,s8
        if(info.priority > last_priority) {
     516:	fcda59e3          	bge	s4,a3,4e8 <main+0x3c6>
          printf("  > TICK %d: DEMOTED Q%d->Q%d\n",
     51a:	8652                	mv	a2,s4
     51c:	8556                	mv	a0,s5
     51e:	15d000ef          	jal	e7a <printf>
          demotion_seen = 1;
     522:	8de6                	mv	s11,s9
     524:	b7f1                	j	4f0 <main+0x3ce>
      }
      last_slices = info.time_slices;
    }
  }
  
  if(getprocinfo(&info) == 0) {
     526:	f8040513          	addi	a0,s0,-128
     52a:	59a000ef          	jal	ac4 <getprocinfo>
     52e:	c959                	beqz	a0,5c4 <main+0x4a2>
    } else {
      printf("  ✗ FAIL: No demotions observed\n");
      test_passed = 0;
    }
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
     530:	00001517          	auipc	a0,0x1
     534:	1c850513          	addi	a0,a0,456 # 16f8 <malloc+0x7c6>
     538:	143000ef          	jal	e7a <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // TEST 5: Automatic Periodic Boost
  // ═══════════════════════════════════════════════════════════════
  printf("┌─ TEST 5: Automatic Periodic Boost ───────────────────────┐\n");
     53c:	00002517          	auipc	a0,0x2
     540:	8e450513          	addi	a0,a0,-1820 # 1e20 <malloc+0xeee>
     544:	137000ef          	jal	e7a <printf>
  printf("  Waiting and working until automatic boost triggers...\n");
     548:	00002517          	auipc	a0,0x2
     54c:	95050513          	addi	a0,a0,-1712 # 1e98 <malloc+0xf66>
     550:	12b000ef          	jal	e7a <printf>
  printf("  This tests starvation prevention mechanism.\n\n");
     554:	00002517          	auipc	a0,0x2
     558:	98450513          	addi	a0,a0,-1660 # 1ed8 <malloc+0xfa6>
     55c:	11f000ef          	jal	e7a <printf>
  
  int boost_detected = 0;
  int prev_priority = info.priority;
     560:	f8842c83          	lw	s9,-120(s0)
  int wait_start = uptime();
     564:	558000ef          	jal	abc <uptime>
     568:	89aa                	mv	s3,a0
  int boost_detected = 0;
     56a:	4b01                	li	s6,0
  last_slices = info.time_slices;
  
  while(uptime() - wait_start < 150 && !boost_detected) {
    cpu_work(WORK_ITERATIONS / 4);
     56c:	00131a37          	lui	s4,0x131
     570:	2d0a0a13          	addi	s4,s4,720 # 1312d0 <base+0x12e2b0>
    
    if(getprocinfo(&info) == 0) {
     574:	f8040a93          	addi	s5,s0,-128
  while(uptime() - wait_start < 150 && !boost_detected) {
     578:	001b7913          	andi	s2,s6,1
     57c:	00194913          	xori	s2,s2,1
     580:	53c000ef          	jal	abc <uptime>
     584:	4135053b          	subw	a0,a0,s3
     588:	09652513          	slti	a0,a0,150
     58c:	c959                	beqz	a0,622 <main+0x500>
     58e:	08090a63          	beqz	s2,622 <main+0x500>
    cpu_work(WORK_ITERATIONS / 4);
     592:	8552                	mv	a0,s4
     594:	a6dff0ef          	jal	0 <cpu_work>
    if(getprocinfo(&info) == 0) {
     598:	8556                	mv	a0,s5
     59a:	52a000ef          	jal	ac4 <getprocinfo>
     59e:	84aa                	mv	s1,a0
     5a0:	f165                	bnez	a0,580 <main+0x45e>
      current_tick = uptime() - start_tick;
     5a2:	51a000ef          	jal	abc <uptime>
     5a6:	418505bb          	subw	a1,a0,s8
      
      if(prev_priority > 0 && info.priority == 0) {
     5aa:	01905563          	blez	s9,5b4 <main+0x492>
     5ae:	f8842783          	lw	a5,-120(s0)
     5b2:	c7b9                	beqz	a5,600 <main+0x4de>
        printf("  < TICK %d: AUTO BOOST DETECTED Q%d->Q0\n", 
               current_tick, prev_priority);
        boost_detected = 1;
      } else if(info.priority > prev_priority) {
     5b4:	f8842683          	lw	a3,-120(s0)
     5b8:	04dccd63          	blt	s9,a3,612 <main+0x4f0>
        printf("  > TICK %d: Demotion Q%d->Q%d\n",
               current_tick, prev_priority, info.priority);
      }
      prev_priority = info.priority;
     5bc:	f8842c83          	lw	s9,-120(s0)
     5c0:	8b26                	mv	s6,s1
     5c2:	bf5d                	j	578 <main+0x456>
    print_status("Final", &info, uptime() - start_tick);
     5c4:	4f8000ef          	jal	abc <uptime>
     5c8:	4185063b          	subw	a2,a0,s8
     5cc:	f8040593          	addi	a1,s0,-128
     5d0:	00001517          	auipc	a0,0x1
     5d4:	7e850513          	addi	a0,a0,2024 # 1db8 <malloc+0xe86>
     5d8:	a81ff0ef          	jal	58 <print_status>
    if(demotion_seen) {
     5dc:	000d8963          	beqz	s11,5ee <main+0x4cc>
      printf("  ✓ PASS: Demotion mechanism working after boost\n");
     5e0:	00001517          	auipc	a0,0x1
     5e4:	7e050513          	addi	a0,a0,2016 # 1dc0 <malloc+0xe8e>
     5e8:	093000ef          	jal	e7a <printf>
     5ec:	b791                	j	530 <main+0x40e>
      printf("  ✗ FAIL: No demotions observed\n");
     5ee:	00002517          	auipc	a0,0x2
     5f2:	80a50513          	addi	a0,a0,-2038 # 1df8 <malloc+0xec6>
     5f6:	085000ef          	jal	e7a <printf>
      test_passed = 0;
     5fa:	f7b43423          	sd	s11,-152(s0)
     5fe:	bf0d                	j	530 <main+0x40e>
        printf("  < TICK %d: AUTO BOOST DETECTED Q%d->Q0\n", 
     600:	8666                	mv	a2,s9
     602:	00002517          	auipc	a0,0x2
     606:	90650513          	addi	a0,a0,-1786 # 1f08 <malloc+0xfd6>
     60a:	071000ef          	jal	e7a <printf>
        boost_detected = 1;
     60e:	4485                	li	s1,1
     610:	b775                	j	5bc <main+0x49a>
        printf("  > TICK %d: Demotion Q%d->Q%d\n",
     612:	8666                	mv	a2,s9
     614:	00002517          	auipc	a0,0x2
     618:	92450513          	addi	a0,a0,-1756 # 1f38 <malloc+0x1006>
     61c:	05f000ef          	jal	e7a <printf>
     620:	bf71                	j	5bc <main+0x49a>
      last_slices = info.time_slices;
    }
  }
  
  if(boost_detected) {
     622:	120b0263          	beqz	s6,746 <main+0x624>
    printf("  ✓ PASS: Automatic periodic boost working!\n");
     626:	00002517          	auipc	a0,0x2
     62a:	93250513          	addi	a0,a0,-1742 # 1f58 <malloc+0x1026>
     62e:	04d000ef          	jal	e7a <printf>
  } else {
    printf("  ? INFO: Auto boost not observed in time window\n");
    printf("          (May have been at Q0 when boost occurred)\n");
  }
  printf("└────────────────────────────────────────────────────────────┘\n\n");
     632:	00001517          	auipc	a0,0x1
     636:	0c650513          	addi	a0,a0,198 # 16f8 <malloc+0x7c6>
     63a:	041000ef          	jal	e7a <printf>
  
  // ═══════════════════════════════════════════════════════════════
  // Summary
  // ═══════════════════════════════════════════════════════════════
  printf("╔══════════════════════════════════════════════════════════╗\n");
     63e:	00001517          	auipc	a0,0x1
     642:	e1a50513          	addi	a0,a0,-486 # 1458 <malloc+0x526>
     646:	035000ef          	jal	e7a <printf>
  printf("║                    TEST SUMMARY                          ║\n");
     64a:	00002517          	auipc	a0,0x2
     64e:	9ae50513          	addi	a0,a0,-1618 # 1ff8 <malloc+0x10c6>
     652:	029000ef          	jal	e7a <printf>
  printf("╠══════════════════════════════════════════════════════════╣\n");
     656:	00002517          	auipc	a0,0x2
     65a:	9ea50513          	addi	a0,a0,-1558 # 2040 <malloc+0x110e>
     65e:	01d000ef          	jal	e7a <printf>
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
         uptime() - start_tick, (uptime() - start_tick)/10, (uptime() - start_tick)%10);
     662:	45a000ef          	jal	abc <uptime>
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
     666:	418504bb          	subw	s1,a0,s8
         uptime() - start_tick, (uptime() - start_tick)/10, (uptime() - start_tick)%10);
     66a:	452000ef          	jal	abc <uptime>
     66e:	892a                	mv	s2,a0
     670:	44c000ef          	jal	abc <uptime>
     674:	418506bb          	subw	a3,a0,s8
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
     678:	666667b7          	lui	a5,0x66666
     67c:	66778793          	addi	a5,a5,1639 # 66666667 <base+0x66663647>
     680:	02f68733          	mul	a4,a3,a5
     684:	9709                	srai	a4,a4,0x22
     686:	41f6d61b          	sraiw	a2,a3,0x1f
     68a:	9f11                	subw	a4,a4,a2
     68c:	0027161b          	slliw	a2,a4,0x2
     690:	9f31                	addw	a4,a4,a2
     692:	0017171b          	slliw	a4,a4,0x1
         uptime() - start_tick, (uptime() - start_tick)/10, (uptime() - start_tick)%10);
     696:	4189053b          	subw	a0,s2,s8
  printf("║  Total runtime: %d ticks (~%d.%d seconds)                \n", 
     69a:	02f507b3          	mul	a5,a0,a5
     69e:	9789                	srai	a5,a5,0x22
     6a0:	41f5561b          	sraiw	a2,a0,0x1f
     6a4:	9e99                	subw	a3,a3,a4
     6a6:	40c7863b          	subw	a2,a5,a2
     6aa:	85a6                	mv	a1,s1
     6ac:	00002517          	auipc	a0,0x2
     6b0:	a4c50513          	addi	a0,a0,-1460 # 20f8 <malloc+0x11c6>
     6b4:	7c6000ef          	jal	e7a <printf>
  printf("║  Initial priority: Q%d                                    \n", initial_priority);
     6b8:	f6043583          	ld	a1,-160(s0)
     6bc:	00002517          	auipc	a0,0x2
     6c0:	a7c50513          	addi	a0,a0,-1412 # 2138 <malloc+0x1206>
     6c4:	7b6000ef          	jal	e7a <printf>
  printf("║  Max demotion reached: Q%d                                \n", demoted_priority);
     6c8:	85de                	mv	a1,s7
     6ca:	00002517          	auipc	a0,0x2
     6ce:	aae50513          	addi	a0,a0,-1362 # 2178 <malloc+0x1246>
     6d2:	7a8000ef          	jal	e7a <printf>
  printf("║  Manual boost: %s                                        \n", 
     6d6:	00001597          	auipc	a1,0x1
     6da:	d5a58593          	addi	a1,a1,-678 # 1430 <malloc+0x4fe>
     6de:	000d1663          	bnez	s10,6ea <main+0x5c8>
     6e2:	00001597          	auipc	a1,0x1
     6e6:	d4658593          	addi	a1,a1,-698 # 1428 <malloc+0x4f6>
     6ea:	00002517          	auipc	a0,0x2
     6ee:	ace50513          	addi	a0,a0,-1330 # 21b8 <malloc+0x1286>
     6f2:	788000ef          	jal	e7a <printf>
         boosted_priority == 0 ? "Working" : "Failed");
  printf("║  Auto boost: %s                                          \n",
     6f6:	00001597          	auipc	a1,0x1
     6fa:	d5258593          	addi	a1,a1,-686 # 1448 <malloc+0x516>
     6fe:	000b0663          	beqz	s6,70a <main+0x5e8>
     702:	00001597          	auipc	a1,0x1
     706:	d3658593          	addi	a1,a1,-714 # 1438 <malloc+0x506>
     70a:	00002517          	auipc	a0,0x2
     70e:	aee50513          	addi	a0,a0,-1298 # 21f8 <malloc+0x12c6>
     712:	768000ef          	jal	e7a <printf>
         boost_detected ? "Detected" : "Not observed");
  printf("╠══════════════════════════════════════════════════════════╣\n");
     716:	00002517          	auipc	a0,0x2
     71a:	92a50513          	addi	a0,a0,-1750 # 2040 <malloc+0x110e>
     71e:	75c000ef          	jal	e7a <printf>
  if(test_passed) {
     722:	f6843783          	ld	a5,-152(s0)
     726:	cf8d                	beqz	a5,760 <main+0x63e>
    printf("║  ✓✓✓ ALL CORE TESTS PASSED ✓✓✓                          ║\n");
     728:	00002517          	auipc	a0,0x2
     72c:	b1050513          	addi	a0,a0,-1264 # 2238 <malloc+0x1306>
     730:	74a000ef          	jal	e7a <printf>
  } else {
    printf("║  ✗✗✗ SOME TESTS FAILED ✗✗✗                              ║\n");
  }
  printf("╚══════════════════════════════════════════════════════════╝\n");
     734:	00002517          	auipc	a0,0x2
     738:	ba450513          	addi	a0,a0,-1116 # 22d8 <malloc+0x13a6>
     73c:	73e000ef          	jal	e7a <printf>
  
  exit(0);
     740:	4501                	li	a0,0
     742:	2e2000ef          	jal	a24 <exit>
    printf("  ? INFO: Auto boost not observed in time window\n");
     746:	00002517          	auipc	a0,0x2
     74a:	84250513          	addi	a0,a0,-1982 # 1f88 <malloc+0x1056>
     74e:	72c000ef          	jal	e7a <printf>
    printf("          (May have been at Q0 when boost occurred)\n");
     752:	00002517          	auipc	a0,0x2
     756:	86e50513          	addi	a0,a0,-1938 # 1fc0 <malloc+0x108e>
     75a:	720000ef          	jal	e7a <printf>
     75e:	bdd1                	j	632 <main+0x510>
    printf("║  ✗✗✗ SOME TESTS FAILED ✗✗✗                              ║\n");
     760:	00002517          	auipc	a0,0x2
     764:	b2850513          	addi	a0,a0,-1240 # 2288 <malloc+0x1356>
     768:	712000ef          	jal	e7a <printf>
     76c:	b7e1                	j	734 <main+0x612>

000000000000076e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     76e:	1141                	addi	sp,sp,-16
     770:	e406                	sd	ra,8(sp)
     772:	e022                	sd	s0,0(sp)
     774:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     776:	9adff0ef          	jal	122 <main>
  exit(r);
     77a:	2aa000ef          	jal	a24 <exit>

000000000000077e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     77e:	1141                	addi	sp,sp,-16
     780:	e406                	sd	ra,8(sp)
     782:	e022                	sd	s0,0(sp)
     784:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     786:	87aa                	mv	a5,a0
     788:	0585                	addi	a1,a1,1
     78a:	0785                	addi	a5,a5,1
     78c:	fff5c703          	lbu	a4,-1(a1)
     790:	fee78fa3          	sb	a4,-1(a5)
     794:	fb75                	bnez	a4,788 <strcpy+0xa>
    ;
  return os;
}
     796:	60a2                	ld	ra,8(sp)
     798:	6402                	ld	s0,0(sp)
     79a:	0141                	addi	sp,sp,16
     79c:	8082                	ret

000000000000079e <strcmp>:

int
strcmp(const char *p, const char *q)
{
     79e:	1141                	addi	sp,sp,-16
     7a0:	e406                	sd	ra,8(sp)
     7a2:	e022                	sd	s0,0(sp)
     7a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     7a6:	00054783          	lbu	a5,0(a0)
     7aa:	cb91                	beqz	a5,7be <strcmp+0x20>
     7ac:	0005c703          	lbu	a4,0(a1)
     7b0:	00f71763          	bne	a4,a5,7be <strcmp+0x20>
    p++, q++;
     7b4:	0505                	addi	a0,a0,1
     7b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     7b8:	00054783          	lbu	a5,0(a0)
     7bc:	fbe5                	bnez	a5,7ac <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     7be:	0005c503          	lbu	a0,0(a1)
}
     7c2:	40a7853b          	subw	a0,a5,a0
     7c6:	60a2                	ld	ra,8(sp)
     7c8:	6402                	ld	s0,0(sp)
     7ca:	0141                	addi	sp,sp,16
     7cc:	8082                	ret

00000000000007ce <strlen>:

uint
strlen(const char *s)
{
     7ce:	1141                	addi	sp,sp,-16
     7d0:	e406                	sd	ra,8(sp)
     7d2:	e022                	sd	s0,0(sp)
     7d4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     7d6:	00054783          	lbu	a5,0(a0)
     7da:	cf91                	beqz	a5,7f6 <strlen+0x28>
     7dc:	00150793          	addi	a5,a0,1
     7e0:	86be                	mv	a3,a5
     7e2:	0785                	addi	a5,a5,1
     7e4:	fff7c703          	lbu	a4,-1(a5)
     7e8:	ff65                	bnez	a4,7e0 <strlen+0x12>
     7ea:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     7ee:	60a2                	ld	ra,8(sp)
     7f0:	6402                	ld	s0,0(sp)
     7f2:	0141                	addi	sp,sp,16
     7f4:	8082                	ret
  for(n = 0; s[n]; n++)
     7f6:	4501                	li	a0,0
     7f8:	bfdd                	j	7ee <strlen+0x20>

00000000000007fa <memset>:

void*
memset(void *dst, int c, uint n)
{
     7fa:	1141                	addi	sp,sp,-16
     7fc:	e406                	sd	ra,8(sp)
     7fe:	e022                	sd	s0,0(sp)
     800:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     802:	ca19                	beqz	a2,818 <memset+0x1e>
     804:	87aa                	mv	a5,a0
     806:	1602                	slli	a2,a2,0x20
     808:	9201                	srli	a2,a2,0x20
     80a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     80e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     812:	0785                	addi	a5,a5,1
     814:	fee79de3          	bne	a5,a4,80e <memset+0x14>
  }
  return dst;
}
     818:	60a2                	ld	ra,8(sp)
     81a:	6402                	ld	s0,0(sp)
     81c:	0141                	addi	sp,sp,16
     81e:	8082                	ret

0000000000000820 <strchr>:

char*
strchr(const char *s, char c)
{
     820:	1141                	addi	sp,sp,-16
     822:	e406                	sd	ra,8(sp)
     824:	e022                	sd	s0,0(sp)
     826:	0800                	addi	s0,sp,16
  for(; *s; s++)
     828:	00054783          	lbu	a5,0(a0)
     82c:	cf81                	beqz	a5,844 <strchr+0x24>
    if(*s == c)
     82e:	00f58763          	beq	a1,a5,83c <strchr+0x1c>
  for(; *s; s++)
     832:	0505                	addi	a0,a0,1
     834:	00054783          	lbu	a5,0(a0)
     838:	fbfd                	bnez	a5,82e <strchr+0xe>
      return (char*)s;
  return 0;
     83a:	4501                	li	a0,0
}
     83c:	60a2                	ld	ra,8(sp)
     83e:	6402                	ld	s0,0(sp)
     840:	0141                	addi	sp,sp,16
     842:	8082                	ret
  return 0;
     844:	4501                	li	a0,0
     846:	bfdd                	j	83c <strchr+0x1c>

0000000000000848 <gets>:

char*
gets(char *buf, int max)
{
     848:	711d                	addi	sp,sp,-96
     84a:	ec86                	sd	ra,88(sp)
     84c:	e8a2                	sd	s0,80(sp)
     84e:	e4a6                	sd	s1,72(sp)
     850:	e0ca                	sd	s2,64(sp)
     852:	fc4e                	sd	s3,56(sp)
     854:	f852                	sd	s4,48(sp)
     856:	f456                	sd	s5,40(sp)
     858:	f05a                	sd	s6,32(sp)
     85a:	ec5e                	sd	s7,24(sp)
     85c:	e862                	sd	s8,16(sp)
     85e:	1080                	addi	s0,sp,96
     860:	8baa                	mv	s7,a0
     862:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     864:	892a                	mv	s2,a0
     866:	4481                	li	s1,0
    cc = read(0, &c, 1);
     868:	faf40b13          	addi	s6,s0,-81
     86c:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
     86e:	8c26                	mv	s8,s1
     870:	0014899b          	addiw	s3,s1,1
     874:	84ce                	mv	s1,s3
     876:	0349d463          	bge	s3,s4,89e <gets+0x56>
    cc = read(0, &c, 1);
     87a:	8656                	mv	a2,s5
     87c:	85da                	mv	a1,s6
     87e:	4501                	li	a0,0
     880:	1bc000ef          	jal	a3c <read>
    if(cc < 1)
     884:	00a05d63          	blez	a0,89e <gets+0x56>
      break;
    buf[i++] = c;
     888:	faf44783          	lbu	a5,-81(s0)
     88c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     890:	0905                	addi	s2,s2,1
     892:	ff678713          	addi	a4,a5,-10
     896:	c319                	beqz	a4,89c <gets+0x54>
     898:	17cd                	addi	a5,a5,-13
     89a:	fbf1                	bnez	a5,86e <gets+0x26>
    buf[i++] = c;
     89c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     89e:	9c5e                	add	s8,s8,s7
     8a0:	000c0023          	sb	zero,0(s8)
  return buf;
}
     8a4:	855e                	mv	a0,s7
     8a6:	60e6                	ld	ra,88(sp)
     8a8:	6446                	ld	s0,80(sp)
     8aa:	64a6                	ld	s1,72(sp)
     8ac:	6906                	ld	s2,64(sp)
     8ae:	79e2                	ld	s3,56(sp)
     8b0:	7a42                	ld	s4,48(sp)
     8b2:	7aa2                	ld	s5,40(sp)
     8b4:	7b02                	ld	s6,32(sp)
     8b6:	6be2                	ld	s7,24(sp)
     8b8:	6c42                	ld	s8,16(sp)
     8ba:	6125                	addi	sp,sp,96
     8bc:	8082                	ret

00000000000008be <stat>:

int
stat(const char *n, struct stat *st)
{
     8be:	1101                	addi	sp,sp,-32
     8c0:	ec06                	sd	ra,24(sp)
     8c2:	e822                	sd	s0,16(sp)
     8c4:	e04a                	sd	s2,0(sp)
     8c6:	1000                	addi	s0,sp,32
     8c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     8ca:	4581                	li	a1,0
     8cc:	198000ef          	jal	a64 <open>
  if(fd < 0)
     8d0:	02054263          	bltz	a0,8f4 <stat+0x36>
     8d4:	e426                	sd	s1,8(sp)
     8d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     8d8:	85ca                	mv	a1,s2
     8da:	1a2000ef          	jal	a7c <fstat>
     8de:	892a                	mv	s2,a0
  close(fd);
     8e0:	8526                	mv	a0,s1
     8e2:	16a000ef          	jal	a4c <close>
  return r;
     8e6:	64a2                	ld	s1,8(sp)
}
     8e8:	854a                	mv	a0,s2
     8ea:	60e2                	ld	ra,24(sp)
     8ec:	6442                	ld	s0,16(sp)
     8ee:	6902                	ld	s2,0(sp)
     8f0:	6105                	addi	sp,sp,32
     8f2:	8082                	ret
    return -1;
     8f4:	57fd                	li	a5,-1
     8f6:	893e                	mv	s2,a5
     8f8:	bfc5                	j	8e8 <stat+0x2a>

00000000000008fa <atoi>:

int
atoi(const char *s)
{
     8fa:	1141                	addi	sp,sp,-16
     8fc:	e406                	sd	ra,8(sp)
     8fe:	e022                	sd	s0,0(sp)
     900:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     902:	00054683          	lbu	a3,0(a0)
     906:	fd06879b          	addiw	a5,a3,-48
     90a:	0ff7f793          	zext.b	a5,a5
     90e:	4625                	li	a2,9
     910:	02f66963          	bltu	a2,a5,942 <atoi+0x48>
     914:	872a                	mv	a4,a0
  n = 0;
     916:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     918:	0705                	addi	a4,a4,1
     91a:	0025179b          	slliw	a5,a0,0x2
     91e:	9fa9                	addw	a5,a5,a0
     920:	0017979b          	slliw	a5,a5,0x1
     924:	9fb5                	addw	a5,a5,a3
     926:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     92a:	00074683          	lbu	a3,0(a4)
     92e:	fd06879b          	addiw	a5,a3,-48
     932:	0ff7f793          	zext.b	a5,a5
     936:	fef671e3          	bgeu	a2,a5,918 <atoi+0x1e>
  return n;
}
     93a:	60a2                	ld	ra,8(sp)
     93c:	6402                	ld	s0,0(sp)
     93e:	0141                	addi	sp,sp,16
     940:	8082                	ret
  n = 0;
     942:	4501                	li	a0,0
     944:	bfdd                	j	93a <atoi+0x40>

0000000000000946 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     946:	1141                	addi	sp,sp,-16
     948:	e406                	sd	ra,8(sp)
     94a:	e022                	sd	s0,0(sp)
     94c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     94e:	02b57563          	bgeu	a0,a1,978 <memmove+0x32>
    while(n-- > 0)
     952:	00c05f63          	blez	a2,970 <memmove+0x2a>
     956:	1602                	slli	a2,a2,0x20
     958:	9201                	srli	a2,a2,0x20
     95a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     95e:	872a                	mv	a4,a0
      *dst++ = *src++;
     960:	0585                	addi	a1,a1,1
     962:	0705                	addi	a4,a4,1
     964:	fff5c683          	lbu	a3,-1(a1)
     968:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     96c:	fee79ae3          	bne	a5,a4,960 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     970:	60a2                	ld	ra,8(sp)
     972:	6402                	ld	s0,0(sp)
     974:	0141                	addi	sp,sp,16
     976:	8082                	ret
    while(n-- > 0)
     978:	fec05ce3          	blez	a2,970 <memmove+0x2a>
    dst += n;
     97c:	00c50733          	add	a4,a0,a2
    src += n;
     980:	95b2                	add	a1,a1,a2
     982:	fff6079b          	addiw	a5,a2,-1
     986:	1782                	slli	a5,a5,0x20
     988:	9381                	srli	a5,a5,0x20
     98a:	fff7c793          	not	a5,a5
     98e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     990:	15fd                	addi	a1,a1,-1
     992:	177d                	addi	a4,a4,-1
     994:	0005c683          	lbu	a3,0(a1)
     998:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     99c:	fef71ae3          	bne	a4,a5,990 <memmove+0x4a>
     9a0:	bfc1                	j	970 <memmove+0x2a>

00000000000009a2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     9a2:	1141                	addi	sp,sp,-16
     9a4:	e406                	sd	ra,8(sp)
     9a6:	e022                	sd	s0,0(sp)
     9a8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     9aa:	c61d                	beqz	a2,9d8 <memcmp+0x36>
     9ac:	1602                	slli	a2,a2,0x20
     9ae:	9201                	srli	a2,a2,0x20
     9b0:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     9b4:	00054783          	lbu	a5,0(a0)
     9b8:	0005c703          	lbu	a4,0(a1)
     9bc:	00e79863          	bne	a5,a4,9cc <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     9c0:	0505                	addi	a0,a0,1
    p2++;
     9c2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     9c4:	fed518e3          	bne	a0,a3,9b4 <memcmp+0x12>
  }
  return 0;
     9c8:	4501                	li	a0,0
     9ca:	a019                	j	9d0 <memcmp+0x2e>
      return *p1 - *p2;
     9cc:	40e7853b          	subw	a0,a5,a4
}
     9d0:	60a2                	ld	ra,8(sp)
     9d2:	6402                	ld	s0,0(sp)
     9d4:	0141                	addi	sp,sp,16
     9d6:	8082                	ret
  return 0;
     9d8:	4501                	li	a0,0
     9da:	bfdd                	j	9d0 <memcmp+0x2e>

00000000000009dc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     9dc:	1141                	addi	sp,sp,-16
     9de:	e406                	sd	ra,8(sp)
     9e0:	e022                	sd	s0,0(sp)
     9e2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     9e4:	f63ff0ef          	jal	946 <memmove>
}
     9e8:	60a2                	ld	ra,8(sp)
     9ea:	6402                	ld	s0,0(sp)
     9ec:	0141                	addi	sp,sp,16
     9ee:	8082                	ret

00000000000009f0 <sbrk>:

char *
sbrk(int n) {
     9f0:	1141                	addi	sp,sp,-16
     9f2:	e406                	sd	ra,8(sp)
     9f4:	e022                	sd	s0,0(sp)
     9f6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     9f8:	4585                	li	a1,1
     9fa:	0b2000ef          	jal	aac <sys_sbrk>
}
     9fe:	60a2                	ld	ra,8(sp)
     a00:	6402                	ld	s0,0(sp)
     a02:	0141                	addi	sp,sp,16
     a04:	8082                	ret

0000000000000a06 <sbrklazy>:

char *
sbrklazy(int n) {
     a06:	1141                	addi	sp,sp,-16
     a08:	e406                	sd	ra,8(sp)
     a0a:	e022                	sd	s0,0(sp)
     a0c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     a0e:	4589                	li	a1,2
     a10:	09c000ef          	jal	aac <sys_sbrk>
}
     a14:	60a2                	ld	ra,8(sp)
     a16:	6402                	ld	s0,0(sp)
     a18:	0141                	addi	sp,sp,16
     a1a:	8082                	ret

0000000000000a1c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     a1c:	4885                	li	a7,1
 ecall
     a1e:	00000073          	ecall
 ret
     a22:	8082                	ret

0000000000000a24 <exit>:
.global exit
exit:
 li a7, SYS_exit
     a24:	4889                	li	a7,2
 ecall
     a26:	00000073          	ecall
 ret
     a2a:	8082                	ret

0000000000000a2c <wait>:
.global wait
wait:
 li a7, SYS_wait
     a2c:	488d                	li	a7,3
 ecall
     a2e:	00000073          	ecall
 ret
     a32:	8082                	ret

0000000000000a34 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     a34:	4891                	li	a7,4
 ecall
     a36:	00000073          	ecall
 ret
     a3a:	8082                	ret

0000000000000a3c <read>:
.global read
read:
 li a7, SYS_read
     a3c:	4895                	li	a7,5
 ecall
     a3e:	00000073          	ecall
 ret
     a42:	8082                	ret

0000000000000a44 <write>:
.global write
write:
 li a7, SYS_write
     a44:	48c1                	li	a7,16
 ecall
     a46:	00000073          	ecall
 ret
     a4a:	8082                	ret

0000000000000a4c <close>:
.global close
close:
 li a7, SYS_close
     a4c:	48d5                	li	a7,21
 ecall
     a4e:	00000073          	ecall
 ret
     a52:	8082                	ret

0000000000000a54 <kill>:
.global kill
kill:
 li a7, SYS_kill
     a54:	4899                	li	a7,6
 ecall
     a56:	00000073          	ecall
 ret
     a5a:	8082                	ret

0000000000000a5c <exec>:
.global exec
exec:
 li a7, SYS_exec
     a5c:	489d                	li	a7,7
 ecall
     a5e:	00000073          	ecall
 ret
     a62:	8082                	ret

0000000000000a64 <open>:
.global open
open:
 li a7, SYS_open
     a64:	48bd                	li	a7,15
 ecall
     a66:	00000073          	ecall
 ret
     a6a:	8082                	ret

0000000000000a6c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     a6c:	48c5                	li	a7,17
 ecall
     a6e:	00000073          	ecall
 ret
     a72:	8082                	ret

0000000000000a74 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     a74:	48c9                	li	a7,18
 ecall
     a76:	00000073          	ecall
 ret
     a7a:	8082                	ret

0000000000000a7c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     a7c:	48a1                	li	a7,8
 ecall
     a7e:	00000073          	ecall
 ret
     a82:	8082                	ret

0000000000000a84 <link>:
.global link
link:
 li a7, SYS_link
     a84:	48cd                	li	a7,19
 ecall
     a86:	00000073          	ecall
 ret
     a8a:	8082                	ret

0000000000000a8c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     a8c:	48d1                	li	a7,20
 ecall
     a8e:	00000073          	ecall
 ret
     a92:	8082                	ret

0000000000000a94 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     a94:	48a5                	li	a7,9
 ecall
     a96:	00000073          	ecall
 ret
     a9a:	8082                	ret

0000000000000a9c <dup>:
.global dup
dup:
 li a7, SYS_dup
     a9c:	48a9                	li	a7,10
 ecall
     a9e:	00000073          	ecall
 ret
     aa2:	8082                	ret

0000000000000aa4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     aa4:	48ad                	li	a7,11
 ecall
     aa6:	00000073          	ecall
 ret
     aaa:	8082                	ret

0000000000000aac <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     aac:	48b1                	li	a7,12
 ecall
     aae:	00000073          	ecall
 ret
     ab2:	8082                	ret

0000000000000ab4 <pause>:
.global pause
pause:
 li a7, SYS_pause
     ab4:	48b5                	li	a7,13
 ecall
     ab6:	00000073          	ecall
 ret
     aba:	8082                	ret

0000000000000abc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     abc:	48b9                	li	a7,14
 ecall
     abe:	00000073          	ecall
 ret
     ac2:	8082                	ret

0000000000000ac4 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
     ac4:	48d9                	li	a7,22
 ecall
     ac6:	00000073          	ecall
 ret
     aca:	8082                	ret

0000000000000acc <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
     acc:	48dd                	li	a7,23
 ecall
     ace:	00000073          	ecall
 ret
     ad2:	8082                	ret

0000000000000ad4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     ad4:	1101                	addi	sp,sp,-32
     ad6:	ec06                	sd	ra,24(sp)
     ad8:	e822                	sd	s0,16(sp)
     ada:	1000                	addi	s0,sp,32
     adc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     ae0:	4605                	li	a2,1
     ae2:	fef40593          	addi	a1,s0,-17
     ae6:	f5fff0ef          	jal	a44 <write>
}
     aea:	60e2                	ld	ra,24(sp)
     aec:	6442                	ld	s0,16(sp)
     aee:	6105                	addi	sp,sp,32
     af0:	8082                	ret

0000000000000af2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     af2:	715d                	addi	sp,sp,-80
     af4:	e486                	sd	ra,72(sp)
     af6:	e0a2                	sd	s0,64(sp)
     af8:	f84a                	sd	s2,48(sp)
     afa:	f44e                	sd	s3,40(sp)
     afc:	0880                	addi	s0,sp,80
     afe:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     b00:	c6d1                	beqz	a3,b8c <printint+0x9a>
     b02:	0805d563          	bgez	a1,b8c <printint+0x9a>
    neg = 1;
    x = -xx;
     b06:	40b005b3          	neg	a1,a1
    neg = 1;
     b0a:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     b0c:	fb840993          	addi	s3,s0,-72
  neg = 0;
     b10:	86ce                	mv	a3,s3
  i = 0;
     b12:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     b14:	00002817          	auipc	a6,0x2
     b18:	88480813          	addi	a6,a6,-1916 # 2398 <digits>
     b1c:	88ba                	mv	a7,a4
     b1e:	0017051b          	addiw	a0,a4,1
     b22:	872a                	mv	a4,a0
     b24:	02c5f7b3          	remu	a5,a1,a2
     b28:	97c2                	add	a5,a5,a6
     b2a:	0007c783          	lbu	a5,0(a5)
     b2e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     b32:	87ae                	mv	a5,a1
     b34:	02c5d5b3          	divu	a1,a1,a2
     b38:	0685                	addi	a3,a3,1
     b3a:	fec7f1e3          	bgeu	a5,a2,b1c <printint+0x2a>
  if(neg)
     b3e:	00030c63          	beqz	t1,b56 <printint+0x64>
    buf[i++] = '-';
     b42:	fd050793          	addi	a5,a0,-48
     b46:	00878533          	add	a0,a5,s0
     b4a:	02d00793          	li	a5,45
     b4e:	fef50423          	sb	a5,-24(a0)
     b52:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
     b56:	02e05563          	blez	a4,b80 <printint+0x8e>
     b5a:	fc26                	sd	s1,56(sp)
     b5c:	377d                	addiw	a4,a4,-1
     b5e:	00e984b3          	add	s1,s3,a4
     b62:	19fd                	addi	s3,s3,-1
     b64:	99ba                	add	s3,s3,a4
     b66:	1702                	slli	a4,a4,0x20
     b68:	9301                	srli	a4,a4,0x20
     b6a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     b6e:	0004c583          	lbu	a1,0(s1)
     b72:	854a                	mv	a0,s2
     b74:	f61ff0ef          	jal	ad4 <putc>
  while(--i >= 0)
     b78:	14fd                	addi	s1,s1,-1
     b7a:	ff349ae3          	bne	s1,s3,b6e <printint+0x7c>
     b7e:	74e2                	ld	s1,56(sp)
}
     b80:	60a6                	ld	ra,72(sp)
     b82:	6406                	ld	s0,64(sp)
     b84:	7942                	ld	s2,48(sp)
     b86:	79a2                	ld	s3,40(sp)
     b88:	6161                	addi	sp,sp,80
     b8a:	8082                	ret
  neg = 0;
     b8c:	4301                	li	t1,0
     b8e:	bfbd                	j	b0c <printint+0x1a>

0000000000000b90 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     b90:	711d                	addi	sp,sp,-96
     b92:	ec86                	sd	ra,88(sp)
     b94:	e8a2                	sd	s0,80(sp)
     b96:	e4a6                	sd	s1,72(sp)
     b98:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     b9a:	0005c483          	lbu	s1,0(a1)
     b9e:	22048363          	beqz	s1,dc4 <vprintf+0x234>
     ba2:	e0ca                	sd	s2,64(sp)
     ba4:	fc4e                	sd	s3,56(sp)
     ba6:	f852                	sd	s4,48(sp)
     ba8:	f456                	sd	s5,40(sp)
     baa:	f05a                	sd	s6,32(sp)
     bac:	ec5e                	sd	s7,24(sp)
     bae:	e862                	sd	s8,16(sp)
     bb0:	8b2a                	mv	s6,a0
     bb2:	8a2e                	mv	s4,a1
     bb4:	8bb2                	mv	s7,a2
  state = 0;
     bb6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     bb8:	4901                	li	s2,0
     bba:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     bbc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     bc0:	06400c13          	li	s8,100
     bc4:	a00d                	j	be6 <vprintf+0x56>
        putc(fd, c0);
     bc6:	85a6                	mv	a1,s1
     bc8:	855a                	mv	a0,s6
     bca:	f0bff0ef          	jal	ad4 <putc>
     bce:	a019                	j	bd4 <vprintf+0x44>
    } else if(state == '%'){
     bd0:	03598363          	beq	s3,s5,bf6 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
     bd4:	0019079b          	addiw	a5,s2,1
     bd8:	893e                	mv	s2,a5
     bda:	873e                	mv	a4,a5
     bdc:	97d2                	add	a5,a5,s4
     bde:	0007c483          	lbu	s1,0(a5)
     be2:	1c048a63          	beqz	s1,db6 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
     be6:	0004879b          	sext.w	a5,s1
    if(state == 0){
     bea:	fe0993e3          	bnez	s3,bd0 <vprintf+0x40>
      if(c0 == '%'){
     bee:	fd579ce3          	bne	a5,s5,bc6 <vprintf+0x36>
        state = '%';
     bf2:	89be                	mv	s3,a5
     bf4:	b7c5                	j	bd4 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
     bf6:	00ea06b3          	add	a3,s4,a4
     bfa:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
     bfe:	1c060863          	beqz	a2,dce <vprintf+0x23e>
      if(c0 == 'd'){
     c02:	03878763          	beq	a5,s8,c30 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     c06:	f9478693          	addi	a3,a5,-108
     c0a:	0016b693          	seqz	a3,a3
     c0e:	f9c60593          	addi	a1,a2,-100
     c12:	e99d                	bnez	a1,c48 <vprintf+0xb8>
     c14:	ca95                	beqz	a3,c48 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
     c16:	008b8493          	addi	s1,s7,8
     c1a:	4685                	li	a3,1
     c1c:	4629                	li	a2,10
     c1e:	000bb583          	ld	a1,0(s7)
     c22:	855a                	mv	a0,s6
     c24:	ecfff0ef          	jal	af2 <printint>
        i += 1;
     c28:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     c2a:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     c2c:	4981                	li	s3,0
     c2e:	b75d                	j	bd4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
     c30:	008b8493          	addi	s1,s7,8
     c34:	4685                	li	a3,1
     c36:	4629                	li	a2,10
     c38:	000ba583          	lw	a1,0(s7)
     c3c:	855a                	mv	a0,s6
     c3e:	eb5ff0ef          	jal	af2 <printint>
     c42:	8ba6                	mv	s7,s1
      state = 0;
     c44:	4981                	li	s3,0
     c46:	b779                	j	bd4 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
     c48:	9752                	add	a4,a4,s4
     c4a:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     c4e:	f9460713          	addi	a4,a2,-108
     c52:	00173713          	seqz	a4,a4
     c56:	8f75                	and	a4,a4,a3
     c58:	f9c58513          	addi	a0,a1,-100
     c5c:	18051363          	bnez	a0,de2 <vprintf+0x252>
     c60:	18070163          	beqz	a4,de2 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
     c64:	008b8493          	addi	s1,s7,8
     c68:	4685                	li	a3,1
     c6a:	4629                	li	a2,10
     c6c:	000bb583          	ld	a1,0(s7)
     c70:	855a                	mv	a0,s6
     c72:	e81ff0ef          	jal	af2 <printint>
        i += 2;
     c76:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     c78:	8ba6                	mv	s7,s1
      state = 0;
     c7a:	4981                	li	s3,0
        i += 2;
     c7c:	bfa1                	j	bd4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
     c7e:	008b8493          	addi	s1,s7,8
     c82:	4681                	li	a3,0
     c84:	4629                	li	a2,10
     c86:	000be583          	lwu	a1,0(s7)
     c8a:	855a                	mv	a0,s6
     c8c:	e67ff0ef          	jal	af2 <printint>
     c90:	8ba6                	mv	s7,s1
      state = 0;
     c92:	4981                	li	s3,0
     c94:	b781                	j	bd4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     c96:	008b8493          	addi	s1,s7,8
     c9a:	4681                	li	a3,0
     c9c:	4629                	li	a2,10
     c9e:	000bb583          	ld	a1,0(s7)
     ca2:	855a                	mv	a0,s6
     ca4:	e4fff0ef          	jal	af2 <printint>
        i += 1;
     ca8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     caa:	8ba6                	mv	s7,s1
      state = 0;
     cac:	4981                	li	s3,0
     cae:	b71d                	j	bd4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     cb0:	008b8493          	addi	s1,s7,8
     cb4:	4681                	li	a3,0
     cb6:	4629                	li	a2,10
     cb8:	000bb583          	ld	a1,0(s7)
     cbc:	855a                	mv	a0,s6
     cbe:	e35ff0ef          	jal	af2 <printint>
        i += 2;
     cc2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     cc4:	8ba6                	mv	s7,s1
      state = 0;
     cc6:	4981                	li	s3,0
        i += 2;
     cc8:	b731                	j	bd4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
     cca:	008b8493          	addi	s1,s7,8
     cce:	4681                	li	a3,0
     cd0:	4641                	li	a2,16
     cd2:	000be583          	lwu	a1,0(s7)
     cd6:	855a                	mv	a0,s6
     cd8:	e1bff0ef          	jal	af2 <printint>
     cdc:	8ba6                	mv	s7,s1
      state = 0;
     cde:	4981                	li	s3,0
     ce0:	bdd5                	j	bd4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ce2:	008b8493          	addi	s1,s7,8
     ce6:	4681                	li	a3,0
     ce8:	4641                	li	a2,16
     cea:	000bb583          	ld	a1,0(s7)
     cee:	855a                	mv	a0,s6
     cf0:	e03ff0ef          	jal	af2 <printint>
        i += 1;
     cf4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     cf6:	8ba6                	mv	s7,s1
      state = 0;
     cf8:	4981                	li	s3,0
     cfa:	bde9                	j	bd4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     cfc:	008b8493          	addi	s1,s7,8
     d00:	4681                	li	a3,0
     d02:	4641                	li	a2,16
     d04:	000bb583          	ld	a1,0(s7)
     d08:	855a                	mv	a0,s6
     d0a:	de9ff0ef          	jal	af2 <printint>
        i += 2;
     d0e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     d10:	8ba6                	mv	s7,s1
      state = 0;
     d12:	4981                	li	s3,0
        i += 2;
     d14:	b5c1                	j	bd4 <vprintf+0x44>
     d16:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
     d18:	008b8793          	addi	a5,s7,8
     d1c:	8cbe                	mv	s9,a5
     d1e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     d22:	03000593          	li	a1,48
     d26:	855a                	mv	a0,s6
     d28:	dadff0ef          	jal	ad4 <putc>
  putc(fd, 'x');
     d2c:	07800593          	li	a1,120
     d30:	855a                	mv	a0,s6
     d32:	da3ff0ef          	jal	ad4 <putc>
     d36:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d38:	00001b97          	auipc	s7,0x1
     d3c:	660b8b93          	addi	s7,s7,1632 # 2398 <digits>
     d40:	03c9d793          	srli	a5,s3,0x3c
     d44:	97de                	add	a5,a5,s7
     d46:	0007c583          	lbu	a1,0(a5)
     d4a:	855a                	mv	a0,s6
     d4c:	d89ff0ef          	jal	ad4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     d50:	0992                	slli	s3,s3,0x4
     d52:	34fd                	addiw	s1,s1,-1
     d54:	f4f5                	bnez	s1,d40 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
     d56:	8be6                	mv	s7,s9
      state = 0;
     d58:	4981                	li	s3,0
     d5a:	6ca2                	ld	s9,8(sp)
     d5c:	bda5                	j	bd4 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
     d5e:	008b8493          	addi	s1,s7,8
     d62:	000bc583          	lbu	a1,0(s7)
     d66:	855a                	mv	a0,s6
     d68:	d6dff0ef          	jal	ad4 <putc>
     d6c:	8ba6                	mv	s7,s1
      state = 0;
     d6e:	4981                	li	s3,0
     d70:	b595                	j	bd4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
     d72:	008b8993          	addi	s3,s7,8
     d76:	000bb483          	ld	s1,0(s7)
     d7a:	cc91                	beqz	s1,d96 <vprintf+0x206>
        for(; *s; s++)
     d7c:	0004c583          	lbu	a1,0(s1)
     d80:	c985                	beqz	a1,db0 <vprintf+0x220>
          putc(fd, *s);
     d82:	855a                	mv	a0,s6
     d84:	d51ff0ef          	jal	ad4 <putc>
        for(; *s; s++)
     d88:	0485                	addi	s1,s1,1
     d8a:	0004c583          	lbu	a1,0(s1)
     d8e:	f9f5                	bnez	a1,d82 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
     d90:	8bce                	mv	s7,s3
      state = 0;
     d92:	4981                	li	s3,0
     d94:	b581                	j	bd4 <vprintf+0x44>
          s = "(null)";
     d96:	00001497          	auipc	s1,0x1
     d9a:	5fa48493          	addi	s1,s1,1530 # 2390 <malloc+0x145e>
        for(; *s; s++)
     d9e:	02800593          	li	a1,40
     da2:	b7c5                	j	d82 <vprintf+0x1f2>
        putc(fd, '%');
     da4:	85be                	mv	a1,a5
     da6:	855a                	mv	a0,s6
     da8:	d2dff0ef          	jal	ad4 <putc>
      state = 0;
     dac:	4981                	li	s3,0
     dae:	b51d                	j	bd4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
     db0:	8bce                	mv	s7,s3
      state = 0;
     db2:	4981                	li	s3,0
     db4:	b505                	j	bd4 <vprintf+0x44>
     db6:	6906                	ld	s2,64(sp)
     db8:	79e2                	ld	s3,56(sp)
     dba:	7a42                	ld	s4,48(sp)
     dbc:	7aa2                	ld	s5,40(sp)
     dbe:	7b02                	ld	s6,32(sp)
     dc0:	6be2                	ld	s7,24(sp)
     dc2:	6c42                	ld	s8,16(sp)
    }
  }
}
     dc4:	60e6                	ld	ra,88(sp)
     dc6:	6446                	ld	s0,80(sp)
     dc8:	64a6                	ld	s1,72(sp)
     dca:	6125                	addi	sp,sp,96
     dcc:	8082                	ret
      if(c0 == 'd'){
     dce:	06400713          	li	a4,100
     dd2:	e4e78fe3          	beq	a5,a4,c30 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
     dd6:	f9478693          	addi	a3,a5,-108
     dda:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
     dde:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     de0:	4701                	li	a4,0
      } else if(c0 == 'u'){
     de2:	07500513          	li	a0,117
     de6:	e8a78ce3          	beq	a5,a0,c7e <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
     dea:	f8b60513          	addi	a0,a2,-117
     dee:	e119                	bnez	a0,df4 <vprintf+0x264>
     df0:	ea0693e3          	bnez	a3,c96 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     df4:	f8b58513          	addi	a0,a1,-117
     df8:	e119                	bnez	a0,dfe <vprintf+0x26e>
     dfa:	ea071be3          	bnez	a4,cb0 <vprintf+0x120>
      } else if(c0 == 'x'){
     dfe:	07800513          	li	a0,120
     e02:	eca784e3          	beq	a5,a0,cca <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
     e06:	f8860613          	addi	a2,a2,-120
     e0a:	e219                	bnez	a2,e10 <vprintf+0x280>
     e0c:	ec069be3          	bnez	a3,ce2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e10:	f8858593          	addi	a1,a1,-120
     e14:	e199                	bnez	a1,e1a <vprintf+0x28a>
     e16:	ee0713e3          	bnez	a4,cfc <vprintf+0x16c>
      } else if(c0 == 'p'){
     e1a:	07000713          	li	a4,112
     e1e:	eee78ce3          	beq	a5,a4,d16 <vprintf+0x186>
      } else if(c0 == 'c'){
     e22:	06300713          	li	a4,99
     e26:	f2e78ce3          	beq	a5,a4,d5e <vprintf+0x1ce>
      } else if(c0 == 's'){
     e2a:	07300713          	li	a4,115
     e2e:	f4e782e3          	beq	a5,a4,d72 <vprintf+0x1e2>
      } else if(c0 == '%'){
     e32:	02500713          	li	a4,37
     e36:	f6e787e3          	beq	a5,a4,da4 <vprintf+0x214>
        putc(fd, '%');
     e3a:	02500593          	li	a1,37
     e3e:	855a                	mv	a0,s6
     e40:	c95ff0ef          	jal	ad4 <putc>
        putc(fd, c0);
     e44:	85a6                	mv	a1,s1
     e46:	855a                	mv	a0,s6
     e48:	c8dff0ef          	jal	ad4 <putc>
      state = 0;
     e4c:	4981                	li	s3,0
     e4e:	b359                	j	bd4 <vprintf+0x44>

0000000000000e50 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     e50:	715d                	addi	sp,sp,-80
     e52:	ec06                	sd	ra,24(sp)
     e54:	e822                	sd	s0,16(sp)
     e56:	1000                	addi	s0,sp,32
     e58:	e010                	sd	a2,0(s0)
     e5a:	e414                	sd	a3,8(s0)
     e5c:	e818                	sd	a4,16(s0)
     e5e:	ec1c                	sd	a5,24(s0)
     e60:	03043023          	sd	a6,32(s0)
     e64:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     e68:	8622                	mv	a2,s0
     e6a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     e6e:	d23ff0ef          	jal	b90 <vprintf>
}
     e72:	60e2                	ld	ra,24(sp)
     e74:	6442                	ld	s0,16(sp)
     e76:	6161                	addi	sp,sp,80
     e78:	8082                	ret

0000000000000e7a <printf>:

void
printf(const char *fmt, ...)
{
     e7a:	711d                	addi	sp,sp,-96
     e7c:	ec06                	sd	ra,24(sp)
     e7e:	e822                	sd	s0,16(sp)
     e80:	1000                	addi	s0,sp,32
     e82:	e40c                	sd	a1,8(s0)
     e84:	e810                	sd	a2,16(s0)
     e86:	ec14                	sd	a3,24(s0)
     e88:	f018                	sd	a4,32(s0)
     e8a:	f41c                	sd	a5,40(s0)
     e8c:	03043823          	sd	a6,48(s0)
     e90:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     e94:	00840613          	addi	a2,s0,8
     e98:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     e9c:	85aa                	mv	a1,a0
     e9e:	4505                	li	a0,1
     ea0:	cf1ff0ef          	jal	b90 <vprintf>
}
     ea4:	60e2                	ld	ra,24(sp)
     ea6:	6442                	ld	s0,16(sp)
     ea8:	6125                	addi	sp,sp,96
     eaa:	8082                	ret

0000000000000eac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     eac:	1141                	addi	sp,sp,-16
     eae:	e406                	sd	ra,8(sp)
     eb0:	e022                	sd	s0,0(sp)
     eb2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     eb4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     eb8:	00002797          	auipc	a5,0x2
     ebc:	1587b783          	ld	a5,344(a5) # 3010 <freep>
     ec0:	a039                	j	ece <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     ec2:	6398                	ld	a4,0(a5)
     ec4:	00e7e463          	bltu	a5,a4,ecc <free+0x20>
     ec8:	00e6ea63          	bltu	a3,a4,edc <free+0x30>
{
     ecc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ece:	fed7fae3          	bgeu	a5,a3,ec2 <free+0x16>
     ed2:	6398                	ld	a4,0(a5)
     ed4:	00e6e463          	bltu	a3,a4,edc <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     ed8:	fee7eae3          	bltu	a5,a4,ecc <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
     edc:	ff852583          	lw	a1,-8(a0)
     ee0:	6390                	ld	a2,0(a5)
     ee2:	02059813          	slli	a6,a1,0x20
     ee6:	01c85713          	srli	a4,a6,0x1c
     eea:	9736                	add	a4,a4,a3
     eec:	02e60563          	beq	a2,a4,f16 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
     ef0:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
     ef4:	4790                	lw	a2,8(a5)
     ef6:	02061593          	slli	a1,a2,0x20
     efa:	01c5d713          	srli	a4,a1,0x1c
     efe:	973e                	add	a4,a4,a5
     f00:	02e68263          	beq	a3,a4,f24 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
     f04:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
     f06:	00002717          	auipc	a4,0x2
     f0a:	10f73523          	sd	a5,266(a4) # 3010 <freep>
}
     f0e:	60a2                	ld	ra,8(sp)
     f10:	6402                	ld	s0,0(sp)
     f12:	0141                	addi	sp,sp,16
     f14:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
     f16:	4618                	lw	a4,8(a2)
     f18:	9f2d                	addw	a4,a4,a1
     f1a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     f1e:	6398                	ld	a4,0(a5)
     f20:	6310                	ld	a2,0(a4)
     f22:	b7f9                	j	ef0 <free+0x44>
    p->s.size += bp->s.size;
     f24:	ff852703          	lw	a4,-8(a0)
     f28:	9f31                	addw	a4,a4,a2
     f2a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
     f2c:	ff053683          	ld	a3,-16(a0)
     f30:	bfd1                	j	f04 <free+0x58>

0000000000000f32 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
     f32:	7139                	addi	sp,sp,-64
     f34:	fc06                	sd	ra,56(sp)
     f36:	f822                	sd	s0,48(sp)
     f38:	f04a                	sd	s2,32(sp)
     f3a:	ec4e                	sd	s3,24(sp)
     f3c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
     f3e:	02051993          	slli	s3,a0,0x20
     f42:	0209d993          	srli	s3,s3,0x20
     f46:	09bd                	addi	s3,s3,15
     f48:	0049d993          	srli	s3,s3,0x4
     f4c:	2985                	addiw	s3,s3,1
     f4e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
     f50:	00002517          	auipc	a0,0x2
     f54:	0c053503          	ld	a0,192(a0) # 3010 <freep>
     f58:	c905                	beqz	a0,f88 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     f5a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
     f5c:	4798                	lw	a4,8(a5)
     f5e:	09377663          	bgeu	a4,s3,fea <malloc+0xb8>
     f62:	f426                	sd	s1,40(sp)
     f64:	e852                	sd	s4,16(sp)
     f66:	e456                	sd	s5,8(sp)
     f68:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
     f6a:	8a4e                	mv	s4,s3
     f6c:	6705                	lui	a4,0x1
     f6e:	00e9f363          	bgeu	s3,a4,f74 <malloc+0x42>
     f72:	6a05                	lui	s4,0x1
     f74:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
     f78:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
     f7c:	00002497          	auipc	s1,0x2
     f80:	09448493          	addi	s1,s1,148 # 3010 <freep>
  if(p == SBRK_ERROR)
     f84:	5afd                	li	s5,-1
     f86:	a83d                	j	fc4 <malloc+0x92>
     f88:	f426                	sd	s1,40(sp)
     f8a:	e852                	sd	s4,16(sp)
     f8c:	e456                	sd	s5,8(sp)
     f8e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
     f90:	00002797          	auipc	a5,0x2
     f94:	09078793          	addi	a5,a5,144 # 3020 <base>
     f98:	00002717          	auipc	a4,0x2
     f9c:	06f73c23          	sd	a5,120(a4) # 3010 <freep>
     fa0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
     fa2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
     fa6:	b7d1                	j	f6a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
     fa8:	6398                	ld	a4,0(a5)
     faa:	e118                	sd	a4,0(a0)
     fac:	a899                	j	1002 <malloc+0xd0>
  hp->s.size = nu;
     fae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
     fb2:	0541                	addi	a0,a0,16
     fb4:	ef9ff0ef          	jal	eac <free>
  return freep;
     fb8:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
     fba:	c125                	beqz	a0,101a <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     fbc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
     fbe:	4798                	lw	a4,8(a5)
     fc0:	03277163          	bgeu	a4,s2,fe2 <malloc+0xb0>
    if(p == freep)
     fc4:	6098                	ld	a4,0(s1)
     fc6:	853e                	mv	a0,a5
     fc8:	fef71ae3          	bne	a4,a5,fbc <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
     fcc:	8552                	mv	a0,s4
     fce:	a23ff0ef          	jal	9f0 <sbrk>
  if(p == SBRK_ERROR)
     fd2:	fd551ee3          	bne	a0,s5,fae <malloc+0x7c>
        return 0;
     fd6:	4501                	li	a0,0
     fd8:	74a2                	ld	s1,40(sp)
     fda:	6a42                	ld	s4,16(sp)
     fdc:	6aa2                	ld	s5,8(sp)
     fde:	6b02                	ld	s6,0(sp)
     fe0:	a03d                	j	100e <malloc+0xdc>
     fe2:	74a2                	ld	s1,40(sp)
     fe4:	6a42                	ld	s4,16(sp)
     fe6:	6aa2                	ld	s5,8(sp)
     fe8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
     fea:	fae90fe3          	beq	s2,a4,fa8 <malloc+0x76>
        p->s.size -= nunits;
     fee:	4137073b          	subw	a4,a4,s3
     ff2:	c798                	sw	a4,8(a5)
        p += p->s.size;
     ff4:	02071693          	slli	a3,a4,0x20
     ff8:	01c6d713          	srli	a4,a3,0x1c
     ffc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
     ffe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1002:	00002717          	auipc	a4,0x2
    1006:	00a73723          	sd	a0,14(a4) # 3010 <freep>
      return (void*)(p + 1);
    100a:	01078513          	addi	a0,a5,16
  }
}
    100e:	70e2                	ld	ra,56(sp)
    1010:	7442                	ld	s0,48(sp)
    1012:	7902                	ld	s2,32(sp)
    1014:	69e2                	ld	s3,24(sp)
    1016:	6121                	addi	sp,sp,64
    1018:	8082                	ret
    101a:	74a2                	ld	s1,40(sp)
    101c:	6a42                	ld	s4,16(sp)
    101e:	6aa2                	ld	s5,8(sp)
    1020:	6b02                	ld	s6,0(sp)
    1022:	b7f5                	j	100e <malloc+0xdc>
