
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000d117          	auipc	sp,0xd
    80000004:	a8813103          	ld	sp,-1400(sp) # 8000ca88 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7feee627>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	0d5020ef          	jal	800029e6 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00015517          	auipc	a0,0x15
    80000190:	94450513          	addi	a0,a0,-1724 # 80014ad0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00015497          	auipc	s1,0x15
    8000019c:	93848493          	addi	s1,s1,-1736 # 80014ad0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00015917          	auipc	s2,0x15
    800001a4:	9c890913          	addi	s2,s2,-1592 # 80014b68 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	4eb010ef          	jal	80001ea2 <myproc>
    800001bc:	6ba020ef          	jal	80002876 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	438020ef          	jal	800025fe <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00015717          	auipc	a4,0x15
    800001dc:	8f870713          	addi	a4,a4,-1800 # 80014ad0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	792020ef          	jal	8000299c <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00015517          	auipc	a0,0x15
    80000226:	8ae50513          	addi	a0,a0,-1874 # 80014ad0 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00015717          	auipc	a4,0x15
    80000250:	90f72e23          	sw	a5,-1764(a4) # 80014b68 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00015517          	auipc	a0,0x15
    80000266:	86e50513          	addi	a0,a0,-1938 # 80014ad0 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00015517          	auipc	a0,0x15
    800002ba:	81a50513          	addi	a0,a0,-2022 # 80014ad0 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	758020ef          	jal	80002a30 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00014517          	auipc	a0,0x14
    800002e0:	7f450513          	addi	a0,a0,2036 # 80014ad0 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00014717          	auipc	a4,0x14
    800002fe:	7d670713          	addi	a4,a4,2006 # 80014ad0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00014797          	auipc	a5,0x14
    80000324:	7b078793          	addi	a5,a5,1968 # 80014ad0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00015797          	auipc	a5,0x15
    80000352:	81a7a783          	lw	a5,-2022(a5) # 80014b68 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00014717          	auipc	a4,0x14
    80000368:	76c70713          	addi	a4,a4,1900 # 80014ad0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00014497          	auipc	s1,0x14
    80000378:	75c48493          	addi	s1,s1,1884 # 80014ad0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00014717          	auipc	a4,0x14
    800003ba:	71a70713          	addi	a4,a4,1818 # 80014ad0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00014717          	auipc	a4,0x14
    800003d0:	7af72223          	sw	a5,1956(a4) # 80014b70 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00014797          	auipc	a5,0x14
    800003ee:	6e678793          	addi	a5,a5,1766 # 80014ad0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00014797          	auipc	a5,0x14
    80000412:	74c7af23          	sw	a2,1886(a5) # 80014b6c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00014517          	auipc	a0,0x14
    8000041a:	75250513          	addi	a0,a0,1874 # 80014b68 <cons+0x98>
    8000041e:	22c020ef          	jal	8000264a <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00009597          	auipc	a1,0x9
    80000430:	bd458593          	addi	a1,a1,-1068 # 80009000 <etext>
    80000434:	00014517          	auipc	a0,0x14
    80000438:	69c50513          	addi	a0,a0,1692 # 80014ad0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	0010f797          	auipc	a5,0x10f
    80000448:	bfc78793          	addi	a5,a5,-1028 # 8010f040 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00009617          	auipc	a2,0x9
    80000482:	60260613          	addi	a2,a2,1538 # 80009a80 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000c797          	auipc	a5,0xc
    8000051c:	58c7a783          	lw	a5,1420(a5) # 8000caa4 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00014517          	auipc	a0,0x14
    80000564:	61850513          	addi	a0,a0,1560 # 80014b78 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00009b97          	auipc	s7,0x9
    8000072c:	358b8b93          	addi	s7,s7,856 # 80009a80 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00009917          	auipc	s2,0x9
    8000078c:	88090913          	addi	s2,s2,-1920 # 80009008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	0000c797          	auipc	a5,0xc
    800007c0:	2e87a783          	lw	a5,744(a5) # 8000caa4 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00014517          	auipc	a0,0x14
    800007d6:	3a650513          	addi	a0,a0,934 # 80014b78 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	0000c797          	auipc	a5,0xc
    800007f4:	2b27aa23          	sw	s2,692(a5) # 8000caa4 <panicking>
  printf("panic: ");
    800007f8:	00009517          	auipc	a0,0x9
    800007fc:	82050513          	addi	a0,a0,-2016 # 80009018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00009517          	auipc	a0,0x9
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80009020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	0000c797          	auipc	a5,0xc
    80000816:	2927a723          	sw	s2,654(a5) # 8000caa0 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00009597          	auipc	a1,0x9
    80000828:	80458593          	addi	a1,a1,-2044 # 80009028 <etext+0x28>
    8000082c:	00014517          	auipc	a0,0x14
    80000830:	34c50513          	addi	a0,a0,844 # 80014b78 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00008597          	auipc	a1,0x8
    80000880:	7b458593          	addi	a1,a1,1972 # 80009030 <etext+0x30>
    80000884:	00014517          	auipc	a0,0x14
    80000888:	30c50513          	addi	a0,a0,780 # 80014b90 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00014517          	auipc	a0,0x14
    800008ac:	2e850513          	addi	a0,a0,744 # 80014b90 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	0000c497          	auipc	s1,0xc
    800008ca:	1e648493          	addi	s1,s1,486 # 8000caac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00014997          	auipc	s3,0x14
    800008d2:	2c298993          	addi	s3,s3,706 # 80014b90 <tx_lock>
    800008d6:	0000c917          	auipc	s2,0xc
    800008da:	1d290913          	addi	s2,s2,466 # 8000caa8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	515010ef          	jal	800025fe <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00014517          	auipc	a0,0x14
    80000918:	27c50513          	addi	a0,a0,636 # 80014b90 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	0000c797          	auipc	a5,0xc
    8000093c:	16c7a783          	lw	a5,364(a5) # 8000caa4 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000c797          	auipc	a5,0xc
    80000946:	15e7a783          	lw	a5,350(a5) # 8000caa0 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	0000c797          	auipc	a5,0xc
    8000096c:	13c7a783          	lw	a5,316(a5) # 8000caa4 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00014517          	auipc	a0,0x14
    800009c8:	1cc50513          	addi	a0,a0,460 # 80014b90 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00014517          	auipc	a0,0x14
    800009e4:	1b050513          	addi	a0,a0,432 # 80014b90 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	0000c797          	auipc	a5,0xc
    800009f4:	0a07ae23          	sw	zero,188(a5) # 8000caac <tx_busy>
    wakeup(&tx_chan);
    800009f8:	0000c517          	auipc	a0,0xc
    800009fc:	0b050513          	addi	a0,a0,176 # 8000caa8 <tx_chan>
    80000a00:	44b010ef          	jal	8000264a <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	0010f797          	auipc	a5,0x10f
    80000a34:	7a878793          	addi	a5,a5,1960 # 801101d8 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	00014917          	auipc	s2,0x14
    80000a50:	15c90913          	addi	s2,s2,348 # 80014ba8 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00008517          	auipc	a0,0x8
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80009038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00008597          	auipc	a1,0x8
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80009040 <etext+0x40>
    80000ada:	00014517          	auipc	a0,0x14
    80000ade:	0ce50513          	addi	a0,a0,206 # 80014ba8 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	0010f517          	auipc	a0,0x10f
    80000aee:	6ee50513          	addi	a0,a0,1774 # 801101d8 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	00014497          	auipc	s1,0x14
    80000b0c:	0a048493          	addi	s1,s1,160 # 80014ba8 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00014517          	auipc	a0,0x14
    80000b20:	08c50513          	addi	a0,a0,140 # 80014ba8 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00014517          	auipc	a0,0x14
    80000b44:	06850513          	addi	a0,a0,104 # 80014ba8 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	30e010ef          	jal	80001e86 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	2e0010ef          	jal	80001e86 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	2d8010ef          	jal	80001e86 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	2c4010ef          	jal	80001e86 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf6:	290010ef          	jal	80001e86 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00008517          	auipc	a0,0x8
    80000c0a:	44250513          	addi	a0,a0,1090 # 80009048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	26c010ef          	jal	80001e86 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00008517          	auipc	a0,0x8
    80000c52:	40250513          	addi	a0,a0,1026 # 80009050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00008517          	auipc	a0,0x8
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80009068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c80:	0310000f          	fence	rw,w
    80000c84:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00008517          	auipc	a0,0x8
    80000c9a:	3da50513          	addi	a0,a0,986 # 80009070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7feeee29>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	032010ef          	jal	80001e76 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	0000c717          	auipc	a4,0xc
    80000e4c:	c6870713          	addi	a4,a4,-920 # 8000cab0 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e5c:	01a010ef          	jal	80001e76 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00008517          	auipc	a0,0x8
    80000e66:	22e50513          	addi	a0,a0,558 # 80009090 <etext+0x90>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	150000ef          	jal	80000fbe <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	527010ef          	jal	80002b98 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	662050ef          	jal	800064d8 <plicinithart>
  }

  scheduler();        
    80000e7a:	5e6010ef          	jal	80002460 <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00008517          	auipc	a0,0x8
    80000e8a:	2ea50513          	addi	a0,a0,746 # 80009170 <etext+0x170>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00008517          	auipc	a0,0x8
    80000e96:	1e650513          	addi	a0,a0,486 # 80009078 <etext+0x78>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00008517          	auipc	a0,0x8
    80000ea2:	2d250513          	addi	a0,a0,722 # 80009170 <etext+0x170>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	39a000ef          	jal	80001248 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	10c000ef          	jal	80000fbe <kvminithart>
    procinit();      // process table
    80000eb6:	703000ef          	jal	80001db8 <procinit>
    trapinit();      // trap vectors
    80000eba:	4bb010ef          	jal	80002b74 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	4db010ef          	jal	80002b98 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	5fc050ef          	jal	800064be <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	612050ef          	jal	800064d8 <plicinithart>
    binit();         // buffer cache
    80000eca:	407020ef          	jal	80003ad0 <binit>
    iinit();         // inode table
    80000ece:	18c030ef          	jal	8000405a <iinit>
    fileinit();      // file table
    80000ed2:	07e040ef          	jal	80004f50 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	6f2050ef          	jal	800065c8 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	350010ef          	jal	8000222a <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	0000c717          	auipc	a4,0xc
    80000ee8:	bcf72623          	sw	a5,-1076(a4) # 8000cab0 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <memstat_find_index>:
}

// swapin handled in swap.c

// Helper: locate or create page_stat entry for va in p->memstat
static int memstat_find_index(struct proc *p, uint64 va) {
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
    80000ef4:	882a                	mv	a6,a0
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80000ef6:	678d                	lui	a5,0x3
    80000ef8:	18878793          	addi	a5,a5,392 # 3188 <_entry-0x7fffce78>
    80000efc:	97aa                	add	a5,a5,a0
    80000efe:	4501                	li	a0,0
    if(p->memstat.pages[i].state != UNMAPPED && p->memstat.pages[i].va == (uint)va)
    80000f00:	0005861b          	sext.w	a2,a1
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80000f04:	08000693          	li	a3,128
    80000f08:	a029                	j	80000f12 <memstat_find_index+0x24>
    80000f0a:	2505                	addiw	a0,a0,1
    80000f0c:	07d1                	addi	a5,a5,20
    80000f0e:	00d50a63          	beq	a0,a3,80000f22 <memstat_find_index+0x34>
    if(p->memstat.pages[i].state != UNMAPPED && p->memstat.pages[i].va == (uint)va)
    80000f12:	43d8                	lw	a4,4(a5)
    80000f14:	db7d                	beqz	a4,80000f0a <memstat_find_index+0x1c>
    80000f16:	4398                	lw	a4,0(a5)
    80000f18:	fec719e3          	bne	a4,a2,80000f0a <memstat_find_index+0x1c>
      p->memstat.pages[i].va = (uint)va;
      return i;
    }
  }
  return -1;
}
    80000f1c:	6422                	ld	s0,8(sp)
    80000f1e:	0141                	addi	sp,sp,16
    80000f20:	8082                	ret
    80000f22:	678d                	lui	a5,0x3
    80000f24:	18c78793          	addi	a5,a5,396 # 318c <_entry-0x7fffce74>
    80000f28:	97c2                	add	a5,a5,a6
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80000f2a:	4501                	li	a0,0
    80000f2c:	08000693          	li	a3,128
    if(p->memstat.pages[i].state == UNMAPPED){
    80000f30:	4398                	lw	a4,0(a5)
    80000f32:	c719                	beqz	a4,80000f40 <memstat_find_index+0x52>
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80000f34:	2505                	addiw	a0,a0,1
    80000f36:	07d1                	addi	a5,a5,20
    80000f38:	fed51ce3          	bne	a0,a3,80000f30 <memstat_find_index+0x42>
  return -1;
    80000f3c:	557d                	li	a0,-1
    80000f3e:	bff9                	j	80000f1c <memstat_find_index+0x2e>
      p->memstat.pages[i].va = (uint)va;
    80000f40:	00251793          	slli	a5,a0,0x2
    80000f44:	97aa                	add	a5,a5,a0
    80000f46:	078a                	slli	a5,a5,0x2
    80000f48:	983e                	add	a6,a6,a5
    80000f4a:	678d                	lui	a5,0x3
    80000f4c:	97c2                	add	a5,a5,a6
    80000f4e:	18b7a423          	sw	a1,392(a5) # 3188 <_entry-0x7fffce78>
      return i;
    80000f52:	b7e9                	j	80000f1c <memstat_find_index+0x2e>

0000000080000f54 <memstat_mark_unmapped>:
    p->memstat.pages[idx].is_dirty = 0; // default clean on load/alloc
    p->memstat.pages[idx].swap_slot = -1;
  }
}

static void memstat_mark_unmapped(struct proc* p, uint64 va){
    80000f54:	1101                	addi	sp,sp,-32
    80000f56:	ec06                	sd	ra,24(sp)
    80000f58:	e822                	sd	s0,16(sp)
    80000f5a:	e426                	sd	s1,8(sp)
    80000f5c:	1000                	addi	s0,sp,32
    80000f5e:	84aa                	mv	s1,a0
  int idx = memstat_find_index(p, va);
    80000f60:	f8fff0ef          	jal	80000eee <memstat_find_index>
  if(idx >= 0){
    80000f64:	02054c63          	bltz	a0,80000f9c <memstat_mark_unmapped+0x48>
    if(p->memstat.pages[idx].state == RESIDENT && p->memstat.num_resident_pages>0)
    80000f68:	00251793          	slli	a5,a0,0x2
    80000f6c:	97aa                	add	a5,a5,a0
    80000f6e:	078a                	slli	a5,a5,0x2
    80000f70:	97a6                	add	a5,a5,s1
    80000f72:	670d                	lui	a4,0x3
    80000f74:	97ba                	add	a5,a5,a4
    80000f76:	18c7a703          	lw	a4,396(a5)
    80000f7a:	4785                	li	a5,1
    80000f7c:	02f70563          	beq	a4,a5,80000fa6 <memstat_mark_unmapped+0x52>
      p->memstat.num_resident_pages--;
    p->memstat.pages[idx].state = UNMAPPED;
    80000f80:	00251713          	slli	a4,a0,0x2
    80000f84:	00a707b3          	add	a5,a4,a0
    80000f88:	078a                	slli	a5,a5,0x2
    80000f8a:	97a6                	add	a5,a5,s1
    80000f8c:	668d                	lui	a3,0x3
    80000f8e:	97b6                	add	a5,a5,a3
    80000f90:	1807a623          	sw	zero,396(a5)
    p->memstat.pages[idx].swap_slot = -1;
    80000f94:	86be                	mv	a3,a5
    80000f96:	57fd                	li	a5,-1
    80000f98:	18f6ac23          	sw	a5,408(a3) # 3198 <_entry-0x7fffce68>
  }
}
    80000f9c:	60e2                	ld	ra,24(sp)
    80000f9e:	6442                	ld	s0,16(sp)
    80000fa0:	64a2                	ld	s1,8(sp)
    80000fa2:	6105                	addi	sp,sp,32
    80000fa4:	8082                	ret
    if(p->memstat.pages[idx].state == RESIDENT && p->memstat.num_resident_pages>0)
    80000fa6:	678d                	lui	a5,0x3
    80000fa8:	97a6                	add	a5,a5,s1
    80000faa:	17c7a783          	lw	a5,380(a5) # 317c <_entry-0x7fffce84>
    80000fae:	fcf059e3          	blez	a5,80000f80 <memstat_mark_unmapped+0x2c>
      p->memstat.num_resident_pages--;
    80000fb2:	670d                	lui	a4,0x3
    80000fb4:	9726                	add	a4,a4,s1
    80000fb6:	37fd                	addiw	a5,a5,-1
    80000fb8:	16f72e23          	sw	a5,380(a4) # 317c <_entry-0x7fffce84>
    80000fbc:	b7d1                	j	80000f80 <memstat_mark_unmapped+0x2c>

0000000080000fbe <kvminithart>:
{
    80000fbe:	1141                	addi	sp,sp,-16
    80000fc0:	e422                	sd	s0,8(sp)
    80000fc2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fc4:	12000073          	sfence.vma
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fc8:	0000c797          	auipc	a5,0xc
    80000fcc:	af07b783          	ld	a5,-1296(a5) # 8000cab8 <kernel_pagetable>
    80000fd0:	83b1                	srli	a5,a5,0xc
    80000fd2:	577d                	li	a4,-1
    80000fd4:	177e                	slli	a4,a4,0x3f
    80000fd6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fd8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fdc:	12000073          	sfence.vma
}
    80000fe0:	6422                	ld	s0,8(sp)
    80000fe2:	0141                	addi	sp,sp,16
    80000fe4:	8082                	ret

0000000080000fe6 <walk>:
{
    80000fe6:	7139                	addi	sp,sp,-64
    80000fe8:	fc06                	sd	ra,56(sp)
    80000fea:	f822                	sd	s0,48(sp)
    80000fec:	f426                	sd	s1,40(sp)
    80000fee:	f04a                	sd	s2,32(sp)
    80000ff0:	ec4e                	sd	s3,24(sp)
    80000ff2:	e852                	sd	s4,16(sp)
    80000ff4:	e456                	sd	s5,8(sp)
    80000ff6:	e05a                	sd	s6,0(sp)
    80000ff8:	0080                	addi	s0,sp,64
    80000ffa:	84aa                	mv	s1,a0
    80000ffc:	89ae                	mv	s3,a1
    80000ffe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001000:	57fd                	li	a5,-1
    80001002:	83e9                	srli	a5,a5,0x1a
    80001004:	4a79                	li	s4,30
  for(int level = 2; level > 0; level--) {
    80001006:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001008:	02b7fc63          	bgeu	a5,a1,80001040 <walk+0x5a>
    panic("walk");
    8000100c:	00008517          	auipc	a0,0x8
    80001010:	09c50513          	addi	a0,a0,156 # 800090a8 <etext+0xa8>
    80001014:	fccff0ef          	jal	800007e0 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001018:	060a8263          	beqz	s5,8000107c <walk+0x96>
    8000101c:	ae3ff0ef          	jal	80000afe <kalloc>
    80001020:	84aa                	mv	s1,a0
    80001022:	c139                	beqz	a0,80001068 <walk+0x82>
      memset(pagetable, 0, PGSIZE);
    80001024:	6605                	lui	a2,0x1
    80001026:	4581                	li	a1,0
    80001028:	c7bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000102c:	00c4d793          	srli	a5,s1,0xc
    80001030:	07aa                	slli	a5,a5,0xa
    80001032:	0017e793          	ori	a5,a5,1
    80001036:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000103a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7feeee1f>
    8000103c:	036a0063          	beq	s4,s6,8000105c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001040:	0149d933          	srl	s2,s3,s4
    80001044:	1ff97913          	andi	s2,s2,511
    80001048:	090e                	slli	s2,s2,0x3
    8000104a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000104c:	00093483          	ld	s1,0(s2)
    80001050:	0014f793          	andi	a5,s1,1
    80001054:	d3f1                	beqz	a5,80001018 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001056:	80a9                	srli	s1,s1,0xa
    80001058:	04b2                	slli	s1,s1,0xc
    8000105a:	b7c5                	j	8000103a <walk+0x54>
  return &pagetable[PX(0, va)];
    8000105c:	00c9d513          	srli	a0,s3,0xc
    80001060:	1ff57513          	andi	a0,a0,511
    80001064:	050e                	slli	a0,a0,0x3
    80001066:	9526                	add	a0,a0,s1
}
    80001068:	70e2                	ld	ra,56(sp)
    8000106a:	7442                	ld	s0,48(sp)
    8000106c:	74a2                	ld	s1,40(sp)
    8000106e:	7902                	ld	s2,32(sp)
    80001070:	69e2                	ld	s3,24(sp)
    80001072:	6a42                	ld	s4,16(sp)
    80001074:	6aa2                	ld	s5,8(sp)
    80001076:	6b02                	ld	s6,0(sp)
    80001078:	6121                	addi	sp,sp,64
    8000107a:	8082                	ret
        return 0;
    8000107c:	4501                	li	a0,0
    8000107e:	b7ed                	j	80001068 <walk+0x82>

0000000080001080 <walkaddr>:
  if(va >= MAXVA)
    80001080:	57fd                	li	a5,-1
    80001082:	83e9                	srli	a5,a5,0x1a
    80001084:	00b7f463          	bgeu	a5,a1,8000108c <walkaddr+0xc>
    return 0;
    80001088:	4501                	li	a0,0
}
    8000108a:	8082                	ret
{
    8000108c:	1141                	addi	sp,sp,-16
    8000108e:	e406                	sd	ra,8(sp)
    80001090:	e022                	sd	s0,0(sp)
    80001092:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001094:	4601                	li	a2,0
    80001096:	f51ff0ef          	jal	80000fe6 <walk>
  if(pte == 0)
    8000109a:	c105                	beqz	a0,800010ba <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    8000109c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109e:	0117f693          	andi	a3,a5,17
    800010a2:	4745                	li	a4,17
    return 0;
    800010a4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a6:	00e68663          	beq	a3,a4,800010b2 <walkaddr+0x32>
}
    800010aa:	60a2                	ld	ra,8(sp)
    800010ac:	6402                	ld	s0,0(sp)
    800010ae:	0141                	addi	sp,sp,16
    800010b0:	8082                	ret
  pa = PTE2PA(*pte);
    800010b2:	83a9                	srli	a5,a5,0xa
    800010b4:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010b8:	bfcd                	j	800010aa <walkaddr+0x2a>
    return 0;
    800010ba:	4501                	li	a0,0
    800010bc:	b7fd                	j	800010aa <walkaddr+0x2a>

00000000800010be <mappages>:
{
    800010be:	715d                	addi	sp,sp,-80
    800010c0:	e486                	sd	ra,72(sp)
    800010c2:	e0a2                	sd	s0,64(sp)
    800010c4:	fc26                	sd	s1,56(sp)
    800010c6:	f84a                	sd	s2,48(sp)
    800010c8:	f44e                	sd	s3,40(sp)
    800010ca:	f052                	sd	s4,32(sp)
    800010cc:	ec56                	sd	s5,24(sp)
    800010ce:	e85a                	sd	s6,16(sp)
    800010d0:	e45e                	sd	s7,8(sp)
    800010d2:	0880                	addi	s0,sp,80
  if((va % PGSIZE) != 0)
    800010d4:	03459793          	slli	a5,a1,0x34
    800010d8:	e7a9                	bnez	a5,80001122 <mappages+0x64>
    800010da:	8aaa                	mv	s5,a0
    800010dc:	8b3a                	mv	s6,a4
  if((size % PGSIZE) != 0)
    800010de:	03461793          	slli	a5,a2,0x34
    800010e2:	e7b1                	bnez	a5,8000112e <mappages+0x70>
  if(size == 0)
    800010e4:	ca39                	beqz	a2,8000113a <mappages+0x7c>
  last = va + size - PGSIZE;
    800010e6:	77fd                	lui	a5,0xfffff
    800010e8:	963e                	add	a2,a2,a5
    800010ea:	00b609b3          	add	s3,a2,a1
  a = va;
    800010ee:	892e                	mv	s2,a1
    800010f0:	40b68a33          	sub	s4,a3,a1
    a += PGSIZE;
    800010f4:	6b85                	lui	s7,0x1
    800010f6:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	4605                	li	a2,1
    800010fc:	85ca                	mv	a1,s2
    800010fe:	8556                	mv	a0,s5
    80001100:	ee7ff0ef          	jal	80000fe6 <walk>
    80001104:	c539                	beqz	a0,80001152 <mappages+0x94>
    if(*pte & PTE_V)
    80001106:	611c                	ld	a5,0(a0)
    80001108:	8b85                	andi	a5,a5,1
    8000110a:	ef95                	bnez	a5,80001146 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000110c:	80b1                	srli	s1,s1,0xc
    8000110e:	04aa                	slli	s1,s1,0xa
    80001110:	0164e4b3          	or	s1,s1,s6
    80001114:	0014e493          	ori	s1,s1,1
    80001118:	e104                	sd	s1,0(a0)
    if(a == last)
    8000111a:	05390863          	beq	s2,s3,8000116a <mappages+0xac>
    a += PGSIZE;
    8000111e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001120:	bfd9                	j	800010f6 <mappages+0x38>
    panic("mappages: va not aligned");
    80001122:	00008517          	auipc	a0,0x8
    80001126:	f8e50513          	addi	a0,a0,-114 # 800090b0 <etext+0xb0>
    8000112a:	eb6ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000112e:	00008517          	auipc	a0,0x8
    80001132:	fa250513          	addi	a0,a0,-94 # 800090d0 <etext+0xd0>
    80001136:	eaaff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000113a:	00008517          	auipc	a0,0x8
    8000113e:	fb650513          	addi	a0,a0,-74 # 800090f0 <etext+0xf0>
    80001142:	e9eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001146:	00008517          	auipc	a0,0x8
    8000114a:	fba50513          	addi	a0,a0,-70 # 80009100 <etext+0x100>
    8000114e:	e92ff0ef          	jal	800007e0 <panic>
      return -1;
    80001152:	557d                	li	a0,-1
}
    80001154:	60a6                	ld	ra,72(sp)
    80001156:	6406                	ld	s0,64(sp)
    80001158:	74e2                	ld	s1,56(sp)
    8000115a:	7942                	ld	s2,48(sp)
    8000115c:	79a2                	ld	s3,40(sp)
    8000115e:	7a02                	ld	s4,32(sp)
    80001160:	6ae2                	ld	s5,24(sp)
    80001162:	6b42                	ld	s6,16(sp)
    80001164:	6ba2                	ld	s7,8(sp)
    80001166:	6161                	addi	sp,sp,80
    80001168:	8082                	ret
  return 0;
    8000116a:	4501                	li	a0,0
    8000116c:	b7e5                	j	80001154 <mappages+0x96>

000000008000116e <kvmmap>:
{
    8000116e:	1141                	addi	sp,sp,-16
    80001170:	e406                	sd	ra,8(sp)
    80001172:	e022                	sd	s0,0(sp)
    80001174:	0800                	addi	s0,sp,16
    80001176:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001178:	86b2                	mv	a3,a2
    8000117a:	863e                	mv	a2,a5
    8000117c:	f43ff0ef          	jal	800010be <mappages>
    80001180:	e509                	bnez	a0,8000118a <kvmmap+0x1c>
}
    80001182:	60a2                	ld	ra,8(sp)
    80001184:	6402                	ld	s0,0(sp)
    80001186:	0141                	addi	sp,sp,16
    80001188:	8082                	ret
    panic("kvmmap");
    8000118a:	00008517          	auipc	a0,0x8
    8000118e:	f8650513          	addi	a0,a0,-122 # 80009110 <etext+0x110>
    80001192:	e4eff0ef          	jal	800007e0 <panic>

0000000080001196 <kvmmake>:
{
    80001196:	1101                	addi	sp,sp,-32
    80001198:	ec06                	sd	ra,24(sp)
    8000119a:	e822                	sd	s0,16(sp)
    8000119c:	e426                	sd	s1,8(sp)
    8000119e:	e04a                	sd	s2,0(sp)
    800011a0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011a2:	95dff0ef          	jal	80000afe <kalloc>
    800011a6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a8:	6605                	lui	a2,0x1
    800011aa:	4581                	li	a1,0
    800011ac:	af7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	6685                	lui	a3,0x1
    800011b4:	10000637          	lui	a2,0x10000
    800011b8:	100005b7          	lui	a1,0x10000
    800011bc:	8526                	mv	a0,s1
    800011be:	fb1ff0ef          	jal	8000116e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c2:	4719                	li	a4,6
    800011c4:	6685                	lui	a3,0x1
    800011c6:	10001637          	lui	a2,0x10001
    800011ca:	100015b7          	lui	a1,0x10001
    800011ce:	8526                	mv	a0,s1
    800011d0:	f9fff0ef          	jal	8000116e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	040006b7          	lui	a3,0x4000
    800011da:	0c000637          	lui	a2,0xc000
    800011de:	0c0005b7          	lui	a1,0xc000
    800011e2:	8526                	mv	a0,s1
    800011e4:	f8bff0ef          	jal	8000116e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e8:	00008917          	auipc	s2,0x8
    800011ec:	e1890913          	addi	s2,s2,-488 # 80009000 <etext>
    800011f0:	4729                	li	a4,10
    800011f2:	80008697          	auipc	a3,0x80008
    800011f6:	e0e68693          	addi	a3,a3,-498 # 9000 <_entry-0x7fff7000>
    800011fa:	4605                	li	a2,1
    800011fc:	067e                	slli	a2,a2,0x1f
    800011fe:	85b2                	mv	a1,a2
    80001200:	8526                	mv	a0,s1
    80001202:	f6dff0ef          	jal	8000116e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001206:	46c5                	li	a3,17
    80001208:	06ee                	slli	a3,a3,0x1b
    8000120a:	4719                	li	a4,6
    8000120c:	412686b3          	sub	a3,a3,s2
    80001210:	864a                	mv	a2,s2
    80001212:	85ca                	mv	a1,s2
    80001214:	8526                	mv	a0,s1
    80001216:	f59ff0ef          	jal	8000116e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000121a:	4729                	li	a4,10
    8000121c:	6685                	lui	a3,0x1
    8000121e:	00007617          	auipc	a2,0x7
    80001222:	de260613          	addi	a2,a2,-542 # 80008000 <_trampoline>
    80001226:	040005b7          	lui	a1,0x4000
    8000122a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000122c:	05b2                	slli	a1,a1,0xc
    8000122e:	8526                	mv	a0,s1
    80001230:	f3fff0ef          	jal	8000116e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001234:	8526                	mv	a0,s1
    80001236:	2e3000ef          	jal	80001d18 <proc_mapstacks>
}
    8000123a:	8526                	mv	a0,s1
    8000123c:	60e2                	ld	ra,24(sp)
    8000123e:	6442                	ld	s0,16(sp)
    80001240:	64a2                	ld	s1,8(sp)
    80001242:	6902                	ld	s2,0(sp)
    80001244:	6105                	addi	sp,sp,32
    80001246:	8082                	ret

0000000080001248 <kvminit>:
{
    80001248:	1141                	addi	sp,sp,-16
    8000124a:	e406                	sd	ra,8(sp)
    8000124c:	e022                	sd	s0,0(sp)
    8000124e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001250:	f47ff0ef          	jal	80001196 <kvmmake>
    80001254:	0000c797          	auipc	a5,0xc
    80001258:	86a7b223          	sd	a0,-1948(a5) # 8000cab8 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmcreate>:
{
    80001264:	1101                	addi	sp,sp,-32
    80001266:	ec06                	sd	ra,24(sp)
    80001268:	e822                	sd	s0,16(sp)
    8000126a:	e426                	sd	s1,8(sp)
    8000126c:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000126e:	891ff0ef          	jal	80000afe <kalloc>
    80001272:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001274:	c509                	beqz	a0,8000127e <uvmcreate+0x1a>
  memset(pagetable, 0, PGSIZE);
    80001276:	6605                	lui	a2,0x1
    80001278:	4581                	li	a1,0
    8000127a:	a29ff0ef          	jal	80000ca2 <memset>
}
    8000127e:	8526                	mv	a0,s1
    80001280:	60e2                	ld	ra,24(sp)
    80001282:	6442                	ld	s0,16(sp)
    80001284:	64a2                	ld	s1,8(sp)
    80001286:	6105                	addi	sp,sp,32
    80001288:	8082                	ret

000000008000128a <uvmunmap>:
{
    8000128a:	7139                	addi	sp,sp,-64
    8000128c:	fc06                	sd	ra,56(sp)
    8000128e:	f822                	sd	s0,48(sp)
    80001290:	0080                	addi	s0,sp,64
  if((va % PGSIZE) != 0)
    80001292:	03459793          	slli	a5,a1,0x34
    80001296:	e38d                	bnez	a5,800012b8 <uvmunmap+0x2e>
    80001298:	f04a                	sd	s2,32(sp)
    8000129a:	ec4e                	sd	s3,24(sp)
    8000129c:	e852                	sd	s4,16(sp)
    8000129e:	e456                	sd	s5,8(sp)
    800012a0:	e05a                	sd	s6,0(sp)
    800012a2:	8a2a                	mv	s4,a0
    800012a4:	892e                	mv	s2,a1
    800012a6:	8ab6                	mv	s5,a3
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a8:	0632                	slli	a2,a2,0xc
    800012aa:	00b609b3          	add	s3,a2,a1
    800012ae:	6b05                	lui	s6,0x1
    800012b0:	0535f963          	bgeu	a1,s3,80001302 <uvmunmap+0x78>
    800012b4:	f426                	sd	s1,40(sp)
    800012b6:	a015                	j	800012da <uvmunmap+0x50>
    800012b8:	f426                	sd	s1,40(sp)
    800012ba:	f04a                	sd	s2,32(sp)
    800012bc:	ec4e                	sd	s3,24(sp)
    800012be:	e852                	sd	s4,16(sp)
    800012c0:	e456                	sd	s5,8(sp)
    800012c2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800012c4:	00008517          	auipc	a0,0x8
    800012c8:	e5450513          	addi	a0,a0,-428 # 80009118 <etext+0x118>
    800012cc:	d14ff0ef          	jal	800007e0 <panic>
    *pte = 0;
    800012d0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d4:	995a                	add	s2,s2,s6
    800012d6:	03397563          	bgeu	s2,s3,80001300 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800012da:	4601                	li	a2,0
    800012dc:	85ca                	mv	a1,s2
    800012de:	8552                	mv	a0,s4
    800012e0:	d07ff0ef          	jal	80000fe6 <walk>
    800012e4:	84aa                	mv	s1,a0
    800012e6:	d57d                	beqz	a0,800012d4 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800012e8:	611c                	ld	a5,0(a0)
    800012ea:	0017f713          	andi	a4,a5,1
    800012ee:	d37d                	beqz	a4,800012d4 <uvmunmap+0x4a>
    if(do_free){
    800012f0:	fe0a80e3          	beqz	s5,800012d0 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012f4:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800012f6:	00c79513          	slli	a0,a5,0xc
    800012fa:	f22ff0ef          	jal	80000a1c <kfree>
    800012fe:	bfc9                	j	800012d0 <uvmunmap+0x46>
    80001300:	74a2                	ld	s1,40(sp)
    80001302:	7902                	ld	s2,32(sp)
    80001304:	69e2                	ld	s3,24(sp)
    80001306:	6a42                	ld	s4,16(sp)
    80001308:	6aa2                	ld	s5,8(sp)
    8000130a:	6b02                	ld	s6,0(sp)
}
    8000130c:	70e2                	ld	ra,56(sp)
    8000130e:	7442                	ld	s0,48(sp)
    80001310:	6121                	addi	sp,sp,64
    80001312:	8082                	ret

0000000080001314 <uvmdealloc>:
{
    80001314:	1101                	addi	sp,sp,-32
    80001316:	ec06                	sd	ra,24(sp)
    80001318:	e822                	sd	s0,16(sp)
    8000131a:	e426                	sd	s1,8(sp)
    8000131c:	1000                	addi	s0,sp,32
    return oldsz;
    8000131e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001320:	00b67d63          	bgeu	a2,a1,8000133a <uvmdealloc+0x26>
    80001324:	84b2                	mv	s1,a2
  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001326:	6785                	lui	a5,0x1
    80001328:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000132a:	00f60733          	add	a4,a2,a5
    8000132e:	76fd                	lui	a3,0xfffff
    80001330:	8f75                	and	a4,a4,a3
    80001332:	97ae                	add	a5,a5,a1
    80001334:	8ff5                	and	a5,a5,a3
    80001336:	00f76863          	bltu	a4,a5,80001346 <uvmdealloc+0x32>
}
    8000133a:	8526                	mv	a0,s1
    8000133c:	60e2                	ld	ra,24(sp)
    8000133e:	6442                	ld	s0,16(sp)
    80001340:	64a2                	ld	s1,8(sp)
    80001342:	6105                	addi	sp,sp,32
    80001344:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001346:	8f99                	sub	a5,a5,a4
    80001348:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000134a:	4685                	li	a3,1
    8000134c:	0007861b          	sext.w	a2,a5
    80001350:	85ba                	mv	a1,a4
    80001352:	f39ff0ef          	jal	8000128a <uvmunmap>
    80001356:	b7d5                	j	8000133a <uvmdealloc+0x26>

0000000080001358 <uvmalloc>:
  if(newsz < oldsz)
    80001358:	08b66f63          	bltu	a2,a1,800013f6 <uvmalloc+0x9e>
{
    8000135c:	7139                	addi	sp,sp,-64
    8000135e:	fc06                	sd	ra,56(sp)
    80001360:	f822                	sd	s0,48(sp)
    80001362:	ec4e                	sd	s3,24(sp)
    80001364:	e852                	sd	s4,16(sp)
    80001366:	e456                	sd	s5,8(sp)
    80001368:	0080                	addi	s0,sp,64
    8000136a:	8aaa                	mv	s5,a0
    8000136c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000136e:	6785                	lui	a5,0x1
    80001370:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001372:	95be                	add	a1,a1,a5
    80001374:	77fd                	lui	a5,0xfffff
    80001376:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000137a:	08c9f063          	bgeu	s3,a2,800013fa <uvmalloc+0xa2>
    8000137e:	f426                	sd	s1,40(sp)
    80001380:	f04a                	sd	s2,32(sp)
    80001382:	e05a                	sd	s6,0(sp)
    80001384:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001386:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000138a:	f74ff0ef          	jal	80000afe <kalloc>
    8000138e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001390:	c515                	beqz	a0,800013bc <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001392:	6605                	lui	a2,0x1
    80001394:	4581                	li	a1,0
    80001396:	90dff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000139a:	875a                	mv	a4,s6
    8000139c:	86a6                	mv	a3,s1
    8000139e:	6605                	lui	a2,0x1
    800013a0:	85ca                	mv	a1,s2
    800013a2:	8556                	mv	a0,s5
    800013a4:	d1bff0ef          	jal	800010be <mappages>
    800013a8:	e915                	bnez	a0,800013dc <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013aa:	6785                	lui	a5,0x1
    800013ac:	993e                	add	s2,s2,a5
    800013ae:	fd496ee3          	bltu	s2,s4,8000138a <uvmalloc+0x32>
  return newsz;
    800013b2:	8552                	mv	a0,s4
    800013b4:	74a2                	ld	s1,40(sp)
    800013b6:	7902                	ld	s2,32(sp)
    800013b8:	6b02                	ld	s6,0(sp)
    800013ba:	a811                	j	800013ce <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013bc:	864e                	mv	a2,s3
    800013be:	85ca                	mv	a1,s2
    800013c0:	8556                	mv	a0,s5
    800013c2:	f53ff0ef          	jal	80001314 <uvmdealloc>
      return 0;
    800013c6:	4501                	li	a0,0
    800013c8:	74a2                	ld	s1,40(sp)
    800013ca:	7902                	ld	s2,32(sp)
    800013cc:	6b02                	ld	s6,0(sp)
}
    800013ce:	70e2                	ld	ra,56(sp)
    800013d0:	7442                	ld	s0,48(sp)
    800013d2:	69e2                	ld	s3,24(sp)
    800013d4:	6a42                	ld	s4,16(sp)
    800013d6:	6aa2                	ld	s5,8(sp)
    800013d8:	6121                	addi	sp,sp,64
    800013da:	8082                	ret
      kfree(mem);
    800013dc:	8526                	mv	a0,s1
    800013de:	e3eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013e2:	864e                	mv	a2,s3
    800013e4:	85ca                	mv	a1,s2
    800013e6:	8556                	mv	a0,s5
    800013e8:	f2dff0ef          	jal	80001314 <uvmdealloc>
      return 0;
    800013ec:	4501                	li	a0,0
    800013ee:	74a2                	ld	s1,40(sp)
    800013f0:	7902                	ld	s2,32(sp)
    800013f2:	6b02                	ld	s6,0(sp)
    800013f4:	bfe9                	j	800013ce <uvmalloc+0x76>
    return oldsz;
    800013f6:	852e                	mv	a0,a1
}
    800013f8:	8082                	ret
  return newsz;
    800013fa:	8532                	mv	a0,a2
    800013fc:	bfc9                	j	800013ce <uvmalloc+0x76>

00000000800013fe <freewalk>:
{
    800013fe:	7179                	addi	sp,sp,-48
    80001400:	f406                	sd	ra,40(sp)
    80001402:	f022                	sd	s0,32(sp)
    80001404:	ec26                	sd	s1,24(sp)
    80001406:	e84a                	sd	s2,16(sp)
    80001408:	e44e                	sd	s3,8(sp)
    8000140a:	e052                	sd	s4,0(sp)
    8000140c:	1800                	addi	s0,sp,48
    8000140e:	8a2a                	mv	s4,a0
  for(int i = 0; i < 512; i++){
    80001410:	84aa                	mv	s1,a0
    80001412:	6905                	lui	s2,0x1
    80001414:	992a                	add	s2,s2,a0
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	4985                	li	s3,1
    80001418:	a819                	j	8000142e <freewalk+0x30>
      uint64 child = PTE2PA(pte);
    8000141a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000141c:	00c79513          	slli	a0,a5,0xc
    80001420:	fdfff0ef          	jal	800013fe <freewalk>
      pagetable[i] = 0;
    80001424:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001428:	04a1                	addi	s1,s1,8
    8000142a:	01248f63          	beq	s1,s2,80001448 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000142e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001430:	00f7f713          	andi	a4,a5,15
    80001434:	ff3703e3          	beq	a4,s3,8000141a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001438:	8b85                	andi	a5,a5,1
    8000143a:	d7fd                	beqz	a5,80001428 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000143c:	00008517          	auipc	a0,0x8
    80001440:	cf450513          	addi	a0,a0,-780 # 80009130 <etext+0x130>
    80001444:	b9cff0ef          	jal	800007e0 <panic>
  kfree((void*)pagetable);
    80001448:	8552                	mv	a0,s4
    8000144a:	dd2ff0ef          	jal	80000a1c <kfree>
}
    8000144e:	70a2                	ld	ra,40(sp)
    80001450:	7402                	ld	s0,32(sp)
    80001452:	64e2                	ld	s1,24(sp)
    80001454:	6942                	ld	s2,16(sp)
    80001456:	69a2                	ld	s3,8(sp)
    80001458:	6a02                	ld	s4,0(sp)
    8000145a:	6145                	addi	sp,sp,48
    8000145c:	8082                	ret

000000008000145e <uvmfree>:
{
    8000145e:	1101                	addi	sp,sp,-32
    80001460:	ec06                	sd	ra,24(sp)
    80001462:	e822                	sd	s0,16(sp)
    80001464:	e426                	sd	s1,8(sp)
    80001466:	1000                	addi	s0,sp,32
    80001468:	84aa                	mv	s1,a0
  if(sz > 0)
    8000146a:	e989                	bnez	a1,8000147c <uvmfree+0x1e>
  freewalk(pagetable);
    8000146c:	8526                	mv	a0,s1
    8000146e:	f91ff0ef          	jal	800013fe <freewalk>
}
    80001472:	60e2                	ld	ra,24(sp)
    80001474:	6442                	ld	s0,16(sp)
    80001476:	64a2                	ld	s1,8(sp)
    80001478:	6105                	addi	sp,sp,32
    8000147a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000147c:	6785                	lui	a5,0x1
    8000147e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001480:	95be                	add	a1,a1,a5
    80001482:	4685                	li	a3,1
    80001484:	00c5d613          	srli	a2,a1,0xc
    80001488:	4581                	li	a1,0
    8000148a:	e01ff0ef          	jal	8000128a <uvmunmap>
    8000148e:	bff9                	j	8000146c <uvmfree+0xe>

0000000080001490 <uvmcopy>:
  for(i = 0; i < sz; i += PGSIZE){
    80001490:	ce49                	beqz	a2,8000152a <uvmcopy+0x9a>
{
    80001492:	715d                	addi	sp,sp,-80
    80001494:	e486                	sd	ra,72(sp)
    80001496:	e0a2                	sd	s0,64(sp)
    80001498:	fc26                	sd	s1,56(sp)
    8000149a:	f84a                	sd	s2,48(sp)
    8000149c:	f44e                	sd	s3,40(sp)
    8000149e:	f052                	sd	s4,32(sp)
    800014a0:	ec56                	sd	s5,24(sp)
    800014a2:	e85a                	sd	s6,16(sp)
    800014a4:	e45e                	sd	s7,8(sp)
    800014a6:	0880                	addi	s0,sp,80
    800014a8:	8aaa                	mv	s5,a0
    800014aa:	8b2e                	mv	s6,a1
    800014ac:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014ae:	4481                	li	s1,0
    800014b0:	a029                	j	800014ba <uvmcopy+0x2a>
    800014b2:	6785                	lui	a5,0x1
    800014b4:	94be                	add	s1,s1,a5
    800014b6:	0544fe63          	bgeu	s1,s4,80001512 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800014ba:	4601                	li	a2,0
    800014bc:	85a6                	mv	a1,s1
    800014be:	8556                	mv	a0,s5
    800014c0:	b27ff0ef          	jal	80000fe6 <walk>
    800014c4:	d57d                	beqz	a0,800014b2 <uvmcopy+0x22>
    if((*pte & PTE_V) == 0)
    800014c6:	6118                	ld	a4,0(a0)
    800014c8:	00177793          	andi	a5,a4,1
    800014cc:	d3fd                	beqz	a5,800014b2 <uvmcopy+0x22>
    pa = PTE2PA(*pte);
    800014ce:	00a75593          	srli	a1,a4,0xa
    800014d2:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014d6:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800014da:	e24ff0ef          	jal	80000afe <kalloc>
    800014de:	89aa                	mv	s3,a0
    800014e0:	c105                	beqz	a0,80001500 <uvmcopy+0x70>
    memmove(mem, (char*)pa, PGSIZE);
    800014e2:	6605                	lui	a2,0x1
    800014e4:	85de                	mv	a1,s7
    800014e6:	819ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014ea:	874a                	mv	a4,s2
    800014ec:	86ce                	mv	a3,s3
    800014ee:	6605                	lui	a2,0x1
    800014f0:	85a6                	mv	a1,s1
    800014f2:	855a                	mv	a0,s6
    800014f4:	bcbff0ef          	jal	800010be <mappages>
    800014f8:	dd4d                	beqz	a0,800014b2 <uvmcopy+0x22>
      kfree(mem);
    800014fa:	854e                	mv	a0,s3
    800014fc:	d20ff0ef          	jal	80000a1c <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001500:	4685                	li	a3,1
    80001502:	00c4d613          	srli	a2,s1,0xc
    80001506:	4581                	li	a1,0
    80001508:	855a                	mv	a0,s6
    8000150a:	d81ff0ef          	jal	8000128a <uvmunmap>
  return -1;
    8000150e:	557d                	li	a0,-1
    80001510:	a011                	j	80001514 <uvmcopy+0x84>
  return 0;
    80001512:	4501                	li	a0,0
}
    80001514:	60a6                	ld	ra,72(sp)
    80001516:	6406                	ld	s0,64(sp)
    80001518:	74e2                	ld	s1,56(sp)
    8000151a:	7942                	ld	s2,48(sp)
    8000151c:	79a2                	ld	s3,40(sp)
    8000151e:	7a02                	ld	s4,32(sp)
    80001520:	6ae2                	ld	s5,24(sp)
    80001522:	6b42                	ld	s6,16(sp)
    80001524:	6ba2                	ld	s7,8(sp)
    80001526:	6161                	addi	sp,sp,80
    80001528:	8082                	ret
  return 0;
    8000152a:	4501                	li	a0,0
}
    8000152c:	8082                	ret

000000008000152e <uvmclear>:
{
    8000152e:	1141                	addi	sp,sp,-16
    80001530:	e406                	sd	ra,8(sp)
    80001532:	e022                	sd	s0,0(sp)
    80001534:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001536:	4601                	li	a2,0
    80001538:	aafff0ef          	jal	80000fe6 <walk>
  if(pte == 0)
    8000153c:	c901                	beqz	a0,8000154c <uvmclear+0x1e>
  *pte &= ~PTE_U;
    8000153e:	611c                	ld	a5,0(a0)
    80001540:	9bbd                	andi	a5,a5,-17
    80001542:	e11c                	sd	a5,0(a0)
}
    80001544:	60a2                	ld	ra,8(sp)
    80001546:	6402                	ld	s0,0(sp)
    80001548:	0141                	addi	sp,sp,16
    8000154a:	8082                	ret
    panic("uvmclear");
    8000154c:	00008517          	auipc	a0,0x8
    80001550:	bf450513          	addi	a0,a0,-1036 # 80009140 <etext+0x140>
    80001554:	a8cff0ef          	jal	800007e0 <panic>

0000000080001558 <ismapped>:
{
    80001558:	1141                	addi	sp,sp,-16
    8000155a:	e406                	sd	ra,8(sp)
    8000155c:	e022                	sd	s0,0(sp)
    8000155e:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001560:	4601                	li	a2,0
    80001562:	a85ff0ef          	jal	80000fe6 <walk>
  if (pte == 0) {
    80001566:	c519                	beqz	a0,80001574 <ismapped+0x1c>
  if (*pte & PTE_V){
    80001568:	6108                	ld	a0,0(a0)
    8000156a:	8905                	andi	a0,a0,1
}
    8000156c:	60a2                	ld	ra,8(sp)
    8000156e:	6402                	ld	s0,0(sp)
    80001570:	0141                	addi	sp,sp,16
    80001572:	8082                	ret
    return 0;
    80001574:	4501                	li	a0,0
    80001576:	bfdd                	j	8000156c <ismapped+0x14>

0000000080001578 <memstat_mark_resident>:
void memstat_mark_resident(struct proc* p, uint64 va, int seq){
    80001578:	1101                	addi	sp,sp,-32
    8000157a:	ec06                	sd	ra,24(sp)
    8000157c:	e822                	sd	s0,16(sp)
    8000157e:	e426                	sd	s1,8(sp)
    80001580:	e04a                	sd	s2,0(sp)
    80001582:	1000                	addi	s0,sp,32
    80001584:	84aa                	mv	s1,a0
    80001586:	8932                	mv	s2,a2
  int idx = memstat_find_index(p, va);
    80001588:	967ff0ef          	jal	80000eee <memstat_find_index>
  if(idx >= 0){
    8000158c:	04054863          	bltz	a0,800015dc <memstat_mark_resident+0x64>
    if(p->memstat.pages[idx].state != RESIDENT) p->memstat.num_resident_pages++;
    80001590:	00251793          	slli	a5,a0,0x2
    80001594:	97aa                	add	a5,a5,a0
    80001596:	078a                	slli	a5,a5,0x2
    80001598:	97a6                	add	a5,a5,s1
    8000159a:	670d                	lui	a4,0x3
    8000159c:	97ba                	add	a5,a5,a4
    8000159e:	18c7a703          	lw	a4,396(a5) # 118c <_entry-0x7fffee74>
    800015a2:	4785                	li	a5,1
    800015a4:	00f70963          	beq	a4,a5,800015b6 <memstat_mark_resident+0x3e>
    800015a8:	678d                	lui	a5,0x3
    800015aa:	97a6                	add	a5,a5,s1
    800015ac:	17c7a703          	lw	a4,380(a5) # 317c <_entry-0x7fffce84>
    800015b0:	2705                	addiw	a4,a4,1 # 3001 <_entry-0x7fffcfff>
    800015b2:	16e7ae23          	sw	a4,380(a5)
    p->memstat.pages[idx].state = RESIDENT;
    800015b6:	00251713          	slli	a4,a0,0x2
    800015ba:	00a707b3          	add	a5,a4,a0
    800015be:	078a                	slli	a5,a5,0x2
    800015c0:	97a6                	add	a5,a5,s1
    800015c2:	668d                	lui	a3,0x3
    800015c4:	97b6                	add	a5,a5,a3
    800015c6:	4605                	li	a2,1
    800015c8:	18c7a623          	sw	a2,396(a5)
    p->memstat.pages[idx].seq = seq;
    800015cc:	1927aa23          	sw	s2,404(a5)
    p->memstat.pages[idx].is_dirty = 0; // default clean on load/alloc
    800015d0:	1807a823          	sw	zero,400(a5)
    p->memstat.pages[idx].swap_slot = -1;
    800015d4:	86be                	mv	a3,a5
    800015d6:	57fd                	li	a5,-1
    800015d8:	18f6ac23          	sw	a5,408(a3) # 3198 <_entry-0x7fffce68>
}
    800015dc:	60e2                	ld	ra,24(sp)
    800015de:	6442                	ld	s0,16(sp)
    800015e0:	64a2                	ld	s1,8(sp)
    800015e2:	6902                	ld	s2,0(sp)
    800015e4:	6105                	addi	sp,sp,32
    800015e6:	8082                	ret

00000000800015e8 <select_victim_fifo_index>:
    p->memstat.pages[idx].state = SWAPPED;
    p->memstat.pages[idx].swap_slot = slot;
  }
}

int select_victim_fifo_index(struct proc* p){
    800015e8:	1141                	addi	sp,sp,-16
    800015ea:	e422                	sd	s0,8(sp)
    800015ec:	0800                	addi	s0,sp,16
  int victim = -1;
  int victim_seq = 0;
  uint victim_va = 0;
  for(int i=0;i<MAX_PAGES_INFO;i++){
    800015ee:	678d                	lui	a5,0x3
    800015f0:	18878793          	addi	a5,a5,392 # 3188 <_entry-0x7fffce78>
    800015f4:	97aa                	add	a5,a5,a0
    800015f6:	4701                	li	a4,0
  uint victim_va = 0;
    800015f8:	4e81                	li	t4,0
  int victim_seq = 0;
    800015fa:	4881                	li	a7,0
  int victim = -1;
    800015fc:	557d                	li	a0,-1
    if(p->memstat.pages[i].state == RESIDENT){
    800015fe:	4805                	li	a6,1
      if(victim == -1 || (uint)p->memstat.pages[i].seq < (uint)victim_seq ||
    80001600:	5e7d                	li	t3,-1
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80001602:	08000593          	li	a1,128
    80001606:	a811                	j	8000161a <select_victim_fifo_index+0x32>
         ((uint)p->memstat.pages[i].seq == (uint)victim_seq && p->memstat.pages[i].va < victim_va)){
        victim = i;
        victim_seq = p->memstat.pages[i].seq;
    80001608:	00c62883          	lw	a7,12(a2) # 100c <_entry-0x7fffeff4>
        victim_va = p->memstat.pages[i].va;
    8000160c:	00062e83          	lw	t4,0(a2)
        victim = i;
    80001610:	853a                	mv	a0,a4
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80001612:	2705                	addiw	a4,a4,1
    80001614:	07d1                	addi	a5,a5,20
    80001616:	02b70363          	beq	a4,a1,8000163c <select_victim_fifo_index+0x54>
    if(p->memstat.pages[i].state == RESIDENT){
    8000161a:	863e                	mv	a2,a5
    8000161c:	43d4                	lw	a3,4(a5)
    8000161e:	ff069ae3          	bne	a3,a6,80001612 <select_victim_fifo_index+0x2a>
      if(victim == -1 || (uint)p->memstat.pages[i].seq < (uint)victim_seq ||
    80001622:	ffc503e3          	beq	a0,t3,80001608 <select_victim_fifo_index+0x20>
    80001626:	47d4                	lw	a3,12(a5)
    80001628:	0006831b          	sext.w	t1,a3
    8000162c:	fd136ee3          	bltu	t1,a7,80001608 <select_victim_fifo_index+0x20>
    80001630:	ff1691e3          	bne	a3,a7,80001612 <select_victim_fifo_index+0x2a>
         ((uint)p->memstat.pages[i].seq == (uint)victim_seq && p->memstat.pages[i].va < victim_va)){
    80001634:	4394                	lw	a3,0(a5)
    80001636:	fdd6fee3          	bgeu	a3,t4,80001612 <select_victim_fifo_index+0x2a>
    8000163a:	b7f9                	j	80001608 <select_victim_fifo_index+0x20>
      }
    }
  }
  return victim;
}
    8000163c:	6422                	ld	s0,8(sp)
    8000163e:	0141                	addi	sp,sp,16
    80001640:	8082                	ret

0000000080001642 <try_kalloc_or_replace>:

// Stub: pretend to write to swap, return a fake slot number.
// Try to kalloc; if fails, evict a page using FIFO and try again.
char* try_kalloc_or_replace(uint64 faulting_va){
    80001642:	7139                	addi	sp,sp,-64
    80001644:	fc06                	sd	ra,56(sp)
    80001646:	f822                	sd	s0,48(sp)
    80001648:	f426                	sd	s1,40(sp)
    8000164a:	ec4e                	sd	s3,24(sp)
    8000164c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000164e:	055000ef          	jal	80001ea2 <myproc>
    80001652:	89aa                	mv	s3,a0
  char *mem = 0;
  mem = kalloc();
    80001654:	caaff0ef          	jal	80000afe <kalloc>
    80001658:	84aa                	mv	s1,a0
  if(mem)
    8000165a:	c901                	beqz	a0,8000166a <try_kalloc_or_replace+0x28>
    sfence_vma();
  }
  // Try allocation again
  mem = kalloc();
  return mem;
}
    8000165c:	8526                	mv	a0,s1
    8000165e:	70e2                	ld	ra,56(sp)
    80001660:	7442                	ld	s0,48(sp)
    80001662:	74a2                	ld	s1,40(sp)
    80001664:	69e2                	ld	s3,24(sp)
    80001666:	6121                	addi	sp,sp,64
    80001668:	8082                	ret
    8000166a:	e852                	sd	s4,16(sp)
  printf("[pid %d] MEMFULL\n", p->pid);
    8000166c:	0309a583          	lw	a1,48(s3) # 1030 <_entry-0x7fffefd0>
    80001670:	00008517          	auipc	a0,0x8
    80001674:	af050513          	addi	a0,a0,-1296 # 80009160 <etext+0x160>
    80001678:	e83fe0ef          	jal	800004fa <printf>
  int idx = select_victim_fifo_index(p);
    8000167c:	854e                	mv	a0,s3
    8000167e:	f6bff0ef          	jal	800015e8 <select_victim_fifo_index>
    80001682:	8a2a                	mv	s4,a0
  if(idx < 0){
    80001684:	08054f63          	bltz	a0,80001722 <try_kalloc_or_replace+0xe0>
    80001688:	f04a                	sd	s2,32(sp)
    8000168a:	e456                	sd	s5,8(sp)
    8000168c:	e05a                	sd	s6,0(sp)
  uint64 va0 = PGROUNDDOWN((uint64)p->memstat.pages[idx].va);
    8000168e:	00251913          	slli	s2,a0,0x2
    80001692:	00a90733          	add	a4,s2,a0
    80001696:	070a                	slli	a4,a4,0x2
    80001698:	974e                	add	a4,a4,s3
    8000169a:	6b0d                	lui	s6,0x3
    8000169c:	975a                	add	a4,a4,s6
    8000169e:	18876a83          	lwu	s5,392(a4)
    800016a2:	77fd                	lui	a5,0xfffff
    800016a4:	00fafab3          	and	s5,s5,a5
  printf("[pid %d] VICTIM va=%p seq=%d algo=FIFO\n", p->pid, (void*)va0, seq);
    800016a8:	19472683          	lw	a3,404(a4)
    800016ac:	8656                	mv	a2,s5
    800016ae:	0309a583          	lw	a1,48(s3)
    800016b2:	00008517          	auipc	a0,0x8
    800016b6:	ae650513          	addi	a0,a0,-1306 # 80009198 <etext+0x198>
    800016ba:	e41fe0ef          	jal	800004fa <printf>
  int dirty = p->memstat.pages[idx].is_dirty;
    800016be:	9952                	add	s2,s2,s4
    800016c0:	090a                	slli	s2,s2,0x2
    800016c2:	994e                	add	s2,s2,s3
    800016c4:	012b07b3          	add	a5,s6,s2
    800016c8:	1907ab03          	lw	s6,400(a5) # fffffffffffff190 <end+0xffffffff7feeefb8>
  printf("[pid %d] EVICT  va=%p state=%s\n", p->pid, (void*)va0, dirty ? "dirty" : "clean");
    800016cc:	0309a583          	lw	a1,48(s3)
    800016d0:	00008697          	auipc	a3,0x8
    800016d4:	a8868693          	addi	a3,a3,-1400 # 80009158 <etext+0x158>
    800016d8:	000b0663          	beqz	s6,800016e4 <try_kalloc_or_replace+0xa2>
    800016dc:	00008697          	auipc	a3,0x8
    800016e0:	a7468693          	addi	a3,a3,-1420 # 80009150 <etext+0x150>
    800016e4:	8656                	mv	a2,s5
    800016e6:	00008517          	auipc	a0,0x8
    800016ea:	ada50513          	addi	a0,a0,-1318 # 800091c0 <etext+0x1c0>
    800016ee:	e0dfe0ef          	jal	800004fa <printf>
  pte_t *pte = walk(p->pagetable, va0, 0);
    800016f2:	4601                	li	a2,0
    800016f4:	85d6                	mv	a1,s5
    800016f6:	0509b503          	ld	a0,80(s3)
    800016fa:	8edff0ef          	jal	80000fe6 <walk>
    800016fe:	892a                	mv	s2,a0
  if(pte == 0 || (*pte & PTE_V) == 0){
    80001700:	c509                	beqz	a0,8000170a <try_kalloc_or_replace+0xc8>
    80001702:	6108                	ld	a0,0(a0)
    80001704:	00157793          	andi	a5,a0,1
    80001708:	eb95                	bnez	a5,8000173c <try_kalloc_or_replace+0xfa>
    memstat_mark_unmapped(p, va0);
    8000170a:	85d6                	mv	a1,s5
    8000170c:	854e                	mv	a0,s3
    8000170e:	847ff0ef          	jal	80000f54 <memstat_mark_unmapped>
  mem = kalloc();
    80001712:	becff0ef          	jal	80000afe <kalloc>
    80001716:	84aa                	mv	s1,a0
    80001718:	7902                	ld	s2,32(sp)
    8000171a:	6a42                	ld	s4,16(sp)
    8000171c:	6aa2                	ld	s5,8(sp)
    8000171e:	6b02                	ld	s6,0(sp)
  return mem;
    80001720:	bf35                	j	8000165c <try_kalloc_or_replace+0x1a>
    printf("[pid %d] KILL swap-exhausted\n", p->pid);
    80001722:	0309a583          	lw	a1,48(s3)
    80001726:	00008517          	auipc	a0,0x8
    8000172a:	a5250513          	addi	a0,a0,-1454 # 80009178 <etext+0x178>
    8000172e:	dcdfe0ef          	jal	800004fa <printf>
    setkilled(p);
    80001732:	854e                	mv	a0,s3
    80001734:	11e010ef          	jal	80002852 <setkilled>
    return 0;
    80001738:	6a42                	ld	s4,16(sp)
    8000173a:	b70d                	j	8000165c <try_kalloc_or_replace+0x1a>
    uint64 pa = PTE2PA(*pte);
    8000173c:	8129                	srli	a0,a0,0xa
    8000173e:	00c51a13          	slli	s4,a0,0xc
    if(dirty){
    80001742:	0c0b0f63          	beqz	s6,80001820 <try_kalloc_or_replace+0x1de>
      int slot = proc_swapout_page(p, va0, pa);
    80001746:	8652                	mv	a2,s4
    80001748:	85d6                	mv	a1,s5
    8000174a:	854e                	mv	a0,s3
    8000174c:	644050ef          	jal	80006d90 <proc_swapout_page>
    80001750:	8b2a                	mv	s6,a0
      if(slot < 0){
    80001752:	08054363          	bltz	a0,800017d8 <try_kalloc_or_replace+0x196>
      printf("[pid %d] SWAPOUT va=%p slot=%d\n", p->pid, (void*)va0, slot);
    80001756:	86aa                	mv	a3,a0
    80001758:	8656                	mv	a2,s5
    8000175a:	0309a583          	lw	a1,48(s3)
    8000175e:	00008517          	auipc	a0,0x8
    80001762:	a9a50513          	addi	a0,a0,-1382 # 800091f8 <etext+0x1f8>
    80001766:	d95fe0ef          	jal	800004fa <printf>
      if(p->resident_pages>0) p->resident_pages--;
    8000176a:	6791                	lui	a5,0x4
    8000176c:	97ce                	add	a5,a5,s3
    8000176e:	be47a783          	lw	a5,-1052(a5) # 3be4 <_entry-0x7fffc41c>
    80001772:	00f05763          	blez	a5,80001780 <try_kalloc_or_replace+0x13e>
    80001776:	6711                	lui	a4,0x4
    80001778:	974e                	add	a4,a4,s3
    8000177a:	37fd                	addiw	a5,a5,-1
    8000177c:	bef72223          	sw	a5,-1052(a4) # 3be4 <_entry-0x7fffc41c>
      p->swapped_pages++;
    80001780:	6791                	lui	a5,0x4
    80001782:	97ce                	add	a5,a5,s3
    80001784:	be87a703          	lw	a4,-1048(a5) # 3be8 <_entry-0x7fffc418>
    80001788:	2705                	addiw	a4,a4,1
    8000178a:	bee7a423          	sw	a4,-1048(a5)
      p->swapout_count++;
    8000178e:	bf07a703          	lw	a4,-1040(a5)
    80001792:	2705                	addiw	a4,a4,1
    80001794:	bee7a823          	sw	a4,-1040(a5)
  int idx = memstat_find_index(p, va);
    80001798:	85d6                	mv	a1,s5
    8000179a:	854e                	mv	a0,s3
    8000179c:	f52ff0ef          	jal	80000eee <memstat_find_index>
  if(idx >= 0){
    800017a0:	0a054863          	bltz	a0,80001850 <try_kalloc_or_replace+0x20e>
    if(p->memstat.pages[idx].state == RESIDENT && p->memstat.num_resident_pages>0)
    800017a4:	00251793          	slli	a5,a0,0x2
    800017a8:	97aa                	add	a5,a5,a0
    800017aa:	078a                	slli	a5,a5,0x2
    800017ac:	97ce                	add	a5,a5,s3
    800017ae:	670d                	lui	a4,0x3
    800017b0:	97ba                	add	a5,a5,a4
    800017b2:	18c7a703          	lw	a4,396(a5)
    800017b6:	4785                	li	a5,1
    800017b8:	04f70863          	beq	a4,a5,80001808 <try_kalloc_or_replace+0x1c6>
    p->memstat.pages[idx].state = SWAPPED;
    800017bc:	00251793          	slli	a5,a0,0x2
    800017c0:	00a78733          	add	a4,a5,a0
    800017c4:	070a                	slli	a4,a4,0x2
    800017c6:	974e                	add	a4,a4,s3
    800017c8:	668d                	lui	a3,0x3
    800017ca:	9736                	add	a4,a4,a3
    800017cc:	4609                	li	a2,2
    800017ce:	18c72623          	sw	a2,396(a4) # 318c <_entry-0x7fffce74>
    p->memstat.pages[idx].swap_slot = slot;
    800017d2:	19672c23          	sw	s6,408(a4)
    800017d6:	a8ad                	j	80001850 <try_kalloc_or_replace+0x20e>
        printf("[pid %d] SWAPFULL\n", p->pid);
    800017d8:	0309a583          	lw	a1,48(s3)
    800017dc:	00008517          	auipc	a0,0x8
    800017e0:	a0450513          	addi	a0,a0,-1532 # 800091e0 <etext+0x1e0>
    800017e4:	d17fe0ef          	jal	800004fa <printf>
        printf("[pid %d] KILL swap-exhausted\n", p->pid);
    800017e8:	0309a583          	lw	a1,48(s3)
    800017ec:	00008517          	auipc	a0,0x8
    800017f0:	98c50513          	addi	a0,a0,-1652 # 80009178 <etext+0x178>
    800017f4:	d07fe0ef          	jal	800004fa <printf>
        setkilled(p);
    800017f8:	854e                	mv	a0,s3
    800017fa:	058010ef          	jal	80002852 <setkilled>
        return 0;
    800017fe:	7902                	ld	s2,32(sp)
    80001800:	6a42                	ld	s4,16(sp)
    80001802:	6aa2                	ld	s5,8(sp)
    80001804:	6b02                	ld	s6,0(sp)
    80001806:	bd99                	j	8000165c <try_kalloc_or_replace+0x1a>
    if(p->memstat.pages[idx].state == RESIDENT && p->memstat.num_resident_pages>0)
    80001808:	678d                	lui	a5,0x3
    8000180a:	97ce                	add	a5,a5,s3
    8000180c:	17c7a783          	lw	a5,380(a5) # 317c <_entry-0x7fffce84>
    80001810:	faf056e3          	blez	a5,800017bc <try_kalloc_or_replace+0x17a>
      p->memstat.num_resident_pages--;
    80001814:	670d                	lui	a4,0x3
    80001816:	974e                	add	a4,a4,s3
    80001818:	37fd                	addiw	a5,a5,-1
    8000181a:	16f72e23          	sw	a5,380(a4) # 317c <_entry-0x7fffce84>
    8000181e:	bf79                	j	800017bc <try_kalloc_or_replace+0x17a>
      printf("[pid %d] DISCARD va=%p\n", p->pid, (void*)va0);
    80001820:	8656                	mv	a2,s5
    80001822:	0309a583          	lw	a1,48(s3)
    80001826:	00008517          	auipc	a0,0x8
    8000182a:	9f250513          	addi	a0,a0,-1550 # 80009218 <etext+0x218>
    8000182e:	ccdfe0ef          	jal	800004fa <printf>
      memstat_mark_unmapped(p, va0);
    80001832:	85d6                	mv	a1,s5
    80001834:	854e                	mv	a0,s3
    80001836:	f1eff0ef          	jal	80000f54 <memstat_mark_unmapped>
      if(p->resident_pages>0) p->resident_pages--;
    8000183a:	6791                	lui	a5,0x4
    8000183c:	97ce                	add	a5,a5,s3
    8000183e:	be47a703          	lw	a4,-1052(a5) # 3be4 <_entry-0x7fffc41c>
    80001842:	00e05763          	blez	a4,80001850 <try_kalloc_or_replace+0x20e>
    80001846:	6791                	lui	a5,0x4
    80001848:	97ce                	add	a5,a5,s3
    8000184a:	377d                	addiw	a4,a4,-1
    8000184c:	bee7a223          	sw	a4,-1052(a5) # 3be4 <_entry-0x7fffc41c>
    *pte = 0;
    80001850:	00093023          	sd	zero,0(s2) # 1000 <_entry-0x7ffff000>
    kfree((void*)pa);
    80001854:	8552                	mv	a0,s4
    80001856:	9c6ff0ef          	jal	80000a1c <kfree>
    8000185a:	12000073          	sfence.vma
}
    8000185e:	bd55                	j	80001712 <try_kalloc_or_replace+0xd0>

0000000080001860 <vmfault>:
{
    80001860:	715d                	addi	sp,sp,-80
    80001862:	e486                	sd	ra,72(sp)
    80001864:	e0a2                	sd	s0,64(sp)
    80001866:	fc26                	sd	s1,56(sp)
    80001868:	f84a                	sd	s2,48(sp)
    8000186a:	f44e                	sd	s3,40(sp)
    8000186c:	f052                	sd	s4,32(sp)
    8000186e:	ec56                	sd	s5,24(sp)
    80001870:	e85a                	sd	s6,16(sp)
    80001872:	e45e                	sd	s7,8(sp)
    80001874:	0880                	addi	s0,sp,80
    80001876:	8aaa                	mv	s5,a0
    80001878:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000187a:	628000ef          	jal	80001ea2 <myproc>
    8000187e:	89aa                	mv	s3,a0
  va = PGROUNDDOWN(va);
    80001880:	777d                	lui	a4,0xfffff
    80001882:	8cf9                	and	s1,s1,a4
  uint64 stack_end = PGROUNDUP(p->stack_top);
    80001884:	6791                	lui	a5,0x4
    80001886:	97aa                	add	a5,a5,a0
    80001888:	bb07b903          	ld	s2,-1104(a5) # 3bb0 <_entry-0x7fffc450>
    8000188c:	6785                	lui	a5,0x1
    8000188e:	fff78693          	addi	a3,a5,-1 # fff <_entry-0x7ffff001>
    80001892:	9936                	add	s2,s2,a3
    80001894:	00e97933          	and	s2,s2,a4
  uint64 stack_base = stack_end - (USERSTACK * PGSIZE);
    80001898:	40f90bb3          	sub	s7,s2,a5
  uint64 stack_guard = stack_end - ((USERSTACK + 1) * PGSIZE);
    8000189c:	7a79                	lui	s4,0xffffe
    8000189e:	9a4a                	add	s4,s4,s2
  if(va >= stack_guard && va < stack_base)
    800018a0:	0144e563          	bltu	s1,s4,800018aa <vmfault+0x4a>
    return 0; // guard page access is invalid
    800018a4:	4b01                	li	s6,0
  if(va >= stack_guard && va < stack_base)
    800018a6:	1b74ed63          	bltu	s1,s7,80001a60 <vmfault+0x200>
    800018aa:	e062                	sd	s8,0(sp)
  int under_brk = (va < p->sz);
    800018ac:	0489bc03          	ld	s8,72(s3)
  if(ismapped(pagetable, va)) {
    800018b0:	85a6                	mv	a1,s1
    800018b2:	8556                	mv	a0,s5
    800018b4:	ca5ff0ef          	jal	80001558 <ismapped>
    return 0;
    800018b8:	4b01                	li	s6,0
  if(ismapped(pagetable, va)) {
    800018ba:	1a051263          	bnez	a0,80001a5e <vmfault+0x1fe>
  int in_text = under_brk && (va >= p->text_start && va < p->text_end);
    800018be:	1584fd63          	bgeu	s1,s8,80001a18 <vmfault+0x1b8>
    800018c2:	6791                	lui	a5,0x4
    800018c4:	97ce                	add	a5,a5,s3
    800018c6:	b887b783          	ld	a5,-1144(a5) # 3b88 <_entry-0x7fffc478>
    800018ca:	8aaa                	mv	s5,a0
    800018cc:	00f4e863          	bltu	s1,a5,800018dc <vmfault+0x7c>
    800018d0:	6791                	lui	a5,0x4
    800018d2:	97ce                	add	a5,a5,s3
    800018d4:	b907ba83          	ld	s5,-1136(a5) # 3b90 <_entry-0x7fffc470>
    800018d8:	0154bab3          	sltu	s5,s1,s5
  int in_data = under_brk && (va >= p->data_start && va < p->data_end);
    800018dc:	6791                	lui	a5,0x4
    800018de:	97ce                	add	a5,a5,s3
    800018e0:	b987b783          	ld	a5,-1128(a5) # 3b98 <_entry-0x7fffc468>
    800018e4:	872a                	mv	a4,a0
    800018e6:	00f4e863          	bltu	s1,a5,800018f6 <vmfault+0x96>
    800018ea:	6791                	lui	a5,0x4
    800018ec:	97ce                	add	a5,a5,s3
    800018ee:	ba07b703          	ld	a4,-1120(a5) # 3ba0 <_entry-0x7fffc460>
    800018f2:	00e4b733          	sltu	a4,s1,a4
  int in_stack = under_brk && (va >= stack_base && va < stack_end);
    800018f6:	0174f763          	bgeu	s1,s7,80001904 <vmfault+0xa4>
    800018fa:	892a                	mv	s2,a0
  int in_heap = under_brk && !(va >= stack_guard && va < stack_base) && !in_stack && !in_text && !in_data;
    800018fc:	0144fe63          	bgeu	s1,s4,80001918 <vmfault+0xb8>
  int in_stack = under_brk && (va >= stack_base && va < stack_end);
    80001900:	892a                	mv	s2,a0
    80001902:	a019                	j	80001908 <vmfault+0xa8>
    80001904:	0124b933          	sltu	s2,s1,s2
  int in_heap = under_brk && !(va >= stack_guard && va < stack_base) && !in_stack && !in_text && !in_data;
    80001908:	015767b3          	or	a5,a4,s5
    8000190c:	00f967b3          	or	a5,s2,a5
    80001910:	0017c793          	xori	a5,a5,1
    80001914:	0007851b          	sext.w	a0,a5
  if(in_text || in_data){
    80001918:	01576733          	or	a4,a4,s5
    8000191c:	2701                	sext.w	a4,a4
    8000191e:	0e070e63          	beqz	a4,80001a1a <vmfault+0x1ba>
    char *buf = try_kalloc_or_replace(va);
    80001922:	8526                	mv	a0,s1
    80001924:	d1fff0ef          	jal	80001642 <try_kalloc_or_replace>
    80001928:	892a                	mv	s2,a0
      return 0;
    8000192a:	4b01                	li	s6,0
    if(buf == 0)
    8000192c:	14050663          	beqz	a0,80001a78 <vmfault+0x218>
    memset(buf, 0, PGSIZE);
    80001930:	6605                	lui	a2,0x1
    80001932:	4581                	li	a1,0
    80001934:	b6eff0ef          	jal	80000ca2 <memset>
    if(p->exec_ip){
    80001938:	6791                	lui	a5,0x4
    8000193a:	97ce                	add	a5,a5,s3
    8000193c:	bb87b503          	ld	a0,-1096(a5) # 3bb8 <_entry-0x7fffc448>
    80001940:	c13d                	beqz	a0,800019a6 <vmfault+0x146>
      if(in_text){
    80001942:	080a8163          	beqz	s5,800019c4 <vmfault+0x164>
        off = p->text_off + (va - p->text_start);
    80001946:	6791                	lui	a5,0x4
    80001948:	97ce                	add	a5,a5,s3
    8000194a:	bc07ab03          	lw	s6,-1088(a5) # 3bc0 <_entry-0x7fffc440>
    8000194e:	b887b703          	ld	a4,-1144(a5)
        filesz = (p->text_filesz > (va - p->text_start)) ? (p->text_filesz - (va - p->text_start)) : 0;
    80001952:	bc47aa03          	lw	s4,-1084(a5)
    80001956:	020a1693          	slli	a3,s4,0x20
    8000195a:	9281                	srli	a3,a3,0x20
    8000195c:	40e487b3          	sub	a5,s1,a4
    80001960:	0ad7f263          	bgeu	a5,a3,80001a04 <vmfault+0x1a4>
        off = p->text_off + (va - p->text_start);
    80001964:	009b0b3b          	addw	s6,s6,s1
    80001968:	40eb0b3b          	subw	s6,s6,a4
        filesz = (p->text_filesz > (va - p->text_start)) ? (p->text_filesz - (va - p->text_start)) : 0;
    8000196c:	409a0a3b          	subw	s4,s4,s1
    80001970:	00ea0a3b          	addw	s4,s4,a4
      if(filesz > PGSIZE) filesz = PGSIZE;
    80001974:	6785                	lui	a5,0x1
    80001976:	0747ef63          	bltu	a5,s4,800019f4 <vmfault+0x194>
      if(filesz > 0){
    8000197a:	020a0663          	beqz	s4,800019a6 <vmfault+0x146>
        ilock(p->exec_ip);
    8000197e:	0a5020ef          	jal	80004222 <ilock>
        int n = readi(p->exec_ip, 0, (uint64)buf, off, filesz);
    80001982:	6b91                	lui	s7,0x4
    80001984:	9bce                	add	s7,s7,s3
    80001986:	8752                	mv	a4,s4
    80001988:	86da                	mv	a3,s6
    8000198a:	864a                	mv	a2,s2
    8000198c:	4581                	li	a1,0
    8000198e:	bb8bb503          	ld	a0,-1096(s7) # 3bb8 <_entry-0x7fffc448>
    80001992:	421020ef          	jal	800045b2 <readi>
    80001996:	8b2a                	mv	s6,a0
        iunlock(p->exec_ip);
    80001998:	bb8bb503          	ld	a0,-1096(s7)
    8000199c:	135020ef          	jal	800042d0 <iunlock>
        if(n != filesz){
    800019a0:	2b01                	sext.w	s6,s6
    800019a2:	054b1b63          	bne	s6,s4,800019f8 <vmfault+0x198>
    int perm = PTE_U | PTE_R | (in_text ? PTE_X : PTE_W);
    800019a6:	4759                	li	a4,22
    800019a8:	000a8363          	beqz	s5,800019ae <vmfault+0x14e>
    800019ac:	4769                	li	a4,26
    if (mappages(p->pagetable, va, PGSIZE, (uint64)buf, perm) != 0) {
    800019ae:	8b4a                	mv	s6,s2
    800019b0:	86ca                	mv	a3,s2
    800019b2:	6605                	lui	a2,0x1
    800019b4:	85a6                	mv	a1,s1
    800019b6:	0509b503          	ld	a0,80(s3)
    800019ba:	f04ff0ef          	jal	800010be <mappages>
    800019be:	e539                	bnez	a0,80001a0c <vmfault+0x1ac>
    800019c0:	6c02                	ld	s8,0(sp)
    800019c2:	a879                	j	80001a60 <vmfault+0x200>
        off = p->data_off + (va - p->data_start);
    800019c4:	6791                	lui	a5,0x4
    800019c6:	97ce                	add	a5,a5,s3
    800019c8:	bd07ab03          	lw	s6,-1072(a5) # 3bd0 <_entry-0x7fffc430>
    800019cc:	b987b703          	ld	a4,-1128(a5)
        filesz = (p->data_filesz > (va - p->data_start)) ? (p->data_filesz - (va - p->data_start)) : 0;
    800019d0:	bd47aa03          	lw	s4,-1068(a5)
    800019d4:	020a1693          	slli	a3,s4,0x20
    800019d8:	9281                	srli	a3,a3,0x20
    800019da:	40e487b3          	sub	a5,s1,a4
    800019de:	02d7f563          	bgeu	a5,a3,80001a08 <vmfault+0x1a8>
        off = p->data_off + (va - p->data_start);
    800019e2:	009b0b3b          	addw	s6,s6,s1
    800019e6:	40eb0b3b          	subw	s6,s6,a4
        filesz = (p->data_filesz > (va - p->data_start)) ? (p->data_filesz - (va - p->data_start)) : 0;
    800019ea:	409a0a3b          	subw	s4,s4,s1
    800019ee:	00ea0a3b          	addw	s4,s4,a4
    800019f2:	b749                	j	80001974 <vmfault+0x114>
      if(filesz > PGSIZE) filesz = PGSIZE;
    800019f4:	6a05                	lui	s4,0x1
    800019f6:	b761                	j	8000197e <vmfault+0x11e>
          kfree(buf);
    800019f8:	854a                	mv	a0,s2
    800019fa:	822ff0ef          	jal	80000a1c <kfree>
          return 0;
    800019fe:	4b01                	li	s6,0
    80001a00:	6c02                	ld	s8,0(sp)
    80001a02:	a8b9                	j	80001a60 <vmfault+0x200>
    int perm = PTE_U | PTE_R | (in_text ? PTE_X : PTE_W);
    80001a04:	4769                	li	a4,26
    80001a06:	b765                	j	800019ae <vmfault+0x14e>
    80001a08:	4759                	li	a4,22
    80001a0a:	b755                	j	800019ae <vmfault+0x14e>
      kfree(buf);
    80001a0c:	854a                	mv	a0,s2
    80001a0e:	80eff0ef          	jal	80000a1c <kfree>
      return 0;
    80001a12:	4b01                	li	s6,0
    80001a14:	6c02                	ld	s8,0(sp)
    80001a16:	a0a9                	j	80001a60 <vmfault+0x200>
  int in_stack = under_brk && (va >= stack_base && va < stack_end);
    80001a18:	892a                	mv	s2,a0
  } else if(in_stack || in_heap) {
    80001a1a:	012567b3          	or	a5,a0,s2
    80001a1e:	2781                	sext.w	a5,a5
    return 0; // outside any valid region
    80001a20:	4b01                	li	s6,0
  } else if(in_stack || in_heap) {
    80001a22:	e399                	bnez	a5,80001a28 <vmfault+0x1c8>
    80001a24:	6c02                	ld	s8,0(sp)
    80001a26:	a82d                	j	80001a60 <vmfault+0x200>
    mem = (uint64) try_kalloc_or_replace(va);
    80001a28:	8526                	mv	a0,s1
    80001a2a:	c19ff0ef          	jal	80001642 <try_kalloc_or_replace>
    80001a2e:	892a                	mv	s2,a0
    if(mem == 0)
    80001a30:	c531                	beqz	a0,80001a7c <vmfault+0x21c>
    mem = (uint64) try_kalloc_or_replace(va);
    80001a32:	8b2a                	mv	s6,a0
    memset((void *) mem, 0, PGSIZE);
    80001a34:	6605                	lui	a2,0x1
    80001a36:	4581                	li	a1,0
    80001a38:	a6aff0ef          	jal	80000ca2 <memset>
    if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001a3c:	4759                	li	a4,22
    80001a3e:	86ca                	mv	a3,s2
    80001a40:	6605                	lui	a2,0x1
    80001a42:	85a6                	mv	a1,s1
    80001a44:	0509b503          	ld	a0,80(s3)
    80001a48:	e76ff0ef          	jal	800010be <mappages>
    80001a4c:	e119                	bnez	a0,80001a52 <vmfault+0x1f2>
    80001a4e:	6c02                	ld	s8,0(sp)
    80001a50:	a801                	j	80001a60 <vmfault+0x200>
      kfree((void *)mem);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fc9fe0ef          	jal	80000a1c <kfree>
      return 0;
    80001a58:	4b01                	li	s6,0
    80001a5a:	6c02                	ld	s8,0(sp)
    80001a5c:	a011                	j	80001a60 <vmfault+0x200>
    80001a5e:	6c02                	ld	s8,0(sp)
}
    80001a60:	855a                	mv	a0,s6
    80001a62:	60a6                	ld	ra,72(sp)
    80001a64:	6406                	ld	s0,64(sp)
    80001a66:	74e2                	ld	s1,56(sp)
    80001a68:	7942                	ld	s2,48(sp)
    80001a6a:	79a2                	ld	s3,40(sp)
    80001a6c:	7a02                	ld	s4,32(sp)
    80001a6e:	6ae2                	ld	s5,24(sp)
    80001a70:	6b42                	ld	s6,16(sp)
    80001a72:	6ba2                	ld	s7,8(sp)
    80001a74:	6161                	addi	sp,sp,80
    80001a76:	8082                	ret
    80001a78:	6c02                	ld	s8,0(sp)
    80001a7a:	b7dd                	j	80001a60 <vmfault+0x200>
    80001a7c:	6c02                	ld	s8,0(sp)
    80001a7e:	b7cd                	j	80001a60 <vmfault+0x200>

0000000080001a80 <copyout>:
  while(len > 0){
    80001a80:	c2cd                	beqz	a3,80001b22 <copyout+0xa2>
{
    80001a82:	711d                	addi	sp,sp,-96
    80001a84:	ec86                	sd	ra,88(sp)
    80001a86:	e8a2                	sd	s0,80(sp)
    80001a88:	e4a6                	sd	s1,72(sp)
    80001a8a:	f852                	sd	s4,48(sp)
    80001a8c:	f05a                	sd	s6,32(sp)
    80001a8e:	ec5e                	sd	s7,24(sp)
    80001a90:	e862                	sd	s8,16(sp)
    80001a92:	1080                	addi	s0,sp,96
    80001a94:	8c2a                	mv	s8,a0
    80001a96:	8b2e                	mv	s6,a1
    80001a98:	8bb2                	mv	s7,a2
    80001a9a:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80001a9c:	74fd                	lui	s1,0xfffff
    80001a9e:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001aa0:	57fd                	li	a5,-1
    80001aa2:	83e9                	srli	a5,a5,0x1a
    80001aa4:	0897e163          	bltu	a5,s1,80001b26 <copyout+0xa6>
    80001aa8:	e0ca                	sd	s2,64(sp)
    80001aaa:	fc4e                	sd	s3,56(sp)
    80001aac:	f456                	sd	s5,40(sp)
    80001aae:	e466                	sd	s9,8(sp)
    80001ab0:	e06a                	sd	s10,0(sp)
    80001ab2:	6d05                	lui	s10,0x1
    80001ab4:	8cbe                	mv	s9,a5
    80001ab6:	a015                	j	80001ada <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001ab8:	409b0533          	sub	a0,s6,s1
    80001abc:	0009861b          	sext.w	a2,s3
    80001ac0:	85de                	mv	a1,s7
    80001ac2:	954a                	add	a0,a0,s2
    80001ac4:	a3aff0ef          	jal	80000cfe <memmove>
    len -= n;
    80001ac8:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001acc:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001ace:	040a0363          	beqz	s4,80001b14 <copyout+0x94>
    if(va0 >= MAXVA)
    80001ad2:	055cec63          	bltu	s9,s5,80001b2a <copyout+0xaa>
    80001ad6:	84d6                	mv	s1,s5
    80001ad8:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001ada:	85a6                	mv	a1,s1
    80001adc:	8562                	mv	a0,s8
    80001ade:	da2ff0ef          	jal	80001080 <walkaddr>
    80001ae2:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001ae4:	e901                	bnez	a0,80001af4 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001ae6:	4601                	li	a2,0
    80001ae8:	85a6                	mv	a1,s1
    80001aea:	8562                	mv	a0,s8
    80001aec:	d75ff0ef          	jal	80001860 <vmfault>
    80001af0:	892a                	mv	s2,a0
    80001af2:	c139                	beqz	a0,80001b38 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001af4:	4601                	li	a2,0
    80001af6:	85a6                	mv	a1,s1
    80001af8:	8562                	mv	a0,s8
    80001afa:	cecff0ef          	jal	80000fe6 <walk>
    if((*pte & PTE_W) == 0)
    80001afe:	611c                	ld	a5,0(a0)
    80001b00:	8b91                	andi	a5,a5,4
    80001b02:	c3b1                	beqz	a5,80001b46 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001b04:	01a48ab3          	add	s5,s1,s10
    80001b08:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    80001b0c:	fb3a76e3          	bgeu	s4,s3,80001ab8 <copyout+0x38>
    80001b10:	89d2                	mv	s3,s4
    80001b12:	b75d                	j	80001ab8 <copyout+0x38>
  return 0;
    80001b14:	4501                	li	a0,0
    80001b16:	6906                	ld	s2,64(sp)
    80001b18:	79e2                	ld	s3,56(sp)
    80001b1a:	7aa2                	ld	s5,40(sp)
    80001b1c:	6ca2                	ld	s9,8(sp)
    80001b1e:	6d02                	ld	s10,0(sp)
    80001b20:	a80d                	j	80001b52 <copyout+0xd2>
    80001b22:	4501                	li	a0,0
}
    80001b24:	8082                	ret
      return -1;
    80001b26:	557d                	li	a0,-1
    80001b28:	a02d                	j	80001b52 <copyout+0xd2>
    80001b2a:	557d                	li	a0,-1
    80001b2c:	6906                	ld	s2,64(sp)
    80001b2e:	79e2                	ld	s3,56(sp)
    80001b30:	7aa2                	ld	s5,40(sp)
    80001b32:	6ca2                	ld	s9,8(sp)
    80001b34:	6d02                	ld	s10,0(sp)
    80001b36:	a831                	j	80001b52 <copyout+0xd2>
        return -1;
    80001b38:	557d                	li	a0,-1
    80001b3a:	6906                	ld	s2,64(sp)
    80001b3c:	79e2                	ld	s3,56(sp)
    80001b3e:	7aa2                	ld	s5,40(sp)
    80001b40:	6ca2                	ld	s9,8(sp)
    80001b42:	6d02                	ld	s10,0(sp)
    80001b44:	a039                	j	80001b52 <copyout+0xd2>
      return -1;
    80001b46:	557d                	li	a0,-1
    80001b48:	6906                	ld	s2,64(sp)
    80001b4a:	79e2                	ld	s3,56(sp)
    80001b4c:	7aa2                	ld	s5,40(sp)
    80001b4e:	6ca2                	ld	s9,8(sp)
    80001b50:	6d02                	ld	s10,0(sp)
}
    80001b52:	60e6                	ld	ra,88(sp)
    80001b54:	6446                	ld	s0,80(sp)
    80001b56:	64a6                	ld	s1,72(sp)
    80001b58:	7a42                	ld	s4,48(sp)
    80001b5a:	7b02                	ld	s6,32(sp)
    80001b5c:	6be2                	ld	s7,24(sp)
    80001b5e:	6c42                	ld	s8,16(sp)
    80001b60:	6125                	addi	sp,sp,96
    80001b62:	8082                	ret

0000000080001b64 <copyin>:
  while(len > 0){
    80001b64:	c2d5                	beqz	a3,80001c08 <copyin+0xa4>
{
    80001b66:	711d                	addi	sp,sp,-96
    80001b68:	ec86                	sd	ra,88(sp)
    80001b6a:	e8a2                	sd	s0,80(sp)
    80001b6c:	e4a6                	sd	s1,72(sp)
    80001b6e:	fc4e                	sd	s3,56(sp)
    80001b70:	f852                	sd	s4,48(sp)
    80001b72:	f456                	sd	s5,40(sp)
    80001b74:	f05a                	sd	s6,32(sp)
    80001b76:	1080                	addi	s0,sp,96
    80001b78:	8b2a                	mv	s6,a0
    80001b7a:	8aae                	mv	s5,a1
    80001b7c:	8a32                	mv	s4,a2
    80001b7e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001b80:	74fd                	lui	s1,0xfffff
    80001b82:	8cf1                	and	s1,s1,a2
    if(va0 >= MAXVA)
    80001b84:	57fd                	li	a5,-1
    80001b86:	83e9                	srli	a5,a5,0x1a
    80001b88:	0897e263          	bltu	a5,s1,80001c0c <copyin+0xa8>
    80001b8c:	e0ca                	sd	s2,64(sp)
    80001b8e:	ec5e                	sd	s7,24(sp)
    80001b90:	e862                	sd	s8,16(sp)
    80001b92:	e466                	sd	s9,8(sp)
    80001b94:	6c05                	lui	s8,0x1
    80001b96:	8bbe                	mv	s7,a5
    80001b98:	a80d                	j	80001bca <copyin+0x66>
    n = PGSIZE - (srcva - va0);
    80001b9a:	01848cb3          	add	s9,s1,s8
    80001b9e:	414c8933          	sub	s2,s9,s4
    if(n > len)
    80001ba2:	0129f363          	bgeu	s3,s2,80001ba8 <copyin+0x44>
    80001ba6:	894e                	mv	s2,s3
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001ba8:	409a05b3          	sub	a1,s4,s1
    80001bac:	0009061b          	sext.w	a2,s2
    80001bb0:	95aa                	add	a1,a1,a0
    80001bb2:	8556                	mv	a0,s5
    80001bb4:	94aff0ef          	jal	80000cfe <memmove>
    len -= n;
    80001bb8:	412989b3          	sub	s3,s3,s2
    dst += n;
    80001bbc:	9aca                	add	s5,s5,s2
  while(len > 0){
    80001bbe:	02098763          	beqz	s3,80001bec <copyin+0x88>
    if(va0 >= MAXVA)
    80001bc2:	059be763          	bltu	s7,s9,80001c10 <copyin+0xac>
    80001bc6:	84e6                	mv	s1,s9
    80001bc8:	8a66                	mv	s4,s9
    pa0 = walkaddr(pagetable, va0);
    80001bca:	85a6                	mv	a1,s1
    80001bcc:	855a                	mv	a0,s6
    80001bce:	cb2ff0ef          	jal	80001080 <walkaddr>
    if(pa0 == 0) {
    80001bd2:	f561                	bnez	a0,80001b9a <copyin+0x36>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001bd4:	4601                	li	a2,0
    80001bd6:	85a6                	mv	a1,s1
    80001bd8:	855a                	mv	a0,s6
    80001bda:	c87ff0ef          	jal	80001860 <vmfault>
    80001bde:	fd55                	bnez	a0,80001b9a <copyin+0x36>
        return -1;
    80001be0:	557d                	li	a0,-1
    80001be2:	6906                	ld	s2,64(sp)
    80001be4:	6be2                	ld	s7,24(sp)
    80001be6:	6c42                	ld	s8,16(sp)
    80001be8:	6ca2                	ld	s9,8(sp)
    80001bea:	a031                	j	80001bf6 <copyin+0x92>
  return 0;
    80001bec:	4501                	li	a0,0
    80001bee:	6906                	ld	s2,64(sp)
    80001bf0:	6be2                	ld	s7,24(sp)
    80001bf2:	6c42                	ld	s8,16(sp)
    80001bf4:	6ca2                	ld	s9,8(sp)
}
    80001bf6:	60e6                	ld	ra,88(sp)
    80001bf8:	6446                	ld	s0,80(sp)
    80001bfa:	64a6                	ld	s1,72(sp)
    80001bfc:	79e2                	ld	s3,56(sp)
    80001bfe:	7a42                	ld	s4,48(sp)
    80001c00:	7aa2                	ld	s5,40(sp)
    80001c02:	7b02                	ld	s6,32(sp)
    80001c04:	6125                	addi	sp,sp,96
    80001c06:	8082                	ret
  return 0;
    80001c08:	4501                	li	a0,0
}
    80001c0a:	8082                	ret
      return -1;
    80001c0c:	557d                	li	a0,-1
    80001c0e:	b7e5                	j	80001bf6 <copyin+0x92>
    80001c10:	557d                	li	a0,-1
    80001c12:	6906                	ld	s2,64(sp)
    80001c14:	6be2                	ld	s7,24(sp)
    80001c16:	6c42                	ld	s8,16(sp)
    80001c18:	6ca2                	ld	s9,8(sp)
    80001c1a:	bff1                	j	80001bf6 <copyin+0x92>

0000000080001c1c <copyinstr>:
  while(got_null == 0 && max > 0){
    80001c1c:	caed                	beqz	a3,80001d0e <copyinstr+0xf2>
{
    80001c1e:	711d                	addi	sp,sp,-96
    80001c20:	ec86                	sd	ra,88(sp)
    80001c22:	e8a2                	sd	s0,80(sp)
    80001c24:	e0ca                	sd	s2,64(sp)
    80001c26:	fc4e                	sd	s3,56(sp)
    80001c28:	f852                	sd	s4,48(sp)
    80001c2a:	e862                	sd	s8,16(sp)
    80001c2c:	e466                	sd	s9,8(sp)
    80001c2e:	1080                	addi	s0,sp,96
    80001c30:	8a2a                	mv	s4,a0
    80001c32:	8c2e                	mv	s8,a1
    80001c34:	8cb2                	mv	s9,a2
    80001c36:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001c38:	797d                	lui	s2,0xfffff
    80001c3a:	01267933          	and	s2,a2,s2
    if(va0 >= MAXVA)
    80001c3e:	57fd                	li	a5,-1
    80001c40:	83e9                	srli	a5,a5,0x1a
    80001c42:	0b27ee63          	bltu	a5,s2,80001cfe <copyinstr+0xe2>
    80001c46:	e4a6                	sd	s1,72(sp)
    80001c48:	f456                	sd	s5,40(sp)
    80001c4a:	f05a                	sd	s6,32(sp)
    80001c4c:	ec5e                	sd	s7,24(sp)
    80001c4e:	6785                	lui	a5,0x1
    80001c50:	993e                	add	s2,s2,a5
    80001c52:	7b7d                	lui	s6,0xfffff
    80001c54:	6b85                	lui	s7,0x1
    80001c56:	5afd                	li	s5,-1
    80001c58:	01aada93          	srli	s5,s5,0x1a
    80001c5c:	a8b1                	j	80001cb8 <copyinstr+0x9c>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0)
    80001c5e:	4601                	li	a2,0
    80001c60:	85a6                	mv	a1,s1
    80001c62:	8552                	mv	a0,s4
    80001c64:	bfdff0ef          	jal	80001860 <vmfault>
    80001c68:	ed39                	bnez	a0,80001cc6 <copyinstr+0xaa>
        return -1;
    80001c6a:	557d                	li	a0,-1
    80001c6c:	64a6                	ld	s1,72(sp)
    80001c6e:	7aa2                	ld	s5,40(sp)
    80001c70:	7b02                	ld	s6,32(sp)
    80001c72:	6be2                	ld	s7,24(sp)
    80001c74:	a819                	j	80001c8a <copyinstr+0x6e>
        *dst = '\0';
    80001c76:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001c7a:	4785                	li	a5,1
  if(got_null){
    80001c7c:	37fd                	addiw	a5,a5,-1
    80001c7e:	0007851b          	sext.w	a0,a5
    80001c82:	64a6                	ld	s1,72(sp)
    80001c84:	7aa2                	ld	s5,40(sp)
    80001c86:	7b02                	ld	s6,32(sp)
    80001c88:	6be2                	ld	s7,24(sp)
}
    80001c8a:	60e6                	ld	ra,88(sp)
    80001c8c:	6446                	ld	s0,80(sp)
    80001c8e:	6906                	ld	s2,64(sp)
    80001c90:	79e2                	ld	s3,56(sp)
    80001c92:	7a42                	ld	s4,48(sp)
    80001c94:	6c42                	ld	s8,16(sp)
    80001c96:	6ca2                	ld	s9,8(sp)
    80001c98:	6125                	addi	sp,sp,96
    80001c9a:	8082                	ret
    80001c9c:	fff98713          	addi	a4,s3,-1
    80001ca0:	972a                	add	a4,a4,a0
      --max;
    80001ca2:	40b709b3          	sub	s3,a4,a1
  while(got_null == 0 && max > 0){
    80001ca6:	04e58a63          	beq	a1,a4,80001cfa <copyinstr+0xde>
    80001caa:	8c3e                	mv	s8,a5
    if(va0 >= MAXVA)
    80001cac:	017907b3          	add	a5,s2,s7
    80001cb0:	8cca                	mv	s9,s2
    80001cb2:	052ae863          	bltu	s5,s2,80001d02 <copyinstr+0xe6>
    80001cb6:	893e                	mv	s2,a5
    80001cb8:	016904b3          	add	s1,s2,s6
    pa0 = walkaddr(pagetable, va0);
    80001cbc:	85a6                	mv	a1,s1
    80001cbe:	8552                	mv	a0,s4
    80001cc0:	bc0ff0ef          	jal	80001080 <walkaddr>
    if(pa0 == 0){
    80001cc4:	dd49                	beqz	a0,80001c5e <copyinstr+0x42>
    n = PGSIZE - (srcva - va0);
    80001cc6:	419906b3          	sub	a3,s2,s9
    if(n > max)
    80001cca:	00d9f363          	bgeu	s3,a3,80001cd0 <copyinstr+0xb4>
    80001cce:	86ce                	mv	a3,s3
    char *p = (char *) (pa0 + (srcva - va0));
    80001cd0:	409c84b3          	sub	s1,s9,s1
    80001cd4:	94aa                	add	s1,s1,a0
    while(n > 0){
    80001cd6:	daf9                	beqz	a3,80001cac <copyinstr+0x90>
    80001cd8:	87e2                	mv	a5,s8
    80001cda:	8562                	mv	a0,s8
      if(*p == '\0'){
    80001cdc:	41848633          	sub	a2,s1,s8
    while(n > 0){
    80001ce0:	96e2                	add	a3,a3,s8
    80001ce2:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001ce4:	00f60733          	add	a4,a2,a5
    80001ce8:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7feeee28>
    80001cec:	d749                	beqz	a4,80001c76 <copyinstr+0x5a>
        *dst = *p;
    80001cee:	00e78023          	sb	a4,0(a5)
      dst++;
    80001cf2:	0785                	addi	a5,a5,1
    while(n > 0){
    80001cf4:	fed797e3          	bne	a5,a3,80001ce2 <copyinstr+0xc6>
    80001cf8:	b755                	j	80001c9c <copyinstr+0x80>
    80001cfa:	4781                	li	a5,0
    80001cfc:	b741                	j	80001c7c <copyinstr+0x60>
      return -1;
    80001cfe:	557d                	li	a0,-1
    80001d00:	b769                	j	80001c8a <copyinstr+0x6e>
    80001d02:	557d                	li	a0,-1
    80001d04:	64a6                	ld	s1,72(sp)
    80001d06:	7aa2                	ld	s5,40(sp)
    80001d08:	7b02                	ld	s6,32(sp)
    80001d0a:	6be2                	ld	s7,24(sp)
    80001d0c:	bfbd                	j	80001c8a <copyinstr+0x6e>
  int got_null = 0;
    80001d0e:	4781                	li	a5,0
  if(got_null){
    80001d10:	37fd                	addiw	a5,a5,-1
    80001d12:	0007851b          	sext.w	a0,a5
}
    80001d16:	8082                	ret

0000000080001d18 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001d18:	715d                	addi	sp,sp,-80
    80001d1a:	e486                	sd	ra,72(sp)
    80001d1c:	e0a2                	sd	s0,64(sp)
    80001d1e:	fc26                	sd	s1,56(sp)
    80001d20:	f84a                	sd	s2,48(sp)
    80001d22:	f44e                	sd	s3,40(sp)
    80001d24:	f052                	sd	s4,32(sp)
    80001d26:	ec56                	sd	s5,24(sp)
    80001d28:	e85a                	sd	s6,16(sp)
    80001d2a:	e45e                	sd	s7,8(sp)
    80001d2c:	0880                	addi	s0,sp,80
    80001d2e:	8aaa                	mv	s5,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d30:	00013497          	auipc	s1,0x13
    80001d34:	2c848493          	addi	s1,s1,712 # 80014ff8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001d38:	8ba6                	mv	s7,s1
    80001d3a:	00109937          	lui	s2,0x109
    80001d3e:	abd90913          	addi	s2,s2,-1347 # 108abd <_entry-0x7fef7543>
    80001d42:	0936                	slli	s2,s2,0xd
    80001d44:	54990913          	addi	s2,s2,1353
    80001d48:	0936                	slli	s2,s2,0xd
    80001d4a:	79f90913          	addi	s2,s2,1951
    80001d4e:	093a                	slli	s2,s2,0xe
    80001d50:	87f90913          	addi	s2,s2,-1921
    80001d54:	040009b7          	lui	s3,0x4000
    80001d58:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001d5a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	6a11                	lui	s4,0x4
    80001d5e:	bf8a0a13          	addi	s4,s4,-1032 # 3bf8 <_entry-0x7fffc408>
    80001d62:	00103b17          	auipc	s6,0x103
    80001d66:	096b0b13          	addi	s6,s6,150 # 80104df8 <tickslock>
    char *pa = kalloc();
    80001d6a:	d95fe0ef          	jal	80000afe <kalloc>
    80001d6e:	862a                	mv	a2,a0
    if(pa == 0)
    80001d70:	cd15                	beqz	a0,80001dac <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    80001d72:	417485b3          	sub	a1,s1,s7
    80001d76:	858d                	srai	a1,a1,0x3
    80001d78:	032585b3          	mul	a1,a1,s2
    80001d7c:	2585                	addiw	a1,a1,1
    80001d7e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001d82:	4719                	li	a4,6
    80001d84:	6685                	lui	a3,0x1
    80001d86:	40b985b3          	sub	a1,s3,a1
    80001d8a:	8556                	mv	a0,s5
    80001d8c:	be2ff0ef          	jal	8000116e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d90:	94d2                	add	s1,s1,s4
    80001d92:	fd649ce3          	bne	s1,s6,80001d6a <proc_mapstacks+0x52>
  }
}
    80001d96:	60a6                	ld	ra,72(sp)
    80001d98:	6406                	ld	s0,64(sp)
    80001d9a:	74e2                	ld	s1,56(sp)
    80001d9c:	7942                	ld	s2,48(sp)
    80001d9e:	79a2                	ld	s3,40(sp)
    80001da0:	7a02                	ld	s4,32(sp)
    80001da2:	6ae2                	ld	s5,24(sp)
    80001da4:	6b42                	ld	s6,16(sp)
    80001da6:	6ba2                	ld	s7,8(sp)
    80001da8:	6161                	addi	sp,sp,80
    80001daa:	8082                	ret
      panic("kalloc");
    80001dac:	00007517          	auipc	a0,0x7
    80001db0:	48450513          	addi	a0,a0,1156 # 80009230 <etext+0x230>
    80001db4:	a2dfe0ef          	jal	800007e0 <panic>

0000000080001db8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001db8:	715d                	addi	sp,sp,-80
    80001dba:	e486                	sd	ra,72(sp)
    80001dbc:	e0a2                	sd	s0,64(sp)
    80001dbe:	fc26                	sd	s1,56(sp)
    80001dc0:	f84a                	sd	s2,48(sp)
    80001dc2:	f44e                	sd	s3,40(sp)
    80001dc4:	f052                	sd	s4,32(sp)
    80001dc6:	ec56                	sd	s5,24(sp)
    80001dc8:	e85a                	sd	s6,16(sp)
    80001dca:	e45e                	sd	s7,8(sp)
    80001dcc:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001dce:	00007597          	auipc	a1,0x7
    80001dd2:	46a58593          	addi	a1,a1,1130 # 80009238 <etext+0x238>
    80001dd6:	00013517          	auipc	a0,0x13
    80001dda:	df250513          	addi	a0,a0,-526 # 80014bc8 <pid_lock>
    80001dde:	d71fe0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001de2:	00007597          	auipc	a1,0x7
    80001de6:	45e58593          	addi	a1,a1,1118 # 80009240 <etext+0x240>
    80001dea:	00013517          	auipc	a0,0x13
    80001dee:	df650513          	addi	a0,a0,-522 # 80014be0 <wait_lock>
    80001df2:	d5dfe0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001df6:	00013497          	auipc	s1,0x13
    80001dfa:	20248493          	addi	s1,s1,514 # 80014ff8 <proc>
      initlock(&p->lock, "proc");
    80001dfe:	00007b97          	auipc	s7,0x7
    80001e02:	452b8b93          	addi	s7,s7,1106 # 80009250 <etext+0x250>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001e06:	8b26                	mv	s6,s1
    80001e08:	00109937          	lui	s2,0x109
    80001e0c:	abd90913          	addi	s2,s2,-1347 # 108abd <_entry-0x7fef7543>
    80001e10:	0936                	slli	s2,s2,0xd
    80001e12:	54990913          	addi	s2,s2,1353
    80001e16:	0936                	slli	s2,s2,0xd
    80001e18:	79f90913          	addi	s2,s2,1951
    80001e1c:	093a                	slli	s2,s2,0xe
    80001e1e:	87f90913          	addi	s2,s2,-1921
    80001e22:	040009b7          	lui	s3,0x4000
    80001e26:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001e28:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e2a:	6a11                	lui	s4,0x4
    80001e2c:	bf8a0a13          	addi	s4,s4,-1032 # 3bf8 <_entry-0x7fffc408>
    80001e30:	00103a97          	auipc	s5,0x103
    80001e34:	fc8a8a93          	addi	s5,s5,-56 # 80104df8 <tickslock>
      initlock(&p->lock, "proc");
    80001e38:	85de                	mv	a1,s7
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	d13fe0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    80001e40:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001e44:	416487b3          	sub	a5,s1,s6
    80001e48:	878d                	srai	a5,a5,0x3
    80001e4a:	032787b3          	mul	a5,a5,s2
    80001e4e:	2785                	addiw	a5,a5,1
    80001e50:	00d7979b          	slliw	a5,a5,0xd
    80001e54:	40f987b3          	sub	a5,s3,a5
    80001e58:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e5a:	94d2                	add	s1,s1,s4
    80001e5c:	fd549ee3          	bne	s1,s5,80001e38 <procinit+0x80>
  }
}
    80001e60:	60a6                	ld	ra,72(sp)
    80001e62:	6406                	ld	s0,64(sp)
    80001e64:	74e2                	ld	s1,56(sp)
    80001e66:	7942                	ld	s2,48(sp)
    80001e68:	79a2                	ld	s3,40(sp)
    80001e6a:	7a02                	ld	s4,32(sp)
    80001e6c:	6ae2                	ld	s5,24(sp)
    80001e6e:	6b42                	ld	s6,16(sp)
    80001e70:	6ba2                	ld	s7,8(sp)
    80001e72:	6161                	addi	sp,sp,80
    80001e74:	8082                	ret

0000000080001e76 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001e76:	1141                	addi	sp,sp,-16
    80001e78:	e422                	sd	s0,8(sp)
    80001e7a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e7c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001e7e:	2501                	sext.w	a0,a0
    80001e80:	6422                	ld	s0,8(sp)
    80001e82:	0141                	addi	sp,sp,16
    80001e84:	8082                	ret

0000000080001e86 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001e86:	1141                	addi	sp,sp,-16
    80001e88:	e422                	sd	s0,8(sp)
    80001e8a:	0800                	addi	s0,sp,16
    80001e8c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001e8e:	2781                	sext.w	a5,a5
    80001e90:	079e                	slli	a5,a5,0x7
  return c;
}
    80001e92:	00013517          	auipc	a0,0x13
    80001e96:	d6650513          	addi	a0,a0,-666 # 80014bf8 <cpus>
    80001e9a:	953e                	add	a0,a0,a5
    80001e9c:	6422                	ld	s0,8(sp)
    80001e9e:	0141                	addi	sp,sp,16
    80001ea0:	8082                	ret

0000000080001ea2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001ea2:	1101                	addi	sp,sp,-32
    80001ea4:	ec06                	sd	ra,24(sp)
    80001ea6:	e822                	sd	s0,16(sp)
    80001ea8:	e426                	sd	s1,8(sp)
    80001eaa:	1000                	addi	s0,sp,32
  push_off();
    80001eac:	ce3fe0ef          	jal	80000b8e <push_off>
    80001eb0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001eb2:	2781                	sext.w	a5,a5
    80001eb4:	079e                	slli	a5,a5,0x7
    80001eb6:	00013717          	auipc	a4,0x13
    80001eba:	d1270713          	addi	a4,a4,-750 # 80014bc8 <pid_lock>
    80001ebe:	97ba                	add	a5,a5,a4
    80001ec0:	7b84                	ld	s1,48(a5)
  pop_off();
    80001ec2:	d51fe0ef          	jal	80000c12 <pop_off>
  return p;
}
    80001ec6:	8526                	mv	a0,s1
    80001ec8:	60e2                	ld	ra,24(sp)
    80001eca:	6442                	ld	s0,16(sp)
    80001ecc:	64a2                	ld	s1,8(sp)
    80001ece:	6105                	addi	sp,sp,32
    80001ed0:	8082                	ret

0000000080001ed2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001ed2:	7179                	addi	sp,sp,-48
    80001ed4:	f406                	sd	ra,40(sp)
    80001ed6:	f022                	sd	s0,32(sp)
    80001ed8:	ec26                	sd	s1,24(sp)
    80001eda:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001edc:	fc7ff0ef          	jal	80001ea2 <myproc>
    80001ee0:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001ee2:	d85fe0ef          	jal	80000c66 <release>

  if (first) {
    80001ee6:	0000b797          	auipc	a5,0xb
    80001eea:	b8a7a783          	lw	a5,-1142(a5) # 8000ca70 <first.1>
    80001eee:	cf8d                	beqz	a5,80001f28 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001ef0:	4505                	li	a0,1
    80001ef2:	624020ef          	jal	80004516 <fsinit>

    first = 0;
    80001ef6:	0000b797          	auipc	a5,0xb
    80001efa:	b607ad23          	sw	zero,-1158(a5) # 8000ca70 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001efe:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001f02:	00007517          	auipc	a0,0x7
    80001f06:	35650513          	addi	a0,a0,854 # 80009258 <etext+0x258>
    80001f0a:	fca43823          	sd	a0,-48(s0)
    80001f0e:	fc043c23          	sd	zero,-40(s0)
    80001f12:	fd040593          	addi	a1,s0,-48
    80001f16:	6f0030ef          	jal	80005606 <kexec>
    80001f1a:	6cbc                	ld	a5,88(s1)
    80001f1c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001f1e:	6cbc                	ld	a5,88(s1)
    80001f20:	7bb8                	ld	a4,112(a5)
    80001f22:	57fd                	li	a5,-1
    80001f24:	02f70d63          	beq	a4,a5,80001f5e <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001f28:	489000ef          	jal	80002bb0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001f2c:	68a8                	ld	a0,80(s1)
    80001f2e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001f30:	04000737          	lui	a4,0x4000
    80001f34:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001f36:	0732                	slli	a4,a4,0xc
    80001f38:	00006797          	auipc	a5,0x6
    80001f3c:	16478793          	addi	a5,a5,356 # 8000809c <userret>
    80001f40:	00006697          	auipc	a3,0x6
    80001f44:	0c068693          	addi	a3,a3,192 # 80008000 <_trampoline>
    80001f48:	8f95                	sub	a5,a5,a3
    80001f4a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001f4c:	577d                	li	a4,-1
    80001f4e:	177e                	slli	a4,a4,0x3f
    80001f50:	8d59                	or	a0,a0,a4
    80001f52:	9782                	jalr	a5
}
    80001f54:	70a2                	ld	ra,40(sp)
    80001f56:	7402                	ld	s0,32(sp)
    80001f58:	64e2                	ld	s1,24(sp)
    80001f5a:	6145                	addi	sp,sp,48
    80001f5c:	8082                	ret
      panic("exec");
    80001f5e:	00007517          	auipc	a0,0x7
    80001f62:	30250513          	addi	a0,a0,770 # 80009260 <etext+0x260>
    80001f66:	87bfe0ef          	jal	800007e0 <panic>

0000000080001f6a <allocpid>:
{
    80001f6a:	1101                	addi	sp,sp,-32
    80001f6c:	ec06                	sd	ra,24(sp)
    80001f6e:	e822                	sd	s0,16(sp)
    80001f70:	e426                	sd	s1,8(sp)
    80001f72:	e04a                	sd	s2,0(sp)
    80001f74:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001f76:	00013917          	auipc	s2,0x13
    80001f7a:	c5290913          	addi	s2,s2,-942 # 80014bc8 <pid_lock>
    80001f7e:	854a                	mv	a0,s2
    80001f80:	c4ffe0ef          	jal	80000bce <acquire>
  pid = nextpid;
    80001f84:	0000b797          	auipc	a5,0xb
    80001f88:	af078793          	addi	a5,a5,-1296 # 8000ca74 <nextpid>
    80001f8c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001f8e:	0014871b          	addiw	a4,s1,1
    80001f92:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001f94:	854a                	mv	a0,s2
    80001f96:	cd1fe0ef          	jal	80000c66 <release>
}
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	60e2                	ld	ra,24(sp)
    80001f9e:	6442                	ld	s0,16(sp)
    80001fa0:	64a2                	ld	s1,8(sp)
    80001fa2:	6902                	ld	s2,0(sp)
    80001fa4:	6105                	addi	sp,sp,32
    80001fa6:	8082                	ret

0000000080001fa8 <proc_pagetable>:
{
    80001fa8:	1101                	addi	sp,sp,-32
    80001faa:	ec06                	sd	ra,24(sp)
    80001fac:	e822                	sd	s0,16(sp)
    80001fae:	e426                	sd	s1,8(sp)
    80001fb0:	e04a                	sd	s2,0(sp)
    80001fb2:	1000                	addi	s0,sp,32
    80001fb4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001fb6:	aaeff0ef          	jal	80001264 <uvmcreate>
    80001fba:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001fbc:	cd05                	beqz	a0,80001ff4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001fbe:	4729                	li	a4,10
    80001fc0:	00006697          	auipc	a3,0x6
    80001fc4:	04068693          	addi	a3,a3,64 # 80008000 <_trampoline>
    80001fc8:	6605                	lui	a2,0x1
    80001fca:	040005b7          	lui	a1,0x4000
    80001fce:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001fd0:	05b2                	slli	a1,a1,0xc
    80001fd2:	8ecff0ef          	jal	800010be <mappages>
    80001fd6:	02054663          	bltz	a0,80002002 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001fda:	4719                	li	a4,6
    80001fdc:	05893683          	ld	a3,88(s2)
    80001fe0:	6605                	lui	a2,0x1
    80001fe2:	020005b7          	lui	a1,0x2000
    80001fe6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001fe8:	05b6                	slli	a1,a1,0xd
    80001fea:	8526                	mv	a0,s1
    80001fec:	8d2ff0ef          	jal	800010be <mappages>
    80001ff0:	00054f63          	bltz	a0,8000200e <proc_pagetable+0x66>
}
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	60e2                	ld	ra,24(sp)
    80001ff8:	6442                	ld	s0,16(sp)
    80001ffa:	64a2                	ld	s1,8(sp)
    80001ffc:	6902                	ld	s2,0(sp)
    80001ffe:	6105                	addi	sp,sp,32
    80002000:	8082                	ret
    uvmfree(pagetable, 0);
    80002002:	4581                	li	a1,0
    80002004:	8526                	mv	a0,s1
    80002006:	c58ff0ef          	jal	8000145e <uvmfree>
    return 0;
    8000200a:	4481                	li	s1,0
    8000200c:	b7e5                	j	80001ff4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000200e:	4681                	li	a3,0
    80002010:	4605                	li	a2,1
    80002012:	040005b7          	lui	a1,0x4000
    80002016:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002018:	05b2                	slli	a1,a1,0xc
    8000201a:	8526                	mv	a0,s1
    8000201c:	a6eff0ef          	jal	8000128a <uvmunmap>
    uvmfree(pagetable, 0);
    80002020:	4581                	li	a1,0
    80002022:	8526                	mv	a0,s1
    80002024:	c3aff0ef          	jal	8000145e <uvmfree>
    return 0;
    80002028:	4481                	li	s1,0
    8000202a:	b7e9                	j	80001ff4 <proc_pagetable+0x4c>

000000008000202c <proc_freepagetable>:
{
    8000202c:	1101                	addi	sp,sp,-32
    8000202e:	ec06                	sd	ra,24(sp)
    80002030:	e822                	sd	s0,16(sp)
    80002032:	e426                	sd	s1,8(sp)
    80002034:	e04a                	sd	s2,0(sp)
    80002036:	1000                	addi	s0,sp,32
    80002038:	84aa                	mv	s1,a0
    8000203a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000203c:	4681                	li	a3,0
    8000203e:	4605                	li	a2,1
    80002040:	040005b7          	lui	a1,0x4000
    80002044:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002046:	05b2                	slli	a1,a1,0xc
    80002048:	a42ff0ef          	jal	8000128a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000204c:	4681                	li	a3,0
    8000204e:	4605                	li	a2,1
    80002050:	020005b7          	lui	a1,0x2000
    80002054:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002056:	05b6                	slli	a1,a1,0xd
    80002058:	8526                	mv	a0,s1
    8000205a:	a30ff0ef          	jal	8000128a <uvmunmap>
  uvmfree(pagetable, sz);
    8000205e:	85ca                	mv	a1,s2
    80002060:	8526                	mv	a0,s1
    80002062:	bfcff0ef          	jal	8000145e <uvmfree>
}
    80002066:	60e2                	ld	ra,24(sp)
    80002068:	6442                	ld	s0,16(sp)
    8000206a:	64a2                	ld	s1,8(sp)
    8000206c:	6902                	ld	s2,0(sp)
    8000206e:	6105                	addi	sp,sp,32
    80002070:	8082                	ret

0000000080002072 <freeproc>:
{
    80002072:	1101                	addi	sp,sp,-32
    80002074:	ec06                	sd	ra,24(sp)
    80002076:	e822                	sd	s0,16(sp)
    80002078:	e426                	sd	s1,8(sp)
    8000207a:	1000                	addi	s0,sp,32
    8000207c:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000207e:	6d28                	ld	a0,88(a0)
    80002080:	c119                	beqz	a0,80002086 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80002082:	99bfe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80002086:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000208a:	68a8                	ld	a0,80(s1)
    8000208c:	c501                	beqz	a0,80002094 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    8000208e:	64ac                	ld	a1,72(s1)
    80002090:	f9dff0ef          	jal	8000202c <proc_freepagetable>
  p->pagetable = 0;
    80002094:	0404b823          	sd	zero,80(s1)
  if(p->exec_ip){
    80002098:	6791                	lui	a5,0x4
    8000209a:	97a6                	add	a5,a5,s1
    8000209c:	bb87b503          	ld	a0,-1096(a5) # 3bb8 <_entry-0x7fffc448>
    800020a0:	c519                	beqz	a0,800020ae <freeproc+0x3c>
    iput(p->exec_ip);
    800020a2:	302020ef          	jal	800043a4 <iput>
    p->exec_ip = 0;
    800020a6:	6791                	lui	a5,0x4
    800020a8:	97a6                	add	a5,a5,s1
    800020aa:	ba07bc23          	sd	zero,-1096(a5) # 3bb8 <_entry-0x7fffc448>
  p->sz = 0;
    800020ae:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800020b2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800020b6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800020ba:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800020be:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800020c2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800020c6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800020ca:	0004ac23          	sw	zero,24(s1)
}
    800020ce:	60e2                	ld	ra,24(sp)
    800020d0:	6442                	ld	s0,16(sp)
    800020d2:	64a2                	ld	s1,8(sp)
    800020d4:	6105                	addi	sp,sp,32
    800020d6:	8082                	ret

00000000800020d8 <allocproc>:
{
    800020d8:	7179                	addi	sp,sp,-48
    800020da:	f406                	sd	ra,40(sp)
    800020dc:	f022                	sd	s0,32(sp)
    800020de:	ec26                	sd	s1,24(sp)
    800020e0:	e84a                	sd	s2,16(sp)
    800020e2:	e44e                	sd	s3,8(sp)
    800020e4:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e6:	00013497          	auipc	s1,0x13
    800020ea:	f1248493          	addi	s1,s1,-238 # 80014ff8 <proc>
    800020ee:	6911                	lui	s2,0x4
    800020f0:	bf890913          	addi	s2,s2,-1032 # 3bf8 <_entry-0x7fffc408>
    800020f4:	00103997          	auipc	s3,0x103
    800020f8:	d0498993          	addi	s3,s3,-764 # 80104df8 <tickslock>
    acquire(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	ad1fe0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80002102:	4c9c                	lw	a5,24(s1)
    80002104:	cb89                	beqz	a5,80002116 <allocproc+0x3e>
      release(&p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	b5ffe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000210c:	94ca                	add	s1,s1,s2
    8000210e:	ff3497e3          	bne	s1,s3,800020fc <allocproc+0x24>
  return 0;
    80002112:	4481                	li	s1,0
    80002114:	a0dd                	j	800021fa <allocproc+0x122>
    80002116:	8926                	mv	s2,s1
  p->pid = allocpid();
    80002118:	e53ff0ef          	jal	80001f6a <allocpid>
    8000211c:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000211e:	4785                	li	a5,1
    80002120:	cc9c                	sw	a5,24(s1)
  p->swapfile = 0;
    80002122:	1604b423          	sd	zero,360(s1)
  p->num_swapped_pages = 0;
    80002126:	678d                	lui	a5,0x3
    80002128:	97a6                	add	a5,a5,s1
    8000212a:	1607a823          	sw	zero,368(a5) # 3170 <_entry-0x7fffce90>
  for(int i=0;i<MAX_SWAP_PAGES;i++){
    8000212e:	17048793          	addi	a5,s1,368
    80002132:	670d                	lui	a4,0x3
    80002134:	17070713          	addi	a4,a4,368 # 3170 <_entry-0x7fffce90>
    80002138:	9726                	add	a4,a4,s1
    p->swap_table[i].slot = -1;
    8000213a:	56fd                	li	a3,-1
    p->swap_table[i].used = 0;
    8000213c:	0007a423          	sw	zero,8(a5)
    p->swap_table[i].va = 0;
    80002140:	0007a023          	sw	zero,0(a5)
    p->swap_table[i].slot = -1;
    80002144:	c3d4                	sw	a3,4(a5)
  for(int i=0;i<MAX_SWAP_PAGES;i++){
    80002146:	07b1                	addi	a5,a5,12
    80002148:	fee79ae3          	bne	a5,a4,8000213c <allocproc+0x64>
  p->memstat.pid = p->pid;
    8000214c:	678d                	lui	a5,0x3
    8000214e:	97a6                	add	a5,a5,s1
    80002150:	16a7aa23          	sw	a0,372(a5) # 3174 <_entry-0x7fffce8c>
  p->memstat.num_pages_total = 0;
    80002154:	1607ac23          	sw	zero,376(a5)
  p->memstat.num_resident_pages = 0;
    80002158:	1607ae23          	sw	zero,380(a5)
  p->memstat.num_swapped_pages = 0;
    8000215c:	1807a023          	sw	zero,384(a5)
  p->memstat.next_fifo_seq = 0;
    80002160:	1807a223          	sw	zero,388(a5)
  for(int i = 0; i < MAX_PAGES_INFO; i++){
    80002164:	678d                	lui	a5,0x3
    80002166:	18878793          	addi	a5,a5,392 # 3188 <_entry-0x7fffce78>
    8000216a:	97a6                	add	a5,a5,s1
    8000216c:	6711                	lui	a4,0x4
    8000216e:	b8870713          	addi	a4,a4,-1144 # 3b88 <_entry-0x7fffc478>
    80002172:	974a                	add	a4,a4,s2
    p->memstat.pages[i].swap_slot = -1;
    80002174:	56fd                	li	a3,-1
    p->memstat.pages[i].va = 0;
    80002176:	0007a023          	sw	zero,0(a5)
    p->memstat.pages[i].state = UNMAPPED;
    8000217a:	0007a223          	sw	zero,4(a5)
    p->memstat.pages[i].is_dirty = 0;
    8000217e:	0007a423          	sw	zero,8(a5)
    p->memstat.pages[i].seq = 0;
    80002182:	0007a623          	sw	zero,12(a5)
    p->memstat.pages[i].swap_slot = -1;
    80002186:	cb94                	sw	a3,16(a5)
  for(int i = 0; i < MAX_PAGES_INFO; i++){
    80002188:	07d1                	addi	a5,a5,20
    8000218a:	fee796e3          	bne	a5,a4,80002176 <allocproc+0x9e>
  p->text_start = 0;
    8000218e:	6791                	lui	a5,0x4
    80002190:	97a6                	add	a5,a5,s1
    80002192:	b807b423          	sd	zero,-1144(a5) # 3b88 <_entry-0x7fffc478>
  p->text_end = 0;
    80002196:	b807b823          	sd	zero,-1136(a5)
  p->data_start = 0;
    8000219a:	b807bc23          	sd	zero,-1128(a5)
  p->data_end = 0;
    8000219e:	ba07b023          	sd	zero,-1120(a5)
  p->heap_start = 0;
    800021a2:	ba07b423          	sd	zero,-1112(a5)
  p->stack_top = 0;
    800021a6:	ba07b823          	sd	zero,-1104(a5)
  p->pagefault_count = 0;
    800021aa:	be07a023          	sw	zero,-1056(a5)
  p->resident_pages = 0;
    800021ae:	be07a223          	sw	zero,-1052(a5)
  p->swapped_pages = 0;
    800021b2:	be07a423          	sw	zero,-1048(a5)
  p->swapin_count = 0;
    800021b6:	be07a623          	sw	zero,-1044(a5)
  p->swapout_count = 0;
    800021ba:	be07a823          	sw	zero,-1040(a5)
  p->vmtrace = 1;
    800021be:	4705                	li	a4,1
    800021c0:	bee7aa23          	sw	a4,-1036(a5)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800021c4:	93bfe0ef          	jal	80000afe <kalloc>
    800021c8:	892a                	mv	s2,a0
    800021ca:	eca8                	sd	a0,88(s1)
    800021cc:	cd1d                	beqz	a0,8000220a <allocproc+0x132>
  p->pagetable = proc_pagetable(p);
    800021ce:	8526                	mv	a0,s1
    800021d0:	dd9ff0ef          	jal	80001fa8 <proc_pagetable>
    800021d4:	892a                	mv	s2,a0
    800021d6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800021d8:	c129                	beqz	a0,8000221a <allocproc+0x142>
  memset(&p->context, 0, sizeof(p->context));
    800021da:	07000613          	li	a2,112
    800021de:	4581                	li	a1,0
    800021e0:	06048513          	addi	a0,s1,96
    800021e4:	abffe0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    800021e8:	00000797          	auipc	a5,0x0
    800021ec:	cea78793          	addi	a5,a5,-790 # 80001ed2 <forkret>
    800021f0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800021f2:	60bc                	ld	a5,64(s1)
    800021f4:	6705                	lui	a4,0x1
    800021f6:	97ba                	add	a5,a5,a4
    800021f8:	f4bc                	sd	a5,104(s1)
}
    800021fa:	8526                	mv	a0,s1
    800021fc:	70a2                	ld	ra,40(sp)
    800021fe:	7402                	ld	s0,32(sp)
    80002200:	64e2                	ld	s1,24(sp)
    80002202:	6942                	ld	s2,16(sp)
    80002204:	69a2                	ld	s3,8(sp)
    80002206:	6145                	addi	sp,sp,48
    80002208:	8082                	ret
    freeproc(p);
    8000220a:	8526                	mv	a0,s1
    8000220c:	e67ff0ef          	jal	80002072 <freeproc>
    release(&p->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	a55fe0ef          	jal	80000c66 <release>
    return 0;
    80002216:	84ca                	mv	s1,s2
    80002218:	b7cd                	j	800021fa <allocproc+0x122>
    freeproc(p);
    8000221a:	8526                	mv	a0,s1
    8000221c:	e57ff0ef          	jal	80002072 <freeproc>
    release(&p->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	a45fe0ef          	jal	80000c66 <release>
    return 0;
    80002226:	84ca                	mv	s1,s2
    80002228:	bfc9                	j	800021fa <allocproc+0x122>

000000008000222a <userinit>:
{
    8000222a:	1101                	addi	sp,sp,-32
    8000222c:	ec06                	sd	ra,24(sp)
    8000222e:	e822                	sd	s0,16(sp)
    80002230:	e426                	sd	s1,8(sp)
    80002232:	1000                	addi	s0,sp,32
  p = allocproc();
    80002234:	ea5ff0ef          	jal	800020d8 <allocproc>
    80002238:	84aa                	mv	s1,a0
  initproc = p;
    8000223a:	0000b797          	auipc	a5,0xb
    8000223e:	88a7b323          	sd	a0,-1914(a5) # 8000cac0 <initproc>
  p->cwd = namei("/");
    80002242:	00007517          	auipc	a0,0x7
    80002246:	02650513          	addi	a0,a0,38 # 80009268 <etext+0x268>
    8000224a:	7ee020ef          	jal	80004a38 <namei>
    8000224e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80002252:	478d                	li	a5,3
    80002254:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80002256:	8526                	mv	a0,s1
    80002258:	a0ffe0ef          	jal	80000c66 <release>
}
    8000225c:	60e2                	ld	ra,24(sp)
    8000225e:	6442                	ld	s0,16(sp)
    80002260:	64a2                	ld	s1,8(sp)
    80002262:	6105                	addi	sp,sp,32
    80002264:	8082                	ret

0000000080002266 <growproc>:
{
    80002266:	1101                	addi	sp,sp,-32
    80002268:	ec06                	sd	ra,24(sp)
    8000226a:	e822                	sd	s0,16(sp)
    8000226c:	e426                	sd	s1,8(sp)
    8000226e:	e04a                	sd	s2,0(sp)
    80002270:	1000                	addi	s0,sp,32
    80002272:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002274:	c2fff0ef          	jal	80001ea2 <myproc>
    80002278:	892a                	mv	s2,a0
  sz = p->sz;
    8000227a:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000227c:	02905963          	blez	s1,800022ae <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80002280:	00b48633          	add	a2,s1,a1
    80002284:	020007b7          	lui	a5,0x2000
    80002288:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    8000228a:	07b6                	slli	a5,a5,0xd
    8000228c:	02c7ea63          	bltu	a5,a2,800022c0 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002290:	4691                	li	a3,4
    80002292:	6928                	ld	a0,80(a0)
    80002294:	8c4ff0ef          	jal	80001358 <uvmalloc>
    80002298:	85aa                	mv	a1,a0
    8000229a:	c50d                	beqz	a0,800022c4 <growproc+0x5e>
  p->sz = sz;
    8000229c:	04b93423          	sd	a1,72(s2)
  return 0;
    800022a0:	4501                	li	a0,0
}
    800022a2:	60e2                	ld	ra,24(sp)
    800022a4:	6442                	ld	s0,16(sp)
    800022a6:	64a2                	ld	s1,8(sp)
    800022a8:	6902                	ld	s2,0(sp)
    800022aa:	6105                	addi	sp,sp,32
    800022ac:	8082                	ret
  } else if(n < 0){
    800022ae:	fe04d7e3          	bgez	s1,8000229c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800022b2:	00b48633          	add	a2,s1,a1
    800022b6:	6928                	ld	a0,80(a0)
    800022b8:	85cff0ef          	jal	80001314 <uvmdealloc>
    800022bc:	85aa                	mv	a1,a0
    800022be:	bff9                	j	8000229c <growproc+0x36>
      return -1;
    800022c0:	557d                	li	a0,-1
    800022c2:	b7c5                	j	800022a2 <growproc+0x3c>
      return -1;
    800022c4:	557d                	li	a0,-1
    800022c6:	bff1                	j	800022a2 <growproc+0x3c>

00000000800022c8 <kfork>:
{
    800022c8:	7139                	addi	sp,sp,-64
    800022ca:	fc06                	sd	ra,56(sp)
    800022cc:	f822                	sd	s0,48(sp)
    800022ce:	f04a                	sd	s2,32(sp)
    800022d0:	e456                	sd	s5,8(sp)
    800022d2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800022d4:	bcfff0ef          	jal	80001ea2 <myproc>
    800022d8:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800022da:	dffff0ef          	jal	800020d8 <allocproc>
    800022de:	16050f63          	beqz	a0,8000245c <kfork+0x194>
    800022e2:	ec4e                	sd	s3,24(sp)
    800022e4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800022e6:	048ab603          	ld	a2,72(s5)
    800022ea:	692c                	ld	a1,80(a0)
    800022ec:	050ab503          	ld	a0,80(s5)
    800022f0:	9a0ff0ef          	jal	80001490 <uvmcopy>
    800022f4:	04054a63          	bltz	a0,80002348 <kfork+0x80>
    800022f8:	f426                	sd	s1,40(sp)
    800022fa:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800022fc:	048ab783          	ld	a5,72(s5)
    80002300:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002304:	058ab683          	ld	a3,88(s5)
    80002308:	87b6                	mv	a5,a3
    8000230a:	0589b703          	ld	a4,88(s3)
    8000230e:	12068693          	addi	a3,a3,288
    80002312:	0007b803          	ld	a6,0(a5)
    80002316:	6788                	ld	a0,8(a5)
    80002318:	6b8c                	ld	a1,16(a5)
    8000231a:	6f90                	ld	a2,24(a5)
    8000231c:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002320:	e708                	sd	a0,8(a4)
    80002322:	eb0c                	sd	a1,16(a4)
    80002324:	ef10                	sd	a2,24(a4)
    80002326:	02078793          	addi	a5,a5,32
    8000232a:	02070713          	addi	a4,a4,32
    8000232e:	fed792e3          	bne	a5,a3,80002312 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80002332:	0589b783          	ld	a5,88(s3)
    80002336:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000233a:	0d0a8493          	addi	s1,s5,208
    8000233e:	0d098913          	addi	s2,s3,208
    80002342:	150a8a13          	addi	s4,s5,336
    80002346:	a831                	j	80002362 <kfork+0x9a>
    freeproc(np);
    80002348:	854e                	mv	a0,s3
    8000234a:	d29ff0ef          	jal	80002072 <freeproc>
    release(&np->lock);
    8000234e:	854e                	mv	a0,s3
    80002350:	917fe0ef          	jal	80000c66 <release>
    return -1;
    80002354:	597d                	li	s2,-1
    80002356:	69e2                	ld	s3,24(sp)
    80002358:	a8dd                	j	8000244e <kfork+0x186>
  for(i = 0; i < NOFILE; i++)
    8000235a:	04a1                	addi	s1,s1,8
    8000235c:	0921                	addi	s2,s2,8
    8000235e:	01448963          	beq	s1,s4,80002370 <kfork+0xa8>
    if(p->ofile[i])
    80002362:	6088                	ld	a0,0(s1)
    80002364:	d97d                	beqz	a0,8000235a <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002366:	46d020ef          	jal	80004fd2 <filedup>
    8000236a:	00a93023          	sd	a0,0(s2)
    8000236e:	b7f5                	j	8000235a <kfork+0x92>
  np->cwd = idup(p->cwd);
    80002370:	150ab503          	ld	a0,336(s5)
    80002374:	679010ef          	jal	800041ec <idup>
    80002378:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000237c:	4641                	li	a2,16
    8000237e:	158a8593          	addi	a1,s5,344
    80002382:	15898513          	addi	a0,s3,344
    80002386:	a5bfe0ef          	jal	80000de0 <safestrcpy>
  np->text_start = p->text_start;
    8000238a:	6791                	lui	a5,0x4
    8000238c:	00fa8733          	add	a4,s5,a5
    80002390:	b8873683          	ld	a3,-1144(a4)
    80002394:	97ce                	add	a5,a5,s3
    80002396:	b8d7b423          	sd	a3,-1144(a5) # 3b88 <_entry-0x7fffc478>
  np->text_end = p->text_end;
    8000239a:	b9073683          	ld	a3,-1136(a4)
    8000239e:	b8d7b823          	sd	a3,-1136(a5)
  np->data_start = p->data_start;
    800023a2:	b9873683          	ld	a3,-1128(a4)
    800023a6:	b8d7bc23          	sd	a3,-1128(a5)
  np->data_end = p->data_end;
    800023aa:	ba073683          	ld	a3,-1120(a4)
    800023ae:	bad7b023          	sd	a3,-1120(a5)
  np->heap_start = p->heap_start;
    800023b2:	ba873683          	ld	a3,-1112(a4)
    800023b6:	bad7b423          	sd	a3,-1112(a5)
  np->stack_top = p->stack_top;
    800023ba:	bb073683          	ld	a3,-1104(a4)
    800023be:	bad7b823          	sd	a3,-1104(a5)
  np->text_off = p->text_off;
    800023c2:	bc072683          	lw	a3,-1088(a4)
    800023c6:	bcd7a023          	sw	a3,-1088(a5)
  np->text_filesz = p->text_filesz;
    800023ca:	bc472683          	lw	a3,-1084(a4)
    800023ce:	bcd7a223          	sw	a3,-1084(a5)
  np->text_memsz = p->text_memsz;
    800023d2:	bc872683          	lw	a3,-1080(a4)
    800023d6:	bcd7a423          	sw	a3,-1080(a5)
  np->text_flags = p->text_flags;
    800023da:	bcc72683          	lw	a3,-1076(a4)
    800023de:	bcd7a623          	sw	a3,-1076(a5)
  np->data_off = p->data_off;
    800023e2:	bd072683          	lw	a3,-1072(a4)
    800023e6:	bcd7a823          	sw	a3,-1072(a5)
  np->data_filesz = p->data_filesz;
    800023ea:	bd472683          	lw	a3,-1068(a4)
    800023ee:	bcd7aa23          	sw	a3,-1068(a5)
  np->data_memsz = p->data_memsz;
    800023f2:	bd872683          	lw	a3,-1064(a4)
    800023f6:	bcd7ac23          	sw	a3,-1064(a5)
  np->data_flags = p->data_flags;
    800023fa:	bdc72683          	lw	a3,-1060(a4)
    800023fe:	bcd7ae23          	sw	a3,-1060(a5)
  if(p->exec_ip){
    80002402:	bb873503          	ld	a0,-1096(a4)
    80002406:	c519                	beqz	a0,80002414 <kfork+0x14c>
    np->exec_ip = idup(p->exec_ip);
    80002408:	5e5010ef          	jal	800041ec <idup>
    8000240c:	6791                	lui	a5,0x4
    8000240e:	97ce                	add	a5,a5,s3
    80002410:	baa7bc23          	sd	a0,-1096(a5) # 3bb8 <_entry-0x7fffc448>
  pid = np->pid;
    80002414:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002418:	854e                	mv	a0,s3
    8000241a:	84dfe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    8000241e:	00012497          	auipc	s1,0x12
    80002422:	7c248493          	addi	s1,s1,1986 # 80014be0 <wait_lock>
    80002426:	8526                	mv	a0,s1
    80002428:	fa6fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    8000242c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002430:	8526                	mv	a0,s1
    80002432:	835fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80002436:	854e                	mv	a0,s3
    80002438:	f96fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    8000243c:	478d                	li	a5,3
    8000243e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002442:	854e                	mv	a0,s3
    80002444:	823fe0ef          	jal	80000c66 <release>
  return pid;
    80002448:	74a2                	ld	s1,40(sp)
    8000244a:	69e2                	ld	s3,24(sp)
    8000244c:	6a42                	ld	s4,16(sp)
}
    8000244e:	854a                	mv	a0,s2
    80002450:	70e2                	ld	ra,56(sp)
    80002452:	7442                	ld	s0,48(sp)
    80002454:	7902                	ld	s2,32(sp)
    80002456:	6aa2                	ld	s5,8(sp)
    80002458:	6121                	addi	sp,sp,64
    8000245a:	8082                	ret
    return -1;
    8000245c:	597d                	li	s2,-1
    8000245e:	bfc5                	j	8000244e <kfork+0x186>

0000000080002460 <scheduler>:
{
    80002460:	711d                	addi	sp,sp,-96
    80002462:	ec86                	sd	ra,88(sp)
    80002464:	e8a2                	sd	s0,80(sp)
    80002466:	e4a6                	sd	s1,72(sp)
    80002468:	e0ca                	sd	s2,64(sp)
    8000246a:	fc4e                	sd	s3,56(sp)
    8000246c:	f852                	sd	s4,48(sp)
    8000246e:	f456                	sd	s5,40(sp)
    80002470:	f05a                	sd	s6,32(sp)
    80002472:	ec5e                	sd	s7,24(sp)
    80002474:	e862                	sd	s8,16(sp)
    80002476:	e466                	sd	s9,8(sp)
    80002478:	1080                	addi	s0,sp,96
    8000247a:	8792                	mv	a5,tp
  int id = r_tp();
    8000247c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000247e:	00779c13          	slli	s8,a5,0x7
    80002482:	00012717          	auipc	a4,0x12
    80002486:	74670713          	addi	a4,a4,1862 # 80014bc8 <pid_lock>
    8000248a:	9762                	add	a4,a4,s8
    8000248c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002490:	00012717          	auipc	a4,0x12
    80002494:	77070713          	addi	a4,a4,1904 # 80014c00 <cpus+0x8>
    80002498:	9c3a                	add	s8,s8,a4
        p->state = RUNNING;
    8000249a:	4c91                	li	s9,4
        c->proc = p;
    8000249c:	079e                	slli	a5,a5,0x7
    8000249e:	00012a97          	auipc	s5,0x12
    800024a2:	72aa8a93          	addi	s5,s5,1834 # 80014bc8 <pid_lock>
    800024a6:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800024a8:	6991                	lui	s3,0x4
    800024aa:	bf898993          	addi	s3,s3,-1032 # 3bf8 <_entry-0x7fffc408>
    800024ae:	00103a17          	auipc	s4,0x103
    800024b2:	94aa0a13          	addi	s4,s4,-1718 # 80104df8 <tickslock>
    800024b6:	a835                	j	800024f2 <scheduler+0x92>
      release(&p->lock);
    800024b8:	8526                	mv	a0,s1
    800024ba:	facfe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800024be:	94ce                	add	s1,s1,s3
    800024c0:	03448563          	beq	s1,s4,800024ea <scheduler+0x8a>
      acquire(&p->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	f08fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    800024ca:	4c9c                	lw	a5,24(s1)
    800024cc:	ff2796e3          	bne	a5,s2,800024b8 <scheduler+0x58>
        p->state = RUNNING;
    800024d0:	0194ac23          	sw	s9,24(s1)
        c->proc = p;
    800024d4:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    800024d8:	06048593          	addi	a1,s1,96
    800024dc:	8562                	mv	a0,s8
    800024de:	5fe000ef          	jal	80002adc <swtch>
        c->proc = 0;
    800024e2:	020ab823          	sd	zero,48(s5)
        found = 1;
    800024e6:	8b5e                	mv	s6,s7
    800024e8:	bfc1                	j	800024b8 <scheduler+0x58>
    if(found == 0) {
    800024ea:	000b1463          	bnez	s6,800024f2 <scheduler+0x92>
      asm volatile("wfi");
    800024ee:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024fa:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002502:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002504:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002508:	4b01                	li	s6,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000250a:	00013497          	auipc	s1,0x13
    8000250e:	aee48493          	addi	s1,s1,-1298 # 80014ff8 <proc>
      if(p->state == RUNNABLE) {
    80002512:	490d                	li	s2,3
        found = 1;
    80002514:	4b85                	li	s7,1
    80002516:	b77d                	j	800024c4 <scheduler+0x64>

0000000080002518 <sched>:
{
    80002518:	7179                	addi	sp,sp,-48
    8000251a:	f406                	sd	ra,40(sp)
    8000251c:	f022                	sd	s0,32(sp)
    8000251e:	ec26                	sd	s1,24(sp)
    80002520:	e84a                	sd	s2,16(sp)
    80002522:	e44e                	sd	s3,8(sp)
    80002524:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002526:	97dff0ef          	jal	80001ea2 <myproc>
    8000252a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000252c:	e38fe0ef          	jal	80000b64 <holding>
    80002530:	c92d                	beqz	a0,800025a2 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002532:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002534:	2781                	sext.w	a5,a5
    80002536:	079e                	slli	a5,a5,0x7
    80002538:	00012717          	auipc	a4,0x12
    8000253c:	69070713          	addi	a4,a4,1680 # 80014bc8 <pid_lock>
    80002540:	97ba                	add	a5,a5,a4
    80002542:	0a87a703          	lw	a4,168(a5)
    80002546:	4785                	li	a5,1
    80002548:	06f71363          	bne	a4,a5,800025ae <sched+0x96>
  if(p->state == RUNNING)
    8000254c:	4c98                	lw	a4,24(s1)
    8000254e:	4791                	li	a5,4
    80002550:	06f70563          	beq	a4,a5,800025ba <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002554:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002558:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000255a:	e7b5                	bnez	a5,800025c6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000255c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000255e:	00012917          	auipc	s2,0x12
    80002562:	66a90913          	addi	s2,s2,1642 # 80014bc8 <pid_lock>
    80002566:	2781                	sext.w	a5,a5
    80002568:	079e                	slli	a5,a5,0x7
    8000256a:	97ca                	add	a5,a5,s2
    8000256c:	0ac7a983          	lw	s3,172(a5)
    80002570:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002572:	2781                	sext.w	a5,a5
    80002574:	079e                	slli	a5,a5,0x7
    80002576:	00012597          	auipc	a1,0x12
    8000257a:	68a58593          	addi	a1,a1,1674 # 80014c00 <cpus+0x8>
    8000257e:	95be                	add	a1,a1,a5
    80002580:	06048513          	addi	a0,s1,96
    80002584:	558000ef          	jal	80002adc <swtch>
    80002588:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000258a:	2781                	sext.w	a5,a5
    8000258c:	079e                	slli	a5,a5,0x7
    8000258e:	993e                	add	s2,s2,a5
    80002590:	0b392623          	sw	s3,172(s2)
}
    80002594:	70a2                	ld	ra,40(sp)
    80002596:	7402                	ld	s0,32(sp)
    80002598:	64e2                	ld	s1,24(sp)
    8000259a:	6942                	ld	s2,16(sp)
    8000259c:	69a2                	ld	s3,8(sp)
    8000259e:	6145                	addi	sp,sp,48
    800025a0:	8082                	ret
    panic("sched p->lock");
    800025a2:	00007517          	auipc	a0,0x7
    800025a6:	cce50513          	addi	a0,a0,-818 # 80009270 <etext+0x270>
    800025aa:	a36fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    800025ae:	00007517          	auipc	a0,0x7
    800025b2:	cd250513          	addi	a0,a0,-814 # 80009280 <etext+0x280>
    800025b6:	a2afe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    800025ba:	00007517          	auipc	a0,0x7
    800025be:	cd650513          	addi	a0,a0,-810 # 80009290 <etext+0x290>
    800025c2:	a1efe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    800025c6:	00007517          	auipc	a0,0x7
    800025ca:	cda50513          	addi	a0,a0,-806 # 800092a0 <etext+0x2a0>
    800025ce:	a12fe0ef          	jal	800007e0 <panic>

00000000800025d2 <yield>:
{
    800025d2:	1101                	addi	sp,sp,-32
    800025d4:	ec06                	sd	ra,24(sp)
    800025d6:	e822                	sd	s0,16(sp)
    800025d8:	e426                	sd	s1,8(sp)
    800025da:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800025dc:	8c7ff0ef          	jal	80001ea2 <myproc>
    800025e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025e2:	decfe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    800025e6:	478d                	li	a5,3
    800025e8:	cc9c                	sw	a5,24(s1)
  sched();
    800025ea:	f2fff0ef          	jal	80002518 <sched>
  release(&p->lock);
    800025ee:	8526                	mv	a0,s1
    800025f0:	e76fe0ef          	jal	80000c66 <release>
}
    800025f4:	60e2                	ld	ra,24(sp)
    800025f6:	6442                	ld	s0,16(sp)
    800025f8:	64a2                	ld	s1,8(sp)
    800025fa:	6105                	addi	sp,sp,32
    800025fc:	8082                	ret

00000000800025fe <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800025fe:	7179                	addi	sp,sp,-48
    80002600:	f406                	sd	ra,40(sp)
    80002602:	f022                	sd	s0,32(sp)
    80002604:	ec26                	sd	s1,24(sp)
    80002606:	e84a                	sd	s2,16(sp)
    80002608:	e44e                	sd	s3,8(sp)
    8000260a:	1800                	addi	s0,sp,48
    8000260c:	89aa                	mv	s3,a0
    8000260e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002610:	893ff0ef          	jal	80001ea2 <myproc>
    80002614:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002616:	db8fe0ef          	jal	80000bce <acquire>
  release(lk);
    8000261a:	854a                	mv	a0,s2
    8000261c:	e4afe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80002620:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002624:	4789                	li	a5,2
    80002626:	cc9c                	sw	a5,24(s1)

  sched();
    80002628:	ef1ff0ef          	jal	80002518 <sched>

  // Tidy up.
  p->chan = 0;
    8000262c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002630:	8526                	mv	a0,s1
    80002632:	e34fe0ef          	jal	80000c66 <release>
  acquire(lk);
    80002636:	854a                	mv	a0,s2
    80002638:	d96fe0ef          	jal	80000bce <acquire>
}
    8000263c:	70a2                	ld	ra,40(sp)
    8000263e:	7402                	ld	s0,32(sp)
    80002640:	64e2                	ld	s1,24(sp)
    80002642:	6942                	ld	s2,16(sp)
    80002644:	69a2                	ld	s3,8(sp)
    80002646:	6145                	addi	sp,sp,48
    80002648:	8082                	ret

000000008000264a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000264a:	7139                	addi	sp,sp,-64
    8000264c:	fc06                	sd	ra,56(sp)
    8000264e:	f822                	sd	s0,48(sp)
    80002650:	f426                	sd	s1,40(sp)
    80002652:	f04a                	sd	s2,32(sp)
    80002654:	ec4e                	sd	s3,24(sp)
    80002656:	e852                	sd	s4,16(sp)
    80002658:	e456                	sd	s5,8(sp)
    8000265a:	e05a                	sd	s6,0(sp)
    8000265c:	0080                	addi	s0,sp,64
    8000265e:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002660:	00013497          	auipc	s1,0x13
    80002664:	99848493          	addi	s1,s1,-1640 # 80014ff8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002668:	4a09                	li	s4,2
        p->state = RUNNABLE;
    8000266a:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000266c:	6911                	lui	s2,0x4
    8000266e:	bf890913          	addi	s2,s2,-1032 # 3bf8 <_entry-0x7fffc408>
    80002672:	00102997          	auipc	s3,0x102
    80002676:	78698993          	addi	s3,s3,1926 # 80104df8 <tickslock>
    8000267a:	a039                	j	80002688 <wakeup+0x3e>
      }
      release(&p->lock);
    8000267c:	8526                	mv	a0,s1
    8000267e:	de8fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002682:	94ca                	add	s1,s1,s2
    80002684:	03348263          	beq	s1,s3,800026a8 <wakeup+0x5e>
    if(p != myproc()){
    80002688:	81bff0ef          	jal	80001ea2 <myproc>
    8000268c:	fea48be3          	beq	s1,a0,80002682 <wakeup+0x38>
      acquire(&p->lock);
    80002690:	8526                	mv	a0,s1
    80002692:	d3cfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002696:	4c9c                	lw	a5,24(s1)
    80002698:	ff4792e3          	bne	a5,s4,8000267c <wakeup+0x32>
    8000269c:	709c                	ld	a5,32(s1)
    8000269e:	fd579fe3          	bne	a5,s5,8000267c <wakeup+0x32>
        p->state = RUNNABLE;
    800026a2:	0164ac23          	sw	s6,24(s1)
    800026a6:	bfd9                	j	8000267c <wakeup+0x32>
    }
  }
}
    800026a8:	70e2                	ld	ra,56(sp)
    800026aa:	7442                	ld	s0,48(sp)
    800026ac:	74a2                	ld	s1,40(sp)
    800026ae:	7902                	ld	s2,32(sp)
    800026b0:	69e2                	ld	s3,24(sp)
    800026b2:	6a42                	ld	s4,16(sp)
    800026b4:	6aa2                	ld	s5,8(sp)
    800026b6:	6b02                	ld	s6,0(sp)
    800026b8:	6121                	addi	sp,sp,64
    800026ba:	8082                	ret

00000000800026bc <reparent>:
{
    800026bc:	7139                	addi	sp,sp,-64
    800026be:	fc06                	sd	ra,56(sp)
    800026c0:	f822                	sd	s0,48(sp)
    800026c2:	f426                	sd	s1,40(sp)
    800026c4:	f04a                	sd	s2,32(sp)
    800026c6:	ec4e                	sd	s3,24(sp)
    800026c8:	e852                	sd	s4,16(sp)
    800026ca:	e456                	sd	s5,8(sp)
    800026cc:	0080                	addi	s0,sp,64
    800026ce:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800026d0:	00013497          	auipc	s1,0x13
    800026d4:	92848493          	addi	s1,s1,-1752 # 80014ff8 <proc>
      pp->parent = initproc;
    800026d8:	0000aa97          	auipc	s5,0xa
    800026dc:	3e8a8a93          	addi	s5,s5,1000 # 8000cac0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800026e0:	6911                	lui	s2,0x4
    800026e2:	bf890913          	addi	s2,s2,-1032 # 3bf8 <_entry-0x7fffc408>
    800026e6:	00102a17          	auipc	s4,0x102
    800026ea:	712a0a13          	addi	s4,s4,1810 # 80104df8 <tickslock>
    800026ee:	a021                	j	800026f6 <reparent+0x3a>
    800026f0:	94ca                	add	s1,s1,s2
    800026f2:	01448b63          	beq	s1,s4,80002708 <reparent+0x4c>
    if(pp->parent == p){
    800026f6:	7c9c                	ld	a5,56(s1)
    800026f8:	ff379ce3          	bne	a5,s3,800026f0 <reparent+0x34>
      pp->parent = initproc;
    800026fc:	000ab503          	ld	a0,0(s5)
    80002700:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002702:	f49ff0ef          	jal	8000264a <wakeup>
    80002706:	b7ed                	j	800026f0 <reparent+0x34>
}
    80002708:	70e2                	ld	ra,56(sp)
    8000270a:	7442                	ld	s0,48(sp)
    8000270c:	74a2                	ld	s1,40(sp)
    8000270e:	7902                	ld	s2,32(sp)
    80002710:	69e2                	ld	s3,24(sp)
    80002712:	6a42                	ld	s4,16(sp)
    80002714:	6aa2                	ld	s5,8(sp)
    80002716:	6121                	addi	sp,sp,64
    80002718:	8082                	ret

000000008000271a <kexit>:
{
    8000271a:	7139                	addi	sp,sp,-64
    8000271c:	fc06                	sd	ra,56(sp)
    8000271e:	f822                	sd	s0,48(sp)
    80002720:	f426                	sd	s1,40(sp)
    80002722:	f04a                	sd	s2,32(sp)
    80002724:	ec4e                	sd	s3,24(sp)
    80002726:	e852                	sd	s4,16(sp)
    80002728:	0080                	addi	s0,sp,64
    8000272a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000272c:	f76ff0ef          	jal	80001ea2 <myproc>
    80002730:	89aa                	mv	s3,a0
  if(p == initproc)
    80002732:	0000a797          	auipc	a5,0xa
    80002736:	38e7b783          	ld	a5,910(a5) # 8000cac0 <initproc>
    8000273a:	0d050493          	addi	s1,a0,208
    8000273e:	15050913          	addi	s2,a0,336
    80002742:	00a79f63          	bne	a5,a0,80002760 <kexit+0x46>
    panic("init exiting");
    80002746:	00007517          	auipc	a0,0x7
    8000274a:	b7250513          	addi	a0,a0,-1166 # 800092b8 <etext+0x2b8>
    8000274e:	892fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002752:	0c7020ef          	jal	80005018 <fileclose>
      p->ofile[fd] = 0;
    80002756:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000275a:	04a1                	addi	s1,s1,8
    8000275c:	01248563          	beq	s1,s2,80002766 <kexit+0x4c>
    if(p->ofile[fd]){
    80002760:	6088                	ld	a0,0(s1)
    80002762:	f965                	bnez	a0,80002752 <kexit+0x38>
    80002764:	bfdd                	j	8000275a <kexit+0x40>
  begin_op();
    80002766:	4a6020ef          	jal	80004c0c <begin_op>
  iput(p->cwd);
    8000276a:	1509b503          	ld	a0,336(s3)
    8000276e:	437010ef          	jal	800043a4 <iput>
  end_op();
    80002772:	504020ef          	jal	80004c76 <end_op>
  p->cwd = 0;
    80002776:	1409b823          	sd	zero,336(s3)
  if(p->swapfile){
    8000277a:	1689b783          	ld	a5,360(s3)
    8000277e:	c395                	beqz	a5,800027a2 <kexit+0x88>
    int freed_slots = 0;
    80002780:	fc042623          	sw	zero,-52(s0)
    swapfile_cleanup(p, &freed_slots);
    80002784:	fcc40593          	addi	a1,s0,-52
    80002788:	854e                	mv	a0,s3
    8000278a:	49e040ef          	jal	80006c28 <swapfile_cleanup>
    printf("[pid %d] SWAPCLEANUP freed_slots=%d\n", p->pid, freed_slots);
    8000278e:	fcc42603          	lw	a2,-52(s0)
    80002792:	0309a583          	lw	a1,48(s3)
    80002796:	00007517          	auipc	a0,0x7
    8000279a:	b3250513          	addi	a0,a0,-1230 # 800092c8 <etext+0x2c8>
    8000279e:	d5dfd0ef          	jal	800004fa <printf>
  acquire(&wait_lock);
    800027a2:	00012497          	auipc	s1,0x12
    800027a6:	43e48493          	addi	s1,s1,1086 # 80014be0 <wait_lock>
    800027aa:	8526                	mv	a0,s1
    800027ac:	c22fe0ef          	jal	80000bce <acquire>
  reparent(p);
    800027b0:	854e                	mv	a0,s3
    800027b2:	f0bff0ef          	jal	800026bc <reparent>
  wakeup(p->parent);
    800027b6:	0389b503          	ld	a0,56(s3)
    800027ba:	e91ff0ef          	jal	8000264a <wakeup>
  acquire(&p->lock);
    800027be:	854e                	mv	a0,s3
    800027c0:	c0efe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    800027c4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800027c8:	4795                	li	a5,5
    800027ca:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800027ce:	8526                	mv	a0,s1
    800027d0:	c96fe0ef          	jal	80000c66 <release>
  sched();
    800027d4:	d45ff0ef          	jal	80002518 <sched>
  panic("zombie exit");
    800027d8:	00007517          	auipc	a0,0x7
    800027dc:	b1850513          	addi	a0,a0,-1256 # 800092f0 <etext+0x2f0>
    800027e0:	800fe0ef          	jal	800007e0 <panic>

00000000800027e4 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800027e4:	7179                	addi	sp,sp,-48
    800027e6:	f406                	sd	ra,40(sp)
    800027e8:	f022                	sd	s0,32(sp)
    800027ea:	ec26                	sd	s1,24(sp)
    800027ec:	e84a                	sd	s2,16(sp)
    800027ee:	e44e                	sd	s3,8(sp)
    800027f0:	e052                	sd	s4,0(sp)
    800027f2:	1800                	addi	s0,sp,48
    800027f4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800027f6:	00013497          	auipc	s1,0x13
    800027fa:	80248493          	addi	s1,s1,-2046 # 80014ff8 <proc>
    800027fe:	6991                	lui	s3,0x4
    80002800:	bf898993          	addi	s3,s3,-1032 # 3bf8 <_entry-0x7fffc408>
    80002804:	00102a17          	auipc	s4,0x102
    80002808:	5f4a0a13          	addi	s4,s4,1524 # 80104df8 <tickslock>
    acquire(&p->lock);
    8000280c:	8526                	mv	a0,s1
    8000280e:	bc0fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    80002812:	589c                	lw	a5,48(s1)
    80002814:	01278a63          	beq	a5,s2,80002828 <kkill+0x44>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002818:	8526                	mv	a0,s1
    8000281a:	c4cfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000281e:	94ce                	add	s1,s1,s3
    80002820:	ff4496e3          	bne	s1,s4,8000280c <kkill+0x28>
  }
  return -1;
    80002824:	557d                	li	a0,-1
    80002826:	a819                	j	8000283c <kkill+0x58>
      p->killed = 1;
    80002828:	4785                	li	a5,1
    8000282a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000282c:	4c98                	lw	a4,24(s1)
    8000282e:	4789                	li	a5,2
    80002830:	00f70e63          	beq	a4,a5,8000284c <kkill+0x68>
      release(&p->lock);
    80002834:	8526                	mv	a0,s1
    80002836:	c30fe0ef          	jal	80000c66 <release>
      return 0;
    8000283a:	4501                	li	a0,0
}
    8000283c:	70a2                	ld	ra,40(sp)
    8000283e:	7402                	ld	s0,32(sp)
    80002840:	64e2                	ld	s1,24(sp)
    80002842:	6942                	ld	s2,16(sp)
    80002844:	69a2                	ld	s3,8(sp)
    80002846:	6a02                	ld	s4,0(sp)
    80002848:	6145                	addi	sp,sp,48
    8000284a:	8082                	ret
        p->state = RUNNABLE;
    8000284c:	478d                	li	a5,3
    8000284e:	cc9c                	sw	a5,24(s1)
    80002850:	b7d5                	j	80002834 <kkill+0x50>

0000000080002852 <setkilled>:

void
setkilled(struct proc *p)
{
    80002852:	1101                	addi	sp,sp,-32
    80002854:	ec06                	sd	ra,24(sp)
    80002856:	e822                	sd	s0,16(sp)
    80002858:	e426                	sd	s1,8(sp)
    8000285a:	1000                	addi	s0,sp,32
    8000285c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000285e:	b70fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    80002862:	4785                	li	a5,1
    80002864:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002866:	8526                	mv	a0,s1
    80002868:	bfefe0ef          	jal	80000c66 <release>
}
    8000286c:	60e2                	ld	ra,24(sp)
    8000286e:	6442                	ld	s0,16(sp)
    80002870:	64a2                	ld	s1,8(sp)
    80002872:	6105                	addi	sp,sp,32
    80002874:	8082                	ret

0000000080002876 <killed>:

int
killed(struct proc *p)
{
    80002876:	1101                	addi	sp,sp,-32
    80002878:	ec06                	sd	ra,24(sp)
    8000287a:	e822                	sd	s0,16(sp)
    8000287c:	e426                	sd	s1,8(sp)
    8000287e:	e04a                	sd	s2,0(sp)
    80002880:	1000                	addi	s0,sp,32
    80002882:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002884:	b4afe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002888:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000288c:	8526                	mv	a0,s1
    8000288e:	bd8fe0ef          	jal	80000c66 <release>
  return k;
}
    80002892:	854a                	mv	a0,s2
    80002894:	60e2                	ld	ra,24(sp)
    80002896:	6442                	ld	s0,16(sp)
    80002898:	64a2                	ld	s1,8(sp)
    8000289a:	6902                	ld	s2,0(sp)
    8000289c:	6105                	addi	sp,sp,32
    8000289e:	8082                	ret

00000000800028a0 <kwait>:
{
    800028a0:	715d                	addi	sp,sp,-80
    800028a2:	e486                	sd	ra,72(sp)
    800028a4:	e0a2                	sd	s0,64(sp)
    800028a6:	fc26                	sd	s1,56(sp)
    800028a8:	f84a                	sd	s2,48(sp)
    800028aa:	f44e                	sd	s3,40(sp)
    800028ac:	f052                	sd	s4,32(sp)
    800028ae:	ec56                	sd	s5,24(sp)
    800028b0:	e85a                	sd	s6,16(sp)
    800028b2:	e45e                	sd	s7,8(sp)
    800028b4:	e062                	sd	s8,0(sp)
    800028b6:	0880                	addi	s0,sp,80
    800028b8:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800028ba:	de8ff0ef          	jal	80001ea2 <myproc>
    800028be:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800028c0:	00012517          	auipc	a0,0x12
    800028c4:	32050513          	addi	a0,a0,800 # 80014be0 <wait_lock>
    800028c8:	b06fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800028cc:	4a95                	li	s5,5
        havekids = 1;
    800028ce:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800028d0:	6991                	lui	s3,0x4
    800028d2:	bf898993          	addi	s3,s3,-1032 # 3bf8 <_entry-0x7fffc408>
    800028d6:	00102a17          	auipc	s4,0x102
    800028da:	522a0a13          	addi	s4,s4,1314 # 80104df8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800028de:	00012c17          	auipc	s8,0x12
    800028e2:	302c0c13          	addi	s8,s8,770 # 80014be0 <wait_lock>
    800028e6:	a869                	j	80002980 <kwait+0xe0>
          pid = pp->pid;
    800028e8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800028ec:	000b8c63          	beqz	s7,80002904 <kwait+0x64>
    800028f0:	4691                	li	a3,4
    800028f2:	02c48613          	addi	a2,s1,44
    800028f6:	85de                	mv	a1,s7
    800028f8:	05093503          	ld	a0,80(s2)
    800028fc:	984ff0ef          	jal	80001a80 <copyout>
    80002900:	02054b63          	bltz	a0,80002936 <kwait+0x96>
          freeproc(pp);
    80002904:	8526                	mv	a0,s1
    80002906:	f6cff0ef          	jal	80002072 <freeproc>
          release(&pp->lock);
    8000290a:	8526                	mv	a0,s1
    8000290c:	b5afe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002910:	00012517          	auipc	a0,0x12
    80002914:	2d050513          	addi	a0,a0,720 # 80014be0 <wait_lock>
    80002918:	b4efe0ef          	jal	80000c66 <release>
}
    8000291c:	854e                	mv	a0,s3
    8000291e:	60a6                	ld	ra,72(sp)
    80002920:	6406                	ld	s0,64(sp)
    80002922:	74e2                	ld	s1,56(sp)
    80002924:	7942                	ld	s2,48(sp)
    80002926:	79a2                	ld	s3,40(sp)
    80002928:	7a02                	ld	s4,32(sp)
    8000292a:	6ae2                	ld	s5,24(sp)
    8000292c:	6b42                	ld	s6,16(sp)
    8000292e:	6ba2                	ld	s7,8(sp)
    80002930:	6c02                	ld	s8,0(sp)
    80002932:	6161                	addi	sp,sp,80
    80002934:	8082                	ret
            release(&pp->lock);
    80002936:	8526                	mv	a0,s1
    80002938:	b2efe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    8000293c:	00012517          	auipc	a0,0x12
    80002940:	2a450513          	addi	a0,a0,676 # 80014be0 <wait_lock>
    80002944:	b22fe0ef          	jal	80000c66 <release>
            return -1;
    80002948:	59fd                	li	s3,-1
    8000294a:	bfc9                	j	8000291c <kwait+0x7c>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000294c:	94ce                	add	s1,s1,s3
    8000294e:	03448063          	beq	s1,s4,8000296e <kwait+0xce>
      if(pp->parent == p){
    80002952:	7c9c                	ld	a5,56(s1)
    80002954:	ff279ce3          	bne	a5,s2,8000294c <kwait+0xac>
        acquire(&pp->lock);
    80002958:	8526                	mv	a0,s1
    8000295a:	a74fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    8000295e:	4c9c                	lw	a5,24(s1)
    80002960:	f95784e3          	beq	a5,s5,800028e8 <kwait+0x48>
        release(&pp->lock);
    80002964:	8526                	mv	a0,s1
    80002966:	b00fe0ef          	jal	80000c66 <release>
        havekids = 1;
    8000296a:	875a                	mv	a4,s6
    8000296c:	b7c5                	j	8000294c <kwait+0xac>
    if(!havekids || killed(p)){
    8000296e:	cf19                	beqz	a4,8000298c <kwait+0xec>
    80002970:	854a                	mv	a0,s2
    80002972:	f05ff0ef          	jal	80002876 <killed>
    80002976:	e919                	bnez	a0,8000298c <kwait+0xec>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002978:	85e2                	mv	a1,s8
    8000297a:	854a                	mv	a0,s2
    8000297c:	c83ff0ef          	jal	800025fe <sleep>
    havekids = 0;
    80002980:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002982:	00012497          	auipc	s1,0x12
    80002986:	67648493          	addi	s1,s1,1654 # 80014ff8 <proc>
    8000298a:	b7e1                	j	80002952 <kwait+0xb2>
      release(&wait_lock);
    8000298c:	00012517          	auipc	a0,0x12
    80002990:	25450513          	addi	a0,a0,596 # 80014be0 <wait_lock>
    80002994:	ad2fe0ef          	jal	80000c66 <release>
      return -1;
    80002998:	59fd                	li	s3,-1
    8000299a:	b749                	j	8000291c <kwait+0x7c>

000000008000299c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000299c:	7179                	addi	sp,sp,-48
    8000299e:	f406                	sd	ra,40(sp)
    800029a0:	f022                	sd	s0,32(sp)
    800029a2:	ec26                	sd	s1,24(sp)
    800029a4:	e84a                	sd	s2,16(sp)
    800029a6:	e44e                	sd	s3,8(sp)
    800029a8:	e052                	sd	s4,0(sp)
    800029aa:	1800                	addi	s0,sp,48
    800029ac:	84aa                	mv	s1,a0
    800029ae:	892e                	mv	s2,a1
    800029b0:	89b2                	mv	s3,a2
    800029b2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029b4:	ceeff0ef          	jal	80001ea2 <myproc>
  if(user_dst){
    800029b8:	cc99                	beqz	s1,800029d6 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800029ba:	86d2                	mv	a3,s4
    800029bc:	864e                	mv	a2,s3
    800029be:	85ca                	mv	a1,s2
    800029c0:	6928                	ld	a0,80(a0)
    800029c2:	8beff0ef          	jal	80001a80 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800029c6:	70a2                	ld	ra,40(sp)
    800029c8:	7402                	ld	s0,32(sp)
    800029ca:	64e2                	ld	s1,24(sp)
    800029cc:	6942                	ld	s2,16(sp)
    800029ce:	69a2                	ld	s3,8(sp)
    800029d0:	6a02                	ld	s4,0(sp)
    800029d2:	6145                	addi	sp,sp,48
    800029d4:	8082                	ret
    memmove((char *)dst, src, len);
    800029d6:	000a061b          	sext.w	a2,s4
    800029da:	85ce                	mv	a1,s3
    800029dc:	854a                	mv	a0,s2
    800029de:	b20fe0ef          	jal	80000cfe <memmove>
    return 0;
    800029e2:	8526                	mv	a0,s1
    800029e4:	b7cd                	j	800029c6 <either_copyout+0x2a>

00000000800029e6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800029e6:	7179                	addi	sp,sp,-48
    800029e8:	f406                	sd	ra,40(sp)
    800029ea:	f022                	sd	s0,32(sp)
    800029ec:	ec26                	sd	s1,24(sp)
    800029ee:	e84a                	sd	s2,16(sp)
    800029f0:	e44e                	sd	s3,8(sp)
    800029f2:	e052                	sd	s4,0(sp)
    800029f4:	1800                	addi	s0,sp,48
    800029f6:	892a                	mv	s2,a0
    800029f8:	84ae                	mv	s1,a1
    800029fa:	89b2                	mv	s3,a2
    800029fc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029fe:	ca4ff0ef          	jal	80001ea2 <myproc>
  if(user_src){
    80002a02:	cc99                	beqz	s1,80002a20 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002a04:	86d2                	mv	a3,s4
    80002a06:	864e                	mv	a2,s3
    80002a08:	85ca                	mv	a1,s2
    80002a0a:	6928                	ld	a0,80(a0)
    80002a0c:	958ff0ef          	jal	80001b64 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a10:	70a2                	ld	ra,40(sp)
    80002a12:	7402                	ld	s0,32(sp)
    80002a14:	64e2                	ld	s1,24(sp)
    80002a16:	6942                	ld	s2,16(sp)
    80002a18:	69a2                	ld	s3,8(sp)
    80002a1a:	6a02                	ld	s4,0(sp)
    80002a1c:	6145                	addi	sp,sp,48
    80002a1e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002a20:	000a061b          	sext.w	a2,s4
    80002a24:	85ce                	mv	a1,s3
    80002a26:	854a                	mv	a0,s2
    80002a28:	ad6fe0ef          	jal	80000cfe <memmove>
    return 0;
    80002a2c:	8526                	mv	a0,s1
    80002a2e:	b7cd                	j	80002a10 <either_copyin+0x2a>

0000000080002a30 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002a30:	715d                	addi	sp,sp,-80
    80002a32:	e486                	sd	ra,72(sp)
    80002a34:	e0a2                	sd	s0,64(sp)
    80002a36:	fc26                	sd	s1,56(sp)
    80002a38:	f84a                	sd	s2,48(sp)
    80002a3a:	f44e                	sd	s3,40(sp)
    80002a3c:	f052                	sd	s4,32(sp)
    80002a3e:	ec56                	sd	s5,24(sp)
    80002a40:	e85a                	sd	s6,16(sp)
    80002a42:	e45e                	sd	s7,8(sp)
    80002a44:	e062                	sd	s8,0(sp)
    80002a46:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002a48:	00006517          	auipc	a0,0x6
    80002a4c:	72850513          	addi	a0,a0,1832 # 80009170 <etext+0x170>
    80002a50:	aabfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a54:	00012497          	auipc	s1,0x12
    80002a58:	6fc48493          	addi	s1,s1,1788 # 80015150 <proc+0x158>
    80002a5c:	00102997          	auipc	s3,0x102
    80002a60:	4f498993          	addi	s3,s3,1268 # 80104f50 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a64:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    80002a66:	00007a17          	auipc	s4,0x7
    80002a6a:	89aa0a13          	addi	s4,s4,-1894 # 80009300 <etext+0x300>
    printf("%d %s %s", p->pid, state, p->name);
    80002a6e:	00007b17          	auipc	s6,0x7
    80002a72:	89ab0b13          	addi	s6,s6,-1894 # 80009308 <etext+0x308>
    printf("\n");
    80002a76:	00006a97          	auipc	s5,0x6
    80002a7a:	6faa8a93          	addi	s5,s5,1786 # 80009170 <etext+0x170>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a7e:	00007c17          	auipc	s8,0x7
    80002a82:	01ac0c13          	addi	s8,s8,26 # 80009a98 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a86:	6911                	lui	s2,0x4
    80002a88:	bf890913          	addi	s2,s2,-1032 # 3bf8 <_entry-0x7fffc408>
    80002a8c:	a821                	j	80002aa4 <procdump+0x74>
    printf("%d %s %s", p->pid, state, p->name);
    80002a8e:	ed86a583          	lw	a1,-296(a3)
    80002a92:	855a                	mv	a0,s6
    80002a94:	a67fd0ef          	jal	800004fa <printf>
    printf("\n");
    80002a98:	8556                	mv	a0,s5
    80002a9a:	a61fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a9e:	94ca                	add	s1,s1,s2
    80002aa0:	03348263          	beq	s1,s3,80002ac4 <procdump+0x94>
    if(p->state == UNUSED)
    80002aa4:	86a6                	mv	a3,s1
    80002aa6:	ec04a783          	lw	a5,-320(s1)
    80002aaa:	dbf5                	beqz	a5,80002a9e <procdump+0x6e>
      state = "???";
    80002aac:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002aae:	fefbe0e3          	bltu	s7,a5,80002a8e <procdump+0x5e>
    80002ab2:	02079713          	slli	a4,a5,0x20
    80002ab6:	01d75793          	srli	a5,a4,0x1d
    80002aba:	97e2                	add	a5,a5,s8
    80002abc:	6390                	ld	a2,0(a5)
    80002abe:	fa61                	bnez	a2,80002a8e <procdump+0x5e>
      state = "???";
    80002ac0:	8652                	mv	a2,s4
    80002ac2:	b7f1                	j	80002a8e <procdump+0x5e>
  }
}
    80002ac4:	60a6                	ld	ra,72(sp)
    80002ac6:	6406                	ld	s0,64(sp)
    80002ac8:	74e2                	ld	s1,56(sp)
    80002aca:	7942                	ld	s2,48(sp)
    80002acc:	79a2                	ld	s3,40(sp)
    80002ace:	7a02                	ld	s4,32(sp)
    80002ad0:	6ae2                	ld	s5,24(sp)
    80002ad2:	6b42                	ld	s6,16(sp)
    80002ad4:	6ba2                	ld	s7,8(sp)
    80002ad6:	6c02                	ld	s8,0(sp)
    80002ad8:	6161                	addi	sp,sp,80
    80002ada:	8082                	ret

0000000080002adc <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002adc:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002ae0:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002ae4:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002ae6:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002ae8:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002aec:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002af0:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002af4:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002af8:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002afc:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002b00:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002b04:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002b08:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002b0c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002b10:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002b14:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002b18:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002b1a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002b1c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002b20:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002b24:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002b28:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002b2c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002b30:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002b34:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002b38:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002b3c:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002b40:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002b44:	8082                	ret

0000000080002b46 <kstrcmp>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "swap.h"
// local strcmp to avoid pulling in system headers that conflict with xv6's prototypes
static int kstrcmp(const char *a, const char *b) {
    80002b46:	1141                	addi	sp,sp,-16
    80002b48:	e422                	sd	s0,8(sp)
    80002b4a:	0800                	addi	s0,sp,16
  while(*a && *b && *a == *b) { a++; b++; }
    80002b4c:	00054783          	lbu	a5,0(a0)
    80002b50:	cb99                	beqz	a5,80002b66 <kstrcmp+0x20>
    80002b52:	0005c703          	lbu	a4,0(a1)
    80002b56:	cb01                	beqz	a4,80002b66 <kstrcmp+0x20>
    80002b58:	00f71763          	bne	a4,a5,80002b66 <kstrcmp+0x20>
    80002b5c:	0505                	addi	a0,a0,1
    80002b5e:	0585                	addi	a1,a1,1
    80002b60:	00054783          	lbu	a5,0(a0)
    80002b64:	f7fd                	bnez	a5,80002b52 <kstrcmp+0xc>
  return (unsigned char)*a - (unsigned char)*b;
    80002b66:	0005c503          	lbu	a0,0(a1)
}
    80002b6a:	40a7853b          	subw	a0,a5,a0
    80002b6e:	6422                	ld	s0,8(sp)
    80002b70:	0141                	addi	sp,sp,16
    80002b72:	8082                	ret

0000000080002b74 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b74:	1141                	addi	sp,sp,-16
    80002b76:	e406                	sd	ra,8(sp)
    80002b78:	e022                	sd	s0,0(sp)
    80002b7a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b7c:	00006597          	auipc	a1,0x6
    80002b80:	7cc58593          	addi	a1,a1,1996 # 80009348 <etext+0x348>
    80002b84:	00102517          	auipc	a0,0x102
    80002b88:	27450513          	addi	a0,a0,628 # 80104df8 <tickslock>
    80002b8c:	fc3fd0ef          	jal	80000b4e <initlock>
}
    80002b90:	60a2                	ld	ra,8(sp)
    80002b92:	6402                	ld	s0,0(sp)
    80002b94:	0141                	addi	sp,sp,16
    80002b96:	8082                	ret

0000000080002b98 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b98:	1141                	addi	sp,sp,-16
    80002b9a:	e422                	sd	s0,8(sp)
    80002b9c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b9e:	00004797          	auipc	a5,0x4
    80002ba2:	8c278793          	addi	a5,a5,-1854 # 80006460 <kernelvec>
    80002ba6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002baa:	6422                	ld	s0,8(sp)
    80002bac:	0141                	addi	sp,sp,16
    80002bae:	8082                	ret

0000000080002bb0 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002bb0:	1141                	addi	sp,sp,-16
    80002bb2:	e406                	sd	ra,8(sp)
    80002bb4:	e022                	sd	s0,0(sp)
    80002bb6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bb8:	aeaff0ef          	jal	80001ea2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bc0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002bc6:	04000737          	lui	a4,0x4000
    80002bca:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002bcc:	0732                	slli	a4,a4,0xc
    80002bce:	00005797          	auipc	a5,0x5
    80002bd2:	43278793          	addi	a5,a5,1074 # 80008000 <_trampoline>
    80002bd6:	00005697          	auipc	a3,0x5
    80002bda:	42a68693          	addi	a3,a3,1066 # 80008000 <_trampoline>
    80002bde:	8f95                	sub	a5,a5,a3
    80002be0:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002be2:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002be6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002be8:	18002773          	csrr	a4,satp
    80002bec:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002bee:	6d38                	ld	a4,88(a0)
    80002bf0:	613c                	ld	a5,64(a0)
    80002bf2:	6685                	lui	a3,0x1
    80002bf4:	97b6                	add	a5,a5,a3
    80002bf6:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002bf8:	6d3c                	ld	a5,88(a0)
    80002bfa:	00000717          	auipc	a4,0x0
    80002bfe:	0f870713          	addi	a4,a4,248 # 80002cf2 <usertrap>
    80002c02:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c04:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c06:	8712                	mv	a4,tp
    80002c08:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c0a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c0e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c12:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c16:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c1a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c1c:	6f9c                	ld	a5,24(a5)
    80002c1e:	14179073          	csrw	sepc,a5
}
    80002c22:	60a2                	ld	ra,8(sp)
    80002c24:	6402                	ld	s0,0(sp)
    80002c26:	0141                	addi	sp,sp,16
    80002c28:	8082                	ret

0000000080002c2a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c2a:	1101                	addi	sp,sp,-32
    80002c2c:	ec06                	sd	ra,24(sp)
    80002c2e:	e822                	sd	s0,16(sp)
    80002c30:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002c32:	a44ff0ef          	jal	80001e76 <cpuid>
    80002c36:	cd11                	beqz	a0,80002c52 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002c38:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002c3c:	000f4737          	lui	a4,0xf4
    80002c40:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002c44:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002c46:	14d79073          	csrw	stimecmp,a5
}
    80002c4a:	60e2                	ld	ra,24(sp)
    80002c4c:	6442                	ld	s0,16(sp)
    80002c4e:	6105                	addi	sp,sp,32
    80002c50:	8082                	ret
    80002c52:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002c54:	00102497          	auipc	s1,0x102
    80002c58:	1a448493          	addi	s1,s1,420 # 80104df8 <tickslock>
    80002c5c:	8526                	mv	a0,s1
    80002c5e:	f71fd0ef          	jal	80000bce <acquire>
    ticks++;
    80002c62:	0000a517          	auipc	a0,0xa
    80002c66:	e6650513          	addi	a0,a0,-410 # 8000cac8 <ticks>
    80002c6a:	411c                	lw	a5,0(a0)
    80002c6c:	2785                	addiw	a5,a5,1
    80002c6e:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002c70:	9dbff0ef          	jal	8000264a <wakeup>
    release(&tickslock);
    80002c74:	8526                	mv	a0,s1
    80002c76:	ff1fd0ef          	jal	80000c66 <release>
    80002c7a:	64a2                	ld	s1,8(sp)
    80002c7c:	bf75                	j	80002c38 <clockintr+0xe>

0000000080002c7e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c7e:	1101                	addi	sp,sp,-32
    80002c80:	ec06                	sd	ra,24(sp)
    80002c82:	e822                	sd	s0,16(sp)
    80002c84:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c86:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002c8a:	57fd                	li	a5,-1
    80002c8c:	17fe                	slli	a5,a5,0x3f
    80002c8e:	07a5                	addi	a5,a5,9
    80002c90:	00f70c63          	beq	a4,a5,80002ca8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002c94:	57fd                	li	a5,-1
    80002c96:	17fe                	slli	a5,a5,0x3f
    80002c98:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002c9a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002c9c:	04f70763          	beq	a4,a5,80002cea <devintr+0x6c>
  }
}
    80002ca0:	60e2                	ld	ra,24(sp)
    80002ca2:	6442                	ld	s0,16(sp)
    80002ca4:	6105                	addi	sp,sp,32
    80002ca6:	8082                	ret
    80002ca8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002caa:	063030ef          	jal	8000650c <plic_claim>
    80002cae:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cb0:	47a9                	li	a5,10
    80002cb2:	00f50963          	beq	a0,a5,80002cc4 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002cb6:	4785                	li	a5,1
    80002cb8:	00f50963          	beq	a0,a5,80002cca <devintr+0x4c>
    return 1;
    80002cbc:	4505                	li	a0,1
    } else if(irq){
    80002cbe:	e889                	bnez	s1,80002cd0 <devintr+0x52>
    80002cc0:	64a2                	ld	s1,8(sp)
    80002cc2:	bff9                	j	80002ca0 <devintr+0x22>
      uartintr();
    80002cc4:	cedfd0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002cc8:	a819                	j	80002cde <devintr+0x60>
      virtio_disk_intr();
    80002cca:	509030ef          	jal	800069d2 <virtio_disk_intr>
    if(irq)
    80002cce:	a801                	j	80002cde <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002cd0:	85a6                	mv	a1,s1
    80002cd2:	00006517          	auipc	a0,0x6
    80002cd6:	67e50513          	addi	a0,a0,1662 # 80009350 <etext+0x350>
    80002cda:	821fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002cde:	8526                	mv	a0,s1
    80002ce0:	04d030ef          	jal	8000652c <plic_complete>
    return 1;
    80002ce4:	4505                	li	a0,1
    80002ce6:	64a2                	ld	s1,8(sp)
    80002ce8:	bf65                	j	80002ca0 <devintr+0x22>
    clockintr();
    80002cea:	f41ff0ef          	jal	80002c2a <clockintr>
    return 2;
    80002cee:	4509                	li	a0,2
    80002cf0:	bf45                	j	80002ca0 <devintr+0x22>

0000000080002cf2 <usertrap>:
{
    80002cf2:	7119                	addi	sp,sp,-128
    80002cf4:	fc86                	sd	ra,120(sp)
    80002cf6:	f8a2                	sd	s0,112(sp)
    80002cf8:	0100                	addi	s0,sp,128
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cfe:	1007f793          	andi	a5,a5,256
    80002d02:	10079463          	bnez	a5,80002e0a <usertrap+0x118>
    80002d06:	f4a6                	sd	s1,104(sp)
    80002d08:	f0ca                	sd	s2,96(sp)
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d0a:	00003797          	auipc	a5,0x3
    80002d0e:	75678793          	addi	a5,a5,1878 # 80006460 <kernelvec>
    80002d12:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d16:	98cff0ef          	jal	80001ea2 <myproc>
    80002d1a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d1c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d1e:	14102773          	csrr	a4,sepc
    80002d22:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d24:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d28:	47a1                	li	a5,8
    80002d2a:	10f70163          	beq	a4,a5,80002e2c <usertrap+0x13a>
  } else if((which_dev = devintr()) != 0){
    80002d2e:	f51ff0ef          	jal	80002c7e <devintr>
    80002d32:	892a                	mv	s2,a0
    80002d34:	70051263          	bnez	a0,80003438 <usertrap+0x746>
    80002d38:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15 || r_scause() == 13 || r_scause() == 12) {
    80002d3c:	47bd                	li	a5,15
    80002d3e:	00f70c63          	beq	a4,a5,80002d56 <usertrap+0x64>
    80002d42:	14202773          	csrr	a4,scause
    80002d46:	47b5                	li	a5,13
    80002d48:	00f70763          	beq	a4,a5,80002d56 <usertrap+0x64>
    80002d4c:	14202773          	csrr	a4,scause
    80002d50:	47b1                	li	a5,12
    80002d52:	6af71c63          	bne	a4,a5,8000340a <usertrap+0x718>
    80002d56:	ecce                	sd	s3,88(sp)
    80002d58:	e8d2                	sd	s4,80(sp)
    80002d5a:	e4d6                	sd	s5,72(sp)
    80002d5c:	e0da                	sd	s6,64(sp)
    80002d5e:	fc5e                	sd	s7,56(sp)
    80002d60:	f862                	sd	s8,48(sp)
    80002d62:	f466                	sd	s9,40(sp)
    80002d64:	f06a                	sd	s10,32(sp)
    80002d66:	ec6e                	sd	s11,24(sp)
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d68:	14302af3          	csrr	s5,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d6c:	14202cf3          	csrr	s9,scause
    const char *acc = (sc == 15) ? "write" : (sc == 13) ? "read" : "exec";
    80002d70:	47bd                	li	a5,15
    80002d72:	00006d97          	auipc	s11,0x6
    80002d76:	5fed8d93          	addi	s11,s11,1534 # 80009370 <etext+0x370>
    80002d7a:	00fc8963          	beq	s9,a5,80002d8c <usertrap+0x9a>
    80002d7e:	47b5                	li	a5,13
    80002d80:	00006d97          	auipc	s11,0x6
    80002d84:	4e0d8d93          	addi	s11,s11,1248 # 80009260 <etext+0x260>
    80002d88:	0efc8763          	beq	s9,a5,80002e76 <usertrap+0x184>
  uint64 stack_end = PGROUNDUP(p->stack_top); // end of the top stack page (fixed at exec)
    80002d8c:	6791                	lui	a5,0x4
    80002d8e:	97a6                	add	a5,a5,s1
    80002d90:	bb07b783          	ld	a5,-1104(a5) # 3bb0 <_entry-0x7fffc450>
    80002d94:	6b05                	lui	s6,0x1
    80002d96:	fffb0713          	addi	a4,s6,-1 # fff <_entry-0x7ffff001>
    80002d9a:	97ba                	add	a5,a5,a4
    80002d9c:	777d                	lui	a4,0xfffff
    80002d9e:	8ff9                	and	a5,a5,a4
  uint64 stack_base = stack_end - (USERSTACK * PGSIZE);
    80002da0:	41678b33          	sub	s6,a5,s6
  uint64 stack_guard = stack_end - ((USERSTACK + 1) * PGSIZE);
    80002da4:	7bf9                	lui	s7,0xffffe
    80002da6:	9bbe                	add	s7,s7,a5
  int in_guard = (va >= stack_guard && va < stack_base);
    80002da8:	8c4a                	mv	s8,s2
    80002daa:	017ae463          	bltu	s5,s7,80002db2 <usertrap+0xc0>
    80002dae:	016abc33          	sltu	s8,s5,s6
  int in_text = under_brk && (va >= p->text_start && va < p->text_end);
    80002db2:	64b8                	ld	a4,72(s1)
    80002db4:	0ceaf663          	bgeu	s5,a4,80002e80 <usertrap+0x18e>
    80002db8:	6711                	lui	a4,0x4
    80002dba:	9726                	add	a4,a4,s1
    80002dbc:	b8873703          	ld	a4,-1144(a4) # 3b88 <_entry-0x7fffc478>
    80002dc0:	834a                	mv	t1,s2
    80002dc2:	00eae863          	bltu	s5,a4,80002dd2 <usertrap+0xe0>
    80002dc6:	6711                	lui	a4,0x4
    80002dc8:	9726                	add	a4,a4,s1
    80002dca:	b9073303          	ld	t1,-1136(a4) # 3b90 <_entry-0x7fffc470>
    80002dce:	006ab333          	sltu	t1,s5,t1
  int in_data = under_brk && (va >= p->data_start && va < p->data_end);
    80002dd2:	6711                	lui	a4,0x4
    80002dd4:	9726                	add	a4,a4,s1
    80002dd6:	b9873703          	ld	a4,-1128(a4) # 3b98 <_entry-0x7fffc468>
    80002dda:	88ca                	mv	a7,s2
    80002ddc:	00eae863          	bltu	s5,a4,80002dec <usertrap+0xfa>
    80002de0:	6711                	lui	a4,0x4
    80002de2:	9726                	add	a4,a4,s1
    80002de4:	ba073883          	ld	a7,-1120(a4) # 3ba0 <_entry-0x7fffc460>
    80002de8:	011ab8b3          	sltu	a7,s5,a7
  int in_stack = under_brk && (va >= stack_base && va < stack_end);
    80002dec:	00fab533          	sltu	a0,s5,a5
    80002df0:	016af363          	bgeu	s5,s6,80002df6 <usertrap+0x104>
    80002df4:	854a                	mv	a0,s2
  int in_heap = under_brk && !in_text && !in_data && !in_stack && !in_guard;
    80002df6:	006c6833          	or	a6,s8,t1
    80002dfa:	0108e833          	or	a6,a7,a6
    80002dfe:	01056833          	or	a6,a0,a6
    80002e02:	00184813          	xori	a6,a6,1
    80002e06:	2801                	sext.w	a6,a6
    80002e08:	a041                	j	80002e88 <usertrap+0x196>
    80002e0a:	f4a6                	sd	s1,104(sp)
    80002e0c:	f0ca                	sd	s2,96(sp)
    80002e0e:	ecce                	sd	s3,88(sp)
    80002e10:	e8d2                	sd	s4,80(sp)
    80002e12:	e4d6                	sd	s5,72(sp)
    80002e14:	e0da                	sd	s6,64(sp)
    80002e16:	fc5e                	sd	s7,56(sp)
    80002e18:	f862                	sd	s8,48(sp)
    80002e1a:	f466                	sd	s9,40(sp)
    80002e1c:	f06a                	sd	s10,32(sp)
    80002e1e:	ec6e                	sd	s11,24(sp)
    panic("usertrap: not from user mode");
    80002e20:	00006517          	auipc	a0,0x6
    80002e24:	58050513          	addi	a0,a0,1408 # 800093a0 <etext+0x3a0>
    80002e28:	9b9fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002e2c:	a4bff0ef          	jal	80002876 <killed>
    80002e30:	ed1d                	bnez	a0,80002e6e <usertrap+0x17c>
    p->trapframe->epc += 4;
    80002e32:	6cb8                	ld	a4,88(s1)
    80002e34:	6f1c                	ld	a5,24(a4)
    80002e36:	0791                	addi	a5,a5,4
    80002e38:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e42:	10079073          	csrw	sstatus,a5
    syscall();
    80002e46:	1a5000ef          	jal	800037ea <syscall>
  if(killed(p))
    80002e4a:	8526                	mv	a0,s1
    80002e4c:	a2bff0ef          	jal	80002876 <killed>
    80002e50:	5e051963          	bnez	a0,80003442 <usertrap+0x750>
  prepare_return();
    80002e54:	d5dff0ef          	jal	80002bb0 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e58:	68a8                	ld	a0,80(s1)
    80002e5a:	8131                	srli	a0,a0,0xc
    80002e5c:	57fd                	li	a5,-1
    80002e5e:	17fe                	slli	a5,a5,0x3f
    80002e60:	8d5d                	or	a0,a0,a5
}
    80002e62:	74a6                	ld	s1,104(sp)
    80002e64:	7906                	ld	s2,96(sp)
    80002e66:	70e6                	ld	ra,120(sp)
    80002e68:	7446                	ld	s0,112(sp)
    80002e6a:	6109                	addi	sp,sp,128
    80002e6c:	8082                	ret
      kexit(-1);
    80002e6e:	557d                	li	a0,-1
    80002e70:	8abff0ef          	jal	8000271a <kexit>
    80002e74:	bf7d                	j	80002e32 <usertrap+0x140>
    const char *acc = (sc == 15) ? "write" : (sc == 13) ? "read" : "exec";
    80002e76:	00007d97          	auipc	s11,0x7
    80002e7a:	932d8d93          	addi	s11,s11,-1742 # 800097a8 <etext+0x7a8>
    80002e7e:	b739                	j	80002d8c <usertrap+0x9a>
  int in_stack = under_brk && (va >= stack_base && va < stack_end);
    80002e80:	854a                	mv	a0,s2
  int in_data = under_brk && (va >= p->data_start && va < p->data_end);
    80002e82:	88ca                	mv	a7,s2
  int in_text = under_brk && (va >= p->text_start && va < p->text_end);
    80002e84:	834a                	mv	t1,s2
  int in_heap = under_brk && !in_text && !in_data && !in_stack && !in_guard;
    80002e86:	884a                	mv	a6,s2
    uint64 va0 = PGROUNDDOWN(va);
    80002e88:	7a7d                	lui	s4,0xfffff
    80002e8a:	014afa33          	and	s4,s5,s4
    for(int i=0;i<MAX_PAGES_INFO;i++){
    80002e8e:	698d                	lui	s3,0x3
    80002e90:	18898993          	addi	s3,s3,392 # 3188 <_entry-0x7fffce78>
    80002e94:	99a6                	add	s3,s3,s1
    80002e96:	6691                	lui	a3,0x4
    80002e98:	b8868693          	addi	a3,a3,-1144 # 3b88 <_entry-0x7fffc478>
    80002e9c:	96a6                	add	a3,a3,s1
    uint64 va0 = PGROUNDDOWN(va);
    80002e9e:	87ce                	mv	a5,s3
      if(p->memstat.pages[i].state == SWAPPED && p->memstat.pages[i].va == (uint)va0){
    80002ea0:	4609                	li	a2,2
    80002ea2:	000a059b          	sext.w	a1,s4
    80002ea6:	a021                	j	80002eae <usertrap+0x1bc>
    for(int i=0;i<MAX_PAGES_INFO;i++){
    80002ea8:	07d1                	addi	a5,a5,20
    80002eaa:	6ed78b63          	beq	a5,a3,800035a0 <usertrap+0x8ae>
      if(p->memstat.pages[i].state == SWAPPED && p->memstat.pages[i].va == (uint)va0){
    80002eae:	43d8                	lw	a4,4(a5)
    80002eb0:	fec71ce3          	bne	a4,a2,80002ea8 <usertrap+0x1b6>
    80002eb4:	4398                	lw	a4,0(a5)
    80002eb6:	feb719e3          	bne	a4,a1,80002ea8 <usertrap+0x1b6>
    if(in_guard){
    80002eba:	5c0c1863          	bnez	s8,8000348a <usertrap+0x798>
    80002ebe:	4c05                	li	s8,1
      cause = "swap"; valid = 1;
    80002ec0:	00006797          	auipc	a5,0x6
    80002ec4:	4d878793          	addi	a5,a5,1240 # 80009398 <etext+0x398>
    80002ec8:	f8f43423          	sd	a5,-120(s0)
    p->pagefault_count++;
    80002ecc:	6791                	lui	a5,0x4
    80002ece:	97a6                	add	a5,a5,s1
    80002ed0:	be07a703          	lw	a4,-1056(a5) # 3be0 <_entry-0x7fffc420>
    80002ed4:	2705                	addiw	a4,a4,1
    80002ed6:	bee7a023          	sw	a4,-1056(a5)
    if(p->vmtrace)
    80002eda:	bf47a783          	lw	a5,-1036(a5)
    80002ede:	58079863          	bnez	a5,8000346e <usertrap+0x77c>
      pte_t *pte = walk(p->pagetable, va0, 0);
    80002ee2:	4601                	li	a2,0
    80002ee4:	85d2                	mv	a1,s4
    80002ee6:	68a8                	ld	a0,80(s1)
    80002ee8:	8fefe0ef          	jal	80000fe6 <walk>
      int mapped = (pte && (*pte & PTE_V));
    80002eec:	8d4a                	mv	s10,s2
    80002eee:	c509                	beqz	a0,80002ef8 <usertrap+0x206>
    80002ef0:	00053d03          	ld	s10,0(a0)
    80002ef4:	001d7d13          	andi	s10,s10,1
      if(kstrcmp(cause, "heap") == 0 || kstrcmp(cause, "stack") == 0 || kstrcmp(cause, "swap") == 0) {
    80002ef8:	00006597          	auipc	a1,0x6
    80002efc:	49058593          	addi	a1,a1,1168 # 80009388 <etext+0x388>
    80002f00:	f8843503          	ld	a0,-120(s0)
    80002f04:	c43ff0ef          	jal	80002b46 <kstrcmp>
    80002f08:	e949                	bnez	a0,80002f9a <usertrap+0x2a8>
        if(is_exec_access){
    80002f0a:	47b1                	li	a5,12
    80002f0c:	0cfc8e63          	beq	s9,a5,80002fe8 <usertrap+0x2f6>
        } else if(!mapped) {
    80002f10:	1e0d1663          	bnez	s10,800030fc <usertrap+0x40a>
          if(va0 >= guard_lo && va0 < stack_lo){
    80002f14:	017a6463          	bltu	s4,s7,80002f1c <usertrap+0x22a>
    80002f18:	0f6a6e63          	bltu	s4,s6,80003014 <usertrap+0x322>
          char *mem = try_kalloc_or_replace(va0);
    80002f1c:	8552                	mv	a0,s4
    80002f1e:	f24fe0ef          	jal	80001642 <try_kalloc_or_replace>
    80002f22:	892a                	mv	s2,a0
          if(mem == 0){
    80002f24:	10050d63          	beqz	a0,8000303e <usertrap+0x34c>
            if(swapped){
    80002f28:	140c0863          	beqz	s8,80003078 <usertrap+0x386>
              if(swapin_page(p, va0, mem) < 0){
    80002f2c:	862a                	mv	a2,a0
    80002f2e:	85d2                	mv	a1,s4
    80002f30:	8526                	mv	a0,s1
    80002f32:	771030ef          	jal	80006ea2 <swapin_page>
    80002f36:	12054163          	bltz	a0,80003058 <usertrap+0x366>
            if(mappages(p->pagetable, va0, PGSIZE, (uint64)mem, PTE_U|PTE_R|PTE_W) < 0){
    80002f3a:	4759                	li	a4,22
    80002f3c:	86ca                	mv	a3,s2
    80002f3e:	6605                	lui	a2,0x1
    80002f40:	85d2                	mv	a1,s4
    80002f42:	68a8                	ld	a0,80(s1)
    80002f44:	97afe0ef          	jal	800010be <mappages>
    80002f48:	16054463          	bltz	a0,800030b0 <usertrap+0x3be>
              int seq = p->memstat.next_fifo_seq++;
    80002f4c:	678d                	lui	a5,0x3
    80002f4e:	97a6                	add	a5,a5,s1
    80002f50:	1847a903          	lw	s2,388(a5) # 3184 <_entry-0x7fffce7c>
    80002f54:	0019071b          	addiw	a4,s2,1
    80002f58:	18e7a223          	sw	a4,388(a5)
              if(p->vmtrace) printf("[pid %d] RESIDENT va=%p seq=%d\n", p->pid, (void*)va0, seq);
    80002f5c:	6791                	lui	a5,0x4
    80002f5e:	97a6                	add	a5,a5,s1
    80002f60:	bf47a783          	lw	a5,-1036(a5) # 3bf4 <_entry-0x7fffc40c>
    80002f64:	16079663          	bnez	a5,800030d0 <usertrap+0x3de>
              memstat_mark_resident(p, va0, seq);
    80002f68:	864a                	mv	a2,s2
    80002f6a:	85d2                	mv	a1,s4
    80002f6c:	8526                	mv	a0,s1
    80002f6e:	e0afe0ef          	jal	80001578 <memstat_mark_resident>
              if(sc == 15){
    80002f72:	47bd                	li	a5,15
    80002f74:	16fc8863          	beq	s9,a5,800030e4 <usertrap+0x3f2>
              p->resident_pages++;
    80002f78:	6791                	lui	a5,0x4
    80002f7a:	97a6                	add	a5,a5,s1
    80002f7c:	be47a703          	lw	a4,-1052(a5) # 3be4 <_entry-0x7fffc41c>
    80002f80:	2705                	addiw	a4,a4,1
    80002f82:	bee7a223          	sw	a4,-1052(a5)
    80002f86:	69e6                	ld	s3,88(sp)
    80002f88:	6a46                	ld	s4,80(sp)
    80002f8a:	6aa6                	ld	s5,72(sp)
    80002f8c:	6b06                	ld	s6,64(sp)
    80002f8e:	7be2                	ld	s7,56(sp)
    80002f90:	7c42                	ld	s8,48(sp)
    80002f92:	7ca2                	ld	s9,40(sp)
    80002f94:	7d02                	ld	s10,32(sp)
    80002f96:	6de2                	ld	s11,24(sp)
    80002f98:	bd4d                	j	80002e4a <usertrap+0x158>
      if(kstrcmp(cause, "heap") == 0 || kstrcmp(cause, "stack") == 0 || kstrcmp(cause, "swap") == 0) {
    80002f9a:	00006597          	auipc	a1,0x6
    80002f9e:	3f658593          	addi	a1,a1,1014 # 80009390 <etext+0x390>
    80002fa2:	f8843503          	ld	a0,-120(s0)
    80002fa6:	ba1ff0ef          	jal	80002b46 <kstrcmp>
    80002faa:	d125                	beqz	a0,80002f0a <usertrap+0x218>
    80002fac:	00006597          	auipc	a1,0x6
    80002fb0:	3ec58593          	addi	a1,a1,1004 # 80009398 <etext+0x398>
    80002fb4:	f8843503          	ld	a0,-120(s0)
    80002fb8:	b8fff0ef          	jal	80002b46 <kstrcmp>
    80002fbc:	d539                	beqz	a0,80002f0a <usertrap+0x218>
      } else if(kstrcmp(cause, "exec") == 0) {
    80002fbe:	00006597          	auipc	a1,0x6
    80002fc2:	2a258593          	addi	a1,a1,674 # 80009260 <etext+0x260>
    80002fc6:	f8843503          	ld	a0,-120(s0)
    80002fca:	b7dff0ef          	jal	80002b46 <kstrcmp>
    80002fce:	8b2a                	mv	s6,a0
    80002fd0:	18050963          	beqz	a0,80003162 <usertrap+0x470>
    80002fd4:	69e6                	ld	s3,88(sp)
    80002fd6:	6a46                	ld	s4,80(sp)
    80002fd8:	6aa6                	ld	s5,72(sp)
    80002fda:	6b06                	ld	s6,64(sp)
    80002fdc:	7be2                	ld	s7,56(sp)
    80002fde:	7c42                	ld	s8,48(sp)
    80002fe0:	7ca2                	ld	s9,40(sp)
    80002fe2:	7d02                	ld	s10,32(sp)
    80002fe4:	6de2                	ld	s11,24(sp)
    80002fe6:	b595                	j	80002e4a <usertrap+0x158>
          printf("[pid %d] KILL invalid-access va=%p access=%s\n", p->pid, (void*)va, acc);
    80002fe8:	86ee                	mv	a3,s11
    80002fea:	8656                	mv	a2,s5
    80002fec:	588c                	lw	a1,48(s1)
    80002fee:	00006517          	auipc	a0,0x6
    80002ff2:	40250513          	addi	a0,a0,1026 # 800093f0 <etext+0x3f0>
    80002ff6:	d04fd0ef          	jal	800004fa <printf>
          setkilled(p);
    80002ffa:	8526                	mv	a0,s1
    80002ffc:	857ff0ef          	jal	80002852 <setkilled>
    80003000:	69e6                	ld	s3,88(sp)
    80003002:	6a46                	ld	s4,80(sp)
    80003004:	6aa6                	ld	s5,72(sp)
    80003006:	6b06                	ld	s6,64(sp)
    80003008:	7be2                	ld	s7,56(sp)
    8000300a:	7c42                	ld	s8,48(sp)
    8000300c:	7ca2                	ld	s9,40(sp)
    8000300e:	7d02                	ld	s10,32(sp)
    80003010:	6de2                	ld	s11,24(sp)
    80003012:	bd25                	j	80002e4a <usertrap+0x158>
            printf("[pid %d] KILL guard-page-access va=%p\n", p->pid, (void*)va0);
    80003014:	8652                	mv	a2,s4
    80003016:	588c                	lw	a1,48(s1)
    80003018:	00006517          	auipc	a0,0x6
    8000301c:	40850513          	addi	a0,a0,1032 # 80009420 <etext+0x420>
    80003020:	cdafd0ef          	jal	800004fa <printf>
            setkilled(p);
    80003024:	8526                	mv	a0,s1
    80003026:	82dff0ef          	jal	80002852 <setkilled>
            goto pf_done;
    8000302a:	69e6                	ld	s3,88(sp)
    8000302c:	6a46                	ld	s4,80(sp)
    8000302e:	6aa6                	ld	s5,72(sp)
    80003030:	6b06                	ld	s6,64(sp)
    80003032:	7be2                	ld	s7,56(sp)
    80003034:	7c42                	ld	s8,48(sp)
    80003036:	7ca2                	ld	s9,40(sp)
    80003038:	7d02                	ld	s10,32(sp)
    8000303a:	6de2                	ld	s11,24(sp)
    8000303c:	b539                	j	80002e4a <usertrap+0x158>
            setkilled(p);
    8000303e:	8526                	mv	a0,s1
    80003040:	813ff0ef          	jal	80002852 <setkilled>
    80003044:	69e6                	ld	s3,88(sp)
    80003046:	6a46                	ld	s4,80(sp)
    80003048:	6aa6                	ld	s5,72(sp)
    8000304a:	6b06                	ld	s6,64(sp)
    8000304c:	7be2                	ld	s7,56(sp)
    8000304e:	7c42                	ld	s8,48(sp)
    80003050:	7ca2                	ld	s9,40(sp)
    80003052:	7d02                	ld	s10,32(sp)
    80003054:	6de2                	ld	s11,24(sp)
    80003056:	bbd5                	j	80002e4a <usertrap+0x158>
                kfree(mem);
    80003058:	854a                	mv	a0,s2
    8000305a:	9c3fd0ef          	jal	80000a1c <kfree>
                setkilled(p);
    8000305e:	8526                	mv	a0,s1
    80003060:	ff2ff0ef          	jal	80002852 <setkilled>
                goto pf_done;
    80003064:	69e6                	ld	s3,88(sp)
    80003066:	6a46                	ld	s4,80(sp)
    80003068:	6aa6                	ld	s5,72(sp)
    8000306a:	6b06                	ld	s6,64(sp)
    8000306c:	7be2                	ld	s7,56(sp)
    8000306e:	7c42                	ld	s8,48(sp)
    80003070:	7ca2                	ld	s9,40(sp)
    80003072:	7d02                	ld	s10,32(sp)
    80003074:	6de2                	ld	s11,24(sp)
    80003076:	bbd1                	j	80002e4a <usertrap+0x158>
              memset(mem, 0, PGSIZE);
    80003078:	6605                	lui	a2,0x1
    8000307a:	4581                	li	a1,0
    8000307c:	c27fd0ef          	jal	80000ca2 <memset>
            if(mappages(p->pagetable, va0, PGSIZE, (uint64)mem, PTE_U|PTE_R|PTE_W) < 0){
    80003080:	4759                	li	a4,22
    80003082:	86ca                	mv	a3,s2
    80003084:	6605                	lui	a2,0x1
    80003086:	85d2                	mv	a1,s4
    80003088:	68a8                	ld	a0,80(s1)
    8000308a:	834fe0ef          	jal	800010be <mappages>
    8000308e:	02054163          	bltz	a0,800030b0 <usertrap+0x3be>
              if(!swapped && p->vmtrace) printf("[pid %d] ALLOC va=%p\n", p->pid, (void*)va0);
    80003092:	6791                	lui	a5,0x4
    80003094:	97a6                	add	a5,a5,s1
    80003096:	bf47a783          	lw	a5,-1036(a5) # 3bf4 <_entry-0x7fffc40c>
    8000309a:	ea0789e3          	beqz	a5,80002f4c <usertrap+0x25a>
    8000309e:	8652                	mv	a2,s4
    800030a0:	588c                	lw	a1,48(s1)
    800030a2:	00006517          	auipc	a0,0x6
    800030a6:	3a650513          	addi	a0,a0,934 # 80009448 <etext+0x448>
    800030aa:	c50fd0ef          	jal	800004fa <printf>
    800030ae:	bd79                	j	80002f4c <usertrap+0x25a>
              kfree(mem);
    800030b0:	854a                	mv	a0,s2
    800030b2:	96bfd0ef          	jal	80000a1c <kfree>
              setkilled(p);
    800030b6:	8526                	mv	a0,s1
    800030b8:	f9aff0ef          	jal	80002852 <setkilled>
    800030bc:	69e6                	ld	s3,88(sp)
    800030be:	6a46                	ld	s4,80(sp)
    800030c0:	6aa6                	ld	s5,72(sp)
    800030c2:	6b06                	ld	s6,64(sp)
    800030c4:	7be2                	ld	s7,56(sp)
    800030c6:	7c42                	ld	s8,48(sp)
    800030c8:	7ca2                	ld	s9,40(sp)
    800030ca:	7d02                	ld	s10,32(sp)
    800030cc:	6de2                	ld	s11,24(sp)
    800030ce:	bbb5                	j	80002e4a <usertrap+0x158>
              if(p->vmtrace) printf("[pid %d] RESIDENT va=%p seq=%d\n", p->pid, (void*)va0, seq);
    800030d0:	86ca                	mv	a3,s2
    800030d2:	8652                	mv	a2,s4
    800030d4:	588c                	lw	a1,48(s1)
    800030d6:	00006517          	auipc	a0,0x6
    800030da:	38a50513          	addi	a0,a0,906 # 80009460 <etext+0x460>
    800030de:	c1cfd0ef          	jal	800004fa <printf>
    800030e2:	b559                	j	80002f68 <usertrap+0x276>
                  if(p->memstat.pages[idx].va == (uint)va0) break;
    800030e4:	2a01                	sext.w	s4,s4
                for(idx=0; idx<MAX_PAGES_INFO; idx++){
    800030e6:	08000713          	li	a4,128
                  if(p->memstat.pages[idx].va == (uint)va0) break;
    800030ea:	0009a783          	lw	a5,0(s3)
    800030ee:	41478b63          	beq	a5,s4,80003504 <usertrap+0x812>
                for(idx=0; idx<MAX_PAGES_INFO; idx++){
    800030f2:	2d05                	addiw	s10,s10,1 # 1001 <_entry-0x7fffefff>
    800030f4:	09d1                	addi	s3,s3,20
    800030f6:	feed1ae3          	bne	s10,a4,800030ea <usertrap+0x3f8>
    800030fa:	bdbd                	j	80002f78 <usertrap+0x286>
        } else if(is_exec_access == 0 && mapped && sc == 15) {
    800030fc:	47bd                	li	a5,15
    800030fe:	00fc8c63          	beq	s9,a5,80003116 <usertrap+0x424>
    80003102:	69e6                	ld	s3,88(sp)
    80003104:	6a46                	ld	s4,80(sp)
    80003106:	6aa6                	ld	s5,72(sp)
    80003108:	6b06                	ld	s6,64(sp)
    8000310a:	7be2                	ld	s7,56(sp)
    8000310c:	7c42                	ld	s8,48(sp)
    8000310e:	7ca2                	ld	s9,40(sp)
    80003110:	7d02                	ld	s10,32(sp)
    80003112:	6de2                	ld	s11,24(sp)
    80003114:	bb1d                	j	80002e4a <usertrap+0x158>
          for(int i=0;i<MAX_PAGES_INFO;i++){
    80003116:	87ca                	mv	a5,s2
            if(p->memstat.pages[i].va == (uint)va0 && p->memstat.pages[i].state == RESIDENT){
    80003118:	2a01                	sext.w	s4,s4
    8000311a:	4605                	li	a2,1
          for(int i=0;i<MAX_PAGES_INFO;i++){
    8000311c:	08000693          	li	a3,128
    80003120:	a029                	j	8000312a <usertrap+0x438>
    80003122:	2785                	addiw	a5,a5,1
    80003124:	09d1                	addi	s3,s3,20
    80003126:	12d78363          	beq	a5,a3,8000324c <usertrap+0x55a>
            if(p->memstat.pages[i].va == (uint)va0 && p->memstat.pages[i].state == RESIDENT){
    8000312a:	0009a703          	lw	a4,0(s3)
    8000312e:	ff471ae3          	bne	a4,s4,80003122 <usertrap+0x430>
    80003132:	0049a703          	lw	a4,4(s3)
    80003136:	fec716e3          	bne	a4,a2,80003122 <usertrap+0x430>
              p->memstat.pages[i].is_dirty = 1;
    8000313a:	00279713          	slli	a4,a5,0x2
    8000313e:	97ba                	add	a5,a5,a4
    80003140:	078a                	slli	a5,a5,0x2
    80003142:	97a6                	add	a5,a5,s1
    80003144:	670d                	lui	a4,0x3
    80003146:	97ba                	add	a5,a5,a4
    80003148:	4705                	li	a4,1
    8000314a:	18e7a823          	sw	a4,400(a5)
              break;
    8000314e:	69e6                	ld	s3,88(sp)
    80003150:	6a46                	ld	s4,80(sp)
    80003152:	6aa6                	ld	s5,72(sp)
    80003154:	6b06                	ld	s6,64(sp)
    80003156:	7be2                	ld	s7,56(sp)
    80003158:	7c42                	ld	s8,48(sp)
    8000315a:	7ca2                	ld	s9,40(sp)
    8000315c:	7d02                	ld	s10,32(sp)
    8000315e:	6de2                	ld	s11,24(sp)
    80003160:	b1ed                	j	80002e4a <usertrap+0x158>
        uint64 pa = walkaddr(p->pagetable, va0);
    80003162:	85d2                	mv	a1,s4
    80003164:	68a8                	ld	a0,80(s1)
    80003166:	f1bfd0ef          	jal	80001080 <walkaddr>
    8000316a:	87aa                	mv	a5,a0
        if(sc == 15){
    8000316c:	473d                	li	a4,15
    8000316e:	08ec8363          	beq	s9,a4,800031f4 <usertrap+0x502>
        if(pa == 0){
    80003172:	40050263          	beqz	a0,80003576 <usertrap+0x884>
          mem = (char*)pa;
    80003176:	893e                	mv	s2,a5
        int newly_alloc = 0;
    80003178:	865a                	mv	a2,s6
        int is_text = (va0 >= p->text_start && va0 < p->text_end);
    8000317a:	6791                	lui	a5,0x4
    8000317c:	97a6                	add	a5,a5,s1
    8000317e:	b887b703          	ld	a4,-1144(a5) # 3b88 <_entry-0x7fffc478>
    80003182:	00ea6863          	bltu	s4,a4,80003192 <usertrap+0x4a0>
    80003186:	6791                	lui	a5,0x4
    80003188:	97a6                	add	a5,a5,s1
    8000318a:	b907b783          	ld	a5,-1136(a5) # 3b90 <_entry-0x7fffc470>
    8000318e:	12fa6c63          	bltu	s4,a5,800032c6 <usertrap+0x5d4>
          off = p->data_off + (va0 - p->data_start);
    80003192:	000a059b          	sext.w	a1,s4
    80003196:	6691                	lui	a3,0x4
    80003198:	96a6                	add	a3,a3,s1
    8000319a:	b986b703          	ld	a4,-1128(a3) # 3b98 <_entry-0x7fffc468>
    8000319e:	0007079b          	sext.w	a5,a4
    800031a2:	bd06a983          	lw	s3,-1072(a3)
    800031a6:	40e989bb          	subw	s3,s3,a4
    800031aa:	014989bb          	addw	s3,s3,s4
          filesz = (p->data_filesz > (va0 - p->data_start)) ? (p->data_filesz - (va0 - p->data_start)) : 0;
    800031ae:	bd46a683          	lw	a3,-1068(a3)
    800031b2:	02069513          	slli	a0,a3,0x20
    800031b6:	9101                	srli	a0,a0,0x20
    800031b8:	40ea0733          	sub	a4,s4,a4
    800031bc:	4a81                	li	s5,0
    800031be:	00a77a63          	bgeu	a4,a0,800031d2 <usertrap+0x4e0>
    800031c2:	9fb5                	addw	a5,a5,a3
    800031c4:	9f8d                	subw	a5,a5,a1
        if(filesz > PGSIZE) filesz = PGSIZE;
    800031c6:	8abe                	mv	s5,a5
    800031c8:	6705                	lui	a4,0x1
    800031ca:	00f77363          	bgeu	a4,a5,800031d0 <usertrap+0x4de>
    800031ce:	6a85                	lui	s5,0x1
    800031d0:	2a81                	sext.w	s5,s5
        if(newly_alloc){
    800031d2:	12061663          	bnez	a2,800032fe <usertrap+0x60c>
        int perm = PTE_U | PTE_R | (is_text ? PTE_X : 0);
    800031d6:	340b1263          	bnez	s6,8000351a <usertrap+0x828>
          pte = walk(p->pagetable, va0, 0);
    800031da:	4601                	li	a2,0
    800031dc:	85d2                	mv	a1,s4
    800031de:	68a8                	ld	a0,80(s1)
    800031e0:	e07fd0ef          	jal	80000fe6 <walk>
    800031e4:	87aa                	mv	a5,a0
          if(pte){
    800031e6:	36050c63          	beqz	a0,8000355e <usertrap+0x86c>
              *pte &= ~PTE_X;
    800031ea:	6398                	ld	a4,0(a5)
    800031ec:	9b4d                	andi	a4,a4,-13
    800031ee:	01276713          	ori	a4,a4,18
    800031f2:	ae3d                	j	80003530 <usertrap+0x83e>
          int is_text_here = (va0 >= p->text_start && va0 < p->text_end);
    800031f4:	6711                	lui	a4,0x4
    800031f6:	9726                	add	a4,a4,s1
    800031f8:	b8873703          	ld	a4,-1144(a4) # 3b88 <_entry-0x7fffc478>
    800031fc:	36ea6b63          	bltu	s4,a4,80003572 <usertrap+0x880>
    80003200:	6711                	lui	a4,0x4
    80003202:	9726                	add	a4,a4,s1
    80003204:	b9073703          	ld	a4,-1136(a4) # 3b90 <_entry-0x7fffc470>
    80003208:	06ea6163          	bltu	s4,a4,8000326a <usertrap+0x578>
        if(pa == 0){
    8000320c:	36050563          	beqz	a0,80003576 <usertrap+0x884>
            int is_text = (va0 >= p->text_start && va0 < p->text_end);
    80003210:	6711                	lui	a4,0x4
    80003212:	9726                	add	a4,a4,s1
    80003214:	b9073703          	ld	a4,-1136(a4) # 3b90 <_entry-0x7fffc470>
    80003218:	f4ea6fe3          	bltu	s4,a4,80003176 <usertrap+0x484>
              pte = walk(p->pagetable, va0, 0);
    8000321c:	4601                	li	a2,0
    8000321e:	85d2                	mv	a1,s4
    80003220:	68a8                	ld	a0,80(s1)
    80003222:	dc5fd0ef          	jal	80000fe6 <walk>
              if(pte){
    80003226:	22050863          	beqz	a0,80003456 <usertrap+0x764>
                *pte |= PTE_W; // grant write
    8000322a:	6118                	ld	a4,0(a0)
    8000322c:	00476713          	ori	a4,a4,4
    80003230:	e118                	sd	a4,0(a0)
  asm volatile("sfence.vma zero, zero");
    80003232:	12000073          	sfence.vma
                  if(p->memstat.pages[i].va == (uint)va0){
    80003236:	2a01                	sext.w	s4,s4
                for(int i=0;i<MAX_PAGES_INFO;i++){
    80003238:	08000793          	li	a5,128
                  if(p->memstat.pages[i].va == (uint)va0){
    8000323c:	0009a703          	lw	a4,0(s3)
    80003240:	07470063          	beq	a4,s4,800032a0 <usertrap+0x5ae>
                for(int i=0;i<MAX_PAGES_INFO;i++){
    80003244:	2b05                	addiw	s6,s6,1
    80003246:	09d1                	addi	s3,s3,20
    80003248:	fefb1ae3          	bne	s6,a5,8000323c <usertrap+0x54a>
  if(killed(p))
    8000324c:	8526                	mv	a0,s1
    8000324e:	e28ff0ef          	jal	80002876 <killed>
    80003252:	28051f63          	bnez	a0,800034f0 <usertrap+0x7fe>
    80003256:	69e6                	ld	s3,88(sp)
    80003258:	6a46                	ld	s4,80(sp)
    8000325a:	6aa6                	ld	s5,72(sp)
    8000325c:	6b06                	ld	s6,64(sp)
    8000325e:	7be2                	ld	s7,56(sp)
    80003260:	7c42                	ld	s8,48(sp)
    80003262:	7ca2                	ld	s9,40(sp)
    80003264:	7d02                	ld	s10,32(sp)
    80003266:	6de2                	ld	s11,24(sp)
    80003268:	b6f5                	j	80002e54 <usertrap+0x162>
            if(p->vmtrace) printf("[pid %d] KILL write-to-text va=%p\n", p->pid, (void*)va);
    8000326a:	6791                	lui	a5,0x4
    8000326c:	97a6                	add	a5,a5,s1
    8000326e:	bf47a783          	lw	a5,-1036(a5) # 3bf4 <_entry-0x7fffc40c>
    80003272:	ef91                	bnez	a5,8000328e <usertrap+0x59c>
            setkilled(p);
    80003274:	8526                	mv	a0,s1
    80003276:	ddcff0ef          	jal	80002852 <setkilled>
            goto pf_done;
    8000327a:	69e6                	ld	s3,88(sp)
    8000327c:	6a46                	ld	s4,80(sp)
    8000327e:	6aa6                	ld	s5,72(sp)
    80003280:	6b06                	ld	s6,64(sp)
    80003282:	7be2                	ld	s7,56(sp)
    80003284:	7c42                	ld	s8,48(sp)
    80003286:	7ca2                	ld	s9,40(sp)
    80003288:	7d02                	ld	s10,32(sp)
    8000328a:	6de2                	ld	s11,24(sp)
    8000328c:	be7d                	j	80002e4a <usertrap+0x158>
            if(p->vmtrace) printf("[pid %d] KILL write-to-text va=%p\n", p->pid, (void*)va);
    8000328e:	8656                	mv	a2,s5
    80003290:	588c                	lw	a1,48(s1)
    80003292:	00006517          	auipc	a0,0x6
    80003296:	1ee50513          	addi	a0,a0,494 # 80009480 <etext+0x480>
    8000329a:	a60fd0ef          	jal	800004fa <printf>
    8000329e:	bfd9                	j	80003274 <usertrap+0x582>
                    p->memstat.pages[i].is_dirty = 1;
    800032a0:	47d1                	li	a5,20
    800032a2:	02fb07b3          	mul	a5,s6,a5
    800032a6:	97a6                	add	a5,a5,s1
    800032a8:	670d                	lui	a4,0x3
    800032aa:	97ba                	add	a5,a5,a4
    800032ac:	4705                	li	a4,1
    800032ae:	18e7a823          	sw	a4,400(a5)
                    break;
    800032b2:	69e6                	ld	s3,88(sp)
    800032b4:	6a46                	ld	s4,80(sp)
    800032b6:	6aa6                	ld	s5,72(sp)
    800032b8:	6b06                	ld	s6,64(sp)
    800032ba:	7be2                	ld	s7,56(sp)
    800032bc:	7c42                	ld	s8,48(sp)
    800032be:	7ca2                	ld	s9,40(sp)
    800032c0:	7d02                	ld	s10,32(sp)
    800032c2:	6de2                	ld	s11,24(sp)
    800032c4:	b659                	j	80002e4a <usertrap+0x158>
          off = p->text_off + (va0 - p->text_start);
    800032c6:	000a059b          	sext.w	a1,s4
    800032ca:	0007079b          	sext.w	a5,a4
    800032ce:	6691                	lui	a3,0x4
    800032d0:	96a6                	add	a3,a3,s1
    800032d2:	bc06a983          	lw	s3,-1088(a3) # 3bc0 <_entry-0x7fffc440>
    800032d6:	40e989bb          	subw	s3,s3,a4
    800032da:	014989bb          	addw	s3,s3,s4
          filesz = (p->text_filesz > (va0 - p->text_start)) ? (p->text_filesz - (va0 - p->text_start)) : 0;
    800032de:	bc46a683          	lw	a3,-1084(a3)
    800032e2:	02069513          	slli	a0,a3,0x20
    800032e6:	9101                	srli	a0,a0,0x20
    800032e8:	40ea0733          	sub	a4,s4,a4
    800032ec:	00a77663          	bgeu	a4,a0,800032f8 <usertrap+0x606>
    800032f0:	9fb5                	addw	a5,a5,a3
    800032f2:	9f8d                	subw	a5,a5,a1
        int is_text = (va0 >= p->text_start && va0 < p->text_end);
    800032f4:	4b05                	li	s6,1
    800032f6:	bdc1                	j	800031c6 <usertrap+0x4d4>
    800032f8:	4b05                	li	s6,1
          filesz = (p->text_filesz > (va0 - p->text_start)) ? (p->text_filesz - (va0 - p->text_start)) : 0;
    800032fa:	4a81                	li	s5,0
    800032fc:	bdd9                	j	800031d2 <usertrap+0x4e0>
          memset(mem, 0, PGSIZE);
    800032fe:	6605                	lui	a2,0x1
    80003300:	4581                	li	a1,0
    80003302:	854a                	mv	a0,s2
    80003304:	99ffd0ef          	jal	80000ca2 <memset>
          if(p->exec_ip && filesz > 0){
    80003308:	6791                	lui	a5,0x4
    8000330a:	97a6                	add	a5,a5,s1
    8000330c:	bb87b503          	ld	a0,-1096(a5) # 3bb8 <_entry-0x7fffc448>
    80003310:	c119                	beqz	a0,80003316 <usertrap+0x624>
    80003312:	060a9563          	bnez	s5,8000337c <usertrap+0x68a>
        int perm = PTE_U | PTE_R | (is_text ? PTE_X : 0);
    80003316:	4769                	li	a4,26
    80003318:	140b0963          	beqz	s6,8000346a <usertrap+0x778>
          if(mappages(p->pagetable, va0, PGSIZE, (uint64)mem, perm) < 0){
    8000331c:	86ca                	mv	a3,s2
    8000331e:	6605                	lui	a2,0x1
    80003320:	85d2                	mv	a1,s4
    80003322:	68a8                	ld	a0,80(s1)
    80003324:	d9bfd0ef          	jal	800010be <mappages>
    80003328:	08054e63          	bltz	a0,800033c4 <usertrap+0x6d2>
          if(p->vmtrace) printf("[pid %d] LOADEXEC va=%p\n", p->pid, (void*)va0);
    8000332c:	6791                	lui	a5,0x4
    8000332e:	97a6                	add	a5,a5,s1
    80003330:	bf47a783          	lw	a5,-1036(a5) # 3bf4 <_entry-0x7fffc40c>
    80003334:	ebc5                	bnez	a5,800033e4 <usertrap+0x6f2>
          int seq = p->memstat.next_fifo_seq++;
    80003336:	678d                	lui	a5,0x3
    80003338:	97a6                	add	a5,a5,s1
    8000333a:	1847a903          	lw	s2,388(a5) # 3184 <_entry-0x7fffce7c>
    8000333e:	0019071b          	addiw	a4,s2,1
    80003342:	18e7a223          	sw	a4,388(a5)
          if(p->vmtrace) printf("[pid %d] RESIDENT va=%p seq=%d\n", p->pid, (void*)va0, seq);
    80003346:	6791                	lui	a5,0x4
    80003348:	97a6                	add	a5,a5,s1
    8000334a:	bf47a783          	lw	a5,-1036(a5) # 3bf4 <_entry-0x7fffc40c>
    8000334e:	e7c5                	bnez	a5,800033f6 <usertrap+0x704>
          memstat_mark_resident(p, va0, seq);
    80003350:	864a                	mv	a2,s2
    80003352:	85d2                	mv	a1,s4
    80003354:	8526                	mv	a0,s1
    80003356:	a22fe0ef          	jal	80001578 <memstat_mark_resident>
          p->resident_pages++;
    8000335a:	6791                	lui	a5,0x4
    8000335c:	97a6                	add	a5,a5,s1
    8000335e:	be47a703          	lw	a4,-1052(a5) # 3be4 <_entry-0x7fffc41c>
    80003362:	2705                	addiw	a4,a4,1 # 3001 <_entry-0x7fffcfff>
    80003364:	bee7a223          	sw	a4,-1052(a5)
    80003368:	69e6                	ld	s3,88(sp)
    8000336a:	6a46                	ld	s4,80(sp)
    8000336c:	6aa6                	ld	s5,72(sp)
    8000336e:	6b06                	ld	s6,64(sp)
    80003370:	7be2                	ld	s7,56(sp)
    80003372:	7c42                	ld	s8,48(sp)
    80003374:	7ca2                	ld	s9,40(sp)
    80003376:	7d02                	ld	s10,32(sp)
    80003378:	6de2                	ld	s11,24(sp)
    8000337a:	bcc1                	j	80002e4a <usertrap+0x158>
            ilock(p->exec_ip);
    8000337c:	6a7000ef          	jal	80004222 <ilock>
            n = readi(p->exec_ip, 0, (uint64)mem, off, filesz);
    80003380:	6b91                	lui	s7,0x4
    80003382:	9ba6                	add	s7,s7,s1
    80003384:	8756                	mv	a4,s5
    80003386:	86ce                	mv	a3,s3
    80003388:	864a                	mv	a2,s2
    8000338a:	4581                	li	a1,0
    8000338c:	bb8bb503          	ld	a0,-1096(s7) # 3bb8 <_entry-0x7fffc448>
    80003390:	222010ef          	jal	800045b2 <readi>
    80003394:	89aa                	mv	s3,a0
            iunlock(p->exec_ip);
    80003396:	bb8bb503          	ld	a0,-1096(s7)
    8000339a:	737000ef          	jal	800042d0 <iunlock>
            if(n != filesz){
    8000339e:	2981                	sext.w	s3,s3
    800033a0:	f7598be3          	beq	s3,s5,80003316 <usertrap+0x624>
              kfree(mem);
    800033a4:	854a                	mv	a0,s2
    800033a6:	e76fd0ef          	jal	80000a1c <kfree>
              setkilled(p);
    800033aa:	8526                	mv	a0,s1
    800033ac:	ca6ff0ef          	jal	80002852 <setkilled>
              goto pf_done;
    800033b0:	69e6                	ld	s3,88(sp)
    800033b2:	6a46                	ld	s4,80(sp)
    800033b4:	6aa6                	ld	s5,72(sp)
    800033b6:	6b06                	ld	s6,64(sp)
    800033b8:	7be2                	ld	s7,56(sp)
    800033ba:	7c42                	ld	s8,48(sp)
    800033bc:	7ca2                	ld	s9,40(sp)
    800033be:	7d02                	ld	s10,32(sp)
    800033c0:	6de2                	ld	s11,24(sp)
    800033c2:	b461                	j	80002e4a <usertrap+0x158>
            kfree(mem);
    800033c4:	854a                	mv	a0,s2
    800033c6:	e56fd0ef          	jal	80000a1c <kfree>
            setkilled(p);
    800033ca:	8526                	mv	a0,s1
    800033cc:	c86ff0ef          	jal	80002852 <setkilled>
            goto pf_done;
    800033d0:	69e6                	ld	s3,88(sp)
    800033d2:	6a46                	ld	s4,80(sp)
    800033d4:	6aa6                	ld	s5,72(sp)
    800033d6:	6b06                	ld	s6,64(sp)
    800033d8:	7be2                	ld	s7,56(sp)
    800033da:	7c42                	ld	s8,48(sp)
    800033dc:	7ca2                	ld	s9,40(sp)
    800033de:	7d02                	ld	s10,32(sp)
    800033e0:	6de2                	ld	s11,24(sp)
    800033e2:	b4a5                	j	80002e4a <usertrap+0x158>
          if(p->vmtrace) printf("[pid %d] LOADEXEC va=%p\n", p->pid, (void*)va0);
    800033e4:	8652                	mv	a2,s4
    800033e6:	588c                	lw	a1,48(s1)
    800033e8:	00006517          	auipc	a0,0x6
    800033ec:	0c050513          	addi	a0,a0,192 # 800094a8 <etext+0x4a8>
    800033f0:	90afd0ef          	jal	800004fa <printf>
    800033f4:	b789                	j	80003336 <usertrap+0x644>
          if(p->vmtrace) printf("[pid %d] RESIDENT va=%p seq=%d\n", p->pid, (void*)va0, seq);
    800033f6:	86ca                	mv	a3,s2
    800033f8:	8652                	mv	a2,s4
    800033fa:	588c                	lw	a1,48(s1)
    800033fc:	00006517          	auipc	a0,0x6
    80003400:	06450513          	addi	a0,a0,100 # 80009460 <etext+0x460>
    80003404:	8f6fd0ef          	jal	800004fa <printf>
    80003408:	b7a1                	j	80003350 <usertrap+0x65e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000340a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000340e:	5890                	lw	a2,48(s1)
    80003410:	00006517          	auipc	a0,0x6
    80003414:	0b850513          	addi	a0,a0,184 # 800094c8 <etext+0x4c8>
    80003418:	8e2fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000341c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003420:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80003424:	00006517          	auipc	a0,0x6
    80003428:	0d450513          	addi	a0,a0,212 # 800094f8 <etext+0x4f8>
    8000342c:	8cefd0ef          	jal	800004fa <printf>
    setkilled(p);
    80003430:	8526                	mv	a0,s1
    80003432:	c20ff0ef          	jal	80002852 <setkilled>
    80003436:	bc11                	j	80002e4a <usertrap+0x158>
  if(killed(p))
    80003438:	8526                	mv	a0,s1
    8000343a:	c3cff0ef          	jal	80002876 <killed>
    8000343e:	c511                	beqz	a0,8000344a <usertrap+0x758>
    80003440:	a011                	j	80003444 <usertrap+0x752>
    80003442:	4901                	li	s2,0
    kexit(-1);
    80003444:	557d                	li	a0,-1
    80003446:	ad4ff0ef          	jal	8000271a <kexit>
  if(which_dev == 2)
    8000344a:	4789                	li	a5,2
    8000344c:	a0f914e3          	bne	s2,a5,80002e54 <usertrap+0x162>
    yield();
    80003450:	982ff0ef          	jal	800025d2 <yield>
    80003454:	b401                	j	80002e54 <usertrap+0x162>
    80003456:	69e6                	ld	s3,88(sp)
    80003458:	6a46                	ld	s4,80(sp)
    8000345a:	6aa6                	ld	s5,72(sp)
    8000345c:	6b06                	ld	s6,64(sp)
    8000345e:	7be2                	ld	s7,56(sp)
    80003460:	7c42                	ld	s8,48(sp)
    80003462:	7ca2                	ld	s9,40(sp)
    80003464:	7d02                	ld	s10,32(sp)
    80003466:	6de2                	ld	s11,24(sp)
    80003468:	b2cd                	j	80002e4a <usertrap+0x158>
        int perm = PTE_U | PTE_R | (is_text ? PTE_X : 0);
    8000346a:	4749                	li	a4,18
    8000346c:	bd45                	j	8000331c <usertrap+0x62a>
      printf("[pid %d] PAGEFAULT va=%p access=%s cause=%s\n", p->pid, (void*)va, acc, cause ? cause : "invalid");
    8000346e:	588c                	lw	a1,48(s1)
    80003470:	8656                	mv	a2,s5
    80003472:	f8843703          	ld	a4,-120(s0)
    80003476:	4d05                	li	s10,1
    80003478:	a82d                	j	800034b2 <usertrap+0x7c0>
      cause = "exec"; valid = 1;
    8000347a:	00006797          	auipc	a5,0x6
    8000347e:	de678793          	addi	a5,a5,-538 # 80009260 <etext+0x260>
    80003482:	f8f43423          	sd	a5,-120(s0)
    80003486:	b499                	j	80002ecc <usertrap+0x1da>
    int was_swapped = 0;
    80003488:	8c4a                	mv	s8,s2
    p->pagefault_count++;
    8000348a:	6791                	lui	a5,0x4
    8000348c:	97a6                	add	a5,a5,s1
    8000348e:	be07a703          	lw	a4,-1056(a5) # 3be0 <_entry-0x7fffc420>
    80003492:	2705                	addiw	a4,a4,1
    80003494:	bee7a023          	sw	a4,-1056(a5)
    if(p->vmtrace)
    80003498:	bf47a783          	lw	a5,-1036(a5)
    8000349c:	c785                	beqz	a5,800034c4 <usertrap+0x7d2>
      printf("[pid %d] PAGEFAULT va=%p access=%s cause=%s\n", p->pid, (void*)va, acc, cause ? cause : "invalid");
    8000349e:	588c                	lw	a1,48(s1)
    800034a0:	8656                	mv	a2,s5
      cause = "guard"; valid = 0; // references to guard page are invalid
    800034a2:	8d4a                	mv	s10,s2
    800034a4:	00006797          	auipc	a5,0x6
    800034a8:	ed478793          	addi	a5,a5,-300 # 80009378 <etext+0x378>
    800034ac:	f8f43423          	sd	a5,-120(s0)
      printf("[pid %d] PAGEFAULT va=%p access=%s cause=%s\n", p->pid, (void*)va, acc, cause ? cause : "invalid");
    800034b0:	873e                	mv	a4,a5
    800034b2:	86ee                	mv	a3,s11
    800034b4:	00006517          	auipc	a0,0x6
    800034b8:	f0c50513          	addi	a0,a0,-244 # 800093c0 <etext+0x3c0>
    800034bc:	83efd0ef          	jal	800004fa <printf>
    if(!valid){
    800034c0:	a20d11e3          	bnez	s10,80002ee2 <usertrap+0x1f0>
      printf("[pid %d] KILL invalid-access va=%p access=%s\n", p->pid, (void*)va, acc);
    800034c4:	86ee                	mv	a3,s11
    800034c6:	8656                	mv	a2,s5
    800034c8:	588c                	lw	a1,48(s1)
    800034ca:	00006517          	auipc	a0,0x6
    800034ce:	f2650513          	addi	a0,a0,-218 # 800093f0 <etext+0x3f0>
    800034d2:	828fd0ef          	jal	800004fa <printf>
      setkilled(p);
    800034d6:	8526                	mv	a0,s1
    800034d8:	b7aff0ef          	jal	80002852 <setkilled>
    800034dc:	69e6                	ld	s3,88(sp)
    800034de:	6a46                	ld	s4,80(sp)
    800034e0:	6aa6                	ld	s5,72(sp)
    800034e2:	6b06                	ld	s6,64(sp)
    800034e4:	7be2                	ld	s7,56(sp)
    800034e6:	7c42                	ld	s8,48(sp)
    800034e8:	7ca2                	ld	s9,40(sp)
    800034ea:	7d02                	ld	s10,32(sp)
    800034ec:	6de2                	ld	s11,24(sp)
    800034ee:	bab1                	j	80002e4a <usertrap+0x158>
    800034f0:	69e6                	ld	s3,88(sp)
    800034f2:	6a46                	ld	s4,80(sp)
    800034f4:	6aa6                	ld	s5,72(sp)
    800034f6:	6b06                	ld	s6,64(sp)
    800034f8:	7be2                	ld	s7,56(sp)
    800034fa:	7c42                	ld	s8,48(sp)
    800034fc:	7ca2                	ld	s9,40(sp)
    800034fe:	7d02                	ld	s10,32(sp)
    80003500:	6de2                	ld	s11,24(sp)
    80003502:	b789                	j	80003444 <usertrap+0x752>
                if(idx < MAX_PAGES_INFO) p->memstat.pages[idx].is_dirty = 1;
    80003504:	002d1793          	slli	a5,s10,0x2
    80003508:	97ea                	add	a5,a5,s10
    8000350a:	078a                	slli	a5,a5,0x2
    8000350c:	97a6                	add	a5,a5,s1
    8000350e:	670d                	lui	a4,0x3
    80003510:	97ba                	add	a5,a5,a4
    80003512:	4705                	li	a4,1
    80003514:	18e7a823          	sw	a4,400(a5)
    80003518:	b485                	j	80002f78 <usertrap+0x286>
          pte = walk(p->pagetable, va0, 0);
    8000351a:	4601                	li	a2,0
    8000351c:	85d2                	mv	a1,s4
    8000351e:	68a8                	ld	a0,80(s1)
    80003520:	ac7fd0ef          	jal	80000fe6 <walk>
    80003524:	87aa                	mv	a5,a0
          if(pte){
    80003526:	c115                	beqz	a0,8000354a <usertrap+0x858>
              *pte &= ~PTE_W;
    80003528:	6398                	ld	a4,0(a5)
    8000352a:	9b6d                	andi	a4,a4,-5
    8000352c:	01a76713          	ori	a4,a4,26
    80003530:	e398                	sd	a4,0(a5)
  asm volatile("sfence.vma zero, zero");
    80003532:	12000073          	sfence.vma
}
    80003536:	69e6                	ld	s3,88(sp)
    80003538:	6a46                	ld	s4,80(sp)
    8000353a:	6aa6                	ld	s5,72(sp)
    8000353c:	6b06                	ld	s6,64(sp)
    8000353e:	7be2                	ld	s7,56(sp)
    80003540:	7c42                	ld	s8,48(sp)
    80003542:	7ca2                	ld	s9,40(sp)
    80003544:	7d02                	ld	s10,32(sp)
    80003546:	6de2                	ld	s11,24(sp)
    80003548:	b209                	j	80002e4a <usertrap+0x158>
    8000354a:	69e6                	ld	s3,88(sp)
    8000354c:	6a46                	ld	s4,80(sp)
    8000354e:	6aa6                	ld	s5,72(sp)
    80003550:	6b06                	ld	s6,64(sp)
    80003552:	7be2                	ld	s7,56(sp)
    80003554:	7c42                	ld	s8,48(sp)
    80003556:	7ca2                	ld	s9,40(sp)
    80003558:	7d02                	ld	s10,32(sp)
    8000355a:	6de2                	ld	s11,24(sp)
    8000355c:	b0fd                	j	80002e4a <usertrap+0x158>
    8000355e:	69e6                	ld	s3,88(sp)
    80003560:	6a46                	ld	s4,80(sp)
    80003562:	6aa6                	ld	s5,72(sp)
    80003564:	6b06                	ld	s6,64(sp)
    80003566:	7be2                	ld	s7,56(sp)
    80003568:	7c42                	ld	s8,48(sp)
    8000356a:	7ca2                	ld	s9,40(sp)
    8000356c:	7d02                	ld	s10,32(sp)
    8000356e:	6de2                	ld	s11,24(sp)
    80003570:	b8e9                	j	80002e4a <usertrap+0x158>
        if(pa == 0){
    80003572:	ca0515e3          	bnez	a0,8000321c <usertrap+0x52a>
          mem = try_kalloc_or_replace(va0);
    80003576:	8552                	mv	a0,s4
    80003578:	8cafe0ef          	jal	80001642 <try_kalloc_or_replace>
    8000357c:	892a                	mv	s2,a0
          newly_alloc = 1;
    8000357e:	4605                	li	a2,1
          if(mem == 0){
    80003580:	be051de3          	bnez	a0,8000317a <usertrap+0x488>
            setkilled(p);
    80003584:	8526                	mv	a0,s1
    80003586:	accff0ef          	jal	80002852 <setkilled>
            goto pf_done;
    8000358a:	69e6                	ld	s3,88(sp)
    8000358c:	6a46                	ld	s4,80(sp)
    8000358e:	6aa6                	ld	s5,72(sp)
    80003590:	6b06                	ld	s6,64(sp)
    80003592:	7be2                	ld	s7,56(sp)
    80003594:	7c42                	ld	s8,48(sp)
    80003596:	7ca2                	ld	s9,40(sp)
    80003598:	7d02                	ld	s10,32(sp)
    8000359a:	6de2                	ld	s11,24(sp)
    8000359c:	8afff06f          	j	80002e4a <usertrap+0x158>
    if(in_guard){
    800035a0:	ee0c14e3          	bnez	s8,80003488 <usertrap+0x796>
    } else if(in_text || in_data){
    800035a4:	011368b3          	or	a7,t1,a7
    800035a8:	00088d1b          	sext.w	s10,a7
    800035ac:	ec0d17e3          	bnez	s10,8000347a <usertrap+0x788>
    } else if(in_stack && !is_exec_access){
    800035b0:	c919                	beqz	a0,800035c6 <usertrap+0x8d4>
    800035b2:	47b1                	li	a5,12
    800035b4:	8c6a                	mv	s8,s10
      cause = "stack"; valid = 1;
    800035b6:	00006717          	auipc	a4,0x6
    800035ba:	dda70713          	addi	a4,a4,-550 # 80009390 <etext+0x390>
    800035be:	f8e43423          	sd	a4,-120(s0)
    } else if(in_stack && !is_exec_access){
    800035c2:	90fc95e3          	bne	s9,a5,80002ecc <usertrap+0x1da>
    } else if(in_heap && !is_exec_access){
    800035c6:	00080c63          	beqz	a6,800035de <usertrap+0x8ec>
    800035ca:	47b1                	li	a5,12
    800035cc:	8c6a                	mv	s8,s10
      cause = "heap"; valid = 1;
    800035ce:	00006717          	auipc	a4,0x6
    800035d2:	dba70713          	addi	a4,a4,-582 # 80009388 <etext+0x388>
    800035d6:	f8e43423          	sd	a4,-120(s0)
    } else if(in_heap && !is_exec_access){
    800035da:	8efc99e3          	bne	s9,a5,80002ecc <usertrap+0x1da>
    p->pagefault_count++;
    800035de:	6791                	lui	a5,0x4
    800035e0:	97a6                	add	a5,a5,s1
    800035e2:	be07a703          	lw	a4,-1056(a5) # 3be0 <_entry-0x7fffc420>
    800035e6:	2705                	addiw	a4,a4,1
    800035e8:	bee7a023          	sw	a4,-1056(a5)
    if(p->vmtrace)
    800035ec:	bf47a783          	lw	a5,-1036(a5)
    800035f0:	ec078ae3          	beqz	a5,800034c4 <usertrap+0x7d2>
      printf("[pid %d] PAGEFAULT va=%p access=%s cause=%s\n", p->pid, (void*)va, acc, cause ? cause : "invalid");
    800035f4:	588c                	lw	a1,48(s1)
    800035f6:	8656                	mv	a2,s5
    800035f8:	8c6a                	mv	s8,s10
    800035fa:	f8043423          	sd	zero,-120(s0)
    800035fe:	00006717          	auipc	a4,0x6
    80003602:	d8270713          	addi	a4,a4,-638 # 80009380 <etext+0x380>
    80003606:	b575                	j	800034b2 <usertrap+0x7c0>

0000000080003608 <kerneltrap>:
{
    80003608:	7179                	addi	sp,sp,-48
    8000360a:	f406                	sd	ra,40(sp)
    8000360c:	f022                	sd	s0,32(sp)
    8000360e:	ec26                	sd	s1,24(sp)
    80003610:	e84a                	sd	s2,16(sp)
    80003612:	e44e                	sd	s3,8(sp)
    80003614:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003616:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000361a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000361e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003622:	1004f793          	andi	a5,s1,256
    80003626:	c795                	beqz	a5,80003652 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003628:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000362c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000362e:	eb85                	bnez	a5,8000365e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80003630:	e4eff0ef          	jal	80002c7e <devintr>
    80003634:	c91d                	beqz	a0,8000366a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80003636:	4789                	li	a5,2
    80003638:	04f50a63          	beq	a0,a5,8000368c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000363c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003640:	10049073          	csrw	sstatus,s1
}
    80003644:	70a2                	ld	ra,40(sp)
    80003646:	7402                	ld	s0,32(sp)
    80003648:	64e2                	ld	s1,24(sp)
    8000364a:	6942                	ld	s2,16(sp)
    8000364c:	69a2                	ld	s3,8(sp)
    8000364e:	6145                	addi	sp,sp,48
    80003650:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003652:	00006517          	auipc	a0,0x6
    80003656:	ece50513          	addi	a0,a0,-306 # 80009520 <etext+0x520>
    8000365a:	986fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000365e:	00006517          	auipc	a0,0x6
    80003662:	eea50513          	addi	a0,a0,-278 # 80009548 <etext+0x548>
    80003666:	97afd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000366a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000366e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80003672:	85ce                	mv	a1,s3
    80003674:	00006517          	auipc	a0,0x6
    80003678:	ef450513          	addi	a0,a0,-268 # 80009568 <etext+0x568>
    8000367c:	e7ffc0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80003680:	00006517          	auipc	a0,0x6
    80003684:	f1050513          	addi	a0,a0,-240 # 80009590 <etext+0x590>
    80003688:	958fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000368c:	817fe0ef          	jal	80001ea2 <myproc>
    80003690:	d555                	beqz	a0,8000363c <kerneltrap+0x34>
    yield();
    80003692:	f41fe0ef          	jal	800025d2 <yield>
    80003696:	b75d                	j	8000363c <kerneltrap+0x34>

0000000080003698 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003698:	1101                	addi	sp,sp,-32
    8000369a:	ec06                	sd	ra,24(sp)
    8000369c:	e822                	sd	s0,16(sp)
    8000369e:	e426                	sd	s1,8(sp)
    800036a0:	1000                	addi	s0,sp,32
    800036a2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800036a4:	ffefe0ef          	jal	80001ea2 <myproc>
  switch (n) {
    800036a8:	4795                	li	a5,5
    800036aa:	0497e163          	bltu	a5,s1,800036ec <argraw+0x54>
    800036ae:	048a                	slli	s1,s1,0x2
    800036b0:	00006717          	auipc	a4,0x6
    800036b4:	41870713          	addi	a4,a4,1048 # 80009ac8 <states.0+0x30>
    800036b8:	94ba                	add	s1,s1,a4
    800036ba:	409c                	lw	a5,0(s1)
    800036bc:	97ba                	add	a5,a5,a4
    800036be:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800036c0:	6d3c                	ld	a5,88(a0)
    800036c2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800036c4:	60e2                	ld	ra,24(sp)
    800036c6:	6442                	ld	s0,16(sp)
    800036c8:	64a2                	ld	s1,8(sp)
    800036ca:	6105                	addi	sp,sp,32
    800036cc:	8082                	ret
    return p->trapframe->a1;
    800036ce:	6d3c                	ld	a5,88(a0)
    800036d0:	7fa8                	ld	a0,120(a5)
    800036d2:	bfcd                	j	800036c4 <argraw+0x2c>
    return p->trapframe->a2;
    800036d4:	6d3c                	ld	a5,88(a0)
    800036d6:	63c8                	ld	a0,128(a5)
    800036d8:	b7f5                	j	800036c4 <argraw+0x2c>
    return p->trapframe->a3;
    800036da:	6d3c                	ld	a5,88(a0)
    800036dc:	67c8                	ld	a0,136(a5)
    800036de:	b7dd                	j	800036c4 <argraw+0x2c>
    return p->trapframe->a4;
    800036e0:	6d3c                	ld	a5,88(a0)
    800036e2:	6bc8                	ld	a0,144(a5)
    800036e4:	b7c5                	j	800036c4 <argraw+0x2c>
    return p->trapframe->a5;
    800036e6:	6d3c                	ld	a5,88(a0)
    800036e8:	6fc8                	ld	a0,152(a5)
    800036ea:	bfe9                	j	800036c4 <argraw+0x2c>
  panic("argraw");
    800036ec:	00006517          	auipc	a0,0x6
    800036f0:	eb450513          	addi	a0,a0,-332 # 800095a0 <etext+0x5a0>
    800036f4:	8ecfd0ef          	jal	800007e0 <panic>

00000000800036f8 <fetchaddr>:
{
    800036f8:	1101                	addi	sp,sp,-32
    800036fa:	ec06                	sd	ra,24(sp)
    800036fc:	e822                	sd	s0,16(sp)
    800036fe:	e426                	sd	s1,8(sp)
    80003700:	e04a                	sd	s2,0(sp)
    80003702:	1000                	addi	s0,sp,32
    80003704:	84aa                	mv	s1,a0
    80003706:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003708:	f9afe0ef          	jal	80001ea2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000370c:	653c                	ld	a5,72(a0)
    8000370e:	02f4f663          	bgeu	s1,a5,8000373a <fetchaddr+0x42>
    80003712:	00848713          	addi	a4,s1,8
    80003716:	02e7e463          	bltu	a5,a4,8000373e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000371a:	46a1                	li	a3,8
    8000371c:	8626                	mv	a2,s1
    8000371e:	85ca                	mv	a1,s2
    80003720:	6928                	ld	a0,80(a0)
    80003722:	c42fe0ef          	jal	80001b64 <copyin>
    80003726:	00a03533          	snez	a0,a0
    8000372a:	40a00533          	neg	a0,a0
}
    8000372e:	60e2                	ld	ra,24(sp)
    80003730:	6442                	ld	s0,16(sp)
    80003732:	64a2                	ld	s1,8(sp)
    80003734:	6902                	ld	s2,0(sp)
    80003736:	6105                	addi	sp,sp,32
    80003738:	8082                	ret
    return -1;
    8000373a:	557d                	li	a0,-1
    8000373c:	bfcd                	j	8000372e <fetchaddr+0x36>
    8000373e:	557d                	li	a0,-1
    80003740:	b7fd                	j	8000372e <fetchaddr+0x36>

0000000080003742 <fetchstr>:
{
    80003742:	7179                	addi	sp,sp,-48
    80003744:	f406                	sd	ra,40(sp)
    80003746:	f022                	sd	s0,32(sp)
    80003748:	ec26                	sd	s1,24(sp)
    8000374a:	e84a                	sd	s2,16(sp)
    8000374c:	e44e                	sd	s3,8(sp)
    8000374e:	1800                	addi	s0,sp,48
    80003750:	892a                	mv	s2,a0
    80003752:	84ae                	mv	s1,a1
    80003754:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003756:	f4cfe0ef          	jal	80001ea2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000375a:	86ce                	mv	a3,s3
    8000375c:	864a                	mv	a2,s2
    8000375e:	85a6                	mv	a1,s1
    80003760:	6928                	ld	a0,80(a0)
    80003762:	cbafe0ef          	jal	80001c1c <copyinstr>
    80003766:	00054c63          	bltz	a0,8000377e <fetchstr+0x3c>
  return strlen(buf);
    8000376a:	8526                	mv	a0,s1
    8000376c:	ea6fd0ef          	jal	80000e12 <strlen>
}
    80003770:	70a2                	ld	ra,40(sp)
    80003772:	7402                	ld	s0,32(sp)
    80003774:	64e2                	ld	s1,24(sp)
    80003776:	6942                	ld	s2,16(sp)
    80003778:	69a2                	ld	s3,8(sp)
    8000377a:	6145                	addi	sp,sp,48
    8000377c:	8082                	ret
    return -1;
    8000377e:	557d                	li	a0,-1
    80003780:	bfc5                	j	80003770 <fetchstr+0x2e>

0000000080003782 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003782:	1101                	addi	sp,sp,-32
    80003784:	ec06                	sd	ra,24(sp)
    80003786:	e822                	sd	s0,16(sp)
    80003788:	e426                	sd	s1,8(sp)
    8000378a:	1000                	addi	s0,sp,32
    8000378c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000378e:	f0bff0ef          	jal	80003698 <argraw>
    80003792:	c088                	sw	a0,0(s1)
}
    80003794:	60e2                	ld	ra,24(sp)
    80003796:	6442                	ld	s0,16(sp)
    80003798:	64a2                	ld	s1,8(sp)
    8000379a:	6105                	addi	sp,sp,32
    8000379c:	8082                	ret

000000008000379e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000379e:	1101                	addi	sp,sp,-32
    800037a0:	ec06                	sd	ra,24(sp)
    800037a2:	e822                	sd	s0,16(sp)
    800037a4:	e426                	sd	s1,8(sp)
    800037a6:	1000                	addi	s0,sp,32
    800037a8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800037aa:	eefff0ef          	jal	80003698 <argraw>
    800037ae:	e088                	sd	a0,0(s1)
}
    800037b0:	60e2                	ld	ra,24(sp)
    800037b2:	6442                	ld	s0,16(sp)
    800037b4:	64a2                	ld	s1,8(sp)
    800037b6:	6105                	addi	sp,sp,32
    800037b8:	8082                	ret

00000000800037ba <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800037ba:	7179                	addi	sp,sp,-48
    800037bc:	f406                	sd	ra,40(sp)
    800037be:	f022                	sd	s0,32(sp)
    800037c0:	ec26                	sd	s1,24(sp)
    800037c2:	e84a                	sd	s2,16(sp)
    800037c4:	1800                	addi	s0,sp,48
    800037c6:	84ae                	mv	s1,a1
    800037c8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800037ca:	fd840593          	addi	a1,s0,-40
    800037ce:	fd1ff0ef          	jal	8000379e <argaddr>
  return fetchstr(addr, buf, max);
    800037d2:	864a                	mv	a2,s2
    800037d4:	85a6                	mv	a1,s1
    800037d6:	fd843503          	ld	a0,-40(s0)
    800037da:	f69ff0ef          	jal	80003742 <fetchstr>
}
    800037de:	70a2                	ld	ra,40(sp)
    800037e0:	7402                	ld	s0,32(sp)
    800037e2:	64e2                	ld	s1,24(sp)
    800037e4:	6942                	ld	s2,16(sp)
    800037e6:	6145                	addi	sp,sp,48
    800037e8:	8082                	ret

00000000800037ea <syscall>:
[SYS_memstat]  sys_memstat,
};

void
syscall(void)
{
    800037ea:	1101                	addi	sp,sp,-32
    800037ec:	ec06                	sd	ra,24(sp)
    800037ee:	e822                	sd	s0,16(sp)
    800037f0:	e426                	sd	s1,8(sp)
    800037f2:	e04a                	sd	s2,0(sp)
    800037f4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800037f6:	eacfe0ef          	jal	80001ea2 <myproc>
    800037fa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800037fc:	05853903          	ld	s2,88(a0)
    80003800:	0a893783          	ld	a5,168(s2)
    80003804:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003808:	37fd                	addiw	a5,a5,-1
    8000380a:	4755                	li	a4,21
    8000380c:	00f76f63          	bltu	a4,a5,8000382a <syscall+0x40>
    80003810:	00369713          	slli	a4,a3,0x3
    80003814:	00006797          	auipc	a5,0x6
    80003818:	2cc78793          	addi	a5,a5,716 # 80009ae0 <syscalls>
    8000381c:	97ba                	add	a5,a5,a4
    8000381e:	639c                	ld	a5,0(a5)
    80003820:	c789                	beqz	a5,8000382a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003822:	9782                	jalr	a5
    80003824:	06a93823          	sd	a0,112(s2)
    80003828:	a829                	j	80003842 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000382a:	15848613          	addi	a2,s1,344
    8000382e:	588c                	lw	a1,48(s1)
    80003830:	00006517          	auipc	a0,0x6
    80003834:	d7850513          	addi	a0,a0,-648 # 800095a8 <etext+0x5a8>
    80003838:	cc3fc0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000383c:	6cbc                	ld	a5,88(s1)
    8000383e:	577d                	li	a4,-1
    80003840:	fbb8                	sd	a4,112(a5)
  }
}
    80003842:	60e2                	ld	ra,24(sp)
    80003844:	6442                	ld	s0,16(sp)
    80003846:	64a2                	ld	s1,8(sp)
    80003848:	6902                	ld	s2,0(sp)
    8000384a:	6105                	addi	sp,sp,32
    8000384c:	8082                	ret

000000008000384e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000384e:	1101                	addi	sp,sp,-32
    80003850:	ec06                	sd	ra,24(sp)
    80003852:	e822                	sd	s0,16(sp)
    80003854:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003856:	fec40593          	addi	a1,s0,-20
    8000385a:	4501                	li	a0,0
    8000385c:	f27ff0ef          	jal	80003782 <argint>
  kexit(n);
    80003860:	fec42503          	lw	a0,-20(s0)
    80003864:	eb7fe0ef          	jal	8000271a <kexit>
  return 0;  // not reached
}
    80003868:	4501                	li	a0,0
    8000386a:	60e2                	ld	ra,24(sp)
    8000386c:	6442                	ld	s0,16(sp)
    8000386e:	6105                	addi	sp,sp,32
    80003870:	8082                	ret

0000000080003872 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003872:	1141                	addi	sp,sp,-16
    80003874:	e406                	sd	ra,8(sp)
    80003876:	e022                	sd	s0,0(sp)
    80003878:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000387a:	e28fe0ef          	jal	80001ea2 <myproc>
}
    8000387e:	5908                	lw	a0,48(a0)
    80003880:	60a2                	ld	ra,8(sp)
    80003882:	6402                	ld	s0,0(sp)
    80003884:	0141                	addi	sp,sp,16
    80003886:	8082                	ret

0000000080003888 <sys_fork>:

uint64
sys_fork(void)
{
    80003888:	1141                	addi	sp,sp,-16
    8000388a:	e406                	sd	ra,8(sp)
    8000388c:	e022                	sd	s0,0(sp)
    8000388e:	0800                	addi	s0,sp,16
  return kfork();
    80003890:	a39fe0ef          	jal	800022c8 <kfork>
}
    80003894:	60a2                	ld	ra,8(sp)
    80003896:	6402                	ld	s0,0(sp)
    80003898:	0141                	addi	sp,sp,16
    8000389a:	8082                	ret

000000008000389c <sys_wait>:

uint64
sys_wait(void)
{
    8000389c:	1101                	addi	sp,sp,-32
    8000389e:	ec06                	sd	ra,24(sp)
    800038a0:	e822                	sd	s0,16(sp)
    800038a2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800038a4:	fe840593          	addi	a1,s0,-24
    800038a8:	4501                	li	a0,0
    800038aa:	ef5ff0ef          	jal	8000379e <argaddr>
  return kwait(p);
    800038ae:	fe843503          	ld	a0,-24(s0)
    800038b2:	feffe0ef          	jal	800028a0 <kwait>
}
    800038b6:	60e2                	ld	ra,24(sp)
    800038b8:	6442                	ld	s0,16(sp)
    800038ba:	6105                	addi	sp,sp,32
    800038bc:	8082                	ret

00000000800038be <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800038be:	7179                	addi	sp,sp,-48
    800038c0:	f406                	sd	ra,40(sp)
    800038c2:	f022                	sd	s0,32(sp)
    800038c4:	ec26                	sd	s1,24(sp)
    800038c6:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800038c8:	fd840593          	addi	a1,s0,-40
    800038cc:	4501                	li	a0,0
    800038ce:	eb5ff0ef          	jal	80003782 <argint>
  argint(1, &t);
    800038d2:	fdc40593          	addi	a1,s0,-36
    800038d6:	4505                	li	a0,1
    800038d8:	eabff0ef          	jal	80003782 <argint>
  addr = myproc()->sz;
    800038dc:	dc6fe0ef          	jal	80001ea2 <myproc>
    800038e0:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800038e2:	fdc42703          	lw	a4,-36(s0)
    800038e6:	4785                	li	a5,1
    800038e8:	02f70763          	beq	a4,a5,80003916 <sys_sbrk+0x58>
    800038ec:	fd842783          	lw	a5,-40(s0)
    800038f0:	0207c363          	bltz	a5,80003916 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800038f4:	97a6                	add	a5,a5,s1
    800038f6:	0297ee63          	bltu	a5,s1,80003932 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    800038fa:	02000737          	lui	a4,0x2000
    800038fe:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80003900:	0736                	slli	a4,a4,0xd
    80003902:	02f76a63          	bltu	a4,a5,80003936 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80003906:	d9cfe0ef          	jal	80001ea2 <myproc>
    8000390a:	fd842703          	lw	a4,-40(s0)
    8000390e:	653c                	ld	a5,72(a0)
    80003910:	97ba                	add	a5,a5,a4
    80003912:	e53c                	sd	a5,72(a0)
    80003914:	a039                	j	80003922 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80003916:	fd842503          	lw	a0,-40(s0)
    8000391a:	94dfe0ef          	jal	80002266 <growproc>
    8000391e:	00054863          	bltz	a0,8000392e <sys_sbrk+0x70>
  }
  return addr;
}
    80003922:	8526                	mv	a0,s1
    80003924:	70a2                	ld	ra,40(sp)
    80003926:	7402                	ld	s0,32(sp)
    80003928:	64e2                	ld	s1,24(sp)
    8000392a:	6145                	addi	sp,sp,48
    8000392c:	8082                	ret
      return -1;
    8000392e:	54fd                	li	s1,-1
    80003930:	bfcd                	j	80003922 <sys_sbrk+0x64>
      return -1;
    80003932:	54fd                	li	s1,-1
    80003934:	b7fd                	j	80003922 <sys_sbrk+0x64>
      return -1;
    80003936:	54fd                	li	s1,-1
    80003938:	b7ed                	j	80003922 <sys_sbrk+0x64>

000000008000393a <sys_pause>:

uint64
sys_pause(void)
{
    8000393a:	7139                	addi	sp,sp,-64
    8000393c:	fc06                	sd	ra,56(sp)
    8000393e:	f822                	sd	s0,48(sp)
    80003940:	f04a                	sd	s2,32(sp)
    80003942:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003944:	fcc40593          	addi	a1,s0,-52
    80003948:	4501                	li	a0,0
    8000394a:	e39ff0ef          	jal	80003782 <argint>
  if(n < 0)
    8000394e:	fcc42783          	lw	a5,-52(s0)
    80003952:	0607c763          	bltz	a5,800039c0 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80003956:	00101517          	auipc	a0,0x101
    8000395a:	4a250513          	addi	a0,a0,1186 # 80104df8 <tickslock>
    8000395e:	a70fd0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80003962:	00009917          	auipc	s2,0x9
    80003966:	16692903          	lw	s2,358(s2) # 8000cac8 <ticks>
  while(ticks - ticks0 < n){
    8000396a:	fcc42783          	lw	a5,-52(s0)
    8000396e:	cf8d                	beqz	a5,800039a8 <sys_pause+0x6e>
    80003970:	f426                	sd	s1,40(sp)
    80003972:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003974:	00101997          	auipc	s3,0x101
    80003978:	48498993          	addi	s3,s3,1156 # 80104df8 <tickslock>
    8000397c:	00009497          	auipc	s1,0x9
    80003980:	14c48493          	addi	s1,s1,332 # 8000cac8 <ticks>
    if(killed(myproc())){
    80003984:	d1efe0ef          	jal	80001ea2 <myproc>
    80003988:	eeffe0ef          	jal	80002876 <killed>
    8000398c:	ed0d                	bnez	a0,800039c6 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000398e:	85ce                	mv	a1,s3
    80003990:	8526                	mv	a0,s1
    80003992:	c6dfe0ef          	jal	800025fe <sleep>
  while(ticks - ticks0 < n){
    80003996:	409c                	lw	a5,0(s1)
    80003998:	412787bb          	subw	a5,a5,s2
    8000399c:	fcc42703          	lw	a4,-52(s0)
    800039a0:	fee7e2e3          	bltu	a5,a4,80003984 <sys_pause+0x4a>
    800039a4:	74a2                	ld	s1,40(sp)
    800039a6:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800039a8:	00101517          	auipc	a0,0x101
    800039ac:	45050513          	addi	a0,a0,1104 # 80104df8 <tickslock>
    800039b0:	ab6fd0ef          	jal	80000c66 <release>
  return 0;
    800039b4:	4501                	li	a0,0
}
    800039b6:	70e2                	ld	ra,56(sp)
    800039b8:	7442                	ld	s0,48(sp)
    800039ba:	7902                	ld	s2,32(sp)
    800039bc:	6121                	addi	sp,sp,64
    800039be:	8082                	ret
    n = 0;
    800039c0:	fc042623          	sw	zero,-52(s0)
    800039c4:	bf49                	j	80003956 <sys_pause+0x1c>
      release(&tickslock);
    800039c6:	00101517          	auipc	a0,0x101
    800039ca:	43250513          	addi	a0,a0,1074 # 80104df8 <tickslock>
    800039ce:	a98fd0ef          	jal	80000c66 <release>
      return -1;
    800039d2:	557d                	li	a0,-1
    800039d4:	74a2                	ld	s1,40(sp)
    800039d6:	69e2                	ld	s3,24(sp)
    800039d8:	bff9                	j	800039b6 <sys_pause+0x7c>

00000000800039da <sys_kill>:

uint64
sys_kill(void)
{
    800039da:	1101                	addi	sp,sp,-32
    800039dc:	ec06                	sd	ra,24(sp)
    800039de:	e822                	sd	s0,16(sp)
    800039e0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800039e2:	fec40593          	addi	a1,s0,-20
    800039e6:	4501                	li	a0,0
    800039e8:	d9bff0ef          	jal	80003782 <argint>
  return kkill(pid);
    800039ec:	fec42503          	lw	a0,-20(s0)
    800039f0:	df5fe0ef          	jal	800027e4 <kkill>
}
    800039f4:	60e2                	ld	ra,24(sp)
    800039f6:	6442                	ld	s0,16(sp)
    800039f8:	6105                	addi	sp,sp,32
    800039fa:	8082                	ret

00000000800039fc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800039fc:	1101                	addi	sp,sp,-32
    800039fe:	ec06                	sd	ra,24(sp)
    80003a00:	e822                	sd	s0,16(sp)
    80003a02:	e426                	sd	s1,8(sp)
    80003a04:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003a06:	00101517          	auipc	a0,0x101
    80003a0a:	3f250513          	addi	a0,a0,1010 # 80104df8 <tickslock>
    80003a0e:	9c0fd0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80003a12:	00009497          	auipc	s1,0x9
    80003a16:	0b64a483          	lw	s1,182(s1) # 8000cac8 <ticks>
  release(&tickslock);
    80003a1a:	00101517          	auipc	a0,0x101
    80003a1e:	3de50513          	addi	a0,a0,990 # 80104df8 <tickslock>
    80003a22:	a44fd0ef          	jal	80000c66 <release>
  return xticks;
}
    80003a26:	02049513          	slli	a0,s1,0x20
    80003a2a:	9101                	srli	a0,a0,0x20
    80003a2c:	60e2                	ld	ra,24(sp)
    80003a2e:	6442                	ld	s0,16(sp)
    80003a30:	64a2                	ld	s1,8(sp)
    80003a32:	6105                	addi	sp,sp,32
    80003a34:	8082                	ret

0000000080003a36 <sys_memstat>:

uint64
sys_memstat(void)
{
    80003a36:	1101                	addi	sp,sp,-32
    80003a38:	ec06                	sd	ra,24(sp)
    80003a3a:	e822                	sd	s0,16(sp)
    80003a3c:	e426                	sd	s1,8(sp)
    80003a3e:	e04a                	sd	s2,0(sp)
    80003a40:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003a42:	c60fe0ef          	jal	80001ea2 <myproc>
    80003a46:	84aa                	mv	s1,a0
  printf("pid=%d name=%s\n", p->pid, p->name);
    80003a48:	15850613          	addi	a2,a0,344
    80003a4c:	590c                	lw	a1,48(a0)
    80003a4e:	00006517          	auipc	a0,0x6
    80003a52:	b7a50513          	addi	a0,a0,-1158 # 800095c8 <etext+0x5c8>
    80003a56:	aa5fc0ef          	jal	800004fa <printf>
  printf("  pages resident: %d\n", p->resident_pages);
    80003a5a:	6911                	lui	s2,0x4
    80003a5c:	9926                	add	s2,s2,s1
    80003a5e:	be492583          	lw	a1,-1052(s2) # 3be4 <_entry-0x7fffc41c>
    80003a62:	00006517          	auipc	a0,0x6
    80003a66:	b7650513          	addi	a0,a0,-1162 # 800095d8 <etext+0x5d8>
    80003a6a:	a91fc0ef          	jal	800004fa <printf>
  printf("  pages swapped:  %d\n", p->swapped_pages);
    80003a6e:	be892583          	lw	a1,-1048(s2)
    80003a72:	00006517          	auipc	a0,0x6
    80003a76:	b7e50513          	addi	a0,a0,-1154 # 800095f0 <etext+0x5f0>
    80003a7a:	a81fc0ef          	jal	800004fa <printf>
  printf("  next fifo seq:  %d\n", p->memstat.next_fifo_seq);
    80003a7e:	678d                	lui	a5,0x3
    80003a80:	94be                	add	s1,s1,a5
    80003a82:	1844a583          	lw	a1,388(s1)
    80003a86:	00006517          	auipc	a0,0x6
    80003a8a:	b8250513          	addi	a0,a0,-1150 # 80009608 <etext+0x608>
    80003a8e:	a6dfc0ef          	jal	800004fa <printf>
  printf("  page faults:    %d\n", p->pagefault_count);
    80003a92:	be092583          	lw	a1,-1056(s2)
    80003a96:	00006517          	auipc	a0,0x6
    80003a9a:	b8a50513          	addi	a0,a0,-1142 # 80009620 <etext+0x620>
    80003a9e:	a5dfc0ef          	jal	800004fa <printf>
  printf("  swapins:        %d\n", p->swapin_count);
    80003aa2:	bec92583          	lw	a1,-1044(s2)
    80003aa6:	00006517          	auipc	a0,0x6
    80003aaa:	b9250513          	addi	a0,a0,-1134 # 80009638 <etext+0x638>
    80003aae:	a4dfc0ef          	jal	800004fa <printf>
  printf("  swapouts:       %d\n", p->swapout_count);
    80003ab2:	bf092583          	lw	a1,-1040(s2)
    80003ab6:	00006517          	auipc	a0,0x6
    80003aba:	b9a50513          	addi	a0,a0,-1126 # 80009650 <etext+0x650>
    80003abe:	a3dfc0ef          	jal	800004fa <printf>
  return 0;
}
    80003ac2:	4501                	li	a0,0
    80003ac4:	60e2                	ld	ra,24(sp)
    80003ac6:	6442                	ld	s0,16(sp)
    80003ac8:	64a2                	ld	s1,8(sp)
    80003aca:	6902                	ld	s2,0(sp)
    80003acc:	6105                	addi	sp,sp,32
    80003ace:	8082                	ret

0000000080003ad0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003ad0:	7179                	addi	sp,sp,-48
    80003ad2:	f406                	sd	ra,40(sp)
    80003ad4:	f022                	sd	s0,32(sp)
    80003ad6:	ec26                	sd	s1,24(sp)
    80003ad8:	e84a                	sd	s2,16(sp)
    80003ada:	e44e                	sd	s3,8(sp)
    80003adc:	e052                	sd	s4,0(sp)
    80003ade:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003ae0:	00006597          	auipc	a1,0x6
    80003ae4:	b8858593          	addi	a1,a1,-1144 # 80009668 <etext+0x668>
    80003ae8:	00101517          	auipc	a0,0x101
    80003aec:	32850513          	addi	a0,a0,808 # 80104e10 <bcache>
    80003af0:	85efd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003af4:	00109797          	auipc	a5,0x109
    80003af8:	31c78793          	addi	a5,a5,796 # 8010ce10 <bcache+0x8000>
    80003afc:	00109717          	auipc	a4,0x109
    80003b00:	57c70713          	addi	a4,a4,1404 # 8010d078 <bcache+0x8268>
    80003b04:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003b08:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003b0c:	00101497          	auipc	s1,0x101
    80003b10:	31c48493          	addi	s1,s1,796 # 80104e28 <bcache+0x18>
    b->next = bcache.head.next;
    80003b14:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003b16:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003b18:	00006a17          	auipc	s4,0x6
    80003b1c:	b58a0a13          	addi	s4,s4,-1192 # 80009670 <etext+0x670>
    b->next = bcache.head.next;
    80003b20:	2b893783          	ld	a5,696(s2)
    80003b24:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003b26:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003b2a:	85d2                	mv	a1,s4
    80003b2c:	01048513          	addi	a0,s1,16
    80003b30:	322010ef          	jal	80004e52 <initsleeplock>
    bcache.head.next->prev = b;
    80003b34:	2b893783          	ld	a5,696(s2)
    80003b38:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003b3a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003b3e:	45848493          	addi	s1,s1,1112
    80003b42:	fd349fe3          	bne	s1,s3,80003b20 <binit+0x50>
  }
}
    80003b46:	70a2                	ld	ra,40(sp)
    80003b48:	7402                	ld	s0,32(sp)
    80003b4a:	64e2                	ld	s1,24(sp)
    80003b4c:	6942                	ld	s2,16(sp)
    80003b4e:	69a2                	ld	s3,8(sp)
    80003b50:	6a02                	ld	s4,0(sp)
    80003b52:	6145                	addi	sp,sp,48
    80003b54:	8082                	ret

0000000080003b56 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003b56:	7179                	addi	sp,sp,-48
    80003b58:	f406                	sd	ra,40(sp)
    80003b5a:	f022                	sd	s0,32(sp)
    80003b5c:	ec26                	sd	s1,24(sp)
    80003b5e:	e84a                	sd	s2,16(sp)
    80003b60:	e44e                	sd	s3,8(sp)
    80003b62:	1800                	addi	s0,sp,48
    80003b64:	892a                	mv	s2,a0
    80003b66:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003b68:	00101517          	auipc	a0,0x101
    80003b6c:	2a850513          	addi	a0,a0,680 # 80104e10 <bcache>
    80003b70:	85efd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003b74:	00109497          	auipc	s1,0x109
    80003b78:	5544b483          	ld	s1,1364(s1) # 8010d0c8 <bcache+0x82b8>
    80003b7c:	00109797          	auipc	a5,0x109
    80003b80:	4fc78793          	addi	a5,a5,1276 # 8010d078 <bcache+0x8268>
    80003b84:	02f48b63          	beq	s1,a5,80003bba <bread+0x64>
    80003b88:	873e                	mv	a4,a5
    80003b8a:	a021                	j	80003b92 <bread+0x3c>
    80003b8c:	68a4                	ld	s1,80(s1)
    80003b8e:	02e48663          	beq	s1,a4,80003bba <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003b92:	449c                	lw	a5,8(s1)
    80003b94:	ff279ce3          	bne	a5,s2,80003b8c <bread+0x36>
    80003b98:	44dc                	lw	a5,12(s1)
    80003b9a:	ff3799e3          	bne	a5,s3,80003b8c <bread+0x36>
      b->refcnt++;
    80003b9e:	40bc                	lw	a5,64(s1)
    80003ba0:	2785                	addiw	a5,a5,1
    80003ba2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003ba4:	00101517          	auipc	a0,0x101
    80003ba8:	26c50513          	addi	a0,a0,620 # 80104e10 <bcache>
    80003bac:	8bafd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80003bb0:	01048513          	addi	a0,s1,16
    80003bb4:	2d4010ef          	jal	80004e88 <acquiresleep>
      return b;
    80003bb8:	a889                	j	80003c0a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003bba:	00109497          	auipc	s1,0x109
    80003bbe:	5064b483          	ld	s1,1286(s1) # 8010d0c0 <bcache+0x82b0>
    80003bc2:	00109797          	auipc	a5,0x109
    80003bc6:	4b678793          	addi	a5,a5,1206 # 8010d078 <bcache+0x8268>
    80003bca:	00f48863          	beq	s1,a5,80003bda <bread+0x84>
    80003bce:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003bd0:	40bc                	lw	a5,64(s1)
    80003bd2:	cb91                	beqz	a5,80003be6 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003bd4:	64a4                	ld	s1,72(s1)
    80003bd6:	fee49de3          	bne	s1,a4,80003bd0 <bread+0x7a>
  panic("bget: no buffers");
    80003bda:	00006517          	auipc	a0,0x6
    80003bde:	a9e50513          	addi	a0,a0,-1378 # 80009678 <etext+0x678>
    80003be2:	bfffc0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80003be6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003bea:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003bee:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003bf2:	4785                	li	a5,1
    80003bf4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003bf6:	00101517          	auipc	a0,0x101
    80003bfa:	21a50513          	addi	a0,a0,538 # 80104e10 <bcache>
    80003bfe:	868fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80003c02:	01048513          	addi	a0,s1,16
    80003c06:	282010ef          	jal	80004e88 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003c0a:	409c                	lw	a5,0(s1)
    80003c0c:	cb89                	beqz	a5,80003c1e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003c0e:	8526                	mv	a0,s1
    80003c10:	70a2                	ld	ra,40(sp)
    80003c12:	7402                	ld	s0,32(sp)
    80003c14:	64e2                	ld	s1,24(sp)
    80003c16:	6942                	ld	s2,16(sp)
    80003c18:	69a2                	ld	s3,8(sp)
    80003c1a:	6145                	addi	sp,sp,48
    80003c1c:	8082                	ret
    virtio_disk_rw(b, 0);
    80003c1e:	4581                	li	a1,0
    80003c20:	8526                	mv	a0,s1
    80003c22:	39f020ef          	jal	800067c0 <virtio_disk_rw>
    b->valid = 1;
    80003c26:	4785                	li	a5,1
    80003c28:	c09c                	sw	a5,0(s1)
  return b;
    80003c2a:	b7d5                	j	80003c0e <bread+0xb8>

0000000080003c2c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003c2c:	1101                	addi	sp,sp,-32
    80003c2e:	ec06                	sd	ra,24(sp)
    80003c30:	e822                	sd	s0,16(sp)
    80003c32:	e426                	sd	s1,8(sp)
    80003c34:	1000                	addi	s0,sp,32
    80003c36:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003c38:	0541                	addi	a0,a0,16
    80003c3a:	2cc010ef          	jal	80004f06 <holdingsleep>
    80003c3e:	c911                	beqz	a0,80003c52 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003c40:	4585                	li	a1,1
    80003c42:	8526                	mv	a0,s1
    80003c44:	37d020ef          	jal	800067c0 <virtio_disk_rw>
}
    80003c48:	60e2                	ld	ra,24(sp)
    80003c4a:	6442                	ld	s0,16(sp)
    80003c4c:	64a2                	ld	s1,8(sp)
    80003c4e:	6105                	addi	sp,sp,32
    80003c50:	8082                	ret
    panic("bwrite");
    80003c52:	00006517          	auipc	a0,0x6
    80003c56:	a3e50513          	addi	a0,a0,-1474 # 80009690 <etext+0x690>
    80003c5a:	b87fc0ef          	jal	800007e0 <panic>

0000000080003c5e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003c5e:	1101                	addi	sp,sp,-32
    80003c60:	ec06                	sd	ra,24(sp)
    80003c62:	e822                	sd	s0,16(sp)
    80003c64:	e426                	sd	s1,8(sp)
    80003c66:	e04a                	sd	s2,0(sp)
    80003c68:	1000                	addi	s0,sp,32
    80003c6a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003c6c:	01050913          	addi	s2,a0,16
    80003c70:	854a                	mv	a0,s2
    80003c72:	294010ef          	jal	80004f06 <holdingsleep>
    80003c76:	c135                	beqz	a0,80003cda <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003c78:	854a                	mv	a0,s2
    80003c7a:	254010ef          	jal	80004ece <releasesleep>

  acquire(&bcache.lock);
    80003c7e:	00101517          	auipc	a0,0x101
    80003c82:	19250513          	addi	a0,a0,402 # 80104e10 <bcache>
    80003c86:	f49fc0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80003c8a:	40bc                	lw	a5,64(s1)
    80003c8c:	37fd                	addiw	a5,a5,-1
    80003c8e:	0007871b          	sext.w	a4,a5
    80003c92:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003c94:	e71d                	bnez	a4,80003cc2 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003c96:	68b8                	ld	a4,80(s1)
    80003c98:	64bc                	ld	a5,72(s1)
    80003c9a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003c9c:	68b8                	ld	a4,80(s1)
    80003c9e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003ca0:	00109797          	auipc	a5,0x109
    80003ca4:	17078793          	addi	a5,a5,368 # 8010ce10 <bcache+0x8000>
    80003ca8:	2b87b703          	ld	a4,696(a5)
    80003cac:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003cae:	00109717          	auipc	a4,0x109
    80003cb2:	3ca70713          	addi	a4,a4,970 # 8010d078 <bcache+0x8268>
    80003cb6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003cb8:	2b87b703          	ld	a4,696(a5)
    80003cbc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003cbe:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003cc2:	00101517          	auipc	a0,0x101
    80003cc6:	14e50513          	addi	a0,a0,334 # 80104e10 <bcache>
    80003cca:	f9dfc0ef          	jal	80000c66 <release>
}
    80003cce:	60e2                	ld	ra,24(sp)
    80003cd0:	6442                	ld	s0,16(sp)
    80003cd2:	64a2                	ld	s1,8(sp)
    80003cd4:	6902                	ld	s2,0(sp)
    80003cd6:	6105                	addi	sp,sp,32
    80003cd8:	8082                	ret
    panic("brelse");
    80003cda:	00006517          	auipc	a0,0x6
    80003cde:	9be50513          	addi	a0,a0,-1602 # 80009698 <etext+0x698>
    80003ce2:	afffc0ef          	jal	800007e0 <panic>

0000000080003ce6 <bpin>:

void
bpin(struct buf *b) {
    80003ce6:	1101                	addi	sp,sp,-32
    80003ce8:	ec06                	sd	ra,24(sp)
    80003cea:	e822                	sd	s0,16(sp)
    80003cec:	e426                	sd	s1,8(sp)
    80003cee:	1000                	addi	s0,sp,32
    80003cf0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003cf2:	00101517          	auipc	a0,0x101
    80003cf6:	11e50513          	addi	a0,a0,286 # 80104e10 <bcache>
    80003cfa:	ed5fc0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80003cfe:	40bc                	lw	a5,64(s1)
    80003d00:	2785                	addiw	a5,a5,1
    80003d02:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003d04:	00101517          	auipc	a0,0x101
    80003d08:	10c50513          	addi	a0,a0,268 # 80104e10 <bcache>
    80003d0c:	f5bfc0ef          	jal	80000c66 <release>
}
    80003d10:	60e2                	ld	ra,24(sp)
    80003d12:	6442                	ld	s0,16(sp)
    80003d14:	64a2                	ld	s1,8(sp)
    80003d16:	6105                	addi	sp,sp,32
    80003d18:	8082                	ret

0000000080003d1a <bunpin>:

void
bunpin(struct buf *b) {
    80003d1a:	1101                	addi	sp,sp,-32
    80003d1c:	ec06                	sd	ra,24(sp)
    80003d1e:	e822                	sd	s0,16(sp)
    80003d20:	e426                	sd	s1,8(sp)
    80003d22:	1000                	addi	s0,sp,32
    80003d24:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003d26:	00101517          	auipc	a0,0x101
    80003d2a:	0ea50513          	addi	a0,a0,234 # 80104e10 <bcache>
    80003d2e:	ea1fc0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80003d32:	40bc                	lw	a5,64(s1)
    80003d34:	37fd                	addiw	a5,a5,-1
    80003d36:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003d38:	00101517          	auipc	a0,0x101
    80003d3c:	0d850513          	addi	a0,a0,216 # 80104e10 <bcache>
    80003d40:	f27fc0ef          	jal	80000c66 <release>
}
    80003d44:	60e2                	ld	ra,24(sp)
    80003d46:	6442                	ld	s0,16(sp)
    80003d48:	64a2                	ld	s1,8(sp)
    80003d4a:	6105                	addi	sp,sp,32
    80003d4c:	8082                	ret

0000000080003d4e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003d4e:	1101                	addi	sp,sp,-32
    80003d50:	ec06                	sd	ra,24(sp)
    80003d52:	e822                	sd	s0,16(sp)
    80003d54:	e426                	sd	s1,8(sp)
    80003d56:	e04a                	sd	s2,0(sp)
    80003d58:	1000                	addi	s0,sp,32
    80003d5a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003d5c:	00d5d59b          	srliw	a1,a1,0xd
    80003d60:	00109797          	auipc	a5,0x109
    80003d64:	78c7a783          	lw	a5,1932(a5) # 8010d4ec <sb+0x1c>
    80003d68:	9dbd                	addw	a1,a1,a5
    80003d6a:	dedff0ef          	jal	80003b56 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003d6e:	0074f713          	andi	a4,s1,7
    80003d72:	4785                	li	a5,1
    80003d74:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003d78:	14ce                	slli	s1,s1,0x33
    80003d7a:	90d9                	srli	s1,s1,0x36
    80003d7c:	00950733          	add	a4,a0,s1
    80003d80:	05874703          	lbu	a4,88(a4)
    80003d84:	00e7f6b3          	and	a3,a5,a4
    80003d88:	c29d                	beqz	a3,80003dae <bfree+0x60>
    80003d8a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003d8c:	94aa                	add	s1,s1,a0
    80003d8e:	fff7c793          	not	a5,a5
    80003d92:	8f7d                	and	a4,a4,a5
    80003d94:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003d98:	7f9000ef          	jal	80004d90 <log_write>
  brelse(bp);
    80003d9c:	854a                	mv	a0,s2
    80003d9e:	ec1ff0ef          	jal	80003c5e <brelse>
}
    80003da2:	60e2                	ld	ra,24(sp)
    80003da4:	6442                	ld	s0,16(sp)
    80003da6:	64a2                	ld	s1,8(sp)
    80003da8:	6902                	ld	s2,0(sp)
    80003daa:	6105                	addi	sp,sp,32
    80003dac:	8082                	ret
    panic("freeing free block");
    80003dae:	00006517          	auipc	a0,0x6
    80003db2:	8f250513          	addi	a0,a0,-1806 # 800096a0 <etext+0x6a0>
    80003db6:	a2bfc0ef          	jal	800007e0 <panic>

0000000080003dba <balloc>:
{
    80003dba:	711d                	addi	sp,sp,-96
    80003dbc:	ec86                	sd	ra,88(sp)
    80003dbe:	e8a2                	sd	s0,80(sp)
    80003dc0:	e4a6                	sd	s1,72(sp)
    80003dc2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003dc4:	00109797          	auipc	a5,0x109
    80003dc8:	7107a783          	lw	a5,1808(a5) # 8010d4d4 <sb+0x4>
    80003dcc:	0e078f63          	beqz	a5,80003eca <balloc+0x110>
    80003dd0:	e0ca                	sd	s2,64(sp)
    80003dd2:	fc4e                	sd	s3,56(sp)
    80003dd4:	f852                	sd	s4,48(sp)
    80003dd6:	f456                	sd	s5,40(sp)
    80003dd8:	f05a                	sd	s6,32(sp)
    80003dda:	ec5e                	sd	s7,24(sp)
    80003ddc:	e862                	sd	s8,16(sp)
    80003dde:	e466                	sd	s9,8(sp)
    80003de0:	8baa                	mv	s7,a0
    80003de2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003de4:	00109b17          	auipc	s6,0x109
    80003de8:	6ecb0b13          	addi	s6,s6,1772 # 8010d4d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003dec:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003dee:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003df0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003df2:	6c89                	lui	s9,0x2
    80003df4:	a0b5                	j	80003e60 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003df6:	97ca                	add	a5,a5,s2
    80003df8:	8e55                	or	a2,a2,a3
    80003dfa:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003dfe:	854a                	mv	a0,s2
    80003e00:	791000ef          	jal	80004d90 <log_write>
        brelse(bp);
    80003e04:	854a                	mv	a0,s2
    80003e06:	e59ff0ef          	jal	80003c5e <brelse>
  bp = bread(dev, bno);
    80003e0a:	85a6                	mv	a1,s1
    80003e0c:	855e                	mv	a0,s7
    80003e0e:	d49ff0ef          	jal	80003b56 <bread>
    80003e12:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003e14:	40000613          	li	a2,1024
    80003e18:	4581                	li	a1,0
    80003e1a:	05850513          	addi	a0,a0,88
    80003e1e:	e85fc0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80003e22:	854a                	mv	a0,s2
    80003e24:	76d000ef          	jal	80004d90 <log_write>
  brelse(bp);
    80003e28:	854a                	mv	a0,s2
    80003e2a:	e35ff0ef          	jal	80003c5e <brelse>
}
    80003e2e:	6906                	ld	s2,64(sp)
    80003e30:	79e2                	ld	s3,56(sp)
    80003e32:	7a42                	ld	s4,48(sp)
    80003e34:	7aa2                	ld	s5,40(sp)
    80003e36:	7b02                	ld	s6,32(sp)
    80003e38:	6be2                	ld	s7,24(sp)
    80003e3a:	6c42                	ld	s8,16(sp)
    80003e3c:	6ca2                	ld	s9,8(sp)
}
    80003e3e:	8526                	mv	a0,s1
    80003e40:	60e6                	ld	ra,88(sp)
    80003e42:	6446                	ld	s0,80(sp)
    80003e44:	64a6                	ld	s1,72(sp)
    80003e46:	6125                	addi	sp,sp,96
    80003e48:	8082                	ret
    brelse(bp);
    80003e4a:	854a                	mv	a0,s2
    80003e4c:	e13ff0ef          	jal	80003c5e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003e50:	015c87bb          	addw	a5,s9,s5
    80003e54:	00078a9b          	sext.w	s5,a5
    80003e58:	004b2703          	lw	a4,4(s6)
    80003e5c:	04eaff63          	bgeu	s5,a4,80003eba <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003e60:	41fad79b          	sraiw	a5,s5,0x1f
    80003e64:	0137d79b          	srliw	a5,a5,0x13
    80003e68:	015787bb          	addw	a5,a5,s5
    80003e6c:	40d7d79b          	sraiw	a5,a5,0xd
    80003e70:	01cb2583          	lw	a1,28(s6)
    80003e74:	9dbd                	addw	a1,a1,a5
    80003e76:	855e                	mv	a0,s7
    80003e78:	cdfff0ef          	jal	80003b56 <bread>
    80003e7c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003e7e:	004b2503          	lw	a0,4(s6)
    80003e82:	000a849b          	sext.w	s1,s5
    80003e86:	8762                	mv	a4,s8
    80003e88:	fca4f1e3          	bgeu	s1,a0,80003e4a <balloc+0x90>
      m = 1 << (bi % 8);
    80003e8c:	00777693          	andi	a3,a4,7
    80003e90:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003e94:	41f7579b          	sraiw	a5,a4,0x1f
    80003e98:	01d7d79b          	srliw	a5,a5,0x1d
    80003e9c:	9fb9                	addw	a5,a5,a4
    80003e9e:	4037d79b          	sraiw	a5,a5,0x3
    80003ea2:	00f90633          	add	a2,s2,a5
    80003ea6:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003eaa:	00c6f5b3          	and	a1,a3,a2
    80003eae:	d5a1                	beqz	a1,80003df6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003eb0:	2705                	addiw	a4,a4,1
    80003eb2:	2485                	addiw	s1,s1,1
    80003eb4:	fd471ae3          	bne	a4,s4,80003e88 <balloc+0xce>
    80003eb8:	bf49                	j	80003e4a <balloc+0x90>
    80003eba:	6906                	ld	s2,64(sp)
    80003ebc:	79e2                	ld	s3,56(sp)
    80003ebe:	7a42                	ld	s4,48(sp)
    80003ec0:	7aa2                	ld	s5,40(sp)
    80003ec2:	7b02                	ld	s6,32(sp)
    80003ec4:	6be2                	ld	s7,24(sp)
    80003ec6:	6c42                	ld	s8,16(sp)
    80003ec8:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003eca:	00005517          	auipc	a0,0x5
    80003ece:	7ee50513          	addi	a0,a0,2030 # 800096b8 <etext+0x6b8>
    80003ed2:	e28fc0ef          	jal	800004fa <printf>
  return 0;
    80003ed6:	4481                	li	s1,0
    80003ed8:	b79d                	j	80003e3e <balloc+0x84>

0000000080003eda <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003eda:	7179                	addi	sp,sp,-48
    80003edc:	f406                	sd	ra,40(sp)
    80003ede:	f022                	sd	s0,32(sp)
    80003ee0:	ec26                	sd	s1,24(sp)
    80003ee2:	e84a                	sd	s2,16(sp)
    80003ee4:	e44e                	sd	s3,8(sp)
    80003ee6:	1800                	addi	s0,sp,48
    80003ee8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003eea:	47ad                	li	a5,11
    80003eec:	02b7e663          	bltu	a5,a1,80003f18 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003ef0:	02059793          	slli	a5,a1,0x20
    80003ef4:	01e7d593          	srli	a1,a5,0x1e
    80003ef8:	00b504b3          	add	s1,a0,a1
    80003efc:	0504a903          	lw	s2,80(s1)
    80003f00:	06091a63          	bnez	s2,80003f74 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003f04:	4108                	lw	a0,0(a0)
    80003f06:	eb5ff0ef          	jal	80003dba <balloc>
    80003f0a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003f0e:	06090363          	beqz	s2,80003f74 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003f12:	0524a823          	sw	s2,80(s1)
    80003f16:	a8b9                	j	80003f74 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003f18:	ff45849b          	addiw	s1,a1,-12
    80003f1c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003f20:	0ff00793          	li	a5,255
    80003f24:	06e7ee63          	bltu	a5,a4,80003fa0 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003f28:	08052903          	lw	s2,128(a0)
    80003f2c:	00091d63          	bnez	s2,80003f46 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003f30:	4108                	lw	a0,0(a0)
    80003f32:	e89ff0ef          	jal	80003dba <balloc>
    80003f36:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003f3a:	02090d63          	beqz	s2,80003f74 <bmap+0x9a>
    80003f3e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003f40:	0929a023          	sw	s2,128(s3)
    80003f44:	a011                	j	80003f48 <bmap+0x6e>
    80003f46:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003f48:	85ca                	mv	a1,s2
    80003f4a:	0009a503          	lw	a0,0(s3)
    80003f4e:	c09ff0ef          	jal	80003b56 <bread>
    80003f52:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003f54:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003f58:	02049713          	slli	a4,s1,0x20
    80003f5c:	01e75593          	srli	a1,a4,0x1e
    80003f60:	00b784b3          	add	s1,a5,a1
    80003f64:	0004a903          	lw	s2,0(s1)
    80003f68:	00090e63          	beqz	s2,80003f84 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003f6c:	8552                	mv	a0,s4
    80003f6e:	cf1ff0ef          	jal	80003c5e <brelse>
    return addr;
    80003f72:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003f74:	854a                	mv	a0,s2
    80003f76:	70a2                	ld	ra,40(sp)
    80003f78:	7402                	ld	s0,32(sp)
    80003f7a:	64e2                	ld	s1,24(sp)
    80003f7c:	6942                	ld	s2,16(sp)
    80003f7e:	69a2                	ld	s3,8(sp)
    80003f80:	6145                	addi	sp,sp,48
    80003f82:	8082                	ret
      addr = balloc(ip->dev);
    80003f84:	0009a503          	lw	a0,0(s3)
    80003f88:	e33ff0ef          	jal	80003dba <balloc>
    80003f8c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003f90:	fc090ee3          	beqz	s2,80003f6c <bmap+0x92>
        a[bn] = addr;
    80003f94:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003f98:	8552                	mv	a0,s4
    80003f9a:	5f7000ef          	jal	80004d90 <log_write>
    80003f9e:	b7f9                	j	80003f6c <bmap+0x92>
    80003fa0:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003fa2:	00005517          	auipc	a0,0x5
    80003fa6:	72e50513          	addi	a0,a0,1838 # 800096d0 <etext+0x6d0>
    80003faa:	837fc0ef          	jal	800007e0 <panic>

0000000080003fae <iget>:
{
    80003fae:	7179                	addi	sp,sp,-48
    80003fb0:	f406                	sd	ra,40(sp)
    80003fb2:	f022                	sd	s0,32(sp)
    80003fb4:	ec26                	sd	s1,24(sp)
    80003fb6:	e84a                	sd	s2,16(sp)
    80003fb8:	e44e                	sd	s3,8(sp)
    80003fba:	e052                	sd	s4,0(sp)
    80003fbc:	1800                	addi	s0,sp,48
    80003fbe:	89aa                	mv	s3,a0
    80003fc0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003fc2:	00109517          	auipc	a0,0x109
    80003fc6:	52e50513          	addi	a0,a0,1326 # 8010d4f0 <itable>
    80003fca:	c05fc0ef          	jal	80000bce <acquire>
  empty = 0;
    80003fce:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003fd0:	00109497          	auipc	s1,0x109
    80003fd4:	53848493          	addi	s1,s1,1336 # 8010d508 <itable+0x18>
    80003fd8:	0010b697          	auipc	a3,0x10b
    80003fdc:	fc068693          	addi	a3,a3,-64 # 8010ef98 <log>
    80003fe0:	a039                	j	80003fee <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003fe2:	02090963          	beqz	s2,80004014 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003fe6:	08848493          	addi	s1,s1,136
    80003fea:	02d48863          	beq	s1,a3,8000401a <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003fee:	449c                	lw	a5,8(s1)
    80003ff0:	fef059e3          	blez	a5,80003fe2 <iget+0x34>
    80003ff4:	4098                	lw	a4,0(s1)
    80003ff6:	ff3716e3          	bne	a4,s3,80003fe2 <iget+0x34>
    80003ffa:	40d8                	lw	a4,4(s1)
    80003ffc:	ff4713e3          	bne	a4,s4,80003fe2 <iget+0x34>
      ip->ref++;
    80004000:	2785                	addiw	a5,a5,1
    80004002:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004004:	00109517          	auipc	a0,0x109
    80004008:	4ec50513          	addi	a0,a0,1260 # 8010d4f0 <itable>
    8000400c:	c5bfc0ef          	jal	80000c66 <release>
      return ip;
    80004010:	8926                	mv	s2,s1
    80004012:	a02d                	j	8000403c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004014:	fbe9                	bnez	a5,80003fe6 <iget+0x38>
      empty = ip;
    80004016:	8926                	mv	s2,s1
    80004018:	b7f9                	j	80003fe6 <iget+0x38>
  if(empty == 0)
    8000401a:	02090a63          	beqz	s2,8000404e <iget+0xa0>
  ip->dev = dev;
    8000401e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004022:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004026:	4785                	li	a5,1
    80004028:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000402c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004030:	00109517          	auipc	a0,0x109
    80004034:	4c050513          	addi	a0,a0,1216 # 8010d4f0 <itable>
    80004038:	c2ffc0ef          	jal	80000c66 <release>
}
    8000403c:	854a                	mv	a0,s2
    8000403e:	70a2                	ld	ra,40(sp)
    80004040:	7402                	ld	s0,32(sp)
    80004042:	64e2                	ld	s1,24(sp)
    80004044:	6942                	ld	s2,16(sp)
    80004046:	69a2                	ld	s3,8(sp)
    80004048:	6a02                	ld	s4,0(sp)
    8000404a:	6145                	addi	sp,sp,48
    8000404c:	8082                	ret
    panic("iget: no inodes");
    8000404e:	00005517          	auipc	a0,0x5
    80004052:	69a50513          	addi	a0,a0,1690 # 800096e8 <etext+0x6e8>
    80004056:	f8afc0ef          	jal	800007e0 <panic>

000000008000405a <iinit>:
{
    8000405a:	7179                	addi	sp,sp,-48
    8000405c:	f406                	sd	ra,40(sp)
    8000405e:	f022                	sd	s0,32(sp)
    80004060:	ec26                	sd	s1,24(sp)
    80004062:	e84a                	sd	s2,16(sp)
    80004064:	e44e                	sd	s3,8(sp)
    80004066:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004068:	00005597          	auipc	a1,0x5
    8000406c:	69058593          	addi	a1,a1,1680 # 800096f8 <etext+0x6f8>
    80004070:	00109517          	auipc	a0,0x109
    80004074:	48050513          	addi	a0,a0,1152 # 8010d4f0 <itable>
    80004078:	ad7fc0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000407c:	00109497          	auipc	s1,0x109
    80004080:	49c48493          	addi	s1,s1,1180 # 8010d518 <itable+0x28>
    80004084:	0010b997          	auipc	s3,0x10b
    80004088:	f2498993          	addi	s3,s3,-220 # 8010efa8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000408c:	00005917          	auipc	s2,0x5
    80004090:	67490913          	addi	s2,s2,1652 # 80009700 <etext+0x700>
    80004094:	85ca                	mv	a1,s2
    80004096:	8526                	mv	a0,s1
    80004098:	5bb000ef          	jal	80004e52 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000409c:	08848493          	addi	s1,s1,136
    800040a0:	ff349ae3          	bne	s1,s3,80004094 <iinit+0x3a>
}
    800040a4:	70a2                	ld	ra,40(sp)
    800040a6:	7402                	ld	s0,32(sp)
    800040a8:	64e2                	ld	s1,24(sp)
    800040aa:	6942                	ld	s2,16(sp)
    800040ac:	69a2                	ld	s3,8(sp)
    800040ae:	6145                	addi	sp,sp,48
    800040b0:	8082                	ret

00000000800040b2 <ialloc>:
{
    800040b2:	7139                	addi	sp,sp,-64
    800040b4:	fc06                	sd	ra,56(sp)
    800040b6:	f822                	sd	s0,48(sp)
    800040b8:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800040ba:	00109717          	auipc	a4,0x109
    800040be:	42272703          	lw	a4,1058(a4) # 8010d4dc <sb+0xc>
    800040c2:	4785                	li	a5,1
    800040c4:	06e7f063          	bgeu	a5,a4,80004124 <ialloc+0x72>
    800040c8:	f426                	sd	s1,40(sp)
    800040ca:	f04a                	sd	s2,32(sp)
    800040cc:	ec4e                	sd	s3,24(sp)
    800040ce:	e852                	sd	s4,16(sp)
    800040d0:	e456                	sd	s5,8(sp)
    800040d2:	e05a                	sd	s6,0(sp)
    800040d4:	8aaa                	mv	s5,a0
    800040d6:	8b2e                	mv	s6,a1
    800040d8:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800040da:	00109a17          	auipc	s4,0x109
    800040de:	3f6a0a13          	addi	s4,s4,1014 # 8010d4d0 <sb>
    800040e2:	00495593          	srli	a1,s2,0x4
    800040e6:	018a2783          	lw	a5,24(s4)
    800040ea:	9dbd                	addw	a1,a1,a5
    800040ec:	8556                	mv	a0,s5
    800040ee:	a69ff0ef          	jal	80003b56 <bread>
    800040f2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800040f4:	05850993          	addi	s3,a0,88
    800040f8:	00f97793          	andi	a5,s2,15
    800040fc:	079a                	slli	a5,a5,0x6
    800040fe:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004100:	00099783          	lh	a5,0(s3)
    80004104:	cb9d                	beqz	a5,8000413a <ialloc+0x88>
    brelse(bp);
    80004106:	b59ff0ef          	jal	80003c5e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000410a:	0905                	addi	s2,s2,1
    8000410c:	00ca2703          	lw	a4,12(s4)
    80004110:	0009079b          	sext.w	a5,s2
    80004114:	fce7e7e3          	bltu	a5,a4,800040e2 <ialloc+0x30>
    80004118:	74a2                	ld	s1,40(sp)
    8000411a:	7902                	ld	s2,32(sp)
    8000411c:	69e2                	ld	s3,24(sp)
    8000411e:	6a42                	ld	s4,16(sp)
    80004120:	6aa2                	ld	s5,8(sp)
    80004122:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80004124:	00005517          	auipc	a0,0x5
    80004128:	5e450513          	addi	a0,a0,1508 # 80009708 <etext+0x708>
    8000412c:	bcefc0ef          	jal	800004fa <printf>
  return 0;
    80004130:	4501                	li	a0,0
}
    80004132:	70e2                	ld	ra,56(sp)
    80004134:	7442                	ld	s0,48(sp)
    80004136:	6121                	addi	sp,sp,64
    80004138:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000413a:	04000613          	li	a2,64
    8000413e:	4581                	li	a1,0
    80004140:	854e                	mv	a0,s3
    80004142:	b61fc0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80004146:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000414a:	8526                	mv	a0,s1
    8000414c:	445000ef          	jal	80004d90 <log_write>
      brelse(bp);
    80004150:	8526                	mv	a0,s1
    80004152:	b0dff0ef          	jal	80003c5e <brelse>
      return iget(dev, inum);
    80004156:	0009059b          	sext.w	a1,s2
    8000415a:	8556                	mv	a0,s5
    8000415c:	e53ff0ef          	jal	80003fae <iget>
    80004160:	74a2                	ld	s1,40(sp)
    80004162:	7902                	ld	s2,32(sp)
    80004164:	69e2                	ld	s3,24(sp)
    80004166:	6a42                	ld	s4,16(sp)
    80004168:	6aa2                	ld	s5,8(sp)
    8000416a:	6b02                	ld	s6,0(sp)
    8000416c:	b7d9                	j	80004132 <ialloc+0x80>

000000008000416e <iupdate>:
{
    8000416e:	1101                	addi	sp,sp,-32
    80004170:	ec06                	sd	ra,24(sp)
    80004172:	e822                	sd	s0,16(sp)
    80004174:	e426                	sd	s1,8(sp)
    80004176:	e04a                	sd	s2,0(sp)
    80004178:	1000                	addi	s0,sp,32
    8000417a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000417c:	415c                	lw	a5,4(a0)
    8000417e:	0047d79b          	srliw	a5,a5,0x4
    80004182:	00109597          	auipc	a1,0x109
    80004186:	3665a583          	lw	a1,870(a1) # 8010d4e8 <sb+0x18>
    8000418a:	9dbd                	addw	a1,a1,a5
    8000418c:	4108                	lw	a0,0(a0)
    8000418e:	9c9ff0ef          	jal	80003b56 <bread>
    80004192:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004194:	05850793          	addi	a5,a0,88
    80004198:	40d8                	lw	a4,4(s1)
    8000419a:	8b3d                	andi	a4,a4,15
    8000419c:	071a                	slli	a4,a4,0x6
    8000419e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800041a0:	04449703          	lh	a4,68(s1)
    800041a4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800041a8:	04649703          	lh	a4,70(s1)
    800041ac:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800041b0:	04849703          	lh	a4,72(s1)
    800041b4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800041b8:	04a49703          	lh	a4,74(s1)
    800041bc:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800041c0:	44f8                	lw	a4,76(s1)
    800041c2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800041c4:	03400613          	li	a2,52
    800041c8:	05048593          	addi	a1,s1,80
    800041cc:	00c78513          	addi	a0,a5,12
    800041d0:	b2ffc0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800041d4:	854a                	mv	a0,s2
    800041d6:	3bb000ef          	jal	80004d90 <log_write>
  brelse(bp);
    800041da:	854a                	mv	a0,s2
    800041dc:	a83ff0ef          	jal	80003c5e <brelse>
}
    800041e0:	60e2                	ld	ra,24(sp)
    800041e2:	6442                	ld	s0,16(sp)
    800041e4:	64a2                	ld	s1,8(sp)
    800041e6:	6902                	ld	s2,0(sp)
    800041e8:	6105                	addi	sp,sp,32
    800041ea:	8082                	ret

00000000800041ec <idup>:
{
    800041ec:	1101                	addi	sp,sp,-32
    800041ee:	ec06                	sd	ra,24(sp)
    800041f0:	e822                	sd	s0,16(sp)
    800041f2:	e426                	sd	s1,8(sp)
    800041f4:	1000                	addi	s0,sp,32
    800041f6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800041f8:	00109517          	auipc	a0,0x109
    800041fc:	2f850513          	addi	a0,a0,760 # 8010d4f0 <itable>
    80004200:	9cffc0ef          	jal	80000bce <acquire>
  ip->ref++;
    80004204:	449c                	lw	a5,8(s1)
    80004206:	2785                	addiw	a5,a5,1
    80004208:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000420a:	00109517          	auipc	a0,0x109
    8000420e:	2e650513          	addi	a0,a0,742 # 8010d4f0 <itable>
    80004212:	a55fc0ef          	jal	80000c66 <release>
}
    80004216:	8526                	mv	a0,s1
    80004218:	60e2                	ld	ra,24(sp)
    8000421a:	6442                	ld	s0,16(sp)
    8000421c:	64a2                	ld	s1,8(sp)
    8000421e:	6105                	addi	sp,sp,32
    80004220:	8082                	ret

0000000080004222 <ilock>:
{
    80004222:	1101                	addi	sp,sp,-32
    80004224:	ec06                	sd	ra,24(sp)
    80004226:	e822                	sd	s0,16(sp)
    80004228:	e426                	sd	s1,8(sp)
    8000422a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000422c:	cd19                	beqz	a0,8000424a <ilock+0x28>
    8000422e:	84aa                	mv	s1,a0
    80004230:	451c                	lw	a5,8(a0)
    80004232:	00f05c63          	blez	a5,8000424a <ilock+0x28>
  acquiresleep(&ip->lock);
    80004236:	0541                	addi	a0,a0,16
    80004238:	451000ef          	jal	80004e88 <acquiresleep>
  if(ip->valid == 0){
    8000423c:	40bc                	lw	a5,64(s1)
    8000423e:	cf89                	beqz	a5,80004258 <ilock+0x36>
}
    80004240:	60e2                	ld	ra,24(sp)
    80004242:	6442                	ld	s0,16(sp)
    80004244:	64a2                	ld	s1,8(sp)
    80004246:	6105                	addi	sp,sp,32
    80004248:	8082                	ret
    8000424a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000424c:	00005517          	auipc	a0,0x5
    80004250:	4d450513          	addi	a0,a0,1236 # 80009720 <etext+0x720>
    80004254:	d8cfc0ef          	jal	800007e0 <panic>
    80004258:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000425a:	40dc                	lw	a5,4(s1)
    8000425c:	0047d79b          	srliw	a5,a5,0x4
    80004260:	00109597          	auipc	a1,0x109
    80004264:	2885a583          	lw	a1,648(a1) # 8010d4e8 <sb+0x18>
    80004268:	9dbd                	addw	a1,a1,a5
    8000426a:	4088                	lw	a0,0(s1)
    8000426c:	8ebff0ef          	jal	80003b56 <bread>
    80004270:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004272:	05850593          	addi	a1,a0,88
    80004276:	40dc                	lw	a5,4(s1)
    80004278:	8bbd                	andi	a5,a5,15
    8000427a:	079a                	slli	a5,a5,0x6
    8000427c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000427e:	00059783          	lh	a5,0(a1)
    80004282:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004286:	00259783          	lh	a5,2(a1)
    8000428a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000428e:	00459783          	lh	a5,4(a1)
    80004292:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004296:	00659783          	lh	a5,6(a1)
    8000429a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000429e:	459c                	lw	a5,8(a1)
    800042a0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800042a2:	03400613          	li	a2,52
    800042a6:	05b1                	addi	a1,a1,12
    800042a8:	05048513          	addi	a0,s1,80
    800042ac:	a53fc0ef          	jal	80000cfe <memmove>
    brelse(bp);
    800042b0:	854a                	mv	a0,s2
    800042b2:	9adff0ef          	jal	80003c5e <brelse>
    ip->valid = 1;
    800042b6:	4785                	li	a5,1
    800042b8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800042ba:	04449783          	lh	a5,68(s1)
    800042be:	c399                	beqz	a5,800042c4 <ilock+0xa2>
    800042c0:	6902                	ld	s2,0(sp)
    800042c2:	bfbd                	j	80004240 <ilock+0x1e>
      panic("ilock: no type");
    800042c4:	00005517          	auipc	a0,0x5
    800042c8:	46450513          	addi	a0,a0,1124 # 80009728 <etext+0x728>
    800042cc:	d14fc0ef          	jal	800007e0 <panic>

00000000800042d0 <iunlock>:
{
    800042d0:	1101                	addi	sp,sp,-32
    800042d2:	ec06                	sd	ra,24(sp)
    800042d4:	e822                	sd	s0,16(sp)
    800042d6:	e426                	sd	s1,8(sp)
    800042d8:	e04a                	sd	s2,0(sp)
    800042da:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800042dc:	c505                	beqz	a0,80004304 <iunlock+0x34>
    800042de:	84aa                	mv	s1,a0
    800042e0:	01050913          	addi	s2,a0,16
    800042e4:	854a                	mv	a0,s2
    800042e6:	421000ef          	jal	80004f06 <holdingsleep>
    800042ea:	cd09                	beqz	a0,80004304 <iunlock+0x34>
    800042ec:	449c                	lw	a5,8(s1)
    800042ee:	00f05b63          	blez	a5,80004304 <iunlock+0x34>
  releasesleep(&ip->lock);
    800042f2:	854a                	mv	a0,s2
    800042f4:	3db000ef          	jal	80004ece <releasesleep>
}
    800042f8:	60e2                	ld	ra,24(sp)
    800042fa:	6442                	ld	s0,16(sp)
    800042fc:	64a2                	ld	s1,8(sp)
    800042fe:	6902                	ld	s2,0(sp)
    80004300:	6105                	addi	sp,sp,32
    80004302:	8082                	ret
    panic("iunlock");
    80004304:	00005517          	auipc	a0,0x5
    80004308:	43450513          	addi	a0,a0,1076 # 80009738 <etext+0x738>
    8000430c:	cd4fc0ef          	jal	800007e0 <panic>

0000000080004310 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004310:	7179                	addi	sp,sp,-48
    80004312:	f406                	sd	ra,40(sp)
    80004314:	f022                	sd	s0,32(sp)
    80004316:	ec26                	sd	s1,24(sp)
    80004318:	e84a                	sd	s2,16(sp)
    8000431a:	e44e                	sd	s3,8(sp)
    8000431c:	1800                	addi	s0,sp,48
    8000431e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004320:	05050493          	addi	s1,a0,80
    80004324:	08050913          	addi	s2,a0,128
    80004328:	a021                	j	80004330 <itrunc+0x20>
    8000432a:	0491                	addi	s1,s1,4
    8000432c:	01248b63          	beq	s1,s2,80004342 <itrunc+0x32>
    if(ip->addrs[i]){
    80004330:	408c                	lw	a1,0(s1)
    80004332:	dde5                	beqz	a1,8000432a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004334:	0009a503          	lw	a0,0(s3)
    80004338:	a17ff0ef          	jal	80003d4e <bfree>
      ip->addrs[i] = 0;
    8000433c:	0004a023          	sw	zero,0(s1)
    80004340:	b7ed                	j	8000432a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004342:	0809a583          	lw	a1,128(s3)
    80004346:	ed89                	bnez	a1,80004360 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004348:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000434c:	854e                	mv	a0,s3
    8000434e:	e21ff0ef          	jal	8000416e <iupdate>
}
    80004352:	70a2                	ld	ra,40(sp)
    80004354:	7402                	ld	s0,32(sp)
    80004356:	64e2                	ld	s1,24(sp)
    80004358:	6942                	ld	s2,16(sp)
    8000435a:	69a2                	ld	s3,8(sp)
    8000435c:	6145                	addi	sp,sp,48
    8000435e:	8082                	ret
    80004360:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004362:	0009a503          	lw	a0,0(s3)
    80004366:	ff0ff0ef          	jal	80003b56 <bread>
    8000436a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000436c:	05850493          	addi	s1,a0,88
    80004370:	45850913          	addi	s2,a0,1112
    80004374:	a021                	j	8000437c <itrunc+0x6c>
    80004376:	0491                	addi	s1,s1,4
    80004378:	01248963          	beq	s1,s2,8000438a <itrunc+0x7a>
      if(a[j])
    8000437c:	408c                	lw	a1,0(s1)
    8000437e:	dde5                	beqz	a1,80004376 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80004380:	0009a503          	lw	a0,0(s3)
    80004384:	9cbff0ef          	jal	80003d4e <bfree>
    80004388:	b7fd                	j	80004376 <itrunc+0x66>
    brelse(bp);
    8000438a:	8552                	mv	a0,s4
    8000438c:	8d3ff0ef          	jal	80003c5e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004390:	0809a583          	lw	a1,128(s3)
    80004394:	0009a503          	lw	a0,0(s3)
    80004398:	9b7ff0ef          	jal	80003d4e <bfree>
    ip->addrs[NDIRECT] = 0;
    8000439c:	0809a023          	sw	zero,128(s3)
    800043a0:	6a02                	ld	s4,0(sp)
    800043a2:	b75d                	j	80004348 <itrunc+0x38>

00000000800043a4 <iput>:
{
    800043a4:	1101                	addi	sp,sp,-32
    800043a6:	ec06                	sd	ra,24(sp)
    800043a8:	e822                	sd	s0,16(sp)
    800043aa:	e426                	sd	s1,8(sp)
    800043ac:	1000                	addi	s0,sp,32
    800043ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800043b0:	00109517          	auipc	a0,0x109
    800043b4:	14050513          	addi	a0,a0,320 # 8010d4f0 <itable>
    800043b8:	817fc0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043bc:	4498                	lw	a4,8(s1)
    800043be:	4785                	li	a5,1
    800043c0:	02f70063          	beq	a4,a5,800043e0 <iput+0x3c>
  ip->ref--;
    800043c4:	449c                	lw	a5,8(s1)
    800043c6:	37fd                	addiw	a5,a5,-1
    800043c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800043ca:	00109517          	auipc	a0,0x109
    800043ce:	12650513          	addi	a0,a0,294 # 8010d4f0 <itable>
    800043d2:	895fc0ef          	jal	80000c66 <release>
}
    800043d6:	60e2                	ld	ra,24(sp)
    800043d8:	6442                	ld	s0,16(sp)
    800043da:	64a2                	ld	s1,8(sp)
    800043dc:	6105                	addi	sp,sp,32
    800043de:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043e0:	40bc                	lw	a5,64(s1)
    800043e2:	d3ed                	beqz	a5,800043c4 <iput+0x20>
    800043e4:	04a49783          	lh	a5,74(s1)
    800043e8:	fff1                	bnez	a5,800043c4 <iput+0x20>
    800043ea:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800043ec:	01048913          	addi	s2,s1,16
    800043f0:	854a                	mv	a0,s2
    800043f2:	297000ef          	jal	80004e88 <acquiresleep>
    release(&itable.lock);
    800043f6:	00109517          	auipc	a0,0x109
    800043fa:	0fa50513          	addi	a0,a0,250 # 8010d4f0 <itable>
    800043fe:	869fc0ef          	jal	80000c66 <release>
    itrunc(ip);
    80004402:	8526                	mv	a0,s1
    80004404:	f0dff0ef          	jal	80004310 <itrunc>
    ip->type = 0;
    80004408:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000440c:	8526                	mv	a0,s1
    8000440e:	d61ff0ef          	jal	8000416e <iupdate>
    ip->valid = 0;
    80004412:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004416:	854a                	mv	a0,s2
    80004418:	2b7000ef          	jal	80004ece <releasesleep>
    acquire(&itable.lock);
    8000441c:	00109517          	auipc	a0,0x109
    80004420:	0d450513          	addi	a0,a0,212 # 8010d4f0 <itable>
    80004424:	faafc0ef          	jal	80000bce <acquire>
    80004428:	6902                	ld	s2,0(sp)
    8000442a:	bf69                	j	800043c4 <iput+0x20>

000000008000442c <iunlockput>:
{
    8000442c:	1101                	addi	sp,sp,-32
    8000442e:	ec06                	sd	ra,24(sp)
    80004430:	e822                	sd	s0,16(sp)
    80004432:	e426                	sd	s1,8(sp)
    80004434:	1000                	addi	s0,sp,32
    80004436:	84aa                	mv	s1,a0
  iunlock(ip);
    80004438:	e99ff0ef          	jal	800042d0 <iunlock>
  iput(ip);
    8000443c:	8526                	mv	a0,s1
    8000443e:	f67ff0ef          	jal	800043a4 <iput>
}
    80004442:	60e2                	ld	ra,24(sp)
    80004444:	6442                	ld	s0,16(sp)
    80004446:	64a2                	ld	s1,8(sp)
    80004448:	6105                	addi	sp,sp,32
    8000444a:	8082                	ret

000000008000444c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000444c:	00109717          	auipc	a4,0x109
    80004450:	09072703          	lw	a4,144(a4) # 8010d4dc <sb+0xc>
    80004454:	4785                	li	a5,1
    80004456:	0ae7ff63          	bgeu	a5,a4,80004514 <ireclaim+0xc8>
{
    8000445a:	7139                	addi	sp,sp,-64
    8000445c:	fc06                	sd	ra,56(sp)
    8000445e:	f822                	sd	s0,48(sp)
    80004460:	f426                	sd	s1,40(sp)
    80004462:	f04a                	sd	s2,32(sp)
    80004464:	ec4e                	sd	s3,24(sp)
    80004466:	e852                	sd	s4,16(sp)
    80004468:	e456                	sd	s5,8(sp)
    8000446a:	e05a                	sd	s6,0(sp)
    8000446c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000446e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004470:	00050a1b          	sext.w	s4,a0
    80004474:	00109a97          	auipc	s5,0x109
    80004478:	05ca8a93          	addi	s5,s5,92 # 8010d4d0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000447c:	00005b17          	auipc	s6,0x5
    80004480:	2c4b0b13          	addi	s6,s6,708 # 80009740 <etext+0x740>
    80004484:	a099                	j	800044ca <ireclaim+0x7e>
    80004486:	85ce                	mv	a1,s3
    80004488:	855a                	mv	a0,s6
    8000448a:	870fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    8000448e:	85ce                	mv	a1,s3
    80004490:	8552                	mv	a0,s4
    80004492:	b1dff0ef          	jal	80003fae <iget>
    80004496:	89aa                	mv	s3,a0
    brelse(bp);
    80004498:	854a                	mv	a0,s2
    8000449a:	fc4ff0ef          	jal	80003c5e <brelse>
    if (ip) {
    8000449e:	00098f63          	beqz	s3,800044bc <ireclaim+0x70>
      begin_op();
    800044a2:	76a000ef          	jal	80004c0c <begin_op>
      ilock(ip);
    800044a6:	854e                	mv	a0,s3
    800044a8:	d7bff0ef          	jal	80004222 <ilock>
      iunlock(ip);
    800044ac:	854e                	mv	a0,s3
    800044ae:	e23ff0ef          	jal	800042d0 <iunlock>
      iput(ip);
    800044b2:	854e                	mv	a0,s3
    800044b4:	ef1ff0ef          	jal	800043a4 <iput>
      end_op();
    800044b8:	7be000ef          	jal	80004c76 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800044bc:	0485                	addi	s1,s1,1
    800044be:	00caa703          	lw	a4,12(s5)
    800044c2:	0004879b          	sext.w	a5,s1
    800044c6:	02e7fd63          	bgeu	a5,a4,80004500 <ireclaim+0xb4>
    800044ca:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800044ce:	0044d593          	srli	a1,s1,0x4
    800044d2:	018aa783          	lw	a5,24(s5)
    800044d6:	9dbd                	addw	a1,a1,a5
    800044d8:	8552                	mv	a0,s4
    800044da:	e7cff0ef          	jal	80003b56 <bread>
    800044de:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800044e0:	05850793          	addi	a5,a0,88
    800044e4:	00f9f713          	andi	a4,s3,15
    800044e8:	071a                	slli	a4,a4,0x6
    800044ea:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800044ec:	00079703          	lh	a4,0(a5)
    800044f0:	c701                	beqz	a4,800044f8 <ireclaim+0xac>
    800044f2:	00679783          	lh	a5,6(a5)
    800044f6:	dbc1                	beqz	a5,80004486 <ireclaim+0x3a>
    brelse(bp);
    800044f8:	854a                	mv	a0,s2
    800044fa:	f64ff0ef          	jal	80003c5e <brelse>
    if (ip) {
    800044fe:	bf7d                	j	800044bc <ireclaim+0x70>
}
    80004500:	70e2                	ld	ra,56(sp)
    80004502:	7442                	ld	s0,48(sp)
    80004504:	74a2                	ld	s1,40(sp)
    80004506:	7902                	ld	s2,32(sp)
    80004508:	69e2                	ld	s3,24(sp)
    8000450a:	6a42                	ld	s4,16(sp)
    8000450c:	6aa2                	ld	s5,8(sp)
    8000450e:	6b02                	ld	s6,0(sp)
    80004510:	6121                	addi	sp,sp,64
    80004512:	8082                	ret
    80004514:	8082                	ret

0000000080004516 <fsinit>:
fsinit(int dev) {
    80004516:	7179                	addi	sp,sp,-48
    80004518:	f406                	sd	ra,40(sp)
    8000451a:	f022                	sd	s0,32(sp)
    8000451c:	ec26                	sd	s1,24(sp)
    8000451e:	e84a                	sd	s2,16(sp)
    80004520:	e44e                	sd	s3,8(sp)
    80004522:	1800                	addi	s0,sp,48
    80004524:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80004526:	4585                	li	a1,1
    80004528:	e2eff0ef          	jal	80003b56 <bread>
    8000452c:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000452e:	00109997          	auipc	s3,0x109
    80004532:	fa298993          	addi	s3,s3,-94 # 8010d4d0 <sb>
    80004536:	02000613          	li	a2,32
    8000453a:	05850593          	addi	a1,a0,88
    8000453e:	854e                	mv	a0,s3
    80004540:	fbefc0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80004544:	854a                	mv	a0,s2
    80004546:	f18ff0ef          	jal	80003c5e <brelse>
  if(sb.magic != FSMAGIC)
    8000454a:	0009a703          	lw	a4,0(s3)
    8000454e:	102037b7          	lui	a5,0x10203
    80004552:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004556:	02f71363          	bne	a4,a5,8000457c <fsinit+0x66>
  initlog(dev, &sb);
    8000455a:	00109597          	auipc	a1,0x109
    8000455e:	f7658593          	addi	a1,a1,-138 # 8010d4d0 <sb>
    80004562:	8526                	mv	a0,s1
    80004564:	62a000ef          	jal	80004b8e <initlog>
  ireclaim(dev);
    80004568:	8526                	mv	a0,s1
    8000456a:	ee3ff0ef          	jal	8000444c <ireclaim>
}
    8000456e:	70a2                	ld	ra,40(sp)
    80004570:	7402                	ld	s0,32(sp)
    80004572:	64e2                	ld	s1,24(sp)
    80004574:	6942                	ld	s2,16(sp)
    80004576:	69a2                	ld	s3,8(sp)
    80004578:	6145                	addi	sp,sp,48
    8000457a:	8082                	ret
    panic("invalid file system");
    8000457c:	00005517          	auipc	a0,0x5
    80004580:	1e450513          	addi	a0,a0,484 # 80009760 <etext+0x760>
    80004584:	a5cfc0ef          	jal	800007e0 <panic>

0000000080004588 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004588:	1141                	addi	sp,sp,-16
    8000458a:	e422                	sd	s0,8(sp)
    8000458c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000458e:	411c                	lw	a5,0(a0)
    80004590:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004592:	415c                	lw	a5,4(a0)
    80004594:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004596:	04451783          	lh	a5,68(a0)
    8000459a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000459e:	04a51783          	lh	a5,74(a0)
    800045a2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800045a6:	04c56783          	lwu	a5,76(a0)
    800045aa:	e99c                	sd	a5,16(a1)
}
    800045ac:	6422                	ld	s0,8(sp)
    800045ae:	0141                	addi	sp,sp,16
    800045b0:	8082                	ret

00000000800045b2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800045b2:	457c                	lw	a5,76(a0)
    800045b4:	0ed7eb63          	bltu	a5,a3,800046aa <readi+0xf8>
{
    800045b8:	7159                	addi	sp,sp,-112
    800045ba:	f486                	sd	ra,104(sp)
    800045bc:	f0a2                	sd	s0,96(sp)
    800045be:	eca6                	sd	s1,88(sp)
    800045c0:	e0d2                	sd	s4,64(sp)
    800045c2:	fc56                	sd	s5,56(sp)
    800045c4:	f85a                	sd	s6,48(sp)
    800045c6:	f45e                	sd	s7,40(sp)
    800045c8:	1880                	addi	s0,sp,112
    800045ca:	8b2a                	mv	s6,a0
    800045cc:	8bae                	mv	s7,a1
    800045ce:	8a32                	mv	s4,a2
    800045d0:	84b6                	mv	s1,a3
    800045d2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800045d4:	9f35                	addw	a4,a4,a3
    return 0;
    800045d6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800045d8:	0cd76063          	bltu	a4,a3,80004698 <readi+0xe6>
    800045dc:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800045de:	00e7f463          	bgeu	a5,a4,800045e6 <readi+0x34>
    n = ip->size - off;
    800045e2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800045e6:	080a8f63          	beqz	s5,80004684 <readi+0xd2>
    800045ea:	e8ca                	sd	s2,80(sp)
    800045ec:	f062                	sd	s8,32(sp)
    800045ee:	ec66                	sd	s9,24(sp)
    800045f0:	e86a                	sd	s10,16(sp)
    800045f2:	e46e                	sd	s11,8(sp)
    800045f4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800045f6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800045fa:	5c7d                	li	s8,-1
    800045fc:	a80d                	j	8000462e <readi+0x7c>
    800045fe:	020d1d93          	slli	s11,s10,0x20
    80004602:	020ddd93          	srli	s11,s11,0x20
    80004606:	05890613          	addi	a2,s2,88
    8000460a:	86ee                	mv	a3,s11
    8000460c:	963a                	add	a2,a2,a4
    8000460e:	85d2                	mv	a1,s4
    80004610:	855e                	mv	a0,s7
    80004612:	b8afe0ef          	jal	8000299c <either_copyout>
    80004616:	05850763          	beq	a0,s8,80004664 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000461a:	854a                	mv	a0,s2
    8000461c:	e42ff0ef          	jal	80003c5e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004620:	013d09bb          	addw	s3,s10,s3
    80004624:	009d04bb          	addw	s1,s10,s1
    80004628:	9a6e                	add	s4,s4,s11
    8000462a:	0559f763          	bgeu	s3,s5,80004678 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000462e:	00a4d59b          	srliw	a1,s1,0xa
    80004632:	855a                	mv	a0,s6
    80004634:	8a7ff0ef          	jal	80003eda <bmap>
    80004638:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000463c:	c5b1                	beqz	a1,80004688 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000463e:	000b2503          	lw	a0,0(s6)
    80004642:	d14ff0ef          	jal	80003b56 <bread>
    80004646:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004648:	3ff4f713          	andi	a4,s1,1023
    8000464c:	40ec87bb          	subw	a5,s9,a4
    80004650:	413a86bb          	subw	a3,s5,s3
    80004654:	8d3e                	mv	s10,a5
    80004656:	2781                	sext.w	a5,a5
    80004658:	0006861b          	sext.w	a2,a3
    8000465c:	faf671e3          	bgeu	a2,a5,800045fe <readi+0x4c>
    80004660:	8d36                	mv	s10,a3
    80004662:	bf71                	j	800045fe <readi+0x4c>
      brelse(bp);
    80004664:	854a                	mv	a0,s2
    80004666:	df8ff0ef          	jal	80003c5e <brelse>
      tot = -1;
    8000466a:	59fd                	li	s3,-1
      break;
    8000466c:	6946                	ld	s2,80(sp)
    8000466e:	7c02                	ld	s8,32(sp)
    80004670:	6ce2                	ld	s9,24(sp)
    80004672:	6d42                	ld	s10,16(sp)
    80004674:	6da2                	ld	s11,8(sp)
    80004676:	a831                	j	80004692 <readi+0xe0>
    80004678:	6946                	ld	s2,80(sp)
    8000467a:	7c02                	ld	s8,32(sp)
    8000467c:	6ce2                	ld	s9,24(sp)
    8000467e:	6d42                	ld	s10,16(sp)
    80004680:	6da2                	ld	s11,8(sp)
    80004682:	a801                	j	80004692 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004684:	89d6                	mv	s3,s5
    80004686:	a031                	j	80004692 <readi+0xe0>
    80004688:	6946                	ld	s2,80(sp)
    8000468a:	7c02                	ld	s8,32(sp)
    8000468c:	6ce2                	ld	s9,24(sp)
    8000468e:	6d42                	ld	s10,16(sp)
    80004690:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004692:	0009851b          	sext.w	a0,s3
    80004696:	69a6                	ld	s3,72(sp)
}
    80004698:	70a6                	ld	ra,104(sp)
    8000469a:	7406                	ld	s0,96(sp)
    8000469c:	64e6                	ld	s1,88(sp)
    8000469e:	6a06                	ld	s4,64(sp)
    800046a0:	7ae2                	ld	s5,56(sp)
    800046a2:	7b42                	ld	s6,48(sp)
    800046a4:	7ba2                	ld	s7,40(sp)
    800046a6:	6165                	addi	sp,sp,112
    800046a8:	8082                	ret
    return 0;
    800046aa:	4501                	li	a0,0
}
    800046ac:	8082                	ret

00000000800046ae <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800046ae:	457c                	lw	a5,76(a0)
    800046b0:	10d7e063          	bltu	a5,a3,800047b0 <writei+0x102>
{
    800046b4:	7159                	addi	sp,sp,-112
    800046b6:	f486                	sd	ra,104(sp)
    800046b8:	f0a2                	sd	s0,96(sp)
    800046ba:	e8ca                	sd	s2,80(sp)
    800046bc:	e0d2                	sd	s4,64(sp)
    800046be:	fc56                	sd	s5,56(sp)
    800046c0:	f85a                	sd	s6,48(sp)
    800046c2:	f45e                	sd	s7,40(sp)
    800046c4:	1880                	addi	s0,sp,112
    800046c6:	8aaa                	mv	s5,a0
    800046c8:	8bae                	mv	s7,a1
    800046ca:	8a32                	mv	s4,a2
    800046cc:	8936                	mv	s2,a3
    800046ce:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800046d0:	00e687bb          	addw	a5,a3,a4
    800046d4:	0ed7e063          	bltu	a5,a3,800047b4 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800046d8:	00043737          	lui	a4,0x43
    800046dc:	0cf76e63          	bltu	a4,a5,800047b8 <writei+0x10a>
    800046e0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800046e2:	0a0b0f63          	beqz	s6,800047a0 <writei+0xf2>
    800046e6:	eca6                	sd	s1,88(sp)
    800046e8:	f062                	sd	s8,32(sp)
    800046ea:	ec66                	sd	s9,24(sp)
    800046ec:	e86a                	sd	s10,16(sp)
    800046ee:	e46e                	sd	s11,8(sp)
    800046f0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800046f2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800046f6:	5c7d                	li	s8,-1
    800046f8:	a825                	j	80004730 <writei+0x82>
    800046fa:	020d1d93          	slli	s11,s10,0x20
    800046fe:	020ddd93          	srli	s11,s11,0x20
    80004702:	05848513          	addi	a0,s1,88
    80004706:	86ee                	mv	a3,s11
    80004708:	8652                	mv	a2,s4
    8000470a:	85de                	mv	a1,s7
    8000470c:	953a                	add	a0,a0,a4
    8000470e:	ad8fe0ef          	jal	800029e6 <either_copyin>
    80004712:	05850a63          	beq	a0,s8,80004766 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004716:	8526                	mv	a0,s1
    80004718:	678000ef          	jal	80004d90 <log_write>
    brelse(bp);
    8000471c:	8526                	mv	a0,s1
    8000471e:	d40ff0ef          	jal	80003c5e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004722:	013d09bb          	addw	s3,s10,s3
    80004726:	012d093b          	addw	s2,s10,s2
    8000472a:	9a6e                	add	s4,s4,s11
    8000472c:	0569f063          	bgeu	s3,s6,8000476c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004730:	00a9559b          	srliw	a1,s2,0xa
    80004734:	8556                	mv	a0,s5
    80004736:	fa4ff0ef          	jal	80003eda <bmap>
    8000473a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000473e:	c59d                	beqz	a1,8000476c <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004740:	000aa503          	lw	a0,0(s5)
    80004744:	c12ff0ef          	jal	80003b56 <bread>
    80004748:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000474a:	3ff97713          	andi	a4,s2,1023
    8000474e:	40ec87bb          	subw	a5,s9,a4
    80004752:	413b06bb          	subw	a3,s6,s3
    80004756:	8d3e                	mv	s10,a5
    80004758:	2781                	sext.w	a5,a5
    8000475a:	0006861b          	sext.w	a2,a3
    8000475e:	f8f67ee3          	bgeu	a2,a5,800046fa <writei+0x4c>
    80004762:	8d36                	mv	s10,a3
    80004764:	bf59                	j	800046fa <writei+0x4c>
      brelse(bp);
    80004766:	8526                	mv	a0,s1
    80004768:	cf6ff0ef          	jal	80003c5e <brelse>
  }

  if(off > ip->size)
    8000476c:	04caa783          	lw	a5,76(s5)
    80004770:	0327fa63          	bgeu	a5,s2,800047a4 <writei+0xf6>
    ip->size = off;
    80004774:	052aa623          	sw	s2,76(s5)
    80004778:	64e6                	ld	s1,88(sp)
    8000477a:	7c02                	ld	s8,32(sp)
    8000477c:	6ce2                	ld	s9,24(sp)
    8000477e:	6d42                	ld	s10,16(sp)
    80004780:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004782:	8556                	mv	a0,s5
    80004784:	9ebff0ef          	jal	8000416e <iupdate>

  return tot;
    80004788:	0009851b          	sext.w	a0,s3
    8000478c:	69a6                	ld	s3,72(sp)
}
    8000478e:	70a6                	ld	ra,104(sp)
    80004790:	7406                	ld	s0,96(sp)
    80004792:	6946                	ld	s2,80(sp)
    80004794:	6a06                	ld	s4,64(sp)
    80004796:	7ae2                	ld	s5,56(sp)
    80004798:	7b42                	ld	s6,48(sp)
    8000479a:	7ba2                	ld	s7,40(sp)
    8000479c:	6165                	addi	sp,sp,112
    8000479e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800047a0:	89da                	mv	s3,s6
    800047a2:	b7c5                	j	80004782 <writei+0xd4>
    800047a4:	64e6                	ld	s1,88(sp)
    800047a6:	7c02                	ld	s8,32(sp)
    800047a8:	6ce2                	ld	s9,24(sp)
    800047aa:	6d42                	ld	s10,16(sp)
    800047ac:	6da2                	ld	s11,8(sp)
    800047ae:	bfd1                	j	80004782 <writei+0xd4>
    return -1;
    800047b0:	557d                	li	a0,-1
}
    800047b2:	8082                	ret
    return -1;
    800047b4:	557d                	li	a0,-1
    800047b6:	bfe1                	j	8000478e <writei+0xe0>
    return -1;
    800047b8:	557d                	li	a0,-1
    800047ba:	bfd1                	j	8000478e <writei+0xe0>

00000000800047bc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800047bc:	1141                	addi	sp,sp,-16
    800047be:	e406                	sd	ra,8(sp)
    800047c0:	e022                	sd	s0,0(sp)
    800047c2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800047c4:	4639                	li	a2,14
    800047c6:	da8fc0ef          	jal	80000d6e <strncmp>
}
    800047ca:	60a2                	ld	ra,8(sp)
    800047cc:	6402                	ld	s0,0(sp)
    800047ce:	0141                	addi	sp,sp,16
    800047d0:	8082                	ret

00000000800047d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800047d2:	7139                	addi	sp,sp,-64
    800047d4:	fc06                	sd	ra,56(sp)
    800047d6:	f822                	sd	s0,48(sp)
    800047d8:	f426                	sd	s1,40(sp)
    800047da:	f04a                	sd	s2,32(sp)
    800047dc:	ec4e                	sd	s3,24(sp)
    800047de:	e852                	sd	s4,16(sp)
    800047e0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800047e2:	04451703          	lh	a4,68(a0)
    800047e6:	4785                	li	a5,1
    800047e8:	00f71a63          	bne	a4,a5,800047fc <dirlookup+0x2a>
    800047ec:	892a                	mv	s2,a0
    800047ee:	89ae                	mv	s3,a1
    800047f0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800047f2:	457c                	lw	a5,76(a0)
    800047f4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800047f6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047f8:	e39d                	bnez	a5,8000481e <dirlookup+0x4c>
    800047fa:	a095                	j	8000485e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800047fc:	00005517          	auipc	a0,0x5
    80004800:	f7c50513          	addi	a0,a0,-132 # 80009778 <etext+0x778>
    80004804:	fddfb0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80004808:	00005517          	auipc	a0,0x5
    8000480c:	f8850513          	addi	a0,a0,-120 # 80009790 <etext+0x790>
    80004810:	fd1fb0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004814:	24c1                	addiw	s1,s1,16
    80004816:	04c92783          	lw	a5,76(s2)
    8000481a:	04f4f163          	bgeu	s1,a5,8000485c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000481e:	4741                	li	a4,16
    80004820:	86a6                	mv	a3,s1
    80004822:	fc040613          	addi	a2,s0,-64
    80004826:	4581                	li	a1,0
    80004828:	854a                	mv	a0,s2
    8000482a:	d89ff0ef          	jal	800045b2 <readi>
    8000482e:	47c1                	li	a5,16
    80004830:	fcf51ce3          	bne	a0,a5,80004808 <dirlookup+0x36>
    if(de.inum == 0)
    80004834:	fc045783          	lhu	a5,-64(s0)
    80004838:	dff1                	beqz	a5,80004814 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000483a:	fc240593          	addi	a1,s0,-62
    8000483e:	854e                	mv	a0,s3
    80004840:	f7dff0ef          	jal	800047bc <namecmp>
    80004844:	f961                	bnez	a0,80004814 <dirlookup+0x42>
      if(poff)
    80004846:	000a0463          	beqz	s4,8000484e <dirlookup+0x7c>
        *poff = off;
    8000484a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000484e:	fc045583          	lhu	a1,-64(s0)
    80004852:	00092503          	lw	a0,0(s2)
    80004856:	f58ff0ef          	jal	80003fae <iget>
    8000485a:	a011                	j	8000485e <dirlookup+0x8c>
  return 0;
    8000485c:	4501                	li	a0,0
}
    8000485e:	70e2                	ld	ra,56(sp)
    80004860:	7442                	ld	s0,48(sp)
    80004862:	74a2                	ld	s1,40(sp)
    80004864:	7902                	ld	s2,32(sp)
    80004866:	69e2                	ld	s3,24(sp)
    80004868:	6a42                	ld	s4,16(sp)
    8000486a:	6121                	addi	sp,sp,64
    8000486c:	8082                	ret

000000008000486e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000486e:	711d                	addi	sp,sp,-96
    80004870:	ec86                	sd	ra,88(sp)
    80004872:	e8a2                	sd	s0,80(sp)
    80004874:	e4a6                	sd	s1,72(sp)
    80004876:	e0ca                	sd	s2,64(sp)
    80004878:	fc4e                	sd	s3,56(sp)
    8000487a:	f852                	sd	s4,48(sp)
    8000487c:	f456                	sd	s5,40(sp)
    8000487e:	f05a                	sd	s6,32(sp)
    80004880:	ec5e                	sd	s7,24(sp)
    80004882:	e862                	sd	s8,16(sp)
    80004884:	e466                	sd	s9,8(sp)
    80004886:	1080                	addi	s0,sp,96
    80004888:	84aa                	mv	s1,a0
    8000488a:	8b2e                	mv	s6,a1
    8000488c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000488e:	00054703          	lbu	a4,0(a0)
    80004892:	02f00793          	li	a5,47
    80004896:	00f70e63          	beq	a4,a5,800048b2 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000489a:	e08fd0ef          	jal	80001ea2 <myproc>
    8000489e:	15053503          	ld	a0,336(a0)
    800048a2:	94bff0ef          	jal	800041ec <idup>
    800048a6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800048a8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800048ac:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800048ae:	4b85                	li	s7,1
    800048b0:	a871                	j	8000494c <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800048b2:	4585                	li	a1,1
    800048b4:	4505                	li	a0,1
    800048b6:	ef8ff0ef          	jal	80003fae <iget>
    800048ba:	8a2a                	mv	s4,a0
    800048bc:	b7f5                	j	800048a8 <namex+0x3a>
      iunlockput(ip);
    800048be:	8552                	mv	a0,s4
    800048c0:	b6dff0ef          	jal	8000442c <iunlockput>
      return 0;
    800048c4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800048c6:	8552                	mv	a0,s4
    800048c8:	60e6                	ld	ra,88(sp)
    800048ca:	6446                	ld	s0,80(sp)
    800048cc:	64a6                	ld	s1,72(sp)
    800048ce:	6906                	ld	s2,64(sp)
    800048d0:	79e2                	ld	s3,56(sp)
    800048d2:	7a42                	ld	s4,48(sp)
    800048d4:	7aa2                	ld	s5,40(sp)
    800048d6:	7b02                	ld	s6,32(sp)
    800048d8:	6be2                	ld	s7,24(sp)
    800048da:	6c42                	ld	s8,16(sp)
    800048dc:	6ca2                	ld	s9,8(sp)
    800048de:	6125                	addi	sp,sp,96
    800048e0:	8082                	ret
      iunlock(ip);
    800048e2:	8552                	mv	a0,s4
    800048e4:	9edff0ef          	jal	800042d0 <iunlock>
      return ip;
    800048e8:	bff9                	j	800048c6 <namex+0x58>
      iunlockput(ip);
    800048ea:	8552                	mv	a0,s4
    800048ec:	b41ff0ef          	jal	8000442c <iunlockput>
      return 0;
    800048f0:	8a4e                	mv	s4,s3
    800048f2:	bfd1                	j	800048c6 <namex+0x58>
  len = path - s;
    800048f4:	40998633          	sub	a2,s3,s1
    800048f8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800048fc:	099c5063          	bge	s8,s9,8000497c <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80004900:	4639                	li	a2,14
    80004902:	85a6                	mv	a1,s1
    80004904:	8556                	mv	a0,s5
    80004906:	bf8fc0ef          	jal	80000cfe <memmove>
    8000490a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000490c:	0004c783          	lbu	a5,0(s1)
    80004910:	01279763          	bne	a5,s2,8000491e <namex+0xb0>
    path++;
    80004914:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004916:	0004c783          	lbu	a5,0(s1)
    8000491a:	ff278de3          	beq	a5,s2,80004914 <namex+0xa6>
    ilock(ip);
    8000491e:	8552                	mv	a0,s4
    80004920:	903ff0ef          	jal	80004222 <ilock>
    if(ip->type != T_DIR){
    80004924:	044a1783          	lh	a5,68(s4)
    80004928:	f9779be3          	bne	a5,s7,800048be <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000492c:	000b0563          	beqz	s6,80004936 <namex+0xc8>
    80004930:	0004c783          	lbu	a5,0(s1)
    80004934:	d7dd                	beqz	a5,800048e2 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004936:	4601                	li	a2,0
    80004938:	85d6                	mv	a1,s5
    8000493a:	8552                	mv	a0,s4
    8000493c:	e97ff0ef          	jal	800047d2 <dirlookup>
    80004940:	89aa                	mv	s3,a0
    80004942:	d545                	beqz	a0,800048ea <namex+0x7c>
    iunlockput(ip);
    80004944:	8552                	mv	a0,s4
    80004946:	ae7ff0ef          	jal	8000442c <iunlockput>
    ip = next;
    8000494a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000494c:	0004c783          	lbu	a5,0(s1)
    80004950:	01279763          	bne	a5,s2,8000495e <namex+0xf0>
    path++;
    80004954:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004956:	0004c783          	lbu	a5,0(s1)
    8000495a:	ff278de3          	beq	a5,s2,80004954 <namex+0xe6>
  if(*path == 0)
    8000495e:	cb8d                	beqz	a5,80004990 <namex+0x122>
  while(*path != '/' && *path != 0)
    80004960:	0004c783          	lbu	a5,0(s1)
    80004964:	89a6                	mv	s3,s1
  len = path - s;
    80004966:	4c81                	li	s9,0
    80004968:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000496a:	01278963          	beq	a5,s2,8000497c <namex+0x10e>
    8000496e:	d3d9                	beqz	a5,800048f4 <namex+0x86>
    path++;
    80004970:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004972:	0009c783          	lbu	a5,0(s3)
    80004976:	ff279ce3          	bne	a5,s2,8000496e <namex+0x100>
    8000497a:	bfad                	j	800048f4 <namex+0x86>
    memmove(name, s, len);
    8000497c:	2601                	sext.w	a2,a2
    8000497e:	85a6                	mv	a1,s1
    80004980:	8556                	mv	a0,s5
    80004982:	b7cfc0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80004986:	9cd6                	add	s9,s9,s5
    80004988:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000498c:	84ce                	mv	s1,s3
    8000498e:	bfbd                	j	8000490c <namex+0x9e>
  if(nameiparent){
    80004990:	f20b0be3          	beqz	s6,800048c6 <namex+0x58>
    iput(ip);
    80004994:	8552                	mv	a0,s4
    80004996:	a0fff0ef          	jal	800043a4 <iput>
    return 0;
    8000499a:	4a01                	li	s4,0
    8000499c:	b72d                	j	800048c6 <namex+0x58>

000000008000499e <dirlink>:
{
    8000499e:	7139                	addi	sp,sp,-64
    800049a0:	fc06                	sd	ra,56(sp)
    800049a2:	f822                	sd	s0,48(sp)
    800049a4:	f04a                	sd	s2,32(sp)
    800049a6:	ec4e                	sd	s3,24(sp)
    800049a8:	e852                	sd	s4,16(sp)
    800049aa:	0080                	addi	s0,sp,64
    800049ac:	892a                	mv	s2,a0
    800049ae:	8a2e                	mv	s4,a1
    800049b0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800049b2:	4601                	li	a2,0
    800049b4:	e1fff0ef          	jal	800047d2 <dirlookup>
    800049b8:	e535                	bnez	a0,80004a24 <dirlink+0x86>
    800049ba:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800049bc:	04c92483          	lw	s1,76(s2)
    800049c0:	c48d                	beqz	s1,800049ea <dirlink+0x4c>
    800049c2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800049c4:	4741                	li	a4,16
    800049c6:	86a6                	mv	a3,s1
    800049c8:	fc040613          	addi	a2,s0,-64
    800049cc:	4581                	li	a1,0
    800049ce:	854a                	mv	a0,s2
    800049d0:	be3ff0ef          	jal	800045b2 <readi>
    800049d4:	47c1                	li	a5,16
    800049d6:	04f51b63          	bne	a0,a5,80004a2c <dirlink+0x8e>
    if(de.inum == 0)
    800049da:	fc045783          	lhu	a5,-64(s0)
    800049de:	c791                	beqz	a5,800049ea <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800049e0:	24c1                	addiw	s1,s1,16
    800049e2:	04c92783          	lw	a5,76(s2)
    800049e6:	fcf4efe3          	bltu	s1,a5,800049c4 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800049ea:	4639                	li	a2,14
    800049ec:	85d2                	mv	a1,s4
    800049ee:	fc240513          	addi	a0,s0,-62
    800049f2:	bb2fc0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    800049f6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800049fa:	4741                	li	a4,16
    800049fc:	86a6                	mv	a3,s1
    800049fe:	fc040613          	addi	a2,s0,-64
    80004a02:	4581                	li	a1,0
    80004a04:	854a                	mv	a0,s2
    80004a06:	ca9ff0ef          	jal	800046ae <writei>
    80004a0a:	1541                	addi	a0,a0,-16
    80004a0c:	00a03533          	snez	a0,a0
    80004a10:	40a00533          	neg	a0,a0
    80004a14:	74a2                	ld	s1,40(sp)
}
    80004a16:	70e2                	ld	ra,56(sp)
    80004a18:	7442                	ld	s0,48(sp)
    80004a1a:	7902                	ld	s2,32(sp)
    80004a1c:	69e2                	ld	s3,24(sp)
    80004a1e:	6a42                	ld	s4,16(sp)
    80004a20:	6121                	addi	sp,sp,64
    80004a22:	8082                	ret
    iput(ip);
    80004a24:	981ff0ef          	jal	800043a4 <iput>
    return -1;
    80004a28:	557d                	li	a0,-1
    80004a2a:	b7f5                	j	80004a16 <dirlink+0x78>
      panic("dirlink read");
    80004a2c:	00005517          	auipc	a0,0x5
    80004a30:	d7450513          	addi	a0,a0,-652 # 800097a0 <etext+0x7a0>
    80004a34:	dadfb0ef          	jal	800007e0 <panic>

0000000080004a38 <namei>:

struct inode*
namei(char *path)
{
    80004a38:	1101                	addi	sp,sp,-32
    80004a3a:	ec06                	sd	ra,24(sp)
    80004a3c:	e822                	sd	s0,16(sp)
    80004a3e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004a40:	fe040613          	addi	a2,s0,-32
    80004a44:	4581                	li	a1,0
    80004a46:	e29ff0ef          	jal	8000486e <namex>
}
    80004a4a:	60e2                	ld	ra,24(sp)
    80004a4c:	6442                	ld	s0,16(sp)
    80004a4e:	6105                	addi	sp,sp,32
    80004a50:	8082                	ret

0000000080004a52 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004a52:	1141                	addi	sp,sp,-16
    80004a54:	e406                	sd	ra,8(sp)
    80004a56:	e022                	sd	s0,0(sp)
    80004a58:	0800                	addi	s0,sp,16
    80004a5a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004a5c:	4585                	li	a1,1
    80004a5e:	e11ff0ef          	jal	8000486e <namex>
}
    80004a62:	60a2                	ld	ra,8(sp)
    80004a64:	6402                	ld	s0,0(sp)
    80004a66:	0141                	addi	sp,sp,16
    80004a68:	8082                	ret

0000000080004a6a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004a6a:	1101                	addi	sp,sp,-32
    80004a6c:	ec06                	sd	ra,24(sp)
    80004a6e:	e822                	sd	s0,16(sp)
    80004a70:	e426                	sd	s1,8(sp)
    80004a72:	e04a                	sd	s2,0(sp)
    80004a74:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004a76:	0010a917          	auipc	s2,0x10a
    80004a7a:	52290913          	addi	s2,s2,1314 # 8010ef98 <log>
    80004a7e:	01892583          	lw	a1,24(s2)
    80004a82:	02492503          	lw	a0,36(s2)
    80004a86:	8d0ff0ef          	jal	80003b56 <bread>
    80004a8a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004a8c:	02892603          	lw	a2,40(s2)
    80004a90:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004a92:	00c05f63          	blez	a2,80004ab0 <write_head+0x46>
    80004a96:	0010a717          	auipc	a4,0x10a
    80004a9a:	52e70713          	addi	a4,a4,1326 # 8010efc4 <log+0x2c>
    80004a9e:	87aa                	mv	a5,a0
    80004aa0:	060a                	slli	a2,a2,0x2
    80004aa2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004aa4:	4314                	lw	a3,0(a4)
    80004aa6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004aa8:	0711                	addi	a4,a4,4
    80004aaa:	0791                	addi	a5,a5,4
    80004aac:	fec79ce3          	bne	a5,a2,80004aa4 <write_head+0x3a>
  }
  bwrite(buf);
    80004ab0:	8526                	mv	a0,s1
    80004ab2:	97aff0ef          	jal	80003c2c <bwrite>
  brelse(buf);
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	9a6ff0ef          	jal	80003c5e <brelse>
}
    80004abc:	60e2                	ld	ra,24(sp)
    80004abe:	6442                	ld	s0,16(sp)
    80004ac0:	64a2                	ld	s1,8(sp)
    80004ac2:	6902                	ld	s2,0(sp)
    80004ac4:	6105                	addi	sp,sp,32
    80004ac6:	8082                	ret

0000000080004ac8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ac8:	0010a797          	auipc	a5,0x10a
    80004acc:	4f87a783          	lw	a5,1272(a5) # 8010efc0 <log+0x28>
    80004ad0:	0af05e63          	blez	a5,80004b8c <install_trans+0xc4>
{
    80004ad4:	715d                	addi	sp,sp,-80
    80004ad6:	e486                	sd	ra,72(sp)
    80004ad8:	e0a2                	sd	s0,64(sp)
    80004ada:	fc26                	sd	s1,56(sp)
    80004adc:	f84a                	sd	s2,48(sp)
    80004ade:	f44e                	sd	s3,40(sp)
    80004ae0:	f052                	sd	s4,32(sp)
    80004ae2:	ec56                	sd	s5,24(sp)
    80004ae4:	e85a                	sd	s6,16(sp)
    80004ae6:	e45e                	sd	s7,8(sp)
    80004ae8:	0880                	addi	s0,sp,80
    80004aea:	8b2a                	mv	s6,a0
    80004aec:	0010aa97          	auipc	s5,0x10a
    80004af0:	4d8a8a93          	addi	s5,s5,1240 # 8010efc4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004af4:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004af6:	00005b97          	auipc	s7,0x5
    80004afa:	cbab8b93          	addi	s7,s7,-838 # 800097b0 <etext+0x7b0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004afe:	0010aa17          	auipc	s4,0x10a
    80004b02:	49aa0a13          	addi	s4,s4,1178 # 8010ef98 <log>
    80004b06:	a025                	j	80004b2e <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004b08:	000aa603          	lw	a2,0(s5)
    80004b0c:	85ce                	mv	a1,s3
    80004b0e:	855e                	mv	a0,s7
    80004b10:	9ebfb0ef          	jal	800004fa <printf>
    80004b14:	a839                	j	80004b32 <install_trans+0x6a>
    brelse(lbuf);
    80004b16:	854a                	mv	a0,s2
    80004b18:	946ff0ef          	jal	80003c5e <brelse>
    brelse(dbuf);
    80004b1c:	8526                	mv	a0,s1
    80004b1e:	940ff0ef          	jal	80003c5e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b22:	2985                	addiw	s3,s3,1
    80004b24:	0a91                	addi	s5,s5,4
    80004b26:	028a2783          	lw	a5,40(s4)
    80004b2a:	04f9d663          	bge	s3,a5,80004b76 <install_trans+0xae>
    if(recovering) {
    80004b2e:	fc0b1de3          	bnez	s6,80004b08 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004b32:	018a2583          	lw	a1,24(s4)
    80004b36:	013585bb          	addw	a1,a1,s3
    80004b3a:	2585                	addiw	a1,a1,1
    80004b3c:	024a2503          	lw	a0,36(s4)
    80004b40:	816ff0ef          	jal	80003b56 <bread>
    80004b44:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004b46:	000aa583          	lw	a1,0(s5)
    80004b4a:	024a2503          	lw	a0,36(s4)
    80004b4e:	808ff0ef          	jal	80003b56 <bread>
    80004b52:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004b54:	40000613          	li	a2,1024
    80004b58:	05890593          	addi	a1,s2,88
    80004b5c:	05850513          	addi	a0,a0,88
    80004b60:	99efc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80004b64:	8526                	mv	a0,s1
    80004b66:	8c6ff0ef          	jal	80003c2c <bwrite>
    if(recovering == 0)
    80004b6a:	fa0b16e3          	bnez	s6,80004b16 <install_trans+0x4e>
      bunpin(dbuf);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	9aaff0ef          	jal	80003d1a <bunpin>
    80004b74:	b74d                	j	80004b16 <install_trans+0x4e>
}
    80004b76:	60a6                	ld	ra,72(sp)
    80004b78:	6406                	ld	s0,64(sp)
    80004b7a:	74e2                	ld	s1,56(sp)
    80004b7c:	7942                	ld	s2,48(sp)
    80004b7e:	79a2                	ld	s3,40(sp)
    80004b80:	7a02                	ld	s4,32(sp)
    80004b82:	6ae2                	ld	s5,24(sp)
    80004b84:	6b42                	ld	s6,16(sp)
    80004b86:	6ba2                	ld	s7,8(sp)
    80004b88:	6161                	addi	sp,sp,80
    80004b8a:	8082                	ret
    80004b8c:	8082                	ret

0000000080004b8e <initlog>:
{
    80004b8e:	7179                	addi	sp,sp,-48
    80004b90:	f406                	sd	ra,40(sp)
    80004b92:	f022                	sd	s0,32(sp)
    80004b94:	ec26                	sd	s1,24(sp)
    80004b96:	e84a                	sd	s2,16(sp)
    80004b98:	e44e                	sd	s3,8(sp)
    80004b9a:	1800                	addi	s0,sp,48
    80004b9c:	892a                	mv	s2,a0
    80004b9e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004ba0:	0010a497          	auipc	s1,0x10a
    80004ba4:	3f848493          	addi	s1,s1,1016 # 8010ef98 <log>
    80004ba8:	00005597          	auipc	a1,0x5
    80004bac:	c2858593          	addi	a1,a1,-984 # 800097d0 <etext+0x7d0>
    80004bb0:	8526                	mv	a0,s1
    80004bb2:	f9dfb0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80004bb6:	0149a583          	lw	a1,20(s3)
    80004bba:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004bbc:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004bc0:	854a                	mv	a0,s2
    80004bc2:	f95fe0ef          	jal	80003b56 <bread>
  log.lh.n = lh->n;
    80004bc6:	4d30                	lw	a2,88(a0)
    80004bc8:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004bca:	00c05f63          	blez	a2,80004be8 <initlog+0x5a>
    80004bce:	87aa                	mv	a5,a0
    80004bd0:	0010a717          	auipc	a4,0x10a
    80004bd4:	3f470713          	addi	a4,a4,1012 # 8010efc4 <log+0x2c>
    80004bd8:	060a                	slli	a2,a2,0x2
    80004bda:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004bdc:	4ff4                	lw	a3,92(a5)
    80004bde:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004be0:	0791                	addi	a5,a5,4
    80004be2:	0711                	addi	a4,a4,4
    80004be4:	fec79ce3          	bne	a5,a2,80004bdc <initlog+0x4e>
  brelse(buf);
    80004be8:	876ff0ef          	jal	80003c5e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004bec:	4505                	li	a0,1
    80004bee:	edbff0ef          	jal	80004ac8 <install_trans>
  log.lh.n = 0;
    80004bf2:	0010a797          	auipc	a5,0x10a
    80004bf6:	3c07a723          	sw	zero,974(a5) # 8010efc0 <log+0x28>
  write_head(); // clear the log
    80004bfa:	e71ff0ef          	jal	80004a6a <write_head>
}
    80004bfe:	70a2                	ld	ra,40(sp)
    80004c00:	7402                	ld	s0,32(sp)
    80004c02:	64e2                	ld	s1,24(sp)
    80004c04:	6942                	ld	s2,16(sp)
    80004c06:	69a2                	ld	s3,8(sp)
    80004c08:	6145                	addi	sp,sp,48
    80004c0a:	8082                	ret

0000000080004c0c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004c0c:	1101                	addi	sp,sp,-32
    80004c0e:	ec06                	sd	ra,24(sp)
    80004c10:	e822                	sd	s0,16(sp)
    80004c12:	e426                	sd	s1,8(sp)
    80004c14:	e04a                	sd	s2,0(sp)
    80004c16:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004c18:	0010a517          	auipc	a0,0x10a
    80004c1c:	38050513          	addi	a0,a0,896 # 8010ef98 <log>
    80004c20:	faffb0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80004c24:	0010a497          	auipc	s1,0x10a
    80004c28:	37448493          	addi	s1,s1,884 # 8010ef98 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004c2c:	4979                	li	s2,30
    80004c2e:	a029                	j	80004c38 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004c30:	85a6                	mv	a1,s1
    80004c32:	8526                	mv	a0,s1
    80004c34:	9cbfd0ef          	jal	800025fe <sleep>
    if(log.committing){
    80004c38:	509c                	lw	a5,32(s1)
    80004c3a:	fbfd                	bnez	a5,80004c30 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004c3c:	4cd8                	lw	a4,28(s1)
    80004c3e:	2705                	addiw	a4,a4,1
    80004c40:	0027179b          	slliw	a5,a4,0x2
    80004c44:	9fb9                	addw	a5,a5,a4
    80004c46:	0017979b          	slliw	a5,a5,0x1
    80004c4a:	5494                	lw	a3,40(s1)
    80004c4c:	9fb5                	addw	a5,a5,a3
    80004c4e:	00f95763          	bge	s2,a5,80004c5c <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004c52:	85a6                	mv	a1,s1
    80004c54:	8526                	mv	a0,s1
    80004c56:	9a9fd0ef          	jal	800025fe <sleep>
    80004c5a:	bff9                	j	80004c38 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004c5c:	0010a517          	auipc	a0,0x10a
    80004c60:	33c50513          	addi	a0,a0,828 # 8010ef98 <log>
    80004c64:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004c66:	800fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80004c6a:	60e2                	ld	ra,24(sp)
    80004c6c:	6442                	ld	s0,16(sp)
    80004c6e:	64a2                	ld	s1,8(sp)
    80004c70:	6902                	ld	s2,0(sp)
    80004c72:	6105                	addi	sp,sp,32
    80004c74:	8082                	ret

0000000080004c76 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004c76:	7139                	addi	sp,sp,-64
    80004c78:	fc06                	sd	ra,56(sp)
    80004c7a:	f822                	sd	s0,48(sp)
    80004c7c:	f426                	sd	s1,40(sp)
    80004c7e:	f04a                	sd	s2,32(sp)
    80004c80:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004c82:	0010a497          	auipc	s1,0x10a
    80004c86:	31648493          	addi	s1,s1,790 # 8010ef98 <log>
    80004c8a:	8526                	mv	a0,s1
    80004c8c:	f43fb0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80004c90:	4cdc                	lw	a5,28(s1)
    80004c92:	37fd                	addiw	a5,a5,-1
    80004c94:	0007891b          	sext.w	s2,a5
    80004c98:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004c9a:	509c                	lw	a5,32(s1)
    80004c9c:	ef9d                	bnez	a5,80004cda <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80004c9e:	04091763          	bnez	s2,80004cec <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004ca2:	0010a497          	auipc	s1,0x10a
    80004ca6:	2f648493          	addi	s1,s1,758 # 8010ef98 <log>
    80004caa:	4785                	li	a5,1
    80004cac:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004cae:	8526                	mv	a0,s1
    80004cb0:	fb7fb0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004cb4:	549c                	lw	a5,40(s1)
    80004cb6:	04f04b63          	bgtz	a5,80004d0c <end_op+0x96>
    acquire(&log.lock);
    80004cba:	0010a497          	auipc	s1,0x10a
    80004cbe:	2de48493          	addi	s1,s1,734 # 8010ef98 <log>
    80004cc2:	8526                	mv	a0,s1
    80004cc4:	f0bfb0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80004cc8:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004ccc:	8526                	mv	a0,s1
    80004cce:	97dfd0ef          	jal	8000264a <wakeup>
    release(&log.lock);
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	f93fb0ef          	jal	80000c66 <release>
}
    80004cd8:	a025                	j	80004d00 <end_op+0x8a>
    80004cda:	ec4e                	sd	s3,24(sp)
    80004cdc:	e852                	sd	s4,16(sp)
    80004cde:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004ce0:	00005517          	auipc	a0,0x5
    80004ce4:	af850513          	addi	a0,a0,-1288 # 800097d8 <etext+0x7d8>
    80004ce8:	af9fb0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80004cec:	0010a497          	auipc	s1,0x10a
    80004cf0:	2ac48493          	addi	s1,s1,684 # 8010ef98 <log>
    80004cf4:	8526                	mv	a0,s1
    80004cf6:	955fd0ef          	jal	8000264a <wakeup>
  release(&log.lock);
    80004cfa:	8526                	mv	a0,s1
    80004cfc:	f6bfb0ef          	jal	80000c66 <release>
}
    80004d00:	70e2                	ld	ra,56(sp)
    80004d02:	7442                	ld	s0,48(sp)
    80004d04:	74a2                	ld	s1,40(sp)
    80004d06:	7902                	ld	s2,32(sp)
    80004d08:	6121                	addi	sp,sp,64
    80004d0a:	8082                	ret
    80004d0c:	ec4e                	sd	s3,24(sp)
    80004d0e:	e852                	sd	s4,16(sp)
    80004d10:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d12:	0010aa97          	auipc	s5,0x10a
    80004d16:	2b2a8a93          	addi	s5,s5,690 # 8010efc4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004d1a:	0010aa17          	auipc	s4,0x10a
    80004d1e:	27ea0a13          	addi	s4,s4,638 # 8010ef98 <log>
    80004d22:	018a2583          	lw	a1,24(s4)
    80004d26:	012585bb          	addw	a1,a1,s2
    80004d2a:	2585                	addiw	a1,a1,1
    80004d2c:	024a2503          	lw	a0,36(s4)
    80004d30:	e27fe0ef          	jal	80003b56 <bread>
    80004d34:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004d36:	000aa583          	lw	a1,0(s5)
    80004d3a:	024a2503          	lw	a0,36(s4)
    80004d3e:	e19fe0ef          	jal	80003b56 <bread>
    80004d42:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004d44:	40000613          	li	a2,1024
    80004d48:	05850593          	addi	a1,a0,88
    80004d4c:	05848513          	addi	a0,s1,88
    80004d50:	faffb0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80004d54:	8526                	mv	a0,s1
    80004d56:	ed7fe0ef          	jal	80003c2c <bwrite>
    brelse(from);
    80004d5a:	854e                	mv	a0,s3
    80004d5c:	f03fe0ef          	jal	80003c5e <brelse>
    brelse(to);
    80004d60:	8526                	mv	a0,s1
    80004d62:	efdfe0ef          	jal	80003c5e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d66:	2905                	addiw	s2,s2,1
    80004d68:	0a91                	addi	s5,s5,4
    80004d6a:	028a2783          	lw	a5,40(s4)
    80004d6e:	faf94ae3          	blt	s2,a5,80004d22 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004d72:	cf9ff0ef          	jal	80004a6a <write_head>
    install_trans(0); // Now install writes to home locations
    80004d76:	4501                	li	a0,0
    80004d78:	d51ff0ef          	jal	80004ac8 <install_trans>
    log.lh.n = 0;
    80004d7c:	0010a797          	auipc	a5,0x10a
    80004d80:	2407a223          	sw	zero,580(a5) # 8010efc0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004d84:	ce7ff0ef          	jal	80004a6a <write_head>
    80004d88:	69e2                	ld	s3,24(sp)
    80004d8a:	6a42                	ld	s4,16(sp)
    80004d8c:	6aa2                	ld	s5,8(sp)
    80004d8e:	b735                	j	80004cba <end_op+0x44>

0000000080004d90 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004d90:	1101                	addi	sp,sp,-32
    80004d92:	ec06                	sd	ra,24(sp)
    80004d94:	e822                	sd	s0,16(sp)
    80004d96:	e426                	sd	s1,8(sp)
    80004d98:	e04a                	sd	s2,0(sp)
    80004d9a:	1000                	addi	s0,sp,32
    80004d9c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004d9e:	0010a917          	auipc	s2,0x10a
    80004da2:	1fa90913          	addi	s2,s2,506 # 8010ef98 <log>
    80004da6:	854a                	mv	a0,s2
    80004da8:	e27fb0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004dac:	02892603          	lw	a2,40(s2)
    80004db0:	47f5                	li	a5,29
    80004db2:	04c7cc63          	blt	a5,a2,80004e0a <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004db6:	0010a797          	auipc	a5,0x10a
    80004dba:	1fe7a783          	lw	a5,510(a5) # 8010efb4 <log+0x1c>
    80004dbe:	04f05c63          	blez	a5,80004e16 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004dc2:	4781                	li	a5,0
    80004dc4:	04c05f63          	blez	a2,80004e22 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004dc8:	44cc                	lw	a1,12(s1)
    80004dca:	0010a717          	auipc	a4,0x10a
    80004dce:	1fa70713          	addi	a4,a4,506 # 8010efc4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004dd2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004dd4:	4314                	lw	a3,0(a4)
    80004dd6:	04b68663          	beq	a3,a1,80004e22 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004dda:	2785                	addiw	a5,a5,1
    80004ddc:	0711                	addi	a4,a4,4
    80004dde:	fef61be3          	bne	a2,a5,80004dd4 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004de2:	0621                	addi	a2,a2,8
    80004de4:	060a                	slli	a2,a2,0x2
    80004de6:	0010a797          	auipc	a5,0x10a
    80004dea:	1b278793          	addi	a5,a5,434 # 8010ef98 <log>
    80004dee:	97b2                	add	a5,a5,a2
    80004df0:	44d8                	lw	a4,12(s1)
    80004df2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004df4:	8526                	mv	a0,s1
    80004df6:	ef1fe0ef          	jal	80003ce6 <bpin>
    log.lh.n++;
    80004dfa:	0010a717          	auipc	a4,0x10a
    80004dfe:	19e70713          	addi	a4,a4,414 # 8010ef98 <log>
    80004e02:	571c                	lw	a5,40(a4)
    80004e04:	2785                	addiw	a5,a5,1
    80004e06:	d71c                	sw	a5,40(a4)
    80004e08:	a80d                	j	80004e3a <log_write+0xaa>
    panic("too big a transaction");
    80004e0a:	00005517          	auipc	a0,0x5
    80004e0e:	9de50513          	addi	a0,a0,-1570 # 800097e8 <etext+0x7e8>
    80004e12:	9cffb0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80004e16:	00005517          	auipc	a0,0x5
    80004e1a:	9ea50513          	addi	a0,a0,-1558 # 80009800 <etext+0x800>
    80004e1e:	9c3fb0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80004e22:	00878693          	addi	a3,a5,8
    80004e26:	068a                	slli	a3,a3,0x2
    80004e28:	0010a717          	auipc	a4,0x10a
    80004e2c:	17070713          	addi	a4,a4,368 # 8010ef98 <log>
    80004e30:	9736                	add	a4,a4,a3
    80004e32:	44d4                	lw	a3,12(s1)
    80004e34:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004e36:	faf60fe3          	beq	a2,a5,80004df4 <log_write+0x64>
  }
  release(&log.lock);
    80004e3a:	0010a517          	auipc	a0,0x10a
    80004e3e:	15e50513          	addi	a0,a0,350 # 8010ef98 <log>
    80004e42:	e25fb0ef          	jal	80000c66 <release>
}
    80004e46:	60e2                	ld	ra,24(sp)
    80004e48:	6442                	ld	s0,16(sp)
    80004e4a:	64a2                	ld	s1,8(sp)
    80004e4c:	6902                	ld	s2,0(sp)
    80004e4e:	6105                	addi	sp,sp,32
    80004e50:	8082                	ret

0000000080004e52 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004e52:	1101                	addi	sp,sp,-32
    80004e54:	ec06                	sd	ra,24(sp)
    80004e56:	e822                	sd	s0,16(sp)
    80004e58:	e426                	sd	s1,8(sp)
    80004e5a:	e04a                	sd	s2,0(sp)
    80004e5c:	1000                	addi	s0,sp,32
    80004e5e:	84aa                	mv	s1,a0
    80004e60:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004e62:	00005597          	auipc	a1,0x5
    80004e66:	9be58593          	addi	a1,a1,-1602 # 80009820 <etext+0x820>
    80004e6a:	0521                	addi	a0,a0,8
    80004e6c:	ce3fb0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004e70:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004e74:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e78:	0204a423          	sw	zero,40(s1)
}
    80004e7c:	60e2                	ld	ra,24(sp)
    80004e7e:	6442                	ld	s0,16(sp)
    80004e80:	64a2                	ld	s1,8(sp)
    80004e82:	6902                	ld	s2,0(sp)
    80004e84:	6105                	addi	sp,sp,32
    80004e86:	8082                	ret

0000000080004e88 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004e88:	1101                	addi	sp,sp,-32
    80004e8a:	ec06                	sd	ra,24(sp)
    80004e8c:	e822                	sd	s0,16(sp)
    80004e8e:	e426                	sd	s1,8(sp)
    80004e90:	e04a                	sd	s2,0(sp)
    80004e92:	1000                	addi	s0,sp,32
    80004e94:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e96:	00850913          	addi	s2,a0,8
    80004e9a:	854a                	mv	a0,s2
    80004e9c:	d33fb0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80004ea0:	409c                	lw	a5,0(s1)
    80004ea2:	c799                	beqz	a5,80004eb0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004ea4:	85ca                	mv	a1,s2
    80004ea6:	8526                	mv	a0,s1
    80004ea8:	f56fd0ef          	jal	800025fe <sleep>
  while (lk->locked) {
    80004eac:	409c                	lw	a5,0(s1)
    80004eae:	fbfd                	bnez	a5,80004ea4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004eb0:	4785                	li	a5,1
    80004eb2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004eb4:	feffc0ef          	jal	80001ea2 <myproc>
    80004eb8:	591c                	lw	a5,48(a0)
    80004eba:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ebc:	854a                	mv	a0,s2
    80004ebe:	da9fb0ef          	jal	80000c66 <release>
}
    80004ec2:	60e2                	ld	ra,24(sp)
    80004ec4:	6442                	ld	s0,16(sp)
    80004ec6:	64a2                	ld	s1,8(sp)
    80004ec8:	6902                	ld	s2,0(sp)
    80004eca:	6105                	addi	sp,sp,32
    80004ecc:	8082                	ret

0000000080004ece <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ece:	1101                	addi	sp,sp,-32
    80004ed0:	ec06                	sd	ra,24(sp)
    80004ed2:	e822                	sd	s0,16(sp)
    80004ed4:	e426                	sd	s1,8(sp)
    80004ed6:	e04a                	sd	s2,0(sp)
    80004ed8:	1000                	addi	s0,sp,32
    80004eda:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004edc:	00850913          	addi	s2,a0,8
    80004ee0:	854a                	mv	a0,s2
    80004ee2:	cedfb0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80004ee6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004eea:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004eee:	8526                	mv	a0,s1
    80004ef0:	f5afd0ef          	jal	8000264a <wakeup>
  release(&lk->lk);
    80004ef4:	854a                	mv	a0,s2
    80004ef6:	d71fb0ef          	jal	80000c66 <release>
}
    80004efa:	60e2                	ld	ra,24(sp)
    80004efc:	6442                	ld	s0,16(sp)
    80004efe:	64a2                	ld	s1,8(sp)
    80004f00:	6902                	ld	s2,0(sp)
    80004f02:	6105                	addi	sp,sp,32
    80004f04:	8082                	ret

0000000080004f06 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004f06:	7179                	addi	sp,sp,-48
    80004f08:	f406                	sd	ra,40(sp)
    80004f0a:	f022                	sd	s0,32(sp)
    80004f0c:	ec26                	sd	s1,24(sp)
    80004f0e:	e84a                	sd	s2,16(sp)
    80004f10:	1800                	addi	s0,sp,48
    80004f12:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004f14:	00850913          	addi	s2,a0,8
    80004f18:	854a                	mv	a0,s2
    80004f1a:	cb5fb0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f1e:	409c                	lw	a5,0(s1)
    80004f20:	ef81                	bnez	a5,80004f38 <holdingsleep+0x32>
    80004f22:	4481                	li	s1,0
  release(&lk->lk);
    80004f24:	854a                	mv	a0,s2
    80004f26:	d41fb0ef          	jal	80000c66 <release>
  return r;
}
    80004f2a:	8526                	mv	a0,s1
    80004f2c:	70a2                	ld	ra,40(sp)
    80004f2e:	7402                	ld	s0,32(sp)
    80004f30:	64e2                	ld	s1,24(sp)
    80004f32:	6942                	ld	s2,16(sp)
    80004f34:	6145                	addi	sp,sp,48
    80004f36:	8082                	ret
    80004f38:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f3a:	0284a983          	lw	s3,40(s1)
    80004f3e:	f65fc0ef          	jal	80001ea2 <myproc>
    80004f42:	5904                	lw	s1,48(a0)
    80004f44:	413484b3          	sub	s1,s1,s3
    80004f48:	0014b493          	seqz	s1,s1
    80004f4c:	69a2                	ld	s3,8(sp)
    80004f4e:	bfd9                	j	80004f24 <holdingsleep+0x1e>

0000000080004f50 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004f50:	1141                	addi	sp,sp,-16
    80004f52:	e406                	sd	ra,8(sp)
    80004f54:	e022                	sd	s0,0(sp)
    80004f56:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004f58:	00005597          	auipc	a1,0x5
    80004f5c:	8d858593          	addi	a1,a1,-1832 # 80009830 <etext+0x830>
    80004f60:	0010a517          	auipc	a0,0x10a
    80004f64:	18050513          	addi	a0,a0,384 # 8010f0e0 <ftable>
    80004f68:	be7fb0ef          	jal	80000b4e <initlock>
}
    80004f6c:	60a2                	ld	ra,8(sp)
    80004f6e:	6402                	ld	s0,0(sp)
    80004f70:	0141                	addi	sp,sp,16
    80004f72:	8082                	ret

0000000080004f74 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004f74:	1101                	addi	sp,sp,-32
    80004f76:	ec06                	sd	ra,24(sp)
    80004f78:	e822                	sd	s0,16(sp)
    80004f7a:	e426                	sd	s1,8(sp)
    80004f7c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004f7e:	0010a517          	auipc	a0,0x10a
    80004f82:	16250513          	addi	a0,a0,354 # 8010f0e0 <ftable>
    80004f86:	c49fb0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f8a:	0010a497          	auipc	s1,0x10a
    80004f8e:	16e48493          	addi	s1,s1,366 # 8010f0f8 <ftable+0x18>
    80004f92:	0010b717          	auipc	a4,0x10b
    80004f96:	10670713          	addi	a4,a4,262 # 80110098 <disk>
    if(f->ref == 0){
    80004f9a:	40dc                	lw	a5,4(s1)
    80004f9c:	cf89                	beqz	a5,80004fb6 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f9e:	02848493          	addi	s1,s1,40
    80004fa2:	fee49ce3          	bne	s1,a4,80004f9a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004fa6:	0010a517          	auipc	a0,0x10a
    80004faa:	13a50513          	addi	a0,a0,314 # 8010f0e0 <ftable>
    80004fae:	cb9fb0ef          	jal	80000c66 <release>
  return 0;
    80004fb2:	4481                	li	s1,0
    80004fb4:	a809                	j	80004fc6 <filealloc+0x52>
      f->ref = 1;
    80004fb6:	4785                	li	a5,1
    80004fb8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004fba:	0010a517          	auipc	a0,0x10a
    80004fbe:	12650513          	addi	a0,a0,294 # 8010f0e0 <ftable>
    80004fc2:	ca5fb0ef          	jal	80000c66 <release>
}
    80004fc6:	8526                	mv	a0,s1
    80004fc8:	60e2                	ld	ra,24(sp)
    80004fca:	6442                	ld	s0,16(sp)
    80004fcc:	64a2                	ld	s1,8(sp)
    80004fce:	6105                	addi	sp,sp,32
    80004fd0:	8082                	ret

0000000080004fd2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004fd2:	1101                	addi	sp,sp,-32
    80004fd4:	ec06                	sd	ra,24(sp)
    80004fd6:	e822                	sd	s0,16(sp)
    80004fd8:	e426                	sd	s1,8(sp)
    80004fda:	1000                	addi	s0,sp,32
    80004fdc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004fde:	0010a517          	auipc	a0,0x10a
    80004fe2:	10250513          	addi	a0,a0,258 # 8010f0e0 <ftable>
    80004fe6:	be9fb0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004fea:	40dc                	lw	a5,4(s1)
    80004fec:	02f05063          	blez	a5,8000500c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004ff0:	2785                	addiw	a5,a5,1
    80004ff2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ff4:	0010a517          	auipc	a0,0x10a
    80004ff8:	0ec50513          	addi	a0,a0,236 # 8010f0e0 <ftable>
    80004ffc:	c6bfb0ef          	jal	80000c66 <release>
  return f;
}
    80005000:	8526                	mv	a0,s1
    80005002:	60e2                	ld	ra,24(sp)
    80005004:	6442                	ld	s0,16(sp)
    80005006:	64a2                	ld	s1,8(sp)
    80005008:	6105                	addi	sp,sp,32
    8000500a:	8082                	ret
    panic("filedup");
    8000500c:	00005517          	auipc	a0,0x5
    80005010:	82c50513          	addi	a0,a0,-2004 # 80009838 <etext+0x838>
    80005014:	fccfb0ef          	jal	800007e0 <panic>

0000000080005018 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005018:	7139                	addi	sp,sp,-64
    8000501a:	fc06                	sd	ra,56(sp)
    8000501c:	f822                	sd	s0,48(sp)
    8000501e:	f426                	sd	s1,40(sp)
    80005020:	0080                	addi	s0,sp,64
    80005022:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005024:	0010a517          	auipc	a0,0x10a
    80005028:	0bc50513          	addi	a0,a0,188 # 8010f0e0 <ftable>
    8000502c:	ba3fb0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80005030:	40dc                	lw	a5,4(s1)
    80005032:	04f05a63          	blez	a5,80005086 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80005036:	37fd                	addiw	a5,a5,-1
    80005038:	0007871b          	sext.w	a4,a5
    8000503c:	c0dc                	sw	a5,4(s1)
    8000503e:	04e04e63          	bgtz	a4,8000509a <fileclose+0x82>
    80005042:	f04a                	sd	s2,32(sp)
    80005044:	ec4e                	sd	s3,24(sp)
    80005046:	e852                	sd	s4,16(sp)
    80005048:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000504a:	0004a903          	lw	s2,0(s1)
    8000504e:	0094ca83          	lbu	s5,9(s1)
    80005052:	0104ba03          	ld	s4,16(s1)
    80005056:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000505a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000505e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005062:	0010a517          	auipc	a0,0x10a
    80005066:	07e50513          	addi	a0,a0,126 # 8010f0e0 <ftable>
    8000506a:	bfdfb0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000506e:	4785                	li	a5,1
    80005070:	04f90063          	beq	s2,a5,800050b0 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005074:	3979                	addiw	s2,s2,-2
    80005076:	4785                	li	a5,1
    80005078:	0527f563          	bgeu	a5,s2,800050c2 <fileclose+0xaa>
    8000507c:	7902                	ld	s2,32(sp)
    8000507e:	69e2                	ld	s3,24(sp)
    80005080:	6a42                	ld	s4,16(sp)
    80005082:	6aa2                	ld	s5,8(sp)
    80005084:	a00d                	j	800050a6 <fileclose+0x8e>
    80005086:	f04a                	sd	s2,32(sp)
    80005088:	ec4e                	sd	s3,24(sp)
    8000508a:	e852                	sd	s4,16(sp)
    8000508c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000508e:	00004517          	auipc	a0,0x4
    80005092:	7b250513          	addi	a0,a0,1970 # 80009840 <etext+0x840>
    80005096:	f4afb0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    8000509a:	0010a517          	auipc	a0,0x10a
    8000509e:	04650513          	addi	a0,a0,70 # 8010f0e0 <ftable>
    800050a2:	bc5fb0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800050a6:	70e2                	ld	ra,56(sp)
    800050a8:	7442                	ld	s0,48(sp)
    800050aa:	74a2                	ld	s1,40(sp)
    800050ac:	6121                	addi	sp,sp,64
    800050ae:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800050b0:	85d6                	mv	a1,s5
    800050b2:	8552                	mv	a0,s4
    800050b4:	336000ef          	jal	800053ea <pipeclose>
    800050b8:	7902                	ld	s2,32(sp)
    800050ba:	69e2                	ld	s3,24(sp)
    800050bc:	6a42                	ld	s4,16(sp)
    800050be:	6aa2                	ld	s5,8(sp)
    800050c0:	b7dd                	j	800050a6 <fileclose+0x8e>
    begin_op();
    800050c2:	b4bff0ef          	jal	80004c0c <begin_op>
    iput(ff.ip);
    800050c6:	854e                	mv	a0,s3
    800050c8:	adcff0ef          	jal	800043a4 <iput>
    end_op();
    800050cc:	babff0ef          	jal	80004c76 <end_op>
    800050d0:	7902                	ld	s2,32(sp)
    800050d2:	69e2                	ld	s3,24(sp)
    800050d4:	6a42                	ld	s4,16(sp)
    800050d6:	6aa2                	ld	s5,8(sp)
    800050d8:	b7f9                	j	800050a6 <fileclose+0x8e>

00000000800050da <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800050da:	715d                	addi	sp,sp,-80
    800050dc:	e486                	sd	ra,72(sp)
    800050de:	e0a2                	sd	s0,64(sp)
    800050e0:	fc26                	sd	s1,56(sp)
    800050e2:	f44e                	sd	s3,40(sp)
    800050e4:	0880                	addi	s0,sp,80
    800050e6:	84aa                	mv	s1,a0
    800050e8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800050ea:	db9fc0ef          	jal	80001ea2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800050ee:	409c                	lw	a5,0(s1)
    800050f0:	37f9                	addiw	a5,a5,-2
    800050f2:	4705                	li	a4,1
    800050f4:	04f76063          	bltu	a4,a5,80005134 <filestat+0x5a>
    800050f8:	f84a                	sd	s2,48(sp)
    800050fa:	892a                	mv	s2,a0
    ilock(f->ip);
    800050fc:	6c88                	ld	a0,24(s1)
    800050fe:	924ff0ef          	jal	80004222 <ilock>
    stati(f->ip, &st);
    80005102:	fb840593          	addi	a1,s0,-72
    80005106:	6c88                	ld	a0,24(s1)
    80005108:	c80ff0ef          	jal	80004588 <stati>
    iunlock(f->ip);
    8000510c:	6c88                	ld	a0,24(s1)
    8000510e:	9c2ff0ef          	jal	800042d0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005112:	46e1                	li	a3,24
    80005114:	fb840613          	addi	a2,s0,-72
    80005118:	85ce                	mv	a1,s3
    8000511a:	05093503          	ld	a0,80(s2)
    8000511e:	963fc0ef          	jal	80001a80 <copyout>
    80005122:	41f5551b          	sraiw	a0,a0,0x1f
    80005126:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80005128:	60a6                	ld	ra,72(sp)
    8000512a:	6406                	ld	s0,64(sp)
    8000512c:	74e2                	ld	s1,56(sp)
    8000512e:	79a2                	ld	s3,40(sp)
    80005130:	6161                	addi	sp,sp,80
    80005132:	8082                	ret
  return -1;
    80005134:	557d                	li	a0,-1
    80005136:	bfcd                	j	80005128 <filestat+0x4e>

0000000080005138 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005138:	7179                	addi	sp,sp,-48
    8000513a:	f406                	sd	ra,40(sp)
    8000513c:	f022                	sd	s0,32(sp)
    8000513e:	e84a                	sd	s2,16(sp)
    80005140:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005142:	00854783          	lbu	a5,8(a0)
    80005146:	cfd1                	beqz	a5,800051e2 <fileread+0xaa>
    80005148:	ec26                	sd	s1,24(sp)
    8000514a:	e44e                	sd	s3,8(sp)
    8000514c:	84aa                	mv	s1,a0
    8000514e:	89ae                	mv	s3,a1
    80005150:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005152:	411c                	lw	a5,0(a0)
    80005154:	4705                	li	a4,1
    80005156:	04e78363          	beq	a5,a4,8000519c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000515a:	470d                	li	a4,3
    8000515c:	04e78763          	beq	a5,a4,800051aa <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005160:	4709                	li	a4,2
    80005162:	06e79a63          	bne	a5,a4,800051d6 <fileread+0x9e>
    ilock(f->ip);
    80005166:	6d08                	ld	a0,24(a0)
    80005168:	8baff0ef          	jal	80004222 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000516c:	874a                	mv	a4,s2
    8000516e:	5094                	lw	a3,32(s1)
    80005170:	864e                	mv	a2,s3
    80005172:	4585                	li	a1,1
    80005174:	6c88                	ld	a0,24(s1)
    80005176:	c3cff0ef          	jal	800045b2 <readi>
    8000517a:	892a                	mv	s2,a0
    8000517c:	00a05563          	blez	a0,80005186 <fileread+0x4e>
      f->off += r;
    80005180:	509c                	lw	a5,32(s1)
    80005182:	9fa9                	addw	a5,a5,a0
    80005184:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005186:	6c88                	ld	a0,24(s1)
    80005188:	948ff0ef          	jal	800042d0 <iunlock>
    8000518c:	64e2                	ld	s1,24(sp)
    8000518e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80005190:	854a                	mv	a0,s2
    80005192:	70a2                	ld	ra,40(sp)
    80005194:	7402                	ld	s0,32(sp)
    80005196:	6942                	ld	s2,16(sp)
    80005198:	6145                	addi	sp,sp,48
    8000519a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000519c:	6908                	ld	a0,16(a0)
    8000519e:	388000ef          	jal	80005526 <piperead>
    800051a2:	892a                	mv	s2,a0
    800051a4:	64e2                	ld	s1,24(sp)
    800051a6:	69a2                	ld	s3,8(sp)
    800051a8:	b7e5                	j	80005190 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800051aa:	02451783          	lh	a5,36(a0)
    800051ae:	03079693          	slli	a3,a5,0x30
    800051b2:	92c1                	srli	a3,a3,0x30
    800051b4:	4725                	li	a4,9
    800051b6:	02d76863          	bltu	a4,a3,800051e6 <fileread+0xae>
    800051ba:	0792                	slli	a5,a5,0x4
    800051bc:	0010a717          	auipc	a4,0x10a
    800051c0:	e8470713          	addi	a4,a4,-380 # 8010f040 <devsw>
    800051c4:	97ba                	add	a5,a5,a4
    800051c6:	639c                	ld	a5,0(a5)
    800051c8:	c39d                	beqz	a5,800051ee <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800051ca:	4505                	li	a0,1
    800051cc:	9782                	jalr	a5
    800051ce:	892a                	mv	s2,a0
    800051d0:	64e2                	ld	s1,24(sp)
    800051d2:	69a2                	ld	s3,8(sp)
    800051d4:	bf75                	j	80005190 <fileread+0x58>
    panic("fileread");
    800051d6:	00004517          	auipc	a0,0x4
    800051da:	67a50513          	addi	a0,a0,1658 # 80009850 <etext+0x850>
    800051de:	e02fb0ef          	jal	800007e0 <panic>
    return -1;
    800051e2:	597d                	li	s2,-1
    800051e4:	b775                	j	80005190 <fileread+0x58>
      return -1;
    800051e6:	597d                	li	s2,-1
    800051e8:	64e2                	ld	s1,24(sp)
    800051ea:	69a2                	ld	s3,8(sp)
    800051ec:	b755                	j	80005190 <fileread+0x58>
    800051ee:	597d                	li	s2,-1
    800051f0:	64e2                	ld	s1,24(sp)
    800051f2:	69a2                	ld	s3,8(sp)
    800051f4:	bf71                	j	80005190 <fileread+0x58>

00000000800051f6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800051f6:	00954783          	lbu	a5,9(a0)
    800051fa:	10078b63          	beqz	a5,80005310 <filewrite+0x11a>
{
    800051fe:	715d                	addi	sp,sp,-80
    80005200:	e486                	sd	ra,72(sp)
    80005202:	e0a2                	sd	s0,64(sp)
    80005204:	f84a                	sd	s2,48(sp)
    80005206:	f052                	sd	s4,32(sp)
    80005208:	e85a                	sd	s6,16(sp)
    8000520a:	0880                	addi	s0,sp,80
    8000520c:	892a                	mv	s2,a0
    8000520e:	8b2e                	mv	s6,a1
    80005210:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005212:	411c                	lw	a5,0(a0)
    80005214:	4705                	li	a4,1
    80005216:	02e78763          	beq	a5,a4,80005244 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000521a:	470d                	li	a4,3
    8000521c:	02e78863          	beq	a5,a4,8000524c <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005220:	4709                	li	a4,2
    80005222:	0ce79c63          	bne	a5,a4,800052fa <filewrite+0x104>
    80005226:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005228:	0ac05863          	blez	a2,800052d8 <filewrite+0xe2>
    8000522c:	fc26                	sd	s1,56(sp)
    8000522e:	ec56                	sd	s5,24(sp)
    80005230:	e45e                	sd	s7,8(sp)
    80005232:	e062                	sd	s8,0(sp)
    int i = 0;
    80005234:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80005236:	6b85                	lui	s7,0x1
    80005238:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000523c:	6c05                	lui	s8,0x1
    8000523e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005242:	a8b5                	j	800052be <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80005244:	6908                	ld	a0,16(a0)
    80005246:	1fc000ef          	jal	80005442 <pipewrite>
    8000524a:	a04d                	j	800052ec <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000524c:	02451783          	lh	a5,36(a0)
    80005250:	03079693          	slli	a3,a5,0x30
    80005254:	92c1                	srli	a3,a3,0x30
    80005256:	4725                	li	a4,9
    80005258:	0ad76e63          	bltu	a4,a3,80005314 <filewrite+0x11e>
    8000525c:	0792                	slli	a5,a5,0x4
    8000525e:	0010a717          	auipc	a4,0x10a
    80005262:	de270713          	addi	a4,a4,-542 # 8010f040 <devsw>
    80005266:	97ba                	add	a5,a5,a4
    80005268:	679c                	ld	a5,8(a5)
    8000526a:	c7dd                	beqz	a5,80005318 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000526c:	4505                	li	a0,1
    8000526e:	9782                	jalr	a5
    80005270:	a8b5                	j	800052ec <filewrite+0xf6>
      if(n1 > max)
    80005272:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80005276:	997ff0ef          	jal	80004c0c <begin_op>
      ilock(f->ip);
    8000527a:	01893503          	ld	a0,24(s2)
    8000527e:	fa5fe0ef          	jal	80004222 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005282:	8756                	mv	a4,s5
    80005284:	02092683          	lw	a3,32(s2)
    80005288:	01698633          	add	a2,s3,s6
    8000528c:	4585                	li	a1,1
    8000528e:	01893503          	ld	a0,24(s2)
    80005292:	c1cff0ef          	jal	800046ae <writei>
    80005296:	84aa                	mv	s1,a0
    80005298:	00a05763          	blez	a0,800052a6 <filewrite+0xb0>
        f->off += r;
    8000529c:	02092783          	lw	a5,32(s2)
    800052a0:	9fa9                	addw	a5,a5,a0
    800052a2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800052a6:	01893503          	ld	a0,24(s2)
    800052aa:	826ff0ef          	jal	800042d0 <iunlock>
      end_op();
    800052ae:	9c9ff0ef          	jal	80004c76 <end_op>

      if(r != n1){
    800052b2:	029a9563          	bne	s5,s1,800052dc <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800052b6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800052ba:	0149da63          	bge	s3,s4,800052ce <filewrite+0xd8>
      int n1 = n - i;
    800052be:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800052c2:	0004879b          	sext.w	a5,s1
    800052c6:	fafbd6e3          	bge	s7,a5,80005272 <filewrite+0x7c>
    800052ca:	84e2                	mv	s1,s8
    800052cc:	b75d                	j	80005272 <filewrite+0x7c>
    800052ce:	74e2                	ld	s1,56(sp)
    800052d0:	6ae2                	ld	s5,24(sp)
    800052d2:	6ba2                	ld	s7,8(sp)
    800052d4:	6c02                	ld	s8,0(sp)
    800052d6:	a039                	j	800052e4 <filewrite+0xee>
    int i = 0;
    800052d8:	4981                	li	s3,0
    800052da:	a029                	j	800052e4 <filewrite+0xee>
    800052dc:	74e2                	ld	s1,56(sp)
    800052de:	6ae2                	ld	s5,24(sp)
    800052e0:	6ba2                	ld	s7,8(sp)
    800052e2:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800052e4:	033a1c63          	bne	s4,s3,8000531c <filewrite+0x126>
    800052e8:	8552                	mv	a0,s4
    800052ea:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800052ec:	60a6                	ld	ra,72(sp)
    800052ee:	6406                	ld	s0,64(sp)
    800052f0:	7942                	ld	s2,48(sp)
    800052f2:	7a02                	ld	s4,32(sp)
    800052f4:	6b42                	ld	s6,16(sp)
    800052f6:	6161                	addi	sp,sp,80
    800052f8:	8082                	ret
    800052fa:	fc26                	sd	s1,56(sp)
    800052fc:	f44e                	sd	s3,40(sp)
    800052fe:	ec56                	sd	s5,24(sp)
    80005300:	e45e                	sd	s7,8(sp)
    80005302:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80005304:	00004517          	auipc	a0,0x4
    80005308:	55c50513          	addi	a0,a0,1372 # 80009860 <etext+0x860>
    8000530c:	cd4fb0ef          	jal	800007e0 <panic>
    return -1;
    80005310:	557d                	li	a0,-1
}
    80005312:	8082                	ret
      return -1;
    80005314:	557d                	li	a0,-1
    80005316:	bfd9                	j	800052ec <filewrite+0xf6>
    80005318:	557d                	li	a0,-1
    8000531a:	bfc9                	j	800052ec <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000531c:	557d                	li	a0,-1
    8000531e:	79a2                	ld	s3,40(sp)
    80005320:	b7f1                	j	800052ec <filewrite+0xf6>

0000000080005322 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005322:	7179                	addi	sp,sp,-48
    80005324:	f406                	sd	ra,40(sp)
    80005326:	f022                	sd	s0,32(sp)
    80005328:	ec26                	sd	s1,24(sp)
    8000532a:	e052                	sd	s4,0(sp)
    8000532c:	1800                	addi	s0,sp,48
    8000532e:	84aa                	mv	s1,a0
    80005330:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005332:	0005b023          	sd	zero,0(a1)
    80005336:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000533a:	c3bff0ef          	jal	80004f74 <filealloc>
    8000533e:	e088                	sd	a0,0(s1)
    80005340:	c549                	beqz	a0,800053ca <pipealloc+0xa8>
    80005342:	c33ff0ef          	jal	80004f74 <filealloc>
    80005346:	00aa3023          	sd	a0,0(s4)
    8000534a:	cd25                	beqz	a0,800053c2 <pipealloc+0xa0>
    8000534c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000534e:	fb0fb0ef          	jal	80000afe <kalloc>
    80005352:	892a                	mv	s2,a0
    80005354:	c12d                	beqz	a0,800053b6 <pipealloc+0x94>
    80005356:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80005358:	4985                	li	s3,1
    8000535a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000535e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005362:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005366:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000536a:	00004597          	auipc	a1,0x4
    8000536e:	50658593          	addi	a1,a1,1286 # 80009870 <etext+0x870>
    80005372:	fdcfb0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80005376:	609c                	ld	a5,0(s1)
    80005378:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000537c:	609c                	ld	a5,0(s1)
    8000537e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005382:	609c                	ld	a5,0(s1)
    80005384:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005388:	609c                	ld	a5,0(s1)
    8000538a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000538e:	000a3783          	ld	a5,0(s4)
    80005392:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005396:	000a3783          	ld	a5,0(s4)
    8000539a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000539e:	000a3783          	ld	a5,0(s4)
    800053a2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800053a6:	000a3783          	ld	a5,0(s4)
    800053aa:	0127b823          	sd	s2,16(a5)
  return 0;
    800053ae:	4501                	li	a0,0
    800053b0:	6942                	ld	s2,16(sp)
    800053b2:	69a2                	ld	s3,8(sp)
    800053b4:	a01d                	j	800053da <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800053b6:	6088                	ld	a0,0(s1)
    800053b8:	c119                	beqz	a0,800053be <pipealloc+0x9c>
    800053ba:	6942                	ld	s2,16(sp)
    800053bc:	a029                	j	800053c6 <pipealloc+0xa4>
    800053be:	6942                	ld	s2,16(sp)
    800053c0:	a029                	j	800053ca <pipealloc+0xa8>
    800053c2:	6088                	ld	a0,0(s1)
    800053c4:	c10d                	beqz	a0,800053e6 <pipealloc+0xc4>
    fileclose(*f0);
    800053c6:	c53ff0ef          	jal	80005018 <fileclose>
  if(*f1)
    800053ca:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800053ce:	557d                	li	a0,-1
  if(*f1)
    800053d0:	c789                	beqz	a5,800053da <pipealloc+0xb8>
    fileclose(*f1);
    800053d2:	853e                	mv	a0,a5
    800053d4:	c45ff0ef          	jal	80005018 <fileclose>
  return -1;
    800053d8:	557d                	li	a0,-1
}
    800053da:	70a2                	ld	ra,40(sp)
    800053dc:	7402                	ld	s0,32(sp)
    800053de:	64e2                	ld	s1,24(sp)
    800053e0:	6a02                	ld	s4,0(sp)
    800053e2:	6145                	addi	sp,sp,48
    800053e4:	8082                	ret
  return -1;
    800053e6:	557d                	li	a0,-1
    800053e8:	bfcd                	j	800053da <pipealloc+0xb8>

00000000800053ea <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800053ea:	1101                	addi	sp,sp,-32
    800053ec:	ec06                	sd	ra,24(sp)
    800053ee:	e822                	sd	s0,16(sp)
    800053f0:	e426                	sd	s1,8(sp)
    800053f2:	e04a                	sd	s2,0(sp)
    800053f4:	1000                	addi	s0,sp,32
    800053f6:	84aa                	mv	s1,a0
    800053f8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800053fa:	fd4fb0ef          	jal	80000bce <acquire>
  if(writable){
    800053fe:	02090763          	beqz	s2,8000542c <pipeclose+0x42>
    pi->writeopen = 0;
    80005402:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005406:	21848513          	addi	a0,s1,536
    8000540a:	a40fd0ef          	jal	8000264a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000540e:	2204b783          	ld	a5,544(s1)
    80005412:	e785                	bnez	a5,8000543a <pipeclose+0x50>
    release(&pi->lock);
    80005414:	8526                	mv	a0,s1
    80005416:	851fb0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    8000541a:	8526                	mv	a0,s1
    8000541c:	e00fb0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    80005420:	60e2                	ld	ra,24(sp)
    80005422:	6442                	ld	s0,16(sp)
    80005424:	64a2                	ld	s1,8(sp)
    80005426:	6902                	ld	s2,0(sp)
    80005428:	6105                	addi	sp,sp,32
    8000542a:	8082                	ret
    pi->readopen = 0;
    8000542c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005430:	21c48513          	addi	a0,s1,540
    80005434:	a16fd0ef          	jal	8000264a <wakeup>
    80005438:	bfd9                	j	8000540e <pipeclose+0x24>
    release(&pi->lock);
    8000543a:	8526                	mv	a0,s1
    8000543c:	82bfb0ef          	jal	80000c66 <release>
}
    80005440:	b7c5                	j	80005420 <pipeclose+0x36>

0000000080005442 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005442:	711d                	addi	sp,sp,-96
    80005444:	ec86                	sd	ra,88(sp)
    80005446:	e8a2                	sd	s0,80(sp)
    80005448:	e4a6                	sd	s1,72(sp)
    8000544a:	e0ca                	sd	s2,64(sp)
    8000544c:	fc4e                	sd	s3,56(sp)
    8000544e:	f852                	sd	s4,48(sp)
    80005450:	f456                	sd	s5,40(sp)
    80005452:	1080                	addi	s0,sp,96
    80005454:	84aa                	mv	s1,a0
    80005456:	8aae                	mv	s5,a1
    80005458:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000545a:	a49fc0ef          	jal	80001ea2 <myproc>
    8000545e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005460:	8526                	mv	a0,s1
    80005462:	f6cfb0ef          	jal	80000bce <acquire>
  while(i < n){
    80005466:	0b405a63          	blez	s4,8000551a <pipewrite+0xd8>
    8000546a:	f05a                	sd	s6,32(sp)
    8000546c:	ec5e                	sd	s7,24(sp)
    8000546e:	e862                	sd	s8,16(sp)
  int i = 0;
    80005470:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005472:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005474:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005478:	21c48b93          	addi	s7,s1,540
    8000547c:	a81d                	j	800054b2 <pipewrite+0x70>
      release(&pi->lock);
    8000547e:	8526                	mv	a0,s1
    80005480:	fe6fb0ef          	jal	80000c66 <release>
      return -1;
    80005484:	597d                	li	s2,-1
    80005486:	7b02                	ld	s6,32(sp)
    80005488:	6be2                	ld	s7,24(sp)
    8000548a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000548c:	854a                	mv	a0,s2
    8000548e:	60e6                	ld	ra,88(sp)
    80005490:	6446                	ld	s0,80(sp)
    80005492:	64a6                	ld	s1,72(sp)
    80005494:	6906                	ld	s2,64(sp)
    80005496:	79e2                	ld	s3,56(sp)
    80005498:	7a42                	ld	s4,48(sp)
    8000549a:	7aa2                	ld	s5,40(sp)
    8000549c:	6125                	addi	sp,sp,96
    8000549e:	8082                	ret
      wakeup(&pi->nread);
    800054a0:	8562                	mv	a0,s8
    800054a2:	9a8fd0ef          	jal	8000264a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800054a6:	85a6                	mv	a1,s1
    800054a8:	855e                	mv	a0,s7
    800054aa:	954fd0ef          	jal	800025fe <sleep>
  while(i < n){
    800054ae:	05495b63          	bge	s2,s4,80005504 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800054b2:	2204a783          	lw	a5,544(s1)
    800054b6:	d7e1                	beqz	a5,8000547e <pipewrite+0x3c>
    800054b8:	854e                	mv	a0,s3
    800054ba:	bbcfd0ef          	jal	80002876 <killed>
    800054be:	f161                	bnez	a0,8000547e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800054c0:	2184a783          	lw	a5,536(s1)
    800054c4:	21c4a703          	lw	a4,540(s1)
    800054c8:	2007879b          	addiw	a5,a5,512
    800054cc:	fcf70ae3          	beq	a4,a5,800054a0 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800054d0:	4685                	li	a3,1
    800054d2:	01590633          	add	a2,s2,s5
    800054d6:	faf40593          	addi	a1,s0,-81
    800054da:	0509b503          	ld	a0,80(s3)
    800054de:	e86fc0ef          	jal	80001b64 <copyin>
    800054e2:	03650e63          	beq	a0,s6,8000551e <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800054e6:	21c4a783          	lw	a5,540(s1)
    800054ea:	0017871b          	addiw	a4,a5,1
    800054ee:	20e4ae23          	sw	a4,540(s1)
    800054f2:	1ff7f793          	andi	a5,a5,511
    800054f6:	97a6                	add	a5,a5,s1
    800054f8:	faf44703          	lbu	a4,-81(s0)
    800054fc:	00e78c23          	sb	a4,24(a5)
      i++;
    80005500:	2905                	addiw	s2,s2,1
    80005502:	b775                	j	800054ae <pipewrite+0x6c>
    80005504:	7b02                	ld	s6,32(sp)
    80005506:	6be2                	ld	s7,24(sp)
    80005508:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000550a:	21848513          	addi	a0,s1,536
    8000550e:	93cfd0ef          	jal	8000264a <wakeup>
  release(&pi->lock);
    80005512:	8526                	mv	a0,s1
    80005514:	f52fb0ef          	jal	80000c66 <release>
  return i;
    80005518:	bf95                	j	8000548c <pipewrite+0x4a>
  int i = 0;
    8000551a:	4901                	li	s2,0
    8000551c:	b7fd                	j	8000550a <pipewrite+0xc8>
    8000551e:	7b02                	ld	s6,32(sp)
    80005520:	6be2                	ld	s7,24(sp)
    80005522:	6c42                	ld	s8,16(sp)
    80005524:	b7dd                	j	8000550a <pipewrite+0xc8>

0000000080005526 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005526:	715d                	addi	sp,sp,-80
    80005528:	e486                	sd	ra,72(sp)
    8000552a:	e0a2                	sd	s0,64(sp)
    8000552c:	fc26                	sd	s1,56(sp)
    8000552e:	f84a                	sd	s2,48(sp)
    80005530:	f44e                	sd	s3,40(sp)
    80005532:	f052                	sd	s4,32(sp)
    80005534:	ec56                	sd	s5,24(sp)
    80005536:	0880                	addi	s0,sp,80
    80005538:	84aa                	mv	s1,a0
    8000553a:	892e                	mv	s2,a1
    8000553c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000553e:	965fc0ef          	jal	80001ea2 <myproc>
    80005542:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005544:	8526                	mv	a0,s1
    80005546:	e88fb0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000554a:	2184a703          	lw	a4,536(s1)
    8000554e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005552:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005556:	02f71563          	bne	a4,a5,80005580 <piperead+0x5a>
    8000555a:	2244a783          	lw	a5,548(s1)
    8000555e:	cb85                	beqz	a5,8000558e <piperead+0x68>
    if(killed(pr)){
    80005560:	8552                	mv	a0,s4
    80005562:	b14fd0ef          	jal	80002876 <killed>
    80005566:	ed19                	bnez	a0,80005584 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005568:	85a6                	mv	a1,s1
    8000556a:	854e                	mv	a0,s3
    8000556c:	892fd0ef          	jal	800025fe <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005570:	2184a703          	lw	a4,536(s1)
    80005574:	21c4a783          	lw	a5,540(s1)
    80005578:	fef701e3          	beq	a4,a5,8000555a <piperead+0x34>
    8000557c:	e85a                	sd	s6,16(sp)
    8000557e:	a809                	j	80005590 <piperead+0x6a>
    80005580:	e85a                	sd	s6,16(sp)
    80005582:	a039                	j	80005590 <piperead+0x6a>
      release(&pi->lock);
    80005584:	8526                	mv	a0,s1
    80005586:	ee0fb0ef          	jal	80000c66 <release>
      return -1;
    8000558a:	59fd                	li	s3,-1
    8000558c:	a8b9                	j	800055ea <piperead+0xc4>
    8000558e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005590:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005592:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005594:	05505363          	blez	s5,800055da <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005598:	2184a783          	lw	a5,536(s1)
    8000559c:	21c4a703          	lw	a4,540(s1)
    800055a0:	02f70d63          	beq	a4,a5,800055da <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800055a4:	1ff7f793          	andi	a5,a5,511
    800055a8:	97a6                	add	a5,a5,s1
    800055aa:	0187c783          	lbu	a5,24(a5)
    800055ae:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800055b2:	4685                	li	a3,1
    800055b4:	fbf40613          	addi	a2,s0,-65
    800055b8:	85ca                	mv	a1,s2
    800055ba:	050a3503          	ld	a0,80(s4)
    800055be:	cc2fc0ef          	jal	80001a80 <copyout>
    800055c2:	03650e63          	beq	a0,s6,800055fe <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800055c6:	2184a783          	lw	a5,536(s1)
    800055ca:	2785                	addiw	a5,a5,1
    800055cc:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800055d0:	2985                	addiw	s3,s3,1
    800055d2:	0905                	addi	s2,s2,1
    800055d4:	fd3a92e3          	bne	s5,s3,80005598 <piperead+0x72>
    800055d8:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800055da:	21c48513          	addi	a0,s1,540
    800055de:	86cfd0ef          	jal	8000264a <wakeup>
  release(&pi->lock);
    800055e2:	8526                	mv	a0,s1
    800055e4:	e82fb0ef          	jal	80000c66 <release>
    800055e8:	6b42                	ld	s6,16(sp)
  return i;
}
    800055ea:	854e                	mv	a0,s3
    800055ec:	60a6                	ld	ra,72(sp)
    800055ee:	6406                	ld	s0,64(sp)
    800055f0:	74e2                	ld	s1,56(sp)
    800055f2:	7942                	ld	s2,48(sp)
    800055f4:	79a2                	ld	s3,40(sp)
    800055f6:	7a02                	ld	s4,32(sp)
    800055f8:	6ae2                	ld	s5,24(sp)
    800055fa:	6161                	addi	sp,sp,80
    800055fc:	8082                	ret
      if(i == 0)
    800055fe:	fc099ee3          	bnez	s3,800055da <piperead+0xb4>
        i = -1;
    80005602:	89aa                	mv	s3,a0
    80005604:	bfd9                	j	800055da <piperead+0xb4>

0000000080005606 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005606:	da010113          	addi	sp,sp,-608
    8000560a:	24113c23          	sd	ra,600(sp)
    8000560e:	24813823          	sd	s0,592(sp)
    80005612:	24913423          	sd	s1,584(sp)
    80005616:	25213023          	sd	s2,576(sp)
    8000561a:	23613023          	sd	s6,544(sp)
    8000561e:	1480                	addi	s0,sp,608
    80005620:	892a                	mv	s2,a0
    80005622:	dca43423          	sd	a0,-568(s0)
    80005626:	8b2e                	mv	s6,a1
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005628:	87bfc0ef          	jal	80001ea2 <myproc>
    8000562c:	84aa                	mv	s1,a0

  begin_op();
    8000562e:	ddeff0ef          	jal	80004c0c <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80005632:	854a                	mv	a0,s2
    80005634:	c04ff0ef          	jal	80004a38 <namei>
    80005638:	c14d                	beqz	a0,800056da <kexec+0xd4>
    8000563a:	23313c23          	sd	s3,568(sp)
    8000563e:	89aa                	mv	s3,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005640:	be3fe0ef          	jal	80004222 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005644:	04000713          	li	a4,64
    80005648:	4681                	li	a3,0
    8000564a:	e5040613          	addi	a2,s0,-432
    8000564e:	4581                	li	a1,0
    80005650:	854e                	mv	a0,s3
    80005652:	f61fe0ef          	jal	800045b2 <readi>
    80005656:	04000793          	li	a5,64
    8000565a:	16f51f63          	bne	a0,a5,800057d8 <kexec+0x1d2>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000565e:	e5042703          	lw	a4,-432(s0)
    80005662:	464c47b7          	lui	a5,0x464c4
    80005666:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000566a:	16f71763          	bne	a4,a5,800057d8 <kexec+0x1d2>
    8000566e:	21713c23          	sd	s7,536(sp)
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)
    80005672:	8526                	mv	a0,s1
    80005674:	935fc0ef          	jal	80001fa8 <proc_pagetable>
    80005678:	8baa                	mv	s7,a0
    8000567a:	36050063          	beqz	a0,800059da <kexec+0x3d4>
    8000567e:	23413823          	sd	s4,560(sp)
    80005682:	23513423          	sd	s5,552(sp)
    80005686:	21813823          	sd	s8,528(sp)
    8000568a:	21913423          	sd	s9,520(sp)
    8000568e:	21a13023          	sd	s10,512(sp)
    80005692:	ffee                	sd	s11,504(sp)
  // Record text/data ranges and offsets for lazy loading; don't allocate physical pages for them now.
  uint64 text_start = 0, text_end = 0;
  uint64 data_start = 0, data_end = 0;
  uint text_off = 0, text_filesz = 0, text_memsz = 0, text_flags = 0;
  uint data_off = 0, data_filesz = 0, data_memsz = 0, data_flags = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005694:	e7042483          	lw	s1,-400(s0)
    80005698:	e8845783          	lhu	a5,-376(s0)
    8000569c:	16078663          	beqz	a5,80005808 <kexec+0x202>
  uint data_off = 0, data_filesz = 0, data_memsz = 0, data_flags = 0;
    800056a0:	dc043823          	sd	zero,-560(s0)
    800056a4:	dc043c23          	sd	zero,-552(s0)
    800056a8:	de043023          	sd	zero,-544(s0)
    800056ac:	de043423          	sd	zero,-536(s0)
  uint text_off = 0, text_filesz = 0, text_memsz = 0, text_flags = 0;
    800056b0:	de043823          	sd	zero,-528(s0)
    800056b4:	de043c23          	sd	zero,-520(s0)
    800056b8:	4781                	li	a5,0
    800056ba:	4d01                	li	s10,0
  uint64 data_start = 0, data_end = 0;
    800056bc:	e0043023          	sd	zero,-512(s0)
    800056c0:	4c01                	li	s8,0
  uint64 text_start = 0, text_end = 0;
    800056c2:	e0043423          	sd	zero,-504(s0)
    800056c6:	4c81                	li	s9,0
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800056c8:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056ca:	4901                	li	s2,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
    800056cc:	4a05                	li	s4,1
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
    800056ce:	6d85                	lui	s11,0x1
    800056d0:	1dfd                	addi	s11,s11,-1 # fff <_entry-0x7ffff001>
    800056d2:	dd643023          	sd	s6,-576(s0)
    800056d6:	8b3e                	mv	s6,a5
    800056d8:	ae15                	j	80005a0c <kexec+0x406>
    end_op();
    800056da:	d9cff0ef          	jal	80004c76 <end_op>
    return -1;
    800056de:	557d                	li	a0,-1
    800056e0:	a239                	j	800057ee <kexec+0x1e8>
    // Track text vs data by flags: execute implies text; else data.
    if(ph.flags & 0x1){
      if(text_start == 0) text_start = ph.vaddr;
      text_end = ph.vaddr + ph.memsz;
    } else {
      if(data_start == 0) data_start = ph.vaddr;
    800056e2:	380c0163          	beqz	s8,80005a64 <kexec+0x45e>
      data_end = ph.vaddr + ph.memsz;
    }
    // Reserve VA range without allocating physical memory yet; just bump sz
    if(ph.vaddr + ph.memsz > sz)
    800056e6:	00eaf363          	bgeu	s5,a4,800056ec <kexec+0xe6>
    800056ea:	8aba                	mv	s5,a4
      text_off = ph.off;
      text_filesz = ph.filesz;
      text_memsz = ph.memsz;
      text_flags = ph.flags;
    } else {
      data_off = ph.off;
    800056ec:	e2042783          	lw	a5,-480(s0)
    800056f0:	def43423          	sd	a5,-536(s0)
      data_filesz = ph.filesz;
    800056f4:	0006079b          	sext.w	a5,a2
    800056f8:	def43023          	sd	a5,-544(s0)
      data_memsz = ph.memsz;
    800056fc:	0006879b          	sext.w	a5,a3
    80005700:	dcf43c23          	sd	a5,-552(s0)
      data_flags = ph.flags;
    80005704:	dcb43823          	sd	a1,-560(s0)
      data_memsz = ph.memsz;
    80005708:	e0e43023          	sd	a4,-512(s0)
    8000570c:	accd                	j	800059fe <kexec+0x3f8>
    8000570e:	db643c23          	sd	s6,-584(s0)
    80005712:	dc043b03          	ld	s6,-576(s0)
    }
  }
  // We've finished reading metadata; keep the transaction open until
  // we either commit to the new image or abort, so any iput() happens
  // within a valid FS transaction.
  iunlock(ip);
    80005716:	854e                	mv	a0,s3
    80005718:	bb9fe0ef          	jal	800042d0 <iunlock>

  p = myproc();
    8000571c:	f86fc0ef          	jal	80001ea2 <myproc>
    80005720:	8daa                	mv	s11,a0
  uint64 oldsz = p->sz;
    80005722:	653c                	ld	a5,72(a0)
    80005724:	dcf43023          	sd	a5,-576(s0)

  // Allocate some pages at the next page boundary for the stack only.
  // Make the first inaccessible as a stack guard.
  // Use the rest as the user stack.
  sz = PGROUNDUP(sz);
    80005728:	6785                	lui	a5,0x1
    8000572a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000572c:	97d6                	add	a5,a5,s5
    8000572e:	777d                	lui	a4,0xfffff
    80005730:	00e7f4b3          	and	s1,a5,a4
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005734:	4691                	li	a3,4
    80005736:	6609                	lui	a2,0x2
    80005738:	9626                	add	a2,a2,s1
    8000573a:	85a6                	mv	a1,s1
    8000573c:	855e                	mv	a0,s7
    8000573e:	c1bfb0ef          	jal	80001358 <uvmalloc>
    80005742:	8aaa                	mv	s5,a0
    80005744:	28050963          	beqz	a0,800059d6 <kexec+0x3d0>
    goto bad;
  sz = sz1;
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005748:	75f9                	lui	a1,0xffffe
    8000574a:	95aa                	add	a1,a1,a0
    8000574c:	855e                	mv	a0,s7
    8000574e:	de1fb0ef          	jal	8000152e <uvmclear>
  sp = sz;
  stackbase = sp - USERSTACK*PGSIZE;
    80005752:	77fd                	lui	a5,0xfffff
    80005754:	97d6                	add	a5,a5,s5

  // Copy argument strings into new stack, remember their
  // addresses in ustack[].
  for(argc = 0; argv[argc]; argc++) {
    80005756:	000b3503          	ld	a0,0(s6)
    8000575a:	12050563          	beqz	a0,80005884 <kexec+0x27e>
    8000575e:	e9040913          	addi	s2,s0,-368
  sp = sz;
    80005762:	84d6                	mv	s1,s5
  for(argc = 0; argv[argc]; argc++) {
    80005764:	4a01                	li	s4,0
    80005766:	db943823          	sd	s9,-592(s0)
    8000576a:	db843423          	sd	s8,-600(s0)
    8000576e:	8cbe                	mv	s9,a5
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    80005770:	ea2fb0ef          	jal	80000e12 <strlen>
    80005774:	2505                	addiw	a0,a0,1
    80005776:	40a48533          	sub	a0,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000577a:	ff057493          	andi	s1,a0,-16
    if(sp < stackbase)
    8000577e:	0394ec63          	bltu	s1,s9,800057b6 <kexec+0x1b0>
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005782:	000b3c03          	ld	s8,0(s6)
    80005786:	8562                	mv	a0,s8
    80005788:	e8afb0ef          	jal	80000e12 <strlen>
    8000578c:	0015069b          	addiw	a3,a0,1
    80005790:	8662                	mv	a2,s8
    80005792:	85a6                	mv	a1,s1
    80005794:	855e                	mv	a0,s7
    80005796:	aeafc0ef          	jal	80001a80 <copyout>
    8000579a:	00054e63          	bltz	a0,800057b6 <kexec+0x1b0>
      goto bad;
    ustack[argc] = sp;
    8000579e:	00993023          	sd	s1,0(s2)
  for(argc = 0; argv[argc]; argc++) {
    800057a2:	0a05                	addi	s4,s4,1
    800057a4:	0b21                	addi	s6,s6,8
    800057a6:	000b3503          	ld	a0,0(s6)
    800057aa:	c551                	beqz	a0,80005836 <kexec+0x230>
    if(argc >= MAXARG)
    800057ac:	0921                	addi	s2,s2,8
    800057ae:	f9040793          	addi	a5,s0,-112
    800057b2:	faf91fe3          	bne	s2,a5,80005770 <kexec+0x16a>

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
    if(pagetable) {
      proc_freepagetable(pagetable, sz);
    800057b6:	85d6                	mv	a1,s5
    800057b8:	855e                	mv	a0,s7
    800057ba:	873fc0ef          	jal	8000202c <proc_freepagetable>
    800057be:	23013a03          	ld	s4,560(sp)
    800057c2:	22813a83          	ld	s5,552(sp)
    800057c6:	21813b83          	ld	s7,536(sp)
    800057ca:	21013c03          	ld	s8,528(sp)
    800057ce:	20813c83          	ld	s9,520(sp)
    800057d2:	20013d03          	ld	s10,512(sp)
    800057d6:	7dfe                	ld	s11,504(sp)
    }
    if(ip){
      // Ensure the iput happens within the transaction we began above.
      ilock(ip);
    800057d8:	854e                	mv	a0,s3
    800057da:	a49fe0ef          	jal	80004222 <ilock>
      iunlockput(ip);
    800057de:	854e                	mv	a0,s3
    800057e0:	c4dfe0ef          	jal	8000442c <iunlockput>
      end_op();
    800057e4:	c92ff0ef          	jal	80004c76 <end_op>
    }
  return -1;
    800057e8:	557d                	li	a0,-1
    800057ea:	23813983          	ld	s3,568(sp)
}
    800057ee:	25813083          	ld	ra,600(sp)
    800057f2:	25013403          	ld	s0,592(sp)
    800057f6:	24813483          	ld	s1,584(sp)
    800057fa:	24013903          	ld	s2,576(sp)
    800057fe:	22013b03          	ld	s6,544(sp)
    80005802:	26010113          	addi	sp,sp,608
    80005806:	8082                	ret
  uint data_off = 0, data_filesz = 0, data_memsz = 0, data_flags = 0;
    80005808:	dc043823          	sd	zero,-560(s0)
    8000580c:	dc043c23          	sd	zero,-552(s0)
    80005810:	de043023          	sd	zero,-544(s0)
    80005814:	de043423          	sd	zero,-536(s0)
  uint text_off = 0, text_filesz = 0, text_memsz = 0, text_flags = 0;
    80005818:	de043823          	sd	zero,-528(s0)
    8000581c:	de043c23          	sd	zero,-520(s0)
    80005820:	da043c23          	sd	zero,-584(s0)
    80005824:	4d01                	li	s10,0
  uint64 data_start = 0, data_end = 0;
    80005826:	e0043023          	sd	zero,-512(s0)
    8000582a:	4c01                	li	s8,0
  uint64 text_start = 0, text_end = 0;
    8000582c:	e0043423          	sd	zero,-504(s0)
    80005830:	4c81                	li	s9,0
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005832:	4a81                	li	s5,0
    80005834:	b5cd                	j	80005716 <kexec+0x110>
    80005836:	da843c03          	ld	s8,-600(s0)
    8000583a:	87e6                	mv	a5,s9
    8000583c:	db043c83          	ld	s9,-592(s0)
  ustack[argc] = 0;
    80005840:	003a1713          	slli	a4,s4,0x3
    80005844:	f9070713          	addi	a4,a4,-112 # ffffffffffffef90 <end+0xffffffff7feeedb8>
    80005848:	9722                	add	a4,a4,s0
    8000584a:	f0073023          	sd	zero,-256(a4)
  sp -= (argc+1) * sizeof(uint64);
    8000584e:	001a0693          	addi	a3,s4,1
    80005852:	068e                	slli	a3,a3,0x3
    80005854:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80005856:	98c1                	andi	s1,s1,-16
  if(sp < stackbase)
    80005858:	f4f4efe3          	bltu	s1,a5,800057b6 <kexec+0x1b0>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000585c:	e9040613          	addi	a2,s0,-368
    80005860:	85a6                	mv	a1,s1
    80005862:	855e                	mv	a0,s7
    80005864:	a1cfc0ef          	jal	80001a80 <copyout>
    80005868:	f40547e3          	bltz	a0,800057b6 <kexec+0x1b0>
  p->trapframe->a1 = sp;
    8000586c:	058db783          	ld	a5,88(s11)
    80005870:	ffa4                	sd	s1,120(a5)
  for(last=s=path; *s; s++)
    80005872:	dc843783          	ld	a5,-568(s0)
    80005876:	0007c703          	lbu	a4,0(a5) # fffffffffffff000 <end+0xffffffff7feeee28>
    8000587a:	c30d                	beqz	a4,8000589c <kexec+0x296>
    8000587c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000587e:	02f00693          	li	a3,47
    80005882:	a801                	j	80005892 <kexec+0x28c>
  sp = sz;
    80005884:	84d6                	mv	s1,s5
  for(argc = 0; argv[argc]; argc++) {
    80005886:	4a01                	li	s4,0
    80005888:	bf65                	j	80005840 <kexec+0x23a>
  for(last=s=path; *s; s++)
    8000588a:	0785                	addi	a5,a5,1
    8000588c:	fff7c703          	lbu	a4,-1(a5)
    80005890:	c711                	beqz	a4,8000589c <kexec+0x296>
    if(*s == '/')
    80005892:	fed71ce3          	bne	a4,a3,8000588a <kexec+0x284>
      last = s+1;
    80005896:	dcf43423          	sd	a5,-568(s0)
    8000589a:	bfc5                	j	8000588a <kexec+0x284>
  safestrcpy(p->name, last, sizeof(p->name));
    8000589c:	4641                	li	a2,16
    8000589e:	dc843583          	ld	a1,-568(s0)
    800058a2:	158d8513          	addi	a0,s11,344
    800058a6:	d3afb0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    800058aa:	050db503          	ld	a0,80(s11)
  p->pagetable = pagetable;
    800058ae:	057db823          	sd	s7,80(s11)
  p->sz = sz;
    800058b2:	055db423          	sd	s5,72(s11)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800058b6:	058db783          	ld	a5,88(s11)
    800058ba:	e6843703          	ld	a4,-408(s0)
    800058be:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800058c0:	058db783          	ld	a5,88(s11)
    800058c4:	fb84                	sd	s1,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800058c6:	dc043583          	ld	a1,-576(s0)
    800058ca:	f62fc0ef          	jal	8000202c <proc_freepagetable>
  p->text_start = text_start;
    800058ce:	6791                	lui	a5,0x4
    800058d0:	97ee                	add	a5,a5,s11
    800058d2:	b997b423          	sd	s9,-1144(a5) # 3b88 <_entry-0x7fffc478>
  p->text_end = text_end;
    800058d6:	e0843703          	ld	a4,-504(s0)
    800058da:	b8e7b823          	sd	a4,-1136(a5)
  p->data_start = data_start;
    800058de:	b987bc23          	sd	s8,-1128(a5)
  p->data_end = data_end;
    800058e2:	e0043703          	ld	a4,-512(s0)
    800058e6:	bae7b023          	sd	a4,-1120(a5)
  uint64 seg_end = data_end ? data_end : text_end;
    800058ea:	c319                	beqz	a4,800058f0 <kexec+0x2ea>
    800058ec:	e0e43423          	sd	a4,-504(s0)
  p->heap_start = PGROUNDUP(seg_end);
    800058f0:	6911                	lui	s2,0x4
    800058f2:	996e                	add	s2,s2,s11
    800058f4:	6785                	lui	a5,0x1
    800058f6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800058f8:	e0843703          	ld	a4,-504(s0)
    800058fc:	97ba                	add	a5,a5,a4
    800058fe:	777d                	lui	a4,0xfffff
    80005900:	8ff9                	and	a5,a5,a4
    80005902:	baf93423          	sd	a5,-1112(s2) # 3ba8 <_entry-0x7fffc458>
  p->stack_top = sp; // top of user stack (within the top stack page)
    80005906:	ba993823          	sd	s1,-1104(s2)
  p->text_off = text_off;
    8000590a:	bda92023          	sw	s10,-1088(s2)
  p->text_filesz = text_filesz;
    8000590e:	db843783          	ld	a5,-584(s0)
    80005912:	bcf92223          	sw	a5,-1084(s2)
  p->text_memsz = text_memsz;
    80005916:	df843783          	ld	a5,-520(s0)
    8000591a:	bcf92423          	sw	a5,-1080(s2)
  p->text_flags = text_flags;
    8000591e:	df043783          	ld	a5,-528(s0)
    80005922:	bcf92623          	sw	a5,-1076(s2)
  p->data_off = data_off;
    80005926:	de843783          	ld	a5,-536(s0)
    8000592a:	bcf92823          	sw	a5,-1072(s2)
  p->data_filesz = data_filesz;
    8000592e:	de043783          	ld	a5,-544(s0)
    80005932:	bcf92a23          	sw	a5,-1068(s2)
  p->data_memsz = data_memsz;
    80005936:	dd843783          	ld	a5,-552(s0)
    8000593a:	bcf92c23          	sw	a5,-1064(s2)
  p->data_flags = data_flags;
    8000593e:	dd043783          	ld	a5,-560(s0)
    80005942:	bcf92e23          	sw	a5,-1060(s2)
  ilock(ip);
    80005946:	854e                	mv	a0,s3
    80005948:	8dbfe0ef          	jal	80004222 <ilock>
  p->exec_ip = idup(ip);
    8000594c:	854e                	mv	a0,s3
    8000594e:	89ffe0ef          	jal	800041ec <idup>
    80005952:	baa93c23          	sd	a0,-1096(s2)
  iunlockput(ip);
    80005956:	854e                	mv	a0,s3
    80005958:	ad5fe0ef          	jal	8000442c <iunlockput>
  end_op();
    8000595c:	b1aff0ef          	jal	80004c76 <end_op>
  printf("[pid %d] INIT-LAZYMAP text=[%p,%p) data=[%p,%p) heap_start=%p stack_top=%p\n",
    80005960:	bb093883          	ld	a7,-1104(s2)
    80005964:	ba893803          	ld	a6,-1112(s2)
    80005968:	ba093783          	ld	a5,-1120(s2)
    8000596c:	b9893703          	ld	a4,-1128(s2)
    80005970:	b9093683          	ld	a3,-1136(s2)
    80005974:	b8893603          	ld	a2,-1144(s2)
    80005978:	030da583          	lw	a1,48(s11)
    8000597c:	00004517          	auipc	a0,0x4
    80005980:	efc50513          	addi	a0,a0,-260 # 80009878 <etext+0x878>
    80005984:	b77fa0ef          	jal	800004fa <printf>
  if(swapfile_create(p) == 0){
    80005988:	856e                	mv	a0,s11
    8000598a:	0f0010ef          	jal	80006a7a <swapfile_create>
    8000598e:	e91d                	bnez	a0,800059c4 <kexec+0x3be>
    printf("[pid %d] SWAPFILE created\n", p->pid);
    80005990:	030da583          	lw	a1,48(s11)
    80005994:	00004517          	auipc	a0,0x4
    80005998:	f3450513          	addi	a0,a0,-204 # 800098c8 <etext+0x8c8>
    8000599c:	b5ffa0ef          	jal	800004fa <printf>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800059a0:	000a051b          	sext.w	a0,s4
    800059a4:	23813983          	ld	s3,568(sp)
    800059a8:	23013a03          	ld	s4,560(sp)
    800059ac:	22813a83          	ld	s5,552(sp)
    800059b0:	21813b83          	ld	s7,536(sp)
    800059b4:	21013c03          	ld	s8,528(sp)
    800059b8:	20813c83          	ld	s9,520(sp)
    800059bc:	20013d03          	ld	s10,512(sp)
    800059c0:	7dfe                	ld	s11,504(sp)
    800059c2:	b535                	j	800057ee <kexec+0x1e8>
    printf("[pid %d] SWAPFILE create failed\n", p->pid);
    800059c4:	030da583          	lw	a1,48(s11)
    800059c8:	00004517          	auipc	a0,0x4
    800059cc:	f2050513          	addi	a0,a0,-224 # 800098e8 <etext+0x8e8>
    800059d0:	b2bfa0ef          	jal	800004fa <printf>
    800059d4:	b7f1                	j	800059a0 <kexec+0x39a>
  sz = PGROUNDUP(sz);
    800059d6:	8aa6                	mv	s5,s1
    800059d8:	bbf9                	j	800057b6 <kexec+0x1b0>
    800059da:	21813b83          	ld	s7,536(sp)
    800059de:	bbed                	j	800057d8 <kexec+0x1d2>
    if(ph.vaddr + ph.memsz > sz)
    800059e0:	00eaf363          	bgeu	s5,a4,800059e6 <kexec+0x3e0>
    800059e4:	8aba                	mv	s5,a4
      text_off = ph.off;
    800059e6:	e2042d03          	lw	s10,-480(s0)
      text_filesz = ph.filesz;
    800059ea:	00060b1b          	sext.w	s6,a2
      text_memsz = ph.memsz;
    800059ee:	0006879b          	sext.w	a5,a3
    800059f2:	def43c23          	sd	a5,-520(s0)
      text_flags = ph.flags;
    800059f6:	deb43823          	sd	a1,-528(s0)
    800059fa:	e0e43423          	sd	a4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800059fe:	2905                	addiw	s2,s2,1
    80005a00:	0384849b          	addiw	s1,s1,56
    80005a04:	e8845783          	lhu	a5,-376(s0)
    80005a08:	d0f953e3          	bge	s2,a5,8000570e <kexec+0x108>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005a0c:	2481                	sext.w	s1,s1
    80005a0e:	03800713          	li	a4,56
    80005a12:	86a6                	mv	a3,s1
    80005a14:	e1840613          	addi	a2,s0,-488
    80005a18:	4581                	li	a1,0
    80005a1a:	854e                	mv	a0,s3
    80005a1c:	b97fe0ef          	jal	800045b2 <readi>
    80005a20:	03800793          	li	a5,56
    80005a24:	d8f519e3          	bne	a0,a5,800057b6 <kexec+0x1b0>
    if(ph.type != ELF_PROG_LOAD)
    80005a28:	e1842783          	lw	a5,-488(s0)
    80005a2c:	fd4799e3          	bne	a5,s4,800059fe <kexec+0x3f8>
    if(ph.memsz < ph.filesz)
    80005a30:	e4043683          	ld	a3,-448(s0)
    80005a34:	e3843603          	ld	a2,-456(s0)
    80005a38:	d6c6efe3          	bltu	a3,a2,800057b6 <kexec+0x1b0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005a3c:	e2843783          	ld	a5,-472(s0)
    80005a40:	00f68733          	add	a4,a3,a5
    80005a44:	d6f769e3          	bltu	a4,a5,800057b6 <kexec+0x1b0>
    if(ph.vaddr % PGSIZE != 0)
    80005a48:	01b7f5b3          	and	a1,a5,s11
    80005a4c:	d60595e3          	bnez	a1,800057b6 <kexec+0x1b0>
    if(ph.flags & 0x1){
    80005a50:	e1c42583          	lw	a1,-484(s0)
    80005a54:	0015f513          	andi	a0,a1,1
    80005a58:	c80505e3          	beqz	a0,800056e2 <kexec+0xdc>
      if(text_start == 0) text_start = ph.vaddr;
    80005a5c:	f80c92e3          	bnez	s9,800059e0 <kexec+0x3da>
    80005a60:	8cbe                	mv	s9,a5
    80005a62:	bfbd                	j	800059e0 <kexec+0x3da>
      if(data_start == 0) data_start = ph.vaddr;
    80005a64:	8c3e                	mv	s8,a5
    80005a66:	b141                	j	800056e6 <kexec+0xe0>

0000000080005a68 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a68:	7179                	addi	sp,sp,-48
    80005a6a:	f406                	sd	ra,40(sp)
    80005a6c:	f022                	sd	s0,32(sp)
    80005a6e:	ec26                	sd	s1,24(sp)
    80005a70:	e84a                	sd	s2,16(sp)
    80005a72:	1800                	addi	s0,sp,48
    80005a74:	892e                	mv	s2,a1
    80005a76:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005a78:	fdc40593          	addi	a1,s0,-36
    80005a7c:	d07fd0ef          	jal	80003782 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005a80:	fdc42703          	lw	a4,-36(s0)
    80005a84:	47bd                	li	a5,15
    80005a86:	02e7e963          	bltu	a5,a4,80005ab8 <argfd+0x50>
    80005a8a:	c18fc0ef          	jal	80001ea2 <myproc>
    80005a8e:	fdc42703          	lw	a4,-36(s0)
    80005a92:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7feeee42>
    80005a96:	078e                	slli	a5,a5,0x3
    80005a98:	953e                	add	a0,a0,a5
    80005a9a:	611c                	ld	a5,0(a0)
    80005a9c:	c385                	beqz	a5,80005abc <argfd+0x54>
    return -1;
  if(pfd)
    80005a9e:	00090463          	beqz	s2,80005aa6 <argfd+0x3e>
    *pfd = fd;
    80005aa2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005aa6:	4501                	li	a0,0
  if(pf)
    80005aa8:	c091                	beqz	s1,80005aac <argfd+0x44>
    *pf = f;
    80005aaa:	e09c                	sd	a5,0(s1)
}
    80005aac:	70a2                	ld	ra,40(sp)
    80005aae:	7402                	ld	s0,32(sp)
    80005ab0:	64e2                	ld	s1,24(sp)
    80005ab2:	6942                	ld	s2,16(sp)
    80005ab4:	6145                	addi	sp,sp,48
    80005ab6:	8082                	ret
    return -1;
    80005ab8:	557d                	li	a0,-1
    80005aba:	bfcd                	j	80005aac <argfd+0x44>
    80005abc:	557d                	li	a0,-1
    80005abe:	b7fd                	j	80005aac <argfd+0x44>

0000000080005ac0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005ac0:	1101                	addi	sp,sp,-32
    80005ac2:	ec06                	sd	ra,24(sp)
    80005ac4:	e822                	sd	s0,16(sp)
    80005ac6:	e426                	sd	s1,8(sp)
    80005ac8:	1000                	addi	s0,sp,32
    80005aca:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005acc:	bd6fc0ef          	jal	80001ea2 <myproc>
    80005ad0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005ad2:	0d050793          	addi	a5,a0,208
    80005ad6:	4501                	li	a0,0
    80005ad8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005ada:	6398                	ld	a4,0(a5)
    80005adc:	cb19                	beqz	a4,80005af2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005ade:	2505                	addiw	a0,a0,1
    80005ae0:	07a1                	addi	a5,a5,8
    80005ae2:	fed51ce3          	bne	a0,a3,80005ada <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005ae6:	557d                	li	a0,-1
}
    80005ae8:	60e2                	ld	ra,24(sp)
    80005aea:	6442                	ld	s0,16(sp)
    80005aec:	64a2                	ld	s1,8(sp)
    80005aee:	6105                	addi	sp,sp,32
    80005af0:	8082                	ret
      p->ofile[fd] = f;
    80005af2:	01a50793          	addi	a5,a0,26
    80005af6:	078e                	slli	a5,a5,0x3
    80005af8:	963e                	add	a2,a2,a5
    80005afa:	e204                	sd	s1,0(a2)
      return fd;
    80005afc:	b7f5                	j	80005ae8 <fdalloc+0x28>

0000000080005afe <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005afe:	715d                	addi	sp,sp,-80
    80005b00:	e486                	sd	ra,72(sp)
    80005b02:	e0a2                	sd	s0,64(sp)
    80005b04:	fc26                	sd	s1,56(sp)
    80005b06:	f84a                	sd	s2,48(sp)
    80005b08:	f44e                	sd	s3,40(sp)
    80005b0a:	ec56                	sd	s5,24(sp)
    80005b0c:	e85a                	sd	s6,16(sp)
    80005b0e:	0880                	addi	s0,sp,80
    80005b10:	8b2e                	mv	s6,a1
    80005b12:	89b2                	mv	s3,a2
    80005b14:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005b16:	fb040593          	addi	a1,s0,-80
    80005b1a:	f39fe0ef          	jal	80004a52 <nameiparent>
    80005b1e:	84aa                	mv	s1,a0
    80005b20:	10050a63          	beqz	a0,80005c34 <create+0x136>
    return 0;

  ilock(dp);
    80005b24:	efefe0ef          	jal	80004222 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005b28:	4601                	li	a2,0
    80005b2a:	fb040593          	addi	a1,s0,-80
    80005b2e:	8526                	mv	a0,s1
    80005b30:	ca3fe0ef          	jal	800047d2 <dirlookup>
    80005b34:	8aaa                	mv	s5,a0
    80005b36:	c129                	beqz	a0,80005b78 <create+0x7a>
    iunlockput(dp);
    80005b38:	8526                	mv	a0,s1
    80005b3a:	8f3fe0ef          	jal	8000442c <iunlockput>
    ilock(ip);
    80005b3e:	8556                	mv	a0,s5
    80005b40:	ee2fe0ef          	jal	80004222 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b44:	4789                	li	a5,2
    80005b46:	02fb1463          	bne	s6,a5,80005b6e <create+0x70>
    80005b4a:	044ad783          	lhu	a5,68(s5)
    80005b4e:	37f9                	addiw	a5,a5,-2
    80005b50:	17c2                	slli	a5,a5,0x30
    80005b52:	93c1                	srli	a5,a5,0x30
    80005b54:	4705                	li	a4,1
    80005b56:	00f76c63          	bltu	a4,a5,80005b6e <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005b5a:	8556                	mv	a0,s5
    80005b5c:	60a6                	ld	ra,72(sp)
    80005b5e:	6406                	ld	s0,64(sp)
    80005b60:	74e2                	ld	s1,56(sp)
    80005b62:	7942                	ld	s2,48(sp)
    80005b64:	79a2                	ld	s3,40(sp)
    80005b66:	6ae2                	ld	s5,24(sp)
    80005b68:	6b42                	ld	s6,16(sp)
    80005b6a:	6161                	addi	sp,sp,80
    80005b6c:	8082                	ret
    iunlockput(ip);
    80005b6e:	8556                	mv	a0,s5
    80005b70:	8bdfe0ef          	jal	8000442c <iunlockput>
    return 0;
    80005b74:	4a81                	li	s5,0
    80005b76:	b7d5                	j	80005b5a <create+0x5c>
    80005b78:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005b7a:	85da                	mv	a1,s6
    80005b7c:	4088                	lw	a0,0(s1)
    80005b7e:	d34fe0ef          	jal	800040b2 <ialloc>
    80005b82:	8a2a                	mv	s4,a0
    80005b84:	cd15                	beqz	a0,80005bc0 <create+0xc2>
  ilock(ip);
    80005b86:	e9cfe0ef          	jal	80004222 <ilock>
  ip->major = major;
    80005b8a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005b8e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005b92:	4905                	li	s2,1
    80005b94:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005b98:	8552                	mv	a0,s4
    80005b9a:	dd4fe0ef          	jal	8000416e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005b9e:	032b0763          	beq	s6,s2,80005bcc <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005ba2:	004a2603          	lw	a2,4(s4)
    80005ba6:	fb040593          	addi	a1,s0,-80
    80005baa:	8526                	mv	a0,s1
    80005bac:	df3fe0ef          	jal	8000499e <dirlink>
    80005bb0:	06054563          	bltz	a0,80005c1a <create+0x11c>
  iunlockput(dp);
    80005bb4:	8526                	mv	a0,s1
    80005bb6:	877fe0ef          	jal	8000442c <iunlockput>
  return ip;
    80005bba:	8ad2                	mv	s5,s4
    80005bbc:	7a02                	ld	s4,32(sp)
    80005bbe:	bf71                	j	80005b5a <create+0x5c>
    iunlockput(dp);
    80005bc0:	8526                	mv	a0,s1
    80005bc2:	86bfe0ef          	jal	8000442c <iunlockput>
    return 0;
    80005bc6:	8ad2                	mv	s5,s4
    80005bc8:	7a02                	ld	s4,32(sp)
    80005bca:	bf41                	j	80005b5a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005bcc:	004a2603          	lw	a2,4(s4)
    80005bd0:	00004597          	auipc	a1,0x4
    80005bd4:	d4058593          	addi	a1,a1,-704 # 80009910 <etext+0x910>
    80005bd8:	8552                	mv	a0,s4
    80005bda:	dc5fe0ef          	jal	8000499e <dirlink>
    80005bde:	02054e63          	bltz	a0,80005c1a <create+0x11c>
    80005be2:	40d0                	lw	a2,4(s1)
    80005be4:	00004597          	auipc	a1,0x4
    80005be8:	d3458593          	addi	a1,a1,-716 # 80009918 <etext+0x918>
    80005bec:	8552                	mv	a0,s4
    80005bee:	db1fe0ef          	jal	8000499e <dirlink>
    80005bf2:	02054463          	bltz	a0,80005c1a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005bf6:	004a2603          	lw	a2,4(s4)
    80005bfa:	fb040593          	addi	a1,s0,-80
    80005bfe:	8526                	mv	a0,s1
    80005c00:	d9ffe0ef          	jal	8000499e <dirlink>
    80005c04:	00054b63          	bltz	a0,80005c1a <create+0x11c>
    dp->nlink++;  // for ".."
    80005c08:	04a4d783          	lhu	a5,74(s1)
    80005c0c:	2785                	addiw	a5,a5,1
    80005c0e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c12:	8526                	mv	a0,s1
    80005c14:	d5afe0ef          	jal	8000416e <iupdate>
    80005c18:	bf71                	j	80005bb4 <create+0xb6>
  ip->nlink = 0;
    80005c1a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005c1e:	8552                	mv	a0,s4
    80005c20:	d4efe0ef          	jal	8000416e <iupdate>
  iunlockput(ip);
    80005c24:	8552                	mv	a0,s4
    80005c26:	807fe0ef          	jal	8000442c <iunlockput>
  iunlockput(dp);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	801fe0ef          	jal	8000442c <iunlockput>
  return 0;
    80005c30:	7a02                	ld	s4,32(sp)
    80005c32:	b725                	j	80005b5a <create+0x5c>
    return 0;
    80005c34:	8aaa                	mv	s5,a0
    80005c36:	b715                	j	80005b5a <create+0x5c>

0000000080005c38 <sys_dup>:
{
    80005c38:	7179                	addi	sp,sp,-48
    80005c3a:	f406                	sd	ra,40(sp)
    80005c3c:	f022                	sd	s0,32(sp)
    80005c3e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005c40:	fd840613          	addi	a2,s0,-40
    80005c44:	4581                	li	a1,0
    80005c46:	4501                	li	a0,0
    80005c48:	e21ff0ef          	jal	80005a68 <argfd>
    return -1;
    80005c4c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005c4e:	02054363          	bltz	a0,80005c74 <sys_dup+0x3c>
    80005c52:	ec26                	sd	s1,24(sp)
    80005c54:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005c56:	fd843903          	ld	s2,-40(s0)
    80005c5a:	854a                	mv	a0,s2
    80005c5c:	e65ff0ef          	jal	80005ac0 <fdalloc>
    80005c60:	84aa                	mv	s1,a0
    return -1;
    80005c62:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005c64:	00054d63          	bltz	a0,80005c7e <sys_dup+0x46>
  filedup(f);
    80005c68:	854a                	mv	a0,s2
    80005c6a:	b68ff0ef          	jal	80004fd2 <filedup>
  return fd;
    80005c6e:	87a6                	mv	a5,s1
    80005c70:	64e2                	ld	s1,24(sp)
    80005c72:	6942                	ld	s2,16(sp)
}
    80005c74:	853e                	mv	a0,a5
    80005c76:	70a2                	ld	ra,40(sp)
    80005c78:	7402                	ld	s0,32(sp)
    80005c7a:	6145                	addi	sp,sp,48
    80005c7c:	8082                	ret
    80005c7e:	64e2                	ld	s1,24(sp)
    80005c80:	6942                	ld	s2,16(sp)
    80005c82:	bfcd                	j	80005c74 <sys_dup+0x3c>

0000000080005c84 <sys_read>:
{
    80005c84:	7179                	addi	sp,sp,-48
    80005c86:	f406                	sd	ra,40(sp)
    80005c88:	f022                	sd	s0,32(sp)
    80005c8a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005c8c:	fd840593          	addi	a1,s0,-40
    80005c90:	4505                	li	a0,1
    80005c92:	b0dfd0ef          	jal	8000379e <argaddr>
  argint(2, &n);
    80005c96:	fe440593          	addi	a1,s0,-28
    80005c9a:	4509                	li	a0,2
    80005c9c:	ae7fd0ef          	jal	80003782 <argint>
  if(argfd(0, 0, &f) < 0)
    80005ca0:	fe840613          	addi	a2,s0,-24
    80005ca4:	4581                	li	a1,0
    80005ca6:	4501                	li	a0,0
    80005ca8:	dc1ff0ef          	jal	80005a68 <argfd>
    80005cac:	87aa                	mv	a5,a0
    return -1;
    80005cae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005cb0:	0007ca63          	bltz	a5,80005cc4 <sys_read+0x40>
  return fileread(f, p, n);
    80005cb4:	fe442603          	lw	a2,-28(s0)
    80005cb8:	fd843583          	ld	a1,-40(s0)
    80005cbc:	fe843503          	ld	a0,-24(s0)
    80005cc0:	c78ff0ef          	jal	80005138 <fileread>
}
    80005cc4:	70a2                	ld	ra,40(sp)
    80005cc6:	7402                	ld	s0,32(sp)
    80005cc8:	6145                	addi	sp,sp,48
    80005cca:	8082                	ret

0000000080005ccc <sys_write>:
{
    80005ccc:	7179                	addi	sp,sp,-48
    80005cce:	f406                	sd	ra,40(sp)
    80005cd0:	f022                	sd	s0,32(sp)
    80005cd2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005cd4:	fd840593          	addi	a1,s0,-40
    80005cd8:	4505                	li	a0,1
    80005cda:	ac5fd0ef          	jal	8000379e <argaddr>
  argint(2, &n);
    80005cde:	fe440593          	addi	a1,s0,-28
    80005ce2:	4509                	li	a0,2
    80005ce4:	a9ffd0ef          	jal	80003782 <argint>
  if(argfd(0, 0, &f) < 0)
    80005ce8:	fe840613          	addi	a2,s0,-24
    80005cec:	4581                	li	a1,0
    80005cee:	4501                	li	a0,0
    80005cf0:	d79ff0ef          	jal	80005a68 <argfd>
    80005cf4:	87aa                	mv	a5,a0
    return -1;
    80005cf6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005cf8:	0007ca63          	bltz	a5,80005d0c <sys_write+0x40>
  return filewrite(f, p, n);
    80005cfc:	fe442603          	lw	a2,-28(s0)
    80005d00:	fd843583          	ld	a1,-40(s0)
    80005d04:	fe843503          	ld	a0,-24(s0)
    80005d08:	ceeff0ef          	jal	800051f6 <filewrite>
}
    80005d0c:	70a2                	ld	ra,40(sp)
    80005d0e:	7402                	ld	s0,32(sp)
    80005d10:	6145                	addi	sp,sp,48
    80005d12:	8082                	ret

0000000080005d14 <sys_close>:
{
    80005d14:	1101                	addi	sp,sp,-32
    80005d16:	ec06                	sd	ra,24(sp)
    80005d18:	e822                	sd	s0,16(sp)
    80005d1a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005d1c:	fe040613          	addi	a2,s0,-32
    80005d20:	fec40593          	addi	a1,s0,-20
    80005d24:	4501                	li	a0,0
    80005d26:	d43ff0ef          	jal	80005a68 <argfd>
    return -1;
    80005d2a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005d2c:	02054063          	bltz	a0,80005d4c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005d30:	972fc0ef          	jal	80001ea2 <myproc>
    80005d34:	fec42783          	lw	a5,-20(s0)
    80005d38:	07e9                	addi	a5,a5,26
    80005d3a:	078e                	slli	a5,a5,0x3
    80005d3c:	953e                	add	a0,a0,a5
    80005d3e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005d42:	fe043503          	ld	a0,-32(s0)
    80005d46:	ad2ff0ef          	jal	80005018 <fileclose>
  return 0;
    80005d4a:	4781                	li	a5,0
}
    80005d4c:	853e                	mv	a0,a5
    80005d4e:	60e2                	ld	ra,24(sp)
    80005d50:	6442                	ld	s0,16(sp)
    80005d52:	6105                	addi	sp,sp,32
    80005d54:	8082                	ret

0000000080005d56 <sys_fstat>:
{
    80005d56:	1101                	addi	sp,sp,-32
    80005d58:	ec06                	sd	ra,24(sp)
    80005d5a:	e822                	sd	s0,16(sp)
    80005d5c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005d5e:	fe040593          	addi	a1,s0,-32
    80005d62:	4505                	li	a0,1
    80005d64:	a3bfd0ef          	jal	8000379e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005d68:	fe840613          	addi	a2,s0,-24
    80005d6c:	4581                	li	a1,0
    80005d6e:	4501                	li	a0,0
    80005d70:	cf9ff0ef          	jal	80005a68 <argfd>
    80005d74:	87aa                	mv	a5,a0
    return -1;
    80005d76:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d78:	0007c863          	bltz	a5,80005d88 <sys_fstat+0x32>
  return filestat(f, st);
    80005d7c:	fe043583          	ld	a1,-32(s0)
    80005d80:	fe843503          	ld	a0,-24(s0)
    80005d84:	b56ff0ef          	jal	800050da <filestat>
}
    80005d88:	60e2                	ld	ra,24(sp)
    80005d8a:	6442                	ld	s0,16(sp)
    80005d8c:	6105                	addi	sp,sp,32
    80005d8e:	8082                	ret

0000000080005d90 <sys_link>:
{
    80005d90:	7169                	addi	sp,sp,-304
    80005d92:	f606                	sd	ra,296(sp)
    80005d94:	f222                	sd	s0,288(sp)
    80005d96:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d98:	08000613          	li	a2,128
    80005d9c:	ed040593          	addi	a1,s0,-304
    80005da0:	4501                	li	a0,0
    80005da2:	a19fd0ef          	jal	800037ba <argstr>
    return -1;
    80005da6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005da8:	0c054e63          	bltz	a0,80005e84 <sys_link+0xf4>
    80005dac:	08000613          	li	a2,128
    80005db0:	f5040593          	addi	a1,s0,-176
    80005db4:	4505                	li	a0,1
    80005db6:	a05fd0ef          	jal	800037ba <argstr>
    return -1;
    80005dba:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005dbc:	0c054463          	bltz	a0,80005e84 <sys_link+0xf4>
    80005dc0:	ee26                	sd	s1,280(sp)
  begin_op();
    80005dc2:	e4bfe0ef          	jal	80004c0c <begin_op>
  if((ip = namei(old)) == 0){
    80005dc6:	ed040513          	addi	a0,s0,-304
    80005dca:	c6ffe0ef          	jal	80004a38 <namei>
    80005dce:	84aa                	mv	s1,a0
    80005dd0:	c53d                	beqz	a0,80005e3e <sys_link+0xae>
  ilock(ip);
    80005dd2:	c50fe0ef          	jal	80004222 <ilock>
  if(ip->type == T_DIR){
    80005dd6:	04449703          	lh	a4,68(s1)
    80005dda:	4785                	li	a5,1
    80005ddc:	06f70663          	beq	a4,a5,80005e48 <sys_link+0xb8>
    80005de0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005de2:	04a4d783          	lhu	a5,74(s1)
    80005de6:	2785                	addiw	a5,a5,1
    80005de8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005dec:	8526                	mv	a0,s1
    80005dee:	b80fe0ef          	jal	8000416e <iupdate>
  iunlock(ip);
    80005df2:	8526                	mv	a0,s1
    80005df4:	cdcfe0ef          	jal	800042d0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005df8:	fd040593          	addi	a1,s0,-48
    80005dfc:	f5040513          	addi	a0,s0,-176
    80005e00:	c53fe0ef          	jal	80004a52 <nameiparent>
    80005e04:	892a                	mv	s2,a0
    80005e06:	cd21                	beqz	a0,80005e5e <sys_link+0xce>
  ilock(dp);
    80005e08:	c1afe0ef          	jal	80004222 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005e0c:	00092703          	lw	a4,0(s2)
    80005e10:	409c                	lw	a5,0(s1)
    80005e12:	04f71363          	bne	a4,a5,80005e58 <sys_link+0xc8>
    80005e16:	40d0                	lw	a2,4(s1)
    80005e18:	fd040593          	addi	a1,s0,-48
    80005e1c:	854a                	mv	a0,s2
    80005e1e:	b81fe0ef          	jal	8000499e <dirlink>
    80005e22:	02054b63          	bltz	a0,80005e58 <sys_link+0xc8>
  iunlockput(dp);
    80005e26:	854a                	mv	a0,s2
    80005e28:	e04fe0ef          	jal	8000442c <iunlockput>
  iput(ip);
    80005e2c:	8526                	mv	a0,s1
    80005e2e:	d76fe0ef          	jal	800043a4 <iput>
  end_op();
    80005e32:	e45fe0ef          	jal	80004c76 <end_op>
  return 0;
    80005e36:	4781                	li	a5,0
    80005e38:	64f2                	ld	s1,280(sp)
    80005e3a:	6952                	ld	s2,272(sp)
    80005e3c:	a0a1                	j	80005e84 <sys_link+0xf4>
    end_op();
    80005e3e:	e39fe0ef          	jal	80004c76 <end_op>
    return -1;
    80005e42:	57fd                	li	a5,-1
    80005e44:	64f2                	ld	s1,280(sp)
    80005e46:	a83d                	j	80005e84 <sys_link+0xf4>
    iunlockput(ip);
    80005e48:	8526                	mv	a0,s1
    80005e4a:	de2fe0ef          	jal	8000442c <iunlockput>
    end_op();
    80005e4e:	e29fe0ef          	jal	80004c76 <end_op>
    return -1;
    80005e52:	57fd                	li	a5,-1
    80005e54:	64f2                	ld	s1,280(sp)
    80005e56:	a03d                	j	80005e84 <sys_link+0xf4>
    iunlockput(dp);
    80005e58:	854a                	mv	a0,s2
    80005e5a:	dd2fe0ef          	jal	8000442c <iunlockput>
  ilock(ip);
    80005e5e:	8526                	mv	a0,s1
    80005e60:	bc2fe0ef          	jal	80004222 <ilock>
  ip->nlink--;
    80005e64:	04a4d783          	lhu	a5,74(s1)
    80005e68:	37fd                	addiw	a5,a5,-1
    80005e6a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e6e:	8526                	mv	a0,s1
    80005e70:	afefe0ef          	jal	8000416e <iupdate>
  iunlockput(ip);
    80005e74:	8526                	mv	a0,s1
    80005e76:	db6fe0ef          	jal	8000442c <iunlockput>
  end_op();
    80005e7a:	dfdfe0ef          	jal	80004c76 <end_op>
  return -1;
    80005e7e:	57fd                	li	a5,-1
    80005e80:	64f2                	ld	s1,280(sp)
    80005e82:	6952                	ld	s2,272(sp)
}
    80005e84:	853e                	mv	a0,a5
    80005e86:	70b2                	ld	ra,296(sp)
    80005e88:	7412                	ld	s0,288(sp)
    80005e8a:	6155                	addi	sp,sp,304
    80005e8c:	8082                	ret

0000000080005e8e <sys_unlink>:
{
    80005e8e:	7151                	addi	sp,sp,-240
    80005e90:	f586                	sd	ra,232(sp)
    80005e92:	f1a2                	sd	s0,224(sp)
    80005e94:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005e96:	08000613          	li	a2,128
    80005e9a:	f3040593          	addi	a1,s0,-208
    80005e9e:	4501                	li	a0,0
    80005ea0:	91bfd0ef          	jal	800037ba <argstr>
    80005ea4:	16054063          	bltz	a0,80006004 <sys_unlink+0x176>
    80005ea8:	eda6                	sd	s1,216(sp)
  begin_op();
    80005eaa:	d63fe0ef          	jal	80004c0c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005eae:	fb040593          	addi	a1,s0,-80
    80005eb2:	f3040513          	addi	a0,s0,-208
    80005eb6:	b9dfe0ef          	jal	80004a52 <nameiparent>
    80005eba:	84aa                	mv	s1,a0
    80005ebc:	c945                	beqz	a0,80005f6c <sys_unlink+0xde>
  ilock(dp);
    80005ebe:	b64fe0ef          	jal	80004222 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005ec2:	00004597          	auipc	a1,0x4
    80005ec6:	a4e58593          	addi	a1,a1,-1458 # 80009910 <etext+0x910>
    80005eca:	fb040513          	addi	a0,s0,-80
    80005ece:	8effe0ef          	jal	800047bc <namecmp>
    80005ed2:	10050e63          	beqz	a0,80005fee <sys_unlink+0x160>
    80005ed6:	00004597          	auipc	a1,0x4
    80005eda:	a4258593          	addi	a1,a1,-1470 # 80009918 <etext+0x918>
    80005ede:	fb040513          	addi	a0,s0,-80
    80005ee2:	8dbfe0ef          	jal	800047bc <namecmp>
    80005ee6:	10050463          	beqz	a0,80005fee <sys_unlink+0x160>
    80005eea:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005eec:	f2c40613          	addi	a2,s0,-212
    80005ef0:	fb040593          	addi	a1,s0,-80
    80005ef4:	8526                	mv	a0,s1
    80005ef6:	8ddfe0ef          	jal	800047d2 <dirlookup>
    80005efa:	892a                	mv	s2,a0
    80005efc:	0e050863          	beqz	a0,80005fec <sys_unlink+0x15e>
  ilock(ip);
    80005f00:	b22fe0ef          	jal	80004222 <ilock>
  if(ip->nlink < 1)
    80005f04:	04a91783          	lh	a5,74(s2)
    80005f08:	06f05763          	blez	a5,80005f76 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005f0c:	04491703          	lh	a4,68(s2)
    80005f10:	4785                	li	a5,1
    80005f12:	06f70963          	beq	a4,a5,80005f84 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005f16:	4641                	li	a2,16
    80005f18:	4581                	li	a1,0
    80005f1a:	fc040513          	addi	a0,s0,-64
    80005f1e:	d85fa0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f22:	4741                	li	a4,16
    80005f24:	f2c42683          	lw	a3,-212(s0)
    80005f28:	fc040613          	addi	a2,s0,-64
    80005f2c:	4581                	li	a1,0
    80005f2e:	8526                	mv	a0,s1
    80005f30:	f7efe0ef          	jal	800046ae <writei>
    80005f34:	47c1                	li	a5,16
    80005f36:	08f51b63          	bne	a0,a5,80005fcc <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005f3a:	04491703          	lh	a4,68(s2)
    80005f3e:	4785                	li	a5,1
    80005f40:	08f70d63          	beq	a4,a5,80005fda <sys_unlink+0x14c>
  iunlockput(dp);
    80005f44:	8526                	mv	a0,s1
    80005f46:	ce6fe0ef          	jal	8000442c <iunlockput>
  ip->nlink--;
    80005f4a:	04a95783          	lhu	a5,74(s2)
    80005f4e:	37fd                	addiw	a5,a5,-1
    80005f50:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005f54:	854a                	mv	a0,s2
    80005f56:	a18fe0ef          	jal	8000416e <iupdate>
  iunlockput(ip);
    80005f5a:	854a                	mv	a0,s2
    80005f5c:	cd0fe0ef          	jal	8000442c <iunlockput>
  end_op();
    80005f60:	d17fe0ef          	jal	80004c76 <end_op>
  return 0;
    80005f64:	4501                	li	a0,0
    80005f66:	64ee                	ld	s1,216(sp)
    80005f68:	694e                	ld	s2,208(sp)
    80005f6a:	a849                	j	80005ffc <sys_unlink+0x16e>
    end_op();
    80005f6c:	d0bfe0ef          	jal	80004c76 <end_op>
    return -1;
    80005f70:	557d                	li	a0,-1
    80005f72:	64ee                	ld	s1,216(sp)
    80005f74:	a061                	j	80005ffc <sys_unlink+0x16e>
    80005f76:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005f78:	00004517          	auipc	a0,0x4
    80005f7c:	9a850513          	addi	a0,a0,-1624 # 80009920 <etext+0x920>
    80005f80:	861fa0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f84:	04c92703          	lw	a4,76(s2)
    80005f88:	02000793          	li	a5,32
    80005f8c:	f8e7f5e3          	bgeu	a5,a4,80005f16 <sys_unlink+0x88>
    80005f90:	e5ce                	sd	s3,200(sp)
    80005f92:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f96:	4741                	li	a4,16
    80005f98:	86ce                	mv	a3,s3
    80005f9a:	f1840613          	addi	a2,s0,-232
    80005f9e:	4581                	li	a1,0
    80005fa0:	854a                	mv	a0,s2
    80005fa2:	e10fe0ef          	jal	800045b2 <readi>
    80005fa6:	47c1                	li	a5,16
    80005fa8:	00f51c63          	bne	a0,a5,80005fc0 <sys_unlink+0x132>
    if(de.inum != 0)
    80005fac:	f1845783          	lhu	a5,-232(s0)
    80005fb0:	efa1                	bnez	a5,80006008 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fb2:	29c1                	addiw	s3,s3,16
    80005fb4:	04c92783          	lw	a5,76(s2)
    80005fb8:	fcf9efe3          	bltu	s3,a5,80005f96 <sys_unlink+0x108>
    80005fbc:	69ae                	ld	s3,200(sp)
    80005fbe:	bfa1                	j	80005f16 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005fc0:	00004517          	auipc	a0,0x4
    80005fc4:	97850513          	addi	a0,a0,-1672 # 80009938 <etext+0x938>
    80005fc8:	819fa0ef          	jal	800007e0 <panic>
    80005fcc:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005fce:	00004517          	auipc	a0,0x4
    80005fd2:	98250513          	addi	a0,a0,-1662 # 80009950 <etext+0x950>
    80005fd6:	80bfa0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005fda:	04a4d783          	lhu	a5,74(s1)
    80005fde:	37fd                	addiw	a5,a5,-1
    80005fe0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005fe4:	8526                	mv	a0,s1
    80005fe6:	988fe0ef          	jal	8000416e <iupdate>
    80005fea:	bfa9                	j	80005f44 <sys_unlink+0xb6>
    80005fec:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005fee:	8526                	mv	a0,s1
    80005ff0:	c3cfe0ef          	jal	8000442c <iunlockput>
  end_op();
    80005ff4:	c83fe0ef          	jal	80004c76 <end_op>
  return -1;
    80005ff8:	557d                	li	a0,-1
    80005ffa:	64ee                	ld	s1,216(sp)
}
    80005ffc:	70ae                	ld	ra,232(sp)
    80005ffe:	740e                	ld	s0,224(sp)
    80006000:	616d                	addi	sp,sp,240
    80006002:	8082                	ret
    return -1;
    80006004:	557d                	li	a0,-1
    80006006:	bfdd                	j	80005ffc <sys_unlink+0x16e>
    iunlockput(ip);
    80006008:	854a                	mv	a0,s2
    8000600a:	c22fe0ef          	jal	8000442c <iunlockput>
    goto bad;
    8000600e:	694e                	ld	s2,208(sp)
    80006010:	69ae                	ld	s3,200(sp)
    80006012:	bff1                	j	80005fee <sys_unlink+0x160>

0000000080006014 <sys_open>:

uint64
sys_open(void)
{
    80006014:	7131                	addi	sp,sp,-192
    80006016:	fd06                	sd	ra,184(sp)
    80006018:	f922                	sd	s0,176(sp)
    8000601a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000601c:	f4c40593          	addi	a1,s0,-180
    80006020:	4505                	li	a0,1
    80006022:	f60fd0ef          	jal	80003782 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006026:	08000613          	li	a2,128
    8000602a:	f5040593          	addi	a1,s0,-176
    8000602e:	4501                	li	a0,0
    80006030:	f8afd0ef          	jal	800037ba <argstr>
    80006034:	87aa                	mv	a5,a0
    return -1;
    80006036:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006038:	0a07c263          	bltz	a5,800060dc <sys_open+0xc8>
    8000603c:	f526                	sd	s1,168(sp)

  begin_op();
    8000603e:	bcffe0ef          	jal	80004c0c <begin_op>

  if(omode & O_CREATE){
    80006042:	f4c42783          	lw	a5,-180(s0)
    80006046:	2007f793          	andi	a5,a5,512
    8000604a:	c3d5                	beqz	a5,800060ee <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000604c:	4681                	li	a3,0
    8000604e:	4601                	li	a2,0
    80006050:	4589                	li	a1,2
    80006052:	f5040513          	addi	a0,s0,-176
    80006056:	aa9ff0ef          	jal	80005afe <create>
    8000605a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000605c:	c541                	beqz	a0,800060e4 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000605e:	04449703          	lh	a4,68(s1)
    80006062:	478d                	li	a5,3
    80006064:	00f71763          	bne	a4,a5,80006072 <sys_open+0x5e>
    80006068:	0464d703          	lhu	a4,70(s1)
    8000606c:	47a5                	li	a5,9
    8000606e:	0ae7ed63          	bltu	a5,a4,80006128 <sys_open+0x114>
    80006072:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006074:	f01fe0ef          	jal	80004f74 <filealloc>
    80006078:	892a                	mv	s2,a0
    8000607a:	c179                	beqz	a0,80006140 <sys_open+0x12c>
    8000607c:	ed4e                	sd	s3,152(sp)
    8000607e:	a43ff0ef          	jal	80005ac0 <fdalloc>
    80006082:	89aa                	mv	s3,a0
    80006084:	0a054a63          	bltz	a0,80006138 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006088:	04449703          	lh	a4,68(s1)
    8000608c:	478d                	li	a5,3
    8000608e:	0cf70263          	beq	a4,a5,80006152 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006092:	4789                	li	a5,2
    80006094:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006098:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000609c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800060a0:	f4c42783          	lw	a5,-180(s0)
    800060a4:	0017c713          	xori	a4,a5,1
    800060a8:	8b05                	andi	a4,a4,1
    800060aa:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800060ae:	0037f713          	andi	a4,a5,3
    800060b2:	00e03733          	snez	a4,a4
    800060b6:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800060ba:	4007f793          	andi	a5,a5,1024
    800060be:	c791                	beqz	a5,800060ca <sys_open+0xb6>
    800060c0:	04449703          	lh	a4,68(s1)
    800060c4:	4789                	li	a5,2
    800060c6:	08f70d63          	beq	a4,a5,80006160 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800060ca:	8526                	mv	a0,s1
    800060cc:	a04fe0ef          	jal	800042d0 <iunlock>
  end_op();
    800060d0:	ba7fe0ef          	jal	80004c76 <end_op>

  return fd;
    800060d4:	854e                	mv	a0,s3
    800060d6:	74aa                	ld	s1,168(sp)
    800060d8:	790a                	ld	s2,160(sp)
    800060da:	69ea                	ld	s3,152(sp)
}
    800060dc:	70ea                	ld	ra,184(sp)
    800060de:	744a                	ld	s0,176(sp)
    800060e0:	6129                	addi	sp,sp,192
    800060e2:	8082                	ret
      end_op();
    800060e4:	b93fe0ef          	jal	80004c76 <end_op>
      return -1;
    800060e8:	557d                	li	a0,-1
    800060ea:	74aa                	ld	s1,168(sp)
    800060ec:	bfc5                	j	800060dc <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800060ee:	f5040513          	addi	a0,s0,-176
    800060f2:	947fe0ef          	jal	80004a38 <namei>
    800060f6:	84aa                	mv	s1,a0
    800060f8:	c11d                	beqz	a0,8000611e <sys_open+0x10a>
    ilock(ip);
    800060fa:	928fe0ef          	jal	80004222 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800060fe:	04449703          	lh	a4,68(s1)
    80006102:	4785                	li	a5,1
    80006104:	f4f71de3          	bne	a4,a5,8000605e <sys_open+0x4a>
    80006108:	f4c42783          	lw	a5,-180(s0)
    8000610c:	d3bd                	beqz	a5,80006072 <sys_open+0x5e>
      iunlockput(ip);
    8000610e:	8526                	mv	a0,s1
    80006110:	b1cfe0ef          	jal	8000442c <iunlockput>
      end_op();
    80006114:	b63fe0ef          	jal	80004c76 <end_op>
      return -1;
    80006118:	557d                	li	a0,-1
    8000611a:	74aa                	ld	s1,168(sp)
    8000611c:	b7c1                	j	800060dc <sys_open+0xc8>
      end_op();
    8000611e:	b59fe0ef          	jal	80004c76 <end_op>
      return -1;
    80006122:	557d                	li	a0,-1
    80006124:	74aa                	ld	s1,168(sp)
    80006126:	bf5d                	j	800060dc <sys_open+0xc8>
    iunlockput(ip);
    80006128:	8526                	mv	a0,s1
    8000612a:	b02fe0ef          	jal	8000442c <iunlockput>
    end_op();
    8000612e:	b49fe0ef          	jal	80004c76 <end_op>
    return -1;
    80006132:	557d                	li	a0,-1
    80006134:	74aa                	ld	s1,168(sp)
    80006136:	b75d                	j	800060dc <sys_open+0xc8>
      fileclose(f);
    80006138:	854a                	mv	a0,s2
    8000613a:	edffe0ef          	jal	80005018 <fileclose>
    8000613e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006140:	8526                	mv	a0,s1
    80006142:	aeafe0ef          	jal	8000442c <iunlockput>
    end_op();
    80006146:	b31fe0ef          	jal	80004c76 <end_op>
    return -1;
    8000614a:	557d                	li	a0,-1
    8000614c:	74aa                	ld	s1,168(sp)
    8000614e:	790a                	ld	s2,160(sp)
    80006150:	b771                	j	800060dc <sys_open+0xc8>
    f->type = FD_DEVICE;
    80006152:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80006156:	04649783          	lh	a5,70(s1)
    8000615a:	02f91223          	sh	a5,36(s2)
    8000615e:	bf3d                	j	8000609c <sys_open+0x88>
    itrunc(ip);
    80006160:	8526                	mv	a0,s1
    80006162:	9aefe0ef          	jal	80004310 <itrunc>
    80006166:	b795                	j	800060ca <sys_open+0xb6>

0000000080006168 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006168:	7175                	addi	sp,sp,-144
    8000616a:	e506                	sd	ra,136(sp)
    8000616c:	e122                	sd	s0,128(sp)
    8000616e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006170:	a9dfe0ef          	jal	80004c0c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006174:	08000613          	li	a2,128
    80006178:	f7040593          	addi	a1,s0,-144
    8000617c:	4501                	li	a0,0
    8000617e:	e3cfd0ef          	jal	800037ba <argstr>
    80006182:	02054363          	bltz	a0,800061a8 <sys_mkdir+0x40>
    80006186:	4681                	li	a3,0
    80006188:	4601                	li	a2,0
    8000618a:	4585                	li	a1,1
    8000618c:	f7040513          	addi	a0,s0,-144
    80006190:	96fff0ef          	jal	80005afe <create>
    80006194:	c911                	beqz	a0,800061a8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006196:	a96fe0ef          	jal	8000442c <iunlockput>
  end_op();
    8000619a:	addfe0ef          	jal	80004c76 <end_op>
  return 0;
    8000619e:	4501                	li	a0,0
}
    800061a0:	60aa                	ld	ra,136(sp)
    800061a2:	640a                	ld	s0,128(sp)
    800061a4:	6149                	addi	sp,sp,144
    800061a6:	8082                	ret
    end_op();
    800061a8:	acffe0ef          	jal	80004c76 <end_op>
    return -1;
    800061ac:	557d                	li	a0,-1
    800061ae:	bfcd                	j	800061a0 <sys_mkdir+0x38>

00000000800061b0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800061b0:	7135                	addi	sp,sp,-160
    800061b2:	ed06                	sd	ra,152(sp)
    800061b4:	e922                	sd	s0,144(sp)
    800061b6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800061b8:	a55fe0ef          	jal	80004c0c <begin_op>
  argint(1, &major);
    800061bc:	f6c40593          	addi	a1,s0,-148
    800061c0:	4505                	li	a0,1
    800061c2:	dc0fd0ef          	jal	80003782 <argint>
  argint(2, &minor);
    800061c6:	f6840593          	addi	a1,s0,-152
    800061ca:	4509                	li	a0,2
    800061cc:	db6fd0ef          	jal	80003782 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800061d0:	08000613          	li	a2,128
    800061d4:	f7040593          	addi	a1,s0,-144
    800061d8:	4501                	li	a0,0
    800061da:	de0fd0ef          	jal	800037ba <argstr>
    800061de:	02054563          	bltz	a0,80006208 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800061e2:	f6841683          	lh	a3,-152(s0)
    800061e6:	f6c41603          	lh	a2,-148(s0)
    800061ea:	458d                	li	a1,3
    800061ec:	f7040513          	addi	a0,s0,-144
    800061f0:	90fff0ef          	jal	80005afe <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800061f4:	c911                	beqz	a0,80006208 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061f6:	a36fe0ef          	jal	8000442c <iunlockput>
  end_op();
    800061fa:	a7dfe0ef          	jal	80004c76 <end_op>
  return 0;
    800061fe:	4501                	li	a0,0
}
    80006200:	60ea                	ld	ra,152(sp)
    80006202:	644a                	ld	s0,144(sp)
    80006204:	610d                	addi	sp,sp,160
    80006206:	8082                	ret
    end_op();
    80006208:	a6ffe0ef          	jal	80004c76 <end_op>
    return -1;
    8000620c:	557d                	li	a0,-1
    8000620e:	bfcd                	j	80006200 <sys_mknod+0x50>

0000000080006210 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006210:	7135                	addi	sp,sp,-160
    80006212:	ed06                	sd	ra,152(sp)
    80006214:	e922                	sd	s0,144(sp)
    80006216:	e14a                	sd	s2,128(sp)
    80006218:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000621a:	c89fb0ef          	jal	80001ea2 <myproc>
    8000621e:	892a                	mv	s2,a0
  
  begin_op();
    80006220:	9edfe0ef          	jal	80004c0c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006224:	08000613          	li	a2,128
    80006228:	f6040593          	addi	a1,s0,-160
    8000622c:	4501                	li	a0,0
    8000622e:	d8cfd0ef          	jal	800037ba <argstr>
    80006232:	04054363          	bltz	a0,80006278 <sys_chdir+0x68>
    80006236:	e526                	sd	s1,136(sp)
    80006238:	f6040513          	addi	a0,s0,-160
    8000623c:	ffcfe0ef          	jal	80004a38 <namei>
    80006240:	84aa                	mv	s1,a0
    80006242:	c915                	beqz	a0,80006276 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80006244:	fdffd0ef          	jal	80004222 <ilock>
  if(ip->type != T_DIR){
    80006248:	04449703          	lh	a4,68(s1)
    8000624c:	4785                	li	a5,1
    8000624e:	02f71963          	bne	a4,a5,80006280 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006252:	8526                	mv	a0,s1
    80006254:	87cfe0ef          	jal	800042d0 <iunlock>
  iput(p->cwd);
    80006258:	15093503          	ld	a0,336(s2)
    8000625c:	948fe0ef          	jal	800043a4 <iput>
  end_op();
    80006260:	a17fe0ef          	jal	80004c76 <end_op>
  p->cwd = ip;
    80006264:	14993823          	sd	s1,336(s2)
  return 0;
    80006268:	4501                	li	a0,0
    8000626a:	64aa                	ld	s1,136(sp)
}
    8000626c:	60ea                	ld	ra,152(sp)
    8000626e:	644a                	ld	s0,144(sp)
    80006270:	690a                	ld	s2,128(sp)
    80006272:	610d                	addi	sp,sp,160
    80006274:	8082                	ret
    80006276:	64aa                	ld	s1,136(sp)
    end_op();
    80006278:	9fffe0ef          	jal	80004c76 <end_op>
    return -1;
    8000627c:	557d                	li	a0,-1
    8000627e:	b7fd                	j	8000626c <sys_chdir+0x5c>
    iunlockput(ip);
    80006280:	8526                	mv	a0,s1
    80006282:	9aafe0ef          	jal	8000442c <iunlockput>
    end_op();
    80006286:	9f1fe0ef          	jal	80004c76 <end_op>
    return -1;
    8000628a:	557d                	li	a0,-1
    8000628c:	64aa                	ld	s1,136(sp)
    8000628e:	bff9                	j	8000626c <sys_chdir+0x5c>

0000000080006290 <sys_exec>:

uint64
sys_exec(void)
{
    80006290:	7121                	addi	sp,sp,-448
    80006292:	ff06                	sd	ra,440(sp)
    80006294:	fb22                	sd	s0,432(sp)
    80006296:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006298:	e4840593          	addi	a1,s0,-440
    8000629c:	4505                	li	a0,1
    8000629e:	d00fd0ef          	jal	8000379e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800062a2:	08000613          	li	a2,128
    800062a6:	f5040593          	addi	a1,s0,-176
    800062aa:	4501                	li	a0,0
    800062ac:	d0efd0ef          	jal	800037ba <argstr>
    800062b0:	87aa                	mv	a5,a0
    return -1;
    800062b2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800062b4:	0c07c463          	bltz	a5,8000637c <sys_exec+0xec>
    800062b8:	f726                	sd	s1,424(sp)
    800062ba:	f34a                	sd	s2,416(sp)
    800062bc:	ef4e                	sd	s3,408(sp)
    800062be:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800062c0:	10000613          	li	a2,256
    800062c4:	4581                	li	a1,0
    800062c6:	e5040513          	addi	a0,s0,-432
    800062ca:	9d9fa0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800062ce:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800062d2:	89a6                	mv	s3,s1
    800062d4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800062d6:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800062da:	00391513          	slli	a0,s2,0x3
    800062de:	e4040593          	addi	a1,s0,-448
    800062e2:	e4843783          	ld	a5,-440(s0)
    800062e6:	953e                	add	a0,a0,a5
    800062e8:	c10fd0ef          	jal	800036f8 <fetchaddr>
    800062ec:	02054663          	bltz	a0,80006318 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800062f0:	e4043783          	ld	a5,-448(s0)
    800062f4:	c3a9                	beqz	a5,80006336 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800062f6:	809fa0ef          	jal	80000afe <kalloc>
    800062fa:	85aa                	mv	a1,a0
    800062fc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006300:	cd01                	beqz	a0,80006318 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006302:	6605                	lui	a2,0x1
    80006304:	e4043503          	ld	a0,-448(s0)
    80006308:	c3afd0ef          	jal	80003742 <fetchstr>
    8000630c:	00054663          	bltz	a0,80006318 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80006310:	0905                	addi	s2,s2,1
    80006312:	09a1                	addi	s3,s3,8
    80006314:	fd4913e3          	bne	s2,s4,800062da <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006318:	f5040913          	addi	s2,s0,-176
    8000631c:	6088                	ld	a0,0(s1)
    8000631e:	c931                	beqz	a0,80006372 <sys_exec+0xe2>
    kfree(argv[i]);
    80006320:	efcfa0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006324:	04a1                	addi	s1,s1,8
    80006326:	ff249be3          	bne	s1,s2,8000631c <sys_exec+0x8c>
  return -1;
    8000632a:	557d                	li	a0,-1
    8000632c:	74ba                	ld	s1,424(sp)
    8000632e:	791a                	ld	s2,416(sp)
    80006330:	69fa                	ld	s3,408(sp)
    80006332:	6a5a                	ld	s4,400(sp)
    80006334:	a0a1                	j	8000637c <sys_exec+0xec>
      argv[i] = 0;
    80006336:	0009079b          	sext.w	a5,s2
    8000633a:	078e                	slli	a5,a5,0x3
    8000633c:	fd078793          	addi	a5,a5,-48
    80006340:	97a2                	add	a5,a5,s0
    80006342:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80006346:	e5040593          	addi	a1,s0,-432
    8000634a:	f5040513          	addi	a0,s0,-176
    8000634e:	ab8ff0ef          	jal	80005606 <kexec>
    80006352:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006354:	f5040993          	addi	s3,s0,-176
    80006358:	6088                	ld	a0,0(s1)
    8000635a:	c511                	beqz	a0,80006366 <sys_exec+0xd6>
    kfree(argv[i]);
    8000635c:	ec0fa0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006360:	04a1                	addi	s1,s1,8
    80006362:	ff349be3          	bne	s1,s3,80006358 <sys_exec+0xc8>
  return ret;
    80006366:	854a                	mv	a0,s2
    80006368:	74ba                	ld	s1,424(sp)
    8000636a:	791a                	ld	s2,416(sp)
    8000636c:	69fa                	ld	s3,408(sp)
    8000636e:	6a5a                	ld	s4,400(sp)
    80006370:	a031                	j	8000637c <sys_exec+0xec>
  return -1;
    80006372:	557d                	li	a0,-1
    80006374:	74ba                	ld	s1,424(sp)
    80006376:	791a                	ld	s2,416(sp)
    80006378:	69fa                	ld	s3,408(sp)
    8000637a:	6a5a                	ld	s4,400(sp)
}
    8000637c:	70fa                	ld	ra,440(sp)
    8000637e:	745a                	ld	s0,432(sp)
    80006380:	6139                	addi	sp,sp,448
    80006382:	8082                	ret

0000000080006384 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006384:	7139                	addi	sp,sp,-64
    80006386:	fc06                	sd	ra,56(sp)
    80006388:	f822                	sd	s0,48(sp)
    8000638a:	f426                	sd	s1,40(sp)
    8000638c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000638e:	b15fb0ef          	jal	80001ea2 <myproc>
    80006392:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006394:	fd840593          	addi	a1,s0,-40
    80006398:	4501                	li	a0,0
    8000639a:	c04fd0ef          	jal	8000379e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000639e:	fc840593          	addi	a1,s0,-56
    800063a2:	fd040513          	addi	a0,s0,-48
    800063a6:	f7dfe0ef          	jal	80005322 <pipealloc>
    return -1;
    800063aa:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800063ac:	0a054463          	bltz	a0,80006454 <sys_pipe+0xd0>
  fd0 = -1;
    800063b0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800063b4:	fd043503          	ld	a0,-48(s0)
    800063b8:	f08ff0ef          	jal	80005ac0 <fdalloc>
    800063bc:	fca42223          	sw	a0,-60(s0)
    800063c0:	08054163          	bltz	a0,80006442 <sys_pipe+0xbe>
    800063c4:	fc843503          	ld	a0,-56(s0)
    800063c8:	ef8ff0ef          	jal	80005ac0 <fdalloc>
    800063cc:	fca42023          	sw	a0,-64(s0)
    800063d0:	06054063          	bltz	a0,80006430 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063d4:	4691                	li	a3,4
    800063d6:	fc440613          	addi	a2,s0,-60
    800063da:	fd843583          	ld	a1,-40(s0)
    800063de:	68a8                	ld	a0,80(s1)
    800063e0:	ea0fb0ef          	jal	80001a80 <copyout>
    800063e4:	00054e63          	bltz	a0,80006400 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800063e8:	4691                	li	a3,4
    800063ea:	fc040613          	addi	a2,s0,-64
    800063ee:	fd843583          	ld	a1,-40(s0)
    800063f2:	0591                	addi	a1,a1,4
    800063f4:	68a8                	ld	a0,80(s1)
    800063f6:	e8afb0ef          	jal	80001a80 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800063fa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063fc:	04055c63          	bgez	a0,80006454 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80006400:	fc442783          	lw	a5,-60(s0)
    80006404:	07e9                	addi	a5,a5,26
    80006406:	078e                	slli	a5,a5,0x3
    80006408:	97a6                	add	a5,a5,s1
    8000640a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000640e:	fc042783          	lw	a5,-64(s0)
    80006412:	07e9                	addi	a5,a5,26
    80006414:	078e                	slli	a5,a5,0x3
    80006416:	94be                	add	s1,s1,a5
    80006418:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000641c:	fd043503          	ld	a0,-48(s0)
    80006420:	bf9fe0ef          	jal	80005018 <fileclose>
    fileclose(wf);
    80006424:	fc843503          	ld	a0,-56(s0)
    80006428:	bf1fe0ef          	jal	80005018 <fileclose>
    return -1;
    8000642c:	57fd                	li	a5,-1
    8000642e:	a01d                	j	80006454 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80006430:	fc442783          	lw	a5,-60(s0)
    80006434:	0007c763          	bltz	a5,80006442 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80006438:	07e9                	addi	a5,a5,26
    8000643a:	078e                	slli	a5,a5,0x3
    8000643c:	97a6                	add	a5,a5,s1
    8000643e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006442:	fd043503          	ld	a0,-48(s0)
    80006446:	bd3fe0ef          	jal	80005018 <fileclose>
    fileclose(wf);
    8000644a:	fc843503          	ld	a0,-56(s0)
    8000644e:	bcbfe0ef          	jal	80005018 <fileclose>
    return -1;
    80006452:	57fd                	li	a5,-1
}
    80006454:	853e                	mv	a0,a5
    80006456:	70e2                	ld	ra,56(sp)
    80006458:	7442                	ld	s0,48(sp)
    8000645a:	74a2                	ld	s1,40(sp)
    8000645c:	6121                	addi	sp,sp,64
    8000645e:	8082                	ret

0000000080006460 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006460:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006462:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006464:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006466:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006468:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000646a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000646c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000646e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006470:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006472:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006474:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006476:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006478:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000647a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000647c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000647e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80006480:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80006482:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80006484:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80006486:	982fd0ef          	jal	80003608 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000648a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000648c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000648e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006490:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006492:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006494:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006496:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006498:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000649a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000649c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000649e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800064a0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800064a2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800064a4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800064a6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800064a8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800064aa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800064ac:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800064ae:	10200073          	sret
	...

00000000800064be <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800064be:	1141                	addi	sp,sp,-16
    800064c0:	e422                	sd	s0,8(sp)
    800064c2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800064c4:	0c0007b7          	lui	a5,0xc000
    800064c8:	4705                	li	a4,1
    800064ca:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800064cc:	0c0007b7          	lui	a5,0xc000
    800064d0:	c3d8                	sw	a4,4(a5)
}
    800064d2:	6422                	ld	s0,8(sp)
    800064d4:	0141                	addi	sp,sp,16
    800064d6:	8082                	ret

00000000800064d8 <plicinithart>:

void
plicinithart(void)
{
    800064d8:	1141                	addi	sp,sp,-16
    800064da:	e406                	sd	ra,8(sp)
    800064dc:	e022                	sd	s0,0(sp)
    800064de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064e0:	997fb0ef          	jal	80001e76 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800064e4:	0085171b          	slliw	a4,a0,0x8
    800064e8:	0c0027b7          	lui	a5,0xc002
    800064ec:	97ba                	add	a5,a5,a4
    800064ee:	40200713          	li	a4,1026
    800064f2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800064f6:	00d5151b          	slliw	a0,a0,0xd
    800064fa:	0c2017b7          	lui	a5,0xc201
    800064fe:	97aa                	add	a5,a5,a0
    80006500:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006504:	60a2                	ld	ra,8(sp)
    80006506:	6402                	ld	s0,0(sp)
    80006508:	0141                	addi	sp,sp,16
    8000650a:	8082                	ret

000000008000650c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000650c:	1141                	addi	sp,sp,-16
    8000650e:	e406                	sd	ra,8(sp)
    80006510:	e022                	sd	s0,0(sp)
    80006512:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006514:	963fb0ef          	jal	80001e76 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006518:	00d5151b          	slliw	a0,a0,0xd
    8000651c:	0c2017b7          	lui	a5,0xc201
    80006520:	97aa                	add	a5,a5,a0
  return irq;
}
    80006522:	43c8                	lw	a0,4(a5)
    80006524:	60a2                	ld	ra,8(sp)
    80006526:	6402                	ld	s0,0(sp)
    80006528:	0141                	addi	sp,sp,16
    8000652a:	8082                	ret

000000008000652c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000652c:	1101                	addi	sp,sp,-32
    8000652e:	ec06                	sd	ra,24(sp)
    80006530:	e822                	sd	s0,16(sp)
    80006532:	e426                	sd	s1,8(sp)
    80006534:	1000                	addi	s0,sp,32
    80006536:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006538:	93ffb0ef          	jal	80001e76 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000653c:	00d5151b          	slliw	a0,a0,0xd
    80006540:	0c2017b7          	lui	a5,0xc201
    80006544:	97aa                	add	a5,a5,a0
    80006546:	c3c4                	sw	s1,4(a5)
}
    80006548:	60e2                	ld	ra,24(sp)
    8000654a:	6442                	ld	s0,16(sp)
    8000654c:	64a2                	ld	s1,8(sp)
    8000654e:	6105                	addi	sp,sp,32
    80006550:	8082                	ret

0000000080006552 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006552:	1141                	addi	sp,sp,-16
    80006554:	e406                	sd	ra,8(sp)
    80006556:	e022                	sd	s0,0(sp)
    80006558:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000655a:	479d                	li	a5,7
    8000655c:	04a7ca63          	blt	a5,a0,800065b0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80006560:	0010a797          	auipc	a5,0x10a
    80006564:	b3878793          	addi	a5,a5,-1224 # 80110098 <disk>
    80006568:	97aa                	add	a5,a5,a0
    8000656a:	0187c783          	lbu	a5,24(a5)
    8000656e:	e7b9                	bnez	a5,800065bc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006570:	00451693          	slli	a3,a0,0x4
    80006574:	0010a797          	auipc	a5,0x10a
    80006578:	b2478793          	addi	a5,a5,-1244 # 80110098 <disk>
    8000657c:	6398                	ld	a4,0(a5)
    8000657e:	9736                	add	a4,a4,a3
    80006580:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006584:	6398                	ld	a4,0(a5)
    80006586:	9736                	add	a4,a4,a3
    80006588:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000658c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006590:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006594:	97aa                	add	a5,a5,a0
    80006596:	4705                	li	a4,1
    80006598:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000659c:	0010a517          	auipc	a0,0x10a
    800065a0:	b1450513          	addi	a0,a0,-1260 # 801100b0 <disk+0x18>
    800065a4:	8a6fc0ef          	jal	8000264a <wakeup>
}
    800065a8:	60a2                	ld	ra,8(sp)
    800065aa:	6402                	ld	s0,0(sp)
    800065ac:	0141                	addi	sp,sp,16
    800065ae:	8082                	ret
    panic("free_desc 1");
    800065b0:	00003517          	auipc	a0,0x3
    800065b4:	3b050513          	addi	a0,a0,944 # 80009960 <etext+0x960>
    800065b8:	a28fa0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    800065bc:	00003517          	auipc	a0,0x3
    800065c0:	3b450513          	addi	a0,a0,948 # 80009970 <etext+0x970>
    800065c4:	a1cfa0ef          	jal	800007e0 <panic>

00000000800065c8 <virtio_disk_init>:
{
    800065c8:	1101                	addi	sp,sp,-32
    800065ca:	ec06                	sd	ra,24(sp)
    800065cc:	e822                	sd	s0,16(sp)
    800065ce:	e426                	sd	s1,8(sp)
    800065d0:	e04a                	sd	s2,0(sp)
    800065d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800065d4:	00003597          	auipc	a1,0x3
    800065d8:	3ac58593          	addi	a1,a1,940 # 80009980 <etext+0x980>
    800065dc:	0010a517          	auipc	a0,0x10a
    800065e0:	be450513          	addi	a0,a0,-1052 # 801101c0 <disk+0x128>
    800065e4:	d6afa0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065e8:	100017b7          	lui	a5,0x10001
    800065ec:	4398                	lw	a4,0(a5)
    800065ee:	2701                	sext.w	a4,a4
    800065f0:	747277b7          	lui	a5,0x74727
    800065f4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065f8:	18f71063          	bne	a4,a5,80006778 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065fc:	100017b7          	lui	a5,0x10001
    80006600:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80006602:	439c                	lw	a5,0(a5)
    80006604:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006606:	4709                	li	a4,2
    80006608:	16e79863          	bne	a5,a4,80006778 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000660c:	100017b7          	lui	a5,0x10001
    80006610:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80006612:	439c                	lw	a5,0(a5)
    80006614:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006616:	16e79163          	bne	a5,a4,80006778 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000661a:	100017b7          	lui	a5,0x10001
    8000661e:	47d8                	lw	a4,12(a5)
    80006620:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006622:	554d47b7          	lui	a5,0x554d4
    80006626:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000662a:	14f71763          	bne	a4,a5,80006778 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000662e:	100017b7          	lui	a5,0x10001
    80006632:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006636:	4705                	li	a4,1
    80006638:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000663a:	470d                	li	a4,3
    8000663c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000663e:	10001737          	lui	a4,0x10001
    80006642:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006644:	c7ffe737          	lui	a4,0xc7ffe
    80006648:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47eee587>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000664c:	8ef9                	and	a3,a3,a4
    8000664e:	10001737          	lui	a4,0x10001
    80006652:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006654:	472d                	li	a4,11
    80006656:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006658:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000665c:	439c                	lw	a5,0(a5)
    8000665e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006662:	8ba1                	andi	a5,a5,8
    80006664:	12078063          	beqz	a5,80006784 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006668:	100017b7          	lui	a5,0x10001
    8000666c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006670:	100017b7          	lui	a5,0x10001
    80006674:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006678:	439c                	lw	a5,0(a5)
    8000667a:	2781                	sext.w	a5,a5
    8000667c:	10079a63          	bnez	a5,80006790 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006680:	100017b7          	lui	a5,0x10001
    80006684:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006688:	439c                	lw	a5,0(a5)
    8000668a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000668c:	10078863          	beqz	a5,8000679c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80006690:	471d                	li	a4,7
    80006692:	10f77b63          	bgeu	a4,a5,800067a8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80006696:	c68fa0ef          	jal	80000afe <kalloc>
    8000669a:	0010a497          	auipc	s1,0x10a
    8000669e:	9fe48493          	addi	s1,s1,-1538 # 80110098 <disk>
    800066a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800066a4:	c5afa0ef          	jal	80000afe <kalloc>
    800066a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800066aa:	c54fa0ef          	jal	80000afe <kalloc>
    800066ae:	87aa                	mv	a5,a0
    800066b0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800066b2:	6088                	ld	a0,0(s1)
    800066b4:	10050063          	beqz	a0,800067b4 <virtio_disk_init+0x1ec>
    800066b8:	0010a717          	auipc	a4,0x10a
    800066bc:	9e873703          	ld	a4,-1560(a4) # 801100a0 <disk+0x8>
    800066c0:	0e070a63          	beqz	a4,800067b4 <virtio_disk_init+0x1ec>
    800066c4:	0e078863          	beqz	a5,800067b4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800066c8:	6605                	lui	a2,0x1
    800066ca:	4581                	li	a1,0
    800066cc:	dd6fa0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800066d0:	0010a497          	auipc	s1,0x10a
    800066d4:	9c848493          	addi	s1,s1,-1592 # 80110098 <disk>
    800066d8:	6605                	lui	a2,0x1
    800066da:	4581                	li	a1,0
    800066dc:	6488                	ld	a0,8(s1)
    800066de:	dc4fa0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800066e2:	6605                	lui	a2,0x1
    800066e4:	4581                	li	a1,0
    800066e6:	6888                	ld	a0,16(s1)
    800066e8:	dbafa0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800066ec:	100017b7          	lui	a5,0x10001
    800066f0:	4721                	li	a4,8
    800066f2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800066f4:	4098                	lw	a4,0(s1)
    800066f6:	100017b7          	lui	a5,0x10001
    800066fa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800066fe:	40d8                	lw	a4,4(s1)
    80006700:	100017b7          	lui	a5,0x10001
    80006704:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006708:	649c                	ld	a5,8(s1)
    8000670a:	0007869b          	sext.w	a3,a5
    8000670e:	10001737          	lui	a4,0x10001
    80006712:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006716:	9781                	srai	a5,a5,0x20
    80006718:	10001737          	lui	a4,0x10001
    8000671c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006720:	689c                	ld	a5,16(s1)
    80006722:	0007869b          	sext.w	a3,a5
    80006726:	10001737          	lui	a4,0x10001
    8000672a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000672e:	9781                	srai	a5,a5,0x20
    80006730:	10001737          	lui	a4,0x10001
    80006734:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006738:	10001737          	lui	a4,0x10001
    8000673c:	4785                	li	a5,1
    8000673e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006740:	00f48c23          	sb	a5,24(s1)
    80006744:	00f48ca3          	sb	a5,25(s1)
    80006748:	00f48d23          	sb	a5,26(s1)
    8000674c:	00f48da3          	sb	a5,27(s1)
    80006750:	00f48e23          	sb	a5,28(s1)
    80006754:	00f48ea3          	sb	a5,29(s1)
    80006758:	00f48f23          	sb	a5,30(s1)
    8000675c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006760:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006764:	100017b7          	lui	a5,0x10001
    80006768:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000676c:	60e2                	ld	ra,24(sp)
    8000676e:	6442                	ld	s0,16(sp)
    80006770:	64a2                	ld	s1,8(sp)
    80006772:	6902                	ld	s2,0(sp)
    80006774:	6105                	addi	sp,sp,32
    80006776:	8082                	ret
    panic("could not find virtio disk");
    80006778:	00003517          	auipc	a0,0x3
    8000677c:	21850513          	addi	a0,a0,536 # 80009990 <etext+0x990>
    80006780:	860fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006784:	00003517          	auipc	a0,0x3
    80006788:	22c50513          	addi	a0,a0,556 # 800099b0 <etext+0x9b0>
    8000678c:	854fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80006790:	00003517          	auipc	a0,0x3
    80006794:	24050513          	addi	a0,a0,576 # 800099d0 <etext+0x9d0>
    80006798:	848fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000679c:	00003517          	auipc	a0,0x3
    800067a0:	25450513          	addi	a0,a0,596 # 800099f0 <etext+0x9f0>
    800067a4:	83cfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800067a8:	00003517          	auipc	a0,0x3
    800067ac:	26850513          	addi	a0,a0,616 # 80009a10 <etext+0xa10>
    800067b0:	830fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800067b4:	00003517          	auipc	a0,0x3
    800067b8:	27c50513          	addi	a0,a0,636 # 80009a30 <etext+0xa30>
    800067bc:	824fa0ef          	jal	800007e0 <panic>

00000000800067c0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800067c0:	7159                	addi	sp,sp,-112
    800067c2:	f486                	sd	ra,104(sp)
    800067c4:	f0a2                	sd	s0,96(sp)
    800067c6:	eca6                	sd	s1,88(sp)
    800067c8:	e8ca                	sd	s2,80(sp)
    800067ca:	e4ce                	sd	s3,72(sp)
    800067cc:	e0d2                	sd	s4,64(sp)
    800067ce:	fc56                	sd	s5,56(sp)
    800067d0:	f85a                	sd	s6,48(sp)
    800067d2:	f45e                	sd	s7,40(sp)
    800067d4:	f062                	sd	s8,32(sp)
    800067d6:	ec66                	sd	s9,24(sp)
    800067d8:	1880                	addi	s0,sp,112
    800067da:	8a2a                	mv	s4,a0
    800067dc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800067de:	00c52c83          	lw	s9,12(a0)
    800067e2:	001c9c9b          	slliw	s9,s9,0x1
    800067e6:	1c82                	slli	s9,s9,0x20
    800067e8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800067ec:	0010a517          	auipc	a0,0x10a
    800067f0:	9d450513          	addi	a0,a0,-1580 # 801101c0 <disk+0x128>
    800067f4:	bdafa0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800067f8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800067fa:	44a1                	li	s1,8
      disk.free[i] = 0;
    800067fc:	0010ab17          	auipc	s6,0x10a
    80006800:	89cb0b13          	addi	s6,s6,-1892 # 80110098 <disk>
  for(int i = 0; i < 3; i++){
    80006804:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006806:	0010ac17          	auipc	s8,0x10a
    8000680a:	9bac0c13          	addi	s8,s8,-1606 # 801101c0 <disk+0x128>
    8000680e:	a8b9                	j	8000686c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006810:	00fb0733          	add	a4,s6,a5
    80006814:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006818:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000681a:	0207c563          	bltz	a5,80006844 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000681e:	2905                	addiw	s2,s2,1
    80006820:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006822:	05590963          	beq	s2,s5,80006874 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80006826:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006828:	0010a717          	auipc	a4,0x10a
    8000682c:	87070713          	addi	a4,a4,-1936 # 80110098 <disk>
    80006830:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006832:	01874683          	lbu	a3,24(a4)
    80006836:	fee9                	bnez	a3,80006810 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006838:	2785                	addiw	a5,a5,1
    8000683a:	0705                	addi	a4,a4,1
    8000683c:	fe979be3          	bne	a5,s1,80006832 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006840:	57fd                	li	a5,-1
    80006842:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006844:	01205d63          	blez	s2,8000685e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006848:	f9042503          	lw	a0,-112(s0)
    8000684c:	d07ff0ef          	jal	80006552 <free_desc>
      for(int j = 0; j < i; j++)
    80006850:	4785                	li	a5,1
    80006852:	0127d663          	bge	a5,s2,8000685e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006856:	f9442503          	lw	a0,-108(s0)
    8000685a:	cf9ff0ef          	jal	80006552 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000685e:	85e2                	mv	a1,s8
    80006860:	0010a517          	auipc	a0,0x10a
    80006864:	85050513          	addi	a0,a0,-1968 # 801100b0 <disk+0x18>
    80006868:	d97fb0ef          	jal	800025fe <sleep>
  for(int i = 0; i < 3; i++){
    8000686c:	f9040613          	addi	a2,s0,-112
    80006870:	894e                	mv	s2,s3
    80006872:	bf55                	j	80006826 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006874:	f9042503          	lw	a0,-112(s0)
    80006878:	00451693          	slli	a3,a0,0x4

  if(write)
    8000687c:	0010a797          	auipc	a5,0x10a
    80006880:	81c78793          	addi	a5,a5,-2020 # 80110098 <disk>
    80006884:	00a50713          	addi	a4,a0,10
    80006888:	0712                	slli	a4,a4,0x4
    8000688a:	973e                	add	a4,a4,a5
    8000688c:	01703633          	snez	a2,s7
    80006890:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006892:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006896:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000689a:	6398                	ld	a4,0(a5)
    8000689c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000689e:	0a868613          	addi	a2,a3,168
    800068a2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800068a4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800068a6:	6390                	ld	a2,0(a5)
    800068a8:	00d605b3          	add	a1,a2,a3
    800068ac:	4741                	li	a4,16
    800068ae:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800068b0:	4805                	li	a6,1
    800068b2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800068b6:	f9442703          	lw	a4,-108(s0)
    800068ba:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800068be:	0712                	slli	a4,a4,0x4
    800068c0:	963a                	add	a2,a2,a4
    800068c2:	058a0593          	addi	a1,s4,88
    800068c6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800068c8:	0007b883          	ld	a7,0(a5)
    800068cc:	9746                	add	a4,a4,a7
    800068ce:	40000613          	li	a2,1024
    800068d2:	c710                	sw	a2,8(a4)
  if(write)
    800068d4:	001bb613          	seqz	a2,s7
    800068d8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800068dc:	00166613          	ori	a2,a2,1
    800068e0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800068e4:	f9842583          	lw	a1,-104(s0)
    800068e8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800068ec:	00250613          	addi	a2,a0,2
    800068f0:	0612                	slli	a2,a2,0x4
    800068f2:	963e                	add	a2,a2,a5
    800068f4:	577d                	li	a4,-1
    800068f6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068fa:	0592                	slli	a1,a1,0x4
    800068fc:	98ae                	add	a7,a7,a1
    800068fe:	03068713          	addi	a4,a3,48
    80006902:	973e                	add	a4,a4,a5
    80006904:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006908:	6398                	ld	a4,0(a5)
    8000690a:	972e                	add	a4,a4,a1
    8000690c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006910:	4689                	li	a3,2
    80006912:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006916:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000691a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000691e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006922:	6794                	ld	a3,8(a5)
    80006924:	0026d703          	lhu	a4,2(a3)
    80006928:	8b1d                	andi	a4,a4,7
    8000692a:	0706                	slli	a4,a4,0x1
    8000692c:	96ba                	add	a3,a3,a4
    8000692e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006932:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006936:	6798                	ld	a4,8(a5)
    80006938:	00275783          	lhu	a5,2(a4)
    8000693c:	2785                	addiw	a5,a5,1
    8000693e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006942:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006946:	100017b7          	lui	a5,0x10001
    8000694a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000694e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006952:	0010a917          	auipc	s2,0x10a
    80006956:	86e90913          	addi	s2,s2,-1938 # 801101c0 <disk+0x128>
  while(b->disk == 1) {
    8000695a:	4485                	li	s1,1
    8000695c:	01079a63          	bne	a5,a6,80006970 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006960:	85ca                	mv	a1,s2
    80006962:	8552                	mv	a0,s4
    80006964:	c9bfb0ef          	jal	800025fe <sleep>
  while(b->disk == 1) {
    80006968:	004a2783          	lw	a5,4(s4)
    8000696c:	fe978ae3          	beq	a5,s1,80006960 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006970:	f9042903          	lw	s2,-112(s0)
    80006974:	00290713          	addi	a4,s2,2
    80006978:	0712                	slli	a4,a4,0x4
    8000697a:	00109797          	auipc	a5,0x109
    8000697e:	71e78793          	addi	a5,a5,1822 # 80110098 <disk>
    80006982:	97ba                	add	a5,a5,a4
    80006984:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006988:	00109997          	auipc	s3,0x109
    8000698c:	71098993          	addi	s3,s3,1808 # 80110098 <disk>
    80006990:	00491713          	slli	a4,s2,0x4
    80006994:	0009b783          	ld	a5,0(s3)
    80006998:	97ba                	add	a5,a5,a4
    8000699a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000699e:	854a                	mv	a0,s2
    800069a0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800069a4:	bafff0ef          	jal	80006552 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800069a8:	8885                	andi	s1,s1,1
    800069aa:	f0fd                	bnez	s1,80006990 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800069ac:	0010a517          	auipc	a0,0x10a
    800069b0:	81450513          	addi	a0,a0,-2028 # 801101c0 <disk+0x128>
    800069b4:	ab2fa0ef          	jal	80000c66 <release>
}
    800069b8:	70a6                	ld	ra,104(sp)
    800069ba:	7406                	ld	s0,96(sp)
    800069bc:	64e6                	ld	s1,88(sp)
    800069be:	6946                	ld	s2,80(sp)
    800069c0:	69a6                	ld	s3,72(sp)
    800069c2:	6a06                	ld	s4,64(sp)
    800069c4:	7ae2                	ld	s5,56(sp)
    800069c6:	7b42                	ld	s6,48(sp)
    800069c8:	7ba2                	ld	s7,40(sp)
    800069ca:	7c02                	ld	s8,32(sp)
    800069cc:	6ce2                	ld	s9,24(sp)
    800069ce:	6165                	addi	sp,sp,112
    800069d0:	8082                	ret

00000000800069d2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800069d2:	1101                	addi	sp,sp,-32
    800069d4:	ec06                	sd	ra,24(sp)
    800069d6:	e822                	sd	s0,16(sp)
    800069d8:	e426                	sd	s1,8(sp)
    800069da:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800069dc:	00109497          	auipc	s1,0x109
    800069e0:	6bc48493          	addi	s1,s1,1724 # 80110098 <disk>
    800069e4:	00109517          	auipc	a0,0x109
    800069e8:	7dc50513          	addi	a0,a0,2012 # 801101c0 <disk+0x128>
    800069ec:	9e2fa0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800069f0:	100017b7          	lui	a5,0x10001
    800069f4:	53b8                	lw	a4,96(a5)
    800069f6:	8b0d                	andi	a4,a4,3
    800069f8:	100017b7          	lui	a5,0x10001
    800069fc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800069fe:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006a02:	689c                	ld	a5,16(s1)
    80006a04:	0204d703          	lhu	a4,32(s1)
    80006a08:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006a0c:	04f70663          	beq	a4,a5,80006a58 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80006a10:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a14:	6898                	ld	a4,16(s1)
    80006a16:	0204d783          	lhu	a5,32(s1)
    80006a1a:	8b9d                	andi	a5,a5,7
    80006a1c:	078e                	slli	a5,a5,0x3
    80006a1e:	97ba                	add	a5,a5,a4
    80006a20:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006a22:	00278713          	addi	a4,a5,2
    80006a26:	0712                	slli	a4,a4,0x4
    80006a28:	9726                	add	a4,a4,s1
    80006a2a:	01074703          	lbu	a4,16(a4)
    80006a2e:	e321                	bnez	a4,80006a6e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a30:	0789                	addi	a5,a5,2
    80006a32:	0792                	slli	a5,a5,0x4
    80006a34:	97a6                	add	a5,a5,s1
    80006a36:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a38:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a3c:	c0ffb0ef          	jal	8000264a <wakeup>

    disk.used_idx += 1;
    80006a40:	0204d783          	lhu	a5,32(s1)
    80006a44:	2785                	addiw	a5,a5,1
    80006a46:	17c2                	slli	a5,a5,0x30
    80006a48:	93c1                	srli	a5,a5,0x30
    80006a4a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a4e:	6898                	ld	a4,16(s1)
    80006a50:	00275703          	lhu	a4,2(a4)
    80006a54:	faf71ee3          	bne	a4,a5,80006a10 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006a58:	00109517          	auipc	a0,0x109
    80006a5c:	76850513          	addi	a0,a0,1896 # 801101c0 <disk+0x128>
    80006a60:	a06fa0ef          	jal	80000c66 <release>
}
    80006a64:	60e2                	ld	ra,24(sp)
    80006a66:	6442                	ld	s0,16(sp)
    80006a68:	64a2                	ld	s1,8(sp)
    80006a6a:	6105                	addi	sp,sp,32
    80006a6c:	8082                	ret
      panic("virtio_disk_intr status");
    80006a6e:	00003517          	auipc	a0,0x3
    80006a72:	fda50513          	addi	a0,a0,-38 # 80009a48 <etext+0xa48>
    80006a76:	d6bf90ef          	jal	800007e0 <panic>

0000000080006a7a <swapfile_create>:
}

// Create per-process swap file at path /pgswpXXXXX (pid)
int swapfile_create(struct proc *p)
{
  if(p->swapfile){
    80006a7a:	16853783          	ld	a5,360(a0)
    80006a7e:	c399                	beqz	a5,80006a84 <swapfile_create+0xa>
    return 0; // already present
    80006a80:	4501                	li	a0,0
  f->readable = 1;
  f->writable = 1;
  p->swapfile = f;
  end_op();
  return 0;
}
    80006a82:	8082                	ret
{
    80006a84:	711d                	addi	sp,sp,-96
    80006a86:	ec86                	sd	ra,88(sp)
    80006a88:	e8a2                	sd	s0,80(sp)
    80006a8a:	e4a6                	sd	s1,72(sp)
    80006a8c:	e0ca                	sd	s2,64(sp)
    80006a8e:	1080                	addi	s0,sp,96
    80006a90:	84aa                	mv	s1,a0
  int pid = p->pid;
    80006a92:	591c                	lw	a5,48(a0)
  name[0] = '/'; name[1] = 'p'; name[2] = 'g'; name[3] = 's'; name[4] = 'w'; name[5] = 'p';
    80006a94:	02f00713          	li	a4,47
    80006a98:	fae40c23          	sb	a4,-72(s0)
    80006a9c:	07000713          	li	a4,112
    80006aa0:	fae40ca3          	sb	a4,-71(s0)
    80006aa4:	06700693          	li	a3,103
    80006aa8:	fad40d23          	sb	a3,-70(s0)
    80006aac:	07300693          	li	a3,115
    80006ab0:	fad40da3          	sb	a3,-69(s0)
    80006ab4:	07700693          	li	a3,119
    80006ab8:	fad40e23          	sb	a3,-68(s0)
    80006abc:	fae40ea3          	sb	a4,-67(s0)
  int d4 = (x/10000)%10, d3=(x/1000)%10, d2=(x/100)%10, d1=(x/10)%10, d0=x%10;
    80006ac0:	6709                	lui	a4,0x2
    80006ac2:	7107071b          	addiw	a4,a4,1808 # 2710 <_entry-0x7fffd8f0>
    80006ac6:	02e7c73b          	divw	a4,a5,a4
    80006aca:	46a9                	li	a3,10
    80006acc:	02d7673b          	remw	a4,a4,a3
  name[6] = '0'+d4; name[7] = '0'+d3; name[8] = '0'+d2; name[9] = '0'+d1; name[10] = '0'+d0; name[11] = 0;
    80006ad0:	0307071b          	addiw	a4,a4,48
    80006ad4:	fae40f23          	sb	a4,-66(s0)
  int d4 = (x/10000)%10, d3=(x/1000)%10, d2=(x/100)%10, d1=(x/10)%10, d0=x%10;
    80006ad8:	3e800713          	li	a4,1000
    80006adc:	02e7c73b          	divw	a4,a5,a4
    80006ae0:	02d7673b          	remw	a4,a4,a3
  name[6] = '0'+d4; name[7] = '0'+d3; name[8] = '0'+d2; name[9] = '0'+d1; name[10] = '0'+d0; name[11] = 0;
    80006ae4:	0307071b          	addiw	a4,a4,48
    80006ae8:	fae40fa3          	sb	a4,-65(s0)
  int d4 = (x/10000)%10, d3=(x/1000)%10, d2=(x/100)%10, d1=(x/10)%10, d0=x%10;
    80006aec:	06400713          	li	a4,100
    80006af0:	02e7c73b          	divw	a4,a5,a4
    80006af4:	02d7673b          	remw	a4,a4,a3
  name[6] = '0'+d4; name[7] = '0'+d3; name[8] = '0'+d2; name[9] = '0'+d1; name[10] = '0'+d0; name[11] = 0;
    80006af8:	0307071b          	addiw	a4,a4,48
    80006afc:	fce40023          	sb	a4,-64(s0)
  int d4 = (x/10000)%10, d3=(x/1000)%10, d2=(x/100)%10, d1=(x/10)%10, d0=x%10;
    80006b00:	02d7c73b          	divw	a4,a5,a3
    80006b04:	02d7673b          	remw	a4,a4,a3
  name[6] = '0'+d4; name[7] = '0'+d3; name[8] = '0'+d2; name[9] = '0'+d1; name[10] = '0'+d0; name[11] = 0;
    80006b08:	0307071b          	addiw	a4,a4,48
    80006b0c:	fce400a3          	sb	a4,-63(s0)
  int d4 = (x/10000)%10, d3=(x/1000)%10, d2=(x/100)%10, d1=(x/10)%10, d0=x%10;
    80006b10:	02d7e7bb          	remw	a5,a5,a3
  name[6] = '0'+d4; name[7] = '0'+d3; name[8] = '0'+d2; name[9] = '0'+d1; name[10] = '0'+d0; name[11] = 0;
    80006b14:	0307879b          	addiw	a5,a5,48
    80006b18:	fcf40123          	sb	a5,-62(s0)
    80006b1c:	fc0401a3          	sb	zero,-61(s0)
  begin_op();
    80006b20:	8ecfe0ef          	jal	80004c0c <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80006b24:	fa840593          	addi	a1,s0,-88
    80006b28:	fb840513          	addi	a0,s0,-72
    80006b2c:	f27fd0ef          	jal	80004a52 <nameiparent>
    80006b30:	892a                	mv	s2,a0
    80006b32:	cd2d                	beqz	a0,80006bac <swapfile_create+0x132>
    80006b34:	fc4e                	sd	s3,56(sp)
  ilock(dp);
    80006b36:	eecfd0ef          	jal	80004222 <ilock>
  if((ip = dirlookup(dp, name, 0)) != 0){
    80006b3a:	4601                	li	a2,0
    80006b3c:	fa840593          	addi	a1,s0,-88
    80006b40:	854a                	mv	a0,s2
    80006b42:	c91fd0ef          	jal	800047d2 <dirlookup>
    80006b46:	89aa                	mv	s3,a0
    80006b48:	c535                	beqz	a0,80006bb4 <swapfile_create+0x13a>
    iunlockput(dp);
    80006b4a:	854a                	mv	a0,s2
    80006b4c:	8e1fd0ef          	jal	8000442c <iunlockput>
    ilock(ip);
    80006b50:	854e                	mv	a0,s3
    80006b52:	ed0fd0ef          	jal	80004222 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006b56:	0449d783          	lhu	a5,68(s3)
    80006b5a:	37f9                	addiw	a5,a5,-2
    80006b5c:	17c2                	slli	a5,a5,0x30
    80006b5e:	93c1                	srli	a5,a5,0x30
    80006b60:	4705                	li	a4,1
    80006b62:	04f76163          	bltu	a4,a5,80006ba4 <swapfile_create+0x12a>
  struct file *f = filealloc();
    80006b66:	c0efe0ef          	jal	80004f74 <filealloc>
    80006b6a:	892a                	mv	s2,a0
  if(f == 0){
    80006b6c:	c555                	beqz	a0,80006c18 <swapfile_create+0x19e>
  iunlock(ip);
    80006b6e:	854e                	mv	a0,s3
    80006b70:	f60fd0ef          	jal	800042d0 <iunlock>
  f->type = FD_INODE;
    80006b74:	4789                	li	a5,2
    80006b76:	00f92023          	sw	a5,0(s2)
  f->ip = ip;
    80006b7a:	01393c23          	sd	s3,24(s2)
  f->off = 0;
    80006b7e:	02092023          	sw	zero,32(s2)
  f->readable = 1;
    80006b82:	4785                	li	a5,1
    80006b84:	00f90423          	sb	a5,8(s2)
  f->writable = 1;
    80006b88:	00f904a3          	sb	a5,9(s2)
  p->swapfile = f;
    80006b8c:	1724b423          	sd	s2,360(s1)
  end_op();
    80006b90:	8e6fe0ef          	jal	80004c76 <end_op>
  return 0;
    80006b94:	4501                	li	a0,0
    80006b96:	79e2                	ld	s3,56(sp)
}
    80006b98:	60e6                	ld	ra,88(sp)
    80006b9a:	6446                	ld	s0,80(sp)
    80006b9c:	64a6                	ld	s1,72(sp)
    80006b9e:	6906                	ld	s2,64(sp)
    80006ba0:	6125                	addi	sp,sp,96
    80006ba2:	8082                	ret
    iunlockput(ip);
    80006ba4:	854e                	mv	a0,s3
    80006ba6:	887fd0ef          	jal	8000442c <iunlockput>
    return 0;
    80006baa:	79e2                	ld	s3,56(sp)
    end_op();
    80006bac:	8cafe0ef          	jal	80004c76 <end_op>
    return -1;
    80006bb0:	557d                	li	a0,-1
    80006bb2:	b7dd                	j	80006b98 <swapfile_create+0x11e>
  if((ip = ialloc(dp->dev, type)) == 0){
    80006bb4:	4589                	li	a1,2
    80006bb6:	00092503          	lw	a0,0(s2)
    80006bba:	cf8fd0ef          	jal	800040b2 <ialloc>
    80006bbe:	89aa                	mv	s3,a0
    80006bc0:	c915                	beqz	a0,80006bf4 <swapfile_create+0x17a>
  ilock(ip);
    80006bc2:	e60fd0ef          	jal	80004222 <ilock>
  ip->major = major;
    80006bc6:	04099323          	sh	zero,70(s3)
  ip->minor = minor;
    80006bca:	04099423          	sh	zero,72(s3)
  ip->nlink = 1;
    80006bce:	4785                	li	a5,1
    80006bd0:	04f99523          	sh	a5,74(s3)
  iupdate(ip);
    80006bd4:	854e                	mv	a0,s3
    80006bd6:	d98fd0ef          	jal	8000416e <iupdate>
  if(dirlink(dp, name, ip->inum) < 0)
    80006bda:	0049a603          	lw	a2,4(s3)
    80006bde:	fa840593          	addi	a1,s0,-88
    80006be2:	854a                	mv	a0,s2
    80006be4:	dbbfd0ef          	jal	8000499e <dirlink>
    80006be8:	00054b63          	bltz	a0,80006bfe <swapfile_create+0x184>
  iunlockput(dp);
    80006bec:	854a                	mv	a0,s2
    80006bee:	83ffd0ef          	jal	8000442c <iunlockput>
  return ip;
    80006bf2:	bf95                	j	80006b66 <swapfile_create+0xec>
    iunlockput(dp);
    80006bf4:	854a                	mv	a0,s2
    80006bf6:	837fd0ef          	jal	8000442c <iunlockput>
    return 0;
    80006bfa:	79e2                	ld	s3,56(sp)
    80006bfc:	bf45                	j	80006bac <swapfile_create+0x132>
  ip->nlink = 0;
    80006bfe:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80006c02:	854e                	mv	a0,s3
    80006c04:	d6afd0ef          	jal	8000416e <iupdate>
  iunlockput(ip);
    80006c08:	854e                	mv	a0,s3
    80006c0a:	823fd0ef          	jal	8000442c <iunlockput>
  iunlockput(dp);
    80006c0e:	854a                	mv	a0,s2
    80006c10:	81dfd0ef          	jal	8000442c <iunlockput>
  return 0;
    80006c14:	79e2                	ld	s3,56(sp)
    80006c16:	bf59                	j	80006bac <swapfile_create+0x132>
    iunlockput(ip);
    80006c18:	854e                	mv	a0,s3
    80006c1a:	813fd0ef          	jal	8000442c <iunlockput>
    end_op();
    80006c1e:	858fe0ef          	jal	80004c76 <end_op>
    return -1;
    80006c22:	557d                	li	a0,-1
    80006c24:	79e2                	ld	s3,56(sp)
    80006c26:	bf8d                	j	80006b98 <swapfile_create+0x11e>

0000000080006c28 <swapfile_cleanup>:

// Cleanup swap file; set freed_slots to number of used entries cleared.
void swapfile_cleanup(struct proc *p, int *freed_slots)
{
    80006c28:	7159                	addi	sp,sp,-112
    80006c2a:	f486                	sd	ra,104(sp)
    80006c2c:	f0a2                	sd	s0,96(sp)
    80006c2e:	eca6                	sd	s1,88(sp)
    80006c30:	1880                	addi	s0,sp,112
    80006c32:	84aa                	mv	s1,a0
  int freed = 0;
  // Count used entries and clear the table
  for(int i=0;i<MAX_SWAP_PAGES;i++){
    80006c34:	17050793          	addi	a5,a0,368
    80006c38:	660d                	lui	a2,0x3
    80006c3a:	17060613          	addi	a2,a2,368 # 3170 <_entry-0x7fffce90>
    80006c3e:	962a                	add	a2,a2,a0
  int freed = 0;
    80006c40:	4801                	li	a6,0
    if(p->swap_table[i].used){
      freed++;
    }
    p->swap_table[i].used = 0;
    p->swap_table[i].va = 0;
    p->swap_table[i].slot = -1;
    80006c42:	58fd                	li	a7,-1
    80006c44:	a811                	j	80006c58 <swapfile_cleanup+0x30>
    p->swap_table[i].used = 0;
    80006c46:	00072423          	sw	zero,8(a4)
    p->swap_table[i].va = 0;
    80006c4a:	00072023          	sw	zero,0(a4)
    p->swap_table[i].slot = -1;
    80006c4e:	01172223          	sw	a7,4(a4)
  for(int i=0;i<MAX_SWAP_PAGES;i++){
    80006c52:	07b1                	addi	a5,a5,12
    80006c54:	00c78763          	beq	a5,a2,80006c62 <swapfile_cleanup+0x3a>
    if(p->swap_table[i].used){
    80006c58:	873e                	mv	a4,a5
    80006c5a:	4794                	lw	a3,8(a5)
    80006c5c:	d6ed                	beqz	a3,80006c46 <swapfile_cleanup+0x1e>
      freed++;
    80006c5e:	2805                	addiw	a6,a6,1
    80006c60:	b7dd                	j	80006c46 <swapfile_cleanup+0x1e>
  }
  p->num_swapped_pages = 0;
    80006c62:	678d                	lui	a5,0x3
    80006c64:	97a6                	add	a5,a5,s1
    80006c66:	1607a823          	sw	zero,368(a5) # 3170 <_entry-0x7fffce90>
  if(freed_slots) *freed_slots = freed;
    80006c6a:	c199                	beqz	a1,80006c70 <swapfile_cleanup+0x48>
    80006c6c:	0105a023          	sw	a6,0(a1)

  if(p->swapfile){
    80006c70:	1684b783          	ld	a5,360(s1)
    80006c74:	10078963          	beqz	a5,80006d86 <swapfile_cleanup+0x15e>
    80006c78:	e8ca                	sd	s2,80(sp)
    // unlink file path and close
    char name2[20];
    // rebuild name again
    int pid2 = p->pid;
    80006c7a:	589c                	lw	a5,48(s1)
    name2[0]='/'; name2[1]='p'; name2[2]='g'; name2[3]='s'; name2[4]='w'; name2[5]='p';
    80006c7c:	02f00713          	li	a4,47
    80006c80:	fae40c23          	sb	a4,-72(s0)
    80006c84:	07000713          	li	a4,112
    80006c88:	fae40ca3          	sb	a4,-71(s0)
    80006c8c:	06700693          	li	a3,103
    80006c90:	fad40d23          	sb	a3,-70(s0)
    80006c94:	07300693          	li	a3,115
    80006c98:	fad40da3          	sb	a3,-69(s0)
    80006c9c:	07700693          	li	a3,119
    80006ca0:	fad40e23          	sb	a3,-68(s0)
    80006ca4:	fae40ea3          	sb	a4,-67(s0)
    int y=pid2; int e4=(y/10000)%10, e3=(y/1000)%10, e2=(y/100)%10, e1=(y/10)%10, e0=y%10;
    80006ca8:	6709                	lui	a4,0x2
    80006caa:	7107071b          	addiw	a4,a4,1808 # 2710 <_entry-0x7fffd8f0>
    80006cae:	02e7c73b          	divw	a4,a5,a4
    80006cb2:	46a9                	li	a3,10
    80006cb4:	02d7673b          	remw	a4,a4,a3
    name2[6]='0'+e4; name2[7]='0'+e3; name2[8]='0'+e2; name2[9]='0'+e1; name2[10]='0'+e0; name2[11]=0;
    80006cb8:	0307071b          	addiw	a4,a4,48
    80006cbc:	fae40f23          	sb	a4,-66(s0)
    int y=pid2; int e4=(y/10000)%10, e3=(y/1000)%10, e2=(y/100)%10, e1=(y/10)%10, e0=y%10;
    80006cc0:	3e800713          	li	a4,1000
    80006cc4:	02e7c73b          	divw	a4,a5,a4
    80006cc8:	02d7673b          	remw	a4,a4,a3
    name2[6]='0'+e4; name2[7]='0'+e3; name2[8]='0'+e2; name2[9]='0'+e1; name2[10]='0'+e0; name2[11]=0;
    80006ccc:	0307071b          	addiw	a4,a4,48
    80006cd0:	fae40fa3          	sb	a4,-65(s0)
    int y=pid2; int e4=(y/10000)%10, e3=(y/1000)%10, e2=(y/100)%10, e1=(y/10)%10, e0=y%10;
    80006cd4:	06400713          	li	a4,100
    80006cd8:	02e7c73b          	divw	a4,a5,a4
    80006cdc:	02d7673b          	remw	a4,a4,a3
    name2[6]='0'+e4; name2[7]='0'+e3; name2[8]='0'+e2; name2[9]='0'+e1; name2[10]='0'+e0; name2[11]=0;
    80006ce0:	0307071b          	addiw	a4,a4,48
    80006ce4:	fce40023          	sb	a4,-64(s0)
    int y=pid2; int e4=(y/10000)%10, e3=(y/1000)%10, e2=(y/100)%10, e1=(y/10)%10, e0=y%10;
    80006ce8:	02d7c73b          	divw	a4,a5,a3
    80006cec:	02d7673b          	remw	a4,a4,a3
    name2[6]='0'+e4; name2[7]='0'+e3; name2[8]='0'+e2; name2[9]='0'+e1; name2[10]='0'+e0; name2[11]=0;
    80006cf0:	0307071b          	addiw	a4,a4,48
    80006cf4:	fce400a3          	sb	a4,-63(s0)
    int y=pid2; int e4=(y/10000)%10, e3=(y/1000)%10, e2=(y/100)%10, e1=(y/10)%10, e0=y%10;
    80006cf8:	02d7e7bb          	remw	a5,a5,a3
    name2[6]='0'+e4; name2[7]='0'+e3; name2[8]='0'+e2; name2[9]='0'+e1; name2[10]='0'+e0; name2[11]=0;
    80006cfc:	0307879b          	addiw	a5,a5,48
    80006d00:	fcf40123          	sb	a5,-62(s0)
    80006d04:	fc0401a3          	sb	zero,-61(s0)

    begin_op();
    80006d08:	f05fd0ef          	jal	80004c0c <begin_op>
    // perform unlink(name2)
    char nm[DIRSIZ]; uint off; struct inode *dp, *ip;
    if((dp = nameiparent(name2, nm)) != 0){
    80006d0c:	f9840593          	addi	a1,s0,-104
    80006d10:	fb840513          	addi	a0,s0,-72
    80006d14:	d3ffd0ef          	jal	80004a52 <nameiparent>
    80006d18:	892a                	mv	s2,a0
    80006d1a:	cd29                	beqz	a0,80006d74 <swapfile_cleanup+0x14c>
    80006d1c:	e4ce                	sd	s3,72(sp)
      ilock(dp);
    80006d1e:	d04fd0ef          	jal	80004222 <ilock>
      if((ip = dirlookup(dp, nm, &off)) != 0){
    80006d22:	f9440613          	addi	a2,s0,-108
    80006d26:	f9840593          	addi	a1,s0,-104
    80006d2a:	854a                	mv	a0,s2
    80006d2c:	aa7fd0ef          	jal	800047d2 <dirlookup>
    80006d30:	89aa                	mv	s3,a0
    80006d32:	cd0d                	beqz	a0,80006d6c <swapfile_cleanup+0x144>
        ilock(ip);
    80006d34:	ceefd0ef          	jal	80004222 <ilock>
        // remove directory entry
        struct dirent de;
        memset(&de, 0, sizeof(de));
    80006d38:	4641                	li	a2,16
    80006d3a:	4581                	li	a1,0
    80006d3c:	fa840513          	addi	a0,s0,-88
    80006d40:	f63f90ef          	jal	80000ca2 <memset>
        writei(dp, 0, (uint64)&de, off, sizeof(de));
    80006d44:	4741                	li	a4,16
    80006d46:	f9442683          	lw	a3,-108(s0)
    80006d4a:	fa840613          	addi	a2,s0,-88
    80006d4e:	4581                	li	a1,0
    80006d50:	854a                	mv	a0,s2
    80006d52:	95dfd0ef          	jal	800046ae <writei>
        ip->nlink--;
    80006d56:	04a9d783          	lhu	a5,74(s3)
    80006d5a:	37fd                	addiw	a5,a5,-1
    80006d5c:	04f99523          	sh	a5,74(s3)
        iupdate(ip);
    80006d60:	854e                	mv	a0,s3
    80006d62:	c0cfd0ef          	jal	8000416e <iupdate>
        iunlockput(ip);
    80006d66:	854e                	mv	a0,s3
    80006d68:	ec4fd0ef          	jal	8000442c <iunlockput>
      }
      iunlockput(dp);
    80006d6c:	854a                	mv	a0,s2
    80006d6e:	ebefd0ef          	jal	8000442c <iunlockput>
    80006d72:	69a6                	ld	s3,72(sp)
    }
    end_op();
    80006d74:	f03fd0ef          	jal	80004c76 <end_op>

    // Close file structure
    fileclose(p->swapfile);
    80006d78:	1684b503          	ld	a0,360(s1)
    80006d7c:	a9cfe0ef          	jal	80005018 <fileclose>
    p->swapfile = 0;
    80006d80:	1604b423          	sd	zero,360(s1)
    80006d84:	6946                	ld	s2,80(sp)
  }
}
    80006d86:	70a6                	ld	ra,104(sp)
    80006d88:	7406                	ld	s0,96(sp)
    80006d8a:	64e6                	ld	s1,88(sp)
    80006d8c:	6165                	addi	sp,sp,112
    80006d8e:	8082                	ret

0000000080006d90 <proc_swapout_page>:

// Swap out a physical page (pa) belonging to p at va into p's swap file
int proc_swapout_page(struct proc *p, uint64 va, uint64 pa)
{
    80006d90:	7139                	addi	sp,sp,-64
    80006d92:	fc06                	sd	ra,56(sp)
    80006d94:	f822                	sd	s0,48(sp)
    80006d96:	f04a                	sd	s2,32(sp)
    80006d98:	ec4e                	sd	s3,24(sp)
    80006d9a:	e852                	sd	s4,16(sp)
    80006d9c:	e456                	sd	s5,8(sp)
    80006d9e:	0080                	addi	s0,sp,64
    80006da0:	8a2a                	mv	s4,a0
    80006da2:	89ae                	mv	s3,a1
    80006da4:	8ab2                	mv	s5,a2
  if(p->swapfile == 0){
    80006da6:	16853783          	ld	a5,360(a0)
    80006daa:	c385                	beqz	a5,80006dca <proc_swapout_page+0x3a>
    80006dac:	f426                	sd	s1,40(sp)
    if(swapfile_create(p) < 0)
      return -1;
  }
  // find free slot
  int slot = -1;
  for (int i = 0; i < MAX_SWAP_PAGES; i++) {
    80006dae:	178a0793          	addi	a5,s4,376
    80006db2:	4901                	li	s2,0
    80006db4:	40000713          	li	a4,1024
    if (!p->swap_table[i].used) {
    80006db8:	4384                	lw	s1,0(a5)
    80006dba:	cc91                	beqz	s1,80006dd6 <proc_swapout_page+0x46>
  for (int i = 0; i < MAX_SWAP_PAGES; i++) {
    80006dbc:	2905                	addiw	s2,s2,1
    80006dbe:	07b1                	addi	a5,a5,12
    80006dc0:	fee91ce3          	bne	s2,a4,80006db8 <proc_swapout_page+0x28>
      slot = i;
      break;
    }
  }
  if (slot == -1)
    return -1; // SWAPFULL
    80006dc4:	597d                	li	s2,-1
    80006dc6:	74a2                	ld	s1,40(sp)
    80006dc8:	a87d                	j	80006e86 <proc_swapout_page+0xf6>
    if(swapfile_create(p) < 0)
    80006dca:	cb1ff0ef          	jal	80006a7a <swapfile_create>
    80006dce:	fc055fe3          	bgez	a0,80006dac <proc_swapout_page+0x1c>
      return -1;
    80006dd2:	597d                	li	s2,-1
    80006dd4:	a84d                	j	80006e86 <proc_swapout_page+0xf6>
  if (slot == -1)
    80006dd6:	57fd                	li	a5,-1
    80006dd8:	0cf90363          	beq	s2,a5,80006e9e <proc_swapout_page+0x10e>

  // write frame to swap file at offset slot*PGSIZE
  begin_op();
    80006ddc:	e31fd0ef          	jal	80004c0c <begin_op>
  ilock(p->swapfile->ip);
    80006de0:	168a3783          	ld	a5,360(s4)
    80006de4:	6f88                	ld	a0,24(a5)
    80006de6:	c3cfd0ef          	jal	80004222 <ilock>
  // src is a kernel-mapped physical page; pass user_src=0
  int n = writei(p->swapfile->ip, 0, pa, slot * PGSIZE, PGSIZE);
    80006dea:	168a3783          	ld	a5,360(s4)
    80006dee:	6705                	lui	a4,0x1
    80006df0:	00c9169b          	slliw	a3,s2,0xc
    80006df4:	8656                	mv	a2,s5
    80006df6:	4581                	li	a1,0
    80006df8:	6f88                	ld	a0,24(a5)
    80006dfa:	8b5fd0ef          	jal	800046ae <writei>
    80006dfe:	8aaa                	mv	s5,a0
  iunlock(p->swapfile->ip);
    80006e00:	168a3783          	ld	a5,360(s4)
    80006e04:	6f88                	ld	a0,24(a5)
    80006e06:	ccafd0ef          	jal	800042d0 <iunlock>
  end_op();
    80006e0a:	e6dfd0ef          	jal	80004c76 <end_op>
  if(n != PGSIZE)
    80006e0e:	6785                	lui	a5,0x1
    80006e10:	08fa9463          	bne	s5,a5,80006e98 <proc_swapout_page+0x108>
    return -1;

  // update table
  p->swap_table[slot].used = 1;
    80006e14:	00191793          	slli	a5,s2,0x1
    80006e18:	97ca                	add	a5,a5,s2
    80006e1a:	078a                	slli	a5,a5,0x2
    80006e1c:	97d2                	add	a5,a5,s4
    80006e1e:	4705                	li	a4,1
    80006e20:	16e7ac23          	sw	a4,376(a5) # 1178 <_entry-0x7fffee88>
  p->swap_table[slot].va = PGROUNDDOWN(va);
    80006e24:	777d                	lui	a4,0xfffff
    80006e26:	00e9f733          	and	a4,s3,a4
    80006e2a:	16e7a823          	sw	a4,368(a5)
  p->swap_table[slot].slot = slot;
    80006e2e:	1727aa23          	sw	s2,372(a5)
  p->num_swapped_pages++;
    80006e32:	678d                	lui	a5,0x3
    80006e34:	97d2                	add	a5,a5,s4
    80006e36:	1707a703          	lw	a4,368(a5) # 3170 <_entry-0x7fffce90>
    80006e3a:	2705                	addiw	a4,a4,1 # fffffffffffff001 <end+0xffffffff7feeee29>
    80006e3c:	16e7a823          	sw	a4,368(a5)

  // Update memstat
  // mark swapped with slot
  // Ensure entry exists and mark swapped
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80006e40:	678d                	lui	a5,0x3
    80006e42:	18878793          	addi	a5,a5,392 # 3188 <_entry-0x7fffce78>
    80006e46:	97d2                	add	a5,a5,s4
    if(p->memstat.pages[i].va == PGROUNDDOWN(va)){
    80006e48:	777d                	lui	a4,0xfffff
    80006e4a:	00e9f5b3          	and	a1,s3,a4
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80006e4e:	08000693          	li	a3,128
    if(p->memstat.pages[i].va == PGROUNDDOWN(va)){
    80006e52:	0007e703          	lwu	a4,0(a5)
    80006e56:	00b70863          	beq	a4,a1,80006e66 <proc_swapout_page+0xd6>
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80006e5a:	2485                	addiw	s1,s1,1
    80006e5c:	07d1                	addi	a5,a5,20
    80006e5e:	fed49ae3          	bne	s1,a3,80006e52 <proc_swapout_page+0xc2>
    80006e62:	74a2                	ld	s1,40(sp)
    80006e64:	a00d                	j	80006e86 <proc_swapout_page+0xf6>
      p->memstat.pages[i].state = SWAPPED;
    80006e66:	00249713          	slli	a4,s1,0x2
    80006e6a:	009707b3          	add	a5,a4,s1
    80006e6e:	078a                	slli	a5,a5,0x2
    80006e70:	97d2                	add	a5,a5,s4
    80006e72:	668d                	lui	a3,0x3
    80006e74:	97b6                	add	a5,a5,a3
    80006e76:	4609                	li	a2,2
    80006e78:	18c7a623          	sw	a2,396(a5)
      p->memstat.pages[i].swap_slot = slot;
    80006e7c:	1927ac23          	sw	s2,408(a5)
      p->memstat.pages[i].is_dirty = 0;
    80006e80:	1807a823          	sw	zero,400(a5)
      break;
    80006e84:	74a2                	ld	s1,40(sp)
    }
  }
  return slot;
}
    80006e86:	854a                	mv	a0,s2
    80006e88:	70e2                	ld	ra,56(sp)
    80006e8a:	7442                	ld	s0,48(sp)
    80006e8c:	7902                	ld	s2,32(sp)
    80006e8e:	69e2                	ld	s3,24(sp)
    80006e90:	6a42                	ld	s4,16(sp)
    80006e92:	6aa2                	ld	s5,8(sp)
    80006e94:	6121                	addi	sp,sp,64
    80006e96:	8082                	ret
    return -1;
    80006e98:	597d                	li	s2,-1
    80006e9a:	74a2                	ld	s1,40(sp)
    80006e9c:	b7ed                	j	80006e86 <proc_swapout_page+0xf6>
    80006e9e:	74a2                	ld	s1,40(sp)
    80006ea0:	b7dd                	j	80006e86 <proc_swapout_page+0xf6>

0000000080006ea2 <swapin_page>:

// Swap in contents for va into dst (a kernel-mapped page buffer)
int swapin_page(struct proc *p, uint64 va, char *dst)
{
    80006ea2:	7179                	addi	sp,sp,-48
    80006ea4:	f406                	sd	ra,40(sp)
    80006ea6:	f022                	sd	s0,32(sp)
    80006ea8:	ec26                	sd	s1,24(sp)
    80006eaa:	1800                	addi	s0,sp,48
  if(p->swapfile == 0)
    80006eac:	16853783          	ld	a5,360(a0)
    80006eb0:	14078263          	beqz	a5,80006ff4 <swapin_page+0x152>
    80006eb4:	e84a                	sd	s2,16(sp)
    80006eb6:	e44e                	sd	s3,8(sp)
    80006eb8:	e052                	sd	s4,0(sp)
    80006eba:	89aa                	mv	s3,a0
    80006ebc:	8a32                	mv	s4,a2
    return -1;
  uint64 va0 = PGROUNDDOWN(va);
    80006ebe:	77fd                	lui	a5,0xfffff
    80006ec0:	00f5f933          	and	s2,a1,a5
  int slot = -1;
  for (int i = 0; i < MAX_SWAP_PAGES; i++) {
    80006ec4:	17050793          	addi	a5,a0,368
    80006ec8:	4481                	li	s1,0
    80006eca:	40000693          	li	a3,1024
    80006ece:	a029                	j	80006ed8 <swapin_page+0x36>
    80006ed0:	2485                	addiw	s1,s1,1
    80006ed2:	07b1                	addi	a5,a5,12 # fffffffffffff00c <end+0xffffffff7feeee34>
    80006ed4:	0ed48263          	beq	s1,a3,80006fb8 <swapin_page+0x116>
    if (p->swap_table[i].used && p->swap_table[i].va == va0) {
    80006ed8:	4798                	lw	a4,8(a5)
    80006eda:	db7d                	beqz	a4,80006ed0 <swapin_page+0x2e>
    80006edc:	0007e703          	lwu	a4,0(a5)
    80006ee0:	ff2718e3          	bne	a4,s2,80006ed0 <swapin_page+0x2e>
      slot = i;
      break;
    }
  }
  if (slot == -1)
    80006ee4:	57fd                	li	a5,-1
    80006ee6:	10f48e63          	beq	s1,a5,80007002 <swapin_page+0x160>
    return -1;

  begin_op();
    80006eea:	d23fd0ef          	jal	80004c0c <begin_op>
  ilock(p->swapfile->ip);
    80006eee:	1689b783          	ld	a5,360(s3)
    80006ef2:	6f88                	ld	a0,24(a5)
    80006ef4:	b2efd0ef          	jal	80004222 <ilock>
  // dst is a kernel buffer; pass user_dst=0
  int n = readi(p->swapfile->ip, 0, (uint64)dst, slot * PGSIZE, PGSIZE);
    80006ef8:	1689b783          	ld	a5,360(s3)
    80006efc:	6705                	lui	a4,0x1
    80006efe:	00c4969b          	slliw	a3,s1,0xc
    80006f02:	8652                	mv	a2,s4
    80006f04:	4581                	li	a1,0
    80006f06:	6f88                	ld	a0,24(a5)
    80006f08:	eaafd0ef          	jal	800045b2 <readi>
    80006f0c:	8a2a                	mv	s4,a0
  iunlock(p->swapfile->ip);
    80006f0e:	1689b783          	ld	a5,360(s3)
    80006f12:	6f88                	ld	a0,24(a5)
    80006f14:	bbcfd0ef          	jal	800042d0 <iunlock>
  end_op();
    80006f18:	d5ffd0ef          	jal	80004c76 <end_op>
  if(n != PGSIZE)
    80006f1c:	6785                	lui	a5,0x1
    80006f1e:	0cfa1d63          	bne	s4,a5,80006ff8 <swapin_page+0x156>
    return -1;

  // free the slot
  p->swap_table[slot].used = 0;
    80006f22:	00149793          	slli	a5,s1,0x1
    80006f26:	97a6                	add	a5,a5,s1
    80006f28:	078a                	slli	a5,a5,0x2
    80006f2a:	97ce                	add	a5,a5,s3
    80006f2c:	1607ac23          	sw	zero,376(a5) # 1178 <_entry-0x7fffee88>
  p->swap_table[slot].va = 0;
    80006f30:	1607a823          	sw	zero,368(a5)
  p->swap_table[slot].slot = -1;
    80006f34:	577d                	li	a4,-1
    80006f36:	16e7aa23          	sw	a4,372(a5)
  if(p->num_swapped_pages > 0)
    80006f3a:	678d                	lui	a5,0x3
    80006f3c:	97ce                	add	a5,a5,s3
    80006f3e:	1707a783          	lw	a5,368(a5) # 3170 <_entry-0x7fffce90>
    80006f42:	00f05763          	blez	a5,80006f50 <swapin_page+0xae>
    p->num_swapped_pages--;
    80006f46:	670d                	lui	a4,0x3
    80006f48:	974e                	add	a4,a4,s3
    80006f4a:	37fd                	addiw	a5,a5,-1
    80006f4c:	16f72823          	sw	a5,368(a4) # 3170 <_entry-0x7fffce90>
  printf("[pid %d] SWAPIN va=%p slot=%d\n", p->pid, (void*)va0, slot);
    80006f50:	86a6                	mv	a3,s1
    80006f52:	864a                	mv	a2,s2
    80006f54:	0309a583          	lw	a1,48(s3)
    80006f58:	00003517          	auipc	a0,0x3
    80006f5c:	b0850513          	addi	a0,a0,-1272 # 80009a60 <etext+0xa60>
    80006f60:	d9af90ef          	jal	800004fa <printf>
  if(p->swapped_pages>0) p->swapped_pages--;
    80006f64:	6791                	lui	a5,0x4
    80006f66:	97ce                	add	a5,a5,s3
    80006f68:	be87a783          	lw	a5,-1048(a5) # 3be8 <_entry-0x7fffc418>
    80006f6c:	00f05763          	blez	a5,80006f7a <swapin_page+0xd8>
    80006f70:	6711                	lui	a4,0x4
    80006f72:	974e                	add	a4,a4,s3
    80006f74:	37fd                	addiw	a5,a5,-1
    80006f76:	bef72423          	sw	a5,-1048(a4) # 3be8 <_entry-0x7fffc418>
  p->resident_pages++;
    80006f7a:	6791                	lui	a5,0x4
    80006f7c:	97ce                	add	a5,a5,s3
    80006f7e:	be47a703          	lw	a4,-1052(a5) # 3be4 <_entry-0x7fffc41c>
    80006f82:	2705                	addiw	a4,a4,1
    80006f84:	bee7a223          	sw	a4,-1052(a5)
  p->swapin_count++;
    80006f88:	bec7a703          	lw	a4,-1044(a5)
    80006f8c:	2705                	addiw	a4,a4,1
    80006f8e:	bee7a623          	sw	a4,-1044(a5)

  // memstat update
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80006f92:	678d                	lui	a5,0x3
    80006f94:	18878793          	addi	a5,a5,392 # 3188 <_entry-0x7fffce78>
    80006f98:	97ce                	add	a5,a5,s3
    80006f9a:	4701                	li	a4,0
    80006f9c:	08000613          	li	a2,128
    if(p->memstat.pages[i].va == va0){
    80006fa0:	0007e683          	lwu	a3,0(a5)
    80006fa4:	01268f63          	beq	a3,s2,80006fc2 <swapin_page+0x120>
  for(int i=0;i<MAX_PAGES_INFO;i++){
    80006fa8:	2705                	addiw	a4,a4,1
    80006faa:	07d1                	addi	a5,a5,20
    80006fac:	fec71ae3          	bne	a4,a2,80006fa0 <swapin_page+0xfe>
    80006fb0:	6942                	ld	s2,16(sp)
    80006fb2:	69a2                	ld	s3,8(sp)
    80006fb4:	6a02                	ld	s4,0(sp)
    80006fb6:	a80d                	j	80006fe8 <swapin_page+0x146>
    return -1;
    80006fb8:	54fd                	li	s1,-1
    80006fba:	6942                	ld	s2,16(sp)
    80006fbc:	69a2                	ld	s3,8(sp)
    80006fbe:	6a02                	ld	s4,0(sp)
    80006fc0:	a025                	j	80006fe8 <swapin_page+0x146>
      p->memstat.pages[i].state = RESIDENT;
    80006fc2:	00271693          	slli	a3,a4,0x2
    80006fc6:	00e687b3          	add	a5,a3,a4
    80006fca:	078a                	slli	a5,a5,0x2
    80006fcc:	97ce                	add	a5,a5,s3
    80006fce:	660d                	lui	a2,0x3
    80006fd0:	97b2                	add	a5,a5,a2
    80006fd2:	4585                	li	a1,1
    80006fd4:	18b7a623          	sw	a1,396(a5)
      p->memstat.pages[i].swap_slot = -1;
    80006fd8:	55fd                	li	a1,-1
    80006fda:	18b7ac23          	sw	a1,408(a5)
      p->memstat.pages[i].is_dirty = 0;
    80006fde:	1807a823          	sw	zero,400(a5)
      break;
    80006fe2:	6942                	ld	s2,16(sp)
    80006fe4:	69a2                	ld	s3,8(sp)
    80006fe6:	6a02                	ld	s4,0(sp)
    }
  }

  return slot;
}
    80006fe8:	8526                	mv	a0,s1
    80006fea:	70a2                	ld	ra,40(sp)
    80006fec:	7402                	ld	s0,32(sp)
    80006fee:	64e2                	ld	s1,24(sp)
    80006ff0:	6145                	addi	sp,sp,48
    80006ff2:	8082                	ret
    return -1;
    80006ff4:	54fd                	li	s1,-1
    80006ff6:	bfcd                	j	80006fe8 <swapin_page+0x146>
    return -1;
    80006ff8:	54fd                	li	s1,-1
    80006ffa:	6942                	ld	s2,16(sp)
    80006ffc:	69a2                	ld	s3,8(sp)
    80006ffe:	6a02                	ld	s4,0(sp)
    80007000:	b7e5                	j	80006fe8 <swapin_page+0x146>
    80007002:	6942                	ld	s2,16(sp)
    80007004:	69a2                	ld	s3,8(sp)
    80007006:	6a02                	ld	s4,0(sp)
    80007008:	b7c5                	j	80006fe8 <swapin_page+0x146>
	...

0000000080008000 <_trampoline>:
    80008000:	14051073          	csrw	sscratch,a0
    80008004:	02000537          	lui	a0,0x2000
    80008008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000800a:	0536                	slli	a0,a0,0xd
    8000800c:	02153423          	sd	ra,40(a0)
    80008010:	02253823          	sd	sp,48(a0)
    80008014:	02353c23          	sd	gp,56(a0)
    80008018:	04453023          	sd	tp,64(a0)
    8000801c:	04553423          	sd	t0,72(a0)
    80008020:	04653823          	sd	t1,80(a0)
    80008024:	04753c23          	sd	t2,88(a0)
    80008028:	f120                	sd	s0,96(a0)
    8000802a:	f524                	sd	s1,104(a0)
    8000802c:	fd2c                	sd	a1,120(a0)
    8000802e:	e150                	sd	a2,128(a0)
    80008030:	e554                	sd	a3,136(a0)
    80008032:	e958                	sd	a4,144(a0)
    80008034:	ed5c                	sd	a5,152(a0)
    80008036:	0b053023          	sd	a6,160(a0)
    8000803a:	0b153423          	sd	a7,168(a0)
    8000803e:	0b253823          	sd	s2,176(a0)
    80008042:	0b353c23          	sd	s3,184(a0)
    80008046:	0d453023          	sd	s4,192(a0)
    8000804a:	0d553423          	sd	s5,200(a0)
    8000804e:	0d653823          	sd	s6,208(a0)
    80008052:	0d753c23          	sd	s7,216(a0)
    80008056:	0f853023          	sd	s8,224(a0)
    8000805a:	0f953423          	sd	s9,232(a0)
    8000805e:	0fa53823          	sd	s10,240(a0)
    80008062:	0fb53c23          	sd	s11,248(a0)
    80008066:	11c53023          	sd	t3,256(a0)
    8000806a:	11d53423          	sd	t4,264(a0)
    8000806e:	11e53823          	sd	t5,272(a0)
    80008072:	11f53c23          	sd	t6,280(a0)
    80008076:	140022f3          	csrr	t0,sscratch
    8000807a:	06553823          	sd	t0,112(a0)
    8000807e:	00853103          	ld	sp,8(a0)
    80008082:	02053203          	ld	tp,32(a0)
    80008086:	01053283          	ld	t0,16(a0)
    8000808a:	00053303          	ld	t1,0(a0)
    8000808e:	12000073          	sfence.vma
    80008092:	18031073          	csrw	satp,t1
    80008096:	12000073          	sfence.vma
    8000809a:	9282                	jalr	t0

000000008000809c <userret>:
    8000809c:	12000073          	sfence.vma
    800080a0:	18051073          	csrw	satp,a0
    800080a4:	12000073          	sfence.vma
    800080a8:	02000537          	lui	a0,0x2000
    800080ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800080ae:	0536                	slli	a0,a0,0xd
    800080b0:	02853083          	ld	ra,40(a0)
    800080b4:	03053103          	ld	sp,48(a0)
    800080b8:	03853183          	ld	gp,56(a0)
    800080bc:	04053203          	ld	tp,64(a0)
    800080c0:	04853283          	ld	t0,72(a0)
    800080c4:	05053303          	ld	t1,80(a0)
    800080c8:	05853383          	ld	t2,88(a0)
    800080cc:	7120                	ld	s0,96(a0)
    800080ce:	7524                	ld	s1,104(a0)
    800080d0:	7d2c                	ld	a1,120(a0)
    800080d2:	6150                	ld	a2,128(a0)
    800080d4:	6554                	ld	a3,136(a0)
    800080d6:	6958                	ld	a4,144(a0)
    800080d8:	6d5c                	ld	a5,152(a0)
    800080da:	0a053803          	ld	a6,160(a0)
    800080de:	0a853883          	ld	a7,168(a0)
    800080e2:	0b053903          	ld	s2,176(a0)
    800080e6:	0b853983          	ld	s3,184(a0)
    800080ea:	0c053a03          	ld	s4,192(a0)
    800080ee:	0c853a83          	ld	s5,200(a0)
    800080f2:	0d053b03          	ld	s6,208(a0)
    800080f6:	0d853b83          	ld	s7,216(a0)
    800080fa:	0e053c03          	ld	s8,224(a0)
    800080fe:	0e853c83          	ld	s9,232(a0)
    80008102:	0f053d03          	ld	s10,240(a0)
    80008106:	0f853d83          	ld	s11,248(a0)
    8000810a:	10053e03          	ld	t3,256(a0)
    8000810e:	10853e83          	ld	t4,264(a0)
    80008112:	11053f03          	ld	t5,272(a0)
    80008116:	11853f83          	ld	t6,280(a0)
    8000811a:	7928                	ld	a0,112(a0)
    8000811c:	10200073          	sret
	...
