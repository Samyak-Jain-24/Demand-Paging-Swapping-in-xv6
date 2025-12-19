#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PGSIZE 4096

// Mix clean and dirty pages to provoke both DISCARD (clean) and SWAPOUT/SWAPIN (dirty).
int
main(void)
{
  printf("[test_swapmix] start\n");
  // Natural eviction: rely on RAM exhaustion (PHYSTOP / QEMU -m)

  int n = 3900; // total pages in first wave
  char *base = sbrklazy(n * PGSIZE);
  if(base == (char*)-1){
    printf("[test_swapmix] sbrklazy failed\n");
    exit(1);
  }

  
  
  // Touch pages: even = dirty (write pattern), odd = clean (read-only)
  printf("[test_swapmix] touching %d pages (even=dirty, odd=clean)\n", n);
  volatile int sink = 0;
  for(int i = 0; i < n; i++){
      memstat();
    if((i & 1) == 0){
      base[i*PGSIZE] = (char)(i & 0x7f);
    } else {
      sink += base[i*PGSIZE]; // read-only: keep clean
    }
  }

  // Second wave to force eviction of early pages
  int m = 3900; // more pages to push out earlier ones
  char *base2 = sbrklazy(m * PGSIZE);
  if(base2 == (char*)-1){
    printf("[test_swapmix] second sbrklazy failed\n");
    exit(1);
  }
  for(int i = 0; i < m; i++){
      memstat();
    // write these to ensure pressure and dirty frames too
    base2[i*PGSIZE] = (char)(0x55);
  }

  // Re-access the first 32 pages.
  // Expect: even pages SWAPIN with original pattern; odd pages DISCARDed -> zero page
  printf("[test_swapmix] verifying first 32 pages\n");
  for(int i = 0; i < 32 && i < n; i++){
      memstat();
    char v = base[i*PGSIZE];
    if((i & 1) == 0){
      char want = (char)(i & 0x7f);
      if(v != want){
        printf("[test_swapmix] dirty page %d mismatch: got %d want %d\n", i, (int)v, (int)want);
        printf("TEST FAILED\n");
        exit(1);
      }
    } else {
      if(v != 0){
        printf("[test_swapmix] clean page %d expected 0 after DISCARD, got %d\n", i, (int)v);
        printf("TEST FAILED\n");
        exit(1);
      }
    }
  }

  printf("[test_swapmix] sink=%d\n", sink);
  printf("TEST PASSED\n");
  exit(0);
}
