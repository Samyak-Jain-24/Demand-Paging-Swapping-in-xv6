
user/_test_multi:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  printf("[test_multi] worker %d done, sum=%d\n", id, sum);
  exit(0);
}

int main(void)
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	1080                	addi	s0,sp,96
  printf("[test_multi] start\n");
   e:	00001517          	auipc	a0,0x1
  12:	9b250513          	addi	a0,a0,-1614 # 9c0 <malloc+0xfa>
  16:	7fc000ef          	jal	812 <printf>
  int kids = 3;
  int pages = 1500; // each; moderate to avoid sbrk failure
  for (int i = 0; i < kids; i++) {
  1a:	4901                	li	s2,0
  1c:	498d                	li	s3,3
    int pid = fork();
  1e:	3bc000ef          	jal	3da <fork>
  22:	84aa                	mv	s1,a0
    if (pid < 0) {
  24:	04054563          	bltz	a0,6e <main+0x6e>
      printf("[test_multi] fork failed\nTEST FAILED\n");
      exit(1);
    }
    if (pid == 0) {
  28:	c125                	beqz	a0,88 <main+0x88>
  for (int i = 0; i < kids; i++) {
  2a:	2905                	addiw	s2,s2,1
  2c:	ff3919e3          	bne	s2,s3,1e <main+0x1e>
  30:	f852                	sd	s4,48(sp)
  32:	f456                	sd	s5,40(sp)
  34:	f05a                	sd	s6,32(sp)
  36:	ec5e                	sd	s7,24(sp)
  38:	448d                	li	s1,3
      worker(i, pages, 17+i);
    }
  }
  int st, ok = 1;
  3a:	4905                	li	s2,1
  for (int i = 0; i < kids; i++) {
    wait(&st);
  3c:	fac40513          	addi	a0,s0,-84
  40:	3aa000ef          	jal	3ea <wait>
  if (st != 0) ok = 0;
  44:	fac42783          	lw	a5,-84(s0)
  48:	0017b793          	seqz	a5,a5
  4c:	40f007b3          	neg	a5,a5
  50:	00f97933          	and	s2,s2,a5
  for (int i = 0; i < kids; i++) {
  54:	34fd                	addiw	s1,s1,-1
  56:	f0fd                	bnez	s1,3c <main+0x3c>
  }
  if (ok) {
  58:	0e090263          	beqz	s2,13c <main+0x13c>
    printf("TEST PASSED\n");
  5c:	00001517          	auipc	a0,0x1
  60:	a4450513          	addi	a0,a0,-1468 # aa0 <malloc+0x1da>
  64:	7ae000ef          	jal	812 <printf>
    exit(0);
  68:	4501                	li	a0,0
  6a:	378000ef          	jal	3e2 <exit>
  6e:	f852                	sd	s4,48(sp)
  70:	f456                	sd	s5,40(sp)
  72:	f05a                	sd	s6,32(sp)
  74:	ec5e                	sd	s7,24(sp)
      printf("[test_multi] fork failed\nTEST FAILED\n");
  76:	00001517          	auipc	a0,0x1
  7a:	96250513          	addi	a0,a0,-1694 # 9d8 <malloc+0x112>
  7e:	794000ef          	jal	812 <printf>
      exit(1);
  82:	4505                	li	a0,1
  84:	35e000ef          	jal	3e2 <exit>
  printf("[test_multi] worker %d: sbrk %d pages\n", id, pages);
  88:	5dc00613          	li	a2,1500
  8c:	85ca                	mv	a1,s2
  8e:	00001517          	auipc	a0,0x1
  92:	97250513          	addi	a0,a0,-1678 # a00 <malloc+0x13a>
  96:	77c000ef          	jal	812 <printf>
  char *base = sbrklazy(pages * PGSIZE);
  9a:	005dc537          	lui	a0,0x5dc
  9e:	326000ef          	jal	3c4 <sbrklazy>
  a2:	89aa                	mv	s3,a0
  if (base == (char*)-1) {
  a4:	57fd                	li	a5,-1
  a6:	02f50163          	beq	a0,a5,c8 <main+0xc8>
  aa:	f852                	sd	s4,48(sp)
  ac:	f456                	sd	s5,40(sp)
  ae:	f05a                	sd	s6,32(sp)
  b0:	ec5e                	sd	s7,24(sp)
  volatile int sum = 0;
  b2:	fa042423          	sw	zero,-88(s0)
    if ((i % 3) == 0) p[0] = (char)(i + id); // write
  b6:	4b0d                	li	s6,3
    if ((i % (pages/4+1)) == 0) printf("[test_multi] worker %d touched %d/%d\n", id, i, pages);
  b8:	17800a93          	li	s5,376
  bc:	00001b97          	auipc	s7,0x1
  c0:	994b8b93          	addi	s7,s7,-1644 # a50 <malloc+0x18a>
  for (int i = 0; i < pages; i++) {
  c4:	6a05                	lui	s4,0x1
  c6:	a83d                	j	104 <main+0x104>
  c8:	f852                	sd	s4,48(sp)
  ca:	f456                	sd	s5,40(sp)
  cc:	f05a                	sd	s6,32(sp)
  ce:	ec5e                	sd	s7,24(sp)
    printf("[test_multi] worker %d: sbrk failed\n", id);
  d0:	85ca                	mv	a1,s2
  d2:	00001517          	auipc	a0,0x1
  d6:	95650513          	addi	a0,a0,-1706 # a28 <malloc+0x162>
  da:	738000ef          	jal	812 <printf>
    exit(2);
  de:	4509                	li	a0,2
  e0:	302000ef          	jal	3e2 <exit>
    else sum += p[0]; // read
  e4:	fa842703          	lw	a4,-88(s0)
  e8:	0009c783          	lbu	a5,0(s3)
  ec:	9fb9                	addw	a5,a5,a4
  ee:	faf42423          	sw	a5,-88(s0)
    if ((i % (pages/4+1)) == 0) printf("[test_multi] worker %d touched %d/%d\n", id, i, pages);
  f2:	0354e7bb          	remw	a5,s1,s5
  f6:	cf99                	beqz	a5,114 <main+0x114>
  for (int i = 0; i < pages; i++) {
  f8:	2485                	addiw	s1,s1,1
  fa:	99d2                	add	s3,s3,s4
  fc:	5dc00793          	li	a5,1500
 100:	02f48263          	beq	s1,a5,124 <main+0x124>
    if ((i % 3) == 0) p[0] = (char)(i + id); // write
 104:	0364e7bb          	remw	a5,s1,s6
 108:	fff1                	bnez	a5,e4 <main+0xe4>
 10a:	012487bb          	addw	a5,s1,s2
 10e:	00f98023          	sb	a5,0(s3)
 112:	b7c5                	j	f2 <main+0xf2>
    if ((i % (pages/4+1)) == 0) printf("[test_multi] worker %d touched %d/%d\n", id, i, pages);
 114:	5dc00693          	li	a3,1500
 118:	8626                	mv	a2,s1
 11a:	85ca                	mv	a1,s2
 11c:	855e                	mv	a0,s7
 11e:	6f4000ef          	jal	812 <printf>
 122:	bfd9                	j	f8 <main+0xf8>
  printf("[test_multi] worker %d done, sum=%d\n", id, sum);
 124:	fa842603          	lw	a2,-88(s0)
 128:	85ca                	mv	a1,s2
 12a:	00001517          	auipc	a0,0x1
 12e:	94e50513          	addi	a0,a0,-1714 # a78 <malloc+0x1b2>
 132:	6e0000ef          	jal	812 <printf>
  exit(0);
 136:	4501                	li	a0,0
 138:	2aa000ef          	jal	3e2 <exit>
  } else {
    printf("TEST FAILED\n");
 13c:	00001517          	auipc	a0,0x1
 140:	97450513          	addi	a0,a0,-1676 # ab0 <malloc+0x1ea>
 144:	6ce000ef          	jal	812 <printf>
    exit(1);
 148:	4505                	li	a0,1
 14a:	298000ef          	jal	3e2 <exit>

000000000000014e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e406                	sd	ra,8(sp)
 152:	e022                	sd	s0,0(sp)
 154:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 156:	eabff0ef          	jal	0 <main>
  exit(r);
 15a:	288000ef          	jal	3e2 <exit>

000000000000015e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e422                	sd	s0,8(sp)
 162:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 164:	87aa                	mv	a5,a0
 166:	0585                	addi	a1,a1,1
 168:	0785                	addi	a5,a5,1
 16a:	fff5c703          	lbu	a4,-1(a1)
 16e:	fee78fa3          	sb	a4,-1(a5)
 172:	fb75                	bnez	a4,166 <strcpy+0x8>
    ;
  return os;
}
 174:	6422                	ld	s0,8(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret

000000000000017a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 180:	00054783          	lbu	a5,0(a0)
 184:	cb91                	beqz	a5,198 <strcmp+0x1e>
 186:	0005c703          	lbu	a4,0(a1)
 18a:	00f71763          	bne	a4,a5,198 <strcmp+0x1e>
    p++, q++;
 18e:	0505                	addi	a0,a0,1
 190:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 192:	00054783          	lbu	a5,0(a0)
 196:	fbe5                	bnez	a5,186 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 198:	0005c503          	lbu	a0,0(a1)
}
 19c:	40a7853b          	subw	a0,a5,a0
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret

00000000000001a6 <strlen>:

uint
strlen(const char *s)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ac:	00054783          	lbu	a5,0(a0)
 1b0:	cf91                	beqz	a5,1cc <strlen+0x26>
 1b2:	0505                	addi	a0,a0,1
 1b4:	87aa                	mv	a5,a0
 1b6:	86be                	mv	a3,a5
 1b8:	0785                	addi	a5,a5,1
 1ba:	fff7c703          	lbu	a4,-1(a5)
 1be:	ff65                	bnez	a4,1b6 <strlen+0x10>
 1c0:	40a6853b          	subw	a0,a3,a0
 1c4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret
  for(n = 0; s[n]; n++)
 1cc:	4501                	li	a0,0
 1ce:	bfe5                	j	1c6 <strlen+0x20>

00000000000001d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1d6:	ca19                	beqz	a2,1ec <memset+0x1c>
 1d8:	87aa                	mv	a5,a0
 1da:	1602                	slli	a2,a2,0x20
 1dc:	9201                	srli	a2,a2,0x20
 1de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1e6:	0785                	addi	a5,a5,1
 1e8:	fee79de3          	bne	a5,a4,1e2 <memset+0x12>
  }
  return dst;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret

00000000000001f2 <strchr>:

char*
strchr(const char *s, char c)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cb99                	beqz	a5,212 <strchr+0x20>
    if(*s == c)
 1fe:	00f58763          	beq	a1,a5,20c <strchr+0x1a>
  for(; *s; s++)
 202:	0505                	addi	a0,a0,1
 204:	00054783          	lbu	a5,0(a0)
 208:	fbfd                	bnez	a5,1fe <strchr+0xc>
      return (char*)s;
  return 0;
 20a:	4501                	li	a0,0
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
  return 0;
 212:	4501                	li	a0,0
 214:	bfe5                	j	20c <strchr+0x1a>

0000000000000216 <gets>:

char*
gets(char *buf, int max)
{
 216:	711d                	addi	sp,sp,-96
 218:	ec86                	sd	ra,88(sp)
 21a:	e8a2                	sd	s0,80(sp)
 21c:	e4a6                	sd	s1,72(sp)
 21e:	e0ca                	sd	s2,64(sp)
 220:	fc4e                	sd	s3,56(sp)
 222:	f852                	sd	s4,48(sp)
 224:	f456                	sd	s5,40(sp)
 226:	f05a                	sd	s6,32(sp)
 228:	ec5e                	sd	s7,24(sp)
 22a:	1080                	addi	s0,sp,96
 22c:	8baa                	mv	s7,a0
 22e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 230:	892a                	mv	s2,a0
 232:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 234:	4aa9                	li	s5,10
 236:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 238:	89a6                	mv	s3,s1
 23a:	2485                	addiw	s1,s1,1
 23c:	0344d663          	bge	s1,s4,268 <gets+0x52>
    cc = read(0, &c, 1);
 240:	4605                	li	a2,1
 242:	faf40593          	addi	a1,s0,-81
 246:	4501                	li	a0,0
 248:	1b2000ef          	jal	3fa <read>
    if(cc < 1)
 24c:	00a05e63          	blez	a0,268 <gets+0x52>
    buf[i++] = c;
 250:	faf44783          	lbu	a5,-81(s0)
 254:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 258:	01578763          	beq	a5,s5,266 <gets+0x50>
 25c:	0905                	addi	s2,s2,1
 25e:	fd679de3          	bne	a5,s6,238 <gets+0x22>
    buf[i++] = c;
 262:	89a6                	mv	s3,s1
 264:	a011                	j	268 <gets+0x52>
 266:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 268:	99de                	add	s3,s3,s7
 26a:	00098023          	sb	zero,0(s3)
  return buf;
}
 26e:	855e                	mv	a0,s7
 270:	60e6                	ld	ra,88(sp)
 272:	6446                	ld	s0,80(sp)
 274:	64a6                	ld	s1,72(sp)
 276:	6906                	ld	s2,64(sp)
 278:	79e2                	ld	s3,56(sp)
 27a:	7a42                	ld	s4,48(sp)
 27c:	7aa2                	ld	s5,40(sp)
 27e:	7b02                	ld	s6,32(sp)
 280:	6be2                	ld	s7,24(sp)
 282:	6125                	addi	sp,sp,96
 284:	8082                	ret

0000000000000286 <stat>:

int
stat(const char *n, struct stat *st)
{
 286:	1101                	addi	sp,sp,-32
 288:	ec06                	sd	ra,24(sp)
 28a:	e822                	sd	s0,16(sp)
 28c:	e04a                	sd	s2,0(sp)
 28e:	1000                	addi	s0,sp,32
 290:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 292:	4581                	li	a1,0
 294:	18e000ef          	jal	422 <open>
  if(fd < 0)
 298:	02054263          	bltz	a0,2bc <stat+0x36>
 29c:	e426                	sd	s1,8(sp)
 29e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a0:	85ca                	mv	a1,s2
 2a2:	198000ef          	jal	43a <fstat>
 2a6:	892a                	mv	s2,a0
  close(fd);
 2a8:	8526                	mv	a0,s1
 2aa:	160000ef          	jal	40a <close>
  return r;
 2ae:	64a2                	ld	s1,8(sp)
}
 2b0:	854a                	mv	a0,s2
 2b2:	60e2                	ld	ra,24(sp)
 2b4:	6442                	ld	s0,16(sp)
 2b6:	6902                	ld	s2,0(sp)
 2b8:	6105                	addi	sp,sp,32
 2ba:	8082                	ret
    return -1;
 2bc:	597d                	li	s2,-1
 2be:	bfcd                	j	2b0 <stat+0x2a>

00000000000002c0 <atoi>:

int
atoi(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c6:	00054683          	lbu	a3,0(a0)
 2ca:	fd06879b          	addiw	a5,a3,-48
 2ce:	0ff7f793          	zext.b	a5,a5
 2d2:	4625                	li	a2,9
 2d4:	02f66863          	bltu	a2,a5,304 <atoi+0x44>
 2d8:	872a                	mv	a4,a0
  n = 0;
 2da:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2dc:	0705                	addi	a4,a4,1
 2de:	0025179b          	slliw	a5,a0,0x2
 2e2:	9fa9                	addw	a5,a5,a0
 2e4:	0017979b          	slliw	a5,a5,0x1
 2e8:	9fb5                	addw	a5,a5,a3
 2ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ee:	00074683          	lbu	a3,0(a4)
 2f2:	fd06879b          	addiw	a5,a3,-48
 2f6:	0ff7f793          	zext.b	a5,a5
 2fa:	fef671e3          	bgeu	a2,a5,2dc <atoi+0x1c>
  return n;
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  n = 0;
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <atoi+0x3e>

0000000000000308 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30e:	02b57463          	bgeu	a0,a1,336 <memmove+0x2e>
    while(n-- > 0)
 312:	00c05f63          	blez	a2,330 <memmove+0x28>
 316:	1602                	slli	a2,a2,0x20
 318:	9201                	srli	a2,a2,0x20
 31a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31e:	872a                	mv	a4,a0
      *dst++ = *src++;
 320:	0585                	addi	a1,a1,1
 322:	0705                	addi	a4,a4,1
 324:	fff5c683          	lbu	a3,-1(a1)
 328:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32c:	fef71ae3          	bne	a4,a5,320 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
    dst += n;
 336:	00c50733          	add	a4,a0,a2
    src += n;
 33a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33c:	fec05ae3          	blez	a2,330 <memmove+0x28>
 340:	fff6079b          	addiw	a5,a2,-1
 344:	1782                	slli	a5,a5,0x20
 346:	9381                	srli	a5,a5,0x20
 348:	fff7c793          	not	a5,a5
 34c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 34e:	15fd                	addi	a1,a1,-1
 350:	177d                	addi	a4,a4,-1
 352:	0005c683          	lbu	a3,0(a1)
 356:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x46>
 35e:	bfc9                	j	330 <memmove+0x28>

0000000000000360 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 366:	ca05                	beqz	a2,396 <memcmp+0x36>
 368:	fff6069b          	addiw	a3,a2,-1
 36c:	1682                	slli	a3,a3,0x20
 36e:	9281                	srli	a3,a3,0x20
 370:	0685                	addi	a3,a3,1
 372:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 374:	00054783          	lbu	a5,0(a0)
 378:	0005c703          	lbu	a4,0(a1)
 37c:	00e79863          	bne	a5,a4,38c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 380:	0505                	addi	a0,a0,1
    p2++;
 382:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 384:	fed518e3          	bne	a0,a3,374 <memcmp+0x14>
  }
  return 0;
 388:	4501                	li	a0,0
 38a:	a019                	j	390 <memcmp+0x30>
      return *p1 - *p2;
 38c:	40e7853b          	subw	a0,a5,a4
}
 390:	6422                	ld	s0,8(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
  return 0;
 396:	4501                	li	a0,0
 398:	bfe5                	j	390 <memcmp+0x30>

000000000000039a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e406                	sd	ra,8(sp)
 39e:	e022                	sd	s0,0(sp)
 3a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a2:	f67ff0ef          	jal	308 <memmove>
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret

00000000000003ae <sbrk>:

char *
sbrk(int n) {
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  // Eager allocation by default to preserve original xv6 semantics
  // relied upon by many user programs and tests (e.g., countfree).
  return sys_sbrk(n, SBRK_EAGER);
 3b6:	4585                	li	a1,1
 3b8:	0b2000ef          	jal	46a <sys_sbrk>
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <sbrklazy>:

char *
sbrklazy(int n) {
 3c4:	1141                	addi	sp,sp,-16
 3c6:	e406                	sd	ra,8(sp)
 3c8:	e022                	sd	s0,0(sp)
 3ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3cc:	4589                	li	a1,2
 3ce:	09c000ef          	jal	46a <sys_sbrk>
}
 3d2:	60a2                	ld	ra,8(sp)
 3d4:	6402                	ld	s0,0(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret

00000000000003da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3da:	4885                	li	a7,1
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e2:	4889                	li	a7,2
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ea:	488d                	li	a7,3
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f2:	4891                	li	a7,4
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <read>:
.global read
read:
 li a7, SYS_read
 3fa:	4895                	li	a7,5
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <write>:
.global write
write:
 li a7, SYS_write
 402:	48c1                	li	a7,16
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <close>:
.global close
close:
 li a7, SYS_close
 40a:	48d5                	li	a7,21
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <kill>:
.global kill
kill:
 li a7, SYS_kill
 412:	4899                	li	a7,6
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <exec>:
.global exec
exec:
 li a7, SYS_exec
 41a:	489d                	li	a7,7
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <open>:
.global open
open:
 li a7, SYS_open
 422:	48bd                	li	a7,15
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 42a:	48c5                	li	a7,17
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 432:	48c9                	li	a7,18
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 43a:	48a1                	li	a7,8
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <link>:
.global link
link:
 li a7, SYS_link
 442:	48cd                	li	a7,19
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 44a:	48d1                	li	a7,20
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 452:	48a5                	li	a7,9
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <dup>:
.global dup
dup:
 li a7, SYS_dup
 45a:	48a9                	li	a7,10
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 462:	48ad                	li	a7,11
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 46a:	48b1                	li	a7,12
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <pause>:
.global pause
pause:
 li a7, SYS_pause
 472:	48b5                	li	a7,13
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 47a:	48b9                	li	a7,14
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 482:	48d9                	li	a7,22
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 48a:	1101                	addi	sp,sp,-32
 48c:	ec06                	sd	ra,24(sp)
 48e:	e822                	sd	s0,16(sp)
 490:	1000                	addi	s0,sp,32
 492:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 496:	4605                	li	a2,1
 498:	fef40593          	addi	a1,s0,-17
 49c:	f67ff0ef          	jal	402 <write>
}
 4a0:	60e2                	ld	ra,24(sp)
 4a2:	6442                	ld	s0,16(sp)
 4a4:	6105                	addi	sp,sp,32
 4a6:	8082                	ret

00000000000004a8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4a8:	715d                	addi	sp,sp,-80
 4aa:	e486                	sd	ra,72(sp)
 4ac:	e0a2                	sd	s0,64(sp)
 4ae:	f84a                	sd	s2,48(sp)
 4b0:	0880                	addi	s0,sp,80
 4b2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4b4:	c299                	beqz	a3,4ba <printint+0x12>
 4b6:	0805c363          	bltz	a1,53c <printint+0x94>
  neg = 0;
 4ba:	4881                	li	a7,0
 4bc:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4c0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4c2:	00000517          	auipc	a0,0x0
 4c6:	60650513          	addi	a0,a0,1542 # ac8 <digits>
 4ca:	883e                	mv	a6,a5
 4cc:	2785                	addiw	a5,a5,1
 4ce:	02c5f733          	remu	a4,a1,a2
 4d2:	972a                	add	a4,a4,a0
 4d4:	00074703          	lbu	a4,0(a4)
 4d8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4dc:	872e                	mv	a4,a1
 4de:	02c5d5b3          	divu	a1,a1,a2
 4e2:	0685                	addi	a3,a3,1
 4e4:	fec773e3          	bgeu	a4,a2,4ca <printint+0x22>
  if(neg)
 4e8:	00088b63          	beqz	a7,4fe <printint+0x56>
    buf[i++] = '-';
 4ec:	fd078793          	addi	a5,a5,-48
 4f0:	97a2                	add	a5,a5,s0
 4f2:	02d00713          	li	a4,45
 4f6:	fee78423          	sb	a4,-24(a5)
 4fa:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4fe:	02f05a63          	blez	a5,532 <printint+0x8a>
 502:	fc26                	sd	s1,56(sp)
 504:	f44e                	sd	s3,40(sp)
 506:	fb840713          	addi	a4,s0,-72
 50a:	00f704b3          	add	s1,a4,a5
 50e:	fff70993          	addi	s3,a4,-1
 512:	99be                	add	s3,s3,a5
 514:	37fd                	addiw	a5,a5,-1
 516:	1782                	slli	a5,a5,0x20
 518:	9381                	srli	a5,a5,0x20
 51a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 51e:	fff4c583          	lbu	a1,-1(s1)
 522:	854a                	mv	a0,s2
 524:	f67ff0ef          	jal	48a <putc>
  while(--i >= 0)
 528:	14fd                	addi	s1,s1,-1
 52a:	ff349ae3          	bne	s1,s3,51e <printint+0x76>
 52e:	74e2                	ld	s1,56(sp)
 530:	79a2                	ld	s3,40(sp)
}
 532:	60a6                	ld	ra,72(sp)
 534:	6406                	ld	s0,64(sp)
 536:	7942                	ld	s2,48(sp)
 538:	6161                	addi	sp,sp,80
 53a:	8082                	ret
    x = -xx;
 53c:	40b005b3          	neg	a1,a1
    neg = 1;
 540:	4885                	li	a7,1
    x = -xx;
 542:	bfad                	j	4bc <printint+0x14>

0000000000000544 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 544:	711d                	addi	sp,sp,-96
 546:	ec86                	sd	ra,88(sp)
 548:	e8a2                	sd	s0,80(sp)
 54a:	e0ca                	sd	s2,64(sp)
 54c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 54e:	0005c903          	lbu	s2,0(a1)
 552:	28090663          	beqz	s2,7de <vprintf+0x29a>
 556:	e4a6                	sd	s1,72(sp)
 558:	fc4e                	sd	s3,56(sp)
 55a:	f852                	sd	s4,48(sp)
 55c:	f456                	sd	s5,40(sp)
 55e:	f05a                	sd	s6,32(sp)
 560:	ec5e                	sd	s7,24(sp)
 562:	e862                	sd	s8,16(sp)
 564:	e466                	sd	s9,8(sp)
 566:	8b2a                	mv	s6,a0
 568:	8a2e                	mv	s4,a1
 56a:	8bb2                	mv	s7,a2
  state = 0;
 56c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 56e:	4481                	li	s1,0
 570:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 572:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 576:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 57a:	06c00c93          	li	s9,108
 57e:	a005                	j	59e <vprintf+0x5a>
        putc(fd, c0);
 580:	85ca                	mv	a1,s2
 582:	855a                	mv	a0,s6
 584:	f07ff0ef          	jal	48a <putc>
 588:	a019                	j	58e <vprintf+0x4a>
    } else if(state == '%'){
 58a:	03598263          	beq	s3,s5,5ae <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 58e:	2485                	addiw	s1,s1,1
 590:	8726                	mv	a4,s1
 592:	009a07b3          	add	a5,s4,s1
 596:	0007c903          	lbu	s2,0(a5)
 59a:	22090a63          	beqz	s2,7ce <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 59e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a2:	fe0994e3          	bnez	s3,58a <vprintf+0x46>
      if(c0 == '%'){
 5a6:	fd579de3          	bne	a5,s5,580 <vprintf+0x3c>
        state = '%';
 5aa:	89be                	mv	s3,a5
 5ac:	b7cd                	j	58e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5ae:	00ea06b3          	add	a3,s4,a4
 5b2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5b6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5b8:	c681                	beqz	a3,5c0 <vprintf+0x7c>
 5ba:	9752                	add	a4,a4,s4
 5bc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5c0:	05878363          	beq	a5,s8,606 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5c4:	05978d63          	beq	a5,s9,61e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5c8:	07500713          	li	a4,117
 5cc:	0ee78763          	beq	a5,a4,6ba <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5d0:	07800713          	li	a4,120
 5d4:	12e78963          	beq	a5,a4,706 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5d8:	07000713          	li	a4,112
 5dc:	14e78e63          	beq	a5,a4,738 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5e0:	06300713          	li	a4,99
 5e4:	18e78e63          	beq	a5,a4,780 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5e8:	07300713          	li	a4,115
 5ec:	1ae78463          	beq	a5,a4,794 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5f0:	02500713          	li	a4,37
 5f4:	04e79563          	bne	a5,a4,63e <vprintf+0xfa>
        putc(fd, '%');
 5f8:	02500593          	li	a1,37
 5fc:	855a                	mv	a0,s6
 5fe:	e8dff0ef          	jal	48a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 602:	4981                	li	s3,0
 604:	b769                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 606:	008b8913          	addi	s2,s7,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000ba583          	lw	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	e95ff0ef          	jal	4a8 <printint>
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bf8d                	j	58e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 61e:	06400793          	li	a5,100
 622:	02f68963          	beq	a3,a5,654 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 626:	06c00793          	li	a5,108
 62a:	04f68263          	beq	a3,a5,66e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 62e:	07500793          	li	a5,117
 632:	0af68063          	beq	a3,a5,6d2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 636:	07800793          	li	a5,120
 63a:	0ef68263          	beq	a3,a5,71e <vprintf+0x1da>
        putc(fd, '%');
 63e:	02500593          	li	a1,37
 642:	855a                	mv	a0,s6
 644:	e47ff0ef          	jal	48a <putc>
        putc(fd, c0);
 648:	85ca                	mv	a1,s2
 64a:	855a                	mv	a0,s6
 64c:	e3fff0ef          	jal	48a <putc>
      state = 0;
 650:	4981                	li	s3,0
 652:	bf35                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 654:	008b8913          	addi	s2,s7,8
 658:	4685                	li	a3,1
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	e47ff0ef          	jal	4a8 <printint>
        i += 1;
 666:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 1;
 66c:	b70d                	j	58e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 66e:	06400793          	li	a5,100
 672:	02f60763          	beq	a2,a5,6a0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 676:	07500793          	li	a5,117
 67a:	06f60963          	beq	a2,a5,6ec <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 67e:	07800793          	li	a5,120
 682:	faf61ee3          	bne	a2,a5,63e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 686:	008b8913          	addi	s2,s7,8
 68a:	4681                	li	a3,0
 68c:	4641                	li	a2,16
 68e:	000bb583          	ld	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	e15ff0ef          	jal	4a8 <printint>
        i += 2;
 698:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
        i += 2;
 69e:	bdc5                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4685                	li	a3,1
 6a6:	4629                	li	a2,10
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	dfbff0ef          	jal	4a8 <printint>
        i += 2;
 6b2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 2;
 6b8:	bdd9                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6ba:	008b8913          	addi	s2,s7,8
 6be:	4681                	li	a3,0
 6c0:	4629                	li	a2,10
 6c2:	000be583          	lwu	a1,0(s7)
 6c6:	855a                	mv	a0,s6
 6c8:	de1ff0ef          	jal	4a8 <printint>
 6cc:	8bca                	mv	s7,s2
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bd7d                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	4681                	li	a3,0
 6d8:	4629                	li	a2,10
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	dc9ff0ef          	jal	4a8 <printint>
        i += 1;
 6e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
        i += 1;
 6ea:	b555                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ec:	008b8913          	addi	s2,s7,8
 6f0:	4681                	li	a3,0
 6f2:	4629                	li	a2,10
 6f4:	000bb583          	ld	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	dafff0ef          	jal	4a8 <printint>
        i += 2;
 6fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 700:	8bca                	mv	s7,s2
      state = 0;
 702:	4981                	li	s3,0
        i += 2;
 704:	b569                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 706:	008b8913          	addi	s2,s7,8
 70a:	4681                	li	a3,0
 70c:	4641                	li	a2,16
 70e:	000be583          	lwu	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	d95ff0ef          	jal	4a8 <printint>
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bd8d                	j	58e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 71e:	008b8913          	addi	s2,s7,8
 722:	4681                	li	a3,0
 724:	4641                	li	a2,16
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	d7dff0ef          	jal	4a8 <printint>
        i += 1;
 730:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 732:	8bca                	mv	s7,s2
      state = 0;
 734:	4981                	li	s3,0
        i += 1;
 736:	bda1                	j	58e <vprintf+0x4a>
 738:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 73a:	008b8d13          	addi	s10,s7,8
 73e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 742:	03000593          	li	a1,48
 746:	855a                	mv	a0,s6
 748:	d43ff0ef          	jal	48a <putc>
  putc(fd, 'x');
 74c:	07800593          	li	a1,120
 750:	855a                	mv	a0,s6
 752:	d39ff0ef          	jal	48a <putc>
 756:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 758:	00000b97          	auipc	s7,0x0
 75c:	370b8b93          	addi	s7,s7,880 # ac8 <digits>
 760:	03c9d793          	srli	a5,s3,0x3c
 764:	97de                	add	a5,a5,s7
 766:	0007c583          	lbu	a1,0(a5)
 76a:	855a                	mv	a0,s6
 76c:	d1fff0ef          	jal	48a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 770:	0992                	slli	s3,s3,0x4
 772:	397d                	addiw	s2,s2,-1
 774:	fe0916e3          	bnez	s2,760 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 778:	8bea                	mv	s7,s10
      state = 0;
 77a:	4981                	li	s3,0
 77c:	6d02                	ld	s10,0(sp)
 77e:	bd01                	j	58e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 780:	008b8913          	addi	s2,s7,8
 784:	000bc583          	lbu	a1,0(s7)
 788:	855a                	mv	a0,s6
 78a:	d01ff0ef          	jal	48a <putc>
 78e:	8bca                	mv	s7,s2
      state = 0;
 790:	4981                	li	s3,0
 792:	bbf5                	j	58e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 794:	008b8993          	addi	s3,s7,8
 798:	000bb903          	ld	s2,0(s7)
 79c:	00090f63          	beqz	s2,7ba <vprintf+0x276>
        for(; *s; s++)
 7a0:	00094583          	lbu	a1,0(s2)
 7a4:	c195                	beqz	a1,7c8 <vprintf+0x284>
          putc(fd, *s);
 7a6:	855a                	mv	a0,s6
 7a8:	ce3ff0ef          	jal	48a <putc>
        for(; *s; s++)
 7ac:	0905                	addi	s2,s2,1
 7ae:	00094583          	lbu	a1,0(s2)
 7b2:	f9f5                	bnez	a1,7a6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7b4:	8bce                	mv	s7,s3
      state = 0;
 7b6:	4981                	li	s3,0
 7b8:	bbd9                	j	58e <vprintf+0x4a>
          s = "(null)";
 7ba:	00000917          	auipc	s2,0x0
 7be:	30690913          	addi	s2,s2,774 # ac0 <malloc+0x1fa>
        for(; *s; s++)
 7c2:	02800593          	li	a1,40
 7c6:	b7c5                	j	7a6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7c8:	8bce                	mv	s7,s3
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b3c9                	j	58e <vprintf+0x4a>
 7ce:	64a6                	ld	s1,72(sp)
 7d0:	79e2                	ld	s3,56(sp)
 7d2:	7a42                	ld	s4,48(sp)
 7d4:	7aa2                	ld	s5,40(sp)
 7d6:	7b02                	ld	s6,32(sp)
 7d8:	6be2                	ld	s7,24(sp)
 7da:	6c42                	ld	s8,16(sp)
 7dc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7de:	60e6                	ld	ra,88(sp)
 7e0:	6446                	ld	s0,80(sp)
 7e2:	6906                	ld	s2,64(sp)
 7e4:	6125                	addi	sp,sp,96
 7e6:	8082                	ret

00000000000007e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e8:	715d                	addi	sp,sp,-80
 7ea:	ec06                	sd	ra,24(sp)
 7ec:	e822                	sd	s0,16(sp)
 7ee:	1000                	addi	s0,sp,32
 7f0:	e010                	sd	a2,0(s0)
 7f2:	e414                	sd	a3,8(s0)
 7f4:	e818                	sd	a4,16(s0)
 7f6:	ec1c                	sd	a5,24(s0)
 7f8:	03043023          	sd	a6,32(s0)
 7fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 800:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 804:	8622                	mv	a2,s0
 806:	d3fff0ef          	jal	544 <vprintf>
}
 80a:	60e2                	ld	ra,24(sp)
 80c:	6442                	ld	s0,16(sp)
 80e:	6161                	addi	sp,sp,80
 810:	8082                	ret

0000000000000812 <printf>:

void
printf(const char *fmt, ...)
{
 812:	711d                	addi	sp,sp,-96
 814:	ec06                	sd	ra,24(sp)
 816:	e822                	sd	s0,16(sp)
 818:	1000                	addi	s0,sp,32
 81a:	e40c                	sd	a1,8(s0)
 81c:	e810                	sd	a2,16(s0)
 81e:	ec14                	sd	a3,24(s0)
 820:	f018                	sd	a4,32(s0)
 822:	f41c                	sd	a5,40(s0)
 824:	03043823          	sd	a6,48(s0)
 828:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 82c:	00840613          	addi	a2,s0,8
 830:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 834:	85aa                	mv	a1,a0
 836:	4505                	li	a0,1
 838:	d0dff0ef          	jal	544 <vprintf>
}
 83c:	60e2                	ld	ra,24(sp)
 83e:	6442                	ld	s0,16(sp)
 840:	6125                	addi	sp,sp,96
 842:	8082                	ret

0000000000000844 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 844:	1141                	addi	sp,sp,-16
 846:	e422                	sd	s0,8(sp)
 848:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84e:	00000797          	auipc	a5,0x0
 852:	7b27b783          	ld	a5,1970(a5) # 1000 <freep>
 856:	a02d                	j	880 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 858:	4618                	lw	a4,8(a2)
 85a:	9f2d                	addw	a4,a4,a1
 85c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 860:	6398                	ld	a4,0(a5)
 862:	6310                	ld	a2,0(a4)
 864:	a83d                	j	8a2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 866:	ff852703          	lw	a4,-8(a0)
 86a:	9f31                	addw	a4,a4,a2
 86c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 86e:	ff053683          	ld	a3,-16(a0)
 872:	a091                	j	8b6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 874:	6398                	ld	a4,0(a5)
 876:	00e7e463          	bltu	a5,a4,87e <free+0x3a>
 87a:	00e6ea63          	bltu	a3,a4,88e <free+0x4a>
{
 87e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	fed7fae3          	bgeu	a5,a3,874 <free+0x30>
 884:	6398                	ld	a4,0(a5)
 886:	00e6e463          	bltu	a3,a4,88e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88a:	fee7eae3          	bltu	a5,a4,87e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 88e:	ff852583          	lw	a1,-8(a0)
 892:	6390                	ld	a2,0(a5)
 894:	02059813          	slli	a6,a1,0x20
 898:	01c85713          	srli	a4,a6,0x1c
 89c:	9736                	add	a4,a4,a3
 89e:	fae60de3          	beq	a2,a4,858 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a6:	4790                	lw	a2,8(a5)
 8a8:	02061593          	slli	a1,a2,0x20
 8ac:	01c5d713          	srli	a4,a1,0x1c
 8b0:	973e                	add	a4,a4,a5
 8b2:	fae68ae3          	beq	a3,a4,866 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8b6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b8:	00000717          	auipc	a4,0x0
 8bc:	74f73423          	sd	a5,1864(a4) # 1000 <freep>
}
 8c0:	6422                	ld	s0,8(sp)
 8c2:	0141                	addi	sp,sp,16
 8c4:	8082                	ret

00000000000008c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c6:	7139                	addi	sp,sp,-64
 8c8:	fc06                	sd	ra,56(sp)
 8ca:	f822                	sd	s0,48(sp)
 8cc:	f426                	sd	s1,40(sp)
 8ce:	ec4e                	sd	s3,24(sp)
 8d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d2:	02051493          	slli	s1,a0,0x20
 8d6:	9081                	srli	s1,s1,0x20
 8d8:	04bd                	addi	s1,s1,15
 8da:	8091                	srli	s1,s1,0x4
 8dc:	0014899b          	addiw	s3,s1,1
 8e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e2:	00000517          	auipc	a0,0x0
 8e6:	71e53503          	ld	a0,1822(a0) # 1000 <freep>
 8ea:	c915                	beqz	a0,91e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ee:	4798                	lw	a4,8(a5)
 8f0:	08977a63          	bgeu	a4,s1,984 <malloc+0xbe>
 8f4:	f04a                	sd	s2,32(sp)
 8f6:	e852                	sd	s4,16(sp)
 8f8:	e456                	sd	s5,8(sp)
 8fa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8fc:	8a4e                	mv	s4,s3
 8fe:	0009871b          	sext.w	a4,s3
 902:	6685                	lui	a3,0x1
 904:	00d77363          	bgeu	a4,a3,90a <malloc+0x44>
 908:	6a05                	lui	s4,0x1
 90a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 90e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 912:	00000917          	auipc	s2,0x0
 916:	6ee90913          	addi	s2,s2,1774 # 1000 <freep>
  if(p == SBRK_ERROR)
 91a:	5afd                	li	s5,-1
 91c:	a081                	j	95c <malloc+0x96>
 91e:	f04a                	sd	s2,32(sp)
 920:	e852                	sd	s4,16(sp)
 922:	e456                	sd	s5,8(sp)
 924:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 926:	00000797          	auipc	a5,0x0
 92a:	6ea78793          	addi	a5,a5,1770 # 1010 <base>
 92e:	00000717          	auipc	a4,0x0
 932:	6cf73923          	sd	a5,1746(a4) # 1000 <freep>
 936:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 938:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 93c:	b7c1                	j	8fc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 93e:	6398                	ld	a4,0(a5)
 940:	e118                	sd	a4,0(a0)
 942:	a8a9                	j	99c <malloc+0xd6>
  hp->s.size = nu;
 944:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 948:	0541                	addi	a0,a0,16
 94a:	efbff0ef          	jal	844 <free>
  return freep;
 94e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 952:	c12d                	beqz	a0,9b4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 954:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 956:	4798                	lw	a4,8(a5)
 958:	02977263          	bgeu	a4,s1,97c <malloc+0xb6>
    if(p == freep)
 95c:	00093703          	ld	a4,0(s2)
 960:	853e                	mv	a0,a5
 962:	fef719e3          	bne	a4,a5,954 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 966:	8552                	mv	a0,s4
 968:	a47ff0ef          	jal	3ae <sbrk>
  if(p == SBRK_ERROR)
 96c:	fd551ce3          	bne	a0,s5,944 <malloc+0x7e>
        return 0;
 970:	4501                	li	a0,0
 972:	7902                	ld	s2,32(sp)
 974:	6a42                	ld	s4,16(sp)
 976:	6aa2                	ld	s5,8(sp)
 978:	6b02                	ld	s6,0(sp)
 97a:	a03d                	j	9a8 <malloc+0xe2>
 97c:	7902                	ld	s2,32(sp)
 97e:	6a42                	ld	s4,16(sp)
 980:	6aa2                	ld	s5,8(sp)
 982:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 984:	fae48de3          	beq	s1,a4,93e <malloc+0x78>
        p->s.size -= nunits;
 988:	4137073b          	subw	a4,a4,s3
 98c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 98e:	02071693          	slli	a3,a4,0x20
 992:	01c6d713          	srli	a4,a3,0x1c
 996:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 998:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 99c:	00000717          	auipc	a4,0x0
 9a0:	66a73223          	sd	a0,1636(a4) # 1000 <freep>
      return (void*)(p + 1);
 9a4:	01078513          	addi	a0,a5,16
  }
}
 9a8:	70e2                	ld	ra,56(sp)
 9aa:	7442                	ld	s0,48(sp)
 9ac:	74a2                	ld	s1,40(sp)
 9ae:	69e2                	ld	s3,24(sp)
 9b0:	6121                	addi	sp,sp,64
 9b2:	8082                	ret
 9b4:	7902                	ld	s2,32(sp)
 9b6:	6a42                	ld	s4,16(sp)
 9b8:	6aa2                	ld	s5,8(sp)
 9ba:	6b02                	ld	s6,0(sp)
 9bc:	b7f5                	j	9a8 <malloc+0xe2>
