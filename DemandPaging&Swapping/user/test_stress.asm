
user/_test_stress:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
// Simple LCG for pseudo-randomness in xv6 user space (no srand/rand)
static unsigned long seed = 1;
static unsigned long lcg(void){ seed = seed * 6364136223846793005UL + 1; return seed; }

int main(void)
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	ec5e                	sd	s7,24(sp)
  14:	e862                	sd	s8,16(sp)
  16:	1080                	addi	s0,sp,96
  printf("[test_stress] start\n");
  18:	00001517          	auipc	a0,0x1
  1c:	9b850513          	addi	a0,a0,-1608 # 9d0 <malloc+0x102>
  20:	7fa000ef          	jal	81a <printf>
  int pages = MANY; // large to drive swap pressure
  24:	6989                	lui	s3,0x2
  26:	32898993          	addi	s3,s3,808 # 2328 <base+0x1308>
  char *base = (char*)-1;
  while (pages >= MINP) {
    printf("[test_stress] sbrk %d pages\n", pages);
  2a:	00001917          	auipc	s2,0x1
  2e:	9c690913          	addi	s2,s2,-1594 # 9f0 <malloc+0x122>
  base = sbrklazy(pages * PGSIZE);
    if (base != (char*)-1) break;
  32:	54fd                	li	s1,-1
  while (pages >= MINP) {
  34:	6a05                	lui	s4,0x1
    printf("[test_stress] sbrk %d pages\n", pages);
  36:	85ce                	mv	a1,s3
  38:	854a                	mv	a0,s2
  3a:	7e0000ef          	jal	81a <printf>
  base = sbrklazy(pages * PGSIZE);
  3e:	00c9951b          	slliw	a0,s3,0xc
  42:	38a000ef          	jal	3cc <sbrklazy>
  46:	8b2a                	mv	s6,a0
    if (base != (char*)-1) break;
  48:	0a951663          	bne	a0,s1,f4 <main+0xf4>
    pages = (pages * 3) / 4;
  4c:	0019979b          	slliw	a5,s3,0x1
  50:	013787bb          	addw	a5,a5,s3
  54:	0007871b          	sext.w	a4,a5
  58:	41f7d99b          	sraiw	s3,a5,0x1f
  5c:	01e9d99b          	srliw	s3,s3,0x1e
  60:	00f989bb          	addw	s3,s3,a5
  64:	4029d99b          	sraiw	s3,s3,0x2
  while (pages >= MINP) {
  68:	fd4757e3          	bge	a4,s4,36 <main+0x36>
  }
  if (base == (char*)-1) {
    printf("[test_stress] sbrk failed for all attempts\nTEST FAILED\n");
  6c:	00001517          	auipc	a0,0x1
  70:	a1c50513          	addi	a0,a0,-1508 # a88 <malloc+0x1ba>
  74:	7a6000ef          	jal	81a <printf>
    exit(1);
  78:	4505                	li	a0,1
  7a:	370000ef          	jal	3ea <exit>
    int idx = (int)(lcg() % pages);
    char *p = base + idx * PGSIZE;
    if (lcg() & 1) {
      p[0] = (char)(idx ^ (i & 0x7f)); // write
    } else {
      sum += p[0]; // read
  7e:	fac42683          	lw	a3,-84(s0)
  82:	00074783          	lbu	a5,0(a4)
  86:	9fb5                	addw	a5,a5,a3
  88:	faf42623          	sw	a5,-84(s0)
    }
    if ((i % 2000) == 0) printf("[test_stress] iter %d/%d\n", i, iters);
  8c:	0374e7bb          	remw	a5,s1,s7
  90:	cb9d                	beqz	a5,c6 <main+0xc6>
  for (int i = 0; i < iters; i++) {
  92:	2485                	addiw	s1,s1,1
  94:	03548f63          	beq	s1,s5,d2 <main+0xd2>
static unsigned long lcg(void){ seed = seed * 6364136223846793005UL + 1; return seed; }
  98:	000a3783          	ld	a5,0(s4) # 1000 <seed>
  9c:	032787b3          	mul	a5,a5,s2
  a0:	0785                	addi	a5,a5,1
    int idx = (int)(lcg() % pages);
  a2:	0337f6b3          	remu	a3,a5,s3
    char *p = base + idx * PGSIZE;
  a6:	00c6971b          	slliw	a4,a3,0xc
  aa:	975a                	add	a4,a4,s6
static unsigned long lcg(void){ seed = seed * 6364136223846793005UL + 1; return seed; }
  ac:	032787b3          	mul	a5,a5,s2
  b0:	0785                	addi	a5,a5,1
  b2:	00fa3023          	sd	a5,0(s4)
    if (lcg() & 1) {
  b6:	8b85                	andi	a5,a5,1
  b8:	d3f9                	beqz	a5,7e <main+0x7e>
      p[0] = (char)(idx ^ (i & 0x7f)); // write
  ba:	07f4f793          	andi	a5,s1,127
  be:	8fb5                	xor	a5,a5,a3
  c0:	00f70023          	sb	a5,0(a4)
  c4:	b7e1                	j	8c <main+0x8c>
    if ((i % 2000) == 0) printf("[test_stress] iter %d/%d\n", i, iters);
  c6:	8656                	mv	a2,s5
  c8:	85a6                	mv	a1,s1
  ca:	8562                	mv	a0,s8
  cc:	74e000ef          	jal	81a <printf>
  d0:	b7c9                	j	92 <main+0x92>
  }
  printf("[test_stress] sum=%d\n", sum);
  d2:	fac42583          	lw	a1,-84(s0)
  d6:	00001517          	auipc	a0,0x1
  da:	95a50513          	addi	a0,a0,-1702 # a30 <malloc+0x162>
  de:	73c000ef          	jal	81a <printf>
  printf("TEST PASSED\n");
  e2:	00001517          	auipc	a0,0x1
  e6:	96650513          	addi	a0,a0,-1690 # a48 <malloc+0x17a>
  ea:	730000ef          	jal	81a <printf>
  exit(0);
  ee:	4501                	li	a0,0
  f0:	2fa000ef          	jal	3ea <exit>
  printf("[test_stress] initializing first 1024 pages\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	96450513          	addi	a0,a0,-1692 # a58 <malloc+0x18a>
  fc:	71e000ef          	jal	81a <printf>
  for (int i = 0; i < 1024 && i < pages; i++) base[i*PGSIZE] = (char)i;
 100:	875a                	mv	a4,s6
 102:	4781                	li	a5,0
 104:	40000693          	li	a3,1024
 108:	6605                	lui	a2,0x1
 10a:	00f70023          	sb	a5,0(a4)
 10e:	2785                	addiw	a5,a5,1
 110:	00d78563          	beq	a5,a3,11a <main+0x11a>
 114:	9732                	add	a4,a4,a2
 116:	ff379ae3          	bne	a5,s3,10a <main+0x10a>
  volatile int sum = 0;
 11a:	fa042623          	sw	zero,-84(s0)
  for (int i = 0; i < iters; i++) {
 11e:	4481                	li	s1,0
static unsigned long lcg(void){ seed = seed * 6364136223846793005UL + 1; return seed; }
 120:	00001a17          	auipc	s4,0x1
 124:	ee0a0a13          	addi	s4,s4,-288 # 1000 <seed>
 128:	00161937          	lui	s2,0x161
 12c:	47d90913          	addi	s2,s2,1149 # 16147d <base+0x16045d>
 130:	093a                	slli	s2,s2,0xe
 132:	2d590913          	addi	s2,s2,725
 136:	0936                	slli	s2,s2,0xd
 138:	92b90913          	addi	s2,s2,-1749
 13c:	093e                	slli	s2,s2,0xf
 13e:	f2d90913          	addi	s2,s2,-211
    if ((i % 2000) == 0) printf("[test_stress] iter %d/%d\n", i, iters);
 142:	7d000b93          	li	s7,2000
 146:	6a95                	lui	s5,0x5
 148:	e20a8a93          	addi	s5,s5,-480 # 4e20 <base+0x3e00>
 14c:	00001c17          	auipc	s8,0x1
 150:	8c4c0c13          	addi	s8,s8,-1852 # a10 <malloc+0x142>
 154:	b791                	j	98 <main+0x98>

0000000000000156 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 156:	1141                	addi	sp,sp,-16
 158:	e406                	sd	ra,8(sp)
 15a:	e022                	sd	s0,0(sp)
 15c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 15e:	ea3ff0ef          	jal	0 <main>
  exit(r);
 162:	288000ef          	jal	3ea <exit>

0000000000000166 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 16c:	87aa                	mv	a5,a0
 16e:	0585                	addi	a1,a1,1
 170:	0785                	addi	a5,a5,1
 172:	fff5c703          	lbu	a4,-1(a1)
 176:	fee78fa3          	sb	a4,-1(a5)
 17a:	fb75                	bnez	a4,16e <strcpy+0x8>
    ;
  return os;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 188:	00054783          	lbu	a5,0(a0)
 18c:	cb91                	beqz	a5,1a0 <strcmp+0x1e>
 18e:	0005c703          	lbu	a4,0(a1)
 192:	00f71763          	bne	a4,a5,1a0 <strcmp+0x1e>
    p++, q++;
 196:	0505                	addi	a0,a0,1
 198:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 19a:	00054783          	lbu	a5,0(a0)
 19e:	fbe5                	bnez	a5,18e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a0:	0005c503          	lbu	a0,0(a1)
}
 1a4:	40a7853b          	subw	a0,a5,a0
 1a8:	6422                	ld	s0,8(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret

00000000000001ae <strlen>:

uint
strlen(const char *s)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	cf91                	beqz	a5,1d4 <strlen+0x26>
 1ba:	0505                	addi	a0,a0,1
 1bc:	87aa                	mv	a5,a0
 1be:	86be                	mv	a3,a5
 1c0:	0785                	addi	a5,a5,1
 1c2:	fff7c703          	lbu	a4,-1(a5)
 1c6:	ff65                	bnez	a4,1be <strlen+0x10>
 1c8:	40a6853b          	subw	a0,a3,a0
 1cc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1ce:	6422                	ld	s0,8(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret
  for(n = 0; s[n]; n++)
 1d4:	4501                	li	a0,0
 1d6:	bfe5                	j	1ce <strlen+0x20>

00000000000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1de:	ca19                	beqz	a2,1f4 <memset+0x1c>
 1e0:	87aa                	mv	a5,a0
 1e2:	1602                	slli	a2,a2,0x20
 1e4:	9201                	srli	a2,a2,0x20
 1e6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ea:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ee:	0785                	addi	a5,a5,1
 1f0:	fee79de3          	bne	a5,a4,1ea <memset+0x12>
  }
  return dst;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret

00000000000001fa <strchr>:

char*
strchr(const char *s, char c)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  for(; *s; s++)
 200:	00054783          	lbu	a5,0(a0)
 204:	cb99                	beqz	a5,21a <strchr+0x20>
    if(*s == c)
 206:	00f58763          	beq	a1,a5,214 <strchr+0x1a>
  for(; *s; s++)
 20a:	0505                	addi	a0,a0,1
 20c:	00054783          	lbu	a5,0(a0)
 210:	fbfd                	bnez	a5,206 <strchr+0xc>
      return (char*)s;
  return 0;
 212:	4501                	li	a0,0
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
  return 0;
 21a:	4501                	li	a0,0
 21c:	bfe5                	j	214 <strchr+0x1a>

000000000000021e <gets>:

char*
gets(char *buf, int max)
{
 21e:	711d                	addi	sp,sp,-96
 220:	ec86                	sd	ra,88(sp)
 222:	e8a2                	sd	s0,80(sp)
 224:	e4a6                	sd	s1,72(sp)
 226:	e0ca                	sd	s2,64(sp)
 228:	fc4e                	sd	s3,56(sp)
 22a:	f852                	sd	s4,48(sp)
 22c:	f456                	sd	s5,40(sp)
 22e:	f05a                	sd	s6,32(sp)
 230:	ec5e                	sd	s7,24(sp)
 232:	1080                	addi	s0,sp,96
 234:	8baa                	mv	s7,a0
 236:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 238:	892a                	mv	s2,a0
 23a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 23c:	4aa9                	li	s5,10
 23e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 240:	89a6                	mv	s3,s1
 242:	2485                	addiw	s1,s1,1
 244:	0344d663          	bge	s1,s4,270 <gets+0x52>
    cc = read(0, &c, 1);
 248:	4605                	li	a2,1
 24a:	faf40593          	addi	a1,s0,-81
 24e:	4501                	li	a0,0
 250:	1b2000ef          	jal	402 <read>
    if(cc < 1)
 254:	00a05e63          	blez	a0,270 <gets+0x52>
    buf[i++] = c;
 258:	faf44783          	lbu	a5,-81(s0)
 25c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 260:	01578763          	beq	a5,s5,26e <gets+0x50>
 264:	0905                	addi	s2,s2,1
 266:	fd679de3          	bne	a5,s6,240 <gets+0x22>
    buf[i++] = c;
 26a:	89a6                	mv	s3,s1
 26c:	a011                	j	270 <gets+0x52>
 26e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 270:	99de                	add	s3,s3,s7
 272:	00098023          	sb	zero,0(s3)
  return buf;
}
 276:	855e                	mv	a0,s7
 278:	60e6                	ld	ra,88(sp)
 27a:	6446                	ld	s0,80(sp)
 27c:	64a6                	ld	s1,72(sp)
 27e:	6906                	ld	s2,64(sp)
 280:	79e2                	ld	s3,56(sp)
 282:	7a42                	ld	s4,48(sp)
 284:	7aa2                	ld	s5,40(sp)
 286:	7b02                	ld	s6,32(sp)
 288:	6be2                	ld	s7,24(sp)
 28a:	6125                	addi	sp,sp,96
 28c:	8082                	ret

000000000000028e <stat>:

int
stat(const char *n, struct stat *st)
{
 28e:	1101                	addi	sp,sp,-32
 290:	ec06                	sd	ra,24(sp)
 292:	e822                	sd	s0,16(sp)
 294:	e04a                	sd	s2,0(sp)
 296:	1000                	addi	s0,sp,32
 298:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29a:	4581                	li	a1,0
 29c:	18e000ef          	jal	42a <open>
  if(fd < 0)
 2a0:	02054263          	bltz	a0,2c4 <stat+0x36>
 2a4:	e426                	sd	s1,8(sp)
 2a6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a8:	85ca                	mv	a1,s2
 2aa:	198000ef          	jal	442 <fstat>
 2ae:	892a                	mv	s2,a0
  close(fd);
 2b0:	8526                	mv	a0,s1
 2b2:	160000ef          	jal	412 <close>
  return r;
 2b6:	64a2                	ld	s1,8(sp)
}
 2b8:	854a                	mv	a0,s2
 2ba:	60e2                	ld	ra,24(sp)
 2bc:	6442                	ld	s0,16(sp)
 2be:	6902                	ld	s2,0(sp)
 2c0:	6105                	addi	sp,sp,32
 2c2:	8082                	ret
    return -1;
 2c4:	597d                	li	s2,-1
 2c6:	bfcd                	j	2b8 <stat+0x2a>

00000000000002c8 <atoi>:

int
atoi(const char *s)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ce:	00054683          	lbu	a3,0(a0)
 2d2:	fd06879b          	addiw	a5,a3,-48
 2d6:	0ff7f793          	zext.b	a5,a5
 2da:	4625                	li	a2,9
 2dc:	02f66863          	bltu	a2,a5,30c <atoi+0x44>
 2e0:	872a                	mv	a4,a0
  n = 0;
 2e2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2e4:	0705                	addi	a4,a4,1
 2e6:	0025179b          	slliw	a5,a0,0x2
 2ea:	9fa9                	addw	a5,a5,a0
 2ec:	0017979b          	slliw	a5,a5,0x1
 2f0:	9fb5                	addw	a5,a5,a3
 2f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f6:	00074683          	lbu	a3,0(a4)
 2fa:	fd06879b          	addiw	a5,a3,-48
 2fe:	0ff7f793          	zext.b	a5,a5
 302:	fef671e3          	bgeu	a2,a5,2e4 <atoi+0x1c>
  return n;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  n = 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <atoi+0x3e>

0000000000000310 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 316:	02b57463          	bgeu	a0,a1,33e <memmove+0x2e>
    while(n-- > 0)
 31a:	00c05f63          	blez	a2,338 <memmove+0x28>
 31e:	1602                	slli	a2,a2,0x20
 320:	9201                	srli	a2,a2,0x20
 322:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 326:	872a                	mv	a4,a0
      *dst++ = *src++;
 328:	0585                	addi	a1,a1,1
 32a:	0705                	addi	a4,a4,1
 32c:	fff5c683          	lbu	a3,-1(a1)
 330:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 334:	fef71ae3          	bne	a4,a5,328 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret
    dst += n;
 33e:	00c50733          	add	a4,a0,a2
    src += n;
 342:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 344:	fec05ae3          	blez	a2,338 <memmove+0x28>
 348:	fff6079b          	addiw	a5,a2,-1 # fff <digits+0x537>
 34c:	1782                	slli	a5,a5,0x20
 34e:	9381                	srli	a5,a5,0x20
 350:	fff7c793          	not	a5,a5
 354:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 356:	15fd                	addi	a1,a1,-1
 358:	177d                	addi	a4,a4,-1
 35a:	0005c683          	lbu	a3,0(a1)
 35e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 362:	fee79ae3          	bne	a5,a4,356 <memmove+0x46>
 366:	bfc9                	j	338 <memmove+0x28>

0000000000000368 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e422                	sd	s0,8(sp)
 36c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 36e:	ca05                	beqz	a2,39e <memcmp+0x36>
 370:	fff6069b          	addiw	a3,a2,-1
 374:	1682                	slli	a3,a3,0x20
 376:	9281                	srli	a3,a3,0x20
 378:	0685                	addi	a3,a3,1
 37a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 37c:	00054783          	lbu	a5,0(a0)
 380:	0005c703          	lbu	a4,0(a1)
 384:	00e79863          	bne	a5,a4,394 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 388:	0505                	addi	a0,a0,1
    p2++;
 38a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 38c:	fed518e3          	bne	a0,a3,37c <memcmp+0x14>
  }
  return 0;
 390:	4501                	li	a0,0
 392:	a019                	j	398 <memcmp+0x30>
      return *p1 - *p2;
 394:	40e7853b          	subw	a0,a5,a4
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret
  return 0;
 39e:	4501                	li	a0,0
 3a0:	bfe5                	j	398 <memcmp+0x30>

00000000000003a2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e406                	sd	ra,8(sp)
 3a6:	e022                	sd	s0,0(sp)
 3a8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3aa:	f67ff0ef          	jal	310 <memmove>
}
 3ae:	60a2                	ld	ra,8(sp)
 3b0:	6402                	ld	s0,0(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret

00000000000003b6 <sbrk>:

char *
sbrk(int n) {
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e406                	sd	ra,8(sp)
 3ba:	e022                	sd	s0,0(sp)
 3bc:	0800                	addi	s0,sp,16
  // Eager allocation by default to preserve original xv6 semantics
  // relied upon by many user programs and tests (e.g., countfree).
  return sys_sbrk(n, SBRK_EAGER);
 3be:	4585                	li	a1,1
 3c0:	0b2000ef          	jal	472 <sys_sbrk>
}
 3c4:	60a2                	ld	ra,8(sp)
 3c6:	6402                	ld	s0,0(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret

00000000000003cc <sbrklazy>:

char *
sbrklazy(int n) {
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e406                	sd	ra,8(sp)
 3d0:	e022                	sd	s0,0(sp)
 3d2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3d4:	4589                	li	a1,2
 3d6:	09c000ef          	jal	472 <sys_sbrk>
}
 3da:	60a2                	ld	ra,8(sp)
 3dc:	6402                	ld	s0,0(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret

00000000000003e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e2:	4885                	li	a7,1
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ea:	4889                	li	a7,2
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f2:	488d                	li	a7,3
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fa:	4891                	li	a7,4
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <read>:
.global read
read:
 li a7, SYS_read
 402:	4895                	li	a7,5
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <write>:
.global write
write:
 li a7, SYS_write
 40a:	48c1                	li	a7,16
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <close>:
.global close
close:
 li a7, SYS_close
 412:	48d5                	li	a7,21
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <kill>:
.global kill
kill:
 li a7, SYS_kill
 41a:	4899                	li	a7,6
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <exec>:
.global exec
exec:
 li a7, SYS_exec
 422:	489d                	li	a7,7
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <open>:
.global open
open:
 li a7, SYS_open
 42a:	48bd                	li	a7,15
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 432:	48c5                	li	a7,17
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43a:	48c9                	li	a7,18
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 442:	48a1                	li	a7,8
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <link>:
.global link
link:
 li a7, SYS_link
 44a:	48cd                	li	a7,19
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 452:	48d1                	li	a7,20
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45a:	48a5                	li	a7,9
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <dup>:
.global dup
dup:
 li a7, SYS_dup
 462:	48a9                	li	a7,10
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46a:	48ad                	li	a7,11
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 472:	48b1                	li	a7,12
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <pause>:
.global pause
pause:
 li a7, SYS_pause
 47a:	48b5                	li	a7,13
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 482:	48b9                	li	a7,14
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 48a:	48d9                	li	a7,22
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 492:	1101                	addi	sp,sp,-32
 494:	ec06                	sd	ra,24(sp)
 496:	e822                	sd	s0,16(sp)
 498:	1000                	addi	s0,sp,32
 49a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49e:	4605                	li	a2,1
 4a0:	fef40593          	addi	a1,s0,-17
 4a4:	f67ff0ef          	jal	40a <write>
}
 4a8:	60e2                	ld	ra,24(sp)
 4aa:	6442                	ld	s0,16(sp)
 4ac:	6105                	addi	sp,sp,32
 4ae:	8082                	ret

00000000000004b0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4b0:	715d                	addi	sp,sp,-80
 4b2:	e486                	sd	ra,72(sp)
 4b4:	e0a2                	sd	s0,64(sp)
 4b6:	f84a                	sd	s2,48(sp)
 4b8:	0880                	addi	s0,sp,80
 4ba:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4bc:	c299                	beqz	a3,4c2 <printint+0x12>
 4be:	0805c363          	bltz	a1,544 <printint+0x94>
  neg = 0;
 4c2:	4881                	li	a7,0
 4c4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4c8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ca:	00000517          	auipc	a0,0x0
 4ce:	5fe50513          	addi	a0,a0,1534 # ac8 <digits>
 4d2:	883e                	mv	a6,a5
 4d4:	2785                	addiw	a5,a5,1
 4d6:	02c5f733          	remu	a4,a1,a2
 4da:	972a                	add	a4,a4,a0
 4dc:	00074703          	lbu	a4,0(a4)
 4e0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4e4:	872e                	mv	a4,a1
 4e6:	02c5d5b3          	divu	a1,a1,a2
 4ea:	0685                	addi	a3,a3,1
 4ec:	fec773e3          	bgeu	a4,a2,4d2 <printint+0x22>
  if(neg)
 4f0:	00088b63          	beqz	a7,506 <printint+0x56>
    buf[i++] = '-';
 4f4:	fd078793          	addi	a5,a5,-48
 4f8:	97a2                	add	a5,a5,s0
 4fa:	02d00713          	li	a4,45
 4fe:	fee78423          	sb	a4,-24(a5)
 502:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 506:	02f05a63          	blez	a5,53a <printint+0x8a>
 50a:	fc26                	sd	s1,56(sp)
 50c:	f44e                	sd	s3,40(sp)
 50e:	fb840713          	addi	a4,s0,-72
 512:	00f704b3          	add	s1,a4,a5
 516:	fff70993          	addi	s3,a4,-1
 51a:	99be                	add	s3,s3,a5
 51c:	37fd                	addiw	a5,a5,-1
 51e:	1782                	slli	a5,a5,0x20
 520:	9381                	srli	a5,a5,0x20
 522:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 526:	fff4c583          	lbu	a1,-1(s1)
 52a:	854a                	mv	a0,s2
 52c:	f67ff0ef          	jal	492 <putc>
  while(--i >= 0)
 530:	14fd                	addi	s1,s1,-1
 532:	ff349ae3          	bne	s1,s3,526 <printint+0x76>
 536:	74e2                	ld	s1,56(sp)
 538:	79a2                	ld	s3,40(sp)
}
 53a:	60a6                	ld	ra,72(sp)
 53c:	6406                	ld	s0,64(sp)
 53e:	7942                	ld	s2,48(sp)
 540:	6161                	addi	sp,sp,80
 542:	8082                	ret
    x = -xx;
 544:	40b005b3          	neg	a1,a1
    neg = 1;
 548:	4885                	li	a7,1
    x = -xx;
 54a:	bfad                	j	4c4 <printint+0x14>

000000000000054c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54c:	711d                	addi	sp,sp,-96
 54e:	ec86                	sd	ra,88(sp)
 550:	e8a2                	sd	s0,80(sp)
 552:	e0ca                	sd	s2,64(sp)
 554:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 556:	0005c903          	lbu	s2,0(a1)
 55a:	28090663          	beqz	s2,7e6 <vprintf+0x29a>
 55e:	e4a6                	sd	s1,72(sp)
 560:	fc4e                	sd	s3,56(sp)
 562:	f852                	sd	s4,48(sp)
 564:	f456                	sd	s5,40(sp)
 566:	f05a                	sd	s6,32(sp)
 568:	ec5e                	sd	s7,24(sp)
 56a:	e862                	sd	s8,16(sp)
 56c:	e466                	sd	s9,8(sp)
 56e:	8b2a                	mv	s6,a0
 570:	8a2e                	mv	s4,a1
 572:	8bb2                	mv	s7,a2
  state = 0;
 574:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 576:	4481                	li	s1,0
 578:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 57a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 57e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 582:	06c00c93          	li	s9,108
 586:	a005                	j	5a6 <vprintf+0x5a>
        putc(fd, c0);
 588:	85ca                	mv	a1,s2
 58a:	855a                	mv	a0,s6
 58c:	f07ff0ef          	jal	492 <putc>
 590:	a019                	j	596 <vprintf+0x4a>
    } else if(state == '%'){
 592:	03598263          	beq	s3,s5,5b6 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 596:	2485                	addiw	s1,s1,1
 598:	8726                	mv	a4,s1
 59a:	009a07b3          	add	a5,s4,s1
 59e:	0007c903          	lbu	s2,0(a5)
 5a2:	22090a63          	beqz	s2,7d6 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5a6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5aa:	fe0994e3          	bnez	s3,592 <vprintf+0x46>
      if(c0 == '%'){
 5ae:	fd579de3          	bne	a5,s5,588 <vprintf+0x3c>
        state = '%';
 5b2:	89be                	mv	s3,a5
 5b4:	b7cd                	j	596 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5b6:	00ea06b3          	add	a3,s4,a4
 5ba:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5be:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5c0:	c681                	beqz	a3,5c8 <vprintf+0x7c>
 5c2:	9752                	add	a4,a4,s4
 5c4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5c8:	05878363          	beq	a5,s8,60e <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5cc:	05978d63          	beq	a5,s9,626 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5d0:	07500713          	li	a4,117
 5d4:	0ee78763          	beq	a5,a4,6c2 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5d8:	07800713          	li	a4,120
 5dc:	12e78963          	beq	a5,a4,70e <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5e0:	07000713          	li	a4,112
 5e4:	14e78e63          	beq	a5,a4,740 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5e8:	06300713          	li	a4,99
 5ec:	18e78e63          	beq	a5,a4,788 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5f0:	07300713          	li	a4,115
 5f4:	1ae78463          	beq	a5,a4,79c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5f8:	02500713          	li	a4,37
 5fc:	04e79563          	bne	a5,a4,646 <vprintf+0xfa>
        putc(fd, '%');
 600:	02500593          	li	a1,37
 604:	855a                	mv	a0,s6
 606:	e8dff0ef          	jal	492 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 60a:	4981                	li	s3,0
 60c:	b769                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 60e:	008b8913          	addi	s2,s7,8
 612:	4685                	li	a3,1
 614:	4629                	li	a2,10
 616:	000ba583          	lw	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	e95ff0ef          	jal	4b0 <printint>
 620:	8bca                	mv	s7,s2
      state = 0;
 622:	4981                	li	s3,0
 624:	bf8d                	j	596 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 626:	06400793          	li	a5,100
 62a:	02f68963          	beq	a3,a5,65c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 62e:	06c00793          	li	a5,108
 632:	04f68263          	beq	a3,a5,676 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 636:	07500793          	li	a5,117
 63a:	0af68063          	beq	a3,a5,6da <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 63e:	07800793          	li	a5,120
 642:	0ef68263          	beq	a3,a5,726 <vprintf+0x1da>
        putc(fd, '%');
 646:	02500593          	li	a1,37
 64a:	855a                	mv	a0,s6
 64c:	e47ff0ef          	jal	492 <putc>
        putc(fd, c0);
 650:	85ca                	mv	a1,s2
 652:	855a                	mv	a0,s6
 654:	e3fff0ef          	jal	492 <putc>
      state = 0;
 658:	4981                	li	s3,0
 65a:	bf35                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65c:	008b8913          	addi	s2,s7,8
 660:	4685                	li	a3,1
 662:	4629                	li	a2,10
 664:	000bb583          	ld	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	e47ff0ef          	jal	4b0 <printint>
        i += 1;
 66e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 670:	8bca                	mv	s7,s2
      state = 0;
 672:	4981                	li	s3,0
        i += 1;
 674:	b70d                	j	596 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 676:	06400793          	li	a5,100
 67a:	02f60763          	beq	a2,a5,6a8 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 67e:	07500793          	li	a5,117
 682:	06f60963          	beq	a2,a5,6f4 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 686:	07800793          	li	a5,120
 68a:	faf61ee3          	bne	a2,a5,646 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 68e:	008b8913          	addi	s2,s7,8
 692:	4681                	li	a3,0
 694:	4641                	li	a2,16
 696:	000bb583          	ld	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	e15ff0ef          	jal	4b0 <printint>
        i += 2;
 6a0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a2:	8bca                	mv	s7,s2
      state = 0;
 6a4:	4981                	li	s3,0
        i += 2;
 6a6:	bdc5                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4685                	li	a3,1
 6ae:	4629                	li	a2,10
 6b0:	000bb583          	ld	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	dfbff0ef          	jal	4b0 <printint>
        i += 2;
 6ba:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
        i += 2;
 6c0:	bdd9                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4629                	li	a2,10
 6ca:	000be583          	lwu	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	de1ff0ef          	jal	4b0 <printint>
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bd7d                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	dc9ff0ef          	jal	4b0 <printint>
        i += 1;
 6ec:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 1;
 6f2:	b555                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4629                	li	a2,10
 6fc:	000bb583          	ld	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	dafff0ef          	jal	4b0 <printint>
        i += 2;
 706:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 708:	8bca                	mv	s7,s2
      state = 0;
 70a:	4981                	li	s3,0
        i += 2;
 70c:	b569                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 70e:	008b8913          	addi	s2,s7,8
 712:	4681                	li	a3,0
 714:	4641                	li	a2,16
 716:	000be583          	lwu	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	d95ff0ef          	jal	4b0 <printint>
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	bd8d                	j	596 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4641                	li	a2,16
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	d7dff0ef          	jal	4b0 <printint>
        i += 1;
 738:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
        i += 1;
 73e:	bda1                	j	596 <vprintf+0x4a>
 740:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 742:	008b8d13          	addi	s10,s7,8
 746:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 74a:	03000593          	li	a1,48
 74e:	855a                	mv	a0,s6
 750:	d43ff0ef          	jal	492 <putc>
  putc(fd, 'x');
 754:	07800593          	li	a1,120
 758:	855a                	mv	a0,s6
 75a:	d39ff0ef          	jal	492 <putc>
 75e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 760:	00000b97          	auipc	s7,0x0
 764:	368b8b93          	addi	s7,s7,872 # ac8 <digits>
 768:	03c9d793          	srli	a5,s3,0x3c
 76c:	97de                	add	a5,a5,s7
 76e:	0007c583          	lbu	a1,0(a5)
 772:	855a                	mv	a0,s6
 774:	d1fff0ef          	jal	492 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 778:	0992                	slli	s3,s3,0x4
 77a:	397d                	addiw	s2,s2,-1
 77c:	fe0916e3          	bnez	s2,768 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 780:	8bea                	mv	s7,s10
      state = 0;
 782:	4981                	li	s3,0
 784:	6d02                	ld	s10,0(sp)
 786:	bd01                	j	596 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 788:	008b8913          	addi	s2,s7,8
 78c:	000bc583          	lbu	a1,0(s7)
 790:	855a                	mv	a0,s6
 792:	d01ff0ef          	jal	492 <putc>
 796:	8bca                	mv	s7,s2
      state = 0;
 798:	4981                	li	s3,0
 79a:	bbf5                	j	596 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 79c:	008b8993          	addi	s3,s7,8
 7a0:	000bb903          	ld	s2,0(s7)
 7a4:	00090f63          	beqz	s2,7c2 <vprintf+0x276>
        for(; *s; s++)
 7a8:	00094583          	lbu	a1,0(s2)
 7ac:	c195                	beqz	a1,7d0 <vprintf+0x284>
          putc(fd, *s);
 7ae:	855a                	mv	a0,s6
 7b0:	ce3ff0ef          	jal	492 <putc>
        for(; *s; s++)
 7b4:	0905                	addi	s2,s2,1
 7b6:	00094583          	lbu	a1,0(s2)
 7ba:	f9f5                	bnez	a1,7ae <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7bc:	8bce                	mv	s7,s3
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	bbd9                	j	596 <vprintf+0x4a>
          s = "(null)";
 7c2:	00000917          	auipc	s2,0x0
 7c6:	2fe90913          	addi	s2,s2,766 # ac0 <malloc+0x1f2>
        for(; *s; s++)
 7ca:	02800593          	li	a1,40
 7ce:	b7c5                	j	7ae <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7d0:	8bce                	mv	s7,s3
      state = 0;
 7d2:	4981                	li	s3,0
 7d4:	b3c9                	j	596 <vprintf+0x4a>
 7d6:	64a6                	ld	s1,72(sp)
 7d8:	79e2                	ld	s3,56(sp)
 7da:	7a42                	ld	s4,48(sp)
 7dc:	7aa2                	ld	s5,40(sp)
 7de:	7b02                	ld	s6,32(sp)
 7e0:	6be2                	ld	s7,24(sp)
 7e2:	6c42                	ld	s8,16(sp)
 7e4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7e6:	60e6                	ld	ra,88(sp)
 7e8:	6446                	ld	s0,80(sp)
 7ea:	6906                	ld	s2,64(sp)
 7ec:	6125                	addi	sp,sp,96
 7ee:	8082                	ret

00000000000007f0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f0:	715d                	addi	sp,sp,-80
 7f2:	ec06                	sd	ra,24(sp)
 7f4:	e822                	sd	s0,16(sp)
 7f6:	1000                	addi	s0,sp,32
 7f8:	e010                	sd	a2,0(s0)
 7fa:	e414                	sd	a3,8(s0)
 7fc:	e818                	sd	a4,16(s0)
 7fe:	ec1c                	sd	a5,24(s0)
 800:	03043023          	sd	a6,32(s0)
 804:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 808:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 80c:	8622                	mv	a2,s0
 80e:	d3fff0ef          	jal	54c <vprintf>
}
 812:	60e2                	ld	ra,24(sp)
 814:	6442                	ld	s0,16(sp)
 816:	6161                	addi	sp,sp,80
 818:	8082                	ret

000000000000081a <printf>:

void
printf(const char *fmt, ...)
{
 81a:	711d                	addi	sp,sp,-96
 81c:	ec06                	sd	ra,24(sp)
 81e:	e822                	sd	s0,16(sp)
 820:	1000                	addi	s0,sp,32
 822:	e40c                	sd	a1,8(s0)
 824:	e810                	sd	a2,16(s0)
 826:	ec14                	sd	a3,24(s0)
 828:	f018                	sd	a4,32(s0)
 82a:	f41c                	sd	a5,40(s0)
 82c:	03043823          	sd	a6,48(s0)
 830:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 834:	00840613          	addi	a2,s0,8
 838:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 83c:	85aa                	mv	a1,a0
 83e:	4505                	li	a0,1
 840:	d0dff0ef          	jal	54c <vprintf>
}
 844:	60e2                	ld	ra,24(sp)
 846:	6442                	ld	s0,16(sp)
 848:	6125                	addi	sp,sp,96
 84a:	8082                	ret

000000000000084c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 84c:	1141                	addi	sp,sp,-16
 84e:	e422                	sd	s0,8(sp)
 850:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 852:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 856:	00000797          	auipc	a5,0x0
 85a:	7ba7b783          	ld	a5,1978(a5) # 1010 <freep>
 85e:	a02d                	j	888 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 860:	4618                	lw	a4,8(a2)
 862:	9f2d                	addw	a4,a4,a1
 864:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 868:	6398                	ld	a4,0(a5)
 86a:	6310                	ld	a2,0(a4)
 86c:	a83d                	j	8aa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 86e:	ff852703          	lw	a4,-8(a0)
 872:	9f31                	addw	a4,a4,a2
 874:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 876:	ff053683          	ld	a3,-16(a0)
 87a:	a091                	j	8be <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87c:	6398                	ld	a4,0(a5)
 87e:	00e7e463          	bltu	a5,a4,886 <free+0x3a>
 882:	00e6ea63          	bltu	a3,a4,896 <free+0x4a>
{
 886:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 888:	fed7fae3          	bgeu	a5,a3,87c <free+0x30>
 88c:	6398                	ld	a4,0(a5)
 88e:	00e6e463          	bltu	a3,a4,896 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	fee7eae3          	bltu	a5,a4,886 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 896:	ff852583          	lw	a1,-8(a0)
 89a:	6390                	ld	a2,0(a5)
 89c:	02059813          	slli	a6,a1,0x20
 8a0:	01c85713          	srli	a4,a6,0x1c
 8a4:	9736                	add	a4,a4,a3
 8a6:	fae60de3          	beq	a2,a4,860 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8aa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ae:	4790                	lw	a2,8(a5)
 8b0:	02061593          	slli	a1,a2,0x20
 8b4:	01c5d713          	srli	a4,a1,0x1c
 8b8:	973e                	add	a4,a4,a5
 8ba:	fae68ae3          	beq	a3,a4,86e <free+0x22>
    p->s.ptr = bp->s.ptr;
 8be:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8c0:	00000717          	auipc	a4,0x0
 8c4:	74f73823          	sd	a5,1872(a4) # 1010 <freep>
}
 8c8:	6422                	ld	s0,8(sp)
 8ca:	0141                	addi	sp,sp,16
 8cc:	8082                	ret

00000000000008ce <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ce:	7139                	addi	sp,sp,-64
 8d0:	fc06                	sd	ra,56(sp)
 8d2:	f822                	sd	s0,48(sp)
 8d4:	f426                	sd	s1,40(sp)
 8d6:	ec4e                	sd	s3,24(sp)
 8d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8da:	02051493          	slli	s1,a0,0x20
 8de:	9081                	srli	s1,s1,0x20
 8e0:	04bd                	addi	s1,s1,15
 8e2:	8091                	srli	s1,s1,0x4
 8e4:	0014899b          	addiw	s3,s1,1
 8e8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ea:	00000517          	auipc	a0,0x0
 8ee:	72653503          	ld	a0,1830(a0) # 1010 <freep>
 8f2:	c915                	beqz	a0,926 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f6:	4798                	lw	a4,8(a5)
 8f8:	08977a63          	bgeu	a4,s1,98c <malloc+0xbe>
 8fc:	f04a                	sd	s2,32(sp)
 8fe:	e852                	sd	s4,16(sp)
 900:	e456                	sd	s5,8(sp)
 902:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 904:	8a4e                	mv	s4,s3
 906:	0009871b          	sext.w	a4,s3
 90a:	6685                	lui	a3,0x1
 90c:	00d77363          	bgeu	a4,a3,912 <malloc+0x44>
 910:	6a05                	lui	s4,0x1
 912:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 916:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 91a:	00000917          	auipc	s2,0x0
 91e:	6f690913          	addi	s2,s2,1782 # 1010 <freep>
  if(p == SBRK_ERROR)
 922:	5afd                	li	s5,-1
 924:	a081                	j	964 <malloc+0x96>
 926:	f04a                	sd	s2,32(sp)
 928:	e852                	sd	s4,16(sp)
 92a:	e456                	sd	s5,8(sp)
 92c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 92e:	00000797          	auipc	a5,0x0
 932:	6f278793          	addi	a5,a5,1778 # 1020 <base>
 936:	00000717          	auipc	a4,0x0
 93a:	6cf73d23          	sd	a5,1754(a4) # 1010 <freep>
 93e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 940:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 944:	b7c1                	j	904 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 946:	6398                	ld	a4,0(a5)
 948:	e118                	sd	a4,0(a0)
 94a:	a8a9                	j	9a4 <malloc+0xd6>
  hp->s.size = nu;
 94c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 950:	0541                	addi	a0,a0,16
 952:	efbff0ef          	jal	84c <free>
  return freep;
 956:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 95a:	c12d                	beqz	a0,9bc <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95e:	4798                	lw	a4,8(a5)
 960:	02977263          	bgeu	a4,s1,984 <malloc+0xb6>
    if(p == freep)
 964:	00093703          	ld	a4,0(s2)
 968:	853e                	mv	a0,a5
 96a:	fef719e3          	bne	a4,a5,95c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 96e:	8552                	mv	a0,s4
 970:	a47ff0ef          	jal	3b6 <sbrk>
  if(p == SBRK_ERROR)
 974:	fd551ce3          	bne	a0,s5,94c <malloc+0x7e>
        return 0;
 978:	4501                	li	a0,0
 97a:	7902                	ld	s2,32(sp)
 97c:	6a42                	ld	s4,16(sp)
 97e:	6aa2                	ld	s5,8(sp)
 980:	6b02                	ld	s6,0(sp)
 982:	a03d                	j	9b0 <malloc+0xe2>
 984:	7902                	ld	s2,32(sp)
 986:	6a42                	ld	s4,16(sp)
 988:	6aa2                	ld	s5,8(sp)
 98a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 98c:	fae48de3          	beq	s1,a4,946 <malloc+0x78>
        p->s.size -= nunits;
 990:	4137073b          	subw	a4,a4,s3
 994:	c798                	sw	a4,8(a5)
        p += p->s.size;
 996:	02071693          	slli	a3,a4,0x20
 99a:	01c6d713          	srli	a4,a3,0x1c
 99e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9a0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9a4:	00000717          	auipc	a4,0x0
 9a8:	66a73623          	sd	a0,1644(a4) # 1010 <freep>
      return (void*)(p + 1);
 9ac:	01078513          	addi	a0,a5,16
  }
}
 9b0:	70e2                	ld	ra,56(sp)
 9b2:	7442                	ld	s0,48(sp)
 9b4:	74a2                	ld	s1,40(sp)
 9b6:	69e2                	ld	s3,24(sp)
 9b8:	6121                	addi	sp,sp,64
 9ba:	8082                	ret
 9bc:	7902                	ld	s2,32(sp)
 9be:	6a42                	ld	s4,16(sp)
 9c0:	6aa2                	ld	s5,8(sp)
 9c2:	6b02                	ld	s6,0(sp)
 9c4:	b7f5                	j	9b0 <malloc+0xe2>
