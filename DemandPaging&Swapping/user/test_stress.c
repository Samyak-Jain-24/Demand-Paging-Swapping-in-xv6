#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096
#define MANY 9000
#define MINP 1024

// Simple LCG for pseudo-randomness in xv6 user space (no srand/rand)
static unsigned long seed = 1;
static unsigned long lcg(void){ seed = seed * 6364136223846793005UL + 1; return seed; }

int main(void)
{
  printf("[test_stress] start\n");
  int pages = MANY; // large to drive swap pressure
  char *base = (char*)-1;
  while (pages >= MINP) {
    printf("[test_stress] sbrk %d pages\n", pages);
  base = sbrklazy(pages * PGSIZE);
    if (base != (char*)-1) break;
    pages = (pages * 3) / 4;
  }
  if (base == (char*)-1) {
    printf("[test_stress] sbrk failed for all attempts\nTEST FAILED\n");
    exit(1);
  }

  // Initialize a subset to mark as dirty
  printf("[test_stress] initializing first 1024 pages\n");
  for (int i = 0; i < 1024 && i < pages; i++) base[i*PGSIZE] = (char)i;

  // Random walk across pages, read/write mix
  int iters = 20000; // bounded runtime
  volatile int sum = 0;
  for (int i = 0; i < iters; i++) {
    int idx = (int)(lcg() % pages);
    char *p = base + idx * PGSIZE;
    if (lcg() & 1) {
      p[0] = (char)(idx ^ (i & 0x7f)); // write
    } else {
      sum += p[0]; // read
    }
    if ((i % 2000) == 0) printf("[test_stress] iter %d/%d\n", i, iters);
  }
  printf("[test_stress] sum=%d\n", sum);
  printf("TEST PASSED\n");
  exit(0);
}
