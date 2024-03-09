#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
  uint64 result;

  printf("argv[1]: %s\n", argv[1]); // print argv[1]
    printf("argv[2]: %s\n", argv[2]); //
    
  if (argc > 3) {
    printf("Usage: vatopa [virtual address] [pid]\n");
    exit(1);
  }
  if (argc == 3){
    result = va2pa((uint64)&argv[0], (uint64)&argv[1]);
    printf("%d\n", result);
  }
  if (argc == 2) {
    result = va2pa((uint64)&argv[0], getpid());
    printf("%d\n", result);
  }
  if (argc == 1) {
    result = va2pa(0, getpid());
    printf("%d\n", result);
  }
    exit(0);
}