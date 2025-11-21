
user/_purecpu:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

// Pure CPU-bound test: Does ONLY computation, checks priority at end
int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  struct procinfo info;
  volatile int dummy = 0;
   8:	fc042e23          	sw	zero,-36(s0)
  
  printf("\n=== Pure CPU-Bound Test ===\n");
   c:	00001517          	auipc	a0,0x1
  10:	98450513          	addi	a0,a0,-1660 # 990 <malloc+0xdc>
  14:	7e6000ef          	jal	ra,7fa <printf>
  
  if(getprocinfo(&info) == 0) {
  18:	fe040513          	addi	a0,s0,-32
  1c:	452000ef          	jal	ra,46e <getprocinfo>
  20:	c50d                	beqz	a0,4a <main+0x4a>
    printf("Starting: PID=%d, Q%d, slices=%d\n\n", 
           info.pid, info.priority, info.time_slices);
  }
  
  printf("Running continuous CPU work (no interruptions)...\n");
  22:	00001517          	auipc	a0,0x1
  26:	9b650513          	addi	a0,a0,-1610 # 9d8 <malloc+0x124>
  2a:	7d0000ef          	jal	ra,7fa <printf>
  printf("This will take several seconds...\n\n");
  2e:	00001517          	auipc	a0,0x1
  32:	9e250513          	addi	a0,a0,-1566 # a10 <malloc+0x15c>
  36:	7c4000ef          	jal	ra,7fa <printf>
  
  // Do MASSIVE amount of work without any syscalls
  // Increased significantly to trigger multiple demotions
  for(int i = 0; i < 500000000; i++) {
  3a:	4781                	li	a5,0
    dummy = dummy + i;
    // Add more computation to slow it down
    if(i % 1000 == 0) {
  3c:	3e800593          	li	a1,1000
  for(int i = 0; i < 500000000; i++) {
  40:	1dcd6637          	lui	a2,0x1dcd6
  44:	50060613          	addi	a2,a2,1280 # 1dcd6500 <base+0x1dcd54f0>
  48:	a00d                	j	6a <main+0x6a>
    printf("Starting: PID=%d, Q%d, slices=%d\n\n", 
  4a:	fec42683          	lw	a3,-20(s0)
  4e:	fe842603          	lw	a2,-24(s0)
  52:	fe042583          	lw	a1,-32(s0)
  56:	00001517          	auipc	a0,0x1
  5a:	95a50513          	addi	a0,a0,-1702 # 9b0 <malloc+0xfc>
  5e:	79c000ef          	jal	ra,7fa <printf>
  62:	b7c1                	j	22 <main+0x22>
  for(int i = 0; i < 500000000; i++) {
  64:	2785                	addiw	a5,a5,1
  66:	02c78a63          	beq	a5,a2,9a <main+0x9a>
    dummy = dummy + i;
  6a:	fdc42703          	lw	a4,-36(s0)
  6e:	9f3d                	addw	a4,a4,a5
  70:	fce42e23          	sw	a4,-36(s0)
    if(i % 1000 == 0) {
  74:	02b7e73b          	remw	a4,a5,a1
  78:	f775                	bnez	a4,64 <main+0x64>
      dummy = dummy * 2;
  7a:	fdc42703          	lw	a4,-36(s0)
  7e:	0017171b          	slliw	a4,a4,0x1
  82:	fce42e23          	sw	a4,-36(s0)
      dummy = dummy / 2;
  86:	fdc42683          	lw	a3,-36(s0)
  8a:	01f6d71b          	srliw	a4,a3,0x1f
  8e:	9f35                	addw	a4,a4,a3
  90:	4017571b          	sraiw	a4,a4,0x1
  94:	fce42e23          	sw	a4,-36(s0)
  98:	b7f1                	j	64 <main+0x64>
    }
  }
  
  printf("Work complete! Checking final state...\n\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	99e50513          	addi	a0,a0,-1634 # a38 <malloc+0x184>
  a2:	758000ef          	jal	ra,7fa <printf>
  
  if(getprocinfo(&info) == 0) {
  a6:	fe040513          	addi	a0,s0,-32
  aa:	3c4000ef          	jal	ra,46e <getprocinfo>
  ae:	c501                	beqz	a0,b6 <main+0xb6>
    } else {
      printf("✗ FAILED: Still at Q0 (no demotion occurred)\n");
    }
  }
  
  exit(0);
  b0:	4501                	li	a0,0
  b2:	31c000ef          	jal	ra,3ce <exit>
    printf("Final: PID=%d, Q%d, slices=%d\n", 
  b6:	fec42683          	lw	a3,-20(s0)
  ba:	fe842603          	lw	a2,-24(s0)
  be:	fe042583          	lw	a1,-32(s0)
  c2:	00001517          	auipc	a0,0x1
  c6:	9a650513          	addi	a0,a0,-1626 # a68 <malloc+0x1b4>
  ca:	730000ef          	jal	ra,7fa <printf>
    printf("\nExpected behavior:\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	9ba50513          	addi	a0,a0,-1606 # a88 <malloc+0x1d4>
  d6:	724000ef          	jal	ra,7fa <printf>
    printf("  - Should have used many timer ticks\n");
  da:	00001517          	auipc	a0,0x1
  de:	9c650513          	addi	a0,a0,-1594 # aa0 <malloc+0x1ec>
  e2:	718000ef          	jal	ra,7fa <printf>
    printf("  - Should have demoted through queues\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	9e250513          	addi	a0,a0,-1566 # ac8 <malloc+0x214>
  ee:	70c000ef          	jal	ra,7fa <printf>
    printf("  - Should be at Q3 (or Q2/Q3)\n\n");
  f2:	00001517          	auipc	a0,0x1
  f6:	9fe50513          	addi	a0,a0,-1538 # af0 <malloc+0x23c>
  fa:	700000ef          	jal	ra,7fa <printf>
    if(info.priority >= 2) {
  fe:	fe842583          	lw	a1,-24(s0)
 102:	4785                	li	a5,1
 104:	00b7cc63          	blt	a5,a1,11c <main+0x11c>
    } else if(info.priority == 1) {
 108:	4785                	li	a5,1
 10a:	02f58063          	beq	a1,a5,12a <main+0x12a>
      printf("✗ FAILED: Still at Q0 (no demotion occurred)\n");
 10e:	00001517          	auipc	a0,0x1
 112:	a5a50513          	addi	a0,a0,-1446 # b68 <malloc+0x2b4>
 116:	6e4000ef          	jal	ra,7fa <printf>
 11a:	bf59                	j	b0 <main+0xb0>
      printf("✓ SUCCESS: Demoted to Q%d\n", info.priority);
 11c:	00001517          	auipc	a0,0x1
 120:	9fc50513          	addi	a0,a0,-1540 # b18 <malloc+0x264>
 124:	6d6000ef          	jal	ra,7fa <printf>
 128:	b761                	j	b0 <main+0xb0>
      printf("~ PARTIAL: Only reached Q1 (expected Q2 or Q3)\n");
 12a:	00001517          	auipc	a0,0x1
 12e:	a0e50513          	addi	a0,a0,-1522 # b38 <malloc+0x284>
 132:	6c8000ef          	jal	ra,7fa <printf>
 136:	bfad                	j	b0 <main+0xb0>

0000000000000138 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e406                	sd	ra,8(sp)
 13c:	e022                	sd	s0,0(sp)
 13e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 140:	ec1ff0ef          	jal	ra,0 <main>
  exit(r);
 144:	28a000ef          	jal	ra,3ce <exit>

0000000000000148 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 14e:	87aa                	mv	a5,a0
 150:	0585                	addi	a1,a1,1
 152:	0785                	addi	a5,a5,1
 154:	fff5c703          	lbu	a4,-1(a1)
 158:	fee78fa3          	sb	a4,-1(a5)
 15c:	fb75                	bnez	a4,150 <strcpy+0x8>
    ;
  return os;
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret

0000000000000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cb91                	beqz	a5,182 <strcmp+0x1e>
 170:	0005c703          	lbu	a4,0(a1)
 174:	00f71763          	bne	a4,a5,182 <strcmp+0x1e>
    p++, q++;
 178:	0505                	addi	a0,a0,1
 17a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbe5                	bnez	a5,170 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 182:	0005c503          	lbu	a0,0(a1)
}
 186:	40a7853b          	subw	a0,a5,a0
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strlen>:

uint
strlen(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cf91                	beqz	a5,1b6 <strlen+0x26>
 19c:	0505                	addi	a0,a0,1
 19e:	87aa                	mv	a5,a0
 1a0:	4685                	li	a3,1
 1a2:	9e89                	subw	a3,a3,a0
 1a4:	00f6853b          	addw	a0,a3,a5
 1a8:	0785                	addi	a5,a5,1
 1aa:	fff7c703          	lbu	a4,-1(a5)
 1ae:	fb7d                	bnez	a4,1a4 <strlen+0x14>
    ;
  return n;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret
  for(n = 0; s[n]; n++)
 1b6:	4501                	li	a0,0
 1b8:	bfe5                	j	1b0 <strlen+0x20>

00000000000001ba <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c0:	ca19                	beqz	a2,1d6 <memset+0x1c>
 1c2:	87aa                	mv	a5,a0
 1c4:	1602                	slli	a2,a2,0x20
 1c6:	9201                	srli	a2,a2,0x20
 1c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1cc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d0:	0785                	addi	a5,a5,1
 1d2:	fee79de3          	bne	a5,a4,1cc <memset+0x12>
  }
  return dst;
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret

00000000000001dc <strchr>:

char*
strchr(const char *s, char c)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cb99                	beqz	a5,1fc <strchr+0x20>
    if(*s == c)
 1e8:	00f58763          	beq	a1,a5,1f6 <strchr+0x1a>
  for(; *s; s++)
 1ec:	0505                	addi	a0,a0,1
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	fbfd                	bnez	a5,1e8 <strchr+0xc>
      return (char*)s;
  return 0;
 1f4:	4501                	li	a0,0
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  return 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <strchr+0x1a>

0000000000000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	711d                	addi	sp,sp,-96
 202:	ec86                	sd	ra,88(sp)
 204:	e8a2                	sd	s0,80(sp)
 206:	e4a6                	sd	s1,72(sp)
 208:	e0ca                	sd	s2,64(sp)
 20a:	fc4e                	sd	s3,56(sp)
 20c:	f852                	sd	s4,48(sp)
 20e:	f456                	sd	s5,40(sp)
 210:	f05a                	sd	s6,32(sp)
 212:	ec5e                	sd	s7,24(sp)
 214:	1080                	addi	s0,sp,96
 216:	8baa                	mv	s7,a0
 218:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21a:	892a                	mv	s2,a0
 21c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 21e:	4aa9                	li	s5,10
 220:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 222:	89a6                	mv	s3,s1
 224:	2485                	addiw	s1,s1,1
 226:	0344d663          	bge	s1,s4,252 <gets+0x52>
    cc = read(0, &c, 1);
 22a:	4605                	li	a2,1
 22c:	faf40593          	addi	a1,s0,-81
 230:	4501                	li	a0,0
 232:	1b4000ef          	jal	ra,3e6 <read>
    if(cc < 1)
 236:	00a05e63          	blez	a0,252 <gets+0x52>
    buf[i++] = c;
 23a:	faf44783          	lbu	a5,-81(s0)
 23e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 242:	01578763          	beq	a5,s5,250 <gets+0x50>
 246:	0905                	addi	s2,s2,1
 248:	fd679de3          	bne	a5,s6,222 <gets+0x22>
  for(i=0; i+1 < max; ){
 24c:	89a6                	mv	s3,s1
 24e:	a011                	j	252 <gets+0x52>
 250:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 252:	99de                	add	s3,s3,s7
 254:	00098023          	sb	zero,0(s3)
  return buf;
}
 258:	855e                	mv	a0,s7
 25a:	60e6                	ld	ra,88(sp)
 25c:	6446                	ld	s0,80(sp)
 25e:	64a6                	ld	s1,72(sp)
 260:	6906                	ld	s2,64(sp)
 262:	79e2                	ld	s3,56(sp)
 264:	7a42                	ld	s4,48(sp)
 266:	7aa2                	ld	s5,40(sp)
 268:	7b02                	ld	s6,32(sp)
 26a:	6be2                	ld	s7,24(sp)
 26c:	6125                	addi	sp,sp,96
 26e:	8082                	ret

0000000000000270 <stat>:

int
stat(const char *n, struct stat *st)
{
 270:	1101                	addi	sp,sp,-32
 272:	ec06                	sd	ra,24(sp)
 274:	e822                	sd	s0,16(sp)
 276:	e426                	sd	s1,8(sp)
 278:	e04a                	sd	s2,0(sp)
 27a:	1000                	addi	s0,sp,32
 27c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27e:	4581                	li	a1,0
 280:	18e000ef          	jal	ra,40e <open>
  if(fd < 0)
 284:	02054163          	bltz	a0,2a6 <stat+0x36>
 288:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 28a:	85ca                	mv	a1,s2
 28c:	19a000ef          	jal	ra,426 <fstat>
 290:	892a                	mv	s2,a0
  close(fd);
 292:	8526                	mv	a0,s1
 294:	162000ef          	jal	ra,3f6 <close>
  return r;
}
 298:	854a                	mv	a0,s2
 29a:	60e2                	ld	ra,24(sp)
 29c:	6442                	ld	s0,16(sp)
 29e:	64a2                	ld	s1,8(sp)
 2a0:	6902                	ld	s2,0(sp)
 2a2:	6105                	addi	sp,sp,32
 2a4:	8082                	ret
    return -1;
 2a6:	597d                	li	s2,-1
 2a8:	bfc5                	j	298 <stat+0x28>

00000000000002aa <atoi>:

int
atoi(const char *s)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b0:	00054603          	lbu	a2,0(a0)
 2b4:	fd06079b          	addiw	a5,a2,-48
 2b8:	0ff7f793          	andi	a5,a5,255
 2bc:	4725                	li	a4,9
 2be:	02f76963          	bltu	a4,a5,2f0 <atoi+0x46>
 2c2:	86aa                	mv	a3,a0
  n = 0;
 2c4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2c6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2c8:	0685                	addi	a3,a3,1
 2ca:	0025179b          	slliw	a5,a0,0x2
 2ce:	9fa9                	addw	a5,a5,a0
 2d0:	0017979b          	slliw	a5,a5,0x1
 2d4:	9fb1                	addw	a5,a5,a2
 2d6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2da:	0006c603          	lbu	a2,0(a3)
 2de:	fd06071b          	addiw	a4,a2,-48
 2e2:	0ff77713          	andi	a4,a4,255
 2e6:	fee5f1e3          	bgeu	a1,a4,2c8 <atoi+0x1e>
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  n = 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <atoi+0x40>

00000000000002f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fa:	02b57463          	bgeu	a0,a1,322 <memmove+0x2e>
    while(n-- > 0)
 2fe:	00c05f63          	blez	a2,31c <memmove+0x28>
 302:	1602                	slli	a2,a2,0x20
 304:	9201                	srli	a2,a2,0x20
 306:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30a:	872a                	mv	a4,a0
      *dst++ = *src++;
 30c:	0585                	addi	a1,a1,1
 30e:	0705                	addi	a4,a4,1
 310:	fff5c683          	lbu	a3,-1(a1)
 314:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 328:	fec05ae3          	blez	a2,31c <memmove+0x28>
 32c:	fff6079b          	addiw	a5,a2,-1
 330:	1782                	slli	a5,a5,0x20
 332:	9381                	srli	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	addi	a1,a1,-1
 33c:	177d                	addi	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x46>
 34a:	bfc9                	j	31c <memmove+0x28>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	ca05                	beqz	a2,382 <memcmp+0x36>
 354:	fff6069b          	addiw	a3,a2,-1
 358:	1682                	slli	a3,a3,0x20
 35a:	9281                	srli	a3,a3,0x20
 35c:	0685                	addi	a3,a3,1
 35e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	00e79863          	bne	a5,a4,378 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36c:	0505                	addi	a0,a0,1
    p2++;
 36e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 370:	fed518e3          	bne	a0,a3,360 <memcmp+0x14>
  }
  return 0;
 374:	4501                	li	a0,0
 376:	a019                	j	37c <memcmp+0x30>
      return *p1 - *p2;
 378:	40e7853b          	subw	a0,a5,a4
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret
  return 0;
 382:	4501                	li	a0,0
 384:	bfe5                	j	37c <memcmp+0x30>

0000000000000386 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38e:	f67ff0ef          	jal	ra,2f4 <memmove>
}
 392:	60a2                	ld	ra,8(sp)
 394:	6402                	ld	s0,0(sp)
 396:	0141                	addi	sp,sp,16
 398:	8082                	ret

000000000000039a <sbrk>:

char *
sbrk(int n) {
 39a:	1141                	addi	sp,sp,-16
 39c:	e406                	sd	ra,8(sp)
 39e:	e022                	sd	s0,0(sp)
 3a0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3a2:	4585                	li	a1,1
 3a4:	0b2000ef          	jal	ra,456 <sys_sbrk>
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret

00000000000003b0 <sbrklazy>:

char *
sbrklazy(int n) {
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e406                	sd	ra,8(sp)
 3b4:	e022                	sd	s0,0(sp)
 3b6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3b8:	4589                	li	a1,2
 3ba:	09c000ef          	jal	ra,456 <sys_sbrk>
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret

00000000000003c6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c6:	4885                	li	a7,1
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ce:	4889                	li	a7,2
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d6:	488d                	li	a7,3
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3de:	4891                	li	a7,4
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <read>:
.global read
read:
 li a7, SYS_read
 3e6:	4895                	li	a7,5
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <write>:
.global write
write:
 li a7, SYS_write
 3ee:	48c1                	li	a7,16
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <close>:
.global close
close:
 li a7, SYS_close
 3f6:	48d5                	li	a7,21
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fe:	4899                	li	a7,6
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <exec>:
.global exec
exec:
 li a7, SYS_exec
 406:	489d                	li	a7,7
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <open>:
.global open
open:
 li a7, SYS_open
 40e:	48bd                	li	a7,15
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 416:	48c5                	li	a7,17
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41e:	48c9                	li	a7,18
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 426:	48a1                	li	a7,8
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <link>:
.global link
link:
 li a7, SYS_link
 42e:	48cd                	li	a7,19
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 436:	48d1                	li	a7,20
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43e:	48a5                	li	a7,9
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <dup>:
.global dup
dup:
 li a7, SYS_dup
 446:	48a9                	li	a7,10
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44e:	48ad                	li	a7,11
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 456:	48b1                	li	a7,12
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <pause>:
.global pause
pause:
 li a7, SYS_pause
 45e:	48b5                	li	a7,13
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 466:	48b9                	li	a7,14
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <getprocinfo>:
.global getprocinfo
getprocinfo:
 li a7, SYS_getprocinfo
 46e:	48d9                	li	a7,22
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <boostproc>:
.global boostproc
boostproc:
 li a7, SYS_boostproc
 476:	48dd                	li	a7,23
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47e:	1101                	addi	sp,sp,-32
 480:	ec06                	sd	ra,24(sp)
 482:	e822                	sd	s0,16(sp)
 484:	1000                	addi	s0,sp,32
 486:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48a:	4605                	li	a2,1
 48c:	fef40593          	addi	a1,s0,-17
 490:	f5fff0ef          	jal	ra,3ee <write>
}
 494:	60e2                	ld	ra,24(sp)
 496:	6442                	ld	s0,16(sp)
 498:	6105                	addi	sp,sp,32
 49a:	8082                	ret

000000000000049c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 49c:	715d                	addi	sp,sp,-80
 49e:	e486                	sd	ra,72(sp)
 4a0:	e0a2                	sd	s0,64(sp)
 4a2:	fc26                	sd	s1,56(sp)
 4a4:	f84a                	sd	s2,48(sp)
 4a6:	f44e                	sd	s3,40(sp)
 4a8:	0880                	addi	s0,sp,80
 4aa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4ac:	c299                	beqz	a3,4b2 <printint+0x16>
 4ae:	0805c163          	bltz	a1,530 <printint+0x94>
  neg = 0;
 4b2:	4881                	li	a7,0
 4b4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4b8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ba:	00000517          	auipc	a0,0x0
 4be:	6e650513          	addi	a0,a0,1766 # ba0 <digits>
 4c2:	883e                	mv	a6,a5
 4c4:	2785                	addiw	a5,a5,1
 4c6:	02c5f733          	remu	a4,a1,a2
 4ca:	972a                	add	a4,a4,a0
 4cc:	00074703          	lbu	a4,0(a4)
 4d0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4d4:	872e                	mv	a4,a1
 4d6:	02c5d5b3          	divu	a1,a1,a2
 4da:	0685                	addi	a3,a3,1
 4dc:	fec773e3          	bgeu	a4,a2,4c2 <printint+0x26>
  if(neg)
 4e0:	00088b63          	beqz	a7,4f6 <printint+0x5a>
    buf[i++] = '-';
 4e4:	fd040713          	addi	a4,s0,-48
 4e8:	97ba                	add	a5,a5,a4
 4ea:	02d00713          	li	a4,45
 4ee:	fee78423          	sb	a4,-24(a5)
 4f2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4f6:	02f05663          	blez	a5,522 <printint+0x86>
 4fa:	fb840713          	addi	a4,s0,-72
 4fe:	00f704b3          	add	s1,a4,a5
 502:	fff70993          	addi	s3,a4,-1
 506:	99be                	add	s3,s3,a5
 508:	37fd                	addiw	a5,a5,-1
 50a:	1782                	slli	a5,a5,0x20
 50c:	9381                	srli	a5,a5,0x20
 50e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 512:	fff4c583          	lbu	a1,-1(s1)
 516:	854a                	mv	a0,s2
 518:	f67ff0ef          	jal	ra,47e <putc>
  while(--i >= 0)
 51c:	14fd                	addi	s1,s1,-1
 51e:	ff349ae3          	bne	s1,s3,512 <printint+0x76>
}
 522:	60a6                	ld	ra,72(sp)
 524:	6406                	ld	s0,64(sp)
 526:	74e2                	ld	s1,56(sp)
 528:	7942                	ld	s2,48(sp)
 52a:	79a2                	ld	s3,40(sp)
 52c:	6161                	addi	sp,sp,80
 52e:	8082                	ret
    x = -xx;
 530:	40b005b3          	neg	a1,a1
    neg = 1;
 534:	4885                	li	a7,1
    x = -xx;
 536:	bfbd                	j	4b4 <printint+0x18>

0000000000000538 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 538:	7119                	addi	sp,sp,-128
 53a:	fc86                	sd	ra,120(sp)
 53c:	f8a2                	sd	s0,112(sp)
 53e:	f4a6                	sd	s1,104(sp)
 540:	f0ca                	sd	s2,96(sp)
 542:	ecce                	sd	s3,88(sp)
 544:	e8d2                	sd	s4,80(sp)
 546:	e4d6                	sd	s5,72(sp)
 548:	e0da                	sd	s6,64(sp)
 54a:	fc5e                	sd	s7,56(sp)
 54c:	f862                	sd	s8,48(sp)
 54e:	f466                	sd	s9,40(sp)
 550:	f06a                	sd	s10,32(sp)
 552:	ec6e                	sd	s11,24(sp)
 554:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 556:	0005c903          	lbu	s2,0(a1)
 55a:	24090c63          	beqz	s2,7b2 <vprintf+0x27a>
 55e:	8b2a                	mv	s6,a0
 560:	8a2e                	mv	s4,a1
 562:	8bb2                	mv	s7,a2
  state = 0;
 564:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 566:	4481                	li	s1,0
 568:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 56a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 56e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 572:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 576:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 57a:	00000c97          	auipc	s9,0x0
 57e:	626c8c93          	addi	s9,s9,1574 # ba0 <digits>
 582:	a005                	j	5a2 <vprintf+0x6a>
        putc(fd, c0);
 584:	85ca                	mv	a1,s2
 586:	855a                	mv	a0,s6
 588:	ef7ff0ef          	jal	ra,47e <putc>
 58c:	a019                	j	592 <vprintf+0x5a>
    } else if(state == '%'){
 58e:	03598263          	beq	s3,s5,5b2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 592:	2485                	addiw	s1,s1,1
 594:	8726                	mv	a4,s1
 596:	009a07b3          	add	a5,s4,s1
 59a:	0007c903          	lbu	s2,0(a5)
 59e:	20090a63          	beqz	s2,7b2 <vprintf+0x27a>
    c0 = fmt[i] & 0xff;
 5a2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a6:	fe0994e3          	bnez	s3,58e <vprintf+0x56>
      if(c0 == '%'){
 5aa:	fd579de3          	bne	a5,s5,584 <vprintf+0x4c>
        state = '%';
 5ae:	89be                	mv	s3,a5
 5b0:	b7cd                	j	592 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5b2:	c3c1                	beqz	a5,632 <vprintf+0xfa>
 5b4:	00ea06b3          	add	a3,s4,a4
 5b8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5bc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5be:	c681                	beqz	a3,5c6 <vprintf+0x8e>
 5c0:	9752                	add	a4,a4,s4
 5c2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5c6:	03878e63          	beq	a5,s8,602 <vprintf+0xca>
      } else if(c0 == 'l' && c1 == 'd'){
 5ca:	05a78863          	beq	a5,s10,61a <vprintf+0xe2>
      } else if(c0 == 'u'){
 5ce:	0db78b63          	beq	a5,s11,6a4 <vprintf+0x16c>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5d2:	07800713          	li	a4,120
 5d6:	10e78d63          	beq	a5,a4,6f0 <vprintf+0x1b8>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5da:	07000713          	li	a4,112
 5de:	14e78263          	beq	a5,a4,722 <vprintf+0x1ea>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5e2:	06300713          	li	a4,99
 5e6:	16e78f63          	beq	a5,a4,764 <vprintf+0x22c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5ea:	07300713          	li	a4,115
 5ee:	18e78563          	beq	a5,a4,778 <vprintf+0x240>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5f2:	05579063          	bne	a5,s5,632 <vprintf+0xfa>
        putc(fd, '%');
 5f6:	85d6                	mv	a1,s5
 5f8:	855a                	mv	a0,s6
 5fa:	e85ff0ef          	jal	ra,47e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf49                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 602:	008b8913          	addi	s2,s7,8
 606:	4685                	li	a3,1
 608:	4629                	li	a2,10
 60a:	000ba583          	lw	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	e8dff0ef          	jal	ra,49c <printint>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	bfad                	j	592 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 61a:	03868663          	beq	a3,s8,646 <vprintf+0x10e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61e:	05a68163          	beq	a3,s10,660 <vprintf+0x128>
      } else if(c0 == 'l' && c1 == 'u'){
 622:	09b68d63          	beq	a3,s11,6bc <vprintf+0x184>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 626:	03a68f63          	beq	a3,s10,664 <vprintf+0x12c>
      } else if(c0 == 'l' && c1 == 'x'){
 62a:	07800793          	li	a5,120
 62e:	0cf68d63          	beq	a3,a5,708 <vprintf+0x1d0>
        putc(fd, '%');
 632:	85d6                	mv	a1,s5
 634:	855a                	mv	a0,s6
 636:	e49ff0ef          	jal	ra,47e <putc>
        putc(fd, c0);
 63a:	85ca                	mv	a1,s2
 63c:	855a                	mv	a0,s6
 63e:	e41ff0ef          	jal	ra,47e <putc>
      state = 0;
 642:	4981                	li	s3,0
 644:	b7b9                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 646:	008b8913          	addi	s2,s7,8
 64a:	4685                	li	a3,1
 64c:	4629                	li	a2,10
 64e:	000bb583          	ld	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	e49ff0ef          	jal	ra,49c <printint>
        i += 1;
 658:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
        i += 1;
 65e:	bf15                	j	592 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 660:	03860563          	beq	a2,s8,68a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 664:	07b60963          	beq	a2,s11,6d6 <vprintf+0x19e>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 668:	07800793          	li	a5,120
 66c:	fcf613e3          	bne	a2,a5,632 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 670:	008b8913          	addi	s2,s7,8
 674:	4681                	li	a3,0
 676:	4641                	li	a2,16
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	e1fff0ef          	jal	ra,49c <printint>
        i += 2;
 682:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 2;
 688:	b729                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000bb583          	ld	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	e05ff0ef          	jal	ra,49c <printint>
        i += 2;
 69c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
        i += 2;
 6a2:	bdc5                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4629                	li	a2,10
 6ac:	000be583          	lwu	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	debff0ef          	jal	ra,49c <printint>
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bde1                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4629                	li	a2,10
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	dd3ff0ef          	jal	ra,49c <printint>
        i += 1;
 6ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 1;
 6d4:	bd7d                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d6:	008b8913          	addi	s2,s7,8
 6da:	4681                	li	a3,0
 6dc:	4629                	li	a2,10
 6de:	000bb583          	ld	a1,0(s7)
 6e2:	855a                	mv	a0,s6
 6e4:	db9ff0ef          	jal	ra,49c <printint>
        i += 2;
 6e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
        i += 2;
 6ee:	b555                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4641                	li	a2,16
 6f8:	000be583          	lwu	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	d9fff0ef          	jal	ra,49c <printint>
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	b571                	j	592 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 708:	008b8913          	addi	s2,s7,8
 70c:	4681                	li	a3,0
 70e:	4641                	li	a2,16
 710:	000bb583          	ld	a1,0(s7)
 714:	855a                	mv	a0,s6
 716:	d87ff0ef          	jal	ra,49c <printint>
        i += 1;
 71a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
        i += 1;
 720:	bd8d                	j	592 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 722:	008b8793          	addi	a5,s7,8
 726:	f8f43423          	sd	a5,-120(s0)
 72a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 72e:	03000593          	li	a1,48
 732:	855a                	mv	a0,s6
 734:	d4bff0ef          	jal	ra,47e <putc>
  putc(fd, 'x');
 738:	07800593          	li	a1,120
 73c:	855a                	mv	a0,s6
 73e:	d41ff0ef          	jal	ra,47e <putc>
 742:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 744:	03c9d793          	srli	a5,s3,0x3c
 748:	97e6                	add	a5,a5,s9
 74a:	0007c583          	lbu	a1,0(a5)
 74e:	855a                	mv	a0,s6
 750:	d2fff0ef          	jal	ra,47e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 754:	0992                	slli	s3,s3,0x4
 756:	397d                	addiw	s2,s2,-1
 758:	fe0916e3          	bnez	s2,744 <vprintf+0x20c>
        printptr(fd, va_arg(ap, uint64));
 75c:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 760:	4981                	li	s3,0
 762:	bd05                	j	592 <vprintf+0x5a>
        putc(fd, va_arg(ap, uint32));
 764:	008b8913          	addi	s2,s7,8
 768:	000bc583          	lbu	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	d11ff0ef          	jal	ra,47e <putc>
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	bd31                	j	592 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 778:	008b8993          	addi	s3,s7,8
 77c:	000bb903          	ld	s2,0(s7)
 780:	00090f63          	beqz	s2,79e <vprintf+0x266>
        for(; *s; s++)
 784:	00094583          	lbu	a1,0(s2)
 788:	c195                	beqz	a1,7ac <vprintf+0x274>
          putc(fd, *s);
 78a:	855a                	mv	a0,s6
 78c:	cf3ff0ef          	jal	ra,47e <putc>
        for(; *s; s++)
 790:	0905                	addi	s2,s2,1
 792:	00094583          	lbu	a1,0(s2)
 796:	f9f5                	bnez	a1,78a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 798:	8bce                	mv	s7,s3
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bbdd                	j	592 <vprintf+0x5a>
          s = "(null)";
 79e:	00000917          	auipc	s2,0x0
 7a2:	3fa90913          	addi	s2,s2,1018 # b98 <malloc+0x2e4>
        for(; *s; s++)
 7a6:	02800593          	li	a1,40
 7aa:	b7c5                	j	78a <vprintf+0x252>
        if((s = va_arg(ap, char*)) == 0)
 7ac:	8bce                	mv	s7,s3
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b3cd                	j	592 <vprintf+0x5a>
    }
  }
}
 7b2:	70e6                	ld	ra,120(sp)
 7b4:	7446                	ld	s0,112(sp)
 7b6:	74a6                	ld	s1,104(sp)
 7b8:	7906                	ld	s2,96(sp)
 7ba:	69e6                	ld	s3,88(sp)
 7bc:	6a46                	ld	s4,80(sp)
 7be:	6aa6                	ld	s5,72(sp)
 7c0:	6b06                	ld	s6,64(sp)
 7c2:	7be2                	ld	s7,56(sp)
 7c4:	7c42                	ld	s8,48(sp)
 7c6:	7ca2                	ld	s9,40(sp)
 7c8:	7d02                	ld	s10,32(sp)
 7ca:	6de2                	ld	s11,24(sp)
 7cc:	6109                	addi	sp,sp,128
 7ce:	8082                	ret

00000000000007d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d0:	715d                	addi	sp,sp,-80
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	e010                	sd	a2,0(s0)
 7da:	e414                	sd	a3,8(s0)
 7dc:	e818                	sd	a4,16(s0)
 7de:	ec1c                	sd	a5,24(s0)
 7e0:	03043023          	sd	a6,32(s0)
 7e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ec:	8622                	mv	a2,s0
 7ee:	d4bff0ef          	jal	ra,538 <vprintf>
}
 7f2:	60e2                	ld	ra,24(sp)
 7f4:	6442                	ld	s0,16(sp)
 7f6:	6161                	addi	sp,sp,80
 7f8:	8082                	ret

00000000000007fa <printf>:

void
printf(const char *fmt, ...)
{
 7fa:	711d                	addi	sp,sp,-96
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	e40c                	sd	a1,8(s0)
 804:	e810                	sd	a2,16(s0)
 806:	ec14                	sd	a3,24(s0)
 808:	f018                	sd	a4,32(s0)
 80a:	f41c                	sd	a5,40(s0)
 80c:	03043823          	sd	a6,48(s0)
 810:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 814:	00840613          	addi	a2,s0,8
 818:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81c:	85aa                	mv	a1,a0
 81e:	4505                	li	a0,1
 820:	d19ff0ef          	jal	ra,538 <vprintf>
}
 824:	60e2                	ld	ra,24(sp)
 826:	6442                	ld	s0,16(sp)
 828:	6125                	addi	sp,sp,96
 82a:	8082                	ret

000000000000082c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82c:	1141                	addi	sp,sp,-16
 82e:	e422                	sd	s0,8(sp)
 830:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 832:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 836:	00000797          	auipc	a5,0x0
 83a:	7ca7b783          	ld	a5,1994(a5) # 1000 <freep>
 83e:	a805                	j	86e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 840:	4618                	lw	a4,8(a2)
 842:	9db9                	addw	a1,a1,a4
 844:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 848:	6398                	ld	a4,0(a5)
 84a:	6318                	ld	a4,0(a4)
 84c:	fee53823          	sd	a4,-16(a0)
 850:	a091                	j	894 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 852:	ff852703          	lw	a4,-8(a0)
 856:	9e39                	addw	a2,a2,a4
 858:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 85a:	ff053703          	ld	a4,-16(a0)
 85e:	e398                	sd	a4,0(a5)
 860:	a099                	j	8a6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	6398                	ld	a4,0(a5)
 864:	00e7e463          	bltu	a5,a4,86c <free+0x40>
 868:	00e6ea63          	bltu	a3,a4,87c <free+0x50>
{
 86c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86e:	fed7fae3          	bgeu	a5,a3,862 <free+0x36>
 872:	6398                	ld	a4,0(a5)
 874:	00e6e463          	bltu	a3,a4,87c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 878:	fee7eae3          	bltu	a5,a4,86c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 87c:	ff852583          	lw	a1,-8(a0)
 880:	6390                	ld	a2,0(a5)
 882:	02059713          	slli	a4,a1,0x20
 886:	9301                	srli	a4,a4,0x20
 888:	0712                	slli	a4,a4,0x4
 88a:	9736                	add	a4,a4,a3
 88c:	fae60ae3          	beq	a2,a4,840 <free+0x14>
    bp->s.ptr = p->s.ptr;
 890:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 894:	4790                	lw	a2,8(a5)
 896:	02061713          	slli	a4,a2,0x20
 89a:	9301                	srli	a4,a4,0x20
 89c:	0712                	slli	a4,a4,0x4
 89e:	973e                	add	a4,a4,a5
 8a0:	fae689e3          	beq	a3,a4,852 <free+0x26>
  } else
    p->s.ptr = bp;
 8a4:	e394                	sd	a3,0(a5)
  freep = p;
 8a6:	00000717          	auipc	a4,0x0
 8aa:	74f73d23          	sd	a5,1882(a4) # 1000 <freep>
}
 8ae:	6422                	ld	s0,8(sp)
 8b0:	0141                	addi	sp,sp,16
 8b2:	8082                	ret

00000000000008b4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b4:	7139                	addi	sp,sp,-64
 8b6:	fc06                	sd	ra,56(sp)
 8b8:	f822                	sd	s0,48(sp)
 8ba:	f426                	sd	s1,40(sp)
 8bc:	f04a                	sd	s2,32(sp)
 8be:	ec4e                	sd	s3,24(sp)
 8c0:	e852                	sd	s4,16(sp)
 8c2:	e456                	sd	s5,8(sp)
 8c4:	e05a                	sd	s6,0(sp)
 8c6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c8:	02051493          	slli	s1,a0,0x20
 8cc:	9081                	srli	s1,s1,0x20
 8ce:	04bd                	addi	s1,s1,15
 8d0:	8091                	srli	s1,s1,0x4
 8d2:	0014899b          	addiw	s3,s1,1
 8d6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d8:	00000517          	auipc	a0,0x0
 8dc:	72853503          	ld	a0,1832(a0) # 1000 <freep>
 8e0:	c515                	beqz	a0,90c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e4:	4798                	lw	a4,8(a5)
 8e6:	02977f63          	bgeu	a4,s1,924 <malloc+0x70>
 8ea:	8a4e                	mv	s4,s3
 8ec:	0009871b          	sext.w	a4,s3
 8f0:	6685                	lui	a3,0x1
 8f2:	00d77363          	bgeu	a4,a3,8f8 <malloc+0x44>
 8f6:	6a05                	lui	s4,0x1
 8f8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 900:	00000917          	auipc	s2,0x0
 904:	70090913          	addi	s2,s2,1792 # 1000 <freep>
  if(p == SBRK_ERROR)
 908:	5afd                	li	s5,-1
 90a:	a0bd                	j	978 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 90c:	00000797          	auipc	a5,0x0
 910:	70478793          	addi	a5,a5,1796 # 1010 <base>
 914:	00000717          	auipc	a4,0x0
 918:	6ef73623          	sd	a5,1772(a4) # 1000 <freep>
 91c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 91e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 922:	b7e1                	j	8ea <malloc+0x36>
      if(p->s.size == nunits)
 924:	02e48b63          	beq	s1,a4,95a <malloc+0xa6>
        p->s.size -= nunits;
 928:	4137073b          	subw	a4,a4,s3
 92c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92e:	1702                	slli	a4,a4,0x20
 930:	9301                	srli	a4,a4,0x20
 932:	0712                	slli	a4,a4,0x4
 934:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 936:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 93a:	00000717          	auipc	a4,0x0
 93e:	6ca73323          	sd	a0,1734(a4) # 1000 <freep>
      return (void*)(p + 1);
 942:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 946:	70e2                	ld	ra,56(sp)
 948:	7442                	ld	s0,48(sp)
 94a:	74a2                	ld	s1,40(sp)
 94c:	7902                	ld	s2,32(sp)
 94e:	69e2                	ld	s3,24(sp)
 950:	6a42                	ld	s4,16(sp)
 952:	6aa2                	ld	s5,8(sp)
 954:	6b02                	ld	s6,0(sp)
 956:	6121                	addi	sp,sp,64
 958:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 95a:	6398                	ld	a4,0(a5)
 95c:	e118                	sd	a4,0(a0)
 95e:	bff1                	j	93a <malloc+0x86>
  hp->s.size = nu;
 960:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 964:	0541                	addi	a0,a0,16
 966:	ec7ff0ef          	jal	ra,82c <free>
  return freep;
 96a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 96e:	dd61                	beqz	a0,946 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 970:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 972:	4798                	lw	a4,8(a5)
 974:	fa9778e3          	bgeu	a4,s1,924 <malloc+0x70>
    if(p == freep)
 978:	00093703          	ld	a4,0(s2)
 97c:	853e                	mv	a0,a5
 97e:	fef719e3          	bne	a4,a5,970 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 982:	8552                	mv	a0,s4
 984:	a17ff0ef          	jal	ra,39a <sbrk>
  if(p == SBRK_ERROR)
 988:	fd551ce3          	bne	a0,s5,960 <malloc+0xac>
        return 0;
 98c:	4501                	li	a0,0
 98e:	bf65                	j	946 <malloc+0x92>
