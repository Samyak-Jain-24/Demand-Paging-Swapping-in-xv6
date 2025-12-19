#include "kernel/types.h"
#include "user/user.h"

#define PAGES 7875  // adjust to exceed RAM pages

int main(void) {
  printf("FIFO test start\n");
  char *p = sbrk(PAGES * 4096);
  for (int i = 0; i < PAGES * 4096; i += 4096) {
    p[i] = 42;  // touch each page once
  }
  printf("FIFO test end\n");
  exit(0);
}
