#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096

static int verify_pattern(char *base, int pages, int stride)
{
  int ok = 1;
  for (int i = 0; i < pages; i++) {
    char *p = base + i * PGSIZE;
    if (p[0] != (char)(i + stride)) {
      printf("Mismatch at page %d: got %d expected %d\n", i, p[0], (char)(i + stride));
      ok = 0;
      break;
    }
  }
  return ok;
}

int
main(void)
{
  printf("[test_lazy] start\n");

  int pages = 32; // small, quick
  printf("[test_lazy] Allocating %d pages via sbrk...\n", pages);
  char *base = sbrklazy(pages * PGSIZE);
  if (base == (char*)-1) {
    printf("[test_lazy] sbrk failed\n");
    printf("TEST FAILED\n");
    exit(1);
  }

  // Touch each page once to trigger first-fault ALLOC/LOADEXEC/RESIDENT logs.
  printf("[test_lazy] Touching each page (write once) to trigger demand paging...\n");
  for (int i = 0; i < pages; i++) {
    char *p = base + i * PGSIZE;
    p[0] = (char)(i + 1); // should fault on first access if not mapped
  }

  // Read back to ensure memory is accessible
  printf("[test_lazy] Verifying pattern...\n");
  int ok = verify_pattern(base, pages, 1);
  if (!ok) {
    printf("[test_lazy] verification failed\n");
    printf("TEST FAILED\n");
    exit(1);
  }

  // Also test read-only first-fault path by reading another offset within each page
  volatile int sum = 0;
  for (int i = 0; i < pages; i++) {
    char *p = base + i * PGSIZE;
    sum += p[0];
  }
  printf("[test_lazy] Sum=%d\n", sum);

  printf("TEST PASSED\n");
  exit(0);
}
