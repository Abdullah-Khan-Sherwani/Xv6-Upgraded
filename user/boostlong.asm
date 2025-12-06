
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
  3a:	7175                	addi	sp,sp,-144
  3c:	e506                	sd	ra,136(sp)
  3e:	e122                	sd	s0,128(sp)
  40:	fca6                	sd	s1,120(sp)
  42:	f8ca                	sd	s2,112(sp)
  44:	f4ce                	sd	s3,104(sp)
  46:	f0d2                	sd	s4,96(sp)
  48:	ecd6                	sd	s5,88(sp)
  4a:	e8da                	sd	s6,80(sp)
  4c:	e4de                	sd	s7,72(sp)
  4e:	e0e2                	sd	s8,64(sp)
  50:	fc66                	sd	s9,56(sp)
  52:	f86a                	sd	s10,48(sp)
  54:	f46e                	sd	s11,40(sp)
  56:	0900                	addi	s0,sp,144
  int start_tick;
  int last_priority = 0;
  int last_slices = 0;
  int boost_count = 0;
  
  printf("\n");
  58:	00001517          	auipc	a0,0x1
  5c:	c1850513          	addi	a0,a0,-1000 # c70 <malloc+0xfc>
  60:	261000ef          	jal	ac0 <printf>
  printf("================================================================\n");
  64:	00001517          	auipc	a0,0x1
  68:	c1450513          	addi	a0,a0,-1004 # c78 <malloc+0x104>
  6c:	255000ef          	jal	ac0 <printf>
  printf("     MLFQ BOOST TEST - SINGLE PROCESS DETAILED VIEW\n");
  70:	00001517          	auipc	a0,0x1
  74:	c5050513          	addi	a0,a0,-944 # cc0 <malloc+0x14c>
  78:	249000ef          	jal	ac0 <printf>
  printf("================================================================\n");
  7c:	00001517          	auipc	a0,0x1
  80:	bfc50513          	addi	a0,a0,-1028 # c78 <malloc+0x104>
  84:	23d000ef          	jal	ac0 <printf>
  printf("  Time Quanta: Q0=2, Q1=4, Q2=8, Q3=16 ticks\n");
  88:	00001517          	auipc	a0,0x1
  8c:	c7050513          	addi	a0,a0,-912 # cf8 <malloc+0x184>
  90:	231000ef          	jal	ac0 <printf>
  printf("  Boost Interval: Every 50 ticks all processes -> Q0\n");
  94:	00001517          	auipc	a0,0x1
  98:	c9450513          	addi	a0,a0,-876 # d28 <malloc+0x1b4>
  9c:	225000ef          	jal	ac0 <printf>
  printf("  Key Test: Q3 stays at Q3 even after 16+ slices until BOOST\n");
  a0:	00001517          	auipc	a0,0x1
  a4:	cc050513          	addi	a0,a0,-832 # d60 <malloc+0x1ec>
  a8:	219000ef          	jal	ac0 <printf>
  printf("================================================================\n\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	cf450513          	addi	a0,a0,-780 # da0 <malloc+0x22c>
  b4:	20d000ef          	jal	ac0 <printf>
  
  start_tick = uptime();
  b8:	668000ef          	jal	720 <uptime>
  bc:	8b2a                	mv	s6,a0
  getprocinfo(&info);
  be:	f8040513          	addi	a0,s0,-128
  c2:	666000ef          	jal	728 <getprocinfo>
  last_priority = info.priority;
  c6:	f8842483          	lw	s1,-120(s0)
  last_slices = info.time_slices;
  ca:	f8c42c03          	lw	s8,-116(s0)
  
  printf("  TICK | QUEUE | SLICES | EVENT\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	d1a50513          	addi	a0,a0,-742 # de8 <malloc+0x274>
  d6:	1eb000ef          	jal	ac0 <printf>
  printf("  -----+-------+--------+----------------------------------------\n");
  da:	00001517          	auipc	a0,0x1
  de:	d3650513          	addi	a0,a0,-714 # e10 <malloc+0x29c>
  e2:	1df000ef          	jal	ac0 <printf>
  e6:	7d000993          	li	s3,2000
  
  int reached_q3 = 0;
  int q3_extra_shown = 0;
  int first_boost_seen = 0;
  ea:	4a01                	li	s4,0
  int q3_extra_shown = 0;
  ec:	f6043823          	sd	zero,-144(s0)
  int reached_q3 = 0;
  f0:	f6043c23          	sd	zero,-136(s0)
  int boost_count = 0;
  f4:	4a81                	li	s5,0
  
  // Run until we see 3 boosts (print after 1st boost, track 2 more)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
    cpu_work(WORK_ITERATIONS / 5);
  f6:	000f4bb7          	lui	s7,0xf4
  fa:	240b8b93          	addi	s7,s7,576 # f4240 <base+0xf2230>
        reached_q3 = 0;
        q3_extra_shown = 0;
      }
    }
    // Show slice progression at Q3 (especially when slices > 16) - only after first boost
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
  fe:	4d8d                	li	s11,3
               current_tick, info.priority, info.time_slices);
        q3_extra_shown++;
      }
    }
    // Show running status for other queues - only after first boost
    else if(first_boost_seen && info.priority < 3 && info.time_slices != last_slices) {
 100:	4c89                	li	s9,2
          printf("  -----+-------+--------+----------------------------------------\n");
 102:	00001d17          	auipc	s10,0x1
 106:	d0ed0d13          	addi	s10,s10,-754 # e10 <malloc+0x29c>
 10a:	a02d                	j	134 <main+0xfa>
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 10c:	87b2                	mv	a5,a2
 10e:	8726                	mv	a4,s1
 110:	85ca                	mv	a1,s2
 112:	00001517          	auipc	a0,0x1
 116:	d4650513          	addi	a0,a0,-698 # e58 <malloc+0x2e4>
 11a:	1a7000ef          	jal	ac0 <printf>
          if(info.priority == 3 && !reached_q3) {
 11e:	f8842783          	lw	a5,-120(s0)
 122:	05b78663          	beq	a5,s11,16e <main+0x134>
      printf("   %d  |  Q%d   |    %d   | Running at Q%d (slices: %d)\n",
             current_tick, info.priority, info.time_slices, 
             info.priority, info.time_slices);
    }
    
    last_priority = info.priority;
 126:	f8842483          	lw	s1,-120(s0)
    last_slices = info.time_slices;
 12a:	f8c42c03          	lw	s8,-116(s0)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
 12e:	39fd                	addiw	s3,s3,-1
 130:	14098f63          	beqz	s3,28e <main+0x254>
    cpu_work(WORK_ITERATIONS / 5);
 134:	855e                	mv	a0,s7
 136:	ecbff0ef          	jal	0 <cpu_work>
    getprocinfo(&info);
 13a:	f8040513          	addi	a0,s0,-128
 13e:	5ea000ef          	jal	728 <getprocinfo>
    int current_tick = uptime() - start_tick;
 142:	5de000ef          	jal	720 <uptime>
 146:	4165093b          	subw	s2,a0,s6
    if(info.priority != last_priority) {
 14a:	f8842603          	lw	a2,-120(s0)
 14e:	0a960d63          	beq	a2,s1,208 <main+0x1ce>
      if(info.priority > last_priority) {
 152:	04c4d963          	bge	s1,a2,1a4 <main+0x16a>
        if(first_boost_seen) {
 156:	fc0a08e3          	beqz	s4,126 <main+0xec>
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 15a:	f8c42683          	lw	a3,-116(s0)
 15e:	8866                	mv	a6,s9
 160:	d4d5                	beqz	s1,10c <main+0xd2>
                 last_priority == 0 ? 2 : (last_priority == 1 ? 4 : 8));
 162:	4821                	li	a6,8
 164:	4785                	li	a5,1
 166:	faf493e3          	bne	s1,a5,10c <main+0xd2>
 16a:	4811                	li	a6,4
 16c:	b745                	j	10c <main+0xd2>
          if(info.priority == 3 && !reached_q3) {
 16e:	f7843783          	ld	a5,-136(s0)
 172:	c781                	beqz	a5,17a <main+0x140>
 174:	f7843a03          	ld	s4,-136(s0)
 178:	b77d                	j	126 <main+0xec>
            printf("  -----+-------+--------+----------------------------------------\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	c9650513          	addi	a0,a0,-874 # e10 <malloc+0x29c>
 182:	13f000ef          	jal	ac0 <printf>
            printf("  >>> Now at LOWEST priority (Q3) - will stay here until BOOST <<<\n");
 186:	00001517          	auipc	a0,0x1
 18a:	d1250513          	addi	a0,a0,-750 # e98 <malloc+0x324>
 18e:	133000ef          	jal	ac0 <printf>
            printf("  -----+-------+--------+----------------------------------------\n");
 192:	00001517          	auipc	a0,0x1
 196:	c7e50513          	addi	a0,a0,-898 # e10 <malloc+0x29c>
 19a:	127000ef          	jal	ac0 <printf>
            reached_q3 = 1;
 19e:	f7443c23          	sd	s4,-136(s0)
 1a2:	b751                	j	126 <main+0xec>
        boost_count++;
 1a4:	2a85                	addiw	s5,s5,1
        if(!first_boost_seen) {
 1a6:	020a1d63          	bnez	s4,1e0 <main+0x1a6>
          printf("   %d  |  Q%d   |    %d   | *** BOOST #1 - START TRACKING ***\n",
 1aa:	f8c42683          	lw	a3,-116(s0)
 1ae:	85ca                	mv	a1,s2
 1b0:	00001517          	auipc	a0,0x1
 1b4:	d3050513          	addi	a0,a0,-720 # ee0 <malloc+0x36c>
 1b8:	109000ef          	jal	ac0 <printf>
          printf("  -----+-------+--------+----------------------------------------\n");
 1bc:	856a                	mv	a0,s10
 1be:	103000ef          	jal	ac0 <printf>
    last_priority = info.priority;
 1c2:	f8842483          	lw	s1,-120(s0)
    last_slices = info.time_slices;
 1c6:	f8c42c03          	lw	s8,-116(s0)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
 1ca:	39fd                	addiw	s3,s3,-1
 1cc:	0c098163          	beqz	s3,28e <main+0x254>
 1d0:	155cc463          	blt	s9,s5,318 <main+0x2de>
 1d4:	4a05                	li	s4,1
 1d6:	f6043823          	sd	zero,-144(s0)
 1da:	f6043c23          	sd	zero,-136(s0)
 1de:	bf99                	j	134 <main+0xfa>
          printf("  -----+-------+--------+----------------------------------------\n");
 1e0:	856a                	mv	a0,s10
 1e2:	0df000ef          	jal	ac0 <printf>
          printf("   %d  |  Q%d   |    %d   | *** BOOST #%d! Q%d->Q0 ***\n",
 1e6:	87a6                	mv	a5,s1
 1e8:	8756                	mv	a4,s5
 1ea:	f8c42683          	lw	a3,-116(s0)
 1ee:	f8842603          	lw	a2,-120(s0)
 1f2:	85ca                	mv	a1,s2
 1f4:	00001517          	auipc	a0,0x1
 1f8:	d2c50513          	addi	a0,a0,-724 # f20 <malloc+0x3ac>
 1fc:	0c5000ef          	jal	ac0 <printf>
          printf("  -----+-------+--------+----------------------------------------\n");
 200:	856a                	mv	a0,s10
 202:	0bf000ef          	jal	ac0 <printf>
 206:	bf75                	j	1c2 <main+0x188>
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 208:	f00a0fe3          	beqz	s4,126 <main+0xec>
 20c:	03b48363          	beq	s1,s11,232 <main+0x1f8>
    else if(first_boost_seen && info.priority < 3 && info.time_slices != last_slices) {
 210:	f09ccbe3          	blt	s9,s1,126 <main+0xec>
 214:	f8c42683          	lw	a3,-116(s0)
 218:	f18687e3          	beq	a3,s8,126 <main+0xec>
      printf("   %d  |  Q%d   |    %d   | Running at Q%d (slices: %d)\n",
 21c:	87b6                	mv	a5,a3
 21e:	8726                	mv	a4,s1
 220:	8626                	mv	a2,s1
 222:	85ca                	mv	a1,s2
 224:	00001517          	auipc	a0,0x1
 228:	dbc50513          	addi	a0,a0,-580 # fe0 <malloc+0x46c>
 22c:	095000ef          	jal	ac0 <printf>
 230:	bddd                	j	126 <main+0xec>
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 232:	f8c42683          	lw	a3,-116(s0)
 236:	ef8688e3          	beq	a3,s8,126 <main+0xec>
      if(info.time_slices <= 16 && info.time_slices % 2 == 0) {
 23a:	47c1                	li	a5,16
 23c:	02d7c563          	blt	a5,a3,266 <main+0x22c>
 240:	0016f793          	andi	a5,a3,1
 244:	c399                	beqz	a5,24a <main+0x210>
 246:	8a3e                	mv	s4,a5
 248:	bdf9                	j	126 <main+0xec>
        printf("   %d  |  Q%d   |   %d   | Waiting at Q3 (slices: %d/16)\n",
 24a:	8736                	mv	a4,a3
 24c:	460d                	li	a2,3
 24e:	85ca                	mv	a1,s2
 250:	00001517          	auipc	a0,0x1
 254:	d0850513          	addi	a0,a0,-760 # f58 <malloc+0x3e4>
 258:	069000ef          	jal	ac0 <printf>
      if(info.time_slices > 16 && q3_extra_shown < 5) {
 25c:	f8c42683          	lw	a3,-116(s0)
 260:	47c1                	li	a5,16
 262:	ecd7d2e3          	bge	a5,a3,126 <main+0xec>
 266:	4791                	li	a5,4
 268:	f7043703          	ld	a4,-144(s0)
 26c:	eae7cde3          	blt	a5,a4,126 <main+0xec>
        printf("   %d  |  Q%d   |   %d   | STILL Q3! (slices > 16, waiting for boost)\n",
 270:	f8842603          	lw	a2,-120(s0)
 274:	85ca                	mv	a1,s2
 276:	00001517          	auipc	a0,0x1
 27a:	d2250513          	addi	a0,a0,-734 # f98 <malloc+0x424>
 27e:	043000ef          	jal	ac0 <printf>
        q3_extra_shown++;
 282:	f7043783          	ld	a5,-144(s0)
 286:	2785                	addiw	a5,a5,1
 288:	f6f43823          	sd	a5,-144(s0)
 28c:	bd69                	j	126 <main+0xec>
  }
  
  printf("\n");
 28e:	00001517          	auipc	a0,0x1
 292:	9e250513          	addi	a0,a0,-1566 # c70 <malloc+0xfc>
 296:	02b000ef          	jal	ac0 <printf>
  printf("================================================================\n");
 29a:	00001517          	auipc	a0,0x1
 29e:	9de50513          	addi	a0,a0,-1570 # c78 <malloc+0x104>
 2a2:	01f000ef          	jal	ac0 <printf>
  printf("                      TEST SUMMARY\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	d7a50513          	addi	a0,a0,-646 # 1020 <malloc+0x4ac>
 2ae:	013000ef          	jal	ac0 <printf>
  printf("================================================================\n");
 2b2:	00001517          	auipc	a0,0x1
 2b6:	9c650513          	addi	a0,a0,-1594 # c78 <malloc+0x104>
 2ba:	007000ef          	jal	ac0 <printf>
  int total = uptime() - start_tick;
 2be:	462000ef          	jal	720 <uptime>
 2c2:	416505bb          	subw	a1,a0,s6
  printf("  Total Runtime   : %d ticks (~%d.%d seconds)\n", 
 2c6:	4629                	li	a2,10
 2c8:	02c5e6bb          	remw	a3,a1,a2
 2cc:	02c5c63b          	divw	a2,a1,a2
 2d0:	2581                	sext.w	a1,a1
 2d2:	00001517          	auipc	a0,0x1
 2d6:	d7650513          	addi	a0,a0,-650 # 1048 <malloc+0x4d4>
 2da:	7e6000ef          	jal	ac0 <printf>
         total, total/10, total%10);
  printf("  Boost Events    : %d automatic boosts detected\n", boost_count);
 2de:	85d6                	mv	a1,s5
 2e0:	00001517          	auipc	a0,0x1
 2e4:	d9850513          	addi	a0,a0,-616 # 1078 <malloc+0x504>
 2e8:	7d8000ef          	jal	ac0 <printf>
  printf("  Expected Interval: ~50 ticks between boosts\n");
 2ec:	00001517          	auipc	a0,0x1
 2f0:	dc450513          	addi	a0,a0,-572 # 10b0 <malloc+0x53c>
 2f4:	7cc000ef          	jal	ac0 <printf>
  printf("----------------------------------------------------------------\n");
 2f8:	00001517          	auipc	a0,0x1
 2fc:	de850513          	addi	a0,a0,-536 # 10e0 <malloc+0x56c>
 300:	7c0000ef          	jal	ac0 <printf>
  if(boost_count >= 3) {
 304:	4789                	li	a5,2
 306:	0957c463          	blt	a5,s5,38e <main+0x354>
    printf("    2. Staying at Q3 until boost interval\n");
    printf("    3. Q3 STAYS Q3 even after 16+ slices (no further demotion)\n");
    printf("    4. Automatic boost back to Q0 (starvation prevention)\n");
    printf("    5. Multiple boost cycles confirming periodic boosting\n");
  } else {
    printf("  Test incomplete - try running longer\n");
 30a:	00001517          	auipc	a0,0x1
 30e:	fa650513          	addi	a0,a0,-90 # 12b0 <malloc+0x73c>
 312:	7ae000ef          	jal	ac0 <printf>
 316:	a0f1                	j	3e2 <main+0x3a8>
  printf("\n");
 318:	00001517          	auipc	a0,0x1
 31c:	95850513          	addi	a0,a0,-1704 # c70 <malloc+0xfc>
 320:	7a0000ef          	jal	ac0 <printf>
  printf("================================================================\n");
 324:	00001517          	auipc	a0,0x1
 328:	95450513          	addi	a0,a0,-1708 # c78 <malloc+0x104>
 32c:	794000ef          	jal	ac0 <printf>
  printf("                      TEST SUMMARY\n");
 330:	00001517          	auipc	a0,0x1
 334:	cf050513          	addi	a0,a0,-784 # 1020 <malloc+0x4ac>
 338:	788000ef          	jal	ac0 <printf>
  printf("================================================================\n");
 33c:	00001517          	auipc	a0,0x1
 340:	93c50513          	addi	a0,a0,-1732 # c78 <malloc+0x104>
 344:	77c000ef          	jal	ac0 <printf>
  int total = uptime() - start_tick;
 348:	3d8000ef          	jal	720 <uptime>
 34c:	416505bb          	subw	a1,a0,s6
  printf("  Total Runtime   : %d ticks (~%d.%d seconds)\n", 
 350:	4629                	li	a2,10
 352:	02c5e6bb          	remw	a3,a1,a2
 356:	02c5c63b          	divw	a2,a1,a2
 35a:	2581                	sext.w	a1,a1
 35c:	00001517          	auipc	a0,0x1
 360:	cec50513          	addi	a0,a0,-788 # 1048 <malloc+0x4d4>
 364:	75c000ef          	jal	ac0 <printf>
  printf("  Boost Events    : %d automatic boosts detected\n", boost_count);
 368:	85d6                	mv	a1,s5
 36a:	00001517          	auipc	a0,0x1
 36e:	d0e50513          	addi	a0,a0,-754 # 1078 <malloc+0x504>
 372:	74e000ef          	jal	ac0 <printf>
  printf("  Expected Interval: ~50 ticks between boosts\n");
 376:	00001517          	auipc	a0,0x1
 37a:	d3a50513          	addi	a0,a0,-710 # 10b0 <malloc+0x53c>
 37e:	742000ef          	jal	ac0 <printf>
  printf("----------------------------------------------------------------\n");
 382:	00001517          	auipc	a0,0x1
 386:	d5e50513          	addi	a0,a0,-674 # 10e0 <malloc+0x56c>
 38a:	736000ef          	jal	ac0 <printf>
    printf("  SUCCESS: Priority boosting is working correctly!\n\n");
 38e:	00001517          	auipc	a0,0x1
 392:	d9a50513          	addi	a0,a0,-614 # 1128 <malloc+0x5b4>
 396:	72a000ef          	jal	ac0 <printf>
    printf("  The test demonstrated:\n");
 39a:	00001517          	auipc	a0,0x1
 39e:	dc650513          	addi	a0,a0,-570 # 1160 <malloc+0x5ec>
 3a2:	71e000ef          	jal	ac0 <printf>
    printf("    1. Demotion: Q0 -> Q1 -> Q2 -> Q3 (CPU-bound behavior)\n");
 3a6:	00001517          	auipc	a0,0x1
 3aa:	dda50513          	addi	a0,a0,-550 # 1180 <malloc+0x60c>
 3ae:	712000ef          	jal	ac0 <printf>
    printf("    2. Staying at Q3 until boost interval\n");
 3b2:	00001517          	auipc	a0,0x1
 3b6:	e0e50513          	addi	a0,a0,-498 # 11c0 <malloc+0x64c>
 3ba:	706000ef          	jal	ac0 <printf>
    printf("    3. Q3 STAYS Q3 even after 16+ slices (no further demotion)\n");
 3be:	00001517          	auipc	a0,0x1
 3c2:	e3250513          	addi	a0,a0,-462 # 11f0 <malloc+0x67c>
 3c6:	6fa000ef          	jal	ac0 <printf>
    printf("    4. Automatic boost back to Q0 (starvation prevention)\n");
 3ca:	00001517          	auipc	a0,0x1
 3ce:	e6650513          	addi	a0,a0,-410 # 1230 <malloc+0x6bc>
 3d2:	6ee000ef          	jal	ac0 <printf>
    printf("    5. Multiple boost cycles confirming periodic boosting\n");
 3d6:	00001517          	auipc	a0,0x1
 3da:	e9a50513          	addi	a0,a0,-358 # 1270 <malloc+0x6fc>
 3de:	6e2000ef          	jal	ac0 <printf>
  }
  printf("================================================================\n\n");
 3e2:	00001517          	auipc	a0,0x1
 3e6:	9be50513          	addi	a0,a0,-1602 # da0 <malloc+0x22c>
 3ea:	6d6000ef          	jal	ac0 <printf>
  
  exit(0);
 3ee:	4501                	li	a0,0
 3f0:	298000ef          	jal	688 <exit>

00000000000003f4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e406                	sd	ra,8(sp)
 3f8:	e022                	sd	s0,0(sp)
 3fa:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 3fc:	c3fff0ef          	jal	3a <main>
  exit(r);
 400:	288000ef          	jal	688 <exit>

0000000000000404 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 404:	1141                	addi	sp,sp,-16
 406:	e422                	sd	s0,8(sp)
 408:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 40a:	87aa                	mv	a5,a0
 40c:	0585                	addi	a1,a1,1
 40e:	0785                	addi	a5,a5,1
 410:	fff5c703          	lbu	a4,-1(a1)
 414:	fee78fa3          	sb	a4,-1(a5)
 418:	fb75                	bnez	a4,40c <strcpy+0x8>
    ;
  return os;
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret

0000000000000420 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 420:	1141                	addi	sp,sp,-16
 422:	e422                	sd	s0,8(sp)
 424:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 426:	00054783          	lbu	a5,0(a0)
 42a:	cb91                	beqz	a5,43e <strcmp+0x1e>
 42c:	0005c703          	lbu	a4,0(a1)
 430:	00f71763          	bne	a4,a5,43e <strcmp+0x1e>
    p++, q++;
 434:	0505                	addi	a0,a0,1
 436:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 438:	00054783          	lbu	a5,0(a0)
 43c:	fbe5                	bnez	a5,42c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 43e:	0005c503          	lbu	a0,0(a1)
}
 442:	40a7853b          	subw	a0,a5,a0
 446:	6422                	ld	s0,8(sp)
 448:	0141                	addi	sp,sp,16
 44a:	8082                	ret

000000000000044c <strlen>:

uint
strlen(const char *s)
{
 44c:	1141                	addi	sp,sp,-16
 44e:	e422                	sd	s0,8(sp)
 450:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 452:	00054783          	lbu	a5,0(a0)
 456:	cf91                	beqz	a5,472 <strlen+0x26>
 458:	0505                	addi	a0,a0,1
 45a:	87aa                	mv	a5,a0
 45c:	86be                	mv	a3,a5
 45e:	0785                	addi	a5,a5,1
 460:	fff7c703          	lbu	a4,-1(a5)
 464:	ff65                	bnez	a4,45c <strlen+0x10>
 466:	40a6853b          	subw	a0,a3,a0
 46a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 46c:	6422                	ld	s0,8(sp)
 46e:	0141                	addi	sp,sp,16
 470:	8082                	ret
  for(n = 0; s[n]; n++)
 472:	4501                	li	a0,0
 474:	bfe5                	j	46c <strlen+0x20>

0000000000000476 <memset>:

void*
memset(void *dst, int c, uint n)
{
 476:	1141                	addi	sp,sp,-16
 478:	e422                	sd	s0,8(sp)
 47a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 47c:	ca19                	beqz	a2,492 <memset+0x1c>
 47e:	87aa                	mv	a5,a0
 480:	1602                	slli	a2,a2,0x20
 482:	9201                	srli	a2,a2,0x20
 484:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 488:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 48c:	0785                	addi	a5,a5,1
 48e:	fee79de3          	bne	a5,a4,488 <memset+0x12>
  }
  return dst;
}
 492:	6422                	ld	s0,8(sp)
 494:	0141                	addi	sp,sp,16
 496:	8082                	ret

0000000000000498 <strchr>:

char*
strchr(const char *s, char c)
{
 498:	1141                	addi	sp,sp,-16
 49a:	e422                	sd	s0,8(sp)
 49c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 49e:	00054783          	lbu	a5,0(a0)
 4a2:	cb99                	beqz	a5,4b8 <strchr+0x20>
    if(*s == c)
 4a4:	00f58763          	beq	a1,a5,4b2 <strchr+0x1a>
  for(; *s; s++)
 4a8:	0505                	addi	a0,a0,1
 4aa:	00054783          	lbu	a5,0(a0)
 4ae:	fbfd                	bnez	a5,4a4 <strchr+0xc>
      return (char*)s;
  return 0;
 4b0:	4501                	li	a0,0
}
 4b2:	6422                	ld	s0,8(sp)
 4b4:	0141                	addi	sp,sp,16
 4b6:	8082                	ret
  return 0;
 4b8:	4501                	li	a0,0
 4ba:	bfe5                	j	4b2 <strchr+0x1a>

00000000000004bc <gets>:

char*
gets(char *buf, int max)
{
 4bc:	711d                	addi	sp,sp,-96
 4be:	ec86                	sd	ra,88(sp)
 4c0:	e8a2                	sd	s0,80(sp)
 4c2:	e4a6                	sd	s1,72(sp)
 4c4:	e0ca                	sd	s2,64(sp)
 4c6:	fc4e                	sd	s3,56(sp)
 4c8:	f852                	sd	s4,48(sp)
 4ca:	f456                	sd	s5,40(sp)
 4cc:	f05a                	sd	s6,32(sp)
 4ce:	ec5e                	sd	s7,24(sp)
 4d0:	1080                	addi	s0,sp,96
 4d2:	8baa                	mv	s7,a0
 4d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4d6:	892a                	mv	s2,a0
 4d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4da:	4aa9                	li	s5,10
 4dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 4de:	89a6                	mv	s3,s1
 4e0:	2485                	addiw	s1,s1,1
 4e2:	0344d663          	bge	s1,s4,50e <gets+0x52>
    cc = read(0, &c, 1);
 4e6:	4605                	li	a2,1
 4e8:	faf40593          	addi	a1,s0,-81
 4ec:	4501                	li	a0,0
 4ee:	1b2000ef          	jal	6a0 <read>
    if(cc < 1)
 4f2:	00a05e63          	blez	a0,50e <gets+0x52>
    buf[i++] = c;
 4f6:	faf44783          	lbu	a5,-81(s0)
 4fa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4fe:	01578763          	beq	a5,s5,50c <gets+0x50>
 502:	0905                	addi	s2,s2,1
 504:	fd679de3          	bne	a5,s6,4de <gets+0x22>
    buf[i++] = c;
 508:	89a6                	mv	s3,s1
 50a:	a011                	j	50e <gets+0x52>
 50c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 50e:	99de                	add	s3,s3,s7
 510:	00098023          	sb	zero,0(s3)
  return buf;
}
 514:	855e                	mv	a0,s7
 516:	60e6                	ld	ra,88(sp)
 518:	6446                	ld	s0,80(sp)
 51a:	64a6                	ld	s1,72(sp)
 51c:	6906                	ld	s2,64(sp)
 51e:	79e2                	ld	s3,56(sp)
 520:	7a42                	ld	s4,48(sp)
 522:	7aa2                	ld	s5,40(sp)
 524:	7b02                	ld	s6,32(sp)
 526:	6be2                	ld	s7,24(sp)
 528:	6125                	addi	sp,sp,96
 52a:	8082                	ret

000000000000052c <stat>:

int
stat(const char *n, struct stat *st)
{
 52c:	1101                	addi	sp,sp,-32
 52e:	ec06                	sd	ra,24(sp)
 530:	e822                	sd	s0,16(sp)
 532:	e04a                	sd	s2,0(sp)
 534:	1000                	addi	s0,sp,32
 536:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 538:	4581                	li	a1,0
 53a:	18e000ef          	jal	6c8 <open>
  if(fd < 0)
 53e:	02054263          	bltz	a0,562 <stat+0x36>
 542:	e426                	sd	s1,8(sp)
 544:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 546:	85ca                	mv	a1,s2
 548:	198000ef          	jal	6e0 <fstat>
 54c:	892a                	mv	s2,a0
  close(fd);
 54e:	8526                	mv	a0,s1
 550:	160000ef          	jal	6b0 <close>
  return r;
 554:	64a2                	ld	s1,8(sp)
}
 556:	854a                	mv	a0,s2
 558:	60e2                	ld	ra,24(sp)
 55a:	6442                	ld	s0,16(sp)
 55c:	6902                	ld	s2,0(sp)
 55e:	6105                	addi	sp,sp,32
 560:	8082                	ret
    return -1;
 562:	597d                	li	s2,-1
 564:	bfcd                	j	556 <stat+0x2a>

0000000000000566 <atoi>:

int
atoi(const char *s)
{
 566:	1141                	addi	sp,sp,-16
 568:	e422                	sd	s0,8(sp)
 56a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 56c:	00054683          	lbu	a3,0(a0)
 570:	fd06879b          	addiw	a5,a3,-48
 574:	0ff7f793          	zext.b	a5,a5
 578:	4625                	li	a2,9
 57a:	02f66863          	bltu	a2,a5,5aa <atoi+0x44>
 57e:	872a                	mv	a4,a0
  n = 0;
 580:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 582:	0705                	addi	a4,a4,1
 584:	0025179b          	slliw	a5,a0,0x2
 588:	9fa9                	addw	a5,a5,a0
 58a:	0017979b          	slliw	a5,a5,0x1
 58e:	9fb5                	addw	a5,a5,a3
 590:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 594:	00074683          	lbu	a3,0(a4)
 598:	fd06879b          	addiw	a5,a3,-48
 59c:	0ff7f793          	zext.b	a5,a5
 5a0:	fef671e3          	bgeu	a2,a5,582 <atoi+0x1c>
  return n;
}
 5a4:	6422                	ld	s0,8(sp)
 5a6:	0141                	addi	sp,sp,16
 5a8:	8082                	ret
  n = 0;
 5aa:	4501                	li	a0,0
 5ac:	bfe5                	j	5a4 <atoi+0x3e>

00000000000005ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5ae:	1141                	addi	sp,sp,-16
 5b0:	e422                	sd	s0,8(sp)
 5b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5b4:	02b57463          	bgeu	a0,a1,5dc <memmove+0x2e>
    while(n-- > 0)
 5b8:	00c05f63          	blez	a2,5d6 <memmove+0x28>
 5bc:	1602                	slli	a2,a2,0x20
 5be:	9201                	srli	a2,a2,0x20
 5c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 5c6:	0585                	addi	a1,a1,1
 5c8:	0705                	addi	a4,a4,1
 5ca:	fff5c683          	lbu	a3,-1(a1)
 5ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5d2:	fef71ae3          	bne	a4,a5,5c6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5d6:	6422                	ld	s0,8(sp)
 5d8:	0141                	addi	sp,sp,16
 5da:	8082                	ret
    dst += n;
 5dc:	00c50733          	add	a4,a0,a2
    src += n;
 5e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 5e2:	fec05ae3          	blez	a2,5d6 <memmove+0x28>
 5e6:	fff6079b          	addiw	a5,a2,-1
 5ea:	1782                	slli	a5,a5,0x20
 5ec:	9381                	srli	a5,a5,0x20
 5ee:	fff7c793          	not	a5,a5
 5f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5f4:	15fd                	addi	a1,a1,-1
 5f6:	177d                	addi	a4,a4,-1
 5f8:	0005c683          	lbu	a3,0(a1)
 5fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 600:	fee79ae3          	bne	a5,a4,5f4 <memmove+0x46>
 604:	bfc9                	j	5d6 <memmove+0x28>

0000000000000606 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 606:	1141                	addi	sp,sp,-16
 608:	e422                	sd	s0,8(sp)
 60a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 60c:	ca05                	beqz	a2,63c <memcmp+0x36>
 60e:	fff6069b          	addiw	a3,a2,-1
 612:	1682                	slli	a3,a3,0x20
 614:	9281                	srli	a3,a3,0x20
 616:	0685                	addi	a3,a3,1
 618:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 61a:	00054783          	lbu	a5,0(a0)
 61e:	0005c703          	lbu	a4,0(a1)
 622:	00e79863          	bne	a5,a4,632 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 626:	0505                	addi	a0,a0,1
    p2++;
 628:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 62a:	fed518e3          	bne	a0,a3,61a <memcmp+0x14>
  }
  return 0;
 62e:	4501                	li	a0,0
 630:	a019                	j	636 <memcmp+0x30>
      return *p1 - *p2;
 632:	40e7853b          	subw	a0,a5,a4
}
 636:	6422                	ld	s0,8(sp)
 638:	0141                	addi	sp,sp,16
 63a:	8082                	ret
  return 0;
 63c:	4501                	li	a0,0
 63e:	bfe5                	j	636 <memcmp+0x30>

0000000000000640 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 640:	1141                	addi	sp,sp,-16
 642:	e406                	sd	ra,8(sp)
 644:	e022                	sd	s0,0(sp)
 646:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 648:	f67ff0ef          	jal	5ae <memmove>
}
 64c:	60a2                	ld	ra,8(sp)
 64e:	6402                	ld	s0,0(sp)
 650:	0141                	addi	sp,sp,16
 652:	8082                	ret

0000000000000654 <sbrk>:

char *
sbrk(int n) {
 654:	1141                	addi	sp,sp,-16
 656:	e406                	sd	ra,8(sp)
 658:	e022                	sd	s0,0(sp)
 65a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 65c:	4585                	li	a1,1
 65e:	0b2000ef          	jal	710 <sys_sbrk>
}
 662:	60a2                	ld	ra,8(sp)
 664:	6402                	ld	s0,0(sp)
 666:	0141                	addi	sp,sp,16
 668:	8082                	ret

000000000000066a <sbrklazy>:

char *
sbrklazy(int n) {
 66a:	1141                	addi	sp,sp,-16
 66c:	e406                	sd	ra,8(sp)
 66e:	e022                	sd	s0,0(sp)
 670:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 672:	4589                	li	a1,2
 674:	09c000ef          	jal	710 <sys_sbrk>
}
 678:	60a2                	ld	ra,8(sp)
 67a:	6402                	ld	s0,0(sp)
 67c:	0141                	addi	sp,sp,16
 67e:	8082                	ret

0000000000000680 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 680:	4885                	li	a7,1
 ecall
 682:	00000073          	ecall
 ret
 686:	8082                	ret

0000000000000688 <exit>:
.global exit
exit:
 li a7, SYS_exit
 688:	4889                	li	a7,2
 ecall
 68a:	00000073          	ecall
 ret
 68e:	8082                	ret

0000000000000690 <wait>:
.global wait
wait:
 li a7, SYS_wait
 690:	488d                	li	a7,3
 ecall
 692:	00000073          	ecall
 ret
 696:	8082                	ret

0000000000000698 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 698:	4891                	li	a7,4
 ecall
 69a:	00000073          	ecall
 ret
 69e:	8082                	ret

00000000000006a0 <read>:
.global read
read:
 li a7, SYS_read
 6a0:	4895                	li	a7,5
 ecall
 6a2:	00000073          	ecall
 ret
 6a6:	8082                	ret

00000000000006a8 <write>:
.global write
write:
 li a7, SYS_write
 6a8:	48c1                	li	a7,16
 ecall
 6aa:	00000073          	ecall
 ret
 6ae:	8082                	ret

00000000000006b0 <close>:
.global close
close:
 li a7, SYS_close
 6b0:	48d5                	li	a7,21
 ecall
 6b2:	00000073          	ecall
 ret
 6b6:	8082                	ret

00000000000006b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 6b8:	4899                	li	a7,6
 ecall
 6ba:	00000073          	ecall
 ret
 6be:	8082                	ret

00000000000006c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6c0:	489d                	li	a7,7
 ecall
 6c2:	00000073          	ecall
 ret
 6c6:	8082                	ret

00000000000006c8 <open>:
.global open
open:
 li a7, SYS_open
 6c8:	48bd                	li	a7,15
 ecall
 6ca:	00000073          	ecall
 ret
 6ce:	8082                	ret

00000000000006d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6d0:	48c5                	li	a7,17
 ecall
 6d2:	00000073          	ecall
 ret
 6d6:	8082                	ret

00000000000006d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6d8:	48c9                	li	a7,18
 ecall
 6da:	00000073          	ecall
 ret
 6de:	8082                	ret

00000000000006e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6e0:	48a1                	li	a7,8
 ecall
 6e2:	00000073          	ecall
 ret
 6e6:	8082                	ret

00000000000006e8 <link>:
.global link
link:
 li a7, SYS_link
 6e8:	48cd                	li	a7,19
 ecall
 6ea:	00000073          	ecall
 ret
 6ee:	8082                	ret

00000000000006f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6f0:	48d1                	li	a7,20
 ecall
 6f2:	00000073          	ecall
 ret
 6f6:	8082                	ret

00000000000006f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6f8:	48a5                	li	a7,9
 ecall
 6fa:	00000073          	ecall
 ret
 6fe:	8082                	ret

0000000000000700 <dup>:
.global dup
dup:
 li a7, SYS_dup
 700:	48a9                	li	a7,10
 ecall
 702:	00000073          	ecall
 ret
 706:	8082                	ret

0000000000000708 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 708:	48ad                	li	a7,11
 ecall
 70a:	00000073          	ecall
 ret
 70e:	8082                	ret

0000000000000710 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 710:	48b1                	li	a7,12
 ecall
 712:	00000073          	ecall
 ret
 716:	8082                	ret

0000000000000718 <pause>:
.global pause
pause:
 li a7, SYS_pause
 718:	48b5                	li	a7,13
 ecall
 71a:	00000073          	ecall
 ret
 71e:	8082                	ret

0000000000000720 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 720:	48b9                	li	a7,14
 ecall
 722:	00000073          	ecall
 ret
 726:	8082                	ret

0000000000000728 <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 728:	48d9                	li	a7,22
 ecall
 72a:	00000073          	ecall
 ret
 72e:	8082                	ret

0000000000000730 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 730:	48dd                	li	a7,23
 ecall
 732:	00000073          	ecall
 ret
 736:	8082                	ret

0000000000000738 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 738:	1101                	addi	sp,sp,-32
 73a:	ec06                	sd	ra,24(sp)
 73c:	e822                	sd	s0,16(sp)
 73e:	1000                	addi	s0,sp,32
 740:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 744:	4605                	li	a2,1
 746:	fef40593          	addi	a1,s0,-17
 74a:	f5fff0ef          	jal	6a8 <write>
}
 74e:	60e2                	ld	ra,24(sp)
 750:	6442                	ld	s0,16(sp)
 752:	6105                	addi	sp,sp,32
 754:	8082                	ret

0000000000000756 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 756:	715d                	addi	sp,sp,-80
 758:	e486                	sd	ra,72(sp)
 75a:	e0a2                	sd	s0,64(sp)
 75c:	f84a                	sd	s2,48(sp)
 75e:	0880                	addi	s0,sp,80
 760:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 762:	c299                	beqz	a3,768 <printint+0x12>
 764:	0805c363          	bltz	a1,7ea <printint+0x94>
  neg = 0;
 768:	4881                	li	a7,0
 76a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 76e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 770:	00001517          	auipc	a0,0x1
 774:	b7050513          	addi	a0,a0,-1168 # 12e0 <digits>
 778:	883e                	mv	a6,a5
 77a:	2785                	addiw	a5,a5,1
 77c:	02c5f733          	remu	a4,a1,a2
 780:	972a                	add	a4,a4,a0
 782:	00074703          	lbu	a4,0(a4)
 786:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 78a:	872e                	mv	a4,a1
 78c:	02c5d5b3          	divu	a1,a1,a2
 790:	0685                	addi	a3,a3,1
 792:	fec773e3          	bgeu	a4,a2,778 <printint+0x22>
  if(neg)
 796:	00088b63          	beqz	a7,7ac <printint+0x56>
    buf[i++] = '-';
 79a:	fd078793          	addi	a5,a5,-48
 79e:	97a2                	add	a5,a5,s0
 7a0:	02d00713          	li	a4,45
 7a4:	fee78423          	sb	a4,-24(a5)
 7a8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 7ac:	02f05a63          	blez	a5,7e0 <printint+0x8a>
 7b0:	fc26                	sd	s1,56(sp)
 7b2:	f44e                	sd	s3,40(sp)
 7b4:	fb840713          	addi	a4,s0,-72
 7b8:	00f704b3          	add	s1,a4,a5
 7bc:	fff70993          	addi	s3,a4,-1
 7c0:	99be                	add	s3,s3,a5
 7c2:	37fd                	addiw	a5,a5,-1
 7c4:	1782                	slli	a5,a5,0x20
 7c6:	9381                	srli	a5,a5,0x20
 7c8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 7cc:	fff4c583          	lbu	a1,-1(s1)
 7d0:	854a                	mv	a0,s2
 7d2:	f67ff0ef          	jal	738 <putc>
  while(--i >= 0)
 7d6:	14fd                	addi	s1,s1,-1
 7d8:	ff349ae3          	bne	s1,s3,7cc <printint+0x76>
 7dc:	74e2                	ld	s1,56(sp)
 7de:	79a2                	ld	s3,40(sp)
}
 7e0:	60a6                	ld	ra,72(sp)
 7e2:	6406                	ld	s0,64(sp)
 7e4:	7942                	ld	s2,48(sp)
 7e6:	6161                	addi	sp,sp,80
 7e8:	8082                	ret
    x = -xx;
 7ea:	40b005b3          	neg	a1,a1
    neg = 1;
 7ee:	4885                	li	a7,1
    x = -xx;
 7f0:	bfad                	j	76a <printint+0x14>

00000000000007f2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7f2:	711d                	addi	sp,sp,-96
 7f4:	ec86                	sd	ra,88(sp)
 7f6:	e8a2                	sd	s0,80(sp)
 7f8:	e0ca                	sd	s2,64(sp)
 7fa:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7fc:	0005c903          	lbu	s2,0(a1)
 800:	28090663          	beqz	s2,a8c <vprintf+0x29a>
 804:	e4a6                	sd	s1,72(sp)
 806:	fc4e                	sd	s3,56(sp)
 808:	f852                	sd	s4,48(sp)
 80a:	f456                	sd	s5,40(sp)
 80c:	f05a                	sd	s6,32(sp)
 80e:	ec5e                	sd	s7,24(sp)
 810:	e862                	sd	s8,16(sp)
 812:	e466                	sd	s9,8(sp)
 814:	8b2a                	mv	s6,a0
 816:	8a2e                	mv	s4,a1
 818:	8bb2                	mv	s7,a2
  state = 0;
 81a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 81c:	4481                	li	s1,0
 81e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 820:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 824:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 828:	06c00c93          	li	s9,108
 82c:	a005                	j	84c <vprintf+0x5a>
        putc(fd, c0);
 82e:	85ca                	mv	a1,s2
 830:	855a                	mv	a0,s6
 832:	f07ff0ef          	jal	738 <putc>
 836:	a019                	j	83c <vprintf+0x4a>
    } else if(state == '%'){
 838:	03598263          	beq	s3,s5,85c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 83c:	2485                	addiw	s1,s1,1
 83e:	8726                	mv	a4,s1
 840:	009a07b3          	add	a5,s4,s1
 844:	0007c903          	lbu	s2,0(a5)
 848:	22090a63          	beqz	s2,a7c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 84c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 850:	fe0994e3          	bnez	s3,838 <vprintf+0x46>
      if(c0 == '%'){
 854:	fd579de3          	bne	a5,s5,82e <vprintf+0x3c>
        state = '%';
 858:	89be                	mv	s3,a5
 85a:	b7cd                	j	83c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 85c:	00ea06b3          	add	a3,s4,a4
 860:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 864:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 866:	c681                	beqz	a3,86e <vprintf+0x7c>
 868:	9752                	add	a4,a4,s4
 86a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 86e:	05878363          	beq	a5,s8,8b4 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 872:	05978d63          	beq	a5,s9,8cc <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 876:	07500713          	li	a4,117
 87a:	0ee78763          	beq	a5,a4,968 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 87e:	07800713          	li	a4,120
 882:	12e78963          	beq	a5,a4,9b4 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 886:	07000713          	li	a4,112
 88a:	14e78e63          	beq	a5,a4,9e6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 88e:	06300713          	li	a4,99
 892:	18e78e63          	beq	a5,a4,a2e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 896:	07300713          	li	a4,115
 89a:	1ae78463          	beq	a5,a4,a42 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 89e:	02500713          	li	a4,37
 8a2:	04e79563          	bne	a5,a4,8ec <vprintf+0xfa>
        putc(fd, '%');
 8a6:	02500593          	li	a1,37
 8aa:	855a                	mv	a0,s6
 8ac:	e8dff0ef          	jal	738 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 8b0:	4981                	li	s3,0
 8b2:	b769                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 8b4:	008b8913          	addi	s2,s7,8
 8b8:	4685                	li	a3,1
 8ba:	4629                	li	a2,10
 8bc:	000ba583          	lw	a1,0(s7)
 8c0:	855a                	mv	a0,s6
 8c2:	e95ff0ef          	jal	756 <printint>
 8c6:	8bca                	mv	s7,s2
      state = 0;
 8c8:	4981                	li	s3,0
 8ca:	bf8d                	j	83c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 8cc:	06400793          	li	a5,100
 8d0:	02f68963          	beq	a3,a5,902 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8d4:	06c00793          	li	a5,108
 8d8:	04f68263          	beq	a3,a5,91c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 8dc:	07500793          	li	a5,117
 8e0:	0af68063          	beq	a3,a5,980 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 8e4:	07800793          	li	a5,120
 8e8:	0ef68263          	beq	a3,a5,9cc <vprintf+0x1da>
        putc(fd, '%');
 8ec:	02500593          	li	a1,37
 8f0:	855a                	mv	a0,s6
 8f2:	e47ff0ef          	jal	738 <putc>
        putc(fd, c0);
 8f6:	85ca                	mv	a1,s2
 8f8:	855a                	mv	a0,s6
 8fa:	e3fff0ef          	jal	738 <putc>
      state = 0;
 8fe:	4981                	li	s3,0
 900:	bf35                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 902:	008b8913          	addi	s2,s7,8
 906:	4685                	li	a3,1
 908:	4629                	li	a2,10
 90a:	000bb583          	ld	a1,0(s7)
 90e:	855a                	mv	a0,s6
 910:	e47ff0ef          	jal	756 <printint>
        i += 1;
 914:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 916:	8bca                	mv	s7,s2
      state = 0;
 918:	4981                	li	s3,0
        i += 1;
 91a:	b70d                	j	83c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 91c:	06400793          	li	a5,100
 920:	02f60763          	beq	a2,a5,94e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 924:	07500793          	li	a5,117
 928:	06f60963          	beq	a2,a5,99a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 92c:	07800793          	li	a5,120
 930:	faf61ee3          	bne	a2,a5,8ec <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 934:	008b8913          	addi	s2,s7,8
 938:	4681                	li	a3,0
 93a:	4641                	li	a2,16
 93c:	000bb583          	ld	a1,0(s7)
 940:	855a                	mv	a0,s6
 942:	e15ff0ef          	jal	756 <printint>
        i += 2;
 946:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 948:	8bca                	mv	s7,s2
      state = 0;
 94a:	4981                	li	s3,0
        i += 2;
 94c:	bdc5                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 94e:	008b8913          	addi	s2,s7,8
 952:	4685                	li	a3,1
 954:	4629                	li	a2,10
 956:	000bb583          	ld	a1,0(s7)
 95a:	855a                	mv	a0,s6
 95c:	dfbff0ef          	jal	756 <printint>
        i += 2;
 960:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 962:	8bca                	mv	s7,s2
      state = 0;
 964:	4981                	li	s3,0
        i += 2;
 966:	bdd9                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 968:	008b8913          	addi	s2,s7,8
 96c:	4681                	li	a3,0
 96e:	4629                	li	a2,10
 970:	000be583          	lwu	a1,0(s7)
 974:	855a                	mv	a0,s6
 976:	de1ff0ef          	jal	756 <printint>
 97a:	8bca                	mv	s7,s2
      state = 0;
 97c:	4981                	li	s3,0
 97e:	bd7d                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 980:	008b8913          	addi	s2,s7,8
 984:	4681                	li	a3,0
 986:	4629                	li	a2,10
 988:	000bb583          	ld	a1,0(s7)
 98c:	855a                	mv	a0,s6
 98e:	dc9ff0ef          	jal	756 <printint>
        i += 1;
 992:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 994:	8bca                	mv	s7,s2
      state = 0;
 996:	4981                	li	s3,0
        i += 1;
 998:	b555                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 99a:	008b8913          	addi	s2,s7,8
 99e:	4681                	li	a3,0
 9a0:	4629                	li	a2,10
 9a2:	000bb583          	ld	a1,0(s7)
 9a6:	855a                	mv	a0,s6
 9a8:	dafff0ef          	jal	756 <printint>
        i += 2;
 9ac:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ae:	8bca                	mv	s7,s2
      state = 0;
 9b0:	4981                	li	s3,0
        i += 2;
 9b2:	b569                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 9b4:	008b8913          	addi	s2,s7,8
 9b8:	4681                	li	a3,0
 9ba:	4641                	li	a2,16
 9bc:	000be583          	lwu	a1,0(s7)
 9c0:	855a                	mv	a0,s6
 9c2:	d95ff0ef          	jal	756 <printint>
 9c6:	8bca                	mv	s7,s2
      state = 0;
 9c8:	4981                	li	s3,0
 9ca:	bd8d                	j	83c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 9cc:	008b8913          	addi	s2,s7,8
 9d0:	4681                	li	a3,0
 9d2:	4641                	li	a2,16
 9d4:	000bb583          	ld	a1,0(s7)
 9d8:	855a                	mv	a0,s6
 9da:	d7dff0ef          	jal	756 <printint>
        i += 1;
 9de:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 9e0:	8bca                	mv	s7,s2
      state = 0;
 9e2:	4981                	li	s3,0
        i += 1;
 9e4:	bda1                	j	83c <vprintf+0x4a>
 9e6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 9e8:	008b8d13          	addi	s10,s7,8
 9ec:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 9f0:	03000593          	li	a1,48
 9f4:	855a                	mv	a0,s6
 9f6:	d43ff0ef          	jal	738 <putc>
  putc(fd, 'x');
 9fa:	07800593          	li	a1,120
 9fe:	855a                	mv	a0,s6
 a00:	d39ff0ef          	jal	738 <putc>
 a04:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a06:	00001b97          	auipc	s7,0x1
 a0a:	8dab8b93          	addi	s7,s7,-1830 # 12e0 <digits>
 a0e:	03c9d793          	srli	a5,s3,0x3c
 a12:	97de                	add	a5,a5,s7
 a14:	0007c583          	lbu	a1,0(a5)
 a18:	855a                	mv	a0,s6
 a1a:	d1fff0ef          	jal	738 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a1e:	0992                	slli	s3,s3,0x4
 a20:	397d                	addiw	s2,s2,-1
 a22:	fe0916e3          	bnez	s2,a0e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 a26:	8bea                	mv	s7,s10
      state = 0;
 a28:	4981                	li	s3,0
 a2a:	6d02                	ld	s10,0(sp)
 a2c:	bd01                	j	83c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 a2e:	008b8913          	addi	s2,s7,8
 a32:	000bc583          	lbu	a1,0(s7)
 a36:	855a                	mv	a0,s6
 a38:	d01ff0ef          	jal	738 <putc>
 a3c:	8bca                	mv	s7,s2
      state = 0;
 a3e:	4981                	li	s3,0
 a40:	bbf5                	j	83c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 a42:	008b8993          	addi	s3,s7,8
 a46:	000bb903          	ld	s2,0(s7)
 a4a:	00090f63          	beqz	s2,a68 <vprintf+0x276>
        for(; *s; s++)
 a4e:	00094583          	lbu	a1,0(s2)
 a52:	c195                	beqz	a1,a76 <vprintf+0x284>
          putc(fd, *s);
 a54:	855a                	mv	a0,s6
 a56:	ce3ff0ef          	jal	738 <putc>
        for(; *s; s++)
 a5a:	0905                	addi	s2,s2,1
 a5c:	00094583          	lbu	a1,0(s2)
 a60:	f9f5                	bnez	a1,a54 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 a62:	8bce                	mv	s7,s3
      state = 0;
 a64:	4981                	li	s3,0
 a66:	bbd9                	j	83c <vprintf+0x4a>
          s = "(null)";
 a68:	00001917          	auipc	s2,0x1
 a6c:	87090913          	addi	s2,s2,-1936 # 12d8 <malloc+0x764>
        for(; *s; s++)
 a70:	02800593          	li	a1,40
 a74:	b7c5                	j	a54 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 a76:	8bce                	mv	s7,s3
      state = 0;
 a78:	4981                	li	s3,0
 a7a:	b3c9                	j	83c <vprintf+0x4a>
 a7c:	64a6                	ld	s1,72(sp)
 a7e:	79e2                	ld	s3,56(sp)
 a80:	7a42                	ld	s4,48(sp)
 a82:	7aa2                	ld	s5,40(sp)
 a84:	7b02                	ld	s6,32(sp)
 a86:	6be2                	ld	s7,24(sp)
 a88:	6c42                	ld	s8,16(sp)
 a8a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 a8c:	60e6                	ld	ra,88(sp)
 a8e:	6446                	ld	s0,80(sp)
 a90:	6906                	ld	s2,64(sp)
 a92:	6125                	addi	sp,sp,96
 a94:	8082                	ret

0000000000000a96 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a96:	715d                	addi	sp,sp,-80
 a98:	ec06                	sd	ra,24(sp)
 a9a:	e822                	sd	s0,16(sp)
 a9c:	1000                	addi	s0,sp,32
 a9e:	e010                	sd	a2,0(s0)
 aa0:	e414                	sd	a3,8(s0)
 aa2:	e818                	sd	a4,16(s0)
 aa4:	ec1c                	sd	a5,24(s0)
 aa6:	03043023          	sd	a6,32(s0)
 aaa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 aae:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ab2:	8622                	mv	a2,s0
 ab4:	d3fff0ef          	jal	7f2 <vprintf>
}
 ab8:	60e2                	ld	ra,24(sp)
 aba:	6442                	ld	s0,16(sp)
 abc:	6161                	addi	sp,sp,80
 abe:	8082                	ret

0000000000000ac0 <printf>:

void
printf(const char *fmt, ...)
{
 ac0:	711d                	addi	sp,sp,-96
 ac2:	ec06                	sd	ra,24(sp)
 ac4:	e822                	sd	s0,16(sp)
 ac6:	1000                	addi	s0,sp,32
 ac8:	e40c                	sd	a1,8(s0)
 aca:	e810                	sd	a2,16(s0)
 acc:	ec14                	sd	a3,24(s0)
 ace:	f018                	sd	a4,32(s0)
 ad0:	f41c                	sd	a5,40(s0)
 ad2:	03043823          	sd	a6,48(s0)
 ad6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ada:	00840613          	addi	a2,s0,8
 ade:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ae2:	85aa                	mv	a1,a0
 ae4:	4505                	li	a0,1
 ae6:	d0dff0ef          	jal	7f2 <vprintf>
}
 aea:	60e2                	ld	ra,24(sp)
 aec:	6442                	ld	s0,16(sp)
 aee:	6125                	addi	sp,sp,96
 af0:	8082                	ret

0000000000000af2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 af2:	1141                	addi	sp,sp,-16
 af4:	e422                	sd	s0,8(sp)
 af6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 af8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 afc:	00001797          	auipc	a5,0x1
 b00:	5047b783          	ld	a5,1284(a5) # 2000 <freep>
 b04:	a02d                	j	b2e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b06:	4618                	lw	a4,8(a2)
 b08:	9f2d                	addw	a4,a4,a1
 b0a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b0e:	6398                	ld	a4,0(a5)
 b10:	6310                	ld	a2,0(a4)
 b12:	a83d                	j	b50 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b14:	ff852703          	lw	a4,-8(a0)
 b18:	9f31                	addw	a4,a4,a2
 b1a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b1c:	ff053683          	ld	a3,-16(a0)
 b20:	a091                	j	b64 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b22:	6398                	ld	a4,0(a5)
 b24:	00e7e463          	bltu	a5,a4,b2c <free+0x3a>
 b28:	00e6ea63          	bltu	a3,a4,b3c <free+0x4a>
{
 b2c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b2e:	fed7fae3          	bgeu	a5,a3,b22 <free+0x30>
 b32:	6398                	ld	a4,0(a5)
 b34:	00e6e463          	bltu	a3,a4,b3c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b38:	fee7eae3          	bltu	a5,a4,b2c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 b3c:	ff852583          	lw	a1,-8(a0)
 b40:	6390                	ld	a2,0(a5)
 b42:	02059813          	slli	a6,a1,0x20
 b46:	01c85713          	srli	a4,a6,0x1c
 b4a:	9736                	add	a4,a4,a3
 b4c:	fae60de3          	beq	a2,a4,b06 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b50:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b54:	4790                	lw	a2,8(a5)
 b56:	02061593          	slli	a1,a2,0x20
 b5a:	01c5d713          	srli	a4,a1,0x1c
 b5e:	973e                	add	a4,a4,a5
 b60:	fae68ae3          	beq	a3,a4,b14 <free+0x22>
    p->s.ptr = bp->s.ptr;
 b64:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b66:	00001717          	auipc	a4,0x1
 b6a:	48f73d23          	sd	a5,1178(a4) # 2000 <freep>
}
 b6e:	6422                	ld	s0,8(sp)
 b70:	0141                	addi	sp,sp,16
 b72:	8082                	ret

0000000000000b74 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b74:	7139                	addi	sp,sp,-64
 b76:	fc06                	sd	ra,56(sp)
 b78:	f822                	sd	s0,48(sp)
 b7a:	f426                	sd	s1,40(sp)
 b7c:	ec4e                	sd	s3,24(sp)
 b7e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b80:	02051493          	slli	s1,a0,0x20
 b84:	9081                	srli	s1,s1,0x20
 b86:	04bd                	addi	s1,s1,15
 b88:	8091                	srli	s1,s1,0x4
 b8a:	0014899b          	addiw	s3,s1,1
 b8e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b90:	00001517          	auipc	a0,0x1
 b94:	47053503          	ld	a0,1136(a0) # 2000 <freep>
 b98:	c915                	beqz	a0,bcc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b9a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b9c:	4798                	lw	a4,8(a5)
 b9e:	08977a63          	bgeu	a4,s1,c32 <malloc+0xbe>
 ba2:	f04a                	sd	s2,32(sp)
 ba4:	e852                	sd	s4,16(sp)
 ba6:	e456                	sd	s5,8(sp)
 ba8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 baa:	8a4e                	mv	s4,s3
 bac:	0009871b          	sext.w	a4,s3
 bb0:	6685                	lui	a3,0x1
 bb2:	00d77363          	bgeu	a4,a3,bb8 <malloc+0x44>
 bb6:	6a05                	lui	s4,0x1
 bb8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bbc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bc0:	00001917          	auipc	s2,0x1
 bc4:	44090913          	addi	s2,s2,1088 # 2000 <freep>
  if(p == SBRK_ERROR)
 bc8:	5afd                	li	s5,-1
 bca:	a081                	j	c0a <malloc+0x96>
 bcc:	f04a                	sd	s2,32(sp)
 bce:	e852                	sd	s4,16(sp)
 bd0:	e456                	sd	s5,8(sp)
 bd2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 bd4:	00001797          	auipc	a5,0x1
 bd8:	43c78793          	addi	a5,a5,1084 # 2010 <base>
 bdc:	00001717          	auipc	a4,0x1
 be0:	42f73223          	sd	a5,1060(a4) # 2000 <freep>
 be4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 be6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bea:	b7c1                	j	baa <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 bec:	6398                	ld	a4,0(a5)
 bee:	e118                	sd	a4,0(a0)
 bf0:	a8a9                	j	c4a <malloc+0xd6>
  hp->s.size = nu;
 bf2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bf6:	0541                	addi	a0,a0,16
 bf8:	efbff0ef          	jal	af2 <free>
  return freep;
 bfc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c00:	c12d                	beqz	a0,c62 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c02:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c04:	4798                	lw	a4,8(a5)
 c06:	02977263          	bgeu	a4,s1,c2a <malloc+0xb6>
    if(p == freep)
 c0a:	00093703          	ld	a4,0(s2)
 c0e:	853e                	mv	a0,a5
 c10:	fef719e3          	bne	a4,a5,c02 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 c14:	8552                	mv	a0,s4
 c16:	a3fff0ef          	jal	654 <sbrk>
  if(p == SBRK_ERROR)
 c1a:	fd551ce3          	bne	a0,s5,bf2 <malloc+0x7e>
        return 0;
 c1e:	4501                	li	a0,0
 c20:	7902                	ld	s2,32(sp)
 c22:	6a42                	ld	s4,16(sp)
 c24:	6aa2                	ld	s5,8(sp)
 c26:	6b02                	ld	s6,0(sp)
 c28:	a03d                	j	c56 <malloc+0xe2>
 c2a:	7902                	ld	s2,32(sp)
 c2c:	6a42                	ld	s4,16(sp)
 c2e:	6aa2                	ld	s5,8(sp)
 c30:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 c32:	fae48de3          	beq	s1,a4,bec <malloc+0x78>
        p->s.size -= nunits;
 c36:	4137073b          	subw	a4,a4,s3
 c3a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c3c:	02071693          	slli	a3,a4,0x20
 c40:	01c6d713          	srli	a4,a3,0x1c
 c44:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c46:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c4a:	00001717          	auipc	a4,0x1
 c4e:	3aa73b23          	sd	a0,950(a4) # 2000 <freep>
      return (void*)(p + 1);
 c52:	01078513          	addi	a0,a5,16
  }
}
 c56:	70e2                	ld	ra,56(sp)
 c58:	7442                	ld	s0,48(sp)
 c5a:	74a2                	ld	s1,40(sp)
 c5c:	69e2                	ld	s3,24(sp)
 c5e:	6121                	addi	sp,sp,64
 c60:	8082                	ret
 c62:	7902                	ld	s2,32(sp)
 c64:	6a42                	ld	s4,16(sp)
 c66:	6aa2                	ld	s5,8(sp)
 c68:	6b02                	ld	s6,0(sp)
 c6a:	b7f5                	j	c56 <malloc+0xe2>
