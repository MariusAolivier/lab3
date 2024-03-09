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
    va2pa(atoi(argv[1]), atoi(argv[2]));
  }
  if (argc == 2) {
    printf("va from main: %s", atoi(argv[1]));
    va2pa(atoi(argv[1]), getpid());
  }
  if (argc == 1) {
    va2pa(0, getpid());
  }
    exit(0);
}