
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	ab013103          	ld	sp,-1360(sp) # 80008ab0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	ad070713          	addi	a4,a4,-1328 # 80008b20 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	2ee78793          	addi	a5,a5,750 # 80006350 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbc86f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	fd078793          	addi	a5,a5,-48 # 8000107c <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	78a080e7          	jalr	1930(ra) # 800028b4 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	796080e7          	jalr	1942(ra) # 800008d0 <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    }

    return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000186:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	ad650513          	addi	a0,a0,-1322 # 80010c60 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	c48080e7          	jalr	-952(ra) # 80000dda <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	ac648493          	addi	s1,s1,-1338 # 80010c60 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b5690913          	addi	s2,s2,-1194 # 80010cf8 <cons+0x98>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

        if (c == C('D'))
    800001aa:	4b91                	li	s7,4
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
            break;

        dst++;
        --n;

        if (c == '\n')
    800001ae:	4ca9                	li	s9,10
    while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
        while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
            if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	ae8080e7          	jalr	-1304(ra) # 80001ca8 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	536080e7          	jalr	1334(ra) # 800026fe <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	280080e7          	jalr	640(ra) # 80002456 <sleep>
        while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
        if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
        cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	64c080e7          	jalr	1612(ra) # 8000285e <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
        dst++;
    8000021e:	0a05                	addi	s4,s4,1
        --n;
    80000220:	39fd                	addiw	s3,s3,-1
        if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	a3a50513          	addi	a0,a0,-1478 # 80010c60 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	c60080e7          	jalr	-928(ra) # 80000e8e <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	a2450513          	addi	a0,a0,-1500 # 80010c60 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	c4a080e7          	jalr	-950(ra) # 80000e8e <release>
                return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
            if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
                cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	a8f72323          	sw	a5,-1402(a4) # 80010cf8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
        uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	572080e7          	jalr	1394(ra) # 800007fe <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
        uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	560080e7          	jalr	1376(ra) # 800007fe <uartputc_sync>
        uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	554080e7          	jalr	1364(ra) # 800007fe <uartputc_sync>
        uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	54a080e7          	jalr	1354(ra) # 800007fe <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	99450513          	addi	a0,a0,-1644 # 80010c60 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	b06080e7          	jalr	-1274(ra) # 80000dda <acquire>

    switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	618080e7          	jalr	1560(ra) # 8000290a <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	96650513          	addi	a0,a0,-1690 # 80010c60 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	b8c080e7          	jalr	-1140(ra) # 80000e8e <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
    switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	94270713          	addi	a4,a4,-1726 # 80010c60 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
            consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	91878793          	addi	a5,a5,-1768 # 80010c60 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	9827a783          	lw	a5,-1662(a5) # 80010cf8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	8d670713          	addi	a4,a4,-1834 # 80010c60 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	8c648493          	addi	s1,s1,-1850 # 80010c60 <cons>
        while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
            cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
        while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	88a70713          	addi	a4,a4,-1910 # 80010c60 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	90f72a23          	sw	a5,-1772(a4) # 80010d00 <cons+0xa0>
            consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
            consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	84e78793          	addi	a5,a5,-1970 # 80010c60 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	8cc7a323          	sw	a2,-1850(a5) # 80010cfc <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	8ba50513          	addi	a0,a0,-1862 # 80010cf8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	074080e7          	jalr	116(ra) # 800024ba <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bc858593          	addi	a1,a1,-1080 # 80008020 <__func__.1+0x18>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	80050513          	addi	a0,a0,-2048 # 80010c60 <cons>
    80000468:	00001097          	auipc	ra,0x1
    8000046c:	8e2080e7          	jalr	-1822(ra) # 80000d4a <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	33e080e7          	jalr	830(ra) # 800007ae <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00041797          	auipc	a5,0x41
    8000047c:	98078793          	addi	a5,a5,-1664 # 80040df8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
        x = -xx;
    else
        x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

    i = 0;
    800004b6:	4701                	li	a4,0
    do
    {
        buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b9660613          	addi	a2,a2,-1130 # 80008050 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

    if (sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
        buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
        consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
    while (--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
        x = -xx;
    80000538:	40a0053b          	negw	a0,a0
    if (sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
        x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000540:	711d                	addi	sp,sp,-96
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
    8000054c:	e40c                	sd	a1,8(s0)
    8000054e:	e810                	sd	a2,16(s0)
    80000550:	ec14                	sd	a3,24(s0)
    80000552:	f018                	sd	a4,32(s0)
    80000554:	f41c                	sd	a5,40(s0)
    80000556:	03043823          	sd	a6,48(s0)
    8000055a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000055e:	00010797          	auipc	a5,0x10
    80000562:	7c07a123          	sw	zero,1986(a5) # 80010d20 <pr+0x18>
    printf("panic: ");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	ac250513          	addi	a0,a0,-1342 # 80008028 <__func__.1+0x20>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	02e080e7          	jalr	46(ra) # 8000059c <printf>
    printf(s);
    80000576:	8526                	mv	a0,s1
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	024080e7          	jalr	36(ra) # 8000059c <printf>
    printf("\n");
    80000580:	00008517          	auipc	a0,0x8
    80000584:	b0850513          	addi	a0,a0,-1272 # 80008088 <digits+0x38>
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	014080e7          	jalr	20(ra) # 8000059c <printf>
    panicked = 1; // freeze uart output from other CPUs
    80000590:	4785                	li	a5,1
    80000592:	00008717          	auipc	a4,0x8
    80000596:	52f72f23          	sw	a5,1342(a4) # 80008ad0 <panicked>
    for (;;)
    8000059a:	a001                	j	8000059a <panic+0x5a>

000000008000059c <printf>:
{
    8000059c:	7131                	addi	sp,sp,-192
    8000059e:	fc86                	sd	ra,120(sp)
    800005a0:	f8a2                	sd	s0,112(sp)
    800005a2:	f4a6                	sd	s1,104(sp)
    800005a4:	f0ca                	sd	s2,96(sp)
    800005a6:	ecce                	sd	s3,88(sp)
    800005a8:	e8d2                	sd	s4,80(sp)
    800005aa:	e4d6                	sd	s5,72(sp)
    800005ac:	e0da                	sd	s6,64(sp)
    800005ae:	fc5e                	sd	s7,56(sp)
    800005b0:	f862                	sd	s8,48(sp)
    800005b2:	f466                	sd	s9,40(sp)
    800005b4:	f06a                	sd	s10,32(sp)
    800005b6:	ec6e                	sd	s11,24(sp)
    800005b8:	0100                	addi	s0,sp,128
    800005ba:	8a2a                	mv	s4,a0
    800005bc:	e40c                	sd	a1,8(s0)
    800005be:	e810                	sd	a2,16(s0)
    800005c0:	ec14                	sd	a3,24(s0)
    800005c2:	f018                	sd	a4,32(s0)
    800005c4:	f41c                	sd	a5,40(s0)
    800005c6:	03043823          	sd	a6,48(s0)
    800005ca:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005ce:	00010d97          	auipc	s11,0x10
    800005d2:	752dad83          	lw	s11,1874(s11) # 80010d20 <pr+0x18>
    if (locking)
    800005d6:	020d9b63          	bnez	s11,8000060c <printf+0x70>
    if (fmt == 0)
    800005da:	040a0263          	beqz	s4,8000061e <printf+0x82>
    va_start(ap, fmt);
    800005de:	00840793          	addi	a5,s0,8
    800005e2:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005e6:	000a4503          	lbu	a0,0(s4)
    800005ea:	14050f63          	beqz	a0,80000748 <printf+0x1ac>
    800005ee:	4981                	li	s3,0
        if (c != '%')
    800005f0:	02500a93          	li	s5,37
        switch (c)
    800005f4:	07000b93          	li	s7,112
    consputc('x');
    800005f8:	4d41                	li	s10,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005fa:	00008b17          	auipc	s6,0x8
    800005fe:	a56b0b13          	addi	s6,s6,-1450 # 80008050 <digits>
        switch (c)
    80000602:	07300c93          	li	s9,115
    80000606:	06400c13          	li	s8,100
    8000060a:	a82d                	j	80000644 <printf+0xa8>
        acquire(&pr.lock);
    8000060c:	00010517          	auipc	a0,0x10
    80000610:	6fc50513          	addi	a0,a0,1788 # 80010d08 <pr>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	7c6080e7          	jalr	1990(ra) # 80000dda <acquire>
    8000061c:	bf7d                	j	800005da <printf+0x3e>
        panic("null fmt");
    8000061e:	00008517          	auipc	a0,0x8
    80000622:	a1a50513          	addi	a0,a0,-1510 # 80008038 <__func__.1+0x30>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	f1a080e7          	jalr	-230(ra) # 80000540 <panic>
            consputc(c);
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	c4e080e7          	jalr	-946(ra) # 8000027c <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c503          	lbu	a0,0(a5)
    80000640:	10050463          	beqz	a0,80000748 <printf+0x1ac>
        if (c != '%')
    80000644:	ff5515e3          	bne	a0,s5,8000062e <printf+0x92>
        c = fmt[++i] & 0xff;
    80000648:	2985                	addiw	s3,s3,1
    8000064a:	013a07b3          	add	a5,s4,s3
    8000064e:	0007c783          	lbu	a5,0(a5)
    80000652:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000656:	cbed                	beqz	a5,80000748 <printf+0x1ac>
        switch (c)
    80000658:	05778a63          	beq	a5,s7,800006ac <printf+0x110>
    8000065c:	02fbf663          	bgeu	s7,a5,80000688 <printf+0xec>
    80000660:	09978863          	beq	a5,s9,800006f0 <printf+0x154>
    80000664:	07800713          	li	a4,120
    80000668:	0ce79563          	bne	a5,a4,80000732 <printf+0x196>
            printint(va_arg(ap, int), 16, 1);
    8000066c:	f8843783          	ld	a5,-120(s0)
    80000670:	00878713          	addi	a4,a5,8
    80000674:	f8e43423          	sd	a4,-120(s0)
    80000678:	4605                	li	a2,1
    8000067a:	85ea                	mv	a1,s10
    8000067c:	4388                	lw	a0,0(a5)
    8000067e:	00000097          	auipc	ra,0x0
    80000682:	e1e080e7          	jalr	-482(ra) # 8000049c <printint>
            break;
    80000686:	bf45                	j	80000636 <printf+0x9a>
        switch (c)
    80000688:	09578f63          	beq	a5,s5,80000726 <printf+0x18a>
    8000068c:	0b879363          	bne	a5,s8,80000732 <printf+0x196>
            printint(va_arg(ap, int), 10, 1);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	4605                	li	a2,1
    8000069e:	45a9                	li	a1,10
    800006a0:	4388                	lw	a0,0(a5)
    800006a2:	00000097          	auipc	ra,0x0
    800006a6:	dfa080e7          	jalr	-518(ra) # 8000049c <printint>
            break;
    800006aa:	b771                	j	80000636 <printf+0x9a>
            printptr(va_arg(ap, uint64));
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006bc:	03000513          	li	a0,48
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	bbc080e7          	jalr	-1092(ra) # 8000027c <consputc>
    consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
    800006d4:	84ea                	mv	s1,s10
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d6:	03c95793          	srli	a5,s2,0x3c
    800006da:	97da                	add	a5,a5,s6
    800006dc:	0007c503          	lbu	a0,0(a5)
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	b9c080e7          	jalr	-1124(ra) # 8000027c <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0912                	slli	s2,s2,0x4
    800006ea:	34fd                	addiw	s1,s1,-1
    800006ec:	f4ed                	bnez	s1,800006d6 <printf+0x13a>
    800006ee:	b7a1                	j	80000636 <printf+0x9a>
            if ((s = va_arg(ap, char *)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	6384                	ld	s1,0(a5)
    800006fe:	cc89                	beqz	s1,80000718 <printf+0x17c>
            for (; *s; s++)
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	d90d                	beqz	a0,80000636 <printf+0x9a>
                consputc(*s);
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	b76080e7          	jalr	-1162(ra) # 8000027c <consputc>
            for (; *s; s++)
    8000070e:	0485                	addi	s1,s1,1
    80000710:	0004c503          	lbu	a0,0(s1)
    80000714:	f96d                	bnez	a0,80000706 <printf+0x16a>
    80000716:	b705                	j	80000636 <printf+0x9a>
                s = "(null)";
    80000718:	00008497          	auipc	s1,0x8
    8000071c:	91848493          	addi	s1,s1,-1768 # 80008030 <__func__.1+0x28>
            for (; *s; s++)
    80000720:	02800513          	li	a0,40
    80000724:	b7cd                	j	80000706 <printf+0x16a>
            consputc('%');
    80000726:	8556                	mv	a0,s5
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b54080e7          	jalr	-1196(ra) # 8000027c <consputc>
            break;
    80000730:	b719                	j	80000636 <printf+0x9a>
            consputc('%');
    80000732:	8556                	mv	a0,s5
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b48080e7          	jalr	-1208(ra) # 8000027c <consputc>
            consputc(c);
    8000073c:	8526                	mv	a0,s1
    8000073e:	00000097          	auipc	ra,0x0
    80000742:	b3e080e7          	jalr	-1218(ra) # 8000027c <consputc>
            break;
    80000746:	bdc5                	j	80000636 <printf+0x9a>
    if (locking)
    80000748:	020d9163          	bnez	s11,8000076a <printf+0x1ce>
}
    8000074c:	70e6                	ld	ra,120(sp)
    8000074e:	7446                	ld	s0,112(sp)
    80000750:	74a6                	ld	s1,104(sp)
    80000752:	7906                	ld	s2,96(sp)
    80000754:	69e6                	ld	s3,88(sp)
    80000756:	6a46                	ld	s4,80(sp)
    80000758:	6aa6                	ld	s5,72(sp)
    8000075a:	6b06                	ld	s6,64(sp)
    8000075c:	7be2                	ld	s7,56(sp)
    8000075e:	7c42                	ld	s8,48(sp)
    80000760:	7ca2                	ld	s9,40(sp)
    80000762:	7d02                	ld	s10,32(sp)
    80000764:	6de2                	ld	s11,24(sp)
    80000766:	6129                	addi	sp,sp,192
    80000768:	8082                	ret
        release(&pr.lock);
    8000076a:	00010517          	auipc	a0,0x10
    8000076e:	59e50513          	addi	a0,a0,1438 # 80010d08 <pr>
    80000772:	00000097          	auipc	ra,0x0
    80000776:	71c080e7          	jalr	1820(ra) # 80000e8e <release>
}
    8000077a:	bfc9                	j	8000074c <printf+0x1b0>

000000008000077c <printfinit>:
        ;
}

void printfinit(void)
{
    8000077c:	1101                	addi	sp,sp,-32
    8000077e:	ec06                	sd	ra,24(sp)
    80000780:	e822                	sd	s0,16(sp)
    80000782:	e426                	sd	s1,8(sp)
    80000784:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    80000786:	00010497          	auipc	s1,0x10
    8000078a:	58248493          	addi	s1,s1,1410 # 80010d08 <pr>
    8000078e:	00008597          	auipc	a1,0x8
    80000792:	8ba58593          	addi	a1,a1,-1862 # 80008048 <__func__.1+0x40>
    80000796:	8526                	mv	a0,s1
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	5b2080e7          	jalr	1458(ra) # 80000d4a <initlock>
    pr.locking = 1;
    800007a0:	4785                	li	a5,1
    800007a2:	cc9c                	sw	a5,24(s1)
}
    800007a4:	60e2                	ld	ra,24(sp)
    800007a6:	6442                	ld	s0,16(sp)
    800007a8:	64a2                	ld	s1,8(sp)
    800007aa:	6105                	addi	sp,sp,32
    800007ac:	8082                	ret

00000000800007ae <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ae:	1141                	addi	sp,sp,-16
    800007b0:	e406                	sd	ra,8(sp)
    800007b2:	e022                	sd	s0,0(sp)
    800007b4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b6:	100007b7          	lui	a5,0x10000
    800007ba:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007be:	f8000713          	li	a4,-128
    800007c2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c6:	470d                	li	a4,3
    800007c8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007cc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d4:	469d                	li	a3,7
    800007d6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007da:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007de:	00008597          	auipc	a1,0x8
    800007e2:	88a58593          	addi	a1,a1,-1910 # 80008068 <digits+0x18>
    800007e6:	00010517          	auipc	a0,0x10
    800007ea:	54250513          	addi	a0,a0,1346 # 80010d28 <uart_tx_lock>
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	55c080e7          	jalr	1372(ra) # 80000d4a <initlock>
}
    800007f6:	60a2                	ld	ra,8(sp)
    800007f8:	6402                	ld	s0,0(sp)
    800007fa:	0141                	addi	sp,sp,16
    800007fc:	8082                	ret

00000000800007fe <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fe:	1101                	addi	sp,sp,-32
    80000800:	ec06                	sd	ra,24(sp)
    80000802:	e822                	sd	s0,16(sp)
    80000804:	e426                	sd	s1,8(sp)
    80000806:	1000                	addi	s0,sp,32
    80000808:	84aa                	mv	s1,a0
  push_off();
    8000080a:	00000097          	auipc	ra,0x0
    8000080e:	584080e7          	jalr	1412(ra) # 80000d8e <push_off>

  if(panicked){
    80000812:	00008797          	auipc	a5,0x8
    80000816:	2be7a783          	lw	a5,702(a5) # 80008ad0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081e:	c391                	beqz	a5,80000822 <uartputc_sync+0x24>
    for(;;)
    80000820:	a001                	j	80000820 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000822:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dfe5                	beqz	a5,80000822 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f513          	zext.b	a0,s1
    80000830:	100007b7          	lui	a5,0x10000
    80000834:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	5f6080e7          	jalr	1526(ra) # 80000e2e <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	28e7b783          	ld	a5,654(a5) # 80008ad8 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	28e73703          	ld	a4,654(a4) # 80008ae0 <uart_tx_w>
    8000085a:	06f70a63          	beq	a4,a5,800008ce <uartstart+0x84>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000874:	00010a17          	auipc	s4,0x10
    80000878:	4b4a0a13          	addi	s4,s4,1204 # 80010d28 <uart_tx_lock>
    uart_tx_r += 1;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	25c48493          	addi	s1,s1,604 # 80008ad8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	25c98993          	addi	s3,s3,604 # 80008ae0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	02077713          	andi	a4,a4,32
    80000894:	c705                	beqz	a4,800008bc <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f7f713          	andi	a4,a5,31
    8000089a:	9752                	add	a4,a4,s4
    8000089c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008a0:	0785                	addi	a5,a5,1
    800008a2:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	c14080e7          	jalr	-1004(ra) # 800024ba <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	609c                	ld	a5,0(s1)
    800008b4:	0009b703          	ld	a4,0(s3)
    800008b8:	fcf71ae3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	44650513          	addi	a0,a0,1094 # 80010d28 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	4f0080e7          	jalr	1264(ra) # 80000dda <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1de7a783          	lw	a5,478(a5) # 80008ad0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008717          	auipc	a4,0x8
    80000900:	1e473703          	ld	a4,484(a4) # 80008ae0 <uart_tx_w>
    80000904:	00008797          	auipc	a5,0x8
    80000908:	1d47b783          	ld	a5,468(a5) # 80008ad8 <uart_tx_r>
    8000090c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	41898993          	addi	s3,s3,1048 # 80010d28 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	1c048493          	addi	s1,s1,448 # 80008ad8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	1c090913          	addi	s2,s2,448 # 80008ae0 <uart_tx_w>
    80000928:	00e79f63          	bne	a5,a4,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85ce                	mv	a1,s3
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	b26080e7          	jalr	-1242(ra) # 80002456 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093703          	ld	a4,0(s2)
    8000093c:	609c                	ld	a5,0(s1)
    8000093e:	02078793          	addi	a5,a5,32
    80000942:	fee785e3          	beq	a5,a4,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	3e248493          	addi	s1,s1,994 # 80010d28 <uart_tx_lock>
    8000094e:	01f77793          	andi	a5,a4,31
    80000952:	97a6                	add	a5,a5,s1
    80000954:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000958:	0705                	addi	a4,a4,1
    8000095a:	00008797          	auipc	a5,0x8
    8000095e:	18e7b323          	sd	a4,390(a5) # 80008ae0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee8080e7          	jalr	-280(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	522080e7          	jalr	1314(ra) # 80000e8e <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb81                	beqz	a5,800009a6 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a0:	6422                	ld	s0,8(sp)
    800009a2:	0141                	addi	sp,sp,16
    800009a4:	8082                	ret
    return -1;
    800009a6:	557d                	li	a0,-1
    800009a8:	bfe5                	j	800009a0 <uartgetc+0x1a>

00000000800009aa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009aa:	1101                	addi	sp,sp,-32
    800009ac:	ec06                	sd	ra,24(sp)
    800009ae:	e822                	sd	s0,16(sp)
    800009b0:	e426                	sd	s1,8(sp)
    800009b2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b4:	54fd                	li	s1,-1
    800009b6:	a029                	j	800009c0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	906080e7          	jalr	-1786(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	fc6080e7          	jalr	-58(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c8:	fe9518e3          	bne	a0,s1,800009b8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009cc:	00010497          	auipc	s1,0x10
    800009d0:	35c48493          	addi	s1,s1,860 # 80010d28 <uart_tx_lock>
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	404080e7          	jalr	1028(ra) # 80000dda <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	4a6080e7          	jalr	1190(ra) # 80000e8e <release>
}
    800009f0:	60e2                	ld	ra,24(sp)
    800009f2:	6442                	ld	s0,16(sp)
    800009f4:	64a2                	ld	s1,8(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <getRefCount>:
  struct spinlock lock;
  struct run *freelist;
} kmem;

uint getRefCount(uint pa)
{
    800009fa:	1141                	addi	sp,sp,-16
    800009fc:	e422                	sd	s0,8(sp)
    800009fe:	0800                	addi	s0,sp,16
  int index = (pa - KERNBASE) / PGSIZE;
    80000a00:	1502                	slli	a0,a0,0x20
    80000a02:	9101                	srli	a0,a0,0x20
    80000a04:	800007b7          	lui	a5,0x80000
    80000a08:	953e                	add	a0,a0,a5
    80000a0a:	43f55793          	srai	a5,a0,0x3f
    80000a0e:	17d2                	slli	a5,a5,0x34
    80000a10:	93d1                	srli	a5,a5,0x34
    80000a12:	97aa                	add	a5,a5,a0
  return ref_count[index];
    80000a14:	87b1                	srai	a5,a5,0xc
    80000a16:	078a                	slli	a5,a5,0x2
    80000a18:	00010717          	auipc	a4,0x10
    80000a1c:	36870713          	addi	a4,a4,872 # 80010d80 <ref_count>
    80000a20:	97ba                	add	a5,a5,a4
}
    80000a22:	4388                	lw	a0,0(a5)
    80000a24:	6422                	ld	s0,8(sp)
    80000a26:	0141                	addi	sp,sp,16
    80000a28:	8082                	ret

0000000080000a2a <checkZero>:

void checkZero(void *pa)
{
    80000a2a:	1101                	addi	sp,sp,-32
    80000a2c:	ec06                	sd	ra,24(sp)
    80000a2e:	e822                	sd	s0,16(sp)
    80000a30:	e426                	sd	s1,8(sp)
    80000a32:	e04a                	sd	s2,0(sp)
    80000a34:	1000                	addi	s0,sp,32
    80000a36:	84aa                	mv	s1,a0
  if (getRefCount((uint64)pa) == 0)
    80000a38:	2501                	sext.w	a0,a0
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	fc0080e7          	jalr	-64(ra) # 800009fa <getRefCount>
    80000a42:	2501                	sext.w	a0,a0
    80000a44:	c519                	beqz	a0,80000a52 <checkZero+0x28>
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
  }
}
    80000a46:	60e2                	ld	ra,24(sp)
    80000a48:	6442                	ld	s0,16(sp)
    80000a4a:	64a2                	ld	s1,8(sp)
    80000a4c:	6902                	ld	s2,0(sp)
    80000a4e:	6105                	addi	sp,sp,32
    80000a50:	8082                	ret
    memset(pa, 1, PGSIZE);
    80000a52:	6605                	lui	a2,0x1
    80000a54:	4585                	li	a1,1
    80000a56:	8526                	mv	a0,s1
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	47e080e7          	jalr	1150(ra) # 80000ed6 <memset>
    acquire(&kmem.lock);
    80000a60:	00010917          	auipc	s2,0x10
    80000a64:	30090913          	addi	s2,s2,768 # 80010d60 <kmem>
    80000a68:	854a                	mv	a0,s2
    80000a6a:	00000097          	auipc	ra,0x0
    80000a6e:	370080e7          	jalr	880(ra) # 80000dda <acquire>
    r->next = kmem.freelist;
    80000a72:	01893783          	ld	a5,24(s2)
    80000a76:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a78:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000a7c:	00008717          	auipc	a4,0x8
    80000a80:	06c70713          	addi	a4,a4,108 # 80008ae8 <FREE_PAGES>
    80000a84:	631c                	ld	a5,0(a4)
    80000a86:	0785                	addi	a5,a5,1 # ffffffff80000001 <end+0xfffffffefffbe071>
    80000a88:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	402080e7          	jalr	1026(ra) # 80000e8e <release>
}
    80000a94:	bf4d                	j	80000a46 <checkZero+0x1c>

0000000080000a96 <decRefCount>:

void decRefCount(uint pa)
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  int index = (pa - KERNBASE) / PGSIZE;
    80000a9e:	02051713          	slli	a4,a0,0x20
    80000aa2:	9301                	srli	a4,a4,0x20
    80000aa4:	800007b7          	lui	a5,0x80000
    80000aa8:	973e                	add	a4,a4,a5
    80000aaa:	43f75793          	srai	a5,a4,0x3f
    80000aae:	17d2                	slli	a5,a5,0x34
    80000ab0:	93d1                	srli	a5,a5,0x34
    80000ab2:	97ba                	add	a5,a5,a4
    80000ab4:	87b1                	srai	a5,a5,0xc
  if (ref_count[index] > 0)
    80000ab6:	00279693          	slli	a3,a5,0x2
    80000aba:	00010717          	auipc	a4,0x10
    80000abe:	2c670713          	addi	a4,a4,710 # 80010d80 <ref_count>
    80000ac2:	9736                	add	a4,a4,a3
    80000ac4:	4318                	lw	a4,0(a4)
    80000ac6:	cb09                	beqz	a4,80000ad8 <decRefCount+0x42>
    ref_count[index]--;
    80000ac8:	87b6                	mv	a5,a3
    80000aca:	00010697          	auipc	a3,0x10
    80000ace:	2b668693          	addi	a3,a3,694 # 80010d80 <ref_count>
    80000ad2:	97b6                	add	a5,a5,a3
    80000ad4:	377d                	addiw	a4,a4,-1
    80000ad6:	c398                	sw	a4,0(a5)

  uint64 w = (uint64)pa;
  checkZero((void *)(w));
    80000ad8:	1502                	slli	a0,a0,0x20
    80000ada:	9101                	srli	a0,a0,0x20
    80000adc:	00000097          	auipc	ra,0x0
    80000ae0:	f4e080e7          	jalr	-178(ra) # 80000a2a <checkZero>
}
    80000ae4:	60a2                	ld	ra,8(sp)
    80000ae6:	6402                	ld	s0,0(sp)
    80000ae8:	0141                	addi	sp,sp,16
    80000aea:	8082                	ret

0000000080000aec <incRefCount>:

void incRefCount(uint pa)
{
    80000aec:	1141                	addi	sp,sp,-16
    80000aee:	e422                	sd	s0,8(sp)
    80000af0:	0800                	addi	s0,sp,16
  int index = (pa - KERNBASE) / PGSIZE;
    80000af2:	1502                	slli	a0,a0,0x20
    80000af4:	9101                	srli	a0,a0,0x20
    80000af6:	800007b7          	lui	a5,0x80000
    80000afa:	953e                	add	a0,a0,a5
    80000afc:	43f55793          	srai	a5,a0,0x3f
    80000b00:	17d2                	slli	a5,a5,0x34
    80000b02:	93d1                	srli	a5,a5,0x34
    80000b04:	97aa                	add	a5,a5,a0
    80000b06:	87b1                	srai	a5,a5,0xc
  ref_count[index]++;
    80000b08:	078a                	slli	a5,a5,0x2
    80000b0a:	00010717          	auipc	a4,0x10
    80000b0e:	27670713          	addi	a4,a4,630 # 80010d80 <ref_count>
    80000b12:	97ba                	add	a5,a5,a4
    80000b14:	4398                	lw	a4,0(a5)
    80000b16:	2705                	addiw	a4,a4,1
    80000b18:	c398                	sw	a4,0(a5)
  // printf("\nFree: %d", FREE_PAGES);
}
    80000b1a:	6422                	ld	s0,8(sp)
    80000b1c:	0141                	addi	sp,sp,16
    80000b1e:	8082                	ret

0000000080000b20 <setRefCount>:

void setRefCount(uint pa)
{
    80000b20:	1141                	addi	sp,sp,-16
    80000b22:	e422                	sd	s0,8(sp)
    80000b24:	0800                	addi	s0,sp,16
  int index = (pa - KERNBASE) / PGSIZE;
    80000b26:	1502                	slli	a0,a0,0x20
    80000b28:	9101                	srli	a0,a0,0x20
    80000b2a:	800007b7          	lui	a5,0x80000
    80000b2e:	953e                	add	a0,a0,a5
    80000b30:	43f55793          	srai	a5,a0,0x3f
    80000b34:	17d2                	slli	a5,a5,0x34
    80000b36:	93d1                	srli	a5,a5,0x34
    80000b38:	97aa                	add	a5,a5,a0
  ref_count[index] = 1;
    80000b3a:	87b1                	srai	a5,a5,0xc
    80000b3c:	078a                	slli	a5,a5,0x2
    80000b3e:	00010717          	auipc	a4,0x10
    80000b42:	24270713          	addi	a4,a4,578 # 80010d80 <ref_count>
    80000b46:	97ba                	add	a5,a5,a4
    80000b48:	4705                	li	a4,1
    80000b4a:	c398                	sw	a4,0(a5)
}
    80000b4c:	6422                	ld	s0,8(sp)
    80000b4e:	0141                	addi	sp,sp,16
    80000b50:	8082                	ret

0000000080000b52 <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000b52:	1141                	addi	sp,sp,-16
    80000b54:	e406                	sd	ra,8(sp)
    80000b56:	e022                	sd	s0,0(sp)
    80000b58:	0800                	addi	s0,sp,16
  if (MAX_PAGES != 0)
    80000b5a:	00008797          	auipc	a5,0x8
    80000b5e:	f967b783          	ld	a5,-106(a5) # 80008af0 <MAX_PAGES>
    80000b62:	c799                	beqz	a5,80000b70 <kfree+0x1e>
    assert(FREE_PAGES < MAX_PAGES);
    80000b64:	00008717          	auipc	a4,0x8
    80000b68:	f8473703          	ld	a4,-124(a4) # 80008ae8 <FREE_PAGES>
    80000b6c:	02f77863          	bgeu	a4,a5,80000b9c <kfree+0x4a>

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000b70:	03451793          	slli	a5,a0,0x34
    80000b74:	efb1                	bnez	a5,80000bd0 <kfree+0x7e>
    80000b76:	00041797          	auipc	a5,0x41
    80000b7a:	41a78793          	addi	a5,a5,1050 # 80041f90 <end>
    80000b7e:	04f56963          	bltu	a0,a5,80000bd0 <kfree+0x7e>
    80000b82:	47c5                	li	a5,17
    80000b84:	07ee                	slli	a5,a5,0x1b
    80000b86:	04f57563          	bgeu	a0,a5,80000bd0 <kfree+0x7e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  decRefCount((uint64)pa);
    80000b8a:	2501                	sext.w	a0,a0
    80000b8c:	00000097          	auipc	ra,0x0
    80000b90:	f0a080e7          	jalr	-246(ra) # 80000a96 <decRefCount>
}
    80000b94:	60a2                	ld	ra,8(sp)
    80000b96:	6402                	ld	s0,0(sp)
    80000b98:	0141                	addi	sp,sp,16
    80000b9a:	8082                	ret
    assert(FREE_PAGES < MAX_PAGES);
    80000b9c:	06a00693          	li	a3,106
    80000ba0:	00007617          	auipc	a2,0x7
    80000ba4:	46860613          	addi	a2,a2,1128 # 80008008 <__func__.1>
    80000ba8:	00007597          	auipc	a1,0x7
    80000bac:	4c858593          	addi	a1,a1,1224 # 80008070 <digits+0x20>
    80000bb0:	00007517          	auipc	a0,0x7
    80000bb4:	4d050513          	addi	a0,a0,1232 # 80008080 <digits+0x30>
    80000bb8:	00000097          	auipc	ra,0x0
    80000bbc:	9e4080e7          	jalr	-1564(ra) # 8000059c <printf>
    80000bc0:	00007517          	auipc	a0,0x7
    80000bc4:	4d050513          	addi	a0,a0,1232 # 80008090 <digits+0x40>
    80000bc8:	00000097          	auipc	ra,0x0
    80000bcc:	978080e7          	jalr	-1672(ra) # 80000540 <panic>
    panic("kfree");
    80000bd0:	00007517          	auipc	a0,0x7
    80000bd4:	4d050513          	addi	a0,a0,1232 # 800080a0 <digits+0x50>
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	968080e7          	jalr	-1688(ra) # 80000540 <panic>

0000000080000be0 <freerange>:
{
    80000be0:	7179                	addi	sp,sp,-48
    80000be2:	f406                	sd	ra,40(sp)
    80000be4:	f022                	sd	s0,32(sp)
    80000be6:	ec26                	sd	s1,24(sp)
    80000be8:	e84a                	sd	s2,16(sp)
    80000bea:	e44e                	sd	s3,8(sp)
    80000bec:	e052                	sd	s4,0(sp)
    80000bee:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000bf0:	6785                	lui	a5,0x1
    80000bf2:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000bf6:	00e504b3          	add	s1,a0,a4
    80000bfa:	777d                	lui	a4,0xfffff
    80000bfc:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bfe:	94be                	add	s1,s1,a5
    80000c00:	0095ee63          	bltu	a1,s1,80000c1c <freerange+0x3c>
    80000c04:	892e                	mv	s2,a1
    kfree(p);
    80000c06:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c08:	6985                	lui	s3,0x1
    kfree(p);
    80000c0a:	01448533          	add	a0,s1,s4
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	f44080e7          	jalr	-188(ra) # 80000b52 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c16:	94ce                	add	s1,s1,s3
    80000c18:	fe9979e3          	bgeu	s2,s1,80000c0a <freerange+0x2a>
}
    80000c1c:	70a2                	ld	ra,40(sp)
    80000c1e:	7402                	ld	s0,32(sp)
    80000c20:	64e2                	ld	s1,24(sp)
    80000c22:	6942                	ld	s2,16(sp)
    80000c24:	69a2                	ld	s3,8(sp)
    80000c26:	6a02                	ld	s4,0(sp)
    80000c28:	6145                	addi	sp,sp,48
    80000c2a:	8082                	ret

0000000080000c2c <kinit>:
{
    80000c2c:	1141                	addi	sp,sp,-16
    80000c2e:	e406                	sd	ra,8(sp)
    80000c30:	e022                	sd	s0,0(sp)
    80000c32:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000c34:	00007597          	auipc	a1,0x7
    80000c38:	47458593          	addi	a1,a1,1140 # 800080a8 <digits+0x58>
    80000c3c:	00010517          	auipc	a0,0x10
    80000c40:	12450513          	addi	a0,a0,292 # 80010d60 <kmem>
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	106080e7          	jalr	262(ra) # 80000d4a <initlock>
  for (int i = 0; i < (PHYSTOP - KERNBASE) / PGSIZE; i++)
    80000c4c:	00010797          	auipc	a5,0x10
    80000c50:	13478793          	addi	a5,a5,308 # 80010d80 <ref_count>
    80000c54:	00030717          	auipc	a4,0x30
    80000c58:	12c70713          	addi	a4,a4,300 # 80030d80 <cpus>
    ref_count[i] = 0;
    80000c5c:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < (PHYSTOP - KERNBASE) / PGSIZE; i++)
    80000c60:	0791                	addi	a5,a5,4
    80000c62:	fee79de3          	bne	a5,a4,80000c5c <kinit+0x30>
  freerange(end, (void *)PHYSTOP);
    80000c66:	45c5                	li	a1,17
    80000c68:	05ee                	slli	a1,a1,0x1b
    80000c6a:	00041517          	auipc	a0,0x41
    80000c6e:	32650513          	addi	a0,a0,806 # 80041f90 <end>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	f6e080e7          	jalr	-146(ra) # 80000be0 <freerange>
  MAX_PAGES = FREE_PAGES;
    80000c7a:	00008797          	auipc	a5,0x8
    80000c7e:	e6e7b783          	ld	a5,-402(a5) # 80008ae8 <FREE_PAGES>
    80000c82:	00008717          	auipc	a4,0x8
    80000c86:	e6f73723          	sd	a5,-402(a4) # 80008af0 <MAX_PAGES>
}
    80000c8a:	60a2                	ld	ra,8(sp)
    80000c8c:	6402                	ld	s0,0(sp)
    80000c8e:	0141                	addi	sp,sp,16
    80000c90:	8082                	ret

0000000080000c92 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c92:	1101                	addi	sp,sp,-32
    80000c94:	ec06                	sd	ra,24(sp)
    80000c96:	e822                	sd	s0,16(sp)
    80000c98:	e426                	sd	s1,8(sp)
    80000c9a:	1000                	addi	s0,sp,32
  assert(FREE_PAGES > 0);
    80000c9c:	00008797          	auipc	a5,0x8
    80000ca0:	e4c7b783          	ld	a5,-436(a5) # 80008ae8 <FREE_PAGES>
    80000ca4:	c3a5                	beqz	a5,80000d04 <kalloc+0x72>
  struct run *r;

  acquire(&kmem.lock);
    80000ca6:	00010497          	auipc	s1,0x10
    80000caa:	0ba48493          	addi	s1,s1,186 # 80010d60 <kmem>
    80000cae:	8526                	mv	a0,s1
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	12a080e7          	jalr	298(ra) # 80000dda <acquire>
  r = kmem.freelist;
    80000cb8:	6c84                	ld	s1,24(s1)
  if (r)
    80000cba:	ccbd                	beqz	s1,80000d38 <kalloc+0xa6>
    kmem.freelist = r->next;
    80000cbc:	609c                	ld	a5,0(s1)
    80000cbe:	00010517          	auipc	a0,0x10
    80000cc2:	0a250513          	addi	a0,a0,162 # 80010d60 <kmem>
    80000cc6:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000cc8:	00000097          	auipc	ra,0x0
    80000ccc:	1c6080e7          	jalr	454(ra) # 80000e8e <release>

  if (r)
  {
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000cd0:	6605                	lui	a2,0x1
    80000cd2:	4595                	li	a1,5
    80000cd4:	8526                	mv	a0,s1
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	200080e7          	jalr	512(ra) # 80000ed6 <memset>
    FREE_PAGES--;
    80000cde:	00008717          	auipc	a4,0x8
    80000ce2:	e0a70713          	addi	a4,a4,-502 # 80008ae8 <FREE_PAGES>
    80000ce6:	631c                	ld	a5,0(a4)
    80000ce8:	17fd                	addi	a5,a5,-1
    80000cea:	e31c                	sd	a5,0(a4)
    incRefCount((uint64)r);
    80000cec:	0004851b          	sext.w	a0,s1
    80000cf0:	00000097          	auipc	ra,0x0
    80000cf4:	dfc080e7          	jalr	-516(ra) # 80000aec <incRefCount>
  }
  return (void *)r;
}
    80000cf8:	8526                	mv	a0,s1
    80000cfa:	60e2                	ld	ra,24(sp)
    80000cfc:	6442                	ld	s0,16(sp)
    80000cfe:	64a2                	ld	s1,8(sp)
    80000d00:	6105                	addi	sp,sp,32
    80000d02:	8082                	ret
  assert(FREE_PAGES > 0);
    80000d04:	07900693          	li	a3,121
    80000d08:	00007617          	auipc	a2,0x7
    80000d0c:	2f860613          	addi	a2,a2,760 # 80008000 <etext>
    80000d10:	00007597          	auipc	a1,0x7
    80000d14:	36058593          	addi	a1,a1,864 # 80008070 <digits+0x20>
    80000d18:	00007517          	auipc	a0,0x7
    80000d1c:	36850513          	addi	a0,a0,872 # 80008080 <digits+0x30>
    80000d20:	00000097          	auipc	ra,0x0
    80000d24:	87c080e7          	jalr	-1924(ra) # 8000059c <printf>
    80000d28:	00007517          	auipc	a0,0x7
    80000d2c:	36850513          	addi	a0,a0,872 # 80008090 <digits+0x40>
    80000d30:	00000097          	auipc	ra,0x0
    80000d34:	810080e7          	jalr	-2032(ra) # 80000540 <panic>
  release(&kmem.lock);
    80000d38:	00010517          	auipc	a0,0x10
    80000d3c:	02850513          	addi	a0,a0,40 # 80010d60 <kmem>
    80000d40:	00000097          	auipc	ra,0x0
    80000d44:	14e080e7          	jalr	334(ra) # 80000e8e <release>
  if (r)
    80000d48:	bf45                	j	80000cf8 <kalloc+0x66>

0000000080000d4a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d4a:	1141                	addi	sp,sp,-16
    80000d4c:	e422                	sd	s0,8(sp)
    80000d4e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d50:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d52:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d56:	00053823          	sd	zero,16(a0)
}
    80000d5a:	6422                	ld	s0,8(sp)
    80000d5c:	0141                	addi	sp,sp,16
    80000d5e:	8082                	ret

0000000080000d60 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d60:	411c                	lw	a5,0(a0)
    80000d62:	e399                	bnez	a5,80000d68 <holding+0x8>
    80000d64:	4501                	li	a0,0
  return r;
}
    80000d66:	8082                	ret
{
    80000d68:	1101                	addi	sp,sp,-32
    80000d6a:	ec06                	sd	ra,24(sp)
    80000d6c:	e822                	sd	s0,16(sp)
    80000d6e:	e426                	sd	s1,8(sp)
    80000d70:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d72:	6904                	ld	s1,16(a0)
    80000d74:	00001097          	auipc	ra,0x1
    80000d78:	f18080e7          	jalr	-232(ra) # 80001c8c <mycpu>
    80000d7c:	40a48533          	sub	a0,s1,a0
    80000d80:	00153513          	seqz	a0,a0
}
    80000d84:	60e2                	ld	ra,24(sp)
    80000d86:	6442                	ld	s0,16(sp)
    80000d88:	64a2                	ld	s1,8(sp)
    80000d8a:	6105                	addi	sp,sp,32
    80000d8c:	8082                	ret

0000000080000d8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d8e:	1101                	addi	sp,sp,-32
    80000d90:	ec06                	sd	ra,24(sp)
    80000d92:	e822                	sd	s0,16(sp)
    80000d94:	e426                	sd	s1,8(sp)
    80000d96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d98:	100024f3          	csrr	s1,sstatus
    80000d9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000da0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000da2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000da6:	00001097          	auipc	ra,0x1
    80000daa:	ee6080e7          	jalr	-282(ra) # 80001c8c <mycpu>
    80000dae:	5d3c                	lw	a5,120(a0)
    80000db0:	cf89                	beqz	a5,80000dca <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000db2:	00001097          	auipc	ra,0x1
    80000db6:	eda080e7          	jalr	-294(ra) # 80001c8c <mycpu>
    80000dba:	5d3c                	lw	a5,120(a0)
    80000dbc:	2785                	addiw	a5,a5,1
    80000dbe:	dd3c                	sw	a5,120(a0)
}
    80000dc0:	60e2                	ld	ra,24(sp)
    80000dc2:	6442                	ld	s0,16(sp)
    80000dc4:	64a2                	ld	s1,8(sp)
    80000dc6:	6105                	addi	sp,sp,32
    80000dc8:	8082                	ret
    mycpu()->intena = old;
    80000dca:	00001097          	auipc	ra,0x1
    80000dce:	ec2080e7          	jalr	-318(ra) # 80001c8c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000dd2:	8085                	srli	s1,s1,0x1
    80000dd4:	8885                	andi	s1,s1,1
    80000dd6:	dd64                	sw	s1,124(a0)
    80000dd8:	bfe9                	j	80000db2 <push_off+0x24>

0000000080000dda <acquire>:
{
    80000dda:	1101                	addi	sp,sp,-32
    80000ddc:	ec06                	sd	ra,24(sp)
    80000dde:	e822                	sd	s0,16(sp)
    80000de0:	e426                	sd	s1,8(sp)
    80000de2:	1000                	addi	s0,sp,32
    80000de4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000de6:	00000097          	auipc	ra,0x0
    80000dea:	fa8080e7          	jalr	-88(ra) # 80000d8e <push_off>
  if(holding(lk))
    80000dee:	8526                	mv	a0,s1
    80000df0:	00000097          	auipc	ra,0x0
    80000df4:	f70080e7          	jalr	-144(ra) # 80000d60 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000df8:	4705                	li	a4,1
  if(holding(lk))
    80000dfa:	e115                	bnez	a0,80000e1e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dfc:	87ba                	mv	a5,a4
    80000dfe:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000e02:	2781                	sext.w	a5,a5
    80000e04:	ffe5                	bnez	a5,80000dfc <acquire+0x22>
  __sync_synchronize();
    80000e06:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e0a:	00001097          	auipc	ra,0x1
    80000e0e:	e82080e7          	jalr	-382(ra) # 80001c8c <mycpu>
    80000e12:	e888                	sd	a0,16(s1)
}
    80000e14:	60e2                	ld	ra,24(sp)
    80000e16:	6442                	ld	s0,16(sp)
    80000e18:	64a2                	ld	s1,8(sp)
    80000e1a:	6105                	addi	sp,sp,32
    80000e1c:	8082                	ret
    panic("acquire");
    80000e1e:	00007517          	auipc	a0,0x7
    80000e22:	29250513          	addi	a0,a0,658 # 800080b0 <digits+0x60>
    80000e26:	fffff097          	auipc	ra,0xfffff
    80000e2a:	71a080e7          	jalr	1818(ra) # 80000540 <panic>

0000000080000e2e <pop_off>:

void
pop_off(void)
{
    80000e2e:	1141                	addi	sp,sp,-16
    80000e30:	e406                	sd	ra,8(sp)
    80000e32:	e022                	sd	s0,0(sp)
    80000e34:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e36:	00001097          	auipc	ra,0x1
    80000e3a:	e56080e7          	jalr	-426(ra) # 80001c8c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e3e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e42:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e44:	e78d                	bnez	a5,80000e6e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e46:	5d3c                	lw	a5,120(a0)
    80000e48:	02f05b63          	blez	a5,80000e7e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e4c:	37fd                	addiw	a5,a5,-1
    80000e4e:	0007871b          	sext.w	a4,a5
    80000e52:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e54:	eb09                	bnez	a4,80000e66 <pop_off+0x38>
    80000e56:	5d7c                	lw	a5,124(a0)
    80000e58:	c799                	beqz	a5,80000e66 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e5a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e5e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e62:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e66:	60a2                	ld	ra,8(sp)
    80000e68:	6402                	ld	s0,0(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
    panic("pop_off - interruptible");
    80000e6e:	00007517          	auipc	a0,0x7
    80000e72:	24a50513          	addi	a0,a0,586 # 800080b8 <digits+0x68>
    80000e76:	fffff097          	auipc	ra,0xfffff
    80000e7a:	6ca080e7          	jalr	1738(ra) # 80000540 <panic>
    panic("pop_off");
    80000e7e:	00007517          	auipc	a0,0x7
    80000e82:	25250513          	addi	a0,a0,594 # 800080d0 <digits+0x80>
    80000e86:	fffff097          	auipc	ra,0xfffff
    80000e8a:	6ba080e7          	jalr	1722(ra) # 80000540 <panic>

0000000080000e8e <release>:
{
    80000e8e:	1101                	addi	sp,sp,-32
    80000e90:	ec06                	sd	ra,24(sp)
    80000e92:	e822                	sd	s0,16(sp)
    80000e94:	e426                	sd	s1,8(sp)
    80000e96:	1000                	addi	s0,sp,32
    80000e98:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e9a:	00000097          	auipc	ra,0x0
    80000e9e:	ec6080e7          	jalr	-314(ra) # 80000d60 <holding>
    80000ea2:	c115                	beqz	a0,80000ec6 <release+0x38>
  lk->cpu = 0;
    80000ea4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ea8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000eac:	0f50000f          	fence	iorw,ow
    80000eb0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000eb4:	00000097          	auipc	ra,0x0
    80000eb8:	f7a080e7          	jalr	-134(ra) # 80000e2e <pop_off>
}
    80000ebc:	60e2                	ld	ra,24(sp)
    80000ebe:	6442                	ld	s0,16(sp)
    80000ec0:	64a2                	ld	s1,8(sp)
    80000ec2:	6105                	addi	sp,sp,32
    80000ec4:	8082                	ret
    panic("release");
    80000ec6:	00007517          	auipc	a0,0x7
    80000eca:	21250513          	addi	a0,a0,530 # 800080d8 <digits+0x88>
    80000ece:	fffff097          	auipc	ra,0xfffff
    80000ed2:	672080e7          	jalr	1650(ra) # 80000540 <panic>

0000000080000ed6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ed6:	1141                	addi	sp,sp,-16
    80000ed8:	e422                	sd	s0,8(sp)
    80000eda:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000edc:	ca19                	beqz	a2,80000ef2 <memset+0x1c>
    80000ede:	87aa                	mv	a5,a0
    80000ee0:	1602                	slli	a2,a2,0x20
    80000ee2:	9201                	srli	a2,a2,0x20
    80000ee4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ee8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000eec:	0785                	addi	a5,a5,1
    80000eee:	fee79de3          	bne	a5,a4,80000ee8 <memset+0x12>
  }
  return dst;
}
    80000ef2:	6422                	ld	s0,8(sp)
    80000ef4:	0141                	addi	sp,sp,16
    80000ef6:	8082                	ret

0000000080000ef8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ef8:	1141                	addi	sp,sp,-16
    80000efa:	e422                	sd	s0,8(sp)
    80000efc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000efe:	ca05                	beqz	a2,80000f2e <memcmp+0x36>
    80000f00:	fff6069b          	addiw	a3,a2,-1
    80000f04:	1682                	slli	a3,a3,0x20
    80000f06:	9281                	srli	a3,a3,0x20
    80000f08:	0685                	addi	a3,a3,1
    80000f0a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f0c:	00054783          	lbu	a5,0(a0)
    80000f10:	0005c703          	lbu	a4,0(a1)
    80000f14:	00e79863          	bne	a5,a4,80000f24 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f18:	0505                	addi	a0,a0,1
    80000f1a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f1c:	fed518e3          	bne	a0,a3,80000f0c <memcmp+0x14>
  }

  return 0;
    80000f20:	4501                	li	a0,0
    80000f22:	a019                	j	80000f28 <memcmp+0x30>
      return *s1 - *s2;
    80000f24:	40e7853b          	subw	a0,a5,a4
}
    80000f28:	6422                	ld	s0,8(sp)
    80000f2a:	0141                	addi	sp,sp,16
    80000f2c:	8082                	ret
  return 0;
    80000f2e:	4501                	li	a0,0
    80000f30:	bfe5                	j	80000f28 <memcmp+0x30>

0000000080000f32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f32:	1141                	addi	sp,sp,-16
    80000f34:	e422                	sd	s0,8(sp)
    80000f36:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f38:	c205                	beqz	a2,80000f58 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f3a:	02a5e263          	bltu	a1,a0,80000f5e <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f3e:	1602                	slli	a2,a2,0x20
    80000f40:	9201                	srli	a2,a2,0x20
    80000f42:	00c587b3          	add	a5,a1,a2
{
    80000f46:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f48:	0585                	addi	a1,a1,1
    80000f4a:	0705                	addi	a4,a4,1
    80000f4c:	fff5c683          	lbu	a3,-1(a1)
    80000f50:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f54:	fef59ae3          	bne	a1,a5,80000f48 <memmove+0x16>

  return dst;
}
    80000f58:	6422                	ld	s0,8(sp)
    80000f5a:	0141                	addi	sp,sp,16
    80000f5c:	8082                	ret
  if(s < d && s + n > d){
    80000f5e:	02061693          	slli	a3,a2,0x20
    80000f62:	9281                	srli	a3,a3,0x20
    80000f64:	00d58733          	add	a4,a1,a3
    80000f68:	fce57be3          	bgeu	a0,a4,80000f3e <memmove+0xc>
    d += n;
    80000f6c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f6e:	fff6079b          	addiw	a5,a2,-1
    80000f72:	1782                	slli	a5,a5,0x20
    80000f74:	9381                	srli	a5,a5,0x20
    80000f76:	fff7c793          	not	a5,a5
    80000f7a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f7c:	177d                	addi	a4,a4,-1
    80000f7e:	16fd                	addi	a3,a3,-1
    80000f80:	00074603          	lbu	a2,0(a4)
    80000f84:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f88:	fee79ae3          	bne	a5,a4,80000f7c <memmove+0x4a>
    80000f8c:	b7f1                	j	80000f58 <memmove+0x26>

0000000080000f8e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e406                	sd	ra,8(sp)
    80000f92:	e022                	sd	s0,0(sp)
    80000f94:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f96:	00000097          	auipc	ra,0x0
    80000f9a:	f9c080e7          	jalr	-100(ra) # 80000f32 <memmove>
}
    80000f9e:	60a2                	ld	ra,8(sp)
    80000fa0:	6402                	ld	s0,0(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000fa6:	1141                	addi	sp,sp,-16
    80000fa8:	e422                	sd	s0,8(sp)
    80000faa:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000fac:	ce11                	beqz	a2,80000fc8 <strncmp+0x22>
    80000fae:	00054783          	lbu	a5,0(a0)
    80000fb2:	cf89                	beqz	a5,80000fcc <strncmp+0x26>
    80000fb4:	0005c703          	lbu	a4,0(a1)
    80000fb8:	00f71a63          	bne	a4,a5,80000fcc <strncmp+0x26>
    n--, p++, q++;
    80000fbc:	367d                	addiw	a2,a2,-1
    80000fbe:	0505                	addi	a0,a0,1
    80000fc0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000fc2:	f675                	bnez	a2,80000fae <strncmp+0x8>
  if(n == 0)
    return 0;
    80000fc4:	4501                	li	a0,0
    80000fc6:	a809                	j	80000fd8 <strncmp+0x32>
    80000fc8:	4501                	li	a0,0
    80000fca:	a039                	j	80000fd8 <strncmp+0x32>
  if(n == 0)
    80000fcc:	ca09                	beqz	a2,80000fde <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000fce:	00054503          	lbu	a0,0(a0)
    80000fd2:	0005c783          	lbu	a5,0(a1)
    80000fd6:	9d1d                	subw	a0,a0,a5
}
    80000fd8:	6422                	ld	s0,8(sp)
    80000fda:	0141                	addi	sp,sp,16
    80000fdc:	8082                	ret
    return 0;
    80000fde:	4501                	li	a0,0
    80000fe0:	bfe5                	j	80000fd8 <strncmp+0x32>

0000000080000fe2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e422                	sd	s0,8(sp)
    80000fe6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fe8:	872a                	mv	a4,a0
    80000fea:	8832                	mv	a6,a2
    80000fec:	367d                	addiw	a2,a2,-1
    80000fee:	01005963          	blez	a6,80001000 <strncpy+0x1e>
    80000ff2:	0705                	addi	a4,a4,1
    80000ff4:	0005c783          	lbu	a5,0(a1)
    80000ff8:	fef70fa3          	sb	a5,-1(a4)
    80000ffc:	0585                	addi	a1,a1,1
    80000ffe:	f7f5                	bnez	a5,80000fea <strncpy+0x8>
    ;
  while(n-- > 0)
    80001000:	86ba                	mv	a3,a4
    80001002:	00c05c63          	blez	a2,8000101a <strncpy+0x38>
    *s++ = 0;
    80001006:	0685                	addi	a3,a3,1
    80001008:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    8000100c:	40d707bb          	subw	a5,a4,a3
    80001010:	37fd                	addiw	a5,a5,-1
    80001012:	010787bb          	addw	a5,a5,a6
    80001016:	fef048e3          	bgtz	a5,80001006 <strncpy+0x24>
  return os;
}
    8000101a:	6422                	ld	s0,8(sp)
    8000101c:	0141                	addi	sp,sp,16
    8000101e:	8082                	ret

0000000080001020 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001020:	1141                	addi	sp,sp,-16
    80001022:	e422                	sd	s0,8(sp)
    80001024:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001026:	02c05363          	blez	a2,8000104c <safestrcpy+0x2c>
    8000102a:	fff6069b          	addiw	a3,a2,-1
    8000102e:	1682                	slli	a3,a3,0x20
    80001030:	9281                	srli	a3,a3,0x20
    80001032:	96ae                	add	a3,a3,a1
    80001034:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001036:	00d58963          	beq	a1,a3,80001048 <safestrcpy+0x28>
    8000103a:	0585                	addi	a1,a1,1
    8000103c:	0785                	addi	a5,a5,1
    8000103e:	fff5c703          	lbu	a4,-1(a1)
    80001042:	fee78fa3          	sb	a4,-1(a5)
    80001046:	fb65                	bnez	a4,80001036 <safestrcpy+0x16>
    ;
  *s = 0;
    80001048:	00078023          	sb	zero,0(a5)
  return os;
}
    8000104c:	6422                	ld	s0,8(sp)
    8000104e:	0141                	addi	sp,sp,16
    80001050:	8082                	ret

0000000080001052 <strlen>:

int
strlen(const char *s)
{
    80001052:	1141                	addi	sp,sp,-16
    80001054:	e422                	sd	s0,8(sp)
    80001056:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001058:	00054783          	lbu	a5,0(a0)
    8000105c:	cf91                	beqz	a5,80001078 <strlen+0x26>
    8000105e:	0505                	addi	a0,a0,1
    80001060:	87aa                	mv	a5,a0
    80001062:	4685                	li	a3,1
    80001064:	9e89                	subw	a3,a3,a0
    80001066:	00f6853b          	addw	a0,a3,a5
    8000106a:	0785                	addi	a5,a5,1
    8000106c:	fff7c703          	lbu	a4,-1(a5)
    80001070:	fb7d                	bnez	a4,80001066 <strlen+0x14>
    ;
  return n;
}
    80001072:	6422                	ld	s0,8(sp)
    80001074:	0141                	addi	sp,sp,16
    80001076:	8082                	ret
  for(n = 0; s[n]; n++)
    80001078:	4501                	li	a0,0
    8000107a:	bfe5                	j	80001072 <strlen+0x20>

000000008000107c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000107c:	1141                	addi	sp,sp,-16
    8000107e:	e406                	sd	ra,8(sp)
    80001080:	e022                	sd	s0,0(sp)
    80001082:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001084:	00001097          	auipc	ra,0x1
    80001088:	bf8080e7          	jalr	-1032(ra) # 80001c7c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000108c:	00008717          	auipc	a4,0x8
    80001090:	a6c70713          	addi	a4,a4,-1428 # 80008af8 <started>
  if(cpuid() == 0){
    80001094:	c139                	beqz	a0,800010da <main+0x5e>
    while(started == 0)
    80001096:	431c                	lw	a5,0(a4)
    80001098:	2781                	sext.w	a5,a5
    8000109a:	dff5                	beqz	a5,80001096 <main+0x1a>
      ;
    __sync_synchronize();
    8000109c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800010a0:	00001097          	auipc	ra,0x1
    800010a4:	bdc080e7          	jalr	-1060(ra) # 80001c7c <cpuid>
    800010a8:	85aa                	mv	a1,a0
    800010aa:	00007517          	auipc	a0,0x7
    800010ae:	04e50513          	addi	a0,a0,78 # 800080f8 <digits+0xa8>
    800010b2:	fffff097          	auipc	ra,0xfffff
    800010b6:	4ea080e7          	jalr	1258(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    800010ba:	00000097          	auipc	ra,0x0
    800010be:	0d8080e7          	jalr	216(ra) # 80001192 <kvminithart>
    trapinithart();   // install kernel trap vector
    800010c2:	00002097          	auipc	ra,0x2
    800010c6:	ad4080e7          	jalr	-1324(ra) # 80002b96 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800010ca:	00005097          	auipc	ra,0x5
    800010ce:	2c6080e7          	jalr	710(ra) # 80006390 <plicinithart>
  }

  scheduler();        
    800010d2:	00001097          	auipc	ra,0x1
    800010d6:	262080e7          	jalr	610(ra) # 80002334 <scheduler>
    consoleinit();
    800010da:	fffff097          	auipc	ra,0xfffff
    800010de:	376080e7          	jalr	886(ra) # 80000450 <consoleinit>
    printfinit();
    800010e2:	fffff097          	auipc	ra,0xfffff
    800010e6:	69a080e7          	jalr	1690(ra) # 8000077c <printfinit>
    printf("\n");
    800010ea:	00007517          	auipc	a0,0x7
    800010ee:	f9e50513          	addi	a0,a0,-98 # 80008088 <digits+0x38>
    800010f2:	fffff097          	auipc	ra,0xfffff
    800010f6:	4aa080e7          	jalr	1194(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    800010fa:	00007517          	auipc	a0,0x7
    800010fe:	fe650513          	addi	a0,a0,-26 # 800080e0 <digits+0x90>
    80001102:	fffff097          	auipc	ra,0xfffff
    80001106:	49a080e7          	jalr	1178(ra) # 8000059c <printf>
    printf("\n");
    8000110a:	00007517          	auipc	a0,0x7
    8000110e:	f7e50513          	addi	a0,a0,-130 # 80008088 <digits+0x38>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	48a080e7          	jalr	1162(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    8000111a:	00000097          	auipc	ra,0x0
    8000111e:	b12080e7          	jalr	-1262(ra) # 80000c2c <kinit>
    kvminit();       // create kernel page table
    80001122:	00000097          	auipc	ra,0x0
    80001126:	326080e7          	jalr	806(ra) # 80001448 <kvminit>
    kvminithart();   // turn on paging
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	068080e7          	jalr	104(ra) # 80001192 <kvminithart>
    procinit();      // process table
    80001132:	00001097          	auipc	ra,0x1
    80001136:	a68080e7          	jalr	-1432(ra) # 80001b9a <procinit>
    trapinit();      // trap vectors
    8000113a:	00002097          	auipc	ra,0x2
    8000113e:	a34080e7          	jalr	-1484(ra) # 80002b6e <trapinit>
    trapinithart();  // install kernel trap vector
    80001142:	00002097          	auipc	ra,0x2
    80001146:	a54080e7          	jalr	-1452(ra) # 80002b96 <trapinithart>
    plicinit();      // set up interrupt controller
    8000114a:	00005097          	auipc	ra,0x5
    8000114e:	230080e7          	jalr	560(ra) # 8000637a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001152:	00005097          	auipc	ra,0x5
    80001156:	23e080e7          	jalr	574(ra) # 80006390 <plicinithart>
    binit();         // buffer cache
    8000115a:	00002097          	auipc	ra,0x2
    8000115e:	3d2080e7          	jalr	978(ra) # 8000352c <binit>
    iinit();         // inode table
    80001162:	00003097          	auipc	ra,0x3
    80001166:	a72080e7          	jalr	-1422(ra) # 80003bd4 <iinit>
    fileinit();      // file table
    8000116a:	00004097          	auipc	ra,0x4
    8000116e:	a18080e7          	jalr	-1512(ra) # 80004b82 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001172:	00005097          	auipc	ra,0x5
    80001176:	326080e7          	jalr	806(ra) # 80006498 <virtio_disk_init>
    userinit();      // first user process
    8000117a:	00001097          	auipc	ra,0x1
    8000117e:	e06080e7          	jalr	-506(ra) # 80001f80 <userinit>
    __sync_synchronize();
    80001182:	0ff0000f          	fence
    started = 1;
    80001186:	4785                	li	a5,1
    80001188:	00008717          	auipc	a4,0x8
    8000118c:	96f72823          	sw	a5,-1680(a4) # 80008af8 <started>
    80001190:	b789                	j	800010d2 <main+0x56>

0000000080001192 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001192:	1141                	addi	sp,sp,-16
    80001194:	e422                	sd	s0,8(sp)
    80001196:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001198:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000119c:	00008797          	auipc	a5,0x8
    800011a0:	9647b783          	ld	a5,-1692(a5) # 80008b00 <kernel_pagetable>
    800011a4:	83b1                	srli	a5,a5,0xc
    800011a6:	577d                	li	a4,-1
    800011a8:	177e                	slli	a4,a4,0x3f
    800011aa:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800011ac:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800011b0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800011b4:	6422                	ld	s0,8(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	f426                	sd	s1,40(sp)
    800011c2:	f04a                	sd	s2,32(sp)
    800011c4:	ec4e                	sd	s3,24(sp)
    800011c6:	e852                	sd	s4,16(sp)
    800011c8:	e456                	sd	s5,8(sp)
    800011ca:	e05a                	sd	s6,0(sp)
    800011cc:	0080                	addi	s0,sp,64
    800011ce:	84aa                	mv	s1,a0
    800011d0:	89ae                	mv	s3,a1
    800011d2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800011d4:	57fd                	li	a5,-1
    800011d6:	83e9                	srli	a5,a5,0x1a
    800011d8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800011da:	4b31                	li	s6,12
  if(va >= MAXVA)
    800011dc:	04b7f263          	bgeu	a5,a1,80001220 <walk+0x66>
    panic("walk");
    800011e0:	00007517          	auipc	a0,0x7
    800011e4:	f3050513          	addi	a0,a0,-208 # 80008110 <digits+0xc0>
    800011e8:	fffff097          	auipc	ra,0xfffff
    800011ec:	358080e7          	jalr	856(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800011f0:	060a8663          	beqz	s5,8000125c <walk+0xa2>
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	a9e080e7          	jalr	-1378(ra) # 80000c92 <kalloc>
    800011fc:	84aa                	mv	s1,a0
    800011fe:	c529                	beqz	a0,80001248 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001200:	6605                	lui	a2,0x1
    80001202:	4581                	li	a1,0
    80001204:	00000097          	auipc	ra,0x0
    80001208:	cd2080e7          	jalr	-814(ra) # 80000ed6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000120c:	00c4d793          	srli	a5,s1,0xc
    80001210:	07aa                	slli	a5,a5,0xa
    80001212:	0017e793          	ori	a5,a5,1
    80001216:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000121a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffbd067>
    8000121c:	036a0063          	beq	s4,s6,8000123c <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001220:	0149d933          	srl	s2,s3,s4
    80001224:	1ff97913          	andi	s2,s2,511
    80001228:	090e                	slli	s2,s2,0x3
    8000122a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000122c:	00093483          	ld	s1,0(s2)
    80001230:	0014f793          	andi	a5,s1,1
    80001234:	dfd5                	beqz	a5,800011f0 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001236:	80a9                	srli	s1,s1,0xa
    80001238:	04b2                	slli	s1,s1,0xc
    8000123a:	b7c5                	j	8000121a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000123c:	00c9d513          	srli	a0,s3,0xc
    80001240:	1ff57513          	andi	a0,a0,511
    80001244:	050e                	slli	a0,a0,0x3
    80001246:	9526                	add	a0,a0,s1
}
    80001248:	70e2                	ld	ra,56(sp)
    8000124a:	7442                	ld	s0,48(sp)
    8000124c:	74a2                	ld	s1,40(sp)
    8000124e:	7902                	ld	s2,32(sp)
    80001250:	69e2                	ld	s3,24(sp)
    80001252:	6a42                	ld	s4,16(sp)
    80001254:	6aa2                	ld	s5,8(sp)
    80001256:	6b02                	ld	s6,0(sp)
    80001258:	6121                	addi	sp,sp,64
    8000125a:	8082                	ret
        return 0;
    8000125c:	4501                	li	a0,0
    8000125e:	b7ed                	j	80001248 <walk+0x8e>

0000000080001260 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001260:	57fd                	li	a5,-1
    80001262:	83e9                	srli	a5,a5,0x1a
    80001264:	00b7f463          	bgeu	a5,a1,8000126c <walkaddr+0xc>
    return 0;
    80001268:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000126a:	8082                	ret
{
    8000126c:	1141                	addi	sp,sp,-16
    8000126e:	e406                	sd	ra,8(sp)
    80001270:	e022                	sd	s0,0(sp)
    80001272:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001274:	4601                	li	a2,0
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	f44080e7          	jalr	-188(ra) # 800011ba <walk>
  if(pte == 0)
    8000127e:	c105                	beqz	a0,8000129e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001280:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001282:	0117f693          	andi	a3,a5,17
    80001286:	4745                	li	a4,17
    return 0;
    80001288:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000128a:	00e68663          	beq	a3,a4,80001296 <walkaddr+0x36>
}
    8000128e:	60a2                	ld	ra,8(sp)
    80001290:	6402                	ld	s0,0(sp)
    80001292:	0141                	addi	sp,sp,16
    80001294:	8082                	ret
  pa = PTE2PA(*pte);
    80001296:	83a9                	srli	a5,a5,0xa
    80001298:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000129c:	bfcd                	j	8000128e <walkaddr+0x2e>
    return 0;
    8000129e:	4501                	li	a0,0
    800012a0:	b7fd                	j	8000128e <walkaddr+0x2e>

00000000800012a2 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012a2:	715d                	addi	sp,sp,-80
    800012a4:	e486                	sd	ra,72(sp)
    800012a6:	e0a2                	sd	s0,64(sp)
    800012a8:	fc26                	sd	s1,56(sp)
    800012aa:	f84a                	sd	s2,48(sp)
    800012ac:	f44e                	sd	s3,40(sp)
    800012ae:	f052                	sd	s4,32(sp)
    800012b0:	ec56                	sd	s5,24(sp)
    800012b2:	e85a                	sd	s6,16(sp)
    800012b4:	e45e                	sd	s7,8(sp)
    800012b6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800012b8:	c639                	beqz	a2,80001306 <mappages+0x64>
    800012ba:	8aaa                	mv	s5,a0
    800012bc:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800012be:	777d                	lui	a4,0xfffff
    800012c0:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800012c4:	fff58993          	addi	s3,a1,-1
    800012c8:	99b2                	add	s3,s3,a2
    800012ca:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800012ce:	893e                	mv	s2,a5
    800012d0:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800012d4:	6b85                	lui	s7,0x1
    800012d6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800012da:	4605                	li	a2,1
    800012dc:	85ca                	mv	a1,s2
    800012de:	8556                	mv	a0,s5
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	eda080e7          	jalr	-294(ra) # 800011ba <walk>
    800012e8:	cd1d                	beqz	a0,80001326 <mappages+0x84>
    if(*pte & PTE_V)
    800012ea:	611c                	ld	a5,0(a0)
    800012ec:	8b85                	andi	a5,a5,1
    800012ee:	e785                	bnez	a5,80001316 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800012f0:	80b1                	srli	s1,s1,0xc
    800012f2:	04aa                	slli	s1,s1,0xa
    800012f4:	0164e4b3          	or	s1,s1,s6
    800012f8:	0014e493          	ori	s1,s1,1
    800012fc:	e104                	sd	s1,0(a0)
    if(a == last)
    800012fe:	05390063          	beq	s2,s3,8000133e <mappages+0x9c>
    a += PGSIZE;
    80001302:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001304:	bfc9                	j	800012d6 <mappages+0x34>
    panic("mappages: size");
    80001306:	00007517          	auipc	a0,0x7
    8000130a:	e1250513          	addi	a0,a0,-494 # 80008118 <digits+0xc8>
    8000130e:	fffff097          	auipc	ra,0xfffff
    80001312:	232080e7          	jalr	562(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001316:	00007517          	auipc	a0,0x7
    8000131a:	e1250513          	addi	a0,a0,-494 # 80008128 <digits+0xd8>
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	222080e7          	jalr	546(ra) # 80000540 <panic>
      return -1;
    80001326:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001328:	60a6                	ld	ra,72(sp)
    8000132a:	6406                	ld	s0,64(sp)
    8000132c:	74e2                	ld	s1,56(sp)
    8000132e:	7942                	ld	s2,48(sp)
    80001330:	79a2                	ld	s3,40(sp)
    80001332:	7a02                	ld	s4,32(sp)
    80001334:	6ae2                	ld	s5,24(sp)
    80001336:	6b42                	ld	s6,16(sp)
    80001338:	6ba2                	ld	s7,8(sp)
    8000133a:	6161                	addi	sp,sp,80
    8000133c:	8082                	ret
  return 0;
    8000133e:	4501                	li	a0,0
    80001340:	b7e5                	j	80001328 <mappages+0x86>

0000000080001342 <kvmmap>:
{
    80001342:	1141                	addi	sp,sp,-16
    80001344:	e406                	sd	ra,8(sp)
    80001346:	e022                	sd	s0,0(sp)
    80001348:	0800                	addi	s0,sp,16
    8000134a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000134c:	86b2                	mv	a3,a2
    8000134e:	863e                	mv	a2,a5
    80001350:	00000097          	auipc	ra,0x0
    80001354:	f52080e7          	jalr	-174(ra) # 800012a2 <mappages>
    80001358:	e509                	bnez	a0,80001362 <kvmmap+0x20>
}
    8000135a:	60a2                	ld	ra,8(sp)
    8000135c:	6402                	ld	s0,0(sp)
    8000135e:	0141                	addi	sp,sp,16
    80001360:	8082                	ret
    panic("kvmmap");
    80001362:	00007517          	auipc	a0,0x7
    80001366:	dd650513          	addi	a0,a0,-554 # 80008138 <digits+0xe8>
    8000136a:	fffff097          	auipc	ra,0xfffff
    8000136e:	1d6080e7          	jalr	470(ra) # 80000540 <panic>

0000000080001372 <kvmmake>:
{
    80001372:	1101                	addi	sp,sp,-32
    80001374:	ec06                	sd	ra,24(sp)
    80001376:	e822                	sd	s0,16(sp)
    80001378:	e426                	sd	s1,8(sp)
    8000137a:	e04a                	sd	s2,0(sp)
    8000137c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	914080e7          	jalr	-1772(ra) # 80000c92 <kalloc>
    80001386:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001388:	6605                	lui	a2,0x1
    8000138a:	4581                	li	a1,0
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	b4a080e7          	jalr	-1206(ra) # 80000ed6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001394:	4719                	li	a4,6
    80001396:	6685                	lui	a3,0x1
    80001398:	10000637          	lui	a2,0x10000
    8000139c:	100005b7          	lui	a1,0x10000
    800013a0:	8526                	mv	a0,s1
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	fa0080e7          	jalr	-96(ra) # 80001342 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013aa:	4719                	li	a4,6
    800013ac:	6685                	lui	a3,0x1
    800013ae:	10001637          	lui	a2,0x10001
    800013b2:	100015b7          	lui	a1,0x10001
    800013b6:	8526                	mv	a0,s1
    800013b8:	00000097          	auipc	ra,0x0
    800013bc:	f8a080e7          	jalr	-118(ra) # 80001342 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013c0:	4719                	li	a4,6
    800013c2:	004006b7          	lui	a3,0x400
    800013c6:	0c000637          	lui	a2,0xc000
    800013ca:	0c0005b7          	lui	a1,0xc000
    800013ce:	8526                	mv	a0,s1
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	f72080e7          	jalr	-142(ra) # 80001342 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013d8:	00007917          	auipc	s2,0x7
    800013dc:	c2890913          	addi	s2,s2,-984 # 80008000 <etext>
    800013e0:	4729                	li	a4,10
    800013e2:	80007697          	auipc	a3,0x80007
    800013e6:	c1e68693          	addi	a3,a3,-994 # 8000 <_entry-0x7fff8000>
    800013ea:	4605                	li	a2,1
    800013ec:	067e                	slli	a2,a2,0x1f
    800013ee:	85b2                	mv	a1,a2
    800013f0:	8526                	mv	a0,s1
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	f50080e7          	jalr	-176(ra) # 80001342 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013fa:	4719                	li	a4,6
    800013fc:	46c5                	li	a3,17
    800013fe:	06ee                	slli	a3,a3,0x1b
    80001400:	412686b3          	sub	a3,a3,s2
    80001404:	864a                	mv	a2,s2
    80001406:	85ca                	mv	a1,s2
    80001408:	8526                	mv	a0,s1
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	f38080e7          	jalr	-200(ra) # 80001342 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001412:	4729                	li	a4,10
    80001414:	6685                	lui	a3,0x1
    80001416:	00006617          	auipc	a2,0x6
    8000141a:	bea60613          	addi	a2,a2,-1046 # 80007000 <_trampoline>
    8000141e:	040005b7          	lui	a1,0x4000
    80001422:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001424:	05b2                	slli	a1,a1,0xc
    80001426:	8526                	mv	a0,s1
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	f1a080e7          	jalr	-230(ra) # 80001342 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001430:	8526                	mv	a0,s1
    80001432:	00000097          	auipc	ra,0x0
    80001436:	6d2080e7          	jalr	1746(ra) # 80001b04 <proc_mapstacks>
}
    8000143a:	8526                	mv	a0,s1
    8000143c:	60e2                	ld	ra,24(sp)
    8000143e:	6442                	ld	s0,16(sp)
    80001440:	64a2                	ld	s1,8(sp)
    80001442:	6902                	ld	s2,0(sp)
    80001444:	6105                	addi	sp,sp,32
    80001446:	8082                	ret

0000000080001448 <kvminit>:
{
    80001448:	1141                	addi	sp,sp,-16
    8000144a:	e406                	sd	ra,8(sp)
    8000144c:	e022                	sd	s0,0(sp)
    8000144e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001450:	00000097          	auipc	ra,0x0
    80001454:	f22080e7          	jalr	-222(ra) # 80001372 <kvmmake>
    80001458:	00007797          	auipc	a5,0x7
    8000145c:	6aa7b423          	sd	a0,1704(a5) # 80008b00 <kernel_pagetable>
}
    80001460:	60a2                	ld	ra,8(sp)
    80001462:	6402                	ld	s0,0(sp)
    80001464:	0141                	addi	sp,sp,16
    80001466:	8082                	ret

0000000080001468 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001468:	715d                	addi	sp,sp,-80
    8000146a:	e486                	sd	ra,72(sp)
    8000146c:	e0a2                	sd	s0,64(sp)
    8000146e:	fc26                	sd	s1,56(sp)
    80001470:	f84a                	sd	s2,48(sp)
    80001472:	f44e                	sd	s3,40(sp)
    80001474:	f052                	sd	s4,32(sp)
    80001476:	ec56                	sd	s5,24(sp)
    80001478:	e85a                	sd	s6,16(sp)
    8000147a:	e45e                	sd	s7,8(sp)
    8000147c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000147e:	03459793          	slli	a5,a1,0x34
    80001482:	e795                	bnez	a5,800014ae <uvmunmap+0x46>
    80001484:	8a2a                	mv	s4,a0
    80001486:	892e                	mv	s2,a1
    80001488:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000148a:	0632                	slli	a2,a2,0xc
    8000148c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001490:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001492:	6b05                	lui	s6,0x1
    80001494:	0735e263          	bltu	a1,s3,800014f8 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001498:	60a6                	ld	ra,72(sp)
    8000149a:	6406                	ld	s0,64(sp)
    8000149c:	74e2                	ld	s1,56(sp)
    8000149e:	7942                	ld	s2,48(sp)
    800014a0:	79a2                	ld	s3,40(sp)
    800014a2:	7a02                	ld	s4,32(sp)
    800014a4:	6ae2                	ld	s5,24(sp)
    800014a6:	6b42                	ld	s6,16(sp)
    800014a8:	6ba2                	ld	s7,8(sp)
    800014aa:	6161                	addi	sp,sp,80
    800014ac:	8082                	ret
    panic("uvmunmap: not aligned");
    800014ae:	00007517          	auipc	a0,0x7
    800014b2:	c9250513          	addi	a0,a0,-878 # 80008140 <digits+0xf0>
    800014b6:	fffff097          	auipc	ra,0xfffff
    800014ba:	08a080e7          	jalr	138(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800014be:	00007517          	auipc	a0,0x7
    800014c2:	c9a50513          	addi	a0,a0,-870 # 80008158 <digits+0x108>
    800014c6:	fffff097          	auipc	ra,0xfffff
    800014ca:	07a080e7          	jalr	122(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800014ce:	00007517          	auipc	a0,0x7
    800014d2:	c9a50513          	addi	a0,a0,-870 # 80008168 <digits+0x118>
    800014d6:	fffff097          	auipc	ra,0xfffff
    800014da:	06a080e7          	jalr	106(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800014de:	00007517          	auipc	a0,0x7
    800014e2:	ca250513          	addi	a0,a0,-862 # 80008180 <digits+0x130>
    800014e6:	fffff097          	auipc	ra,0xfffff
    800014ea:	05a080e7          	jalr	90(ra) # 80000540 <panic>
    *pte = 0;
    800014ee:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014f2:	995a                	add	s2,s2,s6
    800014f4:	fb3972e3          	bgeu	s2,s3,80001498 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800014f8:	4601                	li	a2,0
    800014fa:	85ca                	mv	a1,s2
    800014fc:	8552                	mv	a0,s4
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	cbc080e7          	jalr	-836(ra) # 800011ba <walk>
    80001506:	84aa                	mv	s1,a0
    80001508:	d95d                	beqz	a0,800014be <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000150a:	6108                	ld	a0,0(a0)
    8000150c:	00157793          	andi	a5,a0,1
    80001510:	dfdd                	beqz	a5,800014ce <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001512:	3ff57793          	andi	a5,a0,1023
    80001516:	fd7784e3          	beq	a5,s7,800014de <uvmunmap+0x76>
    if(do_free){
    8000151a:	fc0a8ae3          	beqz	s5,800014ee <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000151e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001520:	0532                	slli	a0,a0,0xc
    80001522:	fffff097          	auipc	ra,0xfffff
    80001526:	630080e7          	jalr	1584(ra) # 80000b52 <kfree>
    8000152a:	b7d1                	j	800014ee <uvmunmap+0x86>

000000008000152c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001536:	fffff097          	auipc	ra,0xfffff
    8000153a:	75c080e7          	jalr	1884(ra) # 80000c92 <kalloc>
    8000153e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001540:	c519                	beqz	a0,8000154e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001542:	6605                	lui	a2,0x1
    80001544:	4581                	li	a1,0
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	990080e7          	jalr	-1648(ra) # 80000ed6 <memset>
  return pagetable;
}
    8000154e:	8526                	mv	a0,s1
    80001550:	60e2                	ld	ra,24(sp)
    80001552:	6442                	ld	s0,16(sp)
    80001554:	64a2                	ld	s1,8(sp)
    80001556:	6105                	addi	sp,sp,32
    80001558:	8082                	ret

000000008000155a <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000155a:	7179                	addi	sp,sp,-48
    8000155c:	f406                	sd	ra,40(sp)
    8000155e:	f022                	sd	s0,32(sp)
    80001560:	ec26                	sd	s1,24(sp)
    80001562:	e84a                	sd	s2,16(sp)
    80001564:	e44e                	sd	s3,8(sp)
    80001566:	e052                	sd	s4,0(sp)
    80001568:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000156a:	6785                	lui	a5,0x1
    8000156c:	04f67863          	bgeu	a2,a5,800015bc <uvmfirst+0x62>
    80001570:	8a2a                	mv	s4,a0
    80001572:	89ae                	mv	s3,a1
    80001574:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001576:	fffff097          	auipc	ra,0xfffff
    8000157a:	71c080e7          	jalr	1820(ra) # 80000c92 <kalloc>
    8000157e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001580:	6605                	lui	a2,0x1
    80001582:	4581                	li	a1,0
    80001584:	00000097          	auipc	ra,0x0
    80001588:	952080e7          	jalr	-1710(ra) # 80000ed6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000158c:	4779                	li	a4,30
    8000158e:	86ca                	mv	a3,s2
    80001590:	6605                	lui	a2,0x1
    80001592:	4581                	li	a1,0
    80001594:	8552                	mv	a0,s4
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	d0c080e7          	jalr	-756(ra) # 800012a2 <mappages>
  memmove(mem, src, sz);
    8000159e:	8626                	mv	a2,s1
    800015a0:	85ce                	mv	a1,s3
    800015a2:	854a                	mv	a0,s2
    800015a4:	00000097          	auipc	ra,0x0
    800015a8:	98e080e7          	jalr	-1650(ra) # 80000f32 <memmove>
}
    800015ac:	70a2                	ld	ra,40(sp)
    800015ae:	7402                	ld	s0,32(sp)
    800015b0:	64e2                	ld	s1,24(sp)
    800015b2:	6942                	ld	s2,16(sp)
    800015b4:	69a2                	ld	s3,8(sp)
    800015b6:	6a02                	ld	s4,0(sp)
    800015b8:	6145                	addi	sp,sp,48
    800015ba:	8082                	ret
    panic("uvmfirst: more than a page");
    800015bc:	00007517          	auipc	a0,0x7
    800015c0:	bdc50513          	addi	a0,a0,-1060 # 80008198 <digits+0x148>
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	f7c080e7          	jalr	-132(ra) # 80000540 <panic>

00000000800015cc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015cc:	1101                	addi	sp,sp,-32
    800015ce:	ec06                	sd	ra,24(sp)
    800015d0:	e822                	sd	s0,16(sp)
    800015d2:	e426                	sd	s1,8(sp)
    800015d4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800015d6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015d8:	00b67d63          	bgeu	a2,a1,800015f2 <uvmdealloc+0x26>
    800015dc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800015de:	6785                	lui	a5,0x1
    800015e0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015e2:	00f60733          	add	a4,a2,a5
    800015e6:	76fd                	lui	a3,0xfffff
    800015e8:	8f75                	and	a4,a4,a3
    800015ea:	97ae                	add	a5,a5,a1
    800015ec:	8ff5                	and	a5,a5,a3
    800015ee:	00f76863          	bltu	a4,a5,800015fe <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800015f2:	8526                	mv	a0,s1
    800015f4:	60e2                	ld	ra,24(sp)
    800015f6:	6442                	ld	s0,16(sp)
    800015f8:	64a2                	ld	s1,8(sp)
    800015fa:	6105                	addi	sp,sp,32
    800015fc:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015fe:	8f99                	sub	a5,a5,a4
    80001600:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001602:	4685                	li	a3,1
    80001604:	0007861b          	sext.w	a2,a5
    80001608:	85ba                	mv	a1,a4
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	e5e080e7          	jalr	-418(ra) # 80001468 <uvmunmap>
    80001612:	b7c5                	j	800015f2 <uvmdealloc+0x26>

0000000080001614 <uvmalloc>:
  if(newsz < oldsz)
    80001614:	0ab66563          	bltu	a2,a1,800016be <uvmalloc+0xaa>
{
    80001618:	7139                	addi	sp,sp,-64
    8000161a:	fc06                	sd	ra,56(sp)
    8000161c:	f822                	sd	s0,48(sp)
    8000161e:	f426                	sd	s1,40(sp)
    80001620:	f04a                	sd	s2,32(sp)
    80001622:	ec4e                	sd	s3,24(sp)
    80001624:	e852                	sd	s4,16(sp)
    80001626:	e456                	sd	s5,8(sp)
    80001628:	e05a                	sd	s6,0(sp)
    8000162a:	0080                	addi	s0,sp,64
    8000162c:	8aaa                	mv	s5,a0
    8000162e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001630:	6785                	lui	a5,0x1
    80001632:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001634:	95be                	add	a1,a1,a5
    80001636:	77fd                	lui	a5,0xfffff
    80001638:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000163c:	08c9f363          	bgeu	s3,a2,800016c2 <uvmalloc+0xae>
    80001640:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001642:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001646:	fffff097          	auipc	ra,0xfffff
    8000164a:	64c080e7          	jalr	1612(ra) # 80000c92 <kalloc>
    8000164e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001650:	c51d                	beqz	a0,8000167e <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001652:	6605                	lui	a2,0x1
    80001654:	4581                	li	a1,0
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	880080e7          	jalr	-1920(ra) # 80000ed6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000165e:	875a                	mv	a4,s6
    80001660:	86a6                	mv	a3,s1
    80001662:	6605                	lui	a2,0x1
    80001664:	85ca                	mv	a1,s2
    80001666:	8556                	mv	a0,s5
    80001668:	00000097          	auipc	ra,0x0
    8000166c:	c3a080e7          	jalr	-966(ra) # 800012a2 <mappages>
    80001670:	e90d                	bnez	a0,800016a2 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001672:	6785                	lui	a5,0x1
    80001674:	993e                	add	s2,s2,a5
    80001676:	fd4968e3          	bltu	s2,s4,80001646 <uvmalloc+0x32>
  return newsz;
    8000167a:	8552                	mv	a0,s4
    8000167c:	a809                	j	8000168e <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000167e:	864e                	mv	a2,s3
    80001680:	85ca                	mv	a1,s2
    80001682:	8556                	mv	a0,s5
    80001684:	00000097          	auipc	ra,0x0
    80001688:	f48080e7          	jalr	-184(ra) # 800015cc <uvmdealloc>
      return 0;
    8000168c:	4501                	li	a0,0
}
    8000168e:	70e2                	ld	ra,56(sp)
    80001690:	7442                	ld	s0,48(sp)
    80001692:	74a2                	ld	s1,40(sp)
    80001694:	7902                	ld	s2,32(sp)
    80001696:	69e2                	ld	s3,24(sp)
    80001698:	6a42                	ld	s4,16(sp)
    8000169a:	6aa2                	ld	s5,8(sp)
    8000169c:	6b02                	ld	s6,0(sp)
    8000169e:	6121                	addi	sp,sp,64
    800016a0:	8082                	ret
      kfree(mem);
    800016a2:	8526                	mv	a0,s1
    800016a4:	fffff097          	auipc	ra,0xfffff
    800016a8:	4ae080e7          	jalr	1198(ra) # 80000b52 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016ac:	864e                	mv	a2,s3
    800016ae:	85ca                	mv	a1,s2
    800016b0:	8556                	mv	a0,s5
    800016b2:	00000097          	auipc	ra,0x0
    800016b6:	f1a080e7          	jalr	-230(ra) # 800015cc <uvmdealloc>
      return 0;
    800016ba:	4501                	li	a0,0
    800016bc:	bfc9                	j	8000168e <uvmalloc+0x7a>
    return oldsz;
    800016be:	852e                	mv	a0,a1
}
    800016c0:	8082                	ret
  return newsz;
    800016c2:	8532                	mv	a0,a2
    800016c4:	b7e9                	j	8000168e <uvmalloc+0x7a>

00000000800016c6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016c6:	7179                	addi	sp,sp,-48
    800016c8:	f406                	sd	ra,40(sp)
    800016ca:	f022                	sd	s0,32(sp)
    800016cc:	ec26                	sd	s1,24(sp)
    800016ce:	e84a                	sd	s2,16(sp)
    800016d0:	e44e                	sd	s3,8(sp)
    800016d2:	e052                	sd	s4,0(sp)
    800016d4:	1800                	addi	s0,sp,48
    800016d6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016d8:	84aa                	mv	s1,a0
    800016da:	6905                	lui	s2,0x1
    800016dc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016de:	4985                	li	s3,1
    800016e0:	a829                	j	800016fa <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800016e2:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800016e4:	00c79513          	slli	a0,a5,0xc
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	fde080e7          	jalr	-34(ra) # 800016c6 <freewalk>
      pagetable[i] = 0;
    800016f0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800016f4:	04a1                	addi	s1,s1,8
    800016f6:	03248163          	beq	s1,s2,80001718 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800016fa:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016fc:	00f7f713          	andi	a4,a5,15
    80001700:	ff3701e3          	beq	a4,s3,800016e2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001704:	8b85                	andi	a5,a5,1
    80001706:	d7fd                	beqz	a5,800016f4 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001708:	00007517          	auipc	a0,0x7
    8000170c:	ab050513          	addi	a0,a0,-1360 # 800081b8 <digits+0x168>
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	e30080e7          	jalr	-464(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001718:	8552                	mv	a0,s4
    8000171a:	fffff097          	auipc	ra,0xfffff
    8000171e:	438080e7          	jalr	1080(ra) # 80000b52 <kfree>
}
    80001722:	70a2                	ld	ra,40(sp)
    80001724:	7402                	ld	s0,32(sp)
    80001726:	64e2                	ld	s1,24(sp)
    80001728:	6942                	ld	s2,16(sp)
    8000172a:	69a2                	ld	s3,8(sp)
    8000172c:	6a02                	ld	s4,0(sp)
    8000172e:	6145                	addi	sp,sp,48
    80001730:	8082                	ret

0000000080001732 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001732:	1101                	addi	sp,sp,-32
    80001734:	ec06                	sd	ra,24(sp)
    80001736:	e822                	sd	s0,16(sp)
    80001738:	e426                	sd	s1,8(sp)
    8000173a:	1000                	addi	s0,sp,32
    8000173c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000173e:	e999                	bnez	a1,80001754 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001740:	8526                	mv	a0,s1
    80001742:	00000097          	auipc	ra,0x0
    80001746:	f84080e7          	jalr	-124(ra) # 800016c6 <freewalk>
}
    8000174a:	60e2                	ld	ra,24(sp)
    8000174c:	6442                	ld	s0,16(sp)
    8000174e:	64a2                	ld	s1,8(sp)
    80001750:	6105                	addi	sp,sp,32
    80001752:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001754:	6785                	lui	a5,0x1
    80001756:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001758:	95be                	add	a1,a1,a5
    8000175a:	4685                	li	a3,1
    8000175c:	00c5d613          	srli	a2,a1,0xc
    80001760:	4581                	li	a1,0
    80001762:	00000097          	auipc	ra,0x0
    80001766:	d06080e7          	jalr	-762(ra) # 80001468 <uvmunmap>
    8000176a:	bfd9                	j	80001740 <uvmfree+0xe>

000000008000176c <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    8000176c:	715d                	addi	sp,sp,-80
    8000176e:	e486                	sd	ra,72(sp)
    80001770:	e0a2                	sd	s0,64(sp)
    80001772:	fc26                	sd	s1,56(sp)
    80001774:	f84a                	sd	s2,48(sp)
    80001776:	f44e                	sd	s3,40(sp)
    80001778:	f052                	sd	s4,32(sp)
    8000177a:	ec56                	sd	s5,24(sp)
    8000177c:	e85a                	sd	s6,16(sp)
    8000177e:	e45e                	sd	s7,8(sp)
    80001780:	0880                	addi	s0,sp,80
   pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001782:	ca4d                	beqz	a2,80001834 <uvmcopy+0xc8>
    80001784:	8b2a                	mv	s6,a0
    80001786:	8aae                	mv	s5,a1
    80001788:	8a32                	mv	s4,a2
    8000178a:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    8000178c:	4601                	li	a2,0
    8000178e:	85ca                	mv	a1,s2
    80001790:	855a                	mv	a0,s6
    80001792:	00000097          	auipc	ra,0x0
    80001796:	a28080e7          	jalr	-1496(ra) # 800011ba <walk>
    8000179a:	84aa                	mv	s1,a0
    8000179c:	c531                	beqz	a0,800017e8 <uvmcopy+0x7c>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000179e:	6118                	ld	a4,0(a0)
    800017a0:	00177793          	andi	a5,a4,1
    800017a4:	cbb1                	beqz	a5,800017f8 <uvmcopy+0x8c>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800017a6:	00a75993          	srli	s3,a4,0xa
    800017aa:	09b2                	slli	s3,s3,0xc
    flags = PTE_FLAGS(*pte) & ~PTE_W;
    800017ac:	3fb77713          	andi	a4,a4,1019

    if(mappages(new, i, PGSIZE, pa, flags | PTE_COW) != 0)
    800017b0:	02076713          	ori	a4,a4,32
    800017b4:	86ce                	mv	a3,s3
    800017b6:	6605                	lui	a2,0x1
    800017b8:	85ca                	mv	a1,s2
    800017ba:	8556                	mv	a0,s5
    800017bc:	00000097          	auipc	ra,0x0
    800017c0:	ae6080e7          	jalr	-1306(ra) # 800012a2 <mappages>
    800017c4:	8baa                	mv	s7,a0
    800017c6:	e129                	bnez	a0,80001808 <uvmcopy+0x9c>
      goto err;
    
    *pte |= PTE_COW;
    *pte &= ~PTE_W;
    800017c8:	609c                	ld	a5,0(s1)
    800017ca:	9bed                	andi	a5,a5,-5
    800017cc:	0207e793          	ori	a5,a5,32
    800017d0:	e09c                	sd	a5,0(s1)
    incRefCount(pa);
    800017d2:	0009851b          	sext.w	a0,s3
    800017d6:	fffff097          	auipc	ra,0xfffff
    800017da:	316080e7          	jalr	790(ra) # 80000aec <incRefCount>
  for(i = 0; i < sz; i += PGSIZE){
    800017de:	6785                	lui	a5,0x1
    800017e0:	993e                	add	s2,s2,a5
    800017e2:	fb4965e3          	bltu	s2,s4,8000178c <uvmcopy+0x20>
    800017e6:	a81d                	j	8000181c <uvmcopy+0xb0>
      panic("uvmcopy: pte should exist");
    800017e8:	00007517          	auipc	a0,0x7
    800017ec:	9e050513          	addi	a0,a0,-1568 # 800081c8 <digits+0x178>
    800017f0:	fffff097          	auipc	ra,0xfffff
    800017f4:	d50080e7          	jalr	-688(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800017f8:	00007517          	auipc	a0,0x7
    800017fc:	9f050513          	addi	a0,a0,-1552 # 800081e8 <digits+0x198>
    80001800:	fffff097          	auipc	ra,0xfffff
    80001804:	d40080e7          	jalr	-704(ra) # 80000540 <panic>
    //printf("uvmcopy-ed: %x -> %d\n", pa, getRefCount((uint64)pa));
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001808:	4685                	li	a3,1
    8000180a:	00c95613          	srli	a2,s2,0xc
    8000180e:	4581                	li	a1,0
    80001810:	8556                	mv	a0,s5
    80001812:	00000097          	auipc	ra,0x0
    80001816:	c56080e7          	jalr	-938(ra) # 80001468 <uvmunmap>
  return -1;
    8000181a:	5bfd                	li	s7,-1
}
    8000181c:	855e                	mv	a0,s7
    8000181e:	60a6                	ld	ra,72(sp)
    80001820:	6406                	ld	s0,64(sp)
    80001822:	74e2                	ld	s1,56(sp)
    80001824:	7942                	ld	s2,48(sp)
    80001826:	79a2                	ld	s3,40(sp)
    80001828:	7a02                	ld	s4,32(sp)
    8000182a:	6ae2                	ld	s5,24(sp)
    8000182c:	6b42                	ld	s6,16(sp)
    8000182e:	6ba2                	ld	s7,8(sp)
    80001830:	6161                	addi	sp,sp,80
    80001832:	8082                	ret
  return 0;
    80001834:	4b81                	li	s7,0
    80001836:	b7dd                	j	8000181c <uvmcopy+0xb0>

0000000080001838 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001838:	1141                	addi	sp,sp,-16
    8000183a:	e406                	sd	ra,8(sp)
    8000183c:	e022                	sd	s0,0(sp)
    8000183e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001840:	4601                	li	a2,0
    80001842:	00000097          	auipc	ra,0x0
    80001846:	978080e7          	jalr	-1672(ra) # 800011ba <walk>
  if(pte == 0)
    8000184a:	c901                	beqz	a0,8000185a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000184c:	611c                	ld	a5,0(a0)
    8000184e:	9bbd                	andi	a5,a5,-17
    80001850:	e11c                	sd	a5,0(a0)
}
    80001852:	60a2                	ld	ra,8(sp)
    80001854:	6402                	ld	s0,0(sp)
    80001856:	0141                	addi	sp,sp,16
    80001858:	8082                	ret
    panic("uvmclear");
    8000185a:	00007517          	auipc	a0,0x7
    8000185e:	9ae50513          	addi	a0,a0,-1618 # 80008208 <digits+0x1b8>
    80001862:	fffff097          	auipc	ra,0xfffff
    80001866:	cde080e7          	jalr	-802(ra) # 80000540 <panic>

000000008000186a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000186a:	c6bd                	beqz	a3,800018d8 <copyout+0x6e>
{
    8000186c:	715d                	addi	sp,sp,-80
    8000186e:	e486                	sd	ra,72(sp)
    80001870:	e0a2                	sd	s0,64(sp)
    80001872:	fc26                	sd	s1,56(sp)
    80001874:	f84a                	sd	s2,48(sp)
    80001876:	f44e                	sd	s3,40(sp)
    80001878:	f052                	sd	s4,32(sp)
    8000187a:	ec56                	sd	s5,24(sp)
    8000187c:	e85a                	sd	s6,16(sp)
    8000187e:	e45e                	sd	s7,8(sp)
    80001880:	e062                	sd	s8,0(sp)
    80001882:	0880                	addi	s0,sp,80
    80001884:	8b2a                	mv	s6,a0
    80001886:	8c2e                	mv	s8,a1
    80001888:	8a32                	mv	s4,a2
    8000188a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000188c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000188e:	6a85                	lui	s5,0x1
    80001890:	a015                	j	800018b4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001892:	9562                	add	a0,a0,s8
    80001894:	0004861b          	sext.w	a2,s1
    80001898:	85d2                	mv	a1,s4
    8000189a:	41250533          	sub	a0,a0,s2
    8000189e:	fffff097          	auipc	ra,0xfffff
    800018a2:	694080e7          	jalr	1684(ra) # 80000f32 <memmove>

    len -= n;
    800018a6:	409989b3          	sub	s3,s3,s1
    src += n;
    800018aa:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800018ac:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018b0:	02098263          	beqz	s3,800018d4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800018b4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018b8:	85ca                	mv	a1,s2
    800018ba:	855a                	mv	a0,s6
    800018bc:	00000097          	auipc	ra,0x0
    800018c0:	9a4080e7          	jalr	-1628(ra) # 80001260 <walkaddr>
    if(pa0 == 0)
    800018c4:	cd01                	beqz	a0,800018dc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800018c6:	418904b3          	sub	s1,s2,s8
    800018ca:	94d6                	add	s1,s1,s5
    800018cc:	fc99f3e3          	bgeu	s3,s1,80001892 <copyout+0x28>
    800018d0:	84ce                	mv	s1,s3
    800018d2:	b7c1                	j	80001892 <copyout+0x28>
  }
  return 0;
    800018d4:	4501                	li	a0,0
    800018d6:	a021                	j	800018de <copyout+0x74>
    800018d8:	4501                	li	a0,0
}
    800018da:	8082                	ret
      return -1;
    800018dc:	557d                	li	a0,-1
}
    800018de:	60a6                	ld	ra,72(sp)
    800018e0:	6406                	ld	s0,64(sp)
    800018e2:	74e2                	ld	s1,56(sp)
    800018e4:	7942                	ld	s2,48(sp)
    800018e6:	79a2                	ld	s3,40(sp)
    800018e8:	7a02                	ld	s4,32(sp)
    800018ea:	6ae2                	ld	s5,24(sp)
    800018ec:	6b42                	ld	s6,16(sp)
    800018ee:	6ba2                	ld	s7,8(sp)
    800018f0:	6c02                	ld	s8,0(sp)
    800018f2:	6161                	addi	sp,sp,80
    800018f4:	8082                	ret

00000000800018f6 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018f6:	caa5                	beqz	a3,80001966 <copyin+0x70>
{
    800018f8:	715d                	addi	sp,sp,-80
    800018fa:	e486                	sd	ra,72(sp)
    800018fc:	e0a2                	sd	s0,64(sp)
    800018fe:	fc26                	sd	s1,56(sp)
    80001900:	f84a                	sd	s2,48(sp)
    80001902:	f44e                	sd	s3,40(sp)
    80001904:	f052                	sd	s4,32(sp)
    80001906:	ec56                	sd	s5,24(sp)
    80001908:	e85a                	sd	s6,16(sp)
    8000190a:	e45e                	sd	s7,8(sp)
    8000190c:	e062                	sd	s8,0(sp)
    8000190e:	0880                	addi	s0,sp,80
    80001910:	8b2a                	mv	s6,a0
    80001912:	8a2e                	mv	s4,a1
    80001914:	8c32                	mv	s8,a2
    80001916:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001918:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000191a:	6a85                	lui	s5,0x1
    8000191c:	a01d                	j	80001942 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000191e:	018505b3          	add	a1,a0,s8
    80001922:	0004861b          	sext.w	a2,s1
    80001926:	412585b3          	sub	a1,a1,s2
    8000192a:	8552                	mv	a0,s4
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	606080e7          	jalr	1542(ra) # 80000f32 <memmove>

    len -= n;
    80001934:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001938:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000193a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000193e:	02098263          	beqz	s3,80001962 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001942:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001946:	85ca                	mv	a1,s2
    80001948:	855a                	mv	a0,s6
    8000194a:	00000097          	auipc	ra,0x0
    8000194e:	916080e7          	jalr	-1770(ra) # 80001260 <walkaddr>
    if(pa0 == 0)
    80001952:	cd01                	beqz	a0,8000196a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001954:	418904b3          	sub	s1,s2,s8
    80001958:	94d6                	add	s1,s1,s5
    8000195a:	fc99f2e3          	bgeu	s3,s1,8000191e <copyin+0x28>
    8000195e:	84ce                	mv	s1,s3
    80001960:	bf7d                	j	8000191e <copyin+0x28>
  }
  return 0;
    80001962:	4501                	li	a0,0
    80001964:	a021                	j	8000196c <copyin+0x76>
    80001966:	4501                	li	a0,0
}
    80001968:	8082                	ret
      return -1;
    8000196a:	557d                	li	a0,-1
}
    8000196c:	60a6                	ld	ra,72(sp)
    8000196e:	6406                	ld	s0,64(sp)
    80001970:	74e2                	ld	s1,56(sp)
    80001972:	7942                	ld	s2,48(sp)
    80001974:	79a2                	ld	s3,40(sp)
    80001976:	7a02                	ld	s4,32(sp)
    80001978:	6ae2                	ld	s5,24(sp)
    8000197a:	6b42                	ld	s6,16(sp)
    8000197c:	6ba2                	ld	s7,8(sp)
    8000197e:	6c02                	ld	s8,0(sp)
    80001980:	6161                	addi	sp,sp,80
    80001982:	8082                	ret

0000000080001984 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001984:	c2dd                	beqz	a3,80001a2a <copyinstr+0xa6>
{
    80001986:	715d                	addi	sp,sp,-80
    80001988:	e486                	sd	ra,72(sp)
    8000198a:	e0a2                	sd	s0,64(sp)
    8000198c:	fc26                	sd	s1,56(sp)
    8000198e:	f84a                	sd	s2,48(sp)
    80001990:	f44e                	sd	s3,40(sp)
    80001992:	f052                	sd	s4,32(sp)
    80001994:	ec56                	sd	s5,24(sp)
    80001996:	e85a                	sd	s6,16(sp)
    80001998:	e45e                	sd	s7,8(sp)
    8000199a:	0880                	addi	s0,sp,80
    8000199c:	8a2a                	mv	s4,a0
    8000199e:	8b2e                	mv	s6,a1
    800019a0:	8bb2                	mv	s7,a2
    800019a2:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800019a4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800019a6:	6985                	lui	s3,0x1
    800019a8:	a02d                	j	800019d2 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800019aa:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800019ae:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800019b0:	37fd                	addiw	a5,a5,-1
    800019b2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800019b6:	60a6                	ld	ra,72(sp)
    800019b8:	6406                	ld	s0,64(sp)
    800019ba:	74e2                	ld	s1,56(sp)
    800019bc:	7942                	ld	s2,48(sp)
    800019be:	79a2                	ld	s3,40(sp)
    800019c0:	7a02                	ld	s4,32(sp)
    800019c2:	6ae2                	ld	s5,24(sp)
    800019c4:	6b42                	ld	s6,16(sp)
    800019c6:	6ba2                	ld	s7,8(sp)
    800019c8:	6161                	addi	sp,sp,80
    800019ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800019cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800019d0:	c8a9                	beqz	s1,80001a22 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800019d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800019d6:	85ca                	mv	a1,s2
    800019d8:	8552                	mv	a0,s4
    800019da:	00000097          	auipc	ra,0x0
    800019de:	886080e7          	jalr	-1914(ra) # 80001260 <walkaddr>
    if(pa0 == 0)
    800019e2:	c131                	beqz	a0,80001a26 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800019e4:	417906b3          	sub	a3,s2,s7
    800019e8:	96ce                	add	a3,a3,s3
    800019ea:	00d4f363          	bgeu	s1,a3,800019f0 <copyinstr+0x6c>
    800019ee:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019f0:	955e                	add	a0,a0,s7
    800019f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019f6:	daf9                	beqz	a3,800019cc <copyinstr+0x48>
    800019f8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019fa:	41650633          	sub	a2,a0,s6
    800019fe:	fff48593          	addi	a1,s1,-1
    80001a02:	95da                	add	a1,a1,s6
    while(n > 0){
    80001a04:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001a06:	00f60733          	add	a4,a2,a5
    80001a0a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbd070>
    80001a0e:	df51                	beqz	a4,800019aa <copyinstr+0x26>
        *dst = *p;
    80001a10:	00e78023          	sb	a4,0(a5)
      --max;
    80001a14:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001a18:	0785                	addi	a5,a5,1
    while(n > 0){
    80001a1a:	fed796e3          	bne	a5,a3,80001a06 <copyinstr+0x82>
      dst++;
    80001a1e:	8b3e                	mv	s6,a5
    80001a20:	b775                	j	800019cc <copyinstr+0x48>
    80001a22:	4781                	li	a5,0
    80001a24:	b771                	j	800019b0 <copyinstr+0x2c>
      return -1;
    80001a26:	557d                	li	a0,-1
    80001a28:	b779                	j	800019b6 <copyinstr+0x32>
  int got_null = 0;
    80001a2a:	4781                	li	a5,0
  if(got_null){
    80001a2c:	37fd                	addiw	a5,a5,-1
    80001a2e:	0007851b          	sext.w	a0,a5
}
    80001a32:	8082                	ret

0000000080001a34 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001a34:	715d                	addi	sp,sp,-80
    80001a36:	e486                	sd	ra,72(sp)
    80001a38:	e0a2                	sd	s0,64(sp)
    80001a3a:	fc26                	sd	s1,56(sp)
    80001a3c:	f84a                	sd	s2,48(sp)
    80001a3e:	f44e                	sd	s3,40(sp)
    80001a40:	f052                	sd	s4,32(sp)
    80001a42:	ec56                	sd	s5,24(sp)
    80001a44:	e85a                	sd	s6,16(sp)
    80001a46:	e45e                	sd	s7,8(sp)
    80001a48:	e062                	sd	s8,0(sp)
    80001a4a:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a4c:	8792                	mv	a5,tp
    int id = r_tp();
    80001a4e:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001a50:	0002fa97          	auipc	s5,0x2f
    80001a54:	330a8a93          	addi	s5,s5,816 # 80030d80 <cpus>
    80001a58:	00779713          	slli	a4,a5,0x7
    80001a5c:	00ea86b3          	add	a3,s5,a4
    80001a60:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffbd070>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001a64:	0721                	addi	a4,a4,8
    80001a66:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001a68:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001a6a:	00007c17          	auipc	s8,0x7
    80001a6e:	fcec0c13          	addi	s8,s8,-50 # 80008a38 <sched_pointer>
    80001a72:	00000b97          	auipc	s7,0x0
    80001a76:	fc2b8b93          	addi	s7,s7,-62 # 80001a34 <rr_scheduler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a7a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001a7e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a82:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001a86:	0002f497          	auipc	s1,0x2f
    80001a8a:	72a48493          	addi	s1,s1,1834 # 800311b0 <proc>
            if (p->state == RUNNABLE)
    80001a8e:	498d                	li	s3,3
                p->state = RUNNING;
    80001a90:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001a92:	00035a17          	auipc	s4,0x35
    80001a96:	11ea0a13          	addi	s4,s4,286 # 80036bb0 <tickslock>
    80001a9a:	a81d                	j	80001ad0 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	3f0080e7          	jalr	1008(ra) # 80000e8e <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001aa6:	60a6                	ld	ra,72(sp)
    80001aa8:	6406                	ld	s0,64(sp)
    80001aaa:	74e2                	ld	s1,56(sp)
    80001aac:	7942                	ld	s2,48(sp)
    80001aae:	79a2                	ld	s3,40(sp)
    80001ab0:	7a02                	ld	s4,32(sp)
    80001ab2:	6ae2                	ld	s5,24(sp)
    80001ab4:	6b42                	ld	s6,16(sp)
    80001ab6:	6ba2                	ld	s7,8(sp)
    80001ab8:	6c02                	ld	s8,0(sp)
    80001aba:	6161                	addi	sp,sp,80
    80001abc:	8082                	ret
            release(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	3ce080e7          	jalr	974(ra) # 80000e8e <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001ac8:	16848493          	addi	s1,s1,360
    80001acc:	fb4487e3          	beq	s1,s4,80001a7a <rr_scheduler+0x46>
            acquire(&p->lock);
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	308080e7          	jalr	776(ra) # 80000dda <acquire>
            if (p->state == RUNNABLE)
    80001ada:	4c9c                	lw	a5,24(s1)
    80001adc:	ff3791e3          	bne	a5,s3,80001abe <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001ae0:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001ae4:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    80001ae8:	06048593          	addi	a1,s1,96
    80001aec:	8556                	mv	a0,s5
    80001aee:	00001097          	auipc	ra,0x1
    80001af2:	016080e7          	jalr	22(ra) # 80002b04 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001af6:	000c3783          	ld	a5,0(s8)
    80001afa:	fb7791e3          	bne	a5,s7,80001a9c <rr_scheduler+0x68>
                c->proc = 0;
    80001afe:	00093023          	sd	zero,0(s2)
    80001b02:	bf75                	j	80001abe <rr_scheduler+0x8a>

0000000080001b04 <proc_mapstacks>:
{
    80001b04:	7139                	addi	sp,sp,-64
    80001b06:	fc06                	sd	ra,56(sp)
    80001b08:	f822                	sd	s0,48(sp)
    80001b0a:	f426                	sd	s1,40(sp)
    80001b0c:	f04a                	sd	s2,32(sp)
    80001b0e:	ec4e                	sd	s3,24(sp)
    80001b10:	e852                	sd	s4,16(sp)
    80001b12:	e456                	sd	s5,8(sp)
    80001b14:	e05a                	sd	s6,0(sp)
    80001b16:	0080                	addi	s0,sp,64
    80001b18:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001b1a:	0002f497          	auipc	s1,0x2f
    80001b1e:	69648493          	addi	s1,s1,1686 # 800311b0 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001b22:	8b26                	mv	s6,s1
    80001b24:	00006a97          	auipc	s5,0x6
    80001b28:	4eca8a93          	addi	s5,s5,1260 # 80008010 <__func__.1+0x8>
    80001b2c:	04000937          	lui	s2,0x4000
    80001b30:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b32:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b34:	00035a17          	auipc	s4,0x35
    80001b38:	07ca0a13          	addi	s4,s4,124 # 80036bb0 <tickslock>
        char *pa = kalloc();
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	156080e7          	jalr	342(ra) # 80000c92 <kalloc>
    80001b44:	862a                	mv	a2,a0
        if (pa == 0)
    80001b46:	c131                	beqz	a0,80001b8a <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001b48:	416485b3          	sub	a1,s1,s6
    80001b4c:	858d                	srai	a1,a1,0x3
    80001b4e:	000ab783          	ld	a5,0(s5)
    80001b52:	02f585b3          	mul	a1,a1,a5
    80001b56:	2585                	addiw	a1,a1,1
    80001b58:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b5c:	4719                	li	a4,6
    80001b5e:	6685                	lui	a3,0x1
    80001b60:	40b905b3          	sub	a1,s2,a1
    80001b64:	854e                	mv	a0,s3
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	7dc080e7          	jalr	2012(ra) # 80001342 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b6e:	16848493          	addi	s1,s1,360
    80001b72:	fd4495e3          	bne	s1,s4,80001b3c <proc_mapstacks+0x38>
}
    80001b76:	70e2                	ld	ra,56(sp)
    80001b78:	7442                	ld	s0,48(sp)
    80001b7a:	74a2                	ld	s1,40(sp)
    80001b7c:	7902                	ld	s2,32(sp)
    80001b7e:	69e2                	ld	s3,24(sp)
    80001b80:	6a42                	ld	s4,16(sp)
    80001b82:	6aa2                	ld	s5,8(sp)
    80001b84:	6b02                	ld	s6,0(sp)
    80001b86:	6121                	addi	sp,sp,64
    80001b88:	8082                	ret
            panic("kalloc");
    80001b8a:	00006517          	auipc	a0,0x6
    80001b8e:	68e50513          	addi	a0,a0,1678 # 80008218 <digits+0x1c8>
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	9ae080e7          	jalr	-1618(ra) # 80000540 <panic>

0000000080001b9a <procinit>:
{
    80001b9a:	7139                	addi	sp,sp,-64
    80001b9c:	fc06                	sd	ra,56(sp)
    80001b9e:	f822                	sd	s0,48(sp)
    80001ba0:	f426                	sd	s1,40(sp)
    80001ba2:	f04a                	sd	s2,32(sp)
    80001ba4:	ec4e                	sd	s3,24(sp)
    80001ba6:	e852                	sd	s4,16(sp)
    80001ba8:	e456                	sd	s5,8(sp)
    80001baa:	e05a                	sd	s6,0(sp)
    80001bac:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001bae:	00006597          	auipc	a1,0x6
    80001bb2:	67258593          	addi	a1,a1,1650 # 80008220 <digits+0x1d0>
    80001bb6:	0002f517          	auipc	a0,0x2f
    80001bba:	5ca50513          	addi	a0,a0,1482 # 80031180 <pid_lock>
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	18c080e7          	jalr	396(ra) # 80000d4a <initlock>
    initlock(&wait_lock, "wait_lock");
    80001bc6:	00006597          	auipc	a1,0x6
    80001bca:	66258593          	addi	a1,a1,1634 # 80008228 <digits+0x1d8>
    80001bce:	0002f517          	auipc	a0,0x2f
    80001bd2:	5ca50513          	addi	a0,a0,1482 # 80031198 <wait_lock>
    80001bd6:	fffff097          	auipc	ra,0xfffff
    80001bda:	174080e7          	jalr	372(ra) # 80000d4a <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001bde:	0002f497          	auipc	s1,0x2f
    80001be2:	5d248493          	addi	s1,s1,1490 # 800311b0 <proc>
        initlock(&p->lock, "proc");
    80001be6:	00006b17          	auipc	s6,0x6
    80001bea:	652b0b13          	addi	s6,s6,1618 # 80008238 <digits+0x1e8>
        p->kstack = KSTACK((int)(p - proc));
    80001bee:	8aa6                	mv	s5,s1
    80001bf0:	00006a17          	auipc	s4,0x6
    80001bf4:	420a0a13          	addi	s4,s4,1056 # 80008010 <__func__.1+0x8>
    80001bf8:	04000937          	lui	s2,0x4000
    80001bfc:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001bfe:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001c00:	00035997          	auipc	s3,0x35
    80001c04:	fb098993          	addi	s3,s3,-80 # 80036bb0 <tickslock>
        initlock(&p->lock, "proc");
    80001c08:	85da                	mv	a1,s6
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	13e080e7          	jalr	318(ra) # 80000d4a <initlock>
        p->state = UNUSED;
    80001c14:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001c18:	415487b3          	sub	a5,s1,s5
    80001c1c:	878d                	srai	a5,a5,0x3
    80001c1e:	000a3703          	ld	a4,0(s4)
    80001c22:	02e787b3          	mul	a5,a5,a4
    80001c26:	2785                	addiw	a5,a5,1
    80001c28:	00d7979b          	slliw	a5,a5,0xd
    80001c2c:	40f907b3          	sub	a5,s2,a5
    80001c30:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001c32:	16848493          	addi	s1,s1,360
    80001c36:	fd3499e3          	bne	s1,s3,80001c08 <procinit+0x6e>
}
    80001c3a:	70e2                	ld	ra,56(sp)
    80001c3c:	7442                	ld	s0,48(sp)
    80001c3e:	74a2                	ld	s1,40(sp)
    80001c40:	7902                	ld	s2,32(sp)
    80001c42:	69e2                	ld	s3,24(sp)
    80001c44:	6a42                	ld	s4,16(sp)
    80001c46:	6aa2                	ld	s5,8(sp)
    80001c48:	6b02                	ld	s6,0(sp)
    80001c4a:	6121                	addi	sp,sp,64
    80001c4c:	8082                	ret

0000000080001c4e <copy_array>:
{
    80001c4e:	1141                	addi	sp,sp,-16
    80001c50:	e422                	sd	s0,8(sp)
    80001c52:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001c54:	02c05163          	blez	a2,80001c76 <copy_array+0x28>
    80001c58:	87aa                	mv	a5,a0
    80001c5a:	0505                	addi	a0,a0,1
    80001c5c:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001c5e:	1602                	slli	a2,a2,0x20
    80001c60:	9201                	srli	a2,a2,0x20
    80001c62:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001c66:	0007c703          	lbu	a4,0(a5)
    80001c6a:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001c6e:	0785                	addi	a5,a5,1
    80001c70:	0585                	addi	a1,a1,1
    80001c72:	fed79ae3          	bne	a5,a3,80001c66 <copy_array+0x18>
}
    80001c76:	6422                	ld	s0,8(sp)
    80001c78:	0141                	addi	sp,sp,16
    80001c7a:	8082                	ret

0000000080001c7c <cpuid>:
{
    80001c7c:	1141                	addi	sp,sp,-16
    80001c7e:	e422                	sd	s0,8(sp)
    80001c80:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c82:	8512                	mv	a0,tp
}
    80001c84:	2501                	sext.w	a0,a0
    80001c86:	6422                	ld	s0,8(sp)
    80001c88:	0141                	addi	sp,sp,16
    80001c8a:	8082                	ret

0000000080001c8c <mycpu>:
{
    80001c8c:	1141                	addi	sp,sp,-16
    80001c8e:	e422                	sd	s0,8(sp)
    80001c90:	0800                	addi	s0,sp,16
    80001c92:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001c94:	2781                	sext.w	a5,a5
    80001c96:	079e                	slli	a5,a5,0x7
}
    80001c98:	0002f517          	auipc	a0,0x2f
    80001c9c:	0e850513          	addi	a0,a0,232 # 80030d80 <cpus>
    80001ca0:	953e                	add	a0,a0,a5
    80001ca2:	6422                	ld	s0,8(sp)
    80001ca4:	0141                	addi	sp,sp,16
    80001ca6:	8082                	ret

0000000080001ca8 <myproc>:
{
    80001ca8:	1101                	addi	sp,sp,-32
    80001caa:	ec06                	sd	ra,24(sp)
    80001cac:	e822                	sd	s0,16(sp)
    80001cae:	e426                	sd	s1,8(sp)
    80001cb0:	1000                	addi	s0,sp,32
    push_off();
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	0dc080e7          	jalr	220(ra) # 80000d8e <push_off>
    80001cba:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001cbc:	2781                	sext.w	a5,a5
    80001cbe:	079e                	slli	a5,a5,0x7
    80001cc0:	0002f717          	auipc	a4,0x2f
    80001cc4:	0c070713          	addi	a4,a4,192 # 80030d80 <cpus>
    80001cc8:	97ba                	add	a5,a5,a4
    80001cca:	6384                	ld	s1,0(a5)
    pop_off();
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	162080e7          	jalr	354(ra) # 80000e2e <pop_off>
}
    80001cd4:	8526                	mv	a0,s1
    80001cd6:	60e2                	ld	ra,24(sp)
    80001cd8:	6442                	ld	s0,16(sp)
    80001cda:	64a2                	ld	s1,8(sp)
    80001cdc:	6105                	addi	sp,sp,32
    80001cde:	8082                	ret

0000000080001ce0 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001ce0:	1141                	addi	sp,sp,-16
    80001ce2:	e406                	sd	ra,8(sp)
    80001ce4:	e022                	sd	s0,0(sp)
    80001ce6:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001ce8:	00000097          	auipc	ra,0x0
    80001cec:	fc0080e7          	jalr	-64(ra) # 80001ca8 <myproc>
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	19e080e7          	jalr	414(ra) # 80000e8e <release>

    if (first)
    80001cf8:	00007797          	auipc	a5,0x7
    80001cfc:	d387a783          	lw	a5,-712(a5) # 80008a30 <first.1>
    80001d00:	eb89                	bnez	a5,80001d12 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001d02:	00001097          	auipc	ra,0x1
    80001d06:	eac080e7          	jalr	-340(ra) # 80002bae <usertrapret>
}
    80001d0a:	60a2                	ld	ra,8(sp)
    80001d0c:	6402                	ld	s0,0(sp)
    80001d0e:	0141                	addi	sp,sp,16
    80001d10:	8082                	ret
        first = 0;
    80001d12:	00007797          	auipc	a5,0x7
    80001d16:	d007af23          	sw	zero,-738(a5) # 80008a30 <first.1>
        fsinit(ROOTDEV);
    80001d1a:	4505                	li	a0,1
    80001d1c:	00002097          	auipc	ra,0x2
    80001d20:	e38080e7          	jalr	-456(ra) # 80003b54 <fsinit>
    80001d24:	bff9                	j	80001d02 <forkret+0x22>

0000000080001d26 <allocpid>:
{
    80001d26:	1101                	addi	sp,sp,-32
    80001d28:	ec06                	sd	ra,24(sp)
    80001d2a:	e822                	sd	s0,16(sp)
    80001d2c:	e426                	sd	s1,8(sp)
    80001d2e:	e04a                	sd	s2,0(sp)
    80001d30:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001d32:	0002f917          	auipc	s2,0x2f
    80001d36:	44e90913          	addi	s2,s2,1102 # 80031180 <pid_lock>
    80001d3a:	854a                	mv	a0,s2
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	09e080e7          	jalr	158(ra) # 80000dda <acquire>
    pid = nextpid;
    80001d44:	00007797          	auipc	a5,0x7
    80001d48:	cfc78793          	addi	a5,a5,-772 # 80008a40 <nextpid>
    80001d4c:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001d4e:	0014871b          	addiw	a4,s1,1
    80001d52:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001d54:	854a                	mv	a0,s2
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	138080e7          	jalr	312(ra) # 80000e8e <release>
}
    80001d5e:	8526                	mv	a0,s1
    80001d60:	60e2                	ld	ra,24(sp)
    80001d62:	6442                	ld	s0,16(sp)
    80001d64:	64a2                	ld	s1,8(sp)
    80001d66:	6902                	ld	s2,0(sp)
    80001d68:	6105                	addi	sp,sp,32
    80001d6a:	8082                	ret

0000000080001d6c <proc_pagetable>:
{
    80001d6c:	1101                	addi	sp,sp,-32
    80001d6e:	ec06                	sd	ra,24(sp)
    80001d70:	e822                	sd	s0,16(sp)
    80001d72:	e426                	sd	s1,8(sp)
    80001d74:	e04a                	sd	s2,0(sp)
    80001d76:	1000                	addi	s0,sp,32
    80001d78:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	7b2080e7          	jalr	1970(ra) # 8000152c <uvmcreate>
    80001d82:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001d84:	c121                	beqz	a0,80001dc4 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d86:	4729                	li	a4,10
    80001d88:	00005697          	auipc	a3,0x5
    80001d8c:	27868693          	addi	a3,a3,632 # 80007000 <_trampoline>
    80001d90:	6605                	lui	a2,0x1
    80001d92:	040005b7          	lui	a1,0x4000
    80001d96:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d98:	05b2                	slli	a1,a1,0xc
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	508080e7          	jalr	1288(ra) # 800012a2 <mappages>
    80001da2:	02054863          	bltz	a0,80001dd2 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001da6:	4719                	li	a4,6
    80001da8:	05893683          	ld	a3,88(s2)
    80001dac:	6605                	lui	a2,0x1
    80001dae:	020005b7          	lui	a1,0x2000
    80001db2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001db4:	05b6                	slli	a1,a1,0xd
    80001db6:	8526                	mv	a0,s1
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	4ea080e7          	jalr	1258(ra) # 800012a2 <mappages>
    80001dc0:	02054163          	bltz	a0,80001de2 <proc_pagetable+0x76>
}
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	60e2                	ld	ra,24(sp)
    80001dc8:	6442                	ld	s0,16(sp)
    80001dca:	64a2                	ld	s1,8(sp)
    80001dcc:	6902                	ld	s2,0(sp)
    80001dce:	6105                	addi	sp,sp,32
    80001dd0:	8082                	ret
        uvmfree(pagetable, 0);
    80001dd2:	4581                	li	a1,0
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	00000097          	auipc	ra,0x0
    80001dda:	95c080e7          	jalr	-1700(ra) # 80001732 <uvmfree>
        return 0;
    80001dde:	4481                	li	s1,0
    80001de0:	b7d5                	j	80001dc4 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001de2:	4681                	li	a3,0
    80001de4:	4605                	li	a2,1
    80001de6:	040005b7          	lui	a1,0x4000
    80001dea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dec:	05b2                	slli	a1,a1,0xc
    80001dee:	8526                	mv	a0,s1
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	678080e7          	jalr	1656(ra) # 80001468 <uvmunmap>
        uvmfree(pagetable, 0);
    80001df8:	4581                	li	a1,0
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	00000097          	auipc	ra,0x0
    80001e00:	936080e7          	jalr	-1738(ra) # 80001732 <uvmfree>
        return 0;
    80001e04:	4481                	li	s1,0
    80001e06:	bf7d                	j	80001dc4 <proc_pagetable+0x58>

0000000080001e08 <proc_freepagetable>:
{
    80001e08:	1101                	addi	sp,sp,-32
    80001e0a:	ec06                	sd	ra,24(sp)
    80001e0c:	e822                	sd	s0,16(sp)
    80001e0e:	e426                	sd	s1,8(sp)
    80001e10:	e04a                	sd	s2,0(sp)
    80001e12:	1000                	addi	s0,sp,32
    80001e14:	84aa                	mv	s1,a0
    80001e16:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e18:	4681                	li	a3,0
    80001e1a:	4605                	li	a2,1
    80001e1c:	040005b7          	lui	a1,0x4000
    80001e20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e22:	05b2                	slli	a1,a1,0xc
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	644080e7          	jalr	1604(ra) # 80001468 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e2c:	4681                	li	a3,0
    80001e2e:	4605                	li	a2,1
    80001e30:	020005b7          	lui	a1,0x2000
    80001e34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e36:	05b6                	slli	a1,a1,0xd
    80001e38:	8526                	mv	a0,s1
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	62e080e7          	jalr	1582(ra) # 80001468 <uvmunmap>
    uvmfree(pagetable, sz);
    80001e42:	85ca                	mv	a1,s2
    80001e44:	8526                	mv	a0,s1
    80001e46:	00000097          	auipc	ra,0x0
    80001e4a:	8ec080e7          	jalr	-1812(ra) # 80001732 <uvmfree>
}
    80001e4e:	60e2                	ld	ra,24(sp)
    80001e50:	6442                	ld	s0,16(sp)
    80001e52:	64a2                	ld	s1,8(sp)
    80001e54:	6902                	ld	s2,0(sp)
    80001e56:	6105                	addi	sp,sp,32
    80001e58:	8082                	ret

0000000080001e5a <freeproc>:
{
    80001e5a:	1101                	addi	sp,sp,-32
    80001e5c:	ec06                	sd	ra,24(sp)
    80001e5e:	e822                	sd	s0,16(sp)
    80001e60:	e426                	sd	s1,8(sp)
    80001e62:	1000                	addi	s0,sp,32
    80001e64:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001e66:	6d28                	ld	a0,88(a0)
    80001e68:	c509                	beqz	a0,80001e72 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	ce8080e7          	jalr	-792(ra) # 80000b52 <kfree>
    p->trapframe = 0;
    80001e72:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001e76:	68a8                	ld	a0,80(s1)
    80001e78:	c511                	beqz	a0,80001e84 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001e7a:	64ac                	ld	a1,72(s1)
    80001e7c:	00000097          	auipc	ra,0x0
    80001e80:	f8c080e7          	jalr	-116(ra) # 80001e08 <proc_freepagetable>
    p->pagetable = 0;
    80001e84:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001e88:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001e8c:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001e90:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001e94:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001e98:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001e9c:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001ea0:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001ea4:	0004ac23          	sw	zero,24(s1)
}
    80001ea8:	60e2                	ld	ra,24(sp)
    80001eaa:	6442                	ld	s0,16(sp)
    80001eac:	64a2                	ld	s1,8(sp)
    80001eae:	6105                	addi	sp,sp,32
    80001eb0:	8082                	ret

0000000080001eb2 <allocproc>:
{
    80001eb2:	1101                	addi	sp,sp,-32
    80001eb4:	ec06                	sd	ra,24(sp)
    80001eb6:	e822                	sd	s0,16(sp)
    80001eb8:	e426                	sd	s1,8(sp)
    80001eba:	e04a                	sd	s2,0(sp)
    80001ebc:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001ebe:	0002f497          	auipc	s1,0x2f
    80001ec2:	2f248493          	addi	s1,s1,754 # 800311b0 <proc>
    80001ec6:	00035917          	auipc	s2,0x35
    80001eca:	cea90913          	addi	s2,s2,-790 # 80036bb0 <tickslock>
        acquire(&p->lock);
    80001ece:	8526                	mv	a0,s1
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	f0a080e7          	jalr	-246(ra) # 80000dda <acquire>
        if (p->state == UNUSED)
    80001ed8:	4c9c                	lw	a5,24(s1)
    80001eda:	cf81                	beqz	a5,80001ef2 <allocproc+0x40>
            release(&p->lock);
    80001edc:	8526                	mv	a0,s1
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	fb0080e7          	jalr	-80(ra) # 80000e8e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001ee6:	16848493          	addi	s1,s1,360
    80001eea:	ff2492e3          	bne	s1,s2,80001ece <allocproc+0x1c>
    return 0;
    80001eee:	4481                	li	s1,0
    80001ef0:	a889                	j	80001f42 <allocproc+0x90>
    p->pid = allocpid();
    80001ef2:	00000097          	auipc	ra,0x0
    80001ef6:	e34080e7          	jalr	-460(ra) # 80001d26 <allocpid>
    80001efa:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001efc:	4785                	li	a5,1
    80001efe:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	d92080e7          	jalr	-622(ra) # 80000c92 <kalloc>
    80001f08:	892a                	mv	s2,a0
    80001f0a:	eca8                	sd	a0,88(s1)
    80001f0c:	c131                	beqz	a0,80001f50 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	00000097          	auipc	ra,0x0
    80001f14:	e5c080e7          	jalr	-420(ra) # 80001d6c <proc_pagetable>
    80001f18:	892a                	mv	s2,a0
    80001f1a:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001f1c:	c531                	beqz	a0,80001f68 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001f1e:	07000613          	li	a2,112
    80001f22:	4581                	li	a1,0
    80001f24:	06048513          	addi	a0,s1,96
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	fae080e7          	jalr	-82(ra) # 80000ed6 <memset>
    p->context.ra = (uint64)forkret;
    80001f30:	00000797          	auipc	a5,0x0
    80001f34:	db078793          	addi	a5,a5,-592 # 80001ce0 <forkret>
    80001f38:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001f3a:	60bc                	ld	a5,64(s1)
    80001f3c:	6705                	lui	a4,0x1
    80001f3e:	97ba                	add	a5,a5,a4
    80001f40:	f4bc                	sd	a5,104(s1)
}
    80001f42:	8526                	mv	a0,s1
    80001f44:	60e2                	ld	ra,24(sp)
    80001f46:	6442                	ld	s0,16(sp)
    80001f48:	64a2                	ld	s1,8(sp)
    80001f4a:	6902                	ld	s2,0(sp)
    80001f4c:	6105                	addi	sp,sp,32
    80001f4e:	8082                	ret
        freeproc(p);
    80001f50:	8526                	mv	a0,s1
    80001f52:	00000097          	auipc	ra,0x0
    80001f56:	f08080e7          	jalr	-248(ra) # 80001e5a <freeproc>
        release(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	f32080e7          	jalr	-206(ra) # 80000e8e <release>
        return 0;
    80001f64:	84ca                	mv	s1,s2
    80001f66:	bff1                	j	80001f42 <allocproc+0x90>
        freeproc(p);
    80001f68:	8526                	mv	a0,s1
    80001f6a:	00000097          	auipc	ra,0x0
    80001f6e:	ef0080e7          	jalr	-272(ra) # 80001e5a <freeproc>
        release(&p->lock);
    80001f72:	8526                	mv	a0,s1
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	f1a080e7          	jalr	-230(ra) # 80000e8e <release>
        return 0;
    80001f7c:	84ca                	mv	s1,s2
    80001f7e:	b7d1                	j	80001f42 <allocproc+0x90>

0000000080001f80 <userinit>:
{
    80001f80:	1101                	addi	sp,sp,-32
    80001f82:	ec06                	sd	ra,24(sp)
    80001f84:	e822                	sd	s0,16(sp)
    80001f86:	e426                	sd	s1,8(sp)
    80001f88:	1000                	addi	s0,sp,32
    p = allocproc();
    80001f8a:	00000097          	auipc	ra,0x0
    80001f8e:	f28080e7          	jalr	-216(ra) # 80001eb2 <allocproc>
    80001f92:	84aa                	mv	s1,a0
    initproc = p;
    80001f94:	00007797          	auipc	a5,0x7
    80001f98:	b6a7ba23          	sd	a0,-1164(a5) # 80008b08 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f9c:	03400613          	li	a2,52
    80001fa0:	00007597          	auipc	a1,0x7
    80001fa4:	ab058593          	addi	a1,a1,-1360 # 80008a50 <initcode>
    80001fa8:	6928                	ld	a0,80(a0)
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	5b0080e7          	jalr	1456(ra) # 8000155a <uvmfirst>
    p->sz = PGSIZE;
    80001fb2:	6785                	lui	a5,0x1
    80001fb4:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001fb6:	6cb8                	ld	a4,88(s1)
    80001fb8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001fbc:	6cb8                	ld	a4,88(s1)
    80001fbe:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001fc0:	4641                	li	a2,16
    80001fc2:	00006597          	auipc	a1,0x6
    80001fc6:	27e58593          	addi	a1,a1,638 # 80008240 <digits+0x1f0>
    80001fca:	15848513          	addi	a0,s1,344
    80001fce:	fffff097          	auipc	ra,0xfffff
    80001fd2:	052080e7          	jalr	82(ra) # 80001020 <safestrcpy>
    p->cwd = namei("/");
    80001fd6:	00006517          	auipc	a0,0x6
    80001fda:	27a50513          	addi	a0,a0,634 # 80008250 <digits+0x200>
    80001fde:	00002097          	auipc	ra,0x2
    80001fe2:	5a0080e7          	jalr	1440(ra) # 8000457e <namei>
    80001fe6:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001fea:	478d                	li	a5,3
    80001fec:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001fee:	8526                	mv	a0,s1
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	e9e080e7          	jalr	-354(ra) # 80000e8e <release>
}
    80001ff8:	60e2                	ld	ra,24(sp)
    80001ffa:	6442                	ld	s0,16(sp)
    80001ffc:	64a2                	ld	s1,8(sp)
    80001ffe:	6105                	addi	sp,sp,32
    80002000:	8082                	ret

0000000080002002 <growproc>:
{
    80002002:	1101                	addi	sp,sp,-32
    80002004:	ec06                	sd	ra,24(sp)
    80002006:	e822                	sd	s0,16(sp)
    80002008:	e426                	sd	s1,8(sp)
    8000200a:	e04a                	sd	s2,0(sp)
    8000200c:	1000                	addi	s0,sp,32
    8000200e:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80002010:	00000097          	auipc	ra,0x0
    80002014:	c98080e7          	jalr	-872(ra) # 80001ca8 <myproc>
    80002018:	84aa                	mv	s1,a0
    sz = p->sz;
    8000201a:	652c                	ld	a1,72(a0)
    if (n > 0)
    8000201c:	01204c63          	bgtz	s2,80002034 <growproc+0x32>
    else if (n < 0)
    80002020:	02094663          	bltz	s2,8000204c <growproc+0x4a>
    p->sz = sz;
    80002024:	e4ac                	sd	a1,72(s1)
    return 0;
    80002026:	4501                	li	a0,0
}
    80002028:	60e2                	ld	ra,24(sp)
    8000202a:	6442                	ld	s0,16(sp)
    8000202c:	64a2                	ld	s1,8(sp)
    8000202e:	6902                	ld	s2,0(sp)
    80002030:	6105                	addi	sp,sp,32
    80002032:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80002034:	4691                	li	a3,4
    80002036:	00b90633          	add	a2,s2,a1
    8000203a:	6928                	ld	a0,80(a0)
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	5d8080e7          	jalr	1496(ra) # 80001614 <uvmalloc>
    80002044:	85aa                	mv	a1,a0
    80002046:	fd79                	bnez	a0,80002024 <growproc+0x22>
            return -1;
    80002048:	557d                	li	a0,-1
    8000204a:	bff9                	j	80002028 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000204c:	00b90633          	add	a2,s2,a1
    80002050:	6928                	ld	a0,80(a0)
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	57a080e7          	jalr	1402(ra) # 800015cc <uvmdealloc>
    8000205a:	85aa                	mv	a1,a0
    8000205c:	b7e1                	j	80002024 <growproc+0x22>

000000008000205e <ps>:
{
    8000205e:	715d                	addi	sp,sp,-80
    80002060:	e486                	sd	ra,72(sp)
    80002062:	e0a2                	sd	s0,64(sp)
    80002064:	fc26                	sd	s1,56(sp)
    80002066:	f84a                	sd	s2,48(sp)
    80002068:	f44e                	sd	s3,40(sp)
    8000206a:	f052                	sd	s4,32(sp)
    8000206c:	ec56                	sd	s5,24(sp)
    8000206e:	e85a                	sd	s6,16(sp)
    80002070:	e45e                	sd	s7,8(sp)
    80002072:	e062                	sd	s8,0(sp)
    80002074:	0880                	addi	s0,sp,80
    80002076:	84aa                	mv	s1,a0
    80002078:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    8000207a:	00000097          	auipc	ra,0x0
    8000207e:	c2e080e7          	jalr	-978(ra) # 80001ca8 <myproc>
        return result;
    80002082:	4901                	li	s2,0
    if (count == 0)
    80002084:	0c0b8563          	beqz	s7,8000214e <ps+0xf0>
    void *result = (void *)myproc()->sz;
    80002088:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    8000208c:	003b951b          	slliw	a0,s7,0x3
    80002090:	0175053b          	addw	a0,a0,s7
    80002094:	0025151b          	slliw	a0,a0,0x2
    80002098:	00000097          	auipc	ra,0x0
    8000209c:	f6a080e7          	jalr	-150(ra) # 80002002 <growproc>
    800020a0:	12054f63          	bltz	a0,800021de <ps+0x180>
    struct user_proc loc_result[count];
    800020a4:	003b9a13          	slli	s4,s7,0x3
    800020a8:	9a5e                	add	s4,s4,s7
    800020aa:	0a0a                	slli	s4,s4,0x2
    800020ac:	00fa0793          	addi	a5,s4,15
    800020b0:	8391                	srli	a5,a5,0x4
    800020b2:	0792                	slli	a5,a5,0x4
    800020b4:	40f10133          	sub	sp,sp,a5
    800020b8:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    800020ba:	16800793          	li	a5,360
    800020be:	02f484b3          	mul	s1,s1,a5
    800020c2:	0002f797          	auipc	a5,0x2f
    800020c6:	0ee78793          	addi	a5,a5,238 # 800311b0 <proc>
    800020ca:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    800020cc:	00035797          	auipc	a5,0x35
    800020d0:	ae478793          	addi	a5,a5,-1308 # 80036bb0 <tickslock>
        return result;
    800020d4:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    800020d6:	06f4fc63          	bgeu	s1,a5,8000214e <ps+0xf0>
    acquire(&wait_lock);
    800020da:	0002f517          	auipc	a0,0x2f
    800020de:	0be50513          	addi	a0,a0,190 # 80031198 <wait_lock>
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	cf8080e7          	jalr	-776(ra) # 80000dda <acquire>
        if (localCount == count)
    800020ea:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    800020ee:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    800020f0:	00035c17          	auipc	s8,0x35
    800020f4:	ac0c0c13          	addi	s8,s8,-1344 # 80036bb0 <tickslock>
    800020f8:	a851                	j	8000218c <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    800020fa:	00399793          	slli	a5,s3,0x3
    800020fe:	97ce                	add	a5,a5,s3
    80002100:	078a                	slli	a5,a5,0x2
    80002102:	97d6                	add	a5,a5,s5
    80002104:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	d84080e7          	jalr	-636(ra) # 80000e8e <release>
    release(&wait_lock);
    80002112:	0002f517          	auipc	a0,0x2f
    80002116:	08650513          	addi	a0,a0,134 # 80031198 <wait_lock>
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	d74080e7          	jalr	-652(ra) # 80000e8e <release>
    if (localCount < count)
    80002122:	0179f963          	bgeu	s3,s7,80002134 <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80002126:	00399793          	slli	a5,s3,0x3
    8000212a:	97ce                	add	a5,a5,s3
    8000212c:	078a                	slli	a5,a5,0x2
    8000212e:	97d6                	add	a5,a5,s5
    80002130:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80002134:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	b72080e7          	jalr	-1166(ra) # 80001ca8 <myproc>
    8000213e:	86d2                	mv	a3,s4
    80002140:	8656                	mv	a2,s5
    80002142:	85da                	mv	a1,s6
    80002144:	6928                	ld	a0,80(a0)
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	724080e7          	jalr	1828(ra) # 8000186a <copyout>
}
    8000214e:	854a                	mv	a0,s2
    80002150:	fb040113          	addi	sp,s0,-80
    80002154:	60a6                	ld	ra,72(sp)
    80002156:	6406                	ld	s0,64(sp)
    80002158:	74e2                	ld	s1,56(sp)
    8000215a:	7942                	ld	s2,48(sp)
    8000215c:	79a2                	ld	s3,40(sp)
    8000215e:	7a02                	ld	s4,32(sp)
    80002160:	6ae2                	ld	s5,24(sp)
    80002162:	6b42                	ld	s6,16(sp)
    80002164:	6ba2                	ld	s7,8(sp)
    80002166:	6c02                	ld	s8,0(sp)
    80002168:	6161                	addi	sp,sp,80
    8000216a:	8082                	ret
        release(&p->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	d20080e7          	jalr	-736(ra) # 80000e8e <release>
        localCount++;
    80002176:	2985                	addiw	s3,s3,1
    80002178:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    8000217c:	16848493          	addi	s1,s1,360
    80002180:	f984f9e3          	bgeu	s1,s8,80002112 <ps+0xb4>
        if (localCount == count)
    80002184:	02490913          	addi	s2,s2,36
    80002188:	053b8d63          	beq	s7,s3,800021e2 <ps+0x184>
        acquire(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	c4c080e7          	jalr	-948(ra) # 80000dda <acquire>
        if (p->state == UNUSED)
    80002196:	4c9c                	lw	a5,24(s1)
    80002198:	d3ad                	beqz	a5,800020fa <ps+0x9c>
        loc_result[localCount].state = p->state;
    8000219a:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    8000219e:	549c                	lw	a5,40(s1)
    800021a0:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800021a4:	54dc                	lw	a5,44(s1)
    800021a6:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800021aa:	589c                	lw	a5,48(s1)
    800021ac:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800021b0:	4641                	li	a2,16
    800021b2:	85ca                	mv	a1,s2
    800021b4:	15848513          	addi	a0,s1,344
    800021b8:	00000097          	auipc	ra,0x0
    800021bc:	a96080e7          	jalr	-1386(ra) # 80001c4e <copy_array>
        if (p->parent != 0) // init
    800021c0:	7c88                	ld	a0,56(s1)
    800021c2:	d54d                	beqz	a0,8000216c <ps+0x10e>
            acquire(&p->parent->lock);
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	c16080e7          	jalr	-1002(ra) # 80000dda <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    800021cc:	7c88                	ld	a0,56(s1)
    800021ce:	591c                	lw	a5,48(a0)
    800021d0:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	cba080e7          	jalr	-838(ra) # 80000e8e <release>
    800021dc:	bf41                	j	8000216c <ps+0x10e>
        return result;
    800021de:	4901                	li	s2,0
    800021e0:	b7bd                	j	8000214e <ps+0xf0>
    release(&wait_lock);
    800021e2:	0002f517          	auipc	a0,0x2f
    800021e6:	fb650513          	addi	a0,a0,-74 # 80031198 <wait_lock>
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	ca4080e7          	jalr	-860(ra) # 80000e8e <release>
    if (localCount < count)
    800021f2:	b789                	j	80002134 <ps+0xd6>

00000000800021f4 <fork>:
{
    800021f4:	7139                	addi	sp,sp,-64
    800021f6:	fc06                	sd	ra,56(sp)
    800021f8:	f822                	sd	s0,48(sp)
    800021fa:	f426                	sd	s1,40(sp)
    800021fc:	f04a                	sd	s2,32(sp)
    800021fe:	ec4e                	sd	s3,24(sp)
    80002200:	e852                	sd	s4,16(sp)
    80002202:	e456                	sd	s5,8(sp)
    80002204:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002206:	00000097          	auipc	ra,0x0
    8000220a:	aa2080e7          	jalr	-1374(ra) # 80001ca8 <myproc>
    8000220e:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002210:	00000097          	auipc	ra,0x0
    80002214:	ca2080e7          	jalr	-862(ra) # 80001eb2 <allocproc>
    80002218:	10050c63          	beqz	a0,80002330 <fork+0x13c>
    8000221c:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000221e:	048ab603          	ld	a2,72(s5)
    80002222:	692c                	ld	a1,80(a0)
    80002224:	050ab503          	ld	a0,80(s5)
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	544080e7          	jalr	1348(ra) # 8000176c <uvmcopy>
    80002230:	04054863          	bltz	a0,80002280 <fork+0x8c>
    np->sz = p->sz;
    80002234:	048ab783          	ld	a5,72(s5)
    80002238:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    8000223c:	058ab683          	ld	a3,88(s5)
    80002240:	87b6                	mv	a5,a3
    80002242:	058a3703          	ld	a4,88(s4)
    80002246:	12068693          	addi	a3,a3,288
    8000224a:	0007b803          	ld	a6,0(a5)
    8000224e:	6788                	ld	a0,8(a5)
    80002250:	6b8c                	ld	a1,16(a5)
    80002252:	6f90                	ld	a2,24(a5)
    80002254:	01073023          	sd	a6,0(a4)
    80002258:	e708                	sd	a0,8(a4)
    8000225a:	eb0c                	sd	a1,16(a4)
    8000225c:	ef10                	sd	a2,24(a4)
    8000225e:	02078793          	addi	a5,a5,32
    80002262:	02070713          	addi	a4,a4,32
    80002266:	fed792e3          	bne	a5,a3,8000224a <fork+0x56>
    np->trapframe->a0 = 0;
    8000226a:	058a3783          	ld	a5,88(s4)
    8000226e:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    80002272:	0d0a8493          	addi	s1,s5,208
    80002276:	0d0a0913          	addi	s2,s4,208
    8000227a:	150a8993          	addi	s3,s5,336
    8000227e:	a00d                	j	800022a0 <fork+0xac>
        freeproc(np);
    80002280:	8552                	mv	a0,s4
    80002282:	00000097          	auipc	ra,0x0
    80002286:	bd8080e7          	jalr	-1064(ra) # 80001e5a <freeproc>
        release(&np->lock);
    8000228a:	8552                	mv	a0,s4
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	c02080e7          	jalr	-1022(ra) # 80000e8e <release>
        return -1;
    80002294:	597d                	li	s2,-1
    80002296:	a059                	j	8000231c <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    80002298:	04a1                	addi	s1,s1,8
    8000229a:	0921                	addi	s2,s2,8
    8000229c:	01348b63          	beq	s1,s3,800022b2 <fork+0xbe>
        if (p->ofile[i])
    800022a0:	6088                	ld	a0,0(s1)
    800022a2:	d97d                	beqz	a0,80002298 <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    800022a4:	00003097          	auipc	ra,0x3
    800022a8:	970080e7          	jalr	-1680(ra) # 80004c14 <filedup>
    800022ac:	00a93023          	sd	a0,0(s2)
    800022b0:	b7e5                	j	80002298 <fork+0xa4>
    np->cwd = idup(p->cwd);
    800022b2:	150ab503          	ld	a0,336(s5)
    800022b6:	00002097          	auipc	ra,0x2
    800022ba:	ade080e7          	jalr	-1314(ra) # 80003d94 <idup>
    800022be:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    800022c2:	4641                	li	a2,16
    800022c4:	158a8593          	addi	a1,s5,344
    800022c8:	158a0513          	addi	a0,s4,344
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	d54080e7          	jalr	-684(ra) # 80001020 <safestrcpy>
    pid = np->pid;
    800022d4:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800022d8:	8552                	mv	a0,s4
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	bb4080e7          	jalr	-1100(ra) # 80000e8e <release>
    acquire(&wait_lock);
    800022e2:	0002f497          	auipc	s1,0x2f
    800022e6:	eb648493          	addi	s1,s1,-330 # 80031198 <wait_lock>
    800022ea:	8526                	mv	a0,s1
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	aee080e7          	jalr	-1298(ra) # 80000dda <acquire>
    np->parent = p;
    800022f4:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	b94080e7          	jalr	-1132(ra) # 80000e8e <release>
    acquire(&np->lock);
    80002302:	8552                	mv	a0,s4
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	ad6080e7          	jalr	-1322(ra) # 80000dda <acquire>
    np->state = RUNNABLE;
    8000230c:	478d                	li	a5,3
    8000230e:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002312:	8552                	mv	a0,s4
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	b7a080e7          	jalr	-1158(ra) # 80000e8e <release>
}
    8000231c:	854a                	mv	a0,s2
    8000231e:	70e2                	ld	ra,56(sp)
    80002320:	7442                	ld	s0,48(sp)
    80002322:	74a2                	ld	s1,40(sp)
    80002324:	7902                	ld	s2,32(sp)
    80002326:	69e2                	ld	s3,24(sp)
    80002328:	6a42                	ld	s4,16(sp)
    8000232a:	6aa2                	ld	s5,8(sp)
    8000232c:	6121                	addi	sp,sp,64
    8000232e:	8082                	ret
        return -1;
    80002330:	597d                	li	s2,-1
    80002332:	b7ed                	j	8000231c <fork+0x128>

0000000080002334 <scheduler>:
{
    80002334:	1101                	addi	sp,sp,-32
    80002336:	ec06                	sd	ra,24(sp)
    80002338:	e822                	sd	s0,16(sp)
    8000233a:	e426                	sd	s1,8(sp)
    8000233c:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    8000233e:	00006497          	auipc	s1,0x6
    80002342:	6fa48493          	addi	s1,s1,1786 # 80008a38 <sched_pointer>
    80002346:	609c                	ld	a5,0(s1)
    80002348:	9782                	jalr	a5
    while (1)
    8000234a:	bff5                	j	80002346 <scheduler+0x12>

000000008000234c <sched>:
{
    8000234c:	7179                	addi	sp,sp,-48
    8000234e:	f406                	sd	ra,40(sp)
    80002350:	f022                	sd	s0,32(sp)
    80002352:	ec26                	sd	s1,24(sp)
    80002354:	e84a                	sd	s2,16(sp)
    80002356:	e44e                	sd	s3,8(sp)
    80002358:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    8000235a:	00000097          	auipc	ra,0x0
    8000235e:	94e080e7          	jalr	-1714(ra) # 80001ca8 <myproc>
    80002362:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	9fc080e7          	jalr	-1540(ra) # 80000d60 <holding>
    8000236c:	c53d                	beqz	a0,800023da <sched+0x8e>
    8000236e:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002370:	2781                	sext.w	a5,a5
    80002372:	079e                	slli	a5,a5,0x7
    80002374:	0002f717          	auipc	a4,0x2f
    80002378:	a0c70713          	addi	a4,a4,-1524 # 80030d80 <cpus>
    8000237c:	97ba                	add	a5,a5,a4
    8000237e:	5fb8                	lw	a4,120(a5)
    80002380:	4785                	li	a5,1
    80002382:	06f71463          	bne	a4,a5,800023ea <sched+0x9e>
    if (p->state == RUNNING)
    80002386:	4c98                	lw	a4,24(s1)
    80002388:	4791                	li	a5,4
    8000238a:	06f70863          	beq	a4,a5,800023fa <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000238e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002392:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002394:	ebbd                	bnez	a5,8000240a <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002396:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    80002398:	0002f917          	auipc	s2,0x2f
    8000239c:	9e890913          	addi	s2,s2,-1560 # 80030d80 <cpus>
    800023a0:	2781                	sext.w	a5,a5
    800023a2:	079e                	slli	a5,a5,0x7
    800023a4:	97ca                	add	a5,a5,s2
    800023a6:	07c7a983          	lw	s3,124(a5)
    800023aa:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800023ac:	2581                	sext.w	a1,a1
    800023ae:	059e                	slli	a1,a1,0x7
    800023b0:	05a1                	addi	a1,a1,8
    800023b2:	95ca                	add	a1,a1,s2
    800023b4:	06048513          	addi	a0,s1,96
    800023b8:	00000097          	auipc	ra,0x0
    800023bc:	74c080e7          	jalr	1868(ra) # 80002b04 <swtch>
    800023c0:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    800023c2:	2781                	sext.w	a5,a5
    800023c4:	079e                	slli	a5,a5,0x7
    800023c6:	993e                	add	s2,s2,a5
    800023c8:	07392e23          	sw	s3,124(s2)
}
    800023cc:	70a2                	ld	ra,40(sp)
    800023ce:	7402                	ld	s0,32(sp)
    800023d0:	64e2                	ld	s1,24(sp)
    800023d2:	6942                	ld	s2,16(sp)
    800023d4:	69a2                	ld	s3,8(sp)
    800023d6:	6145                	addi	sp,sp,48
    800023d8:	8082                	ret
        panic("sched p->lock");
    800023da:	00006517          	auipc	a0,0x6
    800023de:	e7e50513          	addi	a0,a0,-386 # 80008258 <digits+0x208>
    800023e2:	ffffe097          	auipc	ra,0xffffe
    800023e6:	15e080e7          	jalr	350(ra) # 80000540 <panic>
        panic("sched locks");
    800023ea:	00006517          	auipc	a0,0x6
    800023ee:	e7e50513          	addi	a0,a0,-386 # 80008268 <digits+0x218>
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	14e080e7          	jalr	334(ra) # 80000540 <panic>
        panic("sched running");
    800023fa:	00006517          	auipc	a0,0x6
    800023fe:	e7e50513          	addi	a0,a0,-386 # 80008278 <digits+0x228>
    80002402:	ffffe097          	auipc	ra,0xffffe
    80002406:	13e080e7          	jalr	318(ra) # 80000540 <panic>
        panic("sched interruptible");
    8000240a:	00006517          	auipc	a0,0x6
    8000240e:	e7e50513          	addi	a0,a0,-386 # 80008288 <digits+0x238>
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	12e080e7          	jalr	302(ra) # 80000540 <panic>

000000008000241a <yield>:
{
    8000241a:	1101                	addi	sp,sp,-32
    8000241c:	ec06                	sd	ra,24(sp)
    8000241e:	e822                	sd	s0,16(sp)
    80002420:	e426                	sd	s1,8(sp)
    80002422:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002424:	00000097          	auipc	ra,0x0
    80002428:	884080e7          	jalr	-1916(ra) # 80001ca8 <myproc>
    8000242c:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	9ac080e7          	jalr	-1620(ra) # 80000dda <acquire>
    p->state = RUNNABLE;
    80002436:	478d                	li	a5,3
    80002438:	cc9c                	sw	a5,24(s1)
    sched();
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	f12080e7          	jalr	-238(ra) # 8000234c <sched>
    release(&p->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	a4a080e7          	jalr	-1462(ra) # 80000e8e <release>
}
    8000244c:	60e2                	ld	ra,24(sp)
    8000244e:	6442                	ld	s0,16(sp)
    80002450:	64a2                	ld	s1,8(sp)
    80002452:	6105                	addi	sp,sp,32
    80002454:	8082                	ret

0000000080002456 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002456:	7179                	addi	sp,sp,-48
    80002458:	f406                	sd	ra,40(sp)
    8000245a:	f022                	sd	s0,32(sp)
    8000245c:	ec26                	sd	s1,24(sp)
    8000245e:	e84a                	sd	s2,16(sp)
    80002460:	e44e                	sd	s3,8(sp)
    80002462:	1800                	addi	s0,sp,48
    80002464:	89aa                	mv	s3,a0
    80002466:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002468:	00000097          	auipc	ra,0x0
    8000246c:	840080e7          	jalr	-1984(ra) # 80001ca8 <myproc>
    80002470:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	968080e7          	jalr	-1688(ra) # 80000dda <acquire>
    release(lk);
    8000247a:	854a                	mv	a0,s2
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	a12080e7          	jalr	-1518(ra) # 80000e8e <release>

    // Go to sleep.
    p->chan = chan;
    80002484:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    80002488:	4789                	li	a5,2
    8000248a:	cc9c                	sw	a5,24(s1)

    sched();
    8000248c:	00000097          	auipc	ra,0x0
    80002490:	ec0080e7          	jalr	-320(ra) # 8000234c <sched>

    // Tidy up.
    p->chan = 0;
    80002494:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	9f4080e7          	jalr	-1548(ra) # 80000e8e <release>
    acquire(lk);
    800024a2:	854a                	mv	a0,s2
    800024a4:	fffff097          	auipc	ra,0xfffff
    800024a8:	936080e7          	jalr	-1738(ra) # 80000dda <acquire>
}
    800024ac:	70a2                	ld	ra,40(sp)
    800024ae:	7402                	ld	s0,32(sp)
    800024b0:	64e2                	ld	s1,24(sp)
    800024b2:	6942                	ld	s2,16(sp)
    800024b4:	69a2                	ld	s3,8(sp)
    800024b6:	6145                	addi	sp,sp,48
    800024b8:	8082                	ret

00000000800024ba <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800024ba:	7139                	addi	sp,sp,-64
    800024bc:	fc06                	sd	ra,56(sp)
    800024be:	f822                	sd	s0,48(sp)
    800024c0:	f426                	sd	s1,40(sp)
    800024c2:	f04a                	sd	s2,32(sp)
    800024c4:	ec4e                	sd	s3,24(sp)
    800024c6:	e852                	sd	s4,16(sp)
    800024c8:	e456                	sd	s5,8(sp)
    800024ca:	0080                	addi	s0,sp,64
    800024cc:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800024ce:	0002f497          	auipc	s1,0x2f
    800024d2:	ce248493          	addi	s1,s1,-798 # 800311b0 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    800024d6:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800024d8:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800024da:	00034917          	auipc	s2,0x34
    800024de:	6d690913          	addi	s2,s2,1750 # 80036bb0 <tickslock>
    800024e2:	a811                	j	800024f6 <wakeup+0x3c>
            }
            release(&p->lock);
    800024e4:	8526                	mv	a0,s1
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	9a8080e7          	jalr	-1624(ra) # 80000e8e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800024ee:	16848493          	addi	s1,s1,360
    800024f2:	03248663          	beq	s1,s2,8000251e <wakeup+0x64>
        if (p != myproc())
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	7b2080e7          	jalr	1970(ra) # 80001ca8 <myproc>
    800024fe:	fea488e3          	beq	s1,a0,800024ee <wakeup+0x34>
            acquire(&p->lock);
    80002502:	8526                	mv	a0,s1
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	8d6080e7          	jalr	-1834(ra) # 80000dda <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    8000250c:	4c9c                	lw	a5,24(s1)
    8000250e:	fd379be3          	bne	a5,s3,800024e4 <wakeup+0x2a>
    80002512:	709c                	ld	a5,32(s1)
    80002514:	fd4798e3          	bne	a5,s4,800024e4 <wakeup+0x2a>
                p->state = RUNNABLE;
    80002518:	0154ac23          	sw	s5,24(s1)
    8000251c:	b7e1                	j	800024e4 <wakeup+0x2a>
        }
    }
}
    8000251e:	70e2                	ld	ra,56(sp)
    80002520:	7442                	ld	s0,48(sp)
    80002522:	74a2                	ld	s1,40(sp)
    80002524:	7902                	ld	s2,32(sp)
    80002526:	69e2                	ld	s3,24(sp)
    80002528:	6a42                	ld	s4,16(sp)
    8000252a:	6aa2                	ld	s5,8(sp)
    8000252c:	6121                	addi	sp,sp,64
    8000252e:	8082                	ret

0000000080002530 <reparent>:
{
    80002530:	7179                	addi	sp,sp,-48
    80002532:	f406                	sd	ra,40(sp)
    80002534:	f022                	sd	s0,32(sp)
    80002536:	ec26                	sd	s1,24(sp)
    80002538:	e84a                	sd	s2,16(sp)
    8000253a:	e44e                	sd	s3,8(sp)
    8000253c:	e052                	sd	s4,0(sp)
    8000253e:	1800                	addi	s0,sp,48
    80002540:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002542:	0002f497          	auipc	s1,0x2f
    80002546:	c6e48493          	addi	s1,s1,-914 # 800311b0 <proc>
            pp->parent = initproc;
    8000254a:	00006a17          	auipc	s4,0x6
    8000254e:	5bea0a13          	addi	s4,s4,1470 # 80008b08 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002552:	00034997          	auipc	s3,0x34
    80002556:	65e98993          	addi	s3,s3,1630 # 80036bb0 <tickslock>
    8000255a:	a029                	j	80002564 <reparent+0x34>
    8000255c:	16848493          	addi	s1,s1,360
    80002560:	01348d63          	beq	s1,s3,8000257a <reparent+0x4a>
        if (pp->parent == p)
    80002564:	7c9c                	ld	a5,56(s1)
    80002566:	ff279be3          	bne	a5,s2,8000255c <reparent+0x2c>
            pp->parent = initproc;
    8000256a:	000a3503          	ld	a0,0(s4)
    8000256e:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    80002570:	00000097          	auipc	ra,0x0
    80002574:	f4a080e7          	jalr	-182(ra) # 800024ba <wakeup>
    80002578:	b7d5                	j	8000255c <reparent+0x2c>
}
    8000257a:	70a2                	ld	ra,40(sp)
    8000257c:	7402                	ld	s0,32(sp)
    8000257e:	64e2                	ld	s1,24(sp)
    80002580:	6942                	ld	s2,16(sp)
    80002582:	69a2                	ld	s3,8(sp)
    80002584:	6a02                	ld	s4,0(sp)
    80002586:	6145                	addi	sp,sp,48
    80002588:	8082                	ret

000000008000258a <exit>:
{
    8000258a:	7179                	addi	sp,sp,-48
    8000258c:	f406                	sd	ra,40(sp)
    8000258e:	f022                	sd	s0,32(sp)
    80002590:	ec26                	sd	s1,24(sp)
    80002592:	e84a                	sd	s2,16(sp)
    80002594:	e44e                	sd	s3,8(sp)
    80002596:	e052                	sd	s4,0(sp)
    80002598:	1800                	addi	s0,sp,48
    8000259a:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    8000259c:	fffff097          	auipc	ra,0xfffff
    800025a0:	70c080e7          	jalr	1804(ra) # 80001ca8 <myproc>
    800025a4:	89aa                	mv	s3,a0
    if (p == initproc)
    800025a6:	00006797          	auipc	a5,0x6
    800025aa:	5627b783          	ld	a5,1378(a5) # 80008b08 <initproc>
    800025ae:	0d050493          	addi	s1,a0,208
    800025b2:	15050913          	addi	s2,a0,336
    800025b6:	02a79363          	bne	a5,a0,800025dc <exit+0x52>
        panic("init exiting");
    800025ba:	00006517          	auipc	a0,0x6
    800025be:	ce650513          	addi	a0,a0,-794 # 800082a0 <digits+0x250>
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	f7e080e7          	jalr	-130(ra) # 80000540 <panic>
            fileclose(f);
    800025ca:	00002097          	auipc	ra,0x2
    800025ce:	69c080e7          	jalr	1692(ra) # 80004c66 <fileclose>
            p->ofile[fd] = 0;
    800025d2:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    800025d6:	04a1                	addi	s1,s1,8
    800025d8:	01248563          	beq	s1,s2,800025e2 <exit+0x58>
        if (p->ofile[fd])
    800025dc:	6088                	ld	a0,0(s1)
    800025de:	f575                	bnez	a0,800025ca <exit+0x40>
    800025e0:	bfdd                	j	800025d6 <exit+0x4c>
    begin_op();
    800025e2:	00002097          	auipc	ra,0x2
    800025e6:	1bc080e7          	jalr	444(ra) # 8000479e <begin_op>
    iput(p->cwd);
    800025ea:	1509b503          	ld	a0,336(s3)
    800025ee:	00002097          	auipc	ra,0x2
    800025f2:	99e080e7          	jalr	-1634(ra) # 80003f8c <iput>
    end_op();
    800025f6:	00002097          	auipc	ra,0x2
    800025fa:	226080e7          	jalr	550(ra) # 8000481c <end_op>
    p->cwd = 0;
    800025fe:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002602:	0002f497          	auipc	s1,0x2f
    80002606:	b9648493          	addi	s1,s1,-1130 # 80031198 <wait_lock>
    8000260a:	8526                	mv	a0,s1
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	7ce080e7          	jalr	1998(ra) # 80000dda <acquire>
    reparent(p);
    80002614:	854e                	mv	a0,s3
    80002616:	00000097          	auipc	ra,0x0
    8000261a:	f1a080e7          	jalr	-230(ra) # 80002530 <reparent>
    wakeup(p->parent);
    8000261e:	0389b503          	ld	a0,56(s3)
    80002622:	00000097          	auipc	ra,0x0
    80002626:	e98080e7          	jalr	-360(ra) # 800024ba <wakeup>
    acquire(&p->lock);
    8000262a:	854e                	mv	a0,s3
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	7ae080e7          	jalr	1966(ra) # 80000dda <acquire>
    p->xstate = status;
    80002634:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002638:	4795                	li	a5,5
    8000263a:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    8000263e:	8526                	mv	a0,s1
    80002640:	fffff097          	auipc	ra,0xfffff
    80002644:	84e080e7          	jalr	-1970(ra) # 80000e8e <release>
    sched();
    80002648:	00000097          	auipc	ra,0x0
    8000264c:	d04080e7          	jalr	-764(ra) # 8000234c <sched>
    panic("zombie exit");
    80002650:	00006517          	auipc	a0,0x6
    80002654:	c6050513          	addi	a0,a0,-928 # 800082b0 <digits+0x260>
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	ee8080e7          	jalr	-280(ra) # 80000540 <panic>

0000000080002660 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002660:	7179                	addi	sp,sp,-48
    80002662:	f406                	sd	ra,40(sp)
    80002664:	f022                	sd	s0,32(sp)
    80002666:	ec26                	sd	s1,24(sp)
    80002668:	e84a                	sd	s2,16(sp)
    8000266a:	e44e                	sd	s3,8(sp)
    8000266c:	1800                	addi	s0,sp,48
    8000266e:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002670:	0002f497          	auipc	s1,0x2f
    80002674:	b4048493          	addi	s1,s1,-1216 # 800311b0 <proc>
    80002678:	00034997          	auipc	s3,0x34
    8000267c:	53898993          	addi	s3,s3,1336 # 80036bb0 <tickslock>
    {
        acquire(&p->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	758080e7          	jalr	1880(ra) # 80000dda <acquire>
        if (p->pid == pid)
    8000268a:	589c                	lw	a5,48(s1)
    8000268c:	01278d63          	beq	a5,s2,800026a6 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002690:	8526                	mv	a0,s1
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	7fc080e7          	jalr	2044(ra) # 80000e8e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000269a:	16848493          	addi	s1,s1,360
    8000269e:	ff3491e3          	bne	s1,s3,80002680 <kill+0x20>
    }
    return -1;
    800026a2:	557d                	li	a0,-1
    800026a4:	a829                	j	800026be <kill+0x5e>
            p->killed = 1;
    800026a6:	4785                	li	a5,1
    800026a8:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    800026aa:	4c98                	lw	a4,24(s1)
    800026ac:	4789                	li	a5,2
    800026ae:	00f70f63          	beq	a4,a5,800026cc <kill+0x6c>
            release(&p->lock);
    800026b2:	8526                	mv	a0,s1
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	7da080e7          	jalr	2010(ra) # 80000e8e <release>
            return 0;
    800026bc:	4501                	li	a0,0
}
    800026be:	70a2                	ld	ra,40(sp)
    800026c0:	7402                	ld	s0,32(sp)
    800026c2:	64e2                	ld	s1,24(sp)
    800026c4:	6942                	ld	s2,16(sp)
    800026c6:	69a2                	ld	s3,8(sp)
    800026c8:	6145                	addi	sp,sp,48
    800026ca:	8082                	ret
                p->state = RUNNABLE;
    800026cc:	478d                	li	a5,3
    800026ce:	cc9c                	sw	a5,24(s1)
    800026d0:	b7cd                	j	800026b2 <kill+0x52>

00000000800026d2 <setkilled>:

void setkilled(struct proc *p)
{
    800026d2:	1101                	addi	sp,sp,-32
    800026d4:	ec06                	sd	ra,24(sp)
    800026d6:	e822                	sd	s0,16(sp)
    800026d8:	e426                	sd	s1,8(sp)
    800026da:	1000                	addi	s0,sp,32
    800026dc:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	6fc080e7          	jalr	1788(ra) # 80000dda <acquire>
    p->killed = 1;
    800026e6:	4785                	li	a5,1
    800026e8:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	7a2080e7          	jalr	1954(ra) # 80000e8e <release>
}
    800026f4:	60e2                	ld	ra,24(sp)
    800026f6:	6442                	ld	s0,16(sp)
    800026f8:	64a2                	ld	s1,8(sp)
    800026fa:	6105                	addi	sp,sp,32
    800026fc:	8082                	ret

00000000800026fe <killed>:

int killed(struct proc *p)
{
    800026fe:	1101                	addi	sp,sp,-32
    80002700:	ec06                	sd	ra,24(sp)
    80002702:	e822                	sd	s0,16(sp)
    80002704:	e426                	sd	s1,8(sp)
    80002706:	e04a                	sd	s2,0(sp)
    80002708:	1000                	addi	s0,sp,32
    8000270a:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	6ce080e7          	jalr	1742(ra) # 80000dda <acquire>
    k = p->killed;
    80002714:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	774080e7          	jalr	1908(ra) # 80000e8e <release>
    return k;
}
    80002722:	854a                	mv	a0,s2
    80002724:	60e2                	ld	ra,24(sp)
    80002726:	6442                	ld	s0,16(sp)
    80002728:	64a2                	ld	s1,8(sp)
    8000272a:	6902                	ld	s2,0(sp)
    8000272c:	6105                	addi	sp,sp,32
    8000272e:	8082                	ret

0000000080002730 <wait>:
{
    80002730:	715d                	addi	sp,sp,-80
    80002732:	e486                	sd	ra,72(sp)
    80002734:	e0a2                	sd	s0,64(sp)
    80002736:	fc26                	sd	s1,56(sp)
    80002738:	f84a                	sd	s2,48(sp)
    8000273a:	f44e                	sd	s3,40(sp)
    8000273c:	f052                	sd	s4,32(sp)
    8000273e:	ec56                	sd	s5,24(sp)
    80002740:	e85a                	sd	s6,16(sp)
    80002742:	e45e                	sd	s7,8(sp)
    80002744:	e062                	sd	s8,0(sp)
    80002746:	0880                	addi	s0,sp,80
    80002748:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    8000274a:	fffff097          	auipc	ra,0xfffff
    8000274e:	55e080e7          	jalr	1374(ra) # 80001ca8 <myproc>
    80002752:	892a                	mv	s2,a0
    acquire(&wait_lock);
    80002754:	0002f517          	auipc	a0,0x2f
    80002758:	a4450513          	addi	a0,a0,-1468 # 80031198 <wait_lock>
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	67e080e7          	jalr	1662(ra) # 80000dda <acquire>
        havekids = 0;
    80002764:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    80002766:	4a15                	li	s4,5
                havekids = 1;
    80002768:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000276a:	00034997          	auipc	s3,0x34
    8000276e:	44698993          	addi	s3,s3,1094 # 80036bb0 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002772:	0002fc17          	auipc	s8,0x2f
    80002776:	a26c0c13          	addi	s8,s8,-1498 # 80031198 <wait_lock>
        havekids = 0;
    8000277a:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000277c:	0002f497          	auipc	s1,0x2f
    80002780:	a3448493          	addi	s1,s1,-1484 # 800311b0 <proc>
    80002784:	a0bd                	j	800027f2 <wait+0xc2>
                    pid = pp->pid;
    80002786:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000278a:	000b0e63          	beqz	s6,800027a6 <wait+0x76>
    8000278e:	4691                	li	a3,4
    80002790:	02c48613          	addi	a2,s1,44
    80002794:	85da                	mv	a1,s6
    80002796:	05093503          	ld	a0,80(s2)
    8000279a:	fffff097          	auipc	ra,0xfffff
    8000279e:	0d0080e7          	jalr	208(ra) # 8000186a <copyout>
    800027a2:	02054563          	bltz	a0,800027cc <wait+0x9c>
                    freeproc(pp);
    800027a6:	8526                	mv	a0,s1
    800027a8:	fffff097          	auipc	ra,0xfffff
    800027ac:	6b2080e7          	jalr	1714(ra) # 80001e5a <freeproc>
                    release(&pp->lock);
    800027b0:	8526                	mv	a0,s1
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	6dc080e7          	jalr	1756(ra) # 80000e8e <release>
                    release(&wait_lock);
    800027ba:	0002f517          	auipc	a0,0x2f
    800027be:	9de50513          	addi	a0,a0,-1570 # 80031198 <wait_lock>
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	6cc080e7          	jalr	1740(ra) # 80000e8e <release>
                    return pid;
    800027ca:	a0b5                	j	80002836 <wait+0x106>
                        release(&pp->lock);
    800027cc:	8526                	mv	a0,s1
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	6c0080e7          	jalr	1728(ra) # 80000e8e <release>
                        release(&wait_lock);
    800027d6:	0002f517          	auipc	a0,0x2f
    800027da:	9c250513          	addi	a0,a0,-1598 # 80031198 <wait_lock>
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	6b0080e7          	jalr	1712(ra) # 80000e8e <release>
                        return -1;
    800027e6:	59fd                	li	s3,-1
    800027e8:	a0b9                	j	80002836 <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ea:	16848493          	addi	s1,s1,360
    800027ee:	03348463          	beq	s1,s3,80002816 <wait+0xe6>
            if (pp->parent == p)
    800027f2:	7c9c                	ld	a5,56(s1)
    800027f4:	ff279be3          	bne	a5,s2,800027ea <wait+0xba>
                acquire(&pp->lock);
    800027f8:	8526                	mv	a0,s1
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	5e0080e7          	jalr	1504(ra) # 80000dda <acquire>
                if (pp->state == ZOMBIE)
    80002802:	4c9c                	lw	a5,24(s1)
    80002804:	f94781e3          	beq	a5,s4,80002786 <wait+0x56>
                release(&pp->lock);
    80002808:	8526                	mv	a0,s1
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	684080e7          	jalr	1668(ra) # 80000e8e <release>
                havekids = 1;
    80002812:	8756                	mv	a4,s5
    80002814:	bfd9                	j	800027ea <wait+0xba>
        if (!havekids || killed(p))
    80002816:	c719                	beqz	a4,80002824 <wait+0xf4>
    80002818:	854a                	mv	a0,s2
    8000281a:	00000097          	auipc	ra,0x0
    8000281e:	ee4080e7          	jalr	-284(ra) # 800026fe <killed>
    80002822:	c51d                	beqz	a0,80002850 <wait+0x120>
            release(&wait_lock);
    80002824:	0002f517          	auipc	a0,0x2f
    80002828:	97450513          	addi	a0,a0,-1676 # 80031198 <wait_lock>
    8000282c:	ffffe097          	auipc	ra,0xffffe
    80002830:	662080e7          	jalr	1634(ra) # 80000e8e <release>
            return -1;
    80002834:	59fd                	li	s3,-1
}
    80002836:	854e                	mv	a0,s3
    80002838:	60a6                	ld	ra,72(sp)
    8000283a:	6406                	ld	s0,64(sp)
    8000283c:	74e2                	ld	s1,56(sp)
    8000283e:	7942                	ld	s2,48(sp)
    80002840:	79a2                	ld	s3,40(sp)
    80002842:	7a02                	ld	s4,32(sp)
    80002844:	6ae2                	ld	s5,24(sp)
    80002846:	6b42                	ld	s6,16(sp)
    80002848:	6ba2                	ld	s7,8(sp)
    8000284a:	6c02                	ld	s8,0(sp)
    8000284c:	6161                	addi	sp,sp,80
    8000284e:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002850:	85e2                	mv	a1,s8
    80002852:	854a                	mv	a0,s2
    80002854:	00000097          	auipc	ra,0x0
    80002858:	c02080e7          	jalr	-1022(ra) # 80002456 <sleep>
        havekids = 0;
    8000285c:	bf39                	j	8000277a <wait+0x4a>

000000008000285e <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000285e:	7179                	addi	sp,sp,-48
    80002860:	f406                	sd	ra,40(sp)
    80002862:	f022                	sd	s0,32(sp)
    80002864:	ec26                	sd	s1,24(sp)
    80002866:	e84a                	sd	s2,16(sp)
    80002868:	e44e                	sd	s3,8(sp)
    8000286a:	e052                	sd	s4,0(sp)
    8000286c:	1800                	addi	s0,sp,48
    8000286e:	84aa                	mv	s1,a0
    80002870:	892e                	mv	s2,a1
    80002872:	89b2                	mv	s3,a2
    80002874:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002876:	fffff097          	auipc	ra,0xfffff
    8000287a:	432080e7          	jalr	1074(ra) # 80001ca8 <myproc>
    if (user_dst)
    8000287e:	c08d                	beqz	s1,800028a0 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002880:	86d2                	mv	a3,s4
    80002882:	864e                	mv	a2,s3
    80002884:	85ca                	mv	a1,s2
    80002886:	6928                	ld	a0,80(a0)
    80002888:	fffff097          	auipc	ra,0xfffff
    8000288c:	fe2080e7          	jalr	-30(ra) # 8000186a <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002890:	70a2                	ld	ra,40(sp)
    80002892:	7402                	ld	s0,32(sp)
    80002894:	64e2                	ld	s1,24(sp)
    80002896:	6942                	ld	s2,16(sp)
    80002898:	69a2                	ld	s3,8(sp)
    8000289a:	6a02                	ld	s4,0(sp)
    8000289c:	6145                	addi	sp,sp,48
    8000289e:	8082                	ret
        memmove((char *)dst, src, len);
    800028a0:	000a061b          	sext.w	a2,s4
    800028a4:	85ce                	mv	a1,s3
    800028a6:	854a                	mv	a0,s2
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	68a080e7          	jalr	1674(ra) # 80000f32 <memmove>
        return 0;
    800028b0:	8526                	mv	a0,s1
    800028b2:	bff9                	j	80002890 <either_copyout+0x32>

00000000800028b4 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028b4:	7179                	addi	sp,sp,-48
    800028b6:	f406                	sd	ra,40(sp)
    800028b8:	f022                	sd	s0,32(sp)
    800028ba:	ec26                	sd	s1,24(sp)
    800028bc:	e84a                	sd	s2,16(sp)
    800028be:	e44e                	sd	s3,8(sp)
    800028c0:	e052                	sd	s4,0(sp)
    800028c2:	1800                	addi	s0,sp,48
    800028c4:	892a                	mv	s2,a0
    800028c6:	84ae                	mv	s1,a1
    800028c8:	89b2                	mv	s3,a2
    800028ca:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800028cc:	fffff097          	auipc	ra,0xfffff
    800028d0:	3dc080e7          	jalr	988(ra) # 80001ca8 <myproc>
    if (user_src)
    800028d4:	c08d                	beqz	s1,800028f6 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    800028d6:	86d2                	mv	a3,s4
    800028d8:	864e                	mv	a2,s3
    800028da:	85ca                	mv	a1,s2
    800028dc:	6928                	ld	a0,80(a0)
    800028de:	fffff097          	auipc	ra,0xfffff
    800028e2:	018080e7          	jalr	24(ra) # 800018f6 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    800028e6:	70a2                	ld	ra,40(sp)
    800028e8:	7402                	ld	s0,32(sp)
    800028ea:	64e2                	ld	s1,24(sp)
    800028ec:	6942                	ld	s2,16(sp)
    800028ee:	69a2                	ld	s3,8(sp)
    800028f0:	6a02                	ld	s4,0(sp)
    800028f2:	6145                	addi	sp,sp,48
    800028f4:	8082                	ret
        memmove(dst, (char *)src, len);
    800028f6:	000a061b          	sext.w	a2,s4
    800028fa:	85ce                	mv	a1,s3
    800028fc:	854a                	mv	a0,s2
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	634080e7          	jalr	1588(ra) # 80000f32 <memmove>
        return 0;
    80002906:	8526                	mv	a0,s1
    80002908:	bff9                	j	800028e6 <either_copyin+0x32>

000000008000290a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000290a:	715d                	addi	sp,sp,-80
    8000290c:	e486                	sd	ra,72(sp)
    8000290e:	e0a2                	sd	s0,64(sp)
    80002910:	fc26                	sd	s1,56(sp)
    80002912:	f84a                	sd	s2,48(sp)
    80002914:	f44e                	sd	s3,40(sp)
    80002916:	f052                	sd	s4,32(sp)
    80002918:	ec56                	sd	s5,24(sp)
    8000291a:	e85a                	sd	s6,16(sp)
    8000291c:	e45e                	sd	s7,8(sp)
    8000291e:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002920:	00005517          	auipc	a0,0x5
    80002924:	76850513          	addi	a0,a0,1896 # 80008088 <digits+0x38>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	c74080e7          	jalr	-908(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002930:	0002f497          	auipc	s1,0x2f
    80002934:	9d848493          	addi	s1,s1,-1576 # 80031308 <proc+0x158>
    80002938:	00034917          	auipc	s2,0x34
    8000293c:	3d090913          	addi	s2,s2,976 # 80036d08 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002940:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002942:	00006997          	auipc	s3,0x6
    80002946:	97e98993          	addi	s3,s3,-1666 # 800082c0 <digits+0x270>
        printf("%d <%s %s", p->pid, state, p->name);
    8000294a:	00006a97          	auipc	s5,0x6
    8000294e:	97ea8a93          	addi	s5,s5,-1666 # 800082c8 <digits+0x278>
        printf("\n");
    80002952:	00005a17          	auipc	s4,0x5
    80002956:	736a0a13          	addi	s4,s4,1846 # 80008088 <digits+0x38>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000295a:	00006b97          	auipc	s7,0x6
    8000295e:	a7eb8b93          	addi	s7,s7,-1410 # 800083d8 <states.0>
    80002962:	a00d                	j	80002984 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002964:	ed86a583          	lw	a1,-296(a3)
    80002968:	8556                	mv	a0,s5
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	c32080e7          	jalr	-974(ra) # 8000059c <printf>
        printf("\n");
    80002972:	8552                	mv	a0,s4
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	c28080e7          	jalr	-984(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    8000297c:	16848493          	addi	s1,s1,360
    80002980:	03248263          	beq	s1,s2,800029a4 <procdump+0x9a>
        if (p->state == UNUSED)
    80002984:	86a6                	mv	a3,s1
    80002986:	ec04a783          	lw	a5,-320(s1)
    8000298a:	dbed                	beqz	a5,8000297c <procdump+0x72>
            state = "???";
    8000298c:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000298e:	fcfb6be3          	bltu	s6,a5,80002964 <procdump+0x5a>
    80002992:	02079713          	slli	a4,a5,0x20
    80002996:	01d75793          	srli	a5,a4,0x1d
    8000299a:	97de                	add	a5,a5,s7
    8000299c:	6390                	ld	a2,0(a5)
    8000299e:	f279                	bnez	a2,80002964 <procdump+0x5a>
            state = "???";
    800029a0:	864e                	mv	a2,s3
    800029a2:	b7c9                	j	80002964 <procdump+0x5a>
    }
}
    800029a4:	60a6                	ld	ra,72(sp)
    800029a6:	6406                	ld	s0,64(sp)
    800029a8:	74e2                	ld	s1,56(sp)
    800029aa:	7942                	ld	s2,48(sp)
    800029ac:	79a2                	ld	s3,40(sp)
    800029ae:	7a02                	ld	s4,32(sp)
    800029b0:	6ae2                	ld	s5,24(sp)
    800029b2:	6b42                	ld	s6,16(sp)
    800029b4:	6ba2                	ld	s7,8(sp)
    800029b6:	6161                	addi	sp,sp,80
    800029b8:	8082                	ret

00000000800029ba <schedls>:

void schedls()
{
    800029ba:	1141                	addi	sp,sp,-16
    800029bc:	e406                	sd	ra,8(sp)
    800029be:	e022                	sd	s0,0(sp)
    800029c0:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    800029c2:	00006517          	auipc	a0,0x6
    800029c6:	91650513          	addi	a0,a0,-1770 # 800082d8 <digits+0x288>
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	bd2080e7          	jalr	-1070(ra) # 8000059c <printf>
    printf("====================================\n");
    800029d2:	00006517          	auipc	a0,0x6
    800029d6:	92e50513          	addi	a0,a0,-1746 # 80008300 <digits+0x2b0>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	bc2080e7          	jalr	-1086(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    800029e2:	00006717          	auipc	a4,0x6
    800029e6:	0b673703          	ld	a4,182(a4) # 80008a98 <available_schedulers+0x10>
    800029ea:	00006797          	auipc	a5,0x6
    800029ee:	04e7b783          	ld	a5,78(a5) # 80008a38 <sched_pointer>
    800029f2:	04f70663          	beq	a4,a5,80002a3e <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	93a50513          	addi	a0,a0,-1734 # 80008330 <digits+0x2e0>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b9e080e7          	jalr	-1122(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002a06:	00006617          	auipc	a2,0x6
    80002a0a:	09a62603          	lw	a2,154(a2) # 80008aa0 <available_schedulers+0x18>
    80002a0e:	00006597          	auipc	a1,0x6
    80002a12:	07a58593          	addi	a1,a1,122 # 80008a88 <available_schedulers>
    80002a16:	00006517          	auipc	a0,0x6
    80002a1a:	92250513          	addi	a0,a0,-1758 # 80008338 <digits+0x2e8>
    80002a1e:	ffffe097          	auipc	ra,0xffffe
    80002a22:	b7e080e7          	jalr	-1154(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002a26:	00006517          	auipc	a0,0x6
    80002a2a:	91a50513          	addi	a0,a0,-1766 # 80008340 <digits+0x2f0>
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	b6e080e7          	jalr	-1170(ra) # 8000059c <printf>
}
    80002a36:	60a2                	ld	ra,8(sp)
    80002a38:	6402                	ld	s0,0(sp)
    80002a3a:	0141                	addi	sp,sp,16
    80002a3c:	8082                	ret
            printf("[*]\t");
    80002a3e:	00006517          	auipc	a0,0x6
    80002a42:	8ea50513          	addi	a0,a0,-1814 # 80008328 <digits+0x2d8>
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	b56080e7          	jalr	-1194(ra) # 8000059c <printf>
    80002a4e:	bf65                	j	80002a06 <schedls+0x4c>

0000000080002a50 <schedset>:

void schedset(int id)
{
    80002a50:	1141                	addi	sp,sp,-16
    80002a52:	e406                	sd	ra,8(sp)
    80002a54:	e022                	sd	s0,0(sp)
    80002a56:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002a58:	e90d                	bnez	a0,80002a8a <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002a5a:	00006797          	auipc	a5,0x6
    80002a5e:	03e7b783          	ld	a5,62(a5) # 80008a98 <available_schedulers+0x10>
    80002a62:	00006717          	auipc	a4,0x6
    80002a66:	fcf73b23          	sd	a5,-42(a4) # 80008a38 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002a6a:	00006597          	auipc	a1,0x6
    80002a6e:	01e58593          	addi	a1,a1,30 # 80008a88 <available_schedulers>
    80002a72:	00006517          	auipc	a0,0x6
    80002a76:	90e50513          	addi	a0,a0,-1778 # 80008380 <digits+0x330>
    80002a7a:	ffffe097          	auipc	ra,0xffffe
    80002a7e:	b22080e7          	jalr	-1246(ra) # 8000059c <printf>
}
    80002a82:	60a2                	ld	ra,8(sp)
    80002a84:	6402                	ld	s0,0(sp)
    80002a86:	0141                	addi	sp,sp,16
    80002a88:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002a8a:	00006517          	auipc	a0,0x6
    80002a8e:	8ce50513          	addi	a0,a0,-1842 # 80008358 <digits+0x308>
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	b0a080e7          	jalr	-1270(ra) # 8000059c <printf>
        return;
    80002a9a:	b7e5                	j	80002a82 <schedset+0x32>

0000000080002a9c <va2pa>:

// In proc.c or another appropriate file
uint64
va2pa(uint64 va, int pid)
{
    80002a9c:	1101                	addi	sp,sp,-32
    80002a9e:	ec06                	sd	ra,24(sp)
    80002aa0:	e822                	sd	s0,16(sp)
    80002aa2:	e426                	sd	s1,8(sp)
    80002aa4:	1000                	addi	s0,sp,32
    80002aa6:	84aa                	mv	s1,a0

if (pid == 0) {
  p = myproc();
}
else {
for (p=proc; p < &proc[NPROC]; p++){
    80002aa8:	0002e797          	auipc	a5,0x2e
    80002aac:	70878793          	addi	a5,a5,1800 # 800311b0 <proc>
    80002ab0:	00034697          	auipc	a3,0x34
    80002ab4:	10068693          	addi	a3,a3,256 # 80036bb0 <tickslock>
if (pid == 0) {
    80002ab8:	c991                	beqz	a1,80002acc <va2pa+0x30>
        if(p->pid == pid)
    80002aba:	5b98                	lw	a4,48(a5)
    80002abc:	02b70863          	beq	a4,a1,80002aec <va2pa+0x50>
for (p=proc; p < &proc[NPROC]; p++){
    80002ac0:	16878793          	addi	a5,a5,360
    80002ac4:	fed79be3          	bne	a5,a3,80002aba <va2pa+0x1e>
            break;
    }

    if ( p >= &proc[NPROC] || p->state == UNUSED){
        return 0;
    80002ac8:	4501                	li	a0,0
    80002aca:	a821                	j	80002ae2 <va2pa+0x46>
  p = myproc();
    80002acc:	fffff097          	auipc	ra,0xfffff
    80002ad0:	1dc080e7          	jalr	476(ra) # 80001ca8 <myproc>
    80002ad4:	87aa                	mv	a5,a0
    }
}
  
    return walkaddr(p->pagetable, va);
    80002ad6:	85a6                	mv	a1,s1
    80002ad8:	6ba8                	ld	a0,80(a5)
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	786080e7          	jalr	1926(ra) # 80001260 <walkaddr>
    80002ae2:	60e2                	ld	ra,24(sp)
    80002ae4:	6442                	ld	s0,16(sp)
    80002ae6:	64a2                	ld	s1,8(sp)
    80002ae8:	6105                	addi	sp,sp,32
    80002aea:	8082                	ret
    if ( p >= &proc[NPROC] || p->state == UNUSED){
    80002aec:	00034717          	auipc	a4,0x34
    80002af0:	0c470713          	addi	a4,a4,196 # 80036bb0 <tickslock>
    80002af4:	00e7f663          	bgeu	a5,a4,80002b00 <va2pa+0x64>
    80002af8:	4f98                	lw	a4,24(a5)
        return 0;
    80002afa:	4501                	li	a0,0
    if ( p >= &proc[NPROC] || p->state == UNUSED){
    80002afc:	ff69                	bnez	a4,80002ad6 <va2pa+0x3a>
    80002afe:	b7d5                	j	80002ae2 <va2pa+0x46>
        return 0;
    80002b00:	4501                	li	a0,0
    80002b02:	b7c5                	j	80002ae2 <va2pa+0x46>

0000000080002b04 <swtch>:
    80002b04:	00153023          	sd	ra,0(a0)
    80002b08:	00253423          	sd	sp,8(a0)
    80002b0c:	e900                	sd	s0,16(a0)
    80002b0e:	ed04                	sd	s1,24(a0)
    80002b10:	03253023          	sd	s2,32(a0)
    80002b14:	03353423          	sd	s3,40(a0)
    80002b18:	03453823          	sd	s4,48(a0)
    80002b1c:	03553c23          	sd	s5,56(a0)
    80002b20:	05653023          	sd	s6,64(a0)
    80002b24:	05753423          	sd	s7,72(a0)
    80002b28:	05853823          	sd	s8,80(a0)
    80002b2c:	05953c23          	sd	s9,88(a0)
    80002b30:	07a53023          	sd	s10,96(a0)
    80002b34:	07b53423          	sd	s11,104(a0)
    80002b38:	0005b083          	ld	ra,0(a1)
    80002b3c:	0085b103          	ld	sp,8(a1)
    80002b40:	6980                	ld	s0,16(a1)
    80002b42:	6d84                	ld	s1,24(a1)
    80002b44:	0205b903          	ld	s2,32(a1)
    80002b48:	0285b983          	ld	s3,40(a1)
    80002b4c:	0305ba03          	ld	s4,48(a1)
    80002b50:	0385ba83          	ld	s5,56(a1)
    80002b54:	0405bb03          	ld	s6,64(a1)
    80002b58:	0485bb83          	ld	s7,72(a1)
    80002b5c:	0505bc03          	ld	s8,80(a1)
    80002b60:	0585bc83          	ld	s9,88(a1)
    80002b64:	0605bd03          	ld	s10,96(a1)
    80002b68:	0685bd83          	ld	s11,104(a1)
    80002b6c:	8082                	ret

0000000080002b6e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b6e:	1141                	addi	sp,sp,-16
    80002b70:	e406                	sd	ra,8(sp)
    80002b72:	e022                	sd	s0,0(sp)
    80002b74:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b76:	00006597          	auipc	a1,0x6
    80002b7a:	89258593          	addi	a1,a1,-1902 # 80008408 <states.0+0x30>
    80002b7e:	00034517          	auipc	a0,0x34
    80002b82:	03250513          	addi	a0,a0,50 # 80036bb0 <tickslock>
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	1c4080e7          	jalr	452(ra) # 80000d4a <initlock>
}
    80002b8e:	60a2                	ld	ra,8(sp)
    80002b90:	6402                	ld	s0,0(sp)
    80002b92:	0141                	addi	sp,sp,16
    80002b94:	8082                	ret

0000000080002b96 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b96:	1141                	addi	sp,sp,-16
    80002b98:	e422                	sd	s0,8(sp)
    80002b9a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b9c:	00003797          	auipc	a5,0x3
    80002ba0:	72478793          	addi	a5,a5,1828 # 800062c0 <kernelvec>
    80002ba4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ba8:	6422                	ld	s0,8(sp)
    80002baa:	0141                	addi	sp,sp,16
    80002bac:	8082                	ret

0000000080002bae <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002bae:	1141                	addi	sp,sp,-16
    80002bb0:	e406                	sd	ra,8(sp)
    80002bb2:	e022                	sd	s0,0(sp)
    80002bb4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bb6:	fffff097          	auipc	ra,0xfffff
    80002bba:	0f2080e7          	jalr	242(ra) # 80001ca8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bc2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002bc8:	00004697          	auipc	a3,0x4
    80002bcc:	43868693          	addi	a3,a3,1080 # 80007000 <_trampoline>
    80002bd0:	00004717          	auipc	a4,0x4
    80002bd4:	43070713          	addi	a4,a4,1072 # 80007000 <_trampoline>
    80002bd8:	8f15                	sub	a4,a4,a3
    80002bda:	040007b7          	lui	a5,0x4000
    80002bde:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002be0:	07b2                	slli	a5,a5,0xc
    80002be2:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002be4:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002be8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002bea:	18002673          	csrr	a2,satp
    80002bee:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002bf0:	6d30                	ld	a2,88(a0)
    80002bf2:	6138                	ld	a4,64(a0)
    80002bf4:	6585                	lui	a1,0x1
    80002bf6:	972e                	add	a4,a4,a1
    80002bf8:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002bfa:	6d38                	ld	a4,88(a0)
    80002bfc:	00000617          	auipc	a2,0x0
    80002c00:	13060613          	addi	a2,a2,304 # 80002d2c <usertrap>
    80002c04:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c06:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c08:	8612                	mv	a2,tp
    80002c0a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c0c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c10:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c14:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c18:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c1c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c1e:	6f18                	ld	a4,24(a4)
    80002c20:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c24:	6928                	ld	a0,80(a0)
    80002c26:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c28:	00004717          	auipc	a4,0x4
    80002c2c:	47470713          	addi	a4,a4,1140 # 8000709c <userret>
    80002c30:	8f15                	sub	a4,a4,a3
    80002c32:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c34:	577d                	li	a4,-1
    80002c36:	177e                	slli	a4,a4,0x3f
    80002c38:	8d59                	or	a0,a0,a4
    80002c3a:	9782                	jalr	a5
}
    80002c3c:	60a2                	ld	ra,8(sp)
    80002c3e:	6402                	ld	s0,0(sp)
    80002c40:	0141                	addi	sp,sp,16
    80002c42:	8082                	ret

0000000080002c44 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c44:	1101                	addi	sp,sp,-32
    80002c46:	ec06                	sd	ra,24(sp)
    80002c48:	e822                	sd	s0,16(sp)
    80002c4a:	e426                	sd	s1,8(sp)
    80002c4c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c4e:	00034497          	auipc	s1,0x34
    80002c52:	f6248493          	addi	s1,s1,-158 # 80036bb0 <tickslock>
    80002c56:	8526                	mv	a0,s1
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	182080e7          	jalr	386(ra) # 80000dda <acquire>
  ticks++;
    80002c60:	00006517          	auipc	a0,0x6
    80002c64:	eb050513          	addi	a0,a0,-336 # 80008b10 <ticks>
    80002c68:	411c                	lw	a5,0(a0)
    80002c6a:	2785                	addiw	a5,a5,1
    80002c6c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	84c080e7          	jalr	-1972(ra) # 800024ba <wakeup>
  release(&tickslock);
    80002c76:	8526                	mv	a0,s1
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	216080e7          	jalr	534(ra) # 80000e8e <release>
}
    80002c80:	60e2                	ld	ra,24(sp)
    80002c82:	6442                	ld	s0,16(sp)
    80002c84:	64a2                	ld	s1,8(sp)
    80002c86:	6105                	addi	sp,sp,32
    80002c88:	8082                	ret

0000000080002c8a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c8a:	1101                	addi	sp,sp,-32
    80002c8c:	ec06                	sd	ra,24(sp)
    80002c8e:	e822                	sd	s0,16(sp)
    80002c90:	e426                	sd	s1,8(sp)
    80002c92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c94:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c98:	00074d63          	bltz	a4,80002cb2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c9c:	57fd                	li	a5,-1
    80002c9e:	17fe                	slli	a5,a5,0x3f
    80002ca0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ca2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ca4:	06f70363          	beq	a4,a5,80002d0a <devintr+0x80>
  }
}
    80002ca8:	60e2                	ld	ra,24(sp)
    80002caa:	6442                	ld	s0,16(sp)
    80002cac:	64a2                	ld	s1,8(sp)
    80002cae:	6105                	addi	sp,sp,32
    80002cb0:	8082                	ret
     (scause & 0xff) == 9){
    80002cb2:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002cb6:	46a5                	li	a3,9
    80002cb8:	fed792e3          	bne	a5,a3,80002c9c <devintr+0x12>
    int irq = plic_claim();
    80002cbc:	00003097          	auipc	ra,0x3
    80002cc0:	70c080e7          	jalr	1804(ra) # 800063c8 <plic_claim>
    80002cc4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cc6:	47a9                	li	a5,10
    80002cc8:	02f50763          	beq	a0,a5,80002cf6 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002ccc:	4785                	li	a5,1
    80002cce:	02f50963          	beq	a0,a5,80002d00 <devintr+0x76>
    return 1;
    80002cd2:	4505                	li	a0,1
    } else if(irq){
    80002cd4:	d8f1                	beqz	s1,80002ca8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002cd6:	85a6                	mv	a1,s1
    80002cd8:	00005517          	auipc	a0,0x5
    80002cdc:	73850513          	addi	a0,a0,1848 # 80008410 <states.0+0x38>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	8bc080e7          	jalr	-1860(ra) # 8000059c <printf>
      plic_complete(irq);
    80002ce8:	8526                	mv	a0,s1
    80002cea:	00003097          	auipc	ra,0x3
    80002cee:	702080e7          	jalr	1794(ra) # 800063ec <plic_complete>
    return 1;
    80002cf2:	4505                	li	a0,1
    80002cf4:	bf55                	j	80002ca8 <devintr+0x1e>
      uartintr();
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	cb4080e7          	jalr	-844(ra) # 800009aa <uartintr>
    80002cfe:	b7ed                	j	80002ce8 <devintr+0x5e>
      virtio_disk_intr();
    80002d00:	00004097          	auipc	ra,0x4
    80002d04:	bb4080e7          	jalr	-1100(ra) # 800068b4 <virtio_disk_intr>
    80002d08:	b7c5                	j	80002ce8 <devintr+0x5e>
    if(cpuid() == 0){
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	f72080e7          	jalr	-142(ra) # 80001c7c <cpuid>
    80002d12:	c901                	beqz	a0,80002d22 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d14:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d1a:	14479073          	csrw	sip,a5
    return 2;
    80002d1e:	4509                	li	a0,2
    80002d20:	b761                	j	80002ca8 <devintr+0x1e>
      clockintr();
    80002d22:	00000097          	auipc	ra,0x0
    80002d26:	f22080e7          	jalr	-222(ra) # 80002c44 <clockintr>
    80002d2a:	b7ed                	j	80002d14 <devintr+0x8a>

0000000080002d2c <usertrap>:
{
    80002d2c:	7139                	addi	sp,sp,-64
    80002d2e:	fc06                	sd	ra,56(sp)
    80002d30:	f822                	sd	s0,48(sp)
    80002d32:	f426                	sd	s1,40(sp)
    80002d34:	f04a                	sd	s2,32(sp)
    80002d36:	ec4e                	sd	s3,24(sp)
    80002d38:	e852                	sd	s4,16(sp)
    80002d3a:	e456                	sd	s5,8(sp)
    80002d3c:	e05a                	sd	s6,0(sp)
    80002d3e:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d40:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d44:	1007f793          	andi	a5,a5,256
    80002d48:	efb5                	bnez	a5,80002dc4 <usertrap+0x98>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d4a:	00003797          	auipc	a5,0x3
    80002d4e:	57678793          	addi	a5,a5,1398 # 800062c0 <kernelvec>
    80002d52:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	f52080e7          	jalr	-174(ra) # 80001ca8 <myproc>
    80002d5e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d60:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d62:	14102773          	csrr	a4,sepc
    80002d66:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d68:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d6c:	47a1                	li	a5,8
    80002d6e:	06f70363          	beq	a4,a5,80002dd4 <usertrap+0xa8>
  } else if((which_dev = devintr()) != 0){
    80002d72:	00000097          	auipc	ra,0x0
    80002d76:	f18080e7          	jalr	-232(ra) # 80002c8a <devintr>
    80002d7a:	892a                	mv	s2,a0
    80002d7c:	1e051d63          	bnez	a0,80002f76 <usertrap+0x24a>
    80002d80:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002d84:	47bd                	li	a5,15
    80002d86:	0af70563          	beq	a4,a5,80002e30 <usertrap+0x104>
    80002d8a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d8e:	5890                	lw	a2,48(s1)
    80002d90:	00005517          	auipc	a0,0x5
    80002d94:	77850513          	addi	a0,a0,1912 # 80008508 <states.0+0x130>
    80002d98:	ffffe097          	auipc	ra,0xffffe
    80002d9c:	804080e7          	jalr	-2044(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002da0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002da4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002da8:	00005517          	auipc	a0,0x5
    80002dac:	79050513          	addi	a0,a0,1936 # 80008538 <states.0+0x160>
    80002db0:	ffffd097          	auipc	ra,0xffffd
    80002db4:	7ec080e7          	jalr	2028(ra) # 8000059c <printf>
    setkilled(p);
    80002db8:	8526                	mv	a0,s1
    80002dba:	00000097          	auipc	ra,0x0
    80002dbe:	918080e7          	jalr	-1768(ra) # 800026d2 <setkilled>
    80002dc2:	a825                	j	80002dfa <usertrap+0xce>
    panic("usertrap: not from user mode");
    80002dc4:	00005517          	auipc	a0,0x5
    80002dc8:	66c50513          	addi	a0,a0,1644 # 80008430 <states.0+0x58>
    80002dcc:	ffffd097          	auipc	ra,0xffffd
    80002dd0:	774080e7          	jalr	1908(ra) # 80000540 <panic>
    if(killed(p))
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	92a080e7          	jalr	-1750(ra) # 800026fe <killed>
    80002ddc:	e521                	bnez	a0,80002e24 <usertrap+0xf8>
    p->trapframe->epc += 4;
    80002dde:	6cb8                	ld	a4,88(s1)
    80002de0:	6f1c                	ld	a5,24(a4)
    80002de2:	0791                	addi	a5,a5,4
    80002de4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002de6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002dea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dee:	10079073          	csrw	sstatus,a5
    syscall();
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	3f8080e7          	jalr	1016(ra) # 800031ea <syscall>
  if(killed(p))
    80002dfa:	8526                	mv	a0,s1
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	902080e7          	jalr	-1790(ra) # 800026fe <killed>
    80002e04:	18051063          	bnez	a0,80002f84 <usertrap+0x258>
  usertrapret();
    80002e08:	00000097          	auipc	ra,0x0
    80002e0c:	da6080e7          	jalr	-602(ra) # 80002bae <usertrapret>
}
    80002e10:	70e2                	ld	ra,56(sp)
    80002e12:	7442                	ld	s0,48(sp)
    80002e14:	74a2                	ld	s1,40(sp)
    80002e16:	7902                	ld	s2,32(sp)
    80002e18:	69e2                	ld	s3,24(sp)
    80002e1a:	6a42                	ld	s4,16(sp)
    80002e1c:	6aa2                	ld	s5,8(sp)
    80002e1e:	6b02                	ld	s6,0(sp)
    80002e20:	6121                	addi	sp,sp,64
    80002e22:	8082                	ret
      exit(-1);
    80002e24:	557d                	li	a0,-1
    80002e26:	fffff097          	auipc	ra,0xfffff
    80002e2a:	764080e7          	jalr	1892(ra) # 8000258a <exit>
    80002e2e:	bf45                	j	80002dde <usertrap+0xb2>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e30:	14302b73          	csrr	s6,stval
    struct proc *p = myproc();
    80002e34:	fffff097          	auipc	ra,0xfffff
    80002e38:	e74080e7          	jalr	-396(ra) # 80001ca8 <myproc>
    80002e3c:	892a                	mv	s2,a0
    if (va >= p->sz) {
    80002e3e:	020b1993          	slli	s3,s6,0x20
    80002e42:	0209d993          	srli	s3,s3,0x20
    80002e46:	653c                	ld	a5,72(a0)
    80002e48:	08f9fc63          	bgeu	s3,a5,80002ee0 <usertrap+0x1b4>
    if ((pte = walk(p->pagetable, va, 0)) == 0) {
    80002e4c:	4601                	li	a2,0
    80002e4e:	85ce                	mv	a1,s3
    80002e50:	05093503          	ld	a0,80(s2)
    80002e54:	ffffe097          	auipc	ra,0xffffe
    80002e58:	366080e7          	jalr	870(ra) # 800011ba <walk>
    80002e5c:	8a2a                	mv	s4,a0
    80002e5e:	cd59                	beqz	a0,80002efc <usertrap+0x1d0>
    if ((*pte & PTE_COW) == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U)==0) {
    80002e60:	000a3783          	ld	a5,0(s4)
    80002e64:	0317f793          	andi	a5,a5,49
    80002e68:	03100713          	li	a4,49
    80002e6c:	0ae79663          	bne	a5,a4,80002f18 <usertrap+0x1ec>
    pa = PTE2PA(*pte);
    80002e70:	000a3983          	ld	s3,0(s4)
    80002e74:	00a9d993          	srli	s3,s3,0xa
    80002e78:	09b2                	slli	s3,s3,0xc
    if ((mem = kalloc()) == 0) {
    80002e7a:	ffffe097          	auipc	ra,0xffffe
    80002e7e:	e18080e7          	jalr	-488(ra) # 80000c92 <kalloc>
    80002e82:	8aaa                	mv	s5,a0
    80002e84:	c945                	beqz	a0,80002f34 <usertrap+0x208>
    memmove(mem, (char *)pa, PGSIZE);
    80002e86:	6605                	lui	a2,0x1
    80002e88:	85ce                	mv	a1,s3
    80002e8a:	8556                	mv	a0,s5
    80002e8c:	ffffe097          	auipc	ra,0xffffe
    80002e90:	0a6080e7          	jalr	166(ra) # 80000f32 <memmove>
    uvmunmap(p->pagetable, PGROUNDDOWN(va), 1, 0);
    80002e94:	001007b7          	lui	a5,0x100
    80002e98:	17fd                	addi	a5,a5,-1 # fffff <_entry-0x7ff00001>
    80002e9a:	07b2                	slli	a5,a5,0xc
    80002e9c:	00fb7b33          	and	s6,s6,a5
    80002ea0:	4681                	li	a3,0
    80002ea2:	4605                	li	a2,1
    80002ea4:	85da                	mv	a1,s6
    80002ea6:	05093503          	ld	a0,80(s2)
    80002eaa:	ffffe097          	auipc	ra,0xffffe
    80002eae:	5be080e7          	jalr	1470(ra) # 80001468 <uvmunmap>
    if (mappages(p->pagetable, PGROUNDDOWN(va), PGSIZE, (uint64)mem, PTE_FLAGS(*pte) | PTE_W | PTE_X | PTE_R | PTE_U) != 0) {
    80002eb2:	000a3703          	ld	a4,0(s4)
    80002eb6:	3e177713          	andi	a4,a4,993
    80002eba:	01e76713          	ori	a4,a4,30
    80002ebe:	86d6                	mv	a3,s5
    80002ec0:	6605                	lui	a2,0x1
    80002ec2:	85da                	mv	a1,s6
    80002ec4:	05093503          	ld	a0,80(s2)
    80002ec8:	ffffe097          	auipc	ra,0xffffe
    80002ecc:	3da080e7          	jalr	986(ra) # 800012a2 <mappages>
    80002ed0:	e141                	bnez	a0,80002f50 <usertrap+0x224>
    decRefCount(pa);
    80002ed2:	0009851b          	sext.w	a0,s3
    80002ed6:	ffffe097          	auipc	ra,0xffffe
    80002eda:	bc0080e7          	jalr	-1088(ra) # 80000a96 <decRefCount>
    80002ede:	bf31                	j	80002dfa <usertrap+0xce>
      printf("handle_page_fault: Segmentation fault\n");
    80002ee0:	00005517          	auipc	a0,0x5
    80002ee4:	57050513          	addi	a0,a0,1392 # 80008450 <states.0+0x78>
    80002ee8:	ffffd097          	auipc	ra,0xffffd
    80002eec:	6b4080e7          	jalr	1716(ra) # 8000059c <printf>
      setkilled(p);
    80002ef0:	854a                	mv	a0,s2
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	7e0080e7          	jalr	2016(ra) # 800026d2 <setkilled>
    80002efa:	bf89                	j	80002e4c <usertrap+0x120>
      printf("handle_page_fault: pte == 0\n");
    80002efc:	00005517          	auipc	a0,0x5
    80002f00:	57c50513          	addi	a0,a0,1404 # 80008478 <states.0+0xa0>
    80002f04:	ffffd097          	auipc	ra,0xffffd
    80002f08:	698080e7          	jalr	1688(ra) # 8000059c <printf>
      setkilled(p);
    80002f0c:	854a                	mv	a0,s2
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	7c4080e7          	jalr	1988(ra) # 800026d2 <setkilled>
    80002f16:	b7a9                	j	80002e60 <usertrap+0x134>
      printf("handle_page_fault: cow not set\n");
    80002f18:	00005517          	auipc	a0,0x5
    80002f1c:	58050513          	addi	a0,a0,1408 # 80008498 <states.0+0xc0>
    80002f20:	ffffd097          	auipc	ra,0xffffd
    80002f24:	67c080e7          	jalr	1660(ra) # 8000059c <printf>
      setkilled(p);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	fffff097          	auipc	ra,0xfffff
    80002f2e:	7a8080e7          	jalr	1960(ra) # 800026d2 <setkilled>
    80002f32:	bf3d                	j	80002e70 <usertrap+0x144>
      printf("handle_page_fault: kalloc failed\n");
    80002f34:	00005517          	auipc	a0,0x5
    80002f38:	58450513          	addi	a0,a0,1412 # 800084b8 <states.0+0xe0>
    80002f3c:	ffffd097          	auipc	ra,0xffffd
    80002f40:	660080e7          	jalr	1632(ra) # 8000059c <printf>
      setkilled(p);
    80002f44:	854a                	mv	a0,s2
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	78c080e7          	jalr	1932(ra) # 800026d2 <setkilled>
    80002f4e:	bf25                	j	80002e86 <usertrap+0x15a>
      printf("handle_page_fault: mappages failed\n");
    80002f50:	00005517          	auipc	a0,0x5
    80002f54:	59050513          	addi	a0,a0,1424 # 800084e0 <states.0+0x108>
    80002f58:	ffffd097          	auipc	ra,0xffffd
    80002f5c:	644080e7          	jalr	1604(ra) # 8000059c <printf>
      kfree(mem);
    80002f60:	8556                	mv	a0,s5
    80002f62:	ffffe097          	auipc	ra,0xffffe
    80002f66:	bf0080e7          	jalr	-1040(ra) # 80000b52 <kfree>
      setkilled(p);
    80002f6a:	854a                	mv	a0,s2
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	766080e7          	jalr	1894(ra) # 800026d2 <setkilled>
    80002f74:	bfb9                	j	80002ed2 <usertrap+0x1a6>
  if(killed(p))
    80002f76:	8526                	mv	a0,s1
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	786080e7          	jalr	1926(ra) # 800026fe <killed>
    80002f80:	c901                	beqz	a0,80002f90 <usertrap+0x264>
    80002f82:	a011                	j	80002f86 <usertrap+0x25a>
    80002f84:	4901                	li	s2,0
    exit(-1);
    80002f86:	557d                	li	a0,-1
    80002f88:	fffff097          	auipc	ra,0xfffff
    80002f8c:	602080e7          	jalr	1538(ra) # 8000258a <exit>
  if(which_dev == 2)
    80002f90:	4789                	li	a5,2
    80002f92:	e6f91be3          	bne	s2,a5,80002e08 <usertrap+0xdc>
    yield();
    80002f96:	fffff097          	auipc	ra,0xfffff
    80002f9a:	484080e7          	jalr	1156(ra) # 8000241a <yield>
    80002f9e:	b5ad                	j	80002e08 <usertrap+0xdc>

0000000080002fa0 <kerneltrap>:
{
    80002fa0:	7179                	addi	sp,sp,-48
    80002fa2:	f406                	sd	ra,40(sp)
    80002fa4:	f022                	sd	s0,32(sp)
    80002fa6:	ec26                	sd	s1,24(sp)
    80002fa8:	e84a                	sd	s2,16(sp)
    80002faa:	e44e                	sd	s3,8(sp)
    80002fac:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fae:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fb2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fb6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002fba:	1004f793          	andi	a5,s1,256
    80002fbe:	cb85                	beqz	a5,80002fee <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fc0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fc4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002fc6:	ef85                	bnez	a5,80002ffe <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002fc8:	00000097          	auipc	ra,0x0
    80002fcc:	cc2080e7          	jalr	-830(ra) # 80002c8a <devintr>
    80002fd0:	cd1d                	beqz	a0,8000300e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fd2:	4789                	li	a5,2
    80002fd4:	06f50a63          	beq	a0,a5,80003048 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fd8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fdc:	10049073          	csrw	sstatus,s1
}
    80002fe0:	70a2                	ld	ra,40(sp)
    80002fe2:	7402                	ld	s0,32(sp)
    80002fe4:	64e2                	ld	s1,24(sp)
    80002fe6:	6942                	ld	s2,16(sp)
    80002fe8:	69a2                	ld	s3,8(sp)
    80002fea:	6145                	addi	sp,sp,48
    80002fec:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002fee:	00005517          	auipc	a0,0x5
    80002ff2:	56a50513          	addi	a0,a0,1386 # 80008558 <states.0+0x180>
    80002ff6:	ffffd097          	auipc	ra,0xffffd
    80002ffa:	54a080e7          	jalr	1354(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ffe:	00005517          	auipc	a0,0x5
    80003002:	58250513          	addi	a0,a0,1410 # 80008580 <states.0+0x1a8>
    80003006:	ffffd097          	auipc	ra,0xffffd
    8000300a:	53a080e7          	jalr	1338(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    8000300e:	85ce                	mv	a1,s3
    80003010:	00005517          	auipc	a0,0x5
    80003014:	59050513          	addi	a0,a0,1424 # 800085a0 <states.0+0x1c8>
    80003018:	ffffd097          	auipc	ra,0xffffd
    8000301c:	584080e7          	jalr	1412(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003020:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003024:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003028:	00005517          	auipc	a0,0x5
    8000302c:	58850513          	addi	a0,a0,1416 # 800085b0 <states.0+0x1d8>
    80003030:	ffffd097          	auipc	ra,0xffffd
    80003034:	56c080e7          	jalr	1388(ra) # 8000059c <printf>
    panic("kerneltrap");
    80003038:	00005517          	auipc	a0,0x5
    8000303c:	59050513          	addi	a0,a0,1424 # 800085c8 <states.0+0x1f0>
    80003040:	ffffd097          	auipc	ra,0xffffd
    80003044:	500080e7          	jalr	1280(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003048:	fffff097          	auipc	ra,0xfffff
    8000304c:	c60080e7          	jalr	-928(ra) # 80001ca8 <myproc>
    80003050:	d541                	beqz	a0,80002fd8 <kerneltrap+0x38>
    80003052:	fffff097          	auipc	ra,0xfffff
    80003056:	c56080e7          	jalr	-938(ra) # 80001ca8 <myproc>
    8000305a:	4d18                	lw	a4,24(a0)
    8000305c:	4791                	li	a5,4
    8000305e:	f6f71de3          	bne	a4,a5,80002fd8 <kerneltrap+0x38>
    yield();
    80003062:	fffff097          	auipc	ra,0xfffff
    80003066:	3b8080e7          	jalr	952(ra) # 8000241a <yield>
    8000306a:	b7bd                	j	80002fd8 <kerneltrap+0x38>

000000008000306c <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    8000306c:	1101                	addi	sp,sp,-32
    8000306e:	ec06                	sd	ra,24(sp)
    80003070:	e822                	sd	s0,16(sp)
    80003072:	e426                	sd	s1,8(sp)
    80003074:	1000                	addi	s0,sp,32
    80003076:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80003078:	fffff097          	auipc	ra,0xfffff
    8000307c:	c30080e7          	jalr	-976(ra) # 80001ca8 <myproc>
    switch (n)
    80003080:	4795                	li	a5,5
    80003082:	0497e163          	bltu	a5,s1,800030c4 <argraw+0x58>
    80003086:	048a                	slli	s1,s1,0x2
    80003088:	00005717          	auipc	a4,0x5
    8000308c:	57870713          	addi	a4,a4,1400 # 80008600 <states.0+0x228>
    80003090:	94ba                	add	s1,s1,a4
    80003092:	409c                	lw	a5,0(s1)
    80003094:	97ba                	add	a5,a5,a4
    80003096:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80003098:	6d3c                	ld	a5,88(a0)
    8000309a:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	64a2                	ld	s1,8(sp)
    800030a2:	6105                	addi	sp,sp,32
    800030a4:	8082                	ret
        return p->trapframe->a1;
    800030a6:	6d3c                	ld	a5,88(a0)
    800030a8:	7fa8                	ld	a0,120(a5)
    800030aa:	bfcd                	j	8000309c <argraw+0x30>
        return p->trapframe->a2;
    800030ac:	6d3c                	ld	a5,88(a0)
    800030ae:	63c8                	ld	a0,128(a5)
    800030b0:	b7f5                	j	8000309c <argraw+0x30>
        return p->trapframe->a3;
    800030b2:	6d3c                	ld	a5,88(a0)
    800030b4:	67c8                	ld	a0,136(a5)
    800030b6:	b7dd                	j	8000309c <argraw+0x30>
        return p->trapframe->a4;
    800030b8:	6d3c                	ld	a5,88(a0)
    800030ba:	6bc8                	ld	a0,144(a5)
    800030bc:	b7c5                	j	8000309c <argraw+0x30>
        return p->trapframe->a5;
    800030be:	6d3c                	ld	a5,88(a0)
    800030c0:	6fc8                	ld	a0,152(a5)
    800030c2:	bfe9                	j	8000309c <argraw+0x30>
    panic("argraw");
    800030c4:	00005517          	auipc	a0,0x5
    800030c8:	51450513          	addi	a0,a0,1300 # 800085d8 <states.0+0x200>
    800030cc:	ffffd097          	auipc	ra,0xffffd
    800030d0:	474080e7          	jalr	1140(ra) # 80000540 <panic>

00000000800030d4 <fetchaddr>:
{
    800030d4:	1101                	addi	sp,sp,-32
    800030d6:	ec06                	sd	ra,24(sp)
    800030d8:	e822                	sd	s0,16(sp)
    800030da:	e426                	sd	s1,8(sp)
    800030dc:	e04a                	sd	s2,0(sp)
    800030de:	1000                	addi	s0,sp,32
    800030e0:	84aa                	mv	s1,a0
    800030e2:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	bc4080e7          	jalr	-1084(ra) # 80001ca8 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800030ec:	653c                	ld	a5,72(a0)
    800030ee:	02f4f863          	bgeu	s1,a5,8000311e <fetchaddr+0x4a>
    800030f2:	00848713          	addi	a4,s1,8
    800030f6:	02e7e663          	bltu	a5,a4,80003122 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030fa:	46a1                	li	a3,8
    800030fc:	8626                	mv	a2,s1
    800030fe:	85ca                	mv	a1,s2
    80003100:	6928                	ld	a0,80(a0)
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	7f4080e7          	jalr	2036(ra) # 800018f6 <copyin>
    8000310a:	00a03533          	snez	a0,a0
    8000310e:	40a00533          	neg	a0,a0
}
    80003112:	60e2                	ld	ra,24(sp)
    80003114:	6442                	ld	s0,16(sp)
    80003116:	64a2                	ld	s1,8(sp)
    80003118:	6902                	ld	s2,0(sp)
    8000311a:	6105                	addi	sp,sp,32
    8000311c:	8082                	ret
        return -1;
    8000311e:	557d                	li	a0,-1
    80003120:	bfcd                	j	80003112 <fetchaddr+0x3e>
    80003122:	557d                	li	a0,-1
    80003124:	b7fd                	j	80003112 <fetchaddr+0x3e>

0000000080003126 <fetchstr>:
{
    80003126:	7179                	addi	sp,sp,-48
    80003128:	f406                	sd	ra,40(sp)
    8000312a:	f022                	sd	s0,32(sp)
    8000312c:	ec26                	sd	s1,24(sp)
    8000312e:	e84a                	sd	s2,16(sp)
    80003130:	e44e                	sd	s3,8(sp)
    80003132:	1800                	addi	s0,sp,48
    80003134:	892a                	mv	s2,a0
    80003136:	84ae                	mv	s1,a1
    80003138:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    8000313a:	fffff097          	auipc	ra,0xfffff
    8000313e:	b6e080e7          	jalr	-1170(ra) # 80001ca8 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003142:	86ce                	mv	a3,s3
    80003144:	864a                	mv	a2,s2
    80003146:	85a6                	mv	a1,s1
    80003148:	6928                	ld	a0,80(a0)
    8000314a:	fffff097          	auipc	ra,0xfffff
    8000314e:	83a080e7          	jalr	-1990(ra) # 80001984 <copyinstr>
    80003152:	00054e63          	bltz	a0,8000316e <fetchstr+0x48>
    return strlen(buf);
    80003156:	8526                	mv	a0,s1
    80003158:	ffffe097          	auipc	ra,0xffffe
    8000315c:	efa080e7          	jalr	-262(ra) # 80001052 <strlen>
}
    80003160:	70a2                	ld	ra,40(sp)
    80003162:	7402                	ld	s0,32(sp)
    80003164:	64e2                	ld	s1,24(sp)
    80003166:	6942                	ld	s2,16(sp)
    80003168:	69a2                	ld	s3,8(sp)
    8000316a:	6145                	addi	sp,sp,48
    8000316c:	8082                	ret
        return -1;
    8000316e:	557d                	li	a0,-1
    80003170:	bfc5                	j	80003160 <fetchstr+0x3a>

0000000080003172 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	1000                	addi	s0,sp,32
    8000317c:	84ae                	mv	s1,a1
    *ip = argraw(n);
    8000317e:	00000097          	auipc	ra,0x0
    80003182:	eee080e7          	jalr	-274(ra) # 8000306c <argraw>
    80003186:	c088                	sw	a0,0(s1)
}
    80003188:	60e2                	ld	ra,24(sp)
    8000318a:	6442                	ld	s0,16(sp)
    8000318c:	64a2                	ld	s1,8(sp)
    8000318e:	6105                	addi	sp,sp,32
    80003190:	8082                	ret

0000000080003192 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003192:	1101                	addi	sp,sp,-32
    80003194:	ec06                	sd	ra,24(sp)
    80003196:	e822                	sd	s0,16(sp)
    80003198:	e426                	sd	s1,8(sp)
    8000319a:	1000                	addi	s0,sp,32
    8000319c:	84ae                	mv	s1,a1
    *ip = argraw(n);
    8000319e:	00000097          	auipc	ra,0x0
    800031a2:	ece080e7          	jalr	-306(ra) # 8000306c <argraw>
    800031a6:	e088                	sd	a0,0(s1)
}
    800031a8:	60e2                	ld	ra,24(sp)
    800031aa:	6442                	ld	s0,16(sp)
    800031ac:	64a2                	ld	s1,8(sp)
    800031ae:	6105                	addi	sp,sp,32
    800031b0:	8082                	ret

00000000800031b2 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800031b2:	7179                	addi	sp,sp,-48
    800031b4:	f406                	sd	ra,40(sp)
    800031b6:	f022                	sd	s0,32(sp)
    800031b8:	ec26                	sd	s1,24(sp)
    800031ba:	e84a                	sd	s2,16(sp)
    800031bc:	1800                	addi	s0,sp,48
    800031be:	84ae                	mv	s1,a1
    800031c0:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    800031c2:	fd840593          	addi	a1,s0,-40
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	fcc080e7          	jalr	-52(ra) # 80003192 <argaddr>
    return fetchstr(addr, buf, max);
    800031ce:	864a                	mv	a2,s2
    800031d0:	85a6                	mv	a1,s1
    800031d2:	fd843503          	ld	a0,-40(s0)
    800031d6:	00000097          	auipc	ra,0x0
    800031da:	f50080e7          	jalr	-176(ra) # 80003126 <fetchstr>
}
    800031de:	70a2                	ld	ra,40(sp)
    800031e0:	7402                	ld	s0,32(sp)
    800031e2:	64e2                	ld	s1,24(sp)
    800031e4:	6942                	ld	s2,16(sp)
    800031e6:	6145                	addi	sp,sp,48
    800031e8:	8082                	ret

00000000800031ea <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    800031ea:	1101                	addi	sp,sp,-32
    800031ec:	ec06                	sd	ra,24(sp)
    800031ee:	e822                	sd	s0,16(sp)
    800031f0:	e426                	sd	s1,8(sp)
    800031f2:	e04a                	sd	s2,0(sp)
    800031f4:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    800031f6:	fffff097          	auipc	ra,0xfffff
    800031fa:	ab2080e7          	jalr	-1358(ra) # 80001ca8 <myproc>
    800031fe:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80003200:	05853903          	ld	s2,88(a0)
    80003204:	0a893783          	ld	a5,168(s2)
    80003208:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    8000320c:	37fd                	addiw	a5,a5,-1
    8000320e:	4765                	li	a4,25
    80003210:	00f76f63          	bltu	a4,a5,8000322e <syscall+0x44>
    80003214:	00369713          	slli	a4,a3,0x3
    80003218:	00005797          	auipc	a5,0x5
    8000321c:	40078793          	addi	a5,a5,1024 # 80008618 <syscalls>
    80003220:	97ba                	add	a5,a5,a4
    80003222:	639c                	ld	a5,0(a5)
    80003224:	c789                	beqz	a5,8000322e <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80003226:	9782                	jalr	a5
    80003228:	06a93823          	sd	a0,112(s2)
    8000322c:	a839                	j	8000324a <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    8000322e:	15848613          	addi	a2,s1,344
    80003232:	588c                	lw	a1,48(s1)
    80003234:	00005517          	auipc	a0,0x5
    80003238:	3ac50513          	addi	a0,a0,940 # 800085e0 <states.0+0x208>
    8000323c:	ffffd097          	auipc	ra,0xffffd
    80003240:	360080e7          	jalr	864(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80003244:	6cbc                	ld	a5,88(s1)
    80003246:	577d                	li	a4,-1
    80003248:	fbb8                	sd	a4,112(a5)
    }
}
    8000324a:	60e2                	ld	ra,24(sp)
    8000324c:	6442                	ld	s0,16(sp)
    8000324e:	64a2                	ld	s1,8(sp)
    80003250:	6902                	ld	s2,0(sp)
    80003252:	6105                	addi	sp,sp,32
    80003254:	8082                	ret

0000000080003256 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80003256:	1101                	addi	sp,sp,-32
    80003258:	ec06                	sd	ra,24(sp)
    8000325a:	e822                	sd	s0,16(sp)
    8000325c:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    8000325e:	fec40593          	addi	a1,s0,-20
    80003262:	4501                	li	a0,0
    80003264:	00000097          	auipc	ra,0x0
    80003268:	f0e080e7          	jalr	-242(ra) # 80003172 <argint>
    exit(n);
    8000326c:	fec42503          	lw	a0,-20(s0)
    80003270:	fffff097          	auipc	ra,0xfffff
    80003274:	31a080e7          	jalr	794(ra) # 8000258a <exit>
    return 0; // not reached
}
    80003278:	4501                	li	a0,0
    8000327a:	60e2                	ld	ra,24(sp)
    8000327c:	6442                	ld	s0,16(sp)
    8000327e:	6105                	addi	sp,sp,32
    80003280:	8082                	ret

0000000080003282 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003282:	1141                	addi	sp,sp,-16
    80003284:	e406                	sd	ra,8(sp)
    80003286:	e022                	sd	s0,0(sp)
    80003288:	0800                	addi	s0,sp,16
    return myproc()->pid;
    8000328a:	fffff097          	auipc	ra,0xfffff
    8000328e:	a1e080e7          	jalr	-1506(ra) # 80001ca8 <myproc>
}
    80003292:	5908                	lw	a0,48(a0)
    80003294:	60a2                	ld	ra,8(sp)
    80003296:	6402                	ld	s0,0(sp)
    80003298:	0141                	addi	sp,sp,16
    8000329a:	8082                	ret

000000008000329c <sys_fork>:

uint64
sys_fork(void)
{
    8000329c:	1141                	addi	sp,sp,-16
    8000329e:	e406                	sd	ra,8(sp)
    800032a0:	e022                	sd	s0,0(sp)
    800032a2:	0800                	addi	s0,sp,16
    return fork();
    800032a4:	fffff097          	auipc	ra,0xfffff
    800032a8:	f50080e7          	jalr	-176(ra) # 800021f4 <fork>
}
    800032ac:	60a2                	ld	ra,8(sp)
    800032ae:	6402                	ld	s0,0(sp)
    800032b0:	0141                	addi	sp,sp,16
    800032b2:	8082                	ret

00000000800032b4 <sys_wait>:

uint64
sys_wait(void)
{
    800032b4:	1101                	addi	sp,sp,-32
    800032b6:	ec06                	sd	ra,24(sp)
    800032b8:	e822                	sd	s0,16(sp)
    800032ba:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    800032bc:	fe840593          	addi	a1,s0,-24
    800032c0:	4501                	li	a0,0
    800032c2:	00000097          	auipc	ra,0x0
    800032c6:	ed0080e7          	jalr	-304(ra) # 80003192 <argaddr>
    return wait(p);
    800032ca:	fe843503          	ld	a0,-24(s0)
    800032ce:	fffff097          	auipc	ra,0xfffff
    800032d2:	462080e7          	jalr	1122(ra) # 80002730 <wait>
}
    800032d6:	60e2                	ld	ra,24(sp)
    800032d8:	6442                	ld	s0,16(sp)
    800032da:	6105                	addi	sp,sp,32
    800032dc:	8082                	ret

00000000800032de <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032de:	7179                	addi	sp,sp,-48
    800032e0:	f406                	sd	ra,40(sp)
    800032e2:	f022                	sd	s0,32(sp)
    800032e4:	ec26                	sd	s1,24(sp)
    800032e6:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800032e8:	fdc40593          	addi	a1,s0,-36
    800032ec:	4501                	li	a0,0
    800032ee:	00000097          	auipc	ra,0x0
    800032f2:	e84080e7          	jalr	-380(ra) # 80003172 <argint>
    addr = myproc()->sz;
    800032f6:	fffff097          	auipc	ra,0xfffff
    800032fa:	9b2080e7          	jalr	-1614(ra) # 80001ca8 <myproc>
    800032fe:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003300:	fdc42503          	lw	a0,-36(s0)
    80003304:	fffff097          	auipc	ra,0xfffff
    80003308:	cfe080e7          	jalr	-770(ra) # 80002002 <growproc>
    8000330c:	00054863          	bltz	a0,8000331c <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003310:	8526                	mv	a0,s1
    80003312:	70a2                	ld	ra,40(sp)
    80003314:	7402                	ld	s0,32(sp)
    80003316:	64e2                	ld	s1,24(sp)
    80003318:	6145                	addi	sp,sp,48
    8000331a:	8082                	ret
        return -1;
    8000331c:	54fd                	li	s1,-1
    8000331e:	bfcd                	j	80003310 <sys_sbrk+0x32>

0000000080003320 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003320:	7139                	addi	sp,sp,-64
    80003322:	fc06                	sd	ra,56(sp)
    80003324:	f822                	sd	s0,48(sp)
    80003326:	f426                	sd	s1,40(sp)
    80003328:	f04a                	sd	s2,32(sp)
    8000332a:	ec4e                	sd	s3,24(sp)
    8000332c:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    8000332e:	fcc40593          	addi	a1,s0,-52
    80003332:	4501                	li	a0,0
    80003334:	00000097          	auipc	ra,0x0
    80003338:	e3e080e7          	jalr	-450(ra) # 80003172 <argint>
    acquire(&tickslock);
    8000333c:	00034517          	auipc	a0,0x34
    80003340:	87450513          	addi	a0,a0,-1932 # 80036bb0 <tickslock>
    80003344:	ffffe097          	auipc	ra,0xffffe
    80003348:	a96080e7          	jalr	-1386(ra) # 80000dda <acquire>
    ticks0 = ticks;
    8000334c:	00005917          	auipc	s2,0x5
    80003350:	7c492903          	lw	s2,1988(s2) # 80008b10 <ticks>
    while (ticks - ticks0 < n)
    80003354:	fcc42783          	lw	a5,-52(s0)
    80003358:	cf9d                	beqz	a5,80003396 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    8000335a:	00034997          	auipc	s3,0x34
    8000335e:	85698993          	addi	s3,s3,-1962 # 80036bb0 <tickslock>
    80003362:	00005497          	auipc	s1,0x5
    80003366:	7ae48493          	addi	s1,s1,1966 # 80008b10 <ticks>
        if (killed(myproc()))
    8000336a:	fffff097          	auipc	ra,0xfffff
    8000336e:	93e080e7          	jalr	-1730(ra) # 80001ca8 <myproc>
    80003372:	fffff097          	auipc	ra,0xfffff
    80003376:	38c080e7          	jalr	908(ra) # 800026fe <killed>
    8000337a:	ed15                	bnez	a0,800033b6 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000337c:	85ce                	mv	a1,s3
    8000337e:	8526                	mv	a0,s1
    80003380:	fffff097          	auipc	ra,0xfffff
    80003384:	0d6080e7          	jalr	214(ra) # 80002456 <sleep>
    while (ticks - ticks0 < n)
    80003388:	409c                	lw	a5,0(s1)
    8000338a:	412787bb          	subw	a5,a5,s2
    8000338e:	fcc42703          	lw	a4,-52(s0)
    80003392:	fce7ece3          	bltu	a5,a4,8000336a <sys_sleep+0x4a>
    }
    release(&tickslock);
    80003396:	00034517          	auipc	a0,0x34
    8000339a:	81a50513          	addi	a0,a0,-2022 # 80036bb0 <tickslock>
    8000339e:	ffffe097          	auipc	ra,0xffffe
    800033a2:	af0080e7          	jalr	-1296(ra) # 80000e8e <release>
    return 0;
    800033a6:	4501                	li	a0,0
}
    800033a8:	70e2                	ld	ra,56(sp)
    800033aa:	7442                	ld	s0,48(sp)
    800033ac:	74a2                	ld	s1,40(sp)
    800033ae:	7902                	ld	s2,32(sp)
    800033b0:	69e2                	ld	s3,24(sp)
    800033b2:	6121                	addi	sp,sp,64
    800033b4:	8082                	ret
            release(&tickslock);
    800033b6:	00033517          	auipc	a0,0x33
    800033ba:	7fa50513          	addi	a0,a0,2042 # 80036bb0 <tickslock>
    800033be:	ffffe097          	auipc	ra,0xffffe
    800033c2:	ad0080e7          	jalr	-1328(ra) # 80000e8e <release>
            return -1;
    800033c6:	557d                	li	a0,-1
    800033c8:	b7c5                	j	800033a8 <sys_sleep+0x88>

00000000800033ca <sys_kill>:

uint64
sys_kill(void)
{
    800033ca:	1101                	addi	sp,sp,-32
    800033cc:	ec06                	sd	ra,24(sp)
    800033ce:	e822                	sd	s0,16(sp)
    800033d0:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800033d2:	fec40593          	addi	a1,s0,-20
    800033d6:	4501                	li	a0,0
    800033d8:	00000097          	auipc	ra,0x0
    800033dc:	d9a080e7          	jalr	-614(ra) # 80003172 <argint>
    return kill(pid);
    800033e0:	fec42503          	lw	a0,-20(s0)
    800033e4:	fffff097          	auipc	ra,0xfffff
    800033e8:	27c080e7          	jalr	636(ra) # 80002660 <kill>
}
    800033ec:	60e2                	ld	ra,24(sp)
    800033ee:	6442                	ld	s0,16(sp)
    800033f0:	6105                	addi	sp,sp,32
    800033f2:	8082                	ret

00000000800033f4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033f4:	1101                	addi	sp,sp,-32
    800033f6:	ec06                	sd	ra,24(sp)
    800033f8:	e822                	sd	s0,16(sp)
    800033fa:	e426                	sd	s1,8(sp)
    800033fc:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800033fe:	00033517          	auipc	a0,0x33
    80003402:	7b250513          	addi	a0,a0,1970 # 80036bb0 <tickslock>
    80003406:	ffffe097          	auipc	ra,0xffffe
    8000340a:	9d4080e7          	jalr	-1580(ra) # 80000dda <acquire>
    xticks = ticks;
    8000340e:	00005497          	auipc	s1,0x5
    80003412:	7024a483          	lw	s1,1794(s1) # 80008b10 <ticks>
    release(&tickslock);
    80003416:	00033517          	auipc	a0,0x33
    8000341a:	79a50513          	addi	a0,a0,1946 # 80036bb0 <tickslock>
    8000341e:	ffffe097          	auipc	ra,0xffffe
    80003422:	a70080e7          	jalr	-1424(ra) # 80000e8e <release>
    return xticks;
}
    80003426:	02049513          	slli	a0,s1,0x20
    8000342a:	9101                	srli	a0,a0,0x20
    8000342c:	60e2                	ld	ra,24(sp)
    8000342e:	6442                	ld	s0,16(sp)
    80003430:	64a2                	ld	s1,8(sp)
    80003432:	6105                	addi	sp,sp,32
    80003434:	8082                	ret

0000000080003436 <sys_ps>:

void *
sys_ps(void)
{
    80003436:	1101                	addi	sp,sp,-32
    80003438:	ec06                	sd	ra,24(sp)
    8000343a:	e822                	sd	s0,16(sp)
    8000343c:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    8000343e:	fe042623          	sw	zero,-20(s0)
    80003442:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003446:	fec40593          	addi	a1,s0,-20
    8000344a:	4501                	li	a0,0
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	d26080e7          	jalr	-730(ra) # 80003172 <argint>
    argint(1, &count);
    80003454:	fe840593          	addi	a1,s0,-24
    80003458:	4505                	li	a0,1
    8000345a:	00000097          	auipc	ra,0x0
    8000345e:	d18080e7          	jalr	-744(ra) # 80003172 <argint>
    return ps((uint8)start, (uint8)count);
    80003462:	fe844583          	lbu	a1,-24(s0)
    80003466:	fec44503          	lbu	a0,-20(s0)
    8000346a:	fffff097          	auipc	ra,0xfffff
    8000346e:	bf4080e7          	jalr	-1036(ra) # 8000205e <ps>
}
    80003472:	60e2                	ld	ra,24(sp)
    80003474:	6442                	ld	s0,16(sp)
    80003476:	6105                	addi	sp,sp,32
    80003478:	8082                	ret

000000008000347a <sys_schedls>:

uint64 sys_schedls(void)
{
    8000347a:	1141                	addi	sp,sp,-16
    8000347c:	e406                	sd	ra,8(sp)
    8000347e:	e022                	sd	s0,0(sp)
    80003480:	0800                	addi	s0,sp,16
    schedls();
    80003482:	fffff097          	auipc	ra,0xfffff
    80003486:	538080e7          	jalr	1336(ra) # 800029ba <schedls>
    return 0;
}
    8000348a:	4501                	li	a0,0
    8000348c:	60a2                	ld	ra,8(sp)
    8000348e:	6402                	ld	s0,0(sp)
    80003490:	0141                	addi	sp,sp,16
    80003492:	8082                	ret

0000000080003494 <sys_schedset>:

uint64 sys_schedset(void)
{
    80003494:	1101                	addi	sp,sp,-32
    80003496:	ec06                	sd	ra,24(sp)
    80003498:	e822                	sd	s0,16(sp)
    8000349a:	1000                	addi	s0,sp,32
    int id = 0;
    8000349c:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    800034a0:	fec40593          	addi	a1,s0,-20
    800034a4:	4501                	li	a0,0
    800034a6:	00000097          	auipc	ra,0x0
    800034aa:	ccc080e7          	jalr	-820(ra) # 80003172 <argint>
    schedset(id - 1);
    800034ae:	fec42503          	lw	a0,-20(s0)
    800034b2:	357d                	addiw	a0,a0,-1
    800034b4:	fffff097          	auipc	ra,0xfffff
    800034b8:	59c080e7          	jalr	1436(ra) # 80002a50 <schedset>
    return 0;
}
    800034bc:	4501                	li	a0,0
    800034be:	60e2                	ld	ra,24(sp)
    800034c0:	6442                	ld	s0,16(sp)
    800034c2:	6105                	addi	sp,sp,32
    800034c4:	8082                	ret

00000000800034c6 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    800034c6:	1101                	addi	sp,sp,-32
    800034c8:	ec06                	sd	ra,24(sp)
    800034ca:	e822                	sd	s0,16(sp)
    800034cc:	1000                	addi	s0,sp,32
    int pid;
    int va;

    
    argint(0, &va);
    800034ce:	fe840593          	addi	a1,s0,-24
    800034d2:	4501                	li	a0,0
    800034d4:	00000097          	auipc	ra,0x0
    800034d8:	c9e080e7          	jalr	-866(ra) # 80003172 <argint>
    
    
    argint(1, &pid);
    800034dc:	fec40593          	addi	a1,s0,-20
    800034e0:	4505                	li	a0,1
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	c90080e7          	jalr	-880(ra) # 80003172 <argint>

   // printf(" fetched from interrupts: va2pa: va = %s, pid = %s\n", va, pid);

    return va2pa(va, pid);
    800034ea:	fec42583          	lw	a1,-20(s0)
    800034ee:	fe842503          	lw	a0,-24(s0)
    800034f2:	fffff097          	auipc	ra,0xfffff
    800034f6:	5aa080e7          	jalr	1450(ra) # 80002a9c <va2pa>
}
    800034fa:	60e2                	ld	ra,24(sp)
    800034fc:	6442                	ld	s0,16(sp)
    800034fe:	6105                	addi	sp,sp,32
    80003500:	8082                	ret

0000000080003502 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003502:	1141                	addi	sp,sp,-16
    80003504:	e406                	sd	ra,8(sp)
    80003506:	e022                	sd	s0,0(sp)
    80003508:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    8000350a:	00005597          	auipc	a1,0x5
    8000350e:	5de5b583          	ld	a1,1502(a1) # 80008ae8 <FREE_PAGES>
    80003512:	00005517          	auipc	a0,0x5
    80003516:	0e650513          	addi	a0,a0,230 # 800085f8 <states.0+0x220>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	082080e7          	jalr	130(ra) # 8000059c <printf>
    return 0;
}
    80003522:	4501                	li	a0,0
    80003524:	60a2                	ld	ra,8(sp)
    80003526:	6402                	ld	s0,0(sp)
    80003528:	0141                	addi	sp,sp,16
    8000352a:	8082                	ret

000000008000352c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000352c:	7179                	addi	sp,sp,-48
    8000352e:	f406                	sd	ra,40(sp)
    80003530:	f022                	sd	s0,32(sp)
    80003532:	ec26                	sd	s1,24(sp)
    80003534:	e84a                	sd	s2,16(sp)
    80003536:	e44e                	sd	s3,8(sp)
    80003538:	e052                	sd	s4,0(sp)
    8000353a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000353c:	00005597          	auipc	a1,0x5
    80003540:	1b458593          	addi	a1,a1,436 # 800086f0 <syscalls+0xd8>
    80003544:	00033517          	auipc	a0,0x33
    80003548:	68450513          	addi	a0,a0,1668 # 80036bc8 <bcache>
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	7fe080e7          	jalr	2046(ra) # 80000d4a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003554:	0003b797          	auipc	a5,0x3b
    80003558:	67478793          	addi	a5,a5,1652 # 8003ebc8 <bcache+0x8000>
    8000355c:	0003c717          	auipc	a4,0x3c
    80003560:	8d470713          	addi	a4,a4,-1836 # 8003ee30 <bcache+0x8268>
    80003564:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003568:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000356c:	00033497          	auipc	s1,0x33
    80003570:	67448493          	addi	s1,s1,1652 # 80036be0 <bcache+0x18>
    b->next = bcache.head.next;
    80003574:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003576:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003578:	00005a17          	auipc	s4,0x5
    8000357c:	180a0a13          	addi	s4,s4,384 # 800086f8 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003580:	2b893783          	ld	a5,696(s2)
    80003584:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003586:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000358a:	85d2                	mv	a1,s4
    8000358c:	01048513          	addi	a0,s1,16
    80003590:	00001097          	auipc	ra,0x1
    80003594:	4c8080e7          	jalr	1224(ra) # 80004a58 <initsleeplock>
    bcache.head.next->prev = b;
    80003598:	2b893783          	ld	a5,696(s2)
    8000359c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000359e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035a2:	45848493          	addi	s1,s1,1112
    800035a6:	fd349de3          	bne	s1,s3,80003580 <binit+0x54>
  }
}
    800035aa:	70a2                	ld	ra,40(sp)
    800035ac:	7402                	ld	s0,32(sp)
    800035ae:	64e2                	ld	s1,24(sp)
    800035b0:	6942                	ld	s2,16(sp)
    800035b2:	69a2                	ld	s3,8(sp)
    800035b4:	6a02                	ld	s4,0(sp)
    800035b6:	6145                	addi	sp,sp,48
    800035b8:	8082                	ret

00000000800035ba <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035ba:	7179                	addi	sp,sp,-48
    800035bc:	f406                	sd	ra,40(sp)
    800035be:	f022                	sd	s0,32(sp)
    800035c0:	ec26                	sd	s1,24(sp)
    800035c2:	e84a                	sd	s2,16(sp)
    800035c4:	e44e                	sd	s3,8(sp)
    800035c6:	1800                	addi	s0,sp,48
    800035c8:	892a                	mv	s2,a0
    800035ca:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800035cc:	00033517          	auipc	a0,0x33
    800035d0:	5fc50513          	addi	a0,a0,1532 # 80036bc8 <bcache>
    800035d4:	ffffe097          	auipc	ra,0xffffe
    800035d8:	806080e7          	jalr	-2042(ra) # 80000dda <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035dc:	0003c497          	auipc	s1,0x3c
    800035e0:	8a44b483          	ld	s1,-1884(s1) # 8003ee80 <bcache+0x82b8>
    800035e4:	0003c797          	auipc	a5,0x3c
    800035e8:	84c78793          	addi	a5,a5,-1972 # 8003ee30 <bcache+0x8268>
    800035ec:	02f48f63          	beq	s1,a5,8000362a <bread+0x70>
    800035f0:	873e                	mv	a4,a5
    800035f2:	a021                	j	800035fa <bread+0x40>
    800035f4:	68a4                	ld	s1,80(s1)
    800035f6:	02e48a63          	beq	s1,a4,8000362a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035fa:	449c                	lw	a5,8(s1)
    800035fc:	ff279ce3          	bne	a5,s2,800035f4 <bread+0x3a>
    80003600:	44dc                	lw	a5,12(s1)
    80003602:	ff3799e3          	bne	a5,s3,800035f4 <bread+0x3a>
      b->refcnt++;
    80003606:	40bc                	lw	a5,64(s1)
    80003608:	2785                	addiw	a5,a5,1
    8000360a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000360c:	00033517          	auipc	a0,0x33
    80003610:	5bc50513          	addi	a0,a0,1468 # 80036bc8 <bcache>
    80003614:	ffffe097          	auipc	ra,0xffffe
    80003618:	87a080e7          	jalr	-1926(ra) # 80000e8e <release>
      acquiresleep(&b->lock);
    8000361c:	01048513          	addi	a0,s1,16
    80003620:	00001097          	auipc	ra,0x1
    80003624:	472080e7          	jalr	1138(ra) # 80004a92 <acquiresleep>
      return b;
    80003628:	a8b9                	j	80003686 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000362a:	0003c497          	auipc	s1,0x3c
    8000362e:	84e4b483          	ld	s1,-1970(s1) # 8003ee78 <bcache+0x82b0>
    80003632:	0003b797          	auipc	a5,0x3b
    80003636:	7fe78793          	addi	a5,a5,2046 # 8003ee30 <bcache+0x8268>
    8000363a:	00f48863          	beq	s1,a5,8000364a <bread+0x90>
    8000363e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003640:	40bc                	lw	a5,64(s1)
    80003642:	cf81                	beqz	a5,8000365a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003644:	64a4                	ld	s1,72(s1)
    80003646:	fee49de3          	bne	s1,a4,80003640 <bread+0x86>
  panic("bget: no buffers");
    8000364a:	00005517          	auipc	a0,0x5
    8000364e:	0b650513          	addi	a0,a0,182 # 80008700 <syscalls+0xe8>
    80003652:	ffffd097          	auipc	ra,0xffffd
    80003656:	eee080e7          	jalr	-274(ra) # 80000540 <panic>
      b->dev = dev;
    8000365a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000365e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003662:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003666:	4785                	li	a5,1
    80003668:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000366a:	00033517          	auipc	a0,0x33
    8000366e:	55e50513          	addi	a0,a0,1374 # 80036bc8 <bcache>
    80003672:	ffffe097          	auipc	ra,0xffffe
    80003676:	81c080e7          	jalr	-2020(ra) # 80000e8e <release>
      acquiresleep(&b->lock);
    8000367a:	01048513          	addi	a0,s1,16
    8000367e:	00001097          	auipc	ra,0x1
    80003682:	414080e7          	jalr	1044(ra) # 80004a92 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003686:	409c                	lw	a5,0(s1)
    80003688:	cb89                	beqz	a5,8000369a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000368a:	8526                	mv	a0,s1
    8000368c:	70a2                	ld	ra,40(sp)
    8000368e:	7402                	ld	s0,32(sp)
    80003690:	64e2                	ld	s1,24(sp)
    80003692:	6942                	ld	s2,16(sp)
    80003694:	69a2                	ld	s3,8(sp)
    80003696:	6145                	addi	sp,sp,48
    80003698:	8082                	ret
    virtio_disk_rw(b, 0);
    8000369a:	4581                	li	a1,0
    8000369c:	8526                	mv	a0,s1
    8000369e:	00003097          	auipc	ra,0x3
    800036a2:	fe4080e7          	jalr	-28(ra) # 80006682 <virtio_disk_rw>
    b->valid = 1;
    800036a6:	4785                	li	a5,1
    800036a8:	c09c                	sw	a5,0(s1)
  return b;
    800036aa:	b7c5                	j	8000368a <bread+0xd0>

00000000800036ac <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036ac:	1101                	addi	sp,sp,-32
    800036ae:	ec06                	sd	ra,24(sp)
    800036b0:	e822                	sd	s0,16(sp)
    800036b2:	e426                	sd	s1,8(sp)
    800036b4:	1000                	addi	s0,sp,32
    800036b6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036b8:	0541                	addi	a0,a0,16
    800036ba:	00001097          	auipc	ra,0x1
    800036be:	472080e7          	jalr	1138(ra) # 80004b2c <holdingsleep>
    800036c2:	cd01                	beqz	a0,800036da <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036c4:	4585                	li	a1,1
    800036c6:	8526                	mv	a0,s1
    800036c8:	00003097          	auipc	ra,0x3
    800036cc:	fba080e7          	jalr	-70(ra) # 80006682 <virtio_disk_rw>
}
    800036d0:	60e2                	ld	ra,24(sp)
    800036d2:	6442                	ld	s0,16(sp)
    800036d4:	64a2                	ld	s1,8(sp)
    800036d6:	6105                	addi	sp,sp,32
    800036d8:	8082                	ret
    panic("bwrite");
    800036da:	00005517          	auipc	a0,0x5
    800036de:	03e50513          	addi	a0,a0,62 # 80008718 <syscalls+0x100>
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	e5e080e7          	jalr	-418(ra) # 80000540 <panic>

00000000800036ea <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036ea:	1101                	addi	sp,sp,-32
    800036ec:	ec06                	sd	ra,24(sp)
    800036ee:	e822                	sd	s0,16(sp)
    800036f0:	e426                	sd	s1,8(sp)
    800036f2:	e04a                	sd	s2,0(sp)
    800036f4:	1000                	addi	s0,sp,32
    800036f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036f8:	01050913          	addi	s2,a0,16
    800036fc:	854a                	mv	a0,s2
    800036fe:	00001097          	auipc	ra,0x1
    80003702:	42e080e7          	jalr	1070(ra) # 80004b2c <holdingsleep>
    80003706:	c92d                	beqz	a0,80003778 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003708:	854a                	mv	a0,s2
    8000370a:	00001097          	auipc	ra,0x1
    8000370e:	3de080e7          	jalr	990(ra) # 80004ae8 <releasesleep>

  acquire(&bcache.lock);
    80003712:	00033517          	auipc	a0,0x33
    80003716:	4b650513          	addi	a0,a0,1206 # 80036bc8 <bcache>
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	6c0080e7          	jalr	1728(ra) # 80000dda <acquire>
  b->refcnt--;
    80003722:	40bc                	lw	a5,64(s1)
    80003724:	37fd                	addiw	a5,a5,-1
    80003726:	0007871b          	sext.w	a4,a5
    8000372a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000372c:	eb05                	bnez	a4,8000375c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000372e:	68bc                	ld	a5,80(s1)
    80003730:	64b8                	ld	a4,72(s1)
    80003732:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003734:	64bc                	ld	a5,72(s1)
    80003736:	68b8                	ld	a4,80(s1)
    80003738:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000373a:	0003b797          	auipc	a5,0x3b
    8000373e:	48e78793          	addi	a5,a5,1166 # 8003ebc8 <bcache+0x8000>
    80003742:	2b87b703          	ld	a4,696(a5)
    80003746:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003748:	0003b717          	auipc	a4,0x3b
    8000374c:	6e870713          	addi	a4,a4,1768 # 8003ee30 <bcache+0x8268>
    80003750:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003752:	2b87b703          	ld	a4,696(a5)
    80003756:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003758:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000375c:	00033517          	auipc	a0,0x33
    80003760:	46c50513          	addi	a0,a0,1132 # 80036bc8 <bcache>
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	72a080e7          	jalr	1834(ra) # 80000e8e <release>
}
    8000376c:	60e2                	ld	ra,24(sp)
    8000376e:	6442                	ld	s0,16(sp)
    80003770:	64a2                	ld	s1,8(sp)
    80003772:	6902                	ld	s2,0(sp)
    80003774:	6105                	addi	sp,sp,32
    80003776:	8082                	ret
    panic("brelse");
    80003778:	00005517          	auipc	a0,0x5
    8000377c:	fa850513          	addi	a0,a0,-88 # 80008720 <syscalls+0x108>
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	dc0080e7          	jalr	-576(ra) # 80000540 <panic>

0000000080003788 <bpin>:

void
bpin(struct buf *b) {
    80003788:	1101                	addi	sp,sp,-32
    8000378a:	ec06                	sd	ra,24(sp)
    8000378c:	e822                	sd	s0,16(sp)
    8000378e:	e426                	sd	s1,8(sp)
    80003790:	1000                	addi	s0,sp,32
    80003792:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003794:	00033517          	auipc	a0,0x33
    80003798:	43450513          	addi	a0,a0,1076 # 80036bc8 <bcache>
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	63e080e7          	jalr	1598(ra) # 80000dda <acquire>
  b->refcnt++;
    800037a4:	40bc                	lw	a5,64(s1)
    800037a6:	2785                	addiw	a5,a5,1
    800037a8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037aa:	00033517          	auipc	a0,0x33
    800037ae:	41e50513          	addi	a0,a0,1054 # 80036bc8 <bcache>
    800037b2:	ffffd097          	auipc	ra,0xffffd
    800037b6:	6dc080e7          	jalr	1756(ra) # 80000e8e <release>
}
    800037ba:	60e2                	ld	ra,24(sp)
    800037bc:	6442                	ld	s0,16(sp)
    800037be:	64a2                	ld	s1,8(sp)
    800037c0:	6105                	addi	sp,sp,32
    800037c2:	8082                	ret

00000000800037c4 <bunpin>:

void
bunpin(struct buf *b) {
    800037c4:	1101                	addi	sp,sp,-32
    800037c6:	ec06                	sd	ra,24(sp)
    800037c8:	e822                	sd	s0,16(sp)
    800037ca:	e426                	sd	s1,8(sp)
    800037cc:	1000                	addi	s0,sp,32
    800037ce:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037d0:	00033517          	auipc	a0,0x33
    800037d4:	3f850513          	addi	a0,a0,1016 # 80036bc8 <bcache>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	602080e7          	jalr	1538(ra) # 80000dda <acquire>
  b->refcnt--;
    800037e0:	40bc                	lw	a5,64(s1)
    800037e2:	37fd                	addiw	a5,a5,-1
    800037e4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037e6:	00033517          	auipc	a0,0x33
    800037ea:	3e250513          	addi	a0,a0,994 # 80036bc8 <bcache>
    800037ee:	ffffd097          	auipc	ra,0xffffd
    800037f2:	6a0080e7          	jalr	1696(ra) # 80000e8e <release>
}
    800037f6:	60e2                	ld	ra,24(sp)
    800037f8:	6442                	ld	s0,16(sp)
    800037fa:	64a2                	ld	s1,8(sp)
    800037fc:	6105                	addi	sp,sp,32
    800037fe:	8082                	ret

0000000080003800 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003800:	1101                	addi	sp,sp,-32
    80003802:	ec06                	sd	ra,24(sp)
    80003804:	e822                	sd	s0,16(sp)
    80003806:	e426                	sd	s1,8(sp)
    80003808:	e04a                	sd	s2,0(sp)
    8000380a:	1000                	addi	s0,sp,32
    8000380c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000380e:	00d5d59b          	srliw	a1,a1,0xd
    80003812:	0003c797          	auipc	a5,0x3c
    80003816:	a927a783          	lw	a5,-1390(a5) # 8003f2a4 <sb+0x1c>
    8000381a:	9dbd                	addw	a1,a1,a5
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	d9e080e7          	jalr	-610(ra) # 800035ba <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003824:	0074f713          	andi	a4,s1,7
    80003828:	4785                	li	a5,1
    8000382a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000382e:	14ce                	slli	s1,s1,0x33
    80003830:	90d9                	srli	s1,s1,0x36
    80003832:	00950733          	add	a4,a0,s1
    80003836:	05874703          	lbu	a4,88(a4)
    8000383a:	00e7f6b3          	and	a3,a5,a4
    8000383e:	c69d                	beqz	a3,8000386c <bfree+0x6c>
    80003840:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003842:	94aa                	add	s1,s1,a0
    80003844:	fff7c793          	not	a5,a5
    80003848:	8f7d                	and	a4,a4,a5
    8000384a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000384e:	00001097          	auipc	ra,0x1
    80003852:	126080e7          	jalr	294(ra) # 80004974 <log_write>
  brelse(bp);
    80003856:	854a                	mv	a0,s2
    80003858:	00000097          	auipc	ra,0x0
    8000385c:	e92080e7          	jalr	-366(ra) # 800036ea <brelse>
}
    80003860:	60e2                	ld	ra,24(sp)
    80003862:	6442                	ld	s0,16(sp)
    80003864:	64a2                	ld	s1,8(sp)
    80003866:	6902                	ld	s2,0(sp)
    80003868:	6105                	addi	sp,sp,32
    8000386a:	8082                	ret
    panic("freeing free block");
    8000386c:	00005517          	auipc	a0,0x5
    80003870:	ebc50513          	addi	a0,a0,-324 # 80008728 <syscalls+0x110>
    80003874:	ffffd097          	auipc	ra,0xffffd
    80003878:	ccc080e7          	jalr	-820(ra) # 80000540 <panic>

000000008000387c <balloc>:
{
    8000387c:	711d                	addi	sp,sp,-96
    8000387e:	ec86                	sd	ra,88(sp)
    80003880:	e8a2                	sd	s0,80(sp)
    80003882:	e4a6                	sd	s1,72(sp)
    80003884:	e0ca                	sd	s2,64(sp)
    80003886:	fc4e                	sd	s3,56(sp)
    80003888:	f852                	sd	s4,48(sp)
    8000388a:	f456                	sd	s5,40(sp)
    8000388c:	f05a                	sd	s6,32(sp)
    8000388e:	ec5e                	sd	s7,24(sp)
    80003890:	e862                	sd	s8,16(sp)
    80003892:	e466                	sd	s9,8(sp)
    80003894:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003896:	0003c797          	auipc	a5,0x3c
    8000389a:	9f67a783          	lw	a5,-1546(a5) # 8003f28c <sb+0x4>
    8000389e:	cff5                	beqz	a5,8000399a <balloc+0x11e>
    800038a0:	8baa                	mv	s7,a0
    800038a2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800038a4:	0003cb17          	auipc	s6,0x3c
    800038a8:	9e4b0b13          	addi	s6,s6,-1564 # 8003f288 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038ac:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038ae:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038b0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038b2:	6c89                	lui	s9,0x2
    800038b4:	a061                	j	8000393c <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038b6:	97ca                	add	a5,a5,s2
    800038b8:	8e55                	or	a2,a2,a3
    800038ba:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800038be:	854a                	mv	a0,s2
    800038c0:	00001097          	auipc	ra,0x1
    800038c4:	0b4080e7          	jalr	180(ra) # 80004974 <log_write>
        brelse(bp);
    800038c8:	854a                	mv	a0,s2
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	e20080e7          	jalr	-480(ra) # 800036ea <brelse>
  bp = bread(dev, bno);
    800038d2:	85a6                	mv	a1,s1
    800038d4:	855e                	mv	a0,s7
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	ce4080e7          	jalr	-796(ra) # 800035ba <bread>
    800038de:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038e0:	40000613          	li	a2,1024
    800038e4:	4581                	li	a1,0
    800038e6:	05850513          	addi	a0,a0,88
    800038ea:	ffffd097          	auipc	ra,0xffffd
    800038ee:	5ec080e7          	jalr	1516(ra) # 80000ed6 <memset>
  log_write(bp);
    800038f2:	854a                	mv	a0,s2
    800038f4:	00001097          	auipc	ra,0x1
    800038f8:	080080e7          	jalr	128(ra) # 80004974 <log_write>
  brelse(bp);
    800038fc:	854a                	mv	a0,s2
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	dec080e7          	jalr	-532(ra) # 800036ea <brelse>
}
    80003906:	8526                	mv	a0,s1
    80003908:	60e6                	ld	ra,88(sp)
    8000390a:	6446                	ld	s0,80(sp)
    8000390c:	64a6                	ld	s1,72(sp)
    8000390e:	6906                	ld	s2,64(sp)
    80003910:	79e2                	ld	s3,56(sp)
    80003912:	7a42                	ld	s4,48(sp)
    80003914:	7aa2                	ld	s5,40(sp)
    80003916:	7b02                	ld	s6,32(sp)
    80003918:	6be2                	ld	s7,24(sp)
    8000391a:	6c42                	ld	s8,16(sp)
    8000391c:	6ca2                	ld	s9,8(sp)
    8000391e:	6125                	addi	sp,sp,96
    80003920:	8082                	ret
    brelse(bp);
    80003922:	854a                	mv	a0,s2
    80003924:	00000097          	auipc	ra,0x0
    80003928:	dc6080e7          	jalr	-570(ra) # 800036ea <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000392c:	015c87bb          	addw	a5,s9,s5
    80003930:	00078a9b          	sext.w	s5,a5
    80003934:	004b2703          	lw	a4,4(s6)
    80003938:	06eaf163          	bgeu	s5,a4,8000399a <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000393c:	41fad79b          	sraiw	a5,s5,0x1f
    80003940:	0137d79b          	srliw	a5,a5,0x13
    80003944:	015787bb          	addw	a5,a5,s5
    80003948:	40d7d79b          	sraiw	a5,a5,0xd
    8000394c:	01cb2583          	lw	a1,28(s6)
    80003950:	9dbd                	addw	a1,a1,a5
    80003952:	855e                	mv	a0,s7
    80003954:	00000097          	auipc	ra,0x0
    80003958:	c66080e7          	jalr	-922(ra) # 800035ba <bread>
    8000395c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000395e:	004b2503          	lw	a0,4(s6)
    80003962:	000a849b          	sext.w	s1,s5
    80003966:	8762                	mv	a4,s8
    80003968:	faa4fde3          	bgeu	s1,a0,80003922 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000396c:	00777693          	andi	a3,a4,7
    80003970:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003974:	41f7579b          	sraiw	a5,a4,0x1f
    80003978:	01d7d79b          	srliw	a5,a5,0x1d
    8000397c:	9fb9                	addw	a5,a5,a4
    8000397e:	4037d79b          	sraiw	a5,a5,0x3
    80003982:	00f90633          	add	a2,s2,a5
    80003986:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000398a:	00c6f5b3          	and	a1,a3,a2
    8000398e:	d585                	beqz	a1,800038b6 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003990:	2705                	addiw	a4,a4,1
    80003992:	2485                	addiw	s1,s1,1
    80003994:	fd471ae3          	bne	a4,s4,80003968 <balloc+0xec>
    80003998:	b769                	j	80003922 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000399a:	00005517          	auipc	a0,0x5
    8000399e:	da650513          	addi	a0,a0,-602 # 80008740 <syscalls+0x128>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	bfa080e7          	jalr	-1030(ra) # 8000059c <printf>
  return 0;
    800039aa:	4481                	li	s1,0
    800039ac:	bfa9                	j	80003906 <balloc+0x8a>

00000000800039ae <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800039ae:	7179                	addi	sp,sp,-48
    800039b0:	f406                	sd	ra,40(sp)
    800039b2:	f022                	sd	s0,32(sp)
    800039b4:	ec26                	sd	s1,24(sp)
    800039b6:	e84a                	sd	s2,16(sp)
    800039b8:	e44e                	sd	s3,8(sp)
    800039ba:	e052                	sd	s4,0(sp)
    800039bc:	1800                	addi	s0,sp,48
    800039be:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039c0:	47ad                	li	a5,11
    800039c2:	02b7e863          	bltu	a5,a1,800039f2 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800039c6:	02059793          	slli	a5,a1,0x20
    800039ca:	01e7d593          	srli	a1,a5,0x1e
    800039ce:	00b504b3          	add	s1,a0,a1
    800039d2:	0504a903          	lw	s2,80(s1)
    800039d6:	06091e63          	bnez	s2,80003a52 <bmap+0xa4>
      addr = balloc(ip->dev);
    800039da:	4108                	lw	a0,0(a0)
    800039dc:	00000097          	auipc	ra,0x0
    800039e0:	ea0080e7          	jalr	-352(ra) # 8000387c <balloc>
    800039e4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039e8:	06090563          	beqz	s2,80003a52 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800039ec:	0524a823          	sw	s2,80(s1)
    800039f0:	a08d                	j	80003a52 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039f2:	ff45849b          	addiw	s1,a1,-12
    800039f6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039fa:	0ff00793          	li	a5,255
    800039fe:	08e7e563          	bltu	a5,a4,80003a88 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003a02:	08052903          	lw	s2,128(a0)
    80003a06:	00091d63          	bnez	s2,80003a20 <bmap+0x72>
      addr = balloc(ip->dev);
    80003a0a:	4108                	lw	a0,0(a0)
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	e70080e7          	jalr	-400(ra) # 8000387c <balloc>
    80003a14:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a18:	02090d63          	beqz	s2,80003a52 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a1c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003a20:	85ca                	mv	a1,s2
    80003a22:	0009a503          	lw	a0,0(s3)
    80003a26:	00000097          	auipc	ra,0x0
    80003a2a:	b94080e7          	jalr	-1132(ra) # 800035ba <bread>
    80003a2e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a30:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a34:	02049713          	slli	a4,s1,0x20
    80003a38:	01e75593          	srli	a1,a4,0x1e
    80003a3c:	00b784b3          	add	s1,a5,a1
    80003a40:	0004a903          	lw	s2,0(s1)
    80003a44:	02090063          	beqz	s2,80003a64 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003a48:	8552                	mv	a0,s4
    80003a4a:	00000097          	auipc	ra,0x0
    80003a4e:	ca0080e7          	jalr	-864(ra) # 800036ea <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a52:	854a                	mv	a0,s2
    80003a54:	70a2                	ld	ra,40(sp)
    80003a56:	7402                	ld	s0,32(sp)
    80003a58:	64e2                	ld	s1,24(sp)
    80003a5a:	6942                	ld	s2,16(sp)
    80003a5c:	69a2                	ld	s3,8(sp)
    80003a5e:	6a02                	ld	s4,0(sp)
    80003a60:	6145                	addi	sp,sp,48
    80003a62:	8082                	ret
      addr = balloc(ip->dev);
    80003a64:	0009a503          	lw	a0,0(s3)
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	e14080e7          	jalr	-492(ra) # 8000387c <balloc>
    80003a70:	0005091b          	sext.w	s2,a0
      if(addr){
    80003a74:	fc090ae3          	beqz	s2,80003a48 <bmap+0x9a>
        a[bn] = addr;
    80003a78:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a7c:	8552                	mv	a0,s4
    80003a7e:	00001097          	auipc	ra,0x1
    80003a82:	ef6080e7          	jalr	-266(ra) # 80004974 <log_write>
    80003a86:	b7c9                	j	80003a48 <bmap+0x9a>
  panic("bmap: out of range");
    80003a88:	00005517          	auipc	a0,0x5
    80003a8c:	cd050513          	addi	a0,a0,-816 # 80008758 <syscalls+0x140>
    80003a90:	ffffd097          	auipc	ra,0xffffd
    80003a94:	ab0080e7          	jalr	-1360(ra) # 80000540 <panic>

0000000080003a98 <iget>:
{
    80003a98:	7179                	addi	sp,sp,-48
    80003a9a:	f406                	sd	ra,40(sp)
    80003a9c:	f022                	sd	s0,32(sp)
    80003a9e:	ec26                	sd	s1,24(sp)
    80003aa0:	e84a                	sd	s2,16(sp)
    80003aa2:	e44e                	sd	s3,8(sp)
    80003aa4:	e052                	sd	s4,0(sp)
    80003aa6:	1800                	addi	s0,sp,48
    80003aa8:	89aa                	mv	s3,a0
    80003aaa:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003aac:	0003b517          	auipc	a0,0x3b
    80003ab0:	7fc50513          	addi	a0,a0,2044 # 8003f2a8 <itable>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	326080e7          	jalr	806(ra) # 80000dda <acquire>
  empty = 0;
    80003abc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003abe:	0003c497          	auipc	s1,0x3c
    80003ac2:	80248493          	addi	s1,s1,-2046 # 8003f2c0 <itable+0x18>
    80003ac6:	0003d697          	auipc	a3,0x3d
    80003aca:	28a68693          	addi	a3,a3,650 # 80040d50 <log>
    80003ace:	a039                	j	80003adc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ad0:	02090b63          	beqz	s2,80003b06 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ad4:	08848493          	addi	s1,s1,136
    80003ad8:	02d48a63          	beq	s1,a3,80003b0c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003adc:	449c                	lw	a5,8(s1)
    80003ade:	fef059e3          	blez	a5,80003ad0 <iget+0x38>
    80003ae2:	4098                	lw	a4,0(s1)
    80003ae4:	ff3716e3          	bne	a4,s3,80003ad0 <iget+0x38>
    80003ae8:	40d8                	lw	a4,4(s1)
    80003aea:	ff4713e3          	bne	a4,s4,80003ad0 <iget+0x38>
      ip->ref++;
    80003aee:	2785                	addiw	a5,a5,1
    80003af0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003af2:	0003b517          	auipc	a0,0x3b
    80003af6:	7b650513          	addi	a0,a0,1974 # 8003f2a8 <itable>
    80003afa:	ffffd097          	auipc	ra,0xffffd
    80003afe:	394080e7          	jalr	916(ra) # 80000e8e <release>
      return ip;
    80003b02:	8926                	mv	s2,s1
    80003b04:	a03d                	j	80003b32 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b06:	f7f9                	bnez	a5,80003ad4 <iget+0x3c>
    80003b08:	8926                	mv	s2,s1
    80003b0a:	b7e9                	j	80003ad4 <iget+0x3c>
  if(empty == 0)
    80003b0c:	02090c63          	beqz	s2,80003b44 <iget+0xac>
  ip->dev = dev;
    80003b10:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b14:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b18:	4785                	li	a5,1
    80003b1a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b1e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b22:	0003b517          	auipc	a0,0x3b
    80003b26:	78650513          	addi	a0,a0,1926 # 8003f2a8 <itable>
    80003b2a:	ffffd097          	auipc	ra,0xffffd
    80003b2e:	364080e7          	jalr	868(ra) # 80000e8e <release>
}
    80003b32:	854a                	mv	a0,s2
    80003b34:	70a2                	ld	ra,40(sp)
    80003b36:	7402                	ld	s0,32(sp)
    80003b38:	64e2                	ld	s1,24(sp)
    80003b3a:	6942                	ld	s2,16(sp)
    80003b3c:	69a2                	ld	s3,8(sp)
    80003b3e:	6a02                	ld	s4,0(sp)
    80003b40:	6145                	addi	sp,sp,48
    80003b42:	8082                	ret
    panic("iget: no inodes");
    80003b44:	00005517          	auipc	a0,0x5
    80003b48:	c2c50513          	addi	a0,a0,-980 # 80008770 <syscalls+0x158>
    80003b4c:	ffffd097          	auipc	ra,0xffffd
    80003b50:	9f4080e7          	jalr	-1548(ra) # 80000540 <panic>

0000000080003b54 <fsinit>:
fsinit(int dev) {
    80003b54:	7179                	addi	sp,sp,-48
    80003b56:	f406                	sd	ra,40(sp)
    80003b58:	f022                	sd	s0,32(sp)
    80003b5a:	ec26                	sd	s1,24(sp)
    80003b5c:	e84a                	sd	s2,16(sp)
    80003b5e:	e44e                	sd	s3,8(sp)
    80003b60:	1800                	addi	s0,sp,48
    80003b62:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b64:	4585                	li	a1,1
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	a54080e7          	jalr	-1452(ra) # 800035ba <bread>
    80003b6e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b70:	0003b997          	auipc	s3,0x3b
    80003b74:	71898993          	addi	s3,s3,1816 # 8003f288 <sb>
    80003b78:	02000613          	li	a2,32
    80003b7c:	05850593          	addi	a1,a0,88
    80003b80:	854e                	mv	a0,s3
    80003b82:	ffffd097          	auipc	ra,0xffffd
    80003b86:	3b0080e7          	jalr	944(ra) # 80000f32 <memmove>
  brelse(bp);
    80003b8a:	8526                	mv	a0,s1
    80003b8c:	00000097          	auipc	ra,0x0
    80003b90:	b5e080e7          	jalr	-1186(ra) # 800036ea <brelse>
  if(sb.magic != FSMAGIC)
    80003b94:	0009a703          	lw	a4,0(s3)
    80003b98:	102037b7          	lui	a5,0x10203
    80003b9c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003ba0:	02f71263          	bne	a4,a5,80003bc4 <fsinit+0x70>
  initlog(dev, &sb);
    80003ba4:	0003b597          	auipc	a1,0x3b
    80003ba8:	6e458593          	addi	a1,a1,1764 # 8003f288 <sb>
    80003bac:	854a                	mv	a0,s2
    80003bae:	00001097          	auipc	ra,0x1
    80003bb2:	b4a080e7          	jalr	-1206(ra) # 800046f8 <initlog>
}
    80003bb6:	70a2                	ld	ra,40(sp)
    80003bb8:	7402                	ld	s0,32(sp)
    80003bba:	64e2                	ld	s1,24(sp)
    80003bbc:	6942                	ld	s2,16(sp)
    80003bbe:	69a2                	ld	s3,8(sp)
    80003bc0:	6145                	addi	sp,sp,48
    80003bc2:	8082                	ret
    panic("invalid file system");
    80003bc4:	00005517          	auipc	a0,0x5
    80003bc8:	bbc50513          	addi	a0,a0,-1092 # 80008780 <syscalls+0x168>
    80003bcc:	ffffd097          	auipc	ra,0xffffd
    80003bd0:	974080e7          	jalr	-1676(ra) # 80000540 <panic>

0000000080003bd4 <iinit>:
{
    80003bd4:	7179                	addi	sp,sp,-48
    80003bd6:	f406                	sd	ra,40(sp)
    80003bd8:	f022                	sd	s0,32(sp)
    80003bda:	ec26                	sd	s1,24(sp)
    80003bdc:	e84a                	sd	s2,16(sp)
    80003bde:	e44e                	sd	s3,8(sp)
    80003be0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003be2:	00005597          	auipc	a1,0x5
    80003be6:	bb658593          	addi	a1,a1,-1098 # 80008798 <syscalls+0x180>
    80003bea:	0003b517          	auipc	a0,0x3b
    80003bee:	6be50513          	addi	a0,a0,1726 # 8003f2a8 <itable>
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	158080e7          	jalr	344(ra) # 80000d4a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bfa:	0003b497          	auipc	s1,0x3b
    80003bfe:	6d648493          	addi	s1,s1,1750 # 8003f2d0 <itable+0x28>
    80003c02:	0003d997          	auipc	s3,0x3d
    80003c06:	15e98993          	addi	s3,s3,350 # 80040d60 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c0a:	00005917          	auipc	s2,0x5
    80003c0e:	b9690913          	addi	s2,s2,-1130 # 800087a0 <syscalls+0x188>
    80003c12:	85ca                	mv	a1,s2
    80003c14:	8526                	mv	a0,s1
    80003c16:	00001097          	auipc	ra,0x1
    80003c1a:	e42080e7          	jalr	-446(ra) # 80004a58 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c1e:	08848493          	addi	s1,s1,136
    80003c22:	ff3498e3          	bne	s1,s3,80003c12 <iinit+0x3e>
}
    80003c26:	70a2                	ld	ra,40(sp)
    80003c28:	7402                	ld	s0,32(sp)
    80003c2a:	64e2                	ld	s1,24(sp)
    80003c2c:	6942                	ld	s2,16(sp)
    80003c2e:	69a2                	ld	s3,8(sp)
    80003c30:	6145                	addi	sp,sp,48
    80003c32:	8082                	ret

0000000080003c34 <ialloc>:
{
    80003c34:	715d                	addi	sp,sp,-80
    80003c36:	e486                	sd	ra,72(sp)
    80003c38:	e0a2                	sd	s0,64(sp)
    80003c3a:	fc26                	sd	s1,56(sp)
    80003c3c:	f84a                	sd	s2,48(sp)
    80003c3e:	f44e                	sd	s3,40(sp)
    80003c40:	f052                	sd	s4,32(sp)
    80003c42:	ec56                	sd	s5,24(sp)
    80003c44:	e85a                	sd	s6,16(sp)
    80003c46:	e45e                	sd	s7,8(sp)
    80003c48:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c4a:	0003b717          	auipc	a4,0x3b
    80003c4e:	64a72703          	lw	a4,1610(a4) # 8003f294 <sb+0xc>
    80003c52:	4785                	li	a5,1
    80003c54:	04e7fa63          	bgeu	a5,a4,80003ca8 <ialloc+0x74>
    80003c58:	8aaa                	mv	s5,a0
    80003c5a:	8bae                	mv	s7,a1
    80003c5c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c5e:	0003ba17          	auipc	s4,0x3b
    80003c62:	62aa0a13          	addi	s4,s4,1578 # 8003f288 <sb>
    80003c66:	00048b1b          	sext.w	s6,s1
    80003c6a:	0044d593          	srli	a1,s1,0x4
    80003c6e:	018a2783          	lw	a5,24(s4)
    80003c72:	9dbd                	addw	a1,a1,a5
    80003c74:	8556                	mv	a0,s5
    80003c76:	00000097          	auipc	ra,0x0
    80003c7a:	944080e7          	jalr	-1724(ra) # 800035ba <bread>
    80003c7e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c80:	05850993          	addi	s3,a0,88
    80003c84:	00f4f793          	andi	a5,s1,15
    80003c88:	079a                	slli	a5,a5,0x6
    80003c8a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c8c:	00099783          	lh	a5,0(s3)
    80003c90:	c3a1                	beqz	a5,80003cd0 <ialloc+0x9c>
    brelse(bp);
    80003c92:	00000097          	auipc	ra,0x0
    80003c96:	a58080e7          	jalr	-1448(ra) # 800036ea <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c9a:	0485                	addi	s1,s1,1
    80003c9c:	00ca2703          	lw	a4,12(s4)
    80003ca0:	0004879b          	sext.w	a5,s1
    80003ca4:	fce7e1e3          	bltu	a5,a4,80003c66 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ca8:	00005517          	auipc	a0,0x5
    80003cac:	b0050513          	addi	a0,a0,-1280 # 800087a8 <syscalls+0x190>
    80003cb0:	ffffd097          	auipc	ra,0xffffd
    80003cb4:	8ec080e7          	jalr	-1812(ra) # 8000059c <printf>
  return 0;
    80003cb8:	4501                	li	a0,0
}
    80003cba:	60a6                	ld	ra,72(sp)
    80003cbc:	6406                	ld	s0,64(sp)
    80003cbe:	74e2                	ld	s1,56(sp)
    80003cc0:	7942                	ld	s2,48(sp)
    80003cc2:	79a2                	ld	s3,40(sp)
    80003cc4:	7a02                	ld	s4,32(sp)
    80003cc6:	6ae2                	ld	s5,24(sp)
    80003cc8:	6b42                	ld	s6,16(sp)
    80003cca:	6ba2                	ld	s7,8(sp)
    80003ccc:	6161                	addi	sp,sp,80
    80003cce:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003cd0:	04000613          	li	a2,64
    80003cd4:	4581                	li	a1,0
    80003cd6:	854e                	mv	a0,s3
    80003cd8:	ffffd097          	auipc	ra,0xffffd
    80003cdc:	1fe080e7          	jalr	510(ra) # 80000ed6 <memset>
      dip->type = type;
    80003ce0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ce4:	854a                	mv	a0,s2
    80003ce6:	00001097          	auipc	ra,0x1
    80003cea:	c8e080e7          	jalr	-882(ra) # 80004974 <log_write>
      brelse(bp);
    80003cee:	854a                	mv	a0,s2
    80003cf0:	00000097          	auipc	ra,0x0
    80003cf4:	9fa080e7          	jalr	-1542(ra) # 800036ea <brelse>
      return iget(dev, inum);
    80003cf8:	85da                	mv	a1,s6
    80003cfa:	8556                	mv	a0,s5
    80003cfc:	00000097          	auipc	ra,0x0
    80003d00:	d9c080e7          	jalr	-612(ra) # 80003a98 <iget>
    80003d04:	bf5d                	j	80003cba <ialloc+0x86>

0000000080003d06 <iupdate>:
{
    80003d06:	1101                	addi	sp,sp,-32
    80003d08:	ec06                	sd	ra,24(sp)
    80003d0a:	e822                	sd	s0,16(sp)
    80003d0c:	e426                	sd	s1,8(sp)
    80003d0e:	e04a                	sd	s2,0(sp)
    80003d10:	1000                	addi	s0,sp,32
    80003d12:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d14:	415c                	lw	a5,4(a0)
    80003d16:	0047d79b          	srliw	a5,a5,0x4
    80003d1a:	0003b597          	auipc	a1,0x3b
    80003d1e:	5865a583          	lw	a1,1414(a1) # 8003f2a0 <sb+0x18>
    80003d22:	9dbd                	addw	a1,a1,a5
    80003d24:	4108                	lw	a0,0(a0)
    80003d26:	00000097          	auipc	ra,0x0
    80003d2a:	894080e7          	jalr	-1900(ra) # 800035ba <bread>
    80003d2e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d30:	05850793          	addi	a5,a0,88
    80003d34:	40d8                	lw	a4,4(s1)
    80003d36:	8b3d                	andi	a4,a4,15
    80003d38:	071a                	slli	a4,a4,0x6
    80003d3a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d3c:	04449703          	lh	a4,68(s1)
    80003d40:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d44:	04649703          	lh	a4,70(s1)
    80003d48:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003d4c:	04849703          	lh	a4,72(s1)
    80003d50:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003d54:	04a49703          	lh	a4,74(s1)
    80003d58:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003d5c:	44f8                	lw	a4,76(s1)
    80003d5e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d60:	03400613          	li	a2,52
    80003d64:	05048593          	addi	a1,s1,80
    80003d68:	00c78513          	addi	a0,a5,12
    80003d6c:	ffffd097          	auipc	ra,0xffffd
    80003d70:	1c6080e7          	jalr	454(ra) # 80000f32 <memmove>
  log_write(bp);
    80003d74:	854a                	mv	a0,s2
    80003d76:	00001097          	auipc	ra,0x1
    80003d7a:	bfe080e7          	jalr	-1026(ra) # 80004974 <log_write>
  brelse(bp);
    80003d7e:	854a                	mv	a0,s2
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	96a080e7          	jalr	-1686(ra) # 800036ea <brelse>
}
    80003d88:	60e2                	ld	ra,24(sp)
    80003d8a:	6442                	ld	s0,16(sp)
    80003d8c:	64a2                	ld	s1,8(sp)
    80003d8e:	6902                	ld	s2,0(sp)
    80003d90:	6105                	addi	sp,sp,32
    80003d92:	8082                	ret

0000000080003d94 <idup>:
{
    80003d94:	1101                	addi	sp,sp,-32
    80003d96:	ec06                	sd	ra,24(sp)
    80003d98:	e822                	sd	s0,16(sp)
    80003d9a:	e426                	sd	s1,8(sp)
    80003d9c:	1000                	addi	s0,sp,32
    80003d9e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003da0:	0003b517          	auipc	a0,0x3b
    80003da4:	50850513          	addi	a0,a0,1288 # 8003f2a8 <itable>
    80003da8:	ffffd097          	auipc	ra,0xffffd
    80003dac:	032080e7          	jalr	50(ra) # 80000dda <acquire>
  ip->ref++;
    80003db0:	449c                	lw	a5,8(s1)
    80003db2:	2785                	addiw	a5,a5,1
    80003db4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003db6:	0003b517          	auipc	a0,0x3b
    80003dba:	4f250513          	addi	a0,a0,1266 # 8003f2a8 <itable>
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	0d0080e7          	jalr	208(ra) # 80000e8e <release>
}
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	60e2                	ld	ra,24(sp)
    80003dca:	6442                	ld	s0,16(sp)
    80003dcc:	64a2                	ld	s1,8(sp)
    80003dce:	6105                	addi	sp,sp,32
    80003dd0:	8082                	ret

0000000080003dd2 <ilock>:
{
    80003dd2:	1101                	addi	sp,sp,-32
    80003dd4:	ec06                	sd	ra,24(sp)
    80003dd6:	e822                	sd	s0,16(sp)
    80003dd8:	e426                	sd	s1,8(sp)
    80003dda:	e04a                	sd	s2,0(sp)
    80003ddc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003dde:	c115                	beqz	a0,80003e02 <ilock+0x30>
    80003de0:	84aa                	mv	s1,a0
    80003de2:	451c                	lw	a5,8(a0)
    80003de4:	00f05f63          	blez	a5,80003e02 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003de8:	0541                	addi	a0,a0,16
    80003dea:	00001097          	auipc	ra,0x1
    80003dee:	ca8080e7          	jalr	-856(ra) # 80004a92 <acquiresleep>
  if(ip->valid == 0){
    80003df2:	40bc                	lw	a5,64(s1)
    80003df4:	cf99                	beqz	a5,80003e12 <ilock+0x40>
}
    80003df6:	60e2                	ld	ra,24(sp)
    80003df8:	6442                	ld	s0,16(sp)
    80003dfa:	64a2                	ld	s1,8(sp)
    80003dfc:	6902                	ld	s2,0(sp)
    80003dfe:	6105                	addi	sp,sp,32
    80003e00:	8082                	ret
    panic("ilock");
    80003e02:	00005517          	auipc	a0,0x5
    80003e06:	9be50513          	addi	a0,a0,-1602 # 800087c0 <syscalls+0x1a8>
    80003e0a:	ffffc097          	auipc	ra,0xffffc
    80003e0e:	736080e7          	jalr	1846(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e12:	40dc                	lw	a5,4(s1)
    80003e14:	0047d79b          	srliw	a5,a5,0x4
    80003e18:	0003b597          	auipc	a1,0x3b
    80003e1c:	4885a583          	lw	a1,1160(a1) # 8003f2a0 <sb+0x18>
    80003e20:	9dbd                	addw	a1,a1,a5
    80003e22:	4088                	lw	a0,0(s1)
    80003e24:	fffff097          	auipc	ra,0xfffff
    80003e28:	796080e7          	jalr	1942(ra) # 800035ba <bread>
    80003e2c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e2e:	05850593          	addi	a1,a0,88
    80003e32:	40dc                	lw	a5,4(s1)
    80003e34:	8bbd                	andi	a5,a5,15
    80003e36:	079a                	slli	a5,a5,0x6
    80003e38:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e3a:	00059783          	lh	a5,0(a1)
    80003e3e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e42:	00259783          	lh	a5,2(a1)
    80003e46:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e4a:	00459783          	lh	a5,4(a1)
    80003e4e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e52:	00659783          	lh	a5,6(a1)
    80003e56:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e5a:	459c                	lw	a5,8(a1)
    80003e5c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e5e:	03400613          	li	a2,52
    80003e62:	05b1                	addi	a1,a1,12
    80003e64:	05048513          	addi	a0,s1,80
    80003e68:	ffffd097          	auipc	ra,0xffffd
    80003e6c:	0ca080e7          	jalr	202(ra) # 80000f32 <memmove>
    brelse(bp);
    80003e70:	854a                	mv	a0,s2
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	878080e7          	jalr	-1928(ra) # 800036ea <brelse>
    ip->valid = 1;
    80003e7a:	4785                	li	a5,1
    80003e7c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e7e:	04449783          	lh	a5,68(s1)
    80003e82:	fbb5                	bnez	a5,80003df6 <ilock+0x24>
      panic("ilock: no type");
    80003e84:	00005517          	auipc	a0,0x5
    80003e88:	94450513          	addi	a0,a0,-1724 # 800087c8 <syscalls+0x1b0>
    80003e8c:	ffffc097          	auipc	ra,0xffffc
    80003e90:	6b4080e7          	jalr	1716(ra) # 80000540 <panic>

0000000080003e94 <iunlock>:
{
    80003e94:	1101                	addi	sp,sp,-32
    80003e96:	ec06                	sd	ra,24(sp)
    80003e98:	e822                	sd	s0,16(sp)
    80003e9a:	e426                	sd	s1,8(sp)
    80003e9c:	e04a                	sd	s2,0(sp)
    80003e9e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ea0:	c905                	beqz	a0,80003ed0 <iunlock+0x3c>
    80003ea2:	84aa                	mv	s1,a0
    80003ea4:	01050913          	addi	s2,a0,16
    80003ea8:	854a                	mv	a0,s2
    80003eaa:	00001097          	auipc	ra,0x1
    80003eae:	c82080e7          	jalr	-894(ra) # 80004b2c <holdingsleep>
    80003eb2:	cd19                	beqz	a0,80003ed0 <iunlock+0x3c>
    80003eb4:	449c                	lw	a5,8(s1)
    80003eb6:	00f05d63          	blez	a5,80003ed0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003eba:	854a                	mv	a0,s2
    80003ebc:	00001097          	auipc	ra,0x1
    80003ec0:	c2c080e7          	jalr	-980(ra) # 80004ae8 <releasesleep>
}
    80003ec4:	60e2                	ld	ra,24(sp)
    80003ec6:	6442                	ld	s0,16(sp)
    80003ec8:	64a2                	ld	s1,8(sp)
    80003eca:	6902                	ld	s2,0(sp)
    80003ecc:	6105                	addi	sp,sp,32
    80003ece:	8082                	ret
    panic("iunlock");
    80003ed0:	00005517          	auipc	a0,0x5
    80003ed4:	90850513          	addi	a0,a0,-1784 # 800087d8 <syscalls+0x1c0>
    80003ed8:	ffffc097          	auipc	ra,0xffffc
    80003edc:	668080e7          	jalr	1640(ra) # 80000540 <panic>

0000000080003ee0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ee0:	7179                	addi	sp,sp,-48
    80003ee2:	f406                	sd	ra,40(sp)
    80003ee4:	f022                	sd	s0,32(sp)
    80003ee6:	ec26                	sd	s1,24(sp)
    80003ee8:	e84a                	sd	s2,16(sp)
    80003eea:	e44e                	sd	s3,8(sp)
    80003eec:	e052                	sd	s4,0(sp)
    80003eee:	1800                	addi	s0,sp,48
    80003ef0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ef2:	05050493          	addi	s1,a0,80
    80003ef6:	08050913          	addi	s2,a0,128
    80003efa:	a021                	j	80003f02 <itrunc+0x22>
    80003efc:	0491                	addi	s1,s1,4
    80003efe:	01248d63          	beq	s1,s2,80003f18 <itrunc+0x38>
    if(ip->addrs[i]){
    80003f02:	408c                	lw	a1,0(s1)
    80003f04:	dde5                	beqz	a1,80003efc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003f06:	0009a503          	lw	a0,0(s3)
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	8f6080e7          	jalr	-1802(ra) # 80003800 <bfree>
      ip->addrs[i] = 0;
    80003f12:	0004a023          	sw	zero,0(s1)
    80003f16:	b7dd                	j	80003efc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f18:	0809a583          	lw	a1,128(s3)
    80003f1c:	e185                	bnez	a1,80003f3c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f1e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f22:	854e                	mv	a0,s3
    80003f24:	00000097          	auipc	ra,0x0
    80003f28:	de2080e7          	jalr	-542(ra) # 80003d06 <iupdate>
}
    80003f2c:	70a2                	ld	ra,40(sp)
    80003f2e:	7402                	ld	s0,32(sp)
    80003f30:	64e2                	ld	s1,24(sp)
    80003f32:	6942                	ld	s2,16(sp)
    80003f34:	69a2                	ld	s3,8(sp)
    80003f36:	6a02                	ld	s4,0(sp)
    80003f38:	6145                	addi	sp,sp,48
    80003f3a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f3c:	0009a503          	lw	a0,0(s3)
    80003f40:	fffff097          	auipc	ra,0xfffff
    80003f44:	67a080e7          	jalr	1658(ra) # 800035ba <bread>
    80003f48:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f4a:	05850493          	addi	s1,a0,88
    80003f4e:	45850913          	addi	s2,a0,1112
    80003f52:	a021                	j	80003f5a <itrunc+0x7a>
    80003f54:	0491                	addi	s1,s1,4
    80003f56:	01248b63          	beq	s1,s2,80003f6c <itrunc+0x8c>
      if(a[j])
    80003f5a:	408c                	lw	a1,0(s1)
    80003f5c:	dde5                	beqz	a1,80003f54 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003f5e:	0009a503          	lw	a0,0(s3)
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	89e080e7          	jalr	-1890(ra) # 80003800 <bfree>
    80003f6a:	b7ed                	j	80003f54 <itrunc+0x74>
    brelse(bp);
    80003f6c:	8552                	mv	a0,s4
    80003f6e:	fffff097          	auipc	ra,0xfffff
    80003f72:	77c080e7          	jalr	1916(ra) # 800036ea <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f76:	0809a583          	lw	a1,128(s3)
    80003f7a:	0009a503          	lw	a0,0(s3)
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	882080e7          	jalr	-1918(ra) # 80003800 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f86:	0809a023          	sw	zero,128(s3)
    80003f8a:	bf51                	j	80003f1e <itrunc+0x3e>

0000000080003f8c <iput>:
{
    80003f8c:	1101                	addi	sp,sp,-32
    80003f8e:	ec06                	sd	ra,24(sp)
    80003f90:	e822                	sd	s0,16(sp)
    80003f92:	e426                	sd	s1,8(sp)
    80003f94:	e04a                	sd	s2,0(sp)
    80003f96:	1000                	addi	s0,sp,32
    80003f98:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f9a:	0003b517          	auipc	a0,0x3b
    80003f9e:	30e50513          	addi	a0,a0,782 # 8003f2a8 <itable>
    80003fa2:	ffffd097          	auipc	ra,0xffffd
    80003fa6:	e38080e7          	jalr	-456(ra) # 80000dda <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003faa:	4498                	lw	a4,8(s1)
    80003fac:	4785                	li	a5,1
    80003fae:	02f70363          	beq	a4,a5,80003fd4 <iput+0x48>
  ip->ref--;
    80003fb2:	449c                	lw	a5,8(s1)
    80003fb4:	37fd                	addiw	a5,a5,-1
    80003fb6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fb8:	0003b517          	auipc	a0,0x3b
    80003fbc:	2f050513          	addi	a0,a0,752 # 8003f2a8 <itable>
    80003fc0:	ffffd097          	auipc	ra,0xffffd
    80003fc4:	ece080e7          	jalr	-306(ra) # 80000e8e <release>
}
    80003fc8:	60e2                	ld	ra,24(sp)
    80003fca:	6442                	ld	s0,16(sp)
    80003fcc:	64a2                	ld	s1,8(sp)
    80003fce:	6902                	ld	s2,0(sp)
    80003fd0:	6105                	addi	sp,sp,32
    80003fd2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fd4:	40bc                	lw	a5,64(s1)
    80003fd6:	dff1                	beqz	a5,80003fb2 <iput+0x26>
    80003fd8:	04a49783          	lh	a5,74(s1)
    80003fdc:	fbf9                	bnez	a5,80003fb2 <iput+0x26>
    acquiresleep(&ip->lock);
    80003fde:	01048913          	addi	s2,s1,16
    80003fe2:	854a                	mv	a0,s2
    80003fe4:	00001097          	auipc	ra,0x1
    80003fe8:	aae080e7          	jalr	-1362(ra) # 80004a92 <acquiresleep>
    release(&itable.lock);
    80003fec:	0003b517          	auipc	a0,0x3b
    80003ff0:	2bc50513          	addi	a0,a0,700 # 8003f2a8 <itable>
    80003ff4:	ffffd097          	auipc	ra,0xffffd
    80003ff8:	e9a080e7          	jalr	-358(ra) # 80000e8e <release>
    itrunc(ip);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	ee2080e7          	jalr	-286(ra) # 80003ee0 <itrunc>
    ip->type = 0;
    80004006:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000400a:	8526                	mv	a0,s1
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	cfa080e7          	jalr	-774(ra) # 80003d06 <iupdate>
    ip->valid = 0;
    80004014:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004018:	854a                	mv	a0,s2
    8000401a:	00001097          	auipc	ra,0x1
    8000401e:	ace080e7          	jalr	-1330(ra) # 80004ae8 <releasesleep>
    acquire(&itable.lock);
    80004022:	0003b517          	auipc	a0,0x3b
    80004026:	28650513          	addi	a0,a0,646 # 8003f2a8 <itable>
    8000402a:	ffffd097          	auipc	ra,0xffffd
    8000402e:	db0080e7          	jalr	-592(ra) # 80000dda <acquire>
    80004032:	b741                	j	80003fb2 <iput+0x26>

0000000080004034 <iunlockput>:
{
    80004034:	1101                	addi	sp,sp,-32
    80004036:	ec06                	sd	ra,24(sp)
    80004038:	e822                	sd	s0,16(sp)
    8000403a:	e426                	sd	s1,8(sp)
    8000403c:	1000                	addi	s0,sp,32
    8000403e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004040:	00000097          	auipc	ra,0x0
    80004044:	e54080e7          	jalr	-428(ra) # 80003e94 <iunlock>
  iput(ip);
    80004048:	8526                	mv	a0,s1
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	f42080e7          	jalr	-190(ra) # 80003f8c <iput>
}
    80004052:	60e2                	ld	ra,24(sp)
    80004054:	6442                	ld	s0,16(sp)
    80004056:	64a2                	ld	s1,8(sp)
    80004058:	6105                	addi	sp,sp,32
    8000405a:	8082                	ret

000000008000405c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000405c:	1141                	addi	sp,sp,-16
    8000405e:	e422                	sd	s0,8(sp)
    80004060:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004062:	411c                	lw	a5,0(a0)
    80004064:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004066:	415c                	lw	a5,4(a0)
    80004068:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000406a:	04451783          	lh	a5,68(a0)
    8000406e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004072:	04a51783          	lh	a5,74(a0)
    80004076:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000407a:	04c56783          	lwu	a5,76(a0)
    8000407e:	e99c                	sd	a5,16(a1)
}
    80004080:	6422                	ld	s0,8(sp)
    80004082:	0141                	addi	sp,sp,16
    80004084:	8082                	ret

0000000080004086 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004086:	457c                	lw	a5,76(a0)
    80004088:	0ed7e963          	bltu	a5,a3,8000417a <readi+0xf4>
{
    8000408c:	7159                	addi	sp,sp,-112
    8000408e:	f486                	sd	ra,104(sp)
    80004090:	f0a2                	sd	s0,96(sp)
    80004092:	eca6                	sd	s1,88(sp)
    80004094:	e8ca                	sd	s2,80(sp)
    80004096:	e4ce                	sd	s3,72(sp)
    80004098:	e0d2                	sd	s4,64(sp)
    8000409a:	fc56                	sd	s5,56(sp)
    8000409c:	f85a                	sd	s6,48(sp)
    8000409e:	f45e                	sd	s7,40(sp)
    800040a0:	f062                	sd	s8,32(sp)
    800040a2:	ec66                	sd	s9,24(sp)
    800040a4:	e86a                	sd	s10,16(sp)
    800040a6:	e46e                	sd	s11,8(sp)
    800040a8:	1880                	addi	s0,sp,112
    800040aa:	8b2a                	mv	s6,a0
    800040ac:	8bae                	mv	s7,a1
    800040ae:	8a32                	mv	s4,a2
    800040b0:	84b6                	mv	s1,a3
    800040b2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800040b4:	9f35                	addw	a4,a4,a3
    return 0;
    800040b6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800040b8:	0ad76063          	bltu	a4,a3,80004158 <readi+0xd2>
  if(off + n > ip->size)
    800040bc:	00e7f463          	bgeu	a5,a4,800040c4 <readi+0x3e>
    n = ip->size - off;
    800040c0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040c4:	0a0a8963          	beqz	s5,80004176 <readi+0xf0>
    800040c8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040ca:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040ce:	5c7d                	li	s8,-1
    800040d0:	a82d                	j	8000410a <readi+0x84>
    800040d2:	020d1d93          	slli	s11,s10,0x20
    800040d6:	020ddd93          	srli	s11,s11,0x20
    800040da:	05890613          	addi	a2,s2,88
    800040de:	86ee                	mv	a3,s11
    800040e0:	963a                	add	a2,a2,a4
    800040e2:	85d2                	mv	a1,s4
    800040e4:	855e                	mv	a0,s7
    800040e6:	ffffe097          	auipc	ra,0xffffe
    800040ea:	778080e7          	jalr	1912(ra) # 8000285e <either_copyout>
    800040ee:	05850d63          	beq	a0,s8,80004148 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040f2:	854a                	mv	a0,s2
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	5f6080e7          	jalr	1526(ra) # 800036ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040fc:	013d09bb          	addw	s3,s10,s3
    80004100:	009d04bb          	addw	s1,s10,s1
    80004104:	9a6e                	add	s4,s4,s11
    80004106:	0559f763          	bgeu	s3,s5,80004154 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000410a:	00a4d59b          	srliw	a1,s1,0xa
    8000410e:	855a                	mv	a0,s6
    80004110:	00000097          	auipc	ra,0x0
    80004114:	89e080e7          	jalr	-1890(ra) # 800039ae <bmap>
    80004118:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000411c:	cd85                	beqz	a1,80004154 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000411e:	000b2503          	lw	a0,0(s6)
    80004122:	fffff097          	auipc	ra,0xfffff
    80004126:	498080e7          	jalr	1176(ra) # 800035ba <bread>
    8000412a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000412c:	3ff4f713          	andi	a4,s1,1023
    80004130:	40ec87bb          	subw	a5,s9,a4
    80004134:	413a86bb          	subw	a3,s5,s3
    80004138:	8d3e                	mv	s10,a5
    8000413a:	2781                	sext.w	a5,a5
    8000413c:	0006861b          	sext.w	a2,a3
    80004140:	f8f679e3          	bgeu	a2,a5,800040d2 <readi+0x4c>
    80004144:	8d36                	mv	s10,a3
    80004146:	b771                	j	800040d2 <readi+0x4c>
      brelse(bp);
    80004148:	854a                	mv	a0,s2
    8000414a:	fffff097          	auipc	ra,0xfffff
    8000414e:	5a0080e7          	jalr	1440(ra) # 800036ea <brelse>
      tot = -1;
    80004152:	59fd                	li	s3,-1
  }
  return tot;
    80004154:	0009851b          	sext.w	a0,s3
}
    80004158:	70a6                	ld	ra,104(sp)
    8000415a:	7406                	ld	s0,96(sp)
    8000415c:	64e6                	ld	s1,88(sp)
    8000415e:	6946                	ld	s2,80(sp)
    80004160:	69a6                	ld	s3,72(sp)
    80004162:	6a06                	ld	s4,64(sp)
    80004164:	7ae2                	ld	s5,56(sp)
    80004166:	7b42                	ld	s6,48(sp)
    80004168:	7ba2                	ld	s7,40(sp)
    8000416a:	7c02                	ld	s8,32(sp)
    8000416c:	6ce2                	ld	s9,24(sp)
    8000416e:	6d42                	ld	s10,16(sp)
    80004170:	6da2                	ld	s11,8(sp)
    80004172:	6165                	addi	sp,sp,112
    80004174:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004176:	89d6                	mv	s3,s5
    80004178:	bff1                	j	80004154 <readi+0xce>
    return 0;
    8000417a:	4501                	li	a0,0
}
    8000417c:	8082                	ret

000000008000417e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000417e:	457c                	lw	a5,76(a0)
    80004180:	10d7e863          	bltu	a5,a3,80004290 <writei+0x112>
{
    80004184:	7159                	addi	sp,sp,-112
    80004186:	f486                	sd	ra,104(sp)
    80004188:	f0a2                	sd	s0,96(sp)
    8000418a:	eca6                	sd	s1,88(sp)
    8000418c:	e8ca                	sd	s2,80(sp)
    8000418e:	e4ce                	sd	s3,72(sp)
    80004190:	e0d2                	sd	s4,64(sp)
    80004192:	fc56                	sd	s5,56(sp)
    80004194:	f85a                	sd	s6,48(sp)
    80004196:	f45e                	sd	s7,40(sp)
    80004198:	f062                	sd	s8,32(sp)
    8000419a:	ec66                	sd	s9,24(sp)
    8000419c:	e86a                	sd	s10,16(sp)
    8000419e:	e46e                	sd	s11,8(sp)
    800041a0:	1880                	addi	s0,sp,112
    800041a2:	8aaa                	mv	s5,a0
    800041a4:	8bae                	mv	s7,a1
    800041a6:	8a32                	mv	s4,a2
    800041a8:	8936                	mv	s2,a3
    800041aa:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800041ac:	00e687bb          	addw	a5,a3,a4
    800041b0:	0ed7e263          	bltu	a5,a3,80004294 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800041b4:	00043737          	lui	a4,0x43
    800041b8:	0ef76063          	bltu	a4,a5,80004298 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041bc:	0c0b0863          	beqz	s6,8000428c <writei+0x10e>
    800041c0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041c2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800041c6:	5c7d                	li	s8,-1
    800041c8:	a091                	j	8000420c <writei+0x8e>
    800041ca:	020d1d93          	slli	s11,s10,0x20
    800041ce:	020ddd93          	srli	s11,s11,0x20
    800041d2:	05848513          	addi	a0,s1,88
    800041d6:	86ee                	mv	a3,s11
    800041d8:	8652                	mv	a2,s4
    800041da:	85de                	mv	a1,s7
    800041dc:	953a                	add	a0,a0,a4
    800041de:	ffffe097          	auipc	ra,0xffffe
    800041e2:	6d6080e7          	jalr	1750(ra) # 800028b4 <either_copyin>
    800041e6:	07850263          	beq	a0,s8,8000424a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800041ea:	8526                	mv	a0,s1
    800041ec:	00000097          	auipc	ra,0x0
    800041f0:	788080e7          	jalr	1928(ra) # 80004974 <log_write>
    brelse(bp);
    800041f4:	8526                	mv	a0,s1
    800041f6:	fffff097          	auipc	ra,0xfffff
    800041fa:	4f4080e7          	jalr	1268(ra) # 800036ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041fe:	013d09bb          	addw	s3,s10,s3
    80004202:	012d093b          	addw	s2,s10,s2
    80004206:	9a6e                	add	s4,s4,s11
    80004208:	0569f663          	bgeu	s3,s6,80004254 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000420c:	00a9559b          	srliw	a1,s2,0xa
    80004210:	8556                	mv	a0,s5
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	79c080e7          	jalr	1948(ra) # 800039ae <bmap>
    8000421a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000421e:	c99d                	beqz	a1,80004254 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004220:	000aa503          	lw	a0,0(s5)
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	396080e7          	jalr	918(ra) # 800035ba <bread>
    8000422c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000422e:	3ff97713          	andi	a4,s2,1023
    80004232:	40ec87bb          	subw	a5,s9,a4
    80004236:	413b06bb          	subw	a3,s6,s3
    8000423a:	8d3e                	mv	s10,a5
    8000423c:	2781                	sext.w	a5,a5
    8000423e:	0006861b          	sext.w	a2,a3
    80004242:	f8f674e3          	bgeu	a2,a5,800041ca <writei+0x4c>
    80004246:	8d36                	mv	s10,a3
    80004248:	b749                	j	800041ca <writei+0x4c>
      brelse(bp);
    8000424a:	8526                	mv	a0,s1
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	49e080e7          	jalr	1182(ra) # 800036ea <brelse>
  }

  if(off > ip->size)
    80004254:	04caa783          	lw	a5,76(s5)
    80004258:	0127f463          	bgeu	a5,s2,80004260 <writei+0xe2>
    ip->size = off;
    8000425c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004260:	8556                	mv	a0,s5
    80004262:	00000097          	auipc	ra,0x0
    80004266:	aa4080e7          	jalr	-1372(ra) # 80003d06 <iupdate>

  return tot;
    8000426a:	0009851b          	sext.w	a0,s3
}
    8000426e:	70a6                	ld	ra,104(sp)
    80004270:	7406                	ld	s0,96(sp)
    80004272:	64e6                	ld	s1,88(sp)
    80004274:	6946                	ld	s2,80(sp)
    80004276:	69a6                	ld	s3,72(sp)
    80004278:	6a06                	ld	s4,64(sp)
    8000427a:	7ae2                	ld	s5,56(sp)
    8000427c:	7b42                	ld	s6,48(sp)
    8000427e:	7ba2                	ld	s7,40(sp)
    80004280:	7c02                	ld	s8,32(sp)
    80004282:	6ce2                	ld	s9,24(sp)
    80004284:	6d42                	ld	s10,16(sp)
    80004286:	6da2                	ld	s11,8(sp)
    80004288:	6165                	addi	sp,sp,112
    8000428a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000428c:	89da                	mv	s3,s6
    8000428e:	bfc9                	j	80004260 <writei+0xe2>
    return -1;
    80004290:	557d                	li	a0,-1
}
    80004292:	8082                	ret
    return -1;
    80004294:	557d                	li	a0,-1
    80004296:	bfe1                	j	8000426e <writei+0xf0>
    return -1;
    80004298:	557d                	li	a0,-1
    8000429a:	bfd1                	j	8000426e <writei+0xf0>

000000008000429c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000429c:	1141                	addi	sp,sp,-16
    8000429e:	e406                	sd	ra,8(sp)
    800042a0:	e022                	sd	s0,0(sp)
    800042a2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042a4:	4639                	li	a2,14
    800042a6:	ffffd097          	auipc	ra,0xffffd
    800042aa:	d00080e7          	jalr	-768(ra) # 80000fa6 <strncmp>
}
    800042ae:	60a2                	ld	ra,8(sp)
    800042b0:	6402                	ld	s0,0(sp)
    800042b2:	0141                	addi	sp,sp,16
    800042b4:	8082                	ret

00000000800042b6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042b6:	7139                	addi	sp,sp,-64
    800042b8:	fc06                	sd	ra,56(sp)
    800042ba:	f822                	sd	s0,48(sp)
    800042bc:	f426                	sd	s1,40(sp)
    800042be:	f04a                	sd	s2,32(sp)
    800042c0:	ec4e                	sd	s3,24(sp)
    800042c2:	e852                	sd	s4,16(sp)
    800042c4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800042c6:	04451703          	lh	a4,68(a0)
    800042ca:	4785                	li	a5,1
    800042cc:	00f71a63          	bne	a4,a5,800042e0 <dirlookup+0x2a>
    800042d0:	892a                	mv	s2,a0
    800042d2:	89ae                	mv	s3,a1
    800042d4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d6:	457c                	lw	a5,76(a0)
    800042d8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042da:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042dc:	e79d                	bnez	a5,8000430a <dirlookup+0x54>
    800042de:	a8a5                	j	80004356 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042e0:	00004517          	auipc	a0,0x4
    800042e4:	50050513          	addi	a0,a0,1280 # 800087e0 <syscalls+0x1c8>
    800042e8:	ffffc097          	auipc	ra,0xffffc
    800042ec:	258080e7          	jalr	600(ra) # 80000540 <panic>
      panic("dirlookup read");
    800042f0:	00004517          	auipc	a0,0x4
    800042f4:	50850513          	addi	a0,a0,1288 # 800087f8 <syscalls+0x1e0>
    800042f8:	ffffc097          	auipc	ra,0xffffc
    800042fc:	248080e7          	jalr	584(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004300:	24c1                	addiw	s1,s1,16
    80004302:	04c92783          	lw	a5,76(s2)
    80004306:	04f4f763          	bgeu	s1,a5,80004354 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000430a:	4741                	li	a4,16
    8000430c:	86a6                	mv	a3,s1
    8000430e:	fc040613          	addi	a2,s0,-64
    80004312:	4581                	li	a1,0
    80004314:	854a                	mv	a0,s2
    80004316:	00000097          	auipc	ra,0x0
    8000431a:	d70080e7          	jalr	-656(ra) # 80004086 <readi>
    8000431e:	47c1                	li	a5,16
    80004320:	fcf518e3          	bne	a0,a5,800042f0 <dirlookup+0x3a>
    if(de.inum == 0)
    80004324:	fc045783          	lhu	a5,-64(s0)
    80004328:	dfe1                	beqz	a5,80004300 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000432a:	fc240593          	addi	a1,s0,-62
    8000432e:	854e                	mv	a0,s3
    80004330:	00000097          	auipc	ra,0x0
    80004334:	f6c080e7          	jalr	-148(ra) # 8000429c <namecmp>
    80004338:	f561                	bnez	a0,80004300 <dirlookup+0x4a>
      if(poff)
    8000433a:	000a0463          	beqz	s4,80004342 <dirlookup+0x8c>
        *poff = off;
    8000433e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004342:	fc045583          	lhu	a1,-64(s0)
    80004346:	00092503          	lw	a0,0(s2)
    8000434a:	fffff097          	auipc	ra,0xfffff
    8000434e:	74e080e7          	jalr	1870(ra) # 80003a98 <iget>
    80004352:	a011                	j	80004356 <dirlookup+0xa0>
  return 0;
    80004354:	4501                	li	a0,0
}
    80004356:	70e2                	ld	ra,56(sp)
    80004358:	7442                	ld	s0,48(sp)
    8000435a:	74a2                	ld	s1,40(sp)
    8000435c:	7902                	ld	s2,32(sp)
    8000435e:	69e2                	ld	s3,24(sp)
    80004360:	6a42                	ld	s4,16(sp)
    80004362:	6121                	addi	sp,sp,64
    80004364:	8082                	ret

0000000080004366 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004366:	711d                	addi	sp,sp,-96
    80004368:	ec86                	sd	ra,88(sp)
    8000436a:	e8a2                	sd	s0,80(sp)
    8000436c:	e4a6                	sd	s1,72(sp)
    8000436e:	e0ca                	sd	s2,64(sp)
    80004370:	fc4e                	sd	s3,56(sp)
    80004372:	f852                	sd	s4,48(sp)
    80004374:	f456                	sd	s5,40(sp)
    80004376:	f05a                	sd	s6,32(sp)
    80004378:	ec5e                	sd	s7,24(sp)
    8000437a:	e862                	sd	s8,16(sp)
    8000437c:	e466                	sd	s9,8(sp)
    8000437e:	e06a                	sd	s10,0(sp)
    80004380:	1080                	addi	s0,sp,96
    80004382:	84aa                	mv	s1,a0
    80004384:	8b2e                	mv	s6,a1
    80004386:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004388:	00054703          	lbu	a4,0(a0)
    8000438c:	02f00793          	li	a5,47
    80004390:	02f70363          	beq	a4,a5,800043b6 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004394:	ffffe097          	auipc	ra,0xffffe
    80004398:	914080e7          	jalr	-1772(ra) # 80001ca8 <myproc>
    8000439c:	15053503          	ld	a0,336(a0)
    800043a0:	00000097          	auipc	ra,0x0
    800043a4:	9f4080e7          	jalr	-1548(ra) # 80003d94 <idup>
    800043a8:	8a2a                	mv	s4,a0
  while(*path == '/')
    800043aa:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800043ae:	4cb5                	li	s9,13
  len = path - s;
    800043b0:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800043b2:	4c05                	li	s8,1
    800043b4:	a87d                	j	80004472 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800043b6:	4585                	li	a1,1
    800043b8:	4505                	li	a0,1
    800043ba:	fffff097          	auipc	ra,0xfffff
    800043be:	6de080e7          	jalr	1758(ra) # 80003a98 <iget>
    800043c2:	8a2a                	mv	s4,a0
    800043c4:	b7dd                	j	800043aa <namex+0x44>
      iunlockput(ip);
    800043c6:	8552                	mv	a0,s4
    800043c8:	00000097          	auipc	ra,0x0
    800043cc:	c6c080e7          	jalr	-916(ra) # 80004034 <iunlockput>
      return 0;
    800043d0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800043d2:	8552                	mv	a0,s4
    800043d4:	60e6                	ld	ra,88(sp)
    800043d6:	6446                	ld	s0,80(sp)
    800043d8:	64a6                	ld	s1,72(sp)
    800043da:	6906                	ld	s2,64(sp)
    800043dc:	79e2                	ld	s3,56(sp)
    800043de:	7a42                	ld	s4,48(sp)
    800043e0:	7aa2                	ld	s5,40(sp)
    800043e2:	7b02                	ld	s6,32(sp)
    800043e4:	6be2                	ld	s7,24(sp)
    800043e6:	6c42                	ld	s8,16(sp)
    800043e8:	6ca2                	ld	s9,8(sp)
    800043ea:	6d02                	ld	s10,0(sp)
    800043ec:	6125                	addi	sp,sp,96
    800043ee:	8082                	ret
      iunlock(ip);
    800043f0:	8552                	mv	a0,s4
    800043f2:	00000097          	auipc	ra,0x0
    800043f6:	aa2080e7          	jalr	-1374(ra) # 80003e94 <iunlock>
      return ip;
    800043fa:	bfe1                	j	800043d2 <namex+0x6c>
      iunlockput(ip);
    800043fc:	8552                	mv	a0,s4
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	c36080e7          	jalr	-970(ra) # 80004034 <iunlockput>
      return 0;
    80004406:	8a4e                	mv	s4,s3
    80004408:	b7e9                	j	800043d2 <namex+0x6c>
  len = path - s;
    8000440a:	40998633          	sub	a2,s3,s1
    8000440e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004412:	09acd863          	bge	s9,s10,800044a2 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004416:	4639                	li	a2,14
    80004418:	85a6                	mv	a1,s1
    8000441a:	8556                	mv	a0,s5
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	b16080e7          	jalr	-1258(ra) # 80000f32 <memmove>
    80004424:	84ce                	mv	s1,s3
  while(*path == '/')
    80004426:	0004c783          	lbu	a5,0(s1)
    8000442a:	01279763          	bne	a5,s2,80004438 <namex+0xd2>
    path++;
    8000442e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004430:	0004c783          	lbu	a5,0(s1)
    80004434:	ff278de3          	beq	a5,s2,8000442e <namex+0xc8>
    ilock(ip);
    80004438:	8552                	mv	a0,s4
    8000443a:	00000097          	auipc	ra,0x0
    8000443e:	998080e7          	jalr	-1640(ra) # 80003dd2 <ilock>
    if(ip->type != T_DIR){
    80004442:	044a1783          	lh	a5,68(s4)
    80004446:	f98790e3          	bne	a5,s8,800043c6 <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000444a:	000b0563          	beqz	s6,80004454 <namex+0xee>
    8000444e:	0004c783          	lbu	a5,0(s1)
    80004452:	dfd9                	beqz	a5,800043f0 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004454:	865e                	mv	a2,s7
    80004456:	85d6                	mv	a1,s5
    80004458:	8552                	mv	a0,s4
    8000445a:	00000097          	auipc	ra,0x0
    8000445e:	e5c080e7          	jalr	-420(ra) # 800042b6 <dirlookup>
    80004462:	89aa                	mv	s3,a0
    80004464:	dd41                	beqz	a0,800043fc <namex+0x96>
    iunlockput(ip);
    80004466:	8552                	mv	a0,s4
    80004468:	00000097          	auipc	ra,0x0
    8000446c:	bcc080e7          	jalr	-1076(ra) # 80004034 <iunlockput>
    ip = next;
    80004470:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004472:	0004c783          	lbu	a5,0(s1)
    80004476:	01279763          	bne	a5,s2,80004484 <namex+0x11e>
    path++;
    8000447a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000447c:	0004c783          	lbu	a5,0(s1)
    80004480:	ff278de3          	beq	a5,s2,8000447a <namex+0x114>
  if(*path == 0)
    80004484:	cb9d                	beqz	a5,800044ba <namex+0x154>
  while(*path != '/' && *path != 0)
    80004486:	0004c783          	lbu	a5,0(s1)
    8000448a:	89a6                	mv	s3,s1
  len = path - s;
    8000448c:	8d5e                	mv	s10,s7
    8000448e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004490:	01278963          	beq	a5,s2,800044a2 <namex+0x13c>
    80004494:	dbbd                	beqz	a5,8000440a <namex+0xa4>
    path++;
    80004496:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004498:	0009c783          	lbu	a5,0(s3)
    8000449c:	ff279ce3          	bne	a5,s2,80004494 <namex+0x12e>
    800044a0:	b7ad                	j	8000440a <namex+0xa4>
    memmove(name, s, len);
    800044a2:	2601                	sext.w	a2,a2
    800044a4:	85a6                	mv	a1,s1
    800044a6:	8556                	mv	a0,s5
    800044a8:	ffffd097          	auipc	ra,0xffffd
    800044ac:	a8a080e7          	jalr	-1398(ra) # 80000f32 <memmove>
    name[len] = 0;
    800044b0:	9d56                	add	s10,s10,s5
    800044b2:	000d0023          	sb	zero,0(s10)
    800044b6:	84ce                	mv	s1,s3
    800044b8:	b7bd                	j	80004426 <namex+0xc0>
  if(nameiparent){
    800044ba:	f00b0ce3          	beqz	s6,800043d2 <namex+0x6c>
    iput(ip);
    800044be:	8552                	mv	a0,s4
    800044c0:	00000097          	auipc	ra,0x0
    800044c4:	acc080e7          	jalr	-1332(ra) # 80003f8c <iput>
    return 0;
    800044c8:	4a01                	li	s4,0
    800044ca:	b721                	j	800043d2 <namex+0x6c>

00000000800044cc <dirlink>:
{
    800044cc:	7139                	addi	sp,sp,-64
    800044ce:	fc06                	sd	ra,56(sp)
    800044d0:	f822                	sd	s0,48(sp)
    800044d2:	f426                	sd	s1,40(sp)
    800044d4:	f04a                	sd	s2,32(sp)
    800044d6:	ec4e                	sd	s3,24(sp)
    800044d8:	e852                	sd	s4,16(sp)
    800044da:	0080                	addi	s0,sp,64
    800044dc:	892a                	mv	s2,a0
    800044de:	8a2e                	mv	s4,a1
    800044e0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800044e2:	4601                	li	a2,0
    800044e4:	00000097          	auipc	ra,0x0
    800044e8:	dd2080e7          	jalr	-558(ra) # 800042b6 <dirlookup>
    800044ec:	e93d                	bnez	a0,80004562 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044ee:	04c92483          	lw	s1,76(s2)
    800044f2:	c49d                	beqz	s1,80004520 <dirlink+0x54>
    800044f4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044f6:	4741                	li	a4,16
    800044f8:	86a6                	mv	a3,s1
    800044fa:	fc040613          	addi	a2,s0,-64
    800044fe:	4581                	li	a1,0
    80004500:	854a                	mv	a0,s2
    80004502:	00000097          	auipc	ra,0x0
    80004506:	b84080e7          	jalr	-1148(ra) # 80004086 <readi>
    8000450a:	47c1                	li	a5,16
    8000450c:	06f51163          	bne	a0,a5,8000456e <dirlink+0xa2>
    if(de.inum == 0)
    80004510:	fc045783          	lhu	a5,-64(s0)
    80004514:	c791                	beqz	a5,80004520 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004516:	24c1                	addiw	s1,s1,16
    80004518:	04c92783          	lw	a5,76(s2)
    8000451c:	fcf4ede3          	bltu	s1,a5,800044f6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004520:	4639                	li	a2,14
    80004522:	85d2                	mv	a1,s4
    80004524:	fc240513          	addi	a0,s0,-62
    80004528:	ffffd097          	auipc	ra,0xffffd
    8000452c:	aba080e7          	jalr	-1350(ra) # 80000fe2 <strncpy>
  de.inum = inum;
    80004530:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004534:	4741                	li	a4,16
    80004536:	86a6                	mv	a3,s1
    80004538:	fc040613          	addi	a2,s0,-64
    8000453c:	4581                	li	a1,0
    8000453e:	854a                	mv	a0,s2
    80004540:	00000097          	auipc	ra,0x0
    80004544:	c3e080e7          	jalr	-962(ra) # 8000417e <writei>
    80004548:	1541                	addi	a0,a0,-16
    8000454a:	00a03533          	snez	a0,a0
    8000454e:	40a00533          	neg	a0,a0
}
    80004552:	70e2                	ld	ra,56(sp)
    80004554:	7442                	ld	s0,48(sp)
    80004556:	74a2                	ld	s1,40(sp)
    80004558:	7902                	ld	s2,32(sp)
    8000455a:	69e2                	ld	s3,24(sp)
    8000455c:	6a42                	ld	s4,16(sp)
    8000455e:	6121                	addi	sp,sp,64
    80004560:	8082                	ret
    iput(ip);
    80004562:	00000097          	auipc	ra,0x0
    80004566:	a2a080e7          	jalr	-1494(ra) # 80003f8c <iput>
    return -1;
    8000456a:	557d                	li	a0,-1
    8000456c:	b7dd                	j	80004552 <dirlink+0x86>
      panic("dirlink read");
    8000456e:	00004517          	auipc	a0,0x4
    80004572:	29a50513          	addi	a0,a0,666 # 80008808 <syscalls+0x1f0>
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	fca080e7          	jalr	-54(ra) # 80000540 <panic>

000000008000457e <namei>:

struct inode*
namei(char *path)
{
    8000457e:	1101                	addi	sp,sp,-32
    80004580:	ec06                	sd	ra,24(sp)
    80004582:	e822                	sd	s0,16(sp)
    80004584:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004586:	fe040613          	addi	a2,s0,-32
    8000458a:	4581                	li	a1,0
    8000458c:	00000097          	auipc	ra,0x0
    80004590:	dda080e7          	jalr	-550(ra) # 80004366 <namex>
}
    80004594:	60e2                	ld	ra,24(sp)
    80004596:	6442                	ld	s0,16(sp)
    80004598:	6105                	addi	sp,sp,32
    8000459a:	8082                	ret

000000008000459c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000459c:	1141                	addi	sp,sp,-16
    8000459e:	e406                	sd	ra,8(sp)
    800045a0:	e022                	sd	s0,0(sp)
    800045a2:	0800                	addi	s0,sp,16
    800045a4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045a6:	4585                	li	a1,1
    800045a8:	00000097          	auipc	ra,0x0
    800045ac:	dbe080e7          	jalr	-578(ra) # 80004366 <namex>
}
    800045b0:	60a2                	ld	ra,8(sp)
    800045b2:	6402                	ld	s0,0(sp)
    800045b4:	0141                	addi	sp,sp,16
    800045b6:	8082                	ret

00000000800045b8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800045b8:	1101                	addi	sp,sp,-32
    800045ba:	ec06                	sd	ra,24(sp)
    800045bc:	e822                	sd	s0,16(sp)
    800045be:	e426                	sd	s1,8(sp)
    800045c0:	e04a                	sd	s2,0(sp)
    800045c2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800045c4:	0003c917          	auipc	s2,0x3c
    800045c8:	78c90913          	addi	s2,s2,1932 # 80040d50 <log>
    800045cc:	01892583          	lw	a1,24(s2)
    800045d0:	02892503          	lw	a0,40(s2)
    800045d4:	fffff097          	auipc	ra,0xfffff
    800045d8:	fe6080e7          	jalr	-26(ra) # 800035ba <bread>
    800045dc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800045de:	02c92683          	lw	a3,44(s2)
    800045e2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800045e4:	02d05863          	blez	a3,80004614 <write_head+0x5c>
    800045e8:	0003c797          	auipc	a5,0x3c
    800045ec:	79878793          	addi	a5,a5,1944 # 80040d80 <log+0x30>
    800045f0:	05c50713          	addi	a4,a0,92
    800045f4:	36fd                	addiw	a3,a3,-1
    800045f6:	02069613          	slli	a2,a3,0x20
    800045fa:	01e65693          	srli	a3,a2,0x1e
    800045fe:	0003c617          	auipc	a2,0x3c
    80004602:	78660613          	addi	a2,a2,1926 # 80040d84 <log+0x34>
    80004606:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004608:	4390                	lw	a2,0(a5)
    8000460a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000460c:	0791                	addi	a5,a5,4
    8000460e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004610:	fed79ce3          	bne	a5,a3,80004608 <write_head+0x50>
  }
  bwrite(buf);
    80004614:	8526                	mv	a0,s1
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	096080e7          	jalr	150(ra) # 800036ac <bwrite>
  brelse(buf);
    8000461e:	8526                	mv	a0,s1
    80004620:	fffff097          	auipc	ra,0xfffff
    80004624:	0ca080e7          	jalr	202(ra) # 800036ea <brelse>
}
    80004628:	60e2                	ld	ra,24(sp)
    8000462a:	6442                	ld	s0,16(sp)
    8000462c:	64a2                	ld	s1,8(sp)
    8000462e:	6902                	ld	s2,0(sp)
    80004630:	6105                	addi	sp,sp,32
    80004632:	8082                	ret

0000000080004634 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004634:	0003c797          	auipc	a5,0x3c
    80004638:	7487a783          	lw	a5,1864(a5) # 80040d7c <log+0x2c>
    8000463c:	0af05d63          	blez	a5,800046f6 <install_trans+0xc2>
{
    80004640:	7139                	addi	sp,sp,-64
    80004642:	fc06                	sd	ra,56(sp)
    80004644:	f822                	sd	s0,48(sp)
    80004646:	f426                	sd	s1,40(sp)
    80004648:	f04a                	sd	s2,32(sp)
    8000464a:	ec4e                	sd	s3,24(sp)
    8000464c:	e852                	sd	s4,16(sp)
    8000464e:	e456                	sd	s5,8(sp)
    80004650:	e05a                	sd	s6,0(sp)
    80004652:	0080                	addi	s0,sp,64
    80004654:	8b2a                	mv	s6,a0
    80004656:	0003ca97          	auipc	s5,0x3c
    8000465a:	72aa8a93          	addi	s5,s5,1834 # 80040d80 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000465e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004660:	0003c997          	auipc	s3,0x3c
    80004664:	6f098993          	addi	s3,s3,1776 # 80040d50 <log>
    80004668:	a00d                	j	8000468a <install_trans+0x56>
    brelse(lbuf);
    8000466a:	854a                	mv	a0,s2
    8000466c:	fffff097          	auipc	ra,0xfffff
    80004670:	07e080e7          	jalr	126(ra) # 800036ea <brelse>
    brelse(dbuf);
    80004674:	8526                	mv	a0,s1
    80004676:	fffff097          	auipc	ra,0xfffff
    8000467a:	074080e7          	jalr	116(ra) # 800036ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000467e:	2a05                	addiw	s4,s4,1
    80004680:	0a91                	addi	s5,s5,4
    80004682:	02c9a783          	lw	a5,44(s3)
    80004686:	04fa5e63          	bge	s4,a5,800046e2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000468a:	0189a583          	lw	a1,24(s3)
    8000468e:	014585bb          	addw	a1,a1,s4
    80004692:	2585                	addiw	a1,a1,1
    80004694:	0289a503          	lw	a0,40(s3)
    80004698:	fffff097          	auipc	ra,0xfffff
    8000469c:	f22080e7          	jalr	-222(ra) # 800035ba <bread>
    800046a0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800046a2:	000aa583          	lw	a1,0(s5)
    800046a6:	0289a503          	lw	a0,40(s3)
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	f10080e7          	jalr	-240(ra) # 800035ba <bread>
    800046b2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046b4:	40000613          	li	a2,1024
    800046b8:	05890593          	addi	a1,s2,88
    800046bc:	05850513          	addi	a0,a0,88
    800046c0:	ffffd097          	auipc	ra,0xffffd
    800046c4:	872080e7          	jalr	-1934(ra) # 80000f32 <memmove>
    bwrite(dbuf);  // write dst to disk
    800046c8:	8526                	mv	a0,s1
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	fe2080e7          	jalr	-30(ra) # 800036ac <bwrite>
    if(recovering == 0)
    800046d2:	f80b1ce3          	bnez	s6,8000466a <install_trans+0x36>
      bunpin(dbuf);
    800046d6:	8526                	mv	a0,s1
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	0ec080e7          	jalr	236(ra) # 800037c4 <bunpin>
    800046e0:	b769                	j	8000466a <install_trans+0x36>
}
    800046e2:	70e2                	ld	ra,56(sp)
    800046e4:	7442                	ld	s0,48(sp)
    800046e6:	74a2                	ld	s1,40(sp)
    800046e8:	7902                	ld	s2,32(sp)
    800046ea:	69e2                	ld	s3,24(sp)
    800046ec:	6a42                	ld	s4,16(sp)
    800046ee:	6aa2                	ld	s5,8(sp)
    800046f0:	6b02                	ld	s6,0(sp)
    800046f2:	6121                	addi	sp,sp,64
    800046f4:	8082                	ret
    800046f6:	8082                	ret

00000000800046f8 <initlog>:
{
    800046f8:	7179                	addi	sp,sp,-48
    800046fa:	f406                	sd	ra,40(sp)
    800046fc:	f022                	sd	s0,32(sp)
    800046fe:	ec26                	sd	s1,24(sp)
    80004700:	e84a                	sd	s2,16(sp)
    80004702:	e44e                	sd	s3,8(sp)
    80004704:	1800                	addi	s0,sp,48
    80004706:	892a                	mv	s2,a0
    80004708:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000470a:	0003c497          	auipc	s1,0x3c
    8000470e:	64648493          	addi	s1,s1,1606 # 80040d50 <log>
    80004712:	00004597          	auipc	a1,0x4
    80004716:	10658593          	addi	a1,a1,262 # 80008818 <syscalls+0x200>
    8000471a:	8526                	mv	a0,s1
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	62e080e7          	jalr	1582(ra) # 80000d4a <initlock>
  log.start = sb->logstart;
    80004724:	0149a583          	lw	a1,20(s3)
    80004728:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000472a:	0109a783          	lw	a5,16(s3)
    8000472e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004730:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004734:	854a                	mv	a0,s2
    80004736:	fffff097          	auipc	ra,0xfffff
    8000473a:	e84080e7          	jalr	-380(ra) # 800035ba <bread>
  log.lh.n = lh->n;
    8000473e:	4d34                	lw	a3,88(a0)
    80004740:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004742:	02d05663          	blez	a3,8000476e <initlog+0x76>
    80004746:	05c50793          	addi	a5,a0,92
    8000474a:	0003c717          	auipc	a4,0x3c
    8000474e:	63670713          	addi	a4,a4,1590 # 80040d80 <log+0x30>
    80004752:	36fd                	addiw	a3,a3,-1
    80004754:	02069613          	slli	a2,a3,0x20
    80004758:	01e65693          	srli	a3,a2,0x1e
    8000475c:	06050613          	addi	a2,a0,96
    80004760:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004762:	4390                	lw	a2,0(a5)
    80004764:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004766:	0791                	addi	a5,a5,4
    80004768:	0711                	addi	a4,a4,4
    8000476a:	fed79ce3          	bne	a5,a3,80004762 <initlog+0x6a>
  brelse(buf);
    8000476e:	fffff097          	auipc	ra,0xfffff
    80004772:	f7c080e7          	jalr	-132(ra) # 800036ea <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004776:	4505                	li	a0,1
    80004778:	00000097          	auipc	ra,0x0
    8000477c:	ebc080e7          	jalr	-324(ra) # 80004634 <install_trans>
  log.lh.n = 0;
    80004780:	0003c797          	auipc	a5,0x3c
    80004784:	5e07ae23          	sw	zero,1532(a5) # 80040d7c <log+0x2c>
  write_head(); // clear the log
    80004788:	00000097          	auipc	ra,0x0
    8000478c:	e30080e7          	jalr	-464(ra) # 800045b8 <write_head>
}
    80004790:	70a2                	ld	ra,40(sp)
    80004792:	7402                	ld	s0,32(sp)
    80004794:	64e2                	ld	s1,24(sp)
    80004796:	6942                	ld	s2,16(sp)
    80004798:	69a2                	ld	s3,8(sp)
    8000479a:	6145                	addi	sp,sp,48
    8000479c:	8082                	ret

000000008000479e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000479e:	1101                	addi	sp,sp,-32
    800047a0:	ec06                	sd	ra,24(sp)
    800047a2:	e822                	sd	s0,16(sp)
    800047a4:	e426                	sd	s1,8(sp)
    800047a6:	e04a                	sd	s2,0(sp)
    800047a8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800047aa:	0003c517          	auipc	a0,0x3c
    800047ae:	5a650513          	addi	a0,a0,1446 # 80040d50 <log>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	628080e7          	jalr	1576(ra) # 80000dda <acquire>
  while(1){
    if(log.committing){
    800047ba:	0003c497          	auipc	s1,0x3c
    800047be:	59648493          	addi	s1,s1,1430 # 80040d50 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047c2:	4979                	li	s2,30
    800047c4:	a039                	j	800047d2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800047c6:	85a6                	mv	a1,s1
    800047c8:	8526                	mv	a0,s1
    800047ca:	ffffe097          	auipc	ra,0xffffe
    800047ce:	c8c080e7          	jalr	-884(ra) # 80002456 <sleep>
    if(log.committing){
    800047d2:	50dc                	lw	a5,36(s1)
    800047d4:	fbed                	bnez	a5,800047c6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047d6:	5098                	lw	a4,32(s1)
    800047d8:	2705                	addiw	a4,a4,1
    800047da:	0007069b          	sext.w	a3,a4
    800047de:	0027179b          	slliw	a5,a4,0x2
    800047e2:	9fb9                	addw	a5,a5,a4
    800047e4:	0017979b          	slliw	a5,a5,0x1
    800047e8:	54d8                	lw	a4,44(s1)
    800047ea:	9fb9                	addw	a5,a5,a4
    800047ec:	00f95963          	bge	s2,a5,800047fe <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800047f0:	85a6                	mv	a1,s1
    800047f2:	8526                	mv	a0,s1
    800047f4:	ffffe097          	auipc	ra,0xffffe
    800047f8:	c62080e7          	jalr	-926(ra) # 80002456 <sleep>
    800047fc:	bfd9                	j	800047d2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800047fe:	0003c517          	auipc	a0,0x3c
    80004802:	55250513          	addi	a0,a0,1362 # 80040d50 <log>
    80004806:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	686080e7          	jalr	1670(ra) # 80000e8e <release>
      break;
    }
  }
}
    80004810:	60e2                	ld	ra,24(sp)
    80004812:	6442                	ld	s0,16(sp)
    80004814:	64a2                	ld	s1,8(sp)
    80004816:	6902                	ld	s2,0(sp)
    80004818:	6105                	addi	sp,sp,32
    8000481a:	8082                	ret

000000008000481c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000481c:	7139                	addi	sp,sp,-64
    8000481e:	fc06                	sd	ra,56(sp)
    80004820:	f822                	sd	s0,48(sp)
    80004822:	f426                	sd	s1,40(sp)
    80004824:	f04a                	sd	s2,32(sp)
    80004826:	ec4e                	sd	s3,24(sp)
    80004828:	e852                	sd	s4,16(sp)
    8000482a:	e456                	sd	s5,8(sp)
    8000482c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000482e:	0003c497          	auipc	s1,0x3c
    80004832:	52248493          	addi	s1,s1,1314 # 80040d50 <log>
    80004836:	8526                	mv	a0,s1
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	5a2080e7          	jalr	1442(ra) # 80000dda <acquire>
  log.outstanding -= 1;
    80004840:	509c                	lw	a5,32(s1)
    80004842:	37fd                	addiw	a5,a5,-1
    80004844:	0007891b          	sext.w	s2,a5
    80004848:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000484a:	50dc                	lw	a5,36(s1)
    8000484c:	e7b9                	bnez	a5,8000489a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000484e:	04091e63          	bnez	s2,800048aa <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004852:	0003c497          	auipc	s1,0x3c
    80004856:	4fe48493          	addi	s1,s1,1278 # 80040d50 <log>
    8000485a:	4785                	li	a5,1
    8000485c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000485e:	8526                	mv	a0,s1
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	62e080e7          	jalr	1582(ra) # 80000e8e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004868:	54dc                	lw	a5,44(s1)
    8000486a:	06f04763          	bgtz	a5,800048d8 <end_op+0xbc>
    acquire(&log.lock);
    8000486e:	0003c497          	auipc	s1,0x3c
    80004872:	4e248493          	addi	s1,s1,1250 # 80040d50 <log>
    80004876:	8526                	mv	a0,s1
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	562080e7          	jalr	1378(ra) # 80000dda <acquire>
    log.committing = 0;
    80004880:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004884:	8526                	mv	a0,s1
    80004886:	ffffe097          	auipc	ra,0xffffe
    8000488a:	c34080e7          	jalr	-972(ra) # 800024ba <wakeup>
    release(&log.lock);
    8000488e:	8526                	mv	a0,s1
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	5fe080e7          	jalr	1534(ra) # 80000e8e <release>
}
    80004898:	a03d                	j	800048c6 <end_op+0xaa>
    panic("log.committing");
    8000489a:	00004517          	auipc	a0,0x4
    8000489e:	f8650513          	addi	a0,a0,-122 # 80008820 <syscalls+0x208>
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	c9e080e7          	jalr	-866(ra) # 80000540 <panic>
    wakeup(&log);
    800048aa:	0003c497          	auipc	s1,0x3c
    800048ae:	4a648493          	addi	s1,s1,1190 # 80040d50 <log>
    800048b2:	8526                	mv	a0,s1
    800048b4:	ffffe097          	auipc	ra,0xffffe
    800048b8:	c06080e7          	jalr	-1018(ra) # 800024ba <wakeup>
  release(&log.lock);
    800048bc:	8526                	mv	a0,s1
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	5d0080e7          	jalr	1488(ra) # 80000e8e <release>
}
    800048c6:	70e2                	ld	ra,56(sp)
    800048c8:	7442                	ld	s0,48(sp)
    800048ca:	74a2                	ld	s1,40(sp)
    800048cc:	7902                	ld	s2,32(sp)
    800048ce:	69e2                	ld	s3,24(sp)
    800048d0:	6a42                	ld	s4,16(sp)
    800048d2:	6aa2                	ld	s5,8(sp)
    800048d4:	6121                	addi	sp,sp,64
    800048d6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800048d8:	0003ca97          	auipc	s5,0x3c
    800048dc:	4a8a8a93          	addi	s5,s5,1192 # 80040d80 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800048e0:	0003ca17          	auipc	s4,0x3c
    800048e4:	470a0a13          	addi	s4,s4,1136 # 80040d50 <log>
    800048e8:	018a2583          	lw	a1,24(s4)
    800048ec:	012585bb          	addw	a1,a1,s2
    800048f0:	2585                	addiw	a1,a1,1
    800048f2:	028a2503          	lw	a0,40(s4)
    800048f6:	fffff097          	auipc	ra,0xfffff
    800048fa:	cc4080e7          	jalr	-828(ra) # 800035ba <bread>
    800048fe:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004900:	000aa583          	lw	a1,0(s5)
    80004904:	028a2503          	lw	a0,40(s4)
    80004908:	fffff097          	auipc	ra,0xfffff
    8000490c:	cb2080e7          	jalr	-846(ra) # 800035ba <bread>
    80004910:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004912:	40000613          	li	a2,1024
    80004916:	05850593          	addi	a1,a0,88
    8000491a:	05848513          	addi	a0,s1,88
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	614080e7          	jalr	1556(ra) # 80000f32 <memmove>
    bwrite(to);  // write the log
    80004926:	8526                	mv	a0,s1
    80004928:	fffff097          	auipc	ra,0xfffff
    8000492c:	d84080e7          	jalr	-636(ra) # 800036ac <bwrite>
    brelse(from);
    80004930:	854e                	mv	a0,s3
    80004932:	fffff097          	auipc	ra,0xfffff
    80004936:	db8080e7          	jalr	-584(ra) # 800036ea <brelse>
    brelse(to);
    8000493a:	8526                	mv	a0,s1
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	dae080e7          	jalr	-594(ra) # 800036ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004944:	2905                	addiw	s2,s2,1
    80004946:	0a91                	addi	s5,s5,4
    80004948:	02ca2783          	lw	a5,44(s4)
    8000494c:	f8f94ee3          	blt	s2,a5,800048e8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004950:	00000097          	auipc	ra,0x0
    80004954:	c68080e7          	jalr	-920(ra) # 800045b8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004958:	4501                	li	a0,0
    8000495a:	00000097          	auipc	ra,0x0
    8000495e:	cda080e7          	jalr	-806(ra) # 80004634 <install_trans>
    log.lh.n = 0;
    80004962:	0003c797          	auipc	a5,0x3c
    80004966:	4007ad23          	sw	zero,1050(a5) # 80040d7c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000496a:	00000097          	auipc	ra,0x0
    8000496e:	c4e080e7          	jalr	-946(ra) # 800045b8 <write_head>
    80004972:	bdf5                	j	8000486e <end_op+0x52>

0000000080004974 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004974:	1101                	addi	sp,sp,-32
    80004976:	ec06                	sd	ra,24(sp)
    80004978:	e822                	sd	s0,16(sp)
    8000497a:	e426                	sd	s1,8(sp)
    8000497c:	e04a                	sd	s2,0(sp)
    8000497e:	1000                	addi	s0,sp,32
    80004980:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004982:	0003c917          	auipc	s2,0x3c
    80004986:	3ce90913          	addi	s2,s2,974 # 80040d50 <log>
    8000498a:	854a                	mv	a0,s2
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	44e080e7          	jalr	1102(ra) # 80000dda <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004994:	02c92603          	lw	a2,44(s2)
    80004998:	47f5                	li	a5,29
    8000499a:	06c7c563          	blt	a5,a2,80004a04 <log_write+0x90>
    8000499e:	0003c797          	auipc	a5,0x3c
    800049a2:	3ce7a783          	lw	a5,974(a5) # 80040d6c <log+0x1c>
    800049a6:	37fd                	addiw	a5,a5,-1
    800049a8:	04f65e63          	bge	a2,a5,80004a04 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800049ac:	0003c797          	auipc	a5,0x3c
    800049b0:	3c47a783          	lw	a5,964(a5) # 80040d70 <log+0x20>
    800049b4:	06f05063          	blez	a5,80004a14 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800049b8:	4781                	li	a5,0
    800049ba:	06c05563          	blez	a2,80004a24 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049be:	44cc                	lw	a1,12(s1)
    800049c0:	0003c717          	auipc	a4,0x3c
    800049c4:	3c070713          	addi	a4,a4,960 # 80040d80 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800049c8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049ca:	4314                	lw	a3,0(a4)
    800049cc:	04b68c63          	beq	a3,a1,80004a24 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800049d0:	2785                	addiw	a5,a5,1
    800049d2:	0711                	addi	a4,a4,4
    800049d4:	fef61be3          	bne	a2,a5,800049ca <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800049d8:	0621                	addi	a2,a2,8
    800049da:	060a                	slli	a2,a2,0x2
    800049dc:	0003c797          	auipc	a5,0x3c
    800049e0:	37478793          	addi	a5,a5,884 # 80040d50 <log>
    800049e4:	97b2                	add	a5,a5,a2
    800049e6:	44d8                	lw	a4,12(s1)
    800049e8:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800049ea:	8526                	mv	a0,s1
    800049ec:	fffff097          	auipc	ra,0xfffff
    800049f0:	d9c080e7          	jalr	-612(ra) # 80003788 <bpin>
    log.lh.n++;
    800049f4:	0003c717          	auipc	a4,0x3c
    800049f8:	35c70713          	addi	a4,a4,860 # 80040d50 <log>
    800049fc:	575c                	lw	a5,44(a4)
    800049fe:	2785                	addiw	a5,a5,1
    80004a00:	d75c                	sw	a5,44(a4)
    80004a02:	a82d                	j	80004a3c <log_write+0xc8>
    panic("too big a transaction");
    80004a04:	00004517          	auipc	a0,0x4
    80004a08:	e2c50513          	addi	a0,a0,-468 # 80008830 <syscalls+0x218>
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	b34080e7          	jalr	-1228(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004a14:	00004517          	auipc	a0,0x4
    80004a18:	e3450513          	addi	a0,a0,-460 # 80008848 <syscalls+0x230>
    80004a1c:	ffffc097          	auipc	ra,0xffffc
    80004a20:	b24080e7          	jalr	-1244(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004a24:	00878693          	addi	a3,a5,8
    80004a28:	068a                	slli	a3,a3,0x2
    80004a2a:	0003c717          	auipc	a4,0x3c
    80004a2e:	32670713          	addi	a4,a4,806 # 80040d50 <log>
    80004a32:	9736                	add	a4,a4,a3
    80004a34:	44d4                	lw	a3,12(s1)
    80004a36:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a38:	faf609e3          	beq	a2,a5,800049ea <log_write+0x76>
  }
  release(&log.lock);
    80004a3c:	0003c517          	auipc	a0,0x3c
    80004a40:	31450513          	addi	a0,a0,788 # 80040d50 <log>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	44a080e7          	jalr	1098(ra) # 80000e8e <release>
}
    80004a4c:	60e2                	ld	ra,24(sp)
    80004a4e:	6442                	ld	s0,16(sp)
    80004a50:	64a2                	ld	s1,8(sp)
    80004a52:	6902                	ld	s2,0(sp)
    80004a54:	6105                	addi	sp,sp,32
    80004a56:	8082                	ret

0000000080004a58 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a58:	1101                	addi	sp,sp,-32
    80004a5a:	ec06                	sd	ra,24(sp)
    80004a5c:	e822                	sd	s0,16(sp)
    80004a5e:	e426                	sd	s1,8(sp)
    80004a60:	e04a                	sd	s2,0(sp)
    80004a62:	1000                	addi	s0,sp,32
    80004a64:	84aa                	mv	s1,a0
    80004a66:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a68:	00004597          	auipc	a1,0x4
    80004a6c:	e0058593          	addi	a1,a1,-512 # 80008868 <syscalls+0x250>
    80004a70:	0521                	addi	a0,a0,8
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	2d8080e7          	jalr	728(ra) # 80000d4a <initlock>
  lk->name = name;
    80004a7a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a7e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a82:	0204a423          	sw	zero,40(s1)
}
    80004a86:	60e2                	ld	ra,24(sp)
    80004a88:	6442                	ld	s0,16(sp)
    80004a8a:	64a2                	ld	s1,8(sp)
    80004a8c:	6902                	ld	s2,0(sp)
    80004a8e:	6105                	addi	sp,sp,32
    80004a90:	8082                	ret

0000000080004a92 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a92:	1101                	addi	sp,sp,-32
    80004a94:	ec06                	sd	ra,24(sp)
    80004a96:	e822                	sd	s0,16(sp)
    80004a98:	e426                	sd	s1,8(sp)
    80004a9a:	e04a                	sd	s2,0(sp)
    80004a9c:	1000                	addi	s0,sp,32
    80004a9e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004aa0:	00850913          	addi	s2,a0,8
    80004aa4:	854a                	mv	a0,s2
    80004aa6:	ffffc097          	auipc	ra,0xffffc
    80004aaa:	334080e7          	jalr	820(ra) # 80000dda <acquire>
  while (lk->locked) {
    80004aae:	409c                	lw	a5,0(s1)
    80004ab0:	cb89                	beqz	a5,80004ac2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004ab2:	85ca                	mv	a1,s2
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	ffffe097          	auipc	ra,0xffffe
    80004aba:	9a0080e7          	jalr	-1632(ra) # 80002456 <sleep>
  while (lk->locked) {
    80004abe:	409c                	lw	a5,0(s1)
    80004ac0:	fbed                	bnez	a5,80004ab2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004ac2:	4785                	li	a5,1
    80004ac4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ac6:	ffffd097          	auipc	ra,0xffffd
    80004aca:	1e2080e7          	jalr	482(ra) # 80001ca8 <myproc>
    80004ace:	591c                	lw	a5,48(a0)
    80004ad0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ad2:	854a                	mv	a0,s2
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	3ba080e7          	jalr	954(ra) # 80000e8e <release>
}
    80004adc:	60e2                	ld	ra,24(sp)
    80004ade:	6442                	ld	s0,16(sp)
    80004ae0:	64a2                	ld	s1,8(sp)
    80004ae2:	6902                	ld	s2,0(sp)
    80004ae4:	6105                	addi	sp,sp,32
    80004ae6:	8082                	ret

0000000080004ae8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ae8:	1101                	addi	sp,sp,-32
    80004aea:	ec06                	sd	ra,24(sp)
    80004aec:	e822                	sd	s0,16(sp)
    80004aee:	e426                	sd	s1,8(sp)
    80004af0:	e04a                	sd	s2,0(sp)
    80004af2:	1000                	addi	s0,sp,32
    80004af4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004af6:	00850913          	addi	s2,a0,8
    80004afa:	854a                	mv	a0,s2
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	2de080e7          	jalr	734(ra) # 80000dda <acquire>
  lk->locked = 0;
    80004b04:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b08:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b0c:	8526                	mv	a0,s1
    80004b0e:	ffffe097          	auipc	ra,0xffffe
    80004b12:	9ac080e7          	jalr	-1620(ra) # 800024ba <wakeup>
  release(&lk->lk);
    80004b16:	854a                	mv	a0,s2
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	376080e7          	jalr	886(ra) # 80000e8e <release>
}
    80004b20:	60e2                	ld	ra,24(sp)
    80004b22:	6442                	ld	s0,16(sp)
    80004b24:	64a2                	ld	s1,8(sp)
    80004b26:	6902                	ld	s2,0(sp)
    80004b28:	6105                	addi	sp,sp,32
    80004b2a:	8082                	ret

0000000080004b2c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b2c:	7179                	addi	sp,sp,-48
    80004b2e:	f406                	sd	ra,40(sp)
    80004b30:	f022                	sd	s0,32(sp)
    80004b32:	ec26                	sd	s1,24(sp)
    80004b34:	e84a                	sd	s2,16(sp)
    80004b36:	e44e                	sd	s3,8(sp)
    80004b38:	1800                	addi	s0,sp,48
    80004b3a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b3c:	00850913          	addi	s2,a0,8
    80004b40:	854a                	mv	a0,s2
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	298080e7          	jalr	664(ra) # 80000dda <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b4a:	409c                	lw	a5,0(s1)
    80004b4c:	ef99                	bnez	a5,80004b6a <holdingsleep+0x3e>
    80004b4e:	4481                	li	s1,0
  release(&lk->lk);
    80004b50:	854a                	mv	a0,s2
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	33c080e7          	jalr	828(ra) # 80000e8e <release>
  return r;
}
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	70a2                	ld	ra,40(sp)
    80004b5e:	7402                	ld	s0,32(sp)
    80004b60:	64e2                	ld	s1,24(sp)
    80004b62:	6942                	ld	s2,16(sp)
    80004b64:	69a2                	ld	s3,8(sp)
    80004b66:	6145                	addi	sp,sp,48
    80004b68:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b6a:	0284a983          	lw	s3,40(s1)
    80004b6e:	ffffd097          	auipc	ra,0xffffd
    80004b72:	13a080e7          	jalr	314(ra) # 80001ca8 <myproc>
    80004b76:	5904                	lw	s1,48(a0)
    80004b78:	413484b3          	sub	s1,s1,s3
    80004b7c:	0014b493          	seqz	s1,s1
    80004b80:	bfc1                	j	80004b50 <holdingsleep+0x24>

0000000080004b82 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b82:	1141                	addi	sp,sp,-16
    80004b84:	e406                	sd	ra,8(sp)
    80004b86:	e022                	sd	s0,0(sp)
    80004b88:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b8a:	00004597          	auipc	a1,0x4
    80004b8e:	cee58593          	addi	a1,a1,-786 # 80008878 <syscalls+0x260>
    80004b92:	0003c517          	auipc	a0,0x3c
    80004b96:	30650513          	addi	a0,a0,774 # 80040e98 <ftable>
    80004b9a:	ffffc097          	auipc	ra,0xffffc
    80004b9e:	1b0080e7          	jalr	432(ra) # 80000d4a <initlock>
}
    80004ba2:	60a2                	ld	ra,8(sp)
    80004ba4:	6402                	ld	s0,0(sp)
    80004ba6:	0141                	addi	sp,sp,16
    80004ba8:	8082                	ret

0000000080004baa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004baa:	1101                	addi	sp,sp,-32
    80004bac:	ec06                	sd	ra,24(sp)
    80004bae:	e822                	sd	s0,16(sp)
    80004bb0:	e426                	sd	s1,8(sp)
    80004bb2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004bb4:	0003c517          	auipc	a0,0x3c
    80004bb8:	2e450513          	addi	a0,a0,740 # 80040e98 <ftable>
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	21e080e7          	jalr	542(ra) # 80000dda <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bc4:	0003c497          	auipc	s1,0x3c
    80004bc8:	2ec48493          	addi	s1,s1,748 # 80040eb0 <ftable+0x18>
    80004bcc:	0003d717          	auipc	a4,0x3d
    80004bd0:	28470713          	addi	a4,a4,644 # 80041e50 <disk>
    if(f->ref == 0){
    80004bd4:	40dc                	lw	a5,4(s1)
    80004bd6:	cf99                	beqz	a5,80004bf4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bd8:	02848493          	addi	s1,s1,40
    80004bdc:	fee49ce3          	bne	s1,a4,80004bd4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004be0:	0003c517          	auipc	a0,0x3c
    80004be4:	2b850513          	addi	a0,a0,696 # 80040e98 <ftable>
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	2a6080e7          	jalr	678(ra) # 80000e8e <release>
  return 0;
    80004bf0:	4481                	li	s1,0
    80004bf2:	a819                	j	80004c08 <filealloc+0x5e>
      f->ref = 1;
    80004bf4:	4785                	li	a5,1
    80004bf6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004bf8:	0003c517          	auipc	a0,0x3c
    80004bfc:	2a050513          	addi	a0,a0,672 # 80040e98 <ftable>
    80004c00:	ffffc097          	auipc	ra,0xffffc
    80004c04:	28e080e7          	jalr	654(ra) # 80000e8e <release>
}
    80004c08:	8526                	mv	a0,s1
    80004c0a:	60e2                	ld	ra,24(sp)
    80004c0c:	6442                	ld	s0,16(sp)
    80004c0e:	64a2                	ld	s1,8(sp)
    80004c10:	6105                	addi	sp,sp,32
    80004c12:	8082                	ret

0000000080004c14 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c14:	1101                	addi	sp,sp,-32
    80004c16:	ec06                	sd	ra,24(sp)
    80004c18:	e822                	sd	s0,16(sp)
    80004c1a:	e426                	sd	s1,8(sp)
    80004c1c:	1000                	addi	s0,sp,32
    80004c1e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c20:	0003c517          	auipc	a0,0x3c
    80004c24:	27850513          	addi	a0,a0,632 # 80040e98 <ftable>
    80004c28:	ffffc097          	auipc	ra,0xffffc
    80004c2c:	1b2080e7          	jalr	434(ra) # 80000dda <acquire>
  if(f->ref < 1)
    80004c30:	40dc                	lw	a5,4(s1)
    80004c32:	02f05263          	blez	a5,80004c56 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c36:	2785                	addiw	a5,a5,1
    80004c38:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c3a:	0003c517          	auipc	a0,0x3c
    80004c3e:	25e50513          	addi	a0,a0,606 # 80040e98 <ftable>
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	24c080e7          	jalr	588(ra) # 80000e8e <release>
  return f;
}
    80004c4a:	8526                	mv	a0,s1
    80004c4c:	60e2                	ld	ra,24(sp)
    80004c4e:	6442                	ld	s0,16(sp)
    80004c50:	64a2                	ld	s1,8(sp)
    80004c52:	6105                	addi	sp,sp,32
    80004c54:	8082                	ret
    panic("filedup");
    80004c56:	00004517          	auipc	a0,0x4
    80004c5a:	c2a50513          	addi	a0,a0,-982 # 80008880 <syscalls+0x268>
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	8e2080e7          	jalr	-1822(ra) # 80000540 <panic>

0000000080004c66 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c66:	7139                	addi	sp,sp,-64
    80004c68:	fc06                	sd	ra,56(sp)
    80004c6a:	f822                	sd	s0,48(sp)
    80004c6c:	f426                	sd	s1,40(sp)
    80004c6e:	f04a                	sd	s2,32(sp)
    80004c70:	ec4e                	sd	s3,24(sp)
    80004c72:	e852                	sd	s4,16(sp)
    80004c74:	e456                	sd	s5,8(sp)
    80004c76:	0080                	addi	s0,sp,64
    80004c78:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c7a:	0003c517          	auipc	a0,0x3c
    80004c7e:	21e50513          	addi	a0,a0,542 # 80040e98 <ftable>
    80004c82:	ffffc097          	auipc	ra,0xffffc
    80004c86:	158080e7          	jalr	344(ra) # 80000dda <acquire>
  if(f->ref < 1)
    80004c8a:	40dc                	lw	a5,4(s1)
    80004c8c:	06f05163          	blez	a5,80004cee <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004c90:	37fd                	addiw	a5,a5,-1
    80004c92:	0007871b          	sext.w	a4,a5
    80004c96:	c0dc                	sw	a5,4(s1)
    80004c98:	06e04363          	bgtz	a4,80004cfe <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c9c:	0004a903          	lw	s2,0(s1)
    80004ca0:	0094ca83          	lbu	s5,9(s1)
    80004ca4:	0104ba03          	ld	s4,16(s1)
    80004ca8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004cac:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004cb0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004cb4:	0003c517          	auipc	a0,0x3c
    80004cb8:	1e450513          	addi	a0,a0,484 # 80040e98 <ftable>
    80004cbc:	ffffc097          	auipc	ra,0xffffc
    80004cc0:	1d2080e7          	jalr	466(ra) # 80000e8e <release>

  if(ff.type == FD_PIPE){
    80004cc4:	4785                	li	a5,1
    80004cc6:	04f90d63          	beq	s2,a5,80004d20 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cca:	3979                	addiw	s2,s2,-2
    80004ccc:	4785                	li	a5,1
    80004cce:	0527e063          	bltu	a5,s2,80004d0e <fileclose+0xa8>
    begin_op();
    80004cd2:	00000097          	auipc	ra,0x0
    80004cd6:	acc080e7          	jalr	-1332(ra) # 8000479e <begin_op>
    iput(ff.ip);
    80004cda:	854e                	mv	a0,s3
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	2b0080e7          	jalr	688(ra) # 80003f8c <iput>
    end_op();
    80004ce4:	00000097          	auipc	ra,0x0
    80004ce8:	b38080e7          	jalr	-1224(ra) # 8000481c <end_op>
    80004cec:	a00d                	j	80004d0e <fileclose+0xa8>
    panic("fileclose");
    80004cee:	00004517          	auipc	a0,0x4
    80004cf2:	b9a50513          	addi	a0,a0,-1126 # 80008888 <syscalls+0x270>
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	84a080e7          	jalr	-1974(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004cfe:	0003c517          	auipc	a0,0x3c
    80004d02:	19a50513          	addi	a0,a0,410 # 80040e98 <ftable>
    80004d06:	ffffc097          	auipc	ra,0xffffc
    80004d0a:	188080e7          	jalr	392(ra) # 80000e8e <release>
  }
}
    80004d0e:	70e2                	ld	ra,56(sp)
    80004d10:	7442                	ld	s0,48(sp)
    80004d12:	74a2                	ld	s1,40(sp)
    80004d14:	7902                	ld	s2,32(sp)
    80004d16:	69e2                	ld	s3,24(sp)
    80004d18:	6a42                	ld	s4,16(sp)
    80004d1a:	6aa2                	ld	s5,8(sp)
    80004d1c:	6121                	addi	sp,sp,64
    80004d1e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d20:	85d6                	mv	a1,s5
    80004d22:	8552                	mv	a0,s4
    80004d24:	00000097          	auipc	ra,0x0
    80004d28:	34c080e7          	jalr	844(ra) # 80005070 <pipeclose>
    80004d2c:	b7cd                	j	80004d0e <fileclose+0xa8>

0000000080004d2e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d2e:	715d                	addi	sp,sp,-80
    80004d30:	e486                	sd	ra,72(sp)
    80004d32:	e0a2                	sd	s0,64(sp)
    80004d34:	fc26                	sd	s1,56(sp)
    80004d36:	f84a                	sd	s2,48(sp)
    80004d38:	f44e                	sd	s3,40(sp)
    80004d3a:	0880                	addi	s0,sp,80
    80004d3c:	84aa                	mv	s1,a0
    80004d3e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d40:	ffffd097          	auipc	ra,0xffffd
    80004d44:	f68080e7          	jalr	-152(ra) # 80001ca8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d48:	409c                	lw	a5,0(s1)
    80004d4a:	37f9                	addiw	a5,a5,-2
    80004d4c:	4705                	li	a4,1
    80004d4e:	04f76763          	bltu	a4,a5,80004d9c <filestat+0x6e>
    80004d52:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d54:	6c88                	ld	a0,24(s1)
    80004d56:	fffff097          	auipc	ra,0xfffff
    80004d5a:	07c080e7          	jalr	124(ra) # 80003dd2 <ilock>
    stati(f->ip, &st);
    80004d5e:	fb840593          	addi	a1,s0,-72
    80004d62:	6c88                	ld	a0,24(s1)
    80004d64:	fffff097          	auipc	ra,0xfffff
    80004d68:	2f8080e7          	jalr	760(ra) # 8000405c <stati>
    iunlock(f->ip);
    80004d6c:	6c88                	ld	a0,24(s1)
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	126080e7          	jalr	294(ra) # 80003e94 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d76:	46e1                	li	a3,24
    80004d78:	fb840613          	addi	a2,s0,-72
    80004d7c:	85ce                	mv	a1,s3
    80004d7e:	05093503          	ld	a0,80(s2)
    80004d82:	ffffd097          	auipc	ra,0xffffd
    80004d86:	ae8080e7          	jalr	-1304(ra) # 8000186a <copyout>
    80004d8a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d8e:	60a6                	ld	ra,72(sp)
    80004d90:	6406                	ld	s0,64(sp)
    80004d92:	74e2                	ld	s1,56(sp)
    80004d94:	7942                	ld	s2,48(sp)
    80004d96:	79a2                	ld	s3,40(sp)
    80004d98:	6161                	addi	sp,sp,80
    80004d9a:	8082                	ret
  return -1;
    80004d9c:	557d                	li	a0,-1
    80004d9e:	bfc5                	j	80004d8e <filestat+0x60>

0000000080004da0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004da0:	7179                	addi	sp,sp,-48
    80004da2:	f406                	sd	ra,40(sp)
    80004da4:	f022                	sd	s0,32(sp)
    80004da6:	ec26                	sd	s1,24(sp)
    80004da8:	e84a                	sd	s2,16(sp)
    80004daa:	e44e                	sd	s3,8(sp)
    80004dac:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004dae:	00854783          	lbu	a5,8(a0)
    80004db2:	c3d5                	beqz	a5,80004e56 <fileread+0xb6>
    80004db4:	84aa                	mv	s1,a0
    80004db6:	89ae                	mv	s3,a1
    80004db8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dba:	411c                	lw	a5,0(a0)
    80004dbc:	4705                	li	a4,1
    80004dbe:	04e78963          	beq	a5,a4,80004e10 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dc2:	470d                	li	a4,3
    80004dc4:	04e78d63          	beq	a5,a4,80004e1e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004dc8:	4709                	li	a4,2
    80004dca:	06e79e63          	bne	a5,a4,80004e46 <fileread+0xa6>
    ilock(f->ip);
    80004dce:	6d08                	ld	a0,24(a0)
    80004dd0:	fffff097          	auipc	ra,0xfffff
    80004dd4:	002080e7          	jalr	2(ra) # 80003dd2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dd8:	874a                	mv	a4,s2
    80004dda:	5094                	lw	a3,32(s1)
    80004ddc:	864e                	mv	a2,s3
    80004dde:	4585                	li	a1,1
    80004de0:	6c88                	ld	a0,24(s1)
    80004de2:	fffff097          	auipc	ra,0xfffff
    80004de6:	2a4080e7          	jalr	676(ra) # 80004086 <readi>
    80004dea:	892a                	mv	s2,a0
    80004dec:	00a05563          	blez	a0,80004df6 <fileread+0x56>
      f->off += r;
    80004df0:	509c                	lw	a5,32(s1)
    80004df2:	9fa9                	addw	a5,a5,a0
    80004df4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004df6:	6c88                	ld	a0,24(s1)
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	09c080e7          	jalr	156(ra) # 80003e94 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004e00:	854a                	mv	a0,s2
    80004e02:	70a2                	ld	ra,40(sp)
    80004e04:	7402                	ld	s0,32(sp)
    80004e06:	64e2                	ld	s1,24(sp)
    80004e08:	6942                	ld	s2,16(sp)
    80004e0a:	69a2                	ld	s3,8(sp)
    80004e0c:	6145                	addi	sp,sp,48
    80004e0e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e10:	6908                	ld	a0,16(a0)
    80004e12:	00000097          	auipc	ra,0x0
    80004e16:	3c6080e7          	jalr	966(ra) # 800051d8 <piperead>
    80004e1a:	892a                	mv	s2,a0
    80004e1c:	b7d5                	j	80004e00 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e1e:	02451783          	lh	a5,36(a0)
    80004e22:	03079693          	slli	a3,a5,0x30
    80004e26:	92c1                	srli	a3,a3,0x30
    80004e28:	4725                	li	a4,9
    80004e2a:	02d76863          	bltu	a4,a3,80004e5a <fileread+0xba>
    80004e2e:	0792                	slli	a5,a5,0x4
    80004e30:	0003c717          	auipc	a4,0x3c
    80004e34:	fc870713          	addi	a4,a4,-56 # 80040df8 <devsw>
    80004e38:	97ba                	add	a5,a5,a4
    80004e3a:	639c                	ld	a5,0(a5)
    80004e3c:	c38d                	beqz	a5,80004e5e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004e3e:	4505                	li	a0,1
    80004e40:	9782                	jalr	a5
    80004e42:	892a                	mv	s2,a0
    80004e44:	bf75                	j	80004e00 <fileread+0x60>
    panic("fileread");
    80004e46:	00004517          	auipc	a0,0x4
    80004e4a:	a5250513          	addi	a0,a0,-1454 # 80008898 <syscalls+0x280>
    80004e4e:	ffffb097          	auipc	ra,0xffffb
    80004e52:	6f2080e7          	jalr	1778(ra) # 80000540 <panic>
    return -1;
    80004e56:	597d                	li	s2,-1
    80004e58:	b765                	j	80004e00 <fileread+0x60>
      return -1;
    80004e5a:	597d                	li	s2,-1
    80004e5c:	b755                	j	80004e00 <fileread+0x60>
    80004e5e:	597d                	li	s2,-1
    80004e60:	b745                	j	80004e00 <fileread+0x60>

0000000080004e62 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e62:	715d                	addi	sp,sp,-80
    80004e64:	e486                	sd	ra,72(sp)
    80004e66:	e0a2                	sd	s0,64(sp)
    80004e68:	fc26                	sd	s1,56(sp)
    80004e6a:	f84a                	sd	s2,48(sp)
    80004e6c:	f44e                	sd	s3,40(sp)
    80004e6e:	f052                	sd	s4,32(sp)
    80004e70:	ec56                	sd	s5,24(sp)
    80004e72:	e85a                	sd	s6,16(sp)
    80004e74:	e45e                	sd	s7,8(sp)
    80004e76:	e062                	sd	s8,0(sp)
    80004e78:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e7a:	00954783          	lbu	a5,9(a0)
    80004e7e:	10078663          	beqz	a5,80004f8a <filewrite+0x128>
    80004e82:	892a                	mv	s2,a0
    80004e84:	8b2e                	mv	s6,a1
    80004e86:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e88:	411c                	lw	a5,0(a0)
    80004e8a:	4705                	li	a4,1
    80004e8c:	02e78263          	beq	a5,a4,80004eb0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e90:	470d                	li	a4,3
    80004e92:	02e78663          	beq	a5,a4,80004ebe <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e96:	4709                	li	a4,2
    80004e98:	0ee79163          	bne	a5,a4,80004f7a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e9c:	0ac05d63          	blez	a2,80004f56 <filewrite+0xf4>
    int i = 0;
    80004ea0:	4981                	li	s3,0
    80004ea2:	6b85                	lui	s7,0x1
    80004ea4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004ea8:	6c05                	lui	s8,0x1
    80004eaa:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004eae:	a861                	j	80004f46 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004eb0:	6908                	ld	a0,16(a0)
    80004eb2:	00000097          	auipc	ra,0x0
    80004eb6:	22e080e7          	jalr	558(ra) # 800050e0 <pipewrite>
    80004eba:	8a2a                	mv	s4,a0
    80004ebc:	a045                	j	80004f5c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ebe:	02451783          	lh	a5,36(a0)
    80004ec2:	03079693          	slli	a3,a5,0x30
    80004ec6:	92c1                	srli	a3,a3,0x30
    80004ec8:	4725                	li	a4,9
    80004eca:	0cd76263          	bltu	a4,a3,80004f8e <filewrite+0x12c>
    80004ece:	0792                	slli	a5,a5,0x4
    80004ed0:	0003c717          	auipc	a4,0x3c
    80004ed4:	f2870713          	addi	a4,a4,-216 # 80040df8 <devsw>
    80004ed8:	97ba                	add	a5,a5,a4
    80004eda:	679c                	ld	a5,8(a5)
    80004edc:	cbdd                	beqz	a5,80004f92 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ede:	4505                	li	a0,1
    80004ee0:	9782                	jalr	a5
    80004ee2:	8a2a                	mv	s4,a0
    80004ee4:	a8a5                	j	80004f5c <filewrite+0xfa>
    80004ee6:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004eea:	00000097          	auipc	ra,0x0
    80004eee:	8b4080e7          	jalr	-1868(ra) # 8000479e <begin_op>
      ilock(f->ip);
    80004ef2:	01893503          	ld	a0,24(s2)
    80004ef6:	fffff097          	auipc	ra,0xfffff
    80004efa:	edc080e7          	jalr	-292(ra) # 80003dd2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004efe:	8756                	mv	a4,s5
    80004f00:	02092683          	lw	a3,32(s2)
    80004f04:	01698633          	add	a2,s3,s6
    80004f08:	4585                	li	a1,1
    80004f0a:	01893503          	ld	a0,24(s2)
    80004f0e:	fffff097          	auipc	ra,0xfffff
    80004f12:	270080e7          	jalr	624(ra) # 8000417e <writei>
    80004f16:	84aa                	mv	s1,a0
    80004f18:	00a05763          	blez	a0,80004f26 <filewrite+0xc4>
        f->off += r;
    80004f1c:	02092783          	lw	a5,32(s2)
    80004f20:	9fa9                	addw	a5,a5,a0
    80004f22:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f26:	01893503          	ld	a0,24(s2)
    80004f2a:	fffff097          	auipc	ra,0xfffff
    80004f2e:	f6a080e7          	jalr	-150(ra) # 80003e94 <iunlock>
      end_op();
    80004f32:	00000097          	auipc	ra,0x0
    80004f36:	8ea080e7          	jalr	-1814(ra) # 8000481c <end_op>

      if(r != n1){
    80004f3a:	009a9f63          	bne	s5,s1,80004f58 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004f3e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f42:	0149db63          	bge	s3,s4,80004f58 <filewrite+0xf6>
      int n1 = n - i;
    80004f46:	413a04bb          	subw	s1,s4,s3
    80004f4a:	0004879b          	sext.w	a5,s1
    80004f4e:	f8fbdce3          	bge	s7,a5,80004ee6 <filewrite+0x84>
    80004f52:	84e2                	mv	s1,s8
    80004f54:	bf49                	j	80004ee6 <filewrite+0x84>
    int i = 0;
    80004f56:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f58:	013a1f63          	bne	s4,s3,80004f76 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f5c:	8552                	mv	a0,s4
    80004f5e:	60a6                	ld	ra,72(sp)
    80004f60:	6406                	ld	s0,64(sp)
    80004f62:	74e2                	ld	s1,56(sp)
    80004f64:	7942                	ld	s2,48(sp)
    80004f66:	79a2                	ld	s3,40(sp)
    80004f68:	7a02                	ld	s4,32(sp)
    80004f6a:	6ae2                	ld	s5,24(sp)
    80004f6c:	6b42                	ld	s6,16(sp)
    80004f6e:	6ba2                	ld	s7,8(sp)
    80004f70:	6c02                	ld	s8,0(sp)
    80004f72:	6161                	addi	sp,sp,80
    80004f74:	8082                	ret
    ret = (i == n ? n : -1);
    80004f76:	5a7d                	li	s4,-1
    80004f78:	b7d5                	j	80004f5c <filewrite+0xfa>
    panic("filewrite");
    80004f7a:	00004517          	auipc	a0,0x4
    80004f7e:	92e50513          	addi	a0,a0,-1746 # 800088a8 <syscalls+0x290>
    80004f82:	ffffb097          	auipc	ra,0xffffb
    80004f86:	5be080e7          	jalr	1470(ra) # 80000540 <panic>
    return -1;
    80004f8a:	5a7d                	li	s4,-1
    80004f8c:	bfc1                	j	80004f5c <filewrite+0xfa>
      return -1;
    80004f8e:	5a7d                	li	s4,-1
    80004f90:	b7f1                	j	80004f5c <filewrite+0xfa>
    80004f92:	5a7d                	li	s4,-1
    80004f94:	b7e1                	j	80004f5c <filewrite+0xfa>

0000000080004f96 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f96:	7179                	addi	sp,sp,-48
    80004f98:	f406                	sd	ra,40(sp)
    80004f9a:	f022                	sd	s0,32(sp)
    80004f9c:	ec26                	sd	s1,24(sp)
    80004f9e:	e84a                	sd	s2,16(sp)
    80004fa0:	e44e                	sd	s3,8(sp)
    80004fa2:	e052                	sd	s4,0(sp)
    80004fa4:	1800                	addi	s0,sp,48
    80004fa6:	84aa                	mv	s1,a0
    80004fa8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004faa:	0005b023          	sd	zero,0(a1)
    80004fae:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004fb2:	00000097          	auipc	ra,0x0
    80004fb6:	bf8080e7          	jalr	-1032(ra) # 80004baa <filealloc>
    80004fba:	e088                	sd	a0,0(s1)
    80004fbc:	c551                	beqz	a0,80005048 <pipealloc+0xb2>
    80004fbe:	00000097          	auipc	ra,0x0
    80004fc2:	bec080e7          	jalr	-1044(ra) # 80004baa <filealloc>
    80004fc6:	00aa3023          	sd	a0,0(s4)
    80004fca:	c92d                	beqz	a0,8000503c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004fcc:	ffffc097          	auipc	ra,0xffffc
    80004fd0:	cc6080e7          	jalr	-826(ra) # 80000c92 <kalloc>
    80004fd4:	892a                	mv	s2,a0
    80004fd6:	c125                	beqz	a0,80005036 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004fd8:	4985                	li	s3,1
    80004fda:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004fde:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004fe2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004fe6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004fea:	00004597          	auipc	a1,0x4
    80004fee:	8ce58593          	addi	a1,a1,-1842 # 800088b8 <syscalls+0x2a0>
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	d58080e7          	jalr	-680(ra) # 80000d4a <initlock>
  (*f0)->type = FD_PIPE;
    80004ffa:	609c                	ld	a5,0(s1)
    80004ffc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005000:	609c                	ld	a5,0(s1)
    80005002:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005006:	609c                	ld	a5,0(s1)
    80005008:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000500c:	609c                	ld	a5,0(s1)
    8000500e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005012:	000a3783          	ld	a5,0(s4)
    80005016:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000501a:	000a3783          	ld	a5,0(s4)
    8000501e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005022:	000a3783          	ld	a5,0(s4)
    80005026:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000502a:	000a3783          	ld	a5,0(s4)
    8000502e:	0127b823          	sd	s2,16(a5)
  return 0;
    80005032:	4501                	li	a0,0
    80005034:	a025                	j	8000505c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005036:	6088                	ld	a0,0(s1)
    80005038:	e501                	bnez	a0,80005040 <pipealloc+0xaa>
    8000503a:	a039                	j	80005048 <pipealloc+0xb2>
    8000503c:	6088                	ld	a0,0(s1)
    8000503e:	c51d                	beqz	a0,8000506c <pipealloc+0xd6>
    fileclose(*f0);
    80005040:	00000097          	auipc	ra,0x0
    80005044:	c26080e7          	jalr	-986(ra) # 80004c66 <fileclose>
  if(*f1)
    80005048:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000504c:	557d                	li	a0,-1
  if(*f1)
    8000504e:	c799                	beqz	a5,8000505c <pipealloc+0xc6>
    fileclose(*f1);
    80005050:	853e                	mv	a0,a5
    80005052:	00000097          	auipc	ra,0x0
    80005056:	c14080e7          	jalr	-1004(ra) # 80004c66 <fileclose>
  return -1;
    8000505a:	557d                	li	a0,-1
}
    8000505c:	70a2                	ld	ra,40(sp)
    8000505e:	7402                	ld	s0,32(sp)
    80005060:	64e2                	ld	s1,24(sp)
    80005062:	6942                	ld	s2,16(sp)
    80005064:	69a2                	ld	s3,8(sp)
    80005066:	6a02                	ld	s4,0(sp)
    80005068:	6145                	addi	sp,sp,48
    8000506a:	8082                	ret
  return -1;
    8000506c:	557d                	li	a0,-1
    8000506e:	b7fd                	j	8000505c <pipealloc+0xc6>

0000000080005070 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005070:	1101                	addi	sp,sp,-32
    80005072:	ec06                	sd	ra,24(sp)
    80005074:	e822                	sd	s0,16(sp)
    80005076:	e426                	sd	s1,8(sp)
    80005078:	e04a                	sd	s2,0(sp)
    8000507a:	1000                	addi	s0,sp,32
    8000507c:	84aa                	mv	s1,a0
    8000507e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005080:	ffffc097          	auipc	ra,0xffffc
    80005084:	d5a080e7          	jalr	-678(ra) # 80000dda <acquire>
  if(writable){
    80005088:	02090d63          	beqz	s2,800050c2 <pipeclose+0x52>
    pi->writeopen = 0;
    8000508c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005090:	21848513          	addi	a0,s1,536
    80005094:	ffffd097          	auipc	ra,0xffffd
    80005098:	426080e7          	jalr	1062(ra) # 800024ba <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000509c:	2204b783          	ld	a5,544(s1)
    800050a0:	eb95                	bnez	a5,800050d4 <pipeclose+0x64>
    release(&pi->lock);
    800050a2:	8526                	mv	a0,s1
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	dea080e7          	jalr	-534(ra) # 80000e8e <release>
    kfree((char*)pi);
    800050ac:	8526                	mv	a0,s1
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	aa4080e7          	jalr	-1372(ra) # 80000b52 <kfree>
  } else
    release(&pi->lock);
}
    800050b6:	60e2                	ld	ra,24(sp)
    800050b8:	6442                	ld	s0,16(sp)
    800050ba:	64a2                	ld	s1,8(sp)
    800050bc:	6902                	ld	s2,0(sp)
    800050be:	6105                	addi	sp,sp,32
    800050c0:	8082                	ret
    pi->readopen = 0;
    800050c2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800050c6:	21c48513          	addi	a0,s1,540
    800050ca:	ffffd097          	auipc	ra,0xffffd
    800050ce:	3f0080e7          	jalr	1008(ra) # 800024ba <wakeup>
    800050d2:	b7e9                	j	8000509c <pipeclose+0x2c>
    release(&pi->lock);
    800050d4:	8526                	mv	a0,s1
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	db8080e7          	jalr	-584(ra) # 80000e8e <release>
}
    800050de:	bfe1                	j	800050b6 <pipeclose+0x46>

00000000800050e0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800050e0:	711d                	addi	sp,sp,-96
    800050e2:	ec86                	sd	ra,88(sp)
    800050e4:	e8a2                	sd	s0,80(sp)
    800050e6:	e4a6                	sd	s1,72(sp)
    800050e8:	e0ca                	sd	s2,64(sp)
    800050ea:	fc4e                	sd	s3,56(sp)
    800050ec:	f852                	sd	s4,48(sp)
    800050ee:	f456                	sd	s5,40(sp)
    800050f0:	f05a                	sd	s6,32(sp)
    800050f2:	ec5e                	sd	s7,24(sp)
    800050f4:	e862                	sd	s8,16(sp)
    800050f6:	1080                	addi	s0,sp,96
    800050f8:	84aa                	mv	s1,a0
    800050fa:	8aae                	mv	s5,a1
    800050fc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800050fe:	ffffd097          	auipc	ra,0xffffd
    80005102:	baa080e7          	jalr	-1110(ra) # 80001ca8 <myproc>
    80005106:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005108:	8526                	mv	a0,s1
    8000510a:	ffffc097          	auipc	ra,0xffffc
    8000510e:	cd0080e7          	jalr	-816(ra) # 80000dda <acquire>
  while(i < n){
    80005112:	0b405663          	blez	s4,800051be <pipewrite+0xde>
  int i = 0;
    80005116:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005118:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000511a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000511e:	21c48b93          	addi	s7,s1,540
    80005122:	a089                	j	80005164 <pipewrite+0x84>
      release(&pi->lock);
    80005124:	8526                	mv	a0,s1
    80005126:	ffffc097          	auipc	ra,0xffffc
    8000512a:	d68080e7          	jalr	-664(ra) # 80000e8e <release>
      return -1;
    8000512e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005130:	854a                	mv	a0,s2
    80005132:	60e6                	ld	ra,88(sp)
    80005134:	6446                	ld	s0,80(sp)
    80005136:	64a6                	ld	s1,72(sp)
    80005138:	6906                	ld	s2,64(sp)
    8000513a:	79e2                	ld	s3,56(sp)
    8000513c:	7a42                	ld	s4,48(sp)
    8000513e:	7aa2                	ld	s5,40(sp)
    80005140:	7b02                	ld	s6,32(sp)
    80005142:	6be2                	ld	s7,24(sp)
    80005144:	6c42                	ld	s8,16(sp)
    80005146:	6125                	addi	sp,sp,96
    80005148:	8082                	ret
      wakeup(&pi->nread);
    8000514a:	8562                	mv	a0,s8
    8000514c:	ffffd097          	auipc	ra,0xffffd
    80005150:	36e080e7          	jalr	878(ra) # 800024ba <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005154:	85a6                	mv	a1,s1
    80005156:	855e                	mv	a0,s7
    80005158:	ffffd097          	auipc	ra,0xffffd
    8000515c:	2fe080e7          	jalr	766(ra) # 80002456 <sleep>
  while(i < n){
    80005160:	07495063          	bge	s2,s4,800051c0 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005164:	2204a783          	lw	a5,544(s1)
    80005168:	dfd5                	beqz	a5,80005124 <pipewrite+0x44>
    8000516a:	854e                	mv	a0,s3
    8000516c:	ffffd097          	auipc	ra,0xffffd
    80005170:	592080e7          	jalr	1426(ra) # 800026fe <killed>
    80005174:	f945                	bnez	a0,80005124 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005176:	2184a783          	lw	a5,536(s1)
    8000517a:	21c4a703          	lw	a4,540(s1)
    8000517e:	2007879b          	addiw	a5,a5,512
    80005182:	fcf704e3          	beq	a4,a5,8000514a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005186:	4685                	li	a3,1
    80005188:	01590633          	add	a2,s2,s5
    8000518c:	faf40593          	addi	a1,s0,-81
    80005190:	0509b503          	ld	a0,80(s3)
    80005194:	ffffc097          	auipc	ra,0xffffc
    80005198:	762080e7          	jalr	1890(ra) # 800018f6 <copyin>
    8000519c:	03650263          	beq	a0,s6,800051c0 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800051a0:	21c4a783          	lw	a5,540(s1)
    800051a4:	0017871b          	addiw	a4,a5,1
    800051a8:	20e4ae23          	sw	a4,540(s1)
    800051ac:	1ff7f793          	andi	a5,a5,511
    800051b0:	97a6                	add	a5,a5,s1
    800051b2:	faf44703          	lbu	a4,-81(s0)
    800051b6:	00e78c23          	sb	a4,24(a5)
      i++;
    800051ba:	2905                	addiw	s2,s2,1
    800051bc:	b755                	j	80005160 <pipewrite+0x80>
  int i = 0;
    800051be:	4901                	li	s2,0
  wakeup(&pi->nread);
    800051c0:	21848513          	addi	a0,s1,536
    800051c4:	ffffd097          	auipc	ra,0xffffd
    800051c8:	2f6080e7          	jalr	758(ra) # 800024ba <wakeup>
  release(&pi->lock);
    800051cc:	8526                	mv	a0,s1
    800051ce:	ffffc097          	auipc	ra,0xffffc
    800051d2:	cc0080e7          	jalr	-832(ra) # 80000e8e <release>
  return i;
    800051d6:	bfa9                	j	80005130 <pipewrite+0x50>

00000000800051d8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800051d8:	715d                	addi	sp,sp,-80
    800051da:	e486                	sd	ra,72(sp)
    800051dc:	e0a2                	sd	s0,64(sp)
    800051de:	fc26                	sd	s1,56(sp)
    800051e0:	f84a                	sd	s2,48(sp)
    800051e2:	f44e                	sd	s3,40(sp)
    800051e4:	f052                	sd	s4,32(sp)
    800051e6:	ec56                	sd	s5,24(sp)
    800051e8:	e85a                	sd	s6,16(sp)
    800051ea:	0880                	addi	s0,sp,80
    800051ec:	84aa                	mv	s1,a0
    800051ee:	892e                	mv	s2,a1
    800051f0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800051f2:	ffffd097          	auipc	ra,0xffffd
    800051f6:	ab6080e7          	jalr	-1354(ra) # 80001ca8 <myproc>
    800051fa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800051fc:	8526                	mv	a0,s1
    800051fe:	ffffc097          	auipc	ra,0xffffc
    80005202:	bdc080e7          	jalr	-1060(ra) # 80000dda <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005206:	2184a703          	lw	a4,536(s1)
    8000520a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000520e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005212:	02f71763          	bne	a4,a5,80005240 <piperead+0x68>
    80005216:	2244a783          	lw	a5,548(s1)
    8000521a:	c39d                	beqz	a5,80005240 <piperead+0x68>
    if(killed(pr)){
    8000521c:	8552                	mv	a0,s4
    8000521e:	ffffd097          	auipc	ra,0xffffd
    80005222:	4e0080e7          	jalr	1248(ra) # 800026fe <killed>
    80005226:	e949                	bnez	a0,800052b8 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005228:	85a6                	mv	a1,s1
    8000522a:	854e                	mv	a0,s3
    8000522c:	ffffd097          	auipc	ra,0xffffd
    80005230:	22a080e7          	jalr	554(ra) # 80002456 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005234:	2184a703          	lw	a4,536(s1)
    80005238:	21c4a783          	lw	a5,540(s1)
    8000523c:	fcf70de3          	beq	a4,a5,80005216 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005240:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005242:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005244:	05505463          	blez	s5,8000528c <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005248:	2184a783          	lw	a5,536(s1)
    8000524c:	21c4a703          	lw	a4,540(s1)
    80005250:	02f70e63          	beq	a4,a5,8000528c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005254:	0017871b          	addiw	a4,a5,1
    80005258:	20e4ac23          	sw	a4,536(s1)
    8000525c:	1ff7f793          	andi	a5,a5,511
    80005260:	97a6                	add	a5,a5,s1
    80005262:	0187c783          	lbu	a5,24(a5)
    80005266:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000526a:	4685                	li	a3,1
    8000526c:	fbf40613          	addi	a2,s0,-65
    80005270:	85ca                	mv	a1,s2
    80005272:	050a3503          	ld	a0,80(s4)
    80005276:	ffffc097          	auipc	ra,0xffffc
    8000527a:	5f4080e7          	jalr	1524(ra) # 8000186a <copyout>
    8000527e:	01650763          	beq	a0,s6,8000528c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005282:	2985                	addiw	s3,s3,1
    80005284:	0905                	addi	s2,s2,1
    80005286:	fd3a91e3          	bne	s5,s3,80005248 <piperead+0x70>
    8000528a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000528c:	21c48513          	addi	a0,s1,540
    80005290:	ffffd097          	auipc	ra,0xffffd
    80005294:	22a080e7          	jalr	554(ra) # 800024ba <wakeup>
  release(&pi->lock);
    80005298:	8526                	mv	a0,s1
    8000529a:	ffffc097          	auipc	ra,0xffffc
    8000529e:	bf4080e7          	jalr	-1036(ra) # 80000e8e <release>
  return i;
}
    800052a2:	854e                	mv	a0,s3
    800052a4:	60a6                	ld	ra,72(sp)
    800052a6:	6406                	ld	s0,64(sp)
    800052a8:	74e2                	ld	s1,56(sp)
    800052aa:	7942                	ld	s2,48(sp)
    800052ac:	79a2                	ld	s3,40(sp)
    800052ae:	7a02                	ld	s4,32(sp)
    800052b0:	6ae2                	ld	s5,24(sp)
    800052b2:	6b42                	ld	s6,16(sp)
    800052b4:	6161                	addi	sp,sp,80
    800052b6:	8082                	ret
      release(&pi->lock);
    800052b8:	8526                	mv	a0,s1
    800052ba:	ffffc097          	auipc	ra,0xffffc
    800052be:	bd4080e7          	jalr	-1068(ra) # 80000e8e <release>
      return -1;
    800052c2:	59fd                	li	s3,-1
    800052c4:	bff9                	j	800052a2 <piperead+0xca>

00000000800052c6 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800052c6:	1141                	addi	sp,sp,-16
    800052c8:	e422                	sd	s0,8(sp)
    800052ca:	0800                	addi	s0,sp,16
    800052cc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800052ce:	8905                	andi	a0,a0,1
    800052d0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800052d2:	8b89                	andi	a5,a5,2
    800052d4:	c399                	beqz	a5,800052da <flags2perm+0x14>
      perm |= PTE_W;
    800052d6:	00456513          	ori	a0,a0,4
    return perm;
}
    800052da:	6422                	ld	s0,8(sp)
    800052dc:	0141                	addi	sp,sp,16
    800052de:	8082                	ret

00000000800052e0 <exec>:

int
exec(char *path, char **argv)
{
    800052e0:	de010113          	addi	sp,sp,-544
    800052e4:	20113c23          	sd	ra,536(sp)
    800052e8:	20813823          	sd	s0,528(sp)
    800052ec:	20913423          	sd	s1,520(sp)
    800052f0:	21213023          	sd	s2,512(sp)
    800052f4:	ffce                	sd	s3,504(sp)
    800052f6:	fbd2                	sd	s4,496(sp)
    800052f8:	f7d6                	sd	s5,488(sp)
    800052fa:	f3da                	sd	s6,480(sp)
    800052fc:	efde                	sd	s7,472(sp)
    800052fe:	ebe2                	sd	s8,464(sp)
    80005300:	e7e6                	sd	s9,456(sp)
    80005302:	e3ea                	sd	s10,448(sp)
    80005304:	ff6e                	sd	s11,440(sp)
    80005306:	1400                	addi	s0,sp,544
    80005308:	892a                	mv	s2,a0
    8000530a:	dea43423          	sd	a0,-536(s0)
    8000530e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005312:	ffffd097          	auipc	ra,0xffffd
    80005316:	996080e7          	jalr	-1642(ra) # 80001ca8 <myproc>
    8000531a:	84aa                	mv	s1,a0

  begin_op();
    8000531c:	fffff097          	auipc	ra,0xfffff
    80005320:	482080e7          	jalr	1154(ra) # 8000479e <begin_op>

  if((ip = namei(path)) == 0){
    80005324:	854a                	mv	a0,s2
    80005326:	fffff097          	auipc	ra,0xfffff
    8000532a:	258080e7          	jalr	600(ra) # 8000457e <namei>
    8000532e:	c93d                	beqz	a0,800053a4 <exec+0xc4>
    80005330:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	aa0080e7          	jalr	-1376(ra) # 80003dd2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000533a:	04000713          	li	a4,64
    8000533e:	4681                	li	a3,0
    80005340:	e5040613          	addi	a2,s0,-432
    80005344:	4581                	li	a1,0
    80005346:	8556                	mv	a0,s5
    80005348:	fffff097          	auipc	ra,0xfffff
    8000534c:	d3e080e7          	jalr	-706(ra) # 80004086 <readi>
    80005350:	04000793          	li	a5,64
    80005354:	00f51a63          	bne	a0,a5,80005368 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005358:	e5042703          	lw	a4,-432(s0)
    8000535c:	464c47b7          	lui	a5,0x464c4
    80005360:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005364:	04f70663          	beq	a4,a5,800053b0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005368:	8556                	mv	a0,s5
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	cca080e7          	jalr	-822(ra) # 80004034 <iunlockput>
    end_op();
    80005372:	fffff097          	auipc	ra,0xfffff
    80005376:	4aa080e7          	jalr	1194(ra) # 8000481c <end_op>
  }
  return -1;
    8000537a:	557d                	li	a0,-1
}
    8000537c:	21813083          	ld	ra,536(sp)
    80005380:	21013403          	ld	s0,528(sp)
    80005384:	20813483          	ld	s1,520(sp)
    80005388:	20013903          	ld	s2,512(sp)
    8000538c:	79fe                	ld	s3,504(sp)
    8000538e:	7a5e                	ld	s4,496(sp)
    80005390:	7abe                	ld	s5,488(sp)
    80005392:	7b1e                	ld	s6,480(sp)
    80005394:	6bfe                	ld	s7,472(sp)
    80005396:	6c5e                	ld	s8,464(sp)
    80005398:	6cbe                	ld	s9,456(sp)
    8000539a:	6d1e                	ld	s10,448(sp)
    8000539c:	7dfa                	ld	s11,440(sp)
    8000539e:	22010113          	addi	sp,sp,544
    800053a2:	8082                	ret
    end_op();
    800053a4:	fffff097          	auipc	ra,0xfffff
    800053a8:	478080e7          	jalr	1144(ra) # 8000481c <end_op>
    return -1;
    800053ac:	557d                	li	a0,-1
    800053ae:	b7f9                	j	8000537c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800053b0:	8526                	mv	a0,s1
    800053b2:	ffffd097          	auipc	ra,0xffffd
    800053b6:	9ba080e7          	jalr	-1606(ra) # 80001d6c <proc_pagetable>
    800053ba:	8b2a                	mv	s6,a0
    800053bc:	d555                	beqz	a0,80005368 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053be:	e7042783          	lw	a5,-400(s0)
    800053c2:	e8845703          	lhu	a4,-376(s0)
    800053c6:	c735                	beqz	a4,80005432 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053c8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053ca:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800053ce:	6a05                	lui	s4,0x1
    800053d0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800053d4:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800053d8:	6d85                	lui	s11,0x1
    800053da:	7d7d                	lui	s10,0xfffff
    800053dc:	ac3d                	j	8000561a <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800053de:	00003517          	auipc	a0,0x3
    800053e2:	4e250513          	addi	a0,a0,1250 # 800088c0 <syscalls+0x2a8>
    800053e6:	ffffb097          	auipc	ra,0xffffb
    800053ea:	15a080e7          	jalr	346(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800053ee:	874a                	mv	a4,s2
    800053f0:	009c86bb          	addw	a3,s9,s1
    800053f4:	4581                	li	a1,0
    800053f6:	8556                	mv	a0,s5
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	c8e080e7          	jalr	-882(ra) # 80004086 <readi>
    80005400:	2501                	sext.w	a0,a0
    80005402:	1aa91963          	bne	s2,a0,800055b4 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005406:	009d84bb          	addw	s1,s11,s1
    8000540a:	013d09bb          	addw	s3,s10,s3
    8000540e:	1f74f663          	bgeu	s1,s7,800055fa <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005412:	02049593          	slli	a1,s1,0x20
    80005416:	9181                	srli	a1,a1,0x20
    80005418:	95e2                	add	a1,a1,s8
    8000541a:	855a                	mv	a0,s6
    8000541c:	ffffc097          	auipc	ra,0xffffc
    80005420:	e44080e7          	jalr	-444(ra) # 80001260 <walkaddr>
    80005424:	862a                	mv	a2,a0
    if(pa == 0)
    80005426:	dd45                	beqz	a0,800053de <exec+0xfe>
      n = PGSIZE;
    80005428:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000542a:	fd49f2e3          	bgeu	s3,s4,800053ee <exec+0x10e>
      n = sz - i;
    8000542e:	894e                	mv	s2,s3
    80005430:	bf7d                	j	800053ee <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005432:	4901                	li	s2,0
  iunlockput(ip);
    80005434:	8556                	mv	a0,s5
    80005436:	fffff097          	auipc	ra,0xfffff
    8000543a:	bfe080e7          	jalr	-1026(ra) # 80004034 <iunlockput>
  end_op();
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	3de080e7          	jalr	990(ra) # 8000481c <end_op>
  p = myproc();
    80005446:	ffffd097          	auipc	ra,0xffffd
    8000544a:	862080e7          	jalr	-1950(ra) # 80001ca8 <myproc>
    8000544e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005450:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005454:	6785                	lui	a5,0x1
    80005456:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005458:	97ca                	add	a5,a5,s2
    8000545a:	777d                	lui	a4,0xfffff
    8000545c:	8ff9                	and	a5,a5,a4
    8000545e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005462:	4691                	li	a3,4
    80005464:	6609                	lui	a2,0x2
    80005466:	963e                	add	a2,a2,a5
    80005468:	85be                	mv	a1,a5
    8000546a:	855a                	mv	a0,s6
    8000546c:	ffffc097          	auipc	ra,0xffffc
    80005470:	1a8080e7          	jalr	424(ra) # 80001614 <uvmalloc>
    80005474:	8c2a                	mv	s8,a0
  ip = 0;
    80005476:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005478:	12050e63          	beqz	a0,800055b4 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000547c:	75f9                	lui	a1,0xffffe
    8000547e:	95aa                	add	a1,a1,a0
    80005480:	855a                	mv	a0,s6
    80005482:	ffffc097          	auipc	ra,0xffffc
    80005486:	3b6080e7          	jalr	950(ra) # 80001838 <uvmclear>
  stackbase = sp - PGSIZE;
    8000548a:	7afd                	lui	s5,0xfffff
    8000548c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000548e:	df043783          	ld	a5,-528(s0)
    80005492:	6388                	ld	a0,0(a5)
    80005494:	c925                	beqz	a0,80005504 <exec+0x224>
    80005496:	e9040993          	addi	s3,s0,-368
    8000549a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000549e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800054a0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800054a2:	ffffc097          	auipc	ra,0xffffc
    800054a6:	bb0080e7          	jalr	-1104(ra) # 80001052 <strlen>
    800054aa:	0015079b          	addiw	a5,a0,1
    800054ae:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054b2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800054b6:	13596663          	bltu	s2,s5,800055e2 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054ba:	df043d83          	ld	s11,-528(s0)
    800054be:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800054c2:	8552                	mv	a0,s4
    800054c4:	ffffc097          	auipc	ra,0xffffc
    800054c8:	b8e080e7          	jalr	-1138(ra) # 80001052 <strlen>
    800054cc:	0015069b          	addiw	a3,a0,1
    800054d0:	8652                	mv	a2,s4
    800054d2:	85ca                	mv	a1,s2
    800054d4:	855a                	mv	a0,s6
    800054d6:	ffffc097          	auipc	ra,0xffffc
    800054da:	394080e7          	jalr	916(ra) # 8000186a <copyout>
    800054de:	10054663          	bltz	a0,800055ea <exec+0x30a>
    ustack[argc] = sp;
    800054e2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800054e6:	0485                	addi	s1,s1,1
    800054e8:	008d8793          	addi	a5,s11,8
    800054ec:	def43823          	sd	a5,-528(s0)
    800054f0:	008db503          	ld	a0,8(s11)
    800054f4:	c911                	beqz	a0,80005508 <exec+0x228>
    if(argc >= MAXARG)
    800054f6:	09a1                	addi	s3,s3,8
    800054f8:	fb3c95e3          	bne	s9,s3,800054a2 <exec+0x1c2>
  sz = sz1;
    800054fc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005500:	4a81                	li	s5,0
    80005502:	a84d                	j	800055b4 <exec+0x2d4>
  sp = sz;
    80005504:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005506:	4481                	li	s1,0
  ustack[argc] = 0;
    80005508:	00349793          	slli	a5,s1,0x3
    8000550c:	f9078793          	addi	a5,a5,-112
    80005510:	97a2                	add	a5,a5,s0
    80005512:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005516:	00148693          	addi	a3,s1,1
    8000551a:	068e                	slli	a3,a3,0x3
    8000551c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005520:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005524:	01597663          	bgeu	s2,s5,80005530 <exec+0x250>
  sz = sz1;
    80005528:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000552c:	4a81                	li	s5,0
    8000552e:	a059                	j	800055b4 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005530:	e9040613          	addi	a2,s0,-368
    80005534:	85ca                	mv	a1,s2
    80005536:	855a                	mv	a0,s6
    80005538:	ffffc097          	auipc	ra,0xffffc
    8000553c:	332080e7          	jalr	818(ra) # 8000186a <copyout>
    80005540:	0a054963          	bltz	a0,800055f2 <exec+0x312>
  p->trapframe->a1 = sp;
    80005544:	058bb783          	ld	a5,88(s7)
    80005548:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000554c:	de843783          	ld	a5,-536(s0)
    80005550:	0007c703          	lbu	a4,0(a5)
    80005554:	cf11                	beqz	a4,80005570 <exec+0x290>
    80005556:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005558:	02f00693          	li	a3,47
    8000555c:	a039                	j	8000556a <exec+0x28a>
      last = s+1;
    8000555e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005562:	0785                	addi	a5,a5,1
    80005564:	fff7c703          	lbu	a4,-1(a5)
    80005568:	c701                	beqz	a4,80005570 <exec+0x290>
    if(*s == '/')
    8000556a:	fed71ce3          	bne	a4,a3,80005562 <exec+0x282>
    8000556e:	bfc5                	j	8000555e <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005570:	4641                	li	a2,16
    80005572:	de843583          	ld	a1,-536(s0)
    80005576:	158b8513          	addi	a0,s7,344
    8000557a:	ffffc097          	auipc	ra,0xffffc
    8000557e:	aa6080e7          	jalr	-1370(ra) # 80001020 <safestrcpy>
  oldpagetable = p->pagetable;
    80005582:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005586:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000558a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000558e:	058bb783          	ld	a5,88(s7)
    80005592:	e6843703          	ld	a4,-408(s0)
    80005596:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005598:	058bb783          	ld	a5,88(s7)
    8000559c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800055a0:	85ea                	mv	a1,s10
    800055a2:	ffffd097          	auipc	ra,0xffffd
    800055a6:	866080e7          	jalr	-1946(ra) # 80001e08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800055aa:	0004851b          	sext.w	a0,s1
    800055ae:	b3f9                	j	8000537c <exec+0x9c>
    800055b0:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800055b4:	df843583          	ld	a1,-520(s0)
    800055b8:	855a                	mv	a0,s6
    800055ba:	ffffd097          	auipc	ra,0xffffd
    800055be:	84e080e7          	jalr	-1970(ra) # 80001e08 <proc_freepagetable>
  if(ip){
    800055c2:	da0a93e3          	bnez	s5,80005368 <exec+0x88>
  return -1;
    800055c6:	557d                	li	a0,-1
    800055c8:	bb55                	j	8000537c <exec+0x9c>
    800055ca:	df243c23          	sd	s2,-520(s0)
    800055ce:	b7dd                	j	800055b4 <exec+0x2d4>
    800055d0:	df243c23          	sd	s2,-520(s0)
    800055d4:	b7c5                	j	800055b4 <exec+0x2d4>
    800055d6:	df243c23          	sd	s2,-520(s0)
    800055da:	bfe9                	j	800055b4 <exec+0x2d4>
    800055dc:	df243c23          	sd	s2,-520(s0)
    800055e0:	bfd1                	j	800055b4 <exec+0x2d4>
  sz = sz1;
    800055e2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055e6:	4a81                	li	s5,0
    800055e8:	b7f1                	j	800055b4 <exec+0x2d4>
  sz = sz1;
    800055ea:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055ee:	4a81                	li	s5,0
    800055f0:	b7d1                	j	800055b4 <exec+0x2d4>
  sz = sz1;
    800055f2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055f6:	4a81                	li	s5,0
    800055f8:	bf75                	j	800055b4 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055fa:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055fe:	e0843783          	ld	a5,-504(s0)
    80005602:	0017869b          	addiw	a3,a5,1
    80005606:	e0d43423          	sd	a3,-504(s0)
    8000560a:	e0043783          	ld	a5,-512(s0)
    8000560e:	0387879b          	addiw	a5,a5,56
    80005612:	e8845703          	lhu	a4,-376(s0)
    80005616:	e0e6dfe3          	bge	a3,a4,80005434 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000561a:	2781                	sext.w	a5,a5
    8000561c:	e0f43023          	sd	a5,-512(s0)
    80005620:	03800713          	li	a4,56
    80005624:	86be                	mv	a3,a5
    80005626:	e1840613          	addi	a2,s0,-488
    8000562a:	4581                	li	a1,0
    8000562c:	8556                	mv	a0,s5
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	a58080e7          	jalr	-1448(ra) # 80004086 <readi>
    80005636:	03800793          	li	a5,56
    8000563a:	f6f51be3          	bne	a0,a5,800055b0 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000563e:	e1842783          	lw	a5,-488(s0)
    80005642:	4705                	li	a4,1
    80005644:	fae79de3          	bne	a5,a4,800055fe <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005648:	e4043483          	ld	s1,-448(s0)
    8000564c:	e3843783          	ld	a5,-456(s0)
    80005650:	f6f4ede3          	bltu	s1,a5,800055ca <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005654:	e2843783          	ld	a5,-472(s0)
    80005658:	94be                	add	s1,s1,a5
    8000565a:	f6f4ebe3          	bltu	s1,a5,800055d0 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000565e:	de043703          	ld	a4,-544(s0)
    80005662:	8ff9                	and	a5,a5,a4
    80005664:	fbad                	bnez	a5,800055d6 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005666:	e1c42503          	lw	a0,-484(s0)
    8000566a:	00000097          	auipc	ra,0x0
    8000566e:	c5c080e7          	jalr	-932(ra) # 800052c6 <flags2perm>
    80005672:	86aa                	mv	a3,a0
    80005674:	8626                	mv	a2,s1
    80005676:	85ca                	mv	a1,s2
    80005678:	855a                	mv	a0,s6
    8000567a:	ffffc097          	auipc	ra,0xffffc
    8000567e:	f9a080e7          	jalr	-102(ra) # 80001614 <uvmalloc>
    80005682:	dea43c23          	sd	a0,-520(s0)
    80005686:	d939                	beqz	a0,800055dc <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005688:	e2843c03          	ld	s8,-472(s0)
    8000568c:	e2042c83          	lw	s9,-480(s0)
    80005690:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005694:	f60b83e3          	beqz	s7,800055fa <exec+0x31a>
    80005698:	89de                	mv	s3,s7
    8000569a:	4481                	li	s1,0
    8000569c:	bb9d                	j	80005412 <exec+0x132>

000000008000569e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000569e:	7179                	addi	sp,sp,-48
    800056a0:	f406                	sd	ra,40(sp)
    800056a2:	f022                	sd	s0,32(sp)
    800056a4:	ec26                	sd	s1,24(sp)
    800056a6:	e84a                	sd	s2,16(sp)
    800056a8:	1800                	addi	s0,sp,48
    800056aa:	892e                	mv	s2,a1
    800056ac:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800056ae:	fdc40593          	addi	a1,s0,-36
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	ac0080e7          	jalr	-1344(ra) # 80003172 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800056ba:	fdc42703          	lw	a4,-36(s0)
    800056be:	47bd                	li	a5,15
    800056c0:	02e7eb63          	bltu	a5,a4,800056f6 <argfd+0x58>
    800056c4:	ffffc097          	auipc	ra,0xffffc
    800056c8:	5e4080e7          	jalr	1508(ra) # 80001ca8 <myproc>
    800056cc:	fdc42703          	lw	a4,-36(s0)
    800056d0:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffbd08a>
    800056d4:	078e                	slli	a5,a5,0x3
    800056d6:	953e                	add	a0,a0,a5
    800056d8:	611c                	ld	a5,0(a0)
    800056da:	c385                	beqz	a5,800056fa <argfd+0x5c>
    return -1;
  if(pfd)
    800056dc:	00090463          	beqz	s2,800056e4 <argfd+0x46>
    *pfd = fd;
    800056e0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800056e4:	4501                	li	a0,0
  if(pf)
    800056e6:	c091                	beqz	s1,800056ea <argfd+0x4c>
    *pf = f;
    800056e8:	e09c                	sd	a5,0(s1)
}
    800056ea:	70a2                	ld	ra,40(sp)
    800056ec:	7402                	ld	s0,32(sp)
    800056ee:	64e2                	ld	s1,24(sp)
    800056f0:	6942                	ld	s2,16(sp)
    800056f2:	6145                	addi	sp,sp,48
    800056f4:	8082                	ret
    return -1;
    800056f6:	557d                	li	a0,-1
    800056f8:	bfcd                	j	800056ea <argfd+0x4c>
    800056fa:	557d                	li	a0,-1
    800056fc:	b7fd                	j	800056ea <argfd+0x4c>

00000000800056fe <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800056fe:	1101                	addi	sp,sp,-32
    80005700:	ec06                	sd	ra,24(sp)
    80005702:	e822                	sd	s0,16(sp)
    80005704:	e426                	sd	s1,8(sp)
    80005706:	1000                	addi	s0,sp,32
    80005708:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000570a:	ffffc097          	auipc	ra,0xffffc
    8000570e:	59e080e7          	jalr	1438(ra) # 80001ca8 <myproc>
    80005712:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005714:	0d050793          	addi	a5,a0,208
    80005718:	4501                	li	a0,0
    8000571a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000571c:	6398                	ld	a4,0(a5)
    8000571e:	cb19                	beqz	a4,80005734 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005720:	2505                	addiw	a0,a0,1
    80005722:	07a1                	addi	a5,a5,8
    80005724:	fed51ce3          	bne	a0,a3,8000571c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005728:	557d                	li	a0,-1
}
    8000572a:	60e2                	ld	ra,24(sp)
    8000572c:	6442                	ld	s0,16(sp)
    8000572e:	64a2                	ld	s1,8(sp)
    80005730:	6105                	addi	sp,sp,32
    80005732:	8082                	ret
      p->ofile[fd] = f;
    80005734:	01a50793          	addi	a5,a0,26
    80005738:	078e                	slli	a5,a5,0x3
    8000573a:	963e                	add	a2,a2,a5
    8000573c:	e204                	sd	s1,0(a2)
      return fd;
    8000573e:	b7f5                	j	8000572a <fdalloc+0x2c>

0000000080005740 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005740:	715d                	addi	sp,sp,-80
    80005742:	e486                	sd	ra,72(sp)
    80005744:	e0a2                	sd	s0,64(sp)
    80005746:	fc26                	sd	s1,56(sp)
    80005748:	f84a                	sd	s2,48(sp)
    8000574a:	f44e                	sd	s3,40(sp)
    8000574c:	f052                	sd	s4,32(sp)
    8000574e:	ec56                	sd	s5,24(sp)
    80005750:	e85a                	sd	s6,16(sp)
    80005752:	0880                	addi	s0,sp,80
    80005754:	8b2e                	mv	s6,a1
    80005756:	89b2                	mv	s3,a2
    80005758:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000575a:	fb040593          	addi	a1,s0,-80
    8000575e:	fffff097          	auipc	ra,0xfffff
    80005762:	e3e080e7          	jalr	-450(ra) # 8000459c <nameiparent>
    80005766:	84aa                	mv	s1,a0
    80005768:	14050f63          	beqz	a0,800058c6 <create+0x186>
    return 0;

  ilock(dp);
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	666080e7          	jalr	1638(ra) # 80003dd2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005774:	4601                	li	a2,0
    80005776:	fb040593          	addi	a1,s0,-80
    8000577a:	8526                	mv	a0,s1
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	b3a080e7          	jalr	-1222(ra) # 800042b6 <dirlookup>
    80005784:	8aaa                	mv	s5,a0
    80005786:	c931                	beqz	a0,800057da <create+0x9a>
    iunlockput(dp);
    80005788:	8526                	mv	a0,s1
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	8aa080e7          	jalr	-1878(ra) # 80004034 <iunlockput>
    ilock(ip);
    80005792:	8556                	mv	a0,s5
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	63e080e7          	jalr	1598(ra) # 80003dd2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000579c:	000b059b          	sext.w	a1,s6
    800057a0:	4789                	li	a5,2
    800057a2:	02f59563          	bne	a1,a5,800057cc <create+0x8c>
    800057a6:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffbd0b4>
    800057aa:	37f9                	addiw	a5,a5,-2
    800057ac:	17c2                	slli	a5,a5,0x30
    800057ae:	93c1                	srli	a5,a5,0x30
    800057b0:	4705                	li	a4,1
    800057b2:	00f76d63          	bltu	a4,a5,800057cc <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800057b6:	8556                	mv	a0,s5
    800057b8:	60a6                	ld	ra,72(sp)
    800057ba:	6406                	ld	s0,64(sp)
    800057bc:	74e2                	ld	s1,56(sp)
    800057be:	7942                	ld	s2,48(sp)
    800057c0:	79a2                	ld	s3,40(sp)
    800057c2:	7a02                	ld	s4,32(sp)
    800057c4:	6ae2                	ld	s5,24(sp)
    800057c6:	6b42                	ld	s6,16(sp)
    800057c8:	6161                	addi	sp,sp,80
    800057ca:	8082                	ret
    iunlockput(ip);
    800057cc:	8556                	mv	a0,s5
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	866080e7          	jalr	-1946(ra) # 80004034 <iunlockput>
    return 0;
    800057d6:	4a81                	li	s5,0
    800057d8:	bff9                	j	800057b6 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800057da:	85da                	mv	a1,s6
    800057dc:	4088                	lw	a0,0(s1)
    800057de:	ffffe097          	auipc	ra,0xffffe
    800057e2:	456080e7          	jalr	1110(ra) # 80003c34 <ialloc>
    800057e6:	8a2a                	mv	s4,a0
    800057e8:	c539                	beqz	a0,80005836 <create+0xf6>
  ilock(ip);
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	5e8080e7          	jalr	1512(ra) # 80003dd2 <ilock>
  ip->major = major;
    800057f2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800057f6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800057fa:	4905                	li	s2,1
    800057fc:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005800:	8552                	mv	a0,s4
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	504080e7          	jalr	1284(ra) # 80003d06 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000580a:	000b059b          	sext.w	a1,s6
    8000580e:	03258b63          	beq	a1,s2,80005844 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005812:	004a2603          	lw	a2,4(s4)
    80005816:	fb040593          	addi	a1,s0,-80
    8000581a:	8526                	mv	a0,s1
    8000581c:	fffff097          	auipc	ra,0xfffff
    80005820:	cb0080e7          	jalr	-848(ra) # 800044cc <dirlink>
    80005824:	06054f63          	bltz	a0,800058a2 <create+0x162>
  iunlockput(dp);
    80005828:	8526                	mv	a0,s1
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	80a080e7          	jalr	-2038(ra) # 80004034 <iunlockput>
  return ip;
    80005832:	8ad2                	mv	s5,s4
    80005834:	b749                	j	800057b6 <create+0x76>
    iunlockput(dp);
    80005836:	8526                	mv	a0,s1
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	7fc080e7          	jalr	2044(ra) # 80004034 <iunlockput>
    return 0;
    80005840:	8ad2                	mv	s5,s4
    80005842:	bf95                	j	800057b6 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005844:	004a2603          	lw	a2,4(s4)
    80005848:	00003597          	auipc	a1,0x3
    8000584c:	09858593          	addi	a1,a1,152 # 800088e0 <syscalls+0x2c8>
    80005850:	8552                	mv	a0,s4
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	c7a080e7          	jalr	-902(ra) # 800044cc <dirlink>
    8000585a:	04054463          	bltz	a0,800058a2 <create+0x162>
    8000585e:	40d0                	lw	a2,4(s1)
    80005860:	00003597          	auipc	a1,0x3
    80005864:	08858593          	addi	a1,a1,136 # 800088e8 <syscalls+0x2d0>
    80005868:	8552                	mv	a0,s4
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	c62080e7          	jalr	-926(ra) # 800044cc <dirlink>
    80005872:	02054863          	bltz	a0,800058a2 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005876:	004a2603          	lw	a2,4(s4)
    8000587a:	fb040593          	addi	a1,s0,-80
    8000587e:	8526                	mv	a0,s1
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	c4c080e7          	jalr	-948(ra) # 800044cc <dirlink>
    80005888:	00054d63          	bltz	a0,800058a2 <create+0x162>
    dp->nlink++;  // for ".."
    8000588c:	04a4d783          	lhu	a5,74(s1)
    80005890:	2785                	addiw	a5,a5,1
    80005892:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	46e080e7          	jalr	1134(ra) # 80003d06 <iupdate>
    800058a0:	b761                	j	80005828 <create+0xe8>
  ip->nlink = 0;
    800058a2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800058a6:	8552                	mv	a0,s4
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	45e080e7          	jalr	1118(ra) # 80003d06 <iupdate>
  iunlockput(ip);
    800058b0:	8552                	mv	a0,s4
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	782080e7          	jalr	1922(ra) # 80004034 <iunlockput>
  iunlockput(dp);
    800058ba:	8526                	mv	a0,s1
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	778080e7          	jalr	1912(ra) # 80004034 <iunlockput>
  return 0;
    800058c4:	bdcd                	j	800057b6 <create+0x76>
    return 0;
    800058c6:	8aaa                	mv	s5,a0
    800058c8:	b5fd                	j	800057b6 <create+0x76>

00000000800058ca <sys_dup>:
{
    800058ca:	7179                	addi	sp,sp,-48
    800058cc:	f406                	sd	ra,40(sp)
    800058ce:	f022                	sd	s0,32(sp)
    800058d0:	ec26                	sd	s1,24(sp)
    800058d2:	e84a                	sd	s2,16(sp)
    800058d4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800058d6:	fd840613          	addi	a2,s0,-40
    800058da:	4581                	li	a1,0
    800058dc:	4501                	li	a0,0
    800058de:	00000097          	auipc	ra,0x0
    800058e2:	dc0080e7          	jalr	-576(ra) # 8000569e <argfd>
    return -1;
    800058e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800058e8:	02054363          	bltz	a0,8000590e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800058ec:	fd843903          	ld	s2,-40(s0)
    800058f0:	854a                	mv	a0,s2
    800058f2:	00000097          	auipc	ra,0x0
    800058f6:	e0c080e7          	jalr	-500(ra) # 800056fe <fdalloc>
    800058fa:	84aa                	mv	s1,a0
    return -1;
    800058fc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800058fe:	00054863          	bltz	a0,8000590e <sys_dup+0x44>
  filedup(f);
    80005902:	854a                	mv	a0,s2
    80005904:	fffff097          	auipc	ra,0xfffff
    80005908:	310080e7          	jalr	784(ra) # 80004c14 <filedup>
  return fd;
    8000590c:	87a6                	mv	a5,s1
}
    8000590e:	853e                	mv	a0,a5
    80005910:	70a2                	ld	ra,40(sp)
    80005912:	7402                	ld	s0,32(sp)
    80005914:	64e2                	ld	s1,24(sp)
    80005916:	6942                	ld	s2,16(sp)
    80005918:	6145                	addi	sp,sp,48
    8000591a:	8082                	ret

000000008000591c <sys_read>:
{
    8000591c:	7179                	addi	sp,sp,-48
    8000591e:	f406                	sd	ra,40(sp)
    80005920:	f022                	sd	s0,32(sp)
    80005922:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005924:	fd840593          	addi	a1,s0,-40
    80005928:	4505                	li	a0,1
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	868080e7          	jalr	-1944(ra) # 80003192 <argaddr>
  argint(2, &n);
    80005932:	fe440593          	addi	a1,s0,-28
    80005936:	4509                	li	a0,2
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	83a080e7          	jalr	-1990(ra) # 80003172 <argint>
  if(argfd(0, 0, &f) < 0)
    80005940:	fe840613          	addi	a2,s0,-24
    80005944:	4581                	li	a1,0
    80005946:	4501                	li	a0,0
    80005948:	00000097          	auipc	ra,0x0
    8000594c:	d56080e7          	jalr	-682(ra) # 8000569e <argfd>
    80005950:	87aa                	mv	a5,a0
    return -1;
    80005952:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005954:	0007cc63          	bltz	a5,8000596c <sys_read+0x50>
  return fileread(f, p, n);
    80005958:	fe442603          	lw	a2,-28(s0)
    8000595c:	fd843583          	ld	a1,-40(s0)
    80005960:	fe843503          	ld	a0,-24(s0)
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	43c080e7          	jalr	1084(ra) # 80004da0 <fileread>
}
    8000596c:	70a2                	ld	ra,40(sp)
    8000596e:	7402                	ld	s0,32(sp)
    80005970:	6145                	addi	sp,sp,48
    80005972:	8082                	ret

0000000080005974 <sys_write>:
{
    80005974:	7179                	addi	sp,sp,-48
    80005976:	f406                	sd	ra,40(sp)
    80005978:	f022                	sd	s0,32(sp)
    8000597a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000597c:	fd840593          	addi	a1,s0,-40
    80005980:	4505                	li	a0,1
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	810080e7          	jalr	-2032(ra) # 80003192 <argaddr>
  argint(2, &n);
    8000598a:	fe440593          	addi	a1,s0,-28
    8000598e:	4509                	li	a0,2
    80005990:	ffffd097          	auipc	ra,0xffffd
    80005994:	7e2080e7          	jalr	2018(ra) # 80003172 <argint>
  if(argfd(0, 0, &f) < 0)
    80005998:	fe840613          	addi	a2,s0,-24
    8000599c:	4581                	li	a1,0
    8000599e:	4501                	li	a0,0
    800059a0:	00000097          	auipc	ra,0x0
    800059a4:	cfe080e7          	jalr	-770(ra) # 8000569e <argfd>
    800059a8:	87aa                	mv	a5,a0
    return -1;
    800059aa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059ac:	0007cc63          	bltz	a5,800059c4 <sys_write+0x50>
  return filewrite(f, p, n);
    800059b0:	fe442603          	lw	a2,-28(s0)
    800059b4:	fd843583          	ld	a1,-40(s0)
    800059b8:	fe843503          	ld	a0,-24(s0)
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	4a6080e7          	jalr	1190(ra) # 80004e62 <filewrite>
}
    800059c4:	70a2                	ld	ra,40(sp)
    800059c6:	7402                	ld	s0,32(sp)
    800059c8:	6145                	addi	sp,sp,48
    800059ca:	8082                	ret

00000000800059cc <sys_close>:
{
    800059cc:	1101                	addi	sp,sp,-32
    800059ce:	ec06                	sd	ra,24(sp)
    800059d0:	e822                	sd	s0,16(sp)
    800059d2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800059d4:	fe040613          	addi	a2,s0,-32
    800059d8:	fec40593          	addi	a1,s0,-20
    800059dc:	4501                	li	a0,0
    800059de:	00000097          	auipc	ra,0x0
    800059e2:	cc0080e7          	jalr	-832(ra) # 8000569e <argfd>
    return -1;
    800059e6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800059e8:	02054463          	bltz	a0,80005a10 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800059ec:	ffffc097          	auipc	ra,0xffffc
    800059f0:	2bc080e7          	jalr	700(ra) # 80001ca8 <myproc>
    800059f4:	fec42783          	lw	a5,-20(s0)
    800059f8:	07e9                	addi	a5,a5,26
    800059fa:	078e                	slli	a5,a5,0x3
    800059fc:	953e                	add	a0,a0,a5
    800059fe:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005a02:	fe043503          	ld	a0,-32(s0)
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	260080e7          	jalr	608(ra) # 80004c66 <fileclose>
  return 0;
    80005a0e:	4781                	li	a5,0
}
    80005a10:	853e                	mv	a0,a5
    80005a12:	60e2                	ld	ra,24(sp)
    80005a14:	6442                	ld	s0,16(sp)
    80005a16:	6105                	addi	sp,sp,32
    80005a18:	8082                	ret

0000000080005a1a <sys_fstat>:
{
    80005a1a:	1101                	addi	sp,sp,-32
    80005a1c:	ec06                	sd	ra,24(sp)
    80005a1e:	e822                	sd	s0,16(sp)
    80005a20:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005a22:	fe040593          	addi	a1,s0,-32
    80005a26:	4505                	li	a0,1
    80005a28:	ffffd097          	auipc	ra,0xffffd
    80005a2c:	76a080e7          	jalr	1898(ra) # 80003192 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005a30:	fe840613          	addi	a2,s0,-24
    80005a34:	4581                	li	a1,0
    80005a36:	4501                	li	a0,0
    80005a38:	00000097          	auipc	ra,0x0
    80005a3c:	c66080e7          	jalr	-922(ra) # 8000569e <argfd>
    80005a40:	87aa                	mv	a5,a0
    return -1;
    80005a42:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a44:	0007ca63          	bltz	a5,80005a58 <sys_fstat+0x3e>
  return filestat(f, st);
    80005a48:	fe043583          	ld	a1,-32(s0)
    80005a4c:	fe843503          	ld	a0,-24(s0)
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	2de080e7          	jalr	734(ra) # 80004d2e <filestat>
}
    80005a58:	60e2                	ld	ra,24(sp)
    80005a5a:	6442                	ld	s0,16(sp)
    80005a5c:	6105                	addi	sp,sp,32
    80005a5e:	8082                	ret

0000000080005a60 <sys_link>:
{
    80005a60:	7169                	addi	sp,sp,-304
    80005a62:	f606                	sd	ra,296(sp)
    80005a64:	f222                	sd	s0,288(sp)
    80005a66:	ee26                	sd	s1,280(sp)
    80005a68:	ea4a                	sd	s2,272(sp)
    80005a6a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a6c:	08000613          	li	a2,128
    80005a70:	ed040593          	addi	a1,s0,-304
    80005a74:	4501                	li	a0,0
    80005a76:	ffffd097          	auipc	ra,0xffffd
    80005a7a:	73c080e7          	jalr	1852(ra) # 800031b2 <argstr>
    return -1;
    80005a7e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a80:	10054e63          	bltz	a0,80005b9c <sys_link+0x13c>
    80005a84:	08000613          	li	a2,128
    80005a88:	f5040593          	addi	a1,s0,-176
    80005a8c:	4505                	li	a0,1
    80005a8e:	ffffd097          	auipc	ra,0xffffd
    80005a92:	724080e7          	jalr	1828(ra) # 800031b2 <argstr>
    return -1;
    80005a96:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a98:	10054263          	bltz	a0,80005b9c <sys_link+0x13c>
  begin_op();
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	d02080e7          	jalr	-766(ra) # 8000479e <begin_op>
  if((ip = namei(old)) == 0){
    80005aa4:	ed040513          	addi	a0,s0,-304
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	ad6080e7          	jalr	-1322(ra) # 8000457e <namei>
    80005ab0:	84aa                	mv	s1,a0
    80005ab2:	c551                	beqz	a0,80005b3e <sys_link+0xde>
  ilock(ip);
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	31e080e7          	jalr	798(ra) # 80003dd2 <ilock>
  if(ip->type == T_DIR){
    80005abc:	04449703          	lh	a4,68(s1)
    80005ac0:	4785                	li	a5,1
    80005ac2:	08f70463          	beq	a4,a5,80005b4a <sys_link+0xea>
  ip->nlink++;
    80005ac6:	04a4d783          	lhu	a5,74(s1)
    80005aca:	2785                	addiw	a5,a5,1
    80005acc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ad0:	8526                	mv	a0,s1
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	234080e7          	jalr	564(ra) # 80003d06 <iupdate>
  iunlock(ip);
    80005ada:	8526                	mv	a0,s1
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	3b8080e7          	jalr	952(ra) # 80003e94 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ae4:	fd040593          	addi	a1,s0,-48
    80005ae8:	f5040513          	addi	a0,s0,-176
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	ab0080e7          	jalr	-1360(ra) # 8000459c <nameiparent>
    80005af4:	892a                	mv	s2,a0
    80005af6:	c935                	beqz	a0,80005b6a <sys_link+0x10a>
  ilock(dp);
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	2da080e7          	jalr	730(ra) # 80003dd2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005b00:	00092703          	lw	a4,0(s2)
    80005b04:	409c                	lw	a5,0(s1)
    80005b06:	04f71d63          	bne	a4,a5,80005b60 <sys_link+0x100>
    80005b0a:	40d0                	lw	a2,4(s1)
    80005b0c:	fd040593          	addi	a1,s0,-48
    80005b10:	854a                	mv	a0,s2
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	9ba080e7          	jalr	-1606(ra) # 800044cc <dirlink>
    80005b1a:	04054363          	bltz	a0,80005b60 <sys_link+0x100>
  iunlockput(dp);
    80005b1e:	854a                	mv	a0,s2
    80005b20:	ffffe097          	auipc	ra,0xffffe
    80005b24:	514080e7          	jalr	1300(ra) # 80004034 <iunlockput>
  iput(ip);
    80005b28:	8526                	mv	a0,s1
    80005b2a:	ffffe097          	auipc	ra,0xffffe
    80005b2e:	462080e7          	jalr	1122(ra) # 80003f8c <iput>
  end_op();
    80005b32:	fffff097          	auipc	ra,0xfffff
    80005b36:	cea080e7          	jalr	-790(ra) # 8000481c <end_op>
  return 0;
    80005b3a:	4781                	li	a5,0
    80005b3c:	a085                	j	80005b9c <sys_link+0x13c>
    end_op();
    80005b3e:	fffff097          	auipc	ra,0xfffff
    80005b42:	cde080e7          	jalr	-802(ra) # 8000481c <end_op>
    return -1;
    80005b46:	57fd                	li	a5,-1
    80005b48:	a891                	j	80005b9c <sys_link+0x13c>
    iunlockput(ip);
    80005b4a:	8526                	mv	a0,s1
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	4e8080e7          	jalr	1256(ra) # 80004034 <iunlockput>
    end_op();
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	cc8080e7          	jalr	-824(ra) # 8000481c <end_op>
    return -1;
    80005b5c:	57fd                	li	a5,-1
    80005b5e:	a83d                	j	80005b9c <sys_link+0x13c>
    iunlockput(dp);
    80005b60:	854a                	mv	a0,s2
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	4d2080e7          	jalr	1234(ra) # 80004034 <iunlockput>
  ilock(ip);
    80005b6a:	8526                	mv	a0,s1
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	266080e7          	jalr	614(ra) # 80003dd2 <ilock>
  ip->nlink--;
    80005b74:	04a4d783          	lhu	a5,74(s1)
    80005b78:	37fd                	addiw	a5,a5,-1
    80005b7a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b7e:	8526                	mv	a0,s1
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	186080e7          	jalr	390(ra) # 80003d06 <iupdate>
  iunlockput(ip);
    80005b88:	8526                	mv	a0,s1
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	4aa080e7          	jalr	1194(ra) # 80004034 <iunlockput>
  end_op();
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	c8a080e7          	jalr	-886(ra) # 8000481c <end_op>
  return -1;
    80005b9a:	57fd                	li	a5,-1
}
    80005b9c:	853e                	mv	a0,a5
    80005b9e:	70b2                	ld	ra,296(sp)
    80005ba0:	7412                	ld	s0,288(sp)
    80005ba2:	64f2                	ld	s1,280(sp)
    80005ba4:	6952                	ld	s2,272(sp)
    80005ba6:	6155                	addi	sp,sp,304
    80005ba8:	8082                	ret

0000000080005baa <sys_unlink>:
{
    80005baa:	7151                	addi	sp,sp,-240
    80005bac:	f586                	sd	ra,232(sp)
    80005bae:	f1a2                	sd	s0,224(sp)
    80005bb0:	eda6                	sd	s1,216(sp)
    80005bb2:	e9ca                	sd	s2,208(sp)
    80005bb4:	e5ce                	sd	s3,200(sp)
    80005bb6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005bb8:	08000613          	li	a2,128
    80005bbc:	f3040593          	addi	a1,s0,-208
    80005bc0:	4501                	li	a0,0
    80005bc2:	ffffd097          	auipc	ra,0xffffd
    80005bc6:	5f0080e7          	jalr	1520(ra) # 800031b2 <argstr>
    80005bca:	18054163          	bltz	a0,80005d4c <sys_unlink+0x1a2>
  begin_op();
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	bd0080e7          	jalr	-1072(ra) # 8000479e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005bd6:	fb040593          	addi	a1,s0,-80
    80005bda:	f3040513          	addi	a0,s0,-208
    80005bde:	fffff097          	auipc	ra,0xfffff
    80005be2:	9be080e7          	jalr	-1602(ra) # 8000459c <nameiparent>
    80005be6:	84aa                	mv	s1,a0
    80005be8:	c979                	beqz	a0,80005cbe <sys_unlink+0x114>
  ilock(dp);
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	1e8080e7          	jalr	488(ra) # 80003dd2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005bf2:	00003597          	auipc	a1,0x3
    80005bf6:	cee58593          	addi	a1,a1,-786 # 800088e0 <syscalls+0x2c8>
    80005bfa:	fb040513          	addi	a0,s0,-80
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	69e080e7          	jalr	1694(ra) # 8000429c <namecmp>
    80005c06:	14050a63          	beqz	a0,80005d5a <sys_unlink+0x1b0>
    80005c0a:	00003597          	auipc	a1,0x3
    80005c0e:	cde58593          	addi	a1,a1,-802 # 800088e8 <syscalls+0x2d0>
    80005c12:	fb040513          	addi	a0,s0,-80
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	686080e7          	jalr	1670(ra) # 8000429c <namecmp>
    80005c1e:	12050e63          	beqz	a0,80005d5a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005c22:	f2c40613          	addi	a2,s0,-212
    80005c26:	fb040593          	addi	a1,s0,-80
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	68a080e7          	jalr	1674(ra) # 800042b6 <dirlookup>
    80005c34:	892a                	mv	s2,a0
    80005c36:	12050263          	beqz	a0,80005d5a <sys_unlink+0x1b0>
  ilock(ip);
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	198080e7          	jalr	408(ra) # 80003dd2 <ilock>
  if(ip->nlink < 1)
    80005c42:	04a91783          	lh	a5,74(s2)
    80005c46:	08f05263          	blez	a5,80005cca <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005c4a:	04491703          	lh	a4,68(s2)
    80005c4e:	4785                	li	a5,1
    80005c50:	08f70563          	beq	a4,a5,80005cda <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005c54:	4641                	li	a2,16
    80005c56:	4581                	li	a1,0
    80005c58:	fc040513          	addi	a0,s0,-64
    80005c5c:	ffffb097          	auipc	ra,0xffffb
    80005c60:	27a080e7          	jalr	634(ra) # 80000ed6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c64:	4741                	li	a4,16
    80005c66:	f2c42683          	lw	a3,-212(s0)
    80005c6a:	fc040613          	addi	a2,s0,-64
    80005c6e:	4581                	li	a1,0
    80005c70:	8526                	mv	a0,s1
    80005c72:	ffffe097          	auipc	ra,0xffffe
    80005c76:	50c080e7          	jalr	1292(ra) # 8000417e <writei>
    80005c7a:	47c1                	li	a5,16
    80005c7c:	0af51563          	bne	a0,a5,80005d26 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005c80:	04491703          	lh	a4,68(s2)
    80005c84:	4785                	li	a5,1
    80005c86:	0af70863          	beq	a4,a5,80005d36 <sys_unlink+0x18c>
  iunlockput(dp);
    80005c8a:	8526                	mv	a0,s1
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	3a8080e7          	jalr	936(ra) # 80004034 <iunlockput>
  ip->nlink--;
    80005c94:	04a95783          	lhu	a5,74(s2)
    80005c98:	37fd                	addiw	a5,a5,-1
    80005c9a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c9e:	854a                	mv	a0,s2
    80005ca0:	ffffe097          	auipc	ra,0xffffe
    80005ca4:	066080e7          	jalr	102(ra) # 80003d06 <iupdate>
  iunlockput(ip);
    80005ca8:	854a                	mv	a0,s2
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	38a080e7          	jalr	906(ra) # 80004034 <iunlockput>
  end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	b6a080e7          	jalr	-1174(ra) # 8000481c <end_op>
  return 0;
    80005cba:	4501                	li	a0,0
    80005cbc:	a84d                	j	80005d6e <sys_unlink+0x1c4>
    end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	b5e080e7          	jalr	-1186(ra) # 8000481c <end_op>
    return -1;
    80005cc6:	557d                	li	a0,-1
    80005cc8:	a05d                	j	80005d6e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005cca:	00003517          	auipc	a0,0x3
    80005cce:	c2650513          	addi	a0,a0,-986 # 800088f0 <syscalls+0x2d8>
    80005cd2:	ffffb097          	auipc	ra,0xffffb
    80005cd6:	86e080e7          	jalr	-1938(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005cda:	04c92703          	lw	a4,76(s2)
    80005cde:	02000793          	li	a5,32
    80005ce2:	f6e7f9e3          	bgeu	a5,a4,80005c54 <sys_unlink+0xaa>
    80005ce6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cea:	4741                	li	a4,16
    80005cec:	86ce                	mv	a3,s3
    80005cee:	f1840613          	addi	a2,s0,-232
    80005cf2:	4581                	li	a1,0
    80005cf4:	854a                	mv	a0,s2
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	390080e7          	jalr	912(ra) # 80004086 <readi>
    80005cfe:	47c1                	li	a5,16
    80005d00:	00f51b63          	bne	a0,a5,80005d16 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005d04:	f1845783          	lhu	a5,-232(s0)
    80005d08:	e7a1                	bnez	a5,80005d50 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d0a:	29c1                	addiw	s3,s3,16
    80005d0c:	04c92783          	lw	a5,76(s2)
    80005d10:	fcf9ede3          	bltu	s3,a5,80005cea <sys_unlink+0x140>
    80005d14:	b781                	j	80005c54 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005d16:	00003517          	auipc	a0,0x3
    80005d1a:	bf250513          	addi	a0,a0,-1038 # 80008908 <syscalls+0x2f0>
    80005d1e:	ffffb097          	auipc	ra,0xffffb
    80005d22:	822080e7          	jalr	-2014(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005d26:	00003517          	auipc	a0,0x3
    80005d2a:	bfa50513          	addi	a0,a0,-1030 # 80008920 <syscalls+0x308>
    80005d2e:	ffffb097          	auipc	ra,0xffffb
    80005d32:	812080e7          	jalr	-2030(ra) # 80000540 <panic>
    dp->nlink--;
    80005d36:	04a4d783          	lhu	a5,74(s1)
    80005d3a:	37fd                	addiw	a5,a5,-1
    80005d3c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d40:	8526                	mv	a0,s1
    80005d42:	ffffe097          	auipc	ra,0xffffe
    80005d46:	fc4080e7          	jalr	-60(ra) # 80003d06 <iupdate>
    80005d4a:	b781                	j	80005c8a <sys_unlink+0xe0>
    return -1;
    80005d4c:	557d                	li	a0,-1
    80005d4e:	a005                	j	80005d6e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005d50:	854a                	mv	a0,s2
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	2e2080e7          	jalr	738(ra) # 80004034 <iunlockput>
  iunlockput(dp);
    80005d5a:	8526                	mv	a0,s1
    80005d5c:	ffffe097          	auipc	ra,0xffffe
    80005d60:	2d8080e7          	jalr	728(ra) # 80004034 <iunlockput>
  end_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	ab8080e7          	jalr	-1352(ra) # 8000481c <end_op>
  return -1;
    80005d6c:	557d                	li	a0,-1
}
    80005d6e:	70ae                	ld	ra,232(sp)
    80005d70:	740e                	ld	s0,224(sp)
    80005d72:	64ee                	ld	s1,216(sp)
    80005d74:	694e                	ld	s2,208(sp)
    80005d76:	69ae                	ld	s3,200(sp)
    80005d78:	616d                	addi	sp,sp,240
    80005d7a:	8082                	ret

0000000080005d7c <sys_open>:

uint64
sys_open(void)
{
    80005d7c:	7131                	addi	sp,sp,-192
    80005d7e:	fd06                	sd	ra,184(sp)
    80005d80:	f922                	sd	s0,176(sp)
    80005d82:	f526                	sd	s1,168(sp)
    80005d84:	f14a                	sd	s2,160(sp)
    80005d86:	ed4e                	sd	s3,152(sp)
    80005d88:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d8a:	f4c40593          	addi	a1,s0,-180
    80005d8e:	4505                	li	a0,1
    80005d90:	ffffd097          	auipc	ra,0xffffd
    80005d94:	3e2080e7          	jalr	994(ra) # 80003172 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d98:	08000613          	li	a2,128
    80005d9c:	f5040593          	addi	a1,s0,-176
    80005da0:	4501                	li	a0,0
    80005da2:	ffffd097          	auipc	ra,0xffffd
    80005da6:	410080e7          	jalr	1040(ra) # 800031b2 <argstr>
    80005daa:	87aa                	mv	a5,a0
    return -1;
    80005dac:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005dae:	0a07c963          	bltz	a5,80005e60 <sys_open+0xe4>

  begin_op();
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	9ec080e7          	jalr	-1556(ra) # 8000479e <begin_op>

  if(omode & O_CREATE){
    80005dba:	f4c42783          	lw	a5,-180(s0)
    80005dbe:	2007f793          	andi	a5,a5,512
    80005dc2:	cfc5                	beqz	a5,80005e7a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005dc4:	4681                	li	a3,0
    80005dc6:	4601                	li	a2,0
    80005dc8:	4589                	li	a1,2
    80005dca:	f5040513          	addi	a0,s0,-176
    80005dce:	00000097          	auipc	ra,0x0
    80005dd2:	972080e7          	jalr	-1678(ra) # 80005740 <create>
    80005dd6:	84aa                	mv	s1,a0
    if(ip == 0){
    80005dd8:	c959                	beqz	a0,80005e6e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005dda:	04449703          	lh	a4,68(s1)
    80005dde:	478d                	li	a5,3
    80005de0:	00f71763          	bne	a4,a5,80005dee <sys_open+0x72>
    80005de4:	0464d703          	lhu	a4,70(s1)
    80005de8:	47a5                	li	a5,9
    80005dea:	0ce7ed63          	bltu	a5,a4,80005ec4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	dbc080e7          	jalr	-580(ra) # 80004baa <filealloc>
    80005df6:	89aa                	mv	s3,a0
    80005df8:	10050363          	beqz	a0,80005efe <sys_open+0x182>
    80005dfc:	00000097          	auipc	ra,0x0
    80005e00:	902080e7          	jalr	-1790(ra) # 800056fe <fdalloc>
    80005e04:	892a                	mv	s2,a0
    80005e06:	0e054763          	bltz	a0,80005ef4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005e0a:	04449703          	lh	a4,68(s1)
    80005e0e:	478d                	li	a5,3
    80005e10:	0cf70563          	beq	a4,a5,80005eda <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005e14:	4789                	li	a5,2
    80005e16:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005e1a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005e1e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005e22:	f4c42783          	lw	a5,-180(s0)
    80005e26:	0017c713          	xori	a4,a5,1
    80005e2a:	8b05                	andi	a4,a4,1
    80005e2c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e30:	0037f713          	andi	a4,a5,3
    80005e34:	00e03733          	snez	a4,a4
    80005e38:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005e3c:	4007f793          	andi	a5,a5,1024
    80005e40:	c791                	beqz	a5,80005e4c <sys_open+0xd0>
    80005e42:	04449703          	lh	a4,68(s1)
    80005e46:	4789                	li	a5,2
    80005e48:	0af70063          	beq	a4,a5,80005ee8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005e4c:	8526                	mv	a0,s1
    80005e4e:	ffffe097          	auipc	ra,0xffffe
    80005e52:	046080e7          	jalr	70(ra) # 80003e94 <iunlock>
  end_op();
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	9c6080e7          	jalr	-1594(ra) # 8000481c <end_op>

  return fd;
    80005e5e:	854a                	mv	a0,s2
}
    80005e60:	70ea                	ld	ra,184(sp)
    80005e62:	744a                	ld	s0,176(sp)
    80005e64:	74aa                	ld	s1,168(sp)
    80005e66:	790a                	ld	s2,160(sp)
    80005e68:	69ea                	ld	s3,152(sp)
    80005e6a:	6129                	addi	sp,sp,192
    80005e6c:	8082                	ret
      end_op();
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	9ae080e7          	jalr	-1618(ra) # 8000481c <end_op>
      return -1;
    80005e76:	557d                	li	a0,-1
    80005e78:	b7e5                	j	80005e60 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005e7a:	f5040513          	addi	a0,s0,-176
    80005e7e:	ffffe097          	auipc	ra,0xffffe
    80005e82:	700080e7          	jalr	1792(ra) # 8000457e <namei>
    80005e86:	84aa                	mv	s1,a0
    80005e88:	c905                	beqz	a0,80005eb8 <sys_open+0x13c>
    ilock(ip);
    80005e8a:	ffffe097          	auipc	ra,0xffffe
    80005e8e:	f48080e7          	jalr	-184(ra) # 80003dd2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e92:	04449703          	lh	a4,68(s1)
    80005e96:	4785                	li	a5,1
    80005e98:	f4f711e3          	bne	a4,a5,80005dda <sys_open+0x5e>
    80005e9c:	f4c42783          	lw	a5,-180(s0)
    80005ea0:	d7b9                	beqz	a5,80005dee <sys_open+0x72>
      iunlockput(ip);
    80005ea2:	8526                	mv	a0,s1
    80005ea4:	ffffe097          	auipc	ra,0xffffe
    80005ea8:	190080e7          	jalr	400(ra) # 80004034 <iunlockput>
      end_op();
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	970080e7          	jalr	-1680(ra) # 8000481c <end_op>
      return -1;
    80005eb4:	557d                	li	a0,-1
    80005eb6:	b76d                	j	80005e60 <sys_open+0xe4>
      end_op();
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	964080e7          	jalr	-1692(ra) # 8000481c <end_op>
      return -1;
    80005ec0:	557d                	li	a0,-1
    80005ec2:	bf79                	j	80005e60 <sys_open+0xe4>
    iunlockput(ip);
    80005ec4:	8526                	mv	a0,s1
    80005ec6:	ffffe097          	auipc	ra,0xffffe
    80005eca:	16e080e7          	jalr	366(ra) # 80004034 <iunlockput>
    end_op();
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	94e080e7          	jalr	-1714(ra) # 8000481c <end_op>
    return -1;
    80005ed6:	557d                	li	a0,-1
    80005ed8:	b761                	j	80005e60 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005eda:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ede:	04649783          	lh	a5,70(s1)
    80005ee2:	02f99223          	sh	a5,36(s3)
    80005ee6:	bf25                	j	80005e1e <sys_open+0xa2>
    itrunc(ip);
    80005ee8:	8526                	mv	a0,s1
    80005eea:	ffffe097          	auipc	ra,0xffffe
    80005eee:	ff6080e7          	jalr	-10(ra) # 80003ee0 <itrunc>
    80005ef2:	bfa9                	j	80005e4c <sys_open+0xd0>
      fileclose(f);
    80005ef4:	854e                	mv	a0,s3
    80005ef6:	fffff097          	auipc	ra,0xfffff
    80005efa:	d70080e7          	jalr	-656(ra) # 80004c66 <fileclose>
    iunlockput(ip);
    80005efe:	8526                	mv	a0,s1
    80005f00:	ffffe097          	auipc	ra,0xffffe
    80005f04:	134080e7          	jalr	308(ra) # 80004034 <iunlockput>
    end_op();
    80005f08:	fffff097          	auipc	ra,0xfffff
    80005f0c:	914080e7          	jalr	-1772(ra) # 8000481c <end_op>
    return -1;
    80005f10:	557d                	li	a0,-1
    80005f12:	b7b9                	j	80005e60 <sys_open+0xe4>

0000000080005f14 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005f14:	7175                	addi	sp,sp,-144
    80005f16:	e506                	sd	ra,136(sp)
    80005f18:	e122                	sd	s0,128(sp)
    80005f1a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005f1c:	fffff097          	auipc	ra,0xfffff
    80005f20:	882080e7          	jalr	-1918(ra) # 8000479e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005f24:	08000613          	li	a2,128
    80005f28:	f7040593          	addi	a1,s0,-144
    80005f2c:	4501                	li	a0,0
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	284080e7          	jalr	644(ra) # 800031b2 <argstr>
    80005f36:	02054963          	bltz	a0,80005f68 <sys_mkdir+0x54>
    80005f3a:	4681                	li	a3,0
    80005f3c:	4601                	li	a2,0
    80005f3e:	4585                	li	a1,1
    80005f40:	f7040513          	addi	a0,s0,-144
    80005f44:	fffff097          	auipc	ra,0xfffff
    80005f48:	7fc080e7          	jalr	2044(ra) # 80005740 <create>
    80005f4c:	cd11                	beqz	a0,80005f68 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f4e:	ffffe097          	auipc	ra,0xffffe
    80005f52:	0e6080e7          	jalr	230(ra) # 80004034 <iunlockput>
  end_op();
    80005f56:	fffff097          	auipc	ra,0xfffff
    80005f5a:	8c6080e7          	jalr	-1850(ra) # 8000481c <end_op>
  return 0;
    80005f5e:	4501                	li	a0,0
}
    80005f60:	60aa                	ld	ra,136(sp)
    80005f62:	640a                	ld	s0,128(sp)
    80005f64:	6149                	addi	sp,sp,144
    80005f66:	8082                	ret
    end_op();
    80005f68:	fffff097          	auipc	ra,0xfffff
    80005f6c:	8b4080e7          	jalr	-1868(ra) # 8000481c <end_op>
    return -1;
    80005f70:	557d                	li	a0,-1
    80005f72:	b7fd                	j	80005f60 <sys_mkdir+0x4c>

0000000080005f74 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f74:	7135                	addi	sp,sp,-160
    80005f76:	ed06                	sd	ra,152(sp)
    80005f78:	e922                	sd	s0,144(sp)
    80005f7a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f7c:	fffff097          	auipc	ra,0xfffff
    80005f80:	822080e7          	jalr	-2014(ra) # 8000479e <begin_op>
  argint(1, &major);
    80005f84:	f6c40593          	addi	a1,s0,-148
    80005f88:	4505                	li	a0,1
    80005f8a:	ffffd097          	auipc	ra,0xffffd
    80005f8e:	1e8080e7          	jalr	488(ra) # 80003172 <argint>
  argint(2, &minor);
    80005f92:	f6840593          	addi	a1,s0,-152
    80005f96:	4509                	li	a0,2
    80005f98:	ffffd097          	auipc	ra,0xffffd
    80005f9c:	1da080e7          	jalr	474(ra) # 80003172 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005fa0:	08000613          	li	a2,128
    80005fa4:	f7040593          	addi	a1,s0,-144
    80005fa8:	4501                	li	a0,0
    80005faa:	ffffd097          	auipc	ra,0xffffd
    80005fae:	208080e7          	jalr	520(ra) # 800031b2 <argstr>
    80005fb2:	02054b63          	bltz	a0,80005fe8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005fb6:	f6841683          	lh	a3,-152(s0)
    80005fba:	f6c41603          	lh	a2,-148(s0)
    80005fbe:	458d                	li	a1,3
    80005fc0:	f7040513          	addi	a0,s0,-144
    80005fc4:	fffff097          	auipc	ra,0xfffff
    80005fc8:	77c080e7          	jalr	1916(ra) # 80005740 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005fcc:	cd11                	beqz	a0,80005fe8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fce:	ffffe097          	auipc	ra,0xffffe
    80005fd2:	066080e7          	jalr	102(ra) # 80004034 <iunlockput>
  end_op();
    80005fd6:	fffff097          	auipc	ra,0xfffff
    80005fda:	846080e7          	jalr	-1978(ra) # 8000481c <end_op>
  return 0;
    80005fde:	4501                	li	a0,0
}
    80005fe0:	60ea                	ld	ra,152(sp)
    80005fe2:	644a                	ld	s0,144(sp)
    80005fe4:	610d                	addi	sp,sp,160
    80005fe6:	8082                	ret
    end_op();
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	834080e7          	jalr	-1996(ra) # 8000481c <end_op>
    return -1;
    80005ff0:	557d                	li	a0,-1
    80005ff2:	b7fd                	j	80005fe0 <sys_mknod+0x6c>

0000000080005ff4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ff4:	7135                	addi	sp,sp,-160
    80005ff6:	ed06                	sd	ra,152(sp)
    80005ff8:	e922                	sd	s0,144(sp)
    80005ffa:	e526                	sd	s1,136(sp)
    80005ffc:	e14a                	sd	s2,128(sp)
    80005ffe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006000:	ffffc097          	auipc	ra,0xffffc
    80006004:	ca8080e7          	jalr	-856(ra) # 80001ca8 <myproc>
    80006008:	892a                	mv	s2,a0
  
  begin_op();
    8000600a:	ffffe097          	auipc	ra,0xffffe
    8000600e:	794080e7          	jalr	1940(ra) # 8000479e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006012:	08000613          	li	a2,128
    80006016:	f6040593          	addi	a1,s0,-160
    8000601a:	4501                	li	a0,0
    8000601c:	ffffd097          	auipc	ra,0xffffd
    80006020:	196080e7          	jalr	406(ra) # 800031b2 <argstr>
    80006024:	04054b63          	bltz	a0,8000607a <sys_chdir+0x86>
    80006028:	f6040513          	addi	a0,s0,-160
    8000602c:	ffffe097          	auipc	ra,0xffffe
    80006030:	552080e7          	jalr	1362(ra) # 8000457e <namei>
    80006034:	84aa                	mv	s1,a0
    80006036:	c131                	beqz	a0,8000607a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006038:	ffffe097          	auipc	ra,0xffffe
    8000603c:	d9a080e7          	jalr	-614(ra) # 80003dd2 <ilock>
  if(ip->type != T_DIR){
    80006040:	04449703          	lh	a4,68(s1)
    80006044:	4785                	li	a5,1
    80006046:	04f71063          	bne	a4,a5,80006086 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000604a:	8526                	mv	a0,s1
    8000604c:	ffffe097          	auipc	ra,0xffffe
    80006050:	e48080e7          	jalr	-440(ra) # 80003e94 <iunlock>
  iput(p->cwd);
    80006054:	15093503          	ld	a0,336(s2)
    80006058:	ffffe097          	auipc	ra,0xffffe
    8000605c:	f34080e7          	jalr	-204(ra) # 80003f8c <iput>
  end_op();
    80006060:	ffffe097          	auipc	ra,0xffffe
    80006064:	7bc080e7          	jalr	1980(ra) # 8000481c <end_op>
  p->cwd = ip;
    80006068:	14993823          	sd	s1,336(s2)
  return 0;
    8000606c:	4501                	li	a0,0
}
    8000606e:	60ea                	ld	ra,152(sp)
    80006070:	644a                	ld	s0,144(sp)
    80006072:	64aa                	ld	s1,136(sp)
    80006074:	690a                	ld	s2,128(sp)
    80006076:	610d                	addi	sp,sp,160
    80006078:	8082                	ret
    end_op();
    8000607a:	ffffe097          	auipc	ra,0xffffe
    8000607e:	7a2080e7          	jalr	1954(ra) # 8000481c <end_op>
    return -1;
    80006082:	557d                	li	a0,-1
    80006084:	b7ed                	j	8000606e <sys_chdir+0x7a>
    iunlockput(ip);
    80006086:	8526                	mv	a0,s1
    80006088:	ffffe097          	auipc	ra,0xffffe
    8000608c:	fac080e7          	jalr	-84(ra) # 80004034 <iunlockput>
    end_op();
    80006090:	ffffe097          	auipc	ra,0xffffe
    80006094:	78c080e7          	jalr	1932(ra) # 8000481c <end_op>
    return -1;
    80006098:	557d                	li	a0,-1
    8000609a:	bfd1                	j	8000606e <sys_chdir+0x7a>

000000008000609c <sys_exec>:

uint64
sys_exec(void)
{
    8000609c:	7145                	addi	sp,sp,-464
    8000609e:	e786                	sd	ra,456(sp)
    800060a0:	e3a2                	sd	s0,448(sp)
    800060a2:	ff26                	sd	s1,440(sp)
    800060a4:	fb4a                	sd	s2,432(sp)
    800060a6:	f74e                	sd	s3,424(sp)
    800060a8:	f352                	sd	s4,416(sp)
    800060aa:	ef56                	sd	s5,408(sp)
    800060ac:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800060ae:	e3840593          	addi	a1,s0,-456
    800060b2:	4505                	li	a0,1
    800060b4:	ffffd097          	auipc	ra,0xffffd
    800060b8:	0de080e7          	jalr	222(ra) # 80003192 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800060bc:	08000613          	li	a2,128
    800060c0:	f4040593          	addi	a1,s0,-192
    800060c4:	4501                	li	a0,0
    800060c6:	ffffd097          	auipc	ra,0xffffd
    800060ca:	0ec080e7          	jalr	236(ra) # 800031b2 <argstr>
    800060ce:	87aa                	mv	a5,a0
    return -1;
    800060d0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800060d2:	0c07c363          	bltz	a5,80006198 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800060d6:	10000613          	li	a2,256
    800060da:	4581                	li	a1,0
    800060dc:	e4040513          	addi	a0,s0,-448
    800060e0:	ffffb097          	auipc	ra,0xffffb
    800060e4:	df6080e7          	jalr	-522(ra) # 80000ed6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800060e8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800060ec:	89a6                	mv	s3,s1
    800060ee:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800060f0:	02000a13          	li	s4,32
    800060f4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060f8:	00391513          	slli	a0,s2,0x3
    800060fc:	e3040593          	addi	a1,s0,-464
    80006100:	e3843783          	ld	a5,-456(s0)
    80006104:	953e                	add	a0,a0,a5
    80006106:	ffffd097          	auipc	ra,0xffffd
    8000610a:	fce080e7          	jalr	-50(ra) # 800030d4 <fetchaddr>
    8000610e:	02054a63          	bltz	a0,80006142 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006112:	e3043783          	ld	a5,-464(s0)
    80006116:	c3b9                	beqz	a5,8000615c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006118:	ffffb097          	auipc	ra,0xffffb
    8000611c:	b7a080e7          	jalr	-1158(ra) # 80000c92 <kalloc>
    80006120:	85aa                	mv	a1,a0
    80006122:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006126:	cd11                	beqz	a0,80006142 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006128:	6605                	lui	a2,0x1
    8000612a:	e3043503          	ld	a0,-464(s0)
    8000612e:	ffffd097          	auipc	ra,0xffffd
    80006132:	ff8080e7          	jalr	-8(ra) # 80003126 <fetchstr>
    80006136:	00054663          	bltz	a0,80006142 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000613a:	0905                	addi	s2,s2,1
    8000613c:	09a1                	addi	s3,s3,8
    8000613e:	fb491be3          	bne	s2,s4,800060f4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006142:	f4040913          	addi	s2,s0,-192
    80006146:	6088                	ld	a0,0(s1)
    80006148:	c539                	beqz	a0,80006196 <sys_exec+0xfa>
    kfree(argv[i]);
    8000614a:	ffffb097          	auipc	ra,0xffffb
    8000614e:	a08080e7          	jalr	-1528(ra) # 80000b52 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006152:	04a1                	addi	s1,s1,8
    80006154:	ff2499e3          	bne	s1,s2,80006146 <sys_exec+0xaa>
  return -1;
    80006158:	557d                	li	a0,-1
    8000615a:	a83d                	j	80006198 <sys_exec+0xfc>
      argv[i] = 0;
    8000615c:	0a8e                	slli	s5,s5,0x3
    8000615e:	fc0a8793          	addi	a5,s5,-64
    80006162:	00878ab3          	add	s5,a5,s0
    80006166:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000616a:	e4040593          	addi	a1,s0,-448
    8000616e:	f4040513          	addi	a0,s0,-192
    80006172:	fffff097          	auipc	ra,0xfffff
    80006176:	16e080e7          	jalr	366(ra) # 800052e0 <exec>
    8000617a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000617c:	f4040993          	addi	s3,s0,-192
    80006180:	6088                	ld	a0,0(s1)
    80006182:	c901                	beqz	a0,80006192 <sys_exec+0xf6>
    kfree(argv[i]);
    80006184:	ffffb097          	auipc	ra,0xffffb
    80006188:	9ce080e7          	jalr	-1586(ra) # 80000b52 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000618c:	04a1                	addi	s1,s1,8
    8000618e:	ff3499e3          	bne	s1,s3,80006180 <sys_exec+0xe4>
  return ret;
    80006192:	854a                	mv	a0,s2
    80006194:	a011                	j	80006198 <sys_exec+0xfc>
  return -1;
    80006196:	557d                	li	a0,-1
}
    80006198:	60be                	ld	ra,456(sp)
    8000619a:	641e                	ld	s0,448(sp)
    8000619c:	74fa                	ld	s1,440(sp)
    8000619e:	795a                	ld	s2,432(sp)
    800061a0:	79ba                	ld	s3,424(sp)
    800061a2:	7a1a                	ld	s4,416(sp)
    800061a4:	6afa                	ld	s5,408(sp)
    800061a6:	6179                	addi	sp,sp,464
    800061a8:	8082                	ret

00000000800061aa <sys_pipe>:

uint64
sys_pipe(void)
{
    800061aa:	7139                	addi	sp,sp,-64
    800061ac:	fc06                	sd	ra,56(sp)
    800061ae:	f822                	sd	s0,48(sp)
    800061b0:	f426                	sd	s1,40(sp)
    800061b2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800061b4:	ffffc097          	auipc	ra,0xffffc
    800061b8:	af4080e7          	jalr	-1292(ra) # 80001ca8 <myproc>
    800061bc:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800061be:	fd840593          	addi	a1,s0,-40
    800061c2:	4501                	li	a0,0
    800061c4:	ffffd097          	auipc	ra,0xffffd
    800061c8:	fce080e7          	jalr	-50(ra) # 80003192 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800061cc:	fc840593          	addi	a1,s0,-56
    800061d0:	fd040513          	addi	a0,s0,-48
    800061d4:	fffff097          	auipc	ra,0xfffff
    800061d8:	dc2080e7          	jalr	-574(ra) # 80004f96 <pipealloc>
    return -1;
    800061dc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800061de:	0c054463          	bltz	a0,800062a6 <sys_pipe+0xfc>
  fd0 = -1;
    800061e2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800061e6:	fd043503          	ld	a0,-48(s0)
    800061ea:	fffff097          	auipc	ra,0xfffff
    800061ee:	514080e7          	jalr	1300(ra) # 800056fe <fdalloc>
    800061f2:	fca42223          	sw	a0,-60(s0)
    800061f6:	08054b63          	bltz	a0,8000628c <sys_pipe+0xe2>
    800061fa:	fc843503          	ld	a0,-56(s0)
    800061fe:	fffff097          	auipc	ra,0xfffff
    80006202:	500080e7          	jalr	1280(ra) # 800056fe <fdalloc>
    80006206:	fca42023          	sw	a0,-64(s0)
    8000620a:	06054863          	bltz	a0,8000627a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000620e:	4691                	li	a3,4
    80006210:	fc440613          	addi	a2,s0,-60
    80006214:	fd843583          	ld	a1,-40(s0)
    80006218:	68a8                	ld	a0,80(s1)
    8000621a:	ffffb097          	auipc	ra,0xffffb
    8000621e:	650080e7          	jalr	1616(ra) # 8000186a <copyout>
    80006222:	02054063          	bltz	a0,80006242 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006226:	4691                	li	a3,4
    80006228:	fc040613          	addi	a2,s0,-64
    8000622c:	fd843583          	ld	a1,-40(s0)
    80006230:	0591                	addi	a1,a1,4
    80006232:	68a8                	ld	a0,80(s1)
    80006234:	ffffb097          	auipc	ra,0xffffb
    80006238:	636080e7          	jalr	1590(ra) # 8000186a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000623c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000623e:	06055463          	bgez	a0,800062a6 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006242:	fc442783          	lw	a5,-60(s0)
    80006246:	07e9                	addi	a5,a5,26
    80006248:	078e                	slli	a5,a5,0x3
    8000624a:	97a6                	add	a5,a5,s1
    8000624c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006250:	fc042783          	lw	a5,-64(s0)
    80006254:	07e9                	addi	a5,a5,26
    80006256:	078e                	slli	a5,a5,0x3
    80006258:	94be                	add	s1,s1,a5
    8000625a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000625e:	fd043503          	ld	a0,-48(s0)
    80006262:	fffff097          	auipc	ra,0xfffff
    80006266:	a04080e7          	jalr	-1532(ra) # 80004c66 <fileclose>
    fileclose(wf);
    8000626a:	fc843503          	ld	a0,-56(s0)
    8000626e:	fffff097          	auipc	ra,0xfffff
    80006272:	9f8080e7          	jalr	-1544(ra) # 80004c66 <fileclose>
    return -1;
    80006276:	57fd                	li	a5,-1
    80006278:	a03d                	j	800062a6 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000627a:	fc442783          	lw	a5,-60(s0)
    8000627e:	0007c763          	bltz	a5,8000628c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006282:	07e9                	addi	a5,a5,26
    80006284:	078e                	slli	a5,a5,0x3
    80006286:	97a6                	add	a5,a5,s1
    80006288:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000628c:	fd043503          	ld	a0,-48(s0)
    80006290:	fffff097          	auipc	ra,0xfffff
    80006294:	9d6080e7          	jalr	-1578(ra) # 80004c66 <fileclose>
    fileclose(wf);
    80006298:	fc843503          	ld	a0,-56(s0)
    8000629c:	fffff097          	auipc	ra,0xfffff
    800062a0:	9ca080e7          	jalr	-1590(ra) # 80004c66 <fileclose>
    return -1;
    800062a4:	57fd                	li	a5,-1
}
    800062a6:	853e                	mv	a0,a5
    800062a8:	70e2                	ld	ra,56(sp)
    800062aa:	7442                	ld	s0,48(sp)
    800062ac:	74a2                	ld	s1,40(sp)
    800062ae:	6121                	addi	sp,sp,64
    800062b0:	8082                	ret
	...

00000000800062c0 <kernelvec>:
    800062c0:	7111                	addi	sp,sp,-256
    800062c2:	e006                	sd	ra,0(sp)
    800062c4:	e40a                	sd	sp,8(sp)
    800062c6:	e80e                	sd	gp,16(sp)
    800062c8:	ec12                	sd	tp,24(sp)
    800062ca:	f016                	sd	t0,32(sp)
    800062cc:	f41a                	sd	t1,40(sp)
    800062ce:	f81e                	sd	t2,48(sp)
    800062d0:	fc22                	sd	s0,56(sp)
    800062d2:	e0a6                	sd	s1,64(sp)
    800062d4:	e4aa                	sd	a0,72(sp)
    800062d6:	e8ae                	sd	a1,80(sp)
    800062d8:	ecb2                	sd	a2,88(sp)
    800062da:	f0b6                	sd	a3,96(sp)
    800062dc:	f4ba                	sd	a4,104(sp)
    800062de:	f8be                	sd	a5,112(sp)
    800062e0:	fcc2                	sd	a6,120(sp)
    800062e2:	e146                	sd	a7,128(sp)
    800062e4:	e54a                	sd	s2,136(sp)
    800062e6:	e94e                	sd	s3,144(sp)
    800062e8:	ed52                	sd	s4,152(sp)
    800062ea:	f156                	sd	s5,160(sp)
    800062ec:	f55a                	sd	s6,168(sp)
    800062ee:	f95e                	sd	s7,176(sp)
    800062f0:	fd62                	sd	s8,184(sp)
    800062f2:	e1e6                	sd	s9,192(sp)
    800062f4:	e5ea                	sd	s10,200(sp)
    800062f6:	e9ee                	sd	s11,208(sp)
    800062f8:	edf2                	sd	t3,216(sp)
    800062fa:	f1f6                	sd	t4,224(sp)
    800062fc:	f5fa                	sd	t5,232(sp)
    800062fe:	f9fe                	sd	t6,240(sp)
    80006300:	ca1fc0ef          	jal	ra,80002fa0 <kerneltrap>
    80006304:	6082                	ld	ra,0(sp)
    80006306:	6122                	ld	sp,8(sp)
    80006308:	61c2                	ld	gp,16(sp)
    8000630a:	7282                	ld	t0,32(sp)
    8000630c:	7322                	ld	t1,40(sp)
    8000630e:	73c2                	ld	t2,48(sp)
    80006310:	7462                	ld	s0,56(sp)
    80006312:	6486                	ld	s1,64(sp)
    80006314:	6526                	ld	a0,72(sp)
    80006316:	65c6                	ld	a1,80(sp)
    80006318:	6666                	ld	a2,88(sp)
    8000631a:	7686                	ld	a3,96(sp)
    8000631c:	7726                	ld	a4,104(sp)
    8000631e:	77c6                	ld	a5,112(sp)
    80006320:	7866                	ld	a6,120(sp)
    80006322:	688a                	ld	a7,128(sp)
    80006324:	692a                	ld	s2,136(sp)
    80006326:	69ca                	ld	s3,144(sp)
    80006328:	6a6a                	ld	s4,152(sp)
    8000632a:	7a8a                	ld	s5,160(sp)
    8000632c:	7b2a                	ld	s6,168(sp)
    8000632e:	7bca                	ld	s7,176(sp)
    80006330:	7c6a                	ld	s8,184(sp)
    80006332:	6c8e                	ld	s9,192(sp)
    80006334:	6d2e                	ld	s10,200(sp)
    80006336:	6dce                	ld	s11,208(sp)
    80006338:	6e6e                	ld	t3,216(sp)
    8000633a:	7e8e                	ld	t4,224(sp)
    8000633c:	7f2e                	ld	t5,232(sp)
    8000633e:	7fce                	ld	t6,240(sp)
    80006340:	6111                	addi	sp,sp,256
    80006342:	10200073          	sret
    80006346:	00000013          	nop
    8000634a:	00000013          	nop
    8000634e:	0001                	nop

0000000080006350 <timervec>:
    80006350:	34051573          	csrrw	a0,mscratch,a0
    80006354:	e10c                	sd	a1,0(a0)
    80006356:	e510                	sd	a2,8(a0)
    80006358:	e914                	sd	a3,16(a0)
    8000635a:	6d0c                	ld	a1,24(a0)
    8000635c:	7110                	ld	a2,32(a0)
    8000635e:	6194                	ld	a3,0(a1)
    80006360:	96b2                	add	a3,a3,a2
    80006362:	e194                	sd	a3,0(a1)
    80006364:	4589                	li	a1,2
    80006366:	14459073          	csrw	sip,a1
    8000636a:	6914                	ld	a3,16(a0)
    8000636c:	6510                	ld	a2,8(a0)
    8000636e:	610c                	ld	a1,0(a0)
    80006370:	34051573          	csrrw	a0,mscratch,a0
    80006374:	30200073          	mret
	...

000000008000637a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000637a:	1141                	addi	sp,sp,-16
    8000637c:	e422                	sd	s0,8(sp)
    8000637e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006380:	0c0007b7          	lui	a5,0xc000
    80006384:	4705                	li	a4,1
    80006386:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006388:	c3d8                	sw	a4,4(a5)
}
    8000638a:	6422                	ld	s0,8(sp)
    8000638c:	0141                	addi	sp,sp,16
    8000638e:	8082                	ret

0000000080006390 <plicinithart>:

void
plicinithart(void)
{
    80006390:	1141                	addi	sp,sp,-16
    80006392:	e406                	sd	ra,8(sp)
    80006394:	e022                	sd	s0,0(sp)
    80006396:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006398:	ffffc097          	auipc	ra,0xffffc
    8000639c:	8e4080e7          	jalr	-1820(ra) # 80001c7c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800063a0:	0085171b          	slliw	a4,a0,0x8
    800063a4:	0c0027b7          	lui	a5,0xc002
    800063a8:	97ba                	add	a5,a5,a4
    800063aa:	40200713          	li	a4,1026
    800063ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800063b2:	00d5151b          	slliw	a0,a0,0xd
    800063b6:	0c2017b7          	lui	a5,0xc201
    800063ba:	97aa                	add	a5,a5,a0
    800063bc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800063c0:	60a2                	ld	ra,8(sp)
    800063c2:	6402                	ld	s0,0(sp)
    800063c4:	0141                	addi	sp,sp,16
    800063c6:	8082                	ret

00000000800063c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800063c8:	1141                	addi	sp,sp,-16
    800063ca:	e406                	sd	ra,8(sp)
    800063cc:	e022                	sd	s0,0(sp)
    800063ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800063d0:	ffffc097          	auipc	ra,0xffffc
    800063d4:	8ac080e7          	jalr	-1876(ra) # 80001c7c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800063d8:	00d5151b          	slliw	a0,a0,0xd
    800063dc:	0c2017b7          	lui	a5,0xc201
    800063e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800063e2:	43c8                	lw	a0,4(a5)
    800063e4:	60a2                	ld	ra,8(sp)
    800063e6:	6402                	ld	s0,0(sp)
    800063e8:	0141                	addi	sp,sp,16
    800063ea:	8082                	ret

00000000800063ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800063ec:	1101                	addi	sp,sp,-32
    800063ee:	ec06                	sd	ra,24(sp)
    800063f0:	e822                	sd	s0,16(sp)
    800063f2:	e426                	sd	s1,8(sp)
    800063f4:	1000                	addi	s0,sp,32
    800063f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063f8:	ffffc097          	auipc	ra,0xffffc
    800063fc:	884080e7          	jalr	-1916(ra) # 80001c7c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006400:	00d5151b          	slliw	a0,a0,0xd
    80006404:	0c2017b7          	lui	a5,0xc201
    80006408:	97aa                	add	a5,a5,a0
    8000640a:	c3c4                	sw	s1,4(a5)
}
    8000640c:	60e2                	ld	ra,24(sp)
    8000640e:	6442                	ld	s0,16(sp)
    80006410:	64a2                	ld	s1,8(sp)
    80006412:	6105                	addi	sp,sp,32
    80006414:	8082                	ret

0000000080006416 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006416:	1141                	addi	sp,sp,-16
    80006418:	e406                	sd	ra,8(sp)
    8000641a:	e022                	sd	s0,0(sp)
    8000641c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000641e:	479d                	li	a5,7
    80006420:	04a7cc63          	blt	a5,a0,80006478 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006424:	0003c797          	auipc	a5,0x3c
    80006428:	a2c78793          	addi	a5,a5,-1492 # 80041e50 <disk>
    8000642c:	97aa                	add	a5,a5,a0
    8000642e:	0187c783          	lbu	a5,24(a5)
    80006432:	ebb9                	bnez	a5,80006488 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006434:	00451693          	slli	a3,a0,0x4
    80006438:	0003c797          	auipc	a5,0x3c
    8000643c:	a1878793          	addi	a5,a5,-1512 # 80041e50 <disk>
    80006440:	6398                	ld	a4,0(a5)
    80006442:	9736                	add	a4,a4,a3
    80006444:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006448:	6398                	ld	a4,0(a5)
    8000644a:	9736                	add	a4,a4,a3
    8000644c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006450:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006454:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006458:	97aa                	add	a5,a5,a0
    8000645a:	4705                	li	a4,1
    8000645c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006460:	0003c517          	auipc	a0,0x3c
    80006464:	a0850513          	addi	a0,a0,-1528 # 80041e68 <disk+0x18>
    80006468:	ffffc097          	auipc	ra,0xffffc
    8000646c:	052080e7          	jalr	82(ra) # 800024ba <wakeup>
}
    80006470:	60a2                	ld	ra,8(sp)
    80006472:	6402                	ld	s0,0(sp)
    80006474:	0141                	addi	sp,sp,16
    80006476:	8082                	ret
    panic("free_desc 1");
    80006478:	00002517          	auipc	a0,0x2
    8000647c:	4b850513          	addi	a0,a0,1208 # 80008930 <syscalls+0x318>
    80006480:	ffffa097          	auipc	ra,0xffffa
    80006484:	0c0080e7          	jalr	192(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006488:	00002517          	auipc	a0,0x2
    8000648c:	4b850513          	addi	a0,a0,1208 # 80008940 <syscalls+0x328>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	0b0080e7          	jalr	176(ra) # 80000540 <panic>

0000000080006498 <virtio_disk_init>:
{
    80006498:	1101                	addi	sp,sp,-32
    8000649a:	ec06                	sd	ra,24(sp)
    8000649c:	e822                	sd	s0,16(sp)
    8000649e:	e426                	sd	s1,8(sp)
    800064a0:	e04a                	sd	s2,0(sp)
    800064a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800064a4:	00002597          	auipc	a1,0x2
    800064a8:	4ac58593          	addi	a1,a1,1196 # 80008950 <syscalls+0x338>
    800064ac:	0003c517          	auipc	a0,0x3c
    800064b0:	acc50513          	addi	a0,a0,-1332 # 80041f78 <disk+0x128>
    800064b4:	ffffb097          	auipc	ra,0xffffb
    800064b8:	896080e7          	jalr	-1898(ra) # 80000d4a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064bc:	100017b7          	lui	a5,0x10001
    800064c0:	4398                	lw	a4,0(a5)
    800064c2:	2701                	sext.w	a4,a4
    800064c4:	747277b7          	lui	a5,0x74727
    800064c8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800064cc:	14f71b63          	bne	a4,a5,80006622 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064d0:	100017b7          	lui	a5,0x10001
    800064d4:	43dc                	lw	a5,4(a5)
    800064d6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064d8:	4709                	li	a4,2
    800064da:	14e79463          	bne	a5,a4,80006622 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064de:	100017b7          	lui	a5,0x10001
    800064e2:	479c                	lw	a5,8(a5)
    800064e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064e6:	12e79e63          	bne	a5,a4,80006622 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064ea:	100017b7          	lui	a5,0x10001
    800064ee:	47d8                	lw	a4,12(a5)
    800064f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064f2:	554d47b7          	lui	a5,0x554d4
    800064f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064fa:	12f71463          	bne	a4,a5,80006622 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064fe:	100017b7          	lui	a5,0x10001
    80006502:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006506:	4705                	li	a4,1
    80006508:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000650a:	470d                	li	a4,3
    8000650c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000650e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006510:	c7ffe6b7          	lui	a3,0xc7ffe
    80006514:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc7cf>
    80006518:	8f75                	and	a4,a4,a3
    8000651a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000651c:	472d                	li	a4,11
    8000651e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006520:	5bbc                	lw	a5,112(a5)
    80006522:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006526:	8ba1                	andi	a5,a5,8
    80006528:	10078563          	beqz	a5,80006632 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000652c:	100017b7          	lui	a5,0x10001
    80006530:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006534:	43fc                	lw	a5,68(a5)
    80006536:	2781                	sext.w	a5,a5
    80006538:	10079563          	bnez	a5,80006642 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000653c:	100017b7          	lui	a5,0x10001
    80006540:	5bdc                	lw	a5,52(a5)
    80006542:	2781                	sext.w	a5,a5
  if(max == 0)
    80006544:	10078763          	beqz	a5,80006652 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006548:	471d                	li	a4,7
    8000654a:	10f77c63          	bgeu	a4,a5,80006662 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000654e:	ffffa097          	auipc	ra,0xffffa
    80006552:	744080e7          	jalr	1860(ra) # 80000c92 <kalloc>
    80006556:	0003c497          	auipc	s1,0x3c
    8000655a:	8fa48493          	addi	s1,s1,-1798 # 80041e50 <disk>
    8000655e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006560:	ffffa097          	auipc	ra,0xffffa
    80006564:	732080e7          	jalr	1842(ra) # 80000c92 <kalloc>
    80006568:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	728080e7          	jalr	1832(ra) # 80000c92 <kalloc>
    80006572:	87aa                	mv	a5,a0
    80006574:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006576:	6088                	ld	a0,0(s1)
    80006578:	cd6d                	beqz	a0,80006672 <virtio_disk_init+0x1da>
    8000657a:	0003c717          	auipc	a4,0x3c
    8000657e:	8de73703          	ld	a4,-1826(a4) # 80041e58 <disk+0x8>
    80006582:	cb65                	beqz	a4,80006672 <virtio_disk_init+0x1da>
    80006584:	c7fd                	beqz	a5,80006672 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006586:	6605                	lui	a2,0x1
    80006588:	4581                	li	a1,0
    8000658a:	ffffb097          	auipc	ra,0xffffb
    8000658e:	94c080e7          	jalr	-1716(ra) # 80000ed6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006592:	0003c497          	auipc	s1,0x3c
    80006596:	8be48493          	addi	s1,s1,-1858 # 80041e50 <disk>
    8000659a:	6605                	lui	a2,0x1
    8000659c:	4581                	li	a1,0
    8000659e:	6488                	ld	a0,8(s1)
    800065a0:	ffffb097          	auipc	ra,0xffffb
    800065a4:	936080e7          	jalr	-1738(ra) # 80000ed6 <memset>
  memset(disk.used, 0, PGSIZE);
    800065a8:	6605                	lui	a2,0x1
    800065aa:	4581                	li	a1,0
    800065ac:	6888                	ld	a0,16(s1)
    800065ae:	ffffb097          	auipc	ra,0xffffb
    800065b2:	928080e7          	jalr	-1752(ra) # 80000ed6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800065b6:	100017b7          	lui	a5,0x10001
    800065ba:	4721                	li	a4,8
    800065bc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800065be:	4098                	lw	a4,0(s1)
    800065c0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800065c4:	40d8                	lw	a4,4(s1)
    800065c6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800065ca:	6498                	ld	a4,8(s1)
    800065cc:	0007069b          	sext.w	a3,a4
    800065d0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800065d4:	9701                	srai	a4,a4,0x20
    800065d6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800065da:	6898                	ld	a4,16(s1)
    800065dc:	0007069b          	sext.w	a3,a4
    800065e0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800065e4:	9701                	srai	a4,a4,0x20
    800065e6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800065ea:	4705                	li	a4,1
    800065ec:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800065ee:	00e48c23          	sb	a4,24(s1)
    800065f2:	00e48ca3          	sb	a4,25(s1)
    800065f6:	00e48d23          	sb	a4,26(s1)
    800065fa:	00e48da3          	sb	a4,27(s1)
    800065fe:	00e48e23          	sb	a4,28(s1)
    80006602:	00e48ea3          	sb	a4,29(s1)
    80006606:	00e48f23          	sb	a4,30(s1)
    8000660a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000660e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006612:	0727a823          	sw	s2,112(a5)
}
    80006616:	60e2                	ld	ra,24(sp)
    80006618:	6442                	ld	s0,16(sp)
    8000661a:	64a2                	ld	s1,8(sp)
    8000661c:	6902                	ld	s2,0(sp)
    8000661e:	6105                	addi	sp,sp,32
    80006620:	8082                	ret
    panic("could not find virtio disk");
    80006622:	00002517          	auipc	a0,0x2
    80006626:	33e50513          	addi	a0,a0,830 # 80008960 <syscalls+0x348>
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	f16080e7          	jalr	-234(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006632:	00002517          	auipc	a0,0x2
    80006636:	34e50513          	addi	a0,a0,846 # 80008980 <syscalls+0x368>
    8000663a:	ffffa097          	auipc	ra,0xffffa
    8000663e:	f06080e7          	jalr	-250(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006642:	00002517          	auipc	a0,0x2
    80006646:	35e50513          	addi	a0,a0,862 # 800089a0 <syscalls+0x388>
    8000664a:	ffffa097          	auipc	ra,0xffffa
    8000664e:	ef6080e7          	jalr	-266(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006652:	00002517          	auipc	a0,0x2
    80006656:	36e50513          	addi	a0,a0,878 # 800089c0 <syscalls+0x3a8>
    8000665a:	ffffa097          	auipc	ra,0xffffa
    8000665e:	ee6080e7          	jalr	-282(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006662:	00002517          	auipc	a0,0x2
    80006666:	37e50513          	addi	a0,a0,894 # 800089e0 <syscalls+0x3c8>
    8000666a:	ffffa097          	auipc	ra,0xffffa
    8000666e:	ed6080e7          	jalr	-298(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006672:	00002517          	auipc	a0,0x2
    80006676:	38e50513          	addi	a0,a0,910 # 80008a00 <syscalls+0x3e8>
    8000667a:	ffffa097          	auipc	ra,0xffffa
    8000667e:	ec6080e7          	jalr	-314(ra) # 80000540 <panic>

0000000080006682 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006682:	7119                	addi	sp,sp,-128
    80006684:	fc86                	sd	ra,120(sp)
    80006686:	f8a2                	sd	s0,112(sp)
    80006688:	f4a6                	sd	s1,104(sp)
    8000668a:	f0ca                	sd	s2,96(sp)
    8000668c:	ecce                	sd	s3,88(sp)
    8000668e:	e8d2                	sd	s4,80(sp)
    80006690:	e4d6                	sd	s5,72(sp)
    80006692:	e0da                	sd	s6,64(sp)
    80006694:	fc5e                	sd	s7,56(sp)
    80006696:	f862                	sd	s8,48(sp)
    80006698:	f466                	sd	s9,40(sp)
    8000669a:	f06a                	sd	s10,32(sp)
    8000669c:	ec6e                	sd	s11,24(sp)
    8000669e:	0100                	addi	s0,sp,128
    800066a0:	8aaa                	mv	s5,a0
    800066a2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800066a4:	00c52d03          	lw	s10,12(a0)
    800066a8:	001d1d1b          	slliw	s10,s10,0x1
    800066ac:	1d02                	slli	s10,s10,0x20
    800066ae:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800066b2:	0003c517          	auipc	a0,0x3c
    800066b6:	8c650513          	addi	a0,a0,-1850 # 80041f78 <disk+0x128>
    800066ba:	ffffa097          	auipc	ra,0xffffa
    800066be:	720080e7          	jalr	1824(ra) # 80000dda <acquire>
  for(int i = 0; i < 3; i++){
    800066c2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800066c4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800066c6:	0003bb97          	auipc	s7,0x3b
    800066ca:	78ab8b93          	addi	s7,s7,1930 # 80041e50 <disk>
  for(int i = 0; i < 3; i++){
    800066ce:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800066d0:	0003cc97          	auipc	s9,0x3c
    800066d4:	8a8c8c93          	addi	s9,s9,-1880 # 80041f78 <disk+0x128>
    800066d8:	a08d                	j	8000673a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800066da:	00fb8733          	add	a4,s7,a5
    800066de:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800066e2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800066e4:	0207c563          	bltz	a5,8000670e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800066e8:	2905                	addiw	s2,s2,1
    800066ea:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800066ec:	05690c63          	beq	s2,s6,80006744 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800066f0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800066f2:	0003b717          	auipc	a4,0x3b
    800066f6:	75e70713          	addi	a4,a4,1886 # 80041e50 <disk>
    800066fa:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800066fc:	01874683          	lbu	a3,24(a4)
    80006700:	fee9                	bnez	a3,800066da <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006702:	2785                	addiw	a5,a5,1
    80006704:	0705                	addi	a4,a4,1
    80006706:	fe979be3          	bne	a5,s1,800066fc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000670a:	57fd                	li	a5,-1
    8000670c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000670e:	01205d63          	blez	s2,80006728 <virtio_disk_rw+0xa6>
    80006712:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006714:	000a2503          	lw	a0,0(s4)
    80006718:	00000097          	auipc	ra,0x0
    8000671c:	cfe080e7          	jalr	-770(ra) # 80006416 <free_desc>
      for(int j = 0; j < i; j++)
    80006720:	2d85                	addiw	s11,s11,1
    80006722:	0a11                	addi	s4,s4,4
    80006724:	ff2d98e3          	bne	s11,s2,80006714 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006728:	85e6                	mv	a1,s9
    8000672a:	0003b517          	auipc	a0,0x3b
    8000672e:	73e50513          	addi	a0,a0,1854 # 80041e68 <disk+0x18>
    80006732:	ffffc097          	auipc	ra,0xffffc
    80006736:	d24080e7          	jalr	-732(ra) # 80002456 <sleep>
  for(int i = 0; i < 3; i++){
    8000673a:	f8040a13          	addi	s4,s0,-128
{
    8000673e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006740:	894e                	mv	s2,s3
    80006742:	b77d                	j	800066f0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006744:	f8042503          	lw	a0,-128(s0)
    80006748:	00a50713          	addi	a4,a0,10
    8000674c:	0712                	slli	a4,a4,0x4

  if(write)
    8000674e:	0003b797          	auipc	a5,0x3b
    80006752:	70278793          	addi	a5,a5,1794 # 80041e50 <disk>
    80006756:	00e786b3          	add	a3,a5,a4
    8000675a:	01803633          	snez	a2,s8
    8000675e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006760:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006764:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006768:	f6070613          	addi	a2,a4,-160
    8000676c:	6394                	ld	a3,0(a5)
    8000676e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006770:	00870593          	addi	a1,a4,8
    80006774:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006776:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006778:	0007b803          	ld	a6,0(a5)
    8000677c:	9642                	add	a2,a2,a6
    8000677e:	46c1                	li	a3,16
    80006780:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006782:	4585                	li	a1,1
    80006784:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006788:	f8442683          	lw	a3,-124(s0)
    8000678c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006790:	0692                	slli	a3,a3,0x4
    80006792:	9836                	add	a6,a6,a3
    80006794:	058a8613          	addi	a2,s5,88
    80006798:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000679c:	0007b803          	ld	a6,0(a5)
    800067a0:	96c2                	add	a3,a3,a6
    800067a2:	40000613          	li	a2,1024
    800067a6:	c690                	sw	a2,8(a3)
  if(write)
    800067a8:	001c3613          	seqz	a2,s8
    800067ac:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800067b0:	00166613          	ori	a2,a2,1
    800067b4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800067b8:	f8842603          	lw	a2,-120(s0)
    800067bc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800067c0:	00250693          	addi	a3,a0,2
    800067c4:	0692                	slli	a3,a3,0x4
    800067c6:	96be                	add	a3,a3,a5
    800067c8:	58fd                	li	a7,-1
    800067ca:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800067ce:	0612                	slli	a2,a2,0x4
    800067d0:	9832                	add	a6,a6,a2
    800067d2:	f9070713          	addi	a4,a4,-112
    800067d6:	973e                	add	a4,a4,a5
    800067d8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800067dc:	6398                	ld	a4,0(a5)
    800067de:	9732                	add	a4,a4,a2
    800067e0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800067e2:	4609                	li	a2,2
    800067e4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800067e8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800067ec:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800067f0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800067f4:	6794                	ld	a3,8(a5)
    800067f6:	0026d703          	lhu	a4,2(a3)
    800067fa:	8b1d                	andi	a4,a4,7
    800067fc:	0706                	slli	a4,a4,0x1
    800067fe:	96ba                	add	a3,a3,a4
    80006800:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006804:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006808:	6798                	ld	a4,8(a5)
    8000680a:	00275783          	lhu	a5,2(a4)
    8000680e:	2785                	addiw	a5,a5,1
    80006810:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006814:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006818:	100017b7          	lui	a5,0x10001
    8000681c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006820:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006824:	0003b917          	auipc	s2,0x3b
    80006828:	75490913          	addi	s2,s2,1876 # 80041f78 <disk+0x128>
  while(b->disk == 1) {
    8000682c:	4485                	li	s1,1
    8000682e:	00b79c63          	bne	a5,a1,80006846 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006832:	85ca                	mv	a1,s2
    80006834:	8556                	mv	a0,s5
    80006836:	ffffc097          	auipc	ra,0xffffc
    8000683a:	c20080e7          	jalr	-992(ra) # 80002456 <sleep>
  while(b->disk == 1) {
    8000683e:	004aa783          	lw	a5,4(s5)
    80006842:	fe9788e3          	beq	a5,s1,80006832 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006846:	f8042903          	lw	s2,-128(s0)
    8000684a:	00290713          	addi	a4,s2,2
    8000684e:	0712                	slli	a4,a4,0x4
    80006850:	0003b797          	auipc	a5,0x3b
    80006854:	60078793          	addi	a5,a5,1536 # 80041e50 <disk>
    80006858:	97ba                	add	a5,a5,a4
    8000685a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000685e:	0003b997          	auipc	s3,0x3b
    80006862:	5f298993          	addi	s3,s3,1522 # 80041e50 <disk>
    80006866:	00491713          	slli	a4,s2,0x4
    8000686a:	0009b783          	ld	a5,0(s3)
    8000686e:	97ba                	add	a5,a5,a4
    80006870:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006874:	854a                	mv	a0,s2
    80006876:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000687a:	00000097          	auipc	ra,0x0
    8000687e:	b9c080e7          	jalr	-1124(ra) # 80006416 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006882:	8885                	andi	s1,s1,1
    80006884:	f0ed                	bnez	s1,80006866 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006886:	0003b517          	auipc	a0,0x3b
    8000688a:	6f250513          	addi	a0,a0,1778 # 80041f78 <disk+0x128>
    8000688e:	ffffa097          	auipc	ra,0xffffa
    80006892:	600080e7          	jalr	1536(ra) # 80000e8e <release>
}
    80006896:	70e6                	ld	ra,120(sp)
    80006898:	7446                	ld	s0,112(sp)
    8000689a:	74a6                	ld	s1,104(sp)
    8000689c:	7906                	ld	s2,96(sp)
    8000689e:	69e6                	ld	s3,88(sp)
    800068a0:	6a46                	ld	s4,80(sp)
    800068a2:	6aa6                	ld	s5,72(sp)
    800068a4:	6b06                	ld	s6,64(sp)
    800068a6:	7be2                	ld	s7,56(sp)
    800068a8:	7c42                	ld	s8,48(sp)
    800068aa:	7ca2                	ld	s9,40(sp)
    800068ac:	7d02                	ld	s10,32(sp)
    800068ae:	6de2                	ld	s11,24(sp)
    800068b0:	6109                	addi	sp,sp,128
    800068b2:	8082                	ret

00000000800068b4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800068b4:	1101                	addi	sp,sp,-32
    800068b6:	ec06                	sd	ra,24(sp)
    800068b8:	e822                	sd	s0,16(sp)
    800068ba:	e426                	sd	s1,8(sp)
    800068bc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800068be:	0003b497          	auipc	s1,0x3b
    800068c2:	59248493          	addi	s1,s1,1426 # 80041e50 <disk>
    800068c6:	0003b517          	auipc	a0,0x3b
    800068ca:	6b250513          	addi	a0,a0,1714 # 80041f78 <disk+0x128>
    800068ce:	ffffa097          	auipc	ra,0xffffa
    800068d2:	50c080e7          	jalr	1292(ra) # 80000dda <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800068d6:	10001737          	lui	a4,0x10001
    800068da:	533c                	lw	a5,96(a4)
    800068dc:	8b8d                	andi	a5,a5,3
    800068de:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800068e0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800068e4:	689c                	ld	a5,16(s1)
    800068e6:	0204d703          	lhu	a4,32(s1)
    800068ea:	0027d783          	lhu	a5,2(a5)
    800068ee:	04f70863          	beq	a4,a5,8000693e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800068f2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800068f6:	6898                	ld	a4,16(s1)
    800068f8:	0204d783          	lhu	a5,32(s1)
    800068fc:	8b9d                	andi	a5,a5,7
    800068fe:	078e                	slli	a5,a5,0x3
    80006900:	97ba                	add	a5,a5,a4
    80006902:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006904:	00278713          	addi	a4,a5,2
    80006908:	0712                	slli	a4,a4,0x4
    8000690a:	9726                	add	a4,a4,s1
    8000690c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006910:	e721                	bnez	a4,80006958 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006912:	0789                	addi	a5,a5,2
    80006914:	0792                	slli	a5,a5,0x4
    80006916:	97a6                	add	a5,a5,s1
    80006918:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000691a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000691e:	ffffc097          	auipc	ra,0xffffc
    80006922:	b9c080e7          	jalr	-1124(ra) # 800024ba <wakeup>

    disk.used_idx += 1;
    80006926:	0204d783          	lhu	a5,32(s1)
    8000692a:	2785                	addiw	a5,a5,1
    8000692c:	17c2                	slli	a5,a5,0x30
    8000692e:	93c1                	srli	a5,a5,0x30
    80006930:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006934:	6898                	ld	a4,16(s1)
    80006936:	00275703          	lhu	a4,2(a4)
    8000693a:	faf71ce3          	bne	a4,a5,800068f2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000693e:	0003b517          	auipc	a0,0x3b
    80006942:	63a50513          	addi	a0,a0,1594 # 80041f78 <disk+0x128>
    80006946:	ffffa097          	auipc	ra,0xffffa
    8000694a:	548080e7          	jalr	1352(ra) # 80000e8e <release>
}
    8000694e:	60e2                	ld	ra,24(sp)
    80006950:	6442                	ld	s0,16(sp)
    80006952:	64a2                	ld	s1,8(sp)
    80006954:	6105                	addi	sp,sp,32
    80006956:	8082                	ret
      panic("virtio_disk_intr status");
    80006958:	00002517          	auipc	a0,0x2
    8000695c:	0c050513          	addi	a0,a0,192 # 80008a18 <syscalls+0x400>
    80006960:	ffffa097          	auipc	ra,0xffffa
    80006964:	be0080e7          	jalr	-1056(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
