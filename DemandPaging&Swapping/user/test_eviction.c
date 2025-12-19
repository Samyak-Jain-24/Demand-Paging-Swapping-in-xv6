#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096

// Choose a large count to likely exceed RAM so eviction happens
#define MANY_PAGES 6000
#define MIN_PAGES 1024

int main(void)
{
  printf("[test_eviction] start\n");

    int target = MANY_PAGES;
    char *base = (char*)-1;
    while (target >= MIN_PAGES) {
      printf("[test_eviction] Trying to allocate %d pages...\n", target);
    base = sbrklazy(target * PGSIZE);
      if (base != (char*)-1) break;
      target = (target * 3) / 4; // back off
    }
    if (base == (char*)-1) {
      printf("[test_eviction] sbrk failed for all attempts\nTEST FAILED\n");
      exit(1);
    }
    printf("[test_eviction] Allocated %d pages at %p\n", target, base);

  // Create alternating dirty and clean-ish pages. We'll write to even pages, read from odd.
  printf("[test_eviction] Touching pages to fill memory and force eviction...\n");
  volatile int sum = 0;
    for (int i = 0; i < target; i++) {
    char *p = base + i * PGSIZE;
    if ((i & 1) == 0) {
      p[0] = (char)i; // dirty page
    } else {
      sum += p[0]; // read-only access, cleaner victim candidate
    }
    if ((i % 512) == 0) {
      printf("  touched %d pages...\n", i);
    }
  }

  // Re-access early pages to likely trigger SWAPIN of previously evicted ones
  printf("[test_eviction] Re-accessing first 128 pages to provoke SWAPIN...\n");
    for (int i = 0; i < 128 && i < target; i++) {
    char *p = base + i * PGSIZE;
    sum += p[0];
  }

  printf("[test_eviction] sum=%d\n", sum);
  printf("TEST PASSED\n");
  exit(0);
}
