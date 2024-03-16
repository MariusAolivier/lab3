
user/_vatopa:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32

  if (argc > 3) {
   c:	478d                	li	a5,3
   e:	02a7c163          	blt	a5,a0,30 <main+0x30>
  12:	84ae                	mv	s1,a1
    printf("Usage: vatopa [virtual address] [pid]\n");
    exit(1);
  }
  if (argc == 3){
  14:	478d                	li	a5,3
  16:	02f50a63          	beq	a0,a5,4a <main+0x4a>
    int addr = va2pa(atoi(argv[1]), atoi(argv[2]));
    printf("0x%x\n", addr);
  }
  if (argc == 2) {
  1a:	4789                	li	a5,2
  1c:	06f50363          	beq	a0,a5,82 <main+0x82>
    int addr = va2pa(atoi(argv[1]), getpid());
    printf("0x%x\n", addr);
  }
  if (argc == 1) {
  20:	4785                	li	a5,1
  22:	08f50b63          	beq	a0,a5,b8 <main+0xb8>
    int addr = va2pa(0, getpid());
    printf("0x%x\n", addr);
  }
    exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	340080e7          	jalr	832(ra) # 368 <exit>
    printf("Usage: vatopa [virtual address] [pid]\n");
  30:	00001517          	auipc	a0,0x1
  34:	88050513          	addi	a0,a0,-1920 # 8b0 <malloc+0xee>
  38:	00000097          	auipc	ra,0x0
  3c:	6d2080e7          	jalr	1746(ra) # 70a <printf>
    exit(1);
  40:	4505                	li	a0,1
  42:	00000097          	auipc	ra,0x0
  46:	326080e7          	jalr	806(ra) # 368 <exit>
    int addr = va2pa(atoi(argv[1]), atoi(argv[2]));
  4a:	6588                	ld	a0,8(a1)
  4c:	00000097          	auipc	ra,0x0
  50:	222080e7          	jalr	546(ra) # 26e <atoi>
  54:	892a                	mv	s2,a0
  56:	6888                	ld	a0,16(s1)
  58:	00000097          	auipc	ra,0x0
  5c:	216080e7          	jalr	534(ra) # 26e <atoi>
  60:	85aa                	mv	a1,a0
  62:	854a                	mv	a0,s2
  64:	00000097          	auipc	ra,0x0
  68:	3bc080e7          	jalr	956(ra) # 420 <va2pa>
    printf("0x%x\n", addr);
  6c:	0005059b          	sext.w	a1,a0
  70:	00001517          	auipc	a0,0x1
  74:	86850513          	addi	a0,a0,-1944 # 8d8 <malloc+0x116>
  78:	00000097          	auipc	ra,0x0
  7c:	692080e7          	jalr	1682(ra) # 70a <printf>
  if (argc == 1) {
  80:	b75d                	j	26 <main+0x26>
    int addr = va2pa(atoi(argv[1]), getpid());
  82:	6588                	ld	a0,8(a1)
  84:	00000097          	auipc	ra,0x0
  88:	1ea080e7          	jalr	490(ra) # 26e <atoi>
  8c:	84aa                	mv	s1,a0
  8e:	00000097          	auipc	ra,0x0
  92:	35a080e7          	jalr	858(ra) # 3e8 <getpid>
  96:	85aa                	mv	a1,a0
  98:	8526                	mv	a0,s1
  9a:	00000097          	auipc	ra,0x0
  9e:	386080e7          	jalr	902(ra) # 420 <va2pa>
    printf("0x%x\n", addr);
  a2:	0005059b          	sext.w	a1,a0
  a6:	00001517          	auipc	a0,0x1
  aa:	83250513          	addi	a0,a0,-1998 # 8d8 <malloc+0x116>
  ae:	00000097          	auipc	ra,0x0
  b2:	65c080e7          	jalr	1628(ra) # 70a <printf>
  if (argc == 1) {
  b6:	bf85                	j	26 <main+0x26>
    int addr = va2pa(0, getpid());
  b8:	00000097          	auipc	ra,0x0
  bc:	330080e7          	jalr	816(ra) # 3e8 <getpid>
  c0:	85aa                	mv	a1,a0
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	35c080e7          	jalr	860(ra) # 420 <va2pa>
    printf("0x%x\n", addr);
  cc:	0005059b          	sext.w	a1,a0
  d0:	00001517          	auipc	a0,0x1
  d4:	80850513          	addi	a0,a0,-2040 # 8d8 <malloc+0x116>
  d8:	00000097          	auipc	ra,0x0
  dc:	632080e7          	jalr	1586(ra) # 70a <printf>
  e0:	b799                	j	26 <main+0x26>

00000000000000e2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e406                	sd	ra,8(sp)
  e6:	e022                	sd	s0,0(sp)
  e8:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ea:	00000097          	auipc	ra,0x0
  ee:	f16080e7          	jalr	-234(ra) # 0 <main>
  exit(0);
  f2:	4501                	li	a0,0
  f4:	00000097          	auipc	ra,0x0
  f8:	274080e7          	jalr	628(ra) # 368 <exit>

00000000000000fc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 102:	87aa                	mv	a5,a0
 104:	0585                	addi	a1,a1,1
 106:	0785                	addi	a5,a5,1
 108:	fff5c703          	lbu	a4,-1(a1)
 10c:	fee78fa3          	sb	a4,-1(a5)
 110:	fb75                	bnez	a4,104 <strcpy+0x8>
    ;
  return os;
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cb91                	beqz	a5,136 <strcmp+0x1e>
 124:	0005c703          	lbu	a4,0(a1)
 128:	00f71763          	bne	a4,a5,136 <strcmp+0x1e>
    p++, q++;
 12c:	0505                	addi	a0,a0,1
 12e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 130:	00054783          	lbu	a5,0(a0)
 134:	fbe5                	bnez	a5,124 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 136:	0005c503          	lbu	a0,0(a1)
}
 13a:	40a7853b          	subw	a0,a5,a0
 13e:	6422                	ld	s0,8(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strlen>:

uint
strlen(const char *s)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cf91                	beqz	a5,16a <strlen+0x26>
 150:	0505                	addi	a0,a0,1
 152:	87aa                	mv	a5,a0
 154:	4685                	li	a3,1
 156:	9e89                	subw	a3,a3,a0
 158:	00f6853b          	addw	a0,a3,a5
 15c:	0785                	addi	a5,a5,1
 15e:	fff7c703          	lbu	a4,-1(a5)
 162:	fb7d                	bnez	a4,158 <strlen+0x14>
    ;
  return n;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  for(n = 0; s[n]; n++)
 16a:	4501                	li	a0,0
 16c:	bfe5                	j	164 <strlen+0x20>

000000000000016e <memset>:

void*
memset(void *dst, int c, uint n)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 174:	ca19                	beqz	a2,18a <memset+0x1c>
 176:	87aa                	mv	a5,a0
 178:	1602                	slli	a2,a2,0x20
 17a:	9201                	srli	a2,a2,0x20
 17c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 180:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 184:	0785                	addi	a5,a5,1
 186:	fee79de3          	bne	a5,a4,180 <memset+0x12>
  }
  return dst;
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  for(; *s; s++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cb99                	beqz	a5,1b0 <strchr+0x20>
    if(*s == c)
 19c:	00f58763          	beq	a1,a5,1aa <strchr+0x1a>
  for(; *s; s++)
 1a0:	0505                	addi	a0,a0,1
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbfd                	bnez	a5,19c <strchr+0xc>
      return (char*)s;
  return 0;
 1a8:	4501                	li	a0,0
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret
  return 0;
 1b0:	4501                	li	a0,0
 1b2:	bfe5                	j	1aa <strchr+0x1a>

00000000000001b4 <gets>:

char*
gets(char *buf, int max)
{
 1b4:	711d                	addi	sp,sp,-96
 1b6:	ec86                	sd	ra,88(sp)
 1b8:	e8a2                	sd	s0,80(sp)
 1ba:	e4a6                	sd	s1,72(sp)
 1bc:	e0ca                	sd	s2,64(sp)
 1be:	fc4e                	sd	s3,56(sp)
 1c0:	f852                	sd	s4,48(sp)
 1c2:	f456                	sd	s5,40(sp)
 1c4:	f05a                	sd	s6,32(sp)
 1c6:	ec5e                	sd	s7,24(sp)
 1c8:	1080                	addi	s0,sp,96
 1ca:	8baa                	mv	s7,a0
 1cc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ce:	892a                	mv	s2,a0
 1d0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d2:	4aa9                	li	s5,10
 1d4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	2485                	addiw	s1,s1,1
 1da:	0344d863          	bge	s1,s4,20a <gets+0x56>
    cc = read(0, &c, 1);
 1de:	4605                	li	a2,1
 1e0:	faf40593          	addi	a1,s0,-81
 1e4:	4501                	li	a0,0
 1e6:	00000097          	auipc	ra,0x0
 1ea:	19a080e7          	jalr	410(ra) # 380 <read>
    if(cc < 1)
 1ee:	00a05e63          	blez	a0,20a <gets+0x56>
    buf[i++] = c;
 1f2:	faf44783          	lbu	a5,-81(s0)
 1f6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fa:	01578763          	beq	a5,s5,208 <gets+0x54>
 1fe:	0905                	addi	s2,s2,1
 200:	fd679be3          	bne	a5,s6,1d6 <gets+0x22>
  for(i=0; i+1 < max; ){
 204:	89a6                	mv	s3,s1
 206:	a011                	j	20a <gets+0x56>
 208:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20a:	99de                	add	s3,s3,s7
 20c:	00098023          	sb	zero,0(s3)
  return buf;
}
 210:	855e                	mv	a0,s7
 212:	60e6                	ld	ra,88(sp)
 214:	6446                	ld	s0,80(sp)
 216:	64a6                	ld	s1,72(sp)
 218:	6906                	ld	s2,64(sp)
 21a:	79e2                	ld	s3,56(sp)
 21c:	7a42                	ld	s4,48(sp)
 21e:	7aa2                	ld	s5,40(sp)
 220:	7b02                	ld	s6,32(sp)
 222:	6be2                	ld	s7,24(sp)
 224:	6125                	addi	sp,sp,96
 226:	8082                	ret

0000000000000228 <stat>:

int
stat(const char *n, struct stat *st)
{
 228:	1101                	addi	sp,sp,-32
 22a:	ec06                	sd	ra,24(sp)
 22c:	e822                	sd	s0,16(sp)
 22e:	e426                	sd	s1,8(sp)
 230:	e04a                	sd	s2,0(sp)
 232:	1000                	addi	s0,sp,32
 234:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 236:	4581                	li	a1,0
 238:	00000097          	auipc	ra,0x0
 23c:	170080e7          	jalr	368(ra) # 3a8 <open>
  if(fd < 0)
 240:	02054563          	bltz	a0,26a <stat+0x42>
 244:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 246:	85ca                	mv	a1,s2
 248:	00000097          	auipc	ra,0x0
 24c:	178080e7          	jalr	376(ra) # 3c0 <fstat>
 250:	892a                	mv	s2,a0
  close(fd);
 252:	8526                	mv	a0,s1
 254:	00000097          	auipc	ra,0x0
 258:	13c080e7          	jalr	316(ra) # 390 <close>
  return r;
}
 25c:	854a                	mv	a0,s2
 25e:	60e2                	ld	ra,24(sp)
 260:	6442                	ld	s0,16(sp)
 262:	64a2                	ld	s1,8(sp)
 264:	6902                	ld	s2,0(sp)
 266:	6105                	addi	sp,sp,32
 268:	8082                	ret
    return -1;
 26a:	597d                	li	s2,-1
 26c:	bfc5                	j	25c <stat+0x34>

000000000000026e <atoi>:

int
atoi(const char *s)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 274:	00054683          	lbu	a3,0(a0)
 278:	fd06879b          	addiw	a5,a3,-48
 27c:	0ff7f793          	zext.b	a5,a5
 280:	4625                	li	a2,9
 282:	02f66863          	bltu	a2,a5,2b2 <atoi+0x44>
 286:	872a                	mv	a4,a0
  n = 0;
 288:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28a:	0705                	addi	a4,a4,1
 28c:	0025179b          	slliw	a5,a0,0x2
 290:	9fa9                	addw	a5,a5,a0
 292:	0017979b          	slliw	a5,a5,0x1
 296:	9fb5                	addw	a5,a5,a3
 298:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29c:	00074683          	lbu	a3,0(a4)
 2a0:	fd06879b          	addiw	a5,a3,-48
 2a4:	0ff7f793          	zext.b	a5,a5
 2a8:	fef671e3          	bgeu	a2,a5,28a <atoi+0x1c>
  return n;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
  n = 0;
 2b2:	4501                	li	a0,0
 2b4:	bfe5                	j	2ac <atoi+0x3e>

00000000000002b6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2bc:	02b57463          	bgeu	a0,a1,2e4 <memmove+0x2e>
    while(n-- > 0)
 2c0:	00c05f63          	blez	a2,2de <memmove+0x28>
 2c4:	1602                	slli	a2,a2,0x20
 2c6:	9201                	srli	a2,a2,0x20
 2c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ce:	0585                	addi	a1,a1,1
 2d0:	0705                	addi	a4,a4,1
 2d2:	fff5c683          	lbu	a3,-1(a1)
 2d6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
    dst += n;
 2e4:	00c50733          	add	a4,a0,a2
    src += n;
 2e8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ea:	fec05ae3          	blez	a2,2de <memmove+0x28>
 2ee:	fff6079b          	addiw	a5,a2,-1
 2f2:	1782                	slli	a5,a5,0x20
 2f4:	9381                	srli	a5,a5,0x20
 2f6:	fff7c793          	not	a5,a5
 2fa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fc:	15fd                	addi	a1,a1,-1
 2fe:	177d                	addi	a4,a4,-1
 300:	0005c683          	lbu	a3,0(a1)
 304:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 308:	fee79ae3          	bne	a5,a4,2fc <memmove+0x46>
 30c:	bfc9                	j	2de <memmove+0x28>

000000000000030e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 314:	ca05                	beqz	a2,344 <memcmp+0x36>
 316:	fff6069b          	addiw	a3,a2,-1
 31a:	1682                	slli	a3,a3,0x20
 31c:	9281                	srli	a3,a3,0x20
 31e:	0685                	addi	a3,a3,1
 320:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 322:	00054783          	lbu	a5,0(a0)
 326:	0005c703          	lbu	a4,0(a1)
 32a:	00e79863          	bne	a5,a4,33a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32e:	0505                	addi	a0,a0,1
    p2++;
 330:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 332:	fed518e3          	bne	a0,a3,322 <memcmp+0x14>
  }
  return 0;
 336:	4501                	li	a0,0
 338:	a019                	j	33e <memcmp+0x30>
      return *p1 - *p2;
 33a:	40e7853b          	subw	a0,a5,a4
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  return 0;
 344:	4501                	li	a0,0
 346:	bfe5                	j	33e <memcmp+0x30>

0000000000000348 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e406                	sd	ra,8(sp)
 34c:	e022                	sd	s0,0(sp)
 34e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 350:	00000097          	auipc	ra,0x0
 354:	f66080e7          	jalr	-154(ra) # 2b6 <memmove>
}
 358:	60a2                	ld	ra,8(sp)
 35a:	6402                	ld	s0,0(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret

0000000000000360 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 360:	4885                	li	a7,1
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <exit>:
.global exit
exit:
 li a7, SYS_exit
 368:	4889                	li	a7,2
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <wait>:
.global wait
wait:
 li a7, SYS_wait
 370:	488d                	li	a7,3
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 378:	4891                	li	a7,4
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <read>:
.global read
read:
 li a7, SYS_read
 380:	4895                	li	a7,5
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <write>:
.global write
write:
 li a7, SYS_write
 388:	48c1                	li	a7,16
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <close>:
.global close
close:
 li a7, SYS_close
 390:	48d5                	li	a7,21
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <kill>:
.global kill
kill:
 li a7, SYS_kill
 398:	4899                	li	a7,6
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a0:	489d                	li	a7,7
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <open>:
.global open
open:
 li a7, SYS_open
 3a8:	48bd                	li	a7,15
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b0:	48c5                	li	a7,17
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b8:	48c9                	li	a7,18
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c0:	48a1                	li	a7,8
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <link>:
.global link
link:
 li a7, SYS_link
 3c8:	48cd                	li	a7,19
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d0:	48d1                	li	a7,20
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d8:	48a5                	li	a7,9
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e0:	48a9                	li	a7,10
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e8:	48ad                	li	a7,11
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f0:	48b1                	li	a7,12
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f8:	48b5                	li	a7,13
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 400:	48b9                	li	a7,14
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <ps>:
.global ps
ps:
 li a7, SYS_ps
 408:	48d9                	li	a7,22
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 410:	48dd                	li	a7,23
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 418:	48e1                	li	a7,24
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 420:	48e9                	li	a7,26
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 428:	48e5                	li	a7,25
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 430:	1101                	addi	sp,sp,-32
 432:	ec06                	sd	ra,24(sp)
 434:	e822                	sd	s0,16(sp)
 436:	1000                	addi	s0,sp,32
 438:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43c:	4605                	li	a2,1
 43e:	fef40593          	addi	a1,s0,-17
 442:	00000097          	auipc	ra,0x0
 446:	f46080e7          	jalr	-186(ra) # 388 <write>
}
 44a:	60e2                	ld	ra,24(sp)
 44c:	6442                	ld	s0,16(sp)
 44e:	6105                	addi	sp,sp,32
 450:	8082                	ret

0000000000000452 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 452:	7139                	addi	sp,sp,-64
 454:	fc06                	sd	ra,56(sp)
 456:	f822                	sd	s0,48(sp)
 458:	f426                	sd	s1,40(sp)
 45a:	f04a                	sd	s2,32(sp)
 45c:	ec4e                	sd	s3,24(sp)
 45e:	0080                	addi	s0,sp,64
 460:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 462:	c299                	beqz	a3,468 <printint+0x16>
 464:	0805c963          	bltz	a1,4f6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 468:	2581                	sext.w	a1,a1
  neg = 0;
 46a:	4881                	li	a7,0
 46c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 470:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 472:	2601                	sext.w	a2,a2
 474:	00000517          	auipc	a0,0x0
 478:	4cc50513          	addi	a0,a0,1228 # 940 <digits>
 47c:	883a                	mv	a6,a4
 47e:	2705                	addiw	a4,a4,1
 480:	02c5f7bb          	remuw	a5,a1,a2
 484:	1782                	slli	a5,a5,0x20
 486:	9381                	srli	a5,a5,0x20
 488:	97aa                	add	a5,a5,a0
 48a:	0007c783          	lbu	a5,0(a5)
 48e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 492:	0005879b          	sext.w	a5,a1
 496:	02c5d5bb          	divuw	a1,a1,a2
 49a:	0685                	addi	a3,a3,1
 49c:	fec7f0e3          	bgeu	a5,a2,47c <printint+0x2a>
  if(neg)
 4a0:	00088c63          	beqz	a7,4b8 <printint+0x66>
    buf[i++] = '-';
 4a4:	fd070793          	addi	a5,a4,-48
 4a8:	00878733          	add	a4,a5,s0
 4ac:	02d00793          	li	a5,45
 4b0:	fef70823          	sb	a5,-16(a4)
 4b4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4b8:	02e05863          	blez	a4,4e8 <printint+0x96>
 4bc:	fc040793          	addi	a5,s0,-64
 4c0:	00e78933          	add	s2,a5,a4
 4c4:	fff78993          	addi	s3,a5,-1
 4c8:	99ba                	add	s3,s3,a4
 4ca:	377d                	addiw	a4,a4,-1
 4cc:	1702                	slli	a4,a4,0x20
 4ce:	9301                	srli	a4,a4,0x20
 4d0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4d4:	fff94583          	lbu	a1,-1(s2)
 4d8:	8526                	mv	a0,s1
 4da:	00000097          	auipc	ra,0x0
 4de:	f56080e7          	jalr	-170(ra) # 430 <putc>
  while(--i >= 0)
 4e2:	197d                	addi	s2,s2,-1
 4e4:	ff3918e3          	bne	s2,s3,4d4 <printint+0x82>
}
 4e8:	70e2                	ld	ra,56(sp)
 4ea:	7442                	ld	s0,48(sp)
 4ec:	74a2                	ld	s1,40(sp)
 4ee:	7902                	ld	s2,32(sp)
 4f0:	69e2                	ld	s3,24(sp)
 4f2:	6121                	addi	sp,sp,64
 4f4:	8082                	ret
    x = -xx;
 4f6:	40b005bb          	negw	a1,a1
    neg = 1;
 4fa:	4885                	li	a7,1
    x = -xx;
 4fc:	bf85                	j	46c <printint+0x1a>

00000000000004fe <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fe:	7119                	addi	sp,sp,-128
 500:	fc86                	sd	ra,120(sp)
 502:	f8a2                	sd	s0,112(sp)
 504:	f4a6                	sd	s1,104(sp)
 506:	f0ca                	sd	s2,96(sp)
 508:	ecce                	sd	s3,88(sp)
 50a:	e8d2                	sd	s4,80(sp)
 50c:	e4d6                	sd	s5,72(sp)
 50e:	e0da                	sd	s6,64(sp)
 510:	fc5e                	sd	s7,56(sp)
 512:	f862                	sd	s8,48(sp)
 514:	f466                	sd	s9,40(sp)
 516:	f06a                	sd	s10,32(sp)
 518:	ec6e                	sd	s11,24(sp)
 51a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51c:	0005c903          	lbu	s2,0(a1)
 520:	18090f63          	beqz	s2,6be <vprintf+0x1c0>
 524:	8aaa                	mv	s5,a0
 526:	8b32                	mv	s6,a2
 528:	00158493          	addi	s1,a1,1
  state = 0;
 52c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 52e:	02500a13          	li	s4,37
 532:	4c55                	li	s8,21
 534:	00000c97          	auipc	s9,0x0
 538:	3b4c8c93          	addi	s9,s9,948 # 8e8 <malloc+0x126>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 53c:	02800d93          	li	s11,40
  putc(fd, 'x');
 540:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 542:	00000b97          	auipc	s7,0x0
 546:	3feb8b93          	addi	s7,s7,1022 # 940 <digits>
 54a:	a839                	j	568 <vprintf+0x6a>
        putc(fd, c);
 54c:	85ca                	mv	a1,s2
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	ee0080e7          	jalr	-288(ra) # 430 <putc>
 558:	a019                	j	55e <vprintf+0x60>
    } else if(state == '%'){
 55a:	01498d63          	beq	s3,s4,574 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 55e:	0485                	addi	s1,s1,1
 560:	fff4c903          	lbu	s2,-1(s1)
 564:	14090d63          	beqz	s2,6be <vprintf+0x1c0>
    if(state == 0){
 568:	fe0999e3          	bnez	s3,55a <vprintf+0x5c>
      if(c == '%'){
 56c:	ff4910e3          	bne	s2,s4,54c <vprintf+0x4e>
        state = '%';
 570:	89d2                	mv	s3,s4
 572:	b7f5                	j	55e <vprintf+0x60>
      if(c == 'd'){
 574:	11490c63          	beq	s2,s4,68c <vprintf+0x18e>
 578:	f9d9079b          	addiw	a5,s2,-99
 57c:	0ff7f793          	zext.b	a5,a5
 580:	10fc6e63          	bltu	s8,a5,69c <vprintf+0x19e>
 584:	f9d9079b          	addiw	a5,s2,-99
 588:	0ff7f713          	zext.b	a4,a5
 58c:	10ec6863          	bltu	s8,a4,69c <vprintf+0x19e>
 590:	00271793          	slli	a5,a4,0x2
 594:	97e6                	add	a5,a5,s9
 596:	439c                	lw	a5,0(a5)
 598:	97e6                	add	a5,a5,s9
 59a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59c:	008b0913          	addi	s2,s6,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000b2583          	lw	a1,0(s6)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	ea8080e7          	jalr	-344(ra) # 452 <printint>
 5b2:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b765                	j	55e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b8:	008b0913          	addi	s2,s6,8
 5bc:	4681                	li	a3,0
 5be:	4629                	li	a2,10
 5c0:	000b2583          	lw	a1,0(s6)
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e8c080e7          	jalr	-372(ra) # 452 <printint>
 5ce:	8b4a                	mv	s6,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b771                	j	55e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5d4:	008b0913          	addi	s2,s6,8
 5d8:	4681                	li	a3,0
 5da:	866a                	mv	a2,s10
 5dc:	000b2583          	lw	a1,0(s6)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	e70080e7          	jalr	-400(ra) # 452 <printint>
 5ea:	8b4a                	mv	s6,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bf85                	j	55e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5f0:	008b0793          	addi	a5,s6,8
 5f4:	f8f43423          	sd	a5,-120(s0)
 5f8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5fc:	03000593          	li	a1,48
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e2e080e7          	jalr	-466(ra) # 430 <putc>
  putc(fd, 'x');
 60a:	07800593          	li	a1,120
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e20080e7          	jalr	-480(ra) # 430 <putc>
 618:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61a:	03c9d793          	srli	a5,s3,0x3c
 61e:	97de                	add	a5,a5,s7
 620:	0007c583          	lbu	a1,0(a5)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e0a080e7          	jalr	-502(ra) # 430 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62e:	0992                	slli	s3,s3,0x4
 630:	397d                	addiw	s2,s2,-1
 632:	fe0914e3          	bnez	s2,61a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 636:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b70d                	j	55e <vprintf+0x60>
        s = va_arg(ap, char*);
 63e:	008b0913          	addi	s2,s6,8
 642:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 646:	02098163          	beqz	s3,668 <vprintf+0x16a>
        while(*s != 0){
 64a:	0009c583          	lbu	a1,0(s3)
 64e:	c5ad                	beqz	a1,6b8 <vprintf+0x1ba>
          putc(fd, *s);
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	dde080e7          	jalr	-546(ra) # 430 <putc>
          s++;
 65a:	0985                	addi	s3,s3,1
        while(*s != 0){
 65c:	0009c583          	lbu	a1,0(s3)
 660:	f9e5                	bnez	a1,650 <vprintf+0x152>
        s = va_arg(ap, char*);
 662:	8b4a                	mv	s6,s2
      state = 0;
 664:	4981                	li	s3,0
 666:	bde5                	j	55e <vprintf+0x60>
          s = "(null)";
 668:	00000997          	auipc	s3,0x0
 66c:	27898993          	addi	s3,s3,632 # 8e0 <malloc+0x11e>
        while(*s != 0){
 670:	85ee                	mv	a1,s11
 672:	bff9                	j	650 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 674:	008b0913          	addi	s2,s6,8
 678:	000b4583          	lbu	a1,0(s6)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	db2080e7          	jalr	-590(ra) # 430 <putc>
 686:	8b4a                	mv	s6,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bdd1                	j	55e <vprintf+0x60>
        putc(fd, c);
 68c:	85d2                	mv	a1,s4
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	da0080e7          	jalr	-608(ra) # 430 <putc>
      state = 0;
 698:	4981                	li	s3,0
 69a:	b5d1                	j	55e <vprintf+0x60>
        putc(fd, '%');
 69c:	85d2                	mv	a1,s4
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	d90080e7          	jalr	-624(ra) # 430 <putc>
        putc(fd, c);
 6a8:	85ca                	mv	a1,s2
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d84080e7          	jalr	-636(ra) # 430 <putc>
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b565                	j	55e <vprintf+0x60>
        s = va_arg(ap, char*);
 6b8:	8b4a                	mv	s6,s2
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b54d                	j	55e <vprintf+0x60>
    }
  }
}
 6be:	70e6                	ld	ra,120(sp)
 6c0:	7446                	ld	s0,112(sp)
 6c2:	74a6                	ld	s1,104(sp)
 6c4:	7906                	ld	s2,96(sp)
 6c6:	69e6                	ld	s3,88(sp)
 6c8:	6a46                	ld	s4,80(sp)
 6ca:	6aa6                	ld	s5,72(sp)
 6cc:	6b06                	ld	s6,64(sp)
 6ce:	7be2                	ld	s7,56(sp)
 6d0:	7c42                	ld	s8,48(sp)
 6d2:	7ca2                	ld	s9,40(sp)
 6d4:	7d02                	ld	s10,32(sp)
 6d6:	6de2                	ld	s11,24(sp)
 6d8:	6109                	addi	sp,sp,128
 6da:	8082                	ret

00000000000006dc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6dc:	715d                	addi	sp,sp,-80
 6de:	ec06                	sd	ra,24(sp)
 6e0:	e822                	sd	s0,16(sp)
 6e2:	1000                	addi	s0,sp,32
 6e4:	e010                	sd	a2,0(s0)
 6e6:	e414                	sd	a3,8(s0)
 6e8:	e818                	sd	a4,16(s0)
 6ea:	ec1c                	sd	a5,24(s0)
 6ec:	03043023          	sd	a6,32(s0)
 6f0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f8:	8622                	mv	a2,s0
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e04080e7          	jalr	-508(ra) # 4fe <vprintf>
}
 702:	60e2                	ld	ra,24(sp)
 704:	6442                	ld	s0,16(sp)
 706:	6161                	addi	sp,sp,80
 708:	8082                	ret

000000000000070a <printf>:

void
printf(const char *fmt, ...)
{
 70a:	711d                	addi	sp,sp,-96
 70c:	ec06                	sd	ra,24(sp)
 70e:	e822                	sd	s0,16(sp)
 710:	1000                	addi	s0,sp,32
 712:	e40c                	sd	a1,8(s0)
 714:	e810                	sd	a2,16(s0)
 716:	ec14                	sd	a3,24(s0)
 718:	f018                	sd	a4,32(s0)
 71a:	f41c                	sd	a5,40(s0)
 71c:	03043823          	sd	a6,48(s0)
 720:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 724:	00840613          	addi	a2,s0,8
 728:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 72c:	85aa                	mv	a1,a0
 72e:	4505                	li	a0,1
 730:	00000097          	auipc	ra,0x0
 734:	dce080e7          	jalr	-562(ra) # 4fe <vprintf>
}
 738:	60e2                	ld	ra,24(sp)
 73a:	6442                	ld	s0,16(sp)
 73c:	6125                	addi	sp,sp,96
 73e:	8082                	ret

0000000000000740 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 740:	1141                	addi	sp,sp,-16
 742:	e422                	sd	s0,8(sp)
 744:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 746:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74a:	00001797          	auipc	a5,0x1
 74e:	8b67b783          	ld	a5,-1866(a5) # 1000 <freep>
 752:	a02d                	j	77c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 754:	4618                	lw	a4,8(a2)
 756:	9f2d                	addw	a4,a4,a1
 758:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 75c:	6398                	ld	a4,0(a5)
 75e:	6310                	ld	a2,0(a4)
 760:	a83d                	j	79e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 762:	ff852703          	lw	a4,-8(a0)
 766:	9f31                	addw	a4,a4,a2
 768:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 76a:	ff053683          	ld	a3,-16(a0)
 76e:	a091                	j	7b2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	6398                	ld	a4,0(a5)
 772:	00e7e463          	bltu	a5,a4,77a <free+0x3a>
 776:	00e6ea63          	bltu	a3,a4,78a <free+0x4a>
{
 77a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	fed7fae3          	bgeu	a5,a3,770 <free+0x30>
 780:	6398                	ld	a4,0(a5)
 782:	00e6e463          	bltu	a3,a4,78a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 786:	fee7eae3          	bltu	a5,a4,77a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 78a:	ff852583          	lw	a1,-8(a0)
 78e:	6390                	ld	a2,0(a5)
 790:	02059813          	slli	a6,a1,0x20
 794:	01c85713          	srli	a4,a6,0x1c
 798:	9736                	add	a4,a4,a3
 79a:	fae60de3          	beq	a2,a4,754 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 79e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a2:	4790                	lw	a2,8(a5)
 7a4:	02061593          	slli	a1,a2,0x20
 7a8:	01c5d713          	srli	a4,a1,0x1c
 7ac:	973e                	add	a4,a4,a5
 7ae:	fae68ae3          	beq	a3,a4,762 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b4:	00001717          	auipc	a4,0x1
 7b8:	84f73623          	sd	a5,-1972(a4) # 1000 <freep>
}
 7bc:	6422                	ld	s0,8(sp)
 7be:	0141                	addi	sp,sp,16
 7c0:	8082                	ret

00000000000007c2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c2:	7139                	addi	sp,sp,-64
 7c4:	fc06                	sd	ra,56(sp)
 7c6:	f822                	sd	s0,48(sp)
 7c8:	f426                	sd	s1,40(sp)
 7ca:	f04a                	sd	s2,32(sp)
 7cc:	ec4e                	sd	s3,24(sp)
 7ce:	e852                	sd	s4,16(sp)
 7d0:	e456                	sd	s5,8(sp)
 7d2:	e05a                	sd	s6,0(sp)
 7d4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d6:	02051493          	slli	s1,a0,0x20
 7da:	9081                	srli	s1,s1,0x20
 7dc:	04bd                	addi	s1,s1,15
 7de:	8091                	srli	s1,s1,0x4
 7e0:	0014899b          	addiw	s3,s1,1
 7e4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e6:	00001517          	auipc	a0,0x1
 7ea:	81a53503          	ld	a0,-2022(a0) # 1000 <freep>
 7ee:	c515                	beqz	a0,81a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f2:	4798                	lw	a4,8(a5)
 7f4:	02977f63          	bgeu	a4,s1,832 <malloc+0x70>
 7f8:	8a4e                	mv	s4,s3
 7fa:	0009871b          	sext.w	a4,s3
 7fe:	6685                	lui	a3,0x1
 800:	00d77363          	bgeu	a4,a3,806 <malloc+0x44>
 804:	6a05                	lui	s4,0x1
 806:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80e:	00000917          	auipc	s2,0x0
 812:	7f290913          	addi	s2,s2,2034 # 1000 <freep>
  if(p == (char*)-1)
 816:	5afd                	li	s5,-1
 818:	a895                	j	88c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 81a:	00000797          	auipc	a5,0x0
 81e:	7f678793          	addi	a5,a5,2038 # 1010 <base>
 822:	00000717          	auipc	a4,0x0
 826:	7cf73f23          	sd	a5,2014(a4) # 1000 <freep>
 82a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 82c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 830:	b7e1                	j	7f8 <malloc+0x36>
      if(p->s.size == nunits)
 832:	02e48c63          	beq	s1,a4,86a <malloc+0xa8>
        p->s.size -= nunits;
 836:	4137073b          	subw	a4,a4,s3
 83a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 83c:	02071693          	slli	a3,a4,0x20
 840:	01c6d713          	srli	a4,a3,0x1c
 844:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 846:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84a:	00000717          	auipc	a4,0x0
 84e:	7aa73b23          	sd	a0,1974(a4) # 1000 <freep>
      return (void*)(p + 1);
 852:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 856:	70e2                	ld	ra,56(sp)
 858:	7442                	ld	s0,48(sp)
 85a:	74a2                	ld	s1,40(sp)
 85c:	7902                	ld	s2,32(sp)
 85e:	69e2                	ld	s3,24(sp)
 860:	6a42                	ld	s4,16(sp)
 862:	6aa2                	ld	s5,8(sp)
 864:	6b02                	ld	s6,0(sp)
 866:	6121                	addi	sp,sp,64
 868:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 86a:	6398                	ld	a4,0(a5)
 86c:	e118                	sd	a4,0(a0)
 86e:	bff1                	j	84a <malloc+0x88>
  hp->s.size = nu;
 870:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 874:	0541                	addi	a0,a0,16
 876:	00000097          	auipc	ra,0x0
 87a:	eca080e7          	jalr	-310(ra) # 740 <free>
  return freep;
 87e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 882:	d971                	beqz	a0,856 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 886:	4798                	lw	a4,8(a5)
 888:	fa9775e3          	bgeu	a4,s1,832 <malloc+0x70>
    if(p == freep)
 88c:	00093703          	ld	a4,0(s2)
 890:	853e                	mv	a0,a5
 892:	fef719e3          	bne	a4,a5,884 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 896:	8552                	mv	a0,s4
 898:	00000097          	auipc	ra,0x0
 89c:	b58080e7          	jalr	-1192(ra) # 3f0 <sbrk>
  if(p == (char*)-1)
 8a0:	fd5518e3          	bne	a0,s5,870 <malloc+0xae>
        return 0;
 8a4:	4501                	li	a0,0
 8a6:	bf45                	j	856 <malloc+0x94>
