
user/_boostlong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_work>:
#include "kernel/stat.h"
#include "user/user.h"

#define WORK_ITERATIONS 5000000

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
  16:	e8380813          	addi	a6,a6,-381 # 431bde83 <base+0x431bbe73>
  1a:	000f45b7          	lui	a1,0xf4
  1e:	2405859b          	addiw	a1,a1,576 # f4240 <base+0xf2230>
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

0000000000000058 <main>:

int
main(int argc, char *argv[])
{
  58:	7175                	addi	sp,sp,-144
  5a:	e506                	sd	ra,136(sp)
  5c:	e122                	sd	s0,128(sp)
  5e:	fca6                	sd	s1,120(sp)
  60:	f8ca                	sd	s2,112(sp)
  62:	f4ce                	sd	s3,104(sp)
  64:	f0d2                	sd	s4,96(sp)
  66:	ecd6                	sd	s5,88(sp)
  68:	e8da                	sd	s6,80(sp)
  6a:	e4de                	sd	s7,72(sp)
  6c:	e0e2                	sd	s8,64(sp)
  6e:	fc66                	sd	s9,56(sp)
  70:	f86a                	sd	s10,48(sp)
  72:	f46e                	sd	s11,40(sp)
  74:	0900                	addi	s0,sp,144
  int start_tick;
  int last_priority = 0;
  int last_slices = 0;
  int boost_count = 0;
  
  printf("\n");
  76:	00001517          	auipc	a0,0x1
  7a:	bfa50513          	addi	a0,a0,-1030 # c70 <malloc+0xf4>
  7e:	247000ef          	jal	ac4 <printf>
  printf("================================================================\n");
  82:	00001517          	auipc	a0,0x1
  86:	bf650513          	addi	a0,a0,-1034 # c78 <malloc+0xfc>
  8a:	23b000ef          	jal	ac4 <printf>
  printf("     MLFQ BOOST TEST - SINGLE PROCESS DETAILED VIEW\n");
  8e:	00001517          	auipc	a0,0x1
  92:	c3250513          	addi	a0,a0,-974 # cc0 <malloc+0x144>
  96:	22f000ef          	jal	ac4 <printf>
  printf("================================================================\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	bde50513          	addi	a0,a0,-1058 # c78 <malloc+0xfc>
  a2:	223000ef          	jal	ac4 <printf>
  printf("  Time Quanta: Q0=2, Q1=4, Q2=8, Q3=16 ticks\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	c5250513          	addi	a0,a0,-942 # cf8 <malloc+0x17c>
  ae:	217000ef          	jal	ac4 <printf>
  printf("  Boost Interval: Every 50 ticks all processes -> Q0\n");
  b2:	00001517          	auipc	a0,0x1
  b6:	c7650513          	addi	a0,a0,-906 # d28 <malloc+0x1ac>
  ba:	20b000ef          	jal	ac4 <printf>
  printf("  Key Test: Q3 stays at Q3 even after 16+ slices until BOOST\n");
  be:	00001517          	auipc	a0,0x1
  c2:	ca250513          	addi	a0,a0,-862 # d60 <malloc+0x1e4>
  c6:	1ff000ef          	jal	ac4 <printf>
  printf("================================================================\n\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	cd650513          	addi	a0,a0,-810 # da0 <malloc+0x224>
  d2:	1f3000ef          	jal	ac4 <printf>
  
  start_tick = uptime();
  d6:	630000ef          	jal	706 <uptime>
  da:	8b2a                	mv	s6,a0
  getprocinfo(&info);
  dc:	f8040513          	addi	a0,s0,-128
  e0:	62e000ef          	jal	70e <getprocinfo>
  last_priority = info.priority;
  e4:	f8842483          	lw	s1,-120(s0)
  last_slices = info.time_slices;
  e8:	f8c42c03          	lw	s8,-116(s0)
  
  printf("  TICK | QUEUE | SLICES | EVENT\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	cfc50513          	addi	a0,a0,-772 # de8 <malloc+0x26c>
  f4:	1d1000ef          	jal	ac4 <printf>
  printf("  -----+-------+--------+----------------------------------------\n");
  f8:	00001517          	auipc	a0,0x1
  fc:	d1850513          	addi	a0,a0,-744 # e10 <malloc+0x294>
 100:	1c5000ef          	jal	ac4 <printf>
  int reached_q3 = 0;
  int q3_extra_shown = 0;
  int first_boost_seen = 0;
  
  // Run until we see 3 boosts (print after 1st boost, track 2 more)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
 104:	4981                	li	s3,0
  int first_boost_seen = 0;
 106:	4a81                	li	s5,0
  int q3_extra_shown = 0;
 108:	f6043823          	sd	zero,-144(s0)
  int reached_q3 = 0;
 10c:	f6043c23          	sd	zero,-136(s0)
  int boost_count = 0;
 110:	4a01                	li	s4,0
    cpu_work(WORK_ITERATIONS / 5);
 112:	000f4bb7          	lui	s7,0xf4
 116:	240b8b93          	addi	s7,s7,576 # f4240 <base+0xf2230>
    
    getprocinfo(&info);
 11a:	f8040c93          	addi	s9,s0,-128
        reached_q3 = 0;
        q3_extra_shown = 0;
      }
    }
    // Show slice progression at Q3 (especially when slices > 16) - only after first boost
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 11e:	4d8d                	li	s11,3
          printf("  -----+-------+--------+----------------------------------------\n");
 120:	00001d17          	auipc	s10,0x1
 124:	cf0d0d13          	addi	s10,s10,-784 # e10 <malloc+0x294>
 128:	a881                	j	178 <main+0x120>
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 12a:	4811                	li	a6,4
 12c:	a041                	j	1ac <main+0x154>
        boost_count++;
 12e:	001a0c1b          	addiw	s8,s4,1
 132:	8a62                	mv	s4,s8
        if(!first_boost_seen) {
 134:	0c0a9263          	bnez	s5,1f8 <main+0x1a0>
          printf("   %d  |  Q%d   |    %d   | *** BOOST #1 - START TRACKING ***\n",
 138:	f8c42683          	lw	a3,-116(s0)
 13c:	85ca                	mv	a1,s2
 13e:	00001517          	auipc	a0,0x1
 142:	da250513          	addi	a0,a0,-606 # ee0 <malloc+0x364>
 146:	17f000ef          	jal	ac4 <printf>
          printf("  -----+-------+--------+----------------------------------------\n");
 14a:	856a                	mv	a0,s10
 14c:	179000ef          	jal	ac4 <printf>
        q3_extra_shown = 0;
 150:	f7543823          	sd	s5,-144(s0)
        reached_q3 = 0;
 154:	f7543c23          	sd	s5,-136(s0)
          first_boost_seen = 1;
 158:	4a85                	li	s5,1
      printf("   %d  |  Q%d   |    %d   | Running at Q%d (slices: %d)\n",
             current_tick, info.priority, info.time_slices, 
             info.priority, info.time_slices);
    }
    
    last_priority = info.priority;
 15a:	f8842483          	lw	s1,-120(s0)
    last_slices = info.time_slices;
 15e:	f8c42c03          	lw	s8,-116(s0)
  for(int phase = 0; phase < 2000 && boost_count < 3; phase++) {
 162:	0019879b          	addiw	a5,s3,1
 166:	89be                	mv	s3,a5
 168:	7d07a793          	slti	a5,a5,2000
 16c:	14078363          	beqz	a5,2b2 <main+0x25a>
 170:	003a2793          	slti	a5,s4,3
 174:	12078f63          	beqz	a5,2b2 <main+0x25a>
    cpu_work(WORK_ITERATIONS / 5);
 178:	855e                	mv	a0,s7
 17a:	e87ff0ef          	jal	0 <cpu_work>
    getprocinfo(&info);
 17e:	8566                	mv	a0,s9
 180:	58e000ef          	jal	70e <getprocinfo>
    int current_tick = uptime() - start_tick;
 184:	582000ef          	jal	706 <uptime>
 188:	4165093b          	subw	s2,a0,s6
    if(info.priority != last_priority) {
 18c:	f8842603          	lw	a2,-120(s0)
 190:	08960c63          	beq	a2,s1,228 <main+0x1d0>
      if(info.priority > last_priority) {
 194:	f8c4dde3          	bge	s1,a2,12e <main+0xd6>
        if(first_boost_seen) {
 198:	fc0a81e3          	beqz	s5,15a <main+0x102>
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 19c:	f8c42683          	lw	a3,-116(s0)
 1a0:	4809                	li	a6,2
 1a2:	c489                	beqz	s1,1ac <main+0x154>
                 last_priority == 0 ? 2 : (last_priority == 1 ? 4 : 8));
 1a4:	4785                	li	a5,1
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 1a6:	4821                	li	a6,8
                 last_priority == 0 ? 2 : (last_priority == 1 ? 4 : 8));
 1a8:	f8f481e3          	beq	s1,a5,12a <main+0xd2>
          printf("   %d  |  Q%d   |    %d   | DEMOTE Q%d->Q%d (used %d ticks)\n",
 1ac:	87b2                	mv	a5,a2
 1ae:	8726                	mv	a4,s1
 1b0:	85ca                	mv	a1,s2
 1b2:	00001517          	auipc	a0,0x1
 1b6:	ca650513          	addi	a0,a0,-858 # e58 <malloc+0x2dc>
 1ba:	10b000ef          	jal	ac4 <printf>
          if(info.priority == 3 && !reached_q3) {
 1be:	f8842783          	lw	a5,-120(s0)
 1c2:	17f5                	addi	a5,a5,-3
 1c4:	fbd9                	bnez	a5,15a <main+0x102>
 1c6:	f7843783          	ld	a5,-136(s0)
 1ca:	8b85                	andi	a5,a5,1
 1cc:	f7d9                	bnez	a5,15a <main+0x102>
            printf("  -----+-------+--------+----------------------------------------\n");
 1ce:	00001517          	auipc	a0,0x1
 1d2:	c4250513          	addi	a0,a0,-958 # e10 <malloc+0x294>
 1d6:	0ef000ef          	jal	ac4 <printf>
            printf("  >>> Now at LOWEST priority (Q3) - will stay here until BOOST <<<\n");
 1da:	00001517          	auipc	a0,0x1
 1de:	cbe50513          	addi	a0,a0,-834 # e98 <malloc+0x31c>
 1e2:	0e3000ef          	jal	ac4 <printf>
            printf("  -----+-------+--------+----------------------------------------\n");
 1e6:	00001517          	auipc	a0,0x1
 1ea:	c2a50513          	addi	a0,a0,-982 # e10 <malloc+0x294>
 1ee:	0d7000ef          	jal	ac4 <printf>
            reached_q3 = 1;
 1f2:	f7543c23          	sd	s5,-136(s0)
 1f6:	b795                	j	15a <main+0x102>
          printf("  -----+-------+--------+----------------------------------------\n");
 1f8:	856a                	mv	a0,s10
 1fa:	0cb000ef          	jal	ac4 <printf>
          printf("   %d  |  Q%d   |    %d   | *** BOOST #%d! Q%d->Q0 ***\n",
 1fe:	87a6                	mv	a5,s1
 200:	8762                	mv	a4,s8
 202:	f8c42683          	lw	a3,-116(s0)
 206:	f8842603          	lw	a2,-120(s0)
 20a:	85ca                	mv	a1,s2
 20c:	00001517          	auipc	a0,0x1
 210:	d1450513          	addi	a0,a0,-748 # f20 <malloc+0x3a4>
 214:	0b1000ef          	jal	ac4 <printf>
          printf("  -----+-------+--------+----------------------------------------\n");
 218:	856a                	mv	a0,s10
 21a:	0ab000ef          	jal	ac4 <printf>
        q3_extra_shown = 0;
 21e:	f6043823          	sd	zero,-144(s0)
        reached_q3 = 0;
 222:	f6043c23          	sd	zero,-136(s0)
 226:	bf15                	j	15a <main+0x102>
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 228:	f20a89e3          	beqz	s5,15a <main+0x102>
 22c:	03b48463          	beq	s1,s11,254 <main+0x1fc>
    else if(first_boost_seen && info.priority < 3 && info.time_slices != last_slices) {
 230:	4789                	li	a5,2
 232:	f297c4e3          	blt	a5,s1,15a <main+0x102>
 236:	f8c42683          	lw	a3,-116(s0)
 23a:	f38680e3          	beq	a3,s8,15a <main+0x102>
      printf("   %d  |  Q%d   |    %d   | Running at Q%d (slices: %d)\n",
 23e:	87b6                	mv	a5,a3
 240:	8726                	mv	a4,s1
 242:	8626                	mv	a2,s1
 244:	85ca                	mv	a1,s2
 246:	00001517          	auipc	a0,0x1
 24a:	d9a50513          	addi	a0,a0,-614 # fe0 <malloc+0x464>
 24e:	077000ef          	jal	ac4 <printf>
 252:	b721                	j	15a <main+0x102>
    else if(first_boost_seen && info.priority == 3 && info.time_slices != last_slices) {
 254:	f8c42683          	lw	a3,-116(s0)
 258:	f18681e3          	beq	a3,s8,15a <main+0x102>
      if(info.time_slices <= 16 && info.time_slices % 2 == 0) {
 25c:	47c1                	li	a5,16
 25e:	02d7c063          	blt	a5,a3,27e <main+0x226>
 262:	0016f793          	andi	a5,a3,1
 266:	c399                	beqz	a5,26c <main+0x214>
 268:	8abe                	mv	s5,a5
 26a:	bdc5                	j	15a <main+0x102>
        printf("   %d  |  Q%d   |   %d   | Waiting at Q3 (slices: %d/16)\n",
 26c:	8736                	mv	a4,a3
 26e:	460d                	li	a2,3
 270:	85ca                	mv	a1,s2
 272:	00001517          	auipc	a0,0x1
 276:	ce650513          	addi	a0,a0,-794 # f58 <malloc+0x3dc>
 27a:	04b000ef          	jal	ac4 <printf>
      if(info.time_slices > 16 && q3_extra_shown < 5) {
 27e:	f8c42683          	lw	a3,-116(s0)
 282:	f7043783          	ld	a5,-144(s0)
 286:	0057a793          	slti	a5,a5,5
 28a:	ec0788e3          	beqz	a5,15a <main+0x102>
 28e:	47c1                	li	a5,16
 290:	ecd7d5e3          	bge	a5,a3,15a <main+0x102>
        printf("   %d  |  Q%d   |   %d   | STILL Q3! (slices > 16, waiting for boost)\n",
 294:	f8842603          	lw	a2,-120(s0)
 298:	85ca                	mv	a1,s2
 29a:	00001517          	auipc	a0,0x1
 29e:	cfe50513          	addi	a0,a0,-770 # f98 <malloc+0x41c>
 2a2:	023000ef          	jal	ac4 <printf>
        q3_extra_shown++;
 2a6:	f7043783          	ld	a5,-144(s0)
 2aa:	2785                	addiw	a5,a5,1
 2ac:	f6f43823          	sd	a5,-144(s0)
 2b0:	b56d                	j	15a <main+0x102>
  }
  
  printf("\n");
 2b2:	00001517          	auipc	a0,0x1
 2b6:	9be50513          	addi	a0,a0,-1602 # c70 <malloc+0xf4>
 2ba:	00b000ef          	jal	ac4 <printf>
  printf("================================================================\n");
 2be:	00001517          	auipc	a0,0x1
 2c2:	9ba50513          	addi	a0,a0,-1606 # c78 <malloc+0xfc>
 2c6:	7fe000ef          	jal	ac4 <printf>
  printf("                      TEST SUMMARY\n");
 2ca:	00001517          	auipc	a0,0x1
 2ce:	d5650513          	addi	a0,a0,-682 # 1020 <malloc+0x4a4>
 2d2:	7f2000ef          	jal	ac4 <printf>
  printf("================================================================\n");
 2d6:	00001517          	auipc	a0,0x1
 2da:	9a250513          	addi	a0,a0,-1630 # c78 <malloc+0xfc>
 2de:	7e6000ef          	jal	ac4 <printf>
  int total = uptime() - start_tick;
 2e2:	424000ef          	jal	706 <uptime>
 2e6:	416505bb          	subw	a1,a0,s6
  printf("  Total Runtime   : %d ticks (~%d.%d seconds)\n", 
 2ea:	66666637          	lui	a2,0x66666
 2ee:	66760613          	addi	a2,a2,1639 # 66666667 <base+0x66664657>
 2f2:	02c58633          	mul	a2,a1,a2
 2f6:	9609                	srai	a2,a2,0x22
 2f8:	41f5d79b          	sraiw	a5,a1,0x1f
 2fc:	9e1d                	subw	a2,a2,a5
 2fe:	0026169b          	slliw	a3,a2,0x2
 302:	9eb1                	addw	a3,a3,a2
 304:	0016969b          	slliw	a3,a3,0x1
 308:	40d586bb          	subw	a3,a1,a3
 30c:	00001517          	auipc	a0,0x1
 310:	d3c50513          	addi	a0,a0,-708 # 1048 <malloc+0x4cc>
 314:	7b0000ef          	jal	ac4 <printf>
         total, total/10, total%10);
  printf("  Boost Events    : %d automatic boosts detected\n", boost_count);
 318:	85d2                	mv	a1,s4
 31a:	00001517          	auipc	a0,0x1
 31e:	d5e50513          	addi	a0,a0,-674 # 1078 <malloc+0x4fc>
 322:	7a2000ef          	jal	ac4 <printf>
  printf("  Expected Interval: ~50 ticks between boosts\n");
 326:	00001517          	auipc	a0,0x1
 32a:	d8a50513          	addi	a0,a0,-630 # 10b0 <malloc+0x534>
 32e:	796000ef          	jal	ac4 <printf>
  printf("----------------------------------------------------------------\n");
 332:	00001517          	auipc	a0,0x1
 336:	dae50513          	addi	a0,a0,-594 # 10e0 <malloc+0x564>
 33a:	78a000ef          	jal	ac4 <printf>
  if(boost_count >= 3) {
 33e:	4789                	li	a5,2
 340:	0747d563          	bge	a5,s4,3aa <main+0x352>
    printf("  SUCCESS: Priority boosting is working correctly!\n\n");
 344:	00001517          	auipc	a0,0x1
 348:	de450513          	addi	a0,a0,-540 # 1128 <malloc+0x5ac>
 34c:	778000ef          	jal	ac4 <printf>
    printf("  The test demonstrated:\n");
 350:	00001517          	auipc	a0,0x1
 354:	e1050513          	addi	a0,a0,-496 # 1160 <malloc+0x5e4>
 358:	76c000ef          	jal	ac4 <printf>
    printf("    1. Demotion: Q0 -> Q1 -> Q2 -> Q3 (CPU-bound behavior)\n");
 35c:	00001517          	auipc	a0,0x1
 360:	e2450513          	addi	a0,a0,-476 # 1180 <malloc+0x604>
 364:	760000ef          	jal	ac4 <printf>
    printf("    2. Staying at Q3 until boost interval\n");
 368:	00001517          	auipc	a0,0x1
 36c:	e5850513          	addi	a0,a0,-424 # 11c0 <malloc+0x644>
 370:	754000ef          	jal	ac4 <printf>
    printf("    3. Q3 STAYS Q3 even after 16+ slices (no further demotion)\n");
 374:	00001517          	auipc	a0,0x1
 378:	e7c50513          	addi	a0,a0,-388 # 11f0 <malloc+0x674>
 37c:	748000ef          	jal	ac4 <printf>
    printf("    4. Automatic boost back to Q0 (starvation prevention)\n");
 380:	00001517          	auipc	a0,0x1
 384:	eb050513          	addi	a0,a0,-336 # 1230 <malloc+0x6b4>
 388:	73c000ef          	jal	ac4 <printf>
    printf("    5. Multiple boost cycles confirming periodic boosting\n");
 38c:	00001517          	auipc	a0,0x1
 390:	ee450513          	addi	a0,a0,-284 # 1270 <malloc+0x6f4>
 394:	730000ef          	jal	ac4 <printf>
  } else {
    printf("  Test incomplete - try running longer\n");
  }
  printf("================================================================\n\n");
 398:	00001517          	auipc	a0,0x1
 39c:	a0850513          	addi	a0,a0,-1528 # da0 <malloc+0x224>
 3a0:	724000ef          	jal	ac4 <printf>
  
  exit(0);
 3a4:	4501                	li	a0,0
 3a6:	2c8000ef          	jal	66e <exit>
    printf("  Test incomplete - try running longer\n");
 3aa:	00001517          	auipc	a0,0x1
 3ae:	f0650513          	addi	a0,a0,-250 # 12b0 <malloc+0x734>
 3b2:	712000ef          	jal	ac4 <printf>
 3b6:	b7cd                	j	398 <main+0x340>

00000000000003b8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e406                	sd	ra,8(sp)
 3bc:	e022                	sd	s0,0(sp)
 3be:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 3c0:	c99ff0ef          	jal	58 <main>
  exit(r);
 3c4:	2aa000ef          	jal	66e <exit>

00000000000003c8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e406                	sd	ra,8(sp)
 3cc:	e022                	sd	s0,0(sp)
 3ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3d0:	87aa                	mv	a5,a0
 3d2:	0585                	addi	a1,a1,1
 3d4:	0785                	addi	a5,a5,1
 3d6:	fff5c703          	lbu	a4,-1(a1)
 3da:	fee78fa3          	sb	a4,-1(a5)
 3de:	fb75                	bnez	a4,3d2 <strcpy+0xa>
    ;
  return os;
}
 3e0:	60a2                	ld	ra,8(sp)
 3e2:	6402                	ld	s0,0(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret

00000000000003e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3e8:	1141                	addi	sp,sp,-16
 3ea:	e406                	sd	ra,8(sp)
 3ec:	e022                	sd	s0,0(sp)
 3ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3f0:	00054783          	lbu	a5,0(a0)
 3f4:	cb91                	beqz	a5,408 <strcmp+0x20>
 3f6:	0005c703          	lbu	a4,0(a1)
 3fa:	00f71763          	bne	a4,a5,408 <strcmp+0x20>
    p++, q++;
 3fe:	0505                	addi	a0,a0,1
 400:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 402:	00054783          	lbu	a5,0(a0)
 406:	fbe5                	bnez	a5,3f6 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 408:	0005c503          	lbu	a0,0(a1)
}
 40c:	40a7853b          	subw	a0,a5,a0
 410:	60a2                	ld	ra,8(sp)
 412:	6402                	ld	s0,0(sp)
 414:	0141                	addi	sp,sp,16
 416:	8082                	ret

0000000000000418 <strlen>:

uint
strlen(const char *s)
{
 418:	1141                	addi	sp,sp,-16
 41a:	e406                	sd	ra,8(sp)
 41c:	e022                	sd	s0,0(sp)
 41e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 420:	00054783          	lbu	a5,0(a0)
 424:	cf91                	beqz	a5,440 <strlen+0x28>
 426:	00150793          	addi	a5,a0,1
 42a:	86be                	mv	a3,a5
 42c:	0785                	addi	a5,a5,1
 42e:	fff7c703          	lbu	a4,-1(a5)
 432:	ff65                	bnez	a4,42a <strlen+0x12>
 434:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 438:	60a2                	ld	ra,8(sp)
 43a:	6402                	ld	s0,0(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
  for(n = 0; s[n]; n++)
 440:	4501                	li	a0,0
 442:	bfdd                	j	438 <strlen+0x20>

0000000000000444 <memset>:

void*
memset(void *dst, int c, uint n)
{
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 44c:	ca19                	beqz	a2,462 <memset+0x1e>
 44e:	87aa                	mv	a5,a0
 450:	1602                	slli	a2,a2,0x20
 452:	9201                	srli	a2,a2,0x20
 454:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 458:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 45c:	0785                	addi	a5,a5,1
 45e:	fee79de3          	bne	a5,a4,458 <memset+0x14>
  }
  return dst;
}
 462:	60a2                	ld	ra,8(sp)
 464:	6402                	ld	s0,0(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret

000000000000046a <strchr>:

char*
strchr(const char *s, char c)
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e406                	sd	ra,8(sp)
 46e:	e022                	sd	s0,0(sp)
 470:	0800                	addi	s0,sp,16
  for(; *s; s++)
 472:	00054783          	lbu	a5,0(a0)
 476:	cf81                	beqz	a5,48e <strchr+0x24>
    if(*s == c)
 478:	00f58763          	beq	a1,a5,486 <strchr+0x1c>
  for(; *s; s++)
 47c:	0505                	addi	a0,a0,1
 47e:	00054783          	lbu	a5,0(a0)
 482:	fbfd                	bnez	a5,478 <strchr+0xe>
      return (char*)s;
  return 0;
 484:	4501                	li	a0,0
}
 486:	60a2                	ld	ra,8(sp)
 488:	6402                	ld	s0,0(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret
  return 0;
 48e:	4501                	li	a0,0
 490:	bfdd                	j	486 <strchr+0x1c>

0000000000000492 <gets>:

char*
gets(char *buf, int max)
{
 492:	711d                	addi	sp,sp,-96
 494:	ec86                	sd	ra,88(sp)
 496:	e8a2                	sd	s0,80(sp)
 498:	e4a6                	sd	s1,72(sp)
 49a:	e0ca                	sd	s2,64(sp)
 49c:	fc4e                	sd	s3,56(sp)
 49e:	f852                	sd	s4,48(sp)
 4a0:	f456                	sd	s5,40(sp)
 4a2:	f05a                	sd	s6,32(sp)
 4a4:	ec5e                	sd	s7,24(sp)
 4a6:	e862                	sd	s8,16(sp)
 4a8:	1080                	addi	s0,sp,96
 4aa:	8baa                	mv	s7,a0
 4ac:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4ae:	892a                	mv	s2,a0
 4b0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 4b2:	faf40b13          	addi	s6,s0,-81
 4b6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 4b8:	8c26                	mv	s8,s1
 4ba:	0014899b          	addiw	s3,s1,1
 4be:	84ce                	mv	s1,s3
 4c0:	0349d463          	bge	s3,s4,4e8 <gets+0x56>
    cc = read(0, &c, 1);
 4c4:	8656                	mv	a2,s5
 4c6:	85da                	mv	a1,s6
 4c8:	4501                	li	a0,0
 4ca:	1bc000ef          	jal	686 <read>
    if(cc < 1)
 4ce:	00a05d63          	blez	a0,4e8 <gets+0x56>
      break;
    buf[i++] = c;
 4d2:	faf44783          	lbu	a5,-81(s0)
 4d6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4da:	0905                	addi	s2,s2,1
 4dc:	ff678713          	addi	a4,a5,-10
 4e0:	c319                	beqz	a4,4e6 <gets+0x54>
 4e2:	17cd                	addi	a5,a5,-13
 4e4:	fbf1                	bnez	a5,4b8 <gets+0x26>
    buf[i++] = c;
 4e6:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 4e8:	9c5e                	add	s8,s8,s7
 4ea:	000c0023          	sb	zero,0(s8)
  return buf;
}
 4ee:	855e                	mv	a0,s7
 4f0:	60e6                	ld	ra,88(sp)
 4f2:	6446                	ld	s0,80(sp)
 4f4:	64a6                	ld	s1,72(sp)
 4f6:	6906                	ld	s2,64(sp)
 4f8:	79e2                	ld	s3,56(sp)
 4fa:	7a42                	ld	s4,48(sp)
 4fc:	7aa2                	ld	s5,40(sp)
 4fe:	7b02                	ld	s6,32(sp)
 500:	6be2                	ld	s7,24(sp)
 502:	6c42                	ld	s8,16(sp)
 504:	6125                	addi	sp,sp,96
 506:	8082                	ret

0000000000000508 <stat>:

int
stat(const char *n, struct stat *st)
{
 508:	1101                	addi	sp,sp,-32
 50a:	ec06                	sd	ra,24(sp)
 50c:	e822                	sd	s0,16(sp)
 50e:	e04a                	sd	s2,0(sp)
 510:	1000                	addi	s0,sp,32
 512:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 514:	4581                	li	a1,0
 516:	198000ef          	jal	6ae <open>
  if(fd < 0)
 51a:	02054263          	bltz	a0,53e <stat+0x36>
 51e:	e426                	sd	s1,8(sp)
 520:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 522:	85ca                	mv	a1,s2
 524:	1a2000ef          	jal	6c6 <fstat>
 528:	892a                	mv	s2,a0
  close(fd);
 52a:	8526                	mv	a0,s1
 52c:	16a000ef          	jal	696 <close>
  return r;
 530:	64a2                	ld	s1,8(sp)
}
 532:	854a                	mv	a0,s2
 534:	60e2                	ld	ra,24(sp)
 536:	6442                	ld	s0,16(sp)
 538:	6902                	ld	s2,0(sp)
 53a:	6105                	addi	sp,sp,32
 53c:	8082                	ret
    return -1;
 53e:	57fd                	li	a5,-1
 540:	893e                	mv	s2,a5
 542:	bfc5                	j	532 <stat+0x2a>

0000000000000544 <atoi>:

int
atoi(const char *s)
{
 544:	1141                	addi	sp,sp,-16
 546:	e406                	sd	ra,8(sp)
 548:	e022                	sd	s0,0(sp)
 54a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 54c:	00054683          	lbu	a3,0(a0)
 550:	fd06879b          	addiw	a5,a3,-48
 554:	0ff7f793          	zext.b	a5,a5
 558:	4625                	li	a2,9
 55a:	02f66963          	bltu	a2,a5,58c <atoi+0x48>
 55e:	872a                	mv	a4,a0
  n = 0;
 560:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 562:	0705                	addi	a4,a4,1
 564:	0025179b          	slliw	a5,a0,0x2
 568:	9fa9                	addw	a5,a5,a0
 56a:	0017979b          	slliw	a5,a5,0x1
 56e:	9fb5                	addw	a5,a5,a3
 570:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 574:	00074683          	lbu	a3,0(a4)
 578:	fd06879b          	addiw	a5,a3,-48
 57c:	0ff7f793          	zext.b	a5,a5
 580:	fef671e3          	bgeu	a2,a5,562 <atoi+0x1e>
  return n;
}
 584:	60a2                	ld	ra,8(sp)
 586:	6402                	ld	s0,0(sp)
 588:	0141                	addi	sp,sp,16
 58a:	8082                	ret
  n = 0;
 58c:	4501                	li	a0,0
 58e:	bfdd                	j	584 <atoi+0x40>

0000000000000590 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 590:	1141                	addi	sp,sp,-16
 592:	e406                	sd	ra,8(sp)
 594:	e022                	sd	s0,0(sp)
 596:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 598:	02b57563          	bgeu	a0,a1,5c2 <memmove+0x32>
    while(n-- > 0)
 59c:	00c05f63          	blez	a2,5ba <memmove+0x2a>
 5a0:	1602                	slli	a2,a2,0x20
 5a2:	9201                	srli	a2,a2,0x20
 5a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 5aa:	0585                	addi	a1,a1,1
 5ac:	0705                	addi	a4,a4,1
 5ae:	fff5c683          	lbu	a3,-1(a1)
 5b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5b6:	fee79ae3          	bne	a5,a4,5aa <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5ba:	60a2                	ld	ra,8(sp)
 5bc:	6402                	ld	s0,0(sp)
 5be:	0141                	addi	sp,sp,16
 5c0:	8082                	ret
    while(n-- > 0)
 5c2:	fec05ce3          	blez	a2,5ba <memmove+0x2a>
    dst += n;
 5c6:	00c50733          	add	a4,a0,a2
    src += n;
 5ca:	95b2                	add	a1,a1,a2
 5cc:	fff6079b          	addiw	a5,a2,-1
 5d0:	1782                	slli	a5,a5,0x20
 5d2:	9381                	srli	a5,a5,0x20
 5d4:	fff7c793          	not	a5,a5
 5d8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5da:	15fd                	addi	a1,a1,-1
 5dc:	177d                	addi	a4,a4,-1
 5de:	0005c683          	lbu	a3,0(a1)
 5e2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 5e6:	fef71ae3          	bne	a4,a5,5da <memmove+0x4a>
 5ea:	bfc1                	j	5ba <memmove+0x2a>

00000000000005ec <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5ec:	1141                	addi	sp,sp,-16
 5ee:	e406                	sd	ra,8(sp)
 5f0:	e022                	sd	s0,0(sp)
 5f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5f4:	c61d                	beqz	a2,622 <memcmp+0x36>
 5f6:	1602                	slli	a2,a2,0x20
 5f8:	9201                	srli	a2,a2,0x20
 5fa:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 5fe:	00054783          	lbu	a5,0(a0)
 602:	0005c703          	lbu	a4,0(a1)
 606:	00e79863          	bne	a5,a4,616 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 60a:	0505                	addi	a0,a0,1
    p2++;
 60c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 60e:	fed518e3          	bne	a0,a3,5fe <memcmp+0x12>
  }
  return 0;
 612:	4501                	li	a0,0
 614:	a019                	j	61a <memcmp+0x2e>
      return *p1 - *p2;
 616:	40e7853b          	subw	a0,a5,a4
}
 61a:	60a2                	ld	ra,8(sp)
 61c:	6402                	ld	s0,0(sp)
 61e:	0141                	addi	sp,sp,16
 620:	8082                	ret
  return 0;
 622:	4501                	li	a0,0
 624:	bfdd                	j	61a <memcmp+0x2e>

0000000000000626 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 626:	1141                	addi	sp,sp,-16
 628:	e406                	sd	ra,8(sp)
 62a:	e022                	sd	s0,0(sp)
 62c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 62e:	f63ff0ef          	jal	590 <memmove>
}
 632:	60a2                	ld	ra,8(sp)
 634:	6402                	ld	s0,0(sp)
 636:	0141                	addi	sp,sp,16
 638:	8082                	ret

000000000000063a <sbrk>:

char *
sbrk(int n) {
 63a:	1141                	addi	sp,sp,-16
 63c:	e406                	sd	ra,8(sp)
 63e:	e022                	sd	s0,0(sp)
 640:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 642:	4585                	li	a1,1
 644:	0b2000ef          	jal	6f6 <sys_sbrk>
}
 648:	60a2                	ld	ra,8(sp)
 64a:	6402                	ld	s0,0(sp)
 64c:	0141                	addi	sp,sp,16
 64e:	8082                	ret

0000000000000650 <sbrklazy>:

char *
sbrklazy(int n) {
 650:	1141                	addi	sp,sp,-16
 652:	e406                	sd	ra,8(sp)
 654:	e022                	sd	s0,0(sp)
 656:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 658:	4589                	li	a1,2
 65a:	09c000ef          	jal	6f6 <sys_sbrk>
}
 65e:	60a2                	ld	ra,8(sp)
 660:	6402                	ld	s0,0(sp)
 662:	0141                	addi	sp,sp,16
 664:	8082                	ret

0000000000000666 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 666:	4885                	li	a7,1
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <exit>:
.global exit
exit:
 li a7, SYS_exit
 66e:	4889                	li	a7,2
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <wait>:
.global wait
wait:
 li a7, SYS_wait
 676:	488d                	li	a7,3
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 67e:	4891                	li	a7,4
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <read>:
.global read
read:
 li a7, SYS_read
 686:	4895                	li	a7,5
 ecall
 688:	00000073          	ecall
 ret
 68c:	8082                	ret

000000000000068e <write>:
.global write
write:
 li a7, SYS_write
 68e:	48c1                	li	a7,16
 ecall
 690:	00000073          	ecall
 ret
 694:	8082                	ret

0000000000000696 <close>:
.global close
close:
 li a7, SYS_close
 696:	48d5                	li	a7,21
 ecall
 698:	00000073          	ecall
 ret
 69c:	8082                	ret

000000000000069e <kill>:
.global kill
kill:
 li a7, SYS_kill
 69e:	4899                	li	a7,6
 ecall
 6a0:	00000073          	ecall
 ret
 6a4:	8082                	ret

00000000000006a6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6a6:	489d                	li	a7,7
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <open>:
.global open
open:
 li a7, SYS_open
 6ae:	48bd                	li	a7,15
 ecall
 6b0:	00000073          	ecall
 ret
 6b4:	8082                	ret

00000000000006b6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6b6:	48c5                	li	a7,17
 ecall
 6b8:	00000073          	ecall
 ret
 6bc:	8082                	ret

00000000000006be <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6be:	48c9                	li	a7,18
 ecall
 6c0:	00000073          	ecall
 ret
 6c4:	8082                	ret

00000000000006c6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6c6:	48a1                	li	a7,8
 ecall
 6c8:	00000073          	ecall
 ret
 6cc:	8082                	ret

00000000000006ce <link>:
.global link
link:
 li a7, SYS_link
 6ce:	48cd                	li	a7,19
 ecall
 6d0:	00000073          	ecall
 ret
 6d4:	8082                	ret

00000000000006d6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6d6:	48d1                	li	a7,20
 ecall
 6d8:	00000073          	ecall
 ret
 6dc:	8082                	ret

00000000000006de <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6de:	48a5                	li	a7,9
 ecall
 6e0:	00000073          	ecall
 ret
 6e4:	8082                	ret

00000000000006e6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6e6:	48a9                	li	a7,10
 ecall
 6e8:	00000073          	ecall
 ret
 6ec:	8082                	ret

00000000000006ee <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6ee:	48ad                	li	a7,11
 ecall
 6f0:	00000073          	ecall
 ret
 6f4:	8082                	ret

00000000000006f6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 6f6:	48b1                	li	a7,12
 ecall
 6f8:	00000073          	ecall
 ret
 6fc:	8082                	ret

00000000000006fe <pause>:
.global pause
pause:
 li a7, SYS_pause
 6fe:	48b5                	li	a7,13
 ecall
 700:	00000073          	ecall
 ret
 704:	8082                	ret

0000000000000706 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 706:	48b9                	li	a7,14
 ecall
 708:	00000073          	ecall
 ret
 70c:	8082                	ret

000000000000070e <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 70e:	48d9                	li	a7,22
 ecall
 710:	00000073          	ecall
 ret
 714:	8082                	ret

0000000000000716 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 716:	48dd                	li	a7,23
 ecall
 718:	00000073          	ecall
 ret
 71c:	8082                	ret

000000000000071e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 71e:	1101                	addi	sp,sp,-32
 720:	ec06                	sd	ra,24(sp)
 722:	e822                	sd	s0,16(sp)
 724:	1000                	addi	s0,sp,32
 726:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 72a:	4605                	li	a2,1
 72c:	fef40593          	addi	a1,s0,-17
 730:	f5fff0ef          	jal	68e <write>
}
 734:	60e2                	ld	ra,24(sp)
 736:	6442                	ld	s0,16(sp)
 738:	6105                	addi	sp,sp,32
 73a:	8082                	ret

000000000000073c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 73c:	715d                	addi	sp,sp,-80
 73e:	e486                	sd	ra,72(sp)
 740:	e0a2                	sd	s0,64(sp)
 742:	f84a                	sd	s2,48(sp)
 744:	f44e                	sd	s3,40(sp)
 746:	0880                	addi	s0,sp,80
 748:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 74a:	c6d1                	beqz	a3,7d6 <printint+0x9a>
 74c:	0805d563          	bgez	a1,7d6 <printint+0x9a>
    neg = 1;
    x = -xx;
 750:	40b005b3          	neg	a1,a1
    neg = 1;
 754:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 756:	fb840993          	addi	s3,s0,-72
  neg = 0;
 75a:	86ce                	mv	a3,s3
  i = 0;
 75c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 75e:	00001817          	auipc	a6,0x1
 762:	b8280813          	addi	a6,a6,-1150 # 12e0 <digits>
 766:	88ba                	mv	a7,a4
 768:	0017051b          	addiw	a0,a4,1
 76c:	872a                	mv	a4,a0
 76e:	02c5f7b3          	remu	a5,a1,a2
 772:	97c2                	add	a5,a5,a6
 774:	0007c783          	lbu	a5,0(a5)
 778:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 77c:	87ae                	mv	a5,a1
 77e:	02c5d5b3          	divu	a1,a1,a2
 782:	0685                	addi	a3,a3,1
 784:	fec7f1e3          	bgeu	a5,a2,766 <printint+0x2a>
  if(neg)
 788:	00030c63          	beqz	t1,7a0 <printint+0x64>
    buf[i++] = '-';
 78c:	fd050793          	addi	a5,a0,-48
 790:	00878533          	add	a0,a5,s0
 794:	02d00793          	li	a5,45
 798:	fef50423          	sb	a5,-24(a0)
 79c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 7a0:	02e05563          	blez	a4,7ca <printint+0x8e>
 7a4:	fc26                	sd	s1,56(sp)
 7a6:	377d                	addiw	a4,a4,-1
 7a8:	00e984b3          	add	s1,s3,a4
 7ac:	19fd                	addi	s3,s3,-1
 7ae:	99ba                	add	s3,s3,a4
 7b0:	1702                	slli	a4,a4,0x20
 7b2:	9301                	srli	a4,a4,0x20
 7b4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7b8:	0004c583          	lbu	a1,0(s1)
 7bc:	854a                	mv	a0,s2
 7be:	f61ff0ef          	jal	71e <putc>
  while(--i >= 0)
 7c2:	14fd                	addi	s1,s1,-1
 7c4:	ff349ae3          	bne	s1,s3,7b8 <printint+0x7c>
 7c8:	74e2                	ld	s1,56(sp)
}
 7ca:	60a6                	ld	ra,72(sp)
 7cc:	6406                	ld	s0,64(sp)
 7ce:	7942                	ld	s2,48(sp)
 7d0:	79a2                	ld	s3,40(sp)
 7d2:	6161                	addi	sp,sp,80
 7d4:	8082                	ret
  neg = 0;
 7d6:	4301                	li	t1,0
 7d8:	bfbd                	j	756 <printint+0x1a>

00000000000007da <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7da:	711d                	addi	sp,sp,-96
 7dc:	ec86                	sd	ra,88(sp)
 7de:	e8a2                	sd	s0,80(sp)
 7e0:	e4a6                	sd	s1,72(sp)
 7e2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7e4:	0005c483          	lbu	s1,0(a1)
 7e8:	22048363          	beqz	s1,a0e <vprintf+0x234>
 7ec:	e0ca                	sd	s2,64(sp)
 7ee:	fc4e                	sd	s3,56(sp)
 7f0:	f852                	sd	s4,48(sp)
 7f2:	f456                	sd	s5,40(sp)
 7f4:	f05a                	sd	s6,32(sp)
 7f6:	ec5e                	sd	s7,24(sp)
 7f8:	e862                	sd	s8,16(sp)
 7fa:	8b2a                	mv	s6,a0
 7fc:	8a2e                	mv	s4,a1
 7fe:	8bb2                	mv	s7,a2
  state = 0;
 800:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 802:	4901                	li	s2,0
 804:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 806:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 80a:	06400c13          	li	s8,100
 80e:	a00d                	j	830 <vprintf+0x56>
        putc(fd, c0);
 810:	85a6                	mv	a1,s1
 812:	855a                	mv	a0,s6
 814:	f0bff0ef          	jal	71e <putc>
 818:	a019                	j	81e <vprintf+0x44>
    } else if(state == '%'){
 81a:	03598363          	beq	s3,s5,840 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 81e:	0019079b          	addiw	a5,s2,1
 822:	893e                	mv	s2,a5
 824:	873e                	mv	a4,a5
 826:	97d2                	add	a5,a5,s4
 828:	0007c483          	lbu	s1,0(a5)
 82c:	1c048a63          	beqz	s1,a00 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 830:	0004879b          	sext.w	a5,s1
    if(state == 0){
 834:	fe0993e3          	bnez	s3,81a <vprintf+0x40>
      if(c0 == '%'){
 838:	fd579ce3          	bne	a5,s5,810 <vprintf+0x36>
        state = '%';
 83c:	89be                	mv	s3,a5
 83e:	b7c5                	j	81e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 840:	00ea06b3          	add	a3,s4,a4
 844:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 848:	1c060863          	beqz	a2,a18 <vprintf+0x23e>
      if(c0 == 'd'){
 84c:	03878763          	beq	a5,s8,87a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 850:	f9478693          	addi	a3,a5,-108
 854:	0016b693          	seqz	a3,a3
 858:	f9c60593          	addi	a1,a2,-100
 85c:	e99d                	bnez	a1,892 <vprintf+0xb8>
 85e:	ca95                	beqz	a3,892 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 860:	008b8493          	addi	s1,s7,8
 864:	4685                	li	a3,1
 866:	4629                	li	a2,10
 868:	000bb583          	ld	a1,0(s7)
 86c:	855a                	mv	a0,s6
 86e:	ecfff0ef          	jal	73c <printint>
        i += 1;
 872:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 874:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 876:	4981                	li	s3,0
 878:	b75d                	j	81e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 87a:	008b8493          	addi	s1,s7,8
 87e:	4685                	li	a3,1
 880:	4629                	li	a2,10
 882:	000ba583          	lw	a1,0(s7)
 886:	855a                	mv	a0,s6
 888:	eb5ff0ef          	jal	73c <printint>
 88c:	8ba6                	mv	s7,s1
      state = 0;
 88e:	4981                	li	s3,0
 890:	b779                	j	81e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 892:	9752                	add	a4,a4,s4
 894:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 898:	f9460713          	addi	a4,a2,-108
 89c:	00173713          	seqz	a4,a4
 8a0:	8f75                	and	a4,a4,a3
 8a2:	f9c58513          	addi	a0,a1,-100
 8a6:	18051363          	bnez	a0,a2c <vprintf+0x252>
 8aa:	18070163          	beqz	a4,a2c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8ae:	008b8493          	addi	s1,s7,8
 8b2:	4685                	li	a3,1
 8b4:	4629                	li	a2,10
 8b6:	000bb583          	ld	a1,0(s7)
 8ba:	855a                	mv	a0,s6
 8bc:	e81ff0ef          	jal	73c <printint>
        i += 2;
 8c0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8c2:	8ba6                	mv	s7,s1
      state = 0;
 8c4:	4981                	li	s3,0
        i += 2;
 8c6:	bfa1                	j	81e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 8c8:	008b8493          	addi	s1,s7,8
 8cc:	4681                	li	a3,0
 8ce:	4629                	li	a2,10
 8d0:	000be583          	lwu	a1,0(s7)
 8d4:	855a                	mv	a0,s6
 8d6:	e67ff0ef          	jal	73c <printint>
 8da:	8ba6                	mv	s7,s1
      state = 0;
 8dc:	4981                	li	s3,0
 8de:	b781                	j	81e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8e0:	008b8493          	addi	s1,s7,8
 8e4:	4681                	li	a3,0
 8e6:	4629                	li	a2,10
 8e8:	000bb583          	ld	a1,0(s7)
 8ec:	855a                	mv	a0,s6
 8ee:	e4fff0ef          	jal	73c <printint>
        i += 1;
 8f2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8f4:	8ba6                	mv	s7,s1
      state = 0;
 8f6:	4981                	li	s3,0
 8f8:	b71d                	j	81e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8fa:	008b8493          	addi	s1,s7,8
 8fe:	4681                	li	a3,0
 900:	4629                	li	a2,10
 902:	000bb583          	ld	a1,0(s7)
 906:	855a                	mv	a0,s6
 908:	e35ff0ef          	jal	73c <printint>
        i += 2;
 90c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 90e:	8ba6                	mv	s7,s1
      state = 0;
 910:	4981                	li	s3,0
        i += 2;
 912:	b731                	j	81e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 914:	008b8493          	addi	s1,s7,8
 918:	4681                	li	a3,0
 91a:	4641                	li	a2,16
 91c:	000be583          	lwu	a1,0(s7)
 920:	855a                	mv	a0,s6
 922:	e1bff0ef          	jal	73c <printint>
 926:	8ba6                	mv	s7,s1
      state = 0;
 928:	4981                	li	s3,0
 92a:	bdd5                	j	81e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 92c:	008b8493          	addi	s1,s7,8
 930:	4681                	li	a3,0
 932:	4641                	li	a2,16
 934:	000bb583          	ld	a1,0(s7)
 938:	855a                	mv	a0,s6
 93a:	e03ff0ef          	jal	73c <printint>
        i += 1;
 93e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 940:	8ba6                	mv	s7,s1
      state = 0;
 942:	4981                	li	s3,0
 944:	bde9                	j	81e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 946:	008b8493          	addi	s1,s7,8
 94a:	4681                	li	a3,0
 94c:	4641                	li	a2,16
 94e:	000bb583          	ld	a1,0(s7)
 952:	855a                	mv	a0,s6
 954:	de9ff0ef          	jal	73c <printint>
        i += 2;
 958:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 95a:	8ba6                	mv	s7,s1
      state = 0;
 95c:	4981                	li	s3,0
        i += 2;
 95e:	b5c1                	j	81e <vprintf+0x44>
 960:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 962:	008b8793          	addi	a5,s7,8
 966:	8cbe                	mv	s9,a5
 968:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 96c:	03000593          	li	a1,48
 970:	855a                	mv	a0,s6
 972:	dadff0ef          	jal	71e <putc>
  putc(fd, 'x');
 976:	07800593          	li	a1,120
 97a:	855a                	mv	a0,s6
 97c:	da3ff0ef          	jal	71e <putc>
 980:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 982:	00001b97          	auipc	s7,0x1
 986:	95eb8b93          	addi	s7,s7,-1698 # 12e0 <digits>
 98a:	03c9d793          	srli	a5,s3,0x3c
 98e:	97de                	add	a5,a5,s7
 990:	0007c583          	lbu	a1,0(a5)
 994:	855a                	mv	a0,s6
 996:	d89ff0ef          	jal	71e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 99a:	0992                	slli	s3,s3,0x4
 99c:	34fd                	addiw	s1,s1,-1
 99e:	f4f5                	bnez	s1,98a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 9a0:	8be6                	mv	s7,s9
      state = 0;
 9a2:	4981                	li	s3,0
 9a4:	6ca2                	ld	s9,8(sp)
 9a6:	bda5                	j	81e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 9a8:	008b8493          	addi	s1,s7,8
 9ac:	000bc583          	lbu	a1,0(s7)
 9b0:	855a                	mv	a0,s6
 9b2:	d6dff0ef          	jal	71e <putc>
 9b6:	8ba6                	mv	s7,s1
      state = 0;
 9b8:	4981                	li	s3,0
 9ba:	b595                	j	81e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 9bc:	008b8993          	addi	s3,s7,8
 9c0:	000bb483          	ld	s1,0(s7)
 9c4:	cc91                	beqz	s1,9e0 <vprintf+0x206>
        for(; *s; s++)
 9c6:	0004c583          	lbu	a1,0(s1)
 9ca:	c985                	beqz	a1,9fa <vprintf+0x220>
          putc(fd, *s);
 9cc:	855a                	mv	a0,s6
 9ce:	d51ff0ef          	jal	71e <putc>
        for(; *s; s++)
 9d2:	0485                	addi	s1,s1,1
 9d4:	0004c583          	lbu	a1,0(s1)
 9d8:	f9f5                	bnez	a1,9cc <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 9da:	8bce                	mv	s7,s3
      state = 0;
 9dc:	4981                	li	s3,0
 9de:	b581                	j	81e <vprintf+0x44>
          s = "(null)";
 9e0:	00001497          	auipc	s1,0x1
 9e4:	8f848493          	addi	s1,s1,-1800 # 12d8 <malloc+0x75c>
        for(; *s; s++)
 9e8:	02800593          	li	a1,40
 9ec:	b7c5                	j	9cc <vprintf+0x1f2>
        putc(fd, '%');
 9ee:	85be                	mv	a1,a5
 9f0:	855a                	mv	a0,s6
 9f2:	d2dff0ef          	jal	71e <putc>
      state = 0;
 9f6:	4981                	li	s3,0
 9f8:	b51d                	j	81e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 9fa:	8bce                	mv	s7,s3
      state = 0;
 9fc:	4981                	li	s3,0
 9fe:	b505                	j	81e <vprintf+0x44>
 a00:	6906                	ld	s2,64(sp)
 a02:	79e2                	ld	s3,56(sp)
 a04:	7a42                	ld	s4,48(sp)
 a06:	7aa2                	ld	s5,40(sp)
 a08:	7b02                	ld	s6,32(sp)
 a0a:	6be2                	ld	s7,24(sp)
 a0c:	6c42                	ld	s8,16(sp)
    }
  }
}
 a0e:	60e6                	ld	ra,88(sp)
 a10:	6446                	ld	s0,80(sp)
 a12:	64a6                	ld	s1,72(sp)
 a14:	6125                	addi	sp,sp,96
 a16:	8082                	ret
      if(c0 == 'd'){
 a18:	06400713          	li	a4,100
 a1c:	e4e78fe3          	beq	a5,a4,87a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 a20:	f9478693          	addi	a3,a5,-108
 a24:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 a28:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 a2a:	4701                	li	a4,0
      } else if(c0 == 'u'){
 a2c:	07500513          	li	a0,117
 a30:	e8a78ce3          	beq	a5,a0,8c8 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 a34:	f8b60513          	addi	a0,a2,-117
 a38:	e119                	bnez	a0,a3e <vprintf+0x264>
 a3a:	ea0693e3          	bnez	a3,8e0 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 a3e:	f8b58513          	addi	a0,a1,-117
 a42:	e119                	bnez	a0,a48 <vprintf+0x26e>
 a44:	ea071be3          	bnez	a4,8fa <vprintf+0x120>
      } else if(c0 == 'x'){
 a48:	07800513          	li	a0,120
 a4c:	eca784e3          	beq	a5,a0,914 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 a50:	f8860613          	addi	a2,a2,-120
 a54:	e219                	bnez	a2,a5a <vprintf+0x280>
 a56:	ec069be3          	bnez	a3,92c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 a5a:	f8858593          	addi	a1,a1,-120
 a5e:	e199                	bnez	a1,a64 <vprintf+0x28a>
 a60:	ee0713e3          	bnez	a4,946 <vprintf+0x16c>
      } else if(c0 == 'p'){
 a64:	07000713          	li	a4,112
 a68:	eee78ce3          	beq	a5,a4,960 <vprintf+0x186>
      } else if(c0 == 'c'){
 a6c:	06300713          	li	a4,99
 a70:	f2e78ce3          	beq	a5,a4,9a8 <vprintf+0x1ce>
      } else if(c0 == 's'){
 a74:	07300713          	li	a4,115
 a78:	f4e782e3          	beq	a5,a4,9bc <vprintf+0x1e2>
      } else if(c0 == '%'){
 a7c:	02500713          	li	a4,37
 a80:	f6e787e3          	beq	a5,a4,9ee <vprintf+0x214>
        putc(fd, '%');
 a84:	02500593          	li	a1,37
 a88:	855a                	mv	a0,s6
 a8a:	c95ff0ef          	jal	71e <putc>
        putc(fd, c0);
 a8e:	85a6                	mv	a1,s1
 a90:	855a                	mv	a0,s6
 a92:	c8dff0ef          	jal	71e <putc>
      state = 0;
 a96:	4981                	li	s3,0
 a98:	b359                	j	81e <vprintf+0x44>

0000000000000a9a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a9a:	715d                	addi	sp,sp,-80
 a9c:	ec06                	sd	ra,24(sp)
 a9e:	e822                	sd	s0,16(sp)
 aa0:	1000                	addi	s0,sp,32
 aa2:	e010                	sd	a2,0(s0)
 aa4:	e414                	sd	a3,8(s0)
 aa6:	e818                	sd	a4,16(s0)
 aa8:	ec1c                	sd	a5,24(s0)
 aaa:	03043023          	sd	a6,32(s0)
 aae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ab2:	8622                	mv	a2,s0
 ab4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ab8:	d23ff0ef          	jal	7da <vprintf>
}
 abc:	60e2                	ld	ra,24(sp)
 abe:	6442                	ld	s0,16(sp)
 ac0:	6161                	addi	sp,sp,80
 ac2:	8082                	ret

0000000000000ac4 <printf>:

void
printf(const char *fmt, ...)
{
 ac4:	711d                	addi	sp,sp,-96
 ac6:	ec06                	sd	ra,24(sp)
 ac8:	e822                	sd	s0,16(sp)
 aca:	1000                	addi	s0,sp,32
 acc:	e40c                	sd	a1,8(s0)
 ace:	e810                	sd	a2,16(s0)
 ad0:	ec14                	sd	a3,24(s0)
 ad2:	f018                	sd	a4,32(s0)
 ad4:	f41c                	sd	a5,40(s0)
 ad6:	03043823          	sd	a6,48(s0)
 ada:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ade:	00840613          	addi	a2,s0,8
 ae2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ae6:	85aa                	mv	a1,a0
 ae8:	4505                	li	a0,1
 aea:	cf1ff0ef          	jal	7da <vprintf>
}
 aee:	60e2                	ld	ra,24(sp)
 af0:	6442                	ld	s0,16(sp)
 af2:	6125                	addi	sp,sp,96
 af4:	8082                	ret

0000000000000af6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 af6:	1141                	addi	sp,sp,-16
 af8:	e406                	sd	ra,8(sp)
 afa:	e022                	sd	s0,0(sp)
 afc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 afe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b02:	00001797          	auipc	a5,0x1
 b06:	4fe7b783          	ld	a5,1278(a5) # 2000 <freep>
 b0a:	a039                	j	b18 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b0c:	6398                	ld	a4,0(a5)
 b0e:	00e7e463          	bltu	a5,a4,b16 <free+0x20>
 b12:	00e6ea63          	bltu	a3,a4,b26 <free+0x30>
{
 b16:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b18:	fed7fae3          	bgeu	a5,a3,b0c <free+0x16>
 b1c:	6398                	ld	a4,0(a5)
 b1e:	00e6e463          	bltu	a3,a4,b26 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b22:	fee7eae3          	bltu	a5,a4,b16 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b26:	ff852583          	lw	a1,-8(a0)
 b2a:	6390                	ld	a2,0(a5)
 b2c:	02059813          	slli	a6,a1,0x20
 b30:	01c85713          	srli	a4,a6,0x1c
 b34:	9736                	add	a4,a4,a3
 b36:	02e60563          	beq	a2,a4,b60 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 b3a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 b3e:	4790                	lw	a2,8(a5)
 b40:	02061593          	slli	a1,a2,0x20
 b44:	01c5d713          	srli	a4,a1,0x1c
 b48:	973e                	add	a4,a4,a5
 b4a:	02e68263          	beq	a3,a4,b6e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 b4e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b50:	00001717          	auipc	a4,0x1
 b54:	4af73823          	sd	a5,1200(a4) # 2000 <freep>
}
 b58:	60a2                	ld	ra,8(sp)
 b5a:	6402                	ld	s0,0(sp)
 b5c:	0141                	addi	sp,sp,16
 b5e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 b60:	4618                	lw	a4,8(a2)
 b62:	9f2d                	addw	a4,a4,a1
 b64:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b68:	6398                	ld	a4,0(a5)
 b6a:	6310                	ld	a2,0(a4)
 b6c:	b7f9                	j	b3a <free+0x44>
    p->s.size += bp->s.size;
 b6e:	ff852703          	lw	a4,-8(a0)
 b72:	9f31                	addw	a4,a4,a2
 b74:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b76:	ff053683          	ld	a3,-16(a0)
 b7a:	bfd1                	j	b4e <free+0x58>

0000000000000b7c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b7c:	7139                	addi	sp,sp,-64
 b7e:	fc06                	sd	ra,56(sp)
 b80:	f822                	sd	s0,48(sp)
 b82:	f04a                	sd	s2,32(sp)
 b84:	ec4e                	sd	s3,24(sp)
 b86:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b88:	02051993          	slli	s3,a0,0x20
 b8c:	0209d993          	srli	s3,s3,0x20
 b90:	09bd                	addi	s3,s3,15
 b92:	0049d993          	srli	s3,s3,0x4
 b96:	2985                	addiw	s3,s3,1
 b98:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 b9a:	00001517          	auipc	a0,0x1
 b9e:	46653503          	ld	a0,1126(a0) # 2000 <freep>
 ba2:	c905                	beqz	a0,bd2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ba6:	4798                	lw	a4,8(a5)
 ba8:	09377663          	bgeu	a4,s3,c34 <malloc+0xb8>
 bac:	f426                	sd	s1,40(sp)
 bae:	e852                	sd	s4,16(sp)
 bb0:	e456                	sd	s5,8(sp)
 bb2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 bb4:	8a4e                	mv	s4,s3
 bb6:	6705                	lui	a4,0x1
 bb8:	00e9f363          	bgeu	s3,a4,bbe <malloc+0x42>
 bbc:	6a05                	lui	s4,0x1
 bbe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bc2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bc6:	00001497          	auipc	s1,0x1
 bca:	43a48493          	addi	s1,s1,1082 # 2000 <freep>
  if(p == SBRK_ERROR)
 bce:	5afd                	li	s5,-1
 bd0:	a83d                	j	c0e <malloc+0x92>
 bd2:	f426                	sd	s1,40(sp)
 bd4:	e852                	sd	s4,16(sp)
 bd6:	e456                	sd	s5,8(sp)
 bd8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 bda:	00001797          	auipc	a5,0x1
 bde:	43678793          	addi	a5,a5,1078 # 2010 <base>
 be2:	00001717          	auipc	a4,0x1
 be6:	40f73f23          	sd	a5,1054(a4) # 2000 <freep>
 bea:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bec:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bf0:	b7d1                	j	bb4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 bf2:	6398                	ld	a4,0(a5)
 bf4:	e118                	sd	a4,0(a0)
 bf6:	a899                	j	c4c <malloc+0xd0>
  hp->s.size = nu;
 bf8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bfc:	0541                	addi	a0,a0,16
 bfe:	ef9ff0ef          	jal	af6 <free>
  return freep;
 c02:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 c04:	c125                	beqz	a0,c64 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c06:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c08:	4798                	lw	a4,8(a5)
 c0a:	03277163          	bgeu	a4,s2,c2c <malloc+0xb0>
    if(p == freep)
 c0e:	6098                	ld	a4,0(s1)
 c10:	853e                	mv	a0,a5
 c12:	fef71ae3          	bne	a4,a5,c06 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 c16:	8552                	mv	a0,s4
 c18:	a23ff0ef          	jal	63a <sbrk>
  if(p == SBRK_ERROR)
 c1c:	fd551ee3          	bne	a0,s5,bf8 <malloc+0x7c>
        return 0;
 c20:	4501                	li	a0,0
 c22:	74a2                	ld	s1,40(sp)
 c24:	6a42                	ld	s4,16(sp)
 c26:	6aa2                	ld	s5,8(sp)
 c28:	6b02                	ld	s6,0(sp)
 c2a:	a03d                	j	c58 <malloc+0xdc>
 c2c:	74a2                	ld	s1,40(sp)
 c2e:	6a42                	ld	s4,16(sp)
 c30:	6aa2                	ld	s5,8(sp)
 c32:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 c34:	fae90fe3          	beq	s2,a4,bf2 <malloc+0x76>
        p->s.size -= nunits;
 c38:	4137073b          	subw	a4,a4,s3
 c3c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c3e:	02071693          	slli	a3,a4,0x20
 c42:	01c6d713          	srli	a4,a3,0x1c
 c46:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c48:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c4c:	00001717          	auipc	a4,0x1
 c50:	3aa73a23          	sd	a0,948(a4) # 2000 <freep>
      return (void*)(p + 1);
 c54:	01078513          	addi	a0,a5,16
  }
}
 c58:	70e2                	ld	ra,56(sp)
 c5a:	7442                	ld	s0,48(sp)
 c5c:	7902                	ld	s2,32(sp)
 c5e:	69e2                	ld	s3,24(sp)
 c60:	6121                	addi	sp,sp,64
 c62:	8082                	ret
 c64:	74a2                	ld	s1,40(sp)
 c66:	6a42                	ld	s4,16(sp)
 c68:	6aa2                	ld	s5,8(sp)
 c6a:	6b02                	ld	s6,0(sp)
 c6c:	b7f5                	j	c58 <malloc+0xdc>
