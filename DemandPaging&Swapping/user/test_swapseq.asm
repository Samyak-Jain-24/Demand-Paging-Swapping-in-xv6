
user/_test_swapseq:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define PGSIZE 4096

// Sequentially dirty many pages to force heavy SWAPOUT, then re-touch to cause SWAPIN.
int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  printf("[test_swapseq] start\n");
   8:	00001517          	auipc	a0,0x1
   c:	94850513          	addi	a0,a0,-1720 # 950 <malloc+0x102>
  10:	78a000ef          	jal	79a <printf>

  int pages = 8000;
  char *p = sbrklazy(pages * PGSIZE);
  14:	01f40537          	lui	a0,0x1f40
  18:	334000ef          	jal	34c <sbrklazy>
  if(p == (char*)-1){
  1c:	57fd                	li	a5,-1
  1e:	08f50363          	beq	a0,a5,a4 <main+0xa4>
  22:	882a                	mv	a6,a0
  24:	872a                	mv	a4,a0
    printf("[test_swapseq] sbrklazy failed\n");
    exit(1);
  }

  // Dirty all pages with a distinct pattern
  for(int i=0;i<pages;i++){
  26:	4781                	li	a5,0
  28:	6585                	lui	a1,0x1
  2a:	6609                	lui	a2,0x2
  2c:	f4060613          	addi	a2,a2,-192 # 1f40 <base+0xf30>
    p[i*PGSIZE] = (char)(i & 0x7f);
  30:	07f7f693          	andi	a3,a5,127
  34:	00d70023          	sb	a3,0(a4)
  for(int i=0;i<pages;i++){
  38:	2785                	addiw	a5,a5,1
  3a:	972e                	add	a4,a4,a1
  3c:	fec79ae3          	bne	a5,a2,30 <main+0x30>
  }

  // Sweep again in a strided order to provoke swapins
  volatile int sum = 0;
  40:	fe042623          	sw	zero,-20(s0)
  for(int i=pages-1;i>=0;i-=3){
  44:	01f3f7b7          	lui	a5,0x1f3f
  48:	97aa                	add	a5,a5,a0
  4a:	7779                	lui	a4,0xffffe
  4c:	00e50633          	add	a2,a0,a4
  50:	75f5                	lui	a1,0xffffd
    sum += p[i*PGSIZE];
  52:	fec42683          	lw	a3,-20(s0)
  56:	0007c703          	lbu	a4,0(a5) # 1f3f000 <base+0x1f3dff0>
  5a:	9f35                	addw	a4,a4,a3
  5c:	fee42623          	sw	a4,-20(s0)
  for(int i=pages-1;i>=0;i-=3){
  60:	97ae                	add	a5,a5,a1
  62:	fec798e3          	bne	a5,a2,52 <main+0x52>
  }

  // Spot check integrity
  for(int i=0;i<64 && i<pages;i++){
  66:	4581                	li	a1,0
  68:	6685                	lui	a3,0x1
  6a:	04000713          	li	a4,64
    char v = p[i*PGSIZE];
  6e:	00084603          	lbu	a2,0(a6)
    char want = (char)(i & 0x7f);
    if(v != want){
  72:	0ff5f793          	zext.b	a5,a1
  76:	04f61063          	bne	a2,a5,b6 <main+0xb6>
  for(int i=0;i<64 && i<pages;i++){
  7a:	2585                	addiw	a1,a1,1 # ffffffffffffd001 <base+0xffffffffffffbff1>
  7c:	9836                	add	a6,a6,a3
  7e:	fee598e3          	bne	a1,a4,6e <main+0x6e>
      printf("TEST FAILED\n");
      exit(1);
    }
  }

  printf("[test_swapseq] sum=%d\n", sum);
  82:	fec42583          	lw	a1,-20(s0)
  86:	00001517          	auipc	a0,0x1
  8a:	94a50513          	addi	a0,a0,-1718 # 9d0 <malloc+0x182>
  8e:	70c000ef          	jal	79a <printf>
  printf("TEST PASSED\n");
  92:	00001517          	auipc	a0,0x1
  96:	95650513          	addi	a0,a0,-1706 # 9e8 <malloc+0x19a>
  9a:	700000ef          	jal	79a <printf>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	2ca000ef          	jal	36a <exit>
    printf("[test_swapseq] sbrklazy failed\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	8c450513          	addi	a0,a0,-1852 # 968 <malloc+0x11a>
  ac:	6ee000ef          	jal	79a <printf>
    exit(1);
  b0:	4505                	li	a0,1
  b2:	2b8000ef          	jal	36a <exit>
      printf("[test_swapseq] mismatch at page %d: got %d want %d\n", i, (int)v, (int)want);
  b6:	86be                	mv	a3,a5
  b8:	00001517          	auipc	a0,0x1
  bc:	8d050513          	addi	a0,a0,-1840 # 988 <malloc+0x13a>
  c0:	6da000ef          	jal	79a <printf>
      printf("TEST FAILED\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	8fc50513          	addi	a0,a0,-1796 # 9c0 <malloc+0x172>
  cc:	6ce000ef          	jal	79a <printf>
      exit(1);
  d0:	4505                	li	a0,1
  d2:	298000ef          	jal	36a <exit>

00000000000000d6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e406                	sd	ra,8(sp)
  da:	e022                	sd	s0,0(sp)
  dc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  de:	f23ff0ef          	jal	0 <main>
  exit(r);
  e2:	288000ef          	jal	36a <exit>

00000000000000e6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ec:	87aa                	mv	a5,a0
  ee:	0585                	addi	a1,a1,1
  f0:	0785                	addi	a5,a5,1
  f2:	fff5c703          	lbu	a4,-1(a1)
  f6:	fee78fa3          	sb	a4,-1(a5)
  fa:	fb75                	bnez	a4,ee <strcpy+0x8>
    ;
  return os;
}
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret

0000000000000102 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cb91                	beqz	a5,120 <strcmp+0x1e>
 10e:	0005c703          	lbu	a4,0(a1)
 112:	00f71763          	bne	a4,a5,120 <strcmp+0x1e>
    p++, q++;
 116:	0505                	addi	a0,a0,1
 118:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	fbe5                	bnez	a5,10e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 120:	0005c503          	lbu	a0,0(a1)
}
 124:	40a7853b          	subw	a0,a5,a0
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strlen>:

uint
strlen(const char *s)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 134:	00054783          	lbu	a5,0(a0)
 138:	cf91                	beqz	a5,154 <strlen+0x26>
 13a:	0505                	addi	a0,a0,1
 13c:	87aa                	mv	a5,a0
 13e:	86be                	mv	a3,a5
 140:	0785                	addi	a5,a5,1
 142:	fff7c703          	lbu	a4,-1(a5)
 146:	ff65                	bnez	a4,13e <strlen+0x10>
 148:	40a6853b          	subw	a0,a3,a0
 14c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret
  for(n = 0; s[n]; n++)
 154:	4501                	li	a0,0
 156:	bfe5                	j	14e <strlen+0x20>

0000000000000158 <memset>:

void*
memset(void *dst, int c, uint n)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e422                	sd	s0,8(sp)
 15c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15e:	ca19                	beqz	a2,174 <memset+0x1c>
 160:	87aa                	mv	a5,a0
 162:	1602                	slli	a2,a2,0x20
 164:	9201                	srli	a2,a2,0x20
 166:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 16e:	0785                	addi	a5,a5,1
 170:	fee79de3          	bne	a5,a4,16a <memset+0x12>
  }
  return dst;
}
 174:	6422                	ld	s0,8(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret

000000000000017a <strchr>:

char*
strchr(const char *s, char c)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 180:	00054783          	lbu	a5,0(a0)
 184:	cb99                	beqz	a5,19a <strchr+0x20>
    if(*s == c)
 186:	00f58763          	beq	a1,a5,194 <strchr+0x1a>
  for(; *s; s++)
 18a:	0505                	addi	a0,a0,1
 18c:	00054783          	lbu	a5,0(a0)
 190:	fbfd                	bnez	a5,186 <strchr+0xc>
      return (char*)s;
  return 0;
 192:	4501                	li	a0,0
}
 194:	6422                	ld	s0,8(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret
  return 0;
 19a:	4501                	li	a0,0
 19c:	bfe5                	j	194 <strchr+0x1a>

000000000000019e <gets>:

char*
gets(char *buf, int max)
{
 19e:	711d                	addi	sp,sp,-96
 1a0:	ec86                	sd	ra,88(sp)
 1a2:	e8a2                	sd	s0,80(sp)
 1a4:	e4a6                	sd	s1,72(sp)
 1a6:	e0ca                	sd	s2,64(sp)
 1a8:	fc4e                	sd	s3,56(sp)
 1aa:	f852                	sd	s4,48(sp)
 1ac:	f456                	sd	s5,40(sp)
 1ae:	f05a                	sd	s6,32(sp)
 1b0:	ec5e                	sd	s7,24(sp)
 1b2:	1080                	addi	s0,sp,96
 1b4:	8baa                	mv	s7,a0
 1b6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b8:	892a                	mv	s2,a0
 1ba:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1bc:	4aa9                	li	s5,10
 1be:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c0:	89a6                	mv	s3,s1
 1c2:	2485                	addiw	s1,s1,1
 1c4:	0344d663          	bge	s1,s4,1f0 <gets+0x52>
    cc = read(0, &c, 1);
 1c8:	4605                	li	a2,1
 1ca:	faf40593          	addi	a1,s0,-81
 1ce:	4501                	li	a0,0
 1d0:	1b2000ef          	jal	382 <read>
    if(cc < 1)
 1d4:	00a05e63          	blez	a0,1f0 <gets+0x52>
    buf[i++] = c;
 1d8:	faf44783          	lbu	a5,-81(s0)
 1dc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e0:	01578763          	beq	a5,s5,1ee <gets+0x50>
 1e4:	0905                	addi	s2,s2,1
 1e6:	fd679de3          	bne	a5,s6,1c0 <gets+0x22>
    buf[i++] = c;
 1ea:	89a6                	mv	s3,s1
 1ec:	a011                	j	1f0 <gets+0x52>
 1ee:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f0:	99de                	add	s3,s3,s7
 1f2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f6:	855e                	mv	a0,s7
 1f8:	60e6                	ld	ra,88(sp)
 1fa:	6446                	ld	s0,80(sp)
 1fc:	64a6                	ld	s1,72(sp)
 1fe:	6906                	ld	s2,64(sp)
 200:	79e2                	ld	s3,56(sp)
 202:	7a42                	ld	s4,48(sp)
 204:	7aa2                	ld	s5,40(sp)
 206:	7b02                	ld	s6,32(sp)
 208:	6be2                	ld	s7,24(sp)
 20a:	6125                	addi	sp,sp,96
 20c:	8082                	ret

000000000000020e <stat>:

int
stat(const char *n, struct stat *st)
{
 20e:	1101                	addi	sp,sp,-32
 210:	ec06                	sd	ra,24(sp)
 212:	e822                	sd	s0,16(sp)
 214:	e04a                	sd	s2,0(sp)
 216:	1000                	addi	s0,sp,32
 218:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21a:	4581                	li	a1,0
 21c:	18e000ef          	jal	3aa <open>
  if(fd < 0)
 220:	02054263          	bltz	a0,244 <stat+0x36>
 224:	e426                	sd	s1,8(sp)
 226:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 228:	85ca                	mv	a1,s2
 22a:	198000ef          	jal	3c2 <fstat>
 22e:	892a                	mv	s2,a0
  close(fd);
 230:	8526                	mv	a0,s1
 232:	160000ef          	jal	392 <close>
  return r;
 236:	64a2                	ld	s1,8(sp)
}
 238:	854a                	mv	a0,s2
 23a:	60e2                	ld	ra,24(sp)
 23c:	6442                	ld	s0,16(sp)
 23e:	6902                	ld	s2,0(sp)
 240:	6105                	addi	sp,sp,32
 242:	8082                	ret
    return -1;
 244:	597d                	li	s2,-1
 246:	bfcd                	j	238 <stat+0x2a>

0000000000000248 <atoi>:

int
atoi(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24e:	00054683          	lbu	a3,0(a0)
 252:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x5d0>
 256:	0ff7f793          	zext.b	a5,a5
 25a:	4625                	li	a2,9
 25c:	02f66863          	bltu	a2,a5,28c <atoi+0x44>
 260:	872a                	mv	a4,a0
  n = 0;
 262:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 264:	0705                	addi	a4,a4,1 # ffffffffffffe001 <base+0xffffffffffffcff1>
 266:	0025179b          	slliw	a5,a0,0x2
 26a:	9fa9                	addw	a5,a5,a0
 26c:	0017979b          	slliw	a5,a5,0x1
 270:	9fb5                	addw	a5,a5,a3
 272:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 276:	00074683          	lbu	a3,0(a4)
 27a:	fd06879b          	addiw	a5,a3,-48
 27e:	0ff7f793          	zext.b	a5,a5
 282:	fef671e3          	bgeu	a2,a5,264 <atoi+0x1c>
  return n;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
  n = 0;
 28c:	4501                	li	a0,0
 28e:	bfe5                	j	286 <atoi+0x3e>

0000000000000290 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 296:	02b57463          	bgeu	a0,a1,2be <memmove+0x2e>
    while(n-- > 0)
 29a:	00c05f63          	blez	a2,2b8 <memmove+0x28>
 29e:	1602                	slli	a2,a2,0x20
 2a0:	9201                	srli	a2,a2,0x20
 2a2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a8:	0585                	addi	a1,a1,1
 2aa:	0705                	addi	a4,a4,1
 2ac:	fff5c683          	lbu	a3,-1(a1)
 2b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b4:	fef71ae3          	bne	a4,a5,2a8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
    dst += n;
 2be:	00c50733          	add	a4,a0,a2
    src += n;
 2c2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c4:	fec05ae3          	blez	a2,2b8 <memmove+0x28>
 2c8:	fff6079b          	addiw	a5,a2,-1
 2cc:	1782                	slli	a5,a5,0x20
 2ce:	9381                	srli	a5,a5,0x20
 2d0:	fff7c793          	not	a5,a5
 2d4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d6:	15fd                	addi	a1,a1,-1
 2d8:	177d                	addi	a4,a4,-1
 2da:	0005c683          	lbu	a3,0(a1)
 2de:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e2:	fee79ae3          	bne	a5,a4,2d6 <memmove+0x46>
 2e6:	bfc9                	j	2b8 <memmove+0x28>

00000000000002e8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ee:	ca05                	beqz	a2,31e <memcmp+0x36>
 2f0:	fff6069b          	addiw	a3,a2,-1
 2f4:	1682                	slli	a3,a3,0x20
 2f6:	9281                	srli	a3,a3,0x20
 2f8:	0685                	addi	a3,a3,1
 2fa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fc:	00054783          	lbu	a5,0(a0)
 300:	0005c703          	lbu	a4,0(a1)
 304:	00e79863          	bne	a5,a4,314 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 308:	0505                	addi	a0,a0,1
    p2++;
 30a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30c:	fed518e3          	bne	a0,a3,2fc <memcmp+0x14>
  }
  return 0;
 310:	4501                	li	a0,0
 312:	a019                	j	318 <memcmp+0x30>
      return *p1 - *p2;
 314:	40e7853b          	subw	a0,a5,a4
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
  return 0;
 31e:	4501                	li	a0,0
 320:	bfe5                	j	318 <memcmp+0x30>

0000000000000322 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 322:	1141                	addi	sp,sp,-16
 324:	e406                	sd	ra,8(sp)
 326:	e022                	sd	s0,0(sp)
 328:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32a:	f67ff0ef          	jal	290 <memmove>
}
 32e:	60a2                	ld	ra,8(sp)
 330:	6402                	ld	s0,0(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret

0000000000000336 <sbrk>:

char *
sbrk(int n) {
 336:	1141                	addi	sp,sp,-16
 338:	e406                	sd	ra,8(sp)
 33a:	e022                	sd	s0,0(sp)
 33c:	0800                	addi	s0,sp,16
  // Eager allocation by default to preserve original xv6 semantics
  // relied upon by many user programs and tests (e.g., countfree).
  return sys_sbrk(n, SBRK_EAGER);
 33e:	4585                	li	a1,1
 340:	0b2000ef          	jal	3f2 <sys_sbrk>
}
 344:	60a2                	ld	ra,8(sp)
 346:	6402                	ld	s0,0(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret

000000000000034c <sbrklazy>:

char *
sbrklazy(int n) {
 34c:	1141                	addi	sp,sp,-16
 34e:	e406                	sd	ra,8(sp)
 350:	e022                	sd	s0,0(sp)
 352:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 354:	4589                	li	a1,2
 356:	09c000ef          	jal	3f2 <sys_sbrk>
}
 35a:	60a2                	ld	ra,8(sp)
 35c:	6402                	ld	s0,0(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret

0000000000000362 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 362:	4885                	li	a7,1
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <exit>:
.global exit
exit:
 li a7, SYS_exit
 36a:	4889                	li	a7,2
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <wait>:
.global wait
wait:
 li a7, SYS_wait
 372:	488d                	li	a7,3
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37a:	4891                	li	a7,4
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <read>:
.global read
read:
 li a7, SYS_read
 382:	4895                	li	a7,5
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <write>:
.global write
write:
 li a7, SYS_write
 38a:	48c1                	li	a7,16
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <close>:
.global close
close:
 li a7, SYS_close
 392:	48d5                	li	a7,21
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <kill>:
.global kill
kill:
 li a7, SYS_kill
 39a:	4899                	li	a7,6
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a2:	489d                	li	a7,7
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <open>:
.global open
open:
 li a7, SYS_open
 3aa:	48bd                	li	a7,15
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b2:	48c5                	li	a7,17
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ba:	48c9                	li	a7,18
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c2:	48a1                	li	a7,8
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <link>:
.global link
link:
 li a7, SYS_link
 3ca:	48cd                	li	a7,19
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d2:	48d1                	li	a7,20
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3da:	48a5                	li	a7,9
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e2:	48a9                	li	a7,10
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ea:	48ad                	li	a7,11
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3f2:	48b1                	li	a7,12
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <pause>:
.global pause
pause:
 li a7, SYS_pause
 3fa:	48b5                	li	a7,13
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 402:	48b9                	li	a7,14
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 40a:	48d9                	li	a7,22
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 412:	1101                	addi	sp,sp,-32
 414:	ec06                	sd	ra,24(sp)
 416:	e822                	sd	s0,16(sp)
 418:	1000                	addi	s0,sp,32
 41a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41e:	4605                	li	a2,1
 420:	fef40593          	addi	a1,s0,-17
 424:	f67ff0ef          	jal	38a <write>
}
 428:	60e2                	ld	ra,24(sp)
 42a:	6442                	ld	s0,16(sp)
 42c:	6105                	addi	sp,sp,32
 42e:	8082                	ret

0000000000000430 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 430:	715d                	addi	sp,sp,-80
 432:	e486                	sd	ra,72(sp)
 434:	e0a2                	sd	s0,64(sp)
 436:	f84a                	sd	s2,48(sp)
 438:	0880                	addi	s0,sp,80
 43a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 43c:	c299                	beqz	a3,442 <printint+0x12>
 43e:	0805c363          	bltz	a1,4c4 <printint+0x94>
  neg = 0;
 442:	4881                	li	a7,0
 444:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 448:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 44a:	00000517          	auipc	a0,0x0
 44e:	5b650513          	addi	a0,a0,1462 # a00 <digits>
 452:	883e                	mv	a6,a5
 454:	2785                	addiw	a5,a5,1
 456:	02c5f733          	remu	a4,a1,a2
 45a:	972a                	add	a4,a4,a0
 45c:	00074703          	lbu	a4,0(a4)
 460:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 464:	872e                	mv	a4,a1
 466:	02c5d5b3          	divu	a1,a1,a2
 46a:	0685                	addi	a3,a3,1
 46c:	fec773e3          	bgeu	a4,a2,452 <printint+0x22>
  if(neg)
 470:	00088b63          	beqz	a7,486 <printint+0x56>
    buf[i++] = '-';
 474:	fd078793          	addi	a5,a5,-48
 478:	97a2                	add	a5,a5,s0
 47a:	02d00713          	li	a4,45
 47e:	fee78423          	sb	a4,-24(a5)
 482:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 486:	02f05a63          	blez	a5,4ba <printint+0x8a>
 48a:	fc26                	sd	s1,56(sp)
 48c:	f44e                	sd	s3,40(sp)
 48e:	fb840713          	addi	a4,s0,-72
 492:	00f704b3          	add	s1,a4,a5
 496:	fff70993          	addi	s3,a4,-1
 49a:	99be                	add	s3,s3,a5
 49c:	37fd                	addiw	a5,a5,-1
 49e:	1782                	slli	a5,a5,0x20
 4a0:	9381                	srli	a5,a5,0x20
 4a2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4a6:	fff4c583          	lbu	a1,-1(s1)
 4aa:	854a                	mv	a0,s2
 4ac:	f67ff0ef          	jal	412 <putc>
  while(--i >= 0)
 4b0:	14fd                	addi	s1,s1,-1
 4b2:	ff349ae3          	bne	s1,s3,4a6 <printint+0x76>
 4b6:	74e2                	ld	s1,56(sp)
 4b8:	79a2                	ld	s3,40(sp)
}
 4ba:	60a6                	ld	ra,72(sp)
 4bc:	6406                	ld	s0,64(sp)
 4be:	7942                	ld	s2,48(sp)
 4c0:	6161                	addi	sp,sp,80
 4c2:	8082                	ret
    x = -xx;
 4c4:	40b005b3          	neg	a1,a1
    neg = 1;
 4c8:	4885                	li	a7,1
    x = -xx;
 4ca:	bfad                	j	444 <printint+0x14>

00000000000004cc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4cc:	711d                	addi	sp,sp,-96
 4ce:	ec86                	sd	ra,88(sp)
 4d0:	e8a2                	sd	s0,80(sp)
 4d2:	e0ca                	sd	s2,64(sp)
 4d4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d6:	0005c903          	lbu	s2,0(a1)
 4da:	28090663          	beqz	s2,766 <vprintf+0x29a>
 4de:	e4a6                	sd	s1,72(sp)
 4e0:	fc4e                	sd	s3,56(sp)
 4e2:	f852                	sd	s4,48(sp)
 4e4:	f456                	sd	s5,40(sp)
 4e6:	f05a                	sd	s6,32(sp)
 4e8:	ec5e                	sd	s7,24(sp)
 4ea:	e862                	sd	s8,16(sp)
 4ec:	e466                	sd	s9,8(sp)
 4ee:	8b2a                	mv	s6,a0
 4f0:	8a2e                	mv	s4,a1
 4f2:	8bb2                	mv	s7,a2
  state = 0;
 4f4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f6:	4481                	li	s1,0
 4f8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4fa:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4fe:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 502:	06c00c93          	li	s9,108
 506:	a005                	j	526 <vprintf+0x5a>
        putc(fd, c0);
 508:	85ca                	mv	a1,s2
 50a:	855a                	mv	a0,s6
 50c:	f07ff0ef          	jal	412 <putc>
 510:	a019                	j	516 <vprintf+0x4a>
    } else if(state == '%'){
 512:	03598263          	beq	s3,s5,536 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 516:	2485                	addiw	s1,s1,1
 518:	8726                	mv	a4,s1
 51a:	009a07b3          	add	a5,s4,s1
 51e:	0007c903          	lbu	s2,0(a5)
 522:	22090a63          	beqz	s2,756 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 526:	0009079b          	sext.w	a5,s2
    if(state == 0){
 52a:	fe0994e3          	bnez	s3,512 <vprintf+0x46>
      if(c0 == '%'){
 52e:	fd579de3          	bne	a5,s5,508 <vprintf+0x3c>
        state = '%';
 532:	89be                	mv	s3,a5
 534:	b7cd                	j	516 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 536:	00ea06b3          	add	a3,s4,a4
 53a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 53e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 540:	c681                	beqz	a3,548 <vprintf+0x7c>
 542:	9752                	add	a4,a4,s4
 544:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 548:	05878363          	beq	a5,s8,58e <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 54c:	05978d63          	beq	a5,s9,5a6 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 550:	07500713          	li	a4,117
 554:	0ee78763          	beq	a5,a4,642 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 558:	07800713          	li	a4,120
 55c:	12e78963          	beq	a5,a4,68e <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 560:	07000713          	li	a4,112
 564:	14e78e63          	beq	a5,a4,6c0 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 568:	06300713          	li	a4,99
 56c:	18e78e63          	beq	a5,a4,708 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 570:	07300713          	li	a4,115
 574:	1ae78463          	beq	a5,a4,71c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 578:	02500713          	li	a4,37
 57c:	04e79563          	bne	a5,a4,5c6 <vprintf+0xfa>
        putc(fd, '%');
 580:	02500593          	li	a1,37
 584:	855a                	mv	a0,s6
 586:	e8dff0ef          	jal	412 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 58a:	4981                	li	s3,0
 58c:	b769                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 58e:	008b8913          	addi	s2,s7,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000ba583          	lw	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	e95ff0ef          	jal	430 <printint>
 5a0:	8bca                	mv	s7,s2
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	bf8d                	j	516 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5a6:	06400793          	li	a5,100
 5aa:	02f68963          	beq	a3,a5,5dc <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ae:	06c00793          	li	a5,108
 5b2:	04f68263          	beq	a3,a5,5f6 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5b6:	07500793          	li	a5,117
 5ba:	0af68063          	beq	a3,a5,65a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5be:	07800793          	li	a5,120
 5c2:	0ef68263          	beq	a3,a5,6a6 <vprintf+0x1da>
        putc(fd, '%');
 5c6:	02500593          	li	a1,37
 5ca:	855a                	mv	a0,s6
 5cc:	e47ff0ef          	jal	412 <putc>
        putc(fd, c0);
 5d0:	85ca                	mv	a1,s2
 5d2:	855a                	mv	a0,s6
 5d4:	e3fff0ef          	jal	412 <putc>
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	bf35                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5dc:	008b8913          	addi	s2,s7,8
 5e0:	4685                	li	a3,1
 5e2:	4629                	li	a2,10
 5e4:	000bb583          	ld	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	e47ff0ef          	jal	430 <printint>
        i += 1;
 5ee:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
        i += 1;
 5f4:	b70d                	j	516 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f6:	06400793          	li	a5,100
 5fa:	02f60763          	beq	a2,a5,628 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5fe:	07500793          	li	a5,117
 602:	06f60963          	beq	a2,a5,674 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 606:	07800793          	li	a5,120
 60a:	faf61ee3          	bne	a2,a5,5c6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 60e:	008b8913          	addi	s2,s7,8
 612:	4681                	li	a3,0
 614:	4641                	li	a2,16
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	e15ff0ef          	jal	430 <printint>
        i += 2;
 620:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 2;
 626:	bdc5                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 628:	008b8913          	addi	s2,s7,8
 62c:	4685                	li	a3,1
 62e:	4629                	li	a2,10
 630:	000bb583          	ld	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	dfbff0ef          	jal	430 <printint>
        i += 2;
 63a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 63c:	8bca                	mv	s7,s2
      state = 0;
 63e:	4981                	li	s3,0
        i += 2;
 640:	bdd9                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 642:	008b8913          	addi	s2,s7,8
 646:	4681                	li	a3,0
 648:	4629                	li	a2,10
 64a:	000be583          	lwu	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	de1ff0ef          	jal	430 <printint>
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	bd7d                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4681                	li	a3,0
 660:	4629                	li	a2,10
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	dc9ff0ef          	jal	430 <printint>
        i += 1;
 66c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
        i += 1;
 672:	b555                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4629                	li	a2,10
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	dafff0ef          	jal	430 <printint>
        i += 2;
 686:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	8bca                	mv	s7,s2
      state = 0;
 68a:	4981                	li	s3,0
        i += 2;
 68c:	b569                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 68e:	008b8913          	addi	s2,s7,8
 692:	4681                	li	a3,0
 694:	4641                	li	a2,16
 696:	000be583          	lwu	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	d95ff0ef          	jal	430 <printint>
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bd8d                	j	516 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4641                	li	a2,16
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	d7dff0ef          	jal	430 <printint>
        i += 1;
 6b8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 1;
 6be:	bda1                	j	516 <vprintf+0x4a>
 6c0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6c2:	008b8d13          	addi	s10,s7,8
 6c6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ca:	03000593          	li	a1,48
 6ce:	855a                	mv	a0,s6
 6d0:	d43ff0ef          	jal	412 <putc>
  putc(fd, 'x');
 6d4:	07800593          	li	a1,120
 6d8:	855a                	mv	a0,s6
 6da:	d39ff0ef          	jal	412 <putc>
 6de:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e0:	00000b97          	auipc	s7,0x0
 6e4:	320b8b93          	addi	s7,s7,800 # a00 <digits>
 6e8:	03c9d793          	srli	a5,s3,0x3c
 6ec:	97de                	add	a5,a5,s7
 6ee:	0007c583          	lbu	a1,0(a5)
 6f2:	855a                	mv	a0,s6
 6f4:	d1fff0ef          	jal	412 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f8:	0992                	slli	s3,s3,0x4
 6fa:	397d                	addiw	s2,s2,-1
 6fc:	fe0916e3          	bnez	s2,6e8 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 700:	8bea                	mv	s7,s10
      state = 0;
 702:	4981                	li	s3,0
 704:	6d02                	ld	s10,0(sp)
 706:	bd01                	j	516 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 708:	008b8913          	addi	s2,s7,8
 70c:	000bc583          	lbu	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	d01ff0ef          	jal	412 <putc>
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
 71a:	bbf5                	j	516 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 71c:	008b8993          	addi	s3,s7,8
 720:	000bb903          	ld	s2,0(s7)
 724:	00090f63          	beqz	s2,742 <vprintf+0x276>
        for(; *s; s++)
 728:	00094583          	lbu	a1,0(s2)
 72c:	c195                	beqz	a1,750 <vprintf+0x284>
          putc(fd, *s);
 72e:	855a                	mv	a0,s6
 730:	ce3ff0ef          	jal	412 <putc>
        for(; *s; s++)
 734:	0905                	addi	s2,s2,1
 736:	00094583          	lbu	a1,0(s2)
 73a:	f9f5                	bnez	a1,72e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 73c:	8bce                	mv	s7,s3
      state = 0;
 73e:	4981                	li	s3,0
 740:	bbd9                	j	516 <vprintf+0x4a>
          s = "(null)";
 742:	00000917          	auipc	s2,0x0
 746:	2b690913          	addi	s2,s2,694 # 9f8 <malloc+0x1aa>
        for(; *s; s++)
 74a:	02800593          	li	a1,40
 74e:	b7c5                	j	72e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 750:	8bce                	mv	s7,s3
      state = 0;
 752:	4981                	li	s3,0
 754:	b3c9                	j	516 <vprintf+0x4a>
 756:	64a6                	ld	s1,72(sp)
 758:	79e2                	ld	s3,56(sp)
 75a:	7a42                	ld	s4,48(sp)
 75c:	7aa2                	ld	s5,40(sp)
 75e:	7b02                	ld	s6,32(sp)
 760:	6be2                	ld	s7,24(sp)
 762:	6c42                	ld	s8,16(sp)
 764:	6ca2                	ld	s9,8(sp)
    }
  }
}
 766:	60e6                	ld	ra,88(sp)
 768:	6446                	ld	s0,80(sp)
 76a:	6906                	ld	s2,64(sp)
 76c:	6125                	addi	sp,sp,96
 76e:	8082                	ret

0000000000000770 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 770:	715d                	addi	sp,sp,-80
 772:	ec06                	sd	ra,24(sp)
 774:	e822                	sd	s0,16(sp)
 776:	1000                	addi	s0,sp,32
 778:	e010                	sd	a2,0(s0)
 77a:	e414                	sd	a3,8(s0)
 77c:	e818                	sd	a4,16(s0)
 77e:	ec1c                	sd	a5,24(s0)
 780:	03043023          	sd	a6,32(s0)
 784:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 788:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78c:	8622                	mv	a2,s0
 78e:	d3fff0ef          	jal	4cc <vprintf>
}
 792:	60e2                	ld	ra,24(sp)
 794:	6442                	ld	s0,16(sp)
 796:	6161                	addi	sp,sp,80
 798:	8082                	ret

000000000000079a <printf>:

void
printf(const char *fmt, ...)
{
 79a:	711d                	addi	sp,sp,-96
 79c:	ec06                	sd	ra,24(sp)
 79e:	e822                	sd	s0,16(sp)
 7a0:	1000                	addi	s0,sp,32
 7a2:	e40c                	sd	a1,8(s0)
 7a4:	e810                	sd	a2,16(s0)
 7a6:	ec14                	sd	a3,24(s0)
 7a8:	f018                	sd	a4,32(s0)
 7aa:	f41c                	sd	a5,40(s0)
 7ac:	03043823          	sd	a6,48(s0)
 7b0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b4:	00840613          	addi	a2,s0,8
 7b8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7bc:	85aa                	mv	a1,a0
 7be:	4505                	li	a0,1
 7c0:	d0dff0ef          	jal	4cc <vprintf>
}
 7c4:	60e2                	ld	ra,24(sp)
 7c6:	6442                	ld	s0,16(sp)
 7c8:	6125                	addi	sp,sp,96
 7ca:	8082                	ret

00000000000007cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7cc:	1141                	addi	sp,sp,-16
 7ce:	e422                	sd	s0,8(sp)
 7d0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	00001797          	auipc	a5,0x1
 7da:	82a7b783          	ld	a5,-2006(a5) # 1000 <freep>
 7de:	a02d                	j	808 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e0:	4618                	lw	a4,8(a2)
 7e2:	9f2d                	addw	a4,a4,a1
 7e4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e8:	6398                	ld	a4,0(a5)
 7ea:	6310                	ld	a2,0(a4)
 7ec:	a83d                	j	82a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ee:	ff852703          	lw	a4,-8(a0)
 7f2:	9f31                	addw	a4,a4,a2
 7f4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f6:	ff053683          	ld	a3,-16(a0)
 7fa:	a091                	j	83e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fc:	6398                	ld	a4,0(a5)
 7fe:	00e7e463          	bltu	a5,a4,806 <free+0x3a>
 802:	00e6ea63          	bltu	a3,a4,816 <free+0x4a>
{
 806:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 808:	fed7fae3          	bgeu	a5,a3,7fc <free+0x30>
 80c:	6398                	ld	a4,0(a5)
 80e:	00e6e463          	bltu	a3,a4,816 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 812:	fee7eae3          	bltu	a5,a4,806 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 816:	ff852583          	lw	a1,-8(a0)
 81a:	6390                	ld	a2,0(a5)
 81c:	02059813          	slli	a6,a1,0x20
 820:	01c85713          	srli	a4,a6,0x1c
 824:	9736                	add	a4,a4,a3
 826:	fae60de3          	beq	a2,a4,7e0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 82a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 82e:	4790                	lw	a2,8(a5)
 830:	02061593          	slli	a1,a2,0x20
 834:	01c5d713          	srli	a4,a1,0x1c
 838:	973e                	add	a4,a4,a5
 83a:	fae68ae3          	beq	a3,a4,7ee <free+0x22>
    p->s.ptr = bp->s.ptr;
 83e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 840:	00000717          	auipc	a4,0x0
 844:	7cf73023          	sd	a5,1984(a4) # 1000 <freep>
}
 848:	6422                	ld	s0,8(sp)
 84a:	0141                	addi	sp,sp,16
 84c:	8082                	ret

000000000000084e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 84e:	7139                	addi	sp,sp,-64
 850:	fc06                	sd	ra,56(sp)
 852:	f822                	sd	s0,48(sp)
 854:	f426                	sd	s1,40(sp)
 856:	ec4e                	sd	s3,24(sp)
 858:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85a:	02051493          	slli	s1,a0,0x20
 85e:	9081                	srli	s1,s1,0x20
 860:	04bd                	addi	s1,s1,15
 862:	8091                	srli	s1,s1,0x4
 864:	0014899b          	addiw	s3,s1,1
 868:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 86a:	00000517          	auipc	a0,0x0
 86e:	79653503          	ld	a0,1942(a0) # 1000 <freep>
 872:	c915                	beqz	a0,8a6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 874:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 876:	4798                	lw	a4,8(a5)
 878:	08977a63          	bgeu	a4,s1,90c <malloc+0xbe>
 87c:	f04a                	sd	s2,32(sp)
 87e:	e852                	sd	s4,16(sp)
 880:	e456                	sd	s5,8(sp)
 882:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 884:	8a4e                	mv	s4,s3
 886:	0009871b          	sext.w	a4,s3
 88a:	6685                	lui	a3,0x1
 88c:	00d77363          	bgeu	a4,a3,892 <malloc+0x44>
 890:	6a05                	lui	s4,0x1
 892:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 896:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 89a:	00000917          	auipc	s2,0x0
 89e:	76690913          	addi	s2,s2,1894 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a2:	5afd                	li	s5,-1
 8a4:	a081                	j	8e4 <malloc+0x96>
 8a6:	f04a                	sd	s2,32(sp)
 8a8:	e852                	sd	s4,16(sp)
 8aa:	e456                	sd	s5,8(sp)
 8ac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ae:	00000797          	auipc	a5,0x0
 8b2:	76278793          	addi	a5,a5,1890 # 1010 <base>
 8b6:	00000717          	auipc	a4,0x0
 8ba:	74f73523          	sd	a5,1866(a4) # 1000 <freep>
 8be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c4:	b7c1                	j	884 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8c6:	6398                	ld	a4,0(a5)
 8c8:	e118                	sd	a4,0(a0)
 8ca:	a8a9                	j	924 <malloc+0xd6>
  hp->s.size = nu;
 8cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d0:	0541                	addi	a0,a0,16
 8d2:	efbff0ef          	jal	7cc <free>
  return freep;
 8d6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8da:	c12d                	beqz	a0,93c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8de:	4798                	lw	a4,8(a5)
 8e0:	02977263          	bgeu	a4,s1,904 <malloc+0xb6>
    if(p == freep)
 8e4:	00093703          	ld	a4,0(s2)
 8e8:	853e                	mv	a0,a5
 8ea:	fef719e3          	bne	a4,a5,8dc <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8ee:	8552                	mv	a0,s4
 8f0:	a47ff0ef          	jal	336 <sbrk>
  if(p == SBRK_ERROR)
 8f4:	fd551ce3          	bne	a0,s5,8cc <malloc+0x7e>
        return 0;
 8f8:	4501                	li	a0,0
 8fa:	7902                	ld	s2,32(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
 902:	a03d                	j	930 <malloc+0xe2>
 904:	7902                	ld	s2,32(sp)
 906:	6a42                	ld	s4,16(sp)
 908:	6aa2                	ld	s5,8(sp)
 90a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 90c:	fae48de3          	beq	s1,a4,8c6 <malloc+0x78>
        p->s.size -= nunits;
 910:	4137073b          	subw	a4,a4,s3
 914:	c798                	sw	a4,8(a5)
        p += p->s.size;
 916:	02071693          	slli	a3,a4,0x20
 91a:	01c6d713          	srli	a4,a3,0x1c
 91e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 920:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 924:	00000717          	auipc	a4,0x0
 928:	6ca73e23          	sd	a0,1756(a4) # 1000 <freep>
      return (void*)(p + 1);
 92c:	01078513          	addi	a0,a5,16
  }
}
 930:	70e2                	ld	ra,56(sp)
 932:	7442                	ld	s0,48(sp)
 934:	74a2                	ld	s1,40(sp)
 936:	69e2                	ld	s3,24(sp)
 938:	6121                	addi	sp,sp,64
 93a:	8082                	ret
 93c:	7902                	ld	s2,32(sp)
 93e:	6a42                	ld	s4,16(sp)
 940:	6aa2                	ld	s5,8(sp)
 942:	6b02                	ld	s6,0(sp)
 944:	b7f5                	j	930 <malloc+0xe2>
