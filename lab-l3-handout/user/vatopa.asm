
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
   c:	84aa                	mv	s1,a0
   e:	892e                	mv	s2,a1
  uint64 result;

  printf("argv[1]: %s\n", argv[1]); // print argv[1]
  10:	658c                	ld	a1,8(a1)
  12:	00001517          	auipc	a0,0x1
  16:	89e50513          	addi	a0,a0,-1890 # 8b0 <malloc+0xec>
  1a:	00000097          	auipc	ra,0x0
  1e:	6f2080e7          	jalr	1778(ra) # 70c <printf>
    printf("argv[2]: %s\n", argv[2]); //
  22:	01093583          	ld	a1,16(s2)
  26:	00001517          	auipc	a0,0x1
  2a:	89a50513          	addi	a0,a0,-1894 # 8c0 <malloc+0xfc>
  2e:	00000097          	auipc	ra,0x0
  32:	6de080e7          	jalr	1758(ra) # 70c <printf>
    
  if (argc > 3) {
  36:	478d                	li	a5,3
  38:	0297c063          	blt	a5,s1,58 <main+0x58>
    printf("Usage: vatopa [virtual address] [pid]\n");
    exit(1);
  }
  if (argc == 3){
  3c:	478d                	li	a5,3
  3e:	02f48a63          	beq	s1,a5,72 <main+0x72>
    result = va2pa((uint64)&argv[0], (uint64)&argv[1]);
    printf("%d\n", result);
  }
  if (argc == 2) {
  42:	4789                	li	a5,2
  44:	04f48863          	beq	s1,a5,94 <main+0x94>
    result = va2pa((uint64)&argv[0], getpid());
    printf("%d\n", result);
  }
  if (argc == 1) {
  48:	4785                	li	a5,1
  4a:	06f48963          	beq	s1,a5,bc <main+0xbc>
    result = va2pa(0, getpid());
    printf("%d\n", result);
  }
    exit(0);
  4e:	4501                	li	a0,0
  50:	00000097          	auipc	ra,0x0
  54:	31a080e7          	jalr	794(ra) # 36a <exit>
    printf("Usage: vatopa [virtual address] [pid]\n");
  58:	00001517          	auipc	a0,0x1
  5c:	87850513          	addi	a0,a0,-1928 # 8d0 <malloc+0x10c>
  60:	00000097          	auipc	ra,0x0
  64:	6ac080e7          	jalr	1708(ra) # 70c <printf>
    exit(1);
  68:	4505                	li	a0,1
  6a:	00000097          	auipc	ra,0x0
  6e:	300080e7          	jalr	768(ra) # 36a <exit>
    result = va2pa((uint64)&argv[0], (uint64)&argv[1]);
  72:	0089059b          	addiw	a1,s2,8
  76:	854a                	mv	a0,s2
  78:	00000097          	auipc	ra,0x0
  7c:	3aa080e7          	jalr	938(ra) # 422 <va2pa>
  80:	85aa                	mv	a1,a0
    printf("%d\n", result);
  82:	00001517          	auipc	a0,0x1
  86:	87650513          	addi	a0,a0,-1930 # 8f8 <malloc+0x134>
  8a:	00000097          	auipc	ra,0x0
  8e:	682080e7          	jalr	1666(ra) # 70c <printf>
  if (argc == 1) {
  92:	bf75                	j	4e <main+0x4e>
    result = va2pa((uint64)&argv[0], getpid());
  94:	00000097          	auipc	ra,0x0
  98:	356080e7          	jalr	854(ra) # 3ea <getpid>
  9c:	85aa                	mv	a1,a0
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	382080e7          	jalr	898(ra) # 422 <va2pa>
  a8:	85aa                	mv	a1,a0
    printf("%d\n", result);
  aa:	00001517          	auipc	a0,0x1
  ae:	84e50513          	addi	a0,a0,-1970 # 8f8 <malloc+0x134>
  b2:	00000097          	auipc	ra,0x0
  b6:	65a080e7          	jalr	1626(ra) # 70c <printf>
  if (argc == 1) {
  ba:	bf51                	j	4e <main+0x4e>
    result = va2pa(0, getpid());
  bc:	00000097          	auipc	ra,0x0
  c0:	32e080e7          	jalr	814(ra) # 3ea <getpid>
  c4:	85aa                	mv	a1,a0
  c6:	4501                	li	a0,0
  c8:	00000097          	auipc	ra,0x0
  cc:	35a080e7          	jalr	858(ra) # 422 <va2pa>
  d0:	85aa                	mv	a1,a0
    printf("%d\n", result);
  d2:	00001517          	auipc	a0,0x1
  d6:	82650513          	addi	a0,a0,-2010 # 8f8 <malloc+0x134>
  da:	00000097          	auipc	ra,0x0
  de:	632080e7          	jalr	1586(ra) # 70c <printf>
  e2:	b7b5                	j	4e <main+0x4e>

00000000000000e4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <main>
  exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	274080e7          	jalr	628(ra) # 36a <exit>

00000000000000fe <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	87aa                	mv	a5,a0
 106:	0585                	addi	a1,a1,1
 108:	0785                	addi	a5,a5,1
 10a:	fff5c703          	lbu	a4,-1(a1)
 10e:	fee78fa3          	sb	a4,-1(a5)
 112:	fb75                	bnez	a4,106 <strcpy+0x8>
    ;
  return os;
}
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 120:	00054783          	lbu	a5,0(a0)
 124:	cb91                	beqz	a5,138 <strcmp+0x1e>
 126:	0005c703          	lbu	a4,0(a1)
 12a:	00f71763          	bne	a4,a5,138 <strcmp+0x1e>
    p++, q++;
 12e:	0505                	addi	a0,a0,1
 130:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	fbe5                	bnez	a5,126 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 138:	0005c503          	lbu	a0,0(a1)
}
 13c:	40a7853b          	subw	a0,a5,a0
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strlen>:

uint
strlen(const char *s)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cf91                	beqz	a5,16c <strlen+0x26>
 152:	0505                	addi	a0,a0,1
 154:	87aa                	mv	a5,a0
 156:	4685                	li	a3,1
 158:	9e89                	subw	a3,a3,a0
 15a:	00f6853b          	addw	a0,a3,a5
 15e:	0785                	addi	a5,a5,1
 160:	fff7c703          	lbu	a4,-1(a5)
 164:	fb7d                	bnez	a4,15a <strlen+0x14>
    ;
  return n;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret
  for(n = 0; s[n]; n++)
 16c:	4501                	li	a0,0
 16e:	bfe5                	j	166 <strlen+0x20>

0000000000000170 <memset>:

void*
memset(void *dst, int c, uint n)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 176:	ca19                	beqz	a2,18c <memset+0x1c>
 178:	87aa                	mv	a5,a0
 17a:	1602                	slli	a2,a2,0x20
 17c:	9201                	srli	a2,a2,0x20
 17e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 182:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 186:	0785                	addi	a5,a5,1
 188:	fee79de3          	bne	a5,a4,182 <memset+0x12>
  }
  return dst;
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	addi	sp,sp,16
 190:	8082                	ret

0000000000000192 <strchr>:

char*
strchr(const char *s, char c)
{
 192:	1141                	addi	sp,sp,-16
 194:	e422                	sd	s0,8(sp)
 196:	0800                	addi	s0,sp,16
  for(; *s; s++)
 198:	00054783          	lbu	a5,0(a0)
 19c:	cb99                	beqz	a5,1b2 <strchr+0x20>
    if(*s == c)
 19e:	00f58763          	beq	a1,a5,1ac <strchr+0x1a>
  for(; *s; s++)
 1a2:	0505                	addi	a0,a0,1
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	fbfd                	bnez	a5,19e <strchr+0xc>
      return (char*)s;
  return 0;
 1aa:	4501                	li	a0,0
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret
  return 0;
 1b2:	4501                	li	a0,0
 1b4:	bfe5                	j	1ac <strchr+0x1a>

00000000000001b6 <gets>:

char*
gets(char *buf, int max)
{
 1b6:	711d                	addi	sp,sp,-96
 1b8:	ec86                	sd	ra,88(sp)
 1ba:	e8a2                	sd	s0,80(sp)
 1bc:	e4a6                	sd	s1,72(sp)
 1be:	e0ca                	sd	s2,64(sp)
 1c0:	fc4e                	sd	s3,56(sp)
 1c2:	f852                	sd	s4,48(sp)
 1c4:	f456                	sd	s5,40(sp)
 1c6:	f05a                	sd	s6,32(sp)
 1c8:	ec5e                	sd	s7,24(sp)
 1ca:	1080                	addi	s0,sp,96
 1cc:	8baa                	mv	s7,a0
 1ce:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d0:	892a                	mv	s2,a0
 1d2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d4:	4aa9                	li	s5,10
 1d6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d8:	89a6                	mv	s3,s1
 1da:	2485                	addiw	s1,s1,1
 1dc:	0344d863          	bge	s1,s4,20c <gets+0x56>
    cc = read(0, &c, 1);
 1e0:	4605                	li	a2,1
 1e2:	faf40593          	addi	a1,s0,-81
 1e6:	4501                	li	a0,0
 1e8:	00000097          	auipc	ra,0x0
 1ec:	19a080e7          	jalr	410(ra) # 382 <read>
    if(cc < 1)
 1f0:	00a05e63          	blez	a0,20c <gets+0x56>
    buf[i++] = c;
 1f4:	faf44783          	lbu	a5,-81(s0)
 1f8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fc:	01578763          	beq	a5,s5,20a <gets+0x54>
 200:	0905                	addi	s2,s2,1
 202:	fd679be3          	bne	a5,s6,1d8 <gets+0x22>
  for(i=0; i+1 < max; ){
 206:	89a6                	mv	s3,s1
 208:	a011                	j	20c <gets+0x56>
 20a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20c:	99de                	add	s3,s3,s7
 20e:	00098023          	sb	zero,0(s3)
  return buf;
}
 212:	855e                	mv	a0,s7
 214:	60e6                	ld	ra,88(sp)
 216:	6446                	ld	s0,80(sp)
 218:	64a6                	ld	s1,72(sp)
 21a:	6906                	ld	s2,64(sp)
 21c:	79e2                	ld	s3,56(sp)
 21e:	7a42                	ld	s4,48(sp)
 220:	7aa2                	ld	s5,40(sp)
 222:	7b02                	ld	s6,32(sp)
 224:	6be2                	ld	s7,24(sp)
 226:	6125                	addi	sp,sp,96
 228:	8082                	ret

000000000000022a <stat>:

int
stat(const char *n, struct stat *st)
{
 22a:	1101                	addi	sp,sp,-32
 22c:	ec06                	sd	ra,24(sp)
 22e:	e822                	sd	s0,16(sp)
 230:	e426                	sd	s1,8(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	00000097          	auipc	ra,0x0
 23e:	170080e7          	jalr	368(ra) # 3aa <open>
  if(fd < 0)
 242:	02054563          	bltz	a0,26c <stat+0x42>
 246:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 248:	85ca                	mv	a1,s2
 24a:	00000097          	auipc	ra,0x0
 24e:	178080e7          	jalr	376(ra) # 3c2 <fstat>
 252:	892a                	mv	s2,a0
  close(fd);
 254:	8526                	mv	a0,s1
 256:	00000097          	auipc	ra,0x0
 25a:	13c080e7          	jalr	316(ra) # 392 <close>
  return r;
}
 25e:	854a                	mv	a0,s2
 260:	60e2                	ld	ra,24(sp)
 262:	6442                	ld	s0,16(sp)
 264:	64a2                	ld	s1,8(sp)
 266:	6902                	ld	s2,0(sp)
 268:	6105                	addi	sp,sp,32
 26a:	8082                	ret
    return -1;
 26c:	597d                	li	s2,-1
 26e:	bfc5                	j	25e <stat+0x34>

0000000000000270 <atoi>:

int
atoi(const char *s)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 276:	00054683          	lbu	a3,0(a0)
 27a:	fd06879b          	addiw	a5,a3,-48
 27e:	0ff7f793          	zext.b	a5,a5
 282:	4625                	li	a2,9
 284:	02f66863          	bltu	a2,a5,2b4 <atoi+0x44>
 288:	872a                	mv	a4,a0
  n = 0;
 28a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28c:	0705                	addi	a4,a4,1
 28e:	0025179b          	slliw	a5,a0,0x2
 292:	9fa9                	addw	a5,a5,a0
 294:	0017979b          	slliw	a5,a5,0x1
 298:	9fb5                	addw	a5,a5,a3
 29a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29e:	00074683          	lbu	a3,0(a4)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	fef671e3          	bgeu	a2,a5,28c <atoi+0x1c>
  return n;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
  n = 0;
 2b4:	4501                	li	a0,0
 2b6:	bfe5                	j	2ae <atoi+0x3e>

00000000000002b8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2be:	02b57463          	bgeu	a0,a1,2e6 <memmove+0x2e>
    while(n-- > 0)
 2c2:	00c05f63          	blez	a2,2e0 <memmove+0x28>
 2c6:	1602                	slli	a2,a2,0x20
 2c8:	9201                	srli	a2,a2,0x20
 2ca:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ce:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d0:	0585                	addi	a1,a1,1
 2d2:	0705                	addi	a4,a4,1
 2d4:	fff5c683          	lbu	a3,-1(a1)
 2d8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2dc:	fee79ae3          	bne	a5,a4,2d0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
    dst += n;
 2e6:	00c50733          	add	a4,a0,a2
    src += n;
 2ea:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ec:	fec05ae3          	blez	a2,2e0 <memmove+0x28>
 2f0:	fff6079b          	addiw	a5,a2,-1
 2f4:	1782                	slli	a5,a5,0x20
 2f6:	9381                	srli	a5,a5,0x20
 2f8:	fff7c793          	not	a5,a5
 2fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fe:	15fd                	addi	a1,a1,-1
 300:	177d                	addi	a4,a4,-1
 302:	0005c683          	lbu	a3,0(a1)
 306:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30a:	fee79ae3          	bne	a5,a4,2fe <memmove+0x46>
 30e:	bfc9                	j	2e0 <memmove+0x28>

0000000000000310 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 316:	ca05                	beqz	a2,346 <memcmp+0x36>
 318:	fff6069b          	addiw	a3,a2,-1
 31c:	1682                	slli	a3,a3,0x20
 31e:	9281                	srli	a3,a3,0x20
 320:	0685                	addi	a3,a3,1
 322:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 324:	00054783          	lbu	a5,0(a0)
 328:	0005c703          	lbu	a4,0(a1)
 32c:	00e79863          	bne	a5,a4,33c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 330:	0505                	addi	a0,a0,1
    p2++;
 332:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 334:	fed518e3          	bne	a0,a3,324 <memcmp+0x14>
  }
  return 0;
 338:	4501                	li	a0,0
 33a:	a019                	j	340 <memcmp+0x30>
      return *p1 - *p2;
 33c:	40e7853b          	subw	a0,a5,a4
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  return 0;
 346:	4501                	li	a0,0
 348:	bfe5                	j	340 <memcmp+0x30>

000000000000034a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 352:	00000097          	auipc	ra,0x0
 356:	f66080e7          	jalr	-154(ra) # 2b8 <memmove>
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

00000000000003f2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f2:	48b1                	li	a7,12
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
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

000000000000040a <ps>:
.global ps
ps:
 li a7, SYS_ps
 40a:	48d9                	li	a7,22
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 412:	48dd                	li	a7,23
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 41a:	48e1                	li	a7,24
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 422:	48e9                	li	a7,26
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 42a:	48e5                	li	a7,25
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 432:	1101                	addi	sp,sp,-32
 434:	ec06                	sd	ra,24(sp)
 436:	e822                	sd	s0,16(sp)
 438:	1000                	addi	s0,sp,32
 43a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43e:	4605                	li	a2,1
 440:	fef40593          	addi	a1,s0,-17
 444:	00000097          	auipc	ra,0x0
 448:	f46080e7          	jalr	-186(ra) # 38a <write>
}
 44c:	60e2                	ld	ra,24(sp)
 44e:	6442                	ld	s0,16(sp)
 450:	6105                	addi	sp,sp,32
 452:	8082                	ret

0000000000000454 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 454:	7139                	addi	sp,sp,-64
 456:	fc06                	sd	ra,56(sp)
 458:	f822                	sd	s0,48(sp)
 45a:	f426                	sd	s1,40(sp)
 45c:	f04a                	sd	s2,32(sp)
 45e:	ec4e                	sd	s3,24(sp)
 460:	0080                	addi	s0,sp,64
 462:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 464:	c299                	beqz	a3,46a <printint+0x16>
 466:	0805c963          	bltz	a1,4f8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 46a:	2581                	sext.w	a1,a1
  neg = 0;
 46c:	4881                	li	a7,0
 46e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 472:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 474:	2601                	sext.w	a2,a2
 476:	00000517          	auipc	a0,0x0
 47a:	4ea50513          	addi	a0,a0,1258 # 960 <digits>
 47e:	883a                	mv	a6,a4
 480:	2705                	addiw	a4,a4,1
 482:	02c5f7bb          	remuw	a5,a1,a2
 486:	1782                	slli	a5,a5,0x20
 488:	9381                	srli	a5,a5,0x20
 48a:	97aa                	add	a5,a5,a0
 48c:	0007c783          	lbu	a5,0(a5)
 490:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 494:	0005879b          	sext.w	a5,a1
 498:	02c5d5bb          	divuw	a1,a1,a2
 49c:	0685                	addi	a3,a3,1
 49e:	fec7f0e3          	bgeu	a5,a2,47e <printint+0x2a>
  if(neg)
 4a2:	00088c63          	beqz	a7,4ba <printint+0x66>
    buf[i++] = '-';
 4a6:	fd070793          	addi	a5,a4,-48
 4aa:	00878733          	add	a4,a5,s0
 4ae:	02d00793          	li	a5,45
 4b2:	fef70823          	sb	a5,-16(a4)
 4b6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ba:	02e05863          	blez	a4,4ea <printint+0x96>
 4be:	fc040793          	addi	a5,s0,-64
 4c2:	00e78933          	add	s2,a5,a4
 4c6:	fff78993          	addi	s3,a5,-1
 4ca:	99ba                	add	s3,s3,a4
 4cc:	377d                	addiw	a4,a4,-1
 4ce:	1702                	slli	a4,a4,0x20
 4d0:	9301                	srli	a4,a4,0x20
 4d2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4d6:	fff94583          	lbu	a1,-1(s2)
 4da:	8526                	mv	a0,s1
 4dc:	00000097          	auipc	ra,0x0
 4e0:	f56080e7          	jalr	-170(ra) # 432 <putc>
  while(--i >= 0)
 4e4:	197d                	addi	s2,s2,-1
 4e6:	ff3918e3          	bne	s2,s3,4d6 <printint+0x82>
}
 4ea:	70e2                	ld	ra,56(sp)
 4ec:	7442                	ld	s0,48(sp)
 4ee:	74a2                	ld	s1,40(sp)
 4f0:	7902                	ld	s2,32(sp)
 4f2:	69e2                	ld	s3,24(sp)
 4f4:	6121                	addi	sp,sp,64
 4f6:	8082                	ret
    x = -xx;
 4f8:	40b005bb          	negw	a1,a1
    neg = 1;
 4fc:	4885                	li	a7,1
    x = -xx;
 4fe:	bf85                	j	46e <printint+0x1a>

0000000000000500 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 500:	7119                	addi	sp,sp,-128
 502:	fc86                	sd	ra,120(sp)
 504:	f8a2                	sd	s0,112(sp)
 506:	f4a6                	sd	s1,104(sp)
 508:	f0ca                	sd	s2,96(sp)
 50a:	ecce                	sd	s3,88(sp)
 50c:	e8d2                	sd	s4,80(sp)
 50e:	e4d6                	sd	s5,72(sp)
 510:	e0da                	sd	s6,64(sp)
 512:	fc5e                	sd	s7,56(sp)
 514:	f862                	sd	s8,48(sp)
 516:	f466                	sd	s9,40(sp)
 518:	f06a                	sd	s10,32(sp)
 51a:	ec6e                	sd	s11,24(sp)
 51c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51e:	0005c903          	lbu	s2,0(a1)
 522:	18090f63          	beqz	s2,6c0 <vprintf+0x1c0>
 526:	8aaa                	mv	s5,a0
 528:	8b32                	mv	s6,a2
 52a:	00158493          	addi	s1,a1,1
  state = 0;
 52e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 530:	02500a13          	li	s4,37
 534:	4c55                	li	s8,21
 536:	00000c97          	auipc	s9,0x0
 53a:	3d2c8c93          	addi	s9,s9,978 # 908 <malloc+0x144>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 53e:	02800d93          	li	s11,40
  putc(fd, 'x');
 542:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 544:	00000b97          	auipc	s7,0x0
 548:	41cb8b93          	addi	s7,s7,1052 # 960 <digits>
 54c:	a839                	j	56a <vprintf+0x6a>
        putc(fd, c);
 54e:	85ca                	mv	a1,s2
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	ee0080e7          	jalr	-288(ra) # 432 <putc>
 55a:	a019                	j	560 <vprintf+0x60>
    } else if(state == '%'){
 55c:	01498d63          	beq	s3,s4,576 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 560:	0485                	addi	s1,s1,1
 562:	fff4c903          	lbu	s2,-1(s1)
 566:	14090d63          	beqz	s2,6c0 <vprintf+0x1c0>
    if(state == 0){
 56a:	fe0999e3          	bnez	s3,55c <vprintf+0x5c>
      if(c == '%'){
 56e:	ff4910e3          	bne	s2,s4,54e <vprintf+0x4e>
        state = '%';
 572:	89d2                	mv	s3,s4
 574:	b7f5                	j	560 <vprintf+0x60>
      if(c == 'd'){
 576:	11490c63          	beq	s2,s4,68e <vprintf+0x18e>
 57a:	f9d9079b          	addiw	a5,s2,-99
 57e:	0ff7f793          	zext.b	a5,a5
 582:	10fc6e63          	bltu	s8,a5,69e <vprintf+0x19e>
 586:	f9d9079b          	addiw	a5,s2,-99
 58a:	0ff7f713          	zext.b	a4,a5
 58e:	10ec6863          	bltu	s8,a4,69e <vprintf+0x19e>
 592:	00271793          	slli	a5,a4,0x2
 596:	97e6                	add	a5,a5,s9
 598:	439c                	lw	a5,0(a5)
 59a:	97e6                	add	a5,a5,s9
 59c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b0913          	addi	s2,s6,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000b2583          	lw	a1,0(s6)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	ea8080e7          	jalr	-344(ra) # 454 <printint>
 5b4:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b765                	j	560 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ba:	008b0913          	addi	s2,s6,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000b2583          	lw	a1,0(s6)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e8c080e7          	jalr	-372(ra) # 454 <printint>
 5d0:	8b4a                	mv	s6,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b771                	j	560 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5d6:	008b0913          	addi	s2,s6,8
 5da:	4681                	li	a3,0
 5dc:	866a                	mv	a2,s10
 5de:	000b2583          	lw	a1,0(s6)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e70080e7          	jalr	-400(ra) # 454 <printint>
 5ec:	8b4a                	mv	s6,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bf85                	j	560 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5f2:	008b0793          	addi	a5,s6,8
 5f6:	f8f43423          	sd	a5,-120(s0)
 5fa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5fe:	03000593          	li	a1,48
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e2e080e7          	jalr	-466(ra) # 432 <putc>
  putc(fd, 'x');
 60c:	07800593          	li	a1,120
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e20080e7          	jalr	-480(ra) # 432 <putc>
 61a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61c:	03c9d793          	srli	a5,s3,0x3c
 620:	97de                	add	a5,a5,s7
 622:	0007c583          	lbu	a1,0(a5)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e0a080e7          	jalr	-502(ra) # 432 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 630:	0992                	slli	s3,s3,0x4
 632:	397d                	addiw	s2,s2,-1
 634:	fe0914e3          	bnez	s2,61c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 638:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 63c:	4981                	li	s3,0
 63e:	b70d                	j	560 <vprintf+0x60>
        s = va_arg(ap, char*);
 640:	008b0913          	addi	s2,s6,8
 644:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 648:	02098163          	beqz	s3,66a <vprintf+0x16a>
        while(*s != 0){
 64c:	0009c583          	lbu	a1,0(s3)
 650:	c5ad                	beqz	a1,6ba <vprintf+0x1ba>
          putc(fd, *s);
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	dde080e7          	jalr	-546(ra) # 432 <putc>
          s++;
 65c:	0985                	addi	s3,s3,1
        while(*s != 0){
 65e:	0009c583          	lbu	a1,0(s3)
 662:	f9e5                	bnez	a1,652 <vprintf+0x152>
        s = va_arg(ap, char*);
 664:	8b4a                	mv	s6,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bde5                	j	560 <vprintf+0x60>
          s = "(null)";
 66a:	00000997          	auipc	s3,0x0
 66e:	29698993          	addi	s3,s3,662 # 900 <malloc+0x13c>
        while(*s != 0){
 672:	85ee                	mv	a1,s11
 674:	bff9                	j	652 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 676:	008b0913          	addi	s2,s6,8
 67a:	000b4583          	lbu	a1,0(s6)
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	db2080e7          	jalr	-590(ra) # 432 <putc>
 688:	8b4a                	mv	s6,s2
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bdd1                	j	560 <vprintf+0x60>
        putc(fd, c);
 68e:	85d2                	mv	a1,s4
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	da0080e7          	jalr	-608(ra) # 432 <putc>
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b5d1                	j	560 <vprintf+0x60>
        putc(fd, '%');
 69e:	85d2                	mv	a1,s4
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	d90080e7          	jalr	-624(ra) # 432 <putc>
        putc(fd, c);
 6aa:	85ca                	mv	a1,s2
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	d84080e7          	jalr	-636(ra) # 432 <putc>
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b565                	j	560 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ba:	8b4a                	mv	s6,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b54d                	j	560 <vprintf+0x60>
    }
  }
}
 6c0:	70e6                	ld	ra,120(sp)
 6c2:	7446                	ld	s0,112(sp)
 6c4:	74a6                	ld	s1,104(sp)
 6c6:	7906                	ld	s2,96(sp)
 6c8:	69e6                	ld	s3,88(sp)
 6ca:	6a46                	ld	s4,80(sp)
 6cc:	6aa6                	ld	s5,72(sp)
 6ce:	6b06                	ld	s6,64(sp)
 6d0:	7be2                	ld	s7,56(sp)
 6d2:	7c42                	ld	s8,48(sp)
 6d4:	7ca2                	ld	s9,40(sp)
 6d6:	7d02                	ld	s10,32(sp)
 6d8:	6de2                	ld	s11,24(sp)
 6da:	6109                	addi	sp,sp,128
 6dc:	8082                	ret

00000000000006de <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6de:	715d                	addi	sp,sp,-80
 6e0:	ec06                	sd	ra,24(sp)
 6e2:	e822                	sd	s0,16(sp)
 6e4:	1000                	addi	s0,sp,32
 6e6:	e010                	sd	a2,0(s0)
 6e8:	e414                	sd	a3,8(s0)
 6ea:	e818                	sd	a4,16(s0)
 6ec:	ec1c                	sd	a5,24(s0)
 6ee:	03043023          	sd	a6,32(s0)
 6f2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fa:	8622                	mv	a2,s0
 6fc:	00000097          	auipc	ra,0x0
 700:	e04080e7          	jalr	-508(ra) # 500 <vprintf>
}
 704:	60e2                	ld	ra,24(sp)
 706:	6442                	ld	s0,16(sp)
 708:	6161                	addi	sp,sp,80
 70a:	8082                	ret

000000000000070c <printf>:

void
printf(const char *fmt, ...)
{
 70c:	711d                	addi	sp,sp,-96
 70e:	ec06                	sd	ra,24(sp)
 710:	e822                	sd	s0,16(sp)
 712:	1000                	addi	s0,sp,32
 714:	e40c                	sd	a1,8(s0)
 716:	e810                	sd	a2,16(s0)
 718:	ec14                	sd	a3,24(s0)
 71a:	f018                	sd	a4,32(s0)
 71c:	f41c                	sd	a5,40(s0)
 71e:	03043823          	sd	a6,48(s0)
 722:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 726:	00840613          	addi	a2,s0,8
 72a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 72e:	85aa                	mv	a1,a0
 730:	4505                	li	a0,1
 732:	00000097          	auipc	ra,0x0
 736:	dce080e7          	jalr	-562(ra) # 500 <vprintf>
}
 73a:	60e2                	ld	ra,24(sp)
 73c:	6442                	ld	s0,16(sp)
 73e:	6125                	addi	sp,sp,96
 740:	8082                	ret

0000000000000742 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 742:	1141                	addi	sp,sp,-16
 744:	e422                	sd	s0,8(sp)
 746:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 748:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74c:	00001797          	auipc	a5,0x1
 750:	8b47b783          	ld	a5,-1868(a5) # 1000 <freep>
 754:	a02d                	j	77e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 756:	4618                	lw	a4,8(a2)
 758:	9f2d                	addw	a4,a4,a1
 75a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 75e:	6398                	ld	a4,0(a5)
 760:	6310                	ld	a2,0(a4)
 762:	a83d                	j	7a0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 764:	ff852703          	lw	a4,-8(a0)
 768:	9f31                	addw	a4,a4,a2
 76a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 76c:	ff053683          	ld	a3,-16(a0)
 770:	a091                	j	7b4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	6398                	ld	a4,0(a5)
 774:	00e7e463          	bltu	a5,a4,77c <free+0x3a>
 778:	00e6ea63          	bltu	a3,a4,78c <free+0x4a>
{
 77c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	fed7fae3          	bgeu	a5,a3,772 <free+0x30>
 782:	6398                	ld	a4,0(a5)
 784:	00e6e463          	bltu	a3,a4,78c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 788:	fee7eae3          	bltu	a5,a4,77c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 78c:	ff852583          	lw	a1,-8(a0)
 790:	6390                	ld	a2,0(a5)
 792:	02059813          	slli	a6,a1,0x20
 796:	01c85713          	srli	a4,a6,0x1c
 79a:	9736                	add	a4,a4,a3
 79c:	fae60de3          	beq	a2,a4,756 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a4:	4790                	lw	a2,8(a5)
 7a6:	02061593          	slli	a1,a2,0x20
 7aa:	01c5d713          	srli	a4,a1,0x1c
 7ae:	973e                	add	a4,a4,a5
 7b0:	fae68ae3          	beq	a3,a4,764 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b6:	00001717          	auipc	a4,0x1
 7ba:	84f73523          	sd	a5,-1974(a4) # 1000 <freep>
}
 7be:	6422                	ld	s0,8(sp)
 7c0:	0141                	addi	sp,sp,16
 7c2:	8082                	ret

00000000000007c4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c4:	7139                	addi	sp,sp,-64
 7c6:	fc06                	sd	ra,56(sp)
 7c8:	f822                	sd	s0,48(sp)
 7ca:	f426                	sd	s1,40(sp)
 7cc:	f04a                	sd	s2,32(sp)
 7ce:	ec4e                	sd	s3,24(sp)
 7d0:	e852                	sd	s4,16(sp)
 7d2:	e456                	sd	s5,8(sp)
 7d4:	e05a                	sd	s6,0(sp)
 7d6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d8:	02051493          	slli	s1,a0,0x20
 7dc:	9081                	srli	s1,s1,0x20
 7de:	04bd                	addi	s1,s1,15
 7e0:	8091                	srli	s1,s1,0x4
 7e2:	0014899b          	addiw	s3,s1,1
 7e6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e8:	00001517          	auipc	a0,0x1
 7ec:	81853503          	ld	a0,-2024(a0) # 1000 <freep>
 7f0:	c515                	beqz	a0,81c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f4:	4798                	lw	a4,8(a5)
 7f6:	02977f63          	bgeu	a4,s1,834 <malloc+0x70>
 7fa:	8a4e                	mv	s4,s3
 7fc:	0009871b          	sext.w	a4,s3
 800:	6685                	lui	a3,0x1
 802:	00d77363          	bgeu	a4,a3,808 <malloc+0x44>
 806:	6a05                	lui	s4,0x1
 808:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 810:	00000917          	auipc	s2,0x0
 814:	7f090913          	addi	s2,s2,2032 # 1000 <freep>
  if(p == (char*)-1)
 818:	5afd                	li	s5,-1
 81a:	a895                	j	88e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 81c:	00000797          	auipc	a5,0x0
 820:	7f478793          	addi	a5,a5,2036 # 1010 <base>
 824:	00000717          	auipc	a4,0x0
 828:	7cf73e23          	sd	a5,2012(a4) # 1000 <freep>
 82c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 82e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 832:	b7e1                	j	7fa <malloc+0x36>
      if(p->s.size == nunits)
 834:	02e48c63          	beq	s1,a4,86c <malloc+0xa8>
        p->s.size -= nunits;
 838:	4137073b          	subw	a4,a4,s3
 83c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 83e:	02071693          	slli	a3,a4,0x20
 842:	01c6d713          	srli	a4,a3,0x1c
 846:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 848:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84c:	00000717          	auipc	a4,0x0
 850:	7aa73a23          	sd	a0,1972(a4) # 1000 <freep>
      return (void*)(p + 1);
 854:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 858:	70e2                	ld	ra,56(sp)
 85a:	7442                	ld	s0,48(sp)
 85c:	74a2                	ld	s1,40(sp)
 85e:	7902                	ld	s2,32(sp)
 860:	69e2                	ld	s3,24(sp)
 862:	6a42                	ld	s4,16(sp)
 864:	6aa2                	ld	s5,8(sp)
 866:	6b02                	ld	s6,0(sp)
 868:	6121                	addi	sp,sp,64
 86a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 86c:	6398                	ld	a4,0(a5)
 86e:	e118                	sd	a4,0(a0)
 870:	bff1                	j	84c <malloc+0x88>
  hp->s.size = nu;
 872:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 876:	0541                	addi	a0,a0,16
 878:	00000097          	auipc	ra,0x0
 87c:	eca080e7          	jalr	-310(ra) # 742 <free>
  return freep;
 880:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 884:	d971                	beqz	a0,858 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 886:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 888:	4798                	lw	a4,8(a5)
 88a:	fa9775e3          	bgeu	a4,s1,834 <malloc+0x70>
    if(p == freep)
 88e:	00093703          	ld	a4,0(s2)
 892:	853e                	mv	a0,a5
 894:	fef719e3          	bne	a4,a5,886 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 898:	8552                	mv	a0,s4
 89a:	00000097          	auipc	ra,0x0
 89e:	b58080e7          	jalr	-1192(ra) # 3f2 <sbrk>
  if(p == (char*)-1)
 8a2:	fd5518e3          	bne	a0,s5,872 <malloc+0xae>
        return 0;
 8a6:	4501                	li	a0,0
 8a8:	bf45                	j	858 <malloc+0x94>
