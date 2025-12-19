#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096

static void worker(int id, int pages, int stride)
{
  printf("[test_multi] worker %d: sbrk %d pages\n", id, pages);
  char *base = sbrklazy(pages * PGSIZE);
  if (base == (char*)-1) {
    printf("[test_multi] worker %d: sbrk failed\n", id);
    exit(2);
  }
  volatile int sum = 0;
  for (int i = 0; i < pages; i++) {
    char *p = base + i * PGSIZE;
    if ((i % 3) == 0) p[0] = (char)(i + id); // write
    else sum += p[0]; // read
    if ((i % (pages/4+1)) == 0) printf("[test_multi] worker %d touched %d/%d\n", id, i, pages);
  }
  printf("[test_multi] worker %d done, sum=%d\n", id, sum);
  exit(0);
}

int main(void)
{
  printf("[test_multi] start\n");
  int kids = 3;
  int pages = 1500; // each; moderate to avoid sbrk failure
  for (int i = 0; i < kids; i++) {
    int pid = fork();
    if (pid < 0) {
      printf("[test_multi] fork failed\nTEST FAILED\n");
      exit(1);
    }
    if (pid == 0) {
      worker(i, pages, 17+i);
    }
  }
  int st, ok = 1;
  for (int i = 0; i < kids; i++) {
    wait(&st);
  if (st != 0) ok = 0;
  }
  if (ok) {
    printf("TEST PASSED\n");
    exit(0);
  } else {
    printf("TEST FAILED\n");
    exit(1);
  }
}
