
user/_test_swap:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define PGSIZE 4096
#define N 9000
#define MINP 1024

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
  printf("[test_swap] start\n");
  18:	00001517          	auipc	a0,0x1
  1c:	9c850513          	addi	a0,a0,-1592 # 9e0 <malloc+0xfa>
  20:	013000ef          	jal	832 <printf>
  int target = N;
  24:	6489                	lui	s1,0x2
  26:	32848493          	addi	s1,s1,808 # 2328 <base+0x318>
  char *base = (char*)-1;
  while (target >= MINP) {
    printf("[test_swap] Trying to allocate %d pages\n", target);
  2a:	00001a17          	auipc	s4,0x1
  2e:	9cea0a13          	addi	s4,s4,-1586 # 9f8 <malloc+0x112>
  base = sbrklazy(target * PGSIZE);
    if (base != (char*)-1) break;
  32:	597d                	li	s2,-1
  while (target >= MINP) {
  34:	6a85                	lui	s5,0x1
    printf("[test_swap] Trying to allocate %d pages\n", target);
  36:	85a6                	mv	a1,s1
  38:	8552                	mv	a0,s4
  3a:	7f8000ef          	jal	832 <printf>
  base = sbrklazy(target * PGSIZE);
  3e:	00c4951b          	slliw	a0,s1,0xc
  42:	3a2000ef          	jal	3e4 <sbrklazy>
  46:	89aa                	mv	s3,a0
    if (base != (char*)-1) break;
  48:	0f251a63          	bne	a0,s2,13c <main+0x13c>
    target = (target * 3) / 4;
  4c:	0014979b          	slliw	a5,s1,0x1
  50:	9fa5                	addw	a5,a5,s1
  52:	0007871b          	sext.w	a4,a5
  56:	41f7d49b          	sraiw	s1,a5,0x1f
  5a:	01e4d49b          	srliw	s1,s1,0x1e
  5e:	9cbd                	addw	s1,s1,a5
  60:	4024d49b          	sraiw	s1,s1,0x2
  while (target >= MINP) {
  64:	fd5759e3          	bge	a4,s5,36 <main+0x36>
  }
  if (base == (char*)-1) {
    printf("[test_swap] sbrk failed for all attempts\nTEST FAILED\n");
  68:	00001517          	auipc	a0,0x1
  6c:	b2050513          	addi	a0,a0,-1248 # b88 <malloc+0x2a2>
  70:	7c2000ef          	jal	832 <printf>
    exit(1);
  74:	4505                	li	a0,1
  76:	38c000ef          	jal	402 <exit>
  }
  printf("[test_swap] Allocated %d pages at %p\n", target, base);

  // Write a unique pattern on each page to check persistence across swapout/in
  printf("[test_swap] Writing pattern to each page\n");
  for (int i = 0; i < target; i++) {
  7a:	2905                	addiw	s2,s2,1
  7c:	9ada                	add	s5,s5,s6
  7e:	00990e63          	beq	s2,s1,9a <main+0x9a>
    base[i*PGSIZE] = (char)(i & 0x7f);
  82:	07f97793          	andi	a5,s2,127
  86:	00fa8023          	sb	a5,0(s5) # 1000 <digits+0x438>
    if ((i % 1000) == 0) printf("  wrote page %d\n", i);
  8a:	037967bb          	remw	a5,s2,s7
  8e:	f7f5                	bnez	a5,7a <main+0x7a>
  90:	85ca                	mv	a1,s2
  92:	8562                	mv	a0,s8
  94:	79e000ef          	jal	832 <printf>
  98:	b7cd                	j	7a <main+0x7a>
  }

  // Access a later range to push earlier pages out
  printf("[test_swap] Accessing high pages to induce swapout of early pages\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	9a650513          	addi	a0,a0,-1626 # a40 <malloc+0x15a>
  a2:	790000ef          	jal	832 <printf>
  volatile int sump = 0;
  a6:	fa042623          	sw	zero,-84(s0)
  for (int i = target-1; i >= 0; i -= 97) {
  aa:	34fd                	addiw	s1,s1,-1
  ac:	0004871b          	sext.w	a4,s1
  b0:	00c4949b          	slliw	s1,s1,0xc
  b4:	94ce                	add	s1,s1,s3
  b6:	fff9f637          	lui	a2,0xfff9f
    sump += base[i*PGSIZE];
  ba:	fac42683          	lw	a3,-84(s0)
  be:	0004c783          	lbu	a5,0(s1)
  c2:	9fb5                	addw	a5,a5,a3
  c4:	faf42623          	sw	a5,-84(s0)
  for (int i = target-1; i >= 0; i -= 97) {
  c8:	f9f7071b          	addiw	a4,a4,-97
  cc:	94b2                	add	s1,s1,a2
  ce:	fe0756e3          	bgez	a4,ba <main+0xba>
  }

  // Re-access early pages, expect SWAPIN logs and correct data
  printf("[test_swap] Verifying first 256 pages after pressure\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	9b650513          	addi	a0,a0,-1610 # a88 <malloc+0x1a2>
  da:	758000ef          	jal	832 <printf>
  for (int i = 0; i < 256 && i < target; i++) {
  de:	4581                	li	a1,0
  e0:	10000793          	li	a5,256
  e4:	6705                	lui	a4,0x1
  e6:	a00d                	j	108 <main+0x108>
    char v = base[i*PGSIZE];
    if (v != (char)(i & 0x7f)) {
      printf("[test_swap] mismatch at page %d: got %d expected %d\n", i, v, (char)(i & 0x7f));
  e8:	00001517          	auipc	a0,0x1
  ec:	9d850513          	addi	a0,a0,-1576 # ac0 <malloc+0x1da>
  f0:	742000ef          	jal	832 <printf>
      printf("TEST FAILED\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	a0450513          	addi	a0,a0,-1532 # af8 <malloc+0x212>
  fc:	736000ef          	jal	832 <printf>
      exit(1);
 100:	4505                	li	a0,1
 102:	300000ef          	jal	402 <exit>
  for (int i = 0; i < 256 && i < target; i++) {
 106:	9a3a                	add	s4,s4,a4
    if (v != (char)(i & 0x7f)) {
 108:	000a4603          	lbu	a2,0(s4)
 10c:	07f5f693          	andi	a3,a1,127
 110:	fcd61ce3          	bne	a2,a3,e8 <main+0xe8>
  for (int i = 0; i < 256 && i < target; i++) {
 114:	2585                	addiw	a1,a1,1
 116:	fef598e3          	bne	a1,a5,106 <main+0x106>
    }
  }

  printf("[test_swap] sump=%d\n", sump);
 11a:	fac42583          	lw	a1,-84(s0)
 11e:	00001517          	auipc	a0,0x1
 122:	9ea50513          	addi	a0,a0,-1558 # b08 <malloc+0x222>
 126:	70c000ef          	jal	832 <printf>
  printf("TEST PASSED\n");
 12a:	00001517          	auipc	a0,0x1
 12e:	9f650513          	addi	a0,a0,-1546 # b20 <malloc+0x23a>
 132:	700000ef          	jal	832 <printf>
  exit(0);
 136:	4501                	li	a0,0
 138:	2ca000ef          	jal	402 <exit>
  printf("[test_swap] Allocated %d pages at %p\n", target, base);
 13c:	862a                	mv	a2,a0
 13e:	85a6                	mv	a1,s1
 140:	00001517          	auipc	a0,0x1
 144:	9f050513          	addi	a0,a0,-1552 # b30 <malloc+0x24a>
 148:	6ea000ef          	jal	832 <printf>
  printf("[test_swap] Writing pattern to each page\n");
 14c:	00001517          	auipc	a0,0x1
 150:	a0c50513          	addi	a0,a0,-1524 # b58 <malloc+0x272>
 154:	6de000ef          	jal	832 <printf>
  for (int i = 0; i < target; i++) {
 158:	8a4e                	mv	s4,s3
  printf("[test_swap] Writing pattern to each page\n");
 15a:	8ace                	mv	s5,s3
  for (int i = 0; i < target; i++) {
 15c:	4901                	li	s2,0
    if ((i % 1000) == 0) printf("  wrote page %d\n", i);
 15e:	3e800b93          	li	s7,1000
 162:	00001c17          	auipc	s8,0x1
 166:	8c6c0c13          	addi	s8,s8,-1850 # a28 <malloc+0x142>
  for (int i = 0; i < target; i++) {
 16a:	6b05                	lui	s6,0x1
 16c:	bf19                	j	82 <main+0x82>

000000000000016e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e406                	sd	ra,8(sp)
 172:	e022                	sd	s0,0(sp)
 174:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 176:	e8bff0ef          	jal	0 <main>
  exit(r);
 17a:	288000ef          	jal	402 <exit>

000000000000017e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 184:	87aa                	mv	a5,a0
 186:	0585                	addi	a1,a1,1
 188:	0785                	addi	a5,a5,1
 18a:	fff5c703          	lbu	a4,-1(a1)
 18e:	fee78fa3          	sb	a4,-1(a5)
 192:	fb75                	bnez	a4,186 <strcpy+0x8>
    ;
  return os;
}
 194:	6422                	ld	s0,8(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret

000000000000019a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	cb91                	beqz	a5,1b8 <strcmp+0x1e>
 1a6:	0005c703          	lbu	a4,0(a1)
 1aa:	00f71763          	bne	a4,a5,1b8 <strcmp+0x1e>
    p++, q++;
 1ae:	0505                	addi	a0,a0,1
 1b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	fbe5                	bnez	a5,1a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1b8:	0005c503          	lbu	a0,0(a1)
}
 1bc:	40a7853b          	subw	a0,a5,a0
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret

00000000000001c6 <strlen>:

uint
strlen(const char *s)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	cf91                	beqz	a5,1ec <strlen+0x26>
 1d2:	0505                	addi	a0,a0,1
 1d4:	87aa                	mv	a5,a0
 1d6:	86be                	mv	a3,a5
 1d8:	0785                	addi	a5,a5,1
 1da:	fff7c703          	lbu	a4,-1(a5)
 1de:	ff65                	bnez	a4,1d6 <strlen+0x10>
 1e0:	40a6853b          	subw	a0,a3,a0
 1e4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  for(n = 0; s[n]; n++)
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <strlen+0x20>

00000000000001f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f6:	ca19                	beqz	a2,20c <memset+0x1c>
 1f8:	87aa                	mv	a5,a0
 1fa:	1602                	slli	a2,a2,0x20
 1fc:	9201                	srli	a2,a2,0x20
 1fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 202:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 206:	0785                	addi	a5,a5,1
 208:	fee79de3          	bne	a5,a4,202 <memset+0x12>
  }
  return dst;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret

0000000000000212 <strchr>:

char*
strchr(const char *s, char c)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  for(; *s; s++)
 218:	00054783          	lbu	a5,0(a0)
 21c:	cb99                	beqz	a5,232 <strchr+0x20>
    if(*s == c)
 21e:	00f58763          	beq	a1,a5,22c <strchr+0x1a>
  for(; *s; s++)
 222:	0505                	addi	a0,a0,1
 224:	00054783          	lbu	a5,0(a0)
 228:	fbfd                	bnez	a5,21e <strchr+0xc>
      return (char*)s;
  return 0;
 22a:	4501                	li	a0,0
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  return 0;
 232:	4501                	li	a0,0
 234:	bfe5                	j	22c <strchr+0x1a>

0000000000000236 <gets>:

char*
gets(char *buf, int max)
{
 236:	711d                	addi	sp,sp,-96
 238:	ec86                	sd	ra,88(sp)
 23a:	e8a2                	sd	s0,80(sp)
 23c:	e4a6                	sd	s1,72(sp)
 23e:	e0ca                	sd	s2,64(sp)
 240:	fc4e                	sd	s3,56(sp)
 242:	f852                	sd	s4,48(sp)
 244:	f456                	sd	s5,40(sp)
 246:	f05a                	sd	s6,32(sp)
 248:	ec5e                	sd	s7,24(sp)
 24a:	1080                	addi	s0,sp,96
 24c:	8baa                	mv	s7,a0
 24e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 250:	892a                	mv	s2,a0
 252:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 254:	4aa9                	li	s5,10
 256:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 258:	89a6                	mv	s3,s1
 25a:	2485                	addiw	s1,s1,1
 25c:	0344d663          	bge	s1,s4,288 <gets+0x52>
    cc = read(0, &c, 1);
 260:	4605                	li	a2,1
 262:	faf40593          	addi	a1,s0,-81
 266:	4501                	li	a0,0
 268:	1b2000ef          	jal	41a <read>
    if(cc < 1)
 26c:	00a05e63          	blez	a0,288 <gets+0x52>
    buf[i++] = c;
 270:	faf44783          	lbu	a5,-81(s0)
 274:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 278:	01578763          	beq	a5,s5,286 <gets+0x50>
 27c:	0905                	addi	s2,s2,1
 27e:	fd679de3          	bne	a5,s6,258 <gets+0x22>
    buf[i++] = c;
 282:	89a6                	mv	s3,s1
 284:	a011                	j	288 <gets+0x52>
 286:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 288:	99de                	add	s3,s3,s7
 28a:	00098023          	sb	zero,0(s3)
  return buf;
}
 28e:	855e                	mv	a0,s7
 290:	60e6                	ld	ra,88(sp)
 292:	6446                	ld	s0,80(sp)
 294:	64a6                	ld	s1,72(sp)
 296:	6906                	ld	s2,64(sp)
 298:	79e2                	ld	s3,56(sp)
 29a:	7a42                	ld	s4,48(sp)
 29c:	7aa2                	ld	s5,40(sp)
 29e:	7b02                	ld	s6,32(sp)
 2a0:	6be2                	ld	s7,24(sp)
 2a2:	6125                	addi	sp,sp,96
 2a4:	8082                	ret

00000000000002a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a6:	1101                	addi	sp,sp,-32
 2a8:	ec06                	sd	ra,24(sp)
 2aa:	e822                	sd	s0,16(sp)
 2ac:	e04a                	sd	s2,0(sp)
 2ae:	1000                	addi	s0,sp,32
 2b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b2:	4581                	li	a1,0
 2b4:	18e000ef          	jal	442 <open>
  if(fd < 0)
 2b8:	02054263          	bltz	a0,2dc <stat+0x36>
 2bc:	e426                	sd	s1,8(sp)
 2be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c0:	85ca                	mv	a1,s2
 2c2:	198000ef          	jal	45a <fstat>
 2c6:	892a                	mv	s2,a0
  close(fd);
 2c8:	8526                	mv	a0,s1
 2ca:	160000ef          	jal	42a <close>
  return r;
 2ce:	64a2                	ld	s1,8(sp)
}
 2d0:	854a                	mv	a0,s2
 2d2:	60e2                	ld	ra,24(sp)
 2d4:	6442                	ld	s0,16(sp)
 2d6:	6902                	ld	s2,0(sp)
 2d8:	6105                	addi	sp,sp,32
 2da:	8082                	ret
    return -1;
 2dc:	597d                	li	s2,-1
 2de:	bfcd                	j	2d0 <stat+0x2a>

00000000000002e0 <atoi>:

int
atoi(const char *s)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e6:	00054683          	lbu	a3,0(a0)
 2ea:	fd06879b          	addiw	a5,a3,-48
 2ee:	0ff7f793          	zext.b	a5,a5
 2f2:	4625                	li	a2,9
 2f4:	02f66863          	bltu	a2,a5,324 <atoi+0x44>
 2f8:	872a                	mv	a4,a0
  n = 0;
 2fa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2fc:	0705                	addi	a4,a4,1 # 1001 <digits+0x439>
 2fe:	0025179b          	slliw	a5,a0,0x2
 302:	9fa9                	addw	a5,a5,a0
 304:	0017979b          	slliw	a5,a5,0x1
 308:	9fb5                	addw	a5,a5,a3
 30a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30e:	00074683          	lbu	a3,0(a4)
 312:	fd06879b          	addiw	a5,a3,-48
 316:	0ff7f793          	zext.b	a5,a5
 31a:	fef671e3          	bgeu	a2,a5,2fc <atoi+0x1c>
  return n;
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
  n = 0;
 324:	4501                	li	a0,0
 326:	bfe5                	j	31e <atoi+0x3e>

0000000000000328 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 32e:	02b57463          	bgeu	a0,a1,356 <memmove+0x2e>
    while(n-- > 0)
 332:	00c05f63          	blez	a2,350 <memmove+0x28>
 336:	1602                	slli	a2,a2,0x20
 338:	9201                	srli	a2,a2,0x20
 33a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 33e:	872a                	mv	a4,a0
      *dst++ = *src++;
 340:	0585                	addi	a1,a1,1
 342:	0705                	addi	a4,a4,1
 344:	fff5c683          	lbu	a3,-1(a1)
 348:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34c:	fef71ae3          	bne	a4,a5,340 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
    dst += n;
 356:	00c50733          	add	a4,a0,a2
    src += n;
 35a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35c:	fec05ae3          	blez	a2,350 <memmove+0x28>
 360:	fff6079b          	addiw	a5,a2,-1 # fffffffffff9efff <base+0xfffffffffff9cfef>
 364:	1782                	slli	a5,a5,0x20
 366:	9381                	srli	a5,a5,0x20
 368:	fff7c793          	not	a5,a5
 36c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36e:	15fd                	addi	a1,a1,-1
 370:	177d                	addi	a4,a4,-1
 372:	0005c683          	lbu	a3,0(a1)
 376:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37a:	fee79ae3          	bne	a5,a4,36e <memmove+0x46>
 37e:	bfc9                	j	350 <memmove+0x28>

0000000000000380 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 386:	ca05                	beqz	a2,3b6 <memcmp+0x36>
 388:	fff6069b          	addiw	a3,a2,-1
 38c:	1682                	slli	a3,a3,0x20
 38e:	9281                	srli	a3,a3,0x20
 390:	0685                	addi	a3,a3,1
 392:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 394:	00054783          	lbu	a5,0(a0)
 398:	0005c703          	lbu	a4,0(a1)
 39c:	00e79863          	bne	a5,a4,3ac <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a0:	0505                	addi	a0,a0,1
    p2++;
 3a2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a4:	fed518e3          	bne	a0,a3,394 <memcmp+0x14>
  }
  return 0;
 3a8:	4501                	li	a0,0
 3aa:	a019                	j	3b0 <memcmp+0x30>
      return *p1 - *p2;
 3ac:	40e7853b          	subw	a0,a5,a4
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	bfe5                	j	3b0 <memcmp+0x30>

00000000000003ba <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c2:	f67ff0ef          	jal	328 <memmove>
}
 3c6:	60a2                	ld	ra,8(sp)
 3c8:	6402                	ld	s0,0(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret

00000000000003ce <sbrk>:

char *
sbrk(int n) {
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e406                	sd	ra,8(sp)
 3d2:	e022                	sd	s0,0(sp)
 3d4:	0800                	addi	s0,sp,16
  // Eager allocation by default to preserve original xv6 semantics
  // relied upon by many user programs and tests (e.g., countfree).
  return sys_sbrk(n, SBRK_EAGER);
 3d6:	4585                	li	a1,1
 3d8:	0b2000ef          	jal	48a <sys_sbrk>
}
 3dc:	60a2                	ld	ra,8(sp)
 3de:	6402                	ld	s0,0(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret

00000000000003e4 <sbrklazy>:

char *
sbrklazy(int n) {
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e406                	sd	ra,8(sp)
 3e8:	e022                	sd	s0,0(sp)
 3ea:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3ec:	4589                	li	a1,2
 3ee:	09c000ef          	jal	48a <sys_sbrk>
}
 3f2:	60a2                	ld	ra,8(sp)
 3f4:	6402                	ld	s0,0(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret

00000000000003fa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fa:	4885                	li	a7,1
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <exit>:
.global exit
exit:
 li a7, SYS_exit
 402:	4889                	li	a7,2
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <wait>:
.global wait
wait:
 li a7, SYS_wait
 40a:	488d                	li	a7,3
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 412:	4891                	li	a7,4
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <read>:
.global read
read:
 li a7, SYS_read
 41a:	4895                	li	a7,5
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <write>:
.global write
write:
 li a7, SYS_write
 422:	48c1                	li	a7,16
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <close>:
.global close
close:
 li a7, SYS_close
 42a:	48d5                	li	a7,21
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <kill>:
.global kill
kill:
 li a7, SYS_kill
 432:	4899                	li	a7,6
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <exec>:
.global exec
exec:
 li a7, SYS_exec
 43a:	489d                	li	a7,7
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <open>:
.global open
open:
 li a7, SYS_open
 442:	48bd                	li	a7,15
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44a:	48c5                	li	a7,17
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 452:	48c9                	li	a7,18
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45a:	48a1                	li	a7,8
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <link>:
.global link
link:
 li a7, SYS_link
 462:	48cd                	li	a7,19
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46a:	48d1                	li	a7,20
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 472:	48a5                	li	a7,9
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <dup>:
.global dup
dup:
 li a7, SYS_dup
 47a:	48a9                	li	a7,10
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 482:	48ad                	li	a7,11
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 48a:	48b1                	li	a7,12
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <pause>:
.global pause
pause:
 li a7, SYS_pause
 492:	48b5                	li	a7,13
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49a:	48b9                	li	a7,14
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 4a2:	48d9                	li	a7,22
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4aa:	1101                	addi	sp,sp,-32
 4ac:	ec06                	sd	ra,24(sp)
 4ae:	e822                	sd	s0,16(sp)
 4b0:	1000                	addi	s0,sp,32
 4b2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b6:	4605                	li	a2,1
 4b8:	fef40593          	addi	a1,s0,-17
 4bc:	f67ff0ef          	jal	422 <write>
}
 4c0:	60e2                	ld	ra,24(sp)
 4c2:	6442                	ld	s0,16(sp)
 4c4:	6105                	addi	sp,sp,32
 4c6:	8082                	ret

00000000000004c8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4c8:	715d                	addi	sp,sp,-80
 4ca:	e486                	sd	ra,72(sp)
 4cc:	e0a2                	sd	s0,64(sp)
 4ce:	f84a                	sd	s2,48(sp)
 4d0:	0880                	addi	s0,sp,80
 4d2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4d4:	c299                	beqz	a3,4da <printint+0x12>
 4d6:	0805c363          	bltz	a1,55c <printint+0x94>
  neg = 0;
 4da:	4881                	li	a7,0
 4dc:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4e0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4e2:	00000517          	auipc	a0,0x0
 4e6:	6e650513          	addi	a0,a0,1766 # bc8 <digits>
 4ea:	883e                	mv	a6,a5
 4ec:	2785                	addiw	a5,a5,1
 4ee:	02c5f733          	remu	a4,a1,a2
 4f2:	972a                	add	a4,a4,a0
 4f4:	00074703          	lbu	a4,0(a4)
 4f8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4fc:	872e                	mv	a4,a1
 4fe:	02c5d5b3          	divu	a1,a1,a2
 502:	0685                	addi	a3,a3,1
 504:	fec773e3          	bgeu	a4,a2,4ea <printint+0x22>
  if(neg)
 508:	00088b63          	beqz	a7,51e <printint+0x56>
    buf[i++] = '-';
 50c:	fd078793          	addi	a5,a5,-48
 510:	97a2                	add	a5,a5,s0
 512:	02d00713          	li	a4,45
 516:	fee78423          	sb	a4,-24(a5)
 51a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 51e:	02f05a63          	blez	a5,552 <printint+0x8a>
 522:	fc26                	sd	s1,56(sp)
 524:	f44e                	sd	s3,40(sp)
 526:	fb840713          	addi	a4,s0,-72
 52a:	00f704b3          	add	s1,a4,a5
 52e:	fff70993          	addi	s3,a4,-1
 532:	99be                	add	s3,s3,a5
 534:	37fd                	addiw	a5,a5,-1
 536:	1782                	slli	a5,a5,0x20
 538:	9381                	srli	a5,a5,0x20
 53a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 53e:	fff4c583          	lbu	a1,-1(s1)
 542:	854a                	mv	a0,s2
 544:	f67ff0ef          	jal	4aa <putc>
  while(--i >= 0)
 548:	14fd                	addi	s1,s1,-1
 54a:	ff349ae3          	bne	s1,s3,53e <printint+0x76>
 54e:	74e2                	ld	s1,56(sp)
 550:	79a2                	ld	s3,40(sp)
}
 552:	60a6                	ld	ra,72(sp)
 554:	6406                	ld	s0,64(sp)
 556:	7942                	ld	s2,48(sp)
 558:	6161                	addi	sp,sp,80
 55a:	8082                	ret
    x = -xx;
 55c:	40b005b3          	neg	a1,a1
    neg = 1;
 560:	4885                	li	a7,1
    x = -xx;
 562:	bfad                	j	4dc <printint+0x14>

0000000000000564 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 564:	711d                	addi	sp,sp,-96
 566:	ec86                	sd	ra,88(sp)
 568:	e8a2                	sd	s0,80(sp)
 56a:	e0ca                	sd	s2,64(sp)
 56c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56e:	0005c903          	lbu	s2,0(a1)
 572:	28090663          	beqz	s2,7fe <vprintf+0x29a>
 576:	e4a6                	sd	s1,72(sp)
 578:	fc4e                	sd	s3,56(sp)
 57a:	f852                	sd	s4,48(sp)
 57c:	f456                	sd	s5,40(sp)
 57e:	f05a                	sd	s6,32(sp)
 580:	ec5e                	sd	s7,24(sp)
 582:	e862                	sd	s8,16(sp)
 584:	e466                	sd	s9,8(sp)
 586:	8b2a                	mv	s6,a0
 588:	8a2e                	mv	s4,a1
 58a:	8bb2                	mv	s7,a2
  state = 0;
 58c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 58e:	4481                	li	s1,0
 590:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 592:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 596:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 59a:	06c00c93          	li	s9,108
 59e:	a005                	j	5be <vprintf+0x5a>
        putc(fd, c0);
 5a0:	85ca                	mv	a1,s2
 5a2:	855a                	mv	a0,s6
 5a4:	f07ff0ef          	jal	4aa <putc>
 5a8:	a019                	j	5ae <vprintf+0x4a>
    } else if(state == '%'){
 5aa:	03598263          	beq	s3,s5,5ce <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5ae:	2485                	addiw	s1,s1,1
 5b0:	8726                	mv	a4,s1
 5b2:	009a07b3          	add	a5,s4,s1
 5b6:	0007c903          	lbu	s2,0(a5)
 5ba:	22090a63          	beqz	s2,7ee <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5be:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5c2:	fe0994e3          	bnez	s3,5aa <vprintf+0x46>
      if(c0 == '%'){
 5c6:	fd579de3          	bne	a5,s5,5a0 <vprintf+0x3c>
        state = '%';
 5ca:	89be                	mv	s3,a5
 5cc:	b7cd                	j	5ae <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5ce:	00ea06b3          	add	a3,s4,a4
 5d2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5d6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5d8:	c681                	beqz	a3,5e0 <vprintf+0x7c>
 5da:	9752                	add	a4,a4,s4
 5dc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5e0:	05878363          	beq	a5,s8,626 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5e4:	05978d63          	beq	a5,s9,63e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5e8:	07500713          	li	a4,117
 5ec:	0ee78763          	beq	a5,a4,6da <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5f0:	07800713          	li	a4,120
 5f4:	12e78963          	beq	a5,a4,726 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5f8:	07000713          	li	a4,112
 5fc:	14e78e63          	beq	a5,a4,758 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 600:	06300713          	li	a4,99
 604:	18e78e63          	beq	a5,a4,7a0 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 608:	07300713          	li	a4,115
 60c:	1ae78463          	beq	a5,a4,7b4 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 610:	02500713          	li	a4,37
 614:	04e79563          	bne	a5,a4,65e <vprintf+0xfa>
        putc(fd, '%');
 618:	02500593          	li	a1,37
 61c:	855a                	mv	a0,s6
 61e:	e8dff0ef          	jal	4aa <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 622:	4981                	li	s3,0
 624:	b769                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 626:	008b8913          	addi	s2,s7,8
 62a:	4685                	li	a3,1
 62c:	4629                	li	a2,10
 62e:	000ba583          	lw	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	e95ff0ef          	jal	4c8 <printint>
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bf8d                	j	5ae <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 63e:	06400793          	li	a5,100
 642:	02f68963          	beq	a3,a5,674 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 646:	06c00793          	li	a5,108
 64a:	04f68263          	beq	a3,a5,68e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 64e:	07500793          	li	a5,117
 652:	0af68063          	beq	a3,a5,6f2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 656:	07800793          	li	a5,120
 65a:	0ef68263          	beq	a3,a5,73e <vprintf+0x1da>
        putc(fd, '%');
 65e:	02500593          	li	a1,37
 662:	855a                	mv	a0,s6
 664:	e47ff0ef          	jal	4aa <putc>
        putc(fd, c0);
 668:	85ca                	mv	a1,s2
 66a:	855a                	mv	a0,s6
 66c:	e3fff0ef          	jal	4aa <putc>
      state = 0;
 670:	4981                	li	s3,0
 672:	bf35                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 674:	008b8913          	addi	s2,s7,8
 678:	4685                	li	a3,1
 67a:	4629                	li	a2,10
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	e47ff0ef          	jal	4c8 <printint>
        i += 1;
 686:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
        i += 1;
 68c:	b70d                	j	5ae <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 68e:	06400793          	li	a5,100
 692:	02f60763          	beq	a2,a5,6c0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 696:	07500793          	li	a5,117
 69a:	06f60963          	beq	a2,a5,70c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 69e:	07800793          	li	a5,120
 6a2:	faf61ee3          	bne	a2,a5,65e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4641                	li	a2,16
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	e15ff0ef          	jal	4c8 <printint>
        i += 2;
 6b8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 2;
 6be:	bdc5                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4685                	li	a3,1
 6c6:	4629                	li	a2,10
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	dfbff0ef          	jal	4c8 <printint>
        i += 2;
 6d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	bdd9                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000be583          	lwu	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	de1ff0ef          	jal	4c8 <printint>
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bd7d                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	008b8913          	addi	s2,s7,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000bb583          	ld	a1,0(s7)
 6fe:	855a                	mv	a0,s6
 700:	dc9ff0ef          	jal	4c8 <printint>
        i += 1;
 704:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
        i += 1;
 70a:	b555                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4629                	li	a2,10
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	dafff0ef          	jal	4c8 <printint>
        i += 2;
 71e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 2;
 724:	b569                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4641                	li	a2,16
 72e:	000be583          	lwu	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	d95ff0ef          	jal	4c8 <printint>
 738:	8bca                	mv	s7,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bd8d                	j	5ae <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 73e:	008b8913          	addi	s2,s7,8
 742:	4681                	li	a3,0
 744:	4641                	li	a2,16
 746:	000bb583          	ld	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	d7dff0ef          	jal	4c8 <printint>
        i += 1;
 750:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
        i += 1;
 756:	bda1                	j	5ae <vprintf+0x4a>
 758:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 75a:	008b8d13          	addi	s10,s7,8
 75e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 762:	03000593          	li	a1,48
 766:	855a                	mv	a0,s6
 768:	d43ff0ef          	jal	4aa <putc>
  putc(fd, 'x');
 76c:	07800593          	li	a1,120
 770:	855a                	mv	a0,s6
 772:	d39ff0ef          	jal	4aa <putc>
 776:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 778:	00000b97          	auipc	s7,0x0
 77c:	450b8b93          	addi	s7,s7,1104 # bc8 <digits>
 780:	03c9d793          	srli	a5,s3,0x3c
 784:	97de                	add	a5,a5,s7
 786:	0007c583          	lbu	a1,0(a5)
 78a:	855a                	mv	a0,s6
 78c:	d1fff0ef          	jal	4aa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 790:	0992                	slli	s3,s3,0x4
 792:	397d                	addiw	s2,s2,-1
 794:	fe0916e3          	bnez	s2,780 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 798:	8bea                	mv	s7,s10
      state = 0;
 79a:	4981                	li	s3,0
 79c:	6d02                	ld	s10,0(sp)
 79e:	bd01                	j	5ae <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7a0:	008b8913          	addi	s2,s7,8
 7a4:	000bc583          	lbu	a1,0(s7)
 7a8:	855a                	mv	a0,s6
 7aa:	d01ff0ef          	jal	4aa <putc>
 7ae:	8bca                	mv	s7,s2
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	bbf5                	j	5ae <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7b4:	008b8993          	addi	s3,s7,8
 7b8:	000bb903          	ld	s2,0(s7)
 7bc:	00090f63          	beqz	s2,7da <vprintf+0x276>
        for(; *s; s++)
 7c0:	00094583          	lbu	a1,0(s2)
 7c4:	c195                	beqz	a1,7e8 <vprintf+0x284>
          putc(fd, *s);
 7c6:	855a                	mv	a0,s6
 7c8:	ce3ff0ef          	jal	4aa <putc>
        for(; *s; s++)
 7cc:	0905                	addi	s2,s2,1
 7ce:	00094583          	lbu	a1,0(s2)
 7d2:	f9f5                	bnez	a1,7c6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7d4:	8bce                	mv	s7,s3
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bbd9                	j	5ae <vprintf+0x4a>
          s = "(null)";
 7da:	00000917          	auipc	s2,0x0
 7de:	3e690913          	addi	s2,s2,998 # bc0 <malloc+0x2da>
        for(; *s; s++)
 7e2:	02800593          	li	a1,40
 7e6:	b7c5                	j	7c6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7e8:	8bce                	mv	s7,s3
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	b3c9                	j	5ae <vprintf+0x4a>
 7ee:	64a6                	ld	s1,72(sp)
 7f0:	79e2                	ld	s3,56(sp)
 7f2:	7a42                	ld	s4,48(sp)
 7f4:	7aa2                	ld	s5,40(sp)
 7f6:	7b02                	ld	s6,32(sp)
 7f8:	6be2                	ld	s7,24(sp)
 7fa:	6c42                	ld	s8,16(sp)
 7fc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7fe:	60e6                	ld	ra,88(sp)
 800:	6446                	ld	s0,80(sp)
 802:	6906                	ld	s2,64(sp)
 804:	6125                	addi	sp,sp,96
 806:	8082                	ret

0000000000000808 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 808:	715d                	addi	sp,sp,-80
 80a:	ec06                	sd	ra,24(sp)
 80c:	e822                	sd	s0,16(sp)
 80e:	1000                	addi	s0,sp,32
 810:	e010                	sd	a2,0(s0)
 812:	e414                	sd	a3,8(s0)
 814:	e818                	sd	a4,16(s0)
 816:	ec1c                	sd	a5,24(s0)
 818:	03043023          	sd	a6,32(s0)
 81c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 820:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 824:	8622                	mv	a2,s0
 826:	d3fff0ef          	jal	564 <vprintf>
}
 82a:	60e2                	ld	ra,24(sp)
 82c:	6442                	ld	s0,16(sp)
 82e:	6161                	addi	sp,sp,80
 830:	8082                	ret

0000000000000832 <printf>:

void
printf(const char *fmt, ...)
{
 832:	711d                	addi	sp,sp,-96
 834:	ec06                	sd	ra,24(sp)
 836:	e822                	sd	s0,16(sp)
 838:	1000                	addi	s0,sp,32
 83a:	e40c                	sd	a1,8(s0)
 83c:	e810                	sd	a2,16(s0)
 83e:	ec14                	sd	a3,24(s0)
 840:	f018                	sd	a4,32(s0)
 842:	f41c                	sd	a5,40(s0)
 844:	03043823          	sd	a6,48(s0)
 848:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 84c:	00840613          	addi	a2,s0,8
 850:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 854:	85aa                	mv	a1,a0
 856:	4505                	li	a0,1
 858:	d0dff0ef          	jal	564 <vprintf>
}
 85c:	60e2                	ld	ra,24(sp)
 85e:	6442                	ld	s0,16(sp)
 860:	6125                	addi	sp,sp,96
 862:	8082                	ret

0000000000000864 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 864:	1141                	addi	sp,sp,-16
 866:	e422                	sd	s0,8(sp)
 868:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86e:	00001797          	auipc	a5,0x1
 872:	7927b783          	ld	a5,1938(a5) # 2000 <freep>
 876:	a02d                	j	8a0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 878:	4618                	lw	a4,8(a2)
 87a:	9f2d                	addw	a4,a4,a1
 87c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 880:	6398                	ld	a4,0(a5)
 882:	6310                	ld	a2,0(a4)
 884:	a83d                	j	8c2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 886:	ff852703          	lw	a4,-8(a0)
 88a:	9f31                	addw	a4,a4,a2
 88c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88e:	ff053683          	ld	a3,-16(a0)
 892:	a091                	j	8d6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 894:	6398                	ld	a4,0(a5)
 896:	00e7e463          	bltu	a5,a4,89e <free+0x3a>
 89a:	00e6ea63          	bltu	a3,a4,8ae <free+0x4a>
{
 89e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a0:	fed7fae3          	bgeu	a5,a3,894 <free+0x30>
 8a4:	6398                	ld	a4,0(a5)
 8a6:	00e6e463          	bltu	a3,a4,8ae <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8aa:	fee7eae3          	bltu	a5,a4,89e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ae:	ff852583          	lw	a1,-8(a0)
 8b2:	6390                	ld	a2,0(a5)
 8b4:	02059813          	slli	a6,a1,0x20
 8b8:	01c85713          	srli	a4,a6,0x1c
 8bc:	9736                	add	a4,a4,a3
 8be:	fae60de3          	beq	a2,a4,878 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c6:	4790                	lw	a2,8(a5)
 8c8:	02061593          	slli	a1,a2,0x20
 8cc:	01c5d713          	srli	a4,a1,0x1c
 8d0:	973e                	add	a4,a4,a5
 8d2:	fae68ae3          	beq	a3,a4,886 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8d8:	00001717          	auipc	a4,0x1
 8dc:	72f73423          	sd	a5,1832(a4) # 2000 <freep>
}
 8e0:	6422                	ld	s0,8(sp)
 8e2:	0141                	addi	sp,sp,16
 8e4:	8082                	ret

00000000000008e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e6:	7139                	addi	sp,sp,-64
 8e8:	fc06                	sd	ra,56(sp)
 8ea:	f822                	sd	s0,48(sp)
 8ec:	f426                	sd	s1,40(sp)
 8ee:	ec4e                	sd	s3,24(sp)
 8f0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f2:	02051493          	slli	s1,a0,0x20
 8f6:	9081                	srli	s1,s1,0x20
 8f8:	04bd                	addi	s1,s1,15
 8fa:	8091                	srli	s1,s1,0x4
 8fc:	0014899b          	addiw	s3,s1,1
 900:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 902:	00001517          	auipc	a0,0x1
 906:	6fe53503          	ld	a0,1790(a0) # 2000 <freep>
 90a:	c915                	beqz	a0,93e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90e:	4798                	lw	a4,8(a5)
 910:	08977a63          	bgeu	a4,s1,9a4 <malloc+0xbe>
 914:	f04a                	sd	s2,32(sp)
 916:	e852                	sd	s4,16(sp)
 918:	e456                	sd	s5,8(sp)
 91a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 91c:	8a4e                	mv	s4,s3
 91e:	0009871b          	sext.w	a4,s3
 922:	6685                	lui	a3,0x1
 924:	00d77363          	bgeu	a4,a3,92a <malloc+0x44>
 928:	6a05                	lui	s4,0x1
 92a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 932:	00001917          	auipc	s2,0x1
 936:	6ce90913          	addi	s2,s2,1742 # 2000 <freep>
  if(p == SBRK_ERROR)
 93a:	5afd                	li	s5,-1
 93c:	a081                	j	97c <malloc+0x96>
 93e:	f04a                	sd	s2,32(sp)
 940:	e852                	sd	s4,16(sp)
 942:	e456                	sd	s5,8(sp)
 944:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 946:	00001797          	auipc	a5,0x1
 94a:	6ca78793          	addi	a5,a5,1738 # 2010 <base>
 94e:	00001717          	auipc	a4,0x1
 952:	6af73923          	sd	a5,1714(a4) # 2000 <freep>
 956:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 958:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 95c:	b7c1                	j	91c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 95e:	6398                	ld	a4,0(a5)
 960:	e118                	sd	a4,0(a0)
 962:	a8a9                	j	9bc <malloc+0xd6>
  hp->s.size = nu;
 964:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 968:	0541                	addi	a0,a0,16
 96a:	efbff0ef          	jal	864 <free>
  return freep;
 96e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 972:	c12d                	beqz	a0,9d4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 974:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 976:	4798                	lw	a4,8(a5)
 978:	02977263          	bgeu	a4,s1,99c <malloc+0xb6>
    if(p == freep)
 97c:	00093703          	ld	a4,0(s2)
 980:	853e                	mv	a0,a5
 982:	fef719e3          	bne	a4,a5,974 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 986:	8552                	mv	a0,s4
 988:	a47ff0ef          	jal	3ce <sbrk>
  if(p == SBRK_ERROR)
 98c:	fd551ce3          	bne	a0,s5,964 <malloc+0x7e>
        return 0;
 990:	4501                	li	a0,0
 992:	7902                	ld	s2,32(sp)
 994:	6a42                	ld	s4,16(sp)
 996:	6aa2                	ld	s5,8(sp)
 998:	6b02                	ld	s6,0(sp)
 99a:	a03d                	j	9c8 <malloc+0xe2>
 99c:	7902                	ld	s2,32(sp)
 99e:	6a42                	ld	s4,16(sp)
 9a0:	6aa2                	ld	s5,8(sp)
 9a2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a4:	fae48de3          	beq	s1,a4,95e <malloc+0x78>
        p->s.size -= nunits;
 9a8:	4137073b          	subw	a4,a4,s3
 9ac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ae:	02071693          	slli	a3,a4,0x20
 9b2:	01c6d713          	srli	a4,a3,0x1c
 9b6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9b8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9bc:	00001717          	auipc	a4,0x1
 9c0:	64a73223          	sd	a0,1604(a4) # 2000 <freep>
      return (void*)(p + 1);
 9c4:	01078513          	addi	a0,a5,16
  }
}
 9c8:	70e2                	ld	ra,56(sp)
 9ca:	7442                	ld	s0,48(sp)
 9cc:	74a2                	ld	s1,40(sp)
 9ce:	69e2                	ld	s3,24(sp)
 9d0:	6121                	addi	sp,sp,64
 9d2:	8082                	ret
 9d4:	7902                	ld	s2,32(sp)
 9d6:	6a42                	ld	s4,16(sp)
 9d8:	6aa2                	ld	s5,8(sp)
 9da:	6b02                	ld	s6,0(sp)
 9dc:	b7f5                	j	9c8 <malloc+0xe2>
