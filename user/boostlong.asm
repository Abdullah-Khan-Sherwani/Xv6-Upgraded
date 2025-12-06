
user/_boostlong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_work>:
#include "kernel/stat.h"
#include "user/user.h"

#define WORK_ITERATIONS 5000000

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
  14:	2406869b          	addiw	a3,a3,576 # f4240 <base+0xf2230>
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

000000000000003a <main>:

int
main(int argc, char *argv[])
{
  3a:	7135                	addi	sp,sp,-160
  3c:	ed06                	sd	ra,152(sp)
  3e:	e922                	sd	s0,144(sp)
  40:	e526                	sd	s1,136(sp)
  42:	e14a                	sd	s2,128(sp)
  44:	fcce                	sd	s3,120(sp)
  46:	f8d2                	sd	s4,112(sp)
  48:	f4d6                	sd	s5,104(sp)
  4a:	f0da                	sd	s6,96(sp)
  4c:	ecde                	sd	s7,88(sp)
  4e:	e8e2                	sd	s8,80(sp)
  50:	e4e6                	sd	s9,72(sp)
  52:	e0ea                	sd	s10,64(sp)
  54:	fc6e                	sd	s11,56(sp)
  56:	1100                	addi	s0,sp,160
  int start_tick;
  int last_priority = 0;
  int last_slices = 0;
  int boost_count = 0;
  
  printf("\n");
  58:	00001517          	auipc	a0,0x1
  5c:	ca850513          	addi	a0,a0,-856 # d00 <malloc+0xfe>
  60:	2ef000ef          	jal	b4e <printf>
  printf("================================================================\n");
  64:	00001517          	auipc	a0,0x1
  68:	ca450513          	addi	a0,a0,-860 # d08 <malloc+0x106>
  6c:	2e3000ef          	jal	b4e <printf>
  printf("     MLFQ BOOST TEST - SINGLE PROCESS DETAILED VIEW\n");
  70:	00001517          	auipc	a0,0x1
  74:	ce050513          	addi	a0,a0,-800 # d50 <malloc+0x14e>
  78:	2d7000ef          	jal	b4e <printf>
  printf("================================================================\n");
  7c:	00001517          	auipc	a0,0x1
  80:	c8c50513          	addi	a0,a0,-884 # d08 <malloc+0x106>
  84:	2cb000ef          	jal	b4e <printf>
  printf("  Time Quanta: Q0=2, Q1=4, Q2=8, Q3=16 ticks\n");
  88:	00001517          	auipc	a0,0x1
  8c:	d0050513          	addi	a0,a0,-768 # d88 <malloc+0x186>
  90:	2bf000ef          	jal	b4e <printf>
  printf("  Boost Interval: Every 50 ticks all processes -> Q0\n");
  94:	00001517          	auipc	a0,0x1
  98:	d2450513          	addi	a0,a0,-732 # db8 <malloc+0x1b6>
  9c:	2b3000ef          	jal	b4e <printf>
  printf("  Key Test: Q3 stays at Q3 even after 16+ slices until BOOST\n");
  a0:	00001517          	auipc	a0,0x1
  a4:	d5050513          	addi	a0,a0,-688 # df0 <malloc+0x1ee>
  a8:	2a7000ef          	jal	b4e <printf>
  printf("================================================================\n\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	d8450513          	addi	a0,a0,-636 # e30 <malloc+0x22e>
  b4:	29b000ef          	jal	b4e <printf>
  
  start_tick = uptime();
  b8:	6f6000ef          	jal	7ae <uptime>
  bc:	8a2a                	mv	s4,a0
  printf("[DEBUG] Test started at global tick: %d\n", start_tick);
  be:	85aa                	mv	a1,a0
  c0:	00001517          	auipc	a0,0x1
  c4:	db850513          	addi	a0,a0,-584 # e78 <malloc+0x276>
  c8:	287000ef          	jal	b4e <printf>
  getprocinfo(&info);
  cc:	f8040513          	addi	a0,s0,-128
  d0:	6e6000ef          	jal	7b6 <getprocinfo>
  last_priority = info.priority;
  d4:	f8842983          	lw	s3,-120(s0)
  last_slices = info.time_slices;
  d8:	f8c42c03          	lw	s8,-116(s0)
  
  printf("  TICK | QUEUE | SLICES | EVENT\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	dcc50513          	addi	a0,a0,-564 # ea8 <malloc+0x2a6>
  e4:	26b000ef          	jal	b4e <printf>
  printf("  -----+-------+--------+----------------------------------------\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	de850513          	addi	a0,a0,-536 # ed0 <malloc+0x2ce>
  f0:	25f000ef          	jal	b4e <printf>
  int reached_q3 = 0;
  int q3_extra_shown = 0;
  int first_boost_seen = 0;
  
  // Run until we see 3 boosts (print after 1st boost, track 2 more)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
  f4:	4481                	li	s1,0
  int first_boost_seen = 0;
  f6:	4a81                	li	s5,0
  int q3_extra_shown = 0;
  f8:	f6043023          	sd	zero,-160(s0)
  int reached_q3 = 0;
  fc:	f6043423          	sd	zero,-152(s0)
  int boost_count = 0;
 100:	4d01                	li	s10,0
    int tick_before_work = uptime();
    cpu_work(WORK_ITERATIONS / 5);
 102:	000f4bb7          	lui	s7,0xf4
 106:	240b8b93          	addi	s7,s7,576 # f4240 <base+0xf2230>
    getprocinfo(&info);
    int current_tick = uptime() - start_tick;
    int global_tick = uptime();
    
    // Debug: show tick progression every 10 phases (to avoid spam)
    if(phase % 50 == 0) {
 10a:	03200b13          	li	s6,50
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
 10e:	7d000c93          	li	s9,2000
        reached_q3 = 0;
        q3_extra_shown = 0;
      }
    }
    // Show slice progression at Q3 (especially when slices > 16) - only after first boost
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 112:	4d8d                	li	s11,3
 114:	a099                	j	15a <main+0x120>
      printf("[DEBUG] phase=%d | before_work=%d | after_work=%d | global=%d | relative=%d\n",
 116:	87ca                	mv	a5,s2
 118:	872a                	mv	a4,a0
 11a:	f7043683          	ld	a3,-144(s0)
 11e:	f7843603          	ld	a2,-136(s0)
 122:	85a6                	mv	a1,s1
 124:	00001517          	auipc	a0,0x1
 128:	df450513          	addi	a0,a0,-524 # f18 <malloc+0x316>
 12c:	223000ef          	jal	b4e <printf>
 130:	a8a9                	j	18a <main+0x150>
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 132:	87b2                	mv	a5,a2
 134:	874e                	mv	a4,s3
 136:	85ca                	mv	a1,s2
 138:	00001517          	auipc	a0,0x1
 13c:	e3050513          	addi	a0,a0,-464 # f68 <malloc+0x366>
 140:	20f000ef          	jal	b4e <printf>
          if(info.priority == 3 && !reached_q3) {
 144:	f8842783          	lw	a5,-120(s0)
 148:	07b78463          	beq	a5,s11,1b0 <main+0x176>
      printf("   %d  |  Q%d   |    %d   | Running at Q%d (slices: %d)\n",
             current_tick, info.priority, info.time_slices, 
             info.priority, info.time_slices);
    }
    
    last_priority = info.priority;
 14c:	f8842983          	lw	s3,-120(s0)
    last_slices = info.time_slices;
 150:	f8c42c03          	lw	s8,-116(s0)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
 154:	2485                	addiw	s1,s1,1
 156:	1d948363          	beq	s1,s9,31c <main+0x2e2>
    int tick_before_work = uptime();
 15a:	654000ef          	jal	7ae <uptime>
 15e:	f6a43c23          	sd	a0,-136(s0)
    cpu_work(WORK_ITERATIONS / 5);
 162:	855e                	mv	a0,s7
 164:	e9dff0ef          	jal	0 <cpu_work>
    int tick_after_work = uptime();
 168:	646000ef          	jal	7ae <uptime>
 16c:	f6a43823          	sd	a0,-144(s0)
    getprocinfo(&info);
 170:	f8040513          	addi	a0,s0,-128
 174:	642000ef          	jal	7b6 <getprocinfo>
    int current_tick = uptime() - start_tick;
 178:	636000ef          	jal	7ae <uptime>
 17c:	4145093b          	subw	s2,a0,s4
    int global_tick = uptime();
 180:	62e000ef          	jal	7ae <uptime>
    if(phase % 50 == 0) {
 184:	0364e7bb          	remw	a5,s1,s6
 188:	d7d9                	beqz	a5,116 <main+0xdc>
    if(info.priority != last_priority) {
 18a:	f8842603          	lw	a2,-120(s0)
 18e:	11360363          	beq	a2,s3,294 <main+0x25a>
      if(info.priority > last_priority) {
 192:	04c9da63          	bge	s3,a2,1e6 <main+0x1ac>
        if(first_boost_seen) {
 196:	fa0a8be3          	beqz	s5,14c <main+0x112>
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 19a:	f8c42683          	lw	a3,-116(s0)
 19e:	4809                	li	a6,2
 1a0:	f80989e3          	beqz	s3,132 <main+0xf8>
                 last_priority == 0 ? 2 : (last_priority == 1 ? 4 : 8));
 1a4:	4785                	li	a5,1
 1a6:	4821                	li	a6,8
 1a8:	f8f995e3          	bne	s3,a5,132 <main+0xf8>
 1ac:	4811                	li	a6,4
 1ae:	b751                	j	132 <main+0xf8>
          if(info.priority == 3 && !reached_q3) {
 1b0:	f6843783          	ld	a5,-152(s0)
 1b4:	c781                	beqz	a5,1bc <main+0x182>
 1b6:	f6843a83          	ld	s5,-152(s0)
 1ba:	bf49                	j	14c <main+0x112>
            printf("  -----+-------+--------+----------------------------------------\n");
 1bc:	00001517          	auipc	a0,0x1
 1c0:	d1450513          	addi	a0,a0,-748 # ed0 <malloc+0x2ce>
 1c4:	18b000ef          	jal	b4e <printf>
            printf("  >>> Now at LOWEST priority (Q3) - will stay here until BOOST <<<\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	de050513          	addi	a0,a0,-544 # fa8 <malloc+0x3a6>
 1d0:	17f000ef          	jal	b4e <printf>
            printf("  -----+-------+--------+----------------------------------------\n");
 1d4:	00001517          	auipc	a0,0x1
 1d8:	cfc50513          	addi	a0,a0,-772 # ed0 <malloc+0x2ce>
 1dc:	173000ef          	jal	b4e <printf>
            reached_q3 = 1;
 1e0:	f7543423          	sd	s5,-152(s0)
 1e4:	b7a5                	j	14c <main+0x112>
        boost_count++;
 1e6:	2d05                	addiw	s10,s10,1
        int boost_global = uptime();
 1e8:	5c6000ef          	jal	7ae <uptime>
 1ec:	8c2a                	mv	s8,a0
        printf("[DEBUG] BOOST DETECTED! global_tick=%d | relative=%d | expected_boost_at=50,100,150...\n",
 1ee:	864a                	mv	a2,s2
 1f0:	85aa                	mv	a1,a0
 1f2:	00001517          	auipc	a0,0x1
 1f6:	dfe50513          	addi	a0,a0,-514 # ff0 <malloc+0x3ee>
 1fa:	155000ef          	jal	b4e <printf>
        printf("[DEBUG] Boost should occur when (global_tick - 0) >= 50, i.e., at global tick 50, 100, etc.\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	e4a50513          	addi	a0,a0,-438 # 1048 <malloc+0x446>
 206:	149000ef          	jal	b4e <printf>
        printf("[DEBUG] Detection delay = global_tick mod 50 = %d ticks\n", boost_global % 50);
 20a:	036c65bb          	remw	a1,s8,s6
 20e:	00001517          	auipc	a0,0x1
 212:	e9a50513          	addi	a0,a0,-358 # 10a8 <malloc+0x4a6>
 216:	139000ef          	jal	b4e <printf>
        if(!first_boost_seen) {
 21a:	040a9363          	bnez	s5,260 <main+0x226>
          printf("   %d  |  Q%d   |    %d   | *** BOOST #1 - START TRACKING ***\n",
 21e:	f8c42683          	lw	a3,-116(s0)
 222:	f8842603          	lw	a2,-120(s0)
 226:	85ca                	mv	a1,s2
 228:	00001517          	auipc	a0,0x1
 22c:	ec050513          	addi	a0,a0,-320 # 10e8 <malloc+0x4e6>
 230:	11f000ef          	jal	b4e <printf>
          printf("  -----+-------+--------+----------------------------------------\n");
 234:	00001517          	auipc	a0,0x1
 238:	c9c50513          	addi	a0,a0,-868 # ed0 <malloc+0x2ce>
 23c:	113000ef          	jal	b4e <printf>
    last_priority = info.priority;
 240:	f8842983          	lw	s3,-120(s0)
    last_slices = info.time_slices;
 244:	f8c42c03          	lw	s8,-116(s0)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
 248:	2485                	addiw	s1,s1,1
 24a:	0d948963          	beq	s1,s9,31c <main+0x2e2>
 24e:	4789                	li	a5,2
 250:	15a7cb63          	blt	a5,s10,3a6 <main+0x36c>
 254:	4a85                	li	s5,1
 256:	f6043023          	sd	zero,-160(s0)
 25a:	f6043423          	sd	zero,-152(s0)
 25e:	bdf5                	j	15a <main+0x120>
          printf("  -----+-------+--------+----------------------------------------\n");
 260:	00001517          	auipc	a0,0x1
 264:	c7050513          	addi	a0,a0,-912 # ed0 <malloc+0x2ce>
 268:	0e7000ef          	jal	b4e <printf>
          printf("   %d  |  Q%d   |    %d   | *** BOOST #%d! Q%d->Q0 ***\n",
 26c:	87ce                	mv	a5,s3
 26e:	876a                	mv	a4,s10
 270:	f8c42683          	lw	a3,-116(s0)
 274:	f8842603          	lw	a2,-120(s0)
 278:	85ca                	mv	a1,s2
 27a:	00001517          	auipc	a0,0x1
 27e:	eae50513          	addi	a0,a0,-338 # 1128 <malloc+0x526>
 282:	0cd000ef          	jal	b4e <printf>
          printf("  -----+-------+--------+----------------------------------------\n");
 286:	00001517          	auipc	a0,0x1
 28a:	c4a50513          	addi	a0,a0,-950 # ed0 <malloc+0x2ce>
 28e:	0c1000ef          	jal	b4e <printf>
 292:	b77d                	j	240 <main+0x206>
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 294:	ea0a8ce3          	beqz	s5,14c <main+0x112>
 298:	03b98463          	beq	s3,s11,2c0 <main+0x286>
    else if(first_boost_seen && info.priority < 3 && info.time_slices != last_slices) {
 29c:	4789                	li	a5,2
 29e:	eb37c7e3          	blt	a5,s3,14c <main+0x112>
 2a2:	f8c42683          	lw	a3,-116(s0)
 2a6:	eb8683e3          	beq	a3,s8,14c <main+0x112>
      printf("   %d  |  Q%d   |    %d   | Running at Q%d (slices: %d)\n",
 2aa:	87b6                	mv	a5,a3
 2ac:	874e                	mv	a4,s3
 2ae:	864e                	mv	a2,s3
 2b0:	85ca                	mv	a1,s2
 2b2:	00001517          	auipc	a0,0x1
 2b6:	f3650513          	addi	a0,a0,-202 # 11e8 <malloc+0x5e6>
 2ba:	095000ef          	jal	b4e <printf>
 2be:	b579                	j	14c <main+0x112>
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 2c0:	f8c42683          	lw	a3,-116(s0)
 2c4:	e98684e3          	beq	a3,s8,14c <main+0x112>
      if(info.time_slices <= 16 && info.time_slices % 2 == 0) {
 2c8:	47c1                	li	a5,16
 2ca:	02d7c563          	blt	a5,a3,2f4 <main+0x2ba>
 2ce:	0016f793          	andi	a5,a3,1
 2d2:	c399                	beqz	a5,2d8 <main+0x29e>
 2d4:	8abe                	mv	s5,a5
 2d6:	bd9d                	j	14c <main+0x112>
        printf("   %d  |  Q%d   |   %d   | Waiting at Q3 (slices: %d/16)\n",
 2d8:	8736                	mv	a4,a3
 2da:	460d                	li	a2,3
 2dc:	85ca                	mv	a1,s2
 2de:	00001517          	auipc	a0,0x1
 2e2:	e8250513          	addi	a0,a0,-382 # 1160 <malloc+0x55e>
 2e6:	069000ef          	jal	b4e <printf>
      if(info.time_slices > 16 && q3_extra_shown < 5) {
 2ea:	f8c42683          	lw	a3,-116(s0)
 2ee:	47c1                	li	a5,16
 2f0:	e4d7dee3          	bge	a5,a3,14c <main+0x112>
 2f4:	4791                	li	a5,4
 2f6:	f6043703          	ld	a4,-160(s0)
 2fa:	e4e7c9e3          	blt	a5,a4,14c <main+0x112>
        printf("   %d  |  Q%d   |   %d   | STILL Q3! (slices > 16, waiting for boost)\n",
 2fe:	f8842603          	lw	a2,-120(s0)
 302:	85ca                	mv	a1,s2
 304:	00001517          	auipc	a0,0x1
 308:	e9c50513          	addi	a0,a0,-356 # 11a0 <malloc+0x59e>
 30c:	043000ef          	jal	b4e <printf>
        q3_extra_shown++;
 310:	f6043783          	ld	a5,-160(s0)
 314:	2785                	addiw	a5,a5,1
 316:	f6f43023          	sd	a5,-160(s0)
 31a:	bd0d                	j	14c <main+0x112>
  }
  
  printf("\n");
 31c:	00001517          	auipc	a0,0x1
 320:	9e450513          	addi	a0,a0,-1564 # d00 <malloc+0xfe>
 324:	02b000ef          	jal	b4e <printf>
  printf("================================================================\n");
 328:	00001517          	auipc	a0,0x1
 32c:	9e050513          	addi	a0,a0,-1568 # d08 <malloc+0x106>
 330:	01f000ef          	jal	b4e <printf>
  printf("                      TEST SUMMARY\n");
 334:	00001517          	auipc	a0,0x1
 338:	ef450513          	addi	a0,a0,-268 # 1228 <malloc+0x626>
 33c:	013000ef          	jal	b4e <printf>
  printf("================================================================\n");
 340:	00001517          	auipc	a0,0x1
 344:	9c850513          	addi	a0,a0,-1592 # d08 <malloc+0x106>
 348:	007000ef          	jal	b4e <printf>
  int total = uptime() - start_tick;
 34c:	462000ef          	jal	7ae <uptime>
 350:	414505bb          	subw	a1,a0,s4
  printf("  Total Runtime   : %d ticks (~%d.%d seconds)\n", 
 354:	4629                	li	a2,10
 356:	02c5e6bb          	remw	a3,a1,a2
 35a:	02c5c63b          	divw	a2,a1,a2
 35e:	2581                	sext.w	a1,a1
 360:	00001517          	auipc	a0,0x1
 364:	ef050513          	addi	a0,a0,-272 # 1250 <malloc+0x64e>
 368:	7e6000ef          	jal	b4e <printf>
         total, total/10, total%10);
  printf("  Boost Events    : %d automatic boosts detected\n", boost_count);
 36c:	85ea                	mv	a1,s10
 36e:	00001517          	auipc	a0,0x1
 372:	f1250513          	addi	a0,a0,-238 # 1280 <malloc+0x67e>
 376:	7d8000ef          	jal	b4e <printf>
  printf("  Expected Interval: ~50 ticks between boosts\n");
 37a:	00001517          	auipc	a0,0x1
 37e:	f3e50513          	addi	a0,a0,-194 # 12b8 <malloc+0x6b6>
 382:	7cc000ef          	jal	b4e <printf>
  printf("----------------------------------------------------------------\n");
 386:	00001517          	auipc	a0,0x1
 38a:	f6250513          	addi	a0,a0,-158 # 12e8 <malloc+0x6e6>
 38e:	7c0000ef          	jal	b4e <printf>
  if(boost_count >= 3) {
 392:	4789                	li	a5,2
 394:	09a7c463          	blt	a5,s10,41c <main+0x3e2>
    printf("    2. Staying at Q3 until boost interval\n");
    printf("    3. Q3 STAYS Q3 even after 16+ slices (no further demotion)\n");
    printf("    4. Automatic boost back to Q0 (starvation prevention)\n");
    printf("    5. Multiple boost cycles confirming periodic boosting\n");
  } else {
    printf("  Test incomplete - try running longer\n");
 398:	00001517          	auipc	a0,0x1
 39c:	12050513          	addi	a0,a0,288 # 14b8 <malloc+0x8b6>
 3a0:	7ae000ef          	jal	b4e <printf>
 3a4:	a0f1                	j	470 <main+0x436>
  printf("\n");
 3a6:	00001517          	auipc	a0,0x1
 3aa:	95a50513          	addi	a0,a0,-1702 # d00 <malloc+0xfe>
 3ae:	7a0000ef          	jal	b4e <printf>
  printf("================================================================\n");
 3b2:	00001517          	auipc	a0,0x1
 3b6:	95650513          	addi	a0,a0,-1706 # d08 <malloc+0x106>
 3ba:	794000ef          	jal	b4e <printf>
  printf("                      TEST SUMMARY\n");
 3be:	00001517          	auipc	a0,0x1
 3c2:	e6a50513          	addi	a0,a0,-406 # 1228 <malloc+0x626>
 3c6:	788000ef          	jal	b4e <printf>
  printf("================================================================\n");
 3ca:	00001517          	auipc	a0,0x1
 3ce:	93e50513          	addi	a0,a0,-1730 # d08 <malloc+0x106>
 3d2:	77c000ef          	jal	b4e <printf>
  int total = uptime() - start_tick;
 3d6:	3d8000ef          	jal	7ae <uptime>
 3da:	414505bb          	subw	a1,a0,s4
  printf("  Total Runtime   : %d ticks (~%d.%d seconds)\n", 
 3de:	4629                	li	a2,10
 3e0:	02c5e6bb          	remw	a3,a1,a2
 3e4:	02c5c63b          	divw	a2,a1,a2
 3e8:	2581                	sext.w	a1,a1
 3ea:	00001517          	auipc	a0,0x1
 3ee:	e6650513          	addi	a0,a0,-410 # 1250 <malloc+0x64e>
 3f2:	75c000ef          	jal	b4e <printf>
  printf("  Boost Events    : %d automatic boosts detected\n", boost_count);
 3f6:	85ea                	mv	a1,s10
 3f8:	00001517          	auipc	a0,0x1
 3fc:	e8850513          	addi	a0,a0,-376 # 1280 <malloc+0x67e>
 400:	74e000ef          	jal	b4e <printf>
  printf("  Expected Interval: ~50 ticks between boosts\n");
 404:	00001517          	auipc	a0,0x1
 408:	eb450513          	addi	a0,a0,-332 # 12b8 <malloc+0x6b6>
 40c:	742000ef          	jal	b4e <printf>
  printf("----------------------------------------------------------------\n");
 410:	00001517          	auipc	a0,0x1
 414:	ed850513          	addi	a0,a0,-296 # 12e8 <malloc+0x6e6>
 418:	736000ef          	jal	b4e <printf>
    printf("  SUCCESS: Priority boosting is working correctly!\n\n");
 41c:	00001517          	auipc	a0,0x1
 420:	f1450513          	addi	a0,a0,-236 # 1330 <malloc+0x72e>
 424:	72a000ef          	jal	b4e <printf>
    printf("  The test demonstrated:\n");
 428:	00001517          	auipc	a0,0x1
 42c:	f4050513          	addi	a0,a0,-192 # 1368 <malloc+0x766>
 430:	71e000ef          	jal	b4e <printf>
    printf("    1. Demotion: Q0 -> Q1 -> Q2 -> Q3 (CPU-bound behavior)\n");
 434:	00001517          	auipc	a0,0x1
 438:	f5450513          	addi	a0,a0,-172 # 1388 <malloc+0x786>
 43c:	712000ef          	jal	b4e <printf>
    printf("    2. Staying at Q3 until boost interval\n");
 440:	00001517          	auipc	a0,0x1
 444:	f8850513          	addi	a0,a0,-120 # 13c8 <malloc+0x7c6>
 448:	706000ef          	jal	b4e <printf>
    printf("    3. Q3 STAYS Q3 even after 16+ slices (no further demotion)\n");
 44c:	00001517          	auipc	a0,0x1
 450:	fac50513          	addi	a0,a0,-84 # 13f8 <malloc+0x7f6>
 454:	6fa000ef          	jal	b4e <printf>
    printf("    4. Automatic boost back to Q0 (starvation prevention)\n");
 458:	00001517          	auipc	a0,0x1
 45c:	fe050513          	addi	a0,a0,-32 # 1438 <malloc+0x836>
 460:	6ee000ef          	jal	b4e <printf>
    printf("    5. Multiple boost cycles confirming periodic boosting\n");
 464:	00001517          	auipc	a0,0x1
 468:	01450513          	addi	a0,a0,20 # 1478 <malloc+0x876>
 46c:	6e2000ef          	jal	b4e <printf>
  }
  printf("================================================================\n\n");
 470:	00001517          	auipc	a0,0x1
 474:	9c050513          	addi	a0,a0,-1600 # e30 <malloc+0x22e>
 478:	6d6000ef          	jal	b4e <printf>
  
  exit(0);
 47c:	4501                	li	a0,0
 47e:	298000ef          	jal	716 <exit>

0000000000000482 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 482:	1141                	addi	sp,sp,-16
 484:	e406                	sd	ra,8(sp)
 486:	e022                	sd	s0,0(sp)
 488:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 48a:	bb1ff0ef          	jal	3a <main>
  exit(r);
 48e:	288000ef          	jal	716 <exit>

0000000000000492 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 492:	1141                	addi	sp,sp,-16
 494:	e422                	sd	s0,8(sp)
 496:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 498:	87aa                	mv	a5,a0
 49a:	0585                	addi	a1,a1,1
 49c:	0785                	addi	a5,a5,1
 49e:	fff5c703          	lbu	a4,-1(a1)
 4a2:	fee78fa3          	sb	a4,-1(a5)
 4a6:	fb75                	bnez	a4,49a <strcpy+0x8>
    ;
  return os;
}
 4a8:	6422                	ld	s0,8(sp)
 4aa:	0141                	addi	sp,sp,16
 4ac:	8082                	ret

00000000000004ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4ae:	1141                	addi	sp,sp,-16
 4b0:	e422                	sd	s0,8(sp)
 4b2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4b4:	00054783          	lbu	a5,0(a0)
 4b8:	cb91                	beqz	a5,4cc <strcmp+0x1e>
 4ba:	0005c703          	lbu	a4,0(a1)
 4be:	00f71763          	bne	a4,a5,4cc <strcmp+0x1e>
    p++, q++;
 4c2:	0505                	addi	a0,a0,1
 4c4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4c6:	00054783          	lbu	a5,0(a0)
 4ca:	fbe5                	bnez	a5,4ba <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4cc:	0005c503          	lbu	a0,0(a1)
}
 4d0:	40a7853b          	subw	a0,a5,a0
 4d4:	6422                	ld	s0,8(sp)
 4d6:	0141                	addi	sp,sp,16
 4d8:	8082                	ret

00000000000004da <strlen>:

uint
strlen(const char *s)
{
 4da:	1141                	addi	sp,sp,-16
 4dc:	e422                	sd	s0,8(sp)
 4de:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4e0:	00054783          	lbu	a5,0(a0)
 4e4:	cf91                	beqz	a5,500 <strlen+0x26>
 4e6:	0505                	addi	a0,a0,1
 4e8:	87aa                	mv	a5,a0
 4ea:	86be                	mv	a3,a5
 4ec:	0785                	addi	a5,a5,1
 4ee:	fff7c703          	lbu	a4,-1(a5)
 4f2:	ff65                	bnez	a4,4ea <strlen+0x10>
 4f4:	40a6853b          	subw	a0,a3,a0
 4f8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 4fa:	6422                	ld	s0,8(sp)
 4fc:	0141                	addi	sp,sp,16
 4fe:	8082                	ret
  for(n = 0; s[n]; n++)
 500:	4501                	li	a0,0
 502:	bfe5                	j	4fa <strlen+0x20>

0000000000000504 <memset>:

void*
memset(void *dst, int c, uint n)
{
 504:	1141                	addi	sp,sp,-16
 506:	e422                	sd	s0,8(sp)
 508:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 50a:	ca19                	beqz	a2,520 <memset+0x1c>
 50c:	87aa                	mv	a5,a0
 50e:	1602                	slli	a2,a2,0x20
 510:	9201                	srli	a2,a2,0x20
 512:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 516:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 51a:	0785                	addi	a5,a5,1
 51c:	fee79de3          	bne	a5,a4,516 <memset+0x12>
  }
  return dst;
}
 520:	6422                	ld	s0,8(sp)
 522:	0141                	addi	sp,sp,16
 524:	8082                	ret

0000000000000526 <strchr>:

char*
strchr(const char *s, char c)
{
 526:	1141                	addi	sp,sp,-16
 528:	e422                	sd	s0,8(sp)
 52a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 52c:	00054783          	lbu	a5,0(a0)
 530:	cb99                	beqz	a5,546 <strchr+0x20>
    if(*s == c)
 532:	00f58763          	beq	a1,a5,540 <strchr+0x1a>
  for(; *s; s++)
 536:	0505                	addi	a0,a0,1
 538:	00054783          	lbu	a5,0(a0)
 53c:	fbfd                	bnez	a5,532 <strchr+0xc>
      return (char*)s;
  return 0;
 53e:	4501                	li	a0,0
}
 540:	6422                	ld	s0,8(sp)
 542:	0141                	addi	sp,sp,16
 544:	8082                	ret
  return 0;
 546:	4501                	li	a0,0
 548:	bfe5                	j	540 <strchr+0x1a>

000000000000054a <gets>:

char*
gets(char *buf, int max)
{
 54a:	711d                	addi	sp,sp,-96
 54c:	ec86                	sd	ra,88(sp)
 54e:	e8a2                	sd	s0,80(sp)
 550:	e4a6                	sd	s1,72(sp)
 552:	e0ca                	sd	s2,64(sp)
 554:	fc4e                	sd	s3,56(sp)
 556:	f852                	sd	s4,48(sp)
 558:	f456                	sd	s5,40(sp)
 55a:	f05a                	sd	s6,32(sp)
 55c:	ec5e                	sd	s7,24(sp)
 55e:	1080                	addi	s0,sp,96
 560:	8baa                	mv	s7,a0
 562:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 564:	892a                	mv	s2,a0
 566:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 568:	4aa9                	li	s5,10
 56a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 56c:	89a6                	mv	s3,s1
 56e:	2485                	addiw	s1,s1,1
 570:	0344d663          	bge	s1,s4,59c <gets+0x52>
    cc = read(0, &c, 1);
 574:	4605                	li	a2,1
 576:	faf40593          	addi	a1,s0,-81
 57a:	4501                	li	a0,0
 57c:	1b2000ef          	jal	72e <read>
    if(cc < 1)
 580:	00a05e63          	blez	a0,59c <gets+0x52>
    buf[i++] = c;
 584:	faf44783          	lbu	a5,-81(s0)
 588:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 58c:	01578763          	beq	a5,s5,59a <gets+0x50>
 590:	0905                	addi	s2,s2,1
 592:	fd679de3          	bne	a5,s6,56c <gets+0x22>
    buf[i++] = c;
 596:	89a6                	mv	s3,s1
 598:	a011                	j	59c <gets+0x52>
 59a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 59c:	99de                	add	s3,s3,s7
 59e:	00098023          	sb	zero,0(s3)
  return buf;
}
 5a2:	855e                	mv	a0,s7
 5a4:	60e6                	ld	ra,88(sp)
 5a6:	6446                	ld	s0,80(sp)
 5a8:	64a6                	ld	s1,72(sp)
 5aa:	6906                	ld	s2,64(sp)
 5ac:	79e2                	ld	s3,56(sp)
 5ae:	7a42                	ld	s4,48(sp)
 5b0:	7aa2                	ld	s5,40(sp)
 5b2:	7b02                	ld	s6,32(sp)
 5b4:	6be2                	ld	s7,24(sp)
 5b6:	6125                	addi	sp,sp,96
 5b8:	8082                	ret

00000000000005ba <stat>:

int
stat(const char *n, struct stat *st)
{
 5ba:	1101                	addi	sp,sp,-32
 5bc:	ec06                	sd	ra,24(sp)
 5be:	e822                	sd	s0,16(sp)
 5c0:	e04a                	sd	s2,0(sp)
 5c2:	1000                	addi	s0,sp,32
 5c4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5c6:	4581                	li	a1,0
 5c8:	18e000ef          	jal	756 <open>
  if(fd < 0)
 5cc:	02054263          	bltz	a0,5f0 <stat+0x36>
 5d0:	e426                	sd	s1,8(sp)
 5d2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5d4:	85ca                	mv	a1,s2
 5d6:	198000ef          	jal	76e <fstat>
 5da:	892a                	mv	s2,a0
  close(fd);
 5dc:	8526                	mv	a0,s1
 5de:	160000ef          	jal	73e <close>
  return r;
 5e2:	64a2                	ld	s1,8(sp)
}
 5e4:	854a                	mv	a0,s2
 5e6:	60e2                	ld	ra,24(sp)
 5e8:	6442                	ld	s0,16(sp)
 5ea:	6902                	ld	s2,0(sp)
 5ec:	6105                	addi	sp,sp,32
 5ee:	8082                	ret
    return -1;
 5f0:	597d                	li	s2,-1
 5f2:	bfcd                	j	5e4 <stat+0x2a>

00000000000005f4 <atoi>:

int
atoi(const char *s)
{
 5f4:	1141                	addi	sp,sp,-16
 5f6:	e422                	sd	s0,8(sp)
 5f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5fa:	00054683          	lbu	a3,0(a0)
 5fe:	fd06879b          	addiw	a5,a3,-48
 602:	0ff7f793          	zext.b	a5,a5
 606:	4625                	li	a2,9
 608:	02f66863          	bltu	a2,a5,638 <atoi+0x44>
 60c:	872a                	mv	a4,a0
  n = 0;
 60e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 610:	0705                	addi	a4,a4,1
 612:	0025179b          	slliw	a5,a0,0x2
 616:	9fa9                	addw	a5,a5,a0
 618:	0017979b          	slliw	a5,a5,0x1
 61c:	9fb5                	addw	a5,a5,a3
 61e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 622:	00074683          	lbu	a3,0(a4)
 626:	fd06879b          	addiw	a5,a3,-48
 62a:	0ff7f793          	zext.b	a5,a5
 62e:	fef671e3          	bgeu	a2,a5,610 <atoi+0x1c>
  return n;
}
 632:	6422                	ld	s0,8(sp)
 634:	0141                	addi	sp,sp,16
 636:	8082                	ret
  n = 0;
 638:	4501                	li	a0,0
 63a:	bfe5                	j	632 <atoi+0x3e>

000000000000063c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 63c:	1141                	addi	sp,sp,-16
 63e:	e422                	sd	s0,8(sp)
 640:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 642:	02b57463          	bgeu	a0,a1,66a <memmove+0x2e>
    while(n-- > 0)
 646:	00c05f63          	blez	a2,664 <memmove+0x28>
 64a:	1602                	slli	a2,a2,0x20
 64c:	9201                	srli	a2,a2,0x20
 64e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 652:	872a                	mv	a4,a0
      *dst++ = *src++;
 654:	0585                	addi	a1,a1,1
 656:	0705                	addi	a4,a4,1
 658:	fff5c683          	lbu	a3,-1(a1)
 65c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 660:	fef71ae3          	bne	a4,a5,654 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 664:	6422                	ld	s0,8(sp)
 666:	0141                	addi	sp,sp,16
 668:	8082                	ret
    dst += n;
 66a:	00c50733          	add	a4,a0,a2
    src += n;
 66e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 670:	fec05ae3          	blez	a2,664 <memmove+0x28>
 674:	fff6079b          	addiw	a5,a2,-1
 678:	1782                	slli	a5,a5,0x20
 67a:	9381                	srli	a5,a5,0x20
 67c:	fff7c793          	not	a5,a5
 680:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 682:	15fd                	addi	a1,a1,-1
 684:	177d                	addi	a4,a4,-1
 686:	0005c683          	lbu	a3,0(a1)
 68a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 68e:	fee79ae3          	bne	a5,a4,682 <memmove+0x46>
 692:	bfc9                	j	664 <memmove+0x28>

0000000000000694 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 694:	1141                	addi	sp,sp,-16
 696:	e422                	sd	s0,8(sp)
 698:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 69a:	ca05                	beqz	a2,6ca <memcmp+0x36>
 69c:	fff6069b          	addiw	a3,a2,-1
 6a0:	1682                	slli	a3,a3,0x20
 6a2:	9281                	srli	a3,a3,0x20
 6a4:	0685                	addi	a3,a3,1
 6a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6a8:	00054783          	lbu	a5,0(a0)
 6ac:	0005c703          	lbu	a4,0(a1)
 6b0:	00e79863          	bne	a5,a4,6c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6b4:	0505                	addi	a0,a0,1
    p2++;
 6b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6b8:	fed518e3          	bne	a0,a3,6a8 <memcmp+0x14>
  }
  return 0;
 6bc:	4501                	li	a0,0
 6be:	a019                	j	6c4 <memcmp+0x30>
      return *p1 - *p2;
 6c0:	40e7853b          	subw	a0,a5,a4
}
 6c4:	6422                	ld	s0,8(sp)
 6c6:	0141                	addi	sp,sp,16
 6c8:	8082                	ret
  return 0;
 6ca:	4501                	li	a0,0
 6cc:	bfe5                	j	6c4 <memcmp+0x30>

00000000000006ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6ce:	1141                	addi	sp,sp,-16
 6d0:	e406                	sd	ra,8(sp)
 6d2:	e022                	sd	s0,0(sp)
 6d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6d6:	f67ff0ef          	jal	63c <memmove>
}
 6da:	60a2                	ld	ra,8(sp)
 6dc:	6402                	ld	s0,0(sp)
 6de:	0141                	addi	sp,sp,16
 6e0:	8082                	ret

00000000000006e2 <sbrk>:

char *
sbrk(int n) {
 6e2:	1141                	addi	sp,sp,-16
 6e4:	e406                	sd	ra,8(sp)
 6e6:	e022                	sd	s0,0(sp)
 6e8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 6ea:	4585                	li	a1,1
 6ec:	0b2000ef          	jal	79e <sys_sbrk>
}
 6f0:	60a2                	ld	ra,8(sp)
 6f2:	6402                	ld	s0,0(sp)
 6f4:	0141                	addi	sp,sp,16
 6f6:	8082                	ret

00000000000006f8 <sbrklazy>:

char *
sbrklazy(int n) {
 6f8:	1141                	addi	sp,sp,-16
 6fa:	e406                	sd	ra,8(sp)
 6fc:	e022                	sd	s0,0(sp)
 6fe:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 700:	4589                	li	a1,2
 702:	09c000ef          	jal	79e <sys_sbrk>
}
 706:	60a2                	ld	ra,8(sp)
 708:	6402                	ld	s0,0(sp)
 70a:	0141                	addi	sp,sp,16
 70c:	8082                	ret

000000000000070e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 70e:	4885                	li	a7,1
 ecall
 710:	00000073          	ecall
 ret
 714:	8082                	ret

0000000000000716 <exit>:
.global exit
exit:
 li a7, SYS_exit
 716:	4889                	li	a7,2
 ecall
 718:	00000073          	ecall
 ret
 71c:	8082                	ret

000000000000071e <wait>:
.global wait
wait:
 li a7, SYS_wait
 71e:	488d                	li	a7,3
 ecall
 720:	00000073          	ecall
 ret
 724:	8082                	ret

0000000000000726 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 726:	4891                	li	a7,4
 ecall
 728:	00000073          	ecall
 ret
 72c:	8082                	ret

000000000000072e <read>:
.global read
read:
 li a7, SYS_read
 72e:	4895                	li	a7,5
 ecall
 730:	00000073          	ecall
 ret
 734:	8082                	ret

0000000000000736 <write>:
.global write
write:
 li a7, SYS_write
 736:	48c1                	li	a7,16
 ecall
 738:	00000073          	ecall
 ret
 73c:	8082                	ret

000000000000073e <close>:
.global close
close:
 li a7, SYS_close
 73e:	48d5                	li	a7,21
 ecall
 740:	00000073          	ecall
 ret
 744:	8082                	ret

0000000000000746 <kill>:
.global kill
kill:
 li a7, SYS_kill
 746:	4899                	li	a7,6
 ecall
 748:	00000073          	ecall
 ret
 74c:	8082                	ret

000000000000074e <exec>:
.global exec
exec:
 li a7, SYS_exec
 74e:	489d                	li	a7,7
 ecall
 750:	00000073          	ecall
 ret
 754:	8082                	ret

0000000000000756 <open>:
.global open
open:
 li a7, SYS_open
 756:	48bd                	li	a7,15
 ecall
 758:	00000073          	ecall
 ret
 75c:	8082                	ret

000000000000075e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 75e:	48c5                	li	a7,17
 ecall
 760:	00000073          	ecall
 ret
 764:	8082                	ret

0000000000000766 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 766:	48c9                	li	a7,18
 ecall
 768:	00000073          	ecall
 ret
 76c:	8082                	ret

000000000000076e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 76e:	48a1                	li	a7,8
 ecall
 770:	00000073          	ecall
 ret
 774:	8082                	ret

0000000000000776 <link>:
.global link
link:
 li a7, SYS_link
 776:	48cd                	li	a7,19
 ecall
 778:	00000073          	ecall
 ret
 77c:	8082                	ret

000000000000077e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 77e:	48d1                	li	a7,20
 ecall
 780:	00000073          	ecall
 ret
 784:	8082                	ret

0000000000000786 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 786:	48a5                	li	a7,9
 ecall
 788:	00000073          	ecall
 ret
 78c:	8082                	ret

000000000000078e <dup>:
.global dup
dup:
 li a7, SYS_dup
 78e:	48a9                	li	a7,10
 ecall
 790:	00000073          	ecall
 ret
 794:	8082                	ret

0000000000000796 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 796:	48ad                	li	a7,11
 ecall
 798:	00000073          	ecall
 ret
 79c:	8082                	ret

000000000000079e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 79e:	48b1                	li	a7,12
 ecall
 7a0:	00000073          	ecall
 ret
 7a4:	8082                	ret

00000000000007a6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 7a6:	48b5                	li	a7,13
 ecall
 7a8:	00000073          	ecall
 ret
 7ac:	8082                	ret

00000000000007ae <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7ae:	48b9                	li	a7,14
 ecall
 7b0:	00000073          	ecall
 ret
 7b4:	8082                	ret

00000000000007b6 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 7b6:	48d9                	li	a7,22
 ecall
 7b8:	00000073          	ecall
 ret
 7bc:	8082                	ret

00000000000007be <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 7be:	48dd                	li	a7,23
 ecall
 7c0:	00000073          	ecall
 ret
 7c4:	8082                	ret

00000000000007c6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7c6:	1101                	addi	sp,sp,-32
 7c8:	ec06                	sd	ra,24(sp)
 7ca:	e822                	sd	s0,16(sp)
 7cc:	1000                	addi	s0,sp,32
 7ce:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7d2:	4605                	li	a2,1
 7d4:	fef40593          	addi	a1,s0,-17
 7d8:	f5fff0ef          	jal	736 <write>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6105                	addi	sp,sp,32
 7e2:	8082                	ret

00000000000007e4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 7e4:	715d                	addi	sp,sp,-80
 7e6:	e486                	sd	ra,72(sp)
 7e8:	e0a2                	sd	s0,64(sp)
 7ea:	f84a                	sd	s2,48(sp)
 7ec:	0880                	addi	s0,sp,80
 7ee:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 7f0:	c299                	beqz	a3,7f6 <printint+0x12>
 7f2:	0805c363          	bltz	a1,878 <printint+0x94>
  neg = 0;
 7f6:	4881                	li	a7,0
 7f8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 7fc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 7fe:	00001517          	auipc	a0,0x1
 802:	cea50513          	addi	a0,a0,-790 # 14e8 <digits>
 806:	883e                	mv	a6,a5
 808:	2785                	addiw	a5,a5,1
 80a:	02c5f733          	remu	a4,a1,a2
 80e:	972a                	add	a4,a4,a0
 810:	00074703          	lbu	a4,0(a4)
 814:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 818:	872e                	mv	a4,a1
 81a:	02c5d5b3          	divu	a1,a1,a2
 81e:	0685                	addi	a3,a3,1
 820:	fec773e3          	bgeu	a4,a2,806 <printint+0x22>
  if(neg)
 824:	00088b63          	beqz	a7,83a <printint+0x56>
    buf[i++] = '-';
 828:	fd078793          	addi	a5,a5,-48
 82c:	97a2                	add	a5,a5,s0
 82e:	02d00713          	li	a4,45
 832:	fee78423          	sb	a4,-24(a5)
 836:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 83a:	02f05a63          	blez	a5,86e <printint+0x8a>
 83e:	fc26                	sd	s1,56(sp)
 840:	f44e                	sd	s3,40(sp)
 842:	fb840713          	addi	a4,s0,-72
 846:	00f704b3          	add	s1,a4,a5
 84a:	fff70993          	addi	s3,a4,-1
 84e:	99be                	add	s3,s3,a5
 850:	37fd                	addiw	a5,a5,-1
 852:	1782                	slli	a5,a5,0x20
 854:	9381                	srli	a5,a5,0x20
 856:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 85a:	fff4c583          	lbu	a1,-1(s1)
 85e:	854a                	mv	a0,s2
 860:	f67ff0ef          	jal	7c6 <putc>
  while(--i >= 0)
 864:	14fd                	addi	s1,s1,-1
 866:	ff349ae3          	bne	s1,s3,85a <printint+0x76>
 86a:	74e2                	ld	s1,56(sp)
 86c:	79a2                	ld	s3,40(sp)
}
 86e:	60a6                	ld	ra,72(sp)
 870:	6406                	ld	s0,64(sp)
 872:	7942                	ld	s2,48(sp)
 874:	6161                	addi	sp,sp,80
 876:	8082                	ret
    x = -xx;
 878:	40b005b3          	neg	a1,a1
    neg = 1;
 87c:	4885                	li	a7,1
    x = -xx;
 87e:	bfad                	j	7f8 <printint+0x14>

0000000000000880 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 880:	711d                	addi	sp,sp,-96
 882:	ec86                	sd	ra,88(sp)
 884:	e8a2                	sd	s0,80(sp)
 886:	e0ca                	sd	s2,64(sp)
 888:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 88a:	0005c903          	lbu	s2,0(a1)
 88e:	28090663          	beqz	s2,b1a <vprintf+0x29a>
 892:	e4a6                	sd	s1,72(sp)
 894:	fc4e                	sd	s3,56(sp)
 896:	f852                	sd	s4,48(sp)
 898:	f456                	sd	s5,40(sp)
 89a:	f05a                	sd	s6,32(sp)
 89c:	ec5e                	sd	s7,24(sp)
 89e:	e862                	sd	s8,16(sp)
 8a0:	e466                	sd	s9,8(sp)
 8a2:	8b2a                	mv	s6,a0
 8a4:	8a2e                	mv	s4,a1
 8a6:	8bb2                	mv	s7,a2
  state = 0;
 8a8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 8aa:	4481                	li	s1,0
 8ac:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 8ae:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 8b2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 8b6:	06c00c93          	li	s9,108
 8ba:	a005                	j	8da <vprintf+0x5a>
        putc(fd, c0);
 8bc:	85ca                	mv	a1,s2
 8be:	855a                	mv	a0,s6
 8c0:	f07ff0ef          	jal	7c6 <putc>
 8c4:	a019                	j	8ca <vprintf+0x4a>
    } else if(state == '%'){
 8c6:	03598263          	beq	s3,s5,8ea <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 8ca:	2485                	addiw	s1,s1,1
 8cc:	8726                	mv	a4,s1
 8ce:	009a07b3          	add	a5,s4,s1
 8d2:	0007c903          	lbu	s2,0(a5)
 8d6:	22090a63          	beqz	s2,b0a <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 8da:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8de:	fe0994e3          	bnez	s3,8c6 <vprintf+0x46>
      if(c0 == '%'){
 8e2:	fd579de3          	bne	a5,s5,8bc <vprintf+0x3c>
        state = '%';
 8e6:	89be                	mv	s3,a5
 8e8:	b7cd                	j	8ca <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 8ea:	00ea06b3          	add	a3,s4,a4
 8ee:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 8f2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 8f4:	c681                	beqz	a3,8fc <vprintf+0x7c>
 8f6:	9752                	add	a4,a4,s4
 8f8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 8fc:	05878363          	beq	a5,s8,942 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 900:	05978d63          	beq	a5,s9,95a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 904:	07500713          	li	a4,117
 908:	0ee78763          	beq	a5,a4,9f6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 90c:	07800713          	li	a4,120
 910:	12e78963          	beq	a5,a4,a42 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 914:	07000713          	li	a4,112
 918:	14e78e63          	beq	a5,a4,a74 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 91c:	06300713          	li	a4,99
 920:	18e78e63          	beq	a5,a4,abc <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 924:	07300713          	li	a4,115
 928:	1ae78463          	beq	a5,a4,ad0 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 92c:	02500713          	li	a4,37
 930:	04e79563          	bne	a5,a4,97a <vprintf+0xfa>
        putc(fd, '%');
 934:	02500593          	li	a1,37
 938:	855a                	mv	a0,s6
 93a:	e8dff0ef          	jal	7c6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 93e:	4981                	li	s3,0
 940:	b769                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 942:	008b8913          	addi	s2,s7,8
 946:	4685                	li	a3,1
 948:	4629                	li	a2,10
 94a:	000ba583          	lw	a1,0(s7)
 94e:	855a                	mv	a0,s6
 950:	e95ff0ef          	jal	7e4 <printint>
 954:	8bca                	mv	s7,s2
      state = 0;
 956:	4981                	li	s3,0
 958:	bf8d                	j	8ca <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 95a:	06400793          	li	a5,100
 95e:	02f68963          	beq	a3,a5,990 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 962:	06c00793          	li	a5,108
 966:	04f68263          	beq	a3,a5,9aa <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 96a:	07500793          	li	a5,117
 96e:	0af68063          	beq	a3,a5,a0e <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 972:	07800793          	li	a5,120
 976:	0ef68263          	beq	a3,a5,a5a <vprintf+0x1da>
        putc(fd, '%');
 97a:	02500593          	li	a1,37
 97e:	855a                	mv	a0,s6
 980:	e47ff0ef          	jal	7c6 <putc>
        putc(fd, c0);
 984:	85ca                	mv	a1,s2
 986:	855a                	mv	a0,s6
 988:	e3fff0ef          	jal	7c6 <putc>
      state = 0;
 98c:	4981                	li	s3,0
 98e:	bf35                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 990:	008b8913          	addi	s2,s7,8
 994:	4685                	li	a3,1
 996:	4629                	li	a2,10
 998:	000bb583          	ld	a1,0(s7)
 99c:	855a                	mv	a0,s6
 99e:	e47ff0ef          	jal	7e4 <printint>
        i += 1;
 9a2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 9a4:	8bca                	mv	s7,s2
      state = 0;
 9a6:	4981                	li	s3,0
        i += 1;
 9a8:	b70d                	j	8ca <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 9aa:	06400793          	li	a5,100
 9ae:	02f60763          	beq	a2,a5,9dc <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 9b2:	07500793          	li	a5,117
 9b6:	06f60963          	beq	a2,a5,a28 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 9ba:	07800793          	li	a5,120
 9be:	faf61ee3          	bne	a2,a5,97a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 9c2:	008b8913          	addi	s2,s7,8
 9c6:	4681                	li	a3,0
 9c8:	4641                	li	a2,16
 9ca:	000bb583          	ld	a1,0(s7)
 9ce:	855a                	mv	a0,s6
 9d0:	e15ff0ef          	jal	7e4 <printint>
        i += 2;
 9d4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 9d6:	8bca                	mv	s7,s2
      state = 0;
 9d8:	4981                	li	s3,0
        i += 2;
 9da:	bdc5                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 9dc:	008b8913          	addi	s2,s7,8
 9e0:	4685                	li	a3,1
 9e2:	4629                	li	a2,10
 9e4:	000bb583          	ld	a1,0(s7)
 9e8:	855a                	mv	a0,s6
 9ea:	dfbff0ef          	jal	7e4 <printint>
        i += 2;
 9ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 9f0:	8bca                	mv	s7,s2
      state = 0;
 9f2:	4981                	li	s3,0
        i += 2;
 9f4:	bdd9                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 9f6:	008b8913          	addi	s2,s7,8
 9fa:	4681                	li	a3,0
 9fc:	4629                	li	a2,10
 9fe:	000be583          	lwu	a1,0(s7)
 a02:	855a                	mv	a0,s6
 a04:	de1ff0ef          	jal	7e4 <printint>
 a08:	8bca                	mv	s7,s2
      state = 0;
 a0a:	4981                	li	s3,0
 a0c:	bd7d                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a0e:	008b8913          	addi	s2,s7,8
 a12:	4681                	li	a3,0
 a14:	4629                	li	a2,10
 a16:	000bb583          	ld	a1,0(s7)
 a1a:	855a                	mv	a0,s6
 a1c:	dc9ff0ef          	jal	7e4 <printint>
        i += 1;
 a20:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 a22:	8bca                	mv	s7,s2
      state = 0;
 a24:	4981                	li	s3,0
        i += 1;
 a26:	b555                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a28:	008b8913          	addi	s2,s7,8
 a2c:	4681                	li	a3,0
 a2e:	4629                	li	a2,10
 a30:	000bb583          	ld	a1,0(s7)
 a34:	855a                	mv	a0,s6
 a36:	dafff0ef          	jal	7e4 <printint>
        i += 2;
 a3a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 a3c:	8bca                	mv	s7,s2
      state = 0;
 a3e:	4981                	li	s3,0
        i += 2;
 a40:	b569                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 a42:	008b8913          	addi	s2,s7,8
 a46:	4681                	li	a3,0
 a48:	4641                	li	a2,16
 a4a:	000be583          	lwu	a1,0(s7)
 a4e:	855a                	mv	a0,s6
 a50:	d95ff0ef          	jal	7e4 <printint>
 a54:	8bca                	mv	s7,s2
      state = 0;
 a56:	4981                	li	s3,0
 a58:	bd8d                	j	8ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a5a:	008b8913          	addi	s2,s7,8
 a5e:	4681                	li	a3,0
 a60:	4641                	li	a2,16
 a62:	000bb583          	ld	a1,0(s7)
 a66:	855a                	mv	a0,s6
 a68:	d7dff0ef          	jal	7e4 <printint>
        i += 1;
 a6c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 a6e:	8bca                	mv	s7,s2
      state = 0;
 a70:	4981                	li	s3,0
        i += 1;
 a72:	bda1                	j	8ca <vprintf+0x4a>
 a74:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 a76:	008b8d13          	addi	s10,s7,8
 a7a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a7e:	03000593          	li	a1,48
 a82:	855a                	mv	a0,s6
 a84:	d43ff0ef          	jal	7c6 <putc>
  putc(fd, 'x');
 a88:	07800593          	li	a1,120
 a8c:	855a                	mv	a0,s6
 a8e:	d39ff0ef          	jal	7c6 <putc>
 a92:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a94:	00001b97          	auipc	s7,0x1
 a98:	a54b8b93          	addi	s7,s7,-1452 # 14e8 <digits>
 a9c:	03c9d793          	srli	a5,s3,0x3c
 aa0:	97de                	add	a5,a5,s7
 aa2:	0007c583          	lbu	a1,0(a5)
 aa6:	855a                	mv	a0,s6
 aa8:	d1fff0ef          	jal	7c6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 aac:	0992                	slli	s3,s3,0x4
 aae:	397d                	addiw	s2,s2,-1
 ab0:	fe0916e3          	bnez	s2,a9c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 ab4:	8bea                	mv	s7,s10
      state = 0;
 ab6:	4981                	li	s3,0
 ab8:	6d02                	ld	s10,0(sp)
 aba:	bd01                	j	8ca <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 abc:	008b8913          	addi	s2,s7,8
 ac0:	000bc583          	lbu	a1,0(s7)
 ac4:	855a                	mv	a0,s6
 ac6:	d01ff0ef          	jal	7c6 <putc>
 aca:	8bca                	mv	s7,s2
      state = 0;
 acc:	4981                	li	s3,0
 ace:	bbf5                	j	8ca <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 ad0:	008b8993          	addi	s3,s7,8
 ad4:	000bb903          	ld	s2,0(s7)
 ad8:	00090f63          	beqz	s2,af6 <vprintf+0x276>
        for(; *s; s++)
 adc:	00094583          	lbu	a1,0(s2)
 ae0:	c195                	beqz	a1,b04 <vprintf+0x284>
          putc(fd, *s);
 ae2:	855a                	mv	a0,s6
 ae4:	ce3ff0ef          	jal	7c6 <putc>
        for(; *s; s++)
 ae8:	0905                	addi	s2,s2,1
 aea:	00094583          	lbu	a1,0(s2)
 aee:	f9f5                	bnez	a1,ae2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 af0:	8bce                	mv	s7,s3
      state = 0;
 af2:	4981                	li	s3,0
 af4:	bbd9                	j	8ca <vprintf+0x4a>
          s = "(null)";
 af6:	00001917          	auipc	s2,0x1
 afa:	9ea90913          	addi	s2,s2,-1558 # 14e0 <malloc+0x8de>
        for(; *s; s++)
 afe:	02800593          	li	a1,40
 b02:	b7c5                	j	ae2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 b04:	8bce                	mv	s7,s3
      state = 0;
 b06:	4981                	li	s3,0
 b08:	b3c9                	j	8ca <vprintf+0x4a>
 b0a:	64a6                	ld	s1,72(sp)
 b0c:	79e2                	ld	s3,56(sp)
 b0e:	7a42                	ld	s4,48(sp)
 b10:	7aa2                	ld	s5,40(sp)
 b12:	7b02                	ld	s6,32(sp)
 b14:	6be2                	ld	s7,24(sp)
 b16:	6c42                	ld	s8,16(sp)
 b18:	6ca2                	ld	s9,8(sp)
    }
  }
}
 b1a:	60e6                	ld	ra,88(sp)
 b1c:	6446                	ld	s0,80(sp)
 b1e:	6906                	ld	s2,64(sp)
 b20:	6125                	addi	sp,sp,96
 b22:	8082                	ret

0000000000000b24 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b24:	715d                	addi	sp,sp,-80
 b26:	ec06                	sd	ra,24(sp)
 b28:	e822                	sd	s0,16(sp)
 b2a:	1000                	addi	s0,sp,32
 b2c:	e010                	sd	a2,0(s0)
 b2e:	e414                	sd	a3,8(s0)
 b30:	e818                	sd	a4,16(s0)
 b32:	ec1c                	sd	a5,24(s0)
 b34:	03043023          	sd	a6,32(s0)
 b38:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b3c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b40:	8622                	mv	a2,s0
 b42:	d3fff0ef          	jal	880 <vprintf>
}
 b46:	60e2                	ld	ra,24(sp)
 b48:	6442                	ld	s0,16(sp)
 b4a:	6161                	addi	sp,sp,80
 b4c:	8082                	ret

0000000000000b4e <printf>:

void
printf(const char *fmt, ...)
{
 b4e:	711d                	addi	sp,sp,-96
 b50:	ec06                	sd	ra,24(sp)
 b52:	e822                	sd	s0,16(sp)
 b54:	1000                	addi	s0,sp,32
 b56:	e40c                	sd	a1,8(s0)
 b58:	e810                	sd	a2,16(s0)
 b5a:	ec14                	sd	a3,24(s0)
 b5c:	f018                	sd	a4,32(s0)
 b5e:	f41c                	sd	a5,40(s0)
 b60:	03043823          	sd	a6,48(s0)
 b64:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b68:	00840613          	addi	a2,s0,8
 b6c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b70:	85aa                	mv	a1,a0
 b72:	4505                	li	a0,1
 b74:	d0dff0ef          	jal	880 <vprintf>
}
 b78:	60e2                	ld	ra,24(sp)
 b7a:	6442                	ld	s0,16(sp)
 b7c:	6125                	addi	sp,sp,96
 b7e:	8082                	ret

0000000000000b80 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b80:	1141                	addi	sp,sp,-16
 b82:	e422                	sd	s0,8(sp)
 b84:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b86:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b8a:	00001797          	auipc	a5,0x1
 b8e:	4767b783          	ld	a5,1142(a5) # 2000 <freep>
 b92:	a02d                	j	bbc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b94:	4618                	lw	a4,8(a2)
 b96:	9f2d                	addw	a4,a4,a1
 b98:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b9c:	6398                	ld	a4,0(a5)
 b9e:	6310                	ld	a2,0(a4)
 ba0:	a83d                	j	bde <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 ba2:	ff852703          	lw	a4,-8(a0)
 ba6:	9f31                	addw	a4,a4,a2
 ba8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 baa:	ff053683          	ld	a3,-16(a0)
 bae:	a091                	j	bf2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bb0:	6398                	ld	a4,0(a5)
 bb2:	00e7e463          	bltu	a5,a4,bba <free+0x3a>
 bb6:	00e6ea63          	bltu	a3,a4,bca <free+0x4a>
{
 bba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bbc:	fed7fae3          	bgeu	a5,a3,bb0 <free+0x30>
 bc0:	6398                	ld	a4,0(a5)
 bc2:	00e6e463          	bltu	a3,a4,bca <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bc6:	fee7eae3          	bltu	a5,a4,bba <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 bca:	ff852583          	lw	a1,-8(a0)
 bce:	6390                	ld	a2,0(a5)
 bd0:	02059813          	slli	a6,a1,0x20
 bd4:	01c85713          	srli	a4,a6,0x1c
 bd8:	9736                	add	a4,a4,a3
 bda:	fae60de3          	beq	a2,a4,b94 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 bde:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 be2:	4790                	lw	a2,8(a5)
 be4:	02061593          	slli	a1,a2,0x20
 be8:	01c5d713          	srli	a4,a1,0x1c
 bec:	973e                	add	a4,a4,a5
 bee:	fae68ae3          	beq	a3,a4,ba2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 bf2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 bf4:	00001717          	auipc	a4,0x1
 bf8:	40f73623          	sd	a5,1036(a4) # 2000 <freep>
}
 bfc:	6422                	ld	s0,8(sp)
 bfe:	0141                	addi	sp,sp,16
 c00:	8082                	ret

0000000000000c02 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 c02:	7139                	addi	sp,sp,-64
 c04:	fc06                	sd	ra,56(sp)
 c06:	f822                	sd	s0,48(sp)
 c08:	f426                	sd	s1,40(sp)
 c0a:	ec4e                	sd	s3,24(sp)
 c0c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c0e:	02051493          	slli	s1,a0,0x20
 c12:	9081                	srli	s1,s1,0x20
 c14:	04bd                	addi	s1,s1,15
 c16:	8091                	srli	s1,s1,0x4
 c18:	0014899b          	addiw	s3,s1,1
 c1c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 c1e:	00001517          	auipc	a0,0x1
 c22:	3e253503          	ld	a0,994(a0) # 2000 <freep>
 c26:	c915                	beqz	a0,c5a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c28:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c2a:	4798                	lw	a4,8(a5)
 c2c:	08977a63          	bgeu	a4,s1,cc0 <malloc+0xbe>
 c30:	f04a                	sd	s2,32(sp)
 c32:	e852                	sd	s4,16(sp)
 c34:	e456                	sd	s5,8(sp)
 c36:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 c38:	8a4e                	mv	s4,s3
 c3a:	0009871b          	sext.w	a4,s3
 c3e:	6685                	lui	a3,0x1
 c40:	00d77363          	bgeu	a4,a3,c46 <malloc+0x44>
 c44:	6a05                	lui	s4,0x1
 c46:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c4a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c4e:	00001917          	auipc	s2,0x1
 c52:	3b290913          	addi	s2,s2,946 # 2000 <freep>
  if(p == SBRK_ERROR)
 c56:	5afd                	li	s5,-1
 c58:	a081                	j	c98 <malloc+0x96>
 c5a:	f04a                	sd	s2,32(sp)
 c5c:	e852                	sd	s4,16(sp)
 c5e:	e456                	sd	s5,8(sp)
 c60:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c62:	00001797          	auipc	a5,0x1
 c66:	3ae78793          	addi	a5,a5,942 # 2010 <base>
 c6a:	00001717          	auipc	a4,0x1
 c6e:	38f73b23          	sd	a5,918(a4) # 2000 <freep>
 c72:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c74:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c78:	b7c1                	j	c38 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 c7a:	6398                	ld	a4,0(a5)
 c7c:	e118                	sd	a4,0(a0)
 c7e:	a8a9                	j	cd8 <malloc+0xd6>
  hp->s.size = nu;
 c80:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c84:	0541                	addi	a0,a0,16
 c86:	efbff0ef          	jal	b80 <free>
  return freep;
 c8a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c8e:	c12d                	beqz	a0,cf0 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c90:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c92:	4798                	lw	a4,8(a5)
 c94:	02977263          	bgeu	a4,s1,cb8 <malloc+0xb6>
    if(p == freep)
 c98:	00093703          	ld	a4,0(s2)
 c9c:	853e                	mv	a0,a5
 c9e:	fef719e3          	bne	a4,a5,c90 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 ca2:	8552                	mv	a0,s4
 ca4:	a3fff0ef          	jal	6e2 <sbrk>
  if(p == SBRK_ERROR)
 ca8:	fd551ce3          	bne	a0,s5,c80 <malloc+0x7e>
        return 0;
 cac:	4501                	li	a0,0
 cae:	7902                	ld	s2,32(sp)
 cb0:	6a42                	ld	s4,16(sp)
 cb2:	6aa2                	ld	s5,8(sp)
 cb4:	6b02                	ld	s6,0(sp)
 cb6:	a03d                	j	ce4 <malloc+0xe2>
 cb8:	7902                	ld	s2,32(sp)
 cba:	6a42                	ld	s4,16(sp)
 cbc:	6aa2                	ld	s5,8(sp)
 cbe:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 cc0:	fae48de3          	beq	s1,a4,c7a <malloc+0x78>
        p->s.size -= nunits;
 cc4:	4137073b          	subw	a4,a4,s3
 cc8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cca:	02071693          	slli	a3,a4,0x20
 cce:	01c6d713          	srli	a4,a3,0x1c
 cd2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 cd4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 cd8:	00001717          	auipc	a4,0x1
 cdc:	32a73423          	sd	a0,808(a4) # 2000 <freep>
      return (void*)(p + 1);
 ce0:	01078513          	addi	a0,a5,16
  }
}
 ce4:	70e2                	ld	ra,56(sp)
 ce6:	7442                	ld	s0,48(sp)
 ce8:	74a2                	ld	s1,40(sp)
 cea:	69e2                	ld	s3,24(sp)
 cec:	6121                	addi	sp,sp,64
 cee:	8082                	ret
 cf0:	7902                	ld	s2,32(sp)
 cf2:	6a42                	ld	s4,16(sp)
 cf4:	6aa2                	ld	s5,8(sp)
 cf6:	6b02                	ld	s6,0(sp)
 cf8:	b7f5                	j	ce4 <malloc+0xe2>
