
user/_test_swapmix:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define PGSIZE 4096

// Mix clean and dirty pages to provoke both DISCARD (clean) and SWAPOUT/SWAPIN (dirty).
int
main(void)
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	0880                	addi	s0,sp,80
  printf("[test_swapmix] start\n");
   8:	00001517          	auipc	a0,0x1
   c:	9d850513          	addi	a0,a0,-1576 # 9e0 <malloc+0xf8>
  10:	025000ef          	jal	834 <printf>
  // Natural eviction: rely on RAM exhaustion (PHYSTOP / QEMU -m)

  int n = 3900; // total pages in first wave
  char *base = sbrklazy(n * PGSIZE);
  14:	00f3c537          	lui	a0,0xf3c
  18:	3ce000ef          	jal	3e6 <sbrklazy>
  if(base == (char*)-1){
  1c:	57fd                	li	a5,-1
  1e:	02f50a63          	beq	a0,a5,52 <main+0x52>
  22:	fc26                	sd	s1,56(sp)
  24:	f84a                	sd	s2,48(sp)
  26:	f44e                	sd	s3,40(sp)
  28:	f052                	sd	s4,32(sp)
  2a:	ec56                	sd	s5,24(sp)
  2c:	892a                	mv	s2,a0
  }

  
  
  // Touch pages: even = dirty (write pattern), odd = clean (read-only)
  printf("[test_swapmix] touching %d pages (even=dirty, odd=clean)\n", n);
  2e:	6585                	lui	a1,0x1
  30:	f3c58593          	addi	a1,a1,-196 # f3c <digits+0x3cc>
  34:	00001517          	auipc	a0,0x1
  38:	9ec50513          	addi	a0,a0,-1556 # a20 <malloc+0x138>
  3c:	7f8000ef          	jal	834 <printf>
  volatile int sink = 0;
  40:	fa042e23          	sw	zero,-68(s0)
  for(int i = 0; i < n; i++){
  44:	8aca                	mv	s5,s2
  46:	4481                	li	s1,0
  48:	6a05                	lui	s4,0x1
  4a:	6985                	lui	s3,0x1
  4c:	f3c98993          	addi	s3,s3,-196 # f3c <digits+0x3cc>
  50:	a815                	j	84 <main+0x84>
  52:	fc26                	sd	s1,56(sp)
  54:	f84a                	sd	s2,48(sp)
  56:	f44e                	sd	s3,40(sp)
  58:	f052                	sd	s4,32(sp)
  5a:	ec56                	sd	s5,24(sp)
    printf("[test_swapmix] sbrklazy failed\n");
  5c:	00001517          	auipc	a0,0x1
  60:	9a450513          	addi	a0,a0,-1628 # a00 <malloc+0x118>
  64:	7d0000ef          	jal	834 <printf>
    exit(1);
  68:	4505                	li	a0,1
  6a:	39a000ef          	jal	404 <exit>
      memstat();
    if((i & 1) == 0){
      base[i*PGSIZE] = (char)(i & 0x7f);
    } else {
      sink += base[i*PGSIZE]; // read-only: keep clean
  6e:	fbc42703          	lw	a4,-68(s0)
  72:	00094783          	lbu	a5,0(s2)
  76:	9fb9                	addw	a5,a5,a4
  78:	faf42e23          	sw	a5,-68(s0)
  for(int i = 0; i < n; i++){
  7c:	2485                	addiw	s1,s1,1
  7e:	9952                	add	s2,s2,s4
  80:	01348c63          	beq	s1,s3,98 <main+0x98>
      memstat();
  84:	420000ef          	jal	4a4 <memstat>
    if((i & 1) == 0){
  88:	0014f793          	andi	a5,s1,1
  8c:	f3ed                	bnez	a5,6e <main+0x6e>
      base[i*PGSIZE] = (char)(i & 0x7f);
  8e:	07f4f793          	andi	a5,s1,127
  92:	00f90023          	sb	a5,0(s2)
  96:	b7dd                	j	7c <main+0x7c>
    }
  }

  // Second wave to force eviction of early pages
  int m = 3900; // more pages to push out earlier ones
  char *base2 = sbrklazy(m * PGSIZE);
  98:	00f3c537          	lui	a0,0xf3c
  9c:	34a000ef          	jal	3e6 <sbrklazy>
  if(base2 == (char*)-1){
  a0:	57fd                	li	a5,-1
  a2:	02f50c63          	beq	a0,a5,da <main+0xda>
  a6:	84aa                	mv	s1,a0
  a8:	00f3c7b7          	lui	a5,0xf3c
  ac:	00f50933          	add	s2,a0,a5
    exit(1);
  }
  for(int i = 0; i < m; i++){
      memstat();
    // write these to ensure pressure and dirty frames too
    base2[i*PGSIZE] = (char)(0x55);
  b0:	05500a13          	li	s4,85
  for(int i = 0; i < m; i++){
  b4:	6985                	lui	s3,0x1
      memstat();
  b6:	3ee000ef          	jal	4a4 <memstat>
    base2[i*PGSIZE] = (char)(0x55);
  ba:	01448023          	sb	s4,0(s1)
  for(int i = 0; i < m; i++){
  be:	94ce                	add	s1,s1,s3
  c0:	ff249be3          	bne	s1,s2,b6 <main+0xb6>
  }

  // Re-access the first 32 pages.
  // Expect: even pages SWAPIN with original pattern; odd pages DISCARDed -> zero page
  printf("[test_swapmix] verifying first 32 pages\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	9c450513          	addi	a0,a0,-1596 # a88 <malloc+0x1a0>
  cc:	768000ef          	jal	834 <printf>
  for(int i = 0; i < 32 && i < n; i++){
  d0:	4481                	li	s1,0
  d2:	6985                	lui	s3,0x1
  d4:	02000913          	li	s2,32
  d8:	a839                	j	f6 <main+0xf6>
    printf("[test_swapmix] second sbrklazy failed\n");
  da:	00001517          	auipc	a0,0x1
  de:	98650513          	addi	a0,a0,-1658 # a60 <malloc+0x178>
  e2:	752000ef          	jal	834 <printf>
    exit(1);
  e6:	4505                	li	a0,1
  e8:	31c000ef          	jal	404 <exit>
        printf("[test_swapmix] dirty page %d mismatch: got %d want %d\n", i, (int)v, (int)want);
        printf("TEST FAILED\n");
        exit(1);
      }
    } else {
      if(v != 0){
  ec:	e229                	bnez	a2,12e <main+0x12e>
  for(int i = 0; i < 32 && i < n; i++){
  ee:	2485                	addiw	s1,s1,1
  f0:	9ace                	add	s5,s5,s3
  f2:	05248e63          	beq	s1,s2,14e <main+0x14e>
      memstat();
  f6:	3ae000ef          	jal	4a4 <memstat>
    char v = base[i*PGSIZE];
  fa:	000ac603          	lbu	a2,0(s5)
    if((i & 1) == 0){
  fe:	0014f793          	andi	a5,s1,1
 102:	f7ed                	bnez	a5,ec <main+0xec>
      if(v != want){
 104:	0ff4f793          	zext.b	a5,s1
 108:	fef603e3          	beq	a2,a5,ee <main+0xee>
        printf("[test_swapmix] dirty page %d mismatch: got %d want %d\n", i, (int)v, (int)want);
 10c:	86be                	mv	a3,a5
 10e:	85a6                	mv	a1,s1
 110:	00001517          	auipc	a0,0x1
 114:	9a850513          	addi	a0,a0,-1624 # ab8 <malloc+0x1d0>
 118:	71c000ef          	jal	834 <printf>
        printf("TEST FAILED\n");
 11c:	00001517          	auipc	a0,0x1
 120:	9d450513          	addi	a0,a0,-1580 # af0 <malloc+0x208>
 124:	710000ef          	jal	834 <printf>
        exit(1);
 128:	4505                	li	a0,1
 12a:	2da000ef          	jal	404 <exit>
        printf("[test_swapmix] clean page %d expected 0 after DISCARD, got %d\n", i, (int)v);
 12e:	85a6                	mv	a1,s1
 130:	00001517          	auipc	a0,0x1
 134:	9d050513          	addi	a0,a0,-1584 # b00 <malloc+0x218>
 138:	6fc000ef          	jal	834 <printf>
        printf("TEST FAILED\n");
 13c:	00001517          	auipc	a0,0x1
 140:	9b450513          	addi	a0,a0,-1612 # af0 <malloc+0x208>
 144:	6f0000ef          	jal	834 <printf>
        exit(1);
 148:	4505                	li	a0,1
 14a:	2ba000ef          	jal	404 <exit>
      }
    }
  }

  printf("[test_swapmix] sink=%d\n", sink);
 14e:	fbc42583          	lw	a1,-68(s0)
 152:	00001517          	auipc	a0,0x1
 156:	9ee50513          	addi	a0,a0,-1554 # b40 <malloc+0x258>
 15a:	6da000ef          	jal	834 <printf>
  printf("TEST PASSED\n");
 15e:	00001517          	auipc	a0,0x1
 162:	9fa50513          	addi	a0,a0,-1542 # b58 <malloc+0x270>
 166:	6ce000ef          	jal	834 <printf>
  exit(0);
 16a:	4501                	li	a0,0
 16c:	298000ef          	jal	404 <exit>

0000000000000170 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 170:	1141                	addi	sp,sp,-16
 172:	e406                	sd	ra,8(sp)
 174:	e022                	sd	s0,0(sp)
 176:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 178:	e89ff0ef          	jal	0 <main>
  exit(r);
 17c:	288000ef          	jal	404 <exit>

0000000000000180 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 186:	87aa                	mv	a5,a0
 188:	0585                	addi	a1,a1,1
 18a:	0785                	addi	a5,a5,1 # f3c001 <base+0xf3aff1>
 18c:	fff5c703          	lbu	a4,-1(a1)
 190:	fee78fa3          	sb	a4,-1(a5)
 194:	fb75                	bnez	a4,188 <strcpy+0x8>
    ;
  return os;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cb91                	beqz	a5,1ba <strcmp+0x1e>
 1a8:	0005c703          	lbu	a4,0(a1)
 1ac:	00f71763          	bne	a4,a5,1ba <strcmp+0x1e>
    p++, q++;
 1b0:	0505                	addi	a0,a0,1
 1b2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	fbe5                	bnez	a5,1a8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ba:	0005c503          	lbu	a0,0(a1)
}
 1be:	40a7853b          	subw	a0,a5,a0
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret

00000000000001c8 <strlen>:

uint
strlen(const char *s)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	cf91                	beqz	a5,1ee <strlen+0x26>
 1d4:	0505                	addi	a0,a0,1
 1d6:	87aa                	mv	a5,a0
 1d8:	86be                	mv	a3,a5
 1da:	0785                	addi	a5,a5,1
 1dc:	fff7c703          	lbu	a4,-1(a5)
 1e0:	ff65                	bnez	a4,1d8 <strlen+0x10>
 1e2:	40a6853b          	subw	a0,a3,a0
 1e6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
  for(n = 0; s[n]; n++)
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <strlen+0x20>

00000000000001f2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f8:	ca19                	beqz	a2,20e <memset+0x1c>
 1fa:	87aa                	mv	a5,a0
 1fc:	1602                	slli	a2,a2,0x20
 1fe:	9201                	srli	a2,a2,0x20
 200:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 204:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 208:	0785                	addi	a5,a5,1
 20a:	fee79de3          	bne	a5,a4,204 <memset+0x12>
  }
  return dst;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret

0000000000000214 <strchr>:

char*
strchr(const char *s, char c)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  for(; *s; s++)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	cb99                	beqz	a5,234 <strchr+0x20>
    if(*s == c)
 220:	00f58763          	beq	a1,a5,22e <strchr+0x1a>
  for(; *s; s++)
 224:	0505                	addi	a0,a0,1
 226:	00054783          	lbu	a5,0(a0)
 22a:	fbfd                	bnez	a5,220 <strchr+0xc>
      return (char*)s;
  return 0;
 22c:	4501                	li	a0,0
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  return 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <strchr+0x1a>

0000000000000238 <gets>:

char*
gets(char *buf, int max)
{
 238:	711d                	addi	sp,sp,-96
 23a:	ec86                	sd	ra,88(sp)
 23c:	e8a2                	sd	s0,80(sp)
 23e:	e4a6                	sd	s1,72(sp)
 240:	e0ca                	sd	s2,64(sp)
 242:	fc4e                	sd	s3,56(sp)
 244:	f852                	sd	s4,48(sp)
 246:	f456                	sd	s5,40(sp)
 248:	f05a                	sd	s6,32(sp)
 24a:	ec5e                	sd	s7,24(sp)
 24c:	1080                	addi	s0,sp,96
 24e:	8baa                	mv	s7,a0
 250:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 252:	892a                	mv	s2,a0
 254:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 256:	4aa9                	li	s5,10
 258:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25a:	89a6                	mv	s3,s1
 25c:	2485                	addiw	s1,s1,1
 25e:	0344d663          	bge	s1,s4,28a <gets+0x52>
    cc = read(0, &c, 1);
 262:	4605                	li	a2,1
 264:	faf40593          	addi	a1,s0,-81
 268:	4501                	li	a0,0
 26a:	1b2000ef          	jal	41c <read>
    if(cc < 1)
 26e:	00a05e63          	blez	a0,28a <gets+0x52>
    buf[i++] = c;
 272:	faf44783          	lbu	a5,-81(s0)
 276:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27a:	01578763          	beq	a5,s5,288 <gets+0x50>
 27e:	0905                	addi	s2,s2,1
 280:	fd679de3          	bne	a5,s6,25a <gets+0x22>
    buf[i++] = c;
 284:	89a6                	mv	s3,s1
 286:	a011                	j	28a <gets+0x52>
 288:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28a:	99de                	add	s3,s3,s7
 28c:	00098023          	sb	zero,0(s3) # 1000 <freep>
  return buf;
}
 290:	855e                	mv	a0,s7
 292:	60e6                	ld	ra,88(sp)
 294:	6446                	ld	s0,80(sp)
 296:	64a6                	ld	s1,72(sp)
 298:	6906                	ld	s2,64(sp)
 29a:	79e2                	ld	s3,56(sp)
 29c:	7a42                	ld	s4,48(sp)
 29e:	7aa2                	ld	s5,40(sp)
 2a0:	7b02                	ld	s6,32(sp)
 2a2:	6be2                	ld	s7,24(sp)
 2a4:	6125                	addi	sp,sp,96
 2a6:	8082                	ret

00000000000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	1101                	addi	sp,sp,-32
 2aa:	ec06                	sd	ra,24(sp)
 2ac:	e822                	sd	s0,16(sp)
 2ae:	e04a                	sd	s2,0(sp)
 2b0:	1000                	addi	s0,sp,32
 2b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b4:	4581                	li	a1,0
 2b6:	18e000ef          	jal	444 <open>
  if(fd < 0)
 2ba:	02054263          	bltz	a0,2de <stat+0x36>
 2be:	e426                	sd	s1,8(sp)
 2c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c2:	85ca                	mv	a1,s2
 2c4:	198000ef          	jal	45c <fstat>
 2c8:	892a                	mv	s2,a0
  close(fd);
 2ca:	8526                	mv	a0,s1
 2cc:	160000ef          	jal	42c <close>
  return r;
 2d0:	64a2                	ld	s1,8(sp)
}
 2d2:	854a                	mv	a0,s2
 2d4:	60e2                	ld	ra,24(sp)
 2d6:	6442                	ld	s0,16(sp)
 2d8:	6902                	ld	s2,0(sp)
 2da:	6105                	addi	sp,sp,32
 2dc:	8082                	ret
    return -1;
 2de:	597d                	li	s2,-1
 2e0:	bfcd                	j	2d2 <stat+0x2a>

00000000000002e2 <atoi>:

int
atoi(const char *s)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e8:	00054683          	lbu	a3,0(a0)
 2ec:	fd06879b          	addiw	a5,a3,-48
 2f0:	0ff7f793          	zext.b	a5,a5
 2f4:	4625                	li	a2,9
 2f6:	02f66863          	bltu	a2,a5,326 <atoi+0x44>
 2fa:	872a                	mv	a4,a0
  n = 0;
 2fc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2fe:	0705                	addi	a4,a4,1
 300:	0025179b          	slliw	a5,a0,0x2
 304:	9fa9                	addw	a5,a5,a0
 306:	0017979b          	slliw	a5,a5,0x1
 30a:	9fb5                	addw	a5,a5,a3
 30c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 310:	00074683          	lbu	a3,0(a4)
 314:	fd06879b          	addiw	a5,a3,-48
 318:	0ff7f793          	zext.b	a5,a5
 31c:	fef671e3          	bgeu	a2,a5,2fe <atoi+0x1c>
  return n;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  n = 0;
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <atoi+0x3e>

000000000000032a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 330:	02b57463          	bgeu	a0,a1,358 <memmove+0x2e>
    while(n-- > 0)
 334:	00c05f63          	blez	a2,352 <memmove+0x28>
 338:	1602                	slli	a2,a2,0x20
 33a:	9201                	srli	a2,a2,0x20
 33c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 340:	872a                	mv	a4,a0
      *dst++ = *src++;
 342:	0585                	addi	a1,a1,1
 344:	0705                	addi	a4,a4,1
 346:	fff5c683          	lbu	a3,-1(a1)
 34a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34e:	fef71ae3          	bne	a4,a5,342 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 352:	6422                	ld	s0,8(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret
    dst += n;
 358:	00c50733          	add	a4,a0,a2
    src += n;
 35c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35e:	fec05ae3          	blez	a2,352 <memmove+0x28>
 362:	fff6079b          	addiw	a5,a2,-1
 366:	1782                	slli	a5,a5,0x20
 368:	9381                	srli	a5,a5,0x20
 36a:	fff7c793          	not	a5,a5
 36e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 370:	15fd                	addi	a1,a1,-1
 372:	177d                	addi	a4,a4,-1
 374:	0005c683          	lbu	a3,0(a1)
 378:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37c:	fee79ae3          	bne	a5,a4,370 <memmove+0x46>
 380:	bfc9                	j	352 <memmove+0x28>

0000000000000382 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 382:	1141                	addi	sp,sp,-16
 384:	e422                	sd	s0,8(sp)
 386:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 388:	ca05                	beqz	a2,3b8 <memcmp+0x36>
 38a:	fff6069b          	addiw	a3,a2,-1
 38e:	1682                	slli	a3,a3,0x20
 390:	9281                	srli	a3,a3,0x20
 392:	0685                	addi	a3,a3,1
 394:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 396:	00054783          	lbu	a5,0(a0)
 39a:	0005c703          	lbu	a4,0(a1)
 39e:	00e79863          	bne	a5,a4,3ae <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a2:	0505                	addi	a0,a0,1
    p2++;
 3a4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a6:	fed518e3          	bne	a0,a3,396 <memcmp+0x14>
  }
  return 0;
 3aa:	4501                	li	a0,0
 3ac:	a019                	j	3b2 <memcmp+0x30>
      return *p1 - *p2;
 3ae:	40e7853b          	subw	a0,a5,a4
}
 3b2:	6422                	ld	s0,8(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret
  return 0;
 3b8:	4501                	li	a0,0
 3ba:	bfe5                	j	3b2 <memcmp+0x30>

00000000000003bc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e406                	sd	ra,8(sp)
 3c0:	e022                	sd	s0,0(sp)
 3c2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c4:	f67ff0ef          	jal	32a <memmove>
}
 3c8:	60a2                	ld	ra,8(sp)
 3ca:	6402                	ld	s0,0(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret

00000000000003d0 <sbrk>:

char *
sbrk(int n) {
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e406                	sd	ra,8(sp)
 3d4:	e022                	sd	s0,0(sp)
 3d6:	0800                	addi	s0,sp,16
  // Eager allocation by default to preserve original xv6 semantics
  // relied upon by many user programs and tests (e.g., countfree).
  return sys_sbrk(n, SBRK_EAGER);
 3d8:	4585                	li	a1,1
 3da:	0b2000ef          	jal	48c <sys_sbrk>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <sbrklazy>:

char *
sbrklazy(int n) {
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e406                	sd	ra,8(sp)
 3ea:	e022                	sd	s0,0(sp)
 3ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3ee:	4589                	li	a1,2
 3f0:	09c000ef          	jal	48c <sys_sbrk>
}
 3f4:	60a2                	ld	ra,8(sp)
 3f6:	6402                	ld	s0,0(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret

00000000000003fc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fc:	4885                	li	a7,1
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <exit>:
.global exit
exit:
 li a7, SYS_exit
 404:	4889                	li	a7,2
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <wait>:
.global wait
wait:
 li a7, SYS_wait
 40c:	488d                	li	a7,3
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 414:	4891                	li	a7,4
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <read>:
.global read
read:
 li a7, SYS_read
 41c:	4895                	li	a7,5
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <write>:
.global write
write:
 li a7, SYS_write
 424:	48c1                	li	a7,16
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <close>:
.global close
close:
 li a7, SYS_close
 42c:	48d5                	li	a7,21
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <kill>:
.global kill
kill:
 li a7, SYS_kill
 434:	4899                	li	a7,6
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <exec>:
.global exec
exec:
 li a7, SYS_exec
 43c:	489d                	li	a7,7
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <open>:
.global open
open:
 li a7, SYS_open
 444:	48bd                	li	a7,15
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44c:	48c5                	li	a7,17
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 454:	48c9                	li	a7,18
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45c:	48a1                	li	a7,8
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <link>:
.global link
link:
 li a7, SYS_link
 464:	48cd                	li	a7,19
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46c:	48d1                	li	a7,20
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 474:	48a5                	li	a7,9
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <dup>:
.global dup
dup:
 li a7, SYS_dup
 47c:	48a9                	li	a7,10
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 484:	48ad                	li	a7,11
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 48c:	48b1                	li	a7,12
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <pause>:
.global pause
pause:
 li a7, SYS_pause
 494:	48b5                	li	a7,13
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49c:	48b9                	li	a7,14
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 4a4:	48d9                	li	a7,22
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ac:	1101                	addi	sp,sp,-32
 4ae:	ec06                	sd	ra,24(sp)
 4b0:	e822                	sd	s0,16(sp)
 4b2:	1000                	addi	s0,sp,32
 4b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b8:	4605                	li	a2,1
 4ba:	fef40593          	addi	a1,s0,-17
 4be:	f67ff0ef          	jal	424 <write>
}
 4c2:	60e2                	ld	ra,24(sp)
 4c4:	6442                	ld	s0,16(sp)
 4c6:	6105                	addi	sp,sp,32
 4c8:	8082                	ret

00000000000004ca <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ca:	715d                	addi	sp,sp,-80
 4cc:	e486                	sd	ra,72(sp)
 4ce:	e0a2                	sd	s0,64(sp)
 4d0:	f84a                	sd	s2,48(sp)
 4d2:	0880                	addi	s0,sp,80
 4d4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4d6:	c299                	beqz	a3,4dc <printint+0x12>
 4d8:	0805c363          	bltz	a1,55e <printint+0x94>
  neg = 0;
 4dc:	4881                	li	a7,0
 4de:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4e2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4e4:	00000517          	auipc	a0,0x0
 4e8:	68c50513          	addi	a0,a0,1676 # b70 <digits>
 4ec:	883e                	mv	a6,a5
 4ee:	2785                	addiw	a5,a5,1
 4f0:	02c5f733          	remu	a4,a1,a2
 4f4:	972a                	add	a4,a4,a0
 4f6:	00074703          	lbu	a4,0(a4)
 4fa:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4fe:	872e                	mv	a4,a1
 500:	02c5d5b3          	divu	a1,a1,a2
 504:	0685                	addi	a3,a3,1
 506:	fec773e3          	bgeu	a4,a2,4ec <printint+0x22>
  if(neg)
 50a:	00088b63          	beqz	a7,520 <printint+0x56>
    buf[i++] = '-';
 50e:	fd078793          	addi	a5,a5,-48
 512:	97a2                	add	a5,a5,s0
 514:	02d00713          	li	a4,45
 518:	fee78423          	sb	a4,-24(a5)
 51c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 520:	02f05a63          	blez	a5,554 <printint+0x8a>
 524:	fc26                	sd	s1,56(sp)
 526:	f44e                	sd	s3,40(sp)
 528:	fb840713          	addi	a4,s0,-72
 52c:	00f704b3          	add	s1,a4,a5
 530:	fff70993          	addi	s3,a4,-1
 534:	99be                	add	s3,s3,a5
 536:	37fd                	addiw	a5,a5,-1
 538:	1782                	slli	a5,a5,0x20
 53a:	9381                	srli	a5,a5,0x20
 53c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 540:	fff4c583          	lbu	a1,-1(s1)
 544:	854a                	mv	a0,s2
 546:	f67ff0ef          	jal	4ac <putc>
  while(--i >= 0)
 54a:	14fd                	addi	s1,s1,-1
 54c:	ff349ae3          	bne	s1,s3,540 <printint+0x76>
 550:	74e2                	ld	s1,56(sp)
 552:	79a2                	ld	s3,40(sp)
}
 554:	60a6                	ld	ra,72(sp)
 556:	6406                	ld	s0,64(sp)
 558:	7942                	ld	s2,48(sp)
 55a:	6161                	addi	sp,sp,80
 55c:	8082                	ret
    x = -xx;
 55e:	40b005b3          	neg	a1,a1
    neg = 1;
 562:	4885                	li	a7,1
    x = -xx;
 564:	bfad                	j	4de <printint+0x14>

0000000000000566 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 566:	711d                	addi	sp,sp,-96
 568:	ec86                	sd	ra,88(sp)
 56a:	e8a2                	sd	s0,80(sp)
 56c:	e0ca                	sd	s2,64(sp)
 56e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 570:	0005c903          	lbu	s2,0(a1)
 574:	28090663          	beqz	s2,800 <vprintf+0x29a>
 578:	e4a6                	sd	s1,72(sp)
 57a:	fc4e                	sd	s3,56(sp)
 57c:	f852                	sd	s4,48(sp)
 57e:	f456                	sd	s5,40(sp)
 580:	f05a                	sd	s6,32(sp)
 582:	ec5e                	sd	s7,24(sp)
 584:	e862                	sd	s8,16(sp)
 586:	e466                	sd	s9,8(sp)
 588:	8b2a                	mv	s6,a0
 58a:	8a2e                	mv	s4,a1
 58c:	8bb2                	mv	s7,a2
  state = 0;
 58e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 590:	4481                	li	s1,0
 592:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 594:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 598:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 59c:	06c00c93          	li	s9,108
 5a0:	a005                	j	5c0 <vprintf+0x5a>
        putc(fd, c0);
 5a2:	85ca                	mv	a1,s2
 5a4:	855a                	mv	a0,s6
 5a6:	f07ff0ef          	jal	4ac <putc>
 5aa:	a019                	j	5b0 <vprintf+0x4a>
    } else if(state == '%'){
 5ac:	03598263          	beq	s3,s5,5d0 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5b0:	2485                	addiw	s1,s1,1
 5b2:	8726                	mv	a4,s1
 5b4:	009a07b3          	add	a5,s4,s1
 5b8:	0007c903          	lbu	s2,0(a5)
 5bc:	22090a63          	beqz	s2,7f0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5c0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5c4:	fe0994e3          	bnez	s3,5ac <vprintf+0x46>
      if(c0 == '%'){
 5c8:	fd579de3          	bne	a5,s5,5a2 <vprintf+0x3c>
        state = '%';
 5cc:	89be                	mv	s3,a5
 5ce:	b7cd                	j	5b0 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5d0:	00ea06b3          	add	a3,s4,a4
 5d4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5d8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5da:	c681                	beqz	a3,5e2 <vprintf+0x7c>
 5dc:	9752                	add	a4,a4,s4
 5de:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5e2:	05878363          	beq	a5,s8,628 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5e6:	05978d63          	beq	a5,s9,640 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ea:	07500713          	li	a4,117
 5ee:	0ee78763          	beq	a5,a4,6dc <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5f2:	07800713          	li	a4,120
 5f6:	12e78963          	beq	a5,a4,728 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5fa:	07000713          	li	a4,112
 5fe:	14e78e63          	beq	a5,a4,75a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 602:	06300713          	li	a4,99
 606:	18e78e63          	beq	a5,a4,7a2 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 60a:	07300713          	li	a4,115
 60e:	1ae78463          	beq	a5,a4,7b6 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 612:	02500713          	li	a4,37
 616:	04e79563          	bne	a5,a4,660 <vprintf+0xfa>
        putc(fd, '%');
 61a:	02500593          	li	a1,37
 61e:	855a                	mv	a0,s6
 620:	e8dff0ef          	jal	4ac <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 624:	4981                	li	s3,0
 626:	b769                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 628:	008b8913          	addi	s2,s7,8
 62c:	4685                	li	a3,1
 62e:	4629                	li	a2,10
 630:	000ba583          	lw	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	e95ff0ef          	jal	4ca <printint>
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bf8d                	j	5b0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 640:	06400793          	li	a5,100
 644:	02f68963          	beq	a3,a5,676 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 648:	06c00793          	li	a5,108
 64c:	04f68263          	beq	a3,a5,690 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 650:	07500793          	li	a5,117
 654:	0af68063          	beq	a3,a5,6f4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 658:	07800793          	li	a5,120
 65c:	0ef68263          	beq	a3,a5,740 <vprintf+0x1da>
        putc(fd, '%');
 660:	02500593          	li	a1,37
 664:	855a                	mv	a0,s6
 666:	e47ff0ef          	jal	4ac <putc>
        putc(fd, c0);
 66a:	85ca                	mv	a1,s2
 66c:	855a                	mv	a0,s6
 66e:	e3fff0ef          	jal	4ac <putc>
      state = 0;
 672:	4981                	li	s3,0
 674:	bf35                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 676:	008b8913          	addi	s2,s7,8
 67a:	4685                	li	a3,1
 67c:	4629                	li	a2,10
 67e:	000bb583          	ld	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	e47ff0ef          	jal	4ca <printint>
        i += 1;
 688:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
        i += 1;
 68e:	b70d                	j	5b0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 690:	06400793          	li	a5,100
 694:	02f60763          	beq	a2,a5,6c2 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 698:	07500793          	li	a5,117
 69c:	06f60963          	beq	a2,a5,70e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6a0:	07800793          	li	a5,120
 6a4:	faf61ee3          	bne	a2,a5,660 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4681                	li	a3,0
 6ae:	4641                	li	a2,16
 6b0:	000bb583          	ld	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	e15ff0ef          	jal	4ca <printint>
        i += 2;
 6ba:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
        i += 2;
 6c0:	bdc5                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4685                	li	a3,1
 6c8:	4629                	li	a2,10
 6ca:	000bb583          	ld	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	dfbff0ef          	jal	4ca <printint>
        i += 2;
 6d4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
        i += 2;
 6da:	bdd9                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	4681                	li	a3,0
 6e2:	4629                	li	a2,10
 6e4:	000be583          	lwu	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	de1ff0ef          	jal	4ca <printint>
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bd7d                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4629                	li	a2,10
 6fc:	000bb583          	ld	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	dc9ff0ef          	jal	4ca <printint>
        i += 1;
 706:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 708:	8bca                	mv	s7,s2
      state = 0;
 70a:	4981                	li	s3,0
        i += 1;
 70c:	b555                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70e:	008b8913          	addi	s2,s7,8
 712:	4681                	li	a3,0
 714:	4629                	li	a2,10
 716:	000bb583          	ld	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	dafff0ef          	jal	4ca <printint>
        i += 2;
 720:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 722:	8bca                	mv	s7,s2
      state = 0;
 724:	4981                	li	s3,0
        i += 2;
 726:	b569                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 728:	008b8913          	addi	s2,s7,8
 72c:	4681                	li	a3,0
 72e:	4641                	li	a2,16
 730:	000be583          	lwu	a1,0(s7)
 734:	855a                	mv	a0,s6
 736:	d95ff0ef          	jal	4ca <printint>
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
 73e:	bd8d                	j	5b0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 740:	008b8913          	addi	s2,s7,8
 744:	4681                	li	a3,0
 746:	4641                	li	a2,16
 748:	000bb583          	ld	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	d7dff0ef          	jal	4ca <printint>
        i += 1;
 752:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 754:	8bca                	mv	s7,s2
      state = 0;
 756:	4981                	li	s3,0
        i += 1;
 758:	bda1                	j	5b0 <vprintf+0x4a>
 75a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 75c:	008b8d13          	addi	s10,s7,8
 760:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 764:	03000593          	li	a1,48
 768:	855a                	mv	a0,s6
 76a:	d43ff0ef          	jal	4ac <putc>
  putc(fd, 'x');
 76e:	07800593          	li	a1,120
 772:	855a                	mv	a0,s6
 774:	d39ff0ef          	jal	4ac <putc>
 778:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77a:	00000b97          	auipc	s7,0x0
 77e:	3f6b8b93          	addi	s7,s7,1014 # b70 <digits>
 782:	03c9d793          	srli	a5,s3,0x3c
 786:	97de                	add	a5,a5,s7
 788:	0007c583          	lbu	a1,0(a5)
 78c:	855a                	mv	a0,s6
 78e:	d1fff0ef          	jal	4ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 792:	0992                	slli	s3,s3,0x4
 794:	397d                	addiw	s2,s2,-1
 796:	fe0916e3          	bnez	s2,782 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 79a:	8bea                	mv	s7,s10
      state = 0;
 79c:	4981                	li	s3,0
 79e:	6d02                	ld	s10,0(sp)
 7a0:	bd01                	j	5b0 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7a2:	008b8913          	addi	s2,s7,8
 7a6:	000bc583          	lbu	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	d01ff0ef          	jal	4ac <putc>
 7b0:	8bca                	mv	s7,s2
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	bbf5                	j	5b0 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7b6:	008b8993          	addi	s3,s7,8
 7ba:	000bb903          	ld	s2,0(s7)
 7be:	00090f63          	beqz	s2,7dc <vprintf+0x276>
        for(; *s; s++)
 7c2:	00094583          	lbu	a1,0(s2)
 7c6:	c195                	beqz	a1,7ea <vprintf+0x284>
          putc(fd, *s);
 7c8:	855a                	mv	a0,s6
 7ca:	ce3ff0ef          	jal	4ac <putc>
        for(; *s; s++)
 7ce:	0905                	addi	s2,s2,1
 7d0:	00094583          	lbu	a1,0(s2)
 7d4:	f9f5                	bnez	a1,7c8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7d6:	8bce                	mv	s7,s3
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	bbd9                	j	5b0 <vprintf+0x4a>
          s = "(null)";
 7dc:	00000917          	auipc	s2,0x0
 7e0:	38c90913          	addi	s2,s2,908 # b68 <malloc+0x280>
        for(; *s; s++)
 7e4:	02800593          	li	a1,40
 7e8:	b7c5                	j	7c8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ea:	8bce                	mv	s7,s3
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b3c9                	j	5b0 <vprintf+0x4a>
 7f0:	64a6                	ld	s1,72(sp)
 7f2:	79e2                	ld	s3,56(sp)
 7f4:	7a42                	ld	s4,48(sp)
 7f6:	7aa2                	ld	s5,40(sp)
 7f8:	7b02                	ld	s6,32(sp)
 7fa:	6be2                	ld	s7,24(sp)
 7fc:	6c42                	ld	s8,16(sp)
 7fe:	6ca2                	ld	s9,8(sp)
    }
  }
}
 800:	60e6                	ld	ra,88(sp)
 802:	6446                	ld	s0,80(sp)
 804:	6906                	ld	s2,64(sp)
 806:	6125                	addi	sp,sp,96
 808:	8082                	ret

000000000000080a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 80a:	715d                	addi	sp,sp,-80
 80c:	ec06                	sd	ra,24(sp)
 80e:	e822                	sd	s0,16(sp)
 810:	1000                	addi	s0,sp,32
 812:	e010                	sd	a2,0(s0)
 814:	e414                	sd	a3,8(s0)
 816:	e818                	sd	a4,16(s0)
 818:	ec1c                	sd	a5,24(s0)
 81a:	03043023          	sd	a6,32(s0)
 81e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 822:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 826:	8622                	mv	a2,s0
 828:	d3fff0ef          	jal	566 <vprintf>
}
 82c:	60e2                	ld	ra,24(sp)
 82e:	6442                	ld	s0,16(sp)
 830:	6161                	addi	sp,sp,80
 832:	8082                	ret

0000000000000834 <printf>:

void
printf(const char *fmt, ...)
{
 834:	711d                	addi	sp,sp,-96
 836:	ec06                	sd	ra,24(sp)
 838:	e822                	sd	s0,16(sp)
 83a:	1000                	addi	s0,sp,32
 83c:	e40c                	sd	a1,8(s0)
 83e:	e810                	sd	a2,16(s0)
 840:	ec14                	sd	a3,24(s0)
 842:	f018                	sd	a4,32(s0)
 844:	f41c                	sd	a5,40(s0)
 846:	03043823          	sd	a6,48(s0)
 84a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 84e:	00840613          	addi	a2,s0,8
 852:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 856:	85aa                	mv	a1,a0
 858:	4505                	li	a0,1
 85a:	d0dff0ef          	jal	566 <vprintf>
}
 85e:	60e2                	ld	ra,24(sp)
 860:	6442                	ld	s0,16(sp)
 862:	6125                	addi	sp,sp,96
 864:	8082                	ret

0000000000000866 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 866:	1141                	addi	sp,sp,-16
 868:	e422                	sd	s0,8(sp)
 86a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 870:	00000797          	auipc	a5,0x0
 874:	7907b783          	ld	a5,1936(a5) # 1000 <freep>
 878:	a02d                	j	8a2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 87a:	4618                	lw	a4,8(a2)
 87c:	9f2d                	addw	a4,a4,a1
 87e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 882:	6398                	ld	a4,0(a5)
 884:	6310                	ld	a2,0(a4)
 886:	a83d                	j	8c4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 888:	ff852703          	lw	a4,-8(a0)
 88c:	9f31                	addw	a4,a4,a2
 88e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 890:	ff053683          	ld	a3,-16(a0)
 894:	a091                	j	8d8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 896:	6398                	ld	a4,0(a5)
 898:	00e7e463          	bltu	a5,a4,8a0 <free+0x3a>
 89c:	00e6ea63          	bltu	a3,a4,8b0 <free+0x4a>
{
 8a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a2:	fed7fae3          	bgeu	a5,a3,896 <free+0x30>
 8a6:	6398                	ld	a4,0(a5)
 8a8:	00e6e463          	bltu	a3,a4,8b0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ac:	fee7eae3          	bltu	a5,a4,8a0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8b0:	ff852583          	lw	a1,-8(a0)
 8b4:	6390                	ld	a2,0(a5)
 8b6:	02059813          	slli	a6,a1,0x20
 8ba:	01c85713          	srli	a4,a6,0x1c
 8be:	9736                	add	a4,a4,a3
 8c0:	fae60de3          	beq	a2,a4,87a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c8:	4790                	lw	a2,8(a5)
 8ca:	02061593          	slli	a1,a2,0x20
 8ce:	01c5d713          	srli	a4,a1,0x1c
 8d2:	973e                	add	a4,a4,a5
 8d4:	fae68ae3          	beq	a3,a4,888 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8da:	00000717          	auipc	a4,0x0
 8de:	72f73323          	sd	a5,1830(a4) # 1000 <freep>
}
 8e2:	6422                	ld	s0,8(sp)
 8e4:	0141                	addi	sp,sp,16
 8e6:	8082                	ret

00000000000008e8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e8:	7139                	addi	sp,sp,-64
 8ea:	fc06                	sd	ra,56(sp)
 8ec:	f822                	sd	s0,48(sp)
 8ee:	f426                	sd	s1,40(sp)
 8f0:	ec4e                	sd	s3,24(sp)
 8f2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f4:	02051493          	slli	s1,a0,0x20
 8f8:	9081                	srli	s1,s1,0x20
 8fa:	04bd                	addi	s1,s1,15
 8fc:	8091                	srli	s1,s1,0x4
 8fe:	0014899b          	addiw	s3,s1,1
 902:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 904:	00000517          	auipc	a0,0x0
 908:	6fc53503          	ld	a0,1788(a0) # 1000 <freep>
 90c:	c915                	beqz	a0,940 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 910:	4798                	lw	a4,8(a5)
 912:	08977a63          	bgeu	a4,s1,9a6 <malloc+0xbe>
 916:	f04a                	sd	s2,32(sp)
 918:	e852                	sd	s4,16(sp)
 91a:	e456                	sd	s5,8(sp)
 91c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 91e:	8a4e                	mv	s4,s3
 920:	0009871b          	sext.w	a4,s3
 924:	6685                	lui	a3,0x1
 926:	00d77363          	bgeu	a4,a3,92c <malloc+0x44>
 92a:	6a05                	lui	s4,0x1
 92c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 930:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 934:	00000917          	auipc	s2,0x0
 938:	6cc90913          	addi	s2,s2,1740 # 1000 <freep>
  if(p == SBRK_ERROR)
 93c:	5afd                	li	s5,-1
 93e:	a081                	j	97e <malloc+0x96>
 940:	f04a                	sd	s2,32(sp)
 942:	e852                	sd	s4,16(sp)
 944:	e456                	sd	s5,8(sp)
 946:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 948:	00000797          	auipc	a5,0x0
 94c:	6c878793          	addi	a5,a5,1736 # 1010 <base>
 950:	00000717          	auipc	a4,0x0
 954:	6af73823          	sd	a5,1712(a4) # 1000 <freep>
 958:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 95a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 95e:	b7c1                	j	91e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 960:	6398                	ld	a4,0(a5)
 962:	e118                	sd	a4,0(a0)
 964:	a8a9                	j	9be <malloc+0xd6>
  hp->s.size = nu;
 966:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 96a:	0541                	addi	a0,a0,16
 96c:	efbff0ef          	jal	866 <free>
  return freep;
 970:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 974:	c12d                	beqz	a0,9d6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 978:	4798                	lw	a4,8(a5)
 97a:	02977263          	bgeu	a4,s1,99e <malloc+0xb6>
    if(p == freep)
 97e:	00093703          	ld	a4,0(s2)
 982:	853e                	mv	a0,a5
 984:	fef719e3          	bne	a4,a5,976 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 988:	8552                	mv	a0,s4
 98a:	a47ff0ef          	jal	3d0 <sbrk>
  if(p == SBRK_ERROR)
 98e:	fd551ce3          	bne	a0,s5,966 <malloc+0x7e>
        return 0;
 992:	4501                	li	a0,0
 994:	7902                	ld	s2,32(sp)
 996:	6a42                	ld	s4,16(sp)
 998:	6aa2                	ld	s5,8(sp)
 99a:	6b02                	ld	s6,0(sp)
 99c:	a03d                	j	9ca <malloc+0xe2>
 99e:	7902                	ld	s2,32(sp)
 9a0:	6a42                	ld	s4,16(sp)
 9a2:	6aa2                	ld	s5,8(sp)
 9a4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a6:	fae48de3          	beq	s1,a4,960 <malloc+0x78>
        p->s.size -= nunits;
 9aa:	4137073b          	subw	a4,a4,s3
 9ae:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b0:	02071693          	slli	a3,a4,0x20
 9b4:	01c6d713          	srli	a4,a3,0x1c
 9b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9be:	00000717          	auipc	a4,0x0
 9c2:	64a73123          	sd	a0,1602(a4) # 1000 <freep>
      return (void*)(p + 1);
 9c6:	01078513          	addi	a0,a5,16
  }
}
 9ca:	70e2                	ld	ra,56(sp)
 9cc:	7442                	ld	s0,48(sp)
 9ce:	74a2                	ld	s1,40(sp)
 9d0:	69e2                	ld	s3,24(sp)
 9d2:	6121                	addi	sp,sp,64
 9d4:	8082                	ret
 9d6:	7902                	ld	s2,32(sp)
 9d8:	6a42                	ld	s4,16(sp)
 9da:	6aa2                	ld	s5,8(sp)
 9dc:	6b02                	ld	s6,0(sp)
 9de:	b7f5                	j	9ca <malloc+0xe2>
