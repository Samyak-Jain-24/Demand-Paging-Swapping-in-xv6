#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096

// Sequentially dirty many pages to force heavy SWAPOUT, then re-touch to cause SWAPIN.
int
main(void)
{
  printf("[test_swapseq] start\n");

  int pages = 8000;
  char *p = sbrklazy(pages * PGSIZE);
  if(p == (char*)-1){
    printf("[test_swapseq] sbrklazy failed\n");
    exit(1);
  }

  // Dirty all pages with a distinct pattern
  for(int i=0;i<pages;i++){
    p[i*PGSIZE] = (char)(i & 0x7f);
  }

  // Sweep again in a strided order to provoke swapins
  volatile int sum = 0;
  for(int i=pages-1;i>=0;i-=3){
    sum += p[i*PGSIZE];
  }

  // Spot check integrity
  for(int i=0;i<64 && i<pages;i++){
    char v = p[i*PGSIZE];
    char want = (char)(i & 0x7f);
    if(v != want){
      printf("[test_swapseq] mismatch at page %d: got %d want %d\n", i, (int)v, (int)want);
      printf("TEST FAILED\n");
      exit(1);
    }
  }

  printf("[test_swapseq] sum=%d\n", sum);
  printf("TEST PASSED\n");
  exit(0);
}
