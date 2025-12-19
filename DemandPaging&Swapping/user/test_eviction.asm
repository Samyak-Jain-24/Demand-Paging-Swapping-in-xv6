
user/_test_eviction:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
// Choose a large count to likely exceed RAM so eviction happens
#define MANY_PAGES 6000
#define MIN_PAGES 1024

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
  14:	1080                	addi	s0,sp,96
  printf("[test_eviction] start\n");
  16:	00001517          	auipc	a0,0x1
  1a:	98a50513          	addi	a0,a0,-1654 # 9a0 <malloc+0xfa>
  1e:	7d4000ef          	jal	7f2 <printf>

    int target = MANY_PAGES;
  22:	6485                	lui	s1,0x1
  24:	77048493          	addi	s1,s1,1904 # 1770 <base+0x760>
    char *base = (char*)-1;
    while (target >= MIN_PAGES) {
      printf("[test_eviction] Trying to allocate %d pages...\n", target);
  28:	00001a17          	auipc	s4,0x1
  2c:	998a0a13          	addi	s4,s4,-1640 # 9c0 <malloc+0x11a>
    base = sbrklazy(target * PGSIZE);
      if (base != (char*)-1) break;
  30:	597d                	li	s2,-1
    while (target >= MIN_PAGES) {
  32:	6a85                	lui	s5,0x1
      printf("[test_eviction] Trying to allocate %d pages...\n", target);
  34:	85a6                	mv	a1,s1
  36:	8552                	mv	a0,s4
  38:	7ba000ef          	jal	7f2 <printf>
    base = sbrklazy(target * PGSIZE);
  3c:	00c4951b          	slliw	a0,s1,0xc
  40:	364000ef          	jal	3a4 <sbrklazy>
  44:	89aa                	mv	s3,a0
      if (base != (char*)-1) break;
  46:	0b251b63          	bne	a0,s2,fc <main+0xfc>
      target = (target * 3) / 4; // back off
  4a:	0014979b          	slliw	a5,s1,0x1
  4e:	9fa5                	addw	a5,a5,s1
  50:	0007871b          	sext.w	a4,a5
  54:	41f7d49b          	sraiw	s1,a5,0x1f
  58:	01e4d49b          	srliw	s1,s1,0x1e
  5c:	9cbd                	addw	s1,s1,a5
  5e:	4024d49b          	sraiw	s1,s1,0x2
    while (target >= MIN_PAGES) {
  62:	fd5759e3          	bge	a4,s5,34 <main+0x34>
    }
    if (base == (char*)-1) {
      printf("[test_eviction] sbrk failed for all attempts\nTEST FAILED\n");
  66:	00001517          	auipc	a0,0x1
  6a:	a8a50513          	addi	a0,a0,-1398 # af0 <malloc+0x24a>
  6e:	784000ef          	jal	7f2 <printf>
      exit(1);
  72:	4505                	li	a0,1
  74:	34e000ef          	jal	3c2 <exit>
    for (int i = 0; i < target; i++) {
    char *p = base + i * PGSIZE;
    if ((i & 1) == 0) {
      p[0] = (char)i; // dirty page
    } else {
      sum += p[0]; // read-only access, cleaner victim candidate
  78:	fac42703          	lw	a4,-84(s0)
  7c:	000a4783          	lbu	a5,0(s4)
  80:	9fb9                	addw	a5,a5,a4
  82:	faf42623          	sw	a5,-84(s0)
    }
    if ((i % 512) == 0) {
  86:	1ff97793          	andi	a5,s2,511
  8a:	cb99                	beqz	a5,a0 <main+0xa0>
    for (int i = 0; i < target; i++) {
  8c:	2905                	addiw	s2,s2,1
  8e:	9a5a                	add	s4,s4,s6
  90:	00990d63          	beq	s2,s1,aa <main+0xaa>
    if ((i & 1) == 0) {
  94:	00197793          	andi	a5,s2,1
  98:	f3e5                	bnez	a5,78 <main+0x78>
      p[0] = (char)i; // dirty page
  9a:	012a0023          	sb	s2,0(s4)
  9e:	b7e5                	j	86 <main+0x86>
      printf("  touched %d pages...\n", i);
  a0:	85ca                	mv	a1,s2
  a2:	855e                	mv	a0,s7
  a4:	74e000ef          	jal	7f2 <printf>
  a8:	b7d5                	j	8c <main+0x8c>
    }
  }

  // Re-access early pages to likely trigger SWAPIN of previously evicted ones
  printf("[test_eviction] Re-accessing first 128 pages to provoke SWAPIN...\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	95e50513          	addi	a0,a0,-1698 # a08 <malloc+0x162>
  b2:	740000ef          	jal	7f2 <printf>
    for (int i = 0; i < 128 && i < target; i++) {
  b6:	0007f6b7          	lui	a3,0x7f
  ba:	96ce                	add	a3,a3,s3
  bc:	04b2                	slli	s1,s1,0xc
  be:	94ce                	add	s1,s1,s3
  c0:	6605                	lui	a2,0x1
    char *p = base + i * PGSIZE;
    sum += p[0];
  c2:	fac42703          	lw	a4,-84(s0)
  c6:	000ac783          	lbu	a5,0(s5) # 1000 <freep>
  ca:	9fb9                	addw	a5,a5,a4
  cc:	faf42623          	sw	a5,-84(s0)
    for (int i = 0; i < 128 && i < target; i++) {
  d0:	00da8563          	beq	s5,a3,da <main+0xda>
  d4:	9ab2                	add	s5,s5,a2
  d6:	fe9a96e3          	bne	s5,s1,c2 <main+0xc2>
  }

  printf("[test_eviction] sum=%d\n", sum);
  da:	fac42583          	lw	a1,-84(s0)
  de:	00001517          	auipc	a0,0x1
  e2:	97250513          	addi	a0,a0,-1678 # a50 <malloc+0x1aa>
  e6:	70c000ef          	jal	7f2 <printf>
  printf("TEST PASSED\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	97e50513          	addi	a0,a0,-1666 # a68 <malloc+0x1c2>
  f2:	700000ef          	jal	7f2 <printf>
  exit(0);
  f6:	4501                	li	a0,0
  f8:	2ca000ef          	jal	3c2 <exit>
    printf("[test_eviction] Allocated %d pages at %p\n", target, base);
  fc:	862a                	mv	a2,a0
  fe:	85a6                	mv	a1,s1
 100:	00001517          	auipc	a0,0x1
 104:	97850513          	addi	a0,a0,-1672 # a78 <malloc+0x1d2>
 108:	6ea000ef          	jal	7f2 <printf>
  printf("[test_eviction] Touching pages to fill memory and force eviction...\n");
 10c:	00001517          	auipc	a0,0x1
 110:	99c50513          	addi	a0,a0,-1636 # aa8 <malloc+0x202>
 114:	6de000ef          	jal	7f2 <printf>
  volatile int sum = 0;
 118:	fa042623          	sw	zero,-84(s0)
    for (int i = 0; i < target; i++) {
 11c:	8ace                	mv	s5,s3
  volatile int sum = 0;
 11e:	8a4e                	mv	s4,s3
    for (int i = 0; i < target; i++) {
 120:	4901                	li	s2,0
      printf("  touched %d pages...\n", i);
 122:	00001b97          	auipc	s7,0x1
 126:	8ceb8b93          	addi	s7,s7,-1842 # 9f0 <malloc+0x14a>
    for (int i = 0; i < target; i++) {
 12a:	6b05                	lui	s6,0x1
 12c:	b7a5                	j	94 <main+0x94>

000000000000012e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 136:	ecbff0ef          	jal	0 <main>
  exit(r);
 13a:	288000ef          	jal	3c2 <exit>

000000000000013e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 144:	87aa                	mv	a5,a0
 146:	0585                	addi	a1,a1,1
 148:	0785                	addi	a5,a5,1
 14a:	fff5c703          	lbu	a4,-1(a1)
 14e:	fee78fa3          	sb	a4,-1(a5)
 152:	fb75                	bnez	a4,146 <strcpy+0x8>
    ;
  return os;
}
 154:	6422                	ld	s0,8(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret

000000000000015a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 160:	00054783          	lbu	a5,0(a0)
 164:	cb91                	beqz	a5,178 <strcmp+0x1e>
 166:	0005c703          	lbu	a4,0(a1)
 16a:	00f71763          	bne	a4,a5,178 <strcmp+0x1e>
    p++, q++;
 16e:	0505                	addi	a0,a0,1
 170:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 172:	00054783          	lbu	a5,0(a0)
 176:	fbe5                	bnez	a5,166 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 178:	0005c503          	lbu	a0,0(a1)
}
 17c:	40a7853b          	subw	a0,a5,a0
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret

0000000000000186 <strlen>:

uint
strlen(const char *s)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 18c:	00054783          	lbu	a5,0(a0)
 190:	cf91                	beqz	a5,1ac <strlen+0x26>
 192:	0505                	addi	a0,a0,1
 194:	87aa                	mv	a5,a0
 196:	86be                	mv	a3,a5
 198:	0785                	addi	a5,a5,1
 19a:	fff7c703          	lbu	a4,-1(a5)
 19e:	ff65                	bnez	a4,196 <strlen+0x10>
 1a0:	40a6853b          	subw	a0,a3,a0
 1a4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	addi	sp,sp,16
 1aa:	8082                	ret
  for(n = 0; s[n]; n++)
 1ac:	4501                	li	a0,0
 1ae:	bfe5                	j	1a6 <strlen+0x20>

00000000000001b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b6:	ca19                	beqz	a2,1cc <memset+0x1c>
 1b8:	87aa                	mv	a5,a0
 1ba:	1602                	slli	a2,a2,0x20
 1bc:	9201                	srli	a2,a2,0x20
 1be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c6:	0785                	addi	a5,a5,1
 1c8:	fee79de3          	bne	a5,a4,1c2 <memset+0x12>
  }
  return dst;
}
 1cc:	6422                	ld	s0,8(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret

00000000000001d2 <strchr>:

char*
strchr(const char *s, char c)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e422                	sd	s0,8(sp)
 1d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	cb99                	beqz	a5,1f2 <strchr+0x20>
    if(*s == c)
 1de:	00f58763          	beq	a1,a5,1ec <strchr+0x1a>
  for(; *s; s++)
 1e2:	0505                	addi	a0,a0,1
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbfd                	bnez	a5,1de <strchr+0xc>
      return (char*)s;
  return 0;
 1ea:	4501                	li	a0,0
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret
  return 0;
 1f2:	4501                	li	a0,0
 1f4:	bfe5                	j	1ec <strchr+0x1a>

00000000000001f6 <gets>:

char*
gets(char *buf, int max)
{
 1f6:	711d                	addi	sp,sp,-96
 1f8:	ec86                	sd	ra,88(sp)
 1fa:	e8a2                	sd	s0,80(sp)
 1fc:	e4a6                	sd	s1,72(sp)
 1fe:	e0ca                	sd	s2,64(sp)
 200:	fc4e                	sd	s3,56(sp)
 202:	f852                	sd	s4,48(sp)
 204:	f456                	sd	s5,40(sp)
 206:	f05a                	sd	s6,32(sp)
 208:	ec5e                	sd	s7,24(sp)
 20a:	1080                	addi	s0,sp,96
 20c:	8baa                	mv	s7,a0
 20e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 210:	892a                	mv	s2,a0
 212:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 214:	4aa9                	li	s5,10
 216:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 218:	89a6                	mv	s3,s1
 21a:	2485                	addiw	s1,s1,1
 21c:	0344d663          	bge	s1,s4,248 <gets+0x52>
    cc = read(0, &c, 1);
 220:	4605                	li	a2,1
 222:	faf40593          	addi	a1,s0,-81
 226:	4501                	li	a0,0
 228:	1b2000ef          	jal	3da <read>
    if(cc < 1)
 22c:	00a05e63          	blez	a0,248 <gets+0x52>
    buf[i++] = c;
 230:	faf44783          	lbu	a5,-81(s0)
 234:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 238:	01578763          	beq	a5,s5,246 <gets+0x50>
 23c:	0905                	addi	s2,s2,1
 23e:	fd679de3          	bne	a5,s6,218 <gets+0x22>
    buf[i++] = c;
 242:	89a6                	mv	s3,s1
 244:	a011                	j	248 <gets+0x52>
 246:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 248:	99de                	add	s3,s3,s7
 24a:	00098023          	sb	zero,0(s3)
  return buf;
}
 24e:	855e                	mv	a0,s7
 250:	60e6                	ld	ra,88(sp)
 252:	6446                	ld	s0,80(sp)
 254:	64a6                	ld	s1,72(sp)
 256:	6906                	ld	s2,64(sp)
 258:	79e2                	ld	s3,56(sp)
 25a:	7a42                	ld	s4,48(sp)
 25c:	7aa2                	ld	s5,40(sp)
 25e:	7b02                	ld	s6,32(sp)
 260:	6be2                	ld	s7,24(sp)
 262:	6125                	addi	sp,sp,96
 264:	8082                	ret

0000000000000266 <stat>:

int
stat(const char *n, struct stat *st)
{
 266:	1101                	addi	sp,sp,-32
 268:	ec06                	sd	ra,24(sp)
 26a:	e822                	sd	s0,16(sp)
 26c:	e04a                	sd	s2,0(sp)
 26e:	1000                	addi	s0,sp,32
 270:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	4581                	li	a1,0
 274:	18e000ef          	jal	402 <open>
  if(fd < 0)
 278:	02054263          	bltz	a0,29c <stat+0x36>
 27c:	e426                	sd	s1,8(sp)
 27e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 280:	85ca                	mv	a1,s2
 282:	198000ef          	jal	41a <fstat>
 286:	892a                	mv	s2,a0
  close(fd);
 288:	8526                	mv	a0,s1
 28a:	160000ef          	jal	3ea <close>
  return r;
 28e:	64a2                	ld	s1,8(sp)
}
 290:	854a                	mv	a0,s2
 292:	60e2                	ld	ra,24(sp)
 294:	6442                	ld	s0,16(sp)
 296:	6902                	ld	s2,0(sp)
 298:	6105                	addi	sp,sp,32
 29a:	8082                	ret
    return -1;
 29c:	597d                	li	s2,-1
 29e:	bfcd                	j	290 <stat+0x2a>

00000000000002a0 <atoi>:

int
atoi(const char *s)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a6:	00054683          	lbu	a3,0(a0)
 2aa:	fd06879b          	addiw	a5,a3,-48 # 7efd0 <base+0x7dfc0>
 2ae:	0ff7f793          	zext.b	a5,a5
 2b2:	4625                	li	a2,9
 2b4:	02f66863          	bltu	a2,a5,2e4 <atoi+0x44>
 2b8:	872a                	mv	a4,a0
  n = 0;
 2ba:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2bc:	0705                	addi	a4,a4,1
 2be:	0025179b          	slliw	a5,a0,0x2
 2c2:	9fa9                	addw	a5,a5,a0
 2c4:	0017979b          	slliw	a5,a5,0x1
 2c8:	9fb5                	addw	a5,a5,a3
 2ca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ce:	00074683          	lbu	a3,0(a4)
 2d2:	fd06879b          	addiw	a5,a3,-48
 2d6:	0ff7f793          	zext.b	a5,a5
 2da:	fef671e3          	bgeu	a2,a5,2bc <atoi+0x1c>
  return n;
}
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
  n = 0;
 2e4:	4501                	li	a0,0
 2e6:	bfe5                	j	2de <atoi+0x3e>

00000000000002e8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ee:	02b57463          	bgeu	a0,a1,316 <memmove+0x2e>
    while(n-- > 0)
 2f2:	00c05f63          	blez	a2,310 <memmove+0x28>
 2f6:	1602                	slli	a2,a2,0x20
 2f8:	9201                	srli	a2,a2,0x20
 2fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 300:	0585                	addi	a1,a1,1
 302:	0705                	addi	a4,a4,1
 304:	fff5c683          	lbu	a3,-1(a1)
 308:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 30c:	fef71ae3          	bne	a4,a5,300 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret
    dst += n;
 316:	00c50733          	add	a4,a0,a2
    src += n;
 31a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 31c:	fec05ae3          	blez	a2,310 <memmove+0x28>
 320:	fff6079b          	addiw	a5,a2,-1 # fff <digits+0x4c7>
 324:	1782                	slli	a5,a5,0x20
 326:	9381                	srli	a5,a5,0x20
 328:	fff7c793          	not	a5,a5
 32c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 32e:	15fd                	addi	a1,a1,-1
 330:	177d                	addi	a4,a4,-1
 332:	0005c683          	lbu	a3,0(a1)
 336:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 33a:	fee79ae3          	bne	a5,a4,32e <memmove+0x46>
 33e:	bfc9                	j	310 <memmove+0x28>

0000000000000340 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 346:	ca05                	beqz	a2,376 <memcmp+0x36>
 348:	fff6069b          	addiw	a3,a2,-1
 34c:	1682                	slli	a3,a3,0x20
 34e:	9281                	srli	a3,a3,0x20
 350:	0685                	addi	a3,a3,1
 352:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 354:	00054783          	lbu	a5,0(a0)
 358:	0005c703          	lbu	a4,0(a1)
 35c:	00e79863          	bne	a5,a4,36c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 360:	0505                	addi	a0,a0,1
    p2++;
 362:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 364:	fed518e3          	bne	a0,a3,354 <memcmp+0x14>
  }
  return 0;
 368:	4501                	li	a0,0
 36a:	a019                	j	370 <memcmp+0x30>
      return *p1 - *p2;
 36c:	40e7853b          	subw	a0,a5,a4
}
 370:	6422                	ld	s0,8(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret
  return 0;
 376:	4501                	li	a0,0
 378:	bfe5                	j	370 <memcmp+0x30>

000000000000037a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 382:	f67ff0ef          	jal	2e8 <memmove>
}
 386:	60a2                	ld	ra,8(sp)
 388:	6402                	ld	s0,0(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret

000000000000038e <sbrk>:

char *
sbrk(int n) {
 38e:	1141                	addi	sp,sp,-16
 390:	e406                	sd	ra,8(sp)
 392:	e022                	sd	s0,0(sp)
 394:	0800                	addi	s0,sp,16
  // Eager allocation by default to preserve original xv6 semantics
  // relied upon by many user programs and tests (e.g., countfree).
  return sys_sbrk(n, SBRK_EAGER);
 396:	4585                	li	a1,1
 398:	0b2000ef          	jal	44a <sys_sbrk>
}
 39c:	60a2                	ld	ra,8(sp)
 39e:	6402                	ld	s0,0(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret

00000000000003a4 <sbrklazy>:

char *
sbrklazy(int n) {
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e406                	sd	ra,8(sp)
 3a8:	e022                	sd	s0,0(sp)
 3aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3ac:	4589                	li	a1,2
 3ae:	09c000ef          	jal	44a <sys_sbrk>
}
 3b2:	60a2                	ld	ra,8(sp)
 3b4:	6402                	ld	s0,0(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret

00000000000003ba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ba:	4885                	li	a7,1
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c2:	4889                	li	a7,2
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ca:	488d                	li	a7,3
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d2:	4891                	li	a7,4
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <read>:
.global read
read:
 li a7, SYS_read
 3da:	4895                	li	a7,5
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <write>:
.global write
write:
 li a7, SYS_write
 3e2:	48c1                	li	a7,16
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <close>:
.global close
close:
 li a7, SYS_close
 3ea:	48d5                	li	a7,21
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f2:	4899                	li	a7,6
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fa:	489d                	li	a7,7
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <open>:
.global open
open:
 li a7, SYS_open
 402:	48bd                	li	a7,15
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40a:	48c5                	li	a7,17
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 412:	48c9                	li	a7,18
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41a:	48a1                	li	a7,8
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <link>:
.global link
link:
 li a7, SYS_link
 422:	48cd                	li	a7,19
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42a:	48d1                	li	a7,20
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 432:	48a5                	li	a7,9
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <dup>:
.global dup
dup:
 li a7, SYS_dup
 43a:	48a9                	li	a7,10
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 442:	48ad                	li	a7,11
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 44a:	48b1                	li	a7,12
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <pause>:
.global pause
pause:
 li a7, SYS_pause
 452:	48b5                	li	a7,13
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 45a:	48b9                	li	a7,14
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 462:	48d9                	li	a7,22
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46a:	1101                	addi	sp,sp,-32
 46c:	ec06                	sd	ra,24(sp)
 46e:	e822                	sd	s0,16(sp)
 470:	1000                	addi	s0,sp,32
 472:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 476:	4605                	li	a2,1
 478:	fef40593          	addi	a1,s0,-17
 47c:	f67ff0ef          	jal	3e2 <write>
}
 480:	60e2                	ld	ra,24(sp)
 482:	6442                	ld	s0,16(sp)
 484:	6105                	addi	sp,sp,32
 486:	8082                	ret

0000000000000488 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 488:	715d                	addi	sp,sp,-80
 48a:	e486                	sd	ra,72(sp)
 48c:	e0a2                	sd	s0,64(sp)
 48e:	f84a                	sd	s2,48(sp)
 490:	0880                	addi	s0,sp,80
 492:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 494:	c299                	beqz	a3,49a <printint+0x12>
 496:	0805c363          	bltz	a1,51c <printint+0x94>
  neg = 0;
 49a:	4881                	li	a7,0
 49c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4a0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4a2:	00000517          	auipc	a0,0x0
 4a6:	69650513          	addi	a0,a0,1686 # b38 <digits>
 4aa:	883e                	mv	a6,a5
 4ac:	2785                	addiw	a5,a5,1
 4ae:	02c5f733          	remu	a4,a1,a2
 4b2:	972a                	add	a4,a4,a0
 4b4:	00074703          	lbu	a4,0(a4)
 4b8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4bc:	872e                	mv	a4,a1
 4be:	02c5d5b3          	divu	a1,a1,a2
 4c2:	0685                	addi	a3,a3,1
 4c4:	fec773e3          	bgeu	a4,a2,4aa <printint+0x22>
  if(neg)
 4c8:	00088b63          	beqz	a7,4de <printint+0x56>
    buf[i++] = '-';
 4cc:	fd078793          	addi	a5,a5,-48
 4d0:	97a2                	add	a5,a5,s0
 4d2:	02d00713          	li	a4,45
 4d6:	fee78423          	sb	a4,-24(a5)
 4da:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4de:	02f05a63          	blez	a5,512 <printint+0x8a>
 4e2:	fc26                	sd	s1,56(sp)
 4e4:	f44e                	sd	s3,40(sp)
 4e6:	fb840713          	addi	a4,s0,-72
 4ea:	00f704b3          	add	s1,a4,a5
 4ee:	fff70993          	addi	s3,a4,-1
 4f2:	99be                	add	s3,s3,a5
 4f4:	37fd                	addiw	a5,a5,-1
 4f6:	1782                	slli	a5,a5,0x20
 4f8:	9381                	srli	a5,a5,0x20
 4fa:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4fe:	fff4c583          	lbu	a1,-1(s1)
 502:	854a                	mv	a0,s2
 504:	f67ff0ef          	jal	46a <putc>
  while(--i >= 0)
 508:	14fd                	addi	s1,s1,-1
 50a:	ff349ae3          	bne	s1,s3,4fe <printint+0x76>
 50e:	74e2                	ld	s1,56(sp)
 510:	79a2                	ld	s3,40(sp)
}
 512:	60a6                	ld	ra,72(sp)
 514:	6406                	ld	s0,64(sp)
 516:	7942                	ld	s2,48(sp)
 518:	6161                	addi	sp,sp,80
 51a:	8082                	ret
    x = -xx;
 51c:	40b005b3          	neg	a1,a1
    neg = 1;
 520:	4885                	li	a7,1
    x = -xx;
 522:	bfad                	j	49c <printint+0x14>

0000000000000524 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 524:	711d                	addi	sp,sp,-96
 526:	ec86                	sd	ra,88(sp)
 528:	e8a2                	sd	s0,80(sp)
 52a:	e0ca                	sd	s2,64(sp)
 52c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52e:	0005c903          	lbu	s2,0(a1)
 532:	28090663          	beqz	s2,7be <vprintf+0x29a>
 536:	e4a6                	sd	s1,72(sp)
 538:	fc4e                	sd	s3,56(sp)
 53a:	f852                	sd	s4,48(sp)
 53c:	f456                	sd	s5,40(sp)
 53e:	f05a                	sd	s6,32(sp)
 540:	ec5e                	sd	s7,24(sp)
 542:	e862                	sd	s8,16(sp)
 544:	e466                	sd	s9,8(sp)
 546:	8b2a                	mv	s6,a0
 548:	8a2e                	mv	s4,a1
 54a:	8bb2                	mv	s7,a2
  state = 0;
 54c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 54e:	4481                	li	s1,0
 550:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 552:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 556:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 55a:	06c00c93          	li	s9,108
 55e:	a005                	j	57e <vprintf+0x5a>
        putc(fd, c0);
 560:	85ca                	mv	a1,s2
 562:	855a                	mv	a0,s6
 564:	f07ff0ef          	jal	46a <putc>
 568:	a019                	j	56e <vprintf+0x4a>
    } else if(state == '%'){
 56a:	03598263          	beq	s3,s5,58e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 56e:	2485                	addiw	s1,s1,1
 570:	8726                	mv	a4,s1
 572:	009a07b3          	add	a5,s4,s1
 576:	0007c903          	lbu	s2,0(a5)
 57a:	22090a63          	beqz	s2,7ae <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 57e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 582:	fe0994e3          	bnez	s3,56a <vprintf+0x46>
      if(c0 == '%'){
 586:	fd579de3          	bne	a5,s5,560 <vprintf+0x3c>
        state = '%';
 58a:	89be                	mv	s3,a5
 58c:	b7cd                	j	56e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 58e:	00ea06b3          	add	a3,s4,a4
 592:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 596:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 598:	c681                	beqz	a3,5a0 <vprintf+0x7c>
 59a:	9752                	add	a4,a4,s4
 59c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5a0:	05878363          	beq	a5,s8,5e6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5a4:	05978d63          	beq	a5,s9,5fe <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5a8:	07500713          	li	a4,117
 5ac:	0ee78763          	beq	a5,a4,69a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5b0:	07800713          	li	a4,120
 5b4:	12e78963          	beq	a5,a4,6e6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5b8:	07000713          	li	a4,112
 5bc:	14e78e63          	beq	a5,a4,718 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5c0:	06300713          	li	a4,99
 5c4:	18e78e63          	beq	a5,a4,760 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5c8:	07300713          	li	a4,115
 5cc:	1ae78463          	beq	a5,a4,774 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5d0:	02500713          	li	a4,37
 5d4:	04e79563          	bne	a5,a4,61e <vprintf+0xfa>
        putc(fd, '%');
 5d8:	02500593          	li	a1,37
 5dc:	855a                	mv	a0,s6
 5de:	e8dff0ef          	jal	46a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b769                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4685                	li	a3,1
 5ec:	4629                	li	a2,10
 5ee:	000ba583          	lw	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	e95ff0ef          	jal	488 <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bf8d                	j	56e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5fe:	06400793          	li	a5,100
 602:	02f68963          	beq	a3,a5,634 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 606:	06c00793          	li	a5,108
 60a:	04f68263          	beq	a3,a5,64e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 60e:	07500793          	li	a5,117
 612:	0af68063          	beq	a3,a5,6b2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 616:	07800793          	li	a5,120
 61a:	0ef68263          	beq	a3,a5,6fe <vprintf+0x1da>
        putc(fd, '%');
 61e:	02500593          	li	a1,37
 622:	855a                	mv	a0,s6
 624:	e47ff0ef          	jal	46a <putc>
        putc(fd, c0);
 628:	85ca                	mv	a1,s2
 62a:	855a                	mv	a0,s6
 62c:	e3fff0ef          	jal	46a <putc>
      state = 0;
 630:	4981                	li	s3,0
 632:	bf35                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 634:	008b8913          	addi	s2,s7,8
 638:	4685                	li	a3,1
 63a:	4629                	li	a2,10
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	e47ff0ef          	jal	488 <printint>
        i += 1;
 646:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
        i += 1;
 64c:	b70d                	j	56e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 64e:	06400793          	li	a5,100
 652:	02f60763          	beq	a2,a5,680 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 656:	07500793          	li	a5,117
 65a:	06f60963          	beq	a2,a5,6cc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 65e:	07800793          	li	a5,120
 662:	faf61ee3          	bne	a2,a5,61e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 666:	008b8913          	addi	s2,s7,8
 66a:	4681                	li	a3,0
 66c:	4641                	li	a2,16
 66e:	000bb583          	ld	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	e15ff0ef          	jal	488 <printint>
        i += 2;
 678:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
        i += 2;
 67e:	bdc5                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 680:	008b8913          	addi	s2,s7,8
 684:	4685                	li	a3,1
 686:	4629                	li	a2,10
 688:	000bb583          	ld	a1,0(s7)
 68c:	855a                	mv	a0,s6
 68e:	dfbff0ef          	jal	488 <printint>
        i += 2;
 692:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 694:	8bca                	mv	s7,s2
      state = 0;
 696:	4981                	li	s3,0
        i += 2;
 698:	bdd9                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 69a:	008b8913          	addi	s2,s7,8
 69e:	4681                	li	a3,0
 6a0:	4629                	li	a2,10
 6a2:	000be583          	lwu	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	de1ff0ef          	jal	488 <printint>
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	bd7d                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b2:	008b8913          	addi	s2,s7,8
 6b6:	4681                	li	a3,0
 6b8:	4629                	li	a2,10
 6ba:	000bb583          	ld	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	dc9ff0ef          	jal	488 <printint>
        i += 1;
 6c4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
        i += 1;
 6ca:	b555                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	4681                	li	a3,0
 6d2:	4629                	li	a2,10
 6d4:	000bb583          	ld	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	dafff0ef          	jal	488 <printint>
        i += 2;
 6de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
        i += 2;
 6e4:	b569                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	4681                	li	a3,0
 6ec:	4641                	li	a2,16
 6ee:	000be583          	lwu	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	d95ff0ef          	jal	488 <printint>
 6f8:	8bca                	mv	s7,s2
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	bd8d                	j	56e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6fe:	008b8913          	addi	s2,s7,8
 702:	4681                	li	a3,0
 704:	4641                	li	a2,16
 706:	000bb583          	ld	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	d7dff0ef          	jal	488 <printint>
        i += 1;
 710:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 712:	8bca                	mv	s7,s2
      state = 0;
 714:	4981                	li	s3,0
        i += 1;
 716:	bda1                	j	56e <vprintf+0x4a>
 718:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 71a:	008b8d13          	addi	s10,s7,8
 71e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 722:	03000593          	li	a1,48
 726:	855a                	mv	a0,s6
 728:	d43ff0ef          	jal	46a <putc>
  putc(fd, 'x');
 72c:	07800593          	li	a1,120
 730:	855a                	mv	a0,s6
 732:	d39ff0ef          	jal	46a <putc>
 736:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 738:	00000b97          	auipc	s7,0x0
 73c:	400b8b93          	addi	s7,s7,1024 # b38 <digits>
 740:	03c9d793          	srli	a5,s3,0x3c
 744:	97de                	add	a5,a5,s7
 746:	0007c583          	lbu	a1,0(a5)
 74a:	855a                	mv	a0,s6
 74c:	d1fff0ef          	jal	46a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 750:	0992                	slli	s3,s3,0x4
 752:	397d                	addiw	s2,s2,-1
 754:	fe0916e3          	bnez	s2,740 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 758:	8bea                	mv	s7,s10
      state = 0;
 75a:	4981                	li	s3,0
 75c:	6d02                	ld	s10,0(sp)
 75e:	bd01                	j	56e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 760:	008b8913          	addi	s2,s7,8
 764:	000bc583          	lbu	a1,0(s7)
 768:	855a                	mv	a0,s6
 76a:	d01ff0ef          	jal	46a <putc>
 76e:	8bca                	mv	s7,s2
      state = 0;
 770:	4981                	li	s3,0
 772:	bbf5                	j	56e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 774:	008b8993          	addi	s3,s7,8
 778:	000bb903          	ld	s2,0(s7)
 77c:	00090f63          	beqz	s2,79a <vprintf+0x276>
        for(; *s; s++)
 780:	00094583          	lbu	a1,0(s2)
 784:	c195                	beqz	a1,7a8 <vprintf+0x284>
          putc(fd, *s);
 786:	855a                	mv	a0,s6
 788:	ce3ff0ef          	jal	46a <putc>
        for(; *s; s++)
 78c:	0905                	addi	s2,s2,1
 78e:	00094583          	lbu	a1,0(s2)
 792:	f9f5                	bnez	a1,786 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 794:	8bce                	mv	s7,s3
      state = 0;
 796:	4981                	li	s3,0
 798:	bbd9                	j	56e <vprintf+0x4a>
          s = "(null)";
 79a:	00000917          	auipc	s2,0x0
 79e:	39690913          	addi	s2,s2,918 # b30 <malloc+0x28a>
        for(; *s; s++)
 7a2:	02800593          	li	a1,40
 7a6:	b7c5                	j	786 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7a8:	8bce                	mv	s7,s3
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b3c9                	j	56e <vprintf+0x4a>
 7ae:	64a6                	ld	s1,72(sp)
 7b0:	79e2                	ld	s3,56(sp)
 7b2:	7a42                	ld	s4,48(sp)
 7b4:	7aa2                	ld	s5,40(sp)
 7b6:	7b02                	ld	s6,32(sp)
 7b8:	6be2                	ld	s7,24(sp)
 7ba:	6c42                	ld	s8,16(sp)
 7bc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7be:	60e6                	ld	ra,88(sp)
 7c0:	6446                	ld	s0,80(sp)
 7c2:	6906                	ld	s2,64(sp)
 7c4:	6125                	addi	sp,sp,96
 7c6:	8082                	ret

00000000000007c8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c8:	715d                	addi	sp,sp,-80
 7ca:	ec06                	sd	ra,24(sp)
 7cc:	e822                	sd	s0,16(sp)
 7ce:	1000                	addi	s0,sp,32
 7d0:	e010                	sd	a2,0(s0)
 7d2:	e414                	sd	a3,8(s0)
 7d4:	e818                	sd	a4,16(s0)
 7d6:	ec1c                	sd	a5,24(s0)
 7d8:	03043023          	sd	a6,32(s0)
 7dc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e4:	8622                	mv	a2,s0
 7e6:	d3fff0ef          	jal	524 <vprintf>
}
 7ea:	60e2                	ld	ra,24(sp)
 7ec:	6442                	ld	s0,16(sp)
 7ee:	6161                	addi	sp,sp,80
 7f0:	8082                	ret

00000000000007f2 <printf>:

void
printf(const char *fmt, ...)
{
 7f2:	711d                	addi	sp,sp,-96
 7f4:	ec06                	sd	ra,24(sp)
 7f6:	e822                	sd	s0,16(sp)
 7f8:	1000                	addi	s0,sp,32
 7fa:	e40c                	sd	a1,8(s0)
 7fc:	e810                	sd	a2,16(s0)
 7fe:	ec14                	sd	a3,24(s0)
 800:	f018                	sd	a4,32(s0)
 802:	f41c                	sd	a5,40(s0)
 804:	03043823          	sd	a6,48(s0)
 808:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 80c:	00840613          	addi	a2,s0,8
 810:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 814:	85aa                	mv	a1,a0
 816:	4505                	li	a0,1
 818:	d0dff0ef          	jal	524 <vprintf>
}
 81c:	60e2                	ld	ra,24(sp)
 81e:	6442                	ld	s0,16(sp)
 820:	6125                	addi	sp,sp,96
 822:	8082                	ret

0000000000000824 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 824:	1141                	addi	sp,sp,-16
 826:	e422                	sd	s0,8(sp)
 828:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82e:	00000797          	auipc	a5,0x0
 832:	7d27b783          	ld	a5,2002(a5) # 1000 <freep>
 836:	a02d                	j	860 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 838:	4618                	lw	a4,8(a2)
 83a:	9f2d                	addw	a4,a4,a1
 83c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 840:	6398                	ld	a4,0(a5)
 842:	6310                	ld	a2,0(a4)
 844:	a83d                	j	882 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 846:	ff852703          	lw	a4,-8(a0)
 84a:	9f31                	addw	a4,a4,a2
 84c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 84e:	ff053683          	ld	a3,-16(a0)
 852:	a091                	j	896 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 854:	6398                	ld	a4,0(a5)
 856:	00e7e463          	bltu	a5,a4,85e <free+0x3a>
 85a:	00e6ea63          	bltu	a3,a4,86e <free+0x4a>
{
 85e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 860:	fed7fae3          	bgeu	a5,a3,854 <free+0x30>
 864:	6398                	ld	a4,0(a5)
 866:	00e6e463          	bltu	a3,a4,86e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86a:	fee7eae3          	bltu	a5,a4,85e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 86e:	ff852583          	lw	a1,-8(a0)
 872:	6390                	ld	a2,0(a5)
 874:	02059813          	slli	a6,a1,0x20
 878:	01c85713          	srli	a4,a6,0x1c
 87c:	9736                	add	a4,a4,a3
 87e:	fae60de3          	beq	a2,a4,838 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 882:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 886:	4790                	lw	a2,8(a5)
 888:	02061593          	slli	a1,a2,0x20
 88c:	01c5d713          	srli	a4,a1,0x1c
 890:	973e                	add	a4,a4,a5
 892:	fae68ae3          	beq	a3,a4,846 <free+0x22>
    p->s.ptr = bp->s.ptr;
 896:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 898:	00000717          	auipc	a4,0x0
 89c:	76f73423          	sd	a5,1896(a4) # 1000 <freep>
}
 8a0:	6422                	ld	s0,8(sp)
 8a2:	0141                	addi	sp,sp,16
 8a4:	8082                	ret

00000000000008a6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a6:	7139                	addi	sp,sp,-64
 8a8:	fc06                	sd	ra,56(sp)
 8aa:	f822                	sd	s0,48(sp)
 8ac:	f426                	sd	s1,40(sp)
 8ae:	ec4e                	sd	s3,24(sp)
 8b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b2:	02051493          	slli	s1,a0,0x20
 8b6:	9081                	srli	s1,s1,0x20
 8b8:	04bd                	addi	s1,s1,15
 8ba:	8091                	srli	s1,s1,0x4
 8bc:	0014899b          	addiw	s3,s1,1
 8c0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c2:	00000517          	auipc	a0,0x0
 8c6:	73e53503          	ld	a0,1854(a0) # 1000 <freep>
 8ca:	c915                	beqz	a0,8fe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ce:	4798                	lw	a4,8(a5)
 8d0:	08977a63          	bgeu	a4,s1,964 <malloc+0xbe>
 8d4:	f04a                	sd	s2,32(sp)
 8d6:	e852                	sd	s4,16(sp)
 8d8:	e456                	sd	s5,8(sp)
 8da:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8dc:	8a4e                	mv	s4,s3
 8de:	0009871b          	sext.w	a4,s3
 8e2:	6685                	lui	a3,0x1
 8e4:	00d77363          	bgeu	a4,a3,8ea <malloc+0x44>
 8e8:	6a05                	lui	s4,0x1
 8ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f2:	00000917          	auipc	s2,0x0
 8f6:	70e90913          	addi	s2,s2,1806 # 1000 <freep>
  if(p == SBRK_ERROR)
 8fa:	5afd                	li	s5,-1
 8fc:	a081                	j	93c <malloc+0x96>
 8fe:	f04a                	sd	s2,32(sp)
 900:	e852                	sd	s4,16(sp)
 902:	e456                	sd	s5,8(sp)
 904:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 906:	00000797          	auipc	a5,0x0
 90a:	70a78793          	addi	a5,a5,1802 # 1010 <base>
 90e:	00000717          	auipc	a4,0x0
 912:	6ef73923          	sd	a5,1778(a4) # 1000 <freep>
 916:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 918:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 91c:	b7c1                	j	8dc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 91e:	6398                	ld	a4,0(a5)
 920:	e118                	sd	a4,0(a0)
 922:	a8a9                	j	97c <malloc+0xd6>
  hp->s.size = nu;
 924:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 928:	0541                	addi	a0,a0,16
 92a:	efbff0ef          	jal	824 <free>
  return freep;
 92e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 932:	c12d                	beqz	a0,994 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 934:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 936:	4798                	lw	a4,8(a5)
 938:	02977263          	bgeu	a4,s1,95c <malloc+0xb6>
    if(p == freep)
 93c:	00093703          	ld	a4,0(s2)
 940:	853e                	mv	a0,a5
 942:	fef719e3          	bne	a4,a5,934 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 946:	8552                	mv	a0,s4
 948:	a47ff0ef          	jal	38e <sbrk>
  if(p == SBRK_ERROR)
 94c:	fd551ce3          	bne	a0,s5,924 <malloc+0x7e>
        return 0;
 950:	4501                	li	a0,0
 952:	7902                	ld	s2,32(sp)
 954:	6a42                	ld	s4,16(sp)
 956:	6aa2                	ld	s5,8(sp)
 958:	6b02                	ld	s6,0(sp)
 95a:	a03d                	j	988 <malloc+0xe2>
 95c:	7902                	ld	s2,32(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 964:	fae48de3          	beq	s1,a4,91e <malloc+0x78>
        p->s.size -= nunits;
 968:	4137073b          	subw	a4,a4,s3
 96c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 96e:	02071693          	slli	a3,a4,0x20
 972:	01c6d713          	srli	a4,a3,0x1c
 976:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 978:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 97c:	00000717          	auipc	a4,0x0
 980:	68a73223          	sd	a0,1668(a4) # 1000 <freep>
      return (void*)(p + 1);
 984:	01078513          	addi	a0,a5,16
  }
}
 988:	70e2                	ld	ra,56(sp)
 98a:	7442                	ld	s0,48(sp)
 98c:	74a2                	ld	s1,40(sp)
 98e:	69e2                	ld	s3,24(sp)
 990:	6121                	addi	sp,sp,64
 992:	8082                	ret
 994:	7902                	ld	s2,32(sp)
 996:	6a42                	ld	s4,16(sp)
 998:	6aa2                	ld	s5,8(sp)
 99a:	6b02                	ld	s6,0(sp)
 99c:	b7f5                	j	988 <malloc+0xe2>
