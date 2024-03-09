#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{

  if (argc > 3) {
    printf("Usage: vatopa [virtual address] [pid]\n");
    exit(1);
  }
  if (argc == 3){
    int addr = va2pa(atoi(argv[1]), atoi(argv[2]));
    printf("0x%x\n", addr);
  }
  if (argc == 2) {
    int addr = va2pa(atoi(argv[1]), getpid());
    printf("0x%x\n", addr);
  }
  if (argc == 1) {
    int addr = va2pa(0, getpid());
    printf("0x%x\n", addr);
  }
    exit(0);
}