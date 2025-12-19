#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096
#define N 9000
#define MINP 1024

int main(void)
{
  printf("[test_swap] start\n");
  int target = N;
  char *base = (char*)-1;
  while (target >= MINP) {
    printf("[test_swap] Trying to allocate %d pages\n", target);
  base = sbrklazy(target * PGSIZE);
    if (base != (char*)-1) break;
    target = (target * 3) / 4;
  }
  if (base == (char*)-1) {
    printf("[test_swap] sbrk failed for all attempts\nTEST FAILED\n");
    exit(1);
  }
  printf("[test_swap] Allocated %d pages at %p\n", target, base);

  // Write a unique pattern on each page to check persistence across swapout/in
  printf("[test_swap] Writing pattern to each page\n");
  for (int i = 0; i < target; i++) {
    base[i*PGSIZE] = (char)(i & 0x7f);
    if ((i % 1000) == 0) printf("  wrote page %d\n", i);
  }

  // Access a later range to push earlier pages out
  printf("[test_swap] Accessing high pages to induce swapout of early pages\n");
  volatile int sump = 0;
  for (int i = target-1; i >= 0; i -= 97) {
    sump += base[i*PGSIZE];
  }

  // Re-access early pages, expect SWAPIN logs and correct data
  printf("[test_swap] Verifying first 256 pages after pressure\n");
  for (int i = 0; i < 256 && i < target; i++) {
    char v = base[i*PGSIZE];
    if (v != (char)(i & 0x7f)) {
      printf("[test_swap] mismatch at page %d: got %d expected %d\n", i, v, (char)(i & 0x7f));
      printf("TEST FAILED\n");
      exit(1);
    }
  }

  printf("[test_swap] sump=%d\n", sump);
  printf("TEST PASSED\n");
  exit(0);
}
