
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testcase5>:

int global_array[16777216] = {0};
int global_var = 0;

void testcase5()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
    int pid[3];

    printf("\n----- Test case 5 -----\n");
   c:	00001517          	auipc	a0,0x1
  10:	e2450513          	addi	a0,a0,-476 # e30 <malloc+0xf0>
  14:	00001097          	auipc	ra,0x1
  18:	c74080e7          	jalr	-908(ra) # c88 <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	e3450513          	addi	a0,a0,-460 # e50 <malloc+0x110>
  24:	00001097          	auipc	ra,0x1
  28:	c64080e7          	jalr	-924(ra) # c88 <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	97a080e7          	jalr	-1670(ra) # 9a6 <pfreepages>

    for (int i = 0; i < 3; ++i)
  34:	fd040493          	addi	s1,s0,-48
  38:	fdc40913          	addi	s2,s0,-36
    {
        if ((pid[i] = fork()) == 0)
  3c:	00001097          	auipc	ra,0x1
  40:	8a2080e7          	jalr	-1886(ra) # 8de <fork>
  44:	c088                	sw	a0,0(s1)
  46:	c531                	beqz	a0,92 <testcase5+0x92>
            // PARENT
            break;
        }
    }

    sleep(100);
  48:	06400513          	li	a0,100
  4c:	00001097          	auipc	ra,0x1
  50:	92a080e7          	jalr	-1750(ra) # 976 <sleep>
  54:	448d                	li	s1,3

    for (int i = 0; i < 3; ++i)
    {
        int _pid = wait(0);
  56:	4501                	li	a0,0
  58:	00001097          	auipc	ra,0x1
  5c:	896080e7          	jalr	-1898(ra) # 8ee <wait>
        for (int j = 0; j < 3; ++j)
        {
            if (pid[j] == _pid)
  60:	fd042783          	lw	a5,-48(s0)
  64:	02a78b63          	beq	a5,a0,9a <testcase5+0x9a>
  68:	fd442783          	lw	a5,-44(s0)
  6c:	02a78763          	beq	a5,a0,9a <testcase5+0x9a>
  70:	fd842783          	lw	a5,-40(s0)
  74:	02a78363          	beq	a5,a0,9a <testcase5+0x9a>
            {
                break;
            }
            if (j == 2)
            {
                printf("wait() error!");
  78:	00001517          	auipc	a0,0x1
  7c:	de850513          	addi	a0,a0,-536 # e60 <malloc+0x120>
  80:	00001097          	auipc	ra,0x1
  84:	c08080e7          	jalr	-1016(ra) # c88 <printf>
                exit(1);
  88:	4505                	li	a0,1
  8a:	00001097          	auipc	ra,0x1
  8e:	85c080e7          	jalr	-1956(ra) # 8e6 <exit>
    for (int i = 0; i < 3; ++i)
  92:	0491                	addi	s1,s1,4
  94:	fb2494e3          	bne	s1,s2,3c <testcase5+0x3c>
  98:	bf45                	j	48 <testcase5+0x48>
    for (int i = 0; i < 3; ++i)
  9a:	34fd                	addiw	s1,s1,-1
  9c:	fccd                	bnez	s1,56 <testcase5+0x56>
            }
        }
    }

    printf("[prnt] v7 --> ");
  9e:	00001517          	auipc	a0,0x1
  a2:	dd250513          	addi	a0,a0,-558 # e70 <malloc+0x130>
  a6:	00001097          	auipc	ra,0x1
  aa:	be2080e7          	jalr	-1054(ra) # c88 <printf>
    print_free_frame_cnt();
  ae:	00001097          	auipc	ra,0x1
  b2:	8f8080e7          	jalr	-1800(ra) # 9a6 <pfreepages>
}
  b6:	70a2                	ld	ra,40(sp)
  b8:	7402                	ld	s0,32(sp)
  ba:	64e2                	ld	s1,24(sp)
  bc:	6942                	ld	s2,16(sp)
  be:	6145                	addi	sp,sp,48
  c0:	8082                	ret

00000000000000c2 <testcase4>:

void testcase4()
{
  c2:	1101                	addi	sp,sp,-32
  c4:	ec06                	sd	ra,24(sp)
  c6:	e822                	sd	s0,16(sp)
  c8:	e426                	sd	s1,8(sp)
  ca:	e04a                	sd	s2,0(sp)
  cc:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	db250513          	addi	a0,a0,-590 # e80 <malloc+0x140>
  d6:	00001097          	auipc	ra,0x1
  da:	bb2080e7          	jalr	-1102(ra) # c88 <printf>
    printf("[prnt] v1 --> ");
  de:	00001517          	auipc	a0,0x1
  e2:	d7250513          	addi	a0,a0,-654 # e50 <malloc+0x110>
  e6:	00001097          	auipc	ra,0x1
  ea:	ba2080e7          	jalr	-1118(ra) # c88 <printf>
    print_free_frame_cnt();
  ee:	00001097          	auipc	ra,0x1
  f2:	8b8080e7          	jalr	-1864(ra) # 9a6 <pfreepages>

    if ((pid = fork()) == 0)
  f6:	00000097          	auipc	ra,0x0
  fa:	7e8080e7          	jalr	2024(ra) # 8de <fork>
  fe:	c161                	beqz	a0,1be <testcase4+0xfc>
 100:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 102:	00001517          	auipc	a0,0x1
 106:	eae50513          	addi	a0,a0,-338 # fb0 <malloc+0x270>
 10a:	00001097          	auipc	ra,0x1
 10e:	b7e080e7          	jalr	-1154(ra) # c88 <printf>
        print_free_frame_cnt();
 112:	00001097          	auipc	ra,0x1
 116:	894080e7          	jalr	-1900(ra) # 9a6 <pfreepages>

        global_array[0] = 111;
 11a:	00002917          	auipc	s2,0x2
 11e:	ef690913          	addi	s2,s2,-266 # 2010 <global_array>
 122:	06f00793          	li	a5,111
 126:	00f92023          	sw	a5,0(s2)
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 12a:	06f00593          	li	a1,111
 12e:	00001517          	auipc	a0,0x1
 132:	e9250513          	addi	a0,a0,-366 # fc0 <malloc+0x280>
 136:	00001097          	auipc	ra,0x1
 13a:	b52080e7          	jalr	-1198(ra) # c88 <printf>

        printf("[prnt] v3 --> ");
 13e:	00001517          	auipc	a0,0x1
 142:	eca50513          	addi	a0,a0,-310 # 1008 <malloc+0x2c8>
 146:	00001097          	auipc	ra,0x1
 14a:	b42080e7          	jalr	-1214(ra) # c88 <printf>
        print_free_frame_cnt();
 14e:	00001097          	auipc	ra,0x1
 152:	858080e7          	jalr	-1960(ra) # 9a6 <pfreepages>
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 156:	4581                	li	a1,0
 158:	854a                	mv	a0,s2
 15a:	00001097          	auipc	ra,0x1
 15e:	844080e7          	jalr	-1980(ra) # 99e <va2pa>
 162:	85aa                	mv	a1,a0
 164:	00001517          	auipc	a0,0x1
 168:	eb450513          	addi	a0,a0,-332 # 1018 <malloc+0x2d8>
 16c:	00001097          	auipc	ra,0x1
 170:	b1c080e7          	jalr	-1252(ra) # c88 <printf>
    }

    if (wait(0) != pid)
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	778080e7          	jalr	1912(ra) # 8ee <wait>
 17e:	12951763          	bne	a0,s1,2ac <testcase4+0x1ea>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] global_array[0] --> %d\n", global_array[0]);
 182:	00002597          	auipc	a1,0x2
 186:	e8e5a583          	lw	a1,-370(a1) # 2010 <global_array>
 18a:	00001517          	auipc	a0,0x1
 18e:	ea650513          	addi	a0,a0,-346 # 1030 <malloc+0x2f0>
 192:	00001097          	auipc	ra,0x1
 196:	af6080e7          	jalr	-1290(ra) # c88 <printf>

    printf("[prnt] v7 --> ");
 19a:	00001517          	auipc	a0,0x1
 19e:	cd650513          	addi	a0,a0,-810 # e70 <malloc+0x130>
 1a2:	00001097          	auipc	ra,0x1
 1a6:	ae6080e7          	jalr	-1306(ra) # c88 <printf>
    print_free_frame_cnt();
 1aa:	00000097          	auipc	ra,0x0
 1ae:	7fc080e7          	jalr	2044(ra) # 9a6 <pfreepages>
}
 1b2:	60e2                	ld	ra,24(sp)
 1b4:	6442                	ld	s0,16(sp)
 1b6:	64a2                	ld	s1,8(sp)
 1b8:	6902                	ld	s2,0(sp)
 1ba:	6105                	addi	sp,sp,32
 1bc:	8082                	ret
        sleep(50);
 1be:	03200513          	li	a0,50
 1c2:	00000097          	auipc	ra,0x0
 1c6:	7b4080e7          	jalr	1972(ra) # 976 <sleep>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 1ca:	00002497          	auipc	s1,0x2
 1ce:	e4648493          	addi	s1,s1,-442 # 2010 <global_array>
 1d2:	4581                	li	a1,0
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	7c8080e7          	jalr	1992(ra) # 99e <va2pa>
 1de:	85aa                	mv	a1,a0
 1e0:	00001517          	auipc	a0,0x1
 1e4:	cc050513          	addi	a0,a0,-832 # ea0 <malloc+0x160>
 1e8:	00001097          	auipc	ra,0x1
 1ec:	aa0080e7          	jalr	-1376(ra) # c88 <printf>
        printf("[chld] v4 --> ");
 1f0:	00001517          	auipc	a0,0x1
 1f4:	cc850513          	addi	a0,a0,-824 # eb8 <malloc+0x178>
 1f8:	00001097          	auipc	ra,0x1
 1fc:	a90080e7          	jalr	-1392(ra) # c88 <printf>
        print_free_frame_cnt();
 200:	00000097          	auipc	ra,0x0
 204:	7a6080e7          	jalr	1958(ra) # 9a6 <pfreepages>
        global_array[0] = 222;
 208:	0de00793          	li	a5,222
 20c:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 20e:	0de00593          	li	a1,222
 212:	00001517          	auipc	a0,0x1
 216:	cb650513          	addi	a0,a0,-842 # ec8 <malloc+0x188>
 21a:	00001097          	auipc	ra,0x1
 21e:	a6e080e7          	jalr	-1426(ra) # c88 <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 222:	4581                	li	a1,0
 224:	8526                	mv	a0,s1
 226:	00000097          	auipc	ra,0x0
 22a:	778080e7          	jalr	1912(ra) # 99e <va2pa>
 22e:	85aa                	mv	a1,a0
 230:	00001517          	auipc	a0,0x1
 234:	ce050513          	addi	a0,a0,-800 # f10 <malloc+0x1d0>
 238:	00001097          	auipc	ra,0x1
 23c:	a50080e7          	jalr	-1456(ra) # c88 <printf>
        printf("[chld] v5 --> ");
 240:	00001517          	auipc	a0,0x1
 244:	ce850513          	addi	a0,a0,-792 # f28 <malloc+0x1e8>
 248:	00001097          	auipc	ra,0x1
 24c:	a40080e7          	jalr	-1472(ra) # c88 <printf>
        print_free_frame_cnt();
 250:	00000097          	auipc	ra,0x0
 254:	756080e7          	jalr	1878(ra) # 9a6 <pfreepages>
        global_array[2047] = 333;
 258:	14d00793          	li	a5,333
 25c:	00004717          	auipc	a4,0x4
 260:	daf72823          	sw	a5,-592(a4) # 400c <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 264:	14d00593          	li	a1,333
 268:	00001517          	auipc	a0,0x1
 26c:	cd050513          	addi	a0,a0,-816 # f38 <malloc+0x1f8>
 270:	00001097          	auipc	ra,0x1
 274:	a18080e7          	jalr	-1512(ra) # c88 <printf>
        printf("[chld] v6 --> ");
 278:	00001517          	auipc	a0,0x1
 27c:	d0850513          	addi	a0,a0,-760 # f80 <malloc+0x240>
 280:	00001097          	auipc	ra,0x1
 284:	a08080e7          	jalr	-1528(ra) # c88 <printf>
        print_free_frame_cnt();
 288:	00000097          	auipc	ra,0x0
 28c:	71e080e7          	jalr	1822(ra) # 9a6 <pfreepages>
        printf("[chld] global_array[0] --> %d\n", global_array[0]);
 290:	408c                	lw	a1,0(s1)
 292:	00001517          	auipc	a0,0x1
 296:	cfe50513          	addi	a0,a0,-770 # f90 <malloc+0x250>
 29a:	00001097          	auipc	ra,0x1
 29e:	9ee080e7          	jalr	-1554(ra) # c88 <printf>
        exit(0);
 2a2:	4501                	li	a0,0
 2a4:	00000097          	auipc	ra,0x0
 2a8:	642080e7          	jalr	1602(ra) # 8e6 <exit>
        printf("wait() error!");
 2ac:	00001517          	auipc	a0,0x1
 2b0:	bb450513          	addi	a0,a0,-1100 # e60 <malloc+0x120>
 2b4:	00001097          	auipc	ra,0x1
 2b8:	9d4080e7          	jalr	-1580(ra) # c88 <printf>
        exit(1);
 2bc:	4505                	li	a0,1
 2be:	00000097          	auipc	ra,0x0
 2c2:	628080e7          	jalr	1576(ra) # 8e6 <exit>

00000000000002c6 <testcase3>:

void testcase3()
{
 2c6:	1101                	addi	sp,sp,-32
 2c8:	ec06                	sd	ra,24(sp)
 2ca:	e822                	sd	s0,16(sp)
 2cc:	e426                	sd	s1,8(sp)
 2ce:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 2d0:	00001517          	auipc	a0,0x1
 2d4:	d8050513          	addi	a0,a0,-640 # 1050 <malloc+0x310>
 2d8:	00001097          	auipc	ra,0x1
 2dc:	9b0080e7          	jalr	-1616(ra) # c88 <printf>
    printf("[prnt] v1 --> ");
 2e0:	00001517          	auipc	a0,0x1
 2e4:	b7050513          	addi	a0,a0,-1168 # e50 <malloc+0x110>
 2e8:	00001097          	auipc	ra,0x1
 2ec:	9a0080e7          	jalr	-1632(ra) # c88 <printf>
    print_free_frame_cnt();
 2f0:	00000097          	auipc	ra,0x0
 2f4:	6b6080e7          	jalr	1718(ra) # 9a6 <pfreepages>

    if ((pid = fork()) == 0)
 2f8:	00000097          	auipc	ra,0x0
 2fc:	5e6080e7          	jalr	1510(ra) # 8de <fork>
 300:	cd35                	beqz	a0,37c <testcase3+0xb6>
 302:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 304:	00001517          	auipc	a0,0x1
 308:	cac50513          	addi	a0,a0,-852 # fb0 <malloc+0x270>
 30c:	00001097          	auipc	ra,0x1
 310:	97c080e7          	jalr	-1668(ra) # c88 <printf>
        print_free_frame_cnt();
 314:	00000097          	auipc	ra,0x0
 318:	692080e7          	jalr	1682(ra) # 9a6 <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 31c:	00002597          	auipc	a1,0x2
 320:	ce45a583          	lw	a1,-796(a1) # 2000 <global_var>
 324:	00001517          	auipc	a0,0x1
 328:	d7c50513          	addi	a0,a0,-644 # 10a0 <malloc+0x360>
 32c:	00001097          	auipc	ra,0x1
 330:	95c080e7          	jalr	-1700(ra) # c88 <printf>

        printf("[prnt] v3 --> ");
 334:	00001517          	auipc	a0,0x1
 338:	cd450513          	addi	a0,a0,-812 # 1008 <malloc+0x2c8>
 33c:	00001097          	auipc	ra,0x1
 340:	94c080e7          	jalr	-1716(ra) # c88 <printf>
        print_free_frame_cnt();
 344:	00000097          	auipc	ra,0x0
 348:	662080e7          	jalr	1634(ra) # 9a6 <pfreepages>
    }

    if (wait(0) != pid)
 34c:	4501                	li	a0,0
 34e:	00000097          	auipc	ra,0x0
 352:	5a0080e7          	jalr	1440(ra) # 8ee <wait>
 356:	08951663          	bne	a0,s1,3e2 <testcase3+0x11c>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 35a:	00001517          	auipc	a0,0x1
 35e:	d6e50513          	addi	a0,a0,-658 # 10c8 <malloc+0x388>
 362:	00001097          	auipc	ra,0x1
 366:	926080e7          	jalr	-1754(ra) # c88 <printf>
    print_free_frame_cnt();
 36a:	00000097          	auipc	ra,0x0
 36e:	63c080e7          	jalr	1596(ra) # 9a6 <pfreepages>
}
 372:	60e2                	ld	ra,24(sp)
 374:	6442                	ld	s0,16(sp)
 376:	64a2                	ld	s1,8(sp)
 378:	6105                	addi	sp,sp,32
 37a:	8082                	ret
        sleep(50);
 37c:	03200513          	li	a0,50
 380:	00000097          	auipc	ra,0x0
 384:	5f6080e7          	jalr	1526(ra) # 976 <sleep>
        printf("[chld] v4 --> ");
 388:	00001517          	auipc	a0,0x1
 38c:	b3050513          	addi	a0,a0,-1232 # eb8 <malloc+0x178>
 390:	00001097          	auipc	ra,0x1
 394:	8f8080e7          	jalr	-1800(ra) # c88 <printf>
        print_free_frame_cnt();
 398:	00000097          	auipc	ra,0x0
 39c:	60e080e7          	jalr	1550(ra) # 9a6 <pfreepages>
        global_var = 100;
 3a0:	06400793          	li	a5,100
 3a4:	00002717          	auipc	a4,0x2
 3a8:	c4f72e23          	sw	a5,-932(a4) # 2000 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 3ac:	06400593          	li	a1,100
 3b0:	00001517          	auipc	a0,0x1
 3b4:	cc050513          	addi	a0,a0,-832 # 1070 <malloc+0x330>
 3b8:	00001097          	auipc	ra,0x1
 3bc:	8d0080e7          	jalr	-1840(ra) # c88 <printf>
        printf("[chld] v5 --> ");
 3c0:	00001517          	auipc	a0,0x1
 3c4:	b6850513          	addi	a0,a0,-1176 # f28 <malloc+0x1e8>
 3c8:	00001097          	auipc	ra,0x1
 3cc:	8c0080e7          	jalr	-1856(ra) # c88 <printf>
        print_free_frame_cnt();
 3d0:	00000097          	auipc	ra,0x0
 3d4:	5d6080e7          	jalr	1494(ra) # 9a6 <pfreepages>
        exit(0);
 3d8:	4501                	li	a0,0
 3da:	00000097          	auipc	ra,0x0
 3de:	50c080e7          	jalr	1292(ra) # 8e6 <exit>
        printf("wait() error!");
 3e2:	00001517          	auipc	a0,0x1
 3e6:	a7e50513          	addi	a0,a0,-1410 # e60 <malloc+0x120>
 3ea:	00001097          	auipc	ra,0x1
 3ee:	89e080e7          	jalr	-1890(ra) # c88 <printf>
        exit(1);
 3f2:	4505                	li	a0,1
 3f4:	00000097          	auipc	ra,0x0
 3f8:	4f2080e7          	jalr	1266(ra) # 8e6 <exit>

00000000000003fc <testcase2>:

void testcase2()
{
 3fc:	1101                	addi	sp,sp,-32
 3fe:	ec06                	sd	ra,24(sp)
 400:	e822                	sd	s0,16(sp)
 402:	e426                	sd	s1,8(sp)
 404:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 406:	00001517          	auipc	a0,0x1
 40a:	cd250513          	addi	a0,a0,-814 # 10d8 <malloc+0x398>
 40e:	00001097          	auipc	ra,0x1
 412:	87a080e7          	jalr	-1926(ra) # c88 <printf>
    printf("[prnt] v1 --> ");
 416:	00001517          	auipc	a0,0x1
 41a:	a3a50513          	addi	a0,a0,-1478 # e50 <malloc+0x110>
 41e:	00001097          	auipc	ra,0x1
 422:	86a080e7          	jalr	-1942(ra) # c88 <printf>
    print_free_frame_cnt();
 426:	00000097          	auipc	ra,0x0
 42a:	580080e7          	jalr	1408(ra) # 9a6 <pfreepages>

    if ((pid = fork()) == 0)
 42e:	00000097          	auipc	ra,0x0
 432:	4b0080e7          	jalr	1200(ra) # 8de <fork>
 436:	c531                	beqz	a0,482 <testcase2+0x86>
 438:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 43a:	00001517          	auipc	a0,0x1
 43e:	b7650513          	addi	a0,a0,-1162 # fb0 <malloc+0x270>
 442:	00001097          	auipc	ra,0x1
 446:	846080e7          	jalr	-1978(ra) # c88 <printf>
        print_free_frame_cnt();
 44a:	00000097          	auipc	ra,0x0
 44e:	55c080e7          	jalr	1372(ra) # 9a6 <pfreepages>
    }

    if (wait(0) != pid)
 452:	4501                	li	a0,0
 454:	00000097          	auipc	ra,0x0
 458:	49a080e7          	jalr	1178(ra) # 8ee <wait>
 45c:	08951263          	bne	a0,s1,4e0 <testcase2+0xe4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 460:	00001517          	auipc	a0,0x1
 464:	cd050513          	addi	a0,a0,-816 # 1130 <malloc+0x3f0>
 468:	00001097          	auipc	ra,0x1
 46c:	820080e7          	jalr	-2016(ra) # c88 <printf>
    print_free_frame_cnt();
 470:	00000097          	auipc	ra,0x0
 474:	536080e7          	jalr	1334(ra) # 9a6 <pfreepages>
}
 478:	60e2                	ld	ra,24(sp)
 47a:	6442                	ld	s0,16(sp)
 47c:	64a2                	ld	s1,8(sp)
 47e:	6105                	addi	sp,sp,32
 480:	8082                	ret
        sleep(50);
 482:	03200513          	li	a0,50
 486:	00000097          	auipc	ra,0x0
 48a:	4f0080e7          	jalr	1264(ra) # 976 <sleep>
        printf("[chld] v3 --> ");
 48e:	00001517          	auipc	a0,0x1
 492:	c6a50513          	addi	a0,a0,-918 # 10f8 <malloc+0x3b8>
 496:	00000097          	auipc	ra,0x0
 49a:	7f2080e7          	jalr	2034(ra) # c88 <printf>
        print_free_frame_cnt();
 49e:	00000097          	auipc	ra,0x0
 4a2:	508080e7          	jalr	1288(ra) # 9a6 <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 4a6:	00002597          	auipc	a1,0x2
 4aa:	b5a5a583          	lw	a1,-1190(a1) # 2000 <global_var>
 4ae:	00001517          	auipc	a0,0x1
 4b2:	c5a50513          	addi	a0,a0,-934 # 1108 <malloc+0x3c8>
 4b6:	00000097          	auipc	ra,0x0
 4ba:	7d2080e7          	jalr	2002(ra) # c88 <printf>
        printf("[chld] v4 --> ");
 4be:	00001517          	auipc	a0,0x1
 4c2:	9fa50513          	addi	a0,a0,-1542 # eb8 <malloc+0x178>
 4c6:	00000097          	auipc	ra,0x0
 4ca:	7c2080e7          	jalr	1986(ra) # c88 <printf>
        print_free_frame_cnt();
 4ce:	00000097          	auipc	ra,0x0
 4d2:	4d8080e7          	jalr	1240(ra) # 9a6 <pfreepages>
        exit(0);
 4d6:	4501                	li	a0,0
 4d8:	00000097          	auipc	ra,0x0
 4dc:	40e080e7          	jalr	1038(ra) # 8e6 <exit>
        printf("wait() error!");
 4e0:	00001517          	auipc	a0,0x1
 4e4:	98050513          	addi	a0,a0,-1664 # e60 <malloc+0x120>
 4e8:	00000097          	auipc	ra,0x0
 4ec:	7a0080e7          	jalr	1952(ra) # c88 <printf>
        exit(1);
 4f0:	4505                	li	a0,1
 4f2:	00000097          	auipc	ra,0x0
 4f6:	3f4080e7          	jalr	1012(ra) # 8e6 <exit>

00000000000004fa <testcase1>:

void testcase1()
{
 4fa:	1101                	addi	sp,sp,-32
 4fc:	ec06                	sd	ra,24(sp)
 4fe:	e822                	sd	s0,16(sp)
 500:	e426                	sd	s1,8(sp)
 502:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 504:	00001517          	auipc	a0,0x1
 508:	c3c50513          	addi	a0,a0,-964 # 1140 <malloc+0x400>
 50c:	00000097          	auipc	ra,0x0
 510:	77c080e7          	jalr	1916(ra) # c88 <printf>
    printf("[prnt] v1 --> ");
 514:	00001517          	auipc	a0,0x1
 518:	93c50513          	addi	a0,a0,-1732 # e50 <malloc+0x110>
 51c:	00000097          	auipc	ra,0x0
 520:	76c080e7          	jalr	1900(ra) # c88 <printf>
    print_free_frame_cnt();
 524:	00000097          	auipc	ra,0x0
 528:	482080e7          	jalr	1154(ra) # 9a6 <pfreepages>

    if ((pid = fork()) == 0)
 52c:	00000097          	auipc	ra,0x0
 530:	3b2080e7          	jalr	946(ra) # 8de <fork>
 534:	c531                	beqz	a0,580 <testcase1+0x86>
 536:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 538:	00001517          	auipc	a0,0x1
 53c:	ad050513          	addi	a0,a0,-1328 # 1008 <malloc+0x2c8>
 540:	00000097          	auipc	ra,0x0
 544:	748080e7          	jalr	1864(ra) # c88 <printf>
        print_free_frame_cnt();
 548:	00000097          	auipc	ra,0x0
 54c:	45e080e7          	jalr	1118(ra) # 9a6 <pfreepages>
    }

    if (wait(0) != pid)
 550:	4501                	li	a0,0
 552:	00000097          	auipc	ra,0x0
 556:	39c080e7          	jalr	924(ra) # 8ee <wait>
 55a:	04951a63          	bne	a0,s1,5ae <testcase1+0xb4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 55e:	00001517          	auipc	a0,0x1
 562:	c1250513          	addi	a0,a0,-1006 # 1170 <malloc+0x430>
 566:	00000097          	auipc	ra,0x0
 56a:	722080e7          	jalr	1826(ra) # c88 <printf>
    print_free_frame_cnt();
 56e:	00000097          	auipc	ra,0x0
 572:	438080e7          	jalr	1080(ra) # 9a6 <pfreepages>
}
 576:	60e2                	ld	ra,24(sp)
 578:	6442                	ld	s0,16(sp)
 57a:	64a2                	ld	s1,8(sp)
 57c:	6105                	addi	sp,sp,32
 57e:	8082                	ret
        sleep(50);
 580:	03200513          	li	a0,50
 584:	00000097          	auipc	ra,0x0
 588:	3f2080e7          	jalr	1010(ra) # 976 <sleep>
        printf("[chld] v2 --> ");
 58c:	00001517          	auipc	a0,0x1
 590:	bd450513          	addi	a0,a0,-1068 # 1160 <malloc+0x420>
 594:	00000097          	auipc	ra,0x0
 598:	6f4080e7          	jalr	1780(ra) # c88 <printf>
        print_free_frame_cnt();
 59c:	00000097          	auipc	ra,0x0
 5a0:	40a080e7          	jalr	1034(ra) # 9a6 <pfreepages>
        exit(0);
 5a4:	4501                	li	a0,0
 5a6:	00000097          	auipc	ra,0x0
 5aa:	340080e7          	jalr	832(ra) # 8e6 <exit>
        printf("wait() error!");
 5ae:	00001517          	auipc	a0,0x1
 5b2:	8b250513          	addi	a0,a0,-1870 # e60 <malloc+0x120>
 5b6:	00000097          	auipc	ra,0x0
 5ba:	6d2080e7          	jalr	1746(ra) # c88 <printf>
        exit(1);
 5be:	4505                	li	a0,1
 5c0:	00000097          	auipc	ra,0x0
 5c4:	326080e7          	jalr	806(ra) # 8e6 <exit>

00000000000005c8 <main>:

int main(int argc, char *argv[])
{
 5c8:	1101                	addi	sp,sp,-32
 5ca:	ec06                	sd	ra,24(sp)
 5cc:	e822                	sd	s0,16(sp)
 5ce:	e426                	sd	s1,8(sp)
 5d0:	1000                	addi	s0,sp,32
 5d2:	84ae                	mv	s1,a1
    if (argc < 2)
 5d4:	4785                	li	a5,1
 5d6:	02a7d863          	bge	a5,a0,606 <main+0x3e>
    {
        printf("Usage: cowtest test_id");
    }
    switch (atoi(argv[1]))
 5da:	6488                	ld	a0,8(s1)
 5dc:	00000097          	auipc	ra,0x0
 5e0:	210080e7          	jalr	528(ra) # 7ec <atoi>
 5e4:	478d                	li	a5,3
 5e6:	04f50c63          	beq	a0,a5,63e <main+0x76>
 5ea:	02a7c763          	blt	a5,a0,618 <main+0x50>
 5ee:	4785                	li	a5,1
 5f0:	02f50d63          	beq	a0,a5,62a <main+0x62>
 5f4:	4789                	li	a5,2
 5f6:	04f51a63          	bne	a0,a5,64a <main+0x82>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e02080e7          	jalr	-510(ra) # 3fc <testcase2>

    default:
        printf("Error: No test with index %s", argv[1]);
        return 1;
    }
    return 0;
 602:	4501                	li	a0,0
        break;
 604:	a805                	j	634 <main+0x6c>
        printf("Usage: cowtest test_id");
 606:	00001517          	auipc	a0,0x1
 60a:	b7a50513          	addi	a0,a0,-1158 # 1180 <malloc+0x440>
 60e:	00000097          	auipc	ra,0x0
 612:	67a080e7          	jalr	1658(ra) # c88 <printf>
 616:	b7d1                	j	5da <main+0x12>
    switch (atoi(argv[1]))
 618:	4791                	li	a5,4
 61a:	02f51863          	bne	a0,a5,64a <main+0x82>
        testcase4();
 61e:	00000097          	auipc	ra,0x0
 622:	aa4080e7          	jalr	-1372(ra) # c2 <testcase4>
    return 0;
 626:	4501                	li	a0,0
        break;
 628:	a031                	j	634 <main+0x6c>
        testcase1();
 62a:	00000097          	auipc	ra,0x0
 62e:	ed0080e7          	jalr	-304(ra) # 4fa <testcase1>
    return 0;
 632:	4501                	li	a0,0
 634:	60e2                	ld	ra,24(sp)
 636:	6442                	ld	s0,16(sp)
 638:	64a2                	ld	s1,8(sp)
 63a:	6105                	addi	sp,sp,32
 63c:	8082                	ret
        testcase3();
 63e:	00000097          	auipc	ra,0x0
 642:	c88080e7          	jalr	-888(ra) # 2c6 <testcase3>
    return 0;
 646:	4501                	li	a0,0
        break;
 648:	b7f5                	j	634 <main+0x6c>
        printf("Error: No test with index %s", argv[1]);
 64a:	648c                	ld	a1,8(s1)
 64c:	00001517          	auipc	a0,0x1
 650:	b4c50513          	addi	a0,a0,-1204 # 1198 <malloc+0x458>
 654:	00000097          	auipc	ra,0x0
 658:	634080e7          	jalr	1588(ra) # c88 <printf>
        return 1;
 65c:	4505                	li	a0,1
 65e:	bfd9                	j	634 <main+0x6c>

0000000000000660 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 660:	1141                	addi	sp,sp,-16
 662:	e406                	sd	ra,8(sp)
 664:	e022                	sd	s0,0(sp)
 666:	0800                	addi	s0,sp,16
  extern int main();
  main();
 668:	00000097          	auipc	ra,0x0
 66c:	f60080e7          	jalr	-160(ra) # 5c8 <main>
  exit(0);
 670:	4501                	li	a0,0
 672:	00000097          	auipc	ra,0x0
 676:	274080e7          	jalr	628(ra) # 8e6 <exit>

000000000000067a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 67a:	1141                	addi	sp,sp,-16
 67c:	e422                	sd	s0,8(sp)
 67e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 680:	87aa                	mv	a5,a0
 682:	0585                	addi	a1,a1,1
 684:	0785                	addi	a5,a5,1
 686:	fff5c703          	lbu	a4,-1(a1)
 68a:	fee78fa3          	sb	a4,-1(a5)
 68e:	fb75                	bnez	a4,682 <strcpy+0x8>
    ;
  return os;
}
 690:	6422                	ld	s0,8(sp)
 692:	0141                	addi	sp,sp,16
 694:	8082                	ret

0000000000000696 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 696:	1141                	addi	sp,sp,-16
 698:	e422                	sd	s0,8(sp)
 69a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 69c:	00054783          	lbu	a5,0(a0)
 6a0:	cb91                	beqz	a5,6b4 <strcmp+0x1e>
 6a2:	0005c703          	lbu	a4,0(a1)
 6a6:	00f71763          	bne	a4,a5,6b4 <strcmp+0x1e>
    p++, q++;
 6aa:	0505                	addi	a0,a0,1
 6ac:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6ae:	00054783          	lbu	a5,0(a0)
 6b2:	fbe5                	bnez	a5,6a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6b4:	0005c503          	lbu	a0,0(a1)
}
 6b8:	40a7853b          	subw	a0,a5,a0
 6bc:	6422                	ld	s0,8(sp)
 6be:	0141                	addi	sp,sp,16
 6c0:	8082                	ret

00000000000006c2 <strlen>:

uint
strlen(const char *s)
{
 6c2:	1141                	addi	sp,sp,-16
 6c4:	e422                	sd	s0,8(sp)
 6c6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6c8:	00054783          	lbu	a5,0(a0)
 6cc:	cf91                	beqz	a5,6e8 <strlen+0x26>
 6ce:	0505                	addi	a0,a0,1
 6d0:	87aa                	mv	a5,a0
 6d2:	4685                	li	a3,1
 6d4:	9e89                	subw	a3,a3,a0
 6d6:	00f6853b          	addw	a0,a3,a5
 6da:	0785                	addi	a5,a5,1
 6dc:	fff7c703          	lbu	a4,-1(a5)
 6e0:	fb7d                	bnez	a4,6d6 <strlen+0x14>
    ;
  return n;
}
 6e2:	6422                	ld	s0,8(sp)
 6e4:	0141                	addi	sp,sp,16
 6e6:	8082                	ret
  for(n = 0; s[n]; n++)
 6e8:	4501                	li	a0,0
 6ea:	bfe5                	j	6e2 <strlen+0x20>

00000000000006ec <memset>:

void*
memset(void *dst, int c, uint n)
{
 6ec:	1141                	addi	sp,sp,-16
 6ee:	e422                	sd	s0,8(sp)
 6f0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 6f2:	ca19                	beqz	a2,708 <memset+0x1c>
 6f4:	87aa                	mv	a5,a0
 6f6:	1602                	slli	a2,a2,0x20
 6f8:	9201                	srli	a2,a2,0x20
 6fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 6fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 702:	0785                	addi	a5,a5,1
 704:	fee79de3          	bne	a5,a4,6fe <memset+0x12>
  }
  return dst;
}
 708:	6422                	ld	s0,8(sp)
 70a:	0141                	addi	sp,sp,16
 70c:	8082                	ret

000000000000070e <strchr>:

char*
strchr(const char *s, char c)
{
 70e:	1141                	addi	sp,sp,-16
 710:	e422                	sd	s0,8(sp)
 712:	0800                	addi	s0,sp,16
  for(; *s; s++)
 714:	00054783          	lbu	a5,0(a0)
 718:	cb99                	beqz	a5,72e <strchr+0x20>
    if(*s == c)
 71a:	00f58763          	beq	a1,a5,728 <strchr+0x1a>
  for(; *s; s++)
 71e:	0505                	addi	a0,a0,1
 720:	00054783          	lbu	a5,0(a0)
 724:	fbfd                	bnez	a5,71a <strchr+0xc>
      return (char*)s;
  return 0;
 726:	4501                	li	a0,0
}
 728:	6422                	ld	s0,8(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret
  return 0;
 72e:	4501                	li	a0,0
 730:	bfe5                	j	728 <strchr+0x1a>

0000000000000732 <gets>:

char*
gets(char *buf, int max)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec86                	sd	ra,88(sp)
 736:	e8a2                	sd	s0,80(sp)
 738:	e4a6                	sd	s1,72(sp)
 73a:	e0ca                	sd	s2,64(sp)
 73c:	fc4e                	sd	s3,56(sp)
 73e:	f852                	sd	s4,48(sp)
 740:	f456                	sd	s5,40(sp)
 742:	f05a                	sd	s6,32(sp)
 744:	ec5e                	sd	s7,24(sp)
 746:	1080                	addi	s0,sp,96
 748:	8baa                	mv	s7,a0
 74a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 74c:	892a                	mv	s2,a0
 74e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 750:	4aa9                	li	s5,10
 752:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 754:	89a6                	mv	s3,s1
 756:	2485                	addiw	s1,s1,1
 758:	0344d863          	bge	s1,s4,788 <gets+0x56>
    cc = read(0, &c, 1);
 75c:	4605                	li	a2,1
 75e:	faf40593          	addi	a1,s0,-81
 762:	4501                	li	a0,0
 764:	00000097          	auipc	ra,0x0
 768:	19a080e7          	jalr	410(ra) # 8fe <read>
    if(cc < 1)
 76c:	00a05e63          	blez	a0,788 <gets+0x56>
    buf[i++] = c;
 770:	faf44783          	lbu	a5,-81(s0)
 774:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 778:	01578763          	beq	a5,s5,786 <gets+0x54>
 77c:	0905                	addi	s2,s2,1
 77e:	fd679be3          	bne	a5,s6,754 <gets+0x22>
  for(i=0; i+1 < max; ){
 782:	89a6                	mv	s3,s1
 784:	a011                	j	788 <gets+0x56>
 786:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 788:	99de                	add	s3,s3,s7
 78a:	00098023          	sb	zero,0(s3)
  return buf;
}
 78e:	855e                	mv	a0,s7
 790:	60e6                	ld	ra,88(sp)
 792:	6446                	ld	s0,80(sp)
 794:	64a6                	ld	s1,72(sp)
 796:	6906                	ld	s2,64(sp)
 798:	79e2                	ld	s3,56(sp)
 79a:	7a42                	ld	s4,48(sp)
 79c:	7aa2                	ld	s5,40(sp)
 79e:	7b02                	ld	s6,32(sp)
 7a0:	6be2                	ld	s7,24(sp)
 7a2:	6125                	addi	sp,sp,96
 7a4:	8082                	ret

00000000000007a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 7a6:	1101                	addi	sp,sp,-32
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	e426                	sd	s1,8(sp)
 7ae:	e04a                	sd	s2,0(sp)
 7b0:	1000                	addi	s0,sp,32
 7b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7b4:	4581                	li	a1,0
 7b6:	00000097          	auipc	ra,0x0
 7ba:	170080e7          	jalr	368(ra) # 926 <open>
  if(fd < 0)
 7be:	02054563          	bltz	a0,7e8 <stat+0x42>
 7c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7c4:	85ca                	mv	a1,s2
 7c6:	00000097          	auipc	ra,0x0
 7ca:	178080e7          	jalr	376(ra) # 93e <fstat>
 7ce:	892a                	mv	s2,a0
  close(fd);
 7d0:	8526                	mv	a0,s1
 7d2:	00000097          	auipc	ra,0x0
 7d6:	13c080e7          	jalr	316(ra) # 90e <close>
  return r;
}
 7da:	854a                	mv	a0,s2
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	64a2                	ld	s1,8(sp)
 7e2:	6902                	ld	s2,0(sp)
 7e4:	6105                	addi	sp,sp,32
 7e6:	8082                	ret
    return -1;
 7e8:	597d                	li	s2,-1
 7ea:	bfc5                	j	7da <stat+0x34>

00000000000007ec <atoi>:

int
atoi(const char *s)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7f2:	00054683          	lbu	a3,0(a0)
 7f6:	fd06879b          	addiw	a5,a3,-48
 7fa:	0ff7f793          	zext.b	a5,a5
 7fe:	4625                	li	a2,9
 800:	02f66863          	bltu	a2,a5,830 <atoi+0x44>
 804:	872a                	mv	a4,a0
  n = 0;
 806:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 808:	0705                	addi	a4,a4,1
 80a:	0025179b          	slliw	a5,a0,0x2
 80e:	9fa9                	addw	a5,a5,a0
 810:	0017979b          	slliw	a5,a5,0x1
 814:	9fb5                	addw	a5,a5,a3
 816:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 81a:	00074683          	lbu	a3,0(a4)
 81e:	fd06879b          	addiw	a5,a3,-48
 822:	0ff7f793          	zext.b	a5,a5
 826:	fef671e3          	bgeu	a2,a5,808 <atoi+0x1c>
  return n;
}
 82a:	6422                	ld	s0,8(sp)
 82c:	0141                	addi	sp,sp,16
 82e:	8082                	ret
  n = 0;
 830:	4501                	li	a0,0
 832:	bfe5                	j	82a <atoi+0x3e>

0000000000000834 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 834:	1141                	addi	sp,sp,-16
 836:	e422                	sd	s0,8(sp)
 838:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 83a:	02b57463          	bgeu	a0,a1,862 <memmove+0x2e>
    while(n-- > 0)
 83e:	00c05f63          	blez	a2,85c <memmove+0x28>
 842:	1602                	slli	a2,a2,0x20
 844:	9201                	srli	a2,a2,0x20
 846:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 84a:	872a                	mv	a4,a0
      *dst++ = *src++;
 84c:	0585                	addi	a1,a1,1
 84e:	0705                	addi	a4,a4,1
 850:	fff5c683          	lbu	a3,-1(a1)
 854:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 858:	fee79ae3          	bne	a5,a4,84c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 85c:	6422                	ld	s0,8(sp)
 85e:	0141                	addi	sp,sp,16
 860:	8082                	ret
    dst += n;
 862:	00c50733          	add	a4,a0,a2
    src += n;
 866:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 868:	fec05ae3          	blez	a2,85c <memmove+0x28>
 86c:	fff6079b          	addiw	a5,a2,-1
 870:	1782                	slli	a5,a5,0x20
 872:	9381                	srli	a5,a5,0x20
 874:	fff7c793          	not	a5,a5
 878:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 87a:	15fd                	addi	a1,a1,-1
 87c:	177d                	addi	a4,a4,-1
 87e:	0005c683          	lbu	a3,0(a1)
 882:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 886:	fee79ae3          	bne	a5,a4,87a <memmove+0x46>
 88a:	bfc9                	j	85c <memmove+0x28>

000000000000088c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 88c:	1141                	addi	sp,sp,-16
 88e:	e422                	sd	s0,8(sp)
 890:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 892:	ca05                	beqz	a2,8c2 <memcmp+0x36>
 894:	fff6069b          	addiw	a3,a2,-1
 898:	1682                	slli	a3,a3,0x20
 89a:	9281                	srli	a3,a3,0x20
 89c:	0685                	addi	a3,a3,1
 89e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8a0:	00054783          	lbu	a5,0(a0)
 8a4:	0005c703          	lbu	a4,0(a1)
 8a8:	00e79863          	bne	a5,a4,8b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8ac:	0505                	addi	a0,a0,1
    p2++;
 8ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8b0:	fed518e3          	bne	a0,a3,8a0 <memcmp+0x14>
  }
  return 0;
 8b4:	4501                	li	a0,0
 8b6:	a019                	j	8bc <memcmp+0x30>
      return *p1 - *p2;
 8b8:	40e7853b          	subw	a0,a5,a4
}
 8bc:	6422                	ld	s0,8(sp)
 8be:	0141                	addi	sp,sp,16
 8c0:	8082                	ret
  return 0;
 8c2:	4501                	li	a0,0
 8c4:	bfe5                	j	8bc <memcmp+0x30>

00000000000008c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 8c6:	1141                	addi	sp,sp,-16
 8c8:	e406                	sd	ra,8(sp)
 8ca:	e022                	sd	s0,0(sp)
 8cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 8ce:	00000097          	auipc	ra,0x0
 8d2:	f66080e7          	jalr	-154(ra) # 834 <memmove>
}
 8d6:	60a2                	ld	ra,8(sp)
 8d8:	6402                	ld	s0,0(sp)
 8da:	0141                	addi	sp,sp,16
 8dc:	8082                	ret

00000000000008de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 8de:	4885                	li	a7,1
 ecall
 8e0:	00000073          	ecall
 ret
 8e4:	8082                	ret

00000000000008e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 8e6:	4889                	li	a7,2
 ecall
 8e8:	00000073          	ecall
 ret
 8ec:	8082                	ret

00000000000008ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 8ee:	488d                	li	a7,3
 ecall
 8f0:	00000073          	ecall
 ret
 8f4:	8082                	ret

00000000000008f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 8f6:	4891                	li	a7,4
 ecall
 8f8:	00000073          	ecall
 ret
 8fc:	8082                	ret

00000000000008fe <read>:
.global read
read:
 li a7, SYS_read
 8fe:	4895                	li	a7,5
 ecall
 900:	00000073          	ecall
 ret
 904:	8082                	ret

0000000000000906 <write>:
.global write
write:
 li a7, SYS_write
 906:	48c1                	li	a7,16
 ecall
 908:	00000073          	ecall
 ret
 90c:	8082                	ret

000000000000090e <close>:
.global close
close:
 li a7, SYS_close
 90e:	48d5                	li	a7,21
 ecall
 910:	00000073          	ecall
 ret
 914:	8082                	ret

0000000000000916 <kill>:
.global kill
kill:
 li a7, SYS_kill
 916:	4899                	li	a7,6
 ecall
 918:	00000073          	ecall
 ret
 91c:	8082                	ret

000000000000091e <exec>:
.global exec
exec:
 li a7, SYS_exec
 91e:	489d                	li	a7,7
 ecall
 920:	00000073          	ecall
 ret
 924:	8082                	ret

0000000000000926 <open>:
.global open
open:
 li a7, SYS_open
 926:	48bd                	li	a7,15
 ecall
 928:	00000073          	ecall
 ret
 92c:	8082                	ret

000000000000092e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 92e:	48c5                	li	a7,17
 ecall
 930:	00000073          	ecall
 ret
 934:	8082                	ret

0000000000000936 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 936:	48c9                	li	a7,18
 ecall
 938:	00000073          	ecall
 ret
 93c:	8082                	ret

000000000000093e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 93e:	48a1                	li	a7,8
 ecall
 940:	00000073          	ecall
 ret
 944:	8082                	ret

0000000000000946 <link>:
.global link
link:
 li a7, SYS_link
 946:	48cd                	li	a7,19
 ecall
 948:	00000073          	ecall
 ret
 94c:	8082                	ret

000000000000094e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 94e:	48d1                	li	a7,20
 ecall
 950:	00000073          	ecall
 ret
 954:	8082                	ret

0000000000000956 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 956:	48a5                	li	a7,9
 ecall
 958:	00000073          	ecall
 ret
 95c:	8082                	ret

000000000000095e <dup>:
.global dup
dup:
 li a7, SYS_dup
 95e:	48a9                	li	a7,10
 ecall
 960:	00000073          	ecall
 ret
 964:	8082                	ret

0000000000000966 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 966:	48ad                	li	a7,11
 ecall
 968:	00000073          	ecall
 ret
 96c:	8082                	ret

000000000000096e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 96e:	48b1                	li	a7,12
 ecall
 970:	00000073          	ecall
 ret
 974:	8082                	ret

0000000000000976 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 976:	48b5                	li	a7,13
 ecall
 978:	00000073          	ecall
 ret
 97c:	8082                	ret

000000000000097e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 97e:	48b9                	li	a7,14
 ecall
 980:	00000073          	ecall
 ret
 984:	8082                	ret

0000000000000986 <ps>:
.global ps
ps:
 li a7, SYS_ps
 986:	48d9                	li	a7,22
 ecall
 988:	00000073          	ecall
 ret
 98c:	8082                	ret

000000000000098e <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 98e:	48dd                	li	a7,23
 ecall
 990:	00000073          	ecall
 ret
 994:	8082                	ret

0000000000000996 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 996:	48e1                	li	a7,24
 ecall
 998:	00000073          	ecall
 ret
 99c:	8082                	ret

000000000000099e <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 99e:	48e9                	li	a7,26
 ecall
 9a0:	00000073          	ecall
 ret
 9a4:	8082                	ret

00000000000009a6 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 9a6:	48e5                	li	a7,25
 ecall
 9a8:	00000073          	ecall
 ret
 9ac:	8082                	ret

00000000000009ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9ae:	1101                	addi	sp,sp,-32
 9b0:	ec06                	sd	ra,24(sp)
 9b2:	e822                	sd	s0,16(sp)
 9b4:	1000                	addi	s0,sp,32
 9b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9ba:	4605                	li	a2,1
 9bc:	fef40593          	addi	a1,s0,-17
 9c0:	00000097          	auipc	ra,0x0
 9c4:	f46080e7          	jalr	-186(ra) # 906 <write>
}
 9c8:	60e2                	ld	ra,24(sp)
 9ca:	6442                	ld	s0,16(sp)
 9cc:	6105                	addi	sp,sp,32
 9ce:	8082                	ret

00000000000009d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9d0:	7139                	addi	sp,sp,-64
 9d2:	fc06                	sd	ra,56(sp)
 9d4:	f822                	sd	s0,48(sp)
 9d6:	f426                	sd	s1,40(sp)
 9d8:	f04a                	sd	s2,32(sp)
 9da:	ec4e                	sd	s3,24(sp)
 9dc:	0080                	addi	s0,sp,64
 9de:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 9e0:	c299                	beqz	a3,9e6 <printint+0x16>
 9e2:	0805c963          	bltz	a1,a74 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 9e6:	2581                	sext.w	a1,a1
  neg = 0;
 9e8:	4881                	li	a7,0
 9ea:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 9ee:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 9f0:	2601                	sext.w	a2,a2
 9f2:	00001517          	auipc	a0,0x1
 9f6:	82650513          	addi	a0,a0,-2010 # 1218 <digits>
 9fa:	883a                	mv	a6,a4
 9fc:	2705                	addiw	a4,a4,1
 9fe:	02c5f7bb          	remuw	a5,a1,a2
 a02:	1782                	slli	a5,a5,0x20
 a04:	9381                	srli	a5,a5,0x20
 a06:	97aa                	add	a5,a5,a0
 a08:	0007c783          	lbu	a5,0(a5)
 a0c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a10:	0005879b          	sext.w	a5,a1
 a14:	02c5d5bb          	divuw	a1,a1,a2
 a18:	0685                	addi	a3,a3,1
 a1a:	fec7f0e3          	bgeu	a5,a2,9fa <printint+0x2a>
  if(neg)
 a1e:	00088c63          	beqz	a7,a36 <printint+0x66>
    buf[i++] = '-';
 a22:	fd070793          	addi	a5,a4,-48
 a26:	00878733          	add	a4,a5,s0
 a2a:	02d00793          	li	a5,45
 a2e:	fef70823          	sb	a5,-16(a4)
 a32:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a36:	02e05863          	blez	a4,a66 <printint+0x96>
 a3a:	fc040793          	addi	a5,s0,-64
 a3e:	00e78933          	add	s2,a5,a4
 a42:	fff78993          	addi	s3,a5,-1
 a46:	99ba                	add	s3,s3,a4
 a48:	377d                	addiw	a4,a4,-1
 a4a:	1702                	slli	a4,a4,0x20
 a4c:	9301                	srli	a4,a4,0x20
 a4e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a52:	fff94583          	lbu	a1,-1(s2)
 a56:	8526                	mv	a0,s1
 a58:	00000097          	auipc	ra,0x0
 a5c:	f56080e7          	jalr	-170(ra) # 9ae <putc>
  while(--i >= 0)
 a60:	197d                	addi	s2,s2,-1
 a62:	ff3918e3          	bne	s2,s3,a52 <printint+0x82>
}
 a66:	70e2                	ld	ra,56(sp)
 a68:	7442                	ld	s0,48(sp)
 a6a:	74a2                	ld	s1,40(sp)
 a6c:	7902                	ld	s2,32(sp)
 a6e:	69e2                	ld	s3,24(sp)
 a70:	6121                	addi	sp,sp,64
 a72:	8082                	ret
    x = -xx;
 a74:	40b005bb          	negw	a1,a1
    neg = 1;
 a78:	4885                	li	a7,1
    x = -xx;
 a7a:	bf85                	j	9ea <printint+0x1a>

0000000000000a7c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a7c:	7119                	addi	sp,sp,-128
 a7e:	fc86                	sd	ra,120(sp)
 a80:	f8a2                	sd	s0,112(sp)
 a82:	f4a6                	sd	s1,104(sp)
 a84:	f0ca                	sd	s2,96(sp)
 a86:	ecce                	sd	s3,88(sp)
 a88:	e8d2                	sd	s4,80(sp)
 a8a:	e4d6                	sd	s5,72(sp)
 a8c:	e0da                	sd	s6,64(sp)
 a8e:	fc5e                	sd	s7,56(sp)
 a90:	f862                	sd	s8,48(sp)
 a92:	f466                	sd	s9,40(sp)
 a94:	f06a                	sd	s10,32(sp)
 a96:	ec6e                	sd	s11,24(sp)
 a98:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 a9a:	0005c903          	lbu	s2,0(a1)
 a9e:	18090f63          	beqz	s2,c3c <vprintf+0x1c0>
 aa2:	8aaa                	mv	s5,a0
 aa4:	8b32                	mv	s6,a2
 aa6:	00158493          	addi	s1,a1,1
  state = 0;
 aaa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 aac:	02500a13          	li	s4,37
 ab0:	4c55                	li	s8,21
 ab2:	00000c97          	auipc	s9,0x0
 ab6:	70ec8c93          	addi	s9,s9,1806 # 11c0 <malloc+0x480>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 aba:	02800d93          	li	s11,40
  putc(fd, 'x');
 abe:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ac0:	00000b97          	auipc	s7,0x0
 ac4:	758b8b93          	addi	s7,s7,1880 # 1218 <digits>
 ac8:	a839                	j	ae6 <vprintf+0x6a>
        putc(fd, c);
 aca:	85ca                	mv	a1,s2
 acc:	8556                	mv	a0,s5
 ace:	00000097          	auipc	ra,0x0
 ad2:	ee0080e7          	jalr	-288(ra) # 9ae <putc>
 ad6:	a019                	j	adc <vprintf+0x60>
    } else if(state == '%'){
 ad8:	01498d63          	beq	s3,s4,af2 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 adc:	0485                	addi	s1,s1,1
 ade:	fff4c903          	lbu	s2,-1(s1)
 ae2:	14090d63          	beqz	s2,c3c <vprintf+0x1c0>
    if(state == 0){
 ae6:	fe0999e3          	bnez	s3,ad8 <vprintf+0x5c>
      if(c == '%'){
 aea:	ff4910e3          	bne	s2,s4,aca <vprintf+0x4e>
        state = '%';
 aee:	89d2                	mv	s3,s4
 af0:	b7f5                	j	adc <vprintf+0x60>
      if(c == 'd'){
 af2:	11490c63          	beq	s2,s4,c0a <vprintf+0x18e>
 af6:	f9d9079b          	addiw	a5,s2,-99
 afa:	0ff7f793          	zext.b	a5,a5
 afe:	10fc6e63          	bltu	s8,a5,c1a <vprintf+0x19e>
 b02:	f9d9079b          	addiw	a5,s2,-99
 b06:	0ff7f713          	zext.b	a4,a5
 b0a:	10ec6863          	bltu	s8,a4,c1a <vprintf+0x19e>
 b0e:	00271793          	slli	a5,a4,0x2
 b12:	97e6                	add	a5,a5,s9
 b14:	439c                	lw	a5,0(a5)
 b16:	97e6                	add	a5,a5,s9
 b18:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 b1a:	008b0913          	addi	s2,s6,8
 b1e:	4685                	li	a3,1
 b20:	4629                	li	a2,10
 b22:	000b2583          	lw	a1,0(s6)
 b26:	8556                	mv	a0,s5
 b28:	00000097          	auipc	ra,0x0
 b2c:	ea8080e7          	jalr	-344(ra) # 9d0 <printint>
 b30:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 b32:	4981                	li	s3,0
 b34:	b765                	j	adc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b36:	008b0913          	addi	s2,s6,8
 b3a:	4681                	li	a3,0
 b3c:	4629                	li	a2,10
 b3e:	000b2583          	lw	a1,0(s6)
 b42:	8556                	mv	a0,s5
 b44:	00000097          	auipc	ra,0x0
 b48:	e8c080e7          	jalr	-372(ra) # 9d0 <printint>
 b4c:	8b4a                	mv	s6,s2
      state = 0;
 b4e:	4981                	li	s3,0
 b50:	b771                	j	adc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b52:	008b0913          	addi	s2,s6,8
 b56:	4681                	li	a3,0
 b58:	866a                	mv	a2,s10
 b5a:	000b2583          	lw	a1,0(s6)
 b5e:	8556                	mv	a0,s5
 b60:	00000097          	auipc	ra,0x0
 b64:	e70080e7          	jalr	-400(ra) # 9d0 <printint>
 b68:	8b4a                	mv	s6,s2
      state = 0;
 b6a:	4981                	li	s3,0
 b6c:	bf85                	j	adc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 b6e:	008b0793          	addi	a5,s6,8
 b72:	f8f43423          	sd	a5,-120(s0)
 b76:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 b7a:	03000593          	li	a1,48
 b7e:	8556                	mv	a0,s5
 b80:	00000097          	auipc	ra,0x0
 b84:	e2e080e7          	jalr	-466(ra) # 9ae <putc>
  putc(fd, 'x');
 b88:	07800593          	li	a1,120
 b8c:	8556                	mv	a0,s5
 b8e:	00000097          	auipc	ra,0x0
 b92:	e20080e7          	jalr	-480(ra) # 9ae <putc>
 b96:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b98:	03c9d793          	srli	a5,s3,0x3c
 b9c:	97de                	add	a5,a5,s7
 b9e:	0007c583          	lbu	a1,0(a5)
 ba2:	8556                	mv	a0,s5
 ba4:	00000097          	auipc	ra,0x0
 ba8:	e0a080e7          	jalr	-502(ra) # 9ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bac:	0992                	slli	s3,s3,0x4
 bae:	397d                	addiw	s2,s2,-1
 bb0:	fe0914e3          	bnez	s2,b98 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 bb4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 bb8:	4981                	li	s3,0
 bba:	b70d                	j	adc <vprintf+0x60>
        s = va_arg(ap, char*);
 bbc:	008b0913          	addi	s2,s6,8
 bc0:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 bc4:	02098163          	beqz	s3,be6 <vprintf+0x16a>
        while(*s != 0){
 bc8:	0009c583          	lbu	a1,0(s3)
 bcc:	c5ad                	beqz	a1,c36 <vprintf+0x1ba>
          putc(fd, *s);
 bce:	8556                	mv	a0,s5
 bd0:	00000097          	auipc	ra,0x0
 bd4:	dde080e7          	jalr	-546(ra) # 9ae <putc>
          s++;
 bd8:	0985                	addi	s3,s3,1
        while(*s != 0){
 bda:	0009c583          	lbu	a1,0(s3)
 bde:	f9e5                	bnez	a1,bce <vprintf+0x152>
        s = va_arg(ap, char*);
 be0:	8b4a                	mv	s6,s2
      state = 0;
 be2:	4981                	li	s3,0
 be4:	bde5                	j	adc <vprintf+0x60>
          s = "(null)";
 be6:	00000997          	auipc	s3,0x0
 bea:	5d298993          	addi	s3,s3,1490 # 11b8 <malloc+0x478>
        while(*s != 0){
 bee:	85ee                	mv	a1,s11
 bf0:	bff9                	j	bce <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 bf2:	008b0913          	addi	s2,s6,8
 bf6:	000b4583          	lbu	a1,0(s6)
 bfa:	8556                	mv	a0,s5
 bfc:	00000097          	auipc	ra,0x0
 c00:	db2080e7          	jalr	-590(ra) # 9ae <putc>
 c04:	8b4a                	mv	s6,s2
      state = 0;
 c06:	4981                	li	s3,0
 c08:	bdd1                	j	adc <vprintf+0x60>
        putc(fd, c);
 c0a:	85d2                	mv	a1,s4
 c0c:	8556                	mv	a0,s5
 c0e:	00000097          	auipc	ra,0x0
 c12:	da0080e7          	jalr	-608(ra) # 9ae <putc>
      state = 0;
 c16:	4981                	li	s3,0
 c18:	b5d1                	j	adc <vprintf+0x60>
        putc(fd, '%');
 c1a:	85d2                	mv	a1,s4
 c1c:	8556                	mv	a0,s5
 c1e:	00000097          	auipc	ra,0x0
 c22:	d90080e7          	jalr	-624(ra) # 9ae <putc>
        putc(fd, c);
 c26:	85ca                	mv	a1,s2
 c28:	8556                	mv	a0,s5
 c2a:	00000097          	auipc	ra,0x0
 c2e:	d84080e7          	jalr	-636(ra) # 9ae <putc>
      state = 0;
 c32:	4981                	li	s3,0
 c34:	b565                	j	adc <vprintf+0x60>
        s = va_arg(ap, char*);
 c36:	8b4a                	mv	s6,s2
      state = 0;
 c38:	4981                	li	s3,0
 c3a:	b54d                	j	adc <vprintf+0x60>
    }
  }
}
 c3c:	70e6                	ld	ra,120(sp)
 c3e:	7446                	ld	s0,112(sp)
 c40:	74a6                	ld	s1,104(sp)
 c42:	7906                	ld	s2,96(sp)
 c44:	69e6                	ld	s3,88(sp)
 c46:	6a46                	ld	s4,80(sp)
 c48:	6aa6                	ld	s5,72(sp)
 c4a:	6b06                	ld	s6,64(sp)
 c4c:	7be2                	ld	s7,56(sp)
 c4e:	7c42                	ld	s8,48(sp)
 c50:	7ca2                	ld	s9,40(sp)
 c52:	7d02                	ld	s10,32(sp)
 c54:	6de2                	ld	s11,24(sp)
 c56:	6109                	addi	sp,sp,128
 c58:	8082                	ret

0000000000000c5a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c5a:	715d                	addi	sp,sp,-80
 c5c:	ec06                	sd	ra,24(sp)
 c5e:	e822                	sd	s0,16(sp)
 c60:	1000                	addi	s0,sp,32
 c62:	e010                	sd	a2,0(s0)
 c64:	e414                	sd	a3,8(s0)
 c66:	e818                	sd	a4,16(s0)
 c68:	ec1c                	sd	a5,24(s0)
 c6a:	03043023          	sd	a6,32(s0)
 c6e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c72:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c76:	8622                	mv	a2,s0
 c78:	00000097          	auipc	ra,0x0
 c7c:	e04080e7          	jalr	-508(ra) # a7c <vprintf>
}
 c80:	60e2                	ld	ra,24(sp)
 c82:	6442                	ld	s0,16(sp)
 c84:	6161                	addi	sp,sp,80
 c86:	8082                	ret

0000000000000c88 <printf>:

void
printf(const char *fmt, ...)
{
 c88:	711d                	addi	sp,sp,-96
 c8a:	ec06                	sd	ra,24(sp)
 c8c:	e822                	sd	s0,16(sp)
 c8e:	1000                	addi	s0,sp,32
 c90:	e40c                	sd	a1,8(s0)
 c92:	e810                	sd	a2,16(s0)
 c94:	ec14                	sd	a3,24(s0)
 c96:	f018                	sd	a4,32(s0)
 c98:	f41c                	sd	a5,40(s0)
 c9a:	03043823          	sd	a6,48(s0)
 c9e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ca2:	00840613          	addi	a2,s0,8
 ca6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 caa:	85aa                	mv	a1,a0
 cac:	4505                	li	a0,1
 cae:	00000097          	auipc	ra,0x0
 cb2:	dce080e7          	jalr	-562(ra) # a7c <vprintf>
}
 cb6:	60e2                	ld	ra,24(sp)
 cb8:	6442                	ld	s0,16(sp)
 cba:	6125                	addi	sp,sp,96
 cbc:	8082                	ret

0000000000000cbe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cbe:	1141                	addi	sp,sp,-16
 cc0:	e422                	sd	s0,8(sp)
 cc2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cc4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cc8:	00001797          	auipc	a5,0x1
 ccc:	3407b783          	ld	a5,832(a5) # 2008 <freep>
 cd0:	a02d                	j	cfa <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cd2:	4618                	lw	a4,8(a2)
 cd4:	9f2d                	addw	a4,a4,a1
 cd6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cda:	6398                	ld	a4,0(a5)
 cdc:	6310                	ld	a2,0(a4)
 cde:	a83d                	j	d1c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 ce0:	ff852703          	lw	a4,-8(a0)
 ce4:	9f31                	addw	a4,a4,a2
 ce6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 ce8:	ff053683          	ld	a3,-16(a0)
 cec:	a091                	j	d30 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cee:	6398                	ld	a4,0(a5)
 cf0:	00e7e463          	bltu	a5,a4,cf8 <free+0x3a>
 cf4:	00e6ea63          	bltu	a3,a4,d08 <free+0x4a>
{
 cf8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cfa:	fed7fae3          	bgeu	a5,a3,cee <free+0x30>
 cfe:	6398                	ld	a4,0(a5)
 d00:	00e6e463          	bltu	a3,a4,d08 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d04:	fee7eae3          	bltu	a5,a4,cf8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 d08:	ff852583          	lw	a1,-8(a0)
 d0c:	6390                	ld	a2,0(a5)
 d0e:	02059813          	slli	a6,a1,0x20
 d12:	01c85713          	srli	a4,a6,0x1c
 d16:	9736                	add	a4,a4,a3
 d18:	fae60de3          	beq	a2,a4,cd2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d1c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d20:	4790                	lw	a2,8(a5)
 d22:	02061593          	slli	a1,a2,0x20
 d26:	01c5d713          	srli	a4,a1,0x1c
 d2a:	973e                	add	a4,a4,a5
 d2c:	fae68ae3          	beq	a3,a4,ce0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 d30:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d32:	00001717          	auipc	a4,0x1
 d36:	2cf73b23          	sd	a5,726(a4) # 2008 <freep>
}
 d3a:	6422                	ld	s0,8(sp)
 d3c:	0141                	addi	sp,sp,16
 d3e:	8082                	ret

0000000000000d40 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d40:	7139                	addi	sp,sp,-64
 d42:	fc06                	sd	ra,56(sp)
 d44:	f822                	sd	s0,48(sp)
 d46:	f426                	sd	s1,40(sp)
 d48:	f04a                	sd	s2,32(sp)
 d4a:	ec4e                	sd	s3,24(sp)
 d4c:	e852                	sd	s4,16(sp)
 d4e:	e456                	sd	s5,8(sp)
 d50:	e05a                	sd	s6,0(sp)
 d52:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d54:	02051493          	slli	s1,a0,0x20
 d58:	9081                	srli	s1,s1,0x20
 d5a:	04bd                	addi	s1,s1,15
 d5c:	8091                	srli	s1,s1,0x4
 d5e:	0014899b          	addiw	s3,s1,1
 d62:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d64:	00001517          	auipc	a0,0x1
 d68:	2a453503          	ld	a0,676(a0) # 2008 <freep>
 d6c:	c515                	beqz	a0,d98 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d6e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d70:	4798                	lw	a4,8(a5)
 d72:	02977f63          	bgeu	a4,s1,db0 <malloc+0x70>
 d76:	8a4e                	mv	s4,s3
 d78:	0009871b          	sext.w	a4,s3
 d7c:	6685                	lui	a3,0x1
 d7e:	00d77363          	bgeu	a4,a3,d84 <malloc+0x44>
 d82:	6a05                	lui	s4,0x1
 d84:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d88:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d8c:	00001917          	auipc	s2,0x1
 d90:	27c90913          	addi	s2,s2,636 # 2008 <freep>
  if(p == (char*)-1)
 d94:	5afd                	li	s5,-1
 d96:	a895                	j	e0a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 d98:	04001797          	auipc	a5,0x4001
 d9c:	27878793          	addi	a5,a5,632 # 4002010 <base>
 da0:	00001717          	auipc	a4,0x1
 da4:	26f73423          	sd	a5,616(a4) # 2008 <freep>
 da8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 daa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dae:	b7e1                	j	d76 <malloc+0x36>
      if(p->s.size == nunits)
 db0:	02e48c63          	beq	s1,a4,de8 <malloc+0xa8>
        p->s.size -= nunits;
 db4:	4137073b          	subw	a4,a4,s3
 db8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 dba:	02071693          	slli	a3,a4,0x20
 dbe:	01c6d713          	srli	a4,a3,0x1c
 dc2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 dc4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 dc8:	00001717          	auipc	a4,0x1
 dcc:	24a73023          	sd	a0,576(a4) # 2008 <freep>
      return (void*)(p + 1);
 dd0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 dd4:	70e2                	ld	ra,56(sp)
 dd6:	7442                	ld	s0,48(sp)
 dd8:	74a2                	ld	s1,40(sp)
 dda:	7902                	ld	s2,32(sp)
 ddc:	69e2                	ld	s3,24(sp)
 dde:	6a42                	ld	s4,16(sp)
 de0:	6aa2                	ld	s5,8(sp)
 de2:	6b02                	ld	s6,0(sp)
 de4:	6121                	addi	sp,sp,64
 de6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 de8:	6398                	ld	a4,0(a5)
 dea:	e118                	sd	a4,0(a0)
 dec:	bff1                	j	dc8 <malloc+0x88>
  hp->s.size = nu;
 dee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 df2:	0541                	addi	a0,a0,16
 df4:	00000097          	auipc	ra,0x0
 df8:	eca080e7          	jalr	-310(ra) # cbe <free>
  return freep;
 dfc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e00:	d971                	beqz	a0,dd4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e02:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e04:	4798                	lw	a4,8(a5)
 e06:	fa9775e3          	bgeu	a4,s1,db0 <malloc+0x70>
    if(p == freep)
 e0a:	00093703          	ld	a4,0(s2)
 e0e:	853e                	mv	a0,a5
 e10:	fef719e3          	bne	a4,a5,e02 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 e14:	8552                	mv	a0,s4
 e16:	00000097          	auipc	ra,0x0
 e1a:	b58080e7          	jalr	-1192(ra) # 96e <sbrk>
  if(p == (char*)-1)
 e1e:	fd5518e3          	bne	a0,s5,dee <malloc+0xae>
        return 0;
 e22:	4501                	li	a0,0
 e24:	bf45                	j	dd4 <malloc+0x94>
